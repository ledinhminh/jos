
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 27 1d 00 00       	call   801d58 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800046:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80004b:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  80004c:	0f b6 d8             	movzbl %al,%ebx
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 c0 00 00 00       	and    $0xc0,%eax
  800056:	83 f8 40             	cmp    $0x40,%eax
  800059:	75 f0                	jne    80004b <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80005b:	85 c9                	test   %ecx,%ecx
  80005d:	74 0a                	je     800069 <ide_wait_ready+0x29>
  80005f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800064:	f6 c3 21             	test   $0x21,%bl
  800067:	75 05                	jne    80006e <ide_wait_ready+0x2e>
  800069:	b8 00 00 00 00       	mov    $0x0,%eax
		return -1;
	return 0;
}
  80006e:	5b                   	pop    %ebx
  80006f:	5d                   	pop    %ebp
  800070:	c3                   	ret    

00800071 <ide_write>:
	return 0;
}

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  800071:	55                   	push   %ebp
  800072:	89 e5                	mov    %esp,%ebp
  800074:	57                   	push   %edi
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	83 ec 1c             	sub    $0x1c,%esp
  80007a:	8b 75 08             	mov    0x8(%ebp),%esi
  80007d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800080:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  800083:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  800089:	76 24                	jbe    8000af <ide_write+0x3e>
  80008b:	c7 44 24 0c e0 3a 80 	movl   $0x803ae0,0xc(%esp)
  800092:	00 
  800093:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  80009a:	00 
  80009b:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8000a2:	00 
  8000a3:	c7 04 24 02 3b 80 00 	movl   $0x803b02,(%esp)
  8000aa:	e8 15 1d 00 00       	call   801dc4 <_panic>

	ide_wait_ready(0);
  8000af:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b4:	e8 87 ff ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8000b9:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8000be:	89 f8                	mov    %edi,%eax
  8000c0:	ee                   	out    %al,(%dx)
  8000c1:	b2 f3                	mov    $0xf3,%dl
  8000c3:	89 f0                	mov    %esi,%eax
  8000c5:	ee                   	out    %al,(%dx)
  8000c6:	89 f0                	mov    %esi,%eax
  8000c8:	c1 e8 08             	shr    $0x8,%eax
  8000cb:	b2 f4                	mov    $0xf4,%dl
  8000cd:	ee                   	out    %al,(%dx)
  8000ce:	89 f0                	mov    %esi,%eax
  8000d0:	c1 e8 10             	shr    $0x10,%eax
  8000d3:	b2 f5                	mov    $0xf5,%dl
  8000d5:	ee                   	out    %al,(%dx)
  8000d6:	a1 00 50 80 00       	mov    0x805000,%eax
  8000db:	83 e0 01             	and    $0x1,%eax
  8000de:	c1 e0 04             	shl    $0x4,%eax
  8000e1:	83 c8 e0             	or     $0xffffffe0,%eax
  8000e4:	c1 ee 18             	shr    $0x18,%esi
  8000e7:	83 e6 0f             	and    $0xf,%esi
  8000ea:	09 f0                	or     %esi,%eax
  8000ec:	b2 f6                	mov    $0xf6,%dl
  8000ee:	ee                   	out    %al,(%dx)
  8000ef:	b2 f7                	mov    $0xf7,%dl
  8000f1:	b8 30 00 00 00       	mov    $0x30,%eax
  8000f6:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  8000f7:	85 ff                	test   %edi,%edi
  8000f9:	74 2a                	je     800125 <ide_write+0xb4>
		if ((r = ide_wait_ready(1)) < 0)
  8000fb:	b8 01 00 00 00       	mov    $0x1,%eax
  800100:	e8 3b ff ff ff       	call   800040 <ide_wait_ready>
  800105:	85 c0                	test   %eax,%eax
  800107:	78 21                	js     80012a <ide_write+0xb9>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  800109:	89 de                	mov    %ebx,%esi
  80010b:	b9 80 00 00 00       	mov    $0x80,%ecx
  800110:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800115:	fc                   	cld    
  800116:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800118:	83 ef 01             	sub    $0x1,%edi
  80011b:	74 08                	je     800125 <ide_write+0xb4>
  80011d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800123:	eb d6                	jmp    8000fb <ide_write+0x8a>
  800125:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
}
  80012a:	83 c4 1c             	add    $0x1c,%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <ide_read>:
	diskno = d;
}

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	83 ec 1c             	sub    $0x1c,%esp
  80013b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80013e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800141:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800144:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80014a:	76 24                	jbe    800170 <ide_read+0x3e>
  80014c:	c7 44 24 0c e0 3a 80 	movl   $0x803ae0,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800163:	00 
  800164:	c7 04 24 02 3b 80 00 	movl   $0x803b02,(%esp)
  80016b:	e8 54 1c 00 00       	call   801dc4 <_panic>

	ide_wait_ready(0);
  800170:	b8 00 00 00 00       	mov    $0x0,%eax
  800175:	e8 c6 fe ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80017a:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80017f:	89 f0                	mov    %esi,%eax
  800181:	ee                   	out    %al,(%dx)
  800182:	b2 f3                	mov    $0xf3,%dl
  800184:	89 f8                	mov    %edi,%eax
  800186:	ee                   	out    %al,(%dx)
  800187:	89 f8                	mov    %edi,%eax
  800189:	c1 e8 08             	shr    $0x8,%eax
  80018c:	b2 f4                	mov    $0xf4,%dl
  80018e:	ee                   	out    %al,(%dx)
  80018f:	89 f8                	mov    %edi,%eax
  800191:	c1 e8 10             	shr    $0x10,%eax
  800194:	b2 f5                	mov    $0xf5,%dl
  800196:	ee                   	out    %al,(%dx)
  800197:	a1 00 50 80 00       	mov    0x805000,%eax
  80019c:	83 e0 01             	and    $0x1,%eax
  80019f:	c1 e0 04             	shl    $0x4,%eax
  8001a2:	83 c8 e0             	or     $0xffffffe0,%eax
  8001a5:	c1 ef 18             	shr    $0x18,%edi
  8001a8:	83 e7 0f             	and    $0xf,%edi
  8001ab:	09 f8                	or     %edi,%eax
  8001ad:	b2 f6                	mov    $0xf6,%dl
  8001af:	ee                   	out    %al,(%dx)
  8001b0:	b2 f7                	mov    $0xf7,%dl
  8001b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8001b7:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001b8:	85 f6                	test   %esi,%esi
  8001ba:	74 2a                	je     8001e6 <ide_read+0xb4>
		if ((r = ide_wait_ready(1)) < 0)
  8001bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8001c1:	e8 7a fe ff ff       	call   800040 <ide_wait_ready>
  8001c6:	85 c0                	test   %eax,%eax
  8001c8:	78 21                	js     8001eb <ide_read+0xb9>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  8001ca:	89 df                	mov    %ebx,%edi
  8001cc:	b9 80 00 00 00       	mov    $0x80,%ecx
  8001d1:	ba f0 01 00 00       	mov    $0x1f0,%edx
  8001d6:	fc                   	cld    
  8001d7:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8001d9:	83 ee 01             	sub    $0x1,%esi
  8001dc:	74 08                	je     8001e6 <ide_read+0xb4>
  8001de:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8001e4:	eb d6                	jmp    8001bc <ide_read+0x8a>
  8001e6:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
}
  8001eb:	83 c4 1c             	add    $0x1c,%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5e                   	pop    %esi
  8001f0:	5f                   	pop    %edi
  8001f1:	5d                   	pop    %ebp
  8001f2:	c3                   	ret    

008001f3 <ide_set_disk>:
	return (x < 1000);
}

void
ide_set_disk(int d)
{
  8001f3:	55                   	push   %ebp
  8001f4:	89 e5                	mov    %esp,%ebp
  8001f6:	83 ec 18             	sub    $0x18,%esp
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8001fc:	83 f8 01             	cmp    $0x1,%eax
  8001ff:	76 1c                	jbe    80021d <ide_set_disk+0x2a>
		panic("bad disk number");
  800201:	c7 44 24 08 0b 3b 80 	movl   $0x803b0b,0x8(%esp)
  800208:	00 
  800209:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800210:	00 
  800211:	c7 04 24 02 3b 80 00 	movl   $0x803b02,(%esp)
  800218:	e8 a7 1b 00 00       	call   801dc4 <_panic>
	diskno = d;
  80021d:	a3 00 50 80 00       	mov    %eax,0x805000
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <ide_probe_disk1>:
	return 0;
}

bool
ide_probe_disk1(void)
{
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80022b:	b8 00 00 00 00       	mov    $0x0,%eax
  800230:	e8 0b fe ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800235:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80023a:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80023f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800240:	b2 f7                	mov    $0xf7,%dl
  800242:	ec                   	in     (%dx),%al

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800243:	b9 01 00 00 00       	mov    $0x1,%ecx
  800248:	a8 a1                	test   $0xa1,%al
  80024a:	75 0f                	jne    80025b <ide_probe_disk1+0x37>
  80024c:	b1 00                	mov    $0x0,%cl
  80024e:	eb 10                	jmp    800260 <ide_probe_disk1+0x3c>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800250:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800253:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800259:	74 05                	je     800260 <ide_probe_disk1+0x3c>
  80025b:	ec                   	in     (%dx),%al
  80025c:	a8 a1                	test   $0xa1,%al
  80025e:	75 f0                	jne    800250 <ide_probe_disk1+0x2c>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800260:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800265:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80026a:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  80026b:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  800271:	0f 9e c3             	setle  %bl
  800274:	0f b6 db             	movzbl %bl,%ebx
  800277:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80027b:	c7 04 24 1b 3b 80 00 	movl   $0x803b1b,(%esp)
  800282:	e8 f6 1b 00 00       	call   801e7d <cprintf>
	return (x < 1000);
}
  800287:	89 d8                	mov    %ebx,%eax
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    
	...

00800290 <va_is_mapped>:
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
	return (vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P);
  800293:	8b 55 08             	mov    0x8(%ebp),%edx
  800296:	89 d0                	mov    %edx,%eax
  800298:	c1 e8 16             	shr    $0x16,%eax
  80029b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8002a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a7:	f6 c1 01             	test   $0x1,%cl
  8002aa:	74 0d                	je     8002b9 <va_is_mapped+0x29>
  8002ac:	c1 ea 0c             	shr    $0xc,%edx
  8002af:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8002b6:	83 e0 01             	and    $0x1,%eax
}
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
	return (vpt[PGNUM(va)] & PTE_D) != 0;
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	c1 e8 0c             	shr    $0xc,%eax
  8002c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8002cb:	c1 e8 06             	shr    $0x6,%eax
  8002ce:	83 e0 01             	and    $0x1,%eax
}
  8002d1:	5d                   	pop    %ebp
  8002d2:	c3                   	ret    

008002d3 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	83 ec 18             	sub    $0x18,%esp
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	74 0f                	je     8002ef <diskaddr+0x1c>
  8002e0:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8002e6:	85 d2                	test   %edx,%edx
  8002e8:	74 25                	je     80030f <diskaddr+0x3c>
  8002ea:	3b 42 04             	cmp    0x4(%edx),%eax
  8002ed:	72 20                	jb     80030f <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  8002ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002f3:	c7 44 24 08 34 3b 80 	movl   $0x803b34,0x8(%esp)
  8002fa:	00 
  8002fb:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800302:	00 
  800303:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  80030a:	e8 b5 1a 00 00       	call   801dc4 <_panic>
  80030f:	05 00 00 01 00       	add    $0x10000,%eax
  800314:	c1 e0 0c             	shl    $0xc,%eax
	return (char*) (DISKMAP + blockno * BLKSIZE);
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <bc_pgfault>:
// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 20             	sub    $0x20,%esp
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800324:	8b 30                	mov    (%eax),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800326:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
  80032c:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800332:	76 2e                	jbe    800362 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800334:	8b 50 04             	mov    0x4(%eax),%edx
  800337:	89 54 24 14          	mov    %edx,0x14(%esp)
  80033b:	89 74 24 10          	mov    %esi,0x10(%esp)
  80033f:	8b 40 28             	mov    0x28(%eax),%eax
  800342:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800346:	c7 44 24 08 58 3b 80 	movl   $0x803b58,0x8(%esp)
  80034d:	00 
  80034e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  800355:	00 
  800356:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  80035d:	e8 62 1a 00 00       	call   801dc4 <_panic>
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800362:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  800368:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  80036b:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800370:	85 c0                	test   %eax,%eax
  800372:	74 25                	je     800399 <bc_pgfault+0x80>
  800374:	3b 70 04             	cmp    0x4(%eax),%esi
  800377:	72 20                	jb     800399 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  800379:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80037d:	c7 44 24 08 88 3b 80 	movl   $0x803b88,0x8(%esp)
  800384:	00 
  800385:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80038c:	00 
  80038d:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  800394:	e8 2b 1a 00 00       	call   801dc4 <_panic>
	// of the block from the disk into that page, and mark the
	// page not-dirty (since reading the data from disk will mark
	// the page dirty).
	//
	// LAB 5: Your code here
  addr = diskaddr(blockno);
  800399:	89 34 24             	mov    %esi,(%esp)
  80039c:	e8 32 ff ff ff       	call   8002d3 <diskaddr>
  8003a1:	89 c3                	mov    %eax,%ebx
  r = sys_page_alloc(thisenv->env_id, addr, PTE_U|PTE_W|PTE_P);
  8003a3:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8003a8:	8b 40 48             	mov    0x48(%eax),%eax
  8003ab:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8003b2:	00 
  8003b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	e8 eb 27 00 00       	call   802baa <sys_page_alloc>
  if (r < 0)
  8003bf:	85 c0                	test   %eax,%eax
  8003c1:	79 20                	jns    8003e3 <bc_pgfault+0xca>
    panic("sys_page_alloc failed: %e", r);
  8003c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003c7:	c7 44 24 08 d8 3b 80 	movl   $0x803bd8,0x8(%esp)
  8003ce:	00 
  8003cf:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  8003d6:	00 
  8003d7:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  8003de:	e8 e1 19 00 00       	call   801dc4 <_panic>
  r = ide_read(blockno * BLKSECTS, addr, BLKSECTS);
  8003e3:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8003ea:	00 
  8003eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003ef:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  8003f6:	89 04 24             	mov    %eax,(%esp)
  8003f9:	e8 34 fd ff ff       	call   800132 <ide_read>
  if (r < 0)
  8003fe:	85 c0                	test   %eax,%eax
  800400:	79 20                	jns    800422 <bc_pgfault+0x109>
    panic("ide_read failed: %e", r);
  800402:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800406:	c7 44 24 08 f2 3b 80 	movl   $0x803bf2,0x8(%esp)
  80040d:	00 
  80040e:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  800415:	00 
  800416:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  80041d:	e8 a2 19 00 00       	call   801dc4 <_panic>
  r = sys_page_map(thisenv->env_id, addr, thisenv->env_id, addr, PTE_SYSCALL);
  800422:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800427:	8b 50 48             	mov    0x48(%eax),%edx
  80042a:	8b 40 48             	mov    0x48(%eax),%eax
  80042d:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800434:	00 
  800435:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800439:	89 54 24 08          	mov    %edx,0x8(%esp)
  80043d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800441:	89 04 24             	mov    %eax,(%esp)
  800444:	e8 28 27 00 00       	call   802b71 <sys_page_map>
  if (r < 0)
  800449:	85 c0                	test   %eax,%eax
  80044b:	79 20                	jns    80046d <bc_pgfault+0x154>
    panic("sys_page_map failed: %e", r);	
  80044d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800451:	c7 44 24 08 06 3c 80 	movl   $0x803c06,0x8(%esp)
  800458:	00 
  800459:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  800460:	00 
  800461:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  800468:	e8 57 19 00 00       	call   801dc4 <_panic>
	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80046d:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800474:	74 2c                	je     8004a2 <bc_pgfault+0x189>
  800476:	89 34 24             	mov    %esi,(%esp)
  800479:	e8 02 03 00 00       	call   800780 <block_is_free>
  80047e:	85 c0                	test   %eax,%eax
  800480:	74 20                	je     8004a2 <bc_pgfault+0x189>
		panic("reading free block %08x\n", blockno);
  800482:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800486:	c7 44 24 08 1e 3c 80 	movl   $0x803c1e,0x8(%esp)
  80048d:	00 
  80048e:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  800495:	00 
  800496:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  80049d:	e8 22 19 00 00       	call   801dc4 <_panic>
}
  8004a2:	83 c4 20             	add    $0x20,%esp
  8004a5:	5b                   	pop    %ebx
  8004a6:	5e                   	pop    %esi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    

008004a9 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8004a9:	55                   	push   %ebp
  8004aa:	89 e5                	mov    %esp,%ebp
  8004ac:	83 ec 28             	sub    $0x28,%esp
  8004af:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8004b2:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8004b5:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  8004b8:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  8004be:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  8004c3:	76 20                	jbe    8004e5 <flush_block+0x3c>
		panic("flush_block of bad va %08x", addr);
  8004c5:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8004c9:	c7 44 24 08 37 3c 80 	movl   $0x803c37,0x8(%esp)
  8004d0:	00 
  8004d1:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8004d8:	00 
  8004d9:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  8004e0:	e8 df 18 00 00       	call   801dc4 <_panic>
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004e5:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  8004eb:	c1 ee 0c             	shr    $0xc,%esi
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
  int r;

  addr = diskaddr(blockno);
  8004ee:	89 34 24             	mov    %esi,(%esp)
  8004f1:	e8 dd fd ff ff       	call   8002d3 <diskaddr>
  8004f6:	89 c3                	mov    %eax,%ebx
  if (!va_is_mapped(addr) || !va_is_dirty(addr))
  8004f8:	89 04 24             	mov    %eax,(%esp)
  8004fb:	e8 90 fd ff ff       	call   800290 <va_is_mapped>
  800500:	85 c0                	test   %eax,%eax
  800502:	0f 84 96 00 00 00    	je     80059e <flush_block+0xf5>
  800508:	89 1c 24             	mov    %ebx,(%esp)
  80050b:	e8 ab fd ff ff       	call   8002bb <va_is_dirty>
  800510:	85 c0                	test   %eax,%eax
  800512:	0f 84 86 00 00 00    	je     80059e <flush_block+0xf5>
    return;
  r = ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  800518:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  80051f:	00 
  800520:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800524:	c1 e6 03             	shl    $0x3,%esi
  800527:	89 34 24             	mov    %esi,(%esp)
  80052a:	e8 42 fb ff ff       	call   800071 <ide_write>
  if (r < 0)
  80052f:	85 c0                	test   %eax,%eax
  800531:	79 20                	jns    800553 <flush_block+0xaa>
    panic("ide_write failed: %e", r);
  800533:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800537:	c7 44 24 08 52 3c 80 	movl   $0x803c52,0x8(%esp)
  80053e:	00 
  80053f:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800546:	00 
  800547:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  80054e:	e8 71 18 00 00       	call   801dc4 <_panic>
  r = sys_page_map(thisenv->env_id, addr, thisenv->env_id, addr, PTE_SYSCALL);
  800553:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  800558:	8b 50 48             	mov    0x48(%eax),%edx
  80055b:	8b 40 48             	mov    0x48(%eax),%eax
  80055e:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800565:	00 
  800566:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80056a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80056e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800572:	89 04 24             	mov    %eax,(%esp)
  800575:	e8 f7 25 00 00       	call   802b71 <sys_page_map>
  if (r < 0)
  80057a:	85 c0                	test   %eax,%eax
  80057c:	79 20                	jns    80059e <flush_block+0xf5>
    panic("sys_page_map failed: %e", r);	
  80057e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800582:	c7 44 24 08 06 3c 80 	movl   $0x803c06,0x8(%esp)
  800589:	00 
  80058a:	c7 44 24 04 5f 00 00 	movl   $0x5f,0x4(%esp)
  800591:	00 
  800592:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  800599:	e8 26 18 00 00       	call   801dc4 <_panic>
}
  80059e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005a1:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005a4:	89 ec                	mov    %ebp,%esp
  8005a6:	5d                   	pop    %ebp
  8005a7:	c3                   	ret    

008005a8 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  8005a8:	55                   	push   %ebp
  8005a9:	89 e5                	mov    %esp,%ebp
  8005ab:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8005b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005b8:	e8 16 fd ff ff       	call   8002d3 <diskaddr>
  8005bd:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8005c4:	00 
  8005c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005cf:	89 04 24             	mov    %eax,(%esp)
  8005d2:	e8 ce 21 00 00       	call   8027a5 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8005d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005de:	e8 f0 fc ff ff       	call   8002d3 <diskaddr>
  8005e3:	c7 44 24 04 67 3c 80 	movl   $0x803c67,0x4(%esp)
  8005ea:	00 
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 c7 1f 00 00       	call   8025ba <strcpy>
	flush_block(diskaddr(1));
  8005f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005fa:	e8 d4 fc ff ff       	call   8002d3 <diskaddr>
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	e8 a2 fe ff ff       	call   8004a9 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800607:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80060e:	e8 c0 fc ff ff       	call   8002d3 <diskaddr>
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	e8 75 fc ff ff       	call   800290 <va_is_mapped>
  80061b:	85 c0                	test   %eax,%eax
  80061d:	75 24                	jne    800643 <check_bc+0x9b>
  80061f:	c7 44 24 0c 89 3c 80 	movl   $0x803c89,0xc(%esp)
  800626:	00 
  800627:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  80062e:	00 
  80062f:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  800636:	00 
  800637:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  80063e:	e8 81 17 00 00       	call   801dc4 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800643:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80064a:	e8 84 fc ff ff       	call   8002d3 <diskaddr>
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 64 fc ff ff       	call   8002bb <va_is_dirty>
  800657:	85 c0                	test   %eax,%eax
  800659:	74 24                	je     80067f <check_bc+0xd7>
  80065b:	c7 44 24 0c 6e 3c 80 	movl   $0x803c6e,0xc(%esp)
  800662:	00 
  800663:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  80066a:	00 
  80066b:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800672:	00 
  800673:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  80067a:	e8 45 17 00 00       	call   801dc4 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80067f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800686:	e8 48 fc ff ff       	call   8002d3 <diskaddr>
  80068b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800696:	e8 9e 24 00 00       	call   802b39 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80069b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006a2:	e8 2c fc ff ff       	call   8002d3 <diskaddr>
  8006a7:	89 04 24             	mov    %eax,(%esp)
  8006aa:	e8 e1 fb ff ff       	call   800290 <va_is_mapped>
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	74 24                	je     8006d7 <check_bc+0x12f>
  8006b3:	c7 44 24 0c 88 3c 80 	movl   $0x803c88,0xc(%esp)
  8006ba:	00 
  8006bb:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  8006c2:	00 
  8006c3:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8006ca:	00 
  8006cb:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  8006d2:	e8 ed 16 00 00       	call   801dc4 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8006d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006de:	e8 f0 fb ff ff       	call   8002d3 <diskaddr>
  8006e3:	c7 44 24 04 67 3c 80 	movl   $0x803c67,0x4(%esp)
  8006ea:	00 
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	e8 82 1f 00 00       	call   802675 <strcmp>
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 24                	je     80071b <check_bc+0x173>
  8006f7:	c7 44 24 0c ac 3b 80 	movl   $0x803bac,0xc(%esp)
  8006fe:	00 
  8006ff:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  800706:	00 
  800707:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  80070e:	00 
  80070f:	c7 04 24 d0 3b 80 00 	movl   $0x803bd0,(%esp)
  800716:	e8 a9 16 00 00       	call   801dc4 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80071b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800722:	e8 ac fb ff ff       	call   8002d3 <diskaddr>
  800727:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80072e:	00 
  80072f:	8d 95 f0 fe ff ff    	lea    -0x110(%ebp),%edx
  800735:	89 54 24 04          	mov    %edx,0x4(%esp)
  800739:	89 04 24             	mov    %eax,(%esp)
  80073c:	e8 64 20 00 00       	call   8027a5 <memmove>
	flush_block(diskaddr(1));
  800741:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800748:	e8 86 fb ff ff       	call   8002d3 <diskaddr>
  80074d:	89 04 24             	mov    %eax,(%esp)
  800750:	e8 54 fd ff ff       	call   8004a9 <flush_block>

	cprintf("block cache is good\n");
  800755:	c7 04 24 a3 3c 80 00 	movl   $0x803ca3,(%esp)
  80075c:	e8 1c 17 00 00       	call   801e7d <cprintf>
}
  800761:	c9                   	leave  
  800762:	c3                   	ret    

00800763 <bc_init>:

void
bc_init(void)
{
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(bc_pgfault);
  800769:	c7 04 24 19 03 80 00 	movl   $0x800319,(%esp)
  800770:	e8 c7 25 00 00       	call   802d3c <set_pgfault_handler>
	check_bc();
  800775:	e8 2e fe ff ff       	call   8005a8 <check_bc>
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    
  80077c:	00 00                	add    %al,(%eax)
	...

00800780 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	53                   	push   %ebx
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
	if (super == 0 || blockno >= super->s_nblocks)
  800787:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 25                	je     8007b6 <block_is_free+0x36>
  800791:	39 42 04             	cmp    %eax,0x4(%edx)
  800794:	76 20                	jbe    8007b6 <block_is_free+0x36>
  800796:	89 c1                	mov    %eax,%ecx
  800798:	83 e1 1f             	and    $0x1f,%ecx
  80079b:	ba 01 00 00 00       	mov    $0x1,%edx
  8007a0:	d3 e2                	shl    %cl,%edx
  8007a2:	c1 e8 05             	shr    $0x5,%eax
  8007a5:	8b 1d 04 a0 80 00    	mov    0x80a004,%ebx
  8007ab:	85 14 83             	test   %edx,(%ebx,%eax,4)
  8007ae:	0f 95 c0             	setne  %al
  8007b1:	0f b6 c0             	movzbl %al,%eax
  8007b4:	eb 05                	jmp    8007bb <block_is_free+0x3b>
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8007bb:	5b                   	pop    %ebx
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  8007c1:	80 38 2f             	cmpb   $0x2f,(%eax)
  8007c4:	75 08                	jne    8007ce <skip_slash+0x10>
		p++;
  8007c6:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8007c9:	80 38 2f             	cmpb   $0x2f,(%eax)
  8007cc:	74 f8                	je     8007c6 <skip_slash+0x8>
		p++;
	return p;
}
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <fs_sync>:
}

// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8007d7:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8007dc:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
  8007e0:	76 2a                	jbe    80080c <fs_sync+0x3c>
  8007e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8007e7:	bb 01 00 00 00       	mov    $0x1,%ebx
		flush_block(diskaddr(i));
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	e8 df fa ff ff       	call   8002d3 <diskaddr>
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	e8 ad fc ff ff       	call   8004a9 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  8007fc:	83 c3 01             	add    $0x1,%ebx
  8007ff:	89 d8                	mov    %ebx,%eax
  800801:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800807:	39 5a 04             	cmp    %ebx,0x4(%edx)
  80080a:	77 e0                	ja     8007ec <fs_sync+0x1c>
		flush_block(diskaddr(i));
}
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	83 ec 10             	sub    $0x10,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
  uint32_t i;
	for (i = 0; i < super->s_nblocks; i++) {
  80081a:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80081f:	8b 70 04             	mov    0x4(%eax),%esi
  800822:	85 f6                	test   %esi,%esi
  800824:	74 43                	je     800869 <alloc_block+0x57>
  800826:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (block_is_free(i)) { // block is free
  80082b:	89 1c 24             	mov    %ebx,(%esp)
  80082e:	e8 4d ff ff ff       	call   800780 <block_is_free>
  800833:	85 c0                	test   %eax,%eax
  800835:	74 2b                	je     800862 <alloc_block+0x50>
				bitmap[i/32] ^= 1<<(i%32);
  800837:	89 d8                	mov    %ebx,%eax
  800839:	c1 e8 05             	shr    $0x5,%eax
  80083c:	c1 e0 02             	shl    $0x2,%eax
  80083f:	03 05 04 a0 80 00    	add    0x80a004,%eax
  800845:	89 d9                	mov    %ebx,%ecx
  800847:	83 e1 1f             	and    $0x1f,%ecx
  80084a:	ba 01 00 00 00       	mov    $0x1,%edx
  80084f:	d3 e2                	shl    %cl,%edx
  800851:	31 10                	xor    %edx,(%eax)
				flush_block(bitmap);
  800853:	a1 04 a0 80 00       	mov    0x80a004,%eax
  800858:	89 04 24             	mov    %eax,(%esp)
  80085b:	e8 49 fc ff ff       	call   8004a9 <flush_block>
				return i;
  800860:	eb 0c                	jmp    80086e <alloc_block+0x5c>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
  uint32_t i;
	for (i = 0; i < super->s_nblocks; i++) {
  800862:	83 c3 01             	add    $0x1,%ebx
  800865:	39 f3                	cmp    %esi,%ebx
  800867:	72 c2                	jb     80082b <alloc_block+0x19>
  800869:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
				flush_block(bitmap);
				return i;
			}
	}
	return -E_NO_DISK;
}
  80086e:	89 d8                	mov    %ebx,%eax
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	5b                   	pop    %ebx
  800874:	5e                   	pop    %esi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <free_block>:
}

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 18             	sub    $0x18,%esp
  80087d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800880:	85 c9                	test   %ecx,%ecx
  800882:	75 1c                	jne    8008a0 <free_block+0x29>
		panic("attempt to free zero block");
  800884:	c7 44 24 08 b8 3c 80 	movl   $0x803cb8,0x8(%esp)
  80088b:	00 
  80088c:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800893:	00 
  800894:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  80089b:	e8 24 15 00 00       	call   801dc4 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8008a0:	89 c8                	mov    %ecx,%eax
  8008a2:	c1 e8 05             	shr    $0x5,%eax
  8008a5:	c1 e0 02             	shl    $0x2,%eax
  8008a8:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8008ae:	83 e1 1f             	and    $0x1f,%ecx
  8008b1:	ba 01 00 00 00       	mov    $0x1,%edx
  8008b6:	d3 e2                	shl    %cl,%edx
  8008b8:	09 10                	or     %edx,(%eax)
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	56                   	push   %esi
  8008c0:	53                   	push   %ebx
  8008c1:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  8008c4:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8008c9:	8b 70 04             	mov    0x4(%eax),%esi
  8008cc:	85 f6                	test   %esi,%esi
  8008ce:	74 44                	je     800914 <check_bitmap+0x58>
  8008d0:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(!block_is_free(2+i));
  8008d5:	8d 43 02             	lea    0x2(%ebx),%eax
  8008d8:	89 04 24             	mov    %eax,(%esp)
  8008db:	e8 a0 fe ff ff       	call   800780 <block_is_free>
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	74 24                	je     800908 <check_bitmap+0x4c>
  8008e4:	c7 44 24 0c db 3c 80 	movl   $0x803cdb,0xc(%esp)
  8008eb:	00 
  8008ec:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  8008f3:	00 
  8008f4:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  8008fb:	00 
  8008fc:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  800903:	e8 bc 14 00 00       	call   801dc4 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800908:	83 c3 01             	add    $0x1,%ebx
  80090b:	89 d8                	mov    %ebx,%eax
  80090d:	c1 e0 0f             	shl    $0xf,%eax
  800910:	39 f0                	cmp    %esi,%eax
  800912:	72 c1                	jb     8008d5 <check_bitmap+0x19>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800914:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80091b:	e8 60 fe ff ff       	call   800780 <block_is_free>
  800920:	85 c0                	test   %eax,%eax
  800922:	74 24                	je     800948 <check_bitmap+0x8c>
  800924:	c7 44 24 0c ef 3c 80 	movl   $0x803cef,0xc(%esp)
  80092b:	00 
  80092c:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  800933:	00 
  800934:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  80093b:	00 
  80093c:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  800943:	e8 7c 14 00 00       	call   801dc4 <_panic>
	assert(!block_is_free(1));
  800948:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80094f:	e8 2c fe ff ff       	call   800780 <block_is_free>
  800954:	85 c0                	test   %eax,%eax
  800956:	74 24                	je     80097c <check_bitmap+0xc0>
  800958:	c7 44 24 0c 01 3d 80 	movl   $0x803d01,0xc(%esp)
  80095f:	00 
  800960:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  800967:	00 
  800968:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  80096f:	00 
  800970:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  800977:	e8 48 14 00 00       	call   801dc4 <_panic>

	cprintf("bitmap is good\n");
  80097c:	c7 04 24 13 3d 80 00 	movl   $0x803d13,(%esp)
  800983:	e8 f5 14 00 00       	call   801e7d <cprintf>
}
  800988:	83 c4 10             	add    $0x10,%esp
  80098b:	5b                   	pop    %ebx
  80098c:	5e                   	pop    %esi
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800995:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80099a:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8009a0:	74 1c                	je     8009be <check_super+0x2f>
		panic("bad file system magic number");
  8009a2:	c7 44 24 08 23 3d 80 	movl   $0x803d23,0x8(%esp)
  8009a9:	00 
  8009aa:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8009b1:	00 
  8009b2:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  8009b9:	e8 06 14 00 00       	call   801dc4 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8009be:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8009c5:	76 1c                	jbe    8009e3 <check_super+0x54>
		panic("file system is too large");
  8009c7:	c7 44 24 08 40 3d 80 	movl   $0x803d40,0x8(%esp)
  8009ce:	00 
  8009cf:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  8009d6:	00 
  8009d7:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  8009de:	e8 e1 13 00 00       	call   801dc4 <_panic>

	cprintf("superblock is good\n");
  8009e3:	c7 04 24 59 3d 80 00 	movl   $0x803d59,(%esp)
  8009ea:	e8 8e 14 00 00       	call   801e7d <cprintf>
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	83 ec 28             	sub    $0x28,%esp
  8009f7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009fa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009fd:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a00:	89 c6                	mov    %eax,%esi
  800a02:	89 d3                	mov    %edx,%ebx
  800a04:	89 cf                	mov    %ecx,%edi
  int r;
  uint32_t *ptr;
  void *addr;

  if (filebno < NDIRECT)
    ptr = &f->f_direct[filebno];
  800a06:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
	// LAB 5: Your code here.
  int r;
  uint32_t *ptr;
  void *addr;

  if (filebno < NDIRECT)
  800a0d:	83 fa 09             	cmp    $0x9,%edx
  800a10:	76 6e                	jbe    800a80 <file_block_walk+0x8f>
    ptr = &f->f_direct[filebno];
  else if (filebno < NINDIRECT + NDIRECT) {
  800a12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a17:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800a1d:	77 68                	ja     800a87 <file_block_walk+0x96>
    if (f->f_indirect == 0) {
  800a1f:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  800a26:	75 46                	jne    800a6e <file_block_walk+0x7d>
      if (alloc == 0)
  800a28:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800a2c:	75 04                	jne    800a32 <file_block_walk+0x41>
  800a2e:	b0 f5                	mov    $0xf5,%al
  800a30:	eb 55                	jmp    800a87 <file_block_walk+0x96>
        return -E_NOT_FOUND;
      if ((r = alloc_block()) < 0)
  800a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800a38:	e8 d5 fd ff ff       	call   800812 <alloc_block>
  800a3d:	89 c2                	mov    %eax,%edx
  800a3f:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800a44:	85 d2                	test   %edx,%edx
  800a46:	78 3f                	js     800a87 <file_block_walk+0x96>
        return -E_NO_DISK;
      f->f_indirect = r;
  800a48:	89 96 b0 00 00 00    	mov    %edx,0xb0(%esi)
      memset(diskaddr(r), 0, BLKSIZE);
  800a4e:	89 14 24             	mov    %edx,(%esp)
  800a51:	e8 7d f8 ff ff       	call   8002d3 <diskaddr>
  800a56:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800a5d:	00 
  800a5e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a65:	00 
  800a66:	89 04 24             	mov    %eax,(%esp)
  800a69:	e8 d8 1c 00 00       	call   802746 <memset>
    } else
      alloc = 0;      // we did not allocate a block
    /*
     * set the block number is enough
     */
    ptr = diskaddr(f->f_indirect) + 4 * (filebno - NDIRECT);
  800a6e:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800a74:	89 04 24             	mov    %eax,(%esp)
  800a77:	e8 57 f8 ff ff       	call   8002d3 <diskaddr>
  800a7c:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  } else
    return -E_INVAL;

  *ppdiskbno = ptr;
  800a80:	89 07                	mov    %eax,(%edi)
  800a82:	b8 00 00 00 00       	mov    $0x0,%eax
  return 0;	
}
  800a87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a90:	89 ec                	mov    %ebp,%esp
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	57                   	push   %edi
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 3c             	sub    $0x3c,%esp
  800a9d:	89 c6                	mov    %eax,%esi
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800a9f:	8b b8 80 00 00 00    	mov    0x80(%eax),%edi
  800aa5:	8d 87 fe 1f 00 00    	lea    0x1ffe(%edi),%eax
  800aab:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
  800ab1:	0f 48 f8             	cmovs  %eax,%edi
  800ab4:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ab7:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800abd:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800ac3:	0f 48 d0             	cmovs  %eax,%edx
  800ac6:	c1 fa 0c             	sar    $0xc,%edx
  800ac9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800acc:	39 d7                	cmp    %edx,%edi
  800ace:	76 4c                	jbe    800b1c <file_truncate_blocks+0x88>
  800ad0:	89 d3                	mov    %edx,%ebx
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ad2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad9:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800adc:	89 da                	mov    %ebx,%edx
  800ade:	89 f0                	mov    %esi,%eax
  800ae0:	e8 0c ff ff ff       	call   8009f1 <file_block_walk>
  800ae5:	85 c0                	test   %eax,%eax
  800ae7:	78 1c                	js     800b05 <file_truncate_blocks+0x71>
		return r;
	if (*ptr) {
  800ae9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aec:	8b 00                	mov    (%eax),%eax
  800aee:	85 c0                	test   %eax,%eax
  800af0:	74 23                	je     800b15 <file_truncate_blocks+0x81>
		free_block(*ptr);
  800af2:	89 04 24             	mov    %eax,(%esp)
  800af5:	e8 7d fd ff ff       	call   800877 <free_block>
		*ptr = 0;
  800afa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800afd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800b03:	eb 10                	jmp    800b15 <file_truncate_blocks+0x81>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b09:	c7 04 24 6d 3d 80 00 	movl   $0x803d6d,(%esp)
  800b10:	e8 68 13 00 00       	call   801e7d <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800b15:	83 c3 01             	add    $0x1,%ebx
  800b18:	39 df                	cmp    %ebx,%edi
  800b1a:	77 b6                	ja     800ad2 <file_truncate_blocks+0x3e>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800b1c:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800b20:	77 1c                	ja     800b3e <file_truncate_blocks+0xaa>
  800b22:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	74 12                	je     800b3e <file_truncate_blocks+0xaa>
		free_block(f->f_indirect);
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	e8 43 fd ff ff       	call   800877 <free_block>
		f->f_indirect = 0;
  800b34:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800b3b:	00 00 00 
	}
}
  800b3e:	83 c4 3c             	add    $0x3c,%esp
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 18             	sub    $0x18,%esp
  800b4c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b4f:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b55:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800b58:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  800b5e:	7e 09                	jle    800b69 <file_set_size+0x23>
		file_truncate_blocks(f, newsize);
  800b60:	89 f2                	mov    %esi,%edx
  800b62:	89 d8                	mov    %ebx,%eax
  800b64:	e8 2b ff ff ff       	call   800a94 <file_truncate_blocks>
	f->f_size = newsize;
  800b69:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800b6f:	89 1c 24             	mov    %ebx,(%esp)
  800b72:	e8 32 f9 ff ff       	call   8004a9 <flush_block>
	return 0;
}
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b7f:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b82:	89 ec                	mov    %ebp,%esp
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	57                   	push   %edi
  800b8a:	56                   	push   %esi
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 2c             	sub    $0x2c,%esp
  800b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800b92:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800b98:	05 ff 0f 00 00       	add    $0xfff,%eax
  800b9d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800ba2:	7e 59                	jle    800bfd <file_flush+0x77>
  800ba4:	be 00 00 00 00       	mov    $0x0,%esi
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800ba9:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800bac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800bb3:	89 f9                	mov    %edi,%ecx
  800bb5:	89 f2                	mov    %esi,%edx
  800bb7:	89 d8                	mov    %ebx,%eax
  800bb9:	e8 33 fe ff ff       	call   8009f1 <file_block_walk>
  800bbe:	85 c0                	test   %eax,%eax
  800bc0:	78 1d                	js     800bdf <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  800bc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	74 16                	je     800bdf <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  800bc9:	8b 00                	mov    (%eax),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800bcb:	85 c0                	test   %eax,%eax
  800bcd:	74 10                	je     800bdf <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
  800bcf:	89 04 24             	mov    %eax,(%esp)
  800bd2:	e8 fc f6 ff ff       	call   8002d3 <diskaddr>
  800bd7:	89 04 24             	mov    %eax,(%esp)
  800bda:	e8 ca f8 ff ff       	call   8004a9 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800bdf:	83 c6 01             	add    $0x1,%esi
  800be2:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800be8:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  800bee:	05 ff 0f 00 00       	add    $0xfff,%eax
  800bf3:	0f 48 c2             	cmovs  %edx,%eax
  800bf6:	c1 f8 0c             	sar    $0xc,%eax
  800bf9:	39 f0                	cmp    %esi,%eax
  800bfb:	7f af                	jg     800bac <file_flush+0x26>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800bfd:	89 1c 24             	mov    %ebx,(%esp)
  800c00:	e8 a4 f8 ff ff       	call   8004a9 <flush_block>
	if (f->f_indirect)
  800c05:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	74 10                	je     800c1f <file_flush+0x99>
		flush_block(diskaddr(f->f_indirect));
  800c0f:	89 04 24             	mov    %eax,(%esp)
  800c12:	e8 bc f6 ff ff       	call   8002d3 <diskaddr>
  800c17:	89 04 24             	mov    %eax,(%esp)
  800c1a:	e8 8a f8 ff ff       	call   8004a9 <flush_block>
}
  800c1f:	83 c4 2c             	add    $0x2c,%esp
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 28             	sub    $0x28,%esp
	// LAB 5: Your code here.
	int r;
  uint32_t *ptr;

  if ((r = file_block_walk(f, filebno, &ptr, 1)) != 0)
  800c2d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800c30:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c37:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3d:	e8 af fd ff ff       	call   8009f1 <file_block_walk>
  800c42:	89 c2                	mov    %eax,%edx
  800c44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800c49:	85 d2                	test   %edx,%edx
  800c4b:	75 54                	jne    800ca1 <file_get_block+0x7a>
    return -E_INVAL;
  if (*ptr == 0) {
  800c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c50:	83 38 00             	cmpl   $0x0,(%eax)
  800c53:	75 35                	jne    800c8a <file_get_block+0x63>
    if ((r = alloc_block()) < 0)
  800c55:	e8 b8 fb ff ff       	call   800812 <alloc_block>
  800c5a:	89 c2                	mov    %eax,%edx
  800c5c:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800c61:	85 d2                	test   %edx,%edx
  800c63:	78 3c                	js     800ca1 <file_get_block+0x7a>
      return -E_NO_DISK;
    *ptr = r;
  800c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c68:	89 10                	mov    %edx,(%eax)
    memset(diskaddr(r), 0, BLKSIZE);
  800c6a:	89 14 24             	mov    %edx,(%esp)
  800c6d:	e8 61 f6 ff ff       	call   8002d3 <diskaddr>
  800c72:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c79:	00 
  800c7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c81:	00 
  800c82:	89 04 24             	mov    %eax,(%esp)
  800c85:	e8 bc 1a 00 00       	call   802746 <memset>
//    flush_block(diskaddr(r));
  }
  *blk = diskaddr(*ptr);
  800c8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8d:	8b 00                	mov    (%eax),%eax
  800c8f:	89 04 24             	mov    %eax,(%esp)
  800c92:	e8 3c f6 ff ff       	call   8002d3 <diskaddr>
  800c97:	8b 55 10             	mov    0x10(%ebp),%edx
  800c9a:	89 02                	mov    %eax,(%edx)
  800c9c:	b8 00 00 00 00       	mov    $0x0,%eax
  return 0;
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800caf:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  800cb5:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800cbb:	e8 fe fa ff ff       	call   8007be <skip_slash>
  800cc0:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	f = &super->s_root;
  800cc6:	a1 08 a0 80 00       	mov    0x80a008,%eax
	dir = 0;
	name[0] = 0;
  800ccb:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800cd2:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800cd9:	74 0c                	je     800ce7 <walk_path+0x44>
		*pdir = 0;
  800cdb:	8b 95 40 ff ff ff    	mov    -0xc0(%ebp),%edx
  800ce1:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  800ce7:	83 c0 08             	add    $0x8,%eax
  800cea:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  800cf0:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800cf6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  800cfc:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  800d01:	e9 a1 01 00 00       	jmp    800ea7 <walk_path+0x204>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800d06:	83 c6 01             	add    $0x1,%esi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800d09:	0f b6 06             	movzbl (%esi),%eax
  800d0c:	3c 2f                	cmp    $0x2f,%al
  800d0e:	74 04                	je     800d14 <walk_path+0x71>
  800d10:	84 c0                	test   %al,%al
  800d12:	75 f2                	jne    800d06 <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  800d14:	89 f3                	mov    %esi,%ebx
  800d16:	2b 9d 48 ff ff ff    	sub    -0xb8(%ebp),%ebx
  800d1c:	83 fb 7f             	cmp    $0x7f,%ebx
  800d1f:	7e 0a                	jle    800d2b <walk_path+0x88>
  800d21:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d26:	e9 c3 01 00 00       	jmp    800eee <walk_path+0x24b>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800d2b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d2f:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  800d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d39:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800d3f:	89 14 24             	mov    %edx,(%esp)
  800d42:	e8 5e 1a 00 00       	call   8027a5 <memmove>
		name[path - p] = '\0';
  800d47:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800d4e:	00 
		path = skip_slash(path);
  800d4f:	89 f0                	mov    %esi,%eax
  800d51:	e8 68 fa ff ff       	call   8007be <skip_slash>
  800d56:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800d5c:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800d62:	83 b9 84 00 00 00 01 	cmpl   $0x1,0x84(%ecx)
  800d69:	0f 85 7a 01 00 00    	jne    800ee9 <walk_path+0x246>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800d6f:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  800d75:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800d7a:	74 24                	je     800da0 <walk_path+0xfd>
  800d7c:	c7 44 24 0c 8a 3d 80 	movl   $0x803d8a,0xc(%esp)
  800d83:	00 
  800d84:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  800d8b:	00 
  800d8c:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  800d93:	00 
  800d94:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  800d9b:	e8 24 10 00 00       	call   801dc4 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800da0:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800da6:	85 c0                	test   %eax,%eax
  800da8:	0f 48 c2             	cmovs  %edx,%eax
  800dab:	c1 f8 0c             	sar    $0xc,%eax
  800dae:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  800db4:	85 c0                	test   %eax,%eax
  800db6:	0f 84 8a 00 00 00    	je     800e46 <walk_path+0x1a3>
  800dbc:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800dc3:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800dc6:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800dcc:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800dd2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dd6:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800ddc:	89 54 24 04          	mov    %edx,0x4(%esp)
  800de0:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800de6:	89 0c 24             	mov    %ecx,(%esp)
  800de9:	e8 39 fe ff ff       	call   800c27 <file_get_block>
  800dee:	85 c0                	test   %eax,%eax
  800df0:	78 4b                	js     800e3d <walk_path+0x19a>
  800df2:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  800df8:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  800dfe:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e08:	89 1c 24             	mov    %ebx,(%esp)
  800e0b:	e8 65 18 00 00       	call   802675 <strcmp>
  800e10:	85 c0                	test   %eax,%eax
  800e12:	0f 84 83 00 00 00    	je     800e9b <walk_path+0x1f8>
  800e18:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800e1e:	3b 9d 54 ff ff ff    	cmp    -0xac(%ebp),%ebx
  800e24:	75 de                	jne    800e04 <walk_path+0x161>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800e26:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800e2d:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800e33:	39 95 44 ff ff ff    	cmp    %edx,-0xbc(%ebp)
  800e39:	77 91                	ja     800dcc <walk_path+0x129>
  800e3b:	eb 09                	jmp    800e46 <walk_path+0x1a3>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800e3d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800e40:	0f 85 a8 00 00 00    	jne    800eee <walk_path+0x24b>
  800e46:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  800e4c:	80 39 00             	cmpb   $0x0,(%ecx)
  800e4f:	90                   	nop
  800e50:	0f 85 93 00 00 00    	jne    800ee9 <walk_path+0x246>
				if (pdir)
  800e56:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800e5d:	74 0e                	je     800e6d <walk_path+0x1ca>
					*pdir = dir;
  800e5f:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800e65:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800e6b:	89 10                	mov    %edx,(%eax)
				if (lastelem)
  800e6d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800e71:	74 15                	je     800e88 <walk_path+0x1e5>
					strcpy(lastelem, name);
  800e73:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800e79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e80:	89 0c 24             	mov    %ecx,(%esp)
  800e83:	e8 32 17 00 00       	call   8025ba <strcpy>
				*pf = 0;
  800e88:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800e8e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800e94:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800e99:	eb 53                	jmp    800eee <walk_path+0x24b>
  800e9b:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800ea1:	89 9d 4c ff ff ff    	mov    %ebx,-0xb4(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800ea7:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  800ead:	0f b6 01             	movzbl (%ecx),%eax
  800eb0:	84 c0                	test   %al,%al
  800eb2:	74 0f                	je     800ec3 <walk_path+0x220>
  800eb4:	89 ce                	mov    %ecx,%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800eb6:	3c 2f                	cmp    $0x2f,%al
  800eb8:	0f 85 48 fe ff ff    	jne    800d06 <walk_path+0x63>
  800ebe:	e9 51 fe ff ff       	jmp    800d14 <walk_path+0x71>
			}
			return r;
		}
	}

	if (pdir)
  800ec3:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  800eca:	74 08                	je     800ed4 <walk_path+0x231>
		*pdir = dir;
  800ecc:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800ed2:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800ed4:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800eda:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
  800ee0:	89 0a                	mov    %ecx,(%edx)
  800ee2:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  800ee7:	eb 05                	jmp    800eee <walk_path+0x24b>
  800ee9:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  800eee:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5f                   	pop    %edi
  800ef7:	5d                   	pop    %ebp
  800ef8:	c3                   	ret    

00800ef9 <file_remove>:
}

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  800eff:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800f02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f09:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f11:	e8 8d fd ff ff       	call   800ca3 <walk_path>
  800f16:	85 c0                	test   %eax,%eax
  800f18:	78 30                	js     800f4a <file_remove+0x51>
		return r;

	file_truncate_blocks(f, 0);
  800f1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f22:	e8 6d fb ff ff       	call   800a94 <file_truncate_blocks>
	f->f_name[0] = '\0';
  800f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f2a:	c6 00 00             	movb   $0x0,(%eax)
	f->f_size = 0;
  800f2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f30:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  800f37:	00 00 00 
	flush_block(f);
  800f3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f3d:	89 04 24             	mov    %eax,(%esp)
  800f40:	e8 64 f5 ff ff       	call   8004a9 <flush_block>
  800f45:	b8 00 00 00 00       	mov    $0x0,%eax

	return 0;
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	e8 3a fd ff ff       	call   800ca3 <walk_path>
}
  800f69:	c9                   	leave  
  800f6a:	c3                   	ret    

