
obj/user/faultallocbad.debug:     file format elf32-i386


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
  80002c:	e8 b3 00 00 00       	call   8000e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  80003a:	c7 04 24 5c 00 80 00 	movl   $0x80005c,(%esp)
  800041:	e8 fa 10 00 00       	call   801140 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800046:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80004d:	00 
  80004e:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  800055:	e8 ac 10 00 00       	call   801106 <sys_cputs>
}
  80005a:	c9                   	leave  
  80005b:	c3                   	ret    

0080005c <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	53                   	push   %ebx
  800060:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800063:	8b 45 08             	mov    0x8(%ebp),%eax
  800066:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800068:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80006c:	c7 04 24 e0 23 80 00 	movl   $0x8023e0,(%esp)
  800073:	e8 91 01 00 00       	call   800209 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007f:	00 
  800080:	89 d8                	mov    %ebx,%eax
  800082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 16 0f 00 00       	call   800fad <sys_page_alloc>
  800097:	85 c0                	test   %eax,%eax
  800099:	79 24                	jns    8000bf <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a3:	c7 44 24 08 00 24 80 	movl   $0x802400,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 ea 23 80 00 	movl   $0x8023ea,(%esp)
  8000ba:	e8 91 00 00 00       	call   800150 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c3:	c7 44 24 08 2c 24 80 	movl   $0x80242c,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000d2:	00 
  8000d3:	89 1c 24             	mov    %ebx,(%esp)
  8000d6:	e8 cd 07 00 00       	call   8008a8 <snprintf>
}
  8000db:	83 c4 24             	add    $0x24,%esp
  8000de:	5b                   	pop    %ebx
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
  8000ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8000f6:	e8 5c 0f 00 00       	call   801057 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	c1 e0 07             	shl    $0x7,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010d:	85 f6                	test   %esi,%esi
  80010f:	7e 07                	jle    800118 <libmain+0x34>
		binaryname = argv[0];
  800111:	8b 03                	mov    (%ebx),%eax
  800113:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800118:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80011c:	89 34 24             	mov    %esi,(%esp)
  80011f:	e8 10 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800124:	e8 0b 00 00 00       	call   800134 <exit>
}
  800129:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80012c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80012f:	89 ec                	mov    %ebp,%esp
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    
	...

00800134 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80013a:	e8 8a 15 00 00       	call   8016c9 <close_all>
	sys_env_destroy(0);
  80013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800146:	e8 47 0f 00 00       	call   801092 <sys_env_destroy>
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    
  80014d:	00 00                	add    %al,(%eax)
	...

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800158:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800161:	e8 f1 0e 00 00       	call   801057 <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 58 24 80 00 	movl   $0x802458,(%esp)
  800183:	e8 81 00 00 00       	call   800209 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 11 00 00 00       	call   8001a8 <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 cf 28 80 00 	movl   $0x8028cf,(%esp)
  80019e:	e8 66 00 00 00       	call   800209 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x53>
	...

008001a8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001b1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b8:	00 00 00 
	b.cnt = 0;
  8001bb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001dd:	c7 04 24 23 02 80 00 	movl   $0x800223,(%esp)
  8001e4:	e8 d4 01 00 00       	call   8003bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f9:	89 04 24             	mov    %eax,(%esp)
  8001fc:	e8 05 0f 00 00       	call   801106 <sys_cputs>

	return b.cnt;
}
  800201:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80020f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800212:	89 44 24 04          	mov    %eax,0x4(%esp)
  800216:	8b 45 08             	mov    0x8(%ebp),%eax
  800219:	89 04 24             	mov    %eax,(%esp)
  80021c:	e8 87 ff ff ff       	call   8001a8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	53                   	push   %ebx
  800227:	83 ec 14             	sub    $0x14,%esp
  80022a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022d:	8b 03                	mov    (%ebx),%eax
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800236:	83 c0 01             	add    $0x1,%eax
  800239:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80023b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800240:	75 19                	jne    80025b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800242:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800249:	00 
  80024a:	8d 43 08             	lea    0x8(%ebx),%eax
  80024d:	89 04 24             	mov    %eax,(%esp)
  800250:	e8 b1 0e 00 00       	call   801106 <sys_cputs>
		b->idx = 0;
  800255:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80025b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	5b                   	pop    %ebx
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    
	...

