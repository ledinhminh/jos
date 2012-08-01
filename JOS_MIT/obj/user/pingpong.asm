
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
  80003d:	e8 e0 10 00 00       	call   801122 <fork>
  800042:	89 c3                	mov    %eax,%ebx
  800044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800047:	85 c0                	test   %eax,%eax
  800049:	74 3c                	je     800087 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004b:	e8 c7 0f 00 00       	call   801017 <sys_getenvid>
  800050:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 40 28 80 00 	movl   $0x802840,(%esp)
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
  800082:	e8 0d 15 00 00       	call   801594 <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800087:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800099:	00 
  80009a:	89 3c 24             	mov    %edi,(%esp)
  80009d:	e8 5d 15 00 00       	call   8015ff <ipc_recv>
  8000a2:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a7:	e8 6b 0f 00 00       	call   801017 <sys_getenvid>
  8000ac:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b8:	c7 04 24 56 28 80 00 	movl   $0x802856,(%esp)
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
  8000e6:	e8 a9 14 00 00       	call   801594 <ipc_send>
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
  80010a:	e8 08 0f 00 00       	call   801017 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80014e:	e8 26 1a 00 00       	call   801b79 <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 f3 0e 00 00       	call   801052 <sys_env_destroy>
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
  8001b8:	e8 09 0f 00 00       	call   8010c6 <sys_cputs>

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
  80020c:	e8 b5 0e 00 00       	call   8010c6 <sys_cputs>
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
  8002ad:	e8 0e 23 00 00       	call   8025c0 <__udivdi3>
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
  800308:	e8 e3 23 00 00       	call   8026f0 <__umoddi3>
  80030d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800311:	0f be 80 73 28 80 00 	movsbl 0x802873(%eax),%eax
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
  8003f5:	ff 24 95 60 2a 80 00 	jmp    *0x802a60(,%edx,4)
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
  8004c8:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  8004cf:	85 d2                	test   %edx,%edx
  8004d1:	75 20                	jne    8004f3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8004d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d7:	c7 44 24 08 84 28 80 	movl   $0x802884,0x8(%esp)
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
  8004f7:	c7 44 24 08 53 2f 80 	movl   $0x802f53,0x8(%esp)
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
  800531:	b8 8d 28 80 00       	mov    $0x80288d,%eax
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
  800775:	c7 44 24 0c a8 29 80 	movl   $0x8029a8,0xc(%esp)
  80077c:	00 
  80077d:	c7 44 24 08 53 2f 80 	movl   $0x802f53,0x8(%esp)
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
  8007a3:	c7 44 24 0c e0 29 80 	movl   $0x8029e0,0xc(%esp)
  8007aa:	00 
  8007ab:	c7 44 24 08 53 2f 80 	movl   $0x802f53,0x8(%esp)
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
  800d47:	c7 44 24 08 00 2c 80 	movl   $0x802c00,0x8(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d56:	00 
  800d57:	c7 04 24 1d 2c 80 00 	movl   $0x802c1d,(%esp)
  800d5e:	e8 21 17 00 00       	call   802484 <_panic>

	return ret;
}
  800d63:	89 d0                	mov    %edx,%eax
  800d65:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d68:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d6b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6e:	89 ec                	mov    %ebp,%esp
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800d78:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d7f:	00 
  800d80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d87:	00 
  800d88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d8f:	00 
  800d90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d93:	89 04 24             	mov    %eax,(%esp)
  800d96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d99:	ba 00 00 00 00       	mov    $0x0,%edx
  800d9e:	b8 10 00 00 00       	mov    $0x10,%eax
  800da3:	e8 54 ff ff ff       	call   800cfc <syscall>
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800db0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800db7:	00 
  800db8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dc7:	00 
  800dc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd4:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dde:	e8 19 ff ff ff       	call   800cfc <syscall>
}
  800de3:	c9                   	leave  
  800de4:	c3                   	ret    

00800de5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800deb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800df2:	00 
  800df3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dfa:	00 
  800dfb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e02:	00 
  800e03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e12:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e17:	e8 e0 fe ff ff       	call   800cfc <syscall>
}
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e24:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e2b:	00 
  800e2c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e33:	8b 45 10             	mov    0x10(%ebp),%eax
  800e36:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3d:	89 04 24             	mov    %eax,(%esp)
  800e40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4d:	e8 aa fe ff ff       	call   800cfc <syscall>
}
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800e80:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e85:	e8 72 fe ff ff       	call   800cfc <syscall>
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800eb8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ebd:	e8 3a fe ff ff       	call   800cfc <syscall>
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800eca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee1:	00 
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	89 04 24             	mov    %eax,(%esp)
  800ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eeb:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ef5:	e8 02 fe ff ff       	call   800cfc <syscall>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f02:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f09:	00 
  800f0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f19:	00 
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	89 04 24             	mov    %eax,(%esp)
  800f20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f23:	ba 01 00 00 00       	mov    $0x1,%edx
  800f28:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2d:	e8 ca fd ff ff       	call   800cfc <syscall>
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f41:	00 
  800f42:	8b 45 18             	mov    0x18(%ebp),%eax
  800f45:	0b 45 14             	or     0x14(%ebp),%eax
  800f48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f56:	89 04 24             	mov    %eax,(%esp)
  800f59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f61:	b8 06 00 00 00       	mov    $0x6,%eax
  800f66:	e8 91 fd ff ff       	call   800cfc <syscall>
}
  800f6b:	c9                   	leave  
  800f6c:	c3                   	ret    

00800f6d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f6d:	55                   	push   %ebp
  800f6e:	89 e5                	mov    %esp,%ebp
  800f70:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f73:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f82:	00 
  800f83:	8b 45 10             	mov    0x10(%ebp),%eax
  800f86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8d:	89 04 24             	mov    %eax,(%esp)
  800f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f93:	ba 01 00 00 00       	mov    $0x1,%edx
  800f98:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9d:	e8 5a fd ff ff       	call   800cfc <syscall>
}
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800faa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb9:	00 
  800fba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc1:	00 
  800fc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fce:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd8:	e8 1f fd ff ff       	call   800cfc <syscall>
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800fe5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fec:	00 
  800fed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ffc:	00 
  800ffd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801000:	89 04 24             	mov    %eax,(%esp)
  801003:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801006:	ba 00 00 00 00       	mov    $0x0,%edx
  80100b:	b8 04 00 00 00       	mov    $0x4,%eax
  801010:	e8 e7 fc ff ff       	call   800cfc <syscall>
}
  801015:	c9                   	leave  
  801016:	c3                   	ret    

00801017 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80101d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801024:	00 
  801025:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80102c:	00 
  80102d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801034:	00 
  801035:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80103c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801041:	ba 00 00 00 00       	mov    $0x0,%edx
  801046:	b8 02 00 00 00       	mov    $0x2,%eax
  80104b:	e8 ac fc ff ff       	call   800cfc <syscall>
}
  801050:	c9                   	leave  
  801051:	c3                   	ret    

00801052 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801052:	55                   	push   %ebp
  801053:	89 e5                	mov    %esp,%ebp
  801055:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801058:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80105f:	00 
  801060:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801067:	00 
  801068:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80106f:	00 
  801070:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801077:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107a:	ba 01 00 00 00       	mov    $0x1,%edx
  80107f:	b8 03 00 00 00       	mov    $0x3,%eax
  801084:	e8 73 fc ff ff       	call   800cfc <syscall>
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801091:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801098:	00 
  801099:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bf:	e8 38 fc ff ff       	call   800cfc <syscall>
}
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d3:	00 
  8010d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010db:	00 
  8010dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e3:	00 
  8010e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e7:	89 04 24             	mov    %eax,(%esp)
  8010ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f7:	e8 00 fc ff ff       	call   800cfc <syscall>
}
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    
	...

00801100 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801106:	c7 44 24 08 2b 2c 80 	movl   $0x802c2b,0x8(%esp)
  80110d:	00 
  80110e:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801115:	00 
  801116:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80111d:	e8 62 13 00 00       	call   802484 <_panic>

00801122 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801122:	55                   	push   %ebp
  801123:	89 e5                	mov    %esp,%ebp
  801125:	57                   	push   %edi
  801126:	56                   	push   %esi
  801127:	53                   	push   %ebx
  801128:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  80112b:	c7 04 24 e6 13 80 00 	movl   $0x8013e6,(%esp)
  801132:	e8 a5 13 00 00       	call   8024dc <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801137:	ba 08 00 00 00       	mov    $0x8,%edx
  80113c:	89 d0                	mov    %edx,%eax
  80113e:	51                   	push   %ecx
  80113f:	52                   	push   %edx
  801140:	53                   	push   %ebx
  801141:	55                   	push   %ebp
  801142:	56                   	push   %esi
  801143:	57                   	push   %edi
  801144:	89 e5                	mov    %esp,%ebp
  801146:	8d 35 4e 11 80 00    	lea    0x80114e,%esi
  80114c:	0f 34                	sysenter 

