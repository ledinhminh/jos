
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
  800053:	e8 57 16 00 00       	call   8016af <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 08 50 80 00       	mov    0x805008,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800071:	e8 ff 01 00 00       	call   800275 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 57 11 00 00       	call   8011d2 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 93 2c 80 	movl   $0x802c93,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
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
  8000bb:	e8 ef 15 00 00       	call   8016af <ipc_recv>
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
  8000e4:	e8 5b 15 00 00       	call   801644 <ipc_send>
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
  8000f3:	e8 da 10 00 00       	call   8011d2 <fork>
  8000f8:	89 c6                	mov    %eax,%esi
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	79 20                	jns    80011e <umain+0x33>
		panic("fork: %e", id);
  8000fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800102:	c7 44 24 08 93 2c 80 	movl   $0x802c93,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 8c 28 80 00 	movl   $0x80288c,(%esp)
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
  800143:	e8 fc 14 00 00       	call   801644 <ipc_send>
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
  800162:	e8 60 0f 00 00       	call   8010c7 <sys_getenvid>
  800167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80016c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800174:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800179:	85 f6                	test   %esi,%esi
  80017b:	7e 07                	jle    800184 <libmain+0x34>
		binaryname = argv[0];
  80017d:	8b 03                	mov    (%ebx),%eax
  80017f:	a3 00 40 80 00       	mov    %eax,0x804000

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
  8001a6:	e8 7e 1a 00 00       	call   801c29 <close_all>
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 4b 0f 00 00       	call   801102 <sys_env_destroy>
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
  8001c7:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001cd:	e8 f5 0e 00 00       	call   8010c7 <sys_getenvid>
  8001d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e8:	c7 04 24 a4 28 80 00 	movl   $0x8028a4,(%esp)
  8001ef:	e8 81 00 00 00       	call   800275 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 11 00 00 00       	call   800214 <vcprintf>
	cprintf("\n");
  800203:	c7 04 24 5f 2f 80 00 	movl   $0x802f5f,(%esp)
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
  800268:	e8 09 0f 00 00       	call   801176 <sys_cputs>

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
  8002bc:	e8 b5 0e 00 00       	call   801176 <sys_cputs>
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
  80035d:	e8 ae 22 00 00       	call   802610 <__udivdi3>
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
  8003b8:	e8 83 23 00 00       	call   802740 <__umoddi3>
  8003bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c1:	0f be 80 c7 28 80 00 	movsbl 0x8028c7(%eax),%eax
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
  8004a5:	ff 24 95 a0 2a 80 00 	jmp    *0x802aa0(,%edx,4)
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
  800578:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	75 20                	jne    8005a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800583:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800587:	c7 44 24 08 d8 28 80 	movl   $0x8028d8,0x8(%esp)
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
  8005a7:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
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
  8005e1:	b8 e1 28 80 00       	mov    $0x8028e1,%eax
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
  800825:	c7 44 24 0c fc 29 80 	movl   $0x8029fc,0xc(%esp)
  80082c:	00 
  80082d:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
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
  800853:	c7 44 24 0c 34 2a 80 	movl   $0x802a34,0xc(%esp)
  80085a:	00 
  80085b:	c7 44 24 08 97 2f 80 	movl   $0x802f97,0x8(%esp)
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
  800df7:	c7 44 24 08 40 2c 80 	movl   $0x802c40,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
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

008011b0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8011b6:	c7 44 24 08 6b 2c 80 	movl   $0x802c6b,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8011cd:	e8 ea ef ff ff       	call   8001bc <_panic>

008011d2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	57                   	push   %edi
  8011d6:	56                   	push   %esi
  8011d7:	53                   	push   %ebx
  8011d8:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  8011db:	c7 04 24 96 14 80 00 	movl   $0x801496,(%esp)
  8011e2:	e8 4d 13 00 00       	call   802534 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  8011e7:	ba 08 00 00 00       	mov    $0x8,%edx
  8011ec:	89 d0                	mov    %edx,%eax
  8011ee:	51                   	push   %ecx
  8011ef:	52                   	push   %edx
  8011f0:	53                   	push   %ebx
  8011f1:	55                   	push   %ebp
  8011f2:	56                   	push   %esi
  8011f3:	57                   	push   %edi
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8d 35 fe 11 80 00    	lea    0x8011fe,%esi
  8011fc:	0f 34                	sysenter 

