
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
  80002c:	e8 f7 00 00 00       	call   800128 <libmain>
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
  800048:	e8 4a 10 00 00       	call   801097 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 49 11 00 00       	call   8011a2 <fork>
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
  800065:	eb 1b                	jmp    800082 <umain+0x42>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 16                	je     800082 <umain+0x42>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800075:	05 54 00 c0 ee       	add    $0xeec00054,%eax
  80007a:	8b 00                	mov    (%eax),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 0d                	jne    80008d <umain+0x4d>
  800080:	eb 1c                	jmp    80009e <umain+0x5e>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800082:	e8 9d 0f 00 00       	call   801024 <sys_yield>
		return;
  800087:	90                   	nop
  800088:	e9 93 00 00 00       	jmp    800120 <umain+0xe0>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80008d:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800090:	81 c2 54 00 c0 ee    	add    $0xeec00054,%edx
		asm volatile("pause");
  800096:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800098:	8b 02                	mov    (%edx),%eax
  80009a:	85 c0                	test   %eax,%eax
  80009c:	75 f8                	jne    800096 <umain+0x56>
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000a3:	be 00 00 00 00       	mov    $0x0,%esi
  8000a8:	e8 77 0f 00 00       	call   801024 <sys_yield>
  8000ad:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000af:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8000b5:	83 c2 01             	add    $0x1,%edx
  8000b8:	89 15 08 50 80 00    	mov    %edx,0x805008
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000be:	83 c0 01             	add    $0x1,%eax
  8000c1:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000c6:	75 e7                	jne    8000af <umain+0x6f>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000c8:	83 c3 01             	add    $0x1,%ebx
  8000cb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ce:	75 d8                	jne    8000a8 <umain+0x68>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000d0:	a1 08 50 80 00       	mov    0x805008,%eax
  8000d5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000da:	74 25                	je     800101 <umain+0xc1>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000dc:	a1 08 50 80 00       	mov    0x805008,%eax
  8000e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e5:	c7 44 24 08 60 28 80 	movl   $0x802860,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 88 28 80 00 	movl   $0x802888,(%esp)
  8000fc:	e8 93 00 00 00       	call   800194 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800101:	a1 0c 50 80 00       	mov    0x80500c,%eax
  800106:	8b 50 5c             	mov    0x5c(%eax),%edx
  800109:	8b 40 48             	mov    0x48(%eax),%eax
  80010c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800110:	89 44 24 04          	mov    %eax,0x4(%esp)
  800114:	c7 04 24 9b 28 80 00 	movl   $0x80289b,(%esp)
  80011b:	e8 2d 01 00 00       	call   80024d <cprintf>

}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    
	...

00800128 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	83 ec 18             	sub    $0x18,%esp
  80012e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800131:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800134:	8b 75 08             	mov    0x8(%ebp),%esi
  800137:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80013a:	e8 58 0f 00 00       	call   801097 <sys_getenvid>
  80013f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800144:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800147:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80014c:	a3 0c 50 80 00       	mov    %eax,0x80500c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800151:	85 f6                	test   %esi,%esi
  800153:	7e 07                	jle    80015c <libmain+0x34>
		binaryname = argv[0];
  800155:	8b 03                	mov    (%ebx),%eax
  800157:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  80015c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800160:	89 34 24             	mov    %esi,(%esp)
  800163:	e8 d8 fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800168:	e8 0b 00 00 00       	call   800178 <exit>
}
  80016d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800170:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800173:	89 ec                	mov    %ebp,%esp
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    
	...

00800178 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80017e:	e8 36 19 00 00       	call   801ab9 <close_all>
	sys_env_destroy(0);
  800183:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018a:	e8 43 0f 00 00       	call   8010d2 <sys_env_destroy>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    
  800191:	00 00                	add    %al,(%eax)
	...

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80019c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8001a5:	e8 ed 0e 00 00       	call   801097 <sys_getenvid>
  8001aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c0:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  8001c7:	e8 81 00 00 00       	call   80024d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 11 00 00 00       	call   8001ec <vcprintf>
	cprintf("\n");
  8001db:	c7 04 24 b7 28 80 00 	movl   $0x8028b7,(%esp)
  8001e2:	e8 66 00 00 00       	call   80024d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x53>
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
  800240:	e8 01 0f 00 00       	call   801146 <sys_cputs>

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
  800294:	e8 ad 0e 00 00       	call   801146 <sys_cputs>
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
  80032d:	e8 ae 22 00 00       	call   8025e0 <__udivdi3>
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
  800388:	e8 83 23 00 00       	call   802710 <__umoddi3>
  80038d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800391:	0f be 80 e7 28 80 00 	movsbl 0x8028e7(%eax),%eax
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
  800475:	ff 24 95 c0 2a 80 00 	jmp    *0x802ac0(,%edx,4)
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
  800548:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  80054f:	85 d2                	test   %edx,%edx
  800551:	75 20                	jne    800573 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800553:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800557:	c7 44 24 08 f8 28 80 	movl   $0x8028f8,0x8(%esp)
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
  800577:	c7 44 24 08 7b 2f 80 	movl   $0x802f7b,0x8(%esp)
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
  8005b1:	b8 01 29 80 00       	mov    $0x802901,%eax
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
  8007f5:	c7 44 24 0c 1c 2a 80 	movl   $0x802a1c,0xc(%esp)
  8007fc:	00 
  8007fd:	c7 44 24 08 7b 2f 80 	movl   $0x802f7b,0x8(%esp)
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
  800823:	c7 44 24 0c 54 2a 80 	movl   $0x802a54,0xc(%esp)
  80082a:	00 
  80082b:	c7 44 24 08 7b 2f 80 	movl   $0x802f7b,0x8(%esp)
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
  800dc7:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  800dce:	00 
  800dcf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800dd6:	00 
  800dd7:	c7 04 24 7d 2c 80 00 	movl   $0x802c7d,(%esp)
  800dde:	e8 b1 f3 ff ff       	call   800194 <_panic>

	return ret;
}
  800de3:	89 d0                	mov    %edx,%eax
  800de5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800deb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dee:	89 ec                	mov    %ebp,%esp
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800df8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dff:	00 
  800e00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e07:	00 
  800e08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e0f:	00 
  800e10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e13:	89 04 24             	mov    %eax,(%esp)
  800e16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e19:	ba 00 00 00 00       	mov    $0x0,%edx
  800e1e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e23:	e8 54 ff ff ff       	call   800d7c <syscall>
}
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800e30:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e37:	00 
  800e38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e3f:	00 
  800e40:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e47:	00 
  800e48:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e54:	ba 00 00 00 00       	mov    $0x0,%edx
  800e59:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e5e:	e8 19 ff ff ff       	call   800d7c <syscall>
}
  800e63:	c9                   	leave  
  800e64:	c3                   	ret    

00800e65 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e65:	55                   	push   %ebp
  800e66:	89 e5                	mov    %esp,%ebp
  800e68:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e6b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e72:	00 
  800e73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e82:	00 
  800e83:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e92:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e97:	e8 e0 fe ff ff       	call   800d7c <syscall>
}
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    

00800e9e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ea4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eab:	00 
  800eac:	8b 45 14             	mov    0x14(%ebp),%eax
  800eaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eb3:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebd:	89 04 24             	mov    %eax,(%esp)
  800ec0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ecd:	e8 aa fe ff ff       	call   800d7c <syscall>
}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800eda:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee9:	00 
  800eea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef1:	00 
  800ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef5:	89 04 24             	mov    %eax,(%esp)
  800ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800efb:	ba 01 00 00 00       	mov    $0x1,%edx
  800f00:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f05:	e8 72 fe ff ff       	call   800d7c <syscall>
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800f12:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f19:	00 
  800f1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f21:	00 
  800f22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f29:	00 
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	89 04 24             	mov    %eax,(%esp)
  800f30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f33:	ba 01 00 00 00       	mov    $0x1,%edx
  800f38:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3d:	e8 3a fe ff ff       	call   800d7c <syscall>
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f61:	00 
  800f62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f65:	89 04 24             	mov    %eax,(%esp)
  800f68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f70:	b8 09 00 00 00       	mov    $0x9,%eax
  800f75:	e8 02 fe ff ff       	call   800d7c <syscall>
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    

