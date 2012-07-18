
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003d:	e8 6c 10 00 00       	call   8010ae <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 54 0f 00 00       	call   800fa4 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 a0 22 80 00 	movl   $0x8022a0,(%esp)
  80005f:	e8 61 01 00 00       	call   8001c5 <cprintf>
		ipc_send(who, 0, 0, 0);
  800064:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006b:	00 
  80006c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800073:	00 
  800074:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007b:	00 
  80007c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007f:	89 04 24             	mov    %eax,(%esp)
  800082:	e8 bd 14 00 00       	call   801544 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 11 15 00 00       	call   8015b3 <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 f8 0e 00 00       	call   800fa4 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 b6 22 80 00 	movl   $0x8022b6,(%esp)
  8000bf:	e8 01 01 00 00       	call   8001c5 <cprintf>
		if (i == 10)
  8000c4:	83 fb 0a             	cmp    $0xa,%ebx
  8000c7:	74 27                	je     8000f0 <umain+0xbc>
			return;
		i++;
  8000c9:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e3:	89 04 24             	mov    %eax,(%esp)
  8000e6:	e8 59 14 00 00       	call   801544 <ipc_send>
		if (i == 10)
  8000eb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ee:	75 9a                	jne    80008a <umain+0x56>
			return;
	}

}
  8000f0:	83 c4 2c             	add    $0x2c,%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80010a:	e8 95 0e 00 00       	call   800fa4 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014e:	e8 e6 19 00 00       	call   801b39 <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 80 0e 00 00       	call   800fdf <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	00 00                	add    %al,(%eax)
	...

00800164 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	8b 45 0c             	mov    0xc(%ebp),%eax
  800184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 df 01 80 00 	movl   $0x8001df,(%esp)
  8001a0:	e8 d8 01 00 00       	call   80037d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 96 0e 00 00       	call   801053 <sys_cputs>

	return b.cnt;
}
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 87 ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 14             	sub    $0x14,%esp
  8001e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e9:	8b 03                	mov    (%ebx),%eax
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f2:	83 c0 01             	add    $0x1,%eax
  8001f5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fc:	75 19                	jne    800217 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800205:	00 
  800206:	8d 43 08             	lea    0x8(%ebx),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	e8 42 0e 00 00       	call   801053 <sys_cputs>
		b->idx = 0;
  800211:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800217:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021b:	83 c4 14             	add    $0x14,%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    
	...

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 4c             	sub    $0x4c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800250:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800256:	b9 00 00 00 00       	mov    $0x0,%ecx
  80025b:	39 d1                	cmp    %edx,%ecx
  80025d:	72 15                	jb     800274 <printnum+0x44>
  80025f:	77 07                	ja     800268 <printnum+0x38>
  800261:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800264:	39 d0                	cmp    %edx,%eax
  800266:	76 0c                	jbe    800274 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	85 db                	test   %ebx,%ebx
  80026d:	8d 76 00             	lea    0x0(%esi),%esi
  800270:	7f 61                	jg     8002d3 <printnum+0xa3>
  800272:	eb 70                	jmp    8002e4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800274:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800287:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80028b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80028e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800291:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800294:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ad:	e8 7e 1d 00 00       	call   802030 <__udivdi3>
  8002b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c7:	89 f2                	mov    %esi,%edx
  8002c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cc:	e8 5f ff ff ff       	call   800230 <printnum>
  8002d1:	eb 11                	jmp    8002e4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d7:	89 3c 24             	mov    %edi,(%esp)
  8002da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	85 db                	test   %ebx,%ebx
  8002e2:	7f ef                	jg     8002d3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fa:	00 
  8002fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002fe:	89 14 24             	mov    %edx,(%esp)
  800301:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800304:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800308:	e8 53 1e 00 00       	call   802160 <__umoddi3>
  80030d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800311:	0f be 80 d3 22 80 00 	movsbl 0x8022d3(%eax),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031e:	83 c4 4c             	add    $0x4c,%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800329:	83 fa 01             	cmp    $0x1,%edx
  80032c:	7e 0e                	jle    80033c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	eb 22                	jmp    80035e <getuint+0x38>
	else if (lflag)
  80033c:	85 d2                	test   %edx,%edx
  80033e:	74 10                	je     800350 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 0e                	jmp    80035e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800366:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	3b 50 04             	cmp    0x4(%eax),%edx
  80036f:	73 0a                	jae    80037b <sprintputch+0x1b>
		*b->buf++ = ch;
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	88 0a                	mov    %cl,(%edx)
  800376:	83 c2 01             	add    $0x1,%edx
  800379:	89 10                	mov    %edx,(%eax)
}
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
  800383:	83 ec 5c             	sub    $0x5c,%esp
  800386:	8b 7d 08             	mov    0x8(%ebp),%edi
  800389:	8b 75 0c             	mov    0xc(%ebp),%esi
  80038c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80038f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800396:	eb 11                	jmp    8003a9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800398:	85 c0                	test   %eax,%eax
  80039a:	0f 84 68 04 00 00    	je     800808 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8003a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a9:	0f b6 03             	movzbl (%ebx),%eax
  8003ac:	83 c3 01             	add    $0x1,%ebx
  8003af:	83 f8 25             	cmp    $0x25,%eax
  8003b2:	75 e4                	jne    800398 <vprintfmt+0x1b>
  8003b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003bb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8003cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003d2:	eb 06                	jmp    8003da <vprintfmt+0x5d>
  8003d4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8003d8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	0f b6 13             	movzbl (%ebx),%edx
  8003dd:	0f b6 c2             	movzbl %dl,%eax
  8003e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e6:	83 ea 23             	sub    $0x23,%edx
  8003e9:	80 fa 55             	cmp    $0x55,%dl
  8003ec:	0f 87 f9 03 00 00    	ja     8007eb <vprintfmt+0x46e>
  8003f2:	0f b6 d2             	movzbl %dl,%edx
  8003f5:	ff 24 95 c0 24 80 00 	jmp    *0x8024c0(,%edx,4)
  8003fc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800400:	eb d6                	jmp    8003d8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800402:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800405:	83 ea 30             	sub    $0x30,%edx
  800408:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80040b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80040e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800411:	83 fb 09             	cmp    $0x9,%ebx
  800414:	77 54                	ja     80046a <vprintfmt+0xed>
  800416:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800419:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80041f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800422:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800426:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800429:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80042c:	83 fb 09             	cmp    $0x9,%ebx
  80042f:	76 eb                	jbe    80041c <vprintfmt+0x9f>
  800431:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800434:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800437:	eb 31                	jmp    80046a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800439:	8b 55 14             	mov    0x14(%ebp),%edx
  80043c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80043f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800442:	8b 12                	mov    (%edx),%edx
  800444:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800447:	eb 21                	jmp    80046a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800449:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
  800452:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800456:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800459:	e9 7a ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>
  80045e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800465:	e9 6e ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80046a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046e:	0f 89 64 ff ff ff    	jns    8003d8 <vprintfmt+0x5b>
  800474:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800477:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80047a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80047d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800480:	e9 53 ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800485:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800488:	e9 4b ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>
  80048d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	89 74 24 04          	mov    %esi,0x4(%esp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	ff d7                	call   *%edi
  8004a4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004a7:	e9 fd fe ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  8004ac:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	89 c2                	mov    %eax,%edx
  8004bc:	c1 fa 1f             	sar    $0x1f,%edx
  8004bf:	31 d0                	xor    %edx,%eax
  8004c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c3:	83 f8 0f             	cmp    $0xf,%eax
  8004c6:	7f 0b                	jg     8004d3 <vprintfmt+0x156>
  8004c8:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8004cf:	85 d2                	test   %edx,%edx
  8004d1:	75 20                	jne    8004f3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8004d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d7:	c7 44 24 08 e4 22 80 	movl   $0x8022e4,0x8(%esp)
  8004de:	00 
  8004df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e3:	89 3c 24             	mov    %edi,(%esp)
  8004e6:	e8 a5 03 00 00       	call   800890 <printfmt>
  8004eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ee:	e9 b6 fe ff ff       	jmp    8003a9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f7:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  8004fe:	00 
  8004ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800503:	89 3c 24             	mov    %edi,(%esp)
  800506:	e8 85 03 00 00       	call   800890 <printfmt>
  80050b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80050e:	e9 96 fe ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  800513:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800516:	89 c3                	mov    %eax,%ebx
  800518:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80051e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052f:	85 c0                	test   %eax,%eax
  800531:	b8 ed 22 80 00       	mov    $0x8022ed,%eax
  800536:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80053a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80053d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800541:	7e 06                	jle    800549 <vprintfmt+0x1cc>
  800543:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800547:	75 13                	jne    80055c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054c:	0f be 02             	movsbl (%edx),%eax
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 85 a2 00 00 00    	jne    8005f9 <vprintfmt+0x27c>
  800557:	e9 8f 00 00 00       	jmp    8005eb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800560:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800563:	89 0c 24             	mov    %ecx,(%esp)
  800566:	e8 70 03 00 00       	call   8008db <strnlen>
  80056b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800573:	85 d2                	test   %edx,%edx
  800575:	7e d2                	jle    800549 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800577:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80057b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80057e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800581:	89 d3                	mov    %edx,%ebx
  800583:	89 74 24 04          	mov    %esi,0x4(%esp)
  800587:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058a:	89 04 24             	mov    %eax,(%esp)
  80058d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	85 db                	test   %ebx,%ebx
  800594:	7f ed                	jg     800583 <vprintfmt+0x206>
  800596:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800599:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005a0:	eb a7                	jmp    800549 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005a6:	74 1b                	je     8005c3 <vprintfmt+0x246>
  8005a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ab:	83 fa 5e             	cmp    $0x5e,%edx
  8005ae:	76 13                	jbe    8005c3 <vprintfmt+0x246>
					putch('?', putdat);
  8005b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005be:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c1:	eb 0d                	jmp    8005d0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ca:	89 04 24             	mov    %eax,(%esp)
  8005cd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d0:	83 ef 01             	sub    $0x1,%edi
  8005d3:	0f be 03             	movsbl (%ebx),%eax
  8005d6:	85 c0                	test   %eax,%eax
  8005d8:	74 05                	je     8005df <vprintfmt+0x262>
  8005da:	83 c3 01             	add    $0x1,%ebx
  8005dd:	eb 31                	jmp    800610 <vprintfmt+0x293>
  8005df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ef:	7f 36                	jg     800627 <vprintfmt+0x2aa>
  8005f1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f4:	e9 b0 fd ff ff       	jmp    8003a9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fc:	83 c2 01             	add    $0x1,%edx
  8005ff:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800602:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800605:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800608:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80060b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80060e:	89 d3                	mov    %edx,%ebx
  800610:	85 f6                	test   %esi,%esi
  800612:	78 8e                	js     8005a2 <vprintfmt+0x225>
  800614:	83 ee 01             	sub    $0x1,%esi
  800617:	79 89                	jns    8005a2 <vprintfmt+0x225>
  800619:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80061c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800622:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800625:	eb c4                	jmp    8005eb <vprintfmt+0x26e>
  800627:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80062a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80062d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800631:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800638:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063a:	83 eb 01             	sub    $0x1,%ebx
  80063d:	85 db                	test   %ebx,%ebx
  80063f:	7f ec                	jg     80062d <vprintfmt+0x2b0>
  800641:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800644:	e9 60 fd ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  800649:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80064c:	83 f9 01             	cmp    $0x1,%ecx
  80064f:	7e 16                	jle    800667 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 50 08             	lea    0x8(%eax),%edx
  800657:	89 55 14             	mov    %edx,0x14(%ebp)
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	8b 48 04             	mov    0x4(%eax),%ecx
  80065f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800662:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800665:	eb 32                	jmp    800699 <vprintfmt+0x31c>
	else if (lflag)
  800667:	85 c9                	test   %ecx,%ecx
  800669:	74 18                	je     800683 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8d 50 04             	lea    0x4(%eax),%edx
  800671:	89 55 14             	mov    %edx,0x14(%ebp)
  800674:	8b 00                	mov    (%eax),%eax
  800676:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800679:	89 c1                	mov    %eax,%ecx
  80067b:	c1 f9 1f             	sar    $0x1f,%ecx
  80067e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800681:	eb 16                	jmp    800699 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800691:	89 c2                	mov    %eax,%edx
  800693:	c1 fa 1f             	sar    $0x1f,%edx
  800696:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800699:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80069c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80069f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8006a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a8:	0f 89 8a 00 00 00    	jns    800738 <vprintfmt+0x3bb>
				putch('-', putdat);
  8006ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006b9:	ff d7                	call   *%edi
				num = -(long long) num;
  8006bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006be:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006c1:	f7 d8                	neg    %eax
  8006c3:	83 d2 00             	adc    $0x0,%edx
  8006c6:	f7 da                	neg    %edx
  8006c8:	eb 6e                	jmp    800738 <vprintfmt+0x3bb>
  8006ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006cd:	89 ca                	mov    %ecx,%edx
  8006cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d2:	e8 4f fc ff ff       	call   800326 <getuint>
  8006d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8006dc:	eb 5a                	jmp    800738 <vprintfmt+0x3bb>
  8006de:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006e1:	89 ca                	mov    %ecx,%edx
  8006e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e6:	e8 3b fc ff ff       	call   800326 <getuint>
  8006eb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8006f0:	eb 46                	jmp    800738 <vprintfmt+0x3bb>
  8006f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8006f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800700:	ff d7                	call   *%edi
			putch('x', putdat);
  800702:	89 74 24 04          	mov    %esi,0x4(%esp)
  800706:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80070d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	ba 00 00 00 00       	mov    $0x0,%edx
  80071f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800724:	eb 12                	jmp    800738 <vprintfmt+0x3bb>
  800726:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800729:	89 ca                	mov    %ecx,%edx
  80072b:	8d 45 14             	lea    0x14(%ebp),%eax
  80072e:	e8 f3 fb ff ff       	call   800326 <getuint>
  800733:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800738:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80073c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800740:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800743:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800747:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80074b:	89 04 24             	mov    %eax,(%esp)
  80074e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800752:	89 f2                	mov    %esi,%edx
  800754:	89 f8                	mov    %edi,%eax
  800756:	e8 d5 fa ff ff       	call   800230 <printnum>
  80075b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80075e:	e9 46 fc ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  800763:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8d 50 04             	lea    0x4(%eax),%edx
  80076c:	89 55 14             	mov    %edx,0x14(%ebp)
  80076f:	8b 00                	mov    (%eax),%eax
  800771:	85 c0                	test   %eax,%eax
  800773:	75 24                	jne    800799 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800775:	c7 44 24 0c 08 24 80 	movl   $0x802408,0xc(%esp)
  80077c:	00 
  80077d:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  800784:	00 
  800785:	89 74 24 04          	mov    %esi,0x4(%esp)
  800789:	89 3c 24             	mov    %edi,(%esp)
  80078c:	e8 ff 00 00 00       	call   800890 <printfmt>
  800791:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800794:	e9 10 fc ff ff       	jmp    8003a9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800799:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80079c:	7e 29                	jle    8007c7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80079e:	0f b6 16             	movzbl (%esi),%edx
  8007a1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8007a3:	c7 44 24 0c 40 24 80 	movl   $0x802440,0xc(%esp)
  8007aa:	00 
  8007ab:	c7 44 24 08 e3 29 80 	movl   $0x8029e3,0x8(%esp)
  8007b2:	00 
  8007b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b7:	89 3c 24             	mov    %edi,(%esp)
  8007ba:	e8 d1 00 00 00       	call   800890 <printfmt>
  8007bf:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007c2:	e9 e2 fb ff ff       	jmp    8003a9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8007c7:	0f b6 16             	movzbl (%esi),%edx
  8007ca:	88 10                	mov    %dl,(%eax)
  8007cc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8007cf:	e9 d5 fb ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  8007d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007de:	89 14 24             	mov    %edx,(%esp)
  8007e1:	ff d7                	call   *%edi
  8007e3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007e6:	e9 be fb ff ff       	jmp    8003a9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007fb:	80 38 25             	cmpb   $0x25,(%eax)
  8007fe:	0f 84 a5 fb ff ff    	je     8003a9 <vprintfmt+0x2c>
  800804:	89 c3                	mov    %eax,%ebx
  800806:	eb f0                	jmp    8007f8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800808:	83 c4 5c             	add    $0x5c,%esp
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5f                   	pop    %edi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	83 ec 28             	sub    $0x28,%esp
  800816:	8b 45 08             	mov    0x8(%ebp),%eax
  800819:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80081c:	85 c0                	test   %eax,%eax
  80081e:	74 04                	je     800824 <vsnprintf+0x14>
  800820:	85 d2                	test   %edx,%edx
  800822:	7f 07                	jg     80082b <vsnprintf+0x1b>
  800824:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800829:	eb 3b                	jmp    800866 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800832:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800835:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800843:	8b 45 10             	mov    0x10(%ebp),%eax
  800846:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	c7 04 24 60 03 80 00 	movl   $0x800360,(%esp)
  800858:	e8 20 fb ff ff       	call   80037d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800860:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800863:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800866:	c9                   	leave  
  800867:	c3                   	ret    

00800868 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80086e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800871:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800875:	8b 45 10             	mov    0x10(%ebp),%eax
  800878:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 82 ff ff ff       	call   800810 <vsnprintf>
	va_end(ap);

	return rc;
}
  80088e:	c9                   	leave  
  80088f:	c3                   	ret    

