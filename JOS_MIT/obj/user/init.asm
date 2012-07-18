
obj/user/init.debug:     file format elf32-i386


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
  80002c:	e8 4f 01 00 00       	call   800180 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	8b 75 08             	mov    0x8(%ebp),%esi
  80003c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
	for (i = 0; i < n; i++)
  80003f:	b8 00 00 00 00       	mov    $0x0,%eax
  800044:	ba 00 00 00 00       	mov    $0x0,%edx
  800049:	85 db                	test   %ebx,%ebx
  80004b:	7e 10                	jle    80005d <sum+0x29>
		tot ^= i * s[i];
  80004d:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  800051:	0f af ca             	imul   %edx,%ecx
  800054:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800056:	83 c2 01             	add    $0x1,%edx
  800059:	39 da                	cmp    %ebx,%edx
  80005b:	75 f0                	jne    80004d <sum+0x19>
		tot ^= i * s[i];
	return tot;
}
  80005d:	5b                   	pop    %ebx
  80005e:	5e                   	pop    %esi
  80005f:	5d                   	pop    %ebp
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	57                   	push   %edi
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	81 ec 1c 01 00 00    	sub    $0x11c,%esp
  80006d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800070:	c7 04 24 20 1e 80 00 	movl   $0x801e20,(%esp)
  800077:	e8 d1 01 00 00       	call   80024d <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  80007c:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  800083:	00 
  800084:	c7 04 24 00 30 80 00 	movl   $0x803000,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <sum>
  800090:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800095:	74 1a                	je     8000b1 <umain+0x50>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800097:	c7 44 24 08 9e 98 0f 	movl   $0xf989e,0x8(%esp)
  80009e:	00 
  80009f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000a3:	c7 04 24 80 1e 80 00 	movl   $0x801e80,(%esp)
  8000aa:	e8 9e 01 00 00       	call   80024d <cprintf>
  8000af:	eb 0c                	jmp    8000bd <umain+0x5c>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000b1:	c7 04 24 2f 1e 80 00 	movl   $0x801e2f,(%esp)
  8000b8:	e8 90 01 00 00       	call   80024d <cprintf>
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bd:	c7 44 24 04 70 17 00 	movl   $0x1770,0x4(%esp)
  8000c4:	00 
  8000c5:	c7 04 24 20 50 80 00 	movl   $0x805020,(%esp)
  8000cc:	e8 63 ff ff ff       	call   800034 <sum>
  8000d1:	85 c0                	test   %eax,%eax
  8000d3:	74 12                	je     8000e7 <umain+0x86>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d9:	c7 04 24 bc 1e 80 00 	movl   $0x801ebc,(%esp)
  8000e0:	e8 68 01 00 00       	call   80024d <cprintf>
  8000e5:	eb 0c                	jmp    8000f3 <umain+0x92>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	c7 04 24 46 1e 80 00 	movl   $0x801e46,(%esp)
  8000ee:	e8 5a 01 00 00       	call   80024d <cprintf>

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f3:	c7 44 24 04 5c 1e 80 	movl   $0x801e5c,0x4(%esp)
  8000fa:	00 
  8000fb:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800101:	89 04 24             	mov    %eax,(%esp)
  800104:	e8 a1 08 00 00       	call   8009aa <strcat>
	for (i = 0; i < argc; i++) {
  800109:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80010d:	7e 42                	jle    800151 <umain+0xf0>
  80010f:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800114:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  80011a:	c7 44 24 04 68 1e 80 	movl   $0x801e68,0x4(%esp)
  800121:	00 
  800122:	89 34 24             	mov    %esi,(%esp)
  800125:	e8 80 08 00 00       	call   8009aa <strcat>
		strcat(args, argv[i]);
  80012a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800131:	89 34 24             	mov    %esi,(%esp)
  800134:	e8 71 08 00 00       	call   8009aa <strcat>
		strcat(args, "'");
  800139:	c7 44 24 04 69 1e 80 	movl   $0x801e69,0x4(%esp)
  800140:	00 
  800141:	89 34 24             	mov    %esi,(%esp)
  800144:	e8 61 08 00 00       	call   8009aa <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800149:	83 c3 01             	add    $0x1,%ebx
  80014c:	39 5d 08             	cmp    %ebx,0x8(%ebp)
  80014f:	7f c9                	jg     80011a <umain+0xb9>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	c7 04 24 6b 1e 80 00 	movl   $0x801e6b,(%esp)
  800162:	e8 e6 00 00 00       	call   80024d <cprintf>

	cprintf("init: exiting\n");
  800167:	c7 04 24 6f 1e 80 00 	movl   $0x801e6f,(%esp)
  80016e:	e8 da 00 00 00       	call   80024d <cprintf>
}
  800173:	81 c4 1c 01 00 00    	add    $0x11c,%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    
	...

00800180 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 18             	sub    $0x18,%esp
  800186:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800189:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80018c:	8b 75 08             	mov    0x8(%ebp),%esi
  80018f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800192:	e8 8d 0e 00 00       	call   801024 <sys_getenvid>
  800197:	25 ff 03 00 00       	and    $0x3ff,%eax
  80019c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80019f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001a4:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001a9:	85 f6                	test   %esi,%esi
  8001ab:	7e 07                	jle    8001b4 <libmain+0x34>
		binaryname = argv[0];
  8001ad:	8b 03                	mov    (%ebx),%eax
  8001af:	a3 70 47 80 00       	mov    %eax,0x804770

	// call user main routine
	umain(argc, argv);
  8001b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8001b8:	89 34 24             	mov    %esi,(%esp)
  8001bb:	e8 a1 fe ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8001c0:	e8 0b 00 00 00       	call   8001d0 <exit>
}
  8001c5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001c8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001cb:	89 ec                	mov    %ebp,%esp
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    
	...

008001d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001d6:	e8 1e 14 00 00       	call   8015f9 <close_all>
	sys_env_destroy(0);
  8001db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001e2:	e8 78 0e 00 00       	call   80105f <sys_env_destroy>
}
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    
  8001e9:	00 00                	add    %al,(%eax)
	...

008001ec <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fc:	00 00 00 
	b.cnt = 0;
  8001ff:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800206:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800209:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800210:	8b 45 08             	mov    0x8(%ebp),%eax
  800213:	89 44 24 08          	mov    %eax,0x8(%esp)
  800217:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800221:	c7 04 24 67 02 80 00 	movl   $0x800267,(%esp)
  800228:	e8 d0 01 00 00       	call   8003fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800233:	89 44 24 04          	mov    %eax,0x4(%esp)
  800237:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023d:	89 04 24             	mov    %eax,(%esp)
  800240:	e8 8e 0e 00 00       	call   8010d3 <sys_cputs>

	return b.cnt;
}
  800245:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    

0080024d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800253:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	e8 87 ff ff ff       	call   8001ec <vcprintf>
	va_end(ap);

	return cnt;
}
  800265:	c9                   	leave  
  800266:	c3                   	ret    

