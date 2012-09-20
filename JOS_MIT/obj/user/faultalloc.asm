
obj/user/faultalloc.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
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
  80003a:	c7 04 24 70 00 80 00 	movl   $0x800070,(%esp)
  800041:	e8 0a 11 00 00       	call   801150 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  800046:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80004d:	de 
  80004e:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  800055:	e8 c3 01 00 00       	call   80021d <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  80005a:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  800061:	ca 
  800062:	c7 04 24 00 24 80 00 	movl   $0x802400,(%esp)
  800069:	e8 af 01 00 00       	call   80021d <cprintf>
}
  80006e:	c9                   	leave  
  80006f:	c3                   	ret    

00800070 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800070:	55                   	push   %ebp
  800071:	89 e5                	mov    %esp,%ebp
  800073:	53                   	push   %ebx
  800074:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800077:	8b 45 08             	mov    0x8(%ebp),%eax
  80007a:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80007c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800080:	c7 04 24 04 24 80 00 	movl   $0x802404,(%esp)
  800087:	e8 91 01 00 00       	call   80021d <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	89 d8                	mov    %ebx,%eax
  800096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 12 0f 00 00       	call   800fbd <sys_page_alloc>
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 24                	jns    8000d3 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  8000af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b7:	c7 44 24 08 20 24 80 	movl   $0x802420,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 0e 24 80 00 	movl   $0x80240e,(%esp)
  8000ce:	e8 91 00 00 00       	call   800164 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d7:	c7 44 24 08 4c 24 80 	movl   $0x80244c,0x8(%esp)
  8000de:	00 
  8000df:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000e6:	00 
  8000e7:	89 1c 24             	mov    %ebx,(%esp)
  8000ea:	e8 c9 07 00 00       	call   8008b8 <snprintf>
}
  8000ef:	83 c4 24             	add    $0x24,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5d                   	pop    %ebp
  8000f4:	c3                   	ret    
  8000f5:	00 00                	add    %al,(%eax)
	...

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	83 ec 18             	sub    $0x18,%esp
  8000fe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800101:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800104:	8b 75 08             	mov    0x8(%ebp),%esi
  800107:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80010a:	e8 58 0f 00 00       	call   801067 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	c1 e0 07             	shl    $0x7,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800121:	85 f6                	test   %esi,%esi
  800123:	7e 07                	jle    80012c <libmain+0x34>
		binaryname = argv[0];
  800125:	8b 03                	mov    (%ebx),%eax
  800127:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800130:	89 34 24             	mov    %esi,(%esp)
  800133:	e8 fc fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800138:	e8 0b 00 00 00       	call   800148 <exit>
}
  80013d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800140:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800143:	89 ec                	mov    %ebp,%esp
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    
	...

00800148 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80014e:	e8 86 15 00 00       	call   8016d9 <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 43 0f 00 00       	call   8010a2 <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    
  800161:	00 00                	add    %al,(%eax)
	...

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80016c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800175:	e8 ed 0e 00 00       	call   801067 <sys_getenvid>
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800188:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800190:	c7 04 24 78 24 80 00 	movl   $0x802478,(%esp)
  800197:	e8 81 00 00 00       	call   80021d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a3:	89 04 24             	mov    %eax,(%esp)
  8001a6:	e8 11 00 00 00       	call   8001bc <vcprintf>
	cprintf("\n");
  8001ab:	c7 04 24 ef 28 80 00 	movl   $0x8028ef,(%esp)
  8001b2:	e8 66 00 00 00       	call   80021d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x53>
	...

008001bc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cc:	00 00 00 
	b.cnt = 0;
  8001cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f1:	c7 04 24 37 02 80 00 	movl   $0x800237,(%esp)
  8001f8:	e8 d0 01 00 00       	call   8003cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fd:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800203:	89 44 24 04          	mov    %eax,0x4(%esp)
  800207:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020d:	89 04 24             	mov    %eax,(%esp)
  800210:	e8 01 0f 00 00       	call   801116 <sys_cputs>

	return b.cnt;
}
  800215:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800223:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	89 04 24             	mov    %eax,(%esp)
  800230:	e8 87 ff ff ff       	call   8001bc <vcprintf>
	va_end(ap);

	return cnt;
}
  800235:	c9                   	leave  
  800236:	c3                   	ret    

