
obj/user/forktree.debug:     file format elf32-i386


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
  80002c:	e8 f3 00 00 00       	call   800124 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 38             	sub    $0x38,%esp
  800046:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800049:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	0f b6 75 0c          	movzbl 0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  800053:	89 1c 24             	mov    %ebx,(%esp)
  800056:	e8 85 08 00 00       	call   8008e0 <strlen>
  80005b:	83 f8 02             	cmp    $0x2,%eax
  80005e:	7f 5a                	jg     8000ba <forkchild+0x7a>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800060:	89 f0                	mov    %esi,%eax
  800062:	0f be f0             	movsbl %al,%esi
  800065:	89 74 24 10          	mov    %esi,0x10(%esp)
  800069:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80006d:	c7 44 24 08 c0 22 80 	movl   $0x8022c0,0x8(%esp)
  800074:	00 
  800075:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80007c:	00 
  80007d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800080:	89 04 24             	mov    %eax,(%esp)
  800083:	e8 00 08 00 00       	call   800888 <snprintf>
	if (fork() == 0) {
  800088:	e8 41 10 00 00       	call   8010ce <fork>
  80008d:	85 c0                	test   %eax,%eax
  80008f:	75 29                	jne    8000ba <forkchild+0x7a>
		cprintf("%04x: I am '%c'\n", sys_getenvid(), branch);
  800091:	e8 2e 0f 00 00       	call   800fc4 <sys_getenvid>
  800096:	89 74 24 08          	mov    %esi,0x8(%esp)
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 c5 22 80 00 	movl   $0x8022c5,(%esp)
  8000a5:	e8 47 01 00 00       	call   8001f1 <cprintf>
		forktree(nxt);
  8000aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000ad:	89 04 24             	mov    %eax,(%esp)
  8000b0:	e8 0f 00 00 00       	call   8000c4 <forktree>
		exit();
  8000b5:	e8 ba 00 00 00       	call   800174 <exit>
	}
	
}
  8000ba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000bd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c0:	89 ec                	mov    %ebp,%esp
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <forktree>:

void
forktree(const char *cur)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	53                   	push   %ebx
  8000c8:	83 ec 14             	sub    $0x14,%esp
  8000cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  8000ce:	e8 f1 0e 00 00       	call   800fc4 <sys_getenvid>
  8000d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000db:	c7 04 24 d6 22 80 00 	movl   $0x8022d6,(%esp)
  8000e2:	e8 0a 01 00 00       	call   8001f1 <cprintf>

	forkchild(cur, '0');
  8000e7:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  8000ee:	00 
  8000ef:	89 1c 24             	mov    %ebx,(%esp)
  8000f2:	e8 49 ff ff ff       	call   800040 <forkchild>
	forkchild(cur, '1');
  8000f7:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
  8000fe:	00 
  8000ff:	89 1c 24             	mov    %ebx,(%esp)
  800102:	e8 39 ff ff ff       	call   800040 <forkchild>
}
  800107:	83 c4 14             	add    $0x14,%esp
  80010a:	5b                   	pop    %ebx
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <umain>:

void
umain(int argc, char **argv)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 18             	sub    $0x18,%esp
	forktree("");
  800113:	c7 04 24 d5 22 80 00 	movl   $0x8022d5,(%esp)
  80011a:	e8 a5 ff ff ff       	call   8000c4 <forktree>
}
  80011f:	c9                   	leave  
  800120:	c3                   	ret    
  800121:	00 00                	add    %al,(%eax)
	...

00800124 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 18             	sub    $0x18,%esp
  80012a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80012d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800130:	8b 75 08             	mov    0x8(%ebp),%esi
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800136:	e8 89 0e 00 00       	call   800fc4 <sys_getenvid>
  80013b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800140:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800143:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800148:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014d:	85 f6                	test   %esi,%esi
  80014f:	7e 07                	jle    800158 <libmain+0x34>
		binaryname = argv[0];
  800151:	8b 03                	mov    (%ebx),%eax
  800153:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800158:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80015c:	89 34 24             	mov    %esi,(%esp)
  80015f:	e8 a9 ff ff ff       	call   80010d <umain>

	// exit gracefully
	exit();
  800164:	e8 0b 00 00 00       	call   800174 <exit>
}
  800169:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80016c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016f:	89 ec                	mov    %ebp,%esp
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    
	...

