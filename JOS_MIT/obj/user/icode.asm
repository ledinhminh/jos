
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
  80003f:	c7 05 00 30 80 00 00 	movl   $0x802400,0x803000
  800046:	24 80 00 

	cprintf("icode startup\n");
  800049:	c7 04 24 06 24 80 00 	movl   $0x802406,(%esp)
  800050:	e8 2c 02 00 00       	call   800281 <cprintf>

	cprintf("icode: open /motd\n");
  800055:	c7 04 24 15 24 80 00 	movl   $0x802415,(%esp)
  80005c:	e8 20 02 00 00       	call   800281 <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0) {
  800061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800068:	00 
  800069:	c7 04 24 28 24 80 00 	movl   $0x802428,(%esp)
  800070:	e8 ff 18 00 00       	call   801974 <open>
  800075:	89 c6                	mov    %eax,%esi
  800077:	85 c0                	test   %eax,%eax
  800079:	79 20                	jns    80009b <umain+0x67>
		panic("icode: open /motd: %e", fd);
  80007b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80007f:	c7 44 24 08 2e 24 80 	movl   $0x80242e,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  80008e:	00 
  80008f:	c7 04 24 44 24 80 00 	movl   $0x802444,(%esp)
  800096:	e8 2d 01 00 00       	call   8001c8 <_panic>
  }
	cprintf("icode: read /motd\n");
  80009b:	c7 04 24 51 24 80 00 	movl   $0x802451,(%esp)
  8000a2:	e8 da 01 00 00       	call   800281 <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000a7:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  8000ad:	eb 0c                	jmp    8000bb <umain+0x87>
		sys_cputs(buf, n);
  8000af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b3:	89 1c 24             	mov    %ebx,(%esp)
  8000b6:	e8 48 10 00 00       	call   801103 <sys_cputs>
	cprintf("icode: open /motd\n");
	if ((fd = open("/motd", O_RDONLY)) < 0) {
		panic("icode: open /motd: %e", fd);
  }
	cprintf("icode: read /motd\n");
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000bb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8000c2:	00 
  8000c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000c7:	89 34 24             	mov    %esi,(%esp)
  8000ca:	e8 74 13 00 00       	call   801443 <read>
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	7f dc                	jg     8000af <umain+0x7b>
		sys_cputs(buf, n);

	cprintf("icode: close /motd\n");
  8000d3:	c7 04 24 64 24 80 00 	movl   $0x802464,(%esp)
  8000da:	e8 a2 01 00 00       	call   800281 <cprintf>
	close(fd);
  8000df:	89 34 24             	mov    %esi,(%esp)
  8000e2:	e8 c5 14 00 00       	call   8015ac <close>

	cprintf("icode: spawn /init\n");
  8000e7:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  8000ee:	e8 8e 01 00 00       	call   800281 <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0) {
  8000f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 0c 8c 24 80 	movl   $0x80248c,0xc(%esp)
  800102:	00 
  800103:	c7 44 24 08 95 24 80 	movl   $0x802495,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 9f 24 80 	movl   $0x80249f,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 9e 24 80 00 	movl   $0x80249e,(%esp)
  80011a:	e8 80 1e 00 00       	call   801f9f <spawnl>
  80011f:	85 c0                	test   %eax,%eax
  800121:	79 20                	jns    800143 <umain+0x10f>
		panic("icode: spawn /init: %e", r);
  800123:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800127:	c7 44 24 08 a4 24 80 	movl   $0x8024a4,0x8(%esp)
  80012e:	00 
  80012f:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800136:	00 
  800137:	c7 04 24 44 24 80 00 	movl   $0x802444,(%esp)
  80013e:	e8 85 00 00 00       	call   8001c8 <_panic>
  }
	cprintf("icode: exiting\n");
  800143:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
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
  80016e:	e8 e1 0e 00 00       	call   801054 <sys_getenvid>
  800173:	25 ff 03 00 00       	and    $0x3ff,%eax
  800178:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80017b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800180:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800185:	85 f6                	test   %esi,%esi
  800187:	7e 07                	jle    800190 <libmain+0x34>
		binaryname = argv[0];
  800189:	8b 03                	mov    (%ebx),%eax
  80018b:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8001b2:	e8 72 14 00 00       	call   801629 <close_all>
	sys_env_destroy(0);
  8001b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001be:	e8 cc 0e 00 00       	call   80108f <sys_env_destroy>
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
  8001d3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001d9:	e8 76 0e 00 00       	call   801054 <sys_getenvid>
  8001de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 d8 24 80 00 	movl   $0x8024d8,(%esp)
  8001fb:	e8 81 00 00 00       	call   800281 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	89 74 24 04          	mov    %esi,0x4(%esp)
  800204:	8b 45 10             	mov    0x10(%ebp),%eax
  800207:	89 04 24             	mov    %eax,(%esp)
  80020a:	e8 11 00 00 00       	call   800220 <vcprintf>
	cprintf("\n");
  80020f:	c7 04 24 62 24 80 00 	movl   $0x802462,(%esp)
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
  800274:	e8 8a 0e 00 00       	call   801103 <sys_cputs>

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
  8002c8:	e8 36 0e 00 00       	call   801103 <sys_cputs>
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
  80035d:	e8 1e 1e 00 00       	call   802180 <__udivdi3>
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
  8003b8:	e8 f3 1e 00 00       	call   8022b0 <__umoddi3>
  8003bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c1:	0f be 80 fb 24 80 00 	movsbl 0x8024fb(%eax),%eax
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
  8004a5:	ff 24 95 e0 26 80 00 	jmp    *0x8026e0(,%edx,4)
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
  800578:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	75 20                	jne    8005a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800583:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800587:	c7 44 24 08 0c 25 80 	movl   $0x80250c,0x8(%esp)
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
  8005a7:	c7 44 24 08 57 29 80 	movl   $0x802957,0x8(%esp)
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
  8005e1:	b8 15 25 80 00       	mov    $0x802515,%eax
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
  800825:	c7 44 24 0c 30 26 80 	movl   $0x802630,0xc(%esp)
  80082c:	00 
  80082d:	c7 44 24 08 57 29 80 	movl   $0x802957,0x8(%esp)
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
  800853:	c7 44 24 0c 68 26 80 	movl   $0x802668,0xc(%esp)
  80085a:	00 
  80085b:	c7 44 24 08 57 29 80 	movl   $0x802957,0x8(%esp)
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
  800df7:	c7 44 24 08 80 28 80 	movl   $0x802880,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 9d 28 80 00 	movl   $0x80289d,(%esp)
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

00800e22 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e28:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e2f:	00 
  800e30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e37:	00 
  800e38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e3f:	00 
  800e40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4a:	ba 01 00 00 00       	mov    $0x1,%edx
  800e4f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e54:	e8 53 ff ff ff       	call   800dac <syscall>
}
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e61:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e68:	00 
  800e69:	8b 45 14             	mov    0x14(%ebp),%eax
  800e6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e70:	8b 45 10             	mov    0x10(%ebp),%eax
  800e73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	89 04 24             	mov    %eax,(%esp)
  800e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e80:	ba 00 00 00 00       	mov    $0x0,%edx
  800e85:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e8a:	e8 1d ff ff ff       	call   800dac <syscall>
}
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eae:	00 
  800eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb2:	89 04 24             	mov    %eax,(%esp)
  800eb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb8:	ba 01 00 00 00       	mov    $0x1,%edx
  800ebd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec2:	e8 e5 fe ff ff       	call   800dac <syscall>
}
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ecf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ede:	00 
  800edf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee6:	00 
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	89 04 24             	mov    %eax,(%esp)
  800eed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efa:	e8 ad fe ff ff       	call   800dac <syscall>
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f16:	00 
  800f17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f1e:	00 
  800f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f22:	89 04 24             	mov    %eax,(%esp)
  800f25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f28:	ba 01 00 00 00       	mov    $0x1,%edx
  800f2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800f32:	e8 75 fe ff ff       	call   800dac <syscall>
}
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f3f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f46:	00 
  800f47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f4e:	00 
  800f4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f56:	00 
  800f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5a:	89 04 24             	mov    %eax,(%esp)
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	ba 01 00 00 00       	mov    $0x1,%edx
  800f65:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6a:	e8 3d fe ff ff       	call   800dac <syscall>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7e:	00 
  800f7f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f82:	0b 45 14             	or     0x14(%ebp),%eax
  800f85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f89:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f93:	89 04 24             	mov    %eax,(%esp)
  800f96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f99:	ba 01 00 00 00       	mov    $0x1,%edx
  800f9e:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa3:	e8 04 fe ff ff       	call   800dac <syscall>
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fb0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbf:	00 
  800fc0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fca:	89 04 24             	mov    %eax,(%esp)
  800fcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800fd5:	b8 05 00 00 00       	mov    $0x5,%eax
  800fda:	e8 cd fd ff ff       	call   800dac <syscall>
}
  800fdf:	c9                   	leave  
  800fe0:	c3                   	ret    

