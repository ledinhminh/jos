
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
  80003d:	e8 9a 10 00 00       	call   8010dc <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004f:	e8 a0 0f 00 00       	call   800ff4 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 00 23 80 00 	movl   $0x802300,(%esp)
  800063:	e8 b1 01 00 00       	call   800219 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 84 0f 00 00       	call   800ff4 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 1a 23 80 00 	movl   $0x80231a,(%esp)
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
  8000a2:	e8 ed 14 00 00       	call   801594 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 41 15 00 00       	call   801603 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 18 0f 00 00       	call   800ff4 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 30 23 80 00 	movl   $0x802330,(%esp)
  8000fa:	e8 1a 01 00 00       	call   800219 <cprintf>
		if (val == 10)
  8000ff:	a1 04 40 80 00       	mov    0x804004,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 60 14 00 00       	call   801594 <ipc_send>
		if (val == 10)
  800134:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
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
  80015e:	e8 91 0e 00 00       	call   800ff4 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8001a2:	e8 e2 19 00 00       	call   801b89 <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 7c 0e 00 00       	call   80102f <sys_env_destroy>
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
  80020c:	e8 92 0e 00 00       	call   8010a3 <sys_cputs>

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
  800260:	e8 3e 0e 00 00       	call   8010a3 <sys_cputs>
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
  8002fd:	e8 7e 1d 00 00       	call   802080 <__udivdi3>
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
  800358:	e8 53 1e 00 00       	call   8021b0 <__umoddi3>
  80035d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800361:	0f be 80 60 23 80 00 	movsbl 0x802360(%eax),%eax
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
  800445:	ff 24 95 40 25 80 00 	jmp    *0x802540(,%edx,4)
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
  800518:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80051f:	85 d2                	test   %edx,%edx
  800521:	75 20                	jne    800543 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800527:	c7 44 24 08 71 23 80 	movl   $0x802371,0x8(%esp)
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
  800547:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
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
  800581:	b8 7a 23 80 00       	mov    $0x80237a,%eax
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
  8007c5:	c7 44 24 0c 94 24 80 	movl   $0x802494,0xc(%esp)
  8007cc:	00 
  8007cd:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
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
  8007f3:	c7 44 24 0c cc 24 80 	movl   $0x8024cc,0xc(%esp)
  8007fa:	00 
  8007fb:	c7 44 24 08 63 2a 80 	movl   $0x802a63,0x8(%esp)
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
  800d97:	c7 44 24 08 e0 26 80 	movl   $0x8026e0,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800da6:	00 
  800da7:	c7 04 24 fd 26 80 00 	movl   $0x8026fd,(%esp)
  800dae:	e8 dd 11 00 00       	call   801f90 <_panic>

	return ret;
}
  800db3:	89 d0                	mov    %edx,%eax
  800db5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbe:	89 ec                	mov    %ebp,%esp
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800de7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dea:	ba 01 00 00 00       	mov    $0x1,%edx
  800def:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df4:	e8 53 ff ff ff       	call   800d4c <syscall>
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e01:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e08:	00 
  800e09:	8b 45 14             	mov    0x14(%ebp),%eax
  800e0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e10:	8b 45 10             	mov    0x10(%ebp),%eax
  800e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	89 04 24             	mov    %eax,(%esp)
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	ba 00 00 00 00       	mov    $0x0,%edx
  800e25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2a:	e8 1d ff ff ff       	call   800d4c <syscall>
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e37:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e4e:	00 
  800e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e52:	89 04 24             	mov    %eax,(%esp)
  800e55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e58:	ba 01 00 00 00       	mov    $0x1,%edx
  800e5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e62:	e8 e5 fe ff ff       	call   800d4c <syscall>
}
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    

00800e69 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e6f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e76:	00 
  800e77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e86:	00 
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	89 04 24             	mov    %eax,(%esp)
  800e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e90:	ba 01 00 00 00       	mov    $0x1,%edx
  800e95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e9a:	e8 ad fe ff ff       	call   800d4c <syscall>
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ea7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eae:	00 
  800eaf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ebe:	00 
  800ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec2:	89 04 24             	mov    %eax,(%esp)
  800ec5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec8:	ba 01 00 00 00       	mov    $0x1,%edx
  800ecd:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed2:	e8 75 fe ff ff       	call   800d4c <syscall>
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800edf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef6:	00 
  800ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efa:	89 04 24             	mov    %eax,(%esp)
  800efd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f00:	ba 01 00 00 00       	mov    $0x1,%edx
  800f05:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0a:	e8 3d fe ff ff       	call   800d4c <syscall>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1e:	00 
  800f1f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f22:	0b 45 14             	or     0x14(%ebp),%eax
  800f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f29:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	ba 01 00 00 00       	mov    $0x1,%edx
  800f3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f43:	e8 04 fe ff ff       	call   800d4c <syscall>
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f50:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f57:	00 
  800f58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f5f:	00 
  800f60:	8b 45 10             	mov    0x10(%ebp),%eax
  800f63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6a:	89 04 24             	mov    %eax,(%esp)
  800f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f70:	ba 01 00 00 00       	mov    $0x1,%edx
  800f75:	b8 05 00 00 00       	mov    $0x5,%eax
  800f7a:	e8 cd fd ff ff       	call   800d4c <syscall>
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f96:	00 
  800f97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f9e:	00 
  800f9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb5:	e8 92 fd ff ff       	call   800d4c <syscall>
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800fc2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc9:	00 
  800fca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd9:	00 
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe8:	b8 04 00 00 00       	mov    $0x4,%eax
  800fed:	e8 5a fd ff ff       	call   800d4c <syscall>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ffa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	ba 00 00 00 00       	mov    $0x0,%edx
  801023:	b8 02 00 00 00       	mov    $0x2,%eax
  801028:	e8 1f fd ff ff       	call   800d4c <syscall>
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801035:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80103c:	00 
  80103d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801044:	00 
  801045:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80104c:	00 
  80104d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801054:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801057:	ba 01 00 00 00       	mov    $0x1,%edx
  80105c:	b8 03 00 00 00       	mov    $0x3,%eax
  801061:	e8 e6 fc ff ff       	call   800d4c <syscall>
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80106e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801075:	00 
  801076:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107d:	00 
  80107e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801085:	00 
  801086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801092:	ba 00 00 00 00       	mov    $0x0,%edx
  801097:	b8 01 00 00 00       	mov    $0x1,%eax
  80109c:	e8 ab fc ff ff       	call   800d4c <syscall>
}
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010b0:	00 
  8010b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b8:	00 
  8010b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010c0:	00 
  8010c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c4:	89 04 24             	mov    %eax,(%esp)
  8010c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d4:	e8 73 fc ff ff       	call   800d4c <syscall>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    
	...

008010dc <sfork>:
}

// Challenge!
int
sfork(void)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010e2:	c7 44 24 08 0b 27 80 	movl   $0x80270b,0x8(%esp)
  8010e9:	00 
  8010ea:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8010f1:	00 
  8010f2:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  8010f9:	e8 92 0e 00 00       	call   801f90 <_panic>

