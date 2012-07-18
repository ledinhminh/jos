
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
  80003a:	c7 04 24 c0 1d 80 00 	movl   $0x801dc0,(%esp)
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
  800067:	c7 44 24 08 3b 1e 80 	movl   $0x801e3b,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 58 1e 80 00 	movl   $0x801e58,(%esp)
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
  8000c4:	c7 44 24 08 e0 1d 80 	movl   $0x801de0,0x8(%esp)
  8000cb:	00 
  8000cc:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d3:	00 
  8000d4:	c7 04 24 58 1e 80 00 	movl   $0x801e58,(%esp)
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
  8000ea:	c7 04 24 08 1e 80 00 	movl   $0x801e08,(%esp)
  8000f1:	e8 4b 01 00 00       	call   800241 <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f6:	c7 05 20 50 c0 00 00 	movl   $0x0,0xc05020
  8000fd:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  800100:	c7 44 24 08 67 1e 80 	movl   $0x801e67,0x8(%esp)
  800107:	00 
  800108:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010f:	00 
  800110:	c7 04 24 58 1e 80 00 	movl   $0x801e58,(%esp)
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
  80012e:	e8 e1 0e 00 00       	call   801014 <sys_getenvid>
  800133:	25 ff 03 00 00       	and    $0x3ff,%eax
  800138:	6b c0 7c             	imul   $0x7c,%eax,%eax
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
  800172:	e8 72 14 00 00       	call   8015e9 <close_all>
	sys_env_destroy(0);
  800177:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017e:	e8 cc 0e 00 00       	call   80104f <sys_env_destroy>
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
  800199:	e8 76 0e 00 00       	call   801014 <sys_getenvid>
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 88 1e 80 00 	movl   $0x801e88,(%esp)
  8001bb:	e8 81 00 00 00       	call   800241 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 11 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  8001cf:	c7 04 24 56 1e 80 00 	movl   $0x801e56,(%esp)
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
  800234:	e8 8a 0e 00 00       	call   8010c3 <sys_cputs>

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
  800288:	e8 36 0e 00 00       	call   8010c3 <sys_cputs>
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
  80031d:	e8 1e 18 00 00       	call   801b40 <__udivdi3>
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
  800378:	e8 f3 18 00 00       	call   801c70 <__umoddi3>
  80037d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800381:	0f be 80 ab 1e 80 00 	movsbl 0x801eab(%eax),%eax
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
  800465:	ff 24 95 80 20 80 00 	jmp    *0x802080(,%edx,4)
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
  800538:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  80053f:	85 d2                	test   %edx,%edx
  800541:	75 20                	jne    800563 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800547:	c7 44 24 08 bc 1e 80 	movl   $0x801ebc,0x8(%esp)
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
  800567:	c7 44 24 08 fb 22 80 	movl   $0x8022fb,0x8(%esp)
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
  8005a1:	b8 c5 1e 80 00       	mov    $0x801ec5,%eax
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
  8007e5:	c7 44 24 0c e0 1f 80 	movl   $0x801fe0,0xc(%esp)
  8007ec:	00 
  8007ed:	c7 44 24 08 fb 22 80 	movl   $0x8022fb,0x8(%esp)
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
  800813:	c7 44 24 0c 18 20 80 	movl   $0x802018,0xc(%esp)
  80081a:	00 
  80081b:	c7 44 24 08 fb 22 80 	movl   $0x8022fb,0x8(%esp)
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
  800db7:	c7 44 24 08 20 22 80 	movl   $0x802220,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800dc6:	00 
  800dc7:	c7 04 24 3d 22 80 00 	movl   $0x80223d,(%esp)
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

00800de2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800de8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800def:	00 
  800df0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800df7:	00 
  800df8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dff:	00 
  800e00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0a:	ba 01 00 00 00       	mov    $0x1,%edx
  800e0f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e14:	e8 53 ff ff ff       	call   800d6c <syscall>
}
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e28:	00 
  800e29:	8b 45 14             	mov    0x14(%ebp),%eax
  800e2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e30:	8b 45 10             	mov    0x10(%ebp),%eax
  800e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	89 04 24             	mov    %eax,(%esp)
  800e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e40:	ba 00 00 00 00       	mov    $0x0,%edx
  800e45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e4a:	e8 1d ff ff ff       	call   800d6c <syscall>
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e66:	00 
  800e67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e6e:	00 
  800e6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e72:	89 04 24             	mov    %eax,(%esp)
  800e75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e78:	ba 01 00 00 00       	mov    $0x1,%edx
  800e7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e82:	e8 e5 fe ff ff       	call   800d6c <syscall>
}
  800e87:	c9                   	leave  
  800e88:	c3                   	ret    

00800e89 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e8f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e96:	00 
  800e97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea6:	00 
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	89 04 24             	mov    %eax,(%esp)
  800ead:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eba:	e8 ad fe ff ff       	call   800d6c <syscall>
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800ec7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ece:	00 
  800ecf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ede:	00 
  800edf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee2:	89 04 24             	mov    %eax,(%esp)
  800ee5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee8:	ba 01 00 00 00       	mov    $0x1,%edx
  800eed:	b8 09 00 00 00       	mov    $0x9,%eax
  800ef2:	e8 75 fe ff ff       	call   800d6c <syscall>
}
  800ef7:	c9                   	leave  
  800ef8:	c3                   	ret    

00800ef9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800eff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f06:	00 
  800f07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f16:	00 
  800f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1a:	89 04 24             	mov    %eax,(%esp)
  800f1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f20:	ba 01 00 00 00       	mov    $0x1,%edx
  800f25:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2a:	e8 3d fe ff ff       	call   800d6c <syscall>
}
  800f2f:	c9                   	leave  
  800f30:	c3                   	ret    

