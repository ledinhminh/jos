
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be suffice
	# until we set up our real page table in mem_init in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 60 11 00       	mov    $0x116000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 60 11 f0       	mov    $0xf0116000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 a6 00 00 00       	call   f01000e4 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 80 43 10 f0 	movl   $0xf0104380,(%esp)
f010005f:	e8 53 31 00 00       	call   f01031b7 <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 11 31 00 00       	call   f0103184 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 1d 53 10 f0 	movl   $0xf010531d,(%esp)
f010007a:	e8 38 31 00 00       	call   f01031b7 <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d 00 83 11 f0 00 	cmpl   $0x0,0xf0118300
f0100097:	75 3d                	jne    f01000d6 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 00 83 11 f0    	mov    %esi,0xf0118300

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000a7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01000ae:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000b2:	c7 04 24 9a 43 10 f0 	movl   $0xf010439a,(%esp)
f01000b9:	e8 f9 30 00 00       	call   f01031b7 <cprintf>
	vcprintf(fmt, ap);
f01000be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000c2:	89 34 24             	mov    %esi,(%esp)
f01000c5:	e8 ba 30 00 00       	call   f0103184 <vcprintf>
	cprintf("\n");
f01000ca:	c7 04 24 1d 53 10 f0 	movl   $0xf010531d,(%esp)
f01000d1:	e8 e1 30 00 00       	call   f01031b7 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000dd:	e8 5c 07 00 00       	call   f010083e <monitor>
f01000e2:	eb f2                	jmp    f01000d6 <_panic+0x51>

f01000e4 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f01000e4:	55                   	push   %ebp
f01000e5:	89 e5                	mov    %esp,%ebp
f01000e7:	57                   	push   %edi
f01000e8:	53                   	push   %ebx
f01000e9:	81 ec 20 01 00 00    	sub    $0x120,%esp
	extern char edata[], end[];
    // Lab1 only
    char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f01000ef:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)
f01000f3:	c6 45 f6 00          	movb   $0x0,-0xa(%ebp)
f01000f7:	ba 00 01 00 00       	mov    $0x100,%edx
f01000fc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100101:	8d bd f6 fe ff ff    	lea    -0x10a(%ebp),%edi
f0100107:	66 ab                	stos   %ax,%es:(%edi)
f0100109:	83 ea 02             	sub    $0x2,%edx
f010010c:	89 d1                	mov    %edx,%ecx
f010010e:	c1 e9 02             	shr    $0x2,%ecx
f0100111:	f3 ab                	rep stos %eax,%es:(%edi)
f0100113:	f6 c2 02             	test   $0x2,%dl
f0100116:	74 02                	je     f010011a <i386_init+0x36>
f0100118:	66 ab                	stos   %ax,%es:(%edi)
f010011a:	83 e2 01             	and    $0x1,%edx
f010011d:	85 d2                	test   %edx,%edx
f010011f:	74 01                	je     f0100122 <i386_init+0x3e>
f0100121:	aa                   	stos   %al,%es:(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100122:	b8 6c 89 11 f0       	mov    $0xf011896c,%eax
f0100127:	2d 00 83 11 f0       	sub    $0xf0118300,%eax
f010012c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100130:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100137:	00 
f0100138:	c7 04 24 00 83 11 f0 	movl   $0xf0118300,(%esp)
f010013f:	e8 52 3d 00 00       	call   f0103e96 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100144:	e8 c1 03 00 00       	call   f010050a <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f0100149:	8d 45 f6             	lea    -0xa(%ebp),%eax
f010014c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100150:	8d 7d f7             	lea    -0x9(%ebp),%edi
f0100153:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100157:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010015e:	00 
f010015f:	c7 04 24 dc 43 10 f0 	movl   $0xf01043dc,(%esp)
f0100166:	e8 4c 30 00 00       	call   f01031b7 <cprintf>
    cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f010016b:	0f be 45 f6          	movsbl -0xa(%ebp),%eax
f010016f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100173:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f0100177:	89 44 24 04          	mov    %eax,0x4(%esp)
f010017b:	c7 04 24 b2 43 10 f0 	movl   $0xf01043b2,(%esp)
f0100182:	e8 30 30 00 00       	call   f01031b7 <cprintf>
    cprintf("%n", NULL);
f0100187:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010018e:	00 
f010018f:	c7 04 24 cb 43 10 f0 	movl   $0xf01043cb,(%esp)
f0100196:	e8 1c 30 00 00       	call   f01031b7 <cprintf>
    memset(ntest, 0xd, sizeof(ntest) - 1);
f010019b:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f01001a2:	00 
f01001a3:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f01001aa:	00 
f01001ab:	8d 9d f6 fe ff ff    	lea    -0x10a(%ebp),%ebx
f01001b1:	89 1c 24             	mov    %ebx,(%esp)
f01001b4:	e8 dd 3c 00 00       	call   f0103e96 <memset>
    cprintf("%s%n", ntest, &chnum1); 
f01001b9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01001bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01001c1:	c7 04 24 c9 43 10 f0 	movl   $0xf01043c9,(%esp)
f01001c8:	e8 ea 2f 00 00       	call   f01031b7 <cprintf>
    cprintf("chnum1: %d\n", chnum1);
f01001cd:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
f01001d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01001d5:	c7 04 24 ce 43 10 f0 	movl   $0xf01043ce,(%esp)
f01001dc:	e8 d6 2f 00 00       	call   f01031b7 <cprintf>



	// Lab 2 memory management initialization functions
	mem_init();
f01001e1:	e8 4a 1a 00 00       	call   f0101c30 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01001e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01001ed:	e8 4c 06 00 00       	call   f010083e <monitor>
f01001f2:	eb f2                	jmp    f01001e6 <i386_init+0x102>
	...

f0100200 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100203:	ba 84 00 00 00       	mov    $0x84,%edx
f0100208:	ec                   	in     (%dx),%al
f0100209:	ec                   	in     (%dx),%al
f010020a:	ec                   	in     (%dx),%al
f010020b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010020c:	5d                   	pop    %ebp
f010020d:	c3                   	ret    

f010020e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010020e:	55                   	push   %ebp
f010020f:	89 e5                	mov    %esp,%ebp
f0100211:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100216:	ec                   	in     (%dx),%al
f0100217:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100219:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010021e:	f6 c2 01             	test   $0x1,%dl
f0100221:	74 09                	je     f010022c <serial_proc_data+0x1e>
f0100223:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100228:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100229:	0f b6 c0             	movzbl %al,%eax
}
f010022c:	5d                   	pop    %ebp
f010022d:	c3                   	ret    

f010022e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010022e:	55                   	push   %ebp
f010022f:	89 e5                	mov    %esp,%ebp
f0100231:	57                   	push   %edi
f0100232:	56                   	push   %esi
f0100233:	53                   	push   %ebx
f0100234:	83 ec 0c             	sub    $0xc,%esp
f0100237:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100239:	bb 44 85 11 f0       	mov    $0xf0118544,%ebx
f010023e:	bf 40 83 11 f0       	mov    $0xf0118340,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100243:	eb 1b                	jmp    f0100260 <cons_intr+0x32>
		if (c == 0)
f0100245:	85 c0                	test   %eax,%eax
f0100247:	74 17                	je     f0100260 <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f0100249:	8b 13                	mov    (%ebx),%edx
f010024b:	88 04 3a             	mov    %al,(%edx,%edi,1)
f010024e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100251:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100256:	ba 00 00 00 00       	mov    $0x0,%edx
f010025b:	0f 44 c2             	cmove  %edx,%eax
f010025e:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100260:	ff d6                	call   *%esi
f0100262:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100265:	75 de                	jne    f0100245 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100267:	83 c4 0c             	add    $0xc,%esp
f010026a:	5b                   	pop    %ebx
f010026b:	5e                   	pop    %esi
f010026c:	5f                   	pop    %edi
f010026d:	5d                   	pop    %ebp
f010026e:	c3                   	ret    

f010026f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010026f:	55                   	push   %ebp
f0100270:	89 e5                	mov    %esp,%ebp
f0100272:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100275:	b8 fa 05 10 f0       	mov    $0xf01005fa,%eax
f010027a:	e8 af ff ff ff       	call   f010022e <cons_intr>
}
f010027f:	c9                   	leave  
f0100280:	c3                   	ret    

f0100281 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100281:	55                   	push   %ebp
f0100282:	89 e5                	mov    %esp,%ebp
f0100284:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100287:	83 3d 24 83 11 f0 00 	cmpl   $0x0,0xf0118324
f010028e:	74 0a                	je     f010029a <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100290:	b8 0e 02 10 f0       	mov    $0xf010020e,%eax
f0100295:	e8 94 ff ff ff       	call   f010022e <cons_intr>
}
f010029a:	c9                   	leave  
f010029b:	c3                   	ret    

f010029c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010029c:	55                   	push   %ebp
f010029d:	89 e5                	mov    %esp,%ebp
f010029f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01002a2:	e8 da ff ff ff       	call   f0100281 <serial_intr>
	kbd_intr();
f01002a7:	e8 c3 ff ff ff       	call   f010026f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01002ac:	8b 15 40 85 11 f0    	mov    0xf0118540,%edx
f01002b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01002b7:	3b 15 44 85 11 f0    	cmp    0xf0118544,%edx
f01002bd:	74 1e                	je     f01002dd <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01002bf:	0f b6 82 40 83 11 f0 	movzbl -0xfee7cc0(%edx),%eax
f01002c6:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01002c9:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01002cf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01002d4:	0f 44 d1             	cmove  %ecx,%edx
f01002d7:	89 15 40 85 11 f0    	mov    %edx,0xf0118540
		return c;
	}
	return 0;
}
f01002dd:	c9                   	leave  
f01002de:	c3                   	ret    

f01002df <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01002df:	55                   	push   %ebp
f01002e0:	89 e5                	mov    %esp,%ebp
f01002e2:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01002e5:	e8 b2 ff ff ff       	call   f010029c <cons_getc>
f01002ea:	85 c0                	test   %eax,%eax
f01002ec:	74 f7                	je     f01002e5 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01002ee:	c9                   	leave  
f01002ef:	c3                   	ret    

f01002f0 <iscons>:

int
iscons(int fdnum)
{
f01002f0:	55                   	push   %ebp
f01002f1:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01002f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01002f8:	5d                   	pop    %ebp
f01002f9:	c3                   	ret    

f01002fa <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002fa:	55                   	push   %ebp
f01002fb:	89 e5                	mov    %esp,%ebp
f01002fd:	57                   	push   %edi
f01002fe:	56                   	push   %esi
f01002ff:	53                   	push   %ebx
f0100300:	83 ec 2c             	sub    $0x2c,%esp
f0100303:	89 c7                	mov    %eax,%edi
f0100305:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010030a:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010030b:	a8 20                	test   $0x20,%al
f010030d:	75 21                	jne    f0100330 <cons_putc+0x36>
f010030f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100314:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100319:	e8 e2 fe ff ff       	call   f0100200 <delay>
f010031e:	89 f2                	mov    %esi,%edx
f0100320:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100321:	a8 20                	test   $0x20,%al
f0100323:	75 0b                	jne    f0100330 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100325:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100328:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010032e:	75 e9                	jne    f0100319 <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100330:	89 fa                	mov    %edi,%edx
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100337:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010033c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010033d:	b2 79                	mov    $0x79,%dl
f010033f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100340:	84 c0                	test   %al,%al
f0100342:	78 21                	js     f0100365 <cons_putc+0x6b>
f0100344:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100349:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f010034e:	e8 ad fe ff ff       	call   f0100200 <delay>
f0100353:	89 f2                	mov    %esi,%edx
f0100355:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100356:	84 c0                	test   %al,%al
f0100358:	78 0b                	js     f0100365 <cons_putc+0x6b>
f010035a:	83 c3 01             	add    $0x1,%ebx
f010035d:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100363:	75 e9                	jne    f010034e <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100365:	ba 78 03 00 00       	mov    $0x378,%edx
f010036a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010036e:	ee                   	out    %al,(%dx)
f010036f:	b2 7a                	mov    $0x7a,%dl
f0100371:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100376:	ee                   	out    %al,(%dx)
f0100377:	b8 08 00 00 00       	mov    $0x8,%eax
f010037c:	ee                   	out    %al,(%dx)
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f010037d:	89 f8                	mov    %edi,%eax
f010037f:	80 cc 07             	or     $0x7,%ah
f0100382:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100388:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010038b:	89 f8                	mov    %edi,%eax
f010038d:	25 ff 00 00 00       	and    $0xff,%eax
f0100392:	83 f8 09             	cmp    $0x9,%eax
f0100395:	0f 84 89 00 00 00    	je     f0100424 <cons_putc+0x12a>
f010039b:	83 f8 09             	cmp    $0x9,%eax
f010039e:	7f 12                	jg     f01003b2 <cons_putc+0xb8>
f01003a0:	83 f8 08             	cmp    $0x8,%eax
f01003a3:	0f 85 af 00 00 00    	jne    f0100458 <cons_putc+0x15e>
f01003a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01003b0:	eb 18                	jmp    f01003ca <cons_putc+0xd0>
f01003b2:	83 f8 0a             	cmp    $0xa,%eax
f01003b5:	8d 76 00             	lea    0x0(%esi),%esi
f01003b8:	74 40                	je     f01003fa <cons_putc+0x100>
f01003ba:	83 f8 0d             	cmp    $0xd,%eax
f01003bd:	8d 76 00             	lea    0x0(%esi),%esi
f01003c0:	0f 85 92 00 00 00    	jne    f0100458 <cons_putc+0x15e>
f01003c6:	66 90                	xchg   %ax,%ax
f01003c8:	eb 38                	jmp    f0100402 <cons_putc+0x108>
	case '\b':
		if (crt_pos > 0) {
f01003ca:	0f b7 05 30 83 11 f0 	movzwl 0xf0118330,%eax
f01003d1:	66 85 c0             	test   %ax,%ax
f01003d4:	0f 84 e8 00 00 00    	je     f01004c2 <cons_putc+0x1c8>
			crt_pos--;
f01003da:	83 e8 01             	sub    $0x1,%eax
f01003dd:	66 a3 30 83 11 f0    	mov    %ax,0xf0118330
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003e3:	0f b7 c0             	movzwl %ax,%eax
f01003e6:	66 81 e7 00 ff       	and    $0xff00,%di
f01003eb:	83 cf 20             	or     $0x20,%edi
f01003ee:	8b 15 2c 83 11 f0    	mov    0xf011832c,%edx
f01003f4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003f8:	eb 7b                	jmp    f0100475 <cons_putc+0x17b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003fa:	66 83 05 30 83 11 f0 	addw   $0x50,0xf0118330
f0100401:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100402:	0f b7 05 30 83 11 f0 	movzwl 0xf0118330,%eax
f0100409:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010040f:	c1 e8 10             	shr    $0x10,%eax
f0100412:	66 c1 e8 06          	shr    $0x6,%ax
f0100416:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100419:	c1 e0 04             	shl    $0x4,%eax
f010041c:	66 a3 30 83 11 f0    	mov    %ax,0xf0118330
f0100422:	eb 51                	jmp    f0100475 <cons_putc+0x17b>
		break;
	case '\t':
		cons_putc(' ');
f0100424:	b8 20 00 00 00       	mov    $0x20,%eax
f0100429:	e8 cc fe ff ff       	call   f01002fa <cons_putc>
		cons_putc(' ');
f010042e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100433:	e8 c2 fe ff ff       	call   f01002fa <cons_putc>
		cons_putc(' ');
f0100438:	b8 20 00 00 00       	mov    $0x20,%eax
f010043d:	e8 b8 fe ff ff       	call   f01002fa <cons_putc>
		cons_putc(' ');
f0100442:	b8 20 00 00 00       	mov    $0x20,%eax
f0100447:	e8 ae fe ff ff       	call   f01002fa <cons_putc>
		cons_putc(' ');
f010044c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100451:	e8 a4 fe ff ff       	call   f01002fa <cons_putc>
f0100456:	eb 1d                	jmp    f0100475 <cons_putc+0x17b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100458:	0f b7 05 30 83 11 f0 	movzwl 0xf0118330,%eax
f010045f:	0f b7 c8             	movzwl %ax,%ecx
f0100462:	8b 15 2c 83 11 f0    	mov    0xf011832c,%edx
f0100468:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010046c:	83 c0 01             	add    $0x1,%eax
f010046f:	66 a3 30 83 11 f0    	mov    %ax,0xf0118330
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100475:	66 81 3d 30 83 11 f0 	cmpw   $0x7cf,0xf0118330
f010047c:	cf 07 
f010047e:	76 42                	jbe    f01004c2 <cons_putc+0x1c8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100480:	a1 2c 83 11 f0       	mov    0xf011832c,%eax
f0100485:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010048c:	00 
f010048d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100493:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100497:	89 04 24             	mov    %eax,(%esp)
f010049a:	e8 56 3a 00 00       	call   f0103ef5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010049f:	8b 15 2c 83 11 f0    	mov    0xf011832c,%edx
f01004a5:	b8 80 07 00 00       	mov    $0x780,%eax
f01004aa:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b0:	83 c0 01             	add    $0x1,%eax
f01004b3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004b8:	75 f0                	jne    f01004aa <cons_putc+0x1b0>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004ba:	66 83 2d 30 83 11 f0 	subw   $0x50,0xf0118330
f01004c1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c2:	8b 0d 28 83 11 f0    	mov    0xf0118328,%ecx
f01004c8:	89 cb                	mov    %ecx,%ebx
f01004ca:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004cf:	89 ca                	mov    %ecx,%edx
f01004d1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d2:	0f b7 35 30 83 11 f0 	movzwl 0xf0118330,%esi
f01004d9:	83 c1 01             	add    $0x1,%ecx
f01004dc:	89 f0                	mov    %esi,%eax
f01004de:	66 c1 e8 08          	shr    $0x8,%ax
f01004e2:	89 ca                	mov    %ecx,%edx
f01004e4:	ee                   	out    %al,(%dx)
f01004e5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004ea:	89 da                	mov    %ebx,%edx
f01004ec:	ee                   	out    %al,(%dx)
f01004ed:	89 f0                	mov    %esi,%eax
f01004ef:	89 ca                	mov    %ecx,%edx
f01004f1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f2:	83 c4 2c             	add    $0x2c,%esp
f01004f5:	5b                   	pop    %ebx
f01004f6:	5e                   	pop    %esi
f01004f7:	5f                   	pop    %edi
f01004f8:	5d                   	pop    %ebp
f01004f9:	c3                   	ret    

f01004fa <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01004fa:	55                   	push   %ebp
f01004fb:	89 e5                	mov    %esp,%ebp
f01004fd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100500:	8b 45 08             	mov    0x8(%ebp),%eax
f0100503:	e8 f2 fd ff ff       	call   f01002fa <cons_putc>
}
f0100508:	c9                   	leave  
f0100509:	c3                   	ret    

f010050a <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010050a:	55                   	push   %ebp
f010050b:	89 e5                	mov    %esp,%ebp
f010050d:	57                   	push   %edi
f010050e:	56                   	push   %esi
f010050f:	53                   	push   %ebx
f0100510:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100513:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100518:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f010051b:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f0100520:	0f b7 00             	movzwl (%eax),%eax
f0100523:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100527:	74 11                	je     f010053a <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100529:	c7 05 28 83 11 f0 b4 	movl   $0x3b4,0xf0118328
f0100530:	03 00 00 
f0100533:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100538:	eb 16                	jmp    f0100550 <cons_init+0x46>
	} else {
		*cp = was;
f010053a:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100541:	c7 05 28 83 11 f0 d4 	movl   $0x3d4,0xf0118328
f0100548:	03 00 00 
f010054b:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f0100550:	8b 0d 28 83 11 f0    	mov    0xf0118328,%ecx
f0100556:	89 cb                	mov    %ecx,%ebx
f0100558:	b8 0e 00 00 00       	mov    $0xe,%eax
f010055d:	89 ca                	mov    %ecx,%edx
f010055f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100560:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100563:	89 ca                	mov    %ecx,%edx
f0100565:	ec                   	in     (%dx),%al
f0100566:	0f b6 f8             	movzbl %al,%edi
f0100569:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010056c:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100571:	89 da                	mov    %ebx,%edx
f0100573:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100574:	89 ca                	mov    %ecx,%edx
f0100576:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100577:	89 35 2c 83 11 f0    	mov    %esi,0xf011832c
	crt_pos = pos;
f010057d:	0f b6 c8             	movzbl %al,%ecx
f0100580:	09 cf                	or     %ecx,%edi
f0100582:	66 89 3d 30 83 11 f0 	mov    %di,0xf0118330
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100589:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010058e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100593:	89 da                	mov    %ebx,%edx
f0100595:	ee                   	out    %al,(%dx)
f0100596:	b2 fb                	mov    $0xfb,%dl
f0100598:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010059d:	ee                   	out    %al,(%dx)
f010059e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005a3:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005a8:	89 ca                	mov    %ecx,%edx
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	b2 f9                	mov    $0xf9,%dl
f01005ad:	b8 00 00 00 00       	mov    $0x0,%eax
f01005b2:	ee                   	out    %al,(%dx)
f01005b3:	b2 fb                	mov    $0xfb,%dl
f01005b5:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ba:	ee                   	out    %al,(%dx)
f01005bb:	b2 fc                	mov    $0xfc,%dl
f01005bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c2:	ee                   	out    %al,(%dx)
f01005c3:	b2 f9                	mov    $0xf9,%dl
f01005c5:	b8 01 00 00 00       	mov    $0x1,%eax
f01005ca:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cb:	b2 fd                	mov    $0xfd,%dl
f01005cd:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005ce:	3c ff                	cmp    $0xff,%al
f01005d0:	0f 95 c0             	setne  %al
f01005d3:	0f b6 f0             	movzbl %al,%esi
f01005d6:	89 35 24 83 11 f0    	mov    %esi,0xf0118324
f01005dc:	89 da                	mov    %ebx,%edx
f01005de:	ec                   	in     (%dx),%al
f01005df:	89 ca                	mov    %ecx,%edx
f01005e1:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e2:	85 f6                	test   %esi,%esi
f01005e4:	75 0c                	jne    f01005f2 <cons_init+0xe8>
		cprintf("Serial port does not exist!\n");
f01005e6:	c7 04 24 fb 43 10 f0 	movl   $0xf01043fb,(%esp)
f01005ed:	e8 c5 2b 00 00       	call   f01031b7 <cprintf>
}
f01005f2:	83 c4 1c             	add    $0x1c,%esp
f01005f5:	5b                   	pop    %ebx
f01005f6:	5e                   	pop    %esi
f01005f7:	5f                   	pop    %edi
f01005f8:	5d                   	pop    %ebp
f01005f9:	c3                   	ret    

f01005fa <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01005fa:	55                   	push   %ebp
f01005fb:	89 e5                	mov    %esp,%ebp
f01005fd:	53                   	push   %ebx
f01005fe:	83 ec 14             	sub    $0x14,%esp
f0100601:	ba 64 00 00 00       	mov    $0x64,%edx
f0100606:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100607:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010060c:	a8 01                	test   $0x1,%al
f010060e:	0f 84 dd 00 00 00    	je     f01006f1 <kbd_proc_data+0xf7>
f0100614:	b2 60                	mov    $0x60,%dl
f0100616:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100617:	3c e0                	cmp    $0xe0,%al
f0100619:	75 11                	jne    f010062c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010061b:	83 0d 20 83 11 f0 40 	orl    $0x40,0xf0118320
f0100622:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100627:	e9 c5 00 00 00       	jmp    f01006f1 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f010062c:	84 c0                	test   %al,%al
f010062e:	79 35                	jns    f0100665 <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100630:	8b 15 20 83 11 f0    	mov    0xf0118320,%edx
f0100636:	89 c1                	mov    %eax,%ecx
f0100638:	83 e1 7f             	and    $0x7f,%ecx
f010063b:	f6 c2 40             	test   $0x40,%dl
f010063e:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100641:	0f b6 c0             	movzbl %al,%eax
f0100644:	0f b6 80 40 44 10 f0 	movzbl -0xfefbbc0(%eax),%eax
f010064b:	83 c8 40             	or     $0x40,%eax
f010064e:	0f b6 c0             	movzbl %al,%eax
f0100651:	f7 d0                	not    %eax
f0100653:	21 c2                	and    %eax,%edx
f0100655:	89 15 20 83 11 f0    	mov    %edx,0xf0118320
f010065b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100660:	e9 8c 00 00 00       	jmp    f01006f1 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f0100665:	8b 15 20 83 11 f0    	mov    0xf0118320,%edx
f010066b:	f6 c2 40             	test   $0x40,%dl
f010066e:	74 0c                	je     f010067c <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100670:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100673:	83 e2 bf             	and    $0xffffffbf,%edx
f0100676:	89 15 20 83 11 f0    	mov    %edx,0xf0118320
	}

	shift |= shiftcode[data];
f010067c:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010067f:	0f b6 90 40 44 10 f0 	movzbl -0xfefbbc0(%eax),%edx
f0100686:	0b 15 20 83 11 f0    	or     0xf0118320,%edx
f010068c:	0f b6 88 40 45 10 f0 	movzbl -0xfefbac0(%eax),%ecx
f0100693:	31 ca                	xor    %ecx,%edx
f0100695:	89 15 20 83 11 f0    	mov    %edx,0xf0118320

	c = charcode[shift & (CTL | SHIFT)][data];
f010069b:	89 d1                	mov    %edx,%ecx
f010069d:	83 e1 03             	and    $0x3,%ecx
f01006a0:	8b 0c 8d 40 46 10 f0 	mov    -0xfefb9c0(,%ecx,4),%ecx
f01006a7:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01006ab:	f6 c2 08             	test   $0x8,%dl
f01006ae:	74 1b                	je     f01006cb <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01006b0:	89 d9                	mov    %ebx,%ecx
f01006b2:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01006b5:	83 f8 19             	cmp    $0x19,%eax
f01006b8:	77 05                	ja     f01006bf <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01006ba:	83 eb 20             	sub    $0x20,%ebx
f01006bd:	eb 0c                	jmp    f01006cb <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01006bf:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f01006c2:	8d 43 20             	lea    0x20(%ebx),%eax
f01006c5:	83 f9 19             	cmp    $0x19,%ecx
f01006c8:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01006cb:	f7 d2                	not    %edx
f01006cd:	f6 c2 06             	test   $0x6,%dl
f01006d0:	75 1f                	jne    f01006f1 <kbd_proc_data+0xf7>
f01006d2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01006d8:	75 17                	jne    f01006f1 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f01006da:	c7 04 24 18 44 10 f0 	movl   $0xf0104418,(%esp)
f01006e1:	e8 d1 2a 00 00       	call   f01031b7 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006e6:	ba 92 00 00 00       	mov    $0x92,%edx
f01006eb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006f0:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01006f1:	89 d8                	mov    %ebx,%eax
f01006f3:	83 c4 14             	add    $0x14,%esp
f01006f6:	5b                   	pop    %ebx
f01006f7:	5d                   	pop    %ebp
f01006f8:	c3                   	ret    
f01006f9:	00 00                	add    %al,(%eax)
f01006fb:	00 00                	add    %al,(%eax)
f01006fd:	00 00                	add    %al,(%eax)
	...

f0100700 <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f0100700:	55                   	push   %ebp
f0100701:	89 e5                	mov    %esp,%ebp
	memset(str, 'a', 16);
	cprintf("%s%n", str, &str[270]);
	memset(str, 'a', 176);
	cprintf("%s%n", str, &str[271]);
*/
}
f0100703:	5d                   	pop    %ebp
f0100704:	c3                   	ret    

f0100705 <overflow_me>:

void
overflow_me(void)
{
f0100705:	55                   	push   %ebp
f0100706:	89 e5                	mov    %esp,%ebp
        start_overflow();
}
f0100708:	5d                   	pop    %ebp
f0100709:	c3                   	ret    

f010070a <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f010070a:	55                   	push   %ebp
f010070b:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f010070d:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100710:	5d                   	pop    %ebp
f0100711:	c3                   	ret    

f0100712 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f0100712:	55                   	push   %ebp
f0100713:	89 e5                	mov    %esp,%ebp
f0100715:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f0100718:	c7 04 24 50 46 10 f0 	movl   $0xf0104650,(%esp)
f010071f:	e8 93 2a 00 00       	call   f01031b7 <cprintf>
}
f0100724:	c9                   	leave  
f0100725:	c3                   	ret    

f0100726 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100726:	55                   	push   %ebp
f0100727:	89 e5                	mov    %esp,%ebp
f0100729:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010072c:	c7 04 24 62 46 10 f0 	movl   $0xf0104662,(%esp)
f0100733:	e8 7f 2a 00 00       	call   f01031b7 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100738:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010073f:	00 
f0100740:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100747:	f0 
f0100748:	c7 04 24 34 47 10 f0 	movl   $0xf0104734,(%esp)
f010074f:	e8 63 2a 00 00       	call   f01031b7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100754:	c7 44 24 08 65 43 10 	movl   $0x104365,0x8(%esp)
f010075b:	00 
f010075c:	c7 44 24 04 65 43 10 	movl   $0xf0104365,0x4(%esp)
f0100763:	f0 
f0100764:	c7 04 24 58 47 10 f0 	movl   $0xf0104758,(%esp)
f010076b:	e8 47 2a 00 00       	call   f01031b7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100770:	c7 44 24 08 00 83 11 	movl   $0x118300,0x8(%esp)
f0100777:	00 
f0100778:	c7 44 24 04 00 83 11 	movl   $0xf0118300,0x4(%esp)
f010077f:	f0 
f0100780:	c7 04 24 7c 47 10 f0 	movl   $0xf010477c,(%esp)
f0100787:	e8 2b 2a 00 00       	call   f01031b7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010078c:	c7 44 24 08 6c 89 11 	movl   $0x11896c,0x8(%esp)
f0100793:	00 
f0100794:	c7 44 24 04 6c 89 11 	movl   $0xf011896c,0x4(%esp)
f010079b:	f0 
f010079c:	c7 04 24 a0 47 10 f0 	movl   $0xf01047a0,(%esp)
f01007a3:	e8 0f 2a 00 00       	call   f01031b7 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007a8:	b8 6b 8d 11 f0       	mov    $0xf0118d6b,%eax
f01007ad:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01007b2:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007b8:	85 c0                	test   %eax,%eax
f01007ba:	0f 48 c2             	cmovs  %edx,%eax
f01007bd:	c1 f8 0a             	sar    $0xa,%eax
f01007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007c4:	c7 04 24 c4 47 10 f0 	movl   $0xf01047c4,(%esp)
f01007cb:	e8 e7 29 00 00       	call   f01031b7 <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f01007d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007d5:	c9                   	leave  
f01007d6:	c3                   	ret    