00800f6b <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	57                   	push   %edi
  800f6f:	56                   	push   %esi
  800f70:	53                   	push   %ebx
  800f71:	83 ec 3c             	sub    $0x3c,%esp
  800f74:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800f77:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800f7a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	01 d8                	add    %ebx,%eax
  800f82:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800f85:	8b 55 08             	mov    0x8(%ebp),%edx
  800f88:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800f8e:	77 0d                	ja     800f9d <file_write+0x32>
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800f90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800f93:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  800f96:	72 1d                	jb     800fb5 <file_write+0x4a>
  800f98:	e9 85 00 00 00       	jmp    801022 <file_write+0xb7>
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
  800f9d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800fa0:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa7:	89 04 24             	mov    %eax,(%esp)
  800faa:	e8 97 fb ff ff       	call   800b46 <file_set_size>
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	79 dd                	jns    800f90 <file_write+0x25>
  800fb3:	eb 70                	jmp    801025 <file_write+0xba>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800fb5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800fb8:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fbc:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800fc2:	85 db                	test   %ebx,%ebx
  800fc4:	0f 49 c3             	cmovns %ebx,%eax
  800fc7:	c1 f8 0c             	sar    $0xc,%eax
  800fca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	89 04 24             	mov    %eax,(%esp)
  800fd4:	e8 4e fc ff ff       	call   800c27 <file_get_block>
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 48                	js     801025 <file_write+0xba>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800fdd:	89 da                	mov    %ebx,%edx
  800fdf:	c1 fa 1f             	sar    $0x1f,%edx
  800fe2:	c1 ea 14             	shr    $0x14,%edx
  800fe5:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800fe8:	25 ff 0f 00 00       	and    $0xfff,%eax
  800fed:	29 d0                	sub    %edx,%eax
  800fef:	be 00 10 00 00       	mov    $0x1000,%esi
  800ff4:	29 c6                	sub    %eax,%esi
  800ff6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800ff9:	2b 55 d0             	sub    -0x30(%ebp),%edx
  800ffc:	39 d6                	cmp    %edx,%esi
  800ffe:	0f 47 f2             	cmova  %edx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  801001:	89 74 24 08          	mov    %esi,0x8(%esp)
  801005:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801009:	03 45 e4             	add    -0x1c(%ebp),%eax
  80100c:	89 04 24             	mov    %eax,(%esp)
  80100f:	e8 91 17 00 00       	call   8027a5 <memmove>
		pos += bn;
  801014:	01 f3                	add    %esi,%ebx
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  801016:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801019:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  80101c:	76 04                	jbe    801022 <file_write+0xb7>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
  80101e:	01 f7                	add    %esi,%edi
  801020:	eb 93                	jmp    800fb5 <file_write+0x4a>
	}

	return count;
  801022:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801025:	83 c4 3c             	add    $0x3c,%esp
  801028:	5b                   	pop    %ebx
  801029:	5e                   	pop    %esi
  80102a:	5f                   	pop    %edi
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
  801030:	57                   	push   %edi
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
  801033:	83 ec 3c             	sub    $0x3c,%esp
  801036:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801039:	8b 55 10             	mov    0x10(%ebp),%edx
  80103c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  80103f:	8b 45 08             	mov    0x8(%ebp),%eax
  801042:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
  801048:	b8 00 00 00 00       	mov    $0x0,%eax
  80104d:	39 d9                	cmp    %ebx,%ecx
  80104f:	0f 8e 88 00 00 00    	jle    8010dd <file_read+0xb0>
		return 0;

	count = MIN(count, f->f_size - offset);
  801055:	29 d9                	sub    %ebx,%ecx
  801057:	39 d1                	cmp    %edx,%ecx
  801059:	0f 46 d1             	cmovbe %ecx,%edx
  80105c:	89 55 cc             	mov    %edx,-0x34(%ebp)

	for (pos = offset; pos < offset + count; ) {
  80105f:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801062:	89 d0                	mov    %edx,%eax
  801064:	01 d8                	add    %ebx,%eax
  801066:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801069:	39 d8                	cmp    %ebx,%eax
  80106b:	76 6d                	jbe    8010da <file_read+0xad>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  80106d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801070:	89 44 24 08          	mov    %eax,0x8(%esp)
  801074:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80107a:	85 db                	test   %ebx,%ebx
  80107c:	0f 49 c3             	cmovns %ebx,%eax
  80107f:	c1 f8 0c             	sar    $0xc,%eax
  801082:	89 44 24 04          	mov    %eax,0x4(%esp)
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	89 04 24             	mov    %eax,(%esp)
  80108c:	e8 96 fb ff ff       	call   800c27 <file_get_block>
  801091:	85 c0                	test   %eax,%eax
  801093:	78 48                	js     8010dd <file_read+0xb0>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  801095:	89 da                	mov    %ebx,%edx
  801097:	c1 fa 1f             	sar    $0x1f,%edx
  80109a:	c1 ea 14             	shr    $0x14,%edx
  80109d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  8010a0:	25 ff 0f 00 00       	and    $0xfff,%eax
  8010a5:	29 d0                	sub    %edx,%eax
  8010a7:	be 00 10 00 00       	mov    $0x1000,%esi
  8010ac:	29 c6                	sub    %eax,%esi
  8010ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8010b1:	2b 55 d0             	sub    -0x30(%ebp),%edx
  8010b4:	39 d6                	cmp    %edx,%esi
  8010b6:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  8010b9:	89 74 24 08          	mov    %esi,0x8(%esp)
  8010bd:	03 45 e4             	add    -0x1c(%ebp),%eax
  8010c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010c4:	89 3c 24             	mov    %edi,(%esp)
  8010c7:	e8 d9 16 00 00       	call   8027a5 <memmove>
		pos += bn;
  8010cc:	01 f3                	add    %esi,%ebx
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  8010ce:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8010d1:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  8010d4:	76 04                	jbe    8010da <file_read+0xad>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
  8010d6:	01 f7                	add    %esi,%edi
  8010d8:	eb 93                	jmp    80106d <file_read+0x40>
	}

	return count;
  8010da:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
  8010dd:	83 c4 3c             	add    $0x3c,%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8010f1:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  8010f7:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  8010fd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801103:	89 04 24             	mov    %eax,(%esp)
  801106:	8b 45 08             	mov    0x8(%ebp),%eax
  801109:	e8 95 fb ff ff       	call   800ca3 <walk_path>
  80110e:	85 c0                	test   %eax,%eax
  801110:	75 0a                	jne    80111c <file_create+0x37>
  801112:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801117:	e9 ee 00 00 00       	jmp    80120a <file_create+0x125>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80111c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80111f:	90                   	nop
  801120:	0f 85 e4 00 00 00    	jne    80120a <file_create+0x125>
  801126:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  80112c:	85 f6                	test   %esi,%esi
  80112e:	0f 84 d6 00 00 00    	je     80120a <file_create+0x125>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801134:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  80113a:	a9 ff 0f 00 00       	test   $0xfff,%eax
  80113f:	74 24                	je     801165 <file_create+0x80>
  801141:	c7 44 24 0c 8a 3d 80 	movl   $0x803d8a,0xc(%esp)
  801148:	00 
  801149:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801150:	00 
  801151:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  801158:	00 
  801159:	c7 04 24 d3 3c 80 00 	movl   $0x803cd3,(%esp)
  801160:	e8 5f 0c 00 00       	call   801dc4 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801165:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  80116b:	85 c0                	test   %eax,%eax
  80116d:	0f 48 c2             	cmovs  %edx,%eax
  801170:	c1 f8 0c             	sar    $0xc,%eax
  801173:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  801179:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117e:	85 c0                	test   %eax,%eax
  801180:	74 56                	je     8011d8 <file_create+0xf3>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  801182:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  801188:	89 7c 24 08          	mov    %edi,0x8(%esp)
  80118c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801190:	89 34 24             	mov    %esi,(%esp)
  801193:	e8 8f fa ff ff       	call   800c27 <file_get_block>
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 6e                	js     80120a <file_create+0x125>
			return r;
		f = (struct File*) blk;
  80119c:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  8011a2:	89 ca                	mov    %ecx,%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8011a4:	80 39 00             	cmpb   $0x0,(%ecx)
  8011a7:	74 13                	je     8011bc <file_create+0xd7>
  8011a9:	8d 81 00 01 00 00    	lea    0x100(%ecx),%eax
// --------------------------------------------------------------

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
  8011af:	81 c1 00 10 00 00    	add    $0x1000,%ecx
  8011b5:	89 c2                	mov    %eax,%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  8011b7:	80 38 00             	cmpb   $0x0,(%eax)
  8011ba:	75 08                	jne    8011c4 <file_create+0xdf>
				*file = &f[j];
  8011bc:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  8011c2:	eb 51                	jmp    801215 <file_create+0x130>
  8011c4:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8011c9:	39 c8                	cmp    %ecx,%eax
  8011cb:	75 e8                	jne    8011b5 <file_create+0xd0>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8011cd:	83 c3 01             	add    $0x1,%ebx
  8011d0:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  8011d6:	77 b0                	ja     801188 <file_create+0xa3>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8011d8:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  8011df:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8011e2:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8011e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011f0:	89 34 24             	mov    %esi,(%esp)
  8011f3:	e8 2f fa ff ff       	call   800c27 <file_get_block>
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	78 0e                	js     80120a <file_create+0x125>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  8011fc:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801202:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801208:	eb 0b                	jmp    801215 <file_create+0x130>
		return r;
	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  80120a:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801210:	5b                   	pop    %ebx
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;
	strcpy(f->f_name, name);
  801215:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80121b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121f:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801225:	89 04 24             	mov    %eax,(%esp)
  801228:	e8 8d 13 00 00       	call   8025ba <strcpy>
	*pf = f;
  80122d:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  801233:	8b 45 0c             	mov    0xc(%ebp),%eax
  801236:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801238:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  80123e:	89 04 24             	mov    %eax,(%esp)
  801241:	e8 40 f9 ff ff       	call   800b86 <file_flush>
  801246:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80124b:	eb bd                	jmp    80120a <file_create+0x125>

0080124d <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  801253:	e8 cc ef ff ff       	call   800224 <ide_probe_disk1>
  801258:	85 c0                	test   %eax,%eax
  80125a:	74 0e                	je     80126a <fs_init+0x1d>
		ide_set_disk(1);
  80125c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801263:	e8 8b ef ff ff       	call   8001f3 <ide_set_disk>
  801268:	eb 0c                	jmp    801276 <fs_init+0x29>
	else
		ide_set_disk(0);
  80126a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801271:	e8 7d ef ff ff       	call   8001f3 <ide_set_disk>

	bc_init();
  801276:	e8 e8 f4 ff ff       	call   800763 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  80127b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801282:	e8 4c f0 ff ff       	call   8002d3 <diskaddr>
  801287:	a3 08 a0 80 00       	mov    %eax,0x80a008
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80128c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801293:	e8 3b f0 ff ff       	call   8002d3 <diskaddr>
  801298:	a3 04 a0 80 00       	mov    %eax,0x80a004

	check_super();
  80129d:	e8 ed f6 ff ff       	call   80098f <check_super>
	check_bitmap();
  8012a2:	e8 15 f6 ff ff       	call   8008bc <check_bitmap>
}
  8012a7:	c9                   	leave  
  8012a8:	c3                   	ret    
  8012a9:	00 00                	add    %al,(%eax)
  8012ab:	00 00                	add    %al,(%eax)
  8012ad:	00 00                	add    %al,(%eax)
	...

008012b0 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	ba 20 50 80 00       	mov    $0x805020,%edx
  8012b8:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
  8012c2:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8012c4:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8012c7:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8012cd:	83 c0 01             	add    $0x1,%eax
  8012d0:	83 c2 10             	add    $0x10,%edx
  8012d3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012d8:	75 e8                	jne    8012c2 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <serve_sync>:
}

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8012e2:	e8 e9 f4 ff ff       	call   8007d0 <fs_sync>
	return 0;
}
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    

008012ee <serve_remove>:
}

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
  8012f1:	53                   	push   %ebx
  8012f2:	81 ec 14 04 00 00    	sub    $0x414,%esp

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8012f8:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  8012ff:	00 
  801300:	8b 45 0c             	mov    0xc(%ebp),%eax
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	8d 9d f8 fb ff ff    	lea    -0x408(%ebp),%ebx
  80130d:	89 1c 24             	mov    %ebx,(%esp)
  801310:	e8 90 14 00 00       	call   8027a5 <memmove>
	path[MAXPATHLEN-1] = 0;
  801315:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Delete the specified file
	return file_remove(path);
  801319:	89 1c 24             	mov    %ebx,(%esp)
  80131c:	e8 d8 fb ff ff       	call   800ef9 <file_remove>
}
  801321:	81 c4 14 04 00 00    	add    $0x414,%esp
  801327:	5b                   	pop    %ebx
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <openfile_lookup>:
}

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	83 ec 18             	sub    $0x18,%esp
  801330:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801333:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801336:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801339:	89 f3                	mov    %esi,%ebx
  80133b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801341:	c1 e3 04             	shl    $0x4,%ebx
  801344:	81 c3 20 50 80 00    	add    $0x805020,%ebx
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  80134a:	8b 43 0c             	mov    0xc(%ebx),%eax
  80134d:	89 04 24             	mov    %eax,(%esp)
  801350:	e8 cb 24 00 00       	call   803820 <pageref>
  801355:	83 f8 01             	cmp    $0x1,%eax
  801358:	74 10                	je     80136a <openfile_lookup+0x40>
  80135a:	39 33                	cmp    %esi,(%ebx)
  80135c:	75 0c                	jne    80136a <openfile_lookup+0x40>
		return -E_INVAL;
	*po = o;
  80135e:	8b 45 10             	mov    0x10(%ebp),%eax
  801361:	89 18                	mov    %ebx,(%eax)
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801368:	eb 05                	jmp    80136f <openfile_lookup+0x45>
  80136a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80136f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801372:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801375:	89 ec                	mov    %ebp,%esp
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801379:	55                   	push   %ebp
  80137a:	89 e5                	mov    %esp,%ebp
  80137c:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80137f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801382:	89 44 24 08          	mov    %eax,0x8(%esp)
  801386:	8b 45 0c             	mov    0xc(%ebp),%eax
  801389:	8b 00                	mov    (%eax),%eax
  80138b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138f:	8b 45 08             	mov    0x8(%ebp),%eax
  801392:	89 04 24             	mov    %eax,(%esp)
  801395:	e8 90 ff ff ff       	call   80132a <openfile_lookup>
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 13                	js     8013b1 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  80139e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a1:	8b 40 04             	mov    0x4(%eax),%eax
  8013a4:	89 04 24             	mov    %eax,(%esp)
  8013a7:	e8 da f7 ff ff       	call   800b86 <file_flush>
  8013ac:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8013b1:	c9                   	leave  
  8013b2:	c3                   	ret    

008013b3 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	53                   	push   %ebx
  8013b7:	83 ec 24             	sub    $0x24,%esp
  8013ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8013bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013c4:	8b 03                	mov    (%ebx),%eax
  8013c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cd:	89 04 24             	mov    %eax,(%esp)
  8013d0:	e8 55 ff ff ff       	call   80132a <openfile_lookup>
  8013d5:	85 c0                	test   %eax,%eax
  8013d7:	78 3f                	js     801418 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8013d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013dc:	8b 40 04             	mov    0x4(%eax),%eax
  8013df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e3:	89 1c 24             	mov    %ebx,(%esp)
  8013e6:	e8 cf 11 00 00       	call   8025ba <strcpy>
	ret->ret_size = o->o_file->f_size;
  8013eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ee:	8b 50 04             	mov    0x4(%eax),%edx
  8013f1:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8013f7:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8013fd:	8b 40 04             	mov    0x4(%eax),%eax
  801400:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801407:	0f 94 c0             	sete   %al
  80140a:	0f b6 c0             	movzbl %al,%eax
  80140d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801413:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801418:	83 c4 24             	add    $0x24,%esp
  80141b:	5b                   	pop    %ebx
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 24             	sub    $0x24,%esp
  801425:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
  struct OpenFile *o;
  int r;

  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801428:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80142f:	8b 03                	mov    (%ebx),%eax
  801431:	89 44 24 04          	mov    %eax,0x4(%esp)
  801435:	8b 45 08             	mov    0x8(%ebp),%eax
  801438:	89 04 24             	mov    %eax,(%esp)
  80143b:	e8 ea fe ff ff       	call   80132a <openfile_lookup>
  801440:	85 c0                	test   %eax,%eax
  801442:	78 40                	js     801484 <serve_write+0x66>
    return r;
  r = file_write(o->o_file, req->req_buf,
      MIN(req->req_n, PGSIZE), o->o_fd->fd_offset);
  801444:	8b 45 f4             	mov    -0xc(%ebp),%eax
  struct OpenFile *o;
  int r;

  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
    return r;
  r = file_write(o->o_file, req->req_buf,
  801447:	8b 50 0c             	mov    0xc(%eax),%edx
  80144a:	8b 52 04             	mov    0x4(%edx),%edx
  80144d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801451:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  801458:	ba 00 10 00 00       	mov    $0x1000,%edx
  80145d:	0f 46 53 04          	cmovbe 0x4(%ebx),%edx
  801461:	89 54 24 08          	mov    %edx,0x8(%esp)
  801465:	83 c3 08             	add    $0x8,%ebx
  801468:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80146c:	8b 40 04             	mov    0x4(%eax),%eax
  80146f:	89 04 24             	mov    %eax,(%esp)
  801472:	e8 f4 fa ff ff       	call   800f6b <file_write>
      MIN(req->req_n, PGSIZE), o->o_fd->fd_offset);
  if (r > 0)
  801477:	85 c0                	test   %eax,%eax
  801479:	7e 09                	jle    801484 <serve_write+0x66>
    o->o_fd->fd_offset += r;
  80147b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80147e:	8b 52 0c             	mov    0xc(%edx),%edx
  801481:	01 42 04             	add    %eax,0x4(%edx)
  return r;	
}
  801484:	83 c4 24             	add    $0x24,%esp
  801487:	5b                   	pop    %ebx
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	56                   	push   %esi
  80148e:	53                   	push   %ebx
  80148f:	83 ec 20             	sub    $0x20,%esp
  801492:	8b 75 0c             	mov    0xc(%ebp),%esi
	// so filling in ret will overwrite req.
	//
	// Hint: Use file_read.
	// Hint: The seek position is stored in the struct Fd.
	// LAB 5: Your code here 
  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  801495:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801498:	89 44 24 08          	mov    %eax,0x8(%esp)
  80149c:	8b 06                	mov    (%esi),%eax
  80149e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	e8 7d fe ff ff       	call   80132a <openfile_lookup>
  8014ad:	89 c3                	mov    %eax,%ebx
  8014af:	85 c0                	test   %eax,%eax
  8014b1:	79 0e                	jns    8014c1 <serve_read+0x37>
    cprintf("serve_read: failed to lookup open fileid\n");
  8014b3:	c7 04 24 a8 3d 80 00 	movl   $0x803da8,(%esp)
  8014ba:	e8 be 09 00 00       	call   801e7d <cprintf>
    return r;
  8014bf:	eb 3b                	jmp    8014fc <serve_read+0x72>
  }
  nbytes = MIN(req->req_n, PGSIZE);
  if ((nbytes = file_read(o->o_file, (void *)ret->ret_buf,
      nbytes, o->o_fd->fd_offset)) >= 0)
  8014c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
    cprintf("serve_read: failed to lookup open fileid\n");
    return r;
  }
  nbytes = MIN(req->req_n, PGSIZE);
  if ((nbytes = file_read(o->o_file, (void *)ret->ret_buf,
  8014c4:	8b 50 0c             	mov    0xc(%eax),%edx
  8014c7:	8b 52 04             	mov    0x4(%edx),%edx
  8014ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014ce:	81 7e 04 00 10 00 00 	cmpl   $0x1000,0x4(%esi)
  8014d5:	ba 00 10 00 00       	mov    $0x1000,%edx
  8014da:	0f 46 56 04          	cmovbe 0x4(%esi),%edx
  8014de:	89 54 24 08          	mov    %edx,0x8(%esp)
  8014e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e6:	8b 40 04             	mov    0x4(%eax),%eax
  8014e9:	89 04 24             	mov    %eax,(%esp)
  8014ec:	e8 3c fb ff ff       	call   80102d <file_read>
  8014f1:	89 c3                	mov    %eax,%ebx
      nbytes, o->o_fd->fd_offset)) >= 0)
    o->o_fd->fd_offset += nbytes;
  8014f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f9:	01 58 04             	add    %ebx,0x4(%eax)
  return nbytes;
}
  8014fc:	89 d8                	mov    %ebx,%eax
  8014fe:	83 c4 20             	add    $0x20,%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5d                   	pop    %ebp
  801504:	c3                   	ret    

00801505 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	53                   	push   %ebx
  801509:	83 ec 24             	sub    $0x24,%esp
  80150c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	89 44 24 08          	mov    %eax,0x8(%esp)
  801516:	8b 03                	mov    (%ebx),%eax
  801518:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151c:	8b 45 08             	mov    0x8(%ebp),%eax
  80151f:	89 04 24             	mov    %eax,(%esp)
  801522:	e8 03 fe ff ff       	call   80132a <openfile_lookup>
  801527:	85 c0                	test   %eax,%eax
  801529:	78 15                	js     801540 <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  80152b:	8b 43 04             	mov    0x4(%ebx),%eax
  80152e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801532:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801535:	8b 40 04             	mov    0x4(%eax),%eax
  801538:	89 04 24             	mov    %eax,(%esp)
  80153b:	e8 06 f6 ff ff       	call   800b46 <file_set_size>
}
  801540:	83 c4 24             	add    $0x24,%esp
  801543:	5b                   	pop    %ebx
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    

00801546 <openfile_alloc>:
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	83 ec 28             	sub    $0x28,%esp
  80154c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80154f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801552:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801555:	8b 7d 08             	mov    0x8(%ebp),%edi
  801558:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  80155d:	be 2c 50 80 00       	mov    $0x80502c,%esi
  801562:	89 d8                	mov    %ebx,%eax
  801564:	c1 e0 04             	shl    $0x4,%eax
  801567:	8b 04 30             	mov    (%eax,%esi,1),%eax
  80156a:	89 04 24             	mov    %eax,(%esp)
  80156d:	e8 ae 22 00 00       	call   803820 <pageref>
  801572:	85 c0                	test   %eax,%eax
  801574:	74 0c                	je     801582 <openfile_alloc+0x3c>
  801576:	83 f8 01             	cmp    $0x1,%eax
  801579:	75 67                	jne    8015e2 <openfile_alloc+0x9c>
  80157b:	90                   	nop
  80157c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801580:	eb 27                	jmp    8015a9 <openfile_alloc+0x63>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801582:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801589:	00 
  80158a:	89 d8                	mov    %ebx,%eax
  80158c:	c1 e0 04             	shl    $0x4,%eax
  80158f:	8b 80 2c 50 80 00    	mov    0x80502c(%eax),%eax
  801595:	89 44 24 04          	mov    %eax,0x4(%esp)
  801599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a0:	e8 05 16 00 00       	call   802baa <sys_page_alloc>
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 4d                	js     8015f6 <openfile_alloc+0xb0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8015a9:	c1 e3 04             	shl    $0x4,%ebx
  8015ac:	81 83 20 50 80 00 00 	addl   $0x400,0x805020(%ebx)
  8015b3:	04 00 00 
			*o = &opentab[i];
  8015b6:	8d 83 20 50 80 00    	lea    0x805020(%ebx),%eax
  8015bc:	89 07                	mov    %eax,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8015be:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8015c5:	00 
  8015c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015cd:	00 
  8015ce:	8b 83 2c 50 80 00    	mov    0x80502c(%ebx),%eax
  8015d4:	89 04 24             	mov    %eax,(%esp)
  8015d7:	e8 6a 11 00 00       	call   802746 <memset>
			return (*o)->o_fileid;
  8015dc:	8b 07                	mov    (%edi),%eax
  8015de:	8b 00                	mov    (%eax),%eax
  8015e0:	eb 14                	jmp    8015f6 <openfile_alloc+0xb0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8015e2:	83 c3 01             	add    $0x1,%ebx
  8015e5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8015eb:	0f 85 71 ff ff ff    	jne    801562 <openfile_alloc+0x1c>
  8015f1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}
  8015f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015f9:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8015fc:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8015ff:	89 ec                	mov    %ebp,%esp
  801601:	5d                   	pop    %ebp
  801602:	c3                   	ret    

