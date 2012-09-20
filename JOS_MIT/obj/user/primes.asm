
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
  800053:	e8 5c 16 00 00       	call   8016b4 <ipc_recv>
  800058:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80005a:	a1 08 50 80 00       	mov    0x805008,%eax
  80005f:	8b 40 5c             	mov    0x5c(%eax),%eax
  800062:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800066:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006a:	c7 04 24 a0 28 80 00 	movl   $0x8028a0,(%esp)
  800071:	e8 ff 01 00 00       	call   800275 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800076:	e8 57 11 00 00       	call   8011d2 <fork>
  80007b:	89 c7                	mov    %eax,%edi
  80007d:	85 c0                	test   %eax,%eax
  80007f:	79 20                	jns    8000a1 <primeproc+0x6d>
		panic("fork: %e", id);
  800081:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800085:	c7 44 24 08 b3 2c 80 	movl   $0x802cb3,0x8(%esp)
  80008c:	00 
  80008d:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800094:	00 
  800095:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
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
  8000bb:	e8 f4 15 00 00       	call   8016b4 <ipc_recv>
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
  8000e4:	e8 60 15 00 00       	call   801649 <ipc_send>
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
  800102:	c7 44 24 08 b3 2c 80 	movl   $0x802cb3,0x8(%esp)
  800109:	00 
  80010a:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800111:	00 
  800112:	c7 04 24 ac 28 80 00 	movl   $0x8028ac,(%esp)
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
  800143:	e8 01 15 00 00       	call   801649 <ipc_send>
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
  80016c:	c1 e0 07             	shl    $0x7,%eax
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
  8001a6:	e8 8e 1a 00 00       	call   801c39 <close_all>
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
  8001e8:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  8001ef:	e8 81 00 00 00       	call   800275 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fb:	89 04 24             	mov    %eax,(%esp)
  8001fe:	e8 11 00 00 00       	call   800214 <vcprintf>
	cprintf("\n");
  800203:	c7 04 24 7f 2f 80 00 	movl   $0x802f7f,(%esp)
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
  80035d:	e8 be 22 00 00       	call   802620 <__udivdi3>
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
  8003b8:	e8 93 23 00 00       	call   802750 <__umoddi3>
  8003bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c1:	0f be 80 e7 28 80 00 	movsbl 0x8028e7(%eax),%eax
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
  8004a5:	ff 24 95 c0 2a 80 00 	jmp    *0x802ac0(,%edx,4)
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
  800578:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  80057f:	85 d2                	test   %edx,%edx
  800581:	75 20                	jne    8005a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800583:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800587:	c7 44 24 08 f8 28 80 	movl   $0x8028f8,0x8(%esp)
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
  8005a7:	c7 44 24 08 b7 2f 80 	movl   $0x802fb7,0x8(%esp)
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
  8005e1:	b8 01 29 80 00       	mov    $0x802901,%eax
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
  800825:	c7 44 24 0c 1c 2a 80 	movl   $0x802a1c,0xc(%esp)
  80082c:	00 
  80082d:	c7 44 24 08 b7 2f 80 	movl   $0x802fb7,0x8(%esp)
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
  800853:	c7 44 24 0c 54 2a 80 	movl   $0x802a54,0xc(%esp)
  80085a:	00 
  80085b:	c7 44 24 08 b7 2f 80 	movl   $0x802fb7,0x8(%esp)
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
  800df7:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 7d 2c 80 00 	movl   $0x802c7d,(%esp)
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
  8011b6:	c7 44 24 08 8b 2c 80 	movl   $0x802c8b,0x8(%esp)
  8011bd:	00 
  8011be:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8011c5:	00 
  8011c6:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  8011e2:	e8 5d 13 00 00       	call   802544 <set_pgfault_handler>
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
  801213:	c7 44 24 04 a1 2c 80 	movl   $0x802ca1,0x4(%esp)
  80121a:	00 
  80121b:	c7 04 24 e8 2c 80 00 	movl   $0x802ce8,(%esp)
  801222:	e8 4e f0 ff ff       	call   800275 <cprintf>
	if (envidnum < 0)
  801227:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80122b:	79 23                	jns    801250 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80122d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801230:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801234:	c7 44 24 08 ac 2c 80 	movl   $0x802cac,0x8(%esp)
  80123b:	00 
  80123c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801243:	00 
  801244:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  80126f:	c1 e0 07             	shl    $0x7,%eax
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
  801303:	c7 44 24 08 10 2d 80 	movl   $0x802d10,0x8(%esp)
  80130a:	00 
  80130b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801312:	00 
  801313:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  801351:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  801358:	00 
  801359:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801360:	00 
  801361:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  801368:	e8 4f ee ff ff       	call   8001bc <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  80136d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801370:	89 44 24 08          	mov    %eax,0x8(%esp)
  801374:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
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
  8013b8:	c7 44 24 08 68 2d 80 	movl   $0x802d68,0x8(%esp)
  8013bf:	00 
  8013c0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8013c7:	00 
  8013c8:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  801409:	c7 44 24 08 94 2d 80 	movl   $0x802d94,0x8(%esp)
  801410:	00 
  801411:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801418:	00 
  801419:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  801420:	e8 97 ed ff ff       	call   8001bc <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801425:	c7 44 24 04 b4 25 80 	movl   $0x8025b4,0x4(%esp)
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
  801453:	c7 44 24 08 b8 2d 80 	movl   $0x802db8,0x8(%esp)
  80145a:	00 
  80145b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  801462:	00 
  801463:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80146a:	e8 4d ed ff ff       	call   8001bc <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80146f:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801476:	00 
  801477:	c7 44 24 04 a1 2c 80 	movl   $0x802ca1,0x4(%esp)
  80147e:	00 
  80147f:	c7 04 24 ce 2c 80 00 	movl   $0x802cce,(%esp)
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
  8014b9:	c7 44 24 08 e0 2d 80 	movl   $0x802de0,0x8(%esp)
  8014c0:	00 
  8014c1:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8014c8:	00 
  8014c9:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  8014f6:	c7 44 24 08 1c 2e 80 	movl   $0x802e1c,0x8(%esp)
  8014fd:	00 
  8014fe:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801505:	00 
  801506:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  801536:	c7 44 24 08 58 2e 80 	movl   $0x802e58,0x8(%esp)
  80153d:	00 
  80153e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801545:	00 
  801546:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  8015a0:	c7 44 24 08 80 2e 80 	movl   $0x802e80,0x8(%esp)
  8015a7:	00 
  8015a8:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8015af:	00 
  8015b0:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  8015d8:	c7 44 24 08 a4 2e 80 	movl   $0x802ea4,0x8(%esp)
  8015df:	00 
  8015e0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8015e7:	00 
  8015e8:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
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
  801617:	eb 11                	jmp    80162a <ipc_find_env+0x2a>
  801619:	89 c2                	mov    %eax,%edx
  80161b:	c1 e2 07             	shl    $0x7,%edx
  80161e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801624:	8b 12                	mov    (%edx),%edx
  801626:	39 ca                	cmp    %ecx,%edx
  801628:	75 0f                	jne    801639 <ipc_find_env+0x39>
			return envs[i].env_id;
  80162a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  80162e:	c1 e0 06             	shl    $0x6,%eax
  801631:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801637:	eb 0e                	jmp    801647 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801639:	83 c0 01             	add    $0x1,%eax
  80163c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801641:	75 d6                	jne    801619 <ipc_find_env+0x19>
  801643:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	57                   	push   %edi
  80164d:	56                   	push   %esi
  80164e:	53                   	push   %ebx
  80164f:	83 ec 1c             	sub    $0x1c,%esp
  801652:	8b 75 08             	mov    0x8(%ebp),%esi
  801655:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801658:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80165b:	85 db                	test   %ebx,%ebx
  80165d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801662:	0f 44 d8             	cmove  %eax,%ebx
  801665:	eb 25                	jmp    80168c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801667:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80166a:	74 20                	je     80168c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  80166c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801670:	c7 44 24 08 c8 2e 80 	movl   $0x802ec8,0x8(%esp)
  801677:	00 
  801678:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80167f:	00 
  801680:	c7 04 24 e6 2e 80 00 	movl   $0x802ee6,(%esp)
  801687:	e8 30 eb ff ff       	call   8001bc <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80168c:	8b 45 14             	mov    0x14(%ebp),%eax
  80168f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801693:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801697:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80169b:	89 34 24             	mov    %esi,(%esp)
  80169e:	e8 2b f8 ff ff       	call   800ece <sys_ipc_try_send>
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	75 c0                	jne    801667 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8016a7:	e8 a8 f9 ff ff       	call   801054 <sys_yield>
}
  8016ac:	83 c4 1c             	add    $0x1c,%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	83 ec 28             	sub    $0x28,%esp
  8016ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016c9:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8016d3:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8016d6:	89 04 24             	mov    %eax,(%esp)
  8016d9:	e8 b7 f7 ff ff       	call   800e95 <sys_ipc_recv>
  8016de:	89 c3                	mov    %eax,%ebx
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	79 2a                	jns    80170e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8016e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016ec:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  8016f3:	e8 7d eb ff ff       	call   800275 <cprintf>
		if(from_env_store != NULL)
  8016f8:	85 f6                	test   %esi,%esi
  8016fa:	74 06                	je     801702 <ipc_recv+0x4e>
			*from_env_store = 0;
  8016fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801702:	85 ff                	test   %edi,%edi
  801704:	74 2c                	je     801732 <ipc_recv+0x7e>
			*perm_store = 0;
  801706:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80170c:	eb 24                	jmp    801732 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80170e:	85 f6                	test   %esi,%esi
  801710:	74 0a                	je     80171c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801712:	a1 08 50 80 00       	mov    0x805008,%eax
  801717:	8b 40 74             	mov    0x74(%eax),%eax
  80171a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80171c:	85 ff                	test   %edi,%edi
  80171e:	74 0a                	je     80172a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801720:	a1 08 50 80 00       	mov    0x805008,%eax
  801725:	8b 40 78             	mov    0x78(%eax),%eax
  801728:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80172a:	a1 08 50 80 00       	mov    0x805008,%eax
  80172f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801732:	89 d8                	mov    %ebx,%eax
  801734:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801737:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80173a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80173d:	89 ec                	mov    %ebp,%esp
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    
	...

