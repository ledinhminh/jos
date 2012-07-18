
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
  800041:	e8 86 10 00 00       	call   8010cc <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800046:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80004d:	00 
  80004e:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  800055:	e8 39 10 00 00       	call   801093 <sys_cputs>
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
  80006c:	c7 04 24 20 1e 80 00 	movl   $0x801e20,(%esp)
  800073:	e8 91 01 00 00       	call   800209 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800078:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007f:	00 
  800080:	89 d8                	mov    %ebx,%eax
  800082:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800087:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800092:	e8 a3 0e 00 00       	call   800f3a <sys_page_alloc>
  800097:	85 c0                	test   %eax,%eax
  800099:	79 24                	jns    8000bf <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a3:	c7 44 24 08 40 1e 80 	movl   $0x801e40,0x8(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b2:	00 
  8000b3:	c7 04 24 2a 1e 80 00 	movl   $0x801e2a,(%esp)
  8000ba:	e8 91 00 00 00       	call   800150 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000bf:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c3:	c7 44 24 08 6c 1e 80 	movl   $0x801e6c,0x8(%esp)
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
  8000f6:	e8 e9 0e 00 00       	call   800fe4 <sys_getenvid>
  8000fb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800100:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800103:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800108:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80013a:	e8 1a 15 00 00       	call   801659 <close_all>
	sys_env_destroy(0);
  80013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800146:	e8 d4 0e 00 00       	call   80101f <sys_env_destroy>
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
  800161:	e8 7e 0e 00 00       	call   800fe4 <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 98 1e 80 00 	movl   $0x801e98,(%esp)
  800183:	e8 81 00 00 00       	call   800209 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 11 00 00 00       	call   8001a8 <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 0f 23 80 00 	movl   $0x80230f,(%esp)
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
  8001fc:	e8 92 0e 00 00       	call   801093 <sys_cputs>

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
  800250:	e8 3e 0e 00 00       	call   801093 <sys_cputs>
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
  8002ed:	e8 be 18 00 00       	call   801bb0 <__udivdi3>
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
  800348:	e8 93 19 00 00       	call   801ce0 <__umoddi3>
  80034d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800351:	0f be 80 bb 1e 80 00 	movsbl 0x801ebb(%eax),%eax
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
  800435:	ff 24 95 a0 20 80 00 	jmp    *0x8020a0(,%edx,4)
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
  800508:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80050f:	85 d2                	test   %edx,%edx
  800511:	75 20                	jne    800533 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800513:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800517:	c7 44 24 08 cc 1e 80 	movl   $0x801ecc,0x8(%esp)
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
  800537:	c7 44 24 08 43 23 80 	movl   $0x802343,0x8(%esp)
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
  800571:	b8 d5 1e 80 00       	mov    $0x801ed5,%eax
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
  8007b5:	c7 44 24 0c f0 1f 80 	movl   $0x801ff0,0xc(%esp)
  8007bc:	00 
  8007bd:	c7 44 24 08 43 23 80 	movl   $0x802343,0x8(%esp)
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
  8007e3:	c7 44 24 0c 28 20 80 	movl   $0x802028,0xc(%esp)
  8007ea:	00 
  8007eb:	c7 44 24 08 43 23 80 	movl   $0x802343,0x8(%esp)
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
  800d87:	c7 44 24 08 40 22 80 	movl   $0x802240,0x8(%esp)
  800d8e:	00 
  800d8f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d96:	00 
  800d97:	c7 04 24 5d 22 80 00 	movl   $0x80225d,(%esp)
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

00800db2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800db8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dbf:	00 
  800dc0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dc7:	00 
  800dc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dcf:	00 
  800dd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dda:	ba 01 00 00 00       	mov    $0x1,%edx
  800ddf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de4:	e8 53 ff ff ff       	call   800d3c <syscall>
}
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    

00800deb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800df1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800df8:	00 
  800df9:	8b 45 14             	mov    0x14(%ebp),%eax
  800dfc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e00:	8b 45 10             	mov    0x10(%ebp),%eax
  800e03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	89 04 24             	mov    %eax,(%esp)
  800e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e10:	ba 00 00 00 00       	mov    $0x0,%edx
  800e15:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1a:	e8 1d ff ff ff       	call   800d3c <syscall>
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e27:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e36:	00 
  800e37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e3e:	00 
  800e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e42:	89 04 24             	mov    %eax,(%esp)
  800e45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e48:	ba 01 00 00 00       	mov    $0x1,%edx
  800e4d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e52:	e8 e5 fe ff ff       	call   800d3c <syscall>
}
  800e57:	c9                   	leave  
  800e58:	c3                   	ret    

00800e59 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e59:	55                   	push   %ebp
  800e5a:	89 e5                	mov    %esp,%ebp
  800e5c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e5f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e66:	00 
  800e67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e6e:	00 
  800e6f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e76:	00 
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	89 04 24             	mov    %eax,(%esp)
  800e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e80:	ba 01 00 00 00       	mov    $0x1,%edx
  800e85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8a:	e8 ad fe ff ff       	call   800d3c <syscall>
}
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  800ebd:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec2:	e8 75 fe ff ff       	call   800d3c <syscall>
}
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800ef5:	b8 07 00 00 00       	mov    $0x7,%eax
  800efa:	e8 3d fe ff ff       	call   800d3c <syscall>
}
  800eff:	c9                   	leave  
  800f00:	c3                   	ret    

00800f01 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f0e:	00 
  800f0f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f12:	0b 45 14             	or     0x14(%ebp),%eax
  800f15:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f19:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f23:	89 04 24             	mov    %eax,(%esp)
  800f26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f29:	ba 01 00 00 00       	mov    $0x1,%edx
  800f2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f33:	e8 04 fe ff ff       	call   800d3c <syscall>
}
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f40:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f47:	00 
  800f48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f4f:	00 
  800f50:	8b 45 10             	mov    0x10(%ebp),%eax
  800f53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5a:	89 04 24             	mov    %eax,(%esp)
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	ba 01 00 00 00       	mov    $0x1,%edx
  800f65:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6a:	e8 cd fd ff ff       	call   800d3c <syscall>
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7e:	00 
  800f7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f86:	00 
  800f87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f8e:	00 
  800f8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa5:	e8 92 fd ff ff       	call   800d3c <syscall>
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800fb2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb9:	00 
  800fba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc9:	00 
  800fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fcd:	89 04 24             	mov    %eax,(%esp)
  800fd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd8:	b8 04 00 00 00       	mov    $0x4,%eax
  800fdd:	e8 5a fd ff ff       	call   800d3c <syscall>
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801001:	00 
  801002:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801009:	b9 00 00 00 00       	mov    $0x0,%ecx
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 02 00 00 00       	mov    $0x2,%eax
  801018:	e8 1f fd ff ff       	call   800d3c <syscall>
}
  80101d:	c9                   	leave  
  80101e:	c3                   	ret    