00800237 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	53                   	push   %ebx
  80023b:	83 ec 14             	sub    $0x14,%esp
  80023e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800241:	8b 03                	mov    (%ebx),%eax
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80024a:	83 c0 01             	add    $0x1,%eax
  80024d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80024f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800254:	75 19                	jne    80026f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800256:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80025d:	00 
  80025e:	8d 43 08             	lea    0x8(%ebx),%eax
  800261:	89 04 24             	mov    %eax,(%esp)
  800264:	e8 ad 0e 00 00       	call   801116 <sys_cputs>
		b->idx = 0;
  800269:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80026f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800273:	83 c4 14             	add    $0x14,%esp
  800276:	5b                   	pop    %ebx
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    
  800279:	00 00                	add    %al,(%eax)
  80027b:	00 00                	add    %al,(%eax)
  80027d:	00 00                	add    %al,(%eax)
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ab:	39 d1                	cmp    %edx,%ecx
  8002ad:	72 15                	jb     8002c4 <printnum+0x44>
  8002af:	77 07                	ja     8002b8 <printnum+0x38>
  8002b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b4:	39 d0                	cmp    %edx,%eax
  8002b6:	76 0c                	jbe    8002c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	8d 76 00             	lea    0x0(%esi),%esi
  8002c0:	7f 61                	jg     800323 <printnum+0xa3>
  8002c2:	eb 70                	jmp    800334 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ef:	00 
  8002f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	e8 7e 1e 00 00       	call   802180 <__udivdi3>
  800302:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800305:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	89 54 24 04          	mov    %edx,0x4(%esp)
  800317:	89 f2                	mov    %esi,%edx
  800319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031c:	e8 5f ff ff ff       	call   800280 <printnum>
  800321:	eb 11                	jmp    800334 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	89 74 24 04          	mov    %esi,0x4(%esp)
  800327:	89 3c 24             	mov    %edi,(%esp)
  80032a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032d:	83 eb 01             	sub    $0x1,%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f ef                	jg     800323 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800334:	89 74 24 04          	mov    %esi,0x4(%esp)
  800338:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034a:	00 
  80034b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80034e:	89 14 24             	mov    %edx,(%esp)
  800351:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800354:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800358:	e8 53 1f 00 00       	call   8022b0 <__umoddi3>
  80035d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800361:	0f be 80 9b 24 80 00 	movsbl 0x80249b(%eax),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80036e:	83 c4 4c             	add    $0x4c,%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800379:	83 fa 01             	cmp    $0x1,%edx
  80037c:	7e 0e                	jle    80038c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	8d 4a 08             	lea    0x8(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 02                	mov    (%edx),%eax
  800387:	8b 52 04             	mov    0x4(%edx),%edx
  80038a:	eb 22                	jmp    8003ae <getuint+0x38>
	else if (lflag)
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 10                	je     8003a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 04             	lea    0x4(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
  80039e:	eb 0e                	jmp    8003ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bf:	73 0a                	jae    8003cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c4:	88 0a                	mov    %cl,(%edx)
  8003c6:	83 c2 01             	add    $0x1,%edx
  8003c9:	89 10                	mov    %edx,(%eax)
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 5c             	sub    $0x5c,%esp
  8003d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e6:	eb 11                	jmp    8003f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	0f 84 68 04 00 00    	je     800858 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8003f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f9:	0f b6 03             	movzbl (%ebx),%eax
  8003fc:	83 c3 01             	add    $0x1,%ebx
  8003ff:	83 f8 25             	cmp    $0x25,%eax
  800402:	75 e4                	jne    8003e8 <vprintfmt+0x1b>
  800404:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80040b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80041b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800422:	eb 06                	jmp    80042a <vprintfmt+0x5d>
  800424:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800428:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 13             	movzbl (%ebx),%edx
  80042d:	0f b6 c2             	movzbl %dl,%eax
  800430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800433:	8d 43 01             	lea    0x1(%ebx),%eax
  800436:	83 ea 23             	sub    $0x23,%edx
  800439:	80 fa 55             	cmp    $0x55,%dl
  80043c:	0f 87 f9 03 00 00    	ja     80083b <vprintfmt+0x46e>
  800442:	0f b6 d2             	movzbl %dl,%edx
  800445:	ff 24 95 80 26 80 00 	jmp    *0x802680(,%edx,4)
  80044c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800450:	eb d6                	jmp    800428 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800452:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800455:	83 ea 30             	sub    $0x30,%edx
  800458:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80045b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80045e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800461:	83 fb 09             	cmp    $0x9,%ebx
  800464:	77 54                	ja     8004ba <vprintfmt+0xed>
  800466:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800469:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80046f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800472:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800476:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800479:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80047c:	83 fb 09             	cmp    $0x9,%ebx
  80047f:	76 eb                	jbe    80046c <vprintfmt+0x9f>
  800481:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800484:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800487:	eb 31                	jmp    8004ba <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800489:	8b 55 14             	mov    0x14(%ebp),%edx
  80048c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80048f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800492:	8b 12                	mov    (%edx),%edx
  800494:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800497:	eb 21                	jmp    8004ba <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800499:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8004a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004a9:	e9 7a ff ff ff       	jmp    800428 <vprintfmt+0x5b>
  8004ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004b5:	e9 6e ff ff ff       	jmp    800428 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004be:	0f 89 64 ff ff ff    	jns    800428 <vprintfmt+0x5b>
  8004c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004ca:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004d0:	e9 53 ff ff ff       	jmp    800428 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004d8:	e9 4b ff ff ff       	jmp    800428 <vprintfmt+0x5b>
  8004dd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff d7                	call   *%edi
  8004f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004f7:	e9 fd fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 50 04             	lea    0x4(%eax),%edx
  800505:	89 55 14             	mov    %edx,0x14(%ebp)
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 c2                	mov    %eax,%edx
  80050c:	c1 fa 1f             	sar    $0x1f,%edx
  80050f:	31 d0                	xor    %edx,%eax
  800511:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800513:	83 f8 0f             	cmp    $0xf,%eax
  800516:	7f 0b                	jg     800523 <vprintfmt+0x156>
  800518:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  80051f:	85 d2                	test   %edx,%edx
  800521:	75 20                	jne    800543 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800527:	c7 44 24 08 ac 24 80 	movl   $0x8024ac,0x8(%esp)
  80052e:	00 
  80052f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800533:	89 3c 24             	mov    %edi,(%esp)
  800536:	e8 a5 03 00 00       	call   8008e0 <printfmt>
  80053b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053e:	e9 b6 fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800543:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800547:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  80054e:	00 
  80054f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800553:	89 3c 24             	mov    %edi,(%esp)
  800556:	e8 85 03 00 00       	call   8008e0 <printfmt>
  80055b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80055e:	e9 96 fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800563:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800566:	89 c3                	mov    %eax,%ebx
  800568:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80056b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057f:	85 c0                	test   %eax,%eax
  800581:	b8 b5 24 80 00       	mov    $0x8024b5,%eax
  800586:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80058d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800591:	7e 06                	jle    800599 <vprintfmt+0x1cc>
  800593:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800597:	75 13                	jne    8005ac <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800599:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059c:	0f be 02             	movsbl (%edx),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	0f 85 a2 00 00 00    	jne    800649 <vprintfmt+0x27c>
  8005a7:	e9 8f 00 00 00       	jmp    80063b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b3:	89 0c 24             	mov    %ecx,(%esp)
  8005b6:	e8 70 03 00 00       	call   80092b <strnlen>
  8005bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	7e d2                	jle    800599 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005c7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ce:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005d1:	89 d3                	mov    %edx,%ebx
  8005d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 eb 01             	sub    $0x1,%ebx
  8005e2:	85 db                	test   %ebx,%ebx
  8005e4:	7f ed                	jg     8005d3 <vprintfmt+0x206>
  8005e6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005e9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005f0:	eb a7                	jmp    800599 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f6:	74 1b                	je     800613 <vprintfmt+0x246>
  8005f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005fb:	83 fa 5e             	cmp    $0x5e,%edx
  8005fe:	76 13                	jbe    800613 <vprintfmt+0x246>
					putch('?', putdat);
  800600:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800603:	89 54 24 04          	mov    %edx,0x4(%esp)
  800607:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800611:	eb 0d                	jmp    800620 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800613:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800616:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800620:	83 ef 01             	sub    $0x1,%edi
  800623:	0f be 03             	movsbl (%ebx),%eax
  800626:	85 c0                	test   %eax,%eax
  800628:	74 05                	je     80062f <vprintfmt+0x262>
  80062a:	83 c3 01             	add    $0x1,%ebx
  80062d:	eb 31                	jmp    800660 <vprintfmt+0x293>
  80062f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800638:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80063f:	7f 36                	jg     800677 <vprintfmt+0x2aa>
  800641:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800644:	e9 b0 fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800649:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064c:	83 c2 01             	add    $0x1,%edx
  80064f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800652:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800655:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800658:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80065b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80065e:	89 d3                	mov    %edx,%ebx
  800660:	85 f6                	test   %esi,%esi
  800662:	78 8e                	js     8005f2 <vprintfmt+0x225>
  800664:	83 ee 01             	sub    $0x1,%esi
  800667:	79 89                	jns    8005f2 <vprintfmt+0x225>
  800669:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800672:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800675:	eb c4                	jmp    80063b <vprintfmt+0x26e>
  800677:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80067a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800681:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800688:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068a:	83 eb 01             	sub    $0x1,%ebx
  80068d:	85 db                	test   %ebx,%ebx
  80068f:	7f ec                	jg     80067d <vprintfmt+0x2b0>
  800691:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800694:	e9 60 fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800699:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069c:	83 f9 01             	cmp    $0x1,%ecx
  80069f:	7e 16                	jle    8006b7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 08             	lea    0x8(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8b 48 04             	mov    0x4(%eax),%ecx
  8006af:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006b2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b5:	eb 32                	jmp    8006e9 <vprintfmt+0x31c>
	else if (lflag)
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	74 18                	je     8006d3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	eb 16                	jmp    8006e9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e1:	89 c2                	mov    %eax,%edx
  8006e3:	c1 fa 1f             	sar    $0x1f,%edx
  8006e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006ef:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8006f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f8:	0f 89 8a 00 00 00    	jns    800788 <vprintfmt+0x3bb>
				putch('-', putdat);
  8006fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800702:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800709:	ff d7                	call   *%edi
				num = -(long long) num;
  80070b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80070e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800711:	f7 d8                	neg    %eax
  800713:	83 d2 00             	adc    $0x0,%edx
  800716:	f7 da                	neg    %edx
  800718:	eb 6e                	jmp    800788 <vprintfmt+0x3bb>
  80071a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071d:	89 ca                	mov    %ecx,%edx
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 4f fc ff ff       	call   800376 <getuint>
  800727:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80072c:	eb 5a                	jmp    800788 <vprintfmt+0x3bb>
  80072e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800731:	89 ca                	mov    %ecx,%edx
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 3b fc ff ff       	call   800376 <getuint>
  80073b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800740:	eb 46                	jmp    800788 <vprintfmt+0x3bb>
  800742:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800745:	89 74 24 04          	mov    %esi,0x4(%esp)
  800749:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800750:	ff d7                	call   *%edi
			putch('x', putdat);
  800752:	89 74 24 04          	mov    %esi,0x4(%esp)
  800756:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	ba 00 00 00 00       	mov    $0x0,%edx
  80076f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800774:	eb 12                	jmp    800788 <vprintfmt+0x3bb>
  800776:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800779:	89 ca                	mov    %ecx,%edx
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 f3 fb ff ff       	call   800376 <getuint>
  800783:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800788:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80078c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800790:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800793:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800797:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a2:	89 f2                	mov    %esi,%edx
  8007a4:	89 f8                	mov    %edi,%eax
  8007a6:	e8 d5 fa ff ff       	call   800280 <printnum>
  8007ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ae:	e9 46 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8007b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 50 04             	lea    0x4(%eax),%edx
  8007bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	75 24                	jne    8007e9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8007c5:	c7 44 24 0c d0 25 80 	movl   $0x8025d0,0xc(%esp)
  8007cc:	00 
  8007cd:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  8007d4:	00 
  8007d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d9:	89 3c 24             	mov    %edi,(%esp)
  8007dc:	e8 ff 00 00 00       	call   8008e0 <printfmt>
  8007e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007e4:	e9 10 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8007e9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8007ec:	7e 29                	jle    800817 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8007ee:	0f b6 16             	movzbl (%esi),%edx
  8007f1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8007f3:	c7 44 24 0c 08 26 80 	movl   $0x802608,0xc(%esp)
  8007fa:	00 
  8007fb:	c7 44 24 08 27 29 80 	movl   $0x802927,0x8(%esp)
  800802:	00 
  800803:	89 74 24 04          	mov    %esi,0x4(%esp)
  800807:	89 3c 24             	mov    %edi,(%esp)
  80080a:	e8 d1 00 00 00       	call   8008e0 <printfmt>
  80080f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800812:	e9 e2 fb ff ff       	jmp    8003f9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800817:	0f b6 16             	movzbl (%esi),%edx
  80081a:	88 10                	mov    %dl,(%eax)
  80081c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80081f:	e9 d5 fb ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800824:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800827:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082e:	89 14 24             	mov    %edx,(%esp)
  800831:	ff d7                	call   *%edi
  800833:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800836:	e9 be fb ff ff       	jmp    8003f9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800846:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800848:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80084b:	80 38 25             	cmpb   $0x25,(%eax)
  80084e:	0f 84 a5 fb ff ff    	je     8003f9 <vprintfmt+0x2c>
  800854:	89 c3                	mov    %eax,%ebx
  800856:	eb f0                	jmp    800848 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800858:	83 c4 5c             	add    $0x5c,%esp
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5f                   	pop    %edi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 28             	sub    $0x28,%esp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80086c:	85 c0                	test   %eax,%eax
  80086e:	74 04                	je     800874 <vsnprintf+0x14>
  800870:	85 d2                	test   %edx,%edx
  800872:	7f 07                	jg     80087b <vsnprintf+0x1b>
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800879:	eb 3b                	jmp    8008b6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80087e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800882:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800885:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088c:	8b 45 14             	mov    0x14(%ebp),%eax
  80088f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800893:	8b 45 10             	mov    0x10(%ebp),%eax
  800896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	c7 04 24 b0 03 80 00 	movl   $0x8003b0,(%esp)
  8008a8:	e8 20 fb ff ff       	call   8003cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008be:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 82 ff ff ff       	call   800860 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	89 04 24             	mov    %eax,(%esp)
  800901:	e8 c7 fa ff ff       	call   8003cd <vprintfmt>
	va_end(ap);
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    
	...

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	80 3a 00             	cmpb   $0x0,(%edx)
  80091e:	74 09                	je     800929 <strlen+0x19>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0x10>
		n++;
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 19                	je     800952 <strnlen+0x27>
  800939:	80 3b 00             	cmpb   $0x0,(%ebx)
  80093c:	74 14                	je     800952 <strnlen+0x27>
  80093e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800943:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800946:	39 c8                	cmp    %ecx,%eax
  800948:	74 0d                	je     800957 <strnlen+0x2c>
  80094a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80094e:	75 f3                	jne    800943 <strnlen+0x18>
  800950:	eb 05                	jmp    800957 <strnlen+0x2c>
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800969:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80096d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800970:	83 c2 01             	add    $0x1,%edx
  800973:	84 c9                	test   %cl,%cl
  800975:	75 f2                	jne    800969 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800984:	89 1c 24             	mov    %ebx,(%esp)
  800987:	e8 84 ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800993:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	e8 bc ff ff ff       	call   80095a <strcpy>
	return dst;
}
  80099e:	89 d8                	mov    %ebx,%eax
  8009a0:	83 c4 08             	add    $0x8,%esp
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b4:	85 f6                	test   %esi,%esi
  8009b6:	74 18                	je     8009d0 <strncpy+0x2a>
  8009b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	39 ce                	cmp    %ecx,%esi
  8009ce:	77 ed                	ja     8009bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e2:	89 f0                	mov    %esi,%eax
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	74 27                	je     800a0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009e8:	83 e9 01             	sub    $0x1,%ecx
  8009eb:	74 1d                	je     800a0a <strlcpy+0x36>
  8009ed:	0f b6 1a             	movzbl (%edx),%ebx
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	74 16                	je     800a0a <strlcpy+0x36>
			*dst++ = *src++;
  8009f4:	88 18                	mov    %bl,(%eax)
  8009f6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f9:	83 e9 01             	sub    $0x1,%ecx
  8009fc:	74 0e                	je     800a0c <strlcpy+0x38>
			*dst++ = *src++;
  8009fe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a01:	0f b6 1a             	movzbl (%edx),%ebx
  800a04:	84 db                	test   %bl,%bl
  800a06:	75 ec                	jne    8009f4 <strlcpy+0x20>
  800a08:	eb 02                	jmp    800a0c <strlcpy+0x38>
  800a0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a0c:	c6 00 00             	movb   $0x0,(%eax)
  800a0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1e:	0f b6 01             	movzbl (%ecx),%eax
  800a21:	84 c0                	test   %al,%al
  800a23:	74 15                	je     800a3a <strcmp+0x25>
  800a25:	3a 02                	cmp    (%edx),%al
  800a27:	75 11                	jne    800a3a <strcmp+0x25>
		p++, q++;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2f:	0f b6 01             	movzbl (%ecx),%eax
  800a32:	84 c0                	test   %al,%al
  800a34:	74 04                	je     800a3a <strcmp+0x25>
  800a36:	3a 02                	cmp    (%edx),%al
  800a38:	74 ef                	je     800a29 <strcmp+0x14>
  800a3a:	0f b6 c0             	movzbl %al,%eax
  800a3d:	0f b6 12             	movzbl (%edx),%edx
  800a40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a51:	85 c0                	test   %eax,%eax
  800a53:	74 23                	je     800a78 <strncmp+0x34>
  800a55:	0f b6 1a             	movzbl (%edx),%ebx
  800a58:	84 db                	test   %bl,%bl
  800a5a:	74 25                	je     800a81 <strncmp+0x3d>
  800a5c:	3a 19                	cmp    (%ecx),%bl
  800a5e:	75 21                	jne    800a81 <strncmp+0x3d>
  800a60:	83 e8 01             	sub    $0x1,%eax
  800a63:	74 13                	je     800a78 <strncmp+0x34>
		n--, p++, q++;
  800a65:	83 c2 01             	add    $0x1,%edx
  800a68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a6b:	0f b6 1a             	movzbl (%edx),%ebx
  800a6e:	84 db                	test   %bl,%bl
  800a70:	74 0f                	je     800a81 <strncmp+0x3d>
  800a72:	3a 19                	cmp    (%ecx),%bl
  800a74:	74 ea                	je     800a60 <strncmp+0x1c>
  800a76:	eb 09                	jmp    800a81 <strncmp+0x3d>
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	90                   	nop
  800a80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 02             	movzbl (%edx),%eax
  800a84:	0f b6 11             	movzbl (%ecx),%edx
  800a87:	29 d0                	sub    %edx,%eax
  800a89:	eb f2                	jmp    800a7d <strncmp+0x39>

00800a8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	74 18                	je     800ab4 <strchr+0x29>
		if (*s == c)
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	75 0a                	jne    800aaa <strchr+0x1f>
  800aa0:	eb 17                	jmp    800ab9 <strchr+0x2e>
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800aa8:	74 0f                	je     800ab9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 ee                	jne    800aa2 <strchr+0x17>
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac5:	0f b6 10             	movzbl (%eax),%edx
  800ac8:	84 d2                	test   %dl,%dl
  800aca:	74 18                	je     800ae4 <strfind+0x29>
		if (*s == c)
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	75 0a                	jne    800ada <strfind+0x1f>
  800ad0:	eb 12                	jmp    800ae4 <strfind+0x29>
  800ad2:	38 ca                	cmp    %cl,%dl
  800ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ad8:	74 0a                	je     800ae4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	0f b6 10             	movzbl (%eax),%edx
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	75 ee                	jne    800ad2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 0c             	sub    $0xc,%esp
  800aec:	89 1c 24             	mov    %ebx,(%esp)
  800aef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800af3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800af7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b00:	85 c9                	test   %ecx,%ecx
  800b02:	74 30                	je     800b34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0a:	75 25                	jne    800b31 <memset+0x4b>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 20                	jne    800b31 <memset+0x4b>
		c &= 0xFF;
  800b11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	c1 e3 08             	shl    $0x8,%ebx
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	c1 e6 18             	shl    $0x18,%esi
  800b1e:	89 d0                	mov    %edx,%eax
  800b20:	c1 e0 10             	shl    $0x10,%eax
  800b23:	09 f0                	or     %esi,%eax
  800b25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b27:	09 d8                	or     %ebx,%eax
  800b29:	c1 e9 02             	shr    $0x2,%ecx
  800b2c:	fc                   	cld    
  800b2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2f:	eb 03                	jmp    800b34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	8b 1c 24             	mov    (%esp),%ebx
  800b39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b41:	89 ec                	mov    %ebp,%esp
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	89 34 24             	mov    %esi,(%esp)
  800b4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	73 35                	jae    800b96 <memmove+0x51>
  800b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b64:	39 d0                	cmp    %edx,%eax
  800b66:	73 2e                	jae    800b96 <memmove+0x51>
		s += n;
		d += n;
  800b68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6a:	f6 c2 03             	test   $0x3,%dl
  800b6d:	75 1b                	jne    800b8a <memmove+0x45>
  800b6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b75:	75 13                	jne    800b8a <memmove+0x45>
  800b77:	f6 c1 03             	test   $0x3,%cl
  800b7a:	75 0e                	jne    800b8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b7c:	83 ef 04             	sub    $0x4,%edi
  800b7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b82:	c1 e9 02             	shr    $0x2,%ecx
  800b85:	fd                   	std    
  800b86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b88:	eb 09                	jmp    800b93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8a:	83 ef 01             	sub    $0x1,%edi
  800b8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b90:	fd                   	std    
  800b91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b94:	eb 20                	jmp    800bb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9c:	75 15                	jne    800bb3 <memmove+0x6e>
  800b9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba4:	75 0d                	jne    800bb3 <memmove+0x6e>
  800ba6:	f6 c1 03             	test   $0x3,%cl
  800ba9:	75 08                	jne    800bb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bab:	c1 e9 02             	shr    $0x2,%ecx
  800bae:	fc                   	cld    
  800baf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb1:	eb 03                	jmp    800bb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb3:	fc                   	cld    
  800bb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb6:	8b 34 24             	mov    (%esp),%esi
  800bb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bbd:	89 ec                	mov    %ebp,%esp
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	e8 65 ff ff ff       	call   800b45 <memmove>
}
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 75 08             	mov    0x8(%ebp),%esi
  800beb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf1:	85 c9                	test   %ecx,%ecx
  800bf3:	74 36                	je     800c2b <memcmp+0x49>
		if (*s1 != *s2)
  800bf5:	0f b6 06             	movzbl (%esi),%eax
  800bf8:	0f b6 1f             	movzbl (%edi),%ebx
  800bfb:	38 d8                	cmp    %bl,%al
  800bfd:	74 20                	je     800c1f <memcmp+0x3d>
  800bff:	eb 14                	jmp    800c15 <memcmp+0x33>
  800c01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c0b:	83 c2 01             	add    $0x1,%edx
  800c0e:	83 e9 01             	sub    $0x1,%ecx
  800c11:	38 d8                	cmp    %bl,%al
  800c13:	74 12                	je     800c27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c15:	0f b6 c0             	movzbl %al,%eax
  800c18:	0f b6 db             	movzbl %bl,%ebx
  800c1b:	29 d8                	sub    %ebx,%eax
  800c1d:	eb 11                	jmp    800c30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1f:	83 e9 01             	sub    $0x1,%ecx
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	85 c9                	test   %ecx,%ecx
  800c29:	75 d6                	jne    800c01 <memcmp+0x1f>
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c40:	39 d0                	cmp    %edx,%eax
  800c42:	73 15                	jae    800c59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c48:	38 08                	cmp    %cl,(%eax)
  800c4a:	75 06                	jne    800c52 <memfind+0x1d>
  800c4c:	eb 0b                	jmp    800c59 <memfind+0x24>
  800c4e:	38 08                	cmp    %cl,(%eax)
  800c50:	74 07                	je     800c59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	39 c2                	cmp    %eax,%edx
  800c57:	77 f5                	ja     800c4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 04             	sub    $0x4,%esp
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6a:	0f b6 02             	movzbl (%edx),%eax
  800c6d:	3c 20                	cmp    $0x20,%al
  800c6f:	74 04                	je     800c75 <strtol+0x1a>
  800c71:	3c 09                	cmp    $0x9,%al
  800c73:	75 0e                	jne    800c83 <strtol+0x28>
		s++;
  800c75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c78:	0f b6 02             	movzbl (%edx),%eax
  800c7b:	3c 20                	cmp    $0x20,%al
  800c7d:	74 f6                	je     800c75 <strtol+0x1a>
  800c7f:	3c 09                	cmp    $0x9,%al
  800c81:	74 f2                	je     800c75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c83:	3c 2b                	cmp    $0x2b,%al
  800c85:	75 0c                	jne    800c93 <strtol+0x38>
		s++;
  800c87:	83 c2 01             	add    $0x1,%edx
  800c8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c91:	eb 15                	jmp    800ca8 <strtol+0x4d>
	else if (*s == '-')
  800c93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c9a:	3c 2d                	cmp    $0x2d,%al
  800c9c:	75 0a                	jne    800ca8 <strtol+0x4d>
		s++, neg = 1;
  800c9e:	83 c2 01             	add    $0x1,%edx
  800ca1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	0f 94 c0             	sete   %al
  800cad:	74 05                	je     800cb4 <strtol+0x59>
  800caf:	83 fb 10             	cmp    $0x10,%ebx
  800cb2:	75 18                	jne    800ccc <strtol+0x71>
  800cb4:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb7:	75 13                	jne    800ccc <strtol+0x71>
  800cb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cbd:	8d 76 00             	lea    0x0(%esi),%esi
  800cc0:	75 0a                	jne    800ccc <strtol+0x71>
		s += 2, base = 16;
  800cc2:	83 c2 02             	add    $0x2,%edx
  800cc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cca:	eb 15                	jmp    800ce1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccc:	84 c0                	test   %al,%al
  800cce:	66 90                	xchg   %ax,%ax
  800cd0:	74 0f                	je     800ce1 <strtol+0x86>
  800cd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cda:	75 05                	jne    800ce1 <strtol+0x86>
		s++, base = 8;
  800cdc:	83 c2 01             	add    $0x1,%edx
  800cdf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce8:	0f b6 0a             	movzbl (%edx),%ecx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf0:	80 fb 09             	cmp    $0x9,%bl
  800cf3:	77 08                	ja     800cfd <strtol+0xa2>
			dig = *s - '0';
  800cf5:	0f be c9             	movsbl %cl,%ecx
  800cf8:	83 e9 30             	sub    $0x30,%ecx
  800cfb:	eb 1e                	jmp    800d1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d00:	80 fb 19             	cmp    $0x19,%bl
  800d03:	77 08                	ja     800d0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d05:	0f be c9             	movsbl %cl,%ecx
  800d08:	83 e9 57             	sub    $0x57,%ecx
  800d0b:	eb 0e                	jmp    800d1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d10:	80 fb 19             	cmp    $0x19,%bl
  800d13:	77 15                	ja     800d2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d15:	0f be c9             	movsbl %cl,%ecx
  800d18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d1b:	39 f1                	cmp    %esi,%ecx
  800d1d:	7d 0b                	jge    800d2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d1f:	83 c2 01             	add    $0x1,%edx
  800d22:	0f af c6             	imul   %esi,%eax
  800d25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d28:	eb be                	jmp    800ce8 <strtol+0x8d>
  800d2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d30:	74 05                	je     800d37 <strtol+0xdc>
		*endptr = (char *) s;
  800d32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d37:	89 ca                	mov    %ecx,%edx
  800d39:	f7 da                	neg    %edx
  800d3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d3f:	0f 45 c2             	cmovne %edx,%eax
}
  800d42:	83 c4 04             	add    $0x4,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
	...