00800890 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800899:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089d:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	89 04 24             	mov    %eax,(%esp)
  8008b1:	e8 c7 fa ff ff       	call   80037d <vprintfmt>
	va_end(ap);
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    
	...

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ce:	74 09                	je     8008d9 <strlen+0x19>
		n++;
  8008d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d7:	75 f7                	jne    8008d0 <strlen+0x10>
		n++;
	return n;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 19                	je     800902 <strnlen+0x27>
  8008e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008ec:	74 14                	je     800902 <strnlen+0x27>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f6:	39 c8                	cmp    %ecx,%eax
  8008f8:	74 0d                	je     800907 <strnlen+0x2c>
  8008fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008fe:	75 f3                	jne    8008f3 <strnlen+0x18>
  800900:	eb 05                	jmp    800907 <strnlen+0x2c>
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800914:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800919:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80091d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	84 c9                	test   %cl,%cl
  800925:	75 f2                	jne    800919 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800934:	89 1c 24             	mov    %ebx,(%esp)
  800937:	e8 84 ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800943:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 bc ff ff ff       	call   80090a <strcpy>
	return dst;
}
  80094e:	89 d8                	mov    %ebx,%eax
  800950:	83 c4 08             	add    $0x8,%esp
  800953:	5b                   	pop    %ebx
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800961:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800964:	85 f6                	test   %esi,%esi
  800966:	74 18                	je     800980 <strncpy+0x2a>
  800968:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80096d:	0f b6 1a             	movzbl (%edx),%ebx
  800970:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800973:	80 3a 01             	cmpb   $0x1,(%edx)
  800976:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	83 c1 01             	add    $0x1,%ecx
  80097c:	39 ce                	cmp    %ecx,%esi
  80097e:	77 ed                	ja     80096d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 75 08             	mov    0x8(%ebp),%esi
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800992:	89 f0                	mov    %esi,%eax
  800994:	85 c9                	test   %ecx,%ecx
  800996:	74 27                	je     8009bf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800998:	83 e9 01             	sub    $0x1,%ecx
  80099b:	74 1d                	je     8009ba <strlcpy+0x36>
  80099d:	0f b6 1a             	movzbl (%edx),%ebx
  8009a0:	84 db                	test   %bl,%bl
  8009a2:	74 16                	je     8009ba <strlcpy+0x36>
			*dst++ = *src++;
  8009a4:	88 18                	mov    %bl,(%eax)
  8009a6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a9:	83 e9 01             	sub    $0x1,%ecx
  8009ac:	74 0e                	je     8009bc <strlcpy+0x38>
			*dst++ = *src++;
  8009ae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b1:	0f b6 1a             	movzbl (%edx),%ebx
  8009b4:	84 db                	test   %bl,%bl
  8009b6:	75 ec                	jne    8009a4 <strlcpy+0x20>
  8009b8:	eb 02                	jmp    8009bc <strlcpy+0x38>
  8009ba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009bc:	c6 00 00             	movb   $0x0,(%eax)
  8009bf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	84 c0                	test   %al,%al
  8009d3:	74 15                	je     8009ea <strcmp+0x25>
  8009d5:	3a 02                	cmp    (%edx),%al
  8009d7:	75 11                	jne    8009ea <strcmp+0x25>
		p++, q++;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009df:	0f b6 01             	movzbl (%ecx),%eax
  8009e2:	84 c0                	test   %al,%al
  8009e4:	74 04                	je     8009ea <strcmp+0x25>
  8009e6:	3a 02                	cmp    (%edx),%al
  8009e8:	74 ef                	je     8009d9 <strcmp+0x14>
  8009ea:	0f b6 c0             	movzbl %al,%eax
  8009ed:	0f b6 12             	movzbl (%edx),%edx
  8009f0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	53                   	push   %ebx
  8009f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a01:	85 c0                	test   %eax,%eax
  800a03:	74 23                	je     800a28 <strncmp+0x34>
  800a05:	0f b6 1a             	movzbl (%edx),%ebx
  800a08:	84 db                	test   %bl,%bl
  800a0a:	74 25                	je     800a31 <strncmp+0x3d>
  800a0c:	3a 19                	cmp    (%ecx),%bl
  800a0e:	75 21                	jne    800a31 <strncmp+0x3d>
  800a10:	83 e8 01             	sub    $0x1,%eax
  800a13:	74 13                	je     800a28 <strncmp+0x34>
		n--, p++, q++;
  800a15:	83 c2 01             	add    $0x1,%edx
  800a18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1b:	0f b6 1a             	movzbl (%edx),%ebx
  800a1e:	84 db                	test   %bl,%bl
  800a20:	74 0f                	je     800a31 <strncmp+0x3d>
  800a22:	3a 19                	cmp    (%ecx),%bl
  800a24:	74 ea                	je     800a10 <strncmp+0x1c>
  800a26:	eb 09                	jmp    800a31 <strncmp+0x3d>
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5d                   	pop    %ebp
  800a2f:	90                   	nop
  800a30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a31:	0f b6 02             	movzbl (%edx),%eax
  800a34:	0f b6 11             	movzbl (%ecx),%edx
  800a37:	29 d0                	sub    %edx,%eax
  800a39:	eb f2                	jmp    800a2d <strncmp+0x39>

