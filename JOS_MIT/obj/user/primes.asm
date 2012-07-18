
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 1f 01 00 00       	call   800150 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003d:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800040:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800047:	00 
  800048:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004f:	00 
  800050:	89 34 24             	mov    %esi,(%esp)
  800053:	e8 0b 16 00 00       	call   801663 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 04 40 80 00       	mov    0x804004,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 00 23 80 00 	movl   $0x802300,(%esp)
  800071:	e8 ff 01 00 00       	call   800275 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 e3 10 00 00       	call   80115e <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 13 27 80 	movl   $0x802713,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  80009c:	e8 1b 01 00 00       	call   8001bc <_panic>
	if (id == 0)
  8000a1:	85 c0                	test   %eax,%eax
  8000a3:	74 9b                	je     800040 <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000af:	00 
  8000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b7:	00 
  8000b8:	89 34 24             	mov    %esi,(%esp)
  8000bb:	e8 a3 15 00 00       	call   801663 <ipc_recv>
  8000c0:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c2:	89 c2                	mov    %eax,%edx
  8000c4:	c1 fa 1f             	sar    $0x1f,%edx
  8000c7:	f7 fb                	idiv   %ebx
  8000c9:	85 d2                	test   %edx,%edx
  8000cb:	74 db                	je     8000a8 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d4:	00 
  8000d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000dc:	00 
  8000dd:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e1:	89 3c 24             	mov    %edi,(%esp)
  8000e4:	e8 0b 15 00 00       	call   8015f4 <ipc_send>
  8000e9:	eb bd                	jmp    8000a8 <primeproc+0x74>

008000eb <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f3:	e8 66 10 00 00       	call   80115e <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 13 27 80 	movl   $0x802713,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  800119:	e8 9e 00 00 00       	call   8001bc <_panic>
	if (id == 0)
  80011e:	bb 02 00 00 00       	mov    $0x2,%ebx
  800123:	85 c0                	test   %eax,%eax
  800125:	75 05                	jne    80012c <umain+0x41>
		primeproc();
  800127:	e8 08 ff ff ff       	call   800034 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800133:	00 
  800134:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013b:	00 
  80013c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800140:	89 34 24             	mov    %esi,(%esp)
  800143:	e8 ac 14 00 00       	call   8015f4 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800148:	83 c3 01             	add    $0x1,%ebx
  80014b:	eb df                	jmp    80012c <umain+0x41>
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
  800156:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800159:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80015c:	8b 75 08             	mov    0x8(%ebp),%esi
  80015f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800162:	e8 ed 0e 00 00       	call   801054 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800184:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800188:	89 34 24             	mov    %esi,(%esp)
  80018b:	e8 5b ff ff ff       	call   8000eb <umain>

	// exit gracefully
	exit();
  800190:	e8 0b 00 00 00       	call   8001a0 <exit>
}
  800195:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800198:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80019b:	89 ec                	mov    %ebp,%esp
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
	...

008001a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a6:	e8 3e 1a 00 00       	call   801be9 <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 d8 0e 00 00       	call   80108f <sys_env_destroy>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    
  8001b9:	00 00                	add    %al,(%eax)
	...

008001bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	56                   	push   %esi
  8001c0:	53                   	push   %ebx
  8001c1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001c4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c7:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8001cd:	e8 82 0e 00 00       	call   801054 <sys_getenvid>
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e8:	c7 04 24 24 23 80 00 	movl   $0x802324,(%esp)
  8001ef:	e8 81 00 00 00       	call   800275 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 11 00 00 00       	call   800214 <vcprintf>
	cprintf("\n");
  800203:	c7 04 24 13 2a 80 00 	movl   $0x802a13,(%esp)
  80020a:	e8 66 00 00 00       	call   800275 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020f:	cc                   	int3   
  800210:	eb fd                	jmp    80020f <_panic+0x53>
	...

00800214 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80021d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800224:	00 00 00 
	b.cnt = 0;
  800227:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800231:	8b 45 0c             	mov    0xc(%ebp),%eax
  800234:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800238:	8b 45 08             	mov    0x8(%ebp),%eax
  80023b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800245:	89 44 24 04          	mov    %eax,0x4(%esp)
  800249:	c7 04 24 8f 02 80 00 	movl   $0x80028f,(%esp)
  800250:	e8 d8 01 00 00       	call   80042d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800255:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80025b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800265:	89 04 24             	mov    %eax,(%esp)
  800268:	e8 96 0e 00 00       	call   801103 <sys_cputs>

	return b.cnt;
}
  80026d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80027b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80027e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	e8 87 ff ff ff       	call   800214 <vcprintf>
	va_end(ap);

	return cnt;
}
  80028d:	c9                   	leave  
  80028e:	c3                   	ret    

0080028f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	53                   	push   %ebx
  800293:	83 ec 14             	sub    $0x14,%esp
  800296:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800299:	8b 03                	mov    (%ebx),%eax
  80029b:	8b 55 08             	mov    0x8(%ebp),%edx
  80029e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002a2:	83 c0 01             	add    $0x1,%eax
  8002a5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002a7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ac:	75 19                	jne    8002c7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002ae:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002b5:	00 
  8002b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b9:	89 04 24             	mov    %eax,(%esp)
  8002bc:	e8 42 0e 00 00       	call   801103 <sys_cputs>
		b->idx = 0;
  8002c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002c7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002cb:	83 c4 14             	add    $0x14,%esp
  8002ce:	5b                   	pop    %ebx
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    
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
  80035d:	e8 2e 1d 00 00       	call   802090 <__udivdi3>
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
  8003b8:	e8 03 1e 00 00       	call   8021c0 <__umoddi3>
  8003bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c1:	0f be 80 47 23 80 00 	movsbl 0x802347(%eax),%eax
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
  8004a5:	ff 24 95 20 25 80 00 	jmp    *0x802520(,%edx,4)
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
  800578:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	75 20                	jne    8005a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800583:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800587:	c7 44 24 08 58 23 80 	movl   $0x802358,0x8(%esp)
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
  8005a7:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
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
  8005e1:	b8 61 23 80 00       	mov    $0x802361,%eax
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
  800825:	c7 44 24 0c 7c 24 80 	movl   $0x80247c,0xc(%esp)
  80082c:	00 
  80082d:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
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
  800853:	c7 44 24 0c b4 24 80 	movl   $0x8024b4,0xc(%esp)
  80085a:	00 
  80085b:	c7 44 24 08 47 2a 80 	movl   $0x802a47,0x8(%esp)
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
  800df7:	c7 44 24 08 c0 26 80 	movl   $0x8026c0,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 dd 26 80 00 	movl   $0x8026dd,(%esp)
  800e0e:	e8 a9 f3 ff ff       	call   8001bc <_panic>

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
	...

0080113c <sfork>:
}

// Challenge!
int
sfork(void)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801142:	c7 44 24 08 eb 26 80 	movl   $0x8026eb,0x8(%esp)
  801149:	00 
  80114a:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801151:	00 
  801152:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  801159:	e8 5e f0 ff ff       	call   8001bc <_panic>

0080115e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	57                   	push   %edi
  801162:	56                   	push   %esi
  801163:	53                   	push   %ebx
  801164:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  801167:	c7 04 24 22 14 80 00 	movl   $0x801422,(%esp)
  80116e:	e8 7d 0e 00 00       	call   801ff0 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801173:	ba 08 00 00 00       	mov    $0x8,%edx
  801178:	89 d0                	mov    %edx,%eax
  80117a:	51                   	push   %ecx
  80117b:	52                   	push   %edx
  80117c:	53                   	push   %ebx
  80117d:	55                   	push   %ebp
  80117e:	56                   	push   %esi
  80117f:	57                   	push   %edi
  801180:	89 e5                	mov    %esp,%ebp
  801182:	8d 35 8a 11 80 00    	lea    0x80118a,%esi
  801188:	0f 34                	sysenter 