00800267 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	53                   	push   %ebx
  80026b:	83 ec 14             	sub    $0x14,%esp
  80026e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800271:	8b 03                	mov    (%ebx),%eax
  800273:	8b 55 08             	mov    0x8(%ebp),%edx
  800276:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80027a:	83 c0 01             	add    $0x1,%eax
  80027d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80027f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800284:	75 19                	jne    80029f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800286:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80028d:	00 
  80028e:	8d 43 08             	lea    0x8(%ebx),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 3a 0e 00 00       	call   8010d3 <sys_cputs>
		b->idx = 0;
  800299:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80029f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	5b                   	pop    %ebx
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    
  8002a9:	00 00                	add    %al,(%eax)
  8002ab:	00 00                	add    %al,(%eax)
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002db:	39 d1                	cmp    %edx,%ecx
  8002dd:	72 15                	jb     8002f4 <printnum+0x44>
  8002df:	77 07                	ja     8002e8 <printnum+0x38>
  8002e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e4:	39 d0                	cmp    %edx,%eax
  8002e6:	76 0c                	jbe    8002f4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e8:	83 eb 01             	sub    $0x1,%ebx
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	8d 76 00             	lea    0x0(%esi),%esi
  8002f0:	7f 61                	jg     800353 <printnum+0xa3>
  8002f2:	eb 70                	jmp    800364 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800307:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80030b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80030e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800311:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800314:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800329:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032d:	e8 7e 18 00 00       	call   801bb0 <__udivdi3>
  800332:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800335:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	89 54 24 04          	mov    %edx,0x4(%esp)
  800347:	89 f2                	mov    %esi,%edx
  800349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034c:	e8 5f ff ff ff       	call   8002b0 <printnum>
  800351:	eb 11                	jmp    800364 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800353:	89 74 24 04          	mov    %esi,0x4(%esp)
  800357:	89 3c 24             	mov    %edi,(%esp)
  80035a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035d:	83 eb 01             	sub    $0x1,%ebx
  800360:	85 db                	test   %ebx,%ebx
  800362:	7f ef                	jg     800353 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 74 24 04          	mov    0x4(%esp),%esi
  80036c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800373:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037a:	00 
  80037b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80037e:	89 14 24             	mov    %edx,(%esp)
  800381:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800384:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800388:	e8 53 19 00 00       	call   801ce0 <__umoddi3>
  80038d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800391:	0f be 80 f5 1e 80 00 	movsbl 0x801ef5(%eax),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039e:	83 c4 4c             	add    $0x4c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a9:	83 fa 01             	cmp    $0x1,%edx
  8003ac:	7e 0e                	jle    8003bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ae:	8b 10                	mov    (%eax),%edx
  8003b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 02                	mov    (%edx),%eax
  8003b7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ba:	eb 22                	jmp    8003de <getuint+0x38>
	else if (lflag)
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	74 10                	je     8003d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ce:	eb 0e                	jmp    8003de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f4:	88 0a                	mov    %cl,(%edx)
  8003f6:	83 c2 01             	add    $0x1,%edx
  8003f9:	89 10                	mov    %edx,(%eax)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	57                   	push   %edi
  800401:	56                   	push   %esi
  800402:	53                   	push   %ebx
  800403:	83 ec 5c             	sub    $0x5c,%esp
  800406:	8b 7d 08             	mov    0x8(%ebp),%edi
  800409:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800416:	eb 11                	jmp    800429 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 68 04 00 00    	je     800888 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800420:	89 74 24 04          	mov    %esi,0x4(%esp)
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800429:	0f b6 03             	movzbl (%ebx),%eax
  80042c:	83 c3 01             	add    $0x1,%ebx
  80042f:	83 f8 25             	cmp    $0x25,%eax
  800432:	75 e4                	jne    800418 <vprintfmt+0x1b>
  800434:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80043b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800442:	b9 00 00 00 00       	mov    $0x0,%ecx
  800447:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80044b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800452:	eb 06                	jmp    80045a <vprintfmt+0x5d>
  800454:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800458:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	0f b6 13             	movzbl (%ebx),%edx
  80045d:	0f b6 c2             	movzbl %dl,%eax
  800460:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800463:	8d 43 01             	lea    0x1(%ebx),%eax
  800466:	83 ea 23             	sub    $0x23,%edx
  800469:	80 fa 55             	cmp    $0x55,%dl
  80046c:	0f 87 f9 03 00 00    	ja     80086b <vprintfmt+0x46e>
  800472:	0f b6 d2             	movzbl %dl,%edx
  800475:	ff 24 95 e0 20 80 00 	jmp    *0x8020e0(,%edx,4)
  80047c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800480:	eb d6                	jmp    800458 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800482:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800485:	83 ea 30             	sub    $0x30,%edx
  800488:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80048b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80048e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800491:	83 fb 09             	cmp    $0x9,%ebx
  800494:	77 54                	ja     8004ea <vprintfmt+0xed>
  800496:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800499:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80049f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004a6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004a9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004ac:	83 fb 09             	cmp    $0x9,%ebx
  8004af:	76 eb                	jbe    80049c <vprintfmt+0x9f>
  8004b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004b7:	eb 31                	jmp    8004ea <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004bf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004c2:	8b 12                	mov    (%edx),%edx
  8004c4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004c7:	eb 21                	jmp    8004ea <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8004c9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8004d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004d9:	e9 7a ff ff ff       	jmp    800458 <vprintfmt+0x5b>
  8004de:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004e5:	e9 6e ff ff ff       	jmp    800458 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ea:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ee:	0f 89 64 ff ff ff    	jns    800458 <vprintfmt+0x5b>
  8004f4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004f7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004fa:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800500:	e9 53 ff ff ff       	jmp    800458 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800505:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800508:	e9 4b ff ff ff       	jmp    800458 <vprintfmt+0x5b>
  80050d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 04             	lea    0x4(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	ff d7                	call   *%edi
  800524:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800527:	e9 fd fe ff ff       	jmp    800429 <vprintfmt+0x2c>
  80052c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	89 c2                	mov    %eax,%edx
  80053c:	c1 fa 1f             	sar    $0x1f,%edx
  80053f:	31 d0                	xor    %edx,%eax
  800541:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800543:	83 f8 0f             	cmp    $0xf,%eax
  800546:	7f 0b                	jg     800553 <vprintfmt+0x156>
  800548:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80054f:	85 d2                	test   %edx,%edx
  800551:	75 20                	jne    800573 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800553:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800557:	c7 44 24 08 06 1f 80 	movl   $0x801f06,0x8(%esp)
  80055e:	00 
  80055f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800563:	89 3c 24             	mov    %edi,(%esp)
  800566:	e8 a5 03 00 00       	call   800910 <printfmt>
  80056b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056e:	e9 b6 fe ff ff       	jmp    800429 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800573:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800577:	c7 44 24 08 57 23 80 	movl   $0x802357,0x8(%esp)
  80057e:	00 
  80057f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800583:	89 3c 24             	mov    %edi,(%esp)
  800586:	e8 85 03 00 00       	call   800910 <printfmt>
  80058b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80058e:	e9 96 fe ff ff       	jmp    800429 <vprintfmt+0x2c>
  800593:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800596:	89 c3                	mov    %eax,%ebx
  800598:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80059e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	b8 0f 1f 80 00       	mov    $0x801f0f,%eax
  8005b6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8005ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005bd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005c1:	7e 06                	jle    8005c9 <vprintfmt+0x1cc>
  8005c3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005c7:	75 13                	jne    8005dc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005cc:	0f be 02             	movsbl (%edx),%eax
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	0f 85 a2 00 00 00    	jne    800679 <vprintfmt+0x27c>
  8005d7:	e9 8f 00 00 00       	jmp    80066b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005e3:	89 0c 24             	mov    %ecx,(%esp)
  8005e6:	e8 70 03 00 00       	call   80095b <strnlen>
  8005eb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ee:	29 c2                	sub    %eax,%edx
  8005f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005f3:	85 d2                	test   %edx,%edx
  8005f5:	7e d2                	jle    8005c9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005f7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005fb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005fe:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800601:	89 d3                	mov    %edx,%ebx
  800603:	89 74 24 04          	mov    %esi,0x4(%esp)
  800607:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 eb 01             	sub    $0x1,%ebx
  800612:	85 db                	test   %ebx,%ebx
  800614:	7f ed                	jg     800603 <vprintfmt+0x206>
  800616:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800619:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800620:	eb a7                	jmp    8005c9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800622:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800626:	74 1b                	je     800643 <vprintfmt+0x246>
  800628:	8d 50 e0             	lea    -0x20(%eax),%edx
  80062b:	83 fa 5e             	cmp    $0x5e,%edx
  80062e:	76 13                	jbe    800643 <vprintfmt+0x246>
					putch('?', putdat);
  800630:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800633:	89 54 24 04          	mov    %edx,0x4(%esp)
  800637:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80063e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800641:	eb 0d                	jmp    800650 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800643:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800646:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80064a:	89 04 24             	mov    %eax,(%esp)
  80064d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800650:	83 ef 01             	sub    $0x1,%edi
  800653:	0f be 03             	movsbl (%ebx),%eax
  800656:	85 c0                	test   %eax,%eax
  800658:	74 05                	je     80065f <vprintfmt+0x262>
  80065a:	83 c3 01             	add    $0x1,%ebx
  80065d:	eb 31                	jmp    800690 <vprintfmt+0x293>
  80065f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800662:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800665:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800668:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80066b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80066f:	7f 36                	jg     8006a7 <vprintfmt+0x2aa>
  800671:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800674:	e9 b0 fd ff ff       	jmp    800429 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800679:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80067c:	83 c2 01             	add    $0x1,%edx
  80067f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800682:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800685:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800688:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80068b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80068e:	89 d3                	mov    %edx,%ebx
  800690:	85 f6                	test   %esi,%esi
  800692:	78 8e                	js     800622 <vprintfmt+0x225>
  800694:	83 ee 01             	sub    $0x1,%esi
  800697:	79 89                	jns    800622 <vprintfmt+0x225>
  800699:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80069c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006a5:	eb c4                	jmp    80066b <vprintfmt+0x26e>
  8006a7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006aa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006b8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ba:	83 eb 01             	sub    $0x1,%ebx
  8006bd:	85 db                	test   %ebx,%ebx
  8006bf:	7f ec                	jg     8006ad <vprintfmt+0x2b0>
  8006c1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006c4:	e9 60 fd ff ff       	jmp    800429 <vprintfmt+0x2c>
  8006c9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006cc:	83 f9 01             	cmp    $0x1,%ecx
  8006cf:	7e 16                	jle    8006e7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 50 08             	lea    0x8(%eax),%edx
  8006d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006da:	8b 10                	mov    (%eax),%edx
  8006dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006df:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006e2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006e5:	eb 32                	jmp    800719 <vprintfmt+0x31c>
	else if (lflag)
  8006e7:	85 c9                	test   %ecx,%ecx
  8006e9:	74 18                	je     800703 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8006eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ee:	8d 50 04             	lea    0x4(%eax),%edx
  8006f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f4:	8b 00                	mov    (%eax),%eax
  8006f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f9:	89 c1                	mov    %eax,%ecx
  8006fb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fe:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800701:	eb 16                	jmp    800719 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800703:	8b 45 14             	mov    0x14(%ebp),%eax
  800706:	8d 50 04             	lea    0x4(%eax),%edx
  800709:	89 55 14             	mov    %edx,0x14(%ebp)
  80070c:	8b 00                	mov    (%eax),%eax
  80070e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800711:	89 c2                	mov    %eax,%edx
  800713:	c1 fa 1f             	sar    $0x1f,%edx
  800716:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800719:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80071f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800724:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800728:	0f 89 8a 00 00 00    	jns    8007b8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80072e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800732:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800739:	ff d7                	call   *%edi
				num = -(long long) num;
  80073b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80073e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800741:	f7 d8                	neg    %eax
  800743:	83 d2 00             	adc    $0x0,%edx
  800746:	f7 da                	neg    %edx
  800748:	eb 6e                	jmp    8007b8 <vprintfmt+0x3bb>
  80074a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80074d:	89 ca                	mov    %ecx,%edx
  80074f:	8d 45 14             	lea    0x14(%ebp),%eax
  800752:	e8 4f fc ff ff       	call   8003a6 <getuint>
  800757:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80075c:	eb 5a                	jmp    8007b8 <vprintfmt+0x3bb>
  80075e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800761:	89 ca                	mov    %ecx,%edx
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
  800766:	e8 3b fc ff ff       	call   8003a6 <getuint>
  80076b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800770:	eb 46                	jmp    8007b8 <vprintfmt+0x3bb>
  800772:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800775:	89 74 24 04          	mov    %esi,0x4(%esp)
  800779:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800780:	ff d7                	call   *%edi
			putch('x', putdat);
  800782:	89 74 24 04          	mov    %esi,0x4(%esp)
  800786:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80078d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 50 04             	lea    0x4(%eax),%edx
  800795:	89 55 14             	mov    %edx,0x14(%ebp)
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	ba 00 00 00 00       	mov    $0x0,%edx
  80079f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a4:	eb 12                	jmp    8007b8 <vprintfmt+0x3bb>
  8007a6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007a9:	89 ca                	mov    %ecx,%edx
  8007ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ae:	e8 f3 fb ff ff       	call   8003a6 <getuint>
  8007b3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007b8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8007bc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007c0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007c3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007c7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007cb:	89 04 24             	mov    %eax,(%esp)
  8007ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007d2:	89 f2                	mov    %esi,%edx
  8007d4:	89 f8                	mov    %edi,%eax
  8007d6:	e8 d5 fa ff ff       	call   8002b0 <printnum>
  8007db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007de:	e9 46 fc ff ff       	jmp    800429 <vprintfmt+0x2c>
  8007e3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ec:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ef:	8b 00                	mov    (%eax),%eax
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	75 24                	jne    800819 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8007f5:	c7 44 24 0c 28 20 80 	movl   $0x802028,0xc(%esp)
  8007fc:	00 
  8007fd:	c7 44 24 08 57 23 80 	movl   $0x802357,0x8(%esp)
  800804:	00 
  800805:	89 74 24 04          	mov    %esi,0x4(%esp)
  800809:	89 3c 24             	mov    %edi,(%esp)
  80080c:	e8 ff 00 00 00       	call   800910 <printfmt>
  800811:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800814:	e9 10 fc ff ff       	jmp    800429 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800819:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80081c:	7e 29                	jle    800847 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80081e:	0f b6 16             	movzbl (%esi),%edx
  800821:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800823:	c7 44 24 0c 60 20 80 	movl   $0x802060,0xc(%esp)
  80082a:	00 
  80082b:	c7 44 24 08 57 23 80 	movl   $0x802357,0x8(%esp)
  800832:	00 
  800833:	89 74 24 04          	mov    %esi,0x4(%esp)
  800837:	89 3c 24             	mov    %edi,(%esp)
  80083a:	e8 d1 00 00 00       	call   800910 <printfmt>
  80083f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800842:	e9 e2 fb ff ff       	jmp    800429 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800847:	0f b6 16             	movzbl (%esi),%edx
  80084a:	88 10                	mov    %dl,(%eax)
  80084c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80084f:	e9 d5 fb ff ff       	jmp    800429 <vprintfmt+0x2c>
  800854:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800857:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80085a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085e:	89 14 24             	mov    %edx,(%esp)
  800861:	ff d7                	call   *%edi
  800863:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800866:	e9 be fb ff ff       	jmp    800429 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80086b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800876:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800878:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80087b:	80 38 25             	cmpb   $0x25,(%eax)
  80087e:	0f 84 a5 fb ff ff    	je     800429 <vprintfmt+0x2c>
  800884:	89 c3                	mov    %eax,%ebx
  800886:	eb f0                	jmp    800878 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800888:	83 c4 5c             	add    $0x5c,%esp
  80088b:	5b                   	pop    %ebx
  80088c:	5e                   	pop    %esi
  80088d:	5f                   	pop    %edi
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 28             	sub    $0x28,%esp
  800896:	8b 45 08             	mov    0x8(%ebp),%eax
  800899:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80089c:	85 c0                	test   %eax,%eax
  80089e:	74 04                	je     8008a4 <vsnprintf+0x14>
  8008a0:	85 d2                	test   %edx,%edx
  8008a2:	7f 07                	jg     8008ab <vsnprintf+0x1b>
  8008a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a9:	eb 3b                	jmp    8008e6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ae:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  8008d8:	e8 20 fb ff ff       	call   8003fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008e6:	c9                   	leave  
  8008e7:	c3                   	ret    

008008e8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008ee:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800903:	8b 45 08             	mov    0x8(%ebp),%eax
  800906:	89 04 24             	mov    %eax,(%esp)
  800909:	e8 82 ff ff ff       	call   800890 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090e:	c9                   	leave  
  80090f:	c3                   	ret    

00800910 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800916:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800919:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80091d:	8b 45 10             	mov    0x10(%ebp),%eax
  800920:	89 44 24 08          	mov    %eax,0x8(%esp)
  800924:	8b 45 0c             	mov    0xc(%ebp),%eax
  800927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	89 04 24             	mov    %eax,(%esp)
  800931:	e8 c7 fa ff ff       	call   8003fd <vprintfmt>
	va_end(ap);
}
  800936:	c9                   	leave  
  800937:	c3                   	ret    
	...