008011fe <.after_sysenter_label>:
  8011fe:	5f                   	pop    %edi
  8011ff:	5e                   	pop    %esi
  801200:	5d                   	pop    %ebp
  801201:	5b                   	pop    %ebx
  801202:	5a                   	pop    %edx
  801203:	59                   	pop    %ecx
  801204:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80120b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  801212:	00 
  801213:	c7 44 24 04 81 2c 80 	movl   $0x802c81,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 c8 2c 80 00 	movl   $0x802cc8,(%esp)
  801222:	e8 4e f0 ff ff       	call   800275 <cprintf>
	if (envidnum < 0)
  801227:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80122b:	79 23                	jns    801250 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80122d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801230:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801234:	c7 44 24 08 8c 2c 80 	movl   $0x802c8c,0x8(%esp)
  80123b:	00 
  80123c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801243:	00 
  801244:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80124b:	e8 6c ef ff ff       	call   8001bc <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801250:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801255:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80125a:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80125f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801263:	75 1c                	jne    801281 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801265:	e8 5d fe ff ff       	call   8010c7 <sys_getenvid>
  80126a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80126f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801272:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801277:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80127c:	e9 0a 02 00 00       	jmp    80148b <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801281:	89 d8                	mov    %ebx,%eax
  801283:	c1 e8 16             	shr    $0x16,%eax
  801286:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801289:	a8 01                	test   $0x1,%al
  80128b:	0f 84 43 01 00 00    	je     8013d4 <.after_sysenter_label+0x1d6>
  801291:	89 d8                	mov    %ebx,%eax
  801293:	c1 e8 0c             	shr    $0xc,%eax
  801296:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801299:	f6 c2 01             	test   $0x1,%dl
  80129c:	0f 84 32 01 00 00    	je     8013d4 <.after_sysenter_label+0x1d6>
  8012a2:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8012a5:	f6 c2 04             	test   $0x4,%dl
  8012a8:	0f 84 26 01 00 00    	je     8013d4 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  8012ae:	c1 e0 0c             	shl    $0xc,%eax
  8012b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  8012b4:	c1 e8 0c             	shr    $0xc,%eax
  8012b7:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  8012c2:	a9 02 08 00 00       	test   $0x802,%eax
  8012c7:	0f 84 a0 00 00 00    	je     80136d <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  8012cd:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  8012d0:	80 ce 08             	or     $0x8,%dh
  8012d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8012d6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012f6:	e8 e9 fc ff ff       	call   800fe4 <sys_page_map>
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	79 20                	jns    80131f <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  8012ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801303:	c7 44 24 08 f0 2c 80 	movl   $0x802cf0,0x8(%esp)
  80130a:	00 
  80130b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801312:	00 
  801313:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80131a:	e8 9d ee ff ff       	call   8001bc <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80131f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801322:	89 44 24 10          	mov    %eax,0x10(%esp)
  801326:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801329:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80132d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801334:	00 
  801335:	89 44 24 04          	mov    %eax,0x4(%esp)
  801339:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801340:	e8 9f fc ff ff       	call   800fe4 <sys_page_map>
  801345:	85 c0                	test   %eax,%eax
  801347:	0f 89 87 00 00 00    	jns    8013d4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  80134d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801351:	c7 44 24 08 1c 2d 80 	movl   $0x802d1c,0x8(%esp)
  801358:	00 
  801359:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801360:	00 
  801361:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801368:	e8 4f ee ff ff       	call   8001bc <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  80136d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801370:	89 44 24 08          	mov    %eax,0x8(%esp)
  801374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	c7 04 24 9c 2c 80 00 	movl   $0x802c9c,(%esp)
  801382:	e8 ee ee ff ff       	call   800275 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801387:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80138e:	00 
  80138f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801392:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801399:	89 44 24 08          	mov    %eax,0x8(%esp)
  80139d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8013a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013ab:	e8 34 fc ff ff       	call   800fe4 <sys_page_map>
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	79 20                	jns    8013d4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  8013b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013b8:	c7 44 24 08 48 2d 80 	movl   $0x802d48,0x8(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8013c7:	00 
  8013c8:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8013cf:	e8 e8 ed ff ff       	call   8001bc <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  8013d4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013da:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8013e0:	0f 85 9b fe ff ff    	jne    801281 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8013e6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013ed:	00 
  8013ee:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013f5:	ee 
  8013f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013f9:	89 04 24             	mov    %eax,(%esp)
  8013fc:	e8 1c fc ff ff       	call   80101d <sys_page_alloc>
  801401:	85 c0                	test   %eax,%eax
  801403:	79 20                	jns    801425 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801405:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801409:	c7 44 24 08 74 2d 80 	movl   $0x802d74,0x8(%esp)
  801410:	00 
  801411:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801418:	00 
  801419:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  801420:	e8 97 ed ff ff       	call   8001bc <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801425:	c7 44 24 04 a4 25 80 	movl   $0x8025a4,0x4(%esp)
  80142c:	00 
  80142d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801430:	89 04 24             	mov    %eax,(%esp)
  801433:	e8 cc fa ff ff       	call   800f04 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801438:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80143f:	00 
  801440:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801443:	89 04 24             	mov    %eax,(%esp)
  801446:	e8 29 fb ff ff       	call   800f74 <sys_env_set_status>
  80144b:	85 c0                	test   %eax,%eax
  80144d:	79 20                	jns    80146f <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80144f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801453:	c7 44 24 08 98 2d 80 	movl   $0x802d98,0x8(%esp)
  80145a:	00 
  80145b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  801462:	00 
  801463:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80146a:	e8 4d ed ff ff       	call   8001bc <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80146f:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801476:	00 
  801477:	c7 44 24 04 81 2c 80 	movl   $0x802c81,0x4(%esp)
  80147e:	00 
  80147f:	c7 04 24 ae 2c 80 00 	movl   $0x802cae,(%esp)
  801486:	e8 ea ed ff ff       	call   800275 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  80148b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80148e:	83 c4 3c             	add    $0x3c,%esp
  801491:	5b                   	pop    %ebx
  801492:	5e                   	pop    %esi
  801493:	5f                   	pop    %edi
  801494:	5d                   	pop    %ebp
  801495:	c3                   	ret    

00801496 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801496:	55                   	push   %ebp
  801497:	89 e5                	mov    %esp,%ebp
  801499:	53                   	push   %ebx
  80149a:	83 ec 24             	sub    $0x24,%esp
  80149d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8014a0:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8014a2:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  8014a5:	f6 c2 02             	test   $0x2,%dl
  8014a8:	75 2b                	jne    8014d5 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  8014aa:	8b 40 28             	mov    0x28(%eax),%eax
  8014ad:	89 44 24 14          	mov    %eax,0x14(%esp)
  8014b1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8014b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014b9:	c7 44 24 08 c0 2d 80 	movl   $0x802dc0,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8014d0:	e8 e7 ec ff ff       	call   8001bc <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  8014d5:	89 d8                	mov    %ebx,%eax
  8014d7:	c1 e8 16             	shr    $0x16,%eax
  8014da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014e1:	a8 01                	test   $0x1,%al
  8014e3:	74 11                	je     8014f6 <pgfault+0x60>
  8014e5:	89 d8                	mov    %ebx,%eax
  8014e7:	c1 e8 0c             	shr    $0xc,%eax
  8014ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f1:	f6 c4 08             	test   $0x8,%ah
  8014f4:	75 1c                	jne    801512 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  8014f6:	c7 44 24 08 fc 2d 80 	movl   $0x802dfc,0x8(%esp)
  8014fd:	00 
  8014fe:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801505:	00 
  801506:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80150d:	e8 aa ec ff ff       	call   8001bc <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801512:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801519:	00 
  80151a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801521:	00 
  801522:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801529:	e8 ef fa ff ff       	call   80101d <sys_page_alloc>
  80152e:	85 c0                	test   %eax,%eax
  801530:	79 20                	jns    801552 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  801532:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801536:	c7 44 24 08 38 2e 80 	movl   $0x802e38,0x8(%esp)
  80153d:	00 
  80153e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801545:	00 
  801546:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  80154d:	e8 6a ec ff ff       	call   8001bc <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801552:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  801558:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80155f:	00 
  801560:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801564:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80156b:	e8 35 f6 ff ff       	call   800ba5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801570:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801577:	00 
  801578:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80157c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801583:	00 
  801584:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80158b:	00 
  80158c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801593:	e8 4c fa ff ff       	call   800fe4 <sys_page_map>
  801598:	85 c0                	test   %eax,%eax
  80159a:	79 20                	jns    8015bc <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  80159c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a0:	c7 44 24 08 60 2e 80 	movl   $0x802e60,0x8(%esp)
  8015a7:	00 
  8015a8:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8015af:	00 
  8015b0:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8015b7:	e8 00 ec ff ff       	call   8001bc <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  8015bc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8015c3:	00 
  8015c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015cb:	e8 dc f9 ff ff       	call   800fac <sys_page_unmap>
  8015d0:	85 c0                	test   %eax,%eax
  8015d2:	79 20                	jns    8015f4 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  8015d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015d8:	c7 44 24 08 84 2e 80 	movl   $0x802e84,0x8(%esp)
  8015df:	00 
  8015e0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8015e7:	00 
  8015e8:	c7 04 24 81 2c 80 00 	movl   $0x802c81,(%esp)
  8015ef:	e8 c8 eb ff ff       	call   8001bc <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  8015f4:	83 c4 24             	add    $0x24,%esp
  8015f7:	5b                   	pop    %ebx
  8015f8:	5d                   	pop    %ebp
  8015f9:	c3                   	ret    
  8015fa:	00 00                	add    %al,(%eax)
  8015fc:	00 00                	add    %al,(%eax)
	...

00801600 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801606:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80160c:	b8 01 00 00 00       	mov    $0x1,%eax
  801611:	39 ca                	cmp    %ecx,%edx
  801613:	75 04                	jne    801619 <ipc_find_env+0x19>
  801615:	b0 00                	mov    $0x0,%al
  801617:	eb 0f                	jmp    801628 <ipc_find_env+0x28>
  801619:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80161c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801622:	8b 12                	mov    (%edx),%edx
  801624:	39 ca                	cmp    %ecx,%edx
  801626:	75 0c                	jne    801634 <ipc_find_env+0x34>
			return envs[i].env_id;
  801628:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80162b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801630:	8b 00                	mov    (%eax),%eax
  801632:	eb 0e                	jmp    801642 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801634:	83 c0 01             	add    $0x1,%eax
  801637:	3d 00 04 00 00       	cmp    $0x400,%eax
  80163c:	75 db                	jne    801619 <ipc_find_env+0x19>
  80163e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801642:	5d                   	pop    %ebp
  801643:	c3                   	ret    

00801644 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	57                   	push   %edi
  801648:	56                   	push   %esi
  801649:	53                   	push   %ebx
  80164a:	83 ec 1c             	sub    $0x1c,%esp
  80164d:	8b 75 08             	mov    0x8(%ebp),%esi
  801650:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801653:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801656:	85 db                	test   %ebx,%ebx
  801658:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80165d:	0f 44 d8             	cmove  %eax,%ebx
  801660:	eb 25                	jmp    801687 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801662:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801665:	74 20                	je     801687 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801667:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80166b:	c7 44 24 08 a8 2e 80 	movl   $0x802ea8,0x8(%esp)
  801672:	00 
  801673:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80167a:	00 
  80167b:	c7 04 24 c6 2e 80 00 	movl   $0x802ec6,(%esp)
  801682:	e8 35 eb ff ff       	call   8001bc <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801687:	8b 45 14             	mov    0x14(%ebp),%eax
  80168a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80168e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801692:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801696:	89 34 24             	mov    %esi,(%esp)
  801699:	e8 30 f8 ff ff       	call   800ece <sys_ipc_try_send>
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	75 c0                	jne    801662 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8016a2:	e8 ad f9 ff ff       	call   801054 <sys_yield>
}
  8016a7:	83 c4 1c             	add    $0x1c,%esp
  8016aa:	5b                   	pop    %ebx
  8016ab:	5e                   	pop    %esi
  8016ac:	5f                   	pop    %edi
  8016ad:	5d                   	pop    %ebp
  8016ae:	c3                   	ret    

008016af <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 28             	sub    $0x28,%esp
  8016b5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016b8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016bb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016be:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c4:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8016ce:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8016d1:	89 04 24             	mov    %eax,(%esp)
  8016d4:	e8 bc f7 ff ff       	call   800e95 <sys_ipc_recv>
  8016d9:	89 c3                	mov    %eax,%ebx
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	79 2a                	jns    801709 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8016df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e7:	c7 04 24 d0 2e 80 00 	movl   $0x802ed0,(%esp)
  8016ee:	e8 82 eb ff ff       	call   800275 <cprintf>
		if(from_env_store != NULL)
  8016f3:	85 f6                	test   %esi,%esi
  8016f5:	74 06                	je     8016fd <ipc_recv+0x4e>
			*from_env_store = 0;
  8016f7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8016fd:	85 ff                	test   %edi,%edi
  8016ff:	74 2c                	je     80172d <ipc_recv+0x7e>
			*perm_store = 0;
  801701:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801707:	eb 24                	jmp    80172d <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801709:	85 f6                	test   %esi,%esi
  80170b:	74 0a                	je     801717 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  80170d:	a1 08 50 80 00       	mov    0x805008,%eax
  801712:	8b 40 74             	mov    0x74(%eax),%eax
  801715:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801717:	85 ff                	test   %edi,%edi
  801719:	74 0a                	je     801725 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  80171b:	a1 08 50 80 00       	mov    0x805008,%eax
  801720:	8b 40 78             	mov    0x78(%eax),%eax
  801723:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801725:	a1 08 50 80 00       	mov    0x805008,%eax
  80172a:	8b 58 70             	mov    0x70(%eax),%ebx
}
  80172d:	89 d8                	mov    %ebx,%eax
  80172f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801732:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801735:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801738:	89 ec                	mov    %ebp,%esp
  80173a:	5d                   	pop    %ebp
  80173b:	c3                   	ret    
  80173c:	00 00                	add    %al,(%eax)
	...

