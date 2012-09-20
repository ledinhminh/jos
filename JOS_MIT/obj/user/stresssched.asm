
obj/user/stresssched.debug:     file format elf32-i386


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
  80002c:	e8 03 01 00 00       	call   800134 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 5a 10 00 00       	call   8010a7 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 59 11 00 00       	call   8011b2 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 1d                	jmp    800084 <umain+0x44>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 18                	je     800084 <umain+0x44>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	89 f0                	mov    %esi,%eax
  800074:	c1 e0 07             	shl    $0x7,%eax
  800077:	05 54 00 c0 ee       	add    $0xeec00054,%eax
  80007c:	8b 00                	mov    (%eax),%eax
  80007e:	85 c0                	test   %eax,%eax
  800080:	75 13                	jne    800095 <umain+0x55>
  800082:	eb 24                	jmp    8000a8 <umain+0x68>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800084:	e8 ab 0f 00 00       	call   801034 <sys_yield>
		return;
  800089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800090:	e9 95 00 00 00       	jmp    80012a <umain+0xea>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800095:	89 f2                	mov    %esi,%edx
  800097:	c1 e2 07             	shl    $0x7,%edx
  80009a:	81 c2 54 00 c0 ee    	add    $0xeec00054,%edx
		asm volatile("pause");
  8000a0:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  8000a2:	8b 02                	mov    (%edx),%eax
  8000a4:	85 c0                	test   %eax,%eax
  8000a6:	75 f8                	jne    8000a0 <umain+0x60>
  8000a8:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000ad:	be 00 00 00 00       	mov    $0x0,%esi
  8000b2:	e8 7d 0f 00 00       	call   801034 <sys_yield>
  8000b7:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000b9:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8000bf:	83 c2 01             	add    $0x1,%edx
  8000c2:	89 15 08 50 80 00    	mov    %edx,0x805008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000c8:	83 c0 01             	add    $0x1,%eax
  8000cb:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000d0:	75 e7                	jne    8000b9 <umain+0x79>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000d2:	83 c3 01             	add    $0x1,%ebx
  8000d5:	83 fb 0a             	cmp    $0xa,%ebx
  8000d8:	75 d8                	jne    8000b2 <umain+0x72>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000da:	a1 08 50 80 00       	mov    0x805008,%eax
  8000df:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000e4:	74 25                	je     80010b <umain+0xcb>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000e6:	a1 08 50 80 00       	mov    0x805008,%eax
  8000eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ef:	c7 44 24 08 80 28 80 	movl   $0x802880,0x8(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000fe:	00 
  8000ff:	c7 04 24 a8 28 80 00 	movl   $0x8028a8,(%esp)
  800106:	e8 95 00 00 00       	call   8001a0 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  80010b:	a1 0c 50 80 00       	mov    0x80500c,%eax
  800110:	8b 50 5c             	mov    0x5c(%eax),%edx
  800113:	8b 40 48             	mov    0x48(%eax),%eax
  800116:	89 54 24 08          	mov    %edx,0x8(%esp)
  80011a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011e:	c7 04 24 bb 28 80 00 	movl   $0x8028bb,(%esp)
  800125:	e8 2f 01 00 00       	call   800259 <cprintf>

}
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5d                   	pop    %ebp
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
  80013a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80013d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800140:	8b 75 08             	mov    0x8(%ebp),%esi
  800143:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800146:	e8 5c 0f 00 00       	call   8010a7 <sys_getenvid>
  80014b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800150:	c1 e0 07             	shl    $0x7,%eax
  800153:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800158:	a3 0c 50 80 00       	mov    %eax,0x80500c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015d:	85 f6                	test   %esi,%esi
  80015f:	7e 07                	jle    800168 <libmain+0x34>
		binaryname = argv[0];
  800161:	8b 03                	mov    (%ebx),%eax
  800163:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800168:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80016c:	89 34 24             	mov    %esi,(%esp)
  80016f:	e8 cc fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800174:	e8 0b 00 00 00       	call   800184 <exit>
}
  800179:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80017c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80017f:	89 ec                	mov    %ebp,%esp
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    
	...

00800184 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80018a:	e8 3a 19 00 00       	call   801ac9 <close_all>
	sys_env_destroy(0);
  80018f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800196:	e8 47 0f 00 00       	call   8010e2 <sys_env_destroy>
}
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    
  80019d:	00 00                	add    %al,(%eax)
	...

008001a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	56                   	push   %esi
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001a8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ab:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001b1:	e8 f1 0e 00 00       	call   8010a7 <sys_getenvid>
  8001b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cc:	c7 04 24 e4 28 80 00 	movl   $0x8028e4,(%esp)
  8001d3:	e8 81 00 00 00       	call   800259 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8001df:	89 04 24             	mov    %eax,(%esp)
  8001e2:	e8 11 00 00 00       	call   8001f8 <vcprintf>
	cprintf("\n");
  8001e7:	c7 04 24 d7 28 80 00 	movl   $0x8028d7,(%esp)
  8001ee:	e8 66 00 00 00       	call   800259 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001f3:	cc                   	int3   
  8001f4:	eb fd                	jmp    8001f3 <_panic+0x53>
	...

008001f8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800201:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800208:	00 00 00 
	b.cnt = 0;
  80020b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800212:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800215:	8b 45 0c             	mov    0xc(%ebp),%eax
  800218:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022d:	c7 04 24 73 02 80 00 	movl   $0x800273,(%esp)
  800234:	e8 d4 01 00 00       	call   80040d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800239:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80023f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800243:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800249:	89 04 24             	mov    %eax,(%esp)
  80024c:	e8 05 0f 00 00       	call   801156 <sys_cputs>

	return b.cnt;
}
  800251:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80025f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800262:	89 44 24 04          	mov    %eax,0x4(%esp)
  800266:	8b 45 08             	mov    0x8(%ebp),%eax
  800269:	89 04 24             	mov    %eax,(%esp)
  80026c:	e8 87 ff ff ff       	call   8001f8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800271:	c9                   	leave  
  800272:	c3                   	ret    

00800273 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	53                   	push   %ebx
  800277:	83 ec 14             	sub    $0x14,%esp
  80027a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027d:	8b 03                	mov    (%ebx),%eax
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800286:	83 c0 01             	add    $0x1,%eax
  800289:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80028b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800290:	75 19                	jne    8002ab <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800292:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800299:	00 
  80029a:	8d 43 08             	lea    0x8(%ebx),%eax
  80029d:	89 04 24             	mov    %eax,(%esp)
  8002a0:	e8 b1 0e 00 00       	call   801156 <sys_cputs>
		b->idx = 0;
  8002a5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002af:	83 c4 14             	add    $0x14,%esp
  8002b2:	5b                   	pop    %ebx
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    
	...

008002c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 4c             	sub    $0x4c,%esp
  8002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cc:	89 d6                	mov    %edx,%esi
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002da:	8b 45 10             	mov    0x10(%ebp),%eax
  8002dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002eb:	39 d1                	cmp    %edx,%ecx
  8002ed:	72 15                	jb     800304 <printnum+0x44>
  8002ef:	77 07                	ja     8002f8 <printnum+0x38>
  8002f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002f4:	39 d0                	cmp    %edx,%eax
  8002f6:	76 0c                	jbe    800304 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	8d 76 00             	lea    0x0(%esi),%esi
  800300:	7f 61                	jg     800363 <printnum+0xa3>
  800302:	eb 70                	jmp    800374 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800304:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800308:	83 eb 01             	sub    $0x1,%ebx
  80030b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80030f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800313:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800317:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80031b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80031e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800321:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800324:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800328:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032f:	00 
  800330:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800333:	89 04 24             	mov    %eax,(%esp)
  800336:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800339:	89 54 24 04          	mov    %edx,0x4(%esp)
  80033d:	e8 be 22 00 00       	call   802600 <__udivdi3>
  800342:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800345:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80034c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800350:	89 04 24             	mov    %eax,(%esp)
  800353:	89 54 24 04          	mov    %edx,0x4(%esp)
  800357:	89 f2                	mov    %esi,%edx
  800359:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80035c:	e8 5f ff ff ff       	call   8002c0 <printnum>
  800361:	eb 11                	jmp    800374 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800363:	89 74 24 04          	mov    %esi,0x4(%esp)
  800367:	89 3c 24             	mov    %edi,(%esp)
  80036a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80036d:	83 eb 01             	sub    $0x1,%ebx
  800370:	85 db                	test   %ebx,%ebx
  800372:	7f ef                	jg     800363 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800374:	89 74 24 04          	mov    %esi,0x4(%esp)
  800378:	8b 74 24 04          	mov    0x4(%esp),%esi
  80037c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80037f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800383:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038a:	00 
  80038b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80038e:	89 14 24             	mov    %edx,(%esp)
  800391:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800394:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800398:	e8 93 23 00 00       	call   802730 <__umoddi3>
  80039d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a1:	0f be 80 07 29 80 00 	movsbl 0x802907(%eax),%eax
  8003a8:	89 04 24             	mov    %eax,(%esp)
  8003ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ae:	83 c4 4c             	add    $0x4c,%esp
  8003b1:	5b                   	pop    %ebx
  8003b2:	5e                   	pop    %esi
  8003b3:	5f                   	pop    %edi
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003b9:	83 fa 01             	cmp    $0x1,%edx
  8003bc:	7e 0e                	jle    8003cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003c3:	89 08                	mov    %ecx,(%eax)
  8003c5:	8b 02                	mov    (%edx),%eax
  8003c7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ca:	eb 22                	jmp    8003ee <getuint+0x38>
	else if (lflag)
  8003cc:	85 d2                	test   %edx,%edx
  8003ce:	74 10                	je     8003e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003de:	eb 0e                	jmp    8003ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ff:	73 0a                	jae    80040b <sprintputch+0x1b>
		*b->buf++ = ch;
  800401:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800404:	88 0a                	mov    %cl,(%edx)
  800406:	83 c2 01             	add    $0x1,%edx
  800409:	89 10                	mov    %edx,(%eax)
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    