00800f31 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f37:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3e:	00 
  800f3f:	8b 45 18             	mov    0x18(%ebp),%eax
  800f42:	0b 45 14             	or     0x14(%ebp),%eax
  800f45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f49:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f53:	89 04 24             	mov    %eax,(%esp)
  800f56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f59:	ba 01 00 00 00       	mov    $0x1,%edx
  800f5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800f63:	e8 04 fe ff ff       	call   800d6c <syscall>
}
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f70:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f77:	00 
  800f78:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f7f:	00 
  800f80:	8b 45 10             	mov    0x10(%ebp),%eax
  800f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8a:	89 04 24             	mov    %eax,(%esp)
  800f8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f90:	ba 01 00 00 00       	mov    $0x1,%edx
  800f95:	b8 05 00 00 00       	mov    $0x5,%eax
  800f9a:	e8 cd fd ff ff       	call   800d6c <syscall>
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fa7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fae:	00 
  800faf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb6:	00 
  800fb7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fbe:	00 
  800fbf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fcb:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fd5:	e8 92 fd ff ff       	call   800d6c <syscall>
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800fe2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe9:	00 
  800fea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff1:	00 
  800ff2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff9:	00 
  800ffa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ffd:	89 04 24             	mov    %eax,(%esp)
  801000:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801003:	ba 00 00 00 00       	mov    $0x0,%edx
  801008:	b8 04 00 00 00       	mov    $0x4,%eax
  80100d:	e8 5a fd ff ff       	call   800d6c <syscall>
}
  801012:	c9                   	leave  
  801013:	c3                   	ret    

00801014 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80101a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801021:	00 
  801022:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801029:	00 
  80102a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801031:	00 
  801032:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801039:	b9 00 00 00 00       	mov    $0x0,%ecx
  80103e:	ba 00 00 00 00       	mov    $0x0,%edx
  801043:	b8 02 00 00 00       	mov    $0x2,%eax
  801048:	e8 1f fd ff ff       	call   800d6c <syscall>
}
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801055:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80105c:	00 
  80105d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801064:	00 
  801065:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80106c:	00 
  80106d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801074:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801077:	ba 01 00 00 00       	mov    $0x1,%edx
  80107c:	b8 03 00 00 00       	mov    $0x3,%eax
  801081:	e8 e6 fc ff ff       	call   800d6c <syscall>
}
  801086:	c9                   	leave  
  801087:	c3                   	ret    

00801088 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80108e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801095:	00 
  801096:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80109d:	00 
  80109e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010a5:	00 
  8010a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8010bc:	e8 ab fc ff ff       	call   800d6c <syscall>
}
  8010c1:	c9                   	leave  
  8010c2:	c3                   	ret    

008010c3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8010c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d0:	00 
  8010d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010d8:	00 
  8010d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010e0:	00 
  8010e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e4:	89 04 24             	mov    %eax,(%esp)
  8010e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f4:	e8 73 fc ff ff       	call   800d6c <syscall>
}
  8010f9:	c9                   	leave  
  8010fa:	c3                   	ret    
  8010fb:	00 00                	add    %al,(%eax)
  8010fd:	00 00                	add    %al,(%eax)
	...

00801100 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	8b 45 08             	mov    0x8(%ebp),%eax
  801106:	05 00 00 00 30       	add    $0x30000000,%eax
  80110b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80110e:	5d                   	pop    %ebp
  80110f:	c3                   	ret    

00801110 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801116:	8b 45 08             	mov    0x8(%ebp),%eax
  801119:	89 04 24             	mov    %eax,(%esp)
  80111c:	e8 df ff ff ff       	call   801100 <fd2num>
  801121:	05 20 00 0d 00       	add    $0xd0020,%eax
  801126:	c1 e0 0c             	shl    $0xc,%eax
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801134:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801139:	a8 01                	test   $0x1,%al
  80113b:	74 36                	je     801173 <fd_alloc+0x48>
  80113d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801142:	a8 01                	test   $0x1,%al
  801144:	74 2d                	je     801173 <fd_alloc+0x48>
  801146:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80114b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801150:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801155:	89 c3                	mov    %eax,%ebx
  801157:	89 c2                	mov    %eax,%edx
  801159:	c1 ea 16             	shr    $0x16,%edx
  80115c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80115f:	f6 c2 01             	test   $0x1,%dl
  801162:	74 14                	je     801178 <fd_alloc+0x4d>
  801164:	89 c2                	mov    %eax,%edx
  801166:	c1 ea 0c             	shr    $0xc,%edx
  801169:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80116c:	f6 c2 01             	test   $0x1,%dl
  80116f:	75 10                	jne    801181 <fd_alloc+0x56>
  801171:	eb 05                	jmp    801178 <fd_alloc+0x4d>
  801173:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801178:	89 1f                	mov    %ebx,(%edi)
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80117f:	eb 17                	jmp    801198 <fd_alloc+0x6d>
  801181:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801186:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118b:	75 c8                	jne    801155 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80118d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801193:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801198:	5b                   	pop    %ebx
  801199:	5e                   	pop    %esi
  80119a:	5f                   	pop    %edi
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a3:	83 f8 1f             	cmp    $0x1f,%eax
  8011a6:	77 36                	ja     8011de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011ad:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8011b0:	89 c2                	mov    %eax,%edx
  8011b2:	c1 ea 16             	shr    $0x16,%edx
  8011b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bc:	f6 c2 01             	test   $0x1,%dl
  8011bf:	74 1d                	je     8011de <fd_lookup+0x41>
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 0c             	shr    $0xc,%edx
  8011c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	74 0c                	je     8011de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d5:	89 02                	mov    %eax,(%edx)
  8011d7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8011dc:	eb 05                	jmp    8011e3 <fd_lookup+0x46>
  8011de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 a0 ff ff ff       	call   80119d <fd_lookup>
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 0e                	js     80120f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801201:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801204:	8b 55 0c             	mov    0xc(%ebp),%edx
  801207:	89 50 04             	mov    %edx,0x4(%eax)
  80120a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	56                   	push   %esi
  801215:	53                   	push   %ebx
  801216:	83 ec 10             	sub    $0x10,%esp
  801219:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80121f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801224:	b8 04 30 80 00       	mov    $0x803004,%eax
  801229:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80122f:	75 11                	jne    801242 <dev_lookup+0x31>
  801231:	eb 04                	jmp    801237 <dev_lookup+0x26>
  801233:	39 08                	cmp    %ecx,(%eax)
  801235:	75 10                	jne    801247 <dev_lookup+0x36>
			*dev = devtab[i];
  801237:	89 03                	mov    %eax,(%ebx)
  801239:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80123e:	66 90                	xchg   %ax,%ax
  801240:	eb 36                	jmp    801278 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801242:	be cc 22 80 00       	mov    $0x8022cc,%esi
  801247:	83 c2 01             	add    $0x1,%edx
  80124a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80124d:	85 c0                	test   %eax,%eax
  80124f:	75 e2                	jne    801233 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801251:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801256:	8b 40 48             	mov    0x48(%eax),%eax
  801259:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80125d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801261:	c7 04 24 4c 22 80 00 	movl   $0x80224c,(%esp)
  801268:	e8 d4 ef ff ff       	call   800241 <cprintf>
	*dev = 0;
  80126d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801278:	83 c4 10             	add    $0x10,%esp
  80127b:	5b                   	pop    %ebx
  80127c:	5e                   	pop    %esi
  80127d:	5d                   	pop    %ebp
  80127e:	c3                   	ret    

