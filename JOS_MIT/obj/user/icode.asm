
obj/user/icode.debug:     file format elf32-i386


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
  80002c:	e8 2b 01 00 00       	call   80015c <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	81 ec 30 02 00 00    	sub    $0x230,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  80003f:	c7 05 00 40 80 00 a0 	movl   $0x8029a0,0x804000
  800046:	29 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 a6 29 80 00 	movl   $0x8029a6,(%esp)
  800050:	e8 2c 02 00 00       	call   800281 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 b5 29 80 00 	movl   $0x8029b5,(%esp)
  80005c:	e8 20 02 00 00       	call   800281 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 c8 29 80 00 	movl   $0x8029c8,(%esp)
  800070:	e8 6f 19 00 00       	call   8019e4 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 ce 29 80 	movl   $0x8029ce,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 e4 29 80 00 	movl   $0x8029e4,(%esp)
  800096:	e8 2d 01 00 00       	call   8001c8 <_panic>

	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 f1 29 80 00 	movl   $0x8029f1,(%esp)
  8000a2:	e8 da 01 00 00       	call   800281 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 bb 10 00 00       	call   801176 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0)
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 e4 13 00 00       	call   8014b3 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 04 2a 80 00 	movl   $0x802a04,(%esp)
  8000da:	e8 a2 01 00 00       	call   800281 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 35 15 00 00       	call   80161c <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 18 2a 80 00 	movl   $0x802a18,(%esp)
  8000ee:	e8 8e 01 00 00       	call   800281 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 2c 2a 80 	movl   $0x802a2c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 35 2a 80 	movl   $0x802a35,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 3f 2a 80 	movl   $0x802a3f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 3e 2a 80 00 	movl   $0x802a3e,(%esp)
  80011a:	e8 f0 1e 00 00       	call   80200f <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 44 2a 80 	movl   $0x802a44,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 e4 29 80 00 	movl   $0x8029e4,(%esp)
  80013e:	e8 85 00 00 00       	call   8001c8 <_panic>

	cprintf("icode: exiting\n");
  800143:	c7 04 24 5b 2a 80 00 	movl   $0x802a5b,(%esp)
  80014a:	e8 32 01 00 00       	call   800281 <cprintf>
}
  80014f:	81 c4 30 02 00 00    	add    $0x230,%esp
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    
  800159:	00 00                	add    %al,(%eax)
	...

0080015c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80015c:	55                   	push   %ebp
  80015d:	89 e5                	mov    %esp,%ebp
  80015f:	83 ec 18             	sub    $0x18,%esp
  800162:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800165:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800168:	8b 75 08             	mov    0x8(%ebp),%esi
  80016b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80016e:	e8 54 0f 00 00       	call   8010c7 <sys_getenvid>
  800173:	25 ff 03 00 00       	and    $0x3ff,%eax
  800178:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80017b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800180:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800185:	85 f6                	test   %esi,%esi
  800187:	7e 07                	jle    800190 <libmain+0x34>
		binaryname = argv[0];
  800189:	8b 03                	mov    (%ebx),%eax
  80018b:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800190:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800194:	89 34 24             	mov    %esi,(%esp)
  800197:	e8 98 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80019c:	e8 0b 00 00 00       	call   8001ac <exit>
}
  8001a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8001a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a7:	89 ec                	mov    %ebp,%esp
  8001a9:	5d                   	pop    %ebp
  8001aa:	c3                   	ret    
	...

008001ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001b2:	e8 e2 14 00 00       	call   801699 <close_all>
	sys_env_destroy(0);
  8001b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001be:	e8 3f 0f 00 00       	call   801102 <sys_env_destroy>
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    
  8001c5:	00 00                	add    %al,(%eax)
	...

008001c8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001d0:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001d3:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001d9:	e8 e9 0e 00 00       	call   8010c7 <sys_getenvid>
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 78 2a 80 00 	movl   $0x802a78,(%esp)
  8001fb:	e8 81 00 00 00       	call   800281 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	89 74 24 04          	mov    %esi,0x4(%esp)
  800204:	8b 45 10             	mov    0x10(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 11 00 00 00       	call   800220 <vcprintf>
	cprintf("\n");
  80020f:	c7 04 24 02 2a 80 00 	movl   $0x802a02,(%esp)
  800216:	e8 66 00 00 00       	call   800281 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x53>
	...

00800220 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800229:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800230:	00 00 00 
	b.cnt = 0;
  800233:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80023d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800240:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	89 44 24 08          	mov    %eax,0x8(%esp)
  80024b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	c7 04 24 9b 02 80 00 	movl   $0x80029b,(%esp)
  80025c:	e8 cc 01 00 00       	call   80042d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800261:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80026b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	e8 fd 0e 00 00       	call   801176 <sys_cputs>

	return b.cnt;
}
  800279:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800287:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80028a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	e8 87 ff ff ff       	call   800220 <vcprintf>
	va_end(ap);

	return cnt;
}
  800299:	c9                   	leave  
  80029a:	c3                   	ret    

0080029b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029b:	55                   	push   %ebp
  80029c:	89 e5                	mov    %esp,%ebp
  80029e:	53                   	push   %ebx
  80029f:	83 ec 14             	sub    $0x14,%esp
  8002a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a5:	8b 03                	mov    (%ebx),%eax
  8002a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002aa:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002ae:	83 c0 01             	add    $0x1,%eax
  8002b1:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002b8:	75 19                	jne    8002d3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002ba:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002c1:	00 
  8002c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8002c5:	89 04 24             	mov    %eax,(%esp)
  8002c8:	e8 a9 0e 00 00       	call   801176 <sys_cputs>
		b->idx = 0;
  8002cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002d3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002d7:	83 c4 14             	add    $0x14,%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    
  8002dd:	00 00                	add    %al,(%eax)
	...

008002e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	57                   	push   %edi
  8002e4:	56                   	push   %esi
  8002e5:	53                   	push   %ebx
  8002e6:	83 ec 4c             	sub    $0x4c,%esp
  8002e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ec:	89 d6                	mov    %edx,%esi
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800300:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800303:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800306:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030b:	39 d1                	cmp    %edx,%ecx
  80030d:	72 15                	jb     800324 <printnum+0x44>
  80030f:	77 07                	ja     800318 <printnum+0x38>
  800311:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800314:	39 d0                	cmp    %edx,%eax
  800316:	76 0c                	jbe    800324 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	8d 76 00             	lea    0x0(%esi),%esi
  800320:	7f 61                	jg     800383 <printnum+0xa3>
  800322:	eb 70                	jmp    800394 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800324:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800328:	83 eb 01             	sub    $0x1,%ebx
  80032b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800337:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80033b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80033e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800341:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800344:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034f:	00 
  800350:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800359:	89 54 24 04          	mov    %edx,0x4(%esp)
  80035d:	e8 ce 23 00 00       	call   802730 <__udivdi3>
  800362:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800365:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800368:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80036c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800370:	89 04 24             	mov    %eax,(%esp)
  800373:	89 54 24 04          	mov    %edx,0x4(%esp)
  800377:	89 f2                	mov    %esi,%edx
  800379:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037c:	e8 5f ff ff ff       	call   8002e0 <printnum>
  800381:	eb 11                	jmp    800394 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800383:	89 74 24 04          	mov    %esi,0x4(%esp)
  800387:	89 3c 24             	mov    %edi,(%esp)
  80038a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038d:	83 eb 01             	sub    $0x1,%ebx
  800390:	85 db                	test   %ebx,%ebx
  800392:	7f ef                	jg     800383 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800394:	89 74 24 04          	mov    %esi,0x4(%esp)
  800398:	8b 74 24 04          	mov    0x4(%esp),%esi
  80039c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80039f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003aa:	00 
  8003ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003ae:	89 14 24             	mov    %edx,(%esp)
  8003b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003b8:	e8 a3 24 00 00       	call   802860 <__umoddi3>
  8003bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c1:	0f be 80 9b 2a 80 00 	movsbl 0x802a9b(%eax),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ce:	83 c4 4c             	add    $0x4c,%esp
  8003d1:	5b                   	pop    %ebx
  8003d2:	5e                   	pop    %esi
  8003d3:	5f                   	pop    %edi
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d9:	83 fa 01             	cmp    $0x1,%edx
  8003dc:	7e 0e                	jle    8003ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ea:	eb 22                	jmp    80040e <getuint+0x38>
	else if (lflag)
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	74 10                	je     800400 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f5:	89 08                	mov    %ecx,(%eax)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fe:	eb 0e                	jmp    80040e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 04             	lea    0x4(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800416:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80041a:	8b 10                	mov    (%eax),%edx
  80041c:	3b 50 04             	cmp    0x4(%eax),%edx
  80041f:	73 0a                	jae    80042b <sprintputch+0x1b>
		*b->buf++ = ch;
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	88 0a                	mov    %cl,(%edx)
  800426:	83 c2 01             	add    $0x1,%edx
  800429:	89 10                	mov    %edx,(%eax)
}
  80042b:	5d                   	pop    %ebp
  80042c:	c3                   	ret    