00800270 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 4c             	sub    $0x4c,%esp
  800279:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80027c:	89 d6                	mov    %edx,%esi
  80027e:	8b 45 08             	mov    0x8(%ebp),%eax
  800281:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800284:	8b 55 0c             	mov    0xc(%ebp),%edx
  800287:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80028a:	8b 45 10             	mov    0x10(%ebp),%eax
  80028d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800290:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800293:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800296:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029b:	39 d1                	cmp    %edx,%ecx
  80029d:	72 15                	jb     8002b4 <printnum+0x44>
  80029f:	77 07                	ja     8002a8 <printnum+0x38>
  8002a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002a4:	39 d0                	cmp    %edx,%eax
  8002a6:	76 0c                	jbe    8002b4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002a8:	83 eb 01             	sub    $0x1,%ebx
  8002ab:	85 db                	test   %ebx,%ebx
  8002ad:	8d 76 00             	lea    0x0(%esi),%esi
  8002b0:	7f 61                	jg     800313 <printnum+0xa3>
  8002b2:	eb 70                	jmp    800324 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002c7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002cb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002ce:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002df:	00 
  8002e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002e3:	89 04 24             	mov    %eax,(%esp)
  8002e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ed:	e8 7e 1e 00 00       	call   802170 <__udivdi3>
  8002f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002fc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	89 54 24 04          	mov    %edx,0x4(%esp)
  800307:	89 f2                	mov    %esi,%edx
  800309:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80030c:	e8 5f ff ff ff       	call   800270 <printnum>
  800311:	eb 11                	jmp    800324 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800313:	89 74 24 04          	mov    %esi,0x4(%esp)
  800317:	89 3c 24             	mov    %edi,(%esp)
  80031a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80031d:	83 eb 01             	sub    $0x1,%ebx
  800320:	85 db                	test   %ebx,%ebx
  800322:	7f ef                	jg     800313 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800324:	89 74 24 04          	mov    %esi,0x4(%esp)
  800328:	8b 74 24 04          	mov    0x4(%esp),%esi
  80032c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800333:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033a:	00 
  80033b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80033e:	89 14 24             	mov    %edx,(%esp)
  800341:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800344:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800348:	e8 53 1f 00 00       	call   8022a0 <__umoddi3>
  80034d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800351:	0f be 80 7b 24 80 00 	movsbl 0x80247b(%eax),%eax
  800358:	89 04 24             	mov    %eax,(%esp)
  80035b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80035e:	83 c4 4c             	add    $0x4c,%esp
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800369:	83 fa 01             	cmp    $0x1,%edx
  80036c:	7e 0e                	jle    80037c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	8d 4a 08             	lea    0x8(%edx),%ecx
  800373:	89 08                	mov    %ecx,(%eax)
  800375:	8b 02                	mov    (%edx),%eax
  800377:	8b 52 04             	mov    0x4(%edx),%edx
  80037a:	eb 22                	jmp    80039e <getuint+0x38>
	else if (lflag)
  80037c:	85 d2                	test   %edx,%edx
  80037e:	74 10                	je     800390 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
  80038e:	eb 0e                	jmp    80039e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 04             	lea    0x4(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003aa:	8b 10                	mov    (%eax),%edx
  8003ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8003af:	73 0a                	jae    8003bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b4:	88 0a                	mov    %cl,(%edx)
  8003b6:	83 c2 01             	add    $0x1,%edx
  8003b9:	89 10                	mov    %edx,(%eax)
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	57                   	push   %edi
  8003c1:	56                   	push   %esi
  8003c2:	53                   	push   %ebx
  8003c3:	83 ec 5c             	sub    $0x5c,%esp
  8003c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003cf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003d6:	eb 11                	jmp    8003e9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003d8:	85 c0                	test   %eax,%eax
  8003da:	0f 84 68 04 00 00    	je     800848 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8003e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e4:	89 04 24             	mov    %eax,(%esp)
  8003e7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e9:	0f b6 03             	movzbl (%ebx),%eax
  8003ec:	83 c3 01             	add    $0x1,%ebx
  8003ef:	83 f8 25             	cmp    $0x25,%eax
  8003f2:	75 e4                	jne    8003d8 <vprintfmt+0x1b>
  8003f4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003fb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800402:	b9 00 00 00 00       	mov    $0x0,%ecx
  800407:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80040b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800412:	eb 06                	jmp    80041a <vprintfmt+0x5d>
  800414:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800418:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	0f b6 13             	movzbl (%ebx),%edx
  80041d:	0f b6 c2             	movzbl %dl,%eax
  800420:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800423:	8d 43 01             	lea    0x1(%ebx),%eax
  800426:	83 ea 23             	sub    $0x23,%edx
  800429:	80 fa 55             	cmp    $0x55,%dl
  80042c:	0f 87 f9 03 00 00    	ja     80082b <vprintfmt+0x46e>
  800432:	0f b6 d2             	movzbl %dl,%edx
  800435:	ff 24 95 60 26 80 00 	jmp    *0x802660(,%edx,4)
  80043c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800440:	eb d6                	jmp    800418 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800442:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800445:	83 ea 30             	sub    $0x30,%edx
  800448:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80044b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80044e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800451:	83 fb 09             	cmp    $0x9,%ebx
  800454:	77 54                	ja     8004aa <vprintfmt+0xed>
  800456:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800459:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80045c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80045f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800462:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800466:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800469:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80046c:	83 fb 09             	cmp    $0x9,%ebx
  80046f:	76 eb                	jbe    80045c <vprintfmt+0x9f>
  800471:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800474:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800477:	eb 31                	jmp    8004aa <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800479:	8b 55 14             	mov    0x14(%ebp),%edx
  80047c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80047f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800482:	8b 12                	mov    (%edx),%edx
  800484:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800487:	eb 21                	jmp    8004aa <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800489:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80048d:	ba 00 00 00 00       	mov    $0x0,%edx
  800492:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800496:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800499:	e9 7a ff ff ff       	jmp    800418 <vprintfmt+0x5b>
  80049e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004a5:	e9 6e ff ff ff       	jmp    800418 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ae:	0f 89 64 ff ff ff    	jns    800418 <vprintfmt+0x5b>
  8004b4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004ba:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004bd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004c0:	e9 53 ff ff ff       	jmp    800418 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004c5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004c8:	e9 4b ff ff ff       	jmp    800418 <vprintfmt+0x5b>
  8004cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d3:	8d 50 04             	lea    0x4(%eax),%edx
  8004d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004dd:	8b 00                	mov    (%eax),%eax
  8004df:	89 04 24             	mov    %eax,(%esp)
  8004e2:	ff d7                	call   *%edi
  8004e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004e7:	e9 fd fe ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  8004ec:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 50 04             	lea    0x4(%eax),%edx
  8004f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f8:	8b 00                	mov    (%eax),%eax
  8004fa:	89 c2                	mov    %eax,%edx
  8004fc:	c1 fa 1f             	sar    $0x1f,%edx
  8004ff:	31 d0                	xor    %edx,%eax
  800501:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800503:	83 f8 0f             	cmp    $0xf,%eax
  800506:	7f 0b                	jg     800513 <vprintfmt+0x156>
  800508:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  80050f:	85 d2                	test   %edx,%edx
  800511:	75 20                	jne    800533 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800513:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800517:	c7 44 24 08 8c 24 80 	movl   $0x80248c,0x8(%esp)
  80051e:	00 
  80051f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800523:	89 3c 24             	mov    %edi,(%esp)
  800526:	e8 a5 03 00 00       	call   8008d0 <printfmt>
  80052b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80052e:	e9 b6 fe ff ff       	jmp    8003e9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800533:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800537:	c7 44 24 08 07 29 80 	movl   $0x802907,0x8(%esp)
  80053e:	00 
  80053f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800543:	89 3c 24             	mov    %edi,(%esp)
  800546:	e8 85 03 00 00       	call   8008d0 <printfmt>
  80054b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80054e:	e9 96 fe ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  800553:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800556:	89 c3                	mov    %eax,%ebx
  800558:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80055b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80055e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800561:	8b 45 14             	mov    0x14(%ebp),%eax
  800564:	8d 50 04             	lea    0x4(%eax),%edx
  800567:	89 55 14             	mov    %edx,0x14(%ebp)
  80056a:	8b 00                	mov    (%eax),%eax
  80056c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056f:	85 c0                	test   %eax,%eax
  800571:	b8 95 24 80 00       	mov    $0x802495,%eax
  800576:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80057a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80057d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800581:	7e 06                	jle    800589 <vprintfmt+0x1cc>
  800583:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800587:	75 13                	jne    80059c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800589:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058c:	0f be 02             	movsbl (%edx),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	0f 85 a2 00 00 00    	jne    800639 <vprintfmt+0x27c>
  800597:	e9 8f 00 00 00       	jmp    80062b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80059c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005a3:	89 0c 24             	mov    %ecx,(%esp)
  8005a6:	e8 70 03 00 00       	call   80091b <strnlen>
  8005ab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ae:	29 c2                	sub    %eax,%edx
  8005b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005b3:	85 d2                	test   %edx,%edx
  8005b5:	7e d2                	jle    800589 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005b7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005bb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005be:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005c1:	89 d3                	mov    %edx,%ebx
  8005c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ca:	89 04 24             	mov    %eax,(%esp)
  8005cd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cf:	83 eb 01             	sub    $0x1,%ebx
  8005d2:	85 db                	test   %ebx,%ebx
  8005d4:	7f ed                	jg     8005c3 <vprintfmt+0x206>
  8005d6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005d9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005e0:	eb a7                	jmp    800589 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e6:	74 1b                	je     800603 <vprintfmt+0x246>
  8005e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005eb:	83 fa 5e             	cmp    $0x5e,%edx
  8005ee:	76 13                	jbe    800603 <vprintfmt+0x246>
					putch('?', putdat);
  8005f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005fe:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800601:	eb 0d                	jmp    800610 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800603:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800606:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800610:	83 ef 01             	sub    $0x1,%edi
  800613:	0f be 03             	movsbl (%ebx),%eax
  800616:	85 c0                	test   %eax,%eax
  800618:	74 05                	je     80061f <vprintfmt+0x262>
  80061a:	83 c3 01             	add    $0x1,%ebx
  80061d:	eb 31                	jmp    800650 <vprintfmt+0x293>
  80061f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800622:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800625:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800628:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80062f:	7f 36                	jg     800667 <vprintfmt+0x2aa>
  800631:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800634:	e9 b0 fd ff ff       	jmp    8003e9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800639:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063c:	83 c2 01             	add    $0x1,%edx
  80063f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800642:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800645:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800648:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80064b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80064e:	89 d3                	mov    %edx,%ebx
  800650:	85 f6                	test   %esi,%esi
  800652:	78 8e                	js     8005e2 <vprintfmt+0x225>
  800654:	83 ee 01             	sub    $0x1,%esi
  800657:	79 89                	jns    8005e2 <vprintfmt+0x225>
  800659:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80065c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800662:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800665:	eb c4                	jmp    80062b <vprintfmt+0x26e>
  800667:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80066a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800671:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800678:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067a:	83 eb 01             	sub    $0x1,%ebx
  80067d:	85 db                	test   %ebx,%ebx
  80067f:	7f ec                	jg     80066d <vprintfmt+0x2b0>
  800681:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800684:	e9 60 fd ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  800689:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068c:	83 f9 01             	cmp    $0x1,%ecx
  80068f:	7e 16                	jle    8006a7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 50 08             	lea    0x8(%eax),%edx
  800697:	89 55 14             	mov    %edx,0x14(%ebp)
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	8b 48 04             	mov    0x4(%eax),%ecx
  80069f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006a5:	eb 32                	jmp    8006d9 <vprintfmt+0x31c>
	else if (lflag)
  8006a7:	85 c9                	test   %ecx,%ecx
  8006a9:	74 18                	je     8006c3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8d 50 04             	lea    0x4(%eax),%edx
  8006b1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b4:	8b 00                	mov    (%eax),%eax
  8006b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b9:	89 c1                	mov    %eax,%ecx
  8006bb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006c1:	eb 16                	jmp    8006d9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8006c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c6:	8d 50 04             	lea    0x4(%eax),%edx
  8006c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d1:	89 c2                	mov    %eax,%edx
  8006d3:	c1 fa 1f             	sar    $0x1f,%edx
  8006d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006df:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8006e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e8:	0f 89 8a 00 00 00    	jns    800778 <vprintfmt+0x3bb>
				putch('-', putdat);
  8006ee:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f9:	ff d7                	call   *%edi
				num = -(long long) num;
  8006fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800701:	f7 d8                	neg    %eax
  800703:	83 d2 00             	adc    $0x0,%edx
  800706:	f7 da                	neg    %edx
  800708:	eb 6e                	jmp    800778 <vprintfmt+0x3bb>
  80070a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070d:	89 ca                	mov    %ecx,%edx
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
  800712:	e8 4f fc ff ff       	call   800366 <getuint>
  800717:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80071c:	eb 5a                	jmp    800778 <vprintfmt+0x3bb>
  80071e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800721:	89 ca                	mov    %ecx,%edx
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
  800726:	e8 3b fc ff ff       	call   800366 <getuint>
  80072b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800730:	eb 46                	jmp    800778 <vprintfmt+0x3bb>
  800732:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800735:	89 74 24 04          	mov    %esi,0x4(%esp)
  800739:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800740:	ff d7                	call   *%edi
			putch('x', putdat);
  800742:	89 74 24 04          	mov    %esi,0x4(%esp)
  800746:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80074d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 50 04             	lea    0x4(%eax),%edx
  800755:	89 55 14             	mov    %edx,0x14(%ebp)
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	ba 00 00 00 00       	mov    $0x0,%edx
  80075f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800764:	eb 12                	jmp    800778 <vprintfmt+0x3bb>
  800766:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800769:	89 ca                	mov    %ecx,%edx
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
  80076e:	e8 f3 fb ff ff       	call   800366 <getuint>
  800773:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800778:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80077c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800780:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800783:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800787:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80078b:	89 04 24             	mov    %eax,(%esp)
  80078e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800792:	89 f2                	mov    %esi,%edx
  800794:	89 f8                	mov    %edi,%eax
  800796:	e8 d5 fa ff ff       	call   800270 <printnum>
  80079b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80079e:	e9 46 fc ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  8007a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 50 04             	lea    0x4(%eax),%edx
  8007ac:	89 55 14             	mov    %edx,0x14(%ebp)
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	75 24                	jne    8007d9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8007b5:	c7 44 24 0c b0 25 80 	movl   $0x8025b0,0xc(%esp)
  8007bc:	00 
  8007bd:	c7 44 24 08 07 29 80 	movl   $0x802907,0x8(%esp)
  8007c4:	00 
  8007c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c9:	89 3c 24             	mov    %edi,(%esp)
  8007cc:	e8 ff 00 00 00       	call   8008d0 <printfmt>
  8007d1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007d4:	e9 10 fc ff ff       	jmp    8003e9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8007d9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8007dc:	7e 29                	jle    800807 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8007de:	0f b6 16             	movzbl (%esi),%edx
  8007e1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8007e3:	c7 44 24 0c e8 25 80 	movl   $0x8025e8,0xc(%esp)
  8007ea:	00 
  8007eb:	c7 44 24 08 07 29 80 	movl   $0x802907,0x8(%esp)
  8007f2:	00 
  8007f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f7:	89 3c 24             	mov    %edi,(%esp)
  8007fa:	e8 d1 00 00 00       	call   8008d0 <printfmt>
  8007ff:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800802:	e9 e2 fb ff ff       	jmp    8003e9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800807:	0f b6 16             	movzbl (%esi),%edx
  80080a:	88 10                	mov    %dl,(%eax)
  80080c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80080f:	e9 d5 fb ff ff       	jmp    8003e9 <vprintfmt+0x2c>
  800814:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800817:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081e:	89 14 24             	mov    %edx,(%esp)
  800821:	ff d7                	call   *%edi
  800823:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800826:	e9 be fb ff ff       	jmp    8003e9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80082b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800836:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800838:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80083b:	80 38 25             	cmpb   $0x25,(%eax)
  80083e:	0f 84 a5 fb ff ff    	je     8003e9 <vprintfmt+0x2c>
  800844:	89 c3                	mov    %eax,%ebx
  800846:	eb f0                	jmp    800838 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800848:	83 c4 5c             	add    $0x5c,%esp
  80084b:	5b                   	pop    %ebx
  80084c:	5e                   	pop    %esi
  80084d:	5f                   	pop    %edi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 28             	sub    $0x28,%esp
  800856:	8b 45 08             	mov    0x8(%ebp),%eax
  800859:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80085c:	85 c0                	test   %eax,%eax
  80085e:	74 04                	je     800864 <vsnprintf+0x14>
  800860:	85 d2                	test   %edx,%edx
  800862:	7f 07                	jg     80086b <vsnprintf+0x1b>
  800864:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800869:	eb 3b                	jmp    8008a6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80086b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80086e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800872:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800875:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800883:	8b 45 10             	mov    0x10(%ebp),%eax
  800886:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80088d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800891:	c7 04 24 a0 03 80 00 	movl   $0x8003a0,(%esp)
  800898:	e8 20 fb ff ff       	call   8003bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80089d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008a6:	c9                   	leave  
  8008a7:	c3                   	ret    

008008a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008ae:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	89 04 24             	mov    %eax,(%esp)
  8008c9:	e8 82 ff ff ff       	call   800850 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ce:	c9                   	leave  
  8008cf:	c3                   	ret    

008008d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008d6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	89 04 24             	mov    %eax,(%esp)
  8008f1:	e8 c7 fa ff ff       	call   8003bd <vprintfmt>
	va_end(ap);
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    
	...

00800900 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800906:	b8 00 00 00 00       	mov    $0x0,%eax
  80090b:	80 3a 00             	cmpb   $0x0,(%edx)
  80090e:	74 09                	je     800919 <strlen+0x19>
		n++;
  800910:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800913:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800917:	75 f7                	jne    800910 <strlen+0x10>
		n++;
	return n;
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	53                   	push   %ebx
  80091f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800922:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800925:	85 c9                	test   %ecx,%ecx
  800927:	74 19                	je     800942 <strnlen+0x27>
  800929:	80 3b 00             	cmpb   $0x0,(%ebx)
  80092c:	74 14                	je     800942 <strnlen+0x27>
  80092e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800933:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800936:	39 c8                	cmp    %ecx,%eax
  800938:	74 0d                	je     800947 <strnlen+0x2c>
  80093a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80093e:	75 f3                	jne    800933 <strnlen+0x18>
  800940:	eb 05                	jmp    800947 <strnlen+0x2c>
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800954:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800959:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80095d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800960:	83 c2 01             	add    $0x1,%edx
  800963:	84 c9                	test   %cl,%cl
  800965:	75 f2                	jne    800959 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800967:	5b                   	pop    %ebx
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	53                   	push   %ebx
  80096e:	83 ec 08             	sub    $0x8,%esp
  800971:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800974:	89 1c 24             	mov    %ebx,(%esp)
  800977:	e8 84 ff ff ff       	call   800900 <strlen>
	strcpy(dst + len, src);
  80097c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800983:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800986:	89 04 24             	mov    %eax,(%esp)
  800989:	e8 bc ff ff ff       	call   80094a <strcpy>
	return dst;
}
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	83 c4 08             	add    $0x8,%esp
  800993:	5b                   	pop    %ebx
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a4:	85 f6                	test   %esi,%esi
  8009a6:	74 18                	je     8009c0 <strncpy+0x2a>
  8009a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009ad:	0f b6 1a             	movzbl (%edx),%ebx
  8009b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	39 ce                	cmp    %ecx,%esi
  8009be:	77 ed                	ja     8009ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009c0:	5b                   	pop    %ebx
  8009c1:	5e                   	pop    %esi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	56                   	push   %esi
  8009c8:	53                   	push   %ebx
  8009c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d2:	89 f0                	mov    %esi,%eax
  8009d4:	85 c9                	test   %ecx,%ecx
  8009d6:	74 27                	je     8009ff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009d8:	83 e9 01             	sub    $0x1,%ecx
  8009db:	74 1d                	je     8009fa <strlcpy+0x36>
  8009dd:	0f b6 1a             	movzbl (%edx),%ebx
  8009e0:	84 db                	test   %bl,%bl
  8009e2:	74 16                	je     8009fa <strlcpy+0x36>
			*dst++ = *src++;
  8009e4:	88 18                	mov    %bl,(%eax)
  8009e6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e9:	83 e9 01             	sub    $0x1,%ecx
  8009ec:	74 0e                	je     8009fc <strlcpy+0x38>
			*dst++ = *src++;
  8009ee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f1:	0f b6 1a             	movzbl (%edx),%ebx
  8009f4:	84 db                	test   %bl,%bl
  8009f6:	75 ec                	jne    8009e4 <strlcpy+0x20>
  8009f8:	eb 02                	jmp    8009fc <strlcpy+0x38>
  8009fa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009fc:	c6 00 00             	movb   $0x0,(%eax)
  8009ff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	84 c0                	test   %al,%al
  800a13:	74 15                	je     800a2a <strcmp+0x25>
  800a15:	3a 02                	cmp    (%edx),%al
  800a17:	75 11                	jne    800a2a <strcmp+0x25>
		p++, q++;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a1f:	0f b6 01             	movzbl (%ecx),%eax
  800a22:	84 c0                	test   %al,%al
  800a24:	74 04                	je     800a2a <strcmp+0x25>
  800a26:	3a 02                	cmp    (%edx),%al
  800a28:	74 ef                	je     800a19 <strcmp+0x14>
  800a2a:	0f b6 c0             	movzbl %al,%eax
  800a2d:	0f b6 12             	movzbl (%edx),%edx
  800a30:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	53                   	push   %ebx
  800a38:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a41:	85 c0                	test   %eax,%eax
  800a43:	74 23                	je     800a68 <strncmp+0x34>
  800a45:	0f b6 1a             	movzbl (%edx),%ebx
  800a48:	84 db                	test   %bl,%bl
  800a4a:	74 25                	je     800a71 <strncmp+0x3d>
  800a4c:	3a 19                	cmp    (%ecx),%bl
  800a4e:	75 21                	jne    800a71 <strncmp+0x3d>
  800a50:	83 e8 01             	sub    $0x1,%eax
  800a53:	74 13                	je     800a68 <strncmp+0x34>
		n--, p++, q++;
  800a55:	83 c2 01             	add    $0x1,%edx
  800a58:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5b:	0f b6 1a             	movzbl (%edx),%ebx
  800a5e:	84 db                	test   %bl,%bl
  800a60:	74 0f                	je     800a71 <strncmp+0x3d>
  800a62:	3a 19                	cmp    (%ecx),%bl
  800a64:	74 ea                	je     800a50 <strncmp+0x1c>
  800a66:	eb 09                	jmp    800a71 <strncmp+0x3d>
  800a68:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	90                   	nop
  800a70:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a71:	0f b6 02             	movzbl (%edx),%eax
  800a74:	0f b6 11             	movzbl (%ecx),%edx
  800a77:	29 d0                	sub    %edx,%eax
  800a79:	eb f2                	jmp    800a6d <strncmp+0x39>