00801750 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	8b 45 08             	mov    0x8(%ebp),%eax
  801756:	05 00 00 00 30       	add    $0x30000000,%eax
  80175b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801766:	8b 45 08             	mov    0x8(%ebp),%eax
  801769:	89 04 24             	mov    %eax,(%esp)
  80176c:	e8 df ff ff ff       	call   801750 <fd2num>
  801771:	05 20 00 0d 00       	add    $0xd0020,%eax
  801776:	c1 e0 0c             	shl    $0xc,%eax
}
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	57                   	push   %edi
  80177f:	56                   	push   %esi
  801780:	53                   	push   %ebx
  801781:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801784:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801789:	a8 01                	test   $0x1,%al
  80178b:	74 36                	je     8017c3 <fd_alloc+0x48>
  80178d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801792:	a8 01                	test   $0x1,%al
  801794:	74 2d                	je     8017c3 <fd_alloc+0x48>
  801796:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80179b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8017a0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8017a5:	89 c3                	mov    %eax,%ebx
  8017a7:	89 c2                	mov    %eax,%edx
  8017a9:	c1 ea 16             	shr    $0x16,%edx
  8017ac:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8017af:	f6 c2 01             	test   $0x1,%dl
  8017b2:	74 14                	je     8017c8 <fd_alloc+0x4d>
  8017b4:	89 c2                	mov    %eax,%edx
  8017b6:	c1 ea 0c             	shr    $0xc,%edx
  8017b9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8017bc:	f6 c2 01             	test   $0x1,%dl
  8017bf:	75 10                	jne    8017d1 <fd_alloc+0x56>
  8017c1:	eb 05                	jmp    8017c8 <fd_alloc+0x4d>
  8017c3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8017c8:	89 1f                	mov    %ebx,(%edi)
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017cf:	eb 17                	jmp    8017e8 <fd_alloc+0x6d>
  8017d1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8017d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8017db:	75 c8                	jne    8017a5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8017dd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8017e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8017e8:	5b                   	pop    %ebx
  8017e9:	5e                   	pop    %esi
  8017ea:	5f                   	pop    %edi
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8017f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f3:	83 f8 1f             	cmp    $0x1f,%eax
  8017f6:	77 36                	ja     80182e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8017f8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8017fd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801800:	89 c2                	mov    %eax,%edx
  801802:	c1 ea 16             	shr    $0x16,%edx
  801805:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80180c:	f6 c2 01             	test   $0x1,%dl
  80180f:	74 1d                	je     80182e <fd_lookup+0x41>
  801811:	89 c2                	mov    %eax,%edx
  801813:	c1 ea 0c             	shr    $0xc,%edx
  801816:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80181d:	f6 c2 01             	test   $0x1,%dl
  801820:	74 0c                	je     80182e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801822:	8b 55 0c             	mov    0xc(%ebp),%edx
  801825:	89 02                	mov    %eax,(%edx)
  801827:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80182c:	eb 05                	jmp    801833 <fd_lookup+0x46>
  80182e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801833:	5d                   	pop    %ebp
  801834:	c3                   	ret    

00801835 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801835:	55                   	push   %ebp
  801836:	89 e5                	mov    %esp,%ebp
  801838:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80183b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80183e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	89 04 24             	mov    %eax,(%esp)
  801848:	e8 a0 ff ff ff       	call   8017ed <fd_lookup>
  80184d:	85 c0                	test   %eax,%eax
  80184f:	78 0e                	js     80185f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801851:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801854:	8b 55 0c             	mov    0xc(%ebp),%edx
  801857:	89 50 04             	mov    %edx,0x4(%eax)
  80185a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	83 ec 10             	sub    $0x10,%esp
  801869:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80186c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801874:	b8 04 40 80 00       	mov    $0x804004,%eax
  801879:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  80187f:	75 11                	jne    801892 <dev_lookup+0x31>
  801881:	eb 04                	jmp    801887 <dev_lookup+0x26>
  801883:	39 08                	cmp    %ecx,(%eax)
  801885:	75 10                	jne    801897 <dev_lookup+0x36>
			*dev = devtab[i];
  801887:	89 03                	mov    %eax,(%ebx)
  801889:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80188e:	66 90                	xchg   %ax,%ax
  801890:	eb 36                	jmp    8018c8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801892:	be 84 2f 80 00       	mov    $0x802f84,%esi
  801897:	83 c2 01             	add    $0x1,%edx
  80189a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80189d:	85 c0                	test   %eax,%eax
  80189f:	75 e2                	jne    801883 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8018a1:	a1 08 50 80 00       	mov    0x805008,%eax
  8018a6:	8b 40 48             	mov    0x48(%eax),%eax
  8018a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  8018b8:	e8 b8 e9 ff ff       	call   800275 <cprintf>
	*dev = 0;
  8018bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8018c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	5b                   	pop    %ebx
  8018cc:	5e                   	pop    %esi
  8018cd:	5d                   	pop    %ebp
  8018ce:	c3                   	ret    

008018cf <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	53                   	push   %ebx
  8018d3:	83 ec 24             	sub    $0x24,%esp
  8018d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e3:	89 04 24             	mov    %eax,(%esp)
  8018e6:	e8 02 ff ff ff       	call   8017ed <fd_lookup>
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 53                	js     801942 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018f9:	8b 00                	mov    (%eax),%eax
  8018fb:	89 04 24             	mov    %eax,(%esp)
  8018fe:	e8 5e ff ff ff       	call   801861 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801903:	85 c0                	test   %eax,%eax
  801905:	78 3b                	js     801942 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801907:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80190c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801913:	74 2d                	je     801942 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801915:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801918:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80191f:	00 00 00 
	stat->st_isdir = 0;
  801922:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801929:	00 00 00 
	stat->st_dev = dev;
  80192c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80192f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801935:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801939:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80193c:	89 14 24             	mov    %edx,(%esp)
  80193f:	ff 50 14             	call   *0x14(%eax)
}
  801942:	83 c4 24             	add    $0x24,%esp
  801945:	5b                   	pop    %ebx
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	53                   	push   %ebx
  80194c:	83 ec 24             	sub    $0x24,%esp
  80194f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801952:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801955:	89 44 24 04          	mov    %eax,0x4(%esp)
  801959:	89 1c 24             	mov    %ebx,(%esp)
  80195c:	e8 8c fe ff ff       	call   8017ed <fd_lookup>
  801961:	85 c0                	test   %eax,%eax
  801963:	78 5f                	js     8019c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801965:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801968:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196f:	8b 00                	mov    (%eax),%eax
  801971:	89 04 24             	mov    %eax,(%esp)
  801974:	e8 e8 fe ff ff       	call   801861 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 47                	js     8019c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80197d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801980:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801984:	75 23                	jne    8019a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801986:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80198b:	8b 40 48             	mov    0x48(%eax),%eax
  80198e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801992:	89 44 24 04          	mov    %eax,0x4(%esp)
  801996:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  80199d:	e8 d3 e8 ff ff       	call   800275 <cprintf>
  8019a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8019a7:	eb 1b                	jmp    8019c4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8019a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ac:	8b 48 18             	mov    0x18(%eax),%ecx
  8019af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b4:	85 c9                	test   %ecx,%ecx
  8019b6:	74 0c                	je     8019c4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8019b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bf:	89 14 24             	mov    %edx,(%esp)
  8019c2:	ff d1                	call   *%ecx
}
  8019c4:	83 c4 24             	add    $0x24,%esp
  8019c7:	5b                   	pop    %ebx
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    