00800940 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800946:	b8 00 00 00 00       	mov    $0x0,%eax
  80094b:	80 3a 00             	cmpb   $0x0,(%edx)
  80094e:	74 09                	je     800959 <strlen+0x19>
		n++;
  800950:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800953:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800957:	75 f7                	jne    800950 <strlen+0x10>
		n++;
	return n;
}
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	53                   	push   %ebx
  80095f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800965:	85 c9                	test   %ecx,%ecx
  800967:	74 19                	je     800982 <strnlen+0x27>
  800969:	80 3b 00             	cmpb   $0x0,(%ebx)
  80096c:	74 14                	je     800982 <strnlen+0x27>
  80096e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800973:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800976:	39 c8                	cmp    %ecx,%eax
  800978:	74 0d                	je     800987 <strnlen+0x2c>
  80097a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80097e:	75 f3                	jne    800973 <strnlen+0x18>
  800980:	eb 05                	jmp    800987 <strnlen+0x2c>
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800987:	5b                   	pop    %ebx
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	53                   	push   %ebx
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800994:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800999:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80099d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009a0:	83 c2 01             	add    $0x1,%edx
  8009a3:	84 c9                	test   %cl,%cl
  8009a5:	75 f2                	jne    800999 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	83 ec 08             	sub    $0x8,%esp
  8009b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009b4:	89 1c 24             	mov    %ebx,(%esp)
  8009b7:	e8 84 ff ff ff       	call   800940 <strlen>
	strcpy(dst + len, src);
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009c3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009c6:	89 04 24             	mov    %eax,(%esp)
  8009c9:	e8 bc ff ff ff       	call   80098a <strcpy>
	return dst;
}
  8009ce:	89 d8                	mov    %ebx,%eax
  8009d0:	83 c4 08             	add    $0x8,%esp
  8009d3:	5b                   	pop    %ebx
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009e1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e4:	85 f6                	test   %esi,%esi
  8009e6:	74 18                	je     800a00 <strncpy+0x2a>
  8009e8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009ed:	0f b6 1a             	movzbl (%edx),%ebx
  8009f0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009f3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009f6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	39 ce                	cmp    %ecx,%esi
  8009fe:	77 ed                	ja     8009ed <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	56                   	push   %esi
  800a08:	53                   	push   %ebx
  800a09:	8b 75 08             	mov    0x8(%ebp),%esi
  800a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a12:	89 f0                	mov    %esi,%eax
  800a14:	85 c9                	test   %ecx,%ecx
  800a16:	74 27                	je     800a3f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a18:	83 e9 01             	sub    $0x1,%ecx
  800a1b:	74 1d                	je     800a3a <strlcpy+0x36>
  800a1d:	0f b6 1a             	movzbl (%edx),%ebx
  800a20:	84 db                	test   %bl,%bl
  800a22:	74 16                	je     800a3a <strlcpy+0x36>
			*dst++ = *src++;
  800a24:	88 18                	mov    %bl,(%eax)
  800a26:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a29:	83 e9 01             	sub    $0x1,%ecx
  800a2c:	74 0e                	je     800a3c <strlcpy+0x38>
			*dst++ = *src++;
  800a2e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a31:	0f b6 1a             	movzbl (%edx),%ebx
  800a34:	84 db                	test   %bl,%bl
  800a36:	75 ec                	jne    800a24 <strlcpy+0x20>
  800a38:	eb 02                	jmp    800a3c <strlcpy+0x38>
  800a3a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a3c:	c6 00 00             	movb   $0x0,(%eax)
  800a3f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a41:	5b                   	pop    %ebx
  800a42:	5e                   	pop    %esi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a4e:	0f b6 01             	movzbl (%ecx),%eax
  800a51:	84 c0                	test   %al,%al
  800a53:	74 15                	je     800a6a <strcmp+0x25>
  800a55:	3a 02                	cmp    (%edx),%al
  800a57:	75 11                	jne    800a6a <strcmp+0x25>
		p++, q++;
  800a59:	83 c1 01             	add    $0x1,%ecx
  800a5c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	84 c0                	test   %al,%al
  800a64:	74 04                	je     800a6a <strcmp+0x25>
  800a66:	3a 02                	cmp    (%edx),%al
  800a68:	74 ef                	je     800a59 <strcmp+0x14>
  800a6a:	0f b6 c0             	movzbl %al,%eax
  800a6d:	0f b6 12             	movzbl (%edx),%edx
  800a70:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	53                   	push   %ebx
  800a78:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a7e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a81:	85 c0                	test   %eax,%eax
  800a83:	74 23                	je     800aa8 <strncmp+0x34>
  800a85:	0f b6 1a             	movzbl (%edx),%ebx
  800a88:	84 db                	test   %bl,%bl
  800a8a:	74 25                	je     800ab1 <strncmp+0x3d>
  800a8c:	3a 19                	cmp    (%ecx),%bl
  800a8e:	75 21                	jne    800ab1 <strncmp+0x3d>
  800a90:	83 e8 01             	sub    $0x1,%eax
  800a93:	74 13                	je     800aa8 <strncmp+0x34>
		n--, p++, q++;
  800a95:	83 c2 01             	add    $0x1,%edx
  800a98:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a9b:	0f b6 1a             	movzbl (%edx),%ebx
  800a9e:	84 db                	test   %bl,%bl
  800aa0:	74 0f                	je     800ab1 <strncmp+0x3d>
  800aa2:	3a 19                	cmp    (%ecx),%bl
  800aa4:	74 ea                	je     800a90 <strncmp+0x1c>
  800aa6:	eb 09                	jmp    800ab1 <strncmp+0x3d>
  800aa8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aad:	5b                   	pop    %ebx
  800aae:	5d                   	pop    %ebp
  800aaf:	90                   	nop
  800ab0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab1:	0f b6 02             	movzbl (%edx),%eax
  800ab4:	0f b6 11             	movzbl (%ecx),%edx
  800ab7:	29 d0                	sub    %edx,%eax
  800ab9:	eb f2                	jmp    800aad <strncmp+0x39>

00800abb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac5:	0f b6 10             	movzbl (%eax),%edx
  800ac8:	84 d2                	test   %dl,%dl
  800aca:	74 18                	je     800ae4 <strchr+0x29>
		if (*s == c)
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	75 0a                	jne    800ada <strchr+0x1f>
  800ad0:	eb 17                	jmp    800ae9 <strchr+0x2e>
  800ad2:	38 ca                	cmp    %cl,%dl
  800ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ad8:	74 0f                	je     800ae9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	0f b6 10             	movzbl (%eax),%edx
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	75 ee                	jne    800ad2 <strchr+0x17>
  800ae4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ae9:	5d                   	pop    %ebp
  800aea:	c3                   	ret    