00800a7b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a85:	0f b6 10             	movzbl (%eax),%edx
  800a88:	84 d2                	test   %dl,%dl
  800a8a:	74 18                	je     800aa4 <strchr+0x29>
		if (*s == c)
  800a8c:	38 ca                	cmp    %cl,%dl
  800a8e:	75 0a                	jne    800a9a <strchr+0x1f>
  800a90:	eb 17                	jmp    800aa9 <strchr+0x2e>
  800a92:	38 ca                	cmp    %cl,%dl
  800a94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a98:	74 0f                	je     800aa9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	0f b6 10             	movzbl (%eax),%edx
  800aa0:	84 d2                	test   %dl,%dl
  800aa2:	75 ee                	jne    800a92 <strchr+0x17>
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	0f b6 10             	movzbl (%eax),%edx
  800ab8:	84 d2                	test   %dl,%dl
  800aba:	74 18                	je     800ad4 <strfind+0x29>
		if (*s == c)
  800abc:	38 ca                	cmp    %cl,%dl
  800abe:	75 0a                	jne    800aca <strfind+0x1f>
  800ac0:	eb 12                	jmp    800ad4 <strfind+0x29>
  800ac2:	38 ca                	cmp    %cl,%dl
  800ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ac8:	74 0a                	je     800ad4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	75 ee                	jne    800ac2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	83 ec 0c             	sub    $0xc,%esp
  800adc:	89 1c 24             	mov    %ebx,(%esp)
  800adf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ae3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ae7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800af0:	85 c9                	test   %ecx,%ecx
  800af2:	74 30                	je     800b24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800af4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800afa:	75 25                	jne    800b21 <memset+0x4b>
  800afc:	f6 c1 03             	test   $0x3,%cl
  800aff:	75 20                	jne    800b21 <memset+0x4b>
		c &= 0xFF;
  800b01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b04:	89 d3                	mov    %edx,%ebx
  800b06:	c1 e3 08             	shl    $0x8,%ebx
  800b09:	89 d6                	mov    %edx,%esi
  800b0b:	c1 e6 18             	shl    $0x18,%esi
  800b0e:	89 d0                	mov    %edx,%eax
  800b10:	c1 e0 10             	shl    $0x10,%eax
  800b13:	09 f0                	or     %esi,%eax
  800b15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b17:	09 d8                	or     %ebx,%eax
  800b19:	c1 e9 02             	shr    $0x2,%ecx
  800b1c:	fc                   	cld    
  800b1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1f:	eb 03                	jmp    800b24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b21:	fc                   	cld    
  800b22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b24:	89 f8                	mov    %edi,%eax
  800b26:	8b 1c 24             	mov    (%esp),%ebx
  800b29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b31:	89 ec                	mov    %ebp,%esp
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	89 34 24             	mov    %esi,(%esp)
  800b3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b4d:	39 c6                	cmp    %eax,%esi
  800b4f:	73 35                	jae    800b86 <memmove+0x51>
  800b51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b54:	39 d0                	cmp    %edx,%eax
  800b56:	73 2e                	jae    800b86 <memmove+0x51>
		s += n;
		d += n;
  800b58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5a:	f6 c2 03             	test   $0x3,%dl
  800b5d:	75 1b                	jne    800b7a <memmove+0x45>
  800b5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b65:	75 13                	jne    800b7a <memmove+0x45>
  800b67:	f6 c1 03             	test   $0x3,%cl
  800b6a:	75 0e                	jne    800b7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b6c:	83 ef 04             	sub    $0x4,%edi
  800b6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b72:	c1 e9 02             	shr    $0x2,%ecx
  800b75:	fd                   	std    
  800b76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b78:	eb 09                	jmp    800b83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b7a:	83 ef 01             	sub    $0x1,%edi
  800b7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b80:	fd                   	std    
  800b81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b83:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b84:	eb 20                	jmp    800ba6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b8c:	75 15                	jne    800ba3 <memmove+0x6e>
  800b8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b94:	75 0d                	jne    800ba3 <memmove+0x6e>
  800b96:	f6 c1 03             	test   $0x3,%cl
  800b99:	75 08                	jne    800ba3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b9b:	c1 e9 02             	shr    $0x2,%ecx
  800b9e:	fc                   	cld    
  800b9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba1:	eb 03                	jmp    800ba6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ba3:	fc                   	cld    
  800ba4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba6:	8b 34 24             	mov    (%esp),%esi
  800ba9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bad:	89 ec                	mov    %ebp,%esp
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	89 04 24             	mov    %eax,(%esp)
  800bcb:	e8 65 ff ff ff       	call   800b35 <memmove>
}
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bdb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bde:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be1:	85 c9                	test   %ecx,%ecx
  800be3:	74 36                	je     800c1b <memcmp+0x49>
		if (*s1 != *s2)
  800be5:	0f b6 06             	movzbl (%esi),%eax
  800be8:	0f b6 1f             	movzbl (%edi),%ebx
  800beb:	38 d8                	cmp    %bl,%al
  800bed:	74 20                	je     800c0f <memcmp+0x3d>
  800bef:	eb 14                	jmp    800c05 <memcmp+0x33>
  800bf1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bf6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bfb:	83 c2 01             	add    $0x1,%edx
  800bfe:	83 e9 01             	sub    $0x1,%ecx
  800c01:	38 d8                	cmp    %bl,%al
  800c03:	74 12                	je     800c17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c05:	0f b6 c0             	movzbl %al,%eax
  800c08:	0f b6 db             	movzbl %bl,%ebx
  800c0b:	29 d8                	sub    %ebx,%eax
  800c0d:	eb 11                	jmp    800c20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0f:	83 e9 01             	sub    $0x1,%ecx
  800c12:	ba 00 00 00 00       	mov    $0x0,%edx
  800c17:	85 c9                	test   %ecx,%ecx
  800c19:	75 d6                	jne    800bf1 <memcmp+0x1f>
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5f                   	pop    %edi
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c30:	39 d0                	cmp    %edx,%eax
  800c32:	73 15                	jae    800c49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c38:	38 08                	cmp    %cl,(%eax)
  800c3a:	75 06                	jne    800c42 <memfind+0x1d>
  800c3c:	eb 0b                	jmp    800c49 <memfind+0x24>
  800c3e:	38 08                	cmp    %cl,(%eax)
  800c40:	74 07                	je     800c49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c42:	83 c0 01             	add    $0x1,%eax
  800c45:	39 c2                	cmp    %eax,%edx
  800c47:	77 f5                	ja     800c3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	83 ec 04             	sub    $0x4,%esp
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5a:	0f b6 02             	movzbl (%edx),%eax
  800c5d:	3c 20                	cmp    $0x20,%al
  800c5f:	74 04                	je     800c65 <strtol+0x1a>
  800c61:	3c 09                	cmp    $0x9,%al
  800c63:	75 0e                	jne    800c73 <strtol+0x28>
		s++;
  800c65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c68:	0f b6 02             	movzbl (%edx),%eax
  800c6b:	3c 20                	cmp    $0x20,%al
  800c6d:	74 f6                	je     800c65 <strtol+0x1a>
  800c6f:	3c 09                	cmp    $0x9,%al
  800c71:	74 f2                	je     800c65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c73:	3c 2b                	cmp    $0x2b,%al
  800c75:	75 0c                	jne    800c83 <strtol+0x38>
		s++;
  800c77:	83 c2 01             	add    $0x1,%edx
  800c7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c81:	eb 15                	jmp    800c98 <strtol+0x4d>
	else if (*s == '-')
  800c83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c8a:	3c 2d                	cmp    $0x2d,%al
  800c8c:	75 0a                	jne    800c98 <strtol+0x4d>
		s++, neg = 1;
  800c8e:	83 c2 01             	add    $0x1,%edx
  800c91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c98:	85 db                	test   %ebx,%ebx
  800c9a:	0f 94 c0             	sete   %al
  800c9d:	74 05                	je     800ca4 <strtol+0x59>
  800c9f:	83 fb 10             	cmp    $0x10,%ebx
  800ca2:	75 18                	jne    800cbc <strtol+0x71>
  800ca4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ca7:	75 13                	jne    800cbc <strtol+0x71>
  800ca9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cad:	8d 76 00             	lea    0x0(%esi),%esi
  800cb0:	75 0a                	jne    800cbc <strtol+0x71>
		s += 2, base = 16;
  800cb2:	83 c2 02             	add    $0x2,%edx
  800cb5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cba:	eb 15                	jmp    800cd1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cbc:	84 c0                	test   %al,%al
  800cbe:	66 90                	xchg   %ax,%ax
  800cc0:	74 0f                	je     800cd1 <strtol+0x86>
  800cc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cc7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cca:	75 05                	jne    800cd1 <strtol+0x86>
		s++, base = 8;
  800ccc:	83 c2 01             	add    $0x1,%edx
  800ccf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cd8:	0f b6 0a             	movzbl (%edx),%ecx
  800cdb:	89 cf                	mov    %ecx,%edi
  800cdd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ce0:	80 fb 09             	cmp    $0x9,%bl
  800ce3:	77 08                	ja     800ced <strtol+0xa2>
			dig = *s - '0';
  800ce5:	0f be c9             	movsbl %cl,%ecx
  800ce8:	83 e9 30             	sub    $0x30,%ecx
  800ceb:	eb 1e                	jmp    800d0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ced:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cf0:	80 fb 19             	cmp    $0x19,%bl
  800cf3:	77 08                	ja     800cfd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cf5:	0f be c9             	movsbl %cl,%ecx
  800cf8:	83 e9 57             	sub    $0x57,%ecx
  800cfb:	eb 0e                	jmp    800d0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cfd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d00:	80 fb 19             	cmp    $0x19,%bl
  800d03:	77 15                	ja     800d1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d05:	0f be c9             	movsbl %cl,%ecx
  800d08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d0b:	39 f1                	cmp    %esi,%ecx
  800d0d:	7d 0b                	jge    800d1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d0f:	83 c2 01             	add    $0x1,%edx
  800d12:	0f af c6             	imul   %esi,%eax
  800d15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d18:	eb be                	jmp    800cd8 <strtol+0x8d>
  800d1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d20:	74 05                	je     800d27 <strtol+0xdc>
		*endptr = (char *) s;
  800d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d27:	89 ca                	mov    %ecx,%edx
  800d29:	f7 da                	neg    %edx
  800d2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d2f:	0f 45 c2             	cmovne %edx,%eax
}
  800d32:	83 c4 04             	add    $0x4,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
	...

