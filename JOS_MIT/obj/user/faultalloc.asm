
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
  800041:	e8 96 10 00 00       	call   8010dc <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  800046:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80004d:	de 
  80004e:	c7 04 24 40 1e 80 00 	movl   $0x801e40,(%esp)
  800055:	e8 c3 01 00 00       	call   80021d <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  80005a:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  800061:	ca 
  800062:	c7 04 24 40 1e 80 00 	movl   $0x801e40,(%esp)
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
  800080:	c7 04 24 44 1e 80 00 	movl   $0x801e44,(%esp)
  800087:	e8 91 01 00 00       	call   80021d <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80008c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800093:	00 
  800094:	89 d8                	mov    %ebx,%eax
  800096:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80009b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a6:	e8 9f 0e 00 00       	call   800f4a <sys_page_alloc>
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	79 24                	jns    8000d3 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  8000af:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000b3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b7:	c7 44 24 08 60 1e 80 	movl   $0x801e60,0x8(%esp)
  8000be:	00 
  8000bf:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000c6:	00 
  8000c7:	c7 04 24 4e 1e 80 00 	movl   $0x801e4e,(%esp)
  8000ce:	e8 91 00 00 00       	call   800164 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000d3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d7:	c7 44 24 08 8c 1e 80 	movl   $0x801e8c,0x8(%esp)
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
  80010a:	e8 e5 0e 00 00       	call   800ff4 <sys_getenvid>
  80010f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800114:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800117:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011c:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80014e:	e8 16 15 00 00       	call   801669 <close_all>
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 d0 0e 00 00       	call   80102f <sys_env_destroy>
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
  800175:	e8 7a 0e 00 00       	call   800ff4 <sys_getenvid>
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800188:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800190:	c7 04 24 b8 1e 80 00 	movl   $0x801eb8,(%esp)
  800197:	e8 81 00 00 00       	call   80021d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a3:	89 04 24             	mov    %eax,(%esp)
  8001a6:	e8 11 00 00 00       	call   8001bc <vcprintf>
	cprintf("\n");
  8001ab:	c7 04 24 2f 23 80 00 	movl   $0x80232f,(%esp)
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
  800210:	e8 8e 0e 00 00       	call   8010a3 <sys_cputs>

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
  800264:	e8 3a 0e 00 00       	call   8010a3 <sys_cputs>
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
  8002fd:	e8 be 18 00 00       	call   801bc0 <__udivdi3>
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
  800358:	e8 93 19 00 00       	call   801cf0 <__umoddi3>
  80035d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800361:	0f be 80 db 1e 80 00 	movsbl 0x801edb(%eax),%eax
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
  800445:	ff 24 95 c0 20 80 00 	jmp    *0x8020c0(,%edx,4)
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
  800518:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  80051f:	85 d2                	test   %edx,%edx
  800521:	75 20                	jne    800543 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800527:	c7 44 24 08 ec 1e 80 	movl   $0x801eec,0x8(%esp)
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
  800547:	c7 44 24 08 63 23 80 	movl   $0x802363,0x8(%esp)
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
  800581:	b8 f5 1e 80 00       	mov    $0x801ef5,%eax
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
  8007c5:	c7 44 24 0c 10 20 80 	movl   $0x802010,0xc(%esp)
  8007cc:	00 
  8007cd:	c7 44 24 08 63 23 80 	movl   $0x802363,0x8(%esp)
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
  8007f3:	c7 44 24 0c 48 20 80 	movl   $0x802048,0xc(%esp)
  8007fa:	00 
  8007fb:	c7 44 24 08 63 23 80 	movl   $0x802363,0x8(%esp)
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
  800d97:	c7 44 24 08 60 22 80 	movl   $0x802260,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800da6:	00 
  800da7:	c7 04 24 7d 22 80 00 	movl   $0x80227d,(%esp)
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

00800dc2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ddf:	00 
  800de0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800de7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dea:	ba 01 00 00 00       	mov    $0x1,%edx
  800def:	b8 0e 00 00 00       	mov    $0xe,%eax
  800df4:	e8 53 ff ff ff       	call   800d4c <syscall>
}
  800df9:	c9                   	leave  
  800dfa:	c3                   	ret    

00800dfb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e01:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e08:	00 
  800e09:	8b 45 14             	mov    0x14(%ebp),%eax
  800e0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e10:	8b 45 10             	mov    0x10(%ebp),%eax
  800e13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	89 04 24             	mov    %eax,(%esp)
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	ba 00 00 00 00       	mov    $0x0,%edx
  800e25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e2a:	e8 1d ff ff ff       	call   800d4c <syscall>
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e37:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e46:	00 
  800e47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e4e:	00 
  800e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e52:	89 04 24             	mov    %eax,(%esp)
  800e55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e58:	ba 01 00 00 00       	mov    $0x1,%edx
  800e5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e62:	e8 e5 fe ff ff       	call   800d4c <syscall>
}
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    

00800e69 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e6f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e76:	00 
  800e77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e7e:	00 
  800e7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e86:	00 
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	89 04 24             	mov    %eax,(%esp)
  800e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e90:	ba 01 00 00 00       	mov    $0x1,%edx
  800e95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e9a:	e8 ad fe ff ff       	call   800d4c <syscall>
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ea7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eae:	00 
  800eaf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ebe:	00 
  800ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec2:	89 04 24             	mov    %eax,(%esp)
  800ec5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec8:	ba 01 00 00 00       	mov    $0x1,%edx
  800ecd:	b8 09 00 00 00       	mov    $0x9,%eax
  800ed2:	e8 75 fe ff ff       	call   800d4c <syscall>
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800edf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef6:	00 
  800ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efa:	89 04 24             	mov    %eax,(%esp)
  800efd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f00:	ba 01 00 00 00       	mov    $0x1,%edx
  800f05:	b8 07 00 00 00       	mov    $0x7,%eax
  800f0a:	e8 3d fe ff ff       	call   800d4c <syscall>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1e:	00 
  800f1f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f22:	0b 45 14             	or     0x14(%ebp),%eax
  800f25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f29:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	89 04 24             	mov    %eax,(%esp)
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	ba 01 00 00 00       	mov    $0x1,%edx
  800f3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f43:	e8 04 fe ff ff       	call   800d4c <syscall>
}
  800f48:	c9                   	leave  
  800f49:	c3                   	ret    