0080114e <.after_sysenter_label>:
  80114e:	5f                   	pop    %edi
  80114f:	5e                   	pop    %esi
  801150:	5d                   	pop    %ebp
  801151:	5b                   	pop    %ebx
  801152:	5a                   	pop    %edx
  801153:	59                   	pop    %ecx
  801154:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  801162:	00 
  801163:	c7 44 24 04 41 2c 80 	movl   $0x802c41,0x4(%esp)
  80116a:	00 
  80116b:	c7 04 24 88 2c 80 00 	movl   $0x802c88,(%esp)
  801172:	e8 4e f0 ff ff       	call   8001c5 <cprintf>
	if (envidnum < 0)
  801177:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80117b:	79 23                	jns    8011a0 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80117d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801180:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801184:	c7 44 24 08 4c 2c 80 	movl   $0x802c4c,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801193:	00 
  801194:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80119b:	e8 e4 12 00 00       	call   802484 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8011a0:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8011a5:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8011aa:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  8011af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011b3:	75 1c                	jne    8011d1 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011b5:	e8 5d fe ff ff       	call   801017 <sys_getenvid>
  8011ba:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011bf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c7:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8011cc:	e9 0a 02 00 00       	jmp    8013db <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8011d1:	89 d8                	mov    %ebx,%eax
  8011d3:	c1 e8 16             	shr    $0x16,%eax
  8011d6:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8011d9:	a8 01                	test   $0x1,%al
  8011db:	0f 84 43 01 00 00    	je     801324 <.after_sysenter_label+0x1d6>
  8011e1:	89 d8                	mov    %ebx,%eax
  8011e3:	c1 e8 0c             	shr    $0xc,%eax
  8011e6:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8011e9:	f6 c2 01             	test   $0x1,%dl
  8011ec:	0f 84 32 01 00 00    	je     801324 <.after_sysenter_label+0x1d6>
  8011f2:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8011f5:	f6 c2 04             	test   $0x4,%dl
  8011f8:	0f 84 26 01 00 00    	je     801324 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  8011fe:	c1 e0 0c             	shl    $0xc,%eax
  801201:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801204:	c1 e8 0c             	shr    $0xc,%eax
  801207:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  801212:	a9 02 08 00 00       	test   $0x802,%eax
  801217:	0f 84 a0 00 00 00    	je     8012bd <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  80121d:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  801220:	80 ce 08             	or     $0x8,%dh
  801223:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801226:	89 54 24 10          	mov    %edx,0x10(%esp)
  80122a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80122d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801231:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801234:	89 44 24 08          	mov    %eax,0x8(%esp)
  801238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80123b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801246:	e8 e9 fc ff ff       	call   800f34 <sys_page_map>
  80124b:	85 c0                	test   %eax,%eax
  80124d:	79 20                	jns    80126f <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80124f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801253:	c7 44 24 08 b0 2c 80 	movl   $0x802cb0,0x8(%esp)
  80125a:	00 
  80125b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801262:	00 
  801263:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80126a:	e8 15 12 00 00       	call   802484 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80126f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801272:	89 44 24 10          	mov    %eax,0x10(%esp)
  801276:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801279:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801284:	00 
  801285:	89 44 24 04          	mov    %eax,0x4(%esp)
  801289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801290:	e8 9f fc ff ff       	call   800f34 <sys_page_map>
  801295:	85 c0                	test   %eax,%eax
  801297:	0f 89 87 00 00 00    	jns    801324 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  80129d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a1:	c7 44 24 08 dc 2c 80 	movl   $0x802cdc,0x8(%esp)
  8012a8:	00 
  8012a9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8012b0:	00 
  8012b1:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  8012b8:	e8 c7 11 00 00       	call   802484 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  8012bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cb:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8012d2:	e8 ee ee ff ff       	call   8001c5 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  8012d7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012de:	00 
  8012df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012fb:	e8 34 fc ff ff       	call   800f34 <sys_page_map>
  801300:	85 c0                	test   %eax,%eax
  801302:	79 20                	jns    801324 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801304:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801308:	c7 44 24 08 08 2d 80 	movl   $0x802d08,0x8(%esp)
  80130f:	00 
  801310:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801317:	00 
  801318:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80131f:	e8 60 11 00 00       	call   802484 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801324:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80132a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801330:	0f 85 9b fe ff ff    	jne    8011d1 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801336:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80133d:	00 
  80133e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801345:	ee 
  801346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801349:	89 04 24             	mov    %eax,(%esp)
  80134c:	e8 1c fc ff ff       	call   800f6d <sys_page_alloc>
  801351:	85 c0                	test   %eax,%eax
  801353:	79 20                	jns    801375 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801355:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801359:	c7 44 24 08 34 2d 80 	movl   $0x802d34,0x8(%esp)
  801360:	00 
  801361:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801368:	00 
  801369:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  801370:	e8 0f 11 00 00       	call   802484 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801375:	c7 44 24 04 4c 25 80 	movl   $0x80254c,0x4(%esp)
  80137c:	00 
  80137d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801380:	89 04 24             	mov    %eax,(%esp)
  801383:	e8 cc fa ff ff       	call   800e54 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801388:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80138f:	00 
  801390:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801393:	89 04 24             	mov    %eax,(%esp)
  801396:	e8 29 fb ff ff       	call   800ec4 <sys_env_set_status>
  80139b:	85 c0                	test   %eax,%eax
  80139d:	79 20                	jns    8013bf <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80139f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a3:	c7 44 24 08 58 2d 80 	movl   $0x802d58,0x8(%esp)
  8013aa:	00 
  8013ab:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8013b2:	00 
  8013b3:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  8013ba:	e8 c5 10 00 00       	call   802484 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  8013bf:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  8013c6:	00 
  8013c7:	c7 44 24 04 41 2c 80 	movl   $0x802c41,0x4(%esp)
  8013ce:	00 
  8013cf:	c7 04 24 6e 2c 80 00 	movl   $0x802c6e,(%esp)
  8013d6:	e8 ea ed ff ff       	call   8001c5 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  8013db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013de:	83 c4 3c             	add    $0x3c,%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 24             	sub    $0x24,%esp
  8013ed:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8013f0:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8013f2:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  8013f5:	f6 c2 02             	test   $0x2,%dl
  8013f8:	75 2b                	jne    801425 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  8013fa:	8b 40 28             	mov    0x28(%eax),%eax
  8013fd:	89 44 24 14          	mov    %eax,0x14(%esp)
  801401:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801405:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801409:	c7 44 24 08 80 2d 80 	movl   $0x802d80,0x8(%esp)
  801410:	00 
  801411:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801418:	00 
  801419:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  801420:	e8 5f 10 00 00       	call   802484 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801425:	89 d8                	mov    %ebx,%eax
  801427:	c1 e8 16             	shr    $0x16,%eax
  80142a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801431:	a8 01                	test   $0x1,%al
  801433:	74 11                	je     801446 <pgfault+0x60>
  801435:	89 d8                	mov    %ebx,%eax
  801437:	c1 e8 0c             	shr    $0xc,%eax
  80143a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801441:	f6 c4 08             	test   $0x8,%ah
  801444:	75 1c                	jne    801462 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  801446:	c7 44 24 08 bc 2d 80 	movl   $0x802dbc,0x8(%esp)
  80144d:	00 
  80144e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801455:	00 
  801456:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80145d:	e8 22 10 00 00       	call   802484 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801462:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801469:	00 
  80146a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801471:	00 
  801472:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801479:	e8 ef fa ff ff       	call   800f6d <sys_page_alloc>
  80147e:	85 c0                	test   %eax,%eax
  801480:	79 20                	jns    8014a2 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  801482:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801486:	c7 44 24 08 f8 2d 80 	movl   $0x802df8,0x8(%esp)
  80148d:	00 
  80148e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801495:	00 
  801496:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80149d:	e8 e2 0f 00 00       	call   802484 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  8014a2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  8014a8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014af:	00 
  8014b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014b4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8014bb:	e8 35 f6 ff ff       	call   800af5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  8014c0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8014c7:	00 
  8014c8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014cc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014d3:	00 
  8014d4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014db:	00 
  8014dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e3:	e8 4c fa ff ff       	call   800f34 <sys_page_map>
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	79 20                	jns    80150c <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  8014ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f0:	c7 44 24 08 20 2e 80 	movl   $0x802e20,0x8(%esp)
  8014f7:	00 
  8014f8:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8014ff:	00 
  801500:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  801507:	e8 78 0f 00 00       	call   802484 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  80150c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801513:	00 
  801514:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151b:	e8 dc f9 ff ff       	call   800efc <sys_page_unmap>
  801520:	85 c0                	test   %eax,%eax
  801522:	79 20                	jns    801544 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  801524:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801528:	c7 44 24 08 44 2e 80 	movl   $0x802e44,0x8(%esp)
  80152f:	00 
  801530:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801537:	00 
  801538:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80153f:	e8 40 0f 00 00       	call   802484 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801544:	83 c4 24             	add    $0x24,%esp
  801547:	5b                   	pop    %ebx
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    
  80154a:	00 00                	add    %al,(%eax)
  80154c:	00 00                	add    %al,(%eax)
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
  8015b0:	eb 25                	jmp    8015d7 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8015b2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8015b5:	74 20                	je     8015d7 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8015b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015bb:	c7 44 24 08 68 2e 80 	movl   $0x802e68,0x8(%esp)
  8015c2:	00 
  8015c3:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8015ca:	00 
  8015cb:	c7 04 24 86 2e 80 00 	movl   $0x802e86,(%esp)
  8015d2:	e8 ad 0e 00 00       	call   802484 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8015d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015da:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8015e6:	89 34 24             	mov    %esi,(%esp)
  8015e9:	e8 30 f8 ff ff       	call   800e1e <sys_ipc_try_send>
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	75 c0                	jne    8015b2 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8015f2:	e8 ad f9 ff ff       	call   800fa4 <sys_yield>
}
  8015f7:	83 c4 1c             	add    $0x1c,%esp
  8015fa:	5b                   	pop    %ebx
  8015fb:	5e                   	pop    %esi
  8015fc:	5f                   	pop    %edi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    