f01007d7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007d7:	55                   	push   %ebp
f01007d8:	89 e5                	mov    %esp,%ebp
f01007da:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007dd:	a1 a4 48 10 f0       	mov    0xf01048a4,%eax
f01007e2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007e6:	a1 a0 48 10 f0       	mov    0xf01048a0,%eax
f01007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ef:	c7 04 24 7b 46 10 f0 	movl   $0xf010467b,(%esp)
f01007f6:	e8 bc 29 00 00       	call   f01031b7 <cprintf>
f01007fb:	a1 b0 48 10 f0       	mov    0xf01048b0,%eax
f0100800:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100804:	a1 ac 48 10 f0       	mov    0xf01048ac,%eax
f0100809:	89 44 24 04          	mov    %eax,0x4(%esp)
f010080d:	c7 04 24 7b 46 10 f0 	movl   $0xf010467b,(%esp)
f0100814:	e8 9e 29 00 00       	call   f01031b7 <cprintf>
f0100819:	a1 bc 48 10 f0       	mov    0xf01048bc,%eax
f010081e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100822:	a1 b8 48 10 f0       	mov    0xf01048b8,%eax
f0100827:	89 44 24 04          	mov    %eax,0x4(%esp)
f010082b:	c7 04 24 7b 46 10 f0 	movl   $0xf010467b,(%esp)
f0100832:	e8 80 29 00 00       	call   f01031b7 <cprintf>
	return 0;
}
f0100837:	b8 00 00 00 00       	mov    $0x0,%eax
f010083c:	c9                   	leave  
f010083d:	c3                   	ret    

f010083e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010083e:	55                   	push   %ebp
f010083f:	89 e5                	mov    %esp,%ebp
f0100841:	57                   	push   %edi
f0100842:	56                   	push   %esi
f0100843:	53                   	push   %ebx
f0100844:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100847:	c7 04 24 f0 47 10 f0 	movl   $0xf01047f0,(%esp)
f010084e:	e8 64 29 00 00       	call   f01031b7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100853:	c7 04 24 14 48 10 f0 	movl   $0xf0104814,(%esp)
f010085a:	e8 58 29 00 00       	call   f01031b7 <cprintf>


	while (1) {
		buf = readline("K> ");
f010085f:	c7 04 24 84 46 10 f0 	movl   $0xf0104684,(%esp)
f0100866:	e8 a5 33 00 00       	call   f0103c10 <readline>
f010086b:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010086d:	85 c0                	test   %eax,%eax
f010086f:	74 ee                	je     f010085f <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100871:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100878:	be 00 00 00 00       	mov    $0x0,%esi
f010087d:	eb 06                	jmp    f0100885 <monitor+0x47>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010087f:	c6 03 00             	movb   $0x0,(%ebx)
f0100882:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100885:	0f b6 03             	movzbl (%ebx),%eax
f0100888:	84 c0                	test   %al,%al
f010088a:	74 6f                	je     f01008fb <monitor+0xbd>
f010088c:	0f be c0             	movsbl %al,%eax
f010088f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100893:	c7 04 24 88 46 10 f0 	movl   $0xf0104688,(%esp)
f010089a:	e8 9f 35 00 00       	call   f0103e3e <strchr>
f010089f:	85 c0                	test   %eax,%eax
f01008a1:	75 dc                	jne    f010087f <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f01008a3:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008a6:	74 53                	je     f01008fb <monitor+0xbd>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008a8:	83 fe 0f             	cmp    $0xf,%esi
f01008ab:	90                   	nop
f01008ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01008b0:	75 16                	jne    f01008c8 <monitor+0x8a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008b2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008b9:	00 
f01008ba:	c7 04 24 8d 46 10 f0 	movl   $0xf010468d,(%esp)
f01008c1:	e8 f1 28 00 00       	call   f01031b7 <cprintf>
f01008c6:	eb 97                	jmp    f010085f <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f01008c8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008cc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01008cf:	0f b6 03             	movzbl (%ebx),%eax
f01008d2:	84 c0                	test   %al,%al
f01008d4:	75 0c                	jne    f01008e2 <monitor+0xa4>
f01008d6:	eb ad                	jmp    f0100885 <monitor+0x47>
			buf++;
f01008d8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008db:	0f b6 03             	movzbl (%ebx),%eax
f01008de:	84 c0                	test   %al,%al
f01008e0:	74 a3                	je     f0100885 <monitor+0x47>
f01008e2:	0f be c0             	movsbl %al,%eax
f01008e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008e9:	c7 04 24 88 46 10 f0 	movl   $0xf0104688,(%esp)
f01008f0:	e8 49 35 00 00       	call   f0103e3e <strchr>
f01008f5:	85 c0                	test   %eax,%eax
f01008f7:	74 df                	je     f01008d8 <monitor+0x9a>
f01008f9:	eb 8a                	jmp    f0100885 <monitor+0x47>
			buf++;
	}
	argv[argc] = 0;
f01008fb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100902:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100903:	85 f6                	test   %esi,%esi
f0100905:	0f 84 54 ff ff ff    	je     f010085f <monitor+0x21>
f010090b:	bb a0 48 10 f0       	mov    $0xf01048a0,%ebx
f0100910:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100915:	8b 03                	mov    (%ebx),%eax
f0100917:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010091e:	89 04 24             	mov    %eax,(%esp)
f0100921:	e8 a3 34 00 00       	call   f0103dc9 <strcmp>
f0100926:	85 c0                	test   %eax,%eax
f0100928:	75 23                	jne    f010094d <monitor+0x10f>
			return commands[i].func(argc, argv, tf);
f010092a:	6b ff 0c             	imul   $0xc,%edi,%edi
f010092d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100930:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100934:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100937:	89 44 24 04          	mov    %eax,0x4(%esp)
f010093b:	89 34 24             	mov    %esi,(%esp)
f010093e:	ff 97 a8 48 10 f0    	call   *-0xfefb758(%edi)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100944:	85 c0                	test   %eax,%eax
f0100946:	78 28                	js     f0100970 <monitor+0x132>
f0100948:	e9 12 ff ff ff       	jmp    f010085f <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010094d:	83 c7 01             	add    $0x1,%edi
f0100950:	83 c3 0c             	add    $0xc,%ebx
f0100953:	83 ff 03             	cmp    $0x3,%edi
f0100956:	75 bd                	jne    f0100915 <monitor+0xd7>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100958:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010095b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010095f:	c7 04 24 aa 46 10 f0 	movl   $0xf01046aa,(%esp)
f0100966:	e8 4c 28 00 00       	call   f01031b7 <cprintf>
f010096b:	e9 ef fe ff ff       	jmp    f010085f <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100970:	83 c4 5c             	add    $0x5c,%esp
f0100973:	5b                   	pop    %ebx
f0100974:	5e                   	pop    %esi
f0100975:	5f                   	pop    %edi
f0100976:	5d                   	pop    %ebp
f0100977:	c3                   	ret    

f0100978 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
f010097b:	57                   	push   %edi
f010097c:	56                   	push   %esi
f010097d:	53                   	push   %ebx
f010097e:	83 ec 4c             	sub    $0x4c,%esp

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100981:	89 ee                	mov    %ebp,%esi
	overflow_me();
	// Your code here.
	uint32_t ebp = read_ebp(), *ebpp, eip, i;
	struct Eipdebuginfo dbg;
	while (ebp > 0) {
f0100983:	85 f6                	test   %esi,%esi
f0100985:	0f 84 a2 00 00 00    	je     f0100a2d <mon_backtrace+0xb5>
		ebpp = (uint32_t *)ebp;
f010098b:	89 75 c4             	mov    %esi,-0x3c(%ebp)
		eip = ebpp[1];
f010098e:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("ebp %x eip %x args", ebp, eip);
f0100991:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100995:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100999:	c7 04 24 c0 46 10 f0 	movl   $0xf01046c0,(%esp)
f01009a0:	e8 12 28 00 00       	call   f01031b7 <cprintf>
f01009a5:	bb 02 00 00 00       	mov    $0x2,%ebx
		for (i = 2; i < 6; i++) {
			cprintf(" %08x", ebpp[i]);
f01009aa:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
f01009ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009b1:	c7 04 24 d3 46 10 f0 	movl   $0xf01046d3,(%esp)
f01009b8:	e8 fa 27 00 00       	call   f01031b7 <cprintf>
	struct Eipdebuginfo dbg;
	while (ebp > 0) {
		ebpp = (uint32_t *)ebp;
		eip = ebpp[1];
		cprintf("ebp %x eip %x args", ebp, eip);
		for (i = 2; i < 6; i++) {
f01009bd:	83 c3 01             	add    $0x1,%ebx
f01009c0:	83 fb 06             	cmp    $0x6,%ebx
f01009c3:	75 e5                	jne    f01009aa <mon_backtrace+0x32>
			cprintf(" %08x", ebpp[i]);
		}
		debuginfo_eip(eip, &dbg);
f01009c5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01009c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009cc:	89 3c 24             	mov    %edi,(%esp)
f01009cf:	e8 4a 29 00 00       	call   f010331e <debuginfo_eip>
		cprintf("\n\t%s:%d: ", dbg.eip_file, dbg.eip_line);
f01009d4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01009d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009db:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01009de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009e2:	c7 04 24 d9 46 10 f0 	movl   $0xf01046d9,(%esp)
f01009e9:	e8 c9 27 00 00       	call   f01031b7 <cprintf>
		for (i = 0; i < dbg.eip_fn_namelen; i++)
f01009ee:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01009f2:	74 19                	je     f0100a0d <mon_backtrace+0x95>
f01009f4:	b3 00                	mov    $0x0,%bl
			cputchar(dbg.eip_fn_name[i]);
f01009f6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009f9:	0f be 04 18          	movsbl (%eax,%ebx,1),%eax
f01009fd:	89 04 24             	mov    %eax,(%esp)
f0100a00:	e8 f5 fa ff ff       	call   f01004fa <cputchar>
		for (i = 2; i < 6; i++) {
			cprintf(" %08x", ebpp[i]);
		}
		debuginfo_eip(eip, &dbg);
		cprintf("\n\t%s:%d: ", dbg.eip_file, dbg.eip_line);
		for (i = 0; i < dbg.eip_fn_namelen; i++)
f0100a05:	83 c3 01             	add    $0x1,%ebx
f0100a08:	39 5d dc             	cmp    %ebx,-0x24(%ebp)
f0100a0b:	77 e9                	ja     f01009f6 <mon_backtrace+0x7e>
			cputchar(dbg.eip_fn_name[i]);
		cprintf("+%d\n", eip - dbg.eip_fn_addr);
f0100a0d:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100a10:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100a14:	c7 04 24 e3 46 10 f0 	movl   $0xf01046e3,(%esp)
f0100a1b:	e8 97 27 00 00       	call   f01031b7 <cprintf>
		ebp = *ebpp;
f0100a20:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100a23:	8b 30                	mov    (%eax),%esi
{
	overflow_me();
	// Your code here.
	uint32_t ebp = read_ebp(), *ebpp, eip, i;
	struct Eipdebuginfo dbg;
	while (ebp > 0) {
f0100a25:	85 f6                	test   %esi,%esi
f0100a27:	0f 85 5e ff ff ff    	jne    f010098b <mon_backtrace+0x13>
			cputchar(dbg.eip_fn_name[i]);
		cprintf("+%d\n", eip - dbg.eip_fn_addr);
		ebp = *ebpp;
	}
 //   overflow_me();
    	cprintf("Backtrace success\n");
f0100a2d:	c7 04 24 e8 46 10 f0 	movl   $0xf01046e8,(%esp)
f0100a34:	e8 7e 27 00 00       	call   f01031b7 <cprintf>
	return 0;
}
f0100a39:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a3e:	83 c4 4c             	add    $0x4c,%esp
f0100a41:	5b                   	pop    %ebx
f0100a42:	5e                   	pop    %esi
f0100a43:	5f                   	pop    %edi
f0100a44:	5d                   	pop    %ebp
f0100a45:	c3                   	ret    
	...

f0100a50 <page_free_4pages>:
//	2. Add the pages to the chunck list.
//	
//	Return 0 if everything ok
int
page_free_4pages(struct Page *pp)
{
f0100a50:	55                   	push   %ebp
f0100a51:	89 e5                	mov    %esp,%ebp
f0100a53:	83 ec 10             	sub    $0x10,%esp
f0100a56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0100a59:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0100a5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0100a5f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function
	struct Page *tmp;
	int i;
	for( tmp = pp, i = 0; i < 3; tmp = tmp->pp_link, i++ )
	{
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0100a62:	8b 08                	mov    (%eax),%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a64:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f0100a6a:	89 cb                	mov    %ecx,%ebx
f0100a6c:	29 d3                	sub    %edx,%ebx
f0100a6e:	c1 fb 03             	sar    $0x3,%ebx
f0100a71:	c1 e3 0c             	shl    $0xc,%ebx
f0100a74:	89 5d f0             	mov    %ebx,-0x10(%ebp)
f0100a77:	89 c6                	mov    %eax,%esi
f0100a79:	29 d6                	sub    %edx,%esi
f0100a7b:	c1 fe 03             	sar    $0x3,%esi
f0100a7e:	c1 e6 0c             	shl    $0xc,%esi
f0100a81:	29 f3                	sub    %esi,%ebx
f0100a83:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0100a89:	0f 85 87 00 00 00    	jne    f0100b16 <page_free_4pages+0xc6>
f0100a8f:	8b 39                	mov    (%ecx),%edi
f0100a91:	89 fe                	mov    %edi,%esi
f0100a93:	29 d6                	sub    %edx,%esi
f0100a95:	c1 fe 03             	sar    $0x3,%esi
f0100a98:	c1 e6 0c             	shl    $0xc,%esi
f0100a9b:	89 f3                	mov    %esi,%ebx
f0100a9d:	2b 5d f0             	sub    -0x10(%ebp),%ebx
f0100aa0:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
f0100aa6:	75 6e                	jne    f0100b16 <page_free_4pages+0xc6>
f0100aa8:	8b 1f                	mov    (%edi),%ebx
f0100aaa:	29 d3                	sub    %edx,%ebx
f0100aac:	89 da                	mov    %ebx,%edx
f0100aae:	c1 fa 03             	sar    $0x3,%edx
f0100ab1:	c1 e2 0c             	shl    $0xc,%edx
f0100ab4:	29 f2                	sub    %esi,%edx
f0100ab6:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0100abc:	75 58                	jne    f0100b16 <page_free_4pages+0xc6>
			return -1;
		}
	}
	for( tmp = pp, i = 0; i < 3; tmp = tmp->pp_link, i++)
	{
		*pp->pp_link = chunck_list;
f0100abe:	8b 1d 54 85 11 f0    	mov    0xf0118554,%ebx
f0100ac4:	8b 35 58 85 11 f0    	mov    0xf0118558,%esi
f0100aca:	89 19                	mov    %ebx,(%ecx)
f0100acc:	89 71 04             	mov    %esi,0x4(%ecx)
		chunck_list = *pp;
f0100acf:	8b 10                	mov    (%eax),%edx
f0100ad1:	8b 48 04             	mov    0x4(%eax),%ecx
f0100ad4:	89 15 54 85 11 f0    	mov    %edx,0xf0118554
f0100ada:	89 0d 58 85 11 f0    	mov    %ecx,0xf0118558
			return -1;
		}
	}
	for( tmp = pp, i = 0; i < 3; tmp = tmp->pp_link, i++)
	{
		*pp->pp_link = chunck_list;
f0100ae0:	8b 18                	mov    (%eax),%ebx
f0100ae2:	89 13                	mov    %edx,(%ebx)
f0100ae4:	89 4b 04             	mov    %ecx,0x4(%ebx)
		chunck_list = *pp;
f0100ae7:	8b 10                	mov    (%eax),%edx
f0100ae9:	8b 48 04             	mov    0x4(%eax),%ecx
f0100aec:	89 15 54 85 11 f0    	mov    %edx,0xf0118554
f0100af2:	89 0d 58 85 11 f0    	mov    %ecx,0xf0118558
			return -1;
		}
	}
	for( tmp = pp, i = 0; i < 3; tmp = tmp->pp_link, i++)
	{
		*pp->pp_link = chunck_list;
f0100af8:	8b 18                	mov    (%eax),%ebx
f0100afa:	89 13                	mov    %edx,(%ebx)
f0100afc:	89 4b 04             	mov    %ecx,0x4(%ebx)
		chunck_list = *pp;
f0100aff:	8b 50 04             	mov    0x4(%eax),%edx
f0100b02:	8b 00                	mov    (%eax),%eax
f0100b04:	a3 54 85 11 f0       	mov    %eax,0xf0118554
f0100b09:	89 15 58 85 11 f0    	mov    %edx,0xf0118558
f0100b0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b14:	eb 05                	jmp    f0100b1b <page_free_4pages+0xcb>
f0100b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	}

	return 0;
}
f0100b1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0100b1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0100b21:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0100b24:	89 ec                	mov    %ebp,%esp
f0100b26:	5d                   	pop    %ebp
f0100b27:	c3                   	ret    

f0100b28 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100b28:	55                   	push   %ebp
f0100b29:	89 e5                	mov    %esp,%ebp
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b2e:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100b31:	5d                   	pop    %ebp
f0100b32:	c3                   	ret    

f0100b33 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100b33:	55                   	push   %ebp
f0100b34:	89 e5                	mov    %esp,%ebp
f0100b36:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100b39:	89 d1                	mov    %edx,%ecx
f0100b3b:	c1 e9 16             	shr    $0x16,%ecx
f0100b3e:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100b41:	a8 01                	test   $0x1,%al
f0100b43:	74 4d                	je     f0100b92 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100b45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b4a:	89 c1                	mov    %eax,%ecx
f0100b4c:	c1 e9 0c             	shr    $0xc,%ecx
f0100b4f:	3b 0d 60 89 11 f0    	cmp    0xf0118960,%ecx
f0100b55:	72 20                	jb     f0100b77 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b57:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b5b:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0100b62:	f0 
f0100b63:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0100b6a:	00 
f0100b6b:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100b72:	e8 0e f5 ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100b77:	c1 ea 0c             	shr    $0xc,%edx
f0100b7a:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b80:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b87:	a8 01                	test   $0x1,%al
f0100b89:	74 07                	je     f0100b92 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b90:	eb 05                	jmp    f0100b97 <check_va2pa+0x64>
f0100b92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b97:	c9                   	leave  
f0100b98:	c3                   	ret    

f0100b99 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100b99:	55                   	push   %ebp
f0100b9a:	89 e5                	mov    %esp,%ebp
f0100b9c:	83 ec 18             	sub    $0x18,%esp
f0100b9f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	assert(pp->pp_ref == 0);
f0100ba2:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ba7:	74 24                	je     f0100bcd <page_free+0x34>
f0100ba9:	c7 44 24 0c 2a 50 10 	movl   $0xf010502a,0xc(%esp)
f0100bb0:	f0 
f0100bb1:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100bb8:	f0 
f0100bb9:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
f0100bc0:	00 
f0100bc1:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100bc8:	e8 b8 f4 ff ff       	call   f0100085 <_panic>
	pp->pp_link = page_free_list;
f0100bcd:	8b 15 50 85 11 f0    	mov    0xf0118550,%edx
f0100bd3:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100bd5:	a3 50 85 11 f0       	mov    %eax,0xf0118550
}
f0100bda:	c9                   	leave  
f0100bdb:	c3                   	ret    

f0100bdc <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100bdc:	55                   	push   %ebp
f0100bdd:	89 e5                	mov    %esp,%ebp
f0100bdf:	83 ec 18             	sub    $0x18,%esp
f0100be2:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100be5:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100be9:	83 ea 01             	sub    $0x1,%edx
f0100bec:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100bf0:	66 85 d2             	test   %dx,%dx
f0100bf3:	75 08                	jne    f0100bfd <page_decref+0x21>
		page_free(pp);
f0100bf5:	89 04 24             	mov    %eax,(%esp)
f0100bf8:	e8 9c ff ff ff       	call   f0100b99 <page_free>
}
f0100bfd:	c9                   	leave  
f0100bfe:	c3                   	ret    

f0100bff <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100bff:	55                   	push   %ebp
f0100c00:	89 e5                	mov    %esp,%ebp
f0100c02:	83 ec 18             	sub    $0x18,%esp
f0100c05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100c08:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100c0b:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c0d:	89 04 24             	mov    %eax,(%esp)
f0100c10:	e8 47 25 00 00       	call   f010315c <mc146818_read>
f0100c15:	89 c6                	mov    %eax,%esi
f0100c17:	83 c3 01             	add    $0x1,%ebx
f0100c1a:	89 1c 24             	mov    %ebx,(%esp)
f0100c1d:	e8 3a 25 00 00       	call   f010315c <mc146818_read>
f0100c22:	c1 e0 08             	shl    $0x8,%eax
f0100c25:	09 f0                	or     %esi,%eax
}
f0100c27:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100c2a:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100c2d:	89 ec                	mov    %ebp,%esp
f0100c2f:	5d                   	pop    %ebp
f0100c30:	c3                   	ret    

f0100c31 <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100c31:	55                   	push   %ebp
f0100c32:	89 e5                	mov    %esp,%ebp
f0100c34:	83 ec 18             	sub    $0x18,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100c37:	b8 15 00 00 00       	mov    $0x15,%eax
f0100c3c:	e8 be ff ff ff       	call   f0100bff <nvram_read>
f0100c41:	c1 e0 0a             	shl    $0xa,%eax
f0100c44:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100c4a:	85 c0                	test   %eax,%eax
f0100c4c:	0f 48 c2             	cmovs  %edx,%eax
f0100c4f:	c1 f8 0c             	sar    $0xc,%eax
f0100c52:	a3 4c 85 11 f0       	mov    %eax,0xf011854c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100c57:	b8 17 00 00 00       	mov    $0x17,%eax
f0100c5c:	e8 9e ff ff ff       	call   f0100bff <nvram_read>
f0100c61:	c1 e0 0a             	shl    $0xa,%eax
f0100c64:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100c6a:	85 c0                	test   %eax,%eax
f0100c6c:	0f 48 c2             	cmovs  %edx,%eax
f0100c6f:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100c72:	85 c0                	test   %eax,%eax
f0100c74:	74 0e                	je     f0100c84 <i386_detect_memory+0x53>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100c76:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100c7c:	89 15 60 89 11 f0    	mov    %edx,0xf0118960
f0100c82:	eb 0c                	jmp    f0100c90 <i386_detect_memory+0x5f>
	else
		npages = npages_basemem;
f0100c84:	8b 15 4c 85 11 f0    	mov    0xf011854c,%edx
f0100c8a:	89 15 60 89 11 f0    	mov    %edx,0xf0118960

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100c90:	c1 e0 0c             	shl    $0xc,%eax
f0100c93:	c1 e8 0a             	shr    $0xa,%eax
f0100c96:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c9a:	a1 4c 85 11 f0       	mov    0xf011854c,%eax
f0100c9f:	c1 e0 0c             	shl    $0xc,%eax
f0100ca2:	c1 e8 0a             	shr    $0xa,%eax
f0100ca5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ca9:	a1 60 89 11 f0       	mov    0xf0118960,%eax
f0100cae:	c1 e0 0c             	shl    $0xc,%eax
f0100cb1:	c1 e8 0a             	shr    $0xa,%eax
f0100cb4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cb8:	c7 04 24 e8 48 10 f0 	movl   $0xf01048e8,(%esp)
f0100cbf:	e8 f3 24 00 00       	call   f01031b7 <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f0100cc4:	c9                   	leave  
f0100cc5:	c3                   	ret    

f0100cc6 <check_kern_pgdir>:
// but it is a pretty good sanity check.
//

static void
check_kern_pgdir(void)
{
f0100cc6:	55                   	push   %ebp
f0100cc7:	89 e5                	mov    %esp,%ebp
f0100cc9:	57                   	push   %edi
f0100cca:	56                   	push   %esi
f0100ccb:	53                   	push   %ebx
f0100ccc:	83 ec 1c             	sub    $0x1c,%esp
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0100ccf:	8b 1d 64 89 11 f0    	mov    0xf0118964,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0100cd5:	a1 60 89 11 f0       	mov    0xf0118960,%eax
f0100cda:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f0100ce1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0100ce7:	74 79                	je     f0100d62 <check_kern_pgdir+0x9c>
f0100ce9:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0100cee:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0100cf4:	89 d8                	mov    %ebx,%eax
f0100cf6:	e8 38 fe ff ff       	call   f0100b33 <check_va2pa>
f0100cfb:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d01:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100d07:	77 20                	ja     f0100d29 <check_kern_pgdir+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d09:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100d0d:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f0100d14:	f0 
f0100d15:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0100d1c:	00 
f0100d1d:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100d24:	e8 5c f3 ff ff       	call   f0100085 <_panic>
f0100d29:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0100d30:	39 d0                	cmp    %edx,%eax
f0100d32:	74 24                	je     f0100d58 <check_kern_pgdir+0x92>
f0100d34:	c7 44 24 0c 48 49 10 	movl   $0xf0104948,0xc(%esp)
f0100d3b:	f0 
f0100d3c:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100d43:	f0 
f0100d44:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0100d4b:	00 
f0100d4c:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100d53:	e8 2d f3 ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0100d58:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0100d5e:	39 f7                	cmp    %esi,%edi
f0100d60:	77 8c                	ja     f0100cee <check_kern_pgdir+0x28>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0100d62:	a1 60 89 11 f0       	mov    0xf0118960,%eax
f0100d67:	c1 e0 0c             	shl    $0xc,%eax
f0100d6a:	85 c0                	test   %eax,%eax
f0100d6c:	74 4c                	je     f0100dba <check_kern_pgdir+0xf4>
f0100d6e:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0100d73:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0100d79:	89 d8                	mov    %ebx,%eax
f0100d7b:	e8 b3 fd ff ff       	call   f0100b33 <check_va2pa>
f0100d80:	39 f0                	cmp    %esi,%eax
f0100d82:	74 24                	je     f0100da8 <check_kern_pgdir+0xe2>
f0100d84:	c7 44 24 0c 7c 49 10 	movl   $0xf010497c,0xc(%esp)
f0100d8b:	f0 
f0100d8c:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100d93:	f0 
f0100d94:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0100d9b:	00 
f0100d9c:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100da3:	e8 dd f2 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0100da8:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
f0100dae:	a1 60 89 11 f0       	mov    0xf0118960,%eax
f0100db3:	c1 e0 0c             	shl    $0xc,%eax
f0100db6:	39 f0                	cmp    %esi,%eax
f0100db8:	77 b9                	ja     f0100d73 <check_kern_pgdir+0xad>
f0100dba:	be 00 80 bf ef       	mov    $0xefbf8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0100dbf:	bf 00 e0 10 f0       	mov    $0xf010e000,%edi
f0100dc4:	81 c7 00 80 40 20    	add    $0x20408000,%edi
f0100dca:	89 f2                	mov    %esi,%edx
f0100dcc:	89 d8                	mov    %ebx,%eax
f0100dce:	e8 60 fd ff ff       	call   f0100b33 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100dd3:	ba 00 e0 10 f0       	mov    $0xf010e000,%edx
f0100dd8:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100dde:	77 20                	ja     f0100e00 <check_kern_pgdir+0x13a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100de0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100de4:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f0100deb:	f0 
f0100dec:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0100df3:	00 
f0100df4:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100dfb:	e8 85 f2 ff ff       	call   f0100085 <_panic>
f0100e00:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0100e03:	39 d0                	cmp    %edx,%eax
f0100e05:	74 24                	je     f0100e2b <check_kern_pgdir+0x165>
f0100e07:	c7 44 24 0c a4 49 10 	movl   $0xf01049a4,0xc(%esp)
f0100e0e:	f0 
f0100e0f:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100e16:	f0 
f0100e17:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0100e1e:	00 
f0100e1f:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100e26:	e8 5a f2 ff ff       	call   f0100085 <_panic>
f0100e2b:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0100e31:	81 fe 00 00 c0 ef    	cmp    $0xefc00000,%esi
f0100e37:	75 91                	jne    f0100dca <check_kern_pgdir+0x104>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0100e39:	ba 00 00 80 ef       	mov    $0xef800000,%edx
f0100e3e:	89 d8                	mov    %ebx,%eax
f0100e40:	e8 ee fc ff ff       	call   f0100b33 <check_va2pa>
f0100e45:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100e48:	74 24                	je     f0100e6e <check_kern_pgdir+0x1a8>
f0100e4a:	c7 44 24 0c ec 49 10 	movl   $0xf01049ec,0xc(%esp)
f0100e51:	f0 
f0100e52:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100e59:	f0 
f0100e5a:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0100e61:	00 
f0100e62:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100e69:	e8 17 f2 ff ff       	call   f0100085 <_panic>
f0100e6e:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0100e73:	8d 90 44 fc ff ff    	lea    -0x3bc(%eax),%edx
f0100e79:	83 fa 02             	cmp    $0x2,%edx
f0100e7c:	77 2e                	ja     f0100eac <check_kern_pgdir+0x1e6>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0100e7e:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0100e82:	0f 85 aa 00 00 00    	jne    f0100f32 <check_kern_pgdir+0x26c>
f0100e88:	c7 44 24 0c 4f 50 10 	movl   $0xf010504f,0xc(%esp)
f0100e8f:	f0 
f0100e90:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100e97:	f0 
f0100e98:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0100e9f:	00 
f0100ea0:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100ea7:	e8 d9 f1 ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0100eac:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0100eb1:	76 55                	jbe    f0100f08 <check_kern_pgdir+0x242>
				assert(pgdir[i] & PTE_P);
f0100eb3:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0100eb6:	f6 c2 01             	test   $0x1,%dl
f0100eb9:	75 24                	jne    f0100edf <check_kern_pgdir+0x219>
f0100ebb:	c7 44 24 0c 4f 50 10 	movl   $0xf010504f,0xc(%esp)
f0100ec2:	f0 
f0100ec3:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100eca:	f0 
f0100ecb:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0100ed2:	00 
f0100ed3:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100eda:	e8 a6 f1 ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f0100edf:	f6 c2 02             	test   $0x2,%dl
f0100ee2:	75 4e                	jne    f0100f32 <check_kern_pgdir+0x26c>
f0100ee4:	c7 44 24 0c 60 50 10 	movl   $0xf0105060,0xc(%esp)
f0100eeb:	f0 
f0100eec:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100ef3:	f0 
f0100ef4:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0100efb:	00 
f0100efc:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100f03:	e8 7d f1 ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0100f08:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0100f0c:	74 24                	je     f0100f32 <check_kern_pgdir+0x26c>
f0100f0e:	c7 44 24 0c 71 50 10 	movl   $0xf0105071,0xc(%esp)
f0100f15:	f0 
f0100f16:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0100f1d:	f0 
f0100f1e:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0100f25:	00 
f0100f26:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100f2d:	e8 53 f1 ff ff       	call   f0100085 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0100f32:	83 c0 01             	add    $0x1,%eax
f0100f35:	3d 00 04 00 00       	cmp    $0x400,%eax
f0100f3a:	0f 85 33 ff ff ff    	jne    f0100e73 <check_kern_pgdir+0x1ad>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0100f40:	c7 04 24 1c 4a 10 f0 	movl   $0xf0104a1c,(%esp)
f0100f47:	e8 6b 22 00 00       	call   f01031b7 <cprintf>
}
f0100f4c:	83 c4 1c             	add    $0x1c,%esp
f0100f4f:	5b                   	pop    %ebx
f0100f50:	5e                   	pop    %esi
f0100f51:	5f                   	pop    %edi
f0100f52:	5d                   	pop    %ebp
f0100f53:	c3                   	ret    