00800d4c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 48             	sub    $0x48,%esp
  800d52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d58:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d5b:	89 c6                	mov    %eax,%esi
  800d5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d60:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d62:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6b:	51                   	push   %ecx
  800d6c:	52                   	push   %edx
  800d6d:	53                   	push   %ebx
  800d6e:	54                   	push   %esp
  800d6f:	55                   	push   %ebp
  800d70:	56                   	push   %esi
  800d71:	57                   	push   %edi
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	8d 35 7c 0d 80 00    	lea    0x800d7c,%esi
  800d7a:	0f 34                	sysenter 

00800d7c <.after_sysenter_label>:
  800d7c:	5f                   	pop    %edi
  800d7d:	5e                   	pop    %esi
  800d7e:	5d                   	pop    %ebp
  800d7f:	5c                   	pop    %esp
  800d80:	5b                   	pop    %ebx
  800d81:	5a                   	pop    %edx
  800d82:	59                   	pop    %ecx
  800d83:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d85:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d89:	74 28                	je     800db3 <.after_sysenter_label+0x37>
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 24                	jle    800db3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d93:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d97:	c7 44 24 08 20 28 80 	movl   $0x802820,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800da6:	00 
  800da7:	c7 04 24 3d 28 80 00 	movl   $0x80283d,(%esp)
  800dae:	e8 b1 f3 ff ff       	call   800164 <_panic>

	return ret;
}
  800db3:	89 d0                	mov    %edx,%eax
  800db5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbe:	89 ec                	mov    %ebp,%esp
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800dc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ddf:	00 
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	89 04 24             	mov    %eax,(%esp)
  800de6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dee:	b8 10 00 00 00       	mov    $0x10,%eax
  800df3:	e8 54 ff ff ff       	call   800d4c <syscall>
}
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    