00801740 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	8b 45 08             	mov    0x8(%ebp),%eax
  801746:	05 00 00 00 30       	add    $0x30000000,%eax
  80174b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801756:	8b 45 08             	mov    0x8(%ebp),%eax
  801759:	89 04 24             	mov    %eax,(%esp)
  80175c:	e8 df ff ff ff       	call   801740 <fd2num>
  801761:	05 20 00 0d 00       	add    $0xd0020,%eax
  801766:	c1 e0 0c             	shl    $0xc,%eax
}
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	57                   	push   %edi
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801774:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801779:	a8 01                	test   $0x1,%al
  80177b:	74 36                	je     8017b3 <fd_alloc+0x48>
  80177d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801782:	a8 01                	test   $0x1,%al
  801784:	74 2d                	je     8017b3 <fd_alloc+0x48>
  801786:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80178b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801790:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801795:	89 c3                	mov    %eax,%ebx
  801797:	89 c2                	mov    %eax,%edx
  801799:	c1 ea 16             	shr    $0x16,%edx
  80179c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80179f:	f6 c2 01             	test   $0x1,%dl
  8017a2:	74 14                	je     8017b8 <fd_alloc+0x4d>
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	c1 ea 0c             	shr    $0xc,%edx
  8017a9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8017ac:	f6 c2 01             	test   $0x1,%dl
  8017af:	75 10                	jne    8017c1 <fd_alloc+0x56>
  8017b1:	eb 05                	jmp    8017b8 <fd_alloc+0x4d>
  8017b3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8017b8:	89 1f                	mov    %ebx,(%edi)
  8017ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017bf:	eb 17                	jmp    8017d8 <fd_alloc+0x6d>
  8017c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017cb:	75 c8                	jne    801795 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8017d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5f                   	pop    %edi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    

008017dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e3:	83 f8 1f             	cmp    $0x1f,%eax
  8017e6:	77 36                	ja     80181e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017e8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8017ed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	c1 ea 16             	shr    $0x16,%edx
  8017f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8017fc:	f6 c2 01             	test   $0x1,%dl
  8017ff:	74 1d                	je     80181e <fd_lookup+0x41>
  801801:	89 c2                	mov    %eax,%edx
  801803:	c1 ea 0c             	shr    $0xc,%edx
  801806:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80180d:	f6 c2 01             	test   $0x1,%dl
  801810:	74 0c                	je     80181e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801812:	8b 55 0c             	mov    0xc(%ebp),%edx
  801815:	89 02                	mov    %eax,(%edx)
  801817:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80181c:	eb 05                	jmp    801823 <fd_lookup+0x46>
  80181e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801823:	5d                   	pop    %ebp
  801824:	c3                   	ret    

00801825 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80182b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80182e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	89 04 24             	mov    %eax,(%esp)
  801838:	e8 a0 ff ff ff       	call   8017dd <fd_lookup>
  80183d:	85 c0                	test   %eax,%eax
  80183f:	78 0e                	js     80184f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801841:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801844:	8b 55 0c             	mov    0xc(%ebp),%edx
  801847:	89 50 04             	mov    %edx,0x4(%eax)
  80184a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	56                   	push   %esi
  801855:	53                   	push   %ebx
  801856:	83 ec 10             	sub    $0x10,%esp
  801859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80185c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801864:	b8 04 40 80 00       	mov    $0x804004,%eax
  801869:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  80186f:	75 11                	jne    801882 <dev_lookup+0x31>
  801871:	eb 04                	jmp    801877 <dev_lookup+0x26>
  801873:	39 08                	cmp    %ecx,(%eax)
  801875:	75 10                	jne    801887 <dev_lookup+0x36>
			*dev = devtab[i];
  801877:	89 03                	mov    %eax,(%ebx)
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80187e:	66 90                	xchg   %ax,%ax
  801880:	eb 36                	jmp    8018b8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801882:	be 64 2f 80 00       	mov    $0x802f64,%esi
  801887:	83 c2 01             	add    $0x1,%edx
  80188a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80188d:	85 c0                	test   %eax,%eax
  80188f:	75 e2                	jne    801873 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801891:	a1 08 50 80 00       	mov    0x805008,%eax
  801896:	8b 40 48             	mov    0x48(%eax),%eax
  801899:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80189d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a1:	c7 04 24 e4 2e 80 00 	movl   $0x802ee4,(%esp)
  8018a8:	e8 c8 e9 ff ff       	call   800275 <cprintf>
	*dev = 0;
  8018ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	5b                   	pop    %ebx
  8018bc:	5e                   	pop    %esi
  8018bd:	5d                   	pop    %ebp
  8018be:	c3                   	ret    

008018bf <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	53                   	push   %ebx
  8018c3:	83 ec 24             	sub    $0x24,%esp
  8018c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	89 04 24             	mov    %eax,(%esp)
  8018d6:	e8 02 ff ff ff       	call   8017dd <fd_lookup>
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	78 53                	js     801932 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e9:	8b 00                	mov    (%eax),%eax
  8018eb:	89 04 24             	mov    %eax,(%esp)
  8018ee:	e8 5e ff ff ff       	call   801851 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 3b                	js     801932 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8018f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ff:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801903:	74 2d                	je     801932 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801905:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801908:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80190f:	00 00 00 
	stat->st_isdir = 0;
  801912:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801919:	00 00 00 
	stat->st_dev = dev;
  80191c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801925:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801929:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80192c:	89 14 24             	mov    %edx,(%esp)
  80192f:	ff 50 14             	call   *0x14(%eax)
}
  801932:	83 c4 24             	add    $0x24,%esp
  801935:	5b                   	pop    %ebx
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	53                   	push   %ebx
  80193c:	83 ec 24             	sub    $0x24,%esp
  80193f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801942:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801945:	89 44 24 04          	mov    %eax,0x4(%esp)
  801949:	89 1c 24             	mov    %ebx,(%esp)
  80194c:	e8 8c fe ff ff       	call   8017dd <fd_lookup>
  801951:	85 c0                	test   %eax,%eax
  801953:	78 5f                	js     8019b4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801955:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801958:	89 44 24 04          	mov    %eax,0x4(%esp)
  80195c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195f:	8b 00                	mov    (%eax),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 e8 fe ff ff       	call   801851 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 47                	js     8019b4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80196d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801970:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801974:	75 23                	jne    801999 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801976:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80197b:	8b 40 48             	mov    0x48(%eax),%eax
  80197e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801982:	89 44 24 04          	mov    %eax,0x4(%esp)
  801986:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  80198d:	e8 e3 e8 ff ff       	call   800275 <cprintf>
  801992:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801997:	eb 1b                	jmp    8019b4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801999:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199c:	8b 48 18             	mov    0x18(%eax),%ecx
  80199f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a4:	85 c9                	test   %ecx,%ecx
  8019a6:	74 0c                	je     8019b4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019af:	89 14 24             	mov    %edx,(%esp)
  8019b2:	ff d1                	call   *%ecx
}
  8019b4:	83 c4 24             	add    $0x24,%esp
  8019b7:	5b                   	pop    %ebx
  8019b8:	5d                   	pop    %ebp
  8019b9:	c3                   	ret    

008019ba <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019ba:	55                   	push   %ebp
  8019bb:	89 e5                	mov    %esp,%ebp
  8019bd:	53                   	push   %ebx
  8019be:	83 ec 24             	sub    $0x24,%esp
  8019c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	89 1c 24             	mov    %ebx,(%esp)
  8019ce:	e8 0a fe ff ff       	call   8017dd <fd_lookup>
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 66                	js     801a3d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019e1:	8b 00                	mov    (%eax),%eax
  8019e3:	89 04 24             	mov    %eax,(%esp)
  8019e6:	e8 66 fe ff ff       	call   801851 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 4e                	js     801a3d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019f2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8019f6:	75 23                	jne    801a1b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8019f8:	a1 08 50 80 00       	mov    0x805008,%eax
  8019fd:	8b 40 48             	mov    0x48(%eax),%eax
  801a00:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	c7 04 24 28 2f 80 00 	movl   $0x802f28,(%esp)
  801a0f:	e8 61 e8 ff ff       	call   800275 <cprintf>
  801a14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a19:	eb 22                	jmp    801a3d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801a21:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a26:	85 c9                	test   %ecx,%ecx
  801a28:	74 13                	je     801a3d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a38:	89 14 24             	mov    %edx,(%esp)
  801a3b:	ff d1                	call   *%ecx
}
  801a3d:	83 c4 24             	add    $0x24,%esp
  801a40:	5b                   	pop    %ebx
  801a41:	5d                   	pop    %ebp
  801a42:	c3                   	ret    

