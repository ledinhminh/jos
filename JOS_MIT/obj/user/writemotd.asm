
obj/user/writemotd.debug:     file format elf32-i386


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
  80002c:	e8 13 02 00 00       	call   800244 <libmain>
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
  80003a:	81 ec 2c 02 00 00    	sub    $0x22c,%esp
	int rfd, wfd;
	char buf[512];
	int n, r;

	if ((rfd = open("/newmotd", O_RDONLY)) < 0)
  800040:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800047:	00 
  800048:	c7 04 24 a0 24 80 00 	movl   $0x8024a0,(%esp)
  80004f:	e8 80 1a 00 00       	call   801ad4 <open>
  800054:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 a9 24 80 	movl   $0x8024a9,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  800079:	e8 32 02 00 00       	call   8002b0 <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 cc 24 80 00 	movl   $0x8024cc,(%esp)
  80008d:	e8 42 1a 00 00       	call   801ad4 <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 d2 24 80 	movl   $0x8024d2,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  8000b3:	e8 f8 01 00 00       	call   8002b0 <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 e1 24 80 00 	movl   $0x8024e1,(%esp)
  8000cd:	e8 97 02 00 00       	call   800369 <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd e4 fd ff ff    	cmp    %edi,-0x21c(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 4c 25 80 	movl   $0x80254c,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  8000f1:	e8 ba 01 00 00       	call   8002b0 <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 f9 24 80 00 	movl   $0x8024f9,(%esp)
  8000fd:	e8 67 02 00 00       	call   800369 <cprintf>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800102:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800108:	eb 0c                	jmp    800116 <umain+0xe2>
		sys_cputs(buf, n);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	89 1c 24             	mov    %ebx,(%esp)
  800111:	e8 50 11 00 00       	call   801266 <sys_cputs>
	cprintf("file descriptors %d %d\n", rfd, wfd);
	if (rfd == wfd)
		panic("open /newmotd and /motd give same file descriptor");

	cprintf("OLD MOTD\n===\n");
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800116:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  80011d:	00 
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 3c 24             	mov    %edi,(%esp)
  800125:	e8 79 14 00 00       	call   8015a3 <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  800135:	e8 2f 02 00 00       	call   800369 <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 3b 12 00 00       	call   801385 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 3e 13 00 00       	call   801498 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 07 25 80 	movl   $0x802507,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  800179:	e8 32 01 00 00       	call   8002b0 <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 1a 25 80 00 	movl   $0x80251a,(%esp)
  800185:	e8 df 01 00 00       	call   800369 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  80018a:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  800190:	eb 40                	jmp    8001d2 <umain+0x19e>
		sys_cputs(buf, n);
  800192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 c8 10 00 00       	call   801266 <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80019e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 3c 24             	mov    %edi,(%esp)
  8001a9:	e8 6c 13 00 00       	call   80151a <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 28 25 80 	movl   $0x802528,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  8001cd:	e8 de 00 00 00       	call   8002b0 <_panic>

	if ((r = ftruncate(wfd, 0)) < 0)
		panic("truncate /motd: %e", r);

	cprintf("NEW MOTD\n===\n");
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  8001d2:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  8001d9:	00 
  8001da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001de:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 b7 13 00 00       	call   8015a3 <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 02 25 80 00 	movl   $0x802502,(%esp)
  8001f9:	e8 6b 01 00 00       	call   800369 <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 38 25 80 	movl   $0x802538,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 bb 24 80 00 	movl   $0x8024bb,(%esp)
  80021d:	e8 8e 00 00 00       	call   8002b0 <_panic>

	close(rfd);
  800222:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 dc 14 00 00       	call   80170c <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 d4 14 00 00       	call   80170c <close>
}
  800238:	81 c4 2c 02 00 00    	add    $0x22c,%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    
	...

00800244 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	83 ec 18             	sub    $0x18,%esp
  80024a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80024d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800256:	e8 5c 0f 00 00       	call   8011b7 <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	c1 e0 07             	shl    $0x7,%eax
  800263:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800268:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80026d:	85 f6                	test   %esi,%esi
  80026f:	7e 07                	jle    800278 <libmain+0x34>
		binaryname = argv[0];
  800271:	8b 03                	mov    (%ebx),%eax
  800273:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800278:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80027c:	89 34 24             	mov    %esi,(%esp)
  80027f:	e8 b0 fd ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800284:	e8 0b 00 00 00       	call   800294 <exit>
}
  800289:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80028c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80028f:	89 ec                	mov    %ebp,%esp
  800291:	5d                   	pop    %ebp
  800292:	c3                   	ret    
	...

00800294 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80029a:	e8 ea 14 00 00       	call   801789 <close_all>
	sys_env_destroy(0);
  80029f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a6:	e8 47 0f 00 00       	call   8011f2 <sys_env_destroy>
}
  8002ab:	c9                   	leave  
  8002ac:	c3                   	ret    
  8002ad:	00 00                	add    %al,(%eax)
	...

008002b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	56                   	push   %esi
  8002b4:	53                   	push   %ebx
  8002b5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002b8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002bb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002c1:	e8 f1 0e 00 00       	call   8011b7 <sys_getenvid>
  8002c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dc:	c7 04 24 88 25 80 00 	movl   $0x802588,(%esp)
  8002e3:	e8 81 00 00 00       	call   800369 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 11 00 00 00       	call   800308 <vcprintf>
	cprintf("\n");
  8002f7:	c7 04 24 05 25 80 00 	movl   $0x802505,(%esp)
  8002fe:	e8 66 00 00 00       	call   800369 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800303:	cc                   	int3   
  800304:	eb fd                	jmp    800303 <_panic+0x53>
	...