0080127f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	53                   	push   %ebx
  801283:	83 ec 24             	sub    $0x24,%esp
  801286:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801289:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	89 04 24             	mov    %eax,(%esp)
  801296:	e8 02 ff ff ff       	call   80119d <fd_lookup>
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 53                	js     8012f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a9:	8b 00                	mov    (%eax),%eax
  8012ab:	89 04 24             	mov    %eax,(%esp)
  8012ae:	e8 5e ff ff ff       	call   801211 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	78 3b                	js     8012f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8012b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8012c3:	74 2d                	je     8012f2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012cf:	00 00 00 
	stat->st_isdir = 0;
  8012d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012d9:	00 00 00 
	stat->st_dev = dev;
  8012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ec:	89 14 24             	mov    %edx,(%esp)
  8012ef:	ff 50 14             	call   *0x14(%eax)
}
  8012f2:	83 c4 24             	add    $0x24,%esp
  8012f5:	5b                   	pop    %ebx
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	53                   	push   %ebx
  8012fc:	83 ec 24             	sub    $0x24,%esp
  8012ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801302:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801305:	89 44 24 04          	mov    %eax,0x4(%esp)
  801309:	89 1c 24             	mov    %ebx,(%esp)
  80130c:	e8 8c fe ff ff       	call   80119d <fd_lookup>
  801311:	85 c0                	test   %eax,%eax
  801313:	78 5f                	js     801374 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801318:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131f:	8b 00                	mov    (%eax),%eax
  801321:	89 04 24             	mov    %eax,(%esp)
  801324:	e8 e8 fe ff ff       	call   801211 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801329:	85 c0                	test   %eax,%eax
  80132b:	78 47                	js     801374 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801330:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801334:	75 23                	jne    801359 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801336:	a1 20 40 c0 00       	mov    0xc04020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80133b:	8b 40 48             	mov    0x48(%eax),%eax
  80133e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	c7 04 24 6c 22 80 00 	movl   $0x80226c,(%esp)
  80134d:	e8 ef ee ff ff       	call   800241 <cprintf>
  801352:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801357:	eb 1b                	jmp    801374 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801359:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135c:	8b 48 18             	mov    0x18(%eax),%ecx
  80135f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801364:	85 c9                	test   %ecx,%ecx
  801366:	74 0c                	je     801374 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801368:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136f:	89 14 24             	mov    %edx,(%esp)
  801372:	ff d1                	call   *%ecx
}
  801374:	83 c4 24             	add    $0x24,%esp
  801377:	5b                   	pop    %ebx
  801378:	5d                   	pop    %ebp
  801379:	c3                   	ret    

0080137a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	53                   	push   %ebx
  80137e:	83 ec 24             	sub    $0x24,%esp
  801381:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801384:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801387:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138b:	89 1c 24             	mov    %ebx,(%esp)
  80138e:	e8 0a fe ff ff       	call   80119d <fd_lookup>
  801393:	85 c0                	test   %eax,%eax
  801395:	78 66                	js     8013fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a1:	8b 00                	mov    (%eax),%eax
  8013a3:	89 04 24             	mov    %eax,(%esp)
  8013a6:	e8 66 fe ff ff       	call   801211 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 4e                	js     8013fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8013b6:	75 23                	jne    8013db <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013b8:	a1 20 40 c0 00       	mov    0xc04020,%eax
  8013bd:	8b 40 48             	mov    0x48(%eax),%eax
  8013c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c8:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  8013cf:	e8 6d ee ff ff       	call   800241 <cprintf>
  8013d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013d9:	eb 22                	jmp    8013fd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8013db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013de:	8b 48 0c             	mov    0xc(%eax),%ecx
  8013e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e6:	85 c9                	test   %ecx,%ecx
  8013e8:	74 13                	je     8013fd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	89 14 24             	mov    %edx,(%esp)
  8013fb:	ff d1                	call   *%ecx
}
  8013fd:	83 c4 24             	add    $0x24,%esp
  801400:	5b                   	pop    %ebx
  801401:	5d                   	pop    %ebp
  801402:	c3                   	ret    

00801403 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	53                   	push   %ebx
  801407:	83 ec 24             	sub    $0x24,%esp
  80140a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801410:	89 44 24 04          	mov    %eax,0x4(%esp)
  801414:	89 1c 24             	mov    %ebx,(%esp)
  801417:	e8 81 fd ff ff       	call   80119d <fd_lookup>
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 6b                	js     80148b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801420:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801423:	89 44 24 04          	mov    %eax,0x4(%esp)
  801427:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142a:	8b 00                	mov    (%eax),%eax
  80142c:	89 04 24             	mov    %eax,(%esp)
  80142f:	e8 dd fd ff ff       	call   801211 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801434:	85 c0                	test   %eax,%eax
  801436:	78 53                	js     80148b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801438:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80143b:	8b 42 08             	mov    0x8(%edx),%eax
  80143e:	83 e0 03             	and    $0x3,%eax
  801441:	83 f8 01             	cmp    $0x1,%eax
  801444:	75 23                	jne    801469 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801446:	a1 20 40 c0 00       	mov    0xc04020,%eax
  80144b:	8b 40 48             	mov    0x48(%eax),%eax
  80144e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801452:	89 44 24 04          	mov    %eax,0x4(%esp)
  801456:	c7 04 24 ad 22 80 00 	movl   $0x8022ad,(%esp)
  80145d:	e8 df ed ff ff       	call   800241 <cprintf>
  801462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801467:	eb 22                	jmp    80148b <read+0x88>
	}
	if (!dev->dev_read)
  801469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146c:	8b 48 08             	mov    0x8(%eax),%ecx
  80146f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801474:	85 c9                	test   %ecx,%ecx
  801476:	74 13                	je     80148b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801478:	8b 45 10             	mov    0x10(%ebp),%eax
  80147b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80147f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801482:	89 44 24 04          	mov    %eax,0x4(%esp)
  801486:	89 14 24             	mov    %edx,(%esp)
  801489:	ff d1                	call   *%ecx
}
  80148b:	83 c4 24             	add    $0x24,%esp
  80148e:	5b                   	pop    %ebx
  80148f:	5d                   	pop    %ebp
  801490:	c3                   	ret    