00801a43 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	53                   	push   %ebx
  801a47:	83 ec 24             	sub    $0x24,%esp
  801a4a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a54:	89 1c 24             	mov    %ebx,(%esp)
  801a57:	e8 81 fd ff ff       	call   8017dd <fd_lookup>
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 6b                	js     801acb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a6a:	8b 00                	mov    (%eax),%eax
  801a6c:	89 04 24             	mov    %eax,(%esp)
  801a6f:	e8 dd fd ff ff       	call   801851 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a74:	85 c0                	test   %eax,%eax
  801a76:	78 53                	js     801acb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a7b:	8b 42 08             	mov    0x8(%edx),%eax
  801a7e:	83 e0 03             	and    $0x3,%eax
  801a81:	83 f8 01             	cmp    $0x1,%eax
  801a84:	75 23                	jne    801aa9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a86:	a1 08 50 80 00       	mov    0x805008,%eax
  801a8b:	8b 40 48             	mov    0x48(%eax),%eax
  801a8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a92:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a96:	c7 04 24 45 2f 80 00 	movl   $0x802f45,(%esp)
  801a9d:	e8 d3 e7 ff ff       	call   800275 <cprintf>
  801aa2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801aa7:	eb 22                	jmp    801acb <read+0x88>
	}
	if (!dev->dev_read)
  801aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aac:	8b 48 08             	mov    0x8(%eax),%ecx
  801aaf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ab4:	85 c9                	test   %ecx,%ecx
  801ab6:	74 13                	je     801acb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ab8:	8b 45 10             	mov    0x10(%ebp),%eax
  801abb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	89 14 24             	mov    %edx,(%esp)
  801ac9:	ff d1                	call   *%ecx
}
  801acb:	83 c4 24             	add    $0x24,%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	57                   	push   %edi
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	83 ec 1c             	sub    $0x1c,%esp
  801ada:	8b 7d 08             	mov    0x8(%ebp),%edi
  801add:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ae5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
  801aef:	85 f6                	test   %esi,%esi
  801af1:	74 29                	je     801b1c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801af3:	89 f0                	mov    %esi,%eax
  801af5:	29 d0                	sub    %edx,%eax
  801af7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801afb:	03 55 0c             	add    0xc(%ebp),%edx
  801afe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b02:	89 3c 24             	mov    %edi,(%esp)
  801b05:	e8 39 ff ff ff       	call   801a43 <read>
		if (m < 0)
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 0e                	js     801b1c <readn+0x4b>
			return m;
		if (m == 0)
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	74 08                	je     801b1a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b12:	01 c3                	add    %eax,%ebx
  801b14:	89 da                	mov    %ebx,%edx
  801b16:	39 f3                	cmp    %esi,%ebx
  801b18:	72 d9                	jb     801af3 <readn+0x22>
  801b1a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b1c:	83 c4 1c             	add    $0x1c,%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	83 ec 28             	sub    $0x28,%esp
  801b2a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b2d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b30:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b33:	89 34 24             	mov    %esi,(%esp)
  801b36:	e8 05 fc ff ff       	call   801740 <fd2num>
  801b3b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b42:	89 04 24             	mov    %eax,(%esp)
  801b45:	e8 93 fc ff ff       	call   8017dd <fd_lookup>
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	78 05                	js     801b55 <fd_close+0x31>
  801b50:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b53:	74 0e                	je     801b63 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b55:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b59:	b8 00 00 00 00       	mov    $0x0,%eax
  801b5e:	0f 44 d8             	cmove  %eax,%ebx
  801b61:	eb 3d                	jmp    801ba0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6a:	8b 06                	mov    (%esi),%eax
  801b6c:	89 04 24             	mov    %eax,(%esp)
  801b6f:	e8 dd fc ff ff       	call   801851 <dev_lookup>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	78 16                	js     801b90 <fd_close+0x6c>
		if (dev->dev_close)
  801b7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7d:	8b 40 10             	mov    0x10(%eax),%eax
  801b80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b85:	85 c0                	test   %eax,%eax
  801b87:	74 07                	je     801b90 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801b89:	89 34 24             	mov    %esi,(%esp)
  801b8c:	ff d0                	call   *%eax
  801b8e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b90:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b94:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b9b:	e8 0c f4 ff ff       	call   800fac <sys_page_unmap>
	return r;
}
  801ba0:	89 d8                	mov    %ebx,%eax
  801ba2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ba5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ba8:	89 ec                	mov    %ebp,%esp
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    

00801bac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801bac:	55                   	push   %ebp
  801bad:	89 e5                	mov    %esp,%ebp
  801baf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 19 fc ff ff       	call   8017dd <fd_lookup>
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 13                	js     801bdb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801bc8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bcf:	00 
  801bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd3:	89 04 24             	mov    %eax,(%esp)
  801bd6:	e8 49 ff ff ff       	call   801b24 <fd_close>
}
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	83 ec 18             	sub    $0x18,%esp
  801be3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801be6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801be9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bf0:	00 
  801bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf4:	89 04 24             	mov    %eax,(%esp)
  801bf7:	e8 78 03 00 00       	call   801f74 <open>
  801bfc:	89 c3                	mov    %eax,%ebx
  801bfe:	85 c0                	test   %eax,%eax
  801c00:	78 1b                	js     801c1d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c09:	89 1c 24             	mov    %ebx,(%esp)
  801c0c:	e8 ae fc ff ff       	call   8018bf <fstat>
  801c11:	89 c6                	mov    %eax,%esi
	close(fd);
  801c13:	89 1c 24             	mov    %ebx,(%esp)
  801c16:	e8 91 ff ff ff       	call   801bac <close>
  801c1b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801c1d:	89 d8                	mov    %ebx,%eax
  801c1f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c22:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c25:	89 ec                	mov    %ebp,%esp
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    

00801c29 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	53                   	push   %ebx
  801c2d:	83 ec 14             	sub    $0x14,%esp
  801c30:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801c35:	89 1c 24             	mov    %ebx,(%esp)
  801c38:	e8 6f ff ff ff       	call   801bac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c3d:	83 c3 01             	add    $0x1,%ebx
  801c40:	83 fb 20             	cmp    $0x20,%ebx
  801c43:	75 f0                	jne    801c35 <close_all+0xc>
		close(i);
}
  801c45:	83 c4 14             	add    $0x14,%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	83 ec 58             	sub    $0x58,%esp
  801c51:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c54:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c57:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c5a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c5d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c64:	8b 45 08             	mov    0x8(%ebp),%eax
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	e8 6e fb ff ff       	call   8017dd <fd_lookup>
  801c6f:	89 c3                	mov    %eax,%ebx
  801c71:	85 c0                	test   %eax,%eax
  801c73:	0f 88 e0 00 00 00    	js     801d59 <dup+0x10e>
		return r;
	close(newfdnum);
  801c79:	89 3c 24             	mov    %edi,(%esp)
  801c7c:	e8 2b ff ff ff       	call   801bac <close>

	newfd = INDEX2FD(newfdnum);
  801c81:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c87:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c8d:	89 04 24             	mov    %eax,(%esp)
  801c90:	e8 bb fa ff ff       	call   801750 <fd2data>
  801c95:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c97:	89 34 24             	mov    %esi,(%esp)
  801c9a:	e8 b1 fa ff ff       	call   801750 <fd2data>
  801c9f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801ca2:	89 da                	mov    %ebx,%edx
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	c1 e8 16             	shr    $0x16,%eax
  801ca9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cb0:	a8 01                	test   $0x1,%al
  801cb2:	74 43                	je     801cf7 <dup+0xac>
  801cb4:	c1 ea 0c             	shr    $0xc,%edx
  801cb7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cbe:	a8 01                	test   $0x1,%al
  801cc0:	74 35                	je     801cf7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801cc2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cc9:	25 07 0e 00 00       	and    $0xe07,%eax
  801cce:	89 44 24 10          	mov    %eax,0x10(%esp)
  801cd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801cd5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cd9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ce0:	00 
  801ce1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cec:	e8 f3 f2 ff ff       	call   800fe4 <sys_page_map>
  801cf1:	89 c3                	mov    %eax,%ebx
  801cf3:	85 c0                	test   %eax,%eax
  801cf5:	78 3f                	js     801d36 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801cf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cfa:	89 c2                	mov    %eax,%edx
  801cfc:	c1 ea 0c             	shr    $0xc,%edx
  801cff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d06:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d0c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d10:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d14:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d1b:	00 
  801d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d27:	e8 b8 f2 ff ff       	call   800fe4 <sys_page_map>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 04                	js     801d36 <dup+0xeb>
  801d32:	89 fb                	mov    %edi,%ebx
  801d34:	eb 23                	jmp    801d59 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d36:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d41:	e8 66 f2 ff ff       	call   800fac <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d49:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d54:	e8 53 f2 ff ff       	call   800fac <sys_page_unmap>
	return r;
}
  801d59:	89 d8                	mov    %ebx,%eax
  801d5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d5e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d61:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d64:	89 ec                	mov    %ebp,%esp
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    