0080040d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	57                   	push   %edi
  800411:	56                   	push   %esi
  800412:	53                   	push   %ebx
  800413:	83 ec 5c             	sub    $0x5c,%esp
  800416:	8b 7d 08             	mov    0x8(%ebp),%edi
  800419:	8b 75 0c             	mov    0xc(%ebp),%esi
  80041c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80041f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800426:	eb 11                	jmp    800439 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800428:	85 c0                	test   %eax,%eax
  80042a:	0f 84 68 04 00 00    	je     800898 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800430:	89 74 24 04          	mov    %esi,0x4(%esp)
  800434:	89 04 24             	mov    %eax,(%esp)
  800437:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800439:	0f b6 03             	movzbl (%ebx),%eax
  80043c:	83 c3 01             	add    $0x1,%ebx
  80043f:	83 f8 25             	cmp    $0x25,%eax
  800442:	75 e4                	jne    800428 <vprintfmt+0x1b>
  800444:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80044b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800452:	b9 00 00 00 00       	mov    $0x0,%ecx
  800457:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80045b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800462:	eb 06                	jmp    80046a <vprintfmt+0x5d>
  800464:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800468:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	0f b6 13             	movzbl (%ebx),%edx
  80046d:	0f b6 c2             	movzbl %dl,%eax
  800470:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800473:	8d 43 01             	lea    0x1(%ebx),%eax
  800476:	83 ea 23             	sub    $0x23,%edx
  800479:	80 fa 55             	cmp    $0x55,%dl
  80047c:	0f 87 f9 03 00 00    	ja     80087b <vprintfmt+0x46e>
  800482:	0f b6 d2             	movzbl %dl,%edx
  800485:	ff 24 95 e0 2a 80 00 	jmp    *0x802ae0(,%edx,4)
  80048c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800490:	eb d6                	jmp    800468 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800492:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800495:	83 ea 30             	sub    $0x30,%edx
  800498:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80049b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80049e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004a1:	83 fb 09             	cmp    $0x9,%ebx
  8004a4:	77 54                	ja     8004fa <vprintfmt+0xed>
  8004a6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8004a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ac:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004af:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004b2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004b6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004bc:	83 fb 09             	cmp    $0x9,%ebx
  8004bf:	76 eb                	jbe    8004ac <vprintfmt+0x9f>
  8004c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004c7:	eb 31                	jmp    8004fa <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004cc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004d2:	8b 12                	mov    (%edx),%edx
  8004d4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004d7:	eb 21                	jmp    8004fa <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8004d9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8004e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e9:	e9 7a ff ff ff       	jmp    800468 <vprintfmt+0x5b>
  8004ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004f5:	e9 6e ff ff ff       	jmp    800468 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004fa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004fe:	0f 89 64 ff ff ff    	jns    800468 <vprintfmt+0x5b>
  800504:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800507:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80050a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80050d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800510:	e9 53 ff ff ff       	jmp    800468 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800515:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800518:	e9 4b ff ff ff       	jmp    800468 <vprintfmt+0x5b>
  80051d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 50 04             	lea    0x4(%eax),%edx
  800526:	89 55 14             	mov    %edx,0x14(%ebp)
  800529:	89 74 24 04          	mov    %esi,0x4(%esp)
  80052d:	8b 00                	mov    (%eax),%eax
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	ff d7                	call   *%edi
  800534:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800537:	e9 fd fe ff ff       	jmp    800439 <vprintfmt+0x2c>
  80053c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80053f:	8b 45 14             	mov    0x14(%ebp),%eax
  800542:	8d 50 04             	lea    0x4(%eax),%edx
  800545:	89 55 14             	mov    %edx,0x14(%ebp)
  800548:	8b 00                	mov    (%eax),%eax
  80054a:	89 c2                	mov    %eax,%edx
  80054c:	c1 fa 1f             	sar    $0x1f,%edx
  80054f:	31 d0                	xor    %edx,%eax
  800551:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800553:	83 f8 0f             	cmp    $0xf,%eax
  800556:	7f 0b                	jg     800563 <vprintfmt+0x156>
  800558:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  80055f:	85 d2                	test   %edx,%edx
  800561:	75 20                	jne    800583 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800563:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800567:	c7 44 24 08 18 29 80 	movl   $0x802918,0x8(%esp)
  80056e:	00 
  80056f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800573:	89 3c 24             	mov    %edi,(%esp)
  800576:	e8 a5 03 00 00       	call   800920 <printfmt>
  80057b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80057e:	e9 b6 fe ff ff       	jmp    800439 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800583:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800587:	c7 44 24 08 9b 2f 80 	movl   $0x802f9b,0x8(%esp)
  80058e:	00 
  80058f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800593:	89 3c 24             	mov    %edi,(%esp)
  800596:	e8 85 03 00 00       	call   800920 <printfmt>
  80059b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80059e:	e9 96 fe ff ff       	jmp    800439 <vprintfmt+0x2c>
  8005a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a6:	89 c3                	mov    %eax,%ebx
  8005a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8005ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 04             	lea    0x4(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 00                	mov    (%eax),%eax
  8005bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	b8 21 29 80 00       	mov    $0x802921,%eax
  8005c6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8005ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005cd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005d1:	7e 06                	jle    8005d9 <vprintfmt+0x1cc>
  8005d3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005d7:	75 13                	jne    8005ec <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005dc:	0f be 02             	movsbl (%edx),%eax
  8005df:	85 c0                	test   %eax,%eax
  8005e1:	0f 85 a2 00 00 00    	jne    800689 <vprintfmt+0x27c>
  8005e7:	e9 8f 00 00 00       	jmp    80067b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f3:	89 0c 24             	mov    %ecx,(%esp)
  8005f6:	e8 70 03 00 00       	call   80096b <strnlen>
  8005fb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005fe:	29 c2                	sub    %eax,%edx
  800600:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800603:	85 d2                	test   %edx,%edx
  800605:	7e d2                	jle    8005d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800607:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80060b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80060e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800611:	89 d3                	mov    %edx,%ebx
  800613:	89 74 24 04          	mov    %esi,0x4(%esp)
  800617:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061f:	83 eb 01             	sub    $0x1,%ebx
  800622:	85 db                	test   %ebx,%ebx
  800624:	7f ed                	jg     800613 <vprintfmt+0x206>
  800626:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800629:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800630:	eb a7                	jmp    8005d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800632:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800636:	74 1b                	je     800653 <vprintfmt+0x246>
  800638:	8d 50 e0             	lea    -0x20(%eax),%edx
  80063b:	83 fa 5e             	cmp    $0x5e,%edx
  80063e:	76 13                	jbe    800653 <vprintfmt+0x246>
					putch('?', putdat);
  800640:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800643:	89 54 24 04          	mov    %edx,0x4(%esp)
  800647:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800651:	eb 0d                	jmp    800660 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800653:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800656:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80065a:	89 04 24             	mov    %eax,(%esp)
  80065d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800660:	83 ef 01             	sub    $0x1,%edi
  800663:	0f be 03             	movsbl (%ebx),%eax
  800666:	85 c0                	test   %eax,%eax
  800668:	74 05                	je     80066f <vprintfmt+0x262>
  80066a:	83 c3 01             	add    $0x1,%ebx
  80066d:	eb 31                	jmp    8006a0 <vprintfmt+0x293>
  80066f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800672:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800675:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800678:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80067f:	7f 36                	jg     8006b7 <vprintfmt+0x2aa>
  800681:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800684:	e9 b0 fd ff ff       	jmp    800439 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800689:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068c:	83 c2 01             	add    $0x1,%edx
  80068f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800692:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800695:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800698:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80069b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80069e:	89 d3                	mov    %edx,%ebx
  8006a0:	85 f6                	test   %esi,%esi
  8006a2:	78 8e                	js     800632 <vprintfmt+0x225>
  8006a4:	83 ee 01             	sub    $0x1,%esi
  8006a7:	79 89                	jns    800632 <vprintfmt+0x225>
  8006a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006b2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006b5:	eb c4                	jmp    80067b <vprintfmt+0x26e>
  8006b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8006ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ca:	83 eb 01             	sub    $0x1,%ebx
  8006cd:	85 db                	test   %ebx,%ebx
  8006cf:	7f ec                	jg     8006bd <vprintfmt+0x2b0>
  8006d1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006d4:	e9 60 fd ff ff       	jmp    800439 <vprintfmt+0x2c>
  8006d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006dc:	83 f9 01             	cmp    $0x1,%ecx
  8006df:	7e 16                	jle    8006f7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8006e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e4:	8d 50 08             	lea    0x8(%eax),%edx
  8006e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ef:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f5:	eb 32                	jmp    800729 <vprintfmt+0x31c>
	else if (lflag)
  8006f7:	85 c9                	test   %ecx,%ecx
  8006f9:	74 18                	je     800713 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8d 50 04             	lea    0x4(%eax),%edx
  800701:	89 55 14             	mov    %edx,0x14(%ebp)
  800704:	8b 00                	mov    (%eax),%eax
  800706:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800709:	89 c1                	mov    %eax,%ecx
  80070b:	c1 f9 1f             	sar    $0x1f,%ecx
  80070e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800711:	eb 16                	jmp    800729 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8d 50 04             	lea    0x4(%eax),%edx
  800719:	89 55 14             	mov    %edx,0x14(%ebp)
  80071c:	8b 00                	mov    (%eax),%eax
  80071e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800721:	89 c2                	mov    %eax,%edx
  800723:	c1 fa 1f             	sar    $0x1f,%edx
  800726:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800729:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80072f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800734:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800738:	0f 89 8a 00 00 00    	jns    8007c8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80073e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800742:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800749:	ff d7                	call   *%edi
				num = -(long long) num;
  80074b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80074e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800751:	f7 d8                	neg    %eax
  800753:	83 d2 00             	adc    $0x0,%edx
  800756:	f7 da                	neg    %edx
  800758:	eb 6e                	jmp    8007c8 <vprintfmt+0x3bb>
  80075a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80075d:	89 ca                	mov    %ecx,%edx
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
  800762:	e8 4f fc ff ff       	call   8003b6 <getuint>
  800767:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80076c:	eb 5a                	jmp    8007c8 <vprintfmt+0x3bb>
  80076e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800771:	89 ca                	mov    %ecx,%edx
  800773:	8d 45 14             	lea    0x14(%ebp),%eax
  800776:	e8 3b fc ff ff       	call   8003b6 <getuint>
  80077b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800780:	eb 46                	jmp    8007c8 <vprintfmt+0x3bb>
  800782:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800785:	89 74 24 04          	mov    %esi,0x4(%esp)
  800789:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800790:	ff d7                	call   *%edi
			putch('x', putdat);
  800792:	89 74 24 04          	mov    %esi,0x4(%esp)
  800796:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80079d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 04             	lea    0x4(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a8:	8b 00                	mov    (%eax),%eax
  8007aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8007af:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007b4:	eb 12                	jmp    8007c8 <vprintfmt+0x3bb>
  8007b6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b9:	89 ca                	mov    %ecx,%edx
  8007bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007be:	e8 f3 fb ff ff       	call   8003b6 <getuint>
  8007c3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8007cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007d3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007db:	89 04 24             	mov    %eax,(%esp)
  8007de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007e2:	89 f2                	mov    %esi,%edx
  8007e4:	89 f8                	mov    %edi,%eax
  8007e6:	e8 d5 fa ff ff       	call   8002c0 <printnum>
  8007eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ee:	e9 46 fc ff ff       	jmp    800439 <vprintfmt+0x2c>
  8007f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8d 50 04             	lea    0x4(%eax),%edx
  8007fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ff:	8b 00                	mov    (%eax),%eax
  800801:	85 c0                	test   %eax,%eax
  800803:	75 24                	jne    800829 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800805:	c7 44 24 0c 3c 2a 80 	movl   $0x802a3c,0xc(%esp)
  80080c:	00 
  80080d:	c7 44 24 08 9b 2f 80 	movl   $0x802f9b,0x8(%esp)
  800814:	00 
  800815:	89 74 24 04          	mov    %esi,0x4(%esp)
  800819:	89 3c 24             	mov    %edi,(%esp)
  80081c:	e8 ff 00 00 00       	call   800920 <printfmt>
  800821:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800824:	e9 10 fc ff ff       	jmp    800439 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800829:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80082c:	7e 29                	jle    800857 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80082e:	0f b6 16             	movzbl (%esi),%edx
  800831:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800833:	c7 44 24 0c 74 2a 80 	movl   $0x802a74,0xc(%esp)
  80083a:	00 
  80083b:	c7 44 24 08 9b 2f 80 	movl   $0x802f9b,0x8(%esp)
  800842:	00 
  800843:	89 74 24 04          	mov    %esi,0x4(%esp)
  800847:	89 3c 24             	mov    %edi,(%esp)
  80084a:	e8 d1 00 00 00       	call   800920 <printfmt>
  80084f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800852:	e9 e2 fb ff ff       	jmp    800439 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800857:	0f b6 16             	movzbl (%esi),%edx
  80085a:	88 10                	mov    %dl,(%eax)
  80085c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80085f:	e9 d5 fb ff ff       	jmp    800439 <vprintfmt+0x2c>
  800864:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800867:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80086e:	89 14 24             	mov    %edx,(%esp)
  800871:	ff d7                	call   *%edi
  800873:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800876:	e9 be fb ff ff       	jmp    800439 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80087f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800886:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800888:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80088b:	80 38 25             	cmpb   $0x25,(%eax)
  80088e:	0f 84 a5 fb ff ff    	je     800439 <vprintfmt+0x2c>
  800894:	89 c3                	mov    %eax,%ebx
  800896:	eb f0                	jmp    800888 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800898:	83 c4 5c             	add    $0x5c,%esp
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5f                   	pop    %edi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 28             	sub    $0x28,%esp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	74 04                	je     8008b4 <vsnprintf+0x14>
  8008b0:	85 d2                	test   %edx,%edx
  8008b2:	7f 07                	jg     8008bb <vsnprintf+0x1b>
  8008b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b9:	eb 3b                	jmp    8008f6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008be:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	c7 04 24 f0 03 80 00 	movl   $0x8003f0,(%esp)
  8008e8:	e8 20 fb ff ff       	call   80040d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008fe:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800901:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800905:	8b 45 10             	mov    0x10(%ebp),%eax
  800908:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80090f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800913:	8b 45 08             	mov    0x8(%ebp),%eax
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	e8 82 ff ff ff       	call   8008a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80091e:	c9                   	leave  
  80091f:	c3                   	ret    

00800920 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800926:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800929:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092d:	8b 45 10             	mov    0x10(%ebp),%eax
  800930:	89 44 24 08          	mov    %eax,0x8(%esp)
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	89 44 24 04          	mov    %eax,0x4(%esp)
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	89 04 24             	mov    %eax,(%esp)
  800941:	e8 c7 fa ff ff       	call   80040d <vprintfmt>
	va_end(ap);
}
  800946:	c9                   	leave  
  800947:	c3                   	ret    
	...

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	80 3a 00             	cmpb   $0x0,(%edx)
  80095e:	74 09                	je     800969 <strlen+0x19>
		n++;
  800960:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800963:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800967:	75 f7                	jne    800960 <strlen+0x10>
		n++;
	return n;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800972:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800975:	85 c9                	test   %ecx,%ecx
  800977:	74 19                	je     800992 <strnlen+0x27>
  800979:	80 3b 00             	cmpb   $0x0,(%ebx)
  80097c:	74 14                	je     800992 <strnlen+0x27>
  80097e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800983:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800986:	39 c8                	cmp    %ecx,%eax
  800988:	74 0d                	je     800997 <strnlen+0x2c>
  80098a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80098e:	75 f3                	jne    800983 <strnlen+0x18>
  800990:	eb 05                	jmp    800997 <strnlen+0x2c>
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8009a4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8009ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8009b0:	83 c2 01             	add    $0x1,%edx
  8009b3:	84 c9                	test   %cl,%cl
  8009b5:	75 f2                	jne    8009a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009b7:	5b                   	pop    %ebx
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	53                   	push   %ebx
  8009be:	83 ec 08             	sub    $0x8,%esp
  8009c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c4:	89 1c 24             	mov    %ebx,(%esp)
  8009c7:	e8 84 ff ff ff       	call   800950 <strlen>
	strcpy(dst + len, src);
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009d3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009d6:	89 04 24             	mov    %eax,(%esp)
  8009d9:	e8 bc ff ff ff       	call   80099a <strcpy>
	return dst;
}
  8009de:	89 d8                	mov    %ebx,%eax
  8009e0:	83 c4 08             	add    $0x8,%esp
  8009e3:	5b                   	pop    %ebx
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f4:	85 f6                	test   %esi,%esi
  8009f6:	74 18                	je     800a10 <strncpy+0x2a>
  8009f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009fd:	0f b6 1a             	movzbl (%edx),%ebx
  800a00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a03:	80 3a 01             	cmpb   $0x1,(%edx)
  800a06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	39 ce                	cmp    %ecx,%esi
  800a0e:	77 ed                	ja     8009fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a10:	5b                   	pop    %ebx
  800a11:	5e                   	pop    %esi
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a22:	89 f0                	mov    %esi,%eax
  800a24:	85 c9                	test   %ecx,%ecx
  800a26:	74 27                	je     800a4f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a28:	83 e9 01             	sub    $0x1,%ecx
  800a2b:	74 1d                	je     800a4a <strlcpy+0x36>
  800a2d:	0f b6 1a             	movzbl (%edx),%ebx
  800a30:	84 db                	test   %bl,%bl
  800a32:	74 16                	je     800a4a <strlcpy+0x36>
			*dst++ = *src++;
  800a34:	88 18                	mov    %bl,(%eax)
  800a36:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a39:	83 e9 01             	sub    $0x1,%ecx
  800a3c:	74 0e                	je     800a4c <strlcpy+0x38>
			*dst++ = *src++;
  800a3e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a41:	0f b6 1a             	movzbl (%edx),%ebx
  800a44:	84 db                	test   %bl,%bl
  800a46:	75 ec                	jne    800a34 <strlcpy+0x20>
  800a48:	eb 02                	jmp    800a4c <strlcpy+0x38>
  800a4a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a4c:	c6 00 00             	movb   $0x0,(%eax)
  800a4f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a5e:	0f b6 01             	movzbl (%ecx),%eax
  800a61:	84 c0                	test   %al,%al
  800a63:	74 15                	je     800a7a <strcmp+0x25>
  800a65:	3a 02                	cmp    (%edx),%al
  800a67:	75 11                	jne    800a7a <strcmp+0x25>
		p++, q++;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a6f:	0f b6 01             	movzbl (%ecx),%eax
  800a72:	84 c0                	test   %al,%al
  800a74:	74 04                	je     800a7a <strcmp+0x25>
  800a76:	3a 02                	cmp    (%edx),%al
  800a78:	74 ef                	je     800a69 <strcmp+0x14>
  800a7a:	0f b6 c0             	movzbl %al,%eax
  800a7d:	0f b6 12             	movzbl (%edx),%edx
  800a80:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	53                   	push   %ebx
  800a88:	8b 55 08             	mov    0x8(%ebp),%edx
  800a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a8e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a91:	85 c0                	test   %eax,%eax
  800a93:	74 23                	je     800ab8 <strncmp+0x34>
  800a95:	0f b6 1a             	movzbl (%edx),%ebx
  800a98:	84 db                	test   %bl,%bl
  800a9a:	74 25                	je     800ac1 <strncmp+0x3d>
  800a9c:	3a 19                	cmp    (%ecx),%bl
  800a9e:	75 21                	jne    800ac1 <strncmp+0x3d>
  800aa0:	83 e8 01             	sub    $0x1,%eax
  800aa3:	74 13                	je     800ab8 <strncmp+0x34>
		n--, p++, q++;
  800aa5:	83 c2 01             	add    $0x1,%edx
  800aa8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aab:	0f b6 1a             	movzbl (%edx),%ebx
  800aae:	84 db                	test   %bl,%bl
  800ab0:	74 0f                	je     800ac1 <strncmp+0x3d>
  800ab2:	3a 19                	cmp    (%ecx),%bl
  800ab4:	74 ea                	je     800aa0 <strncmp+0x1c>
  800ab6:	eb 09                	jmp    800ac1 <strncmp+0x3d>
  800ab8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800abd:	5b                   	pop    %ebx
  800abe:	5d                   	pop    %ebp
  800abf:	90                   	nop
  800ac0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac1:	0f b6 02             	movzbl (%edx),%eax
  800ac4:	0f b6 11             	movzbl (%ecx),%edx
  800ac7:	29 d0                	sub    %edx,%eax
  800ac9:	eb f2                	jmp    800abd <strncmp+0x39>

