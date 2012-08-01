
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
f0100015:	b8 00 30 12 00       	mov    $0x123000,%eax
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
f0100034:	bc 00 30 12 f0       	mov    $0xf0123000,%esp

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
f0100058:	c7 04 24 80 7f 10 f0 	movl   $0xf0107f80,(%esp)
f010005f:	e8 e7 43 00 00       	call   f010444b <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 a5 43 00 00       	call   f0104418 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 b7 92 10 f0 	movl   $0xf01092b7,(%esp)
f010007a:	e8 cc 43 00 00       	call   f010444b <cprintf>
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
f0100090:	83 3d 8c 5e 27 f0 00 	cmpl   $0x0,0xf0275e8c
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 8c 5e 27 f0    	mov    %esi,0xf0275e8c

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
f01000a4:	e8 69 6f 00 00       	call   f0107012 <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 18 80 10 f0 	movl   $0xf0108018,(%esp)
f01000c2:	e8 84 43 00 00       	call   f010444b <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 45 43 00 00       	call   f0104418 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 b7 92 10 f0 	movl   $0xf01092b7,(%esp)
f01000da:	e8 6c 43 00 00       	call   f010444b <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 38 0a 00 00       	call   f0100b23 <monitor>
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
f01000f3:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
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
f0100105:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f010010c:	f0 
f010010d:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
f0100114:	00 
f0100115:	c7 04 24 9a 7f 10 f0 	movl   $0xf0107f9a,(%esp)
f010011c:	e8 64 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0100121:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0100127:	0f 22 da             	mov    %edx,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f010012a:	e8 e3 6e 00 00       	call   f0107012 <cpunum>
f010012f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100133:	c7 04 24 a6 7f 10 f0 	movl   $0xf0107fa6,(%esp)
f010013a:	e8 0c 43 00 00       	call   f010444b <cprintf>

	lapic_init();
f010013f:	e8 ea 6e 00 00       	call   f010702e <lapic_init>
	env_init_percpu();
f0100144:	e8 27 39 00 00       	call   f0103a70 <env_init_percpu>
	trap_init_percpu();
f0100149:	e8 42 43 00 00       	call   f0104490 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014e:	66 90                	xchg   %ax,%ax
f0100150:	e8 bd 6e 00 00       	call   f0107012 <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 80 27 f0    	add    $0xf0278024,%edx
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
f0100166:	c7 04 24 80 53 12 f0 	movl   $0xf0125380,(%esp)
f010016d:	e8 63 72 00 00       	call   f01073d5 <spin_lock>
	// to start running processes on this CPU.  But make sure that
	// only one CPU can enter the scheduler at a time!
	//
	// Your code here:
	lock_kernel();
	sched_yield();
f0100172:	e8 c9 50 00 00       	call   f0105240 <sched_yield>

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
f01001bf:	b8 04 90 2b f0       	mov    $0xf02b9004,%eax
f01001c4:	2d df 46 27 f0       	sub    $0xf02746df,%eax
f01001c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01001d4:	00 
f01001d5:	c7 04 24 df 46 27 f0 	movl   $0xf02746df,(%esp)
f01001dc:	e8 85 67 00 00       	call   f0106966 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01001e1:	e8 33 06 00 00       	call   f0100819 <cons_init>

	cprintf("6828 decimal is %o octal!%n\n%n", 6828, &chnum1, &chnum2);
f01001e6:	8d 45 e6             	lea    -0x1a(%ebp),%eax
f01001e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01001ed:	8d 5d e7             	lea    -0x19(%ebp),%ebx
f01001f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01001f4:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01001fb:	00 
f01001fc:	c7 04 24 60 80 10 f0 	movl   $0xf0108060,(%esp)
f0100203:	e8 43 42 00 00       	call   f010444b <cprintf>
	cprintf("chnum1: %d chnum2: %d\n", chnum1, chnum2);
f0100208:	0f be 45 e6          	movsbl -0x1a(%ebp),%eax
f010020c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100210:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f0100214:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100218:	c7 04 24 bc 7f 10 f0 	movl   $0xf0107fbc,(%esp)
f010021f:	e8 27 42 00 00       	call   f010444b <cprintf>
	cprintf("%n", NULL);
f0100224:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010022b:	00 
f010022c:	c7 04 24 d5 7f 10 f0 	movl   $0xf0107fd5,(%esp)
f0100233:	e8 13 42 00 00       	call   f010444b <cprintf>
	memset(ntest, 0xd, sizeof(ntest) - 1);
f0100238:	c7 44 24 08 ff 00 00 	movl   $0xff,0x8(%esp)
f010023f:	00 
f0100240:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
f0100247:	00 
f0100248:	8d b5 e6 fe ff ff    	lea    -0x11a(%ebp),%esi
f010024e:	89 34 24             	mov    %esi,(%esp)
f0100251:	e8 10 67 00 00       	call   f0106966 <memset>
	cprintf("%s%n", ntest, &chnum1); 
f0100256:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010025a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010025e:	c7 04 24 d3 7f 10 f0 	movl   $0xf0107fd3,(%esp)
f0100265:	e8 e1 41 00 00       	call   f010444b <cprintf>
	cprintf("chnum1: %d\n", chnum1);
f010026a:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
f010026e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100272:	c7 04 24 d8 7f 10 f0 	movl   $0xf0107fd8,(%esp)
f0100279:	e8 cd 41 00 00       	call   f010444b <cprintf>



	extern unsigned char mpentry_start[];
	extern void mp_main(void);
	cprintf("mpentry_start address is %x\n", (int)mpentry_start);
f010027e:	c7 44 24 04 cc 6b 10 	movl   $0xf0106bcc,0x4(%esp)
f0100285:	f0 
f0100286:	c7 04 24 e4 7f 10 f0 	movl   $0xf0107fe4,(%esp)
f010028d:	e8 b9 41 00 00       	call   f010444b <cprintf>
	cprintf("mp_main address is %x\n", (int)mp_main);
f0100292:	c7 44 24 04 ed 00 10 	movl   $0xf01000ed,0x4(%esp)
f0100299:	f0 
f010029a:	c7 04 24 01 80 10 f0 	movl   $0xf0108001,(%esp)
f01002a1:	e8 a5 41 00 00       	call   f010444b <cprintf>
	// Lab 2 memory management initialization functions
	mem_init();
f01002a6:	e8 6a 25 00 00       	call   f0102815 <mem_init>
	// Lab 3 user environment initialization functions


	env_init();
f01002ab:	e8 ea 37 00 00       	call   f0103a9a <env_init>
	trap_init();
f01002b0:	e8 ea 44 00 00       	call   f010479f <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01002b5:	e8 70 6a 00 00       	call   f0106d2a <mp_init>
	lapic_init();
f01002ba:	e8 6f 6d 00 00       	call   f010702e <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01002bf:	90                   	nop
f01002c0:	e8 c7 40 00 00       	call   f010438c <pic_init>

	// Lab 6 hardware initialization functions
	time_init();
f01002c5:	e8 d6 79 00 00       	call   f0107ca0 <time_init>
	pci_init();
f01002ca:	e8 38 77 00 00       	call   f0107a07 <pci_init>
f01002cf:	c7 04 24 80 53 12 f0 	movl   $0xf0125380,(%esp)
f01002d6:	e8 fa 70 00 00       	call   f01073d5 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01002db:	83 3d 94 5e 27 f0 07 	cmpl   $0x7,0xf0275e94
f01002e2:	77 24                	ja     f0100308 <i386_init+0x191>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01002e4:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01002eb:	00 
f01002ec:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01002f3:	f0 
f01002f4:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
f01002fb:	00 
f01002fc:	c7 04 24 9a 7f 10 f0 	movl   $0xf0107f9a,(%esp)
f0100303:	e8 7d fd ff ff       	call   f0100085 <_panic>
	void *code;
	struct Cpu *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100308:	b8 46 6c 10 f0       	mov    $0xf0106c46,%eax
f010030d:	2d cc 6b 10 f0       	sub    $0xf0106bcc,%eax
f0100312:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100316:	c7 44 24 04 cc 6b 10 	movl   $0xf0106bcc,0x4(%esp)
f010031d:	f0 
f010031e:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100325:	e8 9b 66 00 00       	call   f01069c5 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010032a:	6b 05 c4 83 27 f0 74 	imul   $0x74,0xf02783c4,%eax
f0100331:	05 20 80 27 f0       	add    $0xf0278020,%eax
f0100336:	3d 20 80 27 f0       	cmp    $0xf0278020,%eax
f010033b:	76 65                	jbe    f01003a2 <i386_init+0x22b>
f010033d:	be 00 00 00 00       	mov    $0x0,%esi
f0100342:	bb 20 80 27 f0       	mov    $0xf0278020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100347:	e8 c6 6c 00 00       	call   f0107012 <cpunum>
f010034c:	6b c0 74             	imul   $0x74,%eax,%eax
f010034f:	05 20 80 27 f0       	add    $0xf0278020,%eax
f0100354:	39 d8                	cmp    %ebx,%eax
f0100356:	74 34                	je     f010038c <i386_init+0x215>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100358:	89 f0                	mov    %esi,%eax
f010035a:	c1 f8 02             	sar    $0x2,%eax
f010035d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100363:	c1 e0 0f             	shl    $0xf,%eax
f0100366:	8d 80 00 10 28 f0    	lea    -0xfd7f000(%eax),%eax
f010036c:	a3 90 5e 27 f0       	mov    %eax,0xf0275e90
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f0100371:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100378:	00 
f0100379:	0f b6 03             	movzbl (%ebx),%eax
f010037c:	89 04 24             	mov    %eax,(%esp)
f010037f:	e8 14 6e 00 00       	call   f0107198 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100384:	8b 43 04             	mov    0x4(%ebx),%eax
f0100387:	83 f8 01             	cmp    $0x1,%eax
f010038a:	75 f8                	jne    f0100384 <i386_init+0x20d>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010038c:	83 c3 74             	add    $0x74,%ebx
f010038f:	83 c6 74             	add    $0x74,%esi
f0100392:	6b 05 c4 83 27 f0 74 	imul   $0x74,0xf02783c4,%eax
f0100399:	05 20 80 27 f0       	add    $0xf0278020,%eax
f010039e:	39 c3                	cmp    %eax,%ebx
f01003a0:	72 a5                	jb     f0100347 <i386_init+0x1d0>
f01003a2:	bb 00 00 00 00       	mov    $0x0,%ebx
	boot_aps();

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);
f01003a7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01003ae:	00 
f01003af:	c7 44 24 04 c0 4f 00 	movl   $0x4fc0,0x4(%esp)
f01003b6:	00 
f01003b7:	c7 04 24 74 b1 16 f0 	movl   $0xf016b174,(%esp)
f01003be:	e8 a4 3d 00 00       	call   f0104167 <env_create>
	// Starting non-boot CPUs
	boot_aps();

	// Should always have idle processes at first.
	int i;
	for (i = 0; i < NCPU; i++)
f01003c3:	83 c3 01             	add    $0x1,%ebx
f01003c6:	83 fb 08             	cmp    $0x8,%ebx
f01003c9:	75 dc                	jne    f01003a7 <i386_init+0x230>
		ENV_CREATE(user_idle, ENV_TYPE_IDLE);

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01003cb:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
f01003d2:	00 
f01003d3:	c7 44 24 04 0b 97 01 	movl   $0x1970b,0x4(%esp)
f01003da:	00 
f01003db:	c7 04 24 25 57 1d f0 	movl   $0xf01d5725,(%esp)
f01003e2:	e8 80 3d 00 00       	call   f0104167 <env_create>
	ENV_CREATE(net_ns, ENV_TYPE_NS);
#endif

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01003e7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01003ee:	00 
f01003ef:	c7 44 24 04 f3 32 01 	movl   $0x132f3,0x4(%esp)
f01003f6:	00 
f01003f7:	c7 04 24 17 63 21 f0 	movl   $0xf0216317,(%esp)
f01003fe:	e8 64 3d 00 00       	call   f0104167 <env_create>
	//cprintf("%x\n",_pgfault_upcall);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	// Schedule and run the first user environment!
	sched_yield();
f0100403:	e8 38 4e 00 00       	call   f0105240 <sched_yield>
	...

f0100410 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100410:	55                   	push   %ebp
f0100411:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100413:	ba 84 00 00 00       	mov    $0x84,%edx
f0100418:	ec                   	in     (%dx),%al
f0100419:	ec                   	in     (%dx),%al
f010041a:	ec                   	in     (%dx),%al
f010041b:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f010041c:	5d                   	pop    %ebp
f010041d:	c3                   	ret    

f010041e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010041e:	55                   	push   %ebp
f010041f:	89 e5                	mov    %esp,%ebp
f0100421:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100426:	ec                   	in     (%dx),%al
f0100427:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100429:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010042e:	f6 c2 01             	test   $0x1,%dl
f0100431:	74 09                	je     f010043c <serial_proc_data+0x1e>
f0100433:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100438:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100439:	0f b6 c0             	movzbl %al,%eax
}
f010043c:	5d                   	pop    %ebp
f010043d:	c3                   	ret    

f010043e <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010043e:	55                   	push   %ebp
f010043f:	89 e5                	mov    %esp,%ebp
f0100441:	57                   	push   %edi
f0100442:	56                   	push   %esi
f0100443:	53                   	push   %ebx
f0100444:	83 ec 0c             	sub    $0xc,%esp
f0100447:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100449:	bb 24 52 27 f0       	mov    $0xf0275224,%ebx
f010044e:	bf 20 50 27 f0       	mov    $0xf0275020,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100453:	eb 1b                	jmp    f0100470 <cons_intr+0x32>
		if (c == 0)
f0100455:	85 c0                	test   %eax,%eax
f0100457:	74 17                	je     f0100470 <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f0100459:	8b 13                	mov    (%ebx),%edx
f010045b:	88 04 3a             	mov    %al,(%edx,%edi,1)
f010045e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100461:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100466:	ba 00 00 00 00       	mov    $0x0,%edx
f010046b:	0f 44 c2             	cmove  %edx,%eax
f010046e:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100470:	ff d6                	call   *%esi
f0100472:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100475:	75 de                	jne    f0100455 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100477:	83 c4 0c             	add    $0xc,%esp
f010047a:	5b                   	pop    %ebx
f010047b:	5e                   	pop    %esi
f010047c:	5f                   	pop    %edi
f010047d:	5d                   	pop    %ebp
f010047e:	c3                   	ret    

f010047f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010047f:	55                   	push   %ebp
f0100480:	89 e5                	mov    %esp,%ebp
f0100482:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100485:	b8 1a 07 10 f0       	mov    $0xf010071a,%eax
f010048a:	e8 af ff ff ff       	call   f010043e <cons_intr>
}
f010048f:	c9                   	leave  
f0100490:	c3                   	ret    

f0100491 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100491:	55                   	push   %ebp
f0100492:	89 e5                	mov    %esp,%ebp
f0100494:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100497:	83 3d 04 50 27 f0 00 	cmpl   $0x0,0xf0275004
f010049e:	74 0a                	je     f01004aa <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004a0:	b8 1e 04 10 f0       	mov    $0xf010041e,%eax
f01004a5:	e8 94 ff ff ff       	call   f010043e <cons_intr>
}
f01004aa:	c9                   	leave  
f01004ab:	c3                   	ret    

f01004ac <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ac:	55                   	push   %ebp
f01004ad:	89 e5                	mov    %esp,%ebp
f01004af:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b2:	e8 da ff ff ff       	call   f0100491 <serial_intr>
	kbd_intr();
f01004b7:	e8 c3 ff ff ff       	call   f010047f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004bc:	8b 15 20 52 27 f0    	mov    0xf0275220,%edx
f01004c2:	b8 00 00 00 00       	mov    $0x0,%eax
f01004c7:	3b 15 24 52 27 f0    	cmp    0xf0275224,%edx
f01004cd:	74 1e                	je     f01004ed <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f01004cf:	0f b6 82 20 50 27 f0 	movzbl -0xfd8afe0(%edx),%eax
f01004d6:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f01004d9:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f01004df:	b9 00 00 00 00       	mov    $0x0,%ecx
f01004e4:	0f 44 d1             	cmove  %ecx,%edx
f01004e7:	89 15 20 52 27 f0    	mov    %edx,0xf0275220
		return c;
	}
	return 0;
}
f01004ed:	c9                   	leave  
f01004ee:	c3                   	ret    

f01004ef <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01004ef:	55                   	push   %ebp
f01004f0:	89 e5                	mov    %esp,%ebp
f01004f2:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01004f5:	e8 b2 ff ff ff       	call   f01004ac <cons_getc>
f01004fa:	85 c0                	test   %eax,%eax
f01004fc:	74 f7                	je     f01004f5 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01004fe:	c9                   	leave  
f01004ff:	c3                   	ret    

f0100500 <iscons>:

int
iscons(int fdnum)
{
f0100500:	55                   	push   %ebp
f0100501:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100503:	b8 01 00 00 00       	mov    $0x1,%eax
f0100508:	5d                   	pop    %ebp
f0100509:	c3                   	ret    

f010050a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010050a:	55                   	push   %ebp
f010050b:	89 e5                	mov    %esp,%ebp
f010050d:	57                   	push   %edi
f010050e:	56                   	push   %esi
f010050f:	53                   	push   %ebx
f0100510:	83 ec 2c             	sub    $0x2c,%esp
f0100513:	89 c7                	mov    %eax,%edi
f0100515:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010051a:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f010051b:	a8 20                	test   $0x20,%al
f010051d:	75 21                	jne    f0100540 <cons_putc+0x36>
f010051f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100524:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100529:	e8 e2 fe ff ff       	call   f0100410 <delay>
f010052e:	89 f2                	mov    %esi,%edx
f0100530:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100531:	a8 20                	test   $0x20,%al
f0100533:	75 0b                	jne    f0100540 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100535:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;
	
	for (i = 0;
f0100538:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f010053e:	75 e9                	jne    f0100529 <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
	
	outb(COM1 + COM_TX, c);
f0100540:	89 fa                	mov    %edi,%edx
f0100542:	89 f8                	mov    %edi,%eax
f0100544:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100547:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010054c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010054d:	b2 79                	mov    $0x79,%dl
f010054f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100550:	84 c0                	test   %al,%al
f0100552:	78 21                	js     f0100575 <cons_putc+0x6b>
f0100554:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100559:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f010055e:	e8 ad fe ff ff       	call   f0100410 <delay>
f0100563:	89 f2                	mov    %esi,%edx
f0100565:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100566:	84 c0                	test   %al,%al
f0100568:	78 0b                	js     f0100575 <cons_putc+0x6b>
f010056a:	83 c3 01             	add    $0x1,%ebx
f010056d:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100573:	75 e9                	jne    f010055e <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100575:	ba 78 03 00 00       	mov    $0x378,%edx
f010057a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010057e:	ee                   	out    %al,(%dx)
f010057f:	b2 7a                	mov    $0x7a,%dl
f0100581:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100586:	ee                   	out    %al,(%dx)
f0100587:	b8 08 00 00 00       	mov    $0x8,%eax
f010058c:	ee                   	out    %al,(%dx)
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f010058d:	89 f8                	mov    %edi,%eax
f010058f:	80 cc 07             	or     $0x7,%ah
f0100592:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100598:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010059b:	89 f8                	mov    %edi,%eax
f010059d:	25 ff 00 00 00       	and    $0xff,%eax
f01005a2:	83 f8 09             	cmp    $0x9,%eax
f01005a5:	0f 84 89 00 00 00    	je     f0100634 <cons_putc+0x12a>
f01005ab:	83 f8 09             	cmp    $0x9,%eax
f01005ae:	7f 12                	jg     f01005c2 <cons_putc+0xb8>
f01005b0:	83 f8 08             	cmp    $0x8,%eax
f01005b3:	0f 85 af 00 00 00    	jne    f0100668 <cons_putc+0x15e>
f01005b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01005c0:	eb 18                	jmp    f01005da <cons_putc+0xd0>
f01005c2:	83 f8 0a             	cmp    $0xa,%eax
f01005c5:	8d 76 00             	lea    0x0(%esi),%esi
f01005c8:	74 40                	je     f010060a <cons_putc+0x100>
f01005ca:	83 f8 0d             	cmp    $0xd,%eax
f01005cd:	8d 76 00             	lea    0x0(%esi),%esi
f01005d0:	0f 85 92 00 00 00    	jne    f0100668 <cons_putc+0x15e>
f01005d6:	66 90                	xchg   %ax,%ax
f01005d8:	eb 38                	jmp    f0100612 <cons_putc+0x108>
	case '\b':
		if (crt_pos > 0) {
f01005da:	0f b7 05 10 50 27 f0 	movzwl 0xf0275010,%eax
f01005e1:	66 85 c0             	test   %ax,%ax
f01005e4:	0f 84 e8 00 00 00    	je     f01006d2 <cons_putc+0x1c8>
			crt_pos--;
f01005ea:	83 e8 01             	sub    $0x1,%eax
f01005ed:	66 a3 10 50 27 f0    	mov    %ax,0xf0275010
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01005f3:	0f b7 c0             	movzwl %ax,%eax
f01005f6:	66 81 e7 00 ff       	and    $0xff00,%di
f01005fb:	83 cf 20             	or     $0x20,%edi
f01005fe:	8b 15 0c 50 27 f0    	mov    0xf027500c,%edx
f0100604:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100608:	eb 7b                	jmp    f0100685 <cons_putc+0x17b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010060a:	66 83 05 10 50 27 f0 	addw   $0x50,0xf0275010
f0100611:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100612:	0f b7 05 10 50 27 f0 	movzwl 0xf0275010,%eax
f0100619:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f010061f:	c1 e8 10             	shr    $0x10,%eax
f0100622:	66 c1 e8 06          	shr    $0x6,%ax
f0100626:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100629:	c1 e0 04             	shl    $0x4,%eax
f010062c:	66 a3 10 50 27 f0    	mov    %ax,0xf0275010
f0100632:	eb 51                	jmp    f0100685 <cons_putc+0x17b>
		break;
	case '\t':
		cons_putc(' ');
f0100634:	b8 20 00 00 00       	mov    $0x20,%eax
f0100639:	e8 cc fe ff ff       	call   f010050a <cons_putc>
		cons_putc(' ');
f010063e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100643:	e8 c2 fe ff ff       	call   f010050a <cons_putc>
		cons_putc(' ');
f0100648:	b8 20 00 00 00       	mov    $0x20,%eax
f010064d:	e8 b8 fe ff ff       	call   f010050a <cons_putc>
		cons_putc(' ');
f0100652:	b8 20 00 00 00       	mov    $0x20,%eax
f0100657:	e8 ae fe ff ff       	call   f010050a <cons_putc>
		cons_putc(' ');
f010065c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100661:	e8 a4 fe ff ff       	call   f010050a <cons_putc>
f0100666:	eb 1d                	jmp    f0100685 <cons_putc+0x17b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100668:	0f b7 05 10 50 27 f0 	movzwl 0xf0275010,%eax
f010066f:	0f b7 c8             	movzwl %ax,%ecx
f0100672:	8b 15 0c 50 27 f0    	mov    0xf027500c,%edx
f0100678:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010067c:	83 c0 01             	add    $0x1,%eax
f010067f:	66 a3 10 50 27 f0    	mov    %ax,0xf0275010
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100685:	66 81 3d 10 50 27 f0 	cmpw   $0x7cf,0xf0275010
f010068c:	cf 07 
f010068e:	76 42                	jbe    f01006d2 <cons_putc+0x1c8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100690:	a1 0c 50 27 f0       	mov    0xf027500c,%eax
f0100695:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010069c:	00 
f010069d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01006a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006a7:	89 04 24             	mov    %eax,(%esp)
f01006aa:	e8 16 63 00 00       	call   f01069c5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01006af:	8b 15 0c 50 27 f0    	mov    0xf027500c,%edx
f01006b5:	b8 80 07 00 00       	mov    $0x780,%eax
f01006ba:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01006c0:	83 c0 01             	add    $0x1,%eax
f01006c3:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01006c8:	75 f0                	jne    f01006ba <cons_putc+0x1b0>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01006ca:	66 83 2d 10 50 27 f0 	subw   $0x50,0xf0275010
f01006d1:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01006d2:	8b 0d 08 50 27 f0    	mov    0xf0275008,%ecx
f01006d8:	89 cb                	mov    %ecx,%ebx
f01006da:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006df:	89 ca                	mov    %ecx,%edx
f01006e1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01006e2:	0f b7 35 10 50 27 f0 	movzwl 0xf0275010,%esi
f01006e9:	83 c1 01             	add    $0x1,%ecx
f01006ec:	89 f0                	mov    %esi,%eax
f01006ee:	66 c1 e8 08          	shr    $0x8,%ax
f01006f2:	89 ca                	mov    %ecx,%edx
f01006f4:	ee                   	out    %al,(%dx)
f01006f5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006fa:	89 da                	mov    %ebx,%edx
f01006fc:	ee                   	out    %al,(%dx)
f01006fd:	89 f0                	mov    %esi,%eax
f01006ff:	89 ca                	mov    %ecx,%edx
f0100701:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100702:	83 c4 2c             	add    $0x2c,%esp
f0100705:	5b                   	pop    %ebx
f0100706:	5e                   	pop    %esi
f0100707:	5f                   	pop    %edi
f0100708:	5d                   	pop    %ebp
f0100709:	c3                   	ret    

f010070a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010070a:	55                   	push   %ebp
f010070b:	89 e5                	mov    %esp,%ebp
f010070d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100710:	8b 45 08             	mov    0x8(%ebp),%eax
f0100713:	e8 f2 fd ff ff       	call   f010050a <cons_putc>
}
f0100718:	c9                   	leave  
f0100719:	c3                   	ret    

f010071a <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010071a:	55                   	push   %ebp
f010071b:	89 e5                	mov    %esp,%ebp
f010071d:	53                   	push   %ebx
f010071e:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100721:	ba 64 00 00 00       	mov    $0x64,%edx
f0100726:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100727:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010072c:	a8 01                	test   $0x1,%al
f010072e:	0f 84 dd 00 00 00    	je     f0100811 <kbd_proc_data+0xf7>
f0100734:	b2 60                	mov    $0x60,%dl
f0100736:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100737:	3c e0                	cmp    $0xe0,%al
f0100739:	75 11                	jne    f010074c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f010073b:	83 0d 00 50 27 f0 40 	orl    $0x40,0xf0275000
f0100742:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100747:	e9 c5 00 00 00       	jmp    f0100811 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f010074c:	84 c0                	test   %al,%al
f010074e:	79 35                	jns    f0100785 <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100750:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f0100756:	89 c1                	mov    %eax,%ecx
f0100758:	83 e1 7f             	and    $0x7f,%ecx
f010075b:	f6 c2 40             	test   $0x40,%dl
f010075e:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100761:	0f b6 c0             	movzbl %al,%eax
f0100764:	0f b6 80 e0 80 10 f0 	movzbl -0xfef7f20(%eax),%eax
f010076b:	83 c8 40             	or     $0x40,%eax
f010076e:	0f b6 c0             	movzbl %al,%eax
f0100771:	f7 d0                	not    %eax
f0100773:	21 c2                	and    %eax,%edx
f0100775:	89 15 00 50 27 f0    	mov    %edx,0xf0275000
f010077b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100780:	e9 8c 00 00 00       	jmp    f0100811 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f0100785:	8b 15 00 50 27 f0    	mov    0xf0275000,%edx
f010078b:	f6 c2 40             	test   $0x40,%dl
f010078e:	74 0c                	je     f010079c <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100790:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100793:	83 e2 bf             	and    $0xffffffbf,%edx
f0100796:	89 15 00 50 27 f0    	mov    %edx,0xf0275000
	}

	shift |= shiftcode[data];
f010079c:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010079f:	0f b6 90 e0 80 10 f0 	movzbl -0xfef7f20(%eax),%edx
f01007a6:	0b 15 00 50 27 f0    	or     0xf0275000,%edx
f01007ac:	0f b6 88 e0 81 10 f0 	movzbl -0xfef7e20(%eax),%ecx
f01007b3:	31 ca                	xor    %ecx,%edx
f01007b5:	89 15 00 50 27 f0    	mov    %edx,0xf0275000

	c = charcode[shift & (CTL | SHIFT)][data];
f01007bb:	89 d1                	mov    %edx,%ecx
f01007bd:	83 e1 03             	and    $0x3,%ecx
f01007c0:	8b 0c 8d e0 82 10 f0 	mov    -0xfef7d20(,%ecx,4),%ecx
f01007c7:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f01007cb:	f6 c2 08             	test   $0x8,%dl
f01007ce:	74 1b                	je     f01007eb <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f01007d0:	89 d9                	mov    %ebx,%ecx
f01007d2:	8d 43 9f             	lea    -0x61(%ebx),%eax
f01007d5:	83 f8 19             	cmp    $0x19,%eax
f01007d8:	77 05                	ja     f01007df <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f01007da:	83 eb 20             	sub    $0x20,%ebx
f01007dd:	eb 0c                	jmp    f01007eb <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f01007df:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f01007e2:	8d 43 20             	lea    0x20(%ebx),%eax
f01007e5:	83 f9 19             	cmp    $0x19,%ecx
f01007e8:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01007eb:	f7 d2                	not    %edx
f01007ed:	f6 c2 06             	test   $0x6,%dl
f01007f0:	75 1f                	jne    f0100811 <kbd_proc_data+0xf7>
f01007f2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01007f8:	75 17                	jne    f0100811 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f01007fa:	c7 04 24 a3 80 10 f0 	movl   $0xf01080a3,(%esp)
f0100801:	e8 45 3c 00 00       	call   f010444b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100806:	ba 92 00 00 00       	mov    $0x92,%edx
f010080b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100810:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100811:	89 d8                	mov    %ebx,%eax
f0100813:	83 c4 14             	add    $0x14,%esp
f0100816:	5b                   	pop    %ebx
f0100817:	5d                   	pop    %ebp
f0100818:	c3                   	ret    

f0100819 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100819:	55                   	push   %ebp
f010081a:	89 e5                	mov    %esp,%ebp
f010081c:	57                   	push   %edi
f010081d:	56                   	push   %esi
f010081e:	53                   	push   %ebx
f010081f:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100822:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f0100827:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f010082a:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f010082f:	0f b7 00             	movzwl (%eax),%eax
f0100832:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100836:	74 11                	je     f0100849 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100838:	c7 05 08 50 27 f0 b4 	movl   $0x3b4,0xf0275008
f010083f:	03 00 00 
f0100842:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100847:	eb 16                	jmp    f010085f <cons_init+0x46>
	} else {
		*cp = was;
f0100849:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100850:	c7 05 08 50 27 f0 d4 	movl   $0x3d4,0xf0275008
f0100857:	03 00 00 
f010085a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}
	
	/* Extract cursor location */
	outb(addr_6845, 14);
f010085f:	8b 0d 08 50 27 f0    	mov    0xf0275008,%ecx
f0100865:	89 cb                	mov    %ecx,%ebx
f0100867:	b8 0e 00 00 00       	mov    $0xe,%eax
f010086c:	89 ca                	mov    %ecx,%edx
f010086e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010086f:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100872:	89 ca                	mov    %ecx,%edx
f0100874:	ec                   	in     (%dx),%al
f0100875:	0f b6 f8             	movzbl %al,%edi
f0100878:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010087b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100880:	89 da                	mov    %ebx,%edx
f0100882:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100883:	89 ca                	mov    %ecx,%edx
f0100885:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100886:	89 35 0c 50 27 f0    	mov    %esi,0xf027500c
	crt_pos = pos;
f010088c:	0f b6 c8             	movzbl %al,%ecx
f010088f:	09 cf                	or     %ecx,%edi
f0100891:	66 89 3d 10 50 27 f0 	mov    %di,0xf0275010

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100898:	e8 e2 fb ff ff       	call   f010047f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f010089d:	0f b7 05 70 53 12 f0 	movzwl 0xf0125370,%eax
f01008a4:	25 fd ff 00 00       	and    $0xfffd,%eax
f01008a9:	89 04 24             	mov    %eax,(%esp)
f01008ac:	e8 6a 3a 00 00       	call   f010431b <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01008b1:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01008b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01008bb:	89 da                	mov    %ebx,%edx
f01008bd:	ee                   	out    %al,(%dx)
f01008be:	b2 fb                	mov    $0xfb,%dl
f01008c0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01008c5:	ee                   	out    %al,(%dx)
f01008c6:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01008cb:	b8 0c 00 00 00       	mov    $0xc,%eax
f01008d0:	89 ca                	mov    %ecx,%edx
f01008d2:	ee                   	out    %al,(%dx)
f01008d3:	b2 f9                	mov    $0xf9,%dl
f01008d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008da:	ee                   	out    %al,(%dx)
f01008db:	b2 fb                	mov    $0xfb,%dl
f01008dd:	b8 03 00 00 00       	mov    $0x3,%eax
f01008e2:	ee                   	out    %al,(%dx)
f01008e3:	b2 fc                	mov    $0xfc,%dl
f01008e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ea:	ee                   	out    %al,(%dx)
f01008eb:	b2 f9                	mov    $0xf9,%dl
f01008ed:	b8 01 00 00 00       	mov    $0x1,%eax
f01008f2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01008f3:	b2 fd                	mov    $0xfd,%dl
f01008f5:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01008f6:	3c ff                	cmp    $0xff,%al
f01008f8:	0f 95 c0             	setne  %al
f01008fb:	0f b6 f0             	movzbl %al,%esi
f01008fe:	89 35 04 50 27 f0    	mov    %esi,0xf0275004
f0100904:	89 da                	mov    %ebx,%edx
f0100906:	ec                   	in     (%dx),%al
f0100907:	89 ca                	mov    %ecx,%edx
f0100909:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010090a:	85 f6                	test   %esi,%esi
f010090c:	75 0c                	jne    f010091a <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f010090e:	c7 04 24 af 80 10 f0 	movl   $0xf01080af,(%esp)
f0100915:	e8 31 3b 00 00       	call   f010444b <cprintf>
}
f010091a:	83 c4 1c             	add    $0x1c,%esp
f010091d:	5b                   	pop    %ebx
f010091e:	5e                   	pop    %esi
f010091f:	5f                   	pop    %edi
f0100920:	5d                   	pop    %ebp
f0100921:	c3                   	ret    
	...

f0100930 <read_eip>:
// return EIP of caller.
// does not work if inlined.
// putting at the end of the file seems to prevent inlining.
unsigned
read_eip()
{
f0100930:	55                   	push   %ebp
f0100931:	89 e5                	mov    %esp,%ebp
	uint32_t callerpc;
	__asm __volatile("movl 4(%%ebp), %0" : "=r" (callerpc));
f0100933:	8b 45 04             	mov    0x4(%ebp),%eax
	return callerpc;
}
f0100936:	5d                   	pop    %ebp
f0100937:	c3                   	ret    

f0100938 <start_overflow>:
    cprintf("Overflow success\n");
}

void
start_overflow(void)
{
f0100938:	55                   	push   %ebp
f0100939:	89 e5                	mov    %esp,%ebp
f010093b:	57                   	push   %edi
f010093c:	56                   	push   %esi
f010093d:	53                   	push   %ebx
f010093e:	81 ec 3c 01 00 00    	sub    $0x13c,%esp

    // hint: You can use the read_pretaddr function to retrieve 
    //       the pointer to the function call return address;
	//00000012 <do_overflow>: I shall overflow the esp
	//overflow me's ebp's value: $2 = 0xf010fe08
    char str[256] = {};
f0100944:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
f010094a:	b9 40 00 00 00       	mov    $0x40,%ecx
f010094f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100954:	f3 ab                	rep stos %eax,%es:(%edi)
    char *pret_addr;
	// Your code here.
	int i = 0;	
	while(i < 256)
	{
		str[i] = ' ';
f0100956:	8d 95 e8 fe ff ff    	lea    -0x118(%ebp),%edx
f010095c:	c6 04 02 20          	movb   $0x20,(%edx,%eax,1)
		i++;
f0100960:	83 c0 01             	add    $0x1,%eax
    char str[256] = {};
    int nstr = 0;
    char *pret_addr;
	// Your code here.
	int i = 0;	
	while(i < 256)
f0100963:	3d 00 01 00 00       	cmp    $0x100,%eax
f0100968:	75 f2                	jne    f010095c <start_overflow+0x24>
// Lab1 only
// read the pointer to the retaddr on the stack
static uint32_t
read_pretaddr() {
    uint32_t pretaddr;
    __asm __volatile("leal 4(%%ebp), %0" : "=r" (pretaddr)); 
f010096a:	8d 45 04             	lea    0x4(%ebp),%eax
f010096d:	89 85 d4 fe ff ff    	mov    %eax,-0x12c(%ebp)

static __inline uint32_t
read_ebp(void)
{
        uint32_t ebp;
        __asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100973:	89 e8                	mov    %ebp,%eax
	void (*doover)();
	doover = do_overflow;
	void (*overme)();

	uint32_t buffover[4];
	buffover[0] = (uint32_t)doover+3;
f0100975:	c7 85 d8 fe ff ff fa 	movl   $0xf01009fa,-0x128(%ebp)
f010097c:	09 10 f0 
f010097f:	bb 00 00 00 00       	mov    $0x0,%ebx
	i = 0;
	while(i < 4)
	{
		nstr = (buffover[i/4]>>(8*i)) & 0x000000ff;
		str[nstr] = '\0'; 
		cprintf("%s%n",str,pret_addr+i); 
f0100984:	8d bd e8 fe ff ff    	lea    -0x118(%ebp),%edi
	//buffover[1] = *((int *)(*((int *)ebp)));
	//buffover[2] = *((int *)(*((int *)ebp))+1);
	i = 0;
	while(i < 4)
	{
		nstr = (buffover[i/4]>>(8*i)) & 0x000000ff;
f010098a:	8d 43 03             	lea    0x3(%ebx),%eax
f010098d:	85 db                	test   %ebx,%ebx
f010098f:	0f 49 c3             	cmovns %ebx,%eax
f0100992:	c1 f8 02             	sar    $0x2,%eax
f0100995:	8d 0c dd 00 00 00 00 	lea    0x0(,%ebx,8),%ecx
f010099c:	8b b4 85 d8 fe ff ff 	mov    -0x128(%ebp,%eax,4),%esi
f01009a3:	d3 ee                	shr    %cl,%esi
f01009a5:	81 e6 ff 00 00 00    	and    $0xff,%esi
		str[nstr] = '\0'; 
f01009ab:	c6 84 35 e8 fe ff ff 	movb   $0x0,-0x118(%ebp,%esi,1)
f01009b2:	00 
		cprintf("%s%n",str,pret_addr+i); 
f01009b3:	8b 85 d4 fe ff ff    	mov    -0x12c(%ebp),%eax
f01009b9:	01 d8                	add    %ebx,%eax
f01009bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01009bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01009c3:	c7 04 24 d3 7f 10 f0 	movl   $0xf0107fd3,(%esp)
f01009ca:	e8 7c 3a 00 00       	call   f010444b <cprintf>
		//cprintf("%x---%x\n",nstr,*(pret_addr+i));
		str[nstr] = ' ';
f01009cf:	c6 84 35 e8 fe ff ff 	movb   $0x20,-0x118(%ebp,%esi,1)
f01009d6:	20 
		i++;
f01009d7:	83 c3 01             	add    $0x1,%ebx
	uint32_t buffover[4];
	buffover[0] = (uint32_t)doover+3;
	//buffover[1] = *((int *)(*((int *)ebp)));
	//buffover[2] = *((int *)(*((int *)ebp))+1);
	i = 0;
	while(i < 4)
f01009da:	83 fb 04             	cmp    $0x4,%ebx
f01009dd:	75 ab                	jne    f010098a <start_overflow+0x52>
		str[nstr] = ' ';
		i++;
	}


}
f01009df:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f01009e5:	5b                   	pop    %ebx
f01009e6:	5e                   	pop    %esi
f01009e7:	5f                   	pop    %edi
f01009e8:	5d                   	pop    %ebp
f01009e9:	c3                   	ret    

f01009ea <overflow_me>:

void
overflow_me(void)
{
f01009ea:	55                   	push   %ebp
f01009eb:	89 e5                	mov    %esp,%ebp
f01009ed:	83 ec 08             	sub    $0x8,%esp
        start_overflow();
f01009f0:	e8 43 ff ff ff       	call   f0100938 <start_overflow>
}
f01009f5:	c9                   	leave  
f01009f6:	c3                   	ret    

f01009f7 <do_overflow>:
    return pretaddr;
}

void
do_overflow(void)
{
f01009f7:	55                   	push   %ebp
f01009f8:	89 e5                	mov    %esp,%ebp
f01009fa:	83 ec 18             	sub    $0x18,%esp
    cprintf("Overflow success\n");
f01009fd:	c7 04 24 f0 82 10 f0 	movl   $0xf01082f0,(%esp)
f0100a04:	e8 42 3a 00 00       	call   f010444b <cprintf>
}
f0100a09:	c9                   	leave  
f0100a0a:	c3                   	ret    

f0100a0b <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100a0b:	55                   	push   %ebp
f0100a0c:	89 e5                	mov    %esp,%ebp
f0100a0e:	83 ec 18             	sub    $0x18,%esp
	extern char entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100a11:	c7 04 24 02 83 10 f0 	movl   $0xf0108302,(%esp)
f0100a18:	e8 2e 3a 00 00       	call   f010444b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100a1d:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100a24:	00 
f0100a25:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100a2c:	f0 
f0100a2d:	c7 04 24 cc 83 10 f0 	movl   $0xf01083cc,(%esp)
f0100a34:	e8 12 3a 00 00       	call   f010444b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100a39:	c7 44 24 08 65 7f 10 	movl   $0x107f65,0x8(%esp)
f0100a40:	00 
f0100a41:	c7 44 24 04 65 7f 10 	movl   $0xf0107f65,0x4(%esp)
f0100a48:	f0 
f0100a49:	c7 04 24 f0 83 10 f0 	movl   $0xf01083f0,(%esp)
f0100a50:	e8 f6 39 00 00       	call   f010444b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100a55:	c7 44 24 08 df 46 27 	movl   $0x2746df,0x8(%esp)
f0100a5c:	00 
f0100a5d:	c7 44 24 04 df 46 27 	movl   $0xf02746df,0x4(%esp)
f0100a64:	f0 
f0100a65:	c7 04 24 14 84 10 f0 	movl   $0xf0108414,(%esp)
f0100a6c:	e8 da 39 00 00       	call   f010444b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100a71:	c7 44 24 08 04 90 2b 	movl   $0x2b9004,0x8(%esp)
f0100a78:	00 
f0100a79:	c7 44 24 04 04 90 2b 	movl   $0xf02b9004,0x4(%esp)
f0100a80:	f0 
f0100a81:	c7 04 24 38 84 10 f0 	movl   $0xf0108438,(%esp)
f0100a88:	e8 be 39 00 00       	call   f010444b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100a8d:	b8 03 94 2b f0       	mov    $0xf02b9403,%eax
f0100a92:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100a97:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100a9d:	85 c0                	test   %eax,%eax
f0100a9f:	0f 48 c2             	cmovs  %edx,%eax
f0100aa2:	c1 f8 0a             	sar    $0xa,%eax
f0100aa5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aa9:	c7 04 24 5c 84 10 f0 	movl   $0xf010845c,(%esp)
f0100ab0:	e8 96 39 00 00       	call   f010444b <cprintf>
		(end-entry+1023)/1024);
	return 0;
}
f0100ab5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100aba:	c9                   	leave  
f0100abb:	c3                   	ret    

f0100abc <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
f0100abf:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100ac2:	a1 64 85 10 f0       	mov    0xf0108564,%eax
f0100ac7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100acb:	a1 60 85 10 f0       	mov    0xf0108560,%eax
f0100ad0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ad4:	c7 04 24 1b 83 10 f0 	movl   $0xf010831b,(%esp)
f0100adb:	e8 6b 39 00 00       	call   f010444b <cprintf>
f0100ae0:	a1 70 85 10 f0       	mov    0xf0108570,%eax
f0100ae5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ae9:	a1 6c 85 10 f0       	mov    0xf010856c,%eax
f0100aee:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100af2:	c7 04 24 1b 83 10 f0 	movl   $0xf010831b,(%esp)
f0100af9:	e8 4d 39 00 00       	call   f010444b <cprintf>
f0100afe:	a1 7c 85 10 f0       	mov    0xf010857c,%eax
f0100b03:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100b07:	a1 78 85 10 f0       	mov    0xf0108578,%eax
f0100b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b10:	c7 04 24 1b 83 10 f0 	movl   $0xf010831b,(%esp)
f0100b17:	e8 2f 39 00 00       	call   f010444b <cprintf>
	return 0;
}
f0100b1c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b21:	c9                   	leave  
f0100b22:	c3                   	ret    

f0100b23 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100b23:	55                   	push   %ebp
f0100b24:	89 e5                	mov    %esp,%ebp
f0100b26:	57                   	push   %edi
f0100b27:	56                   	push   %esi
f0100b28:	53                   	push   %ebx
f0100b29:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100b2c:	c7 04 24 88 84 10 f0 	movl   $0xf0108488,(%esp)
f0100b33:	e8 13 39 00 00       	call   f010444b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100b38:	c7 04 24 ac 84 10 f0 	movl   $0xf01084ac,(%esp)
f0100b3f:	e8 07 39 00 00       	call   f010444b <cprintf>

	if (tf != NULL)
f0100b44:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100b48:	74 0b                	je     f0100b55 <monitor+0x32>
		print_trapframe(tf);
f0100b4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b4d:	89 04 24             	mov    %eax,(%esp)
f0100b50:	e8 b6 3a 00 00       	call   f010460b <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100b55:	c7 04 24 24 83 10 f0 	movl   $0xf0108324,(%esp)
f0100b5c:	e8 4f 5b 00 00       	call   f01066b0 <readline>
f0100b61:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100b63:	85 c0                	test   %eax,%eax
f0100b65:	74 ee                	je     f0100b55 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100b67:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f0100b6e:	be 00 00 00 00       	mov    $0x0,%esi
f0100b73:	eb 06                	jmp    f0100b7b <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100b75:	c6 03 00             	movb   $0x0,(%ebx)
f0100b78:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100b7b:	0f b6 03             	movzbl (%ebx),%eax
f0100b7e:	84 c0                	test   %al,%al
f0100b80:	74 6a                	je     f0100bec <monitor+0xc9>
f0100b82:	0f be c0             	movsbl %al,%eax
f0100b85:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100b89:	c7 04 24 28 83 10 f0 	movl   $0xf0108328,(%esp)
f0100b90:	e8 76 5d 00 00       	call   f010690b <strchr>
f0100b95:	85 c0                	test   %eax,%eax
f0100b97:	75 dc                	jne    f0100b75 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100b99:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100b9c:	74 4e                	je     f0100bec <monitor+0xc9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100b9e:	83 fe 0f             	cmp    $0xf,%esi
f0100ba1:	75 16                	jne    f0100bb9 <monitor+0x96>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100ba3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100baa:	00 
f0100bab:	c7 04 24 2d 83 10 f0 	movl   $0xf010832d,(%esp)
f0100bb2:	e8 94 38 00 00       	call   f010444b <cprintf>
f0100bb7:	eb 9c                	jmp    f0100b55 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100bb9:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100bbd:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100bc0:	0f b6 03             	movzbl (%ebx),%eax
f0100bc3:	84 c0                	test   %al,%al
f0100bc5:	75 0c                	jne    f0100bd3 <monitor+0xb0>
f0100bc7:	eb b2                	jmp    f0100b7b <monitor+0x58>
			buf++;
f0100bc9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100bcc:	0f b6 03             	movzbl (%ebx),%eax
f0100bcf:	84 c0                	test   %al,%al
f0100bd1:	74 a8                	je     f0100b7b <monitor+0x58>
f0100bd3:	0f be c0             	movsbl %al,%eax
f0100bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100bda:	c7 04 24 28 83 10 f0 	movl   $0xf0108328,(%esp)
f0100be1:	e8 25 5d 00 00       	call   f010690b <strchr>
f0100be6:	85 c0                	test   %eax,%eax
f0100be8:	74 df                	je     f0100bc9 <monitor+0xa6>
f0100bea:	eb 8f                	jmp    f0100b7b <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f0100bec:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100bf3:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100bf4:	85 f6                	test   %esi,%esi
f0100bf6:	0f 84 59 ff ff ff    	je     f0100b55 <monitor+0x32>
f0100bfc:	bb 60 85 10 f0       	mov    $0xf0108560,%ebx
f0100c01:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100c06:	8b 03                	mov    (%ebx),%eax
f0100c08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c0c:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c0f:	89 04 24             	mov    %eax,(%esp)
f0100c12:	e8 7e 5c 00 00       	call   f0106895 <strcmp>
f0100c17:	85 c0                	test   %eax,%eax
f0100c19:	75 23                	jne    f0100c3e <monitor+0x11b>
			return commands[i].func(argc, argv, tf);
f0100c1b:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c21:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100c25:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100c28:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c2c:	89 34 24             	mov    %esi,(%esp)
f0100c2f:	ff 97 68 85 10 f0    	call   *-0xfef7a98(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100c35:	85 c0                	test   %eax,%eax
f0100c37:	78 28                	js     f0100c61 <monitor+0x13e>
f0100c39:	e9 17 ff ff ff       	jmp    f0100b55 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100c3e:	83 c7 01             	add    $0x1,%edi
f0100c41:	83 c3 0c             	add    $0xc,%ebx
f0100c44:	83 ff 03             	cmp    $0x3,%edi
f0100c47:	75 bd                	jne    f0100c06 <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100c49:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100c50:	c7 04 24 4a 83 10 f0 	movl   $0xf010834a,(%esp)
f0100c57:	e8 ef 37 00 00       	call   f010444b <cprintf>
f0100c5c:	e9 f4 fe ff ff       	jmp    f0100b55 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100c61:	83 c4 5c             	add    $0x5c,%esp
f0100c64:	5b                   	pop    %ebx
f0100c65:	5e                   	pop    %esi
f0100c66:	5f                   	pop    %edi
f0100c67:	5d                   	pop    %ebp
f0100c68:	c3                   	ret    

f0100c69 <mon_backtrace>:
        start_overflow();
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100c69:	55                   	push   %ebp
f0100c6a:	89 e5                	mov    %esp,%ebp
f0100c6c:	57                   	push   %edi
f0100c6d:	56                   	push   %esi
f0100c6e:	53                   	push   %ebx
f0100c6f:	83 ec 5c             	sub    $0x5c,%esp
f0100c72:	89 eb                	mov    %ebp,%ebx
	// Your code here.
	struct Eipdebuginfo info;
	uint32_t ebp =  read_ebp();
	uint32_t eip =  read_eip();
f0100c74:	e8 b7 fc ff ff       	call   f0100930 <read_eip>
f0100c79:	89 c7                	mov    %eax,%edi
	uint32_t arg[5];
	memset(arg,0,5);
f0100c7b:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
f0100c82:	00 
f0100c83:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100c8a:	00 
f0100c8b:	8d 45 bc             	lea    -0x44(%ebp),%eax
f0100c8e:	89 04 24             	mov    %eax,(%esp)
f0100c91:	e8 d0 5c 00 00       	call   f0106966 <memset>
	cprintf("Stack backtrace:\n");
f0100c96:	c7 04 24 60 83 10 f0 	movl   $0xf0108360,(%esp)
f0100c9d:	e8 a9 37 00 00       	call   f010444b <cprintf>
		eip = *((uint32_t*)ebp+1);
		ebp = *((uint32_t*)ebp);		
		int i = 0;
		while(i<5)
		{
			arg[i] = *((uint32_t*)ebp+2+i);
f0100ca2:	8d 75 bc             	lea    -0x44(%ebp),%esi
	uint32_t arg[5];
	memset(arg,0,5);
	cprintf("Stack backtrace:\n");
	do{
		
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x \n",ebp,eip,arg[0],arg[1],arg[2],arg[3],arg[4]);
f0100ca5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0100ca8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100cac:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0100caf:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100cb3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100cb6:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100cba:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100cbd:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100cc1:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100cc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cc8:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0100ccc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100cd0:	c7 04 24 d4 84 10 f0 	movl   $0xf01084d4,(%esp)
f0100cd7:	e8 6f 37 00 00       	call   f010444b <cprintf>
		
		debuginfo_eip((uintptr_t)eip,&info);
f0100cdc:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0100cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce3:	89 3c 24             	mov    %edi,(%esp)
f0100ce6:	e8 23 50 00 00       	call   f0105d0e <debuginfo_eip>
		cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip -info.eip_fn_addr);
f0100ceb:	2b 7d e0             	sub    -0x20(%ebp),%edi
f0100cee:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0100cf2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100cf5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cf9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100cfc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d00:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100d03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d07:	c7 04 24 72 83 10 f0 	movl   $0xf0108372,(%esp)
f0100d0e:	e8 38 37 00 00       	call   f010444b <cprintf>

		eip = *((uint32_t*)ebp+1);
f0100d13:	8b 7b 04             	mov    0x4(%ebx),%edi
		ebp = *((uint32_t*)ebp);		
f0100d16:	8b 1b                	mov    (%ebx),%ebx
f0100d18:	b8 00 00 00 00       	mov    $0x0,%eax
		int i = 0;
		while(i<5)
		{
			arg[i] = *((uint32_t*)ebp+2+i);
f0100d1d:	8b 54 83 08          	mov    0x8(%ebx,%eax,4),%edx
f0100d21:	89 14 86             	mov    %edx,(%esi,%eax,4)
			i++;
f0100d24:	83 c0 01             	add    $0x1,%eax
		cprintf("\t%s:%d: %s+%d\n",info.eip_file,info.eip_line,info.eip_fn_name,eip -info.eip_fn_addr);

		eip = *((uint32_t*)ebp+1);
		ebp = *((uint32_t*)ebp);		
		int i = 0;
		while(i<5)
f0100d27:	83 f8 05             	cmp    $0x5,%eax
f0100d2a:	75 f1                	jne    f0100d1d <mon_backtrace+0xb4>
		{
			arg[i] = *((uint32_t*)ebp+2+i);
			i++;
		}
	}while(ebp != 0);
f0100d2c:	85 db                	test   %ebx,%ebx
f0100d2e:	0f 85 71 ff ff ff    	jne    f0100ca5 <mon_backtrace+0x3c>

	
	

    overflow_me();
f0100d34:	e8 b1 fc ff ff       	call   f01009ea <overflow_me>
    cprintf("Backtrace success\n");
f0100d39:	c7 04 24 81 83 10 f0 	movl   $0xf0108381,(%esp)
f0100d40:	e8 06 37 00 00       	call   f010444b <cprintf>
	return 0;
}
f0100d45:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d4a:	83 c4 5c             	add    $0x5c,%esp
f0100d4d:	5b                   	pop    %ebx
f0100d4e:	5e                   	pop    %esi
f0100d4f:	5f                   	pop    %edi
f0100d50:	5d                   	pop    %ebp
f0100d51:	c3                   	ret    
	...

f0100d60 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100d60:	55                   	push   %ebp
f0100d61:	89 e5                	mov    %esp,%ebp
f0100d63:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100d65:	83 3d 28 52 27 f0 00 	cmpl   $0x0,0xf0275228
f0100d6c:	75 0f                	jne    f0100d7d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d6e:	b8 03 a0 2b f0       	mov    $0xf02ba003,%eax
f0100d73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100d78:	a3 28 52 27 f0       	mov    %eax,0xf0275228
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = ROUNDUP(nextfree,PGSIZE);
f0100d7d:	a1 28 52 27 f0       	mov    0xf0275228,%eax
f0100d82:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100d87:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	nextfree = result + n;
f0100d8c:	8d 14 10             	lea    (%eax,%edx,1),%edx
f0100d8f:	89 15 28 52 27 f0    	mov    %edx,0xf0275228
	
	return result;
}
f0100d95:	5d                   	pop    %ebp
f0100d96:	c3                   	ret    

f0100d97 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct Page *pp)
{
f0100d97:	55                   	push   %ebp
f0100d98:	89 e5                	mov    %esp,%ebp
f0100d9a:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	//cprintf("want to free :%d\t%d\n",pp->pp_ref,PGNUM(page2pa(pp)));
	if(pp->pp_ref) //should be no reference
f0100d9d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100da2:	75 0d                	jne    f0100db1 <page_free+0x1a>
		return;
	pp->pp_link = page_free_list;
f0100da4:	8b 15 30 52 27 f0    	mov    0xf0275230,%edx
f0100daa:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100dac:	a3 30 52 27 f0       	mov    %eax,0xf0275230
	//cprintf("have free what?:%d\n",PGNUM(page2pa(page_free_list)));
	
	
}
f0100db1:	5d                   	pop    %ebp
f0100db2:	c3                   	ret    

f0100db3 <page_free_4pages>:
//	2. Add the pages to the chunck list.
//	
//	Return 0 if everything ok
int
page_free_4pages(struct Page *pp)
{
f0100db3:	55                   	push   %ebp
f0100db4:	89 e5                	mov    %esp,%ebp
f0100db6:	53                   	push   %ebx
f0100db7:	83 ec 04             	sub    $0x4,%esp
f0100dba:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100dbd:	85 c0                	test   %eax,%eax
f0100dbf:	75 2d                	jne    f0100dee <page_free_4pages+0x3b>
f0100dc1:	eb 20                	jmp    f0100de3 <page_free_4pages+0x30>
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
	}
	checktolast->pp_link = chunck_list.pp_link;
f0100dc3:	8b 15 34 52 27 f0    	mov    0xf0275234,%edx
f0100dc9:	89 11                	mov    %edx,(%ecx)
	chunck_list.pp_link = pp;
	while(chunck_list.pp_link!=NULL)
	{
		pp = chunck_list.pp_link;
		chunck_list.pp_link = chunck_list.pp_link->pp_link;
f0100dcb:	8b 18                	mov    (%eax),%ebx
		page_free(pp);
f0100dcd:	89 04 24             	mov    %eax,(%esp)
f0100dd0:	e8 c2 ff ff ff       	call   f0100d97 <page_free>
f0100dd5:	89 d8                	mov    %ebx,%eax
			break;
		checktolast = checktolast->pp_link;
	}
	checktolast->pp_link = chunck_list.pp_link;
	chunck_list.pp_link = pp;
	while(chunck_list.pp_link!=NULL)
f0100dd7:	85 db                	test   %ebx,%ebx
f0100dd9:	75 f0                	jne    f0100dcb <page_free_4pages+0x18>
f0100ddb:	89 1d 34 52 27 f0    	mov    %ebx,0xf0275234
f0100de1:	eb 05                	jmp    f0100de8 <page_free_4pages+0x35>
f0100de3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		pp = chunck_list.pp_link;
		chunck_list.pp_link = chunck_list.pp_link->pp_link;
		page_free(pp);
	}
	return 0;
}
f0100de8:	83 c4 04             	add    $0x4,%esp
f0100deb:	5b                   	pop    %ebx
f0100dec:	5d                   	pop    %ebp
f0100ded:	c3                   	ret    
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
f0100dee:	8b 10                	mov    (%eax),%edx
{
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100df0:	85 d2                	test   %edx,%edx
f0100df2:	74 ef                	je     f0100de3 <page_free_4pages+0x30>
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
f0100df4:	8b 12                	mov    (%edx),%edx
{
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100df6:	85 d2                	test   %edx,%edx
f0100df8:	74 e9                	je     f0100de3 <page_free_4pages+0x30>
			return -1;
		if(i==3)
			break;
		checktolast = checktolast->pp_link;
f0100dfa:	8b 0a                	mov    (%edx),%ecx
{
	// Fill this function
	struct Page* checktolast = pp;
	int i;
	for(i = 0;i<4;i++){ //should all be no reference
		if(!checktolast)
f0100dfc:	85 c9                	test   %ecx,%ecx
f0100dfe:	75 c3                	jne    f0100dc3 <page_free_4pages+0x10>
f0100e00:	eb e1                	jmp    f0100de3 <page_free_4pages+0x30>

f0100e02 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct Page* pp)
{
f0100e02:	55                   	push   %ebp
f0100e03:	89 e5                	mov    %esp,%ebp
f0100e05:	83 ec 04             	sub    $0x4,%esp
f0100e08:	8b 45 08             	mov    0x8(%ebp),%eax
	//cprintf("in\n");
	if (--pp->pp_ref == 0)
f0100e0b:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100e0f:	83 ea 01             	sub    $0x1,%edx
f0100e12:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100e16:	66 85 d2             	test   %dx,%dx
f0100e19:	75 08                	jne    f0100e23 <page_decref+0x21>
		page_free(pp);
f0100e1b:	89 04 24             	mov    %eax,(%esp)
f0100e1e:	e8 74 ff ff ff       	call   f0100d97 <page_free>
	//cprintf("out\n");
}
f0100e23:	c9                   	leave  
f0100e24:	c3                   	ret    

f0100e25 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100e25:	55                   	push   %ebp
f0100e26:	89 e5                	mov    %esp,%ebp
f0100e28:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100e2b:	e8 e2 61 00 00       	call   f0107012 <cpunum>
f0100e30:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e33:	83 b8 28 80 27 f0 00 	cmpl   $0x0,-0xfd87fd8(%eax)
f0100e3a:	74 16                	je     f0100e52 <tlb_invalidate+0x2d>
f0100e3c:	e8 d1 61 00 00       	call   f0107012 <cpunum>
f0100e41:	6b c0 74             	imul   $0x74,%eax,%eax
f0100e44:	8b 90 28 80 27 f0    	mov    -0xfd87fd8(%eax),%edx
f0100e4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e4d:	39 42 60             	cmp    %eax,0x60(%edx)
f0100e50:	75 06                	jne    f0100e58 <tlb_invalidate+0x33>
}

static __inline void 
invlpg(void *addr)
{ 
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100e52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e55:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100e58:	c9                   	leave  
f0100e59:	c3                   	ret    

f0100e5a <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100e5a:	55                   	push   %ebp
f0100e5b:	89 e5                	mov    %esp,%ebp
f0100e5d:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	//cprintf("check pde\n");
	if (!(*pgdir & PTE_P))
f0100e60:	89 d1                	mov    %edx,%ecx
f0100e62:	c1 e9 16             	shr    $0x16,%ecx
f0100e65:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100e68:	a8 01                	test   $0x1,%al
f0100e6a:	74 4d                	je     f0100eb9 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100e6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e71:	89 c1                	mov    %eax,%ecx
f0100e73:	c1 e9 0c             	shr    $0xc,%ecx
f0100e76:	3b 0d 94 5e 27 f0    	cmp    0xf0275e94,%ecx
f0100e7c:	72 20                	jb     f0100e9e <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e7e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e82:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0100e89:	f0 
f0100e8a:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0100e91:	00 
f0100e92:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0100e99:	e8 e7 f1 ff ff       	call   f0100085 <_panic>
	//cprintf("check pte\n");
	if (!(p[PTX(va)] & PTE_P))
f0100e9e:	c1 ea 0c             	shr    $0xc,%edx
f0100ea1:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ea7:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100eae:	a8 01                	test   $0x1,%al
f0100eb0:	74 07                	je     f0100eb9 <check_va2pa+0x5f>
		return ~0;
	//cprintf("return addr\n");
	return PTE_ADDR(p[PTX(va)]);
f0100eb2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100eb7:	eb 05                	jmp    f0100ebe <check_va2pa+0x64>
f0100eb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100ebe:	c9                   	leave  
f0100ebf:	c3                   	ret    

f0100ec0 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100ec0:	55                   	push   %ebp
f0100ec1:	89 e5                	mov    %esp,%ebp
f0100ec3:	83 ec 18             	sub    $0x18,%esp
f0100ec6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100ec9:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100ecc:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ece:	89 04 24             	mov    %eax,(%esp)
f0100ed1:	e8 0a 34 00 00       	call   f01042e0 <mc146818_read>
f0100ed6:	89 c6                	mov    %eax,%esi
f0100ed8:	83 c3 01             	add    $0x1,%ebx
f0100edb:	89 1c 24             	mov    %ebx,(%esp)
f0100ede:	e8 fd 33 00 00       	call   f01042e0 <mc146818_read>
f0100ee3:	c1 e0 08             	shl    $0x8,%eax
f0100ee6:	09 f0                	or     %esi,%eax
}
f0100ee8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100eeb:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100eee:	89 ec                	mov    %ebp,%esp
f0100ef0:	5d                   	pop    %ebp
f0100ef1:	c3                   	ret    

f0100ef2 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ef2:	55                   	push   %ebp
f0100ef3:	89 e5                	mov    %esp,%ebp
f0100ef5:	57                   	push   %edi
f0100ef6:	56                   	push   %esi
f0100ef7:	53                   	push   %ebx
f0100ef8:	83 ec 5c             	sub    $0x5c,%esp
	struct Page *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100efb:	83 f8 01             	cmp    $0x1,%eax
f0100efe:	19 f6                	sbb    %esi,%esi
f0100f00:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100f06:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100f09:	8b 1d 30 52 27 f0    	mov    0xf0275230,%ebx
f0100f0f:	85 db                	test   %ebx,%ebx
f0100f11:	75 1c                	jne    f0100f2f <check_page_free_list+0x3d>
		panic("'page_free_list' is a null pointer!");
f0100f13:	c7 44 24 08 84 85 10 	movl   $0xf0108584,0x8(%esp)
f0100f1a:	f0 
f0100f1b:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0100f22:	00 
f0100f23:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0100f2a:	e8 56 f1 ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f0100f2f:	85 c0                	test   %eax,%eax
f0100f31:	74 52                	je     f0100f85 <check_page_free_list+0x93>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
f0100f33:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100f36:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100f39:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100f3c:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f3f:	8b 0d 9c 5e 27 f0    	mov    0xf0275e9c,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100f45:	89 d8                	mov    %ebx,%eax
f0100f47:	29 c8                	sub    %ecx,%eax
f0100f49:	c1 e0 09             	shl    $0x9,%eax
f0100f4c:	c1 e8 16             	shr    $0x16,%eax
f0100f4f:	39 c6                	cmp    %eax,%esi
f0100f51:	0f 96 c0             	setbe  %al
f0100f54:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100f57:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100f5b:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100f5d:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct Page *pp1, *pp2;
		struct Page **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100f61:	8b 1b                	mov    (%ebx),%ebx
f0100f63:	85 db                	test   %ebx,%ebx
f0100f65:	75 de                	jne    f0100f45 <check_page_free_list+0x53>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100f67:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100f6a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100f70:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100f73:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100f76:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100f78:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f7b:	89 1d 30 52 27 f0    	mov    %ebx,0xf0275230
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100f81:	85 db                	test   %ebx,%ebx
f0100f83:	74 67                	je     f0100fec <check_page_free_list+0xfa>
f0100f85:	89 d8                	mov    %ebx,%eax
f0100f87:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f0100f8d:	c1 f8 03             	sar    $0x3,%eax
f0100f90:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100f93:	89 c2                	mov    %eax,%edx
f0100f95:	c1 ea 16             	shr    $0x16,%edx
f0100f98:	39 d6                	cmp    %edx,%esi
f0100f9a:	76 4a                	jbe    f0100fe6 <check_page_free_list+0xf4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f9c:	89 c2                	mov    %eax,%edx
f0100f9e:	c1 ea 0c             	shr    $0xc,%edx
f0100fa1:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0100fa7:	72 20                	jb     f0100fc9 <check_page_free_list+0xd7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fad:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0100fb4:	f0 
f0100fb5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0100fbc:	00 
f0100fbd:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0100fc4:	e8 bc f0 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100fc9:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100fd0:	00 
f0100fd1:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100fd8:	00 
f0100fd9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fde:	89 04 24             	mov    %eax,(%esp)
f0100fe1:	e8 80 59 00 00       	call   f0106966 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link){
f0100fe6:	8b 1b                	mov    (%ebx),%ebx
f0100fe8:	85 db                	test   %ebx,%ebx
f0100fea:	75 99                	jne    f0100f85 <check_page_free_list+0x93>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
f0100fec:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff1:	e8 6a fd ff ff       	call   f0100d60 <boot_alloc>
f0100ff6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ff9:	8b 15 30 52 27 f0    	mov    0xf0275230,%edx
f0100fff:	85 d2                	test   %edx,%edx
f0101001:	0f 84 3c 02 00 00    	je     f0101243 <check_page_free_list+0x351>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0101007:	8b 1d 9c 5e 27 f0    	mov    0xf0275e9c,%ebx
f010100d:	39 da                	cmp    %ebx,%edx
f010100f:	72 51                	jb     f0101062 <check_page_free_list+0x170>
		assert(pp < pages + npages);
f0101011:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f0101016:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0101019:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f010101c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010101f:	39 c2                	cmp    %eax,%edx
f0101021:	73 68                	jae    f010108b <check_page_free_list+0x199>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101023:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101026:	89 d0                	mov    %edx,%eax
f0101028:	29 d8                	sub    %ebx,%eax
f010102a:	a8 07                	test   $0x7,%al
f010102c:	0f 85 86 00 00 00    	jne    f01010b8 <check_page_free_list+0x1c6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101032:	c1 f8 03             	sar    $0x3,%eax
f0101035:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0101038:	85 c0                	test   %eax,%eax
f010103a:	0f 84 a6 00 00 00    	je     f01010e6 <check_page_free_list+0x1f4>
		assert(page2pa(pp) != IOPHYSMEM);
f0101040:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101045:	0f 84 c6 00 00 00    	je     f0101111 <check_page_free_list+0x21f>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010104b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101050:	0f 85 0a 01 00 00    	jne    f0101160 <check_page_free_list+0x26e>
f0101056:	66 90                	xchg   %ax,%ax
f0101058:	e9 df 00 00 00       	jmp    f010113c <check_page_free_list+0x24a>
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010105d:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0101060:	73 24                	jae    f0101086 <check_page_free_list+0x194>
f0101062:	c7 44 24 0c bb 8c 10 	movl   $0xf0108cbb,0xc(%esp)
f0101069:	f0 
f010106a:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101071:	f0 
f0101072:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101079:	00 
f010107a:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101081:	e8 ff ef ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0101086:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101089:	72 24                	jb     f01010af <check_page_free_list+0x1bd>
f010108b:	c7 44 24 0c dc 8c 10 	movl   $0xf0108cdc,0xc(%esp)
f0101092:	f0 
f0101093:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010109a:	f0 
f010109b:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f01010a2:	00 
f01010a3:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01010aa:	e8 d6 ef ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01010af:	89 d0                	mov    %edx,%eax
f01010b1:	2b 45 cc             	sub    -0x34(%ebp),%eax
f01010b4:	a8 07                	test   $0x7,%al
f01010b6:	74 24                	je     f01010dc <check_page_free_list+0x1ea>
f01010b8:	c7 44 24 0c a8 85 10 	movl   $0xf01085a8,0xc(%esp)
f01010bf:	f0 
f01010c0:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01010c7:	f0 
f01010c8:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f01010cf:	00 
f01010d0:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01010d7:	e8 a9 ef ff ff       	call   f0100085 <_panic>
f01010dc:	c1 f8 03             	sar    $0x3,%eax
f01010df:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01010e2:	85 c0                	test   %eax,%eax
f01010e4:	75 24                	jne    f010110a <check_page_free_list+0x218>
f01010e6:	c7 44 24 0c f0 8c 10 	movl   $0xf0108cf0,0xc(%esp)
f01010ed:	f0 
f01010ee:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01010f5:	f0 
f01010f6:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f01010fd:	00 
f01010fe:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101105:	e8 7b ef ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f010110a:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f010110f:	75 24                	jne    f0101135 <check_page_free_list+0x243>
f0101111:	c7 44 24 0c 01 8d 10 	movl   $0xf0108d01,0xc(%esp)
f0101118:	f0 
f0101119:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101120:	f0 
f0101121:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101128:	00 
f0101129:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101130:	e8 50 ef ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101135:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010113a:	75 31                	jne    f010116d <check_page_free_list+0x27b>
f010113c:	c7 44 24 0c dc 85 10 	movl   $0xf01085dc,0xc(%esp)
f0101143:	f0 
f0101144:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010114b:	f0 
f010114c:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101153:	00 
f0101154:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010115b:	e8 25 ef ff ff       	call   f0100085 <_panic>
f0101160:	be 00 00 00 00       	mov    $0x0,%esi
f0101165:	bf 00 00 00 00       	mov    $0x0,%edi
f010116a:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f010116d:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101172:	75 24                	jne    f0101198 <check_page_free_list+0x2a6>
f0101174:	c7 44 24 0c 1a 8d 10 	movl   $0xf0108d1a,0xc(%esp)
f010117b:	f0 
f010117c:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101183:	f0 
f0101184:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f010118b:	00 
f010118c:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101193:	e8 ed ee ff ff       	call   f0100085 <_panic>
f0101198:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010119a:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f010119f:	76 59                	jbe    f01011fa <check_page_free_list+0x308>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011a1:	89 c3                	mov    %eax,%ebx
f01011a3:	c1 eb 0c             	shr    $0xc,%ebx
f01011a6:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f01011a9:	77 20                	ja     f01011cb <check_page_free_list+0x2d9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011af:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01011b6:	f0 
f01011b7:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01011be:	00 
f01011bf:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f01011c6:	e8 ba ee ff ff       	call   f0100085 <_panic>
f01011cb:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01011d1:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01011d4:	76 24                	jbe    f01011fa <check_page_free_list+0x308>
f01011d6:	c7 44 24 0c 00 86 10 	movl   $0xf0108600,0xc(%esp)
f01011dd:	f0 
f01011de:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01011e5:	f0 
f01011e6:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f01011ed:	00 
f01011ee:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01011f5:	e8 8b ee ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01011fa:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01011ff:	75 24                	jne    f0101225 <check_page_free_list+0x333>
f0101201:	c7 44 24 0c 34 8d 10 	movl   $0xf0108d34,0xc(%esp)
f0101208:	f0 
f0101209:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101210:	f0 
f0101211:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101218:	00 
f0101219:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101220:	e8 60 ee ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0101225:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f010122b:	77 05                	ja     f0101232 <check_page_free_list+0x340>
			++nfree_basemem;
f010122d:	83 c7 01             	add    $0x1,%edi
f0101230:	eb 03                	jmp    f0101235 <check_page_free_list+0x343>
		else
			++nfree_extmem;
f0101232:	83 c6 01             	add    $0x1,%esi
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);
	}

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0101235:	8b 12                	mov    (%edx),%edx
f0101237:	85 d2                	test   %edx,%edx
f0101239:	0f 85 1e fe ff ff    	jne    f010105d <check_page_free_list+0x16b>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f010123f:	85 ff                	test   %edi,%edi
f0101241:	7f 24                	jg     f0101267 <check_page_free_list+0x375>
f0101243:	c7 44 24 0c 51 8d 10 	movl   $0xf0108d51,0xc(%esp)
f010124a:	f0 
f010124b:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101252:	f0 
f0101253:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f010125a:	00 
f010125b:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101262:	e8 1e ee ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f0101267:	85 f6                	test   %esi,%esi
f0101269:	7f 24                	jg     f010128f <check_page_free_list+0x39d>
f010126b:	c7 44 24 0c 63 8d 10 	movl   $0xf0108d63,0xc(%esp)
f0101272:	f0 
f0101273:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010127a:	f0 
f010127b:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101282:	00 
f0101283:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010128a:	e8 f6 ed ff ff       	call   f0100085 <_panic>
}
f010128f:	83 c4 5c             	add    $0x5c,%esp
f0101292:	5b                   	pop    %ebx
f0101293:	5e                   	pop    %esi
f0101294:	5f                   	pop    %edi
f0101295:	5d                   	pop    %ebp
f0101296:	c3                   	ret    

f0101297 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0101297:	55                   	push   %ebp
f0101298:	89 e5                	mov    %esp,%ebp
f010129a:	57                   	push   %edi
f010129b:	56                   	push   %esi
f010129c:	53                   	push   %ebx
f010129d:	83 ec 2c             	sub    $0x2c,%esp
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012a0:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f01012a5:	83 f8 07             	cmp    $0x7,%eax
f01012a8:	77 1c                	ja     f01012c6 <page_init+0x2f>
		panic("pa2page called with invalid pa");
f01012aa:	c7 44 24 08 48 86 10 	movl   $0xf0108648,0x8(%esp)
f01012b1:	f0 
f01012b2:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f01012b9:	00 
f01012ba:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f01012c1:	e8 bf ed ff ff       	call   f0100085 <_panic>
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list = NULL;
f01012c6:	c7 05 30 52 27 f0 00 	movl   $0x0,0xf0275230
f01012cd:	00 00 00 
	size_t i;
	//cprintf("%d\t%d\t%d\n",PGNUM(EXTPHYSMEM),npages,up);
	for (i = 0; i < npages; i++) {
f01012d0:	85 c0                	test   %eax,%eax
f01012d2:	0f 85 a4 00 00 00    	jne    f010137c <page_init+0xe5>
f01012d8:	e9 b6 00 00 00       	jmp    f0101393 <page_init+0xfc>
f01012dd:	8d 34 dd 00 00 00 00 	lea    0x0(,%ebx,8),%esi
		pages[i].pp_ref = 0;
f01012e4:	a1 9c 5e 27 f0       	mov    0xf0275e9c,%eax
f01012e9:	66 c7 44 30 04 00 00 	movw   $0x0,0x4(%eax,%esi,1)
		if(i == 0)
f01012f0:	85 db                	test   %ebx,%ebx
f01012f2:	74 71                	je     f0101365 <page_init+0xce>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01012f4:	89 f0                	mov    %esi,%eax
f01012f6:	c1 e0 09             	shl    $0x9,%eax
			continue;
		if (page2pa(&pages[i]) == MPENTRY_PADDR)
f01012f9:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01012fe:	74 65                	je     f0101365 <page_init+0xce>
f0101300:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		if(	page2pa(&pages[i]) >= IOPHYSMEM && 
f0101303:	3d ff ff 09 00       	cmp    $0x9ffff,%eax
f0101308:	76 4b                	jbe    f0101355 <page_init+0xbe>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010130a:	c1 e8 0c             	shr    $0xc,%eax
f010130d:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0101313:	72 29                	jb     f010133e <page_init+0xa7>
f0101315:	89 3d 30 52 27 f0    	mov    %edi,0xf0275230
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010131b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010131e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101322:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101329:	f0 
f010132a:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0101331:	00 
f0101332:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0101339:	e8 47 ed ff ff       	call   f0100085 <_panic>
			page2kva(&pages[i]) < boot_alloc(0)) 
f010133e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101343:	e8 18 fa ff ff       	call   f0100d60 <boot_alloc>
		pages[i].pp_ref = 0;
		if(i == 0)
			continue;
		if (page2pa(&pages[i]) == MPENTRY_PADDR)
			continue;
		if(	page2pa(&pages[i]) >= IOPHYSMEM && 
f0101348:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010134b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101351:	39 d0                	cmp    %edx,%eax
f0101353:	77 10                	ja     f0101365 <page_init+0xce>
			page2kva(&pages[i]) < boot_alloc(0)) 
			continue;
		pages[i].pp_link = page_free_list;
f0101355:	a1 9c 5e 27 f0       	mov    0xf0275e9c,%eax
f010135a:	89 3c 30             	mov    %edi,(%eax,%esi,1)
		page_free_list = &pages[i];
f010135d:	89 f7                	mov    %esi,%edi
f010135f:	03 3d 9c 5e 27 f0    	add    0xf0275e9c,%edi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	page_free_list = NULL;
	size_t i;
	//cprintf("%d\t%d\t%d\n",PGNUM(EXTPHYSMEM),npages,up);
	for (i = 0; i < npages; i++) {
f0101365:	83 c3 01             	add    $0x1,%ebx
f0101368:	39 1d 94 5e 27 f0    	cmp    %ebx,0xf0275e94
f010136e:	0f 87 69 ff ff ff    	ja     f01012dd <page_init+0x46>
f0101374:	89 3d 30 52 27 f0    	mov    %edi,0xf0275230
f010137a:	eb 17                	jmp    f0101393 <page_init+0xfc>
		pages[i].pp_ref = 0;
f010137c:	a1 9c 5e 27 f0       	mov    0xf0275e9c,%eax
f0101381:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
f0101387:	bf 00 00 00 00       	mov    $0x0,%edi
f010138c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101391:	eb d2                	jmp    f0101365 <page_init+0xce>
			page2kva(&pages[i]) < boot_alloc(0)) 
			continue;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0101393:	83 c4 2c             	add    $0x2c,%esp
f0101396:	5b                   	pop    %ebx
f0101397:	5e                   	pop    %esi
f0101398:	5f                   	pop    %edi
f0101399:	5d                   	pop    %ebp
f010139a:	c3                   	ret    

f010139b <page_alloc_4pages>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc_4pages(int alloc_flags)
{
f010139b:	55                   	push   %ebp
f010139c:	89 e5                	mov    %esp,%ebp
f010139e:	57                   	push   %edi
f010139f:	56                   	push   %esi
f01013a0:	53                   	push   %ebx
f01013a1:	83 ec 5c             	sub    $0x5c,%esp
	// Fill this function
	struct Page  head; //
	struct Page* result,*first_free;
	struct Page	*check,*find;
	struct Page* last[4] = {NULL,NULL,NULL,NULL};
f01013a4:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f01013ab:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01013b2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01013b9:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	
	//check if there are enough space and continuous space
	check = page_free_list;
f01013c0:	a1 30 52 27 f0       	mov    0xf0275230,%eax
f01013c5:	89 45 b8             	mov    %eax,-0x48(%ebp)
	while(check != NULL)
f01013c8:	85 c0                	test   %eax,%eax
f01013ca:	0f 84 cc 02 00 00    	je     f010169c <page_alloc_4pages+0x301>
		check = check->pp_link;
f01013d0:	8b 00                	mov    (%eax),%eax
	struct Page	*check,*find;
	struct Page* last[4] = {NULL,NULL,NULL,NULL};
	
	//check if there are enough space and continuous space
	check = page_free_list;
	while(check != NULL)
f01013d2:	85 c0                	test   %eax,%eax
f01013d4:	75 fa                	jne    f01013d0 <page_alloc_4pages+0x35>
f01013d6:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01013d9:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01013dc:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
		if(i == 4 && find == NULL)
		{
			//cprintf("find here:%d\n",PGNUM(page2pa(check)));
			find = check;
			check = &head;
			check->pp_link = page_free_list;
f01013e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01013e6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01013e9:	e9 58 01 00 00       	jmp    f0101546 <page_alloc_4pages+0x1ab>
	struct Page	*check,*find;
	struct Page* last[4] = {NULL,NULL,NULL,NULL};
	
	//check if there are enough space and continuous space
	check = page_free_list;
	while(check != NULL)
f01013ee:	89 df                	mov    %ebx,%edi
f01013f0:	c1 e7 0c             	shl    $0xc,%edi
		//if(find == NULL)
			//cprintf("show:%d\n",PGNUM(page2pa(check))); 
		for(i=0;find == NULL && i<4 ;i++)//how to improve the efficience can i use a flag?
		{
			//cprintf("%d\n",i);
			if(PGNUM(page2pa(check)+PGSIZE*i) >= npages)
f01013f3:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01013f6:	2b 35 9c 5e 27 f0    	sub    0xf0275e9c,%esi
f01013fc:	c1 fe 03             	sar    $0x3,%esi
f01013ff:	c1 e6 0c             	shl    $0xc,%esi
f0101402:	8d 34 37             	lea    (%edi,%esi,1),%esi
f0101405:	89 f0                	mov    %esi,%eax
f0101407:	c1 e8 0c             	shr    $0xc,%eax
f010140a:	8b 15 94 5e 27 f0    	mov    0xf0275e94,%edx
f0101410:	39 d0                	cmp    %edx,%eax
f0101412:	0f 83 0f 01 00 00    	jae    f0101527 <page_alloc_4pages+0x18c>
				break;	
			//cprintf("return1\n");
			if(	page2pa(check)+PGSIZE*i >= IOPHYSMEM && 
f0101418:	81 fe ff ff 09 00    	cmp    $0x9ffff,%esi
f010141e:	76 38                	jbe    f0101458 <page_alloc_4pages+0xbd>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101420:	39 d0                	cmp    %edx,%eax
f0101422:	72 20                	jb     f0101444 <page_alloc_4pages+0xa9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101424:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0101428:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f010142f:	f0 
f0101430:	c7 44 24 04 9e 01 00 	movl   $0x19e,0x4(%esp)
f0101437:	00 
f0101438:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010143f:	e8 41 ec ff ff       	call   f0100085 <_panic>
				KADDR(page2pa(check)+PGSIZE*i) < boot_alloc(0)) 
f0101444:	b8 00 00 00 00       	mov    $0x0,%eax
f0101449:	e8 12 f9 ff ff       	call   f0100d60 <boot_alloc>
		{
			//cprintf("%d\n",i);
			if(PGNUM(page2pa(check)+PGSIZE*i) >= npages)
				break;	
			//cprintf("return1\n");
			if(	page2pa(check)+PGSIZE*i >= IOPHYSMEM && 
f010144e:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0101454:	39 f0                	cmp    %esi,%eax
f0101456:	77 55                	ja     f01014ad <page_alloc_4pages+0x112>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101458:	a1 9c 5e 27 f0       	mov    0xf0275e9c,%eax
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010145d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101460:	29 c2                	sub    %eax,%edx
f0101462:	c1 fa 03             	sar    $0x3,%edx
f0101465:	c1 e2 0c             	shl    $0xc,%edx
f0101468:	01 d7                	add    %edx,%edi
f010146a:	c1 ef 0c             	shr    $0xc,%edi
f010146d:	3b 3d 94 5e 27 f0    	cmp    0xf0275e94,%edi
f0101473:	72 1c                	jb     f0101491 <page_alloc_4pages+0xf6>
		panic("pa2page called with invalid pa");
f0101475:	c7 44 24 08 48 86 10 	movl   $0xf0108648,0x8(%esp)
f010147c:	f0 
f010147d:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0101484:	00 
f0101485:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f010148c:	e8 f4 eb ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101491:	8d 04 f8             	lea    (%eax,%edi,8),%eax
				KADDR(page2pa(check)+PGSIZE*i) < boot_alloc(0)) 
				break;
			//cprintf("return2\n");
			if(	((struct Page*)pa2page(page2pa(check)+PGSIZE*i))->pp_link == NULL )//there is a bug I know
f0101494:	83 38 00             	cmpl   $0x0,(%eax)
f0101497:	74 14                	je     f01014ad <page_alloc_4pages+0x112>
			else
			{
				//cprintf("return3\n");

				//cprintf("addrppp:%d\n",((struct Page*)pa2page(page2pa(check)+PGSIZE*i))->pp_ref);//0
				(((struct Page*)pa2page(page2pa(check)+PGSIZE*i))->pp_ref)=0xffff;
f0101499:	66 c7 40 04 ff ff    	movw   $0xffff,0x4(%eax)
	while(check != NULL)
	{
		//if(PGNUM(page2pa(check))<1030 && PGNUM(page2pa(check))>1000)
		//if(find == NULL)
			//cprintf("show:%d\n",PGNUM(page2pa(check))); 
		for(i=0;find == NULL && i<4 ;i++)//how to improve the efficience can i use a flag?
f010149f:	83 c3 01             	add    $0x1,%ebx
f01014a2:	83 fb 04             	cmp    $0x4,%ebx
f01014a5:	0f 85 43 ff ff ff    	jne    f01013ee <page_alloc_4pages+0x53>
f01014ab:	eb 05                	jmp    f01014b2 <page_alloc_4pages+0x117>
				//cprintf("the continous page:%d\n",PGNUM(page2pa(check)+PGSIZE*i));
			}

		}	
		//this means finding a continuous 4 space and for loop will not excute any more
		if(i == 4 && find == NULL)
f01014ad:	83 fb 04             	cmp    $0x4,%ebx
f01014b0:	75 75                	jne    f0101527 <page_alloc_4pages+0x18c>
		{
			//cprintf("find here:%d\n",PGNUM(page2pa(check)));
			find = check;
			check = &head;
			check->pp_link = page_free_list;
f01014b2:	8b 4d b8             	mov    -0x48(%ebp),%ecx
f01014b5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01014b8:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01014bb:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01014be:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01014c1:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f01014c4:	eb 61                	jmp    f0101527 <page_alloc_4pages+0x18c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01014c6:	89 f3                	mov    %esi,%ebx
f01014c8:	2b 1d 9c 5e 27 f0    	sub    0xf0275e9c,%ebx
f01014ce:	c1 fb 03             	sar    $0x3,%ebx
f01014d1:	c1 e3 0c             	shl    $0xc,%ebx
		}
		//cprintf("findfind:%d\n",PGNUM(page2pa(find)));
		while(check->pp_link->pp_ref == 0xffff)
		{
			//cprintf("findfind:%d\n",PGNUM(page2pa(check)));
			findlow = PGNUM(page2pa(find));
f01014d4:	89 df                	mov    %ebx,%edi
f01014d6:	c1 ef 0c             	shr    $0xc,%edi
			findup	= PGNUM(page2pa(find)+PGSIZE*3);
			checknum= PGNUM(page2pa(check->pp_link));
f01014d9:	89 c1                	mov    %eax,%ecx
f01014db:	2b 0d 9c 5e 27 f0    	sub    0xf0275e9c,%ecx
f01014e1:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f01014e4:	c1 f9 03             	sar    $0x3,%ecx
f01014e7:	81 e1 ff ff 0f 00    	and    $0xfffff,%ecx
			if(find != NULL && checknum >= findlow && checknum <= findup)
f01014ed:	85 f6                	test   %esi,%esi
f01014ef:	74 28                	je     f0101519 <page_alloc_4pages+0x17e>
f01014f1:	39 f9                	cmp    %edi,%ecx
f01014f3:	72 24                	jb     f0101519 <page_alloc_4pages+0x17e>
f01014f5:	81 c3 00 30 00 00    	add    $0x3000,%ebx
f01014fb:	c1 eb 0c             	shr    $0xc,%ebx
f01014fe:	39 cb                	cmp    %ecx,%ebx
f0101500:	72 17                	jb     f0101519 <page_alloc_4pages+0x17e>
			{
				//cprintf("ever here get%d\n",checknum - findlow);
				if(check == &head)
f0101502:	39 55 b4             	cmp    %edx,-0x4c(%ebp)
f0101505:	75 0c                	jne    f0101513 <page_alloc_4pages+0x178>
					last[checknum - findlow] = NULL;
f0101507:	29 f9                	sub    %edi,%ecx
f0101509:	c7 44 8d d0 00 00 00 	movl   $0x0,-0x30(%ebp,%ecx,4)
f0101510:	00 
f0101511:	eb 06                	jmp    f0101519 <page_alloc_4pages+0x17e>
				else
					last[checknum - findlow] = check;
f0101513:	29 f9                	sub    %edi,%ecx
f0101515:	89 54 8d d0          	mov    %edx,-0x30(%ebp,%ecx,4)
			}
			check->pp_link->pp_ref = 0;
f0101519:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			check = check->pp_link;
f010151f:	8b 12                	mov    (%edx),%edx
			//cprintf("nextaddr:%d\n",PGNUM(page2pa(check)));
			if(check == NULL)
f0101521:	85 d2                	test   %edx,%edx
f0101523:	75 08                	jne    f010152d <page_alloc_4pages+0x192>
f0101525:	eb 58                	jmp    f010157f <page_alloc_4pages+0x1e4>
f0101527:	8b 75 bc             	mov    -0x44(%ebp),%esi
f010152a:	8b 55 c0             	mov    -0x40(%ebp),%edx
			find = check;
			check = &head;
			check->pp_link = page_free_list;
		}
		//cprintf("findfind:%d\n",PGNUM(page2pa(find)));
		while(check->pp_link->pp_ref == 0xffff)
f010152d:	8b 02                	mov    (%edx),%eax
f010152f:	66 83 78 04 ff       	cmpw   $0xffffffff,0x4(%eax)
f0101534:	74 90                	je     f01014c6 <page_alloc_4pages+0x12b>
f0101536:	89 55 c0             	mov    %edx,-0x40(%ebp)
			if(check == NULL)
				break;
		}
		//if(check->pp_link == NULL)
			//cprintf("check buff done\n");
		if(check != NULL)
f0101539:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f010153d:	74 40                	je     f010157f <page_alloc_4pages+0x1e4>
	check = page_free_list;
	//cprintf("first page:%d\n",PGNUM(page2pa(check)));
	find = NULL;
	physaddr_t findlow,findup,checknum;
	int i = 0;
	while(check != NULL)
f010153f:	85 c0                	test   %eax,%eax
f0101541:	74 3c                	je     f010157f <page_alloc_4pages+0x1e4>
f0101543:	89 45 c0             	mov    %eax,-0x40(%ebp)
	{
		//if(PGNUM(page2pa(check))<1030 && PGNUM(page2pa(check))>1000)
		//if(find == NULL)
			//cprintf("show:%d\n",PGNUM(page2pa(check))); 
		for(i=0;find == NULL && i<4 ;i++)//how to improve the efficience can i use a flag?
f0101546:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f010154a:	75 db                	jne    f0101527 <page_alloc_4pages+0x18c>
f010154c:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010154f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101552:	89 c6                	mov    %eax,%esi
f0101554:	2b 35 9c 5e 27 f0    	sub    0xf0275e9c,%esi
f010155a:	c1 fe 03             	sar    $0x3,%esi
f010155d:	c1 e6 0c             	shl    $0xc,%esi
		{
			//cprintf("%d\n",i);
			if(PGNUM(page2pa(check)+PGSIZE*i) >= npages)
f0101560:	89 f0                	mov    %esi,%eax
f0101562:	c1 e8 0c             	shr    $0xc,%eax
f0101565:	8b 15 94 5e 27 f0    	mov    0xf0275e94,%edx
f010156b:	bf 00 00 00 00       	mov    $0x0,%edi
f0101570:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101575:	39 c2                	cmp    %eax,%edx
f0101577:	0f 87 9b fe ff ff    	ja     f0101418 <page_alloc_4pages+0x7d>
f010157d:	eb a8                	jmp    f0101527 <page_alloc_4pages+0x18c>
		//if(check->pp_link == NULL)
			//cprintf("check buff done\n");
		if(check != NULL)
			check = check->pp_link;
	}
	if(find == NULL)
f010157f:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
f0101583:	0f 84 13 01 00 00    	je     f010169c <page_alloc_4pages+0x301>
f0101589:	8b 4d bc             	mov    -0x44(%ebp),%ecx
f010158c:	8b 15 9c 5e 27 f0    	mov    0xf0275e9c,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101592:	89 c8                	mov    %ecx,%eax
f0101594:	29 d0                	sub    %edx,%eax
f0101596:	c1 f8 03             	sar    $0x3,%eax
f0101599:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010159e:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f01015a4:	72 3f                	jb     f01015e5 <page_alloc_4pages+0x24a>
f01015a6:	eb 21                	jmp    f01015c9 <page_alloc_4pages+0x22e>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01015a8:	8b 15 9c 5e 27 f0    	mov    0xf0275e9c,%edx
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015ae:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01015b1:	29 d0                	sub    %edx,%eax
f01015b3:	c1 f8 03             	sar    $0x3,%eax
f01015b6:	8d 04 30             	lea    (%eax,%esi,1),%eax
f01015b9:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015be:	83 c6 01             	add    $0x1,%esi
f01015c1:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f01015c7:	72 34                	jb     f01015fd <page_alloc_4pages+0x262>
		panic("pa2page called with invalid pa");
f01015c9:	c7 44 24 08 48 86 10 	movl   $0xf0108648,0x8(%esp)
f01015d0:	f0 
f01015d1:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f01015d8:	00 
f01015d9:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f01015e0:	e8 a0 ea ff ff       	call   f0100085 <_panic>
f01015e5:	be 01 00 00 00       	mov    $0x1,%esi
f01015ea:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
	{
		
		//cprintf("get first\n");
		first_free = (struct Page*)pa2page(page2pa(find)+PGSIZE*i);
		//cprintf("remove from list\n");
		if(last[i] ==  NULL)
f01015f1:	8d 7d d0             	lea    -0x30(%ebp),%edi
		{
			last[i]->pp_link = first_free->pp_link;
		}
		//cprintf("initial,%d\t%d\t%x\t%x\n",first_free->pp_ref,PGNUM(page2pa(find)+PGSIZE*i),page2pa(find)+PGSIZE*i,page2kva(first_free));
		first_free->pp_link = NULL;	
		if(alloc_flags & ALLOC_ZERO)
f01015f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015f7:	83 e1 01             	and    $0x1,%ecx
f01015fa:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
	return &pages[PGNUM(pa)];
f01015fd:	8d 1c c2             	lea    (%edx,%eax,8),%ebx
	{
		
		//cprintf("get first\n");
		first_free = (struct Page*)pa2page(page2pa(find)+PGSIZE*i);
		//cprintf("remove from list\n");
		if(last[i] ==  NULL)
f0101600:	8b 44 b7 fc          	mov    -0x4(%edi,%esi,4),%eax
f0101604:	85 c0                	test   %eax,%eax
f0101606:	75 09                	jne    f0101611 <page_alloc_4pages+0x276>
		{
			//cprintf("come here\n");
			page_free_list = first_free->pp_link;
f0101608:	8b 03                	mov    (%ebx),%eax
f010160a:	a3 30 52 27 f0       	mov    %eax,0xf0275230
f010160f:	eb 04                	jmp    f0101615 <page_alloc_4pages+0x27a>
		}
		else
		{
			last[i]->pp_link = first_free->pp_link;
f0101611:	8b 13                	mov    (%ebx),%edx
f0101613:	89 10                	mov    %edx,(%eax)
		}
		//cprintf("initial,%d\t%d\t%x\t%x\n",first_free->pp_ref,PGNUM(page2pa(find)+PGSIZE*i),page2pa(find)+PGSIZE*i,page2kva(first_free));
		first_free->pp_link = NULL;	
f0101615:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		if(alloc_flags & ALLOC_ZERO)
f010161b:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f010161f:	74 58                	je     f0101679 <page_alloc_4pages+0x2de>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101621:	89 d8                	mov    %ebx,%eax
f0101623:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f0101629:	c1 f8 03             	sar    $0x3,%eax
f010162c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010162f:	89 c2                	mov    %eax,%edx
f0101631:	c1 ea 0c             	shr    $0xc,%edx
f0101634:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f010163a:	72 20                	jb     f010165c <page_alloc_4pages+0x2c1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010163c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101640:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101647:	f0 
f0101648:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010164f:	00 
f0101650:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0101657:	e8 29 ea ff ff       	call   f0100085 <_panic>
		{
			//cprintf("do here?\n");
			memset((char*)page2kva(first_free), 0, PGSIZE);
f010165c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101663:	00 
f0101664:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010166b:	00 
f010166c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101671:	89 04 24             	mov    %eax,(%esp)
f0101674:	e8 ed 52 00 00       	call   f0106966 <memset>
		}
		//cprintf("add to result\n");
		if(i == 0)
f0101679:	83 fe 01             	cmp    $0x1,%esi
f010167c:	75 0b                	jne    f0101689 <page_alloc_4pages+0x2ee>
		{
			result = first_free;
			last[0] = result;
f010167e:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f0101681:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f0101684:	e9 1f ff ff ff       	jmp    f01015a8 <page_alloc_4pages+0x20d>
			continue;
		}
		last[0]->pp_link = first_free;
f0101689:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010168c:	89 18                	mov    %ebx,(%eax)
		last[0] = first_free;
f010168e:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	if(find == NULL)
		return NULL;
	//cprintf("find\n");
	result = NULL;
	first_free = NULL;
	for(i=0;i<4;i++)
f0101691:	83 fe 03             	cmp    $0x3,%esi
f0101694:	0f 8e 0e ff ff ff    	jle    f01015a8 <page_alloc_4pages+0x20d>
f010169a:	eb 07                	jmp    f01016a3 <page_alloc_4pages+0x308>
f010169c:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
		last[0] = first_free;
	}
	//result->pp_ref = 0x0fff; //different from other alloc page,it's really tricky
	//cprintf("out\n");
	return result;
}
f01016a3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01016a6:	83 c4 5c             	add    $0x5c,%esp
f01016a9:	5b                   	pop    %ebx
f01016aa:	5e                   	pop    %esi
f01016ab:	5f                   	pop    %edi
f01016ac:	5d                   	pop    %ebp
f01016ad:	c3                   	ret    

f01016ae <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct Page *
page_alloc(int alloc_flags)
{
f01016ae:	55                   	push   %ebp
f01016af:	89 e5                	mov    %esp,%ebp
f01016b1:	53                   	push   %ebx
f01016b2:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list != NULL)
f01016b5:	8b 1d 30 52 27 f0    	mov    0xf0275230,%ebx
f01016bb:	85 db                	test   %ebx,%ebx
f01016bd:	74 6b                	je     f010172a <page_alloc+0x7c>
	{
		struct Page* result;
		//get first
		result = page_free_list;
		//remove from list
		page_free_list = page_free_list->pp_link;
f01016bf:	8b 03                	mov    (%ebx),%eax
f01016c1:	a3 30 52 27 f0       	mov    %eax,0xf0275230
		if(alloc_flags & ALLOC_ZERO)
f01016c6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f01016ca:	74 58                	je     f0101724 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01016cc:	89 d8                	mov    %ebx,%eax
f01016ce:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f01016d4:	c1 f8 03             	sar    $0x3,%eax
f01016d7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016da:	89 c2                	mov    %eax,%edx
f01016dc:	c1 ea 0c             	shr    $0xc,%edx
f01016df:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f01016e5:	72 20                	jb     f0101707 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016eb:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01016f2:	f0 
f01016f3:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01016fa:	00 
f01016fb:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0101702:	e8 7e e9 ff ff       	call   f0100085 <_panic>
			memset((char*)page2kva(result), 0, PGSIZE);
f0101707:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010170e:	00 
f010170f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101716:	00 
f0101717:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010171c:	89 04 24             	mov    %eax,(%esp)
f010171f:	e8 42 52 00 00       	call   f0106966 <memset>
		//return
		result->pp_link = NULL;
f0101724:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		return result;
	}
	//cprintf("no free?\n");
	return NULL;
}
f010172a:	89 d8                	mov    %ebx,%eax
f010172c:	83 c4 14             	add    $0x14,%esp
f010172f:	5b                   	pop    %ebx
f0101730:	5d                   	pop    %ebp
f0101731:	c3                   	ret    

f0101732 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101732:	55                   	push   %ebp
f0101733:	89 e5                	mov    %esp,%ebp
f0101735:	83 ec 28             	sub    $0x28,%esp
f0101738:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010173b:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010173e:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101741:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pde_t*	pde;
	pte_t*	pte;	//it will change,use pointer to trace it
	struct Page* pp;
	pde = &pgdir[PDX(va)];
f0101744:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101747:	89 de                	mov    %ebx,%esi
f0101749:	c1 ee 16             	shr    $0x16,%esi
f010174c:	c1 e6 02             	shl    $0x2,%esi
f010174f:	03 75 08             	add    0x8(%ebp),%esi
	if(*pde & PTE_P)
f0101752:	8b 06                	mov    (%esi),%eax
f0101754:	a8 01                	test   $0x1,%al
f0101756:	74 47                	je     f010179f <pgdir_walk+0x6d>
	{
		pte = (pte_t *)KADDR(PTE_ADDR(*pde));
f0101758:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010175d:	89 c2                	mov    %eax,%edx
f010175f:	c1 ea 0c             	shr    $0xc,%edx
f0101762:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0101768:	72 20                	jb     f010178a <pgdir_walk+0x58>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010176a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010176e:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101775:	f0 
f0101776:	c7 44 24 04 59 02 00 	movl   $0x259,0x4(%esp)
f010177d:	00 
f010177e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101785:	e8 fb e8 ff ff       	call   f0100085 <_panic>
		return (pte+PTX(va)); 
f010178a:	c1 eb 0a             	shr    $0xa,%ebx
f010178d:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0101793:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f010179a:	e9 a4 00 00 00       	jmp    f0101843 <pgdir_walk+0x111>
	}
	if(!create)
f010179f:	85 ff                	test   %edi,%edi
f01017a1:	0f 84 97 00 00 00    	je     f010183e <pgdir_walk+0x10c>
	{
		return NULL;
	}
	if( (pp = page_alloc(ALLOC_ZERO)) != NULL)
f01017a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01017ae:	e8 fb fe ff ff       	call   f01016ae <page_alloc>
f01017b3:	85 c0                	test   %eax,%eax
f01017b5:	0f 84 83 00 00 00    	je     f010183e <pgdir_walk+0x10c>
	{
		//cprintf("alloc pgnum:%d",PGNUM(page2pa(pp)));
		pp->pp_ref++;
f01017bb:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01017c0:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f01017c6:	c1 f8 03             	sar    $0x3,%eax
f01017c9:	89 c2                	mov    %eax,%edx
f01017cb:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017ce:	89 d0                	mov    %edx,%eax
f01017d0:	c1 e8 0c             	shr    $0xc,%eax
f01017d3:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f01017d9:	72 20                	jb     f01017fb <pgdir_walk+0xc9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017db:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01017df:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01017e6:	f0 
f01017e7:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01017ee:	00 
f01017ef:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f01017f6:	e8 8a e8 ff ff       	call   f0100085 <_panic>
		pte = page2kva(pp);
f01017fb:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101801:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101806:	77 20                	ja     f0101828 <pgdir_walk+0xf6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101808:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010180c:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0101813:	f0 
f0101814:	c7 44 24 04 65 02 00 	movl   $0x265,0x4(%esp)
f010181b:	00 
f010181c:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101823:	e8 5d e8 ff ff       	call   f0100085 <_panic>
		*pde = PTE_ADDR(PADDR(pte))|create|PTE_W|PTE_U|PTE_P;//it's very strange!!!
f0101828:	83 cf 07             	or     $0x7,%edi
f010182b:	09 fa                	or     %edi,%edx
f010182d:	89 16                	mov    %edx,(%esi)
		return (pte+PTX(va));
f010182f:	c1 eb 0a             	shr    $0xa,%ebx
f0101832:	89 da                	mov    %ebx,%edx
f0101834:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
f010183a:	01 d0                	add    %edx,%eax
f010183c:	eb 05                	jmp    f0101843 <pgdir_walk+0x111>
f010183e:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//cprintf("no space?\n");
	return NULL;
}
f0101843:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101846:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101849:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010184c:	89 ec                	mov    %ebp,%esp
f010184e:	5d                   	pop    %ebp
f010184f:	c3                   	ret    

f0101850 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0101850:	55                   	push   %ebp
f0101851:	89 e5                	mov    %esp,%ebp
f0101853:	57                   	push   %edi
f0101854:	56                   	push   %esi
f0101855:	53                   	push   %ebx
f0101856:	83 ec 2c             	sub    $0x2c,%esp
f0101859:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	uintptr_t lva = (uintptr_t) va;
f010185c:	8b 45 0c             	mov    0xc(%ebp),%eax
	uintptr_t rva = (uintptr_t) va + len - 1;
f010185f:	89 c2                	mov    %eax,%edx
f0101861:	03 55 10             	add    0x10(%ebp),%edx
f0101864:	83 ea 01             	sub    $0x1,%edx
f0101867:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	
	perm = perm|PTE_U|PTE_P;
f010186a:	8b 7d 14             	mov    0x14(%ebp),%edi
f010186d:	83 cf 05             	or     $0x5,%edi
	
	pte_t *pte;
	uintptr_t idx_va;
	for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
f0101870:	39 d0                	cmp    %edx,%eax
f0101872:	77 61                	ja     f01018d5 <user_mem_check+0x85>
		if (idx_va >= ULIM) {
			user_mem_check_addr = idx_va;
			return -E_FAULT;
f0101874:	89 c3                	mov    %eax,%ebx
	perm = perm|PTE_U|PTE_P;
	
	pte_t *pte;
	uintptr_t idx_va;
	for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
		if (idx_va >= ULIM) {
f0101876:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010187b:	76 17                	jbe    f0101894 <user_mem_check+0x44>
f010187d:	eb 08                	jmp    f0101887 <user_mem_check+0x37>
f010187f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101885:	76 0d                	jbe    f0101894 <user_mem_check+0x44>
			user_mem_check_addr = idx_va;
f0101887:	89 1d 3c 52 27 f0    	mov    %ebx,0xf027523c
f010188d:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f0101892:	eb 46                	jmp    f01018da <user_mem_check+0x8a>
		}
		pte = pgdir_walk (env->env_pgdir, (void*)idx_va, 0);
f0101894:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010189b:	00 
f010189c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01018a0:	8b 46 60             	mov    0x60(%esi),%eax
f01018a3:	89 04 24             	mov    %eax,(%esp)
f01018a6:	e8 87 fe ff ff       	call   f0101732 <pgdir_walk>
		if (pte == NULL || (*pte & perm) != perm) {
f01018ab:	85 c0                	test   %eax,%eax
f01018ad:	74 08                	je     f01018b7 <user_mem_check+0x67>
f01018af:	8b 00                	mov    (%eax),%eax
f01018b1:	21 f8                	and    %edi,%eax
f01018b3:	39 c7                	cmp    %eax,%edi
f01018b5:	74 0d                	je     f01018c4 <user_mem_check+0x74>
			user_mem_check_addr = idx_va;		
f01018b7:	89 1d 3c 52 27 f0    	mov    %ebx,0xf027523c
f01018bd:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f01018c2:	eb 16                	jmp    f01018da <user_mem_check+0x8a>
		}
		idx_va = ROUNDDOWN (idx_va, PGSIZE);
f01018c4:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	perm = perm|PTE_U|PTE_P;
	
	pte_t *pte;
	uintptr_t idx_va;
	for (idx_va = lva; idx_va <= rva; idx_va += PGSIZE) {
f01018ca:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01018d0:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01018d3:	73 aa                	jae    f010187f <user_mem_check+0x2f>
f01018d5:	b8 00 00 00 00       	mov    $0x0,%eax
		}
		idx_va = ROUNDDOWN (idx_va, PGSIZE);
	}

	return 0;
}
f01018da:	83 c4 2c             	add    $0x2c,%esp
f01018dd:	5b                   	pop    %ebx
f01018de:	5e                   	pop    %esi
f01018df:	5f                   	pop    %edi
f01018e0:	5d                   	pop    %ebp
f01018e1:	c3                   	ret    

f01018e2 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01018e2:	55                   	push   %ebp
f01018e3:	89 e5                	mov    %esp,%ebp
f01018e5:	53                   	push   %ebx
f01018e6:	83 ec 14             	sub    $0x14,%esp
f01018e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01018ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01018ef:	83 c8 04             	or     $0x4,%eax
f01018f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018f6:	8b 45 10             	mov    0x10(%ebp),%eax
f01018f9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101900:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101904:	89 1c 24             	mov    %ebx,(%esp)
f0101907:	e8 44 ff ff ff       	call   f0101850 <user_mem_check>
f010190c:	85 c0                	test   %eax,%eax
f010190e:	79 24                	jns    f0101934 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101910:	a1 3c 52 27 f0       	mov    0xf027523c,%eax
f0101915:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101919:	8b 43 48             	mov    0x48(%ebx),%eax
f010191c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101920:	c7 04 24 68 86 10 f0 	movl   $0xf0108668,(%esp)
f0101927:	e8 1f 2b 00 00       	call   f010444b <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010192c:	89 1c 24             	mov    %ebx,(%esp)
f010192f:	e8 9d 25 00 00       	call   f0103ed1 <env_destroy>
	}
}
f0101934:	83 c4 14             	add    $0x14,%esp
f0101937:	5b                   	pop    %ebx
f0101938:	5d                   	pop    %ebp
f0101939:	c3                   	ret    

f010193a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct Page *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010193a:	55                   	push   %ebp
f010193b:	89 e5                	mov    %esp,%ebp
f010193d:	53                   	push   %ebx
f010193e:	83 ec 14             	sub    $0x14,%esp
f0101941:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	pte = pgdir_walk(pgdir,va,0);
f0101944:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010194b:	00 
f010194c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010194f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101953:	8b 45 08             	mov    0x8(%ebp),%eax
f0101956:	89 04 24             	mov    %eax,(%esp)
f0101959:	e8 d4 fd ff ff       	call   f0101732 <pgdir_walk>
	if(!pte)
f010195e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101963:	85 c0                	test   %eax,%eax
f0101965:	74 38                	je     f010199f <page_lookup+0x65>
		return NULL;
	if(pte_store)
f0101967:	85 db                	test   %ebx,%ebx
f0101969:	74 02                	je     f010196d <page_lookup+0x33>
		*pte_store = pte;
f010196b:	89 03                	mov    %eax,(%ebx)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010196d:	8b 10                	mov    (%eax),%edx
f010196f:	c1 ea 0c             	shr    $0xc,%edx
f0101972:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0101978:	72 1c                	jb     f0101996 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f010197a:	c7 44 24 08 48 86 10 	movl   $0xf0108648,0x8(%esp)
f0101981:	f0 
f0101982:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0101989:	00 
f010198a:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0101991:	e8 ef e6 ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0101996:	c1 e2 03             	shl    $0x3,%edx
f0101999:	03 15 9c 5e 27 f0    	add    0xf0275e9c,%edx
	return 	pa2page(PTE_ADDR(*pte));
}
f010199f:	89 d0                	mov    %edx,%eax
f01019a1:	83 c4 14             	add    $0x14,%esp
f01019a4:	5b                   	pop    %ebx
f01019a5:	5d                   	pop    %ebp
f01019a6:	c3                   	ret    

f01019a7 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01019a7:	55                   	push   %ebp
f01019a8:	89 e5                	mov    %esp,%ebp
f01019aa:	83 ec 28             	sub    $0x28,%esp
f01019ad:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01019b0:	89 75 fc             	mov    %esi,-0x4(%ebp)
f01019b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01019b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t* pte;
	struct Page* pp;
	pp = page_lookup(pgdir,va,&pte);
f01019b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01019bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019c4:	89 34 24             	mov    %esi,(%esp)
f01019c7:	e8 6e ff ff ff       	call   f010193a <page_lookup>
	//cprintf("what's up?\n");
	if(!pp)
f01019cc:	85 c0                	test   %eax,%eax
f01019ce:	74 1d                	je     f01019ed <page_remove+0x46>
		return;
	//cprintf("go on?\n");
	*pte = 0;
f01019d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01019d3:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page_decref(pp);
f01019d9:	89 04 24             	mov    %eax,(%esp)
f01019dc:	e8 21 f4 ff ff       	call   f0100e02 <page_decref>
	tlb_invalidate(pgdir,va);
f01019e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019e5:	89 34 24             	mov    %esi,(%esp)
f01019e8:	e8 38 f4 ff ff       	call   f0100e25 <tlb_invalidate>
	
}
f01019ed:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01019f0:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01019f3:	89 ec                	mov    %ebp,%esp
f01019f5:	5d                   	pop    %ebp
f01019f6:	c3                   	ret    

f01019f7 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct Page *pp, void *va, int perm)
{
f01019f7:	55                   	push   %ebp
f01019f8:	89 e5                	mov    %esp,%ebp
f01019fa:	83 ec 28             	sub    $0x28,%esp
f01019fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101a00:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101a03:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0101a06:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t* pte;
	pte = pgdir_walk(pgdir, va, 0);
f0101a09:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a10:	00 
f0101a11:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a18:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a1b:	89 04 24             	mov    %eax,(%esp)
f0101a1e:	e8 0f fd ff ff       	call   f0101732 <pgdir_walk>
f0101a23:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101a25:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	perm = perm | PTE_P;
f0101a2a:	8b 7d 14             	mov    0x14(%ebp),%edi
f0101a2d:	83 cf 01             	or     $0x1,%edi
	if(pte)
f0101a30:	85 c0                	test   %eax,%eax
f0101a32:	74 19                	je     f0101a4d <page_insert+0x56>
	{
		//PTE exists
		if(*pte & PTE_P)
f0101a34:	f6 00 01             	testb  $0x1,(%eax)
f0101a37:	74 3c                	je     f0101a75 <page_insert+0x7e>
		{
			//cprintf("exists\n");
			page_remove(pgdir,va);
f0101a39:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a40:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a43:	89 04 24             	mov    %eax,(%esp)
f0101a46:	e8 5c ff ff ff       	call   f01019a7 <page_remove>
f0101a4b:	eb 28                	jmp    f0101a75 <page_insert+0x7e>
		}
	}
	else
	{
		//cprintf("2nhello\n");
		pte = pgdir_walk(pgdir, va, perm); //perm create
f0101a4d:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101a51:	8b 45 10             	mov    0x10(%ebp),%eax
f0101a54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101a58:	8b 45 08             	mov    0x8(%ebp),%eax
f0101a5b:	89 04 24             	mov    %eax,(%esp)
f0101a5e:	e8 cf fc ff ff       	call   f0101732 <pgdir_walk>
f0101a63:	89 c3                	mov    %eax,%ebx
		//cprintf("2nhelloend\n");
		if(!pte)
f0101a65:	85 c0                	test   %eax,%eax
f0101a67:	75 0c                	jne    f0101a75 <page_insert+0x7e>
		{
			pp->pp_ref--;
f0101a69:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
f0101a6e:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
			return -E_NO_MEM;
f0101a73:	eb 15                	jmp    f0101a8a <page_insert+0x93>
			
		}
	}
	*pte = PTE_ADDR(page2pa(pp))|perm;
f0101a75:	2b 35 9c 5e 27 f0    	sub    0xf0275e9c,%esi
f0101a7b:	c1 fe 03             	sar    $0x3,%esi
f0101a7e:	c1 e6 0c             	shl    $0xc,%esi
f0101a81:	09 f7                	or     %esi,%edi
f0101a83:	89 3b                	mov    %edi,(%ebx)
f0101a85:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0101a8a:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0101a8d:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0101a90:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0101a93:	89 ec                	mov    %ebp,%esp
f0101a95:	5d                   	pop    %ebp
f0101a96:	c3                   	ret    

f0101a97 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101a97:	55                   	push   %ebp
f0101a98:	89 e5                	mov    %esp,%ebp
f0101a9a:	57                   	push   %edi
f0101a9b:	56                   	push   %esi
f0101a9c:	53                   	push   %ebx
f0101a9d:	83 ec 1c             	sub    $0x1c,%esp
f0101aa0:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Fill this function in
	pte_t* pte;
	size_t base = 0;
	//cprintf("right here:%x\t%x\t%x\n",va,size,pa);
	for(base=0;base < size;base=base+PGSIZE)
f0101aa3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101aa7:	74 40                	je     f0101ae9 <boot_map_region+0x52>
f0101aa9:	bb 00 00 00 00       	mov    $0x0,%ebx
	{
		pte = pgdir_walk (pgdir, (void*)(va+base), 1);
		//if(pte != NULL)
			*pte = PTE_ADDR(pa + base)|perm|PTE_P;
f0101aae:	8b 75 18             	mov    0x18(%ebp),%esi
f0101ab1:	83 ce 01             	or     $0x1,%esi
	pte_t* pte;
	size_t base = 0;
	//cprintf("right here:%x\t%x\t%x\n",va,size,pa);
	for(base=0;base < size;base=base+PGSIZE)
	{
		pte = pgdir_walk (pgdir, (void*)(va+base), 1);
f0101ab4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101abb:	00 
f0101abc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101abf:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0101ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
f0101ac9:	89 04 24             	mov    %eax,(%esp)
f0101acc:	e8 61 fc ff ff       	call   f0101732 <pgdir_walk>
		//if(pte != NULL)
			*pte = PTE_ADDR(pa + base)|perm|PTE_P;
f0101ad1:	8d 14 3b             	lea    (%ebx,%edi,1),%edx
f0101ad4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ada:	09 f2                	or     %esi,%edx
f0101adc:	89 10                	mov    %edx,(%eax)
{
	// Fill this function in
	pte_t* pte;
	size_t base = 0;
	//cprintf("right here:%x\t%x\t%x\n",va,size,pa);
	for(base=0;base < size;base=base+PGSIZE)
f0101ade:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101ae4:	39 5d 10             	cmp    %ebx,0x10(%ebp)
f0101ae7:	77 cb                	ja     f0101ab4 <boot_map_region+0x1d>
		
	}
	//cprintf("if out\n");
	
	
}
f0101ae9:	83 c4 1c             	add    $0x1c,%esp
f0101aec:	5b                   	pop    %ebx
f0101aed:	5e                   	pop    %esi
f0101aee:	5f                   	pop    %edi
f0101aef:	5d                   	pop    %ebp
f0101af0:	c3                   	ret    

f0101af1 <check_page>:


// check page_insert, page_remove, &c
static void
check_page(void)
{
f0101af1:	55                   	push   %ebp
f0101af2:	89 e5                	mov    %esp,%ebp
f0101af4:	57                   	push   %edi
f0101af5:	56                   	push   %esi
f0101af6:	53                   	push   %ebx
f0101af7:	83 ec 3c             	sub    $0x3c,%esp
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101afa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b01:	e8 a8 fb ff ff       	call   f01016ae <page_alloc>
f0101b06:	89 c6                	mov    %eax,%esi
f0101b08:	85 c0                	test   %eax,%eax
f0101b0a:	75 24                	jne    f0101b30 <check_page+0x3f>
f0101b0c:	c7 44 24 0c 74 8d 10 	movl   $0xf0108d74,0xc(%esp)
f0101b13:	f0 
f0101b14:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101b1b:	f0 
f0101b1c:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0101b23:	00 
f0101b24:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101b2b:	e8 55 e5 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101b30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b37:	e8 72 fb ff ff       	call   f01016ae <page_alloc>
f0101b3c:	89 c7                	mov    %eax,%edi
f0101b3e:	85 c0                	test   %eax,%eax
f0101b40:	75 24                	jne    f0101b66 <check_page+0x75>
f0101b42:	c7 44 24 0c 8a 8d 10 	movl   $0xf0108d8a,0xc(%esp)
f0101b49:	f0 
f0101b4a:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101b51:	f0 
f0101b52:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0101b59:	00 
f0101b5a:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101b61:	e8 1f e5 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b66:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b6d:	e8 3c fb ff ff       	call   f01016ae <page_alloc>
f0101b72:	89 c3                	mov    %eax,%ebx
f0101b74:	85 c0                	test   %eax,%eax
f0101b76:	75 24                	jne    f0101b9c <check_page+0xab>
f0101b78:	c7 44 24 0c a0 8d 10 	movl   $0xf0108da0,0xc(%esp)
f0101b7f:	f0 
f0101b80:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101b87:	f0 
f0101b88:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f0101b8f:	00 
f0101b90:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101b97:	e8 e9 e4 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b9c:	39 fe                	cmp    %edi,%esi
f0101b9e:	75 24                	jne    f0101bc4 <check_page+0xd3>
f0101ba0:	c7 44 24 0c b6 8d 10 	movl   $0xf0108db6,0xc(%esp)
f0101ba7:	f0 
f0101ba8:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101baf:	f0 
f0101bb0:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f0101bb7:	00 
f0101bb8:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101bbf:	e8 c1 e4 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101bc4:	39 c7                	cmp    %eax,%edi
f0101bc6:	74 04                	je     f0101bcc <check_page+0xdb>
f0101bc8:	39 c6                	cmp    %eax,%esi
f0101bca:	75 24                	jne    f0101bf0 <check_page+0xff>
f0101bcc:	c7 44 24 0c a0 86 10 	movl   $0xf01086a0,0xc(%esp)
f0101bd3:	f0 
f0101bd4:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101bdb:	f0 
f0101bdc:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f0101be3:	00 
f0101be4:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101beb:	e8 95 e4 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101bf0:	a1 30 52 27 f0       	mov    0xf0275230,%eax
f0101bf5:	89 45 c8             	mov    %eax,-0x38(%ebp)
	page_free_list = 0;
f0101bf8:	c7 05 30 52 27 f0 00 	movl   $0x0,0xf0275230
f0101bff:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c09:	e8 a0 fa ff ff       	call   f01016ae <page_alloc>
f0101c0e:	85 c0                	test   %eax,%eax
f0101c10:	74 24                	je     f0101c36 <check_page+0x145>
f0101c12:	c7 44 24 0c c8 8d 10 	movl   $0xf0108dc8,0xc(%esp)
f0101c19:	f0 
f0101c1a:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101c21:	f0 
f0101c22:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0101c29:	00 
f0101c2a:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101c31:	e8 4f e4 ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101c36:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101c39:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101c44:	00 
f0101c45:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101c4a:	89 04 24             	mov    %eax,(%esp)
f0101c4d:	e8 e8 fc ff ff       	call   f010193a <page_lookup>
f0101c52:	85 c0                	test   %eax,%eax
f0101c54:	74 24                	je     f0101c7a <check_page+0x189>
f0101c56:	c7 44 24 0c c0 86 10 	movl   $0xf01086c0,0xc(%esp)
f0101c5d:	f0 
f0101c5e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101c65:	f0 
f0101c66:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0101c6d:	00 
f0101c6e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101c75:	e8 0b e4 ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101c7a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c81:	00 
f0101c82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c89:	00 
f0101c8a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101c8e:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101c93:	89 04 24             	mov    %eax,(%esp)
f0101c96:	e8 5c fd ff ff       	call   f01019f7 <page_insert>
f0101c9b:	85 c0                	test   %eax,%eax
f0101c9d:	78 24                	js     f0101cc3 <check_page+0x1d2>
f0101c9f:	c7 44 24 0c f8 86 10 	movl   $0xf01086f8,0xc(%esp)
f0101ca6:	f0 
f0101ca7:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101cae:	f0 
f0101caf:	c7 44 24 04 55 04 00 	movl   $0x455,0x4(%esp)
f0101cb6:	00 
f0101cb7:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101cbe:	e8 c2 e3 ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101cc3:	89 34 24             	mov    %esi,(%esp)
f0101cc6:	e8 cc f0 ff ff       	call   f0100d97 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101ccb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101cd2:	00 
f0101cd3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cda:	00 
f0101cdb:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101cdf:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101ce4:	89 04 24             	mov    %eax,(%esp)
f0101ce7:	e8 0b fd ff ff       	call   f01019f7 <page_insert>
f0101cec:	85 c0                	test   %eax,%eax
f0101cee:	74 24                	je     f0101d14 <check_page+0x223>
f0101cf0:	c7 44 24 0c 28 87 10 	movl   $0xf0108728,0xc(%esp)
f0101cf7:	f0 
f0101cf8:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101cff:	f0 
f0101d00:	c7 44 24 04 59 04 00 	movl   $0x459,0x4(%esp)
f0101d07:	00 
f0101d08:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101d0f:	e8 71 e3 ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d14:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d19:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101d1c:	8b 08                	mov    (%eax),%ecx
f0101d1e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101d24:	89 f2                	mov    %esi,%edx
f0101d26:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0101d2c:	c1 fa 03             	sar    $0x3,%edx
f0101d2f:	c1 e2 0c             	shl    $0xc,%edx
f0101d32:	39 d1                	cmp    %edx,%ecx
f0101d34:	74 24                	je     f0101d5a <check_page+0x269>
f0101d36:	c7 44 24 0c 58 87 10 	movl   $0xf0108758,0xc(%esp)
f0101d3d:	f0 
f0101d3e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101d45:	f0 
f0101d46:	c7 44 24 04 5a 04 00 	movl   $0x45a,0x4(%esp)
f0101d4d:	00 
f0101d4e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101d55:	e8 2b e3 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d5a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d5f:	e8 f6 f0 ff ff       	call   f0100e5a <check_va2pa>
f0101d64:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101d67:	89 fa                	mov    %edi,%edx
f0101d69:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0101d6f:	c1 fa 03             	sar    $0x3,%edx
f0101d72:	c1 e2 0c             	shl    $0xc,%edx
f0101d75:	39 d0                	cmp    %edx,%eax
f0101d77:	74 24                	je     f0101d9d <check_page+0x2ac>
f0101d79:	c7 44 24 0c 80 87 10 	movl   $0xf0108780,0xc(%esp)
f0101d80:	f0 
f0101d81:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101d88:	f0 
f0101d89:	c7 44 24 04 5b 04 00 	movl   $0x45b,0x4(%esp)
f0101d90:	00 
f0101d91:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101d98:	e8 e8 e2 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0101d9d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101da2:	74 24                	je     f0101dc8 <check_page+0x2d7>
f0101da4:	c7 44 24 0c d7 8d 10 	movl   $0xf0108dd7,0xc(%esp)
f0101dab:	f0 
f0101dac:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101db3:	f0 
f0101db4:	c7 44 24 04 5c 04 00 	movl   $0x45c,0x4(%esp)
f0101dbb:	00 
f0101dbc:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101dc3:	e8 bd e2 ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f0101dc8:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101dcd:	74 24                	je     f0101df3 <check_page+0x302>
f0101dcf:	c7 44 24 0c e8 8d 10 	movl   $0xf0108de8,0xc(%esp)
f0101dd6:	f0 
f0101dd7:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101dde:	f0 
f0101ddf:	c7 44 24 04 5d 04 00 	movl   $0x45d,0x4(%esp)
f0101de6:	00 
f0101de7:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101dee:	e8 92 e2 ff ff       	call   f0100085 <_panic>
	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101df3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dfa:	00 
f0101dfb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e02:	00 
f0101e03:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e07:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101e0c:	89 04 24             	mov    %eax,(%esp)
f0101e0f:	e8 e3 fb ff ff       	call   f01019f7 <page_insert>
f0101e14:	85 c0                	test   %eax,%eax
f0101e16:	74 24                	je     f0101e3c <check_page+0x34b>
f0101e18:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 04 5f 04 00 	movl   $0x45f,0x4(%esp)
f0101e2f:	00 
f0101e30:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101e37:	e8 49 e2 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e3c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e41:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101e46:	e8 0f f0 ff ff       	call   f0100e5a <check_va2pa>
f0101e4b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0101e4e:	89 da                	mov    %ebx,%edx
f0101e50:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0101e56:	c1 fa 03             	sar    $0x3,%edx
f0101e59:	c1 e2 0c             	shl    $0xc,%edx
f0101e5c:	39 d0                	cmp    %edx,%eax
f0101e5e:	74 24                	je     f0101e84 <check_page+0x393>
f0101e60:	c7 44 24 0c ec 87 10 	movl   $0xf01087ec,0xc(%esp)
f0101e67:	f0 
f0101e68:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101e6f:	f0 
f0101e70:	c7 44 24 04 60 04 00 	movl   $0x460,0x4(%esp)
f0101e77:	00 
f0101e78:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101e7f:	e8 01 e2 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101e84:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e89:	74 24                	je     f0101eaf <check_page+0x3be>
f0101e8b:	c7 44 24 0c f9 8d 10 	movl   $0xf0108df9,0xc(%esp)
f0101e92:	f0 
f0101e93:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101e9a:	f0 
f0101e9b:	c7 44 24 04 61 04 00 	movl   $0x461,0x4(%esp)
f0101ea2:	00 
f0101ea3:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101eaa:	e8 d6 e1 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101eaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101eb6:	e8 f3 f7 ff ff       	call   f01016ae <page_alloc>
f0101ebb:	85 c0                	test   %eax,%eax
f0101ebd:	74 24                	je     f0101ee3 <check_page+0x3f2>
f0101ebf:	c7 44 24 0c c8 8d 10 	movl   $0xf0108dc8,0xc(%esp)
f0101ec6:	f0 
f0101ec7:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101ece:	f0 
f0101ecf:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0101ed6:	00 
f0101ed7:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101ede:	e8 a2 e1 ff ff       	call   f0100085 <_panic>
	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ee3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101eea:	00 
f0101eeb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ef2:	00 
f0101ef3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ef7:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101efc:	89 04 24             	mov    %eax,(%esp)
f0101eff:	e8 f3 fa ff ff       	call   f01019f7 <page_insert>
f0101f04:	85 c0                	test   %eax,%eax
f0101f06:	74 24                	je     f0101f2c <check_page+0x43b>
f0101f08:	c7 44 24 0c b0 87 10 	movl   $0xf01087b0,0xc(%esp)
f0101f0f:	f0 
f0101f10:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101f17:	f0 
f0101f18:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0101f1f:	00 
f0101f20:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101f27:	e8 59 e1 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f2c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f31:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101f36:	e8 1f ef ff ff       	call   f0100e5a <check_va2pa>
f0101f3b:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0101f3e:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0101f44:	c1 fa 03             	sar    $0x3,%edx
f0101f47:	c1 e2 0c             	shl    $0xc,%edx
f0101f4a:	39 d0                	cmp    %edx,%eax
f0101f4c:	74 24                	je     f0101f72 <check_page+0x481>
f0101f4e:	c7 44 24 0c ec 87 10 	movl   $0xf01087ec,0xc(%esp)
f0101f55:	f0 
f0101f56:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101f5d:	f0 
f0101f5e:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0101f65:	00 
f0101f66:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101f6d:	e8 13 e1 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101f72:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f77:	74 24                	je     f0101f9d <check_page+0x4ac>
f0101f79:	c7 44 24 0c f9 8d 10 	movl   $0xf0108df9,0xc(%esp)
f0101f80:	f0 
f0101f81:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101f88:	f0 
f0101f89:	c7 44 24 04 68 04 00 	movl   $0x468,0x4(%esp)
f0101f90:	00 
f0101f91:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101f98:	e8 e8 e0 ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fa4:	e8 05 f7 ff ff       	call   f01016ae <page_alloc>
f0101fa9:	85 c0                	test   %eax,%eax
f0101fab:	74 24                	je     f0101fd1 <check_page+0x4e0>
f0101fad:	c7 44 24 0c c8 8d 10 	movl   $0xf0108dc8,0xc(%esp)
f0101fb4:	f0 
f0101fb5:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0101fbc:	f0 
f0101fbd:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f0101fc4:	00 
f0101fc5:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0101fcc:	e8 b4 e0 ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101fd1:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0101fd6:	8b 00                	mov    (%eax),%eax
f0101fd8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fdd:	89 c2                	mov    %eax,%edx
f0101fdf:	c1 ea 0c             	shr    $0xc,%edx
f0101fe2:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0101fe8:	72 20                	jb     f010200a <check_page+0x519>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101fee:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0101ff5:	f0 
f0101ff6:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f0101ffd:	00 
f0101ffe:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102005:	e8 7b e0 ff ff       	call   f0100085 <_panic>
f010200a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010200f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102012:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102019:	00 
f010201a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102021:	00 
f0102022:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102027:	89 04 24             	mov    %eax,(%esp)
f010202a:	e8 03 f7 ff ff       	call   f0101732 <pgdir_walk>
f010202f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102032:	83 c2 04             	add    $0x4,%edx
f0102035:	39 d0                	cmp    %edx,%eax
f0102037:	74 24                	je     f010205d <check_page+0x56c>
f0102039:	c7 44 24 0c 1c 88 10 	movl   $0xf010881c,0xc(%esp)
f0102040:	f0 
f0102041:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102048:	f0 
f0102049:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0102050:	00 
f0102051:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102058:	e8 28 e0 ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010205d:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102064:	00 
f0102065:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010206c:	00 
f010206d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102071:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102076:	89 04 24             	mov    %eax,(%esp)
f0102079:	e8 79 f9 ff ff       	call   f01019f7 <page_insert>
f010207e:	85 c0                	test   %eax,%eax
f0102080:	74 24                	je     f01020a6 <check_page+0x5b5>
f0102082:	c7 44 24 0c 5c 88 10 	movl   $0xf010885c,0xc(%esp)
f0102089:	f0 
f010208a:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102091:	f0 
f0102092:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f0102099:	00 
f010209a:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01020a1:	e8 df df ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01020a6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ab:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01020b0:	e8 a5 ed ff ff       	call   f0100e5a <check_va2pa>
f01020b5:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01020b8:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f01020be:	c1 fa 03             	sar    $0x3,%edx
f01020c1:	c1 e2 0c             	shl    $0xc,%edx
f01020c4:	39 d0                	cmp    %edx,%eax
f01020c6:	74 24                	je     f01020ec <check_page+0x5fb>
f01020c8:	c7 44 24 0c ec 87 10 	movl   $0xf01087ec,0xc(%esp)
f01020cf:	f0 
f01020d0:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01020d7:	f0 
f01020d8:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f01020df:	00 
f01020e0:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01020e7:	e8 99 df ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01020ec:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01020f1:	74 24                	je     f0102117 <check_page+0x626>
f01020f3:	c7 44 24 0c f9 8d 10 	movl   $0xf0108df9,0xc(%esp)
f01020fa:	f0 
f01020fb:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102102:	f0 
f0102103:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f010210a:	00 
f010210b:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102112:	e8 6e df ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102117:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010211e:	00 
f010211f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102126:	00 
f0102127:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f010212c:	89 04 24             	mov    %eax,(%esp)
f010212f:	e8 fe f5 ff ff       	call   f0101732 <pgdir_walk>
f0102134:	f6 00 04             	testb  $0x4,(%eax)
f0102137:	75 24                	jne    f010215d <check_page+0x66c>
f0102139:	c7 44 24 0c 9c 88 10 	movl   $0xf010889c,0xc(%esp)
f0102140:	f0 
f0102141:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102148:	f0 
f0102149:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f0102150:	00 
f0102151:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102158:	e8 28 df ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010215d:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102162:	f6 00 04             	testb  $0x4,(%eax)
f0102165:	75 24                	jne    f010218b <check_page+0x69a>
f0102167:	c7 44 24 0c 0a 8e 10 	movl   $0xf0108e0a,0xc(%esp)
f010216e:	f0 
f010216f:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102176:	f0 
f0102177:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f010217e:	00 
f010217f:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102186:	e8 fa de ff ff       	call   f0100085 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f010218b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102192:	00 
f0102193:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f010219a:	00 
f010219b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010219f:	89 04 24             	mov    %eax,(%esp)
f01021a2:	e8 50 f8 ff ff       	call   f01019f7 <page_insert>
f01021a7:	85 c0                	test   %eax,%eax
f01021a9:	78 24                	js     f01021cf <check_page+0x6de>
f01021ab:	c7 44 24 0c d0 88 10 	movl   $0xf01088d0,0xc(%esp)
f01021b2:	f0 
f01021b3:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01021ba:	f0 
f01021bb:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f01021c2:	00 
f01021c3:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01021ca:	e8 b6 de ff ff       	call   f0100085 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01021cf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01021d6:	00 
f01021d7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021de:	00 
f01021df:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01021e3:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01021e8:	89 04 24             	mov    %eax,(%esp)
f01021eb:	e8 07 f8 ff ff       	call   f01019f7 <page_insert>
f01021f0:	85 c0                	test   %eax,%eax
f01021f2:	74 24                	je     f0102218 <check_page+0x727>
f01021f4:	c7 44 24 0c 08 89 10 	movl   $0xf0108908,0xc(%esp)
f01021fb:	f0 
f01021fc:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102203:	f0 
f0102204:	c7 44 24 04 7d 04 00 	movl   $0x47d,0x4(%esp)
f010220b:	00 
f010220c:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102213:	e8 6d de ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102218:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010221f:	00 
f0102220:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102227:	00 
f0102228:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f010222d:	89 04 24             	mov    %eax,(%esp)
f0102230:	e8 fd f4 ff ff       	call   f0101732 <pgdir_walk>
f0102235:	f6 00 04             	testb  $0x4,(%eax)
f0102238:	74 24                	je     f010225e <check_page+0x76d>
f010223a:	c7 44 24 0c 44 89 10 	movl   $0xf0108944,0xc(%esp)
f0102241:	f0 
f0102242:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102249:	f0 
f010224a:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f0102251:	00 
f0102252:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102259:	e8 27 de ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010225e:	ba 00 00 00 00       	mov    $0x0,%edx
f0102263:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102268:	e8 ed eb ff ff       	call   f0100e5a <check_va2pa>
f010226d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102270:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0102276:	c1 fa 03             	sar    $0x3,%edx
f0102279:	c1 e2 0c             	shl    $0xc,%edx
f010227c:	39 d0                	cmp    %edx,%eax
f010227e:	74 24                	je     f01022a4 <check_page+0x7b3>
f0102280:	c7 44 24 0c 7c 89 10 	movl   $0xf010897c,0xc(%esp)
f0102287:	f0 
f0102288:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010228f:	f0 
f0102290:	c7 44 24 04 81 04 00 	movl   $0x481,0x4(%esp)
f0102297:	00 
f0102298:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010229f:	e8 e1 dd ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022a4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022a9:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01022ae:	e8 a7 eb ff ff       	call   f0100e5a <check_va2pa>
f01022b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01022b6:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f01022bc:	c1 fa 03             	sar    $0x3,%edx
f01022bf:	c1 e2 0c             	shl    $0xc,%edx
f01022c2:	39 d0                	cmp    %edx,%eax
f01022c4:	74 24                	je     f01022ea <check_page+0x7f9>
f01022c6:	c7 44 24 0c a8 89 10 	movl   $0xf01089a8,0xc(%esp)
f01022cd:	f0 
f01022ce:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01022d5:	f0 
f01022d6:	c7 44 24 04 82 04 00 	movl   $0x482,0x4(%esp)
f01022dd:	00 
f01022de:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01022e5:	e8 9b dd ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01022ea:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f01022ef:	74 24                	je     f0102315 <check_page+0x824>
f01022f1:	c7 44 24 0c 20 8e 10 	movl   $0xf0108e20,0xc(%esp)
f01022f8:	f0 
f01022f9:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102300:	f0 
f0102301:	c7 44 24 04 84 04 00 	movl   $0x484,0x4(%esp)
f0102308:	00 
f0102309:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102310:	e8 70 dd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102315:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010231a:	74 24                	je     f0102340 <check_page+0x84f>
f010231c:	c7 44 24 0c 31 8e 10 	movl   $0xf0108e31,0xc(%esp)
f0102323:	f0 
f0102324:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010232b:	f0 
f010232c:	c7 44 24 04 85 04 00 	movl   $0x485,0x4(%esp)
f0102333:	00 
f0102334:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010233b:	e8 45 dd ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102340:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102347:	e8 62 f3 ff ff       	call   f01016ae <page_alloc>
f010234c:	85 c0                	test   %eax,%eax
f010234e:	74 04                	je     f0102354 <check_page+0x863>
f0102350:	39 c3                	cmp    %eax,%ebx
f0102352:	74 24                	je     f0102378 <check_page+0x887>
f0102354:	c7 44 24 0c d8 89 10 	movl   $0xf01089d8,0xc(%esp)
f010235b:	f0 
f010235c:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102363:	f0 
f0102364:	c7 44 24 04 88 04 00 	movl   $0x488,0x4(%esp)
f010236b:	00 
f010236c:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102373:	e8 0d dd ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102378:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010237f:	00 
f0102380:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102385:	89 04 24             	mov    %eax,(%esp)
f0102388:	e8 1a f6 ff ff       	call   f01019a7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010238d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102392:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102397:	e8 be ea ff ff       	call   f0100e5a <check_va2pa>
f010239c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010239f:	74 24                	je     f01023c5 <check_page+0x8d4>
f01023a1:	c7 44 24 0c fc 89 10 	movl   $0xf01089fc,0xc(%esp)
f01023a8:	f0 
f01023a9:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01023b0:	f0 
f01023b1:	c7 44 24 04 8c 04 00 	movl   $0x48c,0x4(%esp)
f01023b8:	00 
f01023b9:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01023c0:	e8 c0 dc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01023c5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023ca:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01023cf:	e8 86 ea ff ff       	call   f0100e5a <check_va2pa>
f01023d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023d7:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f01023dd:	c1 fa 03             	sar    $0x3,%edx
f01023e0:	c1 e2 0c             	shl    $0xc,%edx
f01023e3:	39 d0                	cmp    %edx,%eax
f01023e5:	74 24                	je     f010240b <check_page+0x91a>
f01023e7:	c7 44 24 0c a8 89 10 	movl   $0xf01089a8,0xc(%esp)
f01023ee:	f0 
f01023ef:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01023f6:	f0 
f01023f7:	c7 44 24 04 8d 04 00 	movl   $0x48d,0x4(%esp)
f01023fe:	00 
f01023ff:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102406:	e8 7a dc ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f010240b:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102410:	74 24                	je     f0102436 <check_page+0x945>
f0102412:	c7 44 24 0c d7 8d 10 	movl   $0xf0108dd7,0xc(%esp)
f0102419:	f0 
f010241a:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102421:	f0 
f0102422:	c7 44 24 04 8e 04 00 	movl   $0x48e,0x4(%esp)
f0102429:	00 
f010242a:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102431:	e8 4f dc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102436:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010243b:	74 24                	je     f0102461 <check_page+0x970>
f010243d:	c7 44 24 0c 31 8e 10 	movl   $0xf0108e31,0xc(%esp)
f0102444:	f0 
f0102445:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010244c:	f0 
f010244d:	c7 44 24 04 8f 04 00 	movl   $0x48f,0x4(%esp)
f0102454:	00 
f0102455:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010245c:	e8 24 dc ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102461:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102468:	00 
f0102469:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f010246e:	89 04 24             	mov    %eax,(%esp)
f0102471:	e8 31 f5 ff ff       	call   f01019a7 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102476:	ba 00 00 00 00       	mov    $0x0,%edx
f010247b:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102480:	e8 d5 e9 ff ff       	call   f0100e5a <check_va2pa>
f0102485:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102488:	74 24                	je     f01024ae <check_page+0x9bd>
f010248a:	c7 44 24 0c fc 89 10 	movl   $0xf01089fc,0xc(%esp)
f0102491:	f0 
f0102492:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102499:	f0 
f010249a:	c7 44 24 04 93 04 00 	movl   $0x493,0x4(%esp)
f01024a1:	00 
f01024a2:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01024a9:	e8 d7 db ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024ae:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024b3:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01024b8:	e8 9d e9 ff ff       	call   f0100e5a <check_va2pa>
f01024bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c0:	74 24                	je     f01024e6 <check_page+0x9f5>
f01024c2:	c7 44 24 0c 20 8a 10 	movl   $0xf0108a20,0xc(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01024d1:	f0 
f01024d2:	c7 44 24 04 94 04 00 	movl   $0x494,0x4(%esp)
f01024d9:	00 
f01024da:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01024e1:	e8 9f db ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01024e6:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01024eb:	74 24                	je     f0102511 <check_page+0xa20>
f01024ed:	c7 44 24 0c 42 8e 10 	movl   $0xf0108e42,0xc(%esp)
f01024f4:	f0 
f01024f5:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01024fc:	f0 
f01024fd:	c7 44 24 04 95 04 00 	movl   $0x495,0x4(%esp)
f0102504:	00 
f0102505:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010250c:	e8 74 db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102511:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102516:	74 24                	je     f010253c <check_page+0xa4b>
f0102518:	c7 44 24 0c 31 8e 10 	movl   $0xf0108e31,0xc(%esp)
f010251f:	f0 
f0102520:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102527:	f0 
f0102528:	c7 44 24 04 96 04 00 	movl   $0x496,0x4(%esp)
f010252f:	00 
f0102530:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102537:	e8 49 db ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010253c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102543:	e8 66 f1 ff ff       	call   f01016ae <page_alloc>
f0102548:	85 c0                	test   %eax,%eax
f010254a:	74 06                	je     f0102552 <check_page+0xa61>
f010254c:	39 c7                	cmp    %eax,%edi
f010254e:	66 90                	xchg   %ax,%ax
f0102550:	74 24                	je     f0102576 <check_page+0xa85>
f0102552:	c7 44 24 0c 48 8a 10 	movl   $0xf0108a48,0xc(%esp)
f0102559:	f0 
f010255a:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102561:	f0 
f0102562:	c7 44 24 04 99 04 00 	movl   $0x499,0x4(%esp)
f0102569:	00 
f010256a:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102571:	e8 0f db ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102576:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010257d:	e8 2c f1 ff ff       	call   f01016ae <page_alloc>
f0102582:	85 c0                	test   %eax,%eax
f0102584:	74 24                	je     f01025aa <check_page+0xab9>
f0102586:	c7 44 24 0c c8 8d 10 	movl   $0xf0108dc8,0xc(%esp)
f010258d:	f0 
f010258e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102595:	f0 
f0102596:	c7 44 24 04 9c 04 00 	movl   $0x49c,0x4(%esp)
f010259d:	00 
f010259e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01025a5:	e8 db da ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025aa:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01025af:	8b 08                	mov    (%eax),%ecx
f01025b1:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025b7:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01025ba:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f01025c0:	c1 fa 03             	sar    $0x3,%edx
f01025c3:	c1 e2 0c             	shl    $0xc,%edx
f01025c6:	39 d1                	cmp    %edx,%ecx
f01025c8:	74 24                	je     f01025ee <check_page+0xafd>
f01025ca:	c7 44 24 0c 58 87 10 	movl   $0xf0108758,0xc(%esp)
f01025d1:	f0 
f01025d2:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01025d9:	f0 
f01025da:	c7 44 24 04 9f 04 00 	movl   $0x49f,0x4(%esp)
f01025e1:	00 
f01025e2:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01025e9:	e8 97 da ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f01025ee:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01025f4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01025f9:	74 24                	je     f010261f <check_page+0xb2e>
f01025fb:	c7 44 24 0c e8 8d 10 	movl   $0xf0108de8,0xc(%esp)
f0102602:	f0 
f0102603:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010260a:	f0 
f010260b:	c7 44 24 04 a1 04 00 	movl   $0x4a1,0x4(%esp)
f0102612:	00 
f0102613:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010261a:	e8 66 da ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f010261f:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102625:	89 34 24             	mov    %esi,(%esp)
f0102628:	e8 6a e7 ff ff       	call   f0100d97 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010262d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102634:	00 
f0102635:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010263c:	00 
f010263d:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102642:	89 04 24             	mov    %eax,(%esp)
f0102645:	e8 e8 f0 ff ff       	call   f0101732 <pgdir_walk>
f010264a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010264d:	8b 0d 98 5e 27 f0    	mov    0xf0275e98,%ecx
f0102653:	83 c1 04             	add    $0x4,%ecx
f0102656:	8b 11                	mov    (%ecx),%edx
f0102658:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010265e:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102661:	c1 ea 0c             	shr    $0xc,%edx
f0102664:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f010266a:	72 23                	jb     f010268f <check_page+0xb9e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010266c:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010266f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102673:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f010267a:	f0 
f010267b:	c7 44 24 04 a8 04 00 	movl   $0x4a8,0x4(%esp)
f0102682:	00 
f0102683:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010268a:	e8 f6 d9 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010268f:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102692:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102698:	39 d0                	cmp    %edx,%eax
f010269a:	74 24                	je     f01026c0 <check_page+0xbcf>
f010269c:	c7 44 24 0c 53 8e 10 	movl   $0xf0108e53,0xc(%esp)
f01026a3:	f0 
f01026a4:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01026ab:	f0 
f01026ac:	c7 44 24 04 a9 04 00 	movl   $0x4a9,0x4(%esp)
f01026b3:	00 
f01026b4:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01026bb:	e8 c5 d9 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01026c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f01026c6:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01026cc:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01026cf:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f01026d5:	c1 f8 03             	sar    $0x3,%eax
f01026d8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026db:	89 c2                	mov    %eax,%edx
f01026dd:	c1 ea 0c             	shr    $0xc,%edx
f01026e0:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f01026e6:	72 20                	jb     f0102708 <check_page+0xc17>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026ec:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01026f3:	f0 
f01026f4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01026fb:	00 
f01026fc:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0102703:	e8 7d d9 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102708:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010270f:	00 
f0102710:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102717:	00 
f0102718:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010271d:	89 04 24             	mov    %eax,(%esp)
f0102720:	e8 41 42 00 00       	call   f0106966 <memset>
	page_free(pp0);
f0102725:	89 34 24             	mov    %esi,(%esp)
f0102728:	e8 6a e6 ff ff       	call   f0100d97 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010272d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102734:	00 
f0102735:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010273c:	00 
f010273d:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0102742:	89 04 24             	mov    %eax,(%esp)
f0102745:	e8 e8 ef ff ff       	call   f0101732 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f010274a:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010274d:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0102753:	c1 fa 03             	sar    $0x3,%edx
f0102756:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102759:	89 d0                	mov    %edx,%eax
f010275b:	c1 e8 0c             	shr    $0xc,%eax
f010275e:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0102764:	72 20                	jb     f0102786 <check_page+0xc95>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102766:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010276a:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0102771:	f0 
f0102772:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102779:	00 
f010277a:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0102781:	e8 ff d8 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0102786:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f010278c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010278f:	f6 00 01             	testb  $0x1,(%eax)
f0102792:	75 11                	jne    f01027a5 <check_page+0xcb4>
f0102794:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
}


// check page_insert, page_remove, &c
static void
check_page(void)
f010279a:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01027a0:	f6 00 01             	testb  $0x1,(%eax)
f01027a3:	74 24                	je     f01027c9 <check_page+0xcd8>
f01027a5:	c7 44 24 0c 6b 8e 10 	movl   $0xf0108e6b,0xc(%esp)
f01027ac:	f0 
f01027ad:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01027b4:	f0 
f01027b5:	c7 44 24 04 b3 04 00 	movl   $0x4b3,0x4(%esp)
f01027bc:	00 
f01027bd:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01027c4:	e8 bc d8 ff ff       	call   f0100085 <_panic>
f01027c9:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01027cc:	39 d0                	cmp    %edx,%eax
f01027ce:	75 d0                	jne    f01027a0 <check_page+0xcaf>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01027d0:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01027d5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027db:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f01027e1:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01027e4:	a3 30 52 27 f0       	mov    %eax,0xf0275230

	// free the pages we took
	page_free(pp0);
f01027e9:	89 34 24             	mov    %esi,(%esp)
f01027ec:	e8 a6 e5 ff ff       	call   f0100d97 <page_free>
	page_free(pp1);
f01027f1:	89 3c 24             	mov    %edi,(%esp)
f01027f4:	e8 9e e5 ff ff       	call   f0100d97 <page_free>
	page_free(pp2);
f01027f9:	89 1c 24             	mov    %ebx,(%esp)
f01027fc:	e8 96 e5 ff ff       	call   f0100d97 <page_free>

	cprintf("check_page() succeeded!\n");
f0102801:	c7 04 24 82 8e 10 f0 	movl   $0xf0108e82,(%esp)
f0102808:	e8 3e 1c 00 00       	call   f010444b <cprintf>
}
f010280d:	83 c4 3c             	add    $0x3c,%esp
f0102810:	5b                   	pop    %ebx
f0102811:	5e                   	pop    %esi
f0102812:	5f                   	pop    %edi
f0102813:	5d                   	pop    %ebp
f0102814:	c3                   	ret    

f0102815 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0102815:	55                   	push   %ebp
f0102816:	89 e5                	mov    %esp,%ebp
f0102818:	57                   	push   %edi
f0102819:	56                   	push   %esi
f010281a:	53                   	push   %ebx
f010281b:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f010281e:	b8 15 00 00 00       	mov    $0x15,%eax
f0102823:	e8 98 e6 ff ff       	call   f0100ec0 <nvram_read>
f0102828:	c1 e0 0a             	shl    $0xa,%eax
f010282b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0102831:	85 c0                	test   %eax,%eax
f0102833:	0f 48 c2             	cmovs  %edx,%eax
f0102836:	c1 f8 0c             	sar    $0xc,%eax
f0102839:	a3 2c 52 27 f0       	mov    %eax,0xf027522c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f010283e:	b8 17 00 00 00       	mov    $0x17,%eax
f0102843:	e8 78 e6 ff ff       	call   f0100ec0 <nvram_read>
f0102848:	c1 e0 0a             	shl    $0xa,%eax
f010284b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0102851:	85 c0                	test   %eax,%eax
f0102853:	0f 48 c2             	cmovs  %edx,%eax
f0102856:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0102859:	85 c0                	test   %eax,%eax
f010285b:	74 0e                	je     f010286b <mem_init+0x56>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010285d:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0102863:	89 15 94 5e 27 f0    	mov    %edx,0xf0275e94
f0102869:	eb 0c                	jmp    f0102877 <mem_init+0x62>
	else
		npages = npages_basemem;
f010286b:	8b 15 2c 52 27 f0    	mov    0xf027522c,%edx
f0102871:	89 15 94 5e 27 f0    	mov    %edx,0xf0275e94

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0102877:	c1 e0 0c             	shl    $0xc,%eax
f010287a:	c1 e8 0a             	shr    $0xa,%eax
f010287d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102881:	a1 2c 52 27 f0       	mov    0xf027522c,%eax
f0102886:	c1 e0 0c             	shl    $0xc,%eax
f0102889:	c1 e8 0a             	shr    $0xa,%eax
f010288c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102890:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f0102895:	c1 e0 0c             	shl    $0xc,%eax
f0102898:	c1 e8 0a             	shr    $0xa,%eax
f010289b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010289f:	c7 04 24 6c 8a 10 f0 	movl   $0xf0108a6c,(%esp)
f01028a6:	e8 a0 1b 00 00       	call   f010444b <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01028ab:	b8 00 10 00 00       	mov    $0x1000,%eax
f01028b0:	e8 ab e4 ff ff       	call   f0100d60 <boot_alloc>
f01028b5:	a3 98 5e 27 f0       	mov    %eax,0xf0275e98
	memset(kern_pgdir, 0, PGSIZE);
f01028ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01028c1:	00 
f01028c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028c9:	00 
f01028ca:	89 04 24             	mov    %eax,(%esp)
f01028cd:	e8 94 40 00 00       	call   f0106966 <memset>
	// Recursively insert PD in itself as a page table, to form
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following two lines.)	
	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01028d2:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028d7:	89 c2                	mov    %eax,%edx
f01028d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028de:	77 20                	ja     f0102900 <mem_init+0xeb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028e4:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01028eb:	f0 
f01028ec:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
f01028f3:	00 
f01028f4:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01028fb:	e8 85 d7 ff ff       	call   f0100085 <_panic>
f0102900:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102906:	83 ca 05             	or     $0x5,%edx
f0102909:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate an array of npages 'struct Page's and store it in 'pages'.
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct Page in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	pages = boot_alloc(npages * sizeof(struct Page));
f010290f:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f0102914:	c1 e0 03             	shl    $0x3,%eax
f0102917:	e8 44 e4 ff ff       	call   f0100d60 <boot_alloc>
f010291c:	a3 9c 5e 27 f0       	mov    %eax,0xf0275e9c
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs=boot_alloc(NENV*sizeof(struct Env));
f0102921:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0102926:	e8 35 e4 ff ff       	call   f0100d60 <boot_alloc>
f010292b:	a3 40 52 27 f0       	mov    %eax,0xf0275240
	cprintf("%d\n",NENV);
f0102930:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102937:	00 
f0102938:	c7 04 24 e0 7f 10 f0 	movl   $0xf0107fe0,(%esp)
f010293f:	e8 07 1b 00 00       	call   f010444b <cprintf>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0102944:	e8 4e e9 ff ff       	call   f0101297 <page_init>

	check_page_free_list(1);
f0102949:	b8 01 00 00 00       	mov    $0x1,%eax
f010294e:	e8 9f e5 ff ff       	call   f0100ef2 <check_page_free_list>
	int nfree;
	struct Page *fl;
	char *c;
	int i;

	if (!pages)
f0102953:	83 3d 9c 5e 27 f0 00 	cmpl   $0x0,0xf0275e9c
f010295a:	75 1c                	jne    f0102978 <mem_init+0x163>
		panic("'pages' is a null pointer!");
f010295c:	c7 44 24 08 9b 8e 10 	movl   $0xf0108e9b,0x8(%esp)
f0102963:	f0 
f0102964:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f010296b:	00 
f010296c:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102973:	e8 0d d7 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102978:	a1 30 52 27 f0       	mov    0xf0275230,%eax
f010297d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102982:	85 c0                	test   %eax,%eax
f0102984:	74 09                	je     f010298f <mem_init+0x17a>
		++nfree;
f0102986:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0102989:	8b 00                	mov    (%eax),%eax
f010298b:	85 c0                	test   %eax,%eax
f010298d:	75 f7                	jne    f0102986 <mem_init+0x171>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010298f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102996:	e8 13 ed ff ff       	call   f01016ae <page_alloc>
f010299b:	89 c6                	mov    %eax,%esi
f010299d:	85 c0                	test   %eax,%eax
f010299f:	75 24                	jne    f01029c5 <mem_init+0x1b0>
f01029a1:	c7 44 24 0c 74 8d 10 	movl   $0xf0108d74,0xc(%esp)
f01029a8:	f0 
f01029a9:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01029b0:	f0 
f01029b1:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01029b8:	00 
f01029b9:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01029c0:	e8 c0 d6 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f01029c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029cc:	e8 dd ec ff ff       	call   f01016ae <page_alloc>
f01029d1:	89 c7                	mov    %eax,%edi
f01029d3:	85 c0                	test   %eax,%eax
f01029d5:	75 24                	jne    f01029fb <mem_init+0x1e6>
f01029d7:	c7 44 24 0c 8a 8d 10 	movl   $0xf0108d8a,0xc(%esp)
f01029de:	f0 
f01029df:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01029e6:	f0 
f01029e7:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f01029ee:	00 
f01029ef:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01029f6:	e8 8a d6 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01029fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a02:	e8 a7 ec ff ff       	call   f01016ae <page_alloc>
f0102a07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102a0a:	85 c0                	test   %eax,%eax
f0102a0c:	75 24                	jne    f0102a32 <mem_init+0x21d>
f0102a0e:	c7 44 24 0c a0 8d 10 	movl   $0xf0108da0,0xc(%esp)
f0102a15:	f0 
f0102a16:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102a1d:	f0 
f0102a1e:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102a25:	00 
f0102a26:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102a2d:	e8 53 d6 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102a32:	39 fe                	cmp    %edi,%esi
f0102a34:	75 24                	jne    f0102a5a <mem_init+0x245>
f0102a36:	c7 44 24 0c b6 8d 10 	movl   $0xf0108db6,0xc(%esp)
f0102a3d:	f0 
f0102a3e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102a45:	f0 
f0102a46:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102a4d:	00 
f0102a4e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102a55:	e8 2b d6 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102a5a:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102a5d:	74 05                	je     f0102a64 <mem_init+0x24f>
f0102a5f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102a62:	75 24                	jne    f0102a88 <mem_init+0x273>
f0102a64:	c7 44 24 0c a0 86 10 	movl   $0xf01086a0,0xc(%esp)
f0102a6b:	f0 
f0102a6c:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102a73:	f0 
f0102a74:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102a7b:	00 
f0102a7c:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102a83:	e8 fd d5 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a88:	8b 15 9c 5e 27 f0    	mov    0xf0275e9c,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0102a8e:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f0102a93:	c1 e0 0c             	shl    $0xc,%eax
f0102a96:	89 f1                	mov    %esi,%ecx
f0102a98:	29 d1                	sub    %edx,%ecx
f0102a9a:	c1 f9 03             	sar    $0x3,%ecx
f0102a9d:	c1 e1 0c             	shl    $0xc,%ecx
f0102aa0:	39 c1                	cmp    %eax,%ecx
f0102aa2:	72 24                	jb     f0102ac8 <mem_init+0x2b3>
f0102aa4:	c7 44 24 0c b6 8e 10 	movl   $0xf0108eb6,0xc(%esp)
f0102aab:	f0 
f0102aac:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102ab3:	f0 
f0102ab4:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f0102abb:	00 
f0102abc:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102ac3:	e8 bd d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0102ac8:	89 f9                	mov    %edi,%ecx
f0102aca:	29 d1                	sub    %edx,%ecx
f0102acc:	c1 f9 03             	sar    $0x3,%ecx
f0102acf:	c1 e1 0c             	shl    $0xc,%ecx
f0102ad2:	39 c8                	cmp    %ecx,%eax
f0102ad4:	77 24                	ja     f0102afa <mem_init+0x2e5>
f0102ad6:	c7 44 24 0c d3 8e 10 	movl   $0xf0108ed3,0xc(%esp)
f0102add:	f0 
f0102ade:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102ae5:	f0 
f0102ae6:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102aed:	00 
f0102aee:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102af5:	e8 8b d5 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0102afa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102afd:	29 d1                	sub    %edx,%ecx
f0102aff:	89 ca                	mov    %ecx,%edx
f0102b01:	c1 fa 03             	sar    $0x3,%edx
f0102b04:	c1 e2 0c             	shl    $0xc,%edx
f0102b07:	39 d0                	cmp    %edx,%eax
f0102b09:	77 24                	ja     f0102b2f <mem_init+0x31a>
f0102b0b:	c7 44 24 0c f0 8e 10 	movl   $0xf0108ef0,0xc(%esp)
f0102b12:	f0 
f0102b13:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102b1a:	f0 
f0102b1b:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102b22:	00 
f0102b23:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102b2a:	e8 56 d5 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102b2f:	a1 30 52 27 f0       	mov    0xf0275230,%eax
f0102b34:	89 45 dc             	mov    %eax,-0x24(%ebp)
	page_free_list = 0;
f0102b37:	c7 05 30 52 27 f0 00 	movl   $0x0,0xf0275230
f0102b3e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b48:	e8 61 eb ff ff       	call   f01016ae <page_alloc>
f0102b4d:	85 c0                	test   %eax,%eax
f0102b4f:	74 24                	je     f0102b75 <mem_init+0x360>
f0102b51:	c7 44 24 0c c8 8d 10 	movl   $0xf0108dc8,0xc(%esp)
f0102b58:	f0 
f0102b59:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102b60:	f0 
f0102b61:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102b68:	00 
f0102b69:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102b70:	e8 10 d5 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0102b75:	89 34 24             	mov    %esi,(%esp)
f0102b78:	e8 1a e2 ff ff       	call   f0100d97 <page_free>
	page_free(pp1);
f0102b7d:	89 3c 24             	mov    %edi,(%esp)
f0102b80:	e8 12 e2 ff ff       	call   f0100d97 <page_free>
	page_free(pp2);
f0102b85:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102b88:	89 0c 24             	mov    %ecx,(%esp)
f0102b8b:	e8 07 e2 ff ff       	call   f0100d97 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b97:	e8 12 eb ff ff       	call   f01016ae <page_alloc>
f0102b9c:	89 c6                	mov    %eax,%esi
f0102b9e:	85 c0                	test   %eax,%eax
f0102ba0:	75 24                	jne    f0102bc6 <mem_init+0x3b1>
f0102ba2:	c7 44 24 0c 74 8d 10 	movl   $0xf0108d74,0xc(%esp)
f0102ba9:	f0 
f0102baa:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102bb1:	f0 
f0102bb2:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f0102bb9:	00 
f0102bba:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102bc1:	e8 bf d4 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0102bc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bcd:	e8 dc ea ff ff       	call   f01016ae <page_alloc>
f0102bd2:	89 c7                	mov    %eax,%edi
f0102bd4:	85 c0                	test   %eax,%eax
f0102bd6:	75 24                	jne    f0102bfc <mem_init+0x3e7>
f0102bd8:	c7 44 24 0c 8a 8d 10 	movl   $0xf0108d8a,0xc(%esp)
f0102bdf:	f0 
f0102be0:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102be7:	f0 
f0102be8:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102bef:	00 
f0102bf0:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102bf7:	e8 89 d4 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bfc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c03:	e8 a6 ea ff ff       	call   f01016ae <page_alloc>
f0102c08:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102c0b:	85 c0                	test   %eax,%eax
f0102c0d:	75 24                	jne    f0102c33 <mem_init+0x41e>
f0102c0f:	c7 44 24 0c a0 8d 10 	movl   $0xf0108da0,0xc(%esp)
f0102c16:	f0 
f0102c17:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102c1e:	f0 
f0102c1f:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0102c26:	00 
f0102c27:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102c2e:	e8 52 d4 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102c33:	39 fe                	cmp    %edi,%esi
f0102c35:	75 24                	jne    f0102c5b <mem_init+0x446>
f0102c37:	c7 44 24 0c b6 8d 10 	movl   $0xf0108db6,0xc(%esp)
f0102c3e:	f0 
f0102c3f:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102c46:	f0 
f0102c47:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0102c4e:	00 
f0102c4f:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102c56:	e8 2a d4 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102c5b:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102c5e:	74 05                	je     f0102c65 <mem_init+0x450>
f0102c60:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0102c63:	75 24                	jne    f0102c89 <mem_init+0x474>
f0102c65:	c7 44 24 0c a0 86 10 	movl   $0xf01086a0,0xc(%esp)
f0102c6c:	f0 
f0102c6d:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102c74:	f0 
f0102c75:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0102c7c:	00 
f0102c7d:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102c84:	e8 fc d3 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0102c89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102c90:	e8 19 ea ff ff       	call   f01016ae <page_alloc>
f0102c95:	85 c0                	test   %eax,%eax
f0102c97:	74 24                	je     f0102cbd <mem_init+0x4a8>
f0102c99:	c7 44 24 0c c8 8d 10 	movl   $0xf0108dc8,0xc(%esp)
f0102ca0:	f0 
f0102ca1:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102ca8:	f0 
f0102ca9:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f0102cb0:	00 
f0102cb1:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102cb8:	e8 c8 d3 ff ff       	call   f0100085 <_panic>
f0102cbd:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0102cc0:	89 f0                	mov    %esi,%eax
f0102cc2:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f0102cc8:	c1 f8 03             	sar    $0x3,%eax
f0102ccb:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cce:	89 c2                	mov    %eax,%edx
f0102cd0:	c1 ea 0c             	shr    $0xc,%edx
f0102cd3:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0102cd9:	72 20                	jb     f0102cfb <mem_init+0x4e6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cdf:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0102ce6:	f0 
f0102ce7:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102cee:	00 
f0102cef:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0102cf6:	e8 8a d3 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0102cfb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102d02:	00 
f0102d03:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102d0a:	00 
f0102d0b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102d10:	89 04 24             	mov    %eax,(%esp)
f0102d13:	e8 4e 3c 00 00       	call   f0106966 <memset>
	page_free(pp0);
f0102d18:	89 34 24             	mov    %esi,(%esp)
f0102d1b:	e8 77 e0 ff ff       	call   f0100d97 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0102d20:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102d27:	e8 82 e9 ff ff       	call   f01016ae <page_alloc>
f0102d2c:	85 c0                	test   %eax,%eax
f0102d2e:	75 24                	jne    f0102d54 <mem_init+0x53f>
f0102d30:	c7 44 24 0c 0d 8f 10 	movl   $0xf0108f0d,0xc(%esp)
f0102d37:	f0 
f0102d38:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102d3f:	f0 
f0102d40:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f0102d47:	00 
f0102d48:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102d4f:	e8 31 d3 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0102d54:	39 c6                	cmp    %eax,%esi
f0102d56:	74 24                	je     f0102d7c <mem_init+0x567>
f0102d58:	c7 44 24 0c 2b 8f 10 	movl   $0xf0108f2b,0xc(%esp)
f0102d5f:	f0 
f0102d60:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102d67:	f0 
f0102d68:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0102d6f:	00 
f0102d70:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102d77:	e8 09 d3 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d7c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102d7f:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0102d85:	c1 fa 03             	sar    $0x3,%edx
f0102d88:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d8b:	89 d0                	mov    %edx,%eax
f0102d8d:	c1 e8 0c             	shr    $0xc,%eax
f0102d90:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0102d96:	72 20                	jb     f0102db8 <mem_init+0x5a3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d98:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102d9c:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0102da3:	f0 
f0102da4:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0102dab:	00 
f0102dac:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0102db3:	e8 cd d2 ff ff       	call   f0100085 <_panic>
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102db8:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0102dbf:	75 11                	jne    f0102dd2 <mem_init+0x5bd>
f0102dc1:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102dc7:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0102dcd:	80 38 00             	cmpb   $0x0,(%eax)
f0102dd0:	74 24                	je     f0102df6 <mem_init+0x5e1>
f0102dd2:	c7 44 24 0c 3b 8f 10 	movl   $0xf0108f3b,0xc(%esp)
f0102dd9:	f0 
f0102dda:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102de1:	f0 
f0102de2:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0102de9:	00 
f0102dea:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102df1:	e8 8f d2 ff ff       	call   f0100085 <_panic>
f0102df6:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0102df9:	39 d0                	cmp    %edx,%eax
f0102dfb:	75 d0                	jne    f0102dcd <mem_init+0x5b8>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0102dfd:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102e00:	a3 30 52 27 f0       	mov    %eax,0xf0275230

	// free the pages we took
	page_free(pp0);
f0102e05:	89 34 24             	mov    %esi,(%esp)
f0102e08:	e8 8a df ff ff       	call   f0100d97 <page_free>
	page_free(pp1);
f0102e0d:	89 3c 24             	mov    %edi,(%esp)
f0102e10:	e8 82 df ff ff       	call   f0100d97 <page_free>
	page_free(pp2);
f0102e15:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e18:	89 0c 24             	mov    %ecx,(%esp)
f0102e1b:	e8 77 df ff ff       	call   f0100d97 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102e20:	a1 30 52 27 f0       	mov    0xf0275230,%eax
f0102e25:	85 c0                	test   %eax,%eax
f0102e27:	74 09                	je     f0102e32 <mem_init+0x61d>
		--nfree;
f0102e29:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0102e2c:	8b 00                	mov    (%eax),%eax
f0102e2e:	85 c0                	test   %eax,%eax
f0102e30:	75 f7                	jne    f0102e29 <mem_init+0x614>
		--nfree;
	assert(nfree == 0);
f0102e32:	85 db                	test   %ebx,%ebx
f0102e34:	74 24                	je     f0102e5a <mem_init+0x645>
f0102e36:	c7 44 24 0c 45 8f 10 	movl   $0xf0108f45,0xc(%esp)
f0102e3d:	f0 
f0102e3e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102e45:	f0 
f0102e46:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0102e4d:	00 
f0102e4e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102e55:	e8 2b d2 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0102e5a:	c7 04 24 a8 8a 10 f0 	movl   $0xf0108aa8,(%esp)
f0102e61:	e8 e5 15 00 00       	call   f010444b <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	check_page();
f0102e66:	e8 86 ec ff ff       	call   f0101af1 <check_page>
	char* addr;
	int i;
	pp = pp0 = 0;
	
	// Allocate two single pages
	pp =  page_alloc(0);
f0102e6b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e72:	e8 37 e8 ff ff       	call   f01016ae <page_alloc>
f0102e77:	89 c3                	mov    %eax,%ebx
	pp0 = page_alloc(0);
f0102e79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102e80:	e8 29 e8 ff ff       	call   f01016ae <page_alloc>
f0102e85:	89 c6                	mov    %eax,%esi
	assert(pp != 0);
f0102e87:	85 db                	test   %ebx,%ebx
f0102e89:	75 24                	jne    f0102eaf <mem_init+0x69a>
f0102e8b:	c7 44 24 0c 50 8f 10 	movl   $0xf0108f50,0xc(%esp)
f0102e92:	f0 
f0102e93:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102e9a:	f0 
f0102e9b:	c7 44 24 04 dd 04 00 	movl   $0x4dd,0x4(%esp)
f0102ea2:	00 
f0102ea3:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102eaa:	e8 d6 d1 ff ff       	call   f0100085 <_panic>
	assert(pp0 != 0);
f0102eaf:	85 c0                	test   %eax,%eax
f0102eb1:	75 24                	jne    f0102ed7 <mem_init+0x6c2>
f0102eb3:	c7 44 24 0c 58 8f 10 	movl   $0xf0108f58,0xc(%esp)
f0102eba:	f0 
f0102ebb:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102ec2:	f0 
f0102ec3:	c7 44 24 04 de 04 00 	movl   $0x4de,0x4(%esp)
f0102eca:	00 
f0102ecb:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102ed2:	e8 ae d1 ff ff       	call   f0100085 <_panic>
	assert(pp != pp0);
f0102ed7:	39 c3                	cmp    %eax,%ebx
f0102ed9:	75 24                	jne    f0102eff <mem_init+0x6ea>
f0102edb:	c7 44 24 0c 61 8f 10 	movl   $0xf0108f61,0xc(%esp)
f0102ee2:	f0 
f0102ee3:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102eea:	f0 
f0102eeb:	c7 44 24 04 df 04 00 	movl   $0x4df,0x4(%esp)
f0102ef2:	00 
f0102ef3:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102efa:	e8 86 d1 ff ff       	call   f0100085 <_panic>

	// Free pp and assign four continuous pages
	page_free(pp);
f0102eff:	89 1c 24             	mov    %ebx,(%esp)
f0102f02:	e8 90 de ff ff       	call   f0100d97 <page_free>
	pp = page_alloc_4pages(0);
f0102f07:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f0e:	e8 88 e4 ff ff       	call   f010139b <page_alloc_4pages>
{
	struct Page *tmp; 
	int i;
	for( tmp = pp, i = 0; i < 3; tmp = tmp->pp_link, i++ )
	{
		if( (page2pa(tmp->pp_link) - page2pa(tmp)) != PGSIZE )
f0102f13:	8b 18                	mov    (%eax),%ebx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0102f15:	8b 15 9c 5e 27 f0    	mov    0xf0275e9c,%edx
f0102f1b:	89 d9                	mov    %ebx,%ecx
f0102f1d:	29 d1                	sub    %edx,%ecx
f0102f1f:	c1 f9 03             	sar    $0x3,%ecx
f0102f22:	c1 e1 0c             	shl    $0xc,%ecx
f0102f25:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102f28:	89 c7                	mov    %eax,%edi
f0102f2a:	29 d7                	sub    %edx,%edi
f0102f2c:	c1 ff 03             	sar    $0x3,%edi
f0102f2f:	89 f9                	mov    %edi,%ecx
f0102f31:	c1 e1 0c             	shl    $0xc,%ecx
f0102f34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f37:	29 cf                	sub    %ecx,%edi
f0102f39:	81 ff 00 10 00 00    	cmp    $0x1000,%edi
f0102f3f:	75 41                	jne    f0102f82 <mem_init+0x76d>
f0102f41:	8b 3b                	mov    (%ebx),%edi
f0102f43:	89 fb                	mov    %edi,%ebx
f0102f45:	29 d3                	sub    %edx,%ebx
f0102f47:	c1 fb 03             	sar    $0x3,%ebx
f0102f4a:	c1 e3 0c             	shl    $0xc,%ebx
f0102f4d:	89 d9                	mov    %ebx,%ecx
f0102f4f:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
f0102f52:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
f0102f58:	75 28                	jne    f0102f82 <mem_init+0x76d>
f0102f5a:	8b 0f                	mov    (%edi),%ecx
f0102f5c:	29 d1                	sub    %edx,%ecx
f0102f5e:	89 ca                	mov    %ecx,%edx
f0102f60:	c1 fa 03             	sar    $0x3,%edx
f0102f63:	c1 e2 0c             	shl    $0xc,%edx
f0102f66:	29 da                	sub    %ebx,%edx
f0102f68:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0102f6e:	75 12                	jne    f0102f82 <mem_init+0x76d>
	page_free(pp);
	pp = page_alloc_4pages(0);
	assert(check_continuous(pp));

	// Free four continuous pages
	assert(!page_free_4pages(pp));
f0102f70:	89 04 24             	mov    %eax,(%esp)
f0102f73:	e8 3b de ff ff       	call   f0100db3 <page_free_4pages>
f0102f78:	85 c0                	test   %eax,%eax
f0102f7a:	74 4e                	je     f0102fca <mem_init+0x7b5>
f0102f7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102f80:	eb 24                	jmp    f0102fa6 <mem_init+0x791>
	assert(pp != pp0);

	// Free pp and assign four continuous pages
	page_free(pp);
	pp = page_alloc_4pages(0);
	assert(check_continuous(pp));
f0102f82:	c7 44 24 0c 6b 8f 10 	movl   $0xf0108f6b,0xc(%esp)
f0102f89:	f0 
f0102f8a:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102f91:	f0 
f0102f92:	c7 44 24 04 e4 04 00 	movl   $0x4e4,0x4(%esp)
f0102f99:	00 
f0102f9a:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102fa1:	e8 df d0 ff ff       	call   f0100085 <_panic>

	// Free four continuous pages
	assert(!page_free_4pages(pp));
f0102fa6:	c7 44 24 0c 80 8f 10 	movl   $0xf0108f80,0xc(%esp)
f0102fad:	f0 
f0102fae:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0102fb5:	f0 
f0102fb6:	c7 44 24 04 e7 04 00 	movl   $0x4e7,0x4(%esp)
f0102fbd:	00 
f0102fbe:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0102fc5:	e8 bb d0 ff ff       	call   f0100085 <_panic>
	//cprintf("herefinish?\n");
	// Free pp0 and assign four continuous zero pages
	page_free(pp0);
f0102fca:	89 34 24             	mov    %esi,(%esp)
f0102fcd:	e8 c5 dd ff ff       	call   f0100d97 <page_free>
	//cprintf("free what?:%d\n",PGNUM(page2pa(pp0)));
	pp0 = page_alloc_4pages(ALLOC_ZERO);
f0102fd2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102fd9:	e8 bd e3 ff ff       	call   f010139b <page_alloc_4pages>
f0102fde:	89 c1                	mov    %eax,%ecx
f0102fe0:	2b 0d 9c 5e 27 f0    	sub    0xf0275e9c,%ecx
f0102fe6:	c1 f9 03             	sar    $0x3,%ecx
f0102fe9:	c1 e1 0c             	shl    $0xc,%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fec:	89 ca                	mov    %ecx,%edx
f0102fee:	c1 ea 0c             	shr    $0xc,%edx
f0102ff1:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0102ff7:	72 20                	jb     f0103019 <mem_init+0x804>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ff9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102ffd:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0103004:	f0 
f0103005:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010300c:	00 
f010300d:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0103014:	e8 6c d0 ff ff       	call   f0100085 <_panic>
	addr = (char*)page2kva(pp0);
	//cprintf("herefinishover?\n");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f0103019:	80 b9 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%ecx)
f0103020:	75 11                	jne    f0103033 <mem_init+0x81e>
f0103022:	8d 91 01 00 00 f0    	lea    -0xfffffff(%ecx),%edx
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0103028:	81 e9 00 c0 ff 0f    	sub    $0xfffc000,%ecx
	pp0 = page_alloc_4pages(ALLOC_ZERO);
	addr = (char*)page2kva(pp0);
	//cprintf("herefinishover?\n");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
		assert(addr[i] == 0);
f010302e:	80 3a 00             	cmpb   $0x0,(%edx)
f0103031:	74 24                	je     f0103057 <mem_init+0x842>
f0103033:	c7 44 24 0c 96 8f 10 	movl   $0xf0108f96,0xc(%esp)
f010303a:	f0 
f010303b:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103042:	f0 
f0103043:	c7 44 24 04 f1 04 00 	movl   $0x4f1,0x4(%esp)
f010304a:	00 
f010304b:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103052:	e8 2e d0 ff ff       	call   f0100085 <_panic>
f0103057:	83 c2 01             	add    $0x1,%edx
	//cprintf("free what?:%d\n",PGNUM(page2pa(pp0)));
	pp0 = page_alloc_4pages(ALLOC_ZERO);
	addr = (char*)page2kva(pp0);
	//cprintf("herefinishover?\n");
	// Check Zero
	for( i = 0; i < 4 * PGSIZE; i++ ){
f010305a:	39 ca                	cmp    %ecx,%edx
f010305c:	75 d0                	jne    f010302e <mem_init+0x819>
		assert(addr[i] == 0);
	}

	// Free pages
	assert(!page_free_4pages(pp0));
f010305e:	89 04 24             	mov    %eax,(%esp)
f0103061:	e8 4d dd ff ff       	call   f0100db3 <page_free_4pages>
f0103066:	85 c0                	test   %eax,%eax
f0103068:	74 24                	je     f010308e <mem_init+0x879>
f010306a:	c7 44 24 0c a3 8f 10 	movl   $0xf0108fa3,0xc(%esp)
f0103071:	f0 
f0103072:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103079:	f0 
f010307a:	c7 44 24 04 f5 04 00 	movl   $0x4f5,0x4(%esp)
f0103081:	00 
f0103082:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103089:	e8 f7 cf ff ff       	call   f0100085 <_panic>
	cprintf("check_four_pages() succeeded!\n");
f010308e:	c7 04 24 c8 8a 10 f0 	movl   $0xf0108ac8,(%esp)
f0103095:	e8 b1 13 00 00       	call   f010444b <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	cprintf("map pages\n");
f010309a:	c7 04 24 ba 8f 10 f0 	movl   $0xf0108fba,(%esp)
f01030a1:	e8 a5 13 00 00       	call   f010444b <cprintf>
	boot_map_region(kern_pgdir, UPAGES, ROUNDUP(npages * sizeof (struct Page), PGSIZE), PADDR(pages), PTE_P | PTE_U);
f01030a6:	a1 9c 5e 27 f0       	mov    0xf0275e9c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030ab:	89 c2                	mov    %eax,%edx
f01030ad:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030b2:	77 20                	ja     f01030d4 <mem_init+0x8bf>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030b8:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01030bf:	f0 
f01030c0:	c7 44 24 04 b8 00 00 	movl   $0xb8,0x4(%esp)
f01030c7:	00 
f01030c8:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01030cf:	e8 b1 cf ff ff       	call   f0100085 <_panic>
f01030d4:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f01030d9:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01030e0:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
f01030e7:	00 
f01030e8:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01030ee:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01030f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01030f7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030fb:	c7 44 24 04 00 00 00 	movl   $0xef000000,0x4(%esp)
f0103102:	ef 
f0103103:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0103108:	89 04 24             	mov    %eax,(%esp)
f010310b:	e8 87 e9 ff ff       	call   f0101a97 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir,UENVS,/* ROUNDUP(sizeof(struct Env) * NENV, PGSIZE) */PTSIZE,PADDR(envs),PTE_U | PTE_P);
f0103110:	a1 40 52 27 f0       	mov    0xf0275240,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103115:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010311a:	77 20                	ja     f010313c <mem_init+0x927>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010311c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103120:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0103127:	f0 
f0103128:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f010312f:	00 
f0103130:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103137:	e8 49 cf ff ff       	call   f0100085 <_panic>
f010313c:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
f0103143:	00 
f0103144:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010314a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010314e:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0103155:	00 
f0103156:	c7 44 24 04 00 00 c0 	movl   $0xeec00000,0x4(%esp)
f010315d:	ee 
f010315e:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0103163:	89 04 24             	mov    %eax,(%esp)
f0103166:	e8 2c e9 ff ff       	call   f0101a97 <boot_map_region>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	cprintf("map bootstack\n");
f010316b:	c7 04 24 c5 8f 10 f0 	movl   $0xf0108fc5,(%esp)
f0103172:	e8 d4 12 00 00       	call   f010444b <cprintf>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	cprintf("map KERNBASE\n");
f0103177:	c7 04 24 d4 8f 10 f0 	movl   $0xf0108fd4,(%esp)
f010317e:	e8 c8 12 00 00       	call   f010444b <cprintf>
	boot_map_region(kern_pgdir, KERNBASE, /* ROUNDUP(0xffffffff - KERNBASE, PGSIZE) *//* 0xffffffff - KERNBASE + 1 */~KERNBASE + 1, 0, PTE_W | PTE_P);
f0103183:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f010318a:	00 
f010318b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103192:	00 
f0103193:	c7 44 24 08 00 00 00 	movl   $0x10000000,0x8(%esp)
f010319a:	10 
f010319b:	c7 44 24 04 00 00 00 	movl   $0xf0000000,0x4(%esp)
f01031a2:	f0 
f01031a3:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01031a8:	89 04 24             	mov    %eax,(%esp)
f01031ab:	e8 e7 e8 ff ff       	call   f0101a97 <boot_map_region>

	// Initialize the SMP-related parts of the memory map
	cprintf("SMP-related memory map\n");
f01031b0:	c7 04 24 e2 8f 10 f0 	movl   $0xf0108fe2,(%esp)
f01031b7:	e8 8f 12 00 00       	call   f010444b <cprintf>
static void
mem_init_mp(void)
{
	// Create a direct mapping at the top of virtual address space starting
	// at IOMEMBASE for accessing the LAPIC unit using memory-mapped I/O.
	boot_map_region(kern_pgdir, IOMEMBASE, -IOMEMBASE, IOMEM_PADDR, PTE_W);
f01031bc:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
f01031c3:	00 
f01031c4:	c7 44 24 0c 00 00 00 	movl   $0xfe000000,0xc(%esp)
f01031cb:	fe 
f01031cc:	c7 44 24 08 00 00 00 	movl   $0x2000000,0x8(%esp)
f01031d3:	02 
f01031d4:	c7 44 24 04 00 00 00 	movl   $0xfe000000,0x4(%esp)
f01031db:	fe 
f01031dc:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01031e1:	89 04 24             	mov    %eax,(%esp)
f01031e4:	e8 ae e8 ff ff       	call   f0101a97 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031e9:	c7 45 dc 00 90 27 f0 	movl   $0xf0279000,-0x24(%ebp)
f01031f0:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f01031f7:	0f 87 23 08 00 00    	ja     f0103a20 <mem_init+0x120b>
f01031fd:	b8 00 90 27 f0       	mov    $0xf0279000,%eax
f0103202:	eb 0a                	jmp    f010320e <mem_init+0x9f9>
f0103204:	89 d8                	mov    %ebx,%eax
f0103206:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010320c:	77 20                	ja     f010322e <mem_init+0xa19>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010320e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103212:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0103219:	f0 
f010321a:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0103221:	00 
f0103222:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103229:	e8 57 ce ff ff       	call   f0100085 <_panic>
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir,
f010322e:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f0103235:	00 
f0103236:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010323c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103240:	c7 44 24 08 00 80 00 	movl   $0x8000,0x8(%esp)
f0103247:	00 
f0103248:	89 74 24 04          	mov    %esi,0x4(%esp)
f010324c:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0103251:	89 04 24             	mov    %eax,(%esp)
f0103254:	e8 3e e8 ff ff       	call   f0101a97 <boot_map_region>
f0103259:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010325f:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//             Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
f0103265:	81 fe 00 80 b7 ef    	cmp    $0xefb78000,%esi
f010326b:	75 97                	jne    f0103204 <mem_init+0x9ef>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010326d:	8b 35 98 5e 27 f0    	mov    0xf0275e98,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
f0103273:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f0103278:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f010327f:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103285:	74 79                	je     f0103300 <mem_init+0xaeb>
f0103287:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010328c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0103292:	89 f0                	mov    %esi,%eax
f0103294:	e8 c1 db ff ff       	call   f0100e5a <check_va2pa>
f0103299:	8b 15 9c 5e 27 f0    	mov    0xf0275e9c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010329f:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01032a5:	77 20                	ja     f01032c7 <mem_init+0xab2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032ab:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01032b2:	f0 
f01032b3:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01032ba:	00 
f01032bb:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01032c2:	e8 be cd ff ff       	call   f0100085 <_panic>
f01032c7:	8d 94 1a 00 00 00 10 	lea    0x10000000(%edx,%ebx,1),%edx
f01032ce:	39 d0                	cmp    %edx,%eax
f01032d0:	74 24                	je     f01032f6 <mem_init+0xae1>
f01032d2:	c7 44 24 0c e8 8a 10 	movl   $0xf0108ae8,0xc(%esp)
f01032d9:	f0 
f01032da:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01032e1:	f0 
f01032e2:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f01032e9:	00 
f01032ea:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01032f1:	e8 8f cd ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct Page), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01032f6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01032fc:	39 df                	cmp    %ebx,%edi
f01032fe:	77 8c                	ja     f010328c <mem_init+0xa77>
f0103300:	bb 00 00 00 00       	mov    $0x0,%ebx


	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0103305:	8d 93 00 00 c0 ee    	lea    -0x11400000(%ebx),%edx
f010330b:	89 f0                	mov    %esi,%eax
f010330d:	e8 48 db ff ff       	call   f0100e5a <check_va2pa>
f0103312:	8b 15 40 52 27 f0    	mov    0xf0275240,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103318:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010331e:	77 20                	ja     f0103340 <mem_init+0xb2b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103320:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103324:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f010332b:	f0 
f010332c:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0103333:	00 
f0103334:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010333b:	e8 45 cd ff ff       	call   f0100085 <_panic>
f0103340:	8d 94 13 00 00 00 10 	lea    0x10000000(%ebx,%edx,1),%edx
f0103347:	39 d0                	cmp    %edx,%eax
f0103349:	74 24                	je     f010336f <mem_init+0xb5a>
f010334b:	c7 44 24 0c 1c 8b 10 	movl   $0xf0108b1c,0xc(%esp)
f0103352:	f0 
f0103353:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010335a:	f0 
f010335b:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0103362:	00 
f0103363:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010336a:	e8 16 cd ff ff       	call   f0100085 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010336f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103375:	81 fb 00 f0 01 00    	cmp    $0x1f000,%ebx
f010337b:	75 88                	jne    f0103305 <mem_init+0xaf0>


	//cprintf("check_kern here finish?\n");

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010337d:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f0103382:	c1 e0 0c             	shl    $0xc,%eax
f0103385:	85 c0                	test   %eax,%eax
f0103387:	74 4c                	je     f01033d5 <mem_init+0xbc0>
f0103389:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010338e:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0103394:	89 f0                	mov    %esi,%eax
f0103396:	e8 bf da ff ff       	call   f0100e5a <check_va2pa>
f010339b:	39 c3                	cmp    %eax,%ebx
f010339d:	74 24                	je     f01033c3 <mem_init+0xbae>
f010339f:	c7 44 24 0c 50 8b 10 	movl   $0xf0108b50,0xc(%esp)
f01033a6:	f0 
f01033a7:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01033ae:	f0 
f01033af:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f01033b6:	00 
f01033b7:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01033be:	e8 c2 cc ff ff       	call   f0100085 <_panic>


	//cprintf("check_kern here finish?\n");

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01033c3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033c9:	a1 94 5e 27 f0       	mov    0xf0275e94,%eax
f01033ce:	c1 e0 0c             	shl    $0xc,%eax
f01033d1:	39 c3                	cmp    %eax,%ebx
f01033d3:	72 b9                	jb     f010338e <mem_init+0xb79>
f01033d5:	bb 00 00 00 fe       	mov    $0xfe000000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f01033da:	89 da                	mov    %ebx,%edx
f01033dc:	89 f0                	mov    %esi,%eax
f01033de:	e8 77 da ff ff       	call   f0100e5a <check_va2pa>
f01033e3:	39 c3                	cmp    %eax,%ebx
f01033e5:	74 24                	je     f010340b <mem_init+0xbf6>
f01033e7:	c7 44 24 0c fa 8f 10 	movl   $0xf0108ffa,0xc(%esp)
f01033ee:	f0 
f01033ef:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01033f6:	f0 
f01033f7:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f01033fe:	00 
f01033ff:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103406:	e8 7a cc ff ff       	call   f0100085 <_panic>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f010340b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103411:	81 fb 00 f0 ff ff    	cmp    $0xfffff000,%ebx
f0103417:	75 c1                	jne    f01033da <mem_init+0xbc5>
f0103419:	c7 45 e0 00 00 bf ef 	movl   $0xefbf0000,-0x20(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103420:	89 f7                	mov    %esi,%edi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check IO mem (new in lab 4)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
f0103422:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103425:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103428:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010342b:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103431:	89 c6                	mov    %eax,%esi
f0103433:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0103439:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010343c:	81 c1 00 00 01 00    	add    $0x10000,%ecx
f0103442:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103445:	89 da                	mov    %ebx,%edx
f0103447:	89 f8                	mov    %edi,%eax
f0103449:	e8 0c da ff ff       	call   f0100e5a <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010344e:	81 7d dc ff ff ff ef 	cmpl   $0xefffffff,-0x24(%ebp)
f0103455:	77 23                	ja     f010347a <mem_init+0xc65>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103457:	8b 7d d8             	mov    -0x28(%ebp),%edi
f010345a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010345e:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0103465:	f0 
f0103466:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f010346d:	00 
f010346e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103475:	e8 0b cc ff ff       	call   f0100085 <_panic>
f010347a:	39 f0                	cmp    %esi,%eax
f010347c:	74 24                	je     f01034a2 <mem_init+0xc8d>
f010347e:	c7 44 24 0c 78 8b 10 	movl   $0xf0108b78,0xc(%esp)
f0103485:	f0 
f0103486:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010348d:	f0 
f010348e:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0103495:	00 
f0103496:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010349d:	e8 e3 cb ff ff       	call   f0100085 <_panic>
f01034a2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034a8:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01034ae:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f01034b1:	0f 85 a9 05 00 00    	jne    f0103a60 <mem_init+0x124b>
f01034b7:	bb 00 00 00 00       	mov    $0x0,%ebx
f01034bc:	8b 75 e0             	mov    -0x20(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01034bf:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01034c2:	89 f8                	mov    %edi,%eax
f01034c4:	e8 91 d9 ff ff       	call   f0100e5a <check_va2pa>
f01034c9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01034cc:	74 24                	je     f01034f2 <mem_init+0xcdd>
f01034ce:	c7 44 24 0c c0 8b 10 	movl   $0xf0108bc0,0xc(%esp)
f01034d5:	f0 
f01034d6:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01034dd:	f0 
f01034de:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f01034e5:	00 
f01034e6:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01034ed:	e8 93 cb ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01034f2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034f8:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f01034fe:	75 bf                	jne    f01034bf <mem_init+0xcaa>
f0103500:	81 6d e0 00 00 01 00 	subl   $0x10000,-0x20(%ebp)
f0103507:	81 45 dc 00 80 00 00 	addl   $0x8000,-0x24(%ebp)
	for (i = IOMEMBASE; i < -PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f010350e:	81 7d e0 00 00 b7 ef 	cmpl   $0xefb70000,-0x20(%ebp)
f0103515:	0f 85 07 ff ff ff    	jne    f0103422 <mem_init+0xc0d>
f010351b:	89 fe                	mov    %edi,%esi
f010351d:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103522:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103528:	83 fa 03             	cmp    $0x3,%edx
f010352b:	77 2e                	ja     f010355b <mem_init+0xd46>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f010352d:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0103531:	0f 85 aa 00 00 00    	jne    f01035e1 <mem_init+0xdcc>
f0103537:	c7 44 24 0c 15 90 10 	movl   $0xf0109015,0xc(%esp)
f010353e:	f0 
f010353f:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103546:	f0 
f0103547:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f010354e:	00 
f010354f:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103556:	e8 2a cb ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010355b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103560:	76 55                	jbe    f01035b7 <mem_init+0xda2>
				assert(pgdir[i] & PTE_P);
f0103562:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0103565:	f6 c2 01             	test   $0x1,%dl
f0103568:	75 24                	jne    f010358e <mem_init+0xd79>
f010356a:	c7 44 24 0c 15 90 10 	movl   $0xf0109015,0xc(%esp)
f0103571:	f0 
f0103572:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103579:	f0 
f010357a:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f0103581:	00 
f0103582:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103589:	e8 f7 ca ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f010358e:	f6 c2 02             	test   $0x2,%dl
f0103591:	75 4e                	jne    f01035e1 <mem_init+0xdcc>
f0103593:	c7 44 24 0c 26 90 10 	movl   $0xf0109026,0xc(%esp)
f010359a:	f0 
f010359b:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01035a2:	f0 
f01035a3:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f01035aa:	00 
f01035ab:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01035b2:	e8 ce ca ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f01035b7:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01035bb:	74 24                	je     f01035e1 <mem_init+0xdcc>
f01035bd:	c7 44 24 0c 37 90 10 	movl   $0xf0109037,0xc(%esp)
f01035c4:	f0 
f01035c5:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01035cc:	f0 
f01035cd:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f01035d4:	00 
f01035d5:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01035dc:	e8 a4 ca ff ff       	call   f0100085 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01035e1:	83 c0 01             	add    $0x1,%eax
f01035e4:	3d 00 04 00 00       	cmp    $0x400,%eax
f01035e9:	0f 85 33 ff ff ff    	jne    f0103522 <mem_init+0xd0d>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01035ef:	c7 04 24 e4 8b 10 f0 	movl   $0xf0108be4,(%esp)
f01035f6:	e8 50 0e 00 00       	call   f010444b <cprintf>
	cprintf("SMP-related memory map\n");
	mem_init_mp();

	// Check that the initial page directory has been set up correctly.
	check_kern_pgdir();
	cprintf("finish all check\n");
f01035fb:	c7 04 24 45 90 10 f0 	movl   $0xf0109045,(%esp)
f0103602:	e8 44 0e 00 00       	call   f010444b <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0103607:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010360c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103611:	77 20                	ja     f0103633 <mem_init+0xe1e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103613:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103617:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f010361e:	f0 
f010361f:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f0103626:	00 
f0103627:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f010362e:	e8 52 ca ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103633:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103639:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010363c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103641:	e8 ac d8 ff ff       	call   f0100ef2 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0103646:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0103649:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010364e:	83 e0 f3             	and    $0xfffffff3,%eax
f0103651:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0103654:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010365b:	e8 4e e0 ff ff       	call   f01016ae <page_alloc>
f0103660:	89 c3                	mov    %eax,%ebx
f0103662:	85 c0                	test   %eax,%eax
f0103664:	75 24                	jne    f010368a <mem_init+0xe75>
f0103666:	c7 44 24 0c 74 8d 10 	movl   $0xf0108d74,0xc(%esp)
f010366d:	f0 
f010366e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103675:	f0 
f0103676:	c7 44 24 04 05 05 00 	movl   $0x505,0x4(%esp)
f010367d:	00 
f010367e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103685:	e8 fb c9 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f010368a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103691:	e8 18 e0 ff ff       	call   f01016ae <page_alloc>
f0103696:	89 c7                	mov    %eax,%edi
f0103698:	85 c0                	test   %eax,%eax
f010369a:	75 24                	jne    f01036c0 <mem_init+0xeab>
f010369c:	c7 44 24 0c 8a 8d 10 	movl   $0xf0108d8a,0xc(%esp)
f01036a3:	f0 
f01036a4:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01036ab:	f0 
f01036ac:	c7 44 24 04 06 05 00 	movl   $0x506,0x4(%esp)
f01036b3:	00 
f01036b4:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01036bb:	e8 c5 c9 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f01036c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01036c7:	e8 e2 df ff ff       	call   f01016ae <page_alloc>
f01036cc:	89 c6                	mov    %eax,%esi
f01036ce:	85 c0                	test   %eax,%eax
f01036d0:	75 24                	jne    f01036f6 <mem_init+0xee1>
f01036d2:	c7 44 24 0c a0 8d 10 	movl   $0xf0108da0,0xc(%esp)
f01036d9:	f0 
f01036da:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01036e1:	f0 
f01036e2:	c7 44 24 04 07 05 00 	movl   $0x507,0x4(%esp)
f01036e9:	00 
f01036ea:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01036f1:	e8 8f c9 ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f01036f6:	89 1c 24             	mov    %ebx,(%esp)
f01036f9:	e8 99 d6 ff ff       	call   f0100d97 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01036fe:	89 f8                	mov    %edi,%eax
f0103700:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f0103706:	c1 f8 03             	sar    $0x3,%eax
f0103709:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010370c:	89 c2                	mov    %eax,%edx
f010370e:	c1 ea 0c             	shr    $0xc,%edx
f0103711:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0103717:	72 20                	jb     f0103739 <mem_init+0xf24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103719:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010371d:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0103724:	f0 
f0103725:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010372c:	00 
f010372d:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0103734:	e8 4c c9 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103739:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103740:	00 
f0103741:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103748:	00 
f0103749:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010374e:	89 04 24             	mov    %eax,(%esp)
f0103751:	e8 10 32 00 00       	call   f0106966 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103756:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0103759:	89 f0                	mov    %esi,%eax
f010375b:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f0103761:	c1 f8 03             	sar    $0x3,%eax
f0103764:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103767:	89 c2                	mov    %eax,%edx
f0103769:	c1 ea 0c             	shr    $0xc,%edx
f010376c:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f0103772:	72 20                	jb     f0103794 <mem_init+0xf7f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103774:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103778:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f010377f:	f0 
f0103780:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0103787:	00 
f0103788:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f010378f:	e8 f1 c8 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103794:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010379b:	00 
f010379c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01037a3:	00 
f01037a4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01037a9:	89 04 24             	mov    %eax,(%esp)
f01037ac:	e8 b5 31 00 00       	call   f0106966 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01037b1:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01037b8:	00 
f01037b9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01037c0:	00 
f01037c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01037c5:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f01037ca:	89 04 24             	mov    %eax,(%esp)
f01037cd:	e8 25 e2 ff ff       	call   f01019f7 <page_insert>
	assert(pp1->pp_ref == 1);
f01037d2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01037d7:	74 24                	je     f01037fd <mem_init+0xfe8>
f01037d9:	c7 44 24 0c d7 8d 10 	movl   $0xf0108dd7,0xc(%esp)
f01037e0:	f0 
f01037e1:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01037e8:	f0 
f01037e9:	c7 44 24 04 0c 05 00 	movl   $0x50c,0x4(%esp)
f01037f0:	00 
f01037f1:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01037f8:	e8 88 c8 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01037fd:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103804:	01 01 01 
f0103807:	74 24                	je     f010382d <mem_init+0x1018>
f0103809:	c7 44 24 0c 04 8c 10 	movl   $0xf0108c04,0xc(%esp)
f0103810:	f0 
f0103811:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103818:	f0 
f0103819:	c7 44 24 04 0d 05 00 	movl   $0x50d,0x4(%esp)
f0103820:	00 
f0103821:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103828:	e8 58 c8 ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010382d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103834:	00 
f0103835:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010383c:	00 
f010383d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103841:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0103846:	89 04 24             	mov    %eax,(%esp)
f0103849:	e8 a9 e1 ff ff       	call   f01019f7 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010384e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0103855:	02 02 02 
f0103858:	74 24                	je     f010387e <mem_init+0x1069>
f010385a:	c7 44 24 0c 28 8c 10 	movl   $0xf0108c28,0xc(%esp)
f0103861:	f0 
f0103862:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103869:	f0 
f010386a:	c7 44 24 04 0f 05 00 	movl   $0x50f,0x4(%esp)
f0103871:	00 
f0103872:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103879:	e8 07 c8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010387e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103883:	74 24                	je     f01038a9 <mem_init+0x1094>
f0103885:	c7 44 24 0c f9 8d 10 	movl   $0xf0108df9,0xc(%esp)
f010388c:	f0 
f010388d:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103894:	f0 
f0103895:	c7 44 24 04 10 05 00 	movl   $0x510,0x4(%esp)
f010389c:	00 
f010389d:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01038a4:	e8 dc c7 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f01038a9:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01038ae:	74 24                	je     f01038d4 <mem_init+0x10bf>
f01038b0:	c7 44 24 0c 42 8e 10 	movl   $0xf0108e42,0xc(%esp)
f01038b7:	f0 
f01038b8:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01038bf:	f0 
f01038c0:	c7 44 24 04 11 05 00 	movl   $0x511,0x4(%esp)
f01038c7:	00 
f01038c8:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01038cf:	e8 b1 c7 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01038d4:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01038db:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f01038de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038e1:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f01038e7:	c1 f8 03             	sar    $0x3,%eax
f01038ea:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038ed:	89 c2                	mov    %eax,%edx
f01038ef:	c1 ea 0c             	shr    $0xc,%edx
f01038f2:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f01038f8:	72 20                	jb     f010391a <mem_init+0x1105>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01038fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038fe:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0103905:	f0 
f0103906:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010390d:	00 
f010390e:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0103915:	e8 6b c7 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010391a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103921:	03 03 03 
f0103924:	74 24                	je     f010394a <mem_init+0x1135>
f0103926:	c7 44 24 0c 4c 8c 10 	movl   $0xf0108c4c,0xc(%esp)
f010392d:	f0 
f010392e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103935:	f0 
f0103936:	c7 44 24 04 13 05 00 	movl   $0x513,0x4(%esp)
f010393d:	00 
f010393e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103945:	e8 3b c7 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010394a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103951:	00 
f0103952:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0103957:	89 04 24             	mov    %eax,(%esp)
f010395a:	e8 48 e0 ff ff       	call   f01019a7 <page_remove>
	assert(pp2->pp_ref == 0);
f010395f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0103964:	74 24                	je     f010398a <mem_init+0x1175>
f0103966:	c7 44 24 0c 31 8e 10 	movl   $0xf0108e31,0xc(%esp)
f010396d:	f0 
f010396e:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0103975:	f0 
f0103976:	c7 44 24 04 15 05 00 	movl   $0x515,0x4(%esp)
f010397d:	00 
f010397e:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f0103985:	e8 fb c6 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010398a:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f010398f:	8b 08                	mov    (%eax),%ecx
f0103991:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0103997:	89 da                	mov    %ebx,%edx
f0103999:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f010399f:	c1 fa 03             	sar    $0x3,%edx
f01039a2:	c1 e2 0c             	shl    $0xc,%edx
f01039a5:	39 d1                	cmp    %edx,%ecx
f01039a7:	74 24                	je     f01039cd <mem_init+0x11b8>
f01039a9:	c7 44 24 0c 58 87 10 	movl   $0xf0108758,0xc(%esp)
f01039b0:	f0 
f01039b1:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01039b8:	f0 
f01039b9:	c7 44 24 04 18 05 00 	movl   $0x518,0x4(%esp)
f01039c0:	00 
f01039c1:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01039c8:	e8 b8 c6 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f01039cd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01039d3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01039d8:	74 24                	je     f01039fe <mem_init+0x11e9>
f01039da:	c7 44 24 0c e8 8d 10 	movl   $0xf0108de8,0xc(%esp)
f01039e1:	f0 
f01039e2:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01039e9:	f0 
f01039ea:	c7 44 24 04 1a 05 00 	movl   $0x51a,0x4(%esp)
f01039f1:	00 
f01039f2:	c7 04 24 a1 8c 10 f0 	movl   $0xf0108ca1,(%esp)
f01039f9:	e8 87 c6 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f01039fe:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0103a04:	89 1c 24             	mov    %ebx,(%esp)
f0103a07:	e8 8b d3 ff ff       	call   f0100d97 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103a0c:	c7 04 24 78 8c 10 f0 	movl   $0xf0108c78,(%esp)
f0103a13:	e8 33 0a 00 00       	call   f010444b <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103a18:	83 c4 3c             	add    $0x3c,%esp
f0103a1b:	5b                   	pop    %ebx
f0103a1c:	5e                   	pop    %esi
f0103a1d:	5f                   	pop    %edi
f0103a1e:	5d                   	pop    %ebp
f0103a1f:	c3                   	ret    
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	for (i = 0; i < NCPU; i++) {
		boot_map_region(kern_pgdir,
f0103a20:	c7 44 24 10 03 00 00 	movl   $0x3,0x10(%esp)
f0103a27:	00 
f0103a28:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a2b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103a30:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a34:	c7 44 24 08 00 80 00 	movl   $0x8000,0x8(%esp)
f0103a3b:	00 
f0103a3c:	c7 44 24 04 00 80 bf 	movl   $0xefbf8000,0x4(%esp)
f0103a43:	ef 
f0103a44:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0103a49:	89 04 24             	mov    %eax,(%esp)
f0103a4c:	e8 46 e0 ff ff       	call   f0101a97 <boot_map_region>
f0103a51:	bb 00 10 28 f0       	mov    $0xf0281000,%ebx
f0103a56:	be 00 80 be ef       	mov    $0xefbe8000,%esi
f0103a5b:	e9 a4 f7 ff ff       	jmp    f0103204 <mem_init+0x9ef>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103a60:	89 da                	mov    %ebx,%edx
f0103a62:	89 f8                	mov    %edi,%eax
f0103a64:	e8 f1 d3 ff ff       	call   f0100e5a <check_va2pa>
f0103a69:	e9 0c fa ff ff       	jmp    f010347a <mem_init+0xc65>
	...

f0103a70 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103a70:	55                   	push   %ebp
f0103a71:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103a73:	b8 68 53 12 f0       	mov    $0xf0125368,%eax
f0103a78:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0103a7b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103a80:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103a82:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103a84:	b0 10                	mov    $0x10,%al
f0103a86:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103a88:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0103a8a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0103a8c:	ea 93 3a 10 f0 08 00 	ljmp   $0x8,$0xf0103a93
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0103a93:	b0 00                	mov    $0x0,%al
f0103a95:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103a98:	5d                   	pop    %ebp
f0103a99:	c3                   	ret    

f0103a9a <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103a9a:	55                   	push   %ebp
f0103a9b:	89 e5                	mov    %esp,%ebp
f0103a9d:	b8 84 ef 01 00       	mov    $0x1ef84,%eax
f0103aa2:	ba 00 00 00 00       	mov    $0x0,%edx
	int i;
	env_free_list = NULL;
	
	for(i = NENV-1;i>=0;i--)
	{
		envs[i].env_id = 0;
f0103aa7:	8b 0d 40 52 27 f0    	mov    0xf0275240,%ecx
f0103aad:	c7 44 01 48 00 00 00 	movl   $0x0,0x48(%ecx,%eax,1)
f0103ab4:	00 
		envs[i].env_status = ENV_FREE;
f0103ab5:	8b 0d 40 52 27 f0    	mov    0xf0275240,%ecx
f0103abb:	c7 44 01 54 00 00 00 	movl   $0x0,0x54(%ecx,%eax,1)
f0103ac2:	00 
		envs[i].env_link = env_free_list;
f0103ac3:	8b 0d 40 52 27 f0    	mov    0xf0275240,%ecx
f0103ac9:	89 54 01 44          	mov    %edx,0x44(%ecx,%eax,1)
		env_free_list = &envs[i];
f0103acd:	89 c2                	mov    %eax,%edx
f0103acf:	03 15 40 52 27 f0    	add    0xf0275240,%edx
f0103ad5:	83 e8 7c             	sub    $0x7c,%eax
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	
	for(i = NENV-1;i>=0;i--)
f0103ad8:	83 f8 84             	cmp    $0xffffff84,%eax
f0103adb:	75 ca                	jne    f0103aa7 <env_init+0xd>
f0103add:	89 15 44 52 27 f0    	mov    %edx,0xf0275244
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	
	// Per-CPU part of the initialization
	env_init_percpu();
f0103ae3:	e8 88 ff ff ff       	call   f0103a70 <env_init_percpu>
}
f0103ae8:	5d                   	pop    %ebp
f0103ae9:	c3                   	ret    

f0103aea <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103aea:	55                   	push   %ebp
f0103aeb:	89 e5                	mov    %esp,%ebp
f0103aed:	83 ec 18             	sub    $0x18,%esp
f0103af0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103af3:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103af6:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103af9:	8b 45 08             	mov    0x8(%ebp),%eax
f0103afc:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103aff:	85 c0                	test   %eax,%eax
f0103b01:	75 17                	jne    f0103b1a <envid2env+0x30>
		*env_store = curenv;
f0103b03:	e8 0a 35 00 00       	call   f0107012 <cpunum>
f0103b08:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b0b:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0103b11:	89 06                	mov    %eax,(%esi)
f0103b13:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f0103b18:	eb 69                	jmp    f0103b83 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103b1a:	89 c3                	mov    %eax,%ebx
f0103b1c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103b22:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103b25:	03 1d 40 52 27 f0    	add    0xf0275240,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103b2b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103b2f:	74 05                	je     f0103b36 <envid2env+0x4c>
f0103b31:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103b34:	74 0d                	je     f0103b43 <envid2env+0x59>
		*env_store = 0;
f0103b36:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0103b3c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103b41:	eb 40                	jmp    f0103b83 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103b43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0103b47:	74 33                	je     f0103b7c <envid2env+0x92>
f0103b49:	e8 c4 34 00 00       	call   f0107012 <cpunum>
f0103b4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b51:	39 98 28 80 27 f0    	cmp    %ebx,-0xfd87fd8(%eax)
f0103b57:	74 23                	je     f0103b7c <envid2env+0x92>
f0103b59:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103b5c:	e8 b1 34 00 00       	call   f0107012 <cpunum>
f0103b61:	6b c0 74             	imul   $0x74,%eax,%eax
f0103b64:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0103b6a:	3b 78 48             	cmp    0x48(%eax),%edi
f0103b6d:	74 0d                	je     f0103b7c <envid2env+0x92>
		*env_store = 0;
f0103b6f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0103b75:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103b7a:	eb 07                	jmp    f0103b83 <envid2env+0x99>
	}

	*env_store = e;
f0103b7c:	89 1e                	mov    %ebx,(%esi)
f0103b7e:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f0103b83:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0103b86:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0103b89:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0103b8c:	89 ec                	mov    %ebp,%esp
f0103b8e:	5d                   	pop    %ebp
f0103b8f:	c3                   	ret    

f0103b90 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103b90:	55                   	push   %ebp
f0103b91:	89 e5                	mov    %esp,%ebp
f0103b93:	83 ec 38             	sub    $0x38,%esp
f0103b96:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103b99:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103b9c:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103b9f:	8b 75 08             	mov    0x8(%ebp),%esi
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103ba2:	e8 6b 34 00 00       	call   f0107012 <cpunum>
f0103ba7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103baa:	8b 98 28 80 27 f0    	mov    -0xfd87fd8(%eax),%ebx
f0103bb0:	e8 5d 34 00 00       	call   f0107012 <cpunum>
f0103bb5:	89 43 5c             	mov    %eax,0x5c(%ebx)
	//cprintf("%s:env_pop_tf[%d]: [%x] to run\n", __FILE__, __LINE__, curenv->env_id);
	if(tf->tf_trapno == T_SYSCALL)	
f0103bb8:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f0103bbc:	75 60                	jne    f0103c1e <env_pop_tf+0x8e>
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103bbe:	c7 04 24 80 53 12 f0 	movl   $0xf0125380,(%esp)
f0103bc5:	e8 f2 36 00 00       	call   f01072bc <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103bca:	f3 90                	pause  
		//cprintf("%s:env_pop_tf[%d]: sysexit [%x] with  %x\n", __FILE__, __LINE__, curenv->env_id,curenv->env_tf.tf_regs.reg_eax);
		asm volatile(
			"sti\n\t"
			"sysexit\n\t"
			:
			:"c" (curenv->env_tf.tf_regs.reg_ecx),
f0103bcc:	e8 41 34 00 00       	call   f0107012 <cpunum>
f0103bd1:	bb 20 80 27 f0       	mov    $0xf0278020,%ebx
f0103bd6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bd9:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103bdd:	8b 40 18             	mov    0x18(%eax),%eax
f0103be0:	89 45 e0             	mov    %eax,-0x20(%ebp)
			 "d" (curenv->env_tf.tf_regs.reg_edx),
f0103be3:	e8 2a 34 00 00       	call   f0107012 <cpunum>
f0103be8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103beb:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103bef:	8b 40 14             	mov    0x14(%eax),%eax
f0103bf2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			 "a" (curenv->env_tf.tf_regs.reg_eax),
f0103bf5:	e8 18 34 00 00       	call   f0107012 <cpunum>
f0103bfa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bfd:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103c01:	8b 78 1c             	mov    0x1c(%eax),%edi
			 "b" (curenv->env_tf.tf_eflags)
f0103c04:	e8 09 34 00 00       	call   f0107012 <cpunum>
	if(tf->tf_trapno == T_SYSCALL)	
	{
		unlock_kernel();
		//print_trapframe(tf);
		//cprintf("%s:env_pop_tf[%d]: sysexit [%x] with  %x\n", __FILE__, __LINE__, curenv->env_id,curenv->env_tf.tf_regs.reg_eax);
		asm volatile(
f0103c09:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c0c:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103c10:	8b 58 38             	mov    0x38(%eax),%ebx
f0103c13:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103c19:	89 f8                	mov    %edi,%eax
f0103c1b:	fb                   	sti    
f0103c1c:	0f 35                	sysexit 
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103c1e:	c7 04 24 80 53 12 f0 	movl   $0xf0125380,(%esp)
f0103c25:	e8 92 36 00 00       	call   f01072bc <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103c2a:	f3 90                	pause  
			);
	}
	unlock_kernel();
	//cprintf("%s:env_pop_tf[%d]: iret [%x] with IF %x[%x]\n", __FILE__, __LINE__, curenv->env_id, curenv->env_tf.tf_eflags & FL_IF, read_eflags()& FL_IF);
	/* cprintf("%x not syscall\t%d\n",curenv->env_id,curenv->env_type); */
	__asm __volatile("movl %0,%%esp\n"
f0103c2c:	89 f4                	mov    %esi,%esp
f0103c2e:	61                   	popa   
f0103c2f:	07                   	pop    %es
f0103c30:	1f                   	pop    %ds
f0103c31:	83 c4 08             	add    $0x8,%esp
f0103c34:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103c35:	c7 44 24 08 57 90 10 	movl   $0xf0109057,0x8(%esp)
f0103c3c:	f0 
f0103c3d:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0103c44:	00 
f0103c45:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f0103c4c:	e8 34 c4 ff ff       	call   f0100085 <_panic>

f0103c51 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c51:	55                   	push   %ebp
f0103c52:	89 e5                	mov    %esp,%ebp
f0103c54:	53                   	push   %ebx
f0103c55:	83 ec 14             	sub    $0x14,%esp
f0103c58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	/* cprintf("go for run\n"); */
	if(curenv != e)
f0103c5b:	e8 b2 33 00 00       	call   f0107012 <cpunum>
f0103c60:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c63:	39 98 28 80 27 f0    	cmp    %ebx,-0xfd87fd8(%eax)
f0103c69:	0f 84 88 00 00 00    	je     f0103cf7 <env_run+0xa6>
	{
		if(curenv)
f0103c6f:	e8 9e 33 00 00       	call   f0107012 <cpunum>
f0103c74:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c77:	83 b8 28 80 27 f0 00 	cmpl   $0x0,-0xfd87fd8(%eax)
f0103c7e:	74 29                	je     f0103ca9 <env_run+0x58>
			if (curenv->env_status == ENV_RUNNING)
f0103c80:	e8 8d 33 00 00       	call   f0107012 <cpunum>
f0103c85:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c88:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0103c8e:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c92:	75 15                	jne    f0103ca9 <env_run+0x58>
				curenv->env_status = ENV_RUNNABLE;
f0103c94:	e8 79 33 00 00       	call   f0107012 <cpunum>
f0103c99:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c9c:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0103ca2:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		curenv = e;
f0103ca9:	e8 64 33 00 00       	call   f0107012 <cpunum>
f0103cae:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cb1:	89 98 28 80 27 f0    	mov    %ebx,-0xfd87fd8(%eax)
		e->env_status = ENV_RUNNING;
f0103cb7:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
		e->env_runs++;
f0103cbe:	83 43 58 01          	addl   $0x1,0x58(%ebx)
		lcr3(PADDR(e->env_pgdir));	
f0103cc2:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cc5:	89 c2                	mov    %eax,%edx
f0103cc7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ccc:	77 20                	ja     f0103cee <env_run+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103cce:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cd2:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0103cd9:	f0 
f0103cda:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
f0103ce1:	00 
f0103ce2:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f0103ce9:	e8 97 c3 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103cee:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103cf4:	0f 22 da             	mov    %edx,%cr3
	}
	//cprintf("%s:env_run[%d]: [%x] to run with IF %x[%x]\n", __FILE__, __LINE__, curenv->env_id, curenv->env_tf.tf_eflags & FL_IF, read_eflags() & FL_IF);
	env_pop_tf(&e->env_tf);
f0103cf7:	89 1c 24             	mov    %ebx,(%esp)
f0103cfa:	e8 91 fe ff ff       	call   f0103b90 <env_pop_tf>

f0103cff <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103cff:	55                   	push   %ebp
f0103d00:	89 e5                	mov    %esp,%ebp
f0103d02:	57                   	push   %edi
f0103d03:	56                   	push   %esi
f0103d04:	53                   	push   %ebx
f0103d05:	83 ec 2c             	sub    $0x2c,%esp
f0103d08:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103d0b:	e8 02 33 00 00       	call   f0107012 <cpunum>
f0103d10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d13:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103d1a:	39 b8 28 80 27 f0    	cmp    %edi,-0xfd87fd8(%eax)
f0103d20:	75 3c                	jne    f0103d5e <env_free+0x5f>
		lcr3(PADDR(kern_pgdir));
f0103d22:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d2c:	77 20                	ja     f0103d4e <env_free+0x4f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d32:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0103d39:	f0 
f0103d3a:	c7 44 24 04 ac 01 00 	movl   $0x1ac,0x4(%esp)
f0103d41:	00 
f0103d42:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f0103d49:	e8 37 c3 ff ff       	call   f0100085 <_panic>
f0103d4e:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103d54:	0f 22 d8             	mov    %eax,%cr3
f0103d57:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103d5e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103d61:	c1 e0 02             	shl    $0x2,%eax
f0103d64:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103d67:	8b 47 60             	mov    0x60(%edi),%eax
f0103d6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103d6d:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103d70:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103d76:	0f 84 b8 00 00 00    	je     f0103e34 <env_free+0x135>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103d7c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103d82:	89 f0                	mov    %esi,%eax
f0103d84:	c1 e8 0c             	shr    $0xc,%eax
f0103d87:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d8a:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0103d90:	72 20                	jb     f0103db2 <env_free+0xb3>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103d92:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103d96:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0103d9d:	f0 
f0103d9e:	c7 44 24 04 bb 01 00 	movl   $0x1bb,0x4(%esp)
f0103da5:	00 
f0103da6:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f0103dad:	e8 d3 c2 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103db2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103db5:	c1 e2 16             	shl    $0x16,%edx
f0103db8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103dbb:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f0103dc0:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103dc7:	01 
f0103dc8:	74 17                	je     f0103de1 <env_free+0xe2>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103dca:	89 d8                	mov    %ebx,%eax
f0103dcc:	c1 e0 0c             	shl    $0xc,%eax
f0103dcf:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103dd6:	8b 47 60             	mov    0x60(%edi),%eax
f0103dd9:	89 04 24             	mov    %eax,(%esp)
f0103ddc:	e8 c6 db ff ff       	call   f01019a7 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103de1:	83 c3 01             	add    $0x1,%ebx
f0103de4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103dea:	75 d4                	jne    f0103dc0 <env_free+0xc1>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103dec:	8b 47 60             	mov    0x60(%edi),%eax
f0103def:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103df2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103df9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103dfc:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0103e02:	72 1c                	jb     f0103e20 <env_free+0x121>
		panic("pa2page called with invalid pa");
f0103e04:	c7 44 24 08 48 86 10 	movl   $0xf0108648,0x8(%esp)
f0103e0b:	f0 
f0103e0c:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0103e13:	00 
f0103e14:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0103e1b:	e8 65 c2 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0103e20:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103e23:	c1 e0 03             	shl    $0x3,%eax
f0103e26:	03 05 9c 5e 27 f0    	add    0xf0275e9c,%eax
f0103e2c:	89 04 24             	mov    %eax,(%esp)
f0103e2f:	e8 ce cf ff ff       	call   f0100e02 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103e34:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103e38:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103e3f:	0f 85 19 ff ff ff    	jne    f0103d5e <env_free+0x5f>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103e45:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103e48:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103e4d:	77 20                	ja     f0103e6f <env_free+0x170>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103e4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e53:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0103e5a:	f0 
f0103e5b:	c7 44 24 04 c9 01 00 	movl   $0x1c9,0x4(%esp)
f0103e62:	00 
f0103e63:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f0103e6a:	e8 16 c2 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0103e6f:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103e76:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103e7c:	c1 e8 0c             	shr    $0xc,%eax
f0103e7f:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0103e85:	72 1c                	jb     f0103ea3 <env_free+0x1a4>
		panic("pa2page called with invalid pa");
f0103e87:	c7 44 24 08 48 86 10 	movl   $0xf0108648,0x8(%esp)
f0103e8e:	f0 
f0103e8f:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0103e96:	00 
f0103e97:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0103e9e:	e8 e2 c1 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f0103ea3:	c1 e0 03             	shl    $0x3,%eax
f0103ea6:	03 05 9c 5e 27 f0    	add    0xf0275e9c,%eax
f0103eac:	89 04 24             	mov    %eax,(%esp)
f0103eaf:	e8 4e cf ff ff       	call   f0100e02 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103eb4:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103ebb:	a1 44 52 27 f0       	mov    0xf0275244,%eax
f0103ec0:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103ec3:	89 3d 44 52 27 f0    	mov    %edi,0xf0275244
}
f0103ec9:	83 c4 2c             	add    $0x2c,%esp
f0103ecc:	5b                   	pop    %ebx
f0103ecd:	5e                   	pop    %esi
f0103ece:	5f                   	pop    %edi
f0103ecf:	5d                   	pop    %ebp
f0103ed0:	c3                   	ret    

f0103ed1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103ed1:	55                   	push   %ebp
f0103ed2:	89 e5                	mov    %esp,%ebp
f0103ed4:	53                   	push   %ebx
f0103ed5:	83 ec 14             	sub    $0x14,%esp
f0103ed8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103edb:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103edf:	75 19                	jne    f0103efa <env_destroy+0x29>
f0103ee1:	e8 2c 31 00 00       	call   f0107012 <cpunum>
f0103ee6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ee9:	39 98 28 80 27 f0    	cmp    %ebx,-0xfd87fd8(%eax)
f0103eef:	74 09                	je     f0103efa <env_destroy+0x29>
		e->env_status = ENV_DYING;
f0103ef1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103ef8:	eb 2f                	jmp    f0103f29 <env_destroy+0x58>
	}

	env_free(e);
f0103efa:	89 1c 24             	mov    %ebx,(%esp)
f0103efd:	e8 fd fd ff ff       	call   f0103cff <env_free>

	if (curenv == e) {
f0103f02:	e8 0b 31 00 00       	call   f0107012 <cpunum>
f0103f07:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f0a:	39 98 28 80 27 f0    	cmp    %ebx,-0xfd87fd8(%eax)
f0103f10:	75 17                	jne    f0103f29 <env_destroy+0x58>
		curenv = NULL;
f0103f12:	e8 fb 30 00 00       	call   f0107012 <cpunum>
f0103f17:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f1a:	c7 80 28 80 27 f0 00 	movl   $0x0,-0xfd87fd8(%eax)
f0103f21:	00 00 00 
		sched_yield();
f0103f24:	e8 17 13 00 00       	call   f0105240 <sched_yield>
	}
}
f0103f29:	83 c4 14             	add    $0x14,%esp
f0103f2c:	5b                   	pop    %ebx
f0103f2d:	5d                   	pop    %ebp
f0103f2e:	c3                   	ret    

f0103f2f <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103f2f:	55                   	push   %ebp
f0103f30:	89 e5                	mov    %esp,%ebp
f0103f32:	53                   	push   %ebx
f0103f33:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103f36:	8b 1d 44 52 27 f0    	mov    0xf0275244,%ebx
f0103f3c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103f41:	85 db                	test   %ebx,%ebx
f0103f43:	0f 84 70 01 00 00    	je     f01040b9 <env_alloc+0x18a>
{
	int i;
	struct Page *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103f50:	e8 59 d7 ff ff       	call   f01016ae <page_alloc>
f0103f55:	89 c2                	mov    %eax,%edx
f0103f57:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0103f5c:	85 d2                	test   %edx,%edx
f0103f5e:	0f 84 55 01 00 00    	je     f01040b9 <env_alloc+0x18a>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0103f64:	2b 15 9c 5e 27 f0    	sub    0xf0275e9c,%edx
f0103f6a:	c1 fa 03             	sar    $0x3,%edx
f0103f6d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103f70:	89 d0                	mov    %edx,%eax
f0103f72:	c1 e8 0c             	shr    $0xc,%eax
f0103f75:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0103f7b:	72 20                	jb     f0103f9d <env_alloc+0x6e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103f7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103f81:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0103f88:	f0 
f0103f89:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0103f90:	00 
f0103f91:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0103f98:	e8 e8 c0 ff ff       	call   f0100085 <_panic>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	e->env_pgdir = page2kva(p);
f0103f9d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103fa3:	89 53 60             	mov    %edx,0x60(%ebx)
	
	memset(e->env_pgdir,0,PGSIZE);
f0103fa6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103fad:	00 
f0103fae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103fb5:	00 
f0103fb6:	89 14 24             	mov    %edx,(%esp)
f0103fb9:	e8 a8 29 00 00       	call   f0106966 <memset>
	memmove(e->env_pgdir,kern_pgdir,PGSIZE);
f0103fbe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103fc5:	00 
f0103fc6:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0103fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fcf:	8b 43 60             	mov    0x60(%ebx),%eax
f0103fd2:	89 04 24             	mov    %eax,(%esp)
f0103fd5:	e8 eb 29 00 00       	call   f01069c5 <memmove>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103fda:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103fdd:	89 c2                	mov    %eax,%edx
f0103fdf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103fe4:	77 20                	ja     f0104006 <env_alloc+0xd7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103fe6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103fea:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f0103ff1:	f0 
f0103ff2:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f0103ff9:	00 
f0103ffa:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f0104001:	e8 7f c0 ff ff       	call   f0100085 <_panic>
f0104006:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010400c:	83 ca 05             	or     $0x5,%edx
f010400f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0104015:	8b 43 48             	mov    0x48(%ebx),%eax
f0104018:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010401d:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0104022:	ba 00 10 00 00       	mov    $0x1000,%edx
f0104027:	0f 4e c2             	cmovle %edx,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f010402a:	89 da                	mov    %ebx,%edx
f010402c:	2b 15 40 52 27 f0    	sub    0xf0275240,%edx
f0104032:	c1 fa 02             	sar    $0x2,%edx
f0104035:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f010403b:	09 d0                	or     %edx,%eax
f010403d:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0104040:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104043:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0104046:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010404d:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0104054:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010405b:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104062:	00 
f0104063:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010406a:	00 
f010406b:	89 1c 24             	mov    %ebx,(%esp)
f010406e:	e8 f3 28 00 00       	call   f0106966 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0104073:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0104079:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010407f:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0104085:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010408c:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0104092:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0104099:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01040a0:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01040a7:	8b 43 44             	mov    0x44(%ebx),%eax
f01040aa:	a3 44 52 27 f0       	mov    %eax,0xf0275244
	*newenv_store = e;
f01040af:	8b 45 08             	mov    0x8(%ebp),%eax
f01040b2:	89 18                	mov    %ebx,(%eax)
f01040b4:	b8 00 00 00 00       	mov    $0x0,%eax

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01040b9:	83 c4 14             	add    $0x14,%esp
f01040bc:	5b                   	pop    %ebx
f01040bd:	5d                   	pop    %ebp
f01040be:	c3                   	ret    

f01040bf <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f01040bf:	55                   	push   %ebp
f01040c0:	89 e5                	mov    %esp,%ebp
f01040c2:	57                   	push   %edi
f01040c3:	56                   	push   %esi
f01040c4:	53                   	push   %ebx
f01040c5:	83 ec 1c             	sub    $0x1c,%esp
f01040c8:	89 c6                	mov    %eax,%esi
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	va = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE);
f01040ca:	8d b9 ff 0f 00 00    	lea    0xfff(%ecx),%edi
	
	struct Page *pp;
	int i;
	for(;len > 0;len -= PGSIZE, va += PGSIZE)
f01040d0:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01040d6:	0f 84 83 00 00 00    	je     f010415f <region_alloc+0xa0>
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	va = ROUNDDOWN(va,PGSIZE);
f01040dc:	89 d3                	mov    %edx,%ebx
f01040de:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	
	struct Page *pp;
	int i;
	for(;len > 0;len -= PGSIZE, va += PGSIZE)
	{
		pp = page_alloc(0);
f01040e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01040eb:	e8 be d5 ff ff       	call   f01016ae <page_alloc>
		if(pp == NULL)
f01040f0:	85 c0                	test   %eax,%eax
f01040f2:	75 1c                	jne    f0104110 <region_alloc+0x51>
			panic ("region_alloc: page_alloc failed%e");
f01040f4:	c7 44 24 08 a4 90 10 	movl   $0xf01090a4,0x8(%esp)
f01040fb:	f0 
f01040fc:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f0104103:	00 
f0104104:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f010410b:	e8 75 bf ff ff       	call   f0100085 <_panic>
		if((i = page_insert(e->env_pgdir,pp,va,PTE_U | PTE_W)))
f0104110:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104117:	00 
f0104118:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010411c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104120:	8b 46 60             	mov    0x60(%esi),%eax
f0104123:	89 04 24             	mov    %eax,(%esp)
f0104126:	e8 cc d8 ff ff       	call   f01019f7 <page_insert>
f010412b:	85 c0                	test   %eax,%eax
f010412d:	74 20                	je     f010414f <region_alloc+0x90>
			panic ("region_alloc: page_insert failed%e", i);
f010412f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104133:	c7 44 24 08 c8 90 10 	movl   $0xf01090c8,0x8(%esp)
f010413a:	f0 
f010413b:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
f0104142:	00 
f0104143:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f010414a:	e8 36 bf ff ff       	call   f0100085 <_panic>
	va = ROUNDDOWN(va,PGSIZE);
	len = ROUNDUP(len,PGSIZE);
	
	struct Page *pp;
	int i;
	for(;len > 0;len -= PGSIZE, va += PGSIZE)
f010414f:	81 ef 00 10 00 00    	sub    $0x1000,%edi
f0104155:	74 08                	je     f010415f <region_alloc+0xa0>
f0104157:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010415d:	eb 85                	jmp    f01040e4 <region_alloc+0x25>
			panic ("region_alloc: page_alloc failed%e");
		if((i = page_insert(e->env_pgdir,pp,va,PTE_U | PTE_W)))
			panic ("region_alloc: page_insert failed%e", i);

	}
}
f010415f:	83 c4 1c             	add    $0x1c,%esp
f0104162:	5b                   	pop    %ebx
f0104163:	5e                   	pop    %esi
f0104164:	5f                   	pop    %edi
f0104165:	5d                   	pop    %ebp
f0104166:	c3                   	ret    

f0104167 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0104167:	55                   	push   %ebp
f0104168:	89 e5                	mov    %esp,%ebp
f010416a:	57                   	push   %edi
f010416b:	56                   	push   %esi
f010416c:	53                   	push   %ebx
f010416d:	83 ec 3c             	sub    $0x3c,%esp
f0104170:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	int r;
	struct Env *e;
	if((r = env_alloc(&e,0))<0)
f0104173:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010417a:	00 
f010417b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010417e:	89 04 24             	mov    %eax,(%esp)
f0104181:	e8 a9 fd ff ff       	call   f0103f2f <env_alloc>
f0104186:	85 c0                	test   %eax,%eax
f0104188:	79 20                	jns    f01041aa <env_create+0x43>
		panic("env_create:env_alloc wrong%e",r);
f010418a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010418e:	c7 44 24 08 6e 90 10 	movl   $0xf010906e,0x8(%esp)
f0104195:	f0 
f0104196:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
f010419d:	00 
f010419e:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f01041a5:	e8 db be ff ff       	call   f0100085 <_panic>
	load_icode(e,binary,size);
f01041aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	//  What?  (See env_run() and env_pop_tf() below.)

	// LAB 3: Your code here.
	struct Elf  *hdr;
	struct Proghdr	*ph,*eph;
	hdr = (struct Elf*)binary;
f01041ad:	89 75 d0             	mov    %esi,-0x30(%ebp)
	if(hdr->e_magic != ELF_MAGIC)
f01041b0:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01041b6:	74 1c                	je     f01041d4 <env_create+0x6d>
		panic("load_icode: elf wrong");
f01041b8:	c7 44 24 08 8b 90 10 	movl   $0xf010908b,0x8(%esp)
f01041bf:	f0 
f01041c0:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
f01041c7:	00 
f01041c8:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f01041cf:	e8 b1 be ff ff       	call   f0100085 <_panic>
	ph = (struct Proghdr *) ((uint8_t *) hdr + hdr->e_phoff);
f01041d4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01041d7:	8b 58 1c             	mov    0x1c(%eax),%ebx
	eph = ph + hdr->e_phnum;
f01041da:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
	
	lcr3(PADDR(e->env_pgdir));
f01041de:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01041e1:	89 c1                	mov    %eax,%ecx
f01041e3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01041e8:	77 20                	ja     f010420a <env_create+0xa3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01041ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01041ee:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01041f5:	f0 
f01041f6:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f01041fd:	00 
f01041fe:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f0104205:	e8 7b be ff ff       	call   f0100085 <_panic>
	struct Elf  *hdr;
	struct Proghdr	*ph,*eph;
	hdr = (struct Elf*)binary;
	if(hdr->e_magic != ELF_MAGIC)
		panic("load_icode: elf wrong");
	ph = (struct Proghdr *) ((uint8_t *) hdr + hdr->e_phoff);
f010420a:	03 5d d0             	add    -0x30(%ebp),%ebx
	eph = ph + hdr->e_phnum;
f010420d:	0f b7 d2             	movzwl %dx,%edx
f0104210:	c1 e2 05             	shl    $0x5,%edx
f0104213:	8d 14 13             	lea    (%ebx,%edx,1),%edx
f0104216:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104219:	81 c1 00 00 00 10    	add    $0x10000000,%ecx
f010421f:	0f 22 d9             	mov    %ecx,%cr3
	
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++)
f0104222:	39 d3                	cmp    %edx,%ebx
f0104224:	73 4a                	jae    f0104270 <env_create+0x109>
	{
		region_alloc(e,(void*)ph->p_va,ph->p_memsz);
f0104226:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0104229:	8b 53 08             	mov    0x8(%ebx),%edx
f010422c:	89 f8                	mov    %edi,%eax
f010422e:	e8 8c fe ff ff       	call   f01040bf <region_alloc>
		memset((void*)ph->p_va,0,ph->p_memsz);
f0104233:	8b 43 14             	mov    0x14(%ebx),%eax
f0104236:	89 44 24 08          	mov    %eax,0x8(%esp)
f010423a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0104241:	00 
f0104242:	8b 43 08             	mov    0x8(%ebx),%eax
f0104245:	89 04 24             	mov    %eax,(%esp)
f0104248:	e8 19 27 00 00       	call   f0106966 <memset>
		memmove ((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f010424d:	8b 43 10             	mov    0x10(%ebx),%eax
f0104250:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104254:	89 f0                	mov    %esi,%eax
f0104256:	03 43 04             	add    0x4(%ebx),%eax
f0104259:	89 44 24 04          	mov    %eax,0x4(%esp)
f010425d:	8b 43 08             	mov    0x8(%ebx),%eax
f0104260:	89 04 24             	mov    %eax,(%esp)
f0104263:	e8 5d 27 00 00       	call   f01069c5 <memmove>
		panic("load_icode: elf wrong");
	ph = (struct Proghdr *) ((uint8_t *) hdr + hdr->e_phoff);
	eph = ph + hdr->e_phnum;
	
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++)
f0104268:	83 c3 20             	add    $0x20,%ebx
f010426b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010426e:	77 b6                	ja     f0104226 <env_create+0xbf>
	}
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	e->env_tf.tf_eip = hdr->e_entry;
f0104270:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104273:	8b 42 18             	mov    0x18(%edx),%eax
f0104276:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e,(void*) (USTACKTOP - PGSIZE), PGSIZE);
f0104279:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010427e:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0104283:	89 f8                	mov    %edi,%eax
f0104285:	e8 35 fe ff ff       	call   f01040bf <region_alloc>
	
	lcr3(PADDR(kern_pgdir));
f010428a:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010428f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104294:	77 20                	ja     f01042b6 <env_create+0x14f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104296:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010429a:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01042a1:	f0 
f01042a2:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
f01042a9:	00 
f01042aa:	c7 04 24 63 90 10 f0 	movl   $0xf0109063,(%esp)
f01042b1:	e8 cf bd ff ff       	call   f0100085 <_panic>
f01042b6:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f01042bc:	0f 22 d8             	mov    %eax,%cr3
	int r;
	struct Env *e;
	if((r = env_alloc(&e,0))<0)
		panic("env_create:env_alloc wrong%e",r);
	load_icode(e,binary,size);
	e->env_type = type;
f01042bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042c2:	8b 55 10             	mov    0x10(%ebp),%edx
f01042c5:	89 50 50             	mov    %edx,0x50(%eax)

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
  if (e->env_type == ENV_TYPE_FS)
f01042c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042cb:	83 78 50 02          	cmpl   $0x2,0x50(%eax)
f01042cf:	75 07                	jne    f01042d8 <env_create+0x171>
    e->env_tf.tf_eflags |= FL_IOPL_3;
f01042d1:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
}
f01042d8:	83 c4 3c             	add    $0x3c,%esp
f01042db:	5b                   	pop    %ebx
f01042dc:	5e                   	pop    %esi
f01042dd:	5f                   	pop    %edi
f01042de:	5d                   	pop    %ebp
f01042df:	c3                   	ret    

f01042e0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01042e0:	55                   	push   %ebp
f01042e1:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042e3:	ba 70 00 00 00       	mov    $0x70,%edx
f01042e8:	8b 45 08             	mov    0x8(%ebp),%eax
f01042eb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01042ec:	b2 71                	mov    $0x71,%dl
f01042ee:	ec                   	in     (%dx),%al
f01042ef:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f01042f2:	5d                   	pop    %ebp
f01042f3:	c3                   	ret    

f01042f4 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01042f4:	55                   	push   %ebp
f01042f5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01042f7:	ba 70 00 00 00       	mov    $0x70,%edx
f01042fc:	8b 45 08             	mov    0x8(%ebp),%eax
f01042ff:	ee                   	out    %al,(%dx)
f0104300:	b2 71                	mov    $0x71,%dl
f0104302:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104305:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0104306:	5d                   	pop    %ebp
f0104307:	c3                   	ret    

f0104308 <irq_eoi>:
	cprintf("\n");
}

void
irq_eoi(void)
{
f0104308:	55                   	push   %ebp
f0104309:	89 e5                	mov    %esp,%ebp
f010430b:	ba 20 00 00 00       	mov    $0x20,%edx
f0104310:	b8 20 00 00 00       	mov    $0x20,%eax
f0104315:	ee                   	out    %al,(%dx)
f0104316:	b2 a0                	mov    $0xa0,%dl
f0104318:	ee                   	out    %al,(%dx)
	//   s: specific
	//   e: end-of-interrupt
	// xxx: specific interrupt line
	outb(IO_PIC1, 0x20);
	outb(IO_PIC2, 0x20);
}
f0104319:	5d                   	pop    %ebp
f010431a:	c3                   	ret    

f010431b <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010431b:	55                   	push   %ebp
f010431c:	89 e5                	mov    %esp,%ebp
f010431e:	56                   	push   %esi
f010431f:	53                   	push   %ebx
f0104320:	83 ec 10             	sub    $0x10,%esp
f0104323:	8b 45 08             	mov    0x8(%ebp),%eax
f0104326:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0104328:	66 a3 70 53 12 f0    	mov    %ax,0xf0125370
	if (!didinit)
f010432e:	83 3d 48 52 27 f0 00 	cmpl   $0x0,0xf0275248
f0104335:	74 4e                	je     f0104385 <irq_setmask_8259A+0x6a>
f0104337:	ba 21 00 00 00       	mov    $0x21,%edx
f010433c:	ee                   	out    %al,(%dx)
f010433d:	89 f0                	mov    %esi,%eax
f010433f:	66 c1 e8 08          	shr    $0x8,%ax
f0104343:	b2 a1                	mov    $0xa1,%dl
f0104345:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0104346:	c7 04 24 eb 90 10 f0 	movl   $0xf01090eb,(%esp)
f010434d:	e8 f9 00 00 00       	call   f010444b <cprintf>
f0104352:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0104357:	0f b7 f6             	movzwl %si,%esi
f010435a:	f7 d6                	not    %esi
f010435c:	0f a3 de             	bt     %ebx,%esi
f010435f:	73 10                	jae    f0104371 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0104361:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104365:	c7 04 24 b4 95 10 f0 	movl   $0xf01095b4,(%esp)
f010436c:	e8 da 00 00 00       	call   f010444b <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0104371:	83 c3 01             	add    $0x1,%ebx
f0104374:	83 fb 10             	cmp    $0x10,%ebx
f0104377:	75 e3                	jne    f010435c <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0104379:	c7 04 24 b7 92 10 f0 	movl   $0xf01092b7,(%esp)
f0104380:	e8 c6 00 00 00       	call   f010444b <cprintf>
}
f0104385:	83 c4 10             	add    $0x10,%esp
f0104388:	5b                   	pop    %ebx
f0104389:	5e                   	pop    %esi
f010438a:	5d                   	pop    %ebp
f010438b:	c3                   	ret    

f010438c <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f010438c:	55                   	push   %ebp
f010438d:	89 e5                	mov    %esp,%ebp
f010438f:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0104392:	c7 05 48 52 27 f0 01 	movl   $0x1,0xf0275248
f0104399:	00 00 00 
f010439c:	ba 21 00 00 00       	mov    $0x21,%edx
f01043a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043a6:	ee                   	out    %al,(%dx)
f01043a7:	b2 a1                	mov    $0xa1,%dl
f01043a9:	ee                   	out    %al,(%dx)
f01043aa:	b2 20                	mov    $0x20,%dl
f01043ac:	b8 11 00 00 00       	mov    $0x11,%eax
f01043b1:	ee                   	out    %al,(%dx)
f01043b2:	b2 21                	mov    $0x21,%dl
f01043b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01043b9:	ee                   	out    %al,(%dx)
f01043ba:	b8 04 00 00 00       	mov    $0x4,%eax
f01043bf:	ee                   	out    %al,(%dx)
f01043c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01043c5:	ee                   	out    %al,(%dx)
f01043c6:	b2 a0                	mov    $0xa0,%dl
f01043c8:	b8 11 00 00 00       	mov    $0x11,%eax
f01043cd:	ee                   	out    %al,(%dx)
f01043ce:	b2 a1                	mov    $0xa1,%dl
f01043d0:	b8 28 00 00 00       	mov    $0x28,%eax
f01043d5:	ee                   	out    %al,(%dx)
f01043d6:	b8 02 00 00 00       	mov    $0x2,%eax
f01043db:	ee                   	out    %al,(%dx)
f01043dc:	b8 01 00 00 00       	mov    $0x1,%eax
f01043e1:	ee                   	out    %al,(%dx)
f01043e2:	b2 20                	mov    $0x20,%dl
f01043e4:	b8 68 00 00 00       	mov    $0x68,%eax
f01043e9:	ee                   	out    %al,(%dx)
f01043ea:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043ef:	ee                   	out    %al,(%dx)
f01043f0:	b2 a0                	mov    $0xa0,%dl
f01043f2:	b8 68 00 00 00       	mov    $0x68,%eax
f01043f7:	ee                   	out    %al,(%dx)
f01043f8:	b8 0a 00 00 00       	mov    $0xa,%eax
f01043fd:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01043fe:	0f b7 05 70 53 12 f0 	movzwl 0xf0125370,%eax
f0104405:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0104409:	74 0b                	je     f0104416 <pic_init+0x8a>
		irq_setmask_8259A(irq_mask_8259A);
f010440b:	0f b7 c0             	movzwl %ax,%eax
f010440e:	89 04 24             	mov    %eax,(%esp)
f0104411:	e8 05 ff ff ff       	call   f010431b <irq_setmask_8259A>
}
f0104416:	c9                   	leave  
f0104417:	c3                   	ret    

f0104418 <vcprintf>:
    (*cnt)++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0104418:	55                   	push   %ebp
f0104419:	89 e5                	mov    %esp,%ebp
f010441b:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f010441e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0104425:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104428:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010442c:	8b 45 08             	mov    0x8(%ebp),%eax
f010442f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104433:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104436:	89 44 24 04          	mov    %eax,0x4(%esp)
f010443a:	c7 04 24 65 44 10 f0 	movl   $0xf0104465,(%esp)
f0104441:	e8 27 1d 00 00       	call   f010616d <vprintfmt>
	return cnt;
}
f0104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104449:	c9                   	leave  
f010444a:	c3                   	ret    

f010444b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010444b:	55                   	push   %ebp
f010444c:	89 e5                	mov    %esp,%ebp
f010444e:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0104451:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0104454:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104458:	8b 45 08             	mov    0x8(%ebp),%eax
f010445b:	89 04 24             	mov    %eax,(%esp)
f010445e:	e8 b5 ff ff ff       	call   f0104418 <vcprintf>
	va_end(ap);

	return cnt;
}
f0104463:	c9                   	leave  
f0104464:	c3                   	ret    

f0104465 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0104465:	55                   	push   %ebp
f0104466:	89 e5                	mov    %esp,%ebp
f0104468:	53                   	push   %ebx
f0104469:	83 ec 14             	sub    $0x14,%esp
f010446c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f010446f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104472:	89 04 24             	mov    %eax,(%esp)
f0104475:	e8 90 c2 ff ff       	call   f010070a <cputchar>
    (*cnt)++;
f010447a:	83 03 01             	addl   $0x1,(%ebx)
}
f010447d:	83 c4 14             	add    $0x14,%esp
f0104480:	5b                   	pop    %ebx
f0104481:	5d                   	pop    %ebp
f0104482:	c3                   	ret    
	...

f0104490 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0104490:	55                   	push   %ebp
f0104491:	89 e5                	mov    %esp,%ebp
f0104493:	57                   	push   %edi
f0104494:	56                   	push   %esi
f0104495:	53                   	push   %ebx
f0104496:	83 ec 1c             	sub    $0x1c,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int i = thiscpu->cpu_id;
f0104499:	e8 74 2b 00 00       	call   f0107012 <cpunum>
f010449e:	bb 20 80 27 f0       	mov    $0xf0278020,%ebx
f01044a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a6:	0f b6 34 18          	movzbl (%eax,%ebx,1),%esi
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f01044aa:	e8 63 2b 00 00       	call   f0107012 <cpunum>
f01044af:	89 f2                	mov    %esi,%edx
f01044b1:	f7 da                	neg    %edx
f01044b3:	c1 e2 10             	shl    $0x10,%edx
f01044b6:	81 ea 00 00 40 10    	sub    $0x10400000,%edx
f01044bc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01044bf:	6b c0 74             	imul   $0x74,%eax,%eax
f01044c2:	89 54 18 10          	mov    %edx,0x10(%eax,%ebx,1)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01044c6:	e8 47 2b 00 00       	call   f0107012 <cpunum>
f01044cb:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ce:	66 c7 44 18 14 10 00 	movw   $0x10,0x14(%eax,%ebx,1)
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&thiscpu->cpu_ts), sizeof(struct Taskstate), 0);
f01044d5:	8d 5e 05             	lea    0x5(%esi),%ebx
f01044d8:	e8 35 2b 00 00       	call   f0107012 <cpunum>
f01044dd:	89 c6                	mov    %eax,%esi
f01044df:	e8 2e 2b 00 00       	call   f0107012 <cpunum>
f01044e4:	89 c7                	mov    %eax,%edi
f01044e6:	e8 27 2b 00 00       	call   f0107012 <cpunum>
f01044eb:	ba 00 53 12 f0       	mov    $0xf0125300,%edx
f01044f0:	66 c7 04 da 68 00    	movw   $0x68,(%edx,%ebx,8)
f01044f6:	6b f6 74             	imul   $0x74,%esi,%esi
f01044f9:	81 c6 2c 80 27 f0    	add    $0xf027802c,%esi
f01044ff:	66 89 74 da 02       	mov    %si,0x2(%edx,%ebx,8)
f0104504:	6b cf 74             	imul   $0x74,%edi,%ecx
f0104507:	81 c1 2c 80 27 f0    	add    $0xf027802c,%ecx
f010450d:	c1 e9 10             	shr    $0x10,%ecx
f0104510:	88 4c da 04          	mov    %cl,0x4(%edx,%ebx,8)
f0104514:	c6 44 da 06 40       	movb   $0x40,0x6(%edx,%ebx,8)
f0104519:	6b c0 74             	imul   $0x74,%eax,%eax
f010451c:	05 2c 80 27 f0       	add    $0xf027802c,%eax
f0104521:	c1 e8 18             	shr    $0x18,%eax
f0104524:	88 44 da 07          	mov    %al,0x7(%edx,%ebx,8)
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0104528:	c6 44 da 05 89       	movb   $0x89,0x5(%edx,%ebx,8)
	/* 				sizeof(struct Taskstate), 0); */
	/* gdt[GD_TSS0 >> 3].sd_s = 0; */

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	wrmsr(0x174, GD_KT, 0);				/* SYSENTER_CS_MSR */
f010452d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104532:	b8 08 00 00 00       	mov    $0x8,%eax
f0104537:	b9 74 01 00 00       	mov    $0x174,%ecx
f010453c:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP - i * (KSTKSIZE + KSTKGAP), 0);
f010453e:	b1 75                	mov    $0x75,%cl
f0104540:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104543:	0f 30                	wrmsr  
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);	/* SYSENTER_EIP_MSR */
f0104545:	b8 06 52 10 f0       	mov    $0xf0105206,%eax
f010454a:	b1 76                	mov    $0x76,%cl
f010454c:	0f 30                	wrmsr  
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010454e:	c1 e3 03             	shl    $0x3,%ebx
f0104551:	0f 00 db             	ltr    %bx
}  

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0104554:	b8 74 53 12 f0       	mov    $0xf0125374,%eax
f0104559:	0f 01 18             	lidtl  (%eax)
	ltr(GD_TSS0 + i * 8);
	// Load the IDT
	lidt(&idt_pd);
}
f010455c:	83 c4 1c             	add    $0x1c,%esp
f010455f:	5b                   	pop    %ebx
f0104560:	5e                   	pop    %esi
f0104561:	5f                   	pop    %edi
f0104562:	5d                   	pop    %ebp
f0104563:	c3                   	ret    

f0104564 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0104564:	55                   	push   %ebp
f0104565:	89 e5                	mov    %esp,%ebp
f0104567:	53                   	push   %ebx
f0104568:	83 ec 14             	sub    $0x14,%esp
f010456b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010456e:	8b 03                	mov    (%ebx),%eax
f0104570:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104574:	c7 04 24 ff 90 10 f0 	movl   $0xf01090ff,(%esp)
f010457b:	e8 cb fe ff ff       	call   f010444b <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104580:	8b 43 04             	mov    0x4(%ebx),%eax
f0104583:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104587:	c7 04 24 0e 91 10 f0 	movl   $0xf010910e,(%esp)
f010458e:	e8 b8 fe ff ff       	call   f010444b <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104593:	8b 43 08             	mov    0x8(%ebx),%eax
f0104596:	89 44 24 04          	mov    %eax,0x4(%esp)
f010459a:	c7 04 24 1d 91 10 f0 	movl   $0xf010911d,(%esp)
f01045a1:	e8 a5 fe ff ff       	call   f010444b <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01045a6:	8b 43 0c             	mov    0xc(%ebx),%eax
f01045a9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045ad:	c7 04 24 2c 91 10 f0 	movl   $0xf010912c,(%esp)
f01045b4:	e8 92 fe ff ff       	call   f010444b <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01045b9:	8b 43 10             	mov    0x10(%ebx),%eax
f01045bc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045c0:	c7 04 24 3b 91 10 f0 	movl   $0xf010913b,(%esp)
f01045c7:	e8 7f fe ff ff       	call   f010444b <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01045cc:	8b 43 14             	mov    0x14(%ebx),%eax
f01045cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d3:	c7 04 24 4a 91 10 f0 	movl   $0xf010914a,(%esp)
f01045da:	e8 6c fe ff ff       	call   f010444b <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01045df:	8b 43 18             	mov    0x18(%ebx),%eax
f01045e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e6:	c7 04 24 59 91 10 f0 	movl   $0xf0109159,(%esp)
f01045ed:	e8 59 fe ff ff       	call   f010444b <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01045f2:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01045f5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045f9:	c7 04 24 68 91 10 f0 	movl   $0xf0109168,(%esp)
f0104600:	e8 46 fe ff ff       	call   f010444b <cprintf>
}
f0104605:	83 c4 14             	add    $0x14,%esp
f0104608:	5b                   	pop    %ebx
f0104609:	5d                   	pop    %ebp
f010460a:	c3                   	ret    

f010460b <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010460b:	55                   	push   %ebp
f010460c:	89 e5                	mov    %esp,%ebp
f010460e:	56                   	push   %esi
f010460f:	53                   	push   %ebx
f0104610:	83 ec 10             	sub    $0x10,%esp
f0104613:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104616:	e8 f7 29 00 00       	call   f0107012 <cpunum>
f010461b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010461f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104623:	c7 04 24 77 91 10 f0 	movl   $0xf0109177,(%esp)
f010462a:	e8 1c fe ff ff       	call   f010444b <cprintf>
	print_regs(&tf->tf_regs);
f010462f:	89 1c 24             	mov    %ebx,(%esp)
f0104632:	e8 2d ff ff ff       	call   f0104564 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104637:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010463b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010463f:	c7 04 24 95 91 10 f0 	movl   $0xf0109195,(%esp)
f0104646:	e8 00 fe ff ff       	call   f010444b <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010464b:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f010464f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104653:	c7 04 24 a8 91 10 f0 	movl   $0xf01091a8,(%esp)
f010465a:	e8 ec fd ff ff       	call   f010444b <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010465f:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0104662:	83 f8 13             	cmp    $0x13,%eax
f0104665:	77 09                	ja     f0104670 <print_trapframe+0x65>
		return excnames[trapno];
f0104667:	8b 14 85 a0 94 10 f0 	mov    -0xfef6b60(,%eax,4),%edx
f010466e:	eb 1d                	jmp    f010468d <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
f0104670:	ba bb 91 10 f0       	mov    $0xf01091bb,%edx
f0104675:	83 f8 30             	cmp    $0x30,%eax
f0104678:	74 13                	je     f010468d <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010467a:	8d 50 e0             	lea    -0x20(%eax),%edx
f010467d:	83 fa 10             	cmp    $0x10,%edx
f0104680:	ba c7 91 10 f0       	mov    $0xf01091c7,%edx
f0104685:	b9 d6 91 10 f0       	mov    $0xf01091d6,%ecx
f010468a:	0f 42 d1             	cmovb  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010468d:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104691:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104695:	c7 04 24 e9 91 10 f0 	movl   $0xf01091e9,(%esp)
f010469c:	e8 aa fd ff ff       	call   f010444b <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01046a1:	3b 1d 64 5a 27 f0    	cmp    0xf0275a64,%ebx
f01046a7:	75 19                	jne    f01046c2 <print_trapframe+0xb7>
f01046a9:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01046ad:	75 13                	jne    f01046c2 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f01046af:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01046b2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046b6:	c7 04 24 fb 91 10 f0 	movl   $0xf01091fb,(%esp)
f01046bd:	e8 89 fd ff ff       	call   f010444b <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01046c2:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046c9:	c7 04 24 0a 92 10 f0 	movl   $0xf010920a,(%esp)
f01046d0:	e8 76 fd ff ff       	call   f010444b <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01046d5:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01046d9:	75 4a                	jne    f0104725 <print_trapframe+0x11a>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01046db:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01046de:	a8 01                	test   $0x1,%al
f01046e0:	ba 18 92 10 f0       	mov    $0xf0109218,%edx
f01046e5:	b9 24 92 10 f0       	mov    $0xf0109224,%ecx
f01046ea:	0f 44 ca             	cmove  %edx,%ecx
f01046ed:	a8 02                	test   $0x2,%al
f01046ef:	ba 2f 92 10 f0       	mov    $0xf010922f,%edx
f01046f4:	be 34 92 10 f0       	mov    $0xf0109234,%esi
f01046f9:	0f 45 d6             	cmovne %esi,%edx
f01046fc:	a8 04                	test   $0x4,%al
f01046fe:	b8 2c 93 10 f0       	mov    $0xf010932c,%eax
f0104703:	be 3a 92 10 f0       	mov    $0xf010923a,%esi
f0104708:	0f 45 c6             	cmovne %esi,%eax
f010470b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010470f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104713:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104717:	c7 04 24 3f 92 10 f0 	movl   $0xf010923f,(%esp)
f010471e:	e8 28 fd ff ff       	call   f010444b <cprintf>
f0104723:	eb 0c                	jmp    f0104731 <print_trapframe+0x126>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104725:	c7 04 24 b7 92 10 f0 	movl   $0xf01092b7,(%esp)
f010472c:	e8 1a fd ff ff       	call   f010444b <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104731:	8b 43 30             	mov    0x30(%ebx),%eax
f0104734:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104738:	c7 04 24 4e 92 10 f0 	movl   $0xf010924e,(%esp)
f010473f:	e8 07 fd ff ff       	call   f010444b <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104744:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104748:	89 44 24 04          	mov    %eax,0x4(%esp)
f010474c:	c7 04 24 5d 92 10 f0 	movl   $0xf010925d,(%esp)
f0104753:	e8 f3 fc ff ff       	call   f010444b <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104758:	8b 43 38             	mov    0x38(%ebx),%eax
f010475b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010475f:	c7 04 24 70 92 10 f0 	movl   $0xf0109270,(%esp)
f0104766:	e8 e0 fc ff ff       	call   f010444b <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f010476b:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010476f:	74 27                	je     f0104798 <print_trapframe+0x18d>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104771:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104774:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104778:	c7 04 24 7f 92 10 f0 	movl   $0xf010927f,(%esp)
f010477f:	e8 c7 fc ff ff       	call   f010444b <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104784:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104788:	89 44 24 04          	mov    %eax,0x4(%esp)
f010478c:	c7 04 24 8e 92 10 f0 	movl   $0xf010928e,(%esp)
f0104793:	e8 b3 fc ff ff       	call   f010444b <cprintf>
	}
}
f0104798:	83 c4 10             	add    $0x10,%esp
f010479b:	5b                   	pop    %ebx
f010479c:	5e                   	pop    %esi
f010479d:	5d                   	pop    %ebp
f010479e:	c3                   	ret    

f010479f <trap_init>:
}


void
trap_init(void)
{
f010479f:	55                   	push   %ebp
f01047a0:	89 e5                	mov    %esp,%ebp
f01047a2:	83 ec 18             	sub    $0x18,%esp
	extern void t_irq13();
	extern void t_irq14();
	extern void t_irq15();
	
	
	SETGATE(idt[T_DIVIDE],0,GD_KT,t_divide,0);
f01047a5:	b8 08 51 10 f0       	mov    $0xf0105108,%eax
f01047aa:	66 a3 60 52 27 f0    	mov    %ax,0xf0275260
f01047b0:	66 c7 05 62 52 27 f0 	movw   $0x8,0xf0275262
f01047b7:	08 00 
f01047b9:	c6 05 64 52 27 f0 00 	movb   $0x0,0xf0275264
f01047c0:	c6 05 65 52 27 f0 8e 	movb   $0x8e,0xf0275265
f01047c7:	c1 e8 10             	shr    $0x10,%eax
f01047ca:	66 a3 66 52 27 f0    	mov    %ax,0xf0275266
	SETGATE(idt[T_DEBUG],0,GD_KT,t_debug,0);
f01047d0:	b8 12 51 10 f0       	mov    $0xf0105112,%eax
f01047d5:	66 a3 68 52 27 f0    	mov    %ax,0xf0275268
f01047db:	66 c7 05 6a 52 27 f0 	movw   $0x8,0xf027526a
f01047e2:	08 00 
f01047e4:	c6 05 6c 52 27 f0 00 	movb   $0x0,0xf027526c
f01047eb:	c6 05 6d 52 27 f0 8e 	movb   $0x8e,0xf027526d
f01047f2:	c1 e8 10             	shr    $0x10,%eax
f01047f5:	66 a3 6e 52 27 f0    	mov    %ax,0xf027526e
	SETGATE(idt[T_NMI],0,GD_KT,t_nmi,0);
f01047fb:	b8 1c 51 10 f0       	mov    $0xf010511c,%eax
f0104800:	66 a3 70 52 27 f0    	mov    %ax,0xf0275270
f0104806:	66 c7 05 72 52 27 f0 	movw   $0x8,0xf0275272
f010480d:	08 00 
f010480f:	c6 05 74 52 27 f0 00 	movb   $0x0,0xf0275274
f0104816:	c6 05 75 52 27 f0 8e 	movb   $0x8e,0xf0275275
f010481d:	c1 e8 10             	shr    $0x10,%eax
f0104820:	66 a3 76 52 27 f0    	mov    %ax,0xf0275276
	SETGATE(idt[T_BRKPT],0,GD_KT,t_brkpt,3);  //user set
f0104826:	b8 26 51 10 f0       	mov    $0xf0105126,%eax
f010482b:	66 a3 78 52 27 f0    	mov    %ax,0xf0275278
f0104831:	66 c7 05 7a 52 27 f0 	movw   $0x8,0xf027527a
f0104838:	08 00 
f010483a:	c6 05 7c 52 27 f0 00 	movb   $0x0,0xf027527c
f0104841:	c6 05 7d 52 27 f0 ee 	movb   $0xee,0xf027527d
f0104848:	c1 e8 10             	shr    $0x10,%eax
f010484b:	66 a3 7e 52 27 f0    	mov    %ax,0xf027527e
	SETGATE(idt[T_BOUND],0,GD_KT,t_bound,0);
f0104851:	b8 3a 51 10 f0       	mov    $0xf010513a,%eax
f0104856:	66 a3 88 52 27 f0    	mov    %ax,0xf0275288
f010485c:	66 c7 05 8a 52 27 f0 	movw   $0x8,0xf027528a
f0104863:	08 00 
f0104865:	c6 05 8c 52 27 f0 00 	movb   $0x0,0xf027528c
f010486c:	c6 05 8d 52 27 f0 8e 	movb   $0x8e,0xf027528d
f0104873:	c1 e8 10             	shr    $0x10,%eax
f0104876:	66 a3 8e 52 27 f0    	mov    %ax,0xf027528e
	SETGATE(idt[T_ILLOP],0,GD_KT,t_illop,0);
f010487c:	b8 44 51 10 f0       	mov    $0xf0105144,%eax
f0104881:	66 a3 90 52 27 f0    	mov    %ax,0xf0275290
f0104887:	66 c7 05 92 52 27 f0 	movw   $0x8,0xf0275292
f010488e:	08 00 
f0104890:	c6 05 94 52 27 f0 00 	movb   $0x0,0xf0275294
f0104897:	c6 05 95 52 27 f0 8e 	movb   $0x8e,0xf0275295
f010489e:	c1 e8 10             	shr    $0x10,%eax
f01048a1:	66 a3 96 52 27 f0    	mov    %ax,0xf0275296
	SETGATE(idt[T_DEVICE],0,GD_KT,t_device,0);
f01048a7:	b8 4e 51 10 f0       	mov    $0xf010514e,%eax
f01048ac:	66 a3 98 52 27 f0    	mov    %ax,0xf0275298
f01048b2:	66 c7 05 9a 52 27 f0 	movw   $0x8,0xf027529a
f01048b9:	08 00 
f01048bb:	c6 05 9c 52 27 f0 00 	movb   $0x0,0xf027529c
f01048c2:	c6 05 9d 52 27 f0 8e 	movb   $0x8e,0xf027529d
f01048c9:	c1 e8 10             	shr    $0x10,%eax
f01048cc:	66 a3 9e 52 27 f0    	mov    %ax,0xf027529e
	SETGATE(idt[T_DBLFLT],0,GD_KT,t_dblflt,0);
f01048d2:	b8 58 51 10 f0       	mov    $0xf0105158,%eax
f01048d7:	66 a3 a0 52 27 f0    	mov    %ax,0xf02752a0
f01048dd:	66 c7 05 a2 52 27 f0 	movw   $0x8,0xf02752a2
f01048e4:	08 00 
f01048e6:	c6 05 a4 52 27 f0 00 	movb   $0x0,0xf02752a4
f01048ed:	c6 05 a5 52 27 f0 8e 	movb   $0x8e,0xf02752a5
f01048f4:	c1 e8 10             	shr    $0x10,%eax
f01048f7:	66 a3 a6 52 27 f0    	mov    %ax,0xf02752a6
	SETGATE(idt[T_TSS],0,GD_KT,t_tss,0);
f01048fd:	b8 60 51 10 f0       	mov    $0xf0105160,%eax
f0104902:	66 a3 b0 52 27 f0    	mov    %ax,0xf02752b0
f0104908:	66 c7 05 b2 52 27 f0 	movw   $0x8,0xf02752b2
f010490f:	08 00 
f0104911:	c6 05 b4 52 27 f0 00 	movb   $0x0,0xf02752b4
f0104918:	c6 05 b5 52 27 f0 8e 	movb   $0x8e,0xf02752b5
f010491f:	c1 e8 10             	shr    $0x10,%eax
f0104922:	66 a3 b6 52 27 f0    	mov    %ax,0xf02752b6
	SETGATE(idt[T_SEGNP],0,GD_KT,t_segnp,0);
f0104928:	b8 68 51 10 f0       	mov    $0xf0105168,%eax
f010492d:	66 a3 b8 52 27 f0    	mov    %ax,0xf02752b8
f0104933:	66 c7 05 ba 52 27 f0 	movw   $0x8,0xf02752ba
f010493a:	08 00 
f010493c:	c6 05 bc 52 27 f0 00 	movb   $0x0,0xf02752bc
f0104943:	c6 05 bd 52 27 f0 8e 	movb   $0x8e,0xf02752bd
f010494a:	c1 e8 10             	shr    $0x10,%eax
f010494d:	66 a3 be 52 27 f0    	mov    %ax,0xf02752be
	SETGATE(idt[T_STACK],0,GD_KT,t_stack,0);
f0104953:	b8 70 51 10 f0       	mov    $0xf0105170,%eax
f0104958:	66 a3 c0 52 27 f0    	mov    %ax,0xf02752c0
f010495e:	66 c7 05 c2 52 27 f0 	movw   $0x8,0xf02752c2
f0104965:	08 00 
f0104967:	c6 05 c4 52 27 f0 00 	movb   $0x0,0xf02752c4
f010496e:	c6 05 c5 52 27 f0 8e 	movb   $0x8e,0xf02752c5
f0104975:	c1 e8 10             	shr    $0x10,%eax
f0104978:	66 a3 c6 52 27 f0    	mov    %ax,0xf02752c6
	SETGATE(idt[T_GPFLT],0,GD_KT,t_gpflt,0);
f010497e:	b8 78 51 10 f0       	mov    $0xf0105178,%eax
f0104983:	66 a3 c8 52 27 f0    	mov    %ax,0xf02752c8
f0104989:	66 c7 05 ca 52 27 f0 	movw   $0x8,0xf02752ca
f0104990:	08 00 
f0104992:	c6 05 cc 52 27 f0 00 	movb   $0x0,0xf02752cc
f0104999:	c6 05 cd 52 27 f0 8e 	movb   $0x8e,0xf02752cd
f01049a0:	c1 e8 10             	shr    $0x10,%eax
f01049a3:	66 a3 ce 52 27 f0    	mov    %ax,0xf02752ce
	SETGATE(idt[T_PGFLT],0,GD_KT,t_pgflt,0);
f01049a9:	b8 80 51 10 f0       	mov    $0xf0105180,%eax
f01049ae:	66 a3 d0 52 27 f0    	mov    %ax,0xf02752d0
f01049b4:	66 c7 05 d2 52 27 f0 	movw   $0x8,0xf02752d2
f01049bb:	08 00 
f01049bd:	c6 05 d4 52 27 f0 00 	movb   $0x0,0xf02752d4
f01049c4:	c6 05 d5 52 27 f0 8e 	movb   $0x8e,0xf02752d5
f01049cb:	c1 e8 10             	shr    $0x10,%eax
f01049ce:	66 a3 d6 52 27 f0    	mov    %ax,0xf02752d6
	SETGATE(idt[T_FPERR],0,GD_KT,t_fperr,0);
f01049d4:	b8 88 51 10 f0       	mov    $0xf0105188,%eax
f01049d9:	66 a3 e0 52 27 f0    	mov    %ax,0xf02752e0
f01049df:	66 c7 05 e2 52 27 f0 	movw   $0x8,0xf02752e2
f01049e6:	08 00 
f01049e8:	c6 05 e4 52 27 f0 00 	movb   $0x0,0xf02752e4
f01049ef:	c6 05 e5 52 27 f0 8e 	movb   $0x8e,0xf02752e5
f01049f6:	c1 e8 10             	shr    $0x10,%eax
f01049f9:	66 a3 e6 52 27 f0    	mov    %ax,0xf02752e6
	SETGATE(idt[T_ALIGN],0,GD_KT,t_align,0);
f01049ff:	b8 92 51 10 f0       	mov    $0xf0105192,%eax
f0104a04:	66 a3 e8 52 27 f0    	mov    %ax,0xf02752e8
f0104a0a:	66 c7 05 ea 52 27 f0 	movw   $0x8,0xf02752ea
f0104a11:	08 00 
f0104a13:	c6 05 ec 52 27 f0 00 	movb   $0x0,0xf02752ec
f0104a1a:	c6 05 ed 52 27 f0 8e 	movb   $0x8e,0xf02752ed
f0104a21:	c1 e8 10             	shr    $0x10,%eax
f0104a24:	66 a3 ee 52 27 f0    	mov    %ax,0xf02752ee
	SETGATE(idt[T_MCHK],0,GD_KT,t_mchk,0);
f0104a2a:	b8 9a 51 10 f0       	mov    $0xf010519a,%eax
f0104a2f:	66 a3 f0 52 27 f0    	mov    %ax,0xf02752f0
f0104a35:	66 c7 05 f2 52 27 f0 	movw   $0x8,0xf02752f2
f0104a3c:	08 00 
f0104a3e:	c6 05 f4 52 27 f0 00 	movb   $0x0,0xf02752f4
f0104a45:	c6 05 f5 52 27 f0 8e 	movb   $0x8e,0xf02752f5
f0104a4c:	c1 e8 10             	shr    $0x10,%eax
f0104a4f:	66 a3 f6 52 27 f0    	mov    %ax,0xf02752f6
	SETGATE(idt[T_SIMDERR],0,GD_KT,t_simderr,0);
f0104a55:	b8 a0 51 10 f0       	mov    $0xf01051a0,%eax
f0104a5a:	66 a3 f8 52 27 f0    	mov    %ax,0xf02752f8
f0104a60:	66 c7 05 fa 52 27 f0 	movw   $0x8,0xf02752fa
f0104a67:	08 00 
f0104a69:	c6 05 fc 52 27 f0 00 	movb   $0x0,0xf02752fc
f0104a70:	c6 05 fd 52 27 f0 8e 	movb   $0x8e,0xf02752fd
f0104a77:	c1 e8 10             	shr    $0x10,%eax
f0104a7a:	66 a3 fe 52 27 f0    	mov    %ax,0xf02752fe
	
	//SETGATE(idt[T_SYSCALL],0,GD_KT,sysenter_handler,3); if sysenter interrupt?
	
	//set IRQ GATE
	SETGATE(idt[IRQ_OFFSET + 0],0,GD_KT,t_irq0,0);
f0104a80:	b8 a6 51 10 f0       	mov    $0xf01051a6,%eax
f0104a85:	66 a3 60 53 27 f0    	mov    %ax,0xf0275360
f0104a8b:	66 c7 05 62 53 27 f0 	movw   $0x8,0xf0275362
f0104a92:	08 00 
f0104a94:	c6 05 64 53 27 f0 00 	movb   $0x0,0xf0275364
f0104a9b:	c6 05 65 53 27 f0 8e 	movb   $0x8e,0xf0275365
f0104aa2:	c1 e8 10             	shr    $0x10,%eax
f0104aa5:	66 a3 66 53 27 f0    	mov    %ax,0xf0275366
	SETGATE(idt[IRQ_OFFSET + 1],0,GD_KT,t_irq1,0);
f0104aab:	b8 ac 51 10 f0       	mov    $0xf01051ac,%eax
f0104ab0:	66 a3 68 53 27 f0    	mov    %ax,0xf0275368
f0104ab6:	66 c7 05 6a 53 27 f0 	movw   $0x8,0xf027536a
f0104abd:	08 00 
f0104abf:	c6 05 6c 53 27 f0 00 	movb   $0x0,0xf027536c
f0104ac6:	c6 05 6d 53 27 f0 8e 	movb   $0x8e,0xf027536d
f0104acd:	c1 e8 10             	shr    $0x10,%eax
f0104ad0:	66 a3 6e 53 27 f0    	mov    %ax,0xf027536e
	SETGATE(idt[IRQ_OFFSET + 2],0,GD_KT,t_irq2,0);
f0104ad6:	b8 b2 51 10 f0       	mov    $0xf01051b2,%eax
f0104adb:	66 a3 70 53 27 f0    	mov    %ax,0xf0275370
f0104ae1:	66 c7 05 72 53 27 f0 	movw   $0x8,0xf0275372
f0104ae8:	08 00 
f0104aea:	c6 05 74 53 27 f0 00 	movb   $0x0,0xf0275374
f0104af1:	c6 05 75 53 27 f0 8e 	movb   $0x8e,0xf0275375
f0104af8:	c1 e8 10             	shr    $0x10,%eax
f0104afb:	66 a3 76 53 27 f0    	mov    %ax,0xf0275376
	SETGATE(idt[IRQ_OFFSET + 3],0,GD_KT,t_irq3,0);
f0104b01:	b8 b8 51 10 f0       	mov    $0xf01051b8,%eax
f0104b06:	66 a3 78 53 27 f0    	mov    %ax,0xf0275378
f0104b0c:	66 c7 05 7a 53 27 f0 	movw   $0x8,0xf027537a
f0104b13:	08 00 
f0104b15:	c6 05 7c 53 27 f0 00 	movb   $0x0,0xf027537c
f0104b1c:	c6 05 7d 53 27 f0 8e 	movb   $0x8e,0xf027537d
f0104b23:	c1 e8 10             	shr    $0x10,%eax
f0104b26:	66 a3 7e 53 27 f0    	mov    %ax,0xf027537e
	SETGATE(idt[IRQ_OFFSET + 4],0,GD_KT,t_irq4,0);
f0104b2c:	b8 be 51 10 f0       	mov    $0xf01051be,%eax
f0104b31:	66 a3 80 53 27 f0    	mov    %ax,0xf0275380
f0104b37:	66 c7 05 82 53 27 f0 	movw   $0x8,0xf0275382
f0104b3e:	08 00 
f0104b40:	c6 05 84 53 27 f0 00 	movb   $0x0,0xf0275384
f0104b47:	c6 05 85 53 27 f0 8e 	movb   $0x8e,0xf0275385
f0104b4e:	c1 e8 10             	shr    $0x10,%eax
f0104b51:	66 a3 86 53 27 f0    	mov    %ax,0xf0275386
	SETGATE(idt[IRQ_OFFSET + 5],0,GD_KT,t_irq5,0);
f0104b57:	b8 c4 51 10 f0       	mov    $0xf01051c4,%eax
f0104b5c:	66 a3 88 53 27 f0    	mov    %ax,0xf0275388
f0104b62:	66 c7 05 8a 53 27 f0 	movw   $0x8,0xf027538a
f0104b69:	08 00 
f0104b6b:	c6 05 8c 53 27 f0 00 	movb   $0x0,0xf027538c
f0104b72:	c6 05 8d 53 27 f0 8e 	movb   $0x8e,0xf027538d
f0104b79:	c1 e8 10             	shr    $0x10,%eax
f0104b7c:	66 a3 8e 53 27 f0    	mov    %ax,0xf027538e
	SETGATE(idt[IRQ_OFFSET + 6],0,GD_KT,t_irq6,0);
f0104b82:	b8 ca 51 10 f0       	mov    $0xf01051ca,%eax
f0104b87:	66 a3 90 53 27 f0    	mov    %ax,0xf0275390
f0104b8d:	66 c7 05 92 53 27 f0 	movw   $0x8,0xf0275392
f0104b94:	08 00 
f0104b96:	c6 05 94 53 27 f0 00 	movb   $0x0,0xf0275394
f0104b9d:	c6 05 95 53 27 f0 8e 	movb   $0x8e,0xf0275395
f0104ba4:	c1 e8 10             	shr    $0x10,%eax
f0104ba7:	66 a3 96 53 27 f0    	mov    %ax,0xf0275396
	SETGATE(idt[IRQ_OFFSET + 7],0,GD_KT,t_irq7,0);
f0104bad:	b8 d0 51 10 f0       	mov    $0xf01051d0,%eax
f0104bb2:	66 a3 98 53 27 f0    	mov    %ax,0xf0275398
f0104bb8:	66 c7 05 9a 53 27 f0 	movw   $0x8,0xf027539a
f0104bbf:	08 00 
f0104bc1:	c6 05 9c 53 27 f0 00 	movb   $0x0,0xf027539c
f0104bc8:	c6 05 9d 53 27 f0 8e 	movb   $0x8e,0xf027539d
f0104bcf:	c1 e8 10             	shr    $0x10,%eax
f0104bd2:	66 a3 9e 53 27 f0    	mov    %ax,0xf027539e
	SETGATE(idt[IRQ_OFFSET + 8],0,GD_KT,t_irq8,0);
f0104bd8:	b8 d6 51 10 f0       	mov    $0xf01051d6,%eax
f0104bdd:	66 a3 a0 53 27 f0    	mov    %ax,0xf02753a0
f0104be3:	66 c7 05 a2 53 27 f0 	movw   $0x8,0xf02753a2
f0104bea:	08 00 
f0104bec:	c6 05 a4 53 27 f0 00 	movb   $0x0,0xf02753a4
f0104bf3:	c6 05 a5 53 27 f0 8e 	movb   $0x8e,0xf02753a5
f0104bfa:	c1 e8 10             	shr    $0x10,%eax
f0104bfd:	66 a3 a6 53 27 f0    	mov    %ax,0xf02753a6
	SETGATE(idt[IRQ_OFFSET + 9],0,GD_KT,t_irq9,0);
f0104c03:	b8 dc 51 10 f0       	mov    $0xf01051dc,%eax
f0104c08:	66 a3 a8 53 27 f0    	mov    %ax,0xf02753a8
f0104c0e:	66 c7 05 aa 53 27 f0 	movw   $0x8,0xf02753aa
f0104c15:	08 00 
f0104c17:	c6 05 ac 53 27 f0 00 	movb   $0x0,0xf02753ac
f0104c1e:	c6 05 ad 53 27 f0 8e 	movb   $0x8e,0xf02753ad
f0104c25:	c1 e8 10             	shr    $0x10,%eax
f0104c28:	66 a3 ae 53 27 f0    	mov    %ax,0xf02753ae
	SETGATE(idt[IRQ_OFFSET + 10],0,GD_KT,t_irq10,0);
f0104c2e:	b8 e2 51 10 f0       	mov    $0xf01051e2,%eax
f0104c33:	66 a3 b0 53 27 f0    	mov    %ax,0xf02753b0
f0104c39:	66 c7 05 b2 53 27 f0 	movw   $0x8,0xf02753b2
f0104c40:	08 00 
f0104c42:	c6 05 b4 53 27 f0 00 	movb   $0x0,0xf02753b4
f0104c49:	c6 05 b5 53 27 f0 8e 	movb   $0x8e,0xf02753b5
f0104c50:	c1 e8 10             	shr    $0x10,%eax
f0104c53:	66 a3 b6 53 27 f0    	mov    %ax,0xf02753b6
	SETGATE(idt[IRQ_OFFSET + 11],0,GD_KT,t_irq11,0);
f0104c59:	b8 e8 51 10 f0       	mov    $0xf01051e8,%eax
f0104c5e:	66 a3 b8 53 27 f0    	mov    %ax,0xf02753b8
f0104c64:	66 c7 05 ba 53 27 f0 	movw   $0x8,0xf02753ba
f0104c6b:	08 00 
f0104c6d:	c6 05 bc 53 27 f0 00 	movb   $0x0,0xf02753bc
f0104c74:	c6 05 bd 53 27 f0 8e 	movb   $0x8e,0xf02753bd
f0104c7b:	c1 e8 10             	shr    $0x10,%eax
f0104c7e:	66 a3 be 53 27 f0    	mov    %ax,0xf02753be
	SETGATE(idt[IRQ_OFFSET + 12],0,GD_KT,t_irq12,0);
f0104c84:	b8 ee 51 10 f0       	mov    $0xf01051ee,%eax
f0104c89:	66 a3 c0 53 27 f0    	mov    %ax,0xf02753c0
f0104c8f:	66 c7 05 c2 53 27 f0 	movw   $0x8,0xf02753c2
f0104c96:	08 00 
f0104c98:	c6 05 c4 53 27 f0 00 	movb   $0x0,0xf02753c4
f0104c9f:	c6 05 c5 53 27 f0 8e 	movb   $0x8e,0xf02753c5
f0104ca6:	c1 e8 10             	shr    $0x10,%eax
f0104ca9:	66 a3 c6 53 27 f0    	mov    %ax,0xf02753c6
	SETGATE(idt[IRQ_OFFSET + 13],0,GD_KT,t_irq13,0);
f0104caf:	b8 f4 51 10 f0       	mov    $0xf01051f4,%eax
f0104cb4:	66 a3 c8 53 27 f0    	mov    %ax,0xf02753c8
f0104cba:	66 c7 05 ca 53 27 f0 	movw   $0x8,0xf02753ca
f0104cc1:	08 00 
f0104cc3:	c6 05 cc 53 27 f0 00 	movb   $0x0,0xf02753cc
f0104cca:	c6 05 cd 53 27 f0 8e 	movb   $0x8e,0xf02753cd
f0104cd1:	c1 e8 10             	shr    $0x10,%eax
f0104cd4:	66 a3 ce 53 27 f0    	mov    %ax,0xf02753ce
	SETGATE(idt[IRQ_OFFSET + 14],0,GD_KT,t_irq14,0);
f0104cda:	b8 fa 51 10 f0       	mov    $0xf01051fa,%eax
f0104cdf:	66 a3 d0 53 27 f0    	mov    %ax,0xf02753d0
f0104ce5:	66 c7 05 d2 53 27 f0 	movw   $0x8,0xf02753d2
f0104cec:	08 00 
f0104cee:	c6 05 d4 53 27 f0 00 	movb   $0x0,0xf02753d4
f0104cf5:	c6 05 d5 53 27 f0 8e 	movb   $0x8e,0xf02753d5
f0104cfc:	c1 e8 10             	shr    $0x10,%eax
f0104cff:	66 a3 d6 53 27 f0    	mov    %ax,0xf02753d6
	SETGATE(idt[IRQ_OFFSET + 15],0,GD_KT,t_irq15,0);
f0104d05:	b8 00 52 10 f0       	mov    $0xf0105200,%eax
f0104d0a:	66 a3 d8 53 27 f0    	mov    %ax,0xf02753d8
f0104d10:	66 c7 05 da 53 27 f0 	movw   $0x8,0xf02753da
f0104d17:	08 00 
f0104d19:	c6 05 dc 53 27 f0 00 	movb   $0x0,0xf02753dc
f0104d20:	c6 05 dd 53 27 f0 8e 	movb   $0x8e,0xf02753dd
f0104d27:	c1 e8 10             	shr    $0x10,%eax
f0104d2a:	66 a3 de 53 27 f0    	mov    %ax,0xf02753de

	wrmsr(0x174, GD_KT, 0);				/* SYSENTER_CS_MSR */
f0104d30:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d35:	b8 08 00 00 00       	mov    $0x8,%eax
f0104d3a:	b9 74 01 00 00       	mov    $0x174,%ecx
f0104d3f:	0f 30                	wrmsr  
	wrmsr(0x175, KSTACKTOP, 0);		/* SYSENTER_ESP_MSR */
f0104d41:	b8 00 00 c0 ef       	mov    $0xefc00000,%eax
f0104d46:	b1 75                	mov    $0x75,%cl
f0104d48:	0f 30                	wrmsr  
	wrmsr(0x176, (uint32_t)&sysenter_handler, 0);	/* SYSENTER_EIP_MSR */
f0104d4a:	b8 06 52 10 f0       	mov    $0xf0105206,%eax
f0104d4f:	b1 76                	mov    $0x76,%cl
f0104d51:	0f 30                	wrmsr  
	
	cprintf("have set!!!!!!!!!!!!!!\n");
f0104d53:	c7 04 24 a1 92 10 f0 	movl   $0xf01092a1,(%esp)
f0104d5a:	e8 ec f6 ff ff       	call   f010444b <cprintf>
	// Per-CPU setup 
	trap_init_percpu();
f0104d5f:	e8 2c f7 ff ff       	call   f0104490 <trap_init_percpu>
}
f0104d64:	c9                   	leave  
f0104d65:	c3                   	ret    

f0104d66 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104d66:	55                   	push   %ebp
f0104d67:	89 e5                	mov    %esp,%ebp
f0104d69:	83 ec 38             	sub    $0x38,%esp
f0104d6c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104d6f:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104d72:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104d75:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d78:	0f 20 d3             	mov    %cr2,%ebx
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f0104d7b:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f0104d7f:	75 1c                	jne    f0104d9d <page_fault_handler+0x37>
		panic ("kernel-mode page faults");
f0104d81:	c7 44 24 08 b9 92 10 	movl   $0xf01092b9,0x8(%esp)
f0104d88:	f0 
f0104d89:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
f0104d90:	00 
f0104d91:	c7 04 24 d1 92 10 f0 	movl   $0xf01092d1,(%esp)
f0104d98:	e8 e8 b2 ff ff       	call   f0100085 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if(curenv->env_pgfault_upcall != NULL)
f0104d9d:	e8 70 22 00 00       	call   f0107012 <cpunum>
f0104da2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104da5:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0104dab:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104daf:	0f 84 f9 00 00 00    	je     f0104eae <page_fault_handler+0x148>
	{
		struct UTrapframe* utf;
		if(	UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp < UXSTACKTOP)
f0104db5:	8b 46 3c             	mov    0x3c(%esi),%eax
f0104db8:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
f0104dbe:	83 e8 38             	sub    $0x38,%eax
f0104dc1:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0104dc7:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0104dcc:	0f 42 d0             	cmovb  %eax,%edx
f0104dcf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		{
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof (struct UTrapframe) - 4);
		}
		else
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof (struct UTrapframe));
		user_mem_assert (curenv,(void*)utf,sizeof (struct UTrapframe),PTE_U|PTE_W);
f0104dd2:	e8 3b 22 00 00       	call   f0107012 <cpunum>
f0104dd7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0104dde:	00 
f0104ddf:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
f0104de6:	00 
f0104de7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104dea:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104dee:	6b c0 74             	imul   $0x74,%eax,%eax
f0104df1:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0104df7:	89 04 24             	mov    %eax,(%esp)
f0104dfa:	e8 e3 ca ff ff       	call   f01018e2 <user_mem_assert>
		
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
f0104e2c:	74 04                	je     f0104e32 <page_fault_handler+0xcc>
f0104e2e:	a4                   	movsb  %ds:(%esi),%es:(%edi)
f0104e2f:	83 e8 01             	sub    $0x1,%eax
f0104e32:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0104e38:	74 05                	je     f0104e3f <page_fault_handler+0xd9>
f0104e3a:	66 a5                	movsw  %ds:(%esi),%es:(%edi)
f0104e3c:	83 e8 02             	sub    $0x2,%eax
f0104e3f:	89 c1                	mov    %eax,%ecx
f0104e41:	c1 e9 02             	shr    $0x2,%ecx
f0104e44:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104e46:	ba 00 00 00 00       	mov    $0x0,%edx
f0104e4b:	a8 02                	test   $0x2,%al
f0104e4d:	74 0b                	je     f0104e5a <page_fault_handler+0xf4>
f0104e4f:	0f b7 0c 16          	movzwl (%esi,%edx,1),%ecx
f0104e53:	66 89 0c 17          	mov    %cx,(%edi,%edx,1)
f0104e57:	83 c2 02             	add    $0x2,%edx
f0104e5a:	a8 01                	test   $0x1,%al
f0104e5c:	74 07                	je     f0104e65 <page_fault_handler+0xff>
f0104e5e:	0f b6 04 16          	movzbl (%esi,%edx,1),%eax
f0104e62:	88 04 17             	mov    %al,(%edi,%edx,1)
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
f0104e65:	e8 a8 21 00 00       	call   f0107012 <cpunum>
f0104e6a:	bb 20 80 27 f0       	mov    $0xf0278020,%ebx
f0104e6f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e72:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
f0104e76:	e8 97 21 00 00       	call   f0107012 <cpunum>
f0104e7b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e7e:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104e82:	8b 40 64             	mov    0x64(%eax),%eax
f0104e85:	89 46 30             	mov    %eax,0x30(%esi)
		curenv->env_tf.tf_esp = (uint32_t) utf;
f0104e88:	e8 85 21 00 00       	call   f0107012 <cpunum>
f0104e8d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e90:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104e94:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104e97:	89 50 3c             	mov    %edx,0x3c(%eax)
		env_run (curenv);
f0104e9a:	e8 73 21 00 00       	call   f0107012 <cpunum>
f0104e9f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ea2:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104ea6:	89 04 24             	mov    %eax,(%esp)
f0104ea9:	e8 a3 ed ff ff       	call   f0103c51 <env_run>
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104eae:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104eb1:	e8 5c 21 00 00       	call   f0107012 <cpunum>
		curenv->env_tf.tf_eip = (uint32_t) curenv->env_pgfault_upcall;
		curenv->env_tf.tf_esp = (uint32_t) utf;
		env_run (curenv);
	}
	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104eb6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104eba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ebe:	bb 20 80 27 f0       	mov    $0xf0278020,%ebx
f0104ec3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ec6:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104eca:	8b 40 48             	mov    0x48(%eax),%eax
f0104ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ed1:	c7 04 24 78 94 10 f0 	movl   $0xf0109478,(%esp)
f0104ed8:	e8 6e f5 ff ff       	call   f010444b <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104edd:	89 34 24             	mov    %esi,(%esp)
f0104ee0:	e8 26 f7 ff ff       	call   f010460b <print_trapframe>
	env_destroy(curenv);
f0104ee5:	e8 28 21 00 00       	call   f0107012 <cpunum>
f0104eea:	6b c0 74             	imul   $0x74,%eax,%eax
f0104eed:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104ef1:	89 04 24             	mov    %eax,(%esp)
f0104ef4:	e8 d8 ef ff ff       	call   f0103ed1 <env_destroy>
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
f0104f19:	83 3d 8c 5e 27 f0 00 	cmpl   $0x0,0xf0275e8c
f0104f20:	74 01                	je     f0104f23 <trap+0x1d>
		asm volatile("hlt");
f0104f22:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
        uint32_t eflags;
        __asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104f23:	9c                   	pushf  
f0104f24:	58                   	pop    %eax
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104f25:	f6 c4 02             	test   $0x2,%ah
f0104f28:	74 24                	je     f0104f4e <trap+0x48>
f0104f2a:	c7 44 24 0c dd 92 10 	movl   $0xf01092dd,0xc(%esp)
f0104f31:	f0 
f0104f32:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0104f39:	f0 
f0104f3a:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
f0104f41:	00 
f0104f42:	c7 04 24 d1 92 10 f0 	movl   $0xf01092d1,(%esp)
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
f0104f5e:	e8 af 20 00 00       	call   f0107012 <cpunum>
f0104f63:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f66:	83 b8 28 80 27 f0 00 	cmpl   $0x0,-0xfd87fd8(%eax)
f0104f6d:	75 24                	jne    f0104f93 <trap+0x8d>
f0104f6f:	c7 44 24 0c f6 92 10 	movl   $0xf01092f6,0xc(%esp)
f0104f76:	f0 
f0104f77:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0104f7e:	f0 
f0104f7f:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
f0104f86:	00 
f0104f87:	c7 04 24 d1 92 10 f0 	movl   $0xf01092d1,(%esp)
f0104f8e:	e8 f2 b0 ff ff       	call   f0100085 <_panic>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104f93:	c7 04 24 80 53 12 f0 	movl   $0xf0125380,(%esp)
f0104f9a:	e8 36 24 00 00       	call   f01073d5 <spin_lock>
		lock_kernel();

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104f9f:	e8 6e 20 00 00       	call   f0107012 <cpunum>
f0104fa4:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa7:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0104fad:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104fb1:	75 2e                	jne    f0104fe1 <trap+0xdb>
			env_free(curenv);
f0104fb3:	e8 5a 20 00 00       	call   f0107012 <cpunum>
f0104fb8:	be 20 80 27 f0       	mov    $0xf0278020,%esi
f0104fbd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fc0:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0104fc4:	89 04 24             	mov    %eax,(%esp)
f0104fc7:	e8 33 ed ff ff       	call   f0103cff <env_free>
			curenv = NULL;
f0104fcc:	e8 41 20 00 00       	call   f0107012 <cpunum>
f0104fd1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fd4:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f0104fdb:	00 
			sched_yield();
f0104fdc:	e8 5f 02 00 00       	call   f0105240 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104fe1:	e8 2c 20 00 00       	call   f0107012 <cpunum>
f0104fe6:	bb 20 80 27 f0       	mov    $0xf0278020,%ebx
f0104feb:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fee:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104ff2:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104ff7:	89 c7                	mov    %eax,%edi
f0104ff9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104ffb:	e8 12 20 00 00       	call   f0107012 <cpunum>
f0105000:	6b c0 74             	imul   $0x74,%eax,%eax
f0105003:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0105007:	89 35 64 5a 27 f0    	mov    %esi,0xf0275a64
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f010500d:	8b 46 28             	mov    0x28(%esi),%eax
f0105010:	83 f8 27             	cmp    $0x27,%eax
f0105013:	75 19                	jne    f010502e <trap+0x128>
		cprintf("Spurious interrupt on irq 7\n");
f0105015:	c7 04 24 fd 92 10 f0 	movl   $0xf01092fd,(%esp)
f010501c:	e8 2a f4 ff ff       	call   f010444b <cprintf>
		print_trapframe(tf);
f0105021:	89 34 24             	mov    %esi,(%esp)
f0105024:	e8 e2 f5 ff ff       	call   f010460b <print_trapframe>
f0105029:	e9 9a 00 00 00       	jmp    f01050c8 <trap+0x1c2>
	// Add time tick increment to clock interrupts.
	// Be careful! In multiprocessors, clock interrupts are
	// triggered on every CPU.
	// LAB 6: Your code here.
	static int a = 0;
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f010502e:	83 f8 20             	cmp    $0x20,%eax
f0105031:	75 28                	jne    f010505b <trap+0x155>
		/* cprintf("%x gen clock int\n", curenv->env_id); */
		if (a == 0) {
f0105033:	83 3d 60 5a 27 f0 00 	cmpl   $0x0,0xf0275a60
f010503a:	75 05                	jne    f0105041 <trap+0x13b>
			time_tick();
f010503c:	e8 7d 2c 00 00       	call   f0107cbe <time_tick>
		}
		a = (a + 1) % ncpu;
f0105041:	8b 15 60 5a 27 f0    	mov    0xf0275a60,%edx
f0105047:	83 c2 01             	add    $0x1,%edx
f010504a:	89 d0                	mov    %edx,%eax
f010504c:	c1 fa 1f             	sar    $0x1f,%edx
f010504f:	f7 3d c4 83 27 f0    	idivl  0xf02783c4
f0105055:	89 15 60 5a 27 f0    	mov    %edx,0xf0275a60
	}

	//print_trapframe(tf);
	if (tf->tf_trapno == T_PGFLT)
f010505b:	83 7e 28 0e          	cmpl   $0xe,0x28(%esi)
f010505f:	75 08                	jne    f0105069 <trap+0x163>
		page_fault_handler(tf);
f0105061:	89 34 24             	mov    %esi,(%esp)
f0105064:	e8 fd fc ff ff       	call   f0104d66 <page_fault_handler>
	//cprintf("int2\n");	
	if (tf->tf_trapno == T_BRKPT)
f0105069:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f010506d:	75 08                	jne    f0105077 <trap+0x171>
		monitor(tf);
f010506f:	89 34 24             	mov    %esi,(%esp)
f0105072:	e8 ac ba ff ff       	call   f0100b23 <monitor>
	
	if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER )
f0105077:	83 7e 28 20          	cmpl   $0x20,0x28(%esi)
f010507b:	75 0a                	jne    f0105087 <trap+0x181>
	{
		lapic_eoi();
f010507d:	e8 c9 20 00 00       	call   f010714b <lapic_eoi>
		sched_yield();
f0105082:	e8 b9 01 00 00       	call   f0105240 <sched_yield>
	}
	
		
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0105087:	89 34 24             	mov    %esi,(%esp)
f010508a:	e8 7c f5 ff ff       	call   f010460b <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010508f:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0105094:	75 1c                	jne    f01050b2 <trap+0x1ac>
		panic("unhandled trap in kernel");
f0105096:	c7 44 24 08 1a 93 10 	movl   $0xf010931a,0x8(%esp)
f010509d:	f0 
f010509e:	c7 44 24 04 3b 01 00 	movl   $0x13b,0x4(%esp)
f01050a5:	00 
f01050a6:	c7 04 24 d1 92 10 f0 	movl   $0xf01092d1,(%esp)
f01050ad:	e8 d3 af ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f01050b2:	e8 5b 1f 00 00       	call   f0107012 <cpunum>
f01050b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01050ba:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f01050c0:	89 04 24             	mov    %eax,(%esp)
f01050c3:	e8 09 ee ff ff       	call   f0103ed1 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01050c8:	e8 45 1f 00 00       	call   f0107012 <cpunum>
f01050cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01050d0:	83 b8 28 80 27 f0 00 	cmpl   $0x0,-0xfd87fd8(%eax)
f01050d7:	74 2a                	je     f0105103 <trap+0x1fd>
f01050d9:	e8 34 1f 00 00       	call   f0107012 <cpunum>
f01050de:	6b c0 74             	imul   $0x74,%eax,%eax
f01050e1:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f01050e7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01050eb:	75 16                	jne    f0105103 <trap+0x1fd>
		env_run(curenv);
f01050ed:	e8 20 1f 00 00       	call   f0107012 <cpunum>
f01050f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01050f5:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f01050fb:	89 04 24             	mov    %eax,(%esp)
f01050fe:	e8 4e eb ff ff       	call   f0103c51 <env_run>
	else
		sched_yield();
f0105103:	e8 38 01 00 00       	call   f0105240 <sched_yield>

f0105108 <t_divide>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(t_divide,T_DIVIDE) 
f0105108:	6a 00                	push   $0x0
f010510a:	6a 00                	push   $0x0
f010510c:	e9 0b 01 00 00       	jmp    f010521c <_alltraps>
f0105111:	90                   	nop

f0105112 <t_debug>:
TRAPHANDLER_NOEC(t_debug,T_DEBUG) 
f0105112:	6a 00                	push   $0x0
f0105114:	6a 01                	push   $0x1
f0105116:	e9 01 01 00 00       	jmp    f010521c <_alltraps>
f010511b:	90                   	nop

f010511c <t_nmi>:
TRAPHANDLER_NOEC(t_nmi,T_NMI) 
f010511c:	6a 00                	push   $0x0
f010511e:	6a 02                	push   $0x2
f0105120:	e9 f7 00 00 00       	jmp    f010521c <_alltraps>
f0105125:	90                   	nop

f0105126 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt,T_BRKPT) 
f0105126:	6a 00                	push   $0x0
f0105128:	6a 03                	push   $0x3
f010512a:	e9 ed 00 00 00       	jmp    f010521c <_alltraps>
f010512f:	90                   	nop

f0105130 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow,T_OFLOW) 
f0105130:	6a 00                	push   $0x0
f0105132:	6a 04                	push   $0x4
f0105134:	e9 e3 00 00 00       	jmp    f010521c <_alltraps>
f0105139:	90                   	nop

f010513a <t_bound>:
TRAPHANDLER_NOEC(t_bound,T_BOUND) 
f010513a:	6a 00                	push   $0x0
f010513c:	6a 05                	push   $0x5
f010513e:	e9 d9 00 00 00       	jmp    f010521c <_alltraps>
f0105143:	90                   	nop

f0105144 <t_illop>:
TRAPHANDLER_NOEC(t_illop,T_ILLOP) 
f0105144:	6a 00                	push   $0x0
f0105146:	6a 06                	push   $0x6
f0105148:	e9 cf 00 00 00       	jmp    f010521c <_alltraps>
f010514d:	90                   	nop

f010514e <t_device>:
TRAPHANDLER_NOEC(t_device,T_DEVICE)
f010514e:	6a 00                	push   $0x0
f0105150:	6a 07                	push   $0x7
f0105152:	e9 c5 00 00 00       	jmp    f010521c <_alltraps>
f0105157:	90                   	nop

f0105158 <t_dblflt>:
TRAPHANDLER(t_dblflt,T_DBLFLT)
f0105158:	6a 08                	push   $0x8
f010515a:	e9 bd 00 00 00       	jmp    f010521c <_alltraps>
f010515f:	90                   	nop

f0105160 <t_tss>:
TRAPHANDLER(t_tss,T_TSS)
f0105160:	6a 0a                	push   $0xa
f0105162:	e9 b5 00 00 00       	jmp    f010521c <_alltraps>
f0105167:	90                   	nop

f0105168 <t_segnp>:
TRAPHANDLER(t_segnp,T_SEGNP)
f0105168:	6a 0b                	push   $0xb
f010516a:	e9 ad 00 00 00       	jmp    f010521c <_alltraps>
f010516f:	90                   	nop

f0105170 <t_stack>:
TRAPHANDLER(t_stack,T_STACK)
f0105170:	6a 0c                	push   $0xc
f0105172:	e9 a5 00 00 00       	jmp    f010521c <_alltraps>
f0105177:	90                   	nop

f0105178 <t_gpflt>:
TRAPHANDLER(t_gpflt,T_GPFLT)
f0105178:	6a 0d                	push   $0xd
f010517a:	e9 9d 00 00 00       	jmp    f010521c <_alltraps>
f010517f:	90                   	nop

f0105180 <t_pgflt>:
TRAPHANDLER(t_pgflt,T_PGFLT)
f0105180:	6a 0e                	push   $0xe
f0105182:	e9 95 00 00 00       	jmp    f010521c <_alltraps>
f0105187:	90                   	nop

f0105188 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr,T_FPERR)
f0105188:	6a 00                	push   $0x0
f010518a:	6a 10                	push   $0x10
f010518c:	e9 8b 00 00 00       	jmp    f010521c <_alltraps>
f0105191:	90                   	nop

f0105192 <t_align>:
TRAPHANDLER(t_align,T_ALIGN )
f0105192:	6a 11                	push   $0x11
f0105194:	e9 83 00 00 00       	jmp    f010521c <_alltraps>
f0105199:	90                   	nop

f010519a <t_mchk>:
TRAPHANDLER_NOEC(t_mchk,T_MCHK)
f010519a:	6a 00                	push   $0x0
f010519c:	6a 12                	push   $0x12
f010519e:	eb 7c                	jmp    f010521c <_alltraps>

f01051a0 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr,T_SIMDERR)
f01051a0:	6a 00                	push   $0x0
f01051a2:	6a 13                	push   $0x13
f01051a4:	eb 76                	jmp    f010521c <_alltraps>

f01051a6 <t_irq0>:

#for IRQ handler
TRAPHANDLER_NOEC(t_irq0,IRQ_OFFSET + 0)
f01051a6:	6a 00                	push   $0x0
f01051a8:	6a 20                	push   $0x20
f01051aa:	eb 70                	jmp    f010521c <_alltraps>

f01051ac <t_irq1>:
TRAPHANDLER_NOEC(t_irq1,IRQ_OFFSET + 1)
f01051ac:	6a 00                	push   $0x0
f01051ae:	6a 21                	push   $0x21
f01051b0:	eb 6a                	jmp    f010521c <_alltraps>

f01051b2 <t_irq2>:
TRAPHANDLER_NOEC(t_irq2,IRQ_OFFSET + 2)
f01051b2:	6a 00                	push   $0x0
f01051b4:	6a 22                	push   $0x22
f01051b6:	eb 64                	jmp    f010521c <_alltraps>

f01051b8 <t_irq3>:
TRAPHANDLER_NOEC(t_irq3,IRQ_OFFSET + 3)
f01051b8:	6a 00                	push   $0x0
f01051ba:	6a 23                	push   $0x23
f01051bc:	eb 5e                	jmp    f010521c <_alltraps>

f01051be <t_irq4>:
TRAPHANDLER_NOEC(t_irq4,IRQ_OFFSET + 4)
f01051be:	6a 00                	push   $0x0
f01051c0:	6a 24                	push   $0x24
f01051c2:	eb 58                	jmp    f010521c <_alltraps>

f01051c4 <t_irq5>:
TRAPHANDLER_NOEC(t_irq5,IRQ_OFFSET + 5)
f01051c4:	6a 00                	push   $0x0
f01051c6:	6a 25                	push   $0x25
f01051c8:	eb 52                	jmp    f010521c <_alltraps>

f01051ca <t_irq6>:
TRAPHANDLER_NOEC(t_irq6,IRQ_OFFSET + 6)
f01051ca:	6a 00                	push   $0x0
f01051cc:	6a 26                	push   $0x26
f01051ce:	eb 4c                	jmp    f010521c <_alltraps>

f01051d0 <t_irq7>:
TRAPHANDLER_NOEC(t_irq7,IRQ_OFFSET + 7)
f01051d0:	6a 00                	push   $0x0
f01051d2:	6a 27                	push   $0x27
f01051d4:	eb 46                	jmp    f010521c <_alltraps>

f01051d6 <t_irq8>:
TRAPHANDLER_NOEC(t_irq8,IRQ_OFFSET + 8)
f01051d6:	6a 00                	push   $0x0
f01051d8:	6a 28                	push   $0x28
f01051da:	eb 40                	jmp    f010521c <_alltraps>

f01051dc <t_irq9>:
TRAPHANDLER_NOEC(t_irq9,IRQ_OFFSET + 9)
f01051dc:	6a 00                	push   $0x0
f01051de:	6a 29                	push   $0x29
f01051e0:	eb 3a                	jmp    f010521c <_alltraps>

f01051e2 <t_irq10>:
TRAPHANDLER_NOEC(t_irq10,IRQ_OFFSET + 10)
f01051e2:	6a 00                	push   $0x0
f01051e4:	6a 2a                	push   $0x2a
f01051e6:	eb 34                	jmp    f010521c <_alltraps>

f01051e8 <t_irq11>:
TRAPHANDLER_NOEC(t_irq11,IRQ_OFFSET + 11)
f01051e8:	6a 00                	push   $0x0
f01051ea:	6a 2b                	push   $0x2b
f01051ec:	eb 2e                	jmp    f010521c <_alltraps>

f01051ee <t_irq12>:
TRAPHANDLER_NOEC(t_irq12,IRQ_OFFSET + 12)
f01051ee:	6a 00                	push   $0x0
f01051f0:	6a 2c                	push   $0x2c
f01051f2:	eb 28                	jmp    f010521c <_alltraps>

f01051f4 <t_irq13>:
TRAPHANDLER_NOEC(t_irq13,IRQ_OFFSET + 13)
f01051f4:	6a 00                	push   $0x0
f01051f6:	6a 2d                	push   $0x2d
f01051f8:	eb 22                	jmp    f010521c <_alltraps>

f01051fa <t_irq14>:
TRAPHANDLER_NOEC(t_irq14,IRQ_OFFSET + 14)
f01051fa:	6a 00                	push   $0x0
f01051fc:	6a 2e                	push   $0x2e
f01051fe:	eb 1c                	jmp    f010521c <_alltraps>

f0105200 <t_irq15>:
TRAPHANDLER_NOEC(t_irq15,IRQ_OFFSET + 15)
f0105200:	6a 00                	push   $0x0
f0105202:	6a 2f                	push   $0x2f
f0105204:	eb 16                	jmp    f010521c <_alltraps>

f0105206 <sysenter_handler>:
.align 2;
sysenter_handler:
/*
 * Lab 3: Your code here for system call handling
 */
 	pushl $0x0 /* parameters to syscall */
f0105206:	6a 00                	push   $0x0
	pushl %edi
f0105208:	57                   	push   %edi
	pushl %ebx
f0105209:	53                   	push   %ebx
	pushl %ecx
f010520a:	51                   	push   %ecx
	pushl %edx
f010520b:	52                   	push   %edx
	pushl %eax
f010520c:	50                   	push   %eax
	call syscall
f010520d:	e8 b7 01 00 00       	call   f01053c9 <syscall>
	addl $0x18, %esp /* kill all the parameters */
f0105212:	83 c4 18             	add    $0x18,%esp
	movl %esi, %edx
f0105215:	89 f2                	mov    %esi,%edx
	movl %ebp, %ecx
f0105217:	89 e9                	mov    %ebp,%ecx
	sti
f0105219:	fb                   	sti    
	sysexit
f010521a:	0f 35                	sysexit 

f010521c <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
 _alltraps:								
	pushw $0x0
f010521c:	66 6a 00             	pushw  $0x0
	pushw %ds
f010521f:	66 1e                	pushw  %ds
	pushw $0x0
f0105221:	66 6a 00             	pushw  $0x0
	pushw %es
f0105224:	66 06                	pushw  %es
	pushal
f0105226:	60                   	pusha  
	
	movl $GD_KD,%eax
f0105227:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax,%ds
f010522c:	8e d8                	mov    %eax,%ds
	movw %ax,%es							
f010522e:	8e c0                	mov    %eax,%es
	
	pushl %esp
f0105230:	54                   	push   %esp
	
	call trap
f0105231:	e8 d0 fc ff ff       	call   f0104f06 <trap>
	...

f0105240 <sched_yield>:


// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0105240:	55                   	push   %ebp
f0105241:	89 e5                	mov    %esp,%ebp
f0105243:	57                   	push   %edi
f0105244:	56                   	push   %esi
f0105245:	53                   	push   %ebx
f0105246:	83 ec 1c             	sub    $0x1c,%esp
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	int cnt = 0;
	for (i = curenv?(ENVX(curenv->env_id) + 1):0; cnt < NENV - 1; cnt++, i++) {
f0105249:	e8 c4 1d 00 00       	call   f0107012 <cpunum>
f010524e:	6b d0 74             	imul   $0x74,%eax,%edx
f0105251:	b8 00 00 00 00       	mov    $0x0,%eax
f0105256:	83 ba 28 80 27 f0 00 	cmpl   $0x0,-0xfd87fd8(%edx)
f010525d:	74 19                	je     f0105278 <sched_yield+0x38>
f010525f:	e8 ae 1d 00 00       	call   f0107012 <cpunum>
f0105264:	6b c0 74             	imul   $0x74,%eax,%eax
f0105267:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f010526d:	8b 40 48             	mov    0x48(%eax),%eax
f0105270:	25 ff 03 00 00       	and    $0x3ff,%eax
f0105275:	83 c0 01             	add    $0x1,%eax
		/* free env */
		if (i > NENV - 1)
			i = 0;
		if (envs[i].env_id == 0)
f0105278:	8b 3d 40 52 27 f0    	mov    0xf0275240,%edi
f010527e:	ba 00 00 00 00       	mov    $0x0,%edx

	// LAB 4: Your code here.
	int cnt = 0;
	for (i = curenv?(ENVX(curenv->env_id) + 1):0; cnt < NENV - 1; cnt++, i++) {
		/* free env */
		if (i > NENV - 1)
f0105283:	be 00 00 00 00       	mov    $0x0,%esi
f0105288:	3d 00 04 00 00       	cmp    $0x400,%eax
f010528d:	0f 4d c6             	cmovge %esi,%eax
			i = 0;
		if (envs[i].env_id == 0)
f0105290:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f0105293:	8d 0c 1f             	lea    (%edi,%ebx,1),%ecx
f0105296:	83 79 48 00          	cmpl   $0x0,0x48(%ecx)
f010529a:	74 29                	je     f01052c5 <sched_yield+0x85>
			continue;
		/* idle env or env running on other cpu */
		if (envs[i].env_type == ENV_TYPE_IDLE ||
f010529c:	83 79 50 01          	cmpl   $0x1,0x50(%ecx)
f01052a0:	74 23                	je     f01052c5 <sched_yield+0x85>
		    envs[i].env_status == ENV_RUNNING) {
f01052a2:	8b 49 54             	mov    0x54(%ecx),%ecx
		if (i > NENV - 1)
			i = 0;
		if (envs[i].env_id == 0)
			continue;
		/* idle env or env running on other cpu */
		if (envs[i].env_type == ENV_TYPE_IDLE ||
f01052a5:	83 f9 03             	cmp    $0x3,%ecx
f01052a8:	74 1b                	je     f01052c5 <sched_yield+0x85>
		    envs[i].env_status == ENV_RUNNING) {
			/* if (envs[i].env_type == ENV_TYPE_IDLE) */
			/* 	cprintf("skip an idle env\n"); */
			continue;
		}
		if (envs[i].env_status == ENV_RUNNABLE) {
f01052aa:	83 f9 02             	cmp    $0x2,%ecx
f01052ad:	8d 76 00             	lea    0x0(%esi),%esi
f01052b0:	75 13                	jne    f01052c5 <sched_yield+0x85>
			curenv->env_status == ENV_RUNNABLE;
f01052b2:	e8 5b 1d 00 00       	call   f0107012 <cpunum>
			//cprintf("%s:sched_yield[%d]: yield to [%x]\n", __FILE__, __LINE__, envs[i].env_id);
			env_run(&envs[i]);
f01052b7:	03 1d 40 52 27 f0    	add    0xf0275240,%ebx
f01052bd:	89 1c 24             	mov    %ebx,(%esp)
f01052c0:	e8 8c e9 ff ff       	call   f0103c51 <env_run>
	// no runnable environments, simply drop through to the code
	// below to switch to this CPU's idle environment.

	// LAB 4: Your code here.
	int cnt = 0;
	for (i = curenv?(ENVX(curenv->env_id) + 1):0; cnt < NENV - 1; cnt++, i++) {
f01052c5:	83 c2 01             	add    $0x1,%edx
f01052c8:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
f01052ce:	74 05                	je     f01052d5 <sched_yield+0x95>
f01052d0:	83 c0 01             	add    $0x1,%eax
f01052d3:	eb b3                	jmp    f0105288 <sched_yield+0x48>
			//cprintf("%s:sched_yield[%d]: yield to [%x]\n", __FILE__, __LINE__, envs[i].env_id);
			env_run(&envs[i]);
		}
		continue;
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
f01052d5:	e8 38 1d 00 00       	call   f0107012 <cpunum>
f01052da:	6b c0 74             	imul   $0x74,%eax,%eax
f01052dd:	83 b8 28 80 27 f0 00 	cmpl   $0x0,-0xfd87fd8(%eax)
f01052e4:	74 14                	je     f01052fa <sched_yield+0xba>
f01052e6:	e8 27 1d 00 00       	call   f0107012 <cpunum>
f01052eb:	6b c0 74             	imul   $0x74,%eax,%eax
f01052ee:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f01052f4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01052f8:	74 0f                	je     f0105309 <sched_yield+0xc9>

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f01052fa:	8b 1d 40 52 27 f0    	mov    0xf0275240,%ebx
f0105300:	89 d8                	mov    %ebx,%eax
f0105302:	ba 00 00 00 00       	mov    $0x0,%edx
f0105307:	eb 16                	jmp    f010531f <sched_yield+0xdf>
			env_run(&envs[i]);
		}
		continue;
	}
	if (curenv && curenv->env_status == ENV_RUNNING) {
		env_run(curenv);
f0105309:	e8 04 1d 00 00       	call   f0107012 <cpunum>
f010530e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105311:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105317:	89 04 24             	mov    %eax,(%esp)
f010531a:	e8 32 e9 ff ff       	call   f0103c51 <env_run>

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if (envs[i].env_type != ENV_TYPE_IDLE &&
f010531f:	83 78 50 01          	cmpl   $0x1,0x50(%eax)
f0105323:	74 0b                	je     f0105330 <sched_yield+0xf0>
f0105325:	8b 48 54             	mov    0x54(%eax),%ecx
f0105328:	83 e9 02             	sub    $0x2,%ecx
f010532b:	83 f9 01             	cmp    $0x1,%ecx
f010532e:	76 10                	jbe    f0105340 <sched_yield+0x100>
	}

	// For debugging and testing purposes, if there are no
	// runnable environments other than the idle environments,
	// drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0105330:	83 c2 01             	add    $0x1,%edx
f0105333:	83 c0 7c             	add    $0x7c,%eax
f0105336:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f010533c:	75 e1                	jne    f010531f <sched_yield+0xdf>
f010533e:	eb 08                	jmp    f0105348 <sched_yield+0x108>
		if (envs[i].env_type != ENV_TYPE_IDLE &&
		    (envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f0105340:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0105346:	75 1a                	jne    f0105362 <sched_yield+0x122>
		cprintf("No more runnable environments!\n");
f0105348:	c7 04 24 f0 94 10 f0 	movl   $0xf01094f0,(%esp)
f010534f:	e8 f7 f0 ff ff       	call   f010444b <cprintf>
		while (1)
			monitor(NULL);
f0105354:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010535b:	e8 c3 b7 ff ff       	call   f0100b23 <monitor>
f0105360:	eb f2                	jmp    f0105354 <sched_yield+0x114>
	}

	// Run this CPU's idle environment when nothing else is runnable.
	idle = &envs[cpunum()];
f0105362:	e8 ab 1c 00 00       	call   f0107012 <cpunum>
f0105367:	6b c0 7c             	imul   $0x7c,%eax,%eax
f010536a:	01 c3                	add    %eax,%ebx
	if (!(idle->env_status == ENV_RUNNABLE || idle->env_status == ENV_RUNNING))
f010536c:	8b 43 54             	mov    0x54(%ebx),%eax
f010536f:	83 e8 02             	sub    $0x2,%eax
f0105372:	83 f8 01             	cmp    $0x1,%eax
f0105375:	76 25                	jbe    f010539c <sched_yield+0x15c>
		panic("CPU %d: No idle environment!", cpunum());
f0105377:	e8 96 1c 00 00       	call   f0107012 <cpunum>
f010537c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105380:	c7 44 24 08 10 95 10 	movl   $0xf0109510,0x8(%esp)
f0105387:	f0 
f0105388:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
f010538f:	00 
f0105390:	c7 04 24 2d 95 10 f0 	movl   $0xf010952d,(%esp)
f0105397:	e8 e9 ac ff ff       	call   f0100085 <_panic>
	env_run(idle);
f010539c:	89 1c 24             	mov    %ebx,(%esp)
f010539f:	e8 ad e8 ff ff       	call   f0103c51 <env_run>
	...

f01053b0 <sys_getenvid>:
}

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
f01053b0:	55                   	push   %ebp
f01053b1:	89 e5                	mov    %esp,%ebp
f01053b3:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f01053b6:	e8 57 1c 00 00       	call   f0107012 <cpunum>
f01053bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01053be:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f01053c4:	8b 40 48             	mov    0x48(%eax),%eax
}
f01053c7:	c9                   	leave  
f01053c8:	c3                   	ret    

f01053c9 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01053c9:	55                   	push   %ebp
f01053ca:	89 e5                	mov    %esp,%ebp
f01053cc:	57                   	push   %edi
f01053cd:	56                   	push   %esi
f01053ce:	53                   	push   %ebx
f01053cf:	83 ec 2c             	sub    $0x2c,%esp
f01053d2:	c7 04 24 80 53 12 f0 	movl   $0xf0125380,(%esp)
f01053d9:	e8 f7 1f 00 00       	call   f01073d5 <spin_lock>
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t r = 0,perm = 0;
	lock_kernel();
	asm volatile(	"movl (%%ebp),%%eax\n"
					:"=a" (curenv->env_tf.tf_regs.reg_ecx),
f01053de:	e8 2f 1c 00 00       	call   f0107012 <cpunum>
f01053e3:	bf 20 80 27 f0       	mov    $0xf0278020,%edi
f01053e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01053eb:	8b 5c 38 08          	mov    0x8(%eax,%edi,1),%ebx
					 "=S" (curenv->env_tf.tf_regs.reg_edx)
f01053ef:	e8 1e 1c 00 00       	call   f0107012 <cpunum>
f01053f4:	89 c2                	mov    %eax,%edx
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t r = 0,perm = 0;
	lock_kernel();
	asm volatile(	"movl (%%ebp),%%eax\n"
f01053f6:	8b 45 00             	mov    0x0(%ebp),%eax
f01053f9:	89 43 18             	mov    %eax,0x18(%ebx)
f01053fc:	6b d2 74             	imul   $0x74,%edx,%edx
f01053ff:	8b 44 3a 08          	mov    0x8(%edx,%edi,1),%eax
f0105403:	89 70 14             	mov    %esi,0x14(%eax)
					:"=a" (curenv->env_tf.tf_regs.reg_ecx),
					 "=S" (curenv->env_tf.tf_regs.reg_edx)
					);
	curenv->env_tf.tf_trapno = T_SYSCALL;
f0105406:	e8 07 1c 00 00       	call   f0107012 <cpunum>
f010540b:	6b c0 74             	imul   $0x74,%eax,%eax
f010540e:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105412:	c7 40 28 30 00 00 00 	movl   $0x30,0x28(%eax)
	curenv->env_tf.tf_eflags |= FL_IF;
f0105419:	e8 f4 1b 00 00       	call   f0107012 <cpunum>
f010541e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105421:	8b 44 38 08          	mov    0x8(%eax,%edi,1),%eax
f0105425:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
	switch (syscallno) {
f010542c:	83 7d 08 10          	cmpl   $0x10,0x8(%ebp)
f0105430:	0f 87 89 07 00 00    	ja     f0105bbf <syscall+0x7f6>
f0105436:	8b 45 08             	mov    0x8(%ebp),%eax
f0105439:	ff 24 85 50 95 10 f0 	jmp    *-0xfef6ab0(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert (curenv, s, len, PTE_U);
f0105440:	e8 cd 1b 00 00       	call   f0107012 <cpunum>
f0105445:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f010544c:	00 
f010544d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105450:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105454:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105457:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010545b:	6b c0 74             	imul   $0x74,%eax,%eax
f010545e:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105464:	89 04 24             	mov    %eax,(%esp)
f0105467:	e8 76 c4 ff ff       	call   f01018e2 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010546c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010546f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105473:	8b 55 10             	mov    0x10(%ebp),%edx
f0105476:	89 54 24 04          	mov    %edx,0x4(%esp)
f010547a:	c7 04 24 3a 95 10 f0 	movl   $0xf010953a,(%esp)
f0105481:	e8 c5 ef ff ff       	call   f010444b <cprintf>
f0105486:	be 00 00 00 00       	mov    $0x0,%esi
f010548b:	e9 34 07 00 00       	jmp    f0105bc4 <syscall+0x7fb>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0105490:	e8 17 b0 ff ff       	call   f01004ac <cons_getc>
f0105495:	89 c6                	mov    %eax,%esi
	case SYS_cputs:
		sys_cputs ((const char*) a1, (size_t)a2); 
		break;
	case SYS_cgetc:
		r = sys_cgetc (); 
		break;
f0105497:	e9 28 07 00 00       	jmp    f0105bc4 <syscall+0x7fb>
	case SYS_getenvid:
		r = sys_getenvid (); 
f010549c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01054a0:	e8 0b ff ff ff       	call   f01053b0 <sys_getenvid>
f01054a5:	89 c6                	mov    %eax,%esi
		break;
f01054a7:	e9 18 07 00 00       	jmp    f0105bc4 <syscall+0x7fb>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f01054ac:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01054b3:	00 
f01054b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01054b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01054be:	89 0c 24             	mov    %ecx,(%esp)
f01054c1:	e8 24 e6 ff ff       	call   f0103aea <envid2env>
f01054c6:	89 c6                	mov    %eax,%esi
f01054c8:	85 c0                	test   %eax,%eax
f01054ca:	0f 88 f4 06 00 00    	js     f0105bc4 <syscall+0x7fb>
		return r;
	env_destroy(e);
f01054d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054d3:	89 04 24             	mov    %eax,(%esp)
f01054d6:	e8 f6 e9 ff ff       	call   f0103ed1 <env_destroy>
f01054db:	be 00 00 00 00       	mov    $0x0,%esi
f01054e0:	e9 df 06 00 00       	jmp    f0105bc4 <syscall+0x7fb>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01054e5:	81 7d 0c ff ff ff ef 	cmpl   $0xefffffff,0xc(%ebp)
f01054ec:	77 23                	ja     f0105511 <syscall+0x148>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01054ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01054f5:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01054fc:	f0 
f01054fd:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
f0105504:	00 
f0105505:	c7 04 24 3f 95 10 f0 	movl   $0xf010953f,(%esp)
f010550c:	e8 74 ab ff ff       	call   f0100085 <_panic>
}

static inline struct Page*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105514:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f010551a:	c1 eb 0c             	shr    $0xc,%ebx
f010551d:	3b 1d 94 5e 27 f0    	cmp    0xf0275e94,%ebx
f0105523:	72 1c                	jb     f0105541 <syscall+0x178>
		panic("pa2page called with invalid pa");
f0105525:	c7 44 24 08 48 86 10 	movl   $0xf0108648,0x8(%esp)
f010552c:	f0 
f010552d:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
f0105534:	00 
f0105535:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f010553c:	e8 44 ab ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f0105541:	c1 e3 03             	shl    $0x3,%ebx
static int
sys_map_kernel_page(void* kpage, void* va)
{
	int r;
	struct Page* p = pa2page(PADDR(kpage));
	if(p ==NULL)
f0105544:	be 03 00 00 00       	mov    $0x3,%esi
f0105549:	03 1d 9c 5e 27 f0    	add    0xf0275e9c,%ebx
f010554f:	0f 84 6f 06 00 00    	je     f0105bc4 <syscall+0x7fb>
		return E_INVAL;
	r = page_insert(curenv->env_pgdir, p, va, PTE_U | PTE_W);
f0105555:	e8 b8 1a 00 00       	call   f0107012 <cpunum>
f010555a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0105561:	00 
f0105562:	8b 55 10             	mov    0x10(%ebp),%edx
f0105565:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105569:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010556d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105570:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105576:	8b 40 60             	mov    0x60(%eax),%eax
f0105579:	89 04 24             	mov    %eax,(%esp)
f010557c:	e8 76 c4 ff ff       	call   f01019f7 <page_insert>
f0105581:	89 c6                	mov    %eax,%esi
f0105583:	e9 3c 06 00 00       	jmp    f0105bc4 <syscall+0x7fb>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0105588:	e8 b3 fc ff ff       	call   f0105240 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	struct Env *newenv;
	int r;
	if((r = env_alloc(&newenv,sys_getenvid()))<0)
f010558d:	8d 76 00             	lea    0x0(%esi),%esi
f0105590:	e8 1b fe ff ff       	call   f01053b0 <sys_getenvid>
f0105595:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105599:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010559c:	89 04 24             	mov    %eax,(%esp)
f010559f:	e8 8b e9 ff ff       	call   f0103f2f <env_alloc>
f01055a4:	89 c6                	mov    %eax,%esi
f01055a6:	85 c0                	test   %eax,%eax
f01055a8:	0f 88 16 06 00 00    	js     f0105bc4 <syscall+0x7fb>
		return r;
	newenv->env_status = ENV_NOT_RUNNABLE;
f01055ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055b1:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	
	//env_pop_tf as sysexit
	newenv->env_tf.tf_regs.reg_ecx = curenv->env_tf.tf_regs.reg_ecx;
f01055b8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01055bb:	e8 52 1a 00 00       	call   f0107012 <cpunum>
f01055c0:	bb 20 80 27 f0       	mov    $0xf0278020,%ebx
f01055c5:	6b c0 74             	imul   $0x74,%eax,%eax
f01055c8:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01055cc:	8b 40 18             	mov    0x18(%eax),%eax
f01055cf:	89 46 18             	mov    %eax,0x18(%esi)
	newenv->env_tf.tf_regs.reg_edx = curenv->env_tf.tf_regs.reg_edx;
f01055d2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01055d5:	e8 38 1a 00 00       	call   f0107012 <cpunum>
f01055da:	6b c0 74             	imul   $0x74,%eax,%eax
f01055dd:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01055e1:	8b 40 14             	mov    0x14(%eax),%eax
f01055e4:	89 46 14             	mov    %eax,0x14(%esi)
	newenv->env_tf.tf_regs.reg_eax = 0;
f01055e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055ea:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	newenv->env_tf.tf_eflags |= FL_IF;
f01055f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055f4:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
	newenv->env_tf.tf_trapno = T_SYSCALL;
f01055fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055fe:	c7 40 28 30 00 00 00 	movl   $0x30,0x28(%eax)
	return newenv->env_id;
f0105605:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105608:	8b 70 48             	mov    0x48(%eax),%esi
f010560b:	e9 b4 05 00 00       	jmp    f0105bc4 <syscall+0x7fb>
		break;
	case SYS_exofork:
		r= sys_exofork();
		break;
	case SYS_env_set_status:
		r= sys_env_set_status((envid_t)a1,(int)a2);
f0105610:	8b 45 10             	mov    0x10(%ebp),%eax
	// You should set envid2env's third argument to 1, which will
	// check whether the current environment has permission to set
	// envid's status.

	// LAB 4: Your code here.
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f0105613:	83 f8 02             	cmp    $0x2,%eax
f0105616:	74 0e                	je     f0105626 <syscall+0x25d>
f0105618:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f010561d:	83 f8 04             	cmp    $0x4,%eax
f0105620:	0f 85 9e 05 00 00    	jne    f0105bc4 <syscall+0x7fb>
		return -E_INVAL;
	struct Env *envptr;
	int r;
	if((r = envid2env(envid,&envptr,1))<0)
f0105626:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010562d:	00 
f010562e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105631:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105638:	89 0c 24             	mov    %ecx,(%esp)
f010563b:	e8 aa e4 ff ff       	call   f0103aea <envid2env>
f0105640:	89 c6                	mov    %eax,%esi
f0105642:	85 c0                	test   %eax,%eax
f0105644:	0f 88 7a 05 00 00    	js     f0105bc4 <syscall+0x7fb>
		return r;
	envptr->env_status = status;
f010564a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010564d:	8b 55 10             	mov    0x10(%ebp),%edx
f0105650:	89 50 54             	mov    %edx,0x54(%eax)
	print_trapframe(&envptr->env_tf);
f0105653:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105656:	89 04 24             	mov    %eax,(%esp)
f0105659:	e8 ad ef ff ff       	call   f010460b <print_trapframe>
f010565e:	be 00 00 00 00       	mov    $0x0,%esi
f0105663:	e9 5c 05 00 00       	jmp    f0105bc4 <syscall+0x7fb>
		break;
	case SYS_env_set_status:
		r= sys_env_set_status((envid_t)a1,(int)a2);
		break;
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0105668:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	if(va >= (void *)UTOP)
f010566b:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105671:	0f 87 ed 00 00 00    	ja     f0105764 <syscall+0x39b>
		return -E_INVAL;
	if( (perm & PTE_U) == 0 || (perm & PTE_P)==0)
f0105677:	8b 45 14             	mov    0x14(%ebp),%eax
f010567a:	83 e0 05             	and    $0x5,%eax
f010567d:	83 f8 05             	cmp    $0x5,%eax
f0105680:	0f 85 de 00 00 00    	jne    f0105764 <syscall+0x39b>
		break;
	case SYS_env_set_status:
		r= sys_env_set_status((envid_t)a1,(int)a2);
		break;
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
f0105686:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	if(va >= (void *)UTOP)
		return -E_INVAL;
	if( (perm & PTE_U) == 0 || (perm & PTE_P)==0)
		return -E_INVAL;
	if( (perm & ~PTE_SYSCALL) != 0)
f0105689:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f010568f:	0f 85 cf 00 00 00    	jne    f0105764 <syscall+0x39b>
		return -E_INVAL;
		
	struct Env *e;
	if(envid2env(envid,&e,1)<0)
f0105695:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010569c:	00 
f010569d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01056a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056a7:	89 0c 24             	mov    %ecx,(%esp)
f01056aa:	e8 3b e4 ff ff       	call   f0103aea <envid2env>
f01056af:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01056b4:	85 c0                	test   %eax,%eax
f01056b6:	0f 88 08 05 00 00    	js     f0105bc4 <syscall+0x7fb>
		return -E_BAD_ENV;
	
	struct Page *p;
	if( (p = page_alloc(ALLOC_ZERO)) == NULL)
f01056bc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01056c3:	e8 e6 bf ff ff       	call   f01016ae <page_alloc>
f01056c8:	89 c6                	mov    %eax,%esi
f01056ca:	85 c0                	test   %eax,%eax
f01056cc:	0f 84 92 00 00 00    	je     f0105764 <syscall+0x39b>
		return -E_INVAL;
	if(page_insert(e->env_pgdir,p,va,perm) < 0)
f01056d2:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01056d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01056da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056e1:	8b 40 60             	mov    0x60(%eax),%eax
f01056e4:	89 04 24             	mov    %eax,(%esp)
f01056e7:	e8 0b c3 ff ff       	call   f01019f7 <page_insert>
f01056ec:	85 c0                	test   %eax,%eax
f01056ee:	79 12                	jns    f0105702 <syscall+0x339>
	{
		page_free(p);
f01056f0:	89 34 24             	mov    %esi,(%esp)
f01056f3:	e8 9f b6 ff ff       	call   f0100d97 <page_free>
f01056f8:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f01056fd:	e9 c2 04 00 00       	jmp    f0105bc4 <syscall+0x7fb>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct Page *pp)
{
	return (pp - pages) << PGSHIFT;
f0105702:	89 f0                	mov    %esi,%eax
f0105704:	2b 05 9c 5e 27 f0    	sub    0xf0275e9c,%eax
f010570a:	c1 f8 03             	sar    $0x3,%eax
f010570d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105710:	89 c2                	mov    %eax,%edx
f0105712:	c1 ea 0c             	shr    $0xc,%edx
f0105715:	3b 15 94 5e 27 f0    	cmp    0xf0275e94,%edx
f010571b:	72 20                	jb     f010573d <syscall+0x374>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010571d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105721:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0105728:	f0 
f0105729:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105730:	00 
f0105731:	c7 04 24 ad 8c 10 f0 	movl   $0xf0108cad,(%esp)
f0105738:	e8 48 a9 ff ff       	call   f0100085 <_panic>
		return -E_NO_MEM;
	}
	memset(page2kva(p),0,PGSIZE);
f010573d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0105744:	00 
f0105745:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010574c:	00 
f010574d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0105752:	89 04 24             	mov    %eax,(%esp)
f0105755:	e8 0c 12 00 00       	call   f0106966 <memset>
f010575a:	be 00 00 00 00       	mov    $0x0,%esi
f010575f:	e9 60 04 00 00       	jmp    f0105bc4 <syscall+0x7fb>
f0105764:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105769:	e9 56 04 00 00       	jmp    f0105bc4 <syscall+0x7fb>
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		break;
	case SYS_page_map:
		perm = a4 & 0xfff;
		a4 &= ~0xfff;
		r= sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,perm);
f010576e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if(	srcva >= (void *)UTOP || ROUNDUP(srcva,PGSIZE) != srcva ||
f0105771:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105777:	0f 87 e5 00 00 00    	ja     f0105862 <syscall+0x499>
f010577d:	89 d8                	mov    %ebx,%eax
f010577f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0105784:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0105789:	39 c3                	cmp    %eax,%ebx
f010578b:	0f 85 d1 00 00 00    	jne    f0105862 <syscall+0x499>
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		break;
	case SYS_page_map:
		perm = a4 & 0xfff;
		a4 &= ~0xfff;
f0105791:	8b 45 18             	mov    0x18(%ebp),%eax
f0105794:	25 00 f0 ff ff       	and    $0xfffff000,%eax
		r= sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,perm);
f0105799:	89 c7                	mov    %eax,%edi
	//   Use the third argument to page_lookup() to
	//   check the current permissions on the page.

	// LAB 4: Your code here.

	if(	srcva >= (void *)UTOP || ROUNDUP(srcva,PGSIZE) != srcva ||
f010579b:	3d ff ff bf ee       	cmp    $0xeebfffff,%eax
f01057a0:	0f 87 bc 00 00 00    	ja     f0105862 <syscall+0x499>
f01057a6:	39 c0                	cmp    %eax,%eax
f01057a8:	0f 85 b4 00 00 00    	jne    f0105862 <syscall+0x499>
		break;
	case SYS_page_alloc:
		r= sys_page_alloc((envid_t)a1,(void*)a2,(int)a3);
		break;
	case SYS_page_map:
		perm = a4 & 0xfff;
f01057ae:	8b 75 18             	mov    0x18(%ebp),%esi
f01057b1:	81 e6 ff 0f 00 00    	and    $0xfff,%esi

	if(	srcva >= (void *)UTOP || ROUNDUP(srcva,PGSIZE) != srcva ||
		dstva >= (void *)UTOP || ROUNDUP(dstva,PGSIZE) != dstva )
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk0\n");
	if( (perm & PTE_U) == 0 || (perm & PTE_P)==0)
f01057b7:	8b 45 18             	mov    0x18(%ebp),%eax
f01057ba:	83 e0 05             	and    $0x5,%eax
f01057bd:	83 f8 05             	cmp    $0x5,%eax
f01057c0:	0f 85 9c 00 00 00    	jne    f0105862 <syscall+0x499>
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk1\n");
	if( (perm & ~PTE_SYSCALL) > 0)
f01057c6:	f7 c6 f8 f1 ff ff    	test   $0xfffff1f8,%esi
f01057cc:	0f 85 90 00 00 00    	jne    f0105862 <syscall+0x499>
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk2\n");
	struct Env *srce,*dste;
	if(	envid2env(srcenvid,&srce,1) < 0 ||
f01057d2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01057d9:	00 
f01057da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01057dd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01057e4:	89 04 24             	mov    %eax,(%esp)
f01057e7:	e8 fe e2 ff ff       	call   f0103aea <envid2env>
f01057ec:	85 c0                	test   %eax,%eax
f01057ee:	78 7c                	js     f010586c <syscall+0x4a3>
		envid2env(dstenvid,&dste,1) < 0)
f01057f0:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01057f7:	00 
f01057f8:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01057fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01057ff:	8b 55 14             	mov    0x14(%ebp),%edx
f0105802:	89 14 24             	mov    %edx,(%esp)
f0105805:	e8 e0 e2 ff ff       	call   f0103aea <envid2env>
	//cprintf("kkkkkkkkkkkkkkkkkk1\n");
	if( (perm & ~PTE_SYSCALL) > 0)
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk2\n");
	struct Env *srce,*dste;
	if(	envid2env(srcenvid,&srce,1) < 0 ||
f010580a:	85 c0                	test   %eax,%eax
f010580c:	78 5e                	js     f010586c <syscall+0x4a3>
		envid2env(dstenvid,&dste,1) < 0)
		return -E_BAD_ENV;
	//cprintf("kkkkkkkkkkkkkkkkkk3\n");
	struct Page* p;
	pte_t* pte_store;
	p = page_lookup(srce->env_pgdir,srcva,&pte_store);
f010580e:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105811:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105815:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010581c:	8b 40 60             	mov    0x60(%eax),%eax
f010581f:	89 04 24             	mov    %eax,(%esp)
f0105822:	e8 13 c1 ff ff       	call   f010193a <page_lookup>
	//cprintf("kkkkkkkkkkkkkkkkkk3.5\n");
	if(	p == NULL || 
f0105827:	85 c0                	test   %eax,%eax
f0105829:	74 37                	je     f0105862 <syscall+0x499>
f010582b:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0105831:	74 08                	je     f010583b <syscall+0x472>
f0105833:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105836:	f6 02 02             	testb  $0x2,(%edx)
f0105839:	74 27                	je     f0105862 <syscall+0x499>
		((perm & PTE_W) >0 && (*pte_store & PTE_W) == 0))
		return -E_INVAL;
	//cprintf("kkkkkkkkkkkkkkkkkk4\n");
	if(page_insert(dste->env_pgdir,p,dstva,perm)<0)
f010583b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010583f:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105843:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105847:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010584a:	8b 40 60             	mov    0x60(%eax),%eax
f010584d:	89 04 24             	mov    %eax,(%esp)
f0105850:	e8 a2 c1 ff ff       	call   f01019f7 <page_insert>
f0105855:	89 c6                	mov    %eax,%esi
f0105857:	c1 fe 1f             	sar    $0x1f,%esi
f010585a:	83 e6 fc             	and    $0xfffffffc,%esi
f010585d:	e9 62 03 00 00       	jmp    f0105bc4 <syscall+0x7fb>
f0105862:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105867:	e9 58 03 00 00       	jmp    f0105bc4 <syscall+0x7fb>
f010586c:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105871:	e9 4e 03 00 00       	jmp    f0105bc4 <syscall+0x7fb>
		perm = a4 & 0xfff;
		a4 &= ~0xfff;
		r= sys_page_map((envid_t)a1,(void*)a2,(envid_t)a3,(void*)a4,perm);
		break;
	case SYS_page_unmap:
		r= sys_page_unmap((envid_t)a1,(void*)a2);
f0105876:	8b 5d 10             	mov    0x10(%ebp),%ebx
sys_page_unmap(envid_t envid, void *va)
{
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	if(va >= (void*)UTOP || ROUNDUP(va,PGSIZE) != va)
f0105879:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f010587f:	90                   	nop
f0105880:	77 53                	ja     f01058d5 <syscall+0x50c>
f0105882:	89 d8                	mov    %ebx,%eax
f0105884:	05 ff 0f 00 00       	add    $0xfff,%eax
f0105889:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010588e:	39 c3                	cmp    %eax,%ebx
f0105890:	75 43                	jne    f01058d5 <syscall+0x50c>
		return -E_INVAL;
	struct Env* e;
	if(envid2env(envid,&e,1)<0)
f0105892:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105899:	00 
f010589a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010589d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01058a4:	89 0c 24             	mov    %ecx,(%esp)
f01058a7:	e8 3e e2 ff ff       	call   f0103aea <envid2env>
f01058ac:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01058b1:	85 c0                	test   %eax,%eax
f01058b3:	0f 88 0b 03 00 00    	js     f0105bc4 <syscall+0x7fb>
		return -E_BAD_ENV;
	page_remove(e->env_pgdir,va);
f01058b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01058c0:	8b 40 60             	mov    0x60(%eax),%eax
f01058c3:	89 04 24             	mov    %eax,(%esp)
f01058c6:	e8 dc c0 ff ff       	call   f01019a7 <page_remove>
f01058cb:	be 00 00 00 00       	mov    $0x0,%esi
f01058d0:	e9 ef 02 00 00       	jmp    f0105bc4 <syscall+0x7fb>
f01058d5:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f01058da:	e9 e5 02 00 00       	jmp    f0105bc4 <syscall+0x7fb>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	struct Env* e;
	if(envid2env(envid,&e,1)<0)
f01058df:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01058e6:	00 
f01058e7:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01058ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058f1:	89 04 24             	mov    %eax,(%esp)
f01058f4:	e8 f1 e1 ff ff       	call   f0103aea <envid2env>
f01058f9:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01058fe:	85 c0                	test   %eax,%eax
f0105900:	0f 88 be 02 00 00    	js     f0105bc4 <syscall+0x7fb>
		return -E_BAD_ENV;
	e->env_pgfault_upcall = func;
f0105906:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105909:	8b 55 10             	mov    0x10(%ebp),%edx
f010590c:	89 50 64             	mov    %edx,0x64(%eax)
f010590f:	be 00 00 00 00       	mov    $0x0,%esi
f0105914:	e9 ab 02 00 00       	jmp    f0105bc4 <syscall+0x7fb>
		break;
	case SYS_env_set_pgfault_upcall:
		r = sys_env_set_pgfault_upcall((envid_t)a1,(void*)a2);
		break;
	case SYS_ipc_recv:
		r = sys_ipc_recv((void*)a1);
f0105919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
 if (dstva < (void *) UTOP && ROUNDDOWN (dstva, PGSIZE) != dstva)
f010591c:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0105922:	77 0f                	ja     f0105933 <syscall+0x56a>
f0105924:	89 d8                	mov    %ebx,%eax
f0105926:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010592b:	39 c3                	cmp    %eax,%ebx
f010592d:	0f 85 8c 02 00 00    	jne    f0105bbf <syscall+0x7f6>
		return -E_INVAL;
	curenv->env_ipc_dstva = dstva;
f0105933:	e8 da 16 00 00       	call   f0107012 <cpunum>
f0105938:	be 20 80 27 f0       	mov    $0xf0278020,%esi
f010593d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105940:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0105944:	89 58 6c             	mov    %ebx,0x6c(%eax)
	curenv->env_ipc_recving = 1;
f0105947:	e8 c6 16 00 00       	call   f0107012 <cpunum>
f010594c:	6b c0 74             	imul   $0x74,%eax,%eax
f010594f:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0105953:	c7 40 68 01 00 00 00 	movl   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f010595a:	e8 b3 16 00 00       	call   f0107012 <cpunum>
f010595f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105962:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0105966:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f010596d:	e8 a0 16 00 00       	call   f0107012 <cpunum>
f0105972:	6b c0 74             	imul   $0x74,%eax,%eax
f0105975:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f0105979:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	sched_yield();
f0105980:	e8 bb f8 ff ff       	call   f0105240 <sched_yield>
{
	// LAB 4: Your code here.
  struct Env* dste;
	int r;
	//envid doesn't currently exist.
	if((r = envid2env(envid,&dste,0)) < 0)
f0105985:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010598c:	00 
f010598d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105990:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105994:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105997:	89 0c 24             	mov    %ecx,(%esp)
f010599a:	e8 4b e1 ff ff       	call   f0103aea <envid2env>
f010599f:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f01059a4:	85 c0                	test   %eax,%eax
f01059a6:	0f 88 18 02 00 00    	js     f0105bc4 <syscall+0x7fb>
		return -E_BAD_ENV;
	//envid is not currently blocked in sys_ipc_recv,
	//or another environment managed to send first.
	if(!dste->env_ipc_recving || dste->env_ipc_from != 0)
f01059ac:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01059af:	83 78 68 00          	cmpl   $0x0,0x68(%eax)
f01059b3:	0f 84 0e 01 00 00    	je     f0105ac7 <syscall+0x6fe>
f01059b9:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f01059bd:	0f 85 04 01 00 00    	jne    f0105ac7 <syscall+0x6fe>
		break;
	case SYS_ipc_recv:
		r = sys_ipc_recv((void*)a1);
		break;
	case SYS_ipc_try_send:
		r = sys_ipc_try_send((envid_t)a1,a2,(void*)a3,(int)a4);
f01059c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	//envid is not currently blocked in sys_ipc_recv,
	//or another environment managed to send first.
	if(!dste->env_ipc_recving || dste->env_ipc_from != 0)
		return -E_IPC_NOT_RECV;
	
	if(srcva < (void*)UTOP )
f01059c6:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01059cc:	0f 87 a4 00 00 00    	ja     f0105a76 <syscall+0x6ad>
	{
		//if srcva < UTOP but srcva is not page-aligned.
		if(ROUNDUP(srcva,PGSIZE) != srcva)
f01059d2:	89 da                	mov    %ebx,%edx
f01059d4:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f01059da:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01059e0:	39 d3                	cmp    %edx,%ebx
f01059e2:	0f 85 e9 00 00 00    	jne    f0105ad1 <syscall+0x708>
			return -E_INVAL;
		//if srcva < UTOP and perm is inappropriate
		if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f01059e8:	8b 55 18             	mov    0x18(%ebp),%edx
f01059eb:	83 e2 05             	and    $0x5,%edx
f01059ee:	83 fa 05             	cmp    $0x5,%edx
f01059f1:	0f 85 da 00 00 00    	jne    f0105ad1 <syscall+0x708>
			return -E_INVAL;
		if ((perm & ~PTE_SYSCALL) != 0)
f01059f7:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f01059fe:	0f 85 cd 00 00 00    	jne    f0105ad1 <syscall+0x708>
			return -E_INVAL;
		//if srcva < UTOP but srcva is not mapped in the caller's address space.
		struct Page* p;
		pte_t* ptestore;
		dste->env_ipc_perm = 0;
f0105a04:	c7 40 78 00 00 00 00 	movl   $0x0,0x78(%eax)
		
		p = page_lookup(curenv->env_pgdir,srcva,&ptestore);
f0105a0b:	e8 02 16 00 00       	call   f0107012 <cpunum>
f0105a10:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105a13:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105a17:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a1b:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a1e:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105a24:	8b 40 60             	mov    0x60(%eax),%eax
f0105a27:	89 04 24             	mov    %eax,(%esp)
f0105a2a:	e8 0b bf ff ff       	call   f010193a <page_lookup>
		if( p == NULL || ((perm & PTE_W) >0 && !(*ptestore & PTE_W) >0)) {
f0105a2f:	85 c0                	test   %eax,%eax
f0105a31:	0f 84 9a 00 00 00    	je     f0105ad1 <syscall+0x708>
f0105a37:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0105a3b:	74 0c                	je     f0105a49 <syscall+0x680>
f0105a3d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105a40:	f6 02 02             	testb  $0x2,(%edx)
f0105a43:	0f 84 88 00 00 00    	je     f0105ad1 <syscall+0x708>
 			return -E_INVAL;
    }
		if(page_insert(dste->env_pgdir,p,dste->env_ipc_dstva,perm)<0)
f0105a49:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105a4c:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105a4f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105a53:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0105a56:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a5e:	8b 42 60             	mov    0x60(%edx),%eax
f0105a61:	89 04 24             	mov    %eax,(%esp)
f0105a64:	e8 8e bf ff ff       	call   f01019f7 <page_insert>
f0105a69:	be fc ff ff ff       	mov    $0xfffffffc,%esi
f0105a6e:	85 c0                	test   %eax,%eax
f0105a70:	0f 88 4e 01 00 00    	js     f0105bc4 <syscall+0x7fb>
			return -E_NO_MEM;
	}
		
	dste->env_ipc_recving = 0;
f0105a76:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a79:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)
	dste->env_ipc_from = curenv->env_id;
f0105a80:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105a83:	e8 8a 15 00 00       	call   f0107012 <cpunum>
f0105a88:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a8b:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105a91:	8b 40 48             	mov    0x48(%eax),%eax
f0105a94:	89 43 74             	mov    %eax,0x74(%ebx)
	dste->env_ipc_value = value;
f0105a97:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105a9a:	8b 55 10             	mov    0x10(%ebp),%edx
f0105a9d:	89 50 70             	mov    %edx,0x70(%eax)
	dste->env_ipc_perm = perm;
f0105aa0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105aa3:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0105aa6:	89 48 78             	mov    %ecx,0x78(%eax)
	dste->env_tf.tf_regs.reg_eax = 0;
f0105aa9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105aac:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	//cprintf("%x----------%x\n",dste->env_id,dste->env_ipc_from);
	dste->env_status = ENV_RUNNABLE;
f0105ab3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ab6:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0105abd:	be 00 00 00 00       	mov    $0x0,%esi
f0105ac2:	e9 fd 00 00 00       	jmp    f0105bc4 <syscall+0x7fb>
f0105ac7:	be f9 ff ff ff       	mov    $0xfffffff9,%esi
f0105acc:	e9 f3 00 00 00       	jmp    f0105bc4 <syscall+0x7fb>
f0105ad1:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105ad6:	e9 e9 00 00 00       	jmp    f0105bc4 <syscall+0x7fb>
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
  struct Env *e;
  if (envid2env(envid, &e, 1) < 0) 
f0105adb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105ae2:	00 
f0105ae3:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0105ae6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105aea:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105aed:	89 04 24             	mov    %eax,(%esp)
f0105af0:	e8 f5 df ff ff       	call   f0103aea <envid2env>
f0105af5:	be fe ff ff ff       	mov    $0xfffffffe,%esi
f0105afa:	85 c0                	test   %eax,%eax
f0105afc:	0f 88 c2 00 00 00    	js     f0105bc4 <syscall+0x7fb>
      return -E_BAD_ENV;
  user_mem_assert(curenv, tf, sizeof(struct Trapframe), PTE_U);
f0105b02:	e8 0b 15 00 00       	call   f0107012 <cpunum>
f0105b07:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105b0e:	00 
f0105b0f:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0105b16:	00 
f0105b17:	8b 55 10             	mov    0x10(%ebp),%edx
f0105b1a:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b1e:	6b c0 74             	imul   $0x74,%eax,%eax
f0105b21:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105b27:	89 04 24             	mov    %eax,(%esp)
f0105b2a:	e8 b3 bd ff ff       	call   f01018e2 <user_mem_assert>
  e->env_tf = *tf;
f0105b2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b32:	b9 11 00 00 00       	mov    $0x11,%ecx
f0105b37:	89 c7                	mov    %eax,%edi
f0105b39:	8b 75 10             	mov    0x10(%ebp),%esi
f0105b3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  e->env_tf.tf_cs = GD_UT | 3;
f0105b3e:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b41:	66 c7 40 34 1b 00    	movw   $0x1b,0x34(%eax)
  e->env_tf.tf_eflags |= FL_IF;
f0105b47:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b4a:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)
  //sysenter/exit return
  e->env_tf.tf_regs.reg_ecx = tf->tf_esp;
f0105b51:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105b54:	8b 51 3c             	mov    0x3c(%ecx),%edx
f0105b57:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b5a:	89 50 18             	mov    %edx,0x18(%eax)
  e->env_tf.tf_regs.reg_edx = tf->tf_eip;
f0105b5d:	8b 51 30             	mov    0x30(%ecx),%edx
f0105b60:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b63:	89 50 14             	mov    %edx,0x14(%eax)
  e->env_tf.tf_regs.reg_eax = 0;
f0105b66:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105b69:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
f0105b70:	be 00 00 00 00       	mov    $0x0,%esi
f0105b75:	eb 4d                	jmp    f0105bc4 <syscall+0x7fb>
// Return the current time.
static int
sys_time_msec(void)
{
	// LAB 6: Your code here.
	return time_msec();
f0105b77:	e8 33 21 00 00       	call   f0107caf <time_msec>
f0105b7c:	89 c6                	mov    %eax,%esi
	case SYS_env_set_trapframe:
		r = sys_env_set_trapframe((envid_t)a1,(struct Trapframe*)a2);
		break;
	case SYS_time_msec:
		r = sys_time_msec();
		break;
f0105b7e:	eb 44                	jmp    f0105bc4 <syscall+0x7fb>

static int
sys_net_try_send(void* data, size_t len)
{
        // Check the buffer address that supported by users
        if ((uint32_t)data >= UTOP) return -E_INVAL;
f0105b80:	be fd ff ff ff       	mov    $0xfffffffd,%esi
f0105b85:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0105b8c:	77 36                	ja     f0105bc4 <syscall+0x7fb>
        memmove(kern_net_buf, data, len);
f0105b8e:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b91:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b95:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105b98:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105b9c:	c7 04 24 c0 5e 27 f0 	movl   $0xf0275ec0,(%esp)
f0105ba3:	e8 1d 0e 00 00       	call   f01069c5 <memmove>

        return E1000_transmit(kern_net_buf, len);
f0105ba8:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0105bab:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105baf:	c7 04 24 c0 5e 27 f0 	movl   $0xf0275ec0,(%esp)
f0105bb6:	e8 f5 18 00 00       	call   f01074b0 <E1000_transmit>
f0105bbb:	89 c6                	mov    %eax,%esi
f0105bbd:	eb 05                	jmp    f0105bc4 <syscall+0x7fb>
f0105bbf:	be fd ff ff ff       	mov    $0xfffffffd,%esi
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0105bc4:	c7 04 24 80 53 12 f0 	movl   $0xf0125380,(%esp)
f0105bcb:	e8 ec 16 00 00       	call   f01072bc <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0105bd0:	f3 90                	pause  
	}
	unlock_kernel();
	return r;

	panic("syscall not implemented");
}
f0105bd2:	89 f0                	mov    %esi,%eax
f0105bd4:	83 c4 2c             	add    $0x2c,%esp
f0105bd7:	5b                   	pop    %ebx
f0105bd8:	5e                   	pop    %esi
f0105bd9:	5f                   	pop    %edi
f0105bda:	5d                   	pop    %ebp
f0105bdb:	c3                   	ret    
f0105bdc:	00 00                	add    %al,(%eax)
	...

f0105be0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105be0:	55                   	push   %ebp
f0105be1:	89 e5                	mov    %esp,%ebp
f0105be3:	57                   	push   %edi
f0105be4:	56                   	push   %esi
f0105be5:	53                   	push   %ebx
f0105be6:	83 ec 14             	sub    $0x14,%esp
f0105be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105bec:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105bef:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105bf2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105bf5:	8b 1a                	mov    (%edx),%ebx
f0105bf7:	8b 01                	mov    (%ecx),%eax
f0105bf9:	89 45 ec             	mov    %eax,-0x14(%ebp)
	
	while (l <= r) {
f0105bfc:	39 c3                	cmp    %eax,%ebx
f0105bfe:	0f 8f 9c 00 00 00    	jg     f0105ca0 <stab_binsearch+0xc0>
f0105c04:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0105c0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105c0e:	01 d8                	add    %ebx,%eax
f0105c10:	89 c7                	mov    %eax,%edi
f0105c12:	c1 ef 1f             	shr    $0x1f,%edi
f0105c15:	01 c7                	add    %eax,%edi
f0105c17:	d1 ff                	sar    %edi
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105c19:	39 df                	cmp    %ebx,%edi
f0105c1b:	7c 33                	jl     f0105c50 <stab_binsearch+0x70>
f0105c1d:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0105c20:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0105c23:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0105c28:	39 f0                	cmp    %esi,%eax
f0105c2a:	0f 84 bc 00 00 00    	je     f0105cec <stab_binsearch+0x10c>
f0105c30:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0105c34:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0105c38:	89 f8                	mov    %edi,%eax
			m--;
f0105c3a:	83 e8 01             	sub    $0x1,%eax
	
	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
		
		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0105c3d:	39 d8                	cmp    %ebx,%eax
f0105c3f:	7c 0f                	jl     f0105c50 <stab_binsearch+0x70>
f0105c41:	0f b6 0a             	movzbl (%edx),%ecx
f0105c44:	83 ea 0c             	sub    $0xc,%edx
f0105c47:	39 f1                	cmp    %esi,%ecx
f0105c49:	75 ef                	jne    f0105c3a <stab_binsearch+0x5a>
f0105c4b:	e9 9e 00 00 00       	jmp    f0105cee <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0105c50:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0105c53:	eb 3c                	jmp    f0105c91 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0105c55:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105c58:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0105c5a:	8d 5f 01             	lea    0x1(%edi),%ebx
f0105c5d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105c64:	eb 2b                	jmp    f0105c91 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0105c66:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105c69:	76 14                	jbe    f0105c7f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0105c6b:	83 e8 01             	sub    $0x1,%eax
f0105c6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105c71:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105c74:	89 02                	mov    %eax,(%edx)
f0105c76:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105c7d:	eb 12                	jmp    f0105c91 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105c7f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0105c82:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0105c84:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105c88:	89 c3                	mov    %eax,%ebx
f0105c8a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;
	
	while (l <= r) {
f0105c91:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0105c94:	0f 8d 71 ff ff ff    	jge    f0105c0b <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105c9a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105c9e:	75 0f                	jne    f0105caf <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0105ca0:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105ca3:	8b 03                	mov    (%ebx),%eax
f0105ca5:	83 e8 01             	sub    $0x1,%eax
f0105ca8:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105cab:	89 02                	mov    %eax,(%edx)
f0105cad:	eb 57                	jmp    f0105d06 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105caf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105cb2:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105cb4:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0105cb7:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105cb9:	39 c1                	cmp    %eax,%ecx
f0105cbb:	7d 28                	jge    f0105ce5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105cbd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105cc0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0105cc3:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0105cc8:	39 f2                	cmp    %esi,%edx
f0105cca:	74 19                	je     f0105ce5 <stab_binsearch+0x105>
f0105ccc:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0105cd0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0105cd4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105cd7:	39 c1                	cmp    %eax,%ecx
f0105cd9:	7d 0a                	jge    f0105ce5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0105cdb:	0f b6 1a             	movzbl (%edx),%ebx
f0105cde:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105ce1:	39 f3                	cmp    %esi,%ebx
f0105ce3:	75 ef                	jne    f0105cd4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0105ce5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105ce8:	89 02                	mov    %eax,(%edx)
f0105cea:	eb 1a                	jmp    f0105d06 <stab_binsearch+0x126>
	}
}
f0105cec:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0105cee:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105cf1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0105cf4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0105cf8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105cfb:	0f 82 54 ff ff ff    	jb     f0105c55 <stab_binsearch+0x75>
f0105d01:	e9 60 ff ff ff       	jmp    f0105c66 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105d06:	83 c4 14             	add    $0x14,%esp
f0105d09:	5b                   	pop    %ebx
f0105d0a:	5e                   	pop    %esi
f0105d0b:	5f                   	pop    %edi
f0105d0c:	5d                   	pop    %ebp
f0105d0d:	c3                   	ret    

f0105d0e <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105d0e:	55                   	push   %ebp
f0105d0f:	89 e5                	mov    %esp,%ebp
f0105d11:	83 ec 58             	sub    $0x58,%esp
f0105d14:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0105d17:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0105d1a:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0105d1d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105d23:	c7 03 94 95 10 f0    	movl   $0xf0109594,(%ebx)
	info->eip_line = 0;
f0105d29:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0105d30:	c7 43 08 94 95 10 f0 	movl   $0xf0109594,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0105d37:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0105d3e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0105d41:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105d48:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0105d4e:	76 1f                	jbe    f0105d6f <debuginfo_eip+0x61>
f0105d50:	bf 46 aa 11 f0       	mov    $0xf011aa46,%edi
f0105d55:	c7 45 c4 49 60 11 f0 	movl   $0xf0116049,-0x3c(%ebp)
f0105d5c:	c7 45 bc 48 60 11 f0 	movl   $0xf0116048,-0x44(%ebp)
f0105d63:	c7 45 c0 8c 9e 10 f0 	movl   $0xf0109e8c,-0x40(%ebp)
f0105d6a:	e9 c7 00 00 00       	jmp    f0105e36 <debuginfo_eip+0x128>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, usd, sizeof (struct UserStabData), PTE_U) < 0)
f0105d6f:	e8 9e 12 00 00       	call   f0107012 <cpunum>
f0105d74:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105d7b:	00 
f0105d7c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0105d83:	00 
f0105d84:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0105d8b:	00 
f0105d8c:	6b c0 74             	imul   $0x74,%eax,%eax
f0105d8f:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105d95:	89 04 24             	mov    %eax,(%esp)
f0105d98:	e8 b3 ba ff ff       	call   f0101850 <user_mem_check>
f0105d9d:	85 c0                	test   %eax,%eax
f0105d9f:	0f 88 53 02 00 00    	js     f0105ff8 <debuginfo_eip+0x2ea>
			return -1;

		stabs = usd->stabs;
f0105da5:	b8 00 00 20 00       	mov    $0x200000,%eax
f0105daa:	8b 10                	mov    (%eax),%edx
f0105dac:	89 55 c0             	mov    %edx,-0x40(%ebp)
		stab_end = usd->stab_end;
f0105daf:	8b 48 04             	mov    0x4(%eax),%ecx
f0105db2:	89 4d bc             	mov    %ecx,-0x44(%ebp)
		stabstr = usd->stabstr;
f0105db5:	8b 50 08             	mov    0x8(%eax),%edx
f0105db8:	89 55 c4             	mov    %edx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105dbb:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0105dbe:	e8 4f 12 00 00       	call   f0107012 <cpunum>
f0105dc3:	89 c2                	mov    %eax,%edx
			|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105dc5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105dcc:	00 
f0105dcd:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105dd0:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105dd3:	c1 f8 02             	sar    $0x2,%eax
f0105dd6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105ddc:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105de0:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105de3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105de7:	6b c2 74             	imul   $0x74,%edx,%eax
f0105dea:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105df0:	89 04 24             	mov    %eax,(%esp)
f0105df3:	e8 58 ba ff ff       	call   f0101850 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0105df8:	85 c0                	test   %eax,%eax
f0105dfa:	0f 88 f8 01 00 00    	js     f0105ff8 <debuginfo_eip+0x2ea>
			|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0105e00:	e8 0d 12 00 00       	call   f0107012 <cpunum>
f0105e05:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0105e0c:	00 
f0105e0d:	89 fa                	mov    %edi,%edx
f0105e0f:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0105e12:	89 54 24 08          	mov    %edx,0x8(%esp)
f0105e16:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105e19:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105e1d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105e20:	8b 80 28 80 27 f0    	mov    -0xfd87fd8(%eax),%eax
f0105e26:	89 04 24             	mov    %eax,(%esp)
f0105e29:	e8 22 ba ff ff       	call   f0101850 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0
f0105e2e:	85 c0                	test   %eax,%eax
f0105e30:	0f 88 c2 01 00 00    	js     f0105ff8 <debuginfo_eip+0x2ea>
			return -1;

	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0105e36:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0105e39:	0f 83 b9 01 00 00    	jae    f0105ff8 <debuginfo_eip+0x2ea>
f0105e3f:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0105e43:	0f 85 af 01 00 00    	jne    f0105ff8 <debuginfo_eip+0x2ea>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.
	
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105e49:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105e50:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0105e53:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0105e56:	c1 f8 02             	sar    $0x2,%eax
f0105e59:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105e5f:	83 e8 01             	sub    $0x1,%eax
f0105e62:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105e65:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105e68:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105e6b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e6f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105e76:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105e79:	e8 62 fd ff ff       	call   f0105be0 <stab_binsearch>
	if (lfile == 0)
f0105e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105e81:	85 c0                	test   %eax,%eax
f0105e83:	0f 84 6f 01 00 00    	je     f0105ff8 <debuginfo_eip+0x2ea>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105e89:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105e8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105e8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105e92:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105e95:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105e98:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e9c:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105ea3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105ea6:	e8 35 fd ff ff       	call   f0105be0 <stab_binsearch>

	if (lfun <= rfun) {
f0105eab:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105eae:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105eb1:	7f 35                	jg     f0105ee8 <debuginfo_eip+0x1da>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105eb3:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105eb6:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105eb9:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0105ebc:	89 fa                	mov    %edi,%edx
f0105ebe:	2b 55 c4             	sub    -0x3c(%ebp),%edx
f0105ec1:	39 d0                	cmp    %edx,%eax
f0105ec3:	73 06                	jae    f0105ecb <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105ec5:	03 45 c4             	add    -0x3c(%ebp),%eax
f0105ec8:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105ecb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0105ece:	6b c2 0c             	imul   $0xc,%edx,%eax
f0105ed1:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105ed4:	8b 44 08 08          	mov    0x8(%eax,%ecx,1),%eax
f0105ed8:	89 43 10             	mov    %eax,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0105edb:	29 c6                	sub    %eax,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0105edd:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		rline = rfun;
f0105ee0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0105ee3:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0105ee6:	eb 0f                	jmp    f0105ef7 <debuginfo_eip+0x1e9>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105ee8:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105eeb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105eee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105ef1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105ef4:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105ef7:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105efe:	00 
f0105eff:	8b 43 08             	mov    0x8(%ebx),%eax
f0105f02:	89 04 24             	mov    %eax,(%esp)
f0105f05:	e8 31 0a 00 00       	call   f010693b <strfind>
f0105f0a:	2b 43 08             	sub    0x8(%ebx),%eax
f0105f0d:	89 43 0c             	mov    %eax,0xc(%ebx)
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.

	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0105f10:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0105f13:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0105f16:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105f1a:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0105f21:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0105f24:	e8 b7 fc ff ff       	call   f0105be0 <stab_binsearch>
	if(lline <= rline){
f0105f29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105f2c:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0105f2f:	7f 34                	jg     f0105f65 <debuginfo_eip+0x257>
		info -> eip_line = stabs[lline].n_desc;
f0105f31:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105f34:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105f37:	0f b7 44 10 06       	movzwl 0x6(%eax,%edx,1),%eax
f0105f3c:	89 43 04             	mov    %eax,0x4(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0105f3f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105f42:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105f45:	89 4d bc             	mov    %ecx,-0x44(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105f48:	39 c8                	cmp    %ecx,%eax
f0105f4a:	7c 6b                	jl     f0105fb7 <debuginfo_eip+0x2a9>
	       && stabs[lline].n_type != N_SOL
f0105f4c:	6b f0 0c             	imul   $0xc,%eax,%esi
f0105f4f:	01 d6                	add    %edx,%esi
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105f51:	0f b6 4e 04          	movzbl 0x4(%esi),%ecx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105f55:	80 f9 84             	cmp    $0x84,%cl
f0105f58:	74 48                	je     f0105fa2 <debuginfo_eip+0x294>
f0105f5a:	8d 50 ff             	lea    -0x1(%eax),%edx
f0105f5d:	6b d2 0c             	imul   $0xc,%edx,%edx
f0105f60:	03 55 c0             	add    -0x40(%ebp),%edx
f0105f63:	eb 2a                	jmp    f0105f8f <debuginfo_eip+0x281>
	if(lline <= rline){
		info -> eip_line = stabs[lline].n_desc;
	}
	else
	{
		info -> eip_line = 0;
f0105f65:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
f0105f6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		return -1;
f0105f71:	e9 8e 00 00 00       	jmp    f0106004 <debuginfo_eip+0x2f6>
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0105f76:	83 e8 01             	sub    $0x1,%eax
f0105f79:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105f7c:	39 45 bc             	cmp    %eax,-0x44(%ebp)
f0105f7f:	7f 36                	jg     f0105fb7 <debuginfo_eip+0x2a9>
f0105f81:	89 d6                	mov    %edx,%esi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105f83:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0105f87:	83 ea 0c             	sub    $0xc,%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0105f8a:	80 f9 84             	cmp    $0x84,%cl
f0105f8d:	74 13                	je     f0105fa2 <debuginfo_eip+0x294>
f0105f8f:	80 f9 64             	cmp    $0x64,%cl
f0105f92:	75 e2                	jne    f0105f76 <debuginfo_eip+0x268>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0105f94:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
f0105f98:	74 dc                	je     f0105f76 <debuginfo_eip+0x268>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105f9a:	3b 45 bc             	cmp    -0x44(%ebp),%eax
f0105f9d:	8d 76 00             	lea    0x0(%esi),%esi
f0105fa0:	7c 15                	jl     f0105fb7 <debuginfo_eip+0x2a9>
f0105fa2:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105fa5:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105fa8:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0105fab:	2b 7d c4             	sub    -0x3c(%ebp),%edi
f0105fae:	39 f8                	cmp    %edi,%eax
f0105fb0:	73 05                	jae    f0105fb7 <debuginfo_eip+0x2a9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0105fb2:	03 45 c4             	add    -0x3c(%ebp),%eax
f0105fb5:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0105fb7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105fba:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0105fbd:	7d 40                	jge    f0105fff <debuginfo_eip+0x2f1>
		for (lline = lfun + 1;
f0105fbf:	83 c0 01             	add    $0x1,%eax
f0105fc2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0105fc5:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0105fc8:	7e 35                	jle    f0105fff <debuginfo_eip+0x2f1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105fca:	6b c0 0c             	imul   $0xc,%eax,%eax
f0105fcd:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0105fd0:	80 7c 08 04 a0       	cmpb   $0xa0,0x4(%eax,%ecx,1)
f0105fd5:	75 28                	jne    f0105fff <debuginfo_eip+0x2f1>
		     lline++)
			info->eip_fn_narg++;
f0105fd7:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105fdb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105fde:	83 c0 01             	add    $0x1,%eax
f0105fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105fe4:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0105fe7:	7e 16                	jle    f0105fff <debuginfo_eip+0x2f1>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105fe9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105fec:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0105fef:	80 7c 82 04 a0       	cmpb   $0xa0,0x4(%edx,%eax,4)
f0105ff4:	74 e1                	je     f0105fd7 <debuginfo_eip+0x2c9>
f0105ff6:	eb 07                	jmp    f0105fff <debuginfo_eip+0x2f1>
f0105ff8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105ffd:	eb 05                	jmp    f0106004 <debuginfo_eip+0x2f6>
f0105fff:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline++)
			info->eip_fn_narg++;
	
	return 0;
}
f0106004:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0106007:	8b 75 f8             	mov    -0x8(%ebp),%esi
f010600a:	8b 7d fc             	mov    -0x4(%ebp),%edi
f010600d:	89 ec                	mov    %ebp,%esp
f010600f:	5d                   	pop    %ebp
f0106010:	c3                   	ret    
	...

f0106020 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0106020:	55                   	push   %ebp
f0106021:	89 e5                	mov    %esp,%ebp
f0106023:	57                   	push   %edi
f0106024:	56                   	push   %esi
f0106025:	53                   	push   %ebx
f0106026:	83 ec 4c             	sub    $0x4c,%esp
f0106029:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010602c:	89 d6                	mov    %edx,%esi
f010602e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106031:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0106034:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106037:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010603a:	8b 45 10             	mov    0x10(%ebp),%eax
f010603d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0106040:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0106043:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0106046:	b9 00 00 00 00       	mov    $0x0,%ecx
f010604b:	39 d1                	cmp    %edx,%ecx
f010604d:	72 15                	jb     f0106064 <printnum+0x44>
f010604f:	77 07                	ja     f0106058 <printnum+0x38>
f0106051:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106054:	39 d0                	cmp    %edx,%eax
f0106056:	76 0c                	jbe    f0106064 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0106058:	83 eb 01             	sub    $0x1,%ebx
f010605b:	85 db                	test   %ebx,%ebx
f010605d:	8d 76 00             	lea    0x0(%esi),%esi
f0106060:	7f 61                	jg     f01060c3 <printnum+0xa3>
f0106062:	eb 70                	jmp    f01060d4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0106064:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0106068:	83 eb 01             	sub    $0x1,%ebx
f010606b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010606f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106073:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106077:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f010607b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010607e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0106081:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0106084:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0106088:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010608f:	00 
f0106090:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0106093:	89 04 24             	mov    %eax,(%esp)
f0106096:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0106099:	89 54 24 04          	mov    %edx,0x4(%esp)
f010609d:	e8 5e 1c 00 00       	call   f0107d00 <__udivdi3>
f01060a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01060a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01060a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01060ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01060b0:	89 04 24             	mov    %eax,(%esp)
f01060b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01060b7:	89 f2                	mov    %esi,%edx
f01060b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060bc:	e8 5f ff ff ff       	call   f0106020 <printnum>
f01060c1:	eb 11                	jmp    f01060d4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01060c3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01060c7:	89 3c 24             	mov    %edi,(%esp)
f01060ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01060cd:	83 eb 01             	sub    $0x1,%ebx
f01060d0:	85 db                	test   %ebx,%ebx
f01060d2:	7f ef                	jg     f01060c3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01060d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01060d8:	8b 74 24 04          	mov    0x4(%esp),%esi
f01060dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01060df:	89 44 24 08          	mov    %eax,0x8(%esp)
f01060e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01060ea:	00 
f01060eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01060ee:	89 14 24             	mov    %edx,(%esp)
f01060f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01060f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01060f8:	e8 33 1d 00 00       	call   f0107e30 <__umoddi3>
f01060fd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106101:	0f be 80 9e 95 10 f0 	movsbl -0xfef6a62(%eax),%eax
f0106108:	89 04 24             	mov    %eax,(%esp)
f010610b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010610e:	83 c4 4c             	add    $0x4c,%esp
f0106111:	5b                   	pop    %ebx
f0106112:	5e                   	pop    %esi
f0106113:	5f                   	pop    %edi
f0106114:	5d                   	pop    %ebp
f0106115:	c3                   	ret    

f0106116 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0106116:	55                   	push   %ebp
f0106117:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0106119:	83 fa 01             	cmp    $0x1,%edx
f010611c:	7e 0e                	jle    f010612c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010611e:	8b 10                	mov    (%eax),%edx
f0106120:	8d 4a 08             	lea    0x8(%edx),%ecx
f0106123:	89 08                	mov    %ecx,(%eax)
f0106125:	8b 02                	mov    (%edx),%eax
f0106127:	8b 52 04             	mov    0x4(%edx),%edx
f010612a:	eb 22                	jmp    f010614e <getuint+0x38>
	else if (lflag)
f010612c:	85 d2                	test   %edx,%edx
f010612e:	74 10                	je     f0106140 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0106130:	8b 10                	mov    (%eax),%edx
f0106132:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106135:	89 08                	mov    %ecx,(%eax)
f0106137:	8b 02                	mov    (%edx),%eax
f0106139:	ba 00 00 00 00       	mov    $0x0,%edx
f010613e:	eb 0e                	jmp    f010614e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0106140:	8b 10                	mov    (%eax),%edx
f0106142:	8d 4a 04             	lea    0x4(%edx),%ecx
f0106145:	89 08                	mov    %ecx,(%eax)
f0106147:	8b 02                	mov    (%edx),%eax
f0106149:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010614e:	5d                   	pop    %ebp
f010614f:	c3                   	ret    

f0106150 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0106150:	55                   	push   %ebp
f0106151:	89 e5                	mov    %esp,%ebp
f0106153:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0106156:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f010615a:	8b 10                	mov    (%eax),%edx
f010615c:	3b 50 04             	cmp    0x4(%eax),%edx
f010615f:	73 0a                	jae    f010616b <sprintputch+0x1b>
		*b->buf++ = ch;
f0106161:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0106164:	88 0a                	mov    %cl,(%edx)
f0106166:	83 c2 01             	add    $0x1,%edx
f0106169:	89 10                	mov    %edx,(%eax)
}
f010616b:	5d                   	pop    %ebp
f010616c:	c3                   	ret    

f010616d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010616d:	55                   	push   %ebp
f010616e:	89 e5                	mov    %esp,%ebp
f0106170:	57                   	push   %edi
f0106171:	56                   	push   %esi
f0106172:	53                   	push   %ebx
f0106173:	83 ec 5c             	sub    $0x5c,%esp
f0106176:	8b 7d 08             	mov    0x8(%ebp),%edi
f0106179:	8b 75 0c             	mov    0xc(%ebp),%esi
f010617c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f010617f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0106186:	eb 11                	jmp    f0106199 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0106188:	85 c0                	test   %eax,%eax
f010618a:	0f 84 68 04 00 00    	je     f01065f8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
f0106190:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106194:	89 04 24             	mov    %eax,(%esp)
f0106197:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0106199:	0f b6 03             	movzbl (%ebx),%eax
f010619c:	83 c3 01             	add    $0x1,%ebx
f010619f:	83 f8 25             	cmp    $0x25,%eax
f01061a2:	75 e4                	jne    f0106188 <vprintfmt+0x1b>
f01061a4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01061ab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01061b2:	b9 00 00 00 00       	mov    $0x0,%ecx
f01061b7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
f01061bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01061c2:	eb 06                	jmp    f01061ca <vprintfmt+0x5d>
f01061c4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
f01061c8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01061ca:	0f b6 13             	movzbl (%ebx),%edx
f01061cd:	0f b6 c2             	movzbl %dl,%eax
f01061d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061d3:	8d 43 01             	lea    0x1(%ebx),%eax
f01061d6:	83 ea 23             	sub    $0x23,%edx
f01061d9:	80 fa 55             	cmp    $0x55,%dl
f01061dc:	0f 87 f9 03 00 00    	ja     f01065db <vprintfmt+0x46e>
f01061e2:	0f b6 d2             	movzbl %dl,%edx
f01061e5:	ff 24 95 80 97 10 f0 	jmp    *-0xfef6880(,%edx,4)
f01061ec:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
f01061f0:	eb d6                	jmp    f01061c8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01061f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01061f5:	83 ea 30             	sub    $0x30,%edx
f01061f8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f01061fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f01061fe:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0106201:	83 fb 09             	cmp    $0x9,%ebx
f0106204:	77 54                	ja     f010625a <vprintfmt+0xed>
f0106206:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0106209:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010620c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f010620f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0106212:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0106216:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0106219:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010621c:	83 fb 09             	cmp    $0x9,%ebx
f010621f:	76 eb                	jbe    f010620c <vprintfmt+0x9f>
f0106221:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0106224:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0106227:	eb 31                	jmp    f010625a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0106229:	8b 55 14             	mov    0x14(%ebp),%edx
f010622c:	8d 5a 04             	lea    0x4(%edx),%ebx
f010622f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0106232:	8b 12                	mov    (%edx),%edx
f0106234:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f0106237:	eb 21                	jmp    f010625a <vprintfmt+0xed>

		case '.':
			if (width < 0)
f0106239:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010623d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106242:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
f0106246:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0106249:	e9 7a ff ff ff       	jmp    f01061c8 <vprintfmt+0x5b>
f010624e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f0106255:	e9 6e ff ff ff       	jmp    f01061c8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f010625a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010625e:	0f 89 64 ff ff ff    	jns    f01061c8 <vprintfmt+0x5b>
f0106264:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0106267:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010626a:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010626d:	89 55 cc             	mov    %edx,-0x34(%ebp)
f0106270:	e9 53 ff ff ff       	jmp    f01061c8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0106275:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f0106278:	e9 4b ff ff ff       	jmp    f01061c8 <vprintfmt+0x5b>
f010627d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0106280:	8b 45 14             	mov    0x14(%ebp),%eax
f0106283:	8d 50 04             	lea    0x4(%eax),%edx
f0106286:	89 55 14             	mov    %edx,0x14(%ebp)
f0106289:	89 74 24 04          	mov    %esi,0x4(%esp)
f010628d:	8b 00                	mov    (%eax),%eax
f010628f:	89 04 24             	mov    %eax,(%esp)
f0106292:	ff d7                	call   *%edi
f0106294:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0106297:	e9 fd fe ff ff       	jmp    f0106199 <vprintfmt+0x2c>
f010629c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010629f:	8b 45 14             	mov    0x14(%ebp),%eax
f01062a2:	8d 50 04             	lea    0x4(%eax),%edx
f01062a5:	89 55 14             	mov    %edx,0x14(%ebp)
f01062a8:	8b 00                	mov    (%eax),%eax
f01062aa:	89 c2                	mov    %eax,%edx
f01062ac:	c1 fa 1f             	sar    $0x1f,%edx
f01062af:	31 d0                	xor    %edx,%eax
f01062b1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01062b3:	83 f8 0f             	cmp    $0xf,%eax
f01062b6:	7f 0b                	jg     f01062c3 <vprintfmt+0x156>
f01062b8:	8b 14 85 e0 98 10 f0 	mov    -0xfef6720(,%eax,4),%edx
f01062bf:	85 d2                	test   %edx,%edx
f01062c1:	75 20                	jne    f01062e3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
f01062c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01062c7:	c7 44 24 08 af 95 10 	movl   $0xf01095af,0x8(%esp)
f01062ce:	f0 
f01062cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062d3:	89 3c 24             	mov    %edi,(%esp)
f01062d6:	e8 a5 03 00 00       	call   f0106680 <printfmt>
f01062db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01062de:	e9 b6 fe ff ff       	jmp    f0106199 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f01062e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01062e7:	c7 44 24 08 d9 8c 10 	movl   $0xf0108cd9,0x8(%esp)
f01062ee:	f0 
f01062ef:	89 74 24 04          	mov    %esi,0x4(%esp)
f01062f3:	89 3c 24             	mov    %edi,(%esp)
f01062f6:	e8 85 03 00 00       	call   f0106680 <printfmt>
f01062fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01062fe:	e9 96 fe ff ff       	jmp    f0106199 <vprintfmt+0x2c>
f0106303:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0106306:	89 c3                	mov    %eax,%ebx
f0106308:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010630b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010630e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0106311:	8b 45 14             	mov    0x14(%ebp),%eax
f0106314:	8d 50 04             	lea    0x4(%eax),%edx
f0106317:	89 55 14             	mov    %edx,0x14(%ebp)
f010631a:	8b 00                	mov    (%eax),%eax
f010631c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010631f:	85 c0                	test   %eax,%eax
f0106321:	b8 b8 95 10 f0       	mov    $0xf01095b8,%eax
f0106326:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
f010632a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f010632d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
f0106331:	7e 06                	jle    f0106339 <vprintfmt+0x1cc>
f0106333:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
f0106337:	75 13                	jne    f010634c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0106339:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010633c:	0f be 02             	movsbl (%edx),%eax
f010633f:	85 c0                	test   %eax,%eax
f0106341:	0f 85 a2 00 00 00    	jne    f01063e9 <vprintfmt+0x27c>
f0106347:	e9 8f 00 00 00       	jmp    f01063db <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010634c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0106350:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0106353:	89 0c 24             	mov    %ecx,(%esp)
f0106356:	e8 50 04 00 00       	call   f01067ab <strnlen>
f010635b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010635e:	29 c2                	sub    %eax,%edx
f0106360:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0106363:	85 d2                	test   %edx,%edx
f0106365:	7e d2                	jle    f0106339 <vprintfmt+0x1cc>
					putch(padc, putdat);
f0106367:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f010636b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010636e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
f0106371:	89 d3                	mov    %edx,%ebx
f0106373:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106377:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010637a:	89 04 24             	mov    %eax,(%esp)
f010637d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010637f:	83 eb 01             	sub    $0x1,%ebx
f0106382:	85 db                	test   %ebx,%ebx
f0106384:	7f ed                	jg     f0106373 <vprintfmt+0x206>
f0106386:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0106389:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f0106390:	eb a7                	jmp    f0106339 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0106392:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0106396:	74 1b                	je     f01063b3 <vprintfmt+0x246>
f0106398:	8d 50 e0             	lea    -0x20(%eax),%edx
f010639b:	83 fa 5e             	cmp    $0x5e,%edx
f010639e:	76 13                	jbe    f01063b3 <vprintfmt+0x246>
					putch('?', putdat);
f01063a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01063a3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01063a7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01063ae:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01063b1:	eb 0d                	jmp    f01063c0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
f01063b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01063b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01063ba:	89 04 24             	mov    %eax,(%esp)
f01063bd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01063c0:	83 ef 01             	sub    $0x1,%edi
f01063c3:	0f be 03             	movsbl (%ebx),%eax
f01063c6:	85 c0                	test   %eax,%eax
f01063c8:	74 05                	je     f01063cf <vprintfmt+0x262>
f01063ca:	83 c3 01             	add    $0x1,%ebx
f01063cd:	eb 31                	jmp    f0106400 <vprintfmt+0x293>
f01063cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01063d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01063d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01063d8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01063db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01063df:	7f 36                	jg     f0106417 <vprintfmt+0x2aa>
f01063e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01063e4:	e9 b0 fd ff ff       	jmp    f0106199 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01063e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01063ec:	83 c2 01             	add    $0x1,%edx
f01063ef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01063f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01063f5:	89 75 e0             	mov    %esi,-0x20(%ebp)
f01063f8:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01063fb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01063fe:	89 d3                	mov    %edx,%ebx
f0106400:	85 f6                	test   %esi,%esi
f0106402:	78 8e                	js     f0106392 <vprintfmt+0x225>
f0106404:	83 ee 01             	sub    $0x1,%esi
f0106407:	79 89                	jns    f0106392 <vprintfmt+0x225>
f0106409:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010640c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010640f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0106412:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0106415:	eb c4                	jmp    f01063db <vprintfmt+0x26e>
f0106417:	89 5d d8             	mov    %ebx,-0x28(%ebp)
f010641a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010641d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106421:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0106428:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010642a:	83 eb 01             	sub    $0x1,%ebx
f010642d:	85 db                	test   %ebx,%ebx
f010642f:	7f ec                	jg     f010641d <vprintfmt+0x2b0>
f0106431:	8b 5d d8             	mov    -0x28(%ebp),%ebx
f0106434:	e9 60 fd ff ff       	jmp    f0106199 <vprintfmt+0x2c>
f0106439:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010643c:	83 f9 01             	cmp    $0x1,%ecx
f010643f:	7e 16                	jle    f0106457 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
f0106441:	8b 45 14             	mov    0x14(%ebp),%eax
f0106444:	8d 50 08             	lea    0x8(%eax),%edx
f0106447:	89 55 14             	mov    %edx,0x14(%ebp)
f010644a:	8b 10                	mov    (%eax),%edx
f010644c:	8b 48 04             	mov    0x4(%eax),%ecx
f010644f:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0106452:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0106455:	eb 32                	jmp    f0106489 <vprintfmt+0x31c>
	else if (lflag)
f0106457:	85 c9                	test   %ecx,%ecx
f0106459:	74 18                	je     f0106473 <vprintfmt+0x306>
		return va_arg(*ap, long);
f010645b:	8b 45 14             	mov    0x14(%ebp),%eax
f010645e:	8d 50 04             	lea    0x4(%eax),%edx
f0106461:	89 55 14             	mov    %edx,0x14(%ebp)
f0106464:	8b 00                	mov    (%eax),%eax
f0106466:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0106469:	89 c1                	mov    %eax,%ecx
f010646b:	c1 f9 1f             	sar    $0x1f,%ecx
f010646e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0106471:	eb 16                	jmp    f0106489 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
f0106473:	8b 45 14             	mov    0x14(%ebp),%eax
f0106476:	8d 50 04             	lea    0x4(%eax),%edx
f0106479:	89 55 14             	mov    %edx,0x14(%ebp)
f010647c:	8b 00                	mov    (%eax),%eax
f010647e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0106481:	89 c2                	mov    %eax,%edx
f0106483:	c1 fa 1f             	sar    $0x1f,%edx
f0106486:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0106489:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010648c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010648f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
f0106494:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0106498:	0f 89 8a 00 00 00    	jns    f0106528 <vprintfmt+0x3bb>
				putch('-', putdat);
f010649e:	89 74 24 04          	mov    %esi,0x4(%esp)
f01064a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01064a9:	ff d7                	call   *%edi
				num = -(long long) num;
f01064ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01064ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01064b1:	f7 d8                	neg    %eax
f01064b3:	83 d2 00             	adc    $0x0,%edx
f01064b6:	f7 da                	neg    %edx
f01064b8:	eb 6e                	jmp    f0106528 <vprintfmt+0x3bb>
f01064ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01064bd:	89 ca                	mov    %ecx,%edx
f01064bf:	8d 45 14             	lea    0x14(%ebp),%eax
f01064c2:	e8 4f fc ff ff       	call   f0106116 <getuint>
f01064c7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
f01064cc:	eb 5a                	jmp    f0106528 <vprintfmt+0x3bb>
f01064ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
f01064d1:	89 ca                	mov    %ecx,%edx
f01064d3:	8d 45 14             	lea    0x14(%ebp),%eax
f01064d6:	e8 3b fc ff ff       	call   f0106116 <getuint>
f01064db:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
f01064e0:	eb 46                	jmp    f0106528 <vprintfmt+0x3bb>
f01064e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
f01064e5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01064e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01064f0:	ff d7                	call   *%edi
			putch('x', putdat);
f01064f2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01064f6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01064fd:	ff d7                	call   *%edi
			num = (unsigned long long)
f01064ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0106502:	8d 50 04             	lea    0x4(%eax),%edx
f0106505:	89 55 14             	mov    %edx,0x14(%ebp)
f0106508:	8b 00                	mov    (%eax),%eax
f010650a:	ba 00 00 00 00       	mov    $0x0,%edx
f010650f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0106514:	eb 12                	jmp    f0106528 <vprintfmt+0x3bb>
f0106516:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0106519:	89 ca                	mov    %ecx,%edx
f010651b:	8d 45 14             	lea    0x14(%ebp),%eax
f010651e:	e8 f3 fb ff ff       	call   f0106116 <getuint>
f0106523:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f0106528:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
f010652c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0106530:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0106533:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0106537:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010653b:	89 04 24             	mov    %eax,(%esp)
f010653e:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106542:	89 f2                	mov    %esi,%edx
f0106544:	89 f8                	mov    %edi,%eax
f0106546:	e8 d5 fa ff ff       	call   f0106020 <printnum>
f010654b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f010654e:	e9 46 fc ff ff       	jmp    f0106199 <vprintfmt+0x2c>
f0106553:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
f0106556:	8b 45 14             	mov    0x14(%ebp),%eax
f0106559:	8d 50 04             	lea    0x4(%eax),%edx
f010655c:	89 55 14             	mov    %edx,0x14(%ebp)
f010655f:	8b 00                	mov    (%eax),%eax
f0106561:	85 c0                	test   %eax,%eax
f0106563:	75 24                	jne    f0106589 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
f0106565:	c7 44 24 0c d4 96 10 	movl   $0xf01096d4,0xc(%esp)
f010656c:	f0 
f010656d:	c7 44 24 08 d9 8c 10 	movl   $0xf0108cd9,0x8(%esp)
f0106574:	f0 
f0106575:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106579:	89 3c 24             	mov    %edi,(%esp)
f010657c:	e8 ff 00 00 00       	call   f0106680 <printfmt>
f0106581:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f0106584:	e9 10 fc ff ff       	jmp    f0106199 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
f0106589:	83 3e 7f             	cmpl   $0x7f,(%esi)
f010658c:	7e 29                	jle    f01065b7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
f010658e:	0f b6 16             	movzbl (%esi),%edx
f0106591:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
f0106593:	c7 44 24 0c 0c 97 10 	movl   $0xf010970c,0xc(%esp)
f010659a:	f0 
f010659b:	c7 44 24 08 d9 8c 10 	movl   $0xf0108cd9,0x8(%esp)
f01065a2:	f0 
f01065a3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065a7:	89 3c 24             	mov    %edi,(%esp)
f01065aa:	e8 d1 00 00 00       	call   f0106680 <printfmt>
f01065af:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01065b2:	e9 e2 fb ff ff       	jmp    f0106199 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
f01065b7:	0f b6 16             	movzbl (%esi),%edx
f01065ba:	88 10                	mov    %dl,(%eax)
f01065bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
f01065bf:	e9 d5 fb ff ff       	jmp    f0106199 <vprintfmt+0x2c>
f01065c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01065c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01065ca:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065ce:	89 14 24             	mov    %edx,(%esp)
f01065d1:	ff d7                	call   *%edi
f01065d3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
f01065d6:	e9 be fb ff ff       	jmp    f0106199 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01065db:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01065e6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01065e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01065eb:	80 38 25             	cmpb   $0x25,(%eax)
f01065ee:	0f 84 a5 fb ff ff    	je     f0106199 <vprintfmt+0x2c>
f01065f4:	89 c3                	mov    %eax,%ebx
f01065f6:	eb f0                	jmp    f01065e8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
f01065f8:	83 c4 5c             	add    $0x5c,%esp
f01065fb:	5b                   	pop    %ebx
f01065fc:	5e                   	pop    %esi
f01065fd:	5f                   	pop    %edi
f01065fe:	5d                   	pop    %ebp
f01065ff:	c3                   	ret    

f0106600 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0106600:	55                   	push   %ebp
f0106601:	89 e5                	mov    %esp,%ebp
f0106603:	83 ec 28             	sub    $0x28,%esp
f0106606:	8b 45 08             	mov    0x8(%ebp),%eax
f0106609:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f010660c:	85 c0                	test   %eax,%eax
f010660e:	74 04                	je     f0106614 <vsnprintf+0x14>
f0106610:	85 d2                	test   %edx,%edx
f0106612:	7f 07                	jg     f010661b <vsnprintf+0x1b>
f0106614:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0106619:	eb 3b                	jmp    f0106656 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f010661b:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010661e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0106622:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0106625:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010662c:	8b 45 14             	mov    0x14(%ebp),%eax
f010662f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106633:	8b 45 10             	mov    0x10(%ebp),%eax
f0106636:	89 44 24 08          	mov    %eax,0x8(%esp)
f010663a:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010663d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106641:	c7 04 24 50 61 10 f0 	movl   $0xf0106150,(%esp)
f0106648:	e8 20 fb ff ff       	call   f010616d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010664d:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0106650:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0106653:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0106656:	c9                   	leave  
f0106657:	c3                   	ret    

f0106658 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0106658:	55                   	push   %ebp
f0106659:	89 e5                	mov    %esp,%ebp
f010665b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f010665e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f0106661:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106665:	8b 45 10             	mov    0x10(%ebp),%eax
f0106668:	89 44 24 08          	mov    %eax,0x8(%esp)
f010666c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010666f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106673:	8b 45 08             	mov    0x8(%ebp),%eax
f0106676:	89 04 24             	mov    %eax,(%esp)
f0106679:	e8 82 ff ff ff       	call   f0106600 <vsnprintf>
	va_end(ap);

	return rc;
}
f010667e:	c9                   	leave  
f010667f:	c3                   	ret    

f0106680 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0106680:	55                   	push   %ebp
f0106681:	89 e5                	mov    %esp,%ebp
f0106683:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f0106686:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f0106689:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010668d:	8b 45 10             	mov    0x10(%ebp),%eax
f0106690:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106694:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106697:	89 44 24 04          	mov    %eax,0x4(%esp)
f010669b:	8b 45 08             	mov    0x8(%ebp),%eax
f010669e:	89 04 24             	mov    %eax,(%esp)
f01066a1:	e8 c7 fa ff ff       	call   f010616d <vprintfmt>
	va_end(ap);
}
f01066a6:	c9                   	leave  
f01066a7:	c3                   	ret    
	...

f01066b0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01066b0:	55                   	push   %ebp
f01066b1:	89 e5                	mov    %esp,%ebp
f01066b3:	57                   	push   %edi
f01066b4:	56                   	push   %esi
f01066b5:	53                   	push   %ebx
f01066b6:	83 ec 1c             	sub    $0x1c,%esp
f01066b9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01066bc:	85 c0                	test   %eax,%eax
f01066be:	74 10                	je     f01066d0 <readline+0x20>
		cprintf("%s", prompt);
f01066c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066c4:	c7 04 24 d9 8c 10 f0 	movl   $0xf0108cd9,(%esp)
f01066cb:	e8 7b dd ff ff       	call   f010444b <cprintf>

	i = 0;
	echoing = iscons(0);
f01066d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01066d7:	e8 24 9e ff ff       	call   f0100500 <iscons>
f01066dc:	89 c7                	mov    %eax,%edi
f01066de:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f01066e3:	e8 07 9e ff ff       	call   f01004ef <getchar>
f01066e8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01066ea:	85 c0                	test   %eax,%eax
f01066ec:	79 17                	jns    f0106705 <readline+0x55>
			cprintf("read error: %e\n", c);
f01066ee:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066f2:	c7 04 24 20 99 10 f0 	movl   $0xf0109920,(%esp)
f01066f9:	e8 4d dd ff ff       	call   f010444b <cprintf>
f01066fe:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0106703:	eb 76                	jmp    f010677b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106705:	83 f8 08             	cmp    $0x8,%eax
f0106708:	74 08                	je     f0106712 <readline+0x62>
f010670a:	83 f8 7f             	cmp    $0x7f,%eax
f010670d:	8d 76 00             	lea    0x0(%esi),%esi
f0106710:	75 19                	jne    f010672b <readline+0x7b>
f0106712:	85 f6                	test   %esi,%esi
f0106714:	7e 15                	jle    f010672b <readline+0x7b>
			if (echoing)
f0106716:	85 ff                	test   %edi,%edi
f0106718:	74 0c                	je     f0106726 <readline+0x76>
				cputchar('\b');
f010671a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0106721:	e8 e4 9f ff ff       	call   f010070a <cputchar>
			i--;
f0106726:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0106729:	eb b8                	jmp    f01066e3 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f010672b:	83 fb 1f             	cmp    $0x1f,%ebx
f010672e:	66 90                	xchg   %ax,%ax
f0106730:	7e 23                	jle    f0106755 <readline+0xa5>
f0106732:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0106738:	7f 1b                	jg     f0106755 <readline+0xa5>
			if (echoing)
f010673a:	85 ff                	test   %edi,%edi
f010673c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106740:	74 08                	je     f010674a <readline+0x9a>
				cputchar(c);
f0106742:	89 1c 24             	mov    %ebx,(%esp)
f0106745:	e8 c0 9f ff ff       	call   f010070a <cputchar>
			buf[i++] = c;
f010674a:	88 9e 80 5a 27 f0    	mov    %bl,-0xfd8a580(%esi)
f0106750:	83 c6 01             	add    $0x1,%esi
f0106753:	eb 8e                	jmp    f01066e3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0106755:	83 fb 0a             	cmp    $0xa,%ebx
f0106758:	74 05                	je     f010675f <readline+0xaf>
f010675a:	83 fb 0d             	cmp    $0xd,%ebx
f010675d:	75 84                	jne    f01066e3 <readline+0x33>
			if (echoing)
f010675f:	85 ff                	test   %edi,%edi
f0106761:	74 0c                	je     f010676f <readline+0xbf>
				cputchar('\n');
f0106763:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010676a:	e8 9b 9f ff ff       	call   f010070a <cputchar>
			buf[i] = 0;
f010676f:	c6 86 80 5a 27 f0 00 	movb   $0x0,-0xfd8a580(%esi)
f0106776:	b8 80 5a 27 f0       	mov    $0xf0275a80,%eax
			return buf;
		}
	}
}
f010677b:	83 c4 1c             	add    $0x1c,%esp
f010677e:	5b                   	pop    %ebx
f010677f:	5e                   	pop    %esi
f0106780:	5f                   	pop    %edi
f0106781:	5d                   	pop    %ebp
f0106782:	c3                   	ret    
	...

f0106790 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0106790:	55                   	push   %ebp
f0106791:	89 e5                	mov    %esp,%ebp
f0106793:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0106796:	b8 00 00 00 00       	mov    $0x0,%eax
f010679b:	80 3a 00             	cmpb   $0x0,(%edx)
f010679e:	74 09                	je     f01067a9 <strlen+0x19>
		n++;
f01067a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01067a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01067a7:	75 f7                	jne    f01067a0 <strlen+0x10>
		n++;
	return n;
}
f01067a9:	5d                   	pop    %ebp
f01067aa:	c3                   	ret    

f01067ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01067ab:	55                   	push   %ebp
f01067ac:	89 e5                	mov    %esp,%ebp
f01067ae:	53                   	push   %ebx
f01067af:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01067b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01067b5:	85 c9                	test   %ecx,%ecx
f01067b7:	74 19                	je     f01067d2 <strnlen+0x27>
f01067b9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01067bc:	74 14                	je     f01067d2 <strnlen+0x27>
f01067be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01067c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01067c6:	39 c8                	cmp    %ecx,%eax
f01067c8:	74 0d                	je     f01067d7 <strnlen+0x2c>
f01067ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01067ce:	75 f3                	jne    f01067c3 <strnlen+0x18>
f01067d0:	eb 05                	jmp    f01067d7 <strnlen+0x2c>
f01067d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01067d7:	5b                   	pop    %ebx
f01067d8:	5d                   	pop    %ebp
f01067d9:	c3                   	ret    

f01067da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01067da:	55                   	push   %ebp
f01067db:	89 e5                	mov    %esp,%ebp
f01067dd:	53                   	push   %ebx
f01067de:	8b 45 08             	mov    0x8(%ebp),%eax
f01067e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01067e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01067e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f01067ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01067f0:	83 c2 01             	add    $0x1,%edx
f01067f3:	84 c9                	test   %cl,%cl
f01067f5:	75 f2                	jne    f01067e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01067f7:	5b                   	pop    %ebx
f01067f8:	5d                   	pop    %ebp
f01067f9:	c3                   	ret    

f01067fa <strcat>:

char *
strcat(char *dst, const char *src)
{
f01067fa:	55                   	push   %ebp
f01067fb:	89 e5                	mov    %esp,%ebp
f01067fd:	53                   	push   %ebx
f01067fe:	83 ec 08             	sub    $0x8,%esp
f0106801:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0106804:	89 1c 24             	mov    %ebx,(%esp)
f0106807:	e8 84 ff ff ff       	call   f0106790 <strlen>
	strcpy(dst + len, src);
f010680c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010680f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106813:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0106816:	89 04 24             	mov    %eax,(%esp)
f0106819:	e8 bc ff ff ff       	call   f01067da <strcpy>
	return dst;
}
f010681e:	89 d8                	mov    %ebx,%eax
f0106820:	83 c4 08             	add    $0x8,%esp
f0106823:	5b                   	pop    %ebx
f0106824:	5d                   	pop    %ebp
f0106825:	c3                   	ret    

f0106826 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0106826:	55                   	push   %ebp
f0106827:	89 e5                	mov    %esp,%ebp
f0106829:	56                   	push   %esi
f010682a:	53                   	push   %ebx
f010682b:	8b 45 08             	mov    0x8(%ebp),%eax
f010682e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106831:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106834:	85 f6                	test   %esi,%esi
f0106836:	74 18                	je     f0106850 <strncpy+0x2a>
f0106838:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010683d:	0f b6 1a             	movzbl (%edx),%ebx
f0106840:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0106843:	80 3a 01             	cmpb   $0x1,(%edx)
f0106846:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0106849:	83 c1 01             	add    $0x1,%ecx
f010684c:	39 ce                	cmp    %ecx,%esi
f010684e:	77 ed                	ja     f010683d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0106850:	5b                   	pop    %ebx
f0106851:	5e                   	pop    %esi
f0106852:	5d                   	pop    %ebp
f0106853:	c3                   	ret    

f0106854 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0106854:	55                   	push   %ebp
f0106855:	89 e5                	mov    %esp,%ebp
f0106857:	56                   	push   %esi
f0106858:	53                   	push   %ebx
f0106859:	8b 75 08             	mov    0x8(%ebp),%esi
f010685c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010685f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0106862:	89 f0                	mov    %esi,%eax
f0106864:	85 c9                	test   %ecx,%ecx
f0106866:	74 27                	je     f010688f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0106868:	83 e9 01             	sub    $0x1,%ecx
f010686b:	74 1d                	je     f010688a <strlcpy+0x36>
f010686d:	0f b6 1a             	movzbl (%edx),%ebx
f0106870:	84 db                	test   %bl,%bl
f0106872:	74 16                	je     f010688a <strlcpy+0x36>
			*dst++ = *src++;
f0106874:	88 18                	mov    %bl,(%eax)
f0106876:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106879:	83 e9 01             	sub    $0x1,%ecx
f010687c:	74 0e                	je     f010688c <strlcpy+0x38>
			*dst++ = *src++;
f010687e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0106881:	0f b6 1a             	movzbl (%edx),%ebx
f0106884:	84 db                	test   %bl,%bl
f0106886:	75 ec                	jne    f0106874 <strlcpy+0x20>
f0106888:	eb 02                	jmp    f010688c <strlcpy+0x38>
f010688a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f010688c:	c6 00 00             	movb   $0x0,(%eax)
f010688f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f0106891:	5b                   	pop    %ebx
f0106892:	5e                   	pop    %esi
f0106893:	5d                   	pop    %ebp
f0106894:	c3                   	ret    

f0106895 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0106895:	55                   	push   %ebp
f0106896:	89 e5                	mov    %esp,%ebp
f0106898:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010689b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010689e:	0f b6 01             	movzbl (%ecx),%eax
f01068a1:	84 c0                	test   %al,%al
f01068a3:	74 15                	je     f01068ba <strcmp+0x25>
f01068a5:	3a 02                	cmp    (%edx),%al
f01068a7:	75 11                	jne    f01068ba <strcmp+0x25>
		p++, q++;
f01068a9:	83 c1 01             	add    $0x1,%ecx
f01068ac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01068af:	0f b6 01             	movzbl (%ecx),%eax
f01068b2:	84 c0                	test   %al,%al
f01068b4:	74 04                	je     f01068ba <strcmp+0x25>
f01068b6:	3a 02                	cmp    (%edx),%al
f01068b8:	74 ef                	je     f01068a9 <strcmp+0x14>
f01068ba:	0f b6 c0             	movzbl %al,%eax
f01068bd:	0f b6 12             	movzbl (%edx),%edx
f01068c0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01068c2:	5d                   	pop    %ebp
f01068c3:	c3                   	ret    

f01068c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01068c4:	55                   	push   %ebp
f01068c5:	89 e5                	mov    %esp,%ebp
f01068c7:	53                   	push   %ebx
f01068c8:	8b 55 08             	mov    0x8(%ebp),%edx
f01068cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01068ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01068d1:	85 c0                	test   %eax,%eax
f01068d3:	74 23                	je     f01068f8 <strncmp+0x34>
f01068d5:	0f b6 1a             	movzbl (%edx),%ebx
f01068d8:	84 db                	test   %bl,%bl
f01068da:	74 25                	je     f0106901 <strncmp+0x3d>
f01068dc:	3a 19                	cmp    (%ecx),%bl
f01068de:	75 21                	jne    f0106901 <strncmp+0x3d>
f01068e0:	83 e8 01             	sub    $0x1,%eax
f01068e3:	74 13                	je     f01068f8 <strncmp+0x34>
		n--, p++, q++;
f01068e5:	83 c2 01             	add    $0x1,%edx
f01068e8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01068eb:	0f b6 1a             	movzbl (%edx),%ebx
f01068ee:	84 db                	test   %bl,%bl
f01068f0:	74 0f                	je     f0106901 <strncmp+0x3d>
f01068f2:	3a 19                	cmp    (%ecx),%bl
f01068f4:	74 ea                	je     f01068e0 <strncmp+0x1c>
f01068f6:	eb 09                	jmp    f0106901 <strncmp+0x3d>
f01068f8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01068fd:	5b                   	pop    %ebx
f01068fe:	5d                   	pop    %ebp
f01068ff:	90                   	nop
f0106900:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0106901:	0f b6 02             	movzbl (%edx),%eax
f0106904:	0f b6 11             	movzbl (%ecx),%edx
f0106907:	29 d0                	sub    %edx,%eax
f0106909:	eb f2                	jmp    f01068fd <strncmp+0x39>

f010690b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010690b:	55                   	push   %ebp
f010690c:	89 e5                	mov    %esp,%ebp
f010690e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106915:	0f b6 10             	movzbl (%eax),%edx
f0106918:	84 d2                	test   %dl,%dl
f010691a:	74 18                	je     f0106934 <strchr+0x29>
		if (*s == c)
f010691c:	38 ca                	cmp    %cl,%dl
f010691e:	75 0a                	jne    f010692a <strchr+0x1f>
f0106920:	eb 17                	jmp    f0106939 <strchr+0x2e>
f0106922:	38 ca                	cmp    %cl,%dl
f0106924:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106928:	74 0f                	je     f0106939 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010692a:	83 c0 01             	add    $0x1,%eax
f010692d:	0f b6 10             	movzbl (%eax),%edx
f0106930:	84 d2                	test   %dl,%dl
f0106932:	75 ee                	jne    f0106922 <strchr+0x17>
f0106934:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0106939:	5d                   	pop    %ebp
f010693a:	c3                   	ret    

f010693b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010693b:	55                   	push   %ebp
f010693c:	89 e5                	mov    %esp,%ebp
f010693e:	8b 45 08             	mov    0x8(%ebp),%eax
f0106941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0106945:	0f b6 10             	movzbl (%eax),%edx
f0106948:	84 d2                	test   %dl,%dl
f010694a:	74 18                	je     f0106964 <strfind+0x29>
		if (*s == c)
f010694c:	38 ca                	cmp    %cl,%dl
f010694e:	75 0a                	jne    f010695a <strfind+0x1f>
f0106950:	eb 12                	jmp    f0106964 <strfind+0x29>
f0106952:	38 ca                	cmp    %cl,%dl
f0106954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106958:	74 0a                	je     f0106964 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010695a:	83 c0 01             	add    $0x1,%eax
f010695d:	0f b6 10             	movzbl (%eax),%edx
f0106960:	84 d2                	test   %dl,%dl
f0106962:	75 ee                	jne    f0106952 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0106964:	5d                   	pop    %ebp
f0106965:	c3                   	ret    

f0106966 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0106966:	55                   	push   %ebp
f0106967:	89 e5                	mov    %esp,%ebp
f0106969:	83 ec 0c             	sub    $0xc,%esp
f010696c:	89 1c 24             	mov    %ebx,(%esp)
f010696f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106973:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0106977:	8b 7d 08             	mov    0x8(%ebp),%edi
f010697a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010697d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0106980:	85 c9                	test   %ecx,%ecx
f0106982:	74 30                	je     f01069b4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0106984:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010698a:	75 25                	jne    f01069b1 <memset+0x4b>
f010698c:	f6 c1 03             	test   $0x3,%cl
f010698f:	75 20                	jne    f01069b1 <memset+0x4b>
		c &= 0xFF;
f0106991:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0106994:	89 d3                	mov    %edx,%ebx
f0106996:	c1 e3 08             	shl    $0x8,%ebx
f0106999:	89 d6                	mov    %edx,%esi
f010699b:	c1 e6 18             	shl    $0x18,%esi
f010699e:	89 d0                	mov    %edx,%eax
f01069a0:	c1 e0 10             	shl    $0x10,%eax
f01069a3:	09 f0                	or     %esi,%eax
f01069a5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f01069a7:	09 d8                	or     %ebx,%eax
f01069a9:	c1 e9 02             	shr    $0x2,%ecx
f01069ac:	fc                   	cld    
f01069ad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01069af:	eb 03                	jmp    f01069b4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01069b1:	fc                   	cld    
f01069b2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01069b4:	89 f8                	mov    %edi,%eax
f01069b6:	8b 1c 24             	mov    (%esp),%ebx
f01069b9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01069bd:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01069c1:	89 ec                	mov    %ebp,%esp
f01069c3:	5d                   	pop    %ebp
f01069c4:	c3                   	ret    

f01069c5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01069c5:	55                   	push   %ebp
f01069c6:	89 e5                	mov    %esp,%ebp
f01069c8:	83 ec 08             	sub    $0x8,%esp
f01069cb:	89 34 24             	mov    %esi,(%esp)
f01069ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01069d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01069d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
f01069d8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f01069db:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f01069dd:	39 c6                	cmp    %eax,%esi
f01069df:	73 35                	jae    f0106a16 <memmove+0x51>
f01069e1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01069e4:	39 d0                	cmp    %edx,%eax
f01069e6:	73 2e                	jae    f0106a16 <memmove+0x51>
		s += n;
		d += n;
f01069e8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01069ea:	f6 c2 03             	test   $0x3,%dl
f01069ed:	75 1b                	jne    f0106a0a <memmove+0x45>
f01069ef:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01069f5:	75 13                	jne    f0106a0a <memmove+0x45>
f01069f7:	f6 c1 03             	test   $0x3,%cl
f01069fa:	75 0e                	jne    f0106a0a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f01069fc:	83 ef 04             	sub    $0x4,%edi
f01069ff:	8d 72 fc             	lea    -0x4(%edx),%esi
f0106a02:	c1 e9 02             	shr    $0x2,%ecx
f0106a05:	fd                   	std    
f0106a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106a08:	eb 09                	jmp    f0106a13 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0106a0a:	83 ef 01             	sub    $0x1,%edi
f0106a0d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0106a10:	fd                   	std    
f0106a11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0106a13:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0106a14:	eb 20                	jmp    f0106a36 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106a16:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0106a1c:	75 15                	jne    f0106a33 <memmove+0x6e>
f0106a1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0106a24:	75 0d                	jne    f0106a33 <memmove+0x6e>
f0106a26:	f6 c1 03             	test   $0x3,%cl
f0106a29:	75 08                	jne    f0106a33 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f0106a2b:	c1 e9 02             	shr    $0x2,%ecx
f0106a2e:	fc                   	cld    
f0106a2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0106a31:	eb 03                	jmp    f0106a36 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0106a33:	fc                   	cld    
f0106a34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0106a36:	8b 34 24             	mov    (%esp),%esi
f0106a39:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106a3d:	89 ec                	mov    %ebp,%esp
f0106a3f:	5d                   	pop    %ebp
f0106a40:	c3                   	ret    

f0106a41 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
f0106a41:	55                   	push   %ebp
f0106a42:	89 e5                	mov    %esp,%ebp
f0106a44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0106a47:	8b 45 10             	mov    0x10(%ebp),%eax
f0106a4a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0106a51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106a55:	8b 45 08             	mov    0x8(%ebp),%eax
f0106a58:	89 04 24             	mov    %eax,(%esp)
f0106a5b:	e8 65 ff ff ff       	call   f01069c5 <memmove>
}
f0106a60:	c9                   	leave  
f0106a61:	c3                   	ret    

f0106a62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0106a62:	55                   	push   %ebp
f0106a63:	89 e5                	mov    %esp,%ebp
f0106a65:	57                   	push   %edi
f0106a66:	56                   	push   %esi
f0106a67:	53                   	push   %ebx
f0106a68:	8b 75 08             	mov    0x8(%ebp),%esi
f0106a6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0106a6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106a71:	85 c9                	test   %ecx,%ecx
f0106a73:	74 36                	je     f0106aab <memcmp+0x49>
		if (*s1 != *s2)
f0106a75:	0f b6 06             	movzbl (%esi),%eax
f0106a78:	0f b6 1f             	movzbl (%edi),%ebx
f0106a7b:	38 d8                	cmp    %bl,%al
f0106a7d:	74 20                	je     f0106a9f <memcmp+0x3d>
f0106a7f:	eb 14                	jmp    f0106a95 <memcmp+0x33>
f0106a81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f0106a86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f0106a8b:	83 c2 01             	add    $0x1,%edx
f0106a8e:	83 e9 01             	sub    $0x1,%ecx
f0106a91:	38 d8                	cmp    %bl,%al
f0106a93:	74 12                	je     f0106aa7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f0106a95:	0f b6 c0             	movzbl %al,%eax
f0106a98:	0f b6 db             	movzbl %bl,%ebx
f0106a9b:	29 d8                	sub    %ebx,%eax
f0106a9d:	eb 11                	jmp    f0106ab0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0106a9f:	83 e9 01             	sub    $0x1,%ecx
f0106aa2:	ba 00 00 00 00       	mov    $0x0,%edx
f0106aa7:	85 c9                	test   %ecx,%ecx
f0106aa9:	75 d6                	jne    f0106a81 <memcmp+0x1f>
f0106aab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f0106ab0:	5b                   	pop    %ebx
f0106ab1:	5e                   	pop    %esi
f0106ab2:	5f                   	pop    %edi
f0106ab3:	5d                   	pop    %ebp
f0106ab4:	c3                   	ret    

f0106ab5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0106ab5:	55                   	push   %ebp
f0106ab6:	89 e5                	mov    %esp,%ebp
f0106ab8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f0106abb:	89 c2                	mov    %eax,%edx
f0106abd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0106ac0:	39 d0                	cmp    %edx,%eax
f0106ac2:	73 15                	jae    f0106ad9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0106ac4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f0106ac8:	38 08                	cmp    %cl,(%eax)
f0106aca:	75 06                	jne    f0106ad2 <memfind+0x1d>
f0106acc:	eb 0b                	jmp    f0106ad9 <memfind+0x24>
f0106ace:	38 08                	cmp    %cl,(%eax)
f0106ad0:	74 07                	je     f0106ad9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0106ad2:	83 c0 01             	add    $0x1,%eax
f0106ad5:	39 c2                	cmp    %eax,%edx
f0106ad7:	77 f5                	ja     f0106ace <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0106ad9:	5d                   	pop    %ebp
f0106ada:	c3                   	ret    

f0106adb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0106adb:	55                   	push   %ebp
f0106adc:	89 e5                	mov    %esp,%ebp
f0106ade:	57                   	push   %edi
f0106adf:	56                   	push   %esi
f0106ae0:	53                   	push   %ebx
f0106ae1:	83 ec 04             	sub    $0x4,%esp
f0106ae4:	8b 55 08             	mov    0x8(%ebp),%edx
f0106ae7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106aea:	0f b6 02             	movzbl (%edx),%eax
f0106aed:	3c 20                	cmp    $0x20,%al
f0106aef:	74 04                	je     f0106af5 <strtol+0x1a>
f0106af1:	3c 09                	cmp    $0x9,%al
f0106af3:	75 0e                	jne    f0106b03 <strtol+0x28>
		s++;
f0106af5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0106af8:	0f b6 02             	movzbl (%edx),%eax
f0106afb:	3c 20                	cmp    $0x20,%al
f0106afd:	74 f6                	je     f0106af5 <strtol+0x1a>
f0106aff:	3c 09                	cmp    $0x9,%al
f0106b01:	74 f2                	je     f0106af5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0106b03:	3c 2b                	cmp    $0x2b,%al
f0106b05:	75 0c                	jne    f0106b13 <strtol+0x38>
		s++;
f0106b07:	83 c2 01             	add    $0x1,%edx
f0106b0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0106b11:	eb 15                	jmp    f0106b28 <strtol+0x4d>
	else if (*s == '-')
f0106b13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0106b1a:	3c 2d                	cmp    $0x2d,%al
f0106b1c:	75 0a                	jne    f0106b28 <strtol+0x4d>
		s++, neg = 1;
f0106b1e:	83 c2 01             	add    $0x1,%edx
f0106b21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106b28:	85 db                	test   %ebx,%ebx
f0106b2a:	0f 94 c0             	sete   %al
f0106b2d:	74 05                	je     f0106b34 <strtol+0x59>
f0106b2f:	83 fb 10             	cmp    $0x10,%ebx
f0106b32:	75 18                	jne    f0106b4c <strtol+0x71>
f0106b34:	80 3a 30             	cmpb   $0x30,(%edx)
f0106b37:	75 13                	jne    f0106b4c <strtol+0x71>
f0106b39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0106b3d:	8d 76 00             	lea    0x0(%esi),%esi
f0106b40:	75 0a                	jne    f0106b4c <strtol+0x71>
		s += 2, base = 16;
f0106b42:	83 c2 02             	add    $0x2,%edx
f0106b45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0106b4a:	eb 15                	jmp    f0106b61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106b4c:	84 c0                	test   %al,%al
f0106b4e:	66 90                	xchg   %ax,%ax
f0106b50:	74 0f                	je     f0106b61 <strtol+0x86>
f0106b52:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0106b57:	80 3a 30             	cmpb   $0x30,(%edx)
f0106b5a:	75 05                	jne    f0106b61 <strtol+0x86>
		s++, base = 8;
f0106b5c:	83 c2 01             	add    $0x1,%edx
f0106b5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0106b61:	b8 00 00 00 00       	mov    $0x0,%eax
f0106b66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0106b68:	0f b6 0a             	movzbl (%edx),%ecx
f0106b6b:	89 cf                	mov    %ecx,%edi
f0106b6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0106b70:	80 fb 09             	cmp    $0x9,%bl
f0106b73:	77 08                	ja     f0106b7d <strtol+0xa2>
			dig = *s - '0';
f0106b75:	0f be c9             	movsbl %cl,%ecx
f0106b78:	83 e9 30             	sub    $0x30,%ecx
f0106b7b:	eb 1e                	jmp    f0106b9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f0106b7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f0106b80:	80 fb 19             	cmp    $0x19,%bl
f0106b83:	77 08                	ja     f0106b8d <strtol+0xb2>
			dig = *s - 'a' + 10;
f0106b85:	0f be c9             	movsbl %cl,%ecx
f0106b88:	83 e9 57             	sub    $0x57,%ecx
f0106b8b:	eb 0e                	jmp    f0106b9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f0106b8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
f0106b90:	80 fb 19             	cmp    $0x19,%bl
f0106b93:	77 15                	ja     f0106baa <strtol+0xcf>
			dig = *s - 'A' + 10;
f0106b95:	0f be c9             	movsbl %cl,%ecx
f0106b98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0106b9b:	39 f1                	cmp    %esi,%ecx
f0106b9d:	7d 0b                	jge    f0106baa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f0106b9f:	83 c2 01             	add    $0x1,%edx
f0106ba2:	0f af c6             	imul   %esi,%eax
f0106ba5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0106ba8:	eb be                	jmp    f0106b68 <strtol+0x8d>
f0106baa:	89 c1                	mov    %eax,%ecx

	if (endptr)
f0106bac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0106bb0:	74 05                	je     f0106bb7 <strtol+0xdc>
		*endptr = (char *) s;
f0106bb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0106bb5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0106bb7:	89 ca                	mov    %ecx,%edx
f0106bb9:	f7 da                	neg    %edx
f0106bbb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f0106bbf:	0f 45 c2             	cmovne %edx,%eax
}
f0106bc2:	83 c4 04             	add    $0x4,%esp
f0106bc5:	5b                   	pop    %ebx
f0106bc6:	5e                   	pop    %esi
f0106bc7:	5f                   	pop    %edi
f0106bc8:	5d                   	pop    %ebp
f0106bc9:	c3                   	ret    
	...

f0106bcc <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0106bcc:	fa                   	cli    

	xorw    %ax, %ax
f0106bcd:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0106bcf:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106bd1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106bd3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0106bd5:	0f 01 16             	lgdtl  (%esi)
f0106bd8:	74 70                	je     f0106c4a <mpentry_end+0x4>
	movl    %cr0, %eax
f0106bda:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0106bdd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0106be1:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0106be4:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0106bea:	08 00                	or     %al,(%eax)

f0106bec <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106bec:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106bf0:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106bf2:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106bf4:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0106bf6:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0106bfa:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106bfc:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106bfe:	b8 00 30 12 00       	mov    $0x123000,%eax
	movl    %eax, %cr3
f0106c03:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0106c06:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0106c09:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106c0e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in mem_init()
	movl    mpentry_kstack, %esp
f0106c11:	8b 25 90 5e 27 f0    	mov    0xf0275e90,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0106c17:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106c1c:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f0106c21:	ff d0                	call   *%eax

f0106c23 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106c23:	eb fe                	jmp    f0106c23 <spin>
f0106c25:	8d 76 00             	lea    0x0(%esi),%esi

f0106c28 <gdt>:
	...
f0106c30:	ff                   	(bad)  
f0106c31:	ff 00                	incl   (%eax)
f0106c33:	00 00                	add    %al,(%eax)
f0106c35:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106c3c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106c40 <gdtdesc>:
f0106c40:	17                   	pop    %ss
f0106c41:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0106c46 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0106c46:	90                   	nop
	...

f0106c50 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0106c50:	55                   	push   %ebp
f0106c51:	89 e5                	mov    %esp,%ebp
f0106c53:	56                   	push   %esi
f0106c54:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106c55:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0106c5f:	85 d2                	test   %edx,%edx
f0106c61:	7e 0d                	jle    f0106c70 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0106c63:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106c67:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106c69:	83 c1 01             	add    $0x1,%ecx
f0106c6c:	39 d1                	cmp    %edx,%ecx
f0106c6e:	75 f3                	jne    f0106c63 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106c70:	89 d8                	mov    %ebx,%eax
f0106c72:	5b                   	pop    %ebx
f0106c73:	5e                   	pop    %esi
f0106c74:	5d                   	pop    %ebp
f0106c75:	c3                   	ret    

f0106c76 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0106c76:	55                   	push   %ebp
f0106c77:	89 e5                	mov    %esp,%ebp
f0106c79:	56                   	push   %esi
f0106c7a:	53                   	push   %ebx
f0106c7b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106c7e:	8b 0d 94 5e 27 f0    	mov    0xf0275e94,%ecx
f0106c84:	89 c3                	mov    %eax,%ebx
f0106c86:	c1 eb 0c             	shr    $0xc,%ebx
f0106c89:	39 cb                	cmp    %ecx,%ebx
f0106c8b:	72 20                	jb     f0106cad <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106c8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106c91:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0106c98:	f0 
f0106c99:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106ca0:	00 
f0106ca1:	c7 04 24 bd 9a 10 f0 	movl   $0xf0109abd,(%esp)
f0106ca8:	e8 d8 93 ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0106cad:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106cb0:	89 f2                	mov    %esi,%edx
f0106cb2:	c1 ea 0c             	shr    $0xc,%edx
f0106cb5:	39 d1                	cmp    %edx,%ecx
f0106cb7:	77 20                	ja     f0106cd9 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106cb9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106cbd:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0106cc4:	f0 
f0106cc5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0106ccc:	00 
f0106ccd:	c7 04 24 bd 9a 10 f0 	movl   $0xf0109abd,(%esp)
f0106cd4:	e8 ac 93 ff ff       	call   f0100085 <_panic>
f0106cd9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0106cdf:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106ce5:	39 f3                	cmp    %esi,%ebx
f0106ce7:	73 33                	jae    f0106d1c <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106ce9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106cf0:	00 
f0106cf1:	c7 44 24 04 cd 9a 10 	movl   $0xf0109acd,0x4(%esp)
f0106cf8:	f0 
f0106cf9:	89 1c 24             	mov    %ebx,(%esp)
f0106cfc:	e8 61 fd ff ff       	call   f0106a62 <memcmp>
f0106d01:	85 c0                	test   %eax,%eax
f0106d03:	75 10                	jne    f0106d15 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0106d05:	ba 10 00 00 00       	mov    $0x10,%edx
f0106d0a:	89 d8                	mov    %ebx,%eax
f0106d0c:	e8 3f ff ff ff       	call   f0106c50 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106d11:	84 c0                	test   %al,%al
f0106d13:	74 0c                	je     f0106d21 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106d15:	83 c3 10             	add    $0x10,%ebx
f0106d18:	39 de                	cmp    %ebx,%esi
f0106d1a:	77 cd                	ja     f0106ce9 <mpsearch1+0x73>
f0106d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f0106d21:	89 d8                	mov    %ebx,%eax
f0106d23:	83 c4 10             	add    $0x10,%esp
f0106d26:	5b                   	pop    %ebx
f0106d27:	5e                   	pop    %esi
f0106d28:	5d                   	pop    %ebp
f0106d29:	c3                   	ret    

f0106d2a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106d2a:	55                   	push   %ebp
f0106d2b:	89 e5                	mov    %esp,%ebp
f0106d2d:	57                   	push   %edi
f0106d2e:	56                   	push   %esi
f0106d2f:	53                   	push   %ebx
f0106d30:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106d33:	c7 05 c0 83 27 f0 20 	movl   $0xf0278020,0xf02783c0
f0106d3a:	80 27 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106d3d:	83 3d 94 5e 27 f0 00 	cmpl   $0x0,0xf0275e94
f0106d44:	75 24                	jne    f0106d6a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106d46:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106d4d:	00 
f0106d4e:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0106d55:	f0 
f0106d56:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106d5d:	00 
f0106d5e:	c7 04 24 bd 9a 10 f0 	movl   $0xf0109abd,(%esp)
f0106d65:	e8 1b 93 ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106d6a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106d71:	85 c0                	test   %eax,%eax
f0106d73:	74 16                	je     f0106d8b <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0106d75:	c1 e0 04             	shl    $0x4,%eax
f0106d78:	ba 00 04 00 00       	mov    $0x400,%edx
f0106d7d:	e8 f4 fe ff ff       	call   f0106c76 <mpsearch1>
f0106d82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106d85:	85 c0                	test   %eax,%eax
f0106d87:	75 3c                	jne    f0106dc5 <mp_init+0x9b>
f0106d89:	eb 20                	jmp    f0106dab <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0106d8b:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106d92:	c1 e0 0a             	shl    $0xa,%eax
f0106d95:	2d 00 04 00 00       	sub    $0x400,%eax
f0106d9a:	ba 00 04 00 00       	mov    $0x400,%edx
f0106d9f:	e8 d2 fe ff ff       	call   f0106c76 <mpsearch1>
f0106da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0106da7:	85 c0                	test   %eax,%eax
f0106da9:	75 1a                	jne    f0106dc5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0106dab:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106db0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0106db5:	e8 bc fe ff ff       	call   f0106c76 <mpsearch1>
f0106dba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0106dbd:	85 c0                	test   %eax,%eax
f0106dbf:	0f 84 28 02 00 00    	je     f0106fed <mp_init+0x2c3>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106dc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106dc8:	8b 78 04             	mov    0x4(%eax),%edi
f0106dcb:	85 ff                	test   %edi,%edi
f0106dcd:	74 06                	je     f0106dd5 <mp_init+0xab>
f0106dcf:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106dd3:	74 11                	je     f0106de6 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106dd5:	c7 04 24 30 99 10 f0 	movl   $0xf0109930,(%esp)
f0106ddc:	e8 6a d6 ff ff       	call   f010444b <cprintf>
f0106de1:	e9 07 02 00 00       	jmp    f0106fed <mp_init+0x2c3>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106de6:	89 f8                	mov    %edi,%eax
f0106de8:	c1 e8 0c             	shr    $0xc,%eax
f0106deb:	3b 05 94 5e 27 f0    	cmp    0xf0275e94,%eax
f0106df1:	72 20                	jb     f0106e13 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106df3:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0106df7:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f0106dfe:	f0 
f0106dff:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106e06:	00 
f0106e07:	c7 04 24 bd 9a 10 f0 	movl   $0xf0109abd,(%esp)
f0106e0e:	e8 72 92 ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0106e13:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106e19:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106e20:	00 
f0106e21:	c7 44 24 04 d2 9a 10 	movl   $0xf0109ad2,0x4(%esp)
f0106e28:	f0 
f0106e29:	89 3c 24             	mov    %edi,(%esp)
f0106e2c:	e8 31 fc ff ff       	call   f0106a62 <memcmp>
f0106e31:	85 c0                	test   %eax,%eax
f0106e33:	74 11                	je     f0106e46 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106e35:	c7 04 24 60 99 10 f0 	movl   $0xf0109960,(%esp)
f0106e3c:	e8 0a d6 ff ff       	call   f010444b <cprintf>
f0106e41:	e9 a7 01 00 00       	jmp    f0106fed <mp_init+0x2c3>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106e46:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f0106e4a:	89 f8                	mov    %edi,%eax
f0106e4c:	e8 ff fd ff ff       	call   f0106c50 <sum>
f0106e51:	84 c0                	test   %al,%al
f0106e53:	74 11                	je     f0106e66 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106e55:	c7 04 24 94 99 10 f0 	movl   $0xf0109994,(%esp)
f0106e5c:	e8 ea d5 ff ff       	call   f010444b <cprintf>
f0106e61:	e9 87 01 00 00       	jmp    f0106fed <mp_init+0x2c3>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0106e66:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0106e6a:	3c 01                	cmp    $0x1,%al
f0106e6c:	74 1c                	je     f0106e8a <mp_init+0x160>
f0106e6e:	3c 04                	cmp    $0x4,%al
f0106e70:	74 18                	je     f0106e8a <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0106e72:	0f b6 c0             	movzbl %al,%eax
f0106e75:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106e79:	c7 04 24 b8 99 10 f0 	movl   $0xf01099b8,(%esp)
f0106e80:	e8 c6 d5 ff ff       	call   f010444b <cprintf>
f0106e85:	e9 63 01 00 00       	jmp    f0106fed <mp_init+0x2c3>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0106e8a:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0106e8e:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0106e92:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0106e95:	e8 b6 fd ff ff       	call   f0106c50 <sum>
f0106e9a:	3a 47 2a             	cmp    0x2a(%edi),%al
f0106e9d:	74 11                	je     f0106eb0 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106e9f:	c7 04 24 d8 99 10 f0 	movl   $0xf01099d8,(%esp)
f0106ea6:	e8 a0 d5 ff ff       	call   f010444b <cprintf>
f0106eab:	e9 3d 01 00 00       	jmp    f0106fed <mp_init+0x2c3>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0106eb0:	85 ff                	test   %edi,%edi
f0106eb2:	0f 84 35 01 00 00    	je     f0106fed <mp_init+0x2c3>
		return;
	ismp = 1;
f0106eb8:	c7 05 00 80 27 f0 01 	movl   $0x1,0xf0278000
f0106ebf:	00 00 00 
	lapic = (uint32_t *)conf->lapicaddr;
f0106ec2:	8b 47 24             	mov    0x24(%edi),%eax
f0106ec5:	a3 00 90 2b f0       	mov    %eax,0xf02b9000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106eca:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0106ecd:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0106ed2:	0f 84 96 00 00 00    	je     f0106f6e <mp_init+0x244>
f0106ed8:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0106edd:	0f b6 03             	movzbl (%ebx),%eax
f0106ee0:	84 c0                	test   %al,%al
f0106ee2:	74 06                	je     f0106eea <mp_init+0x1c0>
f0106ee4:	3c 04                	cmp    $0x4,%al
f0106ee6:	77 56                	ja     f0106f3e <mp_init+0x214>
f0106ee8:	eb 4f                	jmp    f0106f39 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
f0106eea:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0106eec:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0106ef0:	74 11                	je     f0106f03 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0106ef2:	6b 05 c4 83 27 f0 74 	imul   $0x74,0xf02783c4,%eax
f0106ef9:	05 20 80 27 f0       	add    $0xf0278020,%eax
f0106efe:	a3 c0 83 27 f0       	mov    %eax,0xf02783c0
			if (ncpu < NCPU) {
f0106f03:	a1 c4 83 27 f0       	mov    0xf02783c4,%eax
f0106f08:	83 f8 07             	cmp    $0x7,%eax
f0106f0b:	7f 13                	jg     f0106f20 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f0106f0d:	6b d0 74             	imul   $0x74,%eax,%edx
f0106f10:	88 82 20 80 27 f0    	mov    %al,-0xfd87fe0(%edx)
				ncpu++;
f0106f16:	83 c0 01             	add    $0x1,%eax
f0106f19:	a3 c4 83 27 f0       	mov    %eax,0xf02783c4
f0106f1e:	eb 14                	jmp    f0106f34 <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106f20:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0106f24:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f28:	c7 04 24 08 9a 10 f0 	movl   $0xf0109a08,(%esp)
f0106f2f:	e8 17 d5 ff ff       	call   f010444b <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106f34:	83 c3 14             	add    $0x14,%ebx
			continue;
f0106f37:	eb 26                	jmp    f0106f5f <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106f39:	83 c3 08             	add    $0x8,%ebx
			continue;
f0106f3c:	eb 21                	jmp    f0106f5f <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106f3e:	0f b6 c0             	movzbl %al,%eax
f0106f41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106f45:	c7 04 24 30 9a 10 f0 	movl   $0xf0109a30,(%esp)
f0106f4c:	e8 fa d4 ff ff       	call   f010444b <cprintf>
			ismp = 0;
f0106f51:	c7 05 00 80 27 f0 00 	movl   $0x0,0xf0278000
f0106f58:	00 00 00 
			i = conf->entry;
f0106f5b:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapic = (uint32_t *)conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106f5f:	83 c6 01             	add    $0x1,%esi
f0106f62:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0106f66:	39 f0                	cmp    %esi,%eax
f0106f68:	0f 87 6f ff ff ff    	ja     f0106edd <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106f6e:	a1 c0 83 27 f0       	mov    0xf02783c0,%eax
f0106f73:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0106f7a:	83 3d 00 80 27 f0 00 	cmpl   $0x0,0xf0278000
f0106f81:	75 22                	jne    f0106fa5 <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106f83:	c7 05 c4 83 27 f0 01 	movl   $0x1,0xf02783c4
f0106f8a:	00 00 00 
		lapic = NULL;
f0106f8d:	c7 05 00 90 2b f0 00 	movl   $0x0,0xf02b9000
f0106f94:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106f97:	c7 04 24 50 9a 10 f0 	movl   $0xf0109a50,(%esp)
f0106f9e:	e8 a8 d4 ff ff       	call   f010444b <cprintf>
		return;
f0106fa3:	eb 48                	jmp    f0106fed <mp_init+0x2c3>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0106fa5:	a1 c4 83 27 f0       	mov    0xf02783c4,%eax
f0106faa:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106fae:	a1 c0 83 27 f0       	mov    0xf02783c0,%eax
f0106fb3:	0f b6 00             	movzbl (%eax),%eax
f0106fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106fba:	c7 04 24 d7 9a 10 f0 	movl   $0xf0109ad7,(%esp)
f0106fc1:	e8 85 d4 ff ff       	call   f010444b <cprintf>

	if (mp->imcrp) {
f0106fc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106fc9:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106fcd:	74 1e                	je     f0106fed <mp_init+0x2c3>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106fcf:	c7 04 24 7c 9a 10 f0 	movl   $0xf0109a7c,(%esp)
f0106fd6:	e8 70 d4 ff ff       	call   f010444b <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106fdb:	ba 22 00 00 00       	mov    $0x22,%edx
f0106fe0:	b8 70 00 00 00       	mov    $0x70,%eax
f0106fe5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106fe6:	b2 23                	mov    $0x23,%dl
f0106fe8:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106fe9:	83 c8 01             	or     $0x1,%eax
f0106fec:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106fed:	83 c4 2c             	add    $0x2c,%esp
f0106ff0:	5b                   	pop    %ebx
f0106ff1:	5e                   	pop    %esi
f0106ff2:	5f                   	pop    %edi
f0106ff3:	5d                   	pop    %ebp
f0106ff4:	c3                   	ret    
f0106ff5:	00 00                	add    %al,(%eax)
	...

f0106ff8 <lapicw>:

volatile uint32_t *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
f0106ff8:	55                   	push   %ebp
f0106ff9:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106ffb:	c1 e0 02             	shl    $0x2,%eax
f0106ffe:	03 05 00 90 2b f0    	add    0xf02b9000,%eax
f0107004:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0107006:	a1 00 90 2b f0       	mov    0xf02b9000,%eax
f010700b:	83 c0 20             	add    $0x20,%eax
f010700e:	8b 00                	mov    (%eax),%eax
}
f0107010:	5d                   	pop    %ebp
f0107011:	c3                   	ret    

f0107012 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0107012:	55                   	push   %ebp
f0107013:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0107015:	8b 15 00 90 2b f0    	mov    0xf02b9000,%edx
f010701b:	b8 00 00 00 00       	mov    $0x0,%eax
f0107020:	85 d2                	test   %edx,%edx
f0107022:	74 08                	je     f010702c <cpunum+0x1a>
		return lapic[ID] >> 24;
f0107024:	83 c2 20             	add    $0x20,%edx
f0107027:	8b 02                	mov    (%edx),%eax
f0107029:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f010702c:	5d                   	pop    %ebp
f010702d:	c3                   	ret    

f010702e <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010702e:	55                   	push   %ebp
f010702f:	89 e5                	mov    %esp,%ebp
	if (!lapic) 
f0107031:	83 3d 00 90 2b f0 00 	cmpl   $0x0,0xf02b9000
f0107038:	0f 84 0b 01 00 00    	je     f0107149 <lapic_init+0x11b>
		return;

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010703e:	ba 27 01 00 00       	mov    $0x127,%edx
f0107043:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0107048:	e8 ab ff ff ff       	call   f0106ff8 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010704d:	ba 0b 00 00 00       	mov    $0xb,%edx
f0107052:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0107057:	e8 9c ff ff ff       	call   f0106ff8 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010705c:	ba 20 00 02 00       	mov    $0x20020,%edx
f0107061:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0107066:	e8 8d ff ff ff       	call   f0106ff8 <lapicw>
	lapicw(TICR, 10000000); 
f010706b:	ba 80 96 98 00       	mov    $0x989680,%edx
f0107070:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0107075:	e8 7e ff ff ff       	call   f0106ff8 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010707a:	e8 93 ff ff ff       	call   f0107012 <cpunum>
f010707f:	6b c0 74             	imul   $0x74,%eax,%eax
f0107082:	05 20 80 27 f0       	add    $0xf0278020,%eax
f0107087:	3b 05 c0 83 27 f0    	cmp    0xf02783c0,%eax
f010708d:	74 0f                	je     f010709e <lapic_init+0x70>
		lapicw(LINT0, MASKED);
f010708f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0107094:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0107099:	e8 5a ff ff ff       	call   f0106ff8 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f010709e:	ba 00 00 01 00       	mov    $0x10000,%edx
f01070a3:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01070a8:	e8 4b ff ff ff       	call   f0106ff8 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01070ad:	a1 00 90 2b f0       	mov    0xf02b9000,%eax
f01070b2:	83 c0 30             	add    $0x30,%eax
f01070b5:	8b 00                	mov    (%eax),%eax
f01070b7:	c1 e8 10             	shr    $0x10,%eax
f01070ba:	3c 03                	cmp    $0x3,%al
f01070bc:	76 0f                	jbe    f01070cd <lapic_init+0x9f>
		lapicw(PCINT, MASKED);
f01070be:	ba 00 00 01 00       	mov    $0x10000,%edx
f01070c3:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01070c8:	e8 2b ff ff ff       	call   f0106ff8 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01070cd:	ba 33 00 00 00       	mov    $0x33,%edx
f01070d2:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01070d7:	e8 1c ff ff ff       	call   f0106ff8 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f01070dc:	ba 00 00 00 00       	mov    $0x0,%edx
f01070e1:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01070e6:	e8 0d ff ff ff       	call   f0106ff8 <lapicw>
	lapicw(ESR, 0);
f01070eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01070f0:	b8 a0 00 00 00       	mov    $0xa0,%eax
f01070f5:	e8 fe fe ff ff       	call   f0106ff8 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f01070fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01070ff:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0107104:	e8 ef fe ff ff       	call   f0106ff8 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0107109:	ba 00 00 00 00       	mov    $0x0,%edx
f010710e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107113:	e8 e0 fe ff ff       	call   f0106ff8 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0107118:	ba 00 85 08 00       	mov    $0x88500,%edx
f010711d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107122:	e8 d1 fe ff ff       	call   f0106ff8 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0107127:	8b 15 00 90 2b f0    	mov    0xf02b9000,%edx
f010712d:	81 c2 00 03 00 00    	add    $0x300,%edx
f0107133:	8b 02                	mov    (%edx),%eax
f0107135:	f6 c4 10             	test   $0x10,%ah
f0107138:	75 f9                	jne    f0107133 <lapic_init+0x105>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010713a:	ba 00 00 00 00       	mov    $0x0,%edx
f010713f:	b8 20 00 00 00       	mov    $0x20,%eax
f0107144:	e8 af fe ff ff       	call   f0106ff8 <lapicw>
}
f0107149:	5d                   	pop    %ebp
f010714a:	c3                   	ret    

f010714b <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010714b:	55                   	push   %ebp
f010714c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010714e:	83 3d 00 90 2b f0 00 	cmpl   $0x0,0xf02b9000
f0107155:	74 0f                	je     f0107166 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0107157:	ba 00 00 00 00       	mov    $0x0,%edx
f010715c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0107161:	e8 92 fe ff ff       	call   f0106ff8 <lapicw>
}
f0107166:	5d                   	pop    %ebp
f0107167:	c3                   	ret    

f0107168 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0107168:	55                   	push   %ebp
f0107169:	89 e5                	mov    %esp,%ebp
}
f010716b:	5d                   	pop    %ebp
f010716c:	c3                   	ret    

f010716d <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f010716d:	55                   	push   %ebp
f010716e:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0107170:	8b 55 08             	mov    0x8(%ebp),%edx
f0107173:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0107179:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010717e:	e8 75 fe ff ff       	call   f0106ff8 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0107183:	8b 15 00 90 2b f0    	mov    0xf02b9000,%edx
f0107189:	81 c2 00 03 00 00    	add    $0x300,%edx
f010718f:	8b 02                	mov    (%edx),%eax
f0107191:	f6 c4 10             	test   $0x10,%ah
f0107194:	75 f9                	jne    f010718f <lapic_ipi+0x22>
		;
}
f0107196:	5d                   	pop    %ebp
f0107197:	c3                   	ret    

f0107198 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0107198:	55                   	push   %ebp
f0107199:	89 e5                	mov    %esp,%ebp
f010719b:	56                   	push   %esi
f010719c:	53                   	push   %ebx
f010719d:	83 ec 10             	sub    $0x10,%esp
f01071a0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01071a3:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f01071a7:	ba 70 00 00 00       	mov    $0x70,%edx
f01071ac:	b8 0f 00 00 00       	mov    $0xf,%eax
f01071b1:	ee                   	out    %al,(%dx)
f01071b2:	b2 71                	mov    $0x71,%dl
f01071b4:	b8 0a 00 00 00       	mov    $0xa,%eax
f01071b9:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01071ba:	83 3d 94 5e 27 f0 00 	cmpl   $0x0,0xf0275e94
f01071c1:	75 24                	jne    f01071e7 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01071c3:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01071ca:	00 
f01071cb:	c7 44 24 08 80 80 10 	movl   $0xf0108080,0x8(%esp)
f01071d2:	f0 
f01071d3:	c7 44 24 04 93 00 00 	movl   $0x93,0x4(%esp)
f01071da:	00 
f01071db:	c7 04 24 f4 9a 10 f0 	movl   $0xf0109af4,(%esp)
f01071e2:	e8 9e 8e ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01071e7:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01071ee:	00 00 
	wrv[1] = addr >> 4;
f01071f0:	89 f0                	mov    %esi,%eax
f01071f2:	c1 e8 04             	shr    $0x4,%eax
f01071f5:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01071fb:	c1 e3 18             	shl    $0x18,%ebx
f01071fe:	89 da                	mov    %ebx,%edx
f0107200:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107205:	e8 ee fd ff ff       	call   f0106ff8 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010720a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010720f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107214:	e8 df fd ff ff       	call   f0106ff8 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0107219:	ba 00 85 00 00       	mov    $0x8500,%edx
f010721e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107223:	e8 d0 fd ff ff       	call   f0106ff8 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107228:	c1 ee 0c             	shr    $0xc,%esi
f010722b:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107231:	89 da                	mov    %ebx,%edx
f0107233:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107238:	e8 bb fd ff ff       	call   f0106ff8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010723d:	89 f2                	mov    %esi,%edx
f010723f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0107244:	e8 af fd ff ff       	call   f0106ff8 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0107249:	89 da                	mov    %ebx,%edx
f010724b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0107250:	e8 a3 fd ff ff       	call   f0106ff8 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0107255:	89 f2                	mov    %esi,%edx
f0107257:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010725c:	e8 97 fd ff ff       	call   f0106ff8 <lapicw>
		microdelay(200);
	}
}
f0107261:	83 c4 10             	add    $0x10,%esp
f0107264:	5b                   	pop    %ebx
f0107265:	5e                   	pop    %esi
f0107266:	5d                   	pop    %ebp
f0107267:	c3                   	ret    
	...

f0107270 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0107270:	55                   	push   %ebp
f0107271:	89 e5                	mov    %esp,%ebp
f0107273:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0107276:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f010727c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010727f:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0107282:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0107289:	5d                   	pop    %ebp
f010728a:	c3                   	ret    

f010728b <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f010728b:	55                   	push   %ebp
f010728c:	89 e5                	mov    %esp,%ebp
f010728e:	53                   	push   %ebx
f010728f:	83 ec 04             	sub    $0x4,%esp
f0107292:	89 c2                	mov    %eax,%edx
	return lock->locked && lock->cpu == thiscpu;
f0107294:	b8 00 00 00 00       	mov    $0x0,%eax
f0107299:	83 3a 00             	cmpl   $0x0,(%edx)
f010729c:	74 18                	je     f01072b6 <holding+0x2b>
f010729e:	8b 5a 08             	mov    0x8(%edx),%ebx
f01072a1:	e8 6c fd ff ff       	call   f0107012 <cpunum>
f01072a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01072a9:	05 20 80 27 f0       	add    $0xf0278020,%eax
f01072ae:	39 c3                	cmp    %eax,%ebx
f01072b0:	0f 94 c0             	sete   %al
f01072b3:	0f b6 c0             	movzbl %al,%eax
}
f01072b6:	83 c4 04             	add    $0x4,%esp
f01072b9:	5b                   	pop    %ebx
f01072ba:	5d                   	pop    %ebp
f01072bb:	c3                   	ret    

f01072bc <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01072bc:	55                   	push   %ebp
f01072bd:	89 e5                	mov    %esp,%ebp
f01072bf:	83 ec 78             	sub    $0x78,%esp
f01072c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01072c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01072c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01072cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01072ce:	89 d8                	mov    %ebx,%eax
f01072d0:	e8 b6 ff ff ff       	call   f010728b <holding>
f01072d5:	85 c0                	test   %eax,%eax
f01072d7:	0f 85 d5 00 00 00    	jne    f01073b2 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01072dd:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01072e4:	00 
f01072e5:	8d 43 0c             	lea    0xc(%ebx),%eax
f01072e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01072ec:	8d 45 a8             	lea    -0x58(%ebp),%eax
f01072ef:	89 04 24             	mov    %eax,(%esp)
f01072f2:	e8 ce f6 ff ff       	call   f01069c5 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01072f7:	8b 43 08             	mov    0x8(%ebx),%eax
f01072fa:	0f b6 30             	movzbl (%eax),%esi
f01072fd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107300:	e8 0d fd ff ff       	call   f0107012 <cpunum>
f0107305:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0107309:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010730d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107311:	c7 04 24 04 9b 10 f0 	movl   $0xf0109b04,(%esp)
f0107318:	e8 2e d1 ff ff       	call   f010444b <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010731d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0107320:	85 c0                	test   %eax,%eax
f0107322:	74 72                	je     f0107396 <spin_unlock+0xda>
f0107324:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0107327:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010732a:	8d 75 d0             	lea    -0x30(%ebp),%esi
f010732d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0107331:	89 04 24             	mov    %eax,(%esp)
f0107334:	e8 d5 e9 ff ff       	call   f0105d0e <debuginfo_eip>
f0107339:	85 c0                	test   %eax,%eax
f010733b:	78 39                	js     f0107376 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010733d:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010733f:	89 c2                	mov    %eax,%edx
f0107341:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0107344:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107348:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010734b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010734f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107352:	89 54 24 10          	mov    %edx,0x10(%esp)
f0107356:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0107359:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010735d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0107360:	89 54 24 08          	mov    %edx,0x8(%esp)
f0107364:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107368:	c7 04 24 66 9b 10 f0 	movl   $0xf0109b66,(%esp)
f010736f:	e8 d7 d0 ff ff       	call   f010444b <cprintf>
f0107374:	eb 12                	jmp    f0107388 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0107376:	8b 03                	mov    (%ebx),%eax
f0107378:	89 44 24 04          	mov    %eax,0x4(%esp)
f010737c:	c7 04 24 7d 9b 10 f0 	movl   $0xf0109b7d,(%esp)
f0107383:	e8 c3 d0 ff ff       	call   f010444b <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0107388:	39 fb                	cmp    %edi,%ebx
f010738a:	74 0a                	je     f0107396 <spin_unlock+0xda>
f010738c:	8b 43 04             	mov    0x4(%ebx),%eax
f010738f:	83 c3 04             	add    $0x4,%ebx
f0107392:	85 c0                	test   %eax,%eax
f0107394:	75 97                	jne    f010732d <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0107396:	c7 44 24 08 85 9b 10 	movl   $0xf0109b85,0x8(%esp)
f010739d:	f0 
f010739e:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
f01073a5:	00 
f01073a6:	c7 04 24 91 9b 10 f0 	movl   $0xf0109b91,(%esp)
f01073ad:	e8 d3 8c ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f01073b2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01073b9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01073c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01073c5:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01073c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01073cb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01073ce:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01073d1:	89 ec                	mov    %ebp,%esp
f01073d3:	5d                   	pop    %ebp
f01073d4:	c3                   	ret    

f01073d5 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01073d5:	55                   	push   %ebp
f01073d6:	89 e5                	mov    %esp,%ebp
f01073d8:	56                   	push   %esi
f01073d9:	53                   	push   %ebx
f01073da:	83 ec 20             	sub    $0x20,%esp
f01073dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01073e0:	89 d8                	mov    %ebx,%eax
f01073e2:	e8 a4 fe ff ff       	call   f010728b <holding>
f01073e7:	85 c0                	test   %eax,%eax
f01073e9:	75 12                	jne    f01073fd <spin_lock+0x28>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f01073eb:	89 da                	mov    %ebx,%edx
f01073ed:	b0 01                	mov    $0x1,%al
f01073ef:	f0 87 03             	lock xchg %eax,(%ebx)
f01073f2:	b9 01 00 00 00       	mov    $0x1,%ecx
f01073f7:	85 c0                	test   %eax,%eax
f01073f9:	75 2e                	jne    f0107429 <spin_lock+0x54>
f01073fb:	eb 37                	jmp    f0107434 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01073fd:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0107400:	e8 0d fc ff ff       	call   f0107012 <cpunum>
f0107405:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0107409:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010740d:	c7 44 24 08 3c 9b 10 	movl   $0xf0109b3c,0x8(%esp)
f0107414:	f0 
f0107415:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
f010741c:	00 
f010741d:	c7 04 24 91 9b 10 f0 	movl   $0xf0109b91,(%esp)
f0107424:	e8 5c 8c ff ff       	call   f0100085 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0107429:	f3 90                	pause  
f010742b:	89 c8                	mov    %ecx,%eax
f010742d:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0107430:	85 c0                	test   %eax,%eax
f0107432:	75 f5                	jne    f0107429 <spin_lock+0x54>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0107434:	e8 d9 fb ff ff       	call   f0107012 <cpunum>
f0107439:	6b c0 74             	imul   $0x74,%eax,%eax
f010743c:	05 20 80 27 f0       	add    $0xf0278020,%eax
f0107441:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0107444:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0107447:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
f0107449:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f010744f:	81 fa ff ff 7f 0e    	cmp    $0xe7fffff,%edx
f0107455:	76 40                	jbe    f0107497 <spin_lock+0xc2>
f0107457:	eb 33                	jmp    f010748c <spin_lock+0xb7>
f0107459:	8d 8a 00 00 80 10    	lea    0x10800000(%edx),%ecx
f010745f:	81 f9 ff ff 7f 0e    	cmp    $0xe7fffff,%ecx
f0107465:	77 2a                	ja     f0107491 <spin_lock+0xbc>
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0107467:	8b 4a 04             	mov    0x4(%edx),%ecx
f010746a:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010746d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010746f:	83 c0 01             	add    $0x1,%eax
f0107472:	83 f8 0a             	cmp    $0xa,%eax
f0107475:	75 e2                	jne    f0107459 <spin_lock+0x84>
f0107477:	eb 2d                	jmp    f01074a6 <spin_lock+0xd1>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0107479:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010747f:	83 c0 01             	add    $0x1,%eax
f0107482:	83 c2 04             	add    $0x4,%edx
f0107485:	83 f8 09             	cmp    $0x9,%eax
f0107488:	7e ef                	jle    f0107479 <spin_lock+0xa4>
f010748a:	eb 1a                	jmp    f01074a6 <spin_lock+0xd1>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f010748c:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f0107491:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f0107495:	eb e2                	jmp    f0107479 <spin_lock+0xa4>
	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM
		    || ebp >= (uint32_t *)IOMEMBASE)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0107497:	8b 50 04             	mov    0x4(%eax),%edx
f010749a:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010749d:	8b 10                	mov    (%eax),%edx
f010749f:	b8 01 00 00 00       	mov    $0x1,%eax
f01074a4:	eb b3                	jmp    f0107459 <spin_lock+0x84>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01074a6:	83 c4 20             	add    $0x20,%esp
f01074a9:	5b                   	pop    %ebx
f01074aa:	5e                   	pop    %esi
f01074ab:	5d                   	pop    %ebp
f01074ac:	c3                   	ret    
f01074ad:	00 00                	add    %al,(%eax)
	...

f01074b0 <E1000_transmit>:
	
	/* E1000_transmit((char*)&ncpu,4); */
	return 1;
}

int E1000_transmit(char* buf,int length){
f01074b0:	55                   	push   %ebp
f01074b1:	89 e5                	mov    %esp,%ebp
f01074b3:	53                   	push   %ebx
f01074b4:	83 ec 14             	sub    $0x14,%esp
f01074b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	struct e1000_tx_desc *transmit_desc =  &tx_desc_ring[(*tx_desc_tail)];
f01074ba:	8b 15 c0 6e 27 f0    	mov    0xf0276ec0,%edx
f01074c0:	8b 02                	mov    (%edx),%eax
f01074c2:	c1 e0 04             	shl    $0x4,%eax
f01074c5:	05 e0 6e 27 f0       	add    $0xf0276ee0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01074ca:	89 cb                	mov    %ecx,%ebx
f01074cc:	81 f9 ff ff ff ef    	cmp    $0xefffffff,%ecx
f01074d2:	77 20                	ja     f01074f4 <E1000_transmit+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01074d4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01074d8:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01074df:	f0 
f01074e0:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
f01074e7:	00 
f01074e8:	c7 04 24 c3 9b 10 f0 	movl   $0xf0109bc3,(%esp)
f01074ef:	e8 91 8b ff ff       	call   f0100085 <_panic>
        ) {
		cprintf("tx_desc_ring is full\n");
		return -1;
	}
	
	transmit_desc->buffer_addr = (uint32_t)PADDR(buf);
f01074f4:	81 c3 00 00 00 10    	add    $0x10000000,%ebx
f01074fa:	89 18                	mov    %ebx,(%eax)
f01074fc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	transmit_desc->lower.flags.length = (uint16_t)length;
f0107503:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0107506:	66 89 48 08          	mov    %cx,0x8(%eax)
	transmit_desc->lower.data |= E1000_TXD_CMD_RS | E1000_TXD_CMD_IDE | E1000_TXD_CMD_RPS | E1000_TXD_CMD_TCP;
f010750a:	81 48 08 00 00 00 99 	orl    $0x99000000,0x8(%eax)
	int nexttail = *tx_desc_tail;
	nexttail = (nexttail+1)%TX_DESC_RING_SIZE;
f0107511:	8b 0a                	mov    (%edx),%ecx
f0107513:	83 c1 01             	add    $0x1,%ecx
	*tx_desc_tail = nexttail;	//use a variable to count.
f0107516:	89 c8                	mov    %ecx,%eax
f0107518:	c1 f8 1f             	sar    $0x1f,%eax
f010751b:	c1 e8 1a             	shr    $0x1a,%eax
f010751e:	01 c1                	add    %eax,%ecx
f0107520:	83 e1 3f             	and    $0x3f,%ecx
f0107523:	29 c1                	sub    %eax,%ecx
f0107525:	89 0a                	mov    %ecx,(%edx)

	return 0;
}
f0107527:	b8 00 00 00 00       	mov    $0x0,%eax
f010752c:	83 c4 14             	add    $0x14,%esp
f010752f:	5b                   	pop    %ebx
f0107530:	5d                   	pop    %ebp
f0107531:	c3                   	ret    

f0107532 <pci_E1000_attach>:
// LAB 6: Your driver code here
#include <kern/pmap.h>

int
pci_E1000_attach(struct pci_func *pcif)
{
f0107532:	55                   	push   %ebp
f0107533:	89 e5                	mov    %esp,%ebp
f0107535:	53                   	push   %ebx
f0107536:	83 ec 24             	sub    $0x24,%esp
f0107539:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_func_enable(pcif);
f010753c:	89 1c 24             	mov    %ebx,(%esp)
f010753f:	e8 f9 05 00 00       	call   f0107b3d <pci_func_enable>
	//cprintf("size need:%d\n",pcif->reg_size[0]);//need 128KB
	

	boot_map_region(kern_pgdir,E1000IO,pcif->reg_size[0],pcif->reg_base[0],PTE_PCD|PTE_PWT|PTE_W);
f0107544:	c7 44 24 10 1a 00 00 	movl   $0x1a,0x10(%esp)
f010754b:	00 
f010754c:	8b 43 14             	mov    0x14(%ebx),%eax
f010754f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107553:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0107556:	89 44 24 08          	mov    %eax,0x8(%esp)
f010755a:	c7 44 24 04 00 10 c0 	movl   $0xefc01000,0x4(%esp)
f0107561:	ef 
f0107562:	a1 98 5e 27 f0       	mov    0xf0275e98,%eax
f0107567:	89 04 24             	mov    %eax,(%esp)
f010756a:	e8 28 a5 ff ff       	call   f0101a97 <boot_map_region>
	e1000 = (void*)(E1000IO);	//used like lapic
f010756f:	c7 05 e0 72 27 f0 00 	movl   $0xefc01000,0xf02772e0
f0107576:	10 c0 ef 
	cprintf("dsr  %x pa %x : %x\n",e1000,pcif->reg_base[0],*(int*)(&e1000[E1000_STATUS]));  //DSR offset 0008h.Pay attention that the offset is byte but the data is int(4 byte)
f0107579:	a1 08 10 c0 ef       	mov    0xefc01008,%eax
f010757e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107582:	8b 43 14             	mov    0x14(%ebx),%eax
f0107585:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107589:	c7 44 24 04 00 10 c0 	movl   $0xefc01000,0x4(%esp)
f0107590:	ef 
f0107591:	c7 04 24 d0 9b 10 f0 	movl   $0xf0109bd0,(%esp)
f0107598:	e8 ae ce ff ff       	call   f010444b <cprintf>


	//transmit initialization s14.5	
	*(uint32_t*)(&e1000[E1000_TDBAL]) = TX_DESC_RING_BASE;
f010759d:	8b 15 e0 72 27 f0    	mov    0xf02772e0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01075a3:	b8 e0 6e 27 f0       	mov    $0xf0276ee0,%eax
f01075a8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01075ad:	77 20                	ja     f01075cf <pci_E1000_attach+0x9d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01075af:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01075b3:	c7 44 24 08 3c 80 10 	movl   $0xf010803c,0x8(%esp)
f01075ba:	f0 
f01075bb:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f01075c2:	00 
f01075c3:	c7 04 24 c3 9b 10 f0 	movl   $0xf0109bc3,(%esp)
f01075ca:	e8 b6 8a ff ff       	call   f0100085 <_panic>
f01075cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01075d4:	89 82 00 38 00 00    	mov    %eax,0x3800(%edx)
	*(uint32_t*)(&e1000[E1000_TDBAH]) = 0;					//32 not needed
f01075da:	a1 e0 72 27 f0       	mov    0xf02772e0,%eax
f01075df:	c7 80 04 38 00 00 00 	movl   $0x0,0x3804(%eax)
f01075e6:	00 00 00 
	*(uint32_t*)(&e1000[E1000_TDLEN]) = TX_DESC_RING_LENGTH;
f01075e9:	a1 e0 72 27 f0       	mov    0xf02772e0,%eax
f01075ee:	c7 80 08 38 00 00 00 	movl   $0x400,0x3808(%eax)
f01075f5:	04 00 00 
	*(uint32_t*)(&e1000[E1000_TDH])	  = 0;
f01075f8:	a1 e0 72 27 f0       	mov    0xf02772e0,%eax
f01075fd:	c7 80 10 38 00 00 00 	movl   $0x0,0x3810(%eax)
f0107604:	00 00 00 
	*(uint32_t*)(&e1000[E1000_TDT])   = 0;
f0107607:	a1 e0 72 27 f0       	mov    0xf02772e0,%eax
f010760c:	c7 80 18 38 00 00 00 	movl   $0x0,0x3818(%eax)
f0107613:	00 00 00 

	tx_desc_head = (uint32_t*)(&e1000[E1000_TDH]);
f0107616:	a1 e0 72 27 f0       	mov    0xf02772e0,%eax
f010761b:	8d 90 10 38 00 00    	lea    0x3810(%eax),%edx
f0107621:	89 15 a0 5e 27 f0    	mov    %edx,0xf0275ea0
	tx_desc_tail = (uint32_t*)(&e1000[E1000_TDT]);
f0107627:	8d 90 18 38 00 00    	lea    0x3818(%eax),%edx
f010762d:	89 15 c0 6e 27 f0    	mov    %edx,0xf0276ec0
	//initialize TCTL
	uint32_t *tctl = (uint32_t*)(&e1000[E1000_TCTL]);
	*tctl |= E1000_TCTL_EN;		//1b
	*tctl |= E1000_TCTL_PSP;	//1b
	*tctl |= E1000_TCTL_CT  & ((0x10)<<4 );  
	*tctl |= E1000_TCTL_COLD& ((0x40)<<12);
f0107633:	81 88 00 04 00 00 0a 	orl    $0x4010a,0x400(%eax)
f010763a:	01 04 00 
	
	/* E1000_transmit((char*)&ncpu,4); */
	return 1;
}
f010763d:	b8 01 00 00 00       	mov    $0x1,%eax
f0107642:	83 c4 24             	add    $0x24,%esp
f0107645:	5b                   	pop    %ebx
f0107646:	5d                   	pop    %ebp
f0107647:	c3                   	ret    
	...

f0107650 <pci_attach_match>:
}

static int __attribute__((warn_unused_result))
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
f0107650:	55                   	push   %ebp
f0107651:	89 e5                	mov    %esp,%ebp
f0107653:	57                   	push   %edi
f0107654:	56                   	push   %esi
f0107655:	53                   	push   %ebx
f0107656:	83 ec 3c             	sub    $0x3c,%esp
f0107659:	89 c7                	mov    %eax,%edi
f010765b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010765e:	89 ce                	mov    %ecx,%esi
	uint32_t i;
	
	for (i = 0; list[i].attachfn; i++) {
f0107660:	8b 41 08             	mov    0x8(%ecx),%eax
f0107663:	85 c0                	test   %eax,%eax
f0107665:	74 4d                	je     f01076b4 <pci_attach_match+0x64>
f0107667:	8d 59 0c             	lea    0xc(%ecx),%ebx
		if (list[i].key1 == key1 && list[i].key2 == key2) {
f010766a:	39 3e                	cmp    %edi,(%esi)
f010766c:	75 3a                	jne    f01076a8 <pci_attach_match+0x58>
f010766e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107671:	39 56 04             	cmp    %edx,0x4(%esi)
f0107674:	75 32                	jne    f01076a8 <pci_attach_match+0x58>
			int r = list[i].attachfn(pcif);
f0107676:	8b 55 08             	mov    0x8(%ebp),%edx
f0107679:	89 14 24             	mov    %edx,(%esp)
f010767c:	ff d0                	call   *%eax
			if (r > 0)
f010767e:	85 c0                	test   %eax,%eax
f0107680:	7f 37                	jg     f01076b9 <pci_attach_match+0x69>
				return r;
			if (r < 0)
f0107682:	85 c0                	test   %eax,%eax
f0107684:	79 22                	jns    f01076a8 <pci_attach_match+0x58>
				cprintf("pci_attach_match: attaching "
f0107686:	89 44 24 10          	mov    %eax,0x10(%esp)
f010768a:	8b 46 08             	mov    0x8(%esi),%eax
f010768d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107691:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107694:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107698:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010769c:	c7 04 24 e4 9b 10 f0 	movl   $0xf0109be4,(%esp)
f01076a3:	e8 a3 cd ff ff       	call   f010444b <cprintf>
f01076a8:	89 de                	mov    %ebx,%esi
pci_attach_match(uint32_t key1, uint32_t key2,
		 struct pci_driver *list, struct pci_func *pcif)
{
	uint32_t i;
	
	for (i = 0; list[i].attachfn; i++) {
f01076aa:	8b 43 08             	mov    0x8(%ebx),%eax
f01076ad:	83 c3 0c             	add    $0xc,%ebx
f01076b0:	85 c0                	test   %eax,%eax
f01076b2:	75 b6                	jne    f010766a <pci_attach_match+0x1a>
f01076b4:	b8 00 00 00 00       	mov    $0x0,%eax
					"%x.%x (%p): e\n",
					key1, key2, list[i].attachfn, r);
		}
	}
	return 0;
}
f01076b9:	83 c4 3c             	add    $0x3c,%esp
f01076bc:	5b                   	pop    %ebx
f01076bd:	5e                   	pop    %esi
f01076be:	5f                   	pop    %edi
f01076bf:	5d                   	pop    %ebp
f01076c0:	c3                   	ret    

f01076c1 <pci_conf1_set_addr>:
static void
pci_conf1_set_addr(uint32_t bus,
		   uint32_t dev,
		   uint32_t func,
		   uint32_t offset)
{
f01076c1:	55                   	push   %ebp
f01076c2:	89 e5                	mov    %esp,%ebp
f01076c4:	53                   	push   %ebx
f01076c5:	83 ec 14             	sub    $0x14,%esp
f01076c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	assert(bus < 256);
f01076cb:	3d ff 00 00 00       	cmp    $0xff,%eax
f01076d0:	76 24                	jbe    f01076f6 <pci_conf1_set_addr+0x35>
f01076d2:	c7 44 24 0c 8c 9d 10 	movl   $0xf0109d8c,0xc(%esp)
f01076d9:	f0 
f01076da:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f01076e1:	f0 
f01076e2:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
f01076e9:	00 
f01076ea:	c7 04 24 96 9d 10 f0 	movl   $0xf0109d96,(%esp)
f01076f1:	e8 8f 89 ff ff       	call   f0100085 <_panic>
	assert(dev < 32);
f01076f6:	83 fa 1f             	cmp    $0x1f,%edx
f01076f9:	76 24                	jbe    f010771f <pci_conf1_set_addr+0x5e>
f01076fb:	c7 44 24 0c a1 9d 10 	movl   $0xf0109da1,0xc(%esp)
f0107702:	f0 
f0107703:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010770a:	f0 
f010770b:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
f0107712:	00 
f0107713:	c7 04 24 96 9d 10 f0 	movl   $0xf0109d96,(%esp)
f010771a:	e8 66 89 ff ff       	call   f0100085 <_panic>
	assert(func < 8);
f010771f:	83 f9 07             	cmp    $0x7,%ecx
f0107722:	76 24                	jbe    f0107748 <pci_conf1_set_addr+0x87>
f0107724:	c7 44 24 0c aa 9d 10 	movl   $0xf0109daa,0xc(%esp)
f010772b:	f0 
f010772c:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0107733:	f0 
f0107734:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
f010773b:	00 
f010773c:	c7 04 24 96 9d 10 f0 	movl   $0xf0109d96,(%esp)
f0107743:	e8 3d 89 ff ff       	call   f0100085 <_panic>
	assert(offset < 256);
f0107748:	81 fb ff 00 00 00    	cmp    $0xff,%ebx
f010774e:	76 24                	jbe    f0107774 <pci_conf1_set_addr+0xb3>
f0107750:	c7 44 24 0c b3 9d 10 	movl   $0xf0109db3,0xc(%esp)
f0107757:	f0 
f0107758:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f010775f:	f0 
f0107760:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp)
f0107767:	00 
f0107768:	c7 04 24 96 9d 10 f0 	movl   $0xf0109d96,(%esp)
f010776f:	e8 11 89 ff ff       	call   f0100085 <_panic>
	assert((offset & 0x3) == 0);
f0107774:	f6 c3 03             	test   $0x3,%bl
f0107777:	74 24                	je     f010779d <pci_conf1_set_addr+0xdc>
f0107779:	c7 44 24 0c c0 9d 10 	movl   $0xf0109dc0,0xc(%esp)
f0107780:	f0 
f0107781:	c7 44 24 08 c7 8c 10 	movl   $0xf0108cc7,0x8(%esp)
f0107788:	f0 
f0107789:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
f0107790:	00 
f0107791:	c7 04 24 96 9d 10 f0 	movl   $0xf0109d96,(%esp)
f0107798:	e8 e8 88 ff ff       	call   f0100085 <_panic>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f010779d:	c1 e0 10             	shl    $0x10,%eax
f01077a0:	0d 00 00 00 80       	or     $0x80000000,%eax
f01077a5:	c1 e2 0b             	shl    $0xb,%edx
f01077a8:	09 d0                	or     %edx,%eax
f01077aa:	09 d8                	or     %ebx,%eax
f01077ac:	c1 e1 08             	shl    $0x8,%ecx
f01077af:	09 c8                	or     %ecx,%eax
f01077b1:	ba f8 0c 00 00       	mov    $0xcf8,%edx
f01077b6:	ef                   	out    %eax,(%dx)

	uint32_t v = (1 << 31) |		// config-space
		(bus << 16) | (dev << 11) | (func << 8) | (offset);
	outl(pci_conf1_addr_ioport, v);
}
f01077b7:	83 c4 14             	add    $0x14,%esp
f01077ba:	5b                   	pop    %ebx
f01077bb:	5d                   	pop    %ebp
f01077bc:	c3                   	ret    

f01077bd <pci_conf_read>:

static uint32_t
pci_conf_read(struct pci_func *f, uint32_t off)
{
f01077bd:	55                   	push   %ebp
f01077be:	89 e5                	mov    %esp,%ebp
f01077c0:	53                   	push   %ebx
f01077c1:	83 ec 14             	sub    $0x14,%esp
f01077c4:	89 d3                	mov    %edx,%ebx
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f01077c6:	8b 48 08             	mov    0x8(%eax),%ecx
f01077c9:	8b 50 04             	mov    0x4(%eax),%edx
f01077cc:	8b 00                	mov    (%eax),%eax
f01077ce:	8b 40 04             	mov    0x4(%eax),%eax
f01077d1:	89 1c 24             	mov    %ebx,(%esp)
f01077d4:	e8 e8 fe ff ff       	call   f01076c1 <pci_conf1_set_addr>

static __inline uint32_t
inl(int port)
{
	uint32_t data;
	__asm __volatile("inl %w1,%0" : "=a" (data) : "d" (port));
f01077d9:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f01077de:	ed                   	in     (%dx),%eax
	return inl(pci_conf1_data_ioport);
}
f01077df:	83 c4 14             	add    $0x14,%esp
f01077e2:	5b                   	pop    %ebx
f01077e3:	5d                   	pop    %ebp
f01077e4:	c3                   	ret    

f01077e5 <pci_scan_bus>:
		f->irq_line);
}

static int
pci_scan_bus(struct pci_bus *bus)
{
f01077e5:	55                   	push   %ebp
f01077e6:	89 e5                	mov    %esp,%ebp
f01077e8:	57                   	push   %edi
f01077e9:	56                   	push   %esi
f01077ea:	53                   	push   %ebx
f01077eb:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
f01077f1:	89 c3                	mov    %eax,%ebx
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
f01077f3:	c7 44 24 08 48 00 00 	movl   $0x48,0x8(%esp)
f01077fa:	00 
f01077fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107802:	00 
f0107803:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0107806:	89 04 24             	mov    %eax,(%esp)
f0107809:	e8 58 f1 ff ff       	call   f0106966 <memset>
	df.bus = bus;
f010780e:	89 5d a0             	mov    %ebx,-0x60(%ebp)

	for (df.dev = 0; df.dev < 32; df.dev++) {
f0107811:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
};

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
f0107818:	c7 85 fc fe ff ff 00 	movl   $0x0,-0x104(%ebp)
f010781f:	00 00 00 
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f0107822:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0107825:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;

		totaldev++;

		struct pci_func f = df;
f010782b:	8d 8d 58 ff ff ff    	lea    -0xa8(%ebp),%ecx
f0107831:	89 8d f4 fe ff ff    	mov    %ecx,-0x10c(%ebp)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
			struct pci_func af = f;
f0107837:	8d 85 10 ff ff ff    	lea    -0xf0(%ebp),%eax
f010783d:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
f0107843:	89 8d 00 ff ff ff    	mov    %ecx,-0x100(%ebp)
f0107849:	89 85 04 ff ff ff    	mov    %eax,-0xfc(%ebp)
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
f010784f:	ba 0c 00 00 00       	mov    $0xc,%edx
f0107854:	8d 45 a0             	lea    -0x60(%ebp),%eax
f0107857:	e8 61 ff ff ff       	call   f01077bd <pci_conf_read>
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
f010785c:	89 c2                	mov    %eax,%edx
f010785e:	c1 ea 10             	shr    $0x10,%edx
f0107861:	83 e2 7f             	and    $0x7f,%edx
f0107864:	83 fa 01             	cmp    $0x1,%edx
f0107867:	0f 87 77 01 00 00    	ja     f01079e4 <pci_scan_bus+0x1ff>
			continue;

		totaldev++;

		struct pci_func f = df;
f010786d:	b9 12 00 00 00       	mov    $0x12,%ecx
f0107872:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
f0107878:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
f010787e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f0107880:	c7 85 60 ff ff ff 00 	movl   $0x0,-0xa0(%ebp)
f0107887:	00 00 00 
f010788a:	89 c3                	mov    %eax,%ebx
f010788c:	81 e3 00 00 80 00    	and    $0x800000,%ebx
f0107892:	e9 2f 01 00 00       	jmp    f01079c6 <pci_scan_bus+0x1e1>
		     f.func++) {
			struct pci_func af = f;
f0107897:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
f010789d:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
f01078a3:	b9 12 00 00 00       	mov    $0x12,%ecx
f01078a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

			af.dev_id = pci_conf_read(&f, PCI_ID_REG);
f01078aa:	ba 00 00 00 00       	mov    $0x0,%edx
f01078af:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
f01078b5:	e8 03 ff ff ff       	call   f01077bd <pci_conf_read>
f01078ba:	89 85 1c ff ff ff    	mov    %eax,-0xe4(%ebp)
			if (PCI_VENDOR(af.dev_id) == 0xffff)
f01078c0:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f01078c4:	0f 84 f5 00 00 00    	je     f01079bf <pci_scan_bus+0x1da>
				continue;

			uint32_t intr = pci_conf_read(&af, PCI_INTERRUPT_REG);
f01078ca:	ba 3c 00 00 00       	mov    $0x3c,%edx
f01078cf:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f01078d5:	e8 e3 fe ff ff       	call   f01077bd <pci_conf_read>
			af.irq_line = PCI_INTERRUPT_LINE(intr);
f01078da:	88 85 54 ff ff ff    	mov    %al,-0xac(%ebp)

			af.dev_class = pci_conf_read(&af, PCI_CLASS_REG);
f01078e0:	ba 08 00 00 00       	mov    $0x8,%edx
f01078e5:	8b 85 04 ff ff ff    	mov    -0xfc(%ebp),%eax
f01078eb:	e8 cd fe ff ff       	call   f01077bd <pci_conf_read>
f01078f0:	89 85 20 ff ff ff    	mov    %eax,-0xe0(%ebp)

static void
pci_print_func(struct pci_func *f)
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
f01078f6:	89 c2                	mov    %eax,%edx
f01078f8:	c1 ea 18             	shr    $0x18,%edx
f01078fb:	b9 d4 9d 10 f0       	mov    $0xf0109dd4,%ecx
f0107900:	83 fa 06             	cmp    $0x6,%edx
f0107903:	77 07                	ja     f010790c <pci_scan_bus+0x127>
		class = pci_class[PCI_CLASS(f->dev_class)];
f0107905:	8b 0c 95 48 9e 10 f0 	mov    -0xfef61b8(,%edx,4),%ecx

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f010790c:	8b bd 1c ff ff ff    	mov    -0xe4(%ebp),%edi
{
	const char *class = pci_class[0];
	if (PCI_CLASS(f->dev_class) < sizeof(pci_class) / sizeof(pci_class[0]))
		class = pci_class[PCI_CLASS(f->dev_class)];

	cprintf("PCI: %02x:%02x.%d: %04x:%04x: class: %x.%x (%s) irq: %d\n",
f0107912:	0f b6 b5 54 ff ff ff 	movzbl -0xac(%ebp),%esi
f0107919:	89 74 24 24          	mov    %esi,0x24(%esp)
f010791d:	89 4c 24 20          	mov    %ecx,0x20(%esp)
f0107921:	c1 e8 10             	shr    $0x10,%eax
f0107924:	25 ff 00 00 00       	and    $0xff,%eax
f0107929:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010792d:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107931:	89 f8                	mov    %edi,%eax
f0107933:	c1 e8 10             	shr    $0x10,%eax
f0107936:	89 44 24 14          	mov    %eax,0x14(%esp)
f010793a:	81 e7 ff ff 00 00    	and    $0xffff,%edi
f0107940:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0107944:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
f010794a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010794e:	8b 85 14 ff ff ff    	mov    -0xec(%ebp),%eax
f0107954:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107958:	8b 85 10 ff ff ff    	mov    -0xf0(%ebp),%eax
f010795e:	8b 40 04             	mov    0x4(%eax),%eax
f0107961:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107965:	c7 04 24 10 9c 10 f0 	movl   $0xf0109c10,(%esp)
f010796c:	e8 da ca ff ff       	call   f010444b <cprintf>
static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
				 PCI_SUBCLASS(f->dev_class),
f0107971:	8b 85 20 ff ff ff    	mov    -0xe0(%ebp),%eax
				 &pci_attach_class[0], f) ||
f0107977:	89 c2                	mov    %eax,%edx
f0107979:	c1 ea 10             	shr    $0x10,%edx
f010797c:	81 e2 ff 00 00 00    	and    $0xff,%edx
f0107982:	c1 e8 18             	shr    $0x18,%eax
f0107985:	8b 8d 04 ff ff ff    	mov    -0xfc(%ebp),%ecx
f010798b:	89 0c 24             	mov    %ecx,(%esp)
f010798e:	b9 b4 53 12 f0       	mov    $0xf01253b4,%ecx
f0107993:	e8 b8 fc ff ff       	call   f0107650 <pci_attach_match>

static int
pci_attach(struct pci_func *f)
{
	return
		pci_attach_match(PCI_CLASS(f->dev_class),
f0107998:	85 c0                	test   %eax,%eax
f010799a:	75 23                	jne    f01079bf <pci_scan_bus+0x1da>
				 PCI_SUBCLASS(f->dev_class),
				 &pci_attach_class[0], f) ||
		pci_attach_match(PCI_VENDOR(f->dev_id),
				 PCI_PRODUCT(f->dev_id),
f010799c:	8b 85 1c ff ff ff    	mov    -0xe4(%ebp),%eax
				 &pci_attach_vendor[0], f);
f01079a2:	89 c2                	mov    %eax,%edx
f01079a4:	c1 ea 10             	shr    $0x10,%edx
f01079a7:	25 ff ff 00 00       	and    $0xffff,%eax
f01079ac:	8b 8d 04 ff ff ff    	mov    -0xfc(%ebp),%ecx
f01079b2:	89 0c 24             	mov    %ecx,(%esp)
f01079b5:	b9 cc 53 12 f0       	mov    $0xf01253cc,%ecx
f01079ba:	e8 91 fc ff ff       	call   f0107650 <pci_attach_match>

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
		     f.func++) {
f01079bf:	83 85 60 ff ff ff 01 	addl   $0x1,-0xa0(%ebp)
			continue;

		totaldev++;

		struct pci_func f = df;
		for (f.func = 0; f.func < (PCI_HDRTYPE_MULTIFN(bhlc) ? 8 : 1);
f01079c6:	83 fb 01             	cmp    $0x1,%ebx
f01079c9:	19 c0                	sbb    %eax,%eax
f01079cb:	83 e0 f9             	and    $0xfffffff9,%eax
f01079ce:	83 c0 08             	add    $0x8,%eax
f01079d1:	3b 85 60 ff ff ff    	cmp    -0xa0(%ebp),%eax
f01079d7:	0f 87 ba fe ff ff    	ja     f0107897 <pci_scan_bus+0xb2>
	for (df.dev = 0; df.dev < 32; df.dev++) {
		uint32_t bhlc = pci_conf_read(&df, PCI_BHLC_REG);
		if (PCI_HDRTYPE_TYPE(bhlc) > 1)	    // Unsupported or no device
			continue;

		totaldev++;
f01079dd:	83 85 fc fe ff ff 01 	addl   $0x1,-0x104(%ebp)
	int totaldev = 0;
	struct pci_func df;
	memset(&df, 0, sizeof(df));
	df.bus = bus;

	for (df.dev = 0; df.dev < 32; df.dev++) {
f01079e4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01079e7:	83 c0 01             	add    $0x1,%eax
f01079ea:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01079ed:	83 f8 1f             	cmp    $0x1f,%eax
f01079f0:	0f 86 59 fe ff ff    	jbe    f010784f <pci_scan_bus+0x6a>
			pci_attach(&af);
		}
	}

	return totaldev;
}
f01079f6:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
f01079fc:	81 c4 3c 01 00 00    	add    $0x13c,%esp
f0107a02:	5b                   	pop    %ebx
f0107a03:	5e                   	pop    %esi
f0107a04:	5f                   	pop    %edi
f0107a05:	5d                   	pop    %ebp
f0107a06:	c3                   	ret    

f0107a07 <pci_init>:
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}

int
pci_init(void)
{
f0107a07:	55                   	push   %ebp
f0107a08:	89 e5                	mov    %esp,%ebp
f0107a0a:	83 ec 18             	sub    $0x18,%esp
	static struct pci_bus root_bus;
	memset(&root_bus, 0, sizeof(root_bus));
f0107a0d:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0107a14:	00 
f0107a15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107a1c:	00 
f0107a1d:	c7 04 24 80 5e 27 f0 	movl   $0xf0275e80,(%esp)
f0107a24:	e8 3d ef ff ff       	call   f0106966 <memset>

	return pci_scan_bus(&root_bus);
f0107a29:	b8 80 5e 27 f0       	mov    $0xf0275e80,%eax
f0107a2e:	e8 b2 fd ff ff       	call   f01077e5 <pci_scan_bus>
}
f0107a33:	c9                   	leave  
f0107a34:	c3                   	ret    

f0107a35 <pci_bridge_attach>:
	return totaldev;
}

static int
pci_bridge_attach(struct pci_func *pcif)
{
f0107a35:	55                   	push   %ebp
f0107a36:	89 e5                	mov    %esp,%ebp
f0107a38:	83 ec 48             	sub    $0x48,%esp
f0107a3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0107a3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0107a41:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0107a44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t ioreg  = pci_conf_read(pcif, PCI_BRIDGE_STATIO_REG);
f0107a47:	ba 1c 00 00 00       	mov    $0x1c,%edx
f0107a4c:	89 d8                	mov    %ebx,%eax
f0107a4e:	e8 6a fd ff ff       	call   f01077bd <pci_conf_read>
f0107a53:	89 c7                	mov    %eax,%edi
	uint32_t busreg = pci_conf_read(pcif, PCI_BRIDGE_BUS_REG);
f0107a55:	ba 18 00 00 00       	mov    $0x18,%edx
f0107a5a:	89 d8                	mov    %ebx,%eax
f0107a5c:	e8 5c fd ff ff       	call   f01077bd <pci_conf_read>
f0107a61:	89 c6                	mov    %eax,%esi

	if (PCI_BRIDGE_IO_32BITS(ioreg)) {
f0107a63:	83 e7 0f             	and    $0xf,%edi
f0107a66:	83 ff 01             	cmp    $0x1,%edi
f0107a69:	75 2a                	jne    f0107a95 <pci_bridge_attach+0x60>
		cprintf("PCI: %02x:%02x.pci_driver%dpci_driverpci_driverpci_driverpci_driverpci_driverpci_driverpci_driver: 32-bit bridge IO not supported.\n",
f0107a6b:	8b 43 08             	mov    0x8(%ebx),%eax
f0107a6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107a72:	8b 43 04             	mov    0x4(%ebx),%eax
f0107a75:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107a79:	8b 03                	mov    (%ebx),%eax
f0107a7b:	8b 40 04             	mov    0x4(%eax),%eax
f0107a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107a82:	c7 04 24 4c 9c 10 f0 	movl   $0xf0109c4c,(%esp)
f0107a89:	e8 bd c9 ff ff       	call   f010444b <cprintf>
f0107a8e:	b8 00 00 00 00       	mov    $0x0,%eax
			pcif->bus->busno, pcif->dev, pcif->func);
		return 0;
f0107a93:	eb 66                	jmp    f0107afb <pci_bridge_attach+0xc6>
	}

	struct pci_bus nbus;
	memset(&nbus, 0, sizeof(nbus));
f0107a95:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
f0107a9c:	00 
f0107a9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0107aa4:	00 
f0107aa5:	8d 7d e0             	lea    -0x20(%ebp),%edi
f0107aa8:	89 3c 24             	mov    %edi,(%esp)
f0107aab:	e8 b6 ee ff ff       	call   f0106966 <memset>
	nbus.parent_bridge = pcif;
f0107ab0:	89 5d e0             	mov    %ebx,-0x20(%ebp)
	nbus.busno = (busreg >> PCI_BRIDGE_BUS_SECONDARY_SHIFT) & 0xff;
f0107ab3:	89 f2                	mov    %esi,%edx
f0107ab5:	0f b6 c6             	movzbl %dh,%eax
f0107ab8:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	if (pci_show_devs)
		cprintf("PCI: %02x:%02x.%d: bridge to PCI bus %d--%d\n",
f0107abb:	c1 ee 10             	shr    $0x10,%esi
f0107abe:	81 e6 ff 00 00 00    	and    $0xff,%esi
f0107ac4:	89 74 24 14          	mov    %esi,0x14(%esp)
f0107ac8:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107acc:	8b 43 08             	mov    0x8(%ebx),%eax
f0107acf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107ad3:	8b 43 04             	mov    0x4(%ebx),%eax
f0107ad6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107ada:	8b 03                	mov    (%ebx),%eax
f0107adc:	8b 40 04             	mov    0x4(%eax),%eax
f0107adf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107ae3:	c7 04 24 d0 9c 10 f0 	movl   $0xf0109cd0,(%esp)
f0107aea:	e8 5c c9 ff ff       	call   f010444b <cprintf>
			pcif->bus->busno, pcif->dev, pcif->func,
			nbus.busno,
			(busreg >> PCI_BRIDGE_BUS_SUBORDINATE_SHIFT) & 0xff);

	pci_scan_bus(&nbus);
f0107aef:	89 f8                	mov    %edi,%eax
f0107af1:	e8 ef fc ff ff       	call   f01077e5 <pci_scan_bus>
f0107af6:	b8 01 00 00 00       	mov    $0x1,%eax
	return 1;
}
f0107afb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0107afe:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0107b01:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0107b04:	89 ec                	mov    %ebp,%esp
f0107b06:	5d                   	pop    %ebp
f0107b07:	c3                   	ret    

f0107b08 <pci_conf_write>:
	return inl(pci_conf1_data_ioport);
}

static void
pci_conf_write(struct pci_func *f, uint32_t off, uint32_t v)
{
f0107b08:	55                   	push   %ebp
f0107b09:	89 e5                	mov    %esp,%ebp
f0107b0b:	83 ec 18             	sub    $0x18,%esp
f0107b0e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0107b11:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0107b14:	89 d3                	mov    %edx,%ebx
f0107b16:	89 ce                	mov    %ecx,%esi
	pci_conf1_set_addr(f->bus->busno, f->dev, f->func, off);
f0107b18:	8b 48 08             	mov    0x8(%eax),%ecx
f0107b1b:	8b 50 04             	mov    0x4(%eax),%edx
f0107b1e:	8b 00                	mov    (%eax),%eax
f0107b20:	8b 40 04             	mov    0x4(%eax),%eax
f0107b23:	89 1c 24             	mov    %ebx,(%esp)
f0107b26:	e8 96 fb ff ff       	call   f01076c1 <pci_conf1_set_addr>
}

static __inline void
outl(int port, uint32_t data)
{
	__asm __volatile("outl %0,%w1" : : "a" (data), "d" (port));
f0107b2b:	ba fc 0c 00 00       	mov    $0xcfc,%edx
f0107b30:	89 f0                	mov    %esi,%eax
f0107b32:	ef                   	out    %eax,(%dx)
	outl(pci_conf1_data_ioport, v);
}
f0107b33:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0107b36:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0107b39:	89 ec                	mov    %ebp,%esp
f0107b3b:	5d                   	pop    %ebp
f0107b3c:	c3                   	ret    

f0107b3d <pci_func_enable>:

// External PCI subsystem interface

void
pci_func_enable(struct pci_func *f)
{
f0107b3d:	55                   	push   %ebp
f0107b3e:	89 e5                	mov    %esp,%ebp
f0107b40:	57                   	push   %edi
f0107b41:	56                   	push   %esi
f0107b42:	53                   	push   %ebx
f0107b43:	83 ec 4c             	sub    $0x4c,%esp
f0107b46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	pci_conf_write(f, PCI_COMMAND_STATUS_REG,
f0107b49:	b9 07 00 00 00       	mov    $0x7,%ecx
f0107b4e:	ba 04 00 00 00       	mov    $0x4,%edx
f0107b53:	89 d8                	mov    %ebx,%eax
f0107b55:	e8 ae ff ff ff       	call   f0107b08 <pci_conf_write>
f0107b5a:	be 10 00 00 00       	mov    $0x10,%esi
	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
	{
		uint32_t oldv = pci_conf_read(f, bar);
f0107b5f:	89 f2                	mov    %esi,%edx
f0107b61:	89 d8                	mov    %ebx,%eax
f0107b63:	e8 55 fc ff ff       	call   f01077bd <pci_conf_read>
f0107b68:	89 45 e4             	mov    %eax,-0x1c(%ebp)

		bar_width = 4;
		pci_conf_write(f, bar, 0xffffffff);
f0107b6b:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
f0107b70:	89 f2                	mov    %esi,%edx
f0107b72:	89 d8                	mov    %ebx,%eax
f0107b74:	e8 8f ff ff ff       	call   f0107b08 <pci_conf_write>
		uint32_t rv = pci_conf_read(f, bar);
f0107b79:	89 f2                	mov    %esi,%edx
f0107b7b:	89 d8                	mov    %ebx,%eax
f0107b7d:	e8 3b fc ff ff       	call   f01077bd <pci_conf_read>

		if (rv == 0)
f0107b82:	bf 04 00 00 00       	mov    $0x4,%edi
f0107b87:	85 c0                	test   %eax,%eax
f0107b89:	0f 84 c4 00 00 00    	je     f0107c53 <pci_func_enable+0x116>
			continue;

		int regnum = PCI_MAPREG_NUM(bar);
f0107b8f:	8d 56 f0             	lea    -0x10(%esi),%edx
f0107b92:	c1 ea 02             	shr    $0x2,%edx
f0107b95:	89 55 e0             	mov    %edx,-0x20(%ebp)
		uint32_t base, size;
		if (PCI_MAPREG_TYPE(rv) == PCI_MAPREG_TYPE_MEM) {
f0107b98:	a8 01                	test   $0x1,%al
f0107b9a:	75 2c                	jne    f0107bc8 <pci_func_enable+0x8b>
			if (PCI_MAPREG_MEM_TYPE(rv) == PCI_MAPREG_MEM_TYPE_64BIT)
f0107b9c:	89 c2                	mov    %eax,%edx
f0107b9e:	83 e2 06             	and    $0x6,%edx
f0107ba1:	83 fa 04             	cmp    $0x4,%edx
f0107ba4:	0f 94 c2             	sete   %dl
f0107ba7:	0f b6 fa             	movzbl %dl,%edi
f0107baa:	8d 3c bd 04 00 00 00 	lea    0x4(,%edi,4),%edi
				bar_width = 8;

			size = PCI_MAPREG_MEM_SIZE(rv);
f0107bb1:	83 e0 f0             	and    $0xfffffff0,%eax
f0107bb4:	89 c2                	mov    %eax,%edx
f0107bb6:	f7 da                	neg    %edx
f0107bb8:	21 c2                	and    %eax,%edx
f0107bba:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = PCI_MAPREG_MEM_ADDR(oldv);
f0107bbd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0107bc0:	83 e0 f0             	and    $0xfffffff0,%eax
f0107bc3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0107bc6:	eb 1a                	jmp    f0107be2 <pci_func_enable+0xa5>
			if (pci_show_addrs)
				cprintf("  mem region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		} else {
			size = PCI_MAPREG_IO_SIZE(rv);
f0107bc8:	83 e0 fc             	and    $0xfffffffc,%eax
f0107bcb:	89 c2                	mov    %eax,%edx
f0107bcd:	f7 da                	neg    %edx
f0107bcf:	21 c2                	and    %eax,%edx
f0107bd1:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = PCI_MAPREG_IO_ADDR(oldv);
f0107bd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0107bd7:	83 e2 fc             	and    $0xfffffffc,%edx
f0107bda:	89 55 d8             	mov    %edx,-0x28(%ebp)
f0107bdd:	bf 04 00 00 00       	mov    $0x4,%edi
			if (pci_show_addrs)
				cprintf("  io region %d: %d bytes at 0x%x\n",
					regnum, size, base);
		}

		pci_conf_write(f, bar, oldv);
f0107be2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0107be5:	89 f2                	mov    %esi,%edx
f0107be7:	89 d8                	mov    %ebx,%eax
f0107be9:	e8 1a ff ff ff       	call   f0107b08 <pci_conf_write>
		f->reg_base[regnum] = base;
f0107bee:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107bf1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0107bf4:	89 54 83 14          	mov    %edx,0x14(%ebx,%eax,4)
		f->reg_size[regnum] = size;
f0107bf8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0107bfb:	89 54 83 2c          	mov    %edx,0x2c(%ebx,%eax,4)

		if (size && !base)
f0107bff:	85 d2                	test   %edx,%edx
f0107c01:	74 50                	je     f0107c53 <pci_func_enable+0x116>
f0107c03:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0107c07:	75 4a                	jne    f0107c53 <pci_func_enable+0x116>
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
				"may be misconfigured: "
				"region %d: base 0x%x, size %d\n",
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
f0107c09:	8b 43 0c             	mov    0xc(%ebx),%eax
		pci_conf_write(f, bar, oldv);
		f->reg_base[regnum] = base;
		f->reg_size[regnum] = size;

		if (size && !base)
			cprintf("PCI device %02x:%02x.%d (%04x:%04x) "
f0107c0c:	89 54 24 20          	mov    %edx,0x20(%esp)
f0107c10:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0107c13:	89 54 24 1c          	mov    %edx,0x1c(%esp)
f0107c17:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0107c1a:	89 54 24 18          	mov    %edx,0x18(%esp)
f0107c1e:	89 c2                	mov    %eax,%edx
f0107c20:	c1 ea 10             	shr    $0x10,%edx
f0107c23:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107c27:	25 ff ff 00 00       	and    $0xffff,%eax
f0107c2c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107c30:	8b 43 08             	mov    0x8(%ebx),%eax
f0107c33:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107c37:	8b 43 04             	mov    0x4(%ebx),%eax
f0107c3a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107c3e:	8b 03                	mov    (%ebx),%eax
f0107c40:	8b 40 04             	mov    0x4(%eax),%eax
f0107c43:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c47:	c7 04 24 00 9d 10 f0 	movl   $0xf0109d00,(%esp)
f0107c4e:	e8 f8 c7 ff ff       	call   f010444b <cprintf>
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
	     bar += bar_width)
f0107c53:	01 fe                	add    %edi,%esi
		       PCI_COMMAND_MEM_ENABLE |
		       PCI_COMMAND_MASTER_ENABLE);

	uint32_t bar_width;
	uint32_t bar;
	for (bar = PCI_MAPREG_START; bar < PCI_MAPREG_END;
f0107c55:	83 fe 27             	cmp    $0x27,%esi
f0107c58:	0f 86 01 ff ff ff    	jbe    f0107b5f <pci_func_enable+0x22>
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
f0107c5e:	8b 43 0c             	mov    0xc(%ebx),%eax
				f->bus->busno, f->dev, f->func,
				PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id),
				regnum, base, size);
	}

	cprintf("PCI function %02x:%02x.%d (%04x:%04x) enabled\n",
f0107c61:	89 c2                	mov    %eax,%edx
f0107c63:	c1 ea 10             	shr    $0x10,%edx
f0107c66:	89 54 24 14          	mov    %edx,0x14(%esp)
f0107c6a:	25 ff ff 00 00       	and    $0xffff,%eax
f0107c6f:	89 44 24 10          	mov    %eax,0x10(%esp)
f0107c73:	8b 43 08             	mov    0x8(%ebx),%eax
f0107c76:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0107c7a:	8b 43 04             	mov    0x4(%ebx),%eax
f0107c7d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0107c81:	8b 03                	mov    (%ebx),%eax
f0107c83:	8b 40 04             	mov    0x4(%eax),%eax
f0107c86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0107c8a:	c7 04 24 5c 9d 10 f0 	movl   $0xf0109d5c,(%esp)
f0107c91:	e8 b5 c7 ff ff       	call   f010444b <cprintf>
		f->bus->busno, f->dev, f->func,
		PCI_VENDOR(f->dev_id), PCI_PRODUCT(f->dev_id));
}
f0107c96:	83 c4 4c             	add    $0x4c,%esp
f0107c99:	5b                   	pop    %ebx
f0107c9a:	5e                   	pop    %esi
f0107c9b:	5f                   	pop    %edi
f0107c9c:	5d                   	pop    %ebp
f0107c9d:	c3                   	ret    
	...

f0107ca0 <time_init>:

static unsigned int ticks;

void
time_init(void)
{
f0107ca0:	55                   	push   %ebp
f0107ca1:	89 e5                	mov    %esp,%ebp
	ticks = 0;
f0107ca3:	c7 05 88 5e 27 f0 00 	movl   $0x0,0xf0275e88
f0107caa:	00 00 00 
}
f0107cad:	5d                   	pop    %ebp
f0107cae:	c3                   	ret    

f0107caf <time_msec>:
		panic("time_tick: time overflowed");
}

unsigned int
time_msec(void)
{
f0107caf:	55                   	push   %ebp
f0107cb0:	89 e5                	mov    %esp,%ebp
f0107cb2:	a1 88 5e 27 f0       	mov    0xf0275e88,%eax
f0107cb7:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0107cba:	01 c0                	add    %eax,%eax
	return ticks * 10;
}
f0107cbc:	5d                   	pop    %ebp
f0107cbd:	c3                   	ret    

f0107cbe <time_tick>:

// This should be called once per timer interrupt.  A timer interrupt
// fires every 10 ms.
void
time_tick(void)
{
f0107cbe:	55                   	push   %ebp
f0107cbf:	89 e5                	mov    %esp,%ebp
f0107cc1:	83 ec 18             	sub    $0x18,%esp
	ticks++;
f0107cc4:	a1 88 5e 27 f0       	mov    0xf0275e88,%eax
f0107cc9:	83 c0 01             	add    $0x1,%eax
f0107ccc:	a3 88 5e 27 f0       	mov    %eax,0xf0275e88
	if (ticks * 10 < ticks)
f0107cd1:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0107cd4:	01 d2                	add    %edx,%edx
f0107cd6:	39 d0                	cmp    %edx,%eax
f0107cd8:	76 1c                	jbe    f0107cf6 <time_tick+0x38>
		panic("time_tick: time overflowed");
f0107cda:	c7 44 24 08 64 9e 10 	movl   $0xf0109e64,0x8(%esp)
f0107ce1:	f0 
f0107ce2:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
f0107ce9:	00 
f0107cea:	c7 04 24 7f 9e 10 f0 	movl   $0xf0109e7f,(%esp)
f0107cf1:	e8 8f 83 ff ff       	call   f0100085 <_panic>
}
f0107cf6:	c9                   	leave  
f0107cf7:	c3                   	ret    
	...

f0107d00 <__udivdi3>:
f0107d00:	55                   	push   %ebp
f0107d01:	89 e5                	mov    %esp,%ebp
f0107d03:	57                   	push   %edi
f0107d04:	56                   	push   %esi
f0107d05:	83 ec 10             	sub    $0x10,%esp
f0107d08:	8b 45 14             	mov    0x14(%ebp),%eax
f0107d0b:	8b 55 08             	mov    0x8(%ebp),%edx
f0107d0e:	8b 75 10             	mov    0x10(%ebp),%esi
f0107d11:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0107d14:	85 c0                	test   %eax,%eax
f0107d16:	89 55 f0             	mov    %edx,-0x10(%ebp)
f0107d19:	75 35                	jne    f0107d50 <__udivdi3+0x50>
f0107d1b:	39 fe                	cmp    %edi,%esi
f0107d1d:	77 61                	ja     f0107d80 <__udivdi3+0x80>
f0107d1f:	85 f6                	test   %esi,%esi
f0107d21:	75 0b                	jne    f0107d2e <__udivdi3+0x2e>
f0107d23:	b8 01 00 00 00       	mov    $0x1,%eax
f0107d28:	31 d2                	xor    %edx,%edx
f0107d2a:	f7 f6                	div    %esi
f0107d2c:	89 c6                	mov    %eax,%esi
f0107d2e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0107d31:	31 d2                	xor    %edx,%edx
f0107d33:	89 f8                	mov    %edi,%eax
f0107d35:	f7 f6                	div    %esi
f0107d37:	89 c7                	mov    %eax,%edi
f0107d39:	89 c8                	mov    %ecx,%eax
f0107d3b:	f7 f6                	div    %esi
f0107d3d:	89 c1                	mov    %eax,%ecx
f0107d3f:	89 fa                	mov    %edi,%edx
f0107d41:	89 c8                	mov    %ecx,%eax
f0107d43:	83 c4 10             	add    $0x10,%esp
f0107d46:	5e                   	pop    %esi
f0107d47:	5f                   	pop    %edi
f0107d48:	5d                   	pop    %ebp
f0107d49:	c3                   	ret    
f0107d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0107d50:	39 f8                	cmp    %edi,%eax
f0107d52:	77 1c                	ja     f0107d70 <__udivdi3+0x70>
f0107d54:	0f bd d0             	bsr    %eax,%edx
f0107d57:	83 f2 1f             	xor    $0x1f,%edx
f0107d5a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107d5d:	75 39                	jne    f0107d98 <__udivdi3+0x98>
f0107d5f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0107d62:	0f 86 a0 00 00 00    	jbe    f0107e08 <__udivdi3+0x108>
f0107d68:	39 f8                	cmp    %edi,%eax
f0107d6a:	0f 82 98 00 00 00    	jb     f0107e08 <__udivdi3+0x108>
f0107d70:	31 ff                	xor    %edi,%edi
f0107d72:	31 c9                	xor    %ecx,%ecx
f0107d74:	89 c8                	mov    %ecx,%eax
f0107d76:	89 fa                	mov    %edi,%edx
f0107d78:	83 c4 10             	add    $0x10,%esp
f0107d7b:	5e                   	pop    %esi
f0107d7c:	5f                   	pop    %edi
f0107d7d:	5d                   	pop    %ebp
f0107d7e:	c3                   	ret    
f0107d7f:	90                   	nop
f0107d80:	89 d1                	mov    %edx,%ecx
f0107d82:	89 fa                	mov    %edi,%edx
f0107d84:	89 c8                	mov    %ecx,%eax
f0107d86:	31 ff                	xor    %edi,%edi
f0107d88:	f7 f6                	div    %esi
f0107d8a:	89 c1                	mov    %eax,%ecx
f0107d8c:	89 fa                	mov    %edi,%edx
f0107d8e:	89 c8                	mov    %ecx,%eax
f0107d90:	83 c4 10             	add    $0x10,%esp
f0107d93:	5e                   	pop    %esi
f0107d94:	5f                   	pop    %edi
f0107d95:	5d                   	pop    %ebp
f0107d96:	c3                   	ret    
f0107d97:	90                   	nop
f0107d98:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107d9c:	89 f2                	mov    %esi,%edx
f0107d9e:	d3 e0                	shl    %cl,%eax
f0107da0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0107da3:	b8 20 00 00 00       	mov    $0x20,%eax
f0107da8:	2b 45 f4             	sub    -0xc(%ebp),%eax
f0107dab:	89 c1                	mov    %eax,%ecx
f0107dad:	d3 ea                	shr    %cl,%edx
f0107daf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107db3:	0b 55 ec             	or     -0x14(%ebp),%edx
f0107db6:	d3 e6                	shl    %cl,%esi
f0107db8:	89 c1                	mov    %eax,%ecx
f0107dba:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0107dbd:	89 fe                	mov    %edi,%esi
f0107dbf:	d3 ee                	shr    %cl,%esi
f0107dc1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107dc5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107dc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107dcb:	d3 e7                	shl    %cl,%edi
f0107dcd:	89 c1                	mov    %eax,%ecx
f0107dcf:	d3 ea                	shr    %cl,%edx
f0107dd1:	09 d7                	or     %edx,%edi
f0107dd3:	89 f2                	mov    %esi,%edx
f0107dd5:	89 f8                	mov    %edi,%eax
f0107dd7:	f7 75 ec             	divl   -0x14(%ebp)
f0107dda:	89 d6                	mov    %edx,%esi
f0107ddc:	89 c7                	mov    %eax,%edi
f0107dde:	f7 65 e8             	mull   -0x18(%ebp)
f0107de1:	39 d6                	cmp    %edx,%esi
f0107de3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107de6:	72 30                	jb     f0107e18 <__udivdi3+0x118>
f0107de8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0107deb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0107def:	d3 e2                	shl    %cl,%edx
f0107df1:	39 c2                	cmp    %eax,%edx
f0107df3:	73 05                	jae    f0107dfa <__udivdi3+0xfa>
f0107df5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f0107df8:	74 1e                	je     f0107e18 <__udivdi3+0x118>
f0107dfa:	89 f9                	mov    %edi,%ecx
f0107dfc:	31 ff                	xor    %edi,%edi
f0107dfe:	e9 71 ff ff ff       	jmp    f0107d74 <__udivdi3+0x74>
f0107e03:	90                   	nop
f0107e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107e08:	31 ff                	xor    %edi,%edi
f0107e0a:	b9 01 00 00 00       	mov    $0x1,%ecx
f0107e0f:	e9 60 ff ff ff       	jmp    f0107d74 <__udivdi3+0x74>
f0107e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107e18:	8d 4f ff             	lea    -0x1(%edi),%ecx
f0107e1b:	31 ff                	xor    %edi,%edi
f0107e1d:	89 c8                	mov    %ecx,%eax
f0107e1f:	89 fa                	mov    %edi,%edx
f0107e21:	83 c4 10             	add    $0x10,%esp
f0107e24:	5e                   	pop    %esi
f0107e25:	5f                   	pop    %edi
f0107e26:	5d                   	pop    %ebp
f0107e27:	c3                   	ret    
	...

f0107e30 <__umoddi3>:
f0107e30:	55                   	push   %ebp
f0107e31:	89 e5                	mov    %esp,%ebp
f0107e33:	57                   	push   %edi
f0107e34:	56                   	push   %esi
f0107e35:	83 ec 20             	sub    $0x20,%esp
f0107e38:	8b 55 14             	mov    0x14(%ebp),%edx
f0107e3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0107e3e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0107e41:	8b 75 0c             	mov    0xc(%ebp),%esi
f0107e44:	85 d2                	test   %edx,%edx
f0107e46:	89 c8                	mov    %ecx,%eax
f0107e48:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0107e4b:	75 13                	jne    f0107e60 <__umoddi3+0x30>
f0107e4d:	39 f7                	cmp    %esi,%edi
f0107e4f:	76 3f                	jbe    f0107e90 <__umoddi3+0x60>
f0107e51:	89 f2                	mov    %esi,%edx
f0107e53:	f7 f7                	div    %edi
f0107e55:	89 d0                	mov    %edx,%eax
f0107e57:	31 d2                	xor    %edx,%edx
f0107e59:	83 c4 20             	add    $0x20,%esp
f0107e5c:	5e                   	pop    %esi
f0107e5d:	5f                   	pop    %edi
f0107e5e:	5d                   	pop    %ebp
f0107e5f:	c3                   	ret    
f0107e60:	39 f2                	cmp    %esi,%edx
f0107e62:	77 4c                	ja     f0107eb0 <__umoddi3+0x80>
f0107e64:	0f bd ca             	bsr    %edx,%ecx
f0107e67:	83 f1 1f             	xor    $0x1f,%ecx
f0107e6a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0107e6d:	75 51                	jne    f0107ec0 <__umoddi3+0x90>
f0107e6f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0107e72:	0f 87 e0 00 00 00    	ja     f0107f58 <__umoddi3+0x128>
f0107e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e7b:	29 f8                	sub    %edi,%eax
f0107e7d:	19 d6                	sbb    %edx,%esi
f0107e7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0107e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107e85:	89 f2                	mov    %esi,%edx
f0107e87:	83 c4 20             	add    $0x20,%esp
f0107e8a:	5e                   	pop    %esi
f0107e8b:	5f                   	pop    %edi
f0107e8c:	5d                   	pop    %ebp
f0107e8d:	c3                   	ret    
f0107e8e:	66 90                	xchg   %ax,%ax
f0107e90:	85 ff                	test   %edi,%edi
f0107e92:	75 0b                	jne    f0107e9f <__umoddi3+0x6f>
f0107e94:	b8 01 00 00 00       	mov    $0x1,%eax
f0107e99:	31 d2                	xor    %edx,%edx
f0107e9b:	f7 f7                	div    %edi
f0107e9d:	89 c7                	mov    %eax,%edi
f0107e9f:	89 f0                	mov    %esi,%eax
f0107ea1:	31 d2                	xor    %edx,%edx
f0107ea3:	f7 f7                	div    %edi
f0107ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0107ea8:	f7 f7                	div    %edi
f0107eaa:	eb a9                	jmp    f0107e55 <__umoddi3+0x25>
f0107eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107eb0:	89 c8                	mov    %ecx,%eax
f0107eb2:	89 f2                	mov    %esi,%edx
f0107eb4:	83 c4 20             	add    $0x20,%esp
f0107eb7:	5e                   	pop    %esi
f0107eb8:	5f                   	pop    %edi
f0107eb9:	5d                   	pop    %ebp
f0107eba:	c3                   	ret    
f0107ebb:	90                   	nop
f0107ebc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107ec0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107ec4:	d3 e2                	shl    %cl,%edx
f0107ec6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107ec9:	ba 20 00 00 00       	mov    $0x20,%edx
f0107ece:	2b 55 f0             	sub    -0x10(%ebp),%edx
f0107ed1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0107ed4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107ed8:	89 fa                	mov    %edi,%edx
f0107eda:	d3 ea                	shr    %cl,%edx
f0107edc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107ee0:	0b 55 f4             	or     -0xc(%ebp),%edx
f0107ee3:	d3 e7                	shl    %cl,%edi
f0107ee5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107ee9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0107eec:	89 f2                	mov    %esi,%edx
f0107eee:	89 7d e8             	mov    %edi,-0x18(%ebp)
f0107ef1:	89 c7                	mov    %eax,%edi
f0107ef3:	d3 ea                	shr    %cl,%edx
f0107ef5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107ef9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0107efc:	89 c2                	mov    %eax,%edx
f0107efe:	d3 e6                	shl    %cl,%esi
f0107f00:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107f04:	d3 ea                	shr    %cl,%edx
f0107f06:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f0a:	09 d6                	or     %edx,%esi
f0107f0c:	89 f0                	mov    %esi,%eax
f0107f0e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0107f11:	d3 e7                	shl    %cl,%edi
f0107f13:	89 f2                	mov    %esi,%edx
f0107f15:	f7 75 f4             	divl   -0xc(%ebp)
f0107f18:	89 d6                	mov    %edx,%esi
f0107f1a:	f7 65 e8             	mull   -0x18(%ebp)
f0107f1d:	39 d6                	cmp    %edx,%esi
f0107f1f:	72 2b                	jb     f0107f4c <__umoddi3+0x11c>
f0107f21:	39 c7                	cmp    %eax,%edi
f0107f23:	72 23                	jb     f0107f48 <__umoddi3+0x118>
f0107f25:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f29:	29 c7                	sub    %eax,%edi
f0107f2b:	19 d6                	sbb    %edx,%esi
f0107f2d:	89 f0                	mov    %esi,%eax
f0107f2f:	89 f2                	mov    %esi,%edx
f0107f31:	d3 ef                	shr    %cl,%edi
f0107f33:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0107f37:	d3 e0                	shl    %cl,%eax
f0107f39:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0107f3d:	09 f8                	or     %edi,%eax
f0107f3f:	d3 ea                	shr    %cl,%edx
f0107f41:	83 c4 20             	add    $0x20,%esp
f0107f44:	5e                   	pop    %esi
f0107f45:	5f                   	pop    %edi
f0107f46:	5d                   	pop    %ebp
f0107f47:	c3                   	ret    
f0107f48:	39 d6                	cmp    %edx,%esi
f0107f4a:	75 d9                	jne    f0107f25 <__umoddi3+0xf5>
f0107f4c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f0107f4f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0107f52:	eb d1                	jmp    f0107f25 <__umoddi3+0xf5>
f0107f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0107f58:	39 f2                	cmp    %esi,%edx
f0107f5a:	0f 82 18 ff ff ff    	jb     f0107e78 <__umoddi3+0x48>
f0107f60:	e9 1d ff ff ff       	jmp    f0107e82 <__umoddi3+0x52>