00800aeb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af5:	0f b6 10             	movzbl (%eax),%edx
  800af8:	84 d2                	test   %dl,%dl
  800afa:	74 18                	je     800b14 <strfind+0x29>
		if (*s == c)
  800afc:	38 ca                	cmp    %cl,%dl
  800afe:	75 0a                	jne    800b0a <strfind+0x1f>
  800b00:	eb 12                	jmp    800b14 <strfind+0x29>
  800b02:	38 ca                	cmp    %cl,%dl
  800b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b08:	74 0a                	je     800b14 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	0f b6 10             	movzbl (%eax),%edx
  800b10:	84 d2                	test   %dl,%dl
  800b12:	75 ee                	jne    800b02 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	83 ec 0c             	sub    $0xc,%esp
  800b1c:	89 1c 24             	mov    %ebx,(%esp)
  800b1f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b23:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b30:	85 c9                	test   %ecx,%ecx
  800b32:	74 30                	je     800b64 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b3a:	75 25                	jne    800b61 <memset+0x4b>
  800b3c:	f6 c1 03             	test   $0x3,%cl
  800b3f:	75 20                	jne    800b61 <memset+0x4b>
		c &= 0xFF;
  800b41:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b44:	89 d3                	mov    %edx,%ebx
  800b46:	c1 e3 08             	shl    $0x8,%ebx
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	c1 e6 18             	shl    $0x18,%esi
  800b4e:	89 d0                	mov    %edx,%eax
  800b50:	c1 e0 10             	shl    $0x10,%eax
  800b53:	09 f0                	or     %esi,%eax
  800b55:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b57:	09 d8                	or     %ebx,%eax
  800b59:	c1 e9 02             	shr    $0x2,%ecx
  800b5c:	fc                   	cld    
  800b5d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5f:	eb 03                	jmp    800b64 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b61:	fc                   	cld    
  800b62:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b64:	89 f8                	mov    %edi,%eax
  800b66:	8b 1c 24             	mov    (%esp),%ebx
  800b69:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b6d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b71:	89 ec                	mov    %ebp,%esp
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
  800b7b:	89 34 24             	mov    %esi,(%esp)
  800b7e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b88:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b8b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b8d:	39 c6                	cmp    %eax,%esi
  800b8f:	73 35                	jae    800bc6 <memmove+0x51>
  800b91:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b94:	39 d0                	cmp    %edx,%eax
  800b96:	73 2e                	jae    800bc6 <memmove+0x51>
		s += n;
		d += n;
  800b98:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9a:	f6 c2 03             	test   $0x3,%dl
  800b9d:	75 1b                	jne    800bba <memmove+0x45>
  800b9f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba5:	75 13                	jne    800bba <memmove+0x45>
  800ba7:	f6 c1 03             	test   $0x3,%cl
  800baa:	75 0e                	jne    800bba <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800bac:	83 ef 04             	sub    $0x4,%edi
  800baf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb2:	c1 e9 02             	shr    $0x2,%ecx
  800bb5:	fd                   	std    
  800bb6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb8:	eb 09                	jmp    800bc3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bba:	83 ef 01             	sub    $0x1,%edi
  800bbd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bc0:	fd                   	std    
  800bc1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bc4:	eb 20                	jmp    800be6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bcc:	75 15                	jne    800be3 <memmove+0x6e>
  800bce:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd4:	75 0d                	jne    800be3 <memmove+0x6e>
  800bd6:	f6 c1 03             	test   $0x3,%cl
  800bd9:	75 08                	jne    800be3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bdb:	c1 e9 02             	shr    $0x2,%ecx
  800bde:	fc                   	cld    
  800bdf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be1:	eb 03                	jmp    800be6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be3:	fc                   	cld    
  800be4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be6:	8b 34 24             	mov    (%esp),%esi
  800be9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bed:	89 ec                	mov    %ebp,%esp
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bf7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bfa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c01:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	89 04 24             	mov    %eax,(%esp)
  800c0b:	e8 65 ff ff ff       	call   800b75 <memmove>
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 75 08             	mov    0x8(%ebp),%esi
  800c1b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c1e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c21:	85 c9                	test   %ecx,%ecx
  800c23:	74 36                	je     800c5b <memcmp+0x49>
		if (*s1 != *s2)
  800c25:	0f b6 06             	movzbl (%esi),%eax
  800c28:	0f b6 1f             	movzbl (%edi),%ebx
  800c2b:	38 d8                	cmp    %bl,%al
  800c2d:	74 20                	je     800c4f <memcmp+0x3d>
  800c2f:	eb 14                	jmp    800c45 <memcmp+0x33>
  800c31:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c36:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c3b:	83 c2 01             	add    $0x1,%edx
  800c3e:	83 e9 01             	sub    $0x1,%ecx
  800c41:	38 d8                	cmp    %bl,%al
  800c43:	74 12                	je     800c57 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c45:	0f b6 c0             	movzbl %al,%eax
  800c48:	0f b6 db             	movzbl %bl,%ebx
  800c4b:	29 d8                	sub    %ebx,%eax
  800c4d:	eb 11                	jmp    800c60 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c4f:	83 e9 01             	sub    $0x1,%ecx
  800c52:	ba 00 00 00 00       	mov    $0x0,%edx
  800c57:	85 c9                	test   %ecx,%ecx
  800c59:	75 d6                	jne    800c31 <memcmp+0x1f>
  800c5b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    

00800c65 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c65:	55                   	push   %ebp
  800c66:	89 e5                	mov    %esp,%ebp
  800c68:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c6b:	89 c2                	mov    %eax,%edx
  800c6d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c70:	39 d0                	cmp    %edx,%eax
  800c72:	73 15                	jae    800c89 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c74:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c78:	38 08                	cmp    %cl,(%eax)
  800c7a:	75 06                	jne    800c82 <memfind+0x1d>
  800c7c:	eb 0b                	jmp    800c89 <memfind+0x24>
  800c7e:	38 08                	cmp    %cl,(%eax)
  800c80:	74 07                	je     800c89 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c82:	83 c0 01             	add    $0x1,%eax
  800c85:	39 c2                	cmp    %eax,%edx
  800c87:	77 f5                	ja     800c7e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c89:	5d                   	pop    %ebp
  800c8a:	c3                   	ret    

00800c8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c8b:	55                   	push   %ebp
  800c8c:	89 e5                	mov    %esp,%ebp
  800c8e:	57                   	push   %edi
  800c8f:	56                   	push   %esi
  800c90:	53                   	push   %ebx
  800c91:	83 ec 04             	sub    $0x4,%esp
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c9a:	0f b6 02             	movzbl (%edx),%eax
  800c9d:	3c 20                	cmp    $0x20,%al
  800c9f:	74 04                	je     800ca5 <strtol+0x1a>
  800ca1:	3c 09                	cmp    $0x9,%al
  800ca3:	75 0e                	jne    800cb3 <strtol+0x28>
		s++;
  800ca5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca8:	0f b6 02             	movzbl (%edx),%eax
  800cab:	3c 20                	cmp    $0x20,%al
  800cad:	74 f6                	je     800ca5 <strtol+0x1a>
  800caf:	3c 09                	cmp    $0x9,%al
  800cb1:	74 f2                	je     800ca5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cb3:	3c 2b                	cmp    $0x2b,%al
  800cb5:	75 0c                	jne    800cc3 <strtol+0x38>
		s++;
  800cb7:	83 c2 01             	add    $0x1,%edx
  800cba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cc1:	eb 15                	jmp    800cd8 <strtol+0x4d>
	else if (*s == '-')
  800cc3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cca:	3c 2d                	cmp    $0x2d,%al
  800ccc:	75 0a                	jne    800cd8 <strtol+0x4d>
		s++, neg = 1;
  800cce:	83 c2 01             	add    $0x1,%edx
  800cd1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cd8:	85 db                	test   %ebx,%ebx
  800cda:	0f 94 c0             	sete   %al
  800cdd:	74 05                	je     800ce4 <strtol+0x59>
  800cdf:	83 fb 10             	cmp    $0x10,%ebx
  800ce2:	75 18                	jne    800cfc <strtol+0x71>
  800ce4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ce7:	75 13                	jne    800cfc <strtol+0x71>
  800ce9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ced:	8d 76 00             	lea    0x0(%esi),%esi
  800cf0:	75 0a                	jne    800cfc <strtol+0x71>
		s += 2, base = 16;
  800cf2:	83 c2 02             	add    $0x2,%edx
  800cf5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cfa:	eb 15                	jmp    800d11 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cfc:	84 c0                	test   %al,%al
  800cfe:	66 90                	xchg   %ax,%ax
  800d00:	74 0f                	je     800d11 <strtol+0x86>
  800d02:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d07:	80 3a 30             	cmpb   $0x30,(%edx)
  800d0a:	75 05                	jne    800d11 <strtol+0x86>
		s++, base = 8;
  800d0c:	83 c2 01             	add    $0x1,%edx
  800d0f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d11:	b8 00 00 00 00       	mov    $0x0,%eax
  800d16:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d18:	0f b6 0a             	movzbl (%edx),%ecx
  800d1b:	89 cf                	mov    %ecx,%edi
  800d1d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d20:	80 fb 09             	cmp    $0x9,%bl
  800d23:	77 08                	ja     800d2d <strtol+0xa2>
			dig = *s - '0';
  800d25:	0f be c9             	movsbl %cl,%ecx
  800d28:	83 e9 30             	sub    $0x30,%ecx
  800d2b:	eb 1e                	jmp    800d4b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d2d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d30:	80 fb 19             	cmp    $0x19,%bl
  800d33:	77 08                	ja     800d3d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d35:	0f be c9             	movsbl %cl,%ecx
  800d38:	83 e9 57             	sub    $0x57,%ecx
  800d3b:	eb 0e                	jmp    800d4b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d3d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d40:	80 fb 19             	cmp    $0x19,%bl
  800d43:	77 15                	ja     800d5a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d45:	0f be c9             	movsbl %cl,%ecx
  800d48:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d4b:	39 f1                	cmp    %esi,%ecx
  800d4d:	7d 0b                	jge    800d5a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d4f:	83 c2 01             	add    $0x1,%edx
  800d52:	0f af c6             	imul   %esi,%eax
  800d55:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d58:	eb be                	jmp    800d18 <strtol+0x8d>
  800d5a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d5c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d60:	74 05                	je     800d67 <strtol+0xdc>
		*endptr = (char *) s;
  800d62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d65:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d67:	89 ca                	mov    %ecx,%edx
  800d69:	f7 da                	neg    %edx
  800d6b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d6f:	0f 45 c2             	cmovne %edx,%eax
}
  800d72:	83 c4 04             	add    $0x4,%esp
  800d75:	5b                   	pop    %ebx
  800d76:	5e                   	pop    %esi
  800d77:	5f                   	pop    %edi
  800d78:	5d                   	pop    %ebp
  800d79:	c3                   	ret    
	...

00800d7c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 48             	sub    $0x48,%esp
  800d82:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d85:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d88:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d8b:	89 c6                	mov    %eax,%esi
  800d8d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d90:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d92:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9b:	51                   	push   %ecx
  800d9c:	52                   	push   %edx
  800d9d:	53                   	push   %ebx
  800d9e:	54                   	push   %esp
  800d9f:	55                   	push   %ebp
  800da0:	56                   	push   %esi
  800da1:	57                   	push   %edi
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	8d 35 ac 0d 80 00    	lea    0x800dac,%esi
  800daa:	0f 34                	sysenter 

00800dac <.after_sysenter_label>:
  800dac:	5f                   	pop    %edi
  800dad:	5e                   	pop    %esi
  800dae:	5d                   	pop    %ebp
  800daf:	5c                   	pop    %esp
  800db0:	5b                   	pop    %ebx
  800db1:	5a                   	pop    %edx
  800db2:	59                   	pop    %ecx
  800db3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800db5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800db9:	74 28                	je     800de3 <.after_sysenter_label+0x37>
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 24                	jle    800de3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800dc7:	c7 44 24 08 80 22 80 	movl   $0x802280,0x8(%esp)
  800dce:	00 
  800dcf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800dd6:	00 
  800dd7:	c7 04 24 9d 22 80 00 	movl   $0x80229d,(%esp)
  800dde:	e8 1d 0c 00 00       	call   801a00 <_panic>

	return ret;
}
  800de3:	89 d0                	mov    %edx,%eax
  800de5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800deb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dee:	89 ec                	mov    %ebp,%esp
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800df8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dff:	00 
  800e00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e07:	00 
  800e08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e0f:	00 
  800e10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1a:	ba 01 00 00 00       	mov    $0x1,%edx
  800e1f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e24:	e8 53 ff ff ff       	call   800d7c <syscall>
}
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    