00800acb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad5:	0f b6 10             	movzbl (%eax),%edx
  800ad8:	84 d2                	test   %dl,%dl
  800ada:	74 18                	je     800af4 <strchr+0x29>
		if (*s == c)
  800adc:	38 ca                	cmp    %cl,%dl
  800ade:	75 0a                	jne    800aea <strchr+0x1f>
  800ae0:	eb 17                	jmp    800af9 <strchr+0x2e>
  800ae2:	38 ca                	cmp    %cl,%dl
  800ae4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ae8:	74 0f                	je     800af9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	0f b6 10             	movzbl (%eax),%edx
  800af0:	84 d2                	test   %dl,%dl
  800af2:	75 ee                	jne    800ae2 <strchr+0x17>
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b05:	0f b6 10             	movzbl (%eax),%edx
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	74 18                	je     800b24 <strfind+0x29>
		if (*s == c)
  800b0c:	38 ca                	cmp    %cl,%dl
  800b0e:	75 0a                	jne    800b1a <strfind+0x1f>
  800b10:	eb 12                	jmp    800b24 <strfind+0x29>
  800b12:	38 ca                	cmp    %cl,%dl
  800b14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b18:	74 0a                	je     800b24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b1a:	83 c0 01             	add    $0x1,%eax
  800b1d:	0f b6 10             	movzbl (%eax),%edx
  800b20:	84 d2                	test   %dl,%dl
  800b22:	75 ee                	jne    800b12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	83 ec 0c             	sub    $0xc,%esp
  800b2c:	89 1c 24             	mov    %ebx,(%esp)
  800b2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b40:	85 c9                	test   %ecx,%ecx
  800b42:	74 30                	je     800b74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4a:	75 25                	jne    800b71 <memset+0x4b>
  800b4c:	f6 c1 03             	test   $0x3,%cl
  800b4f:	75 20                	jne    800b71 <memset+0x4b>
		c &= 0xFF;
  800b51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b54:	89 d3                	mov    %edx,%ebx
  800b56:	c1 e3 08             	shl    $0x8,%ebx
  800b59:	89 d6                	mov    %edx,%esi
  800b5b:	c1 e6 18             	shl    $0x18,%esi
  800b5e:	89 d0                	mov    %edx,%eax
  800b60:	c1 e0 10             	shl    $0x10,%eax
  800b63:	09 f0                	or     %esi,%eax
  800b65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b67:	09 d8                	or     %ebx,%eax
  800b69:	c1 e9 02             	shr    $0x2,%ecx
  800b6c:	fc                   	cld    
  800b6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b6f:	eb 03                	jmp    800b74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b71:	fc                   	cld    
  800b72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b74:	89 f8                	mov    %edi,%eax
  800b76:	8b 1c 24             	mov    (%esp),%ebx
  800b79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b81:	89 ec                	mov    %ebp,%esp
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 08             	sub    $0x8,%esp
  800b8b:	89 34 24             	mov    %esi,(%esp)
  800b8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b9d:	39 c6                	cmp    %eax,%esi
  800b9f:	73 35                	jae    800bd6 <memmove+0x51>
  800ba1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ba4:	39 d0                	cmp    %edx,%eax
  800ba6:	73 2e                	jae    800bd6 <memmove+0x51>
		s += n;
		d += n;
  800ba8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800baa:	f6 c2 03             	test   $0x3,%dl
  800bad:	75 1b                	jne    800bca <memmove+0x45>
  800baf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb5:	75 13                	jne    800bca <memmove+0x45>
  800bb7:	f6 c1 03             	test   $0x3,%cl
  800bba:	75 0e                	jne    800bca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800bbc:	83 ef 04             	sub    $0x4,%edi
  800bbf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
  800bc5:	fd                   	std    
  800bc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	eb 09                	jmp    800bd3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bca:	83 ef 01             	sub    $0x1,%edi
  800bcd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bd0:	fd                   	std    
  800bd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bd3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd4:	eb 20                	jmp    800bf6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bdc:	75 15                	jne    800bf3 <memmove+0x6e>
  800bde:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800be4:	75 0d                	jne    800bf3 <memmove+0x6e>
  800be6:	f6 c1 03             	test   $0x3,%cl
  800be9:	75 08                	jne    800bf3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800beb:	c1 e9 02             	shr    $0x2,%ecx
  800bee:	fc                   	cld    
  800bef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf1:	eb 03                	jmp    800bf6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf3:	fc                   	cld    
  800bf4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bf6:	8b 34 24             	mov    (%esp),%esi
  800bf9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bfd:	89 ec                	mov    %ebp,%esp
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c07:	8b 45 10             	mov    0x10(%ebp),%eax
  800c0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	89 04 24             	mov    %eax,(%esp)
  800c1b:	e8 65 ff ff ff       	call   800b85 <memmove>
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c31:	85 c9                	test   %ecx,%ecx
  800c33:	74 36                	je     800c6b <memcmp+0x49>
		if (*s1 != *s2)
  800c35:	0f b6 06             	movzbl (%esi),%eax
  800c38:	0f b6 1f             	movzbl (%edi),%ebx
  800c3b:	38 d8                	cmp    %bl,%al
  800c3d:	74 20                	je     800c5f <memcmp+0x3d>
  800c3f:	eb 14                	jmp    800c55 <memcmp+0x33>
  800c41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c4b:	83 c2 01             	add    $0x1,%edx
  800c4e:	83 e9 01             	sub    $0x1,%ecx
  800c51:	38 d8                	cmp    %bl,%al
  800c53:	74 12                	je     800c67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c55:	0f b6 c0             	movzbl %al,%eax
  800c58:	0f b6 db             	movzbl %bl,%ebx
  800c5b:	29 d8                	sub    %ebx,%eax
  800c5d:	eb 11                	jmp    800c70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c5f:	83 e9 01             	sub    $0x1,%ecx
  800c62:	ba 00 00 00 00       	mov    $0x0,%edx
  800c67:	85 c9                	test   %ecx,%ecx
  800c69:	75 d6                	jne    800c41 <memcmp+0x1f>
  800c6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5f                   	pop    %edi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c7b:	89 c2                	mov    %eax,%edx
  800c7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c80:	39 d0                	cmp    %edx,%eax
  800c82:	73 15                	jae    800c99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c88:	38 08                	cmp    %cl,(%eax)
  800c8a:	75 06                	jne    800c92 <memfind+0x1d>
  800c8c:	eb 0b                	jmp    800c99 <memfind+0x24>
  800c8e:	38 08                	cmp    %cl,(%eax)
  800c90:	74 07                	je     800c99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c92:	83 c0 01             	add    $0x1,%eax
  800c95:	39 c2                	cmp    %eax,%edx
  800c97:	77 f5                	ja     800c8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	57                   	push   %edi
  800c9f:	56                   	push   %esi
  800ca0:	53                   	push   %ebx
  800ca1:	83 ec 04             	sub    $0x4,%esp
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800caa:	0f b6 02             	movzbl (%edx),%eax
  800cad:	3c 20                	cmp    $0x20,%al
  800caf:	74 04                	je     800cb5 <strtol+0x1a>
  800cb1:	3c 09                	cmp    $0x9,%al
  800cb3:	75 0e                	jne    800cc3 <strtol+0x28>
		s++;
  800cb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cb8:	0f b6 02             	movzbl (%edx),%eax
  800cbb:	3c 20                	cmp    $0x20,%al
  800cbd:	74 f6                	je     800cb5 <strtol+0x1a>
  800cbf:	3c 09                	cmp    $0x9,%al
  800cc1:	74 f2                	je     800cb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cc3:	3c 2b                	cmp    $0x2b,%al
  800cc5:	75 0c                	jne    800cd3 <strtol+0x38>
		s++;
  800cc7:	83 c2 01             	add    $0x1,%edx
  800cca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cd1:	eb 15                	jmp    800ce8 <strtol+0x4d>
	else if (*s == '-')
  800cd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cda:	3c 2d                	cmp    $0x2d,%al
  800cdc:	75 0a                	jne    800ce8 <strtol+0x4d>
		s++, neg = 1;
  800cde:	83 c2 01             	add    $0x1,%edx
  800ce1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ce8:	85 db                	test   %ebx,%ebx
  800cea:	0f 94 c0             	sete   %al
  800ced:	74 05                	je     800cf4 <strtol+0x59>
  800cef:	83 fb 10             	cmp    $0x10,%ebx
  800cf2:	75 18                	jne    800d0c <strtol+0x71>
  800cf4:	80 3a 30             	cmpb   $0x30,(%edx)
  800cf7:	75 13                	jne    800d0c <strtol+0x71>
  800cf9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cfd:	8d 76 00             	lea    0x0(%esi),%esi
  800d00:	75 0a                	jne    800d0c <strtol+0x71>
		s += 2, base = 16;
  800d02:	83 c2 02             	add    $0x2,%edx
  800d05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d0a:	eb 15                	jmp    800d21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d0c:	84 c0                	test   %al,%al
  800d0e:	66 90                	xchg   %ax,%ax
  800d10:	74 0f                	je     800d21 <strtol+0x86>
  800d12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d17:	80 3a 30             	cmpb   $0x30,(%edx)
  800d1a:	75 05                	jne    800d21 <strtol+0x86>
		s++, base = 8;
  800d1c:	83 c2 01             	add    $0x1,%edx
  800d1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d21:	b8 00 00 00 00       	mov    $0x0,%eax
  800d26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d28:	0f b6 0a             	movzbl (%edx),%ecx
  800d2b:	89 cf                	mov    %ecx,%edi
  800d2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d30:	80 fb 09             	cmp    $0x9,%bl
  800d33:	77 08                	ja     800d3d <strtol+0xa2>
			dig = *s - '0';
  800d35:	0f be c9             	movsbl %cl,%ecx
  800d38:	83 e9 30             	sub    $0x30,%ecx
  800d3b:	eb 1e                	jmp    800d5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d40:	80 fb 19             	cmp    $0x19,%bl
  800d43:	77 08                	ja     800d4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d45:	0f be c9             	movsbl %cl,%ecx
  800d48:	83 e9 57             	sub    $0x57,%ecx
  800d4b:	eb 0e                	jmp    800d5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d50:	80 fb 19             	cmp    $0x19,%bl
  800d53:	77 15                	ja     800d6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d55:	0f be c9             	movsbl %cl,%ecx
  800d58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d5b:	39 f1                	cmp    %esi,%ecx
  800d5d:	7d 0b                	jge    800d6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d5f:	83 c2 01             	add    $0x1,%edx
  800d62:	0f af c6             	imul   %esi,%eax
  800d65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d68:	eb be                	jmp    800d28 <strtol+0x8d>
  800d6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d70:	74 05                	je     800d77 <strtol+0xdc>
		*endptr = (char *) s;
  800d72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d77:	89 ca                	mov    %ecx,%edx
  800d79:	f7 da                	neg    %edx
  800d7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d7f:	0f 45 c2             	cmovne %edx,%eax
}
  800d82:	83 c4 04             	add    $0x4,%esp
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    
	...

00800d8c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	83 ec 48             	sub    $0x48,%esp
  800d92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d98:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d9b:	89 c6                	mov    %eax,%esi
  800d9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800da0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800da2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800da5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800da8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dab:	51                   	push   %ecx
  800dac:	52                   	push   %edx
  800dad:	53                   	push   %ebx
  800dae:	54                   	push   %esp
  800daf:	55                   	push   %ebp
  800db0:	56                   	push   %esi
  800db1:	57                   	push   %edi
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	8d 35 bc 0d 80 00    	lea    0x800dbc,%esi
  800dba:	0f 34                	sysenter 

00800dbc <.after_sysenter_label>:
  800dbc:	5f                   	pop    %edi
  800dbd:	5e                   	pop    %esi
  800dbe:	5d                   	pop    %ebp
  800dbf:	5c                   	pop    %esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5a                   	pop    %edx
  800dc2:	59                   	pop    %ecx
  800dc3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800dc5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dc9:	74 28                	je     800df3 <.after_sysenter_label+0x37>
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7e 24                	jle    800df3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800dd7:	c7 44 24 08 80 2c 80 	movl   $0x802c80,0x8(%esp)
  800dde:	00 
  800ddf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800de6:	00 
  800de7:	c7 04 24 9d 2c 80 00 	movl   $0x802c9d,(%esp)
  800dee:	e8 ad f3 ff ff       	call   8001a0 <_panic>

	return ret;
}
  800df3:	89 d0                	mov    %edx,%eax
  800df5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfe:	89 ec                	mov    %ebp,%esp
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800e08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e0f:	00 
  800e10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e17:	00 
  800e18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e1f:	00 
  800e20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e23:	89 04 24             	mov    %eax,(%esp)
  800e26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e29:	ba 00 00 00 00       	mov    $0x0,%edx
  800e2e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e33:	e8 54 ff ff ff       	call   800d8c <syscall>
}
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    

00800e3a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800e3a:	55                   	push   %ebp
  800e3b:	89 e5                	mov    %esp,%ebp
  800e3d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800e40:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e47:	00 
  800e48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e4f:	00 
  800e50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e57:	00 
  800e58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e64:	ba 00 00 00 00       	mov    $0x0,%edx
  800e69:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e6e:	e8 19 ff ff ff       	call   800d8c <syscall>
}
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    

00800e75 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e7b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e82:	00 
  800e83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e92:	00 
  800e93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e9d:	ba 01 00 00 00       	mov    $0x1,%edx
  800ea2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea7:	e8 e0 fe ff ff       	call   800d8c <syscall>
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800eb4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ebb:	00 
  800ebc:	8b 45 14             	mov    0x14(%ebp),%eax
  800ebf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ec3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ecd:	89 04 24             	mov    %eax,(%esp)
  800ed0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800edd:	e8 aa fe ff ff       	call   800d8c <syscall>
}
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800f10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f15:	e8 72 fe ff ff       	call   800d8c <syscall>
}
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    