00800308 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800308:	55                   	push   %ebp
  800309:	89 e5                	mov    %esp,%ebp
  80030b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800311:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800318:	00 00 00 
	b.cnt = 0;
  80031b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800322:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800325:	8b 45 0c             	mov    0xc(%ebp),%eax
  800328:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032c:	8b 45 08             	mov    0x8(%ebp),%eax
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800339:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033d:	c7 04 24 83 03 80 00 	movl   $0x800383,(%esp)
  800344:	e8 d4 01 00 00       	call   80051d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800349:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80034f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800353:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800359:	89 04 24             	mov    %eax,(%esp)
  80035c:	e8 05 0f 00 00       	call   801266 <sys_cputs>

	return b.cnt;
}
  800361:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80036f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800372:	89 44 24 04          	mov    %eax,0x4(%esp)
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	89 04 24             	mov    %eax,(%esp)
  80037c:	e8 87 ff ff ff       	call   800308 <vcprintf>
	va_end(ap);

	return cnt;
}
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	53                   	push   %ebx
  800387:	83 ec 14             	sub    $0x14,%esp
  80038a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038d:	8b 03                	mov    (%ebx),%eax
  80038f:	8b 55 08             	mov    0x8(%ebp),%edx
  800392:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800396:	83 c0 01             	add    $0x1,%eax
  800399:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80039b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a0:	75 19                	jne    8003bb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003a2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003a9:	00 
  8003aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ad:	89 04 24             	mov    %eax,(%esp)
  8003b0:	e8 b1 0e 00 00       	call   801266 <sys_cputs>
		b->idx = 0;
  8003b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003bb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	5b                   	pop    %ebx
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    
	...

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 4c             	sub    $0x4c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d6                	mov    %edx,%esi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	39 d1                	cmp    %edx,%ecx
  8003fd:	72 15                	jb     800414 <printnum+0x44>
  8003ff:	77 07                	ja     800408 <printnum+0x38>
  800401:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800404:	39 d0                	cmp    %edx,%eax
  800406:	76 0c                	jbe    800414 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800408:	83 eb 01             	sub    $0x1,%ebx
  80040b:	85 db                	test   %ebx,%ebx
  80040d:	8d 76 00             	lea    0x0(%esi),%esi
  800410:	7f 61                	jg     800473 <printnum+0xa3>
  800412:	eb 70                	jmp    800484 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800414:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800418:	83 eb 01             	sub    $0x1,%ebx
  80041b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80041f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800423:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800427:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80042b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80042e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800431:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800434:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800438:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043f:	00 
  800440:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800449:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044d:	e8 de 1d 00 00       	call   802230 <__udivdi3>
  800452:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800455:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80045c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	89 54 24 04          	mov    %edx,0x4(%esp)
  800467:	89 f2                	mov    %esi,%edx
  800469:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046c:	e8 5f ff ff ff       	call   8003d0 <printnum>
  800471:	eb 11                	jmp    800484 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800473:	89 74 24 04          	mov    %esi,0x4(%esp)
  800477:	89 3c 24             	mov    %edi,(%esp)
  80047a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047d:	83 eb 01             	sub    $0x1,%ebx
  800480:	85 db                	test   %ebx,%ebx
  800482:	7f ef                	jg     800473 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800484:	89 74 24 04          	mov    %esi,0x4(%esp)
  800488:	8b 74 24 04          	mov    0x4(%esp),%esi
  80048c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800493:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80049a:	00 
  80049b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80049e:	89 14 24             	mov    %edx,(%esp)
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a8:	e8 b3 1e 00 00       	call   802360 <__umoddi3>
  8004ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b1:	0f be 80 ab 25 80 00 	movsbl 0x8025ab(%eax),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004be:	83 c4 4c             	add    $0x4c,%esp
  8004c1:	5b                   	pop    %ebx
  8004c2:	5e                   	pop    %esi
  8004c3:	5f                   	pop    %edi
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c9:	83 fa 01             	cmp    $0x1,%edx
  8004cc:	7e 0e                	jle    8004dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ce:	8b 10                	mov    (%eax),%edx
  8004d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d3:	89 08                	mov    %ecx,(%eax)
  8004d5:	8b 02                	mov    (%edx),%eax
  8004d7:	8b 52 04             	mov    0x4(%edx),%edx
  8004da:	eb 22                	jmp    8004fe <getuint+0x38>
	else if (lflag)
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	74 10                	je     8004f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e0:	8b 10                	mov    (%eax),%edx
  8004e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e5:	89 08                	mov    %ecx,(%eax)
  8004e7:	8b 02                	mov    (%edx),%eax
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ee:	eb 0e                	jmp    8004fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f0:	8b 10                	mov    (%eax),%edx
  8004f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 02                	mov    (%edx),%eax
  8004f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800506:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	3b 50 04             	cmp    0x4(%eax),%edx
  80050f:	73 0a                	jae    80051b <sprintputch+0x1b>
		*b->buf++ = ch;
  800511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800514:	88 0a                	mov    %cl,(%edx)
  800516:	83 c2 01             	add    $0x1,%edx
  800519:	89 10                	mov    %edx,(%eax)
}
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 5c             	sub    $0x5c,%esp
  800526:	8b 7d 08             	mov    0x8(%ebp),%edi
  800529:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80052f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800536:	eb 11                	jmp    800549 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800538:	85 c0                	test   %eax,%eax
  80053a:	0f 84 68 04 00 00    	je     8009a8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800540:	89 74 24 04          	mov    %esi,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800549:	0f b6 03             	movzbl (%ebx),%eax
  80054c:	83 c3 01             	add    $0x1,%ebx
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e4                	jne    800538 <vprintfmt+0x1b>
  800554:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80055b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800562:	b9 00 00 00 00       	mov    $0x0,%ecx
  800567:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80056b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800572:	eb 06                	jmp    80057a <vprintfmt+0x5d>
  800574:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800578:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	0f b6 13             	movzbl (%ebx),%edx
  80057d:	0f b6 c2             	movzbl %dl,%eax
  800580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800583:	8d 43 01             	lea    0x1(%ebx),%eax
  800586:	83 ea 23             	sub    $0x23,%edx
  800589:	80 fa 55             	cmp    $0x55,%dl
  80058c:	0f 87 f9 03 00 00    	ja     80098b <vprintfmt+0x46e>
  800592:	0f b6 d2             	movzbl %dl,%edx
  800595:	ff 24 95 80 27 80 00 	jmp    *0x802780(,%edx,4)
  80059c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8005a0:	eb d6                	jmp    800578 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a5:	83 ea 30             	sub    $0x30,%edx
  8005a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8005ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005b1:	83 fb 09             	cmp    $0x9,%ebx
  8005b4:	77 54                	ja     80060a <vprintfmt+0xed>
  8005b6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8005c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005cc:	83 fb 09             	cmp    $0x9,%ebx
  8005cf:	76 eb                	jbe    8005bc <vprintfmt+0x9f>
  8005d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005d7:	eb 31                	jmp    80060a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8005dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8005df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8005e2:	8b 12                	mov    (%edx),%edx
  8005e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8005e7:	eb 21                	jmp    80060a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8005e9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8005f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005f9:	e9 7a ff ff ff       	jmp    800578 <vprintfmt+0x5b>
  8005fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800605:	e9 6e ff ff ff       	jmp    800578 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80060a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80060e:	0f 89 64 ff ff ff    	jns    800578 <vprintfmt+0x5b>
  800614:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800617:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80061a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80061d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800620:	e9 53 ff ff ff       	jmp    800578 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800625:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800628:	e9 4b ff ff ff       	jmp    800578 <vprintfmt+0x5b>
  80062d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	ff d7                	call   *%edi
  800644:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800647:	e9 fd fe ff ff       	jmp    800549 <vprintfmt+0x2c>
  80064c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 c2                	mov    %eax,%edx
  80065c:	c1 fa 1f             	sar    $0x1f,%edx
  80065f:	31 d0                	xor    %edx,%eax
  800661:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800663:	83 f8 0f             	cmp    $0xf,%eax
  800666:	7f 0b                	jg     800673 <vprintfmt+0x156>
  800668:	8b 14 85 e0 28 80 00 	mov    0x8028e0(,%eax,4),%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	75 20                	jne    800693 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800673:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800677:	c7 44 24 08 bc 25 80 	movl   $0x8025bc,0x8(%esp)
  80067e:	00 
  80067f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800683:	89 3c 24             	mov    %edi,(%esp)
  800686:	e8 a5 03 00 00       	call   800a30 <printfmt>
  80068b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068e:	e9 b6 fe ff ff       	jmp    800549 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800697:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  80069e:	00 
  80069f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a3:	89 3c 24             	mov    %edi,(%esp)
  8006a6:	e8 85 03 00 00       	call   800a30 <printfmt>
  8006ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006ae:	e9 96 fe ff ff       	jmp    800549 <vprintfmt+0x2c>
  8006b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b6:	89 c3                	mov    %eax,%ebx
  8006b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	b8 c5 25 80 00       	mov    $0x8025c5,%eax
  8006d6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8006da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8006dd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8006e1:	7e 06                	jle    8006e9 <vprintfmt+0x1cc>
  8006e3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8006e7:	75 13                	jne    8006fc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ec:	0f be 02             	movsbl (%edx),%eax
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	0f 85 a2 00 00 00    	jne    800799 <vprintfmt+0x27c>
  8006f7:	e9 8f 00 00 00       	jmp    80078b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800700:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800703:	89 0c 24             	mov    %ecx,(%esp)
  800706:	e8 70 03 00 00       	call   800a7b <strnlen>
  80070b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80070e:	29 c2                	sub    %eax,%edx
  800710:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800713:	85 d2                	test   %edx,%edx
  800715:	7e d2                	jle    8006e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800717:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80071b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80071e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800721:	89 d3                	mov    %edx,%ebx
  800723:	89 74 24 04          	mov    %esi,0x4(%esp)
  800727:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072a:	89 04 24             	mov    %eax,(%esp)
  80072d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072f:	83 eb 01             	sub    $0x1,%ebx
  800732:	85 db                	test   %ebx,%ebx
  800734:	7f ed                	jg     800723 <vprintfmt+0x206>
  800736:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800739:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800740:	eb a7                	jmp    8006e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800742:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800746:	74 1b                	je     800763 <vprintfmt+0x246>
  800748:	8d 50 e0             	lea    -0x20(%eax),%edx
  80074b:	83 fa 5e             	cmp    $0x5e,%edx
  80074e:	76 13                	jbe    800763 <vprintfmt+0x246>
					putch('?', putdat);
  800750:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800753:	89 54 24 04          	mov    %edx,0x4(%esp)
  800757:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80075e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800761:	eb 0d                	jmp    800770 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800763:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800766:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80076a:	89 04 24             	mov    %eax,(%esp)
  80076d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800770:	83 ef 01             	sub    $0x1,%edi
  800773:	0f be 03             	movsbl (%ebx),%eax
  800776:	85 c0                	test   %eax,%eax
  800778:	74 05                	je     80077f <vprintfmt+0x262>
  80077a:	83 c3 01             	add    $0x1,%ebx
  80077d:	eb 31                	jmp    8007b0 <vprintfmt+0x293>
  80077f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800785:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800788:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80078b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80078f:	7f 36                	jg     8007c7 <vprintfmt+0x2aa>
  800791:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800794:	e9 b0 fd ff ff       	jmp    800549 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800799:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079c:	83 c2 01             	add    $0x1,%edx
  80079f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007a5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007a8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007ab:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007ae:	89 d3                	mov    %edx,%ebx
  8007b0:	85 f6                	test   %esi,%esi
  8007b2:	78 8e                	js     800742 <vprintfmt+0x225>
  8007b4:	83 ee 01             	sub    $0x1,%esi
  8007b7:	79 89                	jns    800742 <vprintfmt+0x225>
  8007b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8007c5:	eb c4                	jmp    80078b <vprintfmt+0x26e>
  8007c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007d8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007da:	83 eb 01             	sub    $0x1,%ebx
  8007dd:	85 db                	test   %ebx,%ebx
  8007df:	7f ec                	jg     8007cd <vprintfmt+0x2b0>
  8007e1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8007e4:	e9 60 fd ff ff       	jmp    800549 <vprintfmt+0x2c>
  8007e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007ec:	83 f9 01             	cmp    $0x1,%ecx
  8007ef:	7e 16                	jle    800807 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 08             	lea    0x8(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fa:	8b 10                	mov    (%eax),%edx
  8007fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ff:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800805:	eb 32                	jmp    800839 <vprintfmt+0x31c>
	else if (lflag)
  800807:	85 c9                	test   %ecx,%ecx
  800809:	74 18                	je     800823 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)
  800814:	8b 00                	mov    (%eax),%eax
  800816:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800819:	89 c1                	mov    %eax,%ecx
  80081b:	c1 f9 1f             	sar    $0x1f,%ecx
  80081e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800821:	eb 16                	jmp    800839 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8d 50 04             	lea    0x4(%eax),%edx
  800829:	89 55 14             	mov    %edx,0x14(%ebp)
  80082c:	8b 00                	mov    (%eax),%eax
  80082e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800831:	89 c2                	mov    %eax,%edx
  800833:	c1 fa 1f             	sar    $0x1f,%edx
  800836:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800839:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80083c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80083f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800844:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800848:	0f 89 8a 00 00 00    	jns    8008d8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80084e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800852:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800859:	ff d7                	call   *%edi
				num = -(long long) num;
  80085b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80085e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800861:	f7 d8                	neg    %eax
  800863:	83 d2 00             	adc    $0x0,%edx
  800866:	f7 da                	neg    %edx
  800868:	eb 6e                	jmp    8008d8 <vprintfmt+0x3bb>
  80086a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80086d:	89 ca                	mov    %ecx,%edx
  80086f:	8d 45 14             	lea    0x14(%ebp),%eax
  800872:	e8 4f fc ff ff       	call   8004c6 <getuint>
  800877:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80087c:	eb 5a                	jmp    8008d8 <vprintfmt+0x3bb>
  80087e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800881:	89 ca                	mov    %ecx,%edx
  800883:	8d 45 14             	lea    0x14(%ebp),%eax
  800886:	e8 3b fc ff ff       	call   8004c6 <getuint>
  80088b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800890:	eb 46                	jmp    8008d8 <vprintfmt+0x3bb>
  800892:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800895:	89 74 24 04          	mov    %esi,0x4(%esp)
  800899:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008a0:	ff d7                	call   *%edi
			putch('x', putdat);
  8008a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008ad:	ff d7                	call   *%edi
			num = (unsigned long long)
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8d 50 04             	lea    0x4(%eax),%edx
  8008b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008b8:	8b 00                	mov    (%eax),%eax
  8008ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8008bf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008c4:	eb 12                	jmp    8008d8 <vprintfmt+0x3bb>
  8008c6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008c9:	89 ca                	mov    %ecx,%edx
  8008cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ce:	e8 f3 fb ff ff       	call   8004c6 <getuint>
  8008d3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008d8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8008dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8008e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8008e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8008e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008eb:	89 04 24             	mov    %eax,(%esp)
  8008ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f2:	89 f2                	mov    %esi,%edx
  8008f4:	89 f8                	mov    %edi,%eax
  8008f6:	e8 d5 fa ff ff       	call   8003d0 <printnum>
  8008fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8008fe:	e9 46 fc ff ff       	jmp    800549 <vprintfmt+0x2c>
  800903:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8d 50 04             	lea    0x4(%eax),%edx
  80090c:	89 55 14             	mov    %edx,0x14(%ebp)
  80090f:	8b 00                	mov    (%eax),%eax
  800911:	85 c0                	test   %eax,%eax
  800913:	75 24                	jne    800939 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800915:	c7 44 24 0c e0 26 80 	movl   $0x8026e0,0xc(%esp)
  80091c:	00 
  80091d:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800924:	00 
  800925:	89 74 24 04          	mov    %esi,0x4(%esp)
  800929:	89 3c 24             	mov    %edi,(%esp)
  80092c:	e8 ff 00 00 00       	call   800a30 <printfmt>
  800931:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800934:	e9 10 fc ff ff       	jmp    800549 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800939:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80093c:	7e 29                	jle    800967 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80093e:	0f b6 16             	movzbl (%esi),%edx
  800941:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800943:	c7 44 24 0c 18 27 80 	movl   $0x802718,0xc(%esp)
  80094a:	00 
  80094b:	c7 44 24 08 ff 29 80 	movl   $0x8029ff,0x8(%esp)
  800952:	00 
  800953:	89 74 24 04          	mov    %esi,0x4(%esp)
  800957:	89 3c 24             	mov    %edi,(%esp)
  80095a:	e8 d1 00 00 00       	call   800a30 <printfmt>
  80095f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800962:	e9 e2 fb ff ff       	jmp    800549 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800967:	0f b6 16             	movzbl (%esi),%edx
  80096a:	88 10                	mov    %dl,(%eax)
  80096c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80096f:	e9 d5 fb ff ff       	jmp    800549 <vprintfmt+0x2c>
  800974:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800977:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80097a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80097e:	89 14 24             	mov    %edx,(%esp)
  800981:	ff d7                	call   *%edi
  800983:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800986:	e9 be fb ff ff       	jmp    800549 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80098b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800996:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800998:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80099b:	80 38 25             	cmpb   $0x25,(%eax)
  80099e:	0f 84 a5 fb ff ff    	je     800549 <vprintfmt+0x2c>
  8009a4:	89 c3                	mov    %eax,%ebx
  8009a6:	eb f0                	jmp    800998 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8009a8:	83 c4 5c             	add    $0x5c,%esp
  8009ab:	5b                   	pop    %ebx
  8009ac:	5e                   	pop    %esi
  8009ad:	5f                   	pop    %edi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	83 ec 28             	sub    $0x28,%esp
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009bc:	85 c0                	test   %eax,%eax
  8009be:	74 04                	je     8009c4 <vsnprintf+0x14>
  8009c0:	85 d2                	test   %edx,%edx
  8009c2:	7f 07                	jg     8009cb <vsnprintf+0x1b>
  8009c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009c9:	eb 3b                	jmp    800a06 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009ce:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8009d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f1:	c7 04 24 00 05 80 00 	movl   $0x800500,(%esp)
  8009f8:	e8 20 fb ff ff       	call   80051d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a0e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a15:	8b 45 10             	mov    0x10(%ebp),%eax
  800a18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	89 04 24             	mov    %eax,(%esp)
  800a29:	e8 82 ff ff ff       	call   8009b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a36:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a40:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	89 04 24             	mov    %eax,(%esp)
  800a51:	e8 c7 fa ff ff       	call   80051d <vprintfmt>
	va_end(ap);
}
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    
	...

00800a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a66:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a6e:	74 09                	je     800a79 <strlen+0x19>
		n++;
  800a70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a77:	75 f7                	jne    800a70 <strlen+0x10>
		n++;
	return n;
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a85:	85 c9                	test   %ecx,%ecx
  800a87:	74 19                	je     800aa2 <strnlen+0x27>
  800a89:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a8c:	74 14                	je     800aa2 <strnlen+0x27>
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a93:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a96:	39 c8                	cmp    %ecx,%eax
  800a98:	74 0d                	je     800aa7 <strnlen+0x2c>
  800a9a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a9e:	75 f3                	jne    800a93 <strnlen+0x18>
  800aa0:	eb 05                	jmp    800aa7 <strnlen+0x2c>
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800aa7:	5b                   	pop    %ebx
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	53                   	push   %ebx
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ab4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ab9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800abd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800ac0:	83 c2 01             	add    $0x1,%edx
  800ac3:	84 c9                	test   %cl,%cl
  800ac5:	75 f2                	jne    800ab9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800ac7:	5b                   	pop    %ebx
  800ac8:	5d                   	pop    %ebp
  800ac9:	c3                   	ret    