00800f7c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f82:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f89:	00 
  800f8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f91:	00 
  800f92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f99:	00 
  800f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9d:	89 04 24             	mov    %eax,(%esp)
  800fa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fa8:	b8 07 00 00 00       	mov    $0x7,%eax
  800fad:	e8 ca fd ff ff       	call   800d7c <syscall>
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800fba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc1:	00 
  800fc2:	8b 45 18             	mov    0x18(%ebp),%eax
  800fc5:	0b 45 14             	or     0x14(%ebp),%eax
  800fc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd6:	89 04 24             	mov    %eax,(%esp)
  800fd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fdc:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe1:	b8 06 00 00 00       	mov    $0x6,%eax
  800fe6:	e8 91 fd ff ff       	call   800d7c <syscall>
}
  800feb:	c9                   	leave  
  800fec:	c3                   	ret    

00800fed <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ff3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ffa:	00 
  800ffb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801002:	00 
  801003:	8b 45 10             	mov    0x10(%ebp),%eax
  801006:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801013:	ba 01 00 00 00       	mov    $0x1,%edx
  801018:	b8 05 00 00 00       	mov    $0x5,%eax
  80101d:	e8 5a fd ff ff       	call   800d7c <syscall>
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80102a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801031:	00 
  801032:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801039:	00 
  80103a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801041:	00 
  801042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80104e:	ba 00 00 00 00       	mov    $0x0,%edx
  801053:	b8 0c 00 00 00       	mov    $0xc,%eax
  801058:	e8 1f fd ff ff       	call   800d7c <syscall>
}
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801065:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80106c:	00 
  80106d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801074:	00 
  801075:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80107c:	00 
  80107d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801080:	89 04 24             	mov    %eax,(%esp)
  801083:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801086:	ba 00 00 00 00       	mov    $0x0,%edx
  80108b:	b8 04 00 00 00       	mov    $0x4,%eax
  801090:	e8 e7 fc ff ff       	call   800d7c <syscall>
}
  801095:	c9                   	leave  
  801096:	c3                   	ret    

00801097 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801097:	55                   	push   %ebp
  801098:	89 e5                	mov    %esp,%ebp
  80109a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80109d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a4:	00 
  8010a5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ac:	00 
  8010ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b4:	00 
  8010b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010bc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010cb:	e8 ac fc ff ff       	call   800d7c <syscall>
}
  8010d0:	c9                   	leave  
  8010d1:	c3                   	ret    

008010d2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010df:	00 
  8010e0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e7:	00 
  8010e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ef:	00 
  8010f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8010ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801104:	e8 73 fc ff ff       	call   800d7c <syscall>
}
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801118:	00 
  801119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801120:	00 
  801121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801128:	00 
  801129:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801130:	b9 00 00 00 00       	mov    $0x0,%ecx
  801135:	ba 00 00 00 00       	mov    $0x0,%edx
  80113a:	b8 01 00 00 00       	mov    $0x1,%eax
  80113f:	e8 38 fc ff ff       	call   800d7c <syscall>
}
  801144:	c9                   	leave  
  801145:	c3                   	ret    

00801146 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80114c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801153:	00 
  801154:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80115b:	00 
  80115c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801163:	00 
  801164:	8b 45 0c             	mov    0xc(%ebp),%eax
  801167:	89 04 24             	mov    %eax,(%esp)
  80116a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116d:	ba 00 00 00 00       	mov    $0x0,%edx
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
  801177:	e8 00 fc ff ff       	call   800d7c <syscall>
}
  80117c:	c9                   	leave  
  80117d:	c3                   	ret    
	...

00801180 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801186:	c7 44 24 08 8b 2c 80 	movl   $0x802c8b,0x8(%esp)
  80118d:	00 
  80118e:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801195:	00 
  801196:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80119d:	e8 f2 ef ff ff       	call   800194 <_panic>

008011a2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
  8011a5:	57                   	push   %edi
  8011a6:	56                   	push   %esi
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  8011ab:	c7 04 24 66 14 80 00 	movl   $0x801466,(%esp)
  8011b2:	e8 0d 12 00 00       	call   8023c4 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  8011b7:	ba 08 00 00 00       	mov    $0x8,%edx
  8011bc:	89 d0                	mov    %edx,%eax
  8011be:	51                   	push   %ecx
  8011bf:	52                   	push   %edx
  8011c0:	53                   	push   %ebx
  8011c1:	55                   	push   %ebp
  8011c2:	56                   	push   %esi
  8011c3:	57                   	push   %edi
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	8d 35 ce 11 80 00    	lea    0x8011ce,%esi
  8011cc:	0f 34                	sysenter 

008011ce <.after_sysenter_label>:
  8011ce:	5f                   	pop    %edi
  8011cf:	5e                   	pop    %esi
  8011d0:	5d                   	pop    %ebp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5a                   	pop    %edx
  8011d3:	59                   	pop    %ecx
  8011d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  8011d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011db:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  8011e2:	00 
  8011e3:	c7 44 24 04 a1 2c 80 	movl   $0x802ca1,0x4(%esp)
  8011ea:	00 
  8011eb:	c7 04 24 e8 2c 80 00 	movl   $0x802ce8,(%esp)
  8011f2:	e8 56 f0 ff ff       	call   80024d <cprintf>
	if (envidnum < 0)
  8011f7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011fb:	79 23                	jns    801220 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  8011fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801200:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801204:	c7 44 24 08 ac 2c 80 	movl   $0x802cac,0x8(%esp)
  80120b:	00 
  80120c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801213:	00 
  801214:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80121b:	e8 74 ef ff ff       	call   800194 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801220:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801225:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80122a:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80122f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801233:	75 1c                	jne    801251 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801235:	e8 5d fe ff ff       	call   801097 <sys_getenvid>
  80123a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80123f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801242:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801247:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  80124c:	e9 0a 02 00 00       	jmp    80145b <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801251:	89 d8                	mov    %ebx,%eax
  801253:	c1 e8 16             	shr    $0x16,%eax
  801256:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801259:	a8 01                	test   $0x1,%al
  80125b:	0f 84 43 01 00 00    	je     8013a4 <.after_sysenter_label+0x1d6>
  801261:	89 d8                	mov    %ebx,%eax
  801263:	c1 e8 0c             	shr    $0xc,%eax
  801266:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801269:	f6 c2 01             	test   $0x1,%dl
  80126c:	0f 84 32 01 00 00    	je     8013a4 <.after_sysenter_label+0x1d6>
  801272:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801275:	f6 c2 04             	test   $0x4,%dl
  801278:	0f 84 26 01 00 00    	je     8013a4 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  80127e:	c1 e0 0c             	shl    $0xc,%eax
  801281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801284:	c1 e8 0c             	shr    $0xc,%eax
  801287:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  80128a:	89 c2                	mov    %eax,%edx
  80128c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  801292:	a9 02 08 00 00       	test   $0x802,%eax
  801297:	0f 84 a0 00 00 00    	je     80133d <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  80129d:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  8012a0:	80 ce 08             	or     $0x8,%dh
  8012a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8012a6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012c6:	e8 e9 fc ff ff       	call   800fb4 <sys_page_map>
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	79 20                	jns    8012ef <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  8012cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d3:	c7 44 24 08 10 2d 80 	movl   $0x802d10,0x8(%esp)
  8012da:	00 
  8012db:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8012e2:	00 
  8012e3:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8012ea:	e8 a5 ee ff ff       	call   800194 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  8012ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801304:	00 
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801310:	e8 9f fc ff ff       	call   800fb4 <sys_page_map>
  801315:	85 c0                	test   %eax,%eax
  801317:	0f 89 87 00 00 00    	jns    8013a4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  80131d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801321:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  801328:	00 
  801329:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801330:	00 
  801331:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  801338:	e8 57 ee ff ff       	call   800194 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  80133d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801340:	89 44 24 08          	mov    %eax,0x8(%esp)
  801344:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  801352:	e8 f6 ee ff ff       	call   80024d <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801357:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80135e:	00 
  80135f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801362:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801366:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801369:	89 44 24 08          	mov    %eax,0x8(%esp)
  80136d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801370:	89 44 24 04          	mov    %eax,0x4(%esp)
  801374:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80137b:	e8 34 fc ff ff       	call   800fb4 <sys_page_map>
  801380:	85 c0                	test   %eax,%eax
  801382:	79 20                	jns    8013a4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801384:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801388:	c7 44 24 08 68 2d 80 	movl   $0x802d68,0x8(%esp)
  80138f:	00 
  801390:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801397:	00 
  801398:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80139f:	e8 f0 ed ff ff       	call   800194 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  8013a4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8013aa:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8013b0:	0f 85 9b fe ff ff    	jne    801251 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8013b6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013bd:	00 
  8013be:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8013c5:	ee 
  8013c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 1c fc ff ff       	call   800fed <sys_page_alloc>
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	79 20                	jns    8013f5 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  8013d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013d9:	c7 44 24 08 94 2d 80 	movl   $0x802d94,0x8(%esp)
  8013e0:	00 
  8013e1:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8013e8:	00 
  8013e9:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8013f0:	e8 9f ed ff ff       	call   800194 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  8013f5:	c7 44 24 04 34 24 80 	movl   $0x802434,0x4(%esp)
  8013fc:	00 
  8013fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801400:	89 04 24             	mov    %eax,(%esp)
  801403:	e8 cc fa ff ff       	call   800ed4 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801408:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80140f:	00 
  801410:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 29 fb ff ff       	call   800f44 <sys_env_set_status>
  80141b:	85 c0                	test   %eax,%eax
  80141d:	79 20                	jns    80143f <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80141f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801423:	c7 44 24 08 b8 2d 80 	movl   $0x802db8,0x8(%esp)
  80142a:	00 
  80142b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  801432:	00 
  801433:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80143a:	e8 55 ed ff ff       	call   800194 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80143f:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801446:	00 
  801447:	c7 44 24 04 a1 2c 80 	movl   $0x802ca1,0x4(%esp)
  80144e:	00 
  80144f:	c7 04 24 ce 2c 80 00 	movl   $0x802cce,(%esp)
  801456:	e8 f2 ed ff ff       	call   80024d <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  80145b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80145e:	83 c4 3c             	add    $0x3c,%esp
  801461:	5b                   	pop    %ebx
  801462:	5e                   	pop    %esi
  801463:	5f                   	pop    %edi
  801464:	5d                   	pop    %ebp
  801465:	c3                   	ret    