0080118a <.after_sysenter_label>:
  80118a:	5f                   	pop    %edi
  80118b:	5e                   	pop    %esi
  80118c:	5d                   	pop    %ebp
  80118d:	5b                   	pop    %ebx
  80118e:	5a                   	pop    %edx
  80118f:	59                   	pop    %ecx
  801190:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801193:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801197:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  80119e:	00 
  80119f:	c7 44 24 04 01 27 80 	movl   $0x802701,0x4(%esp)
  8011a6:	00 
  8011a7:	c7 04 24 5c 27 80 00 	movl   $0x80275c,(%esp)
  8011ae:	e8 c2 f0 ff ff       	call   800275 <cprintf>
	if (envidnum < 0)
  8011b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011b7:	79 23                	jns    8011dc <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  8011b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c0:	c7 44 24 08 0c 27 80 	movl   $0x80270c,0x8(%esp)
  8011c7:	00 
  8011c8:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8011cf:	00 
  8011d0:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8011d7:	e8 e0 ef ff ff       	call   8001bc <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8011dc:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8011e1:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8011e6:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  8011eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011ef:	75 1c                	jne    80120d <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011f1:	e8 5e fe ff ff       	call   801054 <sys_getenvid>
  8011f6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011fb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801203:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801208:	e9 0a 02 00 00       	jmp    801417 <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  80120d:	89 d8                	mov    %ebx,%eax
  80120f:	c1 e8 16             	shr    $0x16,%eax
  801212:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801215:	a8 01                	test   $0x1,%al
  801217:	0f 84 43 01 00 00    	je     801360 <.after_sysenter_label+0x1d6>
  80121d:	89 d8                	mov    %ebx,%eax
  80121f:	c1 e8 0c             	shr    $0xc,%eax
  801222:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801225:	f6 c2 01             	test   $0x1,%dl
  801228:	0f 84 32 01 00 00    	je     801360 <.after_sysenter_label+0x1d6>
  80122e:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801231:	f6 c2 04             	test   $0x4,%dl
  801234:	0f 84 26 01 00 00    	je     801360 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  80123a:	c1 e0 0c             	shl    $0xc,%eax
  80123d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801240:	c1 e8 0c             	shr    $0xc,%eax
  801243:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  801246:	89 c2                	mov    %eax,%edx
  801248:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  80124e:	a9 02 08 00 00       	test   $0x802,%eax
  801253:	0f 84 a0 00 00 00    	je     8012f9 <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  801259:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  80125c:	80 ce 08             	or     $0x8,%dh
  80125f:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801262:	89 54 24 10          	mov    %edx,0x10(%esp)
  801266:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801269:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80126d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801270:	89 44 24 08          	mov    %eax,0x8(%esp)
  801274:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801282:	e8 ea fc ff ff       	call   800f71 <sys_page_map>
  801287:	85 c0                	test   %eax,%eax
  801289:	79 20                	jns    8012ab <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80128b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80128f:	c7 44 24 08 84 27 80 	movl   $0x802784,0x8(%esp)
  801296:	00 
  801297:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  80129e:	00 
  80129f:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8012a6:	e8 11 ef ff ff       	call   8001bc <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  8012ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012c0:	00 
  8012c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cc:	e8 a0 fc ff ff       	call   800f71 <sys_page_map>
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	0f 89 87 00 00 00    	jns    801360 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  8012d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012dd:	c7 44 24 08 b0 27 80 	movl   $0x8027b0,0x8(%esp)
  8012e4:	00 
  8012e5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8012ec:	00 
  8012ed:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8012f4:	e8 c3 ee ff ff       	call   8001bc <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  8012f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801300:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  80130e:	e8 62 ef ff ff       	call   800275 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801313:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80131a:	00 
  80131b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80131e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801322:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801325:	89 44 24 08          	mov    %eax,0x8(%esp)
  801329:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80132c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801330:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801337:	e8 35 fc ff ff       	call   800f71 <sys_page_map>
  80133c:	85 c0                	test   %eax,%eax
  80133e:	79 20                	jns    801360 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801340:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801344:	c7 44 24 08 dc 27 80 	movl   $0x8027dc,0x8(%esp)
  80134b:	00 
  80134c:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801353:	00 
  801354:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  80135b:	e8 5c ee ff ff       	call   8001bc <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801360:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801366:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80136c:	0f 85 9b fe ff ff    	jne    80120d <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801372:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801379:	00 
  80137a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801381:	ee 
  801382:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801385:	89 04 24             	mov    %eax,(%esp)
  801388:	e8 1d fc ff ff       	call   800faa <sys_page_alloc>
  80138d:	85 c0                	test   %eax,%eax
  80138f:	79 20                	jns    8013b1 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801391:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801395:	c7 44 24 08 08 28 80 	movl   $0x802808,0x8(%esp)
  80139c:	00 
  80139d:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8013a4:	00 
  8013a5:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8013ac:	e8 0b ee ff ff       	call   8001bc <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  8013b1:	c7 44 24 04 60 20 80 	movl   $0x802060,0x4(%esp)
  8013b8:	00 
  8013b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013bc:	89 04 24             	mov    %eax,(%esp)
  8013bf:	e8 cd fa ff ff       	call   800e91 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  8013c4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013cb:	00 
  8013cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cf:	89 04 24             	mov    %eax,(%esp)
  8013d2:	e8 2a fb ff ff       	call   800f01 <sys_env_set_status>
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	79 20                	jns    8013fb <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  8013db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013df:	c7 44 24 08 2c 28 80 	movl   $0x80282c,0x8(%esp)
  8013e6:	00 
  8013e7:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8013ee:	00 
  8013ef:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8013f6:	e8 c1 ed ff ff       	call   8001bc <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  8013fb:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801402:	00 
  801403:	c7 44 24 04 01 27 80 	movl   $0x802701,0x4(%esp)
  80140a:	00 
  80140b:	c7 04 24 2e 27 80 00 	movl   $0x80272e,(%esp)
  801412:	e8 5e ee ff ff       	call   800275 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  801417:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80141a:	83 c4 3c             	add    $0x3c,%esp
  80141d:	5b                   	pop    %ebx
  80141e:	5e                   	pop    %esi
  80141f:	5f                   	pop    %edi
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	57                   	push   %edi
  801426:	56                   	push   %esi
  801427:	53                   	push   %ebx
  801428:	83 ec 2c             	sub    $0x2c,%esp
  80142b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  80142e:	8b 33                	mov    (%ebx),%esi
	uint32_t err = utf->utf_err;
  801430:	8b 7b 04             	mov    0x4(%ebx),%edi
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
  801433:	8b 43 2c             	mov    0x2c(%ebx),%eax
  801436:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143a:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801441:	e8 2f ee ff ff       	call   800275 <cprintf>
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801446:	f7 c7 02 00 00 00    	test   $0x2,%edi
  80144c:	75 2b                	jne    801479 <pgfault+0x57>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  80144e:	8b 43 28             	mov    0x28(%ebx),%eax
  801451:	89 44 24 14          	mov    %eax,0x14(%esp)
  801455:	89 74 24 10          	mov    %esi,0x10(%esp)
  801459:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80145d:	c7 44 24 08 74 28 80 	movl   $0x802874,0x8(%esp)
  801464:	00 
  801465:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80146c:	00 
  80146d:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  801474:	e8 43 ed ff ff       	call   8001bc <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801479:	89 f0                	mov    %esi,%eax
  80147b:	c1 e8 16             	shr    $0x16,%eax
  80147e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801485:	a8 01                	test   $0x1,%al
  801487:	74 11                	je     80149a <pgfault+0x78>
  801489:	89 f0                	mov    %esi,%eax
  80148b:	c1 e8 0c             	shr    $0xc,%eax
  80148e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801495:	f6 c4 08             	test   $0x8,%ah
  801498:	75 1c                	jne    8014b6 <pgfault+0x94>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  80149a:	c7 44 24 08 b0 28 80 	movl   $0x8028b0,0x8(%esp)
  8014a1:	00 
  8014a2:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8014a9:	00 
  8014aa:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8014b1:	e8 06 ed ff ff       	call   8001bc <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8014b6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014bd:	00 
  8014be:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014c5:	00 
  8014c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014cd:	e8 d8 fa ff ff       	call   800faa <sys_page_alloc>
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	79 20                	jns    8014f6 <pgfault+0xd4>
		panic ("pgfault: page allocation failed : %e", r);
  8014d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014da:	c7 44 24 08 ec 28 80 	movl   $0x8028ec,0x8(%esp)
  8014e1:	00 
  8014e2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014e9:	00 
  8014ea:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  8014f1:	e8 c6 ec ff ff       	call   8001bc <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  8014f6:	89 f3                	mov    %esi,%ebx
  8014f8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  8014fe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801505:	00 
  801506:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80150a:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801511:	e8 8f f6 ff ff       	call   800ba5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801516:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80151d:	00 
  80151e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801522:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801529:	00 
  80152a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801531:	00 
  801532:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801539:	e8 33 fa ff ff       	call   800f71 <sys_page_map>
  80153e:	85 c0                	test   %eax,%eax
  801540:	79 20                	jns    801562 <pgfault+0x140>
		panic ("pgfault: page mapping failed : %e", r);
  801542:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801546:	c7 44 24 08 14 29 80 	movl   $0x802914,0x8(%esp)
  80154d:	00 
  80154e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801555:	00 
  801556:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  80155d:	e8 5a ec ff ff       	call   8001bc <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  801562:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801569:	00 
  80156a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801571:	e8 c3 f9 ff ff       	call   800f39 <sys_page_unmap>
  801576:	85 c0                	test   %eax,%eax
  801578:	79 20                	jns    80159a <pgfault+0x178>
		panic("pgfault: page unmapping failed : %e", r);
  80157a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80157e:	c7 44 24 08 38 29 80 	movl   $0x802938,0x8(%esp)
  801585:	00 
  801586:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80158d:	00 
  80158e:	c7 04 24 01 27 80 00 	movl   $0x802701,(%esp)
  801595:	e8 22 ec ff ff       	call   8001bc <_panic>
	cprintf("pgfault: finish\n");
  80159a:	c7 04 24 48 27 80 00 	movl   $0x802748,(%esp)
  8015a1:	e8 cf ec ff ff       	call   800275 <cprintf>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  8015a6:	83 c4 2c             	add    $0x2c,%esp
  8015a9:	5b                   	pop    %ebx
  8015aa:	5e                   	pop    %esi
  8015ab:	5f                   	pop    %edi
  8015ac:	5d                   	pop    %ebp
  8015ad:	c3                   	ret    
	...