0080042d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	57                   	push   %edi
  800431:	56                   	push   %esi
  800432:	53                   	push   %ebx
  800433:	83 ec 5c             	sub    $0x5c,%esp
  800436:	8b 7d 08             	mov    0x8(%ebp),%edi
  800439:	8b 75 0c             	mov    0xc(%ebp),%esi
  80043c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80043f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800446:	eb 11                	jmp    800459 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800448:	85 c0                	test   %eax,%eax
  80044a:	0f 84 68 04 00 00    	je     8008b8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800450:	89 74 24 04          	mov    %esi,0x4(%esp)
  800454:	89 04 24             	mov    %eax,(%esp)
  800457:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800459:	0f b6 03             	movzbl (%ebx),%eax
  80045c:	83 c3 01             	add    $0x1,%ebx
  80045f:	83 f8 25             	cmp    $0x25,%eax
  800462:	75 e4                	jne    800448 <vprintfmt+0x1b>
  800464:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80046b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800472:	b9 00 00 00 00       	mov    $0x0,%ecx
  800477:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80047b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800482:	eb 06                	jmp    80048a <vprintfmt+0x5d>
  800484:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800488:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	0f b6 13             	movzbl (%ebx),%edx
  80048d:	0f b6 c2             	movzbl %dl,%eax
  800490:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800493:	8d 43 01             	lea    0x1(%ebx),%eax
  800496:	83 ea 23             	sub    $0x23,%edx
  800499:	80 fa 55             	cmp    $0x55,%dl
  80049c:	0f 87 f9 03 00 00    	ja     80089b <vprintfmt+0x46e>
  8004a2:	0f b6 d2             	movzbl %dl,%edx
  8004a5:	ff 24 95 80 2c 80 00 	jmp    *0x802c80(,%edx,4)
  8004ac:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8004b0:	eb d6                	jmp    800488 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004b5:	83 ea 30             	sub    $0x30,%edx
  8004b8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8004bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004be:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004c1:	83 fb 09             	cmp    $0x9,%ebx
  8004c4:	77 54                	ja     80051a <vprintfmt+0xed>
  8004c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004cc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004cf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004d2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004d6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004dc:	83 fb 09             	cmp    $0x9,%ebx
  8004df:	76 eb                	jbe    8004cc <vprintfmt+0x9f>
  8004e1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004e7:	eb 31                	jmp    80051a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ec:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004ef:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f2:	8b 12                	mov    (%edx),%edx
  8004f4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004f7:	eb 21                	jmp    80051a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8004f9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800502:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800506:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800509:	e9 7a ff ff ff       	jmp    800488 <vprintfmt+0x5b>
  80050e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800515:	e9 6e ff ff ff       	jmp    800488 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80051a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051e:	0f 89 64 ff ff ff    	jns    800488 <vprintfmt+0x5b>
  800524:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800527:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80052a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80052d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800530:	e9 53 ff ff ff       	jmp    800488 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800535:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800538:	e9 4b ff ff ff       	jmp    800488 <vprintfmt+0x5b>
  80053d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	89 74 24 04          	mov    %esi,0x4(%esp)
  80054d:	8b 00                	mov    (%eax),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	ff d7                	call   *%edi
  800554:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800557:	e9 fd fe ff ff       	jmp    800459 <vprintfmt+0x2c>
  80055c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 c2                	mov    %eax,%edx
  80056c:	c1 fa 1f             	sar    $0x1f,%edx
  80056f:	31 d0                	xor    %edx,%eax
  800571:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800573:	83 f8 0f             	cmp    $0xf,%eax
  800576:	7f 0b                	jg     800583 <vprintfmt+0x156>
  800578:	8b 14 85 e0 2d 80 00 	mov    0x802de0(,%eax,4),%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	75 20                	jne    8005a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800583:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800587:	c7 44 24 08 ac 2a 80 	movl   $0x802aac,0x8(%esp)
  80058e:	00 
  80058f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800593:	89 3c 24             	mov    %edi,(%esp)
  800596:	e8 a5 03 00 00       	call   800940 <printfmt>
  80059b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059e:	e9 b6 fe ff ff       	jmp    800459 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a7:	c7 44 24 08 fb 2e 80 	movl   $0x802efb,0x8(%esp)
  8005ae:	00 
  8005af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b3:	89 3c 24             	mov    %edi,(%esp)
  8005b6:	e8 85 03 00 00       	call   800940 <printfmt>
  8005bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005be:	e9 96 fe ff ff       	jmp    800459 <vprintfmt+0x2c>
  8005c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 50 04             	lea    0x4(%eax),%edx
  8005d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005da:	8b 00                	mov    (%eax),%eax
  8005dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	b8 b5 2a 80 00       	mov    $0x802ab5,%eax
  8005e6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8005ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005ed:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005f1:	7e 06                	jle    8005f9 <vprintfmt+0x1cc>
  8005f3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005f7:	75 13                	jne    80060c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fc:	0f be 02             	movsbl (%edx),%eax
  8005ff:	85 c0                	test   %eax,%eax
  800601:	0f 85 a2 00 00 00    	jne    8006a9 <vprintfmt+0x27c>
  800607:	e9 8f 00 00 00       	jmp    80069b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800610:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800613:	89 0c 24             	mov    %ecx,(%esp)
  800616:	e8 70 03 00 00       	call   80098b <strnlen>
  80061b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80061e:	29 c2                	sub    %eax,%edx
  800620:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800623:	85 d2                	test   %edx,%edx
  800625:	7e d2                	jle    8005f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800627:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80062b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80062e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800631:	89 d3                	mov    %edx,%ebx
  800633:	89 74 24 04          	mov    %esi,0x4(%esp)
  800637:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80063f:	83 eb 01             	sub    $0x1,%ebx
  800642:	85 db                	test   %ebx,%ebx
  800644:	7f ed                	jg     800633 <vprintfmt+0x206>
  800646:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800649:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800650:	eb a7                	jmp    8005f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800652:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800656:	74 1b                	je     800673 <vprintfmt+0x246>
  800658:	8d 50 e0             	lea    -0x20(%eax),%edx
  80065b:	83 fa 5e             	cmp    $0x5e,%edx
  80065e:	76 13                	jbe    800673 <vprintfmt+0x246>
					putch('?', putdat);
  800660:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800663:	89 54 24 04          	mov    %edx,0x4(%esp)
  800667:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80066e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800671:	eb 0d                	jmp    800680 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800673:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800676:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	0f be 03             	movsbl (%ebx),%eax
  800686:	85 c0                	test   %eax,%eax
  800688:	74 05                	je     80068f <vprintfmt+0x262>
  80068a:	83 c3 01             	add    $0x1,%ebx
  80068d:	eb 31                	jmp    8006c0 <vprintfmt+0x293>
  80068f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800692:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800695:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800698:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80069f:	7f 36                	jg     8006d7 <vprintfmt+0x2aa>
  8006a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006a4:	e9 b0 fd ff ff       	jmp    800459 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ac:	83 c2 01             	add    $0x1,%edx
  8006af:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006b8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006bb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006be:	89 d3                	mov    %edx,%ebx
  8006c0:	85 f6                	test   %esi,%esi
  8006c2:	78 8e                	js     800652 <vprintfmt+0x225>
  8006c4:	83 ee 01             	sub    $0x1,%esi
  8006c7:	79 89                	jns    800652 <vprintfmt+0x225>
  8006c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006d5:	eb c4                	jmp    80069b <vprintfmt+0x26e>
  8006d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006e8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ea:	83 eb 01             	sub    $0x1,%ebx
  8006ed:	85 db                	test   %ebx,%ebx
  8006ef:	7f ec                	jg     8006dd <vprintfmt+0x2b0>
  8006f1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006f4:	e9 60 fd ff ff       	jmp    800459 <vprintfmt+0x2c>
  8006f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fc:	83 f9 01             	cmp    $0x1,%ecx
  8006ff:	7e 16                	jle    800717 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 08             	lea    0x8(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 10                	mov    (%eax),%edx
  80070c:	8b 48 04             	mov    0x4(%eax),%ecx
  80070f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800712:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800715:	eb 32                	jmp    800749 <vprintfmt+0x31c>
	else if (lflag)
  800717:	85 c9                	test   %ecx,%ecx
  800719:	74 18                	je     800733 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8d 50 04             	lea    0x4(%eax),%edx
  800721:	89 55 14             	mov    %edx,0x14(%ebp)
  800724:	8b 00                	mov    (%eax),%eax
  800726:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800729:	89 c1                	mov    %eax,%ecx
  80072b:	c1 f9 1f             	sar    $0x1f,%ecx
  80072e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800731:	eb 16                	jmp    800749 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8d 50 04             	lea    0x4(%eax),%edx
  800739:	89 55 14             	mov    %edx,0x14(%ebp)
  80073c:	8b 00                	mov    (%eax),%eax
  80073e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800741:	89 c2                	mov    %eax,%edx
  800743:	c1 fa 1f             	sar    $0x1f,%edx
  800746:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800749:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80074f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800754:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800758:	0f 89 8a 00 00 00    	jns    8007e8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80075e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800762:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800769:	ff d7                	call   *%edi
				num = -(long long) num;
  80076b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80076e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800771:	f7 d8                	neg    %eax
  800773:	83 d2 00             	adc    $0x0,%edx
  800776:	f7 da                	neg    %edx
  800778:	eb 6e                	jmp    8007e8 <vprintfmt+0x3bb>
  80077a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80077d:	89 ca                	mov    %ecx,%edx
  80077f:	8d 45 14             	lea    0x14(%ebp),%eax
  800782:	e8 4f fc ff ff       	call   8003d6 <getuint>
  800787:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80078c:	eb 5a                	jmp    8007e8 <vprintfmt+0x3bb>
  80078e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800791:	89 ca                	mov    %ecx,%edx
  800793:	8d 45 14             	lea    0x14(%ebp),%eax
  800796:	e8 3b fc ff ff       	call   8003d6 <getuint>
  80079b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8007a0:	eb 46                	jmp    8007e8 <vprintfmt+0x3bb>
  8007a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8007a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007b0:	ff d7                	call   *%edi
			putch('x', putdat);
  8007b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007bd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 50 04             	lea    0x4(%eax),%edx
  8007c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c8:	8b 00                	mov    (%eax),%eax
  8007ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8007cf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007d4:	eb 12                	jmp    8007e8 <vprintfmt+0x3bb>
  8007d6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007d9:	89 ca                	mov    %ecx,%edx
  8007db:	8d 45 14             	lea    0x14(%ebp),%eax
  8007de:	e8 f3 fb ff ff       	call   8003d6 <getuint>
  8007e3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007e8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8007ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007f3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007fb:	89 04 24             	mov    %eax,(%esp)
  8007fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800802:	89 f2                	mov    %esi,%edx
  800804:	89 f8                	mov    %edi,%eax
  800806:	e8 d5 fa ff ff       	call   8002e0 <printnum>
  80080b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80080e:	e9 46 fc ff ff       	jmp    800459 <vprintfmt+0x2c>
  800813:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800816:	8b 45 14             	mov    0x14(%ebp),%eax
  800819:	8d 50 04             	lea    0x4(%eax),%edx
  80081c:	89 55 14             	mov    %edx,0x14(%ebp)
  80081f:	8b 00                	mov    (%eax),%eax
  800821:	85 c0                	test   %eax,%eax
  800823:	75 24                	jne    800849 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800825:	c7 44 24 0c d0 2b 80 	movl   $0x802bd0,0xc(%esp)
  80082c:	00 
  80082d:	c7 44 24 08 fb 2e 80 	movl   $0x802efb,0x8(%esp)
  800834:	00 
  800835:	89 74 24 04          	mov    %esi,0x4(%esp)
  800839:	89 3c 24             	mov    %edi,(%esp)
  80083c:	e8 ff 00 00 00       	call   800940 <printfmt>
  800841:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800844:	e9 10 fc ff ff       	jmp    800459 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800849:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80084c:	7e 29                	jle    800877 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80084e:	0f b6 16             	movzbl (%esi),%edx
  800851:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800853:	c7 44 24 0c 08 2c 80 	movl   $0x802c08,0xc(%esp)
  80085a:	00 
  80085b:	c7 44 24 08 fb 2e 80 	movl   $0x802efb,0x8(%esp)
  800862:	00 
  800863:	89 74 24 04          	mov    %esi,0x4(%esp)
  800867:	89 3c 24             	mov    %edi,(%esp)
  80086a:	e8 d1 00 00 00       	call   800940 <printfmt>
  80086f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800872:	e9 e2 fb ff ff       	jmp    800459 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800877:	0f b6 16             	movzbl (%esi),%edx
  80087a:	88 10                	mov    %dl,(%eax)
  80087c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80087f:	e9 d5 fb ff ff       	jmp    800459 <vprintfmt+0x2c>
  800884:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800887:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80088a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80088e:	89 14 24             	mov    %edx,(%esp)
  800891:	ff d7                	call   *%edi
  800893:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800896:	e9 be fb ff ff       	jmp    800459 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80089f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008a6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008ab:	80 38 25             	cmpb   $0x25,(%eax)
  8008ae:	0f 84 a5 fb ff ff    	je     800459 <vprintfmt+0x2c>
  8008b4:	89 c3                	mov    %eax,%ebx
  8008b6:	eb f0                	jmp    8008a8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8008b8:	83 c4 5c             	add    $0x5c,%esp
  8008bb:	5b                   	pop    %ebx
  8008bc:	5e                   	pop    %esi
  8008bd:	5f                   	pop    %edi
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 28             	sub    $0x28,%esp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	74 04                	je     8008d4 <vsnprintf+0x14>
  8008d0:	85 d2                	test   %edx,%edx
  8008d2:	7f 07                	jg     8008db <vsnprintf+0x1b>
  8008d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d9:	eb 3b                	jmp    800916 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008de:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800901:	c7 04 24 10 04 80 00 	movl   $0x800410,(%esp)
  800908:	e8 20 fb ff ff       	call   80042d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800910:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800913:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800916:	c9                   	leave  
  800917:	c3                   	ret    

00800918 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80091e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800921:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800925:	8b 45 10             	mov    0x10(%ebp),%eax
  800928:	89 44 24 08          	mov    %eax,0x8(%esp)
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	89 04 24             	mov    %eax,(%esp)
  800939:	e8 82 ff ff ff       	call   8008c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800946:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800949:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80094d:	8b 45 10             	mov    0x10(%ebp),%eax
  800950:	89 44 24 08          	mov    %eax,0x8(%esp)
  800954:	8b 45 0c             	mov    0xc(%ebp),%eax
  800957:	89 44 24 04          	mov    %eax,0x4(%esp)
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	89 04 24             	mov    %eax,(%esp)
  800961:	e8 c7 fa ff ff       	call   80042d <vprintfmt>
	va_end(ap);
}
  800966:	c9                   	leave  
  800967:	c3                   	ret    
	...

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	80 3a 00             	cmpb   $0x0,(%edx)
  80097e:	74 09                	je     800989 <strlen+0x19>
		n++;
  800980:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800983:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800987:	75 f7                	jne    800980 <strlen+0x10>
		n++;
	return n;
}
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800992:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800995:	85 c9                	test   %ecx,%ecx
  800997:	74 19                	je     8009b2 <strnlen+0x27>
  800999:	80 3b 00             	cmpb   $0x0,(%ebx)
  80099c:	74 14                	je     8009b2 <strnlen+0x27>
  80099e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009a3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a6:	39 c8                	cmp    %ecx,%eax
  8009a8:	74 0d                	je     8009b7 <strnlen+0x2c>
  8009aa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009ae:	75 f3                	jne    8009a3 <strnlen+0x18>
  8009b0:	eb 05                	jmp    8009b7 <strnlen+0x2c>
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009c4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	84 c9                	test   %cl,%cl
  8009d5:	75 f2                	jne    8009c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	83 ec 08             	sub    $0x8,%esp
  8009e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e4:	89 1c 24             	mov    %ebx,(%esp)
  8009e7:	e8 84 ff ff ff       	call   800970 <strlen>
	strcpy(dst + len, src);
  8009ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ef:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009f3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009f6:	89 04 24             	mov    %eax,(%esp)
  8009f9:	e8 bc ff ff ff       	call   8009ba <strcpy>
	return dst;
}
  8009fe:	89 d8                	mov    %ebx,%eax
  800a00:	83 c4 08             	add    $0x8,%esp
  800a03:	5b                   	pop    %ebx
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a14:	85 f6                	test   %esi,%esi
  800a16:	74 18                	je     800a30 <strncpy+0x2a>
  800a18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a1d:	0f b6 1a             	movzbl (%edx),%ebx
  800a20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a23:	80 3a 01             	cmpb   $0x1,(%edx)
  800a26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	39 ce                	cmp    %ecx,%esi
  800a2e:	77 ed                	ja     800a1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a42:	89 f0                	mov    %esi,%eax
  800a44:	85 c9                	test   %ecx,%ecx
  800a46:	74 27                	je     800a6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a48:	83 e9 01             	sub    $0x1,%ecx
  800a4b:	74 1d                	je     800a6a <strlcpy+0x36>
  800a4d:	0f b6 1a             	movzbl (%edx),%ebx
  800a50:	84 db                	test   %bl,%bl
  800a52:	74 16                	je     800a6a <strlcpy+0x36>
			*dst++ = *src++;
  800a54:	88 18                	mov    %bl,(%eax)
  800a56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a59:	83 e9 01             	sub    $0x1,%ecx
  800a5c:	74 0e                	je     800a6c <strlcpy+0x38>
			*dst++ = *src++;
  800a5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a61:	0f b6 1a             	movzbl (%edx),%ebx
  800a64:	84 db                	test   %bl,%bl
  800a66:	75 ec                	jne    800a54 <strlcpy+0x20>
  800a68:	eb 02                	jmp    800a6c <strlcpy+0x38>
  800a6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a6c:	c6 00 00             	movb   $0x0,(%eax)
  800a6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7e:	0f b6 01             	movzbl (%ecx),%eax
  800a81:	84 c0                	test   %al,%al
  800a83:	74 15                	je     800a9a <strcmp+0x25>
  800a85:	3a 02                	cmp    (%edx),%al
  800a87:	75 11                	jne    800a9a <strcmp+0x25>
		p++, q++;
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a8f:	0f b6 01             	movzbl (%ecx),%eax
  800a92:	84 c0                	test   %al,%al
  800a94:	74 04                	je     800a9a <strcmp+0x25>
  800a96:	3a 02                	cmp    (%edx),%al
  800a98:	74 ef                	je     800a89 <strcmp+0x14>
  800a9a:	0f b6 c0             	movzbl %al,%eax
  800a9d:	0f b6 12             	movzbl (%edx),%edx
  800aa0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aa2:	5d                   	pop    %ebp
  800aa3:	c3                   	ret    

00800aa4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	53                   	push   %ebx
  800aa8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ab1:	85 c0                	test   %eax,%eax
  800ab3:	74 23                	je     800ad8 <strncmp+0x34>
  800ab5:	0f b6 1a             	movzbl (%edx),%ebx
  800ab8:	84 db                	test   %bl,%bl
  800aba:	74 25                	je     800ae1 <strncmp+0x3d>
  800abc:	3a 19                	cmp    (%ecx),%bl
  800abe:	75 21                	jne    800ae1 <strncmp+0x3d>
  800ac0:	83 e8 01             	sub    $0x1,%eax
  800ac3:	74 13                	je     800ad8 <strncmp+0x34>
		n--, p++, q++;
  800ac5:	83 c2 01             	add    $0x1,%edx
  800ac8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800acb:	0f b6 1a             	movzbl (%edx),%ebx
  800ace:	84 db                	test   %bl,%bl
  800ad0:	74 0f                	je     800ae1 <strncmp+0x3d>
  800ad2:	3a 19                	cmp    (%ecx),%bl
  800ad4:	74 ea                	je     800ac0 <strncmp+0x1c>
  800ad6:	eb 09                	jmp    800ae1 <strncmp+0x3d>
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800add:	5b                   	pop    %ebx
  800ade:	5d                   	pop    %ebp
  800adf:	90                   	nop
  800ae0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae1:	0f b6 02             	movzbl (%edx),%eax
  800ae4:	0f b6 11             	movzbl (%ecx),%edx
  800ae7:	29 d0                	sub    %edx,%eax
  800ae9:	eb f2                	jmp    800add <strncmp+0x39>