008010fe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	57                   	push   %edi
  801102:	56                   	push   %esi
  801103:	53                   	push   %ebx
  801104:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  801107:	c7 04 24 c2 13 80 00 	movl   $0x8013c2,(%esp)
  80110e:	e8 d5 0e 00 00       	call   801fe8 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801113:	ba 08 00 00 00       	mov    $0x8,%edx
  801118:	89 d0                	mov    %edx,%eax
  80111a:	51                   	push   %ecx
  80111b:	52                   	push   %edx
  80111c:	53                   	push   %ebx
  80111d:	55                   	push   %ebp
  80111e:	56                   	push   %esi
  80111f:	57                   	push   %edi
  801120:	89 e5                	mov    %esp,%ebp
  801122:	8d 35 2a 11 80 00    	lea    0x80112a,%esi
  801128:	0f 34                	sysenter 

0080112a <.after_sysenter_label>:
  80112a:	5f                   	pop    %edi
  80112b:	5e                   	pop    %esi
  80112c:	5d                   	pop    %ebp
  80112d:	5b                   	pop    %ebx
  80112e:	5a                   	pop    %edx
  80112f:	59                   	pop    %ecx
  801130:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801133:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801137:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  80113e:	00 
  80113f:	c7 44 24 04 21 27 80 	movl   $0x802721,0x4(%esp)
  801146:	00 
  801147:	c7 04 24 7c 27 80 00 	movl   $0x80277c,(%esp)
  80114e:	e8 c6 f0 ff ff       	call   800219 <cprintf>
	if (envidnum < 0)
  801153:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801157:	79 23                	jns    80117c <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  801159:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80115c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801160:	c7 44 24 08 2c 27 80 	movl   $0x80272c,0x8(%esp)
  801167:	00 
  801168:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80116f:	00 
  801170:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801177:	e8 14 0e 00 00       	call   801f90 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  80117c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801181:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801186:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80118b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80118f:	75 1c                	jne    8011ad <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801191:	e8 5e fe ff ff       	call   800ff4 <sys_getenvid>
  801196:	25 ff 03 00 00       	and    $0x3ff,%eax
  80119b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80119e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a3:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8011a8:	e9 0a 02 00 00       	jmp    8013b7 <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8011ad:	89 d8                	mov    %ebx,%eax
  8011af:	c1 e8 16             	shr    $0x16,%eax
  8011b2:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8011b5:	a8 01                	test   $0x1,%al
  8011b7:	0f 84 43 01 00 00    	je     801300 <.after_sysenter_label+0x1d6>
  8011bd:	89 d8                	mov    %ebx,%eax
  8011bf:	c1 e8 0c             	shr    $0xc,%eax
  8011c2:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8011c5:	f6 c2 01             	test   $0x1,%dl
  8011c8:	0f 84 32 01 00 00    	je     801300 <.after_sysenter_label+0x1d6>
  8011ce:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8011d1:	f6 c2 04             	test   $0x4,%dl
  8011d4:	0f 84 26 01 00 00    	je     801300 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  8011da:	c1 e0 0c             	shl    $0xc,%eax
  8011dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  8011e0:	c1 e8 0c             	shr    $0xc,%eax
  8011e3:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  8011e6:	89 c2                	mov    %eax,%edx
  8011e8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  8011ee:	a9 02 08 00 00       	test   $0x802,%eax
  8011f3:	0f 84 a0 00 00 00    	je     801299 <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  8011f9:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  8011fc:	80 ce 08             	or     $0x8,%dh
  8011ff:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801202:	89 54 24 10          	mov    %edx,0x10(%esp)
  801206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801210:	89 44 24 08          	mov    %eax,0x8(%esp)
  801214:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801217:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801222:	e8 ea fc ff ff       	call   800f11 <sys_page_map>
  801227:	85 c0                	test   %eax,%eax
  801229:	79 20                	jns    80124b <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80122b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122f:	c7 44 24 08 a4 27 80 	movl   $0x8027a4,0x8(%esp)
  801236:	00 
  801237:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  80123e:	00 
  80123f:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801246:	e8 45 0d 00 00       	call   801f90 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80124b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80124e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801252:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801255:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801259:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801260:	00 
  801261:	89 44 24 04          	mov    %eax,0x4(%esp)
  801265:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80126c:	e8 a0 fc ff ff       	call   800f11 <sys_page_map>
  801271:	85 c0                	test   %eax,%eax
  801273:	0f 89 87 00 00 00    	jns    801300 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  801279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127d:	c7 44 24 08 d0 27 80 	movl   $0x8027d0,0x8(%esp)
  801284:	00 
  801285:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  80128c:	00 
  80128d:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801294:	e8 f7 0c 00 00       	call   801f90 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  801299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80129c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a7:	c7 04 24 3c 27 80 00 	movl   $0x80273c,(%esp)
  8012ae:	e8 66 ef ff ff       	call   800219 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  8012b3:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012ba:	00 
  8012bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d7:	e8 35 fc ff ff       	call   800f11 <sys_page_map>
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	79 20                	jns    801300 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  8012e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e4:	c7 44 24 08 fc 27 80 	movl   $0x8027fc,0x8(%esp)
  8012eb:	00 
  8012ec:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012f3:	00 
  8012f4:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  8012fb:	e8 90 0c 00 00       	call   801f90 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801300:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801306:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80130c:	0f 85 9b fe ff ff    	jne    8011ad <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801312:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801319:	00 
  80131a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801321:	ee 
  801322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	e8 1d fc ff ff       	call   800f4a <sys_page_alloc>
  80132d:	85 c0                	test   %eax,%eax
  80132f:	79 20                	jns    801351 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801331:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801335:	c7 44 24 08 28 28 80 	movl   $0x802828,0x8(%esp)
  80133c:	00 
  80133d:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801344:	00 
  801345:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  80134c:	e8 3f 0c 00 00       	call   801f90 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801351:	c7 44 24 04 58 20 80 	movl   $0x802058,0x4(%esp)
  801358:	00 
  801359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135c:	89 04 24             	mov    %eax,(%esp)
  80135f:	e8 cd fa ff ff       	call   800e31 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801364:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80136b:	00 
  80136c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80136f:	89 04 24             	mov    %eax,(%esp)
  801372:	e8 2a fb ff ff       	call   800ea1 <sys_env_set_status>
  801377:	85 c0                	test   %eax,%eax
  801379:	79 20                	jns    80139b <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80137b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80137f:	c7 44 24 08 4c 28 80 	movl   $0x80284c,0x8(%esp)
  801386:	00 
  801387:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80138e:	00 
  80138f:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801396:	e8 f5 0b 00 00       	call   801f90 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80139b:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  8013a2:	00 
  8013a3:	c7 44 24 04 21 27 80 	movl   $0x802721,0x4(%esp)
  8013aa:	00 
  8013ab:	c7 04 24 4e 27 80 00 	movl   $0x80274e,(%esp)
  8013b2:	e8 62 ee ff ff       	call   800219 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  8013b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ba:	83 c4 3c             	add    $0x3c,%esp
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5f                   	pop    %edi
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 2c             	sub    $0x2c,%esp
  8013cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  8013ce:	8b 33                	mov    (%ebx),%esi
	uint32_t err = utf->utf_err;
  8013d0:	8b 7b 04             	mov    0x4(%ebx),%edi
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
  8013d3:	8b 43 2c             	mov    0x2c(%ebx),%eax
  8013d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013da:	c7 04 24 74 28 80 00 	movl   $0x802874,(%esp)
  8013e1:	e8 33 ee ff ff       	call   800219 <cprintf>
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  8013e6:	f7 c7 02 00 00 00    	test   $0x2,%edi
  8013ec:	75 2b                	jne    801419 <pgfault+0x57>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  8013ee:	8b 43 28             	mov    0x28(%ebx),%eax
  8013f1:	89 44 24 14          	mov    %eax,0x14(%esp)
  8013f5:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013f9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013fd:	c7 44 24 08 94 28 80 	movl   $0x802894,0x8(%esp)
  801404:	00 
  801405:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80140c:	00 
  80140d:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801414:	e8 77 0b 00 00       	call   801f90 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801419:	89 f0                	mov    %esi,%eax
  80141b:	c1 e8 16             	shr    $0x16,%eax
  80141e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801425:	a8 01                	test   $0x1,%al
  801427:	74 11                	je     80143a <pgfault+0x78>
  801429:	89 f0                	mov    %esi,%eax
  80142b:	c1 e8 0c             	shr    $0xc,%eax
  80142e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801435:	f6 c4 08             	test   $0x8,%ah
  801438:	75 1c                	jne    801456 <pgfault+0x94>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  80143a:	c7 44 24 08 d0 28 80 	movl   $0x8028d0,0x8(%esp)
  801441:	00 
  801442:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801449:	00 
  80144a:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801451:	e8 3a 0b 00 00       	call   801f90 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801456:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80145d:	00 
  80145e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801465:	00 
  801466:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146d:	e8 d8 fa ff ff       	call   800f4a <sys_page_alloc>
  801472:	85 c0                	test   %eax,%eax
  801474:	79 20                	jns    801496 <pgfault+0xd4>
		panic ("pgfault: page allocation failed : %e", r);
  801476:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80147a:	c7 44 24 08 0c 29 80 	movl   $0x80290c,0x8(%esp)
  801481:	00 
  801482:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801489:	00 
  80148a:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801491:	e8 fa 0a 00 00       	call   801f90 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801496:	89 f3                	mov    %esi,%ebx
  801498:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  80149e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014a5:	00 
  8014a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014aa:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8014b1:	e8 8f f6 ff ff       	call   800b45 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  8014b6:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8014bd:	00 
  8014be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014c9:	00 
  8014ca:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014d1:	00 
  8014d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014d9:	e8 33 fa ff ff       	call   800f11 <sys_page_map>
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	79 20                	jns    801502 <pgfault+0x140>
		panic ("pgfault: page mapping failed : %e", r);
  8014e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e6:	c7 44 24 08 34 29 80 	movl   $0x802934,0x8(%esp)
  8014ed:	00 
  8014ee:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8014f5:	00 
  8014f6:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  8014fd:	e8 8e 0a 00 00       	call   801f90 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  801502:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801509:	00 
  80150a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801511:	e8 c3 f9 ff ff       	call   800ed9 <sys_page_unmap>
  801516:	85 c0                	test   %eax,%eax
  801518:	79 20                	jns    80153a <pgfault+0x178>
		panic("pgfault: page unmapping failed : %e", r);
  80151a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80151e:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  801525:	00 
  801526:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80152d:	00 
  80152e:	c7 04 24 21 27 80 00 	movl   $0x802721,(%esp)
  801535:	e8 56 0a 00 00       	call   801f90 <_panic>
	cprintf("pgfault: finish\n");
  80153a:	c7 04 24 68 27 80 00 	movl   $0x802768,(%esp)
  801541:	e8 d3 ec ff ff       	call   800219 <cprintf>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801546:	83 c4 2c             	add    $0x2c,%esp
  801549:	5b                   	pop    %ebx
  80154a:	5e                   	pop    %esi
  80154b:	5f                   	pop    %edi
  80154c:	5d                   	pop    %ebp
  80154d:	c3                   	ret    
	...