008015b0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8015b6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8015bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8015c1:	39 ca                	cmp    %ecx,%edx
  8015c3:	75 04                	jne    8015c9 <ipc_find_env+0x19>
  8015c5:	b0 00                	mov    $0x0,%al
  8015c7:	eb 0f                	jmp    8015d8 <ipc_find_env+0x28>
  8015c9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8015cc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8015d2:	8b 12                	mov    (%edx),%edx
  8015d4:	39 ca                	cmp    %ecx,%edx
  8015d6:	75 0c                	jne    8015e4 <ipc_find_env+0x34>
			return envs[i].env_id;
  8015d8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015db:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8015e0:	8b 00                	mov    (%eax),%eax
  8015e2:	eb 0e                	jmp    8015f2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015e4:	83 c0 01             	add    $0x1,%eax
  8015e7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015ec:	75 db                	jne    8015c9 <ipc_find_env+0x19>
  8015ee:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	57                   	push   %edi
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 1c             	sub    $0x1c,%esp
  8015fd:	8b 75 08             	mov    0x8(%ebp),%esi
  801600:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801603:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801606:	85 db                	test   %ebx,%ebx
  801608:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80160d:	0f 44 d8             	cmove  %eax,%ebx
  801610:	eb 29                	jmp    80163b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801612:	85 c0                	test   %eax,%eax
  801614:	79 25                	jns    80163b <ipc_send+0x47>
  801616:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801619:	74 20                	je     80163b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  80161b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80161f:	c7 44 24 08 5c 29 80 	movl   $0x80295c,0x8(%esp)
  801626:	00 
  801627:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80162e:	00 
  80162f:	c7 04 24 7a 29 80 00 	movl   $0x80297a,(%esp)
  801636:	e8 81 eb ff ff       	call   8001bc <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80163b:	8b 45 14             	mov    0x14(%ebp),%eax
  80163e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801642:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801646:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80164a:	89 34 24             	mov    %esi,(%esp)
  80164d:	e8 09 f8 ff ff       	call   800e5b <sys_ipc_try_send>
  801652:	85 c0                	test   %eax,%eax
  801654:	75 bc                	jne    801612 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801656:	e8 86 f9 ff ff       	call   800fe1 <sys_yield>
}
  80165b:	83 c4 1c             	add    $0x1c,%esp
  80165e:	5b                   	pop    %ebx
  80165f:	5e                   	pop    %esi
  801660:	5f                   	pop    %edi
  801661:	5d                   	pop    %ebp
  801662:	c3                   	ret    

00801663 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 28             	sub    $0x28,%esp
  801669:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80166c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80166f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801672:	8b 75 08             	mov    0x8(%ebp),%esi
  801675:	8b 45 0c             	mov    0xc(%ebp),%eax
  801678:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80167b:	85 c0                	test   %eax,%eax
  80167d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801682:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801685:	89 04 24             	mov    %eax,(%esp)
  801688:	e8 95 f7 ff ff       	call   800e22 <sys_ipc_recv>
  80168d:	89 c3                	mov    %eax,%ebx
  80168f:	85 c0                	test   %eax,%eax
  801691:	79 2a                	jns    8016bd <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801693:	89 44 24 08          	mov    %eax,0x8(%esp)
  801697:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169b:	c7 04 24 84 29 80 00 	movl   $0x802984,(%esp)
  8016a2:	e8 ce eb ff ff       	call   800275 <cprintf>
		if(from_env_store != NULL)
  8016a7:	85 f6                	test   %esi,%esi
  8016a9:	74 06                	je     8016b1 <ipc_recv+0x4e>
			*from_env_store = 0;
  8016ab:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8016b1:	85 ff                	test   %edi,%edi
  8016b3:	74 2d                	je     8016e2 <ipc_recv+0x7f>
			*perm_store = 0;
  8016b5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016bb:	eb 25                	jmp    8016e2 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  8016bd:	85 f6                	test   %esi,%esi
  8016bf:	90                   	nop
  8016c0:	74 0a                	je     8016cc <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  8016c2:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c7:	8b 40 74             	mov    0x74(%eax),%eax
  8016ca:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8016cc:	85 ff                	test   %edi,%edi
  8016ce:	74 0a                	je     8016da <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  8016d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8016d5:	8b 40 78             	mov    0x78(%eax),%eax
  8016d8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8016da:	a1 04 40 80 00       	mov    0x804004,%eax
  8016df:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8016e2:	89 d8                	mov    %ebx,%eax
  8016e4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016e7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016ea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016ed:	89 ec                	mov    %ebp,%esp
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    
	...