00800dfa <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800e00:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e07:	00 
  800e08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e0f:	00 
  800e10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e17:	00 
  800e18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e24:	ba 00 00 00 00       	mov    $0x0,%edx
  800e29:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e2e:	e8 19 ff ff ff       	call   800d4c <syscall>
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e3b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e42:	00 
  800e43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e62:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e67:	e8 e0 fe ff ff       	call   800d4c <syscall>
}
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e7b:	00 
  800e7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e83:	8b 45 10             	mov    0x10(%ebp),%eax
  800e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9d:	e8 aa fe ff ff       	call   800d4c <syscall>
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800eaa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb9:	00 
  800eba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ec1:	00 
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	89 04 24             	mov    %eax,(%esp)
  800ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecb:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed5:	e8 72 fe ff ff       	call   800d4c <syscall>
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ee2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee9:	00 
  800eea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef9:	00 
  800efa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efd:	89 04 24             	mov    %eax,(%esp)
  800f00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f03:	ba 01 00 00 00       	mov    $0x1,%edx
  800f08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f0d:	e8 3a fe ff ff       	call   800d4c <syscall>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f31:	00 
  800f32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f35:	89 04 24             	mov    %eax,(%esp)
  800f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f40:	b8 09 00 00 00       	mov    $0x9,%eax
  800f45:	e8 02 fe ff ff       	call   800d4c <syscall>
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f52:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f69:	00 
  800f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6d:	89 04 24             	mov    %eax,(%esp)
  800f70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f73:	ba 01 00 00 00       	mov    $0x1,%edx
  800f78:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7d:	e8 ca fd ff ff       	call   800d4c <syscall>
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f91:	00 
  800f92:	8b 45 18             	mov    0x18(%ebp),%eax
  800f95:	0b 45 14             	or     0x14(%ebp),%eax
  800f98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa6:	89 04 24             	mov    %eax,(%esp)
  800fa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fac:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800fb6:	e8 91 fd ff ff       	call   800d4c <syscall>
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fc3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fca:	00 
  800fcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd2:	00 
  800fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fed:	e8 5a fd ff ff       	call   800d4c <syscall>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ffa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	ba 00 00 00 00       	mov    $0x0,%edx
  801023:	b8 0c 00 00 00       	mov    $0xc,%eax
  801028:	e8 1f fd ff ff       	call   800d4c <syscall>
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801035:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80103c:	00 
  80103d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801044:	00 
  801045:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80104c:	00 
  80104d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801050:	89 04 24             	mov    %eax,(%esp)
  801053:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801056:	ba 00 00 00 00       	mov    $0x0,%edx
  80105b:	b8 04 00 00 00       	mov    $0x4,%eax
  801060:	e8 e7 fc ff ff       	call   800d4c <syscall>
}
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80106d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801074:	00 
  801075:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107c:	00 
  80107d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801084:	00 
  801085:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801091:	ba 00 00 00 00       	mov    $0x0,%edx
  801096:	b8 02 00 00 00       	mov    $0x2,%eax
  80109b:	e8 ac fc ff ff       	call   800d4c <syscall>
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010af:	00 
  8010b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010bf:	00 
  8010c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ca:	ba 01 00 00 00       	mov    $0x1,%edx
  8010cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8010d4:	e8 73 fc ff ff       	call   800d4c <syscall>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f8:	00 
  8010f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801100:	b9 00 00 00 00       	mov    $0x0,%ecx
  801105:	ba 00 00 00 00       	mov    $0x0,%edx
  80110a:	b8 01 00 00 00       	mov    $0x1,%eax
  80110f:	e8 38 fc ff ff       	call   800d4c <syscall>
}
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80111c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801123:	00 
  801124:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80112b:	00 
  80112c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801133:	00 
  801134:	8b 45 0c             	mov    0xc(%ebp),%eax
  801137:	89 04 24             	mov    %eax,(%esp)
  80113a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113d:	ba 00 00 00 00       	mov    $0x0,%edx
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
  801147:	e8 00 fc ff ff       	call   800d4c <syscall>
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    
	...