00800aeb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aeb:	55                   	push   %ebp
  800aec:	89 e5                	mov    %esp,%ebp
  800aee:	8b 45 08             	mov    0x8(%ebp),%eax
  800af1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af5:	0f b6 10             	movzbl (%eax),%edx
  800af8:	84 d2                	test   %dl,%dl
  800afa:	74 18                	je     800b14 <strchr+0x29>
		if (*s == c)
  800afc:	38 ca                	cmp    %cl,%dl
  800afe:	75 0a                	jne    800b0a <strchr+0x1f>
  800b00:	eb 17                	jmp    800b19 <strchr+0x2e>
  800b02:	38 ca                	cmp    %cl,%dl
  800b04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b08:	74 0f                	je     800b19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b0a:	83 c0 01             	add    $0x1,%eax
  800b0d:	0f b6 10             	movzbl (%eax),%edx
  800b10:	84 d2                	test   %dl,%dl
  800b12:	75 ee                	jne    800b02 <strchr+0x17>
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b25:	0f b6 10             	movzbl (%eax),%edx
  800b28:	84 d2                	test   %dl,%dl
  800b2a:	74 18                	je     800b44 <strfind+0x29>
		if (*s == c)
  800b2c:	38 ca                	cmp    %cl,%dl
  800b2e:	75 0a                	jne    800b3a <strfind+0x1f>
  800b30:	eb 12                	jmp    800b44 <strfind+0x29>
  800b32:	38 ca                	cmp    %cl,%dl
  800b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b38:	74 0a                	je     800b44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b3a:	83 c0 01             	add    $0x1,%eax
  800b3d:	0f b6 10             	movzbl (%eax),%edx
  800b40:	84 d2                	test   %dl,%dl
  800b42:	75 ee                	jne    800b32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	89 1c 24             	mov    %ebx,(%esp)
  800b4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b60:	85 c9                	test   %ecx,%ecx
  800b62:	74 30                	je     800b94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b6a:	75 25                	jne    800b91 <memset+0x4b>
  800b6c:	f6 c1 03             	test   $0x3,%cl
  800b6f:	75 20                	jne    800b91 <memset+0x4b>
		c &= 0xFF;
  800b71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	c1 e3 08             	shl    $0x8,%ebx
  800b79:	89 d6                	mov    %edx,%esi
  800b7b:	c1 e6 18             	shl    $0x18,%esi
  800b7e:	89 d0                	mov    %edx,%eax
  800b80:	c1 e0 10             	shl    $0x10,%eax
  800b83:	09 f0                	or     %esi,%eax
  800b85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b87:	09 d8                	or     %ebx,%eax
  800b89:	c1 e9 02             	shr    $0x2,%ecx
  800b8c:	fc                   	cld    
  800b8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b8f:	eb 03                	jmp    800b94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b91:	fc                   	cld    
  800b92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b94:	89 f8                	mov    %edi,%eax
  800b96:	8b 1c 24             	mov    (%esp),%ebx
  800b99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ba1:	89 ec                	mov    %ebp,%esp
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 08             	sub    $0x8,%esp
  800bab:	89 34 24             	mov    %esi,(%esp)
  800bae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800bb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800bbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800bbd:	39 c6                	cmp    %eax,%esi
  800bbf:	73 35                	jae    800bf6 <memmove+0x51>
  800bc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bc4:	39 d0                	cmp    %edx,%eax
  800bc6:	73 2e                	jae    800bf6 <memmove+0x51>
		s += n;
		d += n;
  800bc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bca:	f6 c2 03             	test   $0x3,%dl
  800bcd:	75 1b                	jne    800bea <memmove+0x45>
  800bcf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bd5:	75 13                	jne    800bea <memmove+0x45>
  800bd7:	f6 c1 03             	test   $0x3,%cl
  800bda:	75 0e                	jne    800bea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800bdc:	83 ef 04             	sub    $0x4,%edi
  800bdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800be2:	c1 e9 02             	shr    $0x2,%ecx
  800be5:	fd                   	std    
  800be6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be8:	eb 09                	jmp    800bf3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bea:	83 ef 01             	sub    $0x1,%edi
  800bed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bf0:	fd                   	std    
  800bf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf4:	eb 20                	jmp    800c16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bfc:	75 15                	jne    800c13 <memmove+0x6e>
  800bfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c04:	75 0d                	jne    800c13 <memmove+0x6e>
  800c06:	f6 c1 03             	test   $0x3,%cl
  800c09:	75 08                	jne    800c13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c0b:	c1 e9 02             	shr    $0x2,%ecx
  800c0e:	fc                   	cld    
  800c0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c11:	eb 03                	jmp    800c16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c13:	fc                   	cld    
  800c14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c16:	8b 34 24             	mov    (%esp),%esi
  800c19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c1d:	89 ec                	mov    %ebp,%esp
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c27:	8b 45 10             	mov    0x10(%ebp),%eax
  800c2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c35:	8b 45 08             	mov    0x8(%ebp),%eax
  800c38:	89 04 24             	mov    %eax,(%esp)
  800c3b:	e8 65 ff ff ff       	call   800ba5 <memmove>
}
  800c40:	c9                   	leave  
  800c41:	c3                   	ret    

00800c42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	57                   	push   %edi
  800c46:	56                   	push   %esi
  800c47:	53                   	push   %ebx
  800c48:	8b 75 08             	mov    0x8(%ebp),%esi
  800c4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c51:	85 c9                	test   %ecx,%ecx
  800c53:	74 36                	je     800c8b <memcmp+0x49>
		if (*s1 != *s2)
  800c55:	0f b6 06             	movzbl (%esi),%eax
  800c58:	0f b6 1f             	movzbl (%edi),%ebx
  800c5b:	38 d8                	cmp    %bl,%al
  800c5d:	74 20                	je     800c7f <memcmp+0x3d>
  800c5f:	eb 14                	jmp    800c75 <memcmp+0x33>
  800c61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c6b:	83 c2 01             	add    $0x1,%edx
  800c6e:	83 e9 01             	sub    $0x1,%ecx
  800c71:	38 d8                	cmp    %bl,%al
  800c73:	74 12                	je     800c87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c75:	0f b6 c0             	movzbl %al,%eax
  800c78:	0f b6 db             	movzbl %bl,%ebx
  800c7b:	29 d8                	sub    %ebx,%eax
  800c7d:	eb 11                	jmp    800c90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7f:	83 e9 01             	sub    $0x1,%ecx
  800c82:	ba 00 00 00 00       	mov    $0x0,%edx
  800c87:	85 c9                	test   %ecx,%ecx
  800c89:	75 d6                	jne    800c61 <memcmp+0x1f>
  800c8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c9b:	89 c2                	mov    %eax,%edx
  800c9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ca0:	39 d0                	cmp    %edx,%eax
  800ca2:	73 15                	jae    800cb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ca4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ca8:	38 08                	cmp    %cl,(%eax)
  800caa:	75 06                	jne    800cb2 <memfind+0x1d>
  800cac:	eb 0b                	jmp    800cb9 <memfind+0x24>
  800cae:	38 08                	cmp    %cl,(%eax)
  800cb0:	74 07                	je     800cb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb2:	83 c0 01             	add    $0x1,%eax
  800cb5:	39 c2                	cmp    %eax,%edx
  800cb7:	77 f5                	ja     800cae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 04             	sub    $0x4,%esp
  800cc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cca:	0f b6 02             	movzbl (%edx),%eax
  800ccd:	3c 20                	cmp    $0x20,%al
  800ccf:	74 04                	je     800cd5 <strtol+0x1a>
  800cd1:	3c 09                	cmp    $0x9,%al
  800cd3:	75 0e                	jne    800ce3 <strtol+0x28>
		s++;
  800cd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd8:	0f b6 02             	movzbl (%edx),%eax
  800cdb:	3c 20                	cmp    $0x20,%al
  800cdd:	74 f6                	je     800cd5 <strtol+0x1a>
  800cdf:	3c 09                	cmp    $0x9,%al
  800ce1:	74 f2                	je     800cd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ce3:	3c 2b                	cmp    $0x2b,%al
  800ce5:	75 0c                	jne    800cf3 <strtol+0x38>
		s++;
  800ce7:	83 c2 01             	add    $0x1,%edx
  800cea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cf1:	eb 15                	jmp    800d08 <strtol+0x4d>
	else if (*s == '-')
  800cf3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cfa:	3c 2d                	cmp    $0x2d,%al
  800cfc:	75 0a                	jne    800d08 <strtol+0x4d>
		s++, neg = 1;
  800cfe:	83 c2 01             	add    $0x1,%edx
  800d01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d08:	85 db                	test   %ebx,%ebx
  800d0a:	0f 94 c0             	sete   %al
  800d0d:	74 05                	je     800d14 <strtol+0x59>
  800d0f:	83 fb 10             	cmp    $0x10,%ebx
  800d12:	75 18                	jne    800d2c <strtol+0x71>
  800d14:	80 3a 30             	cmpb   $0x30,(%edx)
  800d17:	75 13                	jne    800d2c <strtol+0x71>
  800d19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d1d:	8d 76 00             	lea    0x0(%esi),%esi
  800d20:	75 0a                	jne    800d2c <strtol+0x71>
		s += 2, base = 16;
  800d22:	83 c2 02             	add    $0x2,%edx
  800d25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d2a:	eb 15                	jmp    800d41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d2c:	84 c0                	test   %al,%al
  800d2e:	66 90                	xchg   %ax,%ax
  800d30:	74 0f                	je     800d41 <strtol+0x86>
  800d32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d37:	80 3a 30             	cmpb   $0x30,(%edx)
  800d3a:	75 05                	jne    800d41 <strtol+0x86>
		s++, base = 8;
  800d3c:	83 c2 01             	add    $0x1,%edx
  800d3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d41:	b8 00 00 00 00       	mov    $0x0,%eax
  800d46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d48:	0f b6 0a             	movzbl (%edx),%ecx
  800d4b:	89 cf                	mov    %ecx,%edi
  800d4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d50:	80 fb 09             	cmp    $0x9,%bl
  800d53:	77 08                	ja     800d5d <strtol+0xa2>
			dig = *s - '0';
  800d55:	0f be c9             	movsbl %cl,%ecx
  800d58:	83 e9 30             	sub    $0x30,%ecx
  800d5b:	eb 1e                	jmp    800d7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d60:	80 fb 19             	cmp    $0x19,%bl
  800d63:	77 08                	ja     800d6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d65:	0f be c9             	movsbl %cl,%ecx
  800d68:	83 e9 57             	sub    $0x57,%ecx
  800d6b:	eb 0e                	jmp    800d7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d70:	80 fb 19             	cmp    $0x19,%bl
  800d73:	77 15                	ja     800d8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d75:	0f be c9             	movsbl %cl,%ecx
  800d78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d7b:	39 f1                	cmp    %esi,%ecx
  800d7d:	7d 0b                	jge    800d8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d7f:	83 c2 01             	add    $0x1,%edx
  800d82:	0f af c6             	imul   %esi,%eax
  800d85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d88:	eb be                	jmp    800d48 <strtol+0x8d>
  800d8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d90:	74 05                	je     800d97 <strtol+0xdc>
		*endptr = (char *) s;
  800d92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d97:	89 ca                	mov    %ecx,%edx
  800d99:	f7 da                	neg    %edx
  800d9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d9f:	0f 45 c2             	cmovne %edx,%eax
}
  800da2:	83 c4 04             	add    $0x4,%esp
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    
	...

00800dac <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	83 ec 48             	sub    $0x48,%esp
  800db2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800db5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dbb:	89 c6                	mov    %eax,%esi
  800dbd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800dc0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800dc2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800dc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcb:	51                   	push   %ecx
  800dcc:	52                   	push   %edx
  800dcd:	53                   	push   %ebx
  800dce:	54                   	push   %esp
  800dcf:	55                   	push   %ebp
  800dd0:	56                   	push   %esi
  800dd1:	57                   	push   %edi
  800dd2:	89 e5                	mov    %esp,%ebp
  800dd4:	8d 35 dc 0d 80 00    	lea    0x800ddc,%esi
  800dda:	0f 34                	sysenter 

00800ddc <.after_sysenter_label>:
  800ddc:	5f                   	pop    %edi
  800ddd:	5e                   	pop    %esi
  800dde:	5d                   	pop    %ebp
  800ddf:	5c                   	pop    %esp
  800de0:	5b                   	pop    %ebx
  800de1:	5a                   	pop    %edx
  800de2:	59                   	pop    %ecx
  800de3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800de5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800de9:	74 28                	je     800e13 <.after_sysenter_label+0x37>
  800deb:	85 c0                	test   %eax,%eax
  800ded:	7e 24                	jle    800e13 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800def:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800df7:	c7 44 24 08 20 2e 80 	movl   $0x802e20,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 3d 2e 80 00 	movl   $0x802e3d,(%esp)
  800e0e:	e8 b5 f3 ff ff       	call   8001c8 <_panic>

	return ret;
}
  800e13:	89 d0                	mov    %edx,%eax
  800e15:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e18:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e1b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1e:	89 ec                	mov    %ebp,%esp
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800e28:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e2f:	00 
  800e30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e37:	00 
  800e38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e3f:	00 
  800e40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e43:	89 04 24             	mov    %eax,(%esp)
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e53:	e8 54 ff ff ff       	call   800dac <syscall>
}
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800e60:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e67:	00 
  800e68:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e6f:	00 
  800e70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e77:	00 
  800e78:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e8e:	e8 19 ff ff ff       	call   800dac <syscall>
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e9b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea2:	00 
  800ea3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eaa:	00 
  800eab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb2:	00 
  800eb3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebd:	ba 01 00 00 00       	mov    $0x1,%edx
  800ec2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ec7:	e8 e0 fe ff ff       	call   800dac <syscall>
}
  800ecc:	c9                   	leave  
  800ecd:	c3                   	ret    

00800ece <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ed4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800edb:	00 
  800edc:	8b 45 14             	mov    0x14(%ebp),%eax
  800edf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	89 04 24             	mov    %eax,(%esp)
  800ef0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800efd:	e8 aa fe ff ff       	call   800dac <syscall>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f11:	00 
  800f12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f21:	00 
  800f22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f25:	89 04 24             	mov    %eax,(%esp)
  800f28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f30:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f35:	e8 72 fe ff ff       	call   800dac <syscall>
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800f42:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f49:	00 
  800f4a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f51:	00 
  800f52:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f59:	00 
  800f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5d:	89 04 24             	mov    %eax,(%esp)
  800f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f63:	ba 01 00 00 00       	mov    $0x1,%edx
  800f68:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f6d:	e8 3a fe ff ff       	call   800dac <syscall>
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f7a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f81:	00 
  800f82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f91:	00 
  800f92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f95:	89 04 24             	mov    %eax,(%esp)
  800f98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9b:	ba 01 00 00 00       	mov    $0x1,%edx
  800fa0:	b8 09 00 00 00       	mov    $0x9,%eax
  800fa5:	e8 02 fe ff ff       	call   800dac <syscall>
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800fb2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb9:	00 
  800fba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc9:	00 
  800fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fd8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fdd:	e8 ca fd ff ff       	call   800dac <syscall>
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800fea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff1:	00 
  800ff2:	8b 45 18             	mov    0x18(%ebp),%eax
  800ff5:	0b 45 14             	or     0x14(%ebp),%eax
  800ff8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ffc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801003:	8b 45 0c             	mov    0xc(%ebp),%eax
  801006:	89 04 24             	mov    %eax,(%esp)
  801009:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100c:	ba 01 00 00 00       	mov    $0x1,%edx
  801011:	b8 06 00 00 00       	mov    $0x6,%eax
  801016:	e8 91 fd ff ff       	call   800dac <syscall>
}
  80101b:	c9                   	leave  
  80101c:	c3                   	ret    

0080101d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801023:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80102a:	00 
  80102b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801032:	00 
  801033:	8b 45 10             	mov    0x10(%ebp),%eax
  801036:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801043:	ba 01 00 00 00       	mov    $0x1,%edx
  801048:	b8 05 00 00 00       	mov    $0x5,%eax
  80104d:	e8 5a fd ff ff       	call   800dac <syscall>
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80105a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801061:	00 
  801062:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801069:	00 
  80106a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801071:	00 
  801072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801079:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107e:	ba 00 00 00 00       	mov    $0x0,%edx
  801083:	b8 0c 00 00 00       	mov    $0xc,%eax
  801088:	e8 1f fd ff ff       	call   800dac <syscall>
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801095:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80109c:	00 
  80109d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ac:	00 
  8010ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b0:	89 04 24             	mov    %eax,(%esp)
  8010b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8010c0:	e8 e7 fc ff ff       	call   800dac <syscall>
}
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8010cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d4:	00 
  8010d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010fb:	e8 ac fc ff ff       	call   800dac <syscall>
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801108:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80110f:	00 
  801110:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112a:	ba 01 00 00 00       	mov    $0x1,%edx
  80112f:	b8 03 00 00 00       	mov    $0x3,%eax
  801134:	e8 73 fc ff ff       	call   800dac <syscall>
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    