00801603 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801603:	55                   	push   %ebp
  801604:	89 e5                	mov    %esp,%ebp
  801606:	53                   	push   %ebx
  801607:	81 ec 24 04 00 00    	sub    $0x424,%esp
  80160d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801610:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801617:	00 
  801618:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80161c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801622:	89 04 24             	mov    %eax,(%esp)
  801625:	e8 7b 11 00 00       	call   8027a5 <memmove>
	path[MAXPATHLEN-1] = 0;
  80162a:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80162e:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801634:	89 04 24             	mov    %eax,(%esp)
  801637:	e8 0a ff ff ff       	call   801546 <openfile_alloc>
  80163c:	85 c0                	test   %eax,%eax
  80163e:	0f 88 ec 00 00 00    	js     801730 <serve_open+0x12d>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801644:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80164b:	74 32                	je     80167f <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  80164d:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801653:	89 44 24 04          	mov    %eax,0x4(%esp)
  801657:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80165d:	89 04 24             	mov    %eax,(%esp)
  801660:	e8 80 fa ff ff       	call   8010e5 <file_create>
  801665:	85 c0                	test   %eax,%eax
  801667:	79 36                	jns    80169f <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801669:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801670:	0f 85 ba 00 00 00    	jne    801730 <serve_open+0x12d>
  801676:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801679:	0f 85 b1 00 00 00    	jne    801730 <serve_open+0x12d>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80167f:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801685:	89 44 24 04          	mov    %eax,0x4(%esp)
  801689:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80168f:	89 04 24             	mov    %eax,(%esp)
  801692:	e8 b5 f8 ff ff       	call   800f4c <file_open>
  801697:	85 c0                	test   %eax,%eax
  801699:	0f 88 91 00 00 00    	js     801730 <serve_open+0x12d>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80169f:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8016a6:	74 1a                	je     8016c2 <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  8016a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016af:	00 
  8016b0:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  8016b6:	89 04 24             	mov    %eax,(%esp)
  8016b9:	e8 88 f4 ff ff       	call   800b46 <file_set_size>
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 6e                	js     801730 <serve_open+0x12d>
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;
  8016c2:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8016c8:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016ce:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8016d1:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016d7:	8b 50 0c             	mov    0xc(%eax),%edx
  8016da:	8b 00                	mov    (%eax),%eax
  8016dc:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8016df:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8016ee:	83 e2 03             	and    $0x3,%edx
  8016f1:	89 50 08             	mov    %edx,0x8(%eax)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8016f4:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8016fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fd:	8b 15 68 90 80 00    	mov    0x809068,%edx
  801703:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801705:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80170b:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801711:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  801714:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  80171a:	8b 50 0c             	mov    0xc(%eax),%edx
  80171d:	8b 45 10             	mov    0x10(%ebp),%eax
  801720:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W;
  801722:	8b 45 14             	mov    0x14(%ebp),%eax
  801725:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
  80172b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801730:	81 c4 24 04 00 00    	add    $0x424,%esp
  801736:	5b                   	pop    %ebx
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	57                   	push   %edi
  80173d:	56                   	push   %esi
  80173e:	53                   	push   %ebx
  80173f:	83 ec 2c             	sub    $0x2c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801742:	8d 5d e0             	lea    -0x20(%ebp),%ebx
  801745:	8d 75 e4             	lea    -0x1c(%ebp),%esi
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  801748:	bf 40 90 80 00       	mov    $0x809040,%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80174d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801754:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801758:	a1 20 90 80 00       	mov    0x809020,%eax
  80175d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801761:	89 34 24             	mov    %esi,(%esp)
  801764:	e8 2a 17 00 00       	call   802e93 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801769:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  80176d:	75 15                	jne    801784 <serve+0x4b>
			cprintf("Invalid request from %08x: no argument page\n",
  80176f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	c7 04 24 d4 3d 80 00 	movl   $0x803dd4,(%esp)
  80177d:	e8 fb 06 00 00       	call   801e7d <cprintf>
				whom);
			continue; // just leave it hanging...
  801782:	eb c9                	jmp    80174d <serve+0x14>
		}

		pg = NULL;
  801784:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  80178b:	83 f8 01             	cmp    $0x1,%eax
  80178e:	75 21                	jne    8017b1 <serve+0x78>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801790:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801794:	8d 45 dc             	lea    -0x24(%ebp),%eax
  801797:	89 44 24 08          	mov    %eax,0x8(%esp)
  80179b:	a1 20 90 80 00       	mov    0x809020,%eax
  8017a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017a7:	89 04 24             	mov    %eax,(%esp)
  8017aa:	e8 54 fe ff ff       	call   801603 <serve_open>
  8017af:	eb 40                	jmp    8017f1 <serve+0xb8>
		} else if (req < NHANDLERS && handlers[req]) {
  8017b1:	83 f8 08             	cmp    $0x8,%eax
  8017b4:	77 1f                	ja     8017d5 <serve+0x9c>
  8017b6:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8017b9:	85 d2                	test   %edx,%edx
  8017bb:	90                   	nop
  8017bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017c0:	74 13                	je     8017d5 <serve+0x9c>
			r = handlers[req](whom, fsreq);
  8017c2:	a1 20 90 80 00       	mov    0x809020,%eax
  8017c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ce:	89 04 24             	mov    %eax,(%esp)
  8017d1:	ff d2                	call   *%edx
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  8017d3:	eb 1c                	jmp    8017f1 <serve+0xb8>
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  8017d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e0:	c7 04 24 04 3e 80 00 	movl   $0x803e04,(%esp)
  8017e7:	e8 91 06 00 00       	call   801e7d <cprintf>
  8017ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  8017f1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8017f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8017f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8017fb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8017ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801806:	89 04 24             	mov    %eax,(%esp)
  801809:	e8 16 16 00 00       	call   802e24 <ipc_send>
		sys_page_unmap(0, fsreq);
  80180e:	a1 20 90 80 00       	mov    0x809020,%eax
  801813:	89 44 24 04          	mov    %eax,0x4(%esp)
  801817:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80181e:	e8 16 13 00 00       	call   802b39 <sys_page_unmap>
  801823:	e9 25 ff ff ff       	jmp    80174d <serve+0x14>

00801828 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80182e:	c7 05 64 90 80 00 27 	movl   $0x803e27,0x809064
  801835:	3e 80 00 
	cprintf("FS is running\n");
  801838:	c7 04 24 2a 3e 80 00 	movl   $0x803e2a,(%esp)
  80183f:	e8 39 06 00 00       	call   801e7d <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801844:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801849:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80184e:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801850:	c7 04 24 39 3e 80 00 	movl   $0x803e39,(%esp)
  801857:	e8 21 06 00 00       	call   801e7d <cprintf>

	serve_init();
  80185c:	e8 4f fa ff ff       	call   8012b0 <serve_init>
	fs_init();
  801861:	e8 e7 f9 ff ff       	call   80124d <fs_init>
	fs_test();
  801866:	e8 0d 00 00 00       	call   801878 <fs_test>
	serve();
  80186b:	90                   	nop
  80186c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801870:	e8 c4 fe ff ff       	call   801739 <serve>
}
  801875:	c9                   	leave  
  801876:	c3                   	ret    
	...

00801878 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	53                   	push   %ebx
  80187c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80187f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801886:	00 
  801887:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  80188e:	00 
  80188f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801896:	e8 0f 13 00 00       	call   802baa <sys_page_alloc>
  80189b:	85 c0                	test   %eax,%eax
  80189d:	79 20                	jns    8018bf <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80189f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018a3:	c7 44 24 08 48 3e 80 	movl   $0x803e48,0x8(%esp)
  8018aa:	00 
  8018ab:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  8018b2:	00 
  8018b3:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  8018ba:	e8 05 05 00 00       	call   801dc4 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8018bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8018c6:	00 
  8018c7:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8018cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d0:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8018d7:	e8 c9 0e 00 00       	call   8027a5 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8018dc:	e8 31 ef ff ff       	call   800812 <alloc_block>
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	79 20                	jns    801905 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8018e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018e9:	c7 44 24 08 65 3e 80 	movl   $0x803e65,0x8(%esp)
  8018f0:	00 
  8018f1:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  8018f8:	00 
  8018f9:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801900:	e8 bf 04 00 00       	call   801dc4 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801905:	8d 50 1f             	lea    0x1f(%eax),%edx
  801908:	85 c0                	test   %eax,%eax
  80190a:	0f 49 d0             	cmovns %eax,%edx
  80190d:	c1 fa 05             	sar    $0x5,%edx
  801910:	c1 e2 02             	shl    $0x2,%edx
  801913:	89 c3                	mov    %eax,%ebx
  801915:	c1 fb 1f             	sar    $0x1f,%ebx
  801918:	c1 eb 1b             	shr    $0x1b,%ebx
  80191b:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  80191e:	83 e1 1f             	and    $0x1f,%ecx
  801921:	29 d9                	sub    %ebx,%ecx
  801923:	b8 01 00 00 00       	mov    $0x1,%eax
  801928:	d3 e0                	shl    %cl,%eax
  80192a:	85 82 00 10 00 00    	test   %eax,0x1000(%edx)
  801930:	75 24                	jne    801956 <fs_test+0xde>
  801932:	c7 44 24 0c 75 3e 80 	movl   $0x803e75,0xc(%esp)
  801939:	00 
  80193a:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801941:	00 
  801942:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801949:	00 
  80194a:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801951:	e8 6e 04 00 00       	call   801dc4 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801956:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  80195c:	85 04 11             	test   %eax,(%ecx,%edx,1)
  80195f:	74 24                	je     801985 <fs_test+0x10d>
  801961:	c7 44 24 0c ec 3f 80 	movl   $0x803fec,0xc(%esp)
  801968:	00 
  801969:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801970:	00 
  801971:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801978:	00 
  801979:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801980:	e8 3f 04 00 00       	call   801dc4 <_panic>
	cprintf("alloc_block is good\n");
  801985:	c7 04 24 90 3e 80 00 	movl   $0x803e90,(%esp)
  80198c:	e8 ec 04 00 00       	call   801e7d <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801991:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801994:	89 44 24 04          	mov    %eax,0x4(%esp)
  801998:	c7 04 24 a5 3e 80 00 	movl   $0x803ea5,(%esp)
  80199f:	e8 a8 f5 ff ff       	call   800f4c <file_open>
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	79 25                	jns    8019cd <fs_test+0x155>
  8019a8:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8019ab:	74 40                	je     8019ed <fs_test+0x175>
		panic("file_open /not-found: %e", r);
  8019ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019b1:	c7 44 24 08 b0 3e 80 	movl   $0x803eb0,0x8(%esp)
  8019b8:	00 
  8019b9:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8019c0:	00 
  8019c1:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  8019c8:	e8 f7 03 00 00       	call   801dc4 <_panic>
	else if (r == 0)
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	75 1c                	jne    8019ed <fs_test+0x175>
		panic("file_open /not-found succeeded!");
  8019d1:	c7 44 24 08 0c 40 80 	movl   $0x80400c,0x8(%esp)
  8019d8:	00 
  8019d9:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8019e0:	00 
  8019e1:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  8019e8:	e8 d7 03 00 00       	call   801dc4 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8019ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f4:	c7 04 24 c9 3e 80 00 	movl   $0x803ec9,(%esp)
  8019fb:	e8 4c f5 ff ff       	call   800f4c <file_open>
  801a00:	85 c0                	test   %eax,%eax
  801a02:	79 20                	jns    801a24 <fs_test+0x1ac>
		panic("file_open /newmotd: %e", r);
  801a04:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a08:	c7 44 24 08 d2 3e 80 	movl   $0x803ed2,0x8(%esp)
  801a0f:	00 
  801a10:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801a17:	00 
  801a18:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801a1f:	e8 a0 03 00 00       	call   801dc4 <_panic>
	cprintf("file_open is good\n");
  801a24:	c7 04 24 e9 3e 80 00 	movl   $0x803ee9,(%esp)
  801a2b:	e8 4d 04 00 00       	call   801e7d <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801a30:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a3e:	00 
  801a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a42:	89 04 24             	mov    %eax,(%esp)
  801a45:	e8 dd f1 ff ff       	call   800c27 <file_get_block>
  801a4a:	85 c0                	test   %eax,%eax
  801a4c:	79 20                	jns    801a6e <fs_test+0x1f6>
		panic("file_get_block: %e", r);
  801a4e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a52:	c7 44 24 08 fc 3e 80 	movl   $0x803efc,0x8(%esp)
  801a59:	00 
  801a5a:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801a61:	00 
  801a62:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801a69:	e8 56 03 00 00       	call   801dc4 <_panic>
	if (strcmp(blk, msg) != 0)
  801a6e:	8b 1d 78 40 80 00    	mov    0x804078,%ebx
  801a74:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a7b:	89 04 24             	mov    %eax,(%esp)
  801a7e:	e8 f2 0b 00 00       	call   802675 <strcmp>
  801a83:	85 c0                	test   %eax,%eax
  801a85:	74 1c                	je     801aa3 <fs_test+0x22b>
		panic("file_get_block returned wrong data");
  801a87:	c7 44 24 08 2c 40 80 	movl   $0x80402c,0x8(%esp)
  801a8e:	00 
  801a8f:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  801a96:	00 
  801a97:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801a9e:	e8 21 03 00 00       	call   801dc4 <_panic>
	cprintf("file_get_block is good\n");
  801aa3:	c7 04 24 0f 3f 80 00 	movl   $0x803f0f,(%esp)
  801aaa:	e8 ce 03 00 00       	call   801e7d <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ab2:	0f b6 10             	movzbl (%eax),%edx
  801ab5:	88 10                	mov    %dl,(%eax)
	assert((vpt[PGNUM(blk)] & PTE_D));
  801ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aba:	c1 e8 0c             	shr    $0xc,%eax
  801abd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ac4:	a8 40                	test   $0x40,%al
  801ac6:	75 24                	jne    801aec <fs_test+0x274>
  801ac8:	c7 44 24 0c 28 3f 80 	movl   $0x803f28,0xc(%esp)
  801acf:	00 
  801ad0:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801ad7:	00 
  801ad8:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801adf:	00 
  801ae0:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801ae7:	e8 d8 02 00 00       	call   801dc4 <_panic>
	file_flush(f);
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	89 04 24             	mov    %eax,(%esp)
  801af2:	e8 8f f0 ff ff       	call   800b86 <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  801af7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801afa:	c1 e8 0c             	shr    $0xc,%eax
  801afd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b04:	a8 40                	test   $0x40,%al
  801b06:	74 24                	je     801b2c <fs_test+0x2b4>
  801b08:	c7 44 24 0c 27 3f 80 	movl   $0x803f27,0xc(%esp)
  801b0f:	00 
  801b10:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801b17:	00 
  801b18:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  801b1f:	00 
  801b20:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801b27:	e8 98 02 00 00       	call   801dc4 <_panic>
	cprintf("file_flush is good\n");
  801b2c:	c7 04 24 42 3f 80 00 	movl   $0x803f42,(%esp)
  801b33:	e8 45 03 00 00       	call   801e7d <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801b38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b3f:	00 
  801b40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b43:	89 04 24             	mov    %eax,(%esp)
  801b46:	e8 fb ef ff ff       	call   800b46 <file_set_size>
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	79 20                	jns    801b6f <fs_test+0x2f7>
		panic("file_set_size: %e", r);
  801b4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b53:	c7 44 24 08 56 3f 80 	movl   $0x803f56,0x8(%esp)
  801b5a:	00 
  801b5b:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801b62:	00 
  801b63:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801b6a:	e8 55 02 00 00       	call   801dc4 <_panic>
	assert(f->f_direct[0] == 0);
  801b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b72:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801b79:	74 24                	je     801b9f <fs_test+0x327>
  801b7b:	c7 44 24 0c 68 3f 80 	movl   $0x803f68,0xc(%esp)
  801b82:	00 
  801b83:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801b8a:	00 
  801b8b:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801b92:	00 
  801b93:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801b9a:	e8 25 02 00 00       	call   801dc4 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  801b9f:	c1 e8 0c             	shr    $0xc,%eax
  801ba2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ba9:	a8 40                	test   $0x40,%al
  801bab:	74 24                	je     801bd1 <fs_test+0x359>
  801bad:	c7 44 24 0c 7c 3f 80 	movl   $0x803f7c,0xc(%esp)
  801bb4:	00 
  801bb5:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801bbc:	00 
  801bbd:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  801bc4:	00 
  801bc5:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801bcc:	e8 f3 01 00 00       	call   801dc4 <_panic>
	cprintf("file_truncate is good\n");
  801bd1:	c7 04 24 95 3f 80 00 	movl   $0x803f95,(%esp)
  801bd8:	e8 a0 02 00 00       	call   801e7d <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801bdd:	89 1c 24             	mov    %ebx,(%esp)
  801be0:	e8 8b 09 00 00       	call   802570 <strlen>
  801be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 52 ef ff ff       	call   800b46 <file_set_size>
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	79 20                	jns    801c18 <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  801bf8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bfc:	c7 44 24 08 ac 3f 80 	movl   $0x803fac,0x8(%esp)
  801c03:	00 
  801c04:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801c0b:	00 
  801c0c:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801c13:	e8 ac 01 00 00       	call   801dc4 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  801c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1b:	89 c2                	mov    %eax,%edx
  801c1d:	c1 ea 0c             	shr    $0xc,%edx
  801c20:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c27:	f6 c2 40             	test   $0x40,%dl
  801c2a:	74 24                	je     801c50 <fs_test+0x3d8>
  801c2c:	c7 44 24 0c 7c 3f 80 	movl   $0x803f7c,0xc(%esp)
  801c33:	00 
  801c34:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801c3b:	00 
  801c3c:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  801c43:	00 
  801c44:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801c4b:	e8 74 01 00 00       	call   801dc4 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801c50:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801c53:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c5e:	00 
  801c5f:	89 04 24             	mov    %eax,(%esp)
  801c62:	e8 c0 ef ff ff       	call   800c27 <file_get_block>
  801c67:	85 c0                	test   %eax,%eax
  801c69:	79 20                	jns    801c8b <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801c6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6f:	c7 44 24 08 c0 3f 80 	movl   $0x803fc0,0x8(%esp)
  801c76:	00 
  801c77:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  801c7e:	00 
  801c7f:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801c86:	e8 39 01 00 00       	call   801dc4 <_panic>
	strcpy(blk, msg);
  801c8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c92:	89 04 24             	mov    %eax,(%esp)
  801c95:	e8 20 09 00 00       	call   8025ba <strcpy>
	assert((vpt[PGNUM(blk)] & PTE_D));
  801c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c9d:	c1 e8 0c             	shr    $0xc,%eax
  801ca0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ca7:	a8 40                	test   $0x40,%al
  801ca9:	75 24                	jne    801ccf <fs_test+0x457>
  801cab:	c7 44 24 0c 28 3f 80 	movl   $0x803f28,0xc(%esp)
  801cb2:	00 
  801cb3:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801cba:	00 
  801cbb:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  801cc2:	00 
  801cc3:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801cca:	e8 f5 00 00 00       	call   801dc4 <_panic>
	file_flush(f);
  801ccf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd2:	89 04 24             	mov    %eax,(%esp)
  801cd5:	e8 ac ee ff ff       	call   800b86 <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  801cda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdd:	c1 e8 0c             	shr    $0xc,%eax
  801ce0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801ce7:	a8 40                	test   $0x40,%al
  801ce9:	74 24                	je     801d0f <fs_test+0x497>
  801ceb:	c7 44 24 0c 27 3f 80 	movl   $0x803f27,0xc(%esp)
  801cf2:	00 
  801cf3:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801cfa:	00 
  801cfb:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801d02:	00 
  801d03:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801d0a:	e8 b5 00 00 00       	call   801dc4 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  801d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d12:	c1 e8 0c             	shr    $0xc,%eax
  801d15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801d1c:	a8 40                	test   $0x40,%al
  801d1e:	74 24                	je     801d44 <fs_test+0x4cc>
  801d20:	c7 44 24 0c 7c 3f 80 	movl   $0x803f7c,0xc(%esp)
  801d27:	00 
  801d28:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  801d2f:	00 
  801d30:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  801d37:	00 
  801d38:	c7 04 24 5b 3e 80 00 	movl   $0x803e5b,(%esp)
  801d3f:	e8 80 00 00 00       	call   801dc4 <_panic>
	cprintf("file rewrite is good\n");
  801d44:	c7 04 24 d5 3f 80 00 	movl   $0x803fd5,(%esp)
  801d4b:	e8 2d 01 00 00       	call   801e7d <cprintf>
}
  801d50:	83 c4 24             	add    $0x24,%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    
	...

00801d58 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	83 ec 18             	sub    $0x18,%esp
  801d5e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d61:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d64:	8b 75 08             	mov    0x8(%ebp),%esi
  801d67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  801d6a:	e8 e5 0e 00 00       	call   802c54 <sys_getenvid>
  801d6f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801d74:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d77:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d7c:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801d81:	85 f6                	test   %esi,%esi
  801d83:	7e 07                	jle    801d8c <libmain+0x34>
		binaryname = argv[0];
  801d85:	8b 03                	mov    (%ebx),%eax
  801d87:	a3 64 90 80 00       	mov    %eax,0x809064

	// call user main routine
	umain(argc, argv);
  801d8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d90:	89 34 24             	mov    %esi,(%esp)
  801d93:	e8 90 fa ff ff       	call   801828 <umain>

	// exit gracefully
	exit();
  801d98:	e8 0b 00 00 00       	call   801da8 <exit>
}
  801d9d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801da0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801da3:	89 ec                	mov    %ebp,%esp
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    
	...

00801da8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801da8:	55                   	push   %ebp
  801da9:	89 e5                	mov    %esp,%ebp
  801dab:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801dae:	e8 66 16 00 00       	call   803419 <close_all>
	sys_env_destroy(0);
  801db3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dba:	e8 d0 0e 00 00       	call   802c8f <sys_env_destroy>
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    
  801dc1:	00 00                	add    %al,(%eax)
	...

00801dc4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801dcc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dcf:	8b 1d 64 90 80 00    	mov    0x809064,%ebx
  801dd5:	e8 7a 0e 00 00       	call   802c54 <sys_getenvid>
  801dda:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddd:	89 54 24 10          	mov    %edx,0x10(%esp)
  801de1:	8b 55 08             	mov    0x8(%ebp),%edx
  801de4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801de8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df0:	c7 04 24 88 40 80 00 	movl   $0x804088,(%esp)
  801df7:	e8 81 00 00 00       	call   801e7d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dfc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e00:	8b 45 10             	mov    0x10(%ebp),%eax
  801e03:	89 04 24             	mov    %eax,(%esp)
  801e06:	e8 11 00 00 00       	call   801e1c <vcprintf>
	cprintf("\n");
  801e0b:	c7 04 24 6c 3c 80 00 	movl   $0x803c6c,(%esp)
  801e12:	e8 66 00 00 00       	call   801e7d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e17:	cc                   	int3   
  801e18:	eb fd                	jmp    801e17 <_panic+0x53>
	...

00801e1c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801e25:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801e2c:	00 00 00 
	b.cnt = 0;
  801e2f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801e36:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801e39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e40:	8b 45 08             	mov    0x8(%ebp),%eax
  801e43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e47:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e51:	c7 04 24 97 1e 80 00 	movl   $0x801e97,(%esp)
  801e58:	e8 d0 01 00 00       	call   80202d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801e5d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801e6d:	89 04 24             	mov    %eax,(%esp)
  801e70:	e8 8e 0e 00 00       	call   802d03 <sys_cputs>

	return b.cnt;
}
  801e75:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801e7b:	c9                   	leave  
  801e7c:	c3                   	ret    

00801e7d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801e7d:	55                   	push   %ebp
  801e7e:	89 e5                	mov    %esp,%ebp
  801e80:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801e83:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8d:	89 04 24             	mov    %eax,(%esp)
  801e90:	e8 87 ff ff ff       	call   801e1c <vcprintf>
	va_end(ap);

	return cnt;
}
  801e95:	c9                   	leave  
  801e96:	c3                   	ret    

00801e97 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	53                   	push   %ebx
  801e9b:	83 ec 14             	sub    $0x14,%esp
  801e9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801ea1:	8b 03                	mov    (%ebx),%eax
  801ea3:	8b 55 08             	mov    0x8(%ebp),%edx
  801ea6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801eaa:	83 c0 01             	add    $0x1,%eax
  801ead:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801eaf:	3d ff 00 00 00       	cmp    $0xff,%eax
  801eb4:	75 19                	jne    801ecf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801eb6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801ebd:	00 
  801ebe:	8d 43 08             	lea    0x8(%ebx),%eax
  801ec1:	89 04 24             	mov    %eax,(%esp)
  801ec4:	e8 3a 0e 00 00       	call   802d03 <sys_cputs>
		b->idx = 0;
  801ec9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801ecf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801ed3:	83 c4 14             	add    $0x14,%esp
  801ed6:	5b                   	pop    %ebx
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    
  801ed9:	00 00                	add    %al,(%eax)
  801edb:	00 00                	add    %al,(%eax)
  801edd:	00 00                	add    %al,(%eax)
	...

00801ee0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801ee0:	55                   	push   %ebp
  801ee1:	89 e5                	mov    %esp,%ebp
  801ee3:	57                   	push   %edi
  801ee4:	56                   	push   %esi
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 4c             	sub    $0x4c,%esp
  801ee9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eec:	89 d6                	mov    %edx,%esi
  801eee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801ef4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ef7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801efa:	8b 45 10             	mov    0x10(%ebp),%eax
  801efd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801f00:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801f03:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801f06:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f0b:	39 d1                	cmp    %edx,%ecx
  801f0d:	72 15                	jb     801f24 <printnum+0x44>
  801f0f:	77 07                	ja     801f18 <printnum+0x38>
  801f11:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801f14:	39 d0                	cmp    %edx,%eax
  801f16:	76 0c                	jbe    801f24 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801f18:	83 eb 01             	sub    $0x1,%ebx
  801f1b:	85 db                	test   %ebx,%ebx
  801f1d:	8d 76 00             	lea    0x0(%esi),%esi
  801f20:	7f 61                	jg     801f83 <printnum+0xa3>
  801f22:	eb 70                	jmp    801f94 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801f24:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801f28:	83 eb 01             	sub    $0x1,%ebx
  801f2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f33:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f37:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  801f3b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801f3e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801f41:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801f44:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801f4f:	00 
  801f50:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801f53:	89 04 24             	mov    %eax,(%esp)
  801f56:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801f59:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f5d:	e8 fe 18 00 00       	call   803860 <__udivdi3>
  801f62:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801f65:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f6c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f70:	89 04 24             	mov    %eax,(%esp)
  801f73:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f77:	89 f2                	mov    %esi,%edx
  801f79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7c:	e8 5f ff ff ff       	call   801ee0 <printnum>
  801f81:	eb 11                	jmp    801f94 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801f83:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f87:	89 3c 24             	mov    %edi,(%esp)
  801f8a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801f8d:	83 eb 01             	sub    $0x1,%ebx
  801f90:	85 db                	test   %ebx,%ebx
  801f92:	7f ef                	jg     801f83 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801f94:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f98:	8b 74 24 04          	mov    0x4(%esp),%esi
  801f9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801f9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801faa:	00 
  801fab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801fae:	89 14 24             	mov    %edx,(%esp)
  801fb1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801fb4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fb8:	e8 d3 19 00 00       	call   803990 <__umoddi3>
  801fbd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc1:	0f be 80 ab 40 80 00 	movsbl 0x8040ab(%eax),%eax
  801fc8:	89 04 24             	mov    %eax,(%esp)
  801fcb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801fce:	83 c4 4c             	add    $0x4c,%esp
  801fd1:	5b                   	pop    %ebx
  801fd2:	5e                   	pop    %esi
  801fd3:	5f                   	pop    %edi
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    

