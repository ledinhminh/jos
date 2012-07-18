
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
  800048:	c7 04 24 e0 1e 80 00 	movl   $0x801ee0,(%esp)
  80004f:	e8 10 1a 00 00       	call   801a64 <open>
  800054:	89 85 e4 fd ff ff    	mov    %eax,-0x21c(%ebp)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	79 20                	jns    80007e <umain+0x4a>
		panic("open /newmotd: %e", rfd);
  80005e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800062:	c7 44 24 08 e9 1e 80 	movl   $0x801ee9,0x8(%esp)
  800069:	00 
  80006a:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800071:	00 
  800072:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  800079:	e8 32 02 00 00       	call   8002b0 <_panic>
	if ((wfd = open("/motd", O_RDWR)) < 0)
  80007e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 0c 1f 80 00 	movl   $0x801f0c,(%esp)
  80008d:	e8 d2 19 00 00       	call   801a64 <open>
  800092:	89 c7                	mov    %eax,%edi
  800094:	85 c0                	test   %eax,%eax
  800096:	79 20                	jns    8000b8 <umain+0x84>
		panic("open /motd: %e", wfd);
  800098:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80009c:	c7 44 24 08 12 1f 80 	movl   $0x801f12,0x8(%esp)
  8000a3:	00 
  8000a4:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
  8000ab:	00 
  8000ac:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  8000b3:	e8 f8 01 00 00       	call   8002b0 <_panic>
	cprintf("file descriptors %d %d\n", rfd, wfd);
  8000b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000bc:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  8000c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000c6:	c7 04 24 21 1f 80 00 	movl   $0x801f21,(%esp)
  8000cd:	e8 97 02 00 00       	call   800369 <cprintf>
	if (rfd == wfd)
  8000d2:	39 bd e4 fd ff ff    	cmp    %edi,-0x21c(%ebp)
  8000d8:	75 1c                	jne    8000f6 <umain+0xc2>
		panic("open /newmotd and /motd give same file descriptor");
  8000da:	c7 44 24 08 8c 1f 80 	movl   $0x801f8c,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  8000f1:	e8 ba 01 00 00       	call   8002b0 <_panic>

	cprintf("OLD MOTD\n===\n");
  8000f6:	c7 04 24 39 1f 80 00 	movl   $0x801f39,(%esp)
  8000fd:	e8 67 02 00 00       	call   800369 <cprintf>
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800102:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  800108:	eb 0c                	jmp    800116 <umain+0xe2>
		sys_cputs(buf, n);
  80010a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010e:	89 1c 24             	mov    %ebx,(%esp)
  800111:	e8 dd 10 00 00       	call   8011f3 <sys_cputs>
	cprintf("file descriptors %d %d\n", rfd, wfd);
	if (rfd == wfd)
		panic("open /newmotd and /motd give same file descriptor");

	cprintf("OLD MOTD\n===\n");
	while ((n = read(wfd, buf, sizeof buf-1)) > 0)
  800116:	c7 44 24 08 ff 01 00 	movl   $0x1ff,0x8(%esp)
  80011d:	00 
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 3c 24             	mov    %edi,(%esp)
  800125:	e8 09 14 00 00       	call   801533 <read>
  80012a:	85 c0                	test   %eax,%eax
  80012c:	7f dc                	jg     80010a <umain+0xd6>
		sys_cputs(buf, n);
	cprintf("===\n");
  80012e:	c7 04 24 42 1f 80 00 	movl   $0x801f42,(%esp)
  800135:	e8 2f 02 00 00       	call   800369 <cprintf>
	seek(wfd, 0);
  80013a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800141:	00 
  800142:	89 3c 24             	mov    %edi,(%esp)
  800145:	e8 cb 11 00 00       	call   801315 <seek>

	if ((r = ftruncate(wfd, 0)) < 0)
  80014a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800151:	00 
  800152:	89 3c 24             	mov    %edi,(%esp)
  800155:	e8 ce 12 00 00       	call   801428 <ftruncate>
  80015a:	85 c0                	test   %eax,%eax
  80015c:	79 20                	jns    80017e <umain+0x14a>
		panic("truncate /motd: %e", r);
  80015e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800162:	c7 44 24 08 47 1f 80 	movl   $0x801f47,0x8(%esp)
  800169:	00 
  80016a:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  800171:	00 
  800172:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  800179:	e8 32 01 00 00       	call   8002b0 <_panic>

	cprintf("NEW MOTD\n===\n");
  80017e:	c7 04 24 5a 1f 80 00 	movl   $0x801f5a,(%esp)
  800185:	e8 df 01 00 00       	call   800369 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0) {
  80018a:	8d b5 e8 fd ff ff    	lea    -0x218(%ebp),%esi
  800190:	eb 40                	jmp    8001d2 <umain+0x19e>
		sys_cputs(buf, n);
  800192:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 55 10 00 00       	call   8011f3 <sys_cputs>
		if ((r = write(wfd, buf, n)) != n)
  80019e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a6:	89 3c 24             	mov    %edi,(%esp)
  8001a9:	e8 fc 12 00 00       	call   8014aa <write>
  8001ae:	39 c3                	cmp    %eax,%ebx
  8001b0:	74 20                	je     8001d2 <umain+0x19e>
			panic("write /motd: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 68 1f 80 	movl   $0x801f68,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
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
  8001e7:	e8 47 13 00 00       	call   801533 <read>
  8001ec:	89 c3                	mov    %eax,%ebx
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	7f a0                	jg     800192 <umain+0x15e>
		sys_cputs(buf, n);
		if ((r = write(wfd, buf, n)) != n)
			panic("write /motd: %e", r);
	}
	cprintf("===\n");
  8001f2:	c7 04 24 42 1f 80 00 	movl   $0x801f42,(%esp)
  8001f9:	e8 6b 01 00 00       	call   800369 <cprintf>

	if (n < 0)
  8001fe:	85 db                	test   %ebx,%ebx
  800200:	79 20                	jns    800222 <umain+0x1ee>
		panic("read /newmotd: %e", n);
  800202:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800206:	c7 44 24 08 78 1f 80 	movl   $0x801f78,0x8(%esp)
  80020d:	00 
  80020e:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800215:	00 
  800216:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  80021d:	e8 8e 00 00 00       	call   8002b0 <_panic>

	close(rfd);
  800222:	8b 85 e4 fd ff ff    	mov    -0x21c(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 6c 14 00 00       	call   80169c <close>
	close(wfd);
  800230:	89 3c 24             	mov    %edi,(%esp)
  800233:	e8 64 14 00 00       	call   80169c <close>
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
  800256:	e8 e9 0e 00 00       	call   801144 <sys_getenvid>
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800263:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800268:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80029a:	e8 7a 14 00 00       	call   801719 <close_all>
	sys_env_destroy(0);
  80029f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002a6:	e8 d4 0e 00 00       	call   80117f <sys_env_destroy>
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
  8002c1:	e8 7e 0e 00 00       	call   801144 <sys_getenvid>
  8002c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002dc:	c7 04 24 c8 1f 80 00 	movl   $0x801fc8,(%esp)
  8002e3:	e8 81 00 00 00       	call   800369 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ef:	89 04 24             	mov    %eax,(%esp)
  8002f2:	e8 11 00 00 00       	call   800308 <vcprintf>
	cprintf("\n");
  8002f7:	c7 04 24 45 1f 80 00 	movl   $0x801f45,(%esp)
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
  80035c:	e8 92 0e 00 00       	call   8011f3 <sys_cputs>

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
  8003b0:	e8 3e 0e 00 00       	call   8011f3 <sys_cputs>
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
  80044d:	e8 1e 18 00 00       	call   801c70 <__udivdi3>
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
  8004a8:	e8 f3 18 00 00       	call   801da0 <__umoddi3>
  8004ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b1:	0f be 80 eb 1f 80 00 	movsbl 0x801feb(%eax),%eax
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
  800595:	ff 24 95 c0 21 80 00 	jmp    *0x8021c0(,%edx,4)
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
  800668:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	75 20                	jne    800693 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800673:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800677:	c7 44 24 08 fc 1f 80 	movl   $0x801ffc,0x8(%esp)
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
  800697:	c7 44 24 08 3b 24 80 	movl   $0x80243b,0x8(%esp)
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
  8006d1:	b8 05 20 80 00       	mov    $0x802005,%eax
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
  800915:	c7 44 24 0c 20 21 80 	movl   $0x802120,0xc(%esp)
  80091c:	00 
  80091d:	c7 44 24 08 3b 24 80 	movl   $0x80243b,0x8(%esp)
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
  800943:	c7 44 24 0c 58 21 80 	movl   $0x802158,0xc(%esp)
  80094a:	00 
  80094b:	c7 44 24 08 3b 24 80 	movl   $0x80243b,0x8(%esp)
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
  800ee7:	c7 44 24 08 60 23 80 	movl   $0x802360,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ef6:	00 
  800ef7:	c7 04 24 7d 23 80 00 	movl   $0x80237d,(%esp)
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

00800f12 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1f:	00 
  800f20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f27:	00 
  800f28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f2f:	00 
  800f30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3a:	ba 01 00 00 00       	mov    $0x1,%edx
  800f3f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f44:	e8 53 ff ff ff       	call   800e9c <syscall>
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f51:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f58:	00 
  800f59:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f60:	8b 45 10             	mov    0x10(%ebp),%eax
  800f63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6a:	89 04 24             	mov    %eax,(%esp)
  800f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f70:	ba 00 00 00 00       	mov    $0x0,%edx
  800f75:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f7a:	e8 1d ff ff ff       	call   800e9c <syscall>
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f96:	00 
  800f97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f9e:	00 
  800f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa2:	89 04 24             	mov    %eax,(%esp)
  800fa5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa8:	ba 01 00 00 00       	mov    $0x1,%edx
  800fad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fb2:	e8 e5 fe ff ff       	call   800e9c <syscall>
}
  800fb7:	c9                   	leave  
  800fb8:	c3                   	ret    

00800fb9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800fbf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fce:	00 
  800fcf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd6:	00 
  800fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fda:	89 04 24             	mov    %eax,(%esp)
  800fdd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe0:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fea:	e8 ad fe ff ff       	call   800e9c <syscall>
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ff7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ffe:	00 
  800fff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801006:	00 
  801007:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80100e:	00 
  80100f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801012:	89 04 24             	mov    %eax,(%esp)
  801015:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801018:	ba 01 00 00 00       	mov    $0x1,%edx
  80101d:	b8 09 00 00 00       	mov    $0x9,%eax
  801022:	e8 75 fe ff ff       	call   800e9c <syscall>
}
  801027:	c9                   	leave  
  801028:	c3                   	ret    