00800f4a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f50:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f57:	00 
  800f58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f5f:	00 
  800f60:	8b 45 10             	mov    0x10(%ebp),%eax
  800f63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6a:	89 04 24             	mov    %eax,(%esp)
  800f6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f70:	ba 01 00 00 00       	mov    $0x1,%edx
  800f75:	b8 05 00 00 00       	mov    $0x5,%eax
  800f7a:	e8 cd fd ff ff       	call   800d4c <syscall>
}
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f8e:	00 
  800f8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f96:	00 
  800f97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f9e:	00 
  800f9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fab:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fb5:	e8 92 fd ff ff       	call   800d4c <syscall>
}
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fbc:	55                   	push   %ebp
  800fbd:	89 e5                	mov    %esp,%ebp
  800fbf:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800fc2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc9:	00 
  800fca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd1:	00 
  800fd2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd9:	00 
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe3:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe8:	b8 04 00 00 00       	mov    $0x4,%eax
  800fed:	e8 5a fd ff ff       	call   800d4c <syscall>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ffa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	ba 00 00 00 00       	mov    $0x0,%edx
  801023:	b8 02 00 00 00       	mov    $0x2,%eax
  801028:	e8 1f fd ff ff       	call   800d4c <syscall>
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801035:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80103c:	00 
  80103d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801044:	00 
  801045:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80104c:	00 
  80104d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801054:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801057:	ba 01 00 00 00       	mov    $0x1,%edx
  80105c:	b8 03 00 00 00       	mov    $0x3,%eax
  801061:	e8 e6 fc ff ff       	call   800d4c <syscall>
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80106e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801075:	00 
  801076:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107d:	00 
  80107e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801085:	00 
  801086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801092:	ba 00 00 00 00       	mov    $0x0,%edx
  801097:	b8 01 00 00 00       	mov    $0x1,%eax
  80109c:	e8 ab fc ff ff       	call   800d4c <syscall>
}
  8010a1:	c9                   	leave  
  8010a2:	c3                   	ret    

008010a3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010b0:	00 
  8010b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b8:	00 
  8010b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010c0:	00 
  8010c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010c4:	89 04 24             	mov    %eax,(%esp)
  8010c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d4:	e8 73 fc ff ff       	call   800d4c <syscall>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    
	...

008010dc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010e2:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  8010e9:	75 54                	jne    80113f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  8010eb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010f2:	00 
  8010f3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010fa:	ee 
  8010fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801102:	e8 43 fe ff ff       	call   800f4a <sys_page_alloc>
  801107:	85 c0                	test   %eax,%eax
  801109:	79 20                	jns    80112b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80110b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80110f:	c7 44 24 08 8b 22 80 	movl   $0x80228b,0x8(%esp)
  801116:	00 
  801117:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80111e:	00 
  80111f:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801126:	e8 39 f0 ff ff       	call   800164 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80112b:	c7 44 24 04 4c 11 80 	movl   $0x80114c,0x4(%esp)
  801132:	00 
  801133:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80113a:	e8 f2 fc ff ff       	call   800e31 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	a3 08 40 80 00       	mov    %eax,0x804008
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    
  801149:	00 00                	add    %al,(%eax)
	...

0080114c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80114c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80114d:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801152:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801154:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  801157:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80115b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80115e:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  801162:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801166:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  801168:	83 c4 08             	add    $0x8,%esp
	popal
  80116b:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  80116c:	83 c4 04             	add    $0x4,%esp
	popfl
  80116f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801170:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801171:	c3                   	ret    
	...

00801180 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801180:	55                   	push   %ebp
  801181:	89 e5                	mov    %esp,%ebp
  801183:	8b 45 08             	mov    0x8(%ebp),%eax
  801186:	05 00 00 00 30       	add    $0x30000000,%eax
  80118b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801196:	8b 45 08             	mov    0x8(%ebp),%eax
  801199:	89 04 24             	mov    %eax,(%esp)
  80119c:	e8 df ff ff ff       	call   801180 <fd2num>
  8011a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8011a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8011a9:	c9                   	leave  
  8011aa:	c3                   	ret    

008011ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8011b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8011b9:	a8 01                	test   $0x1,%al
  8011bb:	74 36                	je     8011f3 <fd_alloc+0x48>
  8011bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8011c2:	a8 01                	test   $0x1,%al
  8011c4:	74 2d                	je     8011f3 <fd_alloc+0x48>
  8011c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8011cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8011d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8011d5:	89 c3                	mov    %eax,%ebx
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	c1 ea 16             	shr    $0x16,%edx
  8011dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	74 14                	je     8011f8 <fd_alloc+0x4d>
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	c1 ea 0c             	shr    $0xc,%edx
  8011e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8011ec:	f6 c2 01             	test   $0x1,%dl
  8011ef:	75 10                	jne    801201 <fd_alloc+0x56>
  8011f1:	eb 05                	jmp    8011f8 <fd_alloc+0x4d>
  8011f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8011f8:	89 1f                	mov    %ebx,(%edi)
  8011fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8011ff:	eb 17                	jmp    801218 <fd_alloc+0x6d>
  801201:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801206:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120b:	75 c8                	jne    8011d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80120d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801213:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    

0080121d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801220:	8b 45 08             	mov    0x8(%ebp),%eax
  801223:	83 f8 1f             	cmp    $0x1f,%eax
  801226:	77 36                	ja     80125e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801228:	05 00 00 0d 00       	add    $0xd0000,%eax
  80122d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801230:	89 c2                	mov    %eax,%edx
  801232:	c1 ea 16             	shr    $0x16,%edx
  801235:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123c:	f6 c2 01             	test   $0x1,%dl
  80123f:	74 1d                	je     80125e <fd_lookup+0x41>
  801241:	89 c2                	mov    %eax,%edx
  801243:	c1 ea 0c             	shr    $0xc,%edx
  801246:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124d:	f6 c2 01             	test   $0x1,%dl
  801250:	74 0c                	je     80125e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801252:	8b 55 0c             	mov    0xc(%ebp),%edx
  801255:	89 02                	mov    %eax,(%edx)
  801257:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80125c:	eb 05                	jmp    801263 <fd_lookup+0x46>
  80125e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80126b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80126e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801272:	8b 45 08             	mov    0x8(%ebp),%eax
  801275:	89 04 24             	mov    %eax,(%esp)
  801278:	e8 a0 ff ff ff       	call   80121d <fd_lookup>
  80127d:	85 c0                	test   %eax,%eax
  80127f:	78 0e                	js     80128f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801281:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801284:	8b 55 0c             	mov    0xc(%ebp),%edx
  801287:	89 50 04             	mov    %edx,0x4(%eax)
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80128f:	c9                   	leave  
  801290:	c3                   	ret    