00800e2b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e38:	00 
  800e39:	8b 45 14             	mov    0x14(%ebp),%eax
  800e3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e40:	8b 45 10             	mov    0x10(%ebp),%eax
  800e43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	89 04 24             	mov    %eax,(%esp)
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	ba 00 00 00 00       	mov    $0x0,%edx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	e8 1d ff ff ff       	call   800d7c <syscall>
}
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    

00800e61 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e67:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e76:	00 
  800e77:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e7e:	00 
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	89 04 24             	mov    %eax,(%esp)
  800e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e88:	ba 01 00 00 00       	mov    $0x1,%edx
  800e8d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e92:	e8 e5 fe ff ff       	call   800d7c <syscall>
}
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e9f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eae:	00 
  800eaf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb6:	00 
  800eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eba:	89 04 24             	mov    %eax,(%esp)
  800ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ec5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eca:	e8 ad fe ff ff       	call   800d7c <syscall>
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ed7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ede:	00 
  800edf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eee:	00 
  800eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef2:	89 04 24             	mov    %eax,(%esp)
  800ef5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef8:	ba 01 00 00 00       	mov    $0x1,%edx
  800efd:	b8 09 00 00 00       	mov    $0x9,%eax
  800f02:	e8 75 fe ff ff       	call   800d7c <syscall>
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f0f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f16:	00 
  800f17:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f26:	00 
  800f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2a:	89 04 24             	mov    %eax,(%esp)
  800f2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f30:	ba 01 00 00 00       	mov    $0x1,%edx
  800f35:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3a:	e8 3d fe ff ff       	call   800d7c <syscall>
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f47:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4e:	00 
  800f4f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f52:	0b 45 14             	or     0x14(%ebp),%eax
  800f55:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f59:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f63:	89 04 24             	mov    %eax,(%esp)
  800f66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f69:	ba 01 00 00 00       	mov    $0x1,%edx
  800f6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f73:	e8 04 fe ff ff       	call   800d7c <syscall>
}
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f80:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f87:	00 
  800f88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f8f:	00 
  800f90:	8b 45 10             	mov    0x10(%ebp),%eax
  800f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9a:	89 04 24             	mov    %eax,(%esp)
  800f9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa0:	ba 01 00 00 00       	mov    $0x1,%edx
  800fa5:	b8 05 00 00 00       	mov    $0x5,%eax
  800faa:	e8 cd fd ff ff       	call   800d7c <syscall>
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fb7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fce:	00 
  800fcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fe5:	e8 92 fd ff ff       	call   800d7c <syscall>
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800ff2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801001:	00 
  801002:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801009:	00 
  80100a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801013:	ba 00 00 00 00       	mov    $0x0,%edx
  801018:	b8 04 00 00 00       	mov    $0x4,%eax
  80101d:	e8 5a fd ff ff       	call   800d7c <syscall>
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80102a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104e:	ba 00 00 00 00       	mov    $0x0,%edx
  801053:	b8 02 00 00 00       	mov    $0x2,%eax
  801058:	e8 1f fd ff ff       	call   800d7c <syscall>
}
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801065:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80106c:	00 
  80106d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801074:	00 
  801075:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80107c:	00 
  80107d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801084:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801087:	ba 01 00 00 00       	mov    $0x1,%edx
  80108c:	b8 03 00 00 00       	mov    $0x3,%eax
  801091:	e8 e6 fc ff ff       	call   800d7c <syscall>
}
  801096:	c9                   	leave  
  801097:	c3                   	ret    

00801098 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80109e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a5:	00 
  8010a6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ad:	00 
  8010ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b5:	00 
  8010b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010cc:	e8 ab fc ff ff       	call   800d7c <syscall>
}
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010d9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f0:	00 
  8010f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f4:	89 04 24             	mov    %eax,(%esp)
  8010f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ff:	b8 00 00 00 00       	mov    $0x0,%eax
  801104:	e8 73 fc ff ff       	call   800d7c <syscall>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    
  80110b:	00 00                	add    %al,(%eax)
  80110d:	00 00                	add    %al,(%eax)
	...

00801110 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	8b 45 08             	mov    0x8(%ebp),%eax
  801116:	05 00 00 00 30       	add    $0x30000000,%eax
  80111b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    

00801120 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	89 04 24             	mov    %eax,(%esp)
  80112c:	e8 df ff ff ff       	call   801110 <fd2num>
  801131:	05 20 00 0d 00       	add    $0xd0020,%eax
  801136:	c1 e0 0c             	shl    $0xc,%eax
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	57                   	push   %edi
  80113f:	56                   	push   %esi
  801140:	53                   	push   %ebx
  801141:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801144:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801149:	a8 01                	test   $0x1,%al
  80114b:	74 36                	je     801183 <fd_alloc+0x48>
  80114d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801152:	a8 01                	test   $0x1,%al
  801154:	74 2d                	je     801183 <fd_alloc+0x48>
  801156:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80115b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801160:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801165:	89 c3                	mov    %eax,%ebx
  801167:	89 c2                	mov    %eax,%edx
  801169:	c1 ea 16             	shr    $0x16,%edx
  80116c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80116f:	f6 c2 01             	test   $0x1,%dl
  801172:	74 14                	je     801188 <fd_alloc+0x4d>
  801174:	89 c2                	mov    %eax,%edx
  801176:	c1 ea 0c             	shr    $0xc,%edx
  801179:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80117c:	f6 c2 01             	test   $0x1,%dl
  80117f:	75 10                	jne    801191 <fd_alloc+0x56>
  801181:	eb 05                	jmp    801188 <fd_alloc+0x4d>
  801183:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801188:	89 1f                	mov    %ebx,(%edi)
  80118a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80118f:	eb 17                	jmp    8011a8 <fd_alloc+0x6d>
  801191:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801196:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80119b:	75 c8                	jne    801165 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80119d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8011a3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8011a8:	5b                   	pop    %ebx
  8011a9:	5e                   	pop    %esi
  8011aa:	5f                   	pop    %edi
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b3:	83 f8 1f             	cmp    $0x1f,%eax
  8011b6:	77 36                	ja     8011ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011bd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 16             	shr    $0x16,%edx
  8011c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	74 1d                	je     8011ee <fd_lookup+0x41>
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	c1 ea 0c             	shr    $0xc,%edx
  8011d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011dd:	f6 c2 01             	test   $0x1,%dl
  8011e0:	74 0c                	je     8011ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e5:	89 02                	mov    %eax,(%edx)
  8011e7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8011ec:	eb 05                	jmp    8011f3 <fd_lookup+0x46>
  8011ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011f3:	5d                   	pop    %ebp
  8011f4:	c3                   	ret    

008011f5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801202:	8b 45 08             	mov    0x8(%ebp),%eax
  801205:	89 04 24             	mov    %eax,(%esp)
  801208:	e8 a0 ff ff ff       	call   8011ad <fd_lookup>
  80120d:	85 c0                	test   %eax,%eax
  80120f:	78 0e                	js     80121f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801211:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801214:	8b 55 0c             	mov    0xc(%ebp),%edx
  801217:	89 50 04             	mov    %edx,0x4(%eax)
  80121a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 10             	sub    $0x10,%esp
  801229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80122f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801234:	b8 74 47 80 00       	mov    $0x804774,%eax
  801239:	39 0d 74 47 80 00    	cmp    %ecx,0x804774
  80123f:	75 11                	jne    801252 <dev_lookup+0x31>
  801241:	eb 04                	jmp    801247 <dev_lookup+0x26>
  801243:	39 08                	cmp    %ecx,(%eax)
  801245:	75 10                	jne    801257 <dev_lookup+0x36>
			*dev = devtab[i];
  801247:	89 03                	mov    %eax,(%ebx)
  801249:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80124e:	66 90                	xchg   %ax,%ax
  801250:	eb 36                	jmp    801288 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801252:	be 28 23 80 00       	mov    $0x802328,%esi
  801257:	83 c2 01             	add    $0x1,%edx
  80125a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80125d:	85 c0                	test   %eax,%eax
  80125f:	75 e2                	jne    801243 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801261:	a1 90 67 80 00       	mov    0x806790,%eax
  801266:	8b 40 48             	mov    0x48(%eax),%eax
  801269:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80126d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801271:	c7 04 24 ac 22 80 00 	movl   $0x8022ac,(%esp)
  801278:	e8 d0 ef ff ff       	call   80024d <cprintf>
	*dev = 0;
  80127d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801283:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	5b                   	pop    %ebx
  80128c:	5e                   	pop    %esi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	53                   	push   %ebx
  801293:	83 ec 24             	sub    $0x24,%esp
  801296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801299:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a3:	89 04 24             	mov    %eax,(%esp)
  8012a6:	e8 02 ff ff ff       	call   8011ad <fd_lookup>
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 53                	js     801302 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	8b 00                	mov    (%eax),%eax
  8012bb:	89 04 24             	mov    %eax,(%esp)
  8012be:	e8 5e ff ff ff       	call   801221 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 3b                	js     801302 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8012c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012cf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8012d3:	74 2d                	je     801302 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012df:	00 00 00 
	stat->st_isdir = 0;
  8012e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012e9:	00 00 00 
	stat->st_dev = dev;
  8012ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012fc:	89 14 24             	mov    %edx,(%esp)
  8012ff:	ff 50 14             	call   *0x14(%eax)
}
  801302:	83 c4 24             	add    $0x24,%esp
  801305:	5b                   	pop    %ebx
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	83 ec 24             	sub    $0x24,%esp
  80130f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801312:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	89 1c 24             	mov    %ebx,(%esp)
  80131c:	e8 8c fe ff ff       	call   8011ad <fd_lookup>
  801321:	85 c0                	test   %eax,%eax
  801323:	78 5f                	js     801384 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132f:	8b 00                	mov    (%eax),%eax
  801331:	89 04 24             	mov    %eax,(%esp)
  801334:	e8 e8 fe ff ff       	call   801221 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 47                	js     801384 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80133d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801340:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801344:	75 23                	jne    801369 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801346:	a1 90 67 80 00       	mov    0x806790,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80134b:	8b 40 48             	mov    0x48(%eax),%eax
  80134e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	c7 04 24 cc 22 80 00 	movl   $0x8022cc,(%esp)
  80135d:	e8 eb ee ff ff       	call   80024d <cprintf>
  801362:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801367:	eb 1b                	jmp    801384 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801369:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136c:	8b 48 18             	mov    0x18(%eax),%ecx
  80136f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801374:	85 c9                	test   %ecx,%ecx
  801376:	74 0c                	je     801384 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801378:	8b 45 0c             	mov    0xc(%ebp),%eax
  80137b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137f:	89 14 24             	mov    %edx,(%esp)
  801382:	ff d1                	call   *%ecx
}
  801384:	83 c4 24             	add    $0x24,%esp
  801387:	5b                   	pop    %ebx
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	53                   	push   %ebx
  80138e:	83 ec 24             	sub    $0x24,%esp
  801391:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801394:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801397:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139b:	89 1c 24             	mov    %ebx,(%esp)
  80139e:	e8 0a fe ff ff       	call   8011ad <fd_lookup>
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 66                	js     80140d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b1:	8b 00                	mov    (%eax),%eax
  8013b3:	89 04 24             	mov    %eax,(%esp)
  8013b6:	e8 66 fe ff ff       	call   801221 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 4e                	js     80140d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013c2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8013c6:	75 23                	jne    8013eb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c8:	a1 90 67 80 00       	mov    0x806790,%eax
  8013cd:	8b 40 48             	mov    0x48(%eax),%eax
  8013d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d8:	c7 04 24 ed 22 80 00 	movl   $0x8022ed,(%esp)
  8013df:	e8 69 ee ff ff       	call   80024d <cprintf>
  8013e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013e9:	eb 22                	jmp    80140d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ee:	8b 48 0c             	mov    0xc(%eax),%ecx
  8013f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013f6:	85 c9                	test   %ecx,%ecx
  8013f8:	74 13                	je     80140d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8013fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801401:	8b 45 0c             	mov    0xc(%ebp),%eax
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	89 14 24             	mov    %edx,(%esp)
  80140b:	ff d1                	call   *%ecx
}
  80140d:	83 c4 24             	add    $0x24,%esp
  801410:	5b                   	pop    %ebx
  801411:	5d                   	pop    %ebp
  801412:	c3                   	ret    