00801029 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80102f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801036:	00 
  801037:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103e:	00 
  80103f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801046:	00 
  801047:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104a:	89 04 24             	mov    %eax,(%esp)
  80104d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801050:	ba 01 00 00 00       	mov    $0x1,%edx
  801055:	b8 07 00 00 00       	mov    $0x7,%eax
  80105a:	e8 3d fe ff ff       	call   800e9c <syscall>
}
  80105f:	c9                   	leave  
  801060:	c3                   	ret    

00801061 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  801067:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80106e:	00 
  80106f:	8b 45 18             	mov    0x18(%ebp),%eax
  801072:	0b 45 14             	or     0x14(%ebp),%eax
  801075:	89 44 24 08          	mov    %eax,0x8(%esp)
  801079:	8b 45 10             	mov    0x10(%ebp),%eax
  80107c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801080:	8b 45 0c             	mov    0xc(%ebp),%eax
  801083:	89 04 24             	mov    %eax,(%esp)
  801086:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801089:	ba 01 00 00 00       	mov    $0x1,%edx
  80108e:	b8 06 00 00 00       	mov    $0x6,%eax
  801093:	e8 04 fe ff ff       	call   800e9c <syscall>
}
  801098:	c9                   	leave  
  801099:	c3                   	ret    

0080109a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a7:	00 
  8010a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010af:	00 
  8010b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8010b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ba:	89 04 24             	mov    %eax,(%esp)
  8010bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c0:	ba 01 00 00 00       	mov    $0x1,%edx
  8010c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ca:	e8 cd fd ff ff       	call   800e9c <syscall>
}
  8010cf:	c9                   	leave  
  8010d0:	c3                   	ret    

008010d1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8010d7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010de:	00 
  8010df:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e6:	00 
  8010e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ee:	00 
  8010ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801100:	b8 0c 00 00 00       	mov    $0xc,%eax
  801105:	e8 92 fd ff ff       	call   800e9c <syscall>
}
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801112:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801119:	00 
  80111a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801121:	00 
  801122:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801129:	00 
  80112a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112d:	89 04 24             	mov    %eax,(%esp)
  801130:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801133:	ba 00 00 00 00       	mov    $0x0,%edx
  801138:	b8 04 00 00 00       	mov    $0x4,%eax
  80113d:	e8 5a fd ff ff       	call   800e9c <syscall>
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80114a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801151:	00 
  801152:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801159:	00 
  80115a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801161:	00 
  801162:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801169:	b9 00 00 00 00       	mov    $0x0,%ecx
  80116e:	ba 00 00 00 00       	mov    $0x0,%edx
  801173:	b8 02 00 00 00       	mov    $0x2,%eax
  801178:	e8 1f fd ff ff       	call   800e9c <syscall>
}
  80117d:	c9                   	leave  
  80117e:	c3                   	ret    

0080117f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801185:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80118c:	00 
  80118d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801194:	00 
  801195:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80119c:	00 
  80119d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011a7:	ba 01 00 00 00       	mov    $0x1,%edx
  8011ac:	b8 03 00 00 00       	mov    $0x3,%eax
  8011b1:	e8 e6 fc ff ff       	call   800e9c <syscall>
}
  8011b6:	c9                   	leave  
  8011b7:	c3                   	ret    