00801466 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	53                   	push   %ebx
  80146a:	83 ec 24             	sub    $0x24,%esp
  80146d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801470:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801472:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801475:	f6 c2 02             	test   $0x2,%dl
  801478:	75 2b                	jne    8014a5 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  80147a:	8b 40 28             	mov    0x28(%eax),%eax
  80147d:	89 44 24 14          	mov    %eax,0x14(%esp)
  801481:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801485:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801489:	c7 44 24 08 e0 2d 80 	movl   $0x802de0,0x8(%esp)
  801490:	00 
  801491:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801498:	00 
  801499:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8014a0:	e8 ef ec ff ff       	call   800194 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  8014a5:	89 d8                	mov    %ebx,%eax
  8014a7:	c1 e8 16             	shr    $0x16,%eax
  8014aa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014b1:	a8 01                	test   $0x1,%al
  8014b3:	74 11                	je     8014c6 <pgfault+0x60>
  8014b5:	89 d8                	mov    %ebx,%eax
  8014b7:	c1 e8 0c             	shr    $0xc,%eax
  8014ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c1:	f6 c4 08             	test   $0x8,%ah
  8014c4:	75 1c                	jne    8014e2 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  8014c6:	c7 44 24 08 1c 2e 80 	movl   $0x802e1c,0x8(%esp)
  8014cd:	00 
  8014ce:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8014d5:	00 
  8014d6:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8014dd:	e8 b2 ec ff ff       	call   800194 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8014e2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014e9:	00 
  8014ea:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014f1:	00 
  8014f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014f9:	e8 ef fa ff ff       	call   800fed <sys_page_alloc>
  8014fe:	85 c0                	test   %eax,%eax
  801500:	79 20                	jns    801522 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  801502:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801506:	c7 44 24 08 58 2e 80 	movl   $0x802e58,0x8(%esp)
  80150d:	00 
  80150e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801515:	00 
  801516:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80151d:	e8 72 ec ff ff       	call   800194 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801522:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  801528:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80152f:	00 
  801530:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801534:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80153b:	e8 35 f6 ff ff       	call   800b75 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801540:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801547:	00 
  801548:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80154c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801553:	00 
  801554:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80155b:	00 
  80155c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801563:	e8 4c fa ff ff       	call   800fb4 <sys_page_map>
  801568:	85 c0                	test   %eax,%eax
  80156a:	79 20                	jns    80158c <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  80156c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801570:	c7 44 24 08 80 2e 80 	movl   $0x802e80,0x8(%esp)
  801577:	00 
  801578:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80157f:	00 
  801580:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  801587:	e8 08 ec ff ff       	call   800194 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  80158c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801593:	00 
  801594:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159b:	e8 dc f9 ff ff       	call   800f7c <sys_page_unmap>
  8015a0:	85 c0                	test   %eax,%eax
  8015a2:	79 20                	jns    8015c4 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  8015a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a8:	c7 44 24 08 a4 2e 80 	movl   $0x802ea4,0x8(%esp)
  8015af:	00 
  8015b0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8015b7:	00 
  8015b8:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8015bf:	e8 d0 eb ff ff       	call   800194 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  8015c4:	83 c4 24             	add    $0x24,%esp
  8015c7:	5b                   	pop    %ebx
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    
  8015ca:	00 00                	add    %al,(%eax)
  8015cc:	00 00                	add    %al,(%eax)
	...

008015d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8015db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8015de:	5d                   	pop    %ebp
  8015df:	c3                   	ret    

008015e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8015e0:	55                   	push   %ebp
  8015e1:	89 e5                	mov    %esp,%ebp
  8015e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8015e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e9:	89 04 24             	mov    %eax,(%esp)
  8015ec:	e8 df ff ff ff       	call   8015d0 <fd2num>
  8015f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8015f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	57                   	push   %edi
  8015ff:	56                   	push   %esi
  801600:	53                   	push   %ebx
  801601:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801604:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801609:	a8 01                	test   $0x1,%al
  80160b:	74 36                	je     801643 <fd_alloc+0x48>
  80160d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801612:	a8 01                	test   $0x1,%al
  801614:	74 2d                	je     801643 <fd_alloc+0x48>
  801616:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80161b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801620:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801625:	89 c3                	mov    %eax,%ebx
  801627:	89 c2                	mov    %eax,%edx
  801629:	c1 ea 16             	shr    $0x16,%edx
  80162c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80162f:	f6 c2 01             	test   $0x1,%dl
  801632:	74 14                	je     801648 <fd_alloc+0x4d>
  801634:	89 c2                	mov    %eax,%edx
  801636:	c1 ea 0c             	shr    $0xc,%edx
  801639:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80163c:	f6 c2 01             	test   $0x1,%dl
  80163f:	75 10                	jne    801651 <fd_alloc+0x56>
  801641:	eb 05                	jmp    801648 <fd_alloc+0x4d>
  801643:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801648:	89 1f                	mov    %ebx,(%edi)
  80164a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80164f:	eb 17                	jmp    801668 <fd_alloc+0x6d>
  801651:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801656:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80165b:	75 c8                	jne    801625 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80165d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801663:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801670:	8b 45 08             	mov    0x8(%ebp),%eax
  801673:	83 f8 1f             	cmp    $0x1f,%eax
  801676:	77 36                	ja     8016ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801678:	05 00 00 0d 00       	add    $0xd0000,%eax
  80167d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801680:	89 c2                	mov    %eax,%edx
  801682:	c1 ea 16             	shr    $0x16,%edx
  801685:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80168c:	f6 c2 01             	test   $0x1,%dl
  80168f:	74 1d                	je     8016ae <fd_lookup+0x41>
  801691:	89 c2                	mov    %eax,%edx
  801693:	c1 ea 0c             	shr    $0xc,%edx
  801696:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80169d:	f6 c2 01             	test   $0x1,%dl
  8016a0:	74 0c                	je     8016ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8016a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a5:	89 02                	mov    %eax,(%edx)
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8016ac:	eb 05                	jmp    8016b3 <fd_lookup+0x46>
  8016ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	89 04 24             	mov    %eax,(%esp)
  8016c8:	e8 a0 ff ff ff       	call   80166d <fd_lookup>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 0e                	js     8016df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8016d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016d7:	89 50 04             	mov    %edx,0x4(%eax)
  8016da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	83 ec 10             	sub    $0x10,%esp
  8016e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8016ef:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8016f4:	b8 04 40 80 00       	mov    $0x804004,%eax
  8016f9:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  8016ff:	75 11                	jne    801712 <dev_lookup+0x31>
  801701:	eb 04                	jmp    801707 <dev_lookup+0x26>
  801703:	39 08                	cmp    %ecx,(%eax)
  801705:	75 10                	jne    801717 <dev_lookup+0x36>
			*dev = devtab[i];
  801707:	89 03                	mov    %eax,(%ebx)
  801709:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80170e:	66 90                	xchg   %ax,%ax
  801710:	eb 36                	jmp    801748 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801712:	be 48 2f 80 00       	mov    $0x802f48,%esi
  801717:	83 c2 01             	add    $0x1,%edx
  80171a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80171d:	85 c0                	test   %eax,%eax
  80171f:	75 e2                	jne    801703 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801721:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801726:	8b 40 48             	mov    0x48(%eax),%eax
  801729:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80172d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801731:	c7 04 24 c8 2e 80 00 	movl   $0x802ec8,(%esp)
  801738:	e8 10 eb ff ff       	call   80024d <cprintf>
	*dev = 0;
  80173d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801743:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	5b                   	pop    %ebx
  80174c:	5e                   	pop    %esi
  80174d:	5d                   	pop    %ebp
  80174e:	c3                   	ret    