00800d3c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	83 ec 48             	sub    $0x48,%esp
  800d42:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d45:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d48:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d4b:	89 c6                	mov    %eax,%esi
  800d4d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d50:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d52:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5b:	51                   	push   %ecx
  800d5c:	52                   	push   %edx
  800d5d:	53                   	push   %ebx
  800d5e:	54                   	push   %esp
  800d5f:	55                   	push   %ebp
  800d60:	56                   	push   %esi
  800d61:	57                   	push   %edi
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	8d 35 6c 0d 80 00    	lea    0x800d6c,%esi
  800d6a:	0f 34                	sysenter 

00800d6c <.after_sysenter_label>:
  800d6c:	5f                   	pop    %edi
  800d6d:	5e                   	pop    %esi
  800d6e:	5d                   	pop    %ebp
  800d6f:	5c                   	pop    %esp
  800d70:	5b                   	pop    %ebx
  800d71:	5a                   	pop    %edx
  800d72:	59                   	pop    %ecx
  800d73:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d75:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d79:	74 28                	je     800da3 <.after_sysenter_label+0x37>
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	7e 24                	jle    800da3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d83:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d87:	c7 44 24 08 00 28 80 	movl   $0x802800,0x8(%esp)
  800d8e:	00 
  800d8f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d96:	00 
  800d97:	c7 04 24 1d 28 80 00 	movl   $0x80281d,(%esp)
  800d9e:	e8 ad f3 ff ff       	call   800150 <_panic>

	return ret;
}
  800da3:	89 d0                	mov    %edx,%eax
  800da5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dae:	89 ec                	mov    %ebp,%esp
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800db8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dc7:	00 
  800dc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dcf:	00 
  800dd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd3:	89 04 24             	mov    %eax,(%esp)
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dde:	b8 10 00 00 00       	mov    $0x10,%eax
  800de3:	e8 54 ff ff ff       	call   800d3c <syscall>
}
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    

00800dea <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800df0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800df7:	00 
  800df8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dff:	00 
  800e00:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e07:	00 
  800e08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e14:	ba 00 00 00 00       	mov    $0x0,%edx
  800e19:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e1e:	e8 19 ff ff ff       	call   800d3c <syscall>
}
  800e23:	c9                   	leave  
  800e24:	c3                   	ret    

00800e25 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e2b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e32:	00 
  800e33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e3a:	00 
  800e3b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e42:	00 
  800e43:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e52:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e57:	e8 e0 fe ff ff       	call   800d3c <syscall>
}
  800e5c:	c9                   	leave  
  800e5d:	c3                   	ret    

00800e5e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e64:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e6b:	00 
  800e6c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e73:	8b 45 10             	mov    0x10(%ebp),%eax
  800e76:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	89 04 24             	mov    %eax,(%esp)
  800e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e83:	ba 00 00 00 00       	mov    $0x0,%edx
  800e88:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e8d:	e8 aa fe ff ff       	call   800d3c <syscall>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e9a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb1:	00 
  800eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb5:	89 04 24             	mov    %eax,(%esp)
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	ba 01 00 00 00       	mov    $0x1,%edx
  800ec0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ec5:	e8 72 fe ff ff       	call   800d3c <syscall>
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ed2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed9:	00 
  800eda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee9:	00 
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	89 04 24             	mov    %eax,(%esp)
  800ef0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800efd:	e8 3a fe ff ff       	call   800d3c <syscall>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800f30:	b8 09 00 00 00       	mov    $0x9,%eax
  800f35:	e8 02 fe ff ff       	call   800d3c <syscall>
}
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800f68:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6d:	e8 ca fd ff ff       	call   800d3c <syscall>
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f7a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f81:	00 
  800f82:	8b 45 18             	mov    0x18(%ebp),%eax
  800f85:	0b 45 14             	or     0x14(%ebp),%eax
  800f88:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f96:	89 04 24             	mov    %eax,(%esp)
  800f99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800fa1:	b8 06 00 00 00       	mov    $0x6,%eax
  800fa6:	e8 91 fd ff ff       	call   800d3c <syscall>
}
  800fab:	c9                   	leave  
  800fac:	c3                   	ret    

00800fad <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fb3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fba:	00 
  800fbb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc2:	00 
  800fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fd8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fdd:	e8 5a fd ff ff       	call   800d3c <syscall>
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801001:	00 
  801002:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801009:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 0c 00 00 00       	mov    $0xc,%eax
  801018:	e8 1f fd ff ff       	call   800d3c <syscall>
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801025:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80102c:	00 
  80102d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801034:	00 
  801035:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103c:	00 
  80103d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801040:	89 04 24             	mov    %eax,(%esp)
  801043:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801046:	ba 00 00 00 00       	mov    $0x0,%edx
  80104b:	b8 04 00 00 00       	mov    $0x4,%eax
  801050:	e8 e7 fc ff ff       	call   800d3c <syscall>
}
  801055:	c9                   	leave  
  801056:	c3                   	ret    

00801057 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801057:	55                   	push   %ebp
  801058:	89 e5                	mov    %esp,%ebp
  80105a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80105d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801064:	00 
  801065:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106c:	00 
  80106d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801074:	00 
  801075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801081:	ba 00 00 00 00       	mov    $0x0,%edx
  801086:	b8 02 00 00 00       	mov    $0x2,%eax
  80108b:	e8 ac fc ff ff       	call   800d3c <syscall>
}
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801098:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80109f:	00 
  8010a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a7:	00 
  8010a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010af:	00 
  8010b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ba:	ba 01 00 00 00       	mov    $0x1,%edx
  8010bf:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c4:	e8 73 fc ff ff       	call   800d3c <syscall>
}
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    

008010cb <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010cb:	55                   	push   %ebp
  8010cc:	89 e5                	mov    %esp,%ebp
  8010ce:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e0:	00 
  8010e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e8:	00 
  8010e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ff:	e8 38 fc ff ff       	call   800d3c <syscall>
}
  801104:	c9                   	leave  
  801105:	c3                   	ret    

00801106 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80110c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801113:	00 
  801114:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80111b:	00 
  80111c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801123:	00 
  801124:	8b 45 0c             	mov    0xc(%ebp),%eax
  801127:	89 04 24             	mov    %eax,(%esp)
  80112a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112d:	ba 00 00 00 00       	mov    $0x0,%edx
  801132:	b8 00 00 00 00       	mov    $0x0,%eax
  801137:	e8 00 fc ff ff       	call   800d3c <syscall>
}
  80113c:	c9                   	leave  
  80113d:	c3                   	ret    
	...

00801140 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801146:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  80114d:	75 54                	jne    8011a3 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80114f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801156:	00 
  801157:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80115e:	ee 
  80115f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801166:	e8 42 fe ff ff       	call   800fad <sys_page_alloc>
  80116b:	85 c0                	test   %eax,%eax
  80116d:	79 20                	jns    80118f <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80116f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801173:	c7 44 24 08 2b 28 80 	movl   $0x80282b,0x8(%esp)
  80117a:	00 
  80117b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801182:	00 
  801183:	c7 04 24 43 28 80 00 	movl   $0x802843,(%esp)
  80118a:	e8 c1 ef ff ff       	call   800150 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80118f:	c7 44 24 04 b0 11 80 	movl   $0x8011b0,0x4(%esp)
  801196:	00 
  801197:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80119e:	e8 f1 fc ff ff       	call   800e94 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a6:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    
  8011ad:	00 00                	add    %al,(%eax)
	...

008011b0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011b0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011b1:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  8011b6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011b8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8011bb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8011bf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8011c2:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8011c6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8011ca:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8011cc:	83 c4 08             	add    $0x8,%esp
	popal
  8011cf:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8011d0:	83 c4 04             	add    $0x4,%esp
	popfl
  8011d3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8011d4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011d5:	c3                   	ret    
	...

008011e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f9:	89 04 24             	mov    %eax,(%esp)
  8011fc:	e8 df ff ff ff       	call   8011e0 <fd2num>
  801201:	05 20 00 0d 00       	add    $0xd0020,%eax
  801206:	c1 e0 0c             	shl    $0xc,%eax
}
  801209:	c9                   	leave  
  80120a:	c3                   	ret    

0080120b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	57                   	push   %edi
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801214:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801219:	a8 01                	test   $0x1,%al
  80121b:	74 36                	je     801253 <fd_alloc+0x48>
  80121d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801222:	a8 01                	test   $0x1,%al
  801224:	74 2d                	je     801253 <fd_alloc+0x48>
  801226:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80122b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801230:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801235:	89 c3                	mov    %eax,%ebx
  801237:	89 c2                	mov    %eax,%edx
  801239:	c1 ea 16             	shr    $0x16,%edx
  80123c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80123f:	f6 c2 01             	test   $0x1,%dl
  801242:	74 14                	je     801258 <fd_alloc+0x4d>
  801244:	89 c2                	mov    %eax,%edx
  801246:	c1 ea 0c             	shr    $0xc,%edx
  801249:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	75 10                	jne    801261 <fd_alloc+0x56>
  801251:	eb 05                	jmp    801258 <fd_alloc+0x4d>
  801253:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801258:	89 1f                	mov    %ebx,(%edi)
  80125a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80125f:	eb 17                	jmp    801278 <fd_alloc+0x6d>
  801261:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801266:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80126b:	75 c8                	jne    801235 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80126d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801273:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801278:	5b                   	pop    %ebx
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    