00801291 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801291:	55                   	push   %ebp
  801292:	89 e5                	mov    %esp,%ebp
  801294:	56                   	push   %esi
  801295:	53                   	push   %ebx
  801296:	83 ec 10             	sub    $0x10,%esp
  801299:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80129c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80129f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8012a4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8012a9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8012af:	75 11                	jne    8012c2 <dev_lookup+0x31>
  8012b1:	eb 04                	jmp    8012b7 <dev_lookup+0x26>
  8012b3:	39 08                	cmp    %ecx,(%eax)
  8012b5:	75 10                	jne    8012c7 <dev_lookup+0x36>
			*dev = devtab[i];
  8012b7:	89 03                	mov    %eax,(%ebx)
  8012b9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8012be:	66 90                	xchg   %ax,%ax
  8012c0:	eb 36                	jmp    8012f8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012c2:	be 34 23 80 00       	mov    $0x802334,%esi
  8012c7:	83 c2 01             	add    $0x1,%edx
  8012ca:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	75 e2                	jne    8012b3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	c7 04 24 b4 22 80 00 	movl   $0x8022b4,(%esp)
  8012e8:	e8 30 ef ff ff       	call   80021d <cprintf>
	*dev = 0;
  8012ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	5b                   	pop    %ebx
  8012fc:	5e                   	pop    %esi
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 24             	sub    $0x24,%esp
  801306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801309:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801310:	8b 45 08             	mov    0x8(%ebp),%eax
  801313:	89 04 24             	mov    %eax,(%esp)
  801316:	e8 02 ff ff ff       	call   80121d <fd_lookup>
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 53                	js     801372 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	89 44 24 04          	mov    %eax,0x4(%esp)
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	8b 00                	mov    (%eax),%eax
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	e8 5e ff ff ff       	call   801291 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801333:	85 c0                	test   %eax,%eax
  801335:	78 3b                	js     801372 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801337:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80133c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80133f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801343:	74 2d                	je     801372 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801345:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801348:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80134f:	00 00 00 
	stat->st_isdir = 0;
  801352:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801359:	00 00 00 
	stat->st_dev = dev;
  80135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801365:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801369:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136c:	89 14 24             	mov    %edx,(%esp)
  80136f:	ff 50 14             	call   *0x14(%eax)
}
  801372:	83 c4 24             	add    $0x24,%esp
  801375:	5b                   	pop    %ebx
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	53                   	push   %ebx
  80137c:	83 ec 24             	sub    $0x24,%esp
  80137f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801382:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801385:	89 44 24 04          	mov    %eax,0x4(%esp)
  801389:	89 1c 24             	mov    %ebx,(%esp)
  80138c:	e8 8c fe ff ff       	call   80121d <fd_lookup>
  801391:	85 c0                	test   %eax,%eax
  801393:	78 5f                	js     8013f4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801395:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801398:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139f:	8b 00                	mov    (%eax),%eax
  8013a1:	89 04 24             	mov    %eax,(%esp)
  8013a4:	e8 e8 fe ff ff       	call   801291 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	78 47                	js     8013f4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8013b4:	75 23                	jne    8013d9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013bb:	8b 40 48             	mov    0x48(%eax),%eax
  8013be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c6:	c7 04 24 d4 22 80 00 	movl   $0x8022d4,(%esp)
  8013cd:	e8 4b ee ff ff       	call   80021d <cprintf>
  8013d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013d7:	eb 1b                	jmp    8013f4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8013d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013dc:	8b 48 18             	mov    0x18(%eax),%ecx
  8013df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e4:	85 c9                	test   %ecx,%ecx
  8013e6:	74 0c                	je     8013f4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ef:	89 14 24             	mov    %edx,(%esp)
  8013f2:	ff d1                	call   *%ecx
}
  8013f4:	83 c4 24             	add    $0x24,%esp
  8013f7:	5b                   	pop    %ebx
  8013f8:	5d                   	pop    %ebp
  8013f9:	c3                   	ret    

008013fa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	53                   	push   %ebx
  8013fe:	83 ec 24             	sub    $0x24,%esp
  801401:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801404:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801407:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140b:	89 1c 24             	mov    %ebx,(%esp)
  80140e:	e8 0a fe ff ff       	call   80121d <fd_lookup>
  801413:	85 c0                	test   %eax,%eax
  801415:	78 66                	js     80147d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801417:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80141a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801421:	8b 00                	mov    (%eax),%eax
  801423:	89 04 24             	mov    %eax,(%esp)
  801426:	e8 66 fe ff ff       	call   801291 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 4e                	js     80147d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80142f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801432:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801436:	75 23                	jne    80145b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801438:	a1 04 40 80 00       	mov    0x804004,%eax
  80143d:	8b 40 48             	mov    0x48(%eax),%eax
  801440:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801444:	89 44 24 04          	mov    %eax,0x4(%esp)
  801448:	c7 04 24 f8 22 80 00 	movl   $0x8022f8,(%esp)
  80144f:	e8 c9 ed ff ff       	call   80021d <cprintf>
  801454:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801459:	eb 22                	jmp    80147d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80145b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801461:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801466:	85 c9                	test   %ecx,%ecx
  801468:	74 13                	je     80147d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146a:	8b 45 10             	mov    0x10(%ebp),%eax
  80146d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801471:	8b 45 0c             	mov    0xc(%ebp),%eax
  801474:	89 44 24 04          	mov    %eax,0x4(%esp)
  801478:	89 14 24             	mov    %edx,(%esp)
  80147b:	ff d1                	call   *%ecx
}
  80147d:	83 c4 24             	add    $0x24,%esp
  801480:	5b                   	pop    %ebx
  801481:	5d                   	pop    %ebp
  801482:	c3                   	ret    