0080174f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	53                   	push   %ebx
  801753:	83 ec 24             	sub    $0x24,%esp
  801756:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801759:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	e8 02 ff ff ff       	call   80166d <fd_lookup>
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 53                	js     8017c2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801779:	8b 00                	mov    (%eax),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 5e ff ff ff       	call   8016e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801783:	85 c0                	test   %eax,%eax
  801785:	78 3b                	js     8017c2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801787:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80178c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801793:	74 2d                	je     8017c2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801795:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801798:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80179f:	00 00 00 
	stat->st_isdir = 0;
  8017a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017a9:	00 00 00 
	stat->st_dev = dev;
  8017ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017bc:	89 14 24             	mov    %edx,(%esp)
  8017bf:	ff 50 14             	call   *0x14(%eax)
}
  8017c2:	83 c4 24             	add    $0x24,%esp
  8017c5:	5b                   	pop    %ebx
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 24             	sub    $0x24,%esp
  8017cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d9:	89 1c 24             	mov    %ebx,(%esp)
  8017dc:	e8 8c fe ff ff       	call   80166d <fd_lookup>
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 5f                	js     801844 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	8b 00                	mov    (%eax),%eax
  8017f1:	89 04 24             	mov    %eax,(%esp)
  8017f4:	e8 e8 fe ff ff       	call   8016e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 47                	js     801844 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801800:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801804:	75 23                	jne    801829 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801806:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80180b:	8b 40 48             	mov    0x48(%eax),%eax
  80180e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  80181d:	e8 2b ea ff ff       	call   80024d <cprintf>
  801822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801827:	eb 1b                	jmp    801844 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182c:	8b 48 18             	mov    0x18(%eax),%ecx
  80182f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801834:	85 c9                	test   %ecx,%ecx
  801836:	74 0c                	je     801844 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801838:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183f:	89 14 24             	mov    %edx,(%esp)
  801842:	ff d1                	call   *%ecx
}
  801844:	83 c4 24             	add    $0x24,%esp
  801847:	5b                   	pop    %ebx
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	53                   	push   %ebx
  80184e:	83 ec 24             	sub    $0x24,%esp
  801851:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801854:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185b:	89 1c 24             	mov    %ebx,(%esp)
  80185e:	e8 0a fe ff ff       	call   80166d <fd_lookup>
  801863:	85 c0                	test   %eax,%eax
  801865:	78 66                	js     8018cd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801867:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80186a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801871:	8b 00                	mov    (%eax),%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 66 fe ff ff       	call   8016e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 4e                	js     8018cd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80187f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801882:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801886:	75 23                	jne    8018ab <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801888:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80188d:	8b 40 48             	mov    0x48(%eax),%eax
  801890:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801894:	89 44 24 04          	mov    %eax,0x4(%esp)
  801898:	c7 04 24 0c 2f 80 00 	movl   $0x802f0c,(%esp)
  80189f:	e8 a9 e9 ff ff       	call   80024d <cprintf>
  8018a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8018a9:	eb 22                	jmp    8018cd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ae:	8b 48 0c             	mov    0xc(%eax),%ecx
  8018b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018b6:	85 c9                	test   %ecx,%ecx
  8018b8:	74 13                	je     8018cd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8018bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c8:	89 14 24             	mov    %edx,(%esp)
  8018cb:	ff d1                	call   *%ecx
}
  8018cd:	83 c4 24             	add    $0x24,%esp
  8018d0:	5b                   	pop    %ebx
  8018d1:	5d                   	pop    %ebp
  8018d2:	c3                   	ret    

008018d3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8018d3:	55                   	push   %ebp
  8018d4:	89 e5                	mov    %esp,%ebp
  8018d6:	53                   	push   %ebx
  8018d7:	83 ec 24             	sub    $0x24,%esp
  8018da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e4:	89 1c 24             	mov    %ebx,(%esp)
  8018e7:	e8 81 fd ff ff       	call   80166d <fd_lookup>
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 6b                	js     80195b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fa:	8b 00                	mov    (%eax),%eax
  8018fc:	89 04 24             	mov    %eax,(%esp)
  8018ff:	e8 dd fd ff ff       	call   8016e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801904:	85 c0                	test   %eax,%eax
  801906:	78 53                	js     80195b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801908:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80190b:	8b 42 08             	mov    0x8(%edx),%eax
  80190e:	83 e0 03             	and    $0x3,%eax
  801911:	83 f8 01             	cmp    $0x1,%eax
  801914:	75 23                	jne    801939 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801916:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80191b:	8b 40 48             	mov    0x48(%eax),%eax
  80191e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801922:	89 44 24 04          	mov    %eax,0x4(%esp)
  801926:	c7 04 24 29 2f 80 00 	movl   $0x802f29,(%esp)
  80192d:	e8 1b e9 ff ff       	call   80024d <cprintf>
  801932:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801937:	eb 22                	jmp    80195b <read+0x88>
	}
	if (!dev->dev_read)
  801939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193c:	8b 48 08             	mov    0x8(%eax),%ecx
  80193f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801944:	85 c9                	test   %ecx,%ecx
  801946:	74 13                	je     80195b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801948:	8b 45 10             	mov    0x10(%ebp),%eax
  80194b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80194f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801952:	89 44 24 04          	mov    %eax,0x4(%esp)
  801956:	89 14 24             	mov    %edx,(%esp)
  801959:	ff d1                	call   *%ecx
}
  80195b:	83 c4 24             	add    $0x24,%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	57                   	push   %edi
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	83 ec 1c             	sub    $0x1c,%esp
  80196a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80196d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801970:	ba 00 00 00 00       	mov    $0x0,%edx
  801975:	bb 00 00 00 00       	mov    $0x0,%ebx
  80197a:	b8 00 00 00 00       	mov    $0x0,%eax
  80197f:	85 f6                	test   %esi,%esi
  801981:	74 29                	je     8019ac <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801983:	89 f0                	mov    %esi,%eax
  801985:	29 d0                	sub    %edx,%eax
  801987:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198b:	03 55 0c             	add    0xc(%ebp),%edx
  80198e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801992:	89 3c 24             	mov    %edi,(%esp)
  801995:	e8 39 ff ff ff       	call   8018d3 <read>
		if (m < 0)
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 0e                	js     8019ac <readn+0x4b>
			return m;
		if (m == 0)
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	74 08                	je     8019aa <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8019a2:	01 c3                	add    %eax,%ebx
  8019a4:	89 da                	mov    %ebx,%edx
  8019a6:	39 f3                	cmp    %esi,%ebx
  8019a8:	72 d9                	jb     801983 <readn+0x22>
  8019aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8019ac:	83 c4 1c             	add    $0x1c,%esp
  8019af:	5b                   	pop    %ebx
  8019b0:	5e                   	pop    %esi
  8019b1:	5f                   	pop    %edi
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    