008011b8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8011b8:	55                   	push   %ebp
  8011b9:	89 e5                	mov    %esp,%ebp
  8011bb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8011be:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011c5:	00 
  8011c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cd:	00 
  8011ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011d5:	00 
  8011d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011e2:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8011ec:	e8 ab fc ff ff       	call   800e9c <syscall>
}
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8011f9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801200:	00 
  801201:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801208:	00 
  801209:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801210:	00 
  801211:	8b 45 0c             	mov    0xc(%ebp),%eax
  801214:	89 04 24             	mov    %eax,(%esp)
  801217:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121a:	ba 00 00 00 00       	mov    $0x0,%edx
  80121f:	b8 00 00 00 00       	mov    $0x0,%eax
  801224:	e8 73 fc ff ff       	call   800e9c <syscall>
}
  801229:	c9                   	leave  
  80122a:	c3                   	ret    
  80122b:	00 00                	add    %al,(%eax)
  80122d:	00 00                	add    %al,(%eax)
	...

00801230 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	05 00 00 00 30       	add    $0x30000000,%eax
  80123b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	89 04 24             	mov    %eax,(%esp)
  80124c:	e8 df ff ff ff       	call   801230 <fd2num>
  801251:	05 20 00 0d 00       	add    $0xd0020,%eax
  801256:	c1 e0 0c             	shl    $0xc,%eax
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    

0080125b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	57                   	push   %edi
  80125f:	56                   	push   %esi
  801260:	53                   	push   %ebx
  801261:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801264:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801269:	a8 01                	test   $0x1,%al
  80126b:	74 36                	je     8012a3 <fd_alloc+0x48>
  80126d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801272:	a8 01                	test   $0x1,%al
  801274:	74 2d                	je     8012a3 <fd_alloc+0x48>
  801276:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80127b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801280:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801285:	89 c3                	mov    %eax,%ebx
  801287:	89 c2                	mov    %eax,%edx
  801289:	c1 ea 16             	shr    $0x16,%edx
  80128c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80128f:	f6 c2 01             	test   $0x1,%dl
  801292:	74 14                	je     8012a8 <fd_alloc+0x4d>
  801294:	89 c2                	mov    %eax,%edx
  801296:	c1 ea 0c             	shr    $0xc,%edx
  801299:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80129c:	f6 c2 01             	test   $0x1,%dl
  80129f:	75 10                	jne    8012b1 <fd_alloc+0x56>
  8012a1:	eb 05                	jmp    8012a8 <fd_alloc+0x4d>
  8012a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8012a8:	89 1f                	mov    %ebx,(%edi)
  8012aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8012af:	eb 17                	jmp    8012c8 <fd_alloc+0x6d>
  8012b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bb:	75 c8                	jne    801285 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8012c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012c8:	5b                   	pop    %ebx
  8012c9:	5e                   	pop    %esi
  8012ca:	5f                   	pop    %edi
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	83 f8 1f             	cmp    $0x1f,%eax
  8012d6:	77 36                	ja     80130e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8012e0:	89 c2                	mov    %eax,%edx
  8012e2:	c1 ea 16             	shr    $0x16,%edx
  8012e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ec:	f6 c2 01             	test   $0x1,%dl
  8012ef:	74 1d                	je     80130e <fd_lookup+0x41>
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	c1 ea 0c             	shr    $0xc,%edx
  8012f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012fd:	f6 c2 01             	test   $0x1,%dl
  801300:	74 0c                	je     80130e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801302:	8b 55 0c             	mov    0xc(%ebp),%edx
  801305:	89 02                	mov    %eax,(%edx)
  801307:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80130c:	eb 05                	jmp    801313 <fd_lookup+0x46>
  80130e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801313:	5d                   	pop    %ebp
  801314:	c3                   	ret    

00801315 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80131b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80131e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801322:	8b 45 08             	mov    0x8(%ebp),%eax
  801325:	89 04 24             	mov    %eax,(%esp)
  801328:	e8 a0 ff ff ff       	call   8012cd <fd_lookup>
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 0e                	js     80133f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801331:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801334:	8b 55 0c             	mov    0xc(%ebp),%edx
  801337:	89 50 04             	mov    %edx,0x4(%eax)
  80133a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80133f:	c9                   	leave  
  801340:	c3                   	ret    

00801341 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	56                   	push   %esi
  801345:	53                   	push   %ebx
  801346:	83 ec 10             	sub    $0x10,%esp
  801349:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80134f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801354:	b8 04 30 80 00       	mov    $0x803004,%eax
  801359:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80135f:	75 11                	jne    801372 <dev_lookup+0x31>
  801361:	eb 04                	jmp    801367 <dev_lookup+0x26>
  801363:	39 08                	cmp    %ecx,(%eax)
  801365:	75 10                	jne    801377 <dev_lookup+0x36>
			*dev = devtab[i];
  801367:	89 03                	mov    %eax,(%ebx)
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80136e:	66 90                	xchg   %ax,%ax
  801370:	eb 36                	jmp    8013a8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801372:	be 0c 24 80 00       	mov    $0x80240c,%esi
  801377:	83 c2 01             	add    $0x1,%edx
  80137a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80137d:	85 c0                	test   %eax,%eax
  80137f:	75 e2                	jne    801363 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801381:	a1 04 40 80 00       	mov    0x804004,%eax
  801386:	8b 40 48             	mov    0x48(%eax),%eax
  801389:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80138d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801391:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  801398:	e8 cc ef ff ff       	call   800369 <cprintf>
	*dev = 0;
  80139d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 24             	sub    $0x24,%esp
  8013b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c3:	89 04 24             	mov    %eax,(%esp)
  8013c6:	e8 02 ff ff ff       	call   8012cd <fd_lookup>
  8013cb:	85 c0                	test   %eax,%eax
  8013cd:	78 53                	js     801422 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d9:	8b 00                	mov    (%eax),%eax
  8013db:	89 04 24             	mov    %eax,(%esp)
  8013de:	e8 5e ff ff ff       	call   801341 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e3:	85 c0                	test   %eax,%eax
  8013e5:	78 3b                	js     801422 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013ef:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013f3:	74 2d                	je     801422 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ff:	00 00 00 
	stat->st_isdir = 0;
  801402:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801409:	00 00 00 
	stat->st_dev = dev;
  80140c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801415:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801419:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80141c:	89 14 24             	mov    %edx,(%esp)
  80141f:	ff 50 14             	call   *0x14(%eax)
}
  801422:	83 c4 24             	add    $0x24,%esp
  801425:	5b                   	pop    %ebx
  801426:	5d                   	pop    %ebp
  801427:	c3                   	ret    