008019ca <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8019ca:	55                   	push   %ebp
  8019cb:	89 e5                	mov    %esp,%ebp
  8019cd:	53                   	push   %ebx
  8019ce:	83 ec 24             	sub    $0x24,%esp
  8019d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019db:	89 1c 24             	mov    %ebx,(%esp)
  8019de:	e8 0a fe ff ff       	call   8017ed <fd_lookup>
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 66                	js     801a4d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019f1:	8b 00                	mov    (%eax),%eax
  8019f3:	89 04 24             	mov    %eax,(%esp)
  8019f6:	e8 66 fe ff ff       	call   801861 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	78 4e                	js     801a4d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8019ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a02:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801a06:	75 23                	jne    801a2b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801a08:	a1 08 50 80 00       	mov    0x805008,%eax
  801a0d:	8b 40 48             	mov    0x48(%eax),%eax
  801a10:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a18:	c7 04 24 48 2f 80 00 	movl   $0x802f48,(%esp)
  801a1f:	e8 51 e8 ff ff       	call   800275 <cprintf>
  801a24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a29:	eb 22                	jmp    801a4d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801a31:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a36:	85 c9                	test   %ecx,%ecx
  801a38:	74 13                	je     801a4d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801a3a:	8b 45 10             	mov    0x10(%ebp),%eax
  801a3d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a48:	89 14 24             	mov    %edx,(%esp)
  801a4b:	ff d1                	call   *%ecx
}
  801a4d:	83 c4 24             	add    $0x24,%esp
  801a50:	5b                   	pop    %ebx
  801a51:	5d                   	pop    %ebp
  801a52:	c3                   	ret    

00801a53 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801a53:	55                   	push   %ebp
  801a54:	89 e5                	mov    %esp,%ebp
  801a56:	53                   	push   %ebx
  801a57:	83 ec 24             	sub    $0x24,%esp
  801a5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a60:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a64:	89 1c 24             	mov    %ebx,(%esp)
  801a67:	e8 81 fd ff ff       	call   8017ed <fd_lookup>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 6b                	js     801adb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7a:	8b 00                	mov    (%eax),%eax
  801a7c:	89 04 24             	mov    %eax,(%esp)
  801a7f:	e8 dd fd ff ff       	call   801861 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 53                	js     801adb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a8b:	8b 42 08             	mov    0x8(%edx),%eax
  801a8e:	83 e0 03             	and    $0x3,%eax
  801a91:	83 f8 01             	cmp    $0x1,%eax
  801a94:	75 23                	jne    801ab9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a96:	a1 08 50 80 00       	mov    0x805008,%eax
  801a9b:	8b 40 48             	mov    0x48(%eax),%eax
  801a9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa6:	c7 04 24 65 2f 80 00 	movl   $0x802f65,(%esp)
  801aad:	e8 c3 e7 ff ff       	call   800275 <cprintf>
  801ab2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ab7:	eb 22                	jmp    801adb <read+0x88>
	}
	if (!dev->dev_read)
  801ab9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abc:	8b 48 08             	mov    0x8(%eax),%ecx
  801abf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ac4:	85 c9                	test   %ecx,%ecx
  801ac6:	74 13                	je     801adb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801ac8:	8b 45 10             	mov    0x10(%ebp),%eax
  801acb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801acf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad6:	89 14 24             	mov    %edx,(%esp)
  801ad9:	ff d1                	call   *%ecx
}
  801adb:	83 c4 24             	add    $0x24,%esp
  801ade:	5b                   	pop    %ebx
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	57                   	push   %edi
  801ae5:	56                   	push   %esi
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 1c             	sub    $0x1c,%esp
  801aea:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801af0:	ba 00 00 00 00       	mov    $0x0,%edx
  801af5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
  801aff:	85 f6                	test   %esi,%esi
  801b01:	74 29                	je     801b2c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801b03:	89 f0                	mov    %esi,%eax
  801b05:	29 d0                	sub    %edx,%eax
  801b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b0b:	03 55 0c             	add    0xc(%ebp),%edx
  801b0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b12:	89 3c 24             	mov    %edi,(%esp)
  801b15:	e8 39 ff ff ff       	call   801a53 <read>
		if (m < 0)
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 0e                	js     801b2c <readn+0x4b>
			return m;
		if (m == 0)
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	74 08                	je     801b2a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801b22:	01 c3                	add    %eax,%ebx
  801b24:	89 da                	mov    %ebx,%edx
  801b26:	39 f3                	cmp    %esi,%ebx
  801b28:	72 d9                	jb     801b03 <readn+0x22>
  801b2a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801b2c:	83 c4 1c             	add    $0x1c,%esp
  801b2f:	5b                   	pop    %ebx
  801b30:	5e                   	pop    %esi
  801b31:	5f                   	pop    %edi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	83 ec 28             	sub    $0x28,%esp
  801b3a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b3d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b40:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801b43:	89 34 24             	mov    %esi,(%esp)
  801b46:	e8 05 fc ff ff       	call   801750 <fd2num>
  801b4b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b52:	89 04 24             	mov    %eax,(%esp)
  801b55:	e8 93 fc ff ff       	call   8017ed <fd_lookup>
  801b5a:	89 c3                	mov    %eax,%ebx
  801b5c:	85 c0                	test   %eax,%eax
  801b5e:	78 05                	js     801b65 <fd_close+0x31>
  801b60:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801b63:	74 0e                	je     801b73 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801b65:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801b69:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6e:	0f 44 d8             	cmove  %eax,%ebx
  801b71:	eb 3d                	jmp    801bb0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b73:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7a:	8b 06                	mov    (%esi),%eax
  801b7c:	89 04 24             	mov    %eax,(%esp)
  801b7f:	e8 dd fc ff ff       	call   801861 <dev_lookup>
  801b84:	89 c3                	mov    %eax,%ebx
  801b86:	85 c0                	test   %eax,%eax
  801b88:	78 16                	js     801ba0 <fd_close+0x6c>
		if (dev->dev_close)
  801b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b8d:	8b 40 10             	mov    0x10(%eax),%eax
  801b90:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b95:	85 c0                	test   %eax,%eax
  801b97:	74 07                	je     801ba0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801b99:	89 34 24             	mov    %esi,(%esp)
  801b9c:	ff d0                	call   *%eax
  801b9e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ba0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ba4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bab:	e8 fc f3 ff ff       	call   800fac <sys_page_unmap>
	return r;
}
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bb5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bb8:	89 ec                	mov    %ebp,%esp
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	89 04 24             	mov    %eax,(%esp)
  801bcf:	e8 19 fc ff ff       	call   8017ed <fd_lookup>
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	78 13                	js     801beb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801bd8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801bdf:	00 
  801be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be3:	89 04 24             	mov    %eax,(%esp)
  801be6:	e8 49 ff ff ff       	call   801b34 <fd_close>
}
  801beb:	c9                   	leave  
  801bec:	c3                   	ret    