00800174 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80017a:	e8 8a 18 00 00       	call   801a09 <close_all>
	sys_env_destroy(0);
  80017f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800186:	e8 74 0e 00 00       	call   800fff <sys_env_destroy>
}
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800199:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a0:	00 00 00 
	b.cnt = 0;
  8001a3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001aa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001bb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c5:	c7 04 24 0b 02 80 00 	movl   $0x80020b,(%esp)
  8001cc:	e8 cc 01 00 00       	call   80039d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001db:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e1:	89 04 24             	mov    %eax,(%esp)
  8001e4:	e8 8a 0e 00 00       	call   801073 <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	e8 87 ff ff ff       	call   800190 <vcprintf>
	va_end(ap);

	return cnt;
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	53                   	push   %ebx
  80020f:	83 ec 14             	sub    $0x14,%esp
  800212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800215:	8b 03                	mov    (%ebx),%eax
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80021e:	83 c0 01             	add    $0x1,%eax
  800221:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800223:	3d ff 00 00 00       	cmp    $0xff,%eax
  800228:	75 19                	jne    800243 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80022a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800231:	00 
  800232:	8d 43 08             	lea    0x8(%ebx),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	e8 36 0e 00 00       	call   801073 <sys_cputs>
		b->idx = 0;
  80023d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800243:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800247:	83 c4 14             	add    $0x14,%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    
  80024d:	00 00                	add    %al,(%eax)
	...

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 4c             	sub    $0x4c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d6                	mov    %edx,%esi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800264:	8b 55 0c             	mov    0xc(%ebp),%edx
  800267:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80026a:	8b 45 10             	mov    0x10(%ebp),%eax
  80026d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800270:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800273:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800276:	b9 00 00 00 00       	mov    $0x0,%ecx
  80027b:	39 d1                	cmp    %edx,%ecx
  80027d:	72 15                	jb     800294 <printnum+0x44>
  80027f:	77 07                	ja     800288 <printnum+0x38>
  800281:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800284:	39 d0                	cmp    %edx,%eax
  800286:	76 0c                	jbe    800294 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800288:	83 eb 01             	sub    $0x1,%ebx
  80028b:	85 db                	test   %ebx,%ebx
  80028d:	8d 76 00             	lea    0x0(%esi),%esi
  800290:	7f 61                	jg     8002f3 <printnum+0xa3>
  800292:	eb 70                	jmp    800304 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800298:	83 eb 01             	sub    $0x1,%ebx
  80029b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002a7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002ae:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002b1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bf:	00 
  8002c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002c3:	89 04 24             	mov    %eax,(%esp)
  8002c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002cd:	e8 7e 1d 00 00       	call   802050 <__udivdi3>
  8002d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e7:	89 f2                	mov    %esi,%edx
  8002e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ec:	e8 5f ff ff ff       	call   800250 <printnum>
  8002f1:	eb 11                	jmp    800304 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f7:	89 3c 24             	mov    %edi,(%esp)
  8002fa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fd:	83 eb 01             	sub    $0x1,%ebx
  800300:	85 db                	test   %ebx,%ebx
  800302:	7f ef                	jg     8002f3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800304:	89 74 24 04          	mov    %esi,0x4(%esp)
  800308:	8b 74 24 04          	mov    0x4(%esp),%esi
  80030c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031a:	00 
  80031b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80031e:	89 14 24             	mov    %edx,(%esp)
  800321:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800324:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800328:	e8 53 1e 00 00       	call   802180 <__umoddi3>
  80032d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800331:	0f be 80 f1 22 80 00 	movsbl 0x8022f1(%eax),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033e:	83 c4 4c             	add    $0x4c,%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7e 0e                	jle    80035c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034e:	8b 10                	mov    (%eax),%edx
  800350:	8d 4a 08             	lea    0x8(%edx),%ecx
  800353:	89 08                	mov    %ecx,(%eax)
  800355:	8b 02                	mov    (%edx),%eax
  800357:	8b 52 04             	mov    0x4(%edx),%edx
  80035a:	eb 22                	jmp    80037e <getuint+0x38>
	else if (lflag)
  80035c:	85 d2                	test   %edx,%edx
  80035e:	74 10                	je     800370 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800360:	8b 10                	mov    (%eax),%edx
  800362:	8d 4a 04             	lea    0x4(%edx),%ecx
  800365:	89 08                	mov    %ecx,(%eax)
  800367:	8b 02                	mov    (%edx),%eax
  800369:	ba 00 00 00 00       	mov    $0x0,%edx
  80036e:	eb 0e                	jmp    80037e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800386:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80038a:	8b 10                	mov    (%eax),%edx
  80038c:	3b 50 04             	cmp    0x4(%eax),%edx
  80038f:	73 0a                	jae    80039b <sprintputch+0x1b>
		*b->buf++ = ch;
  800391:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800394:	88 0a                	mov    %cl,(%edx)
  800396:	83 c2 01             	add    $0x1,%edx
  800399:	89 10                	mov    %edx,(%eax)
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	57                   	push   %edi
  8003a1:	56                   	push   %esi
  8003a2:	53                   	push   %ebx
  8003a3:	83 ec 5c             	sub    $0x5c,%esp
  8003a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003af:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003b6:	eb 11                	jmp    8003c9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003b8:	85 c0                	test   %eax,%eax
  8003ba:	0f 84 68 04 00 00    	je     800828 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8003c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c9:	0f b6 03             	movzbl (%ebx),%eax
  8003cc:	83 c3 01             	add    $0x1,%ebx
  8003cf:	83 f8 25             	cmp    $0x25,%eax
  8003d2:	75 e4                	jne    8003b8 <vprintfmt+0x1b>
  8003d4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003db:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8003e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8003eb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003f2:	eb 06                	jmp    8003fa <vprintfmt+0x5d>
  8003f4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8003f8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fa:	0f b6 13             	movzbl (%ebx),%edx
  8003fd:	0f b6 c2             	movzbl %dl,%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	8d 43 01             	lea    0x1(%ebx),%eax
  800406:	83 ea 23             	sub    $0x23,%edx
  800409:	80 fa 55             	cmp    $0x55,%dl
  80040c:	0f 87 f9 03 00 00    	ja     80080b <vprintfmt+0x46e>
  800412:	0f b6 d2             	movzbl %dl,%edx
  800415:	ff 24 95 c0 24 80 00 	jmp    *0x8024c0(,%edx,4)
  80041c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800420:	eb d6                	jmp    8003f8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800422:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800425:	83 ea 30             	sub    $0x30,%edx
  800428:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80042b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80042e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800431:	83 fb 09             	cmp    $0x9,%ebx
  800434:	77 54                	ja     80048a <vprintfmt+0xed>
  800436:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800439:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80043f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800442:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800446:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800449:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80044c:	83 fb 09             	cmp    $0x9,%ebx
  80044f:	76 eb                	jbe    80043c <vprintfmt+0x9f>
  800451:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800454:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800457:	eb 31                	jmp    80048a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800459:	8b 55 14             	mov    0x14(%ebp),%edx
  80045c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80045f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800462:	8b 12                	mov    (%edx),%edx
  800464:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800467:	eb 21                	jmp    80048a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800469:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80046d:	ba 00 00 00 00       	mov    $0x0,%edx
  800472:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800476:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800479:	e9 7a ff ff ff       	jmp    8003f8 <vprintfmt+0x5b>
  80047e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800485:	e9 6e ff ff ff       	jmp    8003f8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80048a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048e:	0f 89 64 ff ff ff    	jns    8003f8 <vprintfmt+0x5b>
  800494:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800497:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80049a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80049d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004a0:	e9 53 ff ff ff       	jmp    8003f8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004a5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004a8:	e9 4b ff ff ff       	jmp    8003f8 <vprintfmt+0x5b>
  8004ad:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b3:	8d 50 04             	lea    0x4(%eax),%edx
  8004b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	89 04 24             	mov    %eax,(%esp)
  8004c2:	ff d7                	call   *%edi
  8004c4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004c7:	e9 fd fe ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  8004cc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d2:	8d 50 04             	lea    0x4(%eax),%edx
  8004d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d8:	8b 00                	mov    (%eax),%eax
  8004da:	89 c2                	mov    %eax,%edx
  8004dc:	c1 fa 1f             	sar    $0x1f,%edx
  8004df:	31 d0                	xor    %edx,%eax
  8004e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	83 f8 0f             	cmp    $0xf,%eax
  8004e6:	7f 0b                	jg     8004f3 <vprintfmt+0x156>
  8004e8:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	75 20                	jne    800513 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8004f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f7:	c7 44 24 08 02 23 80 	movl   $0x802302,0x8(%esp)
  8004fe:	00 
  8004ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800503:	89 3c 24             	mov    %edi,(%esp)
  800506:	e8 a5 03 00 00       	call   8008b0 <printfmt>
  80050b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80050e:	e9 b6 fe ff ff       	jmp    8003c9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800513:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800517:	c7 44 24 08 a7 29 80 	movl   $0x8029a7,0x8(%esp)
  80051e:	00 
  80051f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800523:	89 3c 24             	mov    %edi,(%esp)
  800526:	e8 85 03 00 00       	call   8008b0 <printfmt>
  80052b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80052e:	e9 96 fe ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  800533:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800536:	89 c3                	mov    %eax,%ebx
  800538:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80053b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80053e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800541:	8b 45 14             	mov    0x14(%ebp),%eax
  800544:	8d 50 04             	lea    0x4(%eax),%edx
  800547:	89 55 14             	mov    %edx,0x14(%ebp)
  80054a:	8b 00                	mov    (%eax),%eax
  80054c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054f:	85 c0                	test   %eax,%eax
  800551:	b8 0b 23 80 00       	mov    $0x80230b,%eax
  800556:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80055a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80055d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800561:	7e 06                	jle    800569 <vprintfmt+0x1cc>
  800563:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800567:	75 13                	jne    80057c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800569:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056c:	0f be 02             	movsbl (%edx),%eax
  80056f:	85 c0                	test   %eax,%eax
  800571:	0f 85 a2 00 00 00    	jne    800619 <vprintfmt+0x27c>
  800577:	e9 8f 00 00 00       	jmp    80060b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80057c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800580:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800583:	89 0c 24             	mov    %ecx,(%esp)
  800586:	e8 70 03 00 00       	call   8008fb <strnlen>
  80058b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80058e:	29 c2                	sub    %eax,%edx
  800590:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800593:	85 d2                	test   %edx,%edx
  800595:	7e d2                	jle    800569 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800597:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80059b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80059e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005a1:	89 d3                	mov    %edx,%ebx
  8005a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005aa:	89 04 24             	mov    %eax,(%esp)
  8005ad:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005af:	83 eb 01             	sub    $0x1,%ebx
  8005b2:	85 db                	test   %ebx,%ebx
  8005b4:	7f ed                	jg     8005a3 <vprintfmt+0x206>
  8005b6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005b9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005c0:	eb a7                	jmp    800569 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c6:	74 1b                	je     8005e3 <vprintfmt+0x246>
  8005c8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005cb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ce:	76 13                	jbe    8005e3 <vprintfmt+0x246>
					putch('?', putdat);
  8005d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005d7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005de:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e1:	eb 0d                	jmp    8005f0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f0:	83 ef 01             	sub    $0x1,%edi
  8005f3:	0f be 03             	movsbl (%ebx),%eax
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	74 05                	je     8005ff <vprintfmt+0x262>
  8005fa:	83 c3 01             	add    $0x1,%ebx
  8005fd:	eb 31                	jmp    800630 <vprintfmt+0x293>
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800605:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800608:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060f:	7f 36                	jg     800647 <vprintfmt+0x2aa>
  800611:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800614:	e9 b0 fd ff ff       	jmp    8003c9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800619:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061c:	83 c2 01             	add    $0x1,%edx
  80061f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800622:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800625:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800628:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80062b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80062e:	89 d3                	mov    %edx,%ebx
  800630:	85 f6                	test   %esi,%esi
  800632:	78 8e                	js     8005c2 <vprintfmt+0x225>
  800634:	83 ee 01             	sub    $0x1,%esi
  800637:	79 89                	jns    8005c2 <vprintfmt+0x225>
  800639:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800642:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800645:	eb c4                	jmp    80060b <vprintfmt+0x26e>
  800647:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80064a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800651:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800658:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065a:	83 eb 01             	sub    $0x1,%ebx
  80065d:	85 db                	test   %ebx,%ebx
  80065f:	7f ec                	jg     80064d <vprintfmt+0x2b0>
  800661:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800664:	e9 60 fd ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  800669:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066c:	83 f9 01             	cmp    $0x1,%ecx
  80066f:	7e 16                	jle    800687 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 50 08             	lea    0x8(%eax),%edx
  800677:	89 55 14             	mov    %edx,0x14(%ebp)
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	8b 48 04             	mov    0x4(%eax),%ecx
  80067f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800682:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800685:	eb 32                	jmp    8006b9 <vprintfmt+0x31c>
	else if (lflag)
  800687:	85 c9                	test   %ecx,%ecx
  800689:	74 18                	je     8006a3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8d 50 04             	lea    0x4(%eax),%edx
  800691:	89 55 14             	mov    %edx,0x14(%ebp)
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	89 c1                	mov    %eax,%ecx
  80069b:	c1 f9 1f             	sar    $0x1f,%ecx
  80069e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a1:	eb 16                	jmp    8006b9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8d 50 04             	lea    0x4(%eax),%edx
  8006a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ac:	8b 00                	mov    (%eax),%eax
  8006ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	c1 fa 1f             	sar    $0x1f,%edx
  8006b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006bf:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8006c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006c8:	0f 89 8a 00 00 00    	jns    800758 <vprintfmt+0x3bb>
				putch('-', putdat);
  8006ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006d9:	ff d7                	call   *%edi
				num = -(long long) num;
  8006db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006e1:	f7 d8                	neg    %eax
  8006e3:	83 d2 00             	adc    $0x0,%edx
  8006e6:	f7 da                	neg    %edx
  8006e8:	eb 6e                	jmp    800758 <vprintfmt+0x3bb>
  8006ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006ed:	89 ca                	mov    %ecx,%edx
  8006ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f2:	e8 4f fc ff ff       	call   800346 <getuint>
  8006f7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8006fc:	eb 5a                	jmp    800758 <vprintfmt+0x3bb>
  8006fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800701:	89 ca                	mov    %ecx,%edx
  800703:	8d 45 14             	lea    0x14(%ebp),%eax
  800706:	e8 3b fc ff ff       	call   800346 <getuint>
  80070b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800710:	eb 46                	jmp    800758 <vprintfmt+0x3bb>
  800712:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800715:	89 74 24 04          	mov    %esi,0x4(%esp)
  800719:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800720:	ff d7                	call   *%edi
			putch('x', putdat);
  800722:	89 74 24 04          	mov    %esi,0x4(%esp)
  800726:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80072d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80072f:	8b 45 14             	mov    0x14(%ebp),%eax
  800732:	8d 50 04             	lea    0x4(%eax),%edx
  800735:	89 55 14             	mov    %edx,0x14(%ebp)
  800738:	8b 00                	mov    (%eax),%eax
  80073a:	ba 00 00 00 00       	mov    $0x0,%edx
  80073f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800744:	eb 12                	jmp    800758 <vprintfmt+0x3bb>
  800746:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800749:	89 ca                	mov    %ecx,%edx
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
  80074e:	e8 f3 fb ff ff       	call   800346 <getuint>
  800753:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800758:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80075c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800760:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800763:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800767:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80076b:	89 04 24             	mov    %eax,(%esp)
  80076e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800772:	89 f2                	mov    %esi,%edx
  800774:	89 f8                	mov    %edi,%eax
  800776:	e8 d5 fa ff ff       	call   800250 <printnum>
  80077b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80077e:	e9 46 fc ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  800783:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8d 50 04             	lea    0x4(%eax),%edx
  80078c:	89 55 14             	mov    %edx,0x14(%ebp)
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	85 c0                	test   %eax,%eax
  800793:	75 24                	jne    8007b9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800795:	c7 44 24 0c 24 24 80 	movl   $0x802424,0xc(%esp)
  80079c:	00 
  80079d:	c7 44 24 08 a7 29 80 	movl   $0x8029a7,0x8(%esp)
  8007a4:	00 
  8007a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a9:	89 3c 24             	mov    %edi,(%esp)
  8007ac:	e8 ff 00 00 00       	call   8008b0 <printfmt>
  8007b1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007b4:	e9 10 fc ff ff       	jmp    8003c9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8007b9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8007bc:	7e 29                	jle    8007e7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8007be:	0f b6 16             	movzbl (%esi),%edx
  8007c1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8007c3:	c7 44 24 0c 5c 24 80 	movl   $0x80245c,0xc(%esp)
  8007ca:	00 
  8007cb:	c7 44 24 08 a7 29 80 	movl   $0x8029a7,0x8(%esp)
  8007d2:	00 
  8007d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d7:	89 3c 24             	mov    %edi,(%esp)
  8007da:	e8 d1 00 00 00       	call   8008b0 <printfmt>
  8007df:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007e2:	e9 e2 fb ff ff       	jmp    8003c9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8007e7:	0f b6 16             	movzbl (%esi),%edx
  8007ea:	88 10                	mov    %dl,(%eax)
  8007ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8007ef:	e9 d5 fb ff ff       	jmp    8003c9 <vprintfmt+0x2c>
  8007f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fe:	89 14 24             	mov    %edx,(%esp)
  800801:	ff d7                	call   *%edi
  800803:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800806:	e9 be fb ff ff       	jmp    8003c9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80080b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800816:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800818:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80081b:	80 38 25             	cmpb   $0x25,(%eax)
  80081e:	0f 84 a5 fb ff ff    	je     8003c9 <vprintfmt+0x2c>
  800824:	89 c3                	mov    %eax,%ebx
  800826:	eb f0                	jmp    800818 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800828:	83 c4 5c             	add    $0x5c,%esp
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5f                   	pop    %edi
  80082e:	5d                   	pop    %ebp
  80082f:	c3                   	ret    

00800830 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	83 ec 28             	sub    $0x28,%esp
  800836:	8b 45 08             	mov    0x8(%ebp),%eax
  800839:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 04                	je     800844 <vsnprintf+0x14>
  800840:	85 d2                	test   %edx,%edx
  800842:	7f 07                	jg     80084b <vsnprintf+0x1b>
  800844:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800849:	eb 3b                	jmp    800886 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800852:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800855:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085c:	8b 45 14             	mov    0x14(%ebp),%eax
  80085f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800863:	8b 45 10             	mov    0x10(%ebp),%eax
  800866:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800871:	c7 04 24 80 03 80 00 	movl   $0x800380,(%esp)
  800878:	e8 20 fb ff ff       	call   80039d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800880:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800883:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    