00801fd6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801fd9:	83 fa 01             	cmp    $0x1,%edx
  801fdc:	7e 0e                	jle    801fec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801fde:	8b 10                	mov    (%eax),%edx
  801fe0:	8d 4a 08             	lea    0x8(%edx),%ecx
  801fe3:	89 08                	mov    %ecx,(%eax)
  801fe5:	8b 02                	mov    (%edx),%eax
  801fe7:	8b 52 04             	mov    0x4(%edx),%edx
  801fea:	eb 22                	jmp    80200e <getuint+0x38>
	else if (lflag)
  801fec:	85 d2                	test   %edx,%edx
  801fee:	74 10                	je     802000 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801ff0:	8b 10                	mov    (%eax),%edx
  801ff2:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ff5:	89 08                	mov    %ecx,(%eax)
  801ff7:	8b 02                	mov    (%edx),%eax
  801ff9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ffe:	eb 0e                	jmp    80200e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  802000:	8b 10                	mov    (%eax),%edx
  802002:	8d 4a 04             	lea    0x4(%edx),%ecx
  802005:	89 08                	mov    %ecx,(%eax)
  802007:	8b 02                	mov    (%edx),%eax
  802009:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80200e:	5d                   	pop    %ebp
  80200f:	c3                   	ret    

00802010 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
  802013:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  802016:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80201a:	8b 10                	mov    (%eax),%edx
  80201c:	3b 50 04             	cmp    0x4(%eax),%edx
  80201f:	73 0a                	jae    80202b <sprintputch+0x1b>
		*b->buf++ = ch;
  802021:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802024:	88 0a                	mov    %cl,(%edx)
  802026:	83 c2 01             	add    $0x1,%edx
  802029:	89 10                	mov    %edx,(%eax)
}
  80202b:	5d                   	pop    %ebp
  80202c:	c3                   	ret    

0080202d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	57                   	push   %edi
  802031:	56                   	push   %esi
  802032:	53                   	push   %ebx
  802033:	83 ec 5c             	sub    $0x5c,%esp
  802036:	8b 7d 08             	mov    0x8(%ebp),%edi
  802039:	8b 75 0c             	mov    0xc(%ebp),%esi
  80203c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80203f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  802046:	eb 11                	jmp    802059 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  802048:	85 c0                	test   %eax,%eax
  80204a:	0f 84 68 04 00 00    	je     8024b8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  802050:	89 74 24 04          	mov    %esi,0x4(%esp)
  802054:	89 04 24             	mov    %eax,(%esp)
  802057:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  802059:	0f b6 03             	movzbl (%ebx),%eax
  80205c:	83 c3 01             	add    $0x1,%ebx
  80205f:	83 f8 25             	cmp    $0x25,%eax
  802062:	75 e4                	jne    802048 <vprintfmt+0x1b>
  802064:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80206b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  802072:	b9 00 00 00 00       	mov    $0x0,%ecx
  802077:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80207b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  802082:	eb 06                	jmp    80208a <vprintfmt+0x5d>
  802084:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  802088:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80208a:	0f b6 13             	movzbl (%ebx),%edx
  80208d:	0f b6 c2             	movzbl %dl,%eax
  802090:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802093:	8d 43 01             	lea    0x1(%ebx),%eax
  802096:	83 ea 23             	sub    $0x23,%edx
  802099:	80 fa 55             	cmp    $0x55,%dl
  80209c:	0f 87 f9 03 00 00    	ja     80249b <vprintfmt+0x46e>
  8020a2:	0f b6 d2             	movzbl %dl,%edx
  8020a5:	ff 24 95 80 42 80 00 	jmp    *0x804280(,%edx,4)
  8020ac:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8020b0:	eb d6                	jmp    802088 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8020b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8020b5:	83 ea 30             	sub    $0x30,%edx
  8020b8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8020bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8020be:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8020c1:	83 fb 09             	cmp    $0x9,%ebx
  8020c4:	77 54                	ja     80211a <vprintfmt+0xed>
  8020c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8020c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8020cc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8020cf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8020d2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8020d6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8020d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8020dc:	83 fb 09             	cmp    $0x9,%ebx
  8020df:	76 eb                	jbe    8020cc <vprintfmt+0x9f>
  8020e1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8020e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8020e7:	eb 31                	jmp    80211a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8020e9:	8b 55 14             	mov    0x14(%ebp),%edx
  8020ec:	8d 5a 04             	lea    0x4(%edx),%ebx
  8020ef:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8020f2:	8b 12                	mov    (%edx),%edx
  8020f4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8020f7:	eb 21                	jmp    80211a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8020f9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8020fd:	ba 00 00 00 00       	mov    $0x0,%edx
  802102:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  802106:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  802109:	e9 7a ff ff ff       	jmp    802088 <vprintfmt+0x5b>
  80210e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  802115:	e9 6e ff ff ff       	jmp    802088 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80211a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80211e:	0f 89 64 ff ff ff    	jns    802088 <vprintfmt+0x5b>
  802124:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802127:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80212a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80212d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  802130:	e9 53 ff ff ff       	jmp    802088 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  802135:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  802138:	e9 4b ff ff ff       	jmp    802088 <vprintfmt+0x5b>
  80213d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  802140:	8b 45 14             	mov    0x14(%ebp),%eax
  802143:	8d 50 04             	lea    0x4(%eax),%edx
  802146:	89 55 14             	mov    %edx,0x14(%ebp)
  802149:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214d:	8b 00                	mov    (%eax),%eax
  80214f:	89 04 24             	mov    %eax,(%esp)
  802152:	ff d7                	call   *%edi
  802154:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  802157:	e9 fd fe ff ff       	jmp    802059 <vprintfmt+0x2c>
  80215c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80215f:	8b 45 14             	mov    0x14(%ebp),%eax
  802162:	8d 50 04             	lea    0x4(%eax),%edx
  802165:	89 55 14             	mov    %edx,0x14(%ebp)
  802168:	8b 00                	mov    (%eax),%eax
  80216a:	89 c2                	mov    %eax,%edx
  80216c:	c1 fa 1f             	sar    $0x1f,%edx
  80216f:	31 d0                	xor    %edx,%eax
  802171:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  802173:	83 f8 0f             	cmp    $0xf,%eax
  802176:	7f 0b                	jg     802183 <vprintfmt+0x156>
  802178:	8b 14 85 e0 43 80 00 	mov    0x8043e0(,%eax,4),%edx
  80217f:	85 d2                	test   %edx,%edx
  802181:	75 20                	jne    8021a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  802183:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802187:	c7 44 24 08 bc 40 80 	movl   $0x8040bc,0x8(%esp)
  80218e:	00 
  80218f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	e8 a5 03 00 00       	call   802540 <printfmt>
  80219b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80219e:	e9 b6 fe ff ff       	jmp    802059 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8021a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021a7:	c7 44 24 08 ff 3a 80 	movl   $0x803aff,0x8(%esp)
  8021ae:	00 
  8021af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	e8 85 03 00 00       	call   802540 <printfmt>
  8021bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8021be:	e9 96 fe ff ff       	jmp    802059 <vprintfmt+0x2c>
  8021c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8021cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8021ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8021d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8021d4:	8d 50 04             	lea    0x4(%eax),%edx
  8021d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8021da:	8b 00                	mov    (%eax),%eax
  8021dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8021df:	85 c0                	test   %eax,%eax
  8021e1:	b8 c5 40 80 00       	mov    $0x8040c5,%eax
  8021e6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8021ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8021ed:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8021f1:	7e 06                	jle    8021f9 <vprintfmt+0x1cc>
  8021f3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8021f7:	75 13                	jne    80220c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8021f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8021fc:	0f be 02             	movsbl (%edx),%eax
  8021ff:	85 c0                	test   %eax,%eax
  802201:	0f 85 a2 00 00 00    	jne    8022a9 <vprintfmt+0x27c>
  802207:	e9 8f 00 00 00       	jmp    80229b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80220c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802210:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  802213:	89 0c 24             	mov    %ecx,(%esp)
  802216:	e8 70 03 00 00       	call   80258b <strnlen>
  80221b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80221e:	29 c2                	sub    %eax,%edx
  802220:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  802223:	85 d2                	test   %edx,%edx
  802225:	7e d2                	jle    8021f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  802227:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80222b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80222e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  802231:	89 d3                	mov    %edx,%ebx
  802233:	89 74 24 04          	mov    %esi,0x4(%esp)
  802237:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80223a:	89 04 24             	mov    %eax,(%esp)
  80223d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80223f:	83 eb 01             	sub    $0x1,%ebx
  802242:	85 db                	test   %ebx,%ebx
  802244:	7f ed                	jg     802233 <vprintfmt+0x206>
  802246:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  802249:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  802250:	eb a7                	jmp    8021f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802252:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  802256:	74 1b                	je     802273 <vprintfmt+0x246>
  802258:	8d 50 e0             	lea    -0x20(%eax),%edx
  80225b:	83 fa 5e             	cmp    $0x5e,%edx
  80225e:	76 13                	jbe    802273 <vprintfmt+0x246>
					putch('?', putdat);
  802260:	8b 55 e0             	mov    -0x20(%ebp),%edx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80226e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  802271:	eb 0d                	jmp    802280 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  802273:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802276:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80227a:	89 04 24             	mov    %eax,(%esp)
  80227d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802280:	83 ef 01             	sub    $0x1,%edi
  802283:	0f be 03             	movsbl (%ebx),%eax
  802286:	85 c0                	test   %eax,%eax
  802288:	74 05                	je     80228f <vprintfmt+0x262>
  80228a:	83 c3 01             	add    $0x1,%ebx
  80228d:	eb 31                	jmp    8022c0 <vprintfmt+0x293>
  80228f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  802292:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802295:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802298:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80229b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80229f:	7f 36                	jg     8022d7 <vprintfmt+0x2aa>
  8022a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8022a4:	e9 b0 fd ff ff       	jmp    802059 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8022a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8022ac:	83 c2 01             	add    $0x1,%edx
  8022af:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8022b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8022b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8022b8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8022bb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8022be:	89 d3                	mov    %edx,%ebx
  8022c0:	85 f6                	test   %esi,%esi
  8022c2:	78 8e                	js     802252 <vprintfmt+0x225>
  8022c4:	83 ee 01             	sub    $0x1,%esi
  8022c7:	79 89                	jns    802252 <vprintfmt+0x225>
  8022c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8022cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8022cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8022d2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8022d5:	eb c4                	jmp    80229b <vprintfmt+0x26e>
  8022d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8022da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8022dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022e1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8022e8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8022ea:	83 eb 01             	sub    $0x1,%ebx
  8022ed:	85 db                	test   %ebx,%ebx
  8022ef:	7f ec                	jg     8022dd <vprintfmt+0x2b0>
  8022f1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8022f4:	e9 60 fd ff ff       	jmp    802059 <vprintfmt+0x2c>
  8022f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8022fc:	83 f9 01             	cmp    $0x1,%ecx
  8022ff:	7e 16                	jle    802317 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  802301:	8b 45 14             	mov    0x14(%ebp),%eax
  802304:	8d 50 08             	lea    0x8(%eax),%edx
  802307:	89 55 14             	mov    %edx,0x14(%ebp)
  80230a:	8b 10                	mov    (%eax),%edx
  80230c:	8b 48 04             	mov    0x4(%eax),%ecx
  80230f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  802312:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802315:	eb 32                	jmp    802349 <vprintfmt+0x31c>
	else if (lflag)
  802317:	85 c9                	test   %ecx,%ecx
  802319:	74 18                	je     802333 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80231b:	8b 45 14             	mov    0x14(%ebp),%eax
  80231e:	8d 50 04             	lea    0x4(%eax),%edx
  802321:	89 55 14             	mov    %edx,0x14(%ebp)
  802324:	8b 00                	mov    (%eax),%eax
  802326:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802329:	89 c1                	mov    %eax,%ecx
  80232b:	c1 f9 1f             	sar    $0x1f,%ecx
  80232e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802331:	eb 16                	jmp    802349 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  802333:	8b 45 14             	mov    0x14(%ebp),%eax
  802336:	8d 50 04             	lea    0x4(%eax),%edx
  802339:	89 55 14             	mov    %edx,0x14(%ebp)
  80233c:	8b 00                	mov    (%eax),%eax
  80233e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802341:	89 c2                	mov    %eax,%edx
  802343:	c1 fa 1f             	sar    $0x1f,%edx
  802346:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  802349:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80234c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80234f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  802354:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  802358:	0f 89 8a 00 00 00    	jns    8023e8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80235e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802362:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  802369:	ff d7                	call   *%edi
				num = -(long long) num;
  80236b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80236e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802371:	f7 d8                	neg    %eax
  802373:	83 d2 00             	adc    $0x0,%edx
  802376:	f7 da                	neg    %edx
  802378:	eb 6e                	jmp    8023e8 <vprintfmt+0x3bb>
  80237a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80237d:	89 ca                	mov    %ecx,%edx
  80237f:	8d 45 14             	lea    0x14(%ebp),%eax
  802382:	e8 4f fc ff ff       	call   801fd6 <getuint>
  802387:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80238c:	eb 5a                	jmp    8023e8 <vprintfmt+0x3bb>
  80238e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  802391:	89 ca                	mov    %ecx,%edx
  802393:	8d 45 14             	lea    0x14(%ebp),%eax
  802396:	e8 3b fc ff ff       	call   801fd6 <getuint>
  80239b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8023a0:	eb 46                	jmp    8023e8 <vprintfmt+0x3bb>
  8023a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8023a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8023b0:	ff d7                	call   *%edi
			putch('x', putdat);
  8023b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023b6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8023bd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8023bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8023c2:	8d 50 04             	lea    0x4(%eax),%edx
  8023c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8023c8:	8b 00                	mov    (%eax),%eax
  8023ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8023cf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8023d4:	eb 12                	jmp    8023e8 <vprintfmt+0x3bb>
  8023d6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8023d9:	89 ca                	mov    %ecx,%edx
  8023db:	8d 45 14             	lea    0x14(%ebp),%eax
  8023de:	e8 f3 fb ff ff       	call   801fd6 <getuint>
  8023e3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8023e8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8023ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8023f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8023f3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fb:	89 04 24             	mov    %eax,(%esp)
  8023fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  802402:	89 f2                	mov    %esi,%edx
  802404:	89 f8                	mov    %edi,%eax
  802406:	e8 d5 fa ff ff       	call   801ee0 <printnum>
  80240b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80240e:	e9 46 fc ff ff       	jmp    802059 <vprintfmt+0x2c>
  802413:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  802416:	8b 45 14             	mov    0x14(%ebp),%eax
  802419:	8d 50 04             	lea    0x4(%eax),%edx
  80241c:	89 55 14             	mov    %edx,0x14(%ebp)
  80241f:	8b 00                	mov    (%eax),%eax
  802421:	85 c0                	test   %eax,%eax
  802423:	75 24                	jne    802449 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  802425:	c7 44 24 0c e0 41 80 	movl   $0x8041e0,0xc(%esp)
  80242c:	00 
  80242d:	c7 44 24 08 ff 3a 80 	movl   $0x803aff,0x8(%esp)
  802434:	00 
  802435:	89 74 24 04          	mov    %esi,0x4(%esp)
  802439:	89 3c 24             	mov    %edi,(%esp)
  80243c:	e8 ff 00 00 00       	call   802540 <printfmt>
  802441:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  802444:	e9 10 fc ff ff       	jmp    802059 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  802449:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80244c:	7e 29                	jle    802477 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80244e:	0f b6 16             	movzbl (%esi),%edx
  802451:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  802453:	c7 44 24 0c 18 42 80 	movl   $0x804218,0xc(%esp)
  80245a:	00 
  80245b:	c7 44 24 08 ff 3a 80 	movl   $0x803aff,0x8(%esp)
  802462:	00 
  802463:	89 74 24 04          	mov    %esi,0x4(%esp)
  802467:	89 3c 24             	mov    %edi,(%esp)
  80246a:	e8 d1 00 00 00       	call   802540 <printfmt>
  80246f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  802472:	e9 e2 fb ff ff       	jmp    802059 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  802477:	0f b6 16             	movzbl (%esi),%edx
  80247a:	88 10                	mov    %dl,(%eax)
  80247c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80247f:	e9 d5 fb ff ff       	jmp    802059 <vprintfmt+0x2c>
  802484:	89 45 d0             	mov    %eax,-0x30(%ebp)
  802487:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80248a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80248e:	89 14 24             	mov    %edx,(%esp)
  802491:	ff d7                	call   *%edi
  802493:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  802496:	e9 be fb ff ff       	jmp    802059 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80249b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80249f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8024a6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8024a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024ab:	80 38 25             	cmpb   $0x25,(%eax)
  8024ae:	0f 84 a5 fb ff ff    	je     802059 <vprintfmt+0x2c>
  8024b4:	89 c3                	mov    %eax,%ebx
  8024b6:	eb f0                	jmp    8024a8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8024b8:	83 c4 5c             	add    $0x5c,%esp
  8024bb:	5b                   	pop    %ebx
  8024bc:	5e                   	pop    %esi
  8024bd:	5f                   	pop    %edi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	83 ec 28             	sub    $0x28,%esp
  8024c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8024cc:	85 c0                	test   %eax,%eax
  8024ce:	74 04                	je     8024d4 <vsnprintf+0x14>
  8024d0:	85 d2                	test   %edx,%edx
  8024d2:	7f 07                	jg     8024db <vsnprintf+0x1b>
  8024d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8024d9:	eb 3b                	jmp    802516 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8024db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8024de:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8024e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8024e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8024ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8024ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8024f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8024fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802501:	c7 04 24 10 20 80 00 	movl   $0x802010,(%esp)
  802508:	e8 20 fb ff ff       	call   80202d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80250d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802510:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802513:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  802516:	c9                   	leave  
  802517:	c3                   	ret    

00802518 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802518:	55                   	push   %ebp
  802519:	89 e5                	mov    %esp,%ebp
  80251b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80251e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  802521:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802525:	8b 45 10             	mov    0x10(%ebp),%eax
  802528:	89 44 24 08          	mov    %eax,0x8(%esp)
  80252c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80252f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802533:	8b 45 08             	mov    0x8(%ebp),%eax
  802536:	89 04 24             	mov    %eax,(%esp)
  802539:	e8 82 ff ff ff       	call   8024c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80253e:	c9                   	leave  
  80253f:	c3                   	ret    

00802540 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802540:	55                   	push   %ebp
  802541:	89 e5                	mov    %esp,%ebp
  802543:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  802546:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  802549:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80254d:	8b 45 10             	mov    0x10(%ebp),%eax
  802550:	89 44 24 08          	mov    %eax,0x8(%esp)
  802554:	8b 45 0c             	mov    0xc(%ebp),%eax
  802557:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255b:	8b 45 08             	mov    0x8(%ebp),%eax
  80255e:	89 04 24             	mov    %eax,(%esp)
  802561:	e8 c7 fa ff ff       	call   80202d <vprintfmt>
	va_end(ap);
}
  802566:	c9                   	leave  
  802567:	c3                   	ret    
	...

00802570 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802570:	55                   	push   %ebp
  802571:	89 e5                	mov    %esp,%ebp
  802573:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802576:	b8 00 00 00 00       	mov    $0x0,%eax
  80257b:	80 3a 00             	cmpb   $0x0,(%edx)
  80257e:	74 09                	je     802589 <strlen+0x19>
		n++;
  802580:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802583:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802587:	75 f7                	jne    802580 <strlen+0x10>
		n++;
	return n;
}
  802589:	5d                   	pop    %ebp
  80258a:	c3                   	ret    

0080258b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80258b:	55                   	push   %ebp
  80258c:	89 e5                	mov    %esp,%ebp
  80258e:	53                   	push   %ebx
  80258f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802592:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802595:	85 c9                	test   %ecx,%ecx
  802597:	74 19                	je     8025b2 <strnlen+0x27>
  802599:	80 3b 00             	cmpb   $0x0,(%ebx)
  80259c:	74 14                	je     8025b2 <strnlen+0x27>
  80259e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8025a3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8025a6:	39 c8                	cmp    %ecx,%eax
  8025a8:	74 0d                	je     8025b7 <strnlen+0x2c>
  8025aa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8025ae:	75 f3                	jne    8025a3 <strnlen+0x18>
  8025b0:	eb 05                	jmp    8025b7 <strnlen+0x2c>
  8025b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8025b7:	5b                   	pop    %ebx
  8025b8:	5d                   	pop    %ebp
  8025b9:	c3                   	ret    

008025ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8025ba:	55                   	push   %ebp
  8025bb:	89 e5                	mov    %esp,%ebp
  8025bd:	53                   	push   %ebx
  8025be:	8b 45 08             	mov    0x8(%ebp),%eax
  8025c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8025c4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8025c9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8025cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8025d0:	83 c2 01             	add    $0x1,%edx
  8025d3:	84 c9                	test   %cl,%cl
  8025d5:	75 f2                	jne    8025c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8025d7:	5b                   	pop    %ebx
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    

008025da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8025da:	55                   	push   %ebp
  8025db:	89 e5                	mov    %esp,%ebp
  8025dd:	53                   	push   %ebx
  8025de:	83 ec 08             	sub    $0x8,%esp
  8025e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8025e4:	89 1c 24             	mov    %ebx,(%esp)
  8025e7:	e8 84 ff ff ff       	call   802570 <strlen>
	strcpy(dst + len, src);
  8025ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8025ef:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025f3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8025f6:	89 04 24             	mov    %eax,(%esp)
  8025f9:	e8 bc ff ff ff       	call   8025ba <strcpy>
	return dst;
}
  8025fe:	89 d8                	mov    %ebx,%eax
  802600:	83 c4 08             	add    $0x8,%esp
  802603:	5b                   	pop    %ebx
  802604:	5d                   	pop    %ebp
  802605:	c3                   	ret    

00802606 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802606:	55                   	push   %ebp
  802607:	89 e5                	mov    %esp,%ebp
  802609:	56                   	push   %esi
  80260a:	53                   	push   %ebx
  80260b:	8b 45 08             	mov    0x8(%ebp),%eax
  80260e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802611:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802614:	85 f6                	test   %esi,%esi
  802616:	74 18                	je     802630 <strncpy+0x2a>
  802618:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80261d:	0f b6 1a             	movzbl (%edx),%ebx
  802620:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802623:	80 3a 01             	cmpb   $0x1,(%edx)
  802626:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802629:	83 c1 01             	add    $0x1,%ecx
  80262c:	39 ce                	cmp    %ecx,%esi
  80262e:	77 ed                	ja     80261d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802630:	5b                   	pop    %ebx
  802631:	5e                   	pop    %esi
  802632:	5d                   	pop    %ebp
  802633:	c3                   	ret    

00802634 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802634:	55                   	push   %ebp
  802635:	89 e5                	mov    %esp,%ebp
  802637:	56                   	push   %esi
  802638:	53                   	push   %ebx
  802639:	8b 75 08             	mov    0x8(%ebp),%esi
  80263c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80263f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802642:	89 f0                	mov    %esi,%eax
  802644:	85 c9                	test   %ecx,%ecx
  802646:	74 27                	je     80266f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  802648:	83 e9 01             	sub    $0x1,%ecx
  80264b:	74 1d                	je     80266a <strlcpy+0x36>
  80264d:	0f b6 1a             	movzbl (%edx),%ebx
  802650:	84 db                	test   %bl,%bl
  802652:	74 16                	je     80266a <strlcpy+0x36>
			*dst++ = *src++;
  802654:	88 18                	mov    %bl,(%eax)
  802656:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802659:	83 e9 01             	sub    $0x1,%ecx
  80265c:	74 0e                	je     80266c <strlcpy+0x38>
			*dst++ = *src++;
  80265e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802661:	0f b6 1a             	movzbl (%edx),%ebx
  802664:	84 db                	test   %bl,%bl
  802666:	75 ec                	jne    802654 <strlcpy+0x20>
  802668:	eb 02                	jmp    80266c <strlcpy+0x38>
  80266a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80266c:	c6 00 00             	movb   $0x0,(%eax)
  80266f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802671:	5b                   	pop    %ebx
  802672:	5e                   	pop    %esi
  802673:	5d                   	pop    %ebp
  802674:	c3                   	ret    

00802675 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802675:	55                   	push   %ebp
  802676:	89 e5                	mov    %esp,%ebp
  802678:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80267b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80267e:	0f b6 01             	movzbl (%ecx),%eax
  802681:	84 c0                	test   %al,%al
  802683:	74 15                	je     80269a <strcmp+0x25>
  802685:	3a 02                	cmp    (%edx),%al
  802687:	75 11                	jne    80269a <strcmp+0x25>
		p++, q++;
  802689:	83 c1 01             	add    $0x1,%ecx
  80268c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80268f:	0f b6 01             	movzbl (%ecx),%eax
  802692:	84 c0                	test   %al,%al
  802694:	74 04                	je     80269a <strcmp+0x25>
  802696:	3a 02                	cmp    (%edx),%al
  802698:	74 ef                	je     802689 <strcmp+0x14>
  80269a:	0f b6 c0             	movzbl %al,%eax
  80269d:	0f b6 12             	movzbl (%edx),%edx
  8026a0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8026a2:	5d                   	pop    %ebp
  8026a3:	c3                   	ret    

008026a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8026a4:	55                   	push   %ebp
  8026a5:	89 e5                	mov    %esp,%ebp
  8026a7:	53                   	push   %ebx
  8026a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8026ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026ae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8026b1:	85 c0                	test   %eax,%eax
  8026b3:	74 23                	je     8026d8 <strncmp+0x34>
  8026b5:	0f b6 1a             	movzbl (%edx),%ebx
  8026b8:	84 db                	test   %bl,%bl
  8026ba:	74 25                	je     8026e1 <strncmp+0x3d>
  8026bc:	3a 19                	cmp    (%ecx),%bl
  8026be:	75 21                	jne    8026e1 <strncmp+0x3d>
  8026c0:	83 e8 01             	sub    $0x1,%eax
  8026c3:	74 13                	je     8026d8 <strncmp+0x34>
		n--, p++, q++;
  8026c5:	83 c2 01             	add    $0x1,%edx
  8026c8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8026cb:	0f b6 1a             	movzbl (%edx),%ebx
  8026ce:	84 db                	test   %bl,%bl
  8026d0:	74 0f                	je     8026e1 <strncmp+0x3d>
  8026d2:	3a 19                	cmp    (%ecx),%bl
  8026d4:	74 ea                	je     8026c0 <strncmp+0x1c>
  8026d6:	eb 09                	jmp    8026e1 <strncmp+0x3d>
  8026d8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8026dd:	5b                   	pop    %ebx
  8026de:	5d                   	pop    %ebp
  8026df:	90                   	nop
  8026e0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8026e1:	0f b6 02             	movzbl (%edx),%eax
  8026e4:	0f b6 11             	movzbl (%ecx),%edx
  8026e7:	29 d0                	sub    %edx,%eax
  8026e9:	eb f2                	jmp    8026dd <strncmp+0x39>