0080127d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80127d:	55                   	push   %ebp
  80127e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801280:	8b 45 08             	mov    0x8(%ebp),%eax
  801283:	83 f8 1f             	cmp    $0x1f,%eax
  801286:	77 36                	ja     8012be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801288:	05 00 00 0d 00       	add    $0xd0000,%eax
  80128d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801290:	89 c2                	mov    %eax,%edx
  801292:	c1 ea 16             	shr    $0x16,%edx
  801295:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129c:	f6 c2 01             	test   $0x1,%dl
  80129f:	74 1d                	je     8012be <fd_lookup+0x41>
  8012a1:	89 c2                	mov    %eax,%edx
  8012a3:	c1 ea 0c             	shr    $0xc,%edx
  8012a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ad:	f6 c2 01             	test   $0x1,%dl
  8012b0:	74 0c                	je     8012be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b5:	89 02                	mov    %eax,(%edx)
  8012b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8012bc:	eb 05                	jmp    8012c3 <fd_lookup+0x46>
  8012be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d5:	89 04 24             	mov    %eax,(%esp)
  8012d8:	e8 a0 ff ff ff       	call   80127d <fd_lookup>
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 0e                	js     8012ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e7:	89 50 04             	mov    %edx,0x4(%eax)
  8012ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	56                   	push   %esi
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 10             	sub    $0x10,%esp
  8012f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8012ff:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801304:	b8 04 30 80 00       	mov    $0x803004,%eax
  801309:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80130f:	75 11                	jne    801322 <dev_lookup+0x31>
  801311:	eb 04                	jmp    801317 <dev_lookup+0x26>
  801313:	39 08                	cmp    %ecx,(%eax)
  801315:	75 10                	jne    801327 <dev_lookup+0x36>
			*dev = devtab[i];
  801317:	89 03                	mov    %eax,(%ebx)
  801319:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80131e:	66 90                	xchg   %ax,%ax
  801320:	eb 36                	jmp    801358 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801322:	be d4 28 80 00       	mov    $0x8028d4,%esi
  801327:	83 c2 01             	add    $0x1,%edx
  80132a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80132d:	85 c0                	test   %eax,%eax
  80132f:	75 e2                	jne    801313 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801331:	a1 08 40 80 00       	mov    0x804008,%eax
  801336:	8b 40 48             	mov    0x48(%eax),%eax
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	c7 04 24 54 28 80 00 	movl   $0x802854,(%esp)
  801348:	e8 bc ee ff ff       	call   800209 <cprintf>
	*dev = 0;
  80134d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	5b                   	pop    %ebx
  80135c:	5e                   	pop    %esi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	53                   	push   %ebx
  801363:	83 ec 24             	sub    $0x24,%esp
  801366:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801369:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801370:	8b 45 08             	mov    0x8(%ebp),%eax
  801373:	89 04 24             	mov    %eax,(%esp)
  801376:	e8 02 ff ff ff       	call   80127d <fd_lookup>
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 53                	js     8013d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801389:	8b 00                	mov    (%eax),%eax
  80138b:	89 04 24             	mov    %eax,(%esp)
  80138e:	e8 5e ff ff ff       	call   8012f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801393:	85 c0                	test   %eax,%eax
  801395:	78 3b                	js     8013d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801397:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80139c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80139f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013a3:	74 2d                	je     8013d2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013af:	00 00 00 
	stat->st_isdir = 0;
  8013b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013b9:	00 00 00 
	stat->st_dev = dev;
  8013bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013cc:	89 14 24             	mov    %edx,(%esp)
  8013cf:	ff 50 14             	call   *0x14(%eax)
}
  8013d2:	83 c4 24             	add    $0x24,%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 24             	sub    $0x24,%esp
  8013df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e9:	89 1c 24             	mov    %ebx,(%esp)
  8013ec:	e8 8c fe ff ff       	call   80127d <fd_lookup>
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 5f                	js     801454 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ff:	8b 00                	mov    (%eax),%eax
  801401:	89 04 24             	mov    %eax,(%esp)
  801404:	e8 e8 fe ff ff       	call   8012f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 47                	js     801454 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801410:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801414:	75 23                	jne    801439 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801416:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80141b:	8b 40 48             	mov    0x48(%eax),%eax
  80141e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801422:	89 44 24 04          	mov    %eax,0x4(%esp)
  801426:	c7 04 24 74 28 80 00 	movl   $0x802874,(%esp)
  80142d:	e8 d7 ed ff ff       	call   800209 <cprintf>
  801432:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801437:	eb 1b                	jmp    801454 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801439:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143c:	8b 48 18             	mov    0x18(%eax),%ecx
  80143f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801444:	85 c9                	test   %ecx,%ecx
  801446:	74 0c                	je     801454 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801448:	8b 45 0c             	mov    0xc(%ebp),%eax
  80144b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144f:	89 14 24             	mov    %edx,(%esp)
  801452:	ff d1                	call   *%ecx
}
  801454:	83 c4 24             	add    $0x24,%esp
  801457:	5b                   	pop    %ebx
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	53                   	push   %ebx
  80145e:	83 ec 24             	sub    $0x24,%esp
  801461:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80146b:	89 1c 24             	mov    %ebx,(%esp)
  80146e:	e8 0a fe ff ff       	call   80127d <fd_lookup>
  801473:	85 c0                	test   %eax,%eax
  801475:	78 66                	js     8014dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801477:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801481:	8b 00                	mov    (%eax),%eax
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	e8 66 fe ff ff       	call   8012f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 4e                	js     8014dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801492:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801496:	75 23                	jne    8014bb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801498:	a1 08 40 80 00       	mov    0x804008,%eax
  80149d:	8b 40 48             	mov    0x48(%eax),%eax
  8014a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	c7 04 24 98 28 80 00 	movl   $0x802898,(%esp)
  8014af:	e8 55 ed ff ff       	call   800209 <cprintf>
  8014b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014b9:	eb 22                	jmp    8014dd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014be:	8b 48 0c             	mov    0xc(%eax),%ecx
  8014c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c6:	85 c9                	test   %ecx,%ecx
  8014c8:	74 13                	je     8014dd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8014cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	89 14 24             	mov    %edx,(%esp)
  8014db:	ff d1                	call   *%ecx
}
  8014dd:	83 c4 24             	add    $0x24,%esp
  8014e0:	5b                   	pop    %ebx
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    

008014e3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014e3:	55                   	push   %ebp
  8014e4:	89 e5                	mov    %esp,%ebp
  8014e6:	53                   	push   %ebx
  8014e7:	83 ec 24             	sub    $0x24,%esp
  8014ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f4:	89 1c 24             	mov    %ebx,(%esp)
  8014f7:	e8 81 fd ff ff       	call   80127d <fd_lookup>
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 6b                	js     80156b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801500:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801503:	89 44 24 04          	mov    %eax,0x4(%esp)
  801507:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80150a:	8b 00                	mov    (%eax),%eax
  80150c:	89 04 24             	mov    %eax,(%esp)
  80150f:	e8 dd fd ff ff       	call   8012f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801514:	85 c0                	test   %eax,%eax
  801516:	78 53                	js     80156b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801518:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80151b:	8b 42 08             	mov    0x8(%edx),%eax
  80151e:	83 e0 03             	and    $0x3,%eax
  801521:	83 f8 01             	cmp    $0x1,%eax
  801524:	75 23                	jne    801549 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801526:	a1 08 40 80 00       	mov    0x804008,%eax
  80152b:	8b 40 48             	mov    0x48(%eax),%eax
  80152e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801532:	89 44 24 04          	mov    %eax,0x4(%esp)
  801536:	c7 04 24 b5 28 80 00 	movl   $0x8028b5,(%esp)
  80153d:	e8 c7 ec ff ff       	call   800209 <cprintf>
  801542:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801547:	eb 22                	jmp    80156b <read+0x88>
	}
	if (!dev->dev_read)
  801549:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154c:	8b 48 08             	mov    0x8(%eax),%ecx
  80154f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801554:	85 c9                	test   %ecx,%ecx
  801556:	74 13                	je     80156b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801558:	8b 45 10             	mov    0x10(%ebp),%eax
  80155b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80155f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801562:	89 44 24 04          	mov    %eax,0x4(%esp)
  801566:	89 14 24             	mov    %edx,(%esp)
  801569:	ff d1                	call   *%ecx
}
  80156b:	83 c4 24             	add    $0x24,%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	57                   	push   %edi
  801575:	56                   	push   %esi
  801576:	53                   	push   %ebx
  801577:	83 ec 1c             	sub    $0x1c,%esp
  80157a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80157d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801580:	ba 00 00 00 00       	mov    $0x0,%edx
  801585:	bb 00 00 00 00       	mov    $0x0,%ebx
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
  80158f:	85 f6                	test   %esi,%esi
  801591:	74 29                	je     8015bc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801593:	89 f0                	mov    %esi,%eax
  801595:	29 d0                	sub    %edx,%eax
  801597:	89 44 24 08          	mov    %eax,0x8(%esp)
  80159b:	03 55 0c             	add    0xc(%ebp),%edx
  80159e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a2:	89 3c 24             	mov    %edi,(%esp)
  8015a5:	e8 39 ff ff ff       	call   8014e3 <read>
		if (m < 0)
  8015aa:	85 c0                	test   %eax,%eax
  8015ac:	78 0e                	js     8015bc <readn+0x4b>
			return m;
		if (m == 0)
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	74 08                	je     8015ba <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b2:	01 c3                	add    %eax,%ebx
  8015b4:	89 da                	mov    %ebx,%edx
  8015b6:	39 f3                	cmp    %esi,%ebx
  8015b8:	72 d9                	jb     801593 <readn+0x22>
  8015ba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015bc:	83 c4 1c             	add    $0x1c,%esp
  8015bf:	5b                   	pop    %ebx
  8015c0:	5e                   	pop    %esi
  8015c1:	5f                   	pop    %edi
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    

008015c4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 28             	sub    $0x28,%esp
  8015ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8015d0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015d3:	89 34 24             	mov    %esi,(%esp)
  8015d6:	e8 05 fc ff ff       	call   8011e0 <fd2num>
  8015db:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015e2:	89 04 24             	mov    %eax,(%esp)
  8015e5:	e8 93 fc ff ff       	call   80127d <fd_lookup>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 05                	js     8015f5 <fd_close+0x31>
  8015f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015f3:	74 0e                	je     801603 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8015f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8015fe:	0f 44 d8             	cmove  %eax,%ebx
  801601:	eb 3d                	jmp    801640 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801603:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801606:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160a:	8b 06                	mov    (%esi),%eax
  80160c:	89 04 24             	mov    %eax,(%esp)
  80160f:	e8 dd fc ff ff       	call   8012f1 <dev_lookup>
  801614:	89 c3                	mov    %eax,%ebx
  801616:	85 c0                	test   %eax,%eax
  801618:	78 16                	js     801630 <fd_close+0x6c>
		if (dev->dev_close)
  80161a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161d:	8b 40 10             	mov    0x10(%eax),%eax
  801620:	bb 00 00 00 00       	mov    $0x0,%ebx
  801625:	85 c0                	test   %eax,%eax
  801627:	74 07                	je     801630 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801629:	89 34 24             	mov    %esi,(%esp)
  80162c:	ff d0                	call   *%eax
  80162e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801630:	89 74 24 04          	mov    %esi,0x4(%esp)
  801634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80163b:	e8 fc f8 ff ff       	call   800f3c <sys_page_unmap>
	return r;
}
  801640:	89 d8                	mov    %ebx,%eax
  801642:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801645:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801648:	89 ec                	mov    %ebp,%esp
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801652:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801655:	89 44 24 04          	mov    %eax,0x4(%esp)
  801659:	8b 45 08             	mov    0x8(%ebp),%eax
  80165c:	89 04 24             	mov    %eax,(%esp)
  80165f:	e8 19 fc ff ff       	call   80127d <fd_lookup>
  801664:	85 c0                	test   %eax,%eax
  801666:	78 13                	js     80167b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801668:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80166f:	00 
  801670:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801673:	89 04 24             	mov    %eax,(%esp)
  801676:	e8 49 ff ff ff       	call   8015c4 <fd_close>
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 18             	sub    $0x18,%esp
  801683:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801686:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801689:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801690:	00 
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	89 04 24             	mov    %eax,(%esp)
  801697:	e8 78 03 00 00       	call   801a14 <open>
  80169c:	89 c3                	mov    %eax,%ebx
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 1b                	js     8016bd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a9:	89 1c 24             	mov    %ebx,(%esp)
  8016ac:	e8 ae fc ff ff       	call   80135f <fstat>
  8016b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016b3:	89 1c 24             	mov    %ebx,(%esp)
  8016b6:	e8 91 ff ff ff       	call   80164c <close>
  8016bb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8016bd:	89 d8                	mov    %ebx,%eax
  8016bf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016c2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016c5:	89 ec                	mov    %ebp,%esp
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 14             	sub    $0x14,%esp
  8016d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8016d5:	89 1c 24             	mov    %ebx,(%esp)
  8016d8:	e8 6f ff ff ff       	call   80164c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016dd:	83 c3 01             	add    $0x1,%ebx
  8016e0:	83 fb 20             	cmp    $0x20,%ebx
  8016e3:	75 f0                	jne    8016d5 <close_all+0xc>
		close(i);
}
  8016e5:	83 c4 14             	add    $0x14,%esp
  8016e8:	5b                   	pop    %ebx
  8016e9:	5d                   	pop    %ebp
  8016ea:	c3                   	ret    