00801491 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	57                   	push   %edi
  801495:	56                   	push   %esi
  801496:	53                   	push   %ebx
  801497:	83 ec 1c             	sub    $0x1c,%esp
  80149a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80149d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8014af:	85 f6                	test   %esi,%esi
  8014b1:	74 29                	je     8014dc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014b3:	89 f0                	mov    %esi,%eax
  8014b5:	29 d0                	sub    %edx,%eax
  8014b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014bb:	03 55 0c             	add    0xc(%ebp),%edx
  8014be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c2:	89 3c 24             	mov    %edi,(%esp)
  8014c5:	e8 39 ff ff ff       	call   801403 <read>
		if (m < 0)
  8014ca:	85 c0                	test   %eax,%eax
  8014cc:	78 0e                	js     8014dc <readn+0x4b>
			return m;
		if (m == 0)
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	74 08                	je     8014da <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d2:	01 c3                	add    %eax,%ebx
  8014d4:	89 da                	mov    %ebx,%edx
  8014d6:	39 f3                	cmp    %esi,%ebx
  8014d8:	72 d9                	jb     8014b3 <readn+0x22>
  8014da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014dc:	83 c4 1c             	add    $0x1c,%esp
  8014df:	5b                   	pop    %ebx
  8014e0:	5e                   	pop    %esi
  8014e1:	5f                   	pop    %edi
  8014e2:	5d                   	pop    %ebp
  8014e3:	c3                   	ret    

008014e4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	83 ec 28             	sub    $0x28,%esp
  8014ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8014f0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014f3:	89 34 24             	mov    %esi,(%esp)
  8014f6:	e8 05 fc ff ff       	call   801100 <fd2num>
  8014fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801502:	89 04 24             	mov    %eax,(%esp)
  801505:	e8 93 fc ff ff       	call   80119d <fd_lookup>
  80150a:	89 c3                	mov    %eax,%ebx
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 05                	js     801515 <fd_close+0x31>
  801510:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801513:	74 0e                	je     801523 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801515:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801519:	b8 00 00 00 00       	mov    $0x0,%eax
  80151e:	0f 44 d8             	cmove  %eax,%ebx
  801521:	eb 3d                	jmp    801560 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801523:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801526:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152a:	8b 06                	mov    (%esi),%eax
  80152c:	89 04 24             	mov    %eax,(%esp)
  80152f:	e8 dd fc ff ff       	call   801211 <dev_lookup>
  801534:	89 c3                	mov    %eax,%ebx
  801536:	85 c0                	test   %eax,%eax
  801538:	78 16                	js     801550 <fd_close+0x6c>
		if (dev->dev_close)
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	8b 40 10             	mov    0x10(%eax),%eax
  801540:	bb 00 00 00 00       	mov    $0x0,%ebx
  801545:	85 c0                	test   %eax,%eax
  801547:	74 07                	je     801550 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801549:	89 34 24             	mov    %esi,(%esp)
  80154c:	ff d0                	call   *%eax
  80154e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801550:	89 74 24 04          	mov    %esi,0x4(%esp)
  801554:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80155b:	e8 99 f9 ff ff       	call   800ef9 <sys_page_unmap>
	return r;
}
  801560:	89 d8                	mov    %ebx,%eax
  801562:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801565:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801568:	89 ec                	mov    %ebp,%esp
  80156a:	5d                   	pop    %ebp
  80156b:	c3                   	ret    

0080156c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801572:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801575:	89 44 24 04          	mov    %eax,0x4(%esp)
  801579:	8b 45 08             	mov    0x8(%ebp),%eax
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	e8 19 fc ff ff       	call   80119d <fd_lookup>
  801584:	85 c0                	test   %eax,%eax
  801586:	78 13                	js     80159b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801588:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80158f:	00 
  801590:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801593:	89 04 24             	mov    %eax,(%esp)
  801596:	e8 49 ff ff ff       	call   8014e4 <fd_close>
}
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	83 ec 18             	sub    $0x18,%esp
  8015a3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015a6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015b0:	00 
  8015b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b4:	89 04 24             	mov    %eax,(%esp)
  8015b7:	e8 78 03 00 00       	call   801934 <open>
  8015bc:	89 c3                	mov    %eax,%ebx
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	78 1b                	js     8015dd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c9:	89 1c 24             	mov    %ebx,(%esp)
  8015cc:	e8 ae fc ff ff       	call   80127f <fstat>
  8015d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8015d3:	89 1c 24             	mov    %ebx,(%esp)
  8015d6:	e8 91 ff ff ff       	call   80156c <close>
  8015db:	89 f3                	mov    %esi,%ebx
	return r;
}
  8015dd:	89 d8                	mov    %ebx,%eax
  8015df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015e5:	89 ec                	mov    %ebp,%esp
  8015e7:	5d                   	pop    %ebp
  8015e8:	c3                   	ret    

