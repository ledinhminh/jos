
obj/user/testbss.debug:     file format elf32-i386


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
  80002c:	e8 eb 00 00 00       	call   80011c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  80003a:	c7 04 24 80 23 80 00 	movl   $0x802380,(%esp)
  800041:	e8 fb 01 00 00       	call   800241 <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800046:	b8 01 00 00 00       	mov    $0x1,%eax
  80004b:	ba 20 40 80 00       	mov    $0x804020,%edx
  800050:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  800057:	74 04                	je     80005d <umain+0x29>
  800059:	b0 00                	mov    $0x0,%al
  80005b:	eb 06                	jmp    800063 <umain+0x2f>
  80005d:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800061:	74 20                	je     800083 <umain+0x4f>
			panic("bigarray[%d] isn't cleared!\n", i);
  800063:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800067:	c7 44 24 08 fb 23 80 	movl   $0x8023fb,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 18 24 80 00 	movl   $0x802418,(%esp)
  80007e:	e8 05 01 00 00       	call   800188 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 d0                	jne    80005d <umain+0x29>
  80008d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800092:	ba 20 40 80 00       	mov    $0x804020,%edx
  800097:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80009a:	83 c0 01             	add    $0x1,%eax
  80009d:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a2:	75 f3                	jne    800097 <umain+0x63>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a9:	ba 20 40 80 00       	mov    $0x804020,%edx
  8000ae:	83 3d 20 40 80 00 00 	cmpl   $0x0,0x804020
  8000b5:	74 04                	je     8000bb <umain+0x87>
  8000b7:	b0 00                	mov    $0x0,%al
  8000b9:	eb 05                	jmp    8000c0 <umain+0x8c>
  8000bb:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  8000be:	74 20                	je     8000e0 <umain+0xac>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000c0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c4:	c7 44 24 08 a0 23 80 	movl   $0x8023a0,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 18 24 80 00 	movl   $0x802418,(%esp)
  8000db:	e8 a8 00 00 00       	call   800188 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000e0:	83 c0 01             	add    $0x1,%eax
  8000e3:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e8:	75 d1                	jne    8000bb <umain+0x87>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000ea:	c7 04 24 c8 23 80 00 	movl   $0x8023c8,(%esp)
  8000f1:	e8 4b 01 00 00       	call   800241 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f6:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000fd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800100:	c7 44 24 08 27 24 80 	movl   $0x802427,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 18 24 80 00 	movl   $0x802418,(%esp)
  800117:	e8 6c 00 00 00       	call   800188 <_panic>

0080011c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	83 ec 18             	sub    $0x18,%esp
  800122:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800125:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800128:	8b 75 08             	mov    0x8(%ebp),%esi
  80012b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80012e:	e8 54 0f 00 00       	call   801087 <sys_getenvid>
  800133:	25 ff 03 00 00       	and    $0x3ff,%eax
  800138:	c1 e0 07             	shl    $0x7,%eax
  80013b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800140:	a3 20 40 c0 00       	mov    %eax,0xc04020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800145:	85 f6                	test   %esi,%esi
  800147:	7e 07                	jle    800150 <libmain+0x34>
		binaryname = argv[0];
  800149:	8b 03                	mov    (%ebx),%eax
  80014b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800150:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800154:	89 34 24             	mov    %esi,(%esp)
  800157:	e8 d8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80015c:	e8 0b 00 00 00       	call   80016c <exit>
}
  800161:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800164:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800167:	89 ec                	mov    %ebp,%esp
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    
	...

0080016c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800172:	e8 e2 14 00 00       	call   801659 <close_all>
	sys_env_destroy(0);
  800177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017e:	e8 3f 0f 00 00       	call   8010c2 <sys_env_destroy>
}
  800183:	c9                   	leave  
  800184:	c3                   	ret    
  800185:	00 00                	add    %al,(%eax)
	...

00800188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800190:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800193:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800199:	e8 e9 0e 00 00       	call   801087 <sys_getenvid>
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 48 24 80 00 	movl   $0x802448,(%esp)
  8001bb:	e8 81 00 00 00       	call   800241 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 11 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  8001cf:	c7 04 24 16 24 80 00 	movl   $0x802416,(%esp)
  8001d6:	e8 66 00 00 00       	call   800241 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001db:	cc                   	int3   
  8001dc:	eb fd                	jmp    8001db <_panic+0x53>
	...

008001e0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800200:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800204:	8b 45 08             	mov    0x8(%ebp),%eax
  800207:	89 44 24 08          	mov    %eax,0x8(%esp)
  80020b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800211:	89 44 24 04          	mov    %eax,0x4(%esp)
  800215:	c7 04 24 5b 02 80 00 	movl   $0x80025b,(%esp)
  80021c:	e8 cc 01 00 00       	call   8003ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800221:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800227:	89 44 24 04          	mov    %eax,0x4(%esp)
  80022b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800231:	89 04 24             	mov    %eax,(%esp)
  800234:	e8 fd 0e 00 00       	call   801136 <sys_cputs>

	return b.cnt;
}
  800239:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023f:	c9                   	leave  
  800240:	c3                   	ret    

00800241 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800241:	55                   	push   %ebp
  800242:	89 e5                	mov    %esp,%ebp
  800244:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800247:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80024a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024e:	8b 45 08             	mov    0x8(%ebp),%eax
  800251:	89 04 24             	mov    %eax,(%esp)
  800254:	e8 87 ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800259:	c9                   	leave  
  80025a:	c3                   	ret    

