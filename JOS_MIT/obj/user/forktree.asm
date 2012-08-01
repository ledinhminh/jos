
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
  80006d:	c7 44 24 08 60 28 80 	movl   $0x802860,0x8(%esp)
  800074:	00 
  800075:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80007c:	00 
  80007d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800080:	89 04 24             	mov    %eax,(%esp)
  800083:	e8 00 08 00 00       	call   800888 <snprintf>
	if (fork() == 0) {
  800088:	e8 b5 10 00 00       	call   801142 <fork>
  80008d:	85 c0                	test   %eax,%eax
  80008f:	75 29                	jne    8000ba <forkchild+0x7a>
		cprintf("%04x: I am '%c'\n", sys_getenvid(), branch);
  800091:	e8 a1 0f 00 00       	call   801037 <sys_getenvid>
  800096:	89 74 24 08          	mov    %esi,0x8(%esp)
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 65 28 80 00 	movl   $0x802865,(%esp)
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
  8000ce:	e8 64 0f 00 00       	call   801037 <sys_getenvid>
  8000d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000db:	c7 04 24 76 28 80 00 	movl   $0x802876,(%esp)
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
  800113:	c7 04 24 75 28 80 00 	movl   $0x802875,(%esp)
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
  800136:	e8 fc 0e 00 00       	call   801037 <sys_getenvid>
  80013b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800140:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800143:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800148:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80017a:	e8 da 18 00 00       	call   801a59 <close_all>
	sys_env_destroy(0);
  80017f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800186:	e8 e7 0e 00 00       	call   801072 <sys_env_destroy>
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
  8001e4:	e8 fd 0e 00 00       	call   8010e6 <sys_cputs>

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
  800238:	e8 a9 0e 00 00       	call   8010e6 <sys_cputs>
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
  8002cd:	e8 0e 23 00 00       	call   8025e0 <__udivdi3>
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
  800328:	e8 e3 23 00 00       	call   802710 <__umoddi3>
  80032d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800331:	0f be 80 91 28 80 00 	movsbl 0x802891(%eax),%eax
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
  800415:	ff 24 95 60 2a 80 00 	jmp    *0x802a60(,%edx,4)
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
  8004e8:	8b 14 85 c0 2b 80 00 	mov    0x802bc0(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	75 20                	jne    800513 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8004f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f7:	c7 44 24 08 a2 28 80 	movl   $0x8028a2,0x8(%esp)
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
  800517:	c7 44 24 08 17 2f 80 	movl   $0x802f17,0x8(%esp)
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
  800551:	b8 ab 28 80 00       	mov    $0x8028ab,%eax
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
  800795:	c7 44 24 0c c4 29 80 	movl   $0x8029c4,0xc(%esp)
  80079c:	00 
  80079d:	c7 44 24 08 17 2f 80 	movl   $0x802f17,0x8(%esp)
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
  8007c3:	c7 44 24 0c fc 29 80 	movl   $0x8029fc,0xc(%esp)
  8007ca:	00 
  8007cb:	c7 44 24 08 17 2f 80 	movl   $0x802f17,0x8(%esp)
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
  800d67:	c7 44 24 08 00 2c 80 	movl   $0x802c00,0x8(%esp)
  800d6e:	00 
  800d6f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d76:	00 
  800d77:	c7 04 24 1d 2c 80 00 	movl   $0x802c1d,(%esp)
  800d7e:	e8 e1 15 00 00       	call   802364 <_panic>

	return ret;
}
  800d83:	89 d0                	mov    %edx,%eax
  800d85:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d88:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d8e:	89 ec                	mov    %ebp,%esp
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    

00800d92 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800d92:	55                   	push   %ebp
  800d93:	89 e5                	mov    %esp,%ebp
  800d95:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800d98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d9f:	00 
  800da0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800da7:	00 
  800da8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800daf:	00 
  800db0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db3:	89 04 24             	mov    %eax,(%esp)
  800db6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbe:	b8 10 00 00 00       	mov    $0x10,%eax
  800dc3:	e8 54 ff ff ff       	call   800d1c <syscall>
}
  800dc8:	c9                   	leave  
  800dc9:	c3                   	ret    

00800dca <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800dd0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ddf:	00 
  800de0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800de7:	00 
  800de8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800def:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df4:	ba 00 00 00 00       	mov    $0x0,%edx
  800df9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dfe:	e8 19 ff ff ff       	call   800d1c <syscall>
}
  800e03:	c9                   	leave  
  800e04:	c3                   	ret    

00800e05 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e0b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e12:	00 
  800e13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e1a:	00 
  800e1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e22:	00 
  800e23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e32:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e37:	e8 e0 fe ff ff       	call   800d1c <syscall>
}
  800e3c:	c9                   	leave  
  800e3d:	c3                   	ret    

00800e3e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e44:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e4b:	00 
  800e4c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e53:	8b 45 10             	mov    0x10(%ebp),%eax
  800e56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5d:	89 04 24             	mov    %eax,(%esp)
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	ba 00 00 00 00       	mov    $0x0,%edx
  800e68:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e6d:	e8 aa fe ff ff       	call   800d1c <syscall>
}
  800e72:	c9                   	leave  
  800e73:	c3                   	ret    

00800e74 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e7a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e81:	00 
  800e82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e89:	00 
  800e8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e91:	00 
  800e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e95:	89 04 24             	mov    %eax,(%esp)
  800e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9b:	ba 01 00 00 00       	mov    $0x1,%edx
  800ea0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ea5:	e8 72 fe ff ff       	call   800d1c <syscall>
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800eb2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eb9:	00 
  800eba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ec1:	00 
  800ec2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ec9:	00 
  800eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecd:	89 04 24             	mov    %eax,(%esp)
  800ed0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800edd:	e8 3a fe ff ff       	call   800d1c <syscall>
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800eea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef9:	00 
  800efa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f01:	00 
  800f02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f05:	89 04 24             	mov    %eax,(%esp)
  800f08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f10:	b8 09 00 00 00       	mov    $0x9,%eax
  800f15:	e8 02 fe ff ff       	call   800d1c <syscall>
}
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f22:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f29:	00 
  800f2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f31:	00 
  800f32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f39:	00 
  800f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3d:	89 04 24             	mov    %eax,(%esp)
  800f40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f43:	ba 01 00 00 00       	mov    $0x1,%edx
  800f48:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4d:	e8 ca fd ff ff       	call   800d1c <syscall>
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f5a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f61:	00 
  800f62:	8b 45 18             	mov    0x18(%ebp),%eax
  800f65:	0b 45 14             	or     0x14(%ebp),%eax
  800f68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f76:	89 04 24             	mov    %eax,(%esp)
  800f79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f81:	b8 06 00 00 00       	mov    $0x6,%eax
  800f86:	e8 91 fd ff ff       	call   800d1c <syscall>
}
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f93:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fa2:	00 
  800fa3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	89 04 24             	mov    %eax,(%esp)
  800fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fbd:	e8 5a fd ff ff       	call   800d1c <syscall>
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd9:	00 
  800fda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fe1:	00 
  800fe2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ff8:	e8 1f fd ff ff       	call   800d1c <syscall>
}
  800ffd:	c9                   	leave  
  800ffe:	c3                   	ret    

00800fff <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801005:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80100c:	00 
  80100d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801014:	00 
  801015:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80101c:	00 
  80101d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801020:	89 04 24             	mov    %eax,(%esp)
  801023:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801026:	ba 00 00 00 00       	mov    $0x0,%edx
  80102b:	b8 04 00 00 00       	mov    $0x4,%eax
  801030:	e8 e7 fc ff ff       	call   800d1c <syscall>
}
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80103d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801044:	00 
  801045:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104c:	00 
  80104d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801054:	00 
  801055:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80105c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801061:	ba 00 00 00 00       	mov    $0x0,%edx
  801066:	b8 02 00 00 00       	mov    $0x2,%eax
  80106b:	e8 ac fc ff ff       	call   800d1c <syscall>
}
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801078:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80107f:	00 
  801080:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801087:	00 
  801088:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80108f:	00 
  801090:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801097:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109a:	ba 01 00 00 00       	mov    $0x1,%edx
  80109f:	b8 03 00 00 00       	mov    $0x3,%eax
  8010a4:	e8 73 fc ff ff       	call   800d1c <syscall>
}
  8010a9:	c9                   	leave  
  8010aa:	c3                   	ret    

008010ab <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010b8:	00 
  8010b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c0:	00 
  8010c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010da:	b8 01 00 00 00       	mov    $0x1,%eax
  8010df:	e8 38 fc ff ff       	call   800d1c <syscall>
}
  8010e4:	c9                   	leave  
  8010e5:	c3                   	ret    

008010e6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010e6:	55                   	push   %ebp
  8010e7:	89 e5                	mov    %esp,%ebp
  8010e9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801103:	00 
  801104:	8b 45 0c             	mov    0xc(%ebp),%eax
  801107:	89 04 24             	mov    %eax,(%esp)
  80110a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110d:	ba 00 00 00 00       	mov    $0x0,%edx
  801112:	b8 00 00 00 00       	mov    $0x0,%eax
  801117:	e8 00 fc ff ff       	call   800d1c <syscall>
}
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    
	...

00801120 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801126:	c7 44 24 08 2b 2c 80 	movl   $0x802c2b,0x8(%esp)
  80112d:	00 
  80112e:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801135:	00 
  801136:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80113d:	e8 22 12 00 00       	call   802364 <_panic>

00801142 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  80114b:	c7 04 24 06 14 80 00 	movl   $0x801406,(%esp)
  801152:	e8 65 12 00 00       	call   8023bc <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801157:	ba 08 00 00 00       	mov    $0x8,%edx
  80115c:	89 d0                	mov    %edx,%eax
  80115e:	51                   	push   %ecx
  80115f:	52                   	push   %edx
  801160:	53                   	push   %ebx
  801161:	55                   	push   %ebp
  801162:	56                   	push   %esi
  801163:	57                   	push   %edi
  801164:	89 e5                	mov    %esp,%ebp
  801166:	8d 35 6e 11 80 00    	lea    0x80116e,%esi
  80116c:	0f 34                	sysenter 