008015e9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	53                   	push   %ebx
  8015ed:	83 ec 14             	sub    $0x14,%esp
  8015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015f5:	89 1c 24             	mov    %ebx,(%esp)
  8015f8:	e8 6f ff ff ff       	call   80156c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015fd:	83 c3 01             	add    $0x1,%ebx
  801600:	83 fb 20             	cmp    $0x20,%ebx
  801603:	75 f0                	jne    8015f5 <close_all+0xc>
		close(i);
}
  801605:	83 c4 14             	add    $0x14,%esp
  801608:	5b                   	pop    %ebx
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 58             	sub    $0x58,%esp
  801611:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801614:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801617:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80161a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80161d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801620:	89 44 24 04          	mov    %eax,0x4(%esp)
  801624:	8b 45 08             	mov    0x8(%ebp),%eax
  801627:	89 04 24             	mov    %eax,(%esp)
  80162a:	e8 6e fb ff ff       	call   80119d <fd_lookup>
  80162f:	89 c3                	mov    %eax,%ebx
  801631:	85 c0                	test   %eax,%eax
  801633:	0f 88 e0 00 00 00    	js     801719 <dup+0x10e>
		return r;
	close(newfdnum);
  801639:	89 3c 24             	mov    %edi,(%esp)
  80163c:	e8 2b ff ff ff       	call   80156c <close>

	newfd = INDEX2FD(newfdnum);
  801641:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801647:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80164a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80164d:	89 04 24             	mov    %eax,(%esp)
  801650:	e8 bb fa ff ff       	call   801110 <fd2data>
  801655:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801657:	89 34 24             	mov    %esi,(%esp)
  80165a:	e8 b1 fa ff ff       	call   801110 <fd2data>
  80165f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801662:	89 da                	mov    %ebx,%edx
  801664:	89 d8                	mov    %ebx,%eax
  801666:	c1 e8 16             	shr    $0x16,%eax
  801669:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801670:	a8 01                	test   $0x1,%al
  801672:	74 43                	je     8016b7 <dup+0xac>
  801674:	c1 ea 0c             	shr    $0xc,%edx
  801677:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80167e:	a8 01                	test   $0x1,%al
  801680:	74 35                	je     8016b7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801682:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801689:	25 07 0e 00 00       	and    $0xe07,%eax
  80168e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801692:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801695:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801699:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016a0:	00 
  8016a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016ac:	e8 80 f8 ff ff       	call   800f31 <sys_page_map>
  8016b1:	89 c3                	mov    %eax,%ebx
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	78 3f                	js     8016f6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	c1 ea 0c             	shr    $0xc,%edx
  8016bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016c6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8016d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016db:	00 
  8016dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e7:	e8 45 f8 ff ff       	call   800f31 <sys_page_map>
  8016ec:	89 c3                	mov    %eax,%ebx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 04                	js     8016f6 <dup+0xeb>
  8016f2:	89 fb                	mov    %edi,%ebx
  8016f4:	eb 23                	jmp    801719 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801701:	e8 f3 f7 ff ff       	call   800ef9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801706:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801709:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801714:	e8 e0 f7 ff ff       	call   800ef9 <sys_page_unmap>
	return r;
}
  801719:	89 d8                	mov    %ebx,%eax
  80171b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80171e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801721:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801724:	89 ec                	mov    %ebp,%esp
  801726:	5d                   	pop    %ebp
  801727:	c3                   	ret    

00801728 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	83 ec 18             	sub    $0x18,%esp
  80172e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801731:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801734:	89 c3                	mov    %eax,%ebx
  801736:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801738:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173f:	75 11                	jne    801752 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801741:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801748:	e8 a3 02 00 00       	call   8019f0 <ipc_find_env>
  80174d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801752:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801759:	00 
  80175a:	c7 44 24 08 00 50 c0 	movl   $0xc05000,0x8(%esp)
  801761:	00 
  801762:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801766:	a1 00 40 80 00       	mov    0x804000,%eax
  80176b:	89 04 24             	mov    %eax,(%esp)
  80176e:	e8 c1 02 00 00       	call   801a34 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801773:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80177a:	00 
  80177b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80177f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801786:	e8 18 03 00 00       	call   801aa3 <ipc_recv>
}
  80178b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80178e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801791:	89 ec                	mov    %ebp,%esp
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    

00801795 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80179b:	8b 45 08             	mov    0x8(%ebp),%eax
  80179e:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a1:	a3 00 50 c0 00       	mov    %eax,0xc05000
	fsipcbuf.set_size.req_size = newsize;
  8017a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a9:	a3 04 50 c0 00       	mov    %eax,0xc05004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017b8:	e8 6b ff ff ff       	call   801728 <fsipc>
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017cb:	a3 00 50 c0 00       	mov    %eax,0xc05000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8017da:	e8 49 ff ff ff       	call   801728 <fsipc>
}
  8017df:	c9                   	leave  
  8017e0:	c3                   	ret    

008017e1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8017f1:	e8 32 ff ff ff       	call   801728 <fsipc>
}
  8017f6:	c9                   	leave  
  8017f7:	c3                   	ret    

008017f8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f8:	55                   	push   %ebp
  8017f9:	89 e5                	mov    %esp,%ebp
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 14             	sub    $0x14,%esp
  8017ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 40 0c             	mov    0xc(%eax),%eax
  801808:	a3 00 50 c0 00       	mov    %eax,0xc05000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	b8 05 00 00 00       	mov    $0x5,%eax
  801817:	e8 0c ff ff ff       	call   801728 <fsipc>
  80181c:	85 c0                	test   %eax,%eax
  80181e:	78 2b                	js     80184b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801820:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  801827:	00 
  801828:	89 1c 24             	mov    %ebx,(%esp)
  80182b:	e8 4a f1 ff ff       	call   80097a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801830:	a1 80 50 c0 00       	mov    0xc05080,%eax
  801835:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80183b:	a1 84 50 c0 00       	mov    0xc05084,%eax
  801840:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801846:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80184b:	83 c4 14             	add    $0x14,%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	83 ec 18             	sub    $0x18,%esp
  801857:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80185a:	8b 55 08             	mov    0x8(%ebp),%edx
  80185d:	8b 52 0c             	mov    0xc(%edx),%edx
  801860:	89 15 00 50 c0 00    	mov    %edx,0xc05000
  fsipcbuf.write.req_n = n;
  801866:	a3 04 50 c0 00       	mov    %eax,0xc05004
  memmove(fsipcbuf.write.req_buf, buf,
  80186b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801870:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801875:	0f 47 c2             	cmova  %edx,%eax
  801878:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801883:	c7 04 24 08 50 c0 00 	movl   $0xc05008,(%esp)
  80188a:	e8 d6 f2 ff ff       	call   800b65 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 04 00 00 00       	mov    $0x4,%eax
  801899:	e8 8a fe ff ff       	call   801728 <fsipc>
}
  80189e:	c9                   	leave  
  80189f:	c3                   	ret    