0080101f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801025:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80102c:	00 
  80102d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801034:	00 
  801035:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103c:	00 
  80103d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801044:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801047:	ba 01 00 00 00       	mov    $0x1,%edx
  80104c:	b8 03 00 00 00       	mov    $0x3,%eax
  801051:	e8 e6 fc ff ff       	call   800d3c <syscall>
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80105e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801065:	00 
  801066:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106d:	00 
  80106e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801075:	00 
  801076:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801082:	ba 00 00 00 00       	mov    $0x0,%edx
  801087:	b8 01 00 00 00       	mov    $0x1,%eax
  80108c:	e8 ab fc ff ff       	call   800d3c <syscall>
}
  801091:	c9                   	leave  
  801092:	c3                   	ret    

00801093 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801093:	55                   	push   %ebp
  801094:	89 e5                	mov    %esp,%ebp
  801096:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801099:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b0:	00 
  8010b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b4:	89 04 24             	mov    %eax,(%esp)
  8010b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c4:	e8 73 fc ff ff       	call   800d3c <syscall>
}
  8010c9:	c9                   	leave  
  8010ca:	c3                   	ret    
	...

008010cc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010d2:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8010d9:	75 54                	jne    80112f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8010db:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010e2:	00 
  8010e3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010ea:	ee 
  8010eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010f2:	e8 43 fe ff ff       	call   800f3a <sys_page_alloc>
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	79 20                	jns    80111b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8010fb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010ff:	c7 44 24 08 6b 22 80 	movl   $0x80226b,0x8(%esp)
  801106:	00 
  801107:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80110e:	00 
  80110f:	c7 04 24 83 22 80 00 	movl   $0x802283,(%esp)
  801116:	e8 35 f0 ff ff       	call   800150 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80111b:	c7 44 24 04 3c 11 80 	movl   $0x80113c,0x4(%esp)
  801122:	00 
  801123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112a:	e8 f2 fc ff ff       	call   800e21 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80112f:	8b 45 08             	mov    0x8(%ebp),%eax
  801132:	a3 08 40 80 00       	mov    %eax,0x804008
}
  801137:	c9                   	leave  
  801138:	c3                   	ret    
  801139:	00 00                	add    %al,(%eax)
	...

0080113c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80113c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80113d:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801142:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801144:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  801147:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80114b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80114e:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  801152:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801156:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  801158:	83 c4 08             	add    $0x8,%esp
	popal
  80115b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  80115c:	83 c4 04             	add    $0x4,%esp
	popfl
  80115f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801160:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801161:	c3                   	ret    
	...

00801170 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
  80117b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80117e:	5d                   	pop    %ebp
  80117f:	c3                   	ret    

00801180 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801186:	8b 45 08             	mov    0x8(%ebp),%eax
  801189:	89 04 24             	mov    %eax,(%esp)
  80118c:	e8 df ff ff ff       	call   801170 <fd2num>
  801191:	05 20 00 0d 00       	add    $0xd0020,%eax
  801196:	c1 e0 0c             	shl    $0xc,%eax
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011a4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011a9:	a8 01                	test   $0x1,%al
  8011ab:	74 36                	je     8011e3 <fd_alloc+0x48>
  8011ad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011b2:	a8 01                	test   $0x1,%al
  8011b4:	74 2d                	je     8011e3 <fd_alloc+0x48>
  8011b6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011bb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8011c0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8011c5:	89 c3                	mov    %eax,%ebx
  8011c7:	89 c2                	mov    %eax,%edx
  8011c9:	c1 ea 16             	shr    $0x16,%edx
  8011cc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8011cf:	f6 c2 01             	test   $0x1,%dl
  8011d2:	74 14                	je     8011e8 <fd_alloc+0x4d>
  8011d4:	89 c2                	mov    %eax,%edx
  8011d6:	c1 ea 0c             	shr    $0xc,%edx
  8011d9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8011dc:	f6 c2 01             	test   $0x1,%dl
  8011df:	75 10                	jne    8011f1 <fd_alloc+0x56>
  8011e1:	eb 05                	jmp    8011e8 <fd_alloc+0x4d>
  8011e3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8011e8:	89 1f                	mov    %ebx,(%edi)
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8011ef:	eb 17                	jmp    801208 <fd_alloc+0x6d>
  8011f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011fb:	75 c8                	jne    8011c5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801203:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801210:	8b 45 08             	mov    0x8(%ebp),%eax
  801213:	83 f8 1f             	cmp    $0x1f,%eax
  801216:	77 36                	ja     80124e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801218:	05 00 00 0d 00       	add    $0xd0000,%eax
  80121d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801220:	89 c2                	mov    %eax,%edx
  801222:	c1 ea 16             	shr    $0x16,%edx
  801225:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80122c:	f6 c2 01             	test   $0x1,%dl
  80122f:	74 1d                	je     80124e <fd_lookup+0x41>
  801231:	89 c2                	mov    %eax,%edx
  801233:	c1 ea 0c             	shr    $0xc,%edx
  801236:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80123d:	f6 c2 01             	test   $0x1,%dl
  801240:	74 0c                	je     80124e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801242:	8b 55 0c             	mov    0xc(%ebp),%edx
  801245:	89 02                	mov    %eax,(%edx)
  801247:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80124c:	eb 05                	jmp    801253 <fd_lookup+0x46>
  80124e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801253:	5d                   	pop    %ebp
  801254:	c3                   	ret    