0080025b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	53                   	push   %ebx
  80025f:	83 ec 14             	sub    $0x14,%esp
  800262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800265:	8b 03                	mov    (%ebx),%eax
  800267:	8b 55 08             	mov    0x8(%ebp),%edx
  80026a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80026e:	83 c0 01             	add    $0x1,%eax
  800271:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800273:	3d ff 00 00 00       	cmp    $0xff,%eax
  800278:	75 19                	jne    800293 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80027a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800281:	00 
  800282:	8d 43 08             	lea    0x8(%ebx),%eax
  800285:	89 04 24             	mov    %eax,(%esp)
  800288:	e8 a9 0e 00 00       	call   801136 <sys_cputs>
		b->idx = 0;
  80028d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800293:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800297:	83 c4 14             	add    $0x14,%esp
  80029a:	5b                   	pop    %ebx
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    
  80029d:	00 00                	add    %al,(%eax)
	...

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 4c             	sub    $0x4c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002cb:	39 d1                	cmp    %edx,%ecx
  8002cd:	72 15                	jb     8002e4 <printnum+0x44>
  8002cf:	77 07                	ja     8002d8 <printnum+0x38>
  8002d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d4:	39 d0                	cmp    %edx,%eax
  8002d6:	76 0c                	jbe    8002e4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d8:	83 eb 01             	sub    $0x1,%ebx
  8002db:	85 db                	test   %ebx,%ebx
  8002dd:	8d 76 00             	lea    0x0(%esi),%esi
  8002e0:	7f 61                	jg     800343 <printnum+0xa3>
  8002e2:	eb 70                	jmp    800354 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002e8:	83 eb 01             	sub    $0x1,%ebx
  8002eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002f7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002fe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800301:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800304:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800308:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030f:	00 
  800310:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800319:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031d:	e8 de 1d 00 00       	call   802100 <__udivdi3>
  800322:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800325:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	89 54 24 04          	mov    %edx,0x4(%esp)
  800337:	89 f2                	mov    %esi,%edx
  800339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033c:	e8 5f ff ff ff       	call   8002a0 <printnum>
  800341:	eb 11                	jmp    800354 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800343:	89 74 24 04          	mov    %esi,0x4(%esp)
  800347:	89 3c 24             	mov    %edi,(%esp)
  80034a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034d:	83 eb 01             	sub    $0x1,%ebx
  800350:	85 db                	test   %ebx,%ebx
  800352:	7f ef                	jg     800343 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800354:	89 74 24 04          	mov    %esi,0x4(%esp)
  800358:	8b 74 24 04          	mov    0x4(%esp),%esi
  80035c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036a:	00 
  80036b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80036e:	89 14 24             	mov    %edx,(%esp)
  800371:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800374:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800378:	e8 b3 1e 00 00       	call   802230 <__umoddi3>
  80037d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800381:	0f be 80 6b 24 80 00 	movsbl 0x80246b(%eax),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038e:	83 c4 4c             	add    $0x4c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800399:	83 fa 01             	cmp    $0x1,%edx
  80039c:	7e 0e                	jle    8003ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	8b 52 04             	mov    0x4(%edx),%edx
  8003aa:	eb 22                	jmp    8003ce <getuint+0x38>
	else if (lflag)
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 10                	je     8003c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003be:	eb 0e                	jmp    8003ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003df:	73 0a                	jae    8003eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e4:	88 0a                	mov    %cl,(%edx)
  8003e6:	83 c2 01             	add    $0x1,%edx
  8003e9:	89 10                	mov    %edx,(%eax)
}
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	57                   	push   %edi
  8003f1:	56                   	push   %esi
  8003f2:	53                   	push   %ebx
  8003f3:	83 ec 5c             	sub    $0x5c,%esp
  8003f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ff:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800406:	eb 11                	jmp    800419 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800408:	85 c0                	test   %eax,%eax
  80040a:	0f 84 68 04 00 00    	je     800878 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800410:	89 74 24 04          	mov    %esi,0x4(%esp)
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800419:	0f b6 03             	movzbl (%ebx),%eax
  80041c:	83 c3 01             	add    $0x1,%ebx
  80041f:	83 f8 25             	cmp    $0x25,%eax
  800422:	75 e4                	jne    800408 <vprintfmt+0x1b>
  800424:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80042b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800432:	b9 00 00 00 00       	mov    $0x0,%ecx
  800437:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80043b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800442:	eb 06                	jmp    80044a <vprintfmt+0x5d>
  800444:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800448:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	0f b6 13             	movzbl (%ebx),%edx
  80044d:	0f b6 c2             	movzbl %dl,%eax
  800450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800453:	8d 43 01             	lea    0x1(%ebx),%eax
  800456:	83 ea 23             	sub    $0x23,%edx
  800459:	80 fa 55             	cmp    $0x55,%dl
  80045c:	0f 87 f9 03 00 00    	ja     80085b <vprintfmt+0x46e>
  800462:	0f b6 d2             	movzbl %dl,%edx
  800465:	ff 24 95 40 26 80 00 	jmp    *0x802640(,%edx,4)
  80046c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800470:	eb d6                	jmp    800448 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800472:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800475:	83 ea 30             	sub    $0x30,%edx
  800478:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80047b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80047e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800481:	83 fb 09             	cmp    $0x9,%ebx
  800484:	77 54                	ja     8004da <vprintfmt+0xed>
  800486:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800489:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80048f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800492:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800496:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800499:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80049c:	83 fb 09             	cmp    $0x9,%ebx
  80049f:	76 eb                	jbe    80048c <vprintfmt+0x9f>
  8004a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a7:	eb 31                	jmp    8004da <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ac:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004af:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004b2:	8b 12                	mov    (%edx),%edx
  8004b4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004b7:	eb 21                	jmp    8004da <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8004b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8004c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004c9:	e9 7a ff ff ff       	jmp    800448 <vprintfmt+0x5b>
  8004ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004d5:	e9 6e ff ff ff       	jmp    800448 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004de:	0f 89 64 ff ff ff    	jns    800448 <vprintfmt+0x5b>
  8004e4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004ea:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004f0:	e9 53 ff ff ff       	jmp    800448 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004f8:	e9 4b ff ff ff       	jmp    800448 <vprintfmt+0x5b>
  8004fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	89 74 24 04          	mov    %esi,0x4(%esp)
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff d7                	call   *%edi
  800514:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800517:	e9 fd fe ff ff       	jmp    800419 <vprintfmt+0x2c>
  80051c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	89 c2                	mov    %eax,%edx
  80052c:	c1 fa 1f             	sar    $0x1f,%edx
  80052f:	31 d0                	xor    %edx,%eax
  800531:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800533:	83 f8 0f             	cmp    $0xf,%eax
  800536:	7f 0b                	jg     800543 <vprintfmt+0x156>
  800538:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  80053f:	85 d2                	test   %edx,%edx
  800541:	75 20                	jne    800563 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800547:	c7 44 24 08 7c 24 80 	movl   $0x80247c,0x8(%esp)
  80054e:	00 
  80054f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800553:	89 3c 24             	mov    %edi,(%esp)
  800556:	e8 a5 03 00 00       	call   800900 <printfmt>
  80055b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055e:	e9 b6 fe ff ff       	jmp    800419 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800563:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800567:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  80056e:	00 
  80056f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800573:	89 3c 24             	mov    %edi,(%esp)
  800576:	e8 85 03 00 00       	call   800900 <printfmt>
  80057b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80057e:	e9 96 fe ff ff       	jmp    800419 <vprintfmt+0x2c>
  800583:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800586:	89 c3                	mov    %eax,%ebx
  800588:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80058b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80058e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	b8 85 24 80 00       	mov    $0x802485,%eax
  8005a6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8005aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8005b1:	7e 06                	jle    8005b9 <vprintfmt+0x1cc>
  8005b3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8005b7:	75 13                	jne    8005cc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bc:	0f be 02             	movsbl (%edx),%eax
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	0f 85 a2 00 00 00    	jne    800669 <vprintfmt+0x27c>
  8005c7:	e9 8f 00 00 00       	jmp    80065b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d3:	89 0c 24             	mov    %ecx,(%esp)
  8005d6:	e8 70 03 00 00       	call   80094b <strnlen>
  8005db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005de:	29 c2                	sub    %eax,%edx
  8005e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	7e d2                	jle    8005b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005e7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ee:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005f1:	89 d3                	mov    %edx,%ebx
  8005f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ff:	83 eb 01             	sub    $0x1,%ebx
  800602:	85 db                	test   %ebx,%ebx
  800604:	7f ed                	jg     8005f3 <vprintfmt+0x206>
  800606:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800609:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800610:	eb a7                	jmp    8005b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800612:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800616:	74 1b                	je     800633 <vprintfmt+0x246>
  800618:	8d 50 e0             	lea    -0x20(%eax),%edx
  80061b:	83 fa 5e             	cmp    $0x5e,%edx
  80061e:	76 13                	jbe    800633 <vprintfmt+0x246>
					putch('?', putdat);
  800620:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800623:	89 54 24 04          	mov    %edx,0x4(%esp)
  800627:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800631:	eb 0d                	jmp    800640 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800633:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800636:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80063a:	89 04 24             	mov    %eax,(%esp)
  80063d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800640:	83 ef 01             	sub    $0x1,%edi
  800643:	0f be 03             	movsbl (%ebx),%eax
  800646:	85 c0                	test   %eax,%eax
  800648:	74 05                	je     80064f <vprintfmt+0x262>
  80064a:	83 c3 01             	add    $0x1,%ebx
  80064d:	eb 31                	jmp    800680 <vprintfmt+0x293>
  80064f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800655:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800658:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80065f:	7f 36                	jg     800697 <vprintfmt+0x2aa>
  800661:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800664:	e9 b0 fd ff ff       	jmp    800419 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800669:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80066c:	83 c2 01             	add    $0x1,%edx
  80066f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800672:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800675:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800678:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80067b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80067e:	89 d3                	mov    %edx,%ebx
  800680:	85 f6                	test   %esi,%esi
  800682:	78 8e                	js     800612 <vprintfmt+0x225>
  800684:	83 ee 01             	sub    $0x1,%esi
  800687:	79 89                	jns    800612 <vprintfmt+0x225>
  800689:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800692:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800695:	eb c4                	jmp    80065b <vprintfmt+0x26e>
  800697:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80069a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006aa:	83 eb 01             	sub    $0x1,%ebx
  8006ad:	85 db                	test   %ebx,%ebx
  8006af:	7f ec                	jg     80069d <vprintfmt+0x2b0>
  8006b1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8006b4:	e9 60 fd ff ff       	jmp    800419 <vprintfmt+0x2c>
  8006b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006bc:	83 f9 01             	cmp    $0x1,%ecx
  8006bf:	7e 16                	jle    8006d7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 08             	lea    0x8(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8006cf:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d5:	eb 32                	jmp    800709 <vprintfmt+0x31c>
	else if (lflag)
  8006d7:	85 c9                	test   %ecx,%ecx
  8006d9:	74 18                	je     8006f3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8006db:	8b 45 14             	mov    0x14(%ebp),%eax
  8006de:	8d 50 04             	lea    0x4(%eax),%edx
  8006e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e9:	89 c1                	mov    %eax,%ecx
  8006eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f1:	eb 16                	jmp    800709 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 50 04             	lea    0x4(%eax),%edx
  8006f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fc:	8b 00                	mov    (%eax),%eax
  8006fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800701:	89 c2                	mov    %eax,%edx
  800703:	c1 fa 1f             	sar    $0x1f,%edx
  800706:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800709:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80070c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80070f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800714:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800718:	0f 89 8a 00 00 00    	jns    8007a8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80071e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800722:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800729:	ff d7                	call   *%edi
				num = -(long long) num;
  80072b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800731:	f7 d8                	neg    %eax
  800733:	83 d2 00             	adc    $0x0,%edx
  800736:	f7 da                	neg    %edx
  800738:	eb 6e                	jmp    8007a8 <vprintfmt+0x3bb>
  80073a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80073d:	89 ca                	mov    %ecx,%edx
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
  800742:	e8 4f fc ff ff       	call   800396 <getuint>
  800747:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80074c:	eb 5a                	jmp    8007a8 <vprintfmt+0x3bb>
  80074e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800751:	89 ca                	mov    %ecx,%edx
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
  800756:	e8 3b fc ff ff       	call   800396 <getuint>
  80075b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800760:	eb 46                	jmp    8007a8 <vprintfmt+0x3bb>
  800762:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800765:	89 74 24 04          	mov    %esi,0x4(%esp)
  800769:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800770:	ff d7                	call   *%edi
			putch('x', putdat);
  800772:	89 74 24 04          	mov    %esi,0x4(%esp)
  800776:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80077d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	ba 00 00 00 00       	mov    $0x0,%edx
  80078f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800794:	eb 12                	jmp    8007a8 <vprintfmt+0x3bb>
  800796:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800799:	89 ca                	mov    %ecx,%edx
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
  80079e:	e8 f3 fb ff ff       	call   800396 <getuint>
  8007a3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8007ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8007b0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8007b3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8007b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007bb:	89 04 24             	mov    %eax,(%esp)
  8007be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c2:	89 f2                	mov    %esi,%edx
  8007c4:	89 f8                	mov    %edi,%eax
  8007c6:	e8 d5 fa ff ff       	call   8002a0 <printnum>
  8007cb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ce:	e9 46 fc ff ff       	jmp    800419 <vprintfmt+0x2c>
  8007d3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8d 50 04             	lea    0x4(%eax),%edx
  8007dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007df:	8b 00                	mov    (%eax),%eax
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	75 24                	jne    800809 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8007e5:	c7 44 24 0c a0 25 80 	movl   $0x8025a0,0xc(%esp)
  8007ec:	00 
  8007ed:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  8007f4:	00 
  8007f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f9:	89 3c 24             	mov    %edi,(%esp)
  8007fc:	e8 ff 00 00 00       	call   800900 <printfmt>
  800801:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800804:	e9 10 fc ff ff       	jmp    800419 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800809:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80080c:	7e 29                	jle    800837 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80080e:	0f b6 16             	movzbl (%esi),%edx
  800811:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800813:	c7 44 24 0c d8 25 80 	movl   $0x8025d8,0xc(%esp)
  80081a:	00 
  80081b:	c7 44 24 08 bf 28 80 	movl   $0x8028bf,0x8(%esp)
  800822:	00 
  800823:	89 74 24 04          	mov    %esi,0x4(%esp)
  800827:	89 3c 24             	mov    %edi,(%esp)
  80082a:	e8 d1 00 00 00       	call   800900 <printfmt>
  80082f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800832:	e9 e2 fb ff ff       	jmp    800419 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800837:	0f b6 16             	movzbl (%esi),%edx
  80083a:	88 10                	mov    %dl,(%eax)
  80083c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80083f:	e9 d5 fb ff ff       	jmp    800419 <vprintfmt+0x2c>
  800844:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800847:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80084a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80084e:	89 14 24             	mov    %edx,(%esp)
  800851:	ff d7                	call   *%edi
  800853:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800856:	e9 be fb ff ff       	jmp    800419 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80085b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80085f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800866:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800868:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80086b:	80 38 25             	cmpb   $0x25,(%eax)
  80086e:	0f 84 a5 fb ff ff    	je     800419 <vprintfmt+0x2c>
  800874:	89 c3                	mov    %eax,%ebx
  800876:	eb f0                	jmp    800868 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800878:	83 c4 5c             	add    $0x5c,%esp
  80087b:	5b                   	pop    %ebx
  80087c:	5e                   	pop    %esi
  80087d:	5f                   	pop    %edi
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	83 ec 28             	sub    $0x28,%esp
  800886:	8b 45 08             	mov    0x8(%ebp),%eax
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80088c:	85 c0                	test   %eax,%eax
  80088e:	74 04                	je     800894 <vsnprintf+0x14>
  800890:	85 d2                	test   %edx,%edx
  800892:	7f 07                	jg     80089b <vsnprintf+0x1b>
  800894:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800899:	eb 3b                	jmp    8008d6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80089b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8008a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8008a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8008af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c1:	c7 04 24 d0 03 80 00 	movl   $0x8003d0,(%esp)
  8008c8:	e8 20 fb ff ff       	call   8003ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008d6:	c9                   	leave  
  8008d7:	c3                   	ret    

008008d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008de:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	e8 82 ff ff ff       	call   800880 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800906:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800909:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80090d:	8b 45 10             	mov    0x10(%ebp),%eax
  800910:	89 44 24 08          	mov    %eax,0x8(%esp)
  800914:	8b 45 0c             	mov    0xc(%ebp),%eax
  800917:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	89 04 24             	mov    %eax,(%esp)
  800921:	e8 c7 fa ff ff       	call   8003ed <vprintfmt>
	va_end(ap);
}
  800926:	c9                   	leave  
  800927:	c3                   	ret    
	...