0080116e <.after_sysenter_label>:
  80116e:	5f                   	pop    %edi
  80116f:	5e                   	pop    %esi
  801170:	5d                   	pop    %ebp
  801171:	5b                   	pop    %ebx
  801172:	5a                   	pop    %edx
  801173:	59                   	pop    %ecx
  801174:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801177:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  801182:	00 
  801183:	c7 44 24 04 41 2c 80 	movl   $0x802c41,0x4(%esp)
  80118a:	00 
  80118b:	c7 04 24 88 2c 80 00 	movl   $0x802c88,(%esp)
  801192:	e8 5a f0 ff ff       	call   8001f1 <cprintf>
	if (envidnum < 0)
  801197:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80119b:	79 23                	jns    8011c0 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80119d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011a4:	c7 44 24 08 4c 2c 80 	movl   $0x802c4c,0x8(%esp)
  8011ab:	00 
  8011ac:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8011b3:	00 
  8011b4:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  8011bb:	e8 a4 11 00 00       	call   802364 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8011c0:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8011c5:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8011ca:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  8011cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011d3:	75 1c                	jne    8011f1 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011d5:	e8 5d fe ff ff       	call   801037 <sys_getenvid>
  8011da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011e7:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  8011ec:	e9 0a 02 00 00       	jmp    8013fb <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8011f1:	89 d8                	mov    %ebx,%eax
  8011f3:	c1 e8 16             	shr    $0x16,%eax
  8011f6:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8011f9:	a8 01                	test   $0x1,%al
  8011fb:	0f 84 43 01 00 00    	je     801344 <.after_sysenter_label+0x1d6>
  801201:	89 d8                	mov    %ebx,%eax
  801203:	c1 e8 0c             	shr    $0xc,%eax
  801206:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801209:	f6 c2 01             	test   $0x1,%dl
  80120c:	0f 84 32 01 00 00    	je     801344 <.after_sysenter_label+0x1d6>
  801212:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801215:	f6 c2 04             	test   $0x4,%dl
  801218:	0f 84 26 01 00 00    	je     801344 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  80121e:	c1 e0 0c             	shl    $0xc,%eax
  801221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801224:	c1 e8 0c             	shr    $0xc,%eax
  801227:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  801232:	a9 02 08 00 00       	test   $0x802,%eax
  801237:	0f 84 a0 00 00 00    	je     8012dd <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  80123d:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  801240:	80 ce 08             	or     $0x8,%dh
  801243:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801246:	89 54 24 10          	mov    %edx,0x10(%esp)
  80124a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80124d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801251:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801254:	89 44 24 08          	mov    %eax,0x8(%esp)
  801258:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80125b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801266:	e8 e9 fc ff ff       	call   800f54 <sys_page_map>
  80126b:	85 c0                	test   %eax,%eax
  80126d:	79 20                	jns    80128f <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80126f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801273:	c7 44 24 08 b0 2c 80 	movl   $0x802cb0,0x8(%esp)
  80127a:	00 
  80127b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801282:	00 
  801283:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80128a:	e8 d5 10 00 00       	call   802364 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80128f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801292:	89 44 24 10          	mov    %eax,0x10(%esp)
  801296:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80129d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012a4:	00 
  8012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b0:	e8 9f fc ff ff       	call   800f54 <sys_page_map>
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	0f 89 87 00 00 00    	jns    801344 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  8012bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c1:	c7 44 24 08 dc 2c 80 	movl   $0x802cdc,0x8(%esp)
  8012c8:	00 
  8012c9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8012d0:	00 
  8012d1:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  8012d8:	e8 87 10 00 00       	call   802364 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  8012dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012eb:	c7 04 24 5c 2c 80 00 	movl   $0x802c5c,(%esp)
  8012f2:	e8 fa ee ff ff       	call   8001f1 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  8012f7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8012fe:	00 
  8012ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801302:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801306:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801309:	89 44 24 08          	mov    %eax,0x8(%esp)
  80130d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801310:	89 44 24 04          	mov    %eax,0x4(%esp)
  801314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80131b:	e8 34 fc ff ff       	call   800f54 <sys_page_map>
  801320:	85 c0                	test   %eax,%eax
  801322:	79 20                	jns    801344 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801324:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801328:	c7 44 24 08 08 2d 80 	movl   $0x802d08,0x8(%esp)
  80132f:	00 
  801330:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801337:	00 
  801338:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80133f:	e8 20 10 00 00       	call   802364 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801344:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80134a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801350:	0f 85 9b fe ff ff    	jne    8011f1 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801356:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80135d:	00 
  80135e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801365:	ee 
  801366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801369:	89 04 24             	mov    %eax,(%esp)
  80136c:	e8 1c fc ff ff       	call   800f8d <sys_page_alloc>
  801371:	85 c0                	test   %eax,%eax
  801373:	79 20                	jns    801395 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801375:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801379:	c7 44 24 08 34 2d 80 	movl   $0x802d34,0x8(%esp)
  801380:	00 
  801381:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801388:	00 
  801389:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  801390:	e8 cf 0f 00 00       	call   802364 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801395:	c7 44 24 04 2c 24 80 	movl   $0x80242c,0x4(%esp)
  80139c:	00 
  80139d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013a0:	89 04 24             	mov    %eax,(%esp)
  8013a3:	e8 cc fa ff ff       	call   800e74 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  8013a8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013af:	00 
  8013b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013b3:	89 04 24             	mov    %eax,(%esp)
  8013b6:	e8 29 fb ff ff       	call   800ee4 <sys_env_set_status>
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	79 20                	jns    8013df <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  8013bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013c3:	c7 44 24 08 58 2d 80 	movl   $0x802d58,0x8(%esp)
  8013ca:	00 
  8013cb:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8013d2:	00 
  8013d3:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  8013da:	e8 85 0f 00 00       	call   802364 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  8013df:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  8013e6:	00 
  8013e7:	c7 44 24 04 41 2c 80 	movl   $0x802c41,0x4(%esp)
  8013ee:	00 
  8013ef:	c7 04 24 6e 2c 80 00 	movl   $0x802c6e,(%esp)
  8013f6:	e8 f6 ed ff ff       	call   8001f1 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  8013fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013fe:	83 c4 3c             	add    $0x3c,%esp
  801401:	5b                   	pop    %ebx
  801402:	5e                   	pop    %esi
  801403:	5f                   	pop    %edi
  801404:	5d                   	pop    %ebp
  801405:	c3                   	ret    

00801406 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	53                   	push   %ebx
  80140a:	83 ec 24             	sub    $0x24,%esp
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801410:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801412:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801415:	f6 c2 02             	test   $0x2,%dl
  801418:	75 2b                	jne    801445 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  80141a:	8b 40 28             	mov    0x28(%eax),%eax
  80141d:	89 44 24 14          	mov    %eax,0x14(%esp)
  801421:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801425:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801429:	c7 44 24 08 80 2d 80 	movl   $0x802d80,0x8(%esp)
  801430:	00 
  801431:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801438:	00 
  801439:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  801440:	e8 1f 0f 00 00       	call   802364 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801445:	89 d8                	mov    %ebx,%eax
  801447:	c1 e8 16             	shr    $0x16,%eax
  80144a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801451:	a8 01                	test   $0x1,%al
  801453:	74 11                	je     801466 <pgfault+0x60>
  801455:	89 d8                	mov    %ebx,%eax
  801457:	c1 e8 0c             	shr    $0xc,%eax
  80145a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801461:	f6 c4 08             	test   $0x8,%ah
  801464:	75 1c                	jne    801482 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  801466:	c7 44 24 08 bc 2d 80 	movl   $0x802dbc,0x8(%esp)
  80146d:	00 
  80146e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801475:	00 
  801476:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80147d:	e8 e2 0e 00 00       	call   802364 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801482:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801489:	00 
  80148a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801491:	00 
  801492:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801499:	e8 ef fa ff ff       	call   800f8d <sys_page_alloc>
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	79 20                	jns    8014c2 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  8014a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a6:	c7 44 24 08 f8 2d 80 	movl   $0x802df8,0x8(%esp)
  8014ad:	00 
  8014ae:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014b5:	00 
  8014b6:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  8014bd:	e8 a2 0e 00 00       	call   802364 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  8014c2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  8014c8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014cf:	00 
  8014d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014d4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8014db:	e8 35 f6 ff ff       	call   800b15 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  8014e0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8014e7:	00 
  8014e8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014ec:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f3:	00 
  8014f4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014fb:	00 
  8014fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801503:	e8 4c fa ff ff       	call   800f54 <sys_page_map>
  801508:	85 c0                	test   %eax,%eax
  80150a:	79 20                	jns    80152c <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  80150c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801510:	c7 44 24 08 20 2e 80 	movl   $0x802e20,0x8(%esp)
  801517:	00 
  801518:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80151f:	00 
  801520:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  801527:	e8 38 0e 00 00       	call   802364 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  80152c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801533:	00 
  801534:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153b:	e8 dc f9 ff ff       	call   800f1c <sys_page_unmap>
  801540:	85 c0                	test   %eax,%eax
  801542:	79 20                	jns    801564 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  801544:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801548:	c7 44 24 08 44 2e 80 	movl   $0x802e44,0x8(%esp)
  80154f:	00 
  801550:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801557:	00 
  801558:	c7 04 24 41 2c 80 00 	movl   $0x802c41,(%esp)
  80155f:	e8 00 0e 00 00       	call   802364 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801564:	83 c4 24             	add    $0x24,%esp
  801567:	5b                   	pop    %ebx
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    
  80156a:	00 00                	add    %al,(%eax)
  80156c:	00 00                	add    %al,(%eax)
	...