00801255 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80125b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80125e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801262:	8b 45 08             	mov    0x8(%ebp),%eax
  801265:	89 04 24             	mov    %eax,(%esp)
  801268:	e8 a0 ff ff ff       	call   80120d <fd_lookup>
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 0e                	js     80127f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801271:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801274:	8b 55 0c             	mov    0xc(%ebp),%edx
  801277:	89 50 04             	mov    %edx,0x4(%eax)
  80127a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	83 ec 10             	sub    $0x10,%esp
  801289:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80128c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80128f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801294:	b8 04 30 80 00       	mov    $0x803004,%eax
  801299:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80129f:	75 11                	jne    8012b2 <dev_lookup+0x31>
  8012a1:	eb 04                	jmp    8012a7 <dev_lookup+0x26>
  8012a3:	39 08                	cmp    %ecx,(%eax)
  8012a5:	75 10                	jne    8012b7 <dev_lookup+0x36>
			*dev = devtab[i];
  8012a7:	89 03                	mov    %eax,(%ebx)
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8012ae:	66 90                	xchg   %ax,%ax
  8012b0:	eb 36                	jmp    8012e8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b2:	be 14 23 80 00       	mov    $0x802314,%esi
  8012b7:	83 c2 01             	add    $0x1,%edx
  8012ba:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	75 e2                	jne    8012a3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012c6:	8b 40 48             	mov    0x48(%eax),%eax
  8012c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	c7 04 24 94 22 80 00 	movl   $0x802294,(%esp)
  8012d8:	e8 2c ef ff ff       	call   800209 <cprintf>
	*dev = 0;
  8012dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	5b                   	pop    %ebx
  8012ec:	5e                   	pop    %esi
  8012ed:	5d                   	pop    %ebp
  8012ee:	c3                   	ret    

008012ef <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8012ef:	55                   	push   %ebp
  8012f0:	89 e5                	mov    %esp,%ebp
  8012f2:	53                   	push   %ebx
  8012f3:	83 ec 24             	sub    $0x24,%esp
  8012f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 02 ff ff ff       	call   80120d <fd_lookup>
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 53                	js     801362 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801312:	89 44 24 04          	mov    %eax,0x4(%esp)
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	8b 00                	mov    (%eax),%eax
  80131b:	89 04 24             	mov    %eax,(%esp)
  80131e:	e8 5e ff ff ff       	call   801281 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801323:	85 c0                	test   %eax,%eax
  801325:	78 3b                	js     801362 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801327:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80132c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80132f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801333:	74 2d                	je     801362 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801335:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801338:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133f:	00 00 00 
	stat->st_isdir = 0;
  801342:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801349:	00 00 00 
	stat->st_dev = dev;
  80134c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801355:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801359:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80135c:	89 14 24             	mov    %edx,(%esp)
  80135f:	ff 50 14             	call   *0x14(%eax)
}
  801362:	83 c4 24             	add    $0x24,%esp
  801365:	5b                   	pop    %ebx
  801366:	5d                   	pop    %ebp
  801367:	c3                   	ret    

00801368 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
  80136b:	53                   	push   %ebx
  80136c:	83 ec 24             	sub    $0x24,%esp
  80136f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801372:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801375:	89 44 24 04          	mov    %eax,0x4(%esp)
  801379:	89 1c 24             	mov    %ebx,(%esp)
  80137c:	e8 8c fe ff ff       	call   80120d <fd_lookup>
  801381:	85 c0                	test   %eax,%eax
  801383:	78 5f                	js     8013e4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801385:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801388:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138f:	8b 00                	mov    (%eax),%eax
  801391:	89 04 24             	mov    %eax,(%esp)
  801394:	e8 e8 fe ff ff       	call   801281 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 47                	js     8013e4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80139d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013a0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8013a4:	75 23                	jne    8013c9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013a6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ab:	8b 40 48             	mov    0x48(%eax),%eax
  8013ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	c7 04 24 b4 22 80 00 	movl   $0x8022b4,(%esp)
  8013bd:	e8 47 ee ff ff       	call   800209 <cprintf>
  8013c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013c7:	eb 1b                	jmp    8013e4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8013c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cc:	8b 48 18             	mov    0x18(%eax),%ecx
  8013cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d4:	85 c9                	test   %ecx,%ecx
  8013d6:	74 0c                	je     8013e4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013df:	89 14 24             	mov    %edx,(%esp)
  8013e2:	ff d1                	call   *%ecx
}
  8013e4:	83 c4 24             	add    $0x24,%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5d                   	pop    %ebp
  8013e9:	c3                   	ret    

008013ea <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	53                   	push   %ebx
  8013ee:	83 ec 24             	sub    $0x24,%esp
  8013f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013fb:	89 1c 24             	mov    %ebx,(%esp)
  8013fe:	e8 0a fe ff ff       	call   80120d <fd_lookup>
  801403:	85 c0                	test   %eax,%eax
  801405:	78 66                	js     80146d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801411:	8b 00                	mov    (%eax),%eax
  801413:	89 04 24             	mov    %eax,(%esp)
  801416:	e8 66 fe ff ff       	call   801281 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 4e                	js     80146d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801422:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801426:	75 23                	jne    80144b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801428:	a1 04 40 80 00       	mov    0x804004,%eax
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	c7 04 24 d8 22 80 00 	movl   $0x8022d8,(%esp)
  80143f:	e8 c5 ed ff ff       	call   800209 <cprintf>
  801444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801449:	eb 22                	jmp    80146d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801451:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801456:	85 c9                	test   %ecx,%ecx
  801458:	74 13                	je     80146d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80145a:	8b 45 10             	mov    0x10(%ebp),%eax
  80145d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801461:	8b 45 0c             	mov    0xc(%ebp),%eax
  801464:	89 44 24 04          	mov    %eax,0x4(%esp)
  801468:	89 14 24             	mov    %edx,(%esp)
  80146b:	ff d1                	call   *%ecx
}
  80146d:	83 c4 24             	add    $0x24,%esp
  801470:	5b                   	pop    %ebx
  801471:	5d                   	pop    %ebp
  801472:	c3                   	ret    