00801550 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801556:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80155c:	b8 01 00 00 00       	mov    $0x1,%eax
  801561:	39 ca                	cmp    %ecx,%edx
  801563:	75 04                	jne    801569 <ipc_find_env+0x19>
  801565:	b0 00                	mov    $0x0,%al
  801567:	eb 0f                	jmp    801578 <ipc_find_env+0x28>
  801569:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80156c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801572:	8b 12                	mov    (%edx),%edx
  801574:	39 ca                	cmp    %ecx,%edx
  801576:	75 0c                	jne    801584 <ipc_find_env+0x34>
			return envs[i].env_id;
  801578:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80157b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801580:	8b 00                	mov    (%eax),%eax
  801582:	eb 0e                	jmp    801592 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801584:	83 c0 01             	add    $0x1,%eax
  801587:	3d 00 04 00 00       	cmp    $0x400,%eax
  80158c:	75 db                	jne    801569 <ipc_find_env+0x19>
  80158e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	57                   	push   %edi
  801598:	56                   	push   %esi
  801599:	53                   	push   %ebx
  80159a:	83 ec 1c             	sub    $0x1c,%esp
  80159d:	8b 75 08             	mov    0x8(%ebp),%esi
  8015a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8015a6:	85 db                	test   %ebx,%ebx
  8015a8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8015ad:	0f 44 d8             	cmove  %eax,%ebx
  8015b0:	eb 29                	jmp    8015db <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	79 25                	jns    8015db <ipc_send+0x47>
  8015b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8015b9:	74 20                	je     8015db <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  8015bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015bf:	c7 44 24 08 7c 29 80 	movl   $0x80297c,0x8(%esp)
  8015c6:	00 
  8015c7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8015ce:	00 
  8015cf:	c7 04 24 9a 29 80 00 	movl   $0x80299a,(%esp)
  8015d6:	e8 b5 09 00 00       	call   801f90 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8015db:	8b 45 14             	mov    0x14(%ebp),%eax
  8015de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015ea:	89 34 24             	mov    %esi,(%esp)
  8015ed:	e8 09 f8 ff ff       	call   800dfb <sys_ipc_try_send>
  8015f2:	85 c0                	test   %eax,%eax
  8015f4:	75 bc                	jne    8015b2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8015f6:	e8 86 f9 ff ff       	call   800f81 <sys_yield>
}
  8015fb:	83 c4 1c             	add    $0x1c,%esp
  8015fe:	5b                   	pop    %ebx
  8015ff:	5e                   	pop    %esi
  801600:	5f                   	pop    %edi
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    