008016eb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	83 ec 58             	sub    $0x58,%esp
  8016f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8016f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8016f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8016fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801700:	89 44 24 04          	mov    %eax,0x4(%esp)
  801704:	8b 45 08             	mov    0x8(%ebp),%eax
  801707:	89 04 24             	mov    %eax,(%esp)
  80170a:	e8 6e fb ff ff       	call   80127d <fd_lookup>
  80170f:	89 c3                	mov    %eax,%ebx
  801711:	85 c0                	test   %eax,%eax
  801713:	0f 88 e0 00 00 00    	js     8017f9 <dup+0x10e>
		return r;
	close(newfdnum);
  801719:	89 3c 24             	mov    %edi,(%esp)
  80171c:	e8 2b ff ff ff       	call   80164c <close>

	newfd = INDEX2FD(newfdnum);
  801721:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801727:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80172a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172d:	89 04 24             	mov    %eax,(%esp)
  801730:	e8 bb fa ff ff       	call   8011f0 <fd2data>
  801735:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801737:	89 34 24             	mov    %esi,(%esp)
  80173a:	e8 b1 fa ff ff       	call   8011f0 <fd2data>
  80173f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801742:	89 da                	mov    %ebx,%edx
  801744:	89 d8                	mov    %ebx,%eax
  801746:	c1 e8 16             	shr    $0x16,%eax
  801749:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801750:	a8 01                	test   $0x1,%al
  801752:	74 43                	je     801797 <dup+0xac>
  801754:	c1 ea 0c             	shr    $0xc,%edx
  801757:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80175e:	a8 01                	test   $0x1,%al
  801760:	74 35                	je     801797 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801762:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801769:	25 07 0e 00 00       	and    $0xe07,%eax
  80176e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801772:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801775:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801779:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801780:	00 
  801781:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801785:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80178c:	e8 e3 f7 ff ff       	call   800f74 <sys_page_map>
  801791:	89 c3                	mov    %eax,%ebx
  801793:	85 c0                	test   %eax,%eax
  801795:	78 3f                	js     8017d6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801797:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	c1 ea 0c             	shr    $0xc,%edx
  80179f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017a6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017ac:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017bb:	00 
  8017bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017c7:	e8 a8 f7 ff ff       	call   800f74 <sys_page_map>
  8017cc:	89 c3                	mov    %eax,%ebx
  8017ce:	85 c0                	test   %eax,%eax
  8017d0:	78 04                	js     8017d6 <dup+0xeb>
  8017d2:	89 fb                	mov    %edi,%ebx
  8017d4:	eb 23                	jmp    8017f9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e1:	e8 56 f7 ff ff       	call   800f3c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f4:	e8 43 f7 ff ff       	call   800f3c <sys_page_unmap>
	return r;
}
  8017f9:	89 d8                	mov    %ebx,%eax
  8017fb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8017fe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801801:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801804:	89 ec                	mov    %ebp,%esp
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 18             	sub    $0x18,%esp
  80180e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801811:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801814:	89 c3                	mov    %eax,%ebx
  801816:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801818:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80181f:	75 11                	jne    801832 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801821:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801828:	e8 b3 07 00 00       	call   801fe0 <ipc_find_env>
  80182d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801832:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801839:	00 
  80183a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801841:	00 
  801842:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801846:	a1 00 40 80 00       	mov    0x804000,%eax
  80184b:	89 04 24             	mov    %eax,(%esp)
  80184e:	e8 d6 07 00 00       	call   802029 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801853:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80185a:	00 
  80185b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80185f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801866:	e8 29 08 00 00       	call   802094 <ipc_recv>
}
  80186b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80186e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801871:	89 ec                	mov    %ebp,%esp
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 40 0c             	mov    0xc(%eax),%eax
  801881:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801886:	8b 45 0c             	mov    0xc(%ebp),%eax
  801889:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 02 00 00 00       	mov    $0x2,%eax
  801898:	e8 6b ff ff ff       	call   801808 <fsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ba:	e8 49 ff ff ff       	call   801808 <fsipc>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8018d1:	e8 32 ff ff ff       	call   801808 <fsipc>
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	53                   	push   %ebx
  8018dc:	83 ec 14             	sub    $0x14,%esp
  8018df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f7:	e8 0c ff ff ff       	call   801808 <fsipc>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 2b                	js     80192b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801900:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801907:	00 
  801908:	89 1c 24             	mov    %ebx,(%esp)
  80190b:	e8 3a f0 ff ff       	call   80094a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801910:	a1 80 50 80 00       	mov    0x805080,%eax
  801915:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80191b:	a1 84 50 80 00       	mov    0x805084,%eax
  801920:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801926:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80192b:	83 c4 14             	add    $0x14,%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5d                   	pop    %ebp
  801930:	c3                   	ret    

00801931 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 18             	sub    $0x18,%esp
  801937:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80193a:	8b 55 08             	mov    0x8(%ebp),%edx
  80193d:	8b 52 0c             	mov    0xc(%edx),%edx
  801940:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801946:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80194b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801950:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801955:	0f 47 c2             	cmova  %edx,%eax
  801958:	89 44 24 08          	mov    %eax,0x8(%esp)
  80195c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801963:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80196a:	e8 c6 f1 ff ff       	call   800b35 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80196f:	ba 00 00 00 00       	mov    $0x0,%edx
  801974:	b8 04 00 00 00       	mov    $0x4,%eax
  801979:	e8 8a fe ff ff       	call   801808 <fsipc>
}
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	53                   	push   %ebx
  801984:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801987:	8b 45 08             	mov    0x8(%ebp),%eax
  80198a:	8b 40 0c             	mov    0xc(%eax),%eax
  80198d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801992:	8b 45 10             	mov    0x10(%ebp),%eax
  801995:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80199a:	ba 00 00 00 00       	mov    $0x0,%edx
  80199f:	b8 03 00 00 00       	mov    $0x3,%eax
  8019a4:	e8 5f fe ff ff       	call   801808 <fsipc>
  8019a9:	89 c3                	mov    %eax,%ebx
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	78 17                	js     8019c6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019ba:	00 
  8019bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019be:	89 04 24             	mov    %eax,(%esp)
  8019c1:	e8 6f f1 ff ff       	call   800b35 <memmove>
  return r;	
}
  8019c6:	89 d8                	mov    %ebx,%eax
  8019c8:	83 c4 14             	add    $0x14,%esp
  8019cb:	5b                   	pop    %ebx
  8019cc:	5d                   	pop    %ebp
  8019cd:	c3                   	ret    

008019ce <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8019ce:	55                   	push   %ebp
  8019cf:	89 e5                	mov    %esp,%ebp
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 14             	sub    $0x14,%esp
  8019d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019d8:	89 1c 24             	mov    %ebx,(%esp)
  8019db:	e8 20 ef ff ff       	call   800900 <strlen>
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8019e7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8019ed:	7f 1f                	jg     801a0e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8019ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019f3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019fa:	e8 4b ef ff ff       	call   80094a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8019ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801a04:	b8 07 00 00 00       	mov    $0x7,%eax
  801a09:	e8 fa fd ff ff       	call   801808 <fsipc>
}
  801a0e:	83 c4 14             	add    $0x14,%esp
  801a11:	5b                   	pop    %ebx
  801a12:	5d                   	pop    %ebp
  801a13:	c3                   	ret    

00801a14 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	83 ec 28             	sub    $0x28,%esp
  801a1a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a1d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a20:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801a23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 dd f7 ff ff       	call   80120b <fd_alloc>
  801a2e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a30:	85 c0                	test   %eax,%eax
  801a32:	0f 88 89 00 00 00    	js     801ac1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a38:	89 34 24             	mov    %esi,(%esp)
  801a3b:	e8 c0 ee ff ff       	call   800900 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a40:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a45:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a4a:	7f 75                	jg     801ac1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a50:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a57:	e8 ee ee ff ff       	call   80094a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801a64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a67:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6c:	e8 97 fd ff ff       	call   801808 <fsipc>
  801a71:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 0f                	js     801a86 <open+0x72>
  return fd2num(fd);
  801a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7a:	89 04 24             	mov    %eax,(%esp)
  801a7d:	e8 5e f7 ff ff       	call   8011e0 <fd2num>
  801a82:	89 c3                	mov    %eax,%ebx
  801a84:	eb 3b                	jmp    801ac1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801a86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a8d:	00 
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 2b fb ff ff       	call   8015c4 <fd_close>
  801a99:	85 c0                	test   %eax,%eax
  801a9b:	74 24                	je     801ac1 <open+0xad>
  801a9d:	c7 44 24 0c e0 28 80 	movl   $0x8028e0,0xc(%esp)
  801aa4:	00 
  801aa5:	c7 44 24 08 f5 28 80 	movl   $0x8028f5,0x8(%esp)
  801aac:	00 
  801aad:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801ab4:	00 
  801ab5:	c7 04 24 0a 29 80 00 	movl   $0x80290a,(%esp)
  801abc:	e8 8f e6 ff ff       	call   800150 <_panic>
  return r;
}
  801ac1:	89 d8                	mov    %ebx,%eax
  801ac3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ac6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ac9:	89 ec                	mov    %ebp,%esp
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    
  801acd:	00 00                	add    %al,(%eax)
	...

00801ad0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ad6:	c7 44 24 04 15 29 80 	movl   $0x802915,0x4(%esp)
  801add:	00 
  801ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ae1:	89 04 24             	mov    %eax,(%esp)
  801ae4:	e8 61 ee ff ff       	call   80094a <strcpy>
	return 0;
}
  801ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	53                   	push   %ebx
  801af4:	83 ec 14             	sub    $0x14,%esp
  801af7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801afa:	89 1c 24             	mov    %ebx,(%esp)
  801afd:	e8 22 06 00 00       	call   802124 <pageref>
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	b8 00 00 00 00       	mov    $0x0,%eax
  801b09:	83 fa 01             	cmp    $0x1,%edx
  801b0c:	75 0b                	jne    801b19 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801b0e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b11:	89 04 24             	mov    %eax,(%esp)
  801b14:	e8 b9 02 00 00       	call   801dd2 <nsipc_close>
	else
		return 0;
}
  801b19:	83 c4 14             	add    $0x14,%esp
  801b1c:	5b                   	pop    %ebx
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b25:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b2c:	00 
  801b2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 c5 02 00 00       	call   801e0e <nsipc_send>
}
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b51:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b58:	00 
  801b59:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6d:	89 04 24             	mov    %eax,(%esp)
  801b70:	e8 0c 03 00 00       	call   801e81 <nsipc_recv>
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	56                   	push   %esi
  801b7b:	53                   	push   %ebx
  801b7c:	83 ec 20             	sub    $0x20,%esp
  801b7f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b84:	89 04 24             	mov    %eax,(%esp)
  801b87:	e8 7f f6 ff ff       	call   80120b <fd_alloc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 21                	js     801bb3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b92:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b99:	00 
  801b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ba8:	e8 00 f4 ff ff       	call   800fad <sys_page_alloc>
  801bad:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801baf:	85 c0                	test   %eax,%eax
  801bb1:	79 0a                	jns    801bbd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801bb3:	89 34 24             	mov    %esi,(%esp)
  801bb6:	e8 17 02 00 00       	call   801dd2 <nsipc_close>
		return r;
  801bbb:	eb 28                	jmp    801be5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bbd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bc6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 fd f5 ff ff       	call   8011e0 <fd2num>
  801be3:	89 c3                	mov    %eax,%ebx
}
  801be5:	89 d8                	mov    %ebx,%eax
  801be7:	83 c4 20             	add    $0x20,%esp
  801bea:	5b                   	pop    %ebx
  801beb:	5e                   	pop    %esi
  801bec:	5d                   	pop    %ebp
  801bed:	c3                   	ret    

00801bee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bee:	55                   	push   %ebp
  801bef:	89 e5                	mov    %esp,%ebp
  801bf1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bf4:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c02:	8b 45 08             	mov    0x8(%ebp),%eax
  801c05:	89 04 24             	mov    %eax,(%esp)
  801c08:	e8 79 01 00 00       	call   801d86 <nsipc_socket>
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	78 05                	js     801c16 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c11:	e8 61 ff ff ff       	call   801b77 <alloc_sockfd>
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c1e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c21:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c25:	89 04 24             	mov    %eax,(%esp)
  801c28:	e8 50 f6 ff ff       	call   80127d <fd_lookup>
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 15                	js     801c46 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c34:	8b 0a                	mov    (%edx),%ecx
  801c36:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c3b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801c41:	75 03                	jne    801c46 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c43:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c51:	e8 c2 ff ff ff       	call   801c18 <fd2sockid>
  801c56:	85 c0                	test   %eax,%eax
  801c58:	78 0f                	js     801c69 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c61:	89 04 24             	mov    %eax,(%esp)
  801c64:	e8 47 01 00 00       	call   801db0 <nsipc_listen>
}
  801c69:	c9                   	leave  
  801c6a:	c3                   	ret    

00801c6b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c71:	8b 45 08             	mov    0x8(%ebp),%eax
  801c74:	e8 9f ff ff ff       	call   801c18 <fd2sockid>
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	78 16                	js     801c93 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c7d:	8b 55 10             	mov    0x10(%ebp),%edx
  801c80:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c87:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c8b:	89 04 24             	mov    %eax,(%esp)
  801c8e:	e8 6e 02 00 00       	call   801f01 <nsipc_connect>
}
  801c93:	c9                   	leave  
  801c94:	c3                   	ret    