00800a3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	74 18                	je     800a64 <strchr+0x29>
		if (*s == c)
  800a4c:	38 ca                	cmp    %cl,%dl
  800a4e:	75 0a                	jne    800a5a <strchr+0x1f>
  800a50:	eb 17                	jmp    800a69 <strchr+0x2e>
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a58:	74 0f                	je     800a69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 ee                	jne    800a52 <strchr+0x17>
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	74 18                	je     800a94 <strfind+0x29>
		if (*s == c)
  800a7c:	38 ca                	cmp    %cl,%dl
  800a7e:	75 0a                	jne    800a8a <strfind+0x1f>
  800a80:	eb 12                	jmp    800a94 <strfind+0x29>
  800a82:	38 ca                	cmp    %cl,%dl
  800a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a88:	74 0a                	je     800a94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 ee                	jne    800a82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	83 ec 0c             	sub    $0xc,%esp
  800a9c:	89 1c 24             	mov    %ebx,(%esp)
  800a9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800aa7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab0:	85 c9                	test   %ecx,%ecx
  800ab2:	74 30                	je     800ae4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aba:	75 25                	jne    800ae1 <memset+0x4b>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	75 20                	jne    800ae1 <memset+0x4b>
		c &= 0xFF;
  800ac1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	c1 e3 08             	shl    $0x8,%ebx
  800ac9:	89 d6                	mov    %edx,%esi
  800acb:	c1 e6 18             	shl    $0x18,%esi
  800ace:	89 d0                	mov    %edx,%eax
  800ad0:	c1 e0 10             	shl    $0x10,%eax
  800ad3:	09 f0                	or     %esi,%eax
  800ad5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ad7:	09 d8                	or     %ebx,%eax
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
  800adc:	fc                   	cld    
  800add:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800adf:	eb 03                	jmp    800ae4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae1:	fc                   	cld    
  800ae2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae4:	89 f8                	mov    %edi,%eax
  800ae6:	8b 1c 24             	mov    (%esp),%ebx
  800ae9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800aed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800af1:	89 ec                	mov    %ebp,%esp
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	89 34 24             	mov    %esi,(%esp)
  800afe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b0d:	39 c6                	cmp    %eax,%esi
  800b0f:	73 35                	jae    800b46 <memmove+0x51>
  800b11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	73 2e                	jae    800b46 <memmove+0x51>
		s += n;
		d += n;
  800b18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1a:	f6 c2 03             	test   $0x3,%dl
  800b1d:	75 1b                	jne    800b3a <memmove+0x45>
  800b1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b25:	75 13                	jne    800b3a <memmove+0x45>
  800b27:	f6 c1 03             	test   $0x3,%cl
  800b2a:	75 0e                	jne    800b3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b2c:	83 ef 04             	sub    $0x4,%edi
  800b2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b32:	c1 e9 02             	shr    $0x2,%ecx
  800b35:	fd                   	std    
  800b36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b38:	eb 09                	jmp    800b43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3a:	83 ef 01             	sub    $0x1,%edi
  800b3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b40:	fd                   	std    
  800b41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b44:	eb 20                	jmp    800b66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4c:	75 15                	jne    800b63 <memmove+0x6e>
  800b4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b54:	75 0d                	jne    800b63 <memmove+0x6e>
  800b56:	f6 c1 03             	test   $0x3,%cl
  800b59:	75 08                	jne    800b63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b5b:	c1 e9 02             	shr    $0x2,%ecx
  800b5e:	fc                   	cld    
  800b5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b61:	eb 03                	jmp    800b66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b63:	fc                   	cld    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b66:	8b 34 24             	mov    (%esp),%esi
  800b69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b6d:	89 ec                	mov    %ebp,%esp
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b77:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	e8 65 ff ff ff       	call   800af5 <memmove>
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	8b 75 08             	mov    0x8(%ebp),%esi
  800b9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba1:	85 c9                	test   %ecx,%ecx
  800ba3:	74 36                	je     800bdb <memcmp+0x49>
		if (*s1 != *s2)
  800ba5:	0f b6 06             	movzbl (%esi),%eax
  800ba8:	0f b6 1f             	movzbl (%edi),%ebx
  800bab:	38 d8                	cmp    %bl,%al
  800bad:	74 20                	je     800bcf <memcmp+0x3d>
  800baf:	eb 14                	jmp    800bc5 <memcmp+0x33>
  800bb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bbb:	83 c2 01             	add    $0x1,%edx
  800bbe:	83 e9 01             	sub    $0x1,%ecx
  800bc1:	38 d8                	cmp    %bl,%al
  800bc3:	74 12                	je     800bd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800bc5:	0f b6 c0             	movzbl %al,%eax
  800bc8:	0f b6 db             	movzbl %bl,%ebx
  800bcb:	29 d8                	sub    %ebx,%eax
  800bcd:	eb 11                	jmp    800be0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcf:	83 e9 01             	sub    $0x1,%ecx
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	85 c9                	test   %ecx,%ecx
  800bd9:	75 d6                	jne    800bb1 <memcmp+0x1f>
  800bdb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800beb:	89 c2                	mov    %eax,%edx
  800bed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf0:	39 d0                	cmp    %edx,%eax
  800bf2:	73 15                	jae    800c09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bf8:	38 08                	cmp    %cl,(%eax)
  800bfa:	75 06                	jne    800c02 <memfind+0x1d>
  800bfc:	eb 0b                	jmp    800c09 <memfind+0x24>
  800bfe:	38 08                	cmp    %cl,(%eax)
  800c00:	74 07                	je     800c09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c02:	83 c0 01             	add    $0x1,%eax
  800c05:	39 c2                	cmp    %eax,%edx
  800c07:	77 f5                	ja     800bfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 04             	sub    $0x4,%esp
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1a:	0f b6 02             	movzbl (%edx),%eax
  800c1d:	3c 20                	cmp    $0x20,%al
  800c1f:	74 04                	je     800c25 <strtol+0x1a>
  800c21:	3c 09                	cmp    $0x9,%al
  800c23:	75 0e                	jne    800c33 <strtol+0x28>
		s++;
  800c25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c28:	0f b6 02             	movzbl (%edx),%eax
  800c2b:	3c 20                	cmp    $0x20,%al
  800c2d:	74 f6                	je     800c25 <strtol+0x1a>
  800c2f:	3c 09                	cmp    $0x9,%al
  800c31:	74 f2                	je     800c25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c33:	3c 2b                	cmp    $0x2b,%al
  800c35:	75 0c                	jne    800c43 <strtol+0x38>
		s++;
  800c37:	83 c2 01             	add    $0x1,%edx
  800c3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c41:	eb 15                	jmp    800c58 <strtol+0x4d>
	else if (*s == '-')
  800c43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c4a:	3c 2d                	cmp    $0x2d,%al
  800c4c:	75 0a                	jne    800c58 <strtol+0x4d>
		s++, neg = 1;
  800c4e:	83 c2 01             	add    $0x1,%edx
  800c51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c58:	85 db                	test   %ebx,%ebx
  800c5a:	0f 94 c0             	sete   %al
  800c5d:	74 05                	je     800c64 <strtol+0x59>
  800c5f:	83 fb 10             	cmp    $0x10,%ebx
  800c62:	75 18                	jne    800c7c <strtol+0x71>
  800c64:	80 3a 30             	cmpb   $0x30,(%edx)
  800c67:	75 13                	jne    800c7c <strtol+0x71>
  800c69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c6d:	8d 76 00             	lea    0x0(%esi),%esi
  800c70:	75 0a                	jne    800c7c <strtol+0x71>
		s += 2, base = 16;
  800c72:	83 c2 02             	add    $0x2,%edx
  800c75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7a:	eb 15                	jmp    800c91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7c:	84 c0                	test   %al,%al
  800c7e:	66 90                	xchg   %ax,%ax
  800c80:	74 0f                	je     800c91 <strtol+0x86>
  800c82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c87:	80 3a 30             	cmpb   $0x30,(%edx)
  800c8a:	75 05                	jne    800c91 <strtol+0x86>
		s++, base = 8;
  800c8c:	83 c2 01             	add    $0x1,%edx
  800c8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c91:	b8 00 00 00 00       	mov    $0x0,%eax
  800c96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c98:	0f b6 0a             	movzbl (%edx),%ecx
  800c9b:	89 cf                	mov    %ecx,%edi
  800c9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ca0:	80 fb 09             	cmp    $0x9,%bl
  800ca3:	77 08                	ja     800cad <strtol+0xa2>
			dig = *s - '0';
  800ca5:	0f be c9             	movsbl %cl,%ecx
  800ca8:	83 e9 30             	sub    $0x30,%ecx
  800cab:	eb 1e                	jmp    800ccb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cb0:	80 fb 19             	cmp    $0x19,%bl
  800cb3:	77 08                	ja     800cbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cb5:	0f be c9             	movsbl %cl,%ecx
  800cb8:	83 e9 57             	sub    $0x57,%ecx
  800cbb:	eb 0e                	jmp    800ccb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800cc0:	80 fb 19             	cmp    $0x19,%bl
  800cc3:	77 15                	ja     800cda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800cc5:	0f be c9             	movsbl %cl,%ecx
  800cc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ccb:	39 f1                	cmp    %esi,%ecx
  800ccd:	7d 0b                	jge    800cda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ccf:	83 c2 01             	add    $0x1,%edx
  800cd2:	0f af c6             	imul   %esi,%eax
  800cd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cd8:	eb be                	jmp    800c98 <strtol+0x8d>
  800cda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce0:	74 05                	je     800ce7 <strtol+0xdc>
		*endptr = (char *) s;
  800ce2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ce5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ce7:	89 ca                	mov    %ecx,%edx
  800ce9:	f7 da                	neg    %edx
  800ceb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cef:	0f 45 c2             	cmovne %edx,%eax
}
  800cf2:	83 c4 04             	add    $0x4,%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    
	...

00800cfc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	83 ec 48             	sub    $0x48,%esp
  800d02:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d05:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d08:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d0b:	89 c6                	mov    %eax,%esi
  800d0d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d10:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d12:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1b:	51                   	push   %ecx
  800d1c:	52                   	push   %edx
  800d1d:	53                   	push   %ebx
  800d1e:	54                   	push   %esp
  800d1f:	55                   	push   %ebp
  800d20:	56                   	push   %esi
  800d21:	57                   	push   %edi
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	8d 35 2c 0d 80 00    	lea    0x800d2c,%esi
  800d2a:	0f 34                	sysenter 

00800d2c <.after_sysenter_label>:
  800d2c:	5f                   	pop    %edi
  800d2d:	5e                   	pop    %esi
  800d2e:	5d                   	pop    %ebp
  800d2f:	5c                   	pop    %esp
  800d30:	5b                   	pop    %ebx
  800d31:	5a                   	pop    %edx
  800d32:	59                   	pop    %ecx
  800d33:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d35:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d39:	74 28                	je     800d63 <.after_sysenter_label+0x37>
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 24                	jle    800d63 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d43:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d47:	c7 44 24 08 60 26 80 	movl   $0x802660,0x8(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d56:	00 
  800d57:	c7 04 24 7d 26 80 00 	movl   $0x80267d,(%esp)
  800d5e:	e8 dd 11 00 00       	call   801f40 <_panic>

	return ret;
}
  800d63:	89 d0                	mov    %edx,%eax
  800d65:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d68:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6e:	89 ec                	mov    %ebp,%esp
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d78:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d7f:	00 
  800d80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d87:	00 
  800d88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d8f:	00 
  800d90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d97:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d9f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da4:	e8 53 ff ff ff       	call   800cfc <syscall>
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800db1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800db8:	00 
  800db9:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dca:	89 04 24             	mov    %eax,(%esp)
  800dcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dda:	e8 1d ff ff ff       	call   800cfc <syscall>
}
  800ddf:	c9                   	leave  
  800de0:	c3                   	ret    