00801d68 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	83 ec 18             	sub    $0x18,%esp
  801d6e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d71:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d74:	89 c3                	mov    %eax,%ebx
  801d76:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d78:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d7f:	75 11                	jne    801d92 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d81:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d88:	e8 73 f8 ff ff       	call   801600 <ipc_find_env>
  801d8d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d92:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d99:	00 
  801d9a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801da1:	00 
  801da2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801da6:	a1 00 50 80 00       	mov    0x805000,%eax
  801dab:	89 04 24             	mov    %eax,(%esp)
  801dae:	e8 91 f8 ff ff       	call   801644 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801db3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dba:	00 
  801dbb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dc6:	e8 e4 f8 ff ff       	call   8016af <ipc_recv>
}
  801dcb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dce:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801dd1:	89 ec                	mov    %ebp,%esp
  801dd3:	5d                   	pop    %ebp
  801dd4:	c3                   	ret    

00801dd5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ddb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dde:	8b 40 0c             	mov    0xc(%eax),%eax
  801de1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de9:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801dee:	ba 00 00 00 00       	mov    $0x0,%edx
  801df3:	b8 02 00 00 00       	mov    $0x2,%eax
  801df8:	e8 6b ff ff ff       	call   801d68 <fsipc>
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e05:	8b 45 08             	mov    0x8(%ebp),%eax
  801e08:	8b 40 0c             	mov    0xc(%eax),%eax
  801e0b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e10:	ba 00 00 00 00       	mov    $0x0,%edx
  801e15:	b8 06 00 00 00       	mov    $0x6,%eax
  801e1a:	e8 49 ff ff ff       	call   801d68 <fsipc>
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    

00801e21 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e27:	ba 00 00 00 00       	mov    $0x0,%edx
  801e2c:	b8 08 00 00 00       	mov    $0x8,%eax
  801e31:	e8 32 ff ff ff       	call   801d68 <fsipc>
}
  801e36:	c9                   	leave  
  801e37:	c3                   	ret    

00801e38 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	53                   	push   %ebx
  801e3c:	83 ec 14             	sub    $0x14,%esp
  801e3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e42:	8b 45 08             	mov    0x8(%ebp),%eax
  801e45:	8b 40 0c             	mov    0xc(%eax),%eax
  801e48:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e52:	b8 05 00 00 00       	mov    $0x5,%eax
  801e57:	e8 0c ff ff ff       	call   801d68 <fsipc>
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	78 2b                	js     801e8b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e60:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e67:	00 
  801e68:	89 1c 24             	mov    %ebx,(%esp)
  801e6b:	e8 4a eb ff ff       	call   8009ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e70:	a1 80 60 80 00       	mov    0x806080,%eax
  801e75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e7b:	a1 84 60 80 00       	mov    0x806084,%eax
  801e80:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e86:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e8b:	83 c4 14             	add    $0x14,%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	83 ec 18             	sub    $0x18,%esp
  801e97:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e9d:	8b 52 0c             	mov    0xc(%edx),%edx
  801ea0:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801ea6:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801eab:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801eb0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801eb5:	0f 47 c2             	cmova  %edx,%eax
  801eb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ec3:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801eca:	e8 d6 ec ff ff       	call   800ba5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801ecf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed4:	b8 04 00 00 00       	mov    $0x4,%eax
  801ed9:	e8 8a fe ff ff       	call   801d68 <fsipc>
}
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eea:	8b 40 0c             	mov    0xc(%eax),%eax
  801eed:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801ef2:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef5:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801efa:	ba 00 00 00 00       	mov    $0x0,%edx
  801eff:	b8 03 00 00 00       	mov    $0x3,%eax
  801f04:	e8 5f fe ff ff       	call   801d68 <fsipc>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	78 17                	js     801f26 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f13:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f1a:	00 
  801f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1e:	89 04 24             	mov    %eax,(%esp)
  801f21:	e8 7f ec ff ff       	call   800ba5 <memmove>
  return r;	
}
  801f26:	89 d8                	mov    %ebx,%eax
  801f28:	83 c4 14             	add    $0x14,%esp
  801f2b:	5b                   	pop    %ebx
  801f2c:	5d                   	pop    %ebp
  801f2d:	c3                   	ret    

00801f2e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	53                   	push   %ebx
  801f32:	83 ec 14             	sub    $0x14,%esp
  801f35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801f38:	89 1c 24             	mov    %ebx,(%esp)
  801f3b:	e8 30 ea ff ff       	call   800970 <strlen>
  801f40:	89 c2                	mov    %eax,%edx
  801f42:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801f47:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801f4d:	7f 1f                	jg     801f6e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f53:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f5a:	e8 5b ea ff ff       	call   8009ba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f64:	b8 07 00 00 00       	mov    $0x7,%eax
  801f69:	e8 fa fd ff ff       	call   801d68 <fsipc>
}
  801f6e:	83 c4 14             	add    $0x14,%esp
  801f71:	5b                   	pop    %ebx
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 28             	sub    $0x28,%esp
  801f7a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f7d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f80:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 dd f7 ff ff       	call   80176b <fd_alloc>
  801f8e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801f90:	85 c0                	test   %eax,%eax
  801f92:	0f 88 89 00 00 00    	js     802021 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801f98:	89 34 24             	mov    %esi,(%esp)
  801f9b:	e8 d0 e9 ff ff       	call   800970 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801fa0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801fa5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801faa:	7f 75                	jg     802021 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801fac:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fb0:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801fb7:	e8 fe e9 ff ff       	call   8009ba <strcpy>
  fsipcbuf.open.req_omode = mode;
  801fbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fbf:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801fc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fc7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fcc:	e8 97 fd ff ff       	call   801d68 <fsipc>
  801fd1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	78 0f                	js     801fe6 <open+0x72>
  return fd2num(fd);
  801fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fda:	89 04 24             	mov    %eax,(%esp)
  801fdd:	e8 5e f7 ff ff       	call   801740 <fd2num>
  801fe2:	89 c3                	mov    %eax,%ebx
  801fe4:	eb 3b                	jmp    802021 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801fe6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801fed:	00 
  801fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ff1:	89 04 24             	mov    %eax,(%esp)
  801ff4:	e8 2b fb ff ff       	call   801b24 <fd_close>
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	74 24                	je     802021 <open+0xad>
  801ffd:	c7 44 24 0c 70 2f 80 	movl   $0x802f70,0xc(%esp)
  802004:	00 
  802005:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  80200c:	00 
  80200d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  802014:	00 
  802015:	c7 04 24 9a 2f 80 00 	movl   $0x802f9a,(%esp)
  80201c:	e8 9b e1 ff ff       	call   8001bc <_panic>
  return r;
}
  802021:	89 d8                	mov    %ebx,%eax
  802023:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802026:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802029:	89 ec                	mov    %ebp,%esp
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    
  80202d:	00 00                	add    %al,(%eax)
	...

00802030 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802036:	c7 44 24 04 a5 2f 80 	movl   $0x802fa5,0x4(%esp)
  80203d:	00 
  80203e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802041:	89 04 24             	mov    %eax,(%esp)
  802044:	e8 71 e9 ff ff       	call   8009ba <strcpy>
	return 0;
}
  802049:	b8 00 00 00 00       	mov    $0x0,%eax
  80204e:	c9                   	leave  
  80204f:	c3                   	ret    

00802050 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	53                   	push   %ebx
  802054:	83 ec 14             	sub    $0x14,%esp
  802057:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80205a:	89 1c 24             	mov    %ebx,(%esp)
  80205d:	e8 6a 05 00 00       	call   8025cc <pageref>
  802062:	89 c2                	mov    %eax,%edx
  802064:	b8 00 00 00 00       	mov    $0x0,%eax
  802069:	83 fa 01             	cmp    $0x1,%edx
  80206c:	75 0b                	jne    802079 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80206e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802071:	89 04 24             	mov    %eax,(%esp)
  802074:	e8 b9 02 00 00       	call   802332 <nsipc_close>
	else
		return 0;
}
  802079:	83 c4 14             	add    $0x14,%esp
  80207c:	5b                   	pop    %ebx
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802085:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80208c:	00 
  80208d:	8b 45 10             	mov    0x10(%ebp),%eax
  802090:	89 44 24 08          	mov    %eax,0x8(%esp)
  802094:	8b 45 0c             	mov    0xc(%ebp),%eax
  802097:	89 44 24 04          	mov    %eax,0x4(%esp)
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	8b 40 0c             	mov    0xc(%eax),%eax
  8020a1:	89 04 24             	mov    %eax,(%esp)
  8020a4:	e8 c5 02 00 00       	call   80236e <nsipc_send>
}
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    

008020ab <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8020b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020b8:	00 
  8020b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8020cd:	89 04 24             	mov    %eax,(%esp)
  8020d0:	e8 0c 03 00 00       	call   8023e1 <nsipc_recv>
}
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    