0080113b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80113b:	55                   	push   %ebp
  80113c:	89 e5                	mov    %esp,%ebp
  80113e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801141:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801148:	00 
  801149:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801160:	b9 00 00 00 00       	mov    $0x0,%ecx
  801165:	ba 00 00 00 00       	mov    $0x0,%edx
  80116a:	b8 01 00 00 00       	mov    $0x1,%eax
  80116f:	e8 38 fc ff ff       	call   800dac <syscall>
}
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80117c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801183:	00 
  801184:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80118b:	00 
  80118c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801193:	00 
  801194:	8b 45 0c             	mov    0xc(%ebp),%eax
  801197:	89 04 24             	mov    %eax,(%esp)
  80119a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119d:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a7:	e8 00 fc ff ff       	call   800dac <syscall>
}
  8011ac:	c9                   	leave  
  8011ad:	c3                   	ret    
	...

008011b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c9:	89 04 24             	mov    %eax,(%esp)
  8011cc:	e8 df ff ff ff       	call   8011b0 <fd2num>
  8011d1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011d6:	c1 e0 0c             	shl    $0xc,%eax
}
  8011d9:	c9                   	leave  
  8011da:	c3                   	ret    

008011db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	57                   	push   %edi
  8011df:	56                   	push   %esi
  8011e0:	53                   	push   %ebx
  8011e1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011e9:	a8 01                	test   $0x1,%al
  8011eb:	74 36                	je     801223 <fd_alloc+0x48>
  8011ed:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011f2:	a8 01                	test   $0x1,%al
  8011f4:	74 2d                	je     801223 <fd_alloc+0x48>
  8011f6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011fb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801200:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801205:	89 c3                	mov    %eax,%ebx
  801207:	89 c2                	mov    %eax,%edx
  801209:	c1 ea 16             	shr    $0x16,%edx
  80120c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80120f:	f6 c2 01             	test   $0x1,%dl
  801212:	74 14                	je     801228 <fd_alloc+0x4d>
  801214:	89 c2                	mov    %eax,%edx
  801216:	c1 ea 0c             	shr    $0xc,%edx
  801219:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80121c:	f6 c2 01             	test   $0x1,%dl
  80121f:	75 10                	jne    801231 <fd_alloc+0x56>
  801221:	eb 05                	jmp    801228 <fd_alloc+0x4d>
  801223:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801228:	89 1f                	mov    %ebx,(%edi)
  80122a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80122f:	eb 17                	jmp    801248 <fd_alloc+0x6d>
  801231:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801236:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80123b:	75 c8                	jne    801205 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80123d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801243:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801248:	5b                   	pop    %ebx
  801249:	5e                   	pop    %esi
  80124a:	5f                   	pop    %edi
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801250:	8b 45 08             	mov    0x8(%ebp),%eax
  801253:	83 f8 1f             	cmp    $0x1f,%eax
  801256:	77 36                	ja     80128e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801258:	05 00 00 0d 00       	add    $0xd0000,%eax
  80125d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801260:	89 c2                	mov    %eax,%edx
  801262:	c1 ea 16             	shr    $0x16,%edx
  801265:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126c:	f6 c2 01             	test   $0x1,%dl
  80126f:	74 1d                	je     80128e <fd_lookup+0x41>
  801271:	89 c2                	mov    %eax,%edx
  801273:	c1 ea 0c             	shr    $0xc,%edx
  801276:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127d:	f6 c2 01             	test   $0x1,%dl
  801280:	74 0c                	je     80128e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801282:	8b 55 0c             	mov    0xc(%ebp),%edx
  801285:	89 02                	mov    %eax,(%edx)
  801287:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80128c:	eb 05                	jmp    801293 <fd_lookup+0x46>
  80128e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    

00801295 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80129b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a5:	89 04 24             	mov    %eax,(%esp)
  8012a8:	e8 a0 ff ff ff       	call   80124d <fd_lookup>
  8012ad:	85 c0                	test   %eax,%eax
  8012af:	78 0e                	js     8012bf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b7:	89 50 04             	mov    %edx,0x4(%eax)
  8012ba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012bf:	c9                   	leave  
  8012c0:	c3                   	ret    

008012c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012c1:	55                   	push   %ebp
  8012c2:	89 e5                	mov    %esp,%ebp
  8012c4:	56                   	push   %esi
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 10             	sub    $0x10,%esp
  8012c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8012cf:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012d4:	b8 04 40 80 00       	mov    $0x804004,%eax
  8012d9:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  8012df:	75 11                	jne    8012f2 <dev_lookup+0x31>
  8012e1:	eb 04                	jmp    8012e7 <dev_lookup+0x26>
  8012e3:	39 08                	cmp    %ecx,(%eax)
  8012e5:	75 10                	jne    8012f7 <dev_lookup+0x36>
			*dev = devtab[i];
  8012e7:	89 03                	mov    %eax,(%ebx)
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8012ee:	66 90                	xchg   %ax,%ax
  8012f0:	eb 36                	jmp    801328 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012f2:	be c8 2e 80 00       	mov    $0x802ec8,%esi
  8012f7:	83 c2 01             	add    $0x1,%edx
  8012fa:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	75 e2                	jne    8012e3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801301:	a1 08 50 80 00       	mov    0x805008,%eax
  801306:	8b 40 48             	mov    0x48(%eax),%eax
  801309:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80130d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801311:	c7 04 24 4c 2e 80 00 	movl   $0x802e4c,(%esp)
  801318:	e8 64 ef ff ff       	call   800281 <cprintf>
	*dev = 0;
  80131d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801323:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801328:	83 c4 10             	add    $0x10,%esp
  80132b:	5b                   	pop    %ebx
  80132c:	5e                   	pop    %esi
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	53                   	push   %ebx
  801333:	83 ec 24             	sub    $0x24,%esp
  801336:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801339:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	89 04 24             	mov    %eax,(%esp)
  801346:	e8 02 ff ff ff       	call   80124d <fd_lookup>
  80134b:	85 c0                	test   %eax,%eax
  80134d:	78 53                	js     8013a2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801359:	8b 00                	mov    (%eax),%eax
  80135b:	89 04 24             	mov    %eax,(%esp)
  80135e:	e8 5e ff ff ff       	call   8012c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801363:	85 c0                	test   %eax,%eax
  801365:	78 3b                	js     8013a2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801367:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80136c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80136f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801373:	74 2d                	je     8013a2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801375:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801378:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80137f:	00 00 00 
	stat->st_isdir = 0;
  801382:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801389:	00 00 00 
	stat->st_dev = dev;
  80138c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801395:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801399:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80139c:	89 14 24             	mov    %edx,(%esp)
  80139f:	ff 50 14             	call   *0x14(%eax)
}
  8013a2:	83 c4 24             	add    $0x24,%esp
  8013a5:	5b                   	pop    %ebx
  8013a6:	5d                   	pop    %ebp
  8013a7:	c3                   	ret    

008013a8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8013a8:	55                   	push   %ebp
  8013a9:	89 e5                	mov    %esp,%ebp
  8013ab:	53                   	push   %ebx
  8013ac:	83 ec 24             	sub    $0x24,%esp
  8013af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b9:	89 1c 24             	mov    %ebx,(%esp)
  8013bc:	e8 8c fe ff ff       	call   80124d <fd_lookup>
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	78 5f                	js     801424 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013cf:	8b 00                	mov    (%eax),%eax
  8013d1:	89 04 24             	mov    %eax,(%esp)
  8013d4:	e8 e8 fe ff ff       	call   8012c1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 47                	js     801424 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8013e4:	75 23                	jne    801409 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013e6:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013eb:	8b 40 48             	mov    0x48(%eax),%eax
  8013ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f6:	c7 04 24 6c 2e 80 00 	movl   $0x802e6c,(%esp)
  8013fd:	e8 7f ee ff ff       	call   800281 <cprintf>
  801402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801407:	eb 1b                	jmp    801424 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140c:	8b 48 18             	mov    0x18(%eax),%ecx
  80140f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801414:	85 c9                	test   %ecx,%ecx
  801416:	74 0c                	je     801424 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801418:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141f:	89 14 24             	mov    %edx,(%esp)
  801422:	ff d1                	call   *%ecx
}
  801424:	83 c4 24             	add    $0x24,%esp
  801427:	5b                   	pop    %ebx
  801428:	5d                   	pop    %ebp
  801429:	c3                   	ret    

0080142a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80142a:	55                   	push   %ebp
  80142b:	89 e5                	mov    %esp,%ebp
  80142d:	53                   	push   %ebx
  80142e:	83 ec 24             	sub    $0x24,%esp
  801431:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801434:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801437:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143b:	89 1c 24             	mov    %ebx,(%esp)
  80143e:	e8 0a fe ff ff       	call   80124d <fd_lookup>
  801443:	85 c0                	test   %eax,%eax
  801445:	78 66                	js     8014ad <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801447:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801451:	8b 00                	mov    (%eax),%eax
  801453:	89 04 24             	mov    %eax,(%esp)
  801456:	e8 66 fe ff ff       	call   8012c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80145b:	85 c0                	test   %eax,%eax
  80145d:	78 4e                	js     8014ad <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801462:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801466:	75 23                	jne    80148b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801468:	a1 08 50 80 00       	mov    0x805008,%eax
  80146d:	8b 40 48             	mov    0x48(%eax),%eax
  801470:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801474:	89 44 24 04          	mov    %eax,0x4(%esp)
  801478:	c7 04 24 8d 2e 80 00 	movl   $0x802e8d,(%esp)
  80147f:	e8 fd ed ff ff       	call   800281 <cprintf>
  801484:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801489:	eb 22                	jmp    8014ad <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801491:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801496:	85 c9                	test   %ecx,%ecx
  801498:	74 13                	je     8014ad <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80149a:	8b 45 10             	mov    0x10(%ebp),%eax
  80149d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	89 14 24             	mov    %edx,(%esp)
  8014ab:	ff d1                	call   *%ecx
}
  8014ad:	83 c4 24             	add    $0x24,%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5d                   	pop    %ebp
  8014b2:	c3                   	ret    

008014b3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	53                   	push   %ebx
  8014b7:	83 ec 24             	sub    $0x24,%esp
  8014ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c4:	89 1c 24             	mov    %ebx,(%esp)
  8014c7:	e8 81 fd ff ff       	call   80124d <fd_lookup>
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 6b                	js     80153b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014da:	8b 00                	mov    (%eax),%eax
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	e8 dd fd ff ff       	call   8012c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 53                	js     80153b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014eb:	8b 42 08             	mov    0x8(%edx),%eax
  8014ee:	83 e0 03             	and    $0x3,%eax
  8014f1:	83 f8 01             	cmp    $0x1,%eax
  8014f4:	75 23                	jne    801519 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f6:	a1 08 50 80 00       	mov    0x805008,%eax
  8014fb:	8b 40 48             	mov    0x48(%eax),%eax
  8014fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	c7 04 24 aa 2e 80 00 	movl   $0x802eaa,(%esp)
  80150d:	e8 6f ed ff ff       	call   800281 <cprintf>
  801512:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801517:	eb 22                	jmp    80153b <read+0x88>
	}
	if (!dev->dev_read)
  801519:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151c:	8b 48 08             	mov    0x8(%eax),%ecx
  80151f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801524:	85 c9                	test   %ecx,%ecx
  801526:	74 13                	je     80153b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801528:	8b 45 10             	mov    0x10(%ebp),%eax
  80152b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80152f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801532:	89 44 24 04          	mov    %eax,0x4(%esp)
  801536:	89 14 24             	mov    %edx,(%esp)
  801539:	ff d1                	call   *%ecx
}
  80153b:	83 c4 24             	add    $0x24,%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5d                   	pop    %ebp
  801540:	c3                   	ret    

00801541 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	57                   	push   %edi
  801545:	56                   	push   %esi
  801546:	53                   	push   %ebx
  801547:	83 ec 1c             	sub    $0x1c,%esp
  80154a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80154d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801550:	ba 00 00 00 00       	mov    $0x0,%edx
  801555:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155a:	b8 00 00 00 00       	mov    $0x0,%eax
  80155f:	85 f6                	test   %esi,%esi
  801561:	74 29                	je     80158c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801563:	89 f0                	mov    %esi,%eax
  801565:	29 d0                	sub    %edx,%eax
  801567:	89 44 24 08          	mov    %eax,0x8(%esp)
  80156b:	03 55 0c             	add    0xc(%ebp),%edx
  80156e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801572:	89 3c 24             	mov    %edi,(%esp)
  801575:	e8 39 ff ff ff       	call   8014b3 <read>
		if (m < 0)
  80157a:	85 c0                	test   %eax,%eax
  80157c:	78 0e                	js     80158c <readn+0x4b>
			return m;
		if (m == 0)
  80157e:	85 c0                	test   %eax,%eax
  801580:	74 08                	je     80158a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801582:	01 c3                	add    %eax,%ebx
  801584:	89 da                	mov    %ebx,%edx
  801586:	39 f3                	cmp    %esi,%ebx
  801588:	72 d9                	jb     801563 <readn+0x22>
  80158a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80158c:	83 c4 1c             	add    $0x1c,%esp
  80158f:	5b                   	pop    %ebx
  801590:	5e                   	pop    %esi
  801591:	5f                   	pop    %edi
  801592:	5d                   	pop    %ebp
  801593:	c3                   	ret    

00801594 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 28             	sub    $0x28,%esp
  80159a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80159d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8015a0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015a3:	89 34 24             	mov    %esi,(%esp)
  8015a6:	e8 05 fc ff ff       	call   8011b0 <fd2num>
  8015ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015b2:	89 04 24             	mov    %eax,(%esp)
  8015b5:	e8 93 fc ff ff       	call   80124d <fd_lookup>
  8015ba:	89 c3                	mov    %eax,%ebx
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 05                	js     8015c5 <fd_close+0x31>
  8015c0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015c3:	74 0e                	je     8015d3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8015c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ce:	0f 44 d8             	cmove  %eax,%ebx
  8015d1:	eb 3d                	jmp    801610 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015da:	8b 06                	mov    (%esi),%eax
  8015dc:	89 04 24             	mov    %eax,(%esp)
  8015df:	e8 dd fc ff ff       	call   8012c1 <dev_lookup>
  8015e4:	89 c3                	mov    %eax,%ebx
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 16                	js     801600 <fd_close+0x6c>
		if (dev->dev_close)
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	8b 40 10             	mov    0x10(%eax),%eax
  8015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	74 07                	je     801600 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8015f9:	89 34 24             	mov    %esi,(%esp)
  8015fc:	ff d0                	call   *%eax
  8015fe:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801600:	89 74 24 04          	mov    %esi,0x4(%esp)
  801604:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160b:	e8 9c f9 ff ff       	call   800fac <sys_page_unmap>
	return r;
}
  801610:	89 d8                	mov    %ebx,%eax
  801612:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801615:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801618:	89 ec                	mov    %ebp,%esp
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    