00800f1c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
  800f1f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800f48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f4d:	e8 3a fe ff ff       	call   800d8c <syscall>
}
  800f52:	c9                   	leave  
  800f53:	c3                   	ret    

00800f54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f54:	55                   	push   %ebp
  800f55:	89 e5                	mov    %esp,%ebp
  800f57:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f5a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f61:	00 
  800f62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f69:	00 
  800f6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f71:	00 
  800f72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f75:	89 04 24             	mov    %eax,(%esp)
  800f78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f80:	b8 09 00 00 00       	mov    $0x9,%eax
  800f85:	e8 02 fe ff ff       	call   800d8c <syscall>
}
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    

00800f8c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f8c:	55                   	push   %ebp
  800f8d:	89 e5                	mov    %esp,%ebp
  800f8f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f92:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f99:	00 
  800f9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fa1:	00 
  800fa2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa9:	00 
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	89 04 24             	mov    %eax,(%esp)
  800fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbd:	e8 ca fd ff ff       	call   800d8c <syscall>
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800fca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd1:	00 
  800fd2:	8b 45 18             	mov    0x18(%ebp),%eax
  800fd5:	0b 45 14             	or     0x14(%ebp),%eax
  800fd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe6:	89 04 24             	mov    %eax,(%esp)
  800fe9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fec:	ba 01 00 00 00       	mov    $0x1,%edx
  800ff1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ff6:	e8 91 fd ff ff       	call   800d8c <syscall>
}
  800ffb:	c9                   	leave  
  800ffc:	c3                   	ret    

00800ffd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801003:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80100a:	00 
  80100b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801012:	00 
  801013:	8b 45 10             	mov    0x10(%ebp),%eax
  801016:	89 44 24 04          	mov    %eax,0x4(%esp)
  80101a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101d:	89 04 24             	mov    %eax,(%esp)
  801020:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801023:	ba 01 00 00 00       	mov    $0x1,%edx
  801028:	b8 05 00 00 00       	mov    $0x5,%eax
  80102d:	e8 5a fd ff ff       	call   800d8c <syscall>
}
  801032:	c9                   	leave  
  801033:	c3                   	ret    

00801034 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80103a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801041:	00 
  801042:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801049:	00 
  80104a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801051:	00 
  801052:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801059:	b9 00 00 00 00       	mov    $0x0,%ecx
  80105e:	ba 00 00 00 00       	mov    $0x0,%edx
  801063:	b8 0c 00 00 00       	mov    $0xc,%eax
  801068:	e8 1f fd ff ff       	call   800d8c <syscall>
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801075:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80107c:	00 
  80107d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801084:	00 
  801085:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80108c:	00 
  80108d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801090:	89 04 24             	mov    %eax,(%esp)
  801093:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801096:	ba 00 00 00 00       	mov    $0x0,%edx
  80109b:	b8 04 00 00 00       	mov    $0x4,%eax
  8010a0:	e8 e7 fc ff ff       	call   800d8c <syscall>
}
  8010a5:	c9                   	leave  
  8010a6:	c3                   	ret    

008010a7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8010a7:	55                   	push   %ebp
  8010a8:	89 e5                	mov    %esp,%ebp
  8010aa:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8010ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010b4:	00 
  8010b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010bc:	00 
  8010bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010c4:	00 
  8010c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010db:	e8 ac fc ff ff       	call   800d8c <syscall>
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010ef:	00 
  8010f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010f7:	00 
  8010f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ff:	00 
  801100:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801107:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110a:	ba 01 00 00 00       	mov    $0x1,%edx
  80110f:	b8 03 00 00 00       	mov    $0x3,%eax
  801114:	e8 73 fc ff ff       	call   800d8c <syscall>
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801121:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801128:	00 
  801129:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801130:	00 
  801131:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801138:	00 
  801139:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801140:	b9 00 00 00 00       	mov    $0x0,%ecx
  801145:	ba 00 00 00 00       	mov    $0x0,%edx
  80114a:	b8 01 00 00 00       	mov    $0x1,%eax
  80114f:	e8 38 fc ff ff       	call   800d8c <syscall>
}
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80115c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801163:	00 
  801164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80116b:	00 
  80116c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801173:	00 
  801174:	8b 45 0c             	mov    0xc(%ebp),%eax
  801177:	89 04 24             	mov    %eax,(%esp)
  80117a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117d:	ba 00 00 00 00       	mov    $0x0,%edx
  801182:	b8 00 00 00 00       	mov    $0x0,%eax
  801187:	e8 00 fc ff ff       	call   800d8c <syscall>
}
  80118c:	c9                   	leave  
  80118d:	c3                   	ret    
	...

00801190 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801196:	c7 44 24 08 ab 2c 80 	movl   $0x802cab,0x8(%esp)
  80119d:	00 
  80119e:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8011a5:	00 
  8011a6:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  8011ad:	e8 ee ef ff ff       	call   8001a0 <_panic>

008011b2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011b2:	55                   	push   %ebp
  8011b3:	89 e5                	mov    %esp,%ebp
  8011b5:	57                   	push   %edi
  8011b6:	56                   	push   %esi
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  8011bb:	c7 04 24 76 14 80 00 	movl   $0x801476,(%esp)
  8011c2:	e8 0d 12 00 00       	call   8023d4 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  8011c7:	ba 08 00 00 00       	mov    $0x8,%edx
  8011cc:	89 d0                	mov    %edx,%eax
  8011ce:	51                   	push   %ecx
  8011cf:	52                   	push   %edx
  8011d0:	53                   	push   %ebx
  8011d1:	55                   	push   %ebp
  8011d2:	56                   	push   %esi
  8011d3:	57                   	push   %edi
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	8d 35 de 11 80 00    	lea    0x8011de,%esi
  8011dc:	0f 34                	sysenter 

008011de <.after_sysenter_label>:
  8011de:	5f                   	pop    %edi
  8011df:	5e                   	pop    %esi
  8011e0:	5d                   	pop    %ebp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5a                   	pop    %edx
  8011e3:	59                   	pop    %ecx
  8011e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  8011e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011eb:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  8011f2:	00 
  8011f3:	c7 44 24 04 c1 2c 80 	movl   $0x802cc1,0x4(%esp)
  8011fa:	00 
  8011fb:	c7 04 24 08 2d 80 00 	movl   $0x802d08,(%esp)
  801202:	e8 52 f0 ff ff       	call   800259 <cprintf>
	if (envidnum < 0)
  801207:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80120b:	79 23                	jns    801230 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80120d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801210:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801214:	c7 44 24 08 cc 2c 80 	movl   $0x802ccc,0x8(%esp)
  80121b:	00 
  80121c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801223:	00 
  801224:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  80122b:	e8 70 ef ff ff       	call   8001a0 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801230:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801235:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80123a:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80123f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801243:	75 1c                	jne    801261 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801245:	e8 5d fe ff ff       	call   8010a7 <sys_getenvid>
  80124a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80124f:	c1 e0 07             	shl    $0x7,%eax
  801252:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801257:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  80125c:	e9 0a 02 00 00       	jmp    80146b <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801261:	89 d8                	mov    %ebx,%eax
  801263:	c1 e8 16             	shr    $0x16,%eax
  801266:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801269:	a8 01                	test   $0x1,%al
  80126b:	0f 84 43 01 00 00    	je     8013b4 <.after_sysenter_label+0x1d6>
  801271:	89 d8                	mov    %ebx,%eax
  801273:	c1 e8 0c             	shr    $0xc,%eax
  801276:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	0f 84 32 01 00 00    	je     8013b4 <.after_sysenter_label+0x1d6>
  801282:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801285:	f6 c2 04             	test   $0x4,%dl
  801288:	0f 84 26 01 00 00    	je     8013b4 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  80128e:	c1 e0 0c             	shl    $0xc,%eax
  801291:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801294:	c1 e8 0c             	shr    $0xc,%eax
  801297:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  80129a:	89 c2                	mov    %eax,%edx
  80129c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  8012a2:	a9 02 08 00 00       	test   $0x802,%eax
  8012a7:	0f 84 a0 00 00 00    	je     80134d <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  8012ad:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  8012b0:	80 ce 08             	or     $0x8,%dh
  8012b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8012b6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012d6:	e8 e9 fc ff ff       	call   800fc4 <sys_page_map>
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	79 20                	jns    8012ff <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  8012df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012e3:	c7 44 24 08 30 2d 80 	movl   $0x802d30,0x8(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8012f2:	00 
  8012f3:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  8012fa:	e8 a1 ee ff ff       	call   8001a0 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  8012ff:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801302:	89 44 24 10          	mov    %eax,0x10(%esp)
  801306:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801309:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80130d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801314:	00 
  801315:	89 44 24 04          	mov    %eax,0x4(%esp)
  801319:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801320:	e8 9f fc ff ff       	call   800fc4 <sys_page_map>
  801325:	85 c0                	test   %eax,%eax
  801327:	0f 89 87 00 00 00    	jns    8013b4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  80132d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801331:	c7 44 24 08 5c 2d 80 	movl   $0x802d5c,0x8(%esp)
  801338:	00 
  801339:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801340:	00 
  801341:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  801348:	e8 53 ee ff ff       	call   8001a0 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  80134d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801350:	89 44 24 08          	mov    %eax,0x8(%esp)
  801354:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801357:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135b:	c7 04 24 dc 2c 80 00 	movl   $0x802cdc,(%esp)
  801362:	e8 f2 ee ff ff       	call   800259 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801367:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80136e:	00 
  80136f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801372:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801376:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801379:	89 44 24 08          	mov    %eax,0x8(%esp)
  80137d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801380:	89 44 24 04          	mov    %eax,0x4(%esp)
  801384:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80138b:	e8 34 fc ff ff       	call   800fc4 <sys_page_map>
  801390:	85 c0                	test   %eax,%eax
  801392:	79 20                	jns    8013b4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801394:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801398:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  80139f:	00 
  8013a0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8013a7:	00 
  8013a8:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  8013af:	e8 ec ed ff ff       	call   8001a0 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  8013b4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013ba:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8013c0:	0f 85 9b fe ff ff    	jne    801261 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8013c6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013cd:	00 
  8013ce:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013d5:	ee 
  8013d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d9:	89 04 24             	mov    %eax,(%esp)
  8013dc:	e8 1c fc ff ff       	call   800ffd <sys_page_alloc>
  8013e1:	85 c0                	test   %eax,%eax
  8013e3:	79 20                	jns    801405 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  8013e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e9:	c7 44 24 08 b4 2d 80 	movl   $0x802db4,0x8(%esp)
  8013f0:	00 
  8013f1:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8013f8:	00 
  8013f9:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  801400:	e8 9b ed ff ff       	call   8001a0 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801405:	c7 44 24 04 44 24 80 	movl   $0x802444,0x4(%esp)
  80140c:	00 
  80140d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801410:	89 04 24             	mov    %eax,(%esp)
  801413:	e8 cc fa ff ff       	call   800ee4 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801418:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80141f:	00 
  801420:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801423:	89 04 24             	mov    %eax,(%esp)
  801426:	e8 29 fb ff ff       	call   800f54 <sys_env_set_status>
  80142b:	85 c0                	test   %eax,%eax
  80142d:	79 20                	jns    80144f <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80142f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801433:	c7 44 24 08 d8 2d 80 	movl   $0x802dd8,0x8(%esp)
  80143a:	00 
  80143b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  801442:	00 
  801443:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  80144a:	e8 51 ed ff ff       	call   8001a0 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80144f:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801456:	00 
  801457:	c7 44 24 04 c1 2c 80 	movl   $0x802cc1,0x4(%esp)
  80145e:	00 
  80145f:	c7 04 24 ee 2c 80 00 	movl   $0x802cee,(%esp)
  801466:	e8 ee ed ff ff       	call   800259 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  80146b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80146e:	83 c4 3c             	add    $0x3c,%esp
  801471:	5b                   	pop    %ebx
  801472:	5e                   	pop    %esi
  801473:	5f                   	pop    %edi
  801474:	5d                   	pop    %ebp
  801475:	c3                   	ret    

00801476 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	53                   	push   %ebx
  80147a:	83 ec 24             	sub    $0x24,%esp
  80147d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801480:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801482:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801485:	f6 c2 02             	test   $0x2,%dl
  801488:	75 2b                	jne    8014b5 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  80148a:	8b 40 28             	mov    0x28(%eax),%eax
  80148d:	89 44 24 14          	mov    %eax,0x14(%esp)
  801491:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801495:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801499:	c7 44 24 08 00 2e 80 	movl   $0x802e00,0x8(%esp)
  8014a0:	00 
  8014a1:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8014a8:	00 
  8014a9:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  8014b0:	e8 eb ec ff ff       	call   8001a0 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  8014b5:	89 d8                	mov    %ebx,%eax
  8014b7:	c1 e8 16             	shr    $0x16,%eax
  8014ba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c1:	a8 01                	test   $0x1,%al
  8014c3:	74 11                	je     8014d6 <pgfault+0x60>
  8014c5:	89 d8                	mov    %ebx,%eax
  8014c7:	c1 e8 0c             	shr    $0xc,%eax
  8014ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d1:	f6 c4 08             	test   $0x8,%ah
  8014d4:	75 1c                	jne    8014f2 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  8014d6:	c7 44 24 08 3c 2e 80 	movl   $0x802e3c,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  8014ed:	e8 ae ec ff ff       	call   8001a0 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8014f2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014f9:	00 
  8014fa:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801501:	00 
  801502:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801509:	e8 ef fa ff ff       	call   800ffd <sys_page_alloc>
  80150e:	85 c0                	test   %eax,%eax
  801510:	79 20                	jns    801532 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  801512:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801516:	c7 44 24 08 78 2e 80 	movl   $0x802e78,0x8(%esp)
  80151d:	00 
  80151e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801525:	00 
  801526:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  80152d:	e8 6e ec ff ff       	call   8001a0 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801532:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  801538:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80153f:	00 
  801540:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801544:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80154b:	e8 35 f6 ff ff       	call   800b85 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801550:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801557:	00 
  801558:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80155c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801563:	00 
  801564:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80156b:	00 
  80156c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801573:	e8 4c fa ff ff       	call   800fc4 <sys_page_map>
  801578:	85 c0                	test   %eax,%eax
  80157a:	79 20                	jns    80159c <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  80157c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801580:	c7 44 24 08 a0 2e 80 	movl   $0x802ea0,0x8(%esp)
  801587:	00 
  801588:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80158f:	00 
  801590:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  801597:	e8 04 ec ff ff       	call   8001a0 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  80159c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8015a3:	00 
  8015a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ab:	e8 dc f9 ff ff       	call   800f8c <sys_page_unmap>
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	79 20                	jns    8015d4 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  8015b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015b8:	c7 44 24 08 c4 2e 80 	movl   $0x802ec4,0x8(%esp)
  8015bf:	00 
  8015c0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8015c7:	00 
  8015c8:	c7 04 24 c1 2c 80 00 	movl   $0x802cc1,(%esp)
  8015cf:	e8 cc eb ff ff       	call   8001a0 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  8015d4:	83 c4 24             	add    $0x24,%esp
  8015d7:	5b                   	pop    %ebx
  8015d8:	5d                   	pop    %ebp
  8015d9:	c3                   	ret    
  8015da:	00 00                	add    %al,(%eax)
  8015dc:	00 00                	add    %al,(%eax)
	...

008015e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f9:	89 04 24             	mov    %eax,(%esp)
  8015fc:	e8 df ff ff ff       	call   8015e0 <fd2num>
  801601:	05 20 00 0d 00       	add    $0xd0020,%eax
  801606:	c1 e0 0c             	shl    $0xc,%eax
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	57                   	push   %edi
  80160f:	56                   	push   %esi
  801610:	53                   	push   %ebx
  801611:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801614:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801619:	a8 01                	test   $0x1,%al
  80161b:	74 36                	je     801653 <fd_alloc+0x48>
  80161d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801622:	a8 01                	test   $0x1,%al
  801624:	74 2d                	je     801653 <fd_alloc+0x48>
  801626:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80162b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801630:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801635:	89 c3                	mov    %eax,%ebx
  801637:	89 c2                	mov    %eax,%edx
  801639:	c1 ea 16             	shr    $0x16,%edx
  80163c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80163f:	f6 c2 01             	test   $0x1,%dl
  801642:	74 14                	je     801658 <fd_alloc+0x4d>
  801644:	89 c2                	mov    %eax,%edx
  801646:	c1 ea 0c             	shr    $0xc,%edx
  801649:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80164c:	f6 c2 01             	test   $0x1,%dl
  80164f:	75 10                	jne    801661 <fd_alloc+0x56>
  801651:	eb 05                	jmp    801658 <fd_alloc+0x4d>
  801653:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801658:	89 1f                	mov    %ebx,(%edi)
  80165a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80165f:	eb 17                	jmp    801678 <fd_alloc+0x6d>
  801661:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801666:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80166b:	75 c8                	jne    801635 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80166d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801673:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5f                   	pop    %edi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	83 f8 1f             	cmp    $0x1f,%eax
  801686:	77 36                	ja     8016be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801688:	05 00 00 0d 00       	add    $0xd0000,%eax
  80168d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801690:	89 c2                	mov    %eax,%edx
  801692:	c1 ea 16             	shr    $0x16,%edx
  801695:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80169c:	f6 c2 01             	test   $0x1,%dl
  80169f:	74 1d                	je     8016be <fd_lookup+0x41>
  8016a1:	89 c2                	mov    %eax,%edx
  8016a3:	c1 ea 0c             	shr    $0xc,%edx
  8016a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016ad:	f6 c2 01             	test   $0x1,%dl
  8016b0:	74 0c                	je     8016be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016b5:	89 02                	mov    %eax,(%edx)
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8016bc:	eb 05                	jmp    8016c3 <fd_lookup+0x46>
  8016be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d5:	89 04 24             	mov    %eax,(%esp)
  8016d8:	e8 a0 ff ff ff       	call   80167d <fd_lookup>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	78 0e                	js     8016ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e7:	89 50 04             	mov    %edx,0x4(%eax)
  8016ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016f1:	55                   	push   %ebp
  8016f2:	89 e5                	mov    %esp,%ebp
  8016f4:	56                   	push   %esi
  8016f5:	53                   	push   %ebx
  8016f6:	83 ec 10             	sub    $0x10,%esp
  8016f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8016ff:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801704:	b8 04 40 80 00       	mov    $0x804004,%eax
  801709:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  80170f:	75 11                	jne    801722 <dev_lookup+0x31>
  801711:	eb 04                	jmp    801717 <dev_lookup+0x26>
  801713:	39 08                	cmp    %ecx,(%eax)
  801715:	75 10                	jne    801727 <dev_lookup+0x36>
			*dev = devtab[i];
  801717:	89 03                	mov    %eax,(%ebx)
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80171e:	66 90                	xchg   %ax,%ax
  801720:	eb 36                	jmp    801758 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801722:	be 68 2f 80 00       	mov    $0x802f68,%esi
  801727:	83 c2 01             	add    $0x1,%edx
  80172a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80172d:	85 c0                	test   %eax,%eax
  80172f:	75 e2                	jne    801713 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801731:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801736:	8b 40 48             	mov    0x48(%eax),%eax
  801739:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80173d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801741:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  801748:	e8 0c eb ff ff       	call   800259 <cprintf>
	*dev = 0;
  80174d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801753:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801758:	83 c4 10             	add    $0x10,%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	53                   	push   %ebx
  801763:	83 ec 24             	sub    $0x24,%esp
  801766:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801769:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801770:	8b 45 08             	mov    0x8(%ebp),%eax
  801773:	89 04 24             	mov    %eax,(%esp)
  801776:	e8 02 ff ff ff       	call   80167d <fd_lookup>
  80177b:	85 c0                	test   %eax,%eax
  80177d:	78 53                	js     8017d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80177f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801782:	89 44 24 04          	mov    %eax,0x4(%esp)
  801786:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801789:	8b 00                	mov    (%eax),%eax
  80178b:	89 04 24             	mov    %eax,(%esp)
  80178e:	e8 5e ff ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801793:	85 c0                	test   %eax,%eax
  801795:	78 3b                	js     8017d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801797:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80179c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80179f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8017a3:	74 2d                	je     8017d2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017af:	00 00 00 
	stat->st_isdir = 0;
  8017b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017b9:	00 00 00 
	stat->st_dev = dev;
  8017bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017cc:	89 14 24             	mov    %edx,(%esp)
  8017cf:	ff 50 14             	call   *0x14(%eax)
}
  8017d2:	83 c4 24             	add    $0x24,%esp
  8017d5:	5b                   	pop    %ebx
  8017d6:	5d                   	pop    %ebp
  8017d7:	c3                   	ret    