00801570 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	8b 45 08             	mov    0x8(%ebp),%eax
  801576:	05 00 00 00 30       	add    $0x30000000,%eax
  80157b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	89 04 24             	mov    %eax,(%esp)
  80158c:	e8 df ff ff ff       	call   801570 <fd2num>
  801591:	05 20 00 0d 00       	add    $0xd0020,%eax
  801596:	c1 e0 0c             	shl    $0xc,%eax
}
  801599:	c9                   	leave  
  80159a:	c3                   	ret    

0080159b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80159b:	55                   	push   %ebp
  80159c:	89 e5                	mov    %esp,%ebp
  80159e:	57                   	push   %edi
  80159f:	56                   	push   %esi
  8015a0:	53                   	push   %ebx
  8015a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8015a4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8015a9:	a8 01                	test   $0x1,%al
  8015ab:	74 36                	je     8015e3 <fd_alloc+0x48>
  8015ad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8015b2:	a8 01                	test   $0x1,%al
  8015b4:	74 2d                	je     8015e3 <fd_alloc+0x48>
  8015b6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8015bb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8015c0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8015c5:	89 c3                	mov    %eax,%ebx
  8015c7:	89 c2                	mov    %eax,%edx
  8015c9:	c1 ea 16             	shr    $0x16,%edx
  8015cc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8015cf:	f6 c2 01             	test   $0x1,%dl
  8015d2:	74 14                	je     8015e8 <fd_alloc+0x4d>
  8015d4:	89 c2                	mov    %eax,%edx
  8015d6:	c1 ea 0c             	shr    $0xc,%edx
  8015d9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8015dc:	f6 c2 01             	test   $0x1,%dl
  8015df:	75 10                	jne    8015f1 <fd_alloc+0x56>
  8015e1:	eb 05                	jmp    8015e8 <fd_alloc+0x4d>
  8015e3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8015e8:	89 1f                	mov    %ebx,(%edi)
  8015ea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015ef:	eb 17                	jmp    801608 <fd_alloc+0x6d>
  8015f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8015f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8015fb:	75 c8                	jne    8015c5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8015fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801603:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    

0080160d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	83 f8 1f             	cmp    $0x1f,%eax
  801616:	77 36                	ja     80164e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801618:	05 00 00 0d 00       	add    $0xd0000,%eax
  80161d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801620:	89 c2                	mov    %eax,%edx
  801622:	c1 ea 16             	shr    $0x16,%edx
  801625:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80162c:	f6 c2 01             	test   $0x1,%dl
  80162f:	74 1d                	je     80164e <fd_lookup+0x41>
  801631:	89 c2                	mov    %eax,%edx
  801633:	c1 ea 0c             	shr    $0xc,%edx
  801636:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80163d:	f6 c2 01             	test   $0x1,%dl
  801640:	74 0c                	je     80164e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801642:	8b 55 0c             	mov    0xc(%ebp),%edx
  801645:	89 02                	mov    %eax,(%edx)
  801647:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80164c:	eb 05                	jmp    801653 <fd_lookup+0x46>
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80165b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80165e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	89 04 24             	mov    %eax,(%esp)
  801668:	e8 a0 ff ff ff       	call   80160d <fd_lookup>
  80166d:	85 c0                	test   %eax,%eax
  80166f:	78 0e                	js     80167f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801671:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801674:	8b 55 0c             	mov    0xc(%ebp),%edx
  801677:	89 50 04             	mov    %edx,0x4(%eax)
  80167a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	56                   	push   %esi
  801685:	53                   	push   %ebx
  801686:	83 ec 10             	sub    $0x10,%esp
  801689:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80168f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801694:	b8 04 30 80 00       	mov    $0x803004,%eax
  801699:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80169f:	75 11                	jne    8016b2 <dev_lookup+0x31>
  8016a1:	eb 04                	jmp    8016a7 <dev_lookup+0x26>
  8016a3:	39 08                	cmp    %ecx,(%eax)
  8016a5:	75 10                	jne    8016b7 <dev_lookup+0x36>
			*dev = devtab[i];
  8016a7:	89 03                	mov    %eax,(%ebx)
  8016a9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8016ae:	66 90                	xchg   %ax,%ax
  8016b0:	eb 36                	jmp    8016e8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8016b2:	be e4 2e 80 00       	mov    $0x802ee4,%esi
  8016b7:	83 c2 01             	add    $0x1,%edx
  8016ba:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	75 e2                	jne    8016a3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8016c1:	a1 08 40 80 00       	mov    0x804008,%eax
  8016c6:	8b 40 48             	mov    0x48(%eax),%eax
  8016c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8016cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d1:	c7 04 24 68 2e 80 00 	movl   $0x802e68,(%esp)
  8016d8:	e8 14 eb ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  8016dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8016e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8016e8:	83 c4 10             	add    $0x10,%esp
  8016eb:	5b                   	pop    %ebx
  8016ec:	5e                   	pop    %esi
  8016ed:	5d                   	pop    %ebp
  8016ee:	c3                   	ret    

008016ef <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	53                   	push   %ebx
  8016f3:	83 ec 24             	sub    $0x24,%esp
  8016f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	89 04 24             	mov    %eax,(%esp)
  801706:	e8 02 ff ff ff       	call   80160d <fd_lookup>
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 53                	js     801762 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801712:	89 44 24 04          	mov    %eax,0x4(%esp)
  801716:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801719:	8b 00                	mov    (%eax),%eax
  80171b:	89 04 24             	mov    %eax,(%esp)
  80171e:	e8 5e ff ff ff       	call   801681 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801723:	85 c0                	test   %eax,%eax
  801725:	78 3b                	js     801762 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801727:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80172f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801733:	74 2d                	je     801762 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801735:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801738:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173f:	00 00 00 
	stat->st_isdir = 0;
  801742:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801749:	00 00 00 
	stat->st_dev = dev;
  80174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801755:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801759:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80175c:	89 14 24             	mov    %edx,(%esp)
  80175f:	ff 50 14             	call   *0x14(%eax)
}
  801762:	83 c4 24             	add    $0x24,%esp
  801765:	5b                   	pop    %ebx
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    

00801768 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	53                   	push   %ebx
  80176c:	83 ec 24             	sub    $0x24,%esp
  80176f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801772:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	89 1c 24             	mov    %ebx,(%esp)
  80177c:	e8 8c fe ff ff       	call   80160d <fd_lookup>
  801781:	85 c0                	test   %eax,%eax
  801783:	78 5f                	js     8017e4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801785:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801788:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178f:	8b 00                	mov    (%eax),%eax
  801791:	89 04 24             	mov    %eax,(%esp)
  801794:	e8 e8 fe ff ff       	call   801681 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 47                	js     8017e4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017a4:	75 23                	jne    8017c9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017a6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017ab:	8b 40 48             	mov    0x48(%eax),%eax
  8017ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b6:	c7 04 24 88 2e 80 00 	movl   $0x802e88,(%esp)
  8017bd:	e8 2f ea ff ff       	call   8001f1 <cprintf>
  8017c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017c7:	eb 1b                	jmp    8017e4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8017c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017cc:	8b 48 18             	mov    0x18(%eax),%ecx
  8017cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d4:	85 c9                	test   %ecx,%ecx
  8017d6:	74 0c                	je     8017e4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017df:	89 14 24             	mov    %edx,(%esp)
  8017e2:	ff d1                	call   *%ecx
}
  8017e4:	83 c4 24             	add    $0x24,%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	53                   	push   %ebx
  8017ee:	83 ec 24             	sub    $0x24,%esp
  8017f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fb:	89 1c 24             	mov    %ebx,(%esp)
  8017fe:	e8 0a fe ff ff       	call   80160d <fd_lookup>
  801803:	85 c0                	test   %eax,%eax
  801805:	78 66                	js     80186d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801807:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80180a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80180e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801811:	8b 00                	mov    (%eax),%eax
  801813:	89 04 24             	mov    %eax,(%esp)
  801816:	e8 66 fe ff ff       	call   801681 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 4e                	js     80186d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801822:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801826:	75 23                	jne    80184b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801828:	a1 08 40 80 00       	mov    0x804008,%eax
  80182d:	8b 40 48             	mov    0x48(%eax),%eax
  801830:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801834:	89 44 24 04          	mov    %eax,0x4(%esp)
  801838:	c7 04 24 a9 2e 80 00 	movl   $0x802ea9,(%esp)
  80183f:	e8 ad e9 ff ff       	call   8001f1 <cprintf>
  801844:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801849:	eb 22                	jmp    80186d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80184b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801851:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801856:	85 c9                	test   %ecx,%ecx
  801858:	74 13                	je     80186d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80185a:	8b 45 10             	mov    0x10(%ebp),%eax
  80185d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801861:	8b 45 0c             	mov    0xc(%ebp),%eax
  801864:	89 44 24 04          	mov    %eax,0x4(%esp)
  801868:	89 14 24             	mov    %edx,(%esp)
  80186b:	ff d1                	call   *%ecx
}
  80186d:	83 c4 24             	add    $0x24,%esp
  801870:	5b                   	pop    %ebx
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	53                   	push   %ebx
  801877:	83 ec 24             	sub    $0x24,%esp
  80187a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801880:	89 44 24 04          	mov    %eax,0x4(%esp)
  801884:	89 1c 24             	mov    %ebx,(%esp)
  801887:	e8 81 fd ff ff       	call   80160d <fd_lookup>
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 6b                	js     8018fb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801890:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801893:	89 44 24 04          	mov    %eax,0x4(%esp)
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	8b 00                	mov    (%eax),%eax
  80189c:	89 04 24             	mov    %eax,(%esp)
  80189f:	e8 dd fd ff ff       	call   801681 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a4:	85 c0                	test   %eax,%eax
  8018a6:	78 53                	js     8018fb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8018a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ab:	8b 42 08             	mov    0x8(%edx),%eax
  8018ae:	83 e0 03             	and    $0x3,%eax
  8018b1:	83 f8 01             	cmp    $0x1,%eax
  8018b4:	75 23                	jne    8018d9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8018b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8018bb:	8b 40 48             	mov    0x48(%eax),%eax
  8018be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c6:	c7 04 24 c6 2e 80 00 	movl   $0x802ec6,(%esp)
  8018cd:	e8 1f e9 ff ff       	call   8001f1 <cprintf>
  8018d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018d7:	eb 22                	jmp    8018fb <read+0x88>
	}
	if (!dev->dev_read)
  8018d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018dc:	8b 48 08             	mov    0x8(%eax),%ecx
  8018df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018e4:	85 c9                	test   %ecx,%ecx
  8018e6:	74 13                	je     8018fb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8018e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8018eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f6:	89 14 24             	mov    %edx,(%esp)
  8018f9:	ff d1                	call   *%ecx
}
  8018fb:	83 c4 24             	add    $0x24,%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	57                   	push   %edi
  801905:	56                   	push   %esi
  801906:	53                   	push   %ebx
  801907:	83 ec 1c             	sub    $0x1c,%esp
  80190a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80190d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801910:	ba 00 00 00 00       	mov    $0x0,%edx
  801915:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
  80191f:	85 f6                	test   %esi,%esi
  801921:	74 29                	je     80194c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801923:	89 f0                	mov    %esi,%eax
  801925:	29 d0                	sub    %edx,%eax
  801927:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192b:	03 55 0c             	add    0xc(%ebp),%edx
  80192e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801932:	89 3c 24             	mov    %edi,(%esp)
  801935:	e8 39 ff ff ff       	call   801873 <read>
		if (m < 0)
  80193a:	85 c0                	test   %eax,%eax
  80193c:	78 0e                	js     80194c <readn+0x4b>
			return m;
		if (m == 0)
  80193e:	85 c0                	test   %eax,%eax
  801940:	74 08                	je     80194a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801942:	01 c3                	add    %eax,%ebx
  801944:	89 da                	mov    %ebx,%edx
  801946:	39 f3                	cmp    %esi,%ebx
  801948:	72 d9                	jb     801923 <readn+0x22>
  80194a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80194c:	83 c4 1c             	add    $0x1c,%esp
  80194f:	5b                   	pop    %ebx
  801950:	5e                   	pop    %esi
  801951:	5f                   	pop    %edi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 28             	sub    $0x28,%esp
  80195a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80195d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801960:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801963:	89 34 24             	mov    %esi,(%esp)
  801966:	e8 05 fc ff ff       	call   801570 <fd2num>
  80196b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80196e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801972:	89 04 24             	mov    %eax,(%esp)
  801975:	e8 93 fc ff ff       	call   80160d <fd_lookup>
  80197a:	89 c3                	mov    %eax,%ebx
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 05                	js     801985 <fd_close+0x31>
  801980:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801983:	74 0e                	je     801993 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801985:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
  80198e:	0f 44 d8             	cmove  %eax,%ebx
  801991:	eb 3d                	jmp    8019d0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801993:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801996:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199a:	8b 06                	mov    (%esi),%eax
  80199c:	89 04 24             	mov    %eax,(%esp)
  80199f:	e8 dd fc ff ff       	call   801681 <dev_lookup>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	85 c0                	test   %eax,%eax
  8019a8:	78 16                	js     8019c0 <fd_close+0x6c>
		if (dev->dev_close)
  8019aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ad:	8b 40 10             	mov    0x10(%eax),%eax
  8019b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	74 07                	je     8019c0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8019b9:	89 34 24             	mov    %esi,(%esp)
  8019bc:	ff d0                	call   *%eax
  8019be:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8019c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019cb:	e8 4c f5 ff ff       	call   800f1c <sys_page_unmap>
	return r;
}
  8019d0:	89 d8                	mov    %ebx,%eax
  8019d2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019d5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019d8:	89 ec                	mov    %ebp,%esp
  8019da:	5d                   	pop    %ebp
  8019db:	c3                   	ret    