0080161c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80161c:	55                   	push   %ebp
  80161d:	89 e5                	mov    %esp,%ebp
  80161f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	89 44 24 04          	mov    %eax,0x4(%esp)
  801629:	8b 45 08             	mov    0x8(%ebp),%eax
  80162c:	89 04 24             	mov    %eax,(%esp)
  80162f:	e8 19 fc ff ff       	call   80124d <fd_lookup>
  801634:	85 c0                	test   %eax,%eax
  801636:	78 13                	js     80164b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801638:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80163f:	00 
  801640:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801643:	89 04 24             	mov    %eax,(%esp)
  801646:	e8 49 ff ff ff       	call   801594 <fd_close>
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	83 ec 18             	sub    $0x18,%esp
  801653:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801656:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801659:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801660:	00 
  801661:	8b 45 08             	mov    0x8(%ebp),%eax
  801664:	89 04 24             	mov    %eax,(%esp)
  801667:	e8 78 03 00 00       	call   8019e4 <open>
  80166c:	89 c3                	mov    %eax,%ebx
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 1b                	js     80168d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801672:	8b 45 0c             	mov    0xc(%ebp),%eax
  801675:	89 44 24 04          	mov    %eax,0x4(%esp)
  801679:	89 1c 24             	mov    %ebx,(%esp)
  80167c:	e8 ae fc ff ff       	call   80132f <fstat>
  801681:	89 c6                	mov    %eax,%esi
	close(fd);
  801683:	89 1c 24             	mov    %ebx,(%esp)
  801686:	e8 91 ff ff ff       	call   80161c <close>
  80168b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80168d:	89 d8                	mov    %ebx,%eax
  80168f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801692:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801695:	89 ec                	mov    %ebp,%esp
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	53                   	push   %ebx
  80169d:	83 ec 14             	sub    $0x14,%esp
  8016a0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8016a5:	89 1c 24             	mov    %ebx,(%esp)
  8016a8:	e8 6f ff ff ff       	call   80161c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ad:	83 c3 01             	add    $0x1,%ebx
  8016b0:	83 fb 20             	cmp    $0x20,%ebx
  8016b3:	75 f0                	jne    8016a5 <close_all+0xc>
		close(i);
}
  8016b5:	83 c4 14             	add    $0x14,%esp
  8016b8:	5b                   	pop    %ebx
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 58             	sub    $0x58,%esp
  8016c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d7:	89 04 24             	mov    %eax,(%esp)
  8016da:	e8 6e fb ff ff       	call   80124d <fd_lookup>
  8016df:	89 c3                	mov    %eax,%ebx
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	0f 88 e0 00 00 00    	js     8017c9 <dup+0x10e>
		return r;
	close(newfdnum);
  8016e9:	89 3c 24             	mov    %edi,(%esp)
  8016ec:	e8 2b ff ff ff       	call   80161c <close>

	newfd = INDEX2FD(newfdnum);
  8016f1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016f7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016fd:	89 04 24             	mov    %eax,(%esp)
  801700:	e8 bb fa ff ff       	call   8011c0 <fd2data>
  801705:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801707:	89 34 24             	mov    %esi,(%esp)
  80170a:	e8 b1 fa ff ff       	call   8011c0 <fd2data>
  80170f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801712:	89 da                	mov    %ebx,%edx
  801714:	89 d8                	mov    %ebx,%eax
  801716:	c1 e8 16             	shr    $0x16,%eax
  801719:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801720:	a8 01                	test   $0x1,%al
  801722:	74 43                	je     801767 <dup+0xac>
  801724:	c1 ea 0c             	shr    $0xc,%edx
  801727:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80172e:	a8 01                	test   $0x1,%al
  801730:	74 35                	je     801767 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801732:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801739:	25 07 0e 00 00       	and    $0xe07,%eax
  80173e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801742:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801745:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801749:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801750:	00 
  801751:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801755:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80175c:	e8 83 f8 ff ff       	call   800fe4 <sys_page_map>
  801761:	89 c3                	mov    %eax,%ebx
  801763:	85 c0                	test   %eax,%eax
  801765:	78 3f                	js     8017a6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176a:	89 c2                	mov    %eax,%edx
  80176c:	c1 ea 0c             	shr    $0xc,%edx
  80176f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801776:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80177c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801780:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801784:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80178b:	00 
  80178c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801790:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801797:	e8 48 f8 ff ff       	call   800fe4 <sys_page_map>
  80179c:	89 c3                	mov    %eax,%ebx
  80179e:	85 c0                	test   %eax,%eax
  8017a0:	78 04                	js     8017a6 <dup+0xeb>
  8017a2:	89 fb                	mov    %edi,%ebx
  8017a4:	eb 23                	jmp    8017c9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b1:	e8 f6 f7 ff ff       	call   800fac <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c4:	e8 e3 f7 ff ff       	call   800fac <sys_page_unmap>
	return r;
}
  8017c9:	89 d8                	mov    %ebx,%eax
  8017cb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017ce:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017d4:	89 ec                	mov    %ebp,%esp
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	83 ec 18             	sub    $0x18,%esp
  8017de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017e1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017e4:	89 c3                	mov    %eax,%ebx
  8017e6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017e8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8017ef:	75 11                	jne    801802 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8017f8:	e8 b3 0d 00 00       	call   8025b0 <ipc_find_env>
  8017fd:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801802:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801809:	00 
  80180a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801811:	00 
  801812:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801816:	a1 00 50 80 00       	mov    0x805000,%eax
  80181b:	89 04 24             	mov    %eax,(%esp)
  80181e:	e8 d1 0d 00 00       	call   8025f4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801823:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80182a:	00 
  80182b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801836:	e8 24 0e 00 00       	call   80265f <ipc_recv>
}
  80183b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80183e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801841:	89 ec                	mov    %ebp,%esp
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80184b:	8b 45 08             	mov    0x8(%ebp),%eax
  80184e:	8b 40 0c             	mov    0xc(%eax),%eax
  801851:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801856:	8b 45 0c             	mov    0xc(%ebp),%eax
  801859:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80185e:	ba 00 00 00 00       	mov    $0x0,%edx
  801863:	b8 02 00 00 00       	mov    $0x2,%eax
  801868:	e8 6b ff ff ff       	call   8017d8 <fsipc>
}
  80186d:	c9                   	leave  
  80186e:	c3                   	ret    

0080186f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801875:	8b 45 08             	mov    0x8(%ebp),%eax
  801878:	8b 40 0c             	mov    0xc(%eax),%eax
  80187b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801880:	ba 00 00 00 00       	mov    $0x0,%edx
  801885:	b8 06 00 00 00       	mov    $0x6,%eax
  80188a:	e8 49 ff ff ff       	call   8017d8 <fsipc>
}
  80188f:	c9                   	leave  
  801890:	c3                   	ret    

00801891 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a1:	e8 32 ff ff ff       	call   8017d8 <fsipc>
}
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 14             	sub    $0x14,%esp
  8018af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b8:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018c7:	e8 0c ff ff ff       	call   8017d8 <fsipc>
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 2b                	js     8018fb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018d0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8018d7:	00 
  8018d8:	89 1c 24             	mov    %ebx,(%esp)
  8018db:	e8 da f0 ff ff       	call   8009ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018e0:	a1 80 60 80 00       	mov    0x806080,%eax
  8018e5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018eb:	a1 84 60 80 00       	mov    0x806084,%eax
  8018f0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8018f6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8018fb:	83 c4 14             	add    $0x14,%esp
  8018fe:	5b                   	pop    %ebx
  8018ff:	5d                   	pop    %ebp
  801900:	c3                   	ret    

00801901 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 18             	sub    $0x18,%esp
  801907:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80190a:	8b 55 08             	mov    0x8(%ebp),%edx
  80190d:	8b 52 0c             	mov    0xc(%edx),%edx
  801910:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801916:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  80191b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801920:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801925:	0f 47 c2             	cmova  %edx,%eax
  801928:	89 44 24 08          	mov    %eax,0x8(%esp)
  80192c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801933:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80193a:	e8 66 f2 ff ff       	call   800ba5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80193f:	ba 00 00 00 00       	mov    $0x0,%edx
  801944:	b8 04 00 00 00       	mov    $0x4,%eax
  801949:	e8 8a fe ff ff       	call   8017d8 <fsipc>
}
  80194e:	c9                   	leave  
  80194f:	c3                   	ret    

00801950 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	53                   	push   %ebx
  801954:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
  80195a:	8b 40 0c             	mov    0xc(%eax),%eax
  80195d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801962:	8b 45 10             	mov    0x10(%ebp),%eax
  801965:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196a:	ba 00 00 00 00       	mov    $0x0,%edx
  80196f:	b8 03 00 00 00       	mov    $0x3,%eax
  801974:	e8 5f fe ff ff       	call   8017d8 <fsipc>
  801979:	89 c3                	mov    %eax,%ebx
  80197b:	85 c0                	test   %eax,%eax
  80197d:	78 17                	js     801996 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80197f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801983:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80198a:	00 
  80198b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198e:	89 04 24             	mov    %eax,(%esp)
  801991:	e8 0f f2 ff ff       	call   800ba5 <memmove>
  return r;	
}
  801996:	89 d8                	mov    %ebx,%eax
  801998:	83 c4 14             	add    $0x14,%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    

0080199e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80199e:	55                   	push   %ebp
  80199f:	89 e5                	mov    %esp,%ebp
  8019a1:	53                   	push   %ebx
  8019a2:	83 ec 14             	sub    $0x14,%esp
  8019a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019a8:	89 1c 24             	mov    %ebx,(%esp)
  8019ab:	e8 c0 ef ff ff       	call   800970 <strlen>
  8019b0:	89 c2                	mov    %eax,%edx
  8019b2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8019b7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8019bd:	7f 1f                	jg     8019de <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8019bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019c3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8019ca:	e8 eb ef ff ff       	call   8009ba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8019cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d4:	b8 07 00 00 00       	mov    $0x7,%eax
  8019d9:	e8 fa fd ff ff       	call   8017d8 <fsipc>
}
  8019de:	83 c4 14             	add    $0x14,%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5d                   	pop    %ebp
  8019e3:	c3                   	ret    

008019e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	83 ec 28             	sub    $0x28,%esp
  8019ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8019f0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8019f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f6:	89 04 24             	mov    %eax,(%esp)
  8019f9:	e8 dd f7 ff ff       	call   8011db <fd_alloc>
  8019fe:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a00:	85 c0                	test   %eax,%eax
  801a02:	0f 88 89 00 00 00    	js     801a91 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a08:	89 34 24             	mov    %esi,(%esp)
  801a0b:	e8 60 ef ff ff       	call   800970 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a10:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a1a:	7f 75                	jg     801a91 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a20:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801a27:	e8 8e ef ff ff       	call   8009ba <strcpy>
  fsipcbuf.open.req_omode = mode;
  801a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801a34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a37:	b8 01 00 00 00       	mov    $0x1,%eax
  801a3c:	e8 97 fd ff ff       	call   8017d8 <fsipc>
  801a41:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 0f                	js     801a56 <open+0x72>
  return fd2num(fd);
  801a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4a:	89 04 24             	mov    %eax,(%esp)
  801a4d:	e8 5e f7 ff ff       	call   8011b0 <fd2num>
  801a52:	89 c3                	mov    %eax,%ebx
  801a54:	eb 3b                	jmp    801a91 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801a56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a5d:	00 
  801a5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a61:	89 04 24             	mov    %eax,(%esp)
  801a64:	e8 2b fb ff ff       	call   801594 <fd_close>
  801a69:	85 c0                	test   %eax,%eax
  801a6b:	74 24                	je     801a91 <open+0xad>
  801a6d:	c7 44 24 0c d4 2e 80 	movl   $0x802ed4,0xc(%esp)
  801a74:	00 
  801a75:	c7 44 24 08 e9 2e 80 	movl   $0x802ee9,0x8(%esp)
  801a7c:	00 
  801a7d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801a84:	00 
  801a85:	c7 04 24 fe 2e 80 00 	movl   $0x802efe,(%esp)
  801a8c:	e8 37 e7 ff ff       	call   8001c8 <_panic>
  return r;
}
  801a91:	89 d8                	mov    %ebx,%eax
  801a93:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a96:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a99:	89 ec                	mov    %ebp,%esp
  801a9b:	5d                   	pop    %ebp
  801a9c:	c3                   	ret    
  801a9d:	00 00                	add    %al,(%eax)
	...

00801aa0 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	53                   	push   %ebx
  801aa6:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801aac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ab3:	00 
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	89 04 24             	mov    %eax,(%esp)
  801aba:	e8 25 ff ff ff       	call   8019e4 <open>
  801abf:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801ac5:	89 c3                	mov    %eax,%ebx
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	0f 88 33 05 00 00    	js     802002 <.after_sysenter_label+0x4b9>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801acf:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801ad6:	00 
  801ad7:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801add:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ae1:	89 1c 24             	mov    %ebx,(%esp)
  801ae4:	e8 58 fa ff ff       	call   801541 <readn>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801ae9:	3d 00 02 00 00       	cmp    $0x200,%eax
  801aee:	75 0c                	jne    801afc <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801af0:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801af7:	45 4c 46 
  801afa:	74 36                	je     801b32 <spawn+0x92>
		close(fd);
  801afc:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	e8 12 fb ff ff       	call   80161c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801b0a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801b11:	46 
  801b12:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1c:	c7 04 24 09 2f 80 00 	movl   $0x802f09,(%esp)
  801b23:	e8 59 e7 ff ff       	call   800281 <cprintf>
  801b28:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
		return -E_NOT_EXEC;
  801b2d:	e9 d0 04 00 00       	jmp    802002 <.after_sysenter_label+0x4b9>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801b32:	ba 08 00 00 00       	mov    $0x8,%edx
  801b37:	89 d0                	mov    %edx,%eax
  801b39:	51                   	push   %ecx
  801b3a:	52                   	push   %edx
  801b3b:	53                   	push   %ebx
  801b3c:	55                   	push   %ebp
  801b3d:	56                   	push   %esi
  801b3e:	57                   	push   %edi
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	8d 35 49 1b 80 00    	lea    0x801b49,%esi
  801b47:	0f 34                	sysenter 