00801150 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801156:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  80115d:	75 54                	jne    8011b3 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80115f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801166:	00 
  801167:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80116e:	ee 
  80116f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801176:	e8 42 fe ff ff       	call   800fbd <sys_page_alloc>
  80117b:	85 c0                	test   %eax,%eax
  80117d:	79 20                	jns    80119f <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80117f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801183:	c7 44 24 08 4b 28 80 	movl   $0x80284b,0x8(%esp)
  80118a:	00 
  80118b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801192:	00 
  801193:	c7 04 24 63 28 80 00 	movl   $0x802863,(%esp)
  80119a:	e8 c5 ef ff ff       	call   800164 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80119f:	c7 44 24 04 c0 11 80 	movl   $0x8011c0,0x4(%esp)
  8011a6:	00 
  8011a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011ae:	e8 f1 fc ff ff       	call   800ea4 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  8011bb:	c9                   	leave  
  8011bc:	c3                   	ret    
  8011bd:	00 00                	add    %al,(%eax)
	...

008011c0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8011c0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8011c1:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  8011c6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8011c8:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8011cb:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8011cf:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8011d2:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8011d6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8011da:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8011dc:	83 c4 08             	add    $0x8,%esp
	popal
  8011df:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8011e0:	83 c4 04             	add    $0x4,%esp
	popfl
  8011e3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8011e4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8011e5:	c3                   	ret    
	...

008011f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	89 04 24             	mov    %eax,(%esp)
  80120c:	e8 df ff ff ff       	call   8011f0 <fd2num>
  801211:	05 20 00 0d 00       	add    $0xd0020,%eax
  801216:	c1 e0 0c             	shl    $0xc,%eax
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801224:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801229:	a8 01                	test   $0x1,%al
  80122b:	74 36                	je     801263 <fd_alloc+0x48>
  80122d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801232:	a8 01                	test   $0x1,%al
  801234:	74 2d                	je     801263 <fd_alloc+0x48>
  801236:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80123b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801240:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801245:	89 c3                	mov    %eax,%ebx
  801247:	89 c2                	mov    %eax,%edx
  801249:	c1 ea 16             	shr    $0x16,%edx
  80124c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 14                	je     801268 <fd_alloc+0x4d>
  801254:	89 c2                	mov    %eax,%edx
  801256:	c1 ea 0c             	shr    $0xc,%edx
  801259:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80125c:	f6 c2 01             	test   $0x1,%dl
  80125f:	75 10                	jne    801271 <fd_alloc+0x56>
  801261:	eb 05                	jmp    801268 <fd_alloc+0x4d>
  801263:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801268:	89 1f                	mov    %ebx,(%edi)
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80126f:	eb 17                	jmp    801288 <fd_alloc+0x6d>
  801271:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801276:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127b:	75 c8                	jne    801245 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80127d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801283:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	83 f8 1f             	cmp    $0x1f,%eax
  801296:	77 36                	ja     8012ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801298:	05 00 00 0d 00       	add    $0xd0000,%eax
  80129d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 16             	shr    $0x16,%edx
  8012a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 1d                	je     8012ce <fd_lookup+0x41>
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 ea 0c             	shr    $0xc,%edx
  8012b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bd:	f6 c2 01             	test   $0x1,%dl
  8012c0:	74 0c                	je     8012ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c5:	89 02                	mov    %eax,(%edx)
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8012cc:	eb 05                	jmp    8012d3 <fd_lookup+0x46>
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	89 04 24             	mov    %eax,(%esp)
  8012e8:	e8 a0 ff ff ff       	call   80128d <fd_lookup>
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 0e                	js     8012ff <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f7:	89 50 04             	mov    %edx,0x4(%eax)
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    