008015ff <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 28             	sub    $0x28,%esp
  801605:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801608:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80160b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80160e:	8b 75 08             	mov    0x8(%ebp),%esi
  801611:	8b 45 0c             	mov    0xc(%ebp),%eax
  801614:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801617:	85 c0                	test   %eax,%eax
  801619:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80161e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801621:	89 04 24             	mov    %eax,(%esp)
  801624:	e8 bc f7 ff ff       	call   800de5 <sys_ipc_recv>
  801629:	89 c3                	mov    %eax,%ebx
  80162b:	85 c0                	test   %eax,%eax
  80162d:	79 2a                	jns    801659 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80162f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801633:	89 44 24 04          	mov    %eax,0x4(%esp)
  801637:	c7 04 24 90 2e 80 00 	movl   $0x802e90,(%esp)
  80163e:	e8 82 eb ff ff       	call   8001c5 <cprintf>
		if(from_env_store != NULL)
  801643:	85 f6                	test   %esi,%esi
  801645:	74 06                	je     80164d <ipc_recv+0x4e>
			*from_env_store = 0;
  801647:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80164d:	85 ff                	test   %edi,%edi
  80164f:	74 2c                	je     80167d <ipc_recv+0x7e>
			*perm_store = 0;
  801651:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801657:	eb 24                	jmp    80167d <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801659:	85 f6                	test   %esi,%esi
  80165b:	74 0a                	je     801667 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  80165d:	a1 08 40 80 00       	mov    0x804008,%eax
  801662:	8b 40 74             	mov    0x74(%eax),%eax
  801665:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801667:	85 ff                	test   %edi,%edi
  801669:	74 0a                	je     801675 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  80166b:	a1 08 40 80 00       	mov    0x804008,%eax
  801670:	8b 40 78             	mov    0x78(%eax),%eax
  801673:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801675:	a1 08 40 80 00       	mov    0x804008,%eax
  80167a:	8b 58 70             	mov    0x70(%eax),%ebx
}
  80167d:	89 d8                	mov    %ebx,%eax
  80167f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801682:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801685:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801688:	89 ec                	mov    %ebp,%esp
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    
  80168c:	00 00                	add    %al,(%eax)
	...

00801690 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	8b 45 08             	mov    0x8(%ebp),%eax
  801696:	05 00 00 00 30       	add    $0x30000000,%eax
  80169b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a9:	89 04 24             	mov    %eax,(%esp)
  8016ac:	e8 df ff ff ff       	call   801690 <fd2num>
  8016b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	57                   	push   %edi
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016c9:	a8 01                	test   $0x1,%al
  8016cb:	74 36                	je     801703 <fd_alloc+0x48>
  8016cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016d2:	a8 01                	test   $0x1,%al
  8016d4:	74 2d                	je     801703 <fd_alloc+0x48>
  8016d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016e5:	89 c3                	mov    %eax,%ebx
  8016e7:	89 c2                	mov    %eax,%edx
  8016e9:	c1 ea 16             	shr    $0x16,%edx
  8016ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016ef:	f6 c2 01             	test   $0x1,%dl
  8016f2:	74 14                	je     801708 <fd_alloc+0x4d>
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	c1 ea 0c             	shr    $0xc,%edx
  8016f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8016fc:	f6 c2 01             	test   $0x1,%dl
  8016ff:	75 10                	jne    801711 <fd_alloc+0x56>
  801701:	eb 05                	jmp    801708 <fd_alloc+0x4d>
  801703:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801708:	89 1f                	mov    %ebx,(%edi)
  80170a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80170f:	eb 17                	jmp    801728 <fd_alloc+0x6d>
  801711:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801716:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80171b:	75 c8                	jne    8016e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80171d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801723:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5f                   	pop    %edi
  80172b:	5d                   	pop    %ebp
  80172c:	c3                   	ret    

0080172d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801730:	8b 45 08             	mov    0x8(%ebp),%eax
  801733:	83 f8 1f             	cmp    $0x1f,%eax
  801736:	77 36                	ja     80176e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801738:	05 00 00 0d 00       	add    $0xd0000,%eax
  80173d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801740:	89 c2                	mov    %eax,%edx
  801742:	c1 ea 16             	shr    $0x16,%edx
  801745:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80174c:	f6 c2 01             	test   $0x1,%dl
  80174f:	74 1d                	je     80176e <fd_lookup+0x41>
  801751:	89 c2                	mov    %eax,%edx
  801753:	c1 ea 0c             	shr    $0xc,%edx
  801756:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80175d:	f6 c2 01             	test   $0x1,%dl
  801760:	74 0c                	je     80176e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801762:	8b 55 0c             	mov    0xc(%ebp),%edx
  801765:	89 02                	mov    %eax,(%edx)
  801767:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80176c:	eb 05                	jmp    801773 <fd_lookup+0x46>
  80176e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801773:	5d                   	pop    %ebp
  801774:	c3                   	ret    