00801428 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 24             	sub    $0x24,%esp
  80142f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801432:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801435:	89 44 24 04          	mov    %eax,0x4(%esp)
  801439:	89 1c 24             	mov    %ebx,(%esp)
  80143c:	e8 8c fe ff ff       	call   8012cd <fd_lookup>
  801441:	85 c0                	test   %eax,%eax
  801443:	78 5f                	js     8014a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801445:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144f:	8b 00                	mov    (%eax),%eax
  801451:	89 04 24             	mov    %eax,(%esp)
  801454:	e8 e8 fe ff ff       	call   801341 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801459:	85 c0                	test   %eax,%eax
  80145b:	78 47                	js     8014a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801460:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801464:	75 23                	jne    801489 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801466:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80146b:	8b 40 48             	mov    0x48(%eax),%eax
  80146e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801472:	89 44 24 04          	mov    %eax,0x4(%esp)
  801476:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  80147d:	e8 e7 ee ff ff       	call   800369 <cprintf>
  801482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801487:	eb 1b                	jmp    8014a4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801489:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148c:	8b 48 18             	mov    0x18(%eax),%ecx
  80148f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801494:	85 c9                	test   %ecx,%ecx
  801496:	74 0c                	je     8014a4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801498:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149f:	89 14 24             	mov    %edx,(%esp)
  8014a2:	ff d1                	call   *%ecx
}
  8014a4:	83 c4 24             	add    $0x24,%esp
  8014a7:	5b                   	pop    %ebx
  8014a8:	5d                   	pop    %ebp
  8014a9:	c3                   	ret    

008014aa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 24             	sub    $0x24,%esp
  8014b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	89 1c 24             	mov    %ebx,(%esp)
  8014be:	e8 0a fe ff ff       	call   8012cd <fd_lookup>
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 66                	js     80152d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d1:	8b 00                	mov    (%eax),%eax
  8014d3:	89 04 24             	mov    %eax,(%esp)
  8014d6:	e8 66 fe ff ff       	call   801341 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 4e                	js     80152d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014e2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014e6:	75 23                	jne    80150b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8014ed:	8b 40 48             	mov    0x48(%eax),%eax
  8014f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f8:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  8014ff:	e8 65 ee ff ff       	call   800369 <cprintf>
  801504:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801509:	eb 22                	jmp    80152d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80150b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801511:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801516:	85 c9                	test   %ecx,%ecx
  801518:	74 13                	je     80152d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151a:	8b 45 10             	mov    0x10(%ebp),%eax
  80151d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801521:	8b 45 0c             	mov    0xc(%ebp),%eax
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	89 14 24             	mov    %edx,(%esp)
  80152b:	ff d1                	call   *%ecx
}
  80152d:	83 c4 24             	add    $0x24,%esp
  801530:	5b                   	pop    %ebx
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 24             	sub    $0x24,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	89 44 24 04          	mov    %eax,0x4(%esp)
  801544:	89 1c 24             	mov    %ebx,(%esp)
  801547:	e8 81 fd ff ff       	call   8012cd <fd_lookup>
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 6b                	js     8015bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801553:	89 44 24 04          	mov    %eax,0x4(%esp)
  801557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155a:	8b 00                	mov    (%eax),%eax
  80155c:	89 04 24             	mov    %eax,(%esp)
  80155f:	e8 dd fd ff ff       	call   801341 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801564:	85 c0                	test   %eax,%eax
  801566:	78 53                	js     8015bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801568:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80156b:	8b 42 08             	mov    0x8(%edx),%eax
  80156e:	83 e0 03             	and    $0x3,%eax
  801571:	83 f8 01             	cmp    $0x1,%eax
  801574:	75 23                	jne    801599 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801576:	a1 04 40 80 00       	mov    0x804004,%eax
  80157b:	8b 40 48             	mov    0x48(%eax),%eax
  80157e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801582:	89 44 24 04          	mov    %eax,0x4(%esp)
  801586:	c7 04 24 ed 23 80 00 	movl   $0x8023ed,(%esp)
  80158d:	e8 d7 ed ff ff       	call   800369 <cprintf>
  801592:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801597:	eb 22                	jmp    8015bb <read+0x88>
	}
	if (!dev->dev_read)
  801599:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159c:	8b 48 08             	mov    0x8(%eax),%ecx
  80159f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015a4:	85 c9                	test   %ecx,%ecx
  8015a6:	74 13                	je     8015bb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8015ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b6:	89 14 24             	mov    %edx,(%esp)
  8015b9:	ff d1                	call   *%ecx
}
  8015bb:	83 c4 24             	add    $0x24,%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5d                   	pop    %ebp
  8015c0:	c3                   	ret    

008015c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c1:	55                   	push   %ebp
  8015c2:	89 e5                	mov    %esp,%ebp
  8015c4:	57                   	push   %edi
  8015c5:	56                   	push   %esi
  8015c6:	53                   	push   %ebx
  8015c7:	83 ec 1c             	sub    $0x1c,%esp
  8015ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015da:	b8 00 00 00 00       	mov    $0x0,%eax
  8015df:	85 f6                	test   %esi,%esi
  8015e1:	74 29                	je     80160c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e3:	89 f0                	mov    %esi,%eax
  8015e5:	29 d0                	sub    %edx,%eax
  8015e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015eb:	03 55 0c             	add    0xc(%ebp),%edx
  8015ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f2:	89 3c 24             	mov    %edi,(%esp)
  8015f5:	e8 39 ff ff ff       	call   801533 <read>
		if (m < 0)
  8015fa:	85 c0                	test   %eax,%eax
  8015fc:	78 0e                	js     80160c <readn+0x4b>
			return m;
		if (m == 0)
  8015fe:	85 c0                	test   %eax,%eax
  801600:	74 08                	je     80160a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801602:	01 c3                	add    %eax,%ebx
  801604:	89 da                	mov    %ebx,%edx
  801606:	39 f3                	cmp    %esi,%ebx
  801608:	72 d9                	jb     8015e3 <readn+0x22>
  80160a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80160c:	83 c4 1c             	add    $0x1c,%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5f                   	pop    %edi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 28             	sub    $0x28,%esp
  80161a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80161d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801620:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801623:	89 34 24             	mov    %esi,(%esp)
  801626:	e8 05 fc ff ff       	call   801230 <fd2num>
  80162b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80162e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801632:	89 04 24             	mov    %eax,(%esp)
  801635:	e8 93 fc ff ff       	call   8012cd <fd_lookup>
  80163a:	89 c3                	mov    %eax,%ebx
  80163c:	85 c0                	test   %eax,%eax
  80163e:	78 05                	js     801645 <fd_close+0x31>
  801640:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801643:	74 0e                	je     801653 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801645:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801649:	b8 00 00 00 00       	mov    $0x0,%eax
  80164e:	0f 44 d8             	cmove  %eax,%ebx
  801651:	eb 3d                	jmp    801690 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801653:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801656:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165a:	8b 06                	mov    (%esi),%eax
  80165c:	89 04 24             	mov    %eax,(%esp)
  80165f:	e8 dd fc ff ff       	call   801341 <dev_lookup>
  801664:	89 c3                	mov    %eax,%ebx
  801666:	85 c0                	test   %eax,%eax
  801668:	78 16                	js     801680 <fd_close+0x6c>
		if (dev->dev_close)
  80166a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166d:	8b 40 10             	mov    0x10(%eax),%eax
  801670:	bb 00 00 00 00       	mov    $0x0,%ebx
  801675:	85 c0                	test   %eax,%eax
  801677:	74 07                	je     801680 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801679:	89 34 24             	mov    %esi,(%esp)
  80167c:	ff d0                	call   *%eax
  80167e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801680:	89 74 24 04          	mov    %esi,0x4(%esp)
  801684:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80168b:	e8 99 f9 ff ff       	call   801029 <sys_page_unmap>
	return r;
}
  801690:	89 d8                	mov    %ebx,%eax
  801692:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801695:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801698:	89 ec                	mov    %ebp,%esp
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ac:	89 04 24             	mov    %eax,(%esp)
  8016af:	e8 19 fc ff ff       	call   8012cd <fd_lookup>
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 13                	js     8016cb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016b8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016bf:	00 
  8016c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c3:	89 04 24             	mov    %eax,(%esp)
  8016c6:	e8 49 ff ff ff       	call   801614 <fd_close>
}
  8016cb:	c9                   	leave  
  8016cc:	c3                   	ret    