00801301 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	56                   	push   %esi
  801305:	53                   	push   %ebx
  801306:	83 ec 10             	sub    $0x10,%esp
  801309:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80130f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801314:	b8 04 30 80 00       	mov    $0x803004,%eax
  801319:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80131f:	75 11                	jne    801332 <dev_lookup+0x31>
  801321:	eb 04                	jmp    801327 <dev_lookup+0x26>
  801323:	39 08                	cmp    %ecx,(%eax)
  801325:	75 10                	jne    801337 <dev_lookup+0x36>
			*dev = devtab[i];
  801327:	89 03                	mov    %eax,(%ebx)
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80132e:	66 90                	xchg   %ax,%ax
  801330:	eb 36                	jmp    801368 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801332:	be f4 28 80 00       	mov    $0x8028f4,%esi
  801337:	83 c2 01             	add    $0x1,%edx
  80133a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80133d:	85 c0                	test   %eax,%eax
  80133f:	75 e2                	jne    801323 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801341:	a1 08 40 80 00       	mov    0x804008,%eax
  801346:	8b 40 48             	mov    0x48(%eax),%eax
  801349:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	c7 04 24 74 28 80 00 	movl   $0x802874,(%esp)
  801358:	e8 c0 ee ff ff       	call   80021d <cprintf>
	*dev = 0;
  80135d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801363:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	53                   	push   %ebx
  801373:	83 ec 24             	sub    $0x24,%esp
  801376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801379:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801380:	8b 45 08             	mov    0x8(%ebp),%eax
  801383:	89 04 24             	mov    %eax,(%esp)
  801386:	e8 02 ff ff ff       	call   80128d <fd_lookup>
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 53                	js     8013e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801392:	89 44 24 04          	mov    %eax,0x4(%esp)
  801396:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801399:	8b 00                	mov    (%eax),%eax
  80139b:	89 04 24             	mov    %eax,(%esp)
  80139e:	e8 5e ff ff ff       	call   801301 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 3b                	js     8013e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013af:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013b3:	74 2d                	je     8013e2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013bf:	00 00 00 
	stat->st_isdir = 0;
  8013c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c9:	00 00 00 
	stat->st_dev = dev;
  8013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013dc:	89 14 24             	mov    %edx,(%esp)
  8013df:	ff 50 14             	call   *0x14(%eax)
}
  8013e2:	83 c4 24             	add    $0x24,%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 24             	sub    $0x24,%esp
  8013ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f9:	89 1c 24             	mov    %ebx,(%esp)
  8013fc:	e8 8c fe ff ff       	call   80128d <fd_lookup>
  801401:	85 c0                	test   %eax,%eax
  801403:	78 5f                	js     801464 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140f:	8b 00                	mov    (%eax),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 e8 fe ff ff       	call   801301 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 47                	js     801464 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801420:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801424:	75 23                	jne    801449 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801426:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80142b:	8b 40 48             	mov    0x48(%eax),%eax
  80142e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801432:	89 44 24 04          	mov    %eax,0x4(%esp)
  801436:	c7 04 24 94 28 80 00 	movl   $0x802894,(%esp)
  80143d:	e8 db ed ff ff       	call   80021d <cprintf>
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801447:	eb 1b                	jmp    801464 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801449:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144c:	8b 48 18             	mov    0x18(%eax),%ecx
  80144f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801454:	85 c9                	test   %ecx,%ecx
  801456:	74 0c                	je     801464 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801458:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145f:	89 14 24             	mov    %edx,(%esp)
  801462:	ff d1                	call   *%ecx
}
  801464:	83 c4 24             	add    $0x24,%esp
  801467:	5b                   	pop    %ebx
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 24             	sub    $0x24,%esp
  801471:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801474:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147b:	89 1c 24             	mov    %ebx,(%esp)
  80147e:	e8 0a fe ff ff       	call   80128d <fd_lookup>
  801483:	85 c0                	test   %eax,%eax
  801485:	78 66                	js     8014ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	8b 00                	mov    (%eax),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 66 fe ff ff       	call   801301 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 4e                	js     8014ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014a6:	75 23                	jne    8014cb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8014ad:	8b 40 48             	mov    0x48(%eax),%eax
  8014b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b8:	c7 04 24 b8 28 80 00 	movl   $0x8028b8,(%esp)
  8014bf:	e8 59 ed ff ff       	call   80021d <cprintf>
  8014c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014c9:	eb 22                	jmp    8014ed <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ce:	8b 48 0c             	mov    0xc(%eax),%ecx
  8014d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014d6:	85 c9                	test   %ecx,%ecx
  8014d8:	74 13                	je     8014ed <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014da:	8b 45 10             	mov    0x10(%ebp),%eax
  8014dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	89 14 24             	mov    %edx,(%esp)
  8014eb:	ff d1                	call   *%ecx
}
  8014ed:	83 c4 24             	add    $0x24,%esp
  8014f0:	5b                   	pop    %ebx
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	53                   	push   %ebx
  8014f7:	83 ec 24             	sub    $0x24,%esp
  8014fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801500:	89 44 24 04          	mov    %eax,0x4(%esp)
  801504:	89 1c 24             	mov    %ebx,(%esp)
  801507:	e8 81 fd ff ff       	call   80128d <fd_lookup>
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 6b                	js     80157b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801513:	89 44 24 04          	mov    %eax,0x4(%esp)
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	8b 00                	mov    (%eax),%eax
  80151c:	89 04 24             	mov    %eax,(%esp)
  80151f:	e8 dd fd ff ff       	call   801301 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801524:	85 c0                	test   %eax,%eax
  801526:	78 53                	js     80157b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801528:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152b:	8b 42 08             	mov    0x8(%edx),%eax
  80152e:	83 e0 03             	and    $0x3,%eax
  801531:	83 f8 01             	cmp    $0x1,%eax
  801534:	75 23                	jne    801559 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801536:	a1 08 40 80 00       	mov    0x804008,%eax
  80153b:	8b 40 48             	mov    0x48(%eax),%eax
  80153e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801542:	89 44 24 04          	mov    %eax,0x4(%esp)
  801546:	c7 04 24 d5 28 80 00 	movl   $0x8028d5,(%esp)
  80154d:	e8 cb ec ff ff       	call   80021d <cprintf>
  801552:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801557:	eb 22                	jmp    80157b <read+0x88>
	}
	if (!dev->dev_read)
  801559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155c:	8b 48 08             	mov    0x8(%eax),%ecx
  80155f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801564:	85 c9                	test   %ecx,%ecx
  801566:	74 13                	je     80157b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801568:	8b 45 10             	mov    0x10(%ebp),%eax
  80156b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80156f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	89 14 24             	mov    %edx,(%esp)
  801579:	ff d1                	call   *%ecx
}
  80157b:	83 c4 24             	add    $0x24,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	57                   	push   %edi
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	83 ec 1c             	sub    $0x1c,%esp
  80158a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801590:	ba 00 00 00 00       	mov    $0x0,%edx
  801595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
  80159f:	85 f6                	test   %esi,%esi
  8015a1:	74 29                	je     8015cc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a3:	89 f0                	mov    %esi,%eax
  8015a5:	29 d0                	sub    %edx,%eax
  8015a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ab:	03 55 0c             	add    0xc(%ebp),%edx
  8015ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015b2:	89 3c 24             	mov    %edi,(%esp)
  8015b5:	e8 39 ff ff ff       	call   8014f3 <read>
		if (m < 0)
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 0e                	js     8015cc <readn+0x4b>
			return m;
		if (m == 0)
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	74 08                	je     8015ca <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c2:	01 c3                	add    %eax,%ebx
  8015c4:	89 da                	mov    %ebx,%edx
  8015c6:	39 f3                	cmp    %esi,%ebx
  8015c8:	72 d9                	jb     8015a3 <readn+0x22>
  8015ca:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015cc:	83 c4 1c             	add    $0x1c,%esp
  8015cf:	5b                   	pop    %ebx
  8015d0:	5e                   	pop    %esi
  8015d1:	5f                   	pop    %edi
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 28             	sub    $0x28,%esp
  8015da:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015dd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8015e0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e3:	89 34 24             	mov    %esi,(%esp)
  8015e6:	e8 05 fc ff ff       	call   8011f0 <fd2num>
  8015eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 93 fc ff ff       	call   80128d <fd_lookup>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 05                	js     801605 <fd_close+0x31>
  801600:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801603:	74 0e                	je     801613 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801605:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
  80160e:	0f 44 d8             	cmove  %eax,%ebx
  801611:	eb 3d                	jmp    801650 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801613:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161a:	8b 06                	mov    (%esi),%eax
  80161c:	89 04 24             	mov    %eax,(%esp)
  80161f:	e8 dd fc ff ff       	call   801301 <dev_lookup>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	85 c0                	test   %eax,%eax
  801628:	78 16                	js     801640 <fd_close+0x6c>
		if (dev->dev_close)
  80162a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162d:	8b 40 10             	mov    0x10(%eax),%eax
  801630:	bb 00 00 00 00       	mov    $0x0,%ebx
  801635:	85 c0                	test   %eax,%eax
  801637:	74 07                	je     801640 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801639:	89 34 24             	mov    %esi,(%esp)
  80163c:	ff d0                	call   *%eax
  80163e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801640:	89 74 24 04          	mov    %esi,0x4(%esp)
  801644:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164b:	e8 fc f8 ff ff       	call   800f4c <sys_page_unmap>
	return r;
}
  801650:	89 d8                	mov    %ebx,%eax
  801652:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801655:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801658:	89 ec                	mov    %ebp,%esp
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801665:	89 44 24 04          	mov    %eax,0x4(%esp)
  801669:	8b 45 08             	mov    0x8(%ebp),%eax
  80166c:	89 04 24             	mov    %eax,(%esp)
  80166f:	e8 19 fc ff ff       	call   80128d <fd_lookup>
  801674:	85 c0                	test   %eax,%eax
  801676:	78 13                	js     80168b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801678:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80167f:	00 
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	89 04 24             	mov    %eax,(%esp)
  801686:	e8 49 ff ff ff       	call   8015d4 <fd_close>
}
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 18             	sub    $0x18,%esp
  801693:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801696:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801699:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016a0:	00 
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	e8 78 03 00 00       	call   801a24 <open>
  8016ac:	89 c3                	mov    %eax,%ebx
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 1b                	js     8016cd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	89 1c 24             	mov    %ebx,(%esp)
  8016bc:	e8 ae fc ff ff       	call   80136f <fstat>
  8016c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c3:	89 1c 24             	mov    %ebx,(%esp)
  8016c6:	e8 91 ff ff ff       	call   80165c <close>
  8016cb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8016cd:	89 d8                	mov    %ebx,%eax
  8016cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016d2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016d5:	89 ec                	mov    %ebp,%esp
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 14             	sub    $0x14,%esp
  8016e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8016e5:	89 1c 24             	mov    %ebx,(%esp)
  8016e8:	e8 6f ff ff ff       	call   80165c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ed:	83 c3 01             	add    $0x1,%ebx
  8016f0:	83 fb 20             	cmp    $0x20,%ebx
  8016f3:	75 f0                	jne    8016e5 <close_all+0xc>
		close(i);
}
  8016f5:	83 c4 14             	add    $0x14,%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 58             	sub    $0x58,%esp
  801701:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801704:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801707:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80170a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80170d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801710:	89 44 24 04          	mov    %eax,0x4(%esp)
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	89 04 24             	mov    %eax,(%esp)
  80171a:	e8 6e fb ff ff       	call   80128d <fd_lookup>
  80171f:	89 c3                	mov    %eax,%ebx
  801721:	85 c0                	test   %eax,%eax
  801723:	0f 88 e0 00 00 00    	js     801809 <dup+0x10e>
		return r;
	close(newfdnum);
  801729:	89 3c 24             	mov    %edi,(%esp)
  80172c:	e8 2b ff ff ff       	call   80165c <close>

	newfd = INDEX2FD(newfdnum);
  801731:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801737:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80173a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	e8 bb fa ff ff       	call   801200 <fd2data>
  801745:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801747:	89 34 24             	mov    %esi,(%esp)
  80174a:	e8 b1 fa ff ff       	call   801200 <fd2data>
  80174f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801752:	89 da                	mov    %ebx,%edx
  801754:	89 d8                	mov    %ebx,%eax
  801756:	c1 e8 16             	shr    $0x16,%eax
  801759:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801760:	a8 01                	test   $0x1,%al
  801762:	74 43                	je     8017a7 <dup+0xac>
  801764:	c1 ea 0c             	shr    $0xc,%edx
  801767:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80176e:	a8 01                	test   $0x1,%al
  801770:	74 35                	je     8017a7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801772:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801779:	25 07 0e 00 00       	and    $0xe07,%eax
  80177e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801782:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801785:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801789:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801790:	00 
  801791:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801795:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179c:	e8 e3 f7 ff ff       	call   800f84 <sys_page_map>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 3f                	js     8017e6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017aa:	89 c2                	mov    %eax,%edx
  8017ac:	c1 ea 0c             	shr    $0xc,%edx
  8017af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017b6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017cb:	00 
  8017cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d7:	e8 a8 f7 ff ff       	call   800f84 <sys_page_map>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 04                	js     8017e6 <dup+0xeb>
  8017e2:	89 fb                	mov    %edi,%ebx
  8017e4:	eb 23                	jmp    801809 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f1:	e8 56 f7 ff ff       	call   800f4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801804:	e8 43 f7 ff ff       	call   800f4c <sys_page_unmap>
	return r;
}
  801809:	89 d8                	mov    %ebx,%eax
  80180b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80180e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801811:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801814:	89 ec                	mov    %ebp,%esp
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 18             	sub    $0x18,%esp
  80181e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801821:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801824:	89 c3                	mov    %eax,%ebx
  801826:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801828:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182f:	75 11                	jne    801842 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801831:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801838:	e8 b3 07 00 00       	call   801ff0 <ipc_find_env>
  80183d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801842:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801849:	00 
  80184a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801851:	00 
  801852:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801856:	a1 00 40 80 00       	mov    0x804000,%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 d6 07 00 00       	call   802039 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801863:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80186a:	00 
  80186b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80186f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801876:	e8 29 08 00 00       	call   8020a4 <ipc_recv>
}
  80187b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80187e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801881:	89 ec                	mov    %ebp,%esp
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 40 0c             	mov    0xc(%eax),%eax
  801891:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801896:	8b 45 0c             	mov    0xc(%ebp),%eax
  801899:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a8:	e8 6b ff ff ff       	call   801818 <fsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ca:	e8 49 ff ff ff       	call   801818 <fsipc>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e1:	e8 32 ff ff ff       	call   801818 <fsipc>
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 14             	sub    $0x14,%esp
  8018ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 05 00 00 00       	mov    $0x5,%eax
  801907:	e8 0c ff ff ff       	call   801818 <fsipc>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 2b                	js     80193b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801910:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801917:	00 
  801918:	89 1c 24             	mov    %ebx,(%esp)
  80191b:	e8 3a f0 ff ff       	call   80095a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801920:	a1 80 50 80 00       	mov    0x805080,%eax
  801925:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80192b:	a1 84 50 80 00       	mov    0x805084,%eax
  801930:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80193b:	83 c4 14             	add    $0x14,%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 18             	sub    $0x18,%esp
  801947:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80194a:	8b 55 08             	mov    0x8(%ebp),%edx
  80194d:	8b 52 0c             	mov    0xc(%edx),%edx
  801950:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801956:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80195b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801960:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801965:	0f 47 c2             	cmova  %edx,%eax
  801968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801973:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80197a:	e8 c6 f1 ff ff       	call   800b45 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80197f:	ba 00 00 00 00       	mov    $0x0,%edx
  801984:	b8 04 00 00 00       	mov    $0x4,%eax
  801989:	e8 8a fe ff ff       	call   801818 <fsipc>
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	8b 40 0c             	mov    0xc(%eax),%eax
  80199d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8019a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b4:	e8 5f fe ff ff       	call   801818 <fsipc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 17                	js     8019d6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019ca:	00 
  8019cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	e8 6f f1 ff ff       	call   800b45 <memmove>
  return r;	
}
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	83 c4 14             	add    $0x14,%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 14             	sub    $0x14,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019e8:	89 1c 24             	mov    %ebx,(%esp)
  8019eb:	e8 20 ef ff ff       	call   800910 <strlen>
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8019f7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8019fd:	7f 1f                	jg     801a1e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8019ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a03:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a0a:	e8 4b ef ff ff       	call   80095a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a14:	b8 07 00 00 00       	mov    $0x7,%eax
  801a19:	e8 fa fd ff ff       	call   801818 <fsipc>
}
  801a1e:	83 c4 14             	add    $0x14,%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 28             	sub    $0x28,%esp
  801a2a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a2d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a30:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801a33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 dd f7 ff ff       	call   80121b <fd_alloc>
  801a3e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a40:	85 c0                	test   %eax,%eax
  801a42:	0f 88 89 00 00 00    	js     801ad1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a48:	89 34 24             	mov    %esi,(%esp)
  801a4b:	e8 c0 ee ff ff       	call   800910 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a50:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a55:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a5a:	7f 75                	jg     801ad1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a60:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a67:	e8 ee ee ff ff       	call   80095a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801a74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a77:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7c:	e8 97 fd ff ff       	call   801818 <fsipc>
  801a81:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 0f                	js     801a96 <open+0x72>
  return fd2num(fd);
  801a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8a:	89 04 24             	mov    %eax,(%esp)
  801a8d:	e8 5e f7 ff ff       	call   8011f0 <fd2num>
  801a92:	89 c3                	mov    %eax,%ebx
  801a94:	eb 3b                	jmp    801ad1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801a96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a9d:	00 
  801a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 2b fb ff ff       	call   8015d4 <fd_close>
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	74 24                	je     801ad1 <open+0xad>
  801aad:	c7 44 24 0c 00 29 80 	movl   $0x802900,0xc(%esp)
  801ab4:	00 
  801ab5:	c7 44 24 08 15 29 80 	movl   $0x802915,0x8(%esp)
  801abc:	00 
  801abd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801ac4:	00 
  801ac5:	c7 04 24 2a 29 80 00 	movl   $0x80292a,(%esp)
  801acc:	e8 93 e6 ff ff       	call   800164 <_panic>
  return r;
}
  801ad1:	89 d8                	mov    %ebx,%eax
  801ad3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ad6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ad9:	89 ec                	mov    %ebp,%esp
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    
  801add:	00 00                	add    %al,(%eax)
	...