00800de1 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800e0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e12:	e8 e5 fe ff ff       	call   800cfc <syscall>
}
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    

00800e19 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800e45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4a:	e8 ad fe ff ff       	call   800cfc <syscall>
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e6e:	00 
  800e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e72:	89 04 24             	mov    %eax,(%esp)
  800e75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e78:	ba 01 00 00 00       	mov    $0x1,%edx
  800e7d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e82:	e8 75 fe ff ff       	call   800cfc <syscall>
}
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e8f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e96:	00 
  800e97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea6:	00 
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	89 04 24             	mov    %eax,(%esp)
  800ead:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eba:	e8 3d fe ff ff       	call   800cfc <syscall>
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800ec7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ece:	00 
  800ecf:	8b 45 18             	mov    0x18(%ebp),%eax
  800ed2:	0b 45 14             	or     0x14(%ebp),%eax
  800ed5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ed9:	8b 45 10             	mov    0x10(%ebp),%eax
  800edc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee3:	89 04 24             	mov    %eax,(%esp)
  800ee6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee9:	ba 01 00 00 00       	mov    $0x1,%edx
  800eee:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef3:	e8 04 fe ff ff       	call   800cfc <syscall>
}
  800ef8:	c9                   	leave  
  800ef9:	c3                   	ret    

00800efa <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f00:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f07:	00 
  800f08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f0f:	00 
  800f10:	8b 45 10             	mov    0x10(%ebp),%eax
  800f13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1a:	89 04 24             	mov    %eax,(%esp)
  800f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f20:	ba 01 00 00 00       	mov    $0x1,%edx
  800f25:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2a:	e8 cd fd ff ff       	call   800cfc <syscall>
}
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    

00800f31 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f37:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f46:	00 
  800f47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f4e:	00 
  800f4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f60:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f65:	e8 92 fd ff ff       	call   800cfc <syscall>
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f72:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f79:	00 
  800f7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f89:	00 
  800f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8d:	89 04 24             	mov    %eax,(%esp)
  800f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f93:	ba 00 00 00 00       	mov    $0x0,%edx
  800f98:	b8 04 00 00 00       	mov    $0x4,%eax
  800f9d:	e8 5a fd ff ff       	call   800cfc <syscall>
}
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800faa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb9:	00 
  800fba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc1:	00 
  800fc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fce:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd3:	b8 02 00 00 00       	mov    $0x2,%eax
  800fd8:	e8 1f fd ff ff       	call   800cfc <syscall>
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fe5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fec:	00 
  800fed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ffc:	00 
  800ffd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801004:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801007:	ba 01 00 00 00       	mov    $0x1,%edx
  80100c:	b8 03 00 00 00       	mov    $0x3,%eax
  801011:	e8 e6 fc ff ff       	call   800cfc <syscall>
}
  801016:	c9                   	leave  
  801017:	c3                   	ret    

00801018 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80101e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801025:	00 
  801026:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80102d:	00 
  80102e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801035:	00 
  801036:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801042:	ba 00 00 00 00       	mov    $0x0,%edx
  801047:	b8 01 00 00 00       	mov    $0x1,%eax
  80104c:	e8 ab fc ff ff       	call   800cfc <syscall>
}
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801059:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801060:	00 
  801061:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801068:	00 
  801069:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801070:	00 
  801071:	8b 45 0c             	mov    0xc(%ebp),%eax
  801074:	89 04 24             	mov    %eax,(%esp)
  801077:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107a:	ba 00 00 00 00       	mov    $0x0,%edx
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
  801084:	e8 73 fc ff ff       	call   800cfc <syscall>
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    
	...

0080108c <sfork>:
}

// Challenge!
int
sfork(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801092:	c7 44 24 08 8b 26 80 	movl   $0x80268b,0x8(%esp)
  801099:	00 
  80109a:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8010a1:	00 
  8010a2:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8010a9:	e8 92 0e 00 00       	call   801f40 <_panic>

008010ae <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  8010b7:	c7 04 24 72 13 80 00 	movl   $0x801372,(%esp)
  8010be:	e8 d5 0e 00 00       	call   801f98 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  8010c3:	ba 08 00 00 00       	mov    $0x8,%edx
  8010c8:	89 d0                	mov    %edx,%eax
  8010ca:	51                   	push   %ecx
  8010cb:	52                   	push   %edx
  8010cc:	53                   	push   %ebx
  8010cd:	55                   	push   %ebp
  8010ce:	56                   	push   %esi
  8010cf:	57                   	push   %edi
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	8d 35 da 10 80 00    	lea    0x8010da,%esi
  8010d8:	0f 34                	sysenter 

008010da <.after_sysenter_label>:
  8010da:	5f                   	pop    %edi
  8010db:	5e                   	pop    %esi
  8010dc:	5d                   	pop    %ebp
  8010dd:	5b                   	pop    %ebx
  8010de:	5a                   	pop    %edx
  8010df:	59                   	pop    %ecx
  8010e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  8010e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010e7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  8010ee:	00 
  8010ef:	c7 44 24 04 a1 26 80 	movl   $0x8026a1,0x4(%esp)
  8010f6:	00 
  8010f7:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  8010fe:	e8 c2 f0 ff ff       	call   8001c5 <cprintf>
	if (envidnum < 0)
  801103:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801107:	79 23                	jns    80112c <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  801109:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80110c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801110:	c7 44 24 08 ac 26 80 	movl   $0x8026ac,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801127:	e8 14 0e 00 00       	call   801f40 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  80112c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801131:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801136:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80113b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80113f:	75 1c                	jne    80115d <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801141:	e8 5e fe ff ff       	call   800fa4 <sys_getenvid>
  801146:	25 ff 03 00 00       	and    $0x3ff,%eax
  80114b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80114e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801153:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801158:	e9 0a 02 00 00       	jmp    801367 <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  80115d:	89 d8                	mov    %ebx,%eax
  80115f:	c1 e8 16             	shr    $0x16,%eax
  801162:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801165:	a8 01                	test   $0x1,%al
  801167:	0f 84 43 01 00 00    	je     8012b0 <.after_sysenter_label+0x1d6>
  80116d:	89 d8                	mov    %ebx,%eax
  80116f:	c1 e8 0c             	shr    $0xc,%eax
  801172:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801175:	f6 c2 01             	test   $0x1,%dl
  801178:	0f 84 32 01 00 00    	je     8012b0 <.after_sysenter_label+0x1d6>
  80117e:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801181:	f6 c2 04             	test   $0x4,%dl
  801184:	0f 84 26 01 00 00    	je     8012b0 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  80118a:	c1 e0 0c             	shl    $0xc,%eax
  80118d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801190:	c1 e8 0c             	shr    $0xc,%eax
  801193:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  801196:	89 c2                	mov    %eax,%edx
  801198:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  80119e:	a9 02 08 00 00       	test   $0x802,%eax
  8011a3:	0f 84 a0 00 00 00    	je     801249 <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  8011a9:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  8011ac:	80 ce 08             	or     $0x8,%dh
  8011af:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8011b2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d2:	e8 ea fc ff ff       	call   800ec1 <sys_page_map>
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	79 20                	jns    8011fb <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  8011db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011df:	c7 44 24 08 24 27 80 	movl   $0x802724,0x8(%esp)
  8011e6:	00 
  8011e7:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8011ee:	00 
  8011ef:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8011f6:	e8 45 0d 00 00       	call   801f40 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  8011fb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801202:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801205:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801209:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801210:	00 
  801211:	89 44 24 04          	mov    %eax,0x4(%esp)
  801215:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80121c:	e8 a0 fc ff ff       	call   800ec1 <sys_page_map>
  801221:	85 c0                	test   %eax,%eax
  801223:	0f 89 87 00 00 00    	jns    8012b0 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  801229:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80122d:	c7 44 24 08 50 27 80 	movl   $0x802750,0x8(%esp)
  801234:	00 
  801235:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  80123c:	00 
  80123d:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801244:	e8 f7 0c 00 00       	call   801f40 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  801249:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801250:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801253:	89 44 24 04          	mov    %eax,0x4(%esp)
  801257:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  80125e:	e8 62 ef ff ff       	call   8001c5 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801263:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80126a:	00 
  80126b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80126e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801272:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801275:	89 44 24 08          	mov    %eax,0x8(%esp)
  801279:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801280:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801287:	e8 35 fc ff ff       	call   800ec1 <sys_page_map>
  80128c:	85 c0                	test   %eax,%eax
  80128e:	79 20                	jns    8012b0 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801290:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801294:	c7 44 24 08 7c 27 80 	movl   $0x80277c,0x8(%esp)
  80129b:	00 
  80129c:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012a3:	00 
  8012a4:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8012ab:	e8 90 0c 00 00       	call   801f40 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  8012b0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012b6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012bc:	0f 85 9b fe ff ff    	jne    80115d <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8012c2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012c9:	00 
  8012ca:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012d1:	ee 
  8012d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	e8 1d fc ff ff       	call   800efa <sys_page_alloc>
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	79 20                	jns    801301 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  8012e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e5:	c7 44 24 08 a8 27 80 	movl   $0x8027a8,0x8(%esp)
  8012ec:	00 
  8012ed:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8012f4:	00 
  8012f5:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8012fc:	e8 3f 0c 00 00       	call   801f40 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801301:	c7 44 24 04 08 20 80 	movl   $0x802008,0x4(%esp)
  801308:	00 
  801309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130c:	89 04 24             	mov    %eax,(%esp)
  80130f:	e8 cd fa ff ff       	call   800de1 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801314:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80131b:	00 
  80131c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80131f:	89 04 24             	mov    %eax,(%esp)
  801322:	e8 2a fb ff ff       	call   800e51 <sys_env_set_status>
  801327:	85 c0                	test   %eax,%eax
  801329:	79 20                	jns    80134b <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80132b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132f:	c7 44 24 08 cc 27 80 	movl   $0x8027cc,0x8(%esp)
  801336:	00 
  801337:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80133e:	00 
  80133f:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801346:	e8 f5 0b 00 00       	call   801f40 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80134b:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 a1 26 80 	movl   $0x8026a1,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 ce 26 80 00 	movl   $0x8026ce,(%esp)
  801362:	e8 5e ee ff ff       	call   8001c5 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  801367:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80136a:	83 c4 3c             	add    $0x3c,%esp
  80136d:	5b                   	pop    %ebx
  80136e:	5e                   	pop    %esi
  80136f:	5f                   	pop    %edi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	57                   	push   %edi
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	83 ec 2c             	sub    $0x2c,%esp
  80137b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  80137e:	8b 33                	mov    (%ebx),%esi
	uint32_t err = utf->utf_err;
  801380:	8b 7b 04             	mov    0x4(%ebx),%edi
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
  801383:	8b 43 2c             	mov    0x2c(%ebx),%eax
  801386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138a:	c7 04 24 f4 27 80 00 	movl   $0x8027f4,(%esp)
  801391:	e8 2f ee ff ff       	call   8001c5 <cprintf>
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801396:	f7 c7 02 00 00 00    	test   $0x2,%edi
  80139c:	75 2b                	jne    8013c9 <pgfault+0x57>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  80139e:	8b 43 28             	mov    0x28(%ebx),%eax
  8013a1:	89 44 24 14          	mov    %eax,0x14(%esp)
  8013a5:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013a9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013ad:	c7 44 24 08 14 28 80 	movl   $0x802814,0x8(%esp)
  8013b4:	00 
  8013b5:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8013bc:	00 
  8013bd:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8013c4:	e8 77 0b 00 00       	call   801f40 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  8013c9:	89 f0                	mov    %esi,%eax
  8013cb:	c1 e8 16             	shr    $0x16,%eax
  8013ce:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013d5:	a8 01                	test   $0x1,%al
  8013d7:	74 11                	je     8013ea <pgfault+0x78>
  8013d9:	89 f0                	mov    %esi,%eax
  8013db:	c1 e8 0c             	shr    $0xc,%eax
  8013de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e5:	f6 c4 08             	test   $0x8,%ah
  8013e8:	75 1c                	jne    801406 <pgfault+0x94>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  8013ea:	c7 44 24 08 50 28 80 	movl   $0x802850,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801401:	e8 3a 0b 00 00       	call   801f40 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801406:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80140d:	00 
  80140e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801415:	00 
  801416:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80141d:	e8 d8 fa ff ff       	call   800efa <sys_page_alloc>
  801422:	85 c0                	test   %eax,%eax
  801424:	79 20                	jns    801446 <pgfault+0xd4>
		panic ("pgfault: page allocation failed : %e", r);
  801426:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80142a:	c7 44 24 08 8c 28 80 	movl   $0x80288c,0x8(%esp)
  801431:	00 
  801432:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801439:	00 
  80143a:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801441:	e8 fa 0a 00 00       	call   801f40 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801446:	89 f3                	mov    %esi,%ebx
  801448:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  80144e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801455:	00 
  801456:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80145a:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801461:	e8 8f f6 ff ff       	call   800af5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801466:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80146d:	00 
  80146e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801472:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801479:	00 
  80147a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801481:	00 
  801482:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801489:	e8 33 fa ff ff       	call   800ec1 <sys_page_map>
  80148e:	85 c0                	test   %eax,%eax
  801490:	79 20                	jns    8014b2 <pgfault+0x140>
		panic ("pgfault: page mapping failed : %e", r);
  801492:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801496:	c7 44 24 08 b4 28 80 	movl   $0x8028b4,0x8(%esp)
  80149d:	00 
  80149e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8014a5:	00 
  8014a6:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8014ad:	e8 8e 0a 00 00       	call   801f40 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  8014b2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014b9:	00 
  8014ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c1:	e8 c3 f9 ff ff       	call   800e89 <sys_page_unmap>
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	79 20                	jns    8014ea <pgfault+0x178>
		panic("pgfault: page unmapping failed : %e", r);
  8014ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ce:	c7 44 24 08 d8 28 80 	movl   $0x8028d8,0x8(%esp)
  8014d5:	00 
  8014d6:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8014dd:	00 
  8014de:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8014e5:	e8 56 0a 00 00       	call   801f40 <_panic>
	cprintf("pgfault: finish\n");
  8014ea:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  8014f1:	e8 cf ec ff ff       	call   8001c5 <cprintf>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  8014f6:	83 c4 2c             	add    $0x2c,%esp
  8014f9:	5b                   	pop    %ebx
  8014fa:	5e                   	pop    %esi
  8014fb:	5f                   	pop    %edi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    
	...

00801500 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801506:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80150c:	b8 01 00 00 00       	mov    $0x1,%eax
  801511:	39 ca                	cmp    %ecx,%edx
  801513:	75 04                	jne    801519 <ipc_find_env+0x19>
  801515:	b0 00                	mov    $0x0,%al
  801517:	eb 0f                	jmp    801528 <ipc_find_env+0x28>
  801519:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80151c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801522:	8b 12                	mov    (%edx),%edx
  801524:	39 ca                	cmp    %ecx,%edx
  801526:	75 0c                	jne    801534 <ipc_find_env+0x34>
			return envs[i].env_id;
  801528:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80152b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801530:	8b 00                	mov    (%eax),%eax
  801532:	eb 0e                	jmp    801542 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801534:	83 c0 01             	add    $0x1,%eax
  801537:	3d 00 04 00 00       	cmp    $0x400,%eax
  80153c:	75 db                	jne    801519 <ipc_find_env+0x19>
  80153e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    

00801544 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	57                   	push   %edi
  801548:	56                   	push   %esi
  801549:	53                   	push   %ebx
  80154a:	83 ec 1c             	sub    $0x1c,%esp
  80154d:	8b 75 08             	mov    0x8(%ebp),%esi
  801550:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801553:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801556:	85 db                	test   %ebx,%ebx
  801558:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80155d:	0f 44 d8             	cmove  %eax,%ebx
  801560:	eb 29                	jmp    80158b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801562:	85 c0                	test   %eax,%eax
  801564:	79 25                	jns    80158b <ipc_send+0x47>
  801566:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801569:	74 20                	je     80158b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  80156b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80156f:	c7 44 24 08 fc 28 80 	movl   $0x8028fc,0x8(%esp)
  801576:	00 
  801577:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80157e:	00 
  80157f:	c7 04 24 1a 29 80 00 	movl   $0x80291a,(%esp)
  801586:	e8 b5 09 00 00       	call   801f40 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80158b:	8b 45 14             	mov    0x14(%ebp),%eax
  80158e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801592:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801596:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80159a:	89 34 24             	mov    %esi,(%esp)
  80159d:	e8 09 f8 ff ff       	call   800dab <sys_ipc_try_send>
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	75 bc                	jne    801562 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8015a6:	e8 86 f9 ff ff       	call   800f31 <sys_yield>
}
  8015ab:	83 c4 1c             	add    $0x1c,%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5e                   	pop    %esi
  8015b0:	5f                   	pop    %edi
  8015b1:	5d                   	pop    %ebp
  8015b2:	c3                   	ret    