008017d8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8017d8:	55                   	push   %ebp
  8017d9:	89 e5                	mov    %esp,%ebp
  8017db:	53                   	push   %ebx
  8017dc:	83 ec 24             	sub    $0x24,%esp
  8017df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e9:	89 1c 24             	mov    %ebx,(%esp)
  8017ec:	e8 8c fe ff ff       	call   80167d <fd_lookup>
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 5f                	js     801854 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ff:	8b 00                	mov    (%eax),%eax
  801801:	89 04 24             	mov    %eax,(%esp)
  801804:	e8 e8 fe ff ff       	call   8016f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 47                	js     801854 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80180d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801810:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801814:	75 23                	jne    801839 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801816:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80181b:	8b 40 48             	mov    0x48(%eax),%eax
  80181e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801822:	89 44 24 04          	mov    %eax,0x4(%esp)
  801826:	c7 04 24 08 2f 80 00 	movl   $0x802f08,(%esp)
  80182d:	e8 27 ea ff ff       	call   800259 <cprintf>
  801832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801837:	eb 1b                	jmp    801854 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80183c:	8b 48 18             	mov    0x18(%eax),%ecx
  80183f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801844:	85 c9                	test   %ecx,%ecx
  801846:	74 0c                	je     801854 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80184f:	89 14 24             	mov    %edx,(%esp)
  801852:	ff d1                	call   *%ecx
}
  801854:	83 c4 24             	add    $0x24,%esp
  801857:	5b                   	pop    %ebx
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	53                   	push   %ebx
  80185e:	83 ec 24             	sub    $0x24,%esp
  801861:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801864:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	89 1c 24             	mov    %ebx,(%esp)
  80186e:	e8 0a fe ff ff       	call   80167d <fd_lookup>
  801873:	85 c0                	test   %eax,%eax
  801875:	78 66                	js     8018dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801881:	8b 00                	mov    (%eax),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 66 fe ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 4e                	js     8018dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801892:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801896:	75 23                	jne    8018bb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801898:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80189d:	8b 40 48             	mov    0x48(%eax),%eax
  8018a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a8:	c7 04 24 2c 2f 80 00 	movl   $0x802f2c,(%esp)
  8018af:	e8 a5 e9 ff ff       	call   800259 <cprintf>
  8018b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018b9:	eb 22                	jmp    8018dd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018be:	8b 48 0c             	mov    0xc(%eax),%ecx
  8018c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018c6:	85 c9                	test   %ecx,%ecx
  8018c8:	74 13                	je     8018dd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8018cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d8:	89 14 24             	mov    %edx,(%esp)
  8018db:	ff d1                	call   *%ecx
}
  8018dd:	83 c4 24             	add    $0x24,%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5d                   	pop    %ebp
  8018e2:	c3                   	ret    

008018e3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	53                   	push   %ebx
  8018e7:	83 ec 24             	sub    $0x24,%esp
  8018ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f4:	89 1c 24             	mov    %ebx,(%esp)
  8018f7:	e8 81 fd ff ff       	call   80167d <fd_lookup>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 6b                	js     80196b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801900:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801903:	89 44 24 04          	mov    %eax,0x4(%esp)
  801907:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190a:	8b 00                	mov    (%eax),%eax
  80190c:	89 04 24             	mov    %eax,(%esp)
  80190f:	e8 dd fd ff ff       	call   8016f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801914:	85 c0                	test   %eax,%eax
  801916:	78 53                	js     80196b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801918:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80191b:	8b 42 08             	mov    0x8(%edx),%eax
  80191e:	83 e0 03             	and    $0x3,%eax
  801921:	83 f8 01             	cmp    $0x1,%eax
  801924:	75 23                	jne    801949 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801926:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80192b:	8b 40 48             	mov    0x48(%eax),%eax
  80192e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801932:	89 44 24 04          	mov    %eax,0x4(%esp)
  801936:	c7 04 24 49 2f 80 00 	movl   $0x802f49,(%esp)
  80193d:	e8 17 e9 ff ff       	call   800259 <cprintf>
  801942:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801947:	eb 22                	jmp    80196b <read+0x88>
	}
	if (!dev->dev_read)
  801949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194c:	8b 48 08             	mov    0x8(%eax),%ecx
  80194f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801954:	85 c9                	test   %ecx,%ecx
  801956:	74 13                	je     80196b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801958:	8b 45 10             	mov    0x10(%ebp),%eax
  80195b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801962:	89 44 24 04          	mov    %eax,0x4(%esp)
  801966:	89 14 24             	mov    %edx,(%esp)
  801969:	ff d1                	call   *%ecx
}
  80196b:	83 c4 24             	add    $0x24,%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	57                   	push   %edi
  801975:	56                   	push   %esi
  801976:	53                   	push   %ebx
  801977:	83 ec 1c             	sub    $0x1c,%esp
  80197a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80197d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801980:	ba 00 00 00 00       	mov    $0x0,%edx
  801985:	bb 00 00 00 00       	mov    $0x0,%ebx
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
  80198f:	85 f6                	test   %esi,%esi
  801991:	74 29                	je     8019bc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801993:	89 f0                	mov    %esi,%eax
  801995:	29 d0                	sub    %edx,%eax
  801997:	89 44 24 08          	mov    %eax,0x8(%esp)
  80199b:	03 55 0c             	add    0xc(%ebp),%edx
  80199e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019a2:	89 3c 24             	mov    %edi,(%esp)
  8019a5:	e8 39 ff ff ff       	call   8018e3 <read>
		if (m < 0)
  8019aa:	85 c0                	test   %eax,%eax
  8019ac:	78 0e                	js     8019bc <readn+0x4b>
			return m;
		if (m == 0)
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	74 08                	je     8019ba <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019b2:	01 c3                	add    %eax,%ebx
  8019b4:	89 da                	mov    %ebx,%edx
  8019b6:	39 f3                	cmp    %esi,%ebx
  8019b8:	72 d9                	jb     801993 <readn+0x22>
  8019ba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019bc:	83 c4 1c             	add    $0x1c,%esp
  8019bf:	5b                   	pop    %ebx
  8019c0:	5e                   	pop    %esi
  8019c1:	5f                   	pop    %edi
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	83 ec 28             	sub    $0x28,%esp
  8019ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8019d0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8019d3:	89 34 24             	mov    %esi,(%esp)
  8019d6:	e8 05 fc ff ff       	call   8015e0 <fd2num>
  8019db:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019e2:	89 04 24             	mov    %eax,(%esp)
  8019e5:	e8 93 fc ff ff       	call   80167d <fd_lookup>
  8019ea:	89 c3                	mov    %eax,%ebx
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	78 05                	js     8019f5 <fd_close+0x31>
  8019f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8019f3:	74 0e                	je     801a03 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8019f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fe:	0f 44 d8             	cmove  %eax,%ebx
  801a01:	eb 3d                	jmp    801a40 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801a03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0a:	8b 06                	mov    (%esi),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 dd fc ff ff       	call   8016f1 <dev_lookup>
  801a14:	89 c3                	mov    %eax,%ebx
  801a16:	85 c0                	test   %eax,%eax
  801a18:	78 16                	js     801a30 <fd_close+0x6c>
		if (dev->dev_close)
  801a1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a1d:	8b 40 10             	mov    0x10(%eax),%eax
  801a20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a25:	85 c0                	test   %eax,%eax
  801a27:	74 07                	je     801a30 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801a29:	89 34 24             	mov    %esi,(%esp)
  801a2c:	ff d0                	call   *%eax
  801a2e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a30:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a3b:	e8 4c f5 ff ff       	call   800f8c <sys_page_unmap>
	return r;
}
  801a40:	89 d8                	mov    %ebx,%eax
  801a42:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a45:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a48:	89 ec                	mov    %ebp,%esp
  801a4a:	5d                   	pop    %ebp
  801a4b:	c3                   	ret    

00801a4c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	89 04 24             	mov    %eax,(%esp)
  801a5f:	e8 19 fc ff ff       	call   80167d <fd_lookup>
  801a64:	85 c0                	test   %eax,%eax
  801a66:	78 13                	js     801a7b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a68:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a6f:	00 
  801a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a73:	89 04 24             	mov    %eax,(%esp)
  801a76:	e8 49 ff ff ff       	call   8019c4 <fd_close>
}
  801a7b:	c9                   	leave  
  801a7c:	c3                   	ret    