00800888 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80088e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800891:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800895:	8b 45 10             	mov    0x10(%ebp),%eax
  800898:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 82 ff ff ff       	call   800830 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008b6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	89 04 24             	mov    %eax,(%esp)
  8008d1:	e8 c7 fa ff ff       	call   80039d <vprintfmt>
	va_end(ap);
}
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    
	...

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ee:	74 09                	je     8008f9 <strlen+0x19>
		n++;
  8008f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f7:	75 f7                	jne    8008f0 <strlen+0x10>
		n++;
	return n;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	74 19                	je     800922 <strnlen+0x27>
  800909:	80 3b 00             	cmpb   $0x0,(%ebx)
  80090c:	74 14                	je     800922 <strnlen+0x27>
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800913:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800916:	39 c8                	cmp    %ecx,%eax
  800918:	74 0d                	je     800927 <strnlen+0x2c>
  80091a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80091e:	75 f3                	jne    800913 <strnlen+0x18>
  800920:	eb 05                	jmp    800927 <strnlen+0x2c>
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800939:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80093d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	84 c9                	test   %cl,%cl
  800945:	75 f2                	jne    800939 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800954:	89 1c 24             	mov    %ebx,(%esp)
  800957:	e8 84 ff ff ff       	call   8008e0 <strlen>
	strcpy(dst + len, src);
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800963:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	e8 bc ff ff ff       	call   80092a <strcpy>
	return dst;
}
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	83 c4 08             	add    $0x8,%esp
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800984:	85 f6                	test   %esi,%esi
  800986:	74 18                	je     8009a0 <strncpy+0x2a>
  800988:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80098d:	0f b6 1a             	movzbl (%edx),%ebx
  800990:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800993:	80 3a 01             	cmpb   $0x1,(%edx)
  800996:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800999:	83 c1 01             	add    $0x1,%ecx
  80099c:	39 ce                	cmp    %ecx,%esi
  80099e:	77 ed                	ja     80098d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 27                	je     8009df <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009b8:	83 e9 01             	sub    $0x1,%ecx
  8009bb:	74 1d                	je     8009da <strlcpy+0x36>
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	84 db                	test   %bl,%bl
  8009c2:	74 16                	je     8009da <strlcpy+0x36>
			*dst++ = *src++;
  8009c4:	88 18                	mov    %bl,(%eax)
  8009c6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c9:	83 e9 01             	sub    $0x1,%ecx
  8009cc:	74 0e                	je     8009dc <strlcpy+0x38>
			*dst++ = *src++;
  8009ce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d1:	0f b6 1a             	movzbl (%edx),%ebx
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	75 ec                	jne    8009c4 <strlcpy+0x20>
  8009d8:	eb 02                	jmp    8009dc <strlcpy+0x38>
  8009da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009dc:	c6 00 00             	movb   $0x0,(%eax)
  8009df:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ee:	0f b6 01             	movzbl (%ecx),%eax
  8009f1:	84 c0                	test   %al,%al
  8009f3:	74 15                	je     800a0a <strcmp+0x25>
  8009f5:	3a 02                	cmp    (%edx),%al
  8009f7:	75 11                	jne    800a0a <strcmp+0x25>
		p++, q++;
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	84 c0                	test   %al,%al
  800a04:	74 04                	je     800a0a <strcmp+0x25>
  800a06:	3a 02                	cmp    (%edx),%al
  800a08:	74 ef                	je     8009f9 <strcmp+0x14>
  800a0a:	0f b6 c0             	movzbl %al,%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a21:	85 c0                	test   %eax,%eax
  800a23:	74 23                	je     800a48 <strncmp+0x34>
  800a25:	0f b6 1a             	movzbl (%edx),%ebx
  800a28:	84 db                	test   %bl,%bl
  800a2a:	74 25                	je     800a51 <strncmp+0x3d>
  800a2c:	3a 19                	cmp    (%ecx),%bl
  800a2e:	75 21                	jne    800a51 <strncmp+0x3d>
  800a30:	83 e8 01             	sub    $0x1,%eax
  800a33:	74 13                	je     800a48 <strncmp+0x34>
		n--, p++, q++;
  800a35:	83 c2 01             	add    $0x1,%edx
  800a38:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3b:	0f b6 1a             	movzbl (%edx),%ebx
  800a3e:	84 db                	test   %bl,%bl
  800a40:	74 0f                	je     800a51 <strncmp+0x3d>
  800a42:	3a 19                	cmp    (%ecx),%bl
  800a44:	74 ea                	je     800a30 <strncmp+0x1c>
  800a46:	eb 09                	jmp    800a51 <strncmp+0x3d>
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	90                   	nop
  800a50:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 02             	movzbl (%edx),%eax
  800a54:	0f b6 11             	movzbl (%ecx),%edx
  800a57:	29 d0                	sub    %edx,%eax
  800a59:	eb f2                	jmp    800a4d <strncmp+0x39>

00800a5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a65:	0f b6 10             	movzbl (%eax),%edx
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	74 18                	je     800a84 <strchr+0x29>
		if (*s == c)
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	75 0a                	jne    800a7a <strchr+0x1f>
  800a70:	eb 17                	jmp    800a89 <strchr+0x2e>
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a78:	74 0f                	je     800a89 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	0f b6 10             	movzbl (%eax),%edx
  800a80:	84 d2                	test   %dl,%dl
  800a82:	75 ee                	jne    800a72 <strchr+0x17>
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	74 18                	je     800ab4 <strfind+0x29>
		if (*s == c)
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	75 0a                	jne    800aaa <strfind+0x1f>
  800aa0:	eb 12                	jmp    800ab4 <strfind+0x29>
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800aa8:	74 0a                	je     800ab4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 ee                	jne    800aa2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	89 1c 24             	mov    %ebx,(%esp)
  800abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ac3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad0:	85 c9                	test   %ecx,%ecx
  800ad2:	74 30                	je     800b04 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ada:	75 25                	jne    800b01 <memset+0x4b>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 20                	jne    800b01 <memset+0x4b>
		c &= 0xFF;
  800ae1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	c1 e3 08             	shl    $0x8,%ebx
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	c1 e6 18             	shl    $0x18,%esi
  800aee:	89 d0                	mov    %edx,%eax
  800af0:	c1 e0 10             	shl    $0x10,%eax
  800af3:	09 f0                	or     %esi,%eax
  800af5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800af7:	09 d8                	or     %ebx,%eax
  800af9:	c1 e9 02             	shr    $0x2,%ecx
  800afc:	fc                   	cld    
  800afd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aff:	eb 03                	jmp    800b04 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b01:	fc                   	cld    
  800b02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b04:	89 f8                	mov    %edi,%eax
  800b06:	8b 1c 24             	mov    (%esp),%ebx
  800b09:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b11:	89 ec                	mov    %ebp,%esp
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	89 34 24             	mov    %esi,(%esp)
  800b1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b2b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b2d:	39 c6                	cmp    %eax,%esi
  800b2f:	73 35                	jae    800b66 <memmove+0x51>
  800b31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 2e                	jae    800b66 <memmove+0x51>
		s += n;
		d += n;
  800b38:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	f6 c2 03             	test   $0x3,%dl
  800b3d:	75 1b                	jne    800b5a <memmove+0x45>
  800b3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b45:	75 13                	jne    800b5a <memmove+0x45>
  800b47:	f6 c1 03             	test   $0x3,%cl
  800b4a:	75 0e                	jne    800b5a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b4c:	83 ef 04             	sub    $0x4,%edi
  800b4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b52:	c1 e9 02             	shr    $0x2,%ecx
  800b55:	fd                   	std    
  800b56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b58:	eb 09                	jmp    800b63 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5a:	83 ef 01             	sub    $0x1,%edi
  800b5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b60:	fd                   	std    
  800b61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b63:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b64:	eb 20                	jmp    800b86 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6c:	75 15                	jne    800b83 <memmove+0x6e>
  800b6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b74:	75 0d                	jne    800b83 <memmove+0x6e>
  800b76:	f6 c1 03             	test   $0x3,%cl
  800b79:	75 08                	jne    800b83 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
  800b7e:	fc                   	cld    
  800b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b81:	eb 03                	jmp    800b86 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b83:	fc                   	cld    
  800b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b86:	8b 34 24             	mov    (%esp),%esi
  800b89:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b8d:	89 ec                	mov    %ebp,%esp
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b97:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	89 04 24             	mov    %eax,(%esp)
  800bab:	e8 65 ff ff ff       	call   800b15 <memmove>
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bbb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc1:	85 c9                	test   %ecx,%ecx
  800bc3:	74 36                	je     800bfb <memcmp+0x49>
		if (*s1 != *s2)
  800bc5:	0f b6 06             	movzbl (%esi),%eax
  800bc8:	0f b6 1f             	movzbl (%edi),%ebx
  800bcb:	38 d8                	cmp    %bl,%al
  800bcd:	74 20                	je     800bef <memcmp+0x3d>
  800bcf:	eb 14                	jmp    800be5 <memcmp+0x33>
  800bd1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bd6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bdb:	83 c2 01             	add    $0x1,%edx
  800bde:	83 e9 01             	sub    $0x1,%ecx
  800be1:	38 d8                	cmp    %bl,%al
  800be3:	74 12                	je     800bf7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800be5:	0f b6 c0             	movzbl %al,%eax
  800be8:	0f b6 db             	movzbl %bl,%ebx
  800beb:	29 d8                	sub    %ebx,%eax
  800bed:	eb 11                	jmp    800c00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bef:	83 e9 01             	sub    $0x1,%ecx
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	85 c9                	test   %ecx,%ecx
  800bf9:	75 d6                	jne    800bd1 <memcmp+0x1f>
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c0b:	89 c2                	mov    %eax,%edx
  800c0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c10:	39 d0                	cmp    %edx,%eax
  800c12:	73 15                	jae    800c29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c18:	38 08                	cmp    %cl,(%eax)
  800c1a:	75 06                	jne    800c22 <memfind+0x1d>
  800c1c:	eb 0b                	jmp    800c29 <memfind+0x24>
  800c1e:	38 08                	cmp    %cl,(%eax)
  800c20:	74 07                	je     800c29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	39 c2                	cmp    %eax,%edx
  800c27:	77 f5                	ja     800c1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 04             	sub    $0x4,%esp
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3a:	0f b6 02             	movzbl (%edx),%eax
  800c3d:	3c 20                	cmp    $0x20,%al
  800c3f:	74 04                	je     800c45 <strtol+0x1a>
  800c41:	3c 09                	cmp    $0x9,%al
  800c43:	75 0e                	jne    800c53 <strtol+0x28>
		s++;
  800c45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c48:	0f b6 02             	movzbl (%edx),%eax
  800c4b:	3c 20                	cmp    $0x20,%al
  800c4d:	74 f6                	je     800c45 <strtol+0x1a>
  800c4f:	3c 09                	cmp    $0x9,%al
  800c51:	74 f2                	je     800c45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c53:	3c 2b                	cmp    $0x2b,%al
  800c55:	75 0c                	jne    800c63 <strtol+0x38>
		s++;
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c61:	eb 15                	jmp    800c78 <strtol+0x4d>
	else if (*s == '-')
  800c63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c6a:	3c 2d                	cmp    $0x2d,%al
  800c6c:	75 0a                	jne    800c78 <strtol+0x4d>
		s++, neg = 1;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c78:	85 db                	test   %ebx,%ebx
  800c7a:	0f 94 c0             	sete   %al
  800c7d:	74 05                	je     800c84 <strtol+0x59>
  800c7f:	83 fb 10             	cmp    $0x10,%ebx
  800c82:	75 18                	jne    800c9c <strtol+0x71>
  800c84:	80 3a 30             	cmpb   $0x30,(%edx)
  800c87:	75 13                	jne    800c9c <strtol+0x71>
  800c89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c8d:	8d 76 00             	lea    0x0(%esi),%esi
  800c90:	75 0a                	jne    800c9c <strtol+0x71>
		s += 2, base = 16;
  800c92:	83 c2 02             	add    $0x2,%edx
  800c95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9a:	eb 15                	jmp    800cb1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9c:	84 c0                	test   %al,%al
  800c9e:	66 90                	xchg   %ax,%ax
  800ca0:	74 0f                	je     800cb1 <strtol+0x86>
  800ca2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ca7:	80 3a 30             	cmpb   $0x30,(%edx)
  800caa:	75 05                	jne    800cb1 <strtol+0x86>
		s++, base = 8;
  800cac:	83 c2 01             	add    $0x1,%edx
  800caf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb8:	0f b6 0a             	movzbl (%edx),%ecx
  800cbb:	89 cf                	mov    %ecx,%edi
  800cbd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cc0:	80 fb 09             	cmp    $0x9,%bl
  800cc3:	77 08                	ja     800ccd <strtol+0xa2>
			dig = *s - '0';
  800cc5:	0f be c9             	movsbl %cl,%ecx
  800cc8:	83 e9 30             	sub    $0x30,%ecx
  800ccb:	eb 1e                	jmp    800ceb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ccd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cd0:	80 fb 19             	cmp    $0x19,%bl
  800cd3:	77 08                	ja     800cdd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cd5:	0f be c9             	movsbl %cl,%ecx
  800cd8:	83 e9 57             	sub    $0x57,%ecx
  800cdb:	eb 0e                	jmp    800ceb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cdd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ce0:	80 fb 19             	cmp    $0x19,%bl
  800ce3:	77 15                	ja     800cfa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ce5:	0f be c9             	movsbl %cl,%ecx
  800ce8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ceb:	39 f1                	cmp    %esi,%ecx
  800ced:	7d 0b                	jge    800cfa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800cef:	83 c2 01             	add    $0x1,%edx
  800cf2:	0f af c6             	imul   %esi,%eax
  800cf5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cf8:	eb be                	jmp    800cb8 <strtol+0x8d>
  800cfa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d00:	74 05                	je     800d07 <strtol+0xdc>
		*endptr = (char *) s;
  800d02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d07:	89 ca                	mov    %ecx,%edx
  800d09:	f7 da                	neg    %edx
  800d0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d0f:	0f 45 c2             	cmovne %edx,%eax
}
  800d12:	83 c4 04             	add    $0x4,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    
	...