f0100f54 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100f54:	55                   	push   %ebp
f0100f55:	89 e5                	mov    %esp,%ebp
f0100f57:	83 ec 18             	sub    $0x18,%esp
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	extern char end[];
	n_pages = (ROUNDUP(n, PGSIZE)) >> PGSHIFT;
f0100f5a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
	if (!nextfree) {
f0100f60:	83 3d 48 85 11 f0 00 	cmpl   $0x0,0xf0118548
f0100f67:	75 0f                	jne    f0100f78 <boot_alloc+0x24>
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100f69:	b8 6b 99 11 f0       	mov    $0xf011996b,%eax
f0100f6e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f73:	a3 48 85 11 f0       	mov    %eax,0xf0118548
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	
	result = nextfree;
f0100f78:	a1 48 85 11 f0       	mov    0xf0118548,%eax
	nextfree += n_pages * PGSIZE;
f0100f7d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100f83:	8d 14 10             	lea    (%eax,%edx,1),%edx
f0100f86:	89 15 48 85 11 f0    	mov    %edx,0xf0118548
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f8c:	89 d1                	mov    %edx,%ecx
f0100f8e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100f94:	77 20                	ja     f0100fb6 <boot_alloc+0x62>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f96:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f9a:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f0100fa1:	f0 
f0100fa2:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0100fa9:	00 
f0100faa:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100fb1:	e8 cf f0 ff ff       	call   f0100085 <_panic>

	if (PADDR(nextfree) > npages * PGSIZE) {
f0100fb6:	8b 15 60 89 11 f0    	mov    0xf0118960,%edx
f0100fbc:	c1 e2 0c             	shl    $0xc,%edx
f0100fbf:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f0100fc5:	39 ca                	cmp    %ecx,%edx
f0100fc7:	73 1c                	jae    f0100fe5 <boot_alloc+0x91>
		panic("boot_alloc: Out of physical momery.\n");
f0100fc9:	c7 44 24 08 3c 4a 10 	movl   $0xf0104a3c,0x8(%esp)
f0100fd0:	f0 
f0100fd1:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100fd8:	00 
f0100fd9:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0100fe0:	e8 a0 f0 ff ff       	call   f0100085 <_panic>
	}

	return result;
}
f0100fe5:	c9                   	leave  
f0100fe6:	c3                   	ret    

f0100fe7 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100fe7:	55                   	push   %ebp
f0100fe8:	89 e5                	mov    %esp,%ebp
f0100fea:	56                   	push   %esi
f0100feb:	53                   	push   %ebx
f0100fec:	83 ec 10             	sub    $0x10,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	physaddr_t pa;
	for (i = 0; i < npages; i++) {
f0100fef:	83 3d 60 89 11 f0 00 	cmpl   $0x0,0xf0118960
f0100ff6:	0f 84 1e 01 00 00    	je     f010111a <page_init+0x133>
f0100ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101001:	be 00 00 00 00       	mov    $0x0,%esi
		if (i < npages_basemem) {
f0101006:	39 35 4c 85 11 f0    	cmp    %esi,0xf011854c
f010100c:	76 4f                	jbe    f010105d <page_init+0x76>
			if (i == 0 || i == (MPENTRY_PADDR / PGSIZE)) {
f010100e:	85 f6                	test   %esi,%esi
f0101010:	74 05                	je     f0101017 <page_init+0x30>
f0101012:	83 fe 07             	cmp    $0x7,%esi
f0101015:	75 1d                	jne    f0101034 <page_init+0x4d>
				pages[i].pp_ref = 1;
f0101017:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010101c:	66 c7 44 18 04 01 00 	movw   $0x1,0x4(%eax,%ebx,1)
				pages[i].pp_link = NULL;
f0101023:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101028:	c7 04 18 00 00 00 00 	movl   $0x0,(%eax,%ebx,1)
f010102f:	e9 a2 00 00 00       	jmp    f01010d6 <page_init+0xef>
			} else {
				pages[i].pp_ref = 0;
f0101034:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101039:	66 c7 44 18 04 00 00 	movw   $0x0,0x4(%eax,%ebx,1)
				pages[i].pp_link = page_free_list;
f0101040:	8b 15 50 85 11 f0    	mov    0xf0118550,%edx
f0101046:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010104b:	89 14 18             	mov    %edx,(%eax,%ebx,1)
				page_free_list = &pages[i];
f010104e:	89 d8                	mov    %ebx,%eax
f0101050:	03 05 68 89 11 f0    	add    0xf0118968,%eax
f0101056:	a3 50 85 11 f0       	mov    %eax,0xf0118550
f010105b:	eb 79                	jmp    f01010d6 <page_init+0xef>
			}
		} else if (i < (EXTPHYSMEM / PGSIZE)) {
f010105d:	81 fe ff 00 00 00    	cmp    $0xff,%esi
f0101063:	77 1a                	ja     f010107f <page_init+0x98>
			pages[i].pp_ref = 1;
f0101065:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010106a:	66 c7 44 18 04 01 00 	movw   $0x1,0x4(%eax,%ebx,1)
			pages[i].pp_link = NULL;
f0101071:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f0101076:	c7 04 18 00 00 00 00 	movl   $0x0,(%eax,%ebx,1)
f010107d:	eb 57                	jmp    f01010d6 <page_init+0xef>
		} else if (i<(((uint32_t)boot_alloc(0) - KERNBASE)>>PGSHIFT)){
f010107f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101084:	e8 cb fe ff ff       	call   f0100f54 <boot_alloc>
f0101089:	05 00 00 00 10       	add    $0x10000000,%eax
f010108e:	c1 e8 0c             	shr    $0xc,%eax
f0101091:	39 c6                	cmp    %eax,%esi
f0101093:	73 1a                	jae    f01010af <page_init+0xc8>
      			// 4.1) [EXTPHYSMEM, end of pages]
      			pages[i].pp_ref = 1;
f0101095:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f010109a:	66 c7 44 18 04 01 00 	movw   $0x1,0x4(%eax,%ebx,1)
     			pages[i].pp_link = NULL;
f01010a1:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01010a6:	c7 04 18 00 00 00 00 	movl   $0x0,(%eax,%ebx,1)
f01010ad:	eb 27                	jmp    f01010d6 <page_init+0xef>
    		} else {
      			// 4.2 after pages
      			pages[i].pp_ref = 0;
f01010af:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01010b4:	66 c7 44 18 04 00 00 	movw   $0x0,0x4(%eax,%ebx,1)
     			pages[i].pp_link = page_free_list;
f01010bb:	8b 15 50 85 11 f0    	mov    0xf0118550,%edx
f01010c1:	a1 68 89 11 f0       	mov    0xf0118968,%eax
f01010c6:	89 14 18             	mov    %edx,(%eax,%ebx,1)
      			page_free_list = &pages[i];
f01010c9:	89 d8                	mov    %ebx,%eax
f01010cb:	03 05 68 89 11 f0    	add    0xf0118968,%eax
f01010d1:	a3 50 85 11 f0       	mov    %eax,0xf0118550
    		}
		// check a few pages (on the boundry), not complete
    		pa = page2pa(&pages[i]);
f01010d6:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
f01010dc:	01 da                	add    %ebx,%edx
    		switch(pa) {
f01010de:	89 d8                	mov    %ebx,%eax
f01010e0:	c1 f8 03             	sar    $0x3,%eax
f01010e3:	c1 e0 0c             	shl    $0xc,%eax
f01010e6:	85 c0                	test   %eax,%eax
f01010e8:	74 07                	je     f01010f1 <page_init+0x10a>
f01010ea:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010ef:	75 17                	jne    f0101108 <page_init+0x121>
    			case 0:
    			case IOPHYSMEM:
      				if(pages[i].pp_ref==0)
f01010f1:	66 83 7a 04 00       	cmpw   $0x0,0x4(%edx)
f01010f6:	75 10                	jne    f0101108 <page_init+0x121>
        				cprintf("page error: i %d\n", i);
f01010f8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010fc:	c7 04 24 7f 50 10 f0 	movl   $0xf010507f,(%esp)
f0101103:	e8 af 20 00 00       	call   f01031b7 <cprintf>
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	physaddr_t pa;
	for (i = 0; i < npages; i++) {
f0101108:	83 c6 01             	add    $0x1,%esi
f010110b:	83 c3 08             	add    $0x8,%ebx
f010110e:	39 35 60 89 11 f0    	cmp    %esi,0xf0118960
f0101114:	0f 87 ec fe ff ff    	ja     f0101006 <page_init+0x1f>
		 * pages[i].pp_link = page_free_list;
		 * page_free_list = &pages[i];
     		 */
	}
	
}
f010111a:	83 c4 10             	add    $0x10,%esp
f010111d:	5b                   	pop    %ebx
f010111e:	5e                   	pop    %esi
f010111f:	5d                   	pop    %ebp
f0101120:	c3                   	ret    

f0101121 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0101121:	55                   	push   %ebp
f0101122:	89 e5                	mov    %esp,%ebp
f0101124:	57                   	push   %edi
f0101125:	56                   	push   %esi
f0101126:	53                   	push   %ebx
f0101127:	83 ec 4c             	sub    $0x4c,%esp
	struct Page *pp;
	int pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010112a:	83 f8 01             	cmp    $0x1,%eax
f010112d:	19 f6                	sbb    %esi,%esi
f010112f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0101135:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0101138:	8b 1d 50 85 11 f0    	mov    0xf0118550,%ebx
f010113e:	85 db                	test   %ebx,%ebx
f0101140:	75 1c                	jne    f010115e <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f0101142:	c7 44 24 08 64 4a 10 	movl   $0xf0104a64,0x8(%esp)
f0101149:	f0 
f010114a:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0101151:	00 
f0101152:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101159:	e8 27 ef ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f010115e:	85 c0                	test   %eax,%eax
f0101160:	74 52                	je     f01011b4 <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0101162:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101165:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101168:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010116b:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010116e:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101174:	89 d8                	mov    %ebx,%eax
f0101176:	29 c8                	sub    %ecx,%eax
f0101178:	c1 e0 09             	shl    $0x9,%eax
f010117b:	c1 e8 16             	shr    $0x16,%eax
f010117e:	39 f0                	cmp    %esi,%eax
f0101180:	0f 93 c0             	setae  %al
f0101183:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0101186:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f010118a:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f010118c:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101190:	8b 1b                	mov    (%ebx),%ebx
f0101192:	85 db                	test   %ebx,%ebx
f0101194:	75 de                	jne    f0101174 <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0101196:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101199:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010119f:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01011a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01011a5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01011a7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01011aa:	89 1d 50 85 11 f0    	mov    %ebx,0xf0118550
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f01011b0:	85 db                	test   %ebx,%ebx
f01011b2:	74 67                	je     f010121b <check_page_free_list+0xfa>
f01011b4:	89 d8                	mov    %ebx,%eax
f01011b6:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f01011bc:	c1 f8 03             	sar    $0x3,%eax
f01011bf:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01011c2:	89 c2                	mov    %eax,%edx
f01011c4:	c1 ea 16             	shr    $0x16,%edx
f01011c7:	39 f2                	cmp    %esi,%edx
f01011c9:	73 4a                	jae    f0101215 <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011cb:	89 c2                	mov    %eax,%edx
f01011cd:	c1 ea 0c             	shr    $0xc,%edx
f01011d0:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f01011d6:	72 20                	jb     f01011f8 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011dc:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f01011e3:	f0 
f01011e4:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01011eb:	00 
f01011ec:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f01011f3:	e8 8d ee ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f01011f8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f01011ff:	00 
f0101200:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101207:	00 
f0101208:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010120d:	89 04 24             	mov    %eax,(%esp)
f0101210:	e8 81 2c 00 00       	call   f0103e96 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0101215:	8b 1b                	mov    (%ebx),%ebx
f0101217:	85 db                	test   %ebx,%ebx
f0101219:	75 99                	jne    f01011b4 <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f010121b:	b8 00 00 00 00       	mov    $0x0,%eax
f0101220:	e8 2f fd ff ff       	call   f0100f54 <boot_alloc>
f0101225:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101228:	a1 50 85 11 f0       	mov    0xf0118550,%eax
f010122d:	85 c0                	test   %eax,%eax
f010122f:	0f 84 0d 02 00 00    	je     f0101442 <check_page_free_list+0x321>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101235:	8b 0d 68 89 11 f0    	mov    0xf0118968,%ecx
f010123b:	39 c8                	cmp    %ecx,%eax
f010123d:	72 53                	jb     f0101292 <check_page_free_list+0x171>
		assert(pp < pages + npages);
f010123f:	8b 15 60 89 11 f0    	mov    0xf0118960,%edx
f0101245:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0101248:	8d 3c d1             	lea    (%ecx,%edx,8),%edi
f010124b:	39 f8                	cmp    %edi,%eax
f010124d:	73 6b                	jae    f01012ba <check_page_free_list+0x199>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010124f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101252:	89 c2                	mov    %eax,%edx
f0101254:	29 ca                	sub    %ecx,%edx
f0101256:	f6 c2 07             	test   $0x7,%dl
f0101259:	0f 85 89 00 00 00    	jne    f01012e8 <check_page_free_list+0x1c7>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010125f:	c1 fa 03             	sar    $0x3,%edx
f0101262:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101265:	85 d2                	test   %edx,%edx
f0101267:	0f 84 a9 00 00 00    	je     f0101316 <check_page_free_list+0x1f5>
		assert(page2pa(pp) != IOPHYSMEM);
f010126d:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f0101273:	0f 84 c9 00 00 00    	je     f0101342 <check_page_free_list+0x221>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101279:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f010127f:	0f 85 0d 01 00 00    	jne    f0101392 <check_page_free_list+0x271>
f0101285:	8d 76 00             	lea    0x0(%esi),%esi
f0101288:	e9 e1 00 00 00       	jmp    f010136e <check_page_free_list+0x24d>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010128d:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
f0101290:	73 24                	jae    f01012b6 <check_page_free_list+0x195>
f0101292:	c7 44 24 0c 9f 50 10 	movl   $0xf010509f,0xc(%esp)
f0101299:	f0 
f010129a:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01012a1:	f0 
f01012a2:	c7 44 24 04 aa 02 00 	movl   $0x2aa,0x4(%esp)
f01012a9:	00 
f01012aa:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01012b1:	e8 cf ed ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f01012b6:	39 f8                	cmp    %edi,%eax
f01012b8:	72 24                	jb     f01012de <check_page_free_list+0x1bd>
f01012ba:	c7 44 24 0c ab 50 10 	movl   $0xf01050ab,0xc(%esp)
f01012c1:	f0 
f01012c2:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01012c9:	f0 
f01012ca:	c7 44 24 04 ab 02 00 	movl   $0x2ab,0x4(%esp)
f01012d1:	00 
f01012d2:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01012d9:	e8 a7 ed ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01012de:	89 c2                	mov    %eax,%edx
f01012e0:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f01012e3:	f6 c2 07             	test   $0x7,%dl
f01012e6:	74 24                	je     f010130c <check_page_free_list+0x1eb>
f01012e8:	c7 44 24 0c 88 4a 10 	movl   $0xf0104a88,0xc(%esp)
f01012ef:	f0 
f01012f0:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01012f7:	f0 
f01012f8:	c7 44 24 04 ac 02 00 	movl   $0x2ac,0x4(%esp)
f01012ff:	00 
f0101300:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101307:	e8 79 ed ff ff       	call   f0100085 <_panic>
f010130c:	c1 fa 03             	sar    $0x3,%edx
f010130f:	c1 e2 0c             	shl    $0xc,%edx

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101312:	85 d2                	test   %edx,%edx
f0101314:	75 24                	jne    f010133a <check_page_free_list+0x219>
f0101316:	c7 44 24 0c bf 50 10 	movl   $0xf01050bf,0xc(%esp)
f010131d:	f0 
f010131e:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101325:	f0 
f0101326:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f010132d:	00 
f010132e:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101335:	e8 4b ed ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010133a:	81 fa 00 00 0a 00    	cmp    $0xa0000,%edx
f0101340:	75 24                	jne    f0101366 <check_page_free_list+0x245>
f0101342:	c7 44 24 0c d0 50 10 	movl   $0xf01050d0,0xc(%esp)
f0101349:	f0 
f010134a:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101351:	f0 
f0101352:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f0101359:	00 
f010135a:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101361:	e8 1f ed ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101366:	81 fa 00 f0 0f 00    	cmp    $0xff000,%edx
f010136c:	75 31                	jne    f010139f <check_page_free_list+0x27e>
f010136e:	c7 44 24 0c bc 4a 10 	movl   $0xf0104abc,0xc(%esp)
f0101375:	f0 
f0101376:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010137d:	f0 
f010137e:	c7 44 24 04 b1 02 00 	movl   $0x2b1,0x4(%esp)
f0101385:	00 
f0101386:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010138d:	e8 f3 ec ff ff       	call   f0100085 <_panic>
f0101392:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101397:	be 00 00 00 00       	mov    $0x0,%esi
f010139c:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f010139f:	81 fa 00 00 10 00    	cmp    $0x100000,%edx
f01013a5:	75 24                	jne    f01013cb <check_page_free_list+0x2aa>
f01013a7:	c7 44 24 0c e9 50 10 	movl   $0xf01050e9,0xc(%esp)
f01013ae:	f0 
f01013af:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01013b6:	f0 
f01013b7:	c7 44 24 04 b2 02 00 	movl   $0x2b2,0x4(%esp)
f01013be:	00 
f01013bf:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01013c6:	e8 ba ec ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f01013cb:	81 fa ff ff 0f 00    	cmp    $0xfffff,%edx
f01013d1:	76 59                	jbe    f010142c <check_page_free_list+0x30b>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013d3:	89 d1                	mov    %edx,%ecx
f01013d5:	c1 e9 0c             	shr    $0xc,%ecx
f01013d8:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f01013db:	77 20                	ja     f01013fd <check_page_free_list+0x2dc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01013e1:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f01013e8:	f0 
f01013e9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01013f0:	00 
f01013f1:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f01013f8:	e8 88 ec ff ff       	call   f0100085 <_panic>
f01013fd:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101403:	39 55 c8             	cmp    %edx,-0x38(%ebp)
f0101406:	76 29                	jbe    f0101431 <check_page_free_list+0x310>
f0101408:	c7 44 24 0c e0 4a 10 	movl   $0xf0104ae0,0xc(%esp)
f010140f:	f0 
f0101410:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101417:	f0 
f0101418:	c7 44 24 04 b3 02 00 	movl   $0x2b3,0x4(%esp)
f010141f:	00 
f0101420:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101427:	e8 59 ec ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f010142c:	83 c6 01             	add    $0x1,%esi
f010142f:	eb 03                	jmp    f0101434 <check_page_free_list+0x313>
		else
			++nfree_extmem;
f0101431:	83 c3 01             	add    $0x1,%ebx
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101434:	8b 00                	mov    (%eax),%eax
f0101436:	85 c0                	test   %eax,%eax
f0101438:	0f 85 4f fe ff ff    	jne    f010128d <check_page_free_list+0x16c>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010143e:	85 f6                	test   %esi,%esi
f0101440:	7f 24                	jg     f0101466 <check_page_free_list+0x345>
f0101442:	c7 44 24 0c 03 51 10 	movl   $0xf0105103,0xc(%esp)
f0101449:	f0 
f010144a:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101451:	f0 
f0101452:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101459:	00 
f010145a:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101461:	e8 1f ec ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f0101466:	85 db                	test   %ebx,%ebx
f0101468:	7f 24                	jg     f010148e <check_page_free_list+0x36d>
f010146a:	c7 44 24 0c 15 51 10 	movl   $0xf0105115,0xc(%esp)
f0101471:	f0 
f0101472:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101479:	f0 
f010147a:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f0101481:	00 
f0101482:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101489:	e8 f7 eb ff ff       	call   f0100085 <_panic>
}
f010148e:	83 c4 4c             	add    $0x4c,%esp
f0101491:	5b                   	pop    %ebx
f0101492:	5e                   	pop    %esi
f0101493:	5f                   	pop    %edi
f0101494:	5d                   	pop    %ebp
f0101495:	c3                   	ret    

f0101496 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f0101496:	55                   	push   %ebp
f0101497:	89 e5                	mov    %esp,%ebp
f0101499:	53                   	push   %ebx
f010149a:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if (! page_free_list) 
f010149d:	8b 1d 50 85 11 f0    	mov    0xf0118550,%ebx
f01014a3:	85 db                	test   %ebx,%ebx
f01014a5:	74 65                	je     f010150c <page_alloc+0x76>
		return NULL;
	struct Page *pp = NULL;
	pp = page_free_list;
	page_free_list = page_free_list->pp_link;
f01014a7:	8b 03                	mov    (%ebx),%eax
f01014a9:	a3 50 85 11 f0       	mov    %eax,0xf0118550
	if (alloc_flags & ALLOC_ZERO)
f01014ae:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01014b2:	74 58                	je     f010150c <page_alloc+0x76>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01014b4:	89 d8                	mov    %ebx,%eax
f01014b6:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f01014bc:	c1 f8 03             	sar    $0x3,%eax
f01014bf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014c2:	89 c2                	mov    %eax,%edx
f01014c4:	c1 ea 0c             	shr    $0xc,%edx
f01014c7:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f01014cd:	72 20                	jb     f01014ef <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01014cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01014d3:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f01014da:	f0 
f01014db:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01014e2:	00 
f01014e3:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f01014ea:	e8 96 eb ff ff       	call   f0100085 <_panic>
		memset(page2kva(pp), 0, PGSIZE);
f01014ef:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01014f6:	00 
f01014f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01014fe:	00 
f01014ff:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101504:	89 04 24             	mov    %eax,(%esp)
f0101507:	e8 8a 29 00 00       	call   f0103e96 <memset>
	return pp;
}
f010150c:	89 d8                	mov    %ebx,%eax
f010150e:	83 c4 14             	add    $0x14,%esp
f0101511:	5b                   	pop    %ebx
f0101512:	5d                   	pop    %ebp
f0101513:	c3                   	ret    

f0101514 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101514:	55                   	push   %ebp
f0101515:	89 e5                	mov    %esp,%ebp
f0101517:	83 ec 28             	sub    $0x28,%esp
f010151a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010151d:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101520:	89 7d fc             	mov    %edi,-0x4(%ebp)
	// Fill this function in
	pde_t *pde;
	pte_t *pgtab;
	struct Page *pp;
	pde = &pgdir[PDX(va)];
f0101523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101526:	89 de                	mov    %ebx,%esi
f0101528:	c1 ee 16             	shr    $0x16,%esi
f010152b:	c1 e6 02             	shl    $0x2,%esi
f010152e:	03 75 08             	add    0x8(%ebp),%esi
	if (*pde & PTE_P) {
f0101531:	8b 06                	mov    (%esi),%eax
f0101533:	a8 01                	test   $0x1,%al
f0101535:	74 3c                	je     f0101573 <pgdir_walk+0x5f>
		pgtab = (KADDR(PTE_ADDR(*pde)));
f0101537:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010153c:	89 c2                	mov    %eax,%edx
f010153e:	c1 ea 0c             	shr    $0xc,%edx
f0101541:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0101547:	72 20                	jb     f0101569 <pgdir_walk+0x55>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101549:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010154d:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0101554:	f0 
f0101555:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
f010155c:	00 
f010155d:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101564:	e8 1c eb ff ff       	call   f0100085 <_panic>
f0101569:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010156e:	e9 99 00 00 00       	jmp    f010160c <pgdir_walk+0xf8>
	} else {
		if (!create || !(pp = page_alloc(ALLOC_ZERO)) ||
f0101573:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101577:	0f 84 9c 00 00 00    	je     f0101619 <pgdir_walk+0x105>
f010157d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101584:	e8 0d ff ff ff       	call   f0101496 <page_alloc>
f0101589:	89 c2                	mov    %eax,%edx
f010158b:	85 c0                	test   %eax,%eax
f010158d:	0f 84 86 00 00 00    	je     f0101619 <pgdir_walk+0x105>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101593:	89 c1                	mov    %eax,%ecx
f0101595:	2b 0d 68 89 11 f0    	sub    0xf0118968,%ecx
f010159b:	c1 f9 03             	sar    $0x3,%ecx
f010159e:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015a1:	89 c8                	mov    %ecx,%eax
f01015a3:	c1 e8 0c             	shr    $0xc,%eax
f01015a6:	3b 05 60 89 11 f0    	cmp    0xf0118960,%eax
f01015ac:	72 20                	jb     f01015ce <pgdir_walk+0xba>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015ae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01015b2:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f01015b9:	f0 
f01015ba:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01015c1:	00 
f01015c2:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f01015c9:	e8 b7 ea ff ff       	call   f0100085 <_panic>
	return (void *)(pa + KERNBASE);
f01015ce:	8d b9 00 00 00 f0    	lea    -0x10000000(%ecx),%edi
f01015d4:	89 f8                	mov    %edi,%eax
f01015d6:	85 ff                	test   %edi,%edi
f01015d8:	74 3f                	je     f0101619 <pgdir_walk+0x105>
				!(pgtab = (pte_t*)page2kva(pp)))
			return NULL;
		pp->pp_ref++;
f01015da:	66 83 42 04 01       	addw   $0x1,0x4(%edx)
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01015df:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01015e5:	77 20                	ja     f0101607 <pgdir_walk+0xf3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01015e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01015eb:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f01015f2:	f0 
f01015f3:	c7 44 24 04 dd 01 00 	movl   $0x1dd,0x4(%esp)
f01015fa:	00 
f01015fb:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101602:	e8 7e ea ff ff       	call   f0100085 <_panic>
		*pde = PADDR(pgtab) | PTE_P | PTE_W | PTE_U;
f0101607:	83 c9 07             	or     $0x7,%ecx
f010160a:	89 0e                	mov    %ecx,(%esi)
	}
	return &pgtab[PTX(va)];
f010160c:	c1 eb 0a             	shr    $0xa,%ebx
f010160f:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101615:	01 d8                	add    %ebx,%eax
f0101617:	eb 05                	jmp    f010161e <pgdir_walk+0x10a>
f0101619:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010161e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101621:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101624:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101627:	89 ec                	mov    %ebp,%esp
f0101629:	5d                   	pop    %ebp
f010162a:	c3                   	ret    

f010162b <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010162b:	55                   	push   %ebp
f010162c:	89 e5                	mov    %esp,%ebp
f010162e:	53                   	push   %ebx
f010162f:	83 ec 14             	sub    $0x14,%esp
f0101632:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t * pgtab = pgdir_walk(pgdir, va, 0);
f0101635:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010163c:	00 
f010163d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101640:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101644:	8b 45 08             	mov    0x8(%ebp),%eax
f0101647:	89 04 24             	mov    %eax,(%esp)
f010164a:	e8 c5 fe ff ff       	call   f0101514 <pgdir_walk>
  	if (pgtab) {
f010164f:	ba 00 00 00 00       	mov    $0x0,%edx
f0101654:	85 c0                	test   %eax,%eax
f0101656:	74 38                	je     f0101690 <page_lookup+0x65>
    		if(pte_store) *pte_store = pgtab;
f0101658:	85 db                	test   %ebx,%ebx
f010165a:	74 02                	je     f010165e <page_lookup+0x33>
f010165c:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010165e:	8b 10                	mov    (%eax),%edx
f0101660:	c1 ea 0c             	shr    $0xc,%edx
f0101663:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0101669:	72 1c                	jb     f0101687 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f010166b:	c7 44 24 08 28 4b 10 	movl   $0xf0104b28,0x8(%esp)
f0101672:	f0 
f0101673:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f010167a:	00 
f010167b:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f0101682:	e8 fe e9 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101687:	c1 e2 03             	shl    $0x3,%edx
f010168a:	03 15 68 89 11 f0    	add    0xf0118968,%edx
   		return pa2page(PTE_ADDR(*pgtab));
  	} else
    		return NULL;
}
f0101690:	89 d0                	mov    %edx,%eax
f0101692:	83 c4 14             	add    $0x14,%esp
f0101695:	5b                   	pop    %ebx
f0101696:	5d                   	pop    %ebp
f0101697:	c3                   	ret    

f0101698 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101698:	55                   	push   %ebp
f0101699:	89 e5                	mov    %esp,%ebp
f010169b:	83 ec 28             	sub    $0x28,%esp
f010169e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01016a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01016a4:	8b 75 08             	mov    0x8(%ebp),%esi
f01016a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte;
  	pte_t **pte_store = &pte;
  	struct Page * pp = page_lookup(pgdir, va, pte_store);
f01016aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01016ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01016b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016b5:	89 34 24             	mov    %esi,(%esp)
f01016b8:	e8 6e ff ff ff       	call   f010162b <page_lookup>
  	if(!pp) return;
f01016bd:	85 c0                	test   %eax,%eax
f01016bf:	74 1d                	je     f01016de <page_remove+0x46>
  	page_decref(pp);
f01016c1:	89 04 24             	mov    %eax,(%esp)
f01016c4:	e8 13 f5 ff ff       	call   f0100bdc <page_decref>
  	**pte_store = 0;
f01016c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01016cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  	tlb_invalidate(pgdir, va);
f01016d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01016d6:	89 34 24             	mov    %esi,(%esp)
f01016d9:	e8 4a f4 ff ff       	call   f0100b28 <tlb_invalidate>
}
f01016de:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01016e1:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01016e4:	89 ec                	mov    %ebp,%esp
f01016e6:	5d                   	pop    %ebp
f01016e7:	c3                   	ret    

f01016e8 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01016e8:	55                   	push   %ebp
f01016e9:	89 e5                	mov    %esp,%ebp
f01016eb:	83 ec 28             	sub    $0x28,%esp
f01016ee:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01016f1:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01016f4:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01016f7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01016fa:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t * pte;
  	pte = pgdir_walk(pgdir, va, 1);