008015b3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 28             	sub    $0x28,%esp
  8015b9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015bc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015bf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8015c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8015d2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8015d5:	89 04 24             	mov    %eax,(%esp)
  8015d8:	e8 95 f7 ff ff       	call   800d72 <sys_ipc_recv>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	79 2a                	jns    80160d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8015e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015eb:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  8015f2:	e8 ce eb ff ff       	call   8001c5 <cprintf>
		if(from_env_store != NULL)
  8015f7:	85 f6                	test   %esi,%esi
  8015f9:	74 06                	je     801601 <ipc_recv+0x4e>
			*from_env_store = 0;
  8015fb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801601:	85 ff                	test   %edi,%edi
  801603:	74 2d                	je     801632 <ipc_recv+0x7f>
			*perm_store = 0;
  801605:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80160b:	eb 25                	jmp    801632 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  80160d:	85 f6                	test   %esi,%esi
  80160f:	90                   	nop
  801610:	74 0a                	je     80161c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801612:	a1 04 40 80 00       	mov    0x804004,%eax
  801617:	8b 40 74             	mov    0x74(%eax),%eax
  80161a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80161c:	85 ff                	test   %edi,%edi
  80161e:	74 0a                	je     80162a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801620:	a1 04 40 80 00       	mov    0x804004,%eax
  801625:	8b 40 78             	mov    0x78(%eax),%eax
  801628:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80162a:	a1 04 40 80 00       	mov    0x804004,%eax
  80162f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801632:	89 d8                	mov    %ebx,%eax
  801634:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801637:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80163a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80163d:	89 ec                	mov    %ebp,%esp
  80163f:	5d                   	pop    %ebp
  801640:	c3                   	ret    
	...

00801650 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801650:	55                   	push   %ebp
  801651:	89 e5                	mov    %esp,%ebp
  801653:	8b 45 08             	mov    0x8(%ebp),%eax
  801656:	05 00 00 00 30       	add    $0x30000000,%eax
  80165b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80165e:	5d                   	pop    %ebp
  80165f:	c3                   	ret    

00801660 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801660:	55                   	push   %ebp
  801661:	89 e5                	mov    %esp,%ebp
  801663:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801666:	8b 45 08             	mov    0x8(%ebp),%eax
  801669:	89 04 24             	mov    %eax,(%esp)
  80166c:	e8 df ff ff ff       	call   801650 <fd2num>
  801671:	05 20 00 0d 00       	add    $0xd0020,%eax
  801676:	c1 e0 0c             	shl    $0xc,%eax
}
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	57                   	push   %edi
  80167f:	56                   	push   %esi
  801680:	53                   	push   %ebx
  801681:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801684:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801689:	a8 01                	test   $0x1,%al
  80168b:	74 36                	je     8016c3 <fd_alloc+0x48>
  80168d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801692:	a8 01                	test   $0x1,%al
  801694:	74 2d                	je     8016c3 <fd_alloc+0x48>
  801696:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80169b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016a0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016a5:	89 c3                	mov    %eax,%ebx
  8016a7:	89 c2                	mov    %eax,%edx
  8016a9:	c1 ea 16             	shr    $0x16,%edx
  8016ac:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016af:	f6 c2 01             	test   $0x1,%dl
  8016b2:	74 14                	je     8016c8 <fd_alloc+0x4d>
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	c1 ea 0c             	shr    $0xc,%edx
  8016b9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016bc:	f6 c2 01             	test   $0x1,%dl
  8016bf:	75 10                	jne    8016d1 <fd_alloc+0x56>
  8016c1:	eb 05                	jmp    8016c8 <fd_alloc+0x4d>
  8016c3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8016c8:	89 1f                	mov    %ebx,(%edi)
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016cf:	eb 17                	jmp    8016e8 <fd_alloc+0x6d>
  8016d1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8016d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016db:	75 c8                	jne    8016a5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016dd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8016e8:	5b                   	pop    %ebx
  8016e9:	5e                   	pop    %esi
  8016ea:	5f                   	pop    %edi
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8016f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f3:	83 f8 1f             	cmp    $0x1f,%eax
  8016f6:	77 36                	ja     80172e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8016f8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8016fd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801700:	89 c2                	mov    %eax,%edx
  801702:	c1 ea 16             	shr    $0x16,%edx
  801705:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80170c:	f6 c2 01             	test   $0x1,%dl
  80170f:	74 1d                	je     80172e <fd_lookup+0x41>
  801711:	89 c2                	mov    %eax,%edx
  801713:	c1 ea 0c             	shr    $0xc,%edx
  801716:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80171d:	f6 c2 01             	test   $0x1,%dl
  801720:	74 0c                	je     80172e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801722:	8b 55 0c             	mov    0xc(%ebp),%edx
  801725:	89 02                	mov    %eax,(%edx)
  801727:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80172c:	eb 05                	jmp    801733 <fd_lookup+0x46>
  80172e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    

00801735 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80173b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80173e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801742:	8b 45 08             	mov    0x8(%ebp),%eax
  801745:	89 04 24             	mov    %eax,(%esp)
  801748:	e8 a0 ff ff ff       	call   8016ed <fd_lookup>
  80174d:	85 c0                	test   %eax,%eax
  80174f:	78 0e                	js     80175f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801751:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801754:	8b 55 0c             	mov    0xc(%ebp),%edx
  801757:	89 50 04             	mov    %edx,0x4(%eax)
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	83 ec 10             	sub    $0x10,%esp
  801769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801774:	b8 04 30 80 00       	mov    $0x803004,%eax
  801779:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80177f:	75 11                	jne    801792 <dev_lookup+0x31>
  801781:	eb 04                	jmp    801787 <dev_lookup+0x26>
  801783:	39 08                	cmp    %ecx,(%eax)
  801785:	75 10                	jne    801797 <dev_lookup+0x36>
			*dev = devtab[i];
  801787:	89 03                	mov    %eax,(%ebx)
  801789:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80178e:	66 90                	xchg   %ax,%ax
  801790:	eb 36                	jmp    8017c8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801792:	be b4 29 80 00       	mov    $0x8029b4,%esi
  801797:	83 c2 01             	add    $0x1,%edx
  80179a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80179d:	85 c0                	test   %eax,%eax
  80179f:	75 e2                	jne    801783 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a6:	8b 40 48             	mov    0x48(%eax),%eax
  8017a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b1:	c7 04 24 38 29 80 00 	movl   $0x802938,(%esp)
  8017b8:	e8 08 ea ff ff       	call   8001c5 <cprintf>
	*dev = 0;
  8017bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8017c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5e                   	pop    %esi
  8017cd:	5d                   	pop    %ebp
  8017ce:	c3                   	ret    