00801b49 <.after_sysenter_label>:
  801b49:	5f                   	pop    %edi
  801b4a:	5e                   	pop    %esi
  801b4b:	5d                   	pop    %ebp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5a                   	pop    %edx
  801b4e:	59                   	pop    %ecx
  801b4f:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801b55:	85 c0                	test   %eax,%eax
  801b57:	0f 88 9f 04 00 00    	js     801ffc <.after_sysenter_label+0x4b3>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801b5d:	89 c6                	mov    %eax,%esi
  801b5f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801b65:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801b68:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801b6e:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801b74:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b79:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b7b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b81:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b87:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b8a:	8b 02                	mov    (%edx),%eax
  801b8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b91:	be 00 00 00 00       	mov    $0x0,%esi
  801b96:	85 c0                	test   %eax,%eax
  801b98:	75 16                	jne    801bb0 <.after_sysenter_label+0x67>
  801b9a:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801ba1:	00 00 00 
  801ba4:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bab:	00 00 00 
  801bae:	eb 2c                	jmp    801bdc <.after_sysenter_label+0x93>
  801bb0:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  801bb3:	89 04 24             	mov    %eax,(%esp)
  801bb6:	e8 b5 ed ff ff       	call   800970 <strlen>
  801bbb:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801bbf:	83 c6 01             	add    $0x1,%esi
  801bc2:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
  801bc9:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	75 e3                	jne    801bb3 <.after_sysenter_label+0x6a>
  801bd0:	89 95 7c fd ff ff    	mov    %edx,-0x284(%ebp)
  801bd6:	89 b5 78 fd ff ff    	mov    %esi,-0x288(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801bdc:	f7 db                	neg    %ebx
  801bde:	8d bb 00 10 40 00    	lea    0x401000(%ebx),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801be4:	89 fa                	mov    %edi,%edx
  801be6:	83 e2 fc             	and    $0xfffffffc,%edx
  801be9:	89 f0                	mov    %esi,%eax
  801beb:	f7 d0                	not    %eax
  801bed:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801bf0:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801bf6:	83 e8 08             	sub    $0x8,%eax
  801bf9:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801bff:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801c04:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801c09:	0f 86 f3 03 00 00    	jbe    802002 <.after_sysenter_label+0x4b9>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801c0f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801c16:	00 
  801c17:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801c1e:	00 
  801c1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c26:	e8 f2 f3 ff ff       	call   80101d <sys_page_alloc>
  801c2b:	89 c3                	mov    %eax,%ebx
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 cd 03 00 00    	js     802002 <.after_sysenter_label+0x4b9>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c35:	85 f6                	test   %esi,%esi
  801c37:	7e 46                	jle    801c7f <.after_sysenter_label+0x136>
  801c39:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3e:	89 b5 8c fd ff ff    	mov    %esi,-0x274(%ebp)
  801c44:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  801c47:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801c4d:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c53:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801c56:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c5d:	89 3c 24             	mov    %edi,(%esp)
  801c60:	e8 55 ed ff ff       	call   8009ba <strcpy>
		string_store += strlen(argv[i]) + 1;
  801c65:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801c68:	89 04 24             	mov    %eax,(%esp)
  801c6b:	e8 00 ed ff ff       	call   800970 <strlen>
  801c70:	8d 7c 38 01          	lea    0x1(%eax,%edi,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c74:	83 c3 01             	add    $0x1,%ebx
  801c77:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801c7d:	7c c8                	jl     801c47 <.after_sysenter_label+0xfe>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c7f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c85:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c8b:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c92:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c98:	74 24                	je     801cbe <.after_sysenter_label+0x175>
  801c9a:	c7 44 24 0c 80 2f 80 	movl   $0x802f80,0xc(%esp)
  801ca1:	00 
  801ca2:	c7 44 24 08 e9 2e 80 	movl   $0x802ee9,0x8(%esp)
  801ca9:	00 
  801caa:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  801cb1:	00 
  801cb2:	c7 04 24 23 2f 80 00 	movl   $0x802f23,(%esp)
  801cb9:	e8 0a e5 ff ff       	call   8001c8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801cbe:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801cc4:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801cc9:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801ccf:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801cd2:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801cd8:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cde:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801ce0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801ce6:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801ceb:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801cf1:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801cf8:	00 
  801cf9:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801d00:	ee 
  801d01:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801d07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d12:	00 
  801d13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1a:	e8 c5 f2 ff ff       	call   800fe4 <sys_page_map>
  801d1f:	89 c3                	mov    %eax,%ebx
  801d21:	85 c0                	test   %eax,%eax
  801d23:	78 1a                	js     801d3f <.after_sysenter_label+0x1f6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801d25:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d2c:	00 
  801d2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d34:	e8 73 f2 ff ff       	call   800fac <sys_page_unmap>
  801d39:	89 c3                	mov    %eax,%ebx
  801d3b:	85 c0                	test   %eax,%eax
  801d3d:	79 19                	jns    801d58 <.after_sysenter_label+0x20f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801d3f:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801d46:	00 
  801d47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d4e:	e8 59 f2 ff ff       	call   800fac <sys_page_unmap>
  801d53:	e9 aa 02 00 00       	jmp    802002 <.after_sysenter_label+0x4b9>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d58:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d5e:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801d65:	00 
  801d66:	0f 84 e4 01 00 00    	je     801f50 <.after_sysenter_label+0x407>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801d6c:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801d73:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
  801d79:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801d80:	00 00 00 
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801d83:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d89:	83 3a 01             	cmpl   $0x1,(%edx)
  801d8c:	0f 85 9c 01 00 00    	jne    801f2e <.after_sysenter_label+0x3e5>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d92:	8b 42 18             	mov    0x18(%edx),%eax
  801d95:	83 e0 02             	and    $0x2,%eax
  801d98:	83 f8 01             	cmp    $0x1,%eax
  801d9b:	19 c0                	sbb    %eax,%eax
  801d9d:	83 e0 fe             	and    $0xfffffffe,%eax
  801da0:	83 c0 07             	add    $0x7,%eax
  801da3:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801da9:	8b 52 04             	mov    0x4(%edx),%edx
  801dac:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801db2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801db8:	8b 58 10             	mov    0x10(%eax),%ebx
  801dbb:	8b 50 14             	mov    0x14(%eax),%edx
  801dbe:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801dc4:	8b 40 08             	mov    0x8(%eax),%eax
  801dc7:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801dcd:	25 ff 0f 00 00       	and    $0xfff,%eax
  801dd2:	74 16                	je     801dea <.after_sysenter_label+0x2a1>
		va -= i;
  801dd4:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  801dda:	01 c2                	add    %eax,%edx
  801ddc:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801de2:	01 c3                	add    %eax,%ebx
		fileoffset -= i;
  801de4:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801dea:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801df1:	0f 84 37 01 00 00    	je     801f2e <.after_sysenter_label+0x3e5>
  801df7:	bf 00 00 00 00       	mov    $0x0,%edi
  801dfc:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801e01:	39 fb                	cmp    %edi,%ebx
  801e03:	77 31                	ja     801e36 <.after_sysenter_label+0x2ed>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801e05:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e0f:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801e15:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e19:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e1f:	89 04 24             	mov    %eax,(%esp)
  801e22:	e8 f6 f1 ff ff       	call   80101d <sys_page_alloc>
  801e27:	85 c0                	test   %eax,%eax
  801e29:	0f 89 eb 00 00 00    	jns    801f1a <.after_sysenter_label+0x3d1>
  801e2f:	89 c3                	mov    %eax,%ebx
  801e31:	e9 a8 01 00 00       	jmp    801fde <.after_sysenter_label+0x495>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e36:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e3d:	00 
  801e3e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e45:	00 
  801e46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e4d:	e8 cb f1 ff ff       	call   80101d <sys_page_alloc>
  801e52:	85 c0                	test   %eax,%eax
  801e54:	0f 88 7a 01 00 00    	js     801fd4 <.after_sysenter_label+0x48b>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801e5a:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801e60:	8d 04 06             	lea    (%esi,%eax,1),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801e6d:	89 14 24             	mov    %edx,(%esp)
  801e70:	e8 20 f4 ff ff       	call   801295 <seek>
  801e75:	85 c0                	test   %eax,%eax
  801e77:	0f 88 5b 01 00 00    	js     801fd8 <.after_sysenter_label+0x48f>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e7d:	89 d8                	mov    %ebx,%eax
  801e7f:	29 f8                	sub    %edi,%eax
  801e81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e86:	ba 00 10 00 00       	mov    $0x1000,%edx
  801e8b:	0f 47 c2             	cmova  %edx,%eax
  801e8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e92:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e99:	00 
  801e9a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ea0:	89 04 24             	mov    %eax,(%esp)
  801ea3:	e8 99 f6 ff ff       	call   801541 <readn>
  801ea8:	85 c0                	test   %eax,%eax
  801eaa:	0f 88 2c 01 00 00    	js     801fdc <.after_sysenter_label+0x493>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801eb0:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801eb6:	89 54 24 10          	mov    %edx,0x10(%esp)
  801eba:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801ec0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ec4:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801eca:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ece:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ed5:	00 
  801ed6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801edd:	e8 02 f1 ff ff       	call   800fe4 <sys_page_map>
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	79 20                	jns    801f06 <.after_sysenter_label+0x3bd>
				panic("spawn: sys_page_map data: %e", r);
  801ee6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eea:	c7 44 24 08 2f 2f 80 	movl   $0x802f2f,0x8(%esp)
  801ef1:	00 
  801ef2:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  801ef9:	00 
  801efa:	c7 04 24 23 2f 80 00 	movl   $0x802f23,(%esp)
  801f01:	e8 c2 e2 ff ff       	call   8001c8 <_panic>
			sys_page_unmap(0, UTEMP);
  801f06:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801f0d:	00 
  801f0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f15:	e8 92 f0 ff ff       	call   800fac <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801f1a:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801f20:	89 f7                	mov    %esi,%edi
  801f22:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801f28:	0f 87 d3 fe ff ff    	ja     801e01 <.after_sysenter_label+0x2b8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801f2e:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801f35:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801f3c:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801f42:	7e 0c                	jle    801f50 <.after_sysenter_label+0x407>
  801f44:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801f4b:	e9 33 fe ff ff       	jmp    801d83 <.after_sysenter_label+0x23a>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801f50:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801f56:	89 14 24             	mov    %edx,(%esp)
  801f59:	e8 be f6 ff ff       	call   80161c <close>
	fd = -1;

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801f5e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801f64:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f68:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f6e:	89 04 24             	mov    %eax,(%esp)
  801f71:	e8 c6 ef ff ff       	call   800f3c <sys_env_set_trapframe>
  801f76:	85 c0                	test   %eax,%eax
  801f78:	79 20                	jns    801f9a <.after_sysenter_label+0x451>
		panic("sys_env_set_trapframe: %e", r);
  801f7a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f7e:	c7 44 24 08 4c 2f 80 	movl   $0x802f4c,0x8(%esp)
  801f85:	00 
  801f86:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
  801f8d:	00 
  801f8e:	c7 04 24 23 2f 80 00 	movl   $0x802f23,(%esp)
  801f95:	e8 2e e2 ff ff       	call   8001c8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f9a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801fa1:	00 
  801fa2:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801fa8:	89 14 24             	mov    %edx,(%esp)
  801fab:	e8 c4 ef ff ff       	call   800f74 <sys_env_set_status>
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	79 48                	jns    801ffc <.after_sysenter_label+0x4b3>
		panic("sys_env_set_status: %e", r);
  801fb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fb8:	c7 44 24 08 66 2f 80 	movl   $0x802f66,0x8(%esp)
  801fbf:	00 
  801fc0:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  801fc7:	00 
  801fc8:	c7 04 24 23 2f 80 00 	movl   $0x802f23,(%esp)
  801fcf:	e8 f4 e1 ff ff       	call   8001c8 <_panic>
  801fd4:	89 c3                	mov    %eax,%ebx
  801fd6:	eb 06                	jmp    801fde <.after_sysenter_label+0x495>
  801fd8:	89 c3                	mov    %eax,%ebx
  801fda:	eb 02                	jmp    801fde <.after_sysenter_label+0x495>
  801fdc:	89 c3                	mov    %eax,%ebx
	return child;

error:
	sys_env_destroy(child);
  801fde:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801fe4:	89 04 24             	mov    %eax,(%esp)
  801fe7:	e8 16 f1 ff ff       	call   801102 <sys_env_destroy>
	close(fd);
  801fec:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801ff2:	89 14 24             	mov    %edx,(%esp)
  801ff5:	e8 22 f6 ff ff       	call   80161c <close>
	return r;
  801ffa:	eb 06                	jmp    802002 <.after_sysenter_label+0x4b9>
  801ffc:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
}
  802002:	89 d8                	mov    %ebx,%eax
  802004:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  80200a:	5b                   	pop    %ebx
  80200b:	5e                   	pop    %esi
  80200c:	5f                   	pop    %edi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    

0080200f <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  80200f:	55                   	push   %ebp
  802010:	89 e5                	mov    %esp,%ebp
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 10             	sub    $0x10,%esp
  802017:	8b 5d 0c             	mov    0xc(%ebp),%ebx

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  80201a:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80201d:	83 3a 00             	cmpl   $0x0,(%edx)
  802020:	74 5d                	je     80207f <spawnl+0x70>
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  802027:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  80202a:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  80202e:	75 f7                	jne    802027 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802030:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  802037:	83 e2 f0             	and    $0xfffffff0,%edx
  80203a:	29 d4                	sub    %edx,%esp
  80203c:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802040:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802043:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  802045:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  80204c:	00 

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  80204d:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802050:	89 c3                	mov    %eax,%ebx
  802052:	85 c0                	test   %eax,%eax
  802054:	74 13                	je     802069 <spawnl+0x5a>
  802056:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  80205b:	83 c0 01             	add    $0x1,%eax
  80205e:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  802062:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802065:	39 d8                	cmp    %ebx,%eax
  802067:	72 f2                	jb     80205b <spawnl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802069:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80206d:	8b 45 08             	mov    0x8(%ebp),%eax
  802070:	89 04 24             	mov    %eax,(%esp)
  802073:	e8 28 fa ff ff       	call   801aa0 <spawn>
}
  802078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80207b:	5b                   	pop    %ebx
  80207c:	5e                   	pop    %esi
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80207f:	83 ec 20             	sub    $0x20,%esp
  802082:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802086:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802089:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  80208b:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  802092:	eb d5                	jmp    802069 <spawnl+0x5a>
	...

008020a0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  8020a6:	c7 44 24 04 a8 2f 80 	movl   $0x802fa8,0x4(%esp)
  8020ad:	00 
  8020ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 01 e9 ff ff       	call   8009ba <strcpy>
	return 0;
}
  8020b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020be:	c9                   	leave  
  8020bf:	c3                   	ret    

008020c0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 14             	sub    $0x14,%esp
  8020c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8020ca:	89 1c 24             	mov    %ebx,(%esp)
  8020cd:	e8 1a 06 00 00       	call   8026ec <pageref>
  8020d2:	89 c2                	mov    %eax,%edx
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d9:	83 fa 01             	cmp    $0x1,%edx
  8020dc:	75 0b                	jne    8020e9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8020de:	8b 43 0c             	mov    0xc(%ebx),%eax
  8020e1:	89 04 24             	mov    %eax,(%esp)
  8020e4:	e8 b9 02 00 00       	call   8023a2 <nsipc_close>
	else
		return 0;
}
  8020e9:	83 c4 14             	add    $0x14,%esp
  8020ec:	5b                   	pop    %ebx
  8020ed:	5d                   	pop    %ebp
  8020ee:	c3                   	ret    

008020ef <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8020ef:	55                   	push   %ebp
  8020f0:	89 e5                	mov    %esp,%ebp
  8020f2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8020f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020fc:	00 
  8020fd:	8b 45 10             	mov    0x10(%ebp),%eax
  802100:	89 44 24 08          	mov    %eax,0x8(%esp)
  802104:	8b 45 0c             	mov    0xc(%ebp),%eax
  802107:	89 44 24 04          	mov    %eax,0x4(%esp)
  80210b:	8b 45 08             	mov    0x8(%ebp),%eax
  80210e:	8b 40 0c             	mov    0xc(%eax),%eax
  802111:	89 04 24             	mov    %eax,(%esp)
  802114:	e8 c5 02 00 00       	call   8023de <nsipc_send>
}
  802119:	c9                   	leave  
  80211a:	c3                   	ret    

0080211b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80211b:	55                   	push   %ebp
  80211c:	89 e5                	mov    %esp,%ebp
  80211e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802121:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802128:	00 
  802129:	8b 45 10             	mov    0x10(%ebp),%eax
  80212c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802130:	8b 45 0c             	mov    0xc(%ebp),%eax
  802133:	89 44 24 04          	mov    %eax,0x4(%esp)
  802137:	8b 45 08             	mov    0x8(%ebp),%eax
  80213a:	8b 40 0c             	mov    0xc(%eax),%eax
  80213d:	89 04 24             	mov    %eax,(%esp)
  802140:	e8 0c 03 00 00       	call   802451 <nsipc_recv>
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	56                   	push   %esi
  80214b:	53                   	push   %ebx
  80214c:	83 ec 20             	sub    $0x20,%esp
  80214f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802151:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802154:	89 04 24             	mov    %eax,(%esp)
  802157:	e8 7f f0 ff ff       	call   8011db <fd_alloc>
  80215c:	89 c3                	mov    %eax,%ebx
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 21                	js     802183 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802162:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802169:	00 
  80216a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802171:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802178:	e8 a0 ee ff ff       	call   80101d <sys_page_alloc>
  80217d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80217f:	85 c0                	test   %eax,%eax
  802181:	79 0a                	jns    80218d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802183:	89 34 24             	mov    %esi,(%esp)
  802186:	e8 17 02 00 00       	call   8023a2 <nsipc_close>
		return r;
  80218b:	eb 28                	jmp    8021b5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80218d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802193:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802196:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	89 04 24             	mov    %eax,(%esp)
  8021ae:	e8 fd ef ff ff       	call   8011b0 <fd2num>
  8021b3:	89 c3                	mov    %eax,%ebx
}
  8021b5:	89 d8                	mov    %ebx,%eax
  8021b7:	83 c4 20             	add    $0x20,%esp
  8021ba:	5b                   	pop    %ebx
  8021bb:	5e                   	pop    %esi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    