008019dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	89 04 24             	mov    %eax,(%esp)
  8019ef:	e8 19 fc ff ff       	call   80160d <fd_lookup>
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 13                	js     801a0b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8019f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8019ff:	00 
  801a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a03:	89 04 24             	mov    %eax,(%esp)
  801a06:	e8 49 ff ff ff       	call   801954 <fd_close>
}
  801a0b:	c9                   	leave  
  801a0c:	c3                   	ret    

00801a0d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	83 ec 18             	sub    $0x18,%esp
  801a13:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a16:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a20:	00 
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	89 04 24             	mov    %eax,(%esp)
  801a27:	e8 78 03 00 00       	call   801da4 <open>
  801a2c:	89 c3                	mov    %eax,%ebx
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 1b                	js     801a4d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a39:	89 1c 24             	mov    %ebx,(%esp)
  801a3c:	e8 ae fc ff ff       	call   8016ef <fstat>
  801a41:	89 c6                	mov    %eax,%esi
	close(fd);
  801a43:	89 1c 24             	mov    %ebx,(%esp)
  801a46:	e8 91 ff ff ff       	call   8019dc <close>
  801a4b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801a4d:	89 d8                	mov    %ebx,%eax
  801a4f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a52:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a55:	89 ec                	mov    %ebp,%esp
  801a57:	5d                   	pop    %ebp
  801a58:	c3                   	ret    

00801a59 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801a59:	55                   	push   %ebp
  801a5a:	89 e5                	mov    %esp,%ebp
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 14             	sub    $0x14,%esp
  801a60:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a65:	89 1c 24             	mov    %ebx,(%esp)
  801a68:	e8 6f ff ff ff       	call   8019dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a6d:	83 c3 01             	add    $0x1,%ebx
  801a70:	83 fb 20             	cmp    $0x20,%ebx
  801a73:	75 f0                	jne    801a65 <close_all+0xc>
		close(i);
}
  801a75:	83 c4 14             	add    $0x14,%esp
  801a78:	5b                   	pop    %ebx
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	83 ec 58             	sub    $0x58,%esp
  801a81:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a84:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a87:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a8a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a8d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	89 04 24             	mov    %eax,(%esp)
  801a9a:	e8 6e fb ff ff       	call   80160d <fd_lookup>
  801a9f:	89 c3                	mov    %eax,%ebx
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	0f 88 e0 00 00 00    	js     801b89 <dup+0x10e>
		return r;
	close(newfdnum);
  801aa9:	89 3c 24             	mov    %edi,(%esp)
  801aac:	e8 2b ff ff ff       	call   8019dc <close>

	newfd = INDEX2FD(newfdnum);
  801ab1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801ab7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801aba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 bb fa ff ff       	call   801580 <fd2data>
  801ac5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ac7:	89 34 24             	mov    %esi,(%esp)
  801aca:	e8 b1 fa ff ff       	call   801580 <fd2data>
  801acf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ad2:	89 da                	mov    %ebx,%edx
  801ad4:	89 d8                	mov    %ebx,%eax
  801ad6:	c1 e8 16             	shr    $0x16,%eax
  801ad9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801ae0:	a8 01                	test   $0x1,%al
  801ae2:	74 43                	je     801b27 <dup+0xac>
  801ae4:	c1 ea 0c             	shr    $0xc,%edx
  801ae7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801aee:	a8 01                	test   $0x1,%al
  801af0:	74 35                	je     801b27 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801af2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801af9:	25 07 0e 00 00       	and    $0xe07,%eax
  801afe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b02:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b05:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b10:	00 
  801b11:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b1c:	e8 33 f4 ff ff       	call   800f54 <sys_page_map>
  801b21:	89 c3                	mov    %eax,%ebx
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 3f                	js     801b66 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b27:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2a:	89 c2                	mov    %eax,%edx
  801b2c:	c1 ea 0c             	shr    $0xc,%edx
  801b2f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b36:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b3c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b40:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801b44:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b4b:	00 
  801b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b57:	e8 f8 f3 ff ff       	call   800f54 <sys_page_map>
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 04                	js     801b66 <dup+0xeb>
  801b62:	89 fb                	mov    %edi,%ebx
  801b64:	eb 23                	jmp    801b89 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b66:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b71:	e8 a6 f3 ff ff       	call   800f1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b76:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b79:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b84:	e8 93 f3 ff ff       	call   800f1c <sys_page_unmap>
	return r;
}
  801b89:	89 d8                	mov    %ebx,%eax
  801b8b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b8e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b91:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b94:	89 ec                	mov    %ebp,%esp
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 18             	sub    $0x18,%esp
  801b9e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ba1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ba4:	89 c3                	mov    %eax,%ebx
  801ba6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801ba8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801baf:	75 11                	jne    801bc2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801bb1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801bb8:	e8 a3 08 00 00       	call   802460 <ipc_find_env>
  801bbd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801bc2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bc9:	00 
  801bca:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801bd1:	00 
  801bd2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd6:	a1 00 40 80 00       	mov    0x804000,%eax
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 c1 08 00 00       	call   8024a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801be3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bea:	00 
  801beb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf6:	e8 14 09 00 00       	call   80250f <ipc_recv>
}
  801bfb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bfe:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c01:	89 ec                	mov    %ebp,%esp
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c11:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801c16:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c19:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c1e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c23:	b8 02 00 00 00       	mov    $0x2,%eax
  801c28:	e8 6b ff ff ff       	call   801b98 <fsipc>
}
  801c2d:	c9                   	leave  
  801c2e:	c3                   	ret    

00801c2f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c2f:	55                   	push   %ebp
  801c30:	89 e5                	mov    %esp,%ebp
  801c32:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c35:	8b 45 08             	mov    0x8(%ebp),%eax
  801c38:	8b 40 0c             	mov    0xc(%eax),%eax
  801c3b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801c40:	ba 00 00 00 00       	mov    $0x0,%edx
  801c45:	b8 06 00 00 00       	mov    $0x6,%eax
  801c4a:	e8 49 ff ff ff       	call   801b98 <fsipc>
}
  801c4f:	c9                   	leave  
  801c50:	c3                   	ret    