008026eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8026eb:	55                   	push   %ebp
  8026ec:	89 e5                	mov    %esp,%ebp
  8026ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8026f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8026f5:	0f b6 10             	movzbl (%eax),%edx
  8026f8:	84 d2                	test   %dl,%dl
  8026fa:	74 18                	je     802714 <strchr+0x29>
		if (*s == c)
  8026fc:	38 ca                	cmp    %cl,%dl
  8026fe:	75 0a                	jne    80270a <strchr+0x1f>
  802700:	eb 17                	jmp    802719 <strchr+0x2e>
  802702:	38 ca                	cmp    %cl,%dl
  802704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802708:	74 0f                	je     802719 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80270a:	83 c0 01             	add    $0x1,%eax
  80270d:	0f b6 10             	movzbl (%eax),%edx
  802710:	84 d2                	test   %dl,%dl
  802712:	75 ee                	jne    802702 <strchr+0x17>
  802714:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    

0080271b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80271b:	55                   	push   %ebp
  80271c:	89 e5                	mov    %esp,%ebp
  80271e:	8b 45 08             	mov    0x8(%ebp),%eax
  802721:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802725:	0f b6 10             	movzbl (%eax),%edx
  802728:	84 d2                	test   %dl,%dl
  80272a:	74 18                	je     802744 <strfind+0x29>
		if (*s == c)
  80272c:	38 ca                	cmp    %cl,%dl
  80272e:	75 0a                	jne    80273a <strfind+0x1f>
  802730:	eb 12                	jmp    802744 <strfind+0x29>
  802732:	38 ca                	cmp    %cl,%dl
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	74 0a                	je     802744 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80273a:	83 c0 01             	add    $0x1,%eax
  80273d:	0f b6 10             	movzbl (%eax),%edx
  802740:	84 d2                	test   %dl,%dl
  802742:	75 ee                	jne    802732 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  802744:	5d                   	pop    %ebp
  802745:	c3                   	ret    

00802746 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802746:	55                   	push   %ebp
  802747:	89 e5                	mov    %esp,%ebp
  802749:	83 ec 0c             	sub    $0xc,%esp
  80274c:	89 1c 24             	mov    %ebx,(%esp)
  80274f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802753:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802757:	8b 7d 08             	mov    0x8(%ebp),%edi
  80275a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80275d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802760:	85 c9                	test   %ecx,%ecx
  802762:	74 30                	je     802794 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802764:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80276a:	75 25                	jne    802791 <memset+0x4b>
  80276c:	f6 c1 03             	test   $0x3,%cl
  80276f:	75 20                	jne    802791 <memset+0x4b>
		c &= 0xFF;
  802771:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802774:	89 d3                	mov    %edx,%ebx
  802776:	c1 e3 08             	shl    $0x8,%ebx
  802779:	89 d6                	mov    %edx,%esi
  80277b:	c1 e6 18             	shl    $0x18,%esi
  80277e:	89 d0                	mov    %edx,%eax
  802780:	c1 e0 10             	shl    $0x10,%eax
  802783:	09 f0                	or     %esi,%eax
  802785:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  802787:	09 d8                	or     %ebx,%eax
  802789:	c1 e9 02             	shr    $0x2,%ecx
  80278c:	fc                   	cld    
  80278d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80278f:	eb 03                	jmp    802794 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802791:	fc                   	cld    
  802792:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802794:	89 f8                	mov    %edi,%eax
  802796:	8b 1c 24             	mov    (%esp),%ebx
  802799:	8b 74 24 04          	mov    0x4(%esp),%esi
  80279d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8027a1:	89 ec                	mov    %ebp,%esp
  8027a3:	5d                   	pop    %ebp
  8027a4:	c3                   	ret    

008027a5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8027a5:	55                   	push   %ebp
  8027a6:	89 e5                	mov    %esp,%ebp
  8027a8:	83 ec 08             	sub    $0x8,%esp
  8027ab:	89 34 24             	mov    %esi,(%esp)
  8027ae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8027b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8027b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8027b8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8027bb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8027bd:	39 c6                	cmp    %eax,%esi
  8027bf:	73 35                	jae    8027f6 <memmove+0x51>
  8027c1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8027c4:	39 d0                	cmp    %edx,%eax
  8027c6:	73 2e                	jae    8027f6 <memmove+0x51>
		s += n;
		d += n;
  8027c8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8027ca:	f6 c2 03             	test   $0x3,%dl
  8027cd:	75 1b                	jne    8027ea <memmove+0x45>
  8027cf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8027d5:	75 13                	jne    8027ea <memmove+0x45>
  8027d7:	f6 c1 03             	test   $0x3,%cl
  8027da:	75 0e                	jne    8027ea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  8027dc:	83 ef 04             	sub    $0x4,%edi
  8027df:	8d 72 fc             	lea    -0x4(%edx),%esi
  8027e2:	c1 e9 02             	shr    $0x2,%ecx
  8027e5:	fd                   	std    
  8027e6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8027e8:	eb 09                	jmp    8027f3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8027ea:	83 ef 01             	sub    $0x1,%edi
  8027ed:	8d 72 ff             	lea    -0x1(%edx),%esi
  8027f0:	fd                   	std    
  8027f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8027f3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8027f4:	eb 20                	jmp    802816 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8027f6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8027fc:	75 15                	jne    802813 <memmove+0x6e>
  8027fe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802804:	75 0d                	jne    802813 <memmove+0x6e>
  802806:	f6 c1 03             	test   $0x3,%cl
  802809:	75 08                	jne    802813 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80280b:	c1 e9 02             	shr    $0x2,%ecx
  80280e:	fc                   	cld    
  80280f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802811:	eb 03                	jmp    802816 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802813:	fc                   	cld    
  802814:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802816:	8b 34 24             	mov    (%esp),%esi
  802819:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80281d:	89 ec                	mov    %ebp,%esp
  80281f:	5d                   	pop    %ebp
  802820:	c3                   	ret    

00802821 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  802821:	55                   	push   %ebp
  802822:	89 e5                	mov    %esp,%ebp
  802824:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802827:	8b 45 10             	mov    0x10(%ebp),%eax
  80282a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80282e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802831:	89 44 24 04          	mov    %eax,0x4(%esp)
  802835:	8b 45 08             	mov    0x8(%ebp),%eax
  802838:	89 04 24             	mov    %eax,(%esp)
  80283b:	e8 65 ff ff ff       	call   8027a5 <memmove>
}
  802840:	c9                   	leave  
  802841:	c3                   	ret    

00802842 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802842:	55                   	push   %ebp
  802843:	89 e5                	mov    %esp,%ebp
  802845:	57                   	push   %edi
  802846:	56                   	push   %esi
  802847:	53                   	push   %ebx
  802848:	8b 75 08             	mov    0x8(%ebp),%esi
  80284b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80284e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802851:	85 c9                	test   %ecx,%ecx
  802853:	74 36                	je     80288b <memcmp+0x49>
		if (*s1 != *s2)
  802855:	0f b6 06             	movzbl (%esi),%eax
  802858:	0f b6 1f             	movzbl (%edi),%ebx
  80285b:	38 d8                	cmp    %bl,%al
  80285d:	74 20                	je     80287f <memcmp+0x3d>
  80285f:	eb 14                	jmp    802875 <memcmp+0x33>
  802861:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  802866:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80286b:	83 c2 01             	add    $0x1,%edx
  80286e:	83 e9 01             	sub    $0x1,%ecx
  802871:	38 d8                	cmp    %bl,%al
  802873:	74 12                	je     802887 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802875:	0f b6 c0             	movzbl %al,%eax
  802878:	0f b6 db             	movzbl %bl,%ebx
  80287b:	29 d8                	sub    %ebx,%eax
  80287d:	eb 11                	jmp    802890 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80287f:	83 e9 01             	sub    $0x1,%ecx
  802882:	ba 00 00 00 00       	mov    $0x0,%edx
  802887:	85 c9                	test   %ecx,%ecx
  802889:	75 d6                	jne    802861 <memcmp+0x1f>
  80288b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802890:	5b                   	pop    %ebx
  802891:	5e                   	pop    %esi
  802892:	5f                   	pop    %edi
  802893:	5d                   	pop    %ebp
  802894:	c3                   	ret    

00802895 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802895:	55                   	push   %ebp
  802896:	89 e5                	mov    %esp,%ebp
  802898:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80289b:	89 c2                	mov    %eax,%edx
  80289d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8028a0:	39 d0                	cmp    %edx,%eax
  8028a2:	73 15                	jae    8028b9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8028a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8028a8:	38 08                	cmp    %cl,(%eax)
  8028aa:	75 06                	jne    8028b2 <memfind+0x1d>
  8028ac:	eb 0b                	jmp    8028b9 <memfind+0x24>
  8028ae:	38 08                	cmp    %cl,(%eax)
  8028b0:	74 07                	je     8028b9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8028b2:	83 c0 01             	add    $0x1,%eax
  8028b5:	39 c2                	cmp    %eax,%edx
  8028b7:	77 f5                	ja     8028ae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8028b9:	5d                   	pop    %ebp
  8028ba:	c3                   	ret    

008028bb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8028bb:	55                   	push   %ebp
  8028bc:	89 e5                	mov    %esp,%ebp
  8028be:	57                   	push   %edi
  8028bf:	56                   	push   %esi
  8028c0:	53                   	push   %ebx
  8028c1:	83 ec 04             	sub    $0x4,%esp
  8028c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8028c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8028ca:	0f b6 02             	movzbl (%edx),%eax
  8028cd:	3c 20                	cmp    $0x20,%al
  8028cf:	74 04                	je     8028d5 <strtol+0x1a>
  8028d1:	3c 09                	cmp    $0x9,%al
  8028d3:	75 0e                	jne    8028e3 <strtol+0x28>
		s++;
  8028d5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8028d8:	0f b6 02             	movzbl (%edx),%eax
  8028db:	3c 20                	cmp    $0x20,%al
  8028dd:	74 f6                	je     8028d5 <strtol+0x1a>
  8028df:	3c 09                	cmp    $0x9,%al
  8028e1:	74 f2                	je     8028d5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8028e3:	3c 2b                	cmp    $0x2b,%al
  8028e5:	75 0c                	jne    8028f3 <strtol+0x38>
		s++;
  8028e7:	83 c2 01             	add    $0x1,%edx
  8028ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8028f1:	eb 15                	jmp    802908 <strtol+0x4d>
	else if (*s == '-')
  8028f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8028fa:	3c 2d                	cmp    $0x2d,%al
  8028fc:	75 0a                	jne    802908 <strtol+0x4d>
		s++, neg = 1;
  8028fe:	83 c2 01             	add    $0x1,%edx
  802901:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802908:	85 db                	test   %ebx,%ebx
  80290a:	0f 94 c0             	sete   %al
  80290d:	74 05                	je     802914 <strtol+0x59>
  80290f:	83 fb 10             	cmp    $0x10,%ebx
  802912:	75 18                	jne    80292c <strtol+0x71>
  802914:	80 3a 30             	cmpb   $0x30,(%edx)
  802917:	75 13                	jne    80292c <strtol+0x71>
  802919:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80291d:	8d 76 00             	lea    0x0(%esi),%esi
  802920:	75 0a                	jne    80292c <strtol+0x71>
		s += 2, base = 16;
  802922:	83 c2 02             	add    $0x2,%edx
  802925:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80292a:	eb 15                	jmp    802941 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80292c:	84 c0                	test   %al,%al
  80292e:	66 90                	xchg   %ax,%ax
  802930:	74 0f                	je     802941 <strtol+0x86>
  802932:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802937:	80 3a 30             	cmpb   $0x30,(%edx)
  80293a:	75 05                	jne    802941 <strtol+0x86>
		s++, base = 8;
  80293c:	83 c2 01             	add    $0x1,%edx
  80293f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802941:	b8 00 00 00 00       	mov    $0x0,%eax
  802946:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802948:	0f b6 0a             	movzbl (%edx),%ecx
  80294b:	89 cf                	mov    %ecx,%edi
  80294d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802950:	80 fb 09             	cmp    $0x9,%bl
  802953:	77 08                	ja     80295d <strtol+0xa2>
			dig = *s - '0';
  802955:	0f be c9             	movsbl %cl,%ecx
  802958:	83 e9 30             	sub    $0x30,%ecx
  80295b:	eb 1e                	jmp    80297b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80295d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  802960:	80 fb 19             	cmp    $0x19,%bl
  802963:	77 08                	ja     80296d <strtol+0xb2>
			dig = *s - 'a' + 10;
  802965:	0f be c9             	movsbl %cl,%ecx
  802968:	83 e9 57             	sub    $0x57,%ecx
  80296b:	eb 0e                	jmp    80297b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80296d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802970:	80 fb 19             	cmp    $0x19,%bl
  802973:	77 15                	ja     80298a <strtol+0xcf>
			dig = *s - 'A' + 10;
  802975:	0f be c9             	movsbl %cl,%ecx
  802978:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80297b:	39 f1                	cmp    %esi,%ecx
  80297d:	7d 0b                	jge    80298a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80297f:	83 c2 01             	add    $0x1,%edx
  802982:	0f af c6             	imul   %esi,%eax
  802985:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802988:	eb be                	jmp    802948 <strtol+0x8d>
  80298a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80298c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802990:	74 05                	je     802997 <strtol+0xdc>
		*endptr = (char *) s;
  802992:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802995:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802997:	89 ca                	mov    %ecx,%edx
  802999:	f7 da                	neg    %edx
  80299b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80299f:	0f 45 c2             	cmovne %edx,%eax
}
  8029a2:	83 c4 04             	add    $0x4,%esp
  8029a5:	5b                   	pop    %ebx
  8029a6:	5e                   	pop    %esi
  8029a7:	5f                   	pop    %edi
  8029a8:	5d                   	pop    %ebp
  8029a9:	c3                   	ret    
	...

008029ac <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8029ac:	55                   	push   %ebp
  8029ad:	89 e5                	mov    %esp,%ebp
  8029af:	83 ec 48             	sub    $0x48,%esp
  8029b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8029b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8029b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8029bb:	89 c6                	mov    %eax,%esi
  8029bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8029c0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8029c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8029c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8029c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8029cb:	51                   	push   %ecx
  8029cc:	52                   	push   %edx
  8029cd:	53                   	push   %ebx
  8029ce:	54                   	push   %esp
  8029cf:	55                   	push   %ebp
  8029d0:	56                   	push   %esi
  8029d1:	57                   	push   %edi
  8029d2:	89 e5                	mov    %esp,%ebp
  8029d4:	8d 35 dc 29 80 00    	lea    0x8029dc,%esi
  8029da:	0f 34                	sysenter 

008029dc <.after_sysenter_label>:
  8029dc:	5f                   	pop    %edi
  8029dd:	5e                   	pop    %esi
  8029de:	5d                   	pop    %ebp
  8029df:	5c                   	pop    %esp
  8029e0:	5b                   	pop    %ebx
  8029e1:	5a                   	pop    %edx
  8029e2:	59                   	pop    %ecx
  8029e3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8029e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8029e9:	74 28                	je     802a13 <.after_sysenter_label+0x37>
  8029eb:	85 c0                	test   %eax,%eax
  8029ed:	7e 24                	jle    802a13 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  8029ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8029f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8029f7:	c7 44 24 08 20 44 80 	movl   $0x804420,0x8(%esp)
  8029fe:	00 
  8029ff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802a06:	00 
  802a07:	c7 04 24 3d 44 80 00 	movl   $0x80443d,(%esp)
  802a0e:	e8 b1 f3 ff ff       	call   801dc4 <_panic>

	return ret;
}
  802a13:	89 d0                	mov    %edx,%eax
  802a15:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802a18:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802a1b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802a1e:	89 ec                	mov    %ebp,%esp
  802a20:	5d                   	pop    %ebp
  802a21:	c3                   	ret    

00802a22 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  802a22:	55                   	push   %ebp
  802a23:	89 e5                	mov    %esp,%ebp
  802a25:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  802a28:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802a2f:	00 
  802a30:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802a37:	00 
  802a38:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802a3f:	00 
  802a40:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a4a:	ba 01 00 00 00       	mov    $0x1,%edx
  802a4f:	b8 0e 00 00 00       	mov    $0xe,%eax
  802a54:	e8 53 ff ff ff       	call   8029ac <syscall>
}
  802a59:	c9                   	leave  
  802a5a:	c3                   	ret    

00802a5b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802a5b:	55                   	push   %ebp
  802a5c:	89 e5                	mov    %esp,%ebp
  802a5e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  802a61:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802a68:	00 
  802a69:	8b 45 14             	mov    0x14(%ebp),%eax
  802a6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a70:	8b 45 10             	mov    0x10(%ebp),%eax
  802a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a77:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a7a:	89 04 24             	mov    %eax,(%esp)
  802a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a80:	ba 00 00 00 00       	mov    $0x0,%edx
  802a85:	b8 0d 00 00 00       	mov    $0xd,%eax
  802a8a:	e8 1d ff ff ff       	call   8029ac <syscall>
}
  802a8f:	c9                   	leave  
  802a90:	c3                   	ret    

00802a91 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802a91:	55                   	push   %ebp
  802a92:	89 e5                	mov    %esp,%ebp
  802a94:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  802a97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802a9e:	00 
  802a9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802aa6:	00 
  802aa7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802aae:	00 
  802aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ab2:	89 04 24             	mov    %eax,(%esp)
  802ab5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ab8:	ba 01 00 00 00       	mov    $0x1,%edx
  802abd:	b8 0b 00 00 00       	mov    $0xb,%eax
  802ac2:	e8 e5 fe ff ff       	call   8029ac <syscall>
}
  802ac7:	c9                   	leave  
  802ac8:	c3                   	ret    

00802ac9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802ac9:	55                   	push   %ebp
  802aca:	89 e5                	mov    %esp,%ebp
  802acc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  802acf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802ad6:	00 
  802ad7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802ade:	00 
  802adf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802ae6:	00 
  802ae7:	8b 45 0c             	mov    0xc(%ebp),%eax
  802aea:	89 04 24             	mov    %eax,(%esp)
  802aed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802af0:	ba 01 00 00 00       	mov    $0x1,%edx
  802af5:	b8 0a 00 00 00       	mov    $0xa,%eax
  802afa:	e8 ad fe ff ff       	call   8029ac <syscall>
}
  802aff:	c9                   	leave  
  802b00:	c3                   	ret    

00802b01 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802b01:	55                   	push   %ebp
  802b02:	89 e5                	mov    %esp,%ebp
  802b04:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  802b07:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802b0e:	00 
  802b0f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b16:	00 
  802b17:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802b1e:	00 
  802b1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b22:	89 04 24             	mov    %eax,(%esp)
  802b25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b28:	ba 01 00 00 00       	mov    $0x1,%edx
  802b2d:	b8 09 00 00 00       	mov    $0x9,%eax
  802b32:	e8 75 fe ff ff       	call   8029ac <syscall>
}
  802b37:	c9                   	leave  
  802b38:	c3                   	ret    

00802b39 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  802b39:	55                   	push   %ebp
  802b3a:	89 e5                	mov    %esp,%ebp
  802b3c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  802b3f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802b46:	00 
  802b47:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802b4e:	00 
  802b4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802b56:	00 
  802b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b5a:	89 04 24             	mov    %eax,(%esp)
  802b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b60:	ba 01 00 00 00       	mov    $0x1,%edx
  802b65:	b8 07 00 00 00       	mov    $0x7,%eax
  802b6a:	e8 3d fe ff ff       	call   8029ac <syscall>
}
  802b6f:	c9                   	leave  
  802b70:	c3                   	ret    

00802b71 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802b71:	55                   	push   %ebp
  802b72:	89 e5                	mov    %esp,%ebp
  802b74:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  802b77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802b7e:	00 
  802b7f:	8b 45 18             	mov    0x18(%ebp),%eax
  802b82:	0b 45 14             	or     0x14(%ebp),%eax
  802b85:	89 44 24 08          	mov    %eax,0x8(%esp)
  802b89:	8b 45 10             	mov    0x10(%ebp),%eax
  802b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b93:	89 04 24             	mov    %eax,(%esp)
  802b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802b99:	ba 01 00 00 00       	mov    $0x1,%edx
  802b9e:	b8 06 00 00 00       	mov    $0x6,%eax
  802ba3:	e8 04 fe ff ff       	call   8029ac <syscall>
}
  802ba8:	c9                   	leave  
  802ba9:	c3                   	ret    

00802baa <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802baa:	55                   	push   %ebp
  802bab:	89 e5                	mov    %esp,%ebp
  802bad:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  802bb0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802bb7:	00 
  802bb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802bbf:	00 
  802bc0:	8b 45 10             	mov    0x10(%ebp),%eax
  802bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802bc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  802bca:	89 04 24             	mov    %eax,(%esp)
  802bcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802bd0:	ba 01 00 00 00       	mov    $0x1,%edx
  802bd5:	b8 05 00 00 00       	mov    $0x5,%eax
  802bda:	e8 cd fd ff ff       	call   8029ac <syscall>
}
  802bdf:	c9                   	leave  
  802be0:	c3                   	ret    

00802be1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  802be1:	55                   	push   %ebp
  802be2:	89 e5                	mov    %esp,%ebp
  802be4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  802be7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802bee:	00 
  802bef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802bf6:	00 
  802bf7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802bfe:	00 
  802bff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c06:	b9 00 00 00 00       	mov    $0x0,%ecx
  802c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  802c10:	b8 0c 00 00 00       	mov    $0xc,%eax
  802c15:	e8 92 fd ff ff       	call   8029ac <syscall>
}
  802c1a:	c9                   	leave  
  802c1b:	c3                   	ret    

00802c1c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  802c1c:	55                   	push   %ebp
  802c1d:	89 e5                	mov    %esp,%ebp
  802c1f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  802c22:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802c29:	00 
  802c2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802c31:	00 
  802c32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802c39:	00 
  802c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c3d:	89 04 24             	mov    %eax,(%esp)
  802c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c43:	ba 00 00 00 00       	mov    $0x0,%edx
  802c48:	b8 04 00 00 00       	mov    $0x4,%eax
  802c4d:	e8 5a fd ff ff       	call   8029ac <syscall>
}
  802c52:	c9                   	leave  
  802c53:	c3                   	ret    

00802c54 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  802c54:	55                   	push   %ebp
  802c55:	89 e5                	mov    %esp,%ebp
  802c57:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  802c5a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802c61:	00 
  802c62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802c69:	00 
  802c6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802c71:	00 
  802c72:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802c79:	b9 00 00 00 00       	mov    $0x0,%ecx
  802c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  802c83:	b8 02 00 00 00       	mov    $0x2,%eax
  802c88:	e8 1f fd ff ff       	call   8029ac <syscall>
}
  802c8d:	c9                   	leave  
  802c8e:	c3                   	ret    

00802c8f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  802c8f:	55                   	push   %ebp
  802c90:	89 e5                	mov    %esp,%ebp
  802c92:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  802c95:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802c9c:	00 
  802c9d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802ca4:	00 
  802ca5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802cac:	00 
  802cad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802cb4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802cb7:	ba 01 00 00 00       	mov    $0x1,%edx
  802cbc:	b8 03 00 00 00       	mov    $0x3,%eax
  802cc1:	e8 e6 fc ff ff       	call   8029ac <syscall>
}
  802cc6:	c9                   	leave  
  802cc7:	c3                   	ret    

00802cc8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  802cc8:	55                   	push   %ebp
  802cc9:	89 e5                	mov    %esp,%ebp
  802ccb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  802cce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802cd5:	00 
  802cd6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802cdd:	00 
  802cde:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802ce5:	00 
  802ce6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ced:	b9 00 00 00 00       	mov    $0x0,%ecx
  802cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  802cf7:	b8 01 00 00 00       	mov    $0x1,%eax
  802cfc:	e8 ab fc ff ff       	call   8029ac <syscall>
}
  802d01:	c9                   	leave  
  802d02:	c3                   	ret    

00802d03 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802d03:	55                   	push   %ebp
  802d04:	89 e5                	mov    %esp,%ebp
  802d06:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  802d09:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802d10:	00 
  802d11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802d18:	00 
  802d19:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802d20:	00 
  802d21:	8b 45 0c             	mov    0xc(%ebp),%eax
  802d24:	89 04 24             	mov    %eax,(%esp)
  802d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  802d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  802d34:	e8 73 fc ff ff       	call   8029ac <syscall>
}
  802d39:	c9                   	leave  
  802d3a:	c3                   	ret    
	...

00802d3c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802d3c:	55                   	push   %ebp
  802d3d:	89 e5                	mov    %esp,%ebp
  802d3f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802d42:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802d49:	75 54                	jne    802d9f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  802d4b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802d52:	00 
  802d53:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802d5a:	ee 
  802d5b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d62:	e8 43 fe ff ff       	call   802baa <sys_page_alloc>
  802d67:	85 c0                	test   %eax,%eax
  802d69:	79 20                	jns    802d8b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  802d6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802d6f:	c7 44 24 08 4b 44 80 	movl   $0x80444b,0x8(%esp)
  802d76:	00 
  802d77:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802d7e:	00 
  802d7f:	c7 04 24 63 44 80 00 	movl   $0x804463,(%esp)
  802d86:	e8 39 f0 ff ff       	call   801dc4 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  802d8b:	c7 44 24 04 ac 2d 80 	movl   $0x802dac,0x4(%esp)
  802d92:	00 
  802d93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d9a:	e8 f2 fc ff ff       	call   802a91 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  802da2:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802da7:	c9                   	leave  
  802da8:	c3                   	ret    
  802da9:	00 00                	add    %al,(%eax)
	...