008019b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 28             	sub    $0x28,%esp
  8019ba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019bd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8019c0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8019c3:	89 34 24             	mov    %esi,(%esp)
  8019c6:	e8 05 fc ff ff       	call   8015d0 <fd2num>
  8019cb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8019ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019d2:	89 04 24             	mov    %eax,(%esp)
  8019d5:	e8 93 fc ff ff       	call   80166d <fd_lookup>
  8019da:	89 c3                	mov    %eax,%ebx
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 05                	js     8019e5 <fd_close+0x31>
  8019e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8019e3:	74 0e                	je     8019f3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8019e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ee:	0f 44 d8             	cmove  %eax,%ebx
  8019f1:	eb 3d                	jmp    801a30 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8019f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019fa:	8b 06                	mov    (%esi),%eax
  8019fc:	89 04 24             	mov    %eax,(%esp)
  8019ff:	e8 dd fc ff ff       	call   8016e1 <dev_lookup>
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 16                	js     801a20 <fd_close+0x6c>
		if (dev->dev_close)
  801a0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0d:	8b 40 10             	mov    0x10(%eax),%eax
  801a10:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a15:	85 c0                	test   %eax,%eax
  801a17:	74 07                	je     801a20 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801a19:	89 34 24             	mov    %esi,(%esp)
  801a1c:	ff d0                	call   *%eax
  801a1e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801a20:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a2b:	e8 4c f5 ff ff       	call   800f7c <sys_page_unmap>
	return r;
}
  801a30:	89 d8                	mov    %ebx,%eax
  801a32:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a35:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a38:	89 ec                	mov    %ebp,%esp
  801a3a:	5d                   	pop    %ebp
  801a3b:	c3                   	ret    

00801a3c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a49:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4c:	89 04 24             	mov    %eax,(%esp)
  801a4f:	e8 19 fc ff ff       	call   80166d <fd_lookup>
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 13                	js     801a6b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801a58:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801a5f:	00 
  801a60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a63:	89 04 24             	mov    %eax,(%esp)
  801a66:	e8 49 ff ff ff       	call   8019b4 <fd_close>
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 18             	sub    $0x18,%esp
  801a73:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a76:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a79:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a80:	00 
  801a81:	8b 45 08             	mov    0x8(%ebp),%eax
  801a84:	89 04 24             	mov    %eax,(%esp)
  801a87:	e8 78 03 00 00       	call   801e04 <open>
  801a8c:	89 c3                	mov    %eax,%ebx
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 1b                	js     801aad <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801a92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a99:	89 1c 24             	mov    %ebx,(%esp)
  801a9c:	e8 ae fc ff ff       	call   80174f <fstat>
  801aa1:	89 c6                	mov    %eax,%esi
	close(fd);
  801aa3:	89 1c 24             	mov    %ebx,(%esp)
  801aa6:	e8 91 ff ff ff       	call   801a3c <close>
  801aab:	89 f3                	mov    %esi,%ebx
	return r;
}
  801aad:	89 d8                	mov    %ebx,%eax
  801aaf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ab2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ab5:	89 ec                	mov    %ebp,%esp
  801ab7:	5d                   	pop    %ebp
  801ab8:	c3                   	ret    

00801ab9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	53                   	push   %ebx
  801abd:	83 ec 14             	sub    $0x14,%esp
  801ac0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801ac5:	89 1c 24             	mov    %ebx,(%esp)
  801ac8:	e8 6f ff ff ff       	call   801a3c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801acd:	83 c3 01             	add    $0x1,%ebx
  801ad0:	83 fb 20             	cmp    $0x20,%ebx
  801ad3:	75 f0                	jne    801ac5 <close_all+0xc>
		close(i);
}
  801ad5:	83 c4 14             	add    $0x14,%esp
  801ad8:	5b                   	pop    %ebx
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 58             	sub    $0x58,%esp
  801ae1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801ae4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ae7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801aea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801aed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801af0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af4:	8b 45 08             	mov    0x8(%ebp),%eax
  801af7:	89 04 24             	mov    %eax,(%esp)
  801afa:	e8 6e fb ff ff       	call   80166d <fd_lookup>
  801aff:	89 c3                	mov    %eax,%ebx
  801b01:	85 c0                	test   %eax,%eax
  801b03:	0f 88 e0 00 00 00    	js     801be9 <dup+0x10e>
		return r;
	close(newfdnum);
  801b09:	89 3c 24             	mov    %edi,(%esp)
  801b0c:	e8 2b ff ff ff       	call   801a3c <close>

	newfd = INDEX2FD(newfdnum);
  801b11:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801b17:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1d:	89 04 24             	mov    %eax,(%esp)
  801b20:	e8 bb fa ff ff       	call   8015e0 <fd2data>
  801b25:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801b27:	89 34 24             	mov    %esi,(%esp)
  801b2a:	e8 b1 fa ff ff       	call   8015e0 <fd2data>
  801b2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801b32:	89 da                	mov    %ebx,%edx
  801b34:	89 d8                	mov    %ebx,%eax
  801b36:	c1 e8 16             	shr    $0x16,%eax
  801b39:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801b40:	a8 01                	test   $0x1,%al
  801b42:	74 43                	je     801b87 <dup+0xac>
  801b44:	c1 ea 0c             	shr    $0xc,%edx
  801b47:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b4e:	a8 01                	test   $0x1,%al
  801b50:	74 35                	je     801b87 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801b52:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801b59:	25 07 0e 00 00       	and    $0xe07,%eax
  801b5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801b62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b70:	00 
  801b71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b7c:	e8 33 f4 ff ff       	call   800fb4 <sys_page_map>
  801b81:	89 c3                	mov    %eax,%ebx
  801b83:	85 c0                	test   %eax,%eax
  801b85:	78 3f                	js     801bc6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801b87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b8a:	89 c2                	mov    %eax,%edx
  801b8c:	c1 ea 0c             	shr    $0xc,%edx
  801b8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801b96:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801b9c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ba0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ba4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bab:	00 
  801bac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb7:	e8 f8 f3 ff ff       	call   800fb4 <sys_page_map>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 04                	js     801bc6 <dup+0xeb>
  801bc2:	89 fb                	mov    %edi,%ebx
  801bc4:	eb 23                	jmp    801be9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801bc6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801bca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd1:	e8 a6 f3 ff ff       	call   800f7c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801bd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801bd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be4:	e8 93 f3 ff ff       	call   800f7c <sys_page_unmap>
	return r;
}
  801be9:	89 d8                	mov    %ebx,%eax
  801beb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801bee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801bf1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801bf4:	89 ec                	mov    %ebp,%esp
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    

00801bf8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 18             	sub    $0x18,%esp
  801bfe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c01:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801c08:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c0f:	75 11                	jne    801c22 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c11:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801c18:	e8 43 08 00 00       	call   802460 <ipc_find_env>
  801c1d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c22:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c29:	00 
  801c2a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801c31:	00 
  801c32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c36:	a1 00 50 80 00       	mov    0x805000,%eax
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 61 08 00 00       	call   8024a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c4a:	00 
  801c4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c56:	e8 b4 08 00 00       	call   80250f <ipc_recv>
}
  801c5b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c5e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c61:	89 ec                	mov    %ebp,%esp
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c65:	55                   	push   %ebp
  801c66:	89 e5                	mov    %esp,%ebp
  801c68:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6e:	8b 40 0c             	mov    0xc(%eax),%eax
  801c71:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801c76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c79:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  801c83:	b8 02 00 00 00       	mov    $0x2,%eax
  801c88:	e8 6b ff ff ff       	call   801bf8 <fsipc>
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	8b 40 0c             	mov    0xc(%eax),%eax
  801c9b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ca0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca5:	b8 06 00 00 00       	mov    $0x6,%eax
  801caa:	e8 49 ff ff ff       	call   801bf8 <fsipc>
}
  801caf:	c9                   	leave  
  801cb0:	c3                   	ret    