00801483 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801483:	55                   	push   %ebp
  801484:	89 e5                	mov    %esp,%ebp
  801486:	53                   	push   %ebx
  801487:	83 ec 24             	sub    $0x24,%esp
  80148a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801490:	89 44 24 04          	mov    %eax,0x4(%esp)
  801494:	89 1c 24             	mov    %ebx,(%esp)
  801497:	e8 81 fd ff ff       	call   80121d <fd_lookup>
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 6b                	js     80150b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014aa:	8b 00                	mov    (%eax),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 dd fd ff ff       	call   801291 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 53                	js     80150b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014bb:	8b 42 08             	mov    0x8(%edx),%eax
  8014be:	83 e0 03             	and    $0x3,%eax
  8014c1:	83 f8 01             	cmp    $0x1,%eax
  8014c4:	75 23                	jne    8014e9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014cb:	8b 40 48             	mov    0x48(%eax),%eax
  8014ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d6:	c7 04 24 15 23 80 00 	movl   $0x802315,(%esp)
  8014dd:	e8 3b ed ff ff       	call   80021d <cprintf>
  8014e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014e7:	eb 22                	jmp    80150b <read+0x88>
	}
	if (!dev->dev_read)
  8014e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ec:	8b 48 08             	mov    0x8(%eax),%ecx
  8014ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014f4:	85 c9                	test   %ecx,%ecx
  8014f6:	74 13                	je     80150b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8014fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801502:	89 44 24 04          	mov    %eax,0x4(%esp)
  801506:	89 14 24             	mov    %edx,(%esp)
  801509:	ff d1                	call   *%ecx
}
  80150b:	83 c4 24             	add    $0x24,%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5d                   	pop    %ebp
  801510:	c3                   	ret    

00801511 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801511:	55                   	push   %ebp
  801512:	89 e5                	mov    %esp,%ebp
  801514:	57                   	push   %edi
  801515:	56                   	push   %esi
  801516:	53                   	push   %ebx
  801517:	83 ec 1c             	sub    $0x1c,%esp
  80151a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152a:	b8 00 00 00 00       	mov    $0x0,%eax
  80152f:	85 f6                	test   %esi,%esi
  801531:	74 29                	je     80155c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801533:	89 f0                	mov    %esi,%eax
  801535:	29 d0                	sub    %edx,%eax
  801537:	89 44 24 08          	mov    %eax,0x8(%esp)
  80153b:	03 55 0c             	add    0xc(%ebp),%edx
  80153e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801542:	89 3c 24             	mov    %edi,(%esp)
  801545:	e8 39 ff ff ff       	call   801483 <read>
		if (m < 0)
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 0e                	js     80155c <readn+0x4b>
			return m;
		if (m == 0)
  80154e:	85 c0                	test   %eax,%eax
  801550:	74 08                	je     80155a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801552:	01 c3                	add    %eax,%ebx
  801554:	89 da                	mov    %ebx,%edx
  801556:	39 f3                	cmp    %esi,%ebx
  801558:	72 d9                	jb     801533 <readn+0x22>
  80155a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80155c:	83 c4 1c             	add    $0x1c,%esp
  80155f:	5b                   	pop    %ebx
  801560:	5e                   	pop    %esi
  801561:	5f                   	pop    %edi
  801562:	5d                   	pop    %ebp
  801563:	c3                   	ret    

00801564 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801564:	55                   	push   %ebp
  801565:	89 e5                	mov    %esp,%ebp
  801567:	83 ec 28             	sub    $0x28,%esp
  80156a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80156d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801570:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801573:	89 34 24             	mov    %esi,(%esp)
  801576:	e8 05 fc ff ff       	call   801180 <fd2num>
  80157b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80157e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801582:	89 04 24             	mov    %eax,(%esp)
  801585:	e8 93 fc ff ff       	call   80121d <fd_lookup>
  80158a:	89 c3                	mov    %eax,%ebx
  80158c:	85 c0                	test   %eax,%eax
  80158e:	78 05                	js     801595 <fd_close+0x31>
  801590:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801593:	74 0e                	je     8015a3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801595:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801599:	b8 00 00 00 00       	mov    $0x0,%eax
  80159e:	0f 44 d8             	cmove  %eax,%ebx
  8015a1:	eb 3d                	jmp    8015e0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015aa:	8b 06                	mov    (%esi),%eax
  8015ac:	89 04 24             	mov    %eax,(%esp)
  8015af:	e8 dd fc ff ff       	call   801291 <dev_lookup>
  8015b4:	89 c3                	mov    %eax,%ebx
  8015b6:	85 c0                	test   %eax,%eax
  8015b8:	78 16                	js     8015d0 <fd_close+0x6c>
		if (dev->dev_close)
  8015ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015bd:	8b 40 10             	mov    0x10(%eax),%eax
  8015c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	74 07                	je     8015d0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8015c9:	89 34 24             	mov    %esi,(%esp)
  8015cc:	ff d0                	call   *%eax
  8015ce:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015db:	e8 f9 f8 ff ff       	call   800ed9 <sys_page_unmap>
	return r;
}
  8015e0:	89 d8                	mov    %ebx,%eax
  8015e2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015e5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015e8:	89 ec                	mov    %ebp,%esp
  8015ea:	5d                   	pop    %ebp
  8015eb:	c3                   	ret    