00800930 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800936:	b8 00 00 00 00       	mov    $0x0,%eax
  80093b:	80 3a 00             	cmpb   $0x0,(%edx)
  80093e:	74 09                	je     800949 <strlen+0x19>
		n++;
  800940:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800943:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800947:	75 f7                	jne    800940 <strlen+0x10>
		n++;
	return n;
}
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	53                   	push   %ebx
  80094f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800952:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800955:	85 c9                	test   %ecx,%ecx
  800957:	74 19                	je     800972 <strnlen+0x27>
  800959:	80 3b 00             	cmpb   $0x0,(%ebx)
  80095c:	74 14                	je     800972 <strnlen+0x27>
  80095e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800963:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800966:	39 c8                	cmp    %ecx,%eax
  800968:	74 0d                	je     800977 <strnlen+0x2c>
  80096a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80096e:	75 f3                	jne    800963 <strnlen+0x18>
  800970:	eb 05                	jmp    800977 <strnlen+0x2c>
  800972:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800989:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80098d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800990:	83 c2 01             	add    $0x1,%edx
  800993:	84 c9                	test   %cl,%cl
  800995:	75 f2                	jne    800989 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800997:	5b                   	pop    %ebx
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a4:	89 1c 24             	mov    %ebx,(%esp)
  8009a7:	e8 84 ff ff ff       	call   800930 <strlen>
	strcpy(dst + len, src);
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8009b6:	89 04 24             	mov    %eax,(%esp)
  8009b9:	e8 bc ff ff ff       	call   80097a <strcpy>
	return dst;
}
  8009be:	89 d8                	mov    %ebx,%eax
  8009c0:	83 c4 08             	add    $0x8,%esp
  8009c3:	5b                   	pop    %ebx
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	56                   	push   %esi
  8009ca:	53                   	push   %ebx
  8009cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d4:	85 f6                	test   %esi,%esi
  8009d6:	74 18                	je     8009f0 <strncpy+0x2a>
  8009d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009dd:	0f b6 1a             	movzbl (%edx),%ebx
  8009e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009e3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e9:	83 c1 01             	add    $0x1,%ecx
  8009ec:	39 ce                	cmp    %ecx,%esi
  8009ee:	77 ed                	ja     8009dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009f0:	5b                   	pop    %ebx
  8009f1:	5e                   	pop    %esi
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	56                   	push   %esi
  8009f8:	53                   	push   %ebx
  8009f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a02:	89 f0                	mov    %esi,%eax
  800a04:	85 c9                	test   %ecx,%ecx
  800a06:	74 27                	je     800a2f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a08:	83 e9 01             	sub    $0x1,%ecx
  800a0b:	74 1d                	je     800a2a <strlcpy+0x36>
  800a0d:	0f b6 1a             	movzbl (%edx),%ebx
  800a10:	84 db                	test   %bl,%bl
  800a12:	74 16                	je     800a2a <strlcpy+0x36>
			*dst++ = *src++;
  800a14:	88 18                	mov    %bl,(%eax)
  800a16:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a19:	83 e9 01             	sub    $0x1,%ecx
  800a1c:	74 0e                	je     800a2c <strlcpy+0x38>
			*dst++ = *src++;
  800a1e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a21:	0f b6 1a             	movzbl (%edx),%ebx
  800a24:	84 db                	test   %bl,%bl
  800a26:	75 ec                	jne    800a14 <strlcpy+0x20>
  800a28:	eb 02                	jmp    800a2c <strlcpy+0x38>
  800a2a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a2c:	c6 00 00             	movb   $0x0,(%eax)
  800a2f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a3e:	0f b6 01             	movzbl (%ecx),%eax
  800a41:	84 c0                	test   %al,%al
  800a43:	74 15                	je     800a5a <strcmp+0x25>
  800a45:	3a 02                	cmp    (%edx),%al
  800a47:	75 11                	jne    800a5a <strcmp+0x25>
		p++, q++;
  800a49:	83 c1 01             	add    $0x1,%ecx
  800a4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a4f:	0f b6 01             	movzbl (%ecx),%eax
  800a52:	84 c0                	test   %al,%al
  800a54:	74 04                	je     800a5a <strcmp+0x25>
  800a56:	3a 02                	cmp    (%edx),%al
  800a58:	74 ef                	je     800a49 <strcmp+0x14>
  800a5a:	0f b6 c0             	movzbl %al,%eax
  800a5d:	0f b6 12             	movzbl (%edx),%edx
  800a60:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a62:	5d                   	pop    %ebp
  800a63:	c3                   	ret    

00800a64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	53                   	push   %ebx
  800a68:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a71:	85 c0                	test   %eax,%eax
  800a73:	74 23                	je     800a98 <strncmp+0x34>
  800a75:	0f b6 1a             	movzbl (%edx),%ebx
  800a78:	84 db                	test   %bl,%bl
  800a7a:	74 25                	je     800aa1 <strncmp+0x3d>
  800a7c:	3a 19                	cmp    (%ecx),%bl
  800a7e:	75 21                	jne    800aa1 <strncmp+0x3d>
  800a80:	83 e8 01             	sub    $0x1,%eax
  800a83:	74 13                	je     800a98 <strncmp+0x34>
		n--, p++, q++;
  800a85:	83 c2 01             	add    $0x1,%edx
  800a88:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a8b:	0f b6 1a             	movzbl (%edx),%ebx
  800a8e:	84 db                	test   %bl,%bl
  800a90:	74 0f                	je     800aa1 <strncmp+0x3d>
  800a92:	3a 19                	cmp    (%ecx),%bl
  800a94:	74 ea                	je     800a80 <strncmp+0x1c>
  800a96:	eb 09                	jmp    800aa1 <strncmp+0x3d>
  800a98:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5d                   	pop    %ebp
  800a9f:	90                   	nop
  800aa0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa1:	0f b6 02             	movzbl (%edx),%eax
  800aa4:	0f b6 11             	movzbl (%ecx),%edx
  800aa7:	29 d0                	sub    %edx,%eax
  800aa9:	eb f2                	jmp    800a9d <strncmp+0x39>