00801700 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	8b 45 08             	mov    0x8(%ebp),%eax
  801706:	05 00 00 00 30       	add    $0x30000000,%eax
  80170b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80170e:	5d                   	pop    %ebp
  80170f:	c3                   	ret    

00801710 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801710:	55                   	push   %ebp
  801711:	89 e5                	mov    %esp,%ebp
  801713:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801716:	8b 45 08             	mov    0x8(%ebp),%eax
  801719:	89 04 24             	mov    %eax,(%esp)
  80171c:	e8 df ff ff ff       	call   801700 <fd2num>
  801721:	05 20 00 0d 00       	add    $0xd0020,%eax
  801726:	c1 e0 0c             	shl    $0xc,%eax
}
  801729:	c9                   	leave  
  80172a:	c3                   	ret    

0080172b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	57                   	push   %edi
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801734:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801739:	a8 01                	test   $0x1,%al
  80173b:	74 36                	je     801773 <fd_alloc+0x48>
  80173d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801742:	a8 01                	test   $0x1,%al
  801744:	74 2d                	je     801773 <fd_alloc+0x48>
  801746:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80174b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801750:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801755:	89 c3                	mov    %eax,%ebx
  801757:	89 c2                	mov    %eax,%edx
  801759:	c1 ea 16             	shr    $0x16,%edx
  80175c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80175f:	f6 c2 01             	test   $0x1,%dl
  801762:	74 14                	je     801778 <fd_alloc+0x4d>
  801764:	89 c2                	mov    %eax,%edx
  801766:	c1 ea 0c             	shr    $0xc,%edx
  801769:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80176c:	f6 c2 01             	test   $0x1,%dl
  80176f:	75 10                	jne    801781 <fd_alloc+0x56>
  801771:	eb 05                	jmp    801778 <fd_alloc+0x4d>
  801773:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801778:	89 1f                	mov    %ebx,(%edi)
  80177a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80177f:	eb 17                	jmp    801798 <fd_alloc+0x6d>
  801781:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801786:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80178b:	75 c8                	jne    801755 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80178d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801793:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801798:	5b                   	pop    %ebx
  801799:	5e                   	pop    %esi
  80179a:	5f                   	pop    %edi
  80179b:	5d                   	pop    %ebp
  80179c:	c3                   	ret    

0080179d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a3:	83 f8 1f             	cmp    $0x1f,%eax
  8017a6:	77 36                	ja     8017de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017a8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8017ad:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8017b0:	89 c2                	mov    %eax,%edx
  8017b2:	c1 ea 16             	shr    $0x16,%edx
  8017b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017bc:	f6 c2 01             	test   $0x1,%dl
  8017bf:	74 1d                	je     8017de <fd_lookup+0x41>
  8017c1:	89 c2                	mov    %eax,%edx
  8017c3:	c1 ea 0c             	shr    $0xc,%edx
  8017c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017cd:	f6 c2 01             	test   $0x1,%dl
  8017d0:	74 0c                	je     8017de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d5:	89 02                	mov    %eax,(%edx)
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8017dc:	eb 05                	jmp    8017e3 <fd_lookup+0x46>
  8017de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	89 04 24             	mov    %eax,(%esp)
  8017f8:	e8 a0 ff ff ff       	call   80179d <fd_lookup>
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 0e                	js     80180f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801801:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801804:	8b 55 0c             	mov    0xc(%ebp),%edx
  801807:	89 50 04             	mov    %edx,0x4(%eax)
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	83 ec 10             	sub    $0x10,%esp
  801819:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80181c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801824:	b8 04 30 80 00       	mov    $0x803004,%eax
  801829:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80182f:	75 11                	jne    801842 <dev_lookup+0x31>
  801831:	eb 04                	jmp    801837 <dev_lookup+0x26>
  801833:	39 08                	cmp    %ecx,(%eax)
  801835:	75 10                	jne    801847 <dev_lookup+0x36>
			*dev = devtab[i];
  801837:	89 03                	mov    %eax,(%ebx)
  801839:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80183e:	66 90                	xchg   %ax,%ax
  801840:	eb 36                	jmp    801878 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801842:	be 18 2a 80 00       	mov    $0x802a18,%esi
  801847:	83 c2 01             	add    $0x1,%edx
  80184a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80184d:	85 c0                	test   %eax,%eax
  80184f:	75 e2                	jne    801833 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801851:	a1 04 40 80 00       	mov    0x804004,%eax
  801856:	8b 40 48             	mov    0x48(%eax),%eax
  801859:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80185d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801861:	c7 04 24 98 29 80 00 	movl   $0x802998,(%esp)
  801868:	e8 08 ea ff ff       	call   800275 <cprintf>
	*dev = 0;
  80186d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801873:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	53                   	push   %ebx
  801883:	83 ec 24             	sub    $0x24,%esp
  801886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801889:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801890:	8b 45 08             	mov    0x8(%ebp),%eax
  801893:	89 04 24             	mov    %eax,(%esp)
  801896:	e8 02 ff ff ff       	call   80179d <fd_lookup>
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 53                	js     8018f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a9:	8b 00                	mov    (%eax),%eax
  8018ab:	89 04 24             	mov    %eax,(%esp)
  8018ae:	e8 5e ff ff ff       	call   801811 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	78 3b                	js     8018f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8018b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018bf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8018c3:	74 2d                	je     8018f2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018cf:	00 00 00 
	stat->st_isdir = 0;
  8018d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d9:	00 00 00 
	stat->st_dev = dev;
  8018dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018ec:	89 14 24             	mov    %edx,(%esp)
  8018ef:	ff 50 14             	call   *0x14(%eax)
}
  8018f2:	83 c4 24             	add    $0x24,%esp
  8018f5:	5b                   	pop    %ebx
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	53                   	push   %ebx
  8018fc:	83 ec 24             	sub    $0x24,%esp
  8018ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801902:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801905:	89 44 24 04          	mov    %eax,0x4(%esp)
  801909:	89 1c 24             	mov    %ebx,(%esp)
  80190c:	e8 8c fe ff ff       	call   80179d <fd_lookup>
  801911:	85 c0                	test   %eax,%eax
  801913:	78 5f                	js     801974 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801915:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191f:	8b 00                	mov    (%eax),%eax
  801921:	89 04 24             	mov    %eax,(%esp)
  801924:	e8 e8 fe ff ff       	call   801811 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801929:	85 c0                	test   %eax,%eax
  80192b:	78 47                	js     801974 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80192d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801930:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801934:	75 23                	jne    801959 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801936:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80193b:	8b 40 48             	mov    0x48(%eax),%eax
  80193e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801942:	89 44 24 04          	mov    %eax,0x4(%esp)
  801946:	c7 04 24 b8 29 80 00 	movl   $0x8029b8,(%esp)
  80194d:	e8 23 e9 ff ff       	call   800275 <cprintf>
  801952:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801957:	eb 1b                	jmp    801974 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801959:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195c:	8b 48 18             	mov    0x18(%eax),%ecx
  80195f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801964:	85 c9                	test   %ecx,%ecx
  801966:	74 0c                	je     801974 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801968:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196f:	89 14 24             	mov    %edx,(%esp)
  801972:	ff d1                	call   *%ecx
}
  801974:	83 c4 24             	add    $0x24,%esp
  801977:	5b                   	pop    %ebx
  801978:	5d                   	pop    %ebp
  801979:	c3                   	ret    