008021be <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8021be:	55                   	push   %ebp
  8021bf:	89 e5                	mov    %esp,%ebp
  8021c1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8021c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8021c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d5:	89 04 24             	mov    %eax,(%esp)
  8021d8:	e8 79 01 00 00       	call   802356 <nsipc_socket>
  8021dd:	85 c0                	test   %eax,%eax
  8021df:	78 05                	js     8021e6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8021e1:	e8 61 ff ff ff       	call   802147 <alloc_sockfd>
}
  8021e6:	c9                   	leave  
  8021e7:	c3                   	ret    

008021e8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8021e8:	55                   	push   %ebp
  8021e9:	89 e5                	mov    %esp,%ebp
  8021eb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8021ee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8021f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f5:	89 04 24             	mov    %eax,(%esp)
  8021f8:	e8 50 f0 ff ff       	call   80124d <fd_lookup>
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	78 15                	js     802216 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802201:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802204:	8b 0a                	mov    (%edx),%ecx
  802206:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80220b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802211:	75 03                	jne    802216 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802213:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802216:	c9                   	leave  
  802217:	c3                   	ret    

00802218 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80221e:	8b 45 08             	mov    0x8(%ebp),%eax
  802221:	e8 c2 ff ff ff       	call   8021e8 <fd2sockid>
  802226:	85 c0                	test   %eax,%eax
  802228:	78 0f                	js     802239 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80222a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80222d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802231:	89 04 24             	mov    %eax,(%esp)
  802234:	e8 47 01 00 00       	call   802380 <nsipc_listen>
}
  802239:	c9                   	leave  
  80223a:	c3                   	ret    

0080223b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802241:	8b 45 08             	mov    0x8(%ebp),%eax
  802244:	e8 9f ff ff ff       	call   8021e8 <fd2sockid>
  802249:	85 c0                	test   %eax,%eax
  80224b:	78 16                	js     802263 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80224d:	8b 55 10             	mov    0x10(%ebp),%edx
  802250:	89 54 24 08          	mov    %edx,0x8(%esp)
  802254:	8b 55 0c             	mov    0xc(%ebp),%edx
  802257:	89 54 24 04          	mov    %edx,0x4(%esp)
  80225b:	89 04 24             	mov    %eax,(%esp)
  80225e:	e8 6e 02 00 00       	call   8024d1 <nsipc_connect>
}
  802263:	c9                   	leave  
  802264:	c3                   	ret    

00802265 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802265:	55                   	push   %ebp
  802266:	89 e5                	mov    %esp,%ebp
  802268:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80226b:	8b 45 08             	mov    0x8(%ebp),%eax
  80226e:	e8 75 ff ff ff       	call   8021e8 <fd2sockid>
  802273:	85 c0                	test   %eax,%eax
  802275:	78 0f                	js     802286 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80227e:	89 04 24             	mov    %eax,(%esp)
  802281:	e8 36 01 00 00       	call   8023bc <nsipc_shutdown>
}
  802286:	c9                   	leave  
  802287:	c3                   	ret    

00802288 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80228e:	8b 45 08             	mov    0x8(%ebp),%eax
  802291:	e8 52 ff ff ff       	call   8021e8 <fd2sockid>
  802296:	85 c0                	test   %eax,%eax
  802298:	78 16                	js     8022b0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80229a:	8b 55 10             	mov    0x10(%ebp),%edx
  80229d:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022a4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022a8:	89 04 24             	mov    %eax,(%esp)
  8022ab:	e8 60 02 00 00       	call   802510 <nsipc_bind>
}
  8022b0:	c9                   	leave  
  8022b1:	c3                   	ret    

008022b2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022b2:	55                   	push   %ebp
  8022b3:	89 e5                	mov    %esp,%ebp
  8022b5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022bb:	e8 28 ff ff ff       	call   8021e8 <fd2sockid>
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	78 1f                	js     8022e3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8022c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8022c7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8022cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d2:	89 04 24             	mov    %eax,(%esp)
  8022d5:	e8 75 02 00 00       	call   80254f <nsipc_accept>
  8022da:	85 c0                	test   %eax,%eax
  8022dc:	78 05                	js     8022e3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8022de:	e8 64 fe ff ff       	call   802147 <alloc_sockfd>
}
  8022e3:	c9                   	leave  
  8022e4:	c3                   	ret    
	...

008022f0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	53                   	push   %ebx
  8022f4:	83 ec 14             	sub    $0x14,%esp
  8022f7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8022f9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802300:	75 11                	jne    802313 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802302:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802309:	e8 a2 02 00 00       	call   8025b0 <ipc_find_env>
  80230e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802313:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80231a:	00 
  80231b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802322:	00 
  802323:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802327:	a1 04 50 80 00       	mov    0x805004,%eax
  80232c:	89 04 24             	mov    %eax,(%esp)
  80232f:	e8 c0 02 00 00       	call   8025f4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802334:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80233b:	00 
  80233c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802343:	00 
  802344:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80234b:	e8 0f 03 00 00       	call   80265f <ipc_recv>
}
  802350:	83 c4 14             	add    $0x14,%esp
  802353:	5b                   	pop    %ebx
  802354:	5d                   	pop    %ebp
  802355:	c3                   	ret    

00802356 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80235c:	8b 45 08             	mov    0x8(%ebp),%eax
  80235f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802364:	8b 45 0c             	mov    0xc(%ebp),%eax
  802367:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80236c:	8b 45 10             	mov    0x10(%ebp),%eax
  80236f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802374:	b8 09 00 00 00       	mov    $0x9,%eax
  802379:	e8 72 ff ff ff       	call   8022f0 <nsipc>
}
  80237e:	c9                   	leave  
  80237f:	c3                   	ret    

00802380 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802386:	8b 45 08             	mov    0x8(%ebp),%eax
  802389:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80238e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802391:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802396:	b8 06 00 00 00       	mov    $0x6,%eax
  80239b:	e8 50 ff ff ff       	call   8022f0 <nsipc>
}
  8023a0:	c9                   	leave  
  8023a1:	c3                   	ret    

008023a2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8023a2:	55                   	push   %ebp
  8023a3:	89 e5                	mov    %esp,%ebp
  8023a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8023a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ab:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8023b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8023b5:	e8 36 ff ff ff       	call   8022f0 <nsipc>
}
  8023ba:	c9                   	leave  
  8023bb:	c3                   	ret    

008023bc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8023bc:	55                   	push   %ebp
  8023bd:	89 e5                	mov    %esp,%ebp
  8023bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8023c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8023ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023cd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8023d2:	b8 03 00 00 00       	mov    $0x3,%eax
  8023d7:	e8 14 ff ff ff       	call   8022f0 <nsipc>
}
  8023dc:	c9                   	leave  
  8023dd:	c3                   	ret    

008023de <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8023de:	55                   	push   %ebp
  8023df:	89 e5                	mov    %esp,%ebp
  8023e1:	53                   	push   %ebx
  8023e2:	83 ec 14             	sub    $0x14,%esp
  8023e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8023e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8023eb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8023f0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8023f6:	7e 24                	jle    80241c <nsipc_send+0x3e>
  8023f8:	c7 44 24 0c b4 2f 80 	movl   $0x802fb4,0xc(%esp)
  8023ff:	00 
  802400:	c7 44 24 08 e9 2e 80 	movl   $0x802ee9,0x8(%esp)
  802407:	00 
  802408:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80240f:	00 
  802410:	c7 04 24 c0 2f 80 00 	movl   $0x802fc0,(%esp)
  802417:	e8 ac dd ff ff       	call   8001c8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80241c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802420:	8b 45 0c             	mov    0xc(%ebp),%eax
  802423:	89 44 24 04          	mov    %eax,0x4(%esp)
  802427:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80242e:	e8 72 e7 ff ff       	call   800ba5 <memmove>
	nsipcbuf.send.req_size = size;
  802433:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802439:	8b 45 14             	mov    0x14(%ebp),%eax
  80243c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802441:	b8 08 00 00 00       	mov    $0x8,%eax
  802446:	e8 a5 fe ff ff       	call   8022f0 <nsipc>
}
  80244b:	83 c4 14             	add    $0x14,%esp
  80244e:	5b                   	pop    %ebx
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    

00802451 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802451:	55                   	push   %ebp
  802452:	89 e5                	mov    %esp,%ebp
  802454:	56                   	push   %esi
  802455:	53                   	push   %ebx
  802456:	83 ec 10             	sub    $0x10,%esp
  802459:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80245c:	8b 45 08             	mov    0x8(%ebp),%eax
  80245f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802464:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80246a:	8b 45 14             	mov    0x14(%ebp),%eax
  80246d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802472:	b8 07 00 00 00       	mov    $0x7,%eax
  802477:	e8 74 fe ff ff       	call   8022f0 <nsipc>
  80247c:	89 c3                	mov    %eax,%ebx
  80247e:	85 c0                	test   %eax,%eax
  802480:	78 46                	js     8024c8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802482:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802487:	7f 04                	jg     80248d <nsipc_recv+0x3c>
  802489:	39 c6                	cmp    %eax,%esi
  80248b:	7d 24                	jge    8024b1 <nsipc_recv+0x60>
  80248d:	c7 44 24 0c cc 2f 80 	movl   $0x802fcc,0xc(%esp)
  802494:	00 
  802495:	c7 44 24 08 e9 2e 80 	movl   $0x802ee9,0x8(%esp)
  80249c:	00 
  80249d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8024a4:	00 
  8024a5:	c7 04 24 c0 2f 80 00 	movl   $0x802fc0,(%esp)
  8024ac:	e8 17 dd ff ff       	call   8001c8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8024b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024b5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8024bc:	00 
  8024bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c0:	89 04 24             	mov    %eax,(%esp)
  8024c3:	e8 dd e6 ff ff       	call   800ba5 <memmove>
	}

	return r;
}
  8024c8:	89 d8                	mov    %ebx,%eax
  8024ca:	83 c4 10             	add    $0x10,%esp
  8024cd:	5b                   	pop    %ebx
  8024ce:	5e                   	pop    %esi
  8024cf:	5d                   	pop    %ebp
  8024d0:	c3                   	ret    

008024d1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8024d1:	55                   	push   %ebp
  8024d2:	89 e5                	mov    %esp,%ebp
  8024d4:	53                   	push   %ebx
  8024d5:	83 ec 14             	sub    $0x14,%esp
  8024d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8024db:	8b 45 08             	mov    0x8(%ebp),%eax
  8024de:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8024e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ee:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8024f5:	e8 ab e6 ff ff       	call   800ba5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8024fa:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802500:	b8 05 00 00 00       	mov    $0x5,%eax
  802505:	e8 e6 fd ff ff       	call   8022f0 <nsipc>
}
  80250a:	83 c4 14             	add    $0x14,%esp
  80250d:	5b                   	pop    %ebx
  80250e:	5d                   	pop    %ebp
  80250f:	c3                   	ret    

00802510 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	53                   	push   %ebx
  802514:	83 ec 14             	sub    $0x14,%esp
  802517:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80251a:	8b 45 08             	mov    0x8(%ebp),%eax
  80251d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802522:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802526:	8b 45 0c             	mov    0xc(%ebp),%eax
  802529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80252d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802534:	e8 6c e6 ff ff       	call   800ba5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802539:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80253f:	b8 02 00 00 00       	mov    $0x2,%eax
  802544:	e8 a7 fd ff ff       	call   8022f0 <nsipc>
}
  802549:	83 c4 14             	add    $0x14,%esp
  80254c:	5b                   	pop    %ebx
  80254d:	5d                   	pop    %ebp
  80254e:	c3                   	ret    

0080254f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	83 ec 18             	sub    $0x18,%esp
  802555:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802558:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80255b:	8b 45 08             	mov    0x8(%ebp),%eax
  80255e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802563:	b8 01 00 00 00       	mov    $0x1,%eax
  802568:	e8 83 fd ff ff       	call   8022f0 <nsipc>
  80256d:	89 c3                	mov    %eax,%ebx
  80256f:	85 c0                	test   %eax,%eax
  802571:	78 25                	js     802598 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802573:	be 10 70 80 00       	mov    $0x807010,%esi
  802578:	8b 06                	mov    (%esi),%eax
  80257a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80257e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802585:	00 
  802586:	8b 45 0c             	mov    0xc(%ebp),%eax
  802589:	89 04 24             	mov    %eax,(%esp)
  80258c:	e8 14 e6 ff ff       	call   800ba5 <memmove>
		*addrlen = ret->ret_addrlen;
  802591:	8b 16                	mov    (%esi),%edx
  802593:	8b 45 10             	mov    0x10(%ebp),%eax
  802596:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802598:	89 d8                	mov    %ebx,%eax
  80259a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80259d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8025a0:	89 ec                	mov    %ebp,%esp
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
	...

008025b0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025b0:	55                   	push   %ebp
  8025b1:	89 e5                	mov    %esp,%ebp
  8025b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8025b6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8025bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8025c1:	39 ca                	cmp    %ecx,%edx
  8025c3:	75 04                	jne    8025c9 <ipc_find_env+0x19>
  8025c5:	b0 00                	mov    $0x0,%al
  8025c7:	eb 0f                	jmp    8025d8 <ipc_find_env+0x28>
  8025c9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025cc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8025d2:	8b 12                	mov    (%edx),%edx
  8025d4:	39 ca                	cmp    %ecx,%edx
  8025d6:	75 0c                	jne    8025e4 <ipc_find_env+0x34>
			return envs[i].env_id;
  8025d8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025db:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8025e0:	8b 00                	mov    (%eax),%eax
  8025e2:	eb 0e                	jmp    8025f2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025e4:	83 c0 01             	add    $0x1,%eax
  8025e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025ec:	75 db                	jne    8025c9 <ipc_find_env+0x19>
  8025ee:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    

008025f4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025f4:	55                   	push   %ebp
  8025f5:	89 e5                	mov    %esp,%ebp
  8025f7:	57                   	push   %edi
  8025f8:	56                   	push   %esi
  8025f9:	53                   	push   %ebx
  8025fa:	83 ec 1c             	sub    $0x1c,%esp
  8025fd:	8b 75 08             	mov    0x8(%ebp),%esi
  802600:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802603:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802606:	85 db                	test   %ebx,%ebx
  802608:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80260d:	0f 44 d8             	cmove  %eax,%ebx
  802610:	eb 25                	jmp    802637 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  802612:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802615:	74 20                	je     802637 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  802617:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80261b:	c7 44 24 08 e1 2f 80 	movl   $0x802fe1,0x8(%esp)
  802622:	00 
  802623:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80262a:	00 
  80262b:	c7 04 24 ff 2f 80 00 	movl   $0x802fff,(%esp)
  802632:	e8 91 db ff ff       	call   8001c8 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  802637:	8b 45 14             	mov    0x14(%ebp),%eax
  80263a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80263e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802646:	89 34 24             	mov    %esi,(%esp)
  802649:	e8 80 e8 ff ff       	call   800ece <sys_ipc_try_send>
  80264e:	85 c0                	test   %eax,%eax
  802650:	75 c0                	jne    802612 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802652:	e8 fd e9 ff ff       	call   801054 <sys_yield>
}
  802657:	83 c4 1c             	add    $0x1c,%esp
  80265a:	5b                   	pop    %ebx
  80265b:	5e                   	pop    %esi
  80265c:	5f                   	pop    %edi
  80265d:	5d                   	pop    %ebp
  80265e:	c3                   	ret    