00801bed <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801bed:	55                   	push   %ebp
  801bee:	89 e5                	mov    %esp,%ebp
  801bf0:	83 ec 18             	sub    $0x18,%esp
  801bf3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bf6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801bf9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c00:	00 
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	89 04 24             	mov    %eax,(%esp)
  801c07:	e8 78 03 00 00       	call   801f84 <open>
  801c0c:	89 c3                	mov    %eax,%ebx
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	78 1b                	js     801c2d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801c12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c19:	89 1c 24             	mov    %ebx,(%esp)
  801c1c:	e8 ae fc ff ff       	call   8018cf <fstat>
  801c21:	89 c6                	mov    %eax,%esi
	close(fd);
  801c23:	89 1c 24             	mov    %ebx,(%esp)
  801c26:	e8 91 ff ff ff       	call   801bbc <close>
  801c2b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801c2d:	89 d8                	mov    %ebx,%eax
  801c2f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c32:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c35:	89 ec                	mov    %ebp,%esp
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    

00801c39 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801c39:	55                   	push   %ebp
  801c3a:	89 e5                	mov    %esp,%ebp
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 14             	sub    $0x14,%esp
  801c40:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801c45:	89 1c 24             	mov    %ebx,(%esp)
  801c48:	e8 6f ff ff ff       	call   801bbc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801c4d:	83 c3 01             	add    $0x1,%ebx
  801c50:	83 fb 20             	cmp    $0x20,%ebx
  801c53:	75 f0                	jne    801c45 <close_all+0xc>
		close(i);
}
  801c55:	83 c4 14             	add    $0x14,%esp
  801c58:	5b                   	pop    %ebx
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	83 ec 58             	sub    $0x58,%esp
  801c61:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c64:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c67:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c6a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801c6d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c70:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	89 04 24             	mov    %eax,(%esp)
  801c7a:	e8 6e fb ff ff       	call   8017ed <fd_lookup>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	85 c0                	test   %eax,%eax
  801c83:	0f 88 e0 00 00 00    	js     801d69 <dup+0x10e>
		return r;
	close(newfdnum);
  801c89:	89 3c 24             	mov    %edi,(%esp)
  801c8c:	e8 2b ff ff ff       	call   801bbc <close>

	newfd = INDEX2FD(newfdnum);
  801c91:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c97:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c9d:	89 04 24             	mov    %eax,(%esp)
  801ca0:	e8 bb fa ff ff       	call   801760 <fd2data>
  801ca5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801ca7:	89 34 24             	mov    %esi,(%esp)
  801caa:	e8 b1 fa ff ff       	call   801760 <fd2data>
  801caf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801cb2:	89 da                	mov    %ebx,%edx
  801cb4:	89 d8                	mov    %ebx,%eax
  801cb6:	c1 e8 16             	shr    $0x16,%eax
  801cb9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801cc0:	a8 01                	test   $0x1,%al
  801cc2:	74 43                	je     801d07 <dup+0xac>
  801cc4:	c1 ea 0c             	shr    $0xc,%edx
  801cc7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cce:	a8 01                	test   $0x1,%al
  801cd0:	74 35                	je     801d07 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801cd2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801cd9:	25 07 0e 00 00       	and    $0xe07,%eax
  801cde:	89 44 24 10          	mov    %eax,0x10(%esp)
  801ce2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ce5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ce9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cf0:	00 
  801cf1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cfc:	e8 e3 f2 ff ff       	call   800fe4 <sys_page_map>
  801d01:	89 c3                	mov    %eax,%ebx
  801d03:	85 c0                	test   %eax,%eax
  801d05:	78 3f                	js     801d46 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d0a:	89 c2                	mov    %eax,%edx
  801d0c:	c1 ea 0c             	shr    $0xc,%edx
  801d0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801d16:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801d1c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801d20:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801d24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d2b:	00 
  801d2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d37:	e8 a8 f2 ff ff       	call   800fe4 <sys_page_map>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 04                	js     801d46 <dup+0xeb>
  801d42:	89 fb                	mov    %edi,%ebx
  801d44:	eb 23                	jmp    801d69 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801d46:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d51:	e8 56 f2 ff ff       	call   800fac <sys_page_unmap>
	sys_page_unmap(0, nva);
  801d56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801d59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d64:	e8 43 f2 ff ff       	call   800fac <sys_page_unmap>
	return r;
}
  801d69:	89 d8                	mov    %ebx,%eax
  801d6b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801d6e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d74:	89 ec                	mov    %ebp,%esp
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    

00801d78 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d78:	55                   	push   %ebp
  801d79:	89 e5                	mov    %esp,%ebp
  801d7b:	83 ec 18             	sub    $0x18,%esp
  801d7e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d81:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d88:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d8f:	75 11                	jne    801da2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d91:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d98:	e8 63 f8 ff ff       	call   801600 <ipc_find_env>
  801d9d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801da2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801da9:	00 
  801daa:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801db1:	00 
  801db2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801db6:	a1 00 50 80 00       	mov    0x805000,%eax
  801dbb:	89 04 24             	mov    %eax,(%esp)
  801dbe:	e8 86 f8 ff ff       	call   801649 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801dc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dca:	00 
  801dcb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dcf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dd6:	e8 d9 f8 ff ff       	call   8016b4 <ipc_recv>
}
  801ddb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801dde:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801de1:	89 ec                	mov    %ebp,%esp
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    

00801de5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801deb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dee:	8b 40 0c             	mov    0xc(%eax),%eax
  801df1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801df6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df9:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  801e03:	b8 02 00 00 00       	mov    $0x2,%eax
  801e08:	e8 6b ff ff ff       	call   801d78 <fsipc>
}
  801e0d:	c9                   	leave  
  801e0e:	c3                   	ret    

00801e0f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801e15:	8b 45 08             	mov    0x8(%ebp),%eax
  801e18:	8b 40 0c             	mov    0xc(%eax),%eax
  801e1b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801e20:	ba 00 00 00 00       	mov    $0x0,%edx
  801e25:	b8 06 00 00 00       	mov    $0x6,%eax
  801e2a:	e8 49 ff ff ff       	call   801d78 <fsipc>
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    

00801e31 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801e37:	ba 00 00 00 00       	mov    $0x0,%edx
  801e3c:	b8 08 00 00 00       	mov    $0x8,%eax
  801e41:	e8 32 ff ff ff       	call   801d78 <fsipc>
}
  801e46:	c9                   	leave  
  801e47:	c3                   	ret    

00801e48 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	53                   	push   %ebx
  801e4c:	83 ec 14             	sub    $0x14,%esp
  801e4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801e52:	8b 45 08             	mov    0x8(%ebp),%eax
  801e55:	8b 40 0c             	mov    0xc(%eax),%eax
  801e58:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801e5d:	ba 00 00 00 00       	mov    $0x0,%edx
  801e62:	b8 05 00 00 00       	mov    $0x5,%eax
  801e67:	e8 0c ff ff ff       	call   801d78 <fsipc>
  801e6c:	85 c0                	test   %eax,%eax
  801e6e:	78 2b                	js     801e9b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e70:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e77:	00 
  801e78:	89 1c 24             	mov    %ebx,(%esp)
  801e7b:	e8 3a eb ff ff       	call   8009ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e80:	a1 80 60 80 00       	mov    0x806080,%eax
  801e85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e8b:	a1 84 60 80 00       	mov    0x806084,%eax
  801e90:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e96:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e9b:	83 c4 14             	add    $0x14,%esp
  801e9e:	5b                   	pop    %ebx
  801e9f:	5d                   	pop    %ebp
  801ea0:	c3                   	ret    

00801ea1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	83 ec 18             	sub    $0x18,%esp
  801ea7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801eaa:	8b 55 08             	mov    0x8(%ebp),%edx
  801ead:	8b 52 0c             	mov    0xc(%edx),%edx
  801eb0:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801eb6:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801ebb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ec0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ec5:	0f 47 c2             	cmova  %edx,%eax
  801ec8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ecf:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed3:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801eda:	e8 c6 ec ff ff       	call   800ba5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801edf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee4:	b8 04 00 00 00       	mov    $0x4,%eax
  801ee9:	e8 8a fe ff ff       	call   801d78 <fsipc>
}
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	53                   	push   %ebx
  801ef4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	8b 40 0c             	mov    0xc(%eax),%eax
  801efd:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801f02:	8b 45 10             	mov    0x10(%ebp),%eax
  801f05:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801f0a:	ba 00 00 00 00       	mov    $0x0,%edx
  801f0f:	b8 03 00 00 00       	mov    $0x3,%eax
  801f14:	e8 5f fe ff ff       	call   801d78 <fsipc>
  801f19:	89 c3                	mov    %eax,%ebx
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 17                	js     801f36 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801f1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f23:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f2a:	00 
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	89 04 24             	mov    %eax,(%esp)
  801f31:	e8 6f ec ff ff       	call   800ba5 <memmove>
  return r;	
}
  801f36:	89 d8                	mov    %ebx,%eax
  801f38:	83 c4 14             	add    $0x14,%esp
  801f3b:	5b                   	pop    %ebx
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    

