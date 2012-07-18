
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 39 01 00 00       	call   f0100177 <i386_init>

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
f0100058:	c7 04 24 80 76 10 f0 	movl   $0xf0107680,(%esp)
f010005f:	e8 97 43 00 00       	call   f01043fb <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 55 43 00 00       	call   f01043c8 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 b7 89 10 f0 	movl   $0xf01089b7,(%esp)
f010007a:	e8 7c 43 00 00       	call   f01043fb <cprintf>
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
f0100090:	83 3d 80 ce 1d f0 00 	cmpl   $0x0,0xf01dce80
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 80 ce 1d f0    	mov    %esi,0xf01dce80

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
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000a4:	e8 b9 6e 00 00       	call   f0106f62 <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 18 77 10 f0 	movl   $0xf0107718,(%esp)
f01000c2:	e8 34 43 00 00       	call   f01043fb <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 f5 42 00 00       	call   f01043c8 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 b7 89 10 f0 	movl   $0xf01089b7,(%esp)
f01000da:	e8 1c 43 00 00       	call   f01043fb <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 28 0a 00 00       	call   f0100b13 <monitor>
f01000eb:	eb f2                	jmp    f01000df <_panic+0x5a>

f01000ed <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000ed:	55                   	push   %ebp
f01000ee:	89 e5                	mov    %esp,%ebp
f01000f0:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000f3:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000f8:	89 c2                	mov    %eax,%edx
f01000fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000ff:	77 20                	ja     f0100121 <mp_main+0x34>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100101:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100105:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f010010c:	f0 
f010010d:	c7 44 24 04 8c 00 00 	movl   $0x8c,0x4(%esp)
f0100114:	00 
f0100115:	c7 04 24 9a 76 10 f0 	movl   $0xf010769a,(%esp)
f010011c:	e8 64 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100121:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100127:	0f 22 da             	mov    %edx,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010012a:	e8 33 6e 00 00       	call   f0106f62 <cpunum>
f010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100133:	c7 04 24 a6 76 10 f0 	movl   $0xf01076a6,(%esp)
f010013a:	e8 bc 42 00 00       	call   f01043fb <cprintf>

	lapic_init();
f010013f:	e8 3a 6e 00 00       	call   f0106f7e <lapic_init>
	env_init_percpu();
f0100144:	e8 e7 38 00 00       	call   f0103a30 <env_init_percpu>
	trap_init_percpu();
f0100149:	e8 f2 42 00 00       	call   f0104440 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014e:	66 90                	xchg   %ax,%ax
f0100150:	e8 0d 6e 00 00       	call   f0106f62 <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 d0 1d f0    	add    $0xf01dd024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010015e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100163:	f0 87 02             	lock xchg %eax,(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0100166:	c7 04 24 80 23 12 f0 	movl   $0xf0122380,(%esp)
f010016d:	e8 b3 71 00 00       	call   f0107325 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100172:	e8 99 50 00 00       	call   f0105210 <sched_yield>

f0100177 <i386_init>:



void
i386_init(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp
f010017a:	57                   	push   %edi
f010017b:	56                   	push   %esi
f010017c:	53                   	push   %ebx
f010017d:	81 ec 2c 01 00 00    	sub    $0x12c,%esp
	extern char edata[], end[];
        // Lab1 only
        char chnum1 = 0, chnum2 = 0, ntest[256] = {};
f0100183:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
f0100187:	c6 45 e6 00          	movb   $0x0,-0x1a(%ebp)
f010018b:	ba 00 01 00 00       	mov    $0x100,%edx
f0100190:	b8 00 00 00 00       	mov    $0x0,%eax
f0100195:	8d bd e6 fe ff ff    	lea    -0x11a(%ebp),%edi
f010019b:	66 89 07             	mov    %ax,(%edi)
f010019e:	83 c7 02             	add    $0x2,%edi
f01001a1:	83 ea 02             	sub    $0x2,%edx
f01001a4:	89 d1                	mov    %edx,%ecx
f01001a6:	c1 e9 02             	shr    $0x2,%ecx
f01001a9:	f3 ab                	rep stos %eax,%es:(%edi)
f01001ab:	f6 c2 02             	test   $0x2,%dl
f01001ae:	74 06                	je     f01001b6 <i386_init+0x3f>
f01001b0:	66 89 07             	mov    %ax,(%edi)
f01001b3:	83 c7 02             	add    $0x2,%edi
f01001b6:	83 e2 01             	and    $0x1,%edx
f01001b9:	85 d2                	test   %edx,%edx
f01001bb:	74 02                	je     f01001bf <i386_init+0x48>
f01001bd:	88 07                	mov    %al,(%edi)

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01001bf:	b8 04 e0 21 f0       	mov    $0xf021e004,%eax
f01001c4:	2d e4 b8 1d f0       	sub    $0xf01db8e4,%eax
f01001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d4:	00 
f01001d5:	c7 04 24 e4 b8 1d f0 	movl   $0xf01db8e4,(%esp)
f01001dc:	e8 d5 66 00 00       	call   f01068b6 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001e1:	e8 23 06 00 00       	call   f0100809 <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01001e6:	8d 45 e6             	lea    -0x1a(%ebp),%eax
f01001e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001ed:	8d 5d e7             	lea    -0x19(%ebp),%ebx
f01001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01001f4:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001fb:	00 
f01001fc:	c7 04 24 60 77 10 f0 	movl   $0xf0107760,(%esp)
f0100203:	e8 f3 41 00 00       	call   f01043fb <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f0100208:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f010020c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100210:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100214:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100218:	c7 04 24 bc 76 10 f0 	movl   $0xf01076bc,(%esp)
f010021f:	e8 d7 41 00 00       	call   f01043fb <cprintf>
	cprintf("%n", NULL);
f0100224:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010022b:	00 
f010022c:	c7 04 24 d5 76 10 f0 	movl   $0xf01076d5,(%esp)
f0100233:	e8 c3 41 00 00       	call   f01043fb <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100238:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f010023f:	00 
f0100240:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f0100247:	00 
f0100248:	8d b5 e6 fe ff ff    	lea    -0x11a(%ebp),%esi
f010024e:	89 34 24             	mov    %esi,(%esp)
f0100251:	e8 60 66 00 00       	call   f01068b6 <memset>
	cprintf("%s%n", ntest, &chnum1); 
f0100256:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010025a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010025e:	c7 04 24 d3 76 10 f0 	movl   $0xf01076d3,(%esp)
f0100265:	e8 91 41 00 00       	call   f01043fb <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010026a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010026e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100272:	c7 04 24 d8 76 10 f0 	movl   $0xf01076d8,(%esp)
f0100279:	e8 7d 41 00 00       	call   f01043fb <cprintf>



	extern unsigned char mpentry_start[];
	extern void mp_main(void);
	cprintf("mpentry_start address is %x\n", (int)mpentry_start);
f010027e:	c7 44 24 04 1c 6b 10 	movl   $0xf0106b1c,0x4(%esp)
f0100285:	f0 
f0100286:	c7 04 24 e4 76 10 f0 	movl   $0xf01076e4,(%esp)
f010028d:	e8 69 41 00 00       	call   f01043fb <cprintf>
	cprintf("mp_main address is %x\n", (int)mp_main);
f0100292:	c7 44 24 04 ed 00 10 	movl   $0xf01000ed,0x4(%esp)
f0100299:	f0 
f010029a:	c7 04 24 01 77 10 f0 	movl   $0xf0107701,(%esp)
f01002a1:	e8 55 41 00 00       	call   f01043fb <cprintf>
	// Lab 2 memory management initialization functions
	mem_init();
f01002a6:	e8 5b 25 00 00       	call   f0102806 <mem_init>
	// Lab 3 user environment initialization functions


	env_init();
f01002ab:	e8 aa 37 00 00       	call   f0103a5a <env_init>
	trap_init();
f01002b0:	e8 9a 44 00 00       	call   f010474f <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01002b5:	e8 c0 69 00 00       	call   f0106c7a <mp_init>
	lapic_init();
f01002ba:	e8 bf 6c 00 00       	call   f0106f7e <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01002bf:	90                   	nop
f01002c0:	e8 74 40 00 00       	call   f0104339 <pic_init>
f01002c5:	c7 04 24 80 23 12 f0 	movl   $0xf0122380,(%esp)
f01002cc:	e8 54 70 00 00       	call   f0107325 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01002d1:	83 3d 88 ce 1d f0 07 	cmpl   $0x7,0xf01dce88
f01002d8:	77 24                	ja     f01002fe <i386_init+0x187>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01002da:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01002e1:	00 
f01002e2:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f01002e9:	f0 
f01002ea:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
f01002f1:	00 
f01002f2:	c7 04 24 9a 76 10 f0 	movl   $0xf010769a,(%esp)
f01002f9:	e8 87 fd ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01002fe:	b8 96 6b 10 f0       	mov    $0xf0106b96,%eax
f0100303:	2d 1c 6b 10 f0       	sub    $0xf0106b1c,%eax
f0100308:	89 44 24 08          	mov    %eax,0x8(%esp)
f010030c:	c7 44 24 04 1c 6b 10 	movl   $0xf0106b1c,0x4(%esp)
f0100313:	f0 
f0100314:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f010031b:	e8 f5 65 00 00       	call   f0106915 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100320:	6b 05 c4 d3 1d f0 74 	imul   $0x74,0xf01dd3c4,%eax
f0100327:	05 20 d0 1d f0       	add    $0xf01dd020,%eax
f010032c:	3d 20 d0 1d f0       	cmp    $0xf01dd020,%eax
f0100331:	76 65                	jbe    f0100398 <i386_init+0x221>
f0100333:	be 00 00 00 00       	mov    $0x0,%esi
f0100338:	bb 20 d0 1d f0       	mov    $0xf01dd020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f010033d:	e8 20 6c 00 00       	call   f0106f62 <cpunum>
f0100342:	6b c0 74             	imul   $0x74,%eax,%eax
f0100345:	05 20 d0 1d f0       	add    $0xf01dd020,%eax
f010034a:	39 d8                	cmp    %ebx,%eax
f010034c:	74 34                	je     f0100382 <i386_init+0x20b>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f010034e:	89 f0                	mov    %esi,%eax
f0100350:	c1 f8 02             	sar    $0x2,%eax
f0100353:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100359:	c1 e0 0f             	shl    $0xf,%eax
f010035c:	8d 80 00 60 1e f0    	lea    -0xfe1a000(%eax),%eax
f0100362:	a3 84 ce 1d f0       	mov    %eax,0xf01dce84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100367:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f010036e:	00 
f010036f:	0f b6 03             	movzbl (%ebx),%eax
f0100372:	89 04 24             	mov    %eax,(%esp)
f0100375:	e8 6e 6d 00 00       	call   f01070e8 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010037a:	8b 43 04             	mov    0x4(%ebx),%eax
f010037d:	83 f8 01             	cmp    $0x1,%eax
f0100380:	75 f8                	jne    f010037a <i386_init+0x203>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100382:	83 c3 74             	add    $0x74,%ebx
f0100385:	83 c6 74             	add    $0x74,%esi
f0100388:	6b 05 c4 d3 1d f0 74 	imul   $0x74,0xf01dd3c4,%eax
f010038f:	05 20 d0 1d f0       	add    $0xf01dd020,%eax
f0100394:	39 c3                	cmp    %eax,%ebx
f0100396:	72 a5                	jb     f010033d <i386_init+0x1c6>
f0100398:	bb 00 00 00 00       	mov    $0x0,%ebx
	boot_aps();

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f010039d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01003a4:	00 
f01003a5:	c7 44 24 04 66 4c 00 	movl   $0x4c66,0x4(%esp)
f01003ac:	00 
f01003ad:	c7 04 24 58 52 16 f0 	movl   $0xf0165258,(%esp)
f01003b4:	e8 6e 3d 00 00       	call   f0104127 <env_create>
	// Starting non-boot CPUs
	boot_aps();

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01003b9:	83 c3 01             	add    $0x1,%ebx
f01003bc:	83 fb 08             	cmp    $0x8,%ebx
f01003bf:	75 dc                	jne    f010039d <i386_init+0x226>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01003c1:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
f01003c8:	00 
f01003c9:	c7 44 24 04 e3 63 01 	movl   $0x163e3,0x4(%esp)
f01003d0:	00 
f01003d1:	c7 04 24 01 55 1c f0 	movl   $0xf01c5501,(%esp)
f01003d8:	e8 4a 3d 00 00       	call   f0104127 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01003dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01003e4:	00 
f01003e5:	c7 44 24 04 bc 4c 00 	movl   $0x4cbc,0x4(%esp)
f01003ec:	00 
f01003ed:	c7 04 24 45 08 1c f0 	movl   $0xf01c0845,(%esp)
f01003f4:	e8 2e 3d 00 00       	call   f0104127 <env_create>
	//cprintf("%x\n",_pgfault_upcall);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	// Schedule and run the first user environment!
	sched_yield();
f01003f9:	e8 12 4e 00 00       	call   f0105210 <sched_yield>
	...

f0100400 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100400:	55                   	push   %ebp
f0100401:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100403:	ba 84 00 00 00       	mov    $0x84,%edx
f0100408:	ec                   	in     (%dx),%al
f0100409:	ec                   	in     (%dx),%al
f010040a:	ec                   	in     (%dx),%al
f010040b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010040c:	5d                   	pop    %ebp
f010040d:	c3                   	ret    

f010040e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010040e:	55                   	push   %ebp
f010040f:	89 e5                	mov    %esp,%ebp
f0100411:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100416:	ec                   	in     (%dx),%al
f0100417:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100419:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010041e:	f6 c2 01             	test   $0x1,%dl
f0100421:	74 09                	je     f010042c <serial_proc_data+0x1e>
f0100423:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100428:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100429:	0f b6 c0             	movzbl %al,%eax
}
f010042c:	5d                   	pop    %ebp
f010042d:	c3                   	ret    

f010042e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010042e:	55                   	push   %ebp
f010042f:	89 e5                	mov    %esp,%ebp
f0100431:	57                   	push   %edi
f0100432:	56                   	push   %esi
f0100433:	53                   	push   %ebx
f0100434:	83 ec 0c             	sub    $0xc,%esp
f0100437:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100439:	bb 24 c2 1d f0       	mov    $0xf01dc224,%ebx
f010043e:	bf 20 c0 1d f0       	mov    $0xf01dc020,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100443:	eb 1b                	jmp    f0100460 <cons_intr+0x32>
		if (c == 0)
f0100445:	85 c0                	test   %eax,%eax
f0100447:	74 17                	je     f0100460 <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f0100449:	8b 13                	mov    (%ebx),%edx
f010044b:	88 04 3a             	mov    %al,(%edx,%edi,1)
f010044e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100451:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100456:	ba 00 00 00 00       	mov    $0x0,%edx
f010045b:	0f 44 c2             	cmove  %edx,%eax
f010045e:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100460:	ff d6                	call   *%esi
f0100462:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100465:	75 de                	jne    f0100445 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100467:	83 c4 0c             	add    $0xc,%esp
f010046a:	5b                   	pop    %ebx
f010046b:	5e                   	pop    %esi
f010046c:	5f                   	pop    %edi
f010046d:	5d                   	pop    %ebp
f010046e:	c3                   	ret    

f010046f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010046f:	55                   	push   %ebp
f0100470:	89 e5                	mov    %esp,%ebp
f0100472:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100475:	b8 0a 07 10 f0       	mov    $0xf010070a,%eax
f010047a:	e8 af ff ff ff       	call   f010042e <cons_intr>
}
f010047f:	c9                   	leave  
f0100480:	c3                   	ret    

f0100481 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100481:	55                   	push   %ebp
f0100482:	89 e5                	mov    %esp,%ebp
f0100484:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100487:	83 3d 04 c0 1d f0 00 	cmpl   $0x0,0xf01dc004
f010048e:	74 0a                	je     f010049a <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100490:	b8 0e 04 10 f0       	mov    $0xf010040e,%eax
f0100495:	e8 94 ff ff ff       	call   f010042e <cons_intr>
}
f010049a:	c9                   	leave  
f010049b:	c3                   	ret    

f010049c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004a2:	e8 da ff ff ff       	call   f0100481 <serial_intr>
	kbd_intr();
f01004a7:	e8 c3 ff ff ff       	call   f010046f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004ac:	8b 15 20 c2 1d f0    	mov    0xf01dc220,%edx
f01004b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01004b7:	3b 15 24 c2 1d f0    	cmp    0xf01dc224,%edx
f01004bd:	74 1e                	je     f01004dd <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004bf:	0f b6 82 20 c0 1d f0 	movzbl -0xfe23fe0(%edx),%eax
f01004c6:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01004c9:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01004cf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004d4:	0f 44 d1             	cmove  %ecx,%edx
f01004d7:	89 15 20 c2 1d f0    	mov    %edx,0xf01dc220
		return c;
	}
	return 0;
}
f01004dd:	c9                   	leave  
f01004de:	c3                   	ret    

f01004df <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01004df:	55                   	push   %ebp
f01004e0:	89 e5                	mov    %esp,%ebp
f01004e2:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01004e5:	e8 b2 ff ff ff       	call   f010049c <cons_getc>
f01004ea:	85 c0                	test   %eax,%eax
f01004ec:	74 f7                	je     f01004e5 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01004ee:	c9                   	leave  
f01004ef:	c3                   	ret    

f01004f0 <iscons>:

int
iscons(int fdnum)
{
f01004f0:	55                   	push   %ebp
f01004f1:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01004f3:	b8 01 00 00 00       	mov    $0x1,%eax
f01004f8:	5d                   	pop    %ebp
f01004f9:	c3                   	ret    

f01004fa <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01004fa:	55                   	push   %ebp
f01004fb:	89 e5                	mov    %esp,%ebp
f01004fd:	57                   	push   %edi
f01004fe:	56                   	push   %esi
f01004ff:	53                   	push   %ebx
f0100500:	83 ec 2c             	sub    $0x2c,%esp
f0100503:	89 c7                	mov    %eax,%edi
f0100505:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010050a:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010050b:	a8 20                	test   $0x20,%al
f010050d:	75 21                	jne    f0100530 <cons_putc+0x36>
f010050f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100514:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100519:	e8 e2 fe ff ff       	call   f0100400 <delay>
f010051e:	89 f2                	mov    %esi,%edx
f0100520:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100521:	a8 20                	test   $0x20,%al
f0100523:	75 0b                	jne    f0100530 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100525:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100528:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010052e:	75 e9                	jne    f0100519 <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100530:	89 fa                	mov    %edi,%edx
f0100532:	89 f8                	mov    %edi,%eax
f0100534:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100537:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010053c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010053d:	b2 79                	mov    $0x79,%dl
f010053f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100540:	84 c0                	test   %al,%al
f0100542:	78 21                	js     f0100565 <cons_putc+0x6b>
f0100544:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100549:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f010054e:	e8 ad fe ff ff       	call   f0100400 <delay>
f0100553:	89 f2                	mov    %esi,%edx
f0100555:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100556:	84 c0                	test   %al,%al
f0100558:	78 0b                	js     f0100565 <cons_putc+0x6b>
f010055a:	83 c3 01             	add    $0x1,%ebx
f010055d:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100563:	75 e9                	jne    f010054e <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100565:	ba 78 03 00 00       	mov    $0x378,%edx
f010056a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010056e:	ee                   	out    %al,(%dx)
f010056f:	b2 7a                	mov    $0x7a,%dl
f0100571:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100576:	ee                   	out    %al,(%dx)
f0100577:	b8 08 00 00 00       	mov    $0x8,%eax
f010057c:	ee                   	out    %al,(%dx)
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f010057d:	89 f8                	mov    %edi,%eax
f010057f:	80 cc 07             	or     $0x7,%ah
f0100582:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100588:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010058b:	89 f8                	mov    %edi,%eax
f010058d:	25 ff 00 00 00       	and    $0xff,%eax
f0100592:	83 f8 09             	cmp    $0x9,%eax
f0100595:	0f 84 89 00 00 00    	je     f0100624 <cons_putc+0x12a>
f010059b:	83 f8 09             	cmp    $0x9,%eax
f010059e:	7f 12                	jg     f01005b2 <cons_putc+0xb8>
f01005a0:	83 f8 08             	cmp    $0x8,%eax
f01005a3:	0f 85 af 00 00 00    	jne    f0100658 <cons_putc+0x15e>
f01005a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01005b0:	eb 18                	jmp    f01005ca <cons_putc+0xd0>
f01005b2:	83 f8 0a             	cmp    $0xa,%eax
f01005b5:	8d 76 00             	lea    0x0(%esi),%esi
f01005b8:	74 40                	je     f01005fa <cons_putc+0x100>
f01005ba:	83 f8 0d             	cmp    $0xd,%eax
f01005bd:	8d 76 00             	lea    0x0(%esi),%esi
f01005c0:	0f 85 92 00 00 00    	jne    f0100658 <cons_putc+0x15e>
f01005c6:	66 90                	xchg   %ax,%ax
f01005c8:	eb 38                	jmp    f0100602 <cons_putc+0x108>
	case '\b':
		if (crt_pos > 0) {
f01005ca:	0f b7 05 10 c0 1d f0 	movzwl 0xf01dc010,%eax
f01005d1:	66 85 c0             	test   %ax,%ax
f01005d4:	0f 84 e8 00 00 00    	je     f01006c2 <cons_putc+0x1c8>
			crt_pos--;
f01005da:	83 e8 01             	sub    $0x1,%eax
f01005dd:	66 a3 10 c0 1d f0    	mov    %ax,0xf01dc010
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005e3:	0f b7 c0             	movzwl %ax,%eax
f01005e6:	66 81 e7 00 ff       	and    $0xff00,%di
f01005eb:	83 cf 20             	or     $0x20,%edi
f01005ee:	8b 15 0c c0 1d f0    	mov    0xf01dc00c,%edx
f01005f4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01005f8:	eb 7b                	jmp    f0100675 <cons_putc+0x17b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01005fa:	66 83 05 10 c0 1d f0 	addw   $0x50,0xf01dc010
f0100601:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100602:	0f b7 05 10 c0 1d f0 	movzwl 0xf01dc010,%eax
f0100609:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010060f:	c1 e8 10             	shr    $0x10,%eax
f0100612:	66 c1 e8 06          	shr    $0x6,%ax
f0100616:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100619:	c1 e0 04             	shl    $0x4,%eax
f010061c:	66 a3 10 c0 1d f0    	mov    %ax,0xf01dc010
f0100622:	eb 51                	jmp    f0100675 <cons_putc+0x17b>
		break;
	case '\t':
		cons_putc(' ');
f0100624:	b8 20 00 00 00       	mov    $0x20,%eax
f0100629:	e8 cc fe ff ff       	call   f01004fa <cons_putc>
		cons_putc(' ');
f010062e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100633:	e8 c2 fe ff ff       	call   f01004fa <cons_putc>
		cons_putc(' ');
f0100638:	b8 20 00 00 00       	mov    $0x20,%eax
f010063d:	e8 b8 fe ff ff       	call   f01004fa <cons_putc>
		cons_putc(' ');
f0100642:	b8 20 00 00 00       	mov    $0x20,%eax
f0100647:	e8 ae fe ff ff       	call   f01004fa <cons_putc>
		cons_putc(' ');
f010064c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100651:	e8 a4 fe ff ff       	call   f01004fa <cons_putc>
f0100656:	eb 1d                	jmp    f0100675 <cons_putc+0x17b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100658:	0f b7 05 10 c0 1d f0 	movzwl 0xf01dc010,%eax
f010065f:	0f b7 c8             	movzwl %ax,%ecx
f0100662:	8b 15 0c c0 1d f0    	mov    0xf01dc00c,%edx
f0100668:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010066c:	83 c0 01             	add    $0x1,%eax
f010066f:	66 a3 10 c0 1d f0    	mov    %ax,0xf01dc010
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100675:	66 81 3d 10 c0 1d f0 	cmpw   $0x7cf,0xf01dc010
f010067c:	cf 07 
f010067e:	76 42                	jbe    f01006c2 <cons_putc+0x1c8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100680:	a1 0c c0 1d f0       	mov    0xf01dc00c,%eax
f0100685:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010068c:	00 
f010068d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100693:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100697:	89 04 24             	mov    %eax,(%esp)
f010069a:	e8 76 62 00 00       	call   f0106915 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010069f:	8b 15 0c c0 1d f0    	mov    0xf01dc00c,%edx
f01006a5:	b8 80 07 00 00       	mov    $0x780,%eax
f01006aa:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006b0:	83 c0 01             	add    $0x1,%eax
f01006b3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01006b8:	75 f0                	jne    f01006aa <cons_putc+0x1b0>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006ba:	66 83 2d 10 c0 1d f0 	subw   $0x50,0xf01dc010
f01006c1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006c2:	8b 0d 08 c0 1d f0    	mov    0xf01dc008,%ecx
f01006c8:	89 cb                	mov    %ecx,%ebx
f01006ca:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006cf:	89 ca                	mov    %ecx,%edx
f01006d1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006d2:	0f b7 35 10 c0 1d f0 	movzwl 0xf01dc010,%esi
f01006d9:	83 c1 01             	add    $0x1,%ecx
f01006dc:	89 f0                	mov    %esi,%eax
f01006de:	66 c1 e8 08          	shr    $0x8,%ax
f01006e2:	89 ca                	mov    %ecx,%edx
f01006e4:	ee                   	out    %al,(%dx)
f01006e5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ea:	89 da                	mov    %ebx,%edx
f01006ec:	ee                   	out    %al,(%dx)
f01006ed:	89 f0                	mov    %esi,%eax
f01006ef:	89 ca                	mov    %ecx,%edx
f01006f1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01006f2:	83 c4 2c             	add    $0x2c,%esp
f01006f5:	5b                   	pop    %ebx
f01006f6:	5e                   	pop    %esi
f01006f7:	5f                   	pop    %edi
f01006f8:	5d                   	pop    %ebp
f01006f9:	c3                   	ret    

f01006fa <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006fa:	55                   	push   %ebp
f01006fb:	89 e5                	mov    %esp,%ebp
f01006fd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100700:	8b 45 08             	mov    0x8(%ebp),%eax
f0100703:	e8 f2 fd ff ff       	call   f01004fa <cons_putc>
}
f0100708:	c9                   	leave  
f0100709:	c3                   	ret    

f010070a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010070a:	55                   	push   %ebp
f010070b:	89 e5                	mov    %esp,%ebp
f010070d:	53                   	push   %ebx
f010070e:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100711:	ba 64 00 00 00       	mov    $0x64,%edx
f0100716:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100717:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010071c:	a8 01                	test   $0x1,%al
f010071e:	0f 84 dd 00 00 00    	je     f0100801 <kbd_proc_data+0xf7>
f0100724:	b2 60                	mov    $0x60,%dl
f0100726:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100727:	3c e0                	cmp    $0xe0,%al
f0100729:	75 11                	jne    f010073c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010072b:	83 0d 00 c0 1d f0 40 	orl    $0x40,0xf01dc000
f0100732:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100737:	e9 c5 00 00 00       	jmp    f0100801 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f010073c:	84 c0                	test   %al,%al
f010073e:	79 35                	jns    f0100775 <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100740:	8b 15 00 c0 1d f0    	mov    0xf01dc000,%edx
f0100746:	89 c1                	mov    %eax,%ecx
f0100748:	83 e1 7f             	and    $0x7f,%ecx
f010074b:	f6 c2 40             	test   $0x40,%dl
f010074e:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100751:	0f b6 c0             	movzbl %al,%eax
f0100754:	0f b6 80 e0 77 10 f0 	movzbl -0xfef8820(%eax),%eax
f010075b:	83 c8 40             	or     $0x40,%eax
f010075e:	0f b6 c0             	movzbl %al,%eax
f0100761:	f7 d0                	not    %eax
f0100763:	21 c2                	and    %eax,%edx
f0100765:	89 15 00 c0 1d f0    	mov    %edx,0xf01dc000
f010076b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100770:	e9 8c 00 00 00       	jmp    f0100801 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f0100775:	8b 15 00 c0 1d f0    	mov    0xf01dc000,%edx
f010077b:	f6 c2 40             	test   $0x40,%dl
f010077e:	74 0c                	je     f010078c <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100780:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100783:	83 e2 bf             	and    $0xffffffbf,%edx
f0100786:	89 15 00 c0 1d f0    	mov    %edx,0xf01dc000
	}

	shift |= shiftcode[data];
f010078c:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010078f:	0f b6 90 e0 77 10 f0 	movzbl -0xfef8820(%eax),%edx
f0100796:	0b 15 00 c0 1d f0    	or     0xf01dc000,%edx
f010079c:	0f b6 88 e0 78 10 f0 	movzbl -0xfef8720(%eax),%ecx
f01007a3:	31 ca                	xor    %ecx,%edx
f01007a5:	89 15 00 c0 1d f0    	mov    %edx,0xf01dc000

	c = charcode[shift & (CTL | SHIFT)][data];
f01007ab:	89 d1                	mov    %edx,%ecx
f01007ad:	83 e1 03             	and    $0x3,%ecx
f01007b0:	8b 0c 8d e0 79 10 f0 	mov    -0xfef8620(,%ecx,4),%ecx
f01007b7:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01007bb:	f6 c2 08             	test   $0x8,%dl
f01007be:	74 1b                	je     f01007db <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01007c0:	89 d9                	mov    %ebx,%ecx
f01007c2:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01007c5:	83 f8 19             	cmp    $0x19,%eax
f01007c8:	77 05                	ja     f01007cf <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01007ca:	83 eb 20             	sub    $0x20,%ebx
f01007cd:	eb 0c                	jmp    f01007db <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01007cf:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f01007d2:	8d 43 20             	lea    0x20(%ebx),%eax
f01007d5:	83 f9 19             	cmp    $0x19,%ecx
f01007d8:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01007db:	f7 d2                	not    %edx
f01007dd:	f6 c2 06             	test   $0x6,%dl
f01007e0:	75 1f                	jne    f0100801 <kbd_proc_data+0xf7>
f01007e2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01007e8:	75 17                	jne    f0100801 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f01007ea:	c7 04 24 a3 77 10 f0 	movl   $0xf01077a3,(%esp)
f01007f1:	e8 05 3c 00 00       	call   f01043fb <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01007f6:	ba 92 00 00 00       	mov    $0x92,%edx
f01007fb:	b8 03 00 00 00       	mov    $0x3,%eax
f0100800:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100801:	89 d8                	mov    %ebx,%eax
f0100803:	83 c4 14             	add    $0x14,%esp
f0100806:	5b                   	pop    %ebx
f0100807:	5d                   	pop    %ebp
f0100808:	c3                   	ret    

f0100809 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100809:	55                   	push   %ebp
f010080a:	89 e5                	mov    %esp,%ebp
f010080c:	57                   	push   %edi
f010080d:	56                   	push   %esi
f010080e:	53                   	push   %ebx
f010080f:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100812:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100817:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f010081a:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010081f:	0f b7 00             	movzwl (%eax),%eax
f0100822:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100826:	74 11                	je     f0100839 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100828:	c7 05 08 c0 1d f0 b4 	movl   $0x3b4,0xf01dc008
f010082f:	03 00 00 
f0100832:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100837:	eb 16                	jmp    f010084f <cons_init+0x46>
	} else {
		*cp = was;
f0100839:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100840:	c7 05 08 c0 1d f0 d4 	movl   $0x3d4,0xf01dc008
f0100847:	03 00 00 
f010084a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010084f:	8b 0d 08 c0 1d f0    	mov    0xf01dc008,%ecx
f0100855:	89 cb                	mov    %ecx,%ebx
f0100857:	b8 0e 00 00 00       	mov    $0xe,%eax
f010085c:	89 ca                	mov    %ecx,%edx
f010085e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010085f:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100862:	89 ca                	mov    %ecx,%edx
f0100864:	ec                   	in     (%dx),%al
f0100865:	0f b6 f8             	movzbl %al,%edi
f0100868:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010086b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100870:	89 da                	mov    %ebx,%edx
f0100872:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100873:	89 ca                	mov    %ecx,%edx
f0100875:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100876:	89 35 0c c0 1d f0    	mov    %esi,0xf01dc00c
	crt_pos = pos;
f010087c:	0f b6 c8             	movzbl %al,%ecx
f010087f:	09 cf                	or     %ecx,%edi
f0100881:	66 89 3d 10 c0 1d f0 	mov    %di,0xf01dc010

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100888:	e8 e2 fb ff ff       	call   f010046f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f010088d:	0f b7 05 70 23 12 f0 	movzwl 0xf0122370,%eax
f0100894:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100899:	89 04 24             	mov    %eax,(%esp)
f010089c:	e8 27 3a 00 00       	call   f01042c8 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008a1:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01008a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ab:	89 da                	mov    %ebx,%edx
f01008ad:	ee                   	out    %al,(%dx)
f01008ae:	b2 fb                	mov    $0xfb,%dl
f01008b0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01008b5:	ee                   	out    %al,(%dx)
f01008b6:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01008bb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01008c0:	89 ca                	mov    %ecx,%edx
f01008c2:	ee                   	out    %al,(%dx)
f01008c3:	b2 f9                	mov    $0xf9,%dl
f01008c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ca:	ee                   	out    %al,(%dx)
f01008cb:	b2 fb                	mov    $0xfb,%dl
f01008cd:	b8 03 00 00 00       	mov    $0x3,%eax
f01008d2:	ee                   	out    %al,(%dx)
f01008d3:	b2 fc                	mov    $0xfc,%dl
f01008d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008da:	ee                   	out    %al,(%dx)
f01008db:	b2 f9                	mov    $0xf9,%dl
f01008dd:	b8 01 00 00 00       	mov    $0x1,%eax
f01008e2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008e3:	b2 fd                	mov    $0xfd,%dl
f01008e5:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01008e6:	3c ff                	cmp    $0xff,%al
f01008e8:	0f 95 c0             	setne  %al
f01008eb:	0f b6 f0             	movzbl %al,%esi
f01008ee:	89 35 04 c0 1d f0    	mov    %esi,0xf01dc004
f01008f4:	89 da                	mov    %ebx,%edx
f01008f6:	ec                   	in     (%dx),%al
f01008f7:	89 ca                	mov    %ecx,%edx
f01008f9:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01008fa:	85 f6                	test   %esi,%esi
f01008fc:	75 0c                	jne    f010090a <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f01008fe:	c7 04 24 af 77 10 f0 	movl   $0xf01077af,(%esp)
f0100905:	e8 f1 3a 00 00       	call   f01043fb <cprintf>
}
f010090a:	83 c4 1c             	add    $0x1c,%esp
f010090d:	5b                   	pop    %ebx
f010090e:	5e                   	pop    %esi
f010090f:	5f                   	pop    %edi
f0100910:	5d                   	pop    %ebp
f0100911:	c3                   	ret    
	...

f0100920 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100920:	55                   	push   %ebp
f0100921:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100923:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100926:	5d                   	pop    %ebp
f0100927:	c3                   	ret    

f0100928 <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f0100928:	55                   	push   %ebp
f0100929:	89 e5                	mov    %esp,%ebp
f010092b:	57                   	push   %edi
f010092c:	56                   	push   %esi
f010092d:	53                   	push   %ebx
f010092e:	81 ec 3c 01 00 00    	sub    $0x13c,%esp

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;
	//00000012 <do_overflow>: I shall overflow the esp
	//overflow me's ebp's value: $2 = 0xf010fe08
    char str[256] = {};
f0100934:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f010093a:	b9 40 00 00 00       	mov    $0x40,%ecx
f010093f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100944:	f3 ab                	rep stos %eax,%es:(%edi)
    char *pret_addr;
	// Your code here.
	int i = 0;	
	while(i < 256)
	{
		str[i] = ' ';
f0100946:	8d 95 e8 fe ff ff    	lea    -0x118(%ebp),%edx
f010094c:	c6 04 02 20          	movb   $0x20,(%edx,%eax,1)
		i++;
f0100950:	83 c0 01             	add    $0x1,%eax
    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
	// Your code here.
	int i = 0;	
	while(i < 256)
f0100953:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100958:	75 f2                	jne    f010094c <start_overflow+0x24>
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f010095a:	8d 45 04             	lea    0x4(%ebp),%eax
f010095d:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100963:	89 e8                	mov    %ebp,%eax
	void (*doover)();
	doover = do_overflow;
	void (*overme)();

	uint32_t buffover[4];
	buffover[0] = (uint32_t)doover+3;
f0100965:	c7 85 d8 fe ff ff ea 	movl   $0xf01009ea,-0x128(%ebp)
f010096c:	09 10 f0 
f010096f:	bb 00 00 00 00       	mov    $0x0,%ebx
	i = 0;
	while(i < 4)
	{
		nstr = (buffover[i/4]>>(8*i)) & 0x000000ff;
		str[nstr] = '\0'; 
		cprintf("%s%n",str,pret_addr+i); 
f0100974:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
	//buffover[1] = *((int *)(*((int *)ebp)));
	//buffover[2] = *((int *)(*((int *)ebp))+1);
	i = 0;
	while(i < 4)
	{
		nstr = (buffover[i/4]>>(8*i)) & 0x000000ff;
f010097a:	8d 43 03             	lea    0x3(%ebx),%eax
f010097d:	85 db                	test   %ebx,%ebx
f010097f:	0f 49 c3             	cmovns %ebx,%eax
f0100982:	c1 f8 02             	sar    $0x2,%eax
f0100985:	8d 0c dd 00 00 00 00 	lea    0x0(,%ebx,8),%ecx
f010098c:	8b b4 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%esi
f0100993:	d3 ee                	shr    %cl,%esi
f0100995:	81 e6 ff 00 00 00    	and    $0xff,%esi
		str[nstr] = '\0'; 
f010099b:	c6 84 35 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%esi,1)
f01009a2:	00 
		cprintf("%s%n",str,pret_addr+i); 
f01009a3:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
f01009a9:	01 d8                	add    %ebx,%eax
f01009ab:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009af:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01009b3:	c7 04 24 d3 76 10 f0 	movl   $0xf01076d3,(%esp)
f01009ba:	e8 3c 3a 00 00       	call   f01043fb <cprintf>
		//cprintf("%x---%x\n",nstr,*(pret_addr+i));
		str[nstr] = ' ';
f01009bf:	c6 84 35 e8 fe ff ff 	movb   $0x20,-0x118(%ebp,%esi,1)
f01009c6:	20 
		i++;
f01009c7:	83 c3 01             	add    $0x1,%ebx
	uint32_t buffover[4];
	buffover[0] = (uint32_t)doover+3;
	//buffover[1] = *((int *)(*((int *)ebp)));
	//buffover[2] = *((int *)(*((int *)ebp))+1);
	i = 0;
	while(i < 4)
f01009ca:	83 fb 04             	cmp    $0x4,%ebx
f01009cd:	75 ab                	jne    f010097a <start_overflow+0x52>
		str[nstr] = ' ';
		i++;
	}


}
f01009cf:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f01009d5:	5b                   	pop    %ebx
f01009d6:	5e                   	pop    %esi
f01009d7:	5f                   	pop    %edi
f01009d8:	5d                   	pop    %ebp
f01009d9:	c3                   	ret    

f01009da <overflow_me>:

void
overflow_me(void)
{
f01009da:	55                   	push   %ebp
f01009db:	89 e5                	mov    %esp,%ebp
f01009dd:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f01009e0:	e8 43 ff ff ff       	call   f0100928 <start_overflow>
}
f01009e5:	c9                   	leave  
f01009e6:	c3                   	ret    

f01009e7 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f01009e7:	55                   	push   %ebp
f01009e8:	89 e5                	mov    %esp,%ebp
f01009ea:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f01009ed:	c7 04 24 f0 79 10 f0 	movl   $0xf01079f0,(%esp)
f01009f4:	e8 02 3a 00 00       	call   f01043fb <cprintf>
}
f01009f9:	c9                   	leave  
f01009fa:	c3                   	ret    

f01009fb <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01009fb:	55                   	push   %ebp
f01009fc:	89 e5                	mov    %esp,%ebp
f01009fe:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100a01:	c7 04 24 02 7a 10 f0 	movl   $0xf0107a02,(%esp)
f0100a08:	e8 ee 39 00 00       	call   f01043fb <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100a0d:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100a14:	00 
f0100a15:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100a1c:	f0 
f0100a1d:	c7 04 24 cc 7a 10 f0 	movl   $0xf0107acc,(%esp)
f0100a24:	e8 d2 39 00 00       	call   f01043fb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100a29:	c7 44 24 08 65 76 10 	movl   $0x107665,0x8(%esp)
f0100a30:	00 
f0100a31:	c7 44 24 04 65 76 10 	movl   $0xf0107665,0x4(%esp)
f0100a38:	f0 
f0100a39:	c7 04 24 f0 7a 10 f0 	movl   $0xf0107af0,(%esp)
f0100a40:	e8 b6 39 00 00       	call   f01043fb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100a45:	c7 44 24 08 e4 b8 1d 	movl   $0x1db8e4,0x8(%esp)
f0100a4c:	00 
f0100a4d:	c7 44 24 04 e4 b8 1d 	movl   $0xf01db8e4,0x4(%esp)
f0100a54:	f0 
f0100a55:	c7 04 24 14 7b 10 f0 	movl   $0xf0107b14,(%esp)
f0100a5c:	e8 9a 39 00 00       	call   f01043fb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100a61:	c7 44 24 08 04 e0 21 	movl   $0x21e004,0x8(%esp)
f0100a68:	00 
f0100a69:	c7 44 24 04 04 e0 21 	movl   $0xf021e004,0x4(%esp)
f0100a70:	f0 
f0100a71:	c7 04 24 38 7b 10 f0 	movl   $0xf0107b38,(%esp)
f0100a78:	e8 7e 39 00 00       	call   f01043fb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a7d:	b8 03 e4 21 f0       	mov    $0xf021e403,%eax
f0100a82:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100a87:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100a8d:	85 c0                	test   %eax,%eax
f0100a8f:	0f 48 c2             	cmovs  %edx,%eax
f0100a92:	c1 f8 0a             	sar    $0xa,%eax
f0100a95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a99:	c7 04 24 5c 7b 10 f0 	movl   $0xf0107b5c,(%esp)
f0100aa0:	e8 56 39 00 00       	call   f01043fb <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100aa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aaa:	c9                   	leave  
f0100aab:	c3                   	ret    

f0100aac <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100aac:	55                   	push   %ebp
f0100aad:	89 e5                	mov    %esp,%ebp
f0100aaf:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100ab2:	a1 64 7c 10 f0       	mov    0xf0107c64,%eax
f0100ab7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100abb:	a1 60 7c 10 f0       	mov    0xf0107c60,%eax
f0100ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ac4:	c7 04 24 1b 7a 10 f0 	movl   $0xf0107a1b,(%esp)
f0100acb:	e8 2b 39 00 00       	call   f01043fb <cprintf>
f0100ad0:	a1 70 7c 10 f0       	mov    0xf0107c70,%eax
f0100ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ad9:	a1 6c 7c 10 f0       	mov    0xf0107c6c,%eax
f0100ade:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae2:	c7 04 24 1b 7a 10 f0 	movl   $0xf0107a1b,(%esp)
f0100ae9:	e8 0d 39 00 00       	call   f01043fb <cprintf>
f0100aee:	a1 7c 7c 10 f0       	mov    0xf0107c7c,%eax
f0100af3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100af7:	a1 78 7c 10 f0       	mov    0xf0107c78,%eax
f0100afc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b00:	c7 04 24 1b 7a 10 f0 	movl   $0xf0107a1b,(%esp)
f0100b07:	e8 ef 38 00 00       	call   f01043fb <cprintf>
	return 0;
}
f0100b0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b11:	c9                   	leave  
f0100b12:	c3                   	ret    

f0100b13 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b13:	55                   	push   %ebp
f0100b14:	89 e5                	mov    %esp,%ebp
f0100b16:	57                   	push   %edi
f0100b17:	56                   	push   %esi
f0100b18:	53                   	push   %ebx
f0100b19:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b1c:	c7 04 24 88 7b 10 f0 	movl   $0xf0107b88,(%esp)
f0100b23:	e8 d3 38 00 00       	call   f01043fb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b28:	c7 04 24 ac 7b 10 f0 	movl   $0xf0107bac,(%esp)
f0100b2f:	e8 c7 38 00 00       	call   f01043fb <cprintf>

	if (tf != NULL)
f0100b34:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b38:	74 0b                	je     f0100b45 <monitor+0x32>
		print_trapframe(tf);
f0100b3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b3d:	89 04 24             	mov    %eax,(%esp)
f0100b40:	e8 76 3a 00 00       	call   f01045bb <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100b45:	c7 04 24 24 7a 10 f0 	movl   $0xf0107a24,(%esp)
f0100b4c:	e8 af 5a 00 00       	call   f0106600 <readline>
f0100b51:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b53:	85 c0                	test   %eax,%eax
f0100b55:	74 ee                	je     f0100b45 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b57:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100b5e:	be 00 00 00 00       	mov    $0x0,%esi
f0100b63:	eb 06                	jmp    f0100b6b <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b65:	c6 03 00             	movb   $0x0,(%ebx)
f0100b68:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b6b:	0f b6 03             	movzbl (%ebx),%eax
f0100b6e:	84 c0                	test   %al,%al
f0100b70:	74 6a                	je     f0100bdc <monitor+0xc9>
f0100b72:	0f be c0             	movsbl %al,%eax
f0100b75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b79:	c7 04 24 28 7a 10 f0 	movl   $0xf0107a28,(%esp)
f0100b80:	e8 d6 5c 00 00       	call   f010685b <strchr>
f0100b85:	85 c0                	test   %eax,%eax
f0100b87:	75 dc                	jne    f0100b65 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100b89:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b8c:	74 4e                	je     f0100bdc <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b8e:	83 fe 0f             	cmp    $0xf,%esi
f0100b91:	75 16                	jne    f0100ba9 <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100b93:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100b9a:	00 
f0100b9b:	c7 04 24 2d 7a 10 f0 	movl   $0xf0107a2d,(%esp)
f0100ba2:	e8 54 38 00 00       	call   f01043fb <cprintf>
f0100ba7:	eb 9c                	jmp    f0100b45 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100ba9:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100bad:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100bb0:	0f b6 03             	movzbl (%ebx),%eax
f0100bb3:	84 c0                	test   %al,%al
f0100bb5:	75 0c                	jne    f0100bc3 <monitor+0xb0>
f0100bb7:	eb b2                	jmp    f0100b6b <monitor+0x58>
			buf++;
f0100bb9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100bbc:	0f b6 03             	movzbl (%ebx),%eax
f0100bbf:	84 c0                	test   %al,%al
f0100bc1:	74 a8                	je     f0100b6b <monitor+0x58>
f0100bc3:	0f be c0             	movsbl %al,%eax
f0100bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bca:	c7 04 24 28 7a 10 f0 	movl   $0xf0107a28,(%esp)
f0100bd1:	e8 85 5c 00 00       	call   f010685b <strchr>
f0100bd6:	85 c0                	test   %eax,%eax
f0100bd8:	74 df                	je     f0100bb9 <monitor+0xa6>
f0100bda:	eb 8f                	jmp    f0100b6b <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100bdc:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100be3:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100be4:	85 f6                	test   %esi,%esi
f0100be6:	0f 84 59 ff ff ff    	je     f0100b45 <monitor+0x32>
f0100bec:	bb 60 7c 10 f0       	mov    $0xf0107c60,%ebx
f0100bf1:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100bf6:	8b 03                	mov    (%ebx),%eax
f0100bf8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bfc:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100bff:	89 04 24             	mov    %eax,(%esp)
f0100c02:	e8 de 5b 00 00       	call   f01067e5 <strcmp>
f0100c07:	85 c0                	test   %eax,%eax
f0100c09:	75 23                	jne    f0100c2e <monitor+0x11b>
			return commands[i].func(argc, argv, tf);
f0100c0b:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c11:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c15:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c18:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c1c:	89 34 24             	mov    %esi,(%esp)
f0100c1f:	ff 97 68 7c 10 f0    	call   *-0xfef8398(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c25:	85 c0                	test   %eax,%eax
f0100c27:	78 28                	js     f0100c51 <monitor+0x13e>
f0100c29:	e9 17 ff ff ff       	jmp    f0100b45 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c2e:	83 c7 01             	add    $0x1,%edi
f0100c31:	83 c3 0c             	add    $0xc,%ebx
f0100c34:	83 ff 03             	cmp    $0x3,%edi
f0100c37:	75 bd                	jne    f0100bf6 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c39:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c40:	c7 04 24 4a 7a 10 f0 	movl   $0xf0107a4a,(%esp)
f0100c47:	e8 af 37 00 00       	call   f01043fb <cprintf>
f0100c4c:	e9 f4 fe ff ff       	jmp    f0100b45 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c51:	83 c4 5c             	add    $0x5c,%esp
f0100c54:	5b                   	pop    %ebx
f0100c55:	5e                   	pop    %esi
f0100c56:	5f                   	pop    %edi
f0100c57:	5d                   	pop    %ebp
f0100c58:	c3                   	ret    

f0100c59 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100c59:	55                   	push   %ebp
f0100c5a:	89 e5                	mov    %esp,%ebp
f0100c5c:	57                   	push   %edi
f0100c5d:	56                   	push   %esi
f0100c5e:	53                   	push   %ebx
f0100c5f:	83 ec 5c             	sub    $0x5c,%esp
f0100c62:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t ebp =  read_ebp();
	uint32_t eip =  read_eip();
f0100c64:	e8 b7 fc ff ff       	call   f0100920 <read_eip>
f0100c69:	89 c7                	mov    %eax,%edi
	uint32_t arg[5];
	memset(arg,0,5);
f0100c6b:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0100c72:	00 
f0100c73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c7a:	00 
f0100c7b:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100c7e:	89 04 24             	mov    %eax,(%esp)
f0100c81:	e8 30 5c 00 00       	call   f01068b6 <memset>
	cprintf("Stack backtrace:\n");
f0100c86:	c7 04 24 60 7a 10 f0 	movl   $0xf0107a60,(%esp)
f0100c8d:	e8 69 37 00 00       	call   f01043fb <cprintf>
		eip = *((uint32_t*)ebp+1);
		ebp = *((uint32_t*)ebp);		
		int i = 0;
		while(i<5)
		{
			arg[i] = *((uint32_t*)ebp+2+i);
f0100c92:	8d 75 bc             	lea    -0x44(%ebp),%esi
	uint32_t arg[5];
	memset(arg,0,5);
	cprintf("Stack backtrace:\n");
	do{
		
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n",ebp,eip,arg[0],arg[1],arg[2],arg[3],arg[4]);
f0100c95:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100c98:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100c9c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100c9f:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100ca3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100ca6:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100caa:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100cad:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100cb1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100cb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cb8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100cbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cc0:	c7 04 24 d4 7b 10 f0 	movl   $0xf0107bd4,(%esp)
f0100cc7:	e8 2f 37 00 00       	call   f01043fb <cprintf>
		
		debuginfo_eip((uintptr_t)eip,&info);
f0100ccc:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cd3:	89 3c 24             	mov    %edi,(%esp)
f0100cd6:	e8 83 4f 00 00       	call   f0105c5e <debuginfo_eip>
		cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip -info.eip_fn_addr);
f0100cdb:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100cde:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100ce2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ce5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ce9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cec:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cf0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100cf3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cf7:	c7 04 24 72 7a 10 f0 	movl   $0xf0107a72,(%esp)
f0100cfe:	e8 f8 36 00 00       	call   f01043fb <cprintf>

		eip = *((uint32_t*)ebp+1);
f0100d03:	8b 7b 04             	mov    0x4(%ebx),%edi
		ebp = *((uint32_t*)ebp);		
f0100d06:	8b 1b                	mov    (%ebx),%ebx
f0100d08:	b8 00 00 00 00       	mov    $0x0,%eax
		int i = 0;
		while(i<5)
		{
			arg[i] = *((uint32_t*)ebp+2+i);
f0100d0d:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f0100d11:	89 14 86             	mov    %edx,(%esi,%eax,4)
			i++;
f0100d14:	83 c0 01             	add    $0x1,%eax
		cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip -info.eip_fn_addr);

		eip = *((uint32_t*)ebp+1);
		ebp = *((uint32_t*)ebp);		
		int i = 0;
		while(i<5)
f0100d17:	83 f8 05             	cmp    $0x5,%eax
f0100d1a:	75 f1                	jne    f0100d0d <mon_backtrace+0xb4>
		{
			arg[i] = *((uint32_t*)ebp+2+i);
			i++;
		}
	}while(ebp != 0);
f0100d1c:	85 db                	test   %ebx,%ebx
f0100d1e:	0f 85 71 ff ff ff    	jne    f0100c95 <mon_backtrace+0x3c>

	
	

    overflow_me();
f0100d24:	e8 b1 fc ff ff       	call   f01009da <overflow_me>
    cprintf("Backtrace success\n");
f0100d29:	c7 04 24 81 7a 10 f0 	movl   $0xf0107a81,(%esp)
f0100d30:	e8 c6 36 00 00       	call   f01043fb <cprintf>
	return 0;
}
f0100d35:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d3a:	83 c4 5c             	add    $0x5c,%esp
f0100d3d:	5b                   	pop    %ebx
f0100d3e:	5e                   	pop    %esi
f0100d3f:	5f                   	pop    %edi
f0100d40:	5d                   	pop    %ebp
f0100d41:	c3                   	ret    
	...

f0100d50 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100d50:	55                   	push   %ebp
f0100d51:	89 e5                	mov    %esp,%ebp
f0100d53:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100d55:	83 3d 28 c2 1d f0 00 	cmpl   $0x0,0xf01dc228
f0100d5c:	75 0f                	jne    f0100d6d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d5e:	b8 03 f0 21 f0       	mov    $0xf021f003,%eax
f0100d63:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d68:	a3 28 c2 1d f0       	mov    %eax,0xf01dc228
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = ROUNDUP(nextfree,PGSIZE);
f0100d6d:	a1 28 c2 1d f0       	mov    0xf01dc228,%eax
f0100d72:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100d77:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	nextfree = result + n;
f0100d7c:	8d 14 10             	lea    (%eax,%edx,1),%edx
f0100d7f:	89 15 28 c2 1d f0    	mov    %edx,0xf01dc228
	
	return result;
}
f0100d85:	5d                   	pop    %ebp
f0100d86:	c3                   	ret    

f0100d87 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100d87:	55                   	push   %ebp
f0100d88:	89 e5                	mov    %esp,%ebp
f0100d8a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	//cprintf("want to free :%d\t%d\n",pp->pp_ref,PGNUM(page2pa(pp)));
	if(pp->pp_ref) //should be no reference
f0100d8d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100d92:	75 0d                	jne    f0100da1 <page_free+0x1a>
		return;
	pp->pp_link = page_free_list;
f0100d94:	8b 15 30 c2 1d f0    	mov    0xf01dc230,%edx
f0100d9a:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100d9c:	a3 30 c2 1d f0       	mov    %eax,0xf01dc230
	//cprintf("have free what?:%d\n",PGNUM(page2pa(page_free_list)));
	
	
}
f0100da1:	5d                   	pop    %ebp
f0100da2:	c3                   	ret    

f0100da3 <page_free_4pages>:
//	2. Add the pages to the chunck list.
//	
//	Return 0 if everything ok
int
page_free_4pages(struct Page *pp)
{
f0100da3:	55                   	push   %ebp
f0100da4:	89 e5                	mov    %esp,%ebp
f0100da6:	53                   	push   %ebx
f0100da7:	83 ec 04             	sub    $0x4,%esp
f0100daa:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100dad:	85 c0                	test   %eax,%eax
f0100daf:	75 2d                	jne    f0100dde <page_free_4pages+0x3b>
f0100db1:	eb 20                	jmp    f0100dd3 <page_free_4pages+0x30>
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
	}
	checktolast->pp_link = chunck_list.pp_link;
f0100db3:	8b 15 34 c2 1d f0    	mov    0xf01dc234,%edx
f0100db9:	89 11                	mov    %edx,(%ecx)
	chunck_list.pp_link = pp;
	while(chunck_list.pp_link!=NULL)
	{
		pp = chunck_list.pp_link;
		chunck_list.pp_link = chunck_list.pp_link->pp_link;
f0100dbb:	8b 18                	mov    (%eax),%ebx
		page_free(pp);
f0100dbd:	89 04 24             	mov    %eax,(%esp)
f0100dc0:	e8 c2 ff ff ff       	call   f0100d87 <page_free>
f0100dc5:	89 d8                	mov    %ebx,%eax
			break;
		checktolast = checktolast->pp_link;
	}
	checktolast->pp_link = chunck_list.pp_link;
	chunck_list.pp_link = pp;
	while(chunck_list.pp_link!=NULL)
f0100dc7:	85 db                	test   %ebx,%ebx
f0100dc9:	75 f0                	jne    f0100dbb <page_free_4pages+0x18>
f0100dcb:	89 1d 34 c2 1d f0    	mov    %ebx,0xf01dc234
f0100dd1:	eb 05                	jmp    f0100dd8 <page_free_4pages+0x35>
f0100dd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pp = chunck_list.pp_link;
		chunck_list.pp_link = chunck_list.pp_link->pp_link;
		page_free(pp);
	}
	return 0;
}
f0100dd8:	83 c4 04             	add    $0x4,%esp
f0100ddb:	5b                   	pop    %ebx
f0100ddc:	5d                   	pop    %ebp
f0100ddd:	c3                   	ret    
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
f0100dde:	8b 10                	mov    (%eax),%edx
{
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100de0:	85 d2                	test   %edx,%edx
f0100de2:	74 ef                	je     f0100dd3 <page_free_4pages+0x30>
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
f0100de4:	8b 12                	mov    (%edx),%edx
{
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100de6:	85 d2                	test   %edx,%edx
f0100de8:	74 e9                	je     f0100dd3 <page_free_4pages+0x30>
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
f0100dea:	8b 0a                	mov    (%edx),%ecx
{
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100dec:	85 c9                	test   %ecx,%ecx
f0100dee:	75 c3                	jne    f0100db3 <page_free_4pages+0x10>
f0100df0:	eb e1                	jmp    f0100dd3 <page_free_4pages+0x30>

f0100df2 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100df2:	55                   	push   %ebp
f0100df3:	89 e5                	mov    %esp,%ebp
f0100df5:	83 ec 04             	sub    $0x4,%esp
f0100df8:	8b 45 08             	mov    0x8(%ebp),%eax
	//cprintf("in\n");
	if (--pp->pp_ref == 0)
f0100dfb:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100dff:	83 ea 01             	sub    $0x1,%edx
f0100e02:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100e06:	66 85 d2             	test   %dx,%dx
f0100e09:	75 08                	jne    f0100e13 <page_decref+0x21>
		page_free(pp);
f0100e0b:	89 04 24             	mov    %eax,(%esp)
f0100e0e:	e8 74 ff ff ff       	call   f0100d87 <page_free>
	//cprintf("out\n");
}
f0100e13:	c9                   	leave  
f0100e14:	c3                   	ret    

f0100e15 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100e15:	55                   	push   %ebp
f0100e16:	89 e5                	mov    %esp,%ebp
f0100e18:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100e1b:	e8 42 61 00 00       	call   f0106f62 <cpunum>
f0100e20:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e23:	83 b8 28 d0 1d f0 00 	cmpl   $0x0,-0xfe22fd8(%eax)
f0100e2a:	74 16                	je     f0100e42 <tlb_invalidate+0x2d>
f0100e2c:	e8 31 61 00 00       	call   f0106f62 <cpunum>
f0100e31:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e34:	8b 90 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%edx
f0100e3a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e3d:	39 42 60             	cmp    %eax,0x60(%edx)
f0100e40:	75 06                	jne    f0100e48 <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100e42:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e45:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100e48:	c9                   	leave  
f0100e49:	c3                   	ret    

f0100e4a <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100e4a:	55                   	push   %ebp
f0100e4b:	89 e5                	mov    %esp,%ebp
f0100e4d:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check pde\n");
	if (!(*pgdir & PTE_P))
f0100e50:	89 d1                	mov    %edx,%ecx
f0100e52:	c1 e9 16             	shr    $0x16,%ecx
f0100e55:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e58:	a8 01                	test   $0x1,%al
f0100e5a:	74 4d                	je     f0100ea9 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e61:	89 c1                	mov    %eax,%ecx
f0100e63:	c1 e9 0c             	shr    $0xc,%ecx
f0100e66:	3b 0d 88 ce 1d f0    	cmp    0xf01dce88,%ecx
f0100e6c:	72 20                	jb     f0100e8e <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e72:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0100e79:	f0 
f0100e7a:	c7 44 24 04 2d 04 00 	movl   $0x42d,0x4(%esp)
f0100e81:	00 
f0100e82:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0100e89:	e8 f7 f1 ff ff       	call   f0100085 <_panic>
	//cprintf("check pte\n");
	if (!(p[PTX(va)] & PTE_P))
f0100e8e:	c1 ea 0c             	shr    $0xc,%edx
f0100e91:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100e97:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100e9e:	a8 01                	test   $0x1,%al
f0100ea0:	74 07                	je     f0100ea9 <check_va2pa+0x5f>
		return ~0;
	//cprintf("return addr\n");
	return PTE_ADDR(p[PTX(va)]);
f0100ea2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100ea7:	eb 05                	jmp    f0100eae <check_va2pa+0x64>
f0100ea9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100eae:	c9                   	leave  
f0100eaf:	c3                   	ret    

f0100eb0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100eb0:	55                   	push   %ebp
f0100eb1:	89 e5                	mov    %esp,%ebp
f0100eb3:	83 ec 18             	sub    $0x18,%esp
f0100eb6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100eb9:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100ebc:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ebe:	89 04 24             	mov    %eax,(%esp)
f0100ec1:	e8 da 33 00 00       	call   f01042a0 <mc146818_read>
f0100ec6:	89 c6                	mov    %eax,%esi
f0100ec8:	83 c3 01             	add    $0x1,%ebx
f0100ecb:	89 1c 24             	mov    %ebx,(%esp)
f0100ece:	e8 cd 33 00 00       	call   f01042a0 <mc146818_read>
f0100ed3:	c1 e0 08             	shl    $0x8,%eax
f0100ed6:	09 f0                	or     %esi,%eax
}
f0100ed8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100edb:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100ede:	89 ec                	mov    %ebp,%esp
f0100ee0:	5d                   	pop    %ebp
f0100ee1:	c3                   	ret    

f0100ee2 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ee2:	55                   	push   %ebp
f0100ee3:	89 e5                	mov    %esp,%ebp
f0100ee5:	57                   	push   %edi
f0100ee6:	56                   	push   %esi
f0100ee7:	53                   	push   %ebx
f0100ee8:	83 ec 5c             	sub    $0x5c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100eeb:	83 f8 01             	cmp    $0x1,%eax
f0100eee:	19 f6                	sbb    %esi,%esi
f0100ef0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100ef6:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100ef9:	8b 1d 30 c2 1d f0    	mov    0xf01dc230,%ebx
f0100eff:	85 db                	test   %ebx,%ebx
f0100f01:	75 1c                	jne    f0100f1f <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f0100f03:	c7 44 24 08 84 7c 10 	movl   $0xf0107c84,0x8(%esp)
f0100f0a:	f0 
f0100f0b:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0100f12:	00 
f0100f13:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0100f1a:	e8 66 f1 ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f0100f1f:	85 c0                	test   %eax,%eax
f0100f21:	74 52                	je     f0100f75 <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100f23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f26:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f29:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100f2c:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f2f:	8b 0d 90 ce 1d f0    	mov    0xf01dce90,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f35:	89 d8                	mov    %ebx,%eax
f0100f37:	29 c8                	sub    %ecx,%eax
f0100f39:	c1 e0 09             	shl    $0x9,%eax
f0100f3c:	c1 e8 16             	shr    $0x16,%eax
f0100f3f:	39 c6                	cmp    %eax,%esi
f0100f41:	0f 96 c0             	setbe  %al
f0100f44:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100f47:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100f4b:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100f4d:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f51:	8b 1b                	mov    (%ebx),%ebx
f0100f53:	85 db                	test   %ebx,%ebx
f0100f55:	75 de                	jne    f0100f35 <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f57:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f60:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f63:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f66:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f68:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f6b:	89 1d 30 c2 1d f0    	mov    %ebx,0xf01dc230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100f71:	85 db                	test   %ebx,%ebx
f0100f73:	74 67                	je     f0100fdc <check_page_free_list+0xfa>
f0100f75:	89 d8                	mov    %ebx,%eax
f0100f77:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f0100f7d:	c1 f8 03             	sar    $0x3,%eax
f0100f80:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100f83:	89 c2                	mov    %eax,%edx
f0100f85:	c1 ea 16             	shr    $0x16,%edx
f0100f88:	39 d6                	cmp    %edx,%esi
f0100f8a:	76 4a                	jbe    f0100fd6 <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f8c:	89 c2                	mov    %eax,%edx
f0100f8e:	c1 ea 0c             	shr    $0xc,%edx
f0100f91:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f0100f97:	72 20                	jb     f0100fb9 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f9d:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0100fa4:	f0 
f0100fa5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100fac:	00 
f0100fad:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0100fb4:	e8 cc f0 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100fb9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100fc0:	00 
f0100fc1:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100fc8:	00 
f0100fc9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fce:	89 04 24             	mov    %eax,(%esp)
f0100fd1:	e8 e0 58 00 00       	call   f01068b6 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100fd6:	8b 1b                	mov    (%ebx),%ebx
f0100fd8:	85 db                	test   %ebx,%ebx
f0100fda:	75 99                	jne    f0100f75 <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0100fdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fe1:	e8 6a fd ff ff       	call   f0100d50 <boot_alloc>
f0100fe6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fe9:	8b 15 30 c2 1d f0    	mov    0xf01dc230,%edx
f0100fef:	85 d2                	test   %edx,%edx
f0100ff1:	0f 84 3c 02 00 00    	je     f0101233 <check_page_free_list+0x351>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ff7:	8b 1d 90 ce 1d f0    	mov    0xf01dce90,%ebx
f0100ffd:	39 da                	cmp    %ebx,%edx
f0100fff:	72 51                	jb     f0101052 <check_page_free_list+0x170>
		assert(pp < pages + npages);
f0101001:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f0101006:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101009:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f010100c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010100f:	39 c2                	cmp    %eax,%edx
f0101011:	73 68                	jae    f010107b <check_page_free_list+0x199>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101013:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101016:	89 d0                	mov    %edx,%eax
f0101018:	29 d8                	sub    %ebx,%eax
f010101a:	a8 07                	test   $0x7,%al
f010101c:	0f 85 86 00 00 00    	jne    f01010a8 <check_page_free_list+0x1c6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101022:	c1 f8 03             	sar    $0x3,%eax
f0101025:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101028:	85 c0                	test   %eax,%eax
f010102a:	0f 84 a6 00 00 00    	je     f01010d6 <check_page_free_list+0x1f4>
		assert(page2pa(pp) != IOPHYSMEM);
f0101030:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101035:	0f 84 c6 00 00 00    	je     f0101101 <check_page_free_list+0x21f>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010103b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101040:	0f 85 0a 01 00 00    	jne    f0101150 <check_page_free_list+0x26e>
f0101046:	66 90                	xchg   %ax,%ax
f0101048:	e9 df 00 00 00       	jmp    f010112c <check_page_free_list+0x24a>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010104d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0101050:	73 24                	jae    f0101076 <check_page_free_list+0x194>
f0101052:	c7 44 24 0c bb 83 10 	movl   $0xf01083bb,0xc(%esp)
f0101059:	f0 
f010105a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101061:	f0 
f0101062:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101069:	00 
f010106a:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101071:	e8 0f f0 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101076:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101079:	72 24                	jb     f010109f <check_page_free_list+0x1bd>
f010107b:	c7 44 24 0c dc 83 10 	movl   $0xf01083dc,0xc(%esp)
f0101082:	f0 
f0101083:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010108a:	f0 
f010108b:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101092:	00 
f0101093:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010109a:	e8 e6 ef ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f010109f:	89 d0                	mov    %edx,%eax
f01010a1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01010a4:	a8 07                	test   $0x7,%al
f01010a6:	74 24                	je     f01010cc <check_page_free_list+0x1ea>
f01010a8:	c7 44 24 0c a8 7c 10 	movl   $0xf0107ca8,0xc(%esp)
f01010af:	f0 
f01010b0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01010b7:	f0 
f01010b8:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f01010bf:	00 
f01010c0:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01010c7:	e8 b9 ef ff ff       	call   f0100085 <_panic>
f01010cc:	c1 f8 03             	sar    $0x3,%eax
f01010cf:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010d2:	85 c0                	test   %eax,%eax
f01010d4:	75 24                	jne    f01010fa <check_page_free_list+0x218>
f01010d6:	c7 44 24 0c f0 83 10 	movl   $0xf01083f0,0xc(%esp)
f01010dd:	f0 
f01010de:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01010e5:	f0 
f01010e6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f01010ed:	00 
f01010ee:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01010f5:	e8 8b ef ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f01010fa:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01010ff:	75 24                	jne    f0101125 <check_page_free_list+0x243>
f0101101:	c7 44 24 0c 01 84 10 	movl   $0xf0108401,0xc(%esp)
f0101108:	f0 
f0101109:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101110:	f0 
f0101111:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101118:	00 
f0101119:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101120:	e8 60 ef ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101125:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010112a:	75 31                	jne    f010115d <check_page_free_list+0x27b>
f010112c:	c7 44 24 0c dc 7c 10 	movl   $0xf0107cdc,0xc(%esp)
f0101133:	f0 
f0101134:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010113b:	f0 
f010113c:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101143:	00 
f0101144:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010114b:	e8 35 ef ff ff       	call   f0100085 <_panic>
f0101150:	be 00 00 00 00       	mov    $0x0,%esi
f0101155:	bf 00 00 00 00       	mov    $0x0,%edi
f010115a:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f010115d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101162:	75 24                	jne    f0101188 <check_page_free_list+0x2a6>
f0101164:	c7 44 24 0c 1a 84 10 	movl   $0xf010841a,0xc(%esp)
f010116b:	f0 
f010116c:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101173:	f0 
f0101174:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f010117b:	00 
f010117c:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101183:	e8 fd ee ff ff       	call   f0100085 <_panic>
f0101188:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010118a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010118f:	76 59                	jbe    f01011ea <check_page_free_list+0x308>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101191:	89 c3                	mov    %eax,%ebx
f0101193:	c1 eb 0c             	shr    $0xc,%ebx
f0101196:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101199:	77 20                	ja     f01011bb <check_page_free_list+0x2d9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010119b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010119f:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f01011a6:	f0 
f01011a7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01011ae:	00 
f01011af:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01011b6:	e8 ca ee ff ff       	call   f0100085 <_panic>
f01011bb:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01011c1:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01011c4:	76 24                	jbe    f01011ea <check_page_free_list+0x308>
f01011c6:	c7 44 24 0c 00 7d 10 	movl   $0xf0107d00,0xc(%esp)
f01011cd:	f0 
f01011ce:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01011d5:	f0 
f01011d6:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f01011dd:	00 
f01011de:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01011e5:	e8 9b ee ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011ea:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011ef:	75 24                	jne    f0101215 <check_page_free_list+0x333>
f01011f1:	c7 44 24 0c 34 84 10 	movl   $0xf0108434,0xc(%esp)
f01011f8:	f0 
f01011f9:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101200:	f0 
f0101201:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101208:	00 
f0101209:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101210:	e8 70 ee ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0101215:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f010121b:	77 05                	ja     f0101222 <check_page_free_list+0x340>
			++nfree_basemem;
f010121d:	83 c7 01             	add    $0x1,%edi
f0101220:	eb 03                	jmp    f0101225 <check_page_free_list+0x343>
		else
			++nfree_extmem;
f0101222:	83 c6 01             	add    $0x1,%esi
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101225:	8b 12                	mov    (%edx),%edx
f0101227:	85 d2                	test   %edx,%edx
f0101229:	0f 85 1e fe ff ff    	jne    f010104d <check_page_free_list+0x16b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010122f:	85 ff                	test   %edi,%edi
f0101231:	7f 24                	jg     f0101257 <check_page_free_list+0x375>
f0101233:	c7 44 24 0c 51 84 10 	movl   $0xf0108451,0xc(%esp)
f010123a:	f0 
f010123b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101242:	f0 
f0101243:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f010124a:	00 
f010124b:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101252:	e8 2e ee ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f0101257:	85 f6                	test   %esi,%esi
f0101259:	7f 24                	jg     f010127f <check_page_free_list+0x39d>
f010125b:	c7 44 24 0c 63 84 10 	movl   $0xf0108463,0xc(%esp)
f0101262:	f0 
f0101263:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010126a:	f0 
f010126b:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101272:	00 
f0101273:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010127a:	e8 06 ee ff ff       	call   f0100085 <_panic>
}
f010127f:	83 c4 5c             	add    $0x5c,%esp
f0101282:	5b                   	pop    %ebx
f0101283:	5e                   	pop    %esi
f0101284:	5f                   	pop    %edi
f0101285:	5d                   	pop    %ebp
f0101286:	c3                   	ret    

f0101287 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101287:	55                   	push   %ebp
f0101288:	89 e5                	mov    %esp,%ebp
f010128a:	57                   	push   %edi
f010128b:	56                   	push   %esi
f010128c:	53                   	push   %ebx
f010128d:	83 ec 2c             	sub    $0x2c,%esp
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101290:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f0101295:	83 f8 07             	cmp    $0x7,%eax
f0101298:	77 1c                	ja     f01012b6 <page_init+0x2f>
		panic("pa2page called with invalid pa");
f010129a:	c7 44 24 08 48 7d 10 	movl   $0xf0107d48,0x8(%esp)
f01012a1:	f0 
f01012a2:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01012a9:	00 
f01012aa:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01012b1:	e8 cf ed ff ff       	call   f0100085 <_panic>
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list = NULL;
f01012b6:	c7 05 30 c2 1d f0 00 	movl   $0x0,0xf01dc230
f01012bd:	00 00 00 
	size_t i;
	//cprintf("%d\t%d\t%d\n",PGNUM(EXTPHYSMEM),npages,up);
	for (i = 0; i < npages; i++) {
f01012c0:	85 c0                	test   %eax,%eax
f01012c2:	0f 85 a4 00 00 00    	jne    f010136c <page_init+0xe5>
f01012c8:	e9 b6 00 00 00       	jmp    f0101383 <page_init+0xfc>
f01012cd:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
		pages[i].pp_ref = 0;
f01012d4:	a1 90 ce 1d f0       	mov    0xf01dce90,%eax
f01012d9:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		if(i == 0)
f01012e0:	85 db                	test   %ebx,%ebx
f01012e2:	74 71                	je     f0101355 <page_init+0xce>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01012e4:	89 f0                	mov    %esi,%eax
f01012e6:	c1 e0 09             	shl    $0x9,%eax
			continue;
		if (page2pa(&pages[i]) == MPENTRY_PADDR)
f01012e9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01012ee:	74 65                	je     f0101355 <page_init+0xce>
f01012f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		if(	page2pa(&pages[i]) >= IOPHYSMEM && 
f01012f3:	3d ff ff 09 00       	cmp    $0x9ffff,%eax
f01012f8:	76 4b                	jbe    f0101345 <page_init+0xbe>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012fa:	c1 e8 0c             	shr    $0xc,%eax
f01012fd:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0101303:	72 29                	jb     f010132e <page_init+0xa7>
f0101305:	89 3d 30 c2 1d f0    	mov    %edi,0xf01dc230
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010130b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010130e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101312:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0101319:	f0 
f010131a:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101321:	00 
f0101322:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0101329:	e8 57 ed ff ff       	call   f0100085 <_panic>
			page2kva(&pages[i]) < boot_alloc(0)) 
f010132e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101333:	e8 18 fa ff ff       	call   f0100d50 <boot_alloc>
		pages[i].pp_ref = 0;
		if(i == 0)
			continue;
		if (page2pa(&pages[i]) == MPENTRY_PADDR)
			continue;
		if(	page2pa(&pages[i]) >= IOPHYSMEM && 
f0101338:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010133b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101341:	39 d0                	cmp    %edx,%eax
f0101343:	77 10                	ja     f0101355 <page_init+0xce>
			page2kva(&pages[i]) < boot_alloc(0)) 
			continue;
		pages[i].pp_link = page_free_list;
f0101345:	a1 90 ce 1d f0       	mov    0xf01dce90,%eax
f010134a:	89 3c 30             	mov    %edi,(%eax,%esi,1)
		page_free_list = &pages[i];
f010134d:	89 f7                	mov    %esi,%edi
f010134f:	03 3d 90 ce 1d f0    	add    0xf01dce90,%edi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list = NULL;
	size_t i;
	//cprintf("%d\t%d\t%d\n",PGNUM(EXTPHYSMEM),npages,up);
	for (i = 0; i < npages; i++) {
f0101355:	83 c3 01             	add    $0x1,%ebx
f0101358:	39 1d 88 ce 1d f0    	cmp    %ebx,0xf01dce88
f010135e:	0f 87 69 ff ff ff    	ja     f01012cd <page_init+0x46>
f0101364:	89 3d 30 c2 1d f0    	mov    %edi,0xf01dc230
f010136a:	eb 17                	jmp    f0101383 <page_init+0xfc>
		pages[i].pp_ref = 0;
f010136c:	a1 90 ce 1d f0       	mov    0xf01dce90,%eax
f0101371:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
f0101377:	bf 00 00 00 00       	mov    $0x0,%edi
f010137c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101381:	eb d2                	jmp    f0101355 <page_init+0xce>
			page2kva(&pages[i]) < boot_alloc(0)) 
			continue;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0101383:	83 c4 2c             	add    $0x2c,%esp
f0101386:	5b                   	pop    %ebx
f0101387:	5e                   	pop    %esi
f0101388:	5f                   	pop    %edi
f0101389:	5d                   	pop    %ebp
f010138a:	c3                   	ret    

f010138b <page_alloc_4pages>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc_4pages(int alloc_flags)
{
f010138b:	55                   	push   %ebp
f010138c:	89 e5                	mov    %esp,%ebp
f010138e:	57                   	push   %edi
f010138f:	56                   	push   %esi
f0101390:	53                   	push   %ebx
f0101391:	83 ec 5c             	sub    $0x5c,%esp
	// Fill this function
	struct Page  head; //
	struct Page* result,*first_free;
	struct Page	*check,*find;
	struct Page* last[4] = {NULL,NULL,NULL,NULL};
f0101394:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f010139b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01013a2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01013a9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	
	//check if there are enough space and continuous space
	check = page_free_list;
f01013b0:	a1 30 c2 1d f0       	mov    0xf01dc230,%eax
f01013b5:	89 45 b8             	mov    %eax,-0x48(%ebp)
	while(check != NULL)
f01013b8:	85 c0                	test   %eax,%eax
f01013ba:	0f 84 cc 02 00 00    	je     f010168c <page_alloc_4pages+0x301>
		check = check->pp_link;
f01013c0:	8b 00                	mov    (%eax),%eax
	struct Page	*check,*find;
	struct Page* last[4] = {NULL,NULL,NULL,NULL};
	
	//check if there are enough space and continuous space
	check = page_free_list;
	while(check != NULL)
f01013c2:	85 c0                	test   %eax,%eax
f01013c4:	75 fa                	jne    f01013c0 <page_alloc_4pages+0x35>
f01013c6:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01013c9:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01013cc:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
		if(i == 4 && find == NULL)
		{
			//cprintf("find here:%d\n",PGNUM(page2pa(check)));
			find = check;
			check = &head;
			check->pp_link = page_free_list;
f01013d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01013d6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01013d9:	e9 58 01 00 00       	jmp    f0101536 <page_alloc_4pages+0x1ab>
	struct Page	*check,*find;
	struct Page* last[4] = {NULL,NULL,NULL,NULL};
	
	//check if there are enough space and continuous space
	check = page_free_list;
	while(check != NULL)
f01013de:	89 df                	mov    %ebx,%edi
f01013e0:	c1 e7 0c             	shl    $0xc,%edi
		//if(find == NULL)
			//cprintf("show:%d\n",PGNUM(page2pa(check))); 
		for(i=0;find == NULL && i<4 ;i++)//how to improve the efficience can i use a flag?
		{
			//cprintf("%d\n",i);
			if(PGNUM(page2pa(check)+PGSIZE*i) >= npages)
f01013e3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01013e6:	2b 35 90 ce 1d f0    	sub    0xf01dce90,%esi
f01013ec:	c1 fe 03             	sar    $0x3,%esi
f01013ef:	c1 e6 0c             	shl    $0xc,%esi
f01013f2:	8d 34 37             	lea    (%edi,%esi,1),%esi
f01013f5:	89 f0                	mov    %esi,%eax
f01013f7:	c1 e8 0c             	shr    $0xc,%eax
f01013fa:	8b 15 88 ce 1d f0    	mov    0xf01dce88,%edx
f0101400:	39 d0                	cmp    %edx,%eax
f0101402:	0f 83 0f 01 00 00    	jae    f0101517 <page_alloc_4pages+0x18c>
				break;	
			//cprintf("return1\n");
			if(	page2pa(check)+PGSIZE*i >= IOPHYSMEM && 
f0101408:	81 fe ff ff 09 00    	cmp    $0x9ffff,%esi
f010140e:	76 38                	jbe    f0101448 <page_alloc_4pages+0xbd>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101410:	39 d0                	cmp    %edx,%eax
f0101412:	72 20                	jb     f0101434 <page_alloc_4pages+0xa9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101414:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101418:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f010141f:	f0 
f0101420:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
f0101427:	00 
f0101428:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010142f:	e8 51 ec ff ff       	call   f0100085 <_panic>
				KADDR(page2pa(check)+PGSIZE*i) < boot_alloc(0)) 
f0101434:	b8 00 00 00 00       	mov    $0x0,%eax
f0101439:	e8 12 f9 ff ff       	call   f0100d50 <boot_alloc>
		{
			//cprintf("%d\n",i);
			if(PGNUM(page2pa(check)+PGSIZE*i) >= npages)
				break;	
			//cprintf("return1\n");
			if(	page2pa(check)+PGSIZE*i >= IOPHYSMEM && 
f010143e:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0101444:	39 f0                	cmp    %esi,%eax
f0101446:	77 55                	ja     f010149d <page_alloc_4pages+0x112>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101448:	a1 90 ce 1d f0       	mov    0xf01dce90,%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010144d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101450:	29 c2                	sub    %eax,%edx
f0101452:	c1 fa 03             	sar    $0x3,%edx
f0101455:	c1 e2 0c             	shl    $0xc,%edx
f0101458:	01 d7                	add    %edx,%edi
f010145a:	c1 ef 0c             	shr    $0xc,%edi
f010145d:	3b 3d 88 ce 1d f0    	cmp    0xf01dce88,%edi
f0101463:	72 1c                	jb     f0101481 <page_alloc_4pages+0xf6>
		panic("pa2page called with invalid pa");
f0101465:	c7 44 24 08 48 7d 10 	movl   $0xf0107d48,0x8(%esp)
f010146c:	f0 
f010146d:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101474:	00 
f0101475:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f010147c:	e8 04 ec ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101481:	8d 04 f8             	lea    (%eax,%edi,8),%eax
				KADDR(page2pa(check)+PGSIZE*i) < boot_alloc(0)) 
				break;
			//cprintf("return2\n");
			if(	((struct Page*)pa2page(page2pa(check)+PGSIZE*i))->pp_link == NULL )//there is a bug I know
f0101484:	83 38 00             	cmpl   $0x0,(%eax)
f0101487:	74 14                	je     f010149d <page_alloc_4pages+0x112>
			else
			{
				//cprintf("return3\n");

				//cprintf("addrppp:%d\n",((struct Page*)pa2page(page2pa(check)+PGSIZE*i))->pp_ref);//0
				(((struct Page*)pa2page(page2pa(check)+PGSIZE*i))->pp_ref)=0xffff;
f0101489:	66 c7 40 04 ff ff    	movw   $0xffff,0x4(%eax)
	while(check != NULL)
	{
		//if(PGNUM(page2pa(check))<1030 && PGNUM(page2pa(check))>1000)
		//if(find == NULL)
			//cprintf("show:%d\n",PGNUM(page2pa(check))); 
		for(i=0;find == NULL && i<4 ;i++)//how to improve the efficience can i use a flag?
f010148f:	83 c3 01             	add    $0x1,%ebx
f0101492:	83 fb 04             	cmp    $0x4,%ebx
f0101495:	0f 85 43 ff ff ff    	jne    f01013de <page_alloc_4pages+0x53>
f010149b:	eb 05                	jmp    f01014a2 <page_alloc_4pages+0x117>
				//cprintf("the continous page:%d\n",PGNUM(page2pa(check)+PGSIZE*i));
			}

		}	
		//this means finding a continuous 4 space and for loop will not excute any more
		if(i == 4 && find == NULL)
f010149d:	83 fb 04             	cmp    $0x4,%ebx
f01014a0:	75 75                	jne    f0101517 <page_alloc_4pages+0x18c>
		{
			//cprintf("find here:%d\n",PGNUM(page2pa(check)));
			find = check;
			check = &head;
			check->pp_link = page_free_list;
f01014a2:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01014a5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01014a8:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01014ab:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01014ae:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01014b1:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01014b4:	eb 61                	jmp    f0101517 <page_alloc_4pages+0x18c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01014b6:	89 f3                	mov    %esi,%ebx
f01014b8:	2b 1d 90 ce 1d f0    	sub    0xf01dce90,%ebx
f01014be:	c1 fb 03             	sar    $0x3,%ebx
f01014c1:	c1 e3 0c             	shl    $0xc,%ebx
		}
		//cprintf("findfind:%d\n",PGNUM(page2pa(find)));
		while(check->pp_link->pp_ref == 0xffff)
		{
			//cprintf("findfind:%d\n",PGNUM(page2pa(check)));
			findlow = PGNUM(page2pa(find));
f01014c4:	89 df                	mov    %ebx,%edi
f01014c6:	c1 ef 0c             	shr    $0xc,%edi
			findup	= PGNUM(page2pa(find)+PGSIZE*3);
			checknum= PGNUM(page2pa(check->pp_link));
f01014c9:	89 c1                	mov    %eax,%ecx
f01014cb:	2b 0d 90 ce 1d f0    	sub    0xf01dce90,%ecx
f01014d1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01014d4:	c1 f9 03             	sar    $0x3,%ecx
f01014d7:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
			if(find != NULL && checknum >= findlow && checknum <= findup)
f01014dd:	85 f6                	test   %esi,%esi
f01014df:	74 28                	je     f0101509 <page_alloc_4pages+0x17e>
f01014e1:	39 f9                	cmp    %edi,%ecx
f01014e3:	72 24                	jb     f0101509 <page_alloc_4pages+0x17e>
f01014e5:	81 c3 00 30 00 00    	add    $0x3000,%ebx
f01014eb:	c1 eb 0c             	shr    $0xc,%ebx
f01014ee:	39 cb                	cmp    %ecx,%ebx
f01014f0:	72 17                	jb     f0101509 <page_alloc_4pages+0x17e>
			{
				//cprintf("ever here get%d\n",checknum - findlow);
				if(check == &head)
f01014f2:	39 55 b4             	cmp    %edx,-0x4c(%ebp)
f01014f5:	75 0c                	jne    f0101503 <page_alloc_4pages+0x178>
					last[checknum - findlow] = NULL;
f01014f7:	29 f9                	sub    %edi,%ecx
f01014f9:	c7 44 8d d0 00 00 00 	movl   $0x0,-0x30(%ebp,%ecx,4)
f0101500:	00 
f0101501:	eb 06                	jmp    f0101509 <page_alloc_4pages+0x17e>
				else
					last[checknum - findlow] = check;
f0101503:	29 f9                	sub    %edi,%ecx
f0101505:	89 54 8d d0          	mov    %edx,-0x30(%ebp,%ecx,4)
			}
			check->pp_link->pp_ref = 0;
f0101509:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			check = check->pp_link;
f010150f:	8b 12                	mov    (%edx),%edx
			//cprintf("nextaddr:%d\n",PGNUM(page2pa(check)));
			if(check == NULL)
f0101511:	85 d2                	test   %edx,%edx
f0101513:	75 08                	jne    f010151d <page_alloc_4pages+0x192>
f0101515:	eb 58                	jmp    f010156f <page_alloc_4pages+0x1e4>
f0101517:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010151a:	8b 55 c0             	mov    -0x40(%ebp),%edx
			find = check;
			check = &head;
			check->pp_link = page_free_list;
		}
		//cprintf("findfind:%d\n",PGNUM(page2pa(find)));
		while(check->pp_link->pp_ref == 0xffff)
f010151d:	8b 02                	mov    (%edx),%eax
f010151f:	66 83 78 04 ff       	cmpw   $0xffffffff,0x4(%eax)
f0101524:	74 90                	je     f01014b6 <page_alloc_4pages+0x12b>
f0101526:	89 55 c0             	mov    %edx,-0x40(%ebp)
			if(check == NULL)
				break;
		}
		//if(check->pp_link == NULL)
			//cprintf("check buff done\n");
		if(check != NULL)
f0101529:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f010152d:	74 40                	je     f010156f <page_alloc_4pages+0x1e4>
	check = page_free_list;
	//cprintf("first page:%d\n",PGNUM(page2pa(check)));
	find = NULL;
	physaddr_t findlow,findup,checknum;
	int i = 0;
	while(check != NULL)
f010152f:	85 c0                	test   %eax,%eax
f0101531:	74 3c                	je     f010156f <page_alloc_4pages+0x1e4>
f0101533:	89 45 c0             	mov    %eax,-0x40(%ebp)
	{
		//if(PGNUM(page2pa(check))<1030 && PGNUM(page2pa(check))>1000)
		//if(find == NULL)
			//cprintf("show:%d\n",PGNUM(page2pa(check))); 
		for(i=0;find == NULL && i<4 ;i++)//how to improve the efficience can i use a flag?
f0101536:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f010153a:	75 db                	jne    f0101517 <page_alloc_4pages+0x18c>
f010153c:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010153f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101542:	89 c6                	mov    %eax,%esi
f0101544:	2b 35 90 ce 1d f0    	sub    0xf01dce90,%esi
f010154a:	c1 fe 03             	sar    $0x3,%esi
f010154d:	c1 e6 0c             	shl    $0xc,%esi
		{
			//cprintf("%d\n",i);
			if(PGNUM(page2pa(check)+PGSIZE*i) >= npages)
f0101550:	89 f0                	mov    %esi,%eax
f0101552:	c1 e8 0c             	shr    $0xc,%eax
f0101555:	8b 15 88 ce 1d f0    	mov    0xf01dce88,%edx
f010155b:	bf 00 00 00 00       	mov    $0x0,%edi
f0101560:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101565:	39 c2                	cmp    %eax,%edx
f0101567:	0f 87 9b fe ff ff    	ja     f0101408 <page_alloc_4pages+0x7d>
f010156d:	eb a8                	jmp    f0101517 <page_alloc_4pages+0x18c>
		//if(check->pp_link == NULL)
			//cprintf("check buff done\n");
		if(check != NULL)
			check = check->pp_link;
	}
	if(find == NULL)
f010156f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0101573:	0f 84 13 01 00 00    	je     f010168c <page_alloc_4pages+0x301>
f0101579:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010157c:	8b 15 90 ce 1d f0    	mov    0xf01dce90,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101582:	89 c8                	mov    %ecx,%eax
f0101584:	29 d0                	sub    %edx,%eax
f0101586:	c1 f8 03             	sar    $0x3,%eax
f0101589:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010158e:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0101594:	72 3f                	jb     f01015d5 <page_alloc_4pages+0x24a>
f0101596:	eb 21                	jmp    f01015b9 <page_alloc_4pages+0x22e>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101598:	8b 15 90 ce 1d f0    	mov    0xf01dce90,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010159e:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01015a1:	29 d0                	sub    %edx,%eax
f01015a3:	c1 f8 03             	sar    $0x3,%eax
f01015a6:	8d 04 30             	lea    (%eax,%esi,1),%eax
f01015a9:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015ae:	83 c6 01             	add    $0x1,%esi
f01015b1:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f01015b7:	72 34                	jb     f01015ed <page_alloc_4pages+0x262>
		panic("pa2page called with invalid pa");
f01015b9:	c7 44 24 08 48 7d 10 	movl   $0xf0107d48,0x8(%esp)
f01015c0:	f0 
f01015c1:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01015c8:	00 
f01015c9:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01015d0:	e8 b0 ea ff ff       	call   f0100085 <_panic>
f01015d5:	be 01 00 00 00       	mov    $0x1,%esi
f01015da:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
	{
		
		//cprintf("get first\n");
		first_free = (struct Page*)pa2page(page2pa(find)+PGSIZE*i);
		//cprintf("remove from list\n");
		if(last[i] ==  NULL)
f01015e1:	8d 7d d0             	lea    -0x30(%ebp),%edi
		{
			last[i]->pp_link = first_free->pp_link;
		}
		//cprintf("initial,%d\t%d\t%x\t%x\n",first_free->pp_ref,PGNUM(page2pa(find)+PGSIZE*i),page2pa(find)+PGSIZE*i,page2kva(first_free));
		first_free->pp_link = NULL;	
		if(alloc_flags & ALLOC_ZERO)
f01015e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015e7:	83 e1 01             	and    $0x1,%ecx
f01015ea:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
	return &pages[PGNUM(pa)];
f01015ed:	8d 1c c2             	lea    (%edx,%eax,8),%ebx
	{
		
		//cprintf("get first\n");
		first_free = (struct Page*)pa2page(page2pa(find)+PGSIZE*i);
		//cprintf("remove from list\n");
		if(last[i] ==  NULL)
f01015f0:	8b 44 b7 fc          	mov    -0x4(%edi,%esi,4),%eax
f01015f4:	85 c0                	test   %eax,%eax
f01015f6:	75 09                	jne    f0101601 <page_alloc_4pages+0x276>
		{
			//cprintf("come here\n");
			page_free_list = first_free->pp_link;
f01015f8:	8b 03                	mov    (%ebx),%eax
f01015fa:	a3 30 c2 1d f0       	mov    %eax,0xf01dc230
f01015ff:	eb 04                	jmp    f0101605 <page_alloc_4pages+0x27a>
		}
		else
		{
			last[i]->pp_link = first_free->pp_link;
f0101601:	8b 13                	mov    (%ebx),%edx
f0101603:	89 10                	mov    %edx,(%eax)
		}
		//cprintf("initial,%d\t%d\t%x\t%x\n",first_free->pp_ref,PGNUM(page2pa(find)+PGSIZE*i),page2pa(find)+PGSIZE*i,page2kva(first_free));
		first_free->pp_link = NULL;	
f0101605:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(alloc_flags & ALLOC_ZERO)
f010160b:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f010160f:	74 58                	je     f0101669 <page_alloc_4pages+0x2de>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101611:	89 d8                	mov    %ebx,%eax
f0101613:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f0101619:	c1 f8 03             	sar    $0x3,%eax
f010161c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010161f:	89 c2                	mov    %eax,%edx
f0101621:	c1 ea 0c             	shr    $0xc,%edx
f0101624:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f010162a:	72 20                	jb     f010164c <page_alloc_4pages+0x2c1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010162c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101630:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0101637:	f0 
f0101638:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010163f:	00 
f0101640:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0101647:	e8 39 ea ff ff       	call   f0100085 <_panic>
		{
			//cprintf("do here?\n");
			memset((char*)page2kva(first_free), 0, PGSIZE);
f010164c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101653:	00 
f0101654:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010165b:	00 
f010165c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101661:	89 04 24             	mov    %eax,(%esp)
f0101664:	e8 4d 52 00 00       	call   f01068b6 <memset>
		}
		//cprintf("add to result\n");
		if(i == 0)
f0101669:	83 fe 01             	cmp    $0x1,%esi
f010166c:	75 0b                	jne    f0101679 <page_alloc_4pages+0x2ee>
		{
			result = first_free;
			last[0] = result;
f010166e:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101671:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0101674:	e9 1f ff ff ff       	jmp    f0101598 <page_alloc_4pages+0x20d>
			continue;
		}
		last[0]->pp_link = first_free;
f0101679:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010167c:	89 18                	mov    %ebx,(%eax)
		last[0] = first_free;
f010167e:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	if(find == NULL)
		return NULL;
	//cprintf("find\n");
	result = NULL;
	first_free = NULL;
	for(i=0;i<4;i++)
f0101681:	83 fe 03             	cmp    $0x3,%esi
f0101684:	0f 8e 0e ff ff ff    	jle    f0101598 <page_alloc_4pages+0x20d>
f010168a:	eb 07                	jmp    f0101693 <page_alloc_4pages+0x308>
f010168c:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
		last[0] = first_free;
	}
	//result->pp_ref = 0x0fff; //different from other alloc page,it's really tricky
	//cprintf("out\n");
	return result;
}
f0101693:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0101696:	83 c4 5c             	add    $0x5c,%esp
f0101699:	5b                   	pop    %ebx
f010169a:	5e                   	pop    %esi
f010169b:	5f                   	pop    %edi
f010169c:	5d                   	pop    %ebp
f010169d:	c3                   	ret    

f010169e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f010169e:	55                   	push   %ebp
f010169f:	89 e5                	mov    %esp,%ebp
f01016a1:	53                   	push   %ebx
f01016a2:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list != NULL)
f01016a5:	8b 1d 30 c2 1d f0    	mov    0xf01dc230,%ebx
f01016ab:	85 db                	test   %ebx,%ebx
f01016ad:	74 6b                	je     f010171a <page_alloc+0x7c>
	{
		struct Page* result;
		//get first
		result = page_free_list;
		//remove from list
		page_free_list = page_free_list->pp_link;
f01016af:	8b 03                	mov    (%ebx),%eax
f01016b1:	a3 30 c2 1d f0       	mov    %eax,0xf01dc230
		if(alloc_flags & ALLOC_ZERO)
f01016b6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01016ba:	74 58                	je     f0101714 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01016bc:	89 d8                	mov    %ebx,%eax
f01016be:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f01016c4:	c1 f8 03             	sar    $0x3,%eax
f01016c7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016ca:	89 c2                	mov    %eax,%edx
f01016cc:	c1 ea 0c             	shr    $0xc,%edx
f01016cf:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f01016d5:	72 20                	jb     f01016f7 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016db:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f01016e2:	f0 
f01016e3:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01016ea:	00 
f01016eb:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01016f2:	e8 8e e9 ff ff       	call   f0100085 <_panic>
			memset((char*)page2kva(result), 0, PGSIZE);
f01016f7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01016fe:	00 
f01016ff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101706:	00 
f0101707:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010170c:	89 04 24             	mov    %eax,(%esp)
f010170f:	e8 a2 51 00 00       	call   f01068b6 <memset>
		//return
		result->pp_link = NULL;
f0101714:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return result;
	}
	//cprintf("no free?\n");
	return NULL;
}
f010171a:	89 d8                	mov    %ebx,%eax
f010171c:	83 c4 14             	add    $0x14,%esp
f010171f:	5b                   	pop    %ebx
f0101720:	5d                   	pop    %ebp
f0101721:	c3                   	ret    

f0101722 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101722:	55                   	push   %ebp
f0101723:	89 e5                	mov    %esp,%ebp
f0101725:	83 ec 28             	sub    $0x28,%esp
f0101728:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010172b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010172e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101731:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pde_t*	pde;
	pte_t*	pte;	//it will change,use pointer to trace it
	struct Page* pp;
	pde = &pgdir[PDX(va)];
f0101734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101737:	89 de                	mov    %ebx,%esi
f0101739:	c1 ee 16             	shr    $0x16,%esi
f010173c:	c1 e6 02             	shl    $0x2,%esi
f010173f:	03 75 08             	add    0x8(%ebp),%esi
	if(*pde & PTE_P)
f0101742:	8b 06                	mov    (%esi),%eax
f0101744:	a8 01                	test   $0x1,%al
f0101746:	74 47                	je     f010178f <pgdir_walk+0x6d>
	{
		pte = (pte_t *)KADDR(PTE_ADDR(*pde));
f0101748:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010174d:	89 c2                	mov    %eax,%edx
f010174f:	c1 ea 0c             	shr    $0xc,%edx
f0101752:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f0101758:	72 20                	jb     f010177a <pgdir_walk+0x58>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010175a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010175e:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0101765:	f0 
f0101766:	c7 44 24 04 5a 02 00 	movl   $0x25a,0x4(%esp)
f010176d:	00 
f010176e:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101775:	e8 0b e9 ff ff       	call   f0100085 <_panic>
		return (pte+PTX(va)); 
f010177a:	c1 eb 0a             	shr    $0xa,%ebx
f010177d:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101783:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f010178a:	e9 a4 00 00 00       	jmp    f0101833 <pgdir_walk+0x111>
	}
	if(!create)
f010178f:	85 ff                	test   %edi,%edi
f0101791:	0f 84 97 00 00 00    	je     f010182e <pgdir_walk+0x10c>
	{
		return NULL;
	}
	if( (pp = page_alloc(ALLOC_ZERO)) != NULL)
f0101797:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010179e:	e8 fb fe ff ff       	call   f010169e <page_alloc>
f01017a3:	85 c0                	test   %eax,%eax
f01017a5:	0f 84 83 00 00 00    	je     f010182e <pgdir_walk+0x10c>
	{
		//cprintf("alloc pgnum:%d",PGNUM(page2pa(pp)));
		pp->pp_ref++;
f01017ab:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01017b0:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f01017b6:	c1 f8 03             	sar    $0x3,%eax
f01017b9:	89 c2                	mov    %eax,%edx
f01017bb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017be:	89 d0                	mov    %edx,%eax
f01017c0:	c1 e8 0c             	shr    $0xc,%eax
f01017c3:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f01017c9:	72 20                	jb     f01017eb <pgdir_walk+0xc9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01017cf:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f01017d6:	f0 
f01017d7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01017de:	00 
f01017df:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01017e6:	e8 9a e8 ff ff       	call   f0100085 <_panic>
		pte = page2kva(pp);
f01017eb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01017f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01017f6:	77 20                	ja     f0101818 <pgdir_walk+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01017f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017fc:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0101803:	f0 
f0101804:	c7 44 24 04 66 02 00 	movl   $0x266,0x4(%esp)
f010180b:	00 
f010180c:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101813:	e8 6d e8 ff ff       	call   f0100085 <_panic>
		*pde = PTE_ADDR(PADDR(pte))|create|PTE_W|PTE_U|PTE_P;//it's very strange!!!
f0101818:	83 cf 07             	or     $0x7,%edi
f010181b:	09 fa                	or     %edi,%edx
f010181d:	89 16                	mov    %edx,(%esi)
		return (pte+PTX(va));
f010181f:	c1 eb 0a             	shr    $0xa,%ebx
f0101822:	89 da                	mov    %ebx,%edx
f0101824:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010182a:	01 d0                	add    %edx,%eax
f010182c:	eb 05                	jmp    f0101833 <pgdir_walk+0x111>
f010182e:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//cprintf("no space?\n");
	return NULL;
}
f0101833:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101836:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101839:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010183c:	89 ec                	mov    %ebp,%esp
f010183e:	5d                   	pop    %ebp
f010183f:	c3                   	ret    

f0101840 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101840:	55                   	push   %ebp
f0101841:	89 e5                	mov    %esp,%ebp
f0101843:	57                   	push   %edi
f0101844:	56                   	push   %esi
f0101845:	53                   	push   %ebx
f0101846:	83 ec 2c             	sub    $0x2c,%esp
f0101849:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t lva = (uintptr_t) va;
f010184c:	8b 45 0c             	mov    0xc(%ebp),%eax
	uintptr_t rva = (uintptr_t) va + len - 1;
f010184f:	89 c2                	mov    %eax,%edx
f0101851:	03 55 10             	add    0x10(%ebp),%edx
f0101854:	83 ea 01             	sub    $0x1,%edx
f0101857:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	
	perm = perm|PTE_U|PTE_P;
f010185a:	8b 7d 14             	mov    0x14(%ebp),%edi
f010185d:	83 cf 05             	or     $0x5,%edi
	
	pte_t *pte;
	uintptr_t idx_va;
	for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
f0101860:	39 d0                	cmp    %edx,%eax
f0101862:	77 61                	ja     f01018c5 <user_mem_check+0x85>
		if (idx_va >= ULIM) {
			user_mem_check_addr = idx_va;
			return -E_FAULT;
f0101864:	89 c3                	mov    %eax,%ebx
	perm = perm|PTE_U|PTE_P;
	
	pte_t *pte;
	uintptr_t idx_va;
	for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
		if (idx_va >= ULIM) {
f0101866:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010186b:	76 17                	jbe    f0101884 <user_mem_check+0x44>
f010186d:	eb 08                	jmp    f0101877 <user_mem_check+0x37>
f010186f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101875:	76 0d                	jbe    f0101884 <user_mem_check+0x44>
			user_mem_check_addr = idx_va;
f0101877:	89 1d 3c c2 1d f0    	mov    %ebx,0xf01dc23c
f010187d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f0101882:	eb 46                	jmp    f01018ca <user_mem_check+0x8a>
		}
		pte = pgdir_walk (env->env_pgdir, (void*)idx_va, 0);
f0101884:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010188b:	00 
f010188c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101890:	8b 46 60             	mov    0x60(%esi),%eax
f0101893:	89 04 24             	mov    %eax,(%esp)
f0101896:	e8 87 fe ff ff       	call   f0101722 <pgdir_walk>
		if (pte == NULL || (*pte & perm) != perm) {
f010189b:	85 c0                	test   %eax,%eax
f010189d:	74 08                	je     f01018a7 <user_mem_check+0x67>
f010189f:	8b 00                	mov    (%eax),%eax
f01018a1:	21 f8                	and    %edi,%eax
f01018a3:	39 c7                	cmp    %eax,%edi
f01018a5:	74 0d                	je     f01018b4 <user_mem_check+0x74>
			user_mem_check_addr = idx_va;		
f01018a7:	89 1d 3c c2 1d f0    	mov    %ebx,0xf01dc23c
f01018ad:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f01018b2:	eb 16                	jmp    f01018ca <user_mem_check+0x8a>
		}
		idx_va = ROUNDDOWN (idx_va, PGSIZE);
f01018b4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	perm = perm|PTE_U|PTE_P;
	
	pte_t *pte;
	uintptr_t idx_va;
	for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
f01018ba:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01018c0:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01018c3:	73 aa                	jae    f010186f <user_mem_check+0x2f>
f01018c5:	b8 00 00 00 00       	mov    $0x0,%eax
		}
		idx_va = ROUNDDOWN (idx_va, PGSIZE);
	}

	return 0;
}
f01018ca:	83 c4 2c             	add    $0x2c,%esp
f01018cd:	5b                   	pop    %ebx
f01018ce:	5e                   	pop    %esi
f01018cf:	5f                   	pop    %edi
f01018d0:	5d                   	pop    %ebp
f01018d1:	c3                   	ret    

f01018d2 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01018d2:	55                   	push   %ebp
f01018d3:	89 e5                	mov    %esp,%ebp
f01018d5:	53                   	push   %ebx
f01018d6:	83 ec 14             	sub    $0x14,%esp
f01018d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01018dc:	8b 45 14             	mov    0x14(%ebp),%eax
f01018df:	83 c8 04             	or     $0x4,%eax
f01018e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018e6:	8b 45 10             	mov    0x10(%ebp),%eax
f01018e9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01018f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01018f4:	89 1c 24             	mov    %ebx,(%esp)
f01018f7:	e8 44 ff ff ff       	call   f0101840 <user_mem_check>
f01018fc:	85 c0                	test   %eax,%eax
f01018fe:	79 24                	jns    f0101924 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101900:	a1 3c c2 1d f0       	mov    0xf01dc23c,%eax
f0101905:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101909:	8b 43 48             	mov    0x48(%ebx),%eax
f010190c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101910:	c7 04 24 68 7d 10 f0 	movl   $0xf0107d68,(%esp)
f0101917:	e8 df 2a 00 00       	call   f01043fb <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010191c:	89 1c 24             	mov    %ebx,(%esp)
f010191f:	e8 6d 25 00 00       	call   f0103e91 <env_destroy>
	}
}
f0101924:	83 c4 14             	add    $0x14,%esp
f0101927:	5b                   	pop    %ebx
f0101928:	5d                   	pop    %ebp
f0101929:	c3                   	ret    

f010192a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010192a:	55                   	push   %ebp
f010192b:	89 e5                	mov    %esp,%ebp
f010192d:	53                   	push   %ebx
f010192e:	83 ec 14             	sub    $0x14,%esp
f0101931:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	pte = pgdir_walk(pgdir,va,0);
f0101934:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010193b:	00 
f010193c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010193f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101943:	8b 45 08             	mov    0x8(%ebp),%eax
f0101946:	89 04 24             	mov    %eax,(%esp)
f0101949:	e8 d4 fd ff ff       	call   f0101722 <pgdir_walk>
	if(!pte)
f010194e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101953:	85 c0                	test   %eax,%eax
f0101955:	74 38                	je     f010198f <page_lookup+0x65>
		return NULL;
	if(pte_store)
f0101957:	85 db                	test   %ebx,%ebx
f0101959:	74 02                	je     f010195d <page_lookup+0x33>
		*pte_store = pte;
f010195b:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010195d:	8b 10                	mov    (%eax),%edx
f010195f:	c1 ea 0c             	shr    $0xc,%edx
f0101962:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f0101968:	72 1c                	jb     f0101986 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f010196a:	c7 44 24 08 48 7d 10 	movl   $0xf0107d48,0x8(%esp)
f0101971:	f0 
f0101972:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101979:	00 
f010197a:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0101981:	e8 ff e6 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101986:	c1 e2 03             	shl    $0x3,%edx
f0101989:	03 15 90 ce 1d f0    	add    0xf01dce90,%edx
	return 	pa2page(PTE_ADDR(*pte));
}
f010198f:	89 d0                	mov    %edx,%eax
f0101991:	83 c4 14             	add    $0x14,%esp
f0101994:	5b                   	pop    %ebx
f0101995:	5d                   	pop    %ebp
f0101996:	c3                   	ret    

f0101997 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101997:	55                   	push   %ebp
f0101998:	89 e5                	mov    %esp,%ebp
f010199a:	83 ec 28             	sub    $0x28,%esp
f010199d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01019a0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01019a3:	8b 75 08             	mov    0x8(%ebp),%esi
f01019a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct Page* pp;
	pp = page_lookup(pgdir,va,&pte);
f01019a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01019ac:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019b4:	89 34 24             	mov    %esi,(%esp)
f01019b7:	e8 6e ff ff ff       	call   f010192a <page_lookup>
	//cprintf("what's up?\n");
	if(!pp)
f01019bc:	85 c0                	test   %eax,%eax
f01019be:	74 1d                	je     f01019dd <page_remove+0x46>
		return;
	//cprintf("go on?\n");
	*pte = 0;
f01019c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01019c3:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(pp);
f01019c9:	89 04 24             	mov    %eax,(%esp)
f01019cc:	e8 21 f4 ff ff       	call   f0100df2 <page_decref>
	tlb_invalidate(pgdir,va);
f01019d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019d5:	89 34 24             	mov    %esi,(%esp)
f01019d8:	e8 38 f4 ff ff       	call   f0100e15 <tlb_invalidate>
	
}
f01019dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01019e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01019e3:	89 ec                	mov    %ebp,%esp
f01019e5:	5d                   	pop    %ebp
f01019e6:	c3                   	ret    

f01019e7 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01019e7:	55                   	push   %ebp
f01019e8:	89 e5                	mov    %esp,%ebp
f01019ea:	83 ec 28             	sub    $0x28,%esp
f01019ed:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01019f0:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01019f3:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01019f6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte;
	pte = pgdir_walk(pgdir, va, 0);
f01019f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a00:	00 
f0101a01:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a04:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a08:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a0b:	89 04 24             	mov    %eax,(%esp)
f0101a0e:	e8 0f fd ff ff       	call   f0101722 <pgdir_walk>
f0101a13:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101a15:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	perm = perm | PTE_P;
f0101a1a:	8b 7d 14             	mov    0x14(%ebp),%edi
f0101a1d:	83 cf 01             	or     $0x1,%edi
	if(pte)
f0101a20:	85 c0                	test   %eax,%eax
f0101a22:	74 19                	je     f0101a3d <page_insert+0x56>
	{
		//PTE exists
		if(*pte & PTE_P)
f0101a24:	f6 00 01             	testb  $0x1,(%eax)
f0101a27:	74 3c                	je     f0101a65 <page_insert+0x7e>
		{
			//cprintf("exists\n");
			page_remove(pgdir,va);
f0101a29:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a30:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a33:	89 04 24             	mov    %eax,(%esp)
f0101a36:	e8 5c ff ff ff       	call   f0101997 <page_remove>
f0101a3b:	eb 28                	jmp    f0101a65 <page_insert+0x7e>
		}
	}
	else
	{
		//cprintf("2nhello\n");
		pte = pgdir_walk(pgdir, va, perm); //perm create
f0101a3d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101a41:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a48:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a4b:	89 04 24             	mov    %eax,(%esp)
f0101a4e:	e8 cf fc ff ff       	call   f0101722 <pgdir_walk>
f0101a53:	89 c3                	mov    %eax,%ebx
		//cprintf("2nhelloend\n");
		if(!pte)
f0101a55:	85 c0                	test   %eax,%eax
f0101a57:	75 0c                	jne    f0101a65 <page_insert+0x7e>
		{
			pp->pp_ref--;
f0101a59:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f0101a5e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
			return -E_NO_MEM;
f0101a63:	eb 15                	jmp    f0101a7a <page_insert+0x93>
			
		}
	}
	*pte = PTE_ADDR(page2pa(pp))|perm;
f0101a65:	2b 35 90 ce 1d f0    	sub    0xf01dce90,%esi
f0101a6b:	c1 fe 03             	sar    $0x3,%esi
f0101a6e:	c1 e6 0c             	shl    $0xc,%esi
f0101a71:	09 f7                	or     %esi,%edi
f0101a73:	89 3b                	mov    %edi,(%ebx)
f0101a75:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0101a7a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101a7d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101a80:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101a83:	89 ec                	mov    %ebp,%esp
f0101a85:	5d                   	pop    %ebp
f0101a86:	c3                   	ret    

f0101a87 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101a87:	55                   	push   %ebp
f0101a88:	89 e5                	mov    %esp,%ebp
f0101a8a:	57                   	push   %edi
f0101a8b:	56                   	push   %esi
f0101a8c:	53                   	push   %ebx
f0101a8d:	83 ec 2c             	sub    $0x2c,%esp
f0101a90:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101a93:	89 d7                	mov    %edx,%edi
f0101a95:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	pte_t* pte;
	size_t base = 0;
	//cprintf("right here:%x\t%x\t%x\n",va,size,pa);
	for(base=0;base < size;base=base+PGSIZE)
f0101a98:	85 c9                	test   %ecx,%ecx
f0101a9a:	74 40                	je     f0101adc <boot_map_region+0x55>
f0101a9c:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		pte = pgdir_walk (pgdir, (void*)(va+base), 1);
		//if(pte != NULL)
			*pte = PTE_ADDR(pa + base)|perm|PTE_P;
f0101aa1:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101aa4:	83 ce 01             	or     $0x1,%esi
	pte_t* pte;
	size_t base = 0;
	//cprintf("right here:%x\t%x\t%x\n",va,size,pa);
	for(base=0;base < size;base=base+PGSIZE)
	{
		pte = pgdir_walk (pgdir, (void*)(va+base), 1);
f0101aa7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101aae:	00 
f0101aaf:	8d 04 3b             	lea    (%ebx,%edi,1),%eax
f0101ab2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ab6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101ab9:	89 04 24             	mov    %eax,(%esp)
f0101abc:	e8 61 fc ff ff       	call   f0101722 <pgdir_walk>
		//if(pte != NULL)
			*pte = PTE_ADDR(pa + base)|perm|PTE_P;
f0101ac1:	8b 55 08             	mov    0x8(%ebp),%edx
f0101ac4:	8d 14 13             	lea    (%ebx,%edx,1),%edx
f0101ac7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101acd:	09 f2                	or     %esi,%edx
f0101acf:	89 10                	mov    %edx,(%eax)
{
	// Fill this function in
	pte_t* pte;
	size_t base = 0;
	//cprintf("right here:%x\t%x\t%x\n",va,size,pa);
	for(base=0;base < size;base=base+PGSIZE)
f0101ad1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101ad7:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101ada:	77 cb                	ja     f0101aa7 <boot_map_region+0x20>
		
	}
	//cprintf("if out\n");
	
	
}
f0101adc:	83 c4 2c             	add    $0x2c,%esp
f0101adf:	5b                   	pop    %ebx
f0101ae0:	5e                   	pop    %esi
f0101ae1:	5f                   	pop    %edi
f0101ae2:	5d                   	pop    %ebp
f0101ae3:	c3                   	ret    

f0101ae4 <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f0101ae4:	55                   	push   %ebp
f0101ae5:	89 e5                	mov    %esp,%ebp
f0101ae7:	57                   	push   %edi
f0101ae8:	56                   	push   %esi
f0101ae9:	53                   	push   %ebx
f0101aea:	83 ec 3c             	sub    $0x3c,%esp
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101af4:	e8 a5 fb ff ff       	call   f010169e <page_alloc>
f0101af9:	89 c6                	mov    %eax,%esi
f0101afb:	85 c0                	test   %eax,%eax
f0101afd:	75 24                	jne    f0101b23 <check_page+0x3f>
f0101aff:	c7 44 24 0c 74 84 10 	movl   $0xf0108474,0xc(%esp)
f0101b06:	f0 
f0101b07:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101b0e:	f0 
f0101b0f:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0101b16:	00 
f0101b17:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101b1e:	e8 62 e5 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b23:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b2a:	e8 6f fb ff ff       	call   f010169e <page_alloc>
f0101b2f:	89 c7                	mov    %eax,%edi
f0101b31:	85 c0                	test   %eax,%eax
f0101b33:	75 24                	jne    f0101b59 <check_page+0x75>
f0101b35:	c7 44 24 0c 8a 84 10 	movl   $0xf010848a,0xc(%esp)
f0101b3c:	f0 
f0101b3d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101b44:	f0 
f0101b45:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f0101b4c:	00 
f0101b4d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101b54:	e8 2c e5 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b60:	e8 39 fb ff ff       	call   f010169e <page_alloc>
f0101b65:	89 c3                	mov    %eax,%ebx
f0101b67:	85 c0                	test   %eax,%eax
f0101b69:	75 24                	jne    f0101b8f <check_page+0xab>
f0101b6b:	c7 44 24 0c a0 84 10 	movl   $0xf01084a0,0xc(%esp)
f0101b72:	f0 
f0101b73:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101b7a:	f0 
f0101b7b:	c7 44 24 04 45 04 00 	movl   $0x445,0x4(%esp)
f0101b82:	00 
f0101b83:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101b8a:	e8 f6 e4 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b8f:	39 fe                	cmp    %edi,%esi
f0101b91:	75 24                	jne    f0101bb7 <check_page+0xd3>
f0101b93:	c7 44 24 0c b6 84 10 	movl   $0xf01084b6,0xc(%esp)
f0101b9a:	f0 
f0101b9b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101ba2:	f0 
f0101ba3:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0101baa:	00 
f0101bab:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101bb2:	e8 ce e4 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bb7:	39 c7                	cmp    %eax,%edi
f0101bb9:	74 04                	je     f0101bbf <check_page+0xdb>
f0101bbb:	39 c6                	cmp    %eax,%esi
f0101bbd:	75 24                	jne    f0101be3 <check_page+0xff>
f0101bbf:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0101bc6:	f0 
f0101bc7:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101bce:	f0 
f0101bcf:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0101bd6:	00 
f0101bd7:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101bde:	e8 a2 e4 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101be3:	a1 30 c2 1d f0       	mov    0xf01dc230,%eax
f0101be8:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101beb:	c7 05 30 c2 1d f0 00 	movl   $0x0,0xf01dc230
f0101bf2:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101bf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bfc:	e8 9d fa ff ff       	call   f010169e <page_alloc>
f0101c01:	85 c0                	test   %eax,%eax
f0101c03:	74 24                	je     f0101c29 <check_page+0x145>
f0101c05:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f0101c0c:	f0 
f0101c0d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101c14:	f0 
f0101c15:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0101c1c:	00 
f0101c1d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101c24:	e8 5c e4 ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c29:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c2c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c37:	00 
f0101c38:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101c3d:	89 04 24             	mov    %eax,(%esp)
f0101c40:	e8 e5 fc ff ff       	call   f010192a <page_lookup>
f0101c45:	85 c0                	test   %eax,%eax
f0101c47:	74 24                	je     f0101c6d <check_page+0x189>
f0101c49:	c7 44 24 0c c0 7d 10 	movl   $0xf0107dc0,0xc(%esp)
f0101c50:	f0 
f0101c51:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101c58:	f0 
f0101c59:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0101c60:	00 
f0101c61:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101c68:	e8 18 e4 ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c6d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c74:	00 
f0101c75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c7c:	00 
f0101c7d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c81:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101c86:	89 04 24             	mov    %eax,(%esp)
f0101c89:	e8 59 fd ff ff       	call   f01019e7 <page_insert>
f0101c8e:	85 c0                	test   %eax,%eax
f0101c90:	78 24                	js     f0101cb6 <check_page+0x1d2>
f0101c92:	c7 44 24 0c f8 7d 10 	movl   $0xf0107df8,0xc(%esp)
f0101c99:	f0 
f0101c9a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101ca1:	f0 
f0101ca2:	c7 44 24 04 56 04 00 	movl   $0x456,0x4(%esp)
f0101ca9:	00 
f0101caa:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101cb1:	e8 cf e3 ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101cb6:	89 34 24             	mov    %esi,(%esp)
f0101cb9:	e8 c9 f0 ff ff       	call   f0100d87 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101cbe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cc5:	00 
f0101cc6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ccd:	00 
f0101cce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101cd2:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101cd7:	89 04 24             	mov    %eax,(%esp)
f0101cda:	e8 08 fd ff ff       	call   f01019e7 <page_insert>
f0101cdf:	85 c0                	test   %eax,%eax
f0101ce1:	74 24                	je     f0101d07 <check_page+0x223>
f0101ce3:	c7 44 24 0c 28 7e 10 	movl   $0xf0107e28,0xc(%esp)
f0101cea:	f0 
f0101ceb:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101cf2:	f0 
f0101cf3:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0101cfa:	00 
f0101cfb:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101d02:	e8 7e e3 ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d07:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d0c:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101d0f:	8b 08                	mov    (%eax),%ecx
f0101d11:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101d17:	89 f2                	mov    %esi,%edx
f0101d19:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0101d1f:	c1 fa 03             	sar    $0x3,%edx
f0101d22:	c1 e2 0c             	shl    $0xc,%edx
f0101d25:	39 d1                	cmp    %edx,%ecx
f0101d27:	74 24                	je     f0101d4d <check_page+0x269>
f0101d29:	c7 44 24 0c 58 7e 10 	movl   $0xf0107e58,0xc(%esp)
f0101d30:	f0 
f0101d31:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101d38:	f0 
f0101d39:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0101d40:	00 
f0101d41:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101d48:	e8 38 e3 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d4d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d52:	e8 f3 f0 ff ff       	call   f0100e4a <check_va2pa>
f0101d57:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101d5a:	89 fa                	mov    %edi,%edx
f0101d5c:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0101d62:	c1 fa 03             	sar    $0x3,%edx
f0101d65:	c1 e2 0c             	shl    $0xc,%edx
f0101d68:	39 d0                	cmp    %edx,%eax
f0101d6a:	74 24                	je     f0101d90 <check_page+0x2ac>
f0101d6c:	c7 44 24 0c 80 7e 10 	movl   $0xf0107e80,0xc(%esp)
f0101d73:	f0 
f0101d74:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101d7b:	f0 
f0101d7c:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0101d83:	00 
f0101d84:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101d8b:	e8 f5 e2 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0101d90:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d95:	74 24                	je     f0101dbb <check_page+0x2d7>
f0101d97:	c7 44 24 0c d7 84 10 	movl   $0xf01084d7,0xc(%esp)
f0101d9e:	f0 
f0101d9f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101da6:	f0 
f0101da7:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0101dae:	00 
f0101daf:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101db6:	e8 ca e2 ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f0101dbb:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101dc0:	74 24                	je     f0101de6 <check_page+0x302>
f0101dc2:	c7 44 24 0c e8 84 10 	movl   $0xf01084e8,0xc(%esp)
f0101dc9:	f0 
f0101dca:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101dd1:	f0 
f0101dd2:	c7 44 24 04 5e 04 00 	movl   $0x45e,0x4(%esp)
f0101dd9:	00 
f0101dda:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101de1:	e8 9f e2 ff ff       	call   f0100085 <_panic>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101de6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ded:	00 
f0101dee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101df5:	00 
f0101df6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101dfa:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101dff:	89 04 24             	mov    %eax,(%esp)
f0101e02:	e8 e0 fb ff ff       	call   f01019e7 <page_insert>
f0101e07:	85 c0                	test   %eax,%eax
f0101e09:	74 24                	je     f0101e2f <check_page+0x34b>
f0101e0b:	c7 44 24 0c b0 7e 10 	movl   $0xf0107eb0,0xc(%esp)
f0101e12:	f0 
f0101e13:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101e1a:	f0 
f0101e1b:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f0101e22:	00 
f0101e23:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101e2a:	e8 56 e2 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e2f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e34:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101e39:	e8 0c f0 ff ff       	call   f0100e4a <check_va2pa>
f0101e3e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101e41:	89 da                	mov    %ebx,%edx
f0101e43:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0101e49:	c1 fa 03             	sar    $0x3,%edx
f0101e4c:	c1 e2 0c             	shl    $0xc,%edx
f0101e4f:	39 d0                	cmp    %edx,%eax
f0101e51:	74 24                	je     f0101e77 <check_page+0x393>
f0101e53:	c7 44 24 0c ec 7e 10 	movl   $0xf0107eec,0xc(%esp)
f0101e5a:	f0 
f0101e5b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101e62:	f0 
f0101e63:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f0101e6a:	00 
f0101e6b:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101e72:	e8 0e e2 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101e77:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e7c:	74 24                	je     f0101ea2 <check_page+0x3be>
f0101e7e:	c7 44 24 0c f9 84 10 	movl   $0xf01084f9,0xc(%esp)
f0101e85:	f0 
f0101e86:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101e8d:	f0 
f0101e8e:	c7 44 24 04 62 04 00 	movl   $0x462,0x4(%esp)
f0101e95:	00 
f0101e96:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101e9d:	e8 e3 e1 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ea2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ea9:	e8 f0 f7 ff ff       	call   f010169e <page_alloc>
f0101eae:	85 c0                	test   %eax,%eax
f0101eb0:	74 24                	je     f0101ed6 <check_page+0x3f2>
f0101eb2:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f0101eb9:	f0 
f0101eba:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101ec1:	f0 
f0101ec2:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f0101ec9:	00 
f0101eca:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101ed1:	e8 af e1 ff ff       	call   f0100085 <_panic>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ed6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101edd:	00 
f0101ede:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ee5:	00 
f0101ee6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101eea:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101eef:	89 04 24             	mov    %eax,(%esp)
f0101ef2:	e8 f0 fa ff ff       	call   f01019e7 <page_insert>
f0101ef7:	85 c0                	test   %eax,%eax
f0101ef9:	74 24                	je     f0101f1f <check_page+0x43b>
f0101efb:	c7 44 24 0c b0 7e 10 	movl   $0xf0107eb0,0xc(%esp)
f0101f02:	f0 
f0101f03:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101f0a:	f0 
f0101f0b:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0101f12:	00 
f0101f13:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101f1a:	e8 66 e1 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f1f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f24:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101f29:	e8 1c ef ff ff       	call   f0100e4a <check_va2pa>
f0101f2e:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101f31:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0101f37:	c1 fa 03             	sar    $0x3,%edx
f0101f3a:	c1 e2 0c             	shl    $0xc,%edx
f0101f3d:	39 d0                	cmp    %edx,%eax
f0101f3f:	74 24                	je     f0101f65 <check_page+0x481>
f0101f41:	c7 44 24 0c ec 7e 10 	movl   $0xf0107eec,0xc(%esp)
f0101f48:	f0 
f0101f49:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101f50:	f0 
f0101f51:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0101f58:	00 
f0101f59:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101f60:	e8 20 e1 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101f65:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f6a:	74 24                	je     f0101f90 <check_page+0x4ac>
f0101f6c:	c7 44 24 0c f9 84 10 	movl   $0xf01084f9,0xc(%esp)
f0101f73:	f0 
f0101f74:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101f7b:	f0 
f0101f7c:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0101f83:	00 
f0101f84:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101f8b:	e8 f5 e0 ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f97:	e8 02 f7 ff ff       	call   f010169e <page_alloc>
f0101f9c:	85 c0                	test   %eax,%eax
f0101f9e:	74 24                	je     f0101fc4 <check_page+0x4e0>
f0101fa0:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f0101fa7:	f0 
f0101fa8:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0101faf:	f0 
f0101fb0:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f0101fb7:	00 
f0101fb8:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101fbf:	e8 c1 e0 ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fc4:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0101fc9:	8b 00                	mov    (%eax),%eax
f0101fcb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fd0:	89 c2                	mov    %eax,%edx
f0101fd2:	c1 ea 0c             	shr    $0xc,%edx
f0101fd5:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f0101fdb:	72 20                	jb     f0101ffd <check_page+0x519>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101fe1:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0101fe8:	f0 
f0101fe9:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0101ff0:	00 
f0101ff1:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0101ff8:	e8 88 e0 ff ff       	call   f0100085 <_panic>
f0101ffd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102002:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102005:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010200c:	00 
f010200d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102014:	00 
f0102015:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f010201a:	89 04 24             	mov    %eax,(%esp)
f010201d:	e8 00 f7 ff ff       	call   f0101722 <pgdir_walk>
f0102022:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102025:	83 c2 04             	add    $0x4,%edx
f0102028:	39 d0                	cmp    %edx,%eax
f010202a:	74 24                	je     f0102050 <check_page+0x56c>
f010202c:	c7 44 24 0c 1c 7f 10 	movl   $0xf0107f1c,0xc(%esp)
f0102033:	f0 
f0102034:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010203b:	f0 
f010203c:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0102043:	00 
f0102044:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010204b:	e8 35 e0 ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0102050:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102057:	00 
f0102058:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010205f:	00 
f0102060:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102064:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102069:	89 04 24             	mov    %eax,(%esp)
f010206c:	e8 76 f9 ff ff       	call   f01019e7 <page_insert>
f0102071:	85 c0                	test   %eax,%eax
f0102073:	74 24                	je     f0102099 <check_page+0x5b5>
f0102075:	c7 44 24 0c 5c 7f 10 	movl   $0xf0107f5c,0xc(%esp)
f010207c:	f0 
f010207d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102084:	f0 
f0102085:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f010208c:	00 
f010208d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102094:	e8 ec df ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102099:	ba 00 10 00 00       	mov    $0x1000,%edx
f010209e:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01020a3:	e8 a2 ed ff ff       	call   f0100e4a <check_va2pa>
f01020a8:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01020ab:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f01020b1:	c1 fa 03             	sar    $0x3,%edx
f01020b4:	c1 e2 0c             	shl    $0xc,%edx
f01020b7:	39 d0                	cmp    %edx,%eax
f01020b9:	74 24                	je     f01020df <check_page+0x5fb>
f01020bb:	c7 44 24 0c ec 7e 10 	movl   $0xf0107eec,0xc(%esp)
f01020c2:	f0 
f01020c3:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01020ca:	f0 
f01020cb:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f01020d2:	00 
f01020d3:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01020da:	e8 a6 df ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01020df:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020e4:	74 24                	je     f010210a <check_page+0x626>
f01020e6:	c7 44 24 0c f9 84 10 	movl   $0xf01084f9,0xc(%esp)
f01020ed:	f0 
f01020ee:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01020f5:	f0 
f01020f6:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f01020fd:	00 
f01020fe:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102105:	e8 7b df ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010210a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102111:	00 
f0102112:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102119:	00 
f010211a:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f010211f:	89 04 24             	mov    %eax,(%esp)
f0102122:	e8 fb f5 ff ff       	call   f0101722 <pgdir_walk>
f0102127:	f6 00 04             	testb  $0x4,(%eax)
f010212a:	75 24                	jne    f0102150 <check_page+0x66c>
f010212c:	c7 44 24 0c 9c 7f 10 	movl   $0xf0107f9c,0xc(%esp)
f0102133:	f0 
f0102134:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010213b:	f0 
f010213c:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f0102143:	00 
f0102144:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010214b:	e8 35 df ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102150:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102155:	f6 00 04             	testb  $0x4,(%eax)
f0102158:	75 24                	jne    f010217e <check_page+0x69a>
f010215a:	c7 44 24 0c 0a 85 10 	movl   $0xf010850a,0xc(%esp)
f0102161:	f0 
f0102162:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102169:	f0 
f010216a:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0102171:	00 
f0102172:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102179:	e8 07 df ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010217e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102185:	00 
f0102186:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010218d:	00 
f010218e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102192:	89 04 24             	mov    %eax,(%esp)
f0102195:	e8 4d f8 ff ff       	call   f01019e7 <page_insert>
f010219a:	85 c0                	test   %eax,%eax
f010219c:	78 24                	js     f01021c2 <check_page+0x6de>
f010219e:	c7 44 24 0c d0 7f 10 	movl   $0xf0107fd0,0xc(%esp)
f01021a5:	f0 
f01021a6:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01021ad:	f0 
f01021ae:	c7 44 24 04 7b 04 00 	movl   $0x47b,0x4(%esp)
f01021b5:	00 
f01021b6:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01021bd:	e8 c3 de ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021c2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021c9:	00 
f01021ca:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021d1:	00 
f01021d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01021d6:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01021db:	89 04 24             	mov    %eax,(%esp)
f01021de:	e8 04 f8 ff ff       	call   f01019e7 <page_insert>
f01021e3:	85 c0                	test   %eax,%eax
f01021e5:	74 24                	je     f010220b <check_page+0x727>
f01021e7:	c7 44 24 0c 08 80 10 	movl   $0xf0108008,0xc(%esp)
f01021ee:	f0 
f01021ef:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01021f6:	f0 
f01021f7:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f01021fe:	00 
f01021ff:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102206:	e8 7a de ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010220b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102212:	00 
f0102213:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010221a:	00 
f010221b:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102220:	89 04 24             	mov    %eax,(%esp)
f0102223:	e8 fa f4 ff ff       	call   f0101722 <pgdir_walk>
f0102228:	f6 00 04             	testb  $0x4,(%eax)
f010222b:	74 24                	je     f0102251 <check_page+0x76d>
f010222d:	c7 44 24 0c 44 80 10 	movl   $0xf0108044,0xc(%esp)
f0102234:	f0 
f0102235:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010223c:	f0 
f010223d:	c7 44 24 04 7f 04 00 	movl   $0x47f,0x4(%esp)
f0102244:	00 
f0102245:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010224c:	e8 34 de ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102251:	ba 00 00 00 00       	mov    $0x0,%edx
f0102256:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f010225b:	e8 ea eb ff ff       	call   f0100e4a <check_va2pa>
f0102260:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102263:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0102269:	c1 fa 03             	sar    $0x3,%edx
f010226c:	c1 e2 0c             	shl    $0xc,%edx
f010226f:	39 d0                	cmp    %edx,%eax
f0102271:	74 24                	je     f0102297 <check_page+0x7b3>
f0102273:	c7 44 24 0c 7c 80 10 	movl   $0xf010807c,0xc(%esp)
f010227a:	f0 
f010227b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102282:	f0 
f0102283:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f010228a:	00 
f010228b:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102292:	e8 ee dd ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102297:	ba 00 10 00 00       	mov    $0x1000,%edx
f010229c:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01022a1:	e8 a4 eb ff ff       	call   f0100e4a <check_va2pa>
f01022a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01022a9:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f01022af:	c1 fa 03             	sar    $0x3,%edx
f01022b2:	c1 e2 0c             	shl    $0xc,%edx
f01022b5:	39 d0                	cmp    %edx,%eax
f01022b7:	74 24                	je     f01022dd <check_page+0x7f9>
f01022b9:	c7 44 24 0c a8 80 10 	movl   $0xf01080a8,0xc(%esp)
f01022c0:	f0 
f01022c1:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01022c8:	f0 
f01022c9:	c7 44 24 04 83 04 00 	movl   $0x483,0x4(%esp)
f01022d0:	00 
f01022d1:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01022d8:	e8 a8 dd ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01022dd:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01022e2:	74 24                	je     f0102308 <check_page+0x824>
f01022e4:	c7 44 24 0c 20 85 10 	movl   $0xf0108520,0xc(%esp)
f01022eb:	f0 
f01022ec:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01022f3:	f0 
f01022f4:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f01022fb:	00 
f01022fc:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102303:	e8 7d dd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102308:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010230d:	74 24                	je     f0102333 <check_page+0x84f>
f010230f:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f0102316:	f0 
f0102317:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010231e:	f0 
f010231f:	c7 44 24 04 86 04 00 	movl   $0x486,0x4(%esp)
f0102326:	00 
f0102327:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010232e:	e8 52 dd ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102333:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010233a:	e8 5f f3 ff ff       	call   f010169e <page_alloc>
f010233f:	85 c0                	test   %eax,%eax
f0102341:	74 04                	je     f0102347 <check_page+0x863>
f0102343:	39 c3                	cmp    %eax,%ebx
f0102345:	74 24                	je     f010236b <check_page+0x887>
f0102347:	c7 44 24 0c d8 80 10 	movl   $0xf01080d8,0xc(%esp)
f010234e:	f0 
f010234f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102356:	f0 
f0102357:	c7 44 24 04 89 04 00 	movl   $0x489,0x4(%esp)
f010235e:	00 
f010235f:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102366:	e8 1a dd ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010236b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102372:	00 
f0102373:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102378:	89 04 24             	mov    %eax,(%esp)
f010237b:	e8 17 f6 ff ff       	call   f0101997 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102380:	ba 00 00 00 00       	mov    $0x0,%edx
f0102385:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f010238a:	e8 bb ea ff ff       	call   f0100e4a <check_va2pa>
f010238f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102392:	74 24                	je     f01023b8 <check_page+0x8d4>
f0102394:	c7 44 24 0c fc 80 10 	movl   $0xf01080fc,0xc(%esp)
f010239b:	f0 
f010239c:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01023a3:	f0 
f01023a4:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f01023ab:	00 
f01023ac:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01023b3:	e8 cd dc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023b8:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023bd:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01023c2:	e8 83 ea ff ff       	call   f0100e4a <check_va2pa>
f01023c7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023ca:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f01023d0:	c1 fa 03             	sar    $0x3,%edx
f01023d3:	c1 e2 0c             	shl    $0xc,%edx
f01023d6:	39 d0                	cmp    %edx,%eax
f01023d8:	74 24                	je     f01023fe <check_page+0x91a>
f01023da:	c7 44 24 0c a8 80 10 	movl   $0xf01080a8,0xc(%esp)
f01023e1:	f0 
f01023e2:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01023e9:	f0 
f01023ea:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f01023f1:	00 
f01023f2:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01023f9:	e8 87 dc ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f01023fe:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102403:	74 24                	je     f0102429 <check_page+0x945>
f0102405:	c7 44 24 0c d7 84 10 	movl   $0xf01084d7,0xc(%esp)
f010240c:	f0 
f010240d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102414:	f0 
f0102415:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f010241c:	00 
f010241d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102424:	e8 5c dc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102429:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010242e:	74 24                	je     f0102454 <check_page+0x970>
f0102430:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f0102437:	f0 
f0102438:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010243f:	f0 
f0102440:	c7 44 24 04 90 04 00 	movl   $0x490,0x4(%esp)
f0102447:	00 
f0102448:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010244f:	e8 31 dc ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102454:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010245b:	00 
f010245c:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102461:	89 04 24             	mov    %eax,(%esp)
f0102464:	e8 2e f5 ff ff       	call   f0101997 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102469:	ba 00 00 00 00       	mov    $0x0,%edx
f010246e:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102473:	e8 d2 e9 ff ff       	call   f0100e4a <check_va2pa>
f0102478:	83 f8 ff             	cmp    $0xffffffff,%eax
f010247b:	74 24                	je     f01024a1 <check_page+0x9bd>
f010247d:	c7 44 24 0c fc 80 10 	movl   $0xf01080fc,0xc(%esp)
f0102484:	f0 
f0102485:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010248c:	f0 
f010248d:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f0102494:	00 
f0102495:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010249c:	e8 e4 db ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024a1:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024a6:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01024ab:	e8 9a e9 ff ff       	call   f0100e4a <check_va2pa>
f01024b0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024b3:	74 24                	je     f01024d9 <check_page+0x9f5>
f01024b5:	c7 44 24 0c 20 81 10 	movl   $0xf0108120,0xc(%esp)
f01024bc:	f0 
f01024bd:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01024c4:	f0 
f01024c5:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f01024cc:	00 
f01024cd:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01024d4:	e8 ac db ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01024d9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01024de:	74 24                	je     f0102504 <check_page+0xa20>
f01024e0:	c7 44 24 0c 42 85 10 	movl   $0xf0108542,0xc(%esp)
f01024e7:	f0 
f01024e8:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01024ef:	f0 
f01024f0:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f01024f7:	00 
f01024f8:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01024ff:	e8 81 db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102504:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102509:	74 24                	je     f010252f <check_page+0xa4b>
f010250b:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f0102512:	f0 
f0102513:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010251a:	f0 
f010251b:	c7 44 24 04 97 04 00 	movl   $0x497,0x4(%esp)
f0102522:	00 
f0102523:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010252a:	e8 56 db ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010252f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102536:	e8 63 f1 ff ff       	call   f010169e <page_alloc>
f010253b:	85 c0                	test   %eax,%eax
f010253d:	74 04                	je     f0102543 <check_page+0xa5f>
f010253f:	39 c7                	cmp    %eax,%edi
f0102541:	74 24                	je     f0102567 <check_page+0xa83>
f0102543:	c7 44 24 0c 48 81 10 	movl   $0xf0108148,0xc(%esp)
f010254a:	f0 
f010254b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102552:	f0 
f0102553:	c7 44 24 04 9a 04 00 	movl   $0x49a,0x4(%esp)
f010255a:	00 
f010255b:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102562:	e8 1e db ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102567:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010256e:	e8 2b f1 ff ff       	call   f010169e <page_alloc>
f0102573:	85 c0                	test   %eax,%eax
f0102575:	74 24                	je     f010259b <check_page+0xab7>
f0102577:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f010257e:	f0 
f010257f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102586:	f0 
f0102587:	c7 44 24 04 9d 04 00 	movl   $0x49d,0x4(%esp)
f010258e:	00 
f010258f:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102596:	e8 ea da ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010259b:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01025a0:	8b 08                	mov    (%eax),%ecx
f01025a2:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01025ab:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f01025b1:	c1 fa 03             	sar    $0x3,%edx
f01025b4:	c1 e2 0c             	shl    $0xc,%edx
f01025b7:	39 d1                	cmp    %edx,%ecx
f01025b9:	74 24                	je     f01025df <check_page+0xafb>
f01025bb:	c7 44 24 0c 58 7e 10 	movl   $0xf0107e58,0xc(%esp)
f01025c2:	f0 
f01025c3:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01025ca:	f0 
f01025cb:	c7 44 24 04 a0 04 00 	movl   $0x4a0,0x4(%esp)
f01025d2:	00 
f01025d3:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01025da:	e8 a6 da ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f01025df:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01025e5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025ea:	74 24                	je     f0102610 <check_page+0xb2c>
f01025ec:	c7 44 24 0c e8 84 10 	movl   $0xf01084e8,0xc(%esp)
f01025f3:	f0 
f01025f4:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01025fb:	f0 
f01025fc:	c7 44 24 04 a2 04 00 	movl   $0x4a2,0x4(%esp)
f0102603:	00 
f0102604:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010260b:	e8 75 da ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102610:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102616:	89 34 24             	mov    %esi,(%esp)
f0102619:	e8 69 e7 ff ff       	call   f0100d87 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010261e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102625:	00 
f0102626:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010262d:	00 
f010262e:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102633:	89 04 24             	mov    %eax,(%esp)
f0102636:	e8 e7 f0 ff ff       	call   f0101722 <pgdir_walk>
f010263b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010263e:	8b 0d 8c ce 1d f0    	mov    0xf01dce8c,%ecx
f0102644:	83 c1 04             	add    $0x4,%ecx
f0102647:	8b 11                	mov    (%ecx),%edx
f0102649:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010264f:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102652:	c1 ea 0c             	shr    $0xc,%edx
f0102655:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f010265b:	72 23                	jb     f0102680 <check_page+0xb9c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010265d:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102660:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102664:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f010266b:	f0 
f010266c:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f0102673:	00 
f0102674:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010267b:	e8 05 da ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102680:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102683:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102689:	39 d0                	cmp    %edx,%eax
f010268b:	74 24                	je     f01026b1 <check_page+0xbcd>
f010268d:	c7 44 24 0c 53 85 10 	movl   $0xf0108553,0xc(%esp)
f0102694:	f0 
f0102695:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010269c:	f0 
f010269d:	c7 44 24 04 aa 04 00 	movl   $0x4aa,0x4(%esp)
f01026a4:	00 
f01026a5:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01026ac:	e8 d4 d9 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01026b1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f01026b7:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01026bd:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01026c0:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f01026c6:	c1 f8 03             	sar    $0x3,%eax
f01026c9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026cc:	89 c2                	mov    %eax,%edx
f01026ce:	c1 ea 0c             	shr    $0xc,%edx
f01026d1:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f01026d7:	72 20                	jb     f01026f9 <check_page+0xc15>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026dd:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f01026e4:	f0 
f01026e5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01026ec:	00 
f01026ed:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01026f4:	e8 8c d9 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01026f9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102700:	00 
f0102701:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102708:	00 
f0102709:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010270e:	89 04 24             	mov    %eax,(%esp)
f0102711:	e8 a0 41 00 00       	call   f01068b6 <memset>
	page_free(pp0);
f0102716:	89 34 24             	mov    %esi,(%esp)
f0102719:	e8 69 e6 ff ff       	call   f0100d87 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010271e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102725:	00 
f0102726:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010272d:	00 
f010272e:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0102733:	89 04 24             	mov    %eax,(%esp)
f0102736:	e8 e7 ef ff ff       	call   f0101722 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010273b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010273e:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0102744:	c1 fa 03             	sar    $0x3,%edx
f0102747:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010274a:	89 d0                	mov    %edx,%eax
f010274c:	c1 e8 0c             	shr    $0xc,%eax
f010274f:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0102755:	72 20                	jb     f0102777 <check_page+0xc93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102757:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010275b:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0102762:	f0 
f0102763:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010276a:	00 
f010276b:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0102772:	e8 0e d9 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0102777:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010277d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102780:	f6 00 01             	testb  $0x1,(%eax)
f0102783:	75 11                	jne    f0102796 <check_page+0xcb2>
f0102785:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
}


// check page_insert, page_remove, &c
static void
check_page(void)
f010278b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102791:	f6 00 01             	testb  $0x1,(%eax)
f0102794:	74 24                	je     f01027ba <check_page+0xcd6>
f0102796:	c7 44 24 0c 6b 85 10 	movl   $0xf010856b,0xc(%esp)
f010279d:	f0 
f010279e:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01027a5:	f0 
f01027a6:	c7 44 24 04 b4 04 00 	movl   $0x4b4,0x4(%esp)
f01027ad:	00 
f01027ae:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01027b5:	e8 cb d8 ff ff       	call   f0100085 <_panic>
f01027ba:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01027bd:	39 d0                	cmp    %edx,%eax
f01027bf:	75 d0                	jne    f0102791 <check_page+0xcad>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01027c1:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01027c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027cc:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01027d2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01027d5:	a3 30 c2 1d f0       	mov    %eax,0xf01dc230

	// free the pages we took
	page_free(pp0);
f01027da:	89 34 24             	mov    %esi,(%esp)
f01027dd:	e8 a5 e5 ff ff       	call   f0100d87 <page_free>
	page_free(pp1);
f01027e2:	89 3c 24             	mov    %edi,(%esp)
f01027e5:	e8 9d e5 ff ff       	call   f0100d87 <page_free>
	page_free(pp2);
f01027ea:	89 1c 24             	mov    %ebx,(%esp)
f01027ed:	e8 95 e5 ff ff       	call   f0100d87 <page_free>

	cprintf("check_page() succeeded!\n");
f01027f2:	c7 04 24 82 85 10 f0 	movl   $0xf0108582,(%esp)
f01027f9:	e8 fd 1b 00 00       	call   f01043fb <cprintf>
}
f01027fe:	83 c4 3c             	add    $0x3c,%esp
f0102801:	5b                   	pop    %ebx
f0102802:	5e                   	pop    %esi
f0102803:	5f                   	pop    %edi
f0102804:	5d                   	pop    %ebp
f0102805:	c3                   	ret    

f0102806 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0102806:	55                   	push   %ebp
f0102807:	89 e5                	mov    %esp,%ebp
f0102809:	57                   	push   %edi
f010280a:	56                   	push   %esi
f010280b:	53                   	push   %ebx
f010280c:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010280f:	b8 15 00 00 00       	mov    $0x15,%eax
f0102814:	e8 97 e6 ff ff       	call   f0100eb0 <nvram_read>
f0102819:	c1 e0 0a             	shl    $0xa,%eax
f010281c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0102822:	85 c0                	test   %eax,%eax
f0102824:	0f 48 c2             	cmovs  %edx,%eax
f0102827:	c1 f8 0c             	sar    $0xc,%eax
f010282a:	a3 2c c2 1d f0       	mov    %eax,0xf01dc22c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010282f:	b8 17 00 00 00       	mov    $0x17,%eax
f0102834:	e8 77 e6 ff ff       	call   f0100eb0 <nvram_read>
f0102839:	c1 e0 0a             	shl    $0xa,%eax
f010283c:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0102842:	85 c0                	test   %eax,%eax
f0102844:	0f 48 c2             	cmovs  %edx,%eax
f0102847:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f010284a:	85 c0                	test   %eax,%eax
f010284c:	74 0e                	je     f010285c <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010284e:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0102854:	89 15 88 ce 1d f0    	mov    %edx,0xf01dce88
f010285a:	eb 0c                	jmp    f0102868 <mem_init+0x62>
	else
		npages = npages_basemem;
f010285c:	8b 15 2c c2 1d f0    	mov    0xf01dc22c,%edx
f0102862:	89 15 88 ce 1d f0    	mov    %edx,0xf01dce88

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0102868:	c1 e0 0c             	shl    $0xc,%eax
f010286b:	c1 e8 0a             	shr    $0xa,%eax
f010286e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102872:	a1 2c c2 1d f0       	mov    0xf01dc22c,%eax
f0102877:	c1 e0 0c             	shl    $0xc,%eax
f010287a:	c1 e8 0a             	shr    $0xa,%eax
f010287d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102881:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f0102886:	c1 e0 0c             	shl    $0xc,%eax
f0102889:	c1 e8 0a             	shr    $0xa,%eax
f010288c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102890:	c7 04 24 6c 81 10 f0 	movl   $0xf010816c,(%esp)
f0102897:	e8 5f 1b 00 00       	call   f01043fb <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010289c:	b8 00 10 00 00       	mov    $0x1000,%eax
f01028a1:	e8 aa e4 ff ff       	call   f0100d50 <boot_alloc>
f01028a6:	a3 8c ce 1d f0       	mov    %eax,0xf01dce8c
	memset(kern_pgdir, 0, PGSIZE);
f01028ab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028b2:	00 
f01028b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028ba:	00 
f01028bb:	89 04 24             	mov    %eax,(%esp)
f01028be:	e8 f3 3f 00 00       	call   f01068b6 <memset>
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)	
	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01028c3:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028c8:	89 c2                	mov    %eax,%edx
f01028ca:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028cf:	77 20                	ja     f01028f1 <mem_init+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028d5:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f01028dc:	f0 
f01028dd:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01028e4:	00 
f01028e5:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01028ec:	e8 94 d7 ff ff       	call   f0100085 <_panic>
f01028f1:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01028f7:	83 ca 05             	or     $0x5,%edx
f01028fa:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = boot_alloc(npages * sizeof(struct Page));
f0102900:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f0102905:	c1 e0 03             	shl    $0x3,%eax
f0102908:	e8 43 e4 ff ff       	call   f0100d50 <boot_alloc>
f010290d:	a3 90 ce 1d f0       	mov    %eax,0xf01dce90
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs=boot_alloc(NENV*sizeof(struct Env));
f0102912:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0102917:	e8 34 e4 ff ff       	call   f0100d50 <boot_alloc>
f010291c:	a3 40 c2 1d f0       	mov    %eax,0xf01dc240
	cprintf("%d\n",NENV);
f0102921:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102928:	00 
f0102929:	c7 04 24 e0 76 10 f0 	movl   $0xf01076e0,(%esp)
f0102930:	e8 c6 1a 00 00       	call   f01043fb <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0102935:	e8 4d e9 ff ff       	call   f0101287 <page_init>

	check_page_free_list(1);
f010293a:	b8 01 00 00 00       	mov    $0x1,%eax
f010293f:	e8 9e e5 ff ff       	call   f0100ee2 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0102944:	83 3d 90 ce 1d f0 00 	cmpl   $0x0,0xf01dce90
f010294b:	75 1c                	jne    f0102969 <mem_init+0x163>
		panic("'pages' is a null pointer!");
f010294d:	c7 44 24 08 9b 85 10 	movl   $0xf010859b,0x8(%esp)
f0102954:	f0 
f0102955:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010295c:	00 
f010295d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102964:	e8 1c d7 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102969:	a1 30 c2 1d f0       	mov    0xf01dc230,%eax
f010296e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102973:	85 c0                	test   %eax,%eax
f0102975:	74 09                	je     f0102980 <mem_init+0x17a>
		++nfree;
f0102977:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010297a:	8b 00                	mov    (%eax),%eax
f010297c:	85 c0                	test   %eax,%eax
f010297e:	75 f7                	jne    f0102977 <mem_init+0x171>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102980:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102987:	e8 12 ed ff ff       	call   f010169e <page_alloc>
f010298c:	89 c6                	mov    %eax,%esi
f010298e:	85 c0                	test   %eax,%eax
f0102990:	75 24                	jne    f01029b6 <mem_init+0x1b0>
f0102992:	c7 44 24 0c 74 84 10 	movl   $0xf0108474,0xc(%esp)
f0102999:	f0 
f010299a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01029a1:	f0 
f01029a2:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01029a9:	00 
f01029aa:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01029b1:	e8 cf d6 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01029b6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029bd:	e8 dc ec ff ff       	call   f010169e <page_alloc>
f01029c2:	89 c7                	mov    %eax,%edi
f01029c4:	85 c0                	test   %eax,%eax
f01029c6:	75 24                	jne    f01029ec <mem_init+0x1e6>
f01029c8:	c7 44 24 0c 8a 84 10 	movl   $0xf010848a,0xc(%esp)
f01029cf:	f0 
f01029d0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01029d7:	f0 
f01029d8:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f01029df:	00 
f01029e0:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01029e7:	e8 99 d6 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01029ec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029f3:	e8 a6 ec ff ff       	call   f010169e <page_alloc>
f01029f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01029fb:	85 c0                	test   %eax,%eax
f01029fd:	75 24                	jne    f0102a23 <mem_init+0x21d>
f01029ff:	c7 44 24 0c a0 84 10 	movl   $0xf01084a0,0xc(%esp)
f0102a06:	f0 
f0102a07:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102a0e:	f0 
f0102a0f:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102a16:	00 
f0102a17:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102a1e:	e8 62 d6 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102a23:	39 fe                	cmp    %edi,%esi
f0102a25:	75 24                	jne    f0102a4b <mem_init+0x245>
f0102a27:	c7 44 24 0c b6 84 10 	movl   $0xf01084b6,0xc(%esp)
f0102a2e:	f0 
f0102a2f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102a36:	f0 
f0102a37:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102a3e:	00 
f0102a3f:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102a46:	e8 3a d6 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102a4b:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102a4e:	74 05                	je     f0102a55 <mem_init+0x24f>
f0102a50:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102a53:	75 24                	jne    f0102a79 <mem_init+0x273>
f0102a55:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0102a5c:	f0 
f0102a5d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102a64:	f0 
f0102a65:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0102a6c:	00 
f0102a6d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102a74:	e8 0c d6 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a79:	8b 15 90 ce 1d f0    	mov    0xf01dce90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102a7f:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f0102a84:	c1 e0 0c             	shl    $0xc,%eax
f0102a87:	89 f1                	mov    %esi,%ecx
f0102a89:	29 d1                	sub    %edx,%ecx
f0102a8b:	c1 f9 03             	sar    $0x3,%ecx
f0102a8e:	c1 e1 0c             	shl    $0xc,%ecx
f0102a91:	39 c1                	cmp    %eax,%ecx
f0102a93:	72 24                	jb     f0102ab9 <mem_init+0x2b3>
f0102a95:	c7 44 24 0c b6 85 10 	movl   $0xf01085b6,0xc(%esp)
f0102a9c:	f0 
f0102a9d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102aa4:	f0 
f0102aa5:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102aac:	00 
f0102aad:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102ab4:	e8 cc d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102ab9:	89 f9                	mov    %edi,%ecx
f0102abb:	29 d1                	sub    %edx,%ecx
f0102abd:	c1 f9 03             	sar    $0x3,%ecx
f0102ac0:	c1 e1 0c             	shl    $0xc,%ecx
f0102ac3:	39 c8                	cmp    %ecx,%eax
f0102ac5:	77 24                	ja     f0102aeb <mem_init+0x2e5>
f0102ac7:	c7 44 24 0c d3 85 10 	movl   $0xf01085d3,0xc(%esp)
f0102ace:	f0 
f0102acf:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102ad6:	f0 
f0102ad7:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102ade:	00 
f0102adf:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102ae6:	e8 9a d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102aeb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102aee:	29 d1                	sub    %edx,%ecx
f0102af0:	89 ca                	mov    %ecx,%edx
f0102af2:	c1 fa 03             	sar    $0x3,%edx
f0102af5:	c1 e2 0c             	shl    $0xc,%edx
f0102af8:	39 d0                	cmp    %edx,%eax
f0102afa:	77 24                	ja     f0102b20 <mem_init+0x31a>
f0102afc:	c7 44 24 0c f0 85 10 	movl   $0xf01085f0,0xc(%esp)
f0102b03:	f0 
f0102b04:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102b0b:	f0 
f0102b0c:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102b13:	00 
f0102b14:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102b1b:	e8 65 d5 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102b20:	a1 30 c2 1d f0       	mov    0xf01dc230,%eax
f0102b25:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f0102b28:	c7 05 30 c2 1d f0 00 	movl   $0x0,0xf01dc230
f0102b2f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102b32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b39:	e8 60 eb ff ff       	call   f010169e <page_alloc>
f0102b3e:	85 c0                	test   %eax,%eax
f0102b40:	74 24                	je     f0102b66 <mem_init+0x360>
f0102b42:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f0102b49:	f0 
f0102b4a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102b51:	f0 
f0102b52:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102b59:	00 
f0102b5a:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102b61:	e8 1f d5 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102b66:	89 34 24             	mov    %esi,(%esp)
f0102b69:	e8 19 e2 ff ff       	call   f0100d87 <page_free>
	page_free(pp1);
f0102b6e:	89 3c 24             	mov    %edi,(%esp)
f0102b71:	e8 11 e2 ff ff       	call   f0100d87 <page_free>
	page_free(pp2);
f0102b76:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102b79:	89 0c 24             	mov    %ecx,(%esp)
f0102b7c:	e8 06 e2 ff ff       	call   f0100d87 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b88:	e8 11 eb ff ff       	call   f010169e <page_alloc>
f0102b8d:	89 c6                	mov    %eax,%esi
f0102b8f:	85 c0                	test   %eax,%eax
f0102b91:	75 24                	jne    f0102bb7 <mem_init+0x3b1>
f0102b93:	c7 44 24 0c 74 84 10 	movl   $0xf0108474,0xc(%esp)
f0102b9a:	f0 
f0102b9b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102ba2:	f0 
f0102ba3:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102baa:	00 
f0102bab:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102bb2:	e8 ce d4 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102bb7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bbe:	e8 db ea ff ff       	call   f010169e <page_alloc>
f0102bc3:	89 c7                	mov    %eax,%edi
f0102bc5:	85 c0                	test   %eax,%eax
f0102bc7:	75 24                	jne    f0102bed <mem_init+0x3e7>
f0102bc9:	c7 44 24 0c 8a 84 10 	movl   $0xf010848a,0xc(%esp)
f0102bd0:	f0 
f0102bd1:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102bd8:	f0 
f0102bd9:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0102be0:	00 
f0102be1:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102be8:	e8 98 d4 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bf4:	e8 a5 ea ff ff       	call   f010169e <page_alloc>
f0102bf9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102bfc:	85 c0                	test   %eax,%eax
f0102bfe:	75 24                	jne    f0102c24 <mem_init+0x41e>
f0102c00:	c7 44 24 0c a0 84 10 	movl   $0xf01084a0,0xc(%esp)
f0102c07:	f0 
f0102c08:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102c0f:	f0 
f0102c10:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0102c17:	00 
f0102c18:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102c1f:	e8 61 d4 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102c24:	39 fe                	cmp    %edi,%esi
f0102c26:	75 24                	jne    f0102c4c <mem_init+0x446>
f0102c28:	c7 44 24 0c b6 84 10 	movl   $0xf01084b6,0xc(%esp)
f0102c2f:	f0 
f0102c30:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102c37:	f0 
f0102c38:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0102c3f:	00 
f0102c40:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102c47:	e8 39 d4 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102c4c:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102c4f:	74 05                	je     f0102c56 <mem_init+0x450>
f0102c51:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102c54:	75 24                	jne    f0102c7a <mem_init+0x474>
f0102c56:	c7 44 24 0c a0 7d 10 	movl   $0xf0107da0,0xc(%esp)
f0102c5d:	f0 
f0102c5e:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102c65:	f0 
f0102c66:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0102c6d:	00 
f0102c6e:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102c75:	e8 0b d4 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102c7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c81:	e8 18 ea ff ff       	call   f010169e <page_alloc>
f0102c86:	85 c0                	test   %eax,%eax
f0102c88:	74 24                	je     f0102cae <mem_init+0x4a8>
f0102c8a:	c7 44 24 0c c8 84 10 	movl   $0xf01084c8,0xc(%esp)
f0102c91:	f0 
f0102c92:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102c99:	f0 
f0102c9a:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f0102ca1:	00 
f0102ca2:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102ca9:	e8 d7 d3 ff ff       	call   f0100085 <_panic>
f0102cae:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0102cb1:	89 f0                	mov    %esi,%eax
f0102cb3:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f0102cb9:	c1 f8 03             	sar    $0x3,%eax
f0102cbc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cbf:	89 c2                	mov    %eax,%edx
f0102cc1:	c1 ea 0c             	shr    $0xc,%edx
f0102cc4:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f0102cca:	72 20                	jb     f0102cec <mem_init+0x4e6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ccc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cd0:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0102cd7:	f0 
f0102cd8:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102cdf:	00 
f0102ce0:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0102ce7:	e8 99 d3 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102cec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cf3:	00 
f0102cf4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102cfb:	00 
f0102cfc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d01:	89 04 24             	mov    %eax,(%esp)
f0102d04:	e8 ad 3b 00 00       	call   f01068b6 <memset>
	page_free(pp0);
f0102d09:	89 34 24             	mov    %esi,(%esp)
f0102d0c:	e8 76 e0 ff ff       	call   f0100d87 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102d11:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102d18:	e8 81 e9 ff ff       	call   f010169e <page_alloc>
f0102d1d:	85 c0                	test   %eax,%eax
f0102d1f:	75 24                	jne    f0102d45 <mem_init+0x53f>
f0102d21:	c7 44 24 0c 0d 86 10 	movl   $0xf010860d,0xc(%esp)
f0102d28:	f0 
f0102d29:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102d30:	f0 
f0102d31:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102d38:	00 
f0102d39:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102d40:	e8 40 d3 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102d45:	39 c6                	cmp    %eax,%esi
f0102d47:	74 24                	je     f0102d6d <mem_init+0x567>
f0102d49:	c7 44 24 0c 2b 86 10 	movl   $0xf010862b,0xc(%esp)
f0102d50:	f0 
f0102d51:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102d58:	f0 
f0102d59:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0102d60:	00 
f0102d61:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102d68:	e8 18 d3 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d6d:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d70:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0102d76:	c1 fa 03             	sar    $0x3,%edx
f0102d79:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d7c:	89 d0                	mov    %edx,%eax
f0102d7e:	c1 e8 0c             	shr    $0xc,%eax
f0102d81:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0102d87:	72 20                	jb     f0102da9 <mem_init+0x5a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d89:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d8d:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0102d94:	f0 
f0102d95:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102d9c:	00 
f0102d9d:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0102da4:	e8 dc d2 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102da9:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102db0:	75 11                	jne    f0102dc3 <mem_init+0x5bd>
f0102db2:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102db8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102dbe:	80 38 00             	cmpb   $0x0,(%eax)
f0102dc1:	74 24                	je     f0102de7 <mem_init+0x5e1>
f0102dc3:	c7 44 24 0c 3b 86 10 	movl   $0xf010863b,0xc(%esp)
f0102dca:	f0 
f0102dcb:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102dd2:	f0 
f0102dd3:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102dda:	00 
f0102ddb:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102de2:	e8 9e d2 ff ff       	call   f0100085 <_panic>
f0102de7:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102dea:	39 d0                	cmp    %edx,%eax
f0102dec:	75 d0                	jne    f0102dbe <mem_init+0x5b8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102dee:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102df1:	a3 30 c2 1d f0       	mov    %eax,0xf01dc230

	// free the pages we took
	page_free(pp0);
f0102df6:	89 34 24             	mov    %esi,(%esp)
f0102df9:	e8 89 df ff ff       	call   f0100d87 <page_free>
	page_free(pp1);
f0102dfe:	89 3c 24             	mov    %edi,(%esp)
f0102e01:	e8 81 df ff ff       	call   f0100d87 <page_free>
	page_free(pp2);
f0102e06:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e09:	89 0c 24             	mov    %ecx,(%esp)
f0102e0c:	e8 76 df ff ff       	call   f0100d87 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102e11:	a1 30 c2 1d f0       	mov    0xf01dc230,%eax
f0102e16:	85 c0                	test   %eax,%eax
f0102e18:	74 09                	je     f0102e23 <mem_init+0x61d>
		--nfree;
f0102e1a:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102e1d:	8b 00                	mov    (%eax),%eax
f0102e1f:	85 c0                	test   %eax,%eax
f0102e21:	75 f7                	jne    f0102e1a <mem_init+0x614>
		--nfree;
	assert(nfree == 0);
f0102e23:	85 db                	test   %ebx,%ebx
f0102e25:	74 24                	je     f0102e4b <mem_init+0x645>
f0102e27:	c7 44 24 0c 45 86 10 	movl   $0xf0108645,0xc(%esp)
f0102e2e:	f0 
f0102e2f:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102e36:	f0 
f0102e37:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0102e3e:	00 
f0102e3f:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102e46:	e8 3a d2 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102e4b:	c7 04 24 a8 81 10 f0 	movl   $0xf01081a8,(%esp)
f0102e52:	e8 a4 15 00 00       	call   f01043fb <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	check_page();
f0102e57:	e8 88 ec ff ff       	call   f0101ae4 <check_page>
	char* addr;
	int i;
	pp = pp0 = 0;
	
	// Allocate two single pages
	pp =  page_alloc(0);
f0102e5c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e63:	e8 36 e8 ff ff       	call   f010169e <page_alloc>
f0102e68:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f0102e6a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e71:	e8 28 e8 ff ff       	call   f010169e <page_alloc>
f0102e76:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f0102e78:	85 db                	test   %ebx,%ebx
f0102e7a:	75 24                	jne    f0102ea0 <mem_init+0x69a>
f0102e7c:	c7 44 24 0c 50 86 10 	movl   $0xf0108650,0xc(%esp)
f0102e83:	f0 
f0102e84:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102e8b:	f0 
f0102e8c:	c7 44 24 04 de 04 00 	movl   $0x4de,0x4(%esp)
f0102e93:	00 
f0102e94:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102e9b:	e8 e5 d1 ff ff       	call   f0100085 <_panic>
	assert(pp0 != 0);
f0102ea0:	85 c0                	test   %eax,%eax
f0102ea2:	75 24                	jne    f0102ec8 <mem_init+0x6c2>
f0102ea4:	c7 44 24 0c 58 86 10 	movl   $0xf0108658,0xc(%esp)
f0102eab:	f0 
f0102eac:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102eb3:	f0 
f0102eb4:	c7 44 24 04 df 04 00 	movl   $0x4df,0x4(%esp)
f0102ebb:	00 
f0102ebc:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102ec3:	e8 bd d1 ff ff       	call   f0100085 <_panic>
	assert(pp != pp0);
f0102ec8:	39 c3                	cmp    %eax,%ebx
f0102eca:	75 24                	jne    f0102ef0 <mem_init+0x6ea>
f0102ecc:	c7 44 24 0c 61 86 10 	movl   $0xf0108661,0xc(%esp)
f0102ed3:	f0 
f0102ed4:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102edb:	f0 
f0102edc:	c7 44 24 04 e0 04 00 	movl   $0x4e0,0x4(%esp)
f0102ee3:	00 
f0102ee4:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102eeb:	e8 95 d1 ff ff       	call   f0100085 <_panic>

	// Free pp and assign four continuous pages
	page_free(pp);
f0102ef0:	89 1c 24             	mov    %ebx,(%esp)
f0102ef3:	e8 8f de ff ff       	call   f0100d87 <page_free>
	pp = page_alloc_4pages(0);
f0102ef8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102eff:	e8 87 e4 ff ff       	call   f010138b <page_alloc_4pages>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < 3; tmp = tmp->pp_link, i++ )
	{
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0102f04:	8b 18                	mov    (%eax),%ebx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f06:	8b 15 90 ce 1d f0    	mov    0xf01dce90,%edx
f0102f0c:	89 d9                	mov    %ebx,%ecx
f0102f0e:	29 d1                	sub    %edx,%ecx
f0102f10:	c1 f9 03             	sar    $0x3,%ecx
f0102f13:	c1 e1 0c             	shl    $0xc,%ecx
f0102f16:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102f19:	89 c7                	mov    %eax,%edi
f0102f1b:	29 d7                	sub    %edx,%edi
f0102f1d:	c1 ff 03             	sar    $0x3,%edi
f0102f20:	89 f9                	mov    %edi,%ecx
f0102f22:	c1 e1 0c             	shl    $0xc,%ecx
f0102f25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f28:	29 cf                	sub    %ecx,%edi
f0102f2a:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
f0102f30:	75 40                	jne    f0102f72 <mem_init+0x76c>
f0102f32:	8b 3b                	mov    (%ebx),%edi
f0102f34:	89 fb                	mov    %edi,%ebx
f0102f36:	29 d3                	sub    %edx,%ebx
f0102f38:	c1 fb 03             	sar    $0x3,%ebx
f0102f3b:	c1 e3 0c             	shl    $0xc,%ebx
f0102f3e:	89 d9                	mov    %ebx,%ecx
f0102f40:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
f0102f43:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0102f49:	75 27                	jne    f0102f72 <mem_init+0x76c>
f0102f4b:	8b 0f                	mov    (%edi),%ecx
f0102f4d:	29 d1                	sub    %edx,%ecx
f0102f4f:	89 ca                	mov    %ecx,%edx
f0102f51:	c1 fa 03             	sar    $0x3,%edx
f0102f54:	c1 e2 0c             	shl    $0xc,%edx
f0102f57:	29 da                	sub    %ebx,%edx
f0102f59:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0102f5f:	75 11                	jne    f0102f72 <mem_init+0x76c>
	page_free(pp);
	pp = page_alloc_4pages(0);
	assert(check_continuous(pp));

	// Free four continuous pages
	assert(!page_free_4pages(pp));
f0102f61:	89 04 24             	mov    %eax,(%esp)
f0102f64:	e8 3a de ff ff       	call   f0100da3 <page_free_4pages>
f0102f69:	85 c0                	test   %eax,%eax
f0102f6b:	74 4d                	je     f0102fba <mem_init+0x7b4>
f0102f6d:	8d 76 00             	lea    0x0(%esi),%esi
f0102f70:	eb 24                	jmp    f0102f96 <mem_init+0x790>
	assert(pp != pp0);

	// Free pp and assign four continuous pages
	page_free(pp);
	pp = page_alloc_4pages(0);
	assert(check_continuous(pp));
f0102f72:	c7 44 24 0c 6b 86 10 	movl   $0xf010866b,0xc(%esp)
f0102f79:	f0 
f0102f7a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102f81:	f0 
f0102f82:	c7 44 24 04 e5 04 00 	movl   $0x4e5,0x4(%esp)
f0102f89:	00 
f0102f8a:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102f91:	e8 ef d0 ff ff       	call   f0100085 <_panic>

	// Free four continuous pages
	assert(!page_free_4pages(pp));
f0102f96:	c7 44 24 0c 80 86 10 	movl   $0xf0108680,0xc(%esp)
f0102f9d:	f0 
f0102f9e:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0102fa5:	f0 
f0102fa6:	c7 44 24 04 e8 04 00 	movl   $0x4e8,0x4(%esp)
f0102fad:	00 
f0102fae:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0102fb5:	e8 cb d0 ff ff       	call   f0100085 <_panic>
	//cprintf("herefinish?\n");
	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f0102fba:	89 34 24             	mov    %esi,(%esp)
f0102fbd:	e8 c5 dd ff ff       	call   f0100d87 <page_free>
	//cprintf("free what?:%d\n",PGNUM(page2pa(pp0)));
	pp0 = page_alloc_4pages(ALLOC_ZERO);
f0102fc2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102fc9:	e8 bd e3 ff ff       	call   f010138b <page_alloc_4pages>
f0102fce:	89 c1                	mov    %eax,%ecx
f0102fd0:	2b 0d 90 ce 1d f0    	sub    0xf01dce90,%ecx
f0102fd6:	c1 f9 03             	sar    $0x3,%ecx
f0102fd9:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fdc:	89 ca                	mov    %ecx,%edx
f0102fde:	c1 ea 0c             	shr    $0xc,%edx
f0102fe1:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f0102fe7:	72 20                	jb     f0103009 <mem_init+0x803>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102fe9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102fed:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0102ff4:	f0 
f0102ff5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102ffc:	00 
f0102ffd:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0103004:	e8 7c d0 ff ff       	call   f0100085 <_panic>
	addr = (char*)page2kva(pp0);
	//cprintf("herefinishover?\n");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0103009:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f0103010:	75 11                	jne    f0103023 <mem_init+0x81d>
f0103012:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103018:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
	pp0 = page_alloc_4pages(ALLOC_ZERO);
	addr = (char*)page2kva(pp0);
	//cprintf("herefinishover?\n");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f010301e:	80 3a 00             	cmpb   $0x0,(%edx)
f0103021:	74 24                	je     f0103047 <mem_init+0x841>
f0103023:	c7 44 24 0c 96 86 10 	movl   $0xf0108696,0xc(%esp)
f010302a:	f0 
f010302b:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103032:	f0 
f0103033:	c7 44 24 04 f2 04 00 	movl   $0x4f2,0x4(%esp)
f010303a:	00 
f010303b:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103042:	e8 3e d0 ff ff       	call   f0100085 <_panic>
f0103047:	83 c2 01             	add    $0x1,%edx
	//cprintf("free what?:%d\n",PGNUM(page2pa(pp0)));
	pp0 = page_alloc_4pages(ALLOC_ZERO);
	addr = (char*)page2kva(pp0);
	//cprintf("herefinishover?\n");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f010304a:	39 ca                	cmp    %ecx,%edx
f010304c:	75 d0                	jne    f010301e <mem_init+0x818>
		assert(addr[i] == 0);
	}

	// Free pages
	assert(!page_free_4pages(pp0));
f010304e:	89 04 24             	mov    %eax,(%esp)
f0103051:	e8 4d dd ff ff       	call   f0100da3 <page_free_4pages>
f0103056:	85 c0                	test   %eax,%eax
f0103058:	74 24                	je     f010307e <mem_init+0x878>
f010305a:	c7 44 24 0c a3 86 10 	movl   $0xf01086a3,0xc(%esp)
f0103061:	f0 
f0103062:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103069:	f0 
f010306a:	c7 44 24 04 f6 04 00 	movl   $0x4f6,0x4(%esp)
f0103071:	00 
f0103072:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103079:	e8 07 d0 ff ff       	call   f0100085 <_panic>
	cprintf("check_four_pages() succeeded!\n");
f010307e:	c7 04 24 c8 81 10 f0 	movl   $0xf01081c8,(%esp)
f0103085:	e8 71 13 00 00       	call   f01043fb <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	cprintf("map pages\n");
f010308a:	c7 04 24 ba 86 10 f0 	movl   $0xf01086ba,(%esp)
f0103091:	e8 65 13 00 00       	call   f01043fb <cprintf>
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof (struct Page), PGSIZE), PADDR(pages), PTE_P | PTE_U);
f0103096:	a1 90 ce 1d f0       	mov    0xf01dce90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010309b:	89 c2                	mov    %eax,%edx
f010309d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030a2:	77 20                	ja     f01030c4 <mem_init+0x8be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030a8:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f01030af:	f0 
f01030b0:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f01030b7:	00 
f01030b8:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01030bf:	e8 c1 cf ff ff       	call   f0100085 <_panic>
f01030c4:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f01030c9:	8d 0c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%ecx
f01030d0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01030d6:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01030dd:	00 
f01030de:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01030e4:	89 04 24             	mov    %eax,(%esp)
f01030e7:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01030ec:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01030f1:	e8 91 e9 ff ff       	call   f0101a87 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,/* ROUNDUP(sizeof(struct Env) * NENV, PGSIZE) */PTSIZE,PADDR(envs),PTE_U | PTE_P);
f01030f6:	a1 40 c2 1d f0       	mov    0xf01dc240,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103100:	77 20                	ja     f0103122 <mem_init+0x91c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103102:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103106:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f010310d:	f0 
f010310e:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
f0103115:	00 
f0103116:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010311d:	e8 63 cf ff ff       	call   f0100085 <_panic>
f0103122:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0103129:	00 
f010312a:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103130:	89 04 24             	mov    %eax,(%esp)
f0103133:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0103138:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010313d:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0103142:	e8 40 e9 ff ff       	call   f0101a87 <boot_map_region>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	cprintf("map bootstack\n");
f0103147:	c7 04 24 c5 86 10 f0 	movl   $0xf01086c5,(%esp)
f010314e:	e8 a8 12 00 00       	call   f01043fb <cprintf>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	cprintf("map KERNBASE\n");
f0103153:	c7 04 24 d4 86 10 f0 	movl   $0xf01086d4,(%esp)
f010315a:	e8 9c 12 00 00       	call   f01043fb <cprintf>
	boot_map_region(kern_pgdir, KERNBASE, /* ROUNDUP(0xffffffff - KERNBASE, PGSIZE) *//* 0xffffffff - KERNBASE + 1 */~KERNBASE + 1, 0, PTE_W | PTE_P);
f010315f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0103166:	00 
f0103167:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010316e:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0103173:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0103178:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f010317d:	e8 05 e9 ff ff       	call   f0101a87 <boot_map_region>

	// Initialize the SMP-related parts of the memory map
	cprintf("SMP-related memory map\n");
f0103182:	c7 04 24 e2 86 10 f0 	movl   $0xf01086e2,(%esp)
f0103189:	e8 6d 12 00 00       	call   f01043fb <cprintf>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f010318e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103195:	00 
f0103196:	c7 04 24 00 00 00 fe 	movl   $0xfe000000,(%esp)
f010319d:	b9 00 00 00 02       	mov    $0x2000000,%ecx
f01031a2:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
f01031a7:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f01031ac:	e8 d6 e8 ff ff       	call   f0101a87 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031b1:	c7 45 dc 00 e0 1d f0 	movl   $0xf01de000,-0x24(%ebp)
f01031b8:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f01031bf:	0f 87 1a 08 00 00    	ja     f01039df <mem_init+0x11d9>
f01031c5:	b8 00 e0 1d f0       	mov    $0xf01de000,%eax
f01031ca:	eb 0a                	jmp    f01031d6 <mem_init+0x9d0>
f01031cc:	89 d8                	mov    %ebx,%eax
f01031ce:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01031d4:	77 20                	ja     f01031f6 <mem_init+0x9f0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031da:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f01031e1:	f0 
f01031e2:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
f01031e9:	00 
f01031ea:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01031f1:	e8 8f ce ff ff       	call   f0100085 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir,
f01031f6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01031fd:	00 
f01031fe:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0103204:	89 04 24             	mov    %eax,(%esp)
f0103207:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010320c:	89 f2                	mov    %esi,%edx
f010320e:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0103213:	e8 6f e8 ff ff       	call   f0101a87 <boot_map_region>
f0103218:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010321e:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
f0103224:	81 fe 00 80 b7 ef    	cmp    $0xefb78000,%esi
f010322a:	75 a0                	jne    f01031cc <mem_init+0x9c6>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010322c:	8b 35 8c ce 1d f0    	mov    0xf01dce8c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0103232:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f0103237:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010323e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103244:	74 79                	je     f01032bf <mem_init+0xab9>
f0103246:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010324b:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0103251:	89 f0                	mov    %esi,%eax
f0103253:	e8 f2 db ff ff       	call   f0100e4a <check_va2pa>
f0103258:	8b 15 90 ce 1d f0    	mov    0xf01dce90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010325e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103264:	77 20                	ja     f0103286 <mem_init+0xa80>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103266:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010326a:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0103271:	f0 
f0103272:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0103279:	00 
f010327a:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103281:	e8 ff cd ff ff       	call   f0100085 <_panic>
f0103286:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f010328d:	39 d0                	cmp    %edx,%eax
f010328f:	74 24                	je     f01032b5 <mem_init+0xaaf>
f0103291:	c7 44 24 0c e8 81 10 	movl   $0xf01081e8,0xc(%esp)
f0103298:	f0 
f0103299:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01032a0:	f0 
f01032a1:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f01032a8:	00 
f01032a9:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01032b0:	e8 d0 cd ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01032b5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032bb:	39 df                	cmp    %ebx,%edi
f01032bd:	77 8c                	ja     f010324b <mem_init+0xa45>
f01032bf:	bb 00 00 00 00       	mov    $0x0,%ebx


	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01032c4:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f01032ca:	89 f0                	mov    %esi,%eax
f01032cc:	e8 79 db ff ff       	call   f0100e4a <check_va2pa>
f01032d1:	8b 15 40 c2 1d f0    	mov    0xf01dc240,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01032d7:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01032dd:	77 20                	ja     f01032ff <mem_init+0xaf9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032df:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032e3:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f01032ea:	f0 
f01032eb:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01032f2:	00 
f01032f3:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01032fa:	e8 86 cd ff ff       	call   f0100085 <_panic>
f01032ff:	8d 94 13 00 00 00 10 	lea    0x10000000(%ebx,%edx,1),%edx
f0103306:	39 d0                	cmp    %edx,%eax
f0103308:	74 24                	je     f010332e <mem_init+0xb28>
f010330a:	c7 44 24 0c 1c 82 10 	movl   $0xf010821c,0xc(%esp)
f0103311:	f0 
f0103312:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103319:	f0 
f010331a:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0103321:	00 
f0103322:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103329:	e8 57 cd ff ff       	call   f0100085 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010332e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103334:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f010333a:	75 88                	jne    f01032c4 <mem_init+0xabe>


	//cprintf("check_kern here finish?\n");

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010333c:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f0103341:	c1 e0 0c             	shl    $0xc,%eax
f0103344:	85 c0                	test   %eax,%eax
f0103346:	74 4c                	je     f0103394 <mem_init+0xb8e>
f0103348:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010334d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0103353:	89 f0                	mov    %esi,%eax
f0103355:	e8 f0 da ff ff       	call   f0100e4a <check_va2pa>
f010335a:	39 c3                	cmp    %eax,%ebx
f010335c:	74 24                	je     f0103382 <mem_init+0xb7c>
f010335e:	c7 44 24 0c 50 82 10 	movl   $0xf0108250,0xc(%esp)
f0103365:	f0 
f0103366:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010336d:	f0 
f010336e:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f0103375:	00 
f0103376:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010337d:	e8 03 cd ff ff       	call   f0100085 <_panic>


	//cprintf("check_kern here finish?\n");

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103382:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103388:	a1 88 ce 1d f0       	mov    0xf01dce88,%eax
f010338d:	c1 e0 0c             	shl    $0xc,%eax
f0103390:	39 c3                	cmp    %eax,%ebx
f0103392:	72 b9                	jb     f010334d <mem_init+0xb47>
f0103394:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0103399:	89 da                	mov    %ebx,%edx
f010339b:	89 f0                	mov    %esi,%eax
f010339d:	e8 a8 da ff ff       	call   f0100e4a <check_va2pa>
f01033a2:	39 c3                	cmp    %eax,%ebx
f01033a4:	74 24                	je     f01033ca <mem_init+0xbc4>
f01033a6:	c7 44 24 0c fa 86 10 	movl   $0xf01086fa,0xc(%esp)
f01033ad:	f0 
f01033ae:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01033b5:	f0 
f01033b6:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f01033bd:	00 
f01033be:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01033c5:	e8 bb cc ff ff       	call   f0100085 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f01033ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033d0:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f01033d6:	75 c1                	jne    f0103399 <mem_init+0xb93>
f01033d8:	c7 45 e0 00 00 bf ef 	movl   $0xefbf0000,-0x20(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01033df:	89 f7                	mov    %esi,%edi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f01033e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01033e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01033e7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01033ea:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01033f0:	89 c6                	mov    %eax,%esi
f01033f2:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f01033f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01033fb:	81 c1 00 00 01 00    	add    $0x10000,%ecx
f0103401:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103404:	89 da                	mov    %ebx,%edx
f0103406:	89 f8                	mov    %edi,%eax
f0103408:	e8 3d da ff ff       	call   f0100e4a <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010340d:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f0103414:	77 23                	ja     f0103439 <mem_init+0xc33>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103416:	8b 7d d8             	mov    -0x28(%ebp),%edi
f0103419:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010341d:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0103424:	f0 
f0103425:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f010342c:	00 
f010342d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103434:	e8 4c cc ff ff       	call   f0100085 <_panic>
f0103439:	39 f0                	cmp    %esi,%eax
f010343b:	74 24                	je     f0103461 <mem_init+0xc5b>
f010343d:	c7 44 24 0c 78 82 10 	movl   $0xf0108278,0xc(%esp)
f0103444:	f0 
f0103445:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010344c:	f0 
f010344d:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f0103454:	00 
f0103455:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010345c:	e8 24 cc ff ff       	call   f0100085 <_panic>
f0103461:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103467:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010346d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0103470:	0f 85 9f 05 00 00    	jne    f0103a15 <mem_init+0x120f>
f0103476:	bb 00 00 00 00       	mov    $0x0,%ebx
f010347b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010347e:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f0103481:	89 f8                	mov    %edi,%eax
f0103483:	e8 c2 d9 ff ff       	call   f0100e4a <check_va2pa>
f0103488:	83 f8 ff             	cmp    $0xffffffff,%eax
f010348b:	74 24                	je     f01034b1 <mem_init+0xcab>
f010348d:	c7 44 24 0c c0 82 10 	movl   $0xf01082c0,0xc(%esp)
f0103494:	f0 
f0103495:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010349c:	f0 
f010349d:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f01034a4:	00 
f01034a5:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01034ac:	e8 d4 cb ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01034b1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034b7:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f01034bd:	75 bf                	jne    f010347e <mem_init+0xc78>
f01034bf:	81 6d e0 00 00 01 00 	subl   $0x10000,-0x20(%ebp)
f01034c6:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01034cd:	81 7d e0 00 00 b7 ef 	cmpl   $0xefb70000,-0x20(%ebp)
f01034d4:	0f 85 07 ff ff ff    	jne    f01033e1 <mem_init+0xbdb>
f01034da:	89 fe                	mov    %edi,%esi
f01034dc:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01034e1:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01034e7:	83 fa 03             	cmp    $0x3,%edx
f01034ea:	77 2e                	ja     f010351a <mem_init+0xd14>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01034ec:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f01034f0:	0f 85 aa 00 00 00    	jne    f01035a0 <mem_init+0xd9a>
f01034f6:	c7 44 24 0c 15 87 10 	movl   $0xf0108715,0xc(%esp)
f01034fd:	f0 
f01034fe:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103505:	f0 
f0103506:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f010350d:	00 
f010350e:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103515:	e8 6b cb ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010351a:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010351f:	76 55                	jbe    f0103576 <mem_init+0xd70>
				assert(pgdir[i] & PTE_P);
f0103521:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0103524:	f6 c2 01             	test   $0x1,%dl
f0103527:	75 24                	jne    f010354d <mem_init+0xd47>
f0103529:	c7 44 24 0c 15 87 10 	movl   $0xf0108715,0xc(%esp)
f0103530:	f0 
f0103531:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103538:	f0 
f0103539:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0103540:	00 
f0103541:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103548:	e8 38 cb ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f010354d:	f6 c2 02             	test   $0x2,%dl
f0103550:	75 4e                	jne    f01035a0 <mem_init+0xd9a>
f0103552:	c7 44 24 0c 26 87 10 	movl   $0xf0108726,0xc(%esp)
f0103559:	f0 
f010355a:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103561:	f0 
f0103562:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f0103569:	00 
f010356a:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103571:	e8 0f cb ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103576:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f010357a:	74 24                	je     f01035a0 <mem_init+0xd9a>
f010357c:	c7 44 24 0c 37 87 10 	movl   $0xf0108737,0xc(%esp)
f0103583:	f0 
f0103584:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010358b:	f0 
f010358c:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0103593:	00 
f0103594:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010359b:	e8 e5 ca ff ff       	call   f0100085 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01035a0:	83 c0 01             	add    $0x1,%eax
f01035a3:	3d 00 04 00 00       	cmp    $0x400,%eax
f01035a8:	0f 85 33 ff ff ff    	jne    f01034e1 <mem_init+0xcdb>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01035ae:	c7 04 24 e4 82 10 f0 	movl   $0xf01082e4,(%esp)
f01035b5:	e8 41 0e 00 00       	call   f01043fb <cprintf>
	cprintf("SMP-related memory map\n");
	mem_init_mp();

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	cprintf("finish all check\n");
f01035ba:	c7 04 24 45 87 10 f0 	movl   $0xf0108745,(%esp)
f01035c1:	e8 35 0e 00 00       	call   f01043fb <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01035c6:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01035cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01035d0:	77 20                	ja     f01035f2 <mem_init+0xdec>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035d6:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f01035dd:	f0 
f01035de:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
f01035e5:	00 
f01035e6:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01035ed:	e8 93 ca ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01035f2:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01035f8:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01035fb:	b8 00 00 00 00       	mov    $0x0,%eax
f0103600:	e8 dd d8 ff ff       	call   f0100ee2 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103605:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103608:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010360d:	83 e0 f3             	and    $0xfffffff3,%eax
f0103610:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103613:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010361a:	e8 7f e0 ff ff       	call   f010169e <page_alloc>
f010361f:	89 c3                	mov    %eax,%ebx
f0103621:	85 c0                	test   %eax,%eax
f0103623:	75 24                	jne    f0103649 <mem_init+0xe43>
f0103625:	c7 44 24 0c 74 84 10 	movl   $0xf0108474,0xc(%esp)
f010362c:	f0 
f010362d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103634:	f0 
f0103635:	c7 44 24 04 06 05 00 	movl   $0x506,0x4(%esp)
f010363c:	00 
f010363d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103644:	e8 3c ca ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0103649:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103650:	e8 49 e0 ff ff       	call   f010169e <page_alloc>
f0103655:	89 c7                	mov    %eax,%edi
f0103657:	85 c0                	test   %eax,%eax
f0103659:	75 24                	jne    f010367f <mem_init+0xe79>
f010365b:	c7 44 24 0c 8a 84 10 	movl   $0xf010848a,0xc(%esp)
f0103662:	f0 
f0103663:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010366a:	f0 
f010366b:	c7 44 24 04 07 05 00 	movl   $0x507,0x4(%esp)
f0103672:	00 
f0103673:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010367a:	e8 06 ca ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010367f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103686:	e8 13 e0 ff ff       	call   f010169e <page_alloc>
f010368b:	89 c6                	mov    %eax,%esi
f010368d:	85 c0                	test   %eax,%eax
f010368f:	75 24                	jne    f01036b5 <mem_init+0xeaf>
f0103691:	c7 44 24 0c a0 84 10 	movl   $0xf01084a0,0xc(%esp)
f0103698:	f0 
f0103699:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01036a0:	f0 
f01036a1:	c7 44 24 04 08 05 00 	movl   $0x508,0x4(%esp)
f01036a8:	00 
f01036a9:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01036b0:	e8 d0 c9 ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f01036b5:	89 1c 24             	mov    %ebx,(%esp)
f01036b8:	e8 ca d6 ff ff       	call   f0100d87 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01036bd:	89 f8                	mov    %edi,%eax
f01036bf:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f01036c5:	c1 f8 03             	sar    $0x3,%eax
f01036c8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01036cb:	89 c2                	mov    %eax,%edx
f01036cd:	c1 ea 0c             	shr    $0xc,%edx
f01036d0:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f01036d6:	72 20                	jb     f01036f8 <mem_init+0xef2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01036d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036dc:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f01036e3:	f0 
f01036e4:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01036eb:	00 
f01036ec:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01036f3:	e8 8d c9 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01036f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01036ff:	00 
f0103700:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103707:	00 
f0103708:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010370d:	89 04 24             	mov    %eax,(%esp)
f0103710:	e8 a1 31 00 00       	call   f01068b6 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103715:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103718:	89 f0                	mov    %esi,%eax
f010371a:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f0103720:	c1 f8 03             	sar    $0x3,%eax
f0103723:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103726:	89 c2                	mov    %eax,%edx
f0103728:	c1 ea 0c             	shr    $0xc,%edx
f010372b:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f0103731:	72 20                	jb     f0103753 <mem_init+0xf4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103733:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103737:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f010373e:	f0 
f010373f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103746:	00 
f0103747:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f010374e:	e8 32 c9 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103753:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010375a:	00 
f010375b:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103762:	00 
f0103763:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103768:	89 04 24             	mov    %eax,(%esp)
f010376b:	e8 46 31 00 00       	call   f01068b6 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0103770:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103777:	00 
f0103778:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010377f:	00 
f0103780:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103784:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0103789:	89 04 24             	mov    %eax,(%esp)
f010378c:	e8 56 e2 ff ff       	call   f01019e7 <page_insert>
	assert(pp1->pp_ref == 1);
f0103791:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103796:	74 24                	je     f01037bc <mem_init+0xfb6>
f0103798:	c7 44 24 0c d7 84 10 	movl   $0xf01084d7,0xc(%esp)
f010379f:	f0 
f01037a0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01037a7:	f0 
f01037a8:	c7 44 24 04 0d 05 00 	movl   $0x50d,0x4(%esp)
f01037af:	00 
f01037b0:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01037b7:	e8 c9 c8 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01037bc:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01037c3:	01 01 01 
f01037c6:	74 24                	je     f01037ec <mem_init+0xfe6>
f01037c8:	c7 44 24 0c 04 83 10 	movl   $0xf0108304,0xc(%esp)
f01037cf:	f0 
f01037d0:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01037d7:	f0 
f01037d8:	c7 44 24 04 0e 05 00 	movl   $0x50e,0x4(%esp)
f01037df:	00 
f01037e0:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01037e7:	e8 99 c8 ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01037ec:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01037f3:	00 
f01037f4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037fb:	00 
f01037fc:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103800:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0103805:	89 04 24             	mov    %eax,(%esp)
f0103808:	e8 da e1 ff ff       	call   f01019e7 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010380d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103814:	02 02 02 
f0103817:	74 24                	je     f010383d <mem_init+0x1037>
f0103819:	c7 44 24 0c 28 83 10 	movl   $0xf0108328,0xc(%esp)
f0103820:	f0 
f0103821:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103828:	f0 
f0103829:	c7 44 24 04 10 05 00 	movl   $0x510,0x4(%esp)
f0103830:	00 
f0103831:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103838:	e8 48 c8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010383d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103842:	74 24                	je     f0103868 <mem_init+0x1062>
f0103844:	c7 44 24 0c f9 84 10 	movl   $0xf01084f9,0xc(%esp)
f010384b:	f0 
f010384c:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103853:	f0 
f0103854:	c7 44 24 04 11 05 00 	movl   $0x511,0x4(%esp)
f010385b:	00 
f010385c:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103863:	e8 1d c8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0103868:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010386d:	74 24                	je     f0103893 <mem_init+0x108d>
f010386f:	c7 44 24 0c 42 85 10 	movl   $0xf0108542,0xc(%esp)
f0103876:	f0 
f0103877:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f010387e:	f0 
f010387f:	c7 44 24 04 12 05 00 	movl   $0x512,0x4(%esp)
f0103886:	00 
f0103887:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f010388e:	e8 f2 c7 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103893:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f010389a:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010389d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038a0:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f01038a6:	c1 f8 03             	sar    $0x3,%eax
f01038a9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038ac:	89 c2                	mov    %eax,%edx
f01038ae:	c1 ea 0c             	shr    $0xc,%edx
f01038b1:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f01038b7:	72 20                	jb     f01038d9 <mem_init+0x10d3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038bd:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f01038c4:	f0 
f01038c5:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01038cc:	00 
f01038cd:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f01038d4:	e8 ac c7 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01038d9:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01038e0:	03 03 03 
f01038e3:	74 24                	je     f0103909 <mem_init+0x1103>
f01038e5:	c7 44 24 0c 4c 83 10 	movl   $0xf010834c,0xc(%esp)
f01038ec:	f0 
f01038ed:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01038f4:	f0 
f01038f5:	c7 44 24 04 14 05 00 	movl   $0x514,0x4(%esp)
f01038fc:	00 
f01038fd:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103904:	e8 7c c7 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103909:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103910:	00 
f0103911:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0103916:	89 04 24             	mov    %eax,(%esp)
f0103919:	e8 79 e0 ff ff       	call   f0101997 <page_remove>
	assert(pp2->pp_ref == 0);
f010391e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103923:	74 24                	je     f0103949 <mem_init+0x1143>
f0103925:	c7 44 24 0c 31 85 10 	movl   $0xf0108531,0xc(%esp)
f010392c:	f0 
f010392d:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103934:	f0 
f0103935:	c7 44 24 04 16 05 00 	movl   $0x516,0x4(%esp)
f010393c:	00 
f010393d:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103944:	e8 3c c7 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103949:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f010394e:	8b 08                	mov    (%eax),%ecx
f0103950:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103956:	89 da                	mov    %ebx,%edx
f0103958:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f010395e:	c1 fa 03             	sar    $0x3,%edx
f0103961:	c1 e2 0c             	shl    $0xc,%edx
f0103964:	39 d1                	cmp    %edx,%ecx
f0103966:	74 24                	je     f010398c <mem_init+0x1186>
f0103968:	c7 44 24 0c 58 7e 10 	movl   $0xf0107e58,0xc(%esp)
f010396f:	f0 
f0103970:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0103977:	f0 
f0103978:	c7 44 24 04 19 05 00 	movl   $0x519,0x4(%esp)
f010397f:	00 
f0103980:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f0103987:	e8 f9 c6 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f010398c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103992:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0103997:	74 24                	je     f01039bd <mem_init+0x11b7>
f0103999:	c7 44 24 0c e8 84 10 	movl   $0xf01084e8,0xc(%esp)
f01039a0:	f0 
f01039a1:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f01039a8:	f0 
f01039a9:	c7 44 24 04 1b 05 00 	movl   $0x51b,0x4(%esp)
f01039b0:	00 
f01039b1:	c7 04 24 a1 83 10 f0 	movl   $0xf01083a1,(%esp)
f01039b8:	e8 c8 c6 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f01039bd:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01039c3:	89 1c 24             	mov    %ebx,(%esp)
f01039c6:	e8 bc d3 ff ff       	call   f0100d87 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01039cb:	c7 04 24 78 83 10 f0 	movl   $0xf0108378,(%esp)
f01039d2:	e8 24 0a 00 00       	call   f01043fb <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01039d7:	83 c4 2c             	add    $0x2c,%esp
f01039da:	5b                   	pop    %ebx
f01039db:	5e                   	pop    %esi
f01039dc:	5f                   	pop    %edi
f01039dd:	5d                   	pop    %ebp
f01039de:	c3                   	ret    
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir,
f01039df:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01039e6:	00 
f01039e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01039ea:	05 00 00 00 10       	add    $0x10000000,%eax
f01039ef:	89 04 24             	mov    %eax,(%esp)
f01039f2:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01039f7:	ba 00 80 bf ef       	mov    $0xefbf8000,%edx
f01039fc:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0103a01:	e8 81 e0 ff ff       	call   f0101a87 <boot_map_region>
f0103a06:	bb 00 60 1e f0       	mov    $0xf01e6000,%ebx
f0103a0b:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f0103a10:	e9 b7 f7 ff ff       	jmp    f01031cc <mem_init+0x9c6>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103a15:	89 da                	mov    %ebx,%edx
f0103a17:	89 f8                	mov    %edi,%eax
f0103a19:	e8 2c d4 ff ff       	call   f0100e4a <check_va2pa>
f0103a1e:	e9 16 fa ff ff       	jmp    f0103439 <mem_init+0xc33>
	...

f0103a30 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103a30:	55                   	push   %ebp
f0103a31:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103a33:	b8 68 23 12 f0       	mov    $0xf0122368,%eax
f0103a38:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103a3b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103a40:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103a42:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103a44:	b0 10                	mov    $0x10,%al
f0103a46:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103a48:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103a4a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103a4c:	ea 53 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103a53
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103a53:	b0 00                	mov    $0x0,%al
f0103a55:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103a58:	5d                   	pop    %ebp
f0103a59:	c3                   	ret    

f0103a5a <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103a5a:	55                   	push   %ebp
f0103a5b:	89 e5                	mov    %esp,%ebp
f0103a5d:	b8 84 ef 01 00       	mov    $0x1ef84,%eax
f0103a62:	ba 00 00 00 00       	mov    $0x0,%edx
	int i;
	env_free_list = NULL;
	
	for(i = NENV-1;i>=0;i--)
	{
		envs[i].env_id = 0;
f0103a67:	8b 0d 40 c2 1d f0    	mov    0xf01dc240,%ecx
f0103a6d:	c7 44 01 48 00 00 00 	movl   $0x0,0x48(%ecx,%eax,1)
f0103a74:	00 
		envs[i].env_status = ENV_FREE;
f0103a75:	8b 0d 40 c2 1d f0    	mov    0xf01dc240,%ecx
f0103a7b:	c7 44 01 54 00 00 00 	movl   $0x0,0x54(%ecx,%eax,1)
f0103a82:	00 
		envs[i].env_link = env_free_list;
f0103a83:	8b 0d 40 c2 1d f0    	mov    0xf01dc240,%ecx
f0103a89:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
		env_free_list = &envs[i];
f0103a8d:	89 c2                	mov    %eax,%edx
f0103a8f:	03 15 40 c2 1d f0    	add    0xf01dc240,%edx
f0103a95:	83 e8 7c             	sub    $0x7c,%eax
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	
	for(i = NENV-1;i>=0;i--)
f0103a98:	83 f8 84             	cmp    $0xffffff84,%eax
f0103a9b:	75 ca                	jne    f0103a67 <env_init+0xd>
f0103a9d:	89 15 44 c2 1d f0    	mov    %edx,0xf01dc244
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	
	// Per-CPU part of the initialization
	env_init_percpu();
f0103aa3:	e8 88 ff ff ff       	call   f0103a30 <env_init_percpu>
}
f0103aa8:	5d                   	pop    %ebp
f0103aa9:	c3                   	ret    

f0103aaa <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103aaa:	55                   	push   %ebp
f0103aab:	89 e5                	mov    %esp,%ebp
f0103aad:	83 ec 18             	sub    $0x18,%esp
f0103ab0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103ab3:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103ab6:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103ab9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103abc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103abf:	85 c0                	test   %eax,%eax
f0103ac1:	75 17                	jne    f0103ada <envid2env+0x30>
		*env_store = curenv;
f0103ac3:	e8 9a 34 00 00       	call   f0106f62 <cpunum>
f0103ac8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103acb:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0103ad1:	89 06                	mov    %eax,(%esi)
f0103ad3:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0103ad8:	eb 69                	jmp    f0103b43 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103ada:	89 c3                	mov    %eax,%ebx
f0103adc:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103ae2:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103ae5:	03 1d 40 c2 1d f0    	add    0xf01dc240,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103aeb:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103aef:	74 05                	je     f0103af6 <envid2env+0x4c>
f0103af1:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103af4:	74 0d                	je     f0103b03 <envid2env+0x59>
		*env_store = 0;
f0103af6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0103afc:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103b01:	eb 40                	jmp    f0103b43 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103b03:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103b07:	74 33                	je     f0103b3c <envid2env+0x92>
f0103b09:	e8 54 34 00 00       	call   f0106f62 <cpunum>
f0103b0e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b11:	39 98 28 d0 1d f0    	cmp    %ebx,-0xfe22fd8(%eax)
f0103b17:	74 23                	je     f0103b3c <envid2env+0x92>
f0103b19:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103b1c:	e8 41 34 00 00       	call   f0106f62 <cpunum>
f0103b21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b24:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0103b2a:	3b 78 48             	cmp    0x48(%eax),%edi
f0103b2d:	74 0d                	je     f0103b3c <envid2env+0x92>
		*env_store = 0;
f0103b2f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0103b35:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103b3a:	eb 07                	jmp    f0103b43 <envid2env+0x99>
	}

	*env_store = e;
f0103b3c:	89 1e                	mov    %ebx,(%esi)
f0103b3e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0103b43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103b46:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103b49:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103b4c:	89 ec                	mov    %ebp,%esp
f0103b4e:	5d                   	pop    %ebp
f0103b4f:	c3                   	ret    

f0103b50 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103b50:	55                   	push   %ebp
f0103b51:	89 e5                	mov    %esp,%ebp
f0103b53:	83 ec 38             	sub    $0x38,%esp
f0103b56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103b59:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103b5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103b5f:	8b 75 08             	mov    0x8(%ebp),%esi
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103b62:	e8 fb 33 00 00       	call   f0106f62 <cpunum>
f0103b67:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b6a:	8b 98 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%ebx
f0103b70:	e8 ed 33 00 00       	call   f0106f62 <cpunum>
f0103b75:	89 43 5c             	mov    %eax,0x5c(%ebx)
	//cprintf("%s:env_pop_tf[%d]: [%x] to run\n", __FILE__, __LINE__, curenv->env_id);
	if(tf->tf_trapno == T_SYSCALL)	
f0103b78:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f0103b7c:	75 60                	jne    f0103bde <env_pop_tf+0x8e>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103b7e:	c7 04 24 80 23 12 f0 	movl   $0xf0122380,(%esp)
f0103b85:	e8 82 36 00 00       	call   f010720c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103b8a:	f3 90                	pause  
		//cprintf("%s:env_pop_tf[%d]: sysexit [%x] with  %x\n", __FILE__, __LINE__, curenv->env_id,curenv->env_tf.tf_regs.reg_eax);
		asm volatile(
			"sti\n\t"
			"sysexit\n\t"
			:
			:"c" (curenv->env_tf.tf_regs.reg_ecx),
f0103b8c:	e8 d1 33 00 00       	call   f0106f62 <cpunum>
f0103b91:	bb 20 d0 1d f0       	mov    $0xf01dd020,%ebx
f0103b96:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b99:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103b9d:	8b 40 18             	mov    0x18(%eax),%eax
f0103ba0:	89 45 e0             	mov    %eax,-0x20(%ebp)
			 "d" (curenv->env_tf.tf_regs.reg_edx),
f0103ba3:	e8 ba 33 00 00       	call   f0106f62 <cpunum>
f0103ba8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bab:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103baf:	8b 40 14             	mov    0x14(%eax),%eax
f0103bb2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			 "a" (curenv->env_tf.tf_regs.reg_eax),
f0103bb5:	e8 a8 33 00 00       	call   f0106f62 <cpunum>
f0103bba:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bbd:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103bc1:	8b 78 1c             	mov    0x1c(%eax),%edi
			 "b" (curenv->env_tf.tf_eflags)
f0103bc4:	e8 99 33 00 00       	call   f0106f62 <cpunum>
	{
		unlock_kernel();
		//print_trapframe(tf);
    //if (curenv->env_id == 0x1009)
		//cprintf("%s:env_pop_tf[%d]: sysexit [%x] with  %x\n", __FILE__, __LINE__, curenv->env_id,curenv->env_tf.tf_regs.reg_eax);
		asm volatile(
f0103bc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bcc:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103bd0:	8b 58 38             	mov    0x38(%eax),%ebx
f0103bd3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103bd6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103bd9:	89 f8                	mov    %edi,%eax
f0103bdb:	fb                   	sti    
f0103bdc:	0f 35                	sysexit 
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103bde:	c7 04 24 80 23 12 f0 	movl   $0xf0122380,(%esp)
f0103be5:	e8 22 36 00 00       	call   f010720c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103bea:	f3 90                	pause  
			);
	}
	unlock_kernel();
	//cprintf("%s:env_pop_tf[%d]: iret [%x] with IF %x[%x]\n", __FILE__, __LINE__, curenv->env_id, curenv->env_tf.tf_eflags & FL_IF, read_eflags()& FL_IF);
	/* cprintf("%x not syscall\t%d\n",curenv->env_id,curenv->env_type); */
	__asm __volatile("movl %0,%%esp\n"
f0103bec:	89 f4                	mov    %esi,%esp
f0103bee:	61                   	popa   
f0103bef:	07                   	pop    %es
f0103bf0:	1f                   	pop    %ds
f0103bf1:	83 c4 08             	add    $0x8,%esp
f0103bf4:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103bf5:	c7 44 24 08 57 87 10 	movl   $0xf0108757,0x8(%esp)
f0103bfc:	f0 
f0103bfd:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
f0103c04:	00 
f0103c05:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0103c0c:	e8 74 c4 ff ff       	call   f0100085 <_panic>

f0103c11 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c11:	55                   	push   %ebp
f0103c12:	89 e5                	mov    %esp,%ebp
f0103c14:	53                   	push   %ebx
f0103c15:	83 ec 14             	sub    $0x14,%esp
f0103c18:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	/* cprintf("go for run\n"); */
	if(curenv != e)
f0103c1b:	e8 42 33 00 00       	call   f0106f62 <cpunum>
f0103c20:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c23:	39 98 28 d0 1d f0    	cmp    %ebx,-0xfe22fd8(%eax)
f0103c29:	0f 84 88 00 00 00    	je     f0103cb7 <env_run+0xa6>
	{
		if(curenv)
f0103c2f:	e8 2e 33 00 00       	call   f0106f62 <cpunum>
f0103c34:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c37:	83 b8 28 d0 1d f0 00 	cmpl   $0x0,-0xfe22fd8(%eax)
f0103c3e:	74 29                	je     f0103c69 <env_run+0x58>
			if (curenv->env_status == ENV_RUNNING)
f0103c40:	e8 1d 33 00 00       	call   f0106f62 <cpunum>
f0103c45:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c48:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0103c4e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c52:	75 15                	jne    f0103c69 <env_run+0x58>
				curenv->env_status = ENV_RUNNABLE;
f0103c54:	e8 09 33 00 00       	call   f0106f62 <cpunum>
f0103c59:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c5c:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0103c62:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0103c69:	e8 f4 32 00 00       	call   f0106f62 <cpunum>
f0103c6e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c71:	89 98 28 d0 1d f0    	mov    %ebx,-0xfe22fd8(%eax)
		e->env_status = ENV_RUNNING;
f0103c77:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0103c7e:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));	
f0103c82:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103c85:	89 c2                	mov    %eax,%edx
f0103c87:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103c8c:	77 20                	ja     f0103cae <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103c8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c92:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0103c99:	f0 
f0103c9a:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
f0103ca1:	00 
f0103ca2:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0103ca9:	e8 d7 c3 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103cae:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103cb4:	0f 22 da             	mov    %edx,%cr3
	}
	//cprintf("%s:env_run[%d]: [%x] to run with IF %x[%x]\n", __FILE__, __LINE__, curenv->env_id, curenv->env_tf.tf_eflags & FL_IF, read_eflags() & FL_IF);
	env_pop_tf(&e->env_tf);
f0103cb7:	89 1c 24             	mov    %ebx,(%esp)
f0103cba:	e8 91 fe ff ff       	call   f0103b50 <env_pop_tf>

f0103cbf <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103cbf:	55                   	push   %ebp
f0103cc0:	89 e5                	mov    %esp,%ebp
f0103cc2:	57                   	push   %edi
f0103cc3:	56                   	push   %esi
f0103cc4:	53                   	push   %ebx
f0103cc5:	83 ec 2c             	sub    $0x2c,%esp
f0103cc8:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103ccb:	e8 92 32 00 00       	call   f0106f62 <cpunum>
f0103cd0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103cda:	39 b8 28 d0 1d f0    	cmp    %edi,-0xfe22fd8(%eax)
f0103ce0:	75 3c                	jne    f0103d1e <env_free+0x5f>
		lcr3(PADDR(kern_pgdir));
f0103ce2:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ce7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103cec:	77 20                	ja     f0103d0e <env_free+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cf2:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0103cf9:	f0 
f0103cfa:	c7 44 24 04 ac 01 00 	movl   $0x1ac,0x4(%esp)
f0103d01:	00 
f0103d02:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0103d09:	e8 77 c3 ff ff       	call   f0100085 <_panic>
f0103d0e:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103d14:	0f 22 d8             	mov    %eax,%cr3
f0103d17:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103d1e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d21:	c1 e0 02             	shl    $0x2,%eax
f0103d24:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103d27:	8b 47 60             	mov    0x60(%edi),%eax
f0103d2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103d2d:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103d30:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103d36:	0f 84 b8 00 00 00    	je     f0103df4 <env_free+0x135>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103d3c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d42:	89 f0                	mov    %esi,%eax
f0103d44:	c1 e8 0c             	shr    $0xc,%eax
f0103d47:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d4a:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0103d50:	72 20                	jb     f0103d72 <env_free+0xb3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103d52:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103d56:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0103d5d:	f0 
f0103d5e:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f0103d65:	00 
f0103d66:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0103d6d:	e8 13 c3 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103d72:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103d75:	c1 e2 16             	shl    $0x16,%edx
f0103d78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103d7b:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0103d80:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103d87:	01 
f0103d88:	74 17                	je     f0103da1 <env_free+0xe2>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103d8a:	89 d8                	mov    %ebx,%eax
f0103d8c:	c1 e0 0c             	shl    $0xc,%eax
f0103d8f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103d92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d96:	8b 47 60             	mov    0x60(%edi),%eax
f0103d99:	89 04 24             	mov    %eax,(%esp)
f0103d9c:	e8 f6 db ff ff       	call   f0101997 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103da1:	83 c3 01             	add    $0x1,%ebx
f0103da4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103daa:	75 d4                	jne    f0103d80 <env_free+0xc1>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103dac:	8b 47 60             	mov    0x60(%edi),%eax
f0103daf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103db2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103db9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103dbc:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0103dc2:	72 1c                	jb     f0103de0 <env_free+0x121>
		panic("pa2page called with invalid pa");
f0103dc4:	c7 44 24 08 48 7d 10 	movl   $0xf0107d48,0x8(%esp)
f0103dcb:	f0 
f0103dcc:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103dd3:	00 
f0103dd4:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0103ddb:	e8 a5 c2 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0103de0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103de3:	c1 e0 03             	shl    $0x3,%eax
f0103de6:	03 05 90 ce 1d f0    	add    0xf01dce90,%eax
f0103dec:	89 04 24             	mov    %eax,(%esp)
f0103def:	e8 fe cf ff ff       	call   f0100df2 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103df4:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103df8:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103dff:	0f 85 19 ff ff ff    	jne    f0103d1e <env_free+0x5f>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103e05:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e08:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e0d:	77 20                	ja     f0103e2f <env_free+0x170>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e13:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0103e1a:	f0 
f0103e1b:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f0103e22:	00 
f0103e23:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0103e2a:	e8 56 c2 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0103e2f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e36:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103e3c:	c1 e8 0c             	shr    $0xc,%eax
f0103e3f:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0103e45:	72 1c                	jb     f0103e63 <env_free+0x1a4>
		panic("pa2page called with invalid pa");
f0103e47:	c7 44 24 08 48 7d 10 	movl   $0xf0107d48,0x8(%esp)
f0103e4e:	f0 
f0103e4f:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103e56:	00 
f0103e57:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0103e5e:	e8 22 c2 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0103e63:	c1 e0 03             	shl    $0x3,%eax
f0103e66:	03 05 90 ce 1d f0    	add    0xf01dce90,%eax
f0103e6c:	89 04 24             	mov    %eax,(%esp)
f0103e6f:	e8 7e cf ff ff       	call   f0100df2 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103e74:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103e7b:	a1 44 c2 1d f0       	mov    0xf01dc244,%eax
f0103e80:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103e83:	89 3d 44 c2 1d f0    	mov    %edi,0xf01dc244
}
f0103e89:	83 c4 2c             	add    $0x2c,%esp
f0103e8c:	5b                   	pop    %ebx
f0103e8d:	5e                   	pop    %esi
f0103e8e:	5f                   	pop    %edi
f0103e8f:	5d                   	pop    %ebp
f0103e90:	c3                   	ret    

f0103e91 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103e91:	55                   	push   %ebp
f0103e92:	89 e5                	mov    %esp,%ebp
f0103e94:	53                   	push   %ebx
f0103e95:	83 ec 14             	sub    $0x14,%esp
f0103e98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103e9b:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103e9f:	75 19                	jne    f0103eba <env_destroy+0x29>
f0103ea1:	e8 bc 30 00 00       	call   f0106f62 <cpunum>
f0103ea6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ea9:	39 98 28 d0 1d f0    	cmp    %ebx,-0xfe22fd8(%eax)
f0103eaf:	74 09                	je     f0103eba <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103eb1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103eb8:	eb 2f                	jmp    f0103ee9 <env_destroy+0x58>
	}

	env_free(e);
f0103eba:	89 1c 24             	mov    %ebx,(%esp)
f0103ebd:	e8 fd fd ff ff       	call   f0103cbf <env_free>

	if (curenv == e) {
f0103ec2:	e8 9b 30 00 00       	call   f0106f62 <cpunum>
f0103ec7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eca:	39 98 28 d0 1d f0    	cmp    %ebx,-0xfe22fd8(%eax)
f0103ed0:	75 17                	jne    f0103ee9 <env_destroy+0x58>
		curenv = NULL;
f0103ed2:	e8 8b 30 00 00       	call   f0106f62 <cpunum>
f0103ed7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eda:	c7 80 28 d0 1d f0 00 	movl   $0x0,-0xfe22fd8(%eax)
f0103ee1:	00 00 00 
		sched_yield();
f0103ee4:	e8 27 13 00 00       	call   f0105210 <sched_yield>
	}
}
f0103ee9:	83 c4 14             	add    $0x14,%esp
f0103eec:	5b                   	pop    %ebx
f0103eed:	5d                   	pop    %ebp
f0103eee:	c3                   	ret    

f0103eef <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103eef:	55                   	push   %ebp
f0103ef0:	89 e5                	mov    %esp,%ebp
f0103ef2:	53                   	push   %ebx
f0103ef3:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103ef6:	8b 1d 44 c2 1d f0    	mov    0xf01dc244,%ebx
f0103efc:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103f01:	85 db                	test   %ebx,%ebx
f0103f03:	0f 84 70 01 00 00    	je     f0104079 <env_alloc+0x18a>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103f09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103f10:	e8 89 d7 ff ff       	call   f010169e <page_alloc>
f0103f15:	89 c2                	mov    %eax,%edx
f0103f17:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103f1c:	85 d2                	test   %edx,%edx
f0103f1e:	0f 84 55 01 00 00    	je     f0104079 <env_alloc+0x18a>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103f24:	2b 15 90 ce 1d f0    	sub    0xf01dce90,%edx
f0103f2a:	c1 fa 03             	sar    $0x3,%edx
f0103f2d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f30:	89 d0                	mov    %edx,%eax
f0103f32:	c1 e8 0c             	shr    $0xc,%eax
f0103f35:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0103f3b:	72 20                	jb     f0103f5d <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f3d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f41:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0103f48:	f0 
f0103f49:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103f50:	00 
f0103f51:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f0103f58:	e8 28 c1 ff ff       	call   f0100085 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f0103f5d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103f63:	89 53 60             	mov    %edx,0x60(%ebx)
	
	memset(e->env_pgdir,0,PGSIZE);
f0103f66:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103f6d:	00 
f0103f6e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103f75:	00 
f0103f76:	89 14 24             	mov    %edx,(%esp)
f0103f79:	e8 38 29 00 00       	call   f01068b6 <memset>
	memmove(e->env_pgdir,kern_pgdir,PGSIZE);
f0103f7e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103f85:	00 
f0103f86:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
f0103f8b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f8f:	8b 43 60             	mov    0x60(%ebx),%eax
f0103f92:	89 04 24             	mov    %eax,(%esp)
f0103f95:	e8 7b 29 00 00       	call   f0106915 <memmove>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103f9a:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103f9d:	89 c2                	mov    %eax,%edx
f0103f9f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103fa4:	77 20                	ja     f0103fc6 <env_alloc+0xd7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103fa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103faa:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0103fb1:	f0 
f0103fb2:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0103fb9:	00 
f0103fba:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0103fc1:	e8 bf c0 ff ff       	call   f0100085 <_panic>
f0103fc6:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103fcc:	83 ca 05             	or     $0x5,%edx
f0103fcf:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103fd5:	8b 43 48             	mov    0x48(%ebx),%eax
f0103fd8:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103fdd:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103fe2:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103fe7:	0f 4e c2             	cmovle %edx,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103fea:	89 da                	mov    %ebx,%edx
f0103fec:	2b 15 40 c2 1d f0    	sub    0xf01dc240,%edx
f0103ff2:	c1 fa 02             	sar    $0x2,%edx
f0103ff5:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103ffb:	09 d0                	or     %edx,%eax
f0103ffd:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0104000:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104003:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0104006:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010400d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0104014:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010401b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104022:	00 
f0104023:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010402a:	00 
f010402b:	89 1c 24             	mov    %ebx,(%esp)
f010402e:	e8 83 28 00 00       	call   f01068b6 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0104033:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0104039:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010403f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0104045:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010404c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0104052:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104059:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0104060:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0104067:	8b 43 44             	mov    0x44(%ebx),%eax
f010406a:	a3 44 c2 1d f0       	mov    %eax,0xf01dc244
	*newenv_store = e;
f010406f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104072:	89 18                	mov    %ebx,(%eax)
f0104074:	b8 00 00 00 00       	mov    $0x0,%eax

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0104079:	83 c4 14             	add    $0x14,%esp
f010407c:	5b                   	pop    %ebx
f010407d:	5d                   	pop    %ebp
f010407e:	c3                   	ret    

f010407f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010407f:	55                   	push   %ebp
f0104080:	89 e5                	mov    %esp,%ebp
f0104082:	57                   	push   %edi
f0104083:	56                   	push   %esi
f0104084:	53                   	push   %ebx
f0104085:	83 ec 1c             	sub    $0x1c,%esp
f0104088:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	va = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE);
f010408a:	8d b9 ff 0f 00 00    	lea    0xfff(%ecx),%edi
	
	struct Page *pp;
	int i;
	for(;len > 0;len -= PGSIZE, va += PGSIZE)
f0104090:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0104096:	0f 84 83 00 00 00    	je     f010411f <region_alloc+0xa0>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	va = ROUNDDOWN(va,PGSIZE);
f010409c:	89 d3                	mov    %edx,%ebx
f010409e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	struct Page *pp;
	int i;
	for(;len > 0;len -= PGSIZE, va += PGSIZE)
	{
		pp = page_alloc(0);
f01040a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01040ab:	e8 ee d5 ff ff       	call   f010169e <page_alloc>
		if(pp == NULL)
f01040b0:	85 c0                	test   %eax,%eax
f01040b2:	75 1c                	jne    f01040d0 <region_alloc+0x51>
			panic ("region_alloc: page_alloc failed%e");
f01040b4:	c7 44 24 08 a4 87 10 	movl   $0xf01087a4,0x8(%esp)
f01040bb:	f0 
f01040bc:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f01040c3:	00 
f01040c4:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f01040cb:	e8 b5 bf ff ff       	call   f0100085 <_panic>
		if((i = page_insert(e->env_pgdir,pp,va,PTE_U | PTE_W)))
f01040d0:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01040d7:	00 
f01040d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01040dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01040e0:	8b 46 60             	mov    0x60(%esi),%eax
f01040e3:	89 04 24             	mov    %eax,(%esp)
f01040e6:	e8 fc d8 ff ff       	call   f01019e7 <page_insert>
f01040eb:	85 c0                	test   %eax,%eax
f01040ed:	74 20                	je     f010410f <region_alloc+0x90>
			panic ("region_alloc: page_insert failed%e", i);
f01040ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01040f3:	c7 44 24 08 c8 87 10 	movl   $0xf01087c8,0x8(%esp)
f01040fa:	f0 
f01040fb:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0104102:	00 
f0104103:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f010410a:	e8 76 bf ff ff       	call   f0100085 <_panic>
	va = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE);
	
	struct Page *pp;
	int i;
	for(;len > 0;len -= PGSIZE, va += PGSIZE)
f010410f:	81 ef 00 10 00 00    	sub    $0x1000,%edi
f0104115:	74 08                	je     f010411f <region_alloc+0xa0>
f0104117:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010411d:	eb 85                	jmp    f01040a4 <region_alloc+0x25>
			panic ("region_alloc: page_alloc failed%e");
		if((i = page_insert(e->env_pgdir,pp,va,PTE_U | PTE_W)))
			panic ("region_alloc: page_insert failed%e", i);

	}
}
f010411f:	83 c4 1c             	add    $0x1c,%esp
f0104122:	5b                   	pop    %ebx
f0104123:	5e                   	pop    %esi
f0104124:	5f                   	pop    %edi
f0104125:	5d                   	pop    %ebp
f0104126:	c3                   	ret    

f0104127 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0104127:	55                   	push   %ebp
f0104128:	89 e5                	mov    %esp,%ebp
f010412a:	57                   	push   %edi
f010412b:	56                   	push   %esi
f010412c:	53                   	push   %ebx
f010412d:	83 ec 3c             	sub    $0x3c,%esp
f0104130:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	int r;
	struct Env *e;
	if((r = env_alloc(&e,0))<0)
f0104133:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010413a:	00 
f010413b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010413e:	89 04 24             	mov    %eax,(%esp)
f0104141:	e8 a9 fd ff ff       	call   f0103eef <env_alloc>
f0104146:	85 c0                	test   %eax,%eax
f0104148:	79 20                	jns    f010416a <env_create+0x43>
		panic("env_create:env_alloc wrong%e",r);
f010414a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010414e:	c7 44 24 08 6e 87 10 	movl   $0xf010876e,0x8(%esp)
f0104155:	f0 
f0104156:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
f010415d:	00 
f010415e:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0104165:	e8 1b bf ff ff       	call   f0100085 <_panic>
	load_icode(e,binary,size);
f010416a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf  *hdr;
	struct Proghdr	*ph,*eph;
	hdr = (struct Elf*)binary;
f010416d:	89 75 d0             	mov    %esi,-0x30(%ebp)
	if(hdr->e_magic != ELF_MAGIC)
f0104170:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f0104176:	74 1c                	je     f0104194 <env_create+0x6d>
		panic("load_icode: elf wrong");
f0104178:	c7 44 24 08 8b 87 10 	movl   $0xf010878b,0x8(%esp)
f010417f:	f0 
f0104180:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f0104187:	00 
f0104188:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f010418f:	e8 f1 be ff ff       	call   f0100085 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) hdr + hdr->e_phoff);
f0104194:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104197:	8b 58 1c             	mov    0x1c(%eax),%ebx
	eph = ph + hdr->e_phnum;
f010419a:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
	
	lcr3(PADDR(e->env_pgdir));
f010419e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01041a1:	89 c1                	mov    %eax,%ecx
f01041a3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01041a8:	77 20                	ja     f01041ca <env_create+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01041aa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041ae:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f01041b5:	f0 
f01041b6:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01041bd:	00 
f01041be:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f01041c5:	e8 bb be ff ff       	call   f0100085 <_panic>
	struct Elf  *hdr;
	struct Proghdr	*ph,*eph;
	hdr = (struct Elf*)binary;
	if(hdr->e_magic != ELF_MAGIC)
		panic("load_icode: elf wrong");
	ph = (struct Proghdr *) ((uint8_t *) hdr + hdr->e_phoff);
f01041ca:	03 5d d0             	add    -0x30(%ebp),%ebx
	eph = ph + hdr->e_phnum;
f01041cd:	0f b7 d2             	movzwl %dx,%edx
f01041d0:	c1 e2 05             	shl    $0x5,%edx
f01041d3:	8d 14 13             	lea    (%ebx,%edx,1),%edx
f01041d6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01041d9:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f01041df:	0f 22 d9             	mov    %ecx,%cr3
	
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++)
f01041e2:	39 d3                	cmp    %edx,%ebx
f01041e4:	73 4a                	jae    f0104230 <env_create+0x109>
	{
		region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f01041e6:	8b 4b 14             	mov    0x14(%ebx),%ecx
f01041e9:	8b 53 08             	mov    0x8(%ebx),%edx
f01041ec:	89 f8                	mov    %edi,%eax
f01041ee:	e8 8c fe ff ff       	call   f010407f <region_alloc>
		memset((void*)ph->p_va,0,ph->p_memsz);
f01041f3:	8b 43 14             	mov    0x14(%ebx),%eax
f01041f6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01041fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104201:	00 
f0104202:	8b 43 08             	mov    0x8(%ebx),%eax
f0104205:	89 04 24             	mov    %eax,(%esp)
f0104208:	e8 a9 26 00 00       	call   f01068b6 <memset>
		memmove ((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010420d:	8b 43 10             	mov    0x10(%ebx),%eax
f0104210:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104214:	89 f0                	mov    %esi,%eax
f0104216:	03 43 04             	add    0x4(%ebx),%eax
f0104219:	89 44 24 04          	mov    %eax,0x4(%esp)
f010421d:	8b 43 08             	mov    0x8(%ebx),%eax
f0104220:	89 04 24             	mov    %eax,(%esp)
f0104223:	e8 ed 26 00 00       	call   f0106915 <memmove>
		panic("load_icode: elf wrong");
	ph = (struct Proghdr *) ((uint8_t *) hdr + hdr->e_phoff);
	eph = ph + hdr->e_phnum;
	
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++)
f0104228:	83 c3 20             	add    $0x20,%ebx
f010422b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010422e:	77 b6                	ja     f01041e6 <env_create+0xbf>
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	e->env_tf.tf_eip = hdr->e_entry;
f0104230:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104233:	8b 42 18             	mov    0x18(%edx),%eax
f0104236:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e,(void*) (USTACKTOP - PGSIZE), PGSIZE);
f0104239:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010423e:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104243:	89 f8                	mov    %edi,%eax
f0104245:	e8 35 fe ff ff       	call   f010407f <region_alloc>
	
	lcr3(PADDR(kern_pgdir));
f010424a:	a1 8c ce 1d f0       	mov    0xf01dce8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010424f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104254:	77 20                	ja     f0104276 <env_create+0x14f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104256:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010425a:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f0104261:	f0 
f0104262:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f0104269:	00 
f010426a:	c7 04 24 63 87 10 f0 	movl   $0xf0108763,(%esp)
f0104271:	e8 0f be ff ff       	call   f0100085 <_panic>
f0104276:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010427c:	0f 22 d8             	mov    %eax,%cr3
	int r;
	struct Env *e;
	if((r = env_alloc(&e,0))<0)
		panic("env_create:env_alloc wrong%e",r);
	load_icode(e,binary,size);
	e->env_type = type;
f010427f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104282:	8b 55 10             	mov    0x10(%ebp),%edx
f0104285:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
  if (e->env_type == ENV_TYPE_FS)
f0104288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010428b:	83 78 50 02          	cmpl   $0x2,0x50(%eax)
f010428f:	75 07                	jne    f0104298 <env_create+0x171>
    e->env_tf.tf_eflags |= FL_IOPL_3;
f0104291:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f0104298:	83 c4 3c             	add    $0x3c,%esp
f010429b:	5b                   	pop    %ebx
f010429c:	5e                   	pop    %esi
f010429d:	5f                   	pop    %edi
f010429e:	5d                   	pop    %ebp
f010429f:	c3                   	ret    

f01042a0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01042a0:	55                   	push   %ebp
f01042a1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01042a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01042ab:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01042ac:	b2 71                	mov    $0x71,%dl
f01042ae:	ec                   	in     (%dx),%al
f01042af:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01042b2:	5d                   	pop    %ebp
f01042b3:	c3                   	ret    

f01042b4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01042b4:	55                   	push   %ebp
f01042b5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042b7:	ba 70 00 00 00       	mov    $0x70,%edx
f01042bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01042bf:	ee                   	out    %al,(%dx)
f01042c0:	b2 71                	mov    $0x71,%dl
f01042c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01042c5:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01042c6:	5d                   	pop    %ebp
f01042c7:	c3                   	ret    

f01042c8 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01042c8:	55                   	push   %ebp
f01042c9:	89 e5                	mov    %esp,%ebp
f01042cb:	56                   	push   %esi
f01042cc:	53                   	push   %ebx
f01042cd:	83 ec 10             	sub    $0x10,%esp
f01042d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01042d3:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f01042d5:	66 a3 70 23 12 f0    	mov    %ax,0xf0122370
	if (!didinit)
f01042db:	83 3d 48 c2 1d f0 00 	cmpl   $0x0,0xf01dc248
f01042e2:	74 4e                	je     f0104332 <irq_setmask_8259A+0x6a>
f01042e4:	ba 21 00 00 00       	mov    $0x21,%edx
f01042e9:	ee                   	out    %al,(%dx)
f01042ea:	89 f0                	mov    %esi,%eax
f01042ec:	66 c1 e8 08          	shr    $0x8,%ax
f01042f0:	b2 a1                	mov    $0xa1,%dl
f01042f2:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f01042f3:	c7 04 24 eb 87 10 f0 	movl   $0xf01087eb,(%esp)
f01042fa:	e8 fc 00 00 00       	call   f01043fb <cprintf>
f01042ff:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0104304:	0f b7 f6             	movzwl %si,%esi
f0104307:	f7 d6                	not    %esi
f0104309:	0f a3 de             	bt     %ebx,%esi
f010430c:	73 10                	jae    f010431e <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f010430e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104312:	c7 04 24 ec 8c 10 f0 	movl   $0xf0108cec,(%esp)
f0104319:	e8 dd 00 00 00       	call   f01043fb <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010431e:	83 c3 01             	add    $0x1,%ebx
f0104321:	83 fb 10             	cmp    $0x10,%ebx
f0104324:	75 e3                	jne    f0104309 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104326:	c7 04 24 b7 89 10 f0 	movl   $0xf01089b7,(%esp)
f010432d:	e8 c9 00 00 00       	call   f01043fb <cprintf>
}
f0104332:	83 c4 10             	add    $0x10,%esp
f0104335:	5b                   	pop    %ebx
f0104336:	5e                   	pop    %esi
f0104337:	5d                   	pop    %ebp
f0104338:	c3                   	ret    

f0104339 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0104339:	55                   	push   %ebp
f010433a:	89 e5                	mov    %esp,%ebp
f010433c:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f010433f:	c7 05 48 c2 1d f0 01 	movl   $0x1,0xf01dc248
f0104346:	00 00 00 
f0104349:	ba 21 00 00 00       	mov    $0x21,%edx
f010434e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104353:	ee                   	out    %al,(%dx)
f0104354:	b2 a1                	mov    $0xa1,%dl
f0104356:	ee                   	out    %al,(%dx)
f0104357:	b2 20                	mov    $0x20,%dl
f0104359:	b8 11 00 00 00       	mov    $0x11,%eax
f010435e:	ee                   	out    %al,(%dx)
f010435f:	b2 21                	mov    $0x21,%dl
f0104361:	b8 20 00 00 00       	mov    $0x20,%eax
f0104366:	ee                   	out    %al,(%dx)
f0104367:	b8 04 00 00 00       	mov    $0x4,%eax
f010436c:	ee                   	out    %al,(%dx)
f010436d:	b8 03 00 00 00       	mov    $0x3,%eax
f0104372:	ee                   	out    %al,(%dx)
f0104373:	b2 a0                	mov    $0xa0,%dl
f0104375:	b8 11 00 00 00       	mov    $0x11,%eax
f010437a:	ee                   	out    %al,(%dx)
f010437b:	b2 a1                	mov    $0xa1,%dl
f010437d:	b8 28 00 00 00       	mov    $0x28,%eax
f0104382:	ee                   	out    %al,(%dx)
f0104383:	b8 02 00 00 00       	mov    $0x2,%eax
f0104388:	ee                   	out    %al,(%dx)
f0104389:	b8 01 00 00 00       	mov    $0x1,%eax
f010438e:	ee                   	out    %al,(%dx)
f010438f:	b2 20                	mov    $0x20,%dl
f0104391:	b8 68 00 00 00       	mov    $0x68,%eax
f0104396:	ee                   	out    %al,(%dx)
f0104397:	b8 0a 00 00 00       	mov    $0xa,%eax
f010439c:	ee                   	out    %al,(%dx)
f010439d:	b2 a0                	mov    $0xa0,%dl
f010439f:	b8 68 00 00 00       	mov    $0x68,%eax
f01043a4:	ee                   	out    %al,(%dx)
f01043a5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043aa:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01043ab:	0f b7 05 70 23 12 f0 	movzwl 0xf0122370,%eax
f01043b2:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01043b6:	74 0b                	je     f01043c3 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f01043b8:	0f b7 c0             	movzwl %ax,%eax
f01043bb:	89 04 24             	mov    %eax,(%esp)
f01043be:	e8 05 ff ff ff       	call   f01042c8 <irq_setmask_8259A>
}
f01043c3:	c9                   	leave  
f01043c4:	c3                   	ret    
f01043c5:	00 00                	add    %al,(%eax)
	...

f01043c8 <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f01043c8:	55                   	push   %ebp
f01043c9:	89 e5                	mov    %esp,%ebp
f01043cb:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01043ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01043d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01043d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01043dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01043df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01043e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043ea:	c7 04 24 15 44 10 f0 	movl   $0xf0104415,(%esp)
f01043f1:	e8 c7 1c 00 00       	call   f01060bd <vprintfmt>
	return cnt;
}
f01043f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01043f9:	c9                   	leave  
f01043fa:	c3                   	ret    

f01043fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01043fb:	55                   	push   %ebp
f01043fc:	89 e5                	mov    %esp,%ebp
f01043fe:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0104401:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0104404:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104408:	8b 45 08             	mov    0x8(%ebp),%eax
f010440b:	89 04 24             	mov    %eax,(%esp)
f010440e:	e8 b5 ff ff ff       	call   f01043c8 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104413:	c9                   	leave  
f0104414:	c3                   	ret    

f0104415 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104415:	55                   	push   %ebp
f0104416:	89 e5                	mov    %esp,%ebp
f0104418:	53                   	push   %ebx
f0104419:	83 ec 14             	sub    $0x14,%esp
f010441c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f010441f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104422:	89 04 24             	mov    %eax,(%esp)
f0104425:	e8 d0 c2 ff ff       	call   f01006fa <cputchar>
    (*cnt)++;
f010442a:	83 03 01             	addl   $0x1,(%ebx)
}
f010442d:	83 c4 14             	add    $0x14,%esp
f0104430:	5b                   	pop    %ebx
f0104431:	5d                   	pop    %ebp
f0104432:	c3                   	ret    
	...

f0104440 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104440:	55                   	push   %ebp
f0104441:	89 e5                	mov    %esp,%ebp
f0104443:	57                   	push   %edi
f0104444:	56                   	push   %esi
f0104445:	53                   	push   %ebx
f0104446:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int i = thiscpu->cpu_id;
f0104449:	e8 14 2b 00 00       	call   f0106f62 <cpunum>
f010444e:	bb 20 d0 1d f0       	mov    $0xf01dd020,%ebx
f0104453:	6b c0 74             	imul   $0x74,%eax,%eax
f0104456:	0f b6 34 18          	movzbl (%eax,%ebx,1),%esi
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f010445a:	e8 03 2b 00 00       	call   f0106f62 <cpunum>
f010445f:	89 f2                	mov    %esi,%edx
f0104461:	f7 da                	neg    %edx
f0104463:	c1 e2 10             	shl    $0x10,%edx
f0104466:	81 ea 00 00 40 10    	sub    $0x10400000,%edx
f010446c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010446f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104472:	89 54 18 10          	mov    %edx,0x10(%eax,%ebx,1)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0104476:	e8 e7 2a 00 00       	call   f0106f62 <cpunum>
f010447b:	6b c0 74             	imul   $0x74,%eax,%eax
f010447e:	66 c7 44 18 14 10 00 	movw   $0x10,0x14(%eax,%ebx,1)
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&thiscpu->cpu_ts), sizeof(struct Taskstate), 0);
f0104485:	8d 5e 05             	lea    0x5(%esi),%ebx
f0104488:	e8 d5 2a 00 00       	call   f0106f62 <cpunum>
f010448d:	89 c6                	mov    %eax,%esi
f010448f:	e8 ce 2a 00 00       	call   f0106f62 <cpunum>
f0104494:	89 c7                	mov    %eax,%edi
f0104496:	e8 c7 2a 00 00       	call   f0106f62 <cpunum>
f010449b:	ba 00 23 12 f0       	mov    $0xf0122300,%edx
f01044a0:	66 c7 04 da 68 00    	movw   $0x68,(%edx,%ebx,8)
f01044a6:	6b f6 74             	imul   $0x74,%esi,%esi
f01044a9:	81 c6 2c d0 1d f0    	add    $0xf01dd02c,%esi
f01044af:	66 89 74 da 02       	mov    %si,0x2(%edx,%ebx,8)
f01044b4:	6b cf 74             	imul   $0x74,%edi,%ecx
f01044b7:	81 c1 2c d0 1d f0    	add    $0xf01dd02c,%ecx
f01044bd:	c1 e9 10             	shr    $0x10,%ecx
f01044c0:	88 4c da 04          	mov    %cl,0x4(%edx,%ebx,8)
f01044c4:	c6 44 da 06 40       	movb   $0x40,0x6(%edx,%ebx,8)
f01044c9:	6b c0 74             	imul   $0x74,%eax,%eax
f01044cc:	05 2c d0 1d f0       	add    $0xf01dd02c,%eax
f01044d1:	c1 e8 18             	shr    $0x18,%eax
f01044d4:	88 44 da 07          	mov    %al,0x7(%edx,%ebx,8)
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f01044d8:	c6 44 da 05 89       	movb   $0x89,0x5(%edx,%ebx,8)
	/* 				sizeof(struct Taskstate), 0); */
	/* gdt[GD_TSS0 >> 3].sd_s = 0; */

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	wrmsr(0x174, GD_KT, 0);				/* SYSENTER_CS_MSR */
f01044dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01044e2:	b8 08 00 00 00       	mov    $0x8,%eax
f01044e7:	b9 74 01 00 00       	mov    $0x174,%ecx
f01044ec:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP - i * (KSTKSIZE + KSTKGAP), 0);
f01044ee:	b1 75                	mov    $0x75,%cl
f01044f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044f3:	0f 30                	wrmsr  
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);	/* SYSENTER_EIP_MSR */
f01044f5:	b8 de 51 10 f0       	mov    $0xf01051de,%eax
f01044fa:	b1 76                	mov    $0x76,%cl
f01044fc:	0f 30                	wrmsr  
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01044fe:	c1 e3 03             	shl    $0x3,%ebx
f0104501:	0f 00 db             	ltr    %bx
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104504:	b8 74 23 12 f0       	mov    $0xf0122374,%eax
f0104509:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0 + i * 8);
	// Load the IDT
	lidt(&idt_pd);
}
f010450c:	83 c4 1c             	add    $0x1c,%esp
f010450f:	5b                   	pop    %ebx
f0104510:	5e                   	pop    %esi
f0104511:	5f                   	pop    %edi
f0104512:	5d                   	pop    %ebp
f0104513:	c3                   	ret    

f0104514 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104514:	55                   	push   %ebp
f0104515:	89 e5                	mov    %esp,%ebp
f0104517:	53                   	push   %ebx
f0104518:	83 ec 14             	sub    $0x14,%esp
f010451b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010451e:	8b 03                	mov    (%ebx),%eax
f0104520:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104524:	c7 04 24 ff 87 10 f0 	movl   $0xf01087ff,(%esp)
f010452b:	e8 cb fe ff ff       	call   f01043fb <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104530:	8b 43 04             	mov    0x4(%ebx),%eax
f0104533:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104537:	c7 04 24 0e 88 10 f0 	movl   $0xf010880e,(%esp)
f010453e:	e8 b8 fe ff ff       	call   f01043fb <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104543:	8b 43 08             	mov    0x8(%ebx),%eax
f0104546:	89 44 24 04          	mov    %eax,0x4(%esp)
f010454a:	c7 04 24 1d 88 10 f0 	movl   $0xf010881d,(%esp)
f0104551:	e8 a5 fe ff ff       	call   f01043fb <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0104556:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104559:	89 44 24 04          	mov    %eax,0x4(%esp)
f010455d:	c7 04 24 2c 88 10 f0 	movl   $0xf010882c,(%esp)
f0104564:	e8 92 fe ff ff       	call   f01043fb <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104569:	8b 43 10             	mov    0x10(%ebx),%eax
f010456c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104570:	c7 04 24 3b 88 10 f0 	movl   $0xf010883b,(%esp)
f0104577:	e8 7f fe ff ff       	call   f01043fb <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010457c:	8b 43 14             	mov    0x14(%ebx),%eax
f010457f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104583:	c7 04 24 4a 88 10 f0 	movl   $0xf010884a,(%esp)
f010458a:	e8 6c fe ff ff       	call   f01043fb <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010458f:	8b 43 18             	mov    0x18(%ebx),%eax
f0104592:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104596:	c7 04 24 59 88 10 f0 	movl   $0xf0108859,(%esp)
f010459d:	e8 59 fe ff ff       	call   f01043fb <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01045a2:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01045a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045a9:	c7 04 24 68 88 10 f0 	movl   $0xf0108868,(%esp)
f01045b0:	e8 46 fe ff ff       	call   f01043fb <cprintf>
}
f01045b5:	83 c4 14             	add    $0x14,%esp
f01045b8:	5b                   	pop    %ebx
f01045b9:	5d                   	pop    %ebp
f01045ba:	c3                   	ret    

f01045bb <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01045bb:	55                   	push   %ebp
f01045bc:	89 e5                	mov    %esp,%ebp
f01045be:	56                   	push   %esi
f01045bf:	53                   	push   %ebx
f01045c0:	83 ec 10             	sub    $0x10,%esp
f01045c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01045c6:	e8 97 29 00 00       	call   f0106f62 <cpunum>
f01045cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01045cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045d3:	c7 04 24 77 88 10 f0 	movl   $0xf0108877,(%esp)
f01045da:	e8 1c fe ff ff       	call   f01043fb <cprintf>
	print_regs(&tf->tf_regs);
f01045df:	89 1c 24             	mov    %ebx,(%esp)
f01045e2:	e8 2d ff ff ff       	call   f0104514 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01045e7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01045eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ef:	c7 04 24 95 88 10 f0 	movl   $0xf0108895,(%esp)
f01045f6:	e8 00 fe ff ff       	call   f01043fb <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01045fb:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01045ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104603:	c7 04 24 a8 88 10 f0 	movl   $0xf01088a8,(%esp)
f010460a:	e8 ec fd ff ff       	call   f01043fb <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010460f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104612:	83 f8 13             	cmp    $0x13,%eax
f0104615:	77 09                	ja     f0104620 <print_trapframe+0x65>
		return excnames[trapno];
f0104617:	8b 14 85 e0 8b 10 f0 	mov    -0xfef7420(,%eax,4),%edx
f010461e:	eb 1d                	jmp    f010463d <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
f0104620:	ba bb 88 10 f0       	mov    $0xf01088bb,%edx
f0104625:	83 f8 30             	cmp    $0x30,%eax
f0104628:	74 13                	je     f010463d <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010462a:	8d 50 e0             	lea    -0x20(%eax),%edx
f010462d:	83 fa 10             	cmp    $0x10,%edx
f0104630:	ba c7 88 10 f0       	mov    $0xf01088c7,%edx
f0104635:	b9 d6 88 10 f0       	mov    $0xf01088d6,%ecx
f010463a:	0f 42 d1             	cmovb  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010463d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104641:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104645:	c7 04 24 e9 88 10 f0 	movl   $0xf01088e9,(%esp)
f010464c:	e8 aa fd ff ff       	call   f01043fb <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104651:	3b 1d 60 ca 1d f0    	cmp    0xf01dca60,%ebx
f0104657:	75 19                	jne    f0104672 <print_trapframe+0xb7>
f0104659:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010465d:	75 13                	jne    f0104672 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010465f:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104662:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104666:	c7 04 24 fb 88 10 f0 	movl   $0xf01088fb,(%esp)
f010466d:	e8 89 fd ff ff       	call   f01043fb <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104672:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104675:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104679:	c7 04 24 0a 89 10 f0 	movl   $0xf010890a,(%esp)
f0104680:	e8 76 fd ff ff       	call   f01043fb <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104685:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104689:	75 4a                	jne    f01046d5 <print_trapframe+0x11a>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010468b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010468e:	a8 01                	test   $0x1,%al
f0104690:	ba 18 89 10 f0       	mov    $0xf0108918,%edx
f0104695:	b9 24 89 10 f0       	mov    $0xf0108924,%ecx
f010469a:	0f 44 ca             	cmove  %edx,%ecx
f010469d:	a8 02                	test   $0x2,%al
f010469f:	ba 2f 89 10 f0       	mov    $0xf010892f,%edx
f01046a4:	be 34 89 10 f0       	mov    $0xf0108934,%esi
f01046a9:	0f 45 d6             	cmovne %esi,%edx
f01046ac:	a8 04                	test   $0x4,%al
f01046ae:	b8 2c 8a 10 f0       	mov    $0xf0108a2c,%eax
f01046b3:	be 3a 89 10 f0       	mov    $0xf010893a,%esi
f01046b8:	0f 45 c6             	cmovne %esi,%eax
f01046bb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01046bf:	89 54 24 08          	mov    %edx,0x8(%esp)
f01046c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046c7:	c7 04 24 3f 89 10 f0 	movl   $0xf010893f,(%esp)
f01046ce:	e8 28 fd ff ff       	call   f01043fb <cprintf>
f01046d3:	eb 0c                	jmp    f01046e1 <print_trapframe+0x126>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01046d5:	c7 04 24 b7 89 10 f0 	movl   $0xf01089b7,(%esp)
f01046dc:	e8 1a fd ff ff       	call   f01043fb <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01046e1:	8b 43 30             	mov    0x30(%ebx),%eax
f01046e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046e8:	c7 04 24 4e 89 10 f0 	movl   $0xf010894e,(%esp)
f01046ef:	e8 07 fd ff ff       	call   f01043fb <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01046f4:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01046f8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046fc:	c7 04 24 5d 89 10 f0 	movl   $0xf010895d,(%esp)
f0104703:	e8 f3 fc ff ff       	call   f01043fb <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104708:	8b 43 38             	mov    0x38(%ebx),%eax
f010470b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010470f:	c7 04 24 70 89 10 f0 	movl   $0xf0108970,(%esp)
f0104716:	e8 e0 fc ff ff       	call   f01043fb <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010471b:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010471f:	74 27                	je     f0104748 <print_trapframe+0x18d>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104721:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104724:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104728:	c7 04 24 7f 89 10 f0 	movl   $0xf010897f,(%esp)
f010472f:	e8 c7 fc ff ff       	call   f01043fb <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104734:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104738:	89 44 24 04          	mov    %eax,0x4(%esp)
f010473c:	c7 04 24 8e 89 10 f0 	movl   $0xf010898e,(%esp)
f0104743:	e8 b3 fc ff ff       	call   f01043fb <cprintf>
	}
}
f0104748:	83 c4 10             	add    $0x10,%esp
f010474b:	5b                   	pop    %ebx
f010474c:	5e                   	pop    %esi
f010474d:	5d                   	pop    %ebp
f010474e:	c3                   	ret    

f010474f <trap_init>:
}


void
trap_init(void)
{
f010474f:	55                   	push   %ebp
f0104750:	89 e5                	mov    %esp,%ebp
f0104752:	83 ec 18             	sub    $0x18,%esp
	extern void t_irq13();
	extern void t_irq14();
	extern void t_irq15();
	
	
	SETGATE(idt[T_DIVIDE],0,GD_KT,t_divide,0);
f0104755:	b8 e0 50 10 f0       	mov    $0xf01050e0,%eax
f010475a:	66 a3 60 c2 1d f0    	mov    %ax,0xf01dc260
f0104760:	66 c7 05 62 c2 1d f0 	movw   $0x8,0xf01dc262
f0104767:	08 00 
f0104769:	c6 05 64 c2 1d f0 00 	movb   $0x0,0xf01dc264
f0104770:	c6 05 65 c2 1d f0 8e 	movb   $0x8e,0xf01dc265
f0104777:	c1 e8 10             	shr    $0x10,%eax
f010477a:	66 a3 66 c2 1d f0    	mov    %ax,0xf01dc266
	SETGATE(idt[T_DEBUG],0,GD_KT,t_debug,0);
f0104780:	b8 ea 50 10 f0       	mov    $0xf01050ea,%eax
f0104785:	66 a3 68 c2 1d f0    	mov    %ax,0xf01dc268
f010478b:	66 c7 05 6a c2 1d f0 	movw   $0x8,0xf01dc26a
f0104792:	08 00 
f0104794:	c6 05 6c c2 1d f0 00 	movb   $0x0,0xf01dc26c
f010479b:	c6 05 6d c2 1d f0 8e 	movb   $0x8e,0xf01dc26d
f01047a2:	c1 e8 10             	shr    $0x10,%eax
f01047a5:	66 a3 6e c2 1d f0    	mov    %ax,0xf01dc26e
	SETGATE(idt[T_NMI],0,GD_KT,t_nmi,0);
f01047ab:	b8 f4 50 10 f0       	mov    $0xf01050f4,%eax
f01047b0:	66 a3 70 c2 1d f0    	mov    %ax,0xf01dc270
f01047b6:	66 c7 05 72 c2 1d f0 	movw   $0x8,0xf01dc272
f01047bd:	08 00 
f01047bf:	c6 05 74 c2 1d f0 00 	movb   $0x0,0xf01dc274
f01047c6:	c6 05 75 c2 1d f0 8e 	movb   $0x8e,0xf01dc275
f01047cd:	c1 e8 10             	shr    $0x10,%eax
f01047d0:	66 a3 76 c2 1d f0    	mov    %ax,0xf01dc276
	SETGATE(idt[T_BRKPT],0,GD_KT,t_brkpt,3);  //user set
f01047d6:	b8 fe 50 10 f0       	mov    $0xf01050fe,%eax
f01047db:	66 a3 78 c2 1d f0    	mov    %ax,0xf01dc278
f01047e1:	66 c7 05 7a c2 1d f0 	movw   $0x8,0xf01dc27a
f01047e8:	08 00 
f01047ea:	c6 05 7c c2 1d f0 00 	movb   $0x0,0xf01dc27c
f01047f1:	c6 05 7d c2 1d f0 ee 	movb   $0xee,0xf01dc27d
f01047f8:	c1 e8 10             	shr    $0x10,%eax
f01047fb:	66 a3 7e c2 1d f0    	mov    %ax,0xf01dc27e
	SETGATE(idt[T_BOUND],0,GD_KT,t_bound,0);
f0104801:	b8 12 51 10 f0       	mov    $0xf0105112,%eax
f0104806:	66 a3 88 c2 1d f0    	mov    %ax,0xf01dc288
f010480c:	66 c7 05 8a c2 1d f0 	movw   $0x8,0xf01dc28a
f0104813:	08 00 
f0104815:	c6 05 8c c2 1d f0 00 	movb   $0x0,0xf01dc28c
f010481c:	c6 05 8d c2 1d f0 8e 	movb   $0x8e,0xf01dc28d
f0104823:	c1 e8 10             	shr    $0x10,%eax
f0104826:	66 a3 8e c2 1d f0    	mov    %ax,0xf01dc28e
	SETGATE(idt[T_ILLOP],0,GD_KT,t_illop,0);
f010482c:	b8 1c 51 10 f0       	mov    $0xf010511c,%eax
f0104831:	66 a3 90 c2 1d f0    	mov    %ax,0xf01dc290
f0104837:	66 c7 05 92 c2 1d f0 	movw   $0x8,0xf01dc292
f010483e:	08 00 
f0104840:	c6 05 94 c2 1d f0 00 	movb   $0x0,0xf01dc294
f0104847:	c6 05 95 c2 1d f0 8e 	movb   $0x8e,0xf01dc295
f010484e:	c1 e8 10             	shr    $0x10,%eax
f0104851:	66 a3 96 c2 1d f0    	mov    %ax,0xf01dc296
	SETGATE(idt[T_DEVICE],0,GD_KT,t_device,0);
f0104857:	b8 26 51 10 f0       	mov    $0xf0105126,%eax
f010485c:	66 a3 98 c2 1d f0    	mov    %ax,0xf01dc298
f0104862:	66 c7 05 9a c2 1d f0 	movw   $0x8,0xf01dc29a
f0104869:	08 00 
f010486b:	c6 05 9c c2 1d f0 00 	movb   $0x0,0xf01dc29c
f0104872:	c6 05 9d c2 1d f0 8e 	movb   $0x8e,0xf01dc29d
f0104879:	c1 e8 10             	shr    $0x10,%eax
f010487c:	66 a3 9e c2 1d f0    	mov    %ax,0xf01dc29e
	SETGATE(idt[T_DBLFLT],0,GD_KT,t_dblflt,0);
f0104882:	b8 30 51 10 f0       	mov    $0xf0105130,%eax
f0104887:	66 a3 a0 c2 1d f0    	mov    %ax,0xf01dc2a0
f010488d:	66 c7 05 a2 c2 1d f0 	movw   $0x8,0xf01dc2a2
f0104894:	08 00 
f0104896:	c6 05 a4 c2 1d f0 00 	movb   $0x0,0xf01dc2a4
f010489d:	c6 05 a5 c2 1d f0 8e 	movb   $0x8e,0xf01dc2a5
f01048a4:	c1 e8 10             	shr    $0x10,%eax
f01048a7:	66 a3 a6 c2 1d f0    	mov    %ax,0xf01dc2a6
	SETGATE(idt[T_TSS],0,GD_KT,t_tss,0);
f01048ad:	b8 38 51 10 f0       	mov    $0xf0105138,%eax
f01048b2:	66 a3 b0 c2 1d f0    	mov    %ax,0xf01dc2b0
f01048b8:	66 c7 05 b2 c2 1d f0 	movw   $0x8,0xf01dc2b2
f01048bf:	08 00 
f01048c1:	c6 05 b4 c2 1d f0 00 	movb   $0x0,0xf01dc2b4
f01048c8:	c6 05 b5 c2 1d f0 8e 	movb   $0x8e,0xf01dc2b5
f01048cf:	c1 e8 10             	shr    $0x10,%eax
f01048d2:	66 a3 b6 c2 1d f0    	mov    %ax,0xf01dc2b6
	SETGATE(idt[T_SEGNP],0,GD_KT,t_segnp,0);
f01048d8:	b8 40 51 10 f0       	mov    $0xf0105140,%eax
f01048dd:	66 a3 b8 c2 1d f0    	mov    %ax,0xf01dc2b8
f01048e3:	66 c7 05 ba c2 1d f0 	movw   $0x8,0xf01dc2ba
f01048ea:	08 00 
f01048ec:	c6 05 bc c2 1d f0 00 	movb   $0x0,0xf01dc2bc
f01048f3:	c6 05 bd c2 1d f0 8e 	movb   $0x8e,0xf01dc2bd
f01048fa:	c1 e8 10             	shr    $0x10,%eax
f01048fd:	66 a3 be c2 1d f0    	mov    %ax,0xf01dc2be
	SETGATE(idt[T_STACK],0,GD_KT,t_stack,0);
f0104903:	b8 48 51 10 f0       	mov    $0xf0105148,%eax
f0104908:	66 a3 c0 c2 1d f0    	mov    %ax,0xf01dc2c0
f010490e:	66 c7 05 c2 c2 1d f0 	movw   $0x8,0xf01dc2c2
f0104915:	08 00 
f0104917:	c6 05 c4 c2 1d f0 00 	movb   $0x0,0xf01dc2c4
f010491e:	c6 05 c5 c2 1d f0 8e 	movb   $0x8e,0xf01dc2c5
f0104925:	c1 e8 10             	shr    $0x10,%eax
f0104928:	66 a3 c6 c2 1d f0    	mov    %ax,0xf01dc2c6
	SETGATE(idt[T_GPFLT],0,GD_KT,t_gpflt,0);
f010492e:	b8 50 51 10 f0       	mov    $0xf0105150,%eax
f0104933:	66 a3 c8 c2 1d f0    	mov    %ax,0xf01dc2c8
f0104939:	66 c7 05 ca c2 1d f0 	movw   $0x8,0xf01dc2ca
f0104940:	08 00 
f0104942:	c6 05 cc c2 1d f0 00 	movb   $0x0,0xf01dc2cc
f0104949:	c6 05 cd c2 1d f0 8e 	movb   $0x8e,0xf01dc2cd
f0104950:	c1 e8 10             	shr    $0x10,%eax
f0104953:	66 a3 ce c2 1d f0    	mov    %ax,0xf01dc2ce
	SETGATE(idt[T_PGFLT],0,GD_KT,t_pgflt,0);
f0104959:	b8 58 51 10 f0       	mov    $0xf0105158,%eax
f010495e:	66 a3 d0 c2 1d f0    	mov    %ax,0xf01dc2d0
f0104964:	66 c7 05 d2 c2 1d f0 	movw   $0x8,0xf01dc2d2
f010496b:	08 00 
f010496d:	c6 05 d4 c2 1d f0 00 	movb   $0x0,0xf01dc2d4
f0104974:	c6 05 d5 c2 1d f0 8e 	movb   $0x8e,0xf01dc2d5
f010497b:	c1 e8 10             	shr    $0x10,%eax
f010497e:	66 a3 d6 c2 1d f0    	mov    %ax,0xf01dc2d6
	SETGATE(idt[T_FPERR],0,GD_KT,t_fperr,0);
f0104984:	b8 60 51 10 f0       	mov    $0xf0105160,%eax
f0104989:	66 a3 e0 c2 1d f0    	mov    %ax,0xf01dc2e0
f010498f:	66 c7 05 e2 c2 1d f0 	movw   $0x8,0xf01dc2e2
f0104996:	08 00 
f0104998:	c6 05 e4 c2 1d f0 00 	movb   $0x0,0xf01dc2e4
f010499f:	c6 05 e5 c2 1d f0 8e 	movb   $0x8e,0xf01dc2e5
f01049a6:	c1 e8 10             	shr    $0x10,%eax
f01049a9:	66 a3 e6 c2 1d f0    	mov    %ax,0xf01dc2e6
	SETGATE(idt[T_ALIGN],0,GD_KT,t_align,0);
f01049af:	b8 6a 51 10 f0       	mov    $0xf010516a,%eax
f01049b4:	66 a3 e8 c2 1d f0    	mov    %ax,0xf01dc2e8
f01049ba:	66 c7 05 ea c2 1d f0 	movw   $0x8,0xf01dc2ea
f01049c1:	08 00 
f01049c3:	c6 05 ec c2 1d f0 00 	movb   $0x0,0xf01dc2ec
f01049ca:	c6 05 ed c2 1d f0 8e 	movb   $0x8e,0xf01dc2ed
f01049d1:	c1 e8 10             	shr    $0x10,%eax
f01049d4:	66 a3 ee c2 1d f0    	mov    %ax,0xf01dc2ee
	SETGATE(idt[T_MCHK],0,GD_KT,t_mchk,0);
f01049da:	b8 72 51 10 f0       	mov    $0xf0105172,%eax
f01049df:	66 a3 f0 c2 1d f0    	mov    %ax,0xf01dc2f0
f01049e5:	66 c7 05 f2 c2 1d f0 	movw   $0x8,0xf01dc2f2
f01049ec:	08 00 
f01049ee:	c6 05 f4 c2 1d f0 00 	movb   $0x0,0xf01dc2f4
f01049f5:	c6 05 f5 c2 1d f0 8e 	movb   $0x8e,0xf01dc2f5
f01049fc:	c1 e8 10             	shr    $0x10,%eax
f01049ff:	66 a3 f6 c2 1d f0    	mov    %ax,0xf01dc2f6
	SETGATE(idt[T_SIMDERR],0,GD_KT,t_simderr,0);
f0104a05:	b8 78 51 10 f0       	mov    $0xf0105178,%eax
f0104a0a:	66 a3 f8 c2 1d f0    	mov    %ax,0xf01dc2f8
f0104a10:	66 c7 05 fa c2 1d f0 	movw   $0x8,0xf01dc2fa
f0104a17:	08 00 
f0104a19:	c6 05 fc c2 1d f0 00 	movb   $0x0,0xf01dc2fc
f0104a20:	c6 05 fd c2 1d f0 8e 	movb   $0x8e,0xf01dc2fd
f0104a27:	c1 e8 10             	shr    $0x10,%eax
f0104a2a:	66 a3 fe c2 1d f0    	mov    %ax,0xf01dc2fe
	
	//SETGATE(idt[T_SYSCALL],0,GD_KT,sysenter_handler,3); if sysenter interrupt?
	
	//set IRQ GATE
	SETGATE(idt[IRQ_OFFSET + 0],0,GD_KT,t_irq0,0);
f0104a30:	b8 7e 51 10 f0       	mov    $0xf010517e,%eax
f0104a35:	66 a3 60 c3 1d f0    	mov    %ax,0xf01dc360
f0104a3b:	66 c7 05 62 c3 1d f0 	movw   $0x8,0xf01dc362
f0104a42:	08 00 
f0104a44:	c6 05 64 c3 1d f0 00 	movb   $0x0,0xf01dc364
f0104a4b:	c6 05 65 c3 1d f0 8e 	movb   $0x8e,0xf01dc365
f0104a52:	c1 e8 10             	shr    $0x10,%eax
f0104a55:	66 a3 66 c3 1d f0    	mov    %ax,0xf01dc366
	SETGATE(idt[IRQ_OFFSET + 1],0,GD_KT,t_irq1,0);
f0104a5b:	b8 84 51 10 f0       	mov    $0xf0105184,%eax
f0104a60:	66 a3 68 c3 1d f0    	mov    %ax,0xf01dc368
f0104a66:	66 c7 05 6a c3 1d f0 	movw   $0x8,0xf01dc36a
f0104a6d:	08 00 
f0104a6f:	c6 05 6c c3 1d f0 00 	movb   $0x0,0xf01dc36c
f0104a76:	c6 05 6d c3 1d f0 8e 	movb   $0x8e,0xf01dc36d
f0104a7d:	c1 e8 10             	shr    $0x10,%eax
f0104a80:	66 a3 6e c3 1d f0    	mov    %ax,0xf01dc36e
	SETGATE(idt[IRQ_OFFSET + 2],0,GD_KT,t_irq2,0);
f0104a86:	b8 8a 51 10 f0       	mov    $0xf010518a,%eax
f0104a8b:	66 a3 70 c3 1d f0    	mov    %ax,0xf01dc370
f0104a91:	66 c7 05 72 c3 1d f0 	movw   $0x8,0xf01dc372
f0104a98:	08 00 
f0104a9a:	c6 05 74 c3 1d f0 00 	movb   $0x0,0xf01dc374
f0104aa1:	c6 05 75 c3 1d f0 8e 	movb   $0x8e,0xf01dc375
f0104aa8:	c1 e8 10             	shr    $0x10,%eax
f0104aab:	66 a3 76 c3 1d f0    	mov    %ax,0xf01dc376
	SETGATE(idt[IRQ_OFFSET + 3],0,GD_KT,t_irq3,0);
f0104ab1:	b8 90 51 10 f0       	mov    $0xf0105190,%eax
f0104ab6:	66 a3 78 c3 1d f0    	mov    %ax,0xf01dc378
f0104abc:	66 c7 05 7a c3 1d f0 	movw   $0x8,0xf01dc37a
f0104ac3:	08 00 
f0104ac5:	c6 05 7c c3 1d f0 00 	movb   $0x0,0xf01dc37c
f0104acc:	c6 05 7d c3 1d f0 8e 	movb   $0x8e,0xf01dc37d
f0104ad3:	c1 e8 10             	shr    $0x10,%eax
f0104ad6:	66 a3 7e c3 1d f0    	mov    %ax,0xf01dc37e
	SETGATE(idt[IRQ_OFFSET + 4],0,GD_KT,t_irq4,0);
f0104adc:	b8 96 51 10 f0       	mov    $0xf0105196,%eax
f0104ae1:	66 a3 80 c3 1d f0    	mov    %ax,0xf01dc380
f0104ae7:	66 c7 05 82 c3 1d f0 	movw   $0x8,0xf01dc382
f0104aee:	08 00 
f0104af0:	c6 05 84 c3 1d f0 00 	movb   $0x0,0xf01dc384
f0104af7:	c6 05 85 c3 1d f0 8e 	movb   $0x8e,0xf01dc385
f0104afe:	c1 e8 10             	shr    $0x10,%eax
f0104b01:	66 a3 86 c3 1d f0    	mov    %ax,0xf01dc386
	SETGATE(idt[IRQ_OFFSET + 5],0,GD_KT,t_irq5,0);
f0104b07:	b8 9c 51 10 f0       	mov    $0xf010519c,%eax
f0104b0c:	66 a3 88 c3 1d f0    	mov    %ax,0xf01dc388
f0104b12:	66 c7 05 8a c3 1d f0 	movw   $0x8,0xf01dc38a
f0104b19:	08 00 
f0104b1b:	c6 05 8c c3 1d f0 00 	movb   $0x0,0xf01dc38c
f0104b22:	c6 05 8d c3 1d f0 8e 	movb   $0x8e,0xf01dc38d
f0104b29:	c1 e8 10             	shr    $0x10,%eax
f0104b2c:	66 a3 8e c3 1d f0    	mov    %ax,0xf01dc38e
	SETGATE(idt[IRQ_OFFSET + 6],0,GD_KT,t_irq6,0);
f0104b32:	b8 a2 51 10 f0       	mov    $0xf01051a2,%eax
f0104b37:	66 a3 90 c3 1d f0    	mov    %ax,0xf01dc390
f0104b3d:	66 c7 05 92 c3 1d f0 	movw   $0x8,0xf01dc392
f0104b44:	08 00 
f0104b46:	c6 05 94 c3 1d f0 00 	movb   $0x0,0xf01dc394
f0104b4d:	c6 05 95 c3 1d f0 8e 	movb   $0x8e,0xf01dc395
f0104b54:	c1 e8 10             	shr    $0x10,%eax
f0104b57:	66 a3 96 c3 1d f0    	mov    %ax,0xf01dc396
	SETGATE(idt[IRQ_OFFSET + 7],0,GD_KT,t_irq7,0);
f0104b5d:	b8 a8 51 10 f0       	mov    $0xf01051a8,%eax
f0104b62:	66 a3 98 c3 1d f0    	mov    %ax,0xf01dc398
f0104b68:	66 c7 05 9a c3 1d f0 	movw   $0x8,0xf01dc39a
f0104b6f:	08 00 
f0104b71:	c6 05 9c c3 1d f0 00 	movb   $0x0,0xf01dc39c
f0104b78:	c6 05 9d c3 1d f0 8e 	movb   $0x8e,0xf01dc39d
f0104b7f:	c1 e8 10             	shr    $0x10,%eax
f0104b82:	66 a3 9e c3 1d f0    	mov    %ax,0xf01dc39e
	SETGATE(idt[IRQ_OFFSET + 8],0,GD_KT,t_irq8,0);
f0104b88:	b8 ae 51 10 f0       	mov    $0xf01051ae,%eax
f0104b8d:	66 a3 a0 c3 1d f0    	mov    %ax,0xf01dc3a0
f0104b93:	66 c7 05 a2 c3 1d f0 	movw   $0x8,0xf01dc3a2
f0104b9a:	08 00 
f0104b9c:	c6 05 a4 c3 1d f0 00 	movb   $0x0,0xf01dc3a4
f0104ba3:	c6 05 a5 c3 1d f0 8e 	movb   $0x8e,0xf01dc3a5
f0104baa:	c1 e8 10             	shr    $0x10,%eax
f0104bad:	66 a3 a6 c3 1d f0    	mov    %ax,0xf01dc3a6
	SETGATE(idt[IRQ_OFFSET + 9],0,GD_KT,t_irq9,0);
f0104bb3:	b8 b4 51 10 f0       	mov    $0xf01051b4,%eax
f0104bb8:	66 a3 a8 c3 1d f0    	mov    %ax,0xf01dc3a8
f0104bbe:	66 c7 05 aa c3 1d f0 	movw   $0x8,0xf01dc3aa
f0104bc5:	08 00 
f0104bc7:	c6 05 ac c3 1d f0 00 	movb   $0x0,0xf01dc3ac
f0104bce:	c6 05 ad c3 1d f0 8e 	movb   $0x8e,0xf01dc3ad
f0104bd5:	c1 e8 10             	shr    $0x10,%eax
f0104bd8:	66 a3 ae c3 1d f0    	mov    %ax,0xf01dc3ae
	SETGATE(idt[IRQ_OFFSET + 10],0,GD_KT,t_irq10,0);
f0104bde:	b8 ba 51 10 f0       	mov    $0xf01051ba,%eax
f0104be3:	66 a3 b0 c3 1d f0    	mov    %ax,0xf01dc3b0
f0104be9:	66 c7 05 b2 c3 1d f0 	movw   $0x8,0xf01dc3b2
f0104bf0:	08 00 
f0104bf2:	c6 05 b4 c3 1d f0 00 	movb   $0x0,0xf01dc3b4
f0104bf9:	c6 05 b5 c3 1d f0 8e 	movb   $0x8e,0xf01dc3b5
f0104c00:	c1 e8 10             	shr    $0x10,%eax
f0104c03:	66 a3 b6 c3 1d f0    	mov    %ax,0xf01dc3b6
	SETGATE(idt[IRQ_OFFSET + 11],0,GD_KT,t_irq11,0);
f0104c09:	b8 c0 51 10 f0       	mov    $0xf01051c0,%eax
f0104c0e:	66 a3 b8 c3 1d f0    	mov    %ax,0xf01dc3b8
f0104c14:	66 c7 05 ba c3 1d f0 	movw   $0x8,0xf01dc3ba
f0104c1b:	08 00 
f0104c1d:	c6 05 bc c3 1d f0 00 	movb   $0x0,0xf01dc3bc
f0104c24:	c6 05 bd c3 1d f0 8e 	movb   $0x8e,0xf01dc3bd
f0104c2b:	c1 e8 10             	shr    $0x10,%eax
f0104c2e:	66 a3 be c3 1d f0    	mov    %ax,0xf01dc3be
	SETGATE(idt[IRQ_OFFSET + 12],0,GD_KT,t_irq12,0);
f0104c34:	b8 c6 51 10 f0       	mov    $0xf01051c6,%eax
f0104c39:	66 a3 c0 c3 1d f0    	mov    %ax,0xf01dc3c0
f0104c3f:	66 c7 05 c2 c3 1d f0 	movw   $0x8,0xf01dc3c2
f0104c46:	08 00 
f0104c48:	c6 05 c4 c3 1d f0 00 	movb   $0x0,0xf01dc3c4
f0104c4f:	c6 05 c5 c3 1d f0 8e 	movb   $0x8e,0xf01dc3c5
f0104c56:	c1 e8 10             	shr    $0x10,%eax
f0104c59:	66 a3 c6 c3 1d f0    	mov    %ax,0xf01dc3c6
	SETGATE(idt[IRQ_OFFSET + 13],0,GD_KT,t_irq13,0);
f0104c5f:	b8 cc 51 10 f0       	mov    $0xf01051cc,%eax
f0104c64:	66 a3 c8 c3 1d f0    	mov    %ax,0xf01dc3c8
f0104c6a:	66 c7 05 ca c3 1d f0 	movw   $0x8,0xf01dc3ca
f0104c71:	08 00 
f0104c73:	c6 05 cc c3 1d f0 00 	movb   $0x0,0xf01dc3cc
f0104c7a:	c6 05 cd c3 1d f0 8e 	movb   $0x8e,0xf01dc3cd
f0104c81:	c1 e8 10             	shr    $0x10,%eax
f0104c84:	66 a3 ce c3 1d f0    	mov    %ax,0xf01dc3ce
	SETGATE(idt[IRQ_OFFSET + 14],0,GD_KT,t_irq14,0);
f0104c8a:	b8 d2 51 10 f0       	mov    $0xf01051d2,%eax
f0104c8f:	66 a3 d0 c3 1d f0    	mov    %ax,0xf01dc3d0
f0104c95:	66 c7 05 d2 c3 1d f0 	movw   $0x8,0xf01dc3d2
f0104c9c:	08 00 
f0104c9e:	c6 05 d4 c3 1d f0 00 	movb   $0x0,0xf01dc3d4
f0104ca5:	c6 05 d5 c3 1d f0 8e 	movb   $0x8e,0xf01dc3d5
f0104cac:	c1 e8 10             	shr    $0x10,%eax
f0104caf:	66 a3 d6 c3 1d f0    	mov    %ax,0xf01dc3d6
	SETGATE(idt[IRQ_OFFSET + 15],0,GD_KT,t_irq15,0);
f0104cb5:	b8 d8 51 10 f0       	mov    $0xf01051d8,%eax
f0104cba:	66 a3 d8 c3 1d f0    	mov    %ax,0xf01dc3d8
f0104cc0:	66 c7 05 da c3 1d f0 	movw   $0x8,0xf01dc3da
f0104cc7:	08 00 
f0104cc9:	c6 05 dc c3 1d f0 00 	movb   $0x0,0xf01dc3dc
f0104cd0:	c6 05 dd c3 1d f0 8e 	movb   $0x8e,0xf01dc3dd
f0104cd7:	c1 e8 10             	shr    $0x10,%eax
f0104cda:	66 a3 de c3 1d f0    	mov    %ax,0xf01dc3de

	wrmsr(0x174, GD_KT, 0);				/* SYSENTER_CS_MSR */
f0104ce0:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ce5:	b8 08 00 00 00       	mov    $0x8,%eax
f0104cea:	b9 74 01 00 00       	mov    $0x174,%ecx
f0104cef:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP, 0);		/* SYSENTER_ESP_MSR */
f0104cf1:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0104cf6:	b1 75                	mov    $0x75,%cl
f0104cf8:	0f 30                	wrmsr  
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);	/* SYSENTER_EIP_MSR */
f0104cfa:	b8 de 51 10 f0       	mov    $0xf01051de,%eax
f0104cff:	b1 76                	mov    $0x76,%cl
f0104d01:	0f 30                	wrmsr  
	
	cprintf("have set!!!!!!!!!!!!!!\n");
f0104d03:	c7 04 24 a1 89 10 f0 	movl   $0xf01089a1,(%esp)
f0104d0a:	e8 ec f6 ff ff       	call   f01043fb <cprintf>
	// Per-CPU setup 
	trap_init_percpu();
f0104d0f:	e8 2c f7 ff ff       	call   f0104440 <trap_init_percpu>
}
f0104d14:	c9                   	leave  
f0104d15:	c3                   	ret    

f0104d16 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104d16:	55                   	push   %ebp
f0104d17:	89 e5                	mov    %esp,%ebp
f0104d19:	83 ec 48             	sub    $0x48,%esp
f0104d1c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104d1f:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104d22:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104d25:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d28:	0f 20 d3             	mov    %cr2,%ebx
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0104d2b:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104d2f:	75 1c                	jne    f0104d4d <page_fault_handler+0x37>
		panic ("kernel-mode page faults");
f0104d31:	c7 44 24 08 b9 89 10 	movl   $0xf01089b9,0x8(%esp)
f0104d38:	f0 
f0104d39:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0104d40:	00 
f0104d41:	c7 04 24 d1 89 10 f0 	movl   $0xf01089d1,(%esp)
f0104d48:	e8 38 b3 ff ff       	call   f0100085 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall != NULL)
f0104d4d:	e8 10 22 00 00       	call   f0106f62 <cpunum>
f0104d52:	6b c0 74             	imul   $0x74,%eax,%eax
f0104d55:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0104d5b:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104d5f:	0f 84 49 01 00 00    	je     f0104eae <page_fault_handler+0x198>
	{
		struct UTrapframe* utf;
		if(	UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp < UXSTACKTOP)
f0104d65:	8b 46 3c             	mov    0x3c(%esi),%eax
f0104d68:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104d6e:	83 e8 38             	sub    $0x38,%eax
f0104d71:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0104d77:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104d7c:	0f 42 d0             	cmovb  %eax,%edx
f0104d7f:	89 55 e4             	mov    %edx,-0x1c(%ebp)

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104d82:	9c                   	pushf  
f0104d83:	5f                   	pop    %edi
		{
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof (struct UTrapframe) - 4);
		}
		else
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof (struct UTrapframe));
		cprintf("%s:page_fault_handler[%d]: [%x] with IF %x[%x]\n", __FILE__, __LINE__, curenv->env_id, tf->tf_eflags & FL_IF, read_eflags() & FL_IF);
f0104d84:	8b 46 38             	mov    0x38(%esi),%eax
f0104d87:	25 00 02 00 00       	and    $0x200,%eax
f0104d8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104d8f:	e8 ce 21 00 00       	call   f0106f62 <cpunum>
f0104d94:	81 e7 00 02 00 00    	and    $0x200,%edi
f0104d9a:	89 7c 24 14          	mov    %edi,0x14(%esp)
f0104d9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104da1:	89 54 24 10          	mov    %edx,0x10(%esp)
f0104da5:	bf 20 d0 1d f0       	mov    $0xf01dd020,%edi
f0104daa:	6b c0 74             	imul   $0x74,%eax,%eax
f0104dad:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0104db1:	8b 40 48             	mov    0x48(%eax),%eax
f0104db4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104db8:	c7 44 24 08 a2 01 00 	movl   $0x1a2,0x8(%esp)
f0104dbf:	00 
f0104dc0:	c7 44 24 04 d1 89 10 	movl   $0xf01089d1,0x4(%esp)
f0104dc7:	f0 
f0104dc8:	c7 04 24 78 8b 10 f0 	movl   $0xf0108b78,(%esp)
f0104dcf:	e8 27 f6 ff ff       	call   f01043fb <cprintf>
		user_mem_assert (curenv,(void*)utf,sizeof (struct UTrapframe),PTE_U|PTE_W);
f0104dd4:	e8 89 21 00 00       	call   f0106f62 <cpunum>
f0104dd9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104de0:	00 
f0104de1:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104de8:	00 
f0104de9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104dec:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104df0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df3:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0104df7:	89 04 24             	mov    %eax,(%esp)
f0104dfa:	e8 d3 ca ff ff       	call   f01018d2 <user_mem_assert>
		
		utf->utf_eflags = tf->tf_eflags;
f0104dff:	8b 46 38             	mov    0x38(%esi),%eax
f0104e02:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e05:	89 42 2c             	mov    %eax,0x2c(%edx)
		/* tf->tf_eflags &= ~FL_IF; */
		utf->utf_eip = tf->tf_eip;
f0104e08:	8b 46 30             	mov    0x30(%esi),%eax
f0104e0b:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_err = tf->tf_err;
f0104e0e:	8b 46 2c             	mov    0x2c(%esi),%eax
f0104e11:	89 42 04             	mov    %eax,0x4(%edx)
		utf->utf_esp = tf->tf_esp;
f0104e14:	8b 46 3c             	mov    0x3c(%esi),%eax
f0104e17:	89 42 30             	mov    %eax,0x30(%edx)
		utf->utf_fault_va = fault_va;
f0104e1a:	89 1a                	mov    %ebx,(%edx)
		utf->utf_regs = tf->tf_regs;
f0104e1c:	89 d7                	mov    %edx,%edi
f0104e1e:	83 c7 08             	add    $0x8,%edi
f0104e21:	b8 20 00 00 00       	mov    $0x20,%eax
f0104e26:	f7 c7 01 00 00 00    	test   $0x1,%edi
f0104e2c:	74 04                	je     f0104e32 <page_fault_handler+0x11c>
f0104e2e:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104e2f:	83 e8 01             	sub    $0x1,%eax
f0104e32:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104e38:	74 05                	je     f0104e3f <page_fault_handler+0x129>
f0104e3a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104e3c:	83 e8 02             	sub    $0x2,%eax
f0104e3f:	89 c1                	mov    %eax,%ecx
f0104e41:	c1 e9 02             	shr    $0x2,%ecx
f0104e44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104e46:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e4b:	a8 02                	test   $0x2,%al
f0104e4d:	74 0b                	je     f0104e5a <page_fault_handler+0x144>
f0104e4f:	0f b7 0c 16          	movzwl (%esi,%edx,1),%ecx
f0104e53:	66 89 0c 17          	mov    %cx,(%edi,%edx,1)
f0104e57:	83 c2 02             	add    $0x2,%edx
f0104e5a:	a8 01                	test   $0x1,%al
f0104e5c:	74 07                	je     f0104e65 <page_fault_handler+0x14f>
f0104e5e:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104e62:	88 04 17             	mov    %al,(%edi,%edx,1)
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f0104e65:	e8 f8 20 00 00       	call   f0106f62 <cpunum>
f0104e6a:	bb 20 d0 1d f0       	mov    $0xf01dd020,%ebx
f0104e6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e72:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
f0104e76:	e8 e7 20 00 00       	call   f0106f62 <cpunum>
f0104e7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7e:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104e82:	8b 40 64             	mov    0x64(%eax),%eax
f0104e85:	89 46 30             	mov    %eax,0x30(%esi)
		curenv->env_tf.tf_esp = (uint32_t) utf;
f0104e88:	e8 d5 20 00 00       	call   f0106f62 <cpunum>
f0104e8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e90:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104e94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e97:	89 50 3c             	mov    %edx,0x3c(%eax)
		//cprintf("badfsdffffffffffffffffffsdfsdfsadg");
		//print_trapframe(&curenv->env_tf);
		env_run (curenv);
f0104e9a:	e8 c3 20 00 00       	call   f0106f62 <cpunum>
f0104e9f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea2:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104ea6:	89 04 24             	mov    %eax,(%esp)
f0104ea9:	e8 63 ed ff ff       	call   f0103c11 <env_run>
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104eae:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104eb1:	e8 ac 20 00 00       	call   f0106f62 <cpunum>
		//cprintf("badfsdffffffffffffffffffsdfsdfsadg");
		//print_trapframe(&curenv->env_tf);
		env_run (curenv);
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104eb6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104eba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ebe:	bb 20 d0 1d f0       	mov    $0xf01dd020,%ebx
f0104ec3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec6:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104eca:	8b 40 48             	mov    0x48(%eax),%eax
f0104ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed1:	c7 04 24 a8 8b 10 f0 	movl   $0xf0108ba8,(%esp)
f0104ed8:	e8 1e f5 ff ff       	call   f01043fb <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104edd:	89 34 24             	mov    %esi,(%esp)
f0104ee0:	e8 d6 f6 ff ff       	call   f01045bb <print_trapframe>
	env_destroy(curenv);
f0104ee5:	e8 78 20 00 00       	call   f0106f62 <cpunum>
f0104eea:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eed:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104ef1:	89 04 24             	mov    %eax,(%esp)
f0104ef4:	e8 98 ef ff ff       	call   f0103e91 <env_destroy>
}
f0104ef9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104efc:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104eff:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104f02:	89 ec                	mov    %ebp,%esp
f0104f04:	5d                   	pop    %ebp
f0104f05:	c3                   	ret    

f0104f06 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104f06:	55                   	push   %ebp
f0104f07:	89 e5                	mov    %esp,%ebp
f0104f09:	83 ec 28             	sub    $0x28,%esp
f0104f0c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104f0f:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104f12:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104f15:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104f18:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104f19:	83 3d 80 ce 1d f0 00 	cmpl   $0x0,0xf01dce80
f0104f20:	74 01                	je     f0104f23 <trap+0x1d>
		asm volatile("hlt");
f0104f22:	f4                   	hlt    
f0104f23:	9c                   	pushf  
f0104f24:	58                   	pop    %eax
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104f25:	f6 c4 02             	test   $0x2,%ah
f0104f28:	74 24                	je     f0104f4e <trap+0x48>
f0104f2a:	c7 44 24 0c dd 89 10 	movl   $0xf01089dd,0xc(%esp)
f0104f31:	f0 
f0104f32:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0104f39:	f0 
f0104f3a:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
f0104f41:	00 
f0104f42:	c7 04 24 d1 89 10 f0 	movl   $0xf01089d1,(%esp)
f0104f49:	e8 37 b1 ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0104f4e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104f52:	83 e0 03             	and    $0x3,%eax
f0104f55:	83 f8 03             	cmp    $0x3,%eax
f0104f58:	0f 85 a9 00 00 00    	jne    f0105007 <trap+0x101>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		assert(curenv);
f0104f5e:	e8 ff 1f 00 00       	call   f0106f62 <cpunum>
f0104f63:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f66:	83 b8 28 d0 1d f0 00 	cmpl   $0x0,-0xfe22fd8(%eax)
f0104f6d:	75 24                	jne    f0104f93 <trap+0x8d>
f0104f6f:	c7 44 24 0c f6 89 10 	movl   $0xf01089f6,0xc(%esp)
f0104f76:	f0 
f0104f77:	c7 44 24 08 c7 83 10 	movl   $0xf01083c7,0x8(%esp)
f0104f7e:	f0 
f0104f7f:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
f0104f86:	00 
f0104f87:	c7 04 24 d1 89 10 f0 	movl   $0xf01089d1,(%esp)
f0104f8e:	e8 f2 b0 ff ff       	call   f0100085 <_panic>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104f93:	c7 04 24 80 23 12 f0 	movl   $0xf0122380,(%esp)
f0104f9a:	e8 86 23 00 00       	call   f0107325 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104f9f:	e8 be 1f 00 00       	call   f0106f62 <cpunum>
f0104fa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa7:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0104fad:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104fb1:	75 2e                	jne    f0104fe1 <trap+0xdb>
			env_free(curenv);
f0104fb3:	e8 aa 1f 00 00       	call   f0106f62 <cpunum>
f0104fb8:	be 20 d0 1d f0       	mov    $0xf01dd020,%esi
f0104fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fc0:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0104fc4:	89 04 24             	mov    %eax,(%esp)
f0104fc7:	e8 f3 ec ff ff       	call   f0103cbf <env_free>
			curenv = NULL;
f0104fcc:	e8 91 1f 00 00       	call   f0106f62 <cpunum>
f0104fd1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fd4:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f0104fdb:	00 
			sched_yield();
f0104fdc:	e8 2f 02 00 00       	call   f0105210 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104fe1:	e8 7c 1f 00 00       	call   f0106f62 <cpunum>
f0104fe6:	bb 20 d0 1d f0       	mov    $0xf01dd020,%ebx
f0104feb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fee:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104ff2:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ff7:	89 c7                	mov    %eax,%edi
f0104ff9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104ffb:	e8 62 1f 00 00       	call   f0106f62 <cpunum>
f0105000:	6b c0 74             	imul   $0x74,%eax,%eax
f0105003:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0105007:	89 35 60 ca 1d f0    	mov    %esi,0xf01dca60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010500d:	8b 46 28             	mov    0x28(%esi),%eax
f0105010:	83 f8 27             	cmp    $0x27,%eax
f0105013:	75 16                	jne    f010502b <trap+0x125>
		cprintf("Spurious interrupt on irq 7\n");
f0105015:	c7 04 24 fd 89 10 f0 	movl   $0xf01089fd,(%esp)
f010501c:	e8 da f3 ff ff       	call   f01043fb <cprintf>
		print_trapframe(tf);
f0105021:	89 34 24             	mov    %esi,(%esp)
f0105024:	e8 92 f5 ff ff       	call   f01045bb <print_trapframe>
f0105029:	eb 72                	jmp    f010509d <trap+0x197>

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	//print_trapframe(tf);
	if (tf->tf_trapno == T_PGFLT)
f010502b:	83 f8 0e             	cmp    $0xe,%eax
f010502e:	66 90                	xchg   %ax,%ax
f0105030:	75 0b                	jne    f010503d <trap+0x137>
		page_fault_handler(tf);
f0105032:	89 34 24             	mov    %esi,(%esp)
f0105035:	8d 76 00             	lea    0x0(%esi),%esi
f0105038:	e8 d9 fc ff ff       	call   f0104d16 <page_fault_handler>
	//cprintf("int2\n");	
	if (tf->tf_trapno == T_BRKPT)
f010503d:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f0105041:	75 08                	jne    f010504b <trap+0x145>
		monitor(tf);
f0105043:	89 34 24             	mov    %esi,(%esp)
f0105046:	e8 c8 ba ff ff       	call   f0100b13 <monitor>
	
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER )
f010504b:	83 7e 28 20          	cmpl   $0x20,0x28(%esi)
f010504f:	90                   	nop
f0105050:	75 0a                	jne    f010505c <trap+0x156>
	{
		lapic_eoi();
f0105052:	e8 44 20 00 00       	call   f010709b <lapic_eoi>
		sched_yield();
f0105057:	e8 b4 01 00 00       	call   f0105210 <sched_yield>
	}
	
		
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010505c:	89 34 24             	mov    %esi,(%esp)
f010505f:	e8 57 f5 ff ff       	call   f01045bb <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0105064:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0105069:	75 1c                	jne    f0105087 <trap+0x181>
		panic("unhandled trap in kernel");
f010506b:	c7 44 24 08 1a 8a 10 	movl   $0xf0108a1a,0x8(%esp)
f0105072:	f0 
f0105073:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
f010507a:	00 
f010507b:	c7 04 24 d1 89 10 f0 	movl   $0xf01089d1,(%esp)
f0105082:	e8 fe af ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f0105087:	e8 d6 1e 00 00       	call   f0106f62 <cpunum>
f010508c:	6b c0 74             	imul   $0x74,%eax,%eax
f010508f:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105095:	89 04 24             	mov    %eax,(%esp)
f0105098:	e8 f4 ed ff ff       	call   f0103e91 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f010509d:	e8 c0 1e 00 00       	call   f0106f62 <cpunum>
f01050a2:	6b c0 74             	imul   $0x74,%eax,%eax
f01050a5:	83 b8 28 d0 1d f0 00 	cmpl   $0x0,-0xfe22fd8(%eax)
f01050ac:	74 2a                	je     f01050d8 <trap+0x1d2>
f01050ae:	e8 af 1e 00 00       	call   f0106f62 <cpunum>
f01050b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01050b6:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f01050bc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01050c0:	75 16                	jne    f01050d8 <trap+0x1d2>
		env_run(curenv);
f01050c2:	e8 9b 1e 00 00       	call   f0106f62 <cpunum>
f01050c7:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ca:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f01050d0:	89 04 24             	mov    %eax,(%esp)
f01050d3:	e8 39 eb ff ff       	call   f0103c11 <env_run>
	else
		sched_yield();
f01050d8:	e8 33 01 00 00       	call   f0105210 <sched_yield>
f01050dd:	00 00                	add    %al,(%eax)
	...

f01050e0 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide,T_DIVIDE) 
f01050e0:	6a 00                	push   $0x0
f01050e2:	6a 00                	push   $0x0
f01050e4:	e9 0b 01 00 00       	jmp    f01051f4 <_alltraps>
f01050e9:	90                   	nop

f01050ea <t_debug>:
TRAPHANDLER_NOEC(t_debug,T_DEBUG) 
f01050ea:	6a 00                	push   $0x0
f01050ec:	6a 01                	push   $0x1
f01050ee:	e9 01 01 00 00       	jmp    f01051f4 <_alltraps>
f01050f3:	90                   	nop

f01050f4 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi,T_NMI) 
f01050f4:	6a 00                	push   $0x0
f01050f6:	6a 02                	push   $0x2
f01050f8:	e9 f7 00 00 00       	jmp    f01051f4 <_alltraps>
f01050fd:	90                   	nop

f01050fe <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt,T_BRKPT) 
f01050fe:	6a 00                	push   $0x0
f0105100:	6a 03                	push   $0x3
f0105102:	e9 ed 00 00 00       	jmp    f01051f4 <_alltraps>
f0105107:	90                   	nop

f0105108 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow,T_OFLOW) 
f0105108:	6a 00                	push   $0x0
f010510a:	6a 04                	push   $0x4
f010510c:	e9 e3 00 00 00       	jmp    f01051f4 <_alltraps>
f0105111:	90                   	nop

f0105112 <t_bound>:
TRAPHANDLER_NOEC(t_bound,T_BOUND) 
f0105112:	6a 00                	push   $0x0
f0105114:	6a 05                	push   $0x5
f0105116:	e9 d9 00 00 00       	jmp    f01051f4 <_alltraps>
f010511b:	90                   	nop

f010511c <t_illop>:
TRAPHANDLER_NOEC(t_illop,T_ILLOP) 
f010511c:	6a 00                	push   $0x0
f010511e:	6a 06                	push   $0x6
f0105120:	e9 cf 00 00 00       	jmp    f01051f4 <_alltraps>
f0105125:	90                   	nop

f0105126 <t_device>:
TRAPHANDLER_NOEC(t_device,T_DEVICE)
f0105126:	6a 00                	push   $0x0
f0105128:	6a 07                	push   $0x7
f010512a:	e9 c5 00 00 00       	jmp    f01051f4 <_alltraps>
f010512f:	90                   	nop

f0105130 <t_dblflt>:
TRAPHANDLER(t_dblflt,T_DBLFLT)
f0105130:	6a 08                	push   $0x8
f0105132:	e9 bd 00 00 00       	jmp    f01051f4 <_alltraps>
f0105137:	90                   	nop

f0105138 <t_tss>:
TRAPHANDLER(t_tss,T_TSS)
f0105138:	6a 0a                	push   $0xa
f010513a:	e9 b5 00 00 00       	jmp    f01051f4 <_alltraps>
f010513f:	90                   	nop

f0105140 <t_segnp>:
TRAPHANDLER(t_segnp,T_SEGNP)
f0105140:	6a 0b                	push   $0xb
f0105142:	e9 ad 00 00 00       	jmp    f01051f4 <_alltraps>
f0105147:	90                   	nop

f0105148 <t_stack>:
TRAPHANDLER(t_stack,T_STACK)
f0105148:	6a 0c                	push   $0xc
f010514a:	e9 a5 00 00 00       	jmp    f01051f4 <_alltraps>
f010514f:	90                   	nop

f0105150 <t_gpflt>:
TRAPHANDLER(t_gpflt,T_GPFLT)
f0105150:	6a 0d                	push   $0xd
f0105152:	e9 9d 00 00 00       	jmp    f01051f4 <_alltraps>
f0105157:	90                   	nop

f0105158 <t_pgflt>:
TRAPHANDLER(t_pgflt,T_PGFLT)
f0105158:	6a 0e                	push   $0xe
f010515a:	e9 95 00 00 00       	jmp    f01051f4 <_alltraps>
f010515f:	90                   	nop

f0105160 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr,T_FPERR)
f0105160:	6a 00                	push   $0x0
f0105162:	6a 10                	push   $0x10
f0105164:	e9 8b 00 00 00       	jmp    f01051f4 <_alltraps>
f0105169:	90                   	nop

f010516a <t_align>:
TRAPHANDLER(t_align,T_ALIGN )
f010516a:	6a 11                	push   $0x11
f010516c:	e9 83 00 00 00       	jmp    f01051f4 <_alltraps>
f0105171:	90                   	nop

f0105172 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk,T_MCHK)
f0105172:	6a 00                	push   $0x0
f0105174:	6a 12                	push   $0x12
f0105176:	eb 7c                	jmp    f01051f4 <_alltraps>

f0105178 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr,T_SIMDERR)
f0105178:	6a 00                	push   $0x0
f010517a:	6a 13                	push   $0x13
f010517c:	eb 76                	jmp    f01051f4 <_alltraps>

f010517e <t_irq0>:

#for IRQ handler
TRAPHANDLER_NOEC(t_irq0,IRQ_OFFSET + 0)
f010517e:	6a 00                	push   $0x0
f0105180:	6a 20                	push   $0x20
f0105182:	eb 70                	jmp    f01051f4 <_alltraps>

f0105184 <t_irq1>:
TRAPHANDLER_NOEC(t_irq1,IRQ_OFFSET + 1)
f0105184:	6a 00                	push   $0x0
f0105186:	6a 21                	push   $0x21
f0105188:	eb 6a                	jmp    f01051f4 <_alltraps>

f010518a <t_irq2>:
TRAPHANDLER_NOEC(t_irq2,IRQ_OFFSET + 2)
f010518a:	6a 00                	push   $0x0
f010518c:	6a 22                	push   $0x22
f010518e:	eb 64                	jmp    f01051f4 <_alltraps>

f0105190 <t_irq3>:
TRAPHANDLER_NOEC(t_irq3,IRQ_OFFSET + 3)
f0105190:	6a 00                	push   $0x0
f0105192:	6a 23                	push   $0x23
f0105194:	eb 5e                	jmp    f01051f4 <_alltraps>

f0105196 <t_irq4>:
TRAPHANDLER_NOEC(t_irq4,IRQ_OFFSET + 4)
f0105196:	6a 00                	push   $0x0
f0105198:	6a 24                	push   $0x24
f010519a:	eb 58                	jmp    f01051f4 <_alltraps>

f010519c <t_irq5>:
TRAPHANDLER_NOEC(t_irq5,IRQ_OFFSET + 5)
f010519c:	6a 00                	push   $0x0
f010519e:	6a 25                	push   $0x25
f01051a0:	eb 52                	jmp    f01051f4 <_alltraps>

f01051a2 <t_irq6>:
TRAPHANDLER_NOEC(t_irq6,IRQ_OFFSET + 6)
f01051a2:	6a 00                	push   $0x0
f01051a4:	6a 26                	push   $0x26
f01051a6:	eb 4c                	jmp    f01051f4 <_alltraps>

f01051a8 <t_irq7>:
TRAPHANDLER_NOEC(t_irq7,IRQ_OFFSET + 7)
f01051a8:	6a 00                	push   $0x0
f01051aa:	6a 27                	push   $0x27
f01051ac:	eb 46                	jmp    f01051f4 <_alltraps>

f01051ae <t_irq8>:
TRAPHANDLER_NOEC(t_irq8,IRQ_OFFSET + 8)
f01051ae:	6a 00                	push   $0x0
f01051b0:	6a 28                	push   $0x28
f01051b2:	eb 40                	jmp    f01051f4 <_alltraps>

f01051b4 <t_irq9>:
TRAPHANDLER_NOEC(t_irq9,IRQ_OFFSET + 9)
f01051b4:	6a 00                	push   $0x0
f01051b6:	6a 29                	push   $0x29
f01051b8:	eb 3a                	jmp    f01051f4 <_alltraps>

f01051ba <t_irq10>:
TRAPHANDLER_NOEC(t_irq10,IRQ_OFFSET + 10)
f01051ba:	6a 00                	push   $0x0
f01051bc:	6a 2a                	push   $0x2a
f01051be:	eb 34                	jmp    f01051f4 <_alltraps>

f01051c0 <t_irq11>:
TRAPHANDLER_NOEC(t_irq11,IRQ_OFFSET + 11)
f01051c0:	6a 00                	push   $0x0
f01051c2:	6a 2b                	push   $0x2b
f01051c4:	eb 2e                	jmp    f01051f4 <_alltraps>

f01051c6 <t_irq12>:
TRAPHANDLER_NOEC(t_irq12,IRQ_OFFSET + 12)
f01051c6:	6a 00                	push   $0x0
f01051c8:	6a 2c                	push   $0x2c
f01051ca:	eb 28                	jmp    f01051f4 <_alltraps>

f01051cc <t_irq13>:
TRAPHANDLER_NOEC(t_irq13,IRQ_OFFSET + 13)
f01051cc:	6a 00                	push   $0x0
f01051ce:	6a 2d                	push   $0x2d
f01051d0:	eb 22                	jmp    f01051f4 <_alltraps>

f01051d2 <t_irq14>:
TRAPHANDLER_NOEC(t_irq14,IRQ_OFFSET + 14)
f01051d2:	6a 00                	push   $0x0
f01051d4:	6a 2e                	push   $0x2e
f01051d6:	eb 1c                	jmp    f01051f4 <_alltraps>

f01051d8 <t_irq15>:
TRAPHANDLER_NOEC(t_irq15,IRQ_OFFSET + 15)
f01051d8:	6a 00                	push   $0x0
f01051da:	6a 2f                	push   $0x2f
f01051dc:	eb 16                	jmp    f01051f4 <_alltraps>

f01051de <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
 	pushl $0x0 /* parameters to syscall */
f01051de:	6a 00                	push   $0x0
	pushl %edi
f01051e0:	57                   	push   %edi
	pushl %ebx
f01051e1:	53                   	push   %ebx
	pushl %ecx
f01051e2:	51                   	push   %ecx
	pushl %edx
f01051e3:	52                   	push   %edx
	pushl %eax
f01051e4:	50                   	push   %eax
	call syscall
f01051e5:	e8 af 01 00 00       	call   f0105399 <syscall>
	addl $0x18, %esp /* kill all the parameters */
f01051ea:	83 c4 18             	add    $0x18,%esp
	movl %esi, %edx
f01051ed:	89 f2                	mov    %esi,%edx
	movl %ebp, %ecx
f01051ef:	89 e9                	mov    %ebp,%ecx
	sti
f01051f1:	fb                   	sti    
	sysexit
f01051f2:	0f 35                	sysexit 

f01051f4 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:								
	pushw $0x0
f01051f4:	66 6a 00             	pushw  $0x0
	pushw %ds
f01051f7:	66 1e                	pushw  %ds
	pushw $0x0
f01051f9:	66 6a 00             	pushw  $0x0
	pushw %es
f01051fc:	66 06                	pushw  %es
	pushal
f01051fe:	60                   	pusha  
	
	movl $GD_KD,%eax
f01051ff:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax,%ds
f0105204:	8e d8                	mov    %eax,%ds
	movw %ax,%es							
f0105206:	8e c0                	mov    %eax,%es
	
	pushl %esp
f0105208:	54                   	push   %esp
	
	call trap
f0105209:	e8 f8 fc ff ff       	call   f0104f06 <trap>
	...

f0105210 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105210:	55                   	push   %ebp
f0105211:	89 e5                	mov    %esp,%ebp
f0105213:	57                   	push   %edi
f0105214:	56                   	push   %esi
f0105215:	53                   	push   %ebx
f0105216:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	int cnt = 0;
	for (i = curenv?(ENVX(curenv->env_id) + 1):0; cnt < NENV - 1; cnt++, i++) {
f0105219:	e8 44 1d 00 00       	call   f0106f62 <cpunum>
f010521e:	6b d0 74             	imul   $0x74,%eax,%edx
f0105221:	b8 00 00 00 00       	mov    $0x0,%eax
f0105226:	83 ba 28 d0 1d f0 00 	cmpl   $0x0,-0xfe22fd8(%edx)
f010522d:	74 19                	je     f0105248 <sched_yield+0x38>
f010522f:	e8 2e 1d 00 00       	call   f0106f62 <cpunum>
f0105234:	6b c0 74             	imul   $0x74,%eax,%eax
f0105237:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f010523d:	8b 40 48             	mov    0x48(%eax),%eax
f0105240:	25 ff 03 00 00       	and    $0x3ff,%eax
f0105245:	83 c0 01             	add    $0x1,%eax
		/* free env */
		if (i > NENV - 1)
			i = 0;
		if (envs[i].env_id == 0)
f0105248:	8b 3d 40 c2 1d f0    	mov    0xf01dc240,%edi
f010524e:	ba 00 00 00 00       	mov    $0x0,%edx

	// LAB 4: Your code here.
	int cnt = 0;
	for (i = curenv?(ENVX(curenv->env_id) + 1):0; cnt < NENV - 1; cnt++, i++) {
		/* free env */
		if (i > NENV - 1)
f0105253:	be 00 00 00 00       	mov    $0x0,%esi
f0105258:	3d 00 04 00 00       	cmp    $0x400,%eax
f010525d:	0f 4d c6             	cmovge %esi,%eax
			i = 0;
		if (envs[i].env_id == 0)
f0105260:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f0105263:	8d 0c 1f             	lea    (%edi,%ebx,1),%ecx
f0105266:	83 79 48 00          	cmpl   $0x0,0x48(%ecx)
f010526a:	74 29                	je     f0105295 <sched_yield+0x85>
			continue;
		/* idle env or env running on other cpu */
		if (envs[i].env_type == ENV_TYPE_IDLE ||
f010526c:	83 79 50 01          	cmpl   $0x1,0x50(%ecx)
f0105270:	74 23                	je     f0105295 <sched_yield+0x85>
		    envs[i].env_status == ENV_RUNNING) {
f0105272:	8b 49 54             	mov    0x54(%ecx),%ecx
		if (i > NENV - 1)
			i = 0;
		if (envs[i].env_id == 0)
			continue;
		/* idle env or env running on other cpu */
		if (envs[i].env_type == ENV_TYPE_IDLE ||
f0105275:	83 f9 03             	cmp    $0x3,%ecx
f0105278:	74 1b                	je     f0105295 <sched_yield+0x85>
		    envs[i].env_status == ENV_RUNNING) {
			/* if (envs[i].env_type == ENV_TYPE_IDLE) */
			/* 	cprintf("skip an idle env\n"); */
			continue;
		}
		if (envs[i].env_status == ENV_RUNNABLE) {
f010527a:	83 f9 02             	cmp    $0x2,%ecx
f010527d:	8d 76 00             	lea    0x0(%esi),%esi
f0105280:	75 13                	jne    f0105295 <sched_yield+0x85>
			curenv->env_status == ENV_RUNNABLE;
f0105282:	e8 db 1c 00 00       	call   f0106f62 <cpunum>
			//cprintf("%s:sched_yield[%d]: yield to [%x]\n", __FILE__, __LINE__, envs[i].env_id);
			env_run(&envs[i]);
f0105287:	03 1d 40 c2 1d f0    	add    0xf01dc240,%ebx
f010528d:	89 1c 24             	mov    %ebx,(%esp)
f0105290:	e8 7c e9 ff ff       	call   f0103c11 <env_run>
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	int cnt = 0;
	for (i = curenv?(ENVX(curenv->env_id) + 1):0; cnt < NENV - 1; cnt++, i++) {
f0105295:	83 c2 01             	add    $0x1,%edx
f0105298:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f010529e:	74 05                	je     f01052a5 <sched_yield+0x95>
f01052a0:	83 c0 01             	add    $0x1,%eax
f01052a3:	eb b3                	jmp    f0105258 <sched_yield+0x48>
			//cprintf("%s:sched_yield[%d]: yield to [%x]\n", __FILE__, __LINE__, envs[i].env_id);
			env_run(&envs[i]);
		}
		continue;
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01052a5:	e8 b8 1c 00 00       	call   f0106f62 <cpunum>
f01052aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01052ad:	83 b8 28 d0 1d f0 00 	cmpl   $0x0,-0xfe22fd8(%eax)
f01052b4:	74 14                	je     f01052ca <sched_yield+0xba>
f01052b6:	e8 a7 1c 00 00       	call   f0106f62 <cpunum>
f01052bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01052be:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f01052c4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01052c8:	74 0f                	je     f01052d9 <sched_yield+0xc9>

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f01052ca:	8b 1d 40 c2 1d f0    	mov    0xf01dc240,%ebx
f01052d0:	89 d8                	mov    %ebx,%eax
f01052d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01052d7:	eb 16                	jmp    f01052ef <sched_yield+0xdf>
			env_run(&envs[i]);
		}
		continue;
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
		env_run(curenv);
f01052d9:	e8 84 1c 00 00       	call   f0106f62 <cpunum>
f01052de:	6b c0 74             	imul   $0x74,%eax,%eax
f01052e1:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f01052e7:	89 04 24             	mov    %eax,(%esp)
f01052ea:	e8 22 e9 ff ff       	call   f0103c11 <env_run>

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f01052ef:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f01052f3:	74 0b                	je     f0105300 <sched_yield+0xf0>
f01052f5:	8b 48 54             	mov    0x54(%eax),%ecx
f01052f8:	83 e9 02             	sub    $0x2,%ecx
f01052fb:	83 f9 01             	cmp    $0x1,%ecx
f01052fe:	76 10                	jbe    f0105310 <sched_yield+0x100>
	}

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105300:	83 c2 01             	add    $0x1,%edx
f0105303:	83 c0 7c             	add    $0x7c,%eax
f0105306:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010530c:	75 e1                	jne    f01052ef <sched_yield+0xdf>
f010530e:	eb 08                	jmp    f0105318 <sched_yield+0x108>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0105310:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105316:	75 1a                	jne    f0105332 <sched_yield+0x122>
		cprintf("No more runnable environments!\n");
f0105318:	c7 04 24 30 8c 10 f0 	movl   $0xf0108c30,(%esp)
f010531f:	e8 d7 f0 ff ff       	call   f01043fb <cprintf>
		while (1)
			monitor(NULL);
f0105324:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010532b:	e8 e3 b7 ff ff       	call   f0100b13 <monitor>
f0105330:	eb f2                	jmp    f0105324 <sched_yield+0x114>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0105332:	e8 2b 1c 00 00       	call   f0106f62 <cpunum>
f0105337:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010533a:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f010533c:	8b 43 54             	mov    0x54(%ebx),%eax
f010533f:	83 e8 02             	sub    $0x2,%eax
f0105342:	83 f8 01             	cmp    $0x1,%eax
f0105345:	76 25                	jbe    f010536c <sched_yield+0x15c>
		panic("CPU %d: No idle environment!", cpunum());
f0105347:	e8 16 1c 00 00       	call   f0106f62 <cpunum>
f010534c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105350:	c7 44 24 08 50 8c 10 	movl   $0xf0108c50,0x8(%esp)
f0105357:	f0 
f0105358:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
f010535f:	00 
f0105360:	c7 04 24 6d 8c 10 f0 	movl   $0xf0108c6d,(%esp)
f0105367:	e8 19 ad ff ff       	call   f0100085 <_panic>
	env_run(idle);
f010536c:	89 1c 24             	mov    %ebx,(%esp)
f010536f:	e8 9d e8 ff ff       	call   f0103c11 <env_run>
	...

f0105380 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f0105380:	55                   	push   %ebp
f0105381:	89 e5                	mov    %esp,%ebp
f0105383:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0105386:	e8 d7 1b 00 00       	call   f0106f62 <cpunum>
f010538b:	6b c0 74             	imul   $0x74,%eax,%eax
f010538e:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105394:	8b 40 48             	mov    0x48(%eax),%eax
}
f0105397:	c9                   	leave  
f0105398:	c3                   	ret    

f0105399 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0105399:	55                   	push   %ebp
f010539a:	89 e5                	mov    %esp,%ebp
f010539c:	57                   	push   %edi
f010539d:	56                   	push   %esi
f010539e:	53                   	push   %ebx
f010539f:	83 ec 2c             	sub    $0x2c,%esp
f01053a2:	c7 04 24 80 23 12 f0 	movl   $0xf0122380,(%esp)
f01053a9:	e8 77 1f 00 00       	call   f0107325 <spin_lock>
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t r = 0,perm = 0;
	lock_kernel();
	asm volatile(	"movl (%%ebp),%%eax\n"
					:"=a" (curenv->env_tf.tf_regs.reg_ecx),
f01053ae:	e8 af 1b 00 00       	call   f0106f62 <cpunum>
f01053b3:	bf 20 d0 1d f0       	mov    $0xf01dd020,%edi
f01053b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01053bb:	8b 5c 38 08          	mov    0x8(%eax,%edi,1),%ebx
					 "=S" (curenv->env_tf.tf_regs.reg_edx)
f01053bf:	e8 9e 1b 00 00       	call   f0106f62 <cpunum>
f01053c4:	89 c2                	mov    %eax,%edx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t r = 0,perm = 0;
	lock_kernel();
	asm volatile(	"movl (%%ebp),%%eax\n"
f01053c6:	8b 45 00             	mov    0x0(%ebp),%eax
f01053c9:	89 43 18             	mov    %eax,0x18(%ebx)
f01053cc:	6b d2 74             	imul   $0x74,%edx,%edx
f01053cf:	8b 44 3a 08          	mov    0x8(%edx,%edi,1),%eax
f01053d3:	89 70 14             	mov    %esi,0x14(%eax)
					:"=a" (curenv->env_tf.tf_regs.reg_ecx),
					 "=S" (curenv->env_tf.tf_regs.reg_edx)
					);
	curenv->env_tf.tf_trapno = T_SYSCALL;
f01053d6:	e8 87 1b 00 00       	call   f0106f62 <cpunum>
f01053db:	6b c0 74             	imul   $0x74,%eax,%eax
f01053de:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f01053e2:	c7 40 28 30 00 00 00 	movl   $0x30,0x28(%eax)
	curenv->env_tf.tf_eflags |= FL_IF;
f01053e9:	e8 74 1b 00 00       	call   f0106f62 <cpunum>
f01053ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01053f1:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f01053f5:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
	switch (syscallno) {
f01053fc:	83 7d 08 0e          	cmpl   $0xe,0x8(%ebp)
f0105400:	0f 87 02 07 00 00    	ja     f0105b08 <syscall+0x76f>
f0105406:	8b 45 08             	mov    0x8(%ebp),%eax
f0105409:	ff 24 85 90 8c 10 f0 	jmp    *-0xfef7370(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert (curenv, s, len, PTE_U);
f0105410:	e8 4d 1b 00 00       	call   f0106f62 <cpunum>
f0105415:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010541c:	00 
f010541d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105420:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105427:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010542b:	6b c0 74             	imul   $0x74,%eax,%eax
f010542e:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105434:	89 04 24             	mov    %eax,(%esp)
f0105437:	e8 96 c4 ff ff       	call   f01018d2 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010543c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010543f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105443:	8b 55 10             	mov    0x10(%ebp),%edx
f0105446:	89 54 24 04          	mov    %edx,0x4(%esp)
f010544a:	c7 04 24 7a 8c 10 f0 	movl   $0xf0108c7a,(%esp)
f0105451:	e8 a5 ef ff ff       	call   f01043fb <cprintf>
f0105456:	be 00 00 00 00       	mov    $0x0,%esi
f010545b:	e9 ad 06 00 00       	jmp    f0105b0d <syscall+0x774>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105460:	e8 37 b0 ff ff       	call   f010049c <cons_getc>
f0105465:	89 c6                	mov    %eax,%esi
	case SYS_cputs:
		sys_cputs ((const char*) a1, (size_t)a2); 
		break;
	case SYS_cgetc:
		r = sys_cgetc (); 
		break;
f0105467:	e9 a1 06 00 00       	jmp    f0105b0d <syscall+0x774>
	case SYS_getenvid:
		r = sys_getenvid (); 
f010546c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105470:	e8 0b ff ff ff       	call   f0105380 <sys_getenvid>
f0105475:	89 c6                	mov    %eax,%esi
		break;
f0105477:	e9 91 06 00 00       	jmp    f0105b0d <syscall+0x774>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010547c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105483:	00 
f0105484:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105487:	89 44 24 04          	mov    %eax,0x4(%esp)
f010548b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010548e:	89 0c 24             	mov    %ecx,(%esp)
f0105491:	e8 14 e6 ff ff       	call   f0103aaa <envid2env>
f0105496:	89 c6                	mov    %eax,%esi
f0105498:	85 c0                	test   %eax,%eax
f010549a:	0f 88 6d 06 00 00    	js     f0105b0d <syscall+0x774>
		return r;
	env_destroy(e);
f01054a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054a3:	89 04 24             	mov    %eax,(%esp)
f01054a6:	e8 e6 e9 ff ff       	call   f0103e91 <env_destroy>
f01054ab:	be 00 00 00 00       	mov    $0x0,%esi
f01054b0:	e9 58 06 00 00       	jmp    f0105b0d <syscall+0x774>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01054b5:	81 7d 0c ff ff ff ef 	cmpl   $0xefffffff,0xc(%ebp)
f01054bc:	77 23                	ja     f01054e1 <syscall+0x148>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01054be:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01054c5:	c7 44 24 08 3c 77 10 	movl   $0xf010773c,0x8(%esp)
f01054cc:	f0 
f01054cd:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
f01054d4:	00 
f01054d5:	c7 04 24 7f 8c 10 f0 	movl   $0xf0108c7f,(%esp)
f01054dc:	e8 a4 ab ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01054e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01054e4:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f01054ea:	c1 eb 0c             	shr    $0xc,%ebx
f01054ed:	3b 1d 88 ce 1d f0    	cmp    0xf01dce88,%ebx
f01054f3:	72 1c                	jb     f0105511 <syscall+0x178>
		panic("pa2page called with invalid pa");
f01054f5:	c7 44 24 08 48 7d 10 	movl   $0xf0107d48,0x8(%esp)
f01054fc:	f0 
f01054fd:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0105504:	00 
f0105505:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f010550c:	e8 74 ab ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0105511:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0105514:	be 03 00 00 00       	mov    $0x3,%esi
f0105519:	03 1d 90 ce 1d f0    	add    0xf01dce90,%ebx
f010551f:	0f 84 e8 05 00 00    	je     f0105b0d <syscall+0x774>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0105525:	e8 38 1a 00 00       	call   f0106f62 <cpunum>
f010552a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0105531:	00 
f0105532:	8b 55 10             	mov    0x10(%ebp),%edx
f0105535:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105539:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010553d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105540:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105546:	8b 40 60             	mov    0x60(%eax),%eax
f0105549:	89 04 24             	mov    %eax,(%esp)
f010554c:	e8 96 c4 ff ff       	call   f01019e7 <page_insert>
f0105551:	89 c6                	mov    %eax,%esi
f0105553:	e9 b5 05 00 00       	jmp    f0105b0d <syscall+0x774>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105558:	e8 b3 fc ff ff       	call   f0105210 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *newenv;
	int r;
	if((r = env_alloc(&newenv,sys_getenvid()))<0)
f010555d:	8d 76 00             	lea    0x0(%esi),%esi
f0105560:	e8 1b fe ff ff       	call   f0105380 <sys_getenvid>
f0105565:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105569:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010556c:	89 04 24             	mov    %eax,(%esp)
f010556f:	e8 7b e9 ff ff       	call   f0103eef <env_alloc>
f0105574:	89 c6                	mov    %eax,%esi
f0105576:	85 c0                	test   %eax,%eax
f0105578:	0f 88 8f 05 00 00    	js     f0105b0d <syscall+0x774>
		return r;
	newenv->env_status = ENV_NOT_RUNNABLE;
f010557e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105581:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	//env_pop_tf as sysexit
	newenv->env_tf.tf_regs.reg_ecx = curenv->env_tf.tf_regs.reg_ecx;
f0105588:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010558b:	e8 d2 19 00 00       	call   f0106f62 <cpunum>
f0105590:	bb 20 d0 1d f0       	mov    $0xf01dd020,%ebx
f0105595:	6b c0 74             	imul   $0x74,%eax,%eax
f0105598:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f010559c:	8b 40 18             	mov    0x18(%eax),%eax
f010559f:	89 46 18             	mov    %eax,0x18(%esi)
	newenv->env_tf.tf_regs.reg_edx = curenv->env_tf.tf_regs.reg_edx;
f01055a2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01055a5:	e8 b8 19 00 00       	call   f0106f62 <cpunum>
f01055aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01055ad:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01055b1:	8b 40 14             	mov    0x14(%eax),%eax
f01055b4:	89 46 14             	mov    %eax,0x14(%esi)
	newenv->env_tf.tf_regs.reg_eax = 0;
f01055b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055ba:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	newenv->env_tf.tf_eflags |= FL_IF;
f01055c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055c4:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
	newenv->env_tf.tf_trapno = T_SYSCALL;
f01055cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055ce:	c7 40 28 30 00 00 00 	movl   $0x30,0x28(%eax)
	return newenv->env_id;
f01055d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055d8:	8b 70 48             	mov    0x48(%eax),%esi
f01055db:	e9 2d 05 00 00       	jmp    f0105b0d <syscall+0x774>
		break;
	case SYS_exofork:
		r= sys_exofork();
		break;
	case SYS_env_set_status:
		r= sys_env_set_status((envid_t)a1,(int)a2);
f01055e0:	8b 45 10             	mov    0x10(%ebp),%eax
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01055e3:	83 f8 02             	cmp    $0x2,%eax
f01055e6:	74 0e                	je     f01055f6 <syscall+0x25d>
f01055e8:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01055ed:	83 f8 04             	cmp    $0x4,%eax
f01055f0:	0f 85 17 05 00 00    	jne    f0105b0d <syscall+0x774>
		return -E_INVAL;
	struct Env *envptr;
	int r;
	if((r = envid2env(envid,&envptr,1))<0)
f01055f6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01055fd:	00 
f01055fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105601:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105605:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105608:	89 0c 24             	mov    %ecx,(%esp)
f010560b:	e8 9a e4 ff ff       	call   f0103aaa <envid2env>
f0105610:	89 c6                	mov    %eax,%esi
f0105612:	85 c0                	test   %eax,%eax
f0105614:	0f 88 f3 04 00 00    	js     f0105b0d <syscall+0x774>
		return r;
	envptr->env_status = status;
f010561a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010561d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105620:	89 50 54             	mov    %edx,0x54(%eax)
f0105623:	be 00 00 00 00       	mov    $0x0,%esi
f0105628:	e9 e0 04 00 00       	jmp    f0105b0d <syscall+0x774>
		break;
	case SYS_env_set_status:
		r= sys_env_set_status((envid_t)a1,(int)a2);
		break;
  case SYS_env_set_trapframe:
    r= sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
f010562d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
  
  struct Env *e;
  user_mem_assert(curenv, tf, sizeof(struct Trapframe), PTE_U);
f0105630:	e8 2d 19 00 00       	call   f0106f62 <cpunum>
f0105635:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010563c:	00 
f010563d:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0105644:	00 
f0105645:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105649:	6b c0 74             	imul   $0x74,%eax,%eax
f010564c:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105652:	89 04 24             	mov    %eax,(%esp)
f0105655:	e8 78 c2 ff ff       	call   f01018d2 <user_mem_assert>
  
  if (envid2env(envid, &e, 1) < 0)
f010565a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105661:	00 
f0105662:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105665:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105669:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010566c:	89 0c 24             	mov    %ecx,(%esp)
f010566f:	e8 36 e4 ff ff       	call   f0103aaa <envid2env>
f0105674:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105679:	85 c0                	test   %eax,%eax
f010567b:	0f 88 8c 04 00 00    	js     f0105b0d <syscall+0x774>
      return -E_BAD_ENV;
  
  e->env_tf = *tf;
f0105681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105684:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105689:	89 c7                	mov    %eax,%edi
f010568b:	89 de                	mov    %ebx,%esi
f010568d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  e->env_tf.tf_cs = GD_UT | 3;
f010568f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105692:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
  e->env_tf.tf_eflags |= FL_IF;
f0105698:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010569b:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
f01056a2:	be 00 00 00 00       	mov    $0x0,%esi
f01056a7:	e9 61 04 00 00       	jmp    f0105b0d <syscall+0x774>
		break;
  case SYS_env_set_trapframe:
    r= sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
    break;
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f01056ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if(va >= (void *)UTOP)
f01056af:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01056b5:	0f 87 ed 00 00 00    	ja     f01057a8 <syscall+0x40f>
		return -E_INVAL;
	if( (perm & PTE_U) == 0 || (perm & PTE_P)==0)
f01056bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01056be:	83 e0 05             	and    $0x5,%eax
f01056c1:	83 f8 05             	cmp    $0x5,%eax
f01056c4:	0f 85 de 00 00 00    	jne    f01057a8 <syscall+0x40f>
		break;
  case SYS_env_set_trapframe:
    r= sys_env_set_trapframe((envid_t)a1, (struct Trapframe *)a2);
    break;
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f01056ca:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	if(va >= (void *)UTOP)
		return -E_INVAL;
	if( (perm & PTE_U) == 0 || (perm & PTE_P)==0)
		return -E_INVAL;
	if( (perm & ~PTE_SYSCALL) != 0)
f01056cd:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f01056d3:	0f 85 cf 00 00 00    	jne    f01057a8 <syscall+0x40f>
		return -E_INVAL;
		
	struct Env *e;
	if(envid2env(envid,&e,1)<0)
f01056d9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01056e0:	00 
f01056e1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01056e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056e8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056eb:	89 04 24             	mov    %eax,(%esp)
f01056ee:	e8 b7 e3 ff ff       	call   f0103aaa <envid2env>
f01056f3:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01056f8:	85 c0                	test   %eax,%eax
f01056fa:	0f 88 0d 04 00 00    	js     f0105b0d <syscall+0x774>
		return -E_BAD_ENV;
	
	struct Page *p;
	if( (p = page_alloc(ALLOC_ZERO)) == NULL)
f0105700:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0105707:	e8 92 bf ff ff       	call   f010169e <page_alloc>
f010570c:	89 c6                	mov    %eax,%esi
f010570e:	85 c0                	test   %eax,%eax
f0105710:	0f 84 92 00 00 00    	je     f01057a8 <syscall+0x40f>
		return -E_INVAL;
	if(page_insert(e->env_pgdir,p,va,perm) < 0)
f0105716:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010571a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010571e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105722:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105725:	8b 40 60             	mov    0x60(%eax),%eax
f0105728:	89 04 24             	mov    %eax,(%esp)
f010572b:	e8 b7 c2 ff ff       	call   f01019e7 <page_insert>
f0105730:	85 c0                	test   %eax,%eax
f0105732:	79 12                	jns    f0105746 <syscall+0x3ad>
	{
		page_free(p);
f0105734:	89 34 24             	mov    %esi,(%esp)
f0105737:	e8 4b b6 ff ff       	call   f0100d87 <page_free>
f010573c:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0105741:	e9 c7 03 00 00       	jmp    f0105b0d <syscall+0x774>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0105746:	89 f0                	mov    %esi,%eax
f0105748:	2b 05 90 ce 1d f0    	sub    0xf01dce90,%eax
f010574e:	c1 f8 03             	sar    $0x3,%eax
f0105751:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105754:	89 c2                	mov    %eax,%edx
f0105756:	c1 ea 0c             	shr    $0xc,%edx
f0105759:	3b 15 88 ce 1d f0    	cmp    0xf01dce88,%edx
f010575f:	72 20                	jb     f0105781 <syscall+0x3e8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105761:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105765:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f010576c:	f0 
f010576d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0105774:	00 
f0105775:	c7 04 24 ad 83 10 f0 	movl   $0xf01083ad,(%esp)
f010577c:	e8 04 a9 ff ff       	call   f0100085 <_panic>
		return -E_NO_MEM;
	}
	memset(page2kva(p),0,PGSIZE);
f0105781:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0105788:	00 
f0105789:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0105790:	00 
f0105791:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105796:	89 04 24             	mov    %eax,(%esp)
f0105799:	e8 18 11 00 00       	call   f01068b6 <memset>
f010579e:	be 00 00 00 00       	mov    $0x0,%esi
f01057a3:	e9 65 03 00 00       	jmp    f0105b0d <syscall+0x774>
f01057a8:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01057ad:	e9 5b 03 00 00       	jmp    f0105b0d <syscall+0x774>
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		break;
	case SYS_page_map:
		perm = a4 & 0xfff;
		a4 &= ~0xfff;
		r= sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,perm);
f01057b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if(	srcva >= (void *)UTOP || ROUNDUP(srcva,PGSIZE) != srcva ||
f01057b5:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01057bb:	0f 87 e8 00 00 00    	ja     f01058a9 <syscall+0x510>
f01057c1:	89 d8                	mov    %ebx,%eax
f01057c3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01057c8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01057cd:	39 c3                	cmp    %eax,%ebx
f01057cf:	0f 85 d4 00 00 00    	jne    f01058a9 <syscall+0x510>
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		break;
	case SYS_page_map:
		perm = a4 & 0xfff;
		a4 &= ~0xfff;
f01057d5:	8b 45 18             	mov    0x18(%ebp),%eax
f01057d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		r= sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,perm);
f01057dd:	89 c7                	mov    %eax,%edi
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if(	srcva >= (void *)UTOP || ROUNDUP(srcva,PGSIZE) != srcva ||
f01057df:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01057e4:	0f 87 bf 00 00 00    	ja     f01058a9 <syscall+0x510>
f01057ea:	39 c0                	cmp    %eax,%eax
f01057ec:	0f 85 b7 00 00 00    	jne    f01058a9 <syscall+0x510>
    break;
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		break;
	case SYS_page_map:
		perm = a4 & 0xfff;
f01057f2:	8b 75 18             	mov    0x18(%ebp),%esi
f01057f5:	81 e6 ff 0f 00 00    	and    $0xfff,%esi

	if(	srcva >= (void *)UTOP || ROUNDUP(srcva,PGSIZE) != srcva ||
		dstva >= (void *)UTOP || ROUNDUP(dstva,PGSIZE) != dstva )
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk0\n");
	if( (perm & PTE_U) == 0 || (perm & PTE_P)==0)
f01057fb:	8b 45 18             	mov    0x18(%ebp),%eax
f01057fe:	83 e0 05             	and    $0x5,%eax
f0105801:	83 f8 05             	cmp    $0x5,%eax
f0105804:	0f 85 9f 00 00 00    	jne    f01058a9 <syscall+0x510>
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk1\n");
	if( (perm & ~PTE_SYSCALL) > 0)
f010580a:	f7 c6 f8 f1 ff ff    	test   $0xfffff1f8,%esi
f0105810:	0f 85 93 00 00 00    	jne    f01058a9 <syscall+0x510>
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk2\n");
	struct Env *srce,*dste;
	if(	envid2env(srcenvid,&srce,1) < 0 ||
f0105816:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010581d:	00 
f010581e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105821:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105825:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105828:	89 14 24             	mov    %edx,(%esp)
f010582b:	e8 7a e2 ff ff       	call   f0103aaa <envid2env>
f0105830:	85 c0                	test   %eax,%eax
f0105832:	78 7f                	js     f01058b3 <syscall+0x51a>
		envid2env(dstenvid,&dste,1) < 0)
f0105834:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010583b:	00 
f010583c:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010583f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105843:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0105846:	89 0c 24             	mov    %ecx,(%esp)
f0105849:	e8 5c e2 ff ff       	call   f0103aaa <envid2env>
	//cprintf("kkkkkkkkkkkkkkkkkk1\n");
	if( (perm & ~PTE_SYSCALL) > 0)
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk2\n");
	struct Env *srce,*dste;
	if(	envid2env(srcenvid,&srce,1) < 0 ||
f010584e:	85 c0                	test   %eax,%eax
f0105850:	78 61                	js     f01058b3 <syscall+0x51a>
		envid2env(dstenvid,&dste,1) < 0)
		return -E_BAD_ENV;
	//cprintf("kkkkkkkkkkkkkkkkkk3\n");
	struct Page* p;
	pte_t* pte_store;
	p = page_lookup(srce->env_pgdir,srcva,&pte_store);
f0105852:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105855:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105859:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010585d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105860:	8b 40 60             	mov    0x60(%eax),%eax
f0105863:	89 04 24             	mov    %eax,(%esp)
f0105866:	e8 bf c0 ff ff       	call   f010192a <page_lookup>
	//cprintf("kkkkkkkkkkkkkkkkkk3.5\n");
	if(	p == NULL || 
f010586b:	85 c0                	test   %eax,%eax
f010586d:	74 3a                	je     f01058a9 <syscall+0x510>
f010586f:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0105875:	74 0b                	je     f0105882 <syscall+0x4e9>
f0105877:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010587a:	f6 02 02             	testb  $0x2,(%edx)
f010587d:	8d 76 00             	lea    0x0(%esi),%esi
f0105880:	74 27                	je     f01058a9 <syscall+0x510>
		((perm & PTE_W) >0 && (*pte_store & PTE_W) == 0))
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk4\n");
	if(page_insert(dste->env_pgdir,p,dstva,perm)<0)
f0105882:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105886:	89 7c 24 08          	mov    %edi,0x8(%esp)
f010588a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010588e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105891:	8b 40 60             	mov    0x60(%eax),%eax
f0105894:	89 04 24             	mov    %eax,(%esp)
f0105897:	e8 4b c1 ff ff       	call   f01019e7 <page_insert>
f010589c:	89 c6                	mov    %eax,%esi
f010589e:	c1 fe 1f             	sar    $0x1f,%esi
f01058a1:	83 e6 fc             	and    $0xfffffffc,%esi
f01058a4:	e9 64 02 00 00       	jmp    f0105b0d <syscall+0x774>
f01058a9:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01058ae:	e9 5a 02 00 00       	jmp    f0105b0d <syscall+0x774>
f01058b3:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01058b8:	e9 50 02 00 00       	jmp    f0105b0d <syscall+0x774>
		perm = a4 & 0xfff;
		a4 &= ~0xfff;
		r= sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,perm);
		break;
	case SYS_page_unmap:
		r= sys_page_unmap((envid_t)a1,(void*)a2);
f01058bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if(va >= (void*)UTOP || ROUNDUP(va,PGSIZE) != va)
f01058c0:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01058c6:	77 53                	ja     f010591b <syscall+0x582>
f01058c8:	89 d8                	mov    %ebx,%eax
f01058ca:	05 ff 0f 00 00       	add    $0xfff,%eax
f01058cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01058d4:	39 c3                	cmp    %eax,%ebx
f01058d6:	75 43                	jne    f010591b <syscall+0x582>
		return -E_INVAL;
	struct Env* e;
	if(envid2env(envid,&e,1)<0)
f01058d8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01058df:	00 
f01058e0:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01058e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058e7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058ea:	89 04 24             	mov    %eax,(%esp)
f01058ed:	e8 b8 e1 ff ff       	call   f0103aaa <envid2env>
f01058f2:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01058f7:	85 c0                	test   %eax,%eax
f01058f9:	0f 88 0e 02 00 00    	js     f0105b0d <syscall+0x774>
		return -E_BAD_ENV;
	page_remove(e->env_pgdir,va);
f01058ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105903:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105906:	8b 40 60             	mov    0x60(%eax),%eax
f0105909:	89 04 24             	mov    %eax,(%esp)
f010590c:	e8 86 c0 ff ff       	call   f0101997 <page_remove>
f0105911:	be 00 00 00 00       	mov    $0x0,%esi
f0105916:	e9 f2 01 00 00       	jmp    f0105b0d <syscall+0x774>
f010591b:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105920:	e9 e8 01 00 00       	jmp    f0105b0d <syscall+0x774>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env* e;
	if(envid2env(envid,&e,1)<0)
f0105925:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010592c:	00 
f010592d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105930:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105934:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105937:	89 14 24             	mov    %edx,(%esp)
f010593a:	e8 6b e1 ff ff       	call   f0103aaa <envid2env>
f010593f:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105944:	85 c0                	test   %eax,%eax
f0105946:	0f 88 c1 01 00 00    	js     f0105b0d <syscall+0x774>
		return -E_BAD_ENV;
	e->env_pgfault_upcall = func;
f010594c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010594f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105952:	89 48 64             	mov    %ecx,0x64(%eax)
f0105955:	be 00 00 00 00       	mov    $0x0,%esi
f010595a:	e9 ae 01 00 00       	jmp    f0105b0d <syscall+0x774>
		break;
	case SYS_env_set_pgfault_upcall:
		r = sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		break;
	case SYS_ipc_recv:
		r = sys_ipc_recv((void*)a1);
f010595f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
 if (dstva < (void *) UTOP && ROUNDDOWN (dstva, PGSIZE) != dstva)
f0105962:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105968:	77 0f                	ja     f0105979 <syscall+0x5e0>
f010596a:	89 d8                	mov    %ebx,%eax
f010596c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105971:	39 c3                	cmp    %eax,%ebx
f0105973:	0f 85 8f 01 00 00    	jne    f0105b08 <syscall+0x76f>
		return -E_INVAL;
	curenv->env_ipc_dstva = dstva;
f0105979:	e8 e4 15 00 00       	call   f0106f62 <cpunum>
f010597e:	be 20 d0 1d f0       	mov    $0xf01dd020,%esi
f0105983:	6b c0 74             	imul   $0x74,%eax,%eax
f0105986:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f010598a:	89 58 6c             	mov    %ebx,0x6c(%eax)
	curenv->env_ipc_recving = 1;
f010598d:	e8 d0 15 00 00       	call   f0106f62 <cpunum>
f0105992:	6b c0 74             	imul   $0x74,%eax,%eax
f0105995:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0105999:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f01059a0:	e8 bd 15 00 00       	call   f0106f62 <cpunum>
f01059a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01059a8:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01059ac:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01059b3:	e8 aa 15 00 00       	call   f0106f62 <cpunum>
f01059b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01059bb:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01059bf:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f01059c6:	e8 45 f8 ff ff       	call   f0105210 <sched_yield>
{
	// LAB 4: Your code here.
  struct Env* dste;
	int r;
	//envid doesn't currently exist.
	if((r = envid2env(envid,&dste,0)) < 0) {
f01059cb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01059d2:	00 
f01059d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01059d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01059da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01059dd:	89 04 24             	mov    %eax,(%esp)
f01059e0:	e8 c5 e0 ff ff       	call   f0103aaa <envid2env>
f01059e5:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01059ea:	85 c0                	test   %eax,%eax
f01059ec:	0f 88 1b 01 00 00    	js     f0105b0d <syscall+0x774>
		return -E_BAD_ENV;
  }
	//envid is not currently blocked in sys_ipc_recv,
	//or another environment managed to send first.
	if(!dste->env_ipc_recving || dste->env_ipc_from != 0)
f01059f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059f5:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f01059f9:	0f 84 fb 00 00 00    	je     f0105afa <syscall+0x761>
f01059ff:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0105a03:	0f 85 f1 00 00 00    	jne    f0105afa <syscall+0x761>
		break;
	case SYS_ipc_recv:
		r = sys_ipc_recv((void*)a1);
		break;
	case SYS_ipc_try_send:
		r = sys_ipc_try_send((envid_t)a1,a2,(void*)a3,(int)a4);
f0105a09:	8b 5d 14             	mov    0x14(%ebp),%ebx
	//envid is not currently blocked in sys_ipc_recv,
	//or another environment managed to send first.
	if(!dste->env_ipc_recving || dste->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
	
	if(srcva < (void*)UTOP )
f0105a0c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105a12:	0f 87 94 00 00 00    	ja     f0105aac <syscall+0x713>
	{
		//if srcva < UTOP but srcva is not page-aligned.
		if(ROUNDUP(srcva,PGSIZE) != srcva)
f0105a18:	89 da                	mov    %ebx,%edx
f0105a1a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0105a20:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0105a26:	39 d3                	cmp    %edx,%ebx
f0105a28:	0f 85 d3 00 00 00    	jne    f0105b01 <syscall+0x768>
			return -E_INVAL;
		//if srcva < UTOP and perm is inappropriate
		if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f0105a2e:	8b 55 18             	mov    0x18(%ebp),%edx
f0105a31:	83 e2 05             	and    $0x5,%edx
f0105a34:	83 fa 05             	cmp    $0x5,%edx
f0105a37:	0f 85 c4 00 00 00    	jne    f0105b01 <syscall+0x768>
			return -E_INVAL;
		if ((perm & ~PTE_SYSCALL) != 0)
f0105a3d:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0105a44:	0f 85 b7 00 00 00    	jne    f0105b01 <syscall+0x768>
			return -E_INVAL;
		//if srcva < UTOP but srcva is not mapped in the caller's address space.
		struct Page* p;
		pte_t* ptestore;
		dste->env_ipc_perm = 0;
f0105a4a:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
		
		p = page_lookup(curenv->env_pgdir,srcva,&ptestore);
f0105a51:	e8 0c 15 00 00       	call   f0106f62 <cpunum>
f0105a56:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105a59:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a5d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a61:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a64:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105a6a:	8b 40 60             	mov    0x60(%eax),%eax
f0105a6d:	89 04 24             	mov    %eax,(%esp)
f0105a70:	e8 b5 be ff ff       	call   f010192a <page_lookup>
		if( /*p == NULL ||*/ ((perm & PTE_W) >0 && !(*ptestore & PTE_W) >0)) {
f0105a75:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105a79:	74 08                	je     f0105a83 <syscall+0x6ea>
f0105a7b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105a7e:	f6 02 02             	testb  $0x2,(%edx)
f0105a81:	74 7e                	je     f0105b01 <syscall+0x768>
 			return -E_INVAL;
    }
		if(page_insert(dste->env_pgdir,p,dste->env_ipc_dstva,perm)<0)
f0105a83:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105a86:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105a89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105a8d:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105a90:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a98:	8b 42 60             	mov    0x60(%edx),%eax
f0105a9b:	89 04 24             	mov    %eax,(%esp)
f0105a9e:	e8 44 bf ff ff       	call   f01019e7 <page_insert>
f0105aa3:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0105aa8:	85 c0                	test   %eax,%eax
f0105aaa:	78 61                	js     f0105b0d <syscall+0x774>
			return -E_NO_MEM;
	}
		
	dste->env_ipc_recving = 0;
f0105aac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105aaf:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
	dste->env_ipc_from = curenv->env_id;
f0105ab6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105ab9:	e8 a4 14 00 00       	call   f0106f62 <cpunum>
f0105abe:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ac1:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105ac7:	8b 40 48             	mov    0x48(%eax),%eax
f0105aca:	89 43 74             	mov    %eax,0x74(%ebx)
	dste->env_ipc_value = value;
f0105acd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ad0:	8b 55 10             	mov    0x10(%ebp),%edx
f0105ad3:	89 50 70             	mov    %edx,0x70(%eax)
	dste->env_ipc_perm = perm;
f0105ad6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ad9:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105adc:	89 48 78             	mov    %ecx,0x78(%eax)
	dste->env_tf.tf_regs.reg_eax = 0;
f0105adf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ae2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	//cprintf("%x----------%x\n",dste->env_id,dste->env_ipc_from);
	dste->env_status = ENV_RUNNABLE;
f0105ae9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105aec:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0105af3:	be 00 00 00 00       	mov    $0x0,%esi
f0105af8:	eb 13                	jmp    f0105b0d <syscall+0x774>
f0105afa:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0105aff:	eb 0c                	jmp    f0105b0d <syscall+0x774>
f0105b01:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105b06:	eb 05                	jmp    f0105b0d <syscall+0x774>
f0105b08:	be fd ff ff ff       	mov    $0xfffffffd,%esi
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105b0d:	c7 04 24 80 23 12 f0 	movl   $0xf0122380,(%esp)
f0105b14:	e8 f3 16 00 00       	call   f010720c <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105b19:	f3 90                	pause  
	}
	unlock_kernel();
	return r;

	panic("syscall not implemented");
}
f0105b1b:	89 f0                	mov    %esi,%eax
f0105b1d:	83 c4 2c             	add    $0x2c,%esp
f0105b20:	5b                   	pop    %ebx
f0105b21:	5e                   	pop    %esi
f0105b22:	5f                   	pop    %edi
f0105b23:	5d                   	pop    %ebp
f0105b24:	c3                   	ret    
	...

f0105b30 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105b30:	55                   	push   %ebp
f0105b31:	89 e5                	mov    %esp,%ebp
f0105b33:	57                   	push   %edi
f0105b34:	56                   	push   %esi
f0105b35:	53                   	push   %ebx
f0105b36:	83 ec 14             	sub    $0x14,%esp
f0105b39:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105b3c:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105b3f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105b42:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105b45:	8b 1a                	mov    (%edx),%ebx
f0105b47:	8b 01                	mov    (%ecx),%eax
f0105b49:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0105b4c:	39 c3                	cmp    %eax,%ebx
f0105b4e:	0f 8f 9c 00 00 00    	jg     f0105bf0 <stab_binsearch+0xc0>
f0105b54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0105b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b5e:	01 d8                	add    %ebx,%eax
f0105b60:	89 c7                	mov    %eax,%edi
f0105b62:	c1 ef 1f             	shr    $0x1f,%edi
f0105b65:	01 c7                	add    %eax,%edi
f0105b67:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105b69:	39 df                	cmp    %ebx,%edi
f0105b6b:	7c 33                	jl     f0105ba0 <stab_binsearch+0x70>
f0105b6d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105b70:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105b73:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105b78:	39 f0                	cmp    %esi,%eax
f0105b7a:	0f 84 bc 00 00 00    	je     f0105c3c <stab_binsearch+0x10c>
f0105b80:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0105b84:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0105b88:	89 f8                	mov    %edi,%eax
			m--;
f0105b8a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105b8d:	39 d8                	cmp    %ebx,%eax
f0105b8f:	7c 0f                	jl     f0105ba0 <stab_binsearch+0x70>
f0105b91:	0f b6 0a             	movzbl (%edx),%ecx
f0105b94:	83 ea 0c             	sub    $0xc,%edx
f0105b97:	39 f1                	cmp    %esi,%ecx
f0105b99:	75 ef                	jne    f0105b8a <stab_binsearch+0x5a>
f0105b9b:	e9 9e 00 00 00       	jmp    f0105c3e <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105ba0:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105ba3:	eb 3c                	jmp    f0105be1 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105ba5:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105ba8:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0105baa:	8d 5f 01             	lea    0x1(%edi),%ebx
f0105bad:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105bb4:	eb 2b                	jmp    f0105be1 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0105bb6:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105bb9:	76 14                	jbe    f0105bcf <stab_binsearch+0x9f>
			*region_right = m - 1;
f0105bbb:	83 e8 01             	sub    $0x1,%eax
f0105bbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105bc1:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105bc4:	89 02                	mov    %eax,(%edx)
f0105bc6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105bcd:	eb 12                	jmp    f0105be1 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105bcf:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105bd2:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0105bd4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105bd8:	89 c3                	mov    %eax,%ebx
f0105bda:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0105be1:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0105be4:	0f 8d 71 ff ff ff    	jge    f0105b5b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105bea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105bee:	75 0f                	jne    f0105bff <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0105bf0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105bf3:	8b 03                	mov    (%ebx),%eax
f0105bf5:	83 e8 01             	sub    $0x1,%eax
f0105bf8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105bfb:	89 02                	mov    %eax,(%edx)
f0105bfd:	eb 57                	jmp    f0105c56 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105bff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105c02:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105c04:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105c07:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105c09:	39 c1                	cmp    %eax,%ecx
f0105c0b:	7d 28                	jge    f0105c35 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105c0d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105c10:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105c13:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105c18:	39 f2                	cmp    %esi,%edx
f0105c1a:	74 19                	je     f0105c35 <stab_binsearch+0x105>
f0105c1c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0105c20:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0105c24:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105c27:	39 c1                	cmp    %eax,%ecx
f0105c29:	7d 0a                	jge    f0105c35 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105c2b:	0f b6 1a             	movzbl (%edx),%ebx
f0105c2e:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105c31:	39 f3                	cmp    %esi,%ebx
f0105c33:	75 ef                	jne    f0105c24 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0105c35:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105c38:	89 02                	mov    %eax,(%edx)
f0105c3a:	eb 1a                	jmp    f0105c56 <stab_binsearch+0x126>
	}
}
f0105c3c:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105c3e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105c41:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105c44:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105c48:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105c4b:	0f 82 54 ff ff ff    	jb     f0105ba5 <stab_binsearch+0x75>
f0105c51:	e9 60 ff ff ff       	jmp    f0105bb6 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105c56:	83 c4 14             	add    $0x14,%esp
f0105c59:	5b                   	pop    %ebx
f0105c5a:	5e                   	pop    %esi
f0105c5b:	5f                   	pop    %edi
f0105c5c:	5d                   	pop    %ebp
f0105c5d:	c3                   	ret    

f0105c5e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105c5e:	55                   	push   %ebp
f0105c5f:	89 e5                	mov    %esp,%ebp
f0105c61:	83 ec 58             	sub    $0x58,%esp
f0105c64:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105c67:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105c6a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105c6d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105c73:	c7 03 cc 8c 10 f0    	movl   $0xf0108ccc,(%ebx)
	info->eip_line = 0;
f0105c79:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105c80:	c7 43 08 cc 8c 10 f0 	movl   $0xf0108ccc,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105c87:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105c8e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105c91:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105c98:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105c9e:	76 1f                	jbe    f0105cbf <debuginfo_eip+0x61>
f0105ca0:	bf 55 7c 11 f0       	mov    $0xf0117c55,%edi
f0105ca5:	c7 45 c4 41 42 11 f0 	movl   $0xf0114241,-0x3c(%ebp)
f0105cac:	c7 45 bc 40 42 11 f0 	movl   $0xf0114240,-0x44(%ebp)
f0105cb3:	c7 45 c0 f0 92 10 f0 	movl   $0xf01092f0,-0x40(%ebp)
f0105cba:	e9 c7 00 00 00       	jmp    f0105d86 <debuginfo_eip+0x128>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, usd, sizeof (struct UserStabData), PTE_U) < 0)
f0105cbf:	e8 9e 12 00 00       	call   f0106f62 <cpunum>
f0105cc4:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105ccb:	00 
f0105ccc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105cd3:	00 
f0105cd4:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105cdb:	00 
f0105cdc:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cdf:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105ce5:	89 04 24             	mov    %eax,(%esp)
f0105ce8:	e8 53 bb ff ff       	call   f0101840 <user_mem_check>
f0105ced:	85 c0                	test   %eax,%eax
f0105cef:	0f 88 53 02 00 00    	js     f0105f48 <debuginfo_eip+0x2ea>
			return -1;

		stabs = usd->stabs;
f0105cf5:	b8 00 00 20 00       	mov    $0x200000,%eax
f0105cfa:	8b 10                	mov    (%eax),%edx
f0105cfc:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f0105cff:	8b 48 04             	mov    0x4(%eax),%ecx
f0105d02:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr = usd->stabstr;
f0105d05:	8b 50 08             	mov    0x8(%eax),%edx
f0105d08:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105d0b:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0105d0e:	e8 4f 12 00 00       	call   f0106f62 <cpunum>
f0105d13:	89 c2                	mov    %eax,%edx
			|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105d15:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105d1c:	00 
f0105d1d:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105d20:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105d23:	c1 f8 02             	sar    $0x2,%eax
f0105d26:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105d2c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105d30:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105d33:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105d37:	6b c2 74             	imul   $0x74,%edx,%eax
f0105d3a:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105d40:	89 04 24             	mov    %eax,(%esp)
f0105d43:	e8 f8 ba ff ff       	call   f0101840 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0105d48:	85 c0                	test   %eax,%eax
f0105d4a:	0f 88 f8 01 00 00    	js     f0105f48 <debuginfo_eip+0x2ea>
			|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105d50:	e8 0d 12 00 00       	call   f0106f62 <cpunum>
f0105d55:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105d5c:	00 
f0105d5d:	89 fa                	mov    %edi,%edx
f0105d5f:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0105d62:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105d66:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105d69:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d6d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d70:	8b 80 28 d0 1d f0    	mov    -0xfe22fd8(%eax),%eax
f0105d76:	89 04 24             	mov    %eax,(%esp)
f0105d79:	e8 c2 ba ff ff       	call   f0101840 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0105d7e:	85 c0                	test   %eax,%eax
f0105d80:	0f 88 c2 01 00 00    	js     f0105f48 <debuginfo_eip+0x2ea>
			return -1;

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105d86:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0105d89:	0f 83 b9 01 00 00    	jae    f0105f48 <debuginfo_eip+0x2ea>
f0105d8f:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105d93:	0f 85 af 01 00 00    	jne    f0105f48 <debuginfo_eip+0x2ea>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105d99:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105da0:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105da3:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105da6:	c1 f8 02             	sar    $0x2,%eax
f0105da9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105daf:	83 e8 01             	sub    $0x1,%eax
f0105db2:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105db5:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105db8:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105dbb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105dbf:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105dc6:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105dc9:	e8 62 fd ff ff       	call   f0105b30 <stab_binsearch>
	if (lfile == 0)
f0105dce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105dd1:	85 c0                	test   %eax,%eax
f0105dd3:	0f 84 6f 01 00 00    	je     f0105f48 <debuginfo_eip+0x2ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105dd9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105ddc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ddf:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105de2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105de5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105de8:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105dec:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105df3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105df6:	e8 35 fd ff ff       	call   f0105b30 <stab_binsearch>

	if (lfun <= rfun) {
f0105dfb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105dfe:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105e01:	7f 35                	jg     f0105e38 <debuginfo_eip+0x1da>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105e03:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105e06:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105e09:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0105e0c:	89 fa                	mov    %edi,%edx
f0105e0e:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0105e11:	39 d0                	cmp    %edx,%eax
f0105e13:	73 06                	jae    f0105e1b <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105e15:	03 45 c4             	add    -0x3c(%ebp),%eax
f0105e18:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105e1b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105e1e:	6b c2 0c             	imul   $0xc,%edx,%eax
f0105e21:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105e24:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f0105e28:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105e2b:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105e2d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0105e30:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105e33:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105e36:	eb 0f                	jmp    f0105e47 <debuginfo_eip+0x1e9>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105e38:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105e3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e3e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105e41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105e44:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105e47:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105e4e:	00 
f0105e4f:	8b 43 08             	mov    0x8(%ebx),%eax
f0105e52:	89 04 24             	mov    %eax,(%esp)
f0105e55:	e8 31 0a 00 00       	call   f010688b <strfind>
f0105e5a:	2b 43 08             	sub    0x8(%ebx),%eax
f0105e5d:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105e60:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105e63:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105e66:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e6a:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105e71:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105e74:	e8 b7 fc ff ff       	call   f0105b30 <stab_binsearch>
	if(lline <= rline){
f0105e79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105e7c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105e7f:	7f 34                	jg     f0105eb5 <debuginfo_eip+0x257>
		info -> eip_line = stabs[lline].n_desc;
f0105e81:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105e84:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105e87:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f0105e8c:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0105e8f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105e92:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105e95:	89 4d bc             	mov    %ecx,-0x44(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105e98:	39 c8                	cmp    %ecx,%eax
f0105e9a:	7c 6b                	jl     f0105f07 <debuginfo_eip+0x2a9>
	       && stabs[lline].n_type != N_SOL
f0105e9c:	6b f0 0c             	imul   $0xc,%eax,%esi
f0105e9f:	01 d6                	add    %edx,%esi
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105ea1:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105ea5:	80 f9 84             	cmp    $0x84,%cl
f0105ea8:	74 48                	je     f0105ef2 <debuginfo_eip+0x294>
f0105eaa:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105ead:	6b d2 0c             	imul   $0xc,%edx,%edx
f0105eb0:	03 55 c0             	add    -0x40(%ebp),%edx
f0105eb3:	eb 2a                	jmp    f0105edf <debuginfo_eip+0x281>
	if(lline <= rline){
		info -> eip_line = stabs[lline].n_desc;
	}
	else
	{
		info -> eip_line = 0;
f0105eb5:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
f0105ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0105ec1:	e9 8e 00 00 00       	jmp    f0105f54 <debuginfo_eip+0x2f6>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105ec6:	83 e8 01             	sub    $0x1,%eax
f0105ec9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105ecc:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0105ecf:	7f 36                	jg     f0105f07 <debuginfo_eip+0x2a9>
f0105ed1:	89 d6                	mov    %edx,%esi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105ed3:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105ed7:	83 ea 0c             	sub    $0xc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105eda:	80 f9 84             	cmp    $0x84,%cl
f0105edd:	74 13                	je     f0105ef2 <debuginfo_eip+0x294>
f0105edf:	80 f9 64             	cmp    $0x64,%cl
f0105ee2:	75 e2                	jne    f0105ec6 <debuginfo_eip+0x268>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105ee4:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105ee8:	74 dc                	je     f0105ec6 <debuginfo_eip+0x268>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105eea:	3b 45 bc             	cmp    -0x44(%ebp),%eax
f0105eed:	8d 76 00             	lea    0x0(%esi),%esi
f0105ef0:	7c 15                	jl     f0105f07 <debuginfo_eip+0x2a9>
f0105ef2:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105ef5:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105ef8:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0105efb:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105efe:	39 f8                	cmp    %edi,%eax
f0105f00:	73 05                	jae    f0105f07 <debuginfo_eip+0x2a9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105f02:	03 45 c4             	add    -0x3c(%ebp),%eax
f0105f05:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105f07:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105f0a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105f0d:	7d 40                	jge    f0105f4f <debuginfo_eip+0x2f1>
		for (lline = lfun + 1;
f0105f0f:	83 c0 01             	add    $0x1,%eax
f0105f12:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105f15:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0105f18:	7e 35                	jle    f0105f4f <debuginfo_eip+0x2f1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105f1a:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105f1d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105f20:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f0105f25:	75 28                	jne    f0105f4f <debuginfo_eip+0x2f1>
		     lline++)
			info->eip_fn_narg++;
f0105f27:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105f2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105f2e:	83 c0 01             	add    $0x1,%eax
f0105f31:	89 45 d4             	mov    %eax,-0x2c(%ebp)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105f34:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0105f37:	7e 16                	jle    f0105f4f <debuginfo_eip+0x2f1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105f39:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105f3c:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105f3f:	80 7c 82 04 a0       	cmpb   $0xa0,0x4(%edx,%eax,4)
f0105f44:	74 e1                	je     f0105f27 <debuginfo_eip+0x2c9>
f0105f46:	eb 07                	jmp    f0105f4f <debuginfo_eip+0x2f1>
f0105f48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105f4d:	eb 05                	jmp    f0105f54 <debuginfo_eip+0x2f6>
f0105f4f:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0105f54:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0105f57:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0105f5a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0105f5d:	89 ec                	mov    %ebp,%esp
f0105f5f:	5d                   	pop    %ebp
f0105f60:	c3                   	ret    
	...

f0105f70 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105f70:	55                   	push   %ebp
f0105f71:	89 e5                	mov    %esp,%ebp
f0105f73:	57                   	push   %edi
f0105f74:	56                   	push   %esi
f0105f75:	53                   	push   %ebx
f0105f76:	83 ec 4c             	sub    $0x4c,%esp
f0105f79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f7c:	89 d6                	mov    %edx,%esi
f0105f7e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105f81:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105f84:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105f87:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105f8a:	8b 45 10             	mov    0x10(%ebp),%eax
f0105f8d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105f90:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105f93:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105f96:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105f9b:	39 d1                	cmp    %edx,%ecx
f0105f9d:	72 15                	jb     f0105fb4 <printnum+0x44>
f0105f9f:	77 07                	ja     f0105fa8 <printnum+0x38>
f0105fa1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105fa4:	39 d0                	cmp    %edx,%eax
f0105fa6:	76 0c                	jbe    f0105fb4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0105fa8:	83 eb 01             	sub    $0x1,%ebx
f0105fab:	85 db                	test   %ebx,%ebx
f0105fad:	8d 76 00             	lea    0x0(%esi),%esi
f0105fb0:	7f 61                	jg     f0106013 <printnum+0xa3>
f0105fb2:	eb 70                	jmp    f0106024 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105fb4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0105fb8:	83 eb 01             	sub    $0x1,%ebx
f0105fbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105fbf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105fc3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0105fc7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0105fcb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0105fce:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0105fd1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105fd4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105fd8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105fdf:	00 
f0105fe0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105fe3:	89 04 24             	mov    %eax,(%esp)
f0105fe6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105fe9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105fed:	e8 0e 14 00 00       	call   f0107400 <__udivdi3>
f0105ff2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105ff5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105ff8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105ffc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106000:	89 04 24             	mov    %eax,(%esp)
f0106003:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106007:	89 f2                	mov    %esi,%edx
f0106009:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010600c:	e8 5f ff ff ff       	call   f0105f70 <printnum>
f0106011:	eb 11                	jmp    f0106024 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0106013:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106017:	89 3c 24             	mov    %edi,(%esp)
f010601a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010601d:	83 eb 01             	sub    $0x1,%ebx
f0106020:	85 db                	test   %ebx,%ebx
f0106022:	7f ef                	jg     f0106013 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0106024:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106028:	8b 74 24 04          	mov    0x4(%esp),%esi
f010602c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010602f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106033:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010603a:	00 
f010603b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010603e:	89 14 24             	mov    %edx,(%esp)
f0106041:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106044:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106048:	e8 e3 14 00 00       	call   f0107530 <__umoddi3>
f010604d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106051:	0f be 80 d6 8c 10 f0 	movsbl -0xfef732a(%eax),%eax
f0106058:	89 04 24             	mov    %eax,(%esp)
f010605b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010605e:	83 c4 4c             	add    $0x4c,%esp
f0106061:	5b                   	pop    %ebx
f0106062:	5e                   	pop    %esi
f0106063:	5f                   	pop    %edi
f0106064:	5d                   	pop    %ebp
f0106065:	c3                   	ret    

f0106066 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0106066:	55                   	push   %ebp
f0106067:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0106069:	83 fa 01             	cmp    $0x1,%edx
f010606c:	7e 0e                	jle    f010607c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010606e:	8b 10                	mov    (%eax),%edx
f0106070:	8d 4a 08             	lea    0x8(%edx),%ecx
f0106073:	89 08                	mov    %ecx,(%eax)
f0106075:	8b 02                	mov    (%edx),%eax
f0106077:	8b 52 04             	mov    0x4(%edx),%edx
f010607a:	eb 22                	jmp    f010609e <getuint+0x38>
	else if (lflag)
f010607c:	85 d2                	test   %edx,%edx
f010607e:	74 10                	je     f0106090 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0106080:	8b 10                	mov    (%eax),%edx
f0106082:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106085:	89 08                	mov    %ecx,(%eax)
f0106087:	8b 02                	mov    (%edx),%eax
f0106089:	ba 00 00 00 00       	mov    $0x0,%edx
f010608e:	eb 0e                	jmp    f010609e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0106090:	8b 10                	mov    (%eax),%edx
f0106092:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106095:	89 08                	mov    %ecx,(%eax)
f0106097:	8b 02                	mov    (%edx),%eax
f0106099:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010609e:	5d                   	pop    %ebp
f010609f:	c3                   	ret    

f01060a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01060a0:	55                   	push   %ebp
f01060a1:	89 e5                	mov    %esp,%ebp
f01060a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01060a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01060aa:	8b 10                	mov    (%eax),%edx
f01060ac:	3b 50 04             	cmp    0x4(%eax),%edx
f01060af:	73 0a                	jae    f01060bb <sprintputch+0x1b>
		*b->buf++ = ch;
f01060b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01060b4:	88 0a                	mov    %cl,(%edx)
f01060b6:	83 c2 01             	add    $0x1,%edx
f01060b9:	89 10                	mov    %edx,(%eax)
}
f01060bb:	5d                   	pop    %ebp
f01060bc:	c3                   	ret    

f01060bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01060bd:	55                   	push   %ebp
f01060be:	89 e5                	mov    %esp,%ebp
f01060c0:	57                   	push   %edi
f01060c1:	56                   	push   %esi
f01060c2:	53                   	push   %ebx
f01060c3:	83 ec 5c             	sub    $0x5c,%esp
f01060c6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01060c9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01060cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f01060cf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f01060d6:	eb 11                	jmp    f01060e9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01060d8:	85 c0                	test   %eax,%eax
f01060da:	0f 84 68 04 00 00    	je     f0106548 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
f01060e0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01060e4:	89 04 24             	mov    %eax,(%esp)
f01060e7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01060e9:	0f b6 03             	movzbl (%ebx),%eax
f01060ec:	83 c3 01             	add    $0x1,%ebx
f01060ef:	83 f8 25             	cmp    $0x25,%eax
f01060f2:	75 e4                	jne    f01060d8 <vprintfmt+0x1b>
f01060f4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01060fb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f0106102:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106107:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f010610b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0106112:	eb 06                	jmp    f010611a <vprintfmt+0x5d>
f0106114:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f0106118:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010611a:	0f b6 13             	movzbl (%ebx),%edx
f010611d:	0f b6 c2             	movzbl %dl,%eax
f0106120:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106123:	8d 43 01             	lea    0x1(%ebx),%eax
f0106126:	83 ea 23             	sub    $0x23,%edx
f0106129:	80 fa 55             	cmp    $0x55,%dl
f010612c:	0f 87 f9 03 00 00    	ja     f010652b <vprintfmt+0x46e>
f0106132:	0f b6 d2             	movzbl %dl,%edx
f0106135:	ff 24 95 c0 8e 10 f0 	jmp    *-0xfef7140(,%edx,4)
f010613c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f0106140:	eb d6                	jmp    f0106118 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0106142:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0106145:	83 ea 30             	sub    $0x30,%edx
f0106148:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f010614b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010614e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0106151:	83 fb 09             	cmp    $0x9,%ebx
f0106154:	77 54                	ja     f01061aa <vprintfmt+0xed>
f0106156:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0106159:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010615c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f010615f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0106162:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0106166:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0106169:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010616c:	83 fb 09             	cmp    $0x9,%ebx
f010616f:	76 eb                	jbe    f010615c <vprintfmt+0x9f>
f0106171:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0106174:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0106177:	eb 31                	jmp    f01061aa <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0106179:	8b 55 14             	mov    0x14(%ebp),%edx
f010617c:	8d 5a 04             	lea    0x4(%edx),%ebx
f010617f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0106182:	8b 12                	mov    (%edx),%edx
f0106184:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f0106187:	eb 21                	jmp    f01061aa <vprintfmt+0xed>

		case '.':
			if (width < 0)
f0106189:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010618d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106192:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
f0106196:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0106199:	e9 7a ff ff ff       	jmp    f0106118 <vprintfmt+0x5b>
f010619e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01061a5:	e9 6e ff ff ff       	jmp    f0106118 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f01061aa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01061ae:	0f 89 64 ff ff ff    	jns    f0106118 <vprintfmt+0x5b>
f01061b4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01061b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01061ba:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01061bd:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01061c0:	e9 53 ff ff ff       	jmp    f0106118 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01061c5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f01061c8:	e9 4b ff ff ff       	jmp    f0106118 <vprintfmt+0x5b>
f01061cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01061d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01061d3:	8d 50 04             	lea    0x4(%eax),%edx
f01061d6:	89 55 14             	mov    %edx,0x14(%ebp)
f01061d9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01061dd:	8b 00                	mov    (%eax),%eax
f01061df:	89 04 24             	mov    %eax,(%esp)
f01061e2:	ff d7                	call   *%edi
f01061e4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01061e7:	e9 fd fe ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
f01061ec:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f01061ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01061f2:	8d 50 04             	lea    0x4(%eax),%edx
f01061f5:	89 55 14             	mov    %edx,0x14(%ebp)
f01061f8:	8b 00                	mov    (%eax),%eax
f01061fa:	89 c2                	mov    %eax,%edx
f01061fc:	c1 fa 1f             	sar    $0x1f,%edx
f01061ff:	31 d0                	xor    %edx,%eax
f0106201:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0106203:	83 f8 0f             	cmp    $0xf,%eax
f0106206:	7f 0b                	jg     f0106213 <vprintfmt+0x156>
f0106208:	8b 14 85 20 90 10 f0 	mov    -0xfef6fe0(,%eax,4),%edx
f010620f:	85 d2                	test   %edx,%edx
f0106211:	75 20                	jne    f0106233 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
f0106213:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106217:	c7 44 24 08 e7 8c 10 	movl   $0xf0108ce7,0x8(%esp)
f010621e:	f0 
f010621f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106223:	89 3c 24             	mov    %edi,(%esp)
f0106226:	e8 a5 03 00 00       	call   f01065d0 <printfmt>
f010622b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010622e:	e9 b6 fe ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0106233:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106237:	c7 44 24 08 d9 83 10 	movl   $0xf01083d9,0x8(%esp)
f010623e:	f0 
f010623f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106243:	89 3c 24             	mov    %edi,(%esp)
f0106246:	e8 85 03 00 00       	call   f01065d0 <printfmt>
f010624b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010624e:	e9 96 fe ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
f0106253:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0106256:	89 c3                	mov    %eax,%ebx
f0106258:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010625b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010625e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0106261:	8b 45 14             	mov    0x14(%ebp),%eax
f0106264:	8d 50 04             	lea    0x4(%eax),%edx
f0106267:	89 55 14             	mov    %edx,0x14(%ebp)
f010626a:	8b 00                	mov    (%eax),%eax
f010626c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010626f:	85 c0                	test   %eax,%eax
f0106271:	b8 f0 8c 10 f0       	mov    $0xf0108cf0,%eax
f0106276:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
f010627a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f010627d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0106281:	7e 06                	jle    f0106289 <vprintfmt+0x1cc>
f0106283:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f0106287:	75 13                	jne    f010629c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106289:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010628c:	0f be 02             	movsbl (%edx),%eax
f010628f:	85 c0                	test   %eax,%eax
f0106291:	0f 85 a2 00 00 00    	jne    f0106339 <vprintfmt+0x27c>
f0106297:	e9 8f 00 00 00       	jmp    f010632b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010629c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01062a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01062a3:	89 0c 24             	mov    %ecx,(%esp)
f01062a6:	e8 50 04 00 00       	call   f01066fb <strnlen>
f01062ab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01062ae:	29 c2                	sub    %eax,%edx
f01062b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01062b3:	85 d2                	test   %edx,%edx
f01062b5:	7e d2                	jle    f0106289 <vprintfmt+0x1cc>
					putch(padc, putdat);
f01062b7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f01062bb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01062be:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f01062c1:	89 d3                	mov    %edx,%ebx
f01062c3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01062ca:	89 04 24             	mov    %eax,(%esp)
f01062cd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01062cf:	83 eb 01             	sub    $0x1,%ebx
f01062d2:	85 db                	test   %ebx,%ebx
f01062d4:	7f ed                	jg     f01062c3 <vprintfmt+0x206>
f01062d6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01062d9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01062e0:	eb a7                	jmp    f0106289 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01062e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01062e6:	74 1b                	je     f0106303 <vprintfmt+0x246>
f01062e8:	8d 50 e0             	lea    -0x20(%eax),%edx
f01062eb:	83 fa 5e             	cmp    $0x5e,%edx
f01062ee:	76 13                	jbe    f0106303 <vprintfmt+0x246>
					putch('?', putdat);
f01062f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01062f3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01062f7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01062fe:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106301:	eb 0d                	jmp    f0106310 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0106303:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0106306:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010630a:	89 04 24             	mov    %eax,(%esp)
f010630d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106310:	83 ef 01             	sub    $0x1,%edi
f0106313:	0f be 03             	movsbl (%ebx),%eax
f0106316:	85 c0                	test   %eax,%eax
f0106318:	74 05                	je     f010631f <vprintfmt+0x262>
f010631a:	83 c3 01             	add    $0x1,%ebx
f010631d:	eb 31                	jmp    f0106350 <vprintfmt+0x293>
f010631f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0106322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0106325:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0106328:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010632b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010632f:	7f 36                	jg     f0106367 <vprintfmt+0x2aa>
f0106331:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0106334:	e9 b0 fd ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106339:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010633c:	83 c2 01             	add    $0x1,%edx
f010633f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0106342:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0106345:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0106348:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010634b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f010634e:	89 d3                	mov    %edx,%ebx
f0106350:	85 f6                	test   %esi,%esi
f0106352:	78 8e                	js     f01062e2 <vprintfmt+0x225>
f0106354:	83 ee 01             	sub    $0x1,%esi
f0106357:	79 89                	jns    f01062e2 <vprintfmt+0x225>
f0106359:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010635c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010635f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0106362:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0106365:	eb c4                	jmp    f010632b <vprintfmt+0x26e>
f0106367:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010636a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010636d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106371:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106378:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010637a:	83 eb 01             	sub    $0x1,%ebx
f010637d:	85 db                	test   %ebx,%ebx
f010637f:	7f ec                	jg     f010636d <vprintfmt+0x2b0>
f0106381:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0106384:	e9 60 fd ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
f0106389:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010638c:	83 f9 01             	cmp    $0x1,%ecx
f010638f:	7e 16                	jle    f01063a7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
f0106391:	8b 45 14             	mov    0x14(%ebp),%eax
f0106394:	8d 50 08             	lea    0x8(%eax),%edx
f0106397:	89 55 14             	mov    %edx,0x14(%ebp)
f010639a:	8b 10                	mov    (%eax),%edx
f010639c:	8b 48 04             	mov    0x4(%eax),%ecx
f010639f:	89 55 d8             	mov    %edx,-0x28(%ebp)
f01063a2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01063a5:	eb 32                	jmp    f01063d9 <vprintfmt+0x31c>
	else if (lflag)
f01063a7:	85 c9                	test   %ecx,%ecx
f01063a9:	74 18                	je     f01063c3 <vprintfmt+0x306>
		return va_arg(*ap, long);
f01063ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01063ae:	8d 50 04             	lea    0x4(%eax),%edx
f01063b1:	89 55 14             	mov    %edx,0x14(%ebp)
f01063b4:	8b 00                	mov    (%eax),%eax
f01063b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01063b9:	89 c1                	mov    %eax,%ecx
f01063bb:	c1 f9 1f             	sar    $0x1f,%ecx
f01063be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01063c1:	eb 16                	jmp    f01063d9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
f01063c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01063c6:	8d 50 04             	lea    0x4(%eax),%edx
f01063c9:	89 55 14             	mov    %edx,0x14(%ebp)
f01063cc:	8b 00                	mov    (%eax),%eax
f01063ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01063d1:	89 c2                	mov    %eax,%edx
f01063d3:	c1 fa 1f             	sar    $0x1f,%edx
f01063d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01063d9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01063dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01063df:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f01063e4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01063e8:	0f 89 8a 00 00 00    	jns    f0106478 <vprintfmt+0x3bb>
				putch('-', putdat);
f01063ee:	89 74 24 04          	mov    %esi,0x4(%esp)
f01063f2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01063f9:	ff d7                	call   *%edi
				num = -(long long) num;
f01063fb:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01063fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106401:	f7 d8                	neg    %eax
f0106403:	83 d2 00             	adc    $0x0,%edx
f0106406:	f7 da                	neg    %edx
f0106408:	eb 6e                	jmp    f0106478 <vprintfmt+0x3bb>
f010640a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010640d:	89 ca                	mov    %ecx,%edx
f010640f:	8d 45 14             	lea    0x14(%ebp),%eax
f0106412:	e8 4f fc ff ff       	call   f0106066 <getuint>
f0106417:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
f010641c:	eb 5a                	jmp    f0106478 <vprintfmt+0x3bb>
f010641e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f0106421:	89 ca                	mov    %ecx,%edx
f0106423:	8d 45 14             	lea    0x14(%ebp),%eax
f0106426:	e8 3b fc ff ff       	call   f0106066 <getuint>
f010642b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
f0106430:	eb 46                	jmp    f0106478 <vprintfmt+0x3bb>
f0106432:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
f0106435:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106439:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0106440:	ff d7                	call   *%edi
			putch('x', putdat);
f0106442:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106446:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010644d:	ff d7                	call   *%edi
			num = (unsigned long long)
f010644f:	8b 45 14             	mov    0x14(%ebp),%eax
f0106452:	8d 50 04             	lea    0x4(%eax),%edx
f0106455:	89 55 14             	mov    %edx,0x14(%ebp)
f0106458:	8b 00                	mov    (%eax),%eax
f010645a:	ba 00 00 00 00       	mov    $0x0,%edx
f010645f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0106464:	eb 12                	jmp    f0106478 <vprintfmt+0x3bb>
f0106466:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106469:	89 ca                	mov    %ecx,%edx
f010646b:	8d 45 14             	lea    0x14(%ebp),%eax
f010646e:	e8 f3 fb ff ff       	call   f0106066 <getuint>
f0106473:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106478:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f010647c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106480:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0106483:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106487:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010648b:	89 04 24             	mov    %eax,(%esp)
f010648e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106492:	89 f2                	mov    %esi,%edx
f0106494:	89 f8                	mov    %edi,%eax
f0106496:	e8 d5 fa ff ff       	call   f0105f70 <printnum>
f010649b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f010649e:	e9 46 fc ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
f01064a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
f01064a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01064a9:	8d 50 04             	lea    0x4(%eax),%edx
f01064ac:	89 55 14             	mov    %edx,0x14(%ebp)
f01064af:	8b 00                	mov    (%eax),%eax
f01064b1:	85 c0                	test   %eax,%eax
f01064b3:	75 24                	jne    f01064d9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
f01064b5:	c7 44 24 0c 0c 8e 10 	movl   $0xf0108e0c,0xc(%esp)
f01064bc:	f0 
f01064bd:	c7 44 24 08 d9 83 10 	movl   $0xf01083d9,0x8(%esp)
f01064c4:	f0 
f01064c5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01064c9:	89 3c 24             	mov    %edi,(%esp)
f01064cc:	e8 ff 00 00 00       	call   f01065d0 <printfmt>
f01064d1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01064d4:	e9 10 fc ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
f01064d9:	83 3e 7f             	cmpl   $0x7f,(%esi)
f01064dc:	7e 29                	jle    f0106507 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
f01064de:	0f b6 16             	movzbl (%esi),%edx
f01064e1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
f01064e3:	c7 44 24 0c 44 8e 10 	movl   $0xf0108e44,0xc(%esp)
f01064ea:	f0 
f01064eb:	c7 44 24 08 d9 83 10 	movl   $0xf01083d9,0x8(%esp)
f01064f2:	f0 
f01064f3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01064f7:	89 3c 24             	mov    %edi,(%esp)
f01064fa:	e8 d1 00 00 00       	call   f01065d0 <printfmt>
f01064ff:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0106502:	e9 e2 fb ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
f0106507:	0f b6 16             	movzbl (%esi),%edx
f010650a:	88 10                	mov    %dl,(%eax)
f010650c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
f010650f:	e9 d5 fb ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
f0106514:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0106517:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010651a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010651e:	89 14 24             	mov    %edx,(%esp)
f0106521:	ff d7                	call   *%edi
f0106523:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0106526:	e9 be fb ff ff       	jmp    f01060e9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010652b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010652f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0106536:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0106538:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010653b:	80 38 25             	cmpb   $0x25,(%eax)
f010653e:	0f 84 a5 fb ff ff    	je     f01060e9 <vprintfmt+0x2c>
f0106544:	89 c3                	mov    %eax,%ebx
f0106546:	eb f0                	jmp    f0106538 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
f0106548:	83 c4 5c             	add    $0x5c,%esp
f010654b:	5b                   	pop    %ebx
f010654c:	5e                   	pop    %esi
f010654d:	5f                   	pop    %edi
f010654e:	5d                   	pop    %ebp
f010654f:	c3                   	ret    

f0106550 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0106550:	55                   	push   %ebp
f0106551:	89 e5                	mov    %esp,%ebp
f0106553:	83 ec 28             	sub    $0x28,%esp
f0106556:	8b 45 08             	mov    0x8(%ebp),%eax
f0106559:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f010655c:	85 c0                	test   %eax,%eax
f010655e:	74 04                	je     f0106564 <vsnprintf+0x14>
f0106560:	85 d2                	test   %edx,%edx
f0106562:	7f 07                	jg     f010656b <vsnprintf+0x1b>
f0106564:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106569:	eb 3b                	jmp    f01065a6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f010656b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010656e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0106572:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106575:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010657c:	8b 45 14             	mov    0x14(%ebp),%eax
f010657f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106583:	8b 45 10             	mov    0x10(%ebp),%eax
f0106586:	89 44 24 08          	mov    %eax,0x8(%esp)
f010658a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010658d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106591:	c7 04 24 a0 60 10 f0 	movl   $0xf01060a0,(%esp)
f0106598:	e8 20 fb ff ff       	call   f01060bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010659d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01065a0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01065a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f01065a6:	c9                   	leave  
f01065a7:	c3                   	ret    

f01065a8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01065a8:	55                   	push   %ebp
f01065a9:	89 e5                	mov    %esp,%ebp
f01065ab:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f01065ae:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f01065b1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01065b5:	8b 45 10             	mov    0x10(%ebp),%eax
f01065b8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01065bc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065c3:	8b 45 08             	mov    0x8(%ebp),%eax
f01065c6:	89 04 24             	mov    %eax,(%esp)
f01065c9:	e8 82 ff ff ff       	call   f0106550 <vsnprintf>
	va_end(ap);

	return rc;
}
f01065ce:	c9                   	leave  
f01065cf:	c3                   	ret    

f01065d0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01065d0:	55                   	push   %ebp
f01065d1:	89 e5                	mov    %esp,%ebp
f01065d3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f01065d6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01065d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01065dd:	8b 45 10             	mov    0x10(%ebp),%eax
f01065e0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01065e4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01065e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01065eb:	8b 45 08             	mov    0x8(%ebp),%eax
f01065ee:	89 04 24             	mov    %eax,(%esp)
f01065f1:	e8 c7 fa ff ff       	call   f01060bd <vprintfmt>
	va_end(ap);
}
f01065f6:	c9                   	leave  
f01065f7:	c3                   	ret    
	...

f0106600 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0106600:	55                   	push   %ebp
f0106601:	89 e5                	mov    %esp,%ebp
f0106603:	57                   	push   %edi
f0106604:	56                   	push   %esi
f0106605:	53                   	push   %ebx
f0106606:	83 ec 1c             	sub    $0x1c,%esp
f0106609:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010660c:	85 c0                	test   %eax,%eax
f010660e:	74 10                	je     f0106620 <readline+0x20>
		cprintf("%s", prompt);
f0106610:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106614:	c7 04 24 d9 83 10 f0 	movl   $0xf01083d9,(%esp)
f010661b:	e8 db dd ff ff       	call   f01043fb <cprintf>

	i = 0;
	echoing = iscons(0);
f0106620:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0106627:	e8 c4 9e ff ff       	call   f01004f0 <iscons>
f010662c:	89 c7                	mov    %eax,%edi
f010662e:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0106633:	e8 a7 9e ff ff       	call   f01004df <getchar>
f0106638:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010663a:	85 c0                	test   %eax,%eax
f010663c:	79 17                	jns    f0106655 <readline+0x55>
			cprintf("read error: %e\n", c);
f010663e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106642:	c7 04 24 60 90 10 f0 	movl   $0xf0109060,(%esp)
f0106649:	e8 ad dd ff ff       	call   f01043fb <cprintf>
f010664e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0106653:	eb 76                	jmp    f01066cb <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106655:	83 f8 08             	cmp    $0x8,%eax
f0106658:	74 08                	je     f0106662 <readline+0x62>
f010665a:	83 f8 7f             	cmp    $0x7f,%eax
f010665d:	8d 76 00             	lea    0x0(%esi),%esi
f0106660:	75 19                	jne    f010667b <readline+0x7b>
f0106662:	85 f6                	test   %esi,%esi
f0106664:	7e 15                	jle    f010667b <readline+0x7b>
			if (echoing)
f0106666:	85 ff                	test   %edi,%edi
f0106668:	74 0c                	je     f0106676 <readline+0x76>
				cputchar('\b');
f010666a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0106671:	e8 84 a0 ff ff       	call   f01006fa <cputchar>
			i--;
f0106676:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106679:	eb b8                	jmp    f0106633 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f010667b:	83 fb 1f             	cmp    $0x1f,%ebx
f010667e:	66 90                	xchg   %ax,%ax
f0106680:	7e 23                	jle    f01066a5 <readline+0xa5>
f0106682:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106688:	7f 1b                	jg     f01066a5 <readline+0xa5>
			if (echoing)
f010668a:	85 ff                	test   %edi,%edi
f010668c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106690:	74 08                	je     f010669a <readline+0x9a>
				cputchar(c);
f0106692:	89 1c 24             	mov    %ebx,(%esp)
f0106695:	e8 60 a0 ff ff       	call   f01006fa <cputchar>
			buf[i++] = c;
f010669a:	88 9e 80 ca 1d f0    	mov    %bl,-0xfe23580(%esi)
f01066a0:	83 c6 01             	add    $0x1,%esi
f01066a3:	eb 8e                	jmp    f0106633 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01066a5:	83 fb 0a             	cmp    $0xa,%ebx
f01066a8:	74 05                	je     f01066af <readline+0xaf>
f01066aa:	83 fb 0d             	cmp    $0xd,%ebx
f01066ad:	75 84                	jne    f0106633 <readline+0x33>
			if (echoing)
f01066af:	85 ff                	test   %edi,%edi
f01066b1:	74 0c                	je     f01066bf <readline+0xbf>
				cputchar('\n');
f01066b3:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01066ba:	e8 3b a0 ff ff       	call   f01006fa <cputchar>
			buf[i] = 0;
f01066bf:	c6 86 80 ca 1d f0 00 	movb   $0x0,-0xfe23580(%esi)
f01066c6:	b8 80 ca 1d f0       	mov    $0xf01dca80,%eax
			return buf;
		}
	}
}
f01066cb:	83 c4 1c             	add    $0x1c,%esp
f01066ce:	5b                   	pop    %ebx
f01066cf:	5e                   	pop    %esi
f01066d0:	5f                   	pop    %edi
f01066d1:	5d                   	pop    %ebp
f01066d2:	c3                   	ret    
	...

f01066e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01066e0:	55                   	push   %ebp
f01066e1:	89 e5                	mov    %esp,%ebp
f01066e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01066e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01066eb:	80 3a 00             	cmpb   $0x0,(%edx)
f01066ee:	74 09                	je     f01066f9 <strlen+0x19>
		n++;
f01066f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01066f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01066f7:	75 f7                	jne    f01066f0 <strlen+0x10>
		n++;
	return n;
}
f01066f9:	5d                   	pop    %ebp
f01066fa:	c3                   	ret    

f01066fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01066fb:	55                   	push   %ebp
f01066fc:	89 e5                	mov    %esp,%ebp
f01066fe:	53                   	push   %ebx
f01066ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0106702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106705:	85 c9                	test   %ecx,%ecx
f0106707:	74 19                	je     f0106722 <strnlen+0x27>
f0106709:	80 3b 00             	cmpb   $0x0,(%ebx)
f010670c:	74 14                	je     f0106722 <strnlen+0x27>
f010670e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f0106713:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0106716:	39 c8                	cmp    %ecx,%eax
f0106718:	74 0d                	je     f0106727 <strnlen+0x2c>
f010671a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f010671e:	75 f3                	jne    f0106713 <strnlen+0x18>
f0106720:	eb 05                	jmp    f0106727 <strnlen+0x2c>
f0106722:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f0106727:	5b                   	pop    %ebx
f0106728:	5d                   	pop    %ebp
f0106729:	c3                   	ret    

f010672a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010672a:	55                   	push   %ebp
f010672b:	89 e5                	mov    %esp,%ebp
f010672d:	53                   	push   %ebx
f010672e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106731:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106734:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0106739:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010673d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0106740:	83 c2 01             	add    $0x1,%edx
f0106743:	84 c9                	test   %cl,%cl
f0106745:	75 f2                	jne    f0106739 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0106747:	5b                   	pop    %ebx
f0106748:	5d                   	pop    %ebp
f0106749:	c3                   	ret    

f010674a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010674a:	55                   	push   %ebp
f010674b:	89 e5                	mov    %esp,%ebp
f010674d:	53                   	push   %ebx
f010674e:	83 ec 08             	sub    $0x8,%esp
f0106751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106754:	89 1c 24             	mov    %ebx,(%esp)
f0106757:	e8 84 ff ff ff       	call   f01066e0 <strlen>
	strcpy(dst + len, src);
f010675c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010675f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106763:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0106766:	89 04 24             	mov    %eax,(%esp)
f0106769:	e8 bc ff ff ff       	call   f010672a <strcpy>
	return dst;
}
f010676e:	89 d8                	mov    %ebx,%eax
f0106770:	83 c4 08             	add    $0x8,%esp
f0106773:	5b                   	pop    %ebx
f0106774:	5d                   	pop    %ebp
f0106775:	c3                   	ret    

f0106776 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106776:	55                   	push   %ebp
f0106777:	89 e5                	mov    %esp,%ebp
f0106779:	56                   	push   %esi
f010677a:	53                   	push   %ebx
f010677b:	8b 45 08             	mov    0x8(%ebp),%eax
f010677e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106781:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106784:	85 f6                	test   %esi,%esi
f0106786:	74 18                	je     f01067a0 <strncpy+0x2a>
f0106788:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010678d:	0f b6 1a             	movzbl (%edx),%ebx
f0106790:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106793:	80 3a 01             	cmpb   $0x1,(%edx)
f0106796:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106799:	83 c1 01             	add    $0x1,%ecx
f010679c:	39 ce                	cmp    %ecx,%esi
f010679e:	77 ed                	ja     f010678d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01067a0:	5b                   	pop    %ebx
f01067a1:	5e                   	pop    %esi
f01067a2:	5d                   	pop    %ebp
f01067a3:	c3                   	ret    

f01067a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01067a4:	55                   	push   %ebp
f01067a5:	89 e5                	mov    %esp,%ebp
f01067a7:	56                   	push   %esi
f01067a8:	53                   	push   %ebx
f01067a9:	8b 75 08             	mov    0x8(%ebp),%esi
f01067ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01067af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01067b2:	89 f0                	mov    %esi,%eax
f01067b4:	85 c9                	test   %ecx,%ecx
f01067b6:	74 27                	je     f01067df <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f01067b8:	83 e9 01             	sub    $0x1,%ecx
f01067bb:	74 1d                	je     f01067da <strlcpy+0x36>
f01067bd:	0f b6 1a             	movzbl (%edx),%ebx
f01067c0:	84 db                	test   %bl,%bl
f01067c2:	74 16                	je     f01067da <strlcpy+0x36>
			*dst++ = *src++;
f01067c4:	88 18                	mov    %bl,(%eax)
f01067c6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01067c9:	83 e9 01             	sub    $0x1,%ecx
f01067cc:	74 0e                	je     f01067dc <strlcpy+0x38>
			*dst++ = *src++;
f01067ce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01067d1:	0f b6 1a             	movzbl (%edx),%ebx
f01067d4:	84 db                	test   %bl,%bl
f01067d6:	75 ec                	jne    f01067c4 <strlcpy+0x20>
f01067d8:	eb 02                	jmp    f01067dc <strlcpy+0x38>
f01067da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01067dc:	c6 00 00             	movb   $0x0,(%eax)
f01067df:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01067e1:	5b                   	pop    %ebx
f01067e2:	5e                   	pop    %esi
f01067e3:	5d                   	pop    %ebp
f01067e4:	c3                   	ret    

f01067e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01067e5:	55                   	push   %ebp
f01067e6:	89 e5                	mov    %esp,%ebp
f01067e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01067eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01067ee:	0f b6 01             	movzbl (%ecx),%eax
f01067f1:	84 c0                	test   %al,%al
f01067f3:	74 15                	je     f010680a <strcmp+0x25>
f01067f5:	3a 02                	cmp    (%edx),%al
f01067f7:	75 11                	jne    f010680a <strcmp+0x25>
		p++, q++;
f01067f9:	83 c1 01             	add    $0x1,%ecx
f01067fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01067ff:	0f b6 01             	movzbl (%ecx),%eax
f0106802:	84 c0                	test   %al,%al
f0106804:	74 04                	je     f010680a <strcmp+0x25>
f0106806:	3a 02                	cmp    (%edx),%al
f0106808:	74 ef                	je     f01067f9 <strcmp+0x14>
f010680a:	0f b6 c0             	movzbl %al,%eax
f010680d:	0f b6 12             	movzbl (%edx),%edx
f0106810:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0106812:	5d                   	pop    %ebp
f0106813:	c3                   	ret    

f0106814 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0106814:	55                   	push   %ebp
f0106815:	89 e5                	mov    %esp,%ebp
f0106817:	53                   	push   %ebx
f0106818:	8b 55 08             	mov    0x8(%ebp),%edx
f010681b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010681e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f0106821:	85 c0                	test   %eax,%eax
f0106823:	74 23                	je     f0106848 <strncmp+0x34>
f0106825:	0f b6 1a             	movzbl (%edx),%ebx
f0106828:	84 db                	test   %bl,%bl
f010682a:	74 25                	je     f0106851 <strncmp+0x3d>
f010682c:	3a 19                	cmp    (%ecx),%bl
f010682e:	75 21                	jne    f0106851 <strncmp+0x3d>
f0106830:	83 e8 01             	sub    $0x1,%eax
f0106833:	74 13                	je     f0106848 <strncmp+0x34>
		n--, p++, q++;
f0106835:	83 c2 01             	add    $0x1,%edx
f0106838:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010683b:	0f b6 1a             	movzbl (%edx),%ebx
f010683e:	84 db                	test   %bl,%bl
f0106840:	74 0f                	je     f0106851 <strncmp+0x3d>
f0106842:	3a 19                	cmp    (%ecx),%bl
f0106844:	74 ea                	je     f0106830 <strncmp+0x1c>
f0106846:	eb 09                	jmp    f0106851 <strncmp+0x3d>
f0106848:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010684d:	5b                   	pop    %ebx
f010684e:	5d                   	pop    %ebp
f010684f:	90                   	nop
f0106850:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106851:	0f b6 02             	movzbl (%edx),%eax
f0106854:	0f b6 11             	movzbl (%ecx),%edx
f0106857:	29 d0                	sub    %edx,%eax
f0106859:	eb f2                	jmp    f010684d <strncmp+0x39>

f010685b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010685b:	55                   	push   %ebp
f010685c:	89 e5                	mov    %esp,%ebp
f010685e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106861:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106865:	0f b6 10             	movzbl (%eax),%edx
f0106868:	84 d2                	test   %dl,%dl
f010686a:	74 18                	je     f0106884 <strchr+0x29>
		if (*s == c)
f010686c:	38 ca                	cmp    %cl,%dl
f010686e:	75 0a                	jne    f010687a <strchr+0x1f>
f0106870:	eb 17                	jmp    f0106889 <strchr+0x2e>
f0106872:	38 ca                	cmp    %cl,%dl
f0106874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106878:	74 0f                	je     f0106889 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010687a:	83 c0 01             	add    $0x1,%eax
f010687d:	0f b6 10             	movzbl (%eax),%edx
f0106880:	84 d2                	test   %dl,%dl
f0106882:	75 ee                	jne    f0106872 <strchr+0x17>
f0106884:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0106889:	5d                   	pop    %ebp
f010688a:	c3                   	ret    

f010688b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010688b:	55                   	push   %ebp
f010688c:	89 e5                	mov    %esp,%ebp
f010688e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106891:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106895:	0f b6 10             	movzbl (%eax),%edx
f0106898:	84 d2                	test   %dl,%dl
f010689a:	74 18                	je     f01068b4 <strfind+0x29>
		if (*s == c)
f010689c:	38 ca                	cmp    %cl,%dl
f010689e:	75 0a                	jne    f01068aa <strfind+0x1f>
f01068a0:	eb 12                	jmp    f01068b4 <strfind+0x29>
f01068a2:	38 ca                	cmp    %cl,%dl
f01068a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01068a8:	74 0a                	je     f01068b4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01068aa:	83 c0 01             	add    $0x1,%eax
f01068ad:	0f b6 10             	movzbl (%eax),%edx
f01068b0:	84 d2                	test   %dl,%dl
f01068b2:	75 ee                	jne    f01068a2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f01068b4:	5d                   	pop    %ebp
f01068b5:	c3                   	ret    

f01068b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01068b6:	55                   	push   %ebp
f01068b7:	89 e5                	mov    %esp,%ebp
f01068b9:	83 ec 0c             	sub    $0xc,%esp
f01068bc:	89 1c 24             	mov    %ebx,(%esp)
f01068bf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01068c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01068c7:	8b 7d 08             	mov    0x8(%ebp),%edi
f01068ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01068cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01068d0:	85 c9                	test   %ecx,%ecx
f01068d2:	74 30                	je     f0106904 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01068d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01068da:	75 25                	jne    f0106901 <memset+0x4b>
f01068dc:	f6 c1 03             	test   $0x3,%cl
f01068df:	75 20                	jne    f0106901 <memset+0x4b>
		c &= 0xFF;
f01068e1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01068e4:	89 d3                	mov    %edx,%ebx
f01068e6:	c1 e3 08             	shl    $0x8,%ebx
f01068e9:	89 d6                	mov    %edx,%esi
f01068eb:	c1 e6 18             	shl    $0x18,%esi
f01068ee:	89 d0                	mov    %edx,%eax
f01068f0:	c1 e0 10             	shl    $0x10,%eax
f01068f3:	09 f0                	or     %esi,%eax
f01068f5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f01068f7:	09 d8                	or     %ebx,%eax
f01068f9:	c1 e9 02             	shr    $0x2,%ecx
f01068fc:	fc                   	cld    
f01068fd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01068ff:	eb 03                	jmp    f0106904 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0106901:	fc                   	cld    
f0106902:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0106904:	89 f8                	mov    %edi,%eax
f0106906:	8b 1c 24             	mov    (%esp),%ebx
f0106909:	8b 74 24 04          	mov    0x4(%esp),%esi
f010690d:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0106911:	89 ec                	mov    %ebp,%esp
f0106913:	5d                   	pop    %ebp
f0106914:	c3                   	ret    

f0106915 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0106915:	55                   	push   %ebp
f0106916:	89 e5                	mov    %esp,%ebp
f0106918:	83 ec 08             	sub    $0x8,%esp
f010691b:	89 34 24             	mov    %esi,(%esp)
f010691e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0106922:	8b 45 08             	mov    0x8(%ebp),%eax
f0106925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f0106928:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f010692b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f010692d:	39 c6                	cmp    %eax,%esi
f010692f:	73 35                	jae    f0106966 <memmove+0x51>
f0106931:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0106934:	39 d0                	cmp    %edx,%eax
f0106936:	73 2e                	jae    f0106966 <memmove+0x51>
		s += n;
		d += n;
f0106938:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010693a:	f6 c2 03             	test   $0x3,%dl
f010693d:	75 1b                	jne    f010695a <memmove+0x45>
f010693f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106945:	75 13                	jne    f010695a <memmove+0x45>
f0106947:	f6 c1 03             	test   $0x3,%cl
f010694a:	75 0e                	jne    f010695a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f010694c:	83 ef 04             	sub    $0x4,%edi
f010694f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106952:	c1 e9 02             	shr    $0x2,%ecx
f0106955:	fd                   	std    
f0106956:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106958:	eb 09                	jmp    f0106963 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010695a:	83 ef 01             	sub    $0x1,%edi
f010695d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0106960:	fd                   	std    
f0106961:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106963:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106964:	eb 20                	jmp    f0106986 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106966:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010696c:	75 15                	jne    f0106983 <memmove+0x6e>
f010696e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106974:	75 0d                	jne    f0106983 <memmove+0x6e>
f0106976:	f6 c1 03             	test   $0x3,%cl
f0106979:	75 08                	jne    f0106983 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f010697b:	c1 e9 02             	shr    $0x2,%ecx
f010697e:	fc                   	cld    
f010697f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106981:	eb 03                	jmp    f0106986 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106983:	fc                   	cld    
f0106984:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106986:	8b 34 24             	mov    (%esp),%esi
f0106989:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010698d:	89 ec                	mov    %ebp,%esp
f010698f:	5d                   	pop    %ebp
f0106990:	c3                   	ret    

f0106991 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0106991:	55                   	push   %ebp
f0106992:	89 e5                	mov    %esp,%ebp
f0106994:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106997:	8b 45 10             	mov    0x10(%ebp),%eax
f010699a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010699e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01069a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01069a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01069a8:	89 04 24             	mov    %eax,(%esp)
f01069ab:	e8 65 ff ff ff       	call   f0106915 <memmove>
}
f01069b0:	c9                   	leave  
f01069b1:	c3                   	ret    

f01069b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01069b2:	55                   	push   %ebp
f01069b3:	89 e5                	mov    %esp,%ebp
f01069b5:	57                   	push   %edi
f01069b6:	56                   	push   %esi
f01069b7:	53                   	push   %ebx
f01069b8:	8b 75 08             	mov    0x8(%ebp),%esi
f01069bb:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01069be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01069c1:	85 c9                	test   %ecx,%ecx
f01069c3:	74 36                	je     f01069fb <memcmp+0x49>
		if (*s1 != *s2)
f01069c5:	0f b6 06             	movzbl (%esi),%eax
f01069c8:	0f b6 1f             	movzbl (%edi),%ebx
f01069cb:	38 d8                	cmp    %bl,%al
f01069cd:	74 20                	je     f01069ef <memcmp+0x3d>
f01069cf:	eb 14                	jmp    f01069e5 <memcmp+0x33>
f01069d1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f01069d6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f01069db:	83 c2 01             	add    $0x1,%edx
f01069de:	83 e9 01             	sub    $0x1,%ecx
f01069e1:	38 d8                	cmp    %bl,%al
f01069e3:	74 12                	je     f01069f7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f01069e5:	0f b6 c0             	movzbl %al,%eax
f01069e8:	0f b6 db             	movzbl %bl,%ebx
f01069eb:	29 d8                	sub    %ebx,%eax
f01069ed:	eb 11                	jmp    f0106a00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01069ef:	83 e9 01             	sub    $0x1,%ecx
f01069f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01069f7:	85 c9                	test   %ecx,%ecx
f01069f9:	75 d6                	jne    f01069d1 <memcmp+0x1f>
f01069fb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0106a00:	5b                   	pop    %ebx
f0106a01:	5e                   	pop    %esi
f0106a02:	5f                   	pop    %edi
f0106a03:	5d                   	pop    %ebp
f0106a04:	c3                   	ret    

f0106a05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106a05:	55                   	push   %ebp
f0106a06:	89 e5                	mov    %esp,%ebp
f0106a08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106a0b:	89 c2                	mov    %eax,%edx
f0106a0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106a10:	39 d0                	cmp    %edx,%eax
f0106a12:	73 15                	jae    f0106a29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106a14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0106a18:	38 08                	cmp    %cl,(%eax)
f0106a1a:	75 06                	jne    f0106a22 <memfind+0x1d>
f0106a1c:	eb 0b                	jmp    f0106a29 <memfind+0x24>
f0106a1e:	38 08                	cmp    %cl,(%eax)
f0106a20:	74 07                	je     f0106a29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106a22:	83 c0 01             	add    $0x1,%eax
f0106a25:	39 c2                	cmp    %eax,%edx
f0106a27:	77 f5                	ja     f0106a1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106a29:	5d                   	pop    %ebp
f0106a2a:	c3                   	ret    

f0106a2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106a2b:	55                   	push   %ebp
f0106a2c:	89 e5                	mov    %esp,%ebp
f0106a2e:	57                   	push   %edi
f0106a2f:	56                   	push   %esi
f0106a30:	53                   	push   %ebx
f0106a31:	83 ec 04             	sub    $0x4,%esp
f0106a34:	8b 55 08             	mov    0x8(%ebp),%edx
f0106a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106a3a:	0f b6 02             	movzbl (%edx),%eax
f0106a3d:	3c 20                	cmp    $0x20,%al
f0106a3f:	74 04                	je     f0106a45 <strtol+0x1a>
f0106a41:	3c 09                	cmp    $0x9,%al
f0106a43:	75 0e                	jne    f0106a53 <strtol+0x28>
		s++;
f0106a45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106a48:	0f b6 02             	movzbl (%edx),%eax
f0106a4b:	3c 20                	cmp    $0x20,%al
f0106a4d:	74 f6                	je     f0106a45 <strtol+0x1a>
f0106a4f:	3c 09                	cmp    $0x9,%al
f0106a51:	74 f2                	je     f0106a45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106a53:	3c 2b                	cmp    $0x2b,%al
f0106a55:	75 0c                	jne    f0106a63 <strtol+0x38>
		s++;
f0106a57:	83 c2 01             	add    $0x1,%edx
f0106a5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0106a61:	eb 15                	jmp    f0106a78 <strtol+0x4d>
	else if (*s == '-')
f0106a63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0106a6a:	3c 2d                	cmp    $0x2d,%al
f0106a6c:	75 0a                	jne    f0106a78 <strtol+0x4d>
		s++, neg = 1;
f0106a6e:	83 c2 01             	add    $0x1,%edx
f0106a71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106a78:	85 db                	test   %ebx,%ebx
f0106a7a:	0f 94 c0             	sete   %al
f0106a7d:	74 05                	je     f0106a84 <strtol+0x59>
f0106a7f:	83 fb 10             	cmp    $0x10,%ebx
f0106a82:	75 18                	jne    f0106a9c <strtol+0x71>
f0106a84:	80 3a 30             	cmpb   $0x30,(%edx)
f0106a87:	75 13                	jne    f0106a9c <strtol+0x71>
f0106a89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106a8d:	8d 76 00             	lea    0x0(%esi),%esi
f0106a90:	75 0a                	jne    f0106a9c <strtol+0x71>
		s += 2, base = 16;
f0106a92:	83 c2 02             	add    $0x2,%edx
f0106a95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106a9a:	eb 15                	jmp    f0106ab1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106a9c:	84 c0                	test   %al,%al
f0106a9e:	66 90                	xchg   %ax,%ax
f0106aa0:	74 0f                	je     f0106ab1 <strtol+0x86>
f0106aa2:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106aa7:	80 3a 30             	cmpb   $0x30,(%edx)
f0106aaa:	75 05                	jne    f0106ab1 <strtol+0x86>
		s++, base = 8;
f0106aac:	83 c2 01             	add    $0x1,%edx
f0106aaf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106ab1:	b8 00 00 00 00       	mov    $0x0,%eax
f0106ab6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106ab8:	0f b6 0a             	movzbl (%edx),%ecx
f0106abb:	89 cf                	mov    %ecx,%edi
f0106abd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106ac0:	80 fb 09             	cmp    $0x9,%bl
f0106ac3:	77 08                	ja     f0106acd <strtol+0xa2>
			dig = *s - '0';
f0106ac5:	0f be c9             	movsbl %cl,%ecx
f0106ac8:	83 e9 30             	sub    $0x30,%ecx
f0106acb:	eb 1e                	jmp    f0106aeb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0106acd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0106ad0:	80 fb 19             	cmp    $0x19,%bl
f0106ad3:	77 08                	ja     f0106add <strtol+0xb2>
			dig = *s - 'a' + 10;
f0106ad5:	0f be c9             	movsbl %cl,%ecx
f0106ad8:	83 e9 57             	sub    $0x57,%ecx
f0106adb:	eb 0e                	jmp    f0106aeb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0106add:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0106ae0:	80 fb 19             	cmp    $0x19,%bl
f0106ae3:	77 15                	ja     f0106afa <strtol+0xcf>
			dig = *s - 'A' + 10;
f0106ae5:	0f be c9             	movsbl %cl,%ecx
f0106ae8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106aeb:	39 f1                	cmp    %esi,%ecx
f0106aed:	7d 0b                	jge    f0106afa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0106aef:	83 c2 01             	add    $0x1,%edx
f0106af2:	0f af c6             	imul   %esi,%eax
f0106af5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0106af8:	eb be                	jmp    f0106ab8 <strtol+0x8d>
f0106afa:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0106afc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106b00:	74 05                	je     f0106b07 <strtol+0xdc>
		*endptr = (char *) s;
f0106b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106b05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106b07:	89 ca                	mov    %ecx,%edx
f0106b09:	f7 da                	neg    %edx
f0106b0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0106b0f:	0f 45 c2             	cmovne %edx,%eax
}
f0106b12:	83 c4 04             	add    $0x4,%esp
f0106b15:	5b                   	pop    %ebx
f0106b16:	5e                   	pop    %esi
f0106b17:	5f                   	pop    %edi
f0106b18:	5d                   	pop    %ebp
f0106b19:	c3                   	ret    
	...

f0106b1c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106b1c:	fa                   	cli    

	xorw    %ax, %ax
f0106b1d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106b1f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106b21:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106b23:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106b25:	0f 01 16             	lgdtl  (%esi)
f0106b28:	74 70                	je     f0106b9a <mpentry_end+0x4>
	movl    %cr0, %eax
f0106b2a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106b2d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106b31:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106b34:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106b3a:	08 00                	or     %al,(%eax)

f0106b3c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106b3c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106b40:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106b42:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106b44:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106b46:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106b4a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106b4c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106b4e:	b8 00 00 12 00       	mov    $0x120000,%eax
	movl    %eax, %cr3
f0106b53:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106b56:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106b59:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106b5e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0106b61:	8b 25 84 ce 1d f0    	mov    0xf01dce84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106b67:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106b6c:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f0106b71:	ff d0                	call   *%eax

f0106b73 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106b73:	eb fe                	jmp    f0106b73 <spin>
f0106b75:	8d 76 00             	lea    0x0(%esi),%esi

f0106b78 <gdt>:
	...
f0106b80:	ff                   	(bad)  
f0106b81:	ff 00                	incl   (%eax)
f0106b83:	00 00                	add    %al,(%eax)
f0106b85:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106b8c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106b90 <gdtdesc>:
f0106b90:	17                   	pop    %ss
f0106b91:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106b96 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106b96:	90                   	nop
	...

f0106ba0 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106ba0:	55                   	push   %ebp
f0106ba1:	89 e5                	mov    %esp,%ebp
f0106ba3:	56                   	push   %esi
f0106ba4:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106ba5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106baa:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106baf:	85 d2                	test   %edx,%edx
f0106bb1:	7e 0d                	jle    f0106bc0 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0106bb3:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106bb7:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106bb9:	83 c1 01             	add    $0x1,%ecx
f0106bbc:	39 d1                	cmp    %edx,%ecx
f0106bbe:	75 f3                	jne    f0106bb3 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106bc0:	89 d8                	mov    %ebx,%eax
f0106bc2:	5b                   	pop    %ebx
f0106bc3:	5e                   	pop    %esi
f0106bc4:	5d                   	pop    %ebp
f0106bc5:	c3                   	ret    

f0106bc6 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106bc6:	55                   	push   %ebp
f0106bc7:	89 e5                	mov    %esp,%ebp
f0106bc9:	56                   	push   %esi
f0106bca:	53                   	push   %ebx
f0106bcb:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106bce:	8b 0d 88 ce 1d f0    	mov    0xf01dce88,%ecx
f0106bd4:	89 c3                	mov    %eax,%ebx
f0106bd6:	c1 eb 0c             	shr    $0xc,%ebx
f0106bd9:	39 cb                	cmp    %ecx,%ebx
f0106bdb:	72 20                	jb     f0106bfd <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106bdd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106be1:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0106be8:	f0 
f0106be9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106bf0:	00 
f0106bf1:	c7 04 24 fd 91 10 f0 	movl   $0xf01091fd,(%esp)
f0106bf8:	e8 88 94 ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106bfd:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106c00:	89 f2                	mov    %esi,%edx
f0106c02:	c1 ea 0c             	shr    $0xc,%edx
f0106c05:	39 d1                	cmp    %edx,%ecx
f0106c07:	77 20                	ja     f0106c29 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106c09:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106c0d:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0106c14:	f0 
f0106c15:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106c1c:	00 
f0106c1d:	c7 04 24 fd 91 10 f0 	movl   $0xf01091fd,(%esp)
f0106c24:	e8 5c 94 ff ff       	call   f0100085 <_panic>
f0106c29:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0106c2f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106c35:	39 f3                	cmp    %esi,%ebx
f0106c37:	73 33                	jae    f0106c6c <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106c39:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106c40:	00 
f0106c41:	c7 44 24 04 0d 92 10 	movl   $0xf010920d,0x4(%esp)
f0106c48:	f0 
f0106c49:	89 1c 24             	mov    %ebx,(%esp)
f0106c4c:	e8 61 fd ff ff       	call   f01069b2 <memcmp>
f0106c51:	85 c0                	test   %eax,%eax
f0106c53:	75 10                	jne    f0106c65 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106c55:	ba 10 00 00 00       	mov    $0x10,%edx
f0106c5a:	89 d8                	mov    %ebx,%eax
f0106c5c:	e8 3f ff ff ff       	call   f0106ba0 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106c61:	84 c0                	test   %al,%al
f0106c63:	74 0c                	je     f0106c71 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106c65:	83 c3 10             	add    $0x10,%ebx
f0106c68:	39 de                	cmp    %ebx,%esi
f0106c6a:	77 cd                	ja     f0106c39 <mpsearch1+0x73>
f0106c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f0106c71:	89 d8                	mov    %ebx,%eax
f0106c73:	83 c4 10             	add    $0x10,%esp
f0106c76:	5b                   	pop    %ebx
f0106c77:	5e                   	pop    %esi
f0106c78:	5d                   	pop    %ebp
f0106c79:	c3                   	ret    

f0106c7a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106c7a:	55                   	push   %ebp
f0106c7b:	89 e5                	mov    %esp,%ebp
f0106c7d:	57                   	push   %edi
f0106c7e:	56                   	push   %esi
f0106c7f:	53                   	push   %ebx
f0106c80:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106c83:	c7 05 c0 d3 1d f0 20 	movl   $0xf01dd020,0xf01dd3c0
f0106c8a:	d0 1d f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106c8d:	83 3d 88 ce 1d f0 00 	cmpl   $0x0,0xf01dce88
f0106c94:	75 24                	jne    f0106cba <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106c96:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106c9d:	00 
f0106c9e:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0106ca5:	f0 
f0106ca6:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106cad:	00 
f0106cae:	c7 04 24 fd 91 10 f0 	movl   $0xf01091fd,(%esp)
f0106cb5:	e8 cb 93 ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106cba:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106cc1:	85 c0                	test   %eax,%eax
f0106cc3:	74 16                	je     f0106cdb <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106cc5:	c1 e0 04             	shl    $0x4,%eax
f0106cc8:	ba 00 04 00 00       	mov    $0x400,%edx
f0106ccd:	e8 f4 fe ff ff       	call   f0106bc6 <mpsearch1>
f0106cd2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106cd5:	85 c0                	test   %eax,%eax
f0106cd7:	75 3c                	jne    f0106d15 <mp_init+0x9b>
f0106cd9:	eb 20                	jmp    f0106cfb <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106cdb:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106ce2:	c1 e0 0a             	shl    $0xa,%eax
f0106ce5:	2d 00 04 00 00       	sub    $0x400,%eax
f0106cea:	ba 00 04 00 00       	mov    $0x400,%edx
f0106cef:	e8 d2 fe ff ff       	call   f0106bc6 <mpsearch1>
f0106cf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106cf7:	85 c0                	test   %eax,%eax
f0106cf9:	75 1a                	jne    f0106d15 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106cfb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106d00:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106d05:	e8 bc fe ff ff       	call   f0106bc6 <mpsearch1>
f0106d0a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106d0d:	85 c0                	test   %eax,%eax
f0106d0f:	0f 84 28 02 00 00    	je     f0106f3d <mp_init+0x2c3>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106d15:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106d18:	8b 78 04             	mov    0x4(%eax),%edi
f0106d1b:	85 ff                	test   %edi,%edi
f0106d1d:	74 06                	je     f0106d25 <mp_init+0xab>
f0106d1f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106d23:	74 11                	je     f0106d36 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106d25:	c7 04 24 70 90 10 f0 	movl   $0xf0109070,(%esp)
f0106d2c:	e8 ca d6 ff ff       	call   f01043fb <cprintf>
f0106d31:	e9 07 02 00 00       	jmp    f0106f3d <mp_init+0x2c3>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106d36:	89 f8                	mov    %edi,%eax
f0106d38:	c1 e8 0c             	shr    $0xc,%eax
f0106d3b:	3b 05 88 ce 1d f0    	cmp    0xf01dce88,%eax
f0106d41:	72 20                	jb     f0106d63 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d43:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106d47:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0106d4e:	f0 
f0106d4f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106d56:	00 
f0106d57:	c7 04 24 fd 91 10 f0 	movl   $0xf01091fd,(%esp)
f0106d5e:	e8 22 93 ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0106d63:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106d69:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106d70:	00 
f0106d71:	c7 44 24 04 12 92 10 	movl   $0xf0109212,0x4(%esp)
f0106d78:	f0 
f0106d79:	89 3c 24             	mov    %edi,(%esp)
f0106d7c:	e8 31 fc ff ff       	call   f01069b2 <memcmp>
f0106d81:	85 c0                	test   %eax,%eax
f0106d83:	74 11                	je     f0106d96 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106d85:	c7 04 24 a0 90 10 f0 	movl   $0xf01090a0,(%esp)
f0106d8c:	e8 6a d6 ff ff       	call   f01043fb <cprintf>
f0106d91:	e9 a7 01 00 00       	jmp    f0106f3d <mp_init+0x2c3>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106d96:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f0106d9a:	89 f8                	mov    %edi,%eax
f0106d9c:	e8 ff fd ff ff       	call   f0106ba0 <sum>
f0106da1:	84 c0                	test   %al,%al
f0106da3:	74 11                	je     f0106db6 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106da5:	c7 04 24 d4 90 10 f0 	movl   $0xf01090d4,(%esp)
f0106dac:	e8 4a d6 ff ff       	call   f01043fb <cprintf>
f0106db1:	e9 87 01 00 00       	jmp    f0106f3d <mp_init+0x2c3>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106db6:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106dba:	3c 01                	cmp    $0x1,%al
f0106dbc:	74 1c                	je     f0106dda <mp_init+0x160>
f0106dbe:	3c 04                	cmp    $0x4,%al
f0106dc0:	74 18                	je     f0106dda <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106dc2:	0f b6 c0             	movzbl %al,%eax
f0106dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106dc9:	c7 04 24 f8 90 10 f0 	movl   $0xf01090f8,(%esp)
f0106dd0:	e8 26 d6 ff ff       	call   f01043fb <cprintf>
f0106dd5:	e9 63 01 00 00       	jmp    f0106f3d <mp_init+0x2c3>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106dda:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0106dde:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0106de2:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0106de5:	e8 b6 fd ff ff       	call   f0106ba0 <sum>
f0106dea:	3a 47 2a             	cmp    0x2a(%edi),%al
f0106ded:	74 11                	je     f0106e00 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106def:	c7 04 24 18 91 10 f0 	movl   $0xf0109118,(%esp)
f0106df6:	e8 00 d6 ff ff       	call   f01043fb <cprintf>
f0106dfb:	e9 3d 01 00 00       	jmp    f0106f3d <mp_init+0x2c3>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106e00:	85 ff                	test   %edi,%edi
f0106e02:	0f 84 35 01 00 00    	je     f0106f3d <mp_init+0x2c3>
		return;
	ismp = 1;
f0106e08:	c7 05 00 d0 1d f0 01 	movl   $0x1,0xf01dd000
f0106e0f:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0106e12:	8b 47 24             	mov    0x24(%edi),%eax
f0106e15:	a3 00 e0 21 f0       	mov    %eax,0xf021e000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106e1a:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0106e1d:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106e22:	0f 84 96 00 00 00    	je     f0106ebe <mp_init+0x244>
f0106e28:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0106e2d:	0f b6 03             	movzbl (%ebx),%eax
f0106e30:	84 c0                	test   %al,%al
f0106e32:	74 06                	je     f0106e3a <mp_init+0x1c0>
f0106e34:	3c 04                	cmp    $0x4,%al
f0106e36:	77 56                	ja     f0106e8e <mp_init+0x214>
f0106e38:	eb 4f                	jmp    f0106e89 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
f0106e3a:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0106e3c:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0106e40:	74 11                	je     f0106e53 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0106e42:	6b 05 c4 d3 1d f0 74 	imul   $0x74,0xf01dd3c4,%eax
f0106e49:	05 20 d0 1d f0       	add    $0xf01dd020,%eax
f0106e4e:	a3 c0 d3 1d f0       	mov    %eax,0xf01dd3c0
			if (ncpu < NCPU) {
f0106e53:	a1 c4 d3 1d f0       	mov    0xf01dd3c4,%eax
f0106e58:	83 f8 07             	cmp    $0x7,%eax
f0106e5b:	7f 13                	jg     f0106e70 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f0106e5d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106e60:	88 82 20 d0 1d f0    	mov    %al,-0xfe22fe0(%edx)
				ncpu++;
f0106e66:	83 c0 01             	add    $0x1,%eax
f0106e69:	a3 c4 d3 1d f0       	mov    %eax,0xf01dd3c4
f0106e6e:	eb 14                	jmp    f0106e84 <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106e70:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0106e74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e78:	c7 04 24 48 91 10 f0 	movl   $0xf0109148,(%esp)
f0106e7f:	e8 77 d5 ff ff       	call   f01043fb <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106e84:	83 c3 14             	add    $0x14,%ebx
			continue;
f0106e87:	eb 26                	jmp    f0106eaf <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106e89:	83 c3 08             	add    $0x8,%ebx
			continue;
f0106e8c:	eb 21                	jmp    f0106eaf <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106e8e:	0f b6 c0             	movzbl %al,%eax
f0106e91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e95:	c7 04 24 70 91 10 f0 	movl   $0xf0109170,(%esp)
f0106e9c:	e8 5a d5 ff ff       	call   f01043fb <cprintf>
			ismp = 0;
f0106ea1:	c7 05 00 d0 1d f0 00 	movl   $0x0,0xf01dd000
f0106ea8:	00 00 00 
			i = conf->entry;
f0106eab:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106eaf:	83 c6 01             	add    $0x1,%esi
f0106eb2:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106eb6:	39 f0                	cmp    %esi,%eax
f0106eb8:	0f 87 6f ff ff ff    	ja     f0106e2d <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106ebe:	a1 c0 d3 1d f0       	mov    0xf01dd3c0,%eax
f0106ec3:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106eca:	83 3d 00 d0 1d f0 00 	cmpl   $0x0,0xf01dd000
f0106ed1:	75 22                	jne    f0106ef5 <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106ed3:	c7 05 c4 d3 1d f0 01 	movl   $0x1,0xf01dd3c4
f0106eda:	00 00 00 
		lapic = NULL;
f0106edd:	c7 05 00 e0 21 f0 00 	movl   $0x0,0xf021e000
f0106ee4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106ee7:	c7 04 24 90 91 10 f0 	movl   $0xf0109190,(%esp)
f0106eee:	e8 08 d5 ff ff       	call   f01043fb <cprintf>
		return;
f0106ef3:	eb 48                	jmp    f0106f3d <mp_init+0x2c3>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106ef5:	a1 c4 d3 1d f0       	mov    0xf01dd3c4,%eax
f0106efa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106efe:	a1 c0 d3 1d f0       	mov    0xf01dd3c0,%eax
f0106f03:	0f b6 00             	movzbl (%eax),%eax
f0106f06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f0a:	c7 04 24 17 92 10 f0 	movl   $0xf0109217,(%esp)
f0106f11:	e8 e5 d4 ff ff       	call   f01043fb <cprintf>

	if (mp->imcrp) {
f0106f16:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106f19:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106f1d:	74 1e                	je     f0106f3d <mp_init+0x2c3>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106f1f:	c7 04 24 bc 91 10 f0 	movl   $0xf01091bc,(%esp)
f0106f26:	e8 d0 d4 ff ff       	call   f01043fb <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106f2b:	ba 22 00 00 00       	mov    $0x22,%edx
f0106f30:	b8 70 00 00 00       	mov    $0x70,%eax
f0106f35:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106f36:	b2 23                	mov    $0x23,%dl
f0106f38:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106f39:	83 c8 01             	or     $0x1,%eax
f0106f3c:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106f3d:	83 c4 2c             	add    $0x2c,%esp
f0106f40:	5b                   	pop    %ebx
f0106f41:	5e                   	pop    %esi
f0106f42:	5f                   	pop    %edi
f0106f43:	5d                   	pop    %ebp
f0106f44:	c3                   	ret    
f0106f45:	00 00                	add    %al,(%eax)
	...

f0106f48 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f0106f48:	55                   	push   %ebp
f0106f49:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106f4b:	c1 e0 02             	shl    $0x2,%eax
f0106f4e:	03 05 00 e0 21 f0    	add    0xf021e000,%eax
f0106f54:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106f56:	a1 00 e0 21 f0       	mov    0xf021e000,%eax
f0106f5b:	83 c0 20             	add    $0x20,%eax
f0106f5e:	8b 00                	mov    (%eax),%eax
}
f0106f60:	5d                   	pop    %ebp
f0106f61:	c3                   	ret    

f0106f62 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106f62:	55                   	push   %ebp
f0106f63:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106f65:	8b 15 00 e0 21 f0    	mov    0xf021e000,%edx
f0106f6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0106f70:	85 d2                	test   %edx,%edx
f0106f72:	74 08                	je     f0106f7c <cpunum+0x1a>
		return lapic[ID] >> 24;
f0106f74:	83 c2 20             	add    $0x20,%edx
f0106f77:	8b 02                	mov    (%edx),%eax
f0106f79:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0106f7c:	5d                   	pop    %ebp
f0106f7d:	c3                   	ret    

f0106f7e <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106f7e:	55                   	push   %ebp
f0106f7f:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f0106f81:	83 3d 00 e0 21 f0 00 	cmpl   $0x0,0xf021e000
f0106f88:	0f 84 0b 01 00 00    	je     f0107099 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106f8e:	ba 27 01 00 00       	mov    $0x127,%edx
f0106f93:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106f98:	e8 ab ff ff ff       	call   f0106f48 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0106f9d:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106fa2:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106fa7:	e8 9c ff ff ff       	call   f0106f48 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106fac:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106fb1:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106fb6:	e8 8d ff ff ff       	call   f0106f48 <lapicw>
	lapicw(TICR, 10000000); 
f0106fbb:	ba 80 96 98 00       	mov    $0x989680,%edx
f0106fc0:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106fc5:	e8 7e ff ff ff       	call   f0106f48 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106fca:	e8 93 ff ff ff       	call   f0106f62 <cpunum>
f0106fcf:	6b c0 74             	imul   $0x74,%eax,%eax
f0106fd2:	05 20 d0 1d f0       	add    $0xf01dd020,%eax
f0106fd7:	3b 05 c0 d3 1d f0    	cmp    0xf01dd3c0,%eax
f0106fdd:	74 0f                	je     f0106fee <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f0106fdf:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106fe4:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0106fe9:	e8 5a ff ff ff       	call   f0106f48 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0106fee:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106ff3:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106ff8:	e8 4b ff ff ff       	call   f0106f48 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0106ffd:	a1 00 e0 21 f0       	mov    0xf021e000,%eax
f0107002:	83 c0 30             	add    $0x30,%eax
f0107005:	8b 00                	mov    (%eax),%eax
f0107007:	c1 e8 10             	shr    $0x10,%eax
f010700a:	3c 03                	cmp    $0x3,%al
f010700c:	76 0f                	jbe    f010701d <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f010700e:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107013:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0107018:	e8 2b ff ff ff       	call   f0106f48 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010701d:	ba 33 00 00 00       	mov    $0x33,%edx
f0107022:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0107027:	e8 1c ff ff ff       	call   f0106f48 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010702c:	ba 00 00 00 00       	mov    $0x0,%edx
f0107031:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0107036:	e8 0d ff ff ff       	call   f0106f48 <lapicw>
	lapicw(ESR, 0);
f010703b:	ba 00 00 00 00       	mov    $0x0,%edx
f0107040:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0107045:	e8 fe fe ff ff       	call   f0106f48 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010704a:	ba 00 00 00 00       	mov    $0x0,%edx
f010704f:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0107054:	e8 ef fe ff ff       	call   f0106f48 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0107059:	ba 00 00 00 00       	mov    $0x0,%edx
f010705e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107063:	e8 e0 fe ff ff       	call   f0106f48 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0107068:	ba 00 85 08 00       	mov    $0x88500,%edx
f010706d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107072:	e8 d1 fe ff ff       	call   f0106f48 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0107077:	8b 15 00 e0 21 f0    	mov    0xf021e000,%edx
f010707d:	81 c2 00 03 00 00    	add    $0x300,%edx
f0107083:	8b 02                	mov    (%edx),%eax
f0107085:	f6 c4 10             	test   $0x10,%ah
f0107088:	75 f9                	jne    f0107083 <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010708a:	ba 00 00 00 00       	mov    $0x0,%edx
f010708f:	b8 20 00 00 00       	mov    $0x20,%eax
f0107094:	e8 af fe ff ff       	call   f0106f48 <lapicw>
}
f0107099:	5d                   	pop    %ebp
f010709a:	c3                   	ret    

f010709b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010709b:	55                   	push   %ebp
f010709c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010709e:	83 3d 00 e0 21 f0 00 	cmpl   $0x0,0xf021e000
f01070a5:	74 0f                	je     f01070b6 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01070a7:	ba 00 00 00 00       	mov    $0x0,%edx
f01070ac:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01070b1:	e8 92 fe ff ff       	call   f0106f48 <lapicw>
}
f01070b6:	5d                   	pop    %ebp
f01070b7:	c3                   	ret    

f01070b8 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f01070b8:	55                   	push   %ebp
f01070b9:	89 e5                	mov    %esp,%ebp
}
f01070bb:	5d                   	pop    %ebp
f01070bc:	c3                   	ret    

f01070bd <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f01070bd:	55                   	push   %ebp
f01070be:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01070c0:	8b 55 08             	mov    0x8(%ebp),%edx
f01070c3:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01070c9:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01070ce:	e8 75 fe ff ff       	call   f0106f48 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01070d3:	8b 15 00 e0 21 f0    	mov    0xf021e000,%edx
f01070d9:	81 c2 00 03 00 00    	add    $0x300,%edx
f01070df:	8b 02                	mov    (%edx),%eax
f01070e1:	f6 c4 10             	test   $0x10,%ah
f01070e4:	75 f9                	jne    f01070df <lapic_ipi+0x22>
		;
}
f01070e6:	5d                   	pop    %ebp
f01070e7:	c3                   	ret    

f01070e8 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01070e8:	55                   	push   %ebp
f01070e9:	89 e5                	mov    %esp,%ebp
f01070eb:	56                   	push   %esi
f01070ec:	53                   	push   %ebx
f01070ed:	83 ec 10             	sub    $0x10,%esp
f01070f0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01070f3:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f01070f7:	ba 70 00 00 00       	mov    $0x70,%edx
f01070fc:	b8 0f 00 00 00       	mov    $0xf,%eax
f0107101:	ee                   	out    %al,(%dx)
f0107102:	b2 71                	mov    $0x71,%dl
f0107104:	b8 0a 00 00 00       	mov    $0xa,%eax
f0107109:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010710a:	83 3d 88 ce 1d f0 00 	cmpl   $0x0,0xf01dce88
f0107111:	75 24                	jne    f0107137 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0107113:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f010711a:	00 
f010711b:	c7 44 24 08 80 77 10 	movl   $0xf0107780,0x8(%esp)
f0107122:	f0 
f0107123:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f010712a:	00 
f010712b:	c7 04 24 34 92 10 f0 	movl   $0xf0109234,(%esp)
f0107132:	e8 4e 8f ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0107137:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f010713e:	00 00 
	wrv[1] = addr >> 4;
f0107140:	89 f0                	mov    %esi,%eax
f0107142:	c1 e8 04             	shr    $0x4,%eax
f0107145:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f010714b:	c1 e3 18             	shl    $0x18,%ebx
f010714e:	89 da                	mov    %ebx,%edx
f0107150:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107155:	e8 ee fd ff ff       	call   f0106f48 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010715a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010715f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107164:	e8 df fd ff ff       	call   f0106f48 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0107169:	ba 00 85 00 00       	mov    $0x8500,%edx
f010716e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107173:	e8 d0 fd ff ff       	call   f0106f48 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107178:	c1 ee 0c             	shr    $0xc,%esi
f010717b:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107181:	89 da                	mov    %ebx,%edx
f0107183:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107188:	e8 bb fd ff ff       	call   f0106f48 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010718d:	89 f2                	mov    %esi,%edx
f010718f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107194:	e8 af fd ff ff       	call   f0106f48 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107199:	89 da                	mov    %ebx,%edx
f010719b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01071a0:	e8 a3 fd ff ff       	call   f0106f48 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01071a5:	89 f2                	mov    %esi,%edx
f01071a7:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01071ac:	e8 97 fd ff ff       	call   f0106f48 <lapicw>
		microdelay(200);
	}
}
f01071b1:	83 c4 10             	add    $0x10,%esp
f01071b4:	5b                   	pop    %ebx
f01071b5:	5e                   	pop    %esi
f01071b6:	5d                   	pop    %ebp
f01071b7:	c3                   	ret    
	...

f01071c0 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01071c0:	55                   	push   %ebp
f01071c1:	89 e5                	mov    %esp,%ebp
f01071c3:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01071c6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01071cc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01071cf:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01071d2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01071d9:	5d                   	pop    %ebp
f01071da:	c3                   	ret    

f01071db <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01071db:	55                   	push   %ebp
f01071dc:	89 e5                	mov    %esp,%ebp
f01071de:	53                   	push   %ebx
f01071df:	83 ec 04             	sub    $0x4,%esp
f01071e2:	89 c2                	mov    %eax,%edx
	return lock->locked && lock->cpu == thiscpu;
f01071e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01071e9:	83 3a 00             	cmpl   $0x0,(%edx)
f01071ec:	74 18                	je     f0107206 <holding+0x2b>
f01071ee:	8b 5a 08             	mov    0x8(%edx),%ebx
f01071f1:	e8 6c fd ff ff       	call   f0106f62 <cpunum>
f01071f6:	6b c0 74             	imul   $0x74,%eax,%eax
f01071f9:	05 20 d0 1d f0       	add    $0xf01dd020,%eax
f01071fe:	39 c3                	cmp    %eax,%ebx
f0107200:	0f 94 c0             	sete   %al
f0107203:	0f b6 c0             	movzbl %al,%eax
}
f0107206:	83 c4 04             	add    $0x4,%esp
f0107209:	5b                   	pop    %ebx
f010720a:	5d                   	pop    %ebp
f010720b:	c3                   	ret    

f010720c <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010720c:	55                   	push   %ebp
f010720d:	89 e5                	mov    %esp,%ebp
f010720f:	83 ec 78             	sub    $0x78,%esp
f0107212:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0107215:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0107218:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010721b:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010721e:	89 d8                	mov    %ebx,%eax
f0107220:	e8 b6 ff ff ff       	call   f01071db <holding>
f0107225:	85 c0                	test   %eax,%eax
f0107227:	0f 85 d5 00 00 00    	jne    f0107302 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010722d:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0107234:	00 
f0107235:	8d 43 0c             	lea    0xc(%ebx),%eax
f0107238:	89 44 24 04          	mov    %eax,0x4(%esp)
f010723c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010723f:	89 04 24             	mov    %eax,(%esp)
f0107242:	e8 ce f6 ff ff       	call   f0106915 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0107247:	8b 43 08             	mov    0x8(%ebx),%eax
f010724a:	0f b6 30             	movzbl (%eax),%esi
f010724d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107250:	e8 0d fd ff ff       	call   f0106f62 <cpunum>
f0107255:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107259:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010725d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107261:	c7 04 24 44 92 10 f0 	movl   $0xf0109244,(%esp)
f0107268:	e8 8e d1 ff ff       	call   f01043fb <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010726d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0107270:	85 c0                	test   %eax,%eax
f0107272:	74 72                	je     f01072e6 <spin_unlock+0xda>
f0107274:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0107277:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010727a:	8d 75 d0             	lea    -0x30(%ebp),%esi
f010727d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107281:	89 04 24             	mov    %eax,(%esp)
f0107284:	e8 d5 e9 ff ff       	call   f0105c5e <debuginfo_eip>
f0107289:	85 c0                	test   %eax,%eax
f010728b:	78 39                	js     f01072c6 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010728d:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010728f:	89 c2                	mov    %eax,%edx
f0107291:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0107294:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107298:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010729b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010729f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01072a2:	89 54 24 10          	mov    %edx,0x10(%esp)
f01072a6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01072a9:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01072ad:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01072b0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01072b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01072b8:	c7 04 24 a8 92 10 f0 	movl   $0xf01092a8,(%esp)
f01072bf:	e8 37 d1 ff ff       	call   f01043fb <cprintf>
f01072c4:	eb 12                	jmp    f01072d8 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01072c6:	8b 03                	mov    (%ebx),%eax
f01072c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01072cc:	c7 04 24 bf 92 10 f0 	movl   $0xf01092bf,(%esp)
f01072d3:	e8 23 d1 ff ff       	call   f01043fb <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01072d8:	39 fb                	cmp    %edi,%ebx
f01072da:	74 0a                	je     f01072e6 <spin_unlock+0xda>
f01072dc:	8b 43 04             	mov    0x4(%ebx),%eax
f01072df:	83 c3 04             	add    $0x4,%ebx
f01072e2:	85 c0                	test   %eax,%eax
f01072e4:	75 97                	jne    f010727d <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01072e6:	c7 44 24 08 c7 92 10 	movl   $0xf01092c7,0x8(%esp)
f01072ed:	f0 
f01072ee:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
f01072f5:	00 
f01072f6:	c7 04 24 d3 92 10 f0 	movl   $0xf01092d3,(%esp)
f01072fd:	e8 83 8d ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f0107302:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0107309:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0107310:	b8 00 00 00 00       	mov    $0x0,%eax
f0107315:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0107318:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f010731b:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010731e:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0107321:	89 ec                	mov    %ebp,%esp
f0107323:	5d                   	pop    %ebp
f0107324:	c3                   	ret    

f0107325 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0107325:	55                   	push   %ebp
f0107326:	89 e5                	mov    %esp,%ebp
f0107328:	56                   	push   %esi
f0107329:	53                   	push   %ebx
f010732a:	83 ec 20             	sub    $0x20,%esp
f010732d:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0107330:	89 d8                	mov    %ebx,%eax
f0107332:	e8 a4 fe ff ff       	call   f01071db <holding>
f0107337:	85 c0                	test   %eax,%eax
f0107339:	75 12                	jne    f010734d <spin_lock+0x28>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010733b:	89 da                	mov    %ebx,%edx
f010733d:	b0 01                	mov    $0x1,%al
f010733f:	f0 87 03             	lock xchg %eax,(%ebx)
f0107342:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107347:	85 c0                	test   %eax,%eax
f0107349:	75 2e                	jne    f0107379 <spin_lock+0x54>
f010734b:	eb 37                	jmp    f0107384 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010734d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107350:	e8 0d fc ff ff       	call   f0106f62 <cpunum>
f0107355:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0107359:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010735d:	c7 44 24 08 7c 92 10 	movl   $0xf010927c,0x8(%esp)
f0107364:	f0 
f0107365:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
f010736c:	00 
f010736d:	c7 04 24 d3 92 10 f0 	movl   $0xf01092d3,(%esp)
f0107374:	e8 0c 8d ff ff       	call   f0100085 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0107379:	f3 90                	pause  
f010737b:	89 c8                	mov    %ecx,%eax
f010737d:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107380:	85 c0                	test   %eax,%eax
f0107382:	75 f5                	jne    f0107379 <spin_lock+0x54>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0107384:	e8 d9 fb ff ff       	call   f0106f62 <cpunum>
f0107389:	6b c0 74             	imul   $0x74,%eax,%eax
f010738c:	05 20 d0 1d f0       	add    $0xf01dd020,%eax
f0107391:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0107394:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0107397:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0107399:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f010739f:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f01073a5:	76 40                	jbe    f01073e7 <spin_lock+0xc2>
f01073a7:	eb 33                	jmp    f01073dc <spin_lock+0xb7>
f01073a9:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f01073af:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f01073b5:	77 2a                	ja     f01073e1 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01073b7:	8b 4a 04             	mov    0x4(%edx),%ecx
f01073ba:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01073bd:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f01073bf:	83 c0 01             	add    $0x1,%eax
f01073c2:	83 f8 0a             	cmp    $0xa,%eax
f01073c5:	75 e2                	jne    f01073a9 <spin_lock+0x84>
f01073c7:	eb 2d                	jmp    f01073f6 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f01073c9:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01073cf:	83 c0 01             	add    $0x1,%eax
f01073d2:	83 c2 04             	add    $0x4,%edx
f01073d5:	83 f8 09             	cmp    $0x9,%eax
f01073d8:	7e ef                	jle    f01073c9 <spin_lock+0xa4>
f01073da:	eb 1a                	jmp    f01073f6 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01073dc:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f01073e1:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f01073e5:	eb e2                	jmp    f01073c9 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01073e7:	8b 50 04             	mov    0x4(%eax),%edx
f01073ea:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01073ed:	8b 10                	mov    (%eax),%edx
f01073ef:	b8 01 00 00 00       	mov    $0x1,%eax
f01073f4:	eb b3                	jmp    f01073a9 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01073f6:	83 c4 20             	add    $0x20,%esp
f01073f9:	5b                   	pop    %ebx
f01073fa:	5e                   	pop    %esi
f01073fb:	5d                   	pop    %ebp
f01073fc:	c3                   	ret    
f01073fd:	00 00                	add    %al,(%eax)
	...

f0107400 <__udivdi3>:
f0107400:	55                   	push   %ebp
f0107401:	89 e5                	mov    %esp,%ebp
f0107403:	57                   	push   %edi
f0107404:	56                   	push   %esi
f0107405:	83 ec 10             	sub    $0x10,%esp
f0107408:	8b 45 14             	mov    0x14(%ebp),%eax
f010740b:	8b 55 08             	mov    0x8(%ebp),%edx
f010740e:	8b 75 10             	mov    0x10(%ebp),%esi
f0107411:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0107414:	85 c0                	test   %eax,%eax
f0107416:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0107419:	75 35                	jne    f0107450 <__udivdi3+0x50>
f010741b:	39 fe                	cmp    %edi,%esi
f010741d:	77 61                	ja     f0107480 <__udivdi3+0x80>
f010741f:	85 f6                	test   %esi,%esi
f0107421:	75 0b                	jne    f010742e <__udivdi3+0x2e>
f0107423:	b8 01 00 00 00       	mov    $0x1,%eax
f0107428:	31 d2                	xor    %edx,%edx
f010742a:	f7 f6                	div    %esi
f010742c:	89 c6                	mov    %eax,%esi
f010742e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0107431:	31 d2                	xor    %edx,%edx
f0107433:	89 f8                	mov    %edi,%eax
f0107435:	f7 f6                	div    %esi
f0107437:	89 c7                	mov    %eax,%edi
f0107439:	89 c8                	mov    %ecx,%eax
f010743b:	f7 f6                	div    %esi
f010743d:	89 c1                	mov    %eax,%ecx
f010743f:	89 fa                	mov    %edi,%edx
f0107441:	89 c8                	mov    %ecx,%eax
f0107443:	83 c4 10             	add    $0x10,%esp
f0107446:	5e                   	pop    %esi
f0107447:	5f                   	pop    %edi
f0107448:	5d                   	pop    %ebp
f0107449:	c3                   	ret    
f010744a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107450:	39 f8                	cmp    %edi,%eax
f0107452:	77 1c                	ja     f0107470 <__udivdi3+0x70>
f0107454:	0f bd d0             	bsr    %eax,%edx
f0107457:	83 f2 1f             	xor    $0x1f,%edx
f010745a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010745d:	75 39                	jne    f0107498 <__udivdi3+0x98>
f010745f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0107462:	0f 86 a0 00 00 00    	jbe    f0107508 <__udivdi3+0x108>
f0107468:	39 f8                	cmp    %edi,%eax
f010746a:	0f 82 98 00 00 00    	jb     f0107508 <__udivdi3+0x108>
f0107470:	31 ff                	xor    %edi,%edi
f0107472:	31 c9                	xor    %ecx,%ecx
f0107474:	89 c8                	mov    %ecx,%eax
f0107476:	89 fa                	mov    %edi,%edx
f0107478:	83 c4 10             	add    $0x10,%esp
f010747b:	5e                   	pop    %esi
f010747c:	5f                   	pop    %edi
f010747d:	5d                   	pop    %ebp
f010747e:	c3                   	ret    
f010747f:	90                   	nop
f0107480:	89 d1                	mov    %edx,%ecx
f0107482:	89 fa                	mov    %edi,%edx
f0107484:	89 c8                	mov    %ecx,%eax
f0107486:	31 ff                	xor    %edi,%edi
f0107488:	f7 f6                	div    %esi
f010748a:	89 c1                	mov    %eax,%ecx
f010748c:	89 fa                	mov    %edi,%edx
f010748e:	89 c8                	mov    %ecx,%eax
f0107490:	83 c4 10             	add    $0x10,%esp
f0107493:	5e                   	pop    %esi
f0107494:	5f                   	pop    %edi
f0107495:	5d                   	pop    %ebp
f0107496:	c3                   	ret    
f0107497:	90                   	nop
f0107498:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010749c:	89 f2                	mov    %esi,%edx
f010749e:	d3 e0                	shl    %cl,%eax
f01074a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01074a3:	b8 20 00 00 00       	mov    $0x20,%eax
f01074a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f01074ab:	89 c1                	mov    %eax,%ecx
f01074ad:	d3 ea                	shr    %cl,%edx
f01074af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01074b3:	0b 55 ec             	or     -0x14(%ebp),%edx
f01074b6:	d3 e6                	shl    %cl,%esi
f01074b8:	89 c1                	mov    %eax,%ecx
f01074ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
f01074bd:	89 fe                	mov    %edi,%esi
f01074bf:	d3 ee                	shr    %cl,%esi
f01074c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01074c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01074c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01074cb:	d3 e7                	shl    %cl,%edi
f01074cd:	89 c1                	mov    %eax,%ecx
f01074cf:	d3 ea                	shr    %cl,%edx
f01074d1:	09 d7                	or     %edx,%edi
f01074d3:	89 f2                	mov    %esi,%edx
f01074d5:	89 f8                	mov    %edi,%eax
f01074d7:	f7 75 ec             	divl   -0x14(%ebp)
f01074da:	89 d6                	mov    %edx,%esi
f01074dc:	89 c7                	mov    %eax,%edi
f01074de:	f7 65 e8             	mull   -0x18(%ebp)
f01074e1:	39 d6                	cmp    %edx,%esi
f01074e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01074e6:	72 30                	jb     f0107518 <__udivdi3+0x118>
f01074e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01074eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01074ef:	d3 e2                	shl    %cl,%edx
f01074f1:	39 c2                	cmp    %eax,%edx
f01074f3:	73 05                	jae    f01074fa <__udivdi3+0xfa>
f01074f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01074f8:	74 1e                	je     f0107518 <__udivdi3+0x118>
f01074fa:	89 f9                	mov    %edi,%ecx
f01074fc:	31 ff                	xor    %edi,%edi
f01074fe:	e9 71 ff ff ff       	jmp    f0107474 <__udivdi3+0x74>
f0107503:	90                   	nop
f0107504:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107508:	31 ff                	xor    %edi,%edi
f010750a:	b9 01 00 00 00       	mov    $0x1,%ecx
f010750f:	e9 60 ff ff ff       	jmp    f0107474 <__udivdi3+0x74>
f0107514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107518:	8d 4f ff             	lea    -0x1(%edi),%ecx
f010751b:	31 ff                	xor    %edi,%edi
f010751d:	89 c8                	mov    %ecx,%eax
f010751f:	89 fa                	mov    %edi,%edx
f0107521:	83 c4 10             	add    $0x10,%esp
f0107524:	5e                   	pop    %esi
f0107525:	5f                   	pop    %edi
f0107526:	5d                   	pop    %ebp
f0107527:	c3                   	ret    
	...

f0107530 <__umoddi3>:
f0107530:	55                   	push   %ebp
f0107531:	89 e5                	mov    %esp,%ebp
f0107533:	57                   	push   %edi
f0107534:	56                   	push   %esi
f0107535:	83 ec 20             	sub    $0x20,%esp
f0107538:	8b 55 14             	mov    0x14(%ebp),%edx
f010753b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010753e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0107541:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107544:	85 d2                	test   %edx,%edx
f0107546:	89 c8                	mov    %ecx,%eax
f0107548:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010754b:	75 13                	jne    f0107560 <__umoddi3+0x30>
f010754d:	39 f7                	cmp    %esi,%edi
f010754f:	76 3f                	jbe    f0107590 <__umoddi3+0x60>
f0107551:	89 f2                	mov    %esi,%edx
f0107553:	f7 f7                	div    %edi
f0107555:	89 d0                	mov    %edx,%eax
f0107557:	31 d2                	xor    %edx,%edx
f0107559:	83 c4 20             	add    $0x20,%esp
f010755c:	5e                   	pop    %esi
f010755d:	5f                   	pop    %edi
f010755e:	5d                   	pop    %ebp
f010755f:	c3                   	ret    
f0107560:	39 f2                	cmp    %esi,%edx
f0107562:	77 4c                	ja     f01075b0 <__umoddi3+0x80>
f0107564:	0f bd ca             	bsr    %edx,%ecx
f0107567:	83 f1 1f             	xor    $0x1f,%ecx
f010756a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010756d:	75 51                	jne    f01075c0 <__umoddi3+0x90>
f010756f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0107572:	0f 87 e0 00 00 00    	ja     f0107658 <__umoddi3+0x128>
f0107578:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010757b:	29 f8                	sub    %edi,%eax
f010757d:	19 d6                	sbb    %edx,%esi
f010757f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107582:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107585:	89 f2                	mov    %esi,%edx
f0107587:	83 c4 20             	add    $0x20,%esp
f010758a:	5e                   	pop    %esi
f010758b:	5f                   	pop    %edi
f010758c:	5d                   	pop    %ebp
f010758d:	c3                   	ret    
f010758e:	66 90                	xchg   %ax,%ax
f0107590:	85 ff                	test   %edi,%edi
f0107592:	75 0b                	jne    f010759f <__umoddi3+0x6f>
f0107594:	b8 01 00 00 00       	mov    $0x1,%eax
f0107599:	31 d2                	xor    %edx,%edx
f010759b:	f7 f7                	div    %edi
f010759d:	89 c7                	mov    %eax,%edi
f010759f:	89 f0                	mov    %esi,%eax
f01075a1:	31 d2                	xor    %edx,%edx
f01075a3:	f7 f7                	div    %edi
f01075a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01075a8:	f7 f7                	div    %edi
f01075aa:	eb a9                	jmp    f0107555 <__umoddi3+0x25>
f01075ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01075b0:	89 c8                	mov    %ecx,%eax
f01075b2:	89 f2                	mov    %esi,%edx
f01075b4:	83 c4 20             	add    $0x20,%esp
f01075b7:	5e                   	pop    %esi
f01075b8:	5f                   	pop    %edi
f01075b9:	5d                   	pop    %ebp
f01075ba:	c3                   	ret    
f01075bb:	90                   	nop
f01075bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01075c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01075c4:	d3 e2                	shl    %cl,%edx
f01075c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01075c9:	ba 20 00 00 00       	mov    $0x20,%edx
f01075ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
f01075d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01075d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01075d8:	89 fa                	mov    %edi,%edx
f01075da:	d3 ea                	shr    %cl,%edx
f01075dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01075e0:	0b 55 f4             	or     -0xc(%ebp),%edx
f01075e3:	d3 e7                	shl    %cl,%edi
f01075e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01075e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01075ec:	89 f2                	mov    %esi,%edx
f01075ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
f01075f1:	89 c7                	mov    %eax,%edi
f01075f3:	d3 ea                	shr    %cl,%edx
f01075f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01075f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01075fc:	89 c2                	mov    %eax,%edx
f01075fe:	d3 e6                	shl    %cl,%esi
f0107600:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107604:	d3 ea                	shr    %cl,%edx
f0107606:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010760a:	09 d6                	or     %edx,%esi
f010760c:	89 f0                	mov    %esi,%eax
f010760e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0107611:	d3 e7                	shl    %cl,%edi
f0107613:	89 f2                	mov    %esi,%edx
f0107615:	f7 75 f4             	divl   -0xc(%ebp)
f0107618:	89 d6                	mov    %edx,%esi
f010761a:	f7 65 e8             	mull   -0x18(%ebp)
f010761d:	39 d6                	cmp    %edx,%esi
f010761f:	72 2b                	jb     f010764c <__umoddi3+0x11c>
f0107621:	39 c7                	cmp    %eax,%edi
f0107623:	72 23                	jb     f0107648 <__umoddi3+0x118>
f0107625:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107629:	29 c7                	sub    %eax,%edi
f010762b:	19 d6                	sbb    %edx,%esi
f010762d:	89 f0                	mov    %esi,%eax
f010762f:	89 f2                	mov    %esi,%edx
f0107631:	d3 ef                	shr    %cl,%edi
f0107633:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107637:	d3 e0                	shl    %cl,%eax
f0107639:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010763d:	09 f8                	or     %edi,%eax
f010763f:	d3 ea                	shr    %cl,%edx
f0107641:	83 c4 20             	add    $0x20,%esp
f0107644:	5e                   	pop    %esi
f0107645:	5f                   	pop    %edi
f0107646:	5d                   	pop    %ebp
f0107647:	c3                   	ret    
f0107648:	39 d6                	cmp    %edx,%esi
f010764a:	75 d9                	jne    f0107625 <__umoddi3+0xf5>
f010764c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010764f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0107652:	eb d1                	jmp    f0107625 <__umoddi3+0xf5>
f0107654:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107658:	39 f2                	cmp    %esi,%edx
f010765a:	0f 82 18 ff ff ff    	jb     f0107578 <__umoddi3+0x48>
f0107660:	e9 1d ff ff ff       	jmp    f0107582 <__umoddi3+0x52>