00801413 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801413:	55                   	push   %ebp
  801414:	89 e5                	mov    %esp,%ebp
  801416:	53                   	push   %ebx
  801417:	83 ec 24             	sub    $0x24,%esp
  80141a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801420:	89 44 24 04          	mov    %eax,0x4(%esp)
  801424:	89 1c 24             	mov    %ebx,(%esp)
  801427:	e8 81 fd ff ff       	call   8011ad <fd_lookup>
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 6b                	js     80149b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801433:	89 44 24 04          	mov    %eax,0x4(%esp)
  801437:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143a:	8b 00                	mov    (%eax),%eax
  80143c:	89 04 24             	mov    %eax,(%esp)
  80143f:	e8 dd fd ff ff       	call   801221 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801444:	85 c0                	test   %eax,%eax
  801446:	78 53                	js     80149b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801448:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144b:	8b 42 08             	mov    0x8(%edx),%eax
  80144e:	83 e0 03             	and    $0x3,%eax
  801451:	83 f8 01             	cmp    $0x1,%eax
  801454:	75 23                	jne    801479 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801456:	a1 90 67 80 00       	mov    0x806790,%eax
  80145b:	8b 40 48             	mov    0x48(%eax),%eax
  80145e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801462:	89 44 24 04          	mov    %eax,0x4(%esp)
  801466:	c7 04 24 0a 23 80 00 	movl   $0x80230a,(%esp)
  80146d:	e8 db ed ff ff       	call   80024d <cprintf>
  801472:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801477:	eb 22                	jmp    80149b <read+0x88>
	}
	if (!dev->dev_read)
  801479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147c:	8b 48 08             	mov    0x8(%eax),%ecx
  80147f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801484:	85 c9                	test   %ecx,%ecx
  801486:	74 13                	je     80149b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801488:	8b 45 10             	mov    0x10(%ebp),%eax
  80148b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80148f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801492:	89 44 24 04          	mov    %eax,0x4(%esp)
  801496:	89 14 24             	mov    %edx,(%esp)
  801499:	ff d1                	call   *%ecx
}
  80149b:	83 c4 24             	add    $0x24,%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5d                   	pop    %ebp
  8014a0:	c3                   	ret    

008014a1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	57                   	push   %edi
  8014a5:	56                   	push   %esi
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 1c             	sub    $0x1c,%esp
  8014aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8014bf:	85 f6                	test   %esi,%esi
  8014c1:	74 29                	je     8014ec <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c3:	89 f0                	mov    %esi,%eax
  8014c5:	29 d0                	sub    %edx,%eax
  8014c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014cb:	03 55 0c             	add    0xc(%ebp),%edx
  8014ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014d2:	89 3c 24             	mov    %edi,(%esp)
  8014d5:	e8 39 ff ff ff       	call   801413 <read>
		if (m < 0)
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	78 0e                	js     8014ec <readn+0x4b>
			return m;
		if (m == 0)
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	74 08                	je     8014ea <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e2:	01 c3                	add    %eax,%ebx
  8014e4:	89 da                	mov    %ebx,%edx
  8014e6:	39 f3                	cmp    %esi,%ebx
  8014e8:	72 d9                	jb     8014c3 <readn+0x22>
  8014ea:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ec:	83 c4 1c             	add    $0x1c,%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5f                   	pop    %edi
  8014f2:	5d                   	pop    %ebp
  8014f3:	c3                   	ret    

008014f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 28             	sub    $0x28,%esp
  8014fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801500:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801503:	89 34 24             	mov    %esi,(%esp)
  801506:	e8 05 fc ff ff       	call   801110 <fd2num>
  80150b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80150e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801512:	89 04 24             	mov    %eax,(%esp)
  801515:	e8 93 fc ff ff       	call   8011ad <fd_lookup>
  80151a:	89 c3                	mov    %eax,%ebx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 05                	js     801525 <fd_close+0x31>
  801520:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801523:	74 0e                	je     801533 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801525:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801529:	b8 00 00 00 00       	mov    $0x0,%eax
  80152e:	0f 44 d8             	cmove  %eax,%ebx
  801531:	eb 3d                	jmp    801570 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801533:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801536:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153a:	8b 06                	mov    (%esi),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 dd fc ff ff       	call   801221 <dev_lookup>
  801544:	89 c3                	mov    %eax,%ebx
  801546:	85 c0                	test   %eax,%eax
  801548:	78 16                	js     801560 <fd_close+0x6c>
		if (dev->dev_close)
  80154a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154d:	8b 40 10             	mov    0x10(%eax),%eax
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
  801555:	85 c0                	test   %eax,%eax
  801557:	74 07                	je     801560 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801559:	89 34 24             	mov    %esi,(%esp)
  80155c:	ff d0                	call   *%eax
  80155e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801560:	89 74 24 04          	mov    %esi,0x4(%esp)
  801564:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156b:	e8 99 f9 ff ff       	call   800f09 <sys_page_unmap>
	return r;
}
  801570:	89 d8                	mov    %ebx,%eax
  801572:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801575:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801578:	89 ec                	mov    %ebp,%esp
  80157a:	5d                   	pop    %ebp
  80157b:	c3                   	ret    

0080157c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801582:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801585:	89 44 24 04          	mov    %eax,0x4(%esp)
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	e8 19 fc ff ff       	call   8011ad <fd_lookup>
  801594:	85 c0                	test   %eax,%eax
  801596:	78 13                	js     8015ab <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801598:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80159f:	00 
  8015a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a3:	89 04 24             	mov    %eax,(%esp)
  8015a6:	e8 49 ff ff ff       	call   8014f4 <fd_close>
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	83 ec 18             	sub    $0x18,%esp
  8015b3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015b6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015c0:	00 
  8015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c4:	89 04 24             	mov    %eax,(%esp)
  8015c7:	e8 78 03 00 00       	call   801944 <open>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 1b                	js     8015ed <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8015d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d9:	89 1c 24             	mov    %ebx,(%esp)
  8015dc:	e8 ae fc ff ff       	call   80128f <fstat>
  8015e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8015e3:	89 1c 24             	mov    %ebx,(%esp)
  8015e6:	e8 91 ff ff ff       	call   80157c <close>
  8015eb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8015ed:	89 d8                	mov    %ebx,%eax
  8015ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015f5:	89 ec                	mov    %ebp,%esp
  8015f7:	5d                   	pop    %ebp
  8015f8:	c3                   	ret    

008015f9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	53                   	push   %ebx
  8015fd:	83 ec 14             	sub    $0x14,%esp
  801600:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801605:	89 1c 24             	mov    %ebx,(%esp)
  801608:	e8 6f ff ff ff       	call   80157c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80160d:	83 c3 01             	add    $0x1,%ebx
  801610:	83 fb 20             	cmp    $0x20,%ebx
  801613:	75 f0                	jne    801605 <close_all+0xc>
		close(i);
}
  801615:	83 c4 14             	add    $0x14,%esp
  801618:	5b                   	pop    %ebx
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 58             	sub    $0x58,%esp
  801621:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801624:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801627:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80162a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80162d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	8b 45 08             	mov    0x8(%ebp),%eax
  801637:	89 04 24             	mov    %eax,(%esp)
  80163a:	e8 6e fb ff ff       	call   8011ad <fd_lookup>
  80163f:	89 c3                	mov    %eax,%ebx
  801641:	85 c0                	test   %eax,%eax
  801643:	0f 88 e0 00 00 00    	js     801729 <dup+0x10e>
		return r;
	close(newfdnum);
  801649:	89 3c 24             	mov    %edi,(%esp)
  80164c:	e8 2b ff ff ff       	call   80157c <close>

	newfd = INDEX2FD(newfdnum);
  801651:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801657:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80165a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80165d:	89 04 24             	mov    %eax,(%esp)
  801660:	e8 bb fa ff ff       	call   801120 <fd2data>
  801665:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801667:	89 34 24             	mov    %esi,(%esp)
  80166a:	e8 b1 fa ff ff       	call   801120 <fd2data>
  80166f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801672:	89 da                	mov    %ebx,%edx
  801674:	89 d8                	mov    %ebx,%eax
  801676:	c1 e8 16             	shr    $0x16,%eax
  801679:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801680:	a8 01                	test   $0x1,%al
  801682:	74 43                	je     8016c7 <dup+0xac>
  801684:	c1 ea 0c             	shr    $0xc,%edx
  801687:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80168e:	a8 01                	test   $0x1,%al
  801690:	74 35                	je     8016c7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801692:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801699:	25 07 0e 00 00       	and    $0xe07,%eax
  80169e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016b0:	00 
  8016b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bc:	e8 80 f8 ff ff       	call   800f41 <sys_page_map>
  8016c1:	89 c3                	mov    %eax,%ebx
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 3f                	js     801706 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ca:	89 c2                	mov    %eax,%edx
  8016cc:	c1 ea 0c             	shr    $0xc,%edx
  8016cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016d6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016eb:	00 
  8016ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f7:	e8 45 f8 ff ff       	call   800f41 <sys_page_map>
  8016fc:	89 c3                	mov    %eax,%ebx
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 04                	js     801706 <dup+0xeb>
  801702:	89 fb                	mov    %edi,%ebx
  801704:	eb 23                	jmp    801729 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801706:	89 74 24 04          	mov    %esi,0x4(%esp)
  80170a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801711:	e8 f3 f7 ff ff       	call   800f09 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801716:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801719:	89 44 24 04          	mov    %eax,0x4(%esp)
  80171d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801724:	e8 e0 f7 ff ff       	call   800f09 <sys_page_unmap>
	return r;
}
  801729:	89 d8                	mov    %ebx,%eax
  80172b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80172e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801731:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801734:	89 ec                	mov    %ebp,%esp
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    