00801603 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	83 ec 28             	sub    $0x28,%esp
  801609:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80160c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80160f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801612:	8b 75 08             	mov    0x8(%ebp),%esi
  801615:	8b 45 0c             	mov    0xc(%ebp),%eax
  801618:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80161b:	85 c0                	test   %eax,%eax
  80161d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801622:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801625:	89 04 24             	mov    %eax,(%esp)
  801628:	e8 95 f7 ff ff       	call   800dc2 <sys_ipc_recv>
  80162d:	89 c3                	mov    %eax,%ebx
  80162f:	85 c0                	test   %eax,%eax
  801631:	79 2a                	jns    80165d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801633:	89 44 24 08          	mov    %eax,0x8(%esp)
  801637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163b:	c7 04 24 a4 29 80 00 	movl   $0x8029a4,(%esp)
  801642:	e8 d2 eb ff ff       	call   800219 <cprintf>
		if(from_env_store != NULL)
  801647:	85 f6                	test   %esi,%esi
  801649:	74 06                	je     801651 <ipc_recv+0x4e>
			*from_env_store = 0;
  80164b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801651:	85 ff                	test   %edi,%edi
  801653:	74 2d                	je     801682 <ipc_recv+0x7f>
			*perm_store = 0;
  801655:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80165b:	eb 25                	jmp    801682 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  80165d:	85 f6                	test   %esi,%esi
  80165f:	90                   	nop
  801660:	74 0a                	je     80166c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801662:	a1 08 40 80 00       	mov    0x804008,%eax
  801667:	8b 40 74             	mov    0x74(%eax),%eax
  80166a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80166c:	85 ff                	test   %edi,%edi
  80166e:	74 0a                	je     80167a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801670:	a1 08 40 80 00       	mov    0x804008,%eax
  801675:	8b 40 78             	mov    0x78(%eax),%eax
  801678:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80167a:	a1 08 40 80 00       	mov    0x804008,%eax
  80167f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801682:	89 d8                	mov    %ebx,%eax
  801684:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801687:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80168a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80168d:	89 ec                	mov    %ebp,%esp
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    
	...