008016cd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 18             	sub    $0x18,%esp
  8016d3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016d6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016e0:	00 
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	89 04 24             	mov    %eax,(%esp)
  8016e7:	e8 78 03 00 00       	call   801a64 <open>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 1b                	js     80170d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f9:	89 1c 24             	mov    %ebx,(%esp)
  8016fc:	e8 ae fc ff ff       	call   8013af <fstat>
  801701:	89 c6                	mov    %eax,%esi
	close(fd);
  801703:	89 1c 24             	mov    %ebx,(%esp)
  801706:	e8 91 ff ff ff       	call   80169c <close>
  80170b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80170d:	89 d8                	mov    %ebx,%eax
  80170f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801712:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801715:	89 ec                	mov    %ebp,%esp
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801719:	55                   	push   %ebp
  80171a:	89 e5                	mov    %esp,%ebp
  80171c:	53                   	push   %ebx
  80171d:	83 ec 14             	sub    $0x14,%esp
  801720:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801725:	89 1c 24             	mov    %ebx,(%esp)
  801728:	e8 6f ff ff ff       	call   80169c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80172d:	83 c3 01             	add    $0x1,%ebx
  801730:	83 fb 20             	cmp    $0x20,%ebx
  801733:	75 f0                	jne    801725 <close_all+0xc>
		close(i);
}
  801735:	83 c4 14             	add    $0x14,%esp
  801738:	5b                   	pop    %ebx
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	83 ec 58             	sub    $0x58,%esp
  801741:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801744:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801747:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80174a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80174d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801750:	89 44 24 04          	mov    %eax,0x4(%esp)
  801754:	8b 45 08             	mov    0x8(%ebp),%eax
  801757:	89 04 24             	mov    %eax,(%esp)
  80175a:	e8 6e fb ff ff       	call   8012cd <fd_lookup>
  80175f:	89 c3                	mov    %eax,%ebx
  801761:	85 c0                	test   %eax,%eax
  801763:	0f 88 e0 00 00 00    	js     801849 <dup+0x10e>
		return r;
	close(newfdnum);
  801769:	89 3c 24             	mov    %edi,(%esp)
  80176c:	e8 2b ff ff ff       	call   80169c <close>

	newfd = INDEX2FD(newfdnum);
  801771:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801777:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80177a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80177d:	89 04 24             	mov    %eax,(%esp)
  801780:	e8 bb fa ff ff       	call   801240 <fd2data>
  801785:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801787:	89 34 24             	mov    %esi,(%esp)
  80178a:	e8 b1 fa ff ff       	call   801240 <fd2data>
  80178f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801792:	89 da                	mov    %ebx,%edx
  801794:	89 d8                	mov    %ebx,%eax
  801796:	c1 e8 16             	shr    $0x16,%eax
  801799:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017a0:	a8 01                	test   $0x1,%al
  8017a2:	74 43                	je     8017e7 <dup+0xac>
  8017a4:	c1 ea 0c             	shr    $0xc,%edx
  8017a7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017ae:	a8 01                	test   $0x1,%al
  8017b0:	74 35                	je     8017e7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017b2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8017be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017d0:	00 
  8017d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017dc:	e8 80 f8 ff ff       	call   801061 <sys_page_map>
  8017e1:	89 c3                	mov    %eax,%ebx
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	78 3f                	js     801826 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ea:	89 c2                	mov    %eax,%edx
  8017ec:	c1 ea 0c             	shr    $0xc,%edx
  8017ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017f6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  801800:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801804:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80180b:	00 
  80180c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801810:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801817:	e8 45 f8 ff ff       	call   801061 <sys_page_map>
  80181c:	89 c3                	mov    %eax,%ebx
  80181e:	85 c0                	test   %eax,%eax
  801820:	78 04                	js     801826 <dup+0xeb>
  801822:	89 fb                	mov    %edi,%ebx
  801824:	eb 23                	jmp    801849 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801826:	89 74 24 04          	mov    %esi,0x4(%esp)
  80182a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801831:	e8 f3 f7 ff ff       	call   801029 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801836:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801839:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801844:	e8 e0 f7 ff ff       	call   801029 <sys_page_unmap>
	return r;
}
  801849:	89 d8                	mov    %ebx,%eax
  80184b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80184e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801851:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801854:	89 ec                	mov    %ebp,%esp
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	83 ec 18             	sub    $0x18,%esp
  80185e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801861:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801864:	89 c3                	mov    %eax,%ebx
  801866:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801868:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80186f:	75 11                	jne    801882 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801871:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801878:	e8 a3 02 00 00       	call   801b20 <ipc_find_env>
  80187d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801882:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801889:	00 
  80188a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801891:	00 
  801892:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801896:	a1 00 40 80 00       	mov    0x804000,%eax
  80189b:	89 04 24             	mov    %eax,(%esp)
  80189e:	e8 c1 02 00 00       	call   801b64 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018aa:	00 
  8018ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b6:	e8 18 03 00 00       	call   801bd3 <ipc_recv>
}
  8018bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018be:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018c1:	89 ec                	mov    %ebp,%esp
  8018c3:	5d                   	pop    %ebp
  8018c4:	c3                   	ret    

008018c5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018de:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018e8:	e8 6b ff ff ff       	call   801858 <fsipc>
}
  8018ed:	c9                   	leave  
  8018ee:	c3                   	ret    