00801f3e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	53                   	push   %ebx
  801f42:	83 ec 14             	sub    $0x14,%esp
  801f45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801f48:	89 1c 24             	mov    %ebx,(%esp)
  801f4b:	e8 20 ea ff ff       	call   800970 <strlen>
  801f50:	89 c2                	mov    %eax,%edx
  801f52:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801f57:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801f5d:	7f 1f                	jg     801f7e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801f5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f63:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f6a:	e8 4b ea ff ff       	call   8009ba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801f6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801f74:	b8 07 00 00 00       	mov    $0x7,%eax
  801f79:	e8 fa fd ff ff       	call   801d78 <fsipc>
}
  801f7e:	83 c4 14             	add    $0x14,%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 28             	sub    $0x28,%esp
  801f8a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f8d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f90:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f96:	89 04 24             	mov    %eax,(%esp)
  801f99:	e8 dd f7 ff ff       	call   80177b <fd_alloc>
  801f9e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	0f 88 89 00 00 00    	js     802031 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801fa8:	89 34 24             	mov    %esi,(%esp)
  801fab:	e8 c0 e9 ff ff       	call   800970 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801fb0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801fb5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801fba:	7f 75                	jg     802031 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801fbc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc0:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801fc7:	e8 ee e9 ff ff       	call   8009ba <strcpy>
  fsipcbuf.open.req_omode = mode;
  801fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcf:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801fd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fd7:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdc:	e8 97 fd ff ff       	call   801d78 <fsipc>
  801fe1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	78 0f                	js     801ff6 <open+0x72>
  return fd2num(fd);
  801fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fea:	89 04 24             	mov    %eax,(%esp)
  801fed:	e8 5e f7 ff ff       	call   801750 <fd2num>
  801ff2:	89 c3                	mov    %eax,%ebx
  801ff4:	eb 3b                	jmp    802031 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801ff6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801ffd:	00 
  801ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802001:	89 04 24             	mov    %eax,(%esp)
  802004:	e8 2b fb ff ff       	call   801b34 <fd_close>
  802009:	85 c0                	test   %eax,%eax
  80200b:	74 24                	je     802031 <open+0xad>
  80200d:	c7 44 24 0c 90 2f 80 	movl   $0x802f90,0xc(%esp)
  802014:	00 
  802015:	c7 44 24 08 a5 2f 80 	movl   $0x802fa5,0x8(%esp)
  80201c:	00 
  80201d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  802024:	00 
  802025:	c7 04 24 ba 2f 80 00 	movl   $0x802fba,(%esp)
  80202c:	e8 8b e1 ff ff       	call   8001bc <_panic>
  return r;
}
  802031:	89 d8                	mov    %ebx,%eax
  802033:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802036:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802039:	89 ec                	mov    %ebp,%esp
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    
  80203d:	00 00                	add    %al,(%eax)
	...

00802040 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802046:	c7 44 24 04 c5 2f 80 	movl   $0x802fc5,0x4(%esp)
  80204d:	00 
  80204e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 61 e9 ff ff       	call   8009ba <strcpy>
	return 0;
}
  802059:	b8 00 00 00 00       	mov    $0x0,%eax
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	53                   	push   %ebx
  802064:	83 ec 14             	sub    $0x14,%esp
  802067:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80206a:	89 1c 24             	mov    %ebx,(%esp)
  80206d:	e8 6a 05 00 00       	call   8025dc <pageref>
  802072:	89 c2                	mov    %eax,%edx
  802074:	b8 00 00 00 00       	mov    $0x0,%eax
  802079:	83 fa 01             	cmp    $0x1,%edx
  80207c:	75 0b                	jne    802089 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80207e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802081:	89 04 24             	mov    %eax,(%esp)
  802084:	e8 b9 02 00 00       	call   802342 <nsipc_close>
	else
		return 0;
}
  802089:	83 c4 14             	add    $0x14,%esp
  80208c:	5b                   	pop    %ebx
  80208d:	5d                   	pop    %ebp
  80208e:	c3                   	ret    

0080208f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80208f:	55                   	push   %ebp
  802090:	89 e5                	mov    %esp,%ebp
  802092:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802095:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80209c:	00 
  80209d:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8020b1:	89 04 24             	mov    %eax,(%esp)
  8020b4:	e8 c5 02 00 00       	call   80237e <nsipc_send>
}
  8020b9:	c9                   	leave  
  8020ba:	c3                   	ret    

008020bb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8020bb:	55                   	push   %ebp
  8020bc:	89 e5                	mov    %esp,%ebp
  8020be:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8020c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8020c8:	00 
  8020c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020da:	8b 40 0c             	mov    0xc(%eax),%eax
  8020dd:	89 04 24             	mov    %eax,(%esp)
  8020e0:	e8 0c 03 00 00       	call   8023f1 <nsipc_recv>
}
  8020e5:	c9                   	leave  
  8020e6:	c3                   	ret    

008020e7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8020e7:	55                   	push   %ebp
  8020e8:	89 e5                	mov    %esp,%ebp
  8020ea:	56                   	push   %esi
  8020eb:	53                   	push   %ebx
  8020ec:	83 ec 20             	sub    $0x20,%esp
  8020ef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020f4:	89 04 24             	mov    %eax,(%esp)
  8020f7:	e8 7f f6 ff ff       	call   80177b <fd_alloc>
  8020fc:	89 c3                	mov    %eax,%ebx
  8020fe:	85 c0                	test   %eax,%eax
  802100:	78 21                	js     802123 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802102:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802109:	00 
  80210a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80210d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802118:	e8 00 ef ff ff       	call   80101d <sys_page_alloc>
  80211d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80211f:	85 c0                	test   %eax,%eax
  802121:	79 0a                	jns    80212d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802123:	89 34 24             	mov    %esi,(%esp)
  802126:	e8 17 02 00 00       	call   802342 <nsipc_close>
		return r;
  80212b:	eb 28                	jmp    802155 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80212d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802133:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802136:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802145:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802148:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214b:	89 04 24             	mov    %eax,(%esp)
  80214e:	e8 fd f5 ff ff       	call   801750 <fd2num>
  802153:	89 c3                	mov    %eax,%ebx
}
  802155:	89 d8                	mov    %ebx,%eax
  802157:	83 c4 20             	add    $0x20,%esp
  80215a:	5b                   	pop    %ebx
  80215b:	5e                   	pop    %esi
  80215c:	5d                   	pop    %ebp
  80215d:	c3                   	ret    

0080215e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80215e:	55                   	push   %ebp
  80215f:	89 e5                	mov    %esp,%ebp
  802161:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802164:	8b 45 10             	mov    0x10(%ebp),%eax
  802167:	89 44 24 08          	mov    %eax,0x8(%esp)
  80216b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80216e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802172:	8b 45 08             	mov    0x8(%ebp),%eax
  802175:	89 04 24             	mov    %eax,(%esp)
  802178:	e8 79 01 00 00       	call   8022f6 <nsipc_socket>
  80217d:	85 c0                	test   %eax,%eax
  80217f:	78 05                	js     802186 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802181:	e8 61 ff ff ff       	call   8020e7 <alloc_sockfd>
}
  802186:	c9                   	leave  
  802187:	c3                   	ret    