0080197a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	53                   	push   %ebx
  80197e:	83 ec 24             	sub    $0x24,%esp
  801981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801984:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801987:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198b:	89 1c 24             	mov    %ebx,(%esp)
  80198e:	e8 0a fe ff ff       	call   80179d <fd_lookup>
  801993:	85 c0                	test   %eax,%eax
  801995:	78 66                	js     8019fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801997:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80199e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019a1:	8b 00                	mov    (%eax),%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 66 fe ff ff       	call   801811 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 4e                	js     8019fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019b2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8019b6:	75 23                	jne    8019db <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8019b8:	a1 04 40 80 00       	mov    0x804004,%eax
  8019bd:	8b 40 48             	mov    0x48(%eax),%eax
  8019c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c8:	c7 04 24 dc 29 80 00 	movl   $0x8029dc,(%esp)
  8019cf:	e8 a1 e8 ff ff       	call   800275 <cprintf>
  8019d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019d9:	eb 22                	jmp    8019fd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019de:	8b 48 0c             	mov    0xc(%eax),%ecx
  8019e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019e6:	85 c9                	test   %ecx,%ecx
  8019e8:	74 13                	je     8019fd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f8:	89 14 24             	mov    %edx,(%esp)
  8019fb:	ff d1                	call   *%ecx
}
  8019fd:	83 c4 24             	add    $0x24,%esp
  801a00:	5b                   	pop    %ebx
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	53                   	push   %ebx
  801a07:	83 ec 24             	sub    $0x24,%esp
  801a0a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a14:	89 1c 24             	mov    %ebx,(%esp)
  801a17:	e8 81 fd ff ff       	call   80179d <fd_lookup>
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	78 6b                	js     801a8b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a2a:	8b 00                	mov    (%eax),%eax
  801a2c:	89 04 24             	mov    %eax,(%esp)
  801a2f:	e8 dd fd ff ff       	call   801811 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a34:	85 c0                	test   %eax,%eax
  801a36:	78 53                	js     801a8b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a3b:	8b 42 08             	mov    0x8(%edx),%eax
  801a3e:	83 e0 03             	and    $0x3,%eax
  801a41:	83 f8 01             	cmp    $0x1,%eax
  801a44:	75 23                	jne    801a69 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a46:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4b:	8b 40 48             	mov    0x48(%eax),%eax
  801a4e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a52:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a56:	c7 04 24 f9 29 80 00 	movl   $0x8029f9,(%esp)
  801a5d:	e8 13 e8 ff ff       	call   800275 <cprintf>
  801a62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a67:	eb 22                	jmp    801a8b <read+0x88>
	}
	if (!dev->dev_read)
  801a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6c:	8b 48 08             	mov    0x8(%eax),%ecx
  801a6f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a74:	85 c9                	test   %ecx,%ecx
  801a76:	74 13                	je     801a8b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a78:	8b 45 10             	mov    0x10(%ebp),%eax
  801a7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a82:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a86:	89 14 24             	mov    %edx,(%esp)
  801a89:	ff d1                	call   *%ecx
}
  801a8b:	83 c4 24             	add    $0x24,%esp
  801a8e:	5b                   	pop    %ebx
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    

00801a91 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	57                   	push   %edi
  801a95:	56                   	push   %esi
  801a96:	53                   	push   %ebx
  801a97:	83 ec 1c             	sub    $0x1c,%esp
  801a9a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801aa0:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  801aaf:	85 f6                	test   %esi,%esi
  801ab1:	74 29                	je     801adc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801ab3:	89 f0                	mov    %esi,%eax
  801ab5:	29 d0                	sub    %edx,%eax
  801ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801abb:	03 55 0c             	add    0xc(%ebp),%edx
  801abe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ac2:	89 3c 24             	mov    %edi,(%esp)
  801ac5:	e8 39 ff ff ff       	call   801a03 <read>
		if (m < 0)
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 0e                	js     801adc <readn+0x4b>
			return m;
		if (m == 0)
  801ace:	85 c0                	test   %eax,%eax
  801ad0:	74 08                	je     801ada <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ad2:	01 c3                	add    %eax,%ebx
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	39 f3                	cmp    %esi,%ebx
  801ad8:	72 d9                	jb     801ab3 <readn+0x22>
  801ada:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801adc:	83 c4 1c             	add    $0x1c,%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	83 ec 28             	sub    $0x28,%esp
  801aea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801aed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801af0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801af3:	89 34 24             	mov    %esi,(%esp)
  801af6:	e8 05 fc ff ff       	call   801700 <fd2num>
  801afb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801afe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b02:	89 04 24             	mov    %eax,(%esp)
  801b05:	e8 93 fc ff ff       	call   80179d <fd_lookup>
  801b0a:	89 c3                	mov    %eax,%ebx
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 05                	js     801b15 <fd_close+0x31>
  801b10:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b13:	74 0e                	je     801b23 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	0f 44 d8             	cmove  %eax,%ebx
  801b21:	eb 3d                	jmp    801b60 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b23:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b26:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2a:	8b 06                	mov    (%esi),%eax
  801b2c:	89 04 24             	mov    %eax,(%esp)
  801b2f:	e8 dd fc ff ff       	call   801811 <dev_lookup>
  801b34:	89 c3                	mov    %eax,%ebx
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 16                	js     801b50 <fd_close+0x6c>
		if (dev->dev_close)
  801b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3d:	8b 40 10             	mov    0x10(%eax),%eax
  801b40:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b45:	85 c0                	test   %eax,%eax
  801b47:	74 07                	je     801b50 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801b49:	89 34 24             	mov    %esi,(%esp)
  801b4c:	ff d0                	call   *%eax
  801b4e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b50:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5b:	e8 d9 f3 ff ff       	call   800f39 <sys_page_unmap>
	return r;
}
  801b60:	89 d8                	mov    %ebx,%eax
  801b62:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b65:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b68:	89 ec                	mov    %ebp,%esp
  801b6a:	5d                   	pop    %ebp
  801b6b:	c3                   	ret    

00801b6c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b75:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 19 fc ff ff       	call   80179d <fd_lookup>
  801b84:	85 c0                	test   %eax,%eax
  801b86:	78 13                	js     801b9b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b88:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b8f:	00 
  801b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b93:	89 04 24             	mov    %eax,(%esp)
  801b96:	e8 49 ff ff ff       	call   801ae4 <fd_close>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 18             	sub    $0x18,%esp
  801ba3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ba6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801ba9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bb0:	00 
  801bb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 78 03 00 00       	call   801f34 <open>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 1b                	js     801bdd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801bc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc9:	89 1c 24             	mov    %ebx,(%esp)
  801bcc:	e8 ae fc ff ff       	call   80187f <fstat>
  801bd1:	89 c6                	mov    %eax,%esi
	close(fd);
  801bd3:	89 1c 24             	mov    %ebx,(%esp)
  801bd6:	e8 91 ff ff ff       	call   801b6c <close>
  801bdb:	89 f3                	mov    %esi,%ebx
	return r;
}
  801bdd:	89 d8                	mov    %ebx,%eax
  801bdf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801be2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801be5:	89 ec                	mov    %ebp,%esp
  801be7:	5d                   	pop    %ebp
  801be8:	c3                   	ret    