f01016fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101704:	00 
f0101705:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101709:	8b 45 08             	mov    0x8(%ebp),%eax
f010170c:	89 04 24             	mov    %eax,(%esp)
f010170f:	e8 00 fe ff ff       	call   f0101514 <pgdir_walk>
f0101714:	89 c3                	mov    %eax,%ebx
  	//cprintf("page_insert pa 0x%x, va 0x%x\n", page2pa(pp), (uint32_t)va);
  	if (pte) {
f0101716:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010171b:	85 db                	test   %ebx,%ebx
f010171d:	0f 84 81 00 00 00    	je     f01017a4 <page_insert+0xbc>
    		if (*pte&PTE_P) {
f0101723:	8b 03                	mov    (%ebx),%eax
f0101725:	a8 01                	test   $0x1,%al
f0101727:	74 59                	je     f0101782 <page_insert+0x9a>
      		// this case means just change permission
      			if (PTE_ADDR(*pte)==page2pa(pp)) {
f0101729:	89 c1                	mov    %eax,%ecx
f010172b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101731:	89 f2                	mov    %esi,%edx
f0101733:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f0101739:	c1 fa 03             	sar    $0x3,%edx
f010173c:	c1 e2 0c             	shl    $0xc,%edx
f010173f:	39 d1                	cmp    %edx,%ecx
f0101741:	75 30                	jne    f0101773 <page_insert+0x8b>
        			// fix PTE_COW and PTE_W bug (mutual exclusive)
        			if (perm & PTE_COW) {
f0101743:	f7 45 14 00 08 00 00 	testl  $0x800,0x14(%ebp)
f010174a:	74 07                	je     f0101753 <page_insert+0x6b>
          				*pte &= ~PTE_W;
f010174c:	83 e0 fd             	and    $0xfffffffd,%eax
f010174f:	89 03                	mov    %eax,(%ebx)
f0101751:	eb 0b                	jmp    f010175e <page_insert+0x76>
        			} else if (perm & PTE_W) {
f0101753:	f6 45 14 02          	testb  $0x2,0x14(%ebp)
f0101757:	74 05                	je     f010175e <page_insert+0x76>
          				*pte &= ~PTE_COW;
f0101759:	80 e4 f7             	and    $0xf7,%ah
f010175c:	89 03                	mov    %eax,(%ebx)
        			}
        			// fix PTE_D, clear it when not in perm
        			if ((perm & PTE_D) == 0) {
f010175e:	f6 45 14 40          	testb  $0x40,0x14(%ebp)
f0101762:	75 03                	jne    f0101767 <page_insert+0x7f>
          				*pte &= ~PTE_D;
f0101764:	83 23 bf             	andl   $0xffffffbf,(%ebx)
        			}
        
        			*pte |= perm; // maybe wrong here, cannot clear a bit
f0101767:	8b 45 14             	mov    0x14(%ebp),%eax
f010176a:	09 03                	or     %eax,(%ebx)
f010176c:	b8 00 00 00 00       	mov    $0x0,%eax
        			//pp->pp_ref++; //? and shall I change perm?
        			return 0;
f0101771:	eb 31                	jmp    f01017a4 <page_insert+0xbc>
      			} else {
        			page_remove(pgdir, va);
f0101773:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101777:	8b 45 08             	mov    0x8(%ebp),%eax
f010177a:	89 04 24             	mov    %eax,(%esp)
f010177d:	e8 16 ff ff ff       	call   f0101698 <page_remove>
      			}
    		}
  	} else {
    		return -E_NO_MEM;
  	}
  	*pte = page2pa(pp) | perm | PTE_P;
f0101782:	8b 55 14             	mov    0x14(%ebp),%edx
f0101785:	83 ca 01             	or     $0x1,%edx
f0101788:	89 f0                	mov    %esi,%eax
f010178a:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f0101790:	c1 f8 03             	sar    $0x3,%eax
f0101793:	c1 e0 0c             	shl    $0xc,%eax
f0101796:	09 d0                	or     %edx,%eax
f0101798:	89 03                	mov    %eax,(%ebx)
 	pp->pp_ref++;
f010179a:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
f010179f:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01017a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01017a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01017aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01017ad:	89 ec                	mov    %ebp,%esp
f01017af:	5d                   	pop    %ebp
f01017b0:	c3                   	ret    

f01017b1 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01017b1:	55                   	push   %ebp
f01017b2:	89 e5                	mov    %esp,%ebp
f01017b4:	57                   	push   %edi
f01017b5:	56                   	push   %esi
f01017b6:	53                   	push   %ebx
f01017b7:	83 ec 2c             	sub    $0x2c,%esp
f01017ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01017bd:	89 d7                	mov    %edx,%edi
f01017bf:	89 cb                	mov    %ecx,%ebx
f01017c1:	8b 75 08             	mov    0x8(%ebp),%esi
	// Fill this function in
	uintptr_t va_temp = va;
  	physaddr_t pa_temp = pa;
  	pte_t * pte;
  	physaddr_t pa_check;
  	assert(size%PGSIZE == 0 || 
f01017c4:	f7 c1 ff 0f 00 00    	test   $0xfff,%ecx
f01017ca:	74 40                	je     f010180c <boot_map_region+0x5b>
f01017cc:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01017d0:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017d4:	89 54 24 04          	mov    %edx,0x4(%esp)
f01017d8:	c7 04 24 26 51 10 f0 	movl   $0xf0105126,(%esp)
f01017df:	e8 d3 19 00 00       	call   f01031b7 <cprintf>
f01017e4:	85 c0                	test   %eax,%eax
f01017e6:	75 24                	jne    f010180c <boot_map_region+0x5b>
f01017e8:	c7 44 24 0c 48 4b 10 	movl   $0xf0104b48,0xc(%esp)
f01017ef:	f0 
f01017f0:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01017f7:	f0 
f01017f8:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
f01017ff:	00 
f0101800:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101807:	e8 79 e8 ff ff       	call   f0100085 <_panic>
        cprintf("va 0x%x, size 0x%x, pa 0x%x\n", va, size, pa));
  	uint32_t np = size/PGSIZE;
f010180c:	c1 eb 0c             	shr    $0xc,%ebx
f010180f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0101812:	89 fb                	mov    %edi,%ebx
f0101814:	bf 00 00 00 00       	mov    $0x0,%edi
  	uint32_t i = 0;

  	//cprintf("va 0x%x, size 0x%x, pa 0x%x\n", va, size, pa);
  	do {
    		pte = pgdir_walk(pgdir, (void *)va_temp, 1); 
f0101819:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101820:	00 
f0101821:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101825:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101828:	89 04 24             	mov    %eax,(%esp)
f010182b:	e8 e4 fc ff ff       	call   f0101514 <pgdir_walk>
    		*pte |= (PTE_ADDR(pa_temp) | perm);
f0101830:	89 f2                	mov    %esi,%edx
f0101832:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101838:	0b 10                	or     (%eax),%edx
f010183a:	0b 55 0c             	or     0xc(%ebp),%edx
f010183d:	89 10                	mov    %edx,(%eax)
    		va_temp += PGSIZE;
f010183f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    		pa_temp += PGSIZE;
f0101845:	81 c6 00 10 00 00    	add    $0x1000,%esi
  	} while(++i < np);
f010184b:	83 c7 01             	add    $0x1,%edi
f010184e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
f0101851:	77 c6                	ja     f0101819 <boot_map_region+0x68>
}
f0101853:	83 c4 2c             	add    $0x2c,%esp
f0101856:	5b                   	pop    %ebx
f0101857:	5e                   	pop    %esi
f0101858:	5f                   	pop    %edi
f0101859:	5d                   	pop    %ebp
f010185a:	c3                   	ret    

f010185b <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f010185b:	55                   	push   %ebp
f010185c:	89 e5                	mov    %esp,%ebp
f010185e:	57                   	push   %edi
f010185f:	56                   	push   %esi
f0101860:	53                   	push   %ebx
f0101861:	83 ec 2c             	sub    $0x2c,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101864:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010186b:	e8 26 fc ff ff       	call   f0101496 <page_alloc>
f0101870:	89 c3                	mov    %eax,%ebx
f0101872:	85 c0                	test   %eax,%eax
f0101874:	75 24                	jne    f010189a <check_page_installed_pgdir+0x3f>
f0101876:	c7 44 24 0c 43 51 10 	movl   $0xf0105143,0xc(%esp)
f010187d:	f0 
f010187e:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101885:	f0 
f0101886:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f010188d:	00 
f010188e:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101895:	e8 eb e7 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f010189a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018a1:	e8 f0 fb ff ff       	call   f0101496 <page_alloc>
f01018a6:	89 c7                	mov    %eax,%edi
f01018a8:	85 c0                	test   %eax,%eax
f01018aa:	75 24                	jne    f01018d0 <check_page_installed_pgdir+0x75>
f01018ac:	c7 44 24 0c 59 51 10 	movl   $0xf0105159,0xc(%esp)
f01018b3:	f0 
f01018b4:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01018bb:	f0 
f01018bc:	c7 44 24 04 25 04 00 	movl   $0x425,0x4(%esp)
f01018c3:	00 
f01018c4:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01018cb:	e8 b5 e7 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01018d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018d7:	e8 ba fb ff ff       	call   f0101496 <page_alloc>
f01018dc:	89 c6                	mov    %eax,%esi
f01018de:	85 c0                	test   %eax,%eax
f01018e0:	75 24                	jne    f0101906 <check_page_installed_pgdir+0xab>
f01018e2:	c7 44 24 0c 6f 51 10 	movl   $0xf010516f,0xc(%esp)
f01018e9:	f0 
f01018ea:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01018f1:	f0 
f01018f2:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f01018f9:	00 
f01018fa:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101901:	e8 7f e7 ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f0101906:	89 1c 24             	mov    %ebx,(%esp)
f0101909:	e8 8b f2 ff ff       	call   f0100b99 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010190e:	89 f8                	mov    %edi,%eax
f0101910:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f0101916:	c1 f8 03             	sar    $0x3,%eax
f0101919:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010191c:	89 c2                	mov    %eax,%edx
f010191e:	c1 ea 0c             	shr    $0xc,%edx
f0101921:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0101927:	72 20                	jb     f0101949 <check_page_installed_pgdir+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101929:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010192d:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0101934:	f0 
f0101935:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010193c:	00 
f010193d:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f0101944:	e8 3c e7 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0101949:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101950:	00 
f0101951:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101958:	00 
f0101959:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010195e:	89 04 24             	mov    %eax,(%esp)
f0101961:	e8 30 25 00 00       	call   f0103e96 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101966:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0101969:	89 f0                	mov    %esi,%eax
f010196b:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f0101971:	c1 f8 03             	sar    $0x3,%eax
f0101974:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101977:	89 c2                	mov    %eax,%edx
f0101979:	c1 ea 0c             	shr    $0xc,%edx
f010197c:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0101982:	72 20                	jb     f01019a4 <check_page_installed_pgdir+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101984:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101988:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f010198f:	f0 
f0101990:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101997:	00 
f0101998:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f010199f:	e8 e1 e6 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01019a4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019ab:	00 
f01019ac:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01019b3:	00 
f01019b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01019b9:	89 04 24             	mov    %eax,(%esp)
f01019bc:	e8 d5 24 00 00       	call   f0103e96 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01019c1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01019c8:	00 
f01019c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019d0:	00 
f01019d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01019d5:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01019da:	89 04 24             	mov    %eax,(%esp)
f01019dd:	e8 06 fd ff ff       	call   f01016e8 <page_insert>
	assert(pp1->pp_ref == 1);
f01019e2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019e7:	74 24                	je     f0101a0d <check_page_installed_pgdir+0x1b2>
f01019e9:	c7 44 24 0c 85 51 10 	movl   $0xf0105185,0xc(%esp)
f01019f0:	f0 
f01019f1:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01019f8:	f0 
f01019f9:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0101a00:	00 
f0101a01:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101a08:	e8 78 e6 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0101a0d:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0101a14:	01 01 01 
f0101a17:	74 24                	je     f0101a3d <check_page_installed_pgdir+0x1e2>
f0101a19:	c7 44 24 0c 94 4b 10 	movl   $0xf0104b94,0xc(%esp)
f0101a20:	f0 
f0101a21:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101a28:	f0 
f0101a29:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0101a30:	00 
f0101a31:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101a38:	e8 48 e6 ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0101a3d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a44:	00 
f0101a45:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a4c:	00 
f0101a4d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101a51:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101a56:	89 04 24             	mov    %eax,(%esp)
f0101a59:	e8 8a fc ff ff       	call   f01016e8 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0101a5e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0101a65:	02 02 02 
f0101a68:	74 24                	je     f0101a8e <check_page_installed_pgdir+0x233>
f0101a6a:	c7 44 24 0c b8 4b 10 	movl   $0xf0104bb8,0xc(%esp)
f0101a71:	f0 
f0101a72:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101a79:	f0 
f0101a7a:	c7 44 24 04 2e 04 00 	movl   $0x42e,0x4(%esp)
f0101a81:	00 
f0101a82:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101a89:	e8 f7 e5 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101a8e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a93:	74 24                	je     f0101ab9 <check_page_installed_pgdir+0x25e>
f0101a95:	c7 44 24 0c 96 51 10 	movl   $0xf0105196,0xc(%esp)
f0101a9c:	f0 
f0101a9d:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101aa4:	f0 
f0101aa5:	c7 44 24 04 2f 04 00 	movl   $0x42f,0x4(%esp)
f0101aac:	00 
f0101aad:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101ab4:	e8 cc e5 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0101ab9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101abe:	74 24                	je     f0101ae4 <check_page_installed_pgdir+0x289>
f0101ac0:	c7 44 24 0c a7 51 10 	movl   $0xf01051a7,0xc(%esp)
f0101ac7:	f0 
f0101ac8:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101acf:	f0 
f0101ad0:	c7 44 24 04 30 04 00 	movl   $0x430,0x4(%esp)
f0101ad7:	00 
f0101ad8:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101adf:	e8 a1 e5 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0101ae4:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0101aeb:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101af1:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f0101af7:	c1 f8 03             	sar    $0x3,%eax
f0101afa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101afd:	89 c2                	mov    %eax,%edx
f0101aff:	c1 ea 0c             	shr    $0xc,%edx
f0101b02:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0101b08:	72 20                	jb     f0101b2a <check_page_installed_pgdir+0x2cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101b0e:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0101b15:	f0 
f0101b16:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101b1d:	00 
f0101b1e:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f0101b25:	e8 5b e5 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0101b2a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0101b31:	03 03 03 
f0101b34:	74 24                	je     f0101b5a <check_page_installed_pgdir+0x2ff>
f0101b36:	c7 44 24 0c dc 4b 10 	movl   $0xf0104bdc,0xc(%esp)
f0101b3d:	f0 
f0101b3e:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101b45:	f0 
f0101b46:	c7 44 24 04 32 04 00 	movl   $0x432,0x4(%esp)
f0101b4d:	00 
f0101b4e:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101b55:	e8 2b e5 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101b5a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101b61:	00 
f0101b62:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101b67:	89 04 24             	mov    %eax,(%esp)
f0101b6a:	e8 29 fb ff ff       	call   f0101698 <page_remove>
	assert(pp2->pp_ref == 0);
f0101b6f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101b74:	74 24                	je     f0101b9a <check_page_installed_pgdir+0x33f>
f0101b76:	c7 44 24 0c b8 51 10 	movl   $0xf01051b8,0xc(%esp)
f0101b7d:	f0 
f0101b7e:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101b85:	f0 
f0101b86:	c7 44 24 04 34 04 00 	movl   $0x434,0x4(%esp)
f0101b8d:	00 
f0101b8e:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101b95:	e8 eb e4 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b9a:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0101b9f:	8b 08                	mov    (%eax),%ecx
f0101ba1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101ba7:	89 da                	mov    %ebx,%edx
f0101ba9:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f0101baf:	c1 fa 03             	sar    $0x3,%edx
f0101bb2:	c1 e2 0c             	shl    $0xc,%edx
f0101bb5:	39 d1                	cmp    %edx,%ecx
f0101bb7:	74 24                	je     f0101bdd <check_page_installed_pgdir+0x382>
f0101bb9:	c7 44 24 0c 08 4c 10 	movl   $0xf0104c08,0xc(%esp)
f0101bc0:	f0 
f0101bc1:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101bc8:	f0 
f0101bc9:	c7 44 24 04 37 04 00 	movl   $0x437,0x4(%esp)
f0101bd0:	00 
f0101bd1:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101bd8:	e8 a8 e4 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0101bdd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0101be3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101be8:	74 24                	je     f0101c0e <check_page_installed_pgdir+0x3b3>
f0101bea:	c7 44 24 0c c9 51 10 	movl   $0xf01051c9,0xc(%esp)
f0101bf1:	f0 
f0101bf2:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101bf9:	f0 
f0101bfa:	c7 44 24 04 39 04 00 	movl   $0x439,0x4(%esp)
f0101c01:	00 
f0101c02:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101c09:	e8 77 e4 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0101c0e:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0101c14:	89 1c 24             	mov    %ebx,(%esp)
f0101c17:	e8 7d ef ff ff       	call   f0100b99 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0101c1c:	c7 04 24 30 4c 10 f0 	movl   $0xf0104c30,(%esp)
f0101c23:	e8 8f 15 00 00       	call   f01031b7 <cprintf>
}
f0101c28:	83 c4 2c             	add    $0x2c,%esp
f0101c2b:	5b                   	pop    %ebx
f0101c2c:	5e                   	pop    %esi
f0101c2d:	5f                   	pop    %edi
f0101c2e:	5d                   	pop    %ebp
f0101c2f:	c3                   	ret    

f0101c30 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101c30:	55                   	push   %ebp
f0101c31:	89 e5                	mov    %esp,%ebp
f0101c33:	57                   	push   %edi
f0101c34:	56                   	push   %esi
f0101c35:	53                   	push   %ebx
f0101c36:	83 ec 3c             	sub    $0x3c,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f0101c39:	e8 f3 ef ff ff       	call   f0100c31 <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101c3e:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101c43:	e8 0c f3 ff ff       	call   f0100f54 <boot_alloc>
f0101c48:	a3 64 89 11 f0       	mov    %eax,0xf0118964
	memset(kern_pgdir, 0, PGSIZE);
f0101c4d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c54:	00 
f0101c55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c5c:	00 
f0101c5d:	89 04 24             	mov    %eax,(%esp)
f0101c60:	e8 31 22 00 00       	call   f0103e96 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101c65:	a1 64 89 11 f0       	mov    0xf0118964,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101c6a:	89 c2                	mov    %eax,%edx
f0101c6c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101c71:	77 20                	ja     f0101c93 <mem_init+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101c73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c77:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f0101c7e:	f0 
f0101c7f:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101c86:	00 
f0101c87:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101c8e:	e8 f2 e3 ff ff       	call   f0100085 <_panic>
f0101c93:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101c99:	83 ca 05             	or     $0x5,%edx
f0101c9c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	
	size_t sizepages = ROUNDUP(npages * sizeof (struct Page), PGSIZE);
f0101ca2:	a1 60 89 11 f0       	mov    0xf0118960,%eax
f0101ca7:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
	pages = boot_alloc(sizepages);
f0101cae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0101cb3:	e8 9c f2 ff ff       	call   f0100f54 <boot_alloc>
f0101cb8:	a3 68 89 11 f0       	mov    %eax,0xf0118968
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101cbd:	e8 25 f3 ff ff       	call   f0100fe7 <page_init>

	check_page_free_list(1);
f0101cc2:	b8 01 00 00 00       	mov    $0x1,%eax
f0101cc7:	e8 55 f4 ff ff       	call   f0101121 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0101ccc:	83 3d 68 89 11 f0 00 	cmpl   $0x0,0xf0118968
f0101cd3:	75 1c                	jne    f0101cf1 <mem_init+0xc1>
		panic("'pages' is a null pointer!");
f0101cd5:	c7 44 24 08 da 51 10 	movl   $0xf01051da,0x8(%esp)
f0101cdc:	f0 
f0101cdd:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f0101ce4:	00 
f0101ce5:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101cec:	e8 94 e3 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101cf1:	a1 50 85 11 f0       	mov    0xf0118550,%eax
f0101cf6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101cfb:	85 c0                	test   %eax,%eax
f0101cfd:	74 09                	je     f0101d08 <mem_init+0xd8>
		++nfree;
f0101cff:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101d02:	8b 00                	mov    (%eax),%eax
f0101d04:	85 c0                	test   %eax,%eax
f0101d06:	75 f7                	jne    f0101cff <mem_init+0xcf>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101d08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d0f:	e8 82 f7 ff ff       	call   f0101496 <page_alloc>
f0101d14:	89 c6                	mov    %eax,%esi
f0101d16:	85 c0                	test   %eax,%eax
f0101d18:	75 24                	jne    f0101d3e <mem_init+0x10e>
f0101d1a:	c7 44 24 0c 43 51 10 	movl   $0xf0105143,0xc(%esp)
f0101d21:	f0 
f0101d22:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101d29:	f0 
f0101d2a:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0101d31:	00 
f0101d32:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101d39:	e8 47 e3 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101d3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d45:	e8 4c f7 ff ff       	call   f0101496 <page_alloc>
f0101d4a:	89 c7                	mov    %eax,%edi
f0101d4c:	85 c0                	test   %eax,%eax
f0101d4e:	75 24                	jne    f0101d74 <mem_init+0x144>
f0101d50:	c7 44 24 0c 59 51 10 	movl   $0xf0105159,0xc(%esp)
f0101d57:	f0 
f0101d58:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101d5f:	f0 
f0101d60:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f0101d67:	00 
f0101d68:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101d6f:	e8 11 e3 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d7b:	e8 16 f7 ff ff       	call   f0101496 <page_alloc>
f0101d80:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d83:	85 c0                	test   %eax,%eax
f0101d85:	75 24                	jne    f0101dab <mem_init+0x17b>
f0101d87:	c7 44 24 0c 6f 51 10 	movl   $0xf010516f,0xc(%esp)
f0101d8e:	f0 
f0101d8f:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101d96:	f0 
f0101d97:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f0101d9e:	00 
f0101d9f:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101da6:	e8 da e2 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101dab:	39 fe                	cmp    %edi,%esi
f0101dad:	75 24                	jne    f0101dd3 <mem_init+0x1a3>
f0101daf:	c7 44 24 0c f5 51 10 	movl   $0xf01051f5,0xc(%esp)
f0101db6:	f0 
f0101db7:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101dbe:	f0 
f0101dbf:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0101dc6:	00 
f0101dc7:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101dce:	e8 b2 e2 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101dd3:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101dd6:	74 05                	je     f0101ddd <mem_init+0x1ad>
f0101dd8:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101ddb:	75 24                	jne    f0101e01 <mem_init+0x1d1>
f0101ddd:	c7 44 24 0c 5c 4c 10 	movl   $0xf0104c5c,0xc(%esp)
f0101de4:	f0 
f0101de5:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101dec:	f0 
f0101ded:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0101df4:	00 
f0101df5:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101dfc:	e8 84 e2 ff ff       	call   f0100085 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e01:	8b 15 68 89 11 f0    	mov    0xf0118968,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101e07:	a1 60 89 11 f0       	mov    0xf0118960,%eax
f0101e0c:	c1 e0 0c             	shl    $0xc,%eax
f0101e0f:	89 f1                	mov    %esi,%ecx
f0101e11:	29 d1                	sub    %edx,%ecx
f0101e13:	c1 f9 03             	sar    $0x3,%ecx
f0101e16:	c1 e1 0c             	shl    $0xc,%ecx
f0101e19:	39 c1                	cmp    %eax,%ecx
f0101e1b:	72 24                	jb     f0101e41 <mem_init+0x211>
f0101e1d:	c7 44 24 0c 07 52 10 	movl   $0xf0105207,0xc(%esp)
f0101e24:	f0 
f0101e25:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101e2c:	f0 
f0101e2d:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0101e34:	00 
f0101e35:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101e3c:	e8 44 e2 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101e41:	89 f9                	mov    %edi,%ecx
f0101e43:	29 d1                	sub    %edx,%ecx
f0101e45:	c1 f9 03             	sar    $0x3,%ecx
f0101e48:	c1 e1 0c             	shl    $0xc,%ecx
f0101e4b:	39 c8                	cmp    %ecx,%eax
f0101e4d:	77 24                	ja     f0101e73 <mem_init+0x243>
f0101e4f:	c7 44 24 0c 24 52 10 	movl   $0xf0105224,0xc(%esp)
f0101e56:	f0 
f0101e57:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101e5e:	f0 
f0101e5f:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f0101e66:	00 
f0101e67:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101e6e:	e8 12 e2 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101e73:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e76:	29 d1                	sub    %edx,%ecx
f0101e78:	89 ca                	mov    %ecx,%edx
f0101e7a:	c1 fa 03             	sar    $0x3,%edx
f0101e7d:	c1 e2 0c             	shl    $0xc,%edx
f0101e80:	39 d0                	cmp    %edx,%eax
f0101e82:	77 24                	ja     f0101ea8 <mem_init+0x278>
f0101e84:	c7 44 24 0c 41 52 10 	movl   $0xf0105241,0xc(%esp)
f0101e8b:	f0 
f0101e8c:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101e93:	f0 
f0101e94:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0101e9b:	00 
f0101e9c:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101ea3:	e8 dd e1 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101ea8:	a1 50 85 11 f0       	mov    0xf0118550,%eax
f0101ead:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101eb0:	c7 05 50 85 11 f0 00 	movl   $0x0,0xf0118550
f0101eb7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101eba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ec1:	e8 d0 f5 ff ff       	call   f0101496 <page_alloc>
f0101ec6:	85 c0                	test   %eax,%eax
f0101ec8:	74 24                	je     f0101eee <mem_init+0x2be>
f0101eca:	c7 44 24 0c 5e 52 10 	movl   $0xf010525e,0xc(%esp)
f0101ed1:	f0 
f0101ed2:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101ed9:	f0 
f0101eda:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f0101ee1:	00 
f0101ee2:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101ee9:	e8 97 e1 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101eee:	89 34 24             	mov    %esi,(%esp)
f0101ef1:	e8 a3 ec ff ff       	call   f0100b99 <page_free>
	page_free(pp1);
f0101ef6:	89 3c 24             	mov    %edi,(%esp)
f0101ef9:	e8 9b ec ff ff       	call   f0100b99 <page_free>
	page_free(pp2);
f0101efe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101f01:	89 14 24             	mov    %edx,(%esp)
f0101f04:	e8 90 ec ff ff       	call   f0100b99 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f10:	e8 81 f5 ff ff       	call   f0101496 <page_alloc>
f0101f15:	89 c6                	mov    %eax,%esi
f0101f17:	85 c0                	test   %eax,%eax
f0101f19:	75 24                	jne    f0101f3f <mem_init+0x30f>
f0101f1b:	c7 44 24 0c 43 51 10 	movl   $0xf0105143,0xc(%esp)
f0101f22:	f0 
f0101f23:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101f2a:	f0 
f0101f2b:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0101f32:	00 
f0101f33:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101f3a:	e8 46 e1 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101f3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f46:	e8 4b f5 ff ff       	call   f0101496 <page_alloc>
f0101f4b:	89 c7                	mov    %eax,%edi
f0101f4d:	85 c0                	test   %eax,%eax
f0101f4f:	75 24                	jne    f0101f75 <mem_init+0x345>
f0101f51:	c7 44 24 0c 59 51 10 	movl   $0xf0105159,0xc(%esp)
f0101f58:	f0 
f0101f59:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101f60:	f0 
f0101f61:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101f68:	00 
f0101f69:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101f70:	e8 10 e1 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101f75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f7c:	e8 15 f5 ff ff       	call   f0101496 <page_alloc>
f0101f81:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f84:	85 c0                	test   %eax,%eax
f0101f86:	75 24                	jne    f0101fac <mem_init+0x37c>
f0101f88:	c7 44 24 0c 6f 51 10 	movl   $0xf010516f,0xc(%esp)
f0101f8f:	f0 
f0101f90:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101f97:	f0 
f0101f98:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f0101f9f:	00 
f0101fa0:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101fa7:	e8 d9 e0 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101fac:	39 fe                	cmp    %edi,%esi
f0101fae:	75 24                	jne    f0101fd4 <mem_init+0x3a4>
f0101fb0:	c7 44 24 0c f5 51 10 	movl   $0xf01051f5,0xc(%esp)
f0101fb7:	f0 
f0101fb8:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101fbf:	f0 
f0101fc0:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0101fc7:	00 
f0101fc8:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101fcf:	e8 b1 e0 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101fd4:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101fd7:	74 05                	je     f0101fde <mem_init+0x3ae>
f0101fd9:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101fdc:	75 24                	jne    f0102002 <mem_init+0x3d2>
f0101fde:	c7 44 24 0c 5c 4c 10 	movl   $0xf0104c5c,0xc(%esp)
f0101fe5:	f0 
f0101fe6:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0101fed:	f0 
f0101fee:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0101ff5:	00 
f0101ff6:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0101ffd:	e8 83 e0 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102002:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102009:	e8 88 f4 ff ff       	call   f0101496 <page_alloc>
f010200e:	85 c0                	test   %eax,%eax
f0102010:	74 24                	je     f0102036 <mem_init+0x406>
f0102012:	c7 44 24 0c 5e 52 10 	movl   $0xf010525e,0xc(%esp)
f0102019:	f0 
f010201a:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102021:	f0 
f0102022:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0102029:	00 
f010202a:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102031:	e8 4f e0 ff ff       	call   f0100085 <_panic>
f0102036:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0102039:	89 f0                	mov    %esi,%eax
f010203b:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f0102041:	c1 f8 03             	sar    $0x3,%eax
f0102044:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102047:	89 c2                	mov    %eax,%edx
f0102049:	c1 ea 0c             	shr    $0xc,%edx
f010204c:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0102052:	72 20                	jb     f0102074 <mem_init+0x444>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102054:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102058:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f010205f:	f0 
f0102060:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102067:	00 
f0102068:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f010206f:	e8 11 e0 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102074:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010207b:	00 
f010207c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102083:	00 
f0102084:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102089:	89 04 24             	mov    %eax,(%esp)
f010208c:	e8 05 1e 00 00       	call   f0103e96 <memset>
	page_free(pp0);
f0102091:	89 34 24             	mov    %esi,(%esp)
f0102094:	e8 00 eb ff ff       	call   f0100b99 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102099:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01020a0:	e8 f1 f3 ff ff       	call   f0101496 <page_alloc>
f01020a5:	85 c0                	test   %eax,%eax
f01020a7:	75 24                	jne    f01020cd <mem_init+0x49d>
f01020a9:	c7 44 24 0c 6d 52 10 	movl   $0xf010526d,0xc(%esp)
f01020b0:	f0 
f01020b1:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01020b8:	f0 
f01020b9:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f01020c0:	00 
f01020c1:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01020c8:	e8 b8 df ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f01020cd:	39 c6                	cmp    %eax,%esi
f01020cf:	74 24                	je     f01020f5 <mem_init+0x4c5>
f01020d1:	c7 44 24 0c 8b 52 10 	movl   $0xf010528b,0xc(%esp)
f01020d8:	f0 
f01020d9:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01020e0:	f0 
f01020e1:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f01020e8:	00 
f01020e9:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01020f0:	e8 90 df ff ff       	call   f0100085 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01020f5:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01020f8:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f01020fe:	c1 fa 03             	sar    $0x3,%edx
f0102101:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102104:	89 d0                	mov    %edx,%eax
f0102106:	c1 e8 0c             	shr    $0xc,%eax
f0102109:	3b 05 60 89 11 f0    	cmp    0xf0118960,%eax
f010210f:	72 20                	jb     f0102131 <mem_init+0x501>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102111:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102115:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f010211c:	f0 
f010211d:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102124:	00 
f0102125:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f010212c:	e8 54 df ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102131:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102138:	75 11                	jne    f010214b <mem_init+0x51b>
f010213a:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102140:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102146:	80 38 00             	cmpb   $0x0,(%eax)
f0102149:	74 24                	je     f010216f <mem_init+0x53f>
f010214b:	c7 44 24 0c 9b 52 10 	movl   $0xf010529b,0xc(%esp)
f0102152:	f0 
f0102153:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010215a:	f0 
f010215b:	c7 44 24 04 fb 02 00 	movl   $0x2fb,0x4(%esp)
f0102162:	00 
f0102163:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010216a:	e8 16 df ff ff       	call   f0100085 <_panic>
f010216f:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102172:	39 d0                	cmp    %edx,%eax
f0102174:	75 d0                	jne    f0102146 <mem_init+0x516>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102176:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102179:	89 0d 50 85 11 f0    	mov    %ecx,0xf0118550

	// free the pages we took
	page_free(pp0);