008015ec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fc:	89 04 24             	mov    %eax,(%esp)
  8015ff:	e8 19 fc ff ff       	call   80121d <fd_lookup>
  801604:	85 c0                	test   %eax,%eax
  801606:	78 13                	js     80161b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801608:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80160f:	00 
  801610:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801613:	89 04 24             	mov    %eax,(%esp)
  801616:	e8 49 ff ff ff       	call   801564 <fd_close>
}
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 18             	sub    $0x18,%esp
  801623:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801626:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801629:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801630:	00 
  801631:	8b 45 08             	mov    0x8(%ebp),%eax
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	e8 78 03 00 00       	call   8019b4 <open>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 1b                	js     80165d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801642:	8b 45 0c             	mov    0xc(%ebp),%eax
  801645:	89 44 24 04          	mov    %eax,0x4(%esp)
  801649:	89 1c 24             	mov    %ebx,(%esp)
  80164c:	e8 ae fc ff ff       	call   8012ff <fstat>
  801651:	89 c6                	mov    %eax,%esi
	close(fd);
  801653:	89 1c 24             	mov    %ebx,(%esp)
  801656:	e8 91 ff ff ff       	call   8015ec <close>
  80165b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80165d:	89 d8                	mov    %ebx,%eax
  80165f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801662:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801665:	89 ec                	mov    %ebp,%esp
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	53                   	push   %ebx
  80166d:	83 ec 14             	sub    $0x14,%esp
  801670:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801675:	89 1c 24             	mov    %ebx,(%esp)
  801678:	e8 6f ff ff ff       	call   8015ec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80167d:	83 c3 01             	add    $0x1,%ebx
  801680:	83 fb 20             	cmp    $0x20,%ebx
  801683:	75 f0                	jne    801675 <close_all+0xc>
		close(i);
}
  801685:	83 c4 14             	add    $0x14,%esp
  801688:	5b                   	pop    %ebx
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	83 ec 58             	sub    $0x58,%esp
  801691:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801694:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801697:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80169a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80169d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	89 04 24             	mov    %eax,(%esp)
  8016aa:	e8 6e fb ff ff       	call   80121d <fd_lookup>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	0f 88 e0 00 00 00    	js     801799 <dup+0x10e>
		return r;
	close(newfdnum);
  8016b9:	89 3c 24             	mov    %edi,(%esp)
  8016bc:	e8 2b ff ff ff       	call   8015ec <close>

	newfd = INDEX2FD(newfdnum);
  8016c1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8016c7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8016ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016cd:	89 04 24             	mov    %eax,(%esp)
  8016d0:	e8 bb fa ff ff       	call   801190 <fd2data>
  8016d5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016d7:	89 34 24             	mov    %esi,(%esp)
  8016da:	e8 b1 fa ff ff       	call   801190 <fd2data>
  8016df:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8016e2:	89 da                	mov    %ebx,%edx
  8016e4:	89 d8                	mov    %ebx,%eax
  8016e6:	c1 e8 16             	shr    $0x16,%eax
  8016e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016f0:	a8 01                	test   $0x1,%al
  8016f2:	74 43                	je     801737 <dup+0xac>
  8016f4:	c1 ea 0c             	shr    $0xc,%edx
  8016f7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016fe:	a8 01                	test   $0x1,%al
  801700:	74 35                	je     801737 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801702:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801709:	25 07 0e 00 00       	and    $0xe07,%eax
  80170e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801712:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801715:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801719:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801720:	00 
  801721:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801725:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172c:	e8 e0 f7 ff ff       	call   800f11 <sys_page_map>
  801731:	89 c3                	mov    %eax,%ebx
  801733:	85 c0                	test   %eax,%eax
  801735:	78 3f                	js     801776 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801737:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173a:	89 c2                	mov    %eax,%edx
  80173c:	c1 ea 0c             	shr    $0xc,%edx
  80173f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801746:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80174c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801750:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801754:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80175b:	00 
  80175c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801760:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801767:	e8 a5 f7 ff ff       	call   800f11 <sys_page_map>
  80176c:	89 c3                	mov    %eax,%ebx
  80176e:	85 c0                	test   %eax,%eax
  801770:	78 04                	js     801776 <dup+0xeb>
  801772:	89 fb                	mov    %edi,%ebx
  801774:	eb 23                	jmp    801799 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80177a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801781:	e8 53 f7 ff ff       	call   800ed9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801786:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801789:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801794:	e8 40 f7 ff ff       	call   800ed9 <sys_page_unmap>
	return r;
}
  801799:	89 d8                	mov    %ebx,%eax
  80179b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80179e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8017a1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8017a4:	89 ec                	mov    %ebp,%esp
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	83 ec 18             	sub    $0x18,%esp
  8017ae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8017b1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8017b8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017bf:	75 11                	jne    8017d2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8017c8:	e8 a3 02 00 00       	call   801a70 <ipc_find_env>
  8017cd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017d9:	00 
  8017da:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8017e1:	00 
  8017e2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017e6:	a1 00 40 80 00       	mov    0x804000,%eax
  8017eb:	89 04 24             	mov    %eax,(%esp)
  8017ee:	e8 c1 02 00 00       	call   801ab4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fa:	00 
  8017fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801806:	e8 18 03 00 00       	call   801b23 <ipc_recv>
}
  80180b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80180e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801811:	89 ec                	mov    %ebp,%esp
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80181b:	8b 45 08             	mov    0x8(%ebp),%eax
  80181e:	8b 40 0c             	mov    0xc(%eax),%eax
  801821:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801826:	8b 45 0c             	mov    0xc(%ebp),%eax
  801829:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80182e:	ba 00 00 00 00       	mov    $0x0,%edx
  801833:	b8 02 00 00 00       	mov    $0x2,%eax
  801838:	e8 6b ff ff ff       	call   8017a8 <fsipc>
}
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    

0080183f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801845:	8b 45 08             	mov    0x8(%ebp),%eax
  801848:	8b 40 0c             	mov    0xc(%eax),%eax
  80184b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801850:	ba 00 00 00 00       	mov    $0x0,%edx
  801855:	b8 06 00 00 00       	mov    $0x6,%eax
  80185a:	e8 49 ff ff ff       	call   8017a8 <fsipc>
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801867:	ba 00 00 00 00       	mov    $0x0,%edx
  80186c:	b8 08 00 00 00       	mov    $0x8,%eax
  801871:	e8 32 ff ff ff       	call   8017a8 <fsipc>
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 14             	sub    $0x14,%esp
  80187f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 40 0c             	mov    0xc(%eax),%eax
  801888:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80188d:	ba 00 00 00 00       	mov    $0x0,%edx
  801892:	b8 05 00 00 00       	mov    $0x5,%eax
  801897:	e8 0c ff ff ff       	call   8017a8 <fsipc>
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 2b                	js     8018cb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8018a7:	00 
  8018a8:	89 1c 24             	mov    %ebx,(%esp)
  8018ab:	e8 aa f0 ff ff       	call   80095a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b0:	a1 80 50 80 00       	mov    0x805080,%eax
  8018b5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018bb:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8018c6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8018cb:	83 c4 14             	add    $0x14,%esp
  8018ce:	5b                   	pop    %ebx
  8018cf:	5d                   	pop    %ebp
  8018d0:	c3                   	ret    

008018d1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 18             	sub    $0x18,%esp
  8018d7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018da:	8b 55 08             	mov    0x8(%ebp),%edx
  8018dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  8018e6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  8018eb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018f0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018f5:	0f 47 c2             	cmova  %edx,%eax
  8018f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801903:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80190a:	e8 36 f2 ff ff       	call   800b45 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	b8 04 00 00 00       	mov    $0x4,%eax
  801919:	e8 8a fe ff ff       	call   8017a8 <fsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	8b 40 0c             	mov    0xc(%eax),%eax
  80192d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801932:	8b 45 10             	mov    0x10(%ebp),%eax
  801935:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80193a:	ba 00 00 00 00       	mov    $0x0,%edx
  80193f:	b8 03 00 00 00       	mov    $0x3,%eax
  801944:	e8 5f fe ff ff       	call   8017a8 <fsipc>
  801949:	89 c3                	mov    %eax,%ebx
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 17                	js     801966 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801953:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80195a:	00 
  80195b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195e:	89 04 24             	mov    %eax,(%esp)
  801961:	e8 df f1 ff ff       	call   800b45 <memmove>
  return r;	
}
  801966:	89 d8                	mov    %ebx,%eax
  801968:	83 c4 14             	add    $0x14,%esp
  80196b:	5b                   	pop    %ebx
  80196c:	5d                   	pop    %ebp
  80196d:	c3                   	ret    