00800fe1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fe7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fee:	00 
  800fef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ffe:	00 
  800fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801006:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100b:	ba 00 00 00 00       	mov    $0x0,%edx
  801010:	b8 0c 00 00 00       	mov    $0xc,%eax
  801015:	e8 92 fd ff ff       	call   800dac <syscall>
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801022:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801029:	00 
  80102a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801031:	00 
  801032:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801039:	00 
  80103a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80103d:	89 04 24             	mov    %eax,(%esp)
  801040:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801043:	ba 00 00 00 00       	mov    $0x0,%edx
  801048:	b8 04 00 00 00       	mov    $0x4,%eax
  80104d:	e8 5a fd ff ff       	call   800dac <syscall>
}
  801052:	c9                   	leave  
  801053:	c3                   	ret    

00801054 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80105a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801061:	00 
  801062:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801069:	00 
  80106a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801071:	00 
  801072:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801079:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107e:	ba 00 00 00 00       	mov    $0x0,%edx
  801083:	b8 02 00 00 00       	mov    $0x2,%eax
  801088:	e8 1f fd ff ff       	call   800dac <syscall>
}
  80108d:	c9                   	leave  
  80108e:	c3                   	ret    

0080108f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80108f:	55                   	push   %ebp
  801090:	89 e5                	mov    %esp,%ebp
  801092:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801095:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80109c:	00 
  80109d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ac:	00 
  8010ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b7:	ba 01 00 00 00       	mov    $0x1,%edx
  8010bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c1:	e8 e6 fc ff ff       	call   800dac <syscall>
}
  8010c6:	c9                   	leave  
  8010c7:	c3                   	ret    

008010c8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d5:	00 
  8010d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010dd:	00 
  8010de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e5:	00 
  8010e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010fc:	e8 ab fc ff ff       	call   800dac <syscall>
}
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801109:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801110:	00 
  801111:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801118:	00 
  801119:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801120:	00 
  801121:	8b 45 0c             	mov    0xc(%ebp),%eax
  801124:	89 04 24             	mov    %eax,(%esp)
  801127:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112a:	ba 00 00 00 00       	mov    $0x0,%edx
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
  801134:	e8 73 fc ff ff       	call   800dac <syscall>
}
  801139:	c9                   	leave  
  80113a:	c3                   	ret    
  80113b:	00 00                	add    %al,(%eax)
  80113d:	00 00                	add    %al,(%eax)
	...

00801140 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	8b 45 08             	mov    0x8(%ebp),%eax
  801146:	05 00 00 00 30       	add    $0x30000000,%eax
  80114b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    

00801150 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	89 04 24             	mov    %eax,(%esp)
  80115c:	e8 df ff ff ff       	call   801140 <fd2num>
  801161:	05 20 00 0d 00       	add    $0xd0020,%eax
  801166:	c1 e0 0c             	shl    $0xc,%eax
}
  801169:	c9                   	leave  
  80116a:	c3                   	ret    

0080116b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80116b:	55                   	push   %ebp
  80116c:	89 e5                	mov    %esp,%ebp
  80116e:	57                   	push   %edi
  80116f:	56                   	push   %esi
  801170:	53                   	push   %ebx
  801171:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801174:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801179:	a8 01                	test   $0x1,%al
  80117b:	74 36                	je     8011b3 <fd_alloc+0x48>
  80117d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801182:	a8 01                	test   $0x1,%al
  801184:	74 2d                	je     8011b3 <fd_alloc+0x48>
  801186:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80118b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801190:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801195:	89 c3                	mov    %eax,%ebx
  801197:	89 c2                	mov    %eax,%edx
  801199:	c1 ea 16             	shr    $0x16,%edx
  80119c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80119f:	f6 c2 01             	test   $0x1,%dl
  8011a2:	74 14                	je     8011b8 <fd_alloc+0x4d>
  8011a4:	89 c2                	mov    %eax,%edx
  8011a6:	c1 ea 0c             	shr    $0xc,%edx
  8011a9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8011ac:	f6 c2 01             	test   $0x1,%dl
  8011af:	75 10                	jne    8011c1 <fd_alloc+0x56>
  8011b1:	eb 05                	jmp    8011b8 <fd_alloc+0x4d>
  8011b3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8011b8:	89 1f                	mov    %ebx,(%edi)
  8011ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8011bf:	eb 17                	jmp    8011d8 <fd_alloc+0x6d>
  8011c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011cb:	75 c8                	jne    801195 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8011d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	83 f8 1f             	cmp    $0x1f,%eax
  8011e6:	77 36                	ja     80121e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011ed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8011f0:	89 c2                	mov    %eax,%edx
  8011f2:	c1 ea 16             	shr    $0x16,%edx
  8011f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011fc:	f6 c2 01             	test   $0x1,%dl
  8011ff:	74 1d                	je     80121e <fd_lookup+0x41>
  801201:	89 c2                	mov    %eax,%edx
  801203:	c1 ea 0c             	shr    $0xc,%edx
  801206:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120d:	f6 c2 01             	test   $0x1,%dl
  801210:	74 0c                	je     80121e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801212:	8b 55 0c             	mov    0xc(%ebp),%edx
  801215:	89 02                	mov    %eax,(%edx)
  801217:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80121c:	eb 05                	jmp    801223 <fd_lookup+0x46>
  80121e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80122e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801232:	8b 45 08             	mov    0x8(%ebp),%eax
  801235:	89 04 24             	mov    %eax,(%esp)
  801238:	e8 a0 ff ff ff       	call   8011dd <fd_lookup>
  80123d:	85 c0                	test   %eax,%eax
  80123f:	78 0e                	js     80124f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801241:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801244:	8b 55 0c             	mov    0xc(%ebp),%edx
  801247:	89 50 04             	mov    %edx,0x4(%eax)
  80124a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80124f:	c9                   	leave  
  801250:	c3                   	ret    

00801251 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
  801256:	83 ec 10             	sub    $0x10,%esp
  801259:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80125f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801264:	b8 04 30 80 00       	mov    $0x803004,%eax
  801269:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80126f:	75 11                	jne    801282 <dev_lookup+0x31>
  801271:	eb 04                	jmp    801277 <dev_lookup+0x26>
  801273:	39 08                	cmp    %ecx,(%eax)
  801275:	75 10                	jne    801287 <dev_lookup+0x36>
			*dev = devtab[i];
  801277:	89 03                	mov    %eax,(%ebx)
  801279:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80127e:	66 90                	xchg   %ax,%ax
  801280:	eb 36                	jmp    8012b8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801282:	be 28 29 80 00       	mov    $0x802928,%esi
  801287:	83 c2 01             	add    $0x1,%edx
  80128a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80128d:	85 c0                	test   %eax,%eax
  80128f:	75 e2                	jne    801273 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801291:	a1 04 40 80 00       	mov    0x804004,%eax
  801296:	8b 40 48             	mov    0x48(%eax),%eax
  801299:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80129d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a1:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
  8012a8:	e8 d4 ef ff ff       	call   800281 <cprintf>
	*dev = 0;
  8012ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    

008012bf <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8012bf:	55                   	push   %ebp
  8012c0:	89 e5                	mov    %esp,%ebp
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 24             	sub    $0x24,%esp
  8012c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	89 04 24             	mov    %eax,(%esp)
  8012d6:	e8 02 ff ff ff       	call   8011dd <fd_lookup>
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 53                	js     801332 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	8b 00                	mov    (%eax),%eax
  8012eb:	89 04 24             	mov    %eax,(%esp)
  8012ee:	e8 5e ff ff ff       	call   801251 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 3b                	js     801332 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8012f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ff:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801303:	74 2d                	je     801332 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801305:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801308:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80130f:	00 00 00 
	stat->st_isdir = 0;
  801312:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801319:	00 00 00 
	stat->st_dev = dev;
  80131c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801325:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801329:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80132c:	89 14 24             	mov    %edx,(%esp)
  80132f:	ff 50 14             	call   *0x14(%eax)
}
  801332:	83 c4 24             	add    $0x24,%esp
  801335:	5b                   	pop    %ebx
  801336:	5d                   	pop    %ebp
  801337:	c3                   	ret    

00801338 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	53                   	push   %ebx
  80133c:	83 ec 24             	sub    $0x24,%esp
  80133f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801342:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801345:	89 44 24 04          	mov    %eax,0x4(%esp)
  801349:	89 1c 24             	mov    %ebx,(%esp)
  80134c:	e8 8c fe ff ff       	call   8011dd <fd_lookup>
  801351:	85 c0                	test   %eax,%eax
  801353:	78 5f                	js     8013b4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135f:	8b 00                	mov    (%eax),%eax
  801361:	89 04 24             	mov    %eax,(%esp)
  801364:	e8 e8 fe ff ff       	call   801251 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 47                	js     8013b4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801370:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801374:	75 23                	jne    801399 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801376:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80137b:	8b 40 48             	mov    0x48(%eax),%eax
  80137e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	c7 04 24 cc 28 80 00 	movl   $0x8028cc,(%esp)
  80138d:	e8 ef ee ff ff       	call   800281 <cprintf>
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801397:	eb 1b                	jmp    8013b4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139c:	8b 48 18             	mov    0x18(%eax),%ecx
  80139f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a4:	85 c9                	test   %ecx,%ecx
  8013a6:	74 0c                	je     8013b4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013af:	89 14 24             	mov    %edx,(%esp)
  8013b2:	ff d1                	call   *%ecx
}
  8013b4:	83 c4 24             	add    $0x24,%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5d                   	pop    %ebp
  8013b9:	c3                   	ret    