f010217f:	89 34 24             	mov    %esi,(%esp)
f0102182:	e8 12 ea ff ff       	call   f0100b99 <page_free>
	page_free(pp1);
f0102187:	89 3c 24             	mov    %edi,(%esp)
f010218a:	e8 0a ea ff ff       	call   f0100b99 <page_free>
	page_free(pp2);
f010218f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102192:	89 04 24             	mov    %eax,(%esp)
f0102195:	e8 ff e9 ff ff       	call   f0100b99 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010219a:	a1 50 85 11 f0       	mov    0xf0118550,%eax
f010219f:	85 c0                	test   %eax,%eax
f01021a1:	74 09                	je     f01021ac <mem_init+0x57c>
		--nfree;
f01021a3:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01021a6:	8b 00                	mov    (%eax),%eax
f01021a8:	85 c0                	test   %eax,%eax
f01021aa:	75 f7                	jne    f01021a3 <mem_init+0x573>
		--nfree;
	assert(nfree == 0);
f01021ac:	85 db                	test   %ebx,%ebx
f01021ae:	74 24                	je     f01021d4 <mem_init+0x5a4>
f01021b0:	c7 44 24 0c a5 52 10 	movl   $0xf01052a5,0xc(%esp)
f01021b7:	f0 
f01021b8:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01021bf:	f0 
f01021c0:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01021c7:	00 
f01021c8:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01021cf:	e8 b1 de ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01021d4:	c7 04 24 7c 4c 10 f0 	movl   $0xf0104c7c,(%esp)
f01021db:	e8 d7 0f 00 00       	call   f01031b7 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01021e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01021e7:	e8 aa f2 ff ff       	call   f0101496 <page_alloc>
f01021ec:	89 c6                	mov    %eax,%esi
f01021ee:	85 c0                	test   %eax,%eax
f01021f0:	75 24                	jne    f0102216 <mem_init+0x5e6>
f01021f2:	c7 44 24 0c 43 51 10 	movl   $0xf0105143,0xc(%esp)
f01021f9:	f0 
f01021fa:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102201:	f0 
f0102202:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0102209:	00 
f010220a:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102211:	e8 6f de ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010221d:	e8 74 f2 ff ff       	call   f0101496 <page_alloc>
f0102222:	89 c7                	mov    %eax,%edi
f0102224:	85 c0                	test   %eax,%eax
f0102226:	75 24                	jne    f010224c <mem_init+0x61c>
f0102228:	c7 44 24 0c 59 51 10 	movl   $0xf0105159,0xc(%esp)
f010222f:	f0 
f0102230:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102237:	f0 
f0102238:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f010223f:	00 
f0102240:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102247:	e8 39 de ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010224c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102253:	e8 3e f2 ff ff       	call   f0101496 <page_alloc>
f0102258:	89 c3                	mov    %eax,%ebx
f010225a:	85 c0                	test   %eax,%eax
f010225c:	75 24                	jne    f0102282 <mem_init+0x652>
f010225e:	c7 44 24 0c 6f 51 10 	movl   $0xf010516f,0xc(%esp)
f0102265:	f0 
f0102266:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010226d:	f0 
f010226e:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102275:	00 
f0102276:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010227d:	e8 03 de ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102282:	39 fe                	cmp    %edi,%esi
f0102284:	75 24                	jne    f01022aa <mem_init+0x67a>
f0102286:	c7 44 24 0c f5 51 10 	movl   $0xf01051f5,0xc(%esp)
f010228d:	f0 
f010228e:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102295:	f0 
f0102296:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f010229d:	00 
f010229e:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01022a5:	e8 db dd ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01022aa:	39 c7                	cmp    %eax,%edi
f01022ac:	74 04                	je     f01022b2 <mem_init+0x682>
f01022ae:	39 c6                	cmp    %eax,%esi
f01022b0:	75 24                	jne    f01022d6 <mem_init+0x6a6>
f01022b2:	c7 44 24 0c 5c 4c 10 	movl   $0xf0104c5c,0xc(%esp)
f01022b9:	f0 
f01022ba:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01022c1:	f0 
f01022c2:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f01022c9:	00 
f01022ca:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01022d1:	e8 af dd ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01022d6:	8b 15 50 85 11 f0    	mov    0xf0118550,%edx
f01022dc:	89 55 c8             	mov    %edx,-0x38(%ebp)
	page_free_list = 0;
f01022df:	c7 05 50 85 11 f0 00 	movl   $0x0,0xf0118550
f01022e6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01022e9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022f0:	e8 a1 f1 ff ff       	call   f0101496 <page_alloc>
f01022f5:	85 c0                	test   %eax,%eax
f01022f7:	74 24                	je     f010231d <mem_init+0x6ed>
f01022f9:	c7 44 24 0c 5e 52 10 	movl   $0xf010525e,0xc(%esp)
f0102300:	f0 
f0102301:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102308:	f0 
f0102309:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0102310:	00 
f0102311:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102318:	e8 68 dd ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010231d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102320:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102324:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010232b:	00 
f010232c:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102331:	89 04 24             	mov    %eax,(%esp)
f0102334:	e8 f2 f2 ff ff       	call   f010162b <page_lookup>
f0102339:	85 c0                	test   %eax,%eax
f010233b:	74 24                	je     f0102361 <mem_init+0x731>
f010233d:	c7 44 24 0c 9c 4c 10 	movl   $0xf0104c9c,0xc(%esp)
f0102344:	f0 
f0102345:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010234c:	f0 
f010234d:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0102354:	00 
f0102355:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010235c:	e8 24 dd ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102361:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102368:	00 
f0102369:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102370:	00 
f0102371:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102375:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010237a:	89 04 24             	mov    %eax,(%esp)
f010237d:	e8 66 f3 ff ff       	call   f01016e8 <page_insert>
f0102382:	85 c0                	test   %eax,%eax
f0102384:	78 24                	js     f01023aa <mem_init+0x77a>
f0102386:	c7 44 24 0c d4 4c 10 	movl   $0xf0104cd4,0xc(%esp)
f010238d:	f0 
f010238e:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102395:	f0 
f0102396:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f010239d:	00 
f010239e:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01023a5:	e8 db dc ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01023aa:	89 34 24             	mov    %esi,(%esp)
f01023ad:	e8 e7 e7 ff ff       	call   f0100b99 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01023b2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01023b9:	00 
f01023ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01023c1:	00 
f01023c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01023c6:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01023cb:	89 04 24             	mov    %eax,(%esp)
f01023ce:	e8 15 f3 ff ff       	call   f01016e8 <page_insert>
f01023d3:	85 c0                	test   %eax,%eax
f01023d5:	74 24                	je     f01023fb <mem_init+0x7cb>
f01023d7:	c7 44 24 0c 04 4d 10 	movl   $0xf0104d04,0xc(%esp)
f01023de:	f0 
f01023df:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01023e6:	f0 
f01023e7:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f01023ee:	00 
f01023ef:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01023f6:	e8 8a dc ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023fb:	a1 64 89 11 f0       	mov    0xf0118964,%eax
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102400:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102403:	8b 08                	mov    (%eax),%ecx
f0102405:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010240b:	89 f2                	mov    %esi,%edx
f010240d:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f0102413:	c1 fa 03             	sar    $0x3,%edx
f0102416:	c1 e2 0c             	shl    $0xc,%edx
f0102419:	39 d1                	cmp    %edx,%ecx
f010241b:	74 24                	je     f0102441 <mem_init+0x811>
f010241d:	c7 44 24 0c 08 4c 10 	movl   $0xf0104c08,0xc(%esp)
f0102424:	f0 
f0102425:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010242c:	f0 
f010242d:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102434:	00 
f0102435:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010243c:	e8 44 dc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102441:	ba 00 00 00 00       	mov    $0x0,%edx
f0102446:	e8 e8 e6 ff ff       	call   f0100b33 <check_va2pa>
f010244b:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010244e:	89 fa                	mov    %edi,%edx
f0102450:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f0102456:	c1 fa 03             	sar    $0x3,%edx
f0102459:	c1 e2 0c             	shl    $0xc,%edx
f010245c:	39 d0                	cmp    %edx,%eax
f010245e:	74 24                	je     f0102484 <mem_init+0x854>
f0102460:	c7 44 24 0c 34 4d 10 	movl   $0xf0104d34,0xc(%esp)
f0102467:	f0 
f0102468:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010246f:	f0 
f0102470:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0102477:	00 
f0102478:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010247f:	e8 01 dc ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0102484:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102489:	74 24                	je     f01024af <mem_init+0x87f>
f010248b:	c7 44 24 0c 85 51 10 	movl   $0xf0105185,0xc(%esp)
f0102492:	f0 
f0102493:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010249a:	f0 
f010249b:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f01024a2:	00 
f01024a3:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01024aa:	e8 d6 db ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f01024af:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024b4:	74 24                	je     f01024da <mem_init+0x8aa>
f01024b6:	c7 44 24 0c c9 51 10 	movl   $0xf01051c9,0xc(%esp)
f01024bd:	f0 
f01024be:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01024c5:	f0 
f01024c6:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01024cd:	00 
f01024ce:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01024d5:	e8 ab db ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01024da:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01024e1:	00 
f01024e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024e9:	00 
f01024ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024ee:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01024f3:	89 04 24             	mov    %eax,(%esp)
f01024f6:	e8 ed f1 ff ff       	call   f01016e8 <page_insert>
f01024fb:	85 c0                	test   %eax,%eax
f01024fd:	74 24                	je     f0102523 <mem_init+0x8f3>
f01024ff:	c7 44 24 0c 64 4d 10 	movl   $0xf0104d64,0xc(%esp)
f0102506:	f0 
f0102507:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010250e:	f0 
f010250f:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0102516:	00 
f0102517:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010251e:	e8 62 db ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102523:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102528:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010252d:	e8 01 e6 ff ff       	call   f0100b33 <check_va2pa>
f0102532:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0102535:	89 da                	mov    %ebx,%edx
f0102537:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f010253d:	c1 fa 03             	sar    $0x3,%edx
f0102540:	c1 e2 0c             	shl    $0xc,%edx
f0102543:	39 d0                	cmp    %edx,%eax
f0102545:	74 24                	je     f010256b <mem_init+0x93b>
f0102547:	c7 44 24 0c a0 4d 10 	movl   $0xf0104da0,0xc(%esp)
f010254e:	f0 
f010254f:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102556:	f0 
f0102557:	c7 44 24 04 80 03 00 	movl   $0x380,0x4(%esp)
f010255e:	00 
f010255f:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102566:	e8 1a db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010256b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102570:	74 24                	je     f0102596 <mem_init+0x966>
f0102572:	c7 44 24 0c 96 51 10 	movl   $0xf0105196,0xc(%esp)
f0102579:	f0 
f010257a:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102581:	f0 
f0102582:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0102589:	00 
f010258a:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102591:	e8 ef da ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102596:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010259d:	e8 f4 ee ff ff       	call   f0101496 <page_alloc>
f01025a2:	85 c0                	test   %eax,%eax
f01025a4:	74 24                	je     f01025ca <mem_init+0x99a>
f01025a6:	c7 44 24 0c 5e 52 10 	movl   $0xf010525e,0xc(%esp)
f01025ad:	f0 
f01025ae:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01025b5:	f0 
f01025b6:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f01025bd:	00 
f01025be:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01025c5:	e8 bb da ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01025ca:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01025d1:	00 
f01025d2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025d9:	00 
f01025da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01025de:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01025e3:	89 04 24             	mov    %eax,(%esp)
f01025e6:	e8 fd f0 ff ff       	call   f01016e8 <page_insert>
f01025eb:	85 c0                	test   %eax,%eax
f01025ed:	74 24                	je     f0102613 <mem_init+0x9e3>
f01025ef:	c7 44 24 0c 64 4d 10 	movl   $0xf0104d64,0xc(%esp)
f01025f6:	f0 
f01025f7:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01025fe:	f0 
f01025ff:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0102606:	00 
f0102607:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010260e:	e8 72 da ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102613:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102618:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010261d:	e8 11 e5 ff ff       	call   f0100b33 <check_va2pa>
f0102622:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102625:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f010262b:	c1 fa 03             	sar    $0x3,%edx
f010262e:	c1 e2 0c             	shl    $0xc,%edx
f0102631:	39 d0                	cmp    %edx,%eax
f0102633:	74 24                	je     f0102659 <mem_init+0xa29>
f0102635:	c7 44 24 0c a0 4d 10 	movl   $0xf0104da0,0xc(%esp)
f010263c:	f0 
f010263d:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102644:	f0 
f0102645:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f010264c:	00 
f010264d:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102654:	e8 2c da ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0102659:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010265e:	74 24                	je     f0102684 <mem_init+0xa54>
f0102660:	c7 44 24 0c 96 51 10 	movl   $0xf0105196,0xc(%esp)
f0102667:	f0 
f0102668:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010266f:	f0 
f0102670:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102677:	00 
f0102678:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010267f:	e8 01 da ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102684:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010268b:	e8 06 ee ff ff       	call   f0101496 <page_alloc>
f0102690:	85 c0                	test   %eax,%eax
f0102692:	74 24                	je     f01026b8 <mem_init+0xa88>
f0102694:	c7 44 24 0c 5e 52 10 	movl   $0xf010525e,0xc(%esp)
f010269b:	f0 
f010269c:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01026a3:	f0 
f01026a4:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f01026ab:	00 
f01026ac:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01026b3:	e8 cd d9 ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01026b8:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01026bd:	8b 00                	mov    (%eax),%eax
f01026bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026c4:	89 c2                	mov    %eax,%edx
f01026c6:	c1 ea 0c             	shr    $0xc,%edx
f01026c9:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f01026cf:	72 20                	jb     f01026f1 <mem_init+0xac1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026d5:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f01026dc:	f0 
f01026dd:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01026e4:	00 
f01026e5:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01026ec:	e8 94 d9 ff ff       	call   f0100085 <_panic>
f01026f1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01026f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102700:	00 
f0102701:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102708:	00 
f0102709:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010270e:	89 04 24             	mov    %eax,(%esp)
f0102711:	e8 fe ed ff ff       	call   f0101514 <pgdir_walk>
f0102716:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102719:	83 c2 04             	add    $0x4,%edx
f010271c:	39 d0                	cmp    %edx,%eax
f010271e:	74 24                	je     f0102744 <mem_init+0xb14>
f0102720:	c7 44 24 0c d0 4d 10 	movl   $0xf0104dd0,0xc(%esp)
f0102727:	f0 
f0102728:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010272f:	f0 
f0102730:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102737:	00 
f0102738:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010273f:	e8 41 d9 ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102744:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f010274b:	00 
f010274c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102753:	00 
f0102754:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102758:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010275d:	89 04 24             	mov    %eax,(%esp)
f0102760:	e8 83 ef ff ff       	call   f01016e8 <page_insert>
f0102765:	85 c0                	test   %eax,%eax
f0102767:	74 24                	je     f010278d <mem_init+0xb5d>
f0102769:	c7 44 24 0c 10 4e 10 	movl   $0xf0104e10,0xc(%esp)
f0102770:	f0 
f0102771:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102778:	f0 
f0102779:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f0102780:	00 
f0102781:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102788:	e8 f8 d8 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010278d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102792:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102797:	e8 97 e3 ff ff       	call   f0100b33 <check_va2pa>
f010279c:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010279f:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f01027a5:	c1 fa 03             	sar    $0x3,%edx
f01027a8:	c1 e2 0c             	shl    $0xc,%edx
f01027ab:	39 d0                	cmp    %edx,%eax
f01027ad:	74 24                	je     f01027d3 <mem_init+0xba3>
f01027af:	c7 44 24 0c a0 4d 10 	movl   $0xf0104da0,0xc(%esp)
f01027b6:	f0 
f01027b7:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01027be:	f0 
f01027bf:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f01027c6:	00 
f01027c7:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01027ce:	e8 b2 d8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01027d3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01027d8:	74 24                	je     f01027fe <mem_init+0xbce>
f01027da:	c7 44 24 0c 96 51 10 	movl   $0xf0105196,0xc(%esp)
f01027e1:	f0 
f01027e2:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01027e9:	f0 
f01027ea:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f01027f1:	00 
f01027f2:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01027f9:	e8 87 d8 ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01027fe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102805:	00 
f0102806:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010280d:	00 
f010280e:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102813:	89 04 24             	mov    %eax,(%esp)
f0102816:	e8 f9 ec ff ff       	call   f0101514 <pgdir_walk>
f010281b:	f6 00 04             	testb  $0x4,(%eax)
f010281e:	75 24                	jne    f0102844 <mem_init+0xc14>
f0102820:	c7 44 24 0c 50 4e 10 	movl   $0xf0104e50,0xc(%esp)
f0102827:	f0 
f0102828:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010282f:	f0 
f0102830:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102837:	00 
f0102838:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010283f:	e8 41 d8 ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102844:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102849:	f6 00 04             	testb  $0x4,(%eax)
f010284c:	75 24                	jne    f0102872 <mem_init+0xc42>
f010284e:	c7 44 24 0c b0 52 10 	movl   $0xf01052b0,0xc(%esp)
f0102855:	f0 
f0102856:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f010285d:	f0 
f010285e:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0102865:	00 
f0102866:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f010286d:	e8 13 d8 ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0102872:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102879:	00 
f010287a:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0102881:	00 
f0102882:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102886:	89 04 24             	mov    %eax,(%esp)
f0102889:	e8 5a ee ff ff       	call   f01016e8 <page_insert>
f010288e:	85 c0                	test   %eax,%eax
f0102890:	78 24                	js     f01028b6 <mem_init+0xc86>
f0102892:	c7 44 24 0c 84 4e 10 	movl   $0xf0104e84,0xc(%esp)
f0102899:	f0 
f010289a:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01028a1:	f0 
f01028a2:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f01028a9:	00 
f01028aa:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01028b1:	e8 cf d7 ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01028b6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01028bd:	00 
f01028be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028c5:	00 
f01028c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01028ca:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f01028cf:	89 04 24             	mov    %eax,(%esp)
f01028d2:	e8 11 ee ff ff       	call   f01016e8 <page_insert>
f01028d7:	85 c0                	test   %eax,%eax
f01028d9:	74 24                	je     f01028ff <mem_init+0xccf>
f01028db:	c7 44 24 0c bc 4e 10 	movl   $0xf0104ebc,0xc(%esp)
f01028e2:	f0 
f01028e3:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01028ea:	f0 
f01028eb:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01028f2:	00 
f01028f3:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01028fa:	e8 86 d7 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028ff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102906:	00 
f0102907:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010290e:	00 
f010290f:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102914:	89 04 24             	mov    %eax,(%esp)
f0102917:	e8 f8 eb ff ff       	call   f0101514 <pgdir_walk>
f010291c:	f6 00 04             	testb  $0x4,(%eax)
f010291f:	74 24                	je     f0102945 <mem_init+0xd15>
f0102921:	c7 44 24 0c f8 4e 10 	movl   $0xf0104ef8,0xc(%esp)
f0102928:	f0 
f0102929:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102930:	f0 
f0102931:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102938:	00 
f0102939:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102940:	e8 40 d7 ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102945:	ba 00 00 00 00       	mov    $0x0,%edx
f010294a:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f010294f:	e8 df e1 ff ff       	call   f0100b33 <check_va2pa>
f0102954:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102957:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f010295d:	c1 fa 03             	sar    $0x3,%edx
f0102960:	c1 e2 0c             	shl    $0xc,%edx
f0102963:	39 d0                	cmp    %edx,%eax
f0102965:	74 24                	je     f010298b <mem_init+0xd5b>
f0102967:	c7 44 24 0c 30 4f 10 	movl   $0xf0104f30,0xc(%esp)
f010296e:	f0 
f010296f:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102976:	f0 
f0102977:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f010297e:	00 
f010297f:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102986:	e8 fa d6 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010298b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102990:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102995:	e8 99 e1 ff ff       	call   f0100b33 <check_va2pa>
f010299a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010299d:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f01029a3:	c1 fa 03             	sar    $0x3,%edx
f01029a6:	c1 e2 0c             	shl    $0xc,%edx
f01029a9:	39 d0                	cmp    %edx,%eax
f01029ab:	74 24                	je     f01029d1 <mem_init+0xda1>
f01029ad:	c7 44 24 0c 5c 4f 10 	movl   $0xf0104f5c,0xc(%esp)
f01029b4:	f0 
f01029b5:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01029bc:	f0 
f01029bd:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01029c4:	00 
f01029c5:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01029cc:	e8 b4 d6 ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01029d1:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01029d6:	74 24                	je     f01029fc <mem_init+0xdcc>
f01029d8:	c7 44 24 0c c6 52 10 	movl   $0xf01052c6,0xc(%esp)
f01029df:	f0 
f01029e0:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f01029e7:	f0 
f01029e8:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f01029ef:	00 
f01029f0:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f01029f7:	e8 89 d6 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f01029fc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a01:	74 24                	je     f0102a27 <mem_init+0xdf7>
f0102a03:	c7 44 24 0c b8 51 10 	movl   $0xf01051b8,0xc(%esp)
f0102a0a:	f0 
f0102a0b:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102a12:	f0 
f0102a13:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102a1a:	00 
f0102a1b:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102a22:	e8 5e d6 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102a27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a2e:	e8 63 ea ff ff       	call   f0101496 <page_alloc>
f0102a33:	85 c0                	test   %eax,%eax
f0102a35:	74 04                	je     f0102a3b <mem_init+0xe0b>
f0102a37:	39 c3                	cmp    %eax,%ebx
f0102a39:	74 24                	je     f0102a5f <mem_init+0xe2f>
f0102a3b:	c7 44 24 0c 8c 4f 10 	movl   $0xf0104f8c,0xc(%esp)
f0102a42:	f0 
f0102a43:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102a4a:	f0 
f0102a4b:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102a52:	00 
f0102a53:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102a5a:	e8 26 d6 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102a5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102a66:	00 
f0102a67:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102a6c:	89 04 24             	mov    %eax,(%esp)
f0102a6f:	e8 24 ec ff ff       	call   f0101698 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102a74:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a79:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102a7e:	e8 b0 e0 ff ff       	call   f0100b33 <check_va2pa>
f0102a83:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a86:	74 24                	je     f0102aac <mem_init+0xe7c>
f0102a88:	c7 44 24 0c b0 4f 10 	movl   $0xf0104fb0,0xc(%esp)
f0102a8f:	f0 
f0102a90:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102a97:	f0 
f0102a98:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0102a9f:	00 
f0102aa0:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102aa7:	e8 d9 d5 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102aac:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ab1:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102ab6:	e8 78 e0 ff ff       	call   f0100b33 <check_va2pa>
f0102abb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102abe:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f0102ac4:	c1 fa 03             	sar    $0x3,%edx
f0102ac7:	c1 e2 0c             	shl    $0xc,%edx
f0102aca:	39 d0                	cmp    %edx,%eax
f0102acc:	74 24                	je     f0102af2 <mem_init+0xec2>
f0102ace:	c7 44 24 0c 5c 4f 10 	movl   $0xf0104f5c,0xc(%esp)
f0102ad5:	f0 
f0102ad6:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102ae5:	00 
f0102ae6:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102aed:	e8 93 d5 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0102af2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102af7:	74 24                	je     f0102b1d <mem_init+0xeed>
f0102af9:	c7 44 24 0c 85 51 10 	movl   $0xf0105185,0xc(%esp)
f0102b00:	f0 
f0102b01:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102b08:	f0 
f0102b09:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102b10:	00 
f0102b11:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102b18:	e8 68 d5 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102b1d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102b22:	74 24                	je     f0102b48 <mem_init+0xf18>
f0102b24:	c7 44 24 0c b8 51 10 	movl   $0xf01051b8,0xc(%esp)
f0102b2b:	f0 
f0102b2c:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102b33:	f0 
f0102b34:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102b3b:	00 
f0102b3c:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102b43:	e8 3d d5 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b48:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b4f:	00 
f0102b50:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102b55:	89 04 24             	mov    %eax,(%esp)
f0102b58:	e8 3b eb ff ff       	call   f0101698 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102b5d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b62:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102b67:	e8 c7 df ff ff       	call   f0100b33 <check_va2pa>
f0102b6c:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102b6f:	74 24                	je     f0102b95 <mem_init+0xf65>
f0102b71:	c7 44 24 0c b0 4f 10 	movl   $0xf0104fb0,0xc(%esp)
f0102b78:	f0 
f0102b79:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102b80:	f0 
f0102b81:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0102b88:	00 
f0102b89:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102b90:	e8 f0 d4 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102b95:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102b9a:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102b9f:	e8 8f df ff ff       	call   f0100b33 <check_va2pa>
f0102ba4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ba7:	74 24                	je     f0102bcd <mem_init+0xf9d>
f0102ba9:	c7 44 24 0c d4 4f 10 	movl   $0xf0104fd4,0xc(%esp)
f0102bb0:	f0 
f0102bb1:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102bb8:	f0 
f0102bb9:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0102bc0:	00 
f0102bc1:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102bc8:	e8 b8 d4 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0102bcd:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102bd2:	74 24                	je     f0102bf8 <mem_init+0xfc8>
f0102bd4:	c7 44 24 0c a7 51 10 	movl   $0xf01051a7,0xc(%esp)
f0102bdb:	f0 
f0102bdc:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102be3:	f0 
f0102be4:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f0102beb:	00 
f0102bec:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102bf3:	e8 8d d4 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102bf8:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bfd:	74 24                	je     f0102c23 <mem_init+0xff3>
f0102bff:	c7 44 24 0c b8 51 10 	movl   $0xf01051b8,0xc(%esp)
f0102c06:	f0 
f0102c07:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102c0e:	f0 
f0102c0f:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102c16:	00 
f0102c17:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102c1e:	e8 62 d4 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102c23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c2a:	e8 67 e8 ff ff       	call   f0101496 <page_alloc>
f0102c2f:	85 c0                	test   %eax,%eax
f0102c31:	74 04                	je     f0102c37 <mem_init+0x1007>
f0102c33:	39 c7                	cmp    %eax,%edi
f0102c35:	74 24                	je     f0102c5b <mem_init+0x102b>
f0102c37:	c7 44 24 0c fc 4f 10 	movl   $0xf0104ffc,0xc(%esp)
f0102c3e:	f0 
f0102c3f:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102c46:	f0 
f0102c47:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0102c4e:	00 
f0102c4f:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102c56:	e8 2a d4 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102c5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c62:	e8 2f e8 ff ff       	call   f0101496 <page_alloc>
f0102c67:	85 c0                	test   %eax,%eax
f0102c69:	74 24                	je     f0102c8f <mem_init+0x105f>
f0102c6b:	c7 44 24 0c 5e 52 10 	movl   $0xf010525e,0xc(%esp)
f0102c72:	f0 
f0102c73:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102c7a:	f0 
f0102c7b:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0102c82:	00 
f0102c83:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102c8a:	e8 f6 d3 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c8f:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102c94:	8b 08                	mov    (%eax),%ecx
f0102c96:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102c9c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102c9f:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f0102ca5:	c1 fa 03             	sar    $0x3,%edx
f0102ca8:	c1 e2 0c             	shl    $0xc,%edx
f0102cab:	39 d1                	cmp    %edx,%ecx
f0102cad:	74 24                	je     f0102cd3 <mem_init+0x10a3>
f0102caf:	c7 44 24 0c 08 4c 10 	movl   $0xf0104c08,0xc(%esp)
f0102cb6:	f0 
f0102cb7:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102cbe:	f0 
f0102cbf:	c7 44 24 04 c0 03 00 	movl   $0x3c0,0x4(%esp)
f0102cc6:	00 
f0102cc7:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102cce:	e8 b2 d3 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0102cd3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102cd9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102cde:	74 24                	je     f0102d04 <mem_init+0x10d4>
f0102ce0:	c7 44 24 0c c9 51 10 	movl   $0xf01051c9,0xc(%esp)
f0102ce7:	f0 
f0102ce8:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102cef:	f0 
f0102cf0:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102cf7:	00 
f0102cf8:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102cff:	e8 81 d3 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102d04:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102d0a:	89 34 24             	mov    %esi,(%esp)
f0102d0d:	e8 87 de ff ff       	call   f0100b99 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102d12:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102d19:	00 
f0102d1a:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102d21:	00 
f0102d22:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102d27:	89 04 24             	mov    %eax,(%esp)
f0102d2a:	e8 e5 e7 ff ff       	call   f0101514 <pgdir_walk>
f0102d2f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102d32:	8b 0d 64 89 11 f0    	mov    0xf0118964,%ecx
f0102d38:	83 c1 04             	add    $0x4,%ecx
f0102d3b:	8b 11                	mov    (%ecx),%edx
f0102d3d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102d43:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d46:	c1 ea 0c             	shr    $0xc,%edx
f0102d49:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0102d4f:	72 23                	jb     f0102d74 <mem_init+0x1144>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d51:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102d54:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102d58:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0102d5f:	f0 
f0102d60:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0102d67:	00 
f0102d68:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102d6f:	e8 11 d3 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102d74:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102d77:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102d7d:	39 d0                	cmp    %edx,%eax
f0102d7f:	74 24                	je     f0102da5 <mem_init+0x1175>
f0102d81:	c7 44 24 0c d7 52 10 	movl   $0xf01052d7,0xc(%esp)
f0102d88:	f0 
f0102d89:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102d90:	f0 
f0102d91:	c7 44 24 04 ca 03 00 	movl   $0x3ca,0x4(%esp)
f0102d98:	00 
f0102d99:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102da0:	e8 e0 d2 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102da5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f0102dab:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102db1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102db4:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f0102dba:	c1 f8 03             	sar    $0x3,%eax
f0102dbd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102dc0:	89 c2                	mov    %eax,%edx
f0102dc2:	c1 ea 0c             	shr    $0xc,%edx
f0102dc5:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0102dcb:	72 20                	jb     f0102ded <mem_init+0x11bd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102dcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dd1:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0102dd8:	f0 
f0102dd9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102de0:	00 
f0102de1:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f0102de8:	e8 98 d2 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102ded:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102df4:	00 
f0102df5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102dfc:	00 
f0102dfd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102e02:	89 04 24             	mov    %eax,(%esp)
f0102e05:	e8 8c 10 00 00       	call   f0103e96 <memset>
	page_free(pp0);