008018a0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	53                   	push   %ebx
  8018a4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ad:	a3 00 50 c0 00       	mov    %eax,0xc05000
  fsipcbuf.read.req_n = n;
  8018b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018b5:	a3 04 50 c0 00       	mov    %eax,0xc05004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bf:	b8 03 00 00 00       	mov    $0x3,%eax
  8018c4:	e8 5f fe ff ff       	call   801728 <fsipc>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 17                	js     8018e6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018d3:	c7 44 24 04 00 50 c0 	movl   $0xc05000,0x4(%esp)
  8018da:	00 
  8018db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018de:	89 04 24             	mov    %eax,(%esp)
  8018e1:	e8 7f f2 ff ff       	call   800b65 <memmove>
  return r;	
}
  8018e6:	89 d8                	mov    %ebx,%eax
  8018e8:	83 c4 14             	add    $0x14,%esp
  8018eb:	5b                   	pop    %ebx
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	53                   	push   %ebx
  8018f2:	83 ec 14             	sub    $0x14,%esp
  8018f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8018f8:	89 1c 24             	mov    %ebx,(%esp)
  8018fb:	e8 30 f0 ff ff       	call   800930 <strlen>
  801900:	89 c2                	mov    %eax,%edx
  801902:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801907:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80190d:	7f 1f                	jg     80192e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80190f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801913:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  80191a:	e8 5b f0 ff ff       	call   80097a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80191f:	ba 00 00 00 00       	mov    $0x0,%edx
  801924:	b8 07 00 00 00       	mov    $0x7,%eax
  801929:	e8 fa fd ff ff       	call   801728 <fsipc>
}
  80192e:	83 c4 14             	add    $0x14,%esp
  801931:	5b                   	pop    %ebx
  801932:	5d                   	pop    %ebp
  801933:	c3                   	ret    

00801934 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	83 ec 28             	sub    $0x28,%esp
  80193a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80193d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801940:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801943:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801946:	89 04 24             	mov    %eax,(%esp)
  801949:	e8 dd f7 ff ff       	call   80112b <fd_alloc>
  80194e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801950:	85 c0                	test   %eax,%eax
  801952:	0f 88 89 00 00 00    	js     8019e1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801958:	89 34 24             	mov    %esi,(%esp)
  80195b:	e8 d0 ef ff ff       	call   800930 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801960:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801965:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80196a:	7f 75                	jg     8019e1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80196c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801970:	c7 04 24 00 50 c0 00 	movl   $0xc05000,(%esp)
  801977:	e8 fe ef ff ff       	call   80097a <strcpy>
  fsipcbuf.open.req_omode = mode;
  80197c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197f:	a3 00 54 c0 00       	mov    %eax,0xc05400
  r = fsipc(FSREQ_OPEN, fd);
  801984:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801987:	b8 01 00 00 00       	mov    $0x1,%eax
  80198c:	e8 97 fd ff ff       	call   801728 <fsipc>
  801991:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801993:	85 c0                	test   %eax,%eax
  801995:	78 0f                	js     8019a6 <open+0x72>
  return fd2num(fd);
  801997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80199a:	89 04 24             	mov    %eax,(%esp)
  80199d:	e8 5e f7 ff ff       	call   801100 <fd2num>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	eb 3b                	jmp    8019e1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8019a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ad:	00 
  8019ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019b1:	89 04 24             	mov    %eax,(%esp)
  8019b4:	e8 2b fb ff ff       	call   8014e4 <fd_close>
  8019b9:	85 c0                	test   %eax,%eax
  8019bb:	74 24                	je     8019e1 <open+0xad>
  8019bd:	c7 44 24 0c d4 22 80 	movl   $0x8022d4,0xc(%esp)
  8019c4:	00 
  8019c5:	c7 44 24 08 e9 22 80 	movl   $0x8022e9,0x8(%esp)
  8019cc:	00 
  8019cd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8019d4:	00 
  8019d5:	c7 04 24 fe 22 80 00 	movl   $0x8022fe,(%esp)
  8019dc:	e8 a7 e7 ff ff       	call   800188 <_panic>
  return r;
}
  8019e1:	89 d8                	mov    %ebx,%eax
  8019e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019e6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019e9:	89 ec                	mov    %ebp,%esp
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    
  8019ed:	00 00                	add    %al,(%eax)
	...

008019f0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8019f6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8019fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801a01:	39 ca                	cmp    %ecx,%edx
  801a03:	75 04                	jne    801a09 <ipc_find_env+0x19>
  801a05:	b0 00                	mov    $0x0,%al
  801a07:	eb 0f                	jmp    801a18 <ipc_find_env+0x28>
  801a09:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a0c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801a12:	8b 12                	mov    (%edx),%edx
  801a14:	39 ca                	cmp    %ecx,%edx
  801a16:	75 0c                	jne    801a24 <ipc_find_env+0x34>
			return envs[i].env_id;
  801a18:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a1b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801a20:	8b 00                	mov    (%eax),%eax
  801a22:	eb 0e                	jmp    801a32 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a24:	83 c0 01             	add    $0x1,%eax
  801a27:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a2c:	75 db                	jne    801a09 <ipc_find_env+0x19>
  801a2e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a34:	55                   	push   %ebp
  801a35:	89 e5                	mov    %esp,%ebp
  801a37:	57                   	push   %edi
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 1c             	sub    $0x1c,%esp
  801a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a40:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a46:	85 db                	test   %ebx,%ebx
  801a48:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a4d:	0f 44 d8             	cmove  %eax,%ebx
  801a50:	eb 29                	jmp    801a7b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801a52:	85 c0                	test   %eax,%eax
  801a54:	79 25                	jns    801a7b <ipc_send+0x47>
  801a56:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a59:	74 20                	je     801a7b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801a5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a5f:	c7 44 24 08 09 23 80 	movl   $0x802309,0x8(%esp)
  801a66:	00 
  801a67:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801a6e:	00 
  801a6f:	c7 04 24 27 23 80 00 	movl   $0x802327,(%esp)
  801a76:	e8 0d e7 ff ff       	call   800188 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a86:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a8a:	89 34 24             	mov    %esi,(%esp)
  801a8d:	e8 89 f3 ff ff       	call   800e1b <sys_ipc_try_send>
  801a92:	85 c0                	test   %eax,%eax
  801a94:	75 bc                	jne    801a52 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801a96:	e8 06 f5 ff ff       	call   800fa1 <sys_yield>
}
  801a9b:	83 c4 1c             	add    $0x1c,%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5f                   	pop    %edi
  801aa1:	5d                   	pop    %ebp
  801aa2:	c3                   	ret    