00800aca <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aca:	55                   	push   %ebp
  800acb:	89 e5                	mov    %esp,%ebp
  800acd:	53                   	push   %ebx
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ad4:	89 1c 24             	mov    %ebx,(%esp)
  800ad7:	e8 84 ff ff ff       	call   800a60 <strlen>
	strcpy(dst + len, src);
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ae3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800ae6:	89 04 24             	mov    %eax,(%esp)
  800ae9:	e8 bc ff ff ff       	call   800aaa <strcpy>
	return dst;
}
  800aee:	89 d8                	mov    %ebx,%eax
  800af0:	83 c4 08             	add    $0x8,%esp
  800af3:	5b                   	pop    %ebx
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b04:	85 f6                	test   %esi,%esi
  800b06:	74 18                	je     800b20 <strncpy+0x2a>
  800b08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b0d:	0f b6 1a             	movzbl (%edx),%ebx
  800b10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b13:	80 3a 01             	cmpb   $0x1,(%edx)
  800b16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b19:	83 c1 01             	add    $0x1,%ecx
  800b1c:	39 ce                	cmp    %ecx,%esi
  800b1e:	77 ed                	ja     800b0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
  800b29:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b32:	89 f0                	mov    %esi,%eax
  800b34:	85 c9                	test   %ecx,%ecx
  800b36:	74 27                	je     800b5f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b38:	83 e9 01             	sub    $0x1,%ecx
  800b3b:	74 1d                	je     800b5a <strlcpy+0x36>
  800b3d:	0f b6 1a             	movzbl (%edx),%ebx
  800b40:	84 db                	test   %bl,%bl
  800b42:	74 16                	je     800b5a <strlcpy+0x36>
			*dst++ = *src++;
  800b44:	88 18                	mov    %bl,(%eax)
  800b46:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b49:	83 e9 01             	sub    $0x1,%ecx
  800b4c:	74 0e                	je     800b5c <strlcpy+0x38>
			*dst++ = *src++;
  800b4e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b51:	0f b6 1a             	movzbl (%edx),%ebx
  800b54:	84 db                	test   %bl,%bl
  800b56:	75 ec                	jne    800b44 <strlcpy+0x20>
  800b58:	eb 02                	jmp    800b5c <strlcpy+0x38>
  800b5a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b5c:	c6 00 00             	movb   $0x0,(%eax)
  800b5f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b6e:	0f b6 01             	movzbl (%ecx),%eax
  800b71:	84 c0                	test   %al,%al
  800b73:	74 15                	je     800b8a <strcmp+0x25>
  800b75:	3a 02                	cmp    (%edx),%al
  800b77:	75 11                	jne    800b8a <strcmp+0x25>
		p++, q++;
  800b79:	83 c1 01             	add    $0x1,%ecx
  800b7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b7f:	0f b6 01             	movzbl (%ecx),%eax
  800b82:	84 c0                	test   %al,%al
  800b84:	74 04                	je     800b8a <strcmp+0x25>
  800b86:	3a 02                	cmp    (%edx),%al
  800b88:	74 ef                	je     800b79 <strcmp+0x14>
  800b8a:	0f b6 c0             	movzbl %al,%eax
  800b8d:	0f b6 12             	movzbl (%edx),%edx
  800b90:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    

00800b94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b94:	55                   	push   %ebp
  800b95:	89 e5                	mov    %esp,%ebp
  800b97:	53                   	push   %ebx
  800b98:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ba1:	85 c0                	test   %eax,%eax
  800ba3:	74 23                	je     800bc8 <strncmp+0x34>
  800ba5:	0f b6 1a             	movzbl (%edx),%ebx
  800ba8:	84 db                	test   %bl,%bl
  800baa:	74 25                	je     800bd1 <strncmp+0x3d>
  800bac:	3a 19                	cmp    (%ecx),%bl
  800bae:	75 21                	jne    800bd1 <strncmp+0x3d>
  800bb0:	83 e8 01             	sub    $0x1,%eax
  800bb3:	74 13                	je     800bc8 <strncmp+0x34>
		n--, p++, q++;
  800bb5:	83 c2 01             	add    $0x1,%edx
  800bb8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800bbb:	0f b6 1a             	movzbl (%edx),%ebx
  800bbe:	84 db                	test   %bl,%bl
  800bc0:	74 0f                	je     800bd1 <strncmp+0x3d>
  800bc2:	3a 19                	cmp    (%ecx),%bl
  800bc4:	74 ea                	je     800bb0 <strncmp+0x1c>
  800bc6:	eb 09                	jmp    800bd1 <strncmp+0x3d>
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bcd:	5b                   	pop    %ebx
  800bce:	5d                   	pop    %ebp
  800bcf:	90                   	nop
  800bd0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800bd1:	0f b6 02             	movzbl (%edx),%eax
  800bd4:	0f b6 11             	movzbl (%ecx),%edx
  800bd7:	29 d0                	sub    %edx,%eax
  800bd9:	eb f2                	jmp    800bcd <strncmp+0x39>

00800bdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	8b 45 08             	mov    0x8(%ebp),%eax
  800be1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800be5:	0f b6 10             	movzbl (%eax),%edx
  800be8:	84 d2                	test   %dl,%dl
  800bea:	74 18                	je     800c04 <strchr+0x29>
		if (*s == c)
  800bec:	38 ca                	cmp    %cl,%dl
  800bee:	75 0a                	jne    800bfa <strchr+0x1f>
  800bf0:	eb 17                	jmp    800c09 <strchr+0x2e>
  800bf2:	38 ca                	cmp    %cl,%dl
  800bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bf8:	74 0f                	je     800c09 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800bfa:	83 c0 01             	add    $0x1,%eax
  800bfd:	0f b6 10             	movzbl (%eax),%edx
  800c00:	84 d2                	test   %dl,%dl
  800c02:	75 ee                	jne    800bf2 <strchr+0x17>
  800c04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c15:	0f b6 10             	movzbl (%eax),%edx
  800c18:	84 d2                	test   %dl,%dl
  800c1a:	74 18                	je     800c34 <strfind+0x29>
		if (*s == c)
  800c1c:	38 ca                	cmp    %cl,%dl
  800c1e:	75 0a                	jne    800c2a <strfind+0x1f>
  800c20:	eb 12                	jmp    800c34 <strfind+0x29>
  800c22:	38 ca                	cmp    %cl,%dl
  800c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c28:	74 0a                	je     800c34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c2a:	83 c0 01             	add    $0x1,%eax
  800c2d:	0f b6 10             	movzbl (%eax),%edx
  800c30:	84 d2                	test   %dl,%dl
  800c32:	75 ee                	jne    800c22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	83 ec 0c             	sub    $0xc,%esp
  800c3c:	89 1c 24             	mov    %ebx,(%esp)
  800c3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c50:	85 c9                	test   %ecx,%ecx
  800c52:	74 30                	je     800c84 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c5a:	75 25                	jne    800c81 <memset+0x4b>
  800c5c:	f6 c1 03             	test   $0x3,%cl
  800c5f:	75 20                	jne    800c81 <memset+0x4b>
		c &= 0xFF;
  800c61:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c64:	89 d3                	mov    %edx,%ebx
  800c66:	c1 e3 08             	shl    $0x8,%ebx
  800c69:	89 d6                	mov    %edx,%esi
  800c6b:	c1 e6 18             	shl    $0x18,%esi
  800c6e:	89 d0                	mov    %edx,%eax
  800c70:	c1 e0 10             	shl    $0x10,%eax
  800c73:	09 f0                	or     %esi,%eax
  800c75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c77:	09 d8                	or     %ebx,%eax
  800c79:	c1 e9 02             	shr    $0x2,%ecx
  800c7c:	fc                   	cld    
  800c7d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c7f:	eb 03                	jmp    800c84 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c81:	fc                   	cld    
  800c82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c84:	89 f8                	mov    %edi,%eax
  800c86:	8b 1c 24             	mov    (%esp),%ebx
  800c89:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c91:	89 ec                	mov    %ebp,%esp
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    

00800c95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	83 ec 08             	sub    $0x8,%esp
  800c9b:	89 34 24             	mov    %esi,(%esp)
  800c9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ca8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cad:	39 c6                	cmp    %eax,%esi
  800caf:	73 35                	jae    800ce6 <memmove+0x51>
  800cb1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800cb4:	39 d0                	cmp    %edx,%eax
  800cb6:	73 2e                	jae    800ce6 <memmove+0x51>
		s += n;
		d += n;
  800cb8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cba:	f6 c2 03             	test   $0x3,%dl
  800cbd:	75 1b                	jne    800cda <memmove+0x45>
  800cbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cc5:	75 13                	jne    800cda <memmove+0x45>
  800cc7:	f6 c1 03             	test   $0x3,%cl
  800cca:	75 0e                	jne    800cda <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ccc:	83 ef 04             	sub    $0x4,%edi
  800ccf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800cd2:	c1 e9 02             	shr    $0x2,%ecx
  800cd5:	fd                   	std    
  800cd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cd8:	eb 09                	jmp    800ce3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800cda:	83 ef 01             	sub    $0x1,%edi
  800cdd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ce0:	fd                   	std    
  800ce1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ce3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ce4:	eb 20                	jmp    800d06 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ce6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800cec:	75 15                	jne    800d03 <memmove+0x6e>
  800cee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cf4:	75 0d                	jne    800d03 <memmove+0x6e>
  800cf6:	f6 c1 03             	test   $0x3,%cl
  800cf9:	75 08                	jne    800d03 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800cfb:	c1 e9 02             	shr    $0x2,%ecx
  800cfe:	fc                   	cld    
  800cff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d01:	eb 03                	jmp    800d06 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d03:	fc                   	cld    
  800d04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d06:	8b 34 24             	mov    (%esp),%esi
  800d09:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d0d:	89 ec                	mov    %ebp,%esp
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d17:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d25:	8b 45 08             	mov    0x8(%ebp),%eax
  800d28:	89 04 24             	mov    %eax,(%esp)
  800d2b:	e8 65 ff ff ff       	call   800c95 <memmove>
}
  800d30:	c9                   	leave  
  800d31:	c3                   	ret    

00800d32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	8b 75 08             	mov    0x8(%ebp),%esi
  800d3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d41:	85 c9                	test   %ecx,%ecx
  800d43:	74 36                	je     800d7b <memcmp+0x49>
		if (*s1 != *s2)
  800d45:	0f b6 06             	movzbl (%esi),%eax
  800d48:	0f b6 1f             	movzbl (%edi),%ebx
  800d4b:	38 d8                	cmp    %bl,%al
  800d4d:	74 20                	je     800d6f <memcmp+0x3d>
  800d4f:	eb 14                	jmp    800d65 <memcmp+0x33>
  800d51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d5b:	83 c2 01             	add    $0x1,%edx
  800d5e:	83 e9 01             	sub    $0x1,%ecx
  800d61:	38 d8                	cmp    %bl,%al
  800d63:	74 12                	je     800d77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d65:	0f b6 c0             	movzbl %al,%eax
  800d68:	0f b6 db             	movzbl %bl,%ebx
  800d6b:	29 d8                	sub    %ebx,%eax
  800d6d:	eb 11                	jmp    800d80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d6f:	83 e9 01             	sub    $0x1,%ecx
  800d72:	ba 00 00 00 00       	mov    $0x0,%edx
  800d77:	85 c9                	test   %ecx,%ecx
  800d79:	75 d6                	jne    800d51 <memcmp+0x1f>
  800d7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d8b:	89 c2                	mov    %eax,%edx
  800d8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d90:	39 d0                	cmp    %edx,%eax
  800d92:	73 15                	jae    800da9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d98:	38 08                	cmp    %cl,(%eax)
  800d9a:	75 06                	jne    800da2 <memfind+0x1d>
  800d9c:	eb 0b                	jmp    800da9 <memfind+0x24>
  800d9e:	38 08                	cmp    %cl,(%eax)
  800da0:	74 07                	je     800da9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800da2:	83 c0 01             	add    $0x1,%eax
  800da5:	39 c2                	cmp    %eax,%edx
  800da7:	77 f5                	ja     800d9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
  800db1:	83 ec 04             	sub    $0x4,%esp
  800db4:	8b 55 08             	mov    0x8(%ebp),%edx
  800db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dba:	0f b6 02             	movzbl (%edx),%eax
  800dbd:	3c 20                	cmp    $0x20,%al
  800dbf:	74 04                	je     800dc5 <strtol+0x1a>
  800dc1:	3c 09                	cmp    $0x9,%al
  800dc3:	75 0e                	jne    800dd3 <strtol+0x28>
		s++;
  800dc5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dc8:	0f b6 02             	movzbl (%edx),%eax
  800dcb:	3c 20                	cmp    $0x20,%al
  800dcd:	74 f6                	je     800dc5 <strtol+0x1a>
  800dcf:	3c 09                	cmp    $0x9,%al
  800dd1:	74 f2                	je     800dc5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800dd3:	3c 2b                	cmp    $0x2b,%al
  800dd5:	75 0c                	jne    800de3 <strtol+0x38>
		s++;
  800dd7:	83 c2 01             	add    $0x1,%edx
  800dda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800de1:	eb 15                	jmp    800df8 <strtol+0x4d>
	else if (*s == '-')
  800de3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800dea:	3c 2d                	cmp    $0x2d,%al
  800dec:	75 0a                	jne    800df8 <strtol+0x4d>
		s++, neg = 1;
  800dee:	83 c2 01             	add    $0x1,%edx
  800df1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800df8:	85 db                	test   %ebx,%ebx
  800dfa:	0f 94 c0             	sete   %al
  800dfd:	74 05                	je     800e04 <strtol+0x59>
  800dff:	83 fb 10             	cmp    $0x10,%ebx
  800e02:	75 18                	jne    800e1c <strtol+0x71>
  800e04:	80 3a 30             	cmpb   $0x30,(%edx)
  800e07:	75 13                	jne    800e1c <strtol+0x71>
  800e09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e0d:	8d 76 00             	lea    0x0(%esi),%esi
  800e10:	75 0a                	jne    800e1c <strtol+0x71>
		s += 2, base = 16;
  800e12:	83 c2 02             	add    $0x2,%edx
  800e15:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e1a:	eb 15                	jmp    800e31 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e1c:	84 c0                	test   %al,%al
  800e1e:	66 90                	xchg   %ax,%ax
  800e20:	74 0f                	je     800e31 <strtol+0x86>
  800e22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e27:	80 3a 30             	cmpb   $0x30,(%edx)
  800e2a:	75 05                	jne    800e31 <strtol+0x86>
		s++, base = 8;
  800e2c:	83 c2 01             	add    $0x1,%edx
  800e2f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e38:	0f b6 0a             	movzbl (%edx),%ecx
  800e3b:	89 cf                	mov    %ecx,%edi
  800e3d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e40:	80 fb 09             	cmp    $0x9,%bl
  800e43:	77 08                	ja     800e4d <strtol+0xa2>
			dig = *s - '0';
  800e45:	0f be c9             	movsbl %cl,%ecx
  800e48:	83 e9 30             	sub    $0x30,%ecx
  800e4b:	eb 1e                	jmp    800e6b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e4d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e50:	80 fb 19             	cmp    $0x19,%bl
  800e53:	77 08                	ja     800e5d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e55:	0f be c9             	movsbl %cl,%ecx
  800e58:	83 e9 57             	sub    $0x57,%ecx
  800e5b:	eb 0e                	jmp    800e6b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e5d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e60:	80 fb 19             	cmp    $0x19,%bl
  800e63:	77 15                	ja     800e7a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e65:	0f be c9             	movsbl %cl,%ecx
  800e68:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e6b:	39 f1                	cmp    %esi,%ecx
  800e6d:	7d 0b                	jge    800e7a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e6f:	83 c2 01             	add    $0x1,%edx
  800e72:	0f af c6             	imul   %esi,%eax
  800e75:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e78:	eb be                	jmp    800e38 <strtol+0x8d>
  800e7a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e80:	74 05                	je     800e87 <strtol+0xdc>
		*endptr = (char *) s;
  800e82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e85:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e87:	89 ca                	mov    %ecx,%edx
  800e89:	f7 da                	neg    %edx
  800e8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e8f:	0f 45 c2             	cmovne %edx,%eax
}
  800e92:	83 c4 04             	add    $0x4,%esp
  800e95:	5b                   	pop    %ebx
  800e96:	5e                   	pop    %esi
  800e97:	5f                   	pop    %edi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    
	...