f0102e0a:	89 34 24             	mov    %esi,(%esp)
f0102e0d:	e8 87 dd ff ff       	call   f0100b99 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102e12:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102e19:	00 
f0102e1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102e21:	00 
f0102e22:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102e27:	89 04 24             	mov    %eax,(%esp)
f0102e2a:	e8 e5 e6 ff ff       	call   f0101514 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e2f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102e32:	2b 15 68 89 11 f0    	sub    0xf0118968,%edx
f0102e38:	c1 fa 03             	sar    $0x3,%edx
f0102e3b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e3e:	89 d0                	mov    %edx,%eax
f0102e40:	c1 e8 0c             	shr    $0xc,%eax
f0102e43:	3b 05 60 89 11 f0    	cmp    0xf0118960,%eax
f0102e49:	72 20                	jb     f0102e6b <mem_init+0x123b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e4b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102e4f:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0102e56:	f0 
f0102e57:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102e5e:	00 
f0102e5f:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f0102e66:	e8 1a d2 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0102e6b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102e71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102e74:	f6 00 01             	testb  $0x1,(%eax)
f0102e77:	75 11                	jne    f0102e8a <mem_init+0x125a>
f0102e79:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102e7f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102e85:	f6 00 01             	testb  $0x1,(%eax)
f0102e88:	74 24                	je     f0102eae <mem_init+0x127e>
f0102e8a:	c7 44 24 0c ef 52 10 	movl   $0xf01052ef,0xc(%esp)
f0102e91:	f0 
f0102e92:	c7 44 24 08 3a 50 10 	movl   $0xf010503a,0x8(%esp)
f0102e99:	f0 
f0102e9a:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0102ea1:	00 
f0102ea2:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102ea9:	e8 d7 d1 ff ff       	call   f0100085 <_panic>
f0102eae:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102eb1:	39 d0                	cmp    %edx,%eax
f0102eb3:	75 d0                	jne    f0102e85 <mem_init+0x1255>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102eb5:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102eba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102ec0:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102ec6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102ec9:	a3 50 85 11 f0       	mov    %eax,0xf0118550

	// free the pages we took
	page_free(pp0);
f0102ece:	89 34 24             	mov    %esi,(%esp)
f0102ed1:	e8 c3 dc ff ff       	call   f0100b99 <page_free>
	page_free(pp1);
f0102ed6:	89 3c 24             	mov    %edi,(%esp)
f0102ed9:	e8 bb dc ff ff       	call   f0100b99 <page_free>
	page_free(pp2);
f0102ede:	89 1c 24             	mov    %ebx,(%esp)
f0102ee1:	e8 b3 dc ff ff       	call   f0100b99 <page_free>

	cprintf("check_page() succeeded!\n");
f0102ee6:	c7 04 24 06 53 10 f0 	movl   $0xf0105306,(%esp)
f0102eed:	e8 c5 02 00 00       	call   f01031b7 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102ef2:	a1 68 89 11 f0       	mov    0xf0118968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ef7:	89 c2                	mov    %eax,%edx
f0102ef9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102efe:	77 20                	ja     f0102f20 <mem_init+0x12f0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f00:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f04:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f0102f0b:	f0 
f0102f0c:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
f0102f13:	00 
f0102f14:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102f1b:	e8 65 d1 ff ff       	call   f0100085 <_panic>
                  UPAGES, 
                  ROUNDUP((sizeof(struct Page) * npages), PGSIZE),
f0102f20:	a1 60 89 11 f0       	mov    0xf0118960,%eax
f0102f25:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102f2c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102f32:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102f39:	00 
f0102f3a:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102f40:	89 04 24             	mov    %eax,(%esp)
f0102f43:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102f48:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102f4d:	e8 5f e8 ff ff       	call   f01017b1 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f52:	b8 00 e0 10 f0       	mov    $0xf010e000,%eax
f0102f57:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f5c:	77 20                	ja     f0102f7e <mem_init+0x134e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f62:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f0102f69:	f0 
f0102f6a:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
f0102f71:	00 
f0102f72:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0102f79:	e8 07 d1 ff ff       	call   f0100085 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102f7e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102f85:	00 
f0102f86:	05 00 00 00 10       	add    $0x10000000,%eax
f0102f8b:	89 04 24             	mov    %eax,(%esp)
f0102f8e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102f93:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f0102f98:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102f9d:	e8 0f e8 ff ff       	call   f01017b1 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, 
f0102fa2:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102fa9:	00 
f0102faa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fb1:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102fb6:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102fbb:	a1 64 89 11 f0       	mov    0xf0118964,%eax
f0102fc0:	e8 ec e7 ff ff       	call   f01017b1 <boot_map_region>
                  KERNBASE, 
                  ROUNDUP((0xFFFFFFFF-KERNBASE), PGSIZE),
                  0, 
                  (PTE_W | PTE_P));
  	cprintf("KERNBASE 0x%x\n", KERNBASE);  
f0102fc5:	c7 44 24 04 00 00 00 	movl   $0xf0000000,0x4(%esp)
f0102fcc:	f0 
f0102fcd:	c7 04 24 1f 53 10 f0 	movl   $0xf010531f,(%esp)
f0102fd4:	e8 de 01 00 00       	call   f01031b7 <cprintf>

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
f0102fd9:	e8 e8 dc ff ff       	call   f0100cc6 <check_kern_pgdir>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102fde:	a1 64 89 11 f0       	mov    0xf0118964,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102fe3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102fe8:	77 20                	ja     f010300a <mem_init+0x13da>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102fea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102fee:	c7 44 24 08 24 49 10 	movl   $0xf0104924,0x8(%esp)
f0102ff5:	f0 
f0102ff6:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
f0102ffd:	00 
f0102ffe:	c7 04 24 1e 50 10 f0 	movl   $0xf010501e,(%esp)
f0103005:	e8 7b d0 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010300a:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103010:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103013:	b8 00 00 00 00       	mov    $0x0,%eax
f0103018:	e8 04 e1 ff ff       	call   f0101121 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010301d:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103020:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103025:	83 e0 f3             	and    $0xfffffff3,%eax
f0103028:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f010302b:	e8 2b e8 ff ff       	call   f010185b <check_page_installed_pgdir>
}
f0103030:	83 c4 3c             	add    $0x3c,%esp
f0103033:	5b                   	pop    %ebx
f0103034:	5e                   	pop    %esi
f0103035:	5f                   	pop    %edi
f0103036:	5d                   	pop    %ebp
f0103037:	c3                   	ret    

f0103038 <page_alloc_4pages>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc_4pages(int alloc_flags)
{
f0103038:	55                   	push   %ebp
f0103039:	89 e5                	mov    %esp,%ebp
f010303b:	57                   	push   %edi
f010303c:	56                   	push   %esi
f010303d:	53                   	push   %ebx
f010303e:	83 ec 2c             	sub    $0x2c,%esp
f0103041:	8b 7d 08             	mov    0x8(%ebp),%edi
	// Fill this function
	if (!page_free_list)
f0103044:	a1 50 85 11 f0       	mov    0xf0118550,%eax
f0103049:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010304c:	85 c0                	test   %eax,%eax
f010304e:	0f 84 f9 00 00 00    	je     f010314d <page_alloc_4pages+0x115>
	int i;
	struct Page *pp_head = NULL;
	struct Page *head = NULL;
	pp_head = page_free_list;
	head = pp_head;
	page_free_list = page_free_list->pp_link;
f0103054:	89 c2                	mov    %eax,%edx
f0103056:	8b 00                	mov    (%eax),%eax
f0103058:	a3 50 85 11 f0       	mov    %eax,0xf0118550
	if (alloc_flags & ALLOC_ZERO)
f010305d:	83 e7 01             	and    $0x1,%edi
f0103060:	74 58                	je     f01030ba <page_alloc_4pages+0x82>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103062:	89 d0                	mov    %edx,%eax
f0103064:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f010306a:	c1 f8 03             	sar    $0x3,%eax
f010306d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103070:	89 c2                	mov    %eax,%edx
f0103072:	c1 ea 0c             	shr    $0xc,%edx
f0103075:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f010307b:	72 20                	jb     f010309d <page_alloc_4pages+0x65>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010307d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103081:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f0103088:	f0 
f0103089:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0103090:	00 
f0103091:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f0103098:	e8 e8 cf ff ff       	call   f0100085 <_panic>
		memset(page2kva(pp_head), 0, PGSIZE);
f010309d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030a4:	00 
f01030a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01030ac:	00 
f01030ad:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01030b2:	89 04 24             	mov    %eax,(%esp)
f01030b5:	e8 dc 0d 00 00       	call   f0103e96 <memset>

	for (i = 1; i < 3; i++) {
		if (!page_free_list)
f01030ba:	8b 1d 50 85 11 f0    	mov    0xf0118550,%ebx
f01030c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01030c3:	be 01 00 00 00       	mov    $0x1,%esi
f01030c8:	85 db                	test   %ebx,%ebx
f01030ca:	75 0f                	jne    f01030db <page_alloc_4pages+0xa3>
f01030cc:	eb 7f                	jmp    f010314d <page_alloc_4pages+0x115>
f01030ce:	a1 50 85 11 f0       	mov    0xf0118550,%eax
f01030d3:	85 c0                	test   %eax,%eax
f01030d5:	74 76                	je     f010314d <page_alloc_4pages+0x115>
f01030d7:	89 da                	mov    %ebx,%edx
f01030d9:	89 c3                	mov    %eax,%ebx
			return NULL;
		struct Page *pp = NULL;
		pp = page_free_list;
		page_free_list = page_free_list->pp_link;
f01030db:	8b 03                	mov    (%ebx),%eax
f01030dd:	a3 50 85 11 f0       	mov    %eax,0xf0118550
		pp_head->pp_link = pp;
f01030e2:	89 1a                	mov    %ebx,(%edx)
		pp_head = pp;
		if (alloc_flags & ALLOC_ZERO)
f01030e4:	85 ff                	test   %edi,%edi
f01030e6:	74 58                	je     f0103140 <page_alloc_4pages+0x108>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01030e8:	89 d8                	mov    %ebx,%eax
f01030ea:	2b 05 68 89 11 f0    	sub    0xf0118968,%eax
f01030f0:	c1 f8 03             	sar    $0x3,%eax
f01030f3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030f6:	89 c2                	mov    %eax,%edx
f01030f8:	c1 ea 0c             	shr    $0xc,%edx
f01030fb:	3b 15 60 89 11 f0    	cmp    0xf0118960,%edx
f0103101:	72 20                	jb     f0103123 <page_alloc_4pages+0xeb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103103:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103107:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f010310e:	f0 
f010310f:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0103116:	00 
f0103117:	c7 04 24 91 50 10 f0 	movl   $0xf0105091,(%esp)
f010311e:	e8 62 cf ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0, PGSIZE);
f0103123:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010312a:	00 
f010312b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103132:	00 
f0103133:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103138:	89 04 24             	mov    %eax,(%esp)
f010313b:	e8 56 0d 00 00       	call   f0103e96 <memset>
	head = pp_head;
	page_free_list = page_free_list->pp_link;
	if (alloc_flags & ALLOC_ZERO)
		memset(page2kva(pp_head), 0, PGSIZE);

	for (i = 1; i < 3; i++) {
f0103140:	83 c6 01             	add    $0x1,%esi
f0103143:	83 fe 03             	cmp    $0x3,%esi
f0103146:	75 86                	jne    f01030ce <page_alloc_4pages+0x96>
f0103148:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010314b:	eb 05                	jmp    f0103152 <page_alloc_4pages+0x11a>
f010314d:	b8 00 00 00 00       	mov    $0x0,%eax
		pp_head = pp;
		if (alloc_flags & ALLOC_ZERO)
			memset(page2kva(pp), 0, PGSIZE);
	}
	return head;
}
f0103152:	83 c4 2c             	add    $0x2c,%esp
f0103155:	5b                   	pop    %ebx
f0103156:	5e                   	pop    %esi
f0103157:	5f                   	pop    %edi
f0103158:	5d                   	pop    %ebp
f0103159:	c3                   	ret    
	...

f010315c <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010315c:	55                   	push   %ebp
f010315d:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010315f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103164:	8b 45 08             	mov    0x8(%ebp),%eax
f0103167:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103168:	b2 71                	mov    $0x71,%dl
f010316a:	ec                   	in     (%dx),%al
f010316b:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f010316e:	5d                   	pop    %ebp
f010316f:	c3                   	ret    

f0103170 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103170:	55                   	push   %ebp
f0103171:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103173:	ba 70 00 00 00       	mov    $0x70,%edx
f0103178:	8b 45 08             	mov    0x8(%ebp),%eax
f010317b:	ee                   	out    %al,(%dx)
f010317c:	b2 71                	mov    $0x71,%dl
f010317e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103181:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103182:	5d                   	pop    %ebp
f0103183:	c3                   	ret    

f0103184 <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0103184:	55                   	push   %ebp
f0103185:	89 e5                	mov    %esp,%ebp
f0103187:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010318a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103191:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103194:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103198:	8b 45 08             	mov    0x8(%ebp),%eax
f010319b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010319f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01031a2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031a6:	c7 04 24 d1 31 10 f0 	movl   $0xf01031d1,(%esp)
f01031ad:	e8 db 04 00 00       	call   f010368d <vprintfmt>
	return cnt;
}
f01031b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01031b5:	c9                   	leave  
f01031b6:	c3                   	ret    

f01031b7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01031b7:	55                   	push   %ebp
f01031b8:	89 e5                	mov    %esp,%ebp
f01031ba:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f01031bd:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f01031c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01031c7:	89 04 24             	mov    %eax,(%esp)
f01031ca:	e8 b5 ff ff ff       	call   f0103184 <vcprintf>
	va_end(ap);

	return cnt;
}
f01031cf:	c9                   	leave  
f01031d0:	c3                   	ret    

f01031d1 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01031d1:	55                   	push   %ebp
f01031d2:	89 e5                	mov    %esp,%ebp
f01031d4:	53                   	push   %ebx
f01031d5:	83 ec 14             	sub    $0x14,%esp
f01031d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f01031db:	8b 45 08             	mov    0x8(%ebp),%eax
f01031de:	89 04 24             	mov    %eax,(%esp)
f01031e1:	e8 14 d3 ff ff       	call   f01004fa <cputchar>
    (*cnt)++;
f01031e6:	83 03 01             	addl   $0x1,(%ebx)
}
f01031e9:	83 c4 14             	add    $0x14,%esp
f01031ec:	5b                   	pop    %ebx
f01031ed:	5d                   	pop    %ebp
f01031ee:	c3                   	ret    
	...

f01031f0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01031f0:	55                   	push   %ebp
f01031f1:	89 e5                	mov    %esp,%ebp
f01031f3:	57                   	push   %edi
f01031f4:	56                   	push   %esi
f01031f5:	53                   	push   %ebx
f01031f6:	83 ec 14             	sub    $0x14,%esp
f01031f9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01031fc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01031ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103202:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103205:	8b 1a                	mov    (%edx),%ebx
f0103207:	8b 01                	mov    (%ecx),%eax
f0103209:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f010320c:	39 c3                	cmp    %eax,%ebx
f010320e:	0f 8f 9c 00 00 00    	jg     f01032b0 <stab_binsearch+0xc0>
f0103214:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f010321b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010321e:	01 d8                	add    %ebx,%eax
f0103220:	89 c7                	mov    %eax,%edi
f0103222:	c1 ef 1f             	shr    $0x1f,%edi
f0103225:	01 c7                	add    %eax,%edi
f0103227:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103229:	39 df                	cmp    %ebx,%edi
f010322b:	7c 33                	jl     f0103260 <stab_binsearch+0x70>
f010322d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103230:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0103233:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0103238:	39 f0                	cmp    %esi,%eax
f010323a:	0f 84 bc 00 00 00    	je     f01032fc <stab_binsearch+0x10c>
f0103240:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0103244:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0103248:	89 f8                	mov    %edi,%eax
			m--;
f010324a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010324d:	39 d8                	cmp    %ebx,%eax
f010324f:	7c 0f                	jl     f0103260 <stab_binsearch+0x70>
f0103251:	0f b6 0a             	movzbl (%edx),%ecx
f0103254:	83 ea 0c             	sub    $0xc,%edx
f0103257:	39 f1                	cmp    %esi,%ecx
f0103259:	75 ef                	jne    f010324a <stab_binsearch+0x5a>
f010325b:	e9 9e 00 00 00       	jmp    f01032fe <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103260:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0103263:	eb 3c                	jmp    f01032a1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0103265:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103268:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f010326a:	8d 5f 01             	lea    0x1(%edi),%ebx
f010326d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103274:	eb 2b                	jmp    f01032a1 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0103276:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103279:	76 14                	jbe    f010328f <stab_binsearch+0x9f>
			*region_right = m - 1;
f010327b:	83 e8 01             	sub    $0x1,%eax
f010327e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103281:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103284:	89 02                	mov    %eax,(%edx)
f0103286:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010328d:	eb 12                	jmp    f01032a1 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010328f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0103292:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0103294:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103298:	89 c3                	mov    %eax,%ebx
f010329a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f01032a1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f01032a4:	0f 8d 71 ff ff ff    	jge    f010321b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01032aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01032ae:	75 0f                	jne    f01032bf <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f01032b0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01032b3:	8b 03                	mov    (%ebx),%eax
f01032b5:	83 e8 01             	sub    $0x1,%eax
f01032b8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01032bb:	89 02                	mov    %eax,(%edx)
f01032bd:	eb 57                	jmp    f0103316 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01032c2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01032c4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01032c7:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032c9:	39 c1                	cmp    %eax,%ecx
f01032cb:	7d 28                	jge    f01032f5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01032cd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01032d0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f01032d3:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f01032d8:	39 f2                	cmp    %esi,%edx
f01032da:	74 19                	je     f01032f5 <stab_binsearch+0x105>
f01032dc:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f01032e0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f01032e4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032e7:	39 c1                	cmp    %eax,%ecx
f01032e9:	7d 0a                	jge    f01032f5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f01032eb:	0f b6 1a             	movzbl (%edx),%ebx
f01032ee:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01032f1:	39 f3                	cmp    %esi,%ebx
f01032f3:	75 ef                	jne    f01032e4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f01032f5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01032f8:	89 02                	mov    %eax,(%edx)
f01032fa:	eb 1a                	jmp    f0103316 <stab_binsearch+0x126>
	}
}
f01032fc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01032fe:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103301:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0103304:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103308:	3b 55 0c             	cmp    0xc(%ebp),%edx
f010330b:	0f 82 54 ff ff ff    	jb     f0103265 <stab_binsearch+0x75>
f0103311:	e9 60 ff ff ff       	jmp    f0103276 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0103316:	83 c4 14             	add    $0x14,%esp
f0103319:	5b                   	pop    %ebx
f010331a:	5e                   	pop    %esi
f010331b:	5f                   	pop    %edi
f010331c:	5d                   	pop    %ebp
f010331d:	c3                   	ret    

f010331e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010331e:	55                   	push   %ebp
f010331f:	89 e5                	mov    %esp,%ebp
f0103321:	83 ec 48             	sub    $0x48,%esp
f0103324:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103327:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010332a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010332d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103333:	c7 03 2e 53 10 f0    	movl   $0xf010532e,(%ebx)
	info->eip_line = 0;
f0103339:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103340:	c7 43 08 2e 53 10 f0 	movl   $0xf010532e,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0103347:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010334e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103351:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103358:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010335e:	76 12                	jbe    f0103372 <debuginfo_eip+0x54>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103360:	b8 67 d7 10 f0       	mov    $0xf010d767,%eax
f0103365:	3d 49 b7 10 f0       	cmp    $0xf010b749,%eax
f010336a:	0f 86 a2 01 00 00    	jbe    f0103512 <debuginfo_eip+0x1f4>
f0103370:	eb 1c                	jmp    f010338e <debuginfo_eip+0x70>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0103372:	c7 44 24 08 38 53 10 	movl   $0xf0105338,0x8(%esp)
f0103379:	f0 
f010337a:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0103381:	00 
f0103382:	c7 04 24 45 53 10 f0 	movl   $0xf0105345,(%esp)
f0103389:	e8 f7 cc ff ff       	call   f0100085 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010338e:	80 3d 66 d7 10 f0 00 	cmpb   $0x0,0xf010d766
f0103395:	0f 85 77 01 00 00    	jne    f0103512 <debuginfo_eip+0x1f4>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010339b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01033a2:	b8 48 b7 10 f0       	mov    $0xf010b748,%eax
f01033a7:	2d e0 55 10 f0       	sub    $0xf01055e0,%eax
f01033ac:	c1 f8 02             	sar    $0x2,%eax
f01033af:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01033b5:	83 e8 01             	sub    $0x1,%eax
f01033b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01033bb:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01033be:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01033c1:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033c5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01033cc:	b8 e0 55 10 f0       	mov    $0xf01055e0,%eax
f01033d1:	e8 1a fe ff ff       	call   f01031f0 <stab_binsearch>
	if (lfile == 0)