00800d1c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 48             	sub    $0x48,%esp
  800d22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d28:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d2b:	89 c6                	mov    %eax,%esi
  800d2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d30:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d32:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3b:	51                   	push   %ecx
  800d3c:	52                   	push   %edx
  800d3d:	53                   	push   %ebx
  800d3e:	54                   	push   %esp
  800d3f:	55                   	push   %ebp
  800d40:	56                   	push   %esi
  800d41:	57                   	push   %edi
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	8d 35 4c 0d 80 00    	lea    0x800d4c,%esi
  800d4a:	0f 34                	sysenter 

00800d4c <.after_sysenter_label>:
  800d4c:	5f                   	pop    %edi
  800d4d:	5e                   	pop    %esi
  800d4e:	5d                   	pop    %ebp
  800d4f:	5c                   	pop    %esp
  800d50:	5b                   	pop    %ebx
  800d51:	5a                   	pop    %edx
  800d52:	59                   	pop    %ecx
  800d53:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d59:	74 28                	je     800d83 <.after_sysenter_label+0x37>
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 24                	jle    800d83 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d63:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d67:	c7 44 24 08 60 26 80 	movl   $0x802660,0x8(%esp)
  800d6e:	00 
  800d6f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d76:	00 
  800d77:	c7 04 24 7d 26 80 00 	movl   $0x80267d,(%esp)
  800d7e:	e8 8d 10 00 00       	call   801e10 <_panic>

	return ret;
}
  800d83:	89 d0                	mov    %edx,%eax
  800d85:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d88:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8e:	89 ec                	mov    %ebp,%esp
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d9f:	00 
  800da0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800da7:	00 
  800da8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800daf:	00 
  800db0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800db7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dba:	ba 01 00 00 00       	mov    $0x1,%edx
  800dbf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dc4:	e8 53 ff ff ff       	call   800d1c <syscall>
}
  800dc9:	c9                   	leave  
  800dca:	c3                   	ret    

00800dcb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800dd1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dd8:	00 
  800dd9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ddc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800de0:	8b 45 10             	mov    0x10(%ebp),%eax
  800de3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dea:	89 04 24             	mov    %eax,(%esp)
  800ded:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df0:	ba 00 00 00 00       	mov    $0x0,%edx
  800df5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfa:	e8 1d ff ff ff       	call   800d1c <syscall>
}
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e16:	00 
  800e17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e1e:	00 
  800e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e22:	89 04 24             	mov    %eax,(%esp)
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	ba 01 00 00 00       	mov    $0x1,%edx
  800e2d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e32:	e8 e5 fe ff ff       	call   800d1c <syscall>
}
  800e37:	c9                   	leave  
  800e38:	c3                   	ret    

00800e39 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e39:	55                   	push   %ebp
  800e3a:	89 e5                	mov    %esp,%ebp
  800e3c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e3f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e46:	00 
  800e47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e4e:	00 
  800e4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e56:	00 
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	89 04 24             	mov    %eax,(%esp)
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e60:	ba 01 00 00 00       	mov    $0x1,%edx
  800e65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e6a:	e8 ad fe ff ff       	call   800d1c <syscall>
}
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e86:	00 
  800e87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e8e:	00 
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	89 04 24             	mov    %eax,(%esp)
  800e95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e98:	ba 01 00 00 00       	mov    $0x1,%edx
  800e9d:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea2:	e8 75 fe ff ff       	call   800d1c <syscall>
}
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800eaf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ebe:	00 
  800ebf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ec6:	00 
  800ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eca:	89 04 24             	mov    %eax,(%esp)
  800ecd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eda:	e8 3d fe ff ff       	call   800d1c <syscall>
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800ee7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eee:	00 
  800eef:	8b 45 18             	mov    0x18(%ebp),%eax
  800ef2:	0b 45 14             	or     0x14(%ebp),%eax
  800ef5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  800efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f03:	89 04 24             	mov    %eax,(%esp)
  800f06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f09:	ba 01 00 00 00       	mov    $0x1,%edx
  800f0e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f13:	e8 04 fe ff ff       	call   800d1c <syscall>
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    

00800f1a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f20:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f27:	00 
  800f28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f2f:	00 
  800f30:	8b 45 10             	mov    0x10(%ebp),%eax
  800f33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3a:	89 04 24             	mov    %eax,(%esp)
  800f3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f40:	ba 01 00 00 00       	mov    $0x1,%edx
  800f45:	b8 05 00 00 00       	mov    $0x5,%eax
  800f4a:	e8 cd fd ff ff       	call   800d1c <syscall>
}
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f5e:	00 
  800f5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f66:	00 
  800f67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6e:	00 
  800f6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f80:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f85:	e8 92 fd ff ff       	call   800d1c <syscall>
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f92:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f99:	00 
  800f9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa9:	00 
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	89 04 24             	mov    %eax,(%esp)
  800fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb8:	b8 04 00 00 00       	mov    $0x4,%eax
  800fbd:	e8 5a fd ff ff       	call   800d1c <syscall>
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd9:	00 
  800fda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fe1:	00 
  800fe2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ff8:	e8 1f fd ff ff       	call   800d1c <syscall>
}
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801005:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80100c:	00 
  80100d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801014:	00 
  801015:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80101c:	00 
  80101d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801024:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801027:	ba 01 00 00 00       	mov    $0x1,%edx
  80102c:	b8 03 00 00 00       	mov    $0x3,%eax
  801031:	e8 e6 fc ff ff       	call   800d1c <syscall>
}
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80103e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801045:	00 
  801046:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104d:	00 
  80104e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801055:	00 
  801056:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80105d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801062:	ba 00 00 00 00       	mov    $0x0,%edx
  801067:	b8 01 00 00 00       	mov    $0x1,%eax
  80106c:	e8 ab fc ff ff       	call   800d1c <syscall>
}
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801079:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801080:	00 
  801081:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801090:	00 
  801091:	8b 45 0c             	mov    0xc(%ebp),%eax
  801094:	89 04 24             	mov    %eax,(%esp)
  801097:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109a:	ba 00 00 00 00       	mov    $0x0,%edx
  80109f:	b8 00 00 00 00       	mov    $0x0,%eax
  8010a4:	e8 73 fc ff ff       	call   800d1c <syscall>
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    
	...

008010ac <sfork>:
}

// Challenge!
int
sfork(void)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010b2:	c7 44 24 08 8b 26 80 	movl   $0x80268b,0x8(%esp)
  8010b9:	00 
  8010ba:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8010c1:	00 
  8010c2:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8010c9:	e8 42 0d 00 00       	call   801e10 <_panic>

008010ce <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	57                   	push   %edi
  8010d2:	56                   	push   %esi
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  8010d7:	c7 04 24 92 13 80 00 	movl   $0x801392,(%esp)
  8010de:	e8 85 0d 00 00       	call   801e68 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  8010e3:	ba 08 00 00 00       	mov    $0x8,%edx
  8010e8:	89 d0                	mov    %edx,%eax
  8010ea:	51                   	push   %ecx
  8010eb:	52                   	push   %edx
  8010ec:	53                   	push   %ebx
  8010ed:	55                   	push   %ebp
  8010ee:	56                   	push   %esi
  8010ef:	57                   	push   %edi
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	8d 35 fa 10 80 00    	lea    0x8010fa,%esi
  8010f8:	0f 34                	sysenter 