00801c51 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c57:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c61:	e8 32 ff ff ff       	call   801b98 <fsipc>
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 14             	sub    $0x14,%esp
  801c6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	8b 40 0c             	mov    0xc(%eax),%eax
  801c78:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c7d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c82:	b8 05 00 00 00       	mov    $0x5,%eax
  801c87:	e8 0c ff ff ff       	call   801b98 <fsipc>
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 2b                	js     801cbb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c90:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c97:	00 
  801c98:	89 1c 24             	mov    %ebx,(%esp)
  801c9b:	e8 8a ec ff ff       	call   80092a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ca0:	a1 80 50 80 00       	mov    0x805080,%eax
  801ca5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801cab:	a1 84 50 80 00       	mov    0x805084,%eax
  801cb0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801cbb:	83 c4 14             	add    $0x14,%esp
  801cbe:	5b                   	pop    %ebx
  801cbf:	5d                   	pop    %ebp
  801cc0:	c3                   	ret    

00801cc1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 18             	sub    $0x18,%esp
  801cc7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801cca:	8b 55 08             	mov    0x8(%ebp),%edx
  801ccd:	8b 52 0c             	mov    0xc(%edx),%edx
  801cd0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801cd6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801cdb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ce0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ce5:	0f 47 c2             	cmova  %edx,%eax
  801ce8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801cfa:	e8 16 ee ff ff       	call   800b15 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801cff:	ba 00 00 00 00       	mov    $0x0,%edx
  801d04:	b8 04 00 00 00       	mov    $0x4,%eax
  801d09:	e8 8a fe ff ff       	call   801b98 <fsipc>
}
  801d0e:	c9                   	leave  
  801d0f:	c3                   	ret    

00801d10 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	53                   	push   %ebx
  801d14:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d17:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d1d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801d22:	8b 45 10             	mov    0x10(%ebp),%eax
  801d25:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2f:	b8 03 00 00 00       	mov    $0x3,%eax
  801d34:	e8 5f fe ff ff       	call   801b98 <fsipc>
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	78 17                	js     801d56 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d43:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801d4a:	00 
  801d4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4e:	89 04 24             	mov    %eax,(%esp)
  801d51:	e8 bf ed ff ff       	call   800b15 <memmove>
  return r;	
}
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	83 c4 14             	add    $0x14,%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	53                   	push   %ebx
  801d62:	83 ec 14             	sub    $0x14,%esp
  801d65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d68:	89 1c 24             	mov    %ebx,(%esp)
  801d6b:	e8 70 eb ff ff       	call   8008e0 <strlen>
  801d70:	89 c2                	mov    %eax,%edx
  801d72:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d77:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d7d:	7f 1f                	jg     801d9e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d83:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d8a:	e8 9b eb ff ff       	call   80092a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d94:	b8 07 00 00 00       	mov    $0x7,%eax
  801d99:	e8 fa fd ff ff       	call   801b98 <fsipc>
}
  801d9e:	83 c4 14             	add    $0x14,%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5d                   	pop    %ebp
  801da3:	c3                   	ret    

00801da4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	83 ec 28             	sub    $0x28,%esp
  801daa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801db0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801db3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801db6:	89 04 24             	mov    %eax,(%esp)
  801db9:	e8 dd f7 ff ff       	call   80159b <fd_alloc>
  801dbe:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	0f 88 89 00 00 00    	js     801e51 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801dc8:	89 34 24             	mov    %esi,(%esp)
  801dcb:	e8 10 eb ff ff       	call   8008e0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801dd0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801dd5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801dda:	7f 75                	jg     801e51 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801ddc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801de0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801de7:	e8 3e eb ff ff       	call   80092a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801dec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801def:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801df4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801df7:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfc:	e8 97 fd ff ff       	call   801b98 <fsipc>
  801e01:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801e03:	85 c0                	test   %eax,%eax
  801e05:	78 0f                	js     801e16 <open+0x72>
  return fd2num(fd);
  801e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0a:	89 04 24             	mov    %eax,(%esp)
  801e0d:	e8 5e f7 ff ff       	call   801570 <fd2num>
  801e12:	89 c3                	mov    %eax,%ebx
  801e14:	eb 3b                	jmp    801e51 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801e16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e1d:	00 
  801e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e21:	89 04 24             	mov    %eax,(%esp)
  801e24:	e8 2b fb ff ff       	call   801954 <fd_close>
  801e29:	85 c0                	test   %eax,%eax
  801e2b:	74 24                	je     801e51 <open+0xad>
  801e2d:	c7 44 24 0c f0 2e 80 	movl   $0x802ef0,0xc(%esp)
  801e34:	00 
  801e35:	c7 44 24 08 05 2f 80 	movl   $0x802f05,0x8(%esp)
  801e3c:	00 
  801e3d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801e44:	00 
  801e45:	c7 04 24 1a 2f 80 00 	movl   $0x802f1a,(%esp)
  801e4c:	e8 13 05 00 00       	call   802364 <_panic>
  return r;
}
  801e51:	89 d8                	mov    %ebx,%eax
  801e53:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e56:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e59:	89 ec                	mov    %ebp,%esp
  801e5b:	5d                   	pop    %ebp
  801e5c:	c3                   	ret    
  801e5d:	00 00                	add    %al,(%eax)
	...

00801e60 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
  801e63:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e66:	c7 44 24 04 25 2f 80 	movl   $0x802f25,0x4(%esp)
  801e6d:	00 
  801e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 b1 ea ff ff       	call   80092a <strcpy>
	return 0;
}
  801e79:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	53                   	push   %ebx
  801e84:	83 ec 14             	sub    $0x14,%esp
  801e87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e8a:	89 1c 24             	mov    %ebx,(%esp)
  801e8d:	e8 0a 07 00 00       	call   80259c <pageref>
  801e92:	89 c2                	mov    %eax,%edx
  801e94:	b8 00 00 00 00       	mov    $0x0,%eax
  801e99:	83 fa 01             	cmp    $0x1,%edx
  801e9c:	75 0b                	jne    801ea9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e9e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ea1:	89 04 24             	mov    %eax,(%esp)
  801ea4:	e8 b9 02 00 00       	call   802162 <nsipc_close>
	else
		return 0;
}
  801ea9:	83 c4 14             	add    $0x14,%esp
  801eac:	5b                   	pop    %ebx
  801ead:	5d                   	pop    %ebp
  801eae:	c3                   	ret    

00801eaf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801eb5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ebc:	00 
  801ebd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ece:	8b 40 0c             	mov    0xc(%eax),%eax
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 c5 02 00 00       	call   80219e <nsipc_send>
}
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ee1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ee8:	00 
  801ee9:	8b 45 10             	mov    0x10(%ebp),%eax
  801eec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	8b 40 0c             	mov    0xc(%eax),%eax
  801efd:	89 04 24             	mov    %eax,(%esp)
  801f00:	e8 0c 03 00 00       	call   802211 <nsipc_recv>
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    

00801f07 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f07:	55                   	push   %ebp
  801f08:	89 e5                	mov    %esp,%ebp
  801f0a:	56                   	push   %esi
  801f0b:	53                   	push   %ebx
  801f0c:	83 ec 20             	sub    $0x20,%esp
  801f0f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f14:	89 04 24             	mov    %eax,(%esp)
  801f17:	e8 7f f6 ff ff       	call   80159b <fd_alloc>
  801f1c:	89 c3                	mov    %eax,%ebx
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 21                	js     801f43 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f29:	00 
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f38:	e8 50 f0 ff ff       	call   800f8d <sys_page_alloc>
  801f3d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	79 0a                	jns    801f4d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801f43:	89 34 24             	mov    %esi,(%esp)
  801f46:	e8 17 02 00 00       	call   802162 <nsipc_close>
		return r;
  801f4b:	eb 28                	jmp    801f75 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801f4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f56:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f65:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6b:	89 04 24             	mov    %eax,(%esp)
  801f6e:	e8 fd f5 ff ff       	call   801570 <fd2num>
  801f73:	89 c3                	mov    %eax,%ebx
}
  801f75:	89 d8                	mov    %ebx,%eax
  801f77:	83 c4 20             	add    $0x20,%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5d                   	pop    %ebp
  801f7d:	c3                   	ret    

00801f7e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f7e:	55                   	push   %ebp
  801f7f:	89 e5                	mov    %esp,%ebp
  801f81:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f84:	8b 45 10             	mov    0x10(%ebp),%eax
  801f87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	89 04 24             	mov    %eax,(%esp)
  801f98:	e8 79 01 00 00       	call   802116 <nsipc_socket>
  801f9d:	85 c0                	test   %eax,%eax
  801f9f:	78 05                	js     801fa6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801fa1:	e8 61 ff ff ff       	call   801f07 <alloc_sockfd>
}
  801fa6:	c9                   	leave  
  801fa7:	c3                   	ret    

00801fa8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801fae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801fb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fb5:	89 04 24             	mov    %eax,(%esp)
  801fb8:	e8 50 f6 ff ff       	call   80160d <fd_lookup>
  801fbd:	85 c0                	test   %eax,%eax
  801fbf:	78 15                	js     801fd6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801fc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fc4:	8b 0a                	mov    (%edx),%ecx
  801fc6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801fcb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801fd1:	75 03                	jne    801fd6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801fd3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fde:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe1:	e8 c2 ff ff ff       	call   801fa8 <fd2sockid>
  801fe6:	85 c0                	test   %eax,%eax
  801fe8:	78 0f                	js     801ff9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801fea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fed:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ff1:	89 04 24             	mov    %eax,(%esp)
  801ff4:	e8 47 01 00 00       	call   802140 <nsipc_listen>
}
  801ff9:	c9                   	leave  
  801ffa:	c3                   	ret    

00801ffb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802001:	8b 45 08             	mov    0x8(%ebp),%eax
  802004:	e8 9f ff ff ff       	call   801fa8 <fd2sockid>
  802009:	85 c0                	test   %eax,%eax
  80200b:	78 16                	js     802023 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80200d:	8b 55 10             	mov    0x10(%ebp),%edx
  802010:	89 54 24 08          	mov    %edx,0x8(%esp)
  802014:	8b 55 0c             	mov    0xc(%ebp),%edx
  802017:	89 54 24 04          	mov    %edx,0x4(%esp)
  80201b:	89 04 24             	mov    %eax,(%esp)
  80201e:	e8 6e 02 00 00       	call   802291 <nsipc_connect>
}
  802023:	c9                   	leave  
  802024:	c3                   	ret    