00800aab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab5:	0f b6 10             	movzbl (%eax),%edx
  800ab8:	84 d2                	test   %dl,%dl
  800aba:	74 18                	je     800ad4 <strchr+0x29>
		if (*s == c)
  800abc:	38 ca                	cmp    %cl,%dl
  800abe:	75 0a                	jne    800aca <strchr+0x1f>
  800ac0:	eb 17                	jmp    800ad9 <strchr+0x2e>
  800ac2:	38 ca                	cmp    %cl,%dl
  800ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ac8:	74 0f                	je     800ad9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	75 ee                	jne    800ac2 <strchr+0x17>
  800ad4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ae5:	0f b6 10             	movzbl (%eax),%edx
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	74 18                	je     800b04 <strfind+0x29>
		if (*s == c)
  800aec:	38 ca                	cmp    %cl,%dl
  800aee:	75 0a                	jne    800afa <strfind+0x1f>
  800af0:	eb 12                	jmp    800b04 <strfind+0x29>
  800af2:	38 ca                	cmp    %cl,%dl
  800af4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800af8:	74 0a                	je     800b04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	0f b6 10             	movzbl (%eax),%edx
  800b00:	84 d2                	test   %dl,%dl
  800b02:	75 ee                	jne    800af2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	89 1c 24             	mov    %ebx,(%esp)
  800b0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b20:	85 c9                	test   %ecx,%ecx
  800b22:	74 30                	je     800b54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b2a:	75 25                	jne    800b51 <memset+0x4b>
  800b2c:	f6 c1 03             	test   $0x3,%cl
  800b2f:	75 20                	jne    800b51 <memset+0x4b>
		c &= 0xFF;
  800b31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b34:	89 d3                	mov    %edx,%ebx
  800b36:	c1 e3 08             	shl    $0x8,%ebx
  800b39:	89 d6                	mov    %edx,%esi
  800b3b:	c1 e6 18             	shl    $0x18,%esi
  800b3e:	89 d0                	mov    %edx,%eax
  800b40:	c1 e0 10             	shl    $0x10,%eax
  800b43:	09 f0                	or     %esi,%eax
  800b45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b47:	09 d8                	or     %ebx,%eax
  800b49:	c1 e9 02             	shr    $0x2,%ecx
  800b4c:	fc                   	cld    
  800b4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4f:	eb 03                	jmp    800b54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b51:	fc                   	cld    
  800b52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b54:	89 f8                	mov    %edi,%eax
  800b56:	8b 1c 24             	mov    (%esp),%ebx
  800b59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b61:	89 ec                	mov    %ebp,%esp
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
  800b6b:	89 34 24             	mov    %esi,(%esp)
  800b6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b7d:	39 c6                	cmp    %eax,%esi
  800b7f:	73 35                	jae    800bb6 <memmove+0x51>
  800b81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b84:	39 d0                	cmp    %edx,%eax
  800b86:	73 2e                	jae    800bb6 <memmove+0x51>
		s += n;
		d += n;
  800b88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8a:	f6 c2 03             	test   $0x3,%dl
  800b8d:	75 1b                	jne    800baa <memmove+0x45>
  800b8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b95:	75 13                	jne    800baa <memmove+0x45>
  800b97:	f6 c1 03             	test   $0x3,%cl
  800b9a:	75 0e                	jne    800baa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b9c:	83 ef 04             	sub    $0x4,%edi
  800b9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba2:	c1 e9 02             	shr    $0x2,%ecx
  800ba5:	fd                   	std    
  800ba6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba8:	eb 09                	jmp    800bb3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800baa:	83 ef 01             	sub    $0x1,%edi
  800bad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bb0:	fd                   	std    
  800bb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bb4:	eb 20                	jmp    800bd6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbc:	75 15                	jne    800bd3 <memmove+0x6e>
  800bbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bc4:	75 0d                	jne    800bd3 <memmove+0x6e>
  800bc6:	f6 c1 03             	test   $0x3,%cl
  800bc9:	75 08                	jne    800bd3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bcb:	c1 e9 02             	shr    $0x2,%ecx
  800bce:	fc                   	cld    
  800bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd1:	eb 03                	jmp    800bd6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd3:	fc                   	cld    
  800bd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd6:	8b 34 24             	mov    (%esp),%esi
  800bd9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bdd:	89 ec                	mov    %ebp,%esp
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800be7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	89 04 24             	mov    %eax,(%esp)
  800bfb:	e8 65 ff ff ff       	call   800b65 <memmove>
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	8b 75 08             	mov    0x8(%ebp),%esi
  800c0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c11:	85 c9                	test   %ecx,%ecx
  800c13:	74 36                	je     800c4b <memcmp+0x49>
		if (*s1 != *s2)
  800c15:	0f b6 06             	movzbl (%esi),%eax
  800c18:	0f b6 1f             	movzbl (%edi),%ebx
  800c1b:	38 d8                	cmp    %bl,%al
  800c1d:	74 20                	je     800c3f <memcmp+0x3d>
  800c1f:	eb 14                	jmp    800c35 <memcmp+0x33>
  800c21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c2b:	83 c2 01             	add    $0x1,%edx
  800c2e:	83 e9 01             	sub    $0x1,%ecx
  800c31:	38 d8                	cmp    %bl,%al
  800c33:	74 12                	je     800c47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c35:	0f b6 c0             	movzbl %al,%eax
  800c38:	0f b6 db             	movzbl %bl,%ebx
  800c3b:	29 d8                	sub    %ebx,%eax
  800c3d:	eb 11                	jmp    800c50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3f:	83 e9 01             	sub    $0x1,%ecx
  800c42:	ba 00 00 00 00       	mov    $0x0,%edx
  800c47:	85 c9                	test   %ecx,%ecx
  800c49:	75 d6                	jne    800c21 <memcmp+0x1f>
  800c4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c5b:	89 c2                	mov    %eax,%edx
  800c5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c60:	39 d0                	cmp    %edx,%eax
  800c62:	73 15                	jae    800c79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c68:	38 08                	cmp    %cl,(%eax)
  800c6a:	75 06                	jne    800c72 <memfind+0x1d>
  800c6c:	eb 0b                	jmp    800c79 <memfind+0x24>
  800c6e:	38 08                	cmp    %cl,(%eax)
  800c70:	74 07                	je     800c79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c72:	83 c0 01             	add    $0x1,%eax
  800c75:	39 c2                	cmp    %eax,%edx
  800c77:	77 f5                	ja     800c6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 04             	sub    $0x4,%esp
  800c84:	8b 55 08             	mov    0x8(%ebp),%edx
  800c87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c8a:	0f b6 02             	movzbl (%edx),%eax
  800c8d:	3c 20                	cmp    $0x20,%al
  800c8f:	74 04                	je     800c95 <strtol+0x1a>
  800c91:	3c 09                	cmp    $0x9,%al
  800c93:	75 0e                	jne    800ca3 <strtol+0x28>
		s++;
  800c95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c98:	0f b6 02             	movzbl (%edx),%eax
  800c9b:	3c 20                	cmp    $0x20,%al
  800c9d:	74 f6                	je     800c95 <strtol+0x1a>
  800c9f:	3c 09                	cmp    $0x9,%al
  800ca1:	74 f2                	je     800c95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ca3:	3c 2b                	cmp    $0x2b,%al
  800ca5:	75 0c                	jne    800cb3 <strtol+0x38>
		s++;
  800ca7:	83 c2 01             	add    $0x1,%edx
  800caa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cb1:	eb 15                	jmp    800cc8 <strtol+0x4d>
	else if (*s == '-')
  800cb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800cba:	3c 2d                	cmp    $0x2d,%al
  800cbc:	75 0a                	jne    800cc8 <strtol+0x4d>
		s++, neg = 1;
  800cbe:	83 c2 01             	add    $0x1,%edx
  800cc1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc8:	85 db                	test   %ebx,%ebx
  800cca:	0f 94 c0             	sete   %al
  800ccd:	74 05                	je     800cd4 <strtol+0x59>
  800ccf:	83 fb 10             	cmp    $0x10,%ebx
  800cd2:	75 18                	jne    800cec <strtol+0x71>
  800cd4:	80 3a 30             	cmpb   $0x30,(%edx)
  800cd7:	75 13                	jne    800cec <strtol+0x71>
  800cd9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cdd:	8d 76 00             	lea    0x0(%esi),%esi
  800ce0:	75 0a                	jne    800cec <strtol+0x71>
		s += 2, base = 16;
  800ce2:	83 c2 02             	add    $0x2,%edx
  800ce5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cea:	eb 15                	jmp    800d01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cec:	84 c0                	test   %al,%al
  800cee:	66 90                	xchg   %ax,%ax
  800cf0:	74 0f                	je     800d01 <strtol+0x86>
  800cf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cf7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cfa:	75 05                	jne    800d01 <strtol+0x86>
		s++, base = 8;
  800cfc:	83 c2 01             	add    $0x1,%edx
  800cff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d08:	0f b6 0a             	movzbl (%edx),%ecx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d10:	80 fb 09             	cmp    $0x9,%bl
  800d13:	77 08                	ja     800d1d <strtol+0xa2>
			dig = *s - '0';
  800d15:	0f be c9             	movsbl %cl,%ecx
  800d18:	83 e9 30             	sub    $0x30,%ecx
  800d1b:	eb 1e                	jmp    800d3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d20:	80 fb 19             	cmp    $0x19,%bl
  800d23:	77 08                	ja     800d2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d25:	0f be c9             	movsbl %cl,%ecx
  800d28:	83 e9 57             	sub    $0x57,%ecx
  800d2b:	eb 0e                	jmp    800d3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d30:	80 fb 19             	cmp    $0x19,%bl
  800d33:	77 15                	ja     800d4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d35:	0f be c9             	movsbl %cl,%ecx
  800d38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d3b:	39 f1                	cmp    %esi,%ecx
  800d3d:	7d 0b                	jge    800d4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d3f:	83 c2 01             	add    $0x1,%edx
  800d42:	0f af c6             	imul   %esi,%eax
  800d45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d48:	eb be                	jmp    800d08 <strtol+0x8d>
  800d4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d50:	74 05                	je     800d57 <strtol+0xdc>
		*endptr = (char *) s;
  800d52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d57:	89 ca                	mov    %ecx,%edx
  800d59:	f7 da                	neg    %edx
  800d5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d5f:	0f 45 c2             	cmovne %edx,%eax
}
  800d62:	83 c4 04             	add    $0x4,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
	...

00800d6c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 48             	sub    $0x48,%esp
  800d72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d78:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d7b:	89 c6                	mov    %eax,%esi
  800d7d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d80:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d82:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8b:	51                   	push   %ecx
  800d8c:	52                   	push   %edx
  800d8d:	53                   	push   %ebx
  800d8e:	54                   	push   %esp
  800d8f:	55                   	push   %ebp
  800d90:	56                   	push   %esi
  800d91:	57                   	push   %edi
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	8d 35 9c 0d 80 00    	lea    0x800d9c,%esi
  800d9a:	0f 34                	sysenter 

00800d9c <.after_sysenter_label>:
  800d9c:	5f                   	pop    %edi
  800d9d:	5e                   	pop    %esi
  800d9e:	5d                   	pop    %ebp
  800d9f:	5c                   	pop    %esp
  800da0:	5b                   	pop    %ebx
  800da1:	5a                   	pop    %edx
  800da2:	59                   	pop    %ecx
  800da3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800da5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800da9:	74 28                	je     800dd3 <.after_sysenter_label+0x37>
  800dab:	85 c0                	test   %eax,%eax
  800dad:	7e 24                	jle    800dd3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800daf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800db3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800db7:	c7 44 24 08 e0 27 80 	movl   $0x8027e0,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 fd 27 80 00 	movl   $0x8027fd,(%esp)
  800dce:	e8 b5 f3 ff ff       	call   800188 <_panic>

	return ret;
}
  800dd3:	89 d0                	mov    %edx,%eax
  800dd5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ddb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dde:	89 ec                	mov    %ebp,%esp
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800de8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800def:	00 
  800df0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800df7:	00 
  800df8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dff:	00 
  800e00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e03:	89 04 24             	mov    %eax,(%esp)
  800e06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e09:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e13:	e8 54 ff ff ff       	call   800d6c <syscall>
}
  800e18:	c9                   	leave  
  800e19:	c3                   	ret    