00801473 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	53                   	push   %ebx
  801477:	83 ec 24             	sub    $0x24,%esp
  80147a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801480:	89 44 24 04          	mov    %eax,0x4(%esp)
  801484:	89 1c 24             	mov    %ebx,(%esp)
  801487:	e8 81 fd ff ff       	call   80120d <fd_lookup>
  80148c:	85 c0                	test   %eax,%eax
  80148e:	78 6b                	js     8014fb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801490:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801493:	89 44 24 04          	mov    %eax,0x4(%esp)
  801497:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149a:	8b 00                	mov    (%eax),%eax
  80149c:	89 04 24             	mov    %eax,(%esp)
  80149f:	e8 dd fd ff ff       	call   801281 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 53                	js     8014fb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014ab:	8b 42 08             	mov    0x8(%edx),%eax
  8014ae:	83 e0 03             	and    $0x3,%eax
  8014b1:	83 f8 01             	cmp    $0x1,%eax
  8014b4:	75 23                	jne    8014d9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014bb:	8b 40 48             	mov    0x48(%eax),%eax
  8014be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c6:	c7 04 24 f5 22 80 00 	movl   $0x8022f5,(%esp)
  8014cd:	e8 37 ed ff ff       	call   800209 <cprintf>
  8014d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014d7:	eb 22                	jmp    8014fb <read+0x88>
	}
	if (!dev->dev_read)
  8014d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014dc:	8b 48 08             	mov    0x8(%eax),%ecx
  8014df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014e4:	85 c9                	test   %ecx,%ecx
  8014e6:	74 13                	je     8014fb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8014eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f6:	89 14 24             	mov    %edx,(%esp)
  8014f9:	ff d1                	call   *%ecx
}
  8014fb:	83 c4 24             	add    $0x24,%esp
  8014fe:	5b                   	pop    %ebx
  8014ff:	5d                   	pop    %ebp
  801500:	c3                   	ret    

00801501 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801501:	55                   	push   %ebp
  801502:	89 e5                	mov    %esp,%ebp
  801504:	57                   	push   %edi
  801505:	56                   	push   %esi
  801506:	53                   	push   %ebx
  801507:	83 ec 1c             	sub    $0x1c,%esp
  80150a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80150d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801510:	ba 00 00 00 00       	mov    $0x0,%edx
  801515:	bb 00 00 00 00       	mov    $0x0,%ebx
  80151a:	b8 00 00 00 00       	mov    $0x0,%eax
  80151f:	85 f6                	test   %esi,%esi
  801521:	74 29                	je     80154c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801523:	89 f0                	mov    %esi,%eax
  801525:	29 d0                	sub    %edx,%eax
  801527:	89 44 24 08          	mov    %eax,0x8(%esp)
  80152b:	03 55 0c             	add    0xc(%ebp),%edx
  80152e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801532:	89 3c 24             	mov    %edi,(%esp)
  801535:	e8 39 ff ff ff       	call   801473 <read>
		if (m < 0)
  80153a:	85 c0                	test   %eax,%eax
  80153c:	78 0e                	js     80154c <readn+0x4b>
			return m;
		if (m == 0)
  80153e:	85 c0                	test   %eax,%eax
  801540:	74 08                	je     80154a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801542:	01 c3                	add    %eax,%ebx
  801544:	89 da                	mov    %ebx,%edx
  801546:	39 f3                	cmp    %esi,%ebx
  801548:	72 d9                	jb     801523 <readn+0x22>
  80154a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80154c:	83 c4 1c             	add    $0x1c,%esp
  80154f:	5b                   	pop    %ebx
  801550:	5e                   	pop    %esi
  801551:	5f                   	pop    %edi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    

00801554 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	83 ec 28             	sub    $0x28,%esp
  80155a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80155d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801560:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801563:	89 34 24             	mov    %esi,(%esp)
  801566:	e8 05 fc ff ff       	call   801170 <fd2num>
  80156b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80156e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801572:	89 04 24             	mov    %eax,(%esp)
  801575:	e8 93 fc ff ff       	call   80120d <fd_lookup>
  80157a:	89 c3                	mov    %eax,%ebx
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 05                	js     801585 <fd_close+0x31>
  801580:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801583:	74 0e                	je     801593 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801585:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801589:	b8 00 00 00 00       	mov    $0x0,%eax
  80158e:	0f 44 d8             	cmove  %eax,%ebx
  801591:	eb 3d                	jmp    8015d0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801593:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801596:	89 44 24 04          	mov    %eax,0x4(%esp)
  80159a:	8b 06                	mov    (%esi),%eax
  80159c:	89 04 24             	mov    %eax,(%esp)
  80159f:	e8 dd fc ff ff       	call   801281 <dev_lookup>
  8015a4:	89 c3                	mov    %eax,%ebx
  8015a6:	85 c0                	test   %eax,%eax
  8015a8:	78 16                	js     8015c0 <fd_close+0x6c>
		if (dev->dev_close)
  8015aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ad:	8b 40 10             	mov    0x10(%eax),%eax
  8015b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	74 07                	je     8015c0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8015b9:	89 34 24             	mov    %esi,(%esp)
  8015bc:	ff d0                	call   *%eax
  8015be:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015cb:	e8 f9 f8 ff ff       	call   800ec9 <sys_page_unmap>
	return r;
}
  8015d0:	89 d8                	mov    %ebx,%eax
  8015d2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015d5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015d8:	89 ec                	mov    %ebp,%esp
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    

008015dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ec:	89 04 24             	mov    %eax,(%esp)
  8015ef:	e8 19 fc ff ff       	call   80120d <fd_lookup>
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 13                	js     80160b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015ff:	00 
  801600:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801603:	89 04 24             	mov    %eax,(%esp)
  801606:	e8 49 ff ff ff       	call   801554 <fd_close>
}
  80160b:	c9                   	leave  
  80160c:	c3                   	ret    

0080160d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
  801610:	83 ec 18             	sub    $0x18,%esp
  801613:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801616:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801619:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801620:	00 
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	89 04 24             	mov    %eax,(%esp)
  801627:	e8 78 03 00 00       	call   8019a4 <open>
  80162c:	89 c3                	mov    %eax,%ebx
  80162e:	85 c0                	test   %eax,%eax
  801630:	78 1b                	js     80164d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801632:	8b 45 0c             	mov    0xc(%ebp),%eax
  801635:	89 44 24 04          	mov    %eax,0x4(%esp)
  801639:	89 1c 24             	mov    %ebx,(%esp)
  80163c:	e8 ae fc ff ff       	call   8012ef <fstat>
  801641:	89 c6                	mov    %eax,%esi
	close(fd);
  801643:	89 1c 24             	mov    %ebx,(%esp)
  801646:	e8 91 ff ff ff       	call   8015dc <close>
  80164b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80164d:	89 d8                	mov    %ebx,%eax
  80164f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801652:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801655:	89 ec                	mov    %ebp,%esp
  801657:	5d                   	pop    %ebp
  801658:	c3                   	ret    