00801be9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	53                   	push   %ebx
  801bed:	83 ec 14             	sub    $0x14,%esp
  801bf0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801bf5:	89 1c 24             	mov    %ebx,(%esp)
  801bf8:	e8 6f ff ff ff       	call   801b6c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bfd:	83 c3 01             	add    $0x1,%ebx
  801c00:	83 fb 20             	cmp    $0x20,%ebx
  801c03:	75 f0                	jne    801bf5 <close_all+0xc>
		close(i);
}
  801c05:	83 c4 14             	add    $0x14,%esp
  801c08:	5b                   	pop    %ebx
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	83 ec 58             	sub    $0x58,%esp
  801c11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c17:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c1a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c1d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c20:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	89 04 24             	mov    %eax,(%esp)
  801c2a:	e8 6e fb ff ff       	call   80179d <fd_lookup>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	85 c0                	test   %eax,%eax
  801c33:	0f 88 e0 00 00 00    	js     801d19 <dup+0x10e>
		return r;
	close(newfdnum);
  801c39:	89 3c 24             	mov    %edi,(%esp)
  801c3c:	e8 2b ff ff ff       	call   801b6c <close>

	newfd = INDEX2FD(newfdnum);
  801c41:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c47:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c4d:	89 04 24             	mov    %eax,(%esp)
  801c50:	e8 bb fa ff ff       	call   801710 <fd2data>
  801c55:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c57:	89 34 24             	mov    %esi,(%esp)
  801c5a:	e8 b1 fa ff ff       	call   801710 <fd2data>
  801c5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801c62:	89 da                	mov    %ebx,%edx
  801c64:	89 d8                	mov    %ebx,%eax
  801c66:	c1 e8 16             	shr    $0x16,%eax
  801c69:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c70:	a8 01                	test   $0x1,%al
  801c72:	74 43                	je     801cb7 <dup+0xac>
  801c74:	c1 ea 0c             	shr    $0xc,%edx
  801c77:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c7e:	a8 01                	test   $0x1,%al
  801c80:	74 35                	je     801cb7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c82:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c89:	25 07 0e 00 00       	and    $0xe07,%eax
  801c8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ca0:	00 
  801ca1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cac:	e8 c0 f2 ff ff       	call   800f71 <sys_page_map>
  801cb1:	89 c3                	mov    %eax,%ebx
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 3f                	js     801cf6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801cb7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cba:	89 c2                	mov    %eax,%edx
  801cbc:	c1 ea 0c             	shr    $0xc,%edx
  801cbf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801cc6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801ccc:	89 54 24 10          	mov    %edx,0x10(%esp)
  801cd0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cd4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cdb:	00 
  801cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce7:	e8 85 f2 ff ff       	call   800f71 <sys_page_map>
  801cec:	89 c3                	mov    %eax,%ebx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	78 04                	js     801cf6 <dup+0xeb>
  801cf2:	89 fb                	mov    %edi,%ebx
  801cf4:	eb 23                	jmp    801d19 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d01:	e8 33 f2 ff ff       	call   800f39 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d14:	e8 20 f2 ff ff       	call   800f39 <sys_page_unmap>
	return r;
}
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d24:	89 ec                	mov    %ebp,%esp
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    

00801d28 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d28:	55                   	push   %ebp
  801d29:	89 e5                	mov    %esp,%ebp
  801d2b:	83 ec 18             	sub    $0x18,%esp
  801d2e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d31:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d34:	89 c3                	mov    %eax,%ebx
  801d36:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d38:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801d3f:	75 11                	jne    801d52 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d41:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d48:	e8 63 f8 ff ff       	call   8015b0 <ipc_find_env>
  801d4d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d52:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d59:	00 
  801d5a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d61:	00 
  801d62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d66:	a1 00 40 80 00       	mov    0x804000,%eax
  801d6b:	89 04 24             	mov    %eax,(%esp)
  801d6e:	e8 81 f8 ff ff       	call   8015f4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d7a:	00 
  801d7b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d86:	e8 d8 f8 ff ff       	call   801663 <ipc_recv>
}
  801d8b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d8e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d91:	89 ec                	mov    %ebp,%esp
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801da1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801da6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801dae:	ba 00 00 00 00       	mov    $0x0,%edx
  801db3:	b8 02 00 00 00       	mov    $0x2,%eax
  801db8:	e8 6b ff ff ff       	call   801d28 <fsipc>
}
  801dbd:	c9                   	leave  
  801dbe:	c3                   	ret    

00801dbf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	8b 40 0c             	mov    0xc(%eax),%eax
  801dcb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801dd0:	ba 00 00 00 00       	mov    $0x0,%edx
  801dd5:	b8 06 00 00 00       	mov    $0x6,%eax
  801dda:	e8 49 ff ff ff       	call   801d28 <fsipc>
}
  801ddf:	c9                   	leave  
  801de0:	c3                   	ret    

00801de1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801de7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dec:	b8 08 00 00 00       	mov    $0x8,%eax
  801df1:	e8 32 ff ff ff       	call   801d28 <fsipc>
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	53                   	push   %ebx
  801dfc:	83 ec 14             	sub    $0x14,%esp
  801dff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e02:	8b 45 08             	mov    0x8(%ebp),%eax
  801e05:	8b 40 0c             	mov    0xc(%eax),%eax
  801e08:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e0d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e12:	b8 05 00 00 00       	mov    $0x5,%eax
  801e17:	e8 0c ff ff ff       	call   801d28 <fsipc>
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	78 2b                	js     801e4b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e20:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e27:	00 
  801e28:	89 1c 24             	mov    %ebx,(%esp)
  801e2b:	e8 8a eb ff ff       	call   8009ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e30:	a1 80 50 80 00       	mov    0x805080,%eax
  801e35:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e3b:	a1 84 50 80 00       	mov    0x805084,%eax
  801e40:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e46:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e4b:	83 c4 14             	add    $0x14,%esp
  801e4e:	5b                   	pop    %ebx
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 18             	sub    $0x18,%esp
  801e57:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e5d:	8b 52 0c             	mov    0xc(%edx),%edx
  801e60:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801e66:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801e6b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e70:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e75:	0f 47 c2             	cmova  %edx,%eax
  801e78:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e83:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801e8a:	e8 16 ed ff ff       	call   800ba5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801e8f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e94:	b8 04 00 00 00       	mov    $0x4,%eax
  801e99:	e8 8a fe ff ff       	call   801d28 <fsipc>
}
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	53                   	push   %ebx
  801ea4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eaa:	8b 40 0c             	mov    0xc(%eax),%eax
  801ead:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801eb2:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801eba:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ec4:	e8 5f fe ff ff       	call   801d28 <fsipc>
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	85 c0                	test   %eax,%eax
  801ecd:	78 17                	js     801ee6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ecf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ed3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801eda:	00 
  801edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ede:	89 04 24             	mov    %eax,(%esp)
  801ee1:	e8 bf ec ff ff       	call   800ba5 <memmove>
  return r;	
}
  801ee6:	89 d8                	mov    %ebx,%eax
  801ee8:	83 c4 14             	add    $0x14,%esp
  801eeb:	5b                   	pop    %ebx
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	53                   	push   %ebx
  801ef2:	83 ec 14             	sub    $0x14,%esp
  801ef5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801ef8:	89 1c 24             	mov    %ebx,(%esp)
  801efb:	e8 70 ea ff ff       	call   800970 <strlen>
  801f00:	89 c2                	mov    %eax,%edx
  801f02:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801f07:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801f0d:	7f 1f                	jg     801f2e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f13:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f1a:	e8 9b ea ff ff       	call   8009ba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f24:	b8 07 00 00 00       	mov    $0x7,%eax
  801f29:	e8 fa fd ff ff       	call   801d28 <fsipc>
}
  801f2e:	83 c4 14             	add    $0x14,%esp
  801f31:	5b                   	pop    %ebx
  801f32:	5d                   	pop    %ebp
  801f33:	c3                   	ret    