008018ef <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018fb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801900:	ba 00 00 00 00       	mov    $0x0,%edx
  801905:	b8 06 00 00 00       	mov    $0x6,%eax
  80190a:	e8 49 ff ff ff       	call   801858 <fsipc>
}
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801917:	ba 00 00 00 00       	mov    $0x0,%edx
  80191c:	b8 08 00 00 00       	mov    $0x8,%eax
  801921:	e8 32 ff ff ff       	call   801858 <fsipc>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	53                   	push   %ebx
  80192c:	83 ec 14             	sub    $0x14,%esp
  80192f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801932:	8b 45 08             	mov    0x8(%ebp),%eax
  801935:	8b 40 0c             	mov    0xc(%eax),%eax
  801938:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80193d:	ba 00 00 00 00       	mov    $0x0,%edx
  801942:	b8 05 00 00 00       	mov    $0x5,%eax
  801947:	e8 0c ff ff ff       	call   801858 <fsipc>
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 2b                	js     80197b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801950:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801957:	00 
  801958:	89 1c 24             	mov    %ebx,(%esp)
  80195b:	e8 4a f1 ff ff       	call   800aaa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801960:	a1 80 50 80 00       	mov    0x805080,%eax
  801965:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80196b:	a1 84 50 80 00       	mov    0x805084,%eax
  801970:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80197b:	83 c4 14             	add    $0x14,%esp
  80197e:	5b                   	pop    %ebx
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 18             	sub    $0x18,%esp
  801987:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80198a:	8b 55 08             	mov    0x8(%ebp),%edx
  80198d:	8b 52 0c             	mov    0xc(%edx),%edx
  801990:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801996:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80199b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019a0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019a5:	0f 47 c2             	cmova  %edx,%eax
  8019a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019ba:	e8 d6 f2 ff ff       	call   800c95 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c9:	e8 8a fe ff ff       	call   801858 <fsipc>
}
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	53                   	push   %ebx
  8019d4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	8b 40 0c             	mov    0xc(%eax),%eax
  8019dd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8019e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8019f4:	e8 5f fe ff ff       	call   801858 <fsipc>
  8019f9:	89 c3                	mov    %eax,%ebx
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 17                	js     801a16 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a03:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a0a:	00 
  801a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0e:	89 04 24             	mov    %eax,(%esp)
  801a11:	e8 7f f2 ff ff       	call   800c95 <memmove>
  return r;	
}
  801a16:	89 d8                	mov    %ebx,%eax
  801a18:	83 c4 14             	add    $0x14,%esp
  801a1b:	5b                   	pop    %ebx
  801a1c:	5d                   	pop    %ebp
  801a1d:	c3                   	ret    

00801a1e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	53                   	push   %ebx
  801a22:	83 ec 14             	sub    $0x14,%esp
  801a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a28:	89 1c 24             	mov    %ebx,(%esp)
  801a2b:	e8 30 f0 ff ff       	call   800a60 <strlen>
  801a30:	89 c2                	mov    %eax,%edx
  801a32:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801a37:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801a3d:	7f 1f                	jg     801a5e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a43:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a4a:	e8 5b f0 ff ff       	call   800aaa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a54:	b8 07 00 00 00       	mov    $0x7,%eax
  801a59:	e8 fa fd ff ff       	call   801858 <fsipc>
}
  801a5e:	83 c4 14             	add    $0x14,%esp
  801a61:	5b                   	pop    %ebx
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	83 ec 28             	sub    $0x28,%esp
  801a6a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a6d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a70:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801a73:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a76:	89 04 24             	mov    %eax,(%esp)
  801a79:	e8 dd f7 ff ff       	call   80125b <fd_alloc>
  801a7e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a80:	85 c0                	test   %eax,%eax
  801a82:	0f 88 89 00 00 00    	js     801b11 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a88:	89 34 24             	mov    %esi,(%esp)
  801a8b:	e8 d0 ef ff ff       	call   800a60 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a90:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a9a:	7f 75                	jg     801b11 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aa0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801aa7:	e8 fe ef ff ff       	call   800aaa <strcpy>
  fsipcbuf.open.req_omode = mode;
  801aac:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aaf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801ab4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab7:	b8 01 00 00 00       	mov    $0x1,%eax
  801abc:	e8 97 fd ff ff       	call   801858 <fsipc>
  801ac1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 0f                	js     801ad6 <open+0x72>
  return fd2num(fd);
  801ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aca:	89 04 24             	mov    %eax,(%esp)
  801acd:	e8 5e f7 ff ff       	call   801230 <fd2num>
  801ad2:	89 c3                	mov    %eax,%ebx
  801ad4:	eb 3b                	jmp    801b11 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801ad6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801add:	00 
  801ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae1:	89 04 24             	mov    %eax,(%esp)
  801ae4:	e8 2b fb ff ff       	call   801614 <fd_close>
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	74 24                	je     801b11 <open+0xad>
  801aed:	c7 44 24 0c 14 24 80 	movl   $0x802414,0xc(%esp)
  801af4:	00 
  801af5:	c7 44 24 08 29 24 80 	movl   $0x802429,0x8(%esp)
  801afc:	00 
  801afd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801b04:	00 
  801b05:	c7 04 24 3e 24 80 00 	movl   $0x80243e,(%esp)
  801b0c:	e8 9f e7 ff ff       	call   8002b0 <_panic>
  return r;
}
  801b11:	89 d8                	mov    %ebx,%eax
  801b13:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b16:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b19:	89 ec                	mov    %ebp,%esp
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    
  801b1d:	00 00                	add    %al,(%eax)
	...