00801775 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801775:	55                   	push   %ebp
  801776:	89 e5                	mov    %esp,%ebp
  801778:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80177b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80177e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	89 04 24             	mov    %eax,(%esp)
  801788:	e8 a0 ff ff ff       	call   80172d <fd_lookup>
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 0e                	js     80179f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801791:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801794:	8b 55 0c             	mov    0xc(%ebp),%edx
  801797:	89 50 04             	mov    %edx,0x4(%eax)
  80179a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 10             	sub    $0x10,%esp
  8017a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017af:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8017b4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8017b9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8017bf:	75 11                	jne    8017d2 <dev_lookup+0x31>
  8017c1:	eb 04                	jmp    8017c7 <dev_lookup+0x26>
  8017c3:	39 08                	cmp    %ecx,(%eax)
  8017c5:	75 10                	jne    8017d7 <dev_lookup+0x36>
			*dev = devtab[i];
  8017c7:	89 03                	mov    %eax,(%ebx)
  8017c9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017ce:	66 90                	xchg   %ax,%ax
  8017d0:	eb 36                	jmp    801808 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017d2:	be 20 2f 80 00       	mov    $0x802f20,%esi
  8017d7:	83 c2 01             	add    $0x1,%edx
  8017da:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	75 e2                	jne    8017c3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8017e6:	8b 40 48             	mov    0x48(%eax),%eax
  8017e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f1:	c7 04 24 a4 2e 80 00 	movl   $0x802ea4,(%esp)
  8017f8:	e8 c8 e9 ff ff       	call   8001c5 <cprintf>
	*dev = 0;
  8017fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801803:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	5b                   	pop    %ebx
  80180c:	5e                   	pop    %esi
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	53                   	push   %ebx
  801813:	83 ec 24             	sub    $0x24,%esp
  801816:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801819:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80181c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	89 04 24             	mov    %eax,(%esp)
  801826:	e8 02 ff ff ff       	call   80172d <fd_lookup>
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 53                	js     801882 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80182f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801832:	89 44 24 04          	mov    %eax,0x4(%esp)
  801836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801839:	8b 00                	mov    (%eax),%eax
  80183b:	89 04 24             	mov    %eax,(%esp)
  80183e:	e8 5e ff ff ff       	call   8017a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801843:	85 c0                	test   %eax,%eax
  801845:	78 3b                	js     801882 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801847:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80184c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801853:	74 2d                	je     801882 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801855:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801858:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80185f:	00 00 00 
	stat->st_isdir = 0;
  801862:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801869:	00 00 00 
	stat->st_dev = dev;
  80186c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80186f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801875:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801879:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80187c:	89 14 24             	mov    %edx,(%esp)
  80187f:	ff 50 14             	call   *0x14(%eax)
}
  801882:	83 c4 24             	add    $0x24,%esp
  801885:	5b                   	pop    %ebx
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	53                   	push   %ebx
  80188c:	83 ec 24             	sub    $0x24,%esp
  80188f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801892:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801895:	89 44 24 04          	mov    %eax,0x4(%esp)
  801899:	89 1c 24             	mov    %ebx,(%esp)
  80189c:	e8 8c fe ff ff       	call   80172d <fd_lookup>
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 5f                	js     801904 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018af:	8b 00                	mov    (%eax),%eax
  8018b1:	89 04 24             	mov    %eax,(%esp)
  8018b4:	e8 e8 fe ff ff       	call   8017a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	78 47                	js     801904 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018c0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018c4:	75 23                	jne    8018e9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018c6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018cb:	8b 40 48             	mov    0x48(%eax),%eax
  8018ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d6:	c7 04 24 c4 2e 80 00 	movl   $0x802ec4,(%esp)
  8018dd:	e8 e3 e8 ff ff       	call   8001c5 <cprintf>
  8018e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018e7:	eb 1b                	jmp    801904 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ec:	8b 48 18             	mov    0x18(%eax),%ecx
  8018ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018f4:	85 c9                	test   %ecx,%ecx
  8018f6:	74 0c                	je     801904 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ff:	89 14 24             	mov    %edx,(%esp)
  801902:	ff d1                	call   *%ecx
}
  801904:	83 c4 24             	add    $0x24,%esp
  801907:	5b                   	pop    %ebx
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	53                   	push   %ebx
  80190e:	83 ec 24             	sub    $0x24,%esp
  801911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801914:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191b:	89 1c 24             	mov    %ebx,(%esp)
  80191e:	e8 0a fe ff ff       	call   80172d <fd_lookup>
  801923:	85 c0                	test   %eax,%eax
  801925:	78 66                	js     80198d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801927:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801931:	8b 00                	mov    (%eax),%eax
  801933:	89 04 24             	mov    %eax,(%esp)
  801936:	e8 66 fe ff ff       	call   8017a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 4e                	js     80198d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80193f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801942:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801946:	75 23                	jne    80196b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801948:	a1 08 40 80 00       	mov    0x804008,%eax
  80194d:	8b 40 48             	mov    0x48(%eax),%eax
  801950:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801954:	89 44 24 04          	mov    %eax,0x4(%esp)
  801958:	c7 04 24 e5 2e 80 00 	movl   $0x802ee5,(%esp)
  80195f:	e8 61 e8 ff ff       	call   8001c5 <cprintf>
  801964:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801969:	eb 22                	jmp    80198d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80196b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801971:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801976:	85 c9                	test   %ecx,%ecx
  801978:	74 13                	je     80198d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80197a:	8b 45 10             	mov    0x10(%ebp),%eax
  80197d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801981:	8b 45 0c             	mov    0xc(%ebp),%eax
  801984:	89 44 24 04          	mov    %eax,0x4(%esp)
  801988:	89 14 24             	mov    %edx,(%esp)
  80198b:	ff d1                	call   *%ecx
}
  80198d:	83 c4 24             	add    $0x24,%esp
  801990:	5b                   	pop    %ebx
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	53                   	push   %ebx
  801997:	83 ec 24             	sub    $0x24,%esp
  80199a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80199d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a4:	89 1c 24             	mov    %ebx,(%esp)
  8019a7:	e8 81 fd ff ff       	call   80172d <fd_lookup>
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	78 6b                	js     801a1b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ba:	8b 00                	mov    (%eax),%eax
  8019bc:	89 04 24             	mov    %eax,(%esp)
  8019bf:	e8 dd fd ff ff       	call   8017a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 53                	js     801a1b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019cb:	8b 42 08             	mov    0x8(%edx),%eax
  8019ce:	83 e0 03             	and    $0x3,%eax
  8019d1:	83 f8 01             	cmp    $0x1,%eax
  8019d4:	75 23                	jne    8019f9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019d6:	a1 08 40 80 00       	mov    0x804008,%eax
  8019db:	8b 40 48             	mov    0x48(%eax),%eax
  8019de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e6:	c7 04 24 02 2f 80 00 	movl   $0x802f02,(%esp)
  8019ed:	e8 d3 e7 ff ff       	call   8001c5 <cprintf>
  8019f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019f7:	eb 22                	jmp    801a1b <read+0x88>
	}
	if (!dev->dev_read)
  8019f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019fc:	8b 48 08             	mov    0x8(%eax),%ecx
  8019ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a04:	85 c9                	test   %ecx,%ecx
  801a06:	74 13                	je     801a1b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a08:	8b 45 10             	mov    0x10(%ebp),%eax
  801a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a16:	89 14 24             	mov    %edx,(%esp)
  801a19:	ff d1                	call   *%ecx
}
  801a1b:	83 c4 24             	add    $0x24,%esp
  801a1e:	5b                   	pop    %ebx
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	57                   	push   %edi
  801a25:	56                   	push   %esi
  801a26:	53                   	push   %ebx
  801a27:	83 ec 1c             	sub    $0x1c,%esp
  801a2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
  801a35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3f:	85 f6                	test   %esi,%esi
  801a41:	74 29                	je     801a6c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a43:	89 f0                	mov    %esi,%eax
  801a45:	29 d0                	sub    %edx,%eax
  801a47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a4b:	03 55 0c             	add    0xc(%ebp),%edx
  801a4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a52:	89 3c 24             	mov    %edi,(%esp)
  801a55:	e8 39 ff ff ff       	call   801993 <read>
		if (m < 0)
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 0e                	js     801a6c <readn+0x4b>
			return m;
		if (m == 0)
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	74 08                	je     801a6a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a62:	01 c3                	add    %eax,%ebx
  801a64:	89 da                	mov    %ebx,%edx
  801a66:	39 f3                	cmp    %esi,%ebx
  801a68:	72 d9                	jb     801a43 <readn+0x22>
  801a6a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a6c:	83 c4 1c             	add    $0x1c,%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	83 ec 28             	sub    $0x28,%esp
  801a7a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a7d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a80:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a83:	89 34 24             	mov    %esi,(%esp)
  801a86:	e8 05 fc ff ff       	call   801690 <fd2num>
  801a8b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 93 fc ff ff       	call   80172d <fd_lookup>
  801a9a:	89 c3                	mov    %eax,%ebx
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	78 05                	js     801aa5 <fd_close+0x31>
  801aa0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801aa3:	74 0e                	je     801ab3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801aa5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801aa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aae:	0f 44 d8             	cmove  %eax,%ebx
  801ab1:	eb 3d                	jmp    801af0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ab3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aba:	8b 06                	mov    (%esi),%eax
  801abc:	89 04 24             	mov    %eax,(%esp)
  801abf:	e8 dd fc ff ff       	call   8017a1 <dev_lookup>
  801ac4:	89 c3                	mov    %eax,%ebx
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 16                	js     801ae0 <fd_close+0x6c>
		if (dev->dev_close)
  801aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801acd:	8b 40 10             	mov    0x10(%eax),%eax
  801ad0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ad5:	85 c0                	test   %eax,%eax
  801ad7:	74 07                	je     801ae0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801ad9:	89 34 24             	mov    %esi,(%esp)
  801adc:	ff d0                	call   *%eax
  801ade:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ae0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ae4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aeb:	e8 0c f4 ff ff       	call   800efc <sys_page_unmap>
	return r;
}
  801af0:	89 d8                	mov    %ebx,%eax
  801af2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801af5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801af8:	89 ec                	mov    %ebp,%esp
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 19 fc ff ff       	call   80172d <fd_lookup>
  801b14:	85 c0                	test   %eax,%eax
  801b16:	78 13                	js     801b2b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b1f:	00 
  801b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 49 ff ff ff       	call   801a74 <fd_close>
}
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 18             	sub    $0x18,%esp
  801b33:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b36:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b40:	00 
  801b41:	8b 45 08             	mov    0x8(%ebp),%eax
  801b44:	89 04 24             	mov    %eax,(%esp)
  801b47:	e8 78 03 00 00       	call   801ec4 <open>
  801b4c:	89 c3                	mov    %eax,%ebx
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 1b                	js     801b6d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b59:	89 1c 24             	mov    %ebx,(%esp)
  801b5c:	e8 ae fc ff ff       	call   80180f <fstat>
  801b61:	89 c6                	mov    %eax,%esi
	close(fd);
  801b63:	89 1c 24             	mov    %ebx,(%esp)
  801b66:	e8 91 ff ff ff       	call   801afc <close>
  801b6b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b6d:	89 d8                	mov    %ebx,%eax
  801b6f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b72:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b75:	89 ec                	mov    %ebp,%esp
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b79:	55                   	push   %ebp
  801b7a:	89 e5                	mov    %esp,%ebp
  801b7c:	53                   	push   %ebx
  801b7d:	83 ec 14             	sub    $0x14,%esp
  801b80:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b85:	89 1c 24             	mov    %ebx,(%esp)
  801b88:	e8 6f ff ff ff       	call   801afc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b8d:	83 c3 01             	add    $0x1,%ebx
  801b90:	83 fb 20             	cmp    $0x20,%ebx
  801b93:	75 f0                	jne    801b85 <close_all+0xc>
		close(i);
}
  801b95:	83 c4 14             	add    $0x14,%esp
  801b98:	5b                   	pop    %ebx
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	83 ec 58             	sub    $0x58,%esp
  801ba1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ba4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ba7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801baa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb7:	89 04 24             	mov    %eax,(%esp)
  801bba:	e8 6e fb ff ff       	call   80172d <fd_lookup>
  801bbf:	89 c3                	mov    %eax,%ebx
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	0f 88 e0 00 00 00    	js     801ca9 <dup+0x10e>
		return r;
	close(newfdnum);
  801bc9:	89 3c 24             	mov    %edi,(%esp)
  801bcc:	e8 2b ff ff ff       	call   801afc <close>

	newfd = INDEX2FD(newfdnum);
  801bd1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801bd7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bdd:	89 04 24             	mov    %eax,(%esp)
  801be0:	e8 bb fa ff ff       	call   8016a0 <fd2data>
  801be5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801be7:	89 34 24             	mov    %esi,(%esp)
  801bea:	e8 b1 fa ff ff       	call   8016a0 <fd2data>
  801bef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801bf2:	89 da                	mov    %ebx,%edx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	c1 e8 16             	shr    $0x16,%eax
  801bf9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c00:	a8 01                	test   $0x1,%al
  801c02:	74 43                	je     801c47 <dup+0xac>
  801c04:	c1 ea 0c             	shr    $0xc,%edx
  801c07:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c0e:	a8 01                	test   $0x1,%al
  801c10:	74 35                	je     801c47 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c12:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c19:	25 07 0e 00 00       	and    $0xe07,%eax
  801c1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c29:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c30:	00 
  801c31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c3c:	e8 f3 f2 ff ff       	call   800f34 <sys_page_map>
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 3f                	js     801c86 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	c1 ea 0c             	shr    $0xc,%edx
  801c4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c56:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c5c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c60:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c6b:	00 
  801c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c77:	e8 b8 f2 ff ff       	call   800f34 <sys_page_map>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 04                	js     801c86 <dup+0xeb>
  801c82:	89 fb                	mov    %edi,%ebx
  801c84:	eb 23                	jmp    801ca9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c91:	e8 66 f2 ff ff       	call   800efc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801c96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca4:	e8 53 f2 ff ff       	call   800efc <sys_page_unmap>
	return r;
}
  801ca9:	89 d8                	mov    %ebx,%eax
  801cab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cb1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cb4:	89 ec                	mov    %ebp,%esp
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    