008010fa <.after_sysenter_label>:
  8010fa:	5f                   	pop    %edi
  8010fb:	5e                   	pop    %esi
  8010fc:	5d                   	pop    %ebp
  8010fd:	5b                   	pop    %ebx
  8010fe:	5a                   	pop    %edx
  8010ff:	59                   	pop    %ecx
  801100:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801103:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801107:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  80110e:	00 
  80110f:	c7 44 24 04 a1 26 80 	movl   $0x8026a1,0x4(%esp)
  801116:	00 
  801117:	c7 04 24 fc 26 80 00 	movl   $0x8026fc,(%esp)
  80111e:	e8 ce f0 ff ff       	call   8001f1 <cprintf>
	if (envidnum < 0)
  801123:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801127:	79 23                	jns    80114c <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  801129:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80112c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801130:	c7 44 24 08 ac 26 80 	movl   $0x8026ac,0x8(%esp)
  801137:	00 
  801138:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  80113f:	00 
  801140:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801147:	e8 c4 0c 00 00       	call   801e10 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  80114c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801151:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801156:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80115b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80115f:	75 1c                	jne    80117d <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801161:	e8 5e fe ff ff       	call   800fc4 <sys_getenvid>
  801166:	25 ff 03 00 00       	and    $0x3ff,%eax
  80116b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801173:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801178:	e9 0a 02 00 00       	jmp    801387 <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	c1 e8 16             	shr    $0x16,%eax
  801182:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801185:	a8 01                	test   $0x1,%al
  801187:	0f 84 43 01 00 00    	je     8012d0 <.after_sysenter_label+0x1d6>
  80118d:	89 d8                	mov    %ebx,%eax
  80118f:	c1 e8 0c             	shr    $0xc,%eax
  801192:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801195:	f6 c2 01             	test   $0x1,%dl
  801198:	0f 84 32 01 00 00    	je     8012d0 <.after_sysenter_label+0x1d6>
  80119e:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8011a1:	f6 c2 04             	test   $0x4,%dl
  8011a4:	0f 84 26 01 00 00    	je     8012d0 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  8011aa:	c1 e0 0c             	shl    $0xc,%eax
  8011ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  8011b0:	c1 e8 0c             	shr    $0xc,%eax
  8011b3:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  8011b6:	89 c2                	mov    %eax,%edx
  8011b8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  8011be:	a9 02 08 00 00       	test   $0x802,%eax
  8011c3:	0f 84 a0 00 00 00    	je     801269 <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  8011c9:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  8011cc:	80 ce 08             	or     $0x8,%dh
  8011cf:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8011d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011f2:	e8 ea fc ff ff       	call   800ee1 <sys_page_map>
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	79 20                	jns    80121b <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  8011fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ff:	c7 44 24 08 24 27 80 	movl   $0x802724,0x8(%esp)
  801206:	00 
  801207:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  80120e:	00 
  80120f:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801216:	e8 f5 0b 00 00       	call   801e10 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80121b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80121e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801222:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801225:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801229:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801230:	00 
  801231:	89 44 24 04          	mov    %eax,0x4(%esp)
  801235:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80123c:	e8 a0 fc ff ff       	call   800ee1 <sys_page_map>
  801241:	85 c0                	test   %eax,%eax
  801243:	0f 89 87 00 00 00    	jns    8012d0 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  801249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80124d:	c7 44 24 08 50 27 80 	movl   $0x802750,0x8(%esp)
  801254:	00 
  801255:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  80125c:	00 
  80125d:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801264:	e8 a7 0b 00 00       	call   801e10 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  801269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80126c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801270:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801273:	89 44 24 04          	mov    %eax,0x4(%esp)
  801277:	c7 04 24 bc 26 80 00 	movl   $0x8026bc,(%esp)
  80127e:	e8 6e ef ff ff       	call   8001f1 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801283:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80128a:	00 
  80128b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80128e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801292:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801295:	89 44 24 08          	mov    %eax,0x8(%esp)
  801299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80129c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a7:	e8 35 fc ff ff       	call   800ee1 <sys_page_map>
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	79 20                	jns    8012d0 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  8012b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b4:	c7 44 24 08 7c 27 80 	movl   $0x80277c,0x8(%esp)
  8012bb:	00 
  8012bc:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012c3:	00 
  8012c4:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8012cb:	e8 40 0b 00 00       	call   801e10 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  8012d0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012d6:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012dc:	0f 85 9b fe ff ff    	jne    80117d <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8012e2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012e9:	00 
  8012ea:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8012f1:	ee 
  8012f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f5:	89 04 24             	mov    %eax,(%esp)
  8012f8:	e8 1d fc ff ff       	call   800f1a <sys_page_alloc>
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	79 20                	jns    801321 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801305:	c7 44 24 08 a8 27 80 	movl   $0x8027a8,0x8(%esp)
  80130c:	00 
  80130d:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801314:	00 
  801315:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  80131c:	e8 ef 0a 00 00       	call   801e10 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801321:	c7 44 24 04 d8 1e 80 	movl   $0x801ed8,0x4(%esp)
  801328:	00 
  801329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	e8 cd fa ff ff       	call   800e01 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801334:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80133b:	00 
  80133c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80133f:	89 04 24             	mov    %eax,(%esp)
  801342:	e8 2a fb ff ff       	call   800e71 <sys_env_set_status>
  801347:	85 c0                	test   %eax,%eax
  801349:	79 20                	jns    80136b <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80134b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134f:	c7 44 24 08 cc 27 80 	movl   $0x8027cc,0x8(%esp)
  801356:	00 
  801357:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  80135e:	00 
  80135f:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801366:	e8 a5 0a 00 00       	call   801e10 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80136b:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801372:	00 
  801373:	c7 44 24 04 a1 26 80 	movl   $0x8026a1,0x4(%esp)
  80137a:	00 
  80137b:	c7 04 24 ce 26 80 00 	movl   $0x8026ce,(%esp)
  801382:	e8 6a ee ff ff       	call   8001f1 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  801387:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80138a:	83 c4 3c             	add    $0x3c,%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5f                   	pop    %edi
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	57                   	push   %edi
  801396:	56                   	push   %esi
  801397:	53                   	push   %ebx
  801398:	83 ec 2c             	sub    $0x2c,%esp
  80139b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  80139e:	8b 33                	mov    (%ebx),%esi
	uint32_t err = utf->utf_err;
  8013a0:	8b 7b 04             	mov    0x4(%ebx),%edi
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
  8013a3:	8b 43 2c             	mov    0x2c(%ebx),%eax
  8013a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013aa:	c7 04 24 f4 27 80 00 	movl   $0x8027f4,(%esp)
  8013b1:	e8 3b ee ff ff       	call   8001f1 <cprintf>
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  8013b6:	f7 c7 02 00 00 00    	test   $0x2,%edi
  8013bc:	75 2b                	jne    8013e9 <pgfault+0x57>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  8013be:	8b 43 28             	mov    0x28(%ebx),%eax
  8013c1:	89 44 24 14          	mov    %eax,0x14(%esp)
  8013c5:	89 74 24 10          	mov    %esi,0x10(%esp)
  8013c9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013cd:	c7 44 24 08 14 28 80 	movl   $0x802814,0x8(%esp)
  8013d4:	00 
  8013d5:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8013dc:	00 
  8013dd:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8013e4:	e8 27 0a 00 00       	call   801e10 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  8013e9:	89 f0                	mov    %esi,%eax
  8013eb:	c1 e8 16             	shr    $0x16,%eax
  8013ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f5:	a8 01                	test   $0x1,%al
  8013f7:	74 11                	je     80140a <pgfault+0x78>
  8013f9:	89 f0                	mov    %esi,%eax
  8013fb:	c1 e8 0c             	shr    $0xc,%eax
  8013fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801405:	f6 c4 08             	test   $0x8,%ah
  801408:	75 1c                	jne    801426 <pgfault+0x94>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  80140a:	c7 44 24 08 50 28 80 	movl   $0x802850,0x8(%esp)
  801411:	00 
  801412:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801419:	00 
  80141a:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801421:	e8 ea 09 00 00       	call   801e10 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801426:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80142d:	00 
  80142e:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801435:	00 
  801436:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143d:	e8 d8 fa ff ff       	call   800f1a <sys_page_alloc>
  801442:	85 c0                	test   %eax,%eax
  801444:	79 20                	jns    801466 <pgfault+0xd4>
		panic ("pgfault: page allocation failed : %e", r);
  801446:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80144a:	c7 44 24 08 8c 28 80 	movl   $0x80288c,0x8(%esp)
  801451:	00 
  801452:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801459:	00 
  80145a:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801461:	e8 aa 09 00 00       	call   801e10 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801466:	89 f3                	mov    %esi,%ebx
  801468:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  80146e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801475:	00 
  801476:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80147a:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801481:	e8 8f f6 ff ff       	call   800b15 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801486:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80148d:	00 
  80148e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801492:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801499:	00 
  80149a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014a1:	00 
  8014a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a9:	e8 33 fa ff ff       	call   800ee1 <sys_page_map>
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	79 20                	jns    8014d2 <pgfault+0x140>
		panic ("pgfault: page mapping failed : %e", r);
  8014b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b6:	c7 44 24 08 b4 28 80 	movl   $0x8028b4,0x8(%esp)
  8014bd:	00 
  8014be:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8014c5:	00 
  8014c6:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  8014cd:	e8 3e 09 00 00       	call   801e10 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  8014d2:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014d9:	00 
  8014da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014e1:	e8 c3 f9 ff ff       	call   800ea9 <sys_page_unmap>
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	79 20                	jns    80150a <pgfault+0x178>
		panic("pgfault: page unmapping failed : %e", r);
  8014ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ee:	c7 44 24 08 d8 28 80 	movl   $0x8028d8,0x8(%esp)
  8014f5:	00 
  8014f6:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8014fd:	00 
  8014fe:	c7 04 24 a1 26 80 00 	movl   $0x8026a1,(%esp)
  801505:	e8 06 09 00 00       	call   801e10 <_panic>
	cprintf("pgfault: finish\n");
  80150a:	c7 04 24 e8 26 80 00 	movl   $0x8026e8,(%esp)
  801511:	e8 db ec ff ff       	call   8001f1 <cprintf>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801516:	83 c4 2c             	add    $0x2c,%esp
  801519:	5b                   	pop    %ebx
  80151a:	5e                   	pop    %esi
  80151b:	5f                   	pop    %edi
  80151c:	5d                   	pop    %ebp
  80151d:	c3                   	ret    
	...

00801520 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	8b 45 08             	mov    0x8(%ebp),%eax
  801526:	05 00 00 00 30       	add    $0x30000000,%eax
  80152b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 df ff ff ff       	call   801520 <fd2num>
  801541:	05 20 00 0d 00       	add    $0xd0020,%eax
  801546:	c1 e0 0c             	shl    $0xc,%eax
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	57                   	push   %edi
  80154f:	56                   	push   %esi
  801550:	53                   	push   %ebx
  801551:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801554:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801559:	a8 01                	test   $0x1,%al
  80155b:	74 36                	je     801593 <fd_alloc+0x48>
  80155d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801562:	a8 01                	test   $0x1,%al
  801564:	74 2d                	je     801593 <fd_alloc+0x48>
  801566:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80156b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801570:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801575:	89 c3                	mov    %eax,%ebx
  801577:	89 c2                	mov    %eax,%edx
  801579:	c1 ea 16             	shr    $0x16,%edx
  80157c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80157f:	f6 c2 01             	test   $0x1,%dl
  801582:	74 14                	je     801598 <fd_alloc+0x4d>
  801584:	89 c2                	mov    %eax,%edx
  801586:	c1 ea 0c             	shr    $0xc,%edx
  801589:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80158c:	f6 c2 01             	test   $0x1,%dl
  80158f:	75 10                	jne    8015a1 <fd_alloc+0x56>
  801591:	eb 05                	jmp    801598 <fd_alloc+0x4d>
  801593:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801598:	89 1f                	mov    %ebx,(%edi)
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80159f:	eb 17                	jmp    8015b8 <fd_alloc+0x6d>
  8015a1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015ab:	75 c8                	jne    801575 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015ad:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8015b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8015b8:	5b                   	pop    %ebx
  8015b9:	5e                   	pop    %esi
  8015ba:	5f                   	pop    %edi
  8015bb:	5d                   	pop    %ebp
  8015bc:	c3                   	ret    

008015bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c3:	83 f8 1f             	cmp    $0x1f,%eax
  8015c6:	77 36                	ja     8015fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015c8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8015cd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8015d0:	89 c2                	mov    %eax,%edx
  8015d2:	c1 ea 16             	shr    $0x16,%edx
  8015d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015dc:	f6 c2 01             	test   $0x1,%dl
  8015df:	74 1d                	je     8015fe <fd_lookup+0x41>
  8015e1:	89 c2                	mov    %eax,%edx
  8015e3:	c1 ea 0c             	shr    $0xc,%edx
  8015e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015ed:	f6 c2 01             	test   $0x1,%dl
  8015f0:	74 0c                	je     8015fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f5:	89 02                	mov    %eax,(%edx)
  8015f7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8015fc:	eb 05                	jmp    801603 <fd_lookup+0x46>
  8015fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801603:	5d                   	pop    %ebp
  801604:	c3                   	ret    

00801605 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80160e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801612:	8b 45 08             	mov    0x8(%ebp),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 a0 ff ff ff       	call   8015bd <fd_lookup>
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 0e                	js     80162f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801621:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801624:	8b 55 0c             	mov    0xc(%ebp),%edx
  801627:	89 50 04             	mov    %edx,0x4(%eax)
  80162a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    

00801631 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	56                   	push   %esi
  801635:	53                   	push   %ebx
  801636:	83 ec 10             	sub    $0x10,%esp
  801639:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80163c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80163f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801644:	b8 04 30 80 00       	mov    $0x803004,%eax
  801649:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80164f:	75 11                	jne    801662 <dev_lookup+0x31>
  801651:	eb 04                	jmp    801657 <dev_lookup+0x26>
  801653:	39 08                	cmp    %ecx,(%eax)
  801655:	75 10                	jne    801667 <dev_lookup+0x36>
			*dev = devtab[i];
  801657:	89 03                	mov    %eax,(%ebx)
  801659:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80165e:	66 90                	xchg   %ax,%ax
  801660:	eb 36                	jmp    801698 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801662:	be 78 29 80 00       	mov    $0x802978,%esi
  801667:	83 c2 01             	add    $0x1,%edx
  80166a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80166d:	85 c0                	test   %eax,%eax
  80166f:	75 e2                	jne    801653 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801671:	a1 04 40 80 00       	mov    0x804004,%eax
  801676:	8b 40 48             	mov    0x48(%eax),%eax
  801679:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80167d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801681:	c7 04 24 fc 28 80 00 	movl   $0x8028fc,(%esp)
  801688:	e8 64 eb ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80168d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	5b                   	pop    %ebx
  80169c:	5e                   	pop    %esi
  80169d:	5d                   	pop    %ebp
  80169e:	c3                   	ret    