00801659 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	53                   	push   %ebx
  80165d:	83 ec 14             	sub    $0x14,%esp
  801660:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801665:	89 1c 24             	mov    %ebx,(%esp)
  801668:	e8 6f ff ff ff       	call   8015dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80166d:	83 c3 01             	add    $0x1,%ebx
  801670:	83 fb 20             	cmp    $0x20,%ebx
  801673:	75 f0                	jne    801665 <close_all+0xc>
		close(i);
}
  801675:	83 c4 14             	add    $0x14,%esp
  801678:	5b                   	pop    %ebx
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 58             	sub    $0x58,%esp
  801681:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801684:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801687:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80168a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80168d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801690:	89 44 24 04          	mov    %eax,0x4(%esp)
  801694:	8b 45 08             	mov    0x8(%ebp),%eax
  801697:	89 04 24             	mov    %eax,(%esp)
  80169a:	e8 6e fb ff ff       	call   80120d <fd_lookup>
  80169f:	89 c3                	mov    %eax,%ebx
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	0f 88 e0 00 00 00    	js     801789 <dup+0x10e>
		return r;
	close(newfdnum);
  8016a9:	89 3c 24             	mov    %edi,(%esp)
  8016ac:	e8 2b ff ff ff       	call   8015dc <close>

	newfd = INDEX2FD(newfdnum);
  8016b1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016b7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016bd:	89 04 24             	mov    %eax,(%esp)
  8016c0:	e8 bb fa ff ff       	call   801180 <fd2data>
  8016c5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016c7:	89 34 24             	mov    %esi,(%esp)
  8016ca:	e8 b1 fa ff ff       	call   801180 <fd2data>
  8016cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8016d2:	89 da                	mov    %ebx,%edx
  8016d4:	89 d8                	mov    %ebx,%eax
  8016d6:	c1 e8 16             	shr    $0x16,%eax
  8016d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016e0:	a8 01                	test   $0x1,%al
  8016e2:	74 43                	je     801727 <dup+0xac>
  8016e4:	c1 ea 0c             	shr    $0xc,%edx
  8016e7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016ee:	a8 01                	test   $0x1,%al
  8016f0:	74 35                	je     801727 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016f2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801702:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801705:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801709:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801710:	00 
  801711:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801715:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171c:	e8 e0 f7 ff ff       	call   800f01 <sys_page_map>
  801721:	89 c3                	mov    %eax,%ebx
  801723:	85 c0                	test   %eax,%eax
  801725:	78 3f                	js     801766 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801727:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	c1 ea 0c             	shr    $0xc,%edx
  80172f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801736:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80173c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801740:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801744:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80174b:	00 
  80174c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801757:	e8 a5 f7 ff ff       	call   800f01 <sys_page_map>
  80175c:	89 c3                	mov    %eax,%ebx
  80175e:	85 c0                	test   %eax,%eax
  801760:	78 04                	js     801766 <dup+0xeb>
  801762:	89 fb                	mov    %edi,%ebx
  801764:	eb 23                	jmp    801789 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801766:	89 74 24 04          	mov    %esi,0x4(%esp)
  80176a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801771:	e8 53 f7 ff ff       	call   800ec9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801776:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801784:	e8 40 f7 ff ff       	call   800ec9 <sys_page_unmap>
	return r;
}
  801789:	89 d8                	mov    %ebx,%eax
  80178b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80178e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801791:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801794:	89 ec                	mov    %ebp,%esp
  801796:	5d                   	pop    %ebp
  801797:	c3                   	ret    

00801798 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801798:	55                   	push   %ebp
  801799:	89 e5                	mov    %esp,%ebp
  80179b:	83 ec 18             	sub    $0x18,%esp
  80179e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017a4:	89 c3                	mov    %eax,%ebx
  8017a6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017a8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017af:	75 11                	jne    8017c2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017b1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8017b8:	e8 a3 02 00 00       	call   801a60 <ipc_find_env>
  8017bd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017c9:	00 
  8017ca:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017d1:	00 
  8017d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d6:	a1 00 40 80 00       	mov    0x804000,%eax
  8017db:	89 04 24             	mov    %eax,(%esp)
  8017de:	e8 c1 02 00 00       	call   801aa4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ea:	00 
  8017eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f6:	e8 18 03 00 00       	call   801b13 <ipc_recv>
}
  8017fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017fe:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801801:	89 ec                	mov    %ebp,%esp
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	8b 40 0c             	mov    0xc(%eax),%eax
  801811:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801816:	8b 45 0c             	mov    0xc(%ebp),%eax
  801819:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80181e:	ba 00 00 00 00       	mov    $0x0,%edx
  801823:	b8 02 00 00 00       	mov    $0x2,%eax
  801828:	e8 6b ff ff ff       	call   801798 <fsipc>
}
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801835:	8b 45 08             	mov    0x8(%ebp),%eax
  801838:	8b 40 0c             	mov    0xc(%eax),%eax
  80183b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801840:	ba 00 00 00 00       	mov    $0x0,%edx
  801845:	b8 06 00 00 00       	mov    $0x6,%eax
  80184a:	e8 49 ff ff ff       	call   801798 <fsipc>
}
  80184f:	c9                   	leave  
  801850:	c3                   	ret    

00801851 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801857:	ba 00 00 00 00       	mov    $0x0,%edx
  80185c:	b8 08 00 00 00       	mov    $0x8,%eax
  801861:	e8 32 ff ff ff       	call   801798 <fsipc>
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	53                   	push   %ebx
  80186c:	83 ec 14             	sub    $0x14,%esp
  80186f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801872:	8b 45 08             	mov    0x8(%ebp),%eax
  801875:	8b 40 0c             	mov    0xc(%eax),%eax
  801878:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 05 00 00 00       	mov    $0x5,%eax
  801887:	e8 0c ff ff ff       	call   801798 <fsipc>
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 2b                	js     8018bb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801890:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801897:	00 
  801898:	89 1c 24             	mov    %ebx,(%esp)
  80189b:	e8 aa f0 ff ff       	call   80094a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a0:	a1 80 50 80 00       	mov    0x805080,%eax
  8018a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ab:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8018b6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8018bb:	83 c4 14             	add    $0x14,%esp
  8018be:	5b                   	pop    %ebx
  8018bf:	5d                   	pop    %ebp
  8018c0:	c3                   	ret    