00801cb8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	83 ec 18             	sub    $0x18,%esp
  801cbe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cc1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cc4:	89 c3                	mov    %eax,%ebx
  801cc6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cc8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801ccf:	75 11                	jne    801ce2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801cd1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801cd8:	e8 73 f8 ff ff       	call   801550 <ipc_find_env>
  801cdd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ce2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ce9:	00 
  801cea:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801cf1:	00 
  801cf2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf6:	a1 00 40 80 00       	mov    0x804000,%eax
  801cfb:	89 04 24             	mov    %eax,(%esp)
  801cfe:	e8 91 f8 ff ff       	call   801594 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d0a:	00 
  801d0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d16:	e8 e4 f8 ff ff       	call   8015ff <ipc_recv>
}
  801d1b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d1e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d21:	89 ec                	mov    %ebp,%esp
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d31:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d39:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d43:	b8 02 00 00 00       	mov    $0x2,%eax
  801d48:	e8 6b ff ff ff       	call   801cb8 <fsipc>
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    

00801d4f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	8b 40 0c             	mov    0xc(%eax),%eax
  801d5b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d60:	ba 00 00 00 00       	mov    $0x0,%edx
  801d65:	b8 06 00 00 00       	mov    $0x6,%eax
  801d6a:	e8 49 ff ff ff       	call   801cb8 <fsipc>
}
  801d6f:	c9                   	leave  
  801d70:	c3                   	ret    

00801d71 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d77:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7c:	b8 08 00 00 00       	mov    $0x8,%eax
  801d81:	e8 32 ff ff ff       	call   801cb8 <fsipc>
}
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	53                   	push   %ebx
  801d8c:	83 ec 14             	sub    $0x14,%esp
  801d8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	8b 40 0c             	mov    0xc(%eax),%eax
  801d98:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801da2:	b8 05 00 00 00       	mov    $0x5,%eax
  801da7:	e8 0c ff ff ff       	call   801cb8 <fsipc>
  801dac:	85 c0                	test   %eax,%eax
  801dae:	78 2b                	js     801ddb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801db0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801db7:	00 
  801db8:	89 1c 24             	mov    %ebx,(%esp)
  801dbb:	e8 4a eb ff ff       	call   80090a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801dc0:	a1 80 50 80 00       	mov    0x805080,%eax
  801dc5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801dcb:	a1 84 50 80 00       	mov    0x805084,%eax
  801dd0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801dd6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801ddb:	83 c4 14             	add    $0x14,%esp
  801dde:	5b                   	pop    %ebx
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    

00801de1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	83 ec 18             	sub    $0x18,%esp
  801de7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dea:	8b 55 08             	mov    0x8(%ebp),%edx
  801ded:	8b 52 0c             	mov    0xc(%edx),%edx
  801df0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801df6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801dfb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e00:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e05:	0f 47 c2             	cmova  %edx,%eax
  801e08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e13:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801e1a:	e8 d6 ec ff ff       	call   800af5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801e1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e24:	b8 04 00 00 00       	mov    $0x4,%eax
  801e29:	e8 8a fe ff ff       	call   801cb8 <fsipc>
}
  801e2e:	c9                   	leave  
  801e2f:	c3                   	ret    

00801e30 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	53                   	push   %ebx
  801e34:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e37:	8b 45 08             	mov    0x8(%ebp),%eax
  801e3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e3d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801e42:	8b 45 10             	mov    0x10(%ebp),%eax
  801e45:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e4f:	b8 03 00 00 00       	mov    $0x3,%eax
  801e54:	e8 5f fe ff ff       	call   801cb8 <fsipc>
  801e59:	89 c3                	mov    %eax,%ebx
  801e5b:	85 c0                	test   %eax,%eax
  801e5d:	78 17                	js     801e76 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e63:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e6a:	00 
  801e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 7f ec ff ff       	call   800af5 <memmove>
  return r;	
}
  801e76:	89 d8                	mov    %ebx,%eax
  801e78:	83 c4 14             	add    $0x14,%esp
  801e7b:	5b                   	pop    %ebx
  801e7c:	5d                   	pop    %ebp
  801e7d:	c3                   	ret    

00801e7e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
  801e81:	53                   	push   %ebx
  801e82:	83 ec 14             	sub    $0x14,%esp
  801e85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e88:	89 1c 24             	mov    %ebx,(%esp)
  801e8b:	e8 30 ea ff ff       	call   8008c0 <strlen>
  801e90:	89 c2                	mov    %eax,%edx
  801e92:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801e97:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801e9d:	7f 1f                	jg     801ebe <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801e9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ea3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801eaa:	e8 5b ea ff ff       	call   80090a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801eaf:	ba 00 00 00 00       	mov    $0x0,%edx
  801eb4:	b8 07 00 00 00       	mov    $0x7,%eax
  801eb9:	e8 fa fd ff ff       	call   801cb8 <fsipc>
}
  801ebe:	83 c4 14             	add    $0x14,%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5d                   	pop    %ebp
  801ec3:	c3                   	ret    

00801ec4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 28             	sub    $0x28,%esp
  801eca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ecd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ed0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed6:	89 04 24             	mov    %eax,(%esp)
  801ed9:	e8 dd f7 ff ff       	call   8016bb <fd_alloc>
  801ede:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801ee0:	85 c0                	test   %eax,%eax
  801ee2:	0f 88 89 00 00 00    	js     801f71 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801ee8:	89 34 24             	mov    %esi,(%esp)
  801eeb:	e8 d0 e9 ff ff       	call   8008c0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801ef0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801ef5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801efa:	7f 75                	jg     801f71 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801efc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f00:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f07:	e8 fe e9 ff ff       	call   80090a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801f0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801f14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f17:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1c:	e8 97 fd ff ff       	call   801cb8 <fsipc>
  801f21:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801f23:	85 c0                	test   %eax,%eax
  801f25:	78 0f                	js     801f36 <open+0x72>
  return fd2num(fd);
  801f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2a:	89 04 24             	mov    %eax,(%esp)
  801f2d:	e8 5e f7 ff ff       	call   801690 <fd2num>
  801f32:	89 c3                	mov    %eax,%ebx
  801f34:	eb 3b                	jmp    801f71 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801f36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f3d:	00 
  801f3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 2b fb ff ff       	call   801a74 <fd_close>
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	74 24                	je     801f71 <open+0xad>
  801f4d:	c7 44 24 0c 2c 2f 80 	movl   $0x802f2c,0xc(%esp)
  801f54:	00 
  801f55:	c7 44 24 08 41 2f 80 	movl   $0x802f41,0x8(%esp)
  801f5c:	00 
  801f5d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801f64:	00 
  801f65:	c7 04 24 56 2f 80 00 	movl   $0x802f56,(%esp)
  801f6c:	e8 13 05 00 00       	call   802484 <_panic>
  return r;
}
  801f71:	89 d8                	mov    %ebx,%eax
  801f73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f79:	89 ec                	mov    %ebp,%esp
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    
  801f7d:	00 00                	add    %al,(%eax)
	...

00801f80 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f86:	c7 44 24 04 61 2f 80 	movl   $0x802f61,0x4(%esp)
  801f8d:	00 
  801f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 71 e9 ff ff       	call   80090a <strcpy>
	return 0;
}
  801f99:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9e:	c9                   	leave  
  801f9f:	c3                   	ret    

00801fa0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 14             	sub    $0x14,%esp
  801fa7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801faa:	89 1c 24             	mov    %ebx,(%esp)
  801fad:	e8 c2 05 00 00       	call   802574 <pageref>
  801fb2:	89 c2                	mov    %eax,%edx
  801fb4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb9:	83 fa 01             	cmp    $0x1,%edx
  801fbc:	75 0b                	jne    801fc9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801fbe:	8b 43 0c             	mov    0xc(%ebx),%eax
  801fc1:	89 04 24             	mov    %eax,(%esp)
  801fc4:	e8 b9 02 00 00       	call   802282 <nsipc_close>
	else
		return 0;
}
  801fc9:	83 c4 14             	add    $0x14,%esp
  801fcc:	5b                   	pop    %ebx
  801fcd:	5d                   	pop    %ebp
  801fce:	c3                   	ret    

00801fcf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801fcf:	55                   	push   %ebp
  801fd0:	89 e5                	mov    %esp,%ebp
  801fd2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fd5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fdc:	00 
  801fdd:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801feb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fee:	8b 40 0c             	mov    0xc(%eax),%eax
  801ff1:	89 04 24             	mov    %eax,(%esp)
  801ff4:	e8 c5 02 00 00       	call   8022be <nsipc_send>
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802001:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802008:	00 
  802009:	8b 45 10             	mov    0x10(%ebp),%eax
  80200c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802010:	8b 45 0c             	mov    0xc(%ebp),%eax
  802013:	89 44 24 04          	mov    %eax,0x4(%esp)
  802017:	8b 45 08             	mov    0x8(%ebp),%eax
  80201a:	8b 40 0c             	mov    0xc(%eax),%eax
  80201d:	89 04 24             	mov    %eax,(%esp)
  802020:	e8 0c 03 00 00       	call   802331 <nsipc_recv>
}
  802025:	c9                   	leave  
  802026:	c3                   	ret    