0080169f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	53                   	push   %ebx
  8016a3:	83 ec 24             	sub    $0x24,%esp
  8016a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	89 04 24             	mov    %eax,(%esp)
  8016b6:	e8 02 ff ff ff       	call   8015bd <fd_lookup>
  8016bb:	85 c0                	test   %eax,%eax
  8016bd:	78 53                	js     801712 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c9:	8b 00                	mov    (%eax),%eax
  8016cb:	89 04 24             	mov    %eax,(%esp)
  8016ce:	e8 5e ff ff ff       	call   801631 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 3b                	js     801712 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8016d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016df:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8016e3:	74 2d                	je     801712 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ef:	00 00 00 
	stat->st_isdir = 0;
  8016f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f9:	00 00 00 
	stat->st_dev = dev;
  8016fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801705:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801709:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80170c:	89 14 24             	mov    %edx,(%esp)
  80170f:	ff 50 14             	call   *0x14(%eax)
}
  801712:	83 c4 24             	add    $0x24,%esp
  801715:	5b                   	pop    %ebx
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	53                   	push   %ebx
  80171c:	83 ec 24             	sub    $0x24,%esp
  80171f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	89 1c 24             	mov    %ebx,(%esp)
  80172c:	e8 8c fe ff ff       	call   8015bd <fd_lookup>
  801731:	85 c0                	test   %eax,%eax
  801733:	78 5f                	js     801794 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80173f:	8b 00                	mov    (%eax),%eax
  801741:	89 04 24             	mov    %eax,(%esp)
  801744:	e8 e8 fe ff ff       	call   801631 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 47                	js     801794 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80174d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801750:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801754:	75 23                	jne    801779 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801756:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80175b:	8b 40 48             	mov    0x48(%eax),%eax
  80175e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801762:	89 44 24 04          	mov    %eax,0x4(%esp)
  801766:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  80176d:	e8 7f ea ff ff       	call   8001f1 <cprintf>
  801772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801777:	eb 1b                	jmp    801794 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80177c:	8b 48 18             	mov    0x18(%eax),%ecx
  80177f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801784:	85 c9                	test   %ecx,%ecx
  801786:	74 0c                	je     801794 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	89 14 24             	mov    %edx,(%esp)
  801792:	ff d1                	call   *%ecx
}
  801794:	83 c4 24             	add    $0x24,%esp
  801797:	5b                   	pop    %ebx
  801798:	5d                   	pop    %ebp
  801799:	c3                   	ret    

0080179a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	53                   	push   %ebx
  80179e:	83 ec 24             	sub    $0x24,%esp
  8017a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ab:	89 1c 24             	mov    %ebx,(%esp)
  8017ae:	e8 0a fe ff ff       	call   8015bd <fd_lookup>
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 66                	js     80181d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c1:	8b 00                	mov    (%eax),%eax
  8017c3:	89 04 24             	mov    %eax,(%esp)
  8017c6:	e8 66 fe ff ff       	call   801631 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 4e                	js     80181d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017d2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017d6:	75 23                	jne    8017fb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8017dd:	8b 40 48             	mov    0x48(%eax),%eax
  8017e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e8:	c7 04 24 3d 29 80 00 	movl   $0x80293d,(%esp)
  8017ef:	e8 fd e9 ff ff       	call   8001f1 <cprintf>
  8017f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017f9:	eb 22                	jmp    80181d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fe:	8b 48 0c             	mov    0xc(%eax),%ecx
  801801:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801806:	85 c9                	test   %ecx,%ecx
  801808:	74 13                	je     80181d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180a:	8b 45 10             	mov    0x10(%ebp),%eax
  80180d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801811:	8b 45 0c             	mov    0xc(%ebp),%eax
  801814:	89 44 24 04          	mov    %eax,0x4(%esp)
  801818:	89 14 24             	mov    %edx,(%esp)
  80181b:	ff d1                	call   *%ecx
}
  80181d:	83 c4 24             	add    $0x24,%esp
  801820:	5b                   	pop    %ebx
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	53                   	push   %ebx
  801827:	83 ec 24             	sub    $0x24,%esp
  80182a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801830:	89 44 24 04          	mov    %eax,0x4(%esp)
  801834:	89 1c 24             	mov    %ebx,(%esp)
  801837:	e8 81 fd ff ff       	call   8015bd <fd_lookup>
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 6b                	js     8018ab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801843:	89 44 24 04          	mov    %eax,0x4(%esp)
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	8b 00                	mov    (%eax),%eax
  80184c:	89 04 24             	mov    %eax,(%esp)
  80184f:	e8 dd fd ff ff       	call   801631 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801854:	85 c0                	test   %eax,%eax
  801856:	78 53                	js     8018ab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801858:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80185b:	8b 42 08             	mov    0x8(%edx),%eax
  80185e:	83 e0 03             	and    $0x3,%eax
  801861:	83 f8 01             	cmp    $0x1,%eax
  801864:	75 23                	jne    801889 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801866:	a1 04 40 80 00       	mov    0x804004,%eax
  80186b:	8b 40 48             	mov    0x48(%eax),%eax
  80186e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801872:	89 44 24 04          	mov    %eax,0x4(%esp)
  801876:	c7 04 24 5a 29 80 00 	movl   $0x80295a,(%esp)
  80187d:	e8 6f e9 ff ff       	call   8001f1 <cprintf>
  801882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801887:	eb 22                	jmp    8018ab <read+0x88>
	}
	if (!dev->dev_read)
  801889:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188c:	8b 48 08             	mov    0x8(%eax),%ecx
  80188f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801894:	85 c9                	test   %ecx,%ecx
  801896:	74 13                	je     8018ab <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801898:	8b 45 10             	mov    0x10(%ebp),%eax
  80189b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80189f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a6:	89 14 24             	mov    %edx,(%esp)
  8018a9:	ff d1                	call   *%ecx
}
  8018ab:	83 c4 24             	add    $0x24,%esp
  8018ae:	5b                   	pop    %ebx
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    

008018b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	57                   	push   %edi
  8018b5:	56                   	push   %esi
  8018b6:	53                   	push   %ebx
  8018b7:	83 ec 1c             	sub    $0x1c,%esp
  8018ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8018cf:	85 f6                	test   %esi,%esi
  8018d1:	74 29                	je     8018fc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018d3:	89 f0                	mov    %esi,%eax
  8018d5:	29 d0                	sub    %edx,%eax
  8018d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018db:	03 55 0c             	add    0xc(%ebp),%edx
  8018de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018e2:	89 3c 24             	mov    %edi,(%esp)
  8018e5:	e8 39 ff ff ff       	call   801823 <read>
		if (m < 0)
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 0e                	js     8018fc <readn+0x4b>
			return m;
		if (m == 0)
  8018ee:	85 c0                	test   %eax,%eax
  8018f0:	74 08                	je     8018fa <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018f2:	01 c3                	add    %eax,%ebx
  8018f4:	89 da                	mov    %ebx,%edx
  8018f6:	39 f3                	cmp    %esi,%ebx
  8018f8:	72 d9                	jb     8018d3 <readn+0x22>
  8018fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018fc:	83 c4 1c             	add    $0x1c,%esp
  8018ff:	5b                   	pop    %ebx
  801900:	5e                   	pop    %esi
  801901:	5f                   	pop    %edi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	83 ec 28             	sub    $0x28,%esp
  80190a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80190d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801910:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801913:	89 34 24             	mov    %esi,(%esp)
  801916:	e8 05 fc ff ff       	call   801520 <fd2num>
  80191b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80191e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801922:	89 04 24             	mov    %eax,(%esp)
  801925:	e8 93 fc ff ff       	call   8015bd <fd_lookup>
  80192a:	89 c3                	mov    %eax,%ebx
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 05                	js     801935 <fd_close+0x31>
  801930:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801933:	74 0e                	je     801943 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801935:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801939:	b8 00 00 00 00       	mov    $0x0,%eax
  80193e:	0f 44 d8             	cmove  %eax,%ebx
  801941:	eb 3d                	jmp    801980 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801943:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194a:	8b 06                	mov    (%esi),%eax
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	e8 dd fc ff ff       	call   801631 <dev_lookup>
  801954:	89 c3                	mov    %eax,%ebx
  801956:	85 c0                	test   %eax,%eax
  801958:	78 16                	js     801970 <fd_close+0x6c>
		if (dev->dev_close)
  80195a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195d:	8b 40 10             	mov    0x10(%eax),%eax
  801960:	bb 00 00 00 00       	mov    $0x0,%ebx
  801965:	85 c0                	test   %eax,%eax
  801967:	74 07                	je     801970 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801969:	89 34 24             	mov    %esi,(%esp)
  80196c:	ff d0                	call   *%eax
  80196e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801970:	89 74 24 04          	mov    %esi,0x4(%esp)
  801974:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80197b:	e8 29 f5 ff ff       	call   800ea9 <sys_page_unmap>
	return r;
}
  801980:	89 d8                	mov    %ebx,%eax
  801982:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801985:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801988:	89 ec                	mov    %ebp,%esp
  80198a:	5d                   	pop    %ebp
  80198b:	c3                   	ret    

0080198c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801995:	89 44 24 04          	mov    %eax,0x4(%esp)
  801999:	8b 45 08             	mov    0x8(%ebp),%eax
  80199c:	89 04 24             	mov    %eax,(%esp)
  80199f:	e8 19 fc ff ff       	call   8015bd <fd_lookup>
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 13                	js     8019bb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019a8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019af:	00 
  8019b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b3:	89 04 24             	mov    %eax,(%esp)
  8019b6:	e8 49 ff ff ff       	call   801904 <fd_close>
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 18             	sub    $0x18,%esp
  8019c3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019c6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019d0:	00 
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	89 04 24             	mov    %eax,(%esp)
  8019d7:	e8 78 03 00 00       	call   801d54 <open>
  8019dc:	89 c3                	mov    %eax,%ebx
  8019de:	85 c0                	test   %eax,%eax
  8019e0:	78 1b                	js     8019fd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8019e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e9:	89 1c 24             	mov    %ebx,(%esp)
  8019ec:	e8 ae fc ff ff       	call   80169f <fstat>
  8019f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8019f3:	89 1c 24             	mov    %ebx,(%esp)
  8019f6:	e8 91 ff ff ff       	call   80198c <close>
  8019fb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8019fd:	89 d8                	mov    %ebx,%eax
  8019ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a05:	89 ec                	mov    %ebp,%esp
  801a07:	5d                   	pop    %ebp
  801a08:	c3                   	ret    

00801a09 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	53                   	push   %ebx
  801a0d:	83 ec 14             	sub    $0x14,%esp
  801a10:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a15:	89 1c 24             	mov    %ebx,(%esp)
  801a18:	e8 6f ff ff ff       	call   80198c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a1d:	83 c3 01             	add    $0x1,%ebx
  801a20:	83 fb 20             	cmp    $0x20,%ebx
  801a23:	75 f0                	jne    801a15 <close_all+0xc>
		close(i);
}
  801a25:	83 c4 14             	add    $0x14,%esp
  801a28:	5b                   	pop    %ebx
  801a29:	5d                   	pop    %ebp
  801a2a:	c3                   	ret    

00801a2b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 58             	sub    $0x58,%esp
  801a31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a37:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a44:	8b 45 08             	mov    0x8(%ebp),%eax
  801a47:	89 04 24             	mov    %eax,(%esp)
  801a4a:	e8 6e fb ff ff       	call   8015bd <fd_lookup>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	85 c0                	test   %eax,%eax
  801a53:	0f 88 e0 00 00 00    	js     801b39 <dup+0x10e>
		return r;
	close(newfdnum);
  801a59:	89 3c 24             	mov    %edi,(%esp)
  801a5c:	e8 2b ff ff ff       	call   80198c <close>

	newfd = INDEX2FD(newfdnum);
  801a61:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a67:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a6d:	89 04 24             	mov    %eax,(%esp)
  801a70:	e8 bb fa ff ff       	call   801530 <fd2data>
  801a75:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a77:	89 34 24             	mov    %esi,(%esp)
  801a7a:	e8 b1 fa ff ff       	call   801530 <fd2data>
  801a7f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a82:	89 da                	mov    %ebx,%edx
  801a84:	89 d8                	mov    %ebx,%eax
  801a86:	c1 e8 16             	shr    $0x16,%eax
  801a89:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a90:	a8 01                	test   $0x1,%al
  801a92:	74 43                	je     801ad7 <dup+0xac>
  801a94:	c1 ea 0c             	shr    $0xc,%edx
  801a97:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a9e:	a8 01                	test   $0x1,%al
  801aa0:	74 35                	je     801ad7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801aa2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801aa9:	25 07 0e 00 00       	and    $0xe07,%eax
  801aae:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ab2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ab5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ac0:	00 
  801ac1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ac5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801acc:	e8 10 f4 ff ff       	call   800ee1 <sys_page_map>
  801ad1:	89 c3                	mov    %eax,%ebx
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 3f                	js     801b16 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ad7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ada:	89 c2                	mov    %eax,%edx
  801adc:	c1 ea 0c             	shr    $0xc,%edx
  801adf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ae6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801aec:	89 54 24 10          	mov    %edx,0x10(%esp)
  801af0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801af4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801afb:	00 
  801afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b07:	e8 d5 f3 ff ff       	call   800ee1 <sys_page_map>
  801b0c:	89 c3                	mov    %eax,%ebx
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 04                	js     801b16 <dup+0xeb>
  801b12:	89 fb                	mov    %edi,%ebx
  801b14:	eb 23                	jmp    801b39 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b21:	e8 83 f3 ff ff       	call   800ea9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b34:	e8 70 f3 ff ff       	call   800ea9 <sys_page_unmap>
	return r;
}
  801b39:	89 d8                	mov    %ebx,%eax
  801b3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b44:	89 ec                	mov    %ebp,%esp
  801b46:	5d                   	pop    %ebp
  801b47:	c3                   	ret    