008016a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016ab:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	89 04 24             	mov    %eax,(%esp)
  8016bc:	e8 df ff ff ff       	call   8016a0 <fd2num>
  8016c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	57                   	push   %edi
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016d4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016d9:	a8 01                	test   $0x1,%al
  8016db:	74 36                	je     801713 <fd_alloc+0x48>
  8016dd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016e2:	a8 01                	test   $0x1,%al
  8016e4:	74 2d                	je     801713 <fd_alloc+0x48>
  8016e6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016eb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016f0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	c1 ea 16             	shr    $0x16,%edx
  8016fc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016ff:	f6 c2 01             	test   $0x1,%dl
  801702:	74 14                	je     801718 <fd_alloc+0x4d>
  801704:	89 c2                	mov    %eax,%edx
  801706:	c1 ea 0c             	shr    $0xc,%edx
  801709:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80170c:	f6 c2 01             	test   $0x1,%dl
  80170f:	75 10                	jne    801721 <fd_alloc+0x56>
  801711:	eb 05                	jmp    801718 <fd_alloc+0x4d>
  801713:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801718:	89 1f                	mov    %ebx,(%edi)
  80171a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80171f:	eb 17                	jmp    801738 <fd_alloc+0x6d>
  801721:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801726:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80172b:	75 c8                	jne    8016f5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80172d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801733:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5f                   	pop    %edi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801740:	8b 45 08             	mov    0x8(%ebp),%eax
  801743:	83 f8 1f             	cmp    $0x1f,%eax
  801746:	77 36                	ja     80177e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801748:	05 00 00 0d 00       	add    $0xd0000,%eax
  80174d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801750:	89 c2                	mov    %eax,%edx
  801752:	c1 ea 16             	shr    $0x16,%edx
  801755:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80175c:	f6 c2 01             	test   $0x1,%dl
  80175f:	74 1d                	je     80177e <fd_lookup+0x41>
  801761:	89 c2                	mov    %eax,%edx
  801763:	c1 ea 0c             	shr    $0xc,%edx
  801766:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176d:	f6 c2 01             	test   $0x1,%dl
  801770:	74 0c                	je     80177e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801772:	8b 55 0c             	mov    0xc(%ebp),%edx
  801775:	89 02                	mov    %eax,(%edx)
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80177c:	eb 05                	jmp    801783 <fd_lookup+0x46>
  80177e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80178b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80178e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 a0 ff ff ff       	call   80173d <fd_lookup>
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 0e                	js     8017af <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a7:	89 50 04             	mov    %edx,0x4(%eax)
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 10             	sub    $0x10,%esp
  8017b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8017c4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8017c9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8017cf:	75 11                	jne    8017e2 <dev_lookup+0x31>
  8017d1:	eb 04                	jmp    8017d7 <dev_lookup+0x26>
  8017d3:	39 08                	cmp    %ecx,(%eax)
  8017d5:	75 10                	jne    8017e7 <dev_lookup+0x36>
			*dev = devtab[i];
  8017d7:	89 03                	mov    %eax,(%ebx)
  8017d9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017de:	66 90                	xchg   %ax,%ax
  8017e0:	eb 36                	jmp    801818 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017e2:	be 34 2a 80 00       	mov    $0x802a34,%esi
  8017e7:	83 c2 01             	add    $0x1,%edx
  8017ea:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	75 e2                	jne    8017d3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8017f6:	8b 40 48             	mov    0x48(%eax),%eax
  8017f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  801808:	e8 0c ea ff ff       	call   800219 <cprintf>
	*dev = 0;
  80180d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801813:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 24             	sub    $0x24,%esp
  801826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801829:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	89 04 24             	mov    %eax,(%esp)
  801836:	e8 02 ff ff ff       	call   80173d <fd_lookup>
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 53                	js     801892 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801849:	8b 00                	mov    (%eax),%eax
  80184b:	89 04 24             	mov    %eax,(%esp)
  80184e:	e8 5e ff ff ff       	call   8017b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801853:	85 c0                	test   %eax,%eax
  801855:	78 3b                	js     801892 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801857:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80185c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801863:	74 2d                	je     801892 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801865:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801868:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80186f:	00 00 00 
	stat->st_isdir = 0;
  801872:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801879:	00 00 00 
	stat->st_dev = dev;
  80187c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801885:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801889:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80188c:	89 14 24             	mov    %edx,(%esp)
  80188f:	ff 50 14             	call   *0x14(%eax)
}
  801892:	83 c4 24             	add    $0x24,%esp
  801895:	5b                   	pop    %ebx
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 24             	sub    $0x24,%esp
  80189f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a9:	89 1c 24             	mov    %ebx,(%esp)
  8018ac:	e8 8c fe ff ff       	call   80173d <fd_lookup>
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 5f                	js     801914 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bf:	8b 00                	mov    (%eax),%eax
  8018c1:	89 04 24             	mov    %eax,(%esp)
  8018c4:	e8 e8 fe ff ff       	call   8017b1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 47                	js     801914 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018d0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018d4:	75 23                	jne    8018f9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018db:	8b 40 48             	mov    0x48(%eax),%eax
  8018de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  8018ed:	e8 27 e9 ff ff       	call   800219 <cprintf>
  8018f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018f7:	eb 1b                	jmp    801914 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fc:	8b 48 18             	mov    0x18(%eax),%ecx
  8018ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801904:	85 c9                	test   %ecx,%ecx
  801906:	74 0c                	je     801914 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190f:	89 14 24             	mov    %edx,(%esp)
  801912:	ff d1                	call   *%ecx
}
  801914:	83 c4 24             	add    $0x24,%esp
  801917:	5b                   	pop    %ebx
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	53                   	push   %ebx
  80191e:	83 ec 24             	sub    $0x24,%esp
  801921:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801924:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	89 1c 24             	mov    %ebx,(%esp)
  80192e:	e8 0a fe ff ff       	call   80173d <fd_lookup>
  801933:	85 c0                	test   %eax,%eax
  801935:	78 66                	js     80199d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801937:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801941:	8b 00                	mov    (%eax),%eax
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 66 fe ff ff       	call   8017b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 4e                	js     80199d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80194f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801952:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801956:	75 23                	jne    80197b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801958:	a1 08 40 80 00       	mov    0x804008,%eax
  80195d:	8b 40 48             	mov    0x48(%eax),%eax
  801960:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801964:	89 44 24 04          	mov    %eax,0x4(%esp)
  801968:	c7 04 24 f9 29 80 00 	movl   $0x8029f9,(%esp)
  80196f:	e8 a5 e8 ff ff       	call   800219 <cprintf>
  801974:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801979:	eb 22                	jmp    80199d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801981:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801986:	85 c9                	test   %ecx,%ecx
  801988:	74 13                	je     80199d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80198a:	8b 45 10             	mov    0x10(%ebp),%eax
  80198d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801991:	8b 45 0c             	mov    0xc(%ebp),%eax
  801994:	89 44 24 04          	mov    %eax,0x4(%esp)
  801998:	89 14 24             	mov    %edx,(%esp)
  80199b:	ff d1                	call   *%ecx
}
  80199d:	83 c4 24             	add    $0x24,%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	53                   	push   %ebx
  8019a7:	83 ec 24             	sub    $0x24,%esp
  8019aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b4:	89 1c 24             	mov    %ebx,(%esp)
  8019b7:	e8 81 fd ff ff       	call   80173d <fd_lookup>
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 6b                	js     801a2b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ca:	8b 00                	mov    (%eax),%eax
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	e8 dd fd ff ff       	call   8017b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 53                	js     801a2b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019db:	8b 42 08             	mov    0x8(%edx),%eax
  8019de:	83 e0 03             	and    $0x3,%eax
  8019e1:	83 f8 01             	cmp    $0x1,%eax
  8019e4:	75 23                	jne    801a09 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019e6:	a1 08 40 80 00       	mov    0x804008,%eax
  8019eb:	8b 40 48             	mov    0x48(%eax),%eax
  8019ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	c7 04 24 16 2a 80 00 	movl   $0x802a16,(%esp)
  8019fd:	e8 17 e8 ff ff       	call   800219 <cprintf>
  801a02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a07:	eb 22                	jmp    801a2b <read+0x88>
	}
	if (!dev->dev_read)
  801a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0c:	8b 48 08             	mov    0x8(%eax),%ecx
  801a0f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a14:	85 c9                	test   %ecx,%ecx
  801a16:	74 13                	je     801a2b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a18:	8b 45 10             	mov    0x10(%ebp),%eax
  801a1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a26:	89 14 24             	mov    %edx,(%esp)
  801a29:	ff d1                	call   *%ecx
}
  801a2b:	83 c4 24             	add    $0x24,%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	57                   	push   %edi
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	83 ec 1c             	sub    $0x1c,%esp
  801a3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a3d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a40:	ba 00 00 00 00       	mov    $0x0,%edx
  801a45:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4f:	85 f6                	test   %esi,%esi
  801a51:	74 29                	je     801a7c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a53:	89 f0                	mov    %esi,%eax
  801a55:	29 d0                	sub    %edx,%eax
  801a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5b:	03 55 0c             	add    0xc(%ebp),%edx
  801a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a62:	89 3c 24             	mov    %edi,(%esp)
  801a65:	e8 39 ff ff ff       	call   8019a3 <read>
		if (m < 0)
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 0e                	js     801a7c <readn+0x4b>
			return m;
		if (m == 0)
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	74 08                	je     801a7a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a72:	01 c3                	add    %eax,%ebx
  801a74:	89 da                	mov    %ebx,%edx
  801a76:	39 f3                	cmp    %esi,%ebx
  801a78:	72 d9                	jb     801a53 <readn+0x22>
  801a7a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a7c:	83 c4 1c             	add    $0x1c,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 28             	sub    $0x28,%esp
  801a8a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a8d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a90:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a93:	89 34 24             	mov    %esi,(%esp)
  801a96:	e8 05 fc ff ff       	call   8016a0 <fd2num>
  801a9b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	e8 93 fc ff ff       	call   80173d <fd_lookup>
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 05                	js     801ab5 <fd_close+0x31>
  801ab0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ab3:	74 0e                	je     801ac3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  801abe:	0f 44 d8             	cmove  %eax,%ebx
  801ac1:	eb 3d                	jmp    801b00 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ac3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aca:	8b 06                	mov    (%esi),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 dd fc ff ff       	call   8017b1 <dev_lookup>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 16                	js     801af0 <fd_close+0x6c>
		if (dev->dev_close)
  801ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801add:	8b 40 10             	mov    0x10(%eax),%eax
  801ae0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	74 07                	je     801af0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801ae9:	89 34 24             	mov    %esi,(%esp)
  801aec:	ff d0                	call   *%eax
  801aee:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801af0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801af4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afb:	e8 d9 f3 ff ff       	call   800ed9 <sys_page_unmap>
	return r;
}
  801b00:	89 d8                	mov    %ebx,%eax
  801b02:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b05:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b08:	89 ec                	mov    %ebp,%esp
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 19 fc ff ff       	call   80173d <fd_lookup>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 13                	js     801b3b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b28:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b2f:	00 
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 49 ff ff ff       	call   801a84 <fd_close>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 18             	sub    $0x18,%esp
  801b43:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b46:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b49:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b50:	00 
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	e8 78 03 00 00       	call   801ed4 <open>
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 1b                	js     801b7d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b69:	89 1c 24             	mov    %ebx,(%esp)
  801b6c:	e8 ae fc ff ff       	call   80181f <fstat>
  801b71:	89 c6                	mov    %eax,%esi
	close(fd);
  801b73:	89 1c 24             	mov    %ebx,(%esp)
  801b76:	e8 91 ff ff ff       	call   801b0c <close>
  801b7b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b7d:	89 d8                	mov    %ebx,%eax
  801b7f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b82:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b85:	89 ec                	mov    %ebp,%esp
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 14             	sub    $0x14,%esp
  801b90:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b95:	89 1c 24             	mov    %ebx,(%esp)
  801b98:	e8 6f ff ff ff       	call   801b0c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b9d:	83 c3 01             	add    $0x1,%ebx
  801ba0:	83 fb 20             	cmp    $0x20,%ebx
  801ba3:	75 f0                	jne    801b95 <close_all+0xc>
		close(i);
}
  801ba5:	83 c4 14             	add    $0x14,%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 58             	sub    $0x58,%esp
  801bb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801bba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bbd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	89 04 24             	mov    %eax,(%esp)
  801bca:	e8 6e fb ff ff       	call   80173d <fd_lookup>
  801bcf:	89 c3                	mov    %eax,%ebx
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 e0 00 00 00    	js     801cb9 <dup+0x10e>
		return r;
	close(newfdnum);
  801bd9:	89 3c 24             	mov    %edi,(%esp)
  801bdc:	e8 2b ff ff ff       	call   801b0c <close>

	newfd = INDEX2FD(newfdnum);
  801be1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801be7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 bb fa ff ff       	call   8016b0 <fd2data>
  801bf5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bf7:	89 34 24             	mov    %esi,(%esp)
  801bfa:	e8 b1 fa ff ff       	call   8016b0 <fd2data>
  801bff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801c02:	89 da                	mov    %ebx,%edx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	c1 e8 16             	shr    $0x16,%eax
  801c09:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c10:	a8 01                	test   $0x1,%al
  801c12:	74 43                	je     801c57 <dup+0xac>
  801c14:	c1 ea 0c             	shr    $0xc,%edx
  801c17:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c1e:	a8 01                	test   $0x1,%al
  801c20:	74 35                	je     801c57 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c22:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c29:	25 07 0e 00 00       	and    $0xe07,%eax
  801c2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c40:	00 
  801c41:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4c:	e8 c0 f2 ff ff       	call   800f11 <sys_page_map>
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 3f                	js     801c96 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	c1 ea 0c             	shr    $0xc,%edx
  801c5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c66:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c6c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c70:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c7b:	00 
  801c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c87:	e8 85 f2 ff ff       	call   800f11 <sys_page_map>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 04                	js     801c96 <dup+0xeb>
  801c92:	89 fb                	mov    %edi,%ebx
  801c94:	eb 23                	jmp    801cb9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca1:	e8 33 f2 ff ff       	call   800ed9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ca6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb4:	e8 20 f2 ff ff       	call   800ed9 <sys_page_unmap>
	return r;
}
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cc4:	89 ec                	mov    %ebp,%esp
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    