008013ba <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013ba:	55                   	push   %ebp
  8013bb:	89 e5                	mov    %esp,%ebp
  8013bd:	53                   	push   %ebx
  8013be:	83 ec 24             	sub    $0x24,%esp
  8013c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013cb:	89 1c 24             	mov    %ebx,(%esp)
  8013ce:	e8 0a fe ff ff       	call   8011dd <fd_lookup>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 66                	js     80143d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e1:	8b 00                	mov    (%eax),%eax
  8013e3:	89 04 24             	mov    %eax,(%esp)
  8013e6:	e8 66 fe ff ff       	call   801251 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	78 4e                	js     80143d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013f2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8013f6:	75 23                	jne    80141b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8013fd:	8b 40 48             	mov    0x48(%eax),%eax
  801400:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	c7 04 24 ed 28 80 00 	movl   $0x8028ed,(%esp)
  80140f:	e8 6d ee ff ff       	call   800281 <cprintf>
  801414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801419:	eb 22                	jmp    80143d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80141b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80141e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801421:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801426:	85 c9                	test   %ecx,%ecx
  801428:	74 13                	je     80143d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80142a:	8b 45 10             	mov    0x10(%ebp),%eax
  80142d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801431:	8b 45 0c             	mov    0xc(%ebp),%eax
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	89 14 24             	mov    %edx,(%esp)
  80143b:	ff d1                	call   *%ecx
}
  80143d:	83 c4 24             	add    $0x24,%esp
  801440:	5b                   	pop    %ebx
  801441:	5d                   	pop    %ebp
  801442:	c3                   	ret    

00801443 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	53                   	push   %ebx
  801447:	83 ec 24             	sub    $0x24,%esp
  80144a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80144d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801450:	89 44 24 04          	mov    %eax,0x4(%esp)
  801454:	89 1c 24             	mov    %ebx,(%esp)
  801457:	e8 81 fd ff ff       	call   8011dd <fd_lookup>
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 6b                	js     8014cb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801460:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801463:	89 44 24 04          	mov    %eax,0x4(%esp)
  801467:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146a:	8b 00                	mov    (%eax),%eax
  80146c:	89 04 24             	mov    %eax,(%esp)
  80146f:	e8 dd fd ff ff       	call   801251 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801474:	85 c0                	test   %eax,%eax
  801476:	78 53                	js     8014cb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801478:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80147b:	8b 42 08             	mov    0x8(%edx),%eax
  80147e:	83 e0 03             	and    $0x3,%eax
  801481:	83 f8 01             	cmp    $0x1,%eax
  801484:	75 23                	jne    8014a9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801486:	a1 04 40 80 00       	mov    0x804004,%eax
  80148b:	8b 40 48             	mov    0x48(%eax),%eax
  80148e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801492:	89 44 24 04          	mov    %eax,0x4(%esp)
  801496:	c7 04 24 0a 29 80 00 	movl   $0x80290a,(%esp)
  80149d:	e8 df ed ff ff       	call   800281 <cprintf>
  8014a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014a7:	eb 22                	jmp    8014cb <read+0x88>
	}
	if (!dev->dev_read)
  8014a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ac:	8b 48 08             	mov    0x8(%eax),%ecx
  8014af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b4:	85 c9                	test   %ecx,%ecx
  8014b6:	74 13                	je     8014cb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8014bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c6:	89 14 24             	mov    %edx,(%esp)
  8014c9:	ff d1                	call   *%ecx
}
  8014cb:	83 c4 24             	add    $0x24,%esp
  8014ce:	5b                   	pop    %ebx
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    

008014d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	57                   	push   %edi
  8014d5:	56                   	push   %esi
  8014d6:	53                   	push   %ebx
  8014d7:	83 ec 1c             	sub    $0x1c,%esp
  8014da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8014ef:	85 f6                	test   %esi,%esi
  8014f1:	74 29                	je     80151c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014f3:	89 f0                	mov    %esi,%eax
  8014f5:	29 d0                	sub    %edx,%eax
  8014f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014fb:	03 55 0c             	add    0xc(%ebp),%edx
  8014fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801502:	89 3c 24             	mov    %edi,(%esp)
  801505:	e8 39 ff ff ff       	call   801443 <read>
		if (m < 0)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 0e                	js     80151c <readn+0x4b>
			return m;
		if (m == 0)
  80150e:	85 c0                	test   %eax,%eax
  801510:	74 08                	je     80151a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801512:	01 c3                	add    %eax,%ebx
  801514:	89 da                	mov    %ebx,%edx
  801516:	39 f3                	cmp    %esi,%ebx
  801518:	72 d9                	jb     8014f3 <readn+0x22>
  80151a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80151c:	83 c4 1c             	add    $0x1c,%esp
  80151f:	5b                   	pop    %ebx
  801520:	5e                   	pop    %esi
  801521:	5f                   	pop    %edi
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    

00801524 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	83 ec 28             	sub    $0x28,%esp
  80152a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80152d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801530:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801533:	89 34 24             	mov    %esi,(%esp)
  801536:	e8 05 fc ff ff       	call   801140 <fd2num>
  80153b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80153e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801542:	89 04 24             	mov    %eax,(%esp)
  801545:	e8 93 fc ff ff       	call   8011dd <fd_lookup>
  80154a:	89 c3                	mov    %eax,%ebx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 05                	js     801555 <fd_close+0x31>
  801550:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801553:	74 0e                	je     801563 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801555:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801559:	b8 00 00 00 00       	mov    $0x0,%eax
  80155e:	0f 44 d8             	cmove  %eax,%ebx
  801561:	eb 3d                	jmp    8015a0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801563:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801566:	89 44 24 04          	mov    %eax,0x4(%esp)
  80156a:	8b 06                	mov    (%esi),%eax
  80156c:	89 04 24             	mov    %eax,(%esp)
  80156f:	e8 dd fc ff ff       	call   801251 <dev_lookup>
  801574:	89 c3                	mov    %eax,%ebx
  801576:	85 c0                	test   %eax,%eax
  801578:	78 16                	js     801590 <fd_close+0x6c>
		if (dev->dev_close)
  80157a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157d:	8b 40 10             	mov    0x10(%eax),%eax
  801580:	bb 00 00 00 00       	mov    $0x0,%ebx
  801585:	85 c0                	test   %eax,%eax
  801587:	74 07                	je     801590 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801589:	89 34 24             	mov    %esi,(%esp)
  80158c:	ff d0                	call   *%eax
  80158e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801590:	89 74 24 04          	mov    %esi,0x4(%esp)
  801594:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159b:	e8 99 f9 ff ff       	call   800f39 <sys_page_unmap>
	return r;
}
  8015a0:	89 d8                	mov    %ebx,%eax
  8015a2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015a5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015a8:	89 ec                	mov    %ebp,%esp
  8015aa:	5d                   	pop    %ebp
  8015ab:	c3                   	ret    

008015ac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015bc:	89 04 24             	mov    %eax,(%esp)
  8015bf:	e8 19 fc ff ff       	call   8011dd <fd_lookup>
  8015c4:	85 c0                	test   %eax,%eax
  8015c6:	78 13                	js     8015db <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015cf:	00 
  8015d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d3:	89 04 24             	mov    %eax,(%esp)
  8015d6:	e8 49 ff ff ff       	call   801524 <fd_close>
}
  8015db:	c9                   	leave  
  8015dc:	c3                   	ret    

008015dd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8015dd:	55                   	push   %ebp
  8015de:	89 e5                	mov    %esp,%ebp
  8015e0:	83 ec 18             	sub    $0x18,%esp
  8015e3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015e6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015f0:	00 
  8015f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f4:	89 04 24             	mov    %eax,(%esp)
  8015f7:	e8 78 03 00 00       	call   801974 <open>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	85 c0                	test   %eax,%eax
  801600:	78 1b                	js     80161d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801602:	8b 45 0c             	mov    0xc(%ebp),%eax
  801605:	89 44 24 04          	mov    %eax,0x4(%esp)
  801609:	89 1c 24             	mov    %ebx,(%esp)
  80160c:	e8 ae fc ff ff       	call   8012bf <fstat>
  801611:	89 c6                	mov    %eax,%esi
	close(fd);
  801613:	89 1c 24             	mov    %ebx,(%esp)
  801616:	e8 91 ff ff ff       	call   8015ac <close>
  80161b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80161d:	89 d8                	mov    %ebx,%eax
  80161f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801622:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801625:	89 ec                	mov    %ebp,%esp
  801627:	5d                   	pop    %ebp
  801628:	c3                   	ret    