0080265f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80265f:	55                   	push   %ebp
  802660:	89 e5                	mov    %esp,%ebp
  802662:	83 ec 28             	sub    $0x28,%esp
  802665:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802668:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80266b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80266e:	8b 75 08             	mov    0x8(%ebp),%esi
  802671:	8b 45 0c             	mov    0xc(%ebp),%eax
  802674:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802677:	85 c0                	test   %eax,%eax
  802679:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80267e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802681:	89 04 24             	mov    %eax,(%esp)
  802684:	e8 0c e8 ff ff       	call   800e95 <sys_ipc_recv>
  802689:	89 c3                	mov    %eax,%ebx
  80268b:	85 c0                	test   %eax,%eax
  80268d:	79 2a                	jns    8026b9 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80268f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802693:	89 44 24 04          	mov    %eax,0x4(%esp)
  802697:	c7 04 24 09 30 80 00 	movl   $0x803009,(%esp)
  80269e:	e8 de db ff ff       	call   800281 <cprintf>
		if(from_env_store != NULL)
  8026a3:	85 f6                	test   %esi,%esi
  8026a5:	74 06                	je     8026ad <ipc_recv+0x4e>
			*from_env_store = 0;
  8026a7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8026ad:	85 ff                	test   %edi,%edi
  8026af:	74 2c                	je     8026dd <ipc_recv+0x7e>
			*perm_store = 0;
  8026b1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8026b7:	eb 24                	jmp    8026dd <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8026b9:	85 f6                	test   %esi,%esi
  8026bb:	74 0a                	je     8026c7 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8026bd:	a1 08 50 80 00       	mov    0x805008,%eax
  8026c2:	8b 40 74             	mov    0x74(%eax),%eax
  8026c5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8026c7:	85 ff                	test   %edi,%edi
  8026c9:	74 0a                	je     8026d5 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8026cb:	a1 08 50 80 00       	mov    0x805008,%eax
  8026d0:	8b 40 78             	mov    0x78(%eax),%eax
  8026d3:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8026d5:	a1 08 50 80 00       	mov    0x805008,%eax
  8026da:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8026dd:	89 d8                	mov    %ebx,%eax
  8026df:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8026e2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8026e5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8026e8:	89 ec                	mov    %ebp,%esp
  8026ea:	5d                   	pop    %ebp
  8026eb:	c3                   	ret    

008026ec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8026ec:	55                   	push   %ebp
  8026ed:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8026ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f2:	89 c2                	mov    %eax,%edx
  8026f4:	c1 ea 16             	shr    $0x16,%edx
  8026f7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8026fe:	f6 c2 01             	test   $0x1,%dl
  802701:	74 20                	je     802723 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802703:	c1 e8 0c             	shr    $0xc,%eax
  802706:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80270d:	a8 01                	test   $0x1,%al
  80270f:	74 12                	je     802723 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802711:	c1 e8 0c             	shr    $0xc,%eax
  802714:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802719:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80271e:	0f b7 c0             	movzwl %ax,%eax
  802721:	eb 05                	jmp    802728 <pageref+0x3c>
  802723:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802728:	5d                   	pop    %ebp
  802729:	c3                   	ret    
  80272a:	00 00                	add    %al,(%eax)
  80272c:	00 00                	add    %al,(%eax)
	...

00802730 <__udivdi3>:
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	57                   	push   %edi
  802734:	56                   	push   %esi
  802735:	83 ec 10             	sub    $0x10,%esp
  802738:	8b 45 14             	mov    0x14(%ebp),%eax
  80273b:	8b 55 08             	mov    0x8(%ebp),%edx
  80273e:	8b 75 10             	mov    0x10(%ebp),%esi
  802741:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802744:	85 c0                	test   %eax,%eax
  802746:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802749:	75 35                	jne    802780 <__udivdi3+0x50>
  80274b:	39 fe                	cmp    %edi,%esi
  80274d:	77 61                	ja     8027b0 <__udivdi3+0x80>
  80274f:	85 f6                	test   %esi,%esi
  802751:	75 0b                	jne    80275e <__udivdi3+0x2e>
  802753:	b8 01 00 00 00       	mov    $0x1,%eax
  802758:	31 d2                	xor    %edx,%edx
  80275a:	f7 f6                	div    %esi
  80275c:	89 c6                	mov    %eax,%esi
  80275e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802761:	31 d2                	xor    %edx,%edx
  802763:	89 f8                	mov    %edi,%eax
  802765:	f7 f6                	div    %esi
  802767:	89 c7                	mov    %eax,%edi
  802769:	89 c8                	mov    %ecx,%eax
  80276b:	f7 f6                	div    %esi
  80276d:	89 c1                	mov    %eax,%ecx
  80276f:	89 fa                	mov    %edi,%edx
  802771:	89 c8                	mov    %ecx,%eax
  802773:	83 c4 10             	add    $0x10,%esp
  802776:	5e                   	pop    %esi
  802777:	5f                   	pop    %edi
  802778:	5d                   	pop    %ebp
  802779:	c3                   	ret    
  80277a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802780:	39 f8                	cmp    %edi,%eax
  802782:	77 1c                	ja     8027a0 <__udivdi3+0x70>
  802784:	0f bd d0             	bsr    %eax,%edx
  802787:	83 f2 1f             	xor    $0x1f,%edx
  80278a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80278d:	75 39                	jne    8027c8 <__udivdi3+0x98>
  80278f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802792:	0f 86 a0 00 00 00    	jbe    802838 <__udivdi3+0x108>
  802798:	39 f8                	cmp    %edi,%eax
  80279a:	0f 82 98 00 00 00    	jb     802838 <__udivdi3+0x108>
  8027a0:	31 ff                	xor    %edi,%edi
  8027a2:	31 c9                	xor    %ecx,%ecx
  8027a4:	89 c8                	mov    %ecx,%eax
  8027a6:	89 fa                	mov    %edi,%edx
  8027a8:	83 c4 10             	add    $0x10,%esp
  8027ab:	5e                   	pop    %esi
  8027ac:	5f                   	pop    %edi
  8027ad:	5d                   	pop    %ebp
  8027ae:	c3                   	ret    
  8027af:	90                   	nop
  8027b0:	89 d1                	mov    %edx,%ecx
  8027b2:	89 fa                	mov    %edi,%edx
  8027b4:	89 c8                	mov    %ecx,%eax
  8027b6:	31 ff                	xor    %edi,%edi
  8027b8:	f7 f6                	div    %esi
  8027ba:	89 c1                	mov    %eax,%ecx
  8027bc:	89 fa                	mov    %edi,%edx
  8027be:	89 c8                	mov    %ecx,%eax
  8027c0:	83 c4 10             	add    $0x10,%esp
  8027c3:	5e                   	pop    %esi
  8027c4:	5f                   	pop    %edi
  8027c5:	5d                   	pop    %ebp
  8027c6:	c3                   	ret    
  8027c7:	90                   	nop
  8027c8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027cc:	89 f2                	mov    %esi,%edx
  8027ce:	d3 e0                	shl    %cl,%eax
  8027d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8027d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8027db:	89 c1                	mov    %eax,%ecx
  8027dd:	d3 ea                	shr    %cl,%edx
  8027df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027e3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8027e6:	d3 e6                	shl    %cl,%esi
  8027e8:	89 c1                	mov    %eax,%ecx
  8027ea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8027ed:	89 fe                	mov    %edi,%esi
  8027ef:	d3 ee                	shr    %cl,%esi
  8027f1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8027fb:	d3 e7                	shl    %cl,%edi
  8027fd:	89 c1                	mov    %eax,%ecx
  8027ff:	d3 ea                	shr    %cl,%edx
  802801:	09 d7                	or     %edx,%edi
  802803:	89 f2                	mov    %esi,%edx
  802805:	89 f8                	mov    %edi,%eax
  802807:	f7 75 ec             	divl   -0x14(%ebp)
  80280a:	89 d6                	mov    %edx,%esi
  80280c:	89 c7                	mov    %eax,%edi
  80280e:	f7 65 e8             	mull   -0x18(%ebp)
  802811:	39 d6                	cmp    %edx,%esi
  802813:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802816:	72 30                	jb     802848 <__udivdi3+0x118>
  802818:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80281b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80281f:	d3 e2                	shl    %cl,%edx
  802821:	39 c2                	cmp    %eax,%edx
  802823:	73 05                	jae    80282a <__udivdi3+0xfa>
  802825:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802828:	74 1e                	je     802848 <__udivdi3+0x118>
  80282a:	89 f9                	mov    %edi,%ecx
  80282c:	31 ff                	xor    %edi,%edi
  80282e:	e9 71 ff ff ff       	jmp    8027a4 <__udivdi3+0x74>
  802833:	90                   	nop
  802834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802838:	31 ff                	xor    %edi,%edi
  80283a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80283f:	e9 60 ff ff ff       	jmp    8027a4 <__udivdi3+0x74>
  802844:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802848:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80284b:	31 ff                	xor    %edi,%edi
  80284d:	89 c8                	mov    %ecx,%eax
  80284f:	89 fa                	mov    %edi,%edx
  802851:	83 c4 10             	add    $0x10,%esp
  802854:	5e                   	pop    %esi
  802855:	5f                   	pop    %edi
  802856:	5d                   	pop    %ebp
  802857:	c3                   	ret    
	...

00802860 <__umoddi3>:
  802860:	55                   	push   %ebp
  802861:	89 e5                	mov    %esp,%ebp
  802863:	57                   	push   %edi
  802864:	56                   	push   %esi
  802865:	83 ec 20             	sub    $0x20,%esp
  802868:	8b 55 14             	mov    0x14(%ebp),%edx
  80286b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80286e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802871:	8b 75 0c             	mov    0xc(%ebp),%esi
  802874:	85 d2                	test   %edx,%edx
  802876:	89 c8                	mov    %ecx,%eax
  802878:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80287b:	75 13                	jne    802890 <__umoddi3+0x30>
  80287d:	39 f7                	cmp    %esi,%edi
  80287f:	76 3f                	jbe    8028c0 <__umoddi3+0x60>
  802881:	89 f2                	mov    %esi,%edx
  802883:	f7 f7                	div    %edi
  802885:	89 d0                	mov    %edx,%eax
  802887:	31 d2                	xor    %edx,%edx
  802889:	83 c4 20             	add    $0x20,%esp
  80288c:	5e                   	pop    %esi
  80288d:	5f                   	pop    %edi
  80288e:	5d                   	pop    %ebp
  80288f:	c3                   	ret    
  802890:	39 f2                	cmp    %esi,%edx
  802892:	77 4c                	ja     8028e0 <__umoddi3+0x80>
  802894:	0f bd ca             	bsr    %edx,%ecx
  802897:	83 f1 1f             	xor    $0x1f,%ecx
  80289a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80289d:	75 51                	jne    8028f0 <__umoddi3+0x90>
  80289f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8028a2:	0f 87 e0 00 00 00    	ja     802988 <__umoddi3+0x128>
  8028a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028ab:	29 f8                	sub    %edi,%eax
  8028ad:	19 d6                	sbb    %edx,%esi
  8028af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8028b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028b5:	89 f2                	mov    %esi,%edx
  8028b7:	83 c4 20             	add    $0x20,%esp
  8028ba:	5e                   	pop    %esi
  8028bb:	5f                   	pop    %edi
  8028bc:	5d                   	pop    %ebp
  8028bd:	c3                   	ret    
  8028be:	66 90                	xchg   %ax,%ax
  8028c0:	85 ff                	test   %edi,%edi
  8028c2:	75 0b                	jne    8028cf <__umoddi3+0x6f>
  8028c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028c9:	31 d2                	xor    %edx,%edx
  8028cb:	f7 f7                	div    %edi
  8028cd:	89 c7                	mov    %eax,%edi
  8028cf:	89 f0                	mov    %esi,%eax
  8028d1:	31 d2                	xor    %edx,%edx
  8028d3:	f7 f7                	div    %edi
  8028d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028d8:	f7 f7                	div    %edi
  8028da:	eb a9                	jmp    802885 <__umoddi3+0x25>
  8028dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028e0:	89 c8                	mov    %ecx,%eax
  8028e2:	89 f2                	mov    %esi,%edx
  8028e4:	83 c4 20             	add    $0x20,%esp
  8028e7:	5e                   	pop    %esi
  8028e8:	5f                   	pop    %edi
  8028e9:	5d                   	pop    %ebp
  8028ea:	c3                   	ret    
  8028eb:	90                   	nop
  8028ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8028f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8028f4:	d3 e2                	shl    %cl,%edx
  8028f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8028f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8028fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802901:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802904:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802908:	89 fa                	mov    %edi,%edx
  80290a:	d3 ea                	shr    %cl,%edx
  80290c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802910:	0b 55 f4             	or     -0xc(%ebp),%edx
  802913:	d3 e7                	shl    %cl,%edi
  802915:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802919:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80291c:	89 f2                	mov    %esi,%edx
  80291e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802921:	89 c7                	mov    %eax,%edi
  802923:	d3 ea                	shr    %cl,%edx
  802925:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802929:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80292c:	89 c2                	mov    %eax,%edx
  80292e:	d3 e6                	shl    %cl,%esi
  802930:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802934:	d3 ea                	shr    %cl,%edx
  802936:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80293a:	09 d6                	or     %edx,%esi
  80293c:	89 f0                	mov    %esi,%eax
  80293e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802941:	d3 e7                	shl    %cl,%edi
  802943:	89 f2                	mov    %esi,%edx
  802945:	f7 75 f4             	divl   -0xc(%ebp)
  802948:	89 d6                	mov    %edx,%esi
  80294a:	f7 65 e8             	mull   -0x18(%ebp)
  80294d:	39 d6                	cmp    %edx,%esi
  80294f:	72 2b                	jb     80297c <__umoddi3+0x11c>
  802951:	39 c7                	cmp    %eax,%edi
  802953:	72 23                	jb     802978 <__umoddi3+0x118>
  802955:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802959:	29 c7                	sub    %eax,%edi
  80295b:	19 d6                	sbb    %edx,%esi
  80295d:	89 f0                	mov    %esi,%eax
  80295f:	89 f2                	mov    %esi,%edx
  802961:	d3 ef                	shr    %cl,%edi
  802963:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802967:	d3 e0                	shl    %cl,%eax
  802969:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80296d:	09 f8                	or     %edi,%eax
  80296f:	d3 ea                	shr    %cl,%edx
  802971:	83 c4 20             	add    $0x20,%esp
  802974:	5e                   	pop    %esi
  802975:	5f                   	pop    %edi
  802976:	5d                   	pop    %ebp
  802977:	c3                   	ret    
  802978:	39 d6                	cmp    %edx,%esi
  80297a:	75 d9                	jne    802955 <__umoddi3+0xf5>
  80297c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80297f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802982:	eb d1                	jmp    802955 <__umoddi3+0xf5>
  802984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802988:	39 f2                	cmp    %esi,%edx
  80298a:	0f 82 18 ff ff ff    	jb     8028a8 <__umoddi3+0x48>
  802990:	e9 1d ff ff ff       	jmp    8028b2 <__umoddi3+0x52>