f01033d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033d9:	85 c0                	test   %eax,%eax
f01033db:	0f 84 31 01 00 00    	je     f0103512 <debuginfo_eip+0x1f4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01033e1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01033e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01033e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01033ea:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01033ed:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01033f0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033f4:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01033fb:	b8 e0 55 10 f0       	mov    $0xf01055e0,%eax
f0103400:	e8 eb fd ff ff       	call   f01031f0 <stab_binsearch>

	if (lfun <= rfun) {
f0103405:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103408:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f010340b:	7f 3c                	jg     f0103449 <debuginfo_eip+0x12b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010340d:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103410:	8b 80 e0 55 10 f0    	mov    -0xfefaa20(%eax),%eax
f0103416:	ba 67 d7 10 f0       	mov    $0xf010d767,%edx
f010341b:	81 ea 49 b7 10 f0    	sub    $0xf010b749,%edx
f0103421:	39 d0                	cmp    %edx,%eax
f0103423:	73 08                	jae    f010342d <debuginfo_eip+0x10f>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103425:	05 49 b7 10 f0       	add    $0xf010b749,%eax
f010342a:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f010342d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103430:	6b d0 0c             	imul   $0xc,%eax,%edx
f0103433:	8b 92 e8 55 10 f0    	mov    -0xfefaa18(%edx),%edx
f0103439:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010343c:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010343e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103441:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103444:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103447:	eb 0f                	jmp    f0103458 <debuginfo_eip+0x13a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103449:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f010344c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010344f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103452:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103455:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103458:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010345f:	00 
f0103460:	8b 43 08             	mov    0x8(%ebx),%eax
f0103463:	89 04 24             	mov    %eax,(%esp)
f0103466:	e8 00 0a 00 00       	call   f0103e6b <strfind>
f010346b:	2b 43 08             	sub    0x8(%ebx),%eax
f010346e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0103471:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0103474:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0103477:	89 74 24 04          	mov    %esi,0x4(%esp)
f010347b:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103482:	b8 e0 55 10 f0       	mov    $0xf01055e0,%eax
f0103487:	e8 64 fd ff ff       	call   f01031f0 <stab_binsearch>
	if (lline <= rline) {
f010348c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010348f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0103492:	7f 7e                	jg     f0103512 <debuginfo_eip+0x1f4>
		info->eip_line = stabs[lline].n_desc;
f0103494:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103497:	0f b7 80 e6 55 10 f0 	movzwl -0xfefaa1a(%eax),%eax
f010349e:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f01034a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01034a4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01034a7:	6b c2 0c             	imul   $0xc,%edx,%eax
f01034aa:	05 e0 55 10 f0       	add    $0xf01055e0,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034af:	eb 06                	jmp    f01034b7 <debuginfo_eip+0x199>
f01034b1:	83 ea 01             	sub    $0x1,%edx
f01034b4:	83 e8 0c             	sub    $0xc,%eax
f01034b7:	39 d7                	cmp    %edx,%edi
f01034b9:	7f 26                	jg     f01034e1 <debuginfo_eip+0x1c3>
f01034bb:	89 c6                	mov    %eax,%esi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01034bd:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01034c1:	80 f9 84             	cmp    $0x84,%cl
f01034c4:	74 65                	je     f010352b <debuginfo_eip+0x20d>
f01034c6:	80 f9 64             	cmp    $0x64,%cl
f01034c9:	75 e6                	jne    f01034b1 <debuginfo_eip+0x193>
f01034cb:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01034cf:	74 e0                	je     f01034b1 <debuginfo_eip+0x193>
f01034d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01034d8:	eb 51                	jmp    f010352b <debuginfo_eip+0x20d>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01034da:	05 49 b7 10 f0       	add    $0xf010b749,%eax
f01034df:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01034e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034e4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01034e7:	7d 30                	jge    f0103519 <debuginfo_eip+0x1fb>
		for (lline = lfun + 1;
f01034e9:	83 c0 01             	add    $0x1,%eax
f01034ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01034ef:	ba e0 55 10 f0       	mov    $0xf01055e0,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01034f4:	eb 08                	jmp    f01034fe <debuginfo_eip+0x1e0>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01034f6:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01034fa:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01034fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103501:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0103504:	7d 13                	jge    f0103519 <debuginfo_eip+0x1fb>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103506:	6b c0 0c             	imul   $0xc,%eax,%eax
f0103509:	80 7c 10 04 a0       	cmpb   $0xa0,0x4(%eax,%edx,1)
f010350e:	74 e6                	je     f01034f6 <debuginfo_eip+0x1d8>
f0103510:	eb 07                	jmp    f0103519 <debuginfo_eip+0x1fb>
f0103512:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103517:	eb 05                	jmp    f010351e <debuginfo_eip+0x200>
f0103519:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f010351e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103521:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103524:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103527:	89 ec                	mov    %ebp,%esp
f0103529:	5d                   	pop    %ebp
f010352a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010352b:	8b 06                	mov    (%esi),%eax
f010352d:	ba 67 d7 10 f0       	mov    $0xf010d767,%edx
f0103532:	81 ea 49 b7 10 f0    	sub    $0xf010b749,%edx
f0103538:	39 d0                	cmp    %edx,%eax
f010353a:	72 9e                	jb     f01034da <debuginfo_eip+0x1bc>
f010353c:	eb a3                	jmp    f01034e1 <debuginfo_eip+0x1c3>
	...

f0103540 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103540:	55                   	push   %ebp
f0103541:	89 e5                	mov    %esp,%ebp
f0103543:	57                   	push   %edi
f0103544:	56                   	push   %esi
f0103545:	53                   	push   %ebx
f0103546:	83 ec 4c             	sub    $0x4c,%esp
f0103549:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010354c:	89 d6                	mov    %edx,%esi
f010354e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103551:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103554:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103557:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010355a:	8b 45 10             	mov    0x10(%ebp),%eax
f010355d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103560:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103563:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103566:	b9 00 00 00 00       	mov    $0x0,%ecx
f010356b:	39 d1                	cmp    %edx,%ecx
f010356d:	72 15                	jb     f0103584 <printnum+0x44>
f010356f:	77 07                	ja     f0103578 <printnum+0x38>
f0103571:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103574:	39 d0                	cmp    %edx,%eax
f0103576:	76 0c                	jbe    f0103584 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103578:	83 eb 01             	sub    $0x1,%ebx
f010357b:	85 db                	test   %ebx,%ebx
f010357d:	8d 76 00             	lea    0x0(%esi),%esi
f0103580:	7f 61                	jg     f01035e3 <printnum+0xa3>
f0103582:	eb 70                	jmp    f01035f4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103584:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0103588:	83 eb 01             	sub    $0x1,%ebx
f010358b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010358f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103593:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0103597:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010359b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010359e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01035a1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01035a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01035a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01035af:	00 
f01035b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01035b3:	89 04 24             	mov    %eax,(%esp)
f01035b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01035b9:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035bd:	e8 3e 0b 00 00       	call   f0104100 <__udivdi3>
f01035c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01035c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01035c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01035cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01035d0:	89 04 24             	mov    %eax,(%esp)
f01035d3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01035d7:	89 f2                	mov    %esi,%edx
f01035d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01035dc:	e8 5f ff ff ff       	call   f0103540 <printnum>
f01035e1:	eb 11                	jmp    f01035f4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01035e3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035e7:	89 3c 24             	mov    %edi,(%esp)
f01035ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01035ed:	83 eb 01             	sub    $0x1,%ebx
f01035f0:	85 db                	test   %ebx,%ebx
f01035f2:	7f ef                	jg     f01035e3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01035f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035f8:	8b 74 24 04          	mov    0x4(%esp),%esi
f01035fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01035ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103603:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010360a:	00 
f010360b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010360e:	89 14 24             	mov    %edx,(%esp)
f0103611:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103614:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103618:	e8 13 0c 00 00       	call   f0104230 <__umoddi3>
f010361d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103621:	0f be 80 53 53 10 f0 	movsbl -0xfefacad(%eax),%eax
f0103628:	89 04 24             	mov    %eax,(%esp)
f010362b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010362e:	83 c4 4c             	add    $0x4c,%esp
f0103631:	5b                   	pop    %ebx
f0103632:	5e                   	pop    %esi
f0103633:	5f                   	pop    %edi
f0103634:	5d                   	pop    %ebp
f0103635:	c3                   	ret    

f0103636 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103636:	55                   	push   %ebp
f0103637:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103639:	83 fa 01             	cmp    $0x1,%edx
f010363c:	7e 0e                	jle    f010364c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010363e:	8b 10                	mov    (%eax),%edx
f0103640:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103643:	89 08                	mov    %ecx,(%eax)
f0103645:	8b 02                	mov    (%edx),%eax
f0103647:	8b 52 04             	mov    0x4(%edx),%edx
f010364a:	eb 22                	jmp    f010366e <getuint+0x38>
	else if (lflag)
f010364c:	85 d2                	test   %edx,%edx
f010364e:	74 10                	je     f0103660 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103650:	8b 10                	mov    (%eax),%edx
f0103652:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103655:	89 08                	mov    %ecx,(%eax)
f0103657:	8b 02                	mov    (%edx),%eax
f0103659:	ba 00 00 00 00       	mov    $0x0,%edx
f010365e:	eb 0e                	jmp    f010366e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103660:	8b 10                	mov    (%eax),%edx
f0103662:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103665:	89 08                	mov    %ecx,(%eax)
f0103667:	8b 02                	mov    (%edx),%eax
f0103669:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010366e:	5d                   	pop    %ebp
f010366f:	c3                   	ret    

f0103670 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103670:	55                   	push   %ebp
f0103671:	89 e5                	mov    %esp,%ebp
f0103673:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103676:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010367a:	8b 10                	mov    (%eax),%edx
f010367c:	3b 50 04             	cmp    0x4(%eax),%edx
f010367f:	73 0a                	jae    f010368b <sprintputch+0x1b>
		*b->buf++ = ch;
f0103681:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103684:	88 0a                	mov    %cl,(%edx)
f0103686:	83 c2 01             	add    $0x1,%edx
f0103689:	89 10                	mov    %edx,(%eax)
}
f010368b:	5d                   	pop    %ebp
f010368c:	c3                   	ret    

f010368d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010368d:	55                   	push   %ebp
f010368e:	89 e5                	mov    %esp,%ebp
f0103690:	57                   	push   %edi
f0103691:	56                   	push   %esi
f0103692:	53                   	push   %ebx
f0103693:	83 ec 5c             	sub    $0x5c,%esp
f0103696:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103699:	8b 75 0c             	mov    0xc(%ebp),%esi
f010369c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010369f:	c7 45 c4 ff ff ff ff 	movl   $0xffffffff,-0x3c(%ebp)
f01036a6:	eb 16                	jmp    f01036be <vprintfmt+0x31>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01036a8:	85 c0                	test   %eax,%eax
f01036aa:	0f 84 a8 04 00 00    	je     f0103b58 <vprintfmt+0x4cb>
				return;
			putch(ch, putdat);
f01036b0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01036b4:	89 04 24             	mov    %eax,(%esp)
f01036b7:	ff d7                	call   *%edi
f01036b9:	eb 03                	jmp    f01036be <vprintfmt+0x31>
f01036bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01036be:	0f b6 03             	movzbl (%ebx),%eax
f01036c1:	83 c3 01             	add    $0x1,%ebx
f01036c4:	83 f8 25             	cmp    $0x25,%eax
f01036c7:	75 df                	jne    f01036a8 <vprintfmt+0x1b>
f01036c9:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f01036cd:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f01036d4:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01036db:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f01036e2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01036e7:	eb 06                	jmp    f01036ef <vprintfmt+0x62>
f01036e9:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f01036ed:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036ef:	0f b6 13             	movzbl (%ebx),%edx
f01036f2:	0f b6 c2             	movzbl %dl,%eax
f01036f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01036f8:	8d 43 01             	lea    0x1(%ebx),%eax
f01036fb:	83 ea 23             	sub    $0x23,%edx
f01036fe:	80 fa 55             	cmp    $0x55,%dl
f0103701:	0f 87 34 04 00 00    	ja     f0103b3b <vprintfmt+0x4ae>
f0103707:	0f b6 d2             	movzbl %dl,%edx
f010370a:	ff 24 95 5c 54 10 f0 	jmp    *-0xfefaba4(,%edx,4)
f0103711:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f0103715:	eb d6                	jmp    f01036ed <vprintfmt+0x60>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103717:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010371a:	83 ea 30             	sub    $0x30,%edx
f010371d:	89 55 c8             	mov    %edx,-0x38(%ebp)
				ch = *fmt;
f0103720:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0103723:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0103726:	83 fb 09             	cmp    $0x9,%ebx
f0103729:	77 54                	ja     f010377f <vprintfmt+0xf2>
f010372b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f010372e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103731:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f0103734:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0103737:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f010373b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010373e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0103741:	83 fb 09             	cmp    $0x9,%ebx
f0103744:	76 eb                	jbe    f0103731 <vprintfmt+0xa4>
f0103746:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103749:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010374c:	eb 31                	jmp    f010377f <vprintfmt+0xf2>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010374e:	8b 55 14             	mov    0x14(%ebp),%edx
f0103751:	8d 5a 04             	lea    0x4(%edx),%ebx
f0103754:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0103757:	8b 12                	mov    (%edx),%edx
f0103759:	89 55 c8             	mov    %edx,-0x38(%ebp)
			goto process_precision;
f010375c:	eb 21                	jmp    f010377f <vprintfmt+0xf2>

		case '.':
			if (width < 0)
f010375e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103762:	ba 00 00 00 00       	mov    $0x0,%edx
f0103767:	0f 49 55 dc          	cmovns -0x24(%ebp),%edx
f010376b:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010376e:	e9 7a ff ff ff       	jmp    f01036ed <vprintfmt+0x60>
f0103773:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f010377a:	e9 6e ff ff ff       	jmp    f01036ed <vprintfmt+0x60>

		process_precision:
			if (width < 0)
f010377f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103783:	0f 89 64 ff ff ff    	jns    f01036ed <vprintfmt+0x60>
f0103789:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010378c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010378f:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0103792:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0103795:	e9 53 ff ff ff       	jmp    f01036ed <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010379a:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f010379d:	e9 4b ff ff ff       	jmp    f01036ed <vprintfmt+0x60>
f01037a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01037a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01037a8:	8d 50 04             	lea    0x4(%eax),%edx
f01037ab:	89 55 14             	mov    %edx,0x14(%ebp)
f01037ae:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037b2:	8b 00                	mov    (%eax),%eax
f01037b4:	89 04 24             	mov    %eax,(%esp)
f01037b7:	ff d7                	call   *%edi
f01037b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f01037bc:	e9 fd fe ff ff       	jmp    f01036be <vprintfmt+0x31>
f01037c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01037c4:	8b 45 14             	mov    0x14(%ebp),%eax
f01037c7:	8d 50 04             	lea    0x4(%eax),%edx
f01037ca:	89 55 14             	mov    %edx,0x14(%ebp)
f01037cd:	8b 00                	mov    (%eax),%eax
f01037cf:	89 c2                	mov    %eax,%edx
f01037d1:	c1 fa 1f             	sar    $0x1f,%edx
f01037d4:	31 d0                	xor    %edx,%eax
f01037d6:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01037d8:	83 f8 06             	cmp    $0x6,%eax
f01037db:	7f 0b                	jg     f01037e8 <vprintfmt+0x15b>
f01037dd:	8b 14 85 b4 55 10 f0 	mov    -0xfefaa4c(,%eax,4),%edx
f01037e4:	85 d2                	test   %edx,%edx
f01037e6:	75 20                	jne    f0103808 <vprintfmt+0x17b>
				printfmt(putch, putdat, "error %d", err);
f01037e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037ec:	c7 44 24 08 64 53 10 	movl   $0xf0105364,0x8(%esp)
f01037f3:	f0 
f01037f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01037f8:	89 3c 24             	mov    %edi,(%esp)
f01037fb:	e8 e0 03 00 00       	call   f0103be0 <printfmt>
f0103800:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103803:	e9 b6 fe ff ff       	jmp    f01036be <vprintfmt+0x31>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0103808:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010380c:	c7 44 24 08 4c 50 10 	movl   $0xf010504c,0x8(%esp)
f0103813:	f0 
f0103814:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103818:	89 3c 24             	mov    %edi,(%esp)
f010381b:	e8 c0 03 00 00       	call   f0103be0 <printfmt>
f0103820:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103823:	e9 96 fe ff ff       	jmp    f01036be <vprintfmt+0x31>
f0103828:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010382b:	89 c3                	mov    %eax,%ebx
f010382d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103830:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103833:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103836:	8b 45 14             	mov    0x14(%ebp),%eax
f0103839:	8d 50 04             	lea    0x4(%eax),%edx
f010383c:	89 55 14             	mov    %edx,0x14(%ebp)
f010383f:	8b 00                	mov    (%eax),%eax
f0103841:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103844:	85 c0                	test   %eax,%eax
f0103846:	b8 6d 53 10 f0       	mov    $0xf010536d,%eax
f010384b:	0f 45 45 cc          	cmovne -0x34(%ebp),%eax
f010384f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f0103852:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f0103856:	7e 06                	jle    f010385e <vprintfmt+0x1d1>
f0103858:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f010385c:	75 13                	jne    f0103871 <vprintfmt+0x1e4>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010385e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0103861:	0f be 02             	movsbl (%edx),%eax
f0103864:	85 c0                	test   %eax,%eax
f0103866:	0f 85 9f 00 00 00    	jne    f010390b <vprintfmt+0x27e>
f010386c:	e9 8f 00 00 00       	jmp    f0103900 <vprintfmt+0x273>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103871:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103875:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103878:	89 0c 24             	mov    %ecx,(%esp)
f010387b:	e8 8b 04 00 00       	call   f0103d0b <strnlen>
f0103880:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103883:	29 c2                	sub    %eax,%edx
f0103885:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103888:	85 d2                	test   %edx,%edx
f010388a:	7e d2                	jle    f010385e <vprintfmt+0x1d1>
					putch(padc, putdat);
f010388c:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f0103890:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103893:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0103896:	89 d3                	mov    %edx,%ebx
f0103898:	89 74 24 04          	mov    %esi,0x4(%esp)
f010389c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010389f:	89 04 24             	mov    %eax,(%esp)
f01038a2:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01038a4:	83 eb 01             	sub    $0x1,%ebx
f01038a7:	85 db                	test   %ebx,%ebx
f01038a9:	7f ed                	jg     f0103898 <vprintfmt+0x20b>
f01038ab:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01038ae:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01038b5:	eb a7                	jmp    f010385e <vprintfmt+0x1d1>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01038b7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01038bb:	74 1b                	je     f01038d8 <vprintfmt+0x24b>
f01038bd:	8d 50 e0             	lea    -0x20(%eax),%edx
f01038c0:	83 fa 5e             	cmp    $0x5e,%edx
f01038c3:	76 13                	jbe    f01038d8 <vprintfmt+0x24b>
					putch('?', putdat);
f01038c5:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01038c8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01038cc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01038d3:	ff 55 e0             	call   *-0x20(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01038d6:	eb 0d                	jmp    f01038e5 <vprintfmt+0x258>
					putch('?', putdat);
				else
					putch(ch, putdat);
f01038d8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01038db:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01038df:	89 04 24             	mov    %eax,(%esp)
f01038e2:	ff 55 e0             	call   *-0x20(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01038e5:	83 ef 01             	sub    $0x1,%edi
f01038e8:	0f be 03             	movsbl (%ebx),%eax
f01038eb:	85 c0                	test   %eax,%eax
f01038ed:	74 05                	je     f01038f4 <vprintfmt+0x267>
f01038ef:	83 c3 01             	add    $0x1,%ebx
f01038f2:	eb 2e                	jmp    f0103922 <vprintfmt+0x295>
f01038f4:	89 7d dc             	mov    %edi,-0x24(%ebp)
f01038f7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01038fa:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01038fd:	8b 5d c8             	mov    -0x38(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103900:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103904:	7f 33                	jg     f0103939 <vprintfmt+0x2ac>
f0103906:	e9 b0 fd ff ff       	jmp    f01036bb <vprintfmt+0x2e>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010390b:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010390e:	83 c2 01             	add    $0x1,%edx
f0103911:	89 7d e0             	mov    %edi,-0x20(%ebp)
f0103914:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0103917:	89 75 cc             	mov    %esi,-0x34(%ebp)
f010391a:	8b 75 c8             	mov    -0x38(%ebp),%esi
f010391d:	89 5d c8             	mov    %ebx,-0x38(%ebp)
f0103920:	89 d3                	mov    %edx,%ebx
f0103922:	85 f6                	test   %esi,%esi
f0103924:	78 91                	js     f01038b7 <vprintfmt+0x22a>
f0103926:	83 ee 01             	sub    $0x1,%esi
f0103929:	79 8c                	jns    f01038b7 <vprintfmt+0x22a>
f010392b:	89 7d dc             	mov    %edi,-0x24(%ebp)
f010392e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103931:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103934:	8b 5d c8             	mov    -0x38(%ebp),%ebx
f0103937:	eb c7                	jmp    f0103900 <vprintfmt+0x273>
f0103939:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010393c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010393f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103943:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f010394a:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010394c:	83 eb 01             	sub    $0x1,%ebx
f010394f:	85 db                	test   %ebx,%ebx
f0103951:	7f ec                	jg     f010393f <vprintfmt+0x2b2>
f0103953:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0103956:	e9 63 fd ff ff       	jmp    f01036be <vprintfmt+0x31>
f010395b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010395e:	83 f9 01             	cmp    $0x1,%ecx
f0103961:	7e 16                	jle    f0103979 <vprintfmt+0x2ec>
		return va_arg(*ap, long long);
f0103963:	8b 45 14             	mov    0x14(%ebp),%eax
f0103966:	8d 50 08             	lea    0x8(%eax),%edx
f0103969:	89 55 14             	mov    %edx,0x14(%ebp)
f010396c:	8b 10                	mov    (%eax),%edx
f010396e:	8b 48 04             	mov    0x4(%eax),%ecx
f0103971:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103974:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103977:	eb 32                	jmp    f01039ab <vprintfmt+0x31e>
	else if (lflag)
f0103979:	85 c9                	test   %ecx,%ecx
f010397b:	74 18                	je     f0103995 <vprintfmt+0x308>
		return va_arg(*ap, long);
f010397d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103980:	8d 50 04             	lea    0x4(%eax),%edx
f0103983:	89 55 14             	mov    %edx,0x14(%ebp)
f0103986:	8b 00                	mov    (%eax),%eax
f0103988:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010398b:	89 c1                	mov    %eax,%ecx
f010398d:	c1 f9 1f             	sar    $0x1f,%ecx
f0103990:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0103993:	eb 16                	jmp    f01039ab <vprintfmt+0x31e>
	else
		return va_arg(*ap, int);
f0103995:	8b 45 14             	mov    0x14(%ebp),%eax
f0103998:	8d 50 04             	lea    0x4(%eax),%edx
f010399b:	89 55 14             	mov    %edx,0x14(%ebp)
f010399e:	8b 00                	mov    (%eax),%eax
f01039a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01039a3:	89 c2                	mov    %eax,%edx
f01039a5:	c1 fa 1f             	sar    $0x1f,%edx
f01039a8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01039ab:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01039ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039b1:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f01039b6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01039ba:	0f 89 8a 00 00 00    	jns    f0103a4a <vprintfmt+0x3bd>
				putch('-', putdat);
f01039c0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01039c4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01039cb:	ff d7                	call   *%edi
				num = -(long long) num;
f01039cd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01039d0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01039d3:	f7 d8                	neg    %eax
f01039d5:	83 d2 00             	adc    $0x0,%edx
f01039d8:	f7 da                	neg    %edx
f01039da:	eb 6e                	jmp    f0103a4a <vprintfmt+0x3bd>
f01039dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01039df:	89 ca                	mov    %ecx,%edx
f01039e1:	8d 45 14             	lea    0x14(%ebp),%eax
f01039e4:	e8 4d fc ff ff       	call   f0103636 <getuint>
f01039e9:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
f01039ee:	eb 5a                	jmp    f0103a4a <vprintfmt+0x3bd>
f01039f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		case 'o':
			// Replace this with your code.
			/* putch('X', putdat); */
			/* putch('X', putdat); */
			/* putch('X', putdat); */
		  num = getuint(&ap, lflag);
f01039f3:	89 ca                	mov    %ecx,%edx
f01039f5:	8d 45 14             	lea    0x14(%ebp),%eax
f01039f8:	e8 39 fc ff ff       	call   f0103636 <getuint>
f01039fd:	bb 08 00 00 00       	mov    $0x8,%ebx
		  base = 8;
		  goto number;
f0103a02:	eb 46                	jmp    f0103a4a <vprintfmt+0x3bd>
f0103a04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0103a07:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a0b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103a12:	ff d7                	call   *%edi
			putch('x', putdat);
f0103a14:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a18:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103a1f:	ff d7                	call   *%edi
			num = (unsigned long long)
f0103a21:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a24:	8d 50 04             	lea    0x4(%eax),%edx
f0103a27:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a2a:	8b 00                	mov    (%eax),%eax
f0103a2c:	ba 00 00 00 00       	mov    $0x0,%edx
f0103a31:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103a36:	eb 12                	jmp    f0103a4a <vprintfmt+0x3bd>
f0103a38:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103a3b:	89 ca                	mov    %ecx,%edx
f0103a3d:	8d 45 14             	lea    0x14(%ebp),%eax
f0103a40:	e8 f1 fb ff ff       	call   f0103636 <getuint>
f0103a45:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103a4a:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f0103a4e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0103a52:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103a55:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103a59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103a5d:	89 04 24             	mov    %eax,(%esp)
f0103a60:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103a64:	89 f2                	mov    %esi,%edx
f0103a66:	89 f8                	mov    %edi,%eax
f0103a68:	e8 d3 fa ff ff       	call   f0103540 <printnum>
f0103a6d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f0103a70:	e9 49 fc ff ff       	jmp    f01036be <vprintfmt+0x31>
f0103a75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
			int i = 0;
			char *pch;
			if ((pch = va_arg(ap, char *)) == NULL) {
f0103a78:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a7b:	8d 50 04             	lea    0x4(%eax),%edx
f0103a7e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103a81:	8b 00                	mov    (%eax),%eax
f0103a83:	bb e0 53 10 f0       	mov    $0xf01053e0,%ebx
f0103a88:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0103a8f:	85 c0                	test   %eax,%eax
f0103a91:	75 35                	jne    f0103ac8 <vprintfmt+0x43b>
f0103a93:	eb 15                	jmp    f0103aaa <vprintfmt+0x41d>
				for (i= 0; i < strlen(null_error);i++)
					putch(null_error[i], putdat);
f0103a95:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a99:	0f be 03             	movsbl (%ebx),%eax
f0103a9c:	89 04 24             	mov    %eax,(%esp)
f0103a9f:	ff 55 dc             	call   *-0x24(%ebp)

            // Your code here
			int i = 0;
			char *pch;
			if ((pch = va_arg(ap, char *)) == NULL) {
				for (i= 0; i < strlen(null_error);i++)
f0103aa2:	83 c7 01             	add    $0x1,%edi
f0103aa5:	83 c3 01             	add    $0x1,%ebx
f0103aa8:	eb 06                	jmp    f0103ab0 <vprintfmt+0x423>
f0103aaa:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0103aad:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0103ab0:	c7 04 24 e0 53 10 f0 	movl   $0xf01053e0,(%esp)
f0103ab7:	e8 34 02 00 00       	call   f0103cf0 <strlen>
f0103abc:	39 c7                	cmp    %eax,%edi
f0103abe:	7c d5                	jl     f0103a95 <vprintfmt+0x408>
f0103ac0:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0103ac3:	e9 f3 fb ff ff       	jmp    f01036bb <vprintfmt+0x2e>
					putch(null_error[i], putdat);
			} else {
				if (*(int *)putdat > 127) {
f0103ac8:	8b 16                	mov    (%esi),%edx
f0103aca:	83 fa 7f             	cmp    $0x7f,%edx
f0103acd:	8d 76 00             	lea    0x0(%esi),%esi
f0103ad0:	7e 48                	jle    f0103b1a <vprintfmt+0x48d>
					*pch = 127;
f0103ad2:	c6 00 7f             	movb   $0x7f,(%eax)
f0103ad5:	bb 18 54 10 f0       	mov    $0xf0105418,%ebx
f0103ada:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0103ae1:	89 7d dc             	mov    %edi,-0x24(%ebp)
f0103ae4:	89 f7                	mov    %esi,%edi
f0103ae6:	be 00 00 00 00       	mov    $0x0,%esi
					for (i = 0; i < strlen(overflow_error); i++)
f0103aeb:	eb 13                	jmp    f0103b00 <vprintfmt+0x473>
						putch(overflow_error[i], putdat);
f0103aed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103af1:	0f be 03             	movsbl (%ebx),%eax
f0103af4:	89 04 24             	mov    %eax,(%esp)
f0103af7:	ff 55 dc             	call   *-0x24(%ebp)
				for (i= 0; i < strlen(null_error);i++)
					putch(null_error[i], putdat);
			} else {
				if (*(int *)putdat > 127) {
					*pch = 127;
					for (i = 0; i < strlen(overflow_error); i++)
f0103afa:	83 c6 01             	add    $0x1,%esi
f0103afd:	83 c3 01             	add    $0x1,%ebx
f0103b00:	c7 04 24 18 54 10 f0 	movl   $0xf0105418,(%esp)
f0103b07:	e8 e4 01 00 00       	call   f0103cf0 <strlen>
f0103b0c:	39 c6                	cmp    %eax,%esi
f0103b0e:	7c dd                	jl     f0103aed <vprintfmt+0x460>
f0103b10:	89 fe                	mov    %edi,%esi
f0103b12:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0103b15:	e9 a1 fb ff ff       	jmp    f01036bb <vprintfmt+0x2e>
						putch(overflow_error[i], putdat);
				} else {
					*pch = *(int *)putdat;
f0103b1a:	88 10                	mov    %dl,(%eax)
f0103b1c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103b1f:	e9 9a fb ff ff       	jmp    f01036be <vprintfmt+0x31>
f0103b24:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103b27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            break;
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103b2a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b2e:	89 14 24             	mov    %edx,(%esp)
f0103b31:	ff d7                	call   *%edi
f0103b33:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			break;
f0103b36:	e9 83 fb ff ff       	jmp    f01036be <vprintfmt+0x31>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103b3b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103b3f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103b46:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103b48:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0103b4b:	80 38 25             	cmpb   $0x25,(%eax)
f0103b4e:	0f 84 6a fb ff ff    	je     f01036be <vprintfmt+0x31>
f0103b54:	89 c3                	mov    %eax,%ebx
f0103b56:	eb f0                	jmp    f0103b48 <vprintfmt+0x4bb>
				/* do nothing */;
			break;
		}
	}
}
f0103b58:	83 c4 5c             	add    $0x5c,%esp
f0103b5b:	5b                   	pop    %ebx
f0103b5c:	5e                   	pop    %esi
f0103b5d:	5f                   	pop    %edi
f0103b5e:	5d                   	pop    %ebp
f0103b5f:	c3                   	ret    

f0103b60 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103b60:	55                   	push   %ebp
f0103b61:	89 e5                	mov    %esp,%ebp
f0103b63:	83 ec 28             	sub    $0x28,%esp
f0103b66:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b69:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f0103b6c:	85 c0                	test   %eax,%eax
f0103b6e:	74 04                	je     f0103b74 <vsnprintf+0x14>
f0103b70:	85 d2                	test   %edx,%edx
f0103b72:	7f 07                	jg     f0103b7b <vsnprintf+0x1b>
f0103b74:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103b79:	eb 3b                	jmp    f0103bb6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103b7b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103b7e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0103b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103b85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103b8c:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b93:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b96:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b9a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103b9d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ba1:	c7 04 24 70 36 10 f0 	movl   $0xf0103670,(%esp)
f0103ba8:	e8 e0 fa ff ff       	call   f010368d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103bad:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103bb0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0103bb6:	c9                   	leave  
f0103bb7:	c3                   	ret    

f0103bb8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103bb8:	55                   	push   %ebp
f0103bb9:	89 e5                	mov    %esp,%ebp
f0103bbb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f0103bbe:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0103bc1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bc5:	8b 45 10             	mov    0x10(%ebp),%eax
f0103bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bd3:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bd6:	89 04 24             	mov    %eax,(%esp)
f0103bd9:	e8 82 ff ff ff       	call   f0103b60 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103bde:	c9                   	leave  
f0103bdf:	c3                   	ret    

f0103be0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103be0:	55                   	push   %ebp
f0103be1:	89 e5                	mov    %esp,%ebp
f0103be3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0103be6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0103be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103bed:	8b 45 10             	mov    0x10(%ebp),%eax
f0103bf0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103bf7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bfb:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bfe:	89 04 24             	mov    %eax,(%esp)
f0103c01:	e8 87 fa ff ff       	call   f010368d <vprintfmt>
	va_end(ap);
}
f0103c06:	c9                   	leave  
f0103c07:	c3                   	ret    
	...

f0103c10 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103c10:	55                   	push   %ebp
f0103c11:	89 e5                	mov    %esp,%ebp
f0103c13:	57                   	push   %edi
f0103c14:	56                   	push   %esi
f0103c15:	53                   	push   %ebx
f0103c16:	83 ec 1c             	sub    $0x1c,%esp
f0103c19:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103c1c:	85 c0                	test   %eax,%eax
f0103c1e:	74 10                	je     f0103c30 <readline+0x20>
		cprintf("%s", prompt);
f0103c20:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c24:	c7 04 24 4c 50 10 f0 	movl   $0xf010504c,(%esp)
f0103c2b:	e8 87 f5 ff ff       	call   f01031b7 <cprintf>

	i = 0;
	echoing = iscons(0);
f0103c30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103c37:	e8 b4 c6 ff ff       	call   f01002f0 <iscons>
f0103c3c:	89 c7                	mov    %eax,%edi
f0103c3e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0103c43:	e8 97 c6 ff ff       	call   f01002df <getchar>
f0103c48:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103c4a:	85 c0                	test   %eax,%eax
f0103c4c:	79 17                	jns    f0103c65 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c52:	c7 04 24 d0 55 10 f0 	movl   $0xf01055d0,(%esp)
f0103c59:	e8 59 f5 ff ff       	call   f01031b7 <cprintf>
f0103c5e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0103c63:	eb 76                	jmp    f0103cdb <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103c65:	83 f8 08             	cmp    $0x8,%eax
f0103c68:	74 08                	je     f0103c72 <readline+0x62>
f0103c6a:	83 f8 7f             	cmp    $0x7f,%eax
f0103c6d:	8d 76 00             	lea    0x0(%esi),%esi
f0103c70:	75 19                	jne    f0103c8b <readline+0x7b>
f0103c72:	85 f6                	test   %esi,%esi
f0103c74:	7e 15                	jle    f0103c8b <readline+0x7b>
			if (echoing)
f0103c76:	85 ff                	test   %edi,%edi
f0103c78:	74 0c                	je     f0103c86 <readline+0x76>
				cputchar('\b');
f0103c7a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103c81:	e8 74 c8 ff ff       	call   f01004fa <cputchar>
			i--;
f0103c86:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103c89:	eb b8                	jmp    f0103c43 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103c8b:	83 fb 1f             	cmp    $0x1f,%ebx
f0103c8e:	66 90                	xchg   %ax,%ax
f0103c90:	7e 23                	jle    f0103cb5 <readline+0xa5>
f0103c92:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103c98:	7f 1b                	jg     f0103cb5 <readline+0xa5>
			if (echoing)
f0103c9a:	85 ff                	test   %edi,%edi
f0103c9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103ca0:	74 08                	je     f0103caa <readline+0x9a>
				cputchar(c);
f0103ca2:	89 1c 24             	mov    %ebx,(%esp)
f0103ca5:	e8 50 c8 ff ff       	call   f01004fa <cputchar>
			buf[i++] = c;
f0103caa:	88 9e 60 85 11 f0    	mov    %bl,-0xfee7aa0(%esi)
f0103cb0:	83 c6 01             	add    $0x1,%esi
f0103cb3:	eb 8e                	jmp    f0103c43 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103cb5:	83 fb 0a             	cmp    $0xa,%ebx
f0103cb8:	74 05                	je     f0103cbf <readline+0xaf>
f0103cba:	83 fb 0d             	cmp    $0xd,%ebx
f0103cbd:	75 84                	jne    f0103c43 <readline+0x33>
			if (echoing)
f0103cbf:	85 ff                	test   %edi,%edi
f0103cc1:	74 0c                	je     f0103ccf <readline+0xbf>
				cputchar('\n');
f0103cc3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103cca:	e8 2b c8 ff ff       	call   f01004fa <cputchar>
			buf[i] = 0;
f0103ccf:	c6 86 60 85 11 f0 00 	movb   $0x0,-0xfee7aa0(%esi)
f0103cd6:	b8 60 85 11 f0       	mov    $0xf0118560,%eax
			return buf;
		}
	}
}
f0103cdb:	83 c4 1c             	add    $0x1c,%esp
f0103cde:	5b                   	pop    %ebx
f0103cdf:	5e                   	pop    %esi
f0103ce0:	5f                   	pop    %edi
f0103ce1:	5d                   	pop    %ebp
f0103ce2:	c3                   	ret    
	...

f0103cf0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103cf0:	55                   	push   %ebp
f0103cf1:	89 e5                	mov    %esp,%ebp
f0103cf3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103cf6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103cfb:	80 3a 00             	cmpb   $0x0,(%edx)
f0103cfe:	74 09                	je     f0103d09 <strlen+0x19>
		n++;
f0103d00:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103d03:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103d07:	75 f7                	jne    f0103d00 <strlen+0x10>
		n++;
	return n;
}
f0103d09:	5d                   	pop    %ebp
f0103d0a:	c3                   	ret    

f0103d0b <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103d0b:	55                   	push   %ebp
f0103d0c:	89 e5                	mov    %esp,%ebp
f0103d0e:	53                   	push   %ebx
f0103d0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103d15:	85 c9                	test   %ecx,%ecx
f0103d17:	74 19                	je     f0103d32 <strnlen+0x27>
f0103d19:	80 3b 00             	cmpb   $0x0,(%ebx)
f0103d1c:	74 14                	je     f0103d32 <strnlen+0x27>
f0103d1e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0103d23:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103d26:	39 c8                	cmp    %ecx,%eax
f0103d28:	74 0d                	je     f0103d37 <strnlen+0x2c>
f0103d2a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f0103d2e:	75 f3                	jne    f0103d23 <strnlen+0x18>
f0103d30:	eb 05                	jmp    f0103d37 <strnlen+0x2c>
f0103d32:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0103d37:	5b                   	pop    %ebx
f0103d38:	5d                   	pop    %ebp
f0103d39:	c3                   	ret    

f0103d3a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103d3a:	55                   	push   %ebp
f0103d3b:	89 e5                	mov    %esp,%ebp
f0103d3d:	53                   	push   %ebx
f0103d3e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d41:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103d44:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103d49:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0103d4d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103d50:	83 c2 01             	add    $0x1,%edx
f0103d53:	84 c9                	test   %cl,%cl
f0103d55:	75 f2                	jne    f0103d49 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0103d57:	5b                   	pop    %ebx
f0103d58:	5d                   	pop    %ebp
f0103d59:	c3                   	ret    

f0103d5a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103d5a:	55                   	push   %ebp
f0103d5b:	89 e5                	mov    %esp,%ebp
f0103d5d:	56                   	push   %esi
f0103d5e:	53                   	push   %ebx
f0103d5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d62:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d65:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103d68:	85 f6                	test   %esi,%esi
f0103d6a:	74 18                	je     f0103d84 <strncpy+0x2a>
f0103d6c:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0103d71:	0f b6 1a             	movzbl (%edx),%ebx
f0103d74:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103d77:	80 3a 01             	cmpb   $0x1,(%edx)
f0103d7a:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103d7d:	83 c1 01             	add    $0x1,%ecx
f0103d80:	39 ce                	cmp    %ecx,%esi
f0103d82:	77 ed                	ja     f0103d71 <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103d84:	5b                   	pop    %ebx
f0103d85:	5e                   	pop    %esi
f0103d86:	5d                   	pop    %ebp
f0103d87:	c3                   	ret    

f0103d88 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103d88:	55                   	push   %ebp
f0103d89:	89 e5                	mov    %esp,%ebp
f0103d8b:	56                   	push   %esi
f0103d8c:	53                   	push   %ebx
f0103d8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d90:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103d93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103d96:	89 f0                	mov    %esi,%eax
f0103d98:	85 c9                	test   %ecx,%ecx
f0103d9a:	74 27                	je     f0103dc3 <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0103d9c:	83 e9 01             	sub    $0x1,%ecx
f0103d9f:	74 1d                	je     f0103dbe <strlcpy+0x36>
f0103da1:	0f b6 1a             	movzbl (%edx),%ebx
f0103da4:	84 db                	test   %bl,%bl
f0103da6:	74 16                	je     f0103dbe <strlcpy+0x36>
			*dst++ = *src++;
f0103da8:	88 18                	mov    %bl,(%eax)
f0103daa:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103dad:	83 e9 01             	sub    $0x1,%ecx
f0103db0:	74 0e                	je     f0103dc0 <strlcpy+0x38>
			*dst++ = *src++;
f0103db2:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103db5:	0f b6 1a             	movzbl (%edx),%ebx
f0103db8:	84 db                	test   %bl,%bl
f0103dba:	75 ec                	jne    f0103da8 <strlcpy+0x20>
f0103dbc:	eb 02                	jmp    f0103dc0 <strlcpy+0x38>
f0103dbe:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f0103dc0:	c6 00 00             	movb   $0x0,(%eax)
f0103dc3:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0103dc5:	5b                   	pop    %ebx
f0103dc6:	5e                   	pop    %esi
f0103dc7:	5d                   	pop    %ebp
f0103dc8:	c3                   	ret    

f0103dc9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103dc9:	55                   	push   %ebp
f0103dca:	89 e5                	mov    %esp,%ebp
f0103dcc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103dcf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103dd2:	0f b6 01             	movzbl (%ecx),%eax
f0103dd5:	84 c0                	test   %al,%al
f0103dd7:	74 15                	je     f0103dee <strcmp+0x25>
f0103dd9:	3a 02                	cmp    (%edx),%al
f0103ddb:	75 11                	jne    f0103dee <strcmp+0x25>
		p++, q++;
f0103ddd:	83 c1 01             	add    $0x1,%ecx
f0103de0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103de3:	0f b6 01             	movzbl (%ecx),%eax
f0103de6:	84 c0                	test   %al,%al
f0103de8:	74 04                	je     f0103dee <strcmp+0x25>
f0103dea:	3a 02                	cmp    (%edx),%al
f0103dec:	74 ef                	je     f0103ddd <strcmp+0x14>
f0103dee:	0f b6 c0             	movzbl %al,%eax
f0103df1:	0f b6 12             	movzbl (%edx),%edx
f0103df4:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103df6:	5d                   	pop    %ebp
f0103df7:	c3                   	ret    

f0103df8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103df8:	55                   	push   %ebp
f0103df9:	89 e5                	mov    %esp,%ebp
f0103dfb:	53                   	push   %ebx
f0103dfc:	8b 55 08             	mov    0x8(%ebp),%edx
f0103dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103e02:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0103e05:	85 c0                	test   %eax,%eax
f0103e07:	74 23                	je     f0103e2c <strncmp+0x34>
f0103e09:	0f b6 1a             	movzbl (%edx),%ebx
f0103e0c:	84 db                	test   %bl,%bl
f0103e0e:	74 24                	je     f0103e34 <strncmp+0x3c>
f0103e10:	3a 19                	cmp    (%ecx),%bl
f0103e12:	75 20                	jne    f0103e34 <strncmp+0x3c>
f0103e14:	83 e8 01             	sub    $0x1,%eax
f0103e17:	74 13                	je     f0103e2c <strncmp+0x34>
		n--, p++, q++;
f0103e19:	83 c2 01             	add    $0x1,%edx
f0103e1c:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103e1f:	0f b6 1a             	movzbl (%edx),%ebx
f0103e22:	84 db                	test   %bl,%bl
f0103e24:	74 0e                	je     f0103e34 <strncmp+0x3c>
f0103e26:	3a 19                	cmp    (%ecx),%bl
f0103e28:	74 ea                	je     f0103e14 <strncmp+0x1c>
f0103e2a:	eb 08                	jmp    f0103e34 <strncmp+0x3c>
f0103e2c:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103e31:	5b                   	pop    %ebx
f0103e32:	5d                   	pop    %ebp
f0103e33:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103e34:	0f b6 02             	movzbl (%edx),%eax
f0103e37:	0f b6 11             	movzbl (%ecx),%edx
f0103e3a:	29 d0                	sub    %edx,%eax
f0103e3c:	eb f3                	jmp    f0103e31 <strncmp+0x39>

f0103e3e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103e3e:	55                   	push   %ebp
f0103e3f:	89 e5                	mov    %esp,%ebp
f0103e41:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103e48:	0f b6 10             	movzbl (%eax),%edx
f0103e4b:	84 d2                	test   %dl,%dl
f0103e4d:	74 15                	je     f0103e64 <strchr+0x26>
		if (*s == c)
f0103e4f:	38 ca                	cmp    %cl,%dl
f0103e51:	75 07                	jne    f0103e5a <strchr+0x1c>
f0103e53:	eb 14                	jmp    f0103e69 <strchr+0x2b>
f0103e55:	38 ca                	cmp    %cl,%dl
f0103e57:	90                   	nop
f0103e58:	74 0f                	je     f0103e69 <strchr+0x2b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103e5a:	83 c0 01             	add    $0x1,%eax
f0103e5d:	0f b6 10             	movzbl (%eax),%edx
f0103e60:	84 d2                	test   %dl,%dl
f0103e62:	75 f1                	jne    f0103e55 <strchr+0x17>
f0103e64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0103e69:	5d                   	pop    %ebp
f0103e6a:	c3                   	ret    

f0103e6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103e6b:	55                   	push   %ebp
f0103e6c:	89 e5                	mov    %esp,%ebp
f0103e6e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103e75:	0f b6 10             	movzbl (%eax),%edx
f0103e78:	84 d2                	test   %dl,%dl
f0103e7a:	74 18                	je     f0103e94 <strfind+0x29>
		if (*s == c)
f0103e7c:	38 ca                	cmp    %cl,%dl
f0103e7e:	75 0a                	jne    f0103e8a <strfind+0x1f>
f0103e80:	eb 12                	jmp    f0103e94 <strfind+0x29>
f0103e82:	38 ca                	cmp    %cl,%dl
f0103e84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103e88:	74 0a                	je     f0103e94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103e8a:	83 c0 01             	add    $0x1,%eax
f0103e8d:	0f b6 10             	movzbl (%eax),%edx
f0103e90:	84 d2                	test   %dl,%dl
f0103e92:	75 ee                	jne    f0103e82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0103e94:	5d                   	pop    %ebp
f0103e95:	c3                   	ret    

f0103e96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103e96:	55                   	push   %ebp
f0103e97:	89 e5                	mov    %esp,%ebp
f0103e99:	83 ec 0c             	sub    $0xc,%esp
f0103e9c:	89 1c 24             	mov    %ebx,(%esp)
f0103e9f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103ea3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0103ea7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ead:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103eb0:	85 c9                	test   %ecx,%ecx
f0103eb2:	74 30                	je     f0103ee4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103eb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103eba:	75 25                	jne    f0103ee1 <memset+0x4b>
f0103ebc:	f6 c1 03             	test   $0x3,%cl
f0103ebf:	75 20                	jne    f0103ee1 <memset+0x4b>
		c &= 0xFF;
f0103ec1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103ec4:	89 d3                	mov    %edx,%ebx
f0103ec6:	c1 e3 08             	shl    $0x8,%ebx
f0103ec9:	89 d6                	mov    %edx,%esi
f0103ecb:	c1 e6 18             	shl    $0x18,%esi
f0103ece:	89 d0                	mov    %edx,%eax
f0103ed0:	c1 e0 10             	shl    $0x10,%eax
f0103ed3:	09 f0                	or     %esi,%eax
f0103ed5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f0103ed7:	09 d8                	or     %ebx,%eax
f0103ed9:	c1 e9 02             	shr    $0x2,%ecx
f0103edc:	fc                   	cld    
f0103edd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103edf:	eb 03                	jmp    f0103ee4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103ee1:	fc                   	cld    
f0103ee2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103ee4:	89 f8                	mov    %edi,%eax
f0103ee6:	8b 1c 24             	mov    (%esp),%ebx
f0103ee9:	8b 74 24 04          	mov    0x4(%esp),%esi
f0103eed:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0103ef1:	89 ec                	mov    %ebp,%esp
f0103ef3:	5d                   	pop    %ebp
f0103ef4:	c3                   	ret    

f0103ef5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103ef5:	55                   	push   %ebp
f0103ef6:	89 e5                	mov    %esp,%ebp
f0103ef8:	83 ec 08             	sub    $0x8,%esp
f0103efb:	89 34 24             	mov    %esi,(%esp)
f0103efe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103f02:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0103f08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f0103f0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f0103f0d:	39 c6                	cmp    %eax,%esi
f0103f0f:	73 35                	jae    f0103f46 <memmove+0x51>
f0103f11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103f14:	39 d0                	cmp    %edx,%eax
f0103f16:	73 2e                	jae    f0103f46 <memmove+0x51>
		s += n;
		d += n;
f0103f18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103f1a:	f6 c2 03             	test   $0x3,%dl
f0103f1d:	75 1b                	jne    f0103f3a <memmove+0x45>
f0103f1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103f25:	75 13                	jne    f0103f3a <memmove+0x45>
f0103f27:	f6 c1 03             	test   $0x3,%cl
f0103f2a:	75 0e                	jne    f0103f3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f0103f2c:	83 ef 04             	sub    $0x4,%edi
f0103f2f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103f32:	c1 e9 02             	shr    $0x2,%ecx
f0103f35:	fd                   	std    
f0103f36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103f38:	eb 09                	jmp    f0103f43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103f3a:	83 ef 01             	sub    $0x1,%edi
f0103f3d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0103f40:	fd                   	std    
f0103f41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0103f43:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103f44:	eb 20                	jmp    f0103f66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103f46:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103f4c:	75 15                	jne    f0103f63 <memmove+0x6e>
f0103f4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103f54:	75 0d                	jne    f0103f63 <memmove+0x6e>
f0103f56:	f6 c1 03             	test   $0x3,%cl
f0103f59:	75 08                	jne    f0103f63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0103f5b:	c1 e9 02             	shr    $0x2,%ecx
f0103f5e:	fc                   	cld    
f0103f5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103f61:	eb 03                	jmp    f0103f66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103f63:	fc                   	cld    
f0103f64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103f66:	8b 34 24             	mov    (%esp),%esi
f0103f69:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103f6d:	89 ec                	mov    %ebp,%esp
f0103f6f:	5d                   	pop    %ebp
f0103f70:	c3                   	ret    

f0103f71 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0103f71:	55                   	push   %ebp
f0103f72:	89 e5                	mov    %esp,%ebp
f0103f74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0103f77:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f7a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f7e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f85:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f88:	89 04 24             	mov    %eax,(%esp)
f0103f8b:	e8 65 ff ff ff       	call   f0103ef5 <memmove>
}
f0103f90:	c9                   	leave  
f0103f91:	c3                   	ret    