00802027 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802027:	55                   	push   %ebp
  802028:	89 e5                	mov    %esp,%ebp
  80202a:	56                   	push   %esi
  80202b:	53                   	push   %ebx
  80202c:	83 ec 20             	sub    $0x20,%esp
  80202f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802034:	89 04 24             	mov    %eax,(%esp)
  802037:	e8 7f f6 ff ff       	call   8016bb <fd_alloc>
  80203c:	89 c3                	mov    %eax,%ebx
  80203e:	85 c0                	test   %eax,%eax
  802040:	78 21                	js     802063 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802042:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802049:	00 
  80204a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80204d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802051:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802058:	e8 10 ef ff ff       	call   800f6d <sys_page_alloc>
  80205d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80205f:	85 c0                	test   %eax,%eax
  802061:	79 0a                	jns    80206d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802063:	89 34 24             	mov    %esi,(%esp)
  802066:	e8 17 02 00 00       	call   802282 <nsipc_close>
		return r;
  80206b:	eb 28                	jmp    802095 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80206d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802073:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802076:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802078:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80207b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802082:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802085:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 fd f5 ff ff       	call   801690 <fd2num>
  802093:	89 c3                	mov    %eax,%ebx
}
  802095:	89 d8                	mov    %ebx,%eax
  802097:	83 c4 20             	add    $0x20,%esp
  80209a:	5b                   	pop    %ebx
  80209b:	5e                   	pop    %esi
  80209c:	5d                   	pop    %ebp
  80209d:	c3                   	ret    

0080209e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80209e:	55                   	push   %ebp
  80209f:	89 e5                	mov    %esp,%ebp
  8020a1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b5:	89 04 24             	mov    %eax,(%esp)
  8020b8:	e8 79 01 00 00       	call   802236 <nsipc_socket>
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	78 05                	js     8020c6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8020c1:	e8 61 ff ff ff       	call   802027 <alloc_sockfd>
}
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    

008020c8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020ce:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020d5:	89 04 24             	mov    %eax,(%esp)
  8020d8:	e8 50 f6 ff ff       	call   80172d <fd_lookup>
  8020dd:	85 c0                	test   %eax,%eax
  8020df:	78 15                	js     8020f6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8020e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020e4:	8b 0a                	mov    (%edx),%ecx
  8020e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020eb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  8020f1:	75 03                	jne    8020f6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8020f3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8020f6:	c9                   	leave  
  8020f7:	c3                   	ret    

008020f8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802101:	e8 c2 ff ff ff       	call   8020c8 <fd2sockid>
  802106:	85 c0                	test   %eax,%eax
  802108:	78 0f                	js     802119 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80210a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80210d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802111:	89 04 24             	mov    %eax,(%esp)
  802114:	e8 47 01 00 00       	call   802260 <nsipc_listen>
}
  802119:	c9                   	leave  
  80211a:	c3                   	ret    

0080211b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802121:	8b 45 08             	mov    0x8(%ebp),%eax
  802124:	e8 9f ff ff ff       	call   8020c8 <fd2sockid>
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 16                	js     802143 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80212d:	8b 55 10             	mov    0x10(%ebp),%edx
  802130:	89 54 24 08          	mov    %edx,0x8(%esp)
  802134:	8b 55 0c             	mov    0xc(%ebp),%edx
  802137:	89 54 24 04          	mov    %edx,0x4(%esp)
  80213b:	89 04 24             	mov    %eax,(%esp)
  80213e:	e8 6e 02 00 00       	call   8023b1 <nsipc_connect>
}
  802143:	c9                   	leave  
  802144:	c3                   	ret    

00802145 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80214b:	8b 45 08             	mov    0x8(%ebp),%eax
  80214e:	e8 75 ff ff ff       	call   8020c8 <fd2sockid>
  802153:	85 c0                	test   %eax,%eax
  802155:	78 0f                	js     802166 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80215a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80215e:	89 04 24             	mov    %eax,(%esp)
  802161:	e8 36 01 00 00       	call   80229c <nsipc_shutdown>
}
  802166:	c9                   	leave  
  802167:	c3                   	ret    

00802168 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80216e:	8b 45 08             	mov    0x8(%ebp),%eax
  802171:	e8 52 ff ff ff       	call   8020c8 <fd2sockid>
  802176:	85 c0                	test   %eax,%eax
  802178:	78 16                	js     802190 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80217a:	8b 55 10             	mov    0x10(%ebp),%edx
  80217d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802181:	8b 55 0c             	mov    0xc(%ebp),%edx
  802184:	89 54 24 04          	mov    %edx,0x4(%esp)
  802188:	89 04 24             	mov    %eax,(%esp)
  80218b:	e8 60 02 00 00       	call   8023f0 <nsipc_bind>
}
  802190:	c9                   	leave  
  802191:	c3                   	ret    

00802192 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802198:	8b 45 08             	mov    0x8(%ebp),%eax
  80219b:	e8 28 ff ff ff       	call   8020c8 <fd2sockid>
  8021a0:	85 c0                	test   %eax,%eax
  8021a2:	78 1f                	js     8021c3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8021a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8021a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021b2:	89 04 24             	mov    %eax,(%esp)
  8021b5:	e8 75 02 00 00       	call   80242f <nsipc_accept>
  8021ba:	85 c0                	test   %eax,%eax
  8021bc:	78 05                	js     8021c3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8021be:	e8 64 fe ff ff       	call   802027 <alloc_sockfd>
}
  8021c3:	c9                   	leave  
  8021c4:	c3                   	ret    
	...

008021d0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	53                   	push   %ebx
  8021d4:	83 ec 14             	sub    $0x14,%esp
  8021d7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021d9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8021e0:	75 11                	jne    8021f3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021e2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8021e9:	e8 62 f3 ff ff       	call   801550 <ipc_find_env>
  8021ee:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8021f3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8021fa:	00 
  8021fb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802202:	00 
  802203:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802207:	a1 04 40 80 00       	mov    0x804004,%eax
  80220c:	89 04 24             	mov    %eax,(%esp)
  80220f:	e8 80 f3 ff ff       	call   801594 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802214:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80221b:	00 
  80221c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802223:	00 
  802224:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80222b:	e8 cf f3 ff ff       	call   8015ff <ipc_recv>
}
  802230:	83 c4 14             	add    $0x14,%esp
  802233:	5b                   	pop    %ebx
  802234:	5d                   	pop    %ebp
  802235:	c3                   	ret    

00802236 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802236:	55                   	push   %ebp
  802237:	89 e5                	mov    %esp,%ebp
  802239:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80223c:	8b 45 08             	mov    0x8(%ebp),%eax
  80223f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802244:	8b 45 0c             	mov    0xc(%ebp),%eax
  802247:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80224c:	8b 45 10             	mov    0x10(%ebp),%eax
  80224f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802254:	b8 09 00 00 00       	mov    $0x9,%eax
  802259:	e8 72 ff ff ff       	call   8021d0 <nsipc>
}
  80225e:	c9                   	leave  
  80225f:	c3                   	ret    

00802260 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802266:	8b 45 08             	mov    0x8(%ebp),%eax
  802269:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80226e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802271:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802276:	b8 06 00 00 00       	mov    $0x6,%eax
  80227b:	e8 50 ff ff ff       	call   8021d0 <nsipc>
}
  802280:	c9                   	leave  
  802281:	c3                   	ret    

00802282 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802288:	8b 45 08             	mov    0x8(%ebp),%eax
  80228b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802290:	b8 04 00 00 00       	mov    $0x4,%eax
  802295:	e8 36 ff ff ff       	call   8021d0 <nsipc>
}
  80229a:	c9                   	leave  
  80229b:	c3                   	ret    

0080229c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8022aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ad:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8022b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022b7:	e8 14 ff ff ff       	call   8021d0 <nsipc>
}
  8022bc:	c9                   	leave  
  8022bd:	c3                   	ret    

008022be <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	53                   	push   %ebx
  8022c2:	83 ec 14             	sub    $0x14,%esp
  8022c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022cb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8022d0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022d6:	7e 24                	jle    8022fc <nsipc_send+0x3e>
  8022d8:	c7 44 24 0c 6d 2f 80 	movl   $0x802f6d,0xc(%esp)
  8022df:	00 
  8022e0:	c7 44 24 08 41 2f 80 	movl   $0x802f41,0x8(%esp)
  8022e7:	00 
  8022e8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8022ef:	00 
  8022f0:	c7 04 24 79 2f 80 00 	movl   $0x802f79,(%esp)
  8022f7:	e8 88 01 00 00       	call   802484 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8022fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802300:	8b 45 0c             	mov    0xc(%ebp),%eax
  802303:	89 44 24 04          	mov    %eax,0x4(%esp)
  802307:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80230e:	e8 e2 e7 ff ff       	call   800af5 <memmove>
	nsipcbuf.send.req_size = size;
  802313:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802319:	8b 45 14             	mov    0x14(%ebp),%eax
  80231c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802321:	b8 08 00 00 00       	mov    $0x8,%eax
  802326:	e8 a5 fe ff ff       	call   8021d0 <nsipc>
}
  80232b:	83 c4 14             	add    $0x14,%esp
  80232e:	5b                   	pop    %ebx
  80232f:	5d                   	pop    %ebp
  802330:	c3                   	ret    