00801f34 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f34:	55                   	push   %ebp
  801f35:	89 e5                	mov    %esp,%ebp
  801f37:	83 ec 28             	sub    $0x28,%esp
  801f3a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f3d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f40:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801f43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f46:	89 04 24             	mov    %eax,(%esp)
  801f49:	e8 dd f7 ff ff       	call   80172b <fd_alloc>
  801f4e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801f50:	85 c0                	test   %eax,%eax
  801f52:	0f 88 89 00 00 00    	js     801fe1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801f58:	89 34 24             	mov    %esi,(%esp)
  801f5b:	e8 10 ea ff ff       	call   800970 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801f60:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801f65:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f6a:	7f 75                	jg     801fe1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801f6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f70:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f77:	e8 3e ea ff ff       	call   8009ba <strcpy>
  fsipcbuf.open.req_omode = mode;
  801f7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f7f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f87:	b8 01 00 00 00       	mov    $0x1,%eax
  801f8c:	e8 97 fd ff ff       	call   801d28 <fsipc>
  801f91:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801f93:	85 c0                	test   %eax,%eax
  801f95:	78 0f                	js     801fa6 <open+0x72>
  return fd2num(fd);
  801f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9a:	89 04 24             	mov    %eax,(%esp)
  801f9d:	e8 5e f7 ff ff       	call   801700 <fd2num>
  801fa2:	89 c3                	mov    %eax,%ebx
  801fa4:	eb 3b                	jmp    801fe1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801fa6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fad:	00 
  801fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb1:	89 04 24             	mov    %eax,(%esp)
  801fb4:	e8 2b fb ff ff       	call   801ae4 <fd_close>
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	74 24                	je     801fe1 <open+0xad>
  801fbd:	c7 44 24 0c 20 2a 80 	movl   $0x802a20,0xc(%esp)
  801fc4:	00 
  801fc5:	c7 44 24 08 35 2a 80 	movl   $0x802a35,0x8(%esp)
  801fcc:	00 
  801fcd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801fd4:	00 
  801fd5:	c7 04 24 4a 2a 80 00 	movl   $0x802a4a,(%esp)
  801fdc:	e8 db e1 ff ff       	call   8001bc <_panic>
  return r;
}
  801fe1:	89 d8                	mov    %ebx,%eax
  801fe3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fe6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fe9:	89 ec                	mov    %ebp,%esp
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    
  801fed:	00 00                	add    %al,(%eax)
	...

00801ff0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ff6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801ffd:	75 54                	jne    802053 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801fff:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802006:	00 
  802007:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80200e:	ee 
  80200f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802016:	e8 8f ef ff ff       	call   800faa <sys_page_alloc>
  80201b:	85 c0                	test   %eax,%eax
  80201d:	79 20                	jns    80203f <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80201f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802023:	c7 44 24 08 55 2a 80 	movl   $0x802a55,0x8(%esp)
  80202a:	00 
  80202b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802032:	00 
  802033:	c7 04 24 6d 2a 80 00 	movl   $0x802a6d,(%esp)
  80203a:	e8 7d e1 ff ff       	call   8001bc <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80203f:	c7 44 24 04 60 20 80 	movl   $0x802060,0x4(%esp)
  802046:	00 
  802047:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80204e:	e8 3e ee ff ff       	call   800e91 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802053:	8b 45 08             	mov    0x8(%ebp),%eax
  802056:	a3 00 60 80 00       	mov    %eax,0x806000
}
  80205b:	c9                   	leave  
  80205c:	c3                   	ret    
  80205d:	00 00                	add    %al,(%eax)
	...

00802060 <_pgfault_upcall>:
  802060:	54                   	push   %esp
  802061:	a1 00 60 80 00       	mov    0x806000,%eax
  802066:	ff d0                	call   *%eax
  802068:	83 c4 04             	add    $0x4,%esp
  80206b:	8b 44 24 30          	mov    0x30(%esp),%eax
  80206f:	83 e8 04             	sub    $0x4,%eax
  802072:	89 44 24 30          	mov    %eax,0x30(%esp)
  802076:	8b 5c 24 28          	mov    0x28(%esp),%ebx
  80207a:	89 18                	mov    %ebx,(%eax)
  80207c:	83 c4 08             	add    $0x8,%esp
  80207f:	61                   	popa   
  802080:	83 c4 04             	add    $0x4,%esp
  802083:	9d                   	popf   
  802084:	5c                   	pop    %esp
  802085:	c3                   	ret    
	...

00802090 <__udivdi3>:
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	57                   	push   %edi
  802094:	56                   	push   %esi
  802095:	83 ec 10             	sub    $0x10,%esp
  802098:	8b 45 14             	mov    0x14(%ebp),%eax
  80209b:	8b 55 08             	mov    0x8(%ebp),%edx
  80209e:	8b 75 10             	mov    0x10(%ebp),%esi
  8020a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020a4:	85 c0                	test   %eax,%eax
  8020a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8020a9:	75 35                	jne    8020e0 <__udivdi3+0x50>
  8020ab:	39 fe                	cmp    %edi,%esi
  8020ad:	77 61                	ja     802110 <__udivdi3+0x80>
  8020af:	85 f6                	test   %esi,%esi
  8020b1:	75 0b                	jne    8020be <__udivdi3+0x2e>
  8020b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020b8:	31 d2                	xor    %edx,%edx
  8020ba:	f7 f6                	div    %esi
  8020bc:	89 c6                	mov    %eax,%esi
  8020be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8020c1:	31 d2                	xor    %edx,%edx
  8020c3:	89 f8                	mov    %edi,%eax
  8020c5:	f7 f6                	div    %esi
  8020c7:	89 c7                	mov    %eax,%edi
  8020c9:	89 c8                	mov    %ecx,%eax
  8020cb:	f7 f6                	div    %esi
  8020cd:	89 c1                	mov    %eax,%ecx
  8020cf:	89 fa                	mov    %edi,%edx
  8020d1:	89 c8                	mov    %ecx,%eax
  8020d3:	83 c4 10             	add    $0x10,%esp
  8020d6:	5e                   	pop    %esi
  8020d7:	5f                   	pop    %edi
  8020d8:	5d                   	pop    %ebp
  8020d9:	c3                   	ret    
  8020da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e0:	39 f8                	cmp    %edi,%eax
  8020e2:	77 1c                	ja     802100 <__udivdi3+0x70>
  8020e4:	0f bd d0             	bsr    %eax,%edx
  8020e7:	83 f2 1f             	xor    $0x1f,%edx
  8020ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020ed:	75 39                	jne    802128 <__udivdi3+0x98>
  8020ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020f2:	0f 86 a0 00 00 00    	jbe    802198 <__udivdi3+0x108>
  8020f8:	39 f8                	cmp    %edi,%eax
  8020fa:	0f 82 98 00 00 00    	jb     802198 <__udivdi3+0x108>
  802100:	31 ff                	xor    %edi,%edi
  802102:	31 c9                	xor    %ecx,%ecx
  802104:	89 c8                	mov    %ecx,%eax
  802106:	89 fa                	mov    %edi,%edx
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	5e                   	pop    %esi
  80210c:	5f                   	pop    %edi
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    
  80210f:	90                   	nop
  802110:	89 d1                	mov    %edx,%ecx
  802112:	89 fa                	mov    %edi,%edx
  802114:	89 c8                	mov    %ecx,%eax
  802116:	31 ff                	xor    %edi,%edi
  802118:	f7 f6                	div    %esi
  80211a:	89 c1                	mov    %eax,%ecx
  80211c:	89 fa                	mov    %edi,%edx
  80211e:	89 c8                	mov    %ecx,%eax
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	5e                   	pop    %esi
  802124:	5f                   	pop    %edi
  802125:	5d                   	pop    %ebp
  802126:	c3                   	ret    
  802127:	90                   	nop
  802128:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80212c:	89 f2                	mov    %esi,%edx
  80212e:	d3 e0                	shl    %cl,%eax
  802130:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802133:	b8 20 00 00 00       	mov    $0x20,%eax
  802138:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80213b:	89 c1                	mov    %eax,%ecx
  80213d:	d3 ea                	shr    %cl,%edx
  80213f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802143:	0b 55 ec             	or     -0x14(%ebp),%edx
  802146:	d3 e6                	shl    %cl,%esi
  802148:	89 c1                	mov    %eax,%ecx
  80214a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80214d:	89 fe                	mov    %edi,%esi
  80214f:	d3 ee                	shr    %cl,%esi
  802151:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802155:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802158:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80215b:	d3 e7                	shl    %cl,%edi
  80215d:	89 c1                	mov    %eax,%ecx
  80215f:	d3 ea                	shr    %cl,%edx
  802161:	09 d7                	or     %edx,%edi
  802163:	89 f2                	mov    %esi,%edx
  802165:	89 f8                	mov    %edi,%eax
  802167:	f7 75 ec             	divl   -0x14(%ebp)
  80216a:	89 d6                	mov    %edx,%esi
  80216c:	89 c7                	mov    %eax,%edi
  80216e:	f7 65 e8             	mull   -0x18(%ebp)
  802171:	39 d6                	cmp    %edx,%esi
  802173:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802176:	72 30                	jb     8021a8 <__udivdi3+0x118>
  802178:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80217b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80217f:	d3 e2                	shl    %cl,%edx
  802181:	39 c2                	cmp    %eax,%edx
  802183:	73 05                	jae    80218a <__udivdi3+0xfa>
  802185:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802188:	74 1e                	je     8021a8 <__udivdi3+0x118>
  80218a:	89 f9                	mov    %edi,%ecx
  80218c:	31 ff                	xor    %edi,%edi
  80218e:	e9 71 ff ff ff       	jmp    802104 <__udivdi3+0x74>
  802193:	90                   	nop
  802194:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802198:	31 ff                	xor    %edi,%edi
  80219a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80219f:	e9 60 ff ff ff       	jmp    802104 <__udivdi3+0x74>
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8021ab:	31 ff                	xor    %edi,%edi
  8021ad:	89 c8                	mov    %ecx,%eax
  8021af:	89 fa                	mov    %edi,%edx
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
	...