00802188 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80218e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802191:	89 54 24 04          	mov    %edx,0x4(%esp)
  802195:	89 04 24             	mov    %eax,(%esp)
  802198:	e8 50 f6 ff ff       	call   8017ed <fd_lookup>
  80219d:	85 c0                	test   %eax,%eax
  80219f:	78 15                	js     8021b6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8021a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a4:	8b 0a                	mov    (%edx),%ecx
  8021a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8021ab:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8021b1:	75 03                	jne    8021b6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8021b3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021be:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c1:	e8 c2 ff ff ff       	call   802188 <fd2sockid>
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	78 0f                	js     8021d9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8021ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 47 01 00 00       	call   802320 <nsipc_listen>
}
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e4:	e8 9f ff ff ff       	call   802188 <fd2sockid>
  8021e9:	85 c0                	test   %eax,%eax
  8021eb:	78 16                	js     802203 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8021ed:	8b 55 10             	mov    0x10(%ebp),%edx
  8021f0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021fb:	89 04 24             	mov    %eax,(%esp)
  8021fe:	e8 6e 02 00 00       	call   802471 <nsipc_connect>
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80220b:	8b 45 08             	mov    0x8(%ebp),%eax
  80220e:	e8 75 ff ff ff       	call   802188 <fd2sockid>
  802213:	85 c0                	test   %eax,%eax
  802215:	78 0f                	js     802226 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802217:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80221e:	89 04 24             	mov    %eax,(%esp)
  802221:	e8 36 01 00 00       	call   80235c <nsipc_shutdown>
}
  802226:	c9                   	leave  
  802227:	c3                   	ret    

00802228 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802228:	55                   	push   %ebp
  802229:	89 e5                	mov    %esp,%ebp
  80222b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80222e:	8b 45 08             	mov    0x8(%ebp),%eax
  802231:	e8 52 ff ff ff       	call   802188 <fd2sockid>
  802236:	85 c0                	test   %eax,%eax
  802238:	78 16                	js     802250 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80223a:	8b 55 10             	mov    0x10(%ebp),%edx
  80223d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802241:	8b 55 0c             	mov    0xc(%ebp),%edx
  802244:	89 54 24 04          	mov    %edx,0x4(%esp)
  802248:	89 04 24             	mov    %eax,(%esp)
  80224b:	e8 60 02 00 00       	call   8024b0 <nsipc_bind>
}
  802250:	c9                   	leave  
  802251:	c3                   	ret    

00802252 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802252:	55                   	push   %ebp
  802253:	89 e5                	mov    %esp,%ebp
  802255:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802258:	8b 45 08             	mov    0x8(%ebp),%eax
  80225b:	e8 28 ff ff ff       	call   802188 <fd2sockid>
  802260:	85 c0                	test   %eax,%eax
  802262:	78 1f                	js     802283 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802264:	8b 55 10             	mov    0x10(%ebp),%edx
  802267:	89 54 24 08          	mov    %edx,0x8(%esp)
  80226b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80226e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802272:	89 04 24             	mov    %eax,(%esp)
  802275:	e8 75 02 00 00       	call   8024ef <nsipc_accept>
  80227a:	85 c0                	test   %eax,%eax
  80227c:	78 05                	js     802283 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80227e:	e8 64 fe ff ff       	call   8020e7 <alloc_sockfd>
}
  802283:	c9                   	leave  
  802284:	c3                   	ret    
	...

00802290 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802290:	55                   	push   %ebp
  802291:	89 e5                	mov    %esp,%ebp
  802293:	53                   	push   %ebx
  802294:	83 ec 14             	sub    $0x14,%esp
  802297:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802299:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  8022a0:	75 11                	jne    8022b3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8022a2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8022a9:	e8 52 f3 ff ff       	call   801600 <ipc_find_env>
  8022ae:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8022b3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8022ba:	00 
  8022bb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8022c2:	00 
  8022c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022c7:	a1 04 50 80 00       	mov    0x805004,%eax
  8022cc:	89 04 24             	mov    %eax,(%esp)
  8022cf:	e8 75 f3 ff ff       	call   801649 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8022d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8022db:	00 
  8022dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8022e3:	00 
  8022e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022eb:	e8 c4 f3 ff ff       	call   8016b4 <ipc_recv>
}
  8022f0:	83 c4 14             	add    $0x14,%esp
  8022f3:	5b                   	pop    %ebx
  8022f4:	5d                   	pop    %ebp
  8022f5:	c3                   	ret    

008022f6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8022f6:	55                   	push   %ebp
  8022f7:	89 e5                	mov    %esp,%ebp
  8022f9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8022fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802304:	8b 45 0c             	mov    0xc(%ebp),%eax
  802307:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80230c:	8b 45 10             	mov    0x10(%ebp),%eax
  80230f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802314:	b8 09 00 00 00       	mov    $0x9,%eax
  802319:	e8 72 ff ff ff       	call   802290 <nsipc>
}
  80231e:	c9                   	leave  
  80231f:	c3                   	ret    

00802320 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802320:	55                   	push   %ebp
  802321:	89 e5                	mov    %esp,%ebp
  802323:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802326:	8b 45 08             	mov    0x8(%ebp),%eax
  802329:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80232e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802331:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802336:	b8 06 00 00 00       	mov    $0x6,%eax
  80233b:	e8 50 ff ff ff       	call   802290 <nsipc>
}
  802340:	c9                   	leave  
  802341:	c3                   	ret    

00802342 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802342:	55                   	push   %ebp
  802343:	89 e5                	mov    %esp,%ebp
  802345:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802348:	8b 45 08             	mov    0x8(%ebp),%eax
  80234b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802350:	b8 04 00 00 00       	mov    $0x4,%eax
  802355:	e8 36 ff ff ff       	call   802290 <nsipc>
}
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802362:	8b 45 08             	mov    0x8(%ebp),%eax
  802365:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80236a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802372:	b8 03 00 00 00       	mov    $0x3,%eax
  802377:	e8 14 ff ff ff       	call   802290 <nsipc>
}
  80237c:	c9                   	leave  
  80237d:	c3                   	ret    

0080237e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	53                   	push   %ebx
  802382:	83 ec 14             	sub    $0x14,%esp
  802385:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802388:	8b 45 08             	mov    0x8(%ebp),%eax
  80238b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802390:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802396:	7e 24                	jle    8023bc <nsipc_send+0x3e>
  802398:	c7 44 24 0c d1 2f 80 	movl   $0x802fd1,0xc(%esp)
  80239f:	00 
  8023a0:	c7 44 24 08 a5 2f 80 	movl   $0x802fa5,0x8(%esp)
  8023a7:	00 
  8023a8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8023af:	00 
  8023b0:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  8023b7:	e8 00 de ff ff       	call   8001bc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8023bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023c7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8023ce:	e8 d2 e7 ff ff       	call   800ba5 <memmove>
	nsipcbuf.send.req_size = size;
  8023d3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8023d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8023dc:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8023e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8023e6:	e8 a5 fe ff ff       	call   802290 <nsipc>
}
  8023eb:	83 c4 14             	add    $0x14,%esp
  8023ee:	5b                   	pop    %ebx
  8023ef:	5d                   	pop    %ebp
  8023f0:	c3                   	ret    

008023f1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	56                   	push   %esi
  8023f5:	53                   	push   %ebx
  8023f6:	83 ec 10             	sub    $0x10,%esp
  8023f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8023fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802404:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80240a:	8b 45 14             	mov    0x14(%ebp),%eax
  80240d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802412:	b8 07 00 00 00       	mov    $0x7,%eax
  802417:	e8 74 fe ff ff       	call   802290 <nsipc>
  80241c:	89 c3                	mov    %eax,%ebx
  80241e:	85 c0                	test   %eax,%eax
  802420:	78 46                	js     802468 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802422:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802427:	7f 04                	jg     80242d <nsipc_recv+0x3c>
  802429:	39 c6                	cmp    %eax,%esi
  80242b:	7d 24                	jge    802451 <nsipc_recv+0x60>
  80242d:	c7 44 24 0c e9 2f 80 	movl   $0x802fe9,0xc(%esp)
  802434:	00 
  802435:	c7 44 24 08 a5 2f 80 	movl   $0x802fa5,0x8(%esp)
  80243c:	00 
  80243d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802444:	00 
  802445:	c7 04 24 dd 2f 80 00 	movl   $0x802fdd,(%esp)
  80244c:	e8 6b dd ff ff       	call   8001bc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802451:	89 44 24 08          	mov    %eax,0x8(%esp)
  802455:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80245c:	00 
  80245d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802460:	89 04 24             	mov    %eax,(%esp)
  802463:	e8 3d e7 ff ff       	call   800ba5 <memmove>
	}

	return r;
}
  802468:	89 d8                	mov    %ebx,%eax
  80246a:	83 c4 10             	add    $0x10,%esp
  80246d:	5b                   	pop    %ebx
  80246e:	5e                   	pop    %esi
  80246f:	5d                   	pop    %ebp
  802470:	c3                   	ret    