00801cc8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 18             	sub    $0x18,%esp
  801cce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cd1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cd8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801cdf:	75 11                	jne    801cf2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ce1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ce8:	e8 63 f8 ff ff       	call   801550 <ipc_find_env>
  801ced:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cf2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cf9:	00 
  801cfa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d01:	00 
  801d02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d06:	a1 00 40 80 00       	mov    0x804000,%eax
  801d0b:	89 04 24             	mov    %eax,(%esp)
  801d0e:	e8 81 f8 ff ff       	call   801594 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d1a:	00 
  801d1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d26:	e8 d8 f8 ff ff       	call   801603 <ipc_recv>
}
  801d2b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d2e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d31:	89 ec                	mov    %ebp,%esp
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d49:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d53:	b8 02 00 00 00       	mov    $0x2,%eax
  801d58:	e8 6b ff ff ff       	call   801cc8 <fsipc>
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	8b 40 0c             	mov    0xc(%eax),%eax
  801d6b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d70:	ba 00 00 00 00       	mov    $0x0,%edx
  801d75:	b8 06 00 00 00       	mov    $0x6,%eax
  801d7a:	e8 49 ff ff ff       	call   801cc8 <fsipc>
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d87:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8c:	b8 08 00 00 00       	mov    $0x8,%eax
  801d91:	e8 32 ff ff ff       	call   801cc8 <fsipc>
}
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	53                   	push   %ebx
  801d9c:	83 ec 14             	sub    $0x14,%esp
  801d9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	8b 40 0c             	mov    0xc(%eax),%eax
  801da8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801dad:	ba 00 00 00 00       	mov    $0x0,%edx
  801db2:	b8 05 00 00 00       	mov    $0x5,%eax
  801db7:	e8 0c ff ff ff       	call   801cc8 <fsipc>
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 2b                	js     801deb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801dc0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dc7:	00 
  801dc8:	89 1c 24             	mov    %ebx,(%esp)
  801dcb:	e8 8a eb ff ff       	call   80095a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801dd0:	a1 80 50 80 00       	mov    0x805080,%eax
  801dd5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ddb:	a1 84 50 80 00       	mov    0x805084,%eax
  801de0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801deb:	83 c4 14             	add    $0x14,%esp
  801dee:	5b                   	pop    %ebx
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 18             	sub    $0x18,%esp
  801df7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  801dfd:	8b 52 0c             	mov    0xc(%edx),%edx
  801e00:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801e06:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801e0b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e10:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e15:	0f 47 c2             	cmova  %edx,%eax
  801e18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e23:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801e2a:	e8 16 ed ff ff       	call   800b45 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e34:	b8 04 00 00 00       	mov    $0x4,%eax
  801e39:	e8 8a fe ff ff       	call   801cc8 <fsipc>
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	53                   	push   %ebx
  801e44:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e4d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801e52:	8b 45 10             	mov    0x10(%ebp),%eax
  801e55:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5f:	b8 03 00 00 00       	mov    $0x3,%eax
  801e64:	e8 5f fe ff ff       	call   801cc8 <fsipc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 17                	js     801e86 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e73:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e7a:	00 
  801e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7e:	89 04 24             	mov    %eax,(%esp)
  801e81:	e8 bf ec ff ff       	call   800b45 <memmove>
  return r;	
}
  801e86:	89 d8                	mov    %ebx,%eax
  801e88:	83 c4 14             	add    $0x14,%esp
  801e8b:	5b                   	pop    %ebx
  801e8c:	5d                   	pop    %ebp
  801e8d:	c3                   	ret    

00801e8e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	53                   	push   %ebx
  801e92:	83 ec 14             	sub    $0x14,%esp
  801e95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e98:	89 1c 24             	mov    %ebx,(%esp)
  801e9b:	e8 70 ea ff ff       	call   800910 <strlen>
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801ea7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ead:	7f 1f                	jg     801ece <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801eaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801eba:	e8 9b ea ff ff       	call   80095a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801ebf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec4:	b8 07 00 00 00       	mov    $0x7,%eax
  801ec9:	e8 fa fd ff ff       	call   801cc8 <fsipc>
}
  801ece:	83 c4 14             	add    $0x14,%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 28             	sub    $0x28,%esp
  801eda:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801edd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ee0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801ee3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 dd f7 ff ff       	call   8016cb <fd_alloc>
  801eee:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	0f 88 89 00 00 00    	js     801f81 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801ef8:	89 34 24             	mov    %esi,(%esp)
  801efb:	e8 10 ea ff ff       	call   800910 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801f00:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801f05:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f0a:	7f 75                	jg     801f81 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801f0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f10:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f17:	e8 3e ea ff ff       	call   80095a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801f24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f27:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2c:	e8 97 fd ff ff       	call   801cc8 <fsipc>
  801f31:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 0f                	js     801f46 <open+0x72>
  return fd2num(fd);
  801f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3a:	89 04 24             	mov    %eax,(%esp)
  801f3d:	e8 5e f7 ff ff       	call   8016a0 <fd2num>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	eb 3b                	jmp    801f81 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801f46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f4d:	00 
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 2b fb ff ff       	call   801a84 <fd_close>
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	74 24                	je     801f81 <open+0xad>
  801f5d:	c7 44 24 0c 3c 2a 80 	movl   $0x802a3c,0xc(%esp)
  801f64:	00 
  801f65:	c7 44 24 08 51 2a 80 	movl   $0x802a51,0x8(%esp)
  801f6c:	00 
  801f6d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801f74:	00 
  801f75:	c7 04 24 66 2a 80 00 	movl   $0x802a66,(%esp)
  801f7c:	e8 0f 00 00 00       	call   801f90 <_panic>
  return r;
}
  801f81:	89 d8                	mov    %ebx,%eax
  801f83:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f86:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f89:	89 ec                	mov    %ebp,%esp
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	00 00                	add    %al,(%eax)
	...