00802dac <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802dac:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802dad:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802db2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802db4:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  802db7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802dbb:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802dbe:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  802dc2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802dc6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802dc8:	83 c4 08             	add    $0x8,%esp
	popal
  802dcb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  802dcc:	83 c4 04             	add    $0x4,%esp
	popfl
  802dcf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802dd0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802dd1:	c3                   	ret    
	...

00802de0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802de0:	55                   	push   %ebp
  802de1:	89 e5                	mov    %esp,%ebp
  802de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802de6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  802dec:	b8 01 00 00 00       	mov    $0x1,%eax
  802df1:	39 ca                	cmp    %ecx,%edx
  802df3:	75 04                	jne    802df9 <ipc_find_env+0x19>
  802df5:	b0 00                	mov    $0x0,%al
  802df7:	eb 0f                	jmp    802e08 <ipc_find_env+0x28>
  802df9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802dfc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802e02:	8b 12                	mov    (%edx),%edx
  802e04:	39 ca                	cmp    %ecx,%edx
  802e06:	75 0c                	jne    802e14 <ipc_find_env+0x34>
			return envs[i].env_id;
  802e08:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802e0b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  802e10:	8b 00                	mov    (%eax),%eax
  802e12:	eb 0e                	jmp    802e22 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802e14:	83 c0 01             	add    $0x1,%eax
  802e17:	3d 00 04 00 00       	cmp    $0x400,%eax
  802e1c:	75 db                	jne    802df9 <ipc_find_env+0x19>
  802e1e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802e22:	5d                   	pop    %ebp
  802e23:	c3                   	ret    

00802e24 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802e24:	55                   	push   %ebp
  802e25:	89 e5                	mov    %esp,%ebp
  802e27:	57                   	push   %edi
  802e28:	56                   	push   %esi
  802e29:	53                   	push   %ebx
  802e2a:	83 ec 1c             	sub    $0x1c,%esp
  802e2d:	8b 75 08             	mov    0x8(%ebp),%esi
  802e30:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802e36:	85 db                	test   %ebx,%ebx
  802e38:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802e3d:	0f 44 d8             	cmove  %eax,%ebx
  802e40:	eb 29                	jmp    802e6b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  802e42:	85 c0                	test   %eax,%eax
  802e44:	79 25                	jns    802e6b <ipc_send+0x47>
  802e46:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802e49:	74 20                	je     802e6b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  802e4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e4f:	c7 44 24 08 71 44 80 	movl   $0x804471,0x8(%esp)
  802e56:	00 
  802e57:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  802e5e:	00 
  802e5f:	c7 04 24 8f 44 80 00 	movl   $0x80448f,(%esp)
  802e66:	e8 59 ef ff ff       	call   801dc4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  802e6b:	8b 45 14             	mov    0x14(%ebp),%eax
  802e6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e72:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802e76:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802e7a:	89 34 24             	mov    %esi,(%esp)
  802e7d:	e8 d9 fb ff ff       	call   802a5b <sys_ipc_try_send>
  802e82:	85 c0                	test   %eax,%eax
  802e84:	75 bc                	jne    802e42 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802e86:	e8 56 fd ff ff       	call   802be1 <sys_yield>
}
  802e8b:	83 c4 1c             	add    $0x1c,%esp
  802e8e:	5b                   	pop    %ebx
  802e8f:	5e                   	pop    %esi
  802e90:	5f                   	pop    %edi
  802e91:	5d                   	pop    %ebp
  802e92:	c3                   	ret    

00802e93 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802e93:	55                   	push   %ebp
  802e94:	89 e5                	mov    %esp,%ebp
  802e96:	83 ec 28             	sub    $0x28,%esp
  802e99:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802e9c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802e9f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802ea2:	8b 75 08             	mov    0x8(%ebp),%esi
  802ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ea8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802eab:	85 c0                	test   %eax,%eax
  802ead:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802eb2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802eb5:	89 04 24             	mov    %eax,(%esp)
  802eb8:	e8 65 fb ff ff       	call   802a22 <sys_ipc_recv>
  802ebd:	89 c3                	mov    %eax,%ebx
  802ebf:	85 c0                	test   %eax,%eax
  802ec1:	79 2a                	jns    802eed <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802ec3:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ecb:	c7 04 24 99 44 80 00 	movl   $0x804499,(%esp)
  802ed2:	e8 a6 ef ff ff       	call   801e7d <cprintf>
		if(from_env_store != NULL)
  802ed7:	85 f6                	test   %esi,%esi
  802ed9:	74 06                	je     802ee1 <ipc_recv+0x4e>
			*from_env_store = 0;
  802edb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802ee1:	85 ff                	test   %edi,%edi
  802ee3:	74 2d                	je     802f12 <ipc_recv+0x7f>
			*perm_store = 0;
  802ee5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802eeb:	eb 25                	jmp    802f12 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  802eed:	85 f6                	test   %esi,%esi
  802eef:	90                   	nop
  802ef0:	74 0a                	je     802efc <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  802ef2:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ef7:	8b 40 74             	mov    0x74(%eax),%eax
  802efa:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802efc:	85 ff                	test   %edi,%edi
  802efe:	74 0a                	je     802f0a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  802f00:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802f05:	8b 40 78             	mov    0x78(%eax),%eax
  802f08:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802f0a:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802f0f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802f12:	89 d8                	mov    %ebx,%eax
  802f14:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802f17:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802f1a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802f1d:	89 ec                	mov    %ebp,%esp
  802f1f:	5d                   	pop    %ebp
  802f20:	c3                   	ret    
	...

00802f30 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802f30:	55                   	push   %ebp
  802f31:	89 e5                	mov    %esp,%ebp
  802f33:	8b 45 08             	mov    0x8(%ebp),%eax
  802f36:	05 00 00 00 30       	add    $0x30000000,%eax
  802f3b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  802f3e:	5d                   	pop    %ebp
  802f3f:	c3                   	ret    

00802f40 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802f40:	55                   	push   %ebp
  802f41:	89 e5                	mov    %esp,%ebp
  802f43:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802f46:	8b 45 08             	mov    0x8(%ebp),%eax
  802f49:	89 04 24             	mov    %eax,(%esp)
  802f4c:	e8 df ff ff ff       	call   802f30 <fd2num>
  802f51:	05 20 00 0d 00       	add    $0xd0020,%eax
  802f56:	c1 e0 0c             	shl    $0xc,%eax
}
  802f59:	c9                   	leave  
  802f5a:	c3                   	ret    

00802f5b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802f5b:	55                   	push   %ebp
  802f5c:	89 e5                	mov    %esp,%ebp
  802f5e:	57                   	push   %edi
  802f5f:	56                   	push   %esi
  802f60:	53                   	push   %ebx
  802f61:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  802f64:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  802f69:	a8 01                	test   $0x1,%al
  802f6b:	74 36                	je     802fa3 <fd_alloc+0x48>
  802f6d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  802f72:	a8 01                	test   $0x1,%al
  802f74:	74 2d                	je     802fa3 <fd_alloc+0x48>
  802f76:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  802f7b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  802f80:	be 00 00 40 ef       	mov    $0xef400000,%esi
  802f85:	89 c3                	mov    %eax,%ebx
  802f87:	89 c2                	mov    %eax,%edx
  802f89:	c1 ea 16             	shr    $0x16,%edx
  802f8c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  802f8f:	f6 c2 01             	test   $0x1,%dl
  802f92:	74 14                	je     802fa8 <fd_alloc+0x4d>
  802f94:	89 c2                	mov    %eax,%edx
  802f96:	c1 ea 0c             	shr    $0xc,%edx
  802f99:	8b 14 96             	mov    (%esi,%edx,4),%edx
  802f9c:	f6 c2 01             	test   $0x1,%dl
  802f9f:	75 10                	jne    802fb1 <fd_alloc+0x56>
  802fa1:	eb 05                	jmp    802fa8 <fd_alloc+0x4d>
  802fa3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  802fa8:	89 1f                	mov    %ebx,(%edi)
  802faa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  802faf:	eb 17                	jmp    802fc8 <fd_alloc+0x6d>
  802fb1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802fb6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802fbb:	75 c8                	jne    802f85 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802fbd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802fc3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  802fc8:	5b                   	pop    %ebx
  802fc9:	5e                   	pop    %esi
  802fca:	5f                   	pop    %edi
  802fcb:	5d                   	pop    %ebp
  802fcc:	c3                   	ret    

00802fcd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802fcd:	55                   	push   %ebp
  802fce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  802fd3:	83 f8 1f             	cmp    $0x1f,%eax
  802fd6:	77 36                	ja     80300e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802fd8:	05 00 00 0d 00       	add    $0xd0000,%eax
  802fdd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  802fe0:	89 c2                	mov    %eax,%edx
  802fe2:	c1 ea 16             	shr    $0x16,%edx
  802fe5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802fec:	f6 c2 01             	test   $0x1,%dl
  802fef:	74 1d                	je     80300e <fd_lookup+0x41>
  802ff1:	89 c2                	mov    %eax,%edx
  802ff3:	c1 ea 0c             	shr    $0xc,%edx
  802ff6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802ffd:	f6 c2 01             	test   $0x1,%dl
  803000:	74 0c                	je     80300e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  803002:	8b 55 0c             	mov    0xc(%ebp),%edx
  803005:	89 02                	mov    %eax,(%edx)
  803007:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80300c:	eb 05                	jmp    803013 <fd_lookup+0x46>
  80300e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  803013:	5d                   	pop    %ebp
  803014:	c3                   	ret    

00803015 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  803015:	55                   	push   %ebp
  803016:	89 e5                	mov    %esp,%ebp
  803018:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80301b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80301e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803022:	8b 45 08             	mov    0x8(%ebp),%eax
  803025:	89 04 24             	mov    %eax,(%esp)
  803028:	e8 a0 ff ff ff       	call   802fcd <fd_lookup>
  80302d:	85 c0                	test   %eax,%eax
  80302f:	78 0e                	js     80303f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803031:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803034:	8b 55 0c             	mov    0xc(%ebp),%edx
  803037:	89 50 04             	mov    %edx,0x4(%eax)
  80303a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80303f:	c9                   	leave  
  803040:	c3                   	ret    

00803041 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  803041:	55                   	push   %ebp
  803042:	89 e5                	mov    %esp,%ebp
  803044:	56                   	push   %esi
  803045:	53                   	push   %ebx
  803046:	83 ec 10             	sub    $0x10,%esp
  803049:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80304c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80304f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  803054:	b8 68 90 80 00       	mov    $0x809068,%eax
  803059:	39 0d 68 90 80 00    	cmp    %ecx,0x809068
  80305f:	75 11                	jne    803072 <dev_lookup+0x31>
  803061:	eb 04                	jmp    803067 <dev_lookup+0x26>
  803063:	39 08                	cmp    %ecx,(%eax)
  803065:	75 10                	jne    803077 <dev_lookup+0x36>
			*dev = devtab[i];
  803067:	89 03                	mov    %eax,(%ebx)
  803069:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80306e:	66 90                	xchg   %ax,%ax
  803070:	eb 36                	jmp    8030a8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  803072:	be 2c 45 80 00       	mov    $0x80452c,%esi
  803077:	83 c2 01             	add    $0x1,%edx
  80307a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80307d:	85 c0                	test   %eax,%eax
  80307f:	75 e2                	jne    803063 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  803081:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803086:	8b 40 48             	mov    0x48(%eax),%eax
  803089:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80308d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803091:	c7 04 24 ac 44 80 00 	movl   $0x8044ac,(%esp)
  803098:	e8 e0 ed ff ff       	call   801e7d <cprintf>
	*dev = 0;
  80309d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8030a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8030a8:	83 c4 10             	add    $0x10,%esp
  8030ab:	5b                   	pop    %ebx
  8030ac:	5e                   	pop    %esi
  8030ad:	5d                   	pop    %ebp
  8030ae:	c3                   	ret    

008030af <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8030af:	55                   	push   %ebp
  8030b0:	89 e5                	mov    %esp,%ebp
  8030b2:	53                   	push   %ebx
  8030b3:	83 ec 24             	sub    $0x24,%esp
  8030b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8030c3:	89 04 24             	mov    %eax,(%esp)
  8030c6:	e8 02 ff ff ff       	call   802fcd <fd_lookup>
  8030cb:	85 c0                	test   %eax,%eax
  8030cd:	78 53                	js     803122 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030d9:	8b 00                	mov    (%eax),%eax
  8030db:	89 04 24             	mov    %eax,(%esp)
  8030de:	e8 5e ff ff ff       	call   803041 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030e3:	85 c0                	test   %eax,%eax
  8030e5:	78 3b                	js     803122 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8030e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8030ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030ef:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8030f3:	74 2d                	je     803122 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8030f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8030f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8030ff:	00 00 00 
	stat->st_isdir = 0;
  803102:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803109:	00 00 00 
	stat->st_dev = dev;
  80310c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80310f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  803115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803119:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80311c:	89 14 24             	mov    %edx,(%esp)
  80311f:	ff 50 14             	call   *0x14(%eax)
}
  803122:	83 c4 24             	add    $0x24,%esp
  803125:	5b                   	pop    %ebx
  803126:	5d                   	pop    %ebp
  803127:	c3                   	ret    

00803128 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  803128:	55                   	push   %ebp
  803129:	89 e5                	mov    %esp,%ebp
  80312b:	53                   	push   %ebx
  80312c:	83 ec 24             	sub    $0x24,%esp
  80312f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803132:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803135:	89 44 24 04          	mov    %eax,0x4(%esp)
  803139:	89 1c 24             	mov    %ebx,(%esp)
  80313c:	e8 8c fe ff ff       	call   802fcd <fd_lookup>
  803141:	85 c0                	test   %eax,%eax
  803143:	78 5f                	js     8031a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803145:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803148:	89 44 24 04          	mov    %eax,0x4(%esp)
  80314c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80314f:	8b 00                	mov    (%eax),%eax
  803151:	89 04 24             	mov    %eax,(%esp)
  803154:	e8 e8 fe ff ff       	call   803041 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803159:	85 c0                	test   %eax,%eax
  80315b:	78 47                	js     8031a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80315d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803160:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  803164:	75 23                	jne    803189 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  803166:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80316b:	8b 40 48             	mov    0x48(%eax),%eax
  80316e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803172:	89 44 24 04          	mov    %eax,0x4(%esp)
  803176:	c7 04 24 cc 44 80 00 	movl   $0x8044cc,(%esp)
  80317d:	e8 fb ec ff ff       	call   801e7d <cprintf>
  803182:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  803187:	eb 1b                	jmp    8031a4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  803189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80318c:	8b 48 18             	mov    0x18(%eax),%ecx
  80318f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803194:	85 c9                	test   %ecx,%ecx
  803196:	74 0c                	je     8031a4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  803198:	8b 45 0c             	mov    0xc(%ebp),%eax
  80319b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80319f:	89 14 24             	mov    %edx,(%esp)
  8031a2:	ff d1                	call   *%ecx
}
  8031a4:	83 c4 24             	add    $0x24,%esp
  8031a7:	5b                   	pop    %ebx
  8031a8:	5d                   	pop    %ebp
  8031a9:	c3                   	ret    

008031aa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8031aa:	55                   	push   %ebp
  8031ab:	89 e5                	mov    %esp,%ebp
  8031ad:	53                   	push   %ebx
  8031ae:	83 ec 24             	sub    $0x24,%esp
  8031b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8031b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031bb:	89 1c 24             	mov    %ebx,(%esp)
  8031be:	e8 0a fe ff ff       	call   802fcd <fd_lookup>
  8031c3:	85 c0                	test   %eax,%eax
  8031c5:	78 66                	js     80322d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8031c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8031d1:	8b 00                	mov    (%eax),%eax
  8031d3:	89 04 24             	mov    %eax,(%esp)
  8031d6:	e8 66 fe ff ff       	call   803041 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8031db:	85 c0                	test   %eax,%eax
  8031dd:	78 4e                	js     80322d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8031df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8031e2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8031e6:	75 23                	jne    80320b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8031e8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8031ed:	8b 40 48             	mov    0x48(%eax),%eax
  8031f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8031f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031f8:	c7 04 24 f0 44 80 00 	movl   $0x8044f0,(%esp)
  8031ff:	e8 79 ec ff ff       	call   801e7d <cprintf>
  803204:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  803209:	eb 22                	jmp    80322d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80320b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80320e:	8b 48 0c             	mov    0xc(%eax),%ecx
  803211:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803216:	85 c9                	test   %ecx,%ecx
  803218:	74 13                	je     80322d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80321a:	8b 45 10             	mov    0x10(%ebp),%eax
  80321d:	89 44 24 08          	mov    %eax,0x8(%esp)
  803221:	8b 45 0c             	mov    0xc(%ebp),%eax
  803224:	89 44 24 04          	mov    %eax,0x4(%esp)
  803228:	89 14 24             	mov    %edx,(%esp)
  80322b:	ff d1                	call   *%ecx
}
  80322d:	83 c4 24             	add    $0x24,%esp
  803230:	5b                   	pop    %ebx
  803231:	5d                   	pop    %ebp
  803232:	c3                   	ret    

00803233 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  803233:	55                   	push   %ebp
  803234:	89 e5                	mov    %esp,%ebp
  803236:	53                   	push   %ebx
  803237:	83 ec 24             	sub    $0x24,%esp
  80323a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80323d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803240:	89 44 24 04          	mov    %eax,0x4(%esp)
  803244:	89 1c 24             	mov    %ebx,(%esp)
  803247:	e8 81 fd ff ff       	call   802fcd <fd_lookup>
  80324c:	85 c0                	test   %eax,%eax
  80324e:	78 6b                	js     8032bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803250:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803253:	89 44 24 04          	mov    %eax,0x4(%esp)
  803257:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80325a:	8b 00                	mov    (%eax),%eax
  80325c:	89 04 24             	mov    %eax,(%esp)
  80325f:	e8 dd fd ff ff       	call   803041 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803264:	85 c0                	test   %eax,%eax
  803266:	78 53                	js     8032bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  803268:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80326b:	8b 42 08             	mov    0x8(%edx),%eax
  80326e:	83 e0 03             	and    $0x3,%eax
  803271:	83 f8 01             	cmp    $0x1,%eax
  803274:	75 23                	jne    803299 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  803276:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80327b:	8b 40 48             	mov    0x48(%eax),%eax
  80327e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803282:	89 44 24 04          	mov    %eax,0x4(%esp)
  803286:	c7 04 24 0d 45 80 00 	movl   $0x80450d,(%esp)
  80328d:	e8 eb eb ff ff       	call   801e7d <cprintf>
  803292:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  803297:	eb 22                	jmp    8032bb <read+0x88>
	}
	if (!dev->dev_read)
  803299:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80329c:	8b 48 08             	mov    0x8(%eax),%ecx
  80329f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8032a4:	85 c9                	test   %ecx,%ecx
  8032a6:	74 13                	je     8032bb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8032a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8032ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8032af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8032b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8032b6:	89 14 24             	mov    %edx,(%esp)
  8032b9:	ff d1                	call   *%ecx
}
  8032bb:	83 c4 24             	add    $0x24,%esp
  8032be:	5b                   	pop    %ebx
  8032bf:	5d                   	pop    %ebp
  8032c0:	c3                   	ret    

008032c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8032c1:	55                   	push   %ebp
  8032c2:	89 e5                	mov    %esp,%ebp
  8032c4:	57                   	push   %edi
  8032c5:	56                   	push   %esi
  8032c6:	53                   	push   %ebx
  8032c7:	83 ec 1c             	sub    $0x1c,%esp
  8032ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8032cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8032d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8032d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8032da:	b8 00 00 00 00       	mov    $0x0,%eax
  8032df:	85 f6                	test   %esi,%esi
  8032e1:	74 29                	je     80330c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8032e3:	89 f0                	mov    %esi,%eax
  8032e5:	29 d0                	sub    %edx,%eax
  8032e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8032eb:	03 55 0c             	add    0xc(%ebp),%edx
  8032ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8032f2:	89 3c 24             	mov    %edi,(%esp)
  8032f5:	e8 39 ff ff ff       	call   803233 <read>
		if (m < 0)
  8032fa:	85 c0                	test   %eax,%eax
  8032fc:	78 0e                	js     80330c <readn+0x4b>
			return m;
		if (m == 0)
  8032fe:	85 c0                	test   %eax,%eax
  803300:	74 08                	je     80330a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  803302:	01 c3                	add    %eax,%ebx
  803304:	89 da                	mov    %ebx,%edx
  803306:	39 f3                	cmp    %esi,%ebx
  803308:	72 d9                	jb     8032e3 <readn+0x22>
  80330a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80330c:	83 c4 1c             	add    $0x1c,%esp
  80330f:	5b                   	pop    %ebx
  803310:	5e                   	pop    %esi
  803311:	5f                   	pop    %edi
  803312:	5d                   	pop    %ebp
  803313:	c3                   	ret    

00803314 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  803314:	55                   	push   %ebp
  803315:	89 e5                	mov    %esp,%ebp
  803317:	83 ec 28             	sub    $0x28,%esp
  80331a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80331d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  803320:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  803323:	89 34 24             	mov    %esi,(%esp)
  803326:	e8 05 fc ff ff       	call   802f30 <fd2num>
  80332b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80332e:	89 54 24 04          	mov    %edx,0x4(%esp)
  803332:	89 04 24             	mov    %eax,(%esp)
  803335:	e8 93 fc ff ff       	call   802fcd <fd_lookup>
  80333a:	89 c3                	mov    %eax,%ebx
  80333c:	85 c0                	test   %eax,%eax
  80333e:	78 05                	js     803345 <fd_close+0x31>
  803340:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  803343:	74 0e                	je     803353 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  803345:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803349:	b8 00 00 00 00       	mov    $0x0,%eax
  80334e:	0f 44 d8             	cmove  %eax,%ebx
  803351:	eb 3d                	jmp    803390 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  803353:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803356:	89 44 24 04          	mov    %eax,0x4(%esp)
  80335a:	8b 06                	mov    (%esi),%eax
  80335c:	89 04 24             	mov    %eax,(%esp)
  80335f:	e8 dd fc ff ff       	call   803041 <dev_lookup>
  803364:	89 c3                	mov    %eax,%ebx
  803366:	85 c0                	test   %eax,%eax
  803368:	78 16                	js     803380 <fd_close+0x6c>
		if (dev->dev_close)
  80336a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80336d:	8b 40 10             	mov    0x10(%eax),%eax
  803370:	bb 00 00 00 00       	mov    $0x0,%ebx
  803375:	85 c0                	test   %eax,%eax
  803377:	74 07                	je     803380 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  803379:	89 34 24             	mov    %esi,(%esp)
  80337c:	ff d0                	call   *%eax
  80337e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  803380:	89 74 24 04          	mov    %esi,0x4(%esp)
  803384:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80338b:	e8 a9 f7 ff ff       	call   802b39 <sys_page_unmap>
	return r;
}
  803390:	89 d8                	mov    %ebx,%eax
  803392:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803395:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803398:	89 ec                	mov    %ebp,%esp
  80339a:	5d                   	pop    %ebp
  80339b:	c3                   	ret    

0080339c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80339c:	55                   	push   %ebp
  80339d:	89 e5                	mov    %esp,%ebp
  80339f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8033a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8033a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8033ac:	89 04 24             	mov    %eax,(%esp)
  8033af:	e8 19 fc ff ff       	call   802fcd <fd_lookup>
  8033b4:	85 c0                	test   %eax,%eax
  8033b6:	78 13                	js     8033cb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8033b8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8033bf:	00 
  8033c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033c3:	89 04 24             	mov    %eax,(%esp)
  8033c6:	e8 49 ff ff ff       	call   803314 <fd_close>
}
  8033cb:	c9                   	leave  
  8033cc:	c3                   	ret    

008033cd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8033cd:	55                   	push   %ebp
  8033ce:	89 e5                	mov    %esp,%ebp
  8033d0:	83 ec 18             	sub    $0x18,%esp
  8033d3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8033d6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8033d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8033e0:	00 
  8033e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8033e4:	89 04 24             	mov    %eax,(%esp)
  8033e7:	e8 78 03 00 00       	call   803764 <open>
  8033ec:	89 c3                	mov    %eax,%ebx
  8033ee:	85 c0                	test   %eax,%eax
  8033f0:	78 1b                	js     80340d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8033f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8033f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8033f9:	89 1c 24             	mov    %ebx,(%esp)
  8033fc:	e8 ae fc ff ff       	call   8030af <fstat>
  803401:	89 c6                	mov    %eax,%esi
	close(fd);
  803403:	89 1c 24             	mov    %ebx,(%esp)
  803406:	e8 91 ff ff ff       	call   80339c <close>
  80340b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80340d:	89 d8                	mov    %ebx,%eax
  80340f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803412:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803415:	89 ec                	mov    %ebp,%esp
  803417:	5d                   	pop    %ebp
  803418:	c3                   	ret    

00803419 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  803419:	55                   	push   %ebp
  80341a:	89 e5                	mov    %esp,%ebp
  80341c:	53                   	push   %ebx
  80341d:	83 ec 14             	sub    $0x14,%esp
  803420:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  803425:	89 1c 24             	mov    %ebx,(%esp)
  803428:	e8 6f ff ff ff       	call   80339c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80342d:	83 c3 01             	add    $0x1,%ebx
  803430:	83 fb 20             	cmp    $0x20,%ebx
  803433:	75 f0                	jne    803425 <close_all+0xc>
		close(i);
}
  803435:	83 c4 14             	add    $0x14,%esp
  803438:	5b                   	pop    %ebx
  803439:	5d                   	pop    %ebp
  80343a:	c3                   	ret    