00802471 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802471:	55                   	push   %ebp
  802472:	89 e5                	mov    %esp,%ebp
  802474:	53                   	push   %ebx
  802475:	83 ec 14             	sub    $0x14,%esp
  802478:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80247b:	8b 45 08             	mov    0x8(%ebp),%eax
  80247e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802483:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802487:	8b 45 0c             	mov    0xc(%ebp),%eax
  80248a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80248e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802495:	e8 0b e7 ff ff       	call   800ba5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80249a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8024a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8024a5:	e8 e6 fd ff ff       	call   802290 <nsipc>
}
  8024aa:	83 c4 14             	add    $0x14,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5d                   	pop    %ebp
  8024af:	c3                   	ret    

008024b0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8024b0:	55                   	push   %ebp
  8024b1:	89 e5                	mov    %esp,%ebp
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 14             	sub    $0x14,%esp
  8024b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8024ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8024c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8024d4:	e8 cc e6 ff ff       	call   800ba5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8024d9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8024df:	b8 02 00 00 00       	mov    $0x2,%eax
  8024e4:	e8 a7 fd ff ff       	call   802290 <nsipc>
}
  8024e9:	83 c4 14             	add    $0x14,%esp
  8024ec:	5b                   	pop    %ebx
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    

008024ef <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8024ef:	55                   	push   %ebp
  8024f0:	89 e5                	mov    %esp,%ebp
  8024f2:	83 ec 18             	sub    $0x18,%esp
  8024f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8024f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8024fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fe:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802503:	b8 01 00 00 00       	mov    $0x1,%eax
  802508:	e8 83 fd ff ff       	call   802290 <nsipc>
  80250d:	89 c3                	mov    %eax,%ebx
  80250f:	85 c0                	test   %eax,%eax
  802511:	78 25                	js     802538 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802513:	be 10 70 80 00       	mov    $0x807010,%esi
  802518:	8b 06                	mov    (%esi),%eax
  80251a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80251e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802525:	00 
  802526:	8b 45 0c             	mov    0xc(%ebp),%eax
  802529:	89 04 24             	mov    %eax,(%esp)
  80252c:	e8 74 e6 ff ff       	call   800ba5 <memmove>
		*addrlen = ret->ret_addrlen;
  802531:	8b 16                	mov    (%esi),%edx
  802533:	8b 45 10             	mov    0x10(%ebp),%eax
  802536:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802538:	89 d8                	mov    %ebx,%eax
  80253a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80253d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802540:	89 ec                	mov    %ebp,%esp
  802542:	5d                   	pop    %ebp
  802543:	c3                   	ret    

00802544 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
  802547:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80254a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802551:	75 54                	jne    8025a7 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  802553:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80255a:	00 
  80255b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802562:	ee 
  802563:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80256a:	e8 ae ea ff ff       	call   80101d <sys_page_alloc>
  80256f:	85 c0                	test   %eax,%eax
  802571:	79 20                	jns    802593 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  802573:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802577:	c7 44 24 08 fe 2f 80 	movl   $0x802ffe,0x8(%esp)
  80257e:	00 
  80257f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802586:	00 
  802587:	c7 04 24 16 30 80 00 	movl   $0x803016,(%esp)
  80258e:	e8 29 dc ff ff       	call   8001bc <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  802593:	c7 44 24 04 b4 25 80 	movl   $0x8025b4,0x4(%esp)
  80259a:	00 
  80259b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8025a2:	e8 5d e9 ff ff       	call   800f04 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8025a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025aa:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8025af:	c9                   	leave  
  8025b0:	c3                   	ret    
  8025b1:	00 00                	add    %al,(%eax)
	...

008025b4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8025b4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8025b5:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8025ba:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025bc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8025bf:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8025c3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8025c6:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8025ca:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8025ce:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8025d0:	83 c4 08             	add    $0x8,%esp
	popal
  8025d3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8025d4:	83 c4 04             	add    $0x4,%esp
	popfl
  8025d7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8025d8:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8025d9:	c3                   	ret    
	...

008025dc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025dc:	55                   	push   %ebp
  8025dd:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8025df:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e2:	89 c2                	mov    %eax,%edx
  8025e4:	c1 ea 16             	shr    $0x16,%edx
  8025e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025ee:	f6 c2 01             	test   $0x1,%dl
  8025f1:	74 20                	je     802613 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025f3:	c1 e8 0c             	shr    $0xc,%eax
  8025f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025fd:	a8 01                	test   $0x1,%al
  8025ff:	74 12                	je     802613 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802601:	c1 e8 0c             	shr    $0xc,%eax
  802604:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802609:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80260e:	0f b7 c0             	movzwl %ax,%eax
  802611:	eb 05                	jmp    802618 <pageref+0x3c>
  802613:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802618:	5d                   	pop    %ebp
  802619:	c3                   	ret    
  80261a:	00 00                	add    %al,(%eax)
  80261c:	00 00                	add    %al,(%eax)
	...

00802620 <__udivdi3>:
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	57                   	push   %edi
  802624:	56                   	push   %esi
  802625:	83 ec 10             	sub    $0x10,%esp
  802628:	8b 45 14             	mov    0x14(%ebp),%eax
  80262b:	8b 55 08             	mov    0x8(%ebp),%edx
  80262e:	8b 75 10             	mov    0x10(%ebp),%esi
  802631:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802634:	85 c0                	test   %eax,%eax
  802636:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802639:	75 35                	jne    802670 <__udivdi3+0x50>
  80263b:	39 fe                	cmp    %edi,%esi
  80263d:	77 61                	ja     8026a0 <__udivdi3+0x80>
  80263f:	85 f6                	test   %esi,%esi
  802641:	75 0b                	jne    80264e <__udivdi3+0x2e>
  802643:	b8 01 00 00 00       	mov    $0x1,%eax
  802648:	31 d2                	xor    %edx,%edx
  80264a:	f7 f6                	div    %esi
  80264c:	89 c6                	mov    %eax,%esi
  80264e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802651:	31 d2                	xor    %edx,%edx
  802653:	89 f8                	mov    %edi,%eax
  802655:	f7 f6                	div    %esi
  802657:	89 c7                	mov    %eax,%edi
  802659:	89 c8                	mov    %ecx,%eax
  80265b:	f7 f6                	div    %esi
  80265d:	89 c1                	mov    %eax,%ecx
  80265f:	89 fa                	mov    %edi,%edx
  802661:	89 c8                	mov    %ecx,%eax
  802663:	83 c4 10             	add    $0x10,%esp
  802666:	5e                   	pop    %esi
  802667:	5f                   	pop    %edi
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    
  80266a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802670:	39 f8                	cmp    %edi,%eax
  802672:	77 1c                	ja     802690 <__udivdi3+0x70>
  802674:	0f bd d0             	bsr    %eax,%edx
  802677:	83 f2 1f             	xor    $0x1f,%edx
  80267a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80267d:	75 39                	jne    8026b8 <__udivdi3+0x98>
  80267f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802682:	0f 86 a0 00 00 00    	jbe    802728 <__udivdi3+0x108>
  802688:	39 f8                	cmp    %edi,%eax
  80268a:	0f 82 98 00 00 00    	jb     802728 <__udivdi3+0x108>
  802690:	31 ff                	xor    %edi,%edi
  802692:	31 c9                	xor    %ecx,%ecx
  802694:	89 c8                	mov    %ecx,%eax
  802696:	89 fa                	mov    %edi,%edx
  802698:	83 c4 10             	add    $0x10,%esp
  80269b:	5e                   	pop    %esi
  80269c:	5f                   	pop    %edi
  80269d:	5d                   	pop    %ebp
  80269e:	c3                   	ret    
  80269f:	90                   	nop
  8026a0:	89 d1                	mov    %edx,%ecx
  8026a2:	89 fa                	mov    %edi,%edx
  8026a4:	89 c8                	mov    %ecx,%eax
  8026a6:	31 ff                	xor    %edi,%edi
  8026a8:	f7 f6                	div    %esi
  8026aa:	89 c1                	mov    %eax,%ecx
  8026ac:	89 fa                	mov    %edi,%edx
  8026ae:	89 c8                	mov    %ecx,%eax
  8026b0:	83 c4 10             	add    $0x10,%esp
  8026b3:	5e                   	pop    %esi
  8026b4:	5f                   	pop    %edi
  8026b5:	5d                   	pop    %ebp
  8026b6:	c3                   	ret    
  8026b7:	90                   	nop
  8026b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026bc:	89 f2                	mov    %esi,%edx
  8026be:	d3 e0                	shl    %cl,%eax
  8026c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8026cb:	89 c1                	mov    %eax,%ecx
  8026cd:	d3 ea                	shr    %cl,%edx
  8026cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8026d6:	d3 e6                	shl    %cl,%esi
  8026d8:	89 c1                	mov    %eax,%ecx
  8026da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8026dd:	89 fe                	mov    %edi,%esi
  8026df:	d3 ee                	shr    %cl,%esi
  8026e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026eb:	d3 e7                	shl    %cl,%edi
  8026ed:	89 c1                	mov    %eax,%ecx
  8026ef:	d3 ea                	shr    %cl,%edx
  8026f1:	09 d7                	or     %edx,%edi
  8026f3:	89 f2                	mov    %esi,%edx
  8026f5:	89 f8                	mov    %edi,%eax
  8026f7:	f7 75 ec             	divl   -0x14(%ebp)
  8026fa:	89 d6                	mov    %edx,%esi
  8026fc:	89 c7                	mov    %eax,%edi
  8026fe:	f7 65 e8             	mull   -0x18(%ebp)
  802701:	39 d6                	cmp    %edx,%esi
  802703:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802706:	72 30                	jb     802738 <__udivdi3+0x118>
  802708:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80270b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80270f:	d3 e2                	shl    %cl,%edx
  802711:	39 c2                	cmp    %eax,%edx
  802713:	73 05                	jae    80271a <__udivdi3+0xfa>
  802715:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802718:	74 1e                	je     802738 <__udivdi3+0x118>
  80271a:	89 f9                	mov    %edi,%ecx
  80271c:	31 ff                	xor    %edi,%edi
  80271e:	e9 71 ff ff ff       	jmp    802694 <__udivdi3+0x74>
  802723:	90                   	nop
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	31 ff                	xor    %edi,%edi
  80272a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80272f:	e9 60 ff ff ff       	jmp    802694 <__udivdi3+0x74>
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80273b:	31 ff                	xor    %edi,%edi
  80273d:	89 c8                	mov    %ecx,%eax
  80273f:	89 fa                	mov    %edi,%edx
  802741:	83 c4 10             	add    $0x10,%esp
  802744:	5e                   	pop    %esi
  802745:	5f                   	pop    %edi
  802746:	5d                   	pop    %ebp
  802747:	c3                   	ret    
	...