00802025 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802025:	55                   	push   %ebp
  802026:	89 e5                	mov    %esp,%ebp
  802028:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80202b:	8b 45 08             	mov    0x8(%ebp),%eax
  80202e:	e8 75 ff ff ff       	call   801fa8 <fd2sockid>
  802033:	85 c0                	test   %eax,%eax
  802035:	78 0f                	js     802046 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802037:	8b 55 0c             	mov    0xc(%ebp),%edx
  80203a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80203e:	89 04 24             	mov    %eax,(%esp)
  802041:	e8 36 01 00 00       	call   80217c <nsipc_shutdown>
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	e8 52 ff ff ff       	call   801fa8 <fd2sockid>
  802056:	85 c0                	test   %eax,%eax
  802058:	78 16                	js     802070 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80205a:	8b 55 10             	mov    0x10(%ebp),%edx
  80205d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802061:	8b 55 0c             	mov    0xc(%ebp),%edx
  802064:	89 54 24 04          	mov    %edx,0x4(%esp)
  802068:	89 04 24             	mov    %eax,(%esp)
  80206b:	e8 60 02 00 00       	call   8022d0 <nsipc_bind>
}
  802070:	c9                   	leave  
  802071:	c3                   	ret    

00802072 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802072:	55                   	push   %ebp
  802073:	89 e5                	mov    %esp,%ebp
  802075:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802078:	8b 45 08             	mov    0x8(%ebp),%eax
  80207b:	e8 28 ff ff ff       	call   801fa8 <fd2sockid>
  802080:	85 c0                	test   %eax,%eax
  802082:	78 1f                	js     8020a3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802084:	8b 55 10             	mov    0x10(%ebp),%edx
  802087:	89 54 24 08          	mov    %edx,0x8(%esp)
  80208b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80208e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802092:	89 04 24             	mov    %eax,(%esp)
  802095:	e8 75 02 00 00       	call   80230f <nsipc_accept>
  80209a:	85 c0                	test   %eax,%eax
  80209c:	78 05                	js     8020a3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80209e:	e8 64 fe ff ff       	call   801f07 <alloc_sockfd>
}
  8020a3:	c9                   	leave  
  8020a4:	c3                   	ret    
	...

008020b0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 14             	sub    $0x14,%esp
  8020b7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8020b9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8020c0:	75 11                	jne    8020d3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8020c2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8020c9:	e8 92 03 00 00       	call   802460 <ipc_find_env>
  8020ce:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8020d3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8020da:	00 
  8020db:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8020e2:	00 
  8020e3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020e7:	a1 04 40 80 00       	mov    0x804004,%eax
  8020ec:	89 04 24             	mov    %eax,(%esp)
  8020ef:	e8 b0 03 00 00       	call   8024a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8020f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8020fb:	00 
  8020fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802103:	00 
  802104:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80210b:	e8 ff 03 00 00       	call   80250f <ipc_recv>
}
  802110:	83 c4 14             	add    $0x14,%esp
  802113:	5b                   	pop    %ebx
  802114:	5d                   	pop    %ebp
  802115:	c3                   	ret    

00802116 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802116:	55                   	push   %ebp
  802117:	89 e5                	mov    %esp,%ebp
  802119:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80211c:	8b 45 08             	mov    0x8(%ebp),%eax
  80211f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802124:	8b 45 0c             	mov    0xc(%ebp),%eax
  802127:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80212c:	8b 45 10             	mov    0x10(%ebp),%eax
  80212f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802134:	b8 09 00 00 00       	mov    $0x9,%eax
  802139:	e8 72 ff ff ff       	call   8020b0 <nsipc>
}
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802146:	8b 45 08             	mov    0x8(%ebp),%eax
  802149:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80214e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802151:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802156:	b8 06 00 00 00       	mov    $0x6,%eax
  80215b:	e8 50 ff ff ff       	call   8020b0 <nsipc>
}
  802160:	c9                   	leave  
  802161:	c3                   	ret    

00802162 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802162:	55                   	push   %ebp
  802163:	89 e5                	mov    %esp,%ebp
  802165:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802168:	8b 45 08             	mov    0x8(%ebp),%eax
  80216b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  802170:	b8 04 00 00 00       	mov    $0x4,%eax
  802175:	e8 36 ff ff ff       	call   8020b0 <nsipc>
}
  80217a:	c9                   	leave  
  80217b:	c3                   	ret    

0080217c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802182:	8b 45 08             	mov    0x8(%ebp),%eax
  802185:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80218a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  802192:	b8 03 00 00 00       	mov    $0x3,%eax
  802197:	e8 14 ff ff ff       	call   8020b0 <nsipc>
}
  80219c:	c9                   	leave  
  80219d:	c3                   	ret    

0080219e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	53                   	push   %ebx
  8021a2:	83 ec 14             	sub    $0x14,%esp
  8021a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8021a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ab:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8021b0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8021b6:	7e 24                	jle    8021dc <nsipc_send+0x3e>
  8021b8:	c7 44 24 0c 31 2f 80 	movl   $0x802f31,0xc(%esp)
  8021bf:	00 
  8021c0:	c7 44 24 08 05 2f 80 	movl   $0x802f05,0x8(%esp)
  8021c7:	00 
  8021c8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8021cf:	00 
  8021d0:	c7 04 24 3d 2f 80 00 	movl   $0x802f3d,(%esp)
  8021d7:	e8 88 01 00 00       	call   802364 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8021dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021e7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  8021ee:	e8 22 e9 ff ff       	call   800b15 <memmove>
	nsipcbuf.send.req_size = size;
  8021f3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8021f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8021fc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802201:	b8 08 00 00 00       	mov    $0x8,%eax
  802206:	e8 a5 fe ff ff       	call   8020b0 <nsipc>
}
  80220b:	83 c4 14             	add    $0x14,%esp
  80220e:	5b                   	pop    %ebx
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    

00802211 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	56                   	push   %esi
  802215:	53                   	push   %ebx
  802216:	83 ec 10             	sub    $0x10,%esp
  802219:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80221c:	8b 45 08             	mov    0x8(%ebp),%eax
  80221f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802224:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80222a:	8b 45 14             	mov    0x14(%ebp),%eax
  80222d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802232:	b8 07 00 00 00       	mov    $0x7,%eax
  802237:	e8 74 fe ff ff       	call   8020b0 <nsipc>
  80223c:	89 c3                	mov    %eax,%ebx
  80223e:	85 c0                	test   %eax,%eax
  802240:	78 46                	js     802288 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802242:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802247:	7f 04                	jg     80224d <nsipc_recv+0x3c>
  802249:	39 c6                	cmp    %eax,%esi
  80224b:	7d 24                	jge    802271 <nsipc_recv+0x60>
  80224d:	c7 44 24 0c 49 2f 80 	movl   $0x802f49,0xc(%esp)
  802254:	00 
  802255:	c7 44 24 08 05 2f 80 	movl   $0x802f05,0x8(%esp)
  80225c:	00 
  80225d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802264:	00 
  802265:	c7 04 24 3d 2f 80 00 	movl   $0x802f3d,(%esp)
  80226c:	e8 f3 00 00 00       	call   802364 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802271:	89 44 24 08          	mov    %eax,0x8(%esp)
  802275:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80227c:	00 
  80227d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802280:	89 04 24             	mov    %eax,(%esp)
  802283:	e8 8d e8 ff ff       	call   800b15 <memmove>
	}

	return r;
}
  802288:	89 d8                	mov    %ebx,%eax
  80228a:	83 c4 10             	add    $0x10,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5d                   	pop    %ebp
  802290:	c3                   	ret    

00802291 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802291:	55                   	push   %ebp
  802292:	89 e5                	mov    %esp,%ebp
  802294:	53                   	push   %ebx
  802295:	83 ec 14             	sub    $0x14,%esp
  802298:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80229b:	8b 45 08             	mov    0x8(%ebp),%eax
  80229e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8022a3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ae:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8022b5:	e8 5b e8 ff ff       	call   800b15 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8022ba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8022c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8022c5:	e8 e6 fd ff ff       	call   8020b0 <nsipc>
}
  8022ca:	83 c4 14             	add    $0x14,%esp
  8022cd:	5b                   	pop    %ebx
  8022ce:	5d                   	pop    %ebp
  8022cf:	c3                   	ret    

008022d0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8022d0:	55                   	push   %ebp
  8022d1:	89 e5                	mov    %esp,%ebp
  8022d3:	53                   	push   %ebx
  8022d4:	83 ec 14             	sub    $0x14,%esp
  8022d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8022da:	8b 45 08             	mov    0x8(%ebp),%eax
  8022dd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8022e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8022e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022ed:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8022f4:	e8 1c e8 ff ff       	call   800b15 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8022f9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  8022ff:	b8 02 00 00 00       	mov    $0x2,%eax
  802304:	e8 a7 fd ff ff       	call   8020b0 <nsipc>
}
  802309:	83 c4 14             	add    $0x14,%esp
  80230c:	5b                   	pop    %ebx
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    

0080230f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80230f:	55                   	push   %ebp
  802310:	89 e5                	mov    %esp,%ebp
  802312:	83 ec 18             	sub    $0x18,%esp
  802315:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802318:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80231b:	8b 45 08             	mov    0x8(%ebp),%eax
  80231e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802323:	b8 01 00 00 00       	mov    $0x1,%eax
  802328:	e8 83 fd ff ff       	call   8020b0 <nsipc>
  80232d:	89 c3                	mov    %eax,%ebx
  80232f:	85 c0                	test   %eax,%eax
  802331:	78 25                	js     802358 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802333:	be 10 60 80 00       	mov    $0x806010,%esi
  802338:	8b 06                	mov    (%esi),%eax
  80233a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80233e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802345:	00 
  802346:	8b 45 0c             	mov    0xc(%ebp),%eax
  802349:	89 04 24             	mov    %eax,(%esp)
  80234c:	e8 c4 e7 ff ff       	call   800b15 <memmove>
		*addrlen = ret->ret_addrlen;
  802351:	8b 16                	mov    (%esi),%edx
  802353:	8b 45 10             	mov    0x10(%ebp),%eax
  802356:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802358:	89 d8                	mov    %ebx,%eax
  80235a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80235d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802360:	89 ec                	mov    %ebp,%esp
  802362:	5d                   	pop    %ebp
  802363:	c3                   	ret    