00801c95 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9e:	e8 75 ff ff ff       	call   801c18 <fd2sockid>
  801ca3:	85 c0                	test   %eax,%eax
  801ca5:	78 0f                	js     801cb6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801caa:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cae:	89 04 24             	mov    %eax,(%esp)
  801cb1:	e8 36 01 00 00       	call   801dec <nsipc_shutdown>
}
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    

00801cb8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cb8:	55                   	push   %ebp
  801cb9:	89 e5                	mov    %esp,%ebp
  801cbb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc1:	e8 52 ff ff ff       	call   801c18 <fd2sockid>
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 16                	js     801ce0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cca:	8b 55 10             	mov    0x10(%ebp),%edx
  801ccd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cd4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cd8:	89 04 24             	mov    %eax,(%esp)
  801cdb:	e8 60 02 00 00       	call   801f40 <nsipc_bind>
}
  801ce0:	c9                   	leave  
  801ce1:	c3                   	ret    

00801ce2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	e8 28 ff ff ff       	call   801c18 <fd2sockid>
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 1f                	js     801d13 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cf4:	8b 55 10             	mov    0x10(%ebp),%edx
  801cf7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cfe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d02:	89 04 24             	mov    %eax,(%esp)
  801d05:	e8 75 02 00 00       	call   801f7f <nsipc_accept>
  801d0a:	85 c0                	test   %eax,%eax
  801d0c:	78 05                	js     801d13 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d0e:	e8 64 fe ff ff       	call   801b77 <alloc_sockfd>
}
  801d13:	c9                   	leave  
  801d14:	c3                   	ret    
	...

00801d20 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d20:	55                   	push   %ebp
  801d21:	89 e5                	mov    %esp,%ebp
  801d23:	53                   	push   %ebx
  801d24:	83 ec 14             	sub    $0x14,%esp
  801d27:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d29:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d30:	75 11                	jne    801d43 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d32:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801d39:	e8 a2 02 00 00       	call   801fe0 <ipc_find_env>
  801d3e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d43:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d4a:	00 
  801d4b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d52:	00 
  801d53:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d57:	a1 04 40 80 00       	mov    0x804004,%eax
  801d5c:	89 04 24             	mov    %eax,(%esp)
  801d5f:	e8 c5 02 00 00       	call   802029 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d6b:	00 
  801d6c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d73:	00 
  801d74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7b:	e8 14 03 00 00       	call   802094 <ipc_recv>
}
  801d80:	83 c4 14             	add    $0x14,%esp
  801d83:	5b                   	pop    %ebx
  801d84:	5d                   	pop    %ebp
  801d85:	c3                   	ret    

00801d86 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801d86:	55                   	push   %ebp
  801d87:	89 e5                	mov    %esp,%ebp
  801d89:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d97:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801d9c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d9f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801da4:	b8 09 00 00 00       	mov    $0x9,%eax
  801da9:	e8 72 ff ff ff       	call   801d20 <nsipc>
}
  801dae:	c9                   	leave  
  801daf:	c3                   	ret    

00801db0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801db6:	8b 45 08             	mov    0x8(%ebp),%eax
  801db9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dc6:	b8 06 00 00 00       	mov    $0x6,%eax
  801dcb:	e8 50 ff ff ff       	call   801d20 <nsipc>
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dd8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801de0:	b8 04 00 00 00       	mov    $0x4,%eax
  801de5:	e8 36 ff ff ff       	call   801d20 <nsipc>
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801df2:	8b 45 08             	mov    0x8(%ebp),%eax
  801df5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e02:	b8 03 00 00 00       	mov    $0x3,%eax
  801e07:	e8 14 ff ff ff       	call   801d20 <nsipc>
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	53                   	push   %ebx
  801e12:	83 ec 14             	sub    $0x14,%esp
  801e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e20:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e26:	7e 24                	jle    801e4c <nsipc_send+0x3e>
  801e28:	c7 44 24 0c 21 29 80 	movl   $0x802921,0xc(%esp)
  801e2f:	00 
  801e30:	c7 44 24 08 f5 28 80 	movl   $0x8028f5,0x8(%esp)
  801e37:	00 
  801e38:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801e3f:	00 
  801e40:	c7 04 24 2d 29 80 00 	movl   $0x80292d,(%esp)
  801e47:	e8 04 e3 ff ff       	call   800150 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e4c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e53:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e57:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e5e:	e8 d2 ec ff ff       	call   800b35 <memmove>
	nsipcbuf.send.req_size = size;
  801e63:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e69:	8b 45 14             	mov    0x14(%ebp),%eax
  801e6c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e71:	b8 08 00 00 00       	mov    $0x8,%eax
  801e76:	e8 a5 fe ff ff       	call   801d20 <nsipc>
}
  801e7b:	83 c4 14             	add    $0x14,%esp
  801e7e:	5b                   	pop    %ebx
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    

00801e81 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	56                   	push   %esi
  801e85:	53                   	push   %ebx
  801e86:	83 ec 10             	sub    $0x10,%esp
  801e89:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e94:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e9a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ea2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ea7:	e8 74 fe ff ff       	call   801d20 <nsipc>
  801eac:	89 c3                	mov    %eax,%ebx
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 46                	js     801ef8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801eb2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801eb7:	7f 04                	jg     801ebd <nsipc_recv+0x3c>
  801eb9:	39 c6                	cmp    %eax,%esi
  801ebb:	7d 24                	jge    801ee1 <nsipc_recv+0x60>
  801ebd:	c7 44 24 0c 39 29 80 	movl   $0x802939,0xc(%esp)
  801ec4:	00 
  801ec5:	c7 44 24 08 f5 28 80 	movl   $0x8028f5,0x8(%esp)
  801ecc:	00 
  801ecd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801ed4:	00 
  801ed5:	c7 04 24 2d 29 80 00 	movl   $0x80292d,(%esp)
  801edc:	e8 6f e2 ff ff       	call   800150 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ee1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ee5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801eec:	00 
  801eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef0:	89 04 24             	mov    %eax,(%esp)
  801ef3:	e8 3d ec ff ff       	call   800b35 <memmove>
	}

	return r;
}
  801ef8:	89 d8                	mov    %ebx,%eax
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	5b                   	pop    %ebx
  801efe:	5e                   	pop    %esi
  801eff:	5d                   	pop    %ebp
  801f00:	c3                   	ret    

00801f01 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f01:	55                   	push   %ebp
  801f02:	89 e5                	mov    %esp,%ebp
  801f04:	53                   	push   %ebx
  801f05:	83 ec 14             	sub    $0x14,%esp
  801f08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f0e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f13:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f1e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f25:	e8 0b ec ff ff       	call   800b35 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f2a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f30:	b8 05 00 00 00       	mov    $0x5,%eax
  801f35:	e8 e6 fd ff ff       	call   801d20 <nsipc>
}
  801f3a:	83 c4 14             	add    $0x14,%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5d                   	pop    %ebp
  801f3f:	c3                   	ret    

00801f40 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	53                   	push   %ebx
  801f44:	83 ec 14             	sub    $0x14,%esp
  801f47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f64:	e8 cc eb ff ff       	call   800b35 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f69:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f6f:	b8 02 00 00 00       	mov    $0x2,%eax
  801f74:	e8 a7 fd ff ff       	call   801d20 <nsipc>
}
  801f79:	83 c4 14             	add    $0x14,%esp
  801f7c:	5b                   	pop    %ebx
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    

00801f7f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 18             	sub    $0x18,%esp
  801f85:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f88:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f93:	b8 01 00 00 00       	mov    $0x1,%eax
  801f98:	e8 83 fd ff ff       	call   801d20 <nsipc>
  801f9d:	89 c3                	mov    %eax,%ebx
  801f9f:	85 c0                	test   %eax,%eax
  801fa1:	78 25                	js     801fc8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fa3:	be 10 60 80 00       	mov    $0x806010,%esi
  801fa8:	8b 06                	mov    (%esi),%eax
  801faa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fae:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fb5:	00 
  801fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fb9:	89 04 24             	mov    %eax,(%esp)
  801fbc:	e8 74 eb ff ff       	call   800b35 <memmove>
		*addrlen = ret->ret_addrlen;
  801fc1:	8b 16                	mov    (%esi),%edx
  801fc3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801fc8:	89 d8                	mov    %ebx,%eax
  801fca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fcd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fd0:	89 ec                	mov    %ebp,%esp
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
	...

00801fe0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801fe6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801fec:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff1:	39 ca                	cmp    %ecx,%edx
  801ff3:	75 04                	jne    801ff9 <ipc_find_env+0x19>
  801ff5:	b0 00                	mov    $0x0,%al
  801ff7:	eb 11                	jmp    80200a <ipc_find_env+0x2a>
  801ff9:	89 c2                	mov    %eax,%edx
  801ffb:	c1 e2 07             	shl    $0x7,%edx
  801ffe:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802004:	8b 12                	mov    (%edx),%edx
  802006:	39 ca                	cmp    %ecx,%edx
  802008:	75 0f                	jne    802019 <ipc_find_env+0x39>
			return envs[i].env_id;
  80200a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  80200e:	c1 e0 06             	shl    $0x6,%eax
  802011:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  802017:	eb 0e                	jmp    802027 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802019:	83 c0 01             	add    $0x1,%eax
  80201c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802021:	75 d6                	jne    801ff9 <ipc_find_env+0x19>
  802023:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802027:	5d                   	pop    %ebp
  802028:	c3                   	ret    

00802029 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802029:	55                   	push   %ebp
  80202a:	89 e5                	mov    %esp,%ebp
  80202c:	57                   	push   %edi
  80202d:	56                   	push   %esi
  80202e:	53                   	push   %ebx
  80202f:	83 ec 1c             	sub    $0x1c,%esp
  802032:	8b 75 08             	mov    0x8(%ebp),%esi
  802035:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802038:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80203b:	85 db                	test   %ebx,%ebx
  80203d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802042:	0f 44 d8             	cmove  %eax,%ebx
  802045:	eb 25                	jmp    80206c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  802047:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80204a:	74 20                	je     80206c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  80204c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802050:	c7 44 24 08 4e 29 80 	movl   $0x80294e,0x8(%esp)
  802057:	00 
  802058:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80205f:	00 
  802060:	c7 04 24 6c 29 80 00 	movl   $0x80296c,(%esp)
  802067:	e8 e4 e0 ff ff       	call   800150 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80206c:	8b 45 14             	mov    0x14(%ebp),%eax
  80206f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802073:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802077:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80207b:	89 34 24             	mov    %esi,(%esp)
  80207e:	e8 db ed ff ff       	call   800e5e <sys_ipc_try_send>
  802083:	85 c0                	test   %eax,%eax
  802085:	75 c0                	jne    802047 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802087:	e8 58 ef ff ff       	call   800fe4 <sys_yield>
}
  80208c:	83 c4 1c             	add    $0x1c,%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    

00802094 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	83 ec 28             	sub    $0x28,%esp
  80209a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80209d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8020a0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8020a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020a9:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8020ac:	85 c0                	test   %eax,%eax
  8020ae:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020b3:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8020b6:	89 04 24             	mov    %eax,(%esp)
  8020b9:	e8 67 ed ff ff       	call   800e25 <sys_ipc_recv>
  8020be:	89 c3                	mov    %eax,%ebx
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	79 2a                	jns    8020ee <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8020c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020cc:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  8020d3:	e8 31 e1 ff ff       	call   800209 <cprintf>
		if(from_env_store != NULL)
  8020d8:	85 f6                	test   %esi,%esi
  8020da:	74 06                	je     8020e2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8020dc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8020e2:	85 ff                	test   %edi,%edi
  8020e4:	74 2c                	je     802112 <ipc_recv+0x7e>
			*perm_store = 0;
  8020e6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8020ec:	eb 24                	jmp    802112 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8020ee:	85 f6                	test   %esi,%esi
  8020f0:	74 0a                	je     8020fc <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8020f2:	a1 08 40 80 00       	mov    0x804008,%eax
  8020f7:	8b 40 74             	mov    0x74(%eax),%eax
  8020fa:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8020fc:	85 ff                	test   %edi,%edi
  8020fe:	74 0a                	je     80210a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802100:	a1 08 40 80 00       	mov    0x804008,%eax
  802105:	8b 40 78             	mov    0x78(%eax),%eax
  802108:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80210a:	a1 08 40 80 00       	mov    0x804008,%eax
  80210f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802112:	89 d8                	mov    %ebx,%eax
  802114:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802117:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80211a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80211d:	89 ec                	mov    %ebp,%esp
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    
  802121:	00 00                	add    %al,(%eax)
	...