00801738 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801738:	55                   	push   %ebp
  801739:	89 e5                	mov    %esp,%ebp
  80173b:	83 ec 18             	sub    $0x18,%esp
  80173e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801741:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801744:	89 c3                	mov    %eax,%ebx
  801746:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801748:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80174f:	75 11                	jne    801762 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801751:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801758:	e8 03 03 00 00       	call   801a60 <ipc_find_env>
  80175d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801762:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801769:	00 
  80176a:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801771:	00 
  801772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801776:	a1 00 50 80 00       	mov    0x805000,%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 21 03 00 00       	call   801aa4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801783:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178a:	00 
  80178b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80178f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801796:	e8 78 03 00 00       	call   801b13 <ipc_recv>
}
  80179b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80179e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017a1:	89 ec                	mov    %ebp,%esp
  8017a3:	5d                   	pop    %ebp
  8017a4:	c3                   	ret    

008017a5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017a5:	55                   	push   %ebp
  8017a6:	89 e5                	mov    %esp,%ebp
  8017a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b1:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8017b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b9:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017be:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017c8:	e8 6b ff ff ff       	call   801738 <fsipc>
}
  8017cd:	c9                   	leave  
  8017ce:	c3                   	ret    

008017cf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017cf:	55                   	push   %ebp
  8017d0:	89 e5                	mov    %esp,%ebp
  8017d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017db:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ea:	e8 49 ff ff ff       	call   801738 <fsipc>
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801801:	e8 32 ff ff ff       	call   801738 <fsipc>
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	53                   	push   %ebx
  80180c:	83 ec 14             	sub    $0x14,%esp
  80180f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	8b 40 0c             	mov    0xc(%eax),%eax
  801818:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 05 00 00 00       	mov    $0x5,%eax
  801827:	e8 0c ff ff ff       	call   801738 <fsipc>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 2b                	js     80185b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801830:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  801837:	00 
  801838:	89 1c 24             	mov    %ebx,(%esp)
  80183b:	e8 4a f1 ff ff       	call   80098a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801840:	a1 80 70 80 00       	mov    0x807080,%eax
  801845:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80184b:	a1 84 70 80 00       	mov    0x807084,%eax
  801850:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801856:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80185b:	83 c4 14             	add    $0x14,%esp
  80185e:	5b                   	pop    %ebx
  80185f:	5d                   	pop    %ebp
  801860:	c3                   	ret    

00801861 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	83 ec 18             	sub    $0x18,%esp
  801867:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80186a:	8b 55 08             	mov    0x8(%ebp),%edx
  80186d:	8b 52 0c             	mov    0xc(%edx),%edx
  801870:	89 15 00 70 80 00    	mov    %edx,0x807000
  fsipcbuf.write.req_n = n;
  801876:	a3 04 70 80 00       	mov    %eax,0x807004
  memmove(fsipcbuf.write.req_buf, buf,
  80187b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801880:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801885:	0f 47 c2             	cmova  %edx,%eax
  801888:	89 44 24 08          	mov    %eax,0x8(%esp)
  80188c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80188f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801893:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  80189a:	e8 d6 f2 ff ff       	call   800b75 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a9:	e8 8a fe ff ff       	call   801738 <fsipc>
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	53                   	push   %ebx
  8018b4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bd:	a3 00 70 80 00       	mov    %eax,0x807000
  fsipcbuf.read.req_n = n;
  8018c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018c5:	a3 04 70 80 00       	mov    %eax,0x807004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8018d4:	e8 5f fe ff ff       	call   801738 <fsipc>
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 17                	js     8018f6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018e3:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8018ea:	00 
  8018eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ee:	89 04 24             	mov    %eax,(%esp)
  8018f1:	e8 7f f2 ff ff       	call   800b75 <memmove>
  return r;	
}
  8018f6:	89 d8                	mov    %ebx,%eax
  8018f8:	83 c4 14             	add    $0x14,%esp
  8018fb:	5b                   	pop    %ebx
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	53                   	push   %ebx
  801902:	83 ec 14             	sub    $0x14,%esp
  801905:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801908:	89 1c 24             	mov    %ebx,(%esp)
  80190b:	e8 30 f0 ff ff       	call   800940 <strlen>
  801910:	89 c2                	mov    %eax,%edx
  801912:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801917:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80191d:	7f 1f                	jg     80193e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80191f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801923:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  80192a:	e8 5b f0 ff ff       	call   80098a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80192f:	ba 00 00 00 00       	mov    $0x0,%edx
  801934:	b8 07 00 00 00       	mov    $0x7,%eax
  801939:	e8 fa fd ff ff       	call   801738 <fsipc>
}
  80193e:	83 c4 14             	add    $0x14,%esp
  801941:	5b                   	pop    %ebx
  801942:	5d                   	pop    %ebp
  801943:	c3                   	ret    

00801944 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	83 ec 28             	sub    $0x28,%esp
  80194a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80194d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801950:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801953:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801956:	89 04 24             	mov    %eax,(%esp)
  801959:	e8 dd f7 ff ff       	call   80113b <fd_alloc>
  80195e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801960:	85 c0                	test   %eax,%eax
  801962:	0f 88 89 00 00 00    	js     8019f1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801968:	89 34 24             	mov    %esi,(%esp)
  80196b:	e8 d0 ef ff ff       	call   800940 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801970:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801975:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80197a:	7f 75                	jg     8019f1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80197c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801980:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  801987:	e8 fe ef ff ff       	call   80098a <strcpy>
  fsipcbuf.open.req_omode = mode;
  80198c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198f:	a3 00 74 80 00       	mov    %eax,0x807400
  r = fsipc(FSREQ_OPEN, fd);
  801994:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801997:	b8 01 00 00 00       	mov    $0x1,%eax
  80199c:	e8 97 fd ff ff       	call   801738 <fsipc>
  8019a1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	78 0f                	js     8019b6 <open+0x72>
  return fd2num(fd);
  8019a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019aa:	89 04 24             	mov    %eax,(%esp)
  8019ad:	e8 5e f7 ff ff       	call   801110 <fd2num>
  8019b2:	89 c3                	mov    %eax,%ebx
  8019b4:	eb 3b                	jmp    8019f1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8019b6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019bd:	00 
  8019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c1:	89 04 24             	mov    %eax,(%esp)
  8019c4:	e8 2b fb ff ff       	call   8014f4 <fd_close>
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	74 24                	je     8019f1 <open+0xad>
  8019cd:	c7 44 24 0c 30 23 80 	movl   $0x802330,0xc(%esp)
  8019d4:	00 
  8019d5:	c7 44 24 08 45 23 80 	movl   $0x802345,0x8(%esp)
  8019dc:	00 
  8019dd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8019e4:	00 
  8019e5:	c7 04 24 5a 23 80 00 	movl   $0x80235a,(%esp)
  8019ec:	e8 0f 00 00 00       	call   801a00 <_panic>
  return r;
}
  8019f1:	89 d8                	mov    %ebx,%eax
  8019f3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019f6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019f9:	89 ec                	mov    %ebp,%esp
  8019fb:	5d                   	pop    %ebp
  8019fc:	c3                   	ret    
  8019fd:	00 00                	add    %al,(%eax)
	...

00801a00 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
  801a05:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801a08:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a0b:	8b 1d 70 47 80 00    	mov    0x804770,%ebx
  801a11:	e8 0e f6 ff ff       	call   801024 <sys_getenvid>
  801a16:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a19:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a1d:	8b 55 08             	mov    0x8(%ebp),%edx
  801a20:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a24:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2c:	c7 04 24 68 23 80 00 	movl   $0x802368,(%esp)
  801a33:	e8 15 e8 ff ff       	call   80024d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a38:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a3c:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3f:	89 04 24             	mov    %eax,(%esp)
  801a42:	e8 a5 e7 ff ff       	call   8001ec <vcprintf>
	cprintf("\n");
  801a47:	c7 04 24 24 23 80 00 	movl   $0x802324,(%esp)
  801a4e:	e8 fa e7 ff ff       	call   80024d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a53:	cc                   	int3   
  801a54:	eb fd                	jmp    801a53 <_panic+0x53>
	...