008020d7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8020d7:	55                   	push   %ebp
  8020d8:	89 e5                	mov    %esp,%ebp
  8020da:	56                   	push   %esi
  8020db:	53                   	push   %ebx
  8020dc:	83 ec 20             	sub    $0x20,%esp
  8020df:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e4:	89 04 24             	mov    %eax,(%esp)
  8020e7:	e8 7f f6 ff ff       	call   80176b <fd_alloc>
  8020ec:	89 c3                	mov    %eax,%ebx
  8020ee:	85 c0                	test   %eax,%eax
  8020f0:	78 21                	js     802113 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8020f2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8020f9:	00 
  8020fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802101:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802108:	e8 10 ef ff ff       	call   80101d <sys_page_alloc>
  80210d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80210f:	85 c0                	test   %eax,%eax
  802111:	79 0a                	jns    80211d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802113:	89 34 24             	mov    %esi,(%esp)
  802116:	e8 17 02 00 00       	call   802332 <nsipc_close>
		return r;
  80211b:	eb 28                	jmp    802145 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80211d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802123:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802126:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802135:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213b:	89 04 24             	mov    %eax,(%esp)
  80213e:	e8 fd f5 ff ff       	call   801740 <fd2num>
  802143:	89 c3                	mov    %eax,%ebx
}
  802145:	89 d8                	mov    %ebx,%eax
  802147:	83 c4 20             	add    $0x20,%esp
  80214a:	5b                   	pop    %ebx
  80214b:	5e                   	pop    %esi
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802154:	8b 45 10             	mov    0x10(%ebp),%eax
  802157:	89 44 24 08          	mov    %eax,0x8(%esp)
  80215b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80215e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802162:	8b 45 08             	mov    0x8(%ebp),%eax
  802165:	89 04 24             	mov    %eax,(%esp)
  802168:	e8 79 01 00 00       	call   8022e6 <nsipc_socket>
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 05                	js     802176 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802171:	e8 61 ff ff ff       	call   8020d7 <alloc_sockfd>
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80217e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802181:	89 54 24 04          	mov    %edx,0x4(%esp)
  802185:	89 04 24             	mov    %eax,(%esp)
  802188:	e8 50 f6 ff ff       	call   8017dd <fd_lookup>
  80218d:	85 c0                	test   %eax,%eax
  80218f:	78 15                	js     8021a6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802191:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802194:	8b 0a                	mov    (%edx),%ecx
  802196:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80219b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8021a1:	75 03                	jne    8021a6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021a3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8021a6:	c9                   	leave  
  8021a7:	c3                   	ret    

008021a8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8021a8:	55                   	push   %ebp
  8021a9:	89 e5                	mov    %esp,%ebp
  8021ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b1:	e8 c2 ff ff ff       	call   802178 <fd2sockid>
  8021b6:	85 c0                	test   %eax,%eax
  8021b8:	78 0f                	js     8021c9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c1:	89 04 24             	mov    %eax,(%esp)
  8021c4:	e8 47 01 00 00       	call   802310 <nsipc_listen>
}
  8021c9:	c9                   	leave  
  8021ca:	c3                   	ret    

008021cb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021d4:	e8 9f ff ff ff       	call   802178 <fd2sockid>
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	78 16                	js     8021f3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8021dd:	8b 55 10             	mov    0x10(%ebp),%edx
  8021e0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021eb:	89 04 24             	mov    %eax,(%esp)
  8021ee:	e8 6e 02 00 00       	call   802461 <nsipc_connect>
}
  8021f3:	c9                   	leave  
  8021f4:	c3                   	ret    

008021f5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fe:	e8 75 ff ff ff       	call   802178 <fd2sockid>
  802203:	85 c0                	test   %eax,%eax
  802205:	78 0f                	js     802216 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802207:	8b 55 0c             	mov    0xc(%ebp),%edx
  80220a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80220e:	89 04 24             	mov    %eax,(%esp)
  802211:	e8 36 01 00 00       	call   80234c <nsipc_shutdown>
}
  802216:	c9                   	leave  
  802217:	c3                   	ret    

00802218 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802218:	55                   	push   %ebp
  802219:	89 e5                	mov    %esp,%ebp
  80221b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80221e:	8b 45 08             	mov    0x8(%ebp),%eax
  802221:	e8 52 ff ff ff       	call   802178 <fd2sockid>
  802226:	85 c0                	test   %eax,%eax
  802228:	78 16                	js     802240 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80222a:	8b 55 10             	mov    0x10(%ebp),%edx
  80222d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802231:	8b 55 0c             	mov    0xc(%ebp),%edx
  802234:	89 54 24 04          	mov    %edx,0x4(%esp)
  802238:	89 04 24             	mov    %eax,(%esp)
  80223b:	e8 60 02 00 00       	call   8024a0 <nsipc_bind>
}
  802240:	c9                   	leave  
  802241:	c3                   	ret    

00802242 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802242:	55                   	push   %ebp
  802243:	89 e5                	mov    %esp,%ebp
  802245:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802248:	8b 45 08             	mov    0x8(%ebp),%eax
  80224b:	e8 28 ff ff ff       	call   802178 <fd2sockid>
  802250:	85 c0                	test   %eax,%eax
  802252:	78 1f                	js     802273 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802254:	8b 55 10             	mov    0x10(%ebp),%edx
  802257:	89 54 24 08          	mov    %edx,0x8(%esp)
  80225b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80225e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802262:	89 04 24             	mov    %eax,(%esp)
  802265:	e8 75 02 00 00       	call   8024df <nsipc_accept>
  80226a:	85 c0                	test   %eax,%eax
  80226c:	78 05                	js     802273 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80226e:	e8 64 fe ff ff       	call   8020d7 <alloc_sockfd>
}
  802273:	c9                   	leave  
  802274:	c3                   	ret    
	...

00802280 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	53                   	push   %ebx
  802284:	83 ec 14             	sub    $0x14,%esp
  802287:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802289:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802290:	75 11                	jne    8022a3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802292:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802299:	e8 62 f3 ff ff       	call   801600 <ipc_find_env>
  80229e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8022a3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8022aa:	00 
  8022ab:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8022b2:	00 
  8022b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022b7:	a1 04 50 80 00       	mov    0x805004,%eax
  8022bc:	89 04 24             	mov    %eax,(%esp)
  8022bf:	e8 80 f3 ff ff       	call   801644 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8022c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022cb:	00 
  8022cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022d3:	00 
  8022d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022db:	e8 cf f3 ff ff       	call   8016af <ipc_recv>
}
  8022e0:	83 c4 14             	add    $0x14,%esp
  8022e3:	5b                   	pop    %ebx
  8022e4:	5d                   	pop    %ebp
  8022e5:	c3                   	ret    

008022e6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8022f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8022fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8022ff:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802304:	b8 09 00 00 00       	mov    $0x9,%eax
  802309:	e8 72 ff ff ff       	call   802280 <nsipc>
}
  80230e:	c9                   	leave  
  80230f:	c3                   	ret    

00802310 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802310:	55                   	push   %ebp
  802311:	89 e5                	mov    %esp,%ebp
  802313:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802316:	8b 45 08             	mov    0x8(%ebp),%eax
  802319:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80231e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802321:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802326:	b8 06 00 00 00       	mov    $0x6,%eax
  80232b:	e8 50 ff ff ff       	call   802280 <nsipc>
}
  802330:	c9                   	leave  
  802331:	c3                   	ret    

00802332 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802332:	55                   	push   %ebp
  802333:	89 e5                	mov    %esp,%ebp
  802335:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802338:	8b 45 08             	mov    0x8(%ebp),%eax
  80233b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802340:	b8 04 00 00 00       	mov    $0x4,%eax
  802345:	e8 36 ff ff ff       	call   802280 <nsipc>
}
  80234a:	c9                   	leave  
  80234b:	c3                   	ret    

0080234c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80234c:	55                   	push   %ebp
  80234d:	89 e5                	mov    %esp,%ebp
  80234f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802352:	8b 45 08             	mov    0x8(%ebp),%eax
  802355:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80235a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80235d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802362:	b8 03 00 00 00       	mov    $0x3,%eax
  802367:	e8 14 ff ff ff       	call   802280 <nsipc>
}
  80236c:	c9                   	leave  
  80236d:	c3                   	ret    

0080236e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80236e:	55                   	push   %ebp
  80236f:	89 e5                	mov    %esp,%ebp
  802371:	53                   	push   %ebx
  802372:	83 ec 14             	sub    $0x14,%esp
  802375:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802378:	8b 45 08             	mov    0x8(%ebp),%eax
  80237b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802380:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802386:	7e 24                	jle    8023ac <nsipc_send+0x3e>
  802388:	c7 44 24 0c b1 2f 80 	movl   $0x802fb1,0xc(%esp)
  80238f:	00 
  802390:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  802397:	00 
  802398:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80239f:	00 
  8023a0:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  8023a7:	e8 10 de ff ff       	call   8001bc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023b7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8023be:	e8 e2 e7 ff ff       	call   800ba5 <memmove>
	nsipcbuf.send.req_size = size;
  8023c3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023cc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023d1:	b8 08 00 00 00       	mov    $0x8,%eax
  8023d6:	e8 a5 fe ff ff       	call   802280 <nsipc>
}
  8023db:	83 c4 14             	add    $0x14,%esp
  8023de:	5b                   	pop    %ebx
  8023df:	5d                   	pop    %ebp
  8023e0:	c3                   	ret    