008017cf <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	53                   	push   %ebx
  8017d3:	83 ec 24             	sub    $0x24,%esp
  8017d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	89 04 24             	mov    %eax,(%esp)
  8017e6:	e8 02 ff ff ff       	call   8016ed <fd_lookup>
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	78 53                	js     801842 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017f9:	8b 00                	mov    (%eax),%eax
  8017fb:	89 04 24             	mov    %eax,(%esp)
  8017fe:	e8 5e ff ff ff       	call   801761 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801803:	85 c0                	test   %eax,%eax
  801805:	78 3b                	js     801842 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801807:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80180c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801813:	74 2d                	je     801842 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801815:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801818:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80181f:	00 00 00 
	stat->st_isdir = 0;
  801822:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801829:	00 00 00 
	stat->st_dev = dev;
  80182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801835:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801839:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80183c:	89 14 24             	mov    %edx,(%esp)
  80183f:	ff 50 14             	call   *0x14(%eax)
}
  801842:	83 c4 24             	add    $0x24,%esp
  801845:	5b                   	pop    %ebx
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	53                   	push   %ebx
  80184c:	83 ec 24             	sub    $0x24,%esp
  80184f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801855:	89 44 24 04          	mov    %eax,0x4(%esp)
  801859:	89 1c 24             	mov    %ebx,(%esp)
  80185c:	e8 8c fe ff ff       	call   8016ed <fd_lookup>
  801861:	85 c0                	test   %eax,%eax
  801863:	78 5f                	js     8018c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801868:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186f:	8b 00                	mov    (%eax),%eax
  801871:	89 04 24             	mov    %eax,(%esp)
  801874:	e8 e8 fe ff ff       	call   801761 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801879:	85 c0                	test   %eax,%eax
  80187b:	78 47                	js     8018c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801880:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801884:	75 23                	jne    8018a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801886:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80188b:	8b 40 48             	mov    0x48(%eax),%eax
  80188e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801892:	89 44 24 04          	mov    %eax,0x4(%esp)
  801896:	c7 04 24 58 29 80 00 	movl   $0x802958,(%esp)
  80189d:	e8 23 e9 ff ff       	call   8001c5 <cprintf>
  8018a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018a7:	eb 1b                	jmp    8018c4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ac:	8b 48 18             	mov    0x18(%eax),%ecx
  8018af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018b4:	85 c9                	test   %ecx,%ecx
  8018b6:	74 0c                	je     8018c4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bf:	89 14 24             	mov    %edx,(%esp)
  8018c2:	ff d1                	call   *%ecx
}
  8018c4:	83 c4 24             	add    $0x24,%esp
  8018c7:	5b                   	pop    %ebx
  8018c8:	5d                   	pop    %ebp
  8018c9:	c3                   	ret    

008018ca <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	53                   	push   %ebx
  8018ce:	83 ec 24             	sub    $0x24,%esp
  8018d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018db:	89 1c 24             	mov    %ebx,(%esp)
  8018de:	e8 0a fe ff ff       	call   8016ed <fd_lookup>
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 66                	js     80194d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f1:	8b 00                	mov    (%eax),%eax
  8018f3:	89 04 24             	mov    %eax,(%esp)
  8018f6:	e8 66 fe ff ff       	call   801761 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 4e                	js     80194d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801902:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801906:	75 23                	jne    80192b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801908:	a1 04 40 80 00       	mov    0x804004,%eax
  80190d:	8b 40 48             	mov    0x48(%eax),%eax
  801910:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801914:	89 44 24 04          	mov    %eax,0x4(%esp)
  801918:	c7 04 24 79 29 80 00 	movl   $0x802979,(%esp)
  80191f:	e8 a1 e8 ff ff       	call   8001c5 <cprintf>
  801924:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801929:	eb 22                	jmp    80194d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80192b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801931:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801936:	85 c9                	test   %ecx,%ecx
  801938:	74 13                	je     80194d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80193a:	8b 45 10             	mov    0x10(%ebp),%eax
  80193d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801941:	8b 45 0c             	mov    0xc(%ebp),%eax
  801944:	89 44 24 04          	mov    %eax,0x4(%esp)
  801948:	89 14 24             	mov    %edx,(%esp)
  80194b:	ff d1                	call   *%ecx
}
  80194d:	83 c4 24             	add    $0x24,%esp
  801950:	5b                   	pop    %ebx
  801951:	5d                   	pop    %ebp
  801952:	c3                   	ret    

00801953 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	53                   	push   %ebx
  801957:	83 ec 24             	sub    $0x24,%esp
  80195a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80195d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801960:	89 44 24 04          	mov    %eax,0x4(%esp)
  801964:	89 1c 24             	mov    %ebx,(%esp)
  801967:	e8 81 fd ff ff       	call   8016ed <fd_lookup>
  80196c:	85 c0                	test   %eax,%eax
  80196e:	78 6b                	js     8019db <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801970:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801973:	89 44 24 04          	mov    %eax,0x4(%esp)
  801977:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80197a:	8b 00                	mov    (%eax),%eax
  80197c:	89 04 24             	mov    %eax,(%esp)
  80197f:	e8 dd fd ff ff       	call   801761 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801984:	85 c0                	test   %eax,%eax
  801986:	78 53                	js     8019db <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801988:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80198b:	8b 42 08             	mov    0x8(%edx),%eax
  80198e:	83 e0 03             	and    $0x3,%eax
  801991:	83 f8 01             	cmp    $0x1,%eax
  801994:	75 23                	jne    8019b9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801996:	a1 04 40 80 00       	mov    0x804004,%eax
  80199b:	8b 40 48             	mov    0x48(%eax),%eax
  80199e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a6:	c7 04 24 96 29 80 00 	movl   $0x802996,(%esp)
  8019ad:	e8 13 e8 ff ff       	call   8001c5 <cprintf>
  8019b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019b7:	eb 22                	jmp    8019db <read+0x88>
	}
	if (!dev->dev_read)
  8019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bc:	8b 48 08             	mov    0x8(%eax),%ecx
  8019bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c4:	85 c9                	test   %ecx,%ecx
  8019c6:	74 13                	je     8019db <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d6:	89 14 24             	mov    %edx,(%esp)
  8019d9:	ff d1                	call   *%ecx
}
  8019db:	83 c4 24             	add    $0x24,%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	57                   	push   %edi
  8019e5:	56                   	push   %esi
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 1c             	sub    $0x1c,%esp
  8019ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8019ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ff:	85 f6                	test   %esi,%esi
  801a01:	74 29                	je     801a2c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a03:	89 f0                	mov    %esi,%eax
  801a05:	29 d0                	sub    %edx,%eax
  801a07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0b:	03 55 0c             	add    0xc(%ebp),%edx
  801a0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a12:	89 3c 24             	mov    %edi,(%esp)
  801a15:	e8 39 ff ff ff       	call   801953 <read>
		if (m < 0)
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 0e                	js     801a2c <readn+0x4b>
			return m;
		if (m == 0)
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	74 08                	je     801a2a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a22:	01 c3                	add    %eax,%ebx
  801a24:	89 da                	mov    %ebx,%edx
  801a26:	39 f3                	cmp    %esi,%ebx
  801a28:	72 d9                	jb     801a03 <readn+0x22>
  801a2a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a2c:	83 c4 1c             	add    $0x1c,%esp
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	83 ec 28             	sub    $0x28,%esp
  801a3a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a3d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a40:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a43:	89 34 24             	mov    %esi,(%esp)
  801a46:	e8 05 fc ff ff       	call   801650 <fd2num>
  801a4b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a52:	89 04 24             	mov    %eax,(%esp)
  801a55:	e8 93 fc ff ff       	call   8016ed <fd_lookup>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 05                	js     801a65 <fd_close+0x31>
  801a60:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801a63:	74 0e                	je     801a73 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801a65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a69:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6e:	0f 44 d8             	cmove  %eax,%ebx
  801a71:	eb 3d                	jmp    801ab0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7a:	8b 06                	mov    (%esi),%eax
  801a7c:	89 04 24             	mov    %eax,(%esp)
  801a7f:	e8 dd fc ff ff       	call   801761 <dev_lookup>
  801a84:	89 c3                	mov    %eax,%ebx
  801a86:	85 c0                	test   %eax,%eax
  801a88:	78 16                	js     801aa0 <fd_close+0x6c>
		if (dev->dev_close)
  801a8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a8d:	8b 40 10             	mov    0x10(%eax),%eax
  801a90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a95:	85 c0                	test   %eax,%eax
  801a97:	74 07                	je     801aa0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801a99:	89 34 24             	mov    %esi,(%esp)
  801a9c:	ff d0                	call   *%eax
  801a9e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801aa0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aab:	e8 d9 f3 ff ff       	call   800e89 <sys_page_unmap>
	return r;
}
  801ab0:	89 d8                	mov    %ebx,%eax
  801ab2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ab5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ab8:	89 ec                	mov    %ebp,%esp
  801aba:	5d                   	pop    %ebp
  801abb:	c3                   	ret    

00801abc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801abc:	55                   	push   %ebp
  801abd:	89 e5                	mov    %esp,%ebp
  801abf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ac2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 19 fc ff ff       	call   8016ed <fd_lookup>
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 13                	js     801aeb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801ad8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801adf:	00 
  801ae0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae3:	89 04 24             	mov    %eax,(%esp)
  801ae6:	e8 49 ff ff ff       	call   801a34 <fd_close>
}
  801aeb:	c9                   	leave  
  801aec:	c3                   	ret    

00801aed <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	83 ec 18             	sub    $0x18,%esp
  801af3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801af6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801af9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b00:	00 
  801b01:	8b 45 08             	mov    0x8(%ebp),%eax
  801b04:	89 04 24             	mov    %eax,(%esp)
  801b07:	e8 78 03 00 00       	call   801e84 <open>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 1b                	js     801b2d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b19:	89 1c 24             	mov    %ebx,(%esp)
  801b1c:	e8 ae fc ff ff       	call   8017cf <fstat>
  801b21:	89 c6                	mov    %eax,%esi
	close(fd);
  801b23:	89 1c 24             	mov    %ebx,(%esp)
  801b26:	e8 91 ff ff ff       	call   801abc <close>
  801b2b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b2d:	89 d8                	mov    %ebx,%eax
  801b2f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b32:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b35:	89 ec                	mov    %ebp,%esp
  801b37:	5d                   	pop    %ebp
  801b38:	c3                   	ret    