0080196e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	53                   	push   %ebx
  801972:	83 ec 14             	sub    $0x14,%esp
  801975:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801978:	89 1c 24             	mov    %ebx,(%esp)
  80197b:	e8 90 ef ff ff       	call   800910 <strlen>
  801980:	89 c2                	mov    %eax,%edx
  801982:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801987:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80198d:	7f 1f                	jg     8019ae <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80198f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801993:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80199a:	e8 bb ef ff ff       	call   80095a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a4:	b8 07 00 00 00       	mov    $0x7,%eax
  8019a9:	e8 fa fd ff ff       	call   8017a8 <fsipc>
}
  8019ae:	83 c4 14             	add    $0x14,%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5d                   	pop    %ebp
  8019b3:	c3                   	ret    

008019b4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 28             	sub    $0x28,%esp
  8019ba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019bd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8019c0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8019c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c6:	89 04 24             	mov    %eax,(%esp)
  8019c9:	e8 dd f7 ff ff       	call   8011ab <fd_alloc>
  8019ce:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	0f 88 89 00 00 00    	js     801a61 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8019d8:	89 34 24             	mov    %esi,(%esp)
  8019db:	e8 30 ef ff ff       	call   800910 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8019e0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8019e5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ea:	7f 75                	jg     801a61 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8019ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019f7:	e8 5e ef ff ff       	call   80095a <strcpy>
  fsipcbuf.open.req_omode = mode;
  8019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ff:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801a04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a07:	b8 01 00 00 00       	mov    $0x1,%eax
  801a0c:	e8 97 fd ff ff       	call   8017a8 <fsipc>
  801a11:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801a13:	85 c0                	test   %eax,%eax
  801a15:	78 0f                	js     801a26 <open+0x72>
  return fd2num(fd);
  801a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1a:	89 04 24             	mov    %eax,(%esp)
  801a1d:	e8 5e f7 ff ff       	call   801180 <fd2num>
  801a22:	89 c3                	mov    %eax,%ebx
  801a24:	eb 3b                	jmp    801a61 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801a26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a2d:	00 
  801a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a31:	89 04 24             	mov    %eax,(%esp)
  801a34:	e8 2b fb ff ff       	call   801564 <fd_close>
  801a39:	85 c0                	test   %eax,%eax
  801a3b:	74 24                	je     801a61 <open+0xad>
  801a3d:	c7 44 24 0c 3c 23 80 	movl   $0x80233c,0xc(%esp)
  801a44:	00 
  801a45:	c7 44 24 08 51 23 80 	movl   $0x802351,0x8(%esp)
  801a4c:	00 
  801a4d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801a54:	00 
  801a55:	c7 04 24 66 23 80 00 	movl   $0x802366,(%esp)
  801a5c:	e8 03 e7 ff ff       	call   800164 <_panic>
  return r;
}
  801a61:	89 d8                	mov    %ebx,%eax
  801a63:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a66:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a69:	89 ec                	mov    %ebp,%esp
  801a6b:	5d                   	pop    %ebp
  801a6c:	c3                   	ret    
  801a6d:	00 00                	add    %al,(%eax)
	...