008023e1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023e1:	55                   	push   %ebp
  8023e2:	89 e5                	mov    %esp,%ebp
  8023e4:	56                   	push   %esi
  8023e5:	53                   	push   %ebx
  8023e6:	83 ec 10             	sub    $0x10,%esp
  8023e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ef:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8023f4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8023fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8023fd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802402:	b8 07 00 00 00       	mov    $0x7,%eax
  802407:	e8 74 fe ff ff       	call   802280 <nsipc>
  80240c:	89 c3                	mov    %eax,%ebx
  80240e:	85 c0                	test   %eax,%eax
  802410:	78 46                	js     802458 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802412:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802417:	7f 04                	jg     80241d <nsipc_recv+0x3c>
  802419:	39 c6                	cmp    %eax,%esi
  80241b:	7d 24                	jge    802441 <nsipc_recv+0x60>
  80241d:	c7 44 24 0c c9 2f 80 	movl   $0x802fc9,0xc(%esp)
  802424:	00 
  802425:	c7 44 24 08 85 2f 80 	movl   $0x802f85,0x8(%esp)
  80242c:	00 
  80242d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802434:	00 
  802435:	c7 04 24 bd 2f 80 00 	movl   $0x802fbd,(%esp)
  80243c:	e8 7b dd ff ff       	call   8001bc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802441:	89 44 24 08          	mov    %eax,0x8(%esp)
  802445:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80244c:	00 
  80244d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802450:	89 04 24             	mov    %eax,(%esp)
  802453:	e8 4d e7 ff ff       	call   800ba5 <memmove>
	}

	return r;
}
  802458:	89 d8                	mov    %ebx,%eax
  80245a:	83 c4 10             	add    $0x10,%esp
  80245d:	5b                   	pop    %ebx
  80245e:	5e                   	pop    %esi
  80245f:	5d                   	pop    %ebp
  802460:	c3                   	ret    

00802461 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802461:	55                   	push   %ebp
  802462:	89 e5                	mov    %esp,%ebp
  802464:	53                   	push   %ebx
  802465:	83 ec 14             	sub    $0x14,%esp
  802468:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80246b:	8b 45 08             	mov    0x8(%ebp),%eax
  80246e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802473:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802477:	8b 45 0c             	mov    0xc(%ebp),%eax
  80247a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80247e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802485:	e8 1b e7 ff ff       	call   800ba5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80248a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802490:	b8 05 00 00 00       	mov    $0x5,%eax
  802495:	e8 e6 fd ff ff       	call   802280 <nsipc>
}
  80249a:	83 c4 14             	add    $0x14,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5d                   	pop    %ebp
  80249f:	c3                   	ret    

008024a0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 14             	sub    $0x14,%esp
  8024a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ad:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024bd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8024c4:	e8 dc e6 ff ff       	call   800ba5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024c9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8024cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8024d4:	e8 a7 fd ff ff       	call   802280 <nsipc>
}
  8024d9:	83 c4 14             	add    $0x14,%esp
  8024dc:	5b                   	pop    %ebx
  8024dd:	5d                   	pop    %ebp
  8024de:	c3                   	ret    

008024df <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	83 ec 18             	sub    $0x18,%esp
  8024e5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8024e8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8024eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ee:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8024f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f8:	e8 83 fd ff ff       	call   802280 <nsipc>
  8024fd:	89 c3                	mov    %eax,%ebx
  8024ff:	85 c0                	test   %eax,%eax
  802501:	78 25                	js     802528 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802503:	be 10 70 80 00       	mov    $0x807010,%esi
  802508:	8b 06                	mov    (%esi),%eax
  80250a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80250e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802515:	00 
  802516:	8b 45 0c             	mov    0xc(%ebp),%eax
  802519:	89 04 24             	mov    %eax,(%esp)
  80251c:	e8 84 e6 ff ff       	call   800ba5 <memmove>
		*addrlen = ret->ret_addrlen;
  802521:	8b 16                	mov    (%esi),%edx
  802523:	8b 45 10             	mov    0x10(%ebp),%eax
  802526:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80252d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802530:	89 ec                	mov    %ebp,%esp
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    

00802534 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802534:	55                   	push   %ebp
  802535:	89 e5                	mov    %esp,%ebp
  802537:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80253a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802541:	75 54                	jne    802597 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  802543:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80254a:	00 
  80254b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802552:	ee 
  802553:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80255a:	e8 be ea ff ff       	call   80101d <sys_page_alloc>
  80255f:	85 c0                	test   %eax,%eax
  802561:	79 20                	jns    802583 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  802563:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802567:	c7 44 24 08 de 2f 80 	movl   $0x802fde,0x8(%esp)
  80256e:	00 
  80256f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802576:	00 
  802577:	c7 04 24 f6 2f 80 00 	movl   $0x802ff6,(%esp)
  80257e:	e8 39 dc ff ff       	call   8001bc <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  802583:	c7 44 24 04 a4 25 80 	movl   $0x8025a4,0x4(%esp)
  80258a:	00 
  80258b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802592:	e8 6d e9 ff ff       	call   800f04 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802597:	8b 45 08             	mov    0x8(%ebp),%eax
  80259a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80259f:	c9                   	leave  
  8025a0:	c3                   	ret    
  8025a1:	00 00                	add    %al,(%eax)
	...

008025a4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025a4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025a5:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8025aa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025ac:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8025af:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8025b3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8025b6:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8025ba:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8025be:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8025c0:	83 c4 08             	add    $0x8,%esp
	popal
  8025c3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8025c4:	83 c4 04             	add    $0x4,%esp
	popfl
  8025c7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8025c8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8025c9:	c3                   	ret    
	...

008025cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025cc:	55                   	push   %ebp
  8025cd:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8025cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8025d2:	89 c2                	mov    %eax,%edx
  8025d4:	c1 ea 16             	shr    $0x16,%edx
  8025d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025de:	f6 c2 01             	test   $0x1,%dl
  8025e1:	74 20                	je     802603 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025e3:	c1 e8 0c             	shr    $0xc,%eax
  8025e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025ed:	a8 01                	test   $0x1,%al
  8025ef:	74 12                	je     802603 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025f1:	c1 e8 0c             	shr    $0xc,%eax
  8025f4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025f9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025fe:	0f b7 c0             	movzwl %ax,%eax
  802601:	eb 05                	jmp    802608 <pageref+0x3c>
  802603:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802608:	5d                   	pop    %ebp
  802609:	c3                   	ret    
  80260a:	00 00                	add    %al,(%eax)
  80260c:	00 00                	add    %al,(%eax)
	...