00802750 <__umoddi3>:
  802750:	55                   	push   %ebp
  802751:	89 e5                	mov    %esp,%ebp
  802753:	57                   	push   %edi
  802754:	56                   	push   %esi
  802755:	83 ec 20             	sub    $0x20,%esp
  802758:	8b 55 14             	mov    0x14(%ebp),%edx
  80275b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80275e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802761:	8b 75 0c             	mov    0xc(%ebp),%esi
  802764:	85 d2                	test   %edx,%edx
  802766:	89 c8                	mov    %ecx,%eax
  802768:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80276b:	75 13                	jne    802780 <__umoddi3+0x30>
  80276d:	39 f7                	cmp    %esi,%edi
  80276f:	76 3f                	jbe    8027b0 <__umoddi3+0x60>
  802771:	89 f2                	mov    %esi,%edx
  802773:	f7 f7                	div    %edi
  802775:	89 d0                	mov    %edx,%eax
  802777:	31 d2                	xor    %edx,%edx
  802779:	83 c4 20             	add    $0x20,%esp
  80277c:	5e                   	pop    %esi
  80277d:	5f                   	pop    %edi
  80277e:	5d                   	pop    %ebp
  80277f:	c3                   	ret    
  802780:	39 f2                	cmp    %esi,%edx
  802782:	77 4c                	ja     8027d0 <__umoddi3+0x80>
  802784:	0f bd ca             	bsr    %edx,%ecx
  802787:	83 f1 1f             	xor    $0x1f,%ecx
  80278a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80278d:	75 51                	jne    8027e0 <__umoddi3+0x90>
  80278f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802792:	0f 87 e0 00 00 00    	ja     802878 <__umoddi3+0x128>
  802798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80279b:	29 f8                	sub    %edi,%eax
  80279d:	19 d6                	sbb    %edx,%esi
  80279f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8027a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a5:	89 f2                	mov    %esi,%edx
  8027a7:	83 c4 20             	add    $0x20,%esp
  8027aa:	5e                   	pop    %esi
  8027ab:	5f                   	pop    %edi
  8027ac:	5d                   	pop    %ebp
  8027ad:	c3                   	ret    
  8027ae:	66 90                	xchg   %ax,%ax
  8027b0:	85 ff                	test   %edi,%edi
  8027b2:	75 0b                	jne    8027bf <__umoddi3+0x6f>
  8027b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b9:	31 d2                	xor    %edx,%edx
  8027bb:	f7 f7                	div    %edi
  8027bd:	89 c7                	mov    %eax,%edi
  8027bf:	89 f0                	mov    %esi,%eax
  8027c1:	31 d2                	xor    %edx,%edx
  8027c3:	f7 f7                	div    %edi
  8027c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027c8:	f7 f7                	div    %edi
  8027ca:	eb a9                	jmp    802775 <__umoddi3+0x25>
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	83 c4 20             	add    $0x20,%esp
  8027d7:	5e                   	pop    %esi
  8027d8:	5f                   	pop    %edi
  8027d9:	5d                   	pop    %ebp
  8027da:	c3                   	ret    
  8027db:	90                   	nop
  8027dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027e4:	d3 e2                	shl    %cl,%edx
  8027e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027f8:	89 fa                	mov    %edi,%edx
  8027fa:	d3 ea                	shr    %cl,%edx
  8027fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802800:	0b 55 f4             	or     -0xc(%ebp),%edx
  802803:	d3 e7                	shl    %cl,%edi
  802805:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802809:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80280c:	89 f2                	mov    %esi,%edx
  80280e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802811:	89 c7                	mov    %eax,%edi
  802813:	d3 ea                	shr    %cl,%edx
  802815:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802819:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80281c:	89 c2                	mov    %eax,%edx
  80281e:	d3 e6                	shl    %cl,%esi
  802820:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802824:	d3 ea                	shr    %cl,%edx
  802826:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80282a:	09 d6                	or     %edx,%esi
  80282c:	89 f0                	mov    %esi,%eax
  80282e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802831:	d3 e7                	shl    %cl,%edi
  802833:	89 f2                	mov    %esi,%edx
  802835:	f7 75 f4             	divl   -0xc(%ebp)
  802838:	89 d6                	mov    %edx,%esi
  80283a:	f7 65 e8             	mull   -0x18(%ebp)
  80283d:	39 d6                	cmp    %edx,%esi
  80283f:	72 2b                	jb     80286c <__umoddi3+0x11c>
  802841:	39 c7                	cmp    %eax,%edi
  802843:	72 23                	jb     802868 <__umoddi3+0x118>
  802845:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802849:	29 c7                	sub    %eax,%edi
  80284b:	19 d6                	sbb    %edx,%esi
  80284d:	89 f0                	mov    %esi,%eax
  80284f:	89 f2                	mov    %esi,%edx
  802851:	d3 ef                	shr    %cl,%edi
  802853:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802857:	d3 e0                	shl    %cl,%eax
  802859:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80285d:	09 f8                	or     %edi,%eax
  80285f:	d3 ea                	shr    %cl,%edx
  802861:	83 c4 20             	add    $0x20,%esp
  802864:	5e                   	pop    %esi
  802865:	5f                   	pop    %edi
  802866:	5d                   	pop    %ebp
  802867:	c3                   	ret    
  802868:	39 d6                	cmp    %edx,%esi
  80286a:	75 d9                	jne    802845 <__umoddi3+0xf5>
  80286c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80286f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802872:	eb d1                	jmp    802845 <__umoddi3+0xf5>
  802874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802878:	39 f2                	cmp    %esi,%edx
  80287a:	0f 82 18 ff ff ff    	jb     802798 <__umoddi3+0x48>
  802880:	e9 1d ff ff ff       	jmp    8027a2 <__umoddi3+0x52>