00800e9c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 48             	sub    $0x48,%esp
  800ea2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ea5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ea8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800eab:	89 c6                	mov    %eax,%esi
  800ead:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800eb0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800eb2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800eb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	51                   	push   %ecx
  800ebc:	52                   	push   %edx
  800ebd:	53                   	push   %ebx
  800ebe:	54                   	push   %esp
  800ebf:	55                   	push   %ebp
  800ec0:	56                   	push   %esi
  800ec1:	57                   	push   %edi
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	8d 35 cc 0e 80 00    	lea    0x800ecc,%esi
  800eca:	0f 34                	sysenter 

00800ecc <.after_sysenter_label>:
  800ecc:	5f                   	pop    %edi
  800ecd:	5e                   	pop    %esi
  800ece:	5d                   	pop    %ebp
  800ecf:	5c                   	pop    %esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5a                   	pop    %edx
  800ed2:	59                   	pop    %ecx
  800ed3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ed5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ed9:	74 28                	je     800f03 <.after_sysenter_label+0x37>
  800edb:	85 c0                	test   %eax,%eax
  800edd:	7e 24                	jle    800f03 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ee7:	c7 44 24 08 20 29 80 	movl   $0x802920,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ef6:	00 
  800ef7:	c7 04 24 3d 29 80 00 	movl   $0x80293d,(%esp)
  800efe:	e8 ad f3 ff ff       	call   8002b0 <_panic>

	return ret;
}
  800f03:	89 d0                	mov    %edx,%eax
  800f05:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f08:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f0b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0e:	89 ec                	mov    %ebp,%esp
  800f10:	5d                   	pop    %ebp
  800f11:	c3                   	ret    

00800f12 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800f18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1f:	00 
  800f20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f27:	00 
  800f28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f2f:	00 
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3e:	b8 10 00 00 00       	mov    $0x10,%eax
  800f43:	e8 54 ff ff ff       	call   800e9c <syscall>
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800f50:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f57:	00 
  800f58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f5f:	00 
  800f60:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f67:	00 
  800f68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f6f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f74:	ba 00 00 00 00       	mov    $0x0,%edx
  800f79:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f7e:	e8 19 ff ff ff       	call   800e9c <syscall>
}
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f8b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f92:	00 
  800f93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f9a:	00 
  800f9b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa2:	00 
  800fa3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800faa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fad:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fb7:	e8 e0 fe ff ff       	call   800e9c <syscall>
}
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800fc4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fcb:	00 
  800fcc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fed:	e8 aa fe ff ff       	call   800e9c <syscall>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ffa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801011:	00 
  801012:	8b 45 0c             	mov    0xc(%ebp),%eax
  801015:	89 04 24             	mov    %eax,(%esp)
  801018:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101b:	ba 01 00 00 00       	mov    $0x1,%edx
  801020:	b8 0b 00 00 00       	mov    $0xb,%eax
  801025:	e8 72 fe ff ff       	call   800e9c <syscall>
}
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    

0080102c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80102c:	55                   	push   %ebp
  80102d:	89 e5                	mov    %esp,%ebp
  80102f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801032:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801039:	00 
  80103a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801041:	00 
  801042:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801049:	00 
  80104a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104d:	89 04 24             	mov    %eax,(%esp)
  801050:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801053:	ba 01 00 00 00       	mov    $0x1,%edx
  801058:	b8 0a 00 00 00       	mov    $0xa,%eax
  80105d:	e8 3a fe ff ff       	call   800e9c <syscall>
}
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80106a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801071:	00 
  801072:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801079:	00 
  80107a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801081:	00 
  801082:	8b 45 0c             	mov    0xc(%ebp),%eax
  801085:	89 04 24             	mov    %eax,(%esp)
  801088:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108b:	ba 01 00 00 00       	mov    $0x1,%edx
  801090:	b8 09 00 00 00       	mov    $0x9,%eax
  801095:	e8 02 fe ff ff       	call   800e9c <syscall>
}
  80109a:	c9                   	leave  
  80109b:	c3                   	ret    

0080109c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80109c:	55                   	push   %ebp
  80109d:	89 e5                	mov    %esp,%ebp
  80109f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010a2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b1:	00 
  8010b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b9:	00 
  8010ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010bd:	89 04 24             	mov    %eax,(%esp)
  8010c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c3:	ba 01 00 00 00       	mov    $0x1,%edx
  8010c8:	b8 07 00 00 00       	mov    $0x7,%eax
  8010cd:	e8 ca fd ff ff       	call   800e9c <syscall>
}
  8010d2:	c9                   	leave  
  8010d3:	c3                   	ret    

008010d4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8010da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e1:	00 
  8010e2:	8b 45 18             	mov    0x18(%ebp),%eax
  8010e5:	0b 45 14             	or     0x14(%ebp),%eax
  8010e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f6:	89 04 24             	mov    %eax,(%esp)
  8010f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fc:	ba 01 00 00 00       	mov    $0x1,%edx
  801101:	b8 06 00 00 00       	mov    $0x6,%eax
  801106:	e8 91 fd ff ff       	call   800e9c <syscall>
}
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801113:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80111a:	00 
  80111b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801122:	00 
  801123:	8b 45 10             	mov    0x10(%ebp),%eax
  801126:	89 44 24 04          	mov    %eax,0x4(%esp)
  80112a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112d:	89 04 24             	mov    %eax,(%esp)
  801130:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801133:	ba 01 00 00 00       	mov    $0x1,%edx
  801138:	b8 05 00 00 00       	mov    $0x5,%eax
  80113d:	e8 5a fd ff ff       	call   800e9c <syscall>
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80114a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801151:	00 
  801152:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801159:	00 
  80115a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801161:	00 
  801162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801169:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116e:	ba 00 00 00 00       	mov    $0x0,%edx
  801173:	b8 0c 00 00 00       	mov    $0xc,%eax
  801178:	e8 1f fd ff ff       	call   800e9c <syscall>
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801185:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80118c:	00 
  80118d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801194:	00 
  801195:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80119c:	00 
  80119d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a0:	89 04 24             	mov    %eax,(%esp)
  8011a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ab:	b8 04 00 00 00       	mov    $0x4,%eax
  8011b0:	e8 e7 fc ff ff       	call   800e9c <syscall>
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8011bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cc:	00 
  8011cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011d4:	00 
  8011d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e6:	b8 02 00 00 00       	mov    $0x2,%eax
  8011eb:	e8 ac fc ff ff       	call   800e9c <syscall>
}
  8011f0:	c9                   	leave  
  8011f1:	c3                   	ret    

008011f2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8011f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011ff:	00 
  801200:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801207:	00 
  801208:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80120f:	00 
  801210:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801217:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121a:	ba 01 00 00 00       	mov    $0x1,%edx
  80121f:	b8 03 00 00 00       	mov    $0x3,%eax
  801224:	e8 73 fc ff ff       	call   800e9c <syscall>
}
  801229:	c9                   	leave  
  80122a:	c3                   	ret    

0080122b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801231:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801238:	00 
  801239:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801240:	00 
  801241:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801248:	00 
  801249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801250:	b9 00 00 00 00       	mov    $0x0,%ecx
  801255:	ba 00 00 00 00       	mov    $0x0,%edx
  80125a:	b8 01 00 00 00       	mov    $0x1,%eax
  80125f:	e8 38 fc ff ff       	call   800e9c <syscall>
}
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80126c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801273:	00 
  801274:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80127b:	00 
  80127c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801283:	00 
  801284:	8b 45 0c             	mov    0xc(%ebp),%eax
  801287:	89 04 24             	mov    %eax,(%esp)
  80128a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128d:	ba 00 00 00 00       	mov    $0x0,%edx
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	e8 00 fc ff ff       	call   800e9c <syscall>
}
  80129c:	c9                   	leave  
  80129d:	c3                   	ret    
	...

008012a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012ab:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8012b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b9:	89 04 24             	mov    %eax,(%esp)
  8012bc:	e8 df ff ff ff       	call   8012a0 <fd2num>
  8012c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8012c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8012c9:	c9                   	leave  
  8012ca:	c3                   	ret    

008012cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	57                   	push   %edi
  8012cf:	56                   	push   %esi
  8012d0:	53                   	push   %ebx
  8012d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8012d4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8012d9:	a8 01                	test   $0x1,%al
  8012db:	74 36                	je     801313 <fd_alloc+0x48>
  8012dd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012e2:	a8 01                	test   $0x1,%al
  8012e4:	74 2d                	je     801313 <fd_alloc+0x48>
  8012e6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8012eb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8012f0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8012f5:	89 c3                	mov    %eax,%ebx
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	c1 ea 16             	shr    $0x16,%edx
  8012fc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8012ff:	f6 c2 01             	test   $0x1,%dl
  801302:	74 14                	je     801318 <fd_alloc+0x4d>
  801304:	89 c2                	mov    %eax,%edx
  801306:	c1 ea 0c             	shr    $0xc,%edx
  801309:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80130c:	f6 c2 01             	test   $0x1,%dl
  80130f:	75 10                	jne    801321 <fd_alloc+0x56>
  801311:	eb 05                	jmp    801318 <fd_alloc+0x4d>
  801313:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801318:	89 1f                	mov    %ebx,(%edi)
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80131f:	eb 17                	jmp    801338 <fd_alloc+0x6d>
  801321:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801326:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80132b:	75 c8                	jne    8012f5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80132d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801333:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801338:	5b                   	pop    %ebx
  801339:	5e                   	pop    %esi
  80133a:	5f                   	pop    %edi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	83 f8 1f             	cmp    $0x1f,%eax
  801346:	77 36                	ja     80137e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801348:	05 00 00 0d 00       	add    $0xd0000,%eax
  80134d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801350:	89 c2                	mov    %eax,%edx
  801352:	c1 ea 16             	shr    $0x16,%edx
  801355:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80135c:	f6 c2 01             	test   $0x1,%dl
  80135f:	74 1d                	je     80137e <fd_lookup+0x41>
  801361:	89 c2                	mov    %eax,%edx
  801363:	c1 ea 0c             	shr    $0xc,%edx
  801366:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80136d:	f6 c2 01             	test   $0x1,%dl
  801370:	74 0c                	je     80137e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801372:	8b 55 0c             	mov    0xc(%ebp),%edx
  801375:	89 02                	mov    %eax,(%edx)
  801377:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80137c:	eb 05                	jmp    801383 <fd_lookup+0x46>
  80137e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80138e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801392:	8b 45 08             	mov    0x8(%ebp),%eax
  801395:	89 04 24             	mov    %eax,(%esp)
  801398:	e8 a0 ff ff ff       	call   80133d <fd_lookup>
  80139d:	85 c0                	test   %eax,%eax
  80139f:	78 0e                	js     8013af <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8013a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8013a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013a7:	89 50 04             	mov    %edx,0x4(%eax)
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    