00801b48 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	83 ec 18             	sub    $0x18,%esp
  801b4e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b51:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b58:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801b5f:	75 11                	jne    801b72 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b61:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b68:	e8 93 03 00 00       	call   801f00 <ipc_find_env>
  801b6d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b72:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b79:	00 
  801b7a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b81:	00 
  801b82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b86:	a1 00 40 80 00       	mov    0x804000,%eax
  801b8b:	89 04 24             	mov    %eax,(%esp)
  801b8e:	e8 b1 03 00 00       	call   801f44 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b9a:	00 
  801b9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba6:	e8 08 04 00 00       	call   801fb3 <ipc_recv>
}
  801bab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bb1:	89 ec                	mov    %ebp,%esp
  801bb3:	5d                   	pop    %ebp
  801bb4:	c3                   	ret    

00801bb5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bce:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd3:	b8 02 00 00 00       	mov    $0x2,%eax
  801bd8:	e8 6b ff ff ff       	call   801b48 <fsipc>
}
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	8b 40 0c             	mov    0xc(%eax),%eax
  801beb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  801bfa:	e8 49 ff ff ff       	call   801b48 <fsipc>
}
  801bff:	c9                   	leave  
  801c00:	c3                   	ret    

00801c01 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c07:	ba 00 00 00 00       	mov    $0x0,%edx
  801c0c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c11:	e8 32 ff ff ff       	call   801b48 <fsipc>
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 14             	sub    $0x14,%esp
  801c1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	8b 40 0c             	mov    0xc(%eax),%eax
  801c28:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c32:	b8 05 00 00 00       	mov    $0x5,%eax
  801c37:	e8 0c ff ff ff       	call   801b48 <fsipc>
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	78 2b                	js     801c6b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c40:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c47:	00 
  801c48:	89 1c 24             	mov    %ebx,(%esp)
  801c4b:	e8 da ec ff ff       	call   80092a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c50:	a1 80 50 80 00       	mov    0x805080,%eax
  801c55:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c5b:	a1 84 50 80 00       	mov    0x805084,%eax
  801c60:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c66:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c6b:	83 c4 14             	add    $0x14,%esp
  801c6e:	5b                   	pop    %ebx
  801c6f:	5d                   	pop    %ebp
  801c70:	c3                   	ret    

00801c71 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c71:	55                   	push   %ebp
  801c72:	89 e5                	mov    %esp,%ebp
  801c74:	83 ec 18             	sub    $0x18,%esp
  801c77:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c7d:	8b 52 0c             	mov    0xc(%edx),%edx
  801c80:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801c86:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801c8b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c90:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c95:	0f 47 c2             	cmova  %edx,%eax
  801c98:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801caa:	e8 66 ee ff ff       	call   800b15 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801caf:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb4:	b8 04 00 00 00       	mov    $0x4,%eax
  801cb9:	e8 8a fe ff ff       	call   801b48 <fsipc>
}
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cca:	8b 40 0c             	mov    0xc(%eax),%eax
  801ccd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801cda:	ba 00 00 00 00       	mov    $0x0,%edx
  801cdf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ce4:	e8 5f fe ff ff       	call   801b48 <fsipc>
  801ce9:	89 c3                	mov    %eax,%ebx
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	78 17                	js     801d06 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cef:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cf3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801cfa:	00 
  801cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 0f ee ff ff       	call   800b15 <memmove>
  return r;	
}
  801d06:	89 d8                	mov    %ebx,%eax
  801d08:	83 c4 14             	add    $0x14,%esp
  801d0b:	5b                   	pop    %ebx
  801d0c:	5d                   	pop    %ebp
  801d0d:	c3                   	ret    

00801d0e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d0e:	55                   	push   %ebp
  801d0f:	89 e5                	mov    %esp,%ebp
  801d11:	53                   	push   %ebx
  801d12:	83 ec 14             	sub    $0x14,%esp
  801d15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d18:	89 1c 24             	mov    %ebx,(%esp)
  801d1b:	e8 c0 eb ff ff       	call   8008e0 <strlen>
  801d20:	89 c2                	mov    %eax,%edx
  801d22:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d27:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d2d:	7f 1f                	jg     801d4e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d33:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d3a:	e8 eb eb ff ff       	call   80092a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d44:	b8 07 00 00 00       	mov    $0x7,%eax
  801d49:	e8 fa fd ff ff       	call   801b48 <fsipc>
}
  801d4e:	83 c4 14             	add    $0x14,%esp
  801d51:	5b                   	pop    %ebx
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 28             	sub    $0x28,%esp
  801d5a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d5d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d60:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d66:	89 04 24             	mov    %eax,(%esp)
  801d69:	e8 dd f7 ff ff       	call   80154b <fd_alloc>
  801d6e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801d70:	85 c0                	test   %eax,%eax
  801d72:	0f 88 89 00 00 00    	js     801e01 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801d78:	89 34 24             	mov    %esi,(%esp)
  801d7b:	e8 60 eb ff ff       	call   8008e0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801d80:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801d85:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d8a:	7f 75                	jg     801e01 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801d8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d90:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d97:	e8 8e eb ff ff       	call   80092a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801da7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dac:	e8 97 fd ff ff       	call   801b48 <fsipc>
  801db1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801db3:	85 c0                	test   %eax,%eax
  801db5:	78 0f                	js     801dc6 <open+0x72>
  return fd2num(fd);
  801db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dba:	89 04 24             	mov    %eax,(%esp)
  801dbd:	e8 5e f7 ff ff       	call   801520 <fd2num>
  801dc2:	89 c3                	mov    %eax,%ebx
  801dc4:	eb 3b                	jmp    801e01 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801dc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dcd:	00 
  801dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd1:	89 04 24             	mov    %eax,(%esp)
  801dd4:	e8 2b fb ff ff       	call   801904 <fd_close>
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	74 24                	je     801e01 <open+0xad>
  801ddd:	c7 44 24 0c 80 29 80 	movl   $0x802980,0xc(%esp)
  801de4:	00 
  801de5:	c7 44 24 08 95 29 80 	movl   $0x802995,0x8(%esp)
  801dec:	00 
  801ded:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801df4:	00 
  801df5:	c7 04 24 aa 29 80 00 	movl   $0x8029aa,(%esp)
  801dfc:	e8 0f 00 00 00       	call   801e10 <_panic>
  return r;
}
  801e01:	89 d8                	mov    %ebx,%eax
  801e03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e09:	89 ec                	mov    %ebp,%esp
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	00 00                	add    %al,(%eax)
	...

00801e10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e10:	55                   	push   %ebp
  801e11:	89 e5                	mov    %esp,%ebp
  801e13:	56                   	push   %esi
  801e14:	53                   	push   %ebx
  801e15:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801e18:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e1b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e21:	e8 9e f1 ff ff       	call   800fc4 <sys_getenvid>
  801e26:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e29:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  801e30:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e34:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3c:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  801e43:	e8 a9 e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e48:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e4f:	89 04 24             	mov    %eax,(%esp)
  801e52:	e8 39 e3 ff ff       	call   800190 <vcprintf>
	cprintf("\n");
  801e57:	c7 04 24 d4 22 80 00 	movl   $0x8022d4,(%esp)
  801e5e:	e8 8e e3 ff ff       	call   8001f1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e63:	cc                   	int3   
  801e64:	eb fd                	jmp    801e63 <_panic+0x53>
	...

00801e68 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e6e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e75:	75 54                	jne    801ecb <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801e77:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e7e:	00 
  801e7f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801e86:	ee 
  801e87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e8e:	e8 87 f0 ff ff       	call   800f1a <sys_page_alloc>
  801e93:	85 c0                	test   %eax,%eax
  801e95:	79 20                	jns    801eb7 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  801e97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e9b:	c7 44 24 08 dc 29 80 	movl   $0x8029dc,0x8(%esp)
  801ea2:	00 
  801ea3:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801eaa:	00 
  801eab:	c7 04 24 f4 29 80 00 	movl   $0x8029f4,(%esp)
  801eb2:	e8 59 ff ff ff       	call   801e10 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  801eb7:	c7 44 24 04 d8 1e 80 	movl   $0x801ed8,0x4(%esp)
  801ebe:	00 
  801ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec6:	e8 36 ef ff ff       	call   800e01 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801ed3:	c9                   	leave  
  801ed4:	c3                   	ret    
  801ed5:	00 00                	add    %al,(%eax)
	...

00801ed8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ed8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ed9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ede:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ee0:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  801ee3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801ee7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801eea:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  801eee:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801ef2:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  801ef4:	83 c4 08             	add    $0x8,%esp
	popal
  801ef7:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  801ef8:	83 c4 04             	add    $0x4,%esp
	popfl
  801efb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801efc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801efd:	c3                   	ret    
	...