00801cb1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cb7:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbc:	b8 08 00 00 00       	mov    $0x8,%eax
  801cc1:	e8 32 ff ff ff       	call   801bf8 <fsipc>
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	53                   	push   %ebx
  801ccc:	83 ec 14             	sub    $0x14,%esp
  801ccf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd8:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801cdd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce2:	b8 05 00 00 00       	mov    $0x5,%eax
  801ce7:	e8 0c ff ff ff       	call   801bf8 <fsipc>
  801cec:	85 c0                	test   %eax,%eax
  801cee:	78 2b                	js     801d1b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801cf0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cf7:	00 
  801cf8:	89 1c 24             	mov    %ebx,(%esp)
  801cfb:	e8 8a ec ff ff       	call   80098a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d00:	a1 80 60 80 00       	mov    0x806080,%eax
  801d05:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d0b:	a1 84 60 80 00       	mov    0x806084,%eax
  801d10:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801d1b:	83 c4 14             	add    $0x14,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 18             	sub    $0x18,%esp
  801d27:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  801d2d:	8b 52 0c             	mov    0xc(%edx),%edx
  801d30:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801d36:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801d3b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d40:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d45:	0f 47 c2             	cmova  %edx,%eax
  801d48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d53:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801d5a:	e8 16 ee ff ff       	call   800b75 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d64:	b8 04 00 00 00       	mov    $0x4,%eax
  801d69:	e8 8a fe ff ff       	call   801bf8 <fsipc>
}
  801d6e:	c9                   	leave  
  801d6f:	c3                   	ret    

00801d70 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	53                   	push   %ebx
  801d74:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801d77:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d7d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801d82:	8b 45 10             	mov    0x10(%ebp),%eax
  801d85:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801d8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8f:	b8 03 00 00 00       	mov    $0x3,%eax
  801d94:	e8 5f fe ff ff       	call   801bf8 <fsipc>
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	78 17                	js     801db6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801d9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801da3:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801daa:	00 
  801dab:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dae:	89 04 24             	mov    %eax,(%esp)
  801db1:	e8 bf ed ff ff       	call   800b75 <memmove>
  return r;	
}
  801db6:	89 d8                	mov    %ebx,%eax
  801db8:	83 c4 14             	add    $0x14,%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	53                   	push   %ebx
  801dc2:	83 ec 14             	sub    $0x14,%esp
  801dc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801dc8:	89 1c 24             	mov    %ebx,(%esp)
  801dcb:	e8 70 eb ff ff       	call   800940 <strlen>
  801dd0:	89 c2                	mov    %eax,%edx
  801dd2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801dd7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ddd:	7f 1f                	jg     801dfe <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801ddf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801de3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801dea:	e8 9b eb ff ff       	call   80098a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801def:	ba 00 00 00 00       	mov    $0x0,%edx
  801df4:	b8 07 00 00 00       	mov    $0x7,%eax
  801df9:	e8 fa fd ff ff       	call   801bf8 <fsipc>
}
  801dfe:	83 c4 14             	add    $0x14,%esp
  801e01:	5b                   	pop    %ebx
  801e02:	5d                   	pop    %ebp
  801e03:	c3                   	ret    

00801e04 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801e04:	55                   	push   %ebp
  801e05:	89 e5                	mov    %esp,%ebp
  801e07:	83 ec 28             	sub    $0x28,%esp
  801e0a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e0d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801e10:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801e13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e16:	89 04 24             	mov    %eax,(%esp)
  801e19:	e8 dd f7 ff ff       	call   8015fb <fd_alloc>
  801e1e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801e20:	85 c0                	test   %eax,%eax
  801e22:	0f 88 89 00 00 00    	js     801eb1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801e28:	89 34 24             	mov    %esi,(%esp)
  801e2b:	e8 10 eb ff ff       	call   800940 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801e30:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801e35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e3a:	7f 75                	jg     801eb1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801e3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e40:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801e47:	e8 3e eb ff ff       	call   80098a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801e4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801e54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e57:	b8 01 00 00 00       	mov    $0x1,%eax
  801e5c:	e8 97 fd ff ff       	call   801bf8 <fsipc>
  801e61:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801e63:	85 c0                	test   %eax,%eax
  801e65:	78 0f                	js     801e76 <open+0x72>
  return fd2num(fd);
  801e67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6a:	89 04 24             	mov    %eax,(%esp)
  801e6d:	e8 5e f7 ff ff       	call   8015d0 <fd2num>
  801e72:	89 c3                	mov    %eax,%ebx
  801e74:	eb 3b                	jmp    801eb1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801e76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801e7d:	00 
  801e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e81:	89 04 24             	mov    %eax,(%esp)
  801e84:	e8 2b fb ff ff       	call   8019b4 <fd_close>
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	74 24                	je     801eb1 <open+0xad>
  801e8d:	c7 44 24 0c 54 2f 80 	movl   $0x802f54,0xc(%esp)
  801e94:	00 
  801e95:	c7 44 24 08 69 2f 80 	movl   $0x802f69,0x8(%esp)
  801e9c:	00 
  801e9d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801ea4:	00 
  801ea5:	c7 04 24 7e 2f 80 00 	movl   $0x802f7e,(%esp)
  801eac:	e8 e3 e2 ff ff       	call   800194 <_panic>
  return r;
}
  801eb1:	89 d8                	mov    %ebx,%eax
  801eb3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801eb6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801eb9:	89 ec                	mov    %ebp,%esp
  801ebb:	5d                   	pop    %ebp
  801ebc:	c3                   	ret    
  801ebd:	00 00                	add    %al,(%eax)
	...

00801ec0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ec6:	c7 44 24 04 89 2f 80 	movl   $0x802f89,0x4(%esp)
  801ecd:	00 
  801ece:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed1:	89 04 24             	mov    %eax,(%esp)
  801ed4:	e8 b1 ea ff ff       	call   80098a <strcpy>
	return 0;
}
  801ed9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ede:	c9                   	leave  
  801edf:	c3                   	ret    

00801ee0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 14             	sub    $0x14,%esp
  801ee7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801eea:	89 1c 24             	mov    %ebx,(%esp)
  801eed:	e8 aa 06 00 00       	call   80259c <pageref>
  801ef2:	89 c2                	mov    %eax,%edx
  801ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef9:	83 fa 01             	cmp    $0x1,%edx
  801efc:	75 0b                	jne    801f09 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801efe:	8b 43 0c             	mov    0xc(%ebx),%eax
  801f01:	89 04 24             	mov    %eax,(%esp)
  801f04:	e8 b9 02 00 00       	call   8021c2 <nsipc_close>
	else
		return 0;
}
  801f09:	83 c4 14             	add    $0x14,%esp
  801f0c:	5b                   	pop    %ebx
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801f15:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f1c:	00 
  801f1d:	8b 45 10             	mov    0x10(%ebp),%eax
  801f20:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f31:	89 04 24             	mov    %eax,(%esp)
  801f34:	e8 c5 02 00 00       	call   8021fe <nsipc_send>
}
  801f39:	c9                   	leave  
  801f3a:	c3                   	ret    

00801f3b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801f41:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f48:	00 
  801f49:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f57:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5a:	8b 40 0c             	mov    0xc(%eax),%eax
  801f5d:	89 04 24             	mov    %eax,(%esp)
  801f60:	e8 0c 03 00 00       	call   802271 <nsipc_recv>
}
  801f65:	c9                   	leave  
  801f66:	c3                   	ret    