008021c0 <__umoddi3>:
  8021c0:	55                   	push   %ebp
  8021c1:	89 e5                	mov    %esp,%ebp
  8021c3:	57                   	push   %edi
  8021c4:	56                   	push   %esi
  8021c5:	83 ec 20             	sub    $0x20,%esp
  8021c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021d4:	85 d2                	test   %edx,%edx
  8021d6:	89 c8                	mov    %ecx,%eax
  8021d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021db:	75 13                	jne    8021f0 <__umoddi3+0x30>
  8021dd:	39 f7                	cmp    %esi,%edi
  8021df:	76 3f                	jbe    802220 <__umoddi3+0x60>
  8021e1:	89 f2                	mov    %esi,%edx
  8021e3:	f7 f7                	div    %edi
  8021e5:	89 d0                	mov    %edx,%eax
  8021e7:	31 d2                	xor    %edx,%edx
  8021e9:	83 c4 20             	add    $0x20,%esp
  8021ec:	5e                   	pop    %esi
  8021ed:	5f                   	pop    %edi
  8021ee:	5d                   	pop    %ebp
  8021ef:	c3                   	ret    
  8021f0:	39 f2                	cmp    %esi,%edx
  8021f2:	77 4c                	ja     802240 <__umoddi3+0x80>
  8021f4:	0f bd ca             	bsr    %edx,%ecx
  8021f7:	83 f1 1f             	xor    $0x1f,%ecx
  8021fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021fd:	75 51                	jne    802250 <__umoddi3+0x90>
  8021ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802202:	0f 87 e0 00 00 00    	ja     8022e8 <__umoddi3+0x128>
  802208:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220b:	29 f8                	sub    %edi,%eax
  80220d:	19 d6                	sbb    %edx,%esi
  80220f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802212:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802215:	89 f2                	mov    %esi,%edx
  802217:	83 c4 20             	add    $0x20,%esp
  80221a:	5e                   	pop    %esi
  80221b:	5f                   	pop    %edi
  80221c:	5d                   	pop    %ebp
  80221d:	c3                   	ret    
  80221e:	66 90                	xchg   %ax,%ax
  802220:	85 ff                	test   %edi,%edi
  802222:	75 0b                	jne    80222f <__umoddi3+0x6f>
  802224:	b8 01 00 00 00       	mov    $0x1,%eax
  802229:	31 d2                	xor    %edx,%edx
  80222b:	f7 f7                	div    %edi
  80222d:	89 c7                	mov    %eax,%edi
  80222f:	89 f0                	mov    %esi,%eax
  802231:	31 d2                	xor    %edx,%edx
  802233:	f7 f7                	div    %edi
  802235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802238:	f7 f7                	div    %edi
  80223a:	eb a9                	jmp    8021e5 <__umoddi3+0x25>
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	83 c4 20             	add    $0x20,%esp
  802247:	5e                   	pop    %esi
  802248:	5f                   	pop    %edi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    
  80224b:	90                   	nop
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802254:	d3 e2                	shl    %cl,%edx
  802256:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802259:	ba 20 00 00 00       	mov    $0x20,%edx
  80225e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802261:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802264:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802268:	89 fa                	mov    %edi,%edx
  80226a:	d3 ea                	shr    %cl,%edx
  80226c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802270:	0b 55 f4             	or     -0xc(%ebp),%edx
  802273:	d3 e7                	shl    %cl,%edi
  802275:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802279:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80227c:	89 f2                	mov    %esi,%edx
  80227e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802281:	89 c7                	mov    %eax,%edi
  802283:	d3 ea                	shr    %cl,%edx
  802285:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802289:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80228c:	89 c2                	mov    %eax,%edx
  80228e:	d3 e6                	shl    %cl,%esi
  802290:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802294:	d3 ea                	shr    %cl,%edx
  802296:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80229a:	09 d6                	or     %edx,%esi
  80229c:	89 f0                	mov    %esi,%eax
  80229e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8022a1:	d3 e7                	shl    %cl,%edi
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	f7 75 f4             	divl   -0xc(%ebp)
  8022a8:	89 d6                	mov    %edx,%esi
  8022aa:	f7 65 e8             	mull   -0x18(%ebp)
  8022ad:	39 d6                	cmp    %edx,%esi
  8022af:	72 2b                	jb     8022dc <__umoddi3+0x11c>
  8022b1:	39 c7                	cmp    %eax,%edi
  8022b3:	72 23                	jb     8022d8 <__umoddi3+0x118>
  8022b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022b9:	29 c7                	sub    %eax,%edi
  8022bb:	19 d6                	sbb    %edx,%esi
  8022bd:	89 f0                	mov    %esi,%eax
  8022bf:	89 f2                	mov    %esi,%edx
  8022c1:	d3 ef                	shr    %cl,%edi
  8022c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022c7:	d3 e0                	shl    %cl,%eax
  8022c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022cd:	09 f8                	or     %edi,%eax
  8022cf:	d3 ea                	shr    %cl,%edx
  8022d1:	83 c4 20             	add    $0x20,%esp
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
  8022d8:	39 d6                	cmp    %edx,%esi
  8022da:	75 d9                	jne    8022b5 <__umoddi3+0xf5>
  8022dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022e2:	eb d1                	jmp    8022b5 <__umoddi3+0xf5>
  8022e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	0f 82 18 ff ff ff    	jb     802208 <__umoddi3+0x48>
  8022f0:	e9 1d ff ff ff       	jmp    802212 <__umoddi3+0x52>