00802364 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802364:	55                   	push   %ebp
  802365:	89 e5                	mov    %esp,%ebp
  802367:	56                   	push   %esi
  802368:	53                   	push   %ebx
  802369:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80236c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80236f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802375:	e8 bd ec ff ff       	call   801037 <sys_getenvid>
  80237a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80237d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802381:	8b 55 08             	mov    0x8(%ebp),%edx
  802384:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802388:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80238c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802390:	c7 04 24 60 2f 80 00 	movl   $0x802f60,(%esp)
  802397:	e8 55 de ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80239c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8023a3:	89 04 24             	mov    %eax,(%esp)
  8023a6:	e8 e5 dd ff ff       	call   800190 <vcprintf>
	cprintf("\n");
  8023ab:	c7 04 24 74 28 80 00 	movl   $0x802874,(%esp)
  8023b2:	e8 3a de ff ff       	call   8001f1 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8023b7:	cc                   	int3   
  8023b8:	eb fd                	jmp    8023b7 <_panic+0x53>
	...

008023bc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023bc:	55                   	push   %ebp
  8023bd:	89 e5                	mov    %esp,%ebp
  8023bf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023c2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023c9:	75 54                	jne    80241f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8023cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023d2:	00 
  8023d3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023da:	ee 
  8023db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023e2:	e8 a6 eb ff ff       	call   800f8d <sys_page_alloc>
  8023e7:	85 c0                	test   %eax,%eax
  8023e9:	79 20                	jns    80240b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8023eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ef:	c7 44 24 08 84 2f 80 	movl   $0x802f84,0x8(%esp)
  8023f6:	00 
  8023f7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8023fe:	00 
  8023ff:	c7 04 24 9c 2f 80 00 	movl   $0x802f9c,(%esp)
  802406:	e8 59 ff ff ff       	call   802364 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80240b:	c7 44 24 04 2c 24 80 	movl   $0x80242c,0x4(%esp)
  802412:	00 
  802413:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80241a:	e8 55 ea ff ff       	call   800e74 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80241f:	8b 45 08             	mov    0x8(%ebp),%eax
  802422:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802427:	c9                   	leave  
  802428:	c3                   	ret    
  802429:	00 00                	add    %al,(%eax)
	...

0080242c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80242c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80242d:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802432:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802434:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  802437:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80243b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80243e:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  802442:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802446:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802448:	83 c4 08             	add    $0x8,%esp
	popal
  80244b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  80244c:	83 c4 04             	add    $0x4,%esp
	popfl
  80244f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802450:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802451:	c3                   	ret    
	...

00802460 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802466:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80246c:	b8 01 00 00 00       	mov    $0x1,%eax
  802471:	39 ca                	cmp    %ecx,%edx
  802473:	75 04                	jne    802479 <ipc_find_env+0x19>
  802475:	b0 00                	mov    $0x0,%al
  802477:	eb 0f                	jmp    802488 <ipc_find_env+0x28>
  802479:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80247c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802482:	8b 12                	mov    (%edx),%edx
  802484:	39 ca                	cmp    %ecx,%edx
  802486:	75 0c                	jne    802494 <ipc_find_env+0x34>
			return envs[i].env_id;
  802488:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80248b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  802490:	8b 00                	mov    (%eax),%eax
  802492:	eb 0e                	jmp    8024a2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802494:	83 c0 01             	add    $0x1,%eax
  802497:	3d 00 04 00 00       	cmp    $0x400,%eax
  80249c:	75 db                	jne    802479 <ipc_find_env+0x19>
  80249e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    

008024a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	57                   	push   %edi
  8024a8:	56                   	push   %esi
  8024a9:	53                   	push   %ebx
  8024aa:	83 ec 1c             	sub    $0x1c,%esp
  8024ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8024b6:	85 db                	test   %ebx,%ebx
  8024b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024bd:	0f 44 d8             	cmove  %eax,%ebx
  8024c0:	eb 25                	jmp    8024e7 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8024c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024c5:	74 20                	je     8024e7 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8024c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cb:	c7 44 24 08 aa 2f 80 	movl   $0x802faa,0x8(%esp)
  8024d2:	00 
  8024d3:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8024da:	00 
  8024db:	c7 04 24 c8 2f 80 00 	movl   $0x802fc8,(%esp)
  8024e2:	e8 7d fe ff ff       	call   802364 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8024e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8024ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024f6:	89 34 24             	mov    %esi,(%esp)
  8024f9:	e8 40 e9 ff ff       	call   800e3e <sys_ipc_try_send>
  8024fe:	85 c0                	test   %eax,%eax
  802500:	75 c0                	jne    8024c2 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802502:	e8 bd ea ff ff       	call   800fc4 <sys_yield>
}
  802507:	83 c4 1c             	add    $0x1c,%esp
  80250a:	5b                   	pop    %ebx
  80250b:	5e                   	pop    %esi
  80250c:	5f                   	pop    %edi
  80250d:	5d                   	pop    %ebp
  80250e:	c3                   	ret    

0080250f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80250f:	55                   	push   %ebp
  802510:	89 e5                	mov    %esp,%ebp
  802512:	83 ec 28             	sub    $0x28,%esp
  802515:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802518:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80251b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80251e:	8b 75 08             	mov    0x8(%ebp),%esi
  802521:	8b 45 0c             	mov    0xc(%ebp),%eax
  802524:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802527:	85 c0                	test   %eax,%eax
  802529:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80252e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802531:	89 04 24             	mov    %eax,(%esp)
  802534:	e8 cc e8 ff ff       	call   800e05 <sys_ipc_recv>
  802539:	89 c3                	mov    %eax,%ebx
  80253b:	85 c0                	test   %eax,%eax
  80253d:	79 2a                	jns    802569 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80253f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802543:	89 44 24 04          	mov    %eax,0x4(%esp)
  802547:	c7 04 24 d2 2f 80 00 	movl   $0x802fd2,(%esp)
  80254e:	e8 9e dc ff ff       	call   8001f1 <cprintf>
		if(from_env_store != NULL)
  802553:	85 f6                	test   %esi,%esi
  802555:	74 06                	je     80255d <ipc_recv+0x4e>
			*from_env_store = 0;
  802557:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80255d:	85 ff                	test   %edi,%edi
  80255f:	74 2c                	je     80258d <ipc_recv+0x7e>
			*perm_store = 0;
  802561:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802567:	eb 24                	jmp    80258d <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  802569:	85 f6                	test   %esi,%esi
  80256b:	74 0a                	je     802577 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  80256d:	a1 08 40 80 00       	mov    0x804008,%eax
  802572:	8b 40 74             	mov    0x74(%eax),%eax
  802575:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802577:	85 ff                	test   %edi,%edi
  802579:	74 0a                	je     802585 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  80257b:	a1 08 40 80 00       	mov    0x804008,%eax
  802580:	8b 40 78             	mov    0x78(%eax),%eax
  802583:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802585:	a1 08 40 80 00       	mov    0x804008,%eax
  80258a:	8b 58 70             	mov    0x70(%eax),%ebx
}
  80258d:	89 d8                	mov    %ebx,%eax
  80258f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802592:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802595:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802598:	89 ec                	mov    %ebp,%esp
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    

0080259c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80259c:	55                   	push   %ebp
  80259d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80259f:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a2:	89 c2                	mov    %eax,%edx
  8025a4:	c1 ea 16             	shr    $0x16,%edx
  8025a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025ae:	f6 c2 01             	test   $0x1,%dl
  8025b1:	74 20                	je     8025d3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025b3:	c1 e8 0c             	shr    $0xc,%eax
  8025b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025bd:	a8 01                	test   $0x1,%al
  8025bf:	74 12                	je     8025d3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025c1:	c1 e8 0c             	shr    $0xc,%eax
  8025c4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025c9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025ce:	0f b7 c0             	movzwl %ax,%eax
  8025d1:	eb 05                	jmp    8025d8 <pageref+0x3c>
  8025d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    
  8025da:	00 00                	add    %al,(%eax)
  8025dc:	00 00                	add    %al,(%eax)
	...