00801f67 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801f67:	55                   	push   %ebp
  801f68:	89 e5                	mov    %esp,%ebp
  801f6a:	56                   	push   %esi
  801f6b:	53                   	push   %ebx
  801f6c:	83 ec 20             	sub    $0x20,%esp
  801f6f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f74:	89 04 24             	mov    %eax,(%esp)
  801f77:	e8 7f f6 ff ff       	call   8015fb <fd_alloc>
  801f7c:	89 c3                	mov    %eax,%ebx
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	78 21                	js     801fa3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801f82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f89:	00 
  801f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f98:	e8 50 f0 ff ff       	call   800fed <sys_page_alloc>
  801f9d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	79 0a                	jns    801fad <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801fa3:	89 34 24             	mov    %esi,(%esp)
  801fa6:	e8 17 02 00 00       	call   8021c2 <nsipc_close>
		return r;
  801fab:	eb 28                	jmp    801fd5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801fad:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fbb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	89 04 24             	mov    %eax,(%esp)
  801fce:	e8 fd f5 ff ff       	call   8015d0 <fd2num>
  801fd3:	89 c3                	mov    %eax,%ebx
}
  801fd5:	89 d8                	mov    %ebx,%eax
  801fd7:	83 c4 20             	add    $0x20,%esp
  801fda:	5b                   	pop    %ebx
  801fdb:	5e                   	pop    %esi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801feb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fee:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff5:	89 04 24             	mov    %eax,(%esp)
  801ff8:	e8 79 01 00 00       	call   802176 <nsipc_socket>
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 05                	js     802006 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802001:	e8 61 ff ff ff       	call   801f67 <alloc_sockfd>
}
  802006:	c9                   	leave  
  802007:	c3                   	ret    

00802008 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80200e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802011:	89 54 24 04          	mov    %edx,0x4(%esp)
  802015:	89 04 24             	mov    %eax,(%esp)
  802018:	e8 50 f6 ff ff       	call   80166d <fd_lookup>
  80201d:	85 c0                	test   %eax,%eax
  80201f:	78 15                	js     802036 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802021:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802024:	8b 0a                	mov    (%edx),%ecx
  802026:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80202b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802031:	75 03                	jne    802036 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802033:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802036:	c9                   	leave  
  802037:	c3                   	ret    

00802038 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80203e:	8b 45 08             	mov    0x8(%ebp),%eax
  802041:	e8 c2 ff ff ff       	call   802008 <fd2sockid>
  802046:	85 c0                	test   %eax,%eax
  802048:	78 0f                	js     802059 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80204a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80204d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802051:	89 04 24             	mov    %eax,(%esp)
  802054:	e8 47 01 00 00       	call   8021a0 <nsipc_listen>
}
  802059:	c9                   	leave  
  80205a:	c3                   	ret    

0080205b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80205b:	55                   	push   %ebp
  80205c:	89 e5                	mov    %esp,%ebp
  80205e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802061:	8b 45 08             	mov    0x8(%ebp),%eax
  802064:	e8 9f ff ff ff       	call   802008 <fd2sockid>
  802069:	85 c0                	test   %eax,%eax
  80206b:	78 16                	js     802083 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80206d:	8b 55 10             	mov    0x10(%ebp),%edx
  802070:	89 54 24 08          	mov    %edx,0x8(%esp)
  802074:	8b 55 0c             	mov    0xc(%ebp),%edx
  802077:	89 54 24 04          	mov    %edx,0x4(%esp)
  80207b:	89 04 24             	mov    %eax,(%esp)
  80207e:	e8 6e 02 00 00       	call   8022f1 <nsipc_connect>
}
  802083:	c9                   	leave  
  802084:	c3                   	ret    

00802085 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80208b:	8b 45 08             	mov    0x8(%ebp),%eax
  80208e:	e8 75 ff ff ff       	call   802008 <fd2sockid>
  802093:	85 c0                	test   %eax,%eax
  802095:	78 0f                	js     8020a6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802097:	8b 55 0c             	mov    0xc(%ebp),%edx
  80209a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80209e:	89 04 24             	mov    %eax,(%esp)
  8020a1:	e8 36 01 00 00       	call   8021dc <nsipc_shutdown>
}
  8020a6:	c9                   	leave  
  8020a7:	c3                   	ret    

008020a8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8020a8:	55                   	push   %ebp
  8020a9:	89 e5                	mov    %esp,%ebp
  8020ab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b1:	e8 52 ff ff ff       	call   802008 <fd2sockid>
  8020b6:	85 c0                	test   %eax,%eax
  8020b8:	78 16                	js     8020d0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8020ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8020bd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020c8:	89 04 24             	mov    %eax,(%esp)
  8020cb:	e8 60 02 00 00       	call   802330 <nsipc_bind>
}
  8020d0:	c9                   	leave  
  8020d1:	c3                   	ret    

008020d2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8020d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020db:	e8 28 ff ff ff       	call   802008 <fd2sockid>
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	78 1f                	js     802103 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8020e4:	8b 55 10             	mov    0x10(%ebp),%edx
  8020e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020f2:	89 04 24             	mov    %eax,(%esp)
  8020f5:	e8 75 02 00 00       	call   80236f <nsipc_accept>
  8020fa:	85 c0                	test   %eax,%eax
  8020fc:	78 05                	js     802103 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8020fe:	e8 64 fe ff ff       	call   801f67 <alloc_sockfd>
}
  802103:	c9                   	leave  
  802104:	c3                   	ret    
	...

00802110 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	53                   	push   %ebx
  802114:	83 ec 14             	sub    $0x14,%esp
  802117:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802119:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802120:	75 11                	jne    802133 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802122:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802129:	e8 32 03 00 00       	call   802460 <ipc_find_env>
  80212e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802133:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80213a:	00 
  80213b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802142:	00 
  802143:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802147:	a1 04 50 80 00       	mov    0x805004,%eax
  80214c:	89 04 24             	mov    %eax,(%esp)
  80214f:	e8 50 03 00 00       	call   8024a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802154:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80215b:	00 
  80215c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802163:	00 
  802164:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80216b:	e8 9f 03 00 00       	call   80250f <ipc_recv>
}
  802170:	83 c4 14             	add    $0x14,%esp
  802173:	5b                   	pop    %ebx
  802174:	5d                   	pop    %ebp
  802175:	c3                   	ret    

00802176 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802176:	55                   	push   %ebp
  802177:	89 e5                	mov    %esp,%ebp
  802179:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80217c:	8b 45 08             	mov    0x8(%ebp),%eax
  80217f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802184:	8b 45 0c             	mov    0xc(%ebp),%eax
  802187:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80218c:	8b 45 10             	mov    0x10(%ebp),%eax
  80218f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802194:	b8 09 00 00 00       	mov    $0x9,%eax
  802199:	e8 72 ff ff ff       	call   802110 <nsipc>
}
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8021a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8021ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021b1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8021b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8021bb:	e8 50 ff ff ff       	call   802110 <nsipc>
}
  8021c0:	c9                   	leave  
  8021c1:	c3                   	ret    

008021c2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8021c2:	55                   	push   %ebp
  8021c3:	89 e5                	mov    %esp,%ebp
  8021c5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8021c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021cb:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8021d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8021d5:	e8 36 ff ff ff       	call   802110 <nsipc>
}
  8021da:	c9                   	leave  
  8021db:	c3                   	ret    

008021dc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8021dc:	55                   	push   %ebp
  8021dd:	89 e5                	mov    %esp,%ebp
  8021df:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8021e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8021ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ed:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8021f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8021f7:	e8 14 ff ff ff       	call   802110 <nsipc>
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
  802201:	53                   	push   %ebx
  802202:	83 ec 14             	sub    $0x14,%esp
  802205:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802208:	8b 45 08             	mov    0x8(%ebp),%eax
  80220b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802210:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802216:	7e 24                	jle    80223c <nsipc_send+0x3e>
  802218:	c7 44 24 0c 95 2f 80 	movl   $0x802f95,0xc(%esp)
  80221f:	00 
  802220:	c7 44 24 08 69 2f 80 	movl   $0x802f69,0x8(%esp)
  802227:	00 
  802228:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80222f:	00 
  802230:	c7 04 24 a1 2f 80 00 	movl   $0x802fa1,(%esp)
  802237:	e8 58 df ff ff       	call   800194 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80223c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802240:	8b 45 0c             	mov    0xc(%ebp),%eax
  802243:	89 44 24 04          	mov    %eax,0x4(%esp)
  802247:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80224e:	e8 22 e9 ff ff       	call   800b75 <memmove>
	nsipcbuf.send.req_size = size;
  802253:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802259:	8b 45 14             	mov    0x14(%ebp),%eax
  80225c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802261:	b8 08 00 00 00       	mov    $0x8,%eax
  802266:	e8 a5 fe ff ff       	call   802110 <nsipc>
}
  80226b:	83 c4 14             	add    $0x14,%esp
  80226e:	5b                   	pop    %ebx
  80226f:	5d                   	pop    %ebp
  802270:	c3                   	ret    