00801a60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a66:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801a6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a71:	39 ca                	cmp    %ecx,%edx
  801a73:	75 04                	jne    801a79 <ipc_find_env+0x19>
  801a75:	b0 00                	mov    $0x0,%al
  801a77:	eb 0f                	jmp    801a88 <ipc_find_env+0x28>
  801a79:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a7c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801a82:	8b 12                	mov    (%edx),%edx
  801a84:	39 ca                	cmp    %ecx,%edx
  801a86:	75 0c                	jne    801a94 <ipc_find_env+0x34>
			return envs[i].env_id;
  801a88:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a8b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801a90:	8b 00                	mov    (%eax),%eax
  801a92:	eb 0e                	jmp    801aa2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a94:	83 c0 01             	add    $0x1,%eax
  801a97:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a9c:	75 db                	jne    801a79 <ipc_find_env+0x19>
  801a9e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 1c             	sub    $0x1c,%esp
  801aad:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ab3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801abd:	0f 44 d8             	cmove  %eax,%ebx
  801ac0:	eb 29                	jmp    801aeb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	79 25                	jns    801aeb <ipc_send+0x47>
  801ac6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac9:	74 20                	je     801aeb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801acb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801acf:	c7 44 24 08 8c 23 80 	movl   $0x80238c,0x8(%esp)
  801ad6:	00 
  801ad7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801ade:	00 
  801adf:	c7 04 24 aa 23 80 00 	movl   $0x8023aa,(%esp)
  801ae6:	e8 15 ff ff ff       	call   801a00 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801aeb:	8b 45 14             	mov    0x14(%ebp),%eax
  801aee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801af2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801af6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801afa:	89 34 24             	mov    %esi,(%esp)
  801afd:	e8 29 f3 ff ff       	call   800e2b <sys_ipc_try_send>
  801b02:	85 c0                	test   %eax,%eax
  801b04:	75 bc                	jne    801ac2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801b06:	e8 a6 f4 ff ff       	call   800fb1 <sys_yield>
}
  801b0b:	83 c4 1c             	add    $0x1c,%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5f                   	pop    %edi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 28             	sub    $0x28,%esp
  801b19:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b1c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b1f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b22:	8b 75 08             	mov    0x8(%ebp),%esi
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b28:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b32:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801b35:	89 04 24             	mov    %eax,(%esp)
  801b38:	e8 b5 f2 ff ff       	call   800df2 <sys_ipc_recv>
  801b3d:	89 c3                	mov    %eax,%ebx
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	79 2a                	jns    801b6d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801b43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	c7 04 24 b4 23 80 00 	movl   $0x8023b4,(%esp)
  801b52:	e8 f6 e6 ff ff       	call   80024d <cprintf>
		if(from_env_store != NULL)
  801b57:	85 f6                	test   %esi,%esi
  801b59:	74 06                	je     801b61 <ipc_recv+0x4e>
			*from_env_store = 0;
  801b5b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b61:	85 ff                	test   %edi,%edi
  801b63:	74 2d                	je     801b92 <ipc_recv+0x7f>
			*perm_store = 0;
  801b65:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b6b:	eb 25                	jmp    801b92 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801b6d:	85 f6                	test   %esi,%esi
  801b6f:	90                   	nop
  801b70:	74 0a                	je     801b7c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801b72:	a1 90 67 80 00       	mov    0x806790,%eax
  801b77:	8b 40 74             	mov    0x74(%eax),%eax
  801b7a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b7c:	85 ff                	test   %edi,%edi
  801b7e:	74 0a                	je     801b8a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801b80:	a1 90 67 80 00       	mov    0x806790,%eax
  801b85:	8b 40 78             	mov    0x78(%eax),%eax
  801b88:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b8a:	a1 90 67 80 00       	mov    0x806790,%eax
  801b8f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801b92:	89 d8                	mov    %ebx,%eax
  801b94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b9d:	89 ec                	mov    %ebp,%esp
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
	...

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	83 ec 10             	sub    $0x10,%esp
  801bb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  801bbe:	8b 75 10             	mov    0x10(%ebp),%esi
  801bc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801bc9:	75 35                	jne    801c00 <__udivdi3+0x50>
  801bcb:	39 fe                	cmp    %edi,%esi
  801bcd:	77 61                	ja     801c30 <__udivdi3+0x80>
  801bcf:	85 f6                	test   %esi,%esi
  801bd1:	75 0b                	jne    801bde <__udivdi3+0x2e>
  801bd3:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd8:	31 d2                	xor    %edx,%edx
  801bda:	f7 f6                	div    %esi
  801bdc:	89 c6                	mov    %eax,%esi
  801bde:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801be1:	31 d2                	xor    %edx,%edx
  801be3:	89 f8                	mov    %edi,%eax
  801be5:	f7 f6                	div    %esi
  801be7:	89 c7                	mov    %eax,%edi
  801be9:	89 c8                	mov    %ecx,%eax
  801beb:	f7 f6                	div    %esi
  801bed:	89 c1                	mov    %eax,%ecx
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	89 c8                	mov    %ecx,%eax
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
  801bfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c00:	39 f8                	cmp    %edi,%eax
  801c02:	77 1c                	ja     801c20 <__udivdi3+0x70>
  801c04:	0f bd d0             	bsr    %eax,%edx
  801c07:	83 f2 1f             	xor    $0x1f,%edx
  801c0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c0d:	75 39                	jne    801c48 <__udivdi3+0x98>
  801c0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801c12:	0f 86 a0 00 00 00    	jbe    801cb8 <__udivdi3+0x108>
  801c18:	39 f8                	cmp    %edi,%eax
  801c1a:	0f 82 98 00 00 00    	jb     801cb8 <__udivdi3+0x108>
  801c20:	31 ff                	xor    %edi,%edi
  801c22:	31 c9                	xor    %ecx,%ecx
  801c24:	89 c8                	mov    %ecx,%eax
  801c26:	89 fa                	mov    %edi,%edx
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	5e                   	pop    %esi
  801c2c:	5f                   	pop    %edi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    
  801c2f:	90                   	nop
  801c30:	89 d1                	mov    %edx,%ecx
  801c32:	89 fa                	mov    %edi,%edx
  801c34:	89 c8                	mov    %ecx,%eax
  801c36:	31 ff                	xor    %edi,%edi
  801c38:	f7 f6                	div    %esi
  801c3a:	89 c1                	mov    %eax,%ecx
  801c3c:	89 fa                	mov    %edi,%edx
  801c3e:	89 c8                	mov    %ecx,%eax
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    
  801c47:	90                   	nop
  801c48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c4c:	89 f2                	mov    %esi,%edx
  801c4e:	d3 e0                	shl    %cl,%eax
  801c50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c53:	b8 20 00 00 00       	mov    $0x20,%eax
  801c58:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801c5b:	89 c1                	mov    %eax,%ecx
  801c5d:	d3 ea                	shr    %cl,%edx
  801c5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c63:	0b 55 ec             	or     -0x14(%ebp),%edx
  801c66:	d3 e6                	shl    %cl,%esi
  801c68:	89 c1                	mov    %eax,%ecx
  801c6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801c6d:	89 fe                	mov    %edi,%esi
  801c6f:	d3 ee                	shr    %cl,%esi
  801c71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c75:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7b:	d3 e7                	shl    %cl,%edi
  801c7d:	89 c1                	mov    %eax,%ecx
  801c7f:	d3 ea                	shr    %cl,%edx
  801c81:	09 d7                	or     %edx,%edi
  801c83:	89 f2                	mov    %esi,%edx
  801c85:	89 f8                	mov    %edi,%eax
  801c87:	f7 75 ec             	divl   -0x14(%ebp)
  801c8a:	89 d6                	mov    %edx,%esi
  801c8c:	89 c7                	mov    %eax,%edi
  801c8e:	f7 65 e8             	mull   -0x18(%ebp)
  801c91:	39 d6                	cmp    %edx,%esi
  801c93:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c96:	72 30                	jb     801cc8 <__udivdi3+0x118>
  801c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c9f:	d3 e2                	shl    %cl,%edx
  801ca1:	39 c2                	cmp    %eax,%edx
  801ca3:	73 05                	jae    801caa <__udivdi3+0xfa>
  801ca5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801ca8:	74 1e                	je     801cc8 <__udivdi3+0x118>
  801caa:	89 f9                	mov    %edi,%ecx
  801cac:	31 ff                	xor    %edi,%edi
  801cae:	e9 71 ff ff ff       	jmp    801c24 <__udivdi3+0x74>
  801cb3:	90                   	nop
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	b9 01 00 00 00       	mov    $0x1,%ecx
  801cbf:	e9 60 ff ff ff       	jmp    801c24 <__udivdi3+0x74>
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801ccb:	31 ff                	xor    %edi,%edi
  801ccd:	89 c8                	mov    %ecx,%eax
  801ccf:	89 fa                	mov    %edi,%edx
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
	...

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	83 ec 20             	sub    $0x20,%esp
  801ce8:	8b 55 14             	mov    0x14(%ebp),%edx
  801ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cee:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf4:	85 d2                	test   %edx,%edx
  801cf6:	89 c8                	mov    %ecx,%eax
  801cf8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cfb:	75 13                	jne    801d10 <__umoddi3+0x30>
  801cfd:	39 f7                	cmp    %esi,%edi
  801cff:	76 3f                	jbe    801d40 <__umoddi3+0x60>
  801d01:	89 f2                	mov    %esi,%edx
  801d03:	f7 f7                	div    %edi
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	31 d2                	xor    %edx,%edx
  801d09:	83 c4 20             	add    $0x20,%esp
  801d0c:	5e                   	pop    %esi
  801d0d:	5f                   	pop    %edi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    
  801d10:	39 f2                	cmp    %esi,%edx
  801d12:	77 4c                	ja     801d60 <__umoddi3+0x80>
  801d14:	0f bd ca             	bsr    %edx,%ecx
  801d17:	83 f1 1f             	xor    $0x1f,%ecx
  801d1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d1d:	75 51                	jne    801d70 <__umoddi3+0x90>
  801d1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801d22:	0f 87 e0 00 00 00    	ja     801e08 <__umoddi3+0x128>
  801d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2b:	29 f8                	sub    %edi,%eax
  801d2d:	19 d6                	sbb    %edx,%esi
  801d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	89 f2                	mov    %esi,%edx
  801d37:	83 c4 20             	add    $0x20,%esp
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    
  801d3e:	66 90                	xchg   %ax,%ax
  801d40:	85 ff                	test   %edi,%edi
  801d42:	75 0b                	jne    801d4f <__umoddi3+0x6f>
  801d44:	b8 01 00 00 00       	mov    $0x1,%eax
  801d49:	31 d2                	xor    %edx,%edx
  801d4b:	f7 f7                	div    %edi
  801d4d:	89 c7                	mov    %eax,%edi
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	31 d2                	xor    %edx,%edx
  801d53:	f7 f7                	div    %edi
  801d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d58:	f7 f7                	div    %edi
  801d5a:	eb a9                	jmp    801d05 <__umoddi3+0x25>
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    
  801d6b:	90                   	nop
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d74:	d3 e2                	shl    %cl,%edx
  801d76:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d79:	ba 20 00 00 00       	mov    $0x20,%edx
  801d7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801d81:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d88:	89 fa                	mov    %edi,%edx
  801d8a:	d3 ea                	shr    %cl,%edx
  801d8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d90:	0b 55 f4             	or     -0xc(%ebp),%edx
  801d93:	d3 e7                	shl    %cl,%edi
  801d95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d99:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d9c:	89 f2                	mov    %esi,%edx
  801d9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801da1:	89 c7                	mov    %eax,%edi
  801da3:	d3 ea                	shr    %cl,%edx
  801da5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801da9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801dac:	89 c2                	mov    %eax,%edx
  801dae:	d3 e6                	shl    %cl,%esi
  801db0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801db4:	d3 ea                	shr    %cl,%edx
  801db6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801dba:	09 d6                	or     %edx,%esi
  801dbc:	89 f0                	mov    %esi,%eax
  801dbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801dc1:	d3 e7                	shl    %cl,%edi
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	f7 75 f4             	divl   -0xc(%ebp)
  801dc8:	89 d6                	mov    %edx,%esi
  801dca:	f7 65 e8             	mull   -0x18(%ebp)
  801dcd:	39 d6                	cmp    %edx,%esi
  801dcf:	72 2b                	jb     801dfc <__umoddi3+0x11c>
  801dd1:	39 c7                	cmp    %eax,%edi
  801dd3:	72 23                	jb     801df8 <__umoddi3+0x118>
  801dd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801dd9:	29 c7                	sub    %eax,%edi
  801ddb:	19 d6                	sbb    %edx,%esi
  801ddd:	89 f0                	mov    %esi,%eax
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	d3 ef                	shr    %cl,%edi
  801de3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ded:	09 f8                	or     %edi,%eax
  801def:	d3 ea                	shr    %cl,%edx
  801df1:	83 c4 20             	add    $0x20,%esp
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    
  801df8:	39 d6                	cmp    %edx,%esi
  801dfa:	75 d9                	jne    801dd5 <__umoddi3+0xf5>
  801dfc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801dff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801e02:	eb d1                	jmp    801dd5 <__umoddi3+0xf5>
  801e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	0f 82 18 ff ff ff    	jb     801d28 <__umoddi3+0x48>
  801e10:	e9 1d ff ff ff       	jmp    801d32 <__umoddi3+0x52>