00801b20 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b26:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801b2c:	b8 01 00 00 00       	mov    $0x1,%eax
  801b31:	39 ca                	cmp    %ecx,%edx
  801b33:	75 04                	jne    801b39 <ipc_find_env+0x19>
  801b35:	b0 00                	mov    $0x0,%al
  801b37:	eb 0f                	jmp    801b48 <ipc_find_env+0x28>
  801b39:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b3c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801b42:	8b 12                	mov    (%edx),%edx
  801b44:	39 ca                	cmp    %ecx,%edx
  801b46:	75 0c                	jne    801b54 <ipc_find_env+0x34>
			return envs[i].env_id;
  801b48:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b4b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801b50:	8b 00                	mov    (%eax),%eax
  801b52:	eb 0e                	jmp    801b62 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b54:	83 c0 01             	add    $0x1,%eax
  801b57:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b5c:	75 db                	jne    801b39 <ipc_find_env+0x19>
  801b5e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	57                   	push   %edi
  801b68:	56                   	push   %esi
  801b69:	53                   	push   %ebx
  801b6a:	83 ec 1c             	sub    $0x1c,%esp
  801b6d:	8b 75 08             	mov    0x8(%ebp),%esi
  801b70:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801b76:	85 db                	test   %ebx,%ebx
  801b78:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b7d:	0f 44 d8             	cmove  %eax,%ebx
  801b80:	eb 29                	jmp    801bab <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801b82:	85 c0                	test   %eax,%eax
  801b84:	79 25                	jns    801bab <ipc_send+0x47>
  801b86:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b89:	74 20                	je     801bab <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801b8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b8f:	c7 44 24 08 49 24 80 	movl   $0x802449,0x8(%esp)
  801b96:	00 
  801b97:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801b9e:	00 
  801b9f:	c7 04 24 67 24 80 00 	movl   $0x802467,(%esp)
  801ba6:	e8 05 e7 ff ff       	call   8002b0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801bab:	8b 45 14             	mov    0x14(%ebp),%eax
  801bae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bb2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bba:	89 34 24             	mov    %esi,(%esp)
  801bbd:	e8 89 f3 ff ff       	call   800f4b <sys_ipc_try_send>
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	75 bc                	jne    801b82 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801bc6:	e8 06 f5 ff ff       	call   8010d1 <sys_yield>
}
  801bcb:	83 c4 1c             	add    $0x1c,%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5f                   	pop    %edi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	83 ec 28             	sub    $0x28,%esp
  801bd9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bdc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bdf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801be2:	8b 75 08             	mov    0x8(%ebp),%esi
  801be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801beb:	85 c0                	test   %eax,%eax
  801bed:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801bf2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801bf5:	89 04 24             	mov    %eax,(%esp)
  801bf8:	e8 15 f3 ff ff       	call   800f12 <sys_ipc_recv>
  801bfd:	89 c3                	mov    %eax,%ebx
  801bff:	85 c0                	test   %eax,%eax
  801c01:	79 2a                	jns    801c2d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801c03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0b:	c7 04 24 71 24 80 00 	movl   $0x802471,(%esp)
  801c12:	e8 52 e7 ff ff       	call   800369 <cprintf>
		if(from_env_store != NULL)
  801c17:	85 f6                	test   %esi,%esi
  801c19:	74 06                	je     801c21 <ipc_recv+0x4e>
			*from_env_store = 0;
  801c1b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c21:	85 ff                	test   %edi,%edi
  801c23:	74 2d                	je     801c52 <ipc_recv+0x7f>
			*perm_store = 0;
  801c25:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801c2b:	eb 25                	jmp    801c52 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801c2d:	85 f6                	test   %esi,%esi
  801c2f:	90                   	nop
  801c30:	74 0a                	je     801c3c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801c32:	a1 04 40 80 00       	mov    0x804004,%eax
  801c37:	8b 40 74             	mov    0x74(%eax),%eax
  801c3a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801c3c:	85 ff                	test   %edi,%edi
  801c3e:	74 0a                	je     801c4a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801c40:	a1 04 40 80 00       	mov    0x804004,%eax
  801c45:	8b 40 78             	mov    0x78(%eax),%eax
  801c48:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c4f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801c52:	89 d8                	mov    %ebx,%eax
  801c54:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c57:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c5a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c5d:	89 ec                	mov    %ebp,%esp
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    
	...

00801c70 <__udivdi3>:
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	83 ec 10             	sub    $0x10,%esp
  801c78:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7b:	8b 55 08             	mov    0x8(%ebp),%edx
  801c7e:	8b 75 10             	mov    0x10(%ebp),%esi
  801c81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801c84:	85 c0                	test   %eax,%eax
  801c86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801c89:	75 35                	jne    801cc0 <__udivdi3+0x50>
  801c8b:	39 fe                	cmp    %edi,%esi
  801c8d:	77 61                	ja     801cf0 <__udivdi3+0x80>
  801c8f:	85 f6                	test   %esi,%esi
  801c91:	75 0b                	jne    801c9e <__udivdi3+0x2e>
  801c93:	b8 01 00 00 00       	mov    $0x1,%eax
  801c98:	31 d2                	xor    %edx,%edx
  801c9a:	f7 f6                	div    %esi
  801c9c:	89 c6                	mov    %eax,%esi
  801c9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ca1:	31 d2                	xor    %edx,%edx
  801ca3:	89 f8                	mov    %edi,%eax
  801ca5:	f7 f6                	div    %esi
  801ca7:	89 c7                	mov    %eax,%edi
  801ca9:	89 c8                	mov    %ecx,%eax
  801cab:	f7 f6                	div    %esi
  801cad:	89 c1                	mov    %eax,%ecx
  801caf:	89 fa                	mov    %edi,%edx
  801cb1:	89 c8                	mov    %ecx,%eax
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	39 f8                	cmp    %edi,%eax
  801cc2:	77 1c                	ja     801ce0 <__udivdi3+0x70>
  801cc4:	0f bd d0             	bsr    %eax,%edx
  801cc7:	83 f2 1f             	xor    $0x1f,%edx
  801cca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801ccd:	75 39                	jne    801d08 <__udivdi3+0x98>
  801ccf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801cd2:	0f 86 a0 00 00 00    	jbe    801d78 <__udivdi3+0x108>
  801cd8:	39 f8                	cmp    %edi,%eax
  801cda:	0f 82 98 00 00 00    	jb     801d78 <__udivdi3+0x108>
  801ce0:	31 ff                	xor    %edi,%edi
  801ce2:	31 c9                	xor    %ecx,%ecx
  801ce4:	89 c8                	mov    %ecx,%eax
  801ce6:	89 fa                	mov    %edi,%edx
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	5e                   	pop    %esi
  801cec:	5f                   	pop    %edi
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    
  801cef:	90                   	nop
  801cf0:	89 d1                	mov    %edx,%ecx
  801cf2:	89 fa                	mov    %edi,%edx
  801cf4:	89 c8                	mov    %ecx,%eax
  801cf6:	31 ff                	xor    %edi,%edi
  801cf8:	f7 f6                	div    %esi
  801cfa:	89 c1                	mov    %eax,%ecx
  801cfc:	89 fa                	mov    %edi,%edx
  801cfe:	89 c8                	mov    %ecx,%eax
  801d00:	83 c4 10             	add    $0x10,%esp
  801d03:	5e                   	pop    %esi
  801d04:	5f                   	pop    %edi
  801d05:	5d                   	pop    %ebp
  801d06:	c3                   	ret    
  801d07:	90                   	nop
  801d08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d0c:	89 f2                	mov    %esi,%edx
  801d0e:	d3 e0                	shl    %cl,%eax
  801d10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d13:	b8 20 00 00 00       	mov    $0x20,%eax
  801d18:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801d1b:	89 c1                	mov    %eax,%ecx
  801d1d:	d3 ea                	shr    %cl,%edx
  801d1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d23:	0b 55 ec             	or     -0x14(%ebp),%edx
  801d26:	d3 e6                	shl    %cl,%esi
  801d28:	89 c1                	mov    %eax,%ecx
  801d2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801d2d:	89 fe                	mov    %edi,%esi
  801d2f:	d3 ee                	shr    %cl,%esi
  801d31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d35:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d3b:	d3 e7                	shl    %cl,%edi
  801d3d:	89 c1                	mov    %eax,%ecx
  801d3f:	d3 ea                	shr    %cl,%edx
  801d41:	09 d7                	or     %edx,%edi
  801d43:	89 f2                	mov    %esi,%edx
  801d45:	89 f8                	mov    %edi,%eax
  801d47:	f7 75 ec             	divl   -0x14(%ebp)
  801d4a:	89 d6                	mov    %edx,%esi
  801d4c:	89 c7                	mov    %eax,%edi
  801d4e:	f7 65 e8             	mull   -0x18(%ebp)
  801d51:	39 d6                	cmp    %edx,%esi
  801d53:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d56:	72 30                	jb     801d88 <__udivdi3+0x118>
  801d58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	39 c2                	cmp    %eax,%edx
  801d63:	73 05                	jae    801d6a <__udivdi3+0xfa>
  801d65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801d68:	74 1e                	je     801d88 <__udivdi3+0x118>
  801d6a:	89 f9                	mov    %edi,%ecx
  801d6c:	31 ff                	xor    %edi,%edi
  801d6e:	e9 71 ff ff ff       	jmp    801ce4 <__udivdi3+0x74>
  801d73:	90                   	nop
  801d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d78:	31 ff                	xor    %edi,%edi
  801d7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801d7f:	e9 60 ff ff ff       	jmp    801ce4 <__udivdi3+0x74>
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801d8b:	31 ff                	xor    %edi,%edi
  801d8d:	89 c8                	mov    %ecx,%eax
  801d8f:	89 fa                	mov    %edi,%edx
  801d91:	83 c4 10             	add    $0x10,%esp
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
	...