00801f90 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801f98:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f9b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801fa1:	e8 4e f0 ff ff       	call   800ff4 <sys_getenvid>
  801fa6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fa9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801fad:	8b 55 08             	mov    0x8(%ebp),%edx
  801fb0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801fb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbc:	c7 04 24 74 2a 80 00 	movl   $0x802a74,(%esp)
  801fc3:	e8 51 e2 ff ff       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801fc8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fcc:	8b 45 10             	mov    0x10(%ebp),%eax
  801fcf:	89 04 24             	mov    %eax,(%esp)
  801fd2:	e8 e1 e1 ff ff       	call   8001b8 <vcprintf>
	cprintf("\n");
  801fd7:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801fde:	e8 36 e2 ff ff       	call   800219 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fe3:	cc                   	int3   
  801fe4:	eb fd                	jmp    801fe3 <_panic+0x53>
	...

00801fe8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fee:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ff5:	75 54                	jne    80204b <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801ff7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ffe:	00 
  801fff:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802006:	ee 
  802007:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80200e:	e8 37 ef ff ff       	call   800f4a <sys_page_alloc>
  802013:	85 c0                	test   %eax,%eax
  802015:	79 20                	jns    802037 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  802017:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80201b:	c7 44 24 08 98 2a 80 	movl   $0x802a98,0x8(%esp)
  802022:	00 
  802023:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80202a:	00 
  80202b:	c7 04 24 b0 2a 80 00 	movl   $0x802ab0,(%esp)
  802032:	e8 59 ff ff ff       	call   801f90 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  802037:	c7 44 24 04 58 20 80 	movl   $0x802058,0x4(%esp)
  80203e:	00 
  80203f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802046:	e8 e6 ed ff ff       	call   800e31 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802053:	c9                   	leave  
  802054:	c3                   	ret    
  802055:	00 00                	add    %al,(%eax)
	...

00802058 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802058:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802059:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  80205e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802060:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  802063:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802067:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80206a:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  80206e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802072:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802074:	83 c4 08             	add    $0x8,%esp
	popal
  802077:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  802078:	83 c4 04             	add    $0x4,%esp
	popfl
  80207b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  80207c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80207d:	c3                   	ret    
	...

00802080 <__udivdi3>:
  802080:	55                   	push   %ebp
  802081:	89 e5                	mov    %esp,%ebp
  802083:	57                   	push   %edi
  802084:	56                   	push   %esi
  802085:	83 ec 10             	sub    $0x10,%esp
  802088:	8b 45 14             	mov    0x14(%ebp),%eax
  80208b:	8b 55 08             	mov    0x8(%ebp),%edx
  80208e:	8b 75 10             	mov    0x10(%ebp),%esi
  802091:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802094:	85 c0                	test   %eax,%eax
  802096:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802099:	75 35                	jne    8020d0 <__udivdi3+0x50>
  80209b:	39 fe                	cmp    %edi,%esi
  80209d:	77 61                	ja     802100 <__udivdi3+0x80>
  80209f:	85 f6                	test   %esi,%esi
  8020a1:	75 0b                	jne    8020ae <__udivdi3+0x2e>
  8020a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	f7 f6                	div    %esi
  8020ac:	89 c6                	mov    %eax,%esi
  8020ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8020b1:	31 d2                	xor    %edx,%edx
  8020b3:	89 f8                	mov    %edi,%eax
  8020b5:	f7 f6                	div    %esi
  8020b7:	89 c7                	mov    %eax,%edi
  8020b9:	89 c8                	mov    %ecx,%eax
  8020bb:	f7 f6                	div    %esi
  8020bd:	89 c1                	mov    %eax,%ecx
  8020bf:	89 fa                	mov    %edi,%edx
  8020c1:	89 c8                	mov    %ecx,%eax
  8020c3:	83 c4 10             	add    $0x10,%esp
  8020c6:	5e                   	pop    %esi
  8020c7:	5f                   	pop    %edi
  8020c8:	5d                   	pop    %ebp
  8020c9:	c3                   	ret    
  8020ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d0:	39 f8                	cmp    %edi,%eax
  8020d2:	77 1c                	ja     8020f0 <__udivdi3+0x70>
  8020d4:	0f bd d0             	bsr    %eax,%edx
  8020d7:	83 f2 1f             	xor    $0x1f,%edx
  8020da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020dd:	75 39                	jne    802118 <__udivdi3+0x98>
  8020df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020e2:	0f 86 a0 00 00 00    	jbe    802188 <__udivdi3+0x108>
  8020e8:	39 f8                	cmp    %edi,%eax
  8020ea:	0f 82 98 00 00 00    	jb     802188 <__udivdi3+0x108>
  8020f0:	31 ff                	xor    %edi,%edi
  8020f2:	31 c9                	xor    %ecx,%ecx
  8020f4:	89 c8                	mov    %ecx,%eax
  8020f6:	89 fa                	mov    %edi,%edx
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    
  8020ff:	90                   	nop
  802100:	89 d1                	mov    %edx,%ecx
  802102:	89 fa                	mov    %edi,%edx
  802104:	89 c8                	mov    %ecx,%eax
  802106:	31 ff                	xor    %edi,%edi
  802108:	f7 f6                	div    %esi
  80210a:	89 c1                	mov    %eax,%ecx
  80210c:	89 fa                	mov    %edi,%edx
  80210e:	89 c8                	mov    %ecx,%eax
  802110:	83 c4 10             	add    $0x10,%esp
  802113:	5e                   	pop    %esi
  802114:	5f                   	pop    %edi
  802115:	5d                   	pop    %ebp
  802116:	c3                   	ret    
  802117:	90                   	nop
  802118:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80211c:	89 f2                	mov    %esi,%edx
  80211e:	d3 e0                	shl    %cl,%eax
  802120:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802123:	b8 20 00 00 00       	mov    $0x20,%eax
  802128:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80212b:	89 c1                	mov    %eax,%ecx
  80212d:	d3 ea                	shr    %cl,%edx
  80212f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802133:	0b 55 ec             	or     -0x14(%ebp),%edx
  802136:	d3 e6                	shl    %cl,%esi
  802138:	89 c1                	mov    %eax,%ecx
  80213a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80213d:	89 fe                	mov    %edi,%esi
  80213f:	d3 ee                	shr    %cl,%esi
  802141:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802145:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80214b:	d3 e7                	shl    %cl,%edi
  80214d:	89 c1                	mov    %eax,%ecx
  80214f:	d3 ea                	shr    %cl,%edx
  802151:	09 d7                	or     %edx,%edi
  802153:	89 f2                	mov    %esi,%edx
  802155:	89 f8                	mov    %edi,%eax
  802157:	f7 75 ec             	divl   -0x14(%ebp)
  80215a:	89 d6                	mov    %edx,%esi
  80215c:	89 c7                	mov    %eax,%edi
  80215e:	f7 65 e8             	mull   -0x18(%ebp)
  802161:	39 d6                	cmp    %edx,%esi
  802163:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802166:	72 30                	jb     802198 <__udivdi3+0x118>
  802168:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80216b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	39 c2                	cmp    %eax,%edx
  802173:	73 05                	jae    80217a <__udivdi3+0xfa>
  802175:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802178:	74 1e                	je     802198 <__udivdi3+0x118>
  80217a:	89 f9                	mov    %edi,%ecx
  80217c:	31 ff                	xor    %edi,%edi
  80217e:	e9 71 ff ff ff       	jmp    8020f4 <__udivdi3+0x74>
  802183:	90                   	nop
  802184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802188:	31 ff                	xor    %edi,%edi
  80218a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80218f:	e9 60 ff ff ff       	jmp    8020f4 <__udivdi3+0x74>
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80219b:	31 ff                	xor    %edi,%edi
  80219d:	89 c8                	mov    %ecx,%eax
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	5e                   	pop    %esi
  8021a5:	5f                   	pop    %edi
  8021a6:	5d                   	pop    %ebp
  8021a7:	c3                   	ret    
	...