00801ae0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ae6:	c7 44 24 04 35 29 80 	movl   $0x802935,0x4(%esp)
  801aed:	00 
  801aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 61 ee ff ff       	call   80095a <strcpy>
	return 0;
}
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	53                   	push   %ebx
  801b04:	83 ec 14             	sub    $0x14,%esp
  801b07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b0a:	89 1c 24             	mov    %ebx,(%esp)
  801b0d:	e8 22 06 00 00       	call   802134 <pageref>
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
  801b19:	83 fa 01             	cmp    $0x1,%edx
  801b1c:	75 0b                	jne    801b29 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801b1e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 b9 02 00 00       	call   801de2 <nsipc_close>
	else
		return 0;
}
  801b29:	83 c4 14             	add    $0x14,%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b35:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b3c:	00 
  801b3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 c5 02 00 00       	call   801e1e <nsipc_send>
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b61:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b68:	00 
  801b69:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b77:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7d:	89 04 24             	mov    %eax,(%esp)
  801b80:	e8 0c 03 00 00       	call   801e91 <nsipc_recv>
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 20             	sub    $0x20,%esp
  801b8f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b94:	89 04 24             	mov    %eax,(%esp)
  801b97:	e8 7f f6 ff ff       	call   80121b <fd_alloc>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	78 21                	js     801bc3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ba2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ba9:	00 
  801baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb8:	e8 00 f4 ff ff       	call   800fbd <sys_page_alloc>
  801bbd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	79 0a                	jns    801bcd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801bc3:	89 34 24             	mov    %esi,(%esp)
  801bc6:	e8 17 02 00 00       	call   801de2 <nsipc_close>
		return r;
  801bcb:	eb 28                	jmp    801bf5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bcd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 fd f5 ff ff       	call   8011f0 <fd2num>
  801bf3:	89 c3                	mov    %eax,%ebx
}
  801bf5:	89 d8                	mov    %ebx,%eax
  801bf7:	83 c4 20             	add    $0x20,%esp
  801bfa:	5b                   	pop    %ebx
  801bfb:	5e                   	pop    %esi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c04:	8b 45 10             	mov    0x10(%ebp),%eax
  801c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	89 04 24             	mov    %eax,(%esp)
  801c18:	e8 79 01 00 00       	call   801d96 <nsipc_socket>
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 05                	js     801c26 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c21:	e8 61 ff ff ff       	call   801b87 <alloc_sockfd>
}
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 50 f6 ff ff       	call   80128d <fd_lookup>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 15                	js     801c56 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c44:	8b 0a                	mov    (%edx),%ecx
  801c46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c4b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801c51:	75 03                	jne    801c56 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c53:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c61:	e8 c2 ff ff ff       	call   801c28 <fd2sockid>
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 0f                	js     801c79 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c71:	89 04 24             	mov    %eax,(%esp)
  801c74:	e8 47 01 00 00       	call   801dc0 <nsipc_listen>
}
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	e8 9f ff ff ff       	call   801c28 <fd2sockid>
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 16                	js     801ca3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c8d:	8b 55 10             	mov    0x10(%ebp),%edx
  801c90:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c97:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 6e 02 00 00       	call   801f11 <nsipc_connect>
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
  801cae:	e8 75 ff ff ff       	call   801c28 <fd2sockid>
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 0f                	js     801cc6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cba:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cbe:	89 04 24             	mov    %eax,(%esp)
  801cc1:	e8 36 01 00 00       	call   801dfc <nsipc_shutdown>
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	e8 52 ff ff ff       	call   801c28 <fd2sockid>
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 16                	js     801cf0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cda:	8b 55 10             	mov    0x10(%ebp),%edx
  801cdd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce8:	89 04 24             	mov    %eax,(%esp)
  801ceb:	e8 60 02 00 00       	call   801f50 <nsipc_bind>
}
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	e8 28 ff ff ff       	call   801c28 <fd2sockid>
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 1f                	js     801d23 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d04:	8b 55 10             	mov    0x10(%ebp),%edx
  801d07:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d12:	89 04 24             	mov    %eax,(%esp)
  801d15:	e8 75 02 00 00       	call   801f8f <nsipc_accept>
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	78 05                	js     801d23 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d1e:	e8 64 fe ff ff       	call   801b87 <alloc_sockfd>
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    
	...