00801629 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	53                   	push   %ebx
  80162d:	83 ec 14             	sub    $0x14,%esp
  801630:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801635:	89 1c 24             	mov    %ebx,(%esp)
  801638:	e8 6f ff ff ff       	call   8015ac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80163d:	83 c3 01             	add    $0x1,%ebx
  801640:	83 fb 20             	cmp    $0x20,%ebx
  801643:	75 f0                	jne    801635 <close_all+0xc>
		close(i);
}
  801645:	83 c4 14             	add    $0x14,%esp
  801648:	5b                   	pop    %ebx
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 58             	sub    $0x58,%esp
  801651:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801654:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801657:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80165a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80165d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801660:	89 44 24 04          	mov    %eax,0x4(%esp)
  801664:	8b 45 08             	mov    0x8(%ebp),%eax
  801667:	89 04 24             	mov    %eax,(%esp)
  80166a:	e8 6e fb ff ff       	call   8011dd <fd_lookup>
  80166f:	89 c3                	mov    %eax,%ebx
  801671:	85 c0                	test   %eax,%eax
  801673:	0f 88 e0 00 00 00    	js     801759 <dup+0x10e>
		return r;
	close(newfdnum);
  801679:	89 3c 24             	mov    %edi,(%esp)
  80167c:	e8 2b ff ff ff       	call   8015ac <close>

	newfd = INDEX2FD(newfdnum);
  801681:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801687:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80168a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80168d:	89 04 24             	mov    %eax,(%esp)
  801690:	e8 bb fa ff ff       	call   801150 <fd2data>
  801695:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801697:	89 34 24             	mov    %esi,(%esp)
  80169a:	e8 b1 fa ff ff       	call   801150 <fd2data>
  80169f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8016a2:	89 da                	mov    %ebx,%edx
  8016a4:	89 d8                	mov    %ebx,%eax
  8016a6:	c1 e8 16             	shr    $0x16,%eax
  8016a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016b0:	a8 01                	test   $0x1,%al
  8016b2:	74 43                	je     8016f7 <dup+0xac>
  8016b4:	c1 ea 0c             	shr    $0xc,%edx
  8016b7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016be:	a8 01                	test   $0x1,%al
  8016c0:	74 35                	je     8016f7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016c2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016e0:	00 
  8016e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ec:	e8 80 f8 ff ff       	call   800f71 <sys_page_map>
  8016f1:	89 c3                	mov    %eax,%ebx
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 3f                	js     801736 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	c1 ea 0c             	shr    $0xc,%edx
  8016ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801706:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80170c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801710:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801714:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80171b:	00 
  80171c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801720:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801727:	e8 45 f8 ff ff       	call   800f71 <sys_page_map>
  80172c:	89 c3                	mov    %eax,%ebx
  80172e:	85 c0                	test   %eax,%eax
  801730:	78 04                	js     801736 <dup+0xeb>
  801732:	89 fb                	mov    %edi,%ebx
  801734:	eb 23                	jmp    801759 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801736:	89 74 24 04          	mov    %esi,0x4(%esp)
  80173a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801741:	e8 f3 f7 ff ff       	call   800f39 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801746:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801749:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801754:	e8 e0 f7 ff ff       	call   800f39 <sys_page_unmap>
	return r;
}
  801759:	89 d8                	mov    %ebx,%eax
  80175b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80175e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801761:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801764:	89 ec                	mov    %ebp,%esp
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    

00801768 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	83 ec 18             	sub    $0x18,%esp
  80176e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801771:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801774:	89 c3                	mov    %eax,%ebx
  801776:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801778:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177f:	75 11                	jne    801792 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801781:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801788:	e8 a3 08 00 00       	call   802030 <ipc_find_env>
  80178d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801792:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801799:	00 
  80179a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017a1:	00 
  8017a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017a6:	a1 00 40 80 00       	mov    0x804000,%eax
  8017ab:	89 04 24             	mov    %eax,(%esp)
  8017ae:	e8 c1 08 00 00       	call   802074 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ba:	00 
  8017bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c6:	e8 18 09 00 00       	call   8020e3 <ipc_recv>
}
  8017cb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017ce:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017d1:	89 ec                	mov    %ebp,%esp
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017db:	8b 45 08             	mov    0x8(%ebp),%eax
  8017de:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f8:	e8 6b ff ff ff       	call   801768 <fsipc>
}
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	8b 40 0c             	mov    0xc(%eax),%eax
  80180b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801810:	ba 00 00 00 00       	mov    $0x0,%edx
  801815:	b8 06 00 00 00       	mov    $0x6,%eax
  80181a:	e8 49 ff ff ff       	call   801768 <fsipc>
}
  80181f:	c9                   	leave  
  801820:	c3                   	ret    

00801821 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	b8 08 00 00 00       	mov    $0x8,%eax
  801831:	e8 32 ff ff ff       	call   801768 <fsipc>
}
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	53                   	push   %ebx
  80183c:	83 ec 14             	sub    $0x14,%esp
  80183f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	8b 40 0c             	mov    0xc(%eax),%eax
  801848:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80184d:	ba 00 00 00 00       	mov    $0x0,%edx
  801852:	b8 05 00 00 00       	mov    $0x5,%eax
  801857:	e8 0c ff ff ff       	call   801768 <fsipc>
  80185c:	85 c0                	test   %eax,%eax
  80185e:	78 2b                	js     80188b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801860:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801867:	00 
  801868:	89 1c 24             	mov    %ebx,(%esp)
  80186b:	e8 4a f1 ff ff       	call   8009ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801870:	a1 80 50 80 00       	mov    0x805080,%eax
  801875:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80187b:	a1 84 50 80 00       	mov    0x805084,%eax
  801880:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801886:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80188b:	83 c4 14             	add    $0x14,%esp
  80188e:	5b                   	pop    %ebx
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 18             	sub    $0x18,%esp
  801897:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80189a:	8b 55 08             	mov    0x8(%ebp),%edx
  80189d:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  8018a6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  8018ab:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018b0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018b5:	0f 47 c2             	cmova  %edx,%eax
  8018b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8018ca:	e8 d6 f2 ff ff       	call   800ba5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8018cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8018d9:	e8 8a fe ff ff       	call   801768 <fsipc>
}
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8018f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018f5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801904:	e8 5f fe ff ff       	call   801768 <fsipc>
  801909:	89 c3                	mov    %eax,%ebx
  80190b:	85 c0                	test   %eax,%eax
  80190d:	78 17                	js     801926 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801913:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80191a:	00 
  80191b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80191e:	89 04 24             	mov    %eax,(%esp)
  801921:	e8 7f f2 ff ff       	call   800ba5 <memmove>
  return r;	
}
  801926:	89 d8                	mov    %ebx,%eax
  801928:	83 c4 14             	add    $0x14,%esp
  80192b:	5b                   	pop    %ebx
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	53                   	push   %ebx
  801932:	83 ec 14             	sub    $0x14,%esp
  801935:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801938:	89 1c 24             	mov    %ebx,(%esp)
  80193b:	e8 30 f0 ff ff       	call   800970 <strlen>
  801940:	89 c2                	mov    %eax,%edx
  801942:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801947:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80194d:	7f 1f                	jg     80196e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80194f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801953:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80195a:	e8 5b f0 ff ff       	call   8009ba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80195f:	ba 00 00 00 00       	mov    $0x0,%edx
  801964:	b8 07 00 00 00       	mov    $0x7,%eax
  801969:	e8 fa fd ff ff       	call   801768 <fsipc>
}
  80196e:	83 c4 14             	add    $0x14,%esp
  801971:	5b                   	pop    %ebx
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	83 ec 28             	sub    $0x28,%esp
  80197a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80197d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801980:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801983:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801986:	89 04 24             	mov    %eax,(%esp)
  801989:	e8 dd f7 ff ff       	call   80116b <fd_alloc>
  80198e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801990:	85 c0                	test   %eax,%eax
  801992:	0f 88 89 00 00 00    	js     801a21 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801998:	89 34 24             	mov    %esi,(%esp)
  80199b:	e8 d0 ef ff ff       	call   800970 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8019a0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8019a5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019aa:	7f 75                	jg     801a21 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8019ac:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019b0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019b7:	e8 fe ef ff ff       	call   8009ba <strcpy>
  fsipcbuf.open.req_omode = mode;
  8019bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  8019c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019cc:	e8 97 fd ff ff       	call   801768 <fsipc>
  8019d1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 0f                	js     8019e6 <open+0x72>
  return fd2num(fd);
  8019d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019da:	89 04 24             	mov    %eax,(%esp)
  8019dd:	e8 5e f7 ff ff       	call   801140 <fd2num>
  8019e2:	89 c3                	mov    %eax,%ebx
  8019e4:	eb 3b                	jmp    801a21 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8019e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ed:	00 
  8019ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f1:	89 04 24             	mov    %eax,(%esp)
  8019f4:	e8 2b fb ff ff       	call   801524 <fd_close>
  8019f9:	85 c0                	test   %eax,%eax
  8019fb:	74 24                	je     801a21 <open+0xad>
  8019fd:	c7 44 24 0c 30 29 80 	movl   $0x802930,0xc(%esp)
  801a04:	00 
  801a05:	c7 44 24 08 45 29 80 	movl   $0x802945,0x8(%esp)
  801a0c:	00 
  801a0d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801a14:	00 
  801a15:	c7 04 24 5a 29 80 00 	movl   $0x80295a,(%esp)
  801a1c:	e8 a7 e7 ff ff       	call   8001c8 <_panic>
  return r;
}
  801a21:	89 d8                	mov    %ebx,%eax
  801a23:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a26:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a29:	89 ec                	mov    %ebp,%esp
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    
  801a2d:	00 00                	add    %al,(%eax)
	...