008025e0 <__udivdi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	89 e5                	mov    %esp,%ebp
  8025e3:	57                   	push   %edi
  8025e4:	56                   	push   %esi
  8025e5:	83 ec 10             	sub    $0x10,%esp
  8025e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8025eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8025f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025f4:	85 c0                	test   %eax,%eax
  8025f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025f9:	75 35                	jne    802630 <__udivdi3+0x50>
  8025fb:	39 fe                	cmp    %edi,%esi
  8025fd:	77 61                	ja     802660 <__udivdi3+0x80>
  8025ff:	85 f6                	test   %esi,%esi
  802601:	75 0b                	jne    80260e <__udivdi3+0x2e>
  802603:	b8 01 00 00 00       	mov    $0x1,%eax
  802608:	31 d2                	xor    %edx,%edx
  80260a:	f7 f6                	div    %esi
  80260c:	89 c6                	mov    %eax,%esi
  80260e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802611:	31 d2                	xor    %edx,%edx
  802613:	89 f8                	mov    %edi,%eax
  802615:	f7 f6                	div    %esi
  802617:	89 c7                	mov    %eax,%edi
  802619:	89 c8                	mov    %ecx,%eax
  80261b:	f7 f6                	div    %esi
  80261d:	89 c1                	mov    %eax,%ecx
  80261f:	89 fa                	mov    %edi,%edx
  802621:	89 c8                	mov    %ecx,%eax
  802623:	83 c4 10             	add    $0x10,%esp
  802626:	5e                   	pop    %esi
  802627:	5f                   	pop    %edi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    
  80262a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802630:	39 f8                	cmp    %edi,%eax
  802632:	77 1c                	ja     802650 <__udivdi3+0x70>
  802634:	0f bd d0             	bsr    %eax,%edx
  802637:	83 f2 1f             	xor    $0x1f,%edx
  80263a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80263d:	75 39                	jne    802678 <__udivdi3+0x98>
  80263f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802642:	0f 86 a0 00 00 00    	jbe    8026e8 <__udivdi3+0x108>
  802648:	39 f8                	cmp    %edi,%eax
  80264a:	0f 82 98 00 00 00    	jb     8026e8 <__udivdi3+0x108>
  802650:	31 ff                	xor    %edi,%edi
  802652:	31 c9                	xor    %ecx,%ecx
  802654:	89 c8                	mov    %ecx,%eax
  802656:	89 fa                	mov    %edi,%edx
  802658:	83 c4 10             	add    $0x10,%esp
  80265b:	5e                   	pop    %esi
  80265c:	5f                   	pop    %edi
  80265d:	5d                   	pop    %ebp
  80265e:	c3                   	ret    
  80265f:	90                   	nop
  802660:	89 d1                	mov    %edx,%ecx
  802662:	89 fa                	mov    %edi,%edx
  802664:	89 c8                	mov    %ecx,%eax
  802666:	31 ff                	xor    %edi,%edi
  802668:	f7 f6                	div    %esi
  80266a:	89 c1                	mov    %eax,%ecx
  80266c:	89 fa                	mov    %edi,%edx
  80266e:	89 c8                	mov    %ecx,%eax
  802670:	83 c4 10             	add    $0x10,%esp
  802673:	5e                   	pop    %esi
  802674:	5f                   	pop    %edi
  802675:	5d                   	pop    %ebp
  802676:	c3                   	ret    
  802677:	90                   	nop
  802678:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80267c:	89 f2                	mov    %esi,%edx
  80267e:	d3 e0                	shl    %cl,%eax
  802680:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802683:	b8 20 00 00 00       	mov    $0x20,%eax
  802688:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80268b:	89 c1                	mov    %eax,%ecx
  80268d:	d3 ea                	shr    %cl,%edx
  80268f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802693:	0b 55 ec             	or     -0x14(%ebp),%edx
  802696:	d3 e6                	shl    %cl,%esi
  802698:	89 c1                	mov    %eax,%ecx
  80269a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80269d:	89 fe                	mov    %edi,%esi
  80269f:	d3 ee                	shr    %cl,%esi
  8026a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026ab:	d3 e7                	shl    %cl,%edi
  8026ad:	89 c1                	mov    %eax,%ecx
  8026af:	d3 ea                	shr    %cl,%edx
  8026b1:	09 d7                	or     %edx,%edi
  8026b3:	89 f2                	mov    %esi,%edx
  8026b5:	89 f8                	mov    %edi,%eax
  8026b7:	f7 75 ec             	divl   -0x14(%ebp)
  8026ba:	89 d6                	mov    %edx,%esi
  8026bc:	89 c7                	mov    %eax,%edi
  8026be:	f7 65 e8             	mull   -0x18(%ebp)
  8026c1:	39 d6                	cmp    %edx,%esi
  8026c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026c6:	72 30                	jb     8026f8 <__udivdi3+0x118>
  8026c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026cf:	d3 e2                	shl    %cl,%edx
  8026d1:	39 c2                	cmp    %eax,%edx
  8026d3:	73 05                	jae    8026da <__udivdi3+0xfa>
  8026d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8026d8:	74 1e                	je     8026f8 <__udivdi3+0x118>
  8026da:	89 f9                	mov    %edi,%ecx
  8026dc:	31 ff                	xor    %edi,%edi
  8026de:	e9 71 ff ff ff       	jmp    802654 <__udivdi3+0x74>
  8026e3:	90                   	nop
  8026e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026e8:	31 ff                	xor    %edi,%edi
  8026ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8026ef:	e9 60 ff ff ff       	jmp    802654 <__udivdi3+0x74>
  8026f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026fb:	31 ff                	xor    %edi,%edi
  8026fd:	89 c8                	mov    %ecx,%eax
  8026ff:	89 fa                	mov    %edi,%edx
  802701:	83 c4 10             	add    $0x10,%esp
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
	...

00802710 <__umoddi3>:
  802710:	55                   	push   %ebp
  802711:	89 e5                	mov    %esp,%ebp
  802713:	57                   	push   %edi
  802714:	56                   	push   %esi
  802715:	83 ec 20             	sub    $0x20,%esp
  802718:	8b 55 14             	mov    0x14(%ebp),%edx
  80271b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80271e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802721:	8b 75 0c             	mov    0xc(%ebp),%esi
  802724:	85 d2                	test   %edx,%edx
  802726:	89 c8                	mov    %ecx,%eax
  802728:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80272b:	75 13                	jne    802740 <__umoddi3+0x30>
  80272d:	39 f7                	cmp    %esi,%edi
  80272f:	76 3f                	jbe    802770 <__umoddi3+0x60>
  802731:	89 f2                	mov    %esi,%edx
  802733:	f7 f7                	div    %edi
  802735:	89 d0                	mov    %edx,%eax
  802737:	31 d2                	xor    %edx,%edx
  802739:	83 c4 20             	add    $0x20,%esp
  80273c:	5e                   	pop    %esi
  80273d:	5f                   	pop    %edi
  80273e:	5d                   	pop    %ebp
  80273f:	c3                   	ret    
  802740:	39 f2                	cmp    %esi,%edx
  802742:	77 4c                	ja     802790 <__umoddi3+0x80>
  802744:	0f bd ca             	bsr    %edx,%ecx
  802747:	83 f1 1f             	xor    $0x1f,%ecx
  80274a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80274d:	75 51                	jne    8027a0 <__umoddi3+0x90>
  80274f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802752:	0f 87 e0 00 00 00    	ja     802838 <__umoddi3+0x128>
  802758:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80275b:	29 f8                	sub    %edi,%eax
  80275d:	19 d6                	sbb    %edx,%esi
  80275f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802762:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802765:	89 f2                	mov    %esi,%edx
  802767:	83 c4 20             	add    $0x20,%esp
  80276a:	5e                   	pop    %esi
  80276b:	5f                   	pop    %edi
  80276c:	5d                   	pop    %ebp
  80276d:	c3                   	ret    
  80276e:	66 90                	xchg   %ax,%ax
  802770:	85 ff                	test   %edi,%edi
  802772:	75 0b                	jne    80277f <__umoddi3+0x6f>
  802774:	b8 01 00 00 00       	mov    $0x1,%eax
  802779:	31 d2                	xor    %edx,%edx
  80277b:	f7 f7                	div    %edi
  80277d:	89 c7                	mov    %eax,%edi
  80277f:	89 f0                	mov    %esi,%eax
  802781:	31 d2                	xor    %edx,%edx
  802783:	f7 f7                	div    %edi
  802785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802788:	f7 f7                	div    %edi
  80278a:	eb a9                	jmp    802735 <__umoddi3+0x25>
  80278c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802790:	89 c8                	mov    %ecx,%eax
  802792:	89 f2                	mov    %esi,%edx
  802794:	83 c4 20             	add    $0x20,%esp
  802797:	5e                   	pop    %esi
  802798:	5f                   	pop    %edi
  802799:	5d                   	pop    %ebp
  80279a:	c3                   	ret    
  80279b:	90                   	nop
  80279c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027a4:	d3 e2                	shl    %cl,%edx
  8027a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027b8:	89 fa                	mov    %edi,%edx
  8027ba:	d3 ea                	shr    %cl,%edx
  8027bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027c3:	d3 e7                	shl    %cl,%edi
  8027c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027cc:	89 f2                	mov    %esi,%edx
  8027ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8027d1:	89 c7                	mov    %eax,%edi
  8027d3:	d3 ea                	shr    %cl,%edx
  8027d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8027dc:	89 c2                	mov    %eax,%edx
  8027de:	d3 e6                	shl    %cl,%esi
  8027e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027e4:	d3 ea                	shr    %cl,%edx
  8027e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027ea:	09 d6                	or     %edx,%esi
  8027ec:	89 f0                	mov    %esi,%eax
  8027ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027f1:	d3 e7                	shl    %cl,%edi
  8027f3:	89 f2                	mov    %esi,%edx
  8027f5:	f7 75 f4             	divl   -0xc(%ebp)
  8027f8:	89 d6                	mov    %edx,%esi
  8027fa:	f7 65 e8             	mull   -0x18(%ebp)
  8027fd:	39 d6                	cmp    %edx,%esi
  8027ff:	72 2b                	jb     80282c <__umoddi3+0x11c>
  802801:	39 c7                	cmp    %eax,%edi
  802803:	72 23                	jb     802828 <__umoddi3+0x118>
  802805:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802809:	29 c7                	sub    %eax,%edi
  80280b:	19 d6                	sbb    %edx,%esi
  80280d:	89 f0                	mov    %esi,%eax
  80280f:	89 f2                	mov    %esi,%edx
  802811:	d3 ef                	shr    %cl,%edi
  802813:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802817:	d3 e0                	shl    %cl,%eax
  802819:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80281d:	09 f8                	or     %edi,%eax
  80281f:	d3 ea                	shr    %cl,%edx
  802821:	83 c4 20             	add    $0x20,%esp
  802824:	5e                   	pop    %esi
  802825:	5f                   	pop    %edi
  802826:	5d                   	pop    %ebp
  802827:	c3                   	ret    
  802828:	39 d6                	cmp    %edx,%esi
  80282a:	75 d9                	jne    802805 <__umoddi3+0xf5>
  80282c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80282f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802832:	eb d1                	jmp    802805 <__umoddi3+0xf5>
  802834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802838:	39 f2                	cmp    %esi,%edx
  80283a:	0f 82 18 ff ff ff    	jb     802758 <__umoddi3+0x48>
  802840:	e9 1d ff ff ff       	jmp    802762 <__umoddi3+0x52>