008013b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013b1:	55                   	push   %ebp
  8013b2:	89 e5                	mov    %esp,%ebp
  8013b4:	56                   	push   %esi
  8013b5:	53                   	push   %ebx
  8013b6:	83 ec 10             	sub    $0x10,%esp
  8013b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8013c4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8013c9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8013cf:	75 11                	jne    8013e2 <dev_lookup+0x31>
  8013d1:	eb 04                	jmp    8013d7 <dev_lookup+0x26>
  8013d3:	39 08                	cmp    %ecx,(%eax)
  8013d5:	75 10                	jne    8013e7 <dev_lookup+0x36>
			*dev = devtab[i];
  8013d7:	89 03                	mov    %eax,(%ebx)
  8013d9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8013de:	66 90                	xchg   %ax,%ax
  8013e0:	eb 36                	jmp    801418 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013e2:	be cc 29 80 00       	mov    $0x8029cc,%esi
  8013e7:	83 c2 01             	add    $0x1,%edx
  8013ea:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	75 e2                	jne    8013d3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013f1:	a1 08 40 80 00       	mov    0x804008,%eax
  8013f6:	8b 40 48             	mov    0x48(%eax),%eax
  8013f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801401:	c7 04 24 4c 29 80 00 	movl   $0x80294c,(%esp)
  801408:	e8 5c ef ff ff       	call   800369 <cprintf>
	*dev = 0;
  80140d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801413:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5e                   	pop    %esi
  80141d:	5d                   	pop    %ebp
  80141e:	c3                   	ret    

0080141f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	53                   	push   %ebx
  801423:	83 ec 24             	sub    $0x24,%esp
  801426:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801429:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801430:	8b 45 08             	mov    0x8(%ebp),%eax
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	e8 02 ff ff ff       	call   80133d <fd_lookup>
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 53                	js     801492 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801449:	8b 00                	mov    (%eax),%eax
  80144b:	89 04 24             	mov    %eax,(%esp)
  80144e:	e8 5e ff ff ff       	call   8013b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801453:	85 c0                	test   %eax,%eax
  801455:	78 3b                	js     801492 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801457:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80145c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80145f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801463:	74 2d                	je     801492 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801465:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801468:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80146f:	00 00 00 
	stat->st_isdir = 0;
  801472:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801479:	00 00 00 
	stat->st_dev = dev;
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801485:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801489:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80148c:	89 14 24             	mov    %edx,(%esp)
  80148f:	ff 50 14             	call   *0x14(%eax)
}
  801492:	83 c4 24             	add    $0x24,%esp
  801495:	5b                   	pop    %ebx
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 24             	sub    $0x24,%esp
  80149f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	89 1c 24             	mov    %ebx,(%esp)
  8014ac:	e8 8c fe ff ff       	call   80133d <fd_lookup>
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 5f                	js     801514 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bf:	8b 00                	mov    (%eax),%eax
  8014c1:	89 04 24             	mov    %eax,(%esp)
  8014c4:	e8 e8 fe ff ff       	call   8013b1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 47                	js     801514 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014d4:	75 23                	jne    8014f9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014d6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014db:	8b 40 48             	mov    0x48(%eax),%eax
  8014de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e6:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  8014ed:	e8 77 ee ff ff       	call   800369 <cprintf>
  8014f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f7:	eb 1b                	jmp    801514 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fc:	8b 48 18             	mov    0x18(%eax),%ecx
  8014ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801504:	85 c9                	test   %ecx,%ecx
  801506:	74 0c                	je     801514 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80150b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150f:	89 14 24             	mov    %edx,(%esp)
  801512:	ff d1                	call   *%ecx
}
  801514:	83 c4 24             	add    $0x24,%esp
  801517:	5b                   	pop    %ebx
  801518:	5d                   	pop    %ebp
  801519:	c3                   	ret    

0080151a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	53                   	push   %ebx
  80151e:	83 ec 24             	sub    $0x24,%esp
  801521:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801524:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801527:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152b:	89 1c 24             	mov    %ebx,(%esp)
  80152e:	e8 0a fe ff ff       	call   80133d <fd_lookup>
  801533:	85 c0                	test   %eax,%eax
  801535:	78 66                	js     80159d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801537:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801541:	8b 00                	mov    (%eax),%eax
  801543:	89 04 24             	mov    %eax,(%esp)
  801546:	e8 66 fe ff ff       	call   8013b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 4e                	js     80159d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801552:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801556:	75 23                	jne    80157b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801558:	a1 08 40 80 00       	mov    0x804008,%eax
  80155d:	8b 40 48             	mov    0x48(%eax),%eax
  801560:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801564:	89 44 24 04          	mov    %eax,0x4(%esp)
  801568:	c7 04 24 90 29 80 00 	movl   $0x802990,(%esp)
  80156f:	e8 f5 ed ff ff       	call   800369 <cprintf>
  801574:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801579:	eb 22                	jmp    80159d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80157b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801581:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801586:	85 c9                	test   %ecx,%ecx
  801588:	74 13                	je     80159d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80158a:	8b 45 10             	mov    0x10(%ebp),%eax
  80158d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801591:	8b 45 0c             	mov    0xc(%ebp),%eax
  801594:	89 44 24 04          	mov    %eax,0x4(%esp)
  801598:	89 14 24             	mov    %edx,(%esp)
  80159b:	ff d1                	call   *%ecx
}
  80159d:	83 c4 24             	add    $0x24,%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5d                   	pop    %ebp
  8015a2:	c3                   	ret    

008015a3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 24             	sub    $0x24,%esp
  8015aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b4:	89 1c 24             	mov    %ebx,(%esp)
  8015b7:	e8 81 fd ff ff       	call   80133d <fd_lookup>
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 6b                	js     80162b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	8b 00                	mov    (%eax),%eax
  8015cc:	89 04 24             	mov    %eax,(%esp)
  8015cf:	e8 dd fd ff ff       	call   8013b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 53                	js     80162b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015db:	8b 42 08             	mov    0x8(%edx),%eax
  8015de:	83 e0 03             	and    $0x3,%eax
  8015e1:	83 f8 01             	cmp    $0x1,%eax
  8015e4:	75 23                	jne    801609 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015e6:	a1 08 40 80 00       	mov    0x804008,%eax
  8015eb:	8b 40 48             	mov    0x48(%eax),%eax
  8015ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	c7 04 24 ad 29 80 00 	movl   $0x8029ad,(%esp)
  8015fd:	e8 67 ed ff ff       	call   800369 <cprintf>
  801602:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801607:	eb 22                	jmp    80162b <read+0x88>
	}
	if (!dev->dev_read)
  801609:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160c:	8b 48 08             	mov    0x8(%eax),%ecx
  80160f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801614:	85 c9                	test   %ecx,%ecx
  801616:	74 13                	je     80162b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801618:	8b 45 10             	mov    0x10(%ebp),%eax
  80161b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80161f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801622:	89 44 24 04          	mov    %eax,0x4(%esp)
  801626:	89 14 24             	mov    %edx,(%esp)
  801629:	ff d1                	call   *%ecx
}
  80162b:	83 c4 24             	add    $0x24,%esp
  80162e:	5b                   	pop    %ebx
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    

00801631 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	57                   	push   %edi
  801635:	56                   	push   %esi
  801636:	53                   	push   %ebx
  801637:	83 ec 1c             	sub    $0x1c,%esp
  80163a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80163d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801640:	ba 00 00 00 00       	mov    $0x0,%edx
  801645:	bb 00 00 00 00       	mov    $0x0,%ebx
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
  80164f:	85 f6                	test   %esi,%esi
  801651:	74 29                	je     80167c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801653:	89 f0                	mov    %esi,%eax
  801655:	29 d0                	sub    %edx,%eax
  801657:	89 44 24 08          	mov    %eax,0x8(%esp)
  80165b:	03 55 0c             	add    0xc(%ebp),%edx
  80165e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801662:	89 3c 24             	mov    %edi,(%esp)
  801665:	e8 39 ff ff ff       	call   8015a3 <read>
		if (m < 0)
  80166a:	85 c0                	test   %eax,%eax
  80166c:	78 0e                	js     80167c <readn+0x4b>
			return m;
		if (m == 0)
  80166e:	85 c0                	test   %eax,%eax
  801670:	74 08                	je     80167a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801672:	01 c3                	add    %eax,%ebx
  801674:	89 da                	mov    %ebx,%edx
  801676:	39 f3                	cmp    %esi,%ebx
  801678:	72 d9                	jb     801653 <readn+0x22>
  80167a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80167c:	83 c4 1c             	add    $0x1c,%esp
  80167f:	5b                   	pop    %ebx
  801680:	5e                   	pop    %esi
  801681:	5f                   	pop    %edi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 28             	sub    $0x28,%esp
  80168a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80168d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801690:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801693:	89 34 24             	mov    %esi,(%esp)
  801696:	e8 05 fc ff ff       	call   8012a0 <fd2num>
  80169b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80169e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8016a2:	89 04 24             	mov    %eax,(%esp)
  8016a5:	e8 93 fc ff ff       	call   80133d <fd_lookup>
  8016aa:	89 c3                	mov    %eax,%ebx
  8016ac:	85 c0                	test   %eax,%eax
  8016ae:	78 05                	js     8016b5 <fd_close+0x31>
  8016b0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8016b3:	74 0e                	je     8016c3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8016b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8016b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8016be:	0f 44 d8             	cmove  %eax,%ebx
  8016c1:	eb 3d                	jmp    801700 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8016c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ca:	8b 06                	mov    (%esi),%eax
  8016cc:	89 04 24             	mov    %eax,(%esp)
  8016cf:	e8 dd fc ff ff       	call   8013b1 <dev_lookup>
  8016d4:	89 c3                	mov    %eax,%ebx
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 16                	js     8016f0 <fd_close+0x6c>
		if (dev->dev_close)
  8016da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dd:	8b 40 10             	mov    0x10(%eax),%eax
  8016e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	74 07                	je     8016f0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8016e9:	89 34 24             	mov    %esi,(%esp)
  8016ec:	ff d0                	call   *%eax
  8016ee:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016fb:	e8 9c f9 ff ff       	call   80109c <sys_page_unmap>
	return r;
}
  801700:	89 d8                	mov    %ebx,%eax
  801702:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801705:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801708:	89 ec                	mov    %ebp,%esp
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    

0080170c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801712:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801715:	89 44 24 04          	mov    %eax,0x4(%esp)
  801719:	8b 45 08             	mov    0x8(%ebp),%eax
  80171c:	89 04 24             	mov    %eax,(%esp)
  80171f:	e8 19 fc ff ff       	call   80133d <fd_lookup>
  801724:	85 c0                	test   %eax,%eax
  801726:	78 13                	js     80173b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801728:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80172f:	00 
  801730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801733:	89 04 24             	mov    %eax,(%esp)
  801736:	e8 49 ff ff ff       	call   801684 <fd_close>
}
  80173b:	c9                   	leave  
  80173c:	c3                   	ret    

0080173d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
  801740:	83 ec 18             	sub    $0x18,%esp
  801743:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801746:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801749:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801750:	00 
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	e8 78 03 00 00       	call   801ad4 <open>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 1b                	js     80177d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801762:	8b 45 0c             	mov    0xc(%ebp),%eax
  801765:	89 44 24 04          	mov    %eax,0x4(%esp)
  801769:	89 1c 24             	mov    %ebx,(%esp)
  80176c:	e8 ae fc ff ff       	call   80141f <fstat>
  801771:	89 c6                	mov    %eax,%esi
	close(fd);
  801773:	89 1c 24             	mov    %ebx,(%esp)
  801776:	e8 91 ff ff ff       	call   80170c <close>
  80177b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80177d:	89 d8                	mov    %ebx,%eax
  80177f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801782:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801785:	89 ec                	mov    %ebp,%esp
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	53                   	push   %ebx
  80178d:	83 ec 14             	sub    $0x14,%esp
  801790:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801795:	89 1c 24             	mov    %ebx,(%esp)
  801798:	e8 6f ff ff ff       	call   80170c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80179d:	83 c3 01             	add    $0x1,%ebx
  8017a0:	83 fb 20             	cmp    $0x20,%ebx
  8017a3:	75 f0                	jne    801795 <close_all+0xc>
		close(i);
}
  8017a5:	83 c4 14             	add    $0x14,%esp
  8017a8:	5b                   	pop    %ebx
  8017a9:	5d                   	pop    %ebp
  8017aa:	c3                   	ret    