00802331 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802331:	55                   	push   %ebp
  802332:	89 e5                	mov    %esp,%ebp
  802334:	56                   	push   %esi
  802335:	53                   	push   %ebx
  802336:	83 ec 10             	sub    $0x10,%esp
  802339:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80233c:	8b 45 08             	mov    0x8(%ebp),%eax
  80233f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802344:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80234a:	8b 45 14             	mov    0x14(%ebp),%eax
  80234d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802352:	b8 07 00 00 00       	mov    $0x7,%eax
  802357:	e8 74 fe ff ff       	call   8021d0 <nsipc>
  80235c:	89 c3                	mov    %eax,%ebx
  80235e:	85 c0                	test   %eax,%eax
  802360:	78 46                	js     8023a8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802362:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802367:	7f 04                	jg     80236d <nsipc_recv+0x3c>
  802369:	39 c6                	cmp    %eax,%esi
  80236b:	7d 24                	jge    802391 <nsipc_recv+0x60>
  80236d:	c7 44 24 0c 85 2f 80 	movl   $0x802f85,0xc(%esp)
  802374:	00 
  802375:	c7 44 24 08 41 2f 80 	movl   $0x802f41,0x8(%esp)
  80237c:	00 
  80237d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802384:	00 
  802385:	c7 04 24 79 2f 80 00 	movl   $0x802f79,(%esp)
  80238c:	e8 f3 00 00 00       	call   802484 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802391:	89 44 24 08          	mov    %eax,0x8(%esp)
  802395:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80239c:	00 
  80239d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a0:	89 04 24             	mov    %eax,(%esp)
  8023a3:	e8 4d e7 ff ff       	call   800af5 <memmove>
	}

	return r;
}
  8023a8:	89 d8                	mov    %ebx,%eax
  8023aa:	83 c4 10             	add    $0x10,%esp
  8023ad:	5b                   	pop    %ebx
  8023ae:	5e                   	pop    %esi
  8023af:	5d                   	pop    %ebp
  8023b0:	c3                   	ret    

008023b1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023b1:	55                   	push   %ebp
  8023b2:	89 e5                	mov    %esp,%ebp
  8023b4:	53                   	push   %ebx
  8023b5:	83 ec 14             	sub    $0x14,%esp
  8023b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8023bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023be:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8023c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023ce:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8023d5:	e8 1b e7 ff ff       	call   800af5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8023da:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8023e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8023e5:	e8 e6 fd ff ff       	call   8021d0 <nsipc>
}
  8023ea:	83 c4 14             	add    $0x14,%esp
  8023ed:	5b                   	pop    %ebx
  8023ee:	5d                   	pop    %ebp
  8023ef:	c3                   	ret    

008023f0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023f0:	55                   	push   %ebp
  8023f1:	89 e5                	mov    %esp,%ebp
  8023f3:	53                   	push   %ebx
  8023f4:	83 ec 14             	sub    $0x14,%esp
  8023f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8023fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802402:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802406:	8b 45 0c             	mov    0xc(%ebp),%eax
  802409:	89 44 24 04          	mov    %eax,0x4(%esp)
  80240d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802414:	e8 dc e6 ff ff       	call   800af5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802419:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80241f:	b8 02 00 00 00       	mov    $0x2,%eax
  802424:	e8 a7 fd ff ff       	call   8021d0 <nsipc>
}
  802429:	83 c4 14             	add    $0x14,%esp
  80242c:	5b                   	pop    %ebx
  80242d:	5d                   	pop    %ebp
  80242e:	c3                   	ret    

0080242f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80242f:	55                   	push   %ebp
  802430:	89 e5                	mov    %esp,%ebp
  802432:	83 ec 18             	sub    $0x18,%esp
  802435:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802438:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80243b:	8b 45 08             	mov    0x8(%ebp),%eax
  80243e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802443:	b8 01 00 00 00       	mov    $0x1,%eax
  802448:	e8 83 fd ff ff       	call   8021d0 <nsipc>
  80244d:	89 c3                	mov    %eax,%ebx
  80244f:	85 c0                	test   %eax,%eax
  802451:	78 25                	js     802478 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802453:	be 10 60 80 00       	mov    $0x806010,%esi
  802458:	8b 06                	mov    (%esi),%eax
  80245a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80245e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802465:	00 
  802466:	8b 45 0c             	mov    0xc(%ebp),%eax
  802469:	89 04 24             	mov    %eax,(%esp)
  80246c:	e8 84 e6 ff ff       	call   800af5 <memmove>
		*addrlen = ret->ret_addrlen;
  802471:	8b 16                	mov    (%esi),%edx
  802473:	8b 45 10             	mov    0x10(%ebp),%eax
  802476:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802478:	89 d8                	mov    %ebx,%eax
  80247a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80247d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802480:	89 ec                	mov    %ebp,%esp
  802482:	5d                   	pop    %ebp
  802483:	c3                   	ret    

00802484 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802484:	55                   	push   %ebp
  802485:	89 e5                	mov    %esp,%ebp
  802487:	56                   	push   %esi
  802488:	53                   	push   %ebx
  802489:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80248c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80248f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802495:	e8 7d eb ff ff       	call   801017 <sys_getenvid>
  80249a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80249d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8024a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024b0:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  8024b7:	e8 09 dd ff ff       	call   8001c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8024bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8024c3:	89 04 24             	mov    %eax,(%esp)
  8024c6:	e8 99 dc ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  8024cb:	c7 04 24 1c 2f 80 00 	movl   $0x802f1c,(%esp)
  8024d2:	e8 ee dc ff ff       	call   8001c5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8024d7:	cc                   	int3   
  8024d8:	eb fd                	jmp    8024d7 <_panic+0x53>
	...

008024dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024dc:	55                   	push   %ebp
  8024dd:	89 e5                	mov    %esp,%ebp
  8024df:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8024e2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024e9:	75 54                	jne    80253f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8024eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8024f2:	00 
  8024f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8024fa:	ee 
  8024fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802502:	e8 66 ea ff ff       	call   800f6d <sys_page_alloc>
  802507:	85 c0                	test   %eax,%eax
  802509:	79 20                	jns    80252b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80250b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80250f:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  802516:	00 
  802517:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80251e:	00 
  80251f:	c7 04 24 d8 2f 80 00 	movl   $0x802fd8,(%esp)
  802526:	e8 59 ff ff ff       	call   802484 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80252b:	c7 44 24 04 4c 25 80 	movl   $0x80254c,0x4(%esp)
  802532:	00 
  802533:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80253a:	e8 15 e9 ff ff       	call   800e54 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80253f:	8b 45 08             	mov    0x8(%ebp),%eax
  802542:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802547:	c9                   	leave  
  802548:	c3                   	ret    
  802549:	00 00                	add    %al,(%eax)
	...

0080254c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80254c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80254d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802552:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802554:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  802557:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80255b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80255e:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  802562:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802566:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802568:	83 c4 08             	add    $0x8,%esp
	popal
  80256b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  80256c:	83 c4 04             	add    $0x4,%esp
	popfl
  80256f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802570:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802571:	c3                   	ret    
	...

00802574 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802574:	55                   	push   %ebp
  802575:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802577:	8b 45 08             	mov    0x8(%ebp),%eax
  80257a:	89 c2                	mov    %eax,%edx
  80257c:	c1 ea 16             	shr    $0x16,%edx
  80257f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802586:	f6 c2 01             	test   $0x1,%dl
  802589:	74 20                	je     8025ab <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80258b:	c1 e8 0c             	shr    $0xc,%eax
  80258e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802595:	a8 01                	test   $0x1,%al
  802597:	74 12                	je     8025ab <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802599:	c1 e8 0c             	shr    $0xc,%eax
  80259c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025a1:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025a6:	0f b7 c0             	movzwl %ax,%eax
  8025a9:	eb 05                	jmp    8025b0 <pageref+0x3c>
  8025ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025b0:	5d                   	pop    %ebp
  8025b1:	c3                   	ret    
	...