008018c1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	83 ec 18             	sub    $0x18,%esp
  8018c7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8018cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8018d0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  8018d6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  8018db:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e5:	0f 47 c2             	cmova  %edx,%eax
  8018e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8018fa:	e8 36 f2 ff ff       	call   800b35 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	b8 04 00 00 00       	mov    $0x4,%eax
  801909:	e8 8a fe ff ff       	call   801798 <fsipc>
}
  80190e:	c9                   	leave  
  80190f:	c3                   	ret    

00801910 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
  801913:	53                   	push   %ebx
  801914:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801917:	8b 45 08             	mov    0x8(%ebp),%eax
  80191a:	8b 40 0c             	mov    0xc(%eax),%eax
  80191d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801922:	8b 45 10             	mov    0x10(%ebp),%eax
  801925:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 03 00 00 00       	mov    $0x3,%eax
  801934:	e8 5f fe ff ff       	call   801798 <fsipc>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 17                	js     801956 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80193f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801943:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80194a:	00 
  80194b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 df f1 ff ff       	call   800b35 <memmove>
  return r;	
}
  801956:	89 d8                	mov    %ebx,%eax
  801958:	83 c4 14             	add    $0x14,%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5d                   	pop    %ebp
  80195d:	c3                   	ret    

0080195e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	53                   	push   %ebx
  801962:	83 ec 14             	sub    $0x14,%esp
  801965:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801968:	89 1c 24             	mov    %ebx,(%esp)
  80196b:	e8 90 ef ff ff       	call   800900 <strlen>
  801970:	89 c2                	mov    %eax,%edx
  801972:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801977:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80197d:	7f 1f                	jg     80199e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80197f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801983:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80198a:	e8 bb ef ff ff       	call   80094a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80198f:	ba 00 00 00 00       	mov    $0x0,%edx
  801994:	b8 07 00 00 00       	mov    $0x7,%eax
  801999:	e8 fa fd ff ff       	call   801798 <fsipc>
}
  80199e:	83 c4 14             	add    $0x14,%esp
  8019a1:	5b                   	pop    %ebx
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	83 ec 28             	sub    $0x28,%esp
  8019aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8019b0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8019b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b6:	89 04 24             	mov    %eax,(%esp)
  8019b9:	e8 dd f7 ff ff       	call   80119b <fd_alloc>
  8019be:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8019c0:	85 c0                	test   %eax,%eax
  8019c2:	0f 88 89 00 00 00    	js     801a51 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8019c8:	89 34 24             	mov    %esi,(%esp)
  8019cb:	e8 30 ef ff ff       	call   800900 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8019d0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8019d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019da:	7f 75                	jg     801a51 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8019dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019e7:	e8 5e ef ff ff       	call   80094a <strcpy>
  fsipcbuf.open.req_omode = mode;
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  8019f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019fc:	e8 97 fd ff ff       	call   801798 <fsipc>
  801a01:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 0f                	js     801a16 <open+0x72>
  return fd2num(fd);
  801a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0a:	89 04 24             	mov    %eax,(%esp)
  801a0d:	e8 5e f7 ff ff       	call   801170 <fd2num>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	eb 3b                	jmp    801a51 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801a16:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a1d:	00 
  801a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a21:	89 04 24             	mov    %eax,(%esp)
  801a24:	e8 2b fb ff ff       	call   801554 <fd_close>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	74 24                	je     801a51 <open+0xad>
  801a2d:	c7 44 24 0c 1c 23 80 	movl   $0x80231c,0xc(%esp)
  801a34:	00 
  801a35:	c7 44 24 08 31 23 80 	movl   $0x802331,0x8(%esp)
  801a3c:	00 
  801a3d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801a44:	00 
  801a45:	c7 04 24 46 23 80 00 	movl   $0x802346,(%esp)
  801a4c:	e8 ff e6 ff ff       	call   800150 <_panic>
  return r;
}
  801a51:	89 d8                	mov    %ebx,%eax
  801a53:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a56:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a59:	89 ec                	mov    %ebp,%esp
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    
  801a5d:	00 00                	add    %al,(%eax)
	...

00801a60 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a66:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801a6c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a71:	39 ca                	cmp    %ecx,%edx
  801a73:	75 04                	jne    801a79 <ipc_find_env+0x19>
  801a75:	b0 00                	mov    $0x0,%al
  801a77:	eb 0f                	jmp    801a88 <ipc_find_env+0x28>
  801a79:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a7c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801a82:	8b 12                	mov    (%edx),%edx
  801a84:	39 ca                	cmp    %ecx,%edx
  801a86:	75 0c                	jne    801a94 <ipc_find_env+0x34>
			return envs[i].env_id;
  801a88:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a8b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801a90:	8b 00                	mov    (%eax),%eax
  801a92:	eb 0e                	jmp    801aa2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a94:	83 c0 01             	add    $0x1,%eax
  801a97:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a9c:	75 db                	jne    801a79 <ipc_find_env+0x19>
  801a9e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801aa2:	5d                   	pop    %ebp
  801aa3:	c3                   	ret    