f0103f92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103f92:	55                   	push   %ebp
f0103f93:	89 e5                	mov    %esp,%ebp
f0103f95:	57                   	push   %edi
f0103f96:	56                   	push   %esi
f0103f97:	53                   	push   %ebx
f0103f98:	8b 75 08             	mov    0x8(%ebp),%esi
f0103f9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0103f9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103fa1:	85 c9                	test   %ecx,%ecx
f0103fa3:	74 36                	je     f0103fdb <memcmp+0x49>
		if (*s1 != *s2)
f0103fa5:	0f b6 06             	movzbl (%esi),%eax
f0103fa8:	0f b6 1f             	movzbl (%edi),%ebx
f0103fab:	38 d8                	cmp    %bl,%al
f0103fad:	74 20                	je     f0103fcf <memcmp+0x3d>
f0103faf:	eb 14                	jmp    f0103fc5 <memcmp+0x33>
f0103fb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0103fb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0103fbb:	83 c2 01             	add    $0x1,%edx
f0103fbe:	83 e9 01             	sub    $0x1,%ecx
f0103fc1:	38 d8                	cmp    %bl,%al
f0103fc3:	74 12                	je     f0103fd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0103fc5:	0f b6 c0             	movzbl %al,%eax
f0103fc8:	0f b6 db             	movzbl %bl,%ebx
f0103fcb:	29 d8                	sub    %ebx,%eax
f0103fcd:	eb 11                	jmp    f0103fe0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103fcf:	83 e9 01             	sub    $0x1,%ecx
f0103fd2:	ba 00 00 00 00       	mov    $0x0,%edx
f0103fd7:	85 c9                	test   %ecx,%ecx
f0103fd9:	75 d6                	jne    f0103fb1 <memcmp+0x1f>
f0103fdb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0103fe0:	5b                   	pop    %ebx
f0103fe1:	5e                   	pop    %esi
f0103fe2:	5f                   	pop    %edi
f0103fe3:	5d                   	pop    %ebp
f0103fe4:	c3                   	ret    

f0103fe5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103fe5:	55                   	push   %ebp
f0103fe6:	89 e5                	mov    %esp,%ebp
f0103fe8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0103feb:	89 c2                	mov    %eax,%edx
f0103fed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0103ff0:	39 d0                	cmp    %edx,%eax
f0103ff2:	73 15                	jae    f0104009 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103ff4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0103ff8:	38 08                	cmp    %cl,(%eax)
f0103ffa:	75 06                	jne    f0104002 <memfind+0x1d>
f0103ffc:	eb 0b                	jmp    f0104009 <memfind+0x24>
f0103ffe:	38 08                	cmp    %cl,(%eax)
f0104000:	74 07                	je     f0104009 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104002:	83 c0 01             	add    $0x1,%eax
f0104005:	39 c2                	cmp    %eax,%edx
f0104007:	77 f5                	ja     f0103ffe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104009:	5d                   	pop    %ebp
f010400a:	c3                   	ret    

f010400b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010400b:	55                   	push   %ebp
f010400c:	89 e5                	mov    %esp,%ebp
f010400e:	57                   	push   %edi
f010400f:	56                   	push   %esi
f0104010:	53                   	push   %ebx
f0104011:	83 ec 04             	sub    $0x4,%esp
f0104014:	8b 55 08             	mov    0x8(%ebp),%edx
f0104017:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010401a:	0f b6 02             	movzbl (%edx),%eax
f010401d:	3c 20                	cmp    $0x20,%al
f010401f:	74 04                	je     f0104025 <strtol+0x1a>
f0104021:	3c 09                	cmp    $0x9,%al
f0104023:	75 0e                	jne    f0104033 <strtol+0x28>
		s++;
f0104025:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104028:	0f b6 02             	movzbl (%edx),%eax
f010402b:	3c 20                	cmp    $0x20,%al
f010402d:	74 f6                	je     f0104025 <strtol+0x1a>
f010402f:	3c 09                	cmp    $0x9,%al
f0104031:	74 f2                	je     f0104025 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104033:	3c 2b                	cmp    $0x2b,%al
f0104035:	75 0c                	jne    f0104043 <strtol+0x38>
		s++;
f0104037:	83 c2 01             	add    $0x1,%edx
f010403a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0104041:	eb 15                	jmp    f0104058 <strtol+0x4d>
	else if (*s == '-')
f0104043:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010404a:	3c 2d                	cmp    $0x2d,%al
f010404c:	75 0a                	jne    f0104058 <strtol+0x4d>
		s++, neg = 1;
f010404e:	83 c2 01             	add    $0x1,%edx
f0104051:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104058:	85 db                	test   %ebx,%ebx
f010405a:	0f 94 c0             	sete   %al
f010405d:	74 05                	je     f0104064 <strtol+0x59>
f010405f:	83 fb 10             	cmp    $0x10,%ebx
f0104062:	75 18                	jne    f010407c <strtol+0x71>
f0104064:	80 3a 30             	cmpb   $0x30,(%edx)
f0104067:	75 13                	jne    f010407c <strtol+0x71>
f0104069:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010406d:	8d 76 00             	lea    0x0(%esi),%esi
f0104070:	75 0a                	jne    f010407c <strtol+0x71>
		s += 2, base = 16;
f0104072:	83 c2 02             	add    $0x2,%edx
f0104075:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010407a:	eb 15                	jmp    f0104091 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010407c:	84 c0                	test   %al,%al
f010407e:	66 90                	xchg   %ax,%ax
f0104080:	74 0f                	je     f0104091 <strtol+0x86>
f0104082:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104087:	80 3a 30             	cmpb   $0x30,(%edx)
f010408a:	75 05                	jne    f0104091 <strtol+0x86>
		s++, base = 8;
f010408c:	83 c2 01             	add    $0x1,%edx
f010408f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104091:	b8 00 00 00 00       	mov    $0x0,%eax
f0104096:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104098:	0f b6 0a             	movzbl (%edx),%ecx
f010409b:	89 cf                	mov    %ecx,%edi
f010409d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01040a0:	80 fb 09             	cmp    $0x9,%bl
f01040a3:	77 08                	ja     f01040ad <strtol+0xa2>
			dig = *s - '0';
f01040a5:	0f be c9             	movsbl %cl,%ecx
f01040a8:	83 e9 30             	sub    $0x30,%ecx
f01040ab:	eb 1e                	jmp    f01040cb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f01040ad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f01040b0:	80 fb 19             	cmp    $0x19,%bl
f01040b3:	77 08                	ja     f01040bd <strtol+0xb2>
			dig = *s - 'a' + 10;
f01040b5:	0f be c9             	movsbl %cl,%ecx
f01040b8:	83 e9 57             	sub    $0x57,%ecx
f01040bb:	eb 0e                	jmp    f01040cb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f01040bd:	8d 5f bf             	lea    -0x41(%edi),%ebx
f01040c0:	80 fb 19             	cmp    $0x19,%bl
f01040c3:	77 15                	ja     f01040da <strtol+0xcf>
			dig = *s - 'A' + 10;
f01040c5:	0f be c9             	movsbl %cl,%ecx
f01040c8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01040cb:	39 f1                	cmp    %esi,%ecx
f01040cd:	7d 0b                	jge    f01040da <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f01040cf:	83 c2 01             	add    $0x1,%edx
f01040d2:	0f af c6             	imul   %esi,%eax
f01040d5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01040d8:	eb be                	jmp    f0104098 <strtol+0x8d>
f01040da:	89 c1                	mov    %eax,%ecx

	if (endptr)
f01040dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01040e0:	74 05                	je     f01040e7 <strtol+0xdc>
		*endptr = (char *) s;
f01040e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01040e5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01040e7:	89 ca                	mov    %ecx,%edx
f01040e9:	f7 da                	neg    %edx
f01040eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01040ef:	0f 45 c2             	cmovne %edx,%eax
}
f01040f2:	83 c4 04             	add    $0x4,%esp
f01040f5:	5b                   	pop    %ebx
f01040f6:	5e                   	pop    %esi
f01040f7:	5f                   	pop    %edi
f01040f8:	5d                   	pop    %ebp
f01040f9:	c3                   	ret    
f01040fa:	00 00                	add    %al,(%eax)
f01040fc:	00 00                	add    %al,(%eax)
	...

f0104100 <__udivdi3>:
f0104100:	55                   	push   %ebp
f0104101:	89 e5                	mov    %esp,%ebp
f0104103:	57                   	push   %edi
f0104104:	56                   	push   %esi
f0104105:	83 ec 10             	sub    $0x10,%esp
f0104108:	8b 45 14             	mov    0x14(%ebp),%eax
f010410b:	8b 55 08             	mov    0x8(%ebp),%edx
f010410e:	8b 75 10             	mov    0x10(%ebp),%esi
f0104111:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104114:	85 c0                	test   %eax,%eax
f0104116:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0104119:	75 35                	jne    f0104150 <__udivdi3+0x50>
f010411b:	39 fe                	cmp    %edi,%esi
f010411d:	77 61                	ja     f0104180 <__udivdi3+0x80>
f010411f:	85 f6                	test   %esi,%esi
f0104121:	75 0b                	jne    f010412e <__udivdi3+0x2e>
f0104123:	b8 01 00 00 00       	mov    $0x1,%eax
f0104128:	31 d2                	xor    %edx,%edx
f010412a:	f7 f6                	div    %esi
f010412c:	89 c6                	mov    %eax,%esi
f010412e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104131:	31 d2                	xor    %edx,%edx
f0104133:	89 f8                	mov    %edi,%eax
f0104135:	f7 f6                	div    %esi
f0104137:	89 c7                	mov    %eax,%edi
f0104139:	89 c8                	mov    %ecx,%eax
f010413b:	f7 f6                	div    %esi
f010413d:	89 c1                	mov    %eax,%ecx
f010413f:	89 fa                	mov    %edi,%edx
f0104141:	89 c8                	mov    %ecx,%eax
f0104143:	83 c4 10             	add    $0x10,%esp
f0104146:	5e                   	pop    %esi
f0104147:	5f                   	pop    %edi
f0104148:	5d                   	pop    %ebp
f0104149:	c3                   	ret    
f010414a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104150:	39 f8                	cmp    %edi,%eax
f0104152:	77 1c                	ja     f0104170 <__udivdi3+0x70>
f0104154:	0f bd d0             	bsr    %eax,%edx
f0104157:	83 f2 1f             	xor    $0x1f,%edx
f010415a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010415d:	75 39                	jne    f0104198 <__udivdi3+0x98>
f010415f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104162:	0f 86 a0 00 00 00    	jbe    f0104208 <__udivdi3+0x108>
f0104168:	39 f8                	cmp    %edi,%eax
f010416a:	0f 82 98 00 00 00    	jb     f0104208 <__udivdi3+0x108>
f0104170:	31 ff                	xor    %edi,%edi
f0104172:	31 c9                	xor    %ecx,%ecx
f0104174:	89 c8                	mov    %ecx,%eax
f0104176:	89 fa                	mov    %edi,%edx
f0104178:	83 c4 10             	add    $0x10,%esp
f010417b:	5e                   	pop    %esi
f010417c:	5f                   	pop    %edi
f010417d:	5d                   	pop    %ebp
f010417e:	c3                   	ret    
f010417f:	90                   	nop
f0104180:	89 d1                	mov    %edx,%ecx
f0104182:	89 fa                	mov    %edi,%edx
f0104184:	89 c8                	mov    %ecx,%eax
f0104186:	31 ff                	xor    %edi,%edi
f0104188:	f7 f6                	div    %esi
f010418a:	89 c1                	mov    %eax,%ecx
f010418c:	89 fa                	mov    %edi,%edx
f010418e:	89 c8                	mov    %ecx,%eax
f0104190:	83 c4 10             	add    $0x10,%esp
f0104193:	5e                   	pop    %esi
f0104194:	5f                   	pop    %edi
f0104195:	5d                   	pop    %ebp
f0104196:	c3                   	ret    
f0104197:	90                   	nop
f0104198:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010419c:	89 f2                	mov    %esi,%edx
f010419e:	d3 e0                	shl    %cl,%eax
f01041a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01041a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01041a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f01041ab:	89 c1                	mov    %eax,%ecx
f01041ad:	d3 ea                	shr    %cl,%edx
f01041af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01041b3:	0b 55 ec             	or     -0x14(%ebp),%edx
f01041b6:	d3 e6                	shl    %cl,%esi
f01041b8:	89 c1                	mov    %eax,%ecx
f01041ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
f01041bd:	89 fe                	mov    %edi,%esi
f01041bf:	d3 ee                	shr    %cl,%esi
f01041c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01041c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01041c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01041cb:	d3 e7                	shl    %cl,%edi
f01041cd:	89 c1                	mov    %eax,%ecx
f01041cf:	d3 ea                	shr    %cl,%edx
f01041d1:	09 d7                	or     %edx,%edi
f01041d3:	89 f2                	mov    %esi,%edx
f01041d5:	89 f8                	mov    %edi,%eax
f01041d7:	f7 75 ec             	divl   -0x14(%ebp)
f01041da:	89 d6                	mov    %edx,%esi
f01041dc:	89 c7                	mov    %eax,%edi
f01041de:	f7 65 e8             	mull   -0x18(%ebp)
f01041e1:	39 d6                	cmp    %edx,%esi
f01041e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01041e6:	72 30                	jb     f0104218 <__udivdi3+0x118>
f01041e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01041eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01041ef:	d3 e2                	shl    %cl,%edx
f01041f1:	39 c2                	cmp    %eax,%edx
f01041f3:	73 05                	jae    f01041fa <__udivdi3+0xfa>
f01041f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01041f8:	74 1e                	je     f0104218 <__udivdi3+0x118>
f01041fa:	89 f9                	mov    %edi,%ecx
f01041fc:	31 ff                	xor    %edi,%edi
f01041fe:	e9 71 ff ff ff       	jmp    f0104174 <__udivdi3+0x74>
f0104203:	90                   	nop
f0104204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104208:	31 ff                	xor    %edi,%edi
f010420a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010420f:	e9 60 ff ff ff       	jmp    f0104174 <__udivdi3+0x74>
f0104214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104218:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010421b:	31 ff                	xor    %edi,%edi
f010421d:	89 c8                	mov    %ecx,%eax
f010421f:	89 fa                	mov    %edi,%edx
f0104221:	83 c4 10             	add    $0x10,%esp
f0104224:	5e                   	pop    %esi
f0104225:	5f                   	pop    %edi
f0104226:	5d                   	pop    %ebp
f0104227:	c3                   	ret    
	...

f0104230 <__umoddi3>:
f0104230:	55                   	push   %ebp
f0104231:	89 e5                	mov    %esp,%ebp
f0104233:	57                   	push   %edi
f0104234:	56                   	push   %esi
f0104235:	83 ec 20             	sub    $0x20,%esp
f0104238:	8b 55 14             	mov    0x14(%ebp),%edx
f010423b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010423e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104241:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104244:	85 d2                	test   %edx,%edx
f0104246:	89 c8                	mov    %ecx,%eax
f0104248:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010424b:	75 13                	jne    f0104260 <__umoddi3+0x30>
f010424d:	39 f7                	cmp    %esi,%edi
f010424f:	76 3f                	jbe    f0104290 <__umoddi3+0x60>
f0104251:	89 f2                	mov    %esi,%edx
f0104253:	f7 f7                	div    %edi
f0104255:	89 d0                	mov    %edx,%eax
f0104257:	31 d2                	xor    %edx,%edx
f0104259:	83 c4 20             	add    $0x20,%esp
f010425c:	5e                   	pop    %esi
f010425d:	5f                   	pop    %edi
f010425e:	5d                   	pop    %ebp
f010425f:	c3                   	ret    
f0104260:	39 f2                	cmp    %esi,%edx
f0104262:	77 4c                	ja     f01042b0 <__umoddi3+0x80>
f0104264:	0f bd ca             	bsr    %edx,%ecx
f0104267:	83 f1 1f             	xor    $0x1f,%ecx
f010426a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010426d:	75 51                	jne    f01042c0 <__umoddi3+0x90>
f010426f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0104272:	0f 87 e0 00 00 00    	ja     f0104358 <__umoddi3+0x128>
f0104278:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010427b:	29 f8                	sub    %edi,%eax
f010427d:	19 d6                	sbb    %edx,%esi
f010427f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0104282:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104285:	89 f2                	mov    %esi,%edx
f0104287:	83 c4 20             	add    $0x20,%esp
f010428a:	5e                   	pop    %esi
f010428b:	5f                   	pop    %edi
f010428c:	5d                   	pop    %ebp
f010428d:	c3                   	ret    
f010428e:	66 90                	xchg   %ax,%ax
f0104290:	85 ff                	test   %edi,%edi
f0104292:	75 0b                	jne    f010429f <__umoddi3+0x6f>
f0104294:	b8 01 00 00 00       	mov    $0x1,%eax
f0104299:	31 d2                	xor    %edx,%edx
f010429b:	f7 f7                	div    %edi
f010429d:	89 c7                	mov    %eax,%edi
f010429f:	89 f0                	mov    %esi,%eax
f01042a1:	31 d2                	xor    %edx,%edx
f01042a3:	f7 f7                	div    %edi
f01042a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01042a8:	f7 f7                	div    %edi
f01042aa:	eb a9                	jmp    f0104255 <__umoddi3+0x25>
f01042ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01042b0:	89 c8                	mov    %ecx,%eax
f01042b2:	89 f2                	mov    %esi,%edx
f01042b4:	83 c4 20             	add    $0x20,%esp
f01042b7:	5e                   	pop    %esi
f01042b8:	5f                   	pop    %edi
f01042b9:	5d                   	pop    %ebp
f01042ba:	c3                   	ret    
f01042bb:	90                   	nop
f01042bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01042c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01042c4:	d3 e2                	shl    %cl,%edx
f01042c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01042c9:	ba 20 00 00 00       	mov    $0x20,%edx
f01042ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
f01042d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01042d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01042d8:	89 fa                	mov    %edi,%edx
f01042da:	d3 ea                	shr    %cl,%edx
f01042dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01042e0:	0b 55 f4             	or     -0xc(%ebp),%edx
f01042e3:	d3 e7                	shl    %cl,%edi
f01042e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01042e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01042ec:	89 f2                	mov    %esi,%edx
f01042ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
f01042f1:	89 c7                	mov    %eax,%edi
f01042f3:	d3 ea                	shr    %cl,%edx
f01042f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01042f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01042fc:	89 c2                	mov    %eax,%edx
f01042fe:	d3 e6                	shl    %cl,%esi
f0104300:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104304:	d3 ea                	shr    %cl,%edx
f0104306:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010430a:	09 d6                	or     %edx,%esi
f010430c:	89 f0                	mov    %esi,%eax
f010430e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104311:	d3 e7                	shl    %cl,%edi
f0104313:	89 f2                	mov    %esi,%edx
f0104315:	f7 75 f4             	divl   -0xc(%ebp)
f0104318:	89 d6                	mov    %edx,%esi
f010431a:	f7 65 e8             	mull   -0x18(%ebp)
f010431d:	39 d6                	cmp    %edx,%esi
f010431f:	72 2b                	jb     f010434c <__umoddi3+0x11c>
f0104321:	39 c7                	cmp    %eax,%edi
f0104323:	72 23                	jb     f0104348 <__umoddi3+0x118>
f0104325:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0104329:	29 c7                	sub    %eax,%edi
f010432b:	19 d6                	sbb    %edx,%esi
f010432d:	89 f0                	mov    %esi,%eax
f010432f:	89 f2                	mov    %esi,%edx
f0104331:	d3 ef                	shr    %cl,%edi
f0104333:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0104337:	d3 e0                	shl    %cl,%eax
f0104339:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010433d:	09 f8                	or     %edi,%eax
f010433f:	d3 ea                	shr    %cl,%edx
f0104341:	83 c4 20             	add    $0x20,%esp
f0104344:	5e                   	pop    %esi
f0104345:	5f                   	pop    %edi
f0104346:	5d                   	pop    %ebp
f0104347:	c3                   	ret    
f0104348:	39 d6                	cmp    %edx,%esi
f010434a:	75 d9                	jne    f0104325 <__umoddi3+0xf5>
f010434c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010434f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0104352:	eb d1                	jmp    f0104325 <__umoddi3+0xf5>
f0104354:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104358:	39 f2                	cmp    %esi,%edx
f010435a:	0f 82 18 ff ff ff    	jb     f0104278 <__umoddi3+0x48>
f0104360:	e9 1d ff ff ff       	jmp    f0104282 <__umoddi3+0x52>