00802124 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802124:	55                   	push   %ebp
  802125:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802127:	8b 45 08             	mov    0x8(%ebp),%eax
  80212a:	89 c2                	mov    %eax,%edx
  80212c:	c1 ea 16             	shr    $0x16,%edx
  80212f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802136:	f6 c2 01             	test   $0x1,%dl
  802139:	74 20                	je     80215b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80213b:	c1 e8 0c             	shr    $0xc,%eax
  80213e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802145:	a8 01                	test   $0x1,%al
  802147:	74 12                	je     80215b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802149:	c1 e8 0c             	shr    $0xc,%eax
  80214c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802151:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802156:	0f b7 c0             	movzwl %ax,%eax
  802159:	eb 05                	jmp    802160 <pageref+0x3c>
  80215b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
	...

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	57                   	push   %edi
  802174:	56                   	push   %esi
  802175:	83 ec 10             	sub    $0x10,%esp
  802178:	8b 45 14             	mov    0x14(%ebp),%eax
  80217b:	8b 55 08             	mov    0x8(%ebp),%edx
  80217e:	8b 75 10             	mov    0x10(%ebp),%esi
  802181:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802184:	85 c0                	test   %eax,%eax
  802186:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802189:	75 35                	jne    8021c0 <__udivdi3+0x50>
  80218b:	39 fe                	cmp    %edi,%esi
  80218d:	77 61                	ja     8021f0 <__udivdi3+0x80>
  80218f:	85 f6                	test   %esi,%esi
  802191:	75 0b                	jne    80219e <__udivdi3+0x2e>
  802193:	b8 01 00 00 00       	mov    $0x1,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	f7 f6                	div    %esi
  80219c:	89 c6                	mov    %eax,%esi
  80219e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8021a1:	31 d2                	xor    %edx,%edx
  8021a3:	89 f8                	mov    %edi,%eax
  8021a5:	f7 f6                	div    %esi
  8021a7:	89 c7                	mov    %eax,%edi
  8021a9:	89 c8                	mov    %ecx,%eax
  8021ab:	f7 f6                	div    %esi
  8021ad:	89 c1                	mov    %eax,%ecx
  8021af:	89 fa                	mov    %edi,%edx
  8021b1:	89 c8                	mov    %ecx,%eax
  8021b3:	83 c4 10             	add    $0x10,%esp
  8021b6:	5e                   	pop    %esi
  8021b7:	5f                   	pop    %edi
  8021b8:	5d                   	pop    %ebp
  8021b9:	c3                   	ret    
  8021ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c0:	39 f8                	cmp    %edi,%eax
  8021c2:	77 1c                	ja     8021e0 <__udivdi3+0x70>
  8021c4:	0f bd d0             	bsr    %eax,%edx
  8021c7:	83 f2 1f             	xor    $0x1f,%edx
  8021ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021cd:	75 39                	jne    802208 <__udivdi3+0x98>
  8021cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8021d2:	0f 86 a0 00 00 00    	jbe    802278 <__udivdi3+0x108>
  8021d8:	39 f8                	cmp    %edi,%eax
  8021da:	0f 82 98 00 00 00    	jb     802278 <__udivdi3+0x108>
  8021e0:	31 ff                	xor    %edi,%edi
  8021e2:	31 c9                	xor    %ecx,%ecx
  8021e4:	89 c8                	mov    %ecx,%eax
  8021e6:	89 fa                	mov    %edi,%edx
  8021e8:	83 c4 10             	add    $0x10,%esp
  8021eb:	5e                   	pop    %esi
  8021ec:	5f                   	pop    %edi
  8021ed:	5d                   	pop    %ebp
  8021ee:	c3                   	ret    
  8021ef:	90                   	nop
  8021f0:	89 d1                	mov    %edx,%ecx
  8021f2:	89 fa                	mov    %edi,%edx
  8021f4:	89 c8                	mov    %ecx,%eax
  8021f6:	31 ff                	xor    %edi,%edi
  8021f8:	f7 f6                	div    %esi
  8021fa:	89 c1                	mov    %eax,%ecx
  8021fc:	89 fa                	mov    %edi,%edx
  8021fe:	89 c8                	mov    %ecx,%eax
  802200:	83 c4 10             	add    $0x10,%esp
  802203:	5e                   	pop    %esi
  802204:	5f                   	pop    %edi
  802205:	5d                   	pop    %ebp
  802206:	c3                   	ret    
  802207:	90                   	nop
  802208:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80220c:	89 f2                	mov    %esi,%edx
  80220e:	d3 e0                	shl    %cl,%eax
  802210:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802213:	b8 20 00 00 00       	mov    $0x20,%eax
  802218:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80221b:	89 c1                	mov    %eax,%ecx
  80221d:	d3 ea                	shr    %cl,%edx
  80221f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802223:	0b 55 ec             	or     -0x14(%ebp),%edx
  802226:	d3 e6                	shl    %cl,%esi
  802228:	89 c1                	mov    %eax,%ecx
  80222a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80222d:	89 fe                	mov    %edi,%esi
  80222f:	d3 ee                	shr    %cl,%esi
  802231:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802235:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802238:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80223b:	d3 e7                	shl    %cl,%edi
  80223d:	89 c1                	mov    %eax,%ecx
  80223f:	d3 ea                	shr    %cl,%edx
  802241:	09 d7                	or     %edx,%edi
  802243:	89 f2                	mov    %esi,%edx
  802245:	89 f8                	mov    %edi,%eax
  802247:	f7 75 ec             	divl   -0x14(%ebp)
  80224a:	89 d6                	mov    %edx,%esi
  80224c:	89 c7                	mov    %eax,%edi
  80224e:	f7 65 e8             	mull   -0x18(%ebp)
  802251:	39 d6                	cmp    %edx,%esi
  802253:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802256:	72 30                	jb     802288 <__udivdi3+0x118>
  802258:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80225b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	39 c2                	cmp    %eax,%edx
  802263:	73 05                	jae    80226a <__udivdi3+0xfa>
  802265:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802268:	74 1e                	je     802288 <__udivdi3+0x118>
  80226a:	89 f9                	mov    %edi,%ecx
  80226c:	31 ff                	xor    %edi,%edi
  80226e:	e9 71 ff ff ff       	jmp    8021e4 <__udivdi3+0x74>
  802273:	90                   	nop
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	31 ff                	xor    %edi,%edi
  80227a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80227f:	e9 60 ff ff ff       	jmp    8021e4 <__udivdi3+0x74>
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80228b:	31 ff                	xor    %edi,%edi
  80228d:	89 c8                	mov    %ecx,%eax
  80228f:	89 fa                	mov    %edi,%edx
  802291:	83 c4 10             	add    $0x10,%esp
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
	...

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	57                   	push   %edi
  8022a4:	56                   	push   %esi
  8022a5:	83 ec 20             	sub    $0x20,%esp
  8022a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8022ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8022b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022b4:	85 d2                	test   %edx,%edx
  8022b6:	89 c8                	mov    %ecx,%eax
  8022b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8022bb:	75 13                	jne    8022d0 <__umoddi3+0x30>
  8022bd:	39 f7                	cmp    %esi,%edi
  8022bf:	76 3f                	jbe    802300 <__umoddi3+0x60>
  8022c1:	89 f2                	mov    %esi,%edx
  8022c3:	f7 f7                	div    %edi
  8022c5:	89 d0                	mov    %edx,%eax
  8022c7:	31 d2                	xor    %edx,%edx
  8022c9:	83 c4 20             	add    $0x20,%esp
  8022cc:	5e                   	pop    %esi
  8022cd:	5f                   	pop    %edi
  8022ce:	5d                   	pop    %ebp
  8022cf:	c3                   	ret    
  8022d0:	39 f2                	cmp    %esi,%edx
  8022d2:	77 4c                	ja     802320 <__umoddi3+0x80>
  8022d4:	0f bd ca             	bsr    %edx,%ecx
  8022d7:	83 f1 1f             	xor    $0x1f,%ecx
  8022da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8022dd:	75 51                	jne    802330 <__umoddi3+0x90>
  8022df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8022e2:	0f 87 e0 00 00 00    	ja     8023c8 <__umoddi3+0x128>
  8022e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022eb:	29 f8                	sub    %edi,%eax
  8022ed:	19 d6                	sbb    %edx,%esi
  8022ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8022f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f5:	89 f2                	mov    %esi,%edx
  8022f7:	83 c4 20             	add    $0x20,%esp
  8022fa:	5e                   	pop    %esi
  8022fb:	5f                   	pop    %edi
  8022fc:	5d                   	pop    %ebp
  8022fd:	c3                   	ret    
  8022fe:	66 90                	xchg   %ax,%ax
  802300:	85 ff                	test   %edi,%edi
  802302:	75 0b                	jne    80230f <__umoddi3+0x6f>
  802304:	b8 01 00 00 00       	mov    $0x1,%eax
  802309:	31 d2                	xor    %edx,%edx
  80230b:	f7 f7                	div    %edi
  80230d:	89 c7                	mov    %eax,%edi
  80230f:	89 f0                	mov    %esi,%eax
  802311:	31 d2                	xor    %edx,%edx
  802313:	f7 f7                	div    %edi
  802315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802318:	f7 f7                	div    %edi
  80231a:	eb a9                	jmp    8022c5 <__umoddi3+0x25>
  80231c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802320:	89 c8                	mov    %ecx,%eax
  802322:	89 f2                	mov    %esi,%edx
  802324:	83 c4 20             	add    $0x20,%esp
  802327:	5e                   	pop    %esi
  802328:	5f                   	pop    %edi
  802329:	5d                   	pop    %ebp
  80232a:	c3                   	ret    
  80232b:	90                   	nop
  80232c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802330:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802334:	d3 e2                	shl    %cl,%edx
  802336:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802339:	ba 20 00 00 00       	mov    $0x20,%edx
  80233e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802341:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802344:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802348:	89 fa                	mov    %edi,%edx
  80234a:	d3 ea                	shr    %cl,%edx
  80234c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802350:	0b 55 f4             	or     -0xc(%ebp),%edx
  802353:	d3 e7                	shl    %cl,%edi
  802355:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802359:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80235c:	89 f2                	mov    %esi,%edx
  80235e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802361:	89 c7                	mov    %eax,%edi
  802363:	d3 ea                	shr    %cl,%edx
  802365:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802369:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80236c:	89 c2                	mov    %eax,%edx
  80236e:	d3 e6                	shl    %cl,%esi
  802370:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802374:	d3 ea                	shr    %cl,%edx
  802376:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80237a:	09 d6                	or     %edx,%esi
  80237c:	89 f0                	mov    %esi,%eax
  80237e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802381:	d3 e7                	shl    %cl,%edi
  802383:	89 f2                	mov    %esi,%edx
  802385:	f7 75 f4             	divl   -0xc(%ebp)
  802388:	89 d6                	mov    %edx,%esi
  80238a:	f7 65 e8             	mull   -0x18(%ebp)
  80238d:	39 d6                	cmp    %edx,%esi
  80238f:	72 2b                	jb     8023bc <__umoddi3+0x11c>
  802391:	39 c7                	cmp    %eax,%edi
  802393:	72 23                	jb     8023b8 <__umoddi3+0x118>
  802395:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802399:	29 c7                	sub    %eax,%edi
  80239b:	19 d6                	sbb    %edx,%esi
  80239d:	89 f0                	mov    %esi,%eax
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	d3 ef                	shr    %cl,%edi
  8023a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8023a7:	d3 e0                	shl    %cl,%eax
  8023a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023ad:	09 f8                	or     %edi,%eax
  8023af:	d3 ea                	shr    %cl,%edx
  8023b1:	83 c4 20             	add    $0x20,%esp
  8023b4:	5e                   	pop    %esi
  8023b5:	5f                   	pop    %edi
  8023b6:	5d                   	pop    %ebp
  8023b7:	c3                   	ret    
  8023b8:	39 d6                	cmp    %edx,%esi
  8023ba:	75 d9                	jne    802395 <__umoddi3+0xf5>
  8023bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8023bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8023c2:	eb d1                	jmp    802395 <__umoddi3+0xf5>
  8023c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8023c8:	39 f2                	cmp    %esi,%edx
  8023ca:	0f 82 18 ff ff ff    	jb     8022e8 <__umoddi3+0x48>
  8023d0:	e9 1d ff ff ff       	jmp    8022f2 <__umoddi3+0x52>