00801a30 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	81 ec 9c 02 00 00    	sub    $0x29c,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801a3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a43:	00 
  801a44:	8b 45 08             	mov    0x8(%ebp),%eax
  801a47:	89 04 24             	mov    %eax,(%esp)
  801a4a:	e8 25 ff ff ff       	call   801974 <open>
  801a4f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  801a55:	89 c3                	mov    %eax,%ebx
  801a57:	85 c0                	test   %eax,%eax
  801a59:	0f 88 33 05 00 00    	js     801f92 <.after_sysenter_label+0x4b9>
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
	    || elf->e_magic != ELF_MAGIC) {
  801a5f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  801a66:	00 
  801a67:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a71:	89 1c 24             	mov    %ebx,(%esp)
  801a74:	e8 58 fa ff ff       	call   8014d1 <readn>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801a79:	3d 00 02 00 00       	cmp    $0x200,%eax
  801a7e:	75 0c                	jne    801a8c <spawn+0x5c>
	    || elf->e_magic != ELF_MAGIC) {
  801a80:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a87:	45 4c 46 
  801a8a:	74 36                	je     801ac2 <spawn+0x92>
		close(fd);
  801a8c:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a92:	89 04 24             	mov    %eax,(%esp)
  801a95:	e8 12 fb ff ff       	call   8015ac <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a9a:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  801aa1:	46 
  801aa2:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aac:	c7 04 24 65 29 80 00 	movl   $0x802965,(%esp)
  801ab3:	e8 c9 e7 ff ff       	call   800281 <cprintf>
  801ab8:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
		return -E_NOT_EXEC;
  801abd:	e9 d0 04 00 00       	jmp    801f92 <.after_sysenter_label+0x4b9>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801ac2:	ba 08 00 00 00       	mov    $0x8,%edx
  801ac7:	89 d0                	mov    %edx,%eax
  801ac9:	51                   	push   %ecx
  801aca:	52                   	push   %edx
  801acb:	53                   	push   %ebx
  801acc:	55                   	push   %ebp
  801acd:	56                   	push   %esi
  801ace:	57                   	push   %edi
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	8d 35 d9 1a 80 00    	lea    0x801ad9,%esi
  801ad7:	0f 34                	sysenter 

00801ad9 <.after_sysenter_label>:
  801ad9:	5f                   	pop    %edi
  801ada:	5e                   	pop    %esi
  801adb:	5d                   	pop    %ebp
  801adc:	5b                   	pop    %ebx
  801add:	5a                   	pop    %edx
  801ade:	59                   	pop    %ecx
  801adf:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	0f 88 9f 04 00 00    	js     801f8c <.after_sysenter_label+0x4b3>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801aed:	89 c6                	mov    %eax,%esi
  801aef:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801af5:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801af8:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801afe:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801b04:	b9 11 00 00 00       	mov    $0x11,%ecx
  801b09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801b0b:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801b11:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1a:	8b 02                	mov    (%edx),%eax
  801b1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b21:	be 00 00 00 00       	mov    $0x0,%esi
  801b26:	85 c0                	test   %eax,%eax
  801b28:	75 16                	jne    801b40 <.after_sysenter_label+0x67>
  801b2a:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801b31:	00 00 00 
  801b34:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b3b:	00 00 00 
  801b3e:	eb 2c                	jmp    801b6c <.after_sysenter_label+0x93>
  801b40:	8b 7d 0c             	mov    0xc(%ebp),%edi
		string_size += strlen(argv[argc]) + 1;
  801b43:	89 04 24             	mov    %eax,(%esp)
  801b46:	e8 25 ee ff ff       	call   800970 <strlen>
  801b4b:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801b4f:	83 c6 01             	add    $0x1,%esi
  801b52:	8d 14 b5 00 00 00 00 	lea    0x0(,%esi,4),%edx
  801b59:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	75 e3                	jne    801b43 <.after_sysenter_label+0x6a>
  801b60:	89 95 7c fd ff ff    	mov    %edx,-0x284(%ebp)
  801b66:	89 b5 78 fd ff ff    	mov    %esi,-0x288(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801b6c:	f7 db                	neg    %ebx
  801b6e:	8d bb 00 10 40 00    	lea    0x401000(%ebx),%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801b74:	89 fa                	mov    %edi,%edx
  801b76:	83 e2 fc             	and    $0xfffffffc,%edx
  801b79:	89 f0                	mov    %esi,%eax
  801b7b:	f7 d0                	not    %eax
  801b7d:	8d 04 82             	lea    (%edx,%eax,4),%eax
  801b80:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b86:	83 e8 08             	sub    $0x8,%eax
  801b89:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801b8f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801b94:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801b99:	0f 86 f3 03 00 00    	jbe    801f92 <.after_sysenter_label+0x4b9>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b9f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ba6:	00 
  801ba7:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801bae:	00 
  801baf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb6:	e8 ef f3 ff ff       	call   800faa <sys_page_alloc>
  801bbb:	89 c3                	mov    %eax,%ebx
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 cd 03 00 00    	js     801f92 <.after_sysenter_label+0x4b9>
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801bc5:	85 f6                	test   %esi,%esi
  801bc7:	7e 46                	jle    801c0f <.after_sysenter_label+0x136>
  801bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bce:	89 b5 8c fd ff ff    	mov    %esi,-0x274(%ebp)
  801bd4:	8b 75 0c             	mov    0xc(%ebp),%esi
		argv_store[i] = UTEMP2USTACK(string_store);
  801bd7:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801bdd:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801be3:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  801be6:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bed:	89 3c 24             	mov    %edi,(%esp)
  801bf0:	e8 c5 ed ff ff       	call   8009ba <strcpy>
		string_store += strlen(argv[i]) + 1;
  801bf5:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801bf8:	89 04 24             	mov    %eax,(%esp)
  801bfb:	e8 70 ed ff ff       	call   800970 <strlen>
  801c00:	8d 7c 38 01          	lea    0x1(%eax,%edi,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801c04:	83 c3 01             	add    $0x1,%ebx
  801c07:	3b 9d 8c fd ff ff    	cmp    -0x274(%ebp),%ebx
  801c0d:	7c c8                	jl     801bd7 <.after_sysenter_label+0xfe>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801c0f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c15:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c1b:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801c22:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801c28:	74 24                	je     801c4e <.after_sysenter_label+0x175>
  801c2a:	c7 44 24 0c dc 29 80 	movl   $0x8029dc,0xc(%esp)
  801c31:	00 
  801c32:	c7 44 24 08 45 29 80 	movl   $0x802945,0x8(%esp)
  801c39:	00 
  801c3a:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
  801c41:	00 
  801c42:	c7 04 24 7f 29 80 00 	movl   $0x80297f,(%esp)
  801c49:	e8 7a e5 ff ff       	call   8001c8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801c4e:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c54:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801c59:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801c5f:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801c62:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
  801c68:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c6e:	89 10                	mov    %edx,(%eax)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801c70:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801c76:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801c7b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801c81:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801c88:	00 
  801c89:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  801c90:	ee 
  801c91:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801c97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9b:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ca2:	00 
  801ca3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801caa:	e8 c2 f2 ff ff       	call   800f71 <sys_page_map>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	78 1a                	js     801ccf <.after_sysenter_label+0x1f6>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801cb5:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cbc:	00 
  801cbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc4:	e8 70 f2 ff ff       	call   800f39 <sys_page_unmap>
  801cc9:	89 c3                	mov    %eax,%ebx
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	79 19                	jns    801ce8 <.after_sysenter_label+0x20f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ccf:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801cd6:	00 
  801cd7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cde:	e8 56 f2 ff ff       	call   800f39 <sys_page_unmap>
  801ce3:	e9 aa 02 00 00       	jmp    801f92 <.after_sysenter_label+0x4b9>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ce8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cee:	66 83 bd 14 fe ff ff 	cmpw   $0x0,-0x1ec(%ebp)
  801cf5:	00 
  801cf6:	0f 84 e4 01 00 00    	je     801ee0 <.after_sysenter_label+0x407>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801cfc:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801d03:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
  801d09:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801d10:	00 00 00 
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
  801d13:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801d19:	83 3a 01             	cmpl   $0x1,(%edx)
  801d1c:	0f 85 9c 01 00 00    	jne    801ebe <.after_sysenter_label+0x3e5>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801d22:	8b 42 18             	mov    0x18(%edx),%eax
  801d25:	83 e0 02             	and    $0x2,%eax
  801d28:	83 f8 01             	cmp    $0x1,%eax
  801d2b:	19 c0                	sbb    %eax,%eax
  801d2d:	83 e0 fe             	and    $0xfffffffe,%eax
  801d30:	83 c0 07             	add    $0x7,%eax
  801d33:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801d39:	8b 52 04             	mov    0x4(%edx),%edx
  801d3c:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  801d42:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801d48:	8b 58 10             	mov    0x10(%eax),%ebx
  801d4b:	8b 50 14             	mov    0x14(%eax),%edx
  801d4e:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  801d54:	8b 40 08             	mov    0x8(%eax),%eax
  801d57:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801d5d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801d62:	74 16                	je     801d7a <.after_sysenter_label+0x2a1>
		va -= i;
  801d64:	29 85 90 fd ff ff    	sub    %eax,-0x270(%ebp)
		memsz += i;
  801d6a:	01 c2                	add    %eax,%edx
  801d6c:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801d72:	01 c3                	add    %eax,%ebx
		fileoffset -= i;
  801d74:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d7a:	83 bd 8c fd ff ff 00 	cmpl   $0x0,-0x274(%ebp)
  801d81:	0f 84 37 01 00 00    	je     801ebe <.after_sysenter_label+0x3e5>
  801d87:	bf 00 00 00 00       	mov    $0x0,%edi
  801d8c:	be 00 00 00 00       	mov    $0x0,%esi
		if (i >= filesz) {
  801d91:	39 fb                	cmp    %edi,%ebx
  801d93:	77 31                	ja     801dc6 <.after_sysenter_label+0x2ed>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801d95:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801d9b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d9f:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801da5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801da9:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801daf:	89 04 24             	mov    %eax,(%esp)
  801db2:	e8 f3 f1 ff ff       	call   800faa <sys_page_alloc>
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 89 eb 00 00 00    	jns    801eaa <.after_sysenter_label+0x3d1>
  801dbf:	89 c3                	mov    %eax,%ebx
  801dc1:	e9 a8 01 00 00       	jmp    801f6e <.after_sysenter_label+0x495>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801dc6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801dcd:	00 
  801dce:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801dd5:	00 
  801dd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ddd:	e8 c8 f1 ff ff       	call   800faa <sys_page_alloc>
  801de2:	85 c0                	test   %eax,%eax
  801de4:	0f 88 7a 01 00 00    	js     801f64 <.after_sysenter_label+0x48b>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801dea:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801df0:	8d 04 06             	lea    (%esi,%eax,1),%eax
  801df3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df7:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801dfd:	89 14 24             	mov    %edx,(%esp)
  801e00:	e8 20 f4 ff ff       	call   801225 <seek>
  801e05:	85 c0                	test   %eax,%eax
  801e07:	0f 88 5b 01 00 00    	js     801f68 <.after_sysenter_label+0x48f>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801e0d:	89 d8                	mov    %ebx,%eax
  801e0f:	29 f8                	sub    %edi,%eax
  801e11:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801e16:	ba 00 10 00 00       	mov    $0x1000,%edx
  801e1b:	0f 47 c2             	cmova  %edx,%eax
  801e1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e22:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e29:	00 
  801e2a:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801e30:	89 04 24             	mov    %eax,(%esp)
  801e33:	e8 99 f6 ff ff       	call   8014d1 <readn>
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	0f 88 2c 01 00 00    	js     801f6c <.after_sysenter_label+0x493>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801e40:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801e46:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e4a:	03 bd 90 fd ff ff    	add    -0x270(%ebp),%edi
  801e50:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e54:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801e5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e5e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e65:	00 
  801e66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6d:	e8 ff f0 ff ff       	call   800f71 <sys_page_map>
  801e72:	85 c0                	test   %eax,%eax
  801e74:	79 20                	jns    801e96 <.after_sysenter_label+0x3bd>
				panic("spawn: sys_page_map data: %e", r);
  801e76:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e7a:	c7 44 24 08 8b 29 80 	movl   $0x80298b,0x8(%esp)
  801e81:	00 
  801e82:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  801e89:	00 
  801e8a:	c7 04 24 7f 29 80 00 	movl   $0x80297f,(%esp)
  801e91:	e8 32 e3 ff ff       	call   8001c8 <_panic>
			sys_page_unmap(0, UTEMP);
  801e96:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801e9d:	00 
  801e9e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea5:	e8 8f f0 ff ff       	call   800f39 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801eaa:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801eb0:	89 f7                	mov    %esi,%edi
  801eb2:	39 b5 8c fd ff ff    	cmp    %esi,-0x274(%ebp)
  801eb8:	0f 87 d3 fe ff ff    	ja     801d91 <.after_sysenter_label+0x2b8>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ebe:	83 85 7c fd ff ff 01 	addl   $0x1,-0x284(%ebp)
  801ec5:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801ecc:	3b 85 7c fd ff ff    	cmp    -0x284(%ebp),%eax
  801ed2:	7e 0c                	jle    801ee0 <.after_sysenter_label+0x407>
  801ed4:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801edb:	e9 33 fe ff ff       	jmp    801d13 <.after_sysenter_label+0x23a>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801ee0:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801ee6:	89 14 24             	mov    %edx,(%esp)
  801ee9:	e8 be f6 ff ff       	call   8015ac <close>
	fd = -1;

  //Problem here!
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801eee:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ef8:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801efe:	89 04 24             	mov    %eax,(%esp)
  801f01:	e8 c3 ef ff ff       	call   800ec9 <sys_env_set_trapframe>
  801f06:	85 c0                	test   %eax,%eax
  801f08:	79 20                	jns    801f2a <.after_sysenter_label+0x451>
		panic("sys_env_set_trapframe: %e", r);
  801f0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0e:	c7 44 24 08 a8 29 80 	movl   $0x8029a8,0x8(%esp)
  801f15:	00 
  801f16:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  801f1d:	00 
  801f1e:	c7 04 24 7f 29 80 00 	movl   $0x80297f,(%esp)
  801f25:	e8 9e e2 ff ff       	call   8001c8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801f2a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801f31:	00 
  801f32:	8b 95 84 fd ff ff    	mov    -0x27c(%ebp),%edx
  801f38:	89 14 24             	mov    %edx,(%esp)
  801f3b:	e8 c1 ef ff ff       	call   800f01 <sys_env_set_status>
  801f40:	85 c0                	test   %eax,%eax
  801f42:	79 48                	jns    801f8c <.after_sysenter_label+0x4b3>
		panic("sys_env_set_status: %e", r);
  801f44:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f48:	c7 44 24 08 c2 29 80 	movl   $0x8029c2,0x8(%esp)
  801f4f:	00 
  801f50:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801f57:	00 
  801f58:	c7 04 24 7f 29 80 00 	movl   $0x80297f,(%esp)
  801f5f:	e8 64 e2 ff ff       	call   8001c8 <_panic>
  801f64:	89 c3                	mov    %eax,%ebx
  801f66:	eb 06                	jmp    801f6e <.after_sysenter_label+0x495>
  801f68:	89 c3                	mov    %eax,%ebx
  801f6a:	eb 02                	jmp    801f6e <.after_sysenter_label+0x495>
  801f6c:	89 c3                	mov    %eax,%ebx

	return child;

error:
	sys_env_destroy(child);
  801f6e:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801f74:	89 04 24             	mov    %eax,(%esp)
  801f77:	e8 13 f1 ff ff       	call   80108f <sys_env_destroy>
	close(fd);
  801f7c:	8b 95 88 fd ff ff    	mov    -0x278(%ebp),%edx
  801f82:	89 14 24             	mov    %edx,(%esp)
  801f85:	e8 22 f6 ff ff       	call   8015ac <close>
	return r;
  801f8a:	eb 06                	jmp    801f92 <.after_sysenter_label+0x4b9>
  801f8c:	8b 9d 84 fd ff ff    	mov    -0x27c(%ebp),%ebx
}
  801f92:	89 d8                	mov    %ebx,%eax
  801f94:	81 c4 9c 02 00 00    	add    $0x29c,%esp
  801f9a:	5b                   	pop    %ebx
  801f9b:	5e                   	pop    %esi
  801f9c:	5f                   	pop    %edi
  801f9d:	5d                   	pop    %ebp
  801f9e:	c3                   	ret    

00801f9f <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f9f:	55                   	push   %ebp
  801fa0:	89 e5                	mov    %esp,%ebp
  801fa2:	56                   	push   %esi
  801fa3:	53                   	push   %ebx
  801fa4:	83 ec 10             	sub    $0x10,%esp
  801fa7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  801faa:	8d 55 10             	lea    0x10(%ebp),%edx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fad:	83 3a 00             	cmpl   $0x0,(%edx)
  801fb0:	74 5d                	je     80200f <spawnl+0x70>
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
		argc++;
  801fb7:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801fba:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  801fbe:	75 f7                	jne    801fb7 <spawnl+0x18>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801fc0:	8d 14 85 26 00 00 00 	lea    0x26(,%eax,4),%edx
  801fc7:	83 e2 f0             	and    $0xfffffff0,%edx
  801fca:	29 d4                	sub    %edx,%esp
  801fcc:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  801fd0:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  801fd3:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  801fd5:	c7 44 81 04 00 00 00 	movl   $0x0,0x4(%ecx,%eax,4)
  801fdc:	00 

// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
  801fdd:	8d 75 10             	lea    0x10(%ebp),%esi
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801fe0:	89 c3                	mov    %eax,%ebx
  801fe2:	85 c0                	test   %eax,%eax
  801fe4:	74 13                	je     801ff9 <spawnl+0x5a>
  801fe6:	b8 00 00 00 00       	mov    $0x0,%eax
		argv[i+1] = va_arg(vl, const char *);
  801feb:	83 c0 01             	add    $0x1,%eax
  801fee:	8b 54 86 fc          	mov    -0x4(%esi,%eax,4),%edx
  801ff2:	89 14 81             	mov    %edx,(%ecx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ff5:	39 d8                	cmp    %ebx,%eax
  801ff7:	72 f2                	jb     801feb <spawnl+0x4c>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801ff9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  802000:	89 04 24             	mov    %eax,(%esp)
  802003:	e8 28 fa ff ff       	call   801a30 <spawn>
}
  802008:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80200b:	5b                   	pop    %ebx
  80200c:	5e                   	pop    %esi
  80200d:	5d                   	pop    %ebp
  80200e:	c3                   	ret    
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  80200f:	83 ec 20             	sub    $0x20,%esp
  802012:	8d 4c 24 17          	lea    0x17(%esp),%ecx
  802016:	83 e1 f0             	and    $0xfffffff0,%ecx
	argv[0] = arg0;
  802019:	89 19                	mov    %ebx,(%ecx)
	argv[argc+1] = NULL;
  80201b:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
  802022:	eb d5                	jmp    801ff9 <spawnl+0x5a>
	...

00802030 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802036:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80203c:	b8 01 00 00 00       	mov    $0x1,%eax
  802041:	39 ca                	cmp    %ecx,%edx
  802043:	75 04                	jne    802049 <ipc_find_env+0x19>
  802045:	b0 00                	mov    $0x0,%al
  802047:	eb 0f                	jmp    802058 <ipc_find_env+0x28>
  802049:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80204c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802052:	8b 12                	mov    (%edx),%edx
  802054:	39 ca                	cmp    %ecx,%edx
  802056:	75 0c                	jne    802064 <ipc_find_env+0x34>
			return envs[i].env_id;
  802058:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80205b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  802060:	8b 00                	mov    (%eax),%eax
  802062:	eb 0e                	jmp    802072 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802064:	83 c0 01             	add    $0x1,%eax
  802067:	3d 00 04 00 00       	cmp    $0x400,%eax
  80206c:	75 db                	jne    802049 <ipc_find_env+0x19>
  80206e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	57                   	push   %edi
  802078:	56                   	push   %esi
  802079:	53                   	push   %ebx
  80207a:	83 ec 1c             	sub    $0x1c,%esp
  80207d:	8b 75 08             	mov    0x8(%ebp),%esi
  802080:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802083:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802086:	85 db                	test   %ebx,%ebx
  802088:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80208d:	0f 44 d8             	cmove  %eax,%ebx
  802090:	eb 29                	jmp    8020bb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  802092:	85 c0                	test   %eax,%eax
  802094:	79 25                	jns    8020bb <ipc_send+0x47>
  802096:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802099:	74 20                	je     8020bb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  80209b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80209f:	c7 44 24 08 04 2a 80 	movl   $0x802a04,0x8(%esp)
  8020a6:	00 
  8020a7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8020ae:	00 
  8020af:	c7 04 24 22 2a 80 00 	movl   $0x802a22,(%esp)
  8020b6:	e8 0d e1 ff ff       	call   8001c8 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8020bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8020be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020ca:	89 34 24             	mov    %esi,(%esp)
  8020cd:	e8 89 ed ff ff       	call   800e5b <sys_ipc_try_send>
  8020d2:	85 c0                	test   %eax,%eax
  8020d4:	75 bc                	jne    802092 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8020d6:	e8 06 ef ff ff       	call   800fe1 <sys_yield>
}
  8020db:	83 c4 1c             	add    $0x1c,%esp
  8020de:	5b                   	pop    %ebx
  8020df:	5e                   	pop    %esi
  8020e0:	5f                   	pop    %edi
  8020e1:	5d                   	pop    %ebp
  8020e2:	c3                   	ret    

008020e3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020e3:	55                   	push   %ebp
  8020e4:	89 e5                	mov    %esp,%ebp
  8020e6:	83 ec 28             	sub    $0x28,%esp
  8020e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8020ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8020f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8020f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802102:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802105:	89 04 24             	mov    %eax,(%esp)
  802108:	e8 15 ed ff ff       	call   800e22 <sys_ipc_recv>
  80210d:	89 c3                	mov    %eax,%ebx
  80210f:	85 c0                	test   %eax,%eax
  802111:	79 2a                	jns    80213d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802113:	89 44 24 08          	mov    %eax,0x8(%esp)
  802117:	89 44 24 04          	mov    %eax,0x4(%esp)
  80211b:	c7 04 24 2c 2a 80 00 	movl   $0x802a2c,(%esp)
  802122:	e8 5a e1 ff ff       	call   800281 <cprintf>
		if(from_env_store != NULL)
  802127:	85 f6                	test   %esi,%esi
  802129:	74 06                	je     802131 <ipc_recv+0x4e>
			*from_env_store = 0;
  80212b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802131:	85 ff                	test   %edi,%edi
  802133:	74 2d                	je     802162 <ipc_recv+0x7f>
			*perm_store = 0;
  802135:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80213b:	eb 25                	jmp    802162 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  80213d:	85 f6                	test   %esi,%esi
  80213f:	90                   	nop
  802140:	74 0a                	je     80214c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  802142:	a1 04 40 80 00       	mov    0x804004,%eax
  802147:	8b 40 74             	mov    0x74(%eax),%eax
  80214a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80214c:	85 ff                	test   %edi,%edi
  80214e:	74 0a                	je     80215a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  802150:	a1 04 40 80 00       	mov    0x804004,%eax
  802155:	8b 40 78             	mov    0x78(%eax),%eax
  802158:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80215a:	a1 04 40 80 00       	mov    0x804004,%eax
  80215f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802162:	89 d8                	mov    %ebx,%eax
  802164:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802167:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80216a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80216d:	89 ec                	mov    %ebp,%esp
  80216f:	5d                   	pop    %ebp
  802170:	c3                   	ret    
	...

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	57                   	push   %edi
  802184:	56                   	push   %esi
  802185:	83 ec 10             	sub    $0x10,%esp
  802188:	8b 45 14             	mov    0x14(%ebp),%eax
  80218b:	8b 55 08             	mov    0x8(%ebp),%edx
  80218e:	8b 75 10             	mov    0x10(%ebp),%esi
  802191:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802194:	85 c0                	test   %eax,%eax
  802196:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802199:	75 35                	jne    8021d0 <__udivdi3+0x50>
  80219b:	39 fe                	cmp    %edi,%esi
  80219d:	77 61                	ja     802200 <__udivdi3+0x80>
  80219f:	85 f6                	test   %esi,%esi
  8021a1:	75 0b                	jne    8021ae <__udivdi3+0x2e>
  8021a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	f7 f6                	div    %esi
  8021ac:	89 c6                	mov    %eax,%esi
  8021ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8021b1:	31 d2                	xor    %edx,%edx
  8021b3:	89 f8                	mov    %edi,%eax
  8021b5:	f7 f6                	div    %esi
  8021b7:	89 c7                	mov    %eax,%edi
  8021b9:	89 c8                	mov    %ecx,%eax
  8021bb:	f7 f6                	div    %esi
  8021bd:	89 c1                	mov    %eax,%ecx
  8021bf:	89 fa                	mov    %edi,%edx
  8021c1:	89 c8                	mov    %ecx,%eax
  8021c3:	83 c4 10             	add    $0x10,%esp
  8021c6:	5e                   	pop    %esi
  8021c7:	5f                   	pop    %edi
  8021c8:	5d                   	pop    %ebp
  8021c9:	c3                   	ret    
  8021ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d0:	39 f8                	cmp    %edi,%eax
  8021d2:	77 1c                	ja     8021f0 <__udivdi3+0x70>
  8021d4:	0f bd d0             	bsr    %eax,%edx
  8021d7:	83 f2 1f             	xor    $0x1f,%edx
  8021da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021dd:	75 39                	jne    802218 <__udivdi3+0x98>
  8021df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8021e2:	0f 86 a0 00 00 00    	jbe    802288 <__udivdi3+0x108>
  8021e8:	39 f8                	cmp    %edi,%eax
  8021ea:	0f 82 98 00 00 00    	jb     802288 <__udivdi3+0x108>
  8021f0:	31 ff                	xor    %edi,%edi
  8021f2:	31 c9                	xor    %ecx,%ecx
  8021f4:	89 c8                	mov    %ecx,%eax
  8021f6:	89 fa                	mov    %edi,%edx
  8021f8:	83 c4 10             	add    $0x10,%esp
  8021fb:	5e                   	pop    %esi
  8021fc:	5f                   	pop    %edi
  8021fd:	5d                   	pop    %ebp
  8021fe:	c3                   	ret    
  8021ff:	90                   	nop
  802200:	89 d1                	mov    %edx,%ecx
  802202:	89 fa                	mov    %edi,%edx
  802204:	89 c8                	mov    %ecx,%eax
  802206:	31 ff                	xor    %edi,%edi
  802208:	f7 f6                	div    %esi
  80220a:	89 c1                	mov    %eax,%ecx
  80220c:	89 fa                	mov    %edi,%edx
  80220e:	89 c8                	mov    %ecx,%eax
  802210:	83 c4 10             	add    $0x10,%esp
  802213:	5e                   	pop    %esi
  802214:	5f                   	pop    %edi
  802215:	5d                   	pop    %ebp
  802216:	c3                   	ret    
  802217:	90                   	nop
  802218:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80221c:	89 f2                	mov    %esi,%edx
  80221e:	d3 e0                	shl    %cl,%eax
  802220:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802223:	b8 20 00 00 00       	mov    $0x20,%eax
  802228:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80222b:	89 c1                	mov    %eax,%ecx
  80222d:	d3 ea                	shr    %cl,%edx
  80222f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802233:	0b 55 ec             	or     -0x14(%ebp),%edx
  802236:	d3 e6                	shl    %cl,%esi
  802238:	89 c1                	mov    %eax,%ecx
  80223a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80223d:	89 fe                	mov    %edi,%esi
  80223f:	d3 ee                	shr    %cl,%esi
  802241:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802245:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802248:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80224b:	d3 e7                	shl    %cl,%edi
  80224d:	89 c1                	mov    %eax,%ecx
  80224f:	d3 ea                	shr    %cl,%edx
  802251:	09 d7                	or     %edx,%edi
  802253:	89 f2                	mov    %esi,%edx
  802255:	89 f8                	mov    %edi,%eax
  802257:	f7 75 ec             	divl   -0x14(%ebp)
  80225a:	89 d6                	mov    %edx,%esi
  80225c:	89 c7                	mov    %eax,%edi
  80225e:	f7 65 e8             	mull   -0x18(%ebp)
  802261:	39 d6                	cmp    %edx,%esi
  802263:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802266:	72 30                	jb     802298 <__udivdi3+0x118>
  802268:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80226b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80226f:	d3 e2                	shl    %cl,%edx
  802271:	39 c2                	cmp    %eax,%edx
  802273:	73 05                	jae    80227a <__udivdi3+0xfa>
  802275:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802278:	74 1e                	je     802298 <__udivdi3+0x118>
  80227a:	89 f9                	mov    %edi,%ecx
  80227c:	31 ff                	xor    %edi,%edi
  80227e:	e9 71 ff ff ff       	jmp    8021f4 <__udivdi3+0x74>
  802283:	90                   	nop
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	31 ff                	xor    %edi,%edi
  80228a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80228f:	e9 60 ff ff ff       	jmp    8021f4 <__udivdi3+0x74>
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80229b:	31 ff                	xor    %edi,%edi
  80229d:	89 c8                	mov    %ecx,%eax
  80229f:	89 fa                	mov    %edi,%edx
  8022a1:	83 c4 10             	add    $0x10,%esp
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
	...

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	57                   	push   %edi
  8022b4:	56                   	push   %esi
  8022b5:	83 ec 20             	sub    $0x20,%esp
  8022b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8022bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8022c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022c4:	85 d2                	test   %edx,%edx
  8022c6:	89 c8                	mov    %ecx,%eax
  8022c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8022cb:	75 13                	jne    8022e0 <__umoddi3+0x30>
  8022cd:	39 f7                	cmp    %esi,%edi
  8022cf:	76 3f                	jbe    802310 <__umoddi3+0x60>
  8022d1:	89 f2                	mov    %esi,%edx
  8022d3:	f7 f7                	div    %edi
  8022d5:	89 d0                	mov    %edx,%eax
  8022d7:	31 d2                	xor    %edx,%edx
  8022d9:	83 c4 20             	add    $0x20,%esp
  8022dc:	5e                   	pop    %esi
  8022dd:	5f                   	pop    %edi
  8022de:	5d                   	pop    %ebp
  8022df:	c3                   	ret    
  8022e0:	39 f2                	cmp    %esi,%edx
  8022e2:	77 4c                	ja     802330 <__umoddi3+0x80>
  8022e4:	0f bd ca             	bsr    %edx,%ecx
  8022e7:	83 f1 1f             	xor    $0x1f,%ecx
  8022ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8022ed:	75 51                	jne    802340 <__umoddi3+0x90>
  8022ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8022f2:	0f 87 e0 00 00 00    	ja     8023d8 <__umoddi3+0x128>
  8022f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022fb:	29 f8                	sub    %edi,%eax
  8022fd:	19 d6                	sbb    %edx,%esi
  8022ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802302:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802305:	89 f2                	mov    %esi,%edx
  802307:	83 c4 20             	add    $0x20,%esp
  80230a:	5e                   	pop    %esi
  80230b:	5f                   	pop    %edi
  80230c:	5d                   	pop    %ebp
  80230d:	c3                   	ret    
  80230e:	66 90                	xchg   %ax,%ax
  802310:	85 ff                	test   %edi,%edi
  802312:	75 0b                	jne    80231f <__umoddi3+0x6f>
  802314:	b8 01 00 00 00       	mov    $0x1,%eax
  802319:	31 d2                	xor    %edx,%edx
  80231b:	f7 f7                	div    %edi
  80231d:	89 c7                	mov    %eax,%edi
  80231f:	89 f0                	mov    %esi,%eax
  802321:	31 d2                	xor    %edx,%edx
  802323:	f7 f7                	div    %edi
  802325:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802328:	f7 f7                	div    %edi
  80232a:	eb a9                	jmp    8022d5 <__umoddi3+0x25>
  80232c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802330:	89 c8                	mov    %ecx,%eax
  802332:	89 f2                	mov    %esi,%edx
  802334:	83 c4 20             	add    $0x20,%esp
  802337:	5e                   	pop    %esi
  802338:	5f                   	pop    %edi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    
  80233b:	90                   	nop
  80233c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802340:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802344:	d3 e2                	shl    %cl,%edx
  802346:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802349:	ba 20 00 00 00       	mov    $0x20,%edx
  80234e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802351:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802354:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802358:	89 fa                	mov    %edi,%edx
  80235a:	d3 ea                	shr    %cl,%edx
  80235c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802360:	0b 55 f4             	or     -0xc(%ebp),%edx
  802363:	d3 e7                	shl    %cl,%edi
  802365:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802369:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80236c:	89 f2                	mov    %esi,%edx
  80236e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802371:	89 c7                	mov    %eax,%edi
  802373:	d3 ea                	shr    %cl,%edx
  802375:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802379:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80237c:	89 c2                	mov    %eax,%edx
  80237e:	d3 e6                	shl    %cl,%esi
  802380:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802384:	d3 ea                	shr    %cl,%edx
  802386:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80238a:	09 d6                	or     %edx,%esi
  80238c:	89 f0                	mov    %esi,%eax
  80238e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802391:	d3 e7                	shl    %cl,%edi
  802393:	89 f2                	mov    %esi,%edx
  802395:	f7 75 f4             	divl   -0xc(%ebp)
  802398:	89 d6                	mov    %edx,%esi
  80239a:	f7 65 e8             	mull   -0x18(%ebp)
  80239d:	39 d6                	cmp    %edx,%esi
  80239f:	72 2b                	jb     8023cc <__umoddi3+0x11c>
  8023a1:	39 c7                	cmp    %eax,%edi
  8023a3:	72 23                	jb     8023c8 <__umoddi3+0x118>
  8023a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023a9:	29 c7                	sub    %eax,%edi
  8023ab:	19 d6                	sbb    %edx,%esi
  8023ad:	89 f0                	mov    %esi,%eax
  8023af:	89 f2                	mov    %esi,%edx
  8023b1:	d3 ef                	shr    %cl,%edi
  8023b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8023b7:	d3 e0                	shl    %cl,%eax
  8023b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023bd:	09 f8                	or     %edi,%eax
  8023bf:	d3 ea                	shr    %cl,%edx
  8023c1:	83 c4 20             	add    $0x20,%esp
  8023c4:	5e                   	pop    %esi
  8023c5:	5f                   	pop    %edi
  8023c6:	5d                   	pop    %ebp
  8023c7:	c3                   	ret    
  8023c8:	39 d6                	cmp    %edx,%esi
  8023ca:	75 d9                	jne    8023a5 <__umoddi3+0xf5>
  8023cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8023cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8023d2:	eb d1                	jmp    8023a5 <__umoddi3+0xf5>
  8023d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023d8:	39 f2                	cmp    %esi,%edx
  8023da:	0f 82 18 ff ff ff    	jb     8022f8 <__umoddi3+0x48>
  8023e0:	e9 1d ff ff ff       	jmp    802302 <__umoddi3+0x52>