008025c0 <__udivdi3>:
  8025c0:	55                   	push   %ebp
  8025c1:	89 e5                	mov    %esp,%ebp
  8025c3:	57                   	push   %edi
  8025c4:	56                   	push   %esi
  8025c5:	83 ec 10             	sub    $0x10,%esp
  8025c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8025cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8025d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025d4:	85 c0                	test   %eax,%eax
  8025d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025d9:	75 35                	jne    802610 <__udivdi3+0x50>
  8025db:	39 fe                	cmp    %edi,%esi
  8025dd:	77 61                	ja     802640 <__udivdi3+0x80>
  8025df:	85 f6                	test   %esi,%esi
  8025e1:	75 0b                	jne    8025ee <__udivdi3+0x2e>
  8025e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8025e8:	31 d2                	xor    %edx,%edx
  8025ea:	f7 f6                	div    %esi
  8025ec:	89 c6                	mov    %eax,%esi
  8025ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8025f1:	31 d2                	xor    %edx,%edx
  8025f3:	89 f8                	mov    %edi,%eax
  8025f5:	f7 f6                	div    %esi
  8025f7:	89 c7                	mov    %eax,%edi
  8025f9:	89 c8                	mov    %ecx,%eax
  8025fb:	f7 f6                	div    %esi
  8025fd:	89 c1                	mov    %eax,%ecx
  8025ff:	89 fa                	mov    %edi,%edx
  802601:	89 c8                	mov    %ecx,%eax
  802603:	83 c4 10             	add    $0x10,%esp
  802606:	5e                   	pop    %esi
  802607:	5f                   	pop    %edi
  802608:	5d                   	pop    %ebp
  802609:	c3                   	ret    
  80260a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802610:	39 f8                	cmp    %edi,%eax
  802612:	77 1c                	ja     802630 <__udivdi3+0x70>
  802614:	0f bd d0             	bsr    %eax,%edx
  802617:	83 f2 1f             	xor    $0x1f,%edx
  80261a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80261d:	75 39                	jne    802658 <__udivdi3+0x98>
  80261f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802622:	0f 86 a0 00 00 00    	jbe    8026c8 <__udivdi3+0x108>
  802628:	39 f8                	cmp    %edi,%eax
  80262a:	0f 82 98 00 00 00    	jb     8026c8 <__udivdi3+0x108>
  802630:	31 ff                	xor    %edi,%edi
  802632:	31 c9                	xor    %ecx,%ecx
  802634:	89 c8                	mov    %ecx,%eax
  802636:	89 fa                	mov    %edi,%edx
  802638:	83 c4 10             	add    $0x10,%esp
  80263b:	5e                   	pop    %esi
  80263c:	5f                   	pop    %edi
  80263d:	5d                   	pop    %ebp
  80263e:	c3                   	ret    
  80263f:	90                   	nop
  802640:	89 d1                	mov    %edx,%ecx
  802642:	89 fa                	mov    %edi,%edx
  802644:	89 c8                	mov    %ecx,%eax
  802646:	31 ff                	xor    %edi,%edi
  802648:	f7 f6                	div    %esi
  80264a:	89 c1                	mov    %eax,%ecx
  80264c:	89 fa                	mov    %edi,%edx
  80264e:	89 c8                	mov    %ecx,%eax
  802650:	83 c4 10             	add    $0x10,%esp
  802653:	5e                   	pop    %esi
  802654:	5f                   	pop    %edi
  802655:	5d                   	pop    %ebp
  802656:	c3                   	ret    
  802657:	90                   	nop
  802658:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80265c:	89 f2                	mov    %esi,%edx
  80265e:	d3 e0                	shl    %cl,%eax
  802660:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802663:	b8 20 00 00 00       	mov    $0x20,%eax
  802668:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80266b:	89 c1                	mov    %eax,%ecx
  80266d:	d3 ea                	shr    %cl,%edx
  80266f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802673:	0b 55 ec             	or     -0x14(%ebp),%edx
  802676:	d3 e6                	shl    %cl,%esi
  802678:	89 c1                	mov    %eax,%ecx
  80267a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80267d:	89 fe                	mov    %edi,%esi
  80267f:	d3 ee                	shr    %cl,%esi
  802681:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802685:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802688:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80268b:	d3 e7                	shl    %cl,%edi
  80268d:	89 c1                	mov    %eax,%ecx
  80268f:	d3 ea                	shr    %cl,%edx
  802691:	09 d7                	or     %edx,%edi
  802693:	89 f2                	mov    %esi,%edx
  802695:	89 f8                	mov    %edi,%eax
  802697:	f7 75 ec             	divl   -0x14(%ebp)
  80269a:	89 d6                	mov    %edx,%esi
  80269c:	89 c7                	mov    %eax,%edi
  80269e:	f7 65 e8             	mull   -0x18(%ebp)
  8026a1:	39 d6                	cmp    %edx,%esi
  8026a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026a6:	72 30                	jb     8026d8 <__udivdi3+0x118>
  8026a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026af:	d3 e2                	shl    %cl,%edx
  8026b1:	39 c2                	cmp    %eax,%edx
  8026b3:	73 05                	jae    8026ba <__udivdi3+0xfa>
  8026b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8026b8:	74 1e                	je     8026d8 <__udivdi3+0x118>
  8026ba:	89 f9                	mov    %edi,%ecx
  8026bc:	31 ff                	xor    %edi,%edi
  8026be:	e9 71 ff ff ff       	jmp    802634 <__udivdi3+0x74>
  8026c3:	90                   	nop
  8026c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c8:	31 ff                	xor    %edi,%edi
  8026ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8026cf:	e9 60 ff ff ff       	jmp    802634 <__udivdi3+0x74>
  8026d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026db:	31 ff                	xor    %edi,%edi
  8026dd:	89 c8                	mov    %ecx,%eax
  8026df:	89 fa                	mov    %edi,%edx
  8026e1:	83 c4 10             	add    $0x10,%esp
  8026e4:	5e                   	pop    %esi
  8026e5:	5f                   	pop    %edi
  8026e6:	5d                   	pop    %ebp
  8026e7:	c3                   	ret    
	...

008026f0 <__umoddi3>:
  8026f0:	55                   	push   %ebp
  8026f1:	89 e5                	mov    %esp,%ebp
  8026f3:	57                   	push   %edi
  8026f4:	56                   	push   %esi
  8026f5:	83 ec 20             	sub    $0x20,%esp
  8026f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8026fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  802701:	8b 75 0c             	mov    0xc(%ebp),%esi
  802704:	85 d2                	test   %edx,%edx
  802706:	89 c8                	mov    %ecx,%eax
  802708:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80270b:	75 13                	jne    802720 <__umoddi3+0x30>
  80270d:	39 f7                	cmp    %esi,%edi
  80270f:	76 3f                	jbe    802750 <__umoddi3+0x60>
  802711:	89 f2                	mov    %esi,%edx
  802713:	f7 f7                	div    %edi
  802715:	89 d0                	mov    %edx,%eax
  802717:	31 d2                	xor    %edx,%edx
  802719:	83 c4 20             	add    $0x20,%esp
  80271c:	5e                   	pop    %esi
  80271d:	5f                   	pop    %edi
  80271e:	5d                   	pop    %ebp
  80271f:	c3                   	ret    
  802720:	39 f2                	cmp    %esi,%edx
  802722:	77 4c                	ja     802770 <__umoddi3+0x80>
  802724:	0f bd ca             	bsr    %edx,%ecx
  802727:	83 f1 1f             	xor    $0x1f,%ecx
  80272a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80272d:	75 51                	jne    802780 <__umoddi3+0x90>
  80272f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802732:	0f 87 e0 00 00 00    	ja     802818 <__umoddi3+0x128>
  802738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80273b:	29 f8                	sub    %edi,%eax
  80273d:	19 d6                	sbb    %edx,%esi
  80273f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802745:	89 f2                	mov    %esi,%edx
  802747:	83 c4 20             	add    $0x20,%esp
  80274a:	5e                   	pop    %esi
  80274b:	5f                   	pop    %edi
  80274c:	5d                   	pop    %ebp
  80274d:	c3                   	ret    
  80274e:	66 90                	xchg   %ax,%ax
  802750:	85 ff                	test   %edi,%edi
  802752:	75 0b                	jne    80275f <__umoddi3+0x6f>
  802754:	b8 01 00 00 00       	mov    $0x1,%eax
  802759:	31 d2                	xor    %edx,%edx
  80275b:	f7 f7                	div    %edi
  80275d:	89 c7                	mov    %eax,%edi
  80275f:	89 f0                	mov    %esi,%eax
  802761:	31 d2                	xor    %edx,%edx
  802763:	f7 f7                	div    %edi
  802765:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802768:	f7 f7                	div    %edi
  80276a:	eb a9                	jmp    802715 <__umoddi3+0x25>
  80276c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802770:	89 c8                	mov    %ecx,%eax
  802772:	89 f2                	mov    %esi,%edx
  802774:	83 c4 20             	add    $0x20,%esp
  802777:	5e                   	pop    %esi
  802778:	5f                   	pop    %edi
  802779:	5d                   	pop    %ebp
  80277a:	c3                   	ret    
  80277b:	90                   	nop
  80277c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802780:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802784:	d3 e2                	shl    %cl,%edx
  802786:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802789:	ba 20 00 00 00       	mov    $0x20,%edx
  80278e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802791:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802794:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802798:	89 fa                	mov    %edi,%edx
  80279a:	d3 ea                	shr    %cl,%edx
  80279c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027a3:	d3 e7                	shl    %cl,%edi
  8027a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027ac:	89 f2                	mov    %esi,%edx
  8027ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8027b1:	89 c7                	mov    %eax,%edi
  8027b3:	d3 ea                	shr    %cl,%edx
  8027b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8027bc:	89 c2                	mov    %eax,%edx
  8027be:	d3 e6                	shl    %cl,%esi
  8027c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027c4:	d3 ea                	shr    %cl,%edx
  8027c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027ca:	09 d6                	or     %edx,%esi
  8027cc:	89 f0                	mov    %esi,%eax
  8027ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027d1:	d3 e7                	shl    %cl,%edi
  8027d3:	89 f2                	mov    %esi,%edx
  8027d5:	f7 75 f4             	divl   -0xc(%ebp)
  8027d8:	89 d6                	mov    %edx,%esi
  8027da:	f7 65 e8             	mull   -0x18(%ebp)
  8027dd:	39 d6                	cmp    %edx,%esi
  8027df:	72 2b                	jb     80280c <__umoddi3+0x11c>
  8027e1:	39 c7                	cmp    %eax,%edi
  8027e3:	72 23                	jb     802808 <__umoddi3+0x118>
  8027e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027e9:	29 c7                	sub    %eax,%edi
  8027eb:	19 d6                	sbb    %edx,%esi
  8027ed:	89 f0                	mov    %esi,%eax
  8027ef:	89 f2                	mov    %esi,%edx
  8027f1:	d3 ef                	shr    %cl,%edi
  8027f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027f7:	d3 e0                	shl    %cl,%eax
  8027f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027fd:	09 f8                	or     %edi,%eax
  8027ff:	d3 ea                	shr    %cl,%edx
  802801:	83 c4 20             	add    $0x20,%esp
  802804:	5e                   	pop    %esi
  802805:	5f                   	pop    %edi
  802806:	5d                   	pop    %ebp
  802807:	c3                   	ret    
  802808:	39 d6                	cmp    %edx,%esi
  80280a:	75 d9                	jne    8027e5 <__umoddi3+0xf5>
  80280c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80280f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802812:	eb d1                	jmp    8027e5 <__umoddi3+0xf5>
  802814:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802818:	39 f2                	cmp    %esi,%edx
  80281a:	0f 82 18 ff ff ff    	jb     802738 <__umoddi3+0x48>
  802820:	e9 1d ff ff ff       	jmp    802742 <__umoddi3+0x52>