008021b0 <__umoddi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	57                   	push   %edi
  8021b4:	56                   	push   %esi
  8021b5:	83 ec 20             	sub    $0x20,%esp
  8021b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021c4:	85 d2                	test   %edx,%edx
  8021c6:	89 c8                	mov    %ecx,%eax
  8021c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021cb:	75 13                	jne    8021e0 <__umoddi3+0x30>
  8021cd:	39 f7                	cmp    %esi,%edi
  8021cf:	76 3f                	jbe    802210 <__umoddi3+0x60>
  8021d1:	89 f2                	mov    %esi,%edx
  8021d3:	f7 f7                	div    %edi
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	31 d2                	xor    %edx,%edx
  8021d9:	83 c4 20             	add    $0x20,%esp
  8021dc:	5e                   	pop    %esi
  8021dd:	5f                   	pop    %edi
  8021de:	5d                   	pop    %ebp
  8021df:	c3                   	ret    
  8021e0:	39 f2                	cmp    %esi,%edx
  8021e2:	77 4c                	ja     802230 <__umoddi3+0x80>
  8021e4:	0f bd ca             	bsr    %edx,%ecx
  8021e7:	83 f1 1f             	xor    $0x1f,%ecx
  8021ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021ed:	75 51                	jne    802240 <__umoddi3+0x90>
  8021ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021f2:	0f 87 e0 00 00 00    	ja     8022d8 <__umoddi3+0x128>
  8021f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fb:	29 f8                	sub    %edi,%eax
  8021fd:	19 d6                	sbb    %edx,%esi
  8021ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802202:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802205:	89 f2                	mov    %esi,%edx
  802207:	83 c4 20             	add    $0x20,%esp
  80220a:	5e                   	pop    %esi
  80220b:	5f                   	pop    %edi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    
  80220e:	66 90                	xchg   %ax,%ax
  802210:	85 ff                	test   %edi,%edi
  802212:	75 0b                	jne    80221f <__umoddi3+0x6f>
  802214:	b8 01 00 00 00       	mov    $0x1,%eax
  802219:	31 d2                	xor    %edx,%edx
  80221b:	f7 f7                	div    %edi
  80221d:	89 c7                	mov    %eax,%edi
  80221f:	89 f0                	mov    %esi,%eax
  802221:	31 d2                	xor    %edx,%edx
  802223:	f7 f7                	div    %edi
  802225:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802228:	f7 f7                	div    %edi
  80222a:	eb a9                	jmp    8021d5 <__umoddi3+0x25>
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 20             	add    $0x20,%esp
  802237:	5e                   	pop    %esi
  802238:	5f                   	pop    %edi
  802239:	5d                   	pop    %ebp
  80223a:	c3                   	ret    
  80223b:	90                   	nop
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802244:	d3 e2                	shl    %cl,%edx
  802246:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802249:	ba 20 00 00 00       	mov    $0x20,%edx
  80224e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802251:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802254:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802258:	89 fa                	mov    %edi,%edx
  80225a:	d3 ea                	shr    %cl,%edx
  80225c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802260:	0b 55 f4             	or     -0xc(%ebp),%edx
  802263:	d3 e7                	shl    %cl,%edi
  802265:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802269:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80226c:	89 f2                	mov    %esi,%edx
  80226e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802271:	89 c7                	mov    %eax,%edi
  802273:	d3 ea                	shr    %cl,%edx
  802275:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802279:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80227c:	89 c2                	mov    %eax,%edx
  80227e:	d3 e6                	shl    %cl,%esi
  802280:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802284:	d3 ea                	shr    %cl,%edx
  802286:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80228a:	09 d6                	or     %edx,%esi
  80228c:	89 f0                	mov    %esi,%eax
  80228e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802291:	d3 e7                	shl    %cl,%edi
  802293:	89 f2                	mov    %esi,%edx
  802295:	f7 75 f4             	divl   -0xc(%ebp)
  802298:	89 d6                	mov    %edx,%esi
  80229a:	f7 65 e8             	mull   -0x18(%ebp)
  80229d:	39 d6                	cmp    %edx,%esi
  80229f:	72 2b                	jb     8022cc <__umoddi3+0x11c>
  8022a1:	39 c7                	cmp    %eax,%edi
  8022a3:	72 23                	jb     8022c8 <__umoddi3+0x118>
  8022a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022a9:	29 c7                	sub    %eax,%edi
  8022ab:	19 d6                	sbb    %edx,%esi
  8022ad:	89 f0                	mov    %esi,%eax
  8022af:	89 f2                	mov    %esi,%edx
  8022b1:	d3 ef                	shr    %cl,%edi
  8022b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022bd:	09 f8                	or     %edi,%eax
  8022bf:	d3 ea                	shr    %cl,%edx
  8022c1:	83 c4 20             	add    $0x20,%esp
  8022c4:	5e                   	pop    %esi
  8022c5:	5f                   	pop    %edi
  8022c6:	5d                   	pop    %ebp
  8022c7:	c3                   	ret    
  8022c8:	39 d6                	cmp    %edx,%esi
  8022ca:	75 d9                	jne    8022a5 <__umoddi3+0xf5>
  8022cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022d2:	eb d1                	jmp    8022a5 <__umoddi3+0xf5>
  8022d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	0f 82 18 ff ff ff    	jb     8021f8 <__umoddi3+0x48>
  8022e0:	e9 1d ff ff ff       	jmp    802202 <__umoddi3+0x52>