00801a7d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a7d:	55                   	push   %ebp
  801a7e:	89 e5                	mov    %esp,%ebp
  801a80:	83 ec 18             	sub    $0x18,%esp
  801a83:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a86:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a90:	00 
  801a91:	8b 45 08             	mov    0x8(%ebp),%eax
  801a94:	89 04 24             	mov    %eax,(%esp)
  801a97:	e8 78 03 00 00       	call   801e14 <open>
  801a9c:	89 c3                	mov    %eax,%ebx
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 1b                	js     801abd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa9:	89 1c 24             	mov    %ebx,(%esp)
  801aac:	e8 ae fc ff ff       	call   80175f <fstat>
  801ab1:	89 c6                	mov    %eax,%esi
	close(fd);
  801ab3:	89 1c 24             	mov    %ebx,(%esp)
  801ab6:	e8 91 ff ff ff       	call   801a4c <close>
  801abb:	89 f3                	mov    %esi,%ebx
	return r;
}
  801abd:	89 d8                	mov    %ebx,%eax
  801abf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ac2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ac5:	89 ec                	mov    %ebp,%esp
  801ac7:	5d                   	pop    %ebp
  801ac8:	c3                   	ret    

00801ac9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801ac9:	55                   	push   %ebp
  801aca:	89 e5                	mov    %esp,%ebp
  801acc:	53                   	push   %ebx
  801acd:	83 ec 14             	sub    $0x14,%esp
  801ad0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801ad5:	89 1c 24             	mov    %ebx,(%esp)
  801ad8:	e8 6f ff ff ff       	call   801a4c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801add:	83 c3 01             	add    $0x1,%ebx
  801ae0:	83 fb 20             	cmp    $0x20,%ebx
  801ae3:	75 f0                	jne    801ad5 <close_all+0xc>
		close(i);
}
  801ae5:	83 c4 14             	add    $0x14,%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5d                   	pop    %ebp
  801aea:	c3                   	ret    

00801aeb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 58             	sub    $0x58,%esp
  801af1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801af4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801af7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801afa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801afd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801b00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b04:	8b 45 08             	mov    0x8(%ebp),%eax
  801b07:	89 04 24             	mov    %eax,(%esp)
  801b0a:	e8 6e fb ff ff       	call   80167d <fd_lookup>
  801b0f:	89 c3                	mov    %eax,%ebx
  801b11:	85 c0                	test   %eax,%eax
  801b13:	0f 88 e0 00 00 00    	js     801bf9 <dup+0x10e>
		return r;
	close(newfdnum);
  801b19:	89 3c 24             	mov    %edi,(%esp)
  801b1c:	e8 2b ff ff ff       	call   801a4c <close>

	newfd = INDEX2FD(newfdnum);
  801b21:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b27:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b2d:	89 04 24             	mov    %eax,(%esp)
  801b30:	e8 bb fa ff ff       	call   8015f0 <fd2data>
  801b35:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b37:	89 34 24             	mov    %esi,(%esp)
  801b3a:	e8 b1 fa ff ff       	call   8015f0 <fd2data>
  801b3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b42:	89 da                	mov    %ebx,%edx
  801b44:	89 d8                	mov    %ebx,%eax
  801b46:	c1 e8 16             	shr    $0x16,%eax
  801b49:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b50:	a8 01                	test   $0x1,%al
  801b52:	74 43                	je     801b97 <dup+0xac>
  801b54:	c1 ea 0c             	shr    $0xc,%edx
  801b57:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b5e:	a8 01                	test   $0x1,%al
  801b60:	74 35                	je     801b97 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b62:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b69:	25 07 0e 00 00       	and    $0xe07,%eax
  801b6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b80:	00 
  801b81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b8c:	e8 33 f4 ff ff       	call   800fc4 <sys_page_map>
  801b91:	89 c3                	mov    %eax,%ebx
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 3f                	js     801bd6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b9a:	89 c2                	mov    %eax,%edx
  801b9c:	c1 ea 0c             	shr    $0xc,%edx
  801b9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ba6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801bac:	89 54 24 10          	mov    %edx,0x10(%esp)
  801bb0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801bb4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bbb:	00 
  801bbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bc7:	e8 f8 f3 ff ff       	call   800fc4 <sys_page_map>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 04                	js     801bd6 <dup+0xeb>
  801bd2:	89 fb                	mov    %edi,%ebx
  801bd4:	eb 23                	jmp    801bf9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801bd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be1:	e8 a6 f3 ff ff       	call   800f8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801be6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801be9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bf4:	e8 93 f3 ff ff       	call   800f8c <sys_page_unmap>
	return r;
}
  801bf9:	89 d8                	mov    %ebx,%eax
  801bfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801bfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c04:	89 ec                	mov    %ebp,%esp
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    

00801c08 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	83 ec 18             	sub    $0x18,%esp
  801c0e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c11:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c18:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c1f:	75 11                	jne    801c32 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c21:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c28:	e8 43 08 00 00       	call   802470 <ipc_find_env>
  801c2d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c32:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c39:	00 
  801c3a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c41:	00 
  801c42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c46:	a1 00 50 80 00       	mov    0x805000,%eax
  801c4b:	89 04 24             	mov    %eax,(%esp)
  801c4e:	e8 66 08 00 00       	call   8024b9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c5a:	00 
  801c5b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c66:	e8 b9 08 00 00       	call   802524 <ipc_recv>
}
  801c6b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c6e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c71:	89 ec                	mov    %ebp,%esp
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c81:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c89:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c93:	b8 02 00 00 00       	mov    $0x2,%eax
  801c98:	e8 6b ff ff ff       	call   801c08 <fsipc>
}
  801c9d:	c9                   	leave  
  801c9e:	c3                   	ret    

00801c9f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c9f:	55                   	push   %ebp
  801ca0:	89 e5                	mov    %esp,%ebp
  801ca2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca8:	8b 40 0c             	mov    0xc(%eax),%eax
  801cab:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  801cb5:	b8 06 00 00 00       	mov    $0x6,%eax
  801cba:	e8 49 ff ff ff       	call   801c08 <fsipc>
}
  801cbf:	c9                   	leave  
  801cc0:	c3                   	ret    

00801cc1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801cc1:	55                   	push   %ebp
  801cc2:	89 e5                	mov    %esp,%ebp
  801cc4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccc:	b8 08 00 00 00       	mov    $0x8,%eax
  801cd1:	e8 32 ff ff ff       	call   801c08 <fsipc>
}
  801cd6:	c9                   	leave  
  801cd7:	c3                   	ret    

00801cd8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	53                   	push   %ebx
  801cdc:	83 ec 14             	sub    $0x14,%esp
  801cdf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ce8:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ced:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf2:	b8 05 00 00 00       	mov    $0x5,%eax
  801cf7:	e8 0c ff ff ff       	call   801c08 <fsipc>
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 2b                	js     801d2b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d00:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d07:	00 
  801d08:	89 1c 24             	mov    %ebx,(%esp)
  801d0b:	e8 8a ec ff ff       	call   80099a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d10:	a1 80 60 80 00       	mov    0x806080,%eax
  801d15:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d1b:	a1 84 60 80 00       	mov    0x806084,%eax
  801d20:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d26:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d2b:	83 c4 14             	add    $0x14,%esp
  801d2e:	5b                   	pop    %ebx
  801d2f:	5d                   	pop    %ebp
  801d30:	c3                   	ret    

00801d31 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	83 ec 18             	sub    $0x18,%esp
  801d37:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801d3d:	8b 52 0c             	mov    0xc(%edx),%edx
  801d40:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801d46:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801d4b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d50:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d55:	0f 47 c2             	cmova  %edx,%eax
  801d58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d63:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801d6a:	e8 16 ee ff ff       	call   800b85 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801d6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d74:	b8 04 00 00 00       	mov    $0x4,%eax
  801d79:	e8 8a fe ff ff       	call   801c08 <fsipc>
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	53                   	push   %ebx
  801d84:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d87:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d8d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801d92:	8b 45 10             	mov    0x10(%ebp),%eax
  801d95:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d9f:	b8 03 00 00 00       	mov    $0x3,%eax
  801da4:	e8 5f fe ff ff       	call   801c08 <fsipc>
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 17                	js     801dc6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801daf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801db3:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801dba:	00 
  801dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dbe:	89 04 24             	mov    %eax,(%esp)
  801dc1:	e8 bf ed ff ff       	call   800b85 <memmove>
  return r;	
}
  801dc6:	89 d8                	mov    %ebx,%eax
  801dc8:	83 c4 14             	add    $0x14,%esp
  801dcb:	5b                   	pop    %ebx
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	53                   	push   %ebx
  801dd2:	83 ec 14             	sub    $0x14,%esp
  801dd5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801dd8:	89 1c 24             	mov    %ebx,(%esp)
  801ddb:	e8 70 eb ff ff       	call   800950 <strlen>
  801de0:	89 c2                	mov    %eax,%edx
  801de2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801de7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ded:	7f 1f                	jg     801e0e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801def:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801df3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801dfa:	e8 9b eb ff ff       	call   80099a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801dff:	ba 00 00 00 00       	mov    $0x0,%edx
  801e04:	b8 07 00 00 00       	mov    $0x7,%eax
  801e09:	e8 fa fd ff ff       	call   801c08 <fsipc>
}
  801e0e:	83 c4 14             	add    $0x14,%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5d                   	pop    %ebp
  801e13:	c3                   	ret    

00801e14 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e14:	55                   	push   %ebp
  801e15:	89 e5                	mov    %esp,%ebp
  801e17:	83 ec 28             	sub    $0x28,%esp
  801e1a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e1d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e20:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801e23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e26:	89 04 24             	mov    %eax,(%esp)
  801e29:	e8 dd f7 ff ff       	call   80160b <fd_alloc>
  801e2e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801e30:	85 c0                	test   %eax,%eax
  801e32:	0f 88 89 00 00 00    	js     801ec1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801e38:	89 34 24             	mov    %esi,(%esp)
  801e3b:	e8 10 eb ff ff       	call   800950 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801e40:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801e45:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e4a:	7f 75                	jg     801ec1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801e4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e50:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e57:	e8 3e eb ff ff       	call   80099a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801e64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e67:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6c:	e8 97 fd ff ff       	call   801c08 <fsipc>
  801e71:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 0f                	js     801e86 <open+0x72>
  return fd2num(fd);
  801e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7a:	89 04 24             	mov    %eax,(%esp)
  801e7d:	e8 5e f7 ff ff       	call   8015e0 <fd2num>
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	eb 3b                	jmp    801ec1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801e86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e8d:	00 
  801e8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e91:	89 04 24             	mov    %eax,(%esp)
  801e94:	e8 2b fb ff ff       	call   8019c4 <fd_close>
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	74 24                	je     801ec1 <open+0xad>
  801e9d:	c7 44 24 0c 74 2f 80 	movl   $0x802f74,0xc(%esp)
  801ea4:	00 
  801ea5:	c7 44 24 08 89 2f 80 	movl   $0x802f89,0x8(%esp)
  801eac:	00 
  801ead:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801eb4:	00 
  801eb5:	c7 04 24 9e 2f 80 00 	movl   $0x802f9e,(%esp)
  801ebc:	e8 df e2 ff ff       	call   8001a0 <_panic>
  return r;
}
  801ec1:	89 d8                	mov    %ebx,%eax
  801ec3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ec6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ec9:	89 ec                	mov    %ebp,%esp
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    
  801ecd:	00 00                	add    %al,(%eax)
	...

00801ed0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ed6:	c7 44 24 04 a9 2f 80 	movl   $0x802fa9,0x4(%esp)
  801edd:	00 
  801ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee1:	89 04 24             	mov    %eax,(%esp)
  801ee4:	e8 b1 ea ff ff       	call   80099a <strcpy>
	return 0;
}
  801ee9:	b8 00 00 00 00       	mov    $0x0,%eax
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	53                   	push   %ebx
  801ef4:	83 ec 14             	sub    $0x14,%esp
  801ef7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801efa:	89 1c 24             	mov    %ebx,(%esp)
  801efd:	e8 b2 06 00 00       	call   8025b4 <pageref>
  801f02:	89 c2                	mov    %eax,%edx
  801f04:	b8 00 00 00 00       	mov    $0x0,%eax
  801f09:	83 fa 01             	cmp    $0x1,%edx
  801f0c:	75 0b                	jne    801f19 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801f0e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f11:	89 04 24             	mov    %eax,(%esp)
  801f14:	e8 b9 02 00 00       	call   8021d2 <nsipc_close>
	else
		return 0;
}
  801f19:	83 c4 14             	add    $0x14,%esp
  801f1c:	5b                   	pop    %ebx
  801f1d:	5d                   	pop    %ebp
  801f1e:	c3                   	ret    

00801f1f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f25:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f2c:	00 
  801f2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f41:	89 04 24             	mov    %eax,(%esp)
  801f44:	e8 c5 02 00 00       	call   80220e <nsipc_send>
}
  801f49:	c9                   	leave  
  801f4a:	c3                   	ret    

00801f4b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f4b:	55                   	push   %ebp
  801f4c:	89 e5                	mov    %esp,%ebp
  801f4e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f51:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f58:	00 
  801f59:	8b 45 10             	mov    0x10(%ebp),%eax
  801f5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f67:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f6d:	89 04 24             	mov    %eax,(%esp)
  801f70:	e8 0c 03 00 00       	call   802281 <nsipc_recv>
}
  801f75:	c9                   	leave  
  801f76:	c3                   	ret    

00801f77 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	56                   	push   %esi
  801f7b:	53                   	push   %ebx
  801f7c:	83 ec 20             	sub    $0x20,%esp
  801f7f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f84:	89 04 24             	mov    %eax,(%esp)
  801f87:	e8 7f f6 ff ff       	call   80160b <fd_alloc>
  801f8c:	89 c3                	mov    %eax,%ebx
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 21                	js     801fb3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f99:	00 
  801f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa8:	e8 50 f0 ff ff       	call   800ffd <sys_page_alloc>
  801fad:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	79 0a                	jns    801fbd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801fb3:	89 34 24             	mov    %esi,(%esp)
  801fb6:	e8 17 02 00 00       	call   8021d2 <nsipc_close>
		return r;
  801fbb:	eb 28                	jmp    801fe5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fbd:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fdb:	89 04 24             	mov    %eax,(%esp)
  801fde:	e8 fd f5 ff ff       	call   8015e0 <fd2num>
  801fe3:	89 c3                	mov    %eax,%ebx
}
  801fe5:	89 d8                	mov    %ebx,%eax
  801fe7:	83 c4 20             	add    $0x20,%esp
  801fea:	5b                   	pop    %ebx
  801feb:	5e                   	pop    %esi
  801fec:	5d                   	pop    %ebp
  801fed:	c3                   	ret    

00801fee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fee:	55                   	push   %ebp
  801fef:	89 e5                	mov    %esp,%ebp
  801ff1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ff4:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802002:	8b 45 08             	mov    0x8(%ebp),%eax
  802005:	89 04 24             	mov    %eax,(%esp)
  802008:	e8 79 01 00 00       	call   802186 <nsipc_socket>
  80200d:	85 c0                	test   %eax,%eax
  80200f:	78 05                	js     802016 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802011:	e8 61 ff ff ff       	call   801f77 <alloc_sockfd>
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80201e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802021:	89 54 24 04          	mov    %edx,0x4(%esp)
  802025:	89 04 24             	mov    %eax,(%esp)
  802028:	e8 50 f6 ff ff       	call   80167d <fd_lookup>
  80202d:	85 c0                	test   %eax,%eax
  80202f:	78 15                	js     802046 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802031:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802034:	8b 0a                	mov    (%edx),%ecx
  802036:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80203b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802041:	75 03                	jne    802046 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802043:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802046:	c9                   	leave  
  802047:	c3                   	ret    