00800e1a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800e20:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e27:	00 
  800e28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e2f:	00 
  800e30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e37:	00 
  800e38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e44:	ba 00 00 00 00       	mov    $0x0,%edx
  800e49:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e4e:	e8 19 ff ff ff       	call   800d6c <syscall>
}
  800e53:	c9                   	leave  
  800e54:	c3                   	ret    

00800e55 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e5b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e62:	00 
  800e63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e6a:	00 
  800e6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e72:	00 
  800e73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e82:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e87:	e8 e0 fe ff ff       	call   800d6c <syscall>
}
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e94:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e9b:	00 
  800e9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	89 04 24             	mov    %eax,(%esp)
  800eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebd:	e8 aa fe ff ff       	call   800d6c <syscall>
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800eca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee1:	00 
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	89 04 24             	mov    %eax,(%esp)
  800ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eeb:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ef5:	e8 72 fe ff ff       	call   800d6c <syscall>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800f02:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f09:	00 
  800f0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f19:	00 
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	89 04 24             	mov    %eax,(%esp)
  800f20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f23:	ba 01 00 00 00       	mov    $0x1,%edx
  800f28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f2d:	e8 3a fe ff ff       	call   800d6c <syscall>
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f51:	00 
  800f52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f55:	89 04 24             	mov    %eax,(%esp)
  800f58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f60:	b8 09 00 00 00       	mov    $0x9,%eax
  800f65:	e8 02 fe ff ff       	call   800d6c <syscall>
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f72:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f79:	00 
  800f7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f81:	00 
  800f82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f89:	00 
  800f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8d:	89 04 24             	mov    %eax,(%esp)
  800f90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f93:	ba 01 00 00 00       	mov    $0x1,%edx
  800f98:	b8 07 00 00 00       	mov    $0x7,%eax
  800f9d:	e8 ca fd ff ff       	call   800d6c <syscall>
}
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800faa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb1:	00 
  800fb2:	8b 45 18             	mov    0x18(%ebp),%eax
  800fb5:	0b 45 14             	or     0x14(%ebp),%eax
  800fb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fbc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc6:	89 04 24             	mov    %eax,(%esp)
  800fc9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fcc:	ba 01 00 00 00       	mov    $0x1,%edx
  800fd1:	b8 06 00 00 00       	mov    $0x6,%eax
  800fd6:	e8 91 fd ff ff       	call   800d6c <syscall>
}
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fe3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fea:	00 
  800feb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff2:	00 
  800ff3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffd:	89 04 24             	mov    %eax,(%esp)
  801000:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801003:	ba 01 00 00 00       	mov    $0x1,%edx
  801008:	b8 05 00 00 00       	mov    $0x5,%eax
  80100d:	e8 5a fd ff ff       	call   800d6c <syscall>
}
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80101a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801021:	00 
  801022:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801029:	00 
  80102a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801031:	00 
  801032:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801039:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103e:	ba 00 00 00 00       	mov    $0x0,%edx
  801043:	b8 0c 00 00 00       	mov    $0xc,%eax
  801048:	e8 1f fd ff ff       	call   800d6c <syscall>
}
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801055:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80105c:	00 
  80105d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801064:	00 
  801065:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80106c:	00 
  80106d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801070:	89 04 24             	mov    %eax,(%esp)
  801073:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801076:	ba 00 00 00 00       	mov    $0x0,%edx
  80107b:	b8 04 00 00 00       	mov    $0x4,%eax
  801080:	e8 e7 fc ff ff       	call   800d6c <syscall>
}
  801085:	c9                   	leave  
  801086:	c3                   	ret    

00801087 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80108d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801094:	00 
  801095:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80109c:	00 
  80109d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010a4:	00 
  8010a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b6:	b8 02 00 00 00       	mov    $0x2,%eax
  8010bb:	e8 ac fc ff ff       	call   800d6c <syscall>
}
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010cf:	00 
  8010d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ea:	ba 01 00 00 00       	mov    $0x1,%edx
  8010ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8010f4:	e8 73 fc ff ff       	call   800d6c <syscall>
}
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    

008010fb <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801101:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801108:	00 
  801109:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801110:	00 
  801111:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801118:	00 
  801119:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801120:	b9 00 00 00 00       	mov    $0x0,%ecx
  801125:	ba 00 00 00 00       	mov    $0x0,%edx
  80112a:	b8 01 00 00 00       	mov    $0x1,%eax
  80112f:	e8 38 fc ff ff       	call   800d6c <syscall>
}
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80113c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801143:	00 
  801144:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80114b:	00 
  80114c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801153:	00 
  801154:	8b 45 0c             	mov    0xc(%ebp),%eax
  801157:	89 04 24             	mov    %eax,(%esp)
  80115a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80115d:	ba 00 00 00 00       	mov    $0x0,%edx
  801162:	b8 00 00 00 00       	mov    $0x0,%eax
  801167:	e8 00 fc ff ff       	call   800d6c <syscall>
}
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    
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
  8012b2:	be 8c 28 80 00       	mov    $0x80288c,%esi
  8012b7:	83 c2 01             	add    $0x1,%edx
  8012ba:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	75 e2                	jne    8012a3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012c1:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8012c6:	8b 40 48             	mov    0x48(%eax),%eax
  8012c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d1:	c7 04 24 0c 28 80 00 	movl   $0x80280c,(%esp)
  8012d8:	e8 64 ef ff ff       	call   800241 <cprintf>
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
  8013a6:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ab:	8b 40 48             	mov    0x48(%eax),%eax
  8013ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	c7 04 24 2c 28 80 00 	movl   $0x80282c,(%esp)
  8013bd:	e8 7f ee ff ff       	call   800241 <cprintf>
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
  801428:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80142d:	8b 40 48             	mov    0x48(%eax),%eax
  801430:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801434:	89 44 24 04          	mov    %eax,0x4(%esp)
  801438:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  80143f:	e8 fd ed ff ff       	call   800241 <cprintf>
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
  8014b6:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8014bb:	8b 40 48             	mov    0x48(%eax),%eax
  8014be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c6:	c7 04 24 6d 28 80 00 	movl   $0x80286d,(%esp)
  8014cd:	e8 6f ed ff ff       	call   800241 <cprintf>
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
  8015cb:	e8 9c f9 ff ff       	call   800f6c <sys_page_unmap>
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
  80171c:	e8 83 f8 ff ff       	call   800fa4 <sys_page_map>
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
  801757:	e8 48 f8 ff ff       	call   800fa4 <sys_page_map>
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
  801771:	e8 f6 f7 ff ff       	call   800f6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801776:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801779:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801784:	e8 e3 f7 ff ff       	call   800f6c <sys_page_unmap>
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
  8017b8:	e8 b3 07 00 00       	call   801f70 <ipc_find_env>
  8017bd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017c2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8017c9:	00 
  8017ca:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  8017d1:	00 
  8017d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017d6:	a1 00 40 80 00       	mov    0x804000,%eax
  8017db:	89 04 24             	mov    %eax,(%esp)
  8017de:	e8 d6 07 00 00       	call   801fb9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017ea:	00 
  8017eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f6:	e8 29 08 00 00       	call   802024 <ipc_recv>
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
  801811:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  801816:	8b 45 0c             	mov    0xc(%ebp),%eax
  801819:	a3 04 50 c0 00       	mov    %eax,0xc05004
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
  80183b:	a3 00 50 c0 00       	mov    %eax,0xc05000
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
  801878:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80187d:	ba 00 00 00 00       	mov    $0x0,%edx
  801882:	b8 05 00 00 00       	mov    $0x5,%eax
  801887:	e8 0c ff ff ff       	call   801798 <fsipc>
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 2b                	js     8018bb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801890:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801897:	00 
  801898:	89 1c 24             	mov    %ebx,(%esp)
  80189b:	e8 da f0 ff ff       	call   80097a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a0:	a1 80 50 c0 00       	mov    0xc05080,%eax
  8018a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018ab:	a1 84 50 c0 00       	mov    0xc05084,%eax
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
  8018d0:	89 15 00 50 c0 00    	mov    %edx,0xc05000
  fsipcbuf.write.req_n = n;
  8018d6:	a3 04 50 c0 00       	mov    %eax,0xc05004
  memmove(fsipcbuf.write.req_buf, buf,
  8018db:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e5:	0f 47 c2             	cmova  %edx,%eax
  8018e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f3:	c7 04 24 08 50 c0 00 	movl   $0xc05008,(%esp)
  8018fa:	e8 66 f2 ff ff       	call   800b65 <memmove>
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
  80191d:	a3 00 50 c0 00       	mov    %eax,0xc05000
  fsipcbuf.read.req_n = n;
  801922:	8b 45 10             	mov    0x10(%ebp),%eax
  801925:	a3 04 50 c0 00       	mov    %eax,0xc05004
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
  801943:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  80194a:	00 
  80194b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194e:	89 04 24             	mov    %eax,(%esp)
  801951:	e8 0f f2 ff ff       	call   800b65 <memmove>
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
  80196b:	e8 c0 ef ff ff       	call   800930 <strlen>
  801970:	89 c2                	mov    %eax,%edx
  801972:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801977:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80197d:	7f 1f                	jg     80199e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80197f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801983:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  80198a:	e8 eb ef ff ff       	call   80097a <strcpy>
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
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8019c8:	89 34 24             	mov    %esi,(%esp)
  8019cb:	e8 60 ef ff ff       	call   800930 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8019d0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8019d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019da:	7f 75                	jg     801a51 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8019dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019e0:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  8019e7:	e8 8e ef ff ff       	call   80097a <strcpy>
  fsipcbuf.open.req_omode = mode;
  8019ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ef:	a3 00 54 c0 00       	mov    %eax,0xc05400
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
  801a2d:	c7 44 24 0c 98 28 80 	movl   $0x802898,0xc(%esp)
  801a34:	00 
  801a35:	c7 44 24 08 ad 28 80 	movl   $0x8028ad,0x8(%esp)
  801a3c:	00 
  801a3d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801a44:	00 
  801a45:	c7 04 24 c2 28 80 00 	movl   $0x8028c2,(%esp)
  801a4c:	e8 37 e7 ff ff       	call   800188 <_panic>
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

00801a60 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801a66:	c7 44 24 04 cd 28 80 	movl   $0x8028cd,0x4(%esp)
  801a6d:	00 
  801a6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a71:	89 04 24             	mov    %eax,(%esp)
  801a74:	e8 01 ef ff ff       	call   80097a <strcpy>
	return 0;
}
  801a79:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	53                   	push   %ebx
  801a84:	83 ec 14             	sub    $0x14,%esp
  801a87:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a8a:	89 1c 24             	mov    %ebx,(%esp)
  801a8d:	e8 22 06 00 00       	call   8020b4 <pageref>
  801a92:	89 c2                	mov    %eax,%edx
  801a94:	b8 00 00 00 00       	mov    $0x0,%eax
  801a99:	83 fa 01             	cmp    $0x1,%edx
  801a9c:	75 0b                	jne    801aa9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801a9e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 b9 02 00 00       	call   801d62 <nsipc_close>
	else
		return 0;
}
  801aa9:	83 c4 14             	add    $0x14,%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5d                   	pop    %ebp
  801aae:	c3                   	ret    