00801aa4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	57                   	push   %edi
  801aa8:	56                   	push   %esi
  801aa9:	53                   	push   %ebx
  801aaa:	83 ec 1c             	sub    $0x1c,%esp
  801aad:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ab3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801ab6:	85 db                	test   %ebx,%ebx
  801ab8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801abd:	0f 44 d8             	cmove  %eax,%ebx
  801ac0:	eb 29                	jmp    801aeb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801ac2:	85 c0                	test   %eax,%eax
  801ac4:	79 25                	jns    801aeb <ipc_send+0x47>
  801ac6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ac9:	74 20                	je     801aeb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801acb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801acf:	c7 44 24 08 51 23 80 	movl   $0x802351,0x8(%esp)
  801ad6:	00 
  801ad7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801ade:	00 
  801adf:	c7 04 24 6f 23 80 00 	movl   $0x80236f,(%esp)
  801ae6:	e8 65 e6 ff ff       	call   800150 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801aeb:	8b 45 14             	mov    0x14(%ebp),%eax
  801aee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801af2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801af6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801afa:	89 34 24             	mov    %esi,(%esp)
  801afd:	e8 e9 f2 ff ff       	call   800deb <sys_ipc_try_send>
  801b02:	85 c0                	test   %eax,%eax
  801b04:	75 bc                	jne    801ac2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801b06:	e8 66 f4 ff ff       	call   800f71 <sys_yield>
}
  801b0b:	83 c4 1c             	add    $0x1c,%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5f                   	pop    %edi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 28             	sub    $0x28,%esp
  801b19:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b1c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b1f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b22:	8b 75 08             	mov    0x8(%ebp),%esi
  801b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b28:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b32:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801b35:	89 04 24             	mov    %eax,(%esp)
  801b38:	e8 75 f2 ff ff       	call   800db2 <sys_ipc_recv>
  801b3d:	89 c3                	mov    %eax,%ebx
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	79 2a                	jns    801b6d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801b43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	c7 04 24 79 23 80 00 	movl   $0x802379,(%esp)
  801b52:	e8 b2 e6 ff ff       	call   800209 <cprintf>
		if(from_env_store != NULL)
  801b57:	85 f6                	test   %esi,%esi
  801b59:	74 06                	je     801b61 <ipc_recv+0x4e>
			*from_env_store = 0;
  801b5b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b61:	85 ff                	test   %edi,%edi
  801b63:	74 2d                	je     801b92 <ipc_recv+0x7f>
			*perm_store = 0;
  801b65:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b6b:	eb 25                	jmp    801b92 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801b6d:	85 f6                	test   %esi,%esi
  801b6f:	90                   	nop
  801b70:	74 0a                	je     801b7c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801b72:	a1 04 40 80 00       	mov    0x804004,%eax
  801b77:	8b 40 74             	mov    0x74(%eax),%eax
  801b7a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b7c:	85 ff                	test   %edi,%edi
  801b7e:	74 0a                	je     801b8a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801b80:	a1 04 40 80 00       	mov    0x804004,%eax
  801b85:	8b 40 78             	mov    0x78(%eax),%eax
  801b88:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801b92:	89 d8                	mov    %ebx,%eax
  801b94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b9d:	89 ec                	mov    %ebp,%esp
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
	...

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	83 ec 10             	sub    $0x10,%esp
  801bb8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  801bbe:	8b 75 10             	mov    0x10(%ebp),%esi
  801bc1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801bc9:	75 35                	jne    801c00 <__udivdi3+0x50>
  801bcb:	39 fe                	cmp    %edi,%esi
  801bcd:	77 61                	ja     801c30 <__udivdi3+0x80>
  801bcf:	85 f6                	test   %esi,%esi
  801bd1:	75 0b                	jne    801bde <__udivdi3+0x2e>
  801bd3:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd8:	31 d2                	xor    %edx,%edx
  801bda:	f7 f6                	div    %esi
  801bdc:	89 c6                	mov    %eax,%esi
  801bde:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801be1:	31 d2                	xor    %edx,%edx
  801be3:	89 f8                	mov    %edi,%eax
  801be5:	f7 f6                	div    %esi
  801be7:	89 c7                	mov    %eax,%edi
  801be9:	89 c8                	mov    %ecx,%eax
  801beb:	f7 f6                	div    %esi
  801bed:	89 c1                	mov    %eax,%ecx
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	89 c8                	mov    %ecx,%eax
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	5e                   	pop    %esi
  801bf7:	5f                   	pop    %edi
  801bf8:	5d                   	pop    %ebp
  801bf9:	c3                   	ret    
  801bfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c00:	39 f8                	cmp    %edi,%eax
  801c02:	77 1c                	ja     801c20 <__udivdi3+0x70>
  801c04:	0f bd d0             	bsr    %eax,%edx
  801c07:	83 f2 1f             	xor    $0x1f,%edx
  801c0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c0d:	75 39                	jne    801c48 <__udivdi3+0x98>
  801c0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801c12:	0f 86 a0 00 00 00    	jbe    801cb8 <__udivdi3+0x108>
  801c18:	39 f8                	cmp    %edi,%eax
  801c1a:	0f 82 98 00 00 00    	jb     801cb8 <__udivdi3+0x108>
  801c20:	31 ff                	xor    %edi,%edi
  801c22:	31 c9                	xor    %ecx,%ecx
  801c24:	89 c8                	mov    %ecx,%eax
  801c26:	89 fa                	mov    %edi,%edx
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	5e                   	pop    %esi
  801c2c:	5f                   	pop    %edi
  801c2d:	5d                   	pop    %ebp
  801c2e:	c3                   	ret    
  801c2f:	90                   	nop
  801c30:	89 d1                	mov    %edx,%ecx
  801c32:	89 fa                	mov    %edi,%edx
  801c34:	89 c8                	mov    %ecx,%eax
  801c36:	31 ff                	xor    %edi,%edi
  801c38:	f7 f6                	div    %esi
  801c3a:	89 c1                	mov    %eax,%ecx
  801c3c:	89 fa                	mov    %edi,%edx
  801c3e:	89 c8                	mov    %ecx,%eax
  801c40:	83 c4 10             	add    $0x10,%esp
  801c43:	5e                   	pop    %esi
  801c44:	5f                   	pop    %edi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    
  801c47:	90                   	nop
  801c48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c4c:	89 f2                	mov    %esi,%edx
  801c4e:	d3 e0                	shl    %cl,%eax
  801c50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c53:	b8 20 00 00 00       	mov    $0x20,%eax
  801c58:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801c5b:	89 c1                	mov    %eax,%ecx
  801c5d:	d3 ea                	shr    %cl,%edx
  801c5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c63:	0b 55 ec             	or     -0x14(%ebp),%edx
  801c66:	d3 e6                	shl    %cl,%esi
  801c68:	89 c1                	mov    %eax,%ecx
  801c6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801c6d:	89 fe                	mov    %edi,%esi
  801c6f:	d3 ee                	shr    %cl,%esi
  801c71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c75:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c7b:	d3 e7                	shl    %cl,%edi
  801c7d:	89 c1                	mov    %eax,%ecx
  801c7f:	d3 ea                	shr    %cl,%edx
  801c81:	09 d7                	or     %edx,%edi
  801c83:	89 f2                	mov    %esi,%edx
  801c85:	89 f8                	mov    %edi,%eax
  801c87:	f7 75 ec             	divl   -0x14(%ebp)
  801c8a:	89 d6                	mov    %edx,%esi
  801c8c:	89 c7                	mov    %eax,%edi
  801c8e:	f7 65 e8             	mull   -0x18(%ebp)
  801c91:	39 d6                	cmp    %edx,%esi
  801c93:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c96:	72 30                	jb     801cc8 <__udivdi3+0x118>
  801c98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c9f:	d3 e2                	shl    %cl,%edx
  801ca1:	39 c2                	cmp    %eax,%edx
  801ca3:	73 05                	jae    801caa <__udivdi3+0xfa>
  801ca5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801ca8:	74 1e                	je     801cc8 <__udivdi3+0x118>
  801caa:	89 f9                	mov    %edi,%ecx
  801cac:	31 ff                	xor    %edi,%edi
  801cae:	e9 71 ff ff ff       	jmp    801c24 <__udivdi3+0x74>
  801cb3:	90                   	nop
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	31 ff                	xor    %edi,%edi
  801cba:	b9 01 00 00 00       	mov    $0x1,%ecx
  801cbf:	e9 60 ff ff ff       	jmp    801c24 <__udivdi3+0x74>
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801ccb:	31 ff                	xor    %edi,%edi
  801ccd:	89 c8                	mov    %ecx,%eax
  801ccf:	89 fa                	mov    %edi,%edx
  801cd1:	83 c4 10             	add    $0x10,%esp
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
	...

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	83 ec 20             	sub    $0x20,%esp
  801ce8:	8b 55 14             	mov    0x14(%ebp),%edx
  801ceb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cee:	8b 7d 10             	mov    0x10(%ebp),%edi
  801cf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801cf4:	85 d2                	test   %edx,%edx
  801cf6:	89 c8                	mov    %ecx,%eax
  801cf8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cfb:	75 13                	jne    801d10 <__umoddi3+0x30>
  801cfd:	39 f7                	cmp    %esi,%edi
  801cff:	76 3f                	jbe    801d40 <__umoddi3+0x60>
  801d01:	89 f2                	mov    %esi,%edx
  801d03:	f7 f7                	div    %edi
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	31 d2                	xor    %edx,%edx
  801d09:	83 c4 20             	add    $0x20,%esp
  801d0c:	5e                   	pop    %esi
  801d0d:	5f                   	pop    %edi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    
  801d10:	39 f2                	cmp    %esi,%edx
  801d12:	77 4c                	ja     801d60 <__umoddi3+0x80>
  801d14:	0f bd ca             	bsr    %edx,%ecx
  801d17:	83 f1 1f             	xor    $0x1f,%ecx
  801d1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d1d:	75 51                	jne    801d70 <__umoddi3+0x90>
  801d1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801d22:	0f 87 e0 00 00 00    	ja     801e08 <__umoddi3+0x128>
  801d28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d2b:	29 f8                	sub    %edi,%eax
  801d2d:	19 d6                	sbb    %edx,%esi
  801d2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d35:	89 f2                	mov    %esi,%edx
  801d37:	83 c4 20             	add    $0x20,%esp
  801d3a:	5e                   	pop    %esi
  801d3b:	5f                   	pop    %edi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    
  801d3e:	66 90                	xchg   %ax,%ax
  801d40:	85 ff                	test   %edi,%edi
  801d42:	75 0b                	jne    801d4f <__umoddi3+0x6f>
  801d44:	b8 01 00 00 00       	mov    $0x1,%eax
  801d49:	31 d2                	xor    %edx,%edx
  801d4b:	f7 f7                	div    %edi
  801d4d:	89 c7                	mov    %eax,%edi
  801d4f:	89 f0                	mov    %esi,%eax
  801d51:	31 d2                	xor    %edx,%edx
  801d53:	f7 f7                	div    %edi
  801d55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d58:	f7 f7                	div    %edi
  801d5a:	eb a9                	jmp    801d05 <__umoddi3+0x25>
  801d5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 20             	add    $0x20,%esp
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    
  801d6b:	90                   	nop
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d74:	d3 e2                	shl    %cl,%edx
  801d76:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d79:	ba 20 00 00 00       	mov    $0x20,%edx
  801d7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801d81:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d88:	89 fa                	mov    %edi,%edx
  801d8a:	d3 ea                	shr    %cl,%edx
  801d8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d90:	0b 55 f4             	or     -0xc(%ebp),%edx
  801d93:	d3 e7                	shl    %cl,%edi
  801d95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d99:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d9c:	89 f2                	mov    %esi,%edx
  801d9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801da1:	89 c7                	mov    %eax,%edi
  801da3:	d3 ea                	shr    %cl,%edx
  801da5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801da9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801dac:	89 c2                	mov    %eax,%edx
  801dae:	d3 e6                	shl    %cl,%esi
  801db0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801db4:	d3 ea                	shr    %cl,%edx
  801db6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801dba:	09 d6                	or     %edx,%esi
  801dbc:	89 f0                	mov    %esi,%eax
  801dbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801dc1:	d3 e7                	shl    %cl,%edi
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	f7 75 f4             	divl   -0xc(%ebp)
  801dc8:	89 d6                	mov    %edx,%esi
  801dca:	f7 65 e8             	mull   -0x18(%ebp)
  801dcd:	39 d6                	cmp    %edx,%esi
  801dcf:	72 2b                	jb     801dfc <__umoddi3+0x11c>
  801dd1:	39 c7                	cmp    %eax,%edi
  801dd3:	72 23                	jb     801df8 <__umoddi3+0x118>
  801dd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801dd9:	29 c7                	sub    %eax,%edi
  801ddb:	19 d6                	sbb    %edx,%esi
  801ddd:	89 f0                	mov    %esi,%eax
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	d3 ef                	shr    %cl,%edi
  801de3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ded:	09 f8                	or     %edi,%eax
  801def:	d3 ea                	shr    %cl,%edx
  801df1:	83 c4 20             	add    $0x20,%esp
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    
  801df8:	39 d6                	cmp    %edx,%esi
  801dfa:	75 d9                	jne    801dd5 <__umoddi3+0xf5>
  801dfc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801dff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801e02:	eb d1                	jmp    801dd5 <__umoddi3+0xf5>
  801e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	0f 82 18 ff ff ff    	jb     801d28 <__umoddi3+0x48>
  801e10:	e9 1d ff ff ff       	jmp    801d32 <__umoddi3+0x52>