008017ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	83 ec 58             	sub    $0x58,%esp
  8017b1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017b4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017b7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8017ba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8017bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8017c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c7:	89 04 24             	mov    %eax,(%esp)
  8017ca:	e8 6e fb ff ff       	call   80133d <fd_lookup>
  8017cf:	89 c3                	mov    %eax,%ebx
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	0f 88 e0 00 00 00    	js     8018b9 <dup+0x10e>
		return r;
	close(newfdnum);
  8017d9:	89 3c 24             	mov    %edi,(%esp)
  8017dc:	e8 2b ff ff ff       	call   80170c <close>

	newfd = INDEX2FD(newfdnum);
  8017e1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8017e7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8017ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ed:	89 04 24             	mov    %eax,(%esp)
  8017f0:	e8 bb fa ff ff       	call   8012b0 <fd2data>
  8017f5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017f7:	89 34 24             	mov    %esi,(%esp)
  8017fa:	e8 b1 fa ff ff       	call   8012b0 <fd2data>
  8017ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801802:	89 da                	mov    %ebx,%edx
  801804:	89 d8                	mov    %ebx,%eax
  801806:	c1 e8 16             	shr    $0x16,%eax
  801809:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801810:	a8 01                	test   $0x1,%al
  801812:	74 43                	je     801857 <dup+0xac>
  801814:	c1 ea 0c             	shr    $0xc,%edx
  801817:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80181e:	a8 01                	test   $0x1,%al
  801820:	74 35                	je     801857 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801822:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801829:	25 07 0e 00 00       	and    $0xe07,%eax
  80182e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801835:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801839:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801840:	00 
  801841:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801845:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80184c:	e8 83 f8 ff ff       	call   8010d4 <sys_page_map>
  801851:	89 c3                	mov    %eax,%ebx
  801853:	85 c0                	test   %eax,%eax
  801855:	78 3f                	js     801896 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801857:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80185a:	89 c2                	mov    %eax,%edx
  80185c:	c1 ea 0c             	shr    $0xc,%edx
  80185f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801866:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80186c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801870:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801874:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80187b:	00 
  80187c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801880:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801887:	e8 48 f8 ff ff       	call   8010d4 <sys_page_map>
  80188c:	89 c3                	mov    %eax,%ebx
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 04                	js     801896 <dup+0xeb>
  801892:	89 fb                	mov    %edi,%ebx
  801894:	eb 23                	jmp    8018b9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801896:	89 74 24 04          	mov    %esi,0x4(%esp)
  80189a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a1:	e8 f6 f7 ff ff       	call   80109c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8018a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8018a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b4:	e8 e3 f7 ff ff       	call   80109c <sys_page_unmap>
	return r;
}
  8018b9:	89 d8                	mov    %ebx,%eax
  8018bb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8018be:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8018c1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018c4:	89 ec                	mov    %ebp,%esp
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    

008018c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	83 ec 18             	sub    $0x18,%esp
  8018ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018d1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8018d8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8018df:	75 11                	jne    8018f2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018e1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8018e8:	e8 b3 07 00 00       	call   8020a0 <ipc_find_env>
  8018ed:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018f2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018f9:	00 
  8018fa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801901:	00 
  801902:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801906:	a1 00 40 80 00       	mov    0x804000,%eax
  80190b:	89 04 24             	mov    %eax,(%esp)
  80190e:	e8 d6 07 00 00       	call   8020e9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801913:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80191a:	00 
  80191b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80191f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801926:	e8 29 08 00 00       	call   802154 <ipc_recv>
}
  80192b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80192e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801931:	89 ec                	mov    %ebp,%esp
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80193b:	8b 45 08             	mov    0x8(%ebp),%eax
  80193e:	8b 40 0c             	mov    0xc(%eax),%eax
  801941:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801946:	8b 45 0c             	mov    0xc(%ebp),%eax
  801949:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80194e:	ba 00 00 00 00       	mov    $0x0,%edx
  801953:	b8 02 00 00 00       	mov    $0x2,%eax
  801958:	e8 6b ff ff ff       	call   8018c8 <fsipc>
}
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    

0080195f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80195f:	55                   	push   %ebp
  801960:	89 e5                	mov    %esp,%ebp
  801962:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801965:	8b 45 08             	mov    0x8(%ebp),%eax
  801968:	8b 40 0c             	mov    0xc(%eax),%eax
  80196b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801970:	ba 00 00 00 00       	mov    $0x0,%edx
  801975:	b8 06 00 00 00       	mov    $0x6,%eax
  80197a:	e8 49 ff ff ff       	call   8018c8 <fsipc>
}
  80197f:	c9                   	leave  
  801980:	c3                   	ret    

00801981 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801987:	ba 00 00 00 00       	mov    $0x0,%edx
  80198c:	b8 08 00 00 00       	mov    $0x8,%eax
  801991:	e8 32 ff ff ff       	call   8018c8 <fsipc>
}
  801996:	c9                   	leave  
  801997:	c3                   	ret    

00801998 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801998:	55                   	push   %ebp
  801999:	89 e5                	mov    %esp,%ebp
  80199b:	53                   	push   %ebx
  80199c:	83 ec 14             	sub    $0x14,%esp
  80199f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8019b7:	e8 0c ff ff ff       	call   8018c8 <fsipc>
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 2b                	js     8019eb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019c0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019c7:	00 
  8019c8:	89 1c 24             	mov    %ebx,(%esp)
  8019cb:	e8 da f0 ff ff       	call   800aaa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8019d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8019db:	a1 84 50 80 00       	mov    0x805084,%eax
  8019e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8019e6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8019eb:	83 c4 14             	add    $0x14,%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 18             	sub    $0x18,%esp
  8019f7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8019fd:	8b 52 0c             	mov    0xc(%edx),%edx
  801a00:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801a06:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801a0b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a10:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a15:	0f 47 c2             	cmova  %edx,%eax
  801a18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a23:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801a2a:	e8 66 f2 ff ff       	call   800c95 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a34:	b8 04 00 00 00       	mov    $0x4,%eax
  801a39:	e8 8a fe ff ff       	call   8018c8 <fsipc>
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	53                   	push   %ebx
  801a44:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801a52:	8b 45 10             	mov    0x10(%ebp),%eax
  801a55:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5f:	b8 03 00 00 00       	mov    $0x3,%eax
  801a64:	e8 5f fe ff ff       	call   8018c8 <fsipc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 17                	js     801a86 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a73:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a7a:	00 
  801a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7e:	89 04 24             	mov    %eax,(%esp)
  801a81:	e8 0f f2 ff ff       	call   800c95 <memmove>
  return r;	
}
  801a86:	89 d8                	mov    %ebx,%eax
  801a88:	83 c4 14             	add    $0x14,%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	53                   	push   %ebx
  801a92:	83 ec 14             	sub    $0x14,%esp
  801a95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a98:	89 1c 24             	mov    %ebx,(%esp)
  801a9b:	e8 c0 ef ff ff       	call   800a60 <strlen>
  801aa0:	89 c2                	mov    %eax,%edx
  801aa2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801aa7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801aad:	7f 1f                	jg     801ace <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801aaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801aba:	e8 eb ef ff ff       	call   800aaa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801abf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac4:	b8 07 00 00 00       	mov    $0x7,%eax
  801ac9:	e8 fa fd ff ff       	call   8018c8 <fsipc>
}
  801ace:	83 c4 14             	add    $0x14,%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5d                   	pop    %ebp
  801ad3:	c3                   	ret    

00801ad4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	83 ec 28             	sub    $0x28,%esp
  801ada:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801add:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ae0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801ae3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ae6:	89 04 24             	mov    %eax,(%esp)
  801ae9:	e8 dd f7 ff ff       	call   8012cb <fd_alloc>
  801aee:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801af0:	85 c0                	test   %eax,%eax
  801af2:	0f 88 89 00 00 00    	js     801b81 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801af8:	89 34 24             	mov    %esi,(%esp)
  801afb:	e8 60 ef ff ff       	call   800a60 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801b00:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801b05:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b0a:	7f 75                	jg     801b81 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801b0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b10:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801b17:	e8 8e ef ff ff       	call   800aaa <strcpy>
  fsipcbuf.open.req_omode = mode;
  801b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801b24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b27:	b8 01 00 00 00       	mov    $0x1,%eax
  801b2c:	e8 97 fd ff ff       	call   8018c8 <fsipc>
  801b31:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 0f                	js     801b46 <open+0x72>
  return fd2num(fd);
  801b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3a:	89 04 24             	mov    %eax,(%esp)
  801b3d:	e8 5e f7 ff ff       	call   8012a0 <fd2num>
  801b42:	89 c3                	mov    %eax,%ebx
  801b44:	eb 3b                	jmp    801b81 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801b46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b4d:	00 
  801b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 2b fb ff ff       	call   801684 <fd_close>
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	74 24                	je     801b81 <open+0xad>
  801b5d:	c7 44 24 0c d8 29 80 	movl   $0x8029d8,0xc(%esp)
  801b64:	00 
  801b65:	c7 44 24 08 ed 29 80 	movl   $0x8029ed,0x8(%esp)
  801b6c:	00 
  801b6d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801b74:	00 
  801b75:	c7 04 24 02 2a 80 00 	movl   $0x802a02,(%esp)
  801b7c:	e8 2f e7 ff ff       	call   8002b0 <_panic>
  return r;
}
  801b81:	89 d8                	mov    %ebx,%eax
  801b83:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b86:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b89:	89 ec                	mov    %ebp,%esp
  801b8b:	5d                   	pop    %ebp
  801b8c:	c3                   	ret    
  801b8d:	00 00                	add    %al,(%eax)
	...

00801b90 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b96:	c7 44 24 04 0d 2a 80 	movl   $0x802a0d,0x4(%esp)
  801b9d:	00 
  801b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba1:	89 04 24             	mov    %eax,(%esp)
  801ba4:	e8 01 ef ff ff       	call   800aaa <strcpy>
	return 0;
}
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 14             	sub    $0x14,%esp
  801bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bba:	89 1c 24             	mov    %ebx,(%esp)
  801bbd:	e8 22 06 00 00       	call   8021e4 <pageref>
  801bc2:	89 c2                	mov    %eax,%edx
  801bc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc9:	83 fa 01             	cmp    $0x1,%edx
  801bcc:	75 0b                	jne    801bd9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801bce:	8b 43 0c             	mov    0xc(%ebx),%eax
  801bd1:	89 04 24             	mov    %eax,(%esp)
  801bd4:	e8 b9 02 00 00       	call   801e92 <nsipc_close>
	else
		return 0;
}
  801bd9:	83 c4 14             	add    $0x14,%esp
  801bdc:	5b                   	pop    %ebx
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801be5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801bec:	00 
  801bed:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfe:	8b 40 0c             	mov    0xc(%eax),%eax
  801c01:	89 04 24             	mov    %eax,(%esp)
  801c04:	e8 c5 02 00 00       	call   801ece <nsipc_send>
}
  801c09:	c9                   	leave  
  801c0a:	c3                   	ret    

00801c0b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c11:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801c18:	00 
  801c19:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c20:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c27:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c2d:	89 04 24             	mov    %eax,(%esp)
  801c30:	e8 0c 03 00 00       	call   801f41 <nsipc_recv>
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 20             	sub    $0x20,%esp
  801c3f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c41:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c44:	89 04 24             	mov    %eax,(%esp)
  801c47:	e8 7f f6 ff ff       	call   8012cb <fd_alloc>
  801c4c:	89 c3                	mov    %eax,%ebx
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 21                	js     801c73 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c52:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801c59:	00 
  801c5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c61:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c68:	e8 a0 f4 ff ff       	call   80110d <sys_page_alloc>
  801c6d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	79 0a                	jns    801c7d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801c73:	89 34 24             	mov    %esi,(%esp)
  801c76:	e8 17 02 00 00       	call   801e92 <nsipc_close>
		return r;
  801c7b:	eb 28                	jmp    801ca5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c83:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c86:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c95:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 fd f5 ff ff       	call   8012a0 <fd2num>
  801ca3:	89 c3                	mov    %eax,%ebx
}
  801ca5:	89 d8                	mov    %ebx,%eax
  801ca7:	83 c4 20             	add    $0x20,%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cb4:	8b 45 10             	mov    0x10(%ebp),%eax
  801cb7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc5:	89 04 24             	mov    %eax,(%esp)
  801cc8:	e8 79 01 00 00       	call   801e46 <nsipc_socket>
  801ccd:	85 c0                	test   %eax,%eax
  801ccf:	78 05                	js     801cd6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801cd1:	e8 61 ff ff ff       	call   801c37 <alloc_sockfd>
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801cde:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ce1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce5:	89 04 24             	mov    %eax,(%esp)
  801ce8:	e8 50 f6 ff ff       	call   80133d <fd_lookup>
  801ced:	85 c0                	test   %eax,%eax
  801cef:	78 15                	js     801d06 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801cf1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cf4:	8b 0a                	mov    (%edx),%ecx
  801cf6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801cfb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801d01:	75 03                	jne    801d06 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d03:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    