00801aaf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ab5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801abc:	00 
  801abd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	8b 40 0c             	mov    0xc(%eax),%eax
  801ad1:	89 04 24             	mov    %eax,(%esp)
  801ad4:	e8 c5 02 00 00       	call   801d9e <nsipc_send>
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ae1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801ae8:	00 
  801ae9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af7:	8b 45 08             	mov    0x8(%ebp),%eax
  801afa:	8b 40 0c             	mov    0xc(%eax),%eax
  801afd:	89 04 24             	mov    %eax,(%esp)
  801b00:	e8 0c 03 00 00       	call   801e11 <nsipc_recv>
}
  801b05:	c9                   	leave  
  801b06:	c3                   	ret    

00801b07 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801b07:	55                   	push   %ebp
  801b08:	89 e5                	mov    %esp,%ebp
  801b0a:	56                   	push   %esi
  801b0b:	53                   	push   %ebx
  801b0c:	83 ec 20             	sub    $0x20,%esp
  801b0f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b14:	89 04 24             	mov    %eax,(%esp)
  801b17:	e8 7f f6 ff ff       	call   80119b <fd_alloc>
  801b1c:	89 c3                	mov    %eax,%ebx
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 21                	js     801b43 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801b29:	00 
  801b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b38:	e8 a0 f4 ff ff       	call   800fdd <sys_page_alloc>
  801b3d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b3f:	85 c0                	test   %eax,%eax
  801b41:	79 0a                	jns    801b4d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801b43:	89 34 24             	mov    %esi,(%esp)
  801b46:	e8 17 02 00 00       	call   801d62 <nsipc_close>
		return r;
  801b4b:	eb 28                	jmp    801b75 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b65:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6b:	89 04 24             	mov    %eax,(%esp)
  801b6e:	e8 fd f5 ff ff       	call   801170 <fd2num>
  801b73:	89 c3                	mov    %eax,%ebx
}
  801b75:	89 d8                	mov    %ebx,%eax
  801b77:	83 c4 20             	add    $0x20,%esp
  801b7a:	5b                   	pop    %ebx
  801b7b:	5e                   	pop    %esi
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b84:	8b 45 10             	mov    0x10(%ebp),%eax
  801b87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b92:	8b 45 08             	mov    0x8(%ebp),%eax
  801b95:	89 04 24             	mov    %eax,(%esp)
  801b98:	e8 79 01 00 00       	call   801d16 <nsipc_socket>
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 05                	js     801ba6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801ba1:	e8 61 ff ff ff       	call   801b07 <alloc_sockfd>
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801bae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801bb1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bb5:	89 04 24             	mov    %eax,(%esp)
  801bb8:	e8 50 f6 ff ff       	call   80120d <fd_lookup>
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	78 15                	js     801bd6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801bc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bc4:	8b 0a                	mov    (%edx),%ecx
  801bc6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bcb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801bd1:	75 03                	jne    801bd6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801bd3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801bd6:	c9                   	leave  
  801bd7:	c3                   	ret    

00801bd8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801bd8:	55                   	push   %ebp
  801bd9:	89 e5                	mov    %esp,%ebp
  801bdb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	e8 c2 ff ff ff       	call   801ba8 <fd2sockid>
  801be6:	85 c0                	test   %eax,%eax
  801be8:	78 0f                	js     801bf9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801bea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bed:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bf1:	89 04 24             	mov    %eax,(%esp)
  801bf4:	e8 47 01 00 00       	call   801d40 <nsipc_listen>
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	e8 9f ff ff ff       	call   801ba8 <fd2sockid>
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	78 16                	js     801c23 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c0d:	8b 55 10             	mov    0x10(%ebp),%edx
  801c10:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c14:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c17:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c1b:	89 04 24             	mov    %eax,(%esp)
  801c1e:	e8 6e 02 00 00       	call   801e91 <nsipc_connect>
}
  801c23:	c9                   	leave  
  801c24:	c3                   	ret    

00801c25 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801c25:	55                   	push   %ebp
  801c26:	89 e5                	mov    %esp,%ebp
  801c28:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	e8 75 ff ff ff       	call   801ba8 <fd2sockid>
  801c33:	85 c0                	test   %eax,%eax
  801c35:	78 0f                	js     801c46 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c37:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 36 01 00 00       	call   801d7c <nsipc_shutdown>
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c51:	e8 52 ff ff ff       	call   801ba8 <fd2sockid>
  801c56:	85 c0                	test   %eax,%eax
  801c58:	78 16                	js     801c70 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801c5a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c5d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c64:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c68:	89 04 24             	mov    %eax,(%esp)
  801c6b:	e8 60 02 00 00       	call   801ed0 <nsipc_bind>
}
  801c70:	c9                   	leave  
  801c71:	c3                   	ret    

00801c72 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c78:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7b:	e8 28 ff ff ff       	call   801ba8 <fd2sockid>
  801c80:	85 c0                	test   %eax,%eax
  801c82:	78 1f                	js     801ca3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c84:	8b 55 10             	mov    0x10(%ebp),%edx
  801c87:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c92:	89 04 24             	mov    %eax,(%esp)
  801c95:	e8 75 02 00 00       	call   801f0f <nsipc_accept>
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	78 05                	js     801ca3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801c9e:	e8 64 fe ff ff       	call   801b07 <alloc_sockfd>
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    
	...

00801cb0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 14             	sub    $0x14,%esp
  801cb7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cb9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cc0:	75 11                	jne    801cd3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cc2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801cc9:	e8 a2 02 00 00       	call   801f70 <ipc_find_env>
  801cce:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cd3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cda:	00 
  801cdb:	c7 44 24 08 00 60 c0 	movl   $0xc06000,0x8(%esp)
  801ce2:	00 
  801ce3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ce7:	a1 04 40 80 00       	mov    0x804004,%eax
  801cec:	89 04 24             	mov    %eax,(%esp)
  801cef:	e8 c5 02 00 00       	call   801fb9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cf4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cfb:	00 
  801cfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d03:	00 
  801d04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d0b:	e8 14 03 00 00       	call   802024 <ipc_recv>
}
  801d10:	83 c4 14             	add    $0x14,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    

00801d16 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.socket.req_type = type;
  801d24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d27:	a3 04 60 c0 00       	mov    %eax,0xc06004
	nsipcbuf.socket.req_protocol = protocol;
  801d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2f:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SOCKET);
  801d34:	b8 09 00 00 00       	mov    $0x9,%eax
  801d39:	e8 72 ff ff ff       	call   801cb0 <nsipc>
}
  801d3e:	c9                   	leave  
  801d3f:	c3                   	ret    

00801d40 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.listen.req_backlog = backlog;
  801d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d51:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_LISTEN);
  801d56:	b8 06 00 00 00       	mov    $0x6,%eax
  801d5b:	e8 50 ff ff ff       	call   801cb0 <nsipc>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d68:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6b:	a3 00 60 c0 00       	mov    %eax,0xc06000
	return nsipc(NSREQ_CLOSE);
  801d70:	b8 04 00 00 00       	mov    $0x4,%eax
  801d75:	e8 36 ff ff ff       	call   801cb0 <nsipc>
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d82:	8b 45 08             	mov    0x8(%ebp),%eax
  801d85:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.shutdown.req_how = how;
  801d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8d:	a3 04 60 c0 00       	mov    %eax,0xc06004
	return nsipc(NSREQ_SHUTDOWN);
  801d92:	b8 03 00 00 00       	mov    $0x3,%eax
  801d97:	e8 14 ff ff ff       	call   801cb0 <nsipc>
}
  801d9c:	c9                   	leave  
  801d9d:	c3                   	ret    

00801d9e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d9e:	55                   	push   %ebp
  801d9f:	89 e5                	mov    %esp,%ebp
  801da1:	53                   	push   %ebx
  801da2:	83 ec 14             	sub    $0x14,%esp
  801da5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801da8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dab:	a3 00 60 c0 00       	mov    %eax,0xc06000
	assert(size < 1600);
  801db0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801db6:	7e 24                	jle    801ddc <nsipc_send+0x3e>
  801db8:	c7 44 24 0c d9 28 80 	movl   $0x8028d9,0xc(%esp)
  801dbf:	00 
  801dc0:	c7 44 24 08 ad 28 80 	movl   $0x8028ad,0x8(%esp)
  801dc7:	00 
  801dc8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801dcf:	00 
  801dd0:	c7 04 24 e5 28 80 00 	movl   $0x8028e5,(%esp)
  801dd7:	e8 ac e3 ff ff       	call   800188 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ddc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de7:	c7 04 24 0c 60 c0 00 	movl   $0xc0600c,(%esp)
  801dee:	e8 72 ed ff ff       	call   800b65 <memmove>
	nsipcbuf.send.req_size = size;
  801df3:	89 1d 04 60 c0 00    	mov    %ebx,0xc06004
	nsipcbuf.send.req_flags = flags;
  801df9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfc:	a3 08 60 c0 00       	mov    %eax,0xc06008
	return nsipc(NSREQ_SEND);
  801e01:	b8 08 00 00 00       	mov    $0x8,%eax
  801e06:	e8 a5 fe ff ff       	call   801cb0 <nsipc>
}
  801e0b:	83 c4 14             	add    $0x14,%esp
  801e0e:	5b                   	pop    %ebx
  801e0f:	5d                   	pop    %ebp
  801e10:	c3                   	ret    