00801b39 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b39:	55                   	push   %ebp
  801b3a:	89 e5                	mov    %esp,%ebp
  801b3c:	53                   	push   %ebx
  801b3d:	83 ec 14             	sub    $0x14,%esp
  801b40:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b45:	89 1c 24             	mov    %ebx,(%esp)
  801b48:	e8 6f ff ff ff       	call   801abc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b4d:	83 c3 01             	add    $0x1,%ebx
  801b50:	83 fb 20             	cmp    $0x20,%ebx
  801b53:	75 f0                	jne    801b45 <close_all+0xc>
		close(i);
}
  801b55:	83 c4 14             	add    $0x14,%esp
  801b58:	5b                   	pop    %ebx
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 58             	sub    $0x58,%esp
  801b61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b67:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b6a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801b6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b74:	8b 45 08             	mov    0x8(%ebp),%eax
  801b77:	89 04 24             	mov    %eax,(%esp)
  801b7a:	e8 6e fb ff ff       	call   8016ed <fd_lookup>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	85 c0                	test   %eax,%eax
  801b83:	0f 88 e0 00 00 00    	js     801c69 <dup+0x10e>
		return r;
	close(newfdnum);
  801b89:	89 3c 24             	mov    %edi,(%esp)
  801b8c:	e8 2b ff ff ff       	call   801abc <close>

	newfd = INDEX2FD(newfdnum);
  801b91:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b97:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b9d:	89 04 24             	mov    %eax,(%esp)
  801ba0:	e8 bb fa ff ff       	call   801660 <fd2data>
  801ba5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ba7:	89 34 24             	mov    %esi,(%esp)
  801baa:	e8 b1 fa ff ff       	call   801660 <fd2data>
  801baf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801bb2:	89 da                	mov    %ebx,%edx
  801bb4:	89 d8                	mov    %ebx,%eax
  801bb6:	c1 e8 16             	shr    $0x16,%eax
  801bb9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801bc0:	a8 01                	test   $0x1,%al
  801bc2:	74 43                	je     801c07 <dup+0xac>
  801bc4:	c1 ea 0c             	shr    $0xc,%edx
  801bc7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bce:	a8 01                	test   $0x1,%al
  801bd0:	74 35                	je     801c07 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801bd2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801bd9:	25 07 0e 00 00       	and    $0xe07,%eax
  801bde:	89 44 24 10          	mov    %eax,0x10(%esp)
  801be2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801be5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bf0:	00 
  801bf1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfc:	e8 c0 f2 ff ff       	call   800ec1 <sys_page_map>
  801c01:	89 c3                	mov    %eax,%ebx
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 3f                	js     801c46 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c0a:	89 c2                	mov    %eax,%edx
  801c0c:	c1 ea 0c             	shr    $0xc,%edx
  801c0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c16:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c1c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c20:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c2b:	00 
  801c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c37:	e8 85 f2 ff ff       	call   800ec1 <sys_page_map>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	85 c0                	test   %eax,%eax
  801c40:	78 04                	js     801c46 <dup+0xeb>
  801c42:	89 fb                	mov    %edi,%ebx
  801c44:	eb 23                	jmp    801c69 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c51:	e8 33 f2 ff ff       	call   800e89 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c64:	e8 20 f2 ff ff       	call   800e89 <sys_page_unmap>
	return r;
}
  801c69:	89 d8                	mov    %ebx,%eax
  801c6b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c6e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c74:	89 ec                	mov    %ebp,%esp
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    

00801c78 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	83 ec 18             	sub    $0x18,%esp
  801c7e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c81:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c88:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801c8f:	75 11                	jne    801ca2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c91:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c98:	e8 63 f8 ff ff       	call   801500 <ipc_find_env>
  801c9d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ca2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ca9:	00 
  801caa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cb1:	00 
  801cb2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb6:	a1 00 40 80 00       	mov    0x804000,%eax
  801cbb:	89 04 24             	mov    %eax,(%esp)
  801cbe:	e8 81 f8 ff ff       	call   801544 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801cc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cca:	00 
  801ccb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ccf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd6:	e8 d8 f8 ff ff       	call   8015b3 <ipc_recv>
}
  801cdb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cde:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ce1:	89 ec                	mov    %ebp,%esp
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cee:	8b 40 0c             	mov    0xc(%eax),%eax
  801cf1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cfe:	ba 00 00 00 00       	mov    $0x0,%edx
  801d03:	b8 02 00 00 00       	mov    $0x2,%eax
  801d08:	e8 6b ff ff ff       	call   801c78 <fsipc>
}
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d20:	ba 00 00 00 00       	mov    $0x0,%edx
  801d25:	b8 06 00 00 00       	mov    $0x6,%eax
  801d2a:	e8 49 ff ff ff       	call   801c78 <fsipc>
}
  801d2f:	c9                   	leave  
  801d30:	c3                   	ret    

00801d31 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d37:	ba 00 00 00 00       	mov    $0x0,%edx
  801d3c:	b8 08 00 00 00       	mov    $0x8,%eax
  801d41:	e8 32 ff ff ff       	call   801c78 <fsipc>
}
  801d46:	c9                   	leave  
  801d47:	c3                   	ret    

00801d48 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d48:	55                   	push   %ebp
  801d49:	89 e5                	mov    %esp,%ebp
  801d4b:	53                   	push   %ebx
  801d4c:	83 ec 14             	sub    $0x14,%esp
  801d4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
  801d55:	8b 40 0c             	mov    0xc(%eax),%eax
  801d58:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801d62:	b8 05 00 00 00       	mov    $0x5,%eax
  801d67:	e8 0c ff ff ff       	call   801c78 <fsipc>
  801d6c:	85 c0                	test   %eax,%eax
  801d6e:	78 2b                	js     801d9b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d70:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d77:	00 
  801d78:	89 1c 24             	mov    %ebx,(%esp)
  801d7b:	e8 8a eb ff ff       	call   80090a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d80:	a1 80 50 80 00       	mov    0x805080,%eax
  801d85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d8b:	a1 84 50 80 00       	mov    0x805084,%eax
  801d90:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d9b:	83 c4 14             	add    $0x14,%esp
  801d9e:	5b                   	pop    %ebx
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    

00801da1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 18             	sub    $0x18,%esp
  801da7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801daa:	8b 55 08             	mov    0x8(%ebp),%edx
  801dad:	8b 52 0c             	mov    0xc(%edx),%edx
  801db0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801db6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801dbb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801dc0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801dc5:	0f 47 c2             	cmova  %edx,%eax
  801dc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801dda:	e8 16 ed ff ff       	call   800af5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  801de4:	b8 04 00 00 00       	mov    $0x4,%eax
  801de9:	e8 8a fe ff ff       	call   801c78 <fsipc>
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	53                   	push   %ebx
  801df4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801df7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfa:	8b 40 0c             	mov    0xc(%eax),%eax
  801dfd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801e02:	8b 45 10             	mov    0x10(%ebp),%eax
  801e05:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e0f:	b8 03 00 00 00       	mov    $0x3,%eax
  801e14:	e8 5f fe ff ff       	call   801c78 <fsipc>
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	78 17                	js     801e36 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e23:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e2a:	00 
  801e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2e:	89 04 24             	mov    %eax,(%esp)
  801e31:	e8 bf ec ff ff       	call   800af5 <memmove>
  return r;	
}
  801e36:	89 d8                	mov    %ebx,%eax
  801e38:	83 c4 14             	add    $0x14,%esp
  801e3b:	5b                   	pop    %ebx
  801e3c:	5d                   	pop    %ebp
  801e3d:	c3                   	ret    

00801e3e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 14             	sub    $0x14,%esp
  801e45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e48:	89 1c 24             	mov    %ebx,(%esp)
  801e4b:	e8 70 ea ff ff       	call   8008c0 <strlen>
  801e50:	89 c2                	mov    %eax,%edx
  801e52:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e57:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e5d:	7f 1f                	jg     801e7e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e63:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801e6a:	e8 9b ea ff ff       	call   80090a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801e6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e74:	b8 07 00 00 00       	mov    $0x7,%eax
  801e79:	e8 fa fd ff ff       	call   801c78 <fsipc>
}
  801e7e:	83 c4 14             	add    $0x14,%esp
  801e81:	5b                   	pop    %ebx
  801e82:	5d                   	pop    %ebp
  801e83:	c3                   	ret    

00801e84 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	83 ec 28             	sub    $0x28,%esp
  801e8a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e8d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e90:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e96:	89 04 24             	mov    %eax,(%esp)
  801e99:	e8 dd f7 ff ff       	call   80167b <fd_alloc>
  801e9e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801ea0:	85 c0                	test   %eax,%eax
  801ea2:	0f 88 89 00 00 00    	js     801f31 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801ea8:	89 34 24             	mov    %esi,(%esp)
  801eab:	e8 10 ea ff ff       	call   8008c0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801eb0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801eb5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801eba:	7f 75                	jg     801f31 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801ebc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ec0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ec7:	e8 3e ea ff ff       	call   80090a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801ed4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ed7:	b8 01 00 00 00       	mov    $0x1,%eax
  801edc:	e8 97 fd ff ff       	call   801c78 <fsipc>
  801ee1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801ee3:	85 c0                	test   %eax,%eax
  801ee5:	78 0f                	js     801ef6 <open+0x72>
  return fd2num(fd);
  801ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eea:	89 04 24             	mov    %eax,(%esp)
  801eed:	e8 5e f7 ff ff       	call   801650 <fd2num>
  801ef2:	89 c3                	mov    %eax,%ebx
  801ef4:	eb 3b                	jmp    801f31 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801ef6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801efd:	00 
  801efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f01:	89 04 24             	mov    %eax,(%esp)
  801f04:	e8 2b fb ff ff       	call   801a34 <fd_close>
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	74 24                	je     801f31 <open+0xad>
  801f0d:	c7 44 24 0c bc 29 80 	movl   $0x8029bc,0xc(%esp)
  801f14:	00 
  801f15:	c7 44 24 08 d1 29 80 	movl   $0x8029d1,0x8(%esp)
  801f1c:	00 
  801f1d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801f24:	00 
  801f25:	c7 04 24 e6 29 80 00 	movl   $0x8029e6,(%esp)
  801f2c:	e8 0f 00 00 00       	call   801f40 <_panic>
  return r;
}
  801f31:	89 d8                	mov    %ebx,%eax
  801f33:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f36:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f39:	89 ec                	mov    %ebp,%esp
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    
  801f3d:	00 00                	add    %al,(%eax)
	...

00801f40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	56                   	push   %esi
  801f44:	53                   	push   %ebx
  801f45:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801f48:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f4b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801f51:	e8 4e f0 ff ff       	call   800fa4 <sys_getenvid>
  801f56:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f59:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f5d:	8b 55 08             	mov    0x8(%ebp),%edx
  801f60:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6c:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  801f73:	e8 4d e2 ff ff       	call   8001c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f78:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f7c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7f:	89 04 24             	mov    %eax,(%esp)
  801f82:	e8 dd e1 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  801f87:	c7 04 24 b0 29 80 00 	movl   $0x8029b0,(%esp)
  801f8e:	e8 32 e2 ff ff       	call   8001c5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f93:	cc                   	int3   
  801f94:	eb fd                	jmp    801f93 <_panic+0x53>
	...