0080343b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80343b:	55                   	push   %ebp
  80343c:	89 e5                	mov    %esp,%ebp
  80343e:	83 ec 58             	sub    $0x58,%esp
  803441:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  803444:	89 75 f8             	mov    %esi,-0x8(%ebp)
  803447:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80344a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80344d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803450:	89 44 24 04          	mov    %eax,0x4(%esp)
  803454:	8b 45 08             	mov    0x8(%ebp),%eax
  803457:	89 04 24             	mov    %eax,(%esp)
  80345a:	e8 6e fb ff ff       	call   802fcd <fd_lookup>
  80345f:	89 c3                	mov    %eax,%ebx
  803461:	85 c0                	test   %eax,%eax
  803463:	0f 88 e0 00 00 00    	js     803549 <dup+0x10e>
		return r;
	close(newfdnum);
  803469:	89 3c 24             	mov    %edi,(%esp)
  80346c:	e8 2b ff ff ff       	call   80339c <close>

	newfd = INDEX2FD(newfdnum);
  803471:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  803477:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80347a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80347d:	89 04 24             	mov    %eax,(%esp)
  803480:	e8 bb fa ff ff       	call   802f40 <fd2data>
  803485:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  803487:	89 34 24             	mov    %esi,(%esp)
  80348a:	e8 b1 fa ff ff       	call   802f40 <fd2data>
  80348f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  803492:	89 da                	mov    %ebx,%edx
  803494:	89 d8                	mov    %ebx,%eax
  803496:	c1 e8 16             	shr    $0x16,%eax
  803499:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8034a0:	a8 01                	test   $0x1,%al
  8034a2:	74 43                	je     8034e7 <dup+0xac>
  8034a4:	c1 ea 0c             	shr    $0xc,%edx
  8034a7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8034ae:	a8 01                	test   $0x1,%al
  8034b0:	74 35                	je     8034e7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8034b2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8034b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8034be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8034c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8034c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8034c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8034d0:	00 
  8034d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8034d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034dc:	e8 90 f6 ff ff       	call   802b71 <sys_page_map>
  8034e1:	89 c3                	mov    %eax,%ebx
  8034e3:	85 c0                	test   %eax,%eax
  8034e5:	78 3f                	js     803526 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8034e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034ea:	89 c2                	mov    %eax,%edx
  8034ec:	c1 ea 0c             	shr    $0xc,%edx
  8034ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8034f6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8034fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  803500:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803504:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80350b:	00 
  80350c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803510:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803517:	e8 55 f6 ff ff       	call   802b71 <sys_page_map>
  80351c:	89 c3                	mov    %eax,%ebx
  80351e:	85 c0                	test   %eax,%eax
  803520:	78 04                	js     803526 <dup+0xeb>
  803522:	89 fb                	mov    %edi,%ebx
  803524:	eb 23                	jmp    803549 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  803526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80352a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803531:	e8 03 f6 ff ff       	call   802b39 <sys_page_unmap>
	sys_page_unmap(0, nva);
  803536:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803539:	89 44 24 04          	mov    %eax,0x4(%esp)
  80353d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803544:	e8 f0 f5 ff ff       	call   802b39 <sys_page_unmap>
	return r;
}
  803549:	89 d8                	mov    %ebx,%eax
  80354b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80354e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  803551:	8b 7d fc             	mov    -0x4(%ebp),%edi
  803554:	89 ec                	mov    %ebp,%esp
  803556:	5d                   	pop    %ebp
  803557:	c3                   	ret    

00803558 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803558:	55                   	push   %ebp
  803559:	89 e5                	mov    %esp,%ebp
  80355b:	83 ec 18             	sub    $0x18,%esp
  80355e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803561:	89 75 fc             	mov    %esi,-0x4(%ebp)
  803564:	89 c3                	mov    %eax,%ebx
  803566:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  803568:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  80356f:	75 11                	jne    803582 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803571:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  803578:	e8 63 f8 ff ff       	call   802de0 <ipc_find_env>
  80357d:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  803582:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  803589:	00 
  80358a:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  803591:	00 
  803592:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803596:	a1 00 a0 80 00       	mov    0x80a000,%eax
  80359b:	89 04 24             	mov    %eax,(%esp)
  80359e:	e8 81 f8 ff ff       	call   802e24 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8035a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8035aa:	00 
  8035ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8035af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8035b6:	e8 d8 f8 ff ff       	call   802e93 <ipc_recv>
}
  8035bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8035be:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8035c1:	89 ec                	mov    %ebp,%esp
  8035c3:	5d                   	pop    %ebp
  8035c4:	c3                   	ret    

008035c5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8035c5:	55                   	push   %ebp
  8035c6:	89 e5                	mov    %esp,%ebp
  8035c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8035cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8035ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8035d1:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  8035d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8035d9:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8035de:	ba 00 00 00 00       	mov    $0x0,%edx
  8035e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8035e8:	e8 6b ff ff ff       	call   803558 <fsipc>
}
  8035ed:	c9                   	leave  
  8035ee:	c3                   	ret    

008035ef <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8035ef:	55                   	push   %ebp
  8035f0:	89 e5                	mov    %esp,%ebp
  8035f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8035f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8035f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8035fb:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  803600:	ba 00 00 00 00       	mov    $0x0,%edx
  803605:	b8 06 00 00 00       	mov    $0x6,%eax
  80360a:	e8 49 ff ff ff       	call   803558 <fsipc>
}
  80360f:	c9                   	leave  
  803610:	c3                   	ret    

00803611 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  803611:	55                   	push   %ebp
  803612:	89 e5                	mov    %esp,%ebp
  803614:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803617:	ba 00 00 00 00       	mov    $0x0,%edx
  80361c:	b8 08 00 00 00       	mov    $0x8,%eax
  803621:	e8 32 ff ff ff       	call   803558 <fsipc>
}
  803626:	c9                   	leave  
  803627:	c3                   	ret    

00803628 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  803628:	55                   	push   %ebp
  803629:	89 e5                	mov    %esp,%ebp
  80362b:	53                   	push   %ebx
  80362c:	83 ec 14             	sub    $0x14,%esp
  80362f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803632:	8b 45 08             	mov    0x8(%ebp),%eax
  803635:	8b 40 0c             	mov    0xc(%eax),%eax
  803638:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80363d:	ba 00 00 00 00       	mov    $0x0,%edx
  803642:	b8 05 00 00 00       	mov    $0x5,%eax
  803647:	e8 0c ff ff ff       	call   803558 <fsipc>
  80364c:	85 c0                	test   %eax,%eax
  80364e:	78 2b                	js     80367b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803650:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803657:	00 
  803658:	89 1c 24             	mov    %ebx,(%esp)
  80365b:	e8 5a ef ff ff       	call   8025ba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803660:	a1 80 b0 80 00       	mov    0x80b080,%eax
  803665:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80366b:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803670:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  803676:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80367b:	83 c4 14             	add    $0x14,%esp
  80367e:	5b                   	pop    %ebx
  80367f:	5d                   	pop    %ebp
  803680:	c3                   	ret    

00803681 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803681:	55                   	push   %ebp
  803682:	89 e5                	mov    %esp,%ebp
  803684:	83 ec 18             	sub    $0x18,%esp
  803687:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80368a:	8b 55 08             	mov    0x8(%ebp),%edx
  80368d:	8b 52 0c             	mov    0xc(%edx),%edx
  803690:	89 15 00 b0 80 00    	mov    %edx,0x80b000
  fsipcbuf.write.req_n = n;
  803696:	a3 04 b0 80 00       	mov    %eax,0x80b004
  memmove(fsipcbuf.write.req_buf, buf,
  80369b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8036a0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8036a5:	0f 47 c2             	cmova  %edx,%eax
  8036a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8036ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8036af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036b3:	c7 04 24 08 b0 80 00 	movl   $0x80b008,(%esp)
  8036ba:	e8 e6 f0 ff ff       	call   8027a5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8036bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8036c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8036c9:	e8 8a fe ff ff       	call   803558 <fsipc>
}
  8036ce:	c9                   	leave  
  8036cf:	c3                   	ret    

008036d0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8036d0:	55                   	push   %ebp
  8036d1:	89 e5                	mov    %esp,%ebp
  8036d3:	53                   	push   %ebx
  8036d4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8036d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8036da:	8b 40 0c             	mov    0xc(%eax),%eax
  8036dd:	a3 00 b0 80 00       	mov    %eax,0x80b000
  fsipcbuf.read.req_n = n;
  8036e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8036e5:	a3 04 b0 80 00       	mov    %eax,0x80b004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8036ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8036ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8036f4:	e8 5f fe ff ff       	call   803558 <fsipc>
  8036f9:	89 c3                	mov    %eax,%ebx
  8036fb:	85 c0                	test   %eax,%eax
  8036fd:	78 17                	js     803716 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8036ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  803703:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  80370a:	00 
  80370b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80370e:	89 04 24             	mov    %eax,(%esp)
  803711:	e8 8f f0 ff ff       	call   8027a5 <memmove>
  return r;	
}
  803716:	89 d8                	mov    %ebx,%eax
  803718:	83 c4 14             	add    $0x14,%esp
  80371b:	5b                   	pop    %ebx
  80371c:	5d                   	pop    %ebp
  80371d:	c3                   	ret    

0080371e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80371e:	55                   	push   %ebp
  80371f:	89 e5                	mov    %esp,%ebp
  803721:	53                   	push   %ebx
  803722:	83 ec 14             	sub    $0x14,%esp
  803725:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  803728:	89 1c 24             	mov    %ebx,(%esp)
  80372b:	e8 40 ee ff ff       	call   802570 <strlen>
  803730:	89 c2                	mov    %eax,%edx
  803732:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  803737:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80373d:	7f 1f                	jg     80375e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80373f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803743:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  80374a:	e8 6b ee ff ff       	call   8025ba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80374f:	ba 00 00 00 00       	mov    $0x0,%edx
  803754:	b8 07 00 00 00       	mov    $0x7,%eax
  803759:	e8 fa fd ff ff       	call   803558 <fsipc>
}
  80375e:	83 c4 14             	add    $0x14,%esp
  803761:	5b                   	pop    %ebx
  803762:	5d                   	pop    %ebp
  803763:	c3                   	ret    

00803764 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803764:	55                   	push   %ebp
  803765:	89 e5                	mov    %esp,%ebp
  803767:	83 ec 28             	sub    $0x28,%esp
  80376a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80376d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  803770:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  803773:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803776:	89 04 24             	mov    %eax,(%esp)
  803779:	e8 dd f7 ff ff       	call   802f5b <fd_alloc>
  80377e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  803780:	85 c0                	test   %eax,%eax
  803782:	0f 88 89 00 00 00    	js     803811 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  803788:	89 34 24             	mov    %esi,(%esp)
  80378b:	e8 e0 ed ff ff       	call   802570 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  803790:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  803795:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80379a:	7f 75                	jg     803811 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80379c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037a0:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  8037a7:	e8 0e ee ff ff       	call   8025ba <strcpy>
  fsipcbuf.open.req_omode = mode;
  8037ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037af:	a3 00 b4 80 00       	mov    %eax,0x80b400
  r = fsipc(FSREQ_OPEN, fd);
  8037b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8037b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8037bc:	e8 97 fd ff ff       	call   803558 <fsipc>
  8037c1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8037c3:	85 c0                	test   %eax,%eax
  8037c5:	78 0f                	js     8037d6 <open+0x72>
  return fd2num(fd);
  8037c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037ca:	89 04 24             	mov    %eax,(%esp)
  8037cd:	e8 5e f7 ff ff       	call   802f30 <fd2num>
  8037d2:	89 c3                	mov    %eax,%ebx
  8037d4:	eb 3b                	jmp    803811 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8037d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8037dd:	00 
  8037de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037e1:	89 04 24             	mov    %eax,(%esp)
  8037e4:	e8 2b fb ff ff       	call   803314 <fd_close>
  8037e9:	85 c0                	test   %eax,%eax
  8037eb:	74 24                	je     803811 <open+0xad>
  8037ed:	c7 44 24 0c 34 45 80 	movl   $0x804534,0xc(%esp)
  8037f4:	00 
  8037f5:	c7 44 24 08 ed 3a 80 	movl   $0x803aed,0x8(%esp)
  8037fc:	00 
  8037fd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  803804:	00 
  803805:	c7 04 24 49 45 80 00 	movl   $0x804549,(%esp)
  80380c:	e8 b3 e5 ff ff       	call   801dc4 <_panic>
  return r;
}
  803811:	89 d8                	mov    %ebx,%eax
  803813:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803816:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803819:	89 ec                	mov    %ebp,%esp
  80381b:	5d                   	pop    %ebp
  80381c:	c3                   	ret    
  80381d:	00 00                	add    %al,(%eax)
	...

00803820 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803820:	55                   	push   %ebp
  803821:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  803823:	8b 45 08             	mov    0x8(%ebp),%eax
  803826:	89 c2                	mov    %eax,%edx
  803828:	c1 ea 16             	shr    $0x16,%edx
  80382b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803832:	f6 c2 01             	test   $0x1,%dl
  803835:	74 20                	je     803857 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  803837:	c1 e8 0c             	shr    $0xc,%eax
  80383a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803841:	a8 01                	test   $0x1,%al
  803843:	74 12                	je     803857 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803845:	c1 e8 0c             	shr    $0xc,%eax
  803848:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  80384d:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  803852:	0f b7 c0             	movzwl %ax,%eax
  803855:	eb 05                	jmp    80385c <pageref+0x3c>
  803857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80385c:	5d                   	pop    %ebp
  80385d:	c3                   	ret    
	...

00803860 <__udivdi3>:
  803860:	55                   	push   %ebp
  803861:	89 e5                	mov    %esp,%ebp
  803863:	57                   	push   %edi
  803864:	56                   	push   %esi
  803865:	83 ec 10             	sub    $0x10,%esp
  803868:	8b 45 14             	mov    0x14(%ebp),%eax
  80386b:	8b 55 08             	mov    0x8(%ebp),%edx
  80386e:	8b 75 10             	mov    0x10(%ebp),%esi
  803871:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803874:	85 c0                	test   %eax,%eax
  803876:	89 55 f0             	mov    %edx,-0x10(%ebp)
  803879:	75 35                	jne    8038b0 <__udivdi3+0x50>
  80387b:	39 fe                	cmp    %edi,%esi
  80387d:	77 61                	ja     8038e0 <__udivdi3+0x80>
  80387f:	85 f6                	test   %esi,%esi
  803881:	75 0b                	jne    80388e <__udivdi3+0x2e>
  803883:	b8 01 00 00 00       	mov    $0x1,%eax
  803888:	31 d2                	xor    %edx,%edx
  80388a:	f7 f6                	div    %esi
  80388c:	89 c6                	mov    %eax,%esi
  80388e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  803891:	31 d2                	xor    %edx,%edx
  803893:	89 f8                	mov    %edi,%eax
  803895:	f7 f6                	div    %esi
  803897:	89 c7                	mov    %eax,%edi
  803899:	89 c8                	mov    %ecx,%eax
  80389b:	f7 f6                	div    %esi
  80389d:	89 c1                	mov    %eax,%ecx
  80389f:	89 fa                	mov    %edi,%edx
  8038a1:	89 c8                	mov    %ecx,%eax
  8038a3:	83 c4 10             	add    $0x10,%esp
  8038a6:	5e                   	pop    %esi
  8038a7:	5f                   	pop    %edi
  8038a8:	5d                   	pop    %ebp
  8038a9:	c3                   	ret    
  8038aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8038b0:	39 f8                	cmp    %edi,%eax
  8038b2:	77 1c                	ja     8038d0 <__udivdi3+0x70>
  8038b4:	0f bd d0             	bsr    %eax,%edx
  8038b7:	83 f2 1f             	xor    $0x1f,%edx
  8038ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8038bd:	75 39                	jne    8038f8 <__udivdi3+0x98>
  8038bf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8038c2:	0f 86 a0 00 00 00    	jbe    803968 <__udivdi3+0x108>
  8038c8:	39 f8                	cmp    %edi,%eax
  8038ca:	0f 82 98 00 00 00    	jb     803968 <__udivdi3+0x108>
  8038d0:	31 ff                	xor    %edi,%edi
  8038d2:	31 c9                	xor    %ecx,%ecx
  8038d4:	89 c8                	mov    %ecx,%eax
  8038d6:	89 fa                	mov    %edi,%edx
  8038d8:	83 c4 10             	add    $0x10,%esp
  8038db:	5e                   	pop    %esi
  8038dc:	5f                   	pop    %edi
  8038dd:	5d                   	pop    %ebp
  8038de:	c3                   	ret    
  8038df:	90                   	nop
  8038e0:	89 d1                	mov    %edx,%ecx
  8038e2:	89 fa                	mov    %edi,%edx
  8038e4:	89 c8                	mov    %ecx,%eax
  8038e6:	31 ff                	xor    %edi,%edi
  8038e8:	f7 f6                	div    %esi
  8038ea:	89 c1                	mov    %eax,%ecx
  8038ec:	89 fa                	mov    %edi,%edx
  8038ee:	89 c8                	mov    %ecx,%eax
  8038f0:	83 c4 10             	add    $0x10,%esp
  8038f3:	5e                   	pop    %esi
  8038f4:	5f                   	pop    %edi
  8038f5:	5d                   	pop    %ebp
  8038f6:	c3                   	ret    
  8038f7:	90                   	nop
  8038f8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8038fc:	89 f2                	mov    %esi,%edx
  8038fe:	d3 e0                	shl    %cl,%eax
  803900:	89 45 ec             	mov    %eax,-0x14(%ebp)
  803903:	b8 20 00 00 00       	mov    $0x20,%eax
  803908:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80390b:	89 c1                	mov    %eax,%ecx
  80390d:	d3 ea                	shr    %cl,%edx
  80390f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803913:	0b 55 ec             	or     -0x14(%ebp),%edx
  803916:	d3 e6                	shl    %cl,%esi
  803918:	89 c1                	mov    %eax,%ecx
  80391a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80391d:	89 fe                	mov    %edi,%esi
  80391f:	d3 ee                	shr    %cl,%esi
  803921:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  803925:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803928:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80392b:	d3 e7                	shl    %cl,%edi
  80392d:	89 c1                	mov    %eax,%ecx
  80392f:	d3 ea                	shr    %cl,%edx
  803931:	09 d7                	or     %edx,%edi
  803933:	89 f2                	mov    %esi,%edx
  803935:	89 f8                	mov    %edi,%eax
  803937:	f7 75 ec             	divl   -0x14(%ebp)
  80393a:	89 d6                	mov    %edx,%esi
  80393c:	89 c7                	mov    %eax,%edi
  80393e:	f7 65 e8             	mull   -0x18(%ebp)
  803941:	39 d6                	cmp    %edx,%esi
  803943:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803946:	72 30                	jb     803978 <__udivdi3+0x118>
  803948:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80394b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80394f:	d3 e2                	shl    %cl,%edx
  803951:	39 c2                	cmp    %eax,%edx
  803953:	73 05                	jae    80395a <__udivdi3+0xfa>
  803955:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  803958:	74 1e                	je     803978 <__udivdi3+0x118>
  80395a:	89 f9                	mov    %edi,%ecx
  80395c:	31 ff                	xor    %edi,%edi
  80395e:	e9 71 ff ff ff       	jmp    8038d4 <__udivdi3+0x74>
  803963:	90                   	nop
  803964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803968:	31 ff                	xor    %edi,%edi
  80396a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80396f:	e9 60 ff ff ff       	jmp    8038d4 <__udivdi3+0x74>
  803974:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803978:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80397b:	31 ff                	xor    %edi,%edi
  80397d:	89 c8                	mov    %ecx,%eax
  80397f:	89 fa                	mov    %edi,%edx
  803981:	83 c4 10             	add    $0x10,%esp
  803984:	5e                   	pop    %esi
  803985:	5f                   	pop    %edi
  803986:	5d                   	pop    %ebp
  803987:	c3                   	ret    
	...

00803990 <__umoddi3>:
  803990:	55                   	push   %ebp
  803991:	89 e5                	mov    %esp,%ebp
  803993:	57                   	push   %edi
  803994:	56                   	push   %esi
  803995:	83 ec 20             	sub    $0x20,%esp
  803998:	8b 55 14             	mov    0x14(%ebp),%edx
  80399b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80399e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8039a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8039a4:	85 d2                	test   %edx,%edx
  8039a6:	89 c8                	mov    %ecx,%eax
  8039a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8039ab:	75 13                	jne    8039c0 <__umoddi3+0x30>
  8039ad:	39 f7                	cmp    %esi,%edi
  8039af:	76 3f                	jbe    8039f0 <__umoddi3+0x60>
  8039b1:	89 f2                	mov    %esi,%edx
  8039b3:	f7 f7                	div    %edi
  8039b5:	89 d0                	mov    %edx,%eax
  8039b7:	31 d2                	xor    %edx,%edx
  8039b9:	83 c4 20             	add    $0x20,%esp
  8039bc:	5e                   	pop    %esi
  8039bd:	5f                   	pop    %edi
  8039be:	5d                   	pop    %ebp
  8039bf:	c3                   	ret    
  8039c0:	39 f2                	cmp    %esi,%edx
  8039c2:	77 4c                	ja     803a10 <__umoddi3+0x80>
  8039c4:	0f bd ca             	bsr    %edx,%ecx
  8039c7:	83 f1 1f             	xor    $0x1f,%ecx
  8039ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8039cd:	75 51                	jne    803a20 <__umoddi3+0x90>
  8039cf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8039d2:	0f 87 e0 00 00 00    	ja     803ab8 <__umoddi3+0x128>
  8039d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039db:	29 f8                	sub    %edi,%eax
  8039dd:	19 d6                	sbb    %edx,%esi
  8039df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8039e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039e5:	89 f2                	mov    %esi,%edx
  8039e7:	83 c4 20             	add    $0x20,%esp
  8039ea:	5e                   	pop    %esi
  8039eb:	5f                   	pop    %edi
  8039ec:	5d                   	pop    %ebp
  8039ed:	c3                   	ret    
  8039ee:	66 90                	xchg   %ax,%ax
  8039f0:	85 ff                	test   %edi,%edi
  8039f2:	75 0b                	jne    8039ff <__umoddi3+0x6f>
  8039f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8039f9:	31 d2                	xor    %edx,%edx
  8039fb:	f7 f7                	div    %edi
  8039fd:	89 c7                	mov    %eax,%edi
  8039ff:	89 f0                	mov    %esi,%eax
  803a01:	31 d2                	xor    %edx,%edx
  803a03:	f7 f7                	div    %edi
  803a05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803a08:	f7 f7                	div    %edi
  803a0a:	eb a9                	jmp    8039b5 <__umoddi3+0x25>
  803a0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a10:	89 c8                	mov    %ecx,%eax
  803a12:	89 f2                	mov    %esi,%edx
  803a14:	83 c4 20             	add    $0x20,%esp
  803a17:	5e                   	pop    %esi
  803a18:	5f                   	pop    %edi
  803a19:	5d                   	pop    %ebp
  803a1a:	c3                   	ret    
  803a1b:	90                   	nop
  803a1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803a20:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803a24:	d3 e2                	shl    %cl,%edx
  803a26:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803a29:	ba 20 00 00 00       	mov    $0x20,%edx
  803a2e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  803a31:	89 55 ec             	mov    %edx,-0x14(%ebp)
  803a34:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803a38:	89 fa                	mov    %edi,%edx
  803a3a:	d3 ea                	shr    %cl,%edx
  803a3c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803a40:	0b 55 f4             	or     -0xc(%ebp),%edx
  803a43:	d3 e7                	shl    %cl,%edi
  803a45:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803a49:	89 55 f4             	mov    %edx,-0xc(%ebp)
  803a4c:	89 f2                	mov    %esi,%edx
  803a4e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  803a51:	89 c7                	mov    %eax,%edi
  803a53:	d3 ea                	shr    %cl,%edx
  803a55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803a59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  803a5c:	89 c2                	mov    %eax,%edx
  803a5e:	d3 e6                	shl    %cl,%esi
  803a60:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803a64:	d3 ea                	shr    %cl,%edx
  803a66:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803a6a:	09 d6                	or     %edx,%esi
  803a6c:	89 f0                	mov    %esi,%eax
  803a6e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  803a71:	d3 e7                	shl    %cl,%edi
  803a73:	89 f2                	mov    %esi,%edx
  803a75:	f7 75 f4             	divl   -0xc(%ebp)
  803a78:	89 d6                	mov    %edx,%esi
  803a7a:	f7 65 e8             	mull   -0x18(%ebp)
  803a7d:	39 d6                	cmp    %edx,%esi
  803a7f:	72 2b                	jb     803aac <__umoddi3+0x11c>
  803a81:	39 c7                	cmp    %eax,%edi
  803a83:	72 23                	jb     803aa8 <__umoddi3+0x118>
  803a85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803a89:	29 c7                	sub    %eax,%edi
  803a8b:	19 d6                	sbb    %edx,%esi
  803a8d:	89 f0                	mov    %esi,%eax
  803a8f:	89 f2                	mov    %esi,%edx
  803a91:	d3 ef                	shr    %cl,%edi
  803a93:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  803a97:	d3 e0                	shl    %cl,%eax
  803a99:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  803a9d:	09 f8                	or     %edi,%eax
  803a9f:	d3 ea                	shr    %cl,%edx
  803aa1:	83 c4 20             	add    $0x20,%esp
  803aa4:	5e                   	pop    %esi
  803aa5:	5f                   	pop    %edi
  803aa6:	5d                   	pop    %ebp
  803aa7:	c3                   	ret    
  803aa8:	39 d6                	cmp    %edx,%esi
  803aaa:	75 d9                	jne    803a85 <__umoddi3+0xf5>
  803aac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  803aaf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  803ab2:	eb d1                	jmp    803a85 <__umoddi3+0xf5>
  803ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803ab8:	39 f2                	cmp    %esi,%edx
  803aba:	0f 82 18 ff ff ff    	jb     8039d8 <__umoddi3+0x48>
  803ac0:	e9 1d ff ff ff       	jmp    8039e2 <__umoddi3+0x52>