00801e11 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e11:	55                   	push   %ebp
  801e12:	89 e5                	mov    %esp,%ebp
  801e14:	56                   	push   %esi
  801e15:	53                   	push   %ebx
  801e16:	83 ec 10             	sub    $0x10,%esp
  801e19:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	a3 00 60 c0 00       	mov    %eax,0xc06000
	nsipcbuf.recv.req_len = len;
  801e24:	89 35 04 60 c0 00    	mov    %esi,0xc06004
	nsipcbuf.recv.req_flags = flags;
  801e2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2d:	a3 08 60 c0 00       	mov    %eax,0xc06008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e32:	b8 07 00 00 00       	mov    $0x7,%eax
  801e37:	e8 74 fe ff ff       	call   801cb0 <nsipc>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 46                	js     801e88 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e42:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e47:	7f 04                	jg     801e4d <nsipc_recv+0x3c>
  801e49:	39 c6                	cmp    %eax,%esi
  801e4b:	7d 24                	jge    801e71 <nsipc_recv+0x60>
  801e4d:	c7 44 24 0c f1 28 80 	movl   $0x8028f1,0xc(%esp)
  801e54:	00 
  801e55:	c7 44 24 08 ad 28 80 	movl   $0x8028ad,0x8(%esp)
  801e5c:	00 
  801e5d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801e64:	00 
  801e65:	c7 04 24 e5 28 80 00 	movl   $0x8028e5,(%esp)
  801e6c:	e8 17 e3 ff ff       	call   800188 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e75:	c7 44 24 04 00 60 c0 	movl   $0xc06000,0x4(%esp)
  801e7c:	00 
  801e7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e80:	89 04 24             	mov    %eax,(%esp)
  801e83:	e8 dd ec ff ff       	call   800b65 <memmove>
	}

	return r;
}
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	53                   	push   %ebx
  801e95:	83 ec 14             	sub    $0x14,%esp
  801e98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9e:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ea3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eae:	c7 04 24 04 60 c0 00 	movl   $0xc06004,(%esp)
  801eb5:	e8 ab ec ff ff       	call   800b65 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801eba:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_CONNECT);
  801ec0:	b8 05 00 00 00       	mov    $0x5,%eax
  801ec5:	e8 e6 fd ff ff       	call   801cb0 <nsipc>
}
  801eca:	83 c4 14             	add    $0x14,%esp
  801ecd:	5b                   	pop    %ebx
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 14             	sub    $0x14,%esp
  801ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801eda:	8b 45 08             	mov    0x8(%ebp),%eax
  801edd:	a3 00 60 c0 00       	mov    %eax,0xc06000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ee2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eed:	c7 04 24 04 60 c0 00 	movl   $0xc06004,(%esp)
  801ef4:	e8 6c ec ff ff       	call   800b65 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ef9:	89 1d 14 60 c0 00    	mov    %ebx,0xc06014
	return nsipc(NSREQ_BIND);
  801eff:	b8 02 00 00 00       	mov    $0x2,%eax
  801f04:	e8 a7 fd ff ff       	call   801cb0 <nsipc>
}
  801f09:	83 c4 14             	add    $0x14,%esp
  801f0c:	5b                   	pop    %ebx
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	83 ec 18             	sub    $0x18,%esp
  801f15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	a3 00 60 c0 00       	mov    %eax,0xc06000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f23:	b8 01 00 00 00       	mov    $0x1,%eax
  801f28:	e8 83 fd ff ff       	call   801cb0 <nsipc>
  801f2d:	89 c3                	mov    %eax,%ebx
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 25                	js     801f58 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f33:	be 10 60 c0 00       	mov    $0xc06010,%esi
  801f38:	8b 06                	mov    (%esi),%eax
  801f3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f3e:	c7 44 24 04 00 60 c0 	movl   $0xc06000,0x4(%esp)
  801f45:	00 
  801f46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f49:	89 04 24             	mov    %eax,(%esp)
  801f4c:	e8 14 ec ff ff       	call   800b65 <memmove>
		*addrlen = ret->ret_addrlen;
  801f51:	8b 16                	mov    (%esi),%edx
  801f53:	8b 45 10             	mov    0x10(%ebp),%eax
  801f56:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801f58:	89 d8                	mov    %ebx,%eax
  801f5a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f5d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f60:	89 ec                	mov    %ebp,%esp
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    
	...

00801f70 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f76:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f7c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f81:	39 ca                	cmp    %ecx,%edx
  801f83:	75 04                	jne    801f89 <ipc_find_env+0x19>
  801f85:	b0 00                	mov    $0x0,%al
  801f87:	eb 11                	jmp    801f9a <ipc_find_env+0x2a>
  801f89:	89 c2                	mov    %eax,%edx
  801f8b:	c1 e2 07             	shl    $0x7,%edx
  801f8e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801f94:	8b 12                	mov    (%edx),%edx
  801f96:	39 ca                	cmp    %ecx,%edx
  801f98:	75 0f                	jne    801fa9 <ipc_find_env+0x39>
			return envs[i].env_id;
  801f9a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801f9e:	c1 e0 06             	shl    $0x6,%eax
  801fa1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801fa7:	eb 0e                	jmp    801fb7 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa9:	83 c0 01             	add    $0x1,%eax
  801fac:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fb1:	75 d6                	jne    801f89 <ipc_find_env+0x19>
  801fb3:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801fb7:	5d                   	pop    %ebp
  801fb8:	c3                   	ret    

00801fb9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fb9:	55                   	push   %ebp
  801fba:	89 e5                	mov    %esp,%ebp
  801fbc:	57                   	push   %edi
  801fbd:	56                   	push   %esi
  801fbe:	53                   	push   %ebx
  801fbf:	83 ec 1c             	sub    $0x1c,%esp
  801fc2:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801fcb:	85 db                	test   %ebx,%ebx
  801fcd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fd2:	0f 44 d8             	cmove  %eax,%ebx
  801fd5:	eb 25                	jmp    801ffc <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801fd7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fda:	74 20                	je     801ffc <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801fdc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe0:	c7 44 24 08 06 29 80 	movl   $0x802906,0x8(%esp)
  801fe7:	00 
  801fe8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801fef:	00 
  801ff0:	c7 04 24 24 29 80 00 	movl   $0x802924,(%esp)
  801ff7:	e8 8c e1 ff ff       	call   800188 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801ffc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802003:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802007:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80200b:	89 34 24             	mov    %esi,(%esp)
  80200e:	e8 7b ee ff ff       	call   800e8e <sys_ipc_try_send>
  802013:	85 c0                	test   %eax,%eax
  802015:	75 c0                	jne    801fd7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802017:	e8 f8 ef ff ff       	call   801014 <sys_yield>
}
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    

00802024 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 28             	sub    $0x28,%esp
  80202a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80202d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802030:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802033:	8b 75 08             	mov    0x8(%ebp),%esi
  802036:	8b 45 0c             	mov    0xc(%ebp),%eax
  802039:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80203c:	85 c0                	test   %eax,%eax
  80203e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802043:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802046:	89 04 24             	mov    %eax,(%esp)
  802049:	e8 07 ee ff ff       	call   800e55 <sys_ipc_recv>
  80204e:	89 c3                	mov    %eax,%ebx
  802050:	85 c0                	test   %eax,%eax
  802052:	79 2a                	jns    80207e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802054:	89 44 24 08          	mov    %eax,0x8(%esp)
  802058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80205c:	c7 04 24 2e 29 80 00 	movl   $0x80292e,(%esp)
  802063:	e8 d9 e1 ff ff       	call   800241 <cprintf>
		if(from_env_store != NULL)
  802068:	85 f6                	test   %esi,%esi
  80206a:	74 06                	je     802072 <ipc_recv+0x4e>
			*from_env_store = 0;
  80206c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802072:	85 ff                	test   %edi,%edi
  802074:	74 2c                	je     8020a2 <ipc_recv+0x7e>
			*perm_store = 0;
  802076:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80207c:	eb 24                	jmp    8020a2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80207e:	85 f6                	test   %esi,%esi
  802080:	74 0a                	je     80208c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  802082:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802087:	8b 40 74             	mov    0x74(%eax),%eax
  80208a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80208c:	85 ff                	test   %edi,%edi
  80208e:	74 0a                	je     80209a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802090:	a1 20 40 c0 00       	mov    0xc04020,%eax
  802095:	8b 40 78             	mov    0x78(%eax),%eax
  802098:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80209a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80209f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8020a2:	89 d8                	mov    %ebx,%eax
  8020a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8020a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8020aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8020ad:	89 ec                	mov    %ebp,%esp
  8020af:	5d                   	pop    %ebp
  8020b0:	c3                   	ret    
  8020b1:	00 00                	add    %al,(%eax)
	...

008020b4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8020b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ba:	89 c2                	mov    %eax,%edx
  8020bc:	c1 ea 16             	shr    $0x16,%edx
  8020bf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020c6:	f6 c2 01             	test   $0x1,%dl
  8020c9:	74 20                	je     8020eb <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8020cb:	c1 e8 0c             	shr    $0xc,%eax
  8020ce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020d5:	a8 01                	test   $0x1,%al
  8020d7:	74 12                	je     8020eb <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d9:	c1 e8 0c             	shr    $0xc,%eax
  8020dc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8020e1:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8020e6:	0f b7 c0             	movzwl %ax,%eax
  8020e9:	eb 05                	jmp    8020f0 <pageref+0x3c>
  8020eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020f0:	5d                   	pop    %ebp
  8020f1:	c3                   	ret    
	...