00801f98 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f98:	55                   	push   %ebp
  801f99:	89 e5                	mov    %esp,%ebp
  801f9b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f9e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fa5:	75 54                	jne    801ffb <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801fa7:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801fae:	00 
  801faf:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801fb6:	ee 
  801fb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fbe:	e8 37 ef ff ff       	call   800efa <sys_page_alloc>
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	79 20                	jns    801fe7 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  801fc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcb:	c7 44 24 08 18 2a 80 	movl   $0x802a18,0x8(%esp)
  801fd2:	00 
  801fd3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801fda:	00 
  801fdb:	c7 04 24 30 2a 80 00 	movl   $0x802a30,(%esp)
  801fe2:	e8 59 ff ff ff       	call   801f40 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  801fe7:	c7 44 24 04 08 20 80 	movl   $0x802008,0x4(%esp)
  801fee:	00 
  801fef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ff6:	e8 e6 ed ff ff       	call   800de1 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffe:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802003:	c9                   	leave  
  802004:	c3                   	ret    
  802005:	00 00                	add    %al,(%eax)
	...

00802008 <_pgfault_upcall>:
  802008:	54                   	push   %esp
  802009:	a1 00 60 80 00       	mov    0x806000,%eax
  80200e:	ff d0                	call   *%eax
  802010:	83 c4 04             	add    $0x4,%esp
  802013:	8b 44 24 30          	mov    0x30(%esp),%eax
  802017:	83 e8 04             	sub    $0x4,%eax
  80201a:	89 44 24 30          	mov    %eax,0x30(%esp)
  80201e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  802022:	89 18                	mov    %ebx,(%eax)
  802024:	83 c4 08             	add    $0x8,%esp
  802027:	61                   	popa   
  802028:	83 c4 04             	add    $0x4,%esp
  80202b:	9d                   	popf   
  80202c:	5c                   	pop    %esp
  80202d:	c3                   	ret    
	...

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	57                   	push   %edi
  802034:	56                   	push   %esi
  802035:	83 ec 10             	sub    $0x10,%esp
  802038:	8b 45 14             	mov    0x14(%ebp),%eax
  80203b:	8b 55 08             	mov    0x8(%ebp),%edx
  80203e:	8b 75 10             	mov    0x10(%ebp),%esi
  802041:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802044:	85 c0                	test   %eax,%eax
  802046:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802049:	75 35                	jne    802080 <__udivdi3+0x50>
  80204b:	39 fe                	cmp    %edi,%esi
  80204d:	77 61                	ja     8020b0 <__udivdi3+0x80>
  80204f:	85 f6                	test   %esi,%esi
  802051:	75 0b                	jne    80205e <__udivdi3+0x2e>
  802053:	b8 01 00 00 00       	mov    $0x1,%eax
  802058:	31 d2                	xor    %edx,%edx
  80205a:	f7 f6                	div    %esi
  80205c:	89 c6                	mov    %eax,%esi
  80205e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802061:	31 d2                	xor    %edx,%edx
  802063:	89 f8                	mov    %edi,%eax
  802065:	f7 f6                	div    %esi
  802067:	89 c7                	mov    %eax,%edi
  802069:	89 c8                	mov    %ecx,%eax
  80206b:	f7 f6                	div    %esi
  80206d:	89 c1                	mov    %eax,%ecx
  80206f:	89 fa                	mov    %edi,%edx
  802071:	89 c8                	mov    %ecx,%eax
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	5e                   	pop    %esi
  802077:	5f                   	pop    %edi
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
  80207a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802080:	39 f8                	cmp    %edi,%eax
  802082:	77 1c                	ja     8020a0 <__udivdi3+0x70>
  802084:	0f bd d0             	bsr    %eax,%edx
  802087:	83 f2 1f             	xor    $0x1f,%edx
  80208a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80208d:	75 39                	jne    8020c8 <__udivdi3+0x98>
  80208f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802092:	0f 86 a0 00 00 00    	jbe    802138 <__udivdi3+0x108>
  802098:	39 f8                	cmp    %edi,%eax
  80209a:	0f 82 98 00 00 00    	jb     802138 <__udivdi3+0x108>
  8020a0:	31 ff                	xor    %edi,%edi
  8020a2:	31 c9                	xor    %ecx,%ecx
  8020a4:	89 c8                	mov    %ecx,%eax
  8020a6:	89 fa                	mov    %edi,%edx
  8020a8:	83 c4 10             	add    $0x10,%esp
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    
  8020af:	90                   	nop
  8020b0:	89 d1                	mov    %edx,%ecx
  8020b2:	89 fa                	mov    %edi,%edx
  8020b4:	89 c8                	mov    %ecx,%eax
  8020b6:	31 ff                	xor    %edi,%edi
  8020b8:	f7 f6                	div    %esi
  8020ba:	89 c1                	mov    %eax,%ecx
  8020bc:	89 fa                	mov    %edi,%edx
  8020be:	89 c8                	mov    %ecx,%eax
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	5e                   	pop    %esi
  8020c4:	5f                   	pop    %edi
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    
  8020c7:	90                   	nop
  8020c8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020cc:	89 f2                	mov    %esi,%edx
  8020ce:	d3 e0                	shl    %cl,%eax
  8020d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8020db:	89 c1                	mov    %eax,%ecx
  8020dd:	d3 ea                	shr    %cl,%edx
  8020df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020e3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8020e6:	d3 e6                	shl    %cl,%esi
  8020e8:	89 c1                	mov    %eax,%ecx
  8020ea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8020ed:	89 fe                	mov    %edi,%esi
  8020ef:	d3 ee                	shr    %cl,%esi
  8020f1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020fb:	d3 e7                	shl    %cl,%edi
  8020fd:	89 c1                	mov    %eax,%ecx
  8020ff:	d3 ea                	shr    %cl,%edx
  802101:	09 d7                	or     %edx,%edi
  802103:	89 f2                	mov    %esi,%edx
  802105:	89 f8                	mov    %edi,%eax
  802107:	f7 75 ec             	divl   -0x14(%ebp)
  80210a:	89 d6                	mov    %edx,%esi
  80210c:	89 c7                	mov    %eax,%edi
  80210e:	f7 65 e8             	mull   -0x18(%ebp)
  802111:	39 d6                	cmp    %edx,%esi
  802113:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802116:	72 30                	jb     802148 <__udivdi3+0x118>
  802118:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80211b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	39 c2                	cmp    %eax,%edx
  802123:	73 05                	jae    80212a <__udivdi3+0xfa>
  802125:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802128:	74 1e                	je     802148 <__udivdi3+0x118>
  80212a:	89 f9                	mov    %edi,%ecx
  80212c:	31 ff                	xor    %edi,%edi
  80212e:	e9 71 ff ff ff       	jmp    8020a4 <__udivdi3+0x74>
  802133:	90                   	nop
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80213f:	e9 60 ff ff ff       	jmp    8020a4 <__udivdi3+0x74>
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80214b:	31 ff                	xor    %edi,%edi
  80214d:	89 c8                	mov    %ecx,%eax
  80214f:	89 fa                	mov    %edi,%edx
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
	...

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	57                   	push   %edi
  802164:	56                   	push   %esi
  802165:	83 ec 20             	sub    $0x20,%esp
  802168:	8b 55 14             	mov    0x14(%ebp),%edx
  80216b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80216e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802171:	8b 75 0c             	mov    0xc(%ebp),%esi
  802174:	85 d2                	test   %edx,%edx
  802176:	89 c8                	mov    %ecx,%eax
  802178:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80217b:	75 13                	jne    802190 <__umoddi3+0x30>
  80217d:	39 f7                	cmp    %esi,%edi
  80217f:	76 3f                	jbe    8021c0 <__umoddi3+0x60>
  802181:	89 f2                	mov    %esi,%edx
  802183:	f7 f7                	div    %edi
  802185:	89 d0                	mov    %edx,%eax
  802187:	31 d2                	xor    %edx,%edx
  802189:	83 c4 20             	add    $0x20,%esp
  80218c:	5e                   	pop    %esi
  80218d:	5f                   	pop    %edi
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    
  802190:	39 f2                	cmp    %esi,%edx
  802192:	77 4c                	ja     8021e0 <__umoddi3+0x80>
  802194:	0f bd ca             	bsr    %edx,%ecx
  802197:	83 f1 1f             	xor    $0x1f,%ecx
  80219a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80219d:	75 51                	jne    8021f0 <__umoddi3+0x90>
  80219f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021a2:	0f 87 e0 00 00 00    	ja     802288 <__umoddi3+0x128>
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	29 f8                	sub    %edi,%eax
  8021ad:	19 d6                	sbb    %edx,%esi
  8021af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b5:	89 f2                	mov    %esi,%edx
  8021b7:	83 c4 20             	add    $0x20,%esp
  8021ba:	5e                   	pop    %esi
  8021bb:	5f                   	pop    %edi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    
  8021be:	66 90                	xchg   %ax,%ax
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	75 0b                	jne    8021cf <__umoddi3+0x6f>
  8021c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c9:	31 d2                	xor    %edx,%edx
  8021cb:	f7 f7                	div    %edi
  8021cd:	89 c7                	mov    %eax,%edi
  8021cf:	89 f0                	mov    %esi,%eax
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	f7 f7                	div    %edi
  8021d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d8:	f7 f7                	div    %edi
  8021da:	eb a9                	jmp    802185 <__umoddi3+0x25>
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 20             	add    $0x20,%esp
  8021e7:	5e                   	pop    %esi
  8021e8:	5f                   	pop    %edi
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    
  8021eb:	90                   	nop
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021f4:	d3 e2                	shl    %cl,%edx
  8021f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8021fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802201:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802204:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802208:	89 fa                	mov    %edi,%edx
  80220a:	d3 ea                	shr    %cl,%edx
  80220c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802210:	0b 55 f4             	or     -0xc(%ebp),%edx
  802213:	d3 e7                	shl    %cl,%edi
  802215:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802219:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80221c:	89 f2                	mov    %esi,%edx
  80221e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802221:	89 c7                	mov    %eax,%edi
  802223:	d3 ea                	shr    %cl,%edx
  802225:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802229:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80222c:	89 c2                	mov    %eax,%edx
  80222e:	d3 e6                	shl    %cl,%esi
  802230:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802234:	d3 ea                	shr    %cl,%edx
  802236:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80223a:	09 d6                	or     %edx,%esi
  80223c:	89 f0                	mov    %esi,%eax
  80223e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802241:	d3 e7                	shl    %cl,%edi
  802243:	89 f2                	mov    %esi,%edx
  802245:	f7 75 f4             	divl   -0xc(%ebp)
  802248:	89 d6                	mov    %edx,%esi
  80224a:	f7 65 e8             	mull   -0x18(%ebp)
  80224d:	39 d6                	cmp    %edx,%esi
  80224f:	72 2b                	jb     80227c <__umoddi3+0x11c>
  802251:	39 c7                	cmp    %eax,%edi
  802253:	72 23                	jb     802278 <__umoddi3+0x118>
  802255:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802259:	29 c7                	sub    %eax,%edi
  80225b:	19 d6                	sbb    %edx,%esi
  80225d:	89 f0                	mov    %esi,%eax
  80225f:	89 f2                	mov    %esi,%edx
  802261:	d3 ef                	shr    %cl,%edi
  802263:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802267:	d3 e0                	shl    %cl,%eax
  802269:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80226d:	09 f8                	or     %edi,%eax
  80226f:	d3 ea                	shr    %cl,%edx
  802271:	83 c4 20             	add    $0x20,%esp
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	39 d6                	cmp    %edx,%esi
  80227a:	75 d9                	jne    802255 <__umoddi3+0xf5>
  80227c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80227f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802282:	eb d1                	jmp    802255 <__umoddi3+0xf5>
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	0f 82 18 ff ff ff    	jb     8021a8 <__umoddi3+0x48>
  802290:	e9 1d ff ff ff       	jmp    8021b2 <__umoddi3+0x52>