00801d08 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d11:	e8 c2 ff ff ff       	call   801cd8 <fd2sockid>
  801d16:	85 c0                	test   %eax,%eax
  801d18:	78 0f                	js     801d29 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d1a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d21:	89 04 24             	mov    %eax,(%esp)
  801d24:	e8 47 01 00 00       	call   801e70 <nsipc_listen>
}
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d31:	8b 45 08             	mov    0x8(%ebp),%eax
  801d34:	e8 9f ff ff ff       	call   801cd8 <fd2sockid>
  801d39:	85 c0                	test   %eax,%eax
  801d3b:	78 16                	js     801d53 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801d3d:	8b 55 10             	mov    0x10(%ebp),%edx
  801d40:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d47:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d4b:	89 04 24             	mov    %eax,(%esp)
  801d4e:	e8 6e 02 00 00       	call   801fc1 <nsipc_connect>
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    

00801d55 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	e8 75 ff ff ff       	call   801cd8 <fd2sockid>
  801d63:	85 c0                	test   %eax,%eax
  801d65:	78 0f                	js     801d76 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d67:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d6e:	89 04 24             	mov    %eax,(%esp)
  801d71:	e8 36 01 00 00       	call   801eac <nsipc_shutdown>
}
  801d76:	c9                   	leave  
  801d77:	c3                   	ret    

00801d78 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d81:	e8 52 ff ff ff       	call   801cd8 <fd2sockid>
  801d86:	85 c0                	test   %eax,%eax
  801d88:	78 16                	js     801da0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801d8a:	8b 55 10             	mov    0x10(%ebp),%edx
  801d8d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d91:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d94:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d98:	89 04 24             	mov    %eax,(%esp)
  801d9b:	e8 60 02 00 00       	call   802000 <nsipc_bind>
}
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    

00801da2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	e8 28 ff ff ff       	call   801cd8 <fd2sockid>
  801db0:	85 c0                	test   %eax,%eax
  801db2:	78 1f                	js     801dd3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801db4:	8b 55 10             	mov    0x10(%ebp),%edx
  801db7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801dbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc2:	89 04 24             	mov    %eax,(%esp)
  801dc5:	e8 75 02 00 00       	call   80203f <nsipc_accept>
  801dca:	85 c0                	test   %eax,%eax
  801dcc:	78 05                	js     801dd3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801dce:	e8 64 fe ff ff       	call   801c37 <alloc_sockfd>
}
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    
	...

00801de0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	53                   	push   %ebx
  801de4:	83 ec 14             	sub    $0x14,%esp
  801de7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801de9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801df0:	75 11                	jne    801e03 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801df2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801df9:	e8 a2 02 00 00       	call   8020a0 <ipc_find_env>
  801dfe:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e03:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801e0a:	00 
  801e0b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801e12:	00 
  801e13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e17:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1c:	89 04 24             	mov    %eax,(%esp)
  801e1f:	e8 c5 02 00 00       	call   8020e9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e2b:	00 
  801e2c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e33:	00 
  801e34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3b:	e8 14 03 00 00       	call   802154 <ipc_recv>
}
  801e40:	83 c4 14             	add    $0x14,%esp
  801e43:	5b                   	pop    %ebx
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    

00801e46 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e57:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e5c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e64:	b8 09 00 00 00       	mov    $0x9,%eax
  801e69:	e8 72 ff ff ff       	call   801de0 <nsipc>
}
  801e6e:	c9                   	leave  
  801e6f:	c3                   	ret    

00801e70 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801e70:	55                   	push   %ebp
  801e71:	89 e5                	mov    %esp,%ebp
  801e73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e76:	8b 45 08             	mov    0x8(%ebp),%eax
  801e79:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e81:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e86:	b8 06 00 00 00       	mov    $0x6,%eax
  801e8b:	e8 50 ff ff ff       	call   801de0 <nsipc>
}
  801e90:	c9                   	leave  
  801e91:	c3                   	ret    

00801e92 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e98:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ea0:	b8 04 00 00 00       	mov    $0x4,%eax
  801ea5:	e8 36 ff ff ff       	call   801de0 <nsipc>
}
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ec2:	b8 03 00 00 00       	mov    $0x3,%eax
  801ec7:	e8 14 ff ff ff       	call   801de0 <nsipc>
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	53                   	push   %ebx
  801ed2:	83 ec 14             	sub    $0x14,%esp
  801ed5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  801edb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ee0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ee6:	7e 24                	jle    801f0c <nsipc_send+0x3e>
  801ee8:	c7 44 24 0c 19 2a 80 	movl   $0x802a19,0xc(%esp)
  801eef:	00 
  801ef0:	c7 44 24 08 ed 29 80 	movl   $0x8029ed,0x8(%esp)
  801ef7:	00 
  801ef8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801eff:	00 
  801f00:	c7 04 24 25 2a 80 00 	movl   $0x802a25,(%esp)
  801f07:	e8 a4 e3 ff ff       	call   8002b0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f0c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f13:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f17:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801f1e:	e8 72 ed ff ff       	call   800c95 <memmove>
	nsipcbuf.send.req_size = size;
  801f23:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f29:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f31:	b8 08 00 00 00       	mov    $0x8,%eax
  801f36:	e8 a5 fe ff ff       	call   801de0 <nsipc>
}
  801f3b:	83 c4 14             	add    $0x14,%esp
  801f3e:	5b                   	pop    %ebx
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    

00801f41 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	56                   	push   %esi
  801f45:	53                   	push   %ebx
  801f46:	83 ec 10             	sub    $0x10,%esp
  801f49:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f54:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f62:	b8 07 00 00 00       	mov    $0x7,%eax
  801f67:	e8 74 fe ff ff       	call   801de0 <nsipc>
  801f6c:	89 c3                	mov    %eax,%ebx
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 46                	js     801fb8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801f72:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f77:	7f 04                	jg     801f7d <nsipc_recv+0x3c>
  801f79:	39 c6                	cmp    %eax,%esi
  801f7b:	7d 24                	jge    801fa1 <nsipc_recv+0x60>
  801f7d:	c7 44 24 0c 31 2a 80 	movl   $0x802a31,0xc(%esp)
  801f84:	00 
  801f85:	c7 44 24 08 ed 29 80 	movl   $0x8029ed,0x8(%esp)
  801f8c:	00 
  801f8d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801f94:	00 
  801f95:	c7 04 24 25 2a 80 00 	movl   $0x802a25,(%esp)
  801f9c:	e8 0f e3 ff ff       	call   8002b0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801fa1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fac:	00 
  801fad:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb0:	89 04 24             	mov    %eax,(%esp)
  801fb3:	e8 dd ec ff ff       	call   800c95 <memmove>
	}

	return r;
}
  801fb8:	89 d8                	mov    %ebx,%eax
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	5b                   	pop    %ebx
  801fbe:	5e                   	pop    %esi
  801fbf:	5d                   	pop    %ebp
  801fc0:	c3                   	ret    

00801fc1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	53                   	push   %ebx
  801fc5:	83 ec 14             	sub    $0x14,%esp
  801fc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fd3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fde:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fe5:	e8 ab ec ff ff       	call   800c95 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fea:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801ff0:	b8 05 00 00 00       	mov    $0x5,%eax
  801ff5:	e8 e6 fd ff ff       	call   801de0 <nsipc>
}
  801ffa:	83 c4 14             	add    $0x14,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5d                   	pop    %ebp
  801fff:	c3                   	ret    

00802000 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	53                   	push   %ebx
  802004:	83 ec 14             	sub    $0x14,%esp
  802007:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80200a:	8b 45 08             	mov    0x8(%ebp),%eax
  80200d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802012:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802016:	8b 45 0c             	mov    0xc(%ebp),%eax
  802019:	89 44 24 04          	mov    %eax,0x4(%esp)
  80201d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802024:	e8 6c ec ff ff       	call   800c95 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802029:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80202f:	b8 02 00 00 00       	mov    $0x2,%eax
  802034:	e8 a7 fd ff ff       	call   801de0 <nsipc>
}
  802039:	83 c4 14             	add    $0x14,%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5d                   	pop    %ebp
  80203e:	c3                   	ret    

0080203f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80203f:	55                   	push   %ebp
  802040:	89 e5                	mov    %esp,%ebp
  802042:	83 ec 18             	sub    $0x18,%esp
  802045:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802048:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80204b:	8b 45 08             	mov    0x8(%ebp),%eax
  80204e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802053:	b8 01 00 00 00       	mov    $0x1,%eax
  802058:	e8 83 fd ff ff       	call   801de0 <nsipc>
  80205d:	89 c3                	mov    %eax,%ebx
  80205f:	85 c0                	test   %eax,%eax
  802061:	78 25                	js     802088 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802063:	be 10 60 80 00       	mov    $0x806010,%esi
  802068:	8b 06                	mov    (%esi),%eax
  80206a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80206e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802075:	00 
  802076:	8b 45 0c             	mov    0xc(%ebp),%eax
  802079:	89 04 24             	mov    %eax,(%esp)
  80207c:	e8 14 ec ff ff       	call   800c95 <memmove>
		*addrlen = ret->ret_addrlen;
  802081:	8b 16                	mov    (%esi),%edx
  802083:	8b 45 10             	mov    0x10(%ebp),%eax
  802086:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802088:	89 d8                	mov    %ebx,%eax
  80208a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80208d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802090:	89 ec                	mov    %ebp,%esp
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
	...

008020a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8020a6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8020ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b1:	39 ca                	cmp    %ecx,%edx
  8020b3:	75 04                	jne    8020b9 <ipc_find_env+0x19>
  8020b5:	b0 00                	mov    $0x0,%al
  8020b7:	eb 11                	jmp    8020ca <ipc_find_env+0x2a>
  8020b9:	89 c2                	mov    %eax,%edx
  8020bb:	c1 e2 07             	shl    $0x7,%edx
  8020be:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8020c4:	8b 12                	mov    (%edx),%edx
  8020c6:	39 ca                	cmp    %ecx,%edx
  8020c8:	75 0f                	jne    8020d9 <ipc_find_env+0x39>
			return envs[i].env_id;
  8020ca:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  8020ce:	c1 e0 06             	shl    $0x6,%eax
  8020d1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  8020d7:	eb 0e                	jmp    8020e7 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020d9:	83 c0 01             	add    $0x1,%eax
  8020dc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020e1:	75 d6                	jne    8020b9 <ipc_find_env+0x19>
  8020e3:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    

008020e9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020e9:	55                   	push   %ebp
  8020ea:	89 e5                	mov    %esp,%ebp
  8020ec:	57                   	push   %edi
  8020ed:	56                   	push   %esi
  8020ee:	53                   	push   %ebx
  8020ef:	83 ec 1c             	sub    $0x1c,%esp
  8020f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8020f5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8020fb:	85 db                	test   %ebx,%ebx
  8020fd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802102:	0f 44 d8             	cmove  %eax,%ebx
  802105:	eb 25                	jmp    80212c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  802107:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80210a:	74 20                	je     80212c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  80210c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802110:	c7 44 24 08 46 2a 80 	movl   $0x802a46,0x8(%esp)
  802117:	00 
  802118:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80211f:	00 
  802120:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  802127:	e8 84 e1 ff ff       	call   8002b0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80212c:	8b 45 14             	mov    0x14(%ebp),%eax
  80212f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802133:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802137:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80213b:	89 34 24             	mov    %esi,(%esp)
  80213e:	e8 7b ee ff ff       	call   800fbe <sys_ipc_try_send>
  802143:	85 c0                	test   %eax,%eax
  802145:	75 c0                	jne    802107 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802147:	e8 f8 ef ff ff       	call   801144 <sys_yield>
}
  80214c:	83 c4 1c             	add    $0x1c,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	83 ec 28             	sub    $0x28,%esp
  80215a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80215d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802160:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802163:	8b 75 08             	mov    0x8(%ebp),%esi
  802166:	8b 45 0c             	mov    0xc(%ebp),%eax
  802169:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80216c:	85 c0                	test   %eax,%eax
  80216e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802173:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802176:	89 04 24             	mov    %eax,(%esp)
  802179:	e8 07 ee ff ff       	call   800f85 <sys_ipc_recv>
  80217e:	89 c3                	mov    %eax,%ebx
  802180:	85 c0                	test   %eax,%eax
  802182:	79 2a                	jns    8021ae <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802184:	89 44 24 08          	mov    %eax,0x8(%esp)
  802188:	89 44 24 04          	mov    %eax,0x4(%esp)
  80218c:	c7 04 24 6e 2a 80 00 	movl   $0x802a6e,(%esp)
  802193:	e8 d1 e1 ff ff       	call   800369 <cprintf>
		if(from_env_store != NULL)
  802198:	85 f6                	test   %esi,%esi
  80219a:	74 06                	je     8021a2 <ipc_recv+0x4e>
			*from_env_store = 0;
  80219c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8021a2:	85 ff                	test   %edi,%edi
  8021a4:	74 2c                	je     8021d2 <ipc_recv+0x7e>
			*perm_store = 0;
  8021a6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8021ac:	eb 24                	jmp    8021d2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8021ae:	85 f6                	test   %esi,%esi
  8021b0:	74 0a                	je     8021bc <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8021b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8021b7:	8b 40 74             	mov    0x74(%eax),%eax
  8021ba:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8021bc:	85 ff                	test   %edi,%edi
  8021be:	74 0a                	je     8021ca <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8021c0:	a1 08 40 80 00       	mov    0x804008,%eax
  8021c5:	8b 40 78             	mov    0x78(%eax),%eax
  8021c8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8021ca:	a1 08 40 80 00       	mov    0x804008,%eax
  8021cf:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8021d2:	89 d8                	mov    %ebx,%eax
  8021d4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8021d7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8021da:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8021dd:	89 ec                	mov    %ebp,%esp
  8021df:	5d                   	pop    %ebp
  8021e0:	c3                   	ret    
  8021e1:	00 00                	add    %al,(%eax)
	...