00801aa3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	83 ec 28             	sub    $0x28,%esp
  801aa9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801aac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801aaf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ab2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ab5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801abb:	85 c0                	test   %eax,%eax
  801abd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ac2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801ac5:	89 04 24             	mov    %eax,(%esp)
  801ac8:	e8 15 f3 ff ff       	call   800de2 <sys_ipc_recv>
  801acd:	89 c3                	mov    %eax,%ebx
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	79 2a                	jns    801afd <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801ad3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adb:	c7 04 24 31 23 80 00 	movl   $0x802331,(%esp)
  801ae2:	e8 5a e7 ff ff       	call   800241 <cprintf>
		if(from_env_store != NULL)
  801ae7:	85 f6                	test   %esi,%esi
  801ae9:	74 06                	je     801af1 <ipc_recv+0x4e>
			*from_env_store = 0;
  801aeb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801af1:	85 ff                	test   %edi,%edi
  801af3:	74 2d                	je     801b22 <ipc_recv+0x7f>
			*perm_store = 0;
  801af5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801afb:	eb 25                	jmp    801b22 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801afd:	85 f6                	test   %esi,%esi
  801aff:	90                   	nop
  801b00:	74 0a                	je     801b0c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801b02:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b07:	8b 40 74             	mov    0x74(%eax),%eax
  801b0a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b0c:	85 ff                	test   %edi,%edi
  801b0e:	74 0a                	je     801b1a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801b10:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b15:	8b 40 78             	mov    0x78(%eax),%eax
  801b18:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b1a:	a1 20 40 c0 00       	mov    0xc04020,%eax
  801b1f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801b22:	89 d8                	mov    %ebx,%eax
  801b24:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b27:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b2a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b2d:	89 ec                	mov    %ebp,%esp
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    
	...

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	57                   	push   %edi
  801b44:	56                   	push   %esi
  801b45:	83 ec 10             	sub    $0x10,%esp
  801b48:	8b 45 14             	mov    0x14(%ebp),%eax
  801b4b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b4e:	8b 75 10             	mov    0x10(%ebp),%esi
  801b51:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b54:	85 c0                	test   %eax,%eax
  801b56:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801b59:	75 35                	jne    801b90 <__udivdi3+0x50>
  801b5b:	39 fe                	cmp    %edi,%esi
  801b5d:	77 61                	ja     801bc0 <__udivdi3+0x80>
  801b5f:	85 f6                	test   %esi,%esi
  801b61:	75 0b                	jne    801b6e <__udivdi3+0x2e>
  801b63:	b8 01 00 00 00       	mov    $0x1,%eax
  801b68:	31 d2                	xor    %edx,%edx
  801b6a:	f7 f6                	div    %esi
  801b6c:	89 c6                	mov    %eax,%esi
  801b6e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801b71:	31 d2                	xor    %edx,%edx
  801b73:	89 f8                	mov    %edi,%eax
  801b75:	f7 f6                	div    %esi
  801b77:	89 c7                	mov    %eax,%edi
  801b79:	89 c8                	mov    %ecx,%eax
  801b7b:	f7 f6                	div    %esi
  801b7d:	89 c1                	mov    %eax,%ecx
  801b7f:	89 fa                	mov    %edi,%edx
  801b81:	89 c8                	mov    %ecx,%eax
  801b83:	83 c4 10             	add    $0x10,%esp
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    
  801b8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b90:	39 f8                	cmp    %edi,%eax
  801b92:	77 1c                	ja     801bb0 <__udivdi3+0x70>
  801b94:	0f bd d0             	bsr    %eax,%edx
  801b97:	83 f2 1f             	xor    $0x1f,%edx
  801b9a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b9d:	75 39                	jne    801bd8 <__udivdi3+0x98>
  801b9f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ba2:	0f 86 a0 00 00 00    	jbe    801c48 <__udivdi3+0x108>
  801ba8:	39 f8                	cmp    %edi,%eax
  801baa:	0f 82 98 00 00 00    	jb     801c48 <__udivdi3+0x108>
  801bb0:	31 ff                	xor    %edi,%edi
  801bb2:	31 c9                	xor    %ecx,%ecx
  801bb4:	89 c8                	mov    %ecx,%eax
  801bb6:	89 fa                	mov    %edi,%edx
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	5e                   	pop    %esi
  801bbc:	5f                   	pop    %edi
  801bbd:	5d                   	pop    %ebp
  801bbe:	c3                   	ret    
  801bbf:	90                   	nop
  801bc0:	89 d1                	mov    %edx,%ecx
  801bc2:	89 fa                	mov    %edi,%edx
  801bc4:	89 c8                	mov    %ecx,%eax
  801bc6:	31 ff                	xor    %edi,%edi
  801bc8:	f7 f6                	div    %esi
  801bca:	89 c1                	mov    %eax,%ecx
  801bcc:	89 fa                	mov    %edi,%edx
  801bce:	89 c8                	mov    %ecx,%eax
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	5e                   	pop    %esi
  801bd4:	5f                   	pop    %edi
  801bd5:	5d                   	pop    %ebp
  801bd6:	c3                   	ret    
  801bd7:	90                   	nop
  801bd8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bdc:	89 f2                	mov    %esi,%edx
  801bde:	d3 e0                	shl    %cl,%eax
  801be0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801be3:	b8 20 00 00 00       	mov    $0x20,%eax
  801be8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801beb:	89 c1                	mov    %eax,%ecx
  801bed:	d3 ea                	shr    %cl,%edx
  801bef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bf3:	0b 55 ec             	or     -0x14(%ebp),%edx
  801bf6:	d3 e6                	shl    %cl,%esi
  801bf8:	89 c1                	mov    %eax,%ecx
  801bfa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801bfd:	89 fe                	mov    %edi,%esi
  801bff:	d3 ee                	shr    %cl,%esi
  801c01:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c05:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c08:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c0b:	d3 e7                	shl    %cl,%edi
  801c0d:	89 c1                	mov    %eax,%ecx
  801c0f:	d3 ea                	shr    %cl,%edx
  801c11:	09 d7                	or     %edx,%edi
  801c13:	89 f2                	mov    %esi,%edx
  801c15:	89 f8                	mov    %edi,%eax
  801c17:	f7 75 ec             	divl   -0x14(%ebp)
  801c1a:	89 d6                	mov    %edx,%esi
  801c1c:	89 c7                	mov    %eax,%edi
  801c1e:	f7 65 e8             	mull   -0x18(%ebp)
  801c21:	39 d6                	cmp    %edx,%esi
  801c23:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c26:	72 30                	jb     801c58 <__udivdi3+0x118>
  801c28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c2b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c2f:	d3 e2                	shl    %cl,%edx
  801c31:	39 c2                	cmp    %eax,%edx
  801c33:	73 05                	jae    801c3a <__udivdi3+0xfa>
  801c35:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801c38:	74 1e                	je     801c58 <__udivdi3+0x118>
  801c3a:	89 f9                	mov    %edi,%ecx
  801c3c:	31 ff                	xor    %edi,%edi
  801c3e:	e9 71 ff ff ff       	jmp    801bb4 <__udivdi3+0x74>
  801c43:	90                   	nop
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	31 ff                	xor    %edi,%edi
  801c4a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801c4f:	e9 60 ff ff ff       	jmp    801bb4 <__udivdi3+0x74>
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801c5b:	31 ff                	xor    %edi,%edi
  801c5d:	89 c8                	mov    %ecx,%eax
  801c5f:	89 fa                	mov    %edi,%edx
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	5e                   	pop    %esi
  801c65:	5f                   	pop    %edi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    
	...

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	57                   	push   %edi
  801c74:	56                   	push   %esi
  801c75:	83 ec 20             	sub    $0x20,%esp
  801c78:	8b 55 14             	mov    0x14(%ebp),%edx
  801c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c7e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c81:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c84:	85 d2                	test   %edx,%edx
  801c86:	89 c8                	mov    %ecx,%eax
  801c88:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c8b:	75 13                	jne    801ca0 <__umoddi3+0x30>
  801c8d:	39 f7                	cmp    %esi,%edi
  801c8f:	76 3f                	jbe    801cd0 <__umoddi3+0x60>
  801c91:	89 f2                	mov    %esi,%edx
  801c93:	f7 f7                	div    %edi
  801c95:	89 d0                	mov    %edx,%eax
  801c97:	31 d2                	xor    %edx,%edx
  801c99:	83 c4 20             	add    $0x20,%esp
  801c9c:	5e                   	pop    %esi
  801c9d:	5f                   	pop    %edi
  801c9e:	5d                   	pop    %ebp
  801c9f:	c3                   	ret    
  801ca0:	39 f2                	cmp    %esi,%edx
  801ca2:	77 4c                	ja     801cf0 <__umoddi3+0x80>
  801ca4:	0f bd ca             	bsr    %edx,%ecx
  801ca7:	83 f1 1f             	xor    $0x1f,%ecx
  801caa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801cad:	75 51                	jne    801d00 <__umoddi3+0x90>
  801caf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801cb2:	0f 87 e0 00 00 00    	ja     801d98 <__umoddi3+0x128>
  801cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbb:	29 f8                	sub    %edi,%eax
  801cbd:	19 d6                	sbb    %edx,%esi
  801cbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc5:	89 f2                	mov    %esi,%edx
  801cc7:	83 c4 20             	add    $0x20,%esp
  801cca:	5e                   	pop    %esi
  801ccb:	5f                   	pop    %edi
  801ccc:	5d                   	pop    %ebp
  801ccd:	c3                   	ret    
  801cce:	66 90                	xchg   %ax,%ax
  801cd0:	85 ff                	test   %edi,%edi
  801cd2:	75 0b                	jne    801cdf <__umoddi3+0x6f>
  801cd4:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd9:	31 d2                	xor    %edx,%edx
  801cdb:	f7 f7                	div    %edi
  801cdd:	89 c7                	mov    %eax,%edi
  801cdf:	89 f0                	mov    %esi,%eax
  801ce1:	31 d2                	xor    %edx,%edx
  801ce3:	f7 f7                	div    %edi
  801ce5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce8:	f7 f7                	div    %edi
  801cea:	eb a9                	jmp    801c95 <__umoddi3+0x25>
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	83 c4 20             	add    $0x20,%esp
  801cf7:	5e                   	pop    %esi
  801cf8:	5f                   	pop    %edi
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    
  801cfb:	90                   	nop
  801cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d00:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d04:	d3 e2                	shl    %cl,%edx
  801d06:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d09:	ba 20 00 00 00       	mov    $0x20,%edx
  801d0e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801d11:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d14:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d18:	89 fa                	mov    %edi,%edx
  801d1a:	d3 ea                	shr    %cl,%edx
  801d1c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d20:	0b 55 f4             	or     -0xc(%ebp),%edx
  801d23:	d3 e7                	shl    %cl,%edi
  801d25:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d29:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d2c:	89 f2                	mov    %esi,%edx
  801d2e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801d31:	89 c7                	mov    %eax,%edi
  801d33:	d3 ea                	shr    %cl,%edx
  801d35:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801d3c:	89 c2                	mov    %eax,%edx
  801d3e:	d3 e6                	shl    %cl,%esi
  801d40:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d44:	d3 ea                	shr    %cl,%edx
  801d46:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d4a:	09 d6                	or     %edx,%esi
  801d4c:	89 f0                	mov    %esi,%eax
  801d4e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801d51:	d3 e7                	shl    %cl,%edi
  801d53:	89 f2                	mov    %esi,%edx
  801d55:	f7 75 f4             	divl   -0xc(%ebp)
  801d58:	89 d6                	mov    %edx,%esi
  801d5a:	f7 65 e8             	mull   -0x18(%ebp)
  801d5d:	39 d6                	cmp    %edx,%esi
  801d5f:	72 2b                	jb     801d8c <__umoddi3+0x11c>
  801d61:	39 c7                	cmp    %eax,%edi
  801d63:	72 23                	jb     801d88 <__umoddi3+0x118>
  801d65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d69:	29 c7                	sub    %eax,%edi
  801d6b:	19 d6                	sbb    %edx,%esi
  801d6d:	89 f0                	mov    %esi,%eax
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	d3 ef                	shr    %cl,%edi
  801d73:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d77:	d3 e0                	shl    %cl,%eax
  801d79:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d7d:	09 f8                	or     %edi,%eax
  801d7f:	d3 ea                	shr    %cl,%edx
  801d81:	83 c4 20             	add    $0x20,%esp
  801d84:	5e                   	pop    %esi
  801d85:	5f                   	pop    %edi
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    
  801d88:	39 d6                	cmp    %edx,%esi
  801d8a:	75 d9                	jne    801d65 <__umoddi3+0xf5>
  801d8c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801d8f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801d92:	eb d1                	jmp    801d65 <__umoddi3+0xf5>
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 f2                	cmp    %esi,%edx
  801d9a:	0f 82 18 ff ff ff    	jb     801cb8 <__umoddi3+0x48>
  801da0:	e9 1d ff ff ff       	jmp    801cc2 <__umoddi3+0x52>