00802100 <__udivdi3>:
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	57                   	push   %edi
  802104:	56                   	push   %esi
  802105:	83 ec 10             	sub    $0x10,%esp
  802108:	8b 45 14             	mov    0x14(%ebp),%eax
  80210b:	8b 55 08             	mov    0x8(%ebp),%edx
  80210e:	8b 75 10             	mov    0x10(%ebp),%esi
  802111:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802114:	85 c0                	test   %eax,%eax
  802116:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802119:	75 35                	jne    802150 <__udivdi3+0x50>
  80211b:	39 fe                	cmp    %edi,%esi
  80211d:	77 61                	ja     802180 <__udivdi3+0x80>
  80211f:	85 f6                	test   %esi,%esi
  802121:	75 0b                	jne    80212e <__udivdi3+0x2e>
  802123:	b8 01 00 00 00       	mov    $0x1,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	f7 f6                	div    %esi
  80212c:	89 c6                	mov    %eax,%esi
  80212e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802131:	31 d2                	xor    %edx,%edx
  802133:	89 f8                	mov    %edi,%eax
  802135:	f7 f6                	div    %esi
  802137:	89 c7                	mov    %eax,%edi
  802139:	89 c8                	mov    %ecx,%eax
  80213b:	f7 f6                	div    %esi
  80213d:	89 c1                	mov    %eax,%ecx
  80213f:	89 fa                	mov    %edi,%edx
  802141:	89 c8                	mov    %ecx,%eax
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	5e                   	pop    %esi
  802147:	5f                   	pop    %edi
  802148:	5d                   	pop    %ebp
  802149:	c3                   	ret    
  80214a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802150:	39 f8                	cmp    %edi,%eax
  802152:	77 1c                	ja     802170 <__udivdi3+0x70>
  802154:	0f bd d0             	bsr    %eax,%edx
  802157:	83 f2 1f             	xor    $0x1f,%edx
  80215a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80215d:	75 39                	jne    802198 <__udivdi3+0x98>
  80215f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802162:	0f 86 a0 00 00 00    	jbe    802208 <__udivdi3+0x108>
  802168:	39 f8                	cmp    %edi,%eax
  80216a:	0f 82 98 00 00 00    	jb     802208 <__udivdi3+0x108>
  802170:	31 ff                	xor    %edi,%edi
  802172:	31 c9                	xor    %ecx,%ecx
  802174:	89 c8                	mov    %ecx,%eax
  802176:	89 fa                	mov    %edi,%edx
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	5e                   	pop    %esi
  80217c:	5f                   	pop    %edi
  80217d:	5d                   	pop    %ebp
  80217e:	c3                   	ret    
  80217f:	90                   	nop
  802180:	89 d1                	mov    %edx,%ecx
  802182:	89 fa                	mov    %edi,%edx
  802184:	89 c8                	mov    %ecx,%eax
  802186:	31 ff                	xor    %edi,%edi
  802188:	f7 f6                	div    %esi
  80218a:	89 c1                	mov    %eax,%ecx
  80218c:	89 fa                	mov    %edi,%edx
  80218e:	89 c8                	mov    %ecx,%eax
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	5e                   	pop    %esi
  802194:	5f                   	pop    %edi
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    
  802197:	90                   	nop
  802198:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80219c:	89 f2                	mov    %esi,%edx
  80219e:	d3 e0                	shl    %cl,%eax
  8021a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8021a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8021ab:	89 c1                	mov    %eax,%ecx
  8021ad:	d3 ea                	shr    %cl,%edx
  8021af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8021b6:	d3 e6                	shl    %cl,%esi
  8021b8:	89 c1                	mov    %eax,%ecx
  8021ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8021bd:	89 fe                	mov    %edi,%esi
  8021bf:	d3 ee                	shr    %cl,%esi
  8021c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021cb:	d3 e7                	shl    %cl,%edi
  8021cd:	89 c1                	mov    %eax,%ecx
  8021cf:	d3 ea                	shr    %cl,%edx
  8021d1:	09 d7                	or     %edx,%edi
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	89 f8                	mov    %edi,%eax
  8021d7:	f7 75 ec             	divl   -0x14(%ebp)
  8021da:	89 d6                	mov    %edx,%esi
  8021dc:	89 c7                	mov    %eax,%edi
  8021de:	f7 65 e8             	mull   -0x18(%ebp)
  8021e1:	39 d6                	cmp    %edx,%esi
  8021e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021e6:	72 30                	jb     802218 <__udivdi3+0x118>
  8021e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	39 c2                	cmp    %eax,%edx
  8021f3:	73 05                	jae    8021fa <__udivdi3+0xfa>
  8021f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8021f8:	74 1e                	je     802218 <__udivdi3+0x118>
  8021fa:	89 f9                	mov    %edi,%ecx
  8021fc:	31 ff                	xor    %edi,%edi
  8021fe:	e9 71 ff ff ff       	jmp    802174 <__udivdi3+0x74>
  802203:	90                   	nop
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	31 ff                	xor    %edi,%edi
  80220a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80220f:	e9 60 ff ff ff       	jmp    802174 <__udivdi3+0x74>
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80221b:	31 ff                	xor    %edi,%edi
  80221d:	89 c8                	mov    %ecx,%eax
  80221f:	89 fa                	mov    %edi,%edx
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	5e                   	pop    %esi
  802225:	5f                   	pop    %edi
  802226:	5d                   	pop    %ebp
  802227:	c3                   	ret    
	...

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	57                   	push   %edi
  802234:	56                   	push   %esi
  802235:	83 ec 20             	sub    $0x20,%esp
  802238:	8b 55 14             	mov    0x14(%ebp),%edx
  80223b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80223e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802241:	8b 75 0c             	mov    0xc(%ebp),%esi
  802244:	85 d2                	test   %edx,%edx
  802246:	89 c8                	mov    %ecx,%eax
  802248:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80224b:	75 13                	jne    802260 <__umoddi3+0x30>
  80224d:	39 f7                	cmp    %esi,%edi
  80224f:	76 3f                	jbe    802290 <__umoddi3+0x60>
  802251:	89 f2                	mov    %esi,%edx
  802253:	f7 f7                	div    %edi
  802255:	89 d0                	mov    %edx,%eax
  802257:	31 d2                	xor    %edx,%edx
  802259:	83 c4 20             	add    $0x20,%esp
  80225c:	5e                   	pop    %esi
  80225d:	5f                   	pop    %edi
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    
  802260:	39 f2                	cmp    %esi,%edx
  802262:	77 4c                	ja     8022b0 <__umoddi3+0x80>
  802264:	0f bd ca             	bsr    %edx,%ecx
  802267:	83 f1 1f             	xor    $0x1f,%ecx
  80226a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80226d:	75 51                	jne    8022c0 <__umoddi3+0x90>
  80226f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802272:	0f 87 e0 00 00 00    	ja     802358 <__umoddi3+0x128>
  802278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227b:	29 f8                	sub    %edi,%eax
  80227d:	19 d6                	sbb    %edx,%esi
  80227f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802285:	89 f2                	mov    %esi,%edx
  802287:	83 c4 20             	add    $0x20,%esp
  80228a:	5e                   	pop    %esi
  80228b:	5f                   	pop    %edi
  80228c:	5d                   	pop    %ebp
  80228d:	c3                   	ret    
  80228e:	66 90                	xchg   %ax,%ax
  802290:	85 ff                	test   %edi,%edi
  802292:	75 0b                	jne    80229f <__umoddi3+0x6f>
  802294:	b8 01 00 00 00       	mov    $0x1,%eax
  802299:	31 d2                	xor    %edx,%edx
  80229b:	f7 f7                	div    %edi
  80229d:	89 c7                	mov    %eax,%edi
  80229f:	89 f0                	mov    %esi,%eax
  8022a1:	31 d2                	xor    %edx,%edx
  8022a3:	f7 f7                	div    %edi
  8022a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a8:	f7 f7                	div    %edi
  8022aa:	eb a9                	jmp    802255 <__umoddi3+0x25>
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 20             	add    $0x20,%esp
  8022b7:	5e                   	pop    %esi
  8022b8:	5f                   	pop    %edi
  8022b9:	5d                   	pop    %ebp
  8022ba:	c3                   	ret    
  8022bb:	90                   	nop
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022c4:	d3 e2                	shl    %cl,%edx
  8022c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8022ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8022d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8022d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022d8:	89 fa                	mov    %edi,%edx
  8022da:	d3 ea                	shr    %cl,%edx
  8022dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8022e3:	d3 e7                	shl    %cl,%edi
  8022e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022ec:	89 f2                	mov    %esi,%edx
  8022ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8022f1:	89 c7                	mov    %eax,%edi
  8022f3:	d3 ea                	shr    %cl,%edx
  8022f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8022fc:	89 c2                	mov    %eax,%edx
  8022fe:	d3 e6                	shl    %cl,%esi
  802300:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802304:	d3 ea                	shr    %cl,%edx
  802306:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80230a:	09 d6                	or     %edx,%esi
  80230c:	89 f0                	mov    %esi,%eax
  80230e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802311:	d3 e7                	shl    %cl,%edi
  802313:	89 f2                	mov    %esi,%edx
  802315:	f7 75 f4             	divl   -0xc(%ebp)
  802318:	89 d6                	mov    %edx,%esi
  80231a:	f7 65 e8             	mull   -0x18(%ebp)
  80231d:	39 d6                	cmp    %edx,%esi
  80231f:	72 2b                	jb     80234c <__umoddi3+0x11c>
  802321:	39 c7                	cmp    %eax,%edi
  802323:	72 23                	jb     802348 <__umoddi3+0x118>
  802325:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802329:	29 c7                	sub    %eax,%edi
  80232b:	19 d6                	sbb    %edx,%esi
  80232d:	89 f0                	mov    %esi,%eax
  80232f:	89 f2                	mov    %esi,%edx
  802331:	d3 ef                	shr    %cl,%edi
  802333:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802337:	d3 e0                	shl    %cl,%eax
  802339:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80233d:	09 f8                	or     %edi,%eax
  80233f:	d3 ea                	shr    %cl,%edx
  802341:	83 c4 20             	add    $0x20,%esp
  802344:	5e                   	pop    %esi
  802345:	5f                   	pop    %edi
  802346:	5d                   	pop    %ebp
  802347:	c3                   	ret    
  802348:	39 d6                	cmp    %edx,%esi
  80234a:	75 d9                	jne    802325 <__umoddi3+0xf5>
  80234c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80234f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802352:	eb d1                	jmp    802325 <__umoddi3+0xf5>
  802354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	0f 82 18 ff ff ff    	jb     802278 <__umoddi3+0x48>
  802360:	e9 1d ff ff ff       	jmp    802282 <__umoddi3+0x52>