00802048 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802048:	55                   	push   %ebp
  802049:	89 e5                	mov    %esp,%ebp
  80204b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80204e:	8b 45 08             	mov    0x8(%ebp),%eax
  802051:	e8 c2 ff ff ff       	call   802018 <fd2sockid>
  802056:	85 c0                	test   %eax,%eax
  802058:	78 0f                	js     802069 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80205a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80205d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802061:	89 04 24             	mov    %eax,(%esp)
  802064:	e8 47 01 00 00       	call   8021b0 <nsipc_listen>
}
  802069:	c9                   	leave  
  80206a:	c3                   	ret    

0080206b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80206b:	55                   	push   %ebp
  80206c:	89 e5                	mov    %esp,%ebp
  80206e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802071:	8b 45 08             	mov    0x8(%ebp),%eax
  802074:	e8 9f ff ff ff       	call   802018 <fd2sockid>
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 16                	js     802093 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80207d:	8b 55 10             	mov    0x10(%ebp),%edx
  802080:	89 54 24 08          	mov    %edx,0x8(%esp)
  802084:	8b 55 0c             	mov    0xc(%ebp),%edx
  802087:	89 54 24 04          	mov    %edx,0x4(%esp)
  80208b:	89 04 24             	mov    %eax,(%esp)
  80208e:	e8 6e 02 00 00       	call   802301 <nsipc_connect>
}
  802093:	c9                   	leave  
  802094:	c3                   	ret    

00802095 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	e8 75 ff ff ff       	call   802018 <fd2sockid>
  8020a3:	85 c0                	test   %eax,%eax
  8020a5:	78 0f                	js     8020b6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8020a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020ae:	89 04 24             	mov    %eax,(%esp)
  8020b1:	e8 36 01 00 00       	call   8021ec <nsipc_shutdown>
}
  8020b6:	c9                   	leave  
  8020b7:	c3                   	ret    

008020b8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020b8:	55                   	push   %ebp
  8020b9:	89 e5                	mov    %esp,%ebp
  8020bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020be:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c1:	e8 52 ff ff ff       	call   802018 <fd2sockid>
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	78 16                	js     8020e0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8020ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8020cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020d8:	89 04 24             	mov    %eax,(%esp)
  8020db:	e8 60 02 00 00       	call   802340 <nsipc_bind>
}
  8020e0:	c9                   	leave  
  8020e1:	c3                   	ret    

008020e2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020eb:	e8 28 ff ff ff       	call   802018 <fd2sockid>
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	78 1f                	js     802113 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8020f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  802102:	89 04 24             	mov    %eax,(%esp)
  802105:	e8 75 02 00 00       	call   80237f <nsipc_accept>
  80210a:	85 c0                	test   %eax,%eax
  80210c:	78 05                	js     802113 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80210e:	e8 64 fe ff ff       	call   801f77 <alloc_sockfd>
}
  802113:	c9                   	leave  
  802114:	c3                   	ret    
	...

00802120 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	53                   	push   %ebx
  802124:	83 ec 14             	sub    $0x14,%esp
  802127:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802129:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802130:	75 11                	jne    802143 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802132:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802139:	e8 32 03 00 00       	call   802470 <ipc_find_env>
  80213e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802143:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80214a:	00 
  80214b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802152:	00 
  802153:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802157:	a1 04 50 80 00       	mov    0x805004,%eax
  80215c:	89 04 24             	mov    %eax,(%esp)
  80215f:	e8 55 03 00 00       	call   8024b9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80216b:	00 
  80216c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802173:	00 
  802174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80217b:	e8 a4 03 00 00       	call   802524 <ipc_recv>
}
  802180:	83 c4 14             	add    $0x14,%esp
  802183:	5b                   	pop    %ebx
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    

00802186 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80218c:	8b 45 08             	mov    0x8(%ebp),%eax
  80218f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802194:	8b 45 0c             	mov    0xc(%ebp),%eax
  802197:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80219c:	8b 45 10             	mov    0x10(%ebp),%eax
  80219f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8021a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8021a9:	e8 72 ff ff ff       	call   802120 <nsipc>
}
  8021ae:	c9                   	leave  
  8021af:	c3                   	ret    

008021b0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021b9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8021be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8021c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8021cb:	e8 50 ff ff ff       	call   802120 <nsipc>
}
  8021d0:	c9                   	leave  
  8021d1:	c3                   	ret    

008021d2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8021d2:	55                   	push   %ebp
  8021d3:	89 e5                	mov    %esp,%ebp
  8021d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021db:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8021e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8021e5:	e8 36 ff ff ff       	call   802120 <nsipc>
}
  8021ea:	c9                   	leave  
  8021eb:	c3                   	ret    

008021ec <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8021ec:	55                   	push   %ebp
  8021ed:	89 e5                	mov    %esp,%ebp
  8021ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8021fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021fd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802202:	b8 03 00 00 00       	mov    $0x3,%eax
  802207:	e8 14 ff ff ff       	call   802120 <nsipc>
}
  80220c:	c9                   	leave  
  80220d:	c3                   	ret    

0080220e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	53                   	push   %ebx
  802212:	83 ec 14             	sub    $0x14,%esp
  802215:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802218:	8b 45 08             	mov    0x8(%ebp),%eax
  80221b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802220:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802226:	7e 24                	jle    80224c <nsipc_send+0x3e>
  802228:	c7 44 24 0c b5 2f 80 	movl   $0x802fb5,0xc(%esp)
  80222f:	00 
  802230:	c7 44 24 08 89 2f 80 	movl   $0x802f89,0x8(%esp)
  802237:	00 
  802238:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80223f:	00 
  802240:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  802247:	e8 54 df ff ff       	call   8001a0 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80224c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802250:	8b 45 0c             	mov    0xc(%ebp),%eax
  802253:	89 44 24 04          	mov    %eax,0x4(%esp)
  802257:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80225e:	e8 22 e9 ff ff       	call   800b85 <memmove>
	nsipcbuf.send.req_size = size;
  802263:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802269:	8b 45 14             	mov    0x14(%ebp),%eax
  80226c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802271:	b8 08 00 00 00       	mov    $0x8,%eax
  802276:	e8 a5 fe ff ff       	call   802120 <nsipc>
}
  80227b:	83 c4 14             	add    $0x14,%esp
  80227e:	5b                   	pop    %ebx
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    

00802281 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	56                   	push   %esi
  802285:	53                   	push   %ebx
  802286:	83 ec 10             	sub    $0x10,%esp
  802289:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802294:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80229a:	8b 45 14             	mov    0x14(%ebp),%eax
  80229d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8022a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8022a7:	e8 74 fe ff ff       	call   802120 <nsipc>
  8022ac:	89 c3                	mov    %eax,%ebx
  8022ae:	85 c0                	test   %eax,%eax
  8022b0:	78 46                	js     8022f8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8022b2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022b7:	7f 04                	jg     8022bd <nsipc_recv+0x3c>
  8022b9:	39 c6                	cmp    %eax,%esi
  8022bb:	7d 24                	jge    8022e1 <nsipc_recv+0x60>
  8022bd:	c7 44 24 0c cd 2f 80 	movl   $0x802fcd,0xc(%esp)
  8022c4:	00 
  8022c5:	c7 44 24 08 89 2f 80 	movl   $0x802f89,0x8(%esp)
  8022cc:	00 
  8022cd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8022d4:	00 
  8022d5:	c7 04 24 c1 2f 80 00 	movl   $0x802fc1,(%esp)
  8022dc:	e8 bf de ff ff       	call   8001a0 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022e5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8022ec:	00 
  8022ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022f0:	89 04 24             	mov    %eax,(%esp)
  8022f3:	e8 8d e8 ff ff       	call   800b85 <memmove>
	}

	return r;
}
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	83 c4 10             	add    $0x10,%esp
  8022fd:	5b                   	pop    %ebx
  8022fe:	5e                   	pop    %esi
  8022ff:	5d                   	pop    %ebp
  802300:	c3                   	ret    

00802301 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802301:	55                   	push   %ebp
  802302:	89 e5                	mov    %esp,%ebp
  802304:	53                   	push   %ebx
  802305:	83 ec 14             	sub    $0x14,%esp
  802308:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80230b:	8b 45 08             	mov    0x8(%ebp),%eax
  80230e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802313:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80231e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802325:	e8 5b e8 ff ff       	call   800b85 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80232a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802330:	b8 05 00 00 00       	mov    $0x5,%eax
  802335:	e8 e6 fd ff ff       	call   802120 <nsipc>
}
  80233a:	83 c4 14             	add    $0x14,%esp
  80233d:	5b                   	pop    %ebx
  80233e:	5d                   	pop    %ebp
  80233f:	c3                   	ret    

00802340 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802340:	55                   	push   %ebp
  802341:	89 e5                	mov    %esp,%ebp
  802343:	53                   	push   %ebx
  802344:	83 ec 14             	sub    $0x14,%esp
  802347:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80234a:	8b 45 08             	mov    0x8(%ebp),%eax
  80234d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802352:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802356:	8b 45 0c             	mov    0xc(%ebp),%eax
  802359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802364:	e8 1c e8 ff ff       	call   800b85 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802369:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80236f:	b8 02 00 00 00       	mov    $0x2,%eax
  802374:	e8 a7 fd ff ff       	call   802120 <nsipc>
}
  802379:	83 c4 14             	add    $0x14,%esp
  80237c:	5b                   	pop    %ebx
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    

0080237f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80237f:	55                   	push   %ebp
  802380:	89 e5                	mov    %esp,%ebp
  802382:	83 ec 18             	sub    $0x18,%esp
  802385:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802388:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80238b:	8b 45 08             	mov    0x8(%ebp),%eax
  80238e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802393:	b8 01 00 00 00       	mov    $0x1,%eax
  802398:	e8 83 fd ff ff       	call   802120 <nsipc>
  80239d:	89 c3                	mov    %eax,%ebx
  80239f:	85 c0                	test   %eax,%eax
  8023a1:	78 25                	js     8023c8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8023a3:	be 10 70 80 00       	mov    $0x807010,%esi
  8023a8:	8b 06                	mov    (%esi),%eax
  8023aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023ae:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8023b5:	00 
  8023b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b9:	89 04 24             	mov    %eax,(%esp)
  8023bc:	e8 c4 e7 ff ff       	call   800b85 <memmove>
		*addrlen = ret->ret_addrlen;
  8023c1:	8b 16                	mov    (%esi),%edx
  8023c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8023c6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8023c8:	89 d8                	mov    %ebx,%eax
  8023ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8023cd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8023d0:	89 ec                	mov    %ebp,%esp
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023da:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8023e1:	75 54                	jne    802437 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8023e3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023ea:	00 
  8023eb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023f2:	ee 
  8023f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023fa:	e8 fe eb ff ff       	call   800ffd <sys_page_alloc>
  8023ff:	85 c0                	test   %eax,%eax
  802401:	79 20                	jns    802423 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  802403:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802407:	c7 44 24 08 e2 2f 80 	movl   $0x802fe2,0x8(%esp)
  80240e:	00 
  80240f:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802416:	00 
  802417:	c7 04 24 fa 2f 80 00 	movl   $0x802ffa,(%esp)
  80241e:	e8 7d dd ff ff       	call   8001a0 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  802423:	c7 44 24 04 44 24 80 	movl   $0x802444,0x4(%esp)
  80242a:	00 
  80242b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802432:	e8 ad ea ff ff       	call   800ee4 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802437:	8b 45 08             	mov    0x8(%ebp),%eax
  80243a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80243f:	c9                   	leave  
  802440:	c3                   	ret    
  802441:	00 00                	add    %al,(%eax)
	...

00802444 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802444:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802445:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80244a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80244c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  80244f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802453:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802456:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  80245a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80245e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802460:	83 c4 08             	add    $0x8,%esp
	popal
  802463:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  802464:	83 c4 04             	add    $0x4,%esp
	popfl
  802467:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802468:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802469:	c3                   	ret    
  80246a:	00 00                	add    %al,(%eax)
  80246c:	00 00                	add    %al,(%eax)
	...

00802470 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802470:	55                   	push   %ebp
  802471:	89 e5                	mov    %esp,%ebp
  802473:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802476:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80247c:	b8 01 00 00 00       	mov    $0x1,%eax
  802481:	39 ca                	cmp    %ecx,%edx
  802483:	75 04                	jne    802489 <ipc_find_env+0x19>
  802485:	b0 00                	mov    $0x0,%al
  802487:	eb 11                	jmp    80249a <ipc_find_env+0x2a>
  802489:	89 c2                	mov    %eax,%edx
  80248b:	c1 e2 07             	shl    $0x7,%edx
  80248e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802494:	8b 12                	mov    (%edx),%edx
  802496:	39 ca                	cmp    %ecx,%edx
  802498:	75 0f                	jne    8024a9 <ipc_find_env+0x39>
			return envs[i].env_id;
  80249a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  80249e:	c1 e0 06             	shl    $0x6,%eax
  8024a1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  8024a7:	eb 0e                	jmp    8024b7 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024a9:	83 c0 01             	add    $0x1,%eax
  8024ac:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024b1:	75 d6                	jne    802489 <ipc_find_env+0x19>
  8024b3:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8024b7:	5d                   	pop    %ebp
  8024b8:	c3                   	ret    

008024b9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024b9:	55                   	push   %ebp
  8024ba:	89 e5                	mov    %esp,%ebp
  8024bc:	57                   	push   %edi
  8024bd:	56                   	push   %esi
  8024be:	53                   	push   %ebx
  8024bf:	83 ec 1c             	sub    $0x1c,%esp
  8024c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8024c5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8024cb:	85 db                	test   %ebx,%ebx
  8024cd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024d2:	0f 44 d8             	cmove  %eax,%ebx
  8024d5:	eb 25                	jmp    8024fc <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8024d7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024da:	74 20                	je     8024fc <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8024dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024e0:	c7 44 24 08 08 30 80 	movl   $0x803008,0x8(%esp)
  8024e7:	00 
  8024e8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8024ef:	00 
  8024f0:	c7 04 24 26 30 80 00 	movl   $0x803026,(%esp)
  8024f7:	e8 a4 dc ff ff       	call   8001a0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8024fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8024ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802503:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802507:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80250b:	89 34 24             	mov    %esi,(%esp)
  80250e:	e8 9b e9 ff ff       	call   800eae <sys_ipc_try_send>
  802513:	85 c0                	test   %eax,%eax
  802515:	75 c0                	jne    8024d7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802517:	e8 18 eb ff ff       	call   801034 <sys_yield>
}
  80251c:	83 c4 1c             	add    $0x1c,%esp
  80251f:	5b                   	pop    %ebx
  802520:	5e                   	pop    %esi
  802521:	5f                   	pop    %edi
  802522:	5d                   	pop    %ebp
  802523:	c3                   	ret    