00801a70 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a76:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801a7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a81:	39 ca                	cmp    %ecx,%edx
  801a83:	75 04                	jne    801a89 <ipc_find_env+0x19>
  801a85:	b0 00                	mov    $0x0,%al
  801a87:	eb 0f                	jmp    801a98 <ipc_find_env+0x28>
  801a89:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a8c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801a92:	8b 12                	mov    (%edx),%edx
  801a94:	39 ca                	cmp    %ecx,%edx
  801a96:	75 0c                	jne    801aa4 <ipc_find_env+0x34>
			return envs[i].env_id;
  801a98:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a9b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801aa0:	8b 00                	mov    (%eax),%eax
  801aa2:	eb 0e                	jmp    801ab2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aa4:	83 c0 01             	add    $0x1,%eax
  801aa7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aac:	75 db                	jne    801a89 <ipc_find_env+0x19>
  801aae:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	57                   	push   %edi
  801ab8:	56                   	push   %esi
  801ab9:	53                   	push   %ebx
  801aba:	83 ec 1c             	sub    $0x1c,%esp
  801abd:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801ac6:	85 db                	test   %ebx,%ebx
  801ac8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801acd:	0f 44 d8             	cmove  %eax,%ebx
  801ad0:	eb 29                	jmp    801afb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801ad2:	85 c0                	test   %eax,%eax
  801ad4:	79 25                	jns    801afb <ipc_send+0x47>
  801ad6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad9:	74 20                	je     801afb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801adb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801adf:	c7 44 24 08 71 23 80 	movl   $0x802371,0x8(%esp)
  801ae6:	00 
  801ae7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801aee:	00 
  801aef:	c7 04 24 8f 23 80 00 	movl   $0x80238f,(%esp)
  801af6:	e8 69 e6 ff ff       	call   800164 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801afb:	8b 45 14             	mov    0x14(%ebp),%eax
  801afe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b02:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b06:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b0a:	89 34 24             	mov    %esi,(%esp)
  801b0d:	e8 e9 f2 ff ff       	call   800dfb <sys_ipc_try_send>
  801b12:	85 c0                	test   %eax,%eax
  801b14:	75 bc                	jne    801ad2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801b16:	e8 66 f4 ff ff       	call   800f81 <sys_yield>
}
  801b1b:	83 c4 1c             	add    $0x1c,%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	83 ec 28             	sub    $0x28,%esp
  801b29:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801b2c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b2f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b32:	8b 75 08             	mov    0x8(%ebp),%esi
  801b35:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b38:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b42:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801b45:	89 04 24             	mov    %eax,(%esp)
  801b48:	e8 75 f2 ff ff       	call   800dc2 <sys_ipc_recv>
  801b4d:	89 c3                	mov    %eax,%ebx
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	79 2a                	jns    801b7d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801b53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5b:	c7 04 24 99 23 80 00 	movl   $0x802399,(%esp)
  801b62:	e8 b6 e6 ff ff       	call   80021d <cprintf>
		if(from_env_store != NULL)
  801b67:	85 f6                	test   %esi,%esi
  801b69:	74 06                	je     801b71 <ipc_recv+0x4e>
			*from_env_store = 0;
  801b6b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b71:	85 ff                	test   %edi,%edi
  801b73:	74 2d                	je     801ba2 <ipc_recv+0x7f>
			*perm_store = 0;
  801b75:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b7b:	eb 25                	jmp    801ba2 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801b7d:	85 f6                	test   %esi,%esi
  801b7f:	90                   	nop
  801b80:	74 0a                	je     801b8c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801b82:	a1 04 40 80 00       	mov    0x804004,%eax
  801b87:	8b 40 74             	mov    0x74(%eax),%eax
  801b8a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b8c:	85 ff                	test   %edi,%edi
  801b8e:	74 0a                	je     801b9a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801b90:	a1 04 40 80 00       	mov    0x804004,%eax
  801b95:	8b 40 78             	mov    0x78(%eax),%eax
  801b98:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b9a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801ba2:	89 d8                	mov    %ebx,%eax
  801ba4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ba7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801baa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801bad:	89 ec                	mov    %ebp,%esp
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    
	...

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	57                   	push   %edi
  801bc4:	56                   	push   %esi
  801bc5:	83 ec 10             	sub    $0x10,%esp
  801bc8:	8b 45 14             	mov    0x14(%ebp),%eax
  801bcb:	8b 55 08             	mov    0x8(%ebp),%edx
  801bce:	8b 75 10             	mov    0x10(%ebp),%esi
  801bd1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801bd9:	75 35                	jne    801c10 <__udivdi3+0x50>
  801bdb:	39 fe                	cmp    %edi,%esi
  801bdd:	77 61                	ja     801c40 <__udivdi3+0x80>
  801bdf:	85 f6                	test   %esi,%esi
  801be1:	75 0b                	jne    801bee <__udivdi3+0x2e>
  801be3:	b8 01 00 00 00       	mov    $0x1,%eax
  801be8:	31 d2                	xor    %edx,%edx
  801bea:	f7 f6                	div    %esi
  801bec:	89 c6                	mov    %eax,%esi
  801bee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801bf1:	31 d2                	xor    %edx,%edx
  801bf3:	89 f8                	mov    %edi,%eax
  801bf5:	f7 f6                	div    %esi
  801bf7:	89 c7                	mov    %eax,%edi
  801bf9:	89 c8                	mov    %ecx,%eax
  801bfb:	f7 f6                	div    %esi
  801bfd:	89 c1                	mov    %eax,%ecx
  801bff:	89 fa                	mov    %edi,%edx
  801c01:	89 c8                	mov    %ecx,%eax
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	5e                   	pop    %esi
  801c07:	5f                   	pop    %edi
  801c08:	5d                   	pop    %ebp
  801c09:	c3                   	ret    
  801c0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c10:	39 f8                	cmp    %edi,%eax
  801c12:	77 1c                	ja     801c30 <__udivdi3+0x70>
  801c14:	0f bd d0             	bsr    %eax,%edx
  801c17:	83 f2 1f             	xor    $0x1f,%edx
  801c1a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c1d:	75 39                	jne    801c58 <__udivdi3+0x98>
  801c1f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801c22:	0f 86 a0 00 00 00    	jbe    801cc8 <__udivdi3+0x108>
  801c28:	39 f8                	cmp    %edi,%eax
  801c2a:	0f 82 98 00 00 00    	jb     801cc8 <__udivdi3+0x108>
  801c30:	31 ff                	xor    %edi,%edi
  801c32:	31 c9                	xor    %ecx,%ecx
  801c34:	89 c8                	mov    %ecx,%eax
  801c36:	89 fa                	mov    %edi,%edx
  801c38:	83 c4 10             	add    $0x10,%esp
  801c3b:	5e                   	pop    %esi
  801c3c:	5f                   	pop    %edi
  801c3d:	5d                   	pop    %ebp
  801c3e:	c3                   	ret    
  801c3f:	90                   	nop
  801c40:	89 d1                	mov    %edx,%ecx
  801c42:	89 fa                	mov    %edi,%edx
  801c44:	89 c8                	mov    %ecx,%eax
  801c46:	31 ff                	xor    %edi,%edi
  801c48:	f7 f6                	div    %esi
  801c4a:	89 c1                	mov    %eax,%ecx
  801c4c:	89 fa                	mov    %edi,%edx
  801c4e:	89 c8                	mov    %ecx,%eax
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    
  801c57:	90                   	nop
  801c58:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c5c:	89 f2                	mov    %esi,%edx
  801c5e:	d3 e0                	shl    %cl,%eax
  801c60:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c63:	b8 20 00 00 00       	mov    $0x20,%eax
  801c68:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801c6b:	89 c1                	mov    %eax,%ecx
  801c6d:	d3 ea                	shr    %cl,%edx
  801c6f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c73:	0b 55 ec             	or     -0x14(%ebp),%edx
  801c76:	d3 e6                	shl    %cl,%esi
  801c78:	89 c1                	mov    %eax,%ecx
  801c7a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801c7d:	89 fe                	mov    %edi,%esi
  801c7f:	d3 ee                	shr    %cl,%esi
  801c81:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c85:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c8b:	d3 e7                	shl    %cl,%edi
  801c8d:	89 c1                	mov    %eax,%ecx
  801c8f:	d3 ea                	shr    %cl,%edx
  801c91:	09 d7                	or     %edx,%edi
  801c93:	89 f2                	mov    %esi,%edx
  801c95:	89 f8                	mov    %edi,%eax
  801c97:	f7 75 ec             	divl   -0x14(%ebp)
  801c9a:	89 d6                	mov    %edx,%esi
  801c9c:	89 c7                	mov    %eax,%edi
  801c9e:	f7 65 e8             	mull   -0x18(%ebp)
  801ca1:	39 d6                	cmp    %edx,%esi
  801ca3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801ca6:	72 30                	jb     801cd8 <__udivdi3+0x118>
  801ca8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801caf:	d3 e2                	shl    %cl,%edx
  801cb1:	39 c2                	cmp    %eax,%edx
  801cb3:	73 05                	jae    801cba <__udivdi3+0xfa>
  801cb5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801cb8:	74 1e                	je     801cd8 <__udivdi3+0x118>
  801cba:	89 f9                	mov    %edi,%ecx
  801cbc:	31 ff                	xor    %edi,%edi
  801cbe:	e9 71 ff ff ff       	jmp    801c34 <__udivdi3+0x74>
  801cc3:	90                   	nop
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	31 ff                	xor    %edi,%edi
  801cca:	b9 01 00 00 00       	mov    $0x1,%ecx
  801ccf:	e9 60 ff ff ff       	jmp    801c34 <__udivdi3+0x74>
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801cdb:	31 ff                	xor    %edi,%edi
  801cdd:	89 c8                	mov    %ecx,%eax
  801cdf:	89 fa                	mov    %edi,%edx
  801ce1:	83 c4 10             	add    $0x10,%esp
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
	...

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	57                   	push   %edi
  801cf4:	56                   	push   %esi
  801cf5:	83 ec 20             	sub    $0x20,%esp
  801cf8:	8b 55 14             	mov    0x14(%ebp),%edx
  801cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cfe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801d01:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d04:	85 d2                	test   %edx,%edx
  801d06:	89 c8                	mov    %ecx,%eax
  801d08:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801d0b:	75 13                	jne    801d20 <__umoddi3+0x30>
  801d0d:	39 f7                	cmp    %esi,%edi
  801d0f:	76 3f                	jbe    801d50 <__umoddi3+0x60>
  801d11:	89 f2                	mov    %esi,%edx
  801d13:	f7 f7                	div    %edi
  801d15:	89 d0                	mov    %edx,%eax
  801d17:	31 d2                	xor    %edx,%edx
  801d19:	83 c4 20             	add    $0x20,%esp
  801d1c:	5e                   	pop    %esi
  801d1d:	5f                   	pop    %edi
  801d1e:	5d                   	pop    %ebp
  801d1f:	c3                   	ret    
  801d20:	39 f2                	cmp    %esi,%edx
  801d22:	77 4c                	ja     801d70 <__umoddi3+0x80>
  801d24:	0f bd ca             	bsr    %edx,%ecx
  801d27:	83 f1 1f             	xor    $0x1f,%ecx
  801d2a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801d2d:	75 51                	jne    801d80 <__umoddi3+0x90>
  801d2f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801d32:	0f 87 e0 00 00 00    	ja     801e18 <__umoddi3+0x128>
  801d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3b:	29 f8                	sub    %edi,%eax
  801d3d:	19 d6                	sbb    %edx,%esi
  801d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801d42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d45:	89 f2                	mov    %esi,%edx
  801d47:	83 c4 20             	add    $0x20,%esp
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    
  801d4e:	66 90                	xchg   %ax,%ax
  801d50:	85 ff                	test   %edi,%edi
  801d52:	75 0b                	jne    801d5f <__umoddi3+0x6f>
  801d54:	b8 01 00 00 00       	mov    $0x1,%eax
  801d59:	31 d2                	xor    %edx,%edx
  801d5b:	f7 f7                	div    %edi
  801d5d:	89 c7                	mov    %eax,%edi
  801d5f:	89 f0                	mov    %esi,%eax
  801d61:	31 d2                	xor    %edx,%edx
  801d63:	f7 f7                	div    %edi
  801d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d68:	f7 f7                	div    %edi
  801d6a:	eb a9                	jmp    801d15 <__umoddi3+0x25>
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 20             	add    $0x20,%esp
  801d77:	5e                   	pop    %esi
  801d78:	5f                   	pop    %edi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    
  801d7b:	90                   	nop
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d84:	d3 e2                	shl    %cl,%edx
  801d86:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d89:	ba 20 00 00 00       	mov    $0x20,%edx
  801d8e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801d91:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d94:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d98:	89 fa                	mov    %edi,%edx
  801d9a:	d3 ea                	shr    %cl,%edx
  801d9c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801da0:	0b 55 f4             	or     -0xc(%ebp),%edx
  801da3:	d3 e7                	shl    %cl,%edi
  801da5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801da9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801dac:	89 f2                	mov    %esi,%edx
  801dae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801db1:	89 c7                	mov    %eax,%edi
  801db3:	d3 ea                	shr    %cl,%edx
  801db5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801db9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801dbc:	89 c2                	mov    %eax,%edx
  801dbe:	d3 e6                	shl    %cl,%esi
  801dc0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801dc4:	d3 ea                	shr    %cl,%edx
  801dc6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801dca:	09 d6                	or     %edx,%esi
  801dcc:	89 f0                	mov    %esi,%eax
  801dce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801dd1:	d3 e7                	shl    %cl,%edi
  801dd3:	89 f2                	mov    %esi,%edx
  801dd5:	f7 75 f4             	divl   -0xc(%ebp)
  801dd8:	89 d6                	mov    %edx,%esi
  801dda:	f7 65 e8             	mull   -0x18(%ebp)
  801ddd:	39 d6                	cmp    %edx,%esi
  801ddf:	72 2b                	jb     801e0c <__umoddi3+0x11c>
  801de1:	39 c7                	cmp    %eax,%edi
  801de3:	72 23                	jb     801e08 <__umoddi3+0x118>
  801de5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801de9:	29 c7                	sub    %eax,%edi
  801deb:	19 d6                	sbb    %edx,%esi
  801ded:	89 f0                	mov    %esi,%eax
  801def:	89 f2                	mov    %esi,%edx
  801df1:	d3 ef                	shr    %cl,%edi
  801df3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801df7:	d3 e0                	shl    %cl,%eax
  801df9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801dfd:	09 f8                	or     %edi,%eax
  801dff:	d3 ea                	shr    %cl,%edx
  801e01:	83 c4 20             	add    $0x20,%esp
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
  801e08:	39 d6                	cmp    %edx,%esi
  801e0a:	75 d9                	jne    801de5 <__umoddi3+0xf5>
  801e0c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801e0f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801e12:	eb d1                	jmp    801de5 <__umoddi3+0xf5>
  801e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e18:	39 f2                	cmp    %esi,%edx
  801e1a:	0f 82 18 ff ff ff    	jb     801d38 <__umoddi3+0x48>
  801e20:	e9 1d ff ff ff       	jmp    801d42 <__umoddi3+0x52>