00802271 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	56                   	push   %esi
  802275:	53                   	push   %ebx
  802276:	83 ec 10             	sub    $0x10,%esp
  802279:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80227c:	8b 45 08             	mov    0x8(%ebp),%eax
  80227f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802284:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80228a:	8b 45 14             	mov    0x14(%ebp),%eax
  80228d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802292:	b8 07 00 00 00       	mov    $0x7,%eax
  802297:	e8 74 fe ff ff       	call   802110 <nsipc>
  80229c:	89 c3                	mov    %eax,%ebx
  80229e:	85 c0                	test   %eax,%eax
  8022a0:	78 46                	js     8022e8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8022a2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8022a7:	7f 04                	jg     8022ad <nsipc_recv+0x3c>
  8022a9:	39 c6                	cmp    %eax,%esi
  8022ab:	7d 24                	jge    8022d1 <nsipc_recv+0x60>
  8022ad:	c7 44 24 0c ad 2f 80 	movl   $0x802fad,0xc(%esp)
  8022b4:	00 
  8022b5:	c7 44 24 08 69 2f 80 	movl   $0x802f69,0x8(%esp)
  8022bc:	00 
  8022bd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8022c4:	00 
  8022c5:	c7 04 24 a1 2f 80 00 	movl   $0x802fa1,(%esp)
  8022cc:	e8 c3 de ff ff       	call   800194 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8022d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8022dc:	00 
  8022dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e0:	89 04 24             	mov    %eax,(%esp)
  8022e3:	e8 8d e8 ff ff       	call   800b75 <memmove>
	}

	return r;
}
  8022e8:	89 d8                	mov    %ebx,%eax
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5d                   	pop    %ebp
  8022f0:	c3                   	ret    

008022f1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8022f1:	55                   	push   %ebp
  8022f2:	89 e5                	mov    %esp,%ebp
  8022f4:	53                   	push   %ebx
  8022f5:	83 ec 14             	sub    $0x14,%esp
  8022f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8022fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022fe:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802303:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802307:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80230e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802315:	e8 5b e8 ff ff       	call   800b75 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80231a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802320:	b8 05 00 00 00       	mov    $0x5,%eax
  802325:	e8 e6 fd ff ff       	call   802110 <nsipc>
}
  80232a:	83 c4 14             	add    $0x14,%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5d                   	pop    %ebp
  80232f:	c3                   	ret    

00802330 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	53                   	push   %ebx
  802334:	83 ec 14             	sub    $0x14,%esp
  802337:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80233a:	8b 45 08             	mov    0x8(%ebp),%eax
  80233d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802342:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802346:	8b 45 0c             	mov    0xc(%ebp),%eax
  802349:	89 44 24 04          	mov    %eax,0x4(%esp)
  80234d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802354:	e8 1c e8 ff ff       	call   800b75 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802359:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80235f:	b8 02 00 00 00       	mov    $0x2,%eax
  802364:	e8 a7 fd ff ff       	call   802110 <nsipc>
}
  802369:	83 c4 14             	add    $0x14,%esp
  80236c:	5b                   	pop    %ebx
  80236d:	5d                   	pop    %ebp
  80236e:	c3                   	ret    

0080236f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	83 ec 18             	sub    $0x18,%esp
  802375:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802378:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80237b:	8b 45 08             	mov    0x8(%ebp),%eax
  80237e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802383:	b8 01 00 00 00       	mov    $0x1,%eax
  802388:	e8 83 fd ff ff       	call   802110 <nsipc>
  80238d:	89 c3                	mov    %eax,%ebx
  80238f:	85 c0                	test   %eax,%eax
  802391:	78 25                	js     8023b8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802393:	be 10 70 80 00       	mov    $0x807010,%esi
  802398:	8b 06                	mov    (%esi),%eax
  80239a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80239e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8023a5:	00 
  8023a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a9:	89 04 24             	mov    %eax,(%esp)
  8023ac:	e8 c4 e7 ff ff       	call   800b75 <memmove>
		*addrlen = ret->ret_addrlen;
  8023b1:	8b 16                	mov    (%esi),%edx
  8023b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8023b6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8023bd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8023c0:	89 ec                	mov    %ebp,%esp
  8023c2:	5d                   	pop    %ebp
  8023c3:	c3                   	ret    

008023c4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023ca:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  8023d1:	75 54                	jne    802427 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8023d3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8023da:	00 
  8023db:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8023e2:	ee 
  8023e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ea:	e8 fe eb ff ff       	call   800fed <sys_page_alloc>
  8023ef:	85 c0                	test   %eax,%eax
  8023f1:	79 20                	jns    802413 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8023f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023f7:	c7 44 24 08 c2 2f 80 	movl   $0x802fc2,0x8(%esp)
  8023fe:	00 
  8023ff:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802406:	00 
  802407:	c7 04 24 da 2f 80 00 	movl   $0x802fda,(%esp)
  80240e:	e8 81 dd ff ff       	call   800194 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  802413:	c7 44 24 04 34 24 80 	movl   $0x802434,0x4(%esp)
  80241a:	00 
  80241b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802422:	e8 ad ea ff ff       	call   800ed4 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802427:	8b 45 08             	mov    0x8(%ebp),%eax
  80242a:	a3 00 80 80 00       	mov    %eax,0x808000
}
  80242f:	c9                   	leave  
  802430:	c3                   	ret    
  802431:	00 00                	add    %al,(%eax)
	...

00802434 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802434:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802435:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  80243a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80243c:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  80243f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802443:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802446:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  80244a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80244e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802450:	83 c4 08             	add    $0x8,%esp
	popal
  802453:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  802454:	83 c4 04             	add    $0x4,%esp
	popfl
  802457:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802458:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802459:	c3                   	ret    
  80245a:	00 00                	add    %al,(%eax)
  80245c:	00 00                	add    %al,(%eax)
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
  8024cb:	c7 44 24 08 e8 2f 80 	movl   $0x802fe8,0x8(%esp)
  8024d2:	00 
  8024d3:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8024da:	00 
  8024db:	c7 04 24 06 30 80 00 	movl   $0x803006,(%esp)
  8024e2:	e8 ad dc ff ff       	call   800194 <_panic>
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
  8024f9:	e8 a0 e9 ff ff       	call   800e9e <sys_ipc_try_send>
  8024fe:	85 c0                	test   %eax,%eax
  802500:	75 c0                	jne    8024c2 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802502:	e8 1d eb ff ff       	call   801024 <sys_yield>
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
  802534:	e8 2c e9 ff ff       	call   800e65 <sys_ipc_recv>
  802539:	89 c3                	mov    %eax,%ebx
  80253b:	85 c0                	test   %eax,%eax
  80253d:	79 2a                	jns    802569 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80253f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802543:	89 44 24 04          	mov    %eax,0x4(%esp)
  802547:	c7 04 24 10 30 80 00 	movl   $0x803010,(%esp)
  80254e:	e8 fa dc ff ff       	call   80024d <cprintf>
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
  80256d:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802572:	8b 40 74             	mov    0x74(%eax),%eax
  802575:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802577:	85 ff                	test   %edi,%edi
  802579:	74 0a                	je     802585 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  80257b:	a1 0c 50 80 00       	mov    0x80500c,%eax
  802580:	8b 40 78             	mov    0x78(%eax),%eax
  802583:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802585:	a1 0c 50 80 00       	mov    0x80500c,%eax
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