00801f00 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f00:	55                   	push   %ebp
  801f01:	89 e5                	mov    %esp,%ebp
  801f03:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f06:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f11:	39 ca                	cmp    %ecx,%edx
  801f13:	75 04                	jne    801f19 <ipc_find_env+0x19>
  801f15:	b0 00                	mov    $0x0,%al
  801f17:	eb 0f                	jmp    801f28 <ipc_find_env+0x28>
  801f19:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f1c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801f22:	8b 12                	mov    (%edx),%edx
  801f24:	39 ca                	cmp    %ecx,%edx
  801f26:	75 0c                	jne    801f34 <ipc_find_env+0x34>
			return envs[i].env_id;
  801f28:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f2b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801f30:	8b 00                	mov    (%eax),%eax
  801f32:	eb 0e                	jmp    801f42 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f34:	83 c0 01             	add    $0x1,%eax
  801f37:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f3c:	75 db                	jne    801f19 <ipc_find_env+0x19>
  801f3e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	57                   	push   %edi
  801f48:	56                   	push   %esi
  801f49:	53                   	push   %ebx
  801f4a:	83 ec 1c             	sub    $0x1c,%esp
  801f4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f50:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f56:	85 db                	test   %ebx,%ebx
  801f58:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f5d:	0f 44 d8             	cmove  %eax,%ebx
  801f60:	eb 29                	jmp    801f8b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801f62:	85 c0                	test   %eax,%eax
  801f64:	79 25                	jns    801f8b <ipc_send+0x47>
  801f66:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f69:	74 20                	je     801f8b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6f:	c7 44 24 08 02 2a 80 	movl   $0x802a02,0x8(%esp)
  801f76:	00 
  801f77:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f7e:	00 
  801f7f:	c7 04 24 20 2a 80 00 	movl   $0x802a20,(%esp)
  801f86:	e8 85 fe ff ff       	call   801e10 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f9a:	89 34 24             	mov    %esi,(%esp)
  801f9d:	e8 29 ee ff ff       	call   800dcb <sys_ipc_try_send>
  801fa2:	85 c0                	test   %eax,%eax
  801fa4:	75 bc                	jne    801f62 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801fa6:	e8 a6 ef ff ff       	call   800f51 <sys_yield>
}
  801fab:	83 c4 1c             	add    $0x1c,%esp
  801fae:	5b                   	pop    %ebx
  801faf:	5e                   	pop    %esi
  801fb0:	5f                   	pop    %edi
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	83 ec 28             	sub    $0x28,%esp
  801fb9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801fbc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801fbf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801fc2:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801fcb:	85 c0                	test   %eax,%eax
  801fcd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fd2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801fd5:	89 04 24             	mov    %eax,(%esp)
  801fd8:	e8 b5 ed ff ff       	call   800d92 <sys_ipc_recv>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	79 2a                	jns    80200d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801fe3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801feb:	c7 04 24 2a 2a 80 00 	movl   $0x802a2a,(%esp)
  801ff2:	e8 fa e1 ff ff       	call   8001f1 <cprintf>
		if(from_env_store != NULL)
  801ff7:	85 f6                	test   %esi,%esi
  801ff9:	74 06                	je     802001 <ipc_recv+0x4e>
			*from_env_store = 0;
  801ffb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802001:	85 ff                	test   %edi,%edi
  802003:	74 2d                	je     802032 <ipc_recv+0x7f>
			*perm_store = 0;
  802005:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80200b:	eb 25                	jmp    802032 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  80200d:	85 f6                	test   %esi,%esi
  80200f:	90                   	nop
  802010:	74 0a                	je     80201c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  802012:	a1 04 40 80 00       	mov    0x804004,%eax
  802017:	8b 40 74             	mov    0x74(%eax),%eax
  80201a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80201c:	85 ff                	test   %edi,%edi
  80201e:	74 0a                	je     80202a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  802020:	a1 04 40 80 00       	mov    0x804004,%eax
  802025:	8b 40 78             	mov    0x78(%eax),%eax
  802028:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80202a:	a1 04 40 80 00       	mov    0x804004,%eax
  80202f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802032:	89 d8                	mov    %ebx,%eax
  802034:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802037:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80203a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80203d:	89 ec                	mov    %ebp,%esp
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    
	...

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	57                   	push   %edi
  802054:	56                   	push   %esi
  802055:	83 ec 10             	sub    $0x10,%esp
  802058:	8b 45 14             	mov    0x14(%ebp),%eax
  80205b:	8b 55 08             	mov    0x8(%ebp),%edx
  80205e:	8b 75 10             	mov    0x10(%ebp),%esi
  802061:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802064:	85 c0                	test   %eax,%eax
  802066:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802069:	75 35                	jne    8020a0 <__udivdi3+0x50>
  80206b:	39 fe                	cmp    %edi,%esi
  80206d:	77 61                	ja     8020d0 <__udivdi3+0x80>
  80206f:	85 f6                	test   %esi,%esi
  802071:	75 0b                	jne    80207e <__udivdi3+0x2e>
  802073:	b8 01 00 00 00       	mov    $0x1,%eax
  802078:	31 d2                	xor    %edx,%edx
  80207a:	f7 f6                	div    %esi
  80207c:	89 c6                	mov    %eax,%esi
  80207e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f8                	mov    %edi,%eax
  802085:	f7 f6                	div    %esi
  802087:	89 c7                	mov    %eax,%edi
  802089:	89 c8                	mov    %ecx,%eax
  80208b:	f7 f6                	div    %esi
  80208d:	89 c1                	mov    %eax,%ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	89 c8                	mov    %ecx,%eax
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	5e                   	pop    %esi
  802097:	5f                   	pop    %edi
  802098:	5d                   	pop    %ebp
  802099:	c3                   	ret    
  80209a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a0:	39 f8                	cmp    %edi,%eax
  8020a2:	77 1c                	ja     8020c0 <__udivdi3+0x70>
  8020a4:	0f bd d0             	bsr    %eax,%edx
  8020a7:	83 f2 1f             	xor    $0x1f,%edx
  8020aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020ad:	75 39                	jne    8020e8 <__udivdi3+0x98>
  8020af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020b2:	0f 86 a0 00 00 00    	jbe    802158 <__udivdi3+0x108>
  8020b8:	39 f8                	cmp    %edi,%eax
  8020ba:	0f 82 98 00 00 00    	jb     802158 <__udivdi3+0x108>
  8020c0:	31 ff                	xor    %edi,%edi
  8020c2:	31 c9                	xor    %ecx,%ecx
  8020c4:	89 c8                	mov    %ecx,%eax
  8020c6:	89 fa                	mov    %edi,%edx
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	5e                   	pop    %esi
  8020cc:	5f                   	pop    %edi
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    
  8020cf:	90                   	nop
  8020d0:	89 d1                	mov    %edx,%ecx
  8020d2:	89 fa                	mov    %edi,%edx
  8020d4:	89 c8                	mov    %ecx,%eax
  8020d6:	31 ff                	xor    %edi,%edi
  8020d8:	f7 f6                	div    %esi
  8020da:	89 c1                	mov    %eax,%ecx
  8020dc:	89 fa                	mov    %edi,%edx
  8020de:	89 c8                	mov    %ecx,%eax
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	5e                   	pop    %esi
  8020e4:	5f                   	pop    %edi
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    
  8020e7:	90                   	nop
  8020e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020ec:	89 f2                	mov    %esi,%edx
  8020ee:	d3 e0                	shl    %cl,%eax
  8020f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8020fb:	89 c1                	mov    %eax,%ecx
  8020fd:	d3 ea                	shr    %cl,%edx
  8020ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802103:	0b 55 ec             	or     -0x14(%ebp),%edx
  802106:	d3 e6                	shl    %cl,%esi
  802108:	89 c1                	mov    %eax,%ecx
  80210a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80210d:	89 fe                	mov    %edi,%esi
  80210f:	d3 ee                	shr    %cl,%esi
  802111:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802115:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802118:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80211b:	d3 e7                	shl    %cl,%edi
  80211d:	89 c1                	mov    %eax,%ecx
  80211f:	d3 ea                	shr    %cl,%edx
  802121:	09 d7                	or     %edx,%edi
  802123:	89 f2                	mov    %esi,%edx
  802125:	89 f8                	mov    %edi,%eax
  802127:	f7 75 ec             	divl   -0x14(%ebp)
  80212a:	89 d6                	mov    %edx,%esi
  80212c:	89 c7                	mov    %eax,%edi
  80212e:	f7 65 e8             	mull   -0x18(%ebp)
  802131:	39 d6                	cmp    %edx,%esi
  802133:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802136:	72 30                	jb     802168 <__udivdi3+0x118>
  802138:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80213b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	39 c2                	cmp    %eax,%edx
  802143:	73 05                	jae    80214a <__udivdi3+0xfa>
  802145:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802148:	74 1e                	je     802168 <__udivdi3+0x118>
  80214a:	89 f9                	mov    %edi,%ecx
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	e9 71 ff ff ff       	jmp    8020c4 <__udivdi3+0x74>
  802153:	90                   	nop
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80215f:	e9 60 ff ff ff       	jmp    8020c4 <__udivdi3+0x74>
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80216b:	31 ff                	xor    %edi,%edi
  80216d:	89 c8                	mov    %ecx,%eax
  80216f:	89 fa                	mov    %edi,%edx
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
	...

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	57                   	push   %edi
  802184:	56                   	push   %esi
  802185:	83 ec 20             	sub    $0x20,%esp
  802188:	8b 55 14             	mov    0x14(%ebp),%edx
  80218b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802191:	8b 75 0c             	mov    0xc(%ebp),%esi
  802194:	85 d2                	test   %edx,%edx
  802196:	89 c8                	mov    %ecx,%eax
  802198:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80219b:	75 13                	jne    8021b0 <__umoddi3+0x30>
  80219d:	39 f7                	cmp    %esi,%edi
  80219f:	76 3f                	jbe    8021e0 <__umoddi3+0x60>
  8021a1:	89 f2                	mov    %esi,%edx
  8021a3:	f7 f7                	div    %edi
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	31 d2                	xor    %edx,%edx
  8021a9:	83 c4 20             	add    $0x20,%esp
  8021ac:	5e                   	pop    %esi
  8021ad:	5f                   	pop    %edi
  8021ae:	5d                   	pop    %ebp
  8021af:	c3                   	ret    
  8021b0:	39 f2                	cmp    %esi,%edx
  8021b2:	77 4c                	ja     802200 <__umoddi3+0x80>
  8021b4:	0f bd ca             	bsr    %edx,%ecx
  8021b7:	83 f1 1f             	xor    $0x1f,%ecx
  8021ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021bd:	75 51                	jne    802210 <__umoddi3+0x90>
  8021bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021c2:	0f 87 e0 00 00 00    	ja     8022a8 <__umoddi3+0x128>
  8021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cb:	29 f8                	sub    %edi,%eax
  8021cd:	19 d6                	sbb    %edx,%esi
  8021cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d5:	89 f2                	mov    %esi,%edx
  8021d7:	83 c4 20             	add    $0x20,%esp
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	75 0b                	jne    8021ef <__umoddi3+0x6f>
  8021e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e9:	31 d2                	xor    %edx,%edx
  8021eb:	f7 f7                	div    %edi
  8021ed:	89 c7                	mov    %eax,%edi
  8021ef:	89 f0                	mov    %esi,%eax
  8021f1:	31 d2                	xor    %edx,%edx
  8021f3:	f7 f7                	div    %edi
  8021f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f8:	f7 f7                	div    %edi
  8021fa:	eb a9                	jmp    8021a5 <__umoddi3+0x25>
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 20             	add    $0x20,%esp
  802207:	5e                   	pop    %esi
  802208:	5f                   	pop    %edi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    
  80220b:	90                   	nop
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802214:	d3 e2                	shl    %cl,%edx
  802216:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802219:	ba 20 00 00 00       	mov    $0x20,%edx
  80221e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802221:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802224:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802228:	89 fa                	mov    %edi,%edx
  80222a:	d3 ea                	shr    %cl,%edx
  80222c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802230:	0b 55 f4             	or     -0xc(%ebp),%edx
  802233:	d3 e7                	shl    %cl,%edi
  802235:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802239:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80223c:	89 f2                	mov    %esi,%edx
  80223e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802241:	89 c7                	mov    %eax,%edi
  802243:	d3 ea                	shr    %cl,%edx
  802245:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802249:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80224c:	89 c2                	mov    %eax,%edx
  80224e:	d3 e6                	shl    %cl,%esi
  802250:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802254:	d3 ea                	shr    %cl,%edx
  802256:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80225a:	09 d6                	or     %edx,%esi
  80225c:	89 f0                	mov    %esi,%eax
  80225e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802261:	d3 e7                	shl    %cl,%edi
  802263:	89 f2                	mov    %esi,%edx
  802265:	f7 75 f4             	divl   -0xc(%ebp)
  802268:	89 d6                	mov    %edx,%esi
  80226a:	f7 65 e8             	mull   -0x18(%ebp)
  80226d:	39 d6                	cmp    %edx,%esi
  80226f:	72 2b                	jb     80229c <__umoddi3+0x11c>
  802271:	39 c7                	cmp    %eax,%edi
  802273:	72 23                	jb     802298 <__umoddi3+0x118>
  802275:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802279:	29 c7                	sub    %eax,%edi
  80227b:	19 d6                	sbb    %edx,%esi
  80227d:	89 f0                	mov    %esi,%eax
  80227f:	89 f2                	mov    %esi,%edx
  802281:	d3 ef                	shr    %cl,%edi
  802283:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802287:	d3 e0                	shl    %cl,%eax
  802289:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80228d:	09 f8                	or     %edi,%eax
  80228f:	d3 ea                	shr    %cl,%edx
  802291:	83 c4 20             	add    $0x20,%esp
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
  802298:	39 d6                	cmp    %edx,%esi
  80229a:	75 d9                	jne    802275 <__umoddi3+0xf5>
  80229c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80229f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022a2:	eb d1                	jmp    802275 <__umoddi3+0xf5>
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	0f 82 18 ff ff ff    	jb     8021c8 <__umoddi3+0x48>
  8022b0:	e9 1d ff ff ff       	jmp    8021d2 <__umoddi3+0x52>