00802610 <__udivdi3>:
  802610:	55                   	push   %ebp
  802611:	89 e5                	mov    %esp,%ebp
  802613:	57                   	push   %edi
  802614:	56                   	push   %esi
  802615:	83 ec 10             	sub    $0x10,%esp
  802618:	8b 45 14             	mov    0x14(%ebp),%eax
  80261b:	8b 55 08             	mov    0x8(%ebp),%edx
  80261e:	8b 75 10             	mov    0x10(%ebp),%esi
  802621:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802624:	85 c0                	test   %eax,%eax
  802626:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802629:	75 35                	jne    802660 <__udivdi3+0x50>
  80262b:	39 fe                	cmp    %edi,%esi
  80262d:	77 61                	ja     802690 <__udivdi3+0x80>
  80262f:	85 f6                	test   %esi,%esi
  802631:	75 0b                	jne    80263e <__udivdi3+0x2e>
  802633:	b8 01 00 00 00       	mov    $0x1,%eax
  802638:	31 d2                	xor    %edx,%edx
  80263a:	f7 f6                	div    %esi
  80263c:	89 c6                	mov    %eax,%esi
  80263e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802641:	31 d2                	xor    %edx,%edx
  802643:	89 f8                	mov    %edi,%eax
  802645:	f7 f6                	div    %esi
  802647:	89 c7                	mov    %eax,%edi
  802649:	89 c8                	mov    %ecx,%eax
  80264b:	f7 f6                	div    %esi
  80264d:	89 c1                	mov    %eax,%ecx
  80264f:	89 fa                	mov    %edi,%edx
  802651:	89 c8                	mov    %ecx,%eax
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	5e                   	pop    %esi
  802657:	5f                   	pop    %edi
  802658:	5d                   	pop    %ebp
  802659:	c3                   	ret    
  80265a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802660:	39 f8                	cmp    %edi,%eax
  802662:	77 1c                	ja     802680 <__udivdi3+0x70>
  802664:	0f bd d0             	bsr    %eax,%edx
  802667:	83 f2 1f             	xor    $0x1f,%edx
  80266a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80266d:	75 39                	jne    8026a8 <__udivdi3+0x98>
  80266f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802672:	0f 86 a0 00 00 00    	jbe    802718 <__udivdi3+0x108>
  802678:	39 f8                	cmp    %edi,%eax
  80267a:	0f 82 98 00 00 00    	jb     802718 <__udivdi3+0x108>
  802680:	31 ff                	xor    %edi,%edi
  802682:	31 c9                	xor    %ecx,%ecx
  802684:	89 c8                	mov    %ecx,%eax
  802686:	89 fa                	mov    %edi,%edx
  802688:	83 c4 10             	add    $0x10,%esp
  80268b:	5e                   	pop    %esi
  80268c:	5f                   	pop    %edi
  80268d:	5d                   	pop    %ebp
  80268e:	c3                   	ret    
  80268f:	90                   	nop
  802690:	89 d1                	mov    %edx,%ecx
  802692:	89 fa                	mov    %edi,%edx
  802694:	89 c8                	mov    %ecx,%eax
  802696:	31 ff                	xor    %edi,%edi
  802698:	f7 f6                	div    %esi
  80269a:	89 c1                	mov    %eax,%ecx
  80269c:	89 fa                	mov    %edi,%edx
  80269e:	89 c8                	mov    %ecx,%eax
  8026a0:	83 c4 10             	add    $0x10,%esp
  8026a3:	5e                   	pop    %esi
  8026a4:	5f                   	pop    %edi
  8026a5:	5d                   	pop    %ebp
  8026a6:	c3                   	ret    
  8026a7:	90                   	nop
  8026a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026ac:	89 f2                	mov    %esi,%edx
  8026ae:	d3 e0                	shl    %cl,%eax
  8026b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8026bb:	89 c1                	mov    %eax,%ecx
  8026bd:	d3 ea                	shr    %cl,%edx
  8026bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8026c6:	d3 e6                	shl    %cl,%esi
  8026c8:	89 c1                	mov    %eax,%ecx
  8026ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8026cd:	89 fe                	mov    %edi,%esi
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026db:	d3 e7                	shl    %cl,%edi
  8026dd:	89 c1                	mov    %eax,%ecx
  8026df:	d3 ea                	shr    %cl,%edx
  8026e1:	09 d7                	or     %edx,%edi
  8026e3:	89 f2                	mov    %esi,%edx
  8026e5:	89 f8                	mov    %edi,%eax
  8026e7:	f7 75 ec             	divl   -0x14(%ebp)
  8026ea:	89 d6                	mov    %edx,%esi
  8026ec:	89 c7                	mov    %eax,%edi
  8026ee:	f7 65 e8             	mull   -0x18(%ebp)
  8026f1:	39 d6                	cmp    %edx,%esi
  8026f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026f6:	72 30                	jb     802728 <__udivdi3+0x118>
  8026f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026ff:	d3 e2                	shl    %cl,%edx
  802701:	39 c2                	cmp    %eax,%edx
  802703:	73 05                	jae    80270a <__udivdi3+0xfa>
  802705:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802708:	74 1e                	je     802728 <__udivdi3+0x118>
  80270a:	89 f9                	mov    %edi,%ecx
  80270c:	31 ff                	xor    %edi,%edi
  80270e:	e9 71 ff ff ff       	jmp    802684 <__udivdi3+0x74>
  802713:	90                   	nop
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	31 ff                	xor    %edi,%edi
  80271a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80271f:	e9 60 ff ff ff       	jmp    802684 <__udivdi3+0x74>
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80272b:	31 ff                	xor    %edi,%edi
  80272d:	89 c8                	mov    %ecx,%eax
  80272f:	89 fa                	mov    %edi,%edx
  802731:	83 c4 10             	add    $0x10,%esp
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
	...

00802740 <__umoddi3>:
  802740:	55                   	push   %ebp
  802741:	89 e5                	mov    %esp,%ebp
  802743:	57                   	push   %edi
  802744:	56                   	push   %esi
  802745:	83 ec 20             	sub    $0x20,%esp
  802748:	8b 55 14             	mov    0x14(%ebp),%edx
  80274b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80274e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802751:	8b 75 0c             	mov    0xc(%ebp),%esi
  802754:	85 d2                	test   %edx,%edx
  802756:	89 c8                	mov    %ecx,%eax
  802758:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80275b:	75 13                	jne    802770 <__umoddi3+0x30>
  80275d:	39 f7                	cmp    %esi,%edi
  80275f:	76 3f                	jbe    8027a0 <__umoddi3+0x60>
  802761:	89 f2                	mov    %esi,%edx
  802763:	f7 f7                	div    %edi
  802765:	89 d0                	mov    %edx,%eax
  802767:	31 d2                	xor    %edx,%edx
  802769:	83 c4 20             	add    $0x20,%esp
  80276c:	5e                   	pop    %esi
  80276d:	5f                   	pop    %edi
  80276e:	5d                   	pop    %ebp
  80276f:	c3                   	ret    
  802770:	39 f2                	cmp    %esi,%edx
  802772:	77 4c                	ja     8027c0 <__umoddi3+0x80>
  802774:	0f bd ca             	bsr    %edx,%ecx
  802777:	83 f1 1f             	xor    $0x1f,%ecx
  80277a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80277d:	75 51                	jne    8027d0 <__umoddi3+0x90>
  80277f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802782:	0f 87 e0 00 00 00    	ja     802868 <__umoddi3+0x128>
  802788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80278b:	29 f8                	sub    %edi,%eax
  80278d:	19 d6                	sbb    %edx,%esi
  80278f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802795:	89 f2                	mov    %esi,%edx
  802797:	83 c4 20             	add    $0x20,%esp
  80279a:	5e                   	pop    %esi
  80279b:	5f                   	pop    %edi
  80279c:	5d                   	pop    %ebp
  80279d:	c3                   	ret    
  80279e:	66 90                	xchg   %ax,%ax
  8027a0:	85 ff                	test   %edi,%edi
  8027a2:	75 0b                	jne    8027af <__umoddi3+0x6f>
  8027a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027a9:	31 d2                	xor    %edx,%edx
  8027ab:	f7 f7                	div    %edi
  8027ad:	89 c7                	mov    %eax,%edi
  8027af:	89 f0                	mov    %esi,%eax
  8027b1:	31 d2                	xor    %edx,%edx
  8027b3:	f7 f7                	div    %edi
  8027b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027b8:	f7 f7                	div    %edi
  8027ba:	eb a9                	jmp    802765 <__umoddi3+0x25>
  8027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	89 c8                	mov    %ecx,%eax
  8027c2:	89 f2                	mov    %esi,%edx
  8027c4:	83 c4 20             	add    $0x20,%esp
  8027c7:	5e                   	pop    %esi
  8027c8:	5f                   	pop    %edi
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    
  8027cb:	90                   	nop
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027d4:	d3 e2                	shl    %cl,%edx
  8027d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027e8:	89 fa                	mov    %edi,%edx
  8027ea:	d3 ea                	shr    %cl,%edx
  8027ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027f3:	d3 e7                	shl    %cl,%edi
  8027f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027fc:	89 f2                	mov    %esi,%edx
  8027fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802801:	89 c7                	mov    %eax,%edi
  802803:	d3 ea                	shr    %cl,%edx
  802805:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802809:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80280c:	89 c2                	mov    %eax,%edx
  80280e:	d3 e6                	shl    %cl,%esi
  802810:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802814:	d3 ea                	shr    %cl,%edx
  802816:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80281a:	09 d6                	or     %edx,%esi
  80281c:	89 f0                	mov    %esi,%eax
  80281e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802821:	d3 e7                	shl    %cl,%edi
  802823:	89 f2                	mov    %esi,%edx
  802825:	f7 75 f4             	divl   -0xc(%ebp)
  802828:	89 d6                	mov    %edx,%esi
  80282a:	f7 65 e8             	mull   -0x18(%ebp)
  80282d:	39 d6                	cmp    %edx,%esi
  80282f:	72 2b                	jb     80285c <__umoddi3+0x11c>
  802831:	39 c7                	cmp    %eax,%edi
  802833:	72 23                	jb     802858 <__umoddi3+0x118>
  802835:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802839:	29 c7                	sub    %eax,%edi
  80283b:	19 d6                	sbb    %edx,%esi
  80283d:	89 f0                	mov    %esi,%eax
  80283f:	89 f2                	mov    %esi,%edx
  802841:	d3 ef                	shr    %cl,%edi
  802843:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802847:	d3 e0                	shl    %cl,%eax
  802849:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80284d:	09 f8                	or     %edi,%eax
  80284f:	d3 ea                	shr    %cl,%edx
  802851:	83 c4 20             	add    $0x20,%esp
  802854:	5e                   	pop    %esi
  802855:	5f                   	pop    %edi
  802856:	5d                   	pop    %ebp
  802857:	c3                   	ret    
  802858:	39 d6                	cmp    %edx,%esi
  80285a:	75 d9                	jne    802835 <__umoddi3+0xf5>
  80285c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80285f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802862:	eb d1                	jmp    802835 <__umoddi3+0xf5>
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	39 f2                	cmp    %esi,%edx
  80286a:	0f 82 18 ff ff ff    	jb     802788 <__umoddi3+0x48>
  802870:	e9 1d ff ff ff       	jmp    802792 <__umoddi3+0x52>