008021e4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8021e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ea:	89 c2                	mov    %eax,%edx
  8021ec:	c1 ea 16             	shr    $0x16,%edx
  8021ef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021f6:	f6 c2 01             	test   $0x1,%dl
  8021f9:	74 20                	je     80221b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8021fb:	c1 e8 0c             	shr    $0xc,%eax
  8021fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802205:	a8 01                	test   $0x1,%al
  802207:	74 12                	je     80221b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802209:	c1 e8 0c             	shr    $0xc,%eax
  80220c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802211:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802216:	0f b7 c0             	movzwl %ax,%eax
  802219:	eb 05                	jmp    802220 <pageref+0x3c>
  80221b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802220:	5d                   	pop    %ebp
  802221:	c3                   	ret    
	...

00802230 <__udivdi3>:
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	57                   	push   %edi
  802234:	56                   	push   %esi
  802235:	83 ec 10             	sub    $0x10,%esp
  802238:	8b 45 14             	mov    0x14(%ebp),%eax
  80223b:	8b 55 08             	mov    0x8(%ebp),%edx
  80223e:	8b 75 10             	mov    0x10(%ebp),%esi
  802241:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802244:	85 c0                	test   %eax,%eax
  802246:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802249:	75 35                	jne    802280 <__udivdi3+0x50>
  80224b:	39 fe                	cmp    %edi,%esi
  80224d:	77 61                	ja     8022b0 <__udivdi3+0x80>
  80224f:	85 f6                	test   %esi,%esi
  802251:	75 0b                	jne    80225e <__udivdi3+0x2e>
  802253:	b8 01 00 00 00       	mov    $0x1,%eax
  802258:	31 d2                	xor    %edx,%edx
  80225a:	f7 f6                	div    %esi
  80225c:	89 c6                	mov    %eax,%esi
  80225e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802261:	31 d2                	xor    %edx,%edx
  802263:	89 f8                	mov    %edi,%eax
  802265:	f7 f6                	div    %esi
  802267:	89 c7                	mov    %eax,%edi
  802269:	89 c8                	mov    %ecx,%eax
  80226b:	f7 f6                	div    %esi
  80226d:	89 c1                	mov    %eax,%ecx
  80226f:	89 fa                	mov    %edi,%edx
  802271:	89 c8                	mov    %ecx,%eax
  802273:	83 c4 10             	add    $0x10,%esp
  802276:	5e                   	pop    %esi
  802277:	5f                   	pop    %edi
  802278:	5d                   	pop    %ebp
  802279:	c3                   	ret    
  80227a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802280:	39 f8                	cmp    %edi,%eax
  802282:	77 1c                	ja     8022a0 <__udivdi3+0x70>
  802284:	0f bd d0             	bsr    %eax,%edx
  802287:	83 f2 1f             	xor    $0x1f,%edx
  80228a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80228d:	75 39                	jne    8022c8 <__udivdi3+0x98>
  80228f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802292:	0f 86 a0 00 00 00    	jbe    802338 <__udivdi3+0x108>
  802298:	39 f8                	cmp    %edi,%eax
  80229a:	0f 82 98 00 00 00    	jb     802338 <__udivdi3+0x108>
  8022a0:	31 ff                	xor    %edi,%edi
  8022a2:	31 c9                	xor    %ecx,%ecx
  8022a4:	89 c8                	mov    %ecx,%eax
  8022a6:	89 fa                	mov    %edi,%edx
  8022a8:	83 c4 10             	add    $0x10,%esp
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    
  8022af:	90                   	nop
  8022b0:	89 d1                	mov    %edx,%ecx
  8022b2:	89 fa                	mov    %edi,%edx
  8022b4:	89 c8                	mov    %ecx,%eax
  8022b6:	31 ff                	xor    %edi,%edi
  8022b8:	f7 f6                	div    %esi
  8022ba:	89 c1                	mov    %eax,%ecx
  8022bc:	89 fa                	mov    %edi,%edx
  8022be:	89 c8                	mov    %ecx,%eax
  8022c0:	83 c4 10             	add    $0x10,%esp
  8022c3:	5e                   	pop    %esi
  8022c4:	5f                   	pop    %edi
  8022c5:	5d                   	pop    %ebp
  8022c6:	c3                   	ret    
  8022c7:	90                   	nop
  8022c8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8022cc:	89 f2                	mov    %esi,%edx
  8022ce:	d3 e0                	shl    %cl,%eax
  8022d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8022d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8022db:	89 c1                	mov    %eax,%ecx
  8022dd:	d3 ea                	shr    %cl,%edx
  8022df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8022e3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8022e6:	d3 e6                	shl    %cl,%esi
  8022e8:	89 c1                	mov    %eax,%ecx
  8022ea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8022ed:	89 fe                	mov    %edi,%esi
  8022ef:	d3 ee                	shr    %cl,%esi
  8022f1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8022f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8022f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8022fb:	d3 e7                	shl    %cl,%edi
  8022fd:	89 c1                	mov    %eax,%ecx
  8022ff:	d3 ea                	shr    %cl,%edx
  802301:	09 d7                	or     %edx,%edi
  802303:	89 f2                	mov    %esi,%edx
  802305:	89 f8                	mov    %edi,%eax
  802307:	f7 75 ec             	divl   -0x14(%ebp)
  80230a:	89 d6                	mov    %edx,%esi
  80230c:	89 c7                	mov    %eax,%edi
  80230e:	f7 65 e8             	mull   -0x18(%ebp)
  802311:	39 d6                	cmp    %edx,%esi
  802313:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802316:	72 30                	jb     802348 <__udivdi3+0x118>
  802318:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80231b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	39 c2                	cmp    %eax,%edx
  802323:	73 05                	jae    80232a <__udivdi3+0xfa>
  802325:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802328:	74 1e                	je     802348 <__udivdi3+0x118>
  80232a:	89 f9                	mov    %edi,%ecx
  80232c:	31 ff                	xor    %edi,%edi
  80232e:	e9 71 ff ff ff       	jmp    8022a4 <__udivdi3+0x74>
  802333:	90                   	nop
  802334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802338:	31 ff                	xor    %edi,%edi
  80233a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80233f:	e9 60 ff ff ff       	jmp    8022a4 <__udivdi3+0x74>
  802344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802348:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80234b:	31 ff                	xor    %edi,%edi
  80234d:	89 c8                	mov    %ecx,%eax
  80234f:	89 fa                	mov    %edi,%edx
  802351:	83 c4 10             	add    $0x10,%esp
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
	...

00802360 <__umoddi3>:
  802360:	55                   	push   %ebp
  802361:	89 e5                	mov    %esp,%ebp
  802363:	57                   	push   %edi
  802364:	56                   	push   %esi
  802365:	83 ec 20             	sub    $0x20,%esp
  802368:	8b 55 14             	mov    0x14(%ebp),%edx
  80236b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80236e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802371:	8b 75 0c             	mov    0xc(%ebp),%esi
  802374:	85 d2                	test   %edx,%edx
  802376:	89 c8                	mov    %ecx,%eax
  802378:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80237b:	75 13                	jne    802390 <__umoddi3+0x30>
  80237d:	39 f7                	cmp    %esi,%edi
  80237f:	76 3f                	jbe    8023c0 <__umoddi3+0x60>
  802381:	89 f2                	mov    %esi,%edx
  802383:	f7 f7                	div    %edi
  802385:	89 d0                	mov    %edx,%eax
  802387:	31 d2                	xor    %edx,%edx
  802389:	83 c4 20             	add    $0x20,%esp
  80238c:	5e                   	pop    %esi
  80238d:	5f                   	pop    %edi
  80238e:	5d                   	pop    %ebp
  80238f:	c3                   	ret    
  802390:	39 f2                	cmp    %esi,%edx
  802392:	77 4c                	ja     8023e0 <__umoddi3+0x80>
  802394:	0f bd ca             	bsr    %edx,%ecx
  802397:	83 f1 1f             	xor    $0x1f,%ecx
  80239a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80239d:	75 51                	jne    8023f0 <__umoddi3+0x90>
  80239f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8023a2:	0f 87 e0 00 00 00    	ja     802488 <__umoddi3+0x128>
  8023a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ab:	29 f8                	sub    %edi,%eax
  8023ad:	19 d6                	sbb    %edx,%esi
  8023af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8023b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b5:	89 f2                	mov    %esi,%edx
  8023b7:	83 c4 20             	add    $0x20,%esp
  8023ba:	5e                   	pop    %esi
  8023bb:	5f                   	pop    %edi
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    
  8023be:	66 90                	xchg   %ax,%ax
  8023c0:	85 ff                	test   %edi,%edi
  8023c2:	75 0b                	jne    8023cf <__umoddi3+0x6f>
  8023c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8023c9:	31 d2                	xor    %edx,%edx
  8023cb:	f7 f7                	div    %edi
  8023cd:	89 c7                	mov    %eax,%edi
  8023cf:	89 f0                	mov    %esi,%eax
  8023d1:	31 d2                	xor    %edx,%edx
  8023d3:	f7 f7                	div    %edi
  8023d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d8:	f7 f7                	div    %edi
  8023da:	eb a9                	jmp    802385 <__umoddi3+0x25>
  8023dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023e0:	89 c8                	mov    %ecx,%eax
  8023e2:	89 f2                	mov    %esi,%edx
  8023e4:	83 c4 20             	add    $0x20,%esp
  8023e7:	5e                   	pop    %esi
  8023e8:	5f                   	pop    %edi
  8023e9:	5d                   	pop    %ebp
  8023ea:	c3                   	ret    
  8023eb:	90                   	nop
  8023ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023f4:	d3 e2                	shl    %cl,%edx
  8023f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8023f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8023fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802401:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802404:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802408:	89 fa                	mov    %edi,%edx
  80240a:	d3 ea                	shr    %cl,%edx
  80240c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802410:	0b 55 f4             	or     -0xc(%ebp),%edx
  802413:	d3 e7                	shl    %cl,%edi
  802415:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802419:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80241c:	89 f2                	mov    %esi,%edx
  80241e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802421:	89 c7                	mov    %eax,%edi
  802423:	d3 ea                	shr    %cl,%edx
  802425:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802429:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80242c:	89 c2                	mov    %eax,%edx
  80242e:	d3 e6                	shl    %cl,%esi
  802430:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802434:	d3 ea                	shr    %cl,%edx
  802436:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80243a:	09 d6                	or     %edx,%esi
  80243c:	89 f0                	mov    %esi,%eax
  80243e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802441:	d3 e7                	shl    %cl,%edi
  802443:	89 f2                	mov    %esi,%edx
  802445:	f7 75 f4             	divl   -0xc(%ebp)
  802448:	89 d6                	mov    %edx,%esi
  80244a:	f7 65 e8             	mull   -0x18(%ebp)
  80244d:	39 d6                	cmp    %edx,%esi
  80244f:	72 2b                	jb     80247c <__umoddi3+0x11c>
  802451:	39 c7                	cmp    %eax,%edi
  802453:	72 23                	jb     802478 <__umoddi3+0x118>
  802455:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802459:	29 c7                	sub    %eax,%edi
  80245b:	19 d6                	sbb    %edx,%esi
  80245d:	89 f0                	mov    %esi,%eax
  80245f:	89 f2                	mov    %esi,%edx
  802461:	d3 ef                	shr    %cl,%edi
  802463:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802467:	d3 e0                	shl    %cl,%eax
  802469:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80246d:	09 f8                	or     %edi,%eax
  80246f:	d3 ea                	shr    %cl,%edx
  802471:	83 c4 20             	add    $0x20,%esp
  802474:	5e                   	pop    %esi
  802475:	5f                   	pop    %edi
  802476:	5d                   	pop    %ebp
  802477:	c3                   	ret    
  802478:	39 d6                	cmp    %edx,%esi
  80247a:	75 d9                	jne    802455 <__umoddi3+0xf5>
  80247c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80247f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802482:	eb d1                	jmp    802455 <__umoddi3+0xf5>
  802484:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802488:	39 f2                	cmp    %esi,%edx
  80248a:	0f 82 18 ff ff ff    	jb     8023a8 <__umoddi3+0x48>
  802490:	e9 1d ff ff ff       	jmp    8023b2 <__umoddi3+0x52>