00801da0 <__umoddi3>:
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	57                   	push   %edi
  801da4:	56                   	push   %esi
  801da5:	83 ec 20             	sub    $0x20,%esp
  801da8:	8b 55 14             	mov    0x14(%ebp),%edx
  801dab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dae:	8b 7d 10             	mov    0x10(%ebp),%edi
  801db1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801db4:	85 d2                	test   %edx,%edx
  801db6:	89 c8                	mov    %ecx,%eax
  801db8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801dbb:	75 13                	jne    801dd0 <__umoddi3+0x30>
  801dbd:	39 f7                	cmp    %esi,%edi
  801dbf:	76 3f                	jbe    801e00 <__umoddi3+0x60>
  801dc1:	89 f2                	mov    %esi,%edx
  801dc3:	f7 f7                	div    %edi
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	31 d2                	xor    %edx,%edx
  801dc9:	83 c4 20             	add    $0x20,%esp
  801dcc:	5e                   	pop    %esi
  801dcd:	5f                   	pop    %edi
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    
  801dd0:	39 f2                	cmp    %esi,%edx
  801dd2:	77 4c                	ja     801e20 <__umoddi3+0x80>
  801dd4:	0f bd ca             	bsr    %edx,%ecx
  801dd7:	83 f1 1f             	xor    $0x1f,%ecx
  801dda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ddd:	75 51                	jne    801e30 <__umoddi3+0x90>
  801ddf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801de2:	0f 87 e0 00 00 00    	ja     801ec8 <__umoddi3+0x128>
  801de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801deb:	29 f8                	sub    %edi,%eax
  801ded:	19 d6                	sbb    %edx,%esi
  801def:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df5:	89 f2                	mov    %esi,%edx
  801df7:	83 c4 20             	add    $0x20,%esp
  801dfa:	5e                   	pop    %esi
  801dfb:	5f                   	pop    %edi
  801dfc:	5d                   	pop    %ebp
  801dfd:	c3                   	ret    
  801dfe:	66 90                	xchg   %ax,%ax
  801e00:	85 ff                	test   %edi,%edi
  801e02:	75 0b                	jne    801e0f <__umoddi3+0x6f>
  801e04:	b8 01 00 00 00       	mov    $0x1,%eax
  801e09:	31 d2                	xor    %edx,%edx
  801e0b:	f7 f7                	div    %edi
  801e0d:	89 c7                	mov    %eax,%edi
  801e0f:	89 f0                	mov    %esi,%eax
  801e11:	31 d2                	xor    %edx,%edx
  801e13:	f7 f7                	div    %edi
  801e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e18:	f7 f7                	div    %edi
  801e1a:	eb a9                	jmp    801dc5 <__umoddi3+0x25>
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	89 c8                	mov    %ecx,%eax
  801e22:	89 f2                	mov    %esi,%edx
  801e24:	83 c4 20             	add    $0x20,%esp
  801e27:	5e                   	pop    %esi
  801e28:	5f                   	pop    %edi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    
  801e2b:	90                   	nop
  801e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e30:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e34:	d3 e2                	shl    %cl,%edx
  801e36:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801e39:	ba 20 00 00 00       	mov    $0x20,%edx
  801e3e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801e41:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801e44:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801e48:	89 fa                	mov    %edi,%edx
  801e4a:	d3 ea                	shr    %cl,%edx
  801e4c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e50:	0b 55 f4             	or     -0xc(%ebp),%edx
  801e53:	d3 e7                	shl    %cl,%edi
  801e55:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801e59:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801e5c:	89 f2                	mov    %esi,%edx
  801e5e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801e61:	89 c7                	mov    %eax,%edi
  801e63:	d3 ea                	shr    %cl,%edx
  801e65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801e6c:	89 c2                	mov    %eax,%edx
  801e6e:	d3 e6                	shl    %cl,%esi
  801e70:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801e74:	d3 ea                	shr    %cl,%edx
  801e76:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e7a:	09 d6                	or     %edx,%esi
  801e7c:	89 f0                	mov    %esi,%eax
  801e7e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801e81:	d3 e7                	shl    %cl,%edi
  801e83:	89 f2                	mov    %esi,%edx
  801e85:	f7 75 f4             	divl   -0xc(%ebp)
  801e88:	89 d6                	mov    %edx,%esi
  801e8a:	f7 65 e8             	mull   -0x18(%ebp)
  801e8d:	39 d6                	cmp    %edx,%esi
  801e8f:	72 2b                	jb     801ebc <__umoddi3+0x11c>
  801e91:	39 c7                	cmp    %eax,%edi
  801e93:	72 23                	jb     801eb8 <__umoddi3+0x118>
  801e95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e99:	29 c7                	sub    %eax,%edi
  801e9b:	19 d6                	sbb    %edx,%esi
  801e9d:	89 f0                	mov    %esi,%eax
  801e9f:	89 f2                	mov    %esi,%edx
  801ea1:	d3 ef                	shr    %cl,%edi
  801ea3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ea7:	d3 e0                	shl    %cl,%eax
  801ea9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ead:	09 f8                	or     %edi,%eax
  801eaf:	d3 ea                	shr    %cl,%edx
  801eb1:	83 c4 20             	add    $0x20,%esp
  801eb4:	5e                   	pop    %esi
  801eb5:	5f                   	pop    %edi
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    
  801eb8:	39 d6                	cmp    %edx,%esi
  801eba:	75 d9                	jne    801e95 <__umoddi3+0xf5>
  801ebc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801ebf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801ec2:	eb d1                	jmp    801e95 <__umoddi3+0xf5>
  801ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ec8:	39 f2                	cmp    %esi,%edx
  801eca:	0f 82 18 ff ff ff    	jb     801de8 <__umoddi3+0x48>
  801ed0:	e9 1d ff ff ff       	jmp    801df2 <__umoddi3+0x52>