00801d30 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	53                   	push   %ebx
  801d34:	83 ec 14             	sub    $0x14,%esp
  801d37:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d39:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d40:	75 11                	jne    801d53 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d42:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801d49:	e8 a2 02 00 00       	call   801ff0 <ipc_find_env>
  801d4e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d53:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d5a:	00 
  801d5b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d62:	00 
  801d63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d67:	a1 04 40 80 00       	mov    0x804004,%eax
  801d6c:	89 04 24             	mov    %eax,(%esp)
  801d6f:	e8 c5 02 00 00       	call   802039 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d7b:	00 
  801d7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d83:	00 
  801d84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8b:	e8 14 03 00 00       	call   8020a4 <ipc_recv>
}
  801d90:	83 c4 14             	add    $0x14,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dac:	8b 45 10             	mov    0x10(%ebp),%eax
  801daf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801db4:	b8 09 00 00 00       	mov    $0x9,%eax
  801db9:	e8 72 ff ff ff       	call   801d30 <nsipc>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  801ddb:	e8 50 ff ff ff       	call   801d30 <nsipc>
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801df0:	b8 04 00 00 00       	mov    $0x4,%eax
  801df5:	e8 36 ff ff ff       	call   801d30 <nsipc>
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e02:	8b 45 08             	mov    0x8(%ebp),%eax
  801e05:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e12:	b8 03 00 00 00       	mov    $0x3,%eax
  801e17:	e8 14 ff ff ff       	call   801d30 <nsipc>
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	53                   	push   %ebx
  801e22:	83 ec 14             	sub    $0x14,%esp
  801e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e28:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e30:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e36:	7e 24                	jle    801e5c <nsipc_send+0x3e>
  801e38:	c7 44 24 0c 41 29 80 	movl   $0x802941,0xc(%esp)
  801e3f:	00 
  801e40:	c7 44 24 08 15 29 80 	movl   $0x802915,0x8(%esp)
  801e47:	00 
  801e48:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801e4f:	00 
  801e50:	c7 04 24 4d 29 80 00 	movl   $0x80294d,(%esp)
  801e57:	e8 08 e3 ff ff       	call   800164 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e6e:	e8 d2 ec ff ff       	call   800b45 <memmove>
	nsipcbuf.send.req_size = size;
  801e73:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e79:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e81:	b8 08 00 00 00       	mov    $0x8,%eax
  801e86:	e8 a5 fe ff ff       	call   801d30 <nsipc>
}
  801e8b:	83 c4 14             	add    $0x14,%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	56                   	push   %esi
  801e95:	53                   	push   %ebx
  801e96:	83 ec 10             	sub    $0x10,%esp
  801e99:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ea4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eaa:	8b 45 14             	mov    0x14(%ebp),%eax
  801ead:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801eb2:	b8 07 00 00 00       	mov    $0x7,%eax
  801eb7:	e8 74 fe ff ff       	call   801d30 <nsipc>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 46                	js     801f08 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ec2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ec7:	7f 04                	jg     801ecd <nsipc_recv+0x3c>
  801ec9:	39 c6                	cmp    %eax,%esi
  801ecb:	7d 24                	jge    801ef1 <nsipc_recv+0x60>
  801ecd:	c7 44 24 0c 59 29 80 	movl   $0x802959,0xc(%esp)
  801ed4:	00 
  801ed5:	c7 44 24 08 15 29 80 	movl   $0x802915,0x8(%esp)
  801edc:	00 
  801edd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801ee4:	00 
  801ee5:	c7 04 24 4d 29 80 00 	movl   $0x80294d,(%esp)
  801eec:	e8 73 e2 ff ff       	call   800164 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ef1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801efc:	00 
  801efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f00:	89 04 24             	mov    %eax,(%esp)
  801f03:	e8 3d ec ff ff       	call   800b45 <memmove>
	}

	return r;
}
  801f08:	89 d8                	mov    %ebx,%eax
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5d                   	pop    %ebp
  801f10:	c3                   	ret    

00801f11 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	53                   	push   %ebx
  801f15:	83 ec 14             	sub    $0x14,%esp
  801f18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f35:	e8 0b ec ff ff       	call   800b45 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f3a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f40:	b8 05 00 00 00       	mov    $0x5,%eax
  801f45:	e8 e6 fd ff ff       	call   801d30 <nsipc>
}
  801f4a:	83 c4 14             	add    $0x14,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	53                   	push   %ebx
  801f54:	83 ec 14             	sub    $0x14,%esp
  801f57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f62:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f74:	e8 cc eb ff ff       	call   800b45 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f79:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f7f:	b8 02 00 00 00       	mov    $0x2,%eax
  801f84:	e8 a7 fd ff ff       	call   801d30 <nsipc>
}
  801f89:	83 c4 14             	add    $0x14,%esp
  801f8c:	5b                   	pop    %ebx
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	83 ec 18             	sub    $0x18,%esp
  801f95:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f98:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fa3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa8:	e8 83 fd ff ff       	call   801d30 <nsipc>
  801fad:	89 c3                	mov    %eax,%ebx
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	78 25                	js     801fd8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fb3:	be 10 60 80 00       	mov    $0x806010,%esi
  801fb8:	8b 06                	mov    (%esi),%eax
  801fba:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fbe:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fc5:	00 
  801fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc9:	89 04 24             	mov    %eax,(%esp)
  801fcc:	e8 74 eb ff ff       	call   800b45 <memmove>
		*addrlen = ret->ret_addrlen;
  801fd1:	8b 16                	mov    (%esi),%edx
  801fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fdd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fe0:	89 ec                	mov    %ebp,%esp
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
	...

00801ff0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ff6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801ffc:	b8 01 00 00 00       	mov    $0x1,%eax
  802001:	39 ca                	cmp    %ecx,%edx
  802003:	75 04                	jne    802009 <ipc_find_env+0x19>
  802005:	b0 00                	mov    $0x0,%al
  802007:	eb 11                	jmp    80201a <ipc_find_env+0x2a>
  802009:	89 c2                	mov    %eax,%edx
  80200b:	c1 e2 07             	shl    $0x7,%edx
  80200e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802014:	8b 12                	mov    (%edx),%edx
  802016:	39 ca                	cmp    %ecx,%edx
  802018:	75 0f                	jne    802029 <ipc_find_env+0x39>
			return envs[i].env_id;
  80201a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  80201e:	c1 e0 06             	shl    $0x6,%eax
  802021:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  802027:	eb 0e                	jmp    802037 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802029:	83 c0 01             	add    $0x1,%eax
  80202c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802031:	75 d6                	jne    802009 <ipc_find_env+0x19>
  802033:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    

00802039 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	57                   	push   %edi
  80203d:	56                   	push   %esi
  80203e:	53                   	push   %ebx
  80203f:	83 ec 1c             	sub    $0x1c,%esp
  802042:	8b 75 08             	mov    0x8(%ebp),%esi
  802045:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802048:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80204b:	85 db                	test   %ebx,%ebx
  80204d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802052:	0f 44 d8             	cmove  %eax,%ebx
  802055:	eb 25                	jmp    80207c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  802057:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80205a:	74 20                	je     80207c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  80205c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802060:	c7 44 24 08 6e 29 80 	movl   $0x80296e,0x8(%esp)
  802067:	00 
  802068:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80206f:	00 
  802070:	c7 04 24 8c 29 80 00 	movl   $0x80298c,(%esp)
  802077:	e8 e8 e0 ff ff       	call   800164 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80207c:	8b 45 14             	mov    0x14(%ebp),%eax
  80207f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802083:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802087:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80208b:	89 34 24             	mov    %esi,(%esp)
  80208e:	e8 db ed ff ff       	call   800e6e <sys_ipc_try_send>
  802093:	85 c0                	test   %eax,%eax
  802095:	75 c0                	jne    802057 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802097:	e8 58 ef ff ff       	call   800ff4 <sys_yield>
}
  80209c:	83 c4 1c             	add    $0x1c,%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5f                   	pop    %edi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	83 ec 28             	sub    $0x28,%esp
  8020aa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020ad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8020b0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8020b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020b9:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8020bc:	85 c0                	test   %eax,%eax
  8020be:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8020c3:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8020c6:	89 04 24             	mov    %eax,(%esp)
  8020c9:	e8 67 ed ff ff       	call   800e35 <sys_ipc_recv>
  8020ce:	89 c3                	mov    %eax,%ebx
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	79 2a                	jns    8020fe <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8020d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020dc:	c7 04 24 96 29 80 00 	movl   $0x802996,(%esp)
  8020e3:	e8 35 e1 ff ff       	call   80021d <cprintf>
		if(from_env_store != NULL)
  8020e8:	85 f6                	test   %esi,%esi
  8020ea:	74 06                	je     8020f2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8020ec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8020f2:	85 ff                	test   %edi,%edi
  8020f4:	74 2c                	je     802122 <ipc_recv+0x7e>
			*perm_store = 0;
  8020f6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8020fc:	eb 24                	jmp    802122 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8020fe:	85 f6                	test   %esi,%esi
  802100:	74 0a                	je     80210c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  802102:	a1 08 40 80 00       	mov    0x804008,%eax
  802107:	8b 40 74             	mov    0x74(%eax),%eax
  80210a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80210c:	85 ff                	test   %edi,%edi
  80210e:	74 0a                	je     80211a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802110:	a1 08 40 80 00       	mov    0x804008,%eax
  802115:	8b 40 78             	mov    0x78(%eax),%eax
  802118:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80211a:	a1 08 40 80 00       	mov    0x804008,%eax
  80211f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802122:	89 d8                	mov    %ebx,%eax
  802124:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802127:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80212a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80212d:	89 ec                	mov    %ebp,%esp
  80212f:	5d                   	pop    %ebp
  802130:	c3                   	ret    
  802131:	00 00                	add    %al,(%eax)
	...

00802134 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802134:	55                   	push   %ebp
  802135:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802137:	8b 45 08             	mov    0x8(%ebp),%eax
  80213a:	89 c2                	mov    %eax,%edx
  80213c:	c1 ea 16             	shr    $0x16,%edx
  80213f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802146:	f6 c2 01             	test   $0x1,%dl
  802149:	74 20                	je     80216b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80214b:	c1 e8 0c             	shr    $0xc,%eax
  80214e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802155:	a8 01                	test   $0x1,%al
  802157:	74 12                	je     80216b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802159:	c1 e8 0c             	shr    $0xc,%eax
  80215c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802161:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802166:	0f b7 c0             	movzwl %ax,%eax
  802169:	eb 05                	jmp    802170 <pageref+0x3c>
  80216b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
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