00802524 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802524:	55                   	push   %ebp
  802525:	89 e5                	mov    %esp,%ebp
  802527:	83 ec 28             	sub    $0x28,%esp
  80252a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80252d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802530:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802533:	8b 75 08             	mov    0x8(%ebp),%esi
  802536:	8b 45 0c             	mov    0xc(%ebp),%eax
  802539:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80253c:	85 c0                	test   %eax,%eax
  80253e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802543:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802546:	89 04 24             	mov    %eax,(%esp)
  802549:	e8 27 e9 ff ff       	call   800e75 <sys_ipc_recv>
  80254e:	89 c3                	mov    %eax,%ebx
  802550:	85 c0                	test   %eax,%eax
  802552:	79 2a                	jns    80257e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802554:	89 44 24 08          	mov    %eax,0x8(%esp)
  802558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255c:	c7 04 24 30 30 80 00 	movl   $0x803030,(%esp)
  802563:	e8 f1 dc ff ff       	call   800259 <cprintf>
		if(from_env_store != NULL)
  802568:	85 f6                	test   %esi,%esi
  80256a:	74 06                	je     802572 <ipc_recv+0x4e>
			*from_env_store = 0;
  80256c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802572:	85 ff                	test   %edi,%edi
  802574:	74 2c                	je     8025a2 <ipc_recv+0x7e>
			*perm_store = 0;
  802576:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80257c:	eb 24                	jmp    8025a2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80257e:	85 f6                	test   %esi,%esi
  802580:	74 0a                	je     80258c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  802582:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802587:	8b 40 74             	mov    0x74(%eax),%eax
  80258a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80258c:	85 ff                	test   %edi,%edi
  80258e:	74 0a                	je     80259a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802590:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802595:	8b 40 78             	mov    0x78(%eax),%eax
  802598:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80259a:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80259f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8025a2:	89 d8                	mov    %ebx,%eax
  8025a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8025a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8025aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8025ad:	89 ec                	mov    %ebp,%esp
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    
  8025b1:	00 00                	add    %al,(%eax)
	...

008025b4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025b4:	55                   	push   %ebp
  8025b5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8025b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ba:	89 c2                	mov    %eax,%edx
  8025bc:	c1 ea 16             	shr    $0x16,%edx
  8025bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025c6:	f6 c2 01             	test   $0x1,%dl
  8025c9:	74 20                	je     8025eb <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025cb:	c1 e8 0c             	shr    $0xc,%eax
  8025ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025d5:	a8 01                	test   $0x1,%al
  8025d7:	74 12                	je     8025eb <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025d9:	c1 e8 0c             	shr    $0xc,%eax
  8025dc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025e1:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025e6:	0f b7 c0             	movzwl %ax,%eax
  8025e9:	eb 05                	jmp    8025f0 <pageref+0x3c>
  8025eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025f0:	5d                   	pop    %ebp
  8025f1:	c3                   	ret    
	...

00802600 <__udivdi3>:
  802600:	55                   	push   %ebp
  802601:	89 e5                	mov    %esp,%ebp
  802603:	57                   	push   %edi
  802604:	56                   	push   %esi
  802605:	83 ec 10             	sub    $0x10,%esp
  802608:	8b 45 14             	mov    0x14(%ebp),%eax
  80260b:	8b 55 08             	mov    0x8(%ebp),%edx
  80260e:	8b 75 10             	mov    0x10(%ebp),%esi
  802611:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802614:	85 c0                	test   %eax,%eax
  802616:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802619:	75 35                	jne    802650 <__udivdi3+0x50>
  80261b:	39 fe                	cmp    %edi,%esi
  80261d:	77 61                	ja     802680 <__udivdi3+0x80>
  80261f:	85 f6                	test   %esi,%esi
  802621:	75 0b                	jne    80262e <__udivdi3+0x2e>
  802623:	b8 01 00 00 00       	mov    $0x1,%eax
  802628:	31 d2                	xor    %edx,%edx
  80262a:	f7 f6                	div    %esi
  80262c:	89 c6                	mov    %eax,%esi
  80262e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802631:	31 d2                	xor    %edx,%edx
  802633:	89 f8                	mov    %edi,%eax
  802635:	f7 f6                	div    %esi
  802637:	89 c7                	mov    %eax,%edi
  802639:	89 c8                	mov    %ecx,%eax
  80263b:	f7 f6                	div    %esi
  80263d:	89 c1                	mov    %eax,%ecx
  80263f:	89 fa                	mov    %edi,%edx
  802641:	89 c8                	mov    %ecx,%eax
  802643:	83 c4 10             	add    $0x10,%esp
  802646:	5e                   	pop    %esi
  802647:	5f                   	pop    %edi
  802648:	5d                   	pop    %ebp
  802649:	c3                   	ret    
  80264a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802650:	39 f8                	cmp    %edi,%eax
  802652:	77 1c                	ja     802670 <__udivdi3+0x70>
  802654:	0f bd d0             	bsr    %eax,%edx
  802657:	83 f2 1f             	xor    $0x1f,%edx
  80265a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80265d:	75 39                	jne    802698 <__udivdi3+0x98>
  80265f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802662:	0f 86 a0 00 00 00    	jbe    802708 <__udivdi3+0x108>
  802668:	39 f8                	cmp    %edi,%eax
  80266a:	0f 82 98 00 00 00    	jb     802708 <__udivdi3+0x108>
  802670:	31 ff                	xor    %edi,%edi
  802672:	31 c9                	xor    %ecx,%ecx
  802674:	89 c8                	mov    %ecx,%eax
  802676:	89 fa                	mov    %edi,%edx
  802678:	83 c4 10             	add    $0x10,%esp
  80267b:	5e                   	pop    %esi
  80267c:	5f                   	pop    %edi
  80267d:	5d                   	pop    %ebp
  80267e:	c3                   	ret    
  80267f:	90                   	nop
  802680:	89 d1                	mov    %edx,%ecx
  802682:	89 fa                	mov    %edi,%edx
  802684:	89 c8                	mov    %ecx,%eax
  802686:	31 ff                	xor    %edi,%edi
  802688:	f7 f6                	div    %esi
  80268a:	89 c1                	mov    %eax,%ecx
  80268c:	89 fa                	mov    %edi,%edx
  80268e:	89 c8                	mov    %ecx,%eax
  802690:	83 c4 10             	add    $0x10,%esp
  802693:	5e                   	pop    %esi
  802694:	5f                   	pop    %edi
  802695:	5d                   	pop    %ebp
  802696:	c3                   	ret    
  802697:	90                   	nop
  802698:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80269c:	89 f2                	mov    %esi,%edx
  80269e:	d3 e0                	shl    %cl,%eax
  8026a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8026ab:	89 c1                	mov    %eax,%ecx
  8026ad:	d3 ea                	shr    %cl,%edx
  8026af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8026b6:	d3 e6                	shl    %cl,%esi
  8026b8:	89 c1                	mov    %eax,%ecx
  8026ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8026bd:	89 fe                	mov    %edi,%esi
  8026bf:	d3 ee                	shr    %cl,%esi
  8026c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026cb:	d3 e7                	shl    %cl,%edi
  8026cd:	89 c1                	mov    %eax,%ecx
  8026cf:	d3 ea                	shr    %cl,%edx
  8026d1:	09 d7                	or     %edx,%edi
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	89 f8                	mov    %edi,%eax
  8026d7:	f7 75 ec             	divl   -0x14(%ebp)
  8026da:	89 d6                	mov    %edx,%esi
  8026dc:	89 c7                	mov    %eax,%edi
  8026de:	f7 65 e8             	mull   -0x18(%ebp)
  8026e1:	39 d6                	cmp    %edx,%esi
  8026e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026e6:	72 30                	jb     802718 <__udivdi3+0x118>
  8026e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026ef:	d3 e2                	shl    %cl,%edx
  8026f1:	39 c2                	cmp    %eax,%edx
  8026f3:	73 05                	jae    8026fa <__udivdi3+0xfa>
  8026f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8026f8:	74 1e                	je     802718 <__udivdi3+0x118>
  8026fa:	89 f9                	mov    %edi,%ecx
  8026fc:	31 ff                	xor    %edi,%edi
  8026fe:	e9 71 ff ff ff       	jmp    802674 <__udivdi3+0x74>
  802703:	90                   	nop
  802704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802708:	31 ff                	xor    %edi,%edi
  80270a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80270f:	e9 60 ff ff ff       	jmp    802674 <__udivdi3+0x74>
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80271b:	31 ff                	xor    %edi,%edi
  80271d:	89 c8                	mov    %ecx,%eax
  80271f:	89 fa                	mov    %edi,%edx
  802721:	83 c4 10             	add    $0x10,%esp
  802724:	5e                   	pop    %esi
  802725:	5f                   	pop    %edi
  802726:	5d                   	pop    %ebp
  802727:	c3                   	ret    
	...

00802730 <__umoddi3>:
  802730:	55                   	push   %ebp
  802731:	89 e5                	mov    %esp,%ebp
  802733:	57                   	push   %edi
  802734:	56                   	push   %esi
  802735:	83 ec 20             	sub    $0x20,%esp
  802738:	8b 55 14             	mov    0x14(%ebp),%edx
  80273b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80273e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802741:	8b 75 0c             	mov    0xc(%ebp),%esi
  802744:	85 d2                	test   %edx,%edx
  802746:	89 c8                	mov    %ecx,%eax
  802748:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80274b:	75 13                	jne    802760 <__umoddi3+0x30>
  80274d:	39 f7                	cmp    %esi,%edi
  80274f:	76 3f                	jbe    802790 <__umoddi3+0x60>
  802751:	89 f2                	mov    %esi,%edx
  802753:	f7 f7                	div    %edi
  802755:	89 d0                	mov    %edx,%eax
  802757:	31 d2                	xor    %edx,%edx
  802759:	83 c4 20             	add    $0x20,%esp
  80275c:	5e                   	pop    %esi
  80275d:	5f                   	pop    %edi
  80275e:	5d                   	pop    %ebp
  80275f:	c3                   	ret    
  802760:	39 f2                	cmp    %esi,%edx
  802762:	77 4c                	ja     8027b0 <__umoddi3+0x80>
  802764:	0f bd ca             	bsr    %edx,%ecx
  802767:	83 f1 1f             	xor    $0x1f,%ecx
  80276a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80276d:	75 51                	jne    8027c0 <__umoddi3+0x90>
  80276f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802772:	0f 87 e0 00 00 00    	ja     802858 <__umoddi3+0x128>
  802778:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80277b:	29 f8                	sub    %edi,%eax
  80277d:	19 d6                	sbb    %edx,%esi
  80277f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802785:	89 f2                	mov    %esi,%edx
  802787:	83 c4 20             	add    $0x20,%esp
  80278a:	5e                   	pop    %esi
  80278b:	5f                   	pop    %edi
  80278c:	5d                   	pop    %ebp
  80278d:	c3                   	ret    
  80278e:	66 90                	xchg   %ax,%ax
  802790:	85 ff                	test   %edi,%edi
  802792:	75 0b                	jne    80279f <__umoddi3+0x6f>
  802794:	b8 01 00 00 00       	mov    $0x1,%eax
  802799:	31 d2                	xor    %edx,%edx
  80279b:	f7 f7                	div    %edi
  80279d:	89 c7                	mov    %eax,%edi
  80279f:	89 f0                	mov    %esi,%eax
  8027a1:	31 d2                	xor    %edx,%edx
  8027a3:	f7 f7                	div    %edi
  8027a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a8:	f7 f7                	div    %edi
  8027aa:	eb a9                	jmp    802755 <__umoddi3+0x25>
  8027ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	83 c4 20             	add    $0x20,%esp
  8027b7:	5e                   	pop    %esi
  8027b8:	5f                   	pop    %edi
  8027b9:	5d                   	pop    %ebp
  8027ba:	c3                   	ret    
  8027bb:	90                   	nop
  8027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027c4:	d3 e2                	shl    %cl,%edx
  8027c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027d8:	89 fa                	mov    %edi,%edx
  8027da:	d3 ea                	shr    %cl,%edx
  8027dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027e3:	d3 e7                	shl    %cl,%edi
  8027e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027ec:	89 f2                	mov    %esi,%edx
  8027ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8027f1:	89 c7                	mov    %eax,%edi
  8027f3:	d3 ea                	shr    %cl,%edx
  8027f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8027fc:	89 c2                	mov    %eax,%edx
  8027fe:	d3 e6                	shl    %cl,%esi
  802800:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802804:	d3 ea                	shr    %cl,%edx
  802806:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80280a:	09 d6                	or     %edx,%esi
  80280c:	89 f0                	mov    %esi,%eax
  80280e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802811:	d3 e7                	shl    %cl,%edi
  802813:	89 f2                	mov    %esi,%edx
  802815:	f7 75 f4             	divl   -0xc(%ebp)
  802818:	89 d6                	mov    %edx,%esi
  80281a:	f7 65 e8             	mull   -0x18(%ebp)
  80281d:	39 d6                	cmp    %edx,%esi
  80281f:	72 2b                	jb     80284c <__umoddi3+0x11c>
  802821:	39 c7                	cmp    %eax,%edi
  802823:	72 23                	jb     802848 <__umoddi3+0x118>
  802825:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802829:	29 c7                	sub    %eax,%edi
  80282b:	19 d6                	sbb    %edx,%esi
  80282d:	89 f0                	mov    %esi,%eax
  80282f:	89 f2                	mov    %esi,%edx
  802831:	d3 ef                	shr    %cl,%edi
  802833:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802837:	d3 e0                	shl    %cl,%eax
  802839:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80283d:	09 f8                	or     %edi,%eax
  80283f:	d3 ea                	shr    %cl,%edx
  802841:	83 c4 20             	add    $0x20,%esp
  802844:	5e                   	pop    %esi
  802845:	5f                   	pop    %edi
  802846:	5d                   	pop    %ebp
  802847:	c3                   	ret    
  802848:	39 d6                	cmp    %edx,%esi
  80284a:	75 d9                	jne    802825 <__umoddi3+0xf5>
  80284c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80284f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802852:	eb d1                	jmp    802825 <__umoddi3+0xf5>
  802854:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802858:	39 f2                	cmp    %esi,%edx
  80285a:	0f 82 18 ff ff ff    	jb     802778 <__umoddi3+0x48>
  802860:	e9 1d ff ff ff       	jmp    802782 <__umoddi3+0x52>
