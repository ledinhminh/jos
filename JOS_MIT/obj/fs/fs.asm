
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
  80002c:	e8 93 22 00 00       	call   8022c4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <ide_wait_ready>:
static struct buf *idequeue;
static int havedisk1;

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
  80008b:	c7 44 24 0c c0 45 80 	movl   $0x8045c0,0xc(%esp)
  800092:	00 
  800093:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  80009a:	00 
  80009b:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
  8000a2:	00 
  8000a3:	c7 04 24 e2 45 80 00 	movl   $0x8045e2,(%esp)
  8000aa:	e8 81 22 00 00       	call   802330 <_panic>

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
  8000d6:	a1 00 60 80 00       	mov    0x806000,%eax
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

00800132 <iderw>:

void
iderw(struct buf *b)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	53                   	push   %ebx
  800136:	83 ec 14             	sub    $0x14,%esp
  800139:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!(b->flags & B_BUSY))
  80013c:	8b 03                	mov    (%ebx),%eax
  80013e:	a8 01                	test   $0x1,%al
  800140:	75 1c                	jne    80015e <iderw+0x2c>
    panic("iderw: buf not busy");
  800142:	c7 44 24 08 eb 45 80 	movl   $0x8045eb,0x8(%esp)
  800149:	00 
  80014a:	c7 44 24 04 83 00 00 	movl   $0x83,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 e2 45 80 00 	movl   $0x8045e2,(%esp)
  800159:	e8 d2 21 00 00       	call   802330 <_panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
  80015e:	83 e0 06             	and    $0x6,%eax
  800161:	83 f8 02             	cmp    $0x2,%eax
  800164:	75 1c                	jne    800182 <iderw+0x50>
    panic("iderw: nothing to do");
  800166:	c7 44 24 08 ff 45 80 	movl   $0x8045ff,0x8(%esp)
  80016d:	00 
  80016e:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  800175:	00 
  800176:	c7 04 24 e2 45 80 00 	movl   $0x8045e2,(%esp)
  80017d:	e8 ae 21 00 00       	call   802330 <_panic>
  if(b->dev != 0 && !havedisk1)
  800182:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
  800186:	74 25                	je     8001ad <iderw+0x7b>
  800188:	83 3d 04 b0 80 00 00 	cmpl   $0x0,0x80b004
  80018f:	75 1c                	jne    8001ad <iderw+0x7b>
    panic("iderw: ide disk 1 not present");
  800191:	c7 44 24 08 14 46 80 	movl   $0x804614,0x8(%esp)
  800198:	00 
  800199:	c7 44 24 04 87 00 00 	movl   $0x87,0x4(%esp)
  8001a0:	00 
  8001a1:	c7 04 24 e2 45 80 00 	movl   $0x8045e2,(%esp)
  8001a8:	e8 83 21 00 00       	call   802330 <_panic>

//  spin_lock(&idelock);
  
  b->qnext = 0;
  8001ad:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  8001b4:	a1 00 b0 80 00       	mov    0x80b000,%eax
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)
  8001b9:	ba 00 b0 80 00       	mov    $0x80b000,%edx
  8001be:	85 c0                	test   %eax,%eax
  8001c0:	74 0a                	je     8001cc <iderw+0x9a>
  8001c2:	8d 50 14             	lea    0x14(%eax),%edx
  8001c5:	8b 40 14             	mov    0x14(%eax),%eax
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	75 f6                	jne    8001c2 <iderw+0x90>
    ;
  *pp = b;
  8001cc:	89 1a                	mov    %ebx,(%edx)

  if(idequeue == b)
  8001ce:	a1 00 b0 80 00       	mov    0x80b000,%eax
  8001d3:	39 d8                	cmp    %ebx,%eax
  8001d5:	75 1a                	jne    8001f1 <iderw+0xbf>
    ide_write(b->sector, &b->data, SECTSIZE);
  8001d7:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8001de:	00 
  8001df:	8d 50 18             	lea    0x18(%eax),%edx
  8001e2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001e6:	8b 40 08             	mov    0x8(%eax),%eax
  8001e9:	89 04 24             	mov    %eax,(%esp)
  8001ec:	e8 80 fe ff ff       	call   800071 <ide_write>

  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
  8001f1:	8b 03                	mov    (%ebx),%eax
  8001f3:	83 e0 06             	and    $0x6,%eax
  8001f6:	83 f8 02             	cmp    $0x2,%eax
  8001f9:	74 02                	je     8001fd <iderw+0xcb>
  8001fb:	eb fe                	jmp    8001fb <iderw+0xc9>
//    sleep(b, &idelock);
  }

//  spin_unlock(&idelock);
}
  8001fd:	83 c4 14             	add    $0x14,%esp
  800200:	5b                   	pop    %ebx
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    

00800203 <ide_read>:
	diskno = d;
}

int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	57                   	push   %edi
  800207:	56                   	push   %esi
  800208:	53                   	push   %ebx
  800209:	83 ec 1c             	sub    $0x1c,%esp
  80020c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80020f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800212:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  800215:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  80021b:	76 24                	jbe    800241 <ide_read+0x3e>
  80021d:	c7 44 24 0c c0 45 80 	movl   $0x8045c0,0xc(%esp)
  800224:	00 
  800225:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  80022c:	00 
  80022d:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800234:	00 
  800235:	c7 04 24 e2 45 80 00 	movl   $0x8045e2,(%esp)
  80023c:	e8 ef 20 00 00       	call   802330 <_panic>

	ide_wait_ready(0);
  800241:	b8 00 00 00 00       	mov    $0x0,%eax
  800246:	e8 f5 fd ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80024b:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800250:	89 f0                	mov    %esi,%eax
  800252:	ee                   	out    %al,(%dx)
  800253:	b2 f3                	mov    $0xf3,%dl
  800255:	89 f8                	mov    %edi,%eax
  800257:	ee                   	out    %al,(%dx)
  800258:	89 f8                	mov    %edi,%eax
  80025a:	c1 e8 08             	shr    $0x8,%eax
  80025d:	b2 f4                	mov    $0xf4,%dl
  80025f:	ee                   	out    %al,(%dx)
  800260:	89 f8                	mov    %edi,%eax
  800262:	c1 e8 10             	shr    $0x10,%eax
  800265:	b2 f5                	mov    $0xf5,%dl
  800267:	ee                   	out    %al,(%dx)
  800268:	a1 00 60 80 00       	mov    0x806000,%eax
  80026d:	83 e0 01             	and    $0x1,%eax
  800270:	c1 e0 04             	shl    $0x4,%eax
  800273:	83 c8 e0             	or     $0xffffffe0,%eax
  800276:	c1 ef 18             	shr    $0x18,%edi
  800279:	83 e7 0f             	and    $0xf,%edi
  80027c:	09 f8                	or     %edi,%eax
  80027e:	b2 f6                	mov    $0xf6,%dl
  800280:	ee                   	out    %al,(%dx)
  800281:	b2 f7                	mov    $0xf7,%dl
  800283:	b8 20 00 00 00       	mov    $0x20,%eax
  800288:	ee                   	out    %al,(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800289:	85 f6                	test   %esi,%esi
  80028b:	74 2a                	je     8002b7 <ide_read+0xb4>
		if ((r = ide_wait_ready(1)) < 0)
  80028d:	b8 01 00 00 00       	mov    $0x1,%eax
  800292:	e8 a9 fd ff ff       	call   800040 <ide_wait_ready>
  800297:	85 c0                	test   %eax,%eax
  800299:	78 21                	js     8002bc <ide_read+0xb9>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	b9 80 00 00 00       	mov    $0x80,%ecx
  8002a2:	ba f0 01 00 00       	mov    $0x1f0,%edx
  8002a7:	fc                   	cld    
  8002a8:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  8002aa:	83 ee 01             	sub    $0x1,%esi
  8002ad:	74 08                	je     8002b7 <ide_read+0xb4>
  8002af:	81 c3 00 02 00 00    	add    $0x200,%ebx
  8002b5:	eb d6                	jmp    80028d <ide_read+0x8a>
  8002b7:	b8 00 00 00 00       	mov    $0x0,%eax
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
}
  8002bc:	83 c4 1c             	add    $0x1c,%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5f                   	pop    %edi
  8002c2:	5d                   	pop    %ebp
  8002c3:	c3                   	ret    

008002c4 <ide_set_disk>:
	return (x < 1000);
}

void
ide_set_disk(int d)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8002cd:	83 f8 01             	cmp    $0x1,%eax
  8002d0:	76 1c                	jbe    8002ee <ide_set_disk+0x2a>
		panic("bad disk number");
  8002d2:	c7 44 24 08 32 46 80 	movl   $0x804632,0x8(%esp)
  8002d9:	00 
  8002da:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
  8002e1:	00 
  8002e2:	c7 04 24 e2 45 80 00 	movl   $0x8045e2,(%esp)
  8002e9:	e8 42 20 00 00       	call   802330 <_panic>
	diskno = d;
  8002ee:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8002f3:	c9                   	leave  
  8002f4:	c3                   	ret    

008002f5 <ide_probe_disk1>:
	return 0;
}

bool
ide_probe_disk1(void)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	53                   	push   %ebx
  8002f9:	83 ec 14             	sub    $0x14,%esp
	int r, x;

//  __spin_initlock(&idelock, "ide");

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  8002fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800301:	e8 3a fd ff ff       	call   800040 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800306:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80030b:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  800310:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800311:	b2 f7                	mov    $0xf7,%dl
  800313:	ec                   	in     (%dx),%al

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800314:	b9 00 00 00 00       	mov    $0x0,%ecx
  800319:	a8 a1                	test   $0xa1,%al
  80031b:	74 2c                	je     800349 <ide_probe_disk1+0x54>
  80031d:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++){
    if(inb(0x1F7) != 0){
  80031e:	b1 01                	mov    $0x1,%cl
  800320:	84 c0                	test   %al,%al
  800322:	74 20                	je     800344 <ide_probe_disk1+0x4f>
  800324:	b1 00                	mov    $0x0,%cl
  800326:	eb 05                	jmp    80032d <ide_probe_disk1+0x38>
  800328:	ec                   	in     (%dx),%al
  800329:	84 c0                	test   %al,%al
  80032b:	74 0c                	je     800339 <ide_probe_disk1+0x44>
      havedisk1 = 1;
  80032d:	c7 05 04 b0 80 00 01 	movl   $0x1,0x80b004
  800334:	00 00 00 
      break;
  800337:	eb 10                	jmp    800349 <ide_probe_disk1+0x54>
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++){
  800339:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80033c:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800342:	74 05                	je     800349 <ide_probe_disk1+0x54>
  800344:	ec                   	in     (%dx),%al
  800345:	a8 a1                	test   $0xa1,%al
  800347:	75 df                	jne    800328 <ide_probe_disk1+0x33>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800349:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80034e:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  800353:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  800354:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  80035a:	0f 9e c3             	setle  %bl
  80035d:	0f b6 db             	movzbl %bl,%ebx
  800360:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800364:	c7 04 24 42 46 80 00 	movl   $0x804642,(%esp)
  80036b:	e8 79 20 00 00       	call   8023e9 <cprintf>
	return (x < 1000);
}
  800370:	89 d8                	mov    %ebx,%eax
  800372:	83 c4 14             	add    $0x14,%esp
  800375:	5b                   	pop    %ebx
  800376:	5d                   	pop    %ebp
  800377:	c3                   	ret    
	...

00800380 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	53                   	push   %ebx
  struct buf *b;
//  __spin_initlock(&bcache.lock, "bcache");
  //PAGEBREAK!
  //Create linked list of buffer cache
  bcache.head.prev = &bcache.head;
  800384:	c7 05 50 c5 80 00 44 	movl   $0x80c544,0x80c550
  80038b:	c5 80 00 
  bcache.head.next = &bcache.head;
  80038e:	c7 05 54 c5 80 00 44 	movl   $0x80c544,0x80c554
  800395:	c5 80 00 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  800398:	b8 54 b0 80 00       	mov    $0x80b054,%eax
  80039d:	3d 44 c5 80 00       	cmp    $0x80c544,%eax
  8003a2:	73 31                	jae    8003d5 <binit+0x55>
  struct buf buf[NBUF];
  struct buf head;
} bcache;

void
binit(void)
  8003a4:	bb 44 c5 80 00       	mov    $0x80c544,%ebx
  //PAGEBREAK!
  //Create linked list of buffer cache
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
  8003a9:	ba 54 c5 80 00       	mov    $0x80c554,%edx
  8003ae:	8b 0a                	mov    (%edx),%ecx
  8003b0:	89 48 10             	mov    %ecx,0x10(%eax)
    b->prev = &bcache.head;
  8003b3:	c7 40 0c 44 c5 80 00 	movl   $0x80c544,0xc(%eax)
    b->dev = -1;
  8003ba:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
  8003c1:	8b 0d 54 c5 80 00    	mov    0x80c554,%ecx
  8003c7:	89 41 0c             	mov    %eax,0xc(%ecx)
    bcache.head.next = b;
  8003ca:	89 02                	mov    %eax,(%edx)
//  __spin_initlock(&bcache.lock, "bcache");
  //PAGEBREAK!
  //Create linked list of buffer cache
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  8003cc:	05 18 02 00 00       	add    $0x218,%eax
  8003d1:	39 d8                	cmp    %ebx,%eax
  8003d3:	75 d9                	jne    8003ae <binit+0x2e>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
  8003d5:	5b                   	pop    %ebx
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <brelse>:
  iderw(b);
}

void
brelse(struct buf *b)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 18             	sub    $0x18,%esp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  if((b->flags & B_BUSY) == 0)
  8003e1:	f6 00 01             	testb  $0x1,(%eax)
  8003e4:	75 1c                	jne    800402 <brelse+0x2a>
    panic("brelse");
  8003e6:	c7 44 24 08 59 46 80 	movl   $0x804659,0x8(%esp)
  8003ed:	00 
  8003ee:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8003f5:	00 
  8003f6:	c7 04 24 60 46 80 00 	movl   $0x804660,(%esp)
  8003fd:	e8 2e 1f 00 00       	call   802330 <_panic>
//  spin_lock(&bcache.lock);
  b->next->prev = b->prev;
  800402:	8b 50 10             	mov    0x10(%eax),%edx
  800405:	8b 48 0c             	mov    0xc(%eax),%ecx
  800408:	89 4a 0c             	mov    %ecx,0xc(%edx)
  b->prev->next = b->next;
  80040b:	8b 50 0c             	mov    0xc(%eax),%edx
  80040e:	8b 48 10             	mov    0x10(%eax),%ecx
  800411:	89 4a 10             	mov    %ecx,0x10(%edx)
  b->next = bcache.head.next;
  800414:	ba 54 c5 80 00       	mov    $0x80c554,%edx
  800419:	8b 0a                	mov    (%edx),%ecx
  80041b:	89 48 10             	mov    %ecx,0x10(%eax)
  b->prev = &bcache.head;
  80041e:	c7 40 0c 44 c5 80 00 	movl   $0x80c544,0xc(%eax)
  bcache.head.next->prev = b;
  800425:	8b 0d 54 c5 80 00    	mov    0x80c554,%ecx
  80042b:	89 41 0c             	mov    %eax,0xc(%ecx)
  bcache.head.next = b;
  80042e:	89 02                	mov    %eax,(%edx)

  b->flags &= ~B_BUSY;
  800430:	83 20 fe             	andl   $0xfffffffe,(%eax)

  //wakeup(b);
//  spin_unlock(&bcache.lock);
}
  800433:	c9                   	leave  
  800434:	c3                   	ret    

00800435 <bwrite>:
  return b;
}

void
bwrite(struct buf *b)
{
  800435:	55                   	push   %ebp
  800436:	89 e5                	mov    %esp,%ebp
  800438:	83 ec 18             	sub    $0x18,%esp
  80043b:	8b 45 08             	mov    0x8(%ebp),%eax
  if((b->flags & B_BUSY) == 0)
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	f6 c2 01             	test   $0x1,%dl
  800443:	75 1c                	jne    800461 <bwrite+0x2c>
    panic("bwrite");
  800445:	c7 44 24 08 69 46 80 	movl   $0x804669,0x8(%esp)
  80044c:	00 
  80044d:	c7 44 24 04 4a 00 00 	movl   $0x4a,0x4(%esp)
  800454:	00 
  800455:	c7 04 24 60 46 80 00 	movl   $0x804660,(%esp)
  80045c:	e8 cf 1e 00 00       	call   802330 <_panic>
  b->flags |= B_DIRTY;
  800461:	83 ca 04             	or     $0x4,%edx
  800464:	89 10                	mov    %edx,(%eax)
  iderw(b);
  800466:	89 04 24             	mov    %eax,(%esp)
  800469:	e8 c4 fc ff ff       	call   800132 <iderw>
}
  80046e:	c9                   	leave  
  80046f:	c3                   	ret    

00800470 <bread>:
  panic("bget:no buffers!");
}

struct buf*
bread(uint32_t dev, uint32_t sector)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	53                   	push   %ebx
  800474:	83 ec 14             	sub    $0x14,%esp
  800477:	8b 55 08             	mov    0x8(%ebp),%edx
  80047a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
{
  struct buf *b;
//  spin_lock(&bcache.lock);
  
loop:
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
  80047d:	bb 54 c5 80 00       	mov    $0x80c554,%ebx
  800482:	8b 03                	mov    (%ebx),%eax
  800484:	3d 44 c5 80 00       	cmp    $0x80c544,%eax
  800489:	74 19                	je     8004a4 <bread+0x34>
    if(b->dev == dev && b->sector == sector){
  80048b:	3b 50 04             	cmp    0x4(%eax),%edx
  80048e:	75 0a                	jne    80049a <bread+0x2a>
  800490:	3b 48 08             	cmp    0x8(%eax),%ecx
  800493:	75 05                	jne    80049a <bread+0x2a>
      if(!(b->flags |= B_BUSY)){
  800495:	83 08 01             	orl    $0x1,(%eax)
  800498:	eb e8                	jmp    800482 <bread+0x12>
{
  struct buf *b;
//  spin_lock(&bcache.lock);
  
loop:
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
  80049a:	8b 40 10             	mov    0x10(%eax),%eax
  80049d:	3d 44 c5 80 00       	cmp    $0x80c544,%eax
  8004a2:	75 e7                	jne    80048b <bread+0x1b>
      }
      //sleep(b, &bcache.lock);
      goto loop;
    }
  }
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
  8004a4:	8b 1d 50 c5 80 00    	mov    0x80c550,%ebx
  8004aa:	81 fb 44 c5 80 00    	cmp    $0x80c544,%ebx
  8004b0:	74 37                	je     8004e9 <bread+0x79>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
  8004b2:	f6 03 05             	testb  $0x5,(%ebx)
  8004b5:	75 27                	jne    8004de <bread+0x6e>
  8004b7:	eb 09                	jmp    8004c2 <bread+0x52>
  8004b9:	f6 03 05             	testb  $0x5,(%ebx)
  8004bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004c0:	75 1c                	jne    8004de <bread+0x6e>
      b->dev = dev;
  8004c2:	89 53 04             	mov    %edx,0x4(%ebx)
      b->sector = sector;
  8004c5:	89 4b 08             	mov    %ecx,0x8(%ebx)
      b->flags = B_BUSY;
  8004c8:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
bread(uint32_t dev, uint32_t sector)
{
  struct buf *b;
  b = bget(dev, sector);
  if(!(b->flags & B_VALID))
    iderw(b);
  8004ce:	89 1c 24             	mov    %ebx,(%esp)
  8004d1:	e8 5c fc ff ff       	call   800132 <iderw>
  return b;
}
  8004d6:	89 d8                	mov    %ebx,%eax
  8004d8:	83 c4 14             	add    $0x14,%esp
  8004db:	5b                   	pop    %ebx
  8004dc:	5d                   	pop    %ebp
  8004dd:	c3                   	ret    
      }
      //sleep(b, &bcache.lock);
      goto loop;
    }
  }
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
  8004de:	8b 5b 0c             	mov    0xc(%ebx),%ebx
  8004e1:	81 fb 44 c5 80 00    	cmp    $0x80c544,%ebx
  8004e7:	75 d0                	jne    8004b9 <bread+0x49>
      b->flags = B_BUSY;
//      spin_unlock(&bcache.lock);
      return b;
    }
  }
  panic("bget:no buffers!");
  8004e9:	c7 44 24 08 70 46 80 	movl   $0x804670,0x8(%esp)
  8004f0:	00 
  8004f1:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8004f8:	00 
  8004f9:	c7 04 24 60 46 80 00 	movl   $0x804660,(%esp)
  800500:	e8 2b 1e 00 00       	call   802330 <_panic>
	...

00800510 <begin_trans>:
  write_head();  // clear the log
}

void
begin_trans(void)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
//  spin_lock(&log.lock);
  while(log.busy) {
  800513:	83 3d 9c c7 80 00 00 	cmpl   $0x0,0x80c79c
  80051a:	75 0c                	jne    800528 <begin_trans+0x18>
//    sleep(&log, &log.lock);
  }
  log.busy = 1;
  80051c:	c7 05 9c c7 80 00 01 	movl   $0x1,0x80c79c
  800523:	00 00 00 
//  spin_unlock(&log.lock);
}
  800526:	5d                   	pop    %ebp
  800527:	c3                   	ret    
  800528:	eb fe                	jmp    800528 <begin_trans+0x18>

0080052a <log_write>:
//  spin_unlock(&log.lock);
}

void
log_write(struct buf *b)
{
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	57                   	push   %edi
  80052e:	56                   	push   %esi
  80052f:	53                   	push   %ebx
  800530:	83 ec 1c             	sub    $0x1c,%esp
  800533:	8b 75 08             	mov    0x8(%ebp),%esi
  int i;
  if(log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
  800536:	a1 a4 c7 80 00       	mov    0x80c7a4,%eax
  80053b:	83 f8 09             	cmp    $0x9,%eax
  80053e:	7f 0d                	jg     80054d <log_write+0x23>
  800540:	8b 15 98 c7 80 00    	mov    0x80c798,%edx
  800546:	83 ea 01             	sub    $0x1,%edx
  800549:	39 d0                	cmp    %edx,%eax
  80054b:	7c 1c                	jl     800569 <log_write+0x3f>
    panic("too big a transaction");
  80054d:	c7 44 24 08 81 46 80 	movl   $0x804681,0x8(%esp)
  800554:	00 
  800555:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  80055c:	00 
  80055d:	c7 04 24 97 46 80 00 	movl   $0x804697,(%esp)
  800564:	e8 c7 1d 00 00       	call   802330 <_panic>
  if(!log.busy)
  800569:	83 3d 9c c7 80 00 00 	cmpl   $0x0,0x80c79c
  800570:	74 1b                	je     80058d <log_write+0x63>
    panic("write outside of trans");
  for(i = 0; i < log.lh.n; i++){
  800572:	85 c0                	test   %eax,%eax
  800574:	7e 41                	jle    8005b7 <log_write+0x8d>
    if(log.lh.sector[i] == b->sector)
  800576:	8b 56 08             	mov    0x8(%esi),%edx
  800579:	bb 00 00 00 00       	mov    $0x0,%ebx
  80057e:	b9 a8 c7 80 00       	mov    $0x80c7a8,%ecx
  800583:	39 15 a8 c7 80 00    	cmp    %edx,0x80c7a8
  800589:	75 23                	jne    8005ae <log_write+0x84>
  80058b:	eb 2a                	jmp    8005b7 <log_write+0x8d>
{
  int i;
  if(log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if(!log.busy)
    panic("write outside of trans");
  80058d:	c7 44 24 08 a0 46 80 	movl   $0x8046a0,0x8(%esp)
  800594:	00 
  800595:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
  80059c:	00 
  80059d:	c7 04 24 97 46 80 00 	movl   $0x804697,(%esp)
  8005a4:	e8 87 1d 00 00       	call   802330 <_panic>
  for(i = 0; i < log.lh.n; i++){
    if(log.lh.sector[i] == b->sector)
  8005a9:	39 14 99             	cmp    %edx,(%ecx,%ebx,4)
  8005ac:	74 0e                	je     8005bc <log_write+0x92>
  int i;
  if(log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
  if(!log.busy)
    panic("write outside of trans");
  for(i = 0; i < log.lh.n; i++){
  8005ae:	83 c3 01             	add    $0x1,%ebx
  8005b1:	39 d8                	cmp    %ebx,%eax
  8005b3:	7f f4                	jg     8005a9 <log_write+0x7f>
  8005b5:	eb 05                	jmp    8005bc <log_write+0x92>
  8005b7:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(log.lh.sector[i] == b->sector)
      break;
  }
  log.lh.sector[i] = b->sector;
  8005bc:	8b 46 08             	mov    0x8(%esi),%eax
  8005bf:	89 04 9d a8 c7 80 00 	mov    %eax,0x80c7a8(,%ebx,4)
  struct buf *lbuf = bread(b->dev, log.start+i+1);
  8005c6:	a1 94 c7 80 00       	mov    0x80c794,%eax
  8005cb:	8d 44 03 01          	lea    0x1(%ebx,%eax,1),%eax
  8005cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d3:	8b 46 04             	mov    0x4(%esi),%eax
  8005d6:	89 04 24             	mov    %eax,(%esp)
  8005d9:	e8 92 fe ff ff       	call   800470 <bread>
  8005de:	89 c7                	mov    %eax,%edi
  memmove(lbuf->data, b->data, BSIZE);
  8005e0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005e7:	00 
  8005e8:	8d 46 18             	lea    0x18(%esi),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	8d 47 18             	lea    0x18(%edi),%eax
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	e8 1b 27 00 00       	call   802d15 <memmove>
  bwrite(lbuf);
  8005fa:	89 3c 24             	mov    %edi,(%esp)
  8005fd:	e8 33 fe ff ff       	call   800435 <bwrite>
  brelse(lbuf);
  800602:	89 3c 24             	mov    %edi,(%esp)
  800605:	e8 ce fd ff ff       	call   8003d8 <brelse>
  if(i == log.lh.n)
  80060a:	a1 a4 c7 80 00       	mov    0x80c7a4,%eax
  80060f:	39 d8                	cmp    %ebx,%eax
  800611:	75 08                	jne    80061b <log_write+0xf1>
    log.lh.n++;
  800613:	83 c0 01             	add    $0x1,%eax
  800616:	a3 a4 c7 80 00       	mov    %eax,0x80c7a4
  b->flags |= B_DIRTY;  // XXX prevent eviction
  80061b:	83 0e 04             	orl    $0x4,(%esi)
}
  80061e:	83 c4 1c             	add    $0x1c,%esp
  800621:	5b                   	pop    %ebx
  800622:	5e                   	pop    %esi
  800623:	5f                   	pop    %edi
  800624:	5d                   	pop    %ebp
  800625:	c3                   	ret    

00800626 <install_trans>:
  recover_from_log();
}

static void
install_trans(void)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	57                   	push   %edi
  80062a:	56                   	push   %esi
  80062b:	53                   	push   %ebx
  80062c:	83 ec 2c             	sub    $0x2c,%esp
  int tail;
  for(tail = 0; tail < log.lh.n; tail++){
  80062f:	83 3d a4 c7 80 00 00 	cmpl   $0x0,0x80c7a4
  800636:	0f 8e 80 00 00 00    	jle    8006bc <install_trans+0x96>
  80063c:	bb 00 00 00 00       	mov    $0x0,%ebx
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
  800641:	be a0 c7 80 00       	mov    $0x80c7a0,%esi
  800646:	ba 94 c7 80 00       	mov    $0x80c794,%edx
  80064b:	8b 02                	mov    (%edx),%eax
  80064d:	8d 44 03 01          	lea    0x1(%ebx,%eax,1),%eax
  800651:	89 44 24 04          	mov    %eax,0x4(%esp)
  800655:	8b 06                	mov    (%esi),%eax
  800657:	89 04 24             	mov    %eax,(%esp)
  80065a:	e8 11 fe ff ff       	call   800470 <bread>
  80065f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]);
  800662:	8b 04 9d a8 c7 80 00 	mov    0x80c7a8(,%ebx,4),%eax
  800669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066d:	8b 06                	mov    (%esi),%eax
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	e8 f9 fd ff ff       	call   800470 <bread>
  800677:	89 c7                	mov    %eax,%edi
    memmove(dbuf->data, lbuf->data, BSIZE);
  800679:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800680:	00 
  800681:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800684:	83 c0 18             	add    $0x18,%eax
  800687:	89 44 24 04          	mov    %eax,0x4(%esp)
  80068b:	8d 47 18             	lea    0x18(%edi),%eax
  80068e:	89 04 24             	mov    %eax,(%esp)
  800691:	e8 7f 26 00 00       	call   802d15 <memmove>
    bwrite(dbuf);
  800696:	89 3c 24             	mov    %edi,(%esp)
  800699:	e8 97 fd ff ff       	call   800435 <bwrite>
    brelse(lbuf);
  80069e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006a1:	89 04 24             	mov    %eax,(%esp)
  8006a4:	e8 2f fd ff ff       	call   8003d8 <brelse>
    brelse(dbuf);
  8006a9:	89 3c 24             	mov    %edi,(%esp)
  8006ac:	e8 27 fd ff ff       	call   8003d8 <brelse>

static void
install_trans(void)
{
  int tail;
  for(tail = 0; tail < log.lh.n; tail++){
  8006b1:	83 c3 01             	add    $0x1,%ebx
  8006b4:	39 1d a4 c7 80 00    	cmp    %ebx,0x80c7a4
  8006ba:	7f 8a                	jg     800646 <install_trans+0x20>
    memmove(dbuf->data, lbuf->data, BSIZE);
    bwrite(dbuf);
    brelse(lbuf);
    brelse(dbuf);
  }
}
  8006bc:	83 c4 2c             	add    $0x2c,%esp
  8006bf:	5b                   	pop    %ebx
  8006c0:	5e                   	pop    %esi
  8006c1:	5f                   	pop    %edi
  8006c2:	5d                   	pop    %ebp
  8006c3:	c3                   	ret    

008006c4 <write_head>:
  brelse(buf);
}

static void
write_head(void)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 1c             	sub    $0x1c,%esp
  struct buf *buf = bread(log.dev, log.start);
  8006cd:	a1 94 c7 80 00       	mov    0x80c794,%eax
  8006d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d6:	a1 a0 c7 80 00       	mov    0x80c7a0,%eax
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	e8 8d fd ff ff       	call   800470 <bread>
  8006e3:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  8006e5:	8d 48 18             	lea    0x18(%eax),%ecx
  int i;
  hb->n = log.lh.n;
  8006e8:	b8 a4 c7 80 00       	mov    $0x80c7a4,%eax
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	89 11                	mov    %edx,(%ecx)
  for(i = 0; i < log.lh.n; i++){
  8006f1:	83 38 00             	cmpl   $0x0,(%eax)
  8006f4:	7e 1d                	jle    800713 <write_head+0x4f>
  8006f6:	b8 00 00 00 00       	mov    $0x0,%eax
    hb->sector[i] = log.lh.sector[i];
  8006fb:	bf a8 c7 80 00       	mov    $0x80c7a8,%edi
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for(i = 0; i < log.lh.n; i++){
  800700:	be a4 c7 80 00       	mov    $0x80c7a4,%esi
    hb->sector[i] = log.lh.sector[i];
  800705:	8b 14 87             	mov    (%edi,%eax,4),%edx
  800708:	89 54 81 04          	mov    %edx,0x4(%ecx,%eax,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for(i = 0; i < log.lh.n; i++){
  80070c:	83 c0 01             	add    $0x1,%eax
  80070f:	39 06                	cmp    %eax,(%esi)
  800711:	7f f2                	jg     800705 <write_head+0x41>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
  800713:	89 1c 24             	mov    %ebx,(%esp)
  800716:	e8 1a fd ff ff       	call   800435 <bwrite>
  brelse(buf);
  80071b:	89 1c 24             	mov    %ebx,(%esp)
  80071e:	e8 b5 fc ff ff       	call   8003d8 <brelse>
}
  800723:	83 c4 1c             	add    $0x1c,%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <commit_trans>:
//  spin_unlock(&log.lock);
}

void
commit_trans(void)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	83 ec 08             	sub    $0x8,%esp
  if(log.lh.n > 0) {
  800731:	83 3d a4 c7 80 00 00 	cmpl   $0x0,0x80c7a4
  800738:	7e 19                	jle    800753 <commit_trans+0x28>
    write_head();
  80073a:	e8 85 ff ff ff       	call   8006c4 <write_head>
    install_trans();
  80073f:	e8 e2 fe ff ff       	call   800626 <install_trans>
    log.lh.n = 0;
  800744:	c7 05 a4 c7 80 00 00 	movl   $0x0,0x80c7a4
  80074b:	00 00 00 
    write_head();
  80074e:	e8 71 ff ff ff       	call   8006c4 <write_head>
  }
//  spin_lock(&log.lock);
  log.busy = 0;
  800753:	c7 05 9c c7 80 00 00 	movl   $0x0,0x80c79c
  80075a:	00 00 00 
//  wakeup(&log);
//  spin_unlock(&log.lock);
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <initlog>:

static void recover_from_log(void);

void
initlog(void)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	57                   	push   %edi
  800763:	56                   	push   %esi
  800764:	53                   	push   %ebx
  800765:	83 ec 1c             	sub    $0x1c,%esp
  if(sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

//  __spin_initlock(&log.lock, "log");
  super = diskaddr(1);
  800768:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80076f:	e8 cf 00 00 00       	call   800843 <diskaddr>
  800774:	a3 14 b0 80 00       	mov    %eax,0x80b014
  log.start = (*super).size - (*super).nlog;
  800779:	8b 90 08 01 00 00    	mov    0x108(%eax),%edx
  80077f:	2b 90 0c 01 00 00    	sub    0x10c(%eax),%edx
  800785:	89 15 94 c7 80 00    	mov    %edx,0x80c794
  log.size = (*super).nlog;
  80078b:	8b 80 0c 01 00 00    	mov    0x10c(%eax),%eax
  800791:	a3 98 c7 80 00       	mov    %eax,0x80c798
  log.dev = ROOTDEV;
  800796:	c7 05 a0 c7 80 00 01 	movl   $0x1,0x80c7a0
  80079d:	00 00 00 
}

static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
  8007a0:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007ab:	e8 c0 fc ff ff       	call   800470 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  8007b0:	8d 70 18             	lea    0x18(%eax),%esi
  int i;
  log.lh.n = lh->n;
  8007b3:	8b 1e                	mov    (%esi),%ebx
  8007b5:	89 1d a4 c7 80 00    	mov    %ebx,0x80c7a4
  for(i = 0; i < log.lh.n; i++){
  8007bb:	85 db                	test   %ebx,%ebx
  8007bd:	7e 18                	jle    8007d7 <initlog+0x78>
  8007bf:	ba 00 00 00 00       	mov    $0x0,%edx
    log.lh.sector[i] = lh->sector[i];
  8007c4:	bf a8 c7 80 00       	mov    $0x80c7a8,%edi
  8007c9:	8b 4c 96 04          	mov    0x4(%esi,%edx,4),%ecx
  8007cd:	89 0c 97             	mov    %ecx,(%edi,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for(i = 0; i < log.lh.n; i++){
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	39 da                	cmp    %ebx,%edx
  8007d5:	75 f2                	jne    8007c9 <initlog+0x6a>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
  8007d7:	89 04 24             	mov    %eax,(%esp)
  8007da:	e8 f9 fb ff ff       	call   8003d8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans();  // if committed, copy from log to disk
  8007df:	e8 42 fe ff ff       	call   800626 <install_trans>
  log.lh.n = 0;
  8007e4:	c7 05 a4 c7 80 00 00 	movl   $0x0,0x80c7a4
  8007eb:	00 00 00 
  write_head();  // clear the log
  8007ee:	e8 d1 fe ff ff       	call   8006c4 <write_head>
  super = diskaddr(1);
  log.start = (*super).size - (*super).nlog;
  log.size = (*super).nlog;
  log.dev = ROOTDEV;
  recover_from_log();
}
  8007f3:	83 c4 1c             	add    $0x1c,%esp
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5f                   	pop    %edi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    
  8007fb:	00 00                	add    %al,(%eax)
  8007fd:	00 00                	add    %al,(%eax)
	...

00800800 <va_is_mapped>:
}

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
	return (vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P);
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
  800806:	89 d0                	mov    %edx,%eax
  800808:	c1 e8 16             	shr    $0x16,%eax
  80080b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
  800817:	f6 c1 01             	test   $0x1,%cl
  80081a:	74 0d                	je     800829 <va_is_mapped+0x29>
  80081c:	c1 ea 0c             	shr    $0xc,%edx
  80081f:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800826:	83 e0 01             	and    $0x1,%eax
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
	return (vpt[PGNUM(va)] & PTE_D) != 0;
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	c1 e8 0c             	shr    $0xc,%eax
  800834:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80083b:	c1 e8 06             	shr    $0x6,%eax
  80083e:	83 e0 01             	and    $0x1,%eax
}
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <diskaddr>:
#include <kern/spinlock.h>

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 18             	sub    $0x18,%esp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80084c:	85 c0                	test   %eax,%eax
  80084e:	74 0f                	je     80085f <diskaddr+0x1c>
  800850:	8b 15 14 b0 80 00    	mov    0x80b014,%edx
  800856:	85 d2                	test   %edx,%edx
  800858:	74 25                	je     80087f <diskaddr+0x3c>
  80085a:	3b 42 04             	cmp    0x4(%edx),%eax
  80085d:	72 20                	jb     80087f <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80085f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800863:	c7 44 24 08 b8 46 80 	movl   $0x8046b8,0x8(%esp)
  80086a:	00 
  80086b:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
  800872:	00 
  800873:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  80087a:	e8 b1 1a 00 00       	call   802330 <_panic>
  80087f:	05 00 00 01 00       	add    $0x10000,%eax
  800884:	c1 e0 0c             	shl    $0xc,%eax
	return (char*) (DISKMAP + blockno * BLKSIZE);
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <bc_pgfault>:
// Fault any disk block that is read or written in to memory by
// loading it from disk.
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	56                   	push   %esi
  80088d:	53                   	push   %ebx
  80088e:	83 ec 20             	sub    $0x20,%esp
  800891:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800894:	8b 30                	mov    (%eax),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800896:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
  80089c:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  8008a2:	76 2e                	jbe    8008d2 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  8008a4:	8b 50 04             	mov    0x4(%eax),%edx
  8008a7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8008ab:	89 74 24 10          	mov    %esi,0x10(%esp)
  8008af:	8b 40 28             	mov    0x28(%eax),%eax
  8008b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008b6:	c7 44 24 08 dc 46 80 	movl   $0x8046dc,0x8(%esp)
  8008bd:	00 
  8008be:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8008c5:	00 
  8008c6:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  8008cd:	e8 5e 1a 00 00       	call   802330 <_panic>
// Hint: Use ide_read and BLKSECTS.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8008d2:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  8008d8:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8008db:	a1 14 b0 80 00       	mov    0x80b014,%eax
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	74 25                	je     800909 <bc_pgfault+0x80>
  8008e4:	3b 70 04             	cmp    0x4(%eax),%esi
  8008e7:	72 20                	jb     800909 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8008e9:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8008ed:	c7 44 24 08 0c 47 80 	movl   $0x80470c,0x8(%esp)
  8008f4:	00 
  8008f5:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8008fc:	00 
  8008fd:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800904:	e8 27 1a 00 00       	call   802330 <_panic>
	// of the block from the disk into that page, and mark the
	// page not-dirty (since reading the data from disk will mark
	// the page dirty).
	//
	// LAB 5: Your code here
  addr = diskaddr(blockno);
  800909:	89 34 24             	mov    %esi,(%esp)
  80090c:	e8 32 ff ff ff       	call   800843 <diskaddr>
  800911:	89 c3                	mov    %eax,%ebx
  r = sys_page_alloc(thisenv->env_id, addr, PTE_U|PTE_W|PTE_P);
  800913:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  800918:	8b 40 48             	mov    0x48(%eax),%eax
  80091b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800922:	00 
  800923:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800927:	89 04 24             	mov    %eax,(%esp)
  80092a:	e8 5e 28 00 00       	call   80318d <sys_page_alloc>
  if (r < 0)
  80092f:	85 c0                	test   %eax,%eax
  800931:	79 20                	jns    800953 <bc_pgfault+0xca>
    panic("sys_page_alloc failed: %e", r);
  800933:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800937:	c7 44 24 08 5c 47 80 	movl   $0x80475c,0x8(%esp)
  80093e:	00 
  80093f:	c7 44 24 04 38 00 00 	movl   $0x38,0x4(%esp)
  800946:	00 
  800947:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  80094e:	e8 dd 19 00 00       	call   802330 <_panic>
  r = ide_read(blockno * BLKSECTS, addr, BLKSECTS);
  800953:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  80095a:	00 
  80095b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80095f:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	e8 95 f8 ff ff       	call   800203 <ide_read>
  if (r < 0)
  80096e:	85 c0                	test   %eax,%eax
  800970:	79 20                	jns    800992 <bc_pgfault+0x109>
    panic("ide_read failed: %e", r);
  800972:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800976:	c7 44 24 08 76 47 80 	movl   $0x804776,0x8(%esp)
  80097d:	00 
  80097e:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  800985:	00 
  800986:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  80098d:	e8 9e 19 00 00       	call   802330 <_panic>
  r = sys_page_map(thisenv->env_id, addr, thisenv->env_id, addr, PTE_SYSCALL);
  800992:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  800997:	8b 50 48             	mov    0x48(%eax),%edx
  80099a:	8b 40 48             	mov    0x48(%eax),%eax
  80099d:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  8009a4:	00 
  8009a5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8009a9:	89 54 24 08          	mov    %edx,0x8(%esp)
  8009ad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009b1:	89 04 24             	mov    %eax,(%esp)
  8009b4:	e8 9b 27 00 00       	call   803154 <sys_page_map>
  if (r < 0)
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	79 20                	jns    8009dd <bc_pgfault+0x154>
    panic("sys_page_map failed: %e", r);	
  8009bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c1:	c7 44 24 08 8a 47 80 	movl   $0x80478a,0x8(%esp)
  8009c8:	00 
  8009c9:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8009d0:	00 
  8009d1:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  8009d8:	e8 53 19 00 00       	call   802330 <_panic>
	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8009dd:	83 3d 10 b0 80 00 00 	cmpl   $0x0,0x80b010
  8009e4:	74 2c                	je     800a12 <bc_pgfault+0x189>
  8009e6:	89 34 24             	mov    %esi,(%esp)
  8009e9:	e8 02 03 00 00       	call   800cf0 <block_is_free>
  8009ee:	85 c0                	test   %eax,%eax
  8009f0:	74 20                	je     800a12 <bc_pgfault+0x189>
		panic("reading free block %08x\n", blockno);
  8009f2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8009f6:	c7 44 24 08 a2 47 80 	movl   $0x8047a2,0x8(%esp)
  8009fd:	00 
  8009fe:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  800a05:	00 
  800a06:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800a0d:	e8 1e 19 00 00       	call   802330 <_panic>
}
  800a12:	83 c4 20             	add    $0x20,%esp
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	83 ec 28             	sub    $0x28,%esp
  800a1f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800a22:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800a25:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800a28:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  800a2e:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800a33:	76 20                	jbe    800a55 <flush_block+0x3c>
		panic("flush_block of bad va %08x", addr);
  800a35:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a39:	c7 44 24 08 bb 47 80 	movl   $0x8047bb,0x8(%esp)
  800a40:	00 
  800a41:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800a48:	00 
  800a49:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800a50:	e8 db 18 00 00       	call   802330 <_panic>
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800a55:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  800a5b:	c1 ee 0c             	shr    $0xc,%esi
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
  int r;

  addr = diskaddr(blockno);
  800a5e:	89 34 24             	mov    %esi,(%esp)
  800a61:	e8 dd fd ff ff       	call   800843 <diskaddr>
  800a66:	89 c3                	mov    %eax,%ebx
  if (!va_is_mapped(addr) || !va_is_dirty(addr))
  800a68:	89 04 24             	mov    %eax,(%esp)
  800a6b:	e8 90 fd ff ff       	call   800800 <va_is_mapped>
  800a70:	85 c0                	test   %eax,%eax
  800a72:	0f 84 96 00 00 00    	je     800b0e <flush_block+0xf5>
  800a78:	89 1c 24             	mov    %ebx,(%esp)
  800a7b:	e8 ab fd ff ff       	call   80082b <va_is_dirty>
  800a80:	85 c0                	test   %eax,%eax
  800a82:	0f 84 86 00 00 00    	je     800b0e <flush_block+0xf5>
    return;
  r = ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  800a88:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800a8f:	00 
  800a90:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a94:	c1 e6 03             	shl    $0x3,%esi
  800a97:	89 34 24             	mov    %esi,(%esp)
  800a9a:	e8 d2 f5 ff ff       	call   800071 <ide_write>
  if (r < 0)
  800a9f:	85 c0                	test   %eax,%eax
  800aa1:	79 20                	jns    800ac3 <flush_block+0xaa>
    panic("ide_write failed: %e", r);
  800aa3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800aa7:	c7 44 24 08 d6 47 80 	movl   $0x8047d6,0x8(%esp)
  800aae:	00 
  800aaf:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800ab6:	00 
  800ab7:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800abe:	e8 6d 18 00 00       	call   802330 <_panic>
  r = sys_page_map(thisenv->env_id, addr, thisenv->env_id, addr, PTE_SYSCALL);
  800ac3:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  800ac8:	8b 50 48             	mov    0x48(%eax),%edx
  800acb:	8b 40 48             	mov    0x48(%eax),%eax
  800ace:	c7 44 24 10 07 0e 00 	movl   $0xe07,0x10(%esp)
  800ad5:	00 
  800ad6:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ada:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ade:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae2:	89 04 24             	mov    %eax,(%esp)
  800ae5:	e8 6a 26 00 00       	call   803154 <sys_page_map>
  if (r < 0)
  800aea:	85 c0                	test   %eax,%eax
  800aec:	79 20                	jns    800b0e <flush_block+0xf5>
    panic("sys_page_map failed: %e", r);	
  800aee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af2:	c7 44 24 08 8a 47 80 	movl   $0x80478a,0x8(%esp)
  800af9:	00 
  800afa:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  800b01:	00 
  800b02:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800b09:	e8 22 18 00 00       	call   802330 <_panic>
}
  800b0e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b11:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b14:	89 ec                	mov    %ebp,%esp
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800b21:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b28:	e8 16 fd ff ff       	call   800843 <diskaddr>
  800b2d:	c7 44 24 08 10 01 00 	movl   $0x110,0x8(%esp)
  800b34:	00 
  800b35:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b39:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800b3f:	89 04 24             	mov    %eax,(%esp)
  800b42:	e8 ce 21 00 00       	call   802d15 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800b47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b4e:	e8 f0 fc ff ff       	call   800843 <diskaddr>
  800b53:	c7 44 24 04 eb 47 80 	movl   $0x8047eb,0x4(%esp)
  800b5a:	00 
  800b5b:	89 04 24             	mov    %eax,(%esp)
  800b5e:	e8 c7 1f 00 00       	call   802b2a <strcpy>
	flush_block(diskaddr(1));
  800b63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b6a:	e8 d4 fc ff ff       	call   800843 <diskaddr>
  800b6f:	89 04 24             	mov    %eax,(%esp)
  800b72:	e8 a2 fe ff ff       	call   800a19 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800b77:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b7e:	e8 c0 fc ff ff       	call   800843 <diskaddr>
  800b83:	89 04 24             	mov    %eax,(%esp)
  800b86:	e8 75 fc ff ff       	call   800800 <va_is_mapped>
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	75 24                	jne    800bb3 <check_bc+0x9b>
  800b8f:	c7 44 24 0c 0d 48 80 	movl   $0x80480d,0xc(%esp)
  800b96:	00 
  800b97:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  800b9e:	00 
  800b9f:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  800ba6:	00 
  800ba7:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800bae:	e8 7d 17 00 00       	call   802330 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800bb3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800bba:	e8 84 fc ff ff       	call   800843 <diskaddr>
  800bbf:	89 04 24             	mov    %eax,(%esp)
  800bc2:	e8 64 fc ff ff       	call   80082b <va_is_dirty>
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	74 24                	je     800bef <check_bc+0xd7>
  800bcb:	c7 44 24 0c f2 47 80 	movl   $0x8047f2,0xc(%esp)
  800bd2:	00 
  800bd3:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  800bda:	00 
  800bdb:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800be2:	00 
  800be3:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800bea:	e8 41 17 00 00       	call   802330 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800bef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800bf6:	e8 48 fc ff ff       	call   800843 <diskaddr>
  800bfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c06:	e8 11 25 00 00       	call   80311c <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800c0b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c12:	e8 2c fc ff ff       	call   800843 <diskaddr>
  800c17:	89 04 24             	mov    %eax,(%esp)
  800c1a:	e8 e1 fb ff ff       	call   800800 <va_is_mapped>
  800c1f:	85 c0                	test   %eax,%eax
  800c21:	74 24                	je     800c47 <check_bc+0x12f>
  800c23:	c7 44 24 0c 0c 48 80 	movl   $0x80480c,0xc(%esp)
  800c2a:	00 
  800c2b:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  800c32:	00 
  800c33:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
  800c3a:	00 
  800c3b:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800c42:	e8 e9 16 00 00       	call   802330 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800c47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c4e:	e8 f0 fb ff ff       	call   800843 <diskaddr>
  800c53:	c7 44 24 04 eb 47 80 	movl   $0x8047eb,0x4(%esp)
  800c5a:	00 
  800c5b:	89 04 24             	mov    %eax,(%esp)
  800c5e:	e8 82 1f 00 00       	call   802be5 <strcmp>
  800c63:	85 c0                	test   %eax,%eax
  800c65:	74 24                	je     800c8b <check_bc+0x173>
  800c67:	c7 44 24 0c 30 47 80 	movl   $0x804730,0xc(%esp)
  800c6e:	00 
  800c6f:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  800c76:	00 
  800c77:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
  800c7e:	00 
  800c7f:	c7 04 24 54 47 80 00 	movl   $0x804754,(%esp)
  800c86:	e8 a5 16 00 00       	call   802330 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800c8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800c92:	e8 ac fb ff ff       	call   800843 <diskaddr>
  800c97:	c7 44 24 08 10 01 00 	movl   $0x110,0x8(%esp)
  800c9e:	00 
  800c9f:	8d 95 e8 fe ff ff    	lea    -0x118(%ebp),%edx
  800ca5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ca9:	89 04 24             	mov    %eax,(%esp)
  800cac:	e8 64 20 00 00       	call   802d15 <memmove>
	flush_block(diskaddr(1));
  800cb1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800cb8:	e8 86 fb ff ff       	call   800843 <diskaddr>
  800cbd:	89 04 24             	mov    %eax,(%esp)
  800cc0:	e8 54 fd ff ff       	call   800a19 <flush_block>

	cprintf("block cache is good\n");
  800cc5:	c7 04 24 27 48 80 00 	movl   $0x804827,(%esp)
  800ccc:	e8 18 17 00 00       	call   8023e9 <cprintf>
}
  800cd1:	c9                   	leave  
  800cd2:	c3                   	ret    

00800cd3 <bc_init>:

void
bc_init(void)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(bc_pgfault);
  800cd9:	c7 04 24 89 08 80 00 	movl   $0x800889,(%esp)
  800ce0:	e8 3b 26 00 00       	call   803320 <set_pgfault_handler>
	check_bc();
  800ce5:	e8 2e fe ff ff       	call   800b18 <check_bc>
}
  800cea:	c9                   	leave  
  800ceb:	c3                   	ret    
  800cec:	00 00                	add    %al,(%eax)
	...

00800cf0 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800cf0:	55                   	push   %ebp
  800cf1:	89 e5                	mov    %esp,%ebp
  800cf3:	53                   	push   %ebx
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (super == 0 || blockno >= super->s_nblocks)
  800cf7:	8b 15 14 b0 80 00    	mov    0x80b014,%edx
  800cfd:	85 d2                	test   %edx,%edx
  800cff:	74 25                	je     800d26 <block_is_free+0x36>
  800d01:	39 42 04             	cmp    %eax,0x4(%edx)
  800d04:	76 20                	jbe    800d26 <block_is_free+0x36>
  800d06:	89 c1                	mov    %eax,%ecx
  800d08:	83 e1 1f             	and    $0x1f,%ecx
  800d0b:	ba 01 00 00 00       	mov    $0x1,%edx
  800d10:	d3 e2                	shl    %cl,%edx
  800d12:	c1 e8 05             	shr    $0x5,%eax
  800d15:	8b 1d 10 b0 80 00    	mov    0x80b010,%ebx
  800d1b:	85 14 83             	test   %edx,(%ebx,%eax,4)
  800d1e:	0f 95 c0             	setne  %al
  800d21:	0f b6 c0             	movzbl %al,%eax
  800d24:	eb 05                	jmp    800d2b <block_is_free+0x3b>
  800d26:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800d2b:	5b                   	pop    %ebx
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  800d31:	80 38 2f             	cmpb   $0x2f,(%eax)
  800d34:	75 08                	jne    800d3e <skip_slash+0x10>
		p++;
  800d36:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800d39:	80 38 2f             	cmpb   $0x2f,(%eax)
  800d3c:	74 f8                	je     800d36 <skip_slash+0x8>
		p++;
	return p;
}
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <fs_sync>:
}

// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	53                   	push   %ebx
  800d44:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800d47:	a1 14 b0 80 00       	mov    0x80b014,%eax
  800d4c:	83 78 04 01          	cmpl   $0x1,0x4(%eax)
  800d50:	76 2a                	jbe    800d7c <fs_sync+0x3c>
  800d52:	b8 01 00 00 00       	mov    $0x1,%eax
  800d57:	bb 01 00 00 00       	mov    $0x1,%ebx
		flush_block(diskaddr(i));
  800d5c:	89 04 24             	mov    %eax,(%esp)
  800d5f:	e8 df fa ff ff       	call   800843 <diskaddr>
  800d64:	89 04 24             	mov    %eax,(%esp)
  800d67:	e8 ad fc ff ff       	call   800a19 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800d6c:	83 c3 01             	add    $0x1,%ebx
  800d6f:	89 d8                	mov    %ebx,%eax
  800d71:	8b 15 14 b0 80 00    	mov    0x80b014,%edx
  800d77:	39 5a 04             	cmp    %ebx,0x4(%edx)
  800d7a:	77 e0                	ja     800d5c <fs_sync+0x1c>
		flush_block(diskaddr(i));
}
  800d7c:	83 c4 14             	add    $0x14,%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 10             	sub    $0x10,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
  uint32_t i;
	for (i = 0; i < super->s_nblocks; i++) {
  800d8a:	a1 14 b0 80 00       	mov    0x80b014,%eax
  800d8f:	8b 70 04             	mov    0x4(%eax),%esi
  800d92:	85 f6                	test   %esi,%esi
  800d94:	74 43                	je     800dd9 <alloc_block+0x57>
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (block_is_free(i)) { // block is free
  800d9b:	89 1c 24             	mov    %ebx,(%esp)
  800d9e:	e8 4d ff ff ff       	call   800cf0 <block_is_free>
  800da3:	85 c0                	test   %eax,%eax
  800da5:	74 2b                	je     800dd2 <alloc_block+0x50>
				bitmap[i/32] ^= 1<<(i%32);
  800da7:	89 d8                	mov    %ebx,%eax
  800da9:	c1 e8 05             	shr    $0x5,%eax
  800dac:	c1 e0 02             	shl    $0x2,%eax
  800daf:	03 05 10 b0 80 00    	add    0x80b010,%eax
  800db5:	89 d9                	mov    %ebx,%ecx
  800db7:	83 e1 1f             	and    $0x1f,%ecx
  800dba:	ba 01 00 00 00       	mov    $0x1,%edx
  800dbf:	d3 e2                	shl    %cl,%edx
  800dc1:	31 10                	xor    %edx,(%eax)
				flush_block(bitmap);
  800dc3:	a1 10 b0 80 00       	mov    0x80b010,%eax
  800dc8:	89 04 24             	mov    %eax,(%esp)
  800dcb:	e8 49 fc ff ff       	call   800a19 <flush_block>
				return i;
  800dd0:	eb 0c                	jmp    800dde <alloc_block+0x5c>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
  uint32_t i;
	for (i = 0; i < super->s_nblocks; i++) {
  800dd2:	83 c3 01             	add    $0x1,%ebx
  800dd5:	39 f3                	cmp    %esi,%ebx
  800dd7:	72 c2                	jb     800d9b <alloc_block+0x19>
  800dd9:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
				flush_block(bitmap);
				return i;
			}
	}
	return -E_NO_DISK;
}
  800dde:	89 d8                	mov    %ebx,%eax
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5d                   	pop    %ebp
  800de6:	c3                   	ret    

00800de7 <free_block>:
}

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800de7:	55                   	push   %ebp
  800de8:	89 e5                	mov    %esp,%ebp
  800dea:	83 ec 18             	sub    $0x18,%esp
  800ded:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800df0:	85 c9                	test   %ecx,%ecx
  800df2:	75 1c                	jne    800e10 <free_block+0x29>
		panic("attempt to free zero block");
  800df4:	c7 44 24 08 3c 48 80 	movl   $0x80483c,0x8(%esp)
  800dfb:	00 
  800dfc:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  800e03:	00 
  800e04:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  800e0b:	e8 20 15 00 00       	call   802330 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800e10:	89 c8                	mov    %ecx,%eax
  800e12:	c1 e8 05             	shr    $0x5,%eax
  800e15:	c1 e0 02             	shl    $0x2,%eax
  800e18:	03 05 10 b0 80 00    	add    0x80b010,%eax
  800e1e:	83 e1 1f             	and    $0x1f,%ecx
  800e21:	ba 01 00 00 00       	mov    $0x1,%edx
  800e26:	d3 e2                	shl    %cl,%edx
  800e28:	09 10                	or     %edx,(%eax)
}
  800e2a:	c9                   	leave  
  800e2b:	c3                   	ret    

00800e2c <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	56                   	push   %esi
  800e30:	53                   	push   %ebx
  800e31:	83 ec 10             	sub    $0x10,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800e34:	a1 14 b0 80 00       	mov    0x80b014,%eax
  800e39:	8b 70 04             	mov    0x4(%eax),%esi
  800e3c:	85 f6                	test   %esi,%esi
  800e3e:	74 44                	je     800e84 <check_bitmap+0x58>
  800e40:	bb 00 00 00 00       	mov    $0x0,%ebx
		assert(!block_is_free(2+i));
  800e45:	8d 43 02             	lea    0x2(%ebx),%eax
  800e48:	89 04 24             	mov    %eax,(%esp)
  800e4b:	e8 a0 fe ff ff       	call   800cf0 <block_is_free>
  800e50:	85 c0                	test   %eax,%eax
  800e52:	74 24                	je     800e78 <check_bitmap+0x4c>
  800e54:	c7 44 24 0c 5f 48 80 	movl   $0x80485f,0xc(%esp)
  800e5b:	00 
  800e5c:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  800e63:	00 
  800e64:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  800e6b:	00 
  800e6c:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  800e73:	e8 b8 14 00 00       	call   802330 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800e78:	83 c3 01             	add    $0x1,%ebx
  800e7b:	89 d8                	mov    %ebx,%eax
  800e7d:	c1 e0 0f             	shl    $0xf,%eax
  800e80:	39 f0                	cmp    %esi,%eax
  800e82:	72 c1                	jb     800e45 <check_bitmap+0x19>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800e84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e8b:	e8 60 fe ff ff       	call   800cf0 <block_is_free>
  800e90:	85 c0                	test   %eax,%eax
  800e92:	74 24                	je     800eb8 <check_bitmap+0x8c>
  800e94:	c7 44 24 0c 73 48 80 	movl   $0x804873,0xc(%esp)
  800e9b:	00 
  800e9c:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  800ea3:	00 
  800ea4:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  800eab:	00 
  800eac:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  800eb3:	e8 78 14 00 00       	call   802330 <_panic>
	assert(!block_is_free(1));
  800eb8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800ebf:	e8 2c fe ff ff       	call   800cf0 <block_is_free>
  800ec4:	85 c0                	test   %eax,%eax
  800ec6:	74 24                	je     800eec <check_bitmap+0xc0>
  800ec8:	c7 44 24 0c 85 48 80 	movl   $0x804885,0xc(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  800ed7:	00 
  800ed8:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800edf:	00 
  800ee0:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  800ee7:	e8 44 14 00 00       	call   802330 <_panic>

	cprintf("bitmap is good\n");
  800eec:	c7 04 24 97 48 80 00 	movl   $0x804897,(%esp)
  800ef3:	e8 f1 14 00 00       	call   8023e9 <cprintf>
}
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	5b                   	pop    %ebx
  800efc:	5e                   	pop    %esi
  800efd:	5d                   	pop    %ebp
  800efe:	c3                   	ret    

00800eff <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800f05:	a1 14 b0 80 00       	mov    0x80b014,%eax
  800f0a:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800f10:	74 1c                	je     800f2e <check_super+0x2f>
		panic("bad file system magic number");
  800f12:	c7 44 24 08 a7 48 80 	movl   $0x8048a7,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  800f29:	e8 02 14 00 00       	call   802330 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800f2e:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800f35:	76 1c                	jbe    800f53 <check_super+0x54>
		panic("file system is too large");
  800f37:	c7 44 24 08 c4 48 80 	movl   $0x8048c4,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  800f4e:	e8 dd 13 00 00       	call   802330 <_panic>

	cprintf("superblock is good\n");
  800f53:	c7 04 24 dd 48 80 00 	movl   $0x8048dd,(%esp)
  800f5a:	e8 8a 14 00 00       	call   8023e9 <cprintf>
}
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 28             	sub    $0x28,%esp
  800f67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800f70:	89 c6                	mov    %eax,%esi
  800f72:	89 d3                	mov    %edx,%ebx
  800f74:	89 cf                	mov    %ecx,%edi
  int r;
  uint32_t *ptr;
  void *addr;

  if (filebno < NDIRECT)
    ptr = &f->f_direct[filebno];
  800f76:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
	// LAB 5: Your code here.
  int r;
  uint32_t *ptr;
  void *addr;

  if (filebno < NDIRECT)
  800f7d:	83 fa 09             	cmp    $0x9,%edx
  800f80:	76 6e                	jbe    800ff0 <file_block_walk+0x8f>
    ptr = &f->f_direct[filebno];
  else if (filebno < NINDIRECT + NDIRECT) {
  800f82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f87:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  800f8d:	77 68                	ja     800ff7 <file_block_walk+0x96>
    if (f->f_indirect == 0) {
  800f8f:	83 be b0 00 00 00 00 	cmpl   $0x0,0xb0(%esi)
  800f96:	75 46                	jne    800fde <file_block_walk+0x7d>
      if (alloc == 0)
  800f98:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800f9c:	75 04                	jne    800fa2 <file_block_walk+0x41>
  800f9e:	b0 f5                	mov    $0xf5,%al
  800fa0:	eb 55                	jmp    800ff7 <file_block_walk+0x96>
        return -E_NOT_FOUND;
      if ((r = alloc_block()) < 0)
  800fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800fa8:	e8 d5 fd ff ff       	call   800d82 <alloc_block>
  800fad:	89 c2                	mov    %eax,%edx
  800faf:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  800fb4:	85 d2                	test   %edx,%edx
  800fb6:	78 3f                	js     800ff7 <file_block_walk+0x96>
        return -E_NO_DISK;
      f->f_indirect = r;
  800fb8:	89 96 b0 00 00 00    	mov    %edx,0xb0(%esi)
      memset(diskaddr(r), 0, BLKSIZE);
  800fbe:	89 14 24             	mov    %edx,(%esp)
  800fc1:	e8 7d f8 ff ff       	call   800843 <diskaddr>
  800fc6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fcd:	00 
  800fce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd5:	00 
  800fd6:	89 04 24             	mov    %eax,(%esp)
  800fd9:	e8 d8 1c 00 00       	call   802cb6 <memset>
    } else
      alloc = 0;      // we did not allocate a block
    /*
     * set the block number is enough
     */
    ptr = diskaddr(f->f_indirect) + 4 * (filebno - NDIRECT);
  800fde:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800fe4:	89 04 24             	mov    %eax,(%esp)
  800fe7:	e8 57 f8 ff ff       	call   800843 <diskaddr>
  800fec:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  } else
    return -E_INVAL;

  *ppdiskbno = ptr;
  800ff0:	89 07                	mov    %eax,(%edi)
  800ff2:	b8 00 00 00 00       	mov    $0x0,%eax
  return 0;	
}
  800ff7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ffa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801000:	89 ec                	mov    %ebp,%esp
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <file_truncate_blocks>:
// (Remember to clear the f->f_indirect pointer so you'll know
// whether it's valid!)
// Do not change f->f_size.
static void
file_truncate_blocks(struct File *f, off_t newsize)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	83 ec 3c             	sub    $0x3c,%esp
  80100d:	89 c6                	mov    %eax,%esi
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  80100f:	8b b8 80 00 00 00    	mov    0x80(%eax),%edi
  801015:	8d 87 fe 1f 00 00    	lea    0x1ffe(%edi),%eax
  80101b:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
  801021:	0f 48 f8             	cmovs  %eax,%edi
  801024:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  801027:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  80102d:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  801033:	0f 48 d0             	cmovs  %eax,%edx
  801036:	c1 fa 0c             	sar    $0xc,%edx
  801039:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  80103c:	39 d7                	cmp    %edx,%edi
  80103e:	76 4c                	jbe    80108c <file_truncate_blocks+0x88>
  801040:	89 d3                	mov    %edx,%ebx
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  801042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801049:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80104c:	89 da                	mov    %ebx,%edx
  80104e:	89 f0                	mov    %esi,%eax
  801050:	e8 0c ff ff ff       	call   800f61 <file_block_walk>
  801055:	85 c0                	test   %eax,%eax
  801057:	78 1c                	js     801075 <file_truncate_blocks+0x71>
		return r;
	if (*ptr) {
  801059:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80105c:	8b 00                	mov    (%eax),%eax
  80105e:	85 c0                	test   %eax,%eax
  801060:	74 23                	je     801085 <file_truncate_blocks+0x81>
		free_block(*ptr);
  801062:	89 04 24             	mov    %eax,(%esp)
  801065:	e8 7d fd ff ff       	call   800de7 <free_block>
		*ptr = 0;
  80106a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80106d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  801073:	eb 10                	jmp    801085 <file_truncate_blocks+0x81>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  801075:	89 44 24 04          	mov    %eax,0x4(%esp)
  801079:	c7 04 24 f1 48 80 00 	movl   $0x8048f1,(%esp)
  801080:	e8 64 13 00 00       	call   8023e9 <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  801085:	83 c3 01             	add    $0x1,%ebx
  801088:	39 df                	cmp    %ebx,%edi
  80108a:	77 b6                	ja     801042 <file_truncate_blocks+0x3e>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  80108c:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  801090:	77 1c                	ja     8010ae <file_truncate_blocks+0xaa>
  801092:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  801098:	85 c0                	test   %eax,%eax
  80109a:	74 12                	je     8010ae <file_truncate_blocks+0xaa>
		free_block(f->f_indirect);
  80109c:	89 04 24             	mov    %eax,(%esp)
  80109f:	e8 43 fd ff ff       	call   800de7 <free_block>
		f->f_indirect = 0;
  8010a4:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  8010ab:	00 00 00 
	}
}
  8010ae:	83 c4 3c             	add    $0x3c,%esp
  8010b1:	5b                   	pop    %ebx
  8010b2:	5e                   	pop    %esi
  8010b3:	5f                   	pop    %edi
  8010b4:	5d                   	pop    %ebp
  8010b5:	c3                   	ret    

008010b6 <file_set_size>:

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	83 ec 18             	sub    $0x18,%esp
  8010bc:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8010bf:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8010c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8010c5:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  8010c8:	39 b3 80 00 00 00    	cmp    %esi,0x80(%ebx)
  8010ce:	7e 09                	jle    8010d9 <file_set_size+0x23>
		file_truncate_blocks(f, newsize);
  8010d0:	89 f2                	mov    %esi,%edx
  8010d2:	89 d8                	mov    %ebx,%eax
  8010d4:	e8 2b ff ff ff       	call   801004 <file_truncate_blocks>
	f->f_size = newsize;
  8010d9:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  8010df:	89 1c 24             	mov    %ebx,(%esp)
  8010e2:	e8 32 f9 ff ff       	call   800a19 <flush_block>
	return 0;
}
  8010e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ec:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8010ef:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8010f2:	89 ec                	mov    %ebp,%esp
  8010f4:	5d                   	pop    %ebp
  8010f5:	c3                   	ret    

008010f6 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  8010f6:	55                   	push   %ebp
  8010f7:	89 e5                	mov    %esp,%ebp
  8010f9:	57                   	push   %edi
  8010fa:	56                   	push   %esi
  8010fb:	53                   	push   %ebx
  8010fc:	83 ec 2c             	sub    $0x2c,%esp
  8010ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  801102:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  801108:	05 ff 0f 00 00       	add    $0xfff,%eax
  80110d:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  801112:	7e 59                	jle    80116d <file_flush+0x77>
  801114:	be 00 00 00 00       	mov    $0x0,%esi
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801119:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  80111c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801123:	89 f9                	mov    %edi,%ecx
  801125:	89 f2                	mov    %esi,%edx
  801127:	89 d8                	mov    %ebx,%eax
  801129:	e8 33 fe ff ff       	call   800f61 <file_block_walk>
  80112e:	85 c0                	test   %eax,%eax
  801130:	78 1d                	js     80114f <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  801132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801135:	85 c0                	test   %eax,%eax
  801137:	74 16                	je     80114f <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
  801139:	8b 00                	mov    (%eax),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  80113b:	85 c0                	test   %eax,%eax
  80113d:	74 10                	je     80114f <file_flush+0x59>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
  80113f:	89 04 24             	mov    %eax,(%esp)
  801142:	e8 fc f6 ff ff       	call   800843 <diskaddr>
  801147:	89 04 24             	mov    %eax,(%esp)
  80114a:	e8 ca f8 ff ff       	call   800a19 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80114f:	83 c6 01             	add    $0x1,%esi
  801152:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  801158:	8d 90 fe 1f 00 00    	lea    0x1ffe(%eax),%edx
  80115e:	05 ff 0f 00 00       	add    $0xfff,%eax
  801163:	0f 48 c2             	cmovs  %edx,%eax
  801166:	c1 f8 0c             	sar    $0xc,%eax
  801169:	39 f0                	cmp    %esi,%eax
  80116b:	7f af                	jg     80111c <file_flush+0x26>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  80116d:	89 1c 24             	mov    %ebx,(%esp)
  801170:	e8 a4 f8 ff ff       	call   800a19 <flush_block>
	if (f->f_indirect)
  801175:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  80117b:	85 c0                	test   %eax,%eax
  80117d:	74 10                	je     80118f <file_flush+0x99>
		flush_block(diskaddr(f->f_indirect));
  80117f:	89 04 24             	mov    %eax,(%esp)
  801182:	e8 bc f6 ff ff       	call   800843 <diskaddr>
  801187:	89 04 24             	mov    %eax,(%esp)
  80118a:	e8 8a f8 ff ff       	call   800a19 <flush_block>
}
  80118f:	83 c4 2c             	add    $0x2c,%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    

00801197 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	83 ec 28             	sub    $0x28,%esp
	// LAB 5: Your code here.
	int r;
  uint32_t *ptr;

  if ((r = file_block_walk(f, filebno, &ptr, 1)) != 0)
  80119d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  8011a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8011a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ad:	e8 af fd ff ff       	call   800f61 <file_block_walk>
  8011b2:	89 c2                	mov    %eax,%edx
  8011b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b9:	85 d2                	test   %edx,%edx
  8011bb:	75 54                	jne    801211 <file_get_block+0x7a>
    return -E_INVAL;
  if (*ptr == 0) {
  8011bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c0:	83 38 00             	cmpl   $0x0,(%eax)
  8011c3:	75 35                	jne    8011fa <file_get_block+0x63>
    if ((r = alloc_block()) < 0)
  8011c5:	e8 b8 fb ff ff       	call   800d82 <alloc_block>
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
  8011d1:	85 d2                	test   %edx,%edx
  8011d3:	78 3c                	js     801211 <file_get_block+0x7a>
      return -E_NO_DISK;
    *ptr = r;
  8011d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d8:	89 10                	mov    %edx,(%eax)
    memset(diskaddr(r), 0, BLKSIZE);
  8011da:	89 14 24             	mov    %edx,(%esp)
  8011dd:	e8 61 f6 ff ff       	call   800843 <diskaddr>
  8011e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8011e9:	00 
  8011ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011f1:	00 
  8011f2:	89 04 24             	mov    %eax,(%esp)
  8011f5:	e8 bc 1a 00 00       	call   802cb6 <memset>
//    flush_block(diskaddr(r));
  }
  *blk = diskaddr(*ptr);
  8011fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011fd:	8b 00                	mov    (%eax),%eax
  8011ff:	89 04 24             	mov    %eax,(%esp)
  801202:	e8 3c f6 ff ff       	call   800843 <diskaddr>
  801207:	8b 55 10             	mov    0x10(%ebp),%edx
  80120a:	89 02                	mov    %eax,(%edx)
  80120c:	b8 00 00 00 00       	mov    $0x0,%eax
  return 0;
}
  801211:	c9                   	leave  
  801212:	c3                   	ret    

00801213 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  801213:	55                   	push   %ebp
  801214:	89 e5                	mov    %esp,%ebp
  801216:	57                   	push   %edi
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  80121f:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  801225:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  80122b:	e8 fe fa ff ff       	call   800d2e <skip_slash>
  801230:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	f = &super->s_root;
  801236:	a1 14 b0 80 00       	mov    0x80b014,%eax
	dir = 0;
	name[0] = 0;
  80123b:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  801242:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  801249:	74 0c                	je     801257 <walk_path+0x44>
		*pdir = 0;
  80124b:	8b 95 40 ff ff ff    	mov    -0xc0(%ebp),%edx
  801251:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  801257:	83 c0 08             	add    $0x8,%eax
  80125a:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
  801260:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  801266:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
  80126c:	ba 00 00 00 00       	mov    $0x0,%edx
	while (*path != '\0') {
  801271:	e9 a1 01 00 00       	jmp    801417 <walk_path+0x204>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  801276:	83 c6 01             	add    $0x1,%esi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  801279:	0f b6 06             	movzbl (%esi),%eax
  80127c:	3c 2f                	cmp    $0x2f,%al
  80127e:	74 04                	je     801284 <walk_path+0x71>
  801280:	84 c0                	test   %al,%al
  801282:	75 f2                	jne    801276 <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  801284:	89 f3                	mov    %esi,%ebx
  801286:	2b 9d 48 ff ff ff    	sub    -0xb8(%ebp),%ebx
  80128c:	83 fb 7f             	cmp    $0x7f,%ebx
  80128f:	7e 0a                	jle    80129b <walk_path+0x88>
  801291:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801296:	e9 c3 01 00 00       	jmp    80145e <walk_path+0x24b>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  80129b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80129f:	8b 85 48 ff ff ff    	mov    -0xb8(%ebp),%eax
  8012a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a9:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  8012af:	89 14 24             	mov    %edx,(%esp)
  8012b2:	e8 5e 1a 00 00       	call   802d15 <memmove>
		name[path - p] = '\0';
  8012b7:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  8012be:	00 
		path = skip_slash(path);
  8012bf:	89 f0                	mov    %esi,%eax
  8012c1:	e8 68 fa ff ff       	call   800d2e <skip_slash>
  8012c6:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

		if (dir->f_type != FTYPE_DIR)
  8012cc:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  8012d2:	83 b9 84 00 00 00 01 	cmpl   $0x1,0x84(%ecx)
  8012d9:	0f 85 7a 01 00 00    	jne    801459 <walk_path+0x246>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  8012df:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  8012e5:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8012ea:	74 24                	je     801310 <walk_path+0xfd>
  8012ec:	c7 44 24 0c 0e 49 80 	movl   $0x80490e,0xc(%esp)
  8012f3:	00 
  8012f4:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  8012fb:	00 
  8012fc:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
  801303:	00 
  801304:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  80130b:	e8 20 10 00 00       	call   802330 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801310:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801316:	85 c0                	test   %eax,%eax
  801318:	0f 48 c2             	cmovs  %edx,%eax
  80131b:	c1 f8 0c             	sar    $0xc,%eax
  80131e:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
	for (i = 0; i < nblock; i++) {
  801324:	85 c0                	test   %eax,%eax
  801326:	0f 84 8a 00 00 00    	je     8013b6 <walk_path+0x1a3>
  80132c:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  801333:	00 00 00 
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  801336:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80133c:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  801342:	89 44 24 08          	mov    %eax,0x8(%esp)
  801346:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  80134c:	89 54 24 04          	mov    %edx,0x4(%esp)
  801350:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  801356:	89 0c 24             	mov    %ecx,(%esp)
  801359:	e8 39 fe ff ff       	call   801197 <file_get_block>
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 4b                	js     8013ad <walk_path+0x19a>
  801362:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  801368:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
  80136e:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  801374:	89 74 24 04          	mov    %esi,0x4(%esp)
  801378:	89 1c 24             	mov    %ebx,(%esp)
  80137b:	e8 65 18 00 00       	call   802be5 <strcmp>
  801380:	85 c0                	test   %eax,%eax
  801382:	0f 84 83 00 00 00    	je     80140b <walk_path+0x1f8>
  801388:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  80138e:	3b 9d 54 ff ff ff    	cmp    -0xac(%ebp),%ebx
  801394:	75 de                	jne    801374 <walk_path+0x161>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  801396:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  80139d:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  8013a3:	39 95 44 ff ff ff    	cmp    %edx,-0xbc(%ebp)
  8013a9:	77 91                	ja     80133c <walk_path+0x129>
  8013ab:	eb 09                	jmp    8013b6 <walk_path+0x1a3>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  8013ad:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8013b0:	0f 85 a8 00 00 00    	jne    80145e <walk_path+0x24b>
  8013b6:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  8013bc:	80 39 00             	cmpb   $0x0,(%ecx)
  8013bf:	90                   	nop
  8013c0:	0f 85 93 00 00 00    	jne    801459 <walk_path+0x246>
				if (pdir)
  8013c6:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  8013cd:	74 0e                	je     8013dd <walk_path+0x1ca>
					*pdir = dir;
  8013cf:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  8013d5:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  8013db:	89 10                	mov    %edx,(%eax)
				if (lastelem)
  8013dd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  8013e1:	74 15                	je     8013f8 <walk_path+0x1e5>
					strcpy(lastelem, name);
  8013e3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8013e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013f0:	89 0c 24             	mov    %ecx,(%esp)
  8013f3:	e8 32 17 00 00       	call   802b2a <strcpy>
				*pf = 0;
  8013f8:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  8013fe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  801404:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  801409:	eb 53                	jmp    80145e <walk_path+0x24b>
  80140b:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  801411:	89 9d 4c ff ff ff    	mov    %ebx,-0xb4(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  801417:	8b 8d 48 ff ff ff    	mov    -0xb8(%ebp),%ecx
  80141d:	0f b6 01             	movzbl (%ecx),%eax
  801420:	84 c0                	test   %al,%al
  801422:	74 0f                	je     801433 <walk_path+0x220>
  801424:	89 ce                	mov    %ecx,%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  801426:	3c 2f                	cmp    $0x2f,%al
  801428:	0f 85 48 fe ff ff    	jne    801276 <walk_path+0x63>
  80142e:	e9 51 fe ff ff       	jmp    801284 <walk_path+0x71>
			}
			return r;
		}
	}

	if (pdir)
  801433:	83 bd 40 ff ff ff 00 	cmpl   $0x0,-0xc0(%ebp)
  80143a:	74 08                	je     801444 <walk_path+0x231>
		*pdir = dir;
  80143c:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  801442:	89 10                	mov    %edx,(%eax)
	*pf = f;
  801444:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  80144a:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
  801450:	89 0a                	mov    %ecx,(%edx)
  801452:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801457:	eb 05                	jmp    80145e <walk_path+0x24b>
  801459:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
}
  80145e:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  801464:	5b                   	pop    %ebx
  801465:	5e                   	pop    %esi
  801466:	5f                   	pop    %edi
  801467:	5d                   	pop    %ebp
  801468:	c3                   	ret    

00801469 <file_remove>:
}

// Remove a file by truncating it and then zeroing the name.
int
file_remove(const char *path)
{
  801469:	55                   	push   %ebp
  80146a:	89 e5                	mov    %esp,%ebp
  80146c:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct File *f;

	if ((r = walk_path(path, 0, &f, 0)) < 0)
  80146f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  801472:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	8b 45 08             	mov    0x8(%ebp),%eax
  801481:	e8 8d fd ff ff       	call   801213 <walk_path>
  801486:	85 c0                	test   %eax,%eax
  801488:	78 30                	js     8014ba <file_remove+0x51>
		return r;

	file_truncate_blocks(f, 0);
  80148a:	ba 00 00 00 00       	mov    $0x0,%edx
  80148f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801492:	e8 6d fb ff ff       	call   801004 <file_truncate_blocks>
	f->f_name[0] = '\0';
  801497:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149a:	c6 00 00             	movb   $0x0,(%eax)
	f->f_size = 0;
  80149d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a0:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
  8014a7:	00 00 00 
	flush_block(f);
  8014aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 64 f5 ff ff       	call   800a19 <flush_block>
  8014b5:	b8 00 00 00 00       	mov    $0x0,%eax

	return 0;
}
  8014ba:	c9                   	leave  
  8014bb:	c3                   	ret    

008014bc <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  8014c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d4:	e8 3a fd ff ff       	call   801213 <walk_path>
}
  8014d9:	c9                   	leave  
  8014da:	c3                   	ret    

008014db <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	57                   	push   %edi
  8014df:	56                   	push   %esi
  8014e0:	53                   	push   %ebx
  8014e1:	83 ec 3c             	sub    $0x3c,%esp
  8014e4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8014e7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  8014ea:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8014ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8014f0:	01 d8                	add    %ebx,%eax
  8014f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8014f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014f8:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  8014fe:	77 0d                	ja     80150d <file_write+0x32>
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  801500:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801503:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  801506:	72 1d                	jb     801525 <file_write+0x4a>
  801508:	e9 85 00 00 00       	jmp    801592 <file_write+0xb7>
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
  80150d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801510:	89 54 24 04          	mov    %edx,0x4(%esp)
  801514:	8b 45 08             	mov    0x8(%ebp),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 97 fb ff ff       	call   8010b6 <file_set_size>
  80151f:	85 c0                	test   %eax,%eax
  801521:	79 dd                	jns    801500 <file_write+0x25>
  801523:	eb 70                	jmp    801595 <file_write+0xba>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  801525:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801528:	89 54 24 08          	mov    %edx,0x8(%esp)
  80152c:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  801532:	85 db                	test   %ebx,%ebx
  801534:	0f 49 c3             	cmovns %ebx,%eax
  801537:	c1 f8 0c             	sar    $0xc,%eax
  80153a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80153e:	8b 45 08             	mov    0x8(%ebp),%eax
  801541:	89 04 24             	mov    %eax,(%esp)
  801544:	e8 4e fc ff ff       	call   801197 <file_get_block>
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 48                	js     801595 <file_write+0xba>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  80154d:	89 da                	mov    %ebx,%edx
  80154f:	c1 fa 1f             	sar    $0x1f,%edx
  801552:	c1 ea 14             	shr    $0x14,%edx
  801555:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801558:	25 ff 0f 00 00       	and    $0xfff,%eax
  80155d:	29 d0                	sub    %edx,%eax
  80155f:	be 00 10 00 00       	mov    $0x1000,%esi
  801564:	29 c6                	sub    %eax,%esi
  801566:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801569:	2b 55 d0             	sub    -0x30(%ebp),%edx
  80156c:	39 d6                	cmp    %edx,%esi
  80156e:	0f 47 f2             	cmova  %edx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  801571:	89 74 24 08          	mov    %esi,0x8(%esp)
  801575:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801579:	03 45 e4             	add    -0x1c(%ebp),%eax
  80157c:	89 04 24             	mov    %eax,(%esp)
  80157f:	e8 91 17 00 00       	call   802d15 <memmove>
		pos += bn;
  801584:	01 f3                	add    %esi,%ebx
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  801586:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801589:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  80158c:	76 04                	jbe    801592 <file_write+0xb7>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
  80158e:	01 f7                	add    %esi,%edi
  801590:	eb 93                	jmp    801525 <file_write+0x4a>
	}

	return count;
  801592:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801595:	83 c4 3c             	add    $0x3c,%esp
  801598:	5b                   	pop    %ebx
  801599:	5e                   	pop    %esi
  80159a:	5f                   	pop    %edi
  80159b:	5d                   	pop    %ebp
  80159c:	c3                   	ret    

0080159d <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	57                   	push   %edi
  8015a1:	56                   	push   %esi
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 3c             	sub    $0x3c,%esp
  8015a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015a9:	8b 55 10             	mov    0x10(%ebp),%edx
  8015ac:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8015af:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b2:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
  8015b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bd:	39 d9                	cmp    %ebx,%ecx
  8015bf:	0f 8e 88 00 00 00    	jle    80164d <file_read+0xb0>
		return 0;

	count = MIN(count, f->f_size - offset);
  8015c5:	29 d9                	sub    %ebx,%ecx
  8015c7:	39 d1                	cmp    %edx,%ecx
  8015c9:	0f 46 d1             	cmovbe %ecx,%edx
  8015cc:	89 55 cc             	mov    %edx,-0x34(%ebp)

	for (pos = offset; pos < offset + count; ) {
  8015cf:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8015d2:	89 d0                	mov    %edx,%eax
  8015d4:	01 d8                	add    %ebx,%eax
  8015d6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8015d9:	39 d8                	cmp    %ebx,%eax
  8015db:	76 6d                	jbe    80164a <file_read+0xad>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  8015dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015e4:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  8015ea:	85 db                	test   %ebx,%ebx
  8015ec:	0f 49 c3             	cmovns %ebx,%eax
  8015ef:	c1 f8 0c             	sar    $0xc,%eax
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f9:	89 04 24             	mov    %eax,(%esp)
  8015fc:	e8 96 fb ff ff       	call   801197 <file_get_block>
  801601:	85 c0                	test   %eax,%eax
  801603:	78 48                	js     80164d <file_read+0xb0>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  801605:	89 da                	mov    %ebx,%edx
  801607:	c1 fa 1f             	sar    $0x1f,%edx
  80160a:	c1 ea 14             	shr    $0x14,%edx
  80160d:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  801610:	25 ff 0f 00 00       	and    $0xfff,%eax
  801615:	29 d0                	sub    %edx,%eax
  801617:	be 00 10 00 00       	mov    $0x1000,%esi
  80161c:	29 c6                	sub    %eax,%esi
  80161e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  801621:	2b 55 d0             	sub    -0x30(%ebp),%edx
  801624:	39 d6                	cmp    %edx,%esi
  801626:	0f 47 f2             	cmova  %edx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  801629:	89 74 24 08          	mov    %esi,0x8(%esp)
  80162d:	03 45 e4             	add    -0x1c(%ebp),%eax
  801630:	89 44 24 04          	mov    %eax,0x4(%esp)
  801634:	89 3c 24             	mov    %edi,(%esp)
  801637:	e8 d9 16 00 00       	call   802d15 <memmove>
		pos += bn;
  80163c:	01 f3                	add    %esi,%ebx
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  80163e:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  801641:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  801644:	76 04                	jbe    80164a <file_read+0xad>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
  801646:	01 f7                	add    %esi,%edi
  801648:	eb 93                	jmp    8015dd <file_read+0x40>
	}

	return count;
  80164a:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
  80164d:	83 c4 3c             	add    $0x3c,%esp
  801650:	5b                   	pop    %ebx
  801651:	5e                   	pop    %esi
  801652:	5f                   	pop    %edi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    

00801655 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	57                   	push   %edi
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
  80165b:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  801661:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  801667:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  80166d:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801673:	89 04 24             	mov    %eax,(%esp)
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	e8 95 fb ff ff       	call   801213 <walk_path>
  80167e:	85 c0                	test   %eax,%eax
  801680:	75 0a                	jne    80168c <file_create+0x37>
  801682:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  801687:	e9 ee 00 00 00       	jmp    80177a <file_create+0x125>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  80168c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80168f:	90                   	nop
  801690:	0f 85 e4 00 00 00    	jne    80177a <file_create+0x125>
  801696:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  80169c:	85 f6                	test   %esi,%esi
  80169e:	0f 84 d6 00 00 00    	je     80177a <file_create+0x125>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  8016a4:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  8016aa:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8016af:	74 24                	je     8016d5 <file_create+0x80>
  8016b1:	c7 44 24 0c 0e 49 80 	movl   $0x80490e,0xc(%esp)
  8016b8:	00 
  8016b9:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  8016c0:	00 
  8016c1:	c7 44 24 04 ef 00 00 	movl   $0xef,0x4(%esp)
  8016c8:	00 
  8016c9:	c7 04 24 57 48 80 00 	movl   $0x804857,(%esp)
  8016d0:	e8 5b 0c 00 00       	call   802330 <_panic>
	nblock = dir->f_size / BLKSIZE;
  8016d5:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	0f 48 c2             	cmovs  %edx,%eax
  8016e0:	c1 f8 0c             	sar    $0xc,%eax
  8016e3:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  8016e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	74 56                	je     801748 <file_create+0xf3>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8016f2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8016f8:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8016fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801700:	89 34 24             	mov    %esi,(%esp)
  801703:	e8 8f fa ff ff       	call   801197 <file_get_block>
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 6e                	js     80177a <file_create+0x125>
			return r;
		f = (struct File*) blk;
  80170c:	8b 8d 5c ff ff ff    	mov    -0xa4(%ebp),%ecx
  801712:	89 ca                	mov    %ecx,%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  801714:	80 39 00             	cmpb   $0x0,(%ecx)
  801717:	74 13                	je     80172c <file_create+0xd7>
  801719:	8d 81 00 01 00 00    	lea    0x100(%ecx),%eax
// --------------------------------------------------------------

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
  80171f:	81 c1 00 10 00 00    	add    $0x1000,%ecx
  801725:	89 c2                	mov    %eax,%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  801727:	80 38 00             	cmpb   $0x0,(%eax)
  80172a:	75 08                	jne    801734 <file_create+0xdf>
				*file = &f[j];
  80172c:	89 95 60 ff ff ff    	mov    %edx,-0xa0(%ebp)
  801732:	eb 51                	jmp    801785 <file_create+0x130>
  801734:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  801739:	39 c8                	cmp    %ecx,%eax
  80173b:	75 e8                	jne    801725 <file_create+0xd0>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  80173d:	83 c3 01             	add    $0x1,%ebx
  801740:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  801746:	77 b0                	ja     8016f8 <file_create+0xa3>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  801748:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  80174f:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  801752:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  801758:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801760:	89 34 24             	mov    %esi,(%esp)
  801763:	e8 2f fa ff ff       	call   801197 <file_get_block>
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 0e                	js     80177a <file_create+0x125>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  80176c:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801772:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  801778:	eb 0b                	jmp    801785 <file_create+0x130>
		return r;
	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  80177a:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5f                   	pop    %edi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;
	strcpy(f->f_name, name);
  801785:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80178b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80178f:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 8d 13 00 00       	call   802b2a <strcpy>
	*pf = f;
  80179d:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  8017a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a6:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  8017a8:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  8017ae:	89 04 24             	mov    %eax,(%esp)
  8017b1:	e8 40 f9 ff ff       	call   8010f6 <file_flush>
  8017b6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8017bb:	eb bd                	jmp    80177a <file_create+0x125>

008017bd <fs_init>:
// --------------------------------------------------------------

// Initialize the file system
void
fs_init(void)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available.
	if (ide_probe_disk1())
  8017c3:	e8 2d eb ff ff       	call   8002f5 <ide_probe_disk1>
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	74 0e                	je     8017da <fs_init+0x1d>
		ide_set_disk(1);
  8017cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017d3:	e8 ec ea ff ff       	call   8002c4 <ide_set_disk>
  8017d8:	eb 0c                	jmp    8017e6 <fs_init+0x29>
	else
		ide_set_disk(0);
  8017da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e1:	e8 de ea ff ff       	call   8002c4 <ide_set_disk>

	bc_init();
  8017e6:	e8 e8 f4 ff ff       	call   800cd3 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8017eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8017f2:	e8 4c f0 ff ff       	call   800843 <diskaddr>
  8017f7:	a3 14 b0 80 00       	mov    %eax,0x80b014
	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  8017fc:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801803:	e8 3b f0 ff ff       	call   800843 <diskaddr>
  801808:	a3 10 b0 80 00       	mov    %eax,0x80b010

	check_super();
  80180d:	e8 ed f6 ff ff       	call   800eff <check_super>
	check_bitmap();
  801812:	e8 15 f6 ff ff       	call   800e2c <check_bitmap>
}
  801817:	c9                   	leave  
  801818:	c3                   	ret    
  801819:	00 00                	add    %al,(%eax)
  80181b:	00 00                	add    %al,(%eax)
  80181d:	00 00                	add    %al,(%eax)
	...

00801820 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801820:	55                   	push   %ebp
  801821:	89 e5                	mov    %esp,%ebp
  801823:	ba 20 60 80 00       	mov    $0x806020,%edx
  801828:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
  80182d:	b8 00 00 00 00       	mov    $0x0,%eax
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
		opentab[i].o_fileid = i;
  801832:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801834:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  801837:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  80183d:	83 c0 01             	add    $0x1,%eax
  801840:	83 c2 10             	add    $0x10,%edx
  801843:	3d 00 04 00 00       	cmp    $0x400,%eax
  801848:	75 e8                	jne    801832 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80184a:	5d                   	pop    %ebp
  80184b:	c3                   	ret    

0080184c <serve_sync>:
}

// Sync the file system.
int
serve_sync(envid_t envid, union Fsipc *req)
{
  80184c:	55                   	push   %ebp
  80184d:	89 e5                	mov    %esp,%ebp
  80184f:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801852:	e8 e9 f4 ff ff       	call   800d40 <fs_sync>
	return 0;
}
  801857:	b8 00 00 00 00       	mov    $0x0,%eax
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    

0080185e <serve_remove>:
}

// Remove the file req->req_path.
int
serve_remove(envid_t envid, struct Fsreq_remove *req)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	81 ec 14 04 00 00    	sub    $0x414,%esp

	// Delete the named file.
	// Note: This request doesn't refer to an open file.

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801868:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  80186f:	00 
  801870:	8b 45 0c             	mov    0xc(%ebp),%eax
  801873:	89 44 24 04          	mov    %eax,0x4(%esp)
  801877:	8d 9d f8 fb ff ff    	lea    -0x408(%ebp),%ebx
  80187d:	89 1c 24             	mov    %ebx,(%esp)
  801880:	e8 90 14 00 00       	call   802d15 <memmove>
	path[MAXPATHLEN-1] = 0;
  801885:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Delete the specified file
	return file_remove(path);
  801889:	89 1c 24             	mov    %ebx,(%esp)
  80188c:	e8 d8 fb ff ff       	call   801469 <file_remove>
}
  801891:	81 c4 14 04 00 00    	add    $0x414,%esp
  801897:	5b                   	pop    %ebx
  801898:	5d                   	pop    %ebp
  801899:	c3                   	ret    

0080189a <openfile_lookup>:
}

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  80189a:	55                   	push   %ebp
  80189b:	89 e5                	mov    %esp,%ebp
  80189d:	83 ec 18             	sub    $0x18,%esp
  8018a0:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018a3:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8018a9:	89 f3                	mov    %esi,%ebx
  8018ab:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  8018b1:	c1 e3 04             	shl    $0x4,%ebx
  8018b4:	81 c3 20 60 80 00    	add    $0x806020,%ebx
	if (pageref(o->o_fd) == 1 || o->o_fileid != fileid)
  8018ba:	8b 43 0c             	mov    0xc(%ebx),%eax
  8018bd:	89 04 24             	mov    %eax,(%esp)
  8018c0:	e8 3b 25 00 00       	call   803e00 <pageref>
  8018c5:	83 f8 01             	cmp    $0x1,%eax
  8018c8:	74 10                	je     8018da <openfile_lookup+0x40>
  8018ca:	39 33                	cmp    %esi,(%ebx)
  8018cc:	75 0c                	jne    8018da <openfile_lookup+0x40>
		return -E_INVAL;
	*po = o;
  8018ce:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d1:	89 18                	mov    %ebx,(%eax)
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8018d8:	eb 05                	jmp    8018df <openfile_lookup+0x45>
  8018da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8018df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018e5:	89 ec                	mov    %ebp,%esp
  8018e7:	5d                   	pop    %ebp
  8018e8:	c3                   	ret    

008018e9 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8018e9:	55                   	push   %ebp
  8018ea:	89 e5                	mov    %esp,%ebp
  8018ec:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8018ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f9:	8b 00                	mov    (%eax),%eax
  8018fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801902:	89 04 24             	mov    %eax,(%esp)
  801905:	e8 90 ff ff ff       	call   80189a <openfile_lookup>
  80190a:	85 c0                	test   %eax,%eax
  80190c:	78 13                	js     801921 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  80190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801911:	8b 40 04             	mov    0x4(%eax),%eax
  801914:	89 04 24             	mov    %eax,(%esp)
  801917:	e8 da f7 ff ff       	call   8010f6 <file_flush>
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	53                   	push   %ebx
  801927:	83 ec 24             	sub    $0x24,%esp
  80192a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80192d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801930:	89 44 24 08          	mov    %eax,0x8(%esp)
  801934:	8b 03                	mov    (%ebx),%eax
  801936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193a:	8b 45 08             	mov    0x8(%ebp),%eax
  80193d:	89 04 24             	mov    %eax,(%esp)
  801940:	e8 55 ff ff ff       	call   80189a <openfile_lookup>
  801945:	85 c0                	test   %eax,%eax
  801947:	78 3f                	js     801988 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  801949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194c:	8b 40 04             	mov    0x4(%eax),%eax
  80194f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801953:	89 1c 24             	mov    %ebx,(%esp)
  801956:	e8 cf 11 00 00       	call   802b2a <strcpy>
	ret->ret_size = o->o_file->f_size;
  80195b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195e:	8b 50 04             	mov    0x4(%eax),%edx
  801961:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801967:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80196d:	8b 40 04             	mov    0x4(%eax),%eax
  801970:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801977:	0f 94 c0             	sete   %al
  80197a:	0f b6 c0             	movzbl %al,%eax
  80197d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801988:	83 c4 24             	add    $0x24,%esp
  80198b:	5b                   	pop    %ebx
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	53                   	push   %ebx
  801992:	83 ec 24             	sub    $0x24,%esp
  801995:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	// LAB 5: Your code here.
  struct OpenFile *o;
  int r;

  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801998:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80199b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80199f:	8b 03                	mov    (%ebx),%eax
  8019a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a8:	89 04 24             	mov    %eax,(%esp)
  8019ab:	e8 ea fe ff ff       	call   80189a <openfile_lookup>
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 40                	js     8019f4 <serve_write+0x66>
    return r;
  r = file_write(o->o_file, req->req_buf,
      MIN(req->req_n, PGSIZE), o->o_fd->fd_offset);
  8019b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  struct OpenFile *o;
  int r;

  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
    return r;
  r = file_write(o->o_file, req->req_buf,
  8019b7:	8b 50 0c             	mov    0xc(%eax),%edx
  8019ba:	8b 52 04             	mov    0x4(%edx),%edx
  8019bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8019c1:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  8019c8:	ba 00 10 00 00       	mov    $0x1000,%edx
  8019cd:	0f 46 53 04          	cmovbe 0x4(%ebx),%edx
  8019d1:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019d5:	83 c3 08             	add    $0x8,%ebx
  8019d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019dc:	8b 40 04             	mov    0x4(%eax),%eax
  8019df:	89 04 24             	mov    %eax,(%esp)
  8019e2:	e8 f4 fa ff ff       	call   8014db <file_write>
      MIN(req->req_n, PGSIZE), o->o_fd->fd_offset);
  if (r > 0)
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	7e 09                	jle    8019f4 <serve_write+0x66>
    o->o_fd->fd_offset += r;
  8019eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019ee:	8b 52 0c             	mov    0xc(%edx),%edx
  8019f1:	01 42 04             	add    %eax,0x4(%edx)
  return r;	
}
  8019f4:	83 c4 24             	add    $0x24,%esp
  8019f7:	5b                   	pop    %ebx
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	83 ec 20             	sub    $0x20,%esp
  801a02:	8b 75 0c             	mov    0xc(%ebp),%esi
	// so filling in ret will overwrite req.
	//
	// Hint: Use file_read.
	// Hint: The seek position is stored in the struct Fd.
	// LAB 5: Your code here 
  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
  801a05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0c:	8b 06                	mov    (%esi),%eax
  801a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	89 04 24             	mov    %eax,(%esp)
  801a18:	e8 7d fe ff ff       	call   80189a <openfile_lookup>
  801a1d:	89 c3                	mov    %eax,%ebx
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	79 0e                	jns    801a31 <serve_read+0x37>
    cprintf("serve_read: failed to lookup open fileid\n");
  801a23:	c7 04 24 2c 49 80 00 	movl   $0x80492c,(%esp)
  801a2a:	e8 ba 09 00 00       	call   8023e9 <cprintf>
    return r;
  801a2f:	eb 3b                	jmp    801a6c <serve_read+0x72>
  }
  nbytes = MIN(req->req_n, PGSIZE);
  if ((nbytes = file_read(o->o_file, (void *)ret->ret_buf,
      nbytes, o->o_fd->fd_offset)) >= 0)
  801a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0) {
    cprintf("serve_read: failed to lookup open fileid\n");
    return r;
  }
  nbytes = MIN(req->req_n, PGSIZE);
  if ((nbytes = file_read(o->o_file, (void *)ret->ret_buf,
  801a34:	8b 50 0c             	mov    0xc(%eax),%edx
  801a37:	8b 52 04             	mov    0x4(%edx),%edx
  801a3a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801a3e:	81 7e 04 00 10 00 00 	cmpl   $0x1000,0x4(%esi)
  801a45:	ba 00 10 00 00       	mov    $0x1000,%edx
  801a4a:	0f 46 56 04          	cmovbe 0x4(%esi),%edx
  801a4e:	89 54 24 08          	mov    %edx,0x8(%esp)
  801a52:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a56:	8b 40 04             	mov    0x4(%eax),%eax
  801a59:	89 04 24             	mov    %eax,(%esp)
  801a5c:	e8 3c fb ff ff       	call   80159d <file_read>
  801a61:	89 c3                	mov    %eax,%ebx
      nbytes, o->o_fd->fd_offset)) >= 0)
    o->o_fd->fd_offset += nbytes;
  801a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a66:	8b 40 0c             	mov    0xc(%eax),%eax
  801a69:	01 58 04             	add    %ebx,0x4(%eax)
  return nbytes;
}
  801a6c:	89 d8                	mov    %ebx,%eax
  801a6e:	83 c4 20             	add    $0x20,%esp
  801a71:	5b                   	pop    %ebx
  801a72:	5e                   	pop    %esi
  801a73:	5d                   	pop    %ebp
  801a74:	c3                   	ret    

00801a75 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801a75:	55                   	push   %ebp
  801a76:	89 e5                	mov    %esp,%ebp
  801a78:	53                   	push   %ebx
  801a79:	83 ec 24             	sub    $0x24,%esp
  801a7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801a7f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a82:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a86:	8b 03                	mov    (%ebx),%eax
  801a88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8f:	89 04 24             	mov    %eax,(%esp)
  801a92:	e8 03 fe ff ff       	call   80189a <openfile_lookup>
  801a97:	85 c0                	test   %eax,%eax
  801a99:	78 15                	js     801ab0 <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801a9b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa5:	8b 40 04             	mov    0x4(%eax),%eax
  801aa8:	89 04 24             	mov    %eax,(%esp)
  801aab:	e8 06 f6 ff ff       	call   8010b6 <file_set_size>
}
  801ab0:	83 c4 24             	add    $0x24,%esp
  801ab3:	5b                   	pop    %ebx
  801ab4:	5d                   	pop    %ebp
  801ab5:	c3                   	ret    

00801ab6 <openfile_alloc>:
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801ab6:	55                   	push   %ebp
  801ab7:	89 e5                	mov    %esp,%ebp
  801ab9:	83 ec 28             	sub    $0x28,%esp
  801abc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801abf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801ac2:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ac8:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  801acd:	be 2c 60 80 00       	mov    $0x80602c,%esi
  801ad2:	89 d8                	mov    %ebx,%eax
  801ad4:	c1 e0 04             	shl    $0x4,%eax
  801ad7:	8b 04 30             	mov    (%eax,%esi,1),%eax
  801ada:	89 04 24             	mov    %eax,(%esp)
  801add:	e8 1e 23 00 00       	call   803e00 <pageref>
  801ae2:	85 c0                	test   %eax,%eax
  801ae4:	74 0c                	je     801af2 <openfile_alloc+0x3c>
  801ae6:	83 f8 01             	cmp    $0x1,%eax
  801ae9:	75 67                	jne    801b52 <openfile_alloc+0x9c>
  801aeb:	90                   	nop
  801aec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801af0:	eb 27                	jmp    801b19 <openfile_alloc+0x63>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  801af2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801af9:	00 
  801afa:	89 d8                	mov    %ebx,%eax
  801afc:	c1 e0 04             	shl    $0x4,%eax
  801aff:	8b 80 2c 60 80 00    	mov    0x80602c(%eax),%eax
  801b05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b10:	e8 78 16 00 00       	call   80318d <sys_page_alloc>
  801b15:	85 c0                	test   %eax,%eax
  801b17:	78 4d                	js     801b66 <openfile_alloc+0xb0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801b19:	c1 e3 04             	shl    $0x4,%ebx
  801b1c:	81 83 20 60 80 00 00 	addl   $0x400,0x806020(%ebx)
  801b23:	04 00 00 
			*o = &opentab[i];
  801b26:	8d 83 20 60 80 00    	lea    0x806020(%ebx),%eax
  801b2c:	89 07                	mov    %eax,(%edi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801b2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801b35:	00 
  801b36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b3d:	00 
  801b3e:	8b 83 2c 60 80 00    	mov    0x80602c(%ebx),%eax
  801b44:	89 04 24             	mov    %eax,(%esp)
  801b47:	e8 6a 11 00 00       	call   802cb6 <memset>
			return (*o)->o_fileid;
  801b4c:	8b 07                	mov    (%edi),%eax
  801b4e:	8b 00                	mov    (%eax),%eax
  801b50:	eb 14                	jmp    801b66 <openfile_alloc+0xb0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801b52:	83 c3 01             	add    $0x1,%ebx
  801b55:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801b5b:	0f 85 71 ff ff ff    	jne    801ad2 <openfile_alloc+0x1c>
  801b61:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
}
  801b66:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b69:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b6c:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b6f:	89 ec                	mov    %ebp,%esp
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	53                   	push   %ebx
  801b77:	81 ec 24 04 00 00    	sub    $0x424,%esp
  801b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801b80:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  801b87:	00 
  801b88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b8c:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 7b 11 00 00       	call   802d15 <memmove>
	path[MAXPATHLEN-1] = 0;
  801b9a:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  801b9e:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801ba4:	89 04 24             	mov    %eax,(%esp)
  801ba7:	e8 0a ff ff ff       	call   801ab6 <openfile_alloc>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	0f 88 ec 00 00 00    	js     801ca0 <serve_open+0x12d>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801bb4:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801bbb:	74 32                	je     801bef <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  801bbd:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc7:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801bcd:	89 04 24             	mov    %eax,(%esp)
  801bd0:	e8 80 fa ff ff       	call   801655 <file_create>
  801bd5:	85 c0                	test   %eax,%eax
  801bd7:	79 36                	jns    801c0f <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801bd9:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801be0:	0f 85 ba 00 00 00    	jne    801ca0 <serve_open+0x12d>
  801be6:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801be9:	0f 85 b1 00 00 00    	jne    801ca0 <serve_open+0x12d>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801bef:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf9:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801bff:	89 04 24             	mov    %eax,(%esp)
  801c02:	e8 b5 f8 ff ff       	call   8014bc <file_open>
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 91 00 00 00    	js     801ca0 <serve_open+0x12d>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  801c0f:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801c16:	74 1a                	je     801c32 <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  801c18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c1f:	00 
  801c20:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  801c26:	89 04 24             	mov    %eax,(%esp)
  801c29:	e8 88 f4 ff ff       	call   8010b6 <file_set_size>
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	78 6e                	js     801ca0 <serve_open+0x12d>
			return r;
		}
	}

	// Save the file pointer
	o->o_file = f;
  801c32:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  801c38:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801c3e:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801c41:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801c47:	8b 50 0c             	mov    0xc(%eax),%edx
  801c4a:	8b 00                	mov    (%eax),%eax
  801c4c:	89 42 0c             	mov    %eax,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801c4f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801c55:	8b 40 0c             	mov    0xc(%eax),%eax
  801c58:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801c5e:	83 e2 03             	and    $0x3,%edx
  801c61:	89 50 08             	mov    %edx,0x8(%eax)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801c64:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801c6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c6d:	8b 15 68 a0 80 00    	mov    0x80a068,%edx
  801c73:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801c75:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801c7b:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801c81:	89 50 08             	mov    %edx,0x8(%eax)

	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller
	*pg_store = o->o_fd;
  801c84:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801c8a:	8b 50 0c             	mov    0xc(%eax),%edx
  801c8d:	8b 45 10             	mov    0x10(%ebp),%eax
  801c90:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W;
  801c92:	8b 45 14             	mov    0x14(%ebp),%eax
  801c95:	c7 00 07 00 00 00    	movl   $0x7,(%eax)
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801ca0:	81 c4 24 04 00 00    	add    $0x424,%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5d                   	pop    %ebp
  801ca8:	c3                   	ret    

00801ca9 <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	57                   	push   %edi
  801cad:	56                   	push   %esi
  801cae:	53                   	push   %ebx
  801caf:	83 ec 2c             	sub    $0x2c,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801cb2:	8d 5d e0             	lea    -0x20(%ebp),%ebx
  801cb5:	8d 75 e4             	lea    -0x1c(%ebp),%esi
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  801cb8:	bf 40 a0 80 00       	mov    $0x80a040,%edi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801cbd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801cc4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cc8:	a1 20 a0 80 00       	mov    0x80a020,%eax
  801ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd1:	89 34 24             	mov    %esi,(%esp)
  801cd4:	e8 9b 17 00 00       	call   803474 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, vpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801cd9:	f6 45 e0 01          	testb  $0x1,-0x20(%ebp)
  801cdd:	75 15                	jne    801cf4 <serve+0x4b>
			cprintf("Invalid request from %08x: no argument page\n",
  801cdf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce6:	c7 04 24 58 49 80 00 	movl   $0x804958,(%esp)
  801ced:	e8 f7 06 00 00       	call   8023e9 <cprintf>
				whom);
			continue; // just leave it hanging...
  801cf2:	eb c9                	jmp    801cbd <serve+0x14>
		}

		pg = NULL;
  801cf4:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
		if (req == FSREQ_OPEN) {
  801cfb:	83 f8 01             	cmp    $0x1,%eax
  801cfe:	75 21                	jne    801d21 <serve+0x78>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801d00:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d04:	8d 45 dc             	lea    -0x24(%ebp),%eax
  801d07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0b:	a1 20 a0 80 00       	mov    0x80a020,%eax
  801d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d17:	89 04 24             	mov    %eax,(%esp)
  801d1a:	e8 54 fe ff ff       	call   801b73 <serve_open>
  801d1f:	eb 40                	jmp    801d61 <serve+0xb8>
		} else if (req < NHANDLERS && handlers[req]) {
  801d21:	83 f8 08             	cmp    $0x8,%eax
  801d24:	77 1f                	ja     801d45 <serve+0x9c>
  801d26:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801d29:	85 d2                	test   %edx,%edx
  801d2b:	90                   	nop
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	74 13                	je     801d45 <serve+0x9c>
			r = handlers[req](whom, fsreq);
  801d32:	a1 20 a0 80 00       	mov    0x80a020,%eax
  801d37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d3e:	89 04 24             	mov    %eax,(%esp)
  801d41:	ff d2                	call   *%edx
		}

		pg = NULL;
		if (req == FSREQ_OPEN) {
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
		} else if (req < NHANDLERS && handlers[req]) {
  801d43:	eb 1c                	jmp    801d61 <serve+0xb8>
			r = handlers[req](whom, fsreq);
		} else {
			cprintf("Invalid request code %d from %08x\n", whom, req);
  801d45:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d49:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d50:	c7 04 24 88 49 80 00 	movl   $0x804988,(%esp)
  801d57:	e8 8d 06 00 00       	call   8023e9 <cprintf>
  801d5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			r = -E_INVAL;
		}
		ipc_send(whom, r, pg, perm);
  801d61:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801d64:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d68:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801d6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d76:	89 04 24             	mov    %eax,(%esp)
  801d79:	e8 8b 16 00 00       	call   803409 <ipc_send>
		sys_page_unmap(0, fsreq);
  801d7e:	a1 20 a0 80 00       	mov    0x80a020,%eax
  801d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d87:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8e:	e8 89 13 00 00       	call   80311c <sys_page_unmap>
  801d93:	e9 25 ff ff ff       	jmp    801cbd <serve+0x14>

00801d98 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801d9e:	c7 05 64 a0 80 00 ab 	movl   $0x8049ab,0x80a064
  801da5:	49 80 00 
	cprintf("FS is running\n");
  801da8:	c7 04 24 ae 49 80 00 	movl   $0x8049ae,(%esp)
  801daf:	e8 35 06 00 00       	call   8023e9 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801db4:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801db9:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801dbe:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801dc0:	c7 04 24 bd 49 80 00 	movl   $0x8049bd,(%esp)
  801dc7:	e8 1d 06 00 00       	call   8023e9 <cprintf>

	serve_init();
  801dcc:	e8 4f fa ff ff       	call   801820 <serve_init>
	fs_init();
  801dd1:	e8 e7 f9 ff ff       	call   8017bd <fs_init>
	serve();
  801dd6:	e8 ce fe ff ff       	call   801ca9 <serve>
}
  801ddb:	c9                   	leave  
  801ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de0:	c3                   	ret    
  801de1:	00 00                	add    %al,(%eax)
	...

00801de4 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801de4:	55                   	push   %ebp
  801de5:	89 e5                	mov    %esp,%ebp
  801de7:	53                   	push   %ebx
  801de8:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801deb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801df2:	00 
  801df3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801dfa:	00 
  801dfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e02:	e8 86 13 00 00       	call   80318d <sys_page_alloc>
  801e07:	85 c0                	test   %eax,%eax
  801e09:	79 20                	jns    801e2b <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  801e0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e0f:	c7 44 24 08 cc 49 80 	movl   $0x8049cc,0x8(%esp)
  801e16:	00 
  801e17:	c7 44 24 04 13 00 00 	movl   $0x13,0x4(%esp)
  801e1e:	00 
  801e1f:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801e26:	e8 05 05 00 00       	call   802330 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801e2b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801e32:	00 
  801e33:	a1 10 b0 80 00       	mov    0x80b010,%eax
  801e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e3c:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  801e43:	e8 cd 0e 00 00       	call   802d15 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  801e48:	e8 35 ef ff ff       	call   800d82 <alloc_block>
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	79 20                	jns    801e71 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  801e51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e55:	c7 44 24 08 e9 49 80 	movl   $0x8049e9,0x8(%esp)
  801e5c:	00 
  801e5d:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
  801e64:	00 
  801e65:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801e6c:	e8 bf 04 00 00       	call   802330 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  801e71:	8d 50 1f             	lea    0x1f(%eax),%edx
  801e74:	85 c0                	test   %eax,%eax
  801e76:	0f 49 d0             	cmovns %eax,%edx
  801e79:	c1 fa 05             	sar    $0x5,%edx
  801e7c:	c1 e2 02             	shl    $0x2,%edx
  801e7f:	89 c3                	mov    %eax,%ebx
  801e81:	c1 fb 1f             	sar    $0x1f,%ebx
  801e84:	c1 eb 1b             	shr    $0x1b,%ebx
  801e87:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  801e8a:	83 e1 1f             	and    $0x1f,%ecx
  801e8d:	29 d9                	sub    %ebx,%ecx
  801e8f:	b8 01 00 00 00       	mov    $0x1,%eax
  801e94:	d3 e0                	shl    %cl,%eax
  801e96:	85 82 00 10 00 00    	test   %eax,0x1000(%edx)
  801e9c:	75 24                	jne    801ec2 <fs_test+0xde>
  801e9e:	c7 44 24 0c f9 49 80 	movl   $0x8049f9,0xc(%esp)
  801ea5:	00 
  801ea6:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  801ead:	00 
  801eae:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801eb5:	00 
  801eb6:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801ebd:	e8 6e 04 00 00       	call   802330 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801ec2:	8b 0d 10 b0 80 00    	mov    0x80b010,%ecx
  801ec8:	85 04 11             	test   %eax,(%ecx,%edx,1)
  801ecb:	74 24                	je     801ef1 <fs_test+0x10d>
  801ecd:	c7 44 24 0c 70 4b 80 	movl   $0x804b70,0xc(%esp)
  801ed4:	00 
  801ed5:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  801edc:	00 
  801edd:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801ee4:	00 
  801ee5:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801eec:	e8 3f 04 00 00       	call   802330 <_panic>
	cprintf("alloc_block is good\n");
  801ef1:	c7 04 24 14 4a 80 00 	movl   $0x804a14,(%esp)
  801ef8:	e8 ec 04 00 00       	call   8023e9 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801efd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f04:	c7 04 24 29 4a 80 00 	movl   $0x804a29,(%esp)
  801f0b:	e8 ac f5 ff ff       	call   8014bc <file_open>
  801f10:	85 c0                	test   %eax,%eax
  801f12:	79 25                	jns    801f39 <fs_test+0x155>
  801f14:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801f17:	74 40                	je     801f59 <fs_test+0x175>
		panic("file_open /not-found: %e", r);
  801f19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f1d:	c7 44 24 08 34 4a 80 	movl   $0x804a34,0x8(%esp)
  801f24:	00 
  801f25:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801f2c:	00 
  801f2d:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801f34:	e8 f7 03 00 00       	call   802330 <_panic>
	else if (r == 0)
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	75 1c                	jne    801f59 <fs_test+0x175>
		panic("file_open /not-found succeeded!");
  801f3d:	c7 44 24 08 90 4b 80 	movl   $0x804b90,0x8(%esp)
  801f44:	00 
  801f45:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  801f4c:	00 
  801f4d:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801f54:	e8 d7 03 00 00       	call   802330 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801f59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f60:	c7 04 24 4d 4a 80 00 	movl   $0x804a4d,(%esp)
  801f67:	e8 50 f5 ff ff       	call   8014bc <file_open>
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	79 20                	jns    801f90 <fs_test+0x1ac>
		panic("file_open /newmotd: %e", r);
  801f70:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f74:	c7 44 24 08 56 4a 80 	movl   $0x804a56,0x8(%esp)
  801f7b:	00 
  801f7c:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  801f83:	00 
  801f84:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801f8b:	e8 a0 03 00 00       	call   802330 <_panic>
	cprintf("file_open is good\n");
  801f90:	c7 04 24 6d 4a 80 00 	movl   $0x804a6d,(%esp)
  801f97:	e8 4d 04 00 00       	call   8023e9 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801f9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801faa:	00 
  801fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fae:	89 04 24             	mov    %eax,(%esp)
  801fb1:	e8 e1 f1 ff ff       	call   801197 <file_get_block>
  801fb6:	85 c0                	test   %eax,%eax
  801fb8:	79 20                	jns    801fda <fs_test+0x1f6>
		panic("file_get_block: %e", r);
  801fba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbe:	c7 44 24 08 80 4a 80 	movl   $0x804a80,0x8(%esp)
  801fc5:	00 
  801fc6:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801fcd:	00 
  801fce:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  801fd5:	e8 56 03 00 00       	call   802330 <_panic>
	if (strcmp(blk, msg) != 0)
  801fda:	8b 1d fc 4b 80 00    	mov    0x804bfc,%ebx
  801fe0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fe4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fe7:	89 04 24             	mov    %eax,(%esp)
  801fea:	e8 f6 0b 00 00       	call   802be5 <strcmp>
  801fef:	85 c0                	test   %eax,%eax
  801ff1:	74 1c                	je     80200f <fs_test+0x22b>
		panic("file_get_block returned wrong data");
  801ff3:	c7 44 24 08 b0 4b 80 	movl   $0x804bb0,0x8(%esp)
  801ffa:	00 
  801ffb:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  802002:	00 
  802003:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  80200a:	e8 21 03 00 00       	call   802330 <_panic>
	cprintf("file_get_block is good\n");
  80200f:	c7 04 24 93 4a 80 00 	movl   $0x804a93,(%esp)
  802016:	e8 ce 03 00 00       	call   8023e9 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80201b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80201e:	0f b6 10             	movzbl (%eax),%edx
  802021:	88 10                	mov    %dl,(%eax)
	assert((vpt[PGNUM(blk)] & PTE_D));
  802023:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802026:	c1 e8 0c             	shr    $0xc,%eax
  802029:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802030:	a8 40                	test   $0x40,%al
  802032:	75 24                	jne    802058 <fs_test+0x274>
  802034:	c7 44 24 0c ac 4a 80 	movl   $0x804aac,0xc(%esp)
  80203b:	00 
  80203c:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  802043:	00 
  802044:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80204b:	00 
  80204c:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  802053:	e8 d8 02 00 00       	call   802330 <_panic>
	file_flush(f);
  802058:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205b:	89 04 24             	mov    %eax,(%esp)
  80205e:	e8 93 f0 ff ff       	call   8010f6 <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  802063:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802066:	c1 e8 0c             	shr    $0xc,%eax
  802069:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802070:	a8 40                	test   $0x40,%al
  802072:	74 24                	je     802098 <fs_test+0x2b4>
  802074:	c7 44 24 0c ab 4a 80 	movl   $0x804aab,0xc(%esp)
  80207b:	00 
  80207c:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  802083:	00 
  802084:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  80208b:	00 
  80208c:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  802093:	e8 98 02 00 00       	call   802330 <_panic>
	cprintf("file_flush is good\n");
  802098:	c7 04 24 c6 4a 80 00 	movl   $0x804ac6,(%esp)
  80209f:	e8 45 03 00 00       	call   8023e9 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8020a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020ab:	00 
  8020ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020af:	89 04 24             	mov    %eax,(%esp)
  8020b2:	e8 ff ef ff ff       	call   8010b6 <file_set_size>
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	79 20                	jns    8020db <fs_test+0x2f7>
		panic("file_set_size: %e", r);
  8020bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bf:	c7 44 24 08 da 4a 80 	movl   $0x804ada,0x8(%esp)
  8020c6:	00 
  8020c7:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  8020ce:	00 
  8020cf:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  8020d6:	e8 55 02 00 00       	call   802330 <_panic>
	assert(f->f_direct[0] == 0);
  8020db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020de:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8020e5:	74 24                	je     80210b <fs_test+0x327>
  8020e7:	c7 44 24 0c ec 4a 80 	movl   $0x804aec,0xc(%esp)
  8020ee:	00 
  8020ef:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  8020f6:	00 
  8020f7:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8020fe:	00 
  8020ff:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  802106:	e8 25 02 00 00       	call   802330 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  80210b:	c1 e8 0c             	shr    $0xc,%eax
  80210e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802115:	a8 40                	test   $0x40,%al
  802117:	74 24                	je     80213d <fs_test+0x359>
  802119:	c7 44 24 0c 00 4b 80 	movl   $0x804b00,0xc(%esp)
  802120:	00 
  802121:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  802128:	00 
  802129:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  802130:	00 
  802131:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  802138:	e8 f3 01 00 00       	call   802330 <_panic>
	cprintf("file_truncate is good\n");
  80213d:	c7 04 24 19 4b 80 00 	movl   $0x804b19,(%esp)
  802144:	e8 a0 02 00 00       	call   8023e9 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  802149:	89 1c 24             	mov    %ebx,(%esp)
  80214c:	e8 8f 09 00 00       	call   802ae0 <strlen>
  802151:	89 44 24 04          	mov    %eax,0x4(%esp)
  802155:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802158:	89 04 24             	mov    %eax,(%esp)
  80215b:	e8 56 ef ff ff       	call   8010b6 <file_set_size>
  802160:	85 c0                	test   %eax,%eax
  802162:	79 20                	jns    802184 <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  802164:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802168:	c7 44 24 08 30 4b 80 	movl   $0x804b30,0x8(%esp)
  80216f:	00 
  802170:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  802177:	00 
  802178:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  80217f:	e8 ac 01 00 00       	call   802330 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  802184:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802187:	89 c2                	mov    %eax,%edx
  802189:	c1 ea 0c             	shr    $0xc,%edx
  80218c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802193:	f6 c2 40             	test   $0x40,%dl
  802196:	74 24                	je     8021bc <fs_test+0x3d8>
  802198:	c7 44 24 0c 00 4b 80 	movl   $0x804b00,0xc(%esp)
  80219f:	00 
  8021a0:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  8021a7:	00 
  8021a8:	c7 44 24 04 3b 00 00 	movl   $0x3b,0x4(%esp)
  8021af:	00 
  8021b0:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  8021b7:	e8 74 01 00 00       	call   802330 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  8021bc:	8d 55 f0             	lea    -0x10(%ebp),%edx
  8021bf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021ca:	00 
  8021cb:	89 04 24             	mov    %eax,(%esp)
  8021ce:	e8 c4 ef ff ff       	call   801197 <file_get_block>
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	79 20                	jns    8021f7 <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  8021d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021db:	c7 44 24 08 44 4b 80 	movl   $0x804b44,0x8(%esp)
  8021e2:	00 
  8021e3:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  8021ea:	00 
  8021eb:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  8021f2:	e8 39 01 00 00       	call   802330 <_panic>
	strcpy(blk, msg);
  8021f7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021fe:	89 04 24             	mov    %eax,(%esp)
  802201:	e8 24 09 00 00       	call   802b2a <strcpy>
	assert((vpt[PGNUM(blk)] & PTE_D));
  802206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802209:	c1 e8 0c             	shr    $0xc,%eax
  80220c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802213:	a8 40                	test   $0x40,%al
  802215:	75 24                	jne    80223b <fs_test+0x457>
  802217:	c7 44 24 0c ac 4a 80 	movl   $0x804aac,0xc(%esp)
  80221e:	00 
  80221f:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  802226:	00 
  802227:	c7 44 24 04 3f 00 00 	movl   $0x3f,0x4(%esp)
  80222e:	00 
  80222f:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  802236:	e8 f5 00 00 00       	call   802330 <_panic>
	file_flush(f);
  80223b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223e:	89 04 24             	mov    %eax,(%esp)
  802241:	e8 b0 ee ff ff       	call   8010f6 <file_flush>
	assert(!(vpt[PGNUM(blk)] & PTE_D));
  802246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802249:	c1 e8 0c             	shr    $0xc,%eax
  80224c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802253:	a8 40                	test   $0x40,%al
  802255:	74 24                	je     80227b <fs_test+0x497>
  802257:	c7 44 24 0c ab 4a 80 	movl   $0x804aab,0xc(%esp)
  80225e:	00 
  80225f:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  802266:	00 
  802267:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80226e:	00 
  80226f:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  802276:	e8 b5 00 00 00       	call   802330 <_panic>
	assert(!(vpt[PGNUM(f)] & PTE_D));
  80227b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227e:	c1 e8 0c             	shr    $0xc,%eax
  802281:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802288:	a8 40                	test   $0x40,%al
  80228a:	74 24                	je     8022b0 <fs_test+0x4cc>
  80228c:	c7 44 24 0c 00 4b 80 	movl   $0x804b00,0xc(%esp)
  802293:	00 
  802294:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  80229b:	00 
  80229c:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
  8022a3:	00 
  8022a4:	c7 04 24 df 49 80 00 	movl   $0x8049df,(%esp)
  8022ab:	e8 80 00 00 00       	call   802330 <_panic>
	cprintf("file rewrite is good\n");
  8022b0:	c7 04 24 59 4b 80 00 	movl   $0x804b59,(%esp)
  8022b7:	e8 2d 01 00 00       	call   8023e9 <cprintf>
}
  8022bc:	83 c4 24             	add    $0x24,%esp
  8022bf:	5b                   	pop    %ebx
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    
	...

008022c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	83 ec 18             	sub    $0x18,%esp
  8022ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8022cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8022d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8022d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8022d6:	e8 5c 0f 00 00       	call   803237 <sys_getenvid>
  8022db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8022e0:	c1 e0 07             	shl    $0x7,%eax
  8022e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022e8:	a3 d0 c7 80 00       	mov    %eax,0x80c7d0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8022ed:	85 f6                	test   %esi,%esi
  8022ef:	7e 07                	jle    8022f8 <libmain+0x34>
		binaryname = argv[0];
  8022f1:	8b 03                	mov    (%ebx),%eax
  8022f3:	a3 64 a0 80 00       	mov    %eax,0x80a064

	// call user main routine
	umain(argc, argv);
  8022f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8022fc:	89 34 24             	mov    %esi,(%esp)
  8022ff:	e8 94 fa ff ff       	call   801d98 <umain>

	// exit gracefully
	exit();
  802304:	e8 0b 00 00 00       	call   802314 <exit>
}
  802309:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80230c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80230f:	89 ec                	mov    %ebp,%esp
  802311:	5d                   	pop    %ebp
  802312:	c3                   	ret    
	...

00802314 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80231a:	e8 da 16 00 00       	call   8039f9 <close_all>
	sys_env_destroy(0);
  80231f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802326:	e8 47 0f 00 00       	call   803272 <sys_env_destroy>
}
  80232b:	c9                   	leave  
  80232c:	c3                   	ret    
  80232d:	00 00                	add    %al,(%eax)
	...

00802330 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	56                   	push   %esi
  802334:	53                   	push   %ebx
  802335:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  802338:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80233b:	8b 1d 64 a0 80 00    	mov    0x80a064,%ebx
  802341:	e8 f1 0e 00 00       	call   803237 <sys_getenvid>
  802346:	8b 55 0c             	mov    0xc(%ebp),%edx
  802349:	89 54 24 10          	mov    %edx,0x10(%esp)
  80234d:	8b 55 08             	mov    0x8(%ebp),%edx
  802350:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802354:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802358:	89 44 24 04          	mov    %eax,0x4(%esp)
  80235c:	c7 04 24 0c 4c 80 00 	movl   $0x804c0c,(%esp)
  802363:	e8 81 00 00 00       	call   8023e9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802368:	89 74 24 04          	mov    %esi,0x4(%esp)
  80236c:	8b 45 10             	mov    0x10(%ebp),%eax
  80236f:	89 04 24             	mov    %eax,(%esp)
  802372:	e8 11 00 00 00       	call   802388 <vcprintf>
	cprintf("\n");
  802377:	c7 04 24 f0 47 80 00 	movl   $0x8047f0,(%esp)
  80237e:	e8 66 00 00 00       	call   8023e9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802383:	cc                   	int3   
  802384:	eb fd                	jmp    802383 <_panic+0x53>
	...

00802388 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  802391:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802398:	00 00 00 
	b.cnt = 0;
  80239b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8023a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8023a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8023af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023b3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8023b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023bd:	c7 04 24 03 24 80 00 	movl   $0x802403,(%esp)
  8023c4:	e8 d4 01 00 00       	call   80259d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8023c9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8023cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023d3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8023d9:	89 04 24             	mov    %eax,(%esp)
  8023dc:	e8 05 0f 00 00       	call   8032e6 <sys_cputs>

	return b.cnt;
}
  8023e1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8023e7:	c9                   	leave  
  8023e8:	c3                   	ret    

008023e9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8023e9:	55                   	push   %ebp
  8023ea:	89 e5                	mov    %esp,%ebp
  8023ec:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8023ef:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8023f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f9:	89 04 24             	mov    %eax,(%esp)
  8023fc:	e8 87 ff ff ff       	call   802388 <vcprintf>
	va_end(ap);

	return cnt;
}
  802401:	c9                   	leave  
  802402:	c3                   	ret    

00802403 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  802403:	55                   	push   %ebp
  802404:	89 e5                	mov    %esp,%ebp
  802406:	53                   	push   %ebx
  802407:	83 ec 14             	sub    $0x14,%esp
  80240a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80240d:	8b 03                	mov    (%ebx),%eax
  80240f:	8b 55 08             	mov    0x8(%ebp),%edx
  802412:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  802416:	83 c0 01             	add    $0x1,%eax
  802419:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80241b:	3d ff 00 00 00       	cmp    $0xff,%eax
  802420:	75 19                	jne    80243b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  802422:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  802429:	00 
  80242a:	8d 43 08             	lea    0x8(%ebx),%eax
  80242d:	89 04 24             	mov    %eax,(%esp)
  802430:	e8 b1 0e 00 00       	call   8032e6 <sys_cputs>
		b->idx = 0;
  802435:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80243b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80243f:	83 c4 14             	add    $0x14,%esp
  802442:	5b                   	pop    %ebx
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    
	...

00802450 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	57                   	push   %edi
  802454:	56                   	push   %esi
  802455:	53                   	push   %ebx
  802456:	83 ec 4c             	sub    $0x4c,%esp
  802459:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80245c:	89 d6                	mov    %edx,%esi
  80245e:	8b 45 08             	mov    0x8(%ebp),%eax
  802461:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802464:	8b 55 0c             	mov    0xc(%ebp),%edx
  802467:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80246a:	8b 45 10             	mov    0x10(%ebp),%eax
  80246d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  802470:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  802473:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802476:	b9 00 00 00 00       	mov    $0x0,%ecx
  80247b:	39 d1                	cmp    %edx,%ecx
  80247d:	72 15                	jb     802494 <printnum+0x44>
  80247f:	77 07                	ja     802488 <printnum+0x38>
  802481:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802484:	39 d0                	cmp    %edx,%eax
  802486:	76 0c                	jbe    802494 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  802488:	83 eb 01             	sub    $0x1,%ebx
  80248b:	85 db                	test   %ebx,%ebx
  80248d:	8d 76 00             	lea    0x0(%esi),%esi
  802490:	7f 61                	jg     8024f3 <printnum+0xa3>
  802492:	eb 70                	jmp    802504 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  802494:	89 7c 24 10          	mov    %edi,0x10(%esp)
  802498:	83 eb 01             	sub    $0x1,%ebx
  80249b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80249f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024a3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024a7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8024ab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8024ae:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8024b1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8024b4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8024bf:	00 
  8024c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8024c3:	89 04 24             	mov    %eax,(%esp)
  8024c6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8024c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024cd:	e8 7e 1e 00 00       	call   804350 <__udivdi3>
  8024d2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8024d5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8024d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024dc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8024e0:	89 04 24             	mov    %eax,(%esp)
  8024e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024e7:	89 f2                	mov    %esi,%edx
  8024e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8024ec:	e8 5f ff ff ff       	call   802450 <printnum>
  8024f1:	eb 11                	jmp    802504 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8024f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8024f7:	89 3c 24             	mov    %edi,(%esp)
  8024fa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8024fd:	83 eb 01             	sub    $0x1,%ebx
  802500:	85 db                	test   %ebx,%ebx
  802502:	7f ef                	jg     8024f3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  802504:	89 74 24 04          	mov    %esi,0x4(%esp)
  802508:	8b 74 24 04          	mov    0x4(%esp),%esi
  80250c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80250f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802513:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80251a:	00 
  80251b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80251e:	89 14 24             	mov    %edx,(%esp)
  802521:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  802524:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802528:	e8 53 1f 00 00       	call   804480 <__umoddi3>
  80252d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802531:	0f be 80 2f 4c 80 00 	movsbl 0x804c2f(%eax),%eax
  802538:	89 04 24             	mov    %eax,(%esp)
  80253b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80253e:	83 c4 4c             	add    $0x4c,%esp
  802541:	5b                   	pop    %ebx
  802542:	5e                   	pop    %esi
  802543:	5f                   	pop    %edi
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    

00802546 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  802549:	83 fa 01             	cmp    $0x1,%edx
  80254c:	7e 0e                	jle    80255c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80254e:	8b 10                	mov    (%eax),%edx
  802550:	8d 4a 08             	lea    0x8(%edx),%ecx
  802553:	89 08                	mov    %ecx,(%eax)
  802555:	8b 02                	mov    (%edx),%eax
  802557:	8b 52 04             	mov    0x4(%edx),%edx
  80255a:	eb 22                	jmp    80257e <getuint+0x38>
	else if (lflag)
  80255c:	85 d2                	test   %edx,%edx
  80255e:	74 10                	je     802570 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  802560:	8b 10                	mov    (%eax),%edx
  802562:	8d 4a 04             	lea    0x4(%edx),%ecx
  802565:	89 08                	mov    %ecx,(%eax)
  802567:	8b 02                	mov    (%edx),%eax
  802569:	ba 00 00 00 00       	mov    $0x0,%edx
  80256e:	eb 0e                	jmp    80257e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  802570:	8b 10                	mov    (%eax),%edx
  802572:	8d 4a 04             	lea    0x4(%edx),%ecx
  802575:	89 08                	mov    %ecx,(%eax)
  802577:	8b 02                	mov    (%edx),%eax
  802579:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80257e:	5d                   	pop    %ebp
  80257f:	c3                   	ret    

00802580 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  802580:	55                   	push   %ebp
  802581:	89 e5                	mov    %esp,%ebp
  802583:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  802586:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80258a:	8b 10                	mov    (%eax),%edx
  80258c:	3b 50 04             	cmp    0x4(%eax),%edx
  80258f:	73 0a                	jae    80259b <sprintputch+0x1b>
		*b->buf++ = ch;
  802591:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802594:	88 0a                	mov    %cl,(%edx)
  802596:	83 c2 01             	add    $0x1,%edx
  802599:	89 10                	mov    %edx,(%eax)
}
  80259b:	5d                   	pop    %ebp
  80259c:	c3                   	ret    

0080259d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80259d:	55                   	push   %ebp
  80259e:	89 e5                	mov    %esp,%ebp
  8025a0:	57                   	push   %edi
  8025a1:	56                   	push   %esi
  8025a2:	53                   	push   %ebx
  8025a3:	83 ec 5c             	sub    $0x5c,%esp
  8025a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025a9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8025af:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8025b6:	eb 11                	jmp    8025c9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8025b8:	85 c0                	test   %eax,%eax
  8025ba:	0f 84 68 04 00 00    	je     802a28 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8025c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025c4:	89 04 24             	mov    %eax,(%esp)
  8025c7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8025c9:	0f b6 03             	movzbl (%ebx),%eax
  8025cc:	83 c3 01             	add    $0x1,%ebx
  8025cf:	83 f8 25             	cmp    $0x25,%eax
  8025d2:	75 e4                	jne    8025b8 <vprintfmt+0x1b>
  8025d4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8025db:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8025e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025e7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8025eb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8025f2:	eb 06                	jmp    8025fa <vprintfmt+0x5d>
  8025f4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8025f8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8025fa:	0f b6 13             	movzbl (%ebx),%edx
  8025fd:	0f b6 c2             	movzbl %dl,%eax
  802600:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802603:	8d 43 01             	lea    0x1(%ebx),%eax
  802606:	83 ea 23             	sub    $0x23,%edx
  802609:	80 fa 55             	cmp    $0x55,%dl
  80260c:	0f 87 f9 03 00 00    	ja     802a0b <vprintfmt+0x46e>
  802612:	0f b6 d2             	movzbl %dl,%edx
  802615:	ff 24 95 00 4e 80 00 	jmp    *0x804e00(,%edx,4)
  80261c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  802620:	eb d6                	jmp    8025f8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  802622:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802625:	83 ea 30             	sub    $0x30,%edx
  802628:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80262b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80262e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  802631:	83 fb 09             	cmp    $0x9,%ebx
  802634:	77 54                	ja     80268a <vprintfmt+0xed>
  802636:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  802639:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80263c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80263f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  802642:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  802646:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  802649:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80264c:	83 fb 09             	cmp    $0x9,%ebx
  80264f:	76 eb                	jbe    80263c <vprintfmt+0x9f>
  802651:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  802654:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  802657:	eb 31                	jmp    80268a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  802659:	8b 55 14             	mov    0x14(%ebp),%edx
  80265c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80265f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  802662:	8b 12                	mov    (%edx),%edx
  802664:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  802667:	eb 21                	jmp    80268a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  802669:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80266d:	ba 00 00 00 00       	mov    $0x0,%edx
  802672:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  802676:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  802679:	e9 7a ff ff ff       	jmp    8025f8 <vprintfmt+0x5b>
  80267e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  802685:	e9 6e ff ff ff       	jmp    8025f8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80268a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80268e:	0f 89 64 ff ff ff    	jns    8025f8 <vprintfmt+0x5b>
  802694:	8b 55 cc             	mov    -0x34(%ebp),%edx
  802697:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80269a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80269d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8026a0:	e9 53 ff ff ff       	jmp    8025f8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8026a5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8026a8:	e9 4b ff ff ff       	jmp    8025f8 <vprintfmt+0x5b>
  8026ad:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8026b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8026b3:	8d 50 04             	lea    0x4(%eax),%edx
  8026b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8026b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026bd:	8b 00                	mov    (%eax),%eax
  8026bf:	89 04 24             	mov    %eax,(%esp)
  8026c2:	ff d7                	call   *%edi
  8026c4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8026c7:	e9 fd fe ff ff       	jmp    8025c9 <vprintfmt+0x2c>
  8026cc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8026cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8026d2:	8d 50 04             	lea    0x4(%eax),%edx
  8026d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8026d8:	8b 00                	mov    (%eax),%eax
  8026da:	89 c2                	mov    %eax,%edx
  8026dc:	c1 fa 1f             	sar    $0x1f,%edx
  8026df:	31 d0                	xor    %edx,%eax
  8026e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8026e3:	83 f8 0f             	cmp    $0xf,%eax
  8026e6:	7f 0b                	jg     8026f3 <vprintfmt+0x156>
  8026e8:	8b 14 85 60 4f 80 00 	mov    0x804f60(,%eax,4),%edx
  8026ef:	85 d2                	test   %edx,%edx
  8026f1:	75 20                	jne    802713 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8026f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026f7:	c7 44 24 08 40 4c 80 	movl   $0x804c40,0x8(%esp)
  8026fe:	00 
  8026ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  802703:	89 3c 24             	mov    %edi,(%esp)
  802706:	e8 a5 03 00 00       	call   802ab0 <printfmt>
  80270b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80270e:	e9 b6 fe ff ff       	jmp    8025c9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  802713:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802717:	c7 44 24 08 df 45 80 	movl   $0x8045df,0x8(%esp)
  80271e:	00 
  80271f:	89 74 24 04          	mov    %esi,0x4(%esp)
  802723:	89 3c 24             	mov    %edi,(%esp)
  802726:	e8 85 03 00 00       	call   802ab0 <printfmt>
  80272b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80272e:	e9 96 fe ff ff       	jmp    8025c9 <vprintfmt+0x2c>
  802733:	89 45 d0             	mov    %eax,-0x30(%ebp)
  802736:	89 c3                	mov    %eax,%ebx
  802738:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80273b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80273e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  802741:	8b 45 14             	mov    0x14(%ebp),%eax
  802744:	8d 50 04             	lea    0x4(%eax),%edx
  802747:	89 55 14             	mov    %edx,0x14(%ebp)
  80274a:	8b 00                	mov    (%eax),%eax
  80274c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80274f:	85 c0                	test   %eax,%eax
  802751:	b8 49 4c 80 00       	mov    $0x804c49,%eax
  802756:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80275a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80275d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  802761:	7e 06                	jle    802769 <vprintfmt+0x1cc>
  802763:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  802767:	75 13                	jne    80277c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802769:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80276c:	0f be 02             	movsbl (%edx),%eax
  80276f:	85 c0                	test   %eax,%eax
  802771:	0f 85 a2 00 00 00    	jne    802819 <vprintfmt+0x27c>
  802777:	e9 8f 00 00 00       	jmp    80280b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80277c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802780:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  802783:	89 0c 24             	mov    %ecx,(%esp)
  802786:	e8 70 03 00 00       	call   802afb <strnlen>
  80278b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80278e:	29 c2                	sub    %eax,%edx
  802790:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  802793:	85 d2                	test   %edx,%edx
  802795:	7e d2                	jle    802769 <vprintfmt+0x1cc>
					putch(padc, putdat);
  802797:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80279b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80279e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8027a1:	89 d3                	mov    %edx,%ebx
  8027a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8027aa:	89 04 24             	mov    %eax,(%esp)
  8027ad:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8027af:	83 eb 01             	sub    $0x1,%ebx
  8027b2:	85 db                	test   %ebx,%ebx
  8027b4:	7f ed                	jg     8027a3 <vprintfmt+0x206>
  8027b6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8027b9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8027c0:	eb a7                	jmp    802769 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8027c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8027c6:	74 1b                	je     8027e3 <vprintfmt+0x246>
  8027c8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8027cb:	83 fa 5e             	cmp    $0x5e,%edx
  8027ce:	76 13                	jbe    8027e3 <vprintfmt+0x246>
					putch('?', putdat);
  8027d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8027d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8027d7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8027de:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8027e1:	eb 0d                	jmp    8027f0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8027e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8027e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8027ea:	89 04 24             	mov    %eax,(%esp)
  8027ed:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8027f0:	83 ef 01             	sub    $0x1,%edi
  8027f3:	0f be 03             	movsbl (%ebx),%eax
  8027f6:	85 c0                	test   %eax,%eax
  8027f8:	74 05                	je     8027ff <vprintfmt+0x262>
  8027fa:	83 c3 01             	add    $0x1,%ebx
  8027fd:	eb 31                	jmp    802830 <vprintfmt+0x293>
  8027ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  802802:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  802805:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802808:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80280b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80280f:	7f 36                	jg     802847 <vprintfmt+0x2aa>
  802811:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  802814:	e9 b0 fd ff ff       	jmp    8025c9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  802819:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80281c:	83 c2 01             	add    $0x1,%edx
  80281f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  802822:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  802825:	89 75 e0             	mov    %esi,-0x20(%ebp)
  802828:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80282b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80282e:	89 d3                	mov    %edx,%ebx
  802830:	85 f6                	test   %esi,%esi
  802832:	78 8e                	js     8027c2 <vprintfmt+0x225>
  802834:	83 ee 01             	sub    $0x1,%esi
  802837:	79 89                	jns    8027c2 <vprintfmt+0x225>
  802839:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80283c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80283f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  802842:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  802845:	eb c4                	jmp    80280b <vprintfmt+0x26e>
  802847:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80284a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80284d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802851:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802858:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80285a:	83 eb 01             	sub    $0x1,%ebx
  80285d:	85 db                	test   %ebx,%ebx
  80285f:	7f ec                	jg     80284d <vprintfmt+0x2b0>
  802861:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  802864:	e9 60 fd ff ff       	jmp    8025c9 <vprintfmt+0x2c>
  802869:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80286c:	83 f9 01             	cmp    $0x1,%ecx
  80286f:	7e 16                	jle    802887 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  802871:	8b 45 14             	mov    0x14(%ebp),%eax
  802874:	8d 50 08             	lea    0x8(%eax),%edx
  802877:	89 55 14             	mov    %edx,0x14(%ebp)
  80287a:	8b 10                	mov    (%eax),%edx
  80287c:	8b 48 04             	mov    0x4(%eax),%ecx
  80287f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  802882:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  802885:	eb 32                	jmp    8028b9 <vprintfmt+0x31c>
	else if (lflag)
  802887:	85 c9                	test   %ecx,%ecx
  802889:	74 18                	je     8028a3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80288b:	8b 45 14             	mov    0x14(%ebp),%eax
  80288e:	8d 50 04             	lea    0x4(%eax),%edx
  802891:	89 55 14             	mov    %edx,0x14(%ebp)
  802894:	8b 00                	mov    (%eax),%eax
  802896:	89 45 d8             	mov    %eax,-0x28(%ebp)
  802899:	89 c1                	mov    %eax,%ecx
  80289b:	c1 f9 1f             	sar    $0x1f,%ecx
  80289e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8028a1:	eb 16                	jmp    8028b9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8028a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8028a6:	8d 50 04             	lea    0x4(%eax),%edx
  8028a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8028ac:	8b 00                	mov    (%eax),%eax
  8028ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8028b1:	89 c2                	mov    %eax,%edx
  8028b3:	c1 fa 1f             	sar    $0x1f,%edx
  8028b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8028b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8028bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8028bf:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8028c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8028c8:	0f 89 8a 00 00 00    	jns    802958 <vprintfmt+0x3bb>
				putch('-', putdat);
  8028ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028d2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8028d9:	ff d7                	call   *%edi
				num = -(long long) num;
  8028db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8028de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8028e1:	f7 d8                	neg    %eax
  8028e3:	83 d2 00             	adc    $0x0,%edx
  8028e6:	f7 da                	neg    %edx
  8028e8:	eb 6e                	jmp    802958 <vprintfmt+0x3bb>
  8028ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8028ed:	89 ca                	mov    %ecx,%edx
  8028ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8028f2:	e8 4f fc ff ff       	call   802546 <getuint>
  8028f7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8028fc:	eb 5a                	jmp    802958 <vprintfmt+0x3bb>
  8028fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  802901:	89 ca                	mov    %ecx,%edx
  802903:	8d 45 14             	lea    0x14(%ebp),%eax
  802906:	e8 3b fc ff ff       	call   802546 <getuint>
  80290b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  802910:	eb 46                	jmp    802958 <vprintfmt+0x3bb>
  802912:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  802915:	89 74 24 04          	mov    %esi,0x4(%esp)
  802919:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802920:	ff d7                	call   *%edi
			putch('x', putdat);
  802922:	89 74 24 04          	mov    %esi,0x4(%esp)
  802926:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80292d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80292f:	8b 45 14             	mov    0x14(%ebp),%eax
  802932:	8d 50 04             	lea    0x4(%eax),%edx
  802935:	89 55 14             	mov    %edx,0x14(%ebp)
  802938:	8b 00                	mov    (%eax),%eax
  80293a:	ba 00 00 00 00       	mov    $0x0,%edx
  80293f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  802944:	eb 12                	jmp    802958 <vprintfmt+0x3bb>
  802946:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802949:	89 ca                	mov    %ecx,%edx
  80294b:	8d 45 14             	lea    0x14(%ebp),%eax
  80294e:	e8 f3 fb ff ff       	call   802546 <getuint>
  802953:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  802958:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80295c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802960:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  802963:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  802967:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80296b:	89 04 24             	mov    %eax,(%esp)
  80296e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802972:	89 f2                	mov    %esi,%edx
  802974:	89 f8                	mov    %edi,%eax
  802976:	e8 d5 fa ff ff       	call   802450 <printnum>
  80297b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80297e:	e9 46 fc ff ff       	jmp    8025c9 <vprintfmt+0x2c>
  802983:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  802986:	8b 45 14             	mov    0x14(%ebp),%eax
  802989:	8d 50 04             	lea    0x4(%eax),%edx
  80298c:	89 55 14             	mov    %edx,0x14(%ebp)
  80298f:	8b 00                	mov    (%eax),%eax
  802991:	85 c0                	test   %eax,%eax
  802993:	75 24                	jne    8029b9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  802995:	c7 44 24 0c 64 4d 80 	movl   $0x804d64,0xc(%esp)
  80299c:	00 
  80299d:	c7 44 24 08 df 45 80 	movl   $0x8045df,0x8(%esp)
  8029a4:	00 
  8029a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029a9:	89 3c 24             	mov    %edi,(%esp)
  8029ac:	e8 ff 00 00 00       	call   802ab0 <printfmt>
  8029b1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8029b4:	e9 10 fc ff ff       	jmp    8025c9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8029b9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8029bc:	7e 29                	jle    8029e7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8029be:	0f b6 16             	movzbl (%esi),%edx
  8029c1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8029c3:	c7 44 24 0c 9c 4d 80 	movl   $0x804d9c,0xc(%esp)
  8029ca:	00 
  8029cb:	c7 44 24 08 df 45 80 	movl   $0x8045df,0x8(%esp)
  8029d2:	00 
  8029d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029d7:	89 3c 24             	mov    %edi,(%esp)
  8029da:	e8 d1 00 00 00       	call   802ab0 <printfmt>
  8029df:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8029e2:	e9 e2 fb ff ff       	jmp    8025c9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8029e7:	0f b6 16             	movzbl (%esi),%edx
  8029ea:	88 10                	mov    %dl,(%eax)
  8029ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8029ef:	e9 d5 fb ff ff       	jmp    8025c9 <vprintfmt+0x2c>
  8029f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8029f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8029fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8029fe:	89 14 24             	mov    %edx,(%esp)
  802a01:	ff d7                	call   *%edi
  802a03:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  802a06:	e9 be fb ff ff       	jmp    8025c9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802a0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  802a0f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  802a16:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  802a18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802a1b:	80 38 25             	cmpb   $0x25,(%eax)
  802a1e:	0f 84 a5 fb ff ff    	je     8025c9 <vprintfmt+0x2c>
  802a24:	89 c3                	mov    %eax,%ebx
  802a26:	eb f0                	jmp    802a18 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  802a28:	83 c4 5c             	add    $0x5c,%esp
  802a2b:	5b                   	pop    %ebx
  802a2c:	5e                   	pop    %esi
  802a2d:	5f                   	pop    %edi
  802a2e:	5d                   	pop    %ebp
  802a2f:	c3                   	ret    

00802a30 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  802a30:	55                   	push   %ebp
  802a31:	89 e5                	mov    %esp,%ebp
  802a33:	83 ec 28             	sub    $0x28,%esp
  802a36:	8b 45 08             	mov    0x8(%ebp),%eax
  802a39:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  802a3c:	85 c0                	test   %eax,%eax
  802a3e:	74 04                	je     802a44 <vsnprintf+0x14>
  802a40:	85 d2                	test   %edx,%edx
  802a42:	7f 07                	jg     802a4b <vsnprintf+0x1b>
  802a44:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802a49:	eb 3b                	jmp    802a86 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  802a4b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802a4e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  802a52:	89 45 f0             	mov    %eax,-0x10(%ebp)
  802a55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  802a5c:	8b 45 14             	mov    0x14(%ebp),%eax
  802a5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a63:	8b 45 10             	mov    0x10(%ebp),%eax
  802a66:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a6a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  802a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a71:	c7 04 24 80 25 80 00 	movl   $0x802580,(%esp)
  802a78:	e8 20 fb ff ff       	call   80259d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  802a7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  802a80:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  802a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  802a86:	c9                   	leave  
  802a87:	c3                   	ret    

00802a88 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802a88:	55                   	push   %ebp
  802a89:	89 e5                	mov    %esp,%ebp
  802a8b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  802a8e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  802a91:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a95:	8b 45 10             	mov    0x10(%ebp),%eax
  802a98:	89 44 24 08          	mov    %eax,0x8(%esp)
  802a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  802aa6:	89 04 24             	mov    %eax,(%esp)
  802aa9:	e8 82 ff ff ff       	call   802a30 <vsnprintf>
	va_end(ap);

	return rc;
}
  802aae:	c9                   	leave  
  802aaf:	c3                   	ret    

00802ab0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  802ab0:	55                   	push   %ebp
  802ab1:	89 e5                	mov    %esp,%ebp
  802ab3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  802ab6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  802ab9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802abd:	8b 45 10             	mov    0x10(%ebp),%eax
  802ac0:	89 44 24 08          	mov    %eax,0x8(%esp)
  802ac4:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  802acb:	8b 45 08             	mov    0x8(%ebp),%eax
  802ace:	89 04 24             	mov    %eax,(%esp)
  802ad1:	e8 c7 fa ff ff       	call   80259d <vprintfmt>
	va_end(ap);
}
  802ad6:	c9                   	leave  
  802ad7:	c3                   	ret    
	...

00802ae0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802ae0:	55                   	push   %ebp
  802ae1:	89 e5                	mov    %esp,%ebp
  802ae3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802ae6:	b8 00 00 00 00       	mov    $0x0,%eax
  802aeb:	80 3a 00             	cmpb   $0x0,(%edx)
  802aee:	74 09                	je     802af9 <strlen+0x19>
		n++;
  802af0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802af3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802af7:	75 f7                	jne    802af0 <strlen+0x10>
		n++;
	return n;
}
  802af9:	5d                   	pop    %ebp
  802afa:	c3                   	ret    

00802afb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802afb:	55                   	push   %ebp
  802afc:	89 e5                	mov    %esp,%ebp
  802afe:	53                   	push   %ebx
  802aff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802b02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802b05:	85 c9                	test   %ecx,%ecx
  802b07:	74 19                	je     802b22 <strnlen+0x27>
  802b09:	80 3b 00             	cmpb   $0x0,(%ebx)
  802b0c:	74 14                	je     802b22 <strnlen+0x27>
  802b0e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  802b13:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802b16:	39 c8                	cmp    %ecx,%eax
  802b18:	74 0d                	je     802b27 <strnlen+0x2c>
  802b1a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  802b1e:	75 f3                	jne    802b13 <strnlen+0x18>
  802b20:	eb 05                	jmp    802b27 <strnlen+0x2c>
  802b22:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  802b27:	5b                   	pop    %ebx
  802b28:	5d                   	pop    %ebp
  802b29:	c3                   	ret    

00802b2a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802b2a:	55                   	push   %ebp
  802b2b:	89 e5                	mov    %esp,%ebp
  802b2d:	53                   	push   %ebx
  802b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  802b31:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802b34:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802b39:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  802b3d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  802b40:	83 c2 01             	add    $0x1,%edx
  802b43:	84 c9                	test   %cl,%cl
  802b45:	75 f2                	jne    802b39 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  802b47:	5b                   	pop    %ebx
  802b48:	5d                   	pop    %ebp
  802b49:	c3                   	ret    

00802b4a <strcat>:

char *
strcat(char *dst, const char *src)
{
  802b4a:	55                   	push   %ebp
  802b4b:	89 e5                	mov    %esp,%ebp
  802b4d:	53                   	push   %ebx
  802b4e:	83 ec 08             	sub    $0x8,%esp
  802b51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802b54:	89 1c 24             	mov    %ebx,(%esp)
  802b57:	e8 84 ff ff ff       	call   802ae0 <strlen>
	strcpy(dst + len, src);
  802b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b5f:	89 54 24 04          	mov    %edx,0x4(%esp)
  802b63:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  802b66:	89 04 24             	mov    %eax,(%esp)
  802b69:	e8 bc ff ff ff       	call   802b2a <strcpy>
	return dst;
}
  802b6e:	89 d8                	mov    %ebx,%eax
  802b70:	83 c4 08             	add    $0x8,%esp
  802b73:	5b                   	pop    %ebx
  802b74:	5d                   	pop    %ebp
  802b75:	c3                   	ret    

00802b76 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802b76:	55                   	push   %ebp
  802b77:	89 e5                	mov    %esp,%ebp
  802b79:	56                   	push   %esi
  802b7a:	53                   	push   %ebx
  802b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  802b7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b81:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802b84:	85 f6                	test   %esi,%esi
  802b86:	74 18                	je     802ba0 <strncpy+0x2a>
  802b88:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  802b8d:	0f b6 1a             	movzbl (%edx),%ebx
  802b90:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802b93:	80 3a 01             	cmpb   $0x1,(%edx)
  802b96:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802b99:	83 c1 01             	add    $0x1,%ecx
  802b9c:	39 ce                	cmp    %ecx,%esi
  802b9e:	77 ed                	ja     802b8d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  802ba0:	5b                   	pop    %ebx
  802ba1:	5e                   	pop    %esi
  802ba2:	5d                   	pop    %ebp
  802ba3:	c3                   	ret    

00802ba4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802ba4:	55                   	push   %ebp
  802ba5:	89 e5                	mov    %esp,%ebp
  802ba7:	56                   	push   %esi
  802ba8:	53                   	push   %ebx
  802ba9:	8b 75 08             	mov    0x8(%ebp),%esi
  802bac:	8b 55 0c             	mov    0xc(%ebp),%edx
  802baf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802bb2:	89 f0                	mov    %esi,%eax
  802bb4:	85 c9                	test   %ecx,%ecx
  802bb6:	74 27                	je     802bdf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  802bb8:	83 e9 01             	sub    $0x1,%ecx
  802bbb:	74 1d                	je     802bda <strlcpy+0x36>
  802bbd:	0f b6 1a             	movzbl (%edx),%ebx
  802bc0:	84 db                	test   %bl,%bl
  802bc2:	74 16                	je     802bda <strlcpy+0x36>
			*dst++ = *src++;
  802bc4:	88 18                	mov    %bl,(%eax)
  802bc6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802bc9:	83 e9 01             	sub    $0x1,%ecx
  802bcc:	74 0e                	je     802bdc <strlcpy+0x38>
			*dst++ = *src++;
  802bce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802bd1:	0f b6 1a             	movzbl (%edx),%ebx
  802bd4:	84 db                	test   %bl,%bl
  802bd6:	75 ec                	jne    802bc4 <strlcpy+0x20>
  802bd8:	eb 02                	jmp    802bdc <strlcpy+0x38>
  802bda:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  802bdc:	c6 00 00             	movb   $0x0,(%eax)
  802bdf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  802be1:	5b                   	pop    %ebx
  802be2:	5e                   	pop    %esi
  802be3:	5d                   	pop    %ebp
  802be4:	c3                   	ret    

00802be5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802be5:	55                   	push   %ebp
  802be6:	89 e5                	mov    %esp,%ebp
  802be8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802beb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802bee:	0f b6 01             	movzbl (%ecx),%eax
  802bf1:	84 c0                	test   %al,%al
  802bf3:	74 15                	je     802c0a <strcmp+0x25>
  802bf5:	3a 02                	cmp    (%edx),%al
  802bf7:	75 11                	jne    802c0a <strcmp+0x25>
		p++, q++;
  802bf9:	83 c1 01             	add    $0x1,%ecx
  802bfc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802bff:	0f b6 01             	movzbl (%ecx),%eax
  802c02:	84 c0                	test   %al,%al
  802c04:	74 04                	je     802c0a <strcmp+0x25>
  802c06:	3a 02                	cmp    (%edx),%al
  802c08:	74 ef                	je     802bf9 <strcmp+0x14>
  802c0a:	0f b6 c0             	movzbl %al,%eax
  802c0d:	0f b6 12             	movzbl (%edx),%edx
  802c10:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802c12:	5d                   	pop    %ebp
  802c13:	c3                   	ret    

00802c14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802c14:	55                   	push   %ebp
  802c15:	89 e5                	mov    %esp,%ebp
  802c17:	53                   	push   %ebx
  802c18:	8b 55 08             	mov    0x8(%ebp),%edx
  802c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c1e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  802c21:	85 c0                	test   %eax,%eax
  802c23:	74 23                	je     802c48 <strncmp+0x34>
  802c25:	0f b6 1a             	movzbl (%edx),%ebx
  802c28:	84 db                	test   %bl,%bl
  802c2a:	74 25                	je     802c51 <strncmp+0x3d>
  802c2c:	3a 19                	cmp    (%ecx),%bl
  802c2e:	75 21                	jne    802c51 <strncmp+0x3d>
  802c30:	83 e8 01             	sub    $0x1,%eax
  802c33:	74 13                	je     802c48 <strncmp+0x34>
		n--, p++, q++;
  802c35:	83 c2 01             	add    $0x1,%edx
  802c38:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802c3b:	0f b6 1a             	movzbl (%edx),%ebx
  802c3e:	84 db                	test   %bl,%bl
  802c40:	74 0f                	je     802c51 <strncmp+0x3d>
  802c42:	3a 19                	cmp    (%ecx),%bl
  802c44:	74 ea                	je     802c30 <strncmp+0x1c>
  802c46:	eb 09                	jmp    802c51 <strncmp+0x3d>
  802c48:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802c4d:	5b                   	pop    %ebx
  802c4e:	5d                   	pop    %ebp
  802c4f:	90                   	nop
  802c50:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  802c51:	0f b6 02             	movzbl (%edx),%eax
  802c54:	0f b6 11             	movzbl (%ecx),%edx
  802c57:	29 d0                	sub    %edx,%eax
  802c59:	eb f2                	jmp    802c4d <strncmp+0x39>

00802c5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802c5b:	55                   	push   %ebp
  802c5c:	89 e5                	mov    %esp,%ebp
  802c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  802c61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802c65:	0f b6 10             	movzbl (%eax),%edx
  802c68:	84 d2                	test   %dl,%dl
  802c6a:	74 18                	je     802c84 <strchr+0x29>
		if (*s == c)
  802c6c:	38 ca                	cmp    %cl,%dl
  802c6e:	75 0a                	jne    802c7a <strchr+0x1f>
  802c70:	eb 17                	jmp    802c89 <strchr+0x2e>
  802c72:	38 ca                	cmp    %cl,%dl
  802c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802c78:	74 0f                	je     802c89 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802c7a:	83 c0 01             	add    $0x1,%eax
  802c7d:	0f b6 10             	movzbl (%eax),%edx
  802c80:	84 d2                	test   %dl,%dl
  802c82:	75 ee                	jne    802c72 <strchr+0x17>
  802c84:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  802c89:	5d                   	pop    %ebp
  802c8a:	c3                   	ret    

00802c8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802c8b:	55                   	push   %ebp
  802c8c:	89 e5                	mov    %esp,%ebp
  802c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  802c91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802c95:	0f b6 10             	movzbl (%eax),%edx
  802c98:	84 d2                	test   %dl,%dl
  802c9a:	74 18                	je     802cb4 <strfind+0x29>
		if (*s == c)
  802c9c:	38 ca                	cmp    %cl,%dl
  802c9e:	75 0a                	jne    802caa <strfind+0x1f>
  802ca0:	eb 12                	jmp    802cb4 <strfind+0x29>
  802ca2:	38 ca                	cmp    %cl,%dl
  802ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ca8:	74 0a                	je     802cb4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  802caa:	83 c0 01             	add    $0x1,%eax
  802cad:	0f b6 10             	movzbl (%eax),%edx
  802cb0:	84 d2                	test   %dl,%dl
  802cb2:	75 ee                	jne    802ca2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  802cb4:	5d                   	pop    %ebp
  802cb5:	c3                   	ret    

00802cb6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802cb6:	55                   	push   %ebp
  802cb7:	89 e5                	mov    %esp,%ebp
  802cb9:	83 ec 0c             	sub    $0xc,%esp
  802cbc:	89 1c 24             	mov    %ebx,(%esp)
  802cbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  802cc3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  802cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
  802cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ccd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  802cd0:	85 c9                	test   %ecx,%ecx
  802cd2:	74 30                	je     802d04 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802cd4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802cda:	75 25                	jne    802d01 <memset+0x4b>
  802cdc:	f6 c1 03             	test   $0x3,%cl
  802cdf:	75 20                	jne    802d01 <memset+0x4b>
		c &= 0xFF;
  802ce1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  802ce4:	89 d3                	mov    %edx,%ebx
  802ce6:	c1 e3 08             	shl    $0x8,%ebx
  802ce9:	89 d6                	mov    %edx,%esi
  802ceb:	c1 e6 18             	shl    $0x18,%esi
  802cee:	89 d0                	mov    %edx,%eax
  802cf0:	c1 e0 10             	shl    $0x10,%eax
  802cf3:	09 f0                	or     %esi,%eax
  802cf5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  802cf7:	09 d8                	or     %ebx,%eax
  802cf9:	c1 e9 02             	shr    $0x2,%ecx
  802cfc:	fc                   	cld    
  802cfd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802cff:	eb 03                	jmp    802d04 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802d01:	fc                   	cld    
  802d02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  802d04:	89 f8                	mov    %edi,%eax
  802d06:	8b 1c 24             	mov    (%esp),%ebx
  802d09:	8b 74 24 04          	mov    0x4(%esp),%esi
  802d0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  802d11:	89 ec                	mov    %ebp,%esp
  802d13:	5d                   	pop    %ebp
  802d14:	c3                   	ret    

00802d15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802d15:	55                   	push   %ebp
  802d16:	89 e5                	mov    %esp,%ebp
  802d18:	83 ec 08             	sub    $0x8,%esp
  802d1b:	89 34 24             	mov    %esi,(%esp)
  802d1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802d22:	8b 45 08             	mov    0x8(%ebp),%eax
  802d25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  802d28:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  802d2b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  802d2d:	39 c6                	cmp    %eax,%esi
  802d2f:	73 35                	jae    802d66 <memmove+0x51>
  802d31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802d34:	39 d0                	cmp    %edx,%eax
  802d36:	73 2e                	jae    802d66 <memmove+0x51>
		s += n;
		d += n;
  802d38:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802d3a:	f6 c2 03             	test   $0x3,%dl
  802d3d:	75 1b                	jne    802d5a <memmove+0x45>
  802d3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802d45:	75 13                	jne    802d5a <memmove+0x45>
  802d47:	f6 c1 03             	test   $0x3,%cl
  802d4a:	75 0e                	jne    802d5a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  802d4c:	83 ef 04             	sub    $0x4,%edi
  802d4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  802d52:	c1 e9 02             	shr    $0x2,%ecx
  802d55:	fd                   	std    
  802d56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802d58:	eb 09                	jmp    802d63 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802d5a:	83 ef 01             	sub    $0x1,%edi
  802d5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  802d60:	fd                   	std    
  802d61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  802d63:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  802d64:	eb 20                	jmp    802d86 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802d66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802d6c:	75 15                	jne    802d83 <memmove+0x6e>
  802d6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802d74:	75 0d                	jne    802d83 <memmove+0x6e>
  802d76:	f6 c1 03             	test   $0x3,%cl
  802d79:	75 08                	jne    802d83 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  802d7b:	c1 e9 02             	shr    $0x2,%ecx
  802d7e:	fc                   	cld    
  802d7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802d81:	eb 03                	jmp    802d86 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  802d83:	fc                   	cld    
  802d84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802d86:	8b 34 24             	mov    (%esp),%esi
  802d89:	8b 7c 24 04          	mov    0x4(%esp),%edi
  802d8d:	89 ec                	mov    %ebp,%esp
  802d8f:	5d                   	pop    %ebp
  802d90:	c3                   	ret    

00802d91 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  802d91:	55                   	push   %ebp
  802d92:	89 e5                	mov    %esp,%ebp
  802d94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  802d97:	8b 45 10             	mov    0x10(%ebp),%eax
  802d9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  802d9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802da5:	8b 45 08             	mov    0x8(%ebp),%eax
  802da8:	89 04 24             	mov    %eax,(%esp)
  802dab:	e8 65 ff ff ff       	call   802d15 <memmove>
}
  802db0:	c9                   	leave  
  802db1:	c3                   	ret    

00802db2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802db2:	55                   	push   %ebp
  802db3:	89 e5                	mov    %esp,%ebp
  802db5:	57                   	push   %edi
  802db6:	56                   	push   %esi
  802db7:	53                   	push   %ebx
  802db8:	8b 75 08             	mov    0x8(%ebp),%esi
  802dbb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802dbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802dc1:	85 c9                	test   %ecx,%ecx
  802dc3:	74 36                	je     802dfb <memcmp+0x49>
		if (*s1 != *s2)
  802dc5:	0f b6 06             	movzbl (%esi),%eax
  802dc8:	0f b6 1f             	movzbl (%edi),%ebx
  802dcb:	38 d8                	cmp    %bl,%al
  802dcd:	74 20                	je     802def <memcmp+0x3d>
  802dcf:	eb 14                	jmp    802de5 <memcmp+0x33>
  802dd1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  802dd6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  802ddb:	83 c2 01             	add    $0x1,%edx
  802dde:	83 e9 01             	sub    $0x1,%ecx
  802de1:	38 d8                	cmp    %bl,%al
  802de3:	74 12                	je     802df7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  802de5:	0f b6 c0             	movzbl %al,%eax
  802de8:	0f b6 db             	movzbl %bl,%ebx
  802deb:	29 d8                	sub    %ebx,%eax
  802ded:	eb 11                	jmp    802e00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802def:	83 e9 01             	sub    $0x1,%ecx
  802df2:	ba 00 00 00 00       	mov    $0x0,%edx
  802df7:	85 c9                	test   %ecx,%ecx
  802df9:	75 d6                	jne    802dd1 <memcmp+0x1f>
  802dfb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  802e00:	5b                   	pop    %ebx
  802e01:	5e                   	pop    %esi
  802e02:	5f                   	pop    %edi
  802e03:	5d                   	pop    %ebp
  802e04:	c3                   	ret    

00802e05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  802e05:	55                   	push   %ebp
  802e06:	89 e5                	mov    %esp,%ebp
  802e08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  802e0b:	89 c2                	mov    %eax,%edx
  802e0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802e10:	39 d0                	cmp    %edx,%eax
  802e12:	73 15                	jae    802e29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  802e14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  802e18:	38 08                	cmp    %cl,(%eax)
  802e1a:	75 06                	jne    802e22 <memfind+0x1d>
  802e1c:	eb 0b                	jmp    802e29 <memfind+0x24>
  802e1e:	38 08                	cmp    %cl,(%eax)
  802e20:	74 07                	je     802e29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  802e22:	83 c0 01             	add    $0x1,%eax
  802e25:	39 c2                	cmp    %eax,%edx
  802e27:	77 f5                	ja     802e1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802e29:	5d                   	pop    %ebp
  802e2a:	c3                   	ret    

00802e2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802e2b:	55                   	push   %ebp
  802e2c:	89 e5                	mov    %esp,%ebp
  802e2e:	57                   	push   %edi
  802e2f:	56                   	push   %esi
  802e30:	53                   	push   %ebx
  802e31:	83 ec 04             	sub    $0x4,%esp
  802e34:	8b 55 08             	mov    0x8(%ebp),%edx
  802e37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802e3a:	0f b6 02             	movzbl (%edx),%eax
  802e3d:	3c 20                	cmp    $0x20,%al
  802e3f:	74 04                	je     802e45 <strtol+0x1a>
  802e41:	3c 09                	cmp    $0x9,%al
  802e43:	75 0e                	jne    802e53 <strtol+0x28>
		s++;
  802e45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802e48:	0f b6 02             	movzbl (%edx),%eax
  802e4b:	3c 20                	cmp    $0x20,%al
  802e4d:	74 f6                	je     802e45 <strtol+0x1a>
  802e4f:	3c 09                	cmp    $0x9,%al
  802e51:	74 f2                	je     802e45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  802e53:	3c 2b                	cmp    $0x2b,%al
  802e55:	75 0c                	jne    802e63 <strtol+0x38>
		s++;
  802e57:	83 c2 01             	add    $0x1,%edx
  802e5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802e61:	eb 15                	jmp    802e78 <strtol+0x4d>
	else if (*s == '-')
  802e63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  802e6a:	3c 2d                	cmp    $0x2d,%al
  802e6c:	75 0a                	jne    802e78 <strtol+0x4d>
		s++, neg = 1;
  802e6e:	83 c2 01             	add    $0x1,%edx
  802e71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802e78:	85 db                	test   %ebx,%ebx
  802e7a:	0f 94 c0             	sete   %al
  802e7d:	74 05                	je     802e84 <strtol+0x59>
  802e7f:	83 fb 10             	cmp    $0x10,%ebx
  802e82:	75 18                	jne    802e9c <strtol+0x71>
  802e84:	80 3a 30             	cmpb   $0x30,(%edx)
  802e87:	75 13                	jne    802e9c <strtol+0x71>
  802e89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802e8d:	8d 76 00             	lea    0x0(%esi),%esi
  802e90:	75 0a                	jne    802e9c <strtol+0x71>
		s += 2, base = 16;
  802e92:	83 c2 02             	add    $0x2,%edx
  802e95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  802e9a:	eb 15                	jmp    802eb1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802e9c:	84 c0                	test   %al,%al
  802e9e:	66 90                	xchg   %ax,%ax
  802ea0:	74 0f                	je     802eb1 <strtol+0x86>
  802ea2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802ea7:	80 3a 30             	cmpb   $0x30,(%edx)
  802eaa:	75 05                	jne    802eb1 <strtol+0x86>
		s++, base = 8;
  802eac:	83 c2 01             	add    $0x1,%edx
  802eaf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  802eb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802eb8:	0f b6 0a             	movzbl (%edx),%ecx
  802ebb:	89 cf                	mov    %ecx,%edi
  802ebd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802ec0:	80 fb 09             	cmp    $0x9,%bl
  802ec3:	77 08                	ja     802ecd <strtol+0xa2>
			dig = *s - '0';
  802ec5:	0f be c9             	movsbl %cl,%ecx
  802ec8:	83 e9 30             	sub    $0x30,%ecx
  802ecb:	eb 1e                	jmp    802eeb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  802ecd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  802ed0:	80 fb 19             	cmp    $0x19,%bl
  802ed3:	77 08                	ja     802edd <strtol+0xb2>
			dig = *s - 'a' + 10;
  802ed5:	0f be c9             	movsbl %cl,%ecx
  802ed8:	83 e9 57             	sub    $0x57,%ecx
  802edb:	eb 0e                	jmp    802eeb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  802edd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  802ee0:	80 fb 19             	cmp    $0x19,%bl
  802ee3:	77 15                	ja     802efa <strtol+0xcf>
			dig = *s - 'A' + 10;
  802ee5:	0f be c9             	movsbl %cl,%ecx
  802ee8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  802eeb:	39 f1                	cmp    %esi,%ecx
  802eed:	7d 0b                	jge    802efa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  802eef:	83 c2 01             	add    $0x1,%edx
  802ef2:	0f af c6             	imul   %esi,%eax
  802ef5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  802ef8:	eb be                	jmp    802eb8 <strtol+0x8d>
  802efa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  802efc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802f00:	74 05                	je     802f07 <strtol+0xdc>
		*endptr = (char *) s;
  802f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802f05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802f07:	89 ca                	mov    %ecx,%edx
  802f09:	f7 da                	neg    %edx
  802f0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  802f0f:	0f 45 c2             	cmovne %edx,%eax
}
  802f12:	83 c4 04             	add    $0x4,%esp
  802f15:	5b                   	pop    %ebx
  802f16:	5e                   	pop    %esi
  802f17:	5f                   	pop    %edi
  802f18:	5d                   	pop    %ebp
  802f19:	c3                   	ret    
	...

00802f1c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  802f1c:	55                   	push   %ebp
  802f1d:	89 e5                	mov    %esp,%ebp
  802f1f:	83 ec 48             	sub    $0x48,%esp
  802f22:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802f25:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802f28:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802f2b:	89 c6                	mov    %eax,%esi
  802f2d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802f30:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  802f32:	8b 7d 10             	mov    0x10(%ebp),%edi
  802f35:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802f3b:	51                   	push   %ecx
  802f3c:	52                   	push   %edx
  802f3d:	53                   	push   %ebx
  802f3e:	54                   	push   %esp
  802f3f:	55                   	push   %ebp
  802f40:	56                   	push   %esi
  802f41:	57                   	push   %edi
  802f42:	89 e5                	mov    %esp,%ebp
  802f44:	8d 35 4c 2f 80 00    	lea    0x802f4c,%esi
  802f4a:	0f 34                	sysenter 

00802f4c <.after_sysenter_label>:
  802f4c:	5f                   	pop    %edi
  802f4d:	5e                   	pop    %esi
  802f4e:	5d                   	pop    %ebp
  802f4f:	5c                   	pop    %esp
  802f50:	5b                   	pop    %ebx
  802f51:	5a                   	pop    %edx
  802f52:	59                   	pop    %ecx
  802f53:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  802f55:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  802f59:	74 28                	je     802f83 <.after_sysenter_label+0x37>
  802f5b:	85 c0                	test   %eax,%eax
  802f5d:	7e 24                	jle    802f83 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  802f5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  802f63:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802f67:	c7 44 24 08 a0 4f 80 	movl   $0x804fa0,0x8(%esp)
  802f6e:	00 
  802f6f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  802f76:	00 
  802f77:	c7 04 24 bd 4f 80 00 	movl   $0x804fbd,(%esp)
  802f7e:	e8 ad f3 ff ff       	call   802330 <_panic>

	return ret;
}
  802f83:	89 d0                	mov    %edx,%eax
  802f85:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802f88:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802f8b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802f8e:	89 ec                	mov    %ebp,%esp
  802f90:	5d                   	pop    %ebp
  802f91:	c3                   	ret    

00802f92 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  802f92:	55                   	push   %ebp
  802f93:	89 e5                	mov    %esp,%ebp
  802f95:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  802f98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802f9f:	00 
  802fa0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802fa7:	00 
  802fa8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802faf:	00 
  802fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fb3:	89 04 24             	mov    %eax,(%esp)
  802fb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  802fbe:	b8 10 00 00 00       	mov    $0x10,%eax
  802fc3:	e8 54 ff ff ff       	call   802f1c <syscall>
}
  802fc8:	c9                   	leave  
  802fc9:	c3                   	ret    

00802fca <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  802fca:	55                   	push   %ebp
  802fcb:	89 e5                	mov    %esp,%ebp
  802fcd:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  802fd0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802fd7:	00 
  802fd8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802fdf:	00 
  802fe0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802fe7:	00 
  802fe8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fef:	b9 00 00 00 00       	mov    $0x0,%ecx
  802ff4:	ba 00 00 00 00       	mov    $0x0,%edx
  802ff9:	b8 0f 00 00 00       	mov    $0xf,%eax
  802ffe:	e8 19 ff ff ff       	call   802f1c <syscall>
}
  803003:	c9                   	leave  
  803004:	c3                   	ret    

00803005 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  803005:	55                   	push   %ebp
  803006:	89 e5                	mov    %esp,%ebp
  803008:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80300b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803012:	00 
  803013:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80301a:	00 
  80301b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803022:	00 
  803023:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80302a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80302d:	ba 01 00 00 00       	mov    $0x1,%edx
  803032:	b8 0e 00 00 00       	mov    $0xe,%eax
  803037:	e8 e0 fe ff ff       	call   802f1c <syscall>
}
  80303c:	c9                   	leave  
  80303d:	c3                   	ret    

0080303e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80303e:	55                   	push   %ebp
  80303f:	89 e5                	mov    %esp,%ebp
  803041:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  803044:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80304b:	00 
  80304c:	8b 45 14             	mov    0x14(%ebp),%eax
  80304f:	89 44 24 08          	mov    %eax,0x8(%esp)
  803053:	8b 45 10             	mov    0x10(%ebp),%eax
  803056:	89 44 24 04          	mov    %eax,0x4(%esp)
  80305a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80305d:	89 04 24             	mov    %eax,(%esp)
  803060:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803063:	ba 00 00 00 00       	mov    $0x0,%edx
  803068:	b8 0d 00 00 00       	mov    $0xd,%eax
  80306d:	e8 aa fe ff ff       	call   802f1c <syscall>
}
  803072:	c9                   	leave  
  803073:	c3                   	ret    

00803074 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  803074:	55                   	push   %ebp
  803075:	89 e5                	mov    %esp,%ebp
  803077:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80307a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803081:	00 
  803082:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803089:	00 
  80308a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803091:	00 
  803092:	8b 45 0c             	mov    0xc(%ebp),%eax
  803095:	89 04 24             	mov    %eax,(%esp)
  803098:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80309b:	ba 01 00 00 00       	mov    $0x1,%edx
  8030a0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8030a5:	e8 72 fe ff ff       	call   802f1c <syscall>
}
  8030aa:	c9                   	leave  
  8030ab:	c3                   	ret    

008030ac <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8030ac:	55                   	push   %ebp
  8030ad:	89 e5                	mov    %esp,%ebp
  8030af:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8030b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8030b9:	00 
  8030ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8030c1:	00 
  8030c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8030c9:	00 
  8030ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030cd:	89 04 24             	mov    %eax,(%esp)
  8030d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8030d3:	ba 01 00 00 00       	mov    $0x1,%edx
  8030d8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8030dd:	e8 3a fe ff ff       	call   802f1c <syscall>
}
  8030e2:	c9                   	leave  
  8030e3:	c3                   	ret    

008030e4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8030e4:	55                   	push   %ebp
  8030e5:	89 e5                	mov    %esp,%ebp
  8030e7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8030ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8030f1:	00 
  8030f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8030f9:	00 
  8030fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803101:	00 
  803102:	8b 45 0c             	mov    0xc(%ebp),%eax
  803105:	89 04 24             	mov    %eax,(%esp)
  803108:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80310b:	ba 01 00 00 00       	mov    $0x1,%edx
  803110:	b8 09 00 00 00       	mov    $0x9,%eax
  803115:	e8 02 fe ff ff       	call   802f1c <syscall>
}
  80311a:	c9                   	leave  
  80311b:	c3                   	ret    

0080311c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80311c:	55                   	push   %ebp
  80311d:	89 e5                	mov    %esp,%ebp
  80311f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  803122:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803129:	00 
  80312a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803131:	00 
  803132:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803139:	00 
  80313a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80313d:	89 04 24             	mov    %eax,(%esp)
  803140:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803143:	ba 01 00 00 00       	mov    $0x1,%edx
  803148:	b8 07 00 00 00       	mov    $0x7,%eax
  80314d:	e8 ca fd ff ff       	call   802f1c <syscall>
}
  803152:	c9                   	leave  
  803153:	c3                   	ret    

00803154 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  803154:	55                   	push   %ebp
  803155:	89 e5                	mov    %esp,%ebp
  803157:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  80315a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803161:	00 
  803162:	8b 45 18             	mov    0x18(%ebp),%eax
  803165:	0b 45 14             	or     0x14(%ebp),%eax
  803168:	89 44 24 08          	mov    %eax,0x8(%esp)
  80316c:	8b 45 10             	mov    0x10(%ebp),%eax
  80316f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803173:	8b 45 0c             	mov    0xc(%ebp),%eax
  803176:	89 04 24             	mov    %eax,(%esp)
  803179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80317c:	ba 01 00 00 00       	mov    $0x1,%edx
  803181:	b8 06 00 00 00       	mov    $0x6,%eax
  803186:	e8 91 fd ff ff       	call   802f1c <syscall>
}
  80318b:	c9                   	leave  
  80318c:	c3                   	ret    

0080318d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80318d:	55                   	push   %ebp
  80318e:	89 e5                	mov    %esp,%ebp
  803190:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  803193:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80319a:	00 
  80319b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8031a2:	00 
  8031a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8031a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031ad:	89 04 24             	mov    %eax,(%esp)
  8031b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8031b3:	ba 01 00 00 00       	mov    $0x1,%edx
  8031b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8031bd:	e8 5a fd ff ff       	call   802f1c <syscall>
}
  8031c2:	c9                   	leave  
  8031c3:	c3                   	ret    

008031c4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8031c4:	55                   	push   %ebp
  8031c5:	89 e5                	mov    %esp,%ebp
  8031c7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8031ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8031d1:	00 
  8031d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8031d9:	00 
  8031da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8031e1:	00 
  8031e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8031ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8031f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8031f8:	e8 1f fd ff ff       	call   802f1c <syscall>
}
  8031fd:	c9                   	leave  
  8031fe:	c3                   	ret    

008031ff <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8031ff:	55                   	push   %ebp
  803200:	89 e5                	mov    %esp,%ebp
  803202:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  803205:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80320c:	00 
  80320d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803214:	00 
  803215:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80321c:	00 
  80321d:	8b 45 0c             	mov    0xc(%ebp),%eax
  803220:	89 04 24             	mov    %eax,(%esp)
  803223:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803226:	ba 00 00 00 00       	mov    $0x0,%edx
  80322b:	b8 04 00 00 00       	mov    $0x4,%eax
  803230:	e8 e7 fc ff ff       	call   802f1c <syscall>
}
  803235:	c9                   	leave  
  803236:	c3                   	ret    

00803237 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  803237:	55                   	push   %ebp
  803238:	89 e5                	mov    %esp,%ebp
  80323a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80323d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803244:	00 
  803245:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80324c:	00 
  80324d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803254:	00 
  803255:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80325c:	b9 00 00 00 00       	mov    $0x0,%ecx
  803261:	ba 00 00 00 00       	mov    $0x0,%edx
  803266:	b8 02 00 00 00       	mov    $0x2,%eax
  80326b:	e8 ac fc ff ff       	call   802f1c <syscall>
}
  803270:	c9                   	leave  
  803271:	c3                   	ret    

00803272 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  803272:	55                   	push   %ebp
  803273:	89 e5                	mov    %esp,%ebp
  803275:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  803278:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80327f:	00 
  803280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803287:	00 
  803288:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80328f:	00 
  803290:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803297:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80329a:	ba 01 00 00 00       	mov    $0x1,%edx
  80329f:	b8 03 00 00 00       	mov    $0x3,%eax
  8032a4:	e8 73 fc ff ff       	call   802f1c <syscall>
}
  8032a9:	c9                   	leave  
  8032aa:	c3                   	ret    

008032ab <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8032ab:	55                   	push   %ebp
  8032ac:	89 e5                	mov    %esp,%ebp
  8032ae:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8032b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8032b8:	00 
  8032b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8032c0:	00 
  8032c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8032c8:	00 
  8032c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8032d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8032d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8032da:	b8 01 00 00 00       	mov    $0x1,%eax
  8032df:	e8 38 fc ff ff       	call   802f1c <syscall>
}
  8032e4:	c9                   	leave  
  8032e5:	c3                   	ret    

008032e6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8032e6:	55                   	push   %ebp
  8032e7:	89 e5                	mov    %esp,%ebp
  8032e9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8032ec:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8032f3:	00 
  8032f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8032fb:	00 
  8032fc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803303:	00 
  803304:	8b 45 0c             	mov    0xc(%ebp),%eax
  803307:	89 04 24             	mov    %eax,(%esp)
  80330a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80330d:	ba 00 00 00 00       	mov    $0x0,%edx
  803312:	b8 00 00 00 00       	mov    $0x0,%eax
  803317:	e8 00 fc ff ff       	call   802f1c <syscall>
}
  80331c:	c9                   	leave  
  80331d:	c3                   	ret    
	...

00803320 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803320:	55                   	push   %ebp
  803321:	89 e5                	mov    %esp,%ebp
  803323:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  803326:	83 3d d4 c7 80 00 00 	cmpl   $0x0,0x80c7d4
  80332d:	75 54                	jne    803383 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80332f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  803336:	00 
  803337:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80333e:	ee 
  80333f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803346:	e8 42 fe ff ff       	call   80318d <sys_page_alloc>
  80334b:	85 c0                	test   %eax,%eax
  80334d:	79 20                	jns    80336f <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80334f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803353:	c7 44 24 08 cb 4f 80 	movl   $0x804fcb,0x8(%esp)
  80335a:	00 
  80335b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  803362:	00 
  803363:	c7 04 24 e3 4f 80 00 	movl   $0x804fe3,(%esp)
  80336a:	e8 c1 ef ff ff       	call   802330 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80336f:	c7 44 24 04 90 33 80 	movl   $0x803390,0x4(%esp)
  803376:	00 
  803377:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80337e:	e8 f1 fc ff ff       	call   803074 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803383:	8b 45 08             	mov    0x8(%ebp),%eax
  803386:	a3 d4 c7 80 00       	mov    %eax,0x80c7d4
}
  80338b:	c9                   	leave  
  80338c:	c3                   	ret    
  80338d:	00 00                	add    %al,(%eax)
	...

00803390 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  803390:	54                   	push   %esp
	movl _pgfault_handler, %eax
  803391:	a1 d4 c7 80 00       	mov    0x80c7d4,%eax
	call *%eax
  803396:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  803398:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  80339b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80339f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8033a2:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8033a6:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8033aa:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8033ac:	83 c4 08             	add    $0x8,%esp
	popal
  8033af:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8033b0:	83 c4 04             	add    $0x4,%esp
	popfl
  8033b3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8033b4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8033b5:	c3                   	ret    
	...

008033c0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8033c0:	55                   	push   %ebp
  8033c1:	89 e5                	mov    %esp,%ebp
  8033c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8033c6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8033cc:	b8 01 00 00 00       	mov    $0x1,%eax
  8033d1:	39 ca                	cmp    %ecx,%edx
  8033d3:	75 04                	jne    8033d9 <ipc_find_env+0x19>
  8033d5:	b0 00                	mov    $0x0,%al
  8033d7:	eb 11                	jmp    8033ea <ipc_find_env+0x2a>
  8033d9:	89 c2                	mov    %eax,%edx
  8033db:	c1 e2 07             	shl    $0x7,%edx
  8033de:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8033e4:	8b 12                	mov    (%edx),%edx
  8033e6:	39 ca                	cmp    %ecx,%edx
  8033e8:	75 0f                	jne    8033f9 <ipc_find_env+0x39>
			return envs[i].env_id;
  8033ea:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  8033ee:	c1 e0 06             	shl    $0x6,%eax
  8033f1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  8033f7:	eb 0e                	jmp    803407 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8033f9:	83 c0 01             	add    $0x1,%eax
  8033fc:	3d 00 04 00 00       	cmp    $0x400,%eax
  803401:	75 d6                	jne    8033d9 <ipc_find_env+0x19>
  803403:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  803407:	5d                   	pop    %ebp
  803408:	c3                   	ret    

00803409 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803409:	55                   	push   %ebp
  80340a:	89 e5                	mov    %esp,%ebp
  80340c:	57                   	push   %edi
  80340d:	56                   	push   %esi
  80340e:	53                   	push   %ebx
  80340f:	83 ec 1c             	sub    $0x1c,%esp
  803412:	8b 75 08             	mov    0x8(%ebp),%esi
  803415:	8b 7d 0c             	mov    0xc(%ebp),%edi
  803418:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80341b:	85 db                	test   %ebx,%ebx
  80341d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  803422:	0f 44 d8             	cmove  %eax,%ebx
  803425:	eb 25                	jmp    80344c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  803427:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80342a:	74 20                	je     80344c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  80342c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803430:	c7 44 24 08 f1 4f 80 	movl   $0x804ff1,0x8(%esp)
  803437:	00 
  803438:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80343f:	00 
  803440:	c7 04 24 0f 50 80 00 	movl   $0x80500f,(%esp)
  803447:	e8 e4 ee ff ff       	call   802330 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80344c:	8b 45 14             	mov    0x14(%ebp),%eax
  80344f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803453:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803457:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80345b:	89 34 24             	mov    %esi,(%esp)
  80345e:	e8 db fb ff ff       	call   80303e <sys_ipc_try_send>
  803463:	85 c0                	test   %eax,%eax
  803465:	75 c0                	jne    803427 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  803467:	e8 58 fd ff ff       	call   8031c4 <sys_yield>
}
  80346c:	83 c4 1c             	add    $0x1c,%esp
  80346f:	5b                   	pop    %ebx
  803470:	5e                   	pop    %esi
  803471:	5f                   	pop    %edi
  803472:	5d                   	pop    %ebp
  803473:	c3                   	ret    

00803474 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  803474:	55                   	push   %ebp
  803475:	89 e5                	mov    %esp,%ebp
  803477:	83 ec 28             	sub    $0x28,%esp
  80347a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80347d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  803480:	89 7d fc             	mov    %edi,-0x4(%ebp)
  803483:	8b 75 08             	mov    0x8(%ebp),%esi
  803486:	8b 45 0c             	mov    0xc(%ebp),%eax
  803489:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80348c:	85 c0                	test   %eax,%eax
  80348e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  803493:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  803496:	89 04 24             	mov    %eax,(%esp)
  803499:	e8 67 fb ff ff       	call   803005 <sys_ipc_recv>
  80349e:	89 c3                	mov    %eax,%ebx
  8034a0:	85 c0                	test   %eax,%eax
  8034a2:	79 2a                	jns    8034ce <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8034a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8034a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034ac:	c7 04 24 19 50 80 00 	movl   $0x805019,(%esp)
  8034b3:	e8 31 ef ff ff       	call   8023e9 <cprintf>
		if(from_env_store != NULL)
  8034b8:	85 f6                	test   %esi,%esi
  8034ba:	74 06                	je     8034c2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8034bc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8034c2:	85 ff                	test   %edi,%edi
  8034c4:	74 2c                	je     8034f2 <ipc_recv+0x7e>
			*perm_store = 0;
  8034c6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8034cc:	eb 24                	jmp    8034f2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8034ce:	85 f6                	test   %esi,%esi
  8034d0:	74 0a                	je     8034dc <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8034d2:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  8034d7:	8b 40 74             	mov    0x74(%eax),%eax
  8034da:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8034dc:	85 ff                	test   %edi,%edi
  8034de:	74 0a                	je     8034ea <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8034e0:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  8034e5:	8b 40 78             	mov    0x78(%eax),%eax
  8034e8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8034ea:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  8034ef:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8034f2:	89 d8                	mov    %ebx,%eax
  8034f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8034f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8034fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8034fd:	89 ec                	mov    %ebp,%esp
  8034ff:	5d                   	pop    %ebp
  803500:	c3                   	ret    
	...

00803510 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  803510:	55                   	push   %ebp
  803511:	89 e5                	mov    %esp,%ebp
  803513:	8b 45 08             	mov    0x8(%ebp),%eax
  803516:	05 00 00 00 30       	add    $0x30000000,%eax
  80351b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80351e:	5d                   	pop    %ebp
  80351f:	c3                   	ret    

00803520 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  803520:	55                   	push   %ebp
  803521:	89 e5                	mov    %esp,%ebp
  803523:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  803526:	8b 45 08             	mov    0x8(%ebp),%eax
  803529:	89 04 24             	mov    %eax,(%esp)
  80352c:	e8 df ff ff ff       	call   803510 <fd2num>
  803531:	05 20 00 0d 00       	add    $0xd0020,%eax
  803536:	c1 e0 0c             	shl    $0xc,%eax
}
  803539:	c9                   	leave  
  80353a:	c3                   	ret    

0080353b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80353b:	55                   	push   %ebp
  80353c:	89 e5                	mov    %esp,%ebp
  80353e:	57                   	push   %edi
  80353f:	56                   	push   %esi
  803540:	53                   	push   %ebx
  803541:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  803544:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  803549:	a8 01                	test   $0x1,%al
  80354b:	74 36                	je     803583 <fd_alloc+0x48>
  80354d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  803552:	a8 01                	test   $0x1,%al
  803554:	74 2d                	je     803583 <fd_alloc+0x48>
  803556:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80355b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  803560:	be 00 00 40 ef       	mov    $0xef400000,%esi
  803565:	89 c3                	mov    %eax,%ebx
  803567:	89 c2                	mov    %eax,%edx
  803569:	c1 ea 16             	shr    $0x16,%edx
  80356c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80356f:	f6 c2 01             	test   $0x1,%dl
  803572:	74 14                	je     803588 <fd_alloc+0x4d>
  803574:	89 c2                	mov    %eax,%edx
  803576:	c1 ea 0c             	shr    $0xc,%edx
  803579:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80357c:	f6 c2 01             	test   $0x1,%dl
  80357f:	75 10                	jne    803591 <fd_alloc+0x56>
  803581:	eb 05                	jmp    803588 <fd_alloc+0x4d>
  803583:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  803588:	89 1f                	mov    %ebx,(%edi)
  80358a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80358f:	eb 17                	jmp    8035a8 <fd_alloc+0x6d>
  803591:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  803596:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80359b:	75 c8                	jne    803565 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80359d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8035a3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8035a8:	5b                   	pop    %ebx
  8035a9:	5e                   	pop    %esi
  8035aa:	5f                   	pop    %edi
  8035ab:	5d                   	pop    %ebp
  8035ac:	c3                   	ret    

008035ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8035ad:	55                   	push   %ebp
  8035ae:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8035b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8035b3:	83 f8 1f             	cmp    $0x1f,%eax
  8035b6:	77 36                	ja     8035ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8035b8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8035bd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8035c0:	89 c2                	mov    %eax,%edx
  8035c2:	c1 ea 16             	shr    $0x16,%edx
  8035c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8035cc:	f6 c2 01             	test   $0x1,%dl
  8035cf:	74 1d                	je     8035ee <fd_lookup+0x41>
  8035d1:	89 c2                	mov    %eax,%edx
  8035d3:	c1 ea 0c             	shr    $0xc,%edx
  8035d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8035dd:	f6 c2 01             	test   $0x1,%dl
  8035e0:	74 0c                	je     8035ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8035e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8035e5:	89 02                	mov    %eax,(%edx)
  8035e7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8035ec:	eb 05                	jmp    8035f3 <fd_lookup+0x46>
  8035ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8035f3:	5d                   	pop    %ebp
  8035f4:	c3                   	ret    

008035f5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8035f5:	55                   	push   %ebp
  8035f6:	89 e5                	mov    %esp,%ebp
  8035f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8035fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8035fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  803602:	8b 45 08             	mov    0x8(%ebp),%eax
  803605:	89 04 24             	mov    %eax,(%esp)
  803608:	e8 a0 ff ff ff       	call   8035ad <fd_lookup>
  80360d:	85 c0                	test   %eax,%eax
  80360f:	78 0e                	js     80361f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803611:	8b 45 fc             	mov    -0x4(%ebp),%eax
  803614:	8b 55 0c             	mov    0xc(%ebp),%edx
  803617:	89 50 04             	mov    %edx,0x4(%eax)
  80361a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80361f:	c9                   	leave  
  803620:	c3                   	ret    

00803621 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  803621:	55                   	push   %ebp
  803622:	89 e5                	mov    %esp,%ebp
  803624:	56                   	push   %esi
  803625:	53                   	push   %ebx
  803626:	83 ec 10             	sub    $0x10,%esp
  803629:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80362c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80362f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  803634:	b8 68 a0 80 00       	mov    $0x80a068,%eax
  803639:	39 0d 68 a0 80 00    	cmp    %ecx,0x80a068
  80363f:	75 11                	jne    803652 <dev_lookup+0x31>
  803641:	eb 04                	jmp    803647 <dev_lookup+0x26>
  803643:	39 08                	cmp    %ecx,(%eax)
  803645:	75 10                	jne    803657 <dev_lookup+0x36>
			*dev = devtab[i];
  803647:	89 03                	mov    %eax,(%ebx)
  803649:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80364e:	66 90                	xchg   %ax,%ax
  803650:	eb 36                	jmp    803688 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  803652:	be ac 50 80 00       	mov    $0x8050ac,%esi
  803657:	83 c2 01             	add    $0x1,%edx
  80365a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80365d:	85 c0                	test   %eax,%eax
  80365f:	75 e2                	jne    803643 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  803661:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  803666:	8b 40 48             	mov    0x48(%eax),%eax
  803669:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80366d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803671:	c7 04 24 2c 50 80 00 	movl   $0x80502c,(%esp)
  803678:	e8 6c ed ff ff       	call   8023e9 <cprintf>
	*dev = 0;
  80367d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  803683:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  803688:	83 c4 10             	add    $0x10,%esp
  80368b:	5b                   	pop    %ebx
  80368c:	5e                   	pop    %esi
  80368d:	5d                   	pop    %ebp
  80368e:	c3                   	ret    

0080368f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80368f:	55                   	push   %ebp
  803690:	89 e5                	mov    %esp,%ebp
  803692:	53                   	push   %ebx
  803693:	83 ec 24             	sub    $0x24,%esp
  803696:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803699:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80369c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8036a3:	89 04 24             	mov    %eax,(%esp)
  8036a6:	e8 02 ff ff ff       	call   8035ad <fd_lookup>
  8036ab:	85 c0                	test   %eax,%eax
  8036ad:	78 53                	js     803702 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8036af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8036b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8036b9:	8b 00                	mov    (%eax),%eax
  8036bb:	89 04 24             	mov    %eax,(%esp)
  8036be:	e8 5e ff ff ff       	call   803621 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8036c3:	85 c0                	test   %eax,%eax
  8036c5:	78 3b                	js     803702 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8036c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8036cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8036cf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8036d3:	74 2d                	je     803702 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8036d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8036d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8036df:	00 00 00 
	stat->st_isdir = 0;
  8036e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8036e9:	00 00 00 
	stat->st_dev = dev;
  8036ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8036ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8036f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8036f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8036fc:	89 14 24             	mov    %edx,(%esp)
  8036ff:	ff 50 14             	call   *0x14(%eax)
}
  803702:	83 c4 24             	add    $0x24,%esp
  803705:	5b                   	pop    %ebx
  803706:	5d                   	pop    %ebp
  803707:	c3                   	ret    

00803708 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  803708:	55                   	push   %ebp
  803709:	89 e5                	mov    %esp,%ebp
  80370b:	53                   	push   %ebx
  80370c:	83 ec 24             	sub    $0x24,%esp
  80370f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803712:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803715:	89 44 24 04          	mov    %eax,0x4(%esp)
  803719:	89 1c 24             	mov    %ebx,(%esp)
  80371c:	e8 8c fe ff ff       	call   8035ad <fd_lookup>
  803721:	85 c0                	test   %eax,%eax
  803723:	78 5f                	js     803784 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80372c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80372f:	8b 00                	mov    (%eax),%eax
  803731:	89 04 24             	mov    %eax,(%esp)
  803734:	e8 e8 fe ff ff       	call   803621 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803739:	85 c0                	test   %eax,%eax
  80373b:	78 47                	js     803784 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80373d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803740:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  803744:	75 23                	jne    803769 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  803746:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80374b:	8b 40 48             	mov    0x48(%eax),%eax
  80374e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803752:	89 44 24 04          	mov    %eax,0x4(%esp)
  803756:	c7 04 24 4c 50 80 00 	movl   $0x80504c,(%esp)
  80375d:	e8 87 ec ff ff       	call   8023e9 <cprintf>
  803762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  803767:	eb 1b                	jmp    803784 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  803769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80376c:	8b 48 18             	mov    0x18(%eax),%ecx
  80376f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803774:	85 c9                	test   %ecx,%ecx
  803776:	74 0c                	je     803784 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  803778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80377b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80377f:	89 14 24             	mov    %edx,(%esp)
  803782:	ff d1                	call   *%ecx
}
  803784:	83 c4 24             	add    $0x24,%esp
  803787:	5b                   	pop    %ebx
  803788:	5d                   	pop    %ebp
  803789:	c3                   	ret    

0080378a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80378a:	55                   	push   %ebp
  80378b:	89 e5                	mov    %esp,%ebp
  80378d:	53                   	push   %ebx
  80378e:	83 ec 24             	sub    $0x24,%esp
  803791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803794:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80379b:	89 1c 24             	mov    %ebx,(%esp)
  80379e:	e8 0a fe ff ff       	call   8035ad <fd_lookup>
  8037a3:	85 c0                	test   %eax,%eax
  8037a5:	78 66                	js     80380d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8037a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8037aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8037b1:	8b 00                	mov    (%eax),%eax
  8037b3:	89 04 24             	mov    %eax,(%esp)
  8037b6:	e8 66 fe ff ff       	call   803621 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8037bb:	85 c0                	test   %eax,%eax
  8037bd:	78 4e                	js     80380d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8037bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8037c2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8037c6:	75 23                	jne    8037eb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8037c8:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  8037cd:	8b 40 48             	mov    0x48(%eax),%eax
  8037d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8037d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8037d8:	c7 04 24 70 50 80 00 	movl   $0x805070,(%esp)
  8037df:	e8 05 ec ff ff       	call   8023e9 <cprintf>
  8037e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8037e9:	eb 22                	jmp    80380d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8037eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037ee:	8b 48 0c             	mov    0xc(%eax),%ecx
  8037f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8037f6:	85 c9                	test   %ecx,%ecx
  8037f8:	74 13                	je     80380d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8037fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8037fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  803801:	8b 45 0c             	mov    0xc(%ebp),%eax
  803804:	89 44 24 04          	mov    %eax,0x4(%esp)
  803808:	89 14 24             	mov    %edx,(%esp)
  80380b:	ff d1                	call   *%ecx
}
  80380d:	83 c4 24             	add    $0x24,%esp
  803810:	5b                   	pop    %ebx
  803811:	5d                   	pop    %ebp
  803812:	c3                   	ret    

00803813 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  803813:	55                   	push   %ebp
  803814:	89 e5                	mov    %esp,%ebp
  803816:	53                   	push   %ebx
  803817:	83 ec 24             	sub    $0x24,%esp
  80381a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80381d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803820:	89 44 24 04          	mov    %eax,0x4(%esp)
  803824:	89 1c 24             	mov    %ebx,(%esp)
  803827:	e8 81 fd ff ff       	call   8035ad <fd_lookup>
  80382c:	85 c0                	test   %eax,%eax
  80382e:	78 6b                	js     80389b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803833:	89 44 24 04          	mov    %eax,0x4(%esp)
  803837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80383a:	8b 00                	mov    (%eax),%eax
  80383c:	89 04 24             	mov    %eax,(%esp)
  80383f:	e8 dd fd ff ff       	call   803621 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  803844:	85 c0                	test   %eax,%eax
  803846:	78 53                	js     80389b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  803848:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80384b:	8b 42 08             	mov    0x8(%edx),%eax
  80384e:	83 e0 03             	and    $0x3,%eax
  803851:	83 f8 01             	cmp    $0x1,%eax
  803854:	75 23                	jne    803879 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  803856:	a1 d0 c7 80 00       	mov    0x80c7d0,%eax
  80385b:	8b 40 48             	mov    0x48(%eax),%eax
  80385e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803862:	89 44 24 04          	mov    %eax,0x4(%esp)
  803866:	c7 04 24 8d 50 80 00 	movl   $0x80508d,(%esp)
  80386d:	e8 77 eb ff ff       	call   8023e9 <cprintf>
  803872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  803877:	eb 22                	jmp    80389b <read+0x88>
	}
	if (!dev->dev_read)
  803879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80387c:	8b 48 08             	mov    0x8(%eax),%ecx
  80387f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803884:	85 c9                	test   %ecx,%ecx
  803886:	74 13                	je     80389b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  803888:	8b 45 10             	mov    0x10(%ebp),%eax
  80388b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80388f:	8b 45 0c             	mov    0xc(%ebp),%eax
  803892:	89 44 24 04          	mov    %eax,0x4(%esp)
  803896:	89 14 24             	mov    %edx,(%esp)
  803899:	ff d1                	call   *%ecx
}
  80389b:	83 c4 24             	add    $0x24,%esp
  80389e:	5b                   	pop    %ebx
  80389f:	5d                   	pop    %ebp
  8038a0:	c3                   	ret    

008038a1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8038a1:	55                   	push   %ebp
  8038a2:	89 e5                	mov    %esp,%ebp
  8038a4:	57                   	push   %edi
  8038a5:	56                   	push   %esi
  8038a6:	53                   	push   %ebx
  8038a7:	83 ec 1c             	sub    $0x1c,%esp
  8038aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8038ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8038b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8038b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8038ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8038bf:	85 f6                	test   %esi,%esi
  8038c1:	74 29                	je     8038ec <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8038c3:	89 f0                	mov    %esi,%eax
  8038c5:	29 d0                	sub    %edx,%eax
  8038c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8038cb:	03 55 0c             	add    0xc(%ebp),%edx
  8038ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8038d2:	89 3c 24             	mov    %edi,(%esp)
  8038d5:	e8 39 ff ff ff       	call   803813 <read>
		if (m < 0)
  8038da:	85 c0                	test   %eax,%eax
  8038dc:	78 0e                	js     8038ec <readn+0x4b>
			return m;
		if (m == 0)
  8038de:	85 c0                	test   %eax,%eax
  8038e0:	74 08                	je     8038ea <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8038e2:	01 c3                	add    %eax,%ebx
  8038e4:	89 da                	mov    %ebx,%edx
  8038e6:	39 f3                	cmp    %esi,%ebx
  8038e8:	72 d9                	jb     8038c3 <readn+0x22>
  8038ea:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8038ec:	83 c4 1c             	add    $0x1c,%esp
  8038ef:	5b                   	pop    %ebx
  8038f0:	5e                   	pop    %esi
  8038f1:	5f                   	pop    %edi
  8038f2:	5d                   	pop    %ebp
  8038f3:	c3                   	ret    

008038f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8038f4:	55                   	push   %ebp
  8038f5:	89 e5                	mov    %esp,%ebp
  8038f7:	83 ec 28             	sub    $0x28,%esp
  8038fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8038fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  803900:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  803903:	89 34 24             	mov    %esi,(%esp)
  803906:	e8 05 fc ff ff       	call   803510 <fd2num>
  80390b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80390e:	89 54 24 04          	mov    %edx,0x4(%esp)
  803912:	89 04 24             	mov    %eax,(%esp)
  803915:	e8 93 fc ff ff       	call   8035ad <fd_lookup>
  80391a:	89 c3                	mov    %eax,%ebx
  80391c:	85 c0                	test   %eax,%eax
  80391e:	78 05                	js     803925 <fd_close+0x31>
  803920:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  803923:	74 0e                	je     803933 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  803925:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  803929:	b8 00 00 00 00       	mov    $0x0,%eax
  80392e:	0f 44 d8             	cmove  %eax,%ebx
  803931:	eb 3d                	jmp    803970 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  803933:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80393a:	8b 06                	mov    (%esi),%eax
  80393c:	89 04 24             	mov    %eax,(%esp)
  80393f:	e8 dd fc ff ff       	call   803621 <dev_lookup>
  803944:	89 c3                	mov    %eax,%ebx
  803946:	85 c0                	test   %eax,%eax
  803948:	78 16                	js     803960 <fd_close+0x6c>
		if (dev->dev_close)
  80394a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80394d:	8b 40 10             	mov    0x10(%eax),%eax
  803950:	bb 00 00 00 00       	mov    $0x0,%ebx
  803955:	85 c0                	test   %eax,%eax
  803957:	74 07                	je     803960 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  803959:	89 34 24             	mov    %esi,(%esp)
  80395c:	ff d0                	call   *%eax
  80395e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  803960:	89 74 24 04          	mov    %esi,0x4(%esp)
  803964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80396b:	e8 ac f7 ff ff       	call   80311c <sys_page_unmap>
	return r;
}
  803970:	89 d8                	mov    %ebx,%eax
  803972:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803975:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803978:	89 ec                	mov    %ebp,%esp
  80397a:	5d                   	pop    %ebp
  80397b:	c3                   	ret    

0080397c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80397c:	55                   	push   %ebp
  80397d:	89 e5                	mov    %esp,%ebp
  80397f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803985:	89 44 24 04          	mov    %eax,0x4(%esp)
  803989:	8b 45 08             	mov    0x8(%ebp),%eax
  80398c:	89 04 24             	mov    %eax,(%esp)
  80398f:	e8 19 fc ff ff       	call   8035ad <fd_lookup>
  803994:	85 c0                	test   %eax,%eax
  803996:	78 13                	js     8039ab <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  803998:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80399f:	00 
  8039a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8039a3:	89 04 24             	mov    %eax,(%esp)
  8039a6:	e8 49 ff ff ff       	call   8038f4 <fd_close>
}
  8039ab:	c9                   	leave  
  8039ac:	c3                   	ret    

008039ad <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8039ad:	55                   	push   %ebp
  8039ae:	89 e5                	mov    %esp,%ebp
  8039b0:	83 ec 18             	sub    $0x18,%esp
  8039b3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8039b6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8039b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8039c0:	00 
  8039c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8039c4:	89 04 24             	mov    %eax,(%esp)
  8039c7:	e8 78 03 00 00       	call   803d44 <open>
  8039cc:	89 c3                	mov    %eax,%ebx
  8039ce:	85 c0                	test   %eax,%eax
  8039d0:	78 1b                	js     8039ed <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8039d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8039d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8039d9:	89 1c 24             	mov    %ebx,(%esp)
  8039dc:	e8 ae fc ff ff       	call   80368f <fstat>
  8039e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8039e3:	89 1c 24             	mov    %ebx,(%esp)
  8039e6:	e8 91 ff ff ff       	call   80397c <close>
  8039eb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8039ed:	89 d8                	mov    %ebx,%eax
  8039ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8039f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8039f5:	89 ec                	mov    %ebp,%esp
  8039f7:	5d                   	pop    %ebp
  8039f8:	c3                   	ret    

008039f9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8039f9:	55                   	push   %ebp
  8039fa:	89 e5                	mov    %esp,%ebp
  8039fc:	53                   	push   %ebx
  8039fd:	83 ec 14             	sub    $0x14,%esp
  803a00:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  803a05:	89 1c 24             	mov    %ebx,(%esp)
  803a08:	e8 6f ff ff ff       	call   80397c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  803a0d:	83 c3 01             	add    $0x1,%ebx
  803a10:	83 fb 20             	cmp    $0x20,%ebx
  803a13:	75 f0                	jne    803a05 <close_all+0xc>
		close(i);
}
  803a15:	83 c4 14             	add    $0x14,%esp
  803a18:	5b                   	pop    %ebx
  803a19:	5d                   	pop    %ebp
  803a1a:	c3                   	ret    

00803a1b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  803a1b:	55                   	push   %ebp
  803a1c:	89 e5                	mov    %esp,%ebp
  803a1e:	83 ec 58             	sub    $0x58,%esp
  803a21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  803a24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  803a27:	89 7d fc             	mov    %edi,-0x4(%ebp)
  803a2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  803a2d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803a30:	89 44 24 04          	mov    %eax,0x4(%esp)
  803a34:	8b 45 08             	mov    0x8(%ebp),%eax
  803a37:	89 04 24             	mov    %eax,(%esp)
  803a3a:	e8 6e fb ff ff       	call   8035ad <fd_lookup>
  803a3f:	89 c3                	mov    %eax,%ebx
  803a41:	85 c0                	test   %eax,%eax
  803a43:	0f 88 e0 00 00 00    	js     803b29 <dup+0x10e>
		return r;
	close(newfdnum);
  803a49:	89 3c 24             	mov    %edi,(%esp)
  803a4c:	e8 2b ff ff ff       	call   80397c <close>

	newfd = INDEX2FD(newfdnum);
  803a51:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  803a57:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  803a5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803a5d:	89 04 24             	mov    %eax,(%esp)
  803a60:	e8 bb fa ff ff       	call   803520 <fd2data>
  803a65:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  803a67:	89 34 24             	mov    %esi,(%esp)
  803a6a:	e8 b1 fa ff ff       	call   803520 <fd2data>
  803a6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  803a72:	89 da                	mov    %ebx,%edx
  803a74:	89 d8                	mov    %ebx,%eax
  803a76:	c1 e8 16             	shr    $0x16,%eax
  803a79:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  803a80:	a8 01                	test   $0x1,%al
  803a82:	74 43                	je     803ac7 <dup+0xac>
  803a84:	c1 ea 0c             	shr    $0xc,%edx
  803a87:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  803a8e:	a8 01                	test   $0x1,%al
  803a90:	74 35                	je     803ac7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  803a92:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  803a99:	25 07 0e 00 00       	and    $0xe07,%eax
  803a9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  803aa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803aa5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803aa9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803ab0:	00 
  803ab1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803ab5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803abc:	e8 93 f6 ff ff       	call   803154 <sys_page_map>
  803ac1:	89 c3                	mov    %eax,%ebx
  803ac3:	85 c0                	test   %eax,%eax
  803ac5:	78 3f                	js     803b06 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  803ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803aca:	89 c2                	mov    %eax,%edx
  803acc:	c1 ea 0c             	shr    $0xc,%edx
  803acf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  803ad6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  803adc:	89 54 24 10          	mov    %edx,0x10(%esp)
  803ae0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  803ae4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803aeb:	00 
  803aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  803af0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803af7:	e8 58 f6 ff ff       	call   803154 <sys_page_map>
  803afc:	89 c3                	mov    %eax,%ebx
  803afe:	85 c0                	test   %eax,%eax
  803b00:	78 04                	js     803b06 <dup+0xeb>
  803b02:	89 fb                	mov    %edi,%ebx
  803b04:	eb 23                	jmp    803b29 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  803b06:	89 74 24 04          	mov    %esi,0x4(%esp)
  803b0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b11:	e8 06 f6 ff ff       	call   80311c <sys_page_unmap>
	sys_page_unmap(0, nva);
  803b16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  803b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  803b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b24:	e8 f3 f5 ff ff       	call   80311c <sys_page_unmap>
	return r;
}
  803b29:	89 d8                	mov    %ebx,%eax
  803b2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  803b2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  803b31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  803b34:	89 ec                	mov    %ebp,%esp
  803b36:	5d                   	pop    %ebp
  803b37:	c3                   	ret    

00803b38 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  803b38:	55                   	push   %ebp
  803b39:	89 e5                	mov    %esp,%ebp
  803b3b:	83 ec 18             	sub    $0x18,%esp
  803b3e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803b41:	89 75 fc             	mov    %esi,-0x4(%ebp)
  803b44:	89 c3                	mov    %eax,%ebx
  803b46:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  803b48:	83 3d 08 b0 80 00 00 	cmpl   $0x0,0x80b008
  803b4f:	75 11                	jne    803b62 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  803b51:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  803b58:	e8 63 f8 ff ff       	call   8033c0 <ipc_find_env>
  803b5d:	a3 08 b0 80 00       	mov    %eax,0x80b008
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  803b62:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  803b69:	00 
  803b6a:	c7 44 24 08 00 d0 80 	movl   $0x80d000,0x8(%esp)
  803b71:	00 
  803b72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803b76:	a1 08 b0 80 00       	mov    0x80b008,%eax
  803b7b:	89 04 24             	mov    %eax,(%esp)
  803b7e:	e8 86 f8 ff ff       	call   803409 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  803b83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  803b8a:	00 
  803b8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  803b8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803b96:	e8 d9 f8 ff ff       	call   803474 <ipc_recv>
}
  803b9b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803b9e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803ba1:	89 ec                	mov    %ebp,%esp
  803ba3:	5d                   	pop    %ebp
  803ba4:	c3                   	ret    

00803ba5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  803ba5:	55                   	push   %ebp
  803ba6:	89 e5                	mov    %esp,%ebp
  803ba8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  803bab:	8b 45 08             	mov    0x8(%ebp),%eax
  803bae:	8b 40 0c             	mov    0xc(%eax),%eax
  803bb1:	a3 00 d0 80 00       	mov    %eax,0x80d000
	fsipcbuf.set_size.req_size = newsize;
  803bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  803bb9:	a3 04 d0 80 00       	mov    %eax,0x80d004
	return fsipc(FSREQ_SET_SIZE, NULL);
  803bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  803bc3:	b8 02 00 00 00       	mov    $0x2,%eax
  803bc8:	e8 6b ff ff ff       	call   803b38 <fsipc>
}
  803bcd:	c9                   	leave  
  803bce:	c3                   	ret    

00803bcf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  803bcf:	55                   	push   %ebp
  803bd0:	89 e5                	mov    %esp,%ebp
  803bd2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  803bd8:	8b 40 0c             	mov    0xc(%eax),%eax
  803bdb:	a3 00 d0 80 00       	mov    %eax,0x80d000
	return fsipc(FSREQ_FLUSH, NULL);
  803be0:	ba 00 00 00 00       	mov    $0x0,%edx
  803be5:	b8 06 00 00 00       	mov    $0x6,%eax
  803bea:	e8 49 ff ff ff       	call   803b38 <fsipc>
}
  803bef:	c9                   	leave  
  803bf0:	c3                   	ret    

00803bf1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  803bf1:	55                   	push   %ebp
  803bf2:	89 e5                	mov    %esp,%ebp
  803bf4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  803bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  803bfc:	b8 08 00 00 00       	mov    $0x8,%eax
  803c01:	e8 32 ff ff ff       	call   803b38 <fsipc>
}
  803c06:	c9                   	leave  
  803c07:	c3                   	ret    

00803c08 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  803c08:	55                   	push   %ebp
  803c09:	89 e5                	mov    %esp,%ebp
  803c0b:	53                   	push   %ebx
  803c0c:	83 ec 14             	sub    $0x14,%esp
  803c0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803c12:	8b 45 08             	mov    0x8(%ebp),%eax
  803c15:	8b 40 0c             	mov    0xc(%eax),%eax
  803c18:	a3 00 d0 80 00       	mov    %eax,0x80d000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  803c22:	b8 05 00 00 00       	mov    $0x5,%eax
  803c27:	e8 0c ff ff ff       	call   803b38 <fsipc>
  803c2c:	85 c0                	test   %eax,%eax
  803c2e:	78 2b                	js     803c5b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803c30:	c7 44 24 04 00 d0 80 	movl   $0x80d000,0x4(%esp)
  803c37:	00 
  803c38:	89 1c 24             	mov    %ebx,(%esp)
  803c3b:	e8 ea ee ff ff       	call   802b2a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803c40:	a1 80 d0 80 00       	mov    0x80d080,%eax
  803c45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803c4b:	a1 84 d0 80 00       	mov    0x80d084,%eax
  803c50:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  803c56:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  803c5b:	83 c4 14             	add    $0x14,%esp
  803c5e:	5b                   	pop    %ebx
  803c5f:	5d                   	pop    %ebp
  803c60:	c3                   	ret    

00803c61 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803c61:	55                   	push   %ebp
  803c62:	89 e5                	mov    %esp,%ebp
  803c64:	83 ec 18             	sub    $0x18,%esp
  803c67:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  803c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  803c6d:	8b 52 0c             	mov    0xc(%edx),%edx
  803c70:	89 15 00 d0 80 00    	mov    %edx,0x80d000
  fsipcbuf.write.req_n = n;
  803c76:	a3 04 d0 80 00       	mov    %eax,0x80d004
  memmove(fsipcbuf.write.req_buf, buf,
  803c7b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  803c80:	ba f8 0f 00 00       	mov    $0xff8,%edx
  803c85:	0f 47 c2             	cmova  %edx,%eax
  803c88:	89 44 24 08          	mov    %eax,0x8(%esp)
  803c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  803c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  803c93:	c7 04 24 08 d0 80 00 	movl   $0x80d008,(%esp)
  803c9a:	e8 76 f0 ff ff       	call   802d15 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  803c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  803ca4:	b8 04 00 00 00       	mov    $0x4,%eax
  803ca9:	e8 8a fe ff ff       	call   803b38 <fsipc>
}
  803cae:	c9                   	leave  
  803caf:	c3                   	ret    

00803cb0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  803cb0:	55                   	push   %ebp
  803cb1:	89 e5                	mov    %esp,%ebp
  803cb3:	53                   	push   %ebx
  803cb4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  803cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  803cba:	8b 40 0c             	mov    0xc(%eax),%eax
  803cbd:	a3 00 d0 80 00       	mov    %eax,0x80d000
  fsipcbuf.read.req_n = n;
  803cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  803cc5:	a3 04 d0 80 00       	mov    %eax,0x80d004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  803cca:	ba 00 00 00 00       	mov    $0x0,%edx
  803ccf:	b8 03 00 00 00       	mov    $0x3,%eax
  803cd4:	e8 5f fe ff ff       	call   803b38 <fsipc>
  803cd9:	89 c3                	mov    %eax,%ebx
  803cdb:	85 c0                	test   %eax,%eax
  803cdd:	78 17                	js     803cf6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  803cdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  803ce3:	c7 44 24 04 00 d0 80 	movl   $0x80d000,0x4(%esp)
  803cea:	00 
  803ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  803cee:	89 04 24             	mov    %eax,(%esp)
  803cf1:	e8 1f f0 ff ff       	call   802d15 <memmove>
  return r;	
}
  803cf6:	89 d8                	mov    %ebx,%eax
  803cf8:	83 c4 14             	add    $0x14,%esp
  803cfb:	5b                   	pop    %ebx
  803cfc:	5d                   	pop    %ebp
  803cfd:	c3                   	ret    

00803cfe <remove>:
}

// Delete a file
int
remove(const char *path)
{
  803cfe:	55                   	push   %ebp
  803cff:	89 e5                	mov    %esp,%ebp
  803d01:	53                   	push   %ebx
  803d02:	83 ec 14             	sub    $0x14,%esp
  803d05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  803d08:	89 1c 24             	mov    %ebx,(%esp)
  803d0b:	e8 d0 ed ff ff       	call   802ae0 <strlen>
  803d10:	89 c2                	mov    %eax,%edx
  803d12:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  803d17:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  803d1d:	7f 1f                	jg     803d3e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  803d1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  803d23:	c7 04 24 00 d0 80 00 	movl   $0x80d000,(%esp)
  803d2a:	e8 fb ed ff ff       	call   802b2a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  803d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  803d34:	b8 07 00 00 00       	mov    $0x7,%eax
  803d39:	e8 fa fd ff ff       	call   803b38 <fsipc>
}
  803d3e:	83 c4 14             	add    $0x14,%esp
  803d41:	5b                   	pop    %ebx
  803d42:	5d                   	pop    %ebp
  803d43:	c3                   	ret    

00803d44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  803d44:	55                   	push   %ebp
  803d45:	89 e5                	mov    %esp,%ebp
  803d47:	83 ec 28             	sub    $0x28,%esp
  803d4a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  803d4d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  803d50:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  803d53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803d56:	89 04 24             	mov    %eax,(%esp)
  803d59:	e8 dd f7 ff ff       	call   80353b <fd_alloc>
  803d5e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  803d60:	85 c0                	test   %eax,%eax
  803d62:	0f 88 89 00 00 00    	js     803df1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  803d68:	89 34 24             	mov    %esi,(%esp)
  803d6b:	e8 70 ed ff ff       	call   802ae0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  803d70:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  803d75:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803d7a:	7f 75                	jg     803df1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  803d7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  803d80:	c7 04 24 00 d0 80 00 	movl   $0x80d000,(%esp)
  803d87:	e8 9e ed ff ff       	call   802b2a <strcpy>
  fsipcbuf.open.req_omode = mode;
  803d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  803d8f:	a3 00 d4 80 00       	mov    %eax,0x80d400
  r = fsipc(FSREQ_OPEN, fd);
  803d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803d97:	b8 01 00 00 00       	mov    $0x1,%eax
  803d9c:	e8 97 fd ff ff       	call   803b38 <fsipc>
  803da1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  803da3:	85 c0                	test   %eax,%eax
  803da5:	78 0f                	js     803db6 <open+0x72>
  return fd2num(fd);
  803da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803daa:	89 04 24             	mov    %eax,(%esp)
  803dad:	e8 5e f7 ff ff       	call   803510 <fd2num>
  803db2:	89 c3                	mov    %eax,%ebx
  803db4:	eb 3b                	jmp    803df1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  803db6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803dbd:	00 
  803dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803dc1:	89 04 24             	mov    %eax,(%esp)
  803dc4:	e8 2b fb ff ff       	call   8038f4 <fd_close>
  803dc9:	85 c0                	test   %eax,%eax
  803dcb:	74 24                	je     803df1 <open+0xad>
  803dcd:	c7 44 24 0c b8 50 80 	movl   $0x8050b8,0xc(%esp)
  803dd4:	00 
  803dd5:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  803ddc:	00 
  803ddd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  803de4:	00 
  803de5:	c7 04 24 cd 50 80 00 	movl   $0x8050cd,(%esp)
  803dec:	e8 3f e5 ff ff       	call   802330 <_panic>
  return r;
}
  803df1:	89 d8                	mov    %ebx,%eax
  803df3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  803df6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  803df9:	89 ec                	mov    %ebp,%esp
  803dfb:	5d                   	pop    %ebp
  803dfc:	c3                   	ret    
  803dfd:	00 00                	add    %al,(%eax)
	...

00803e00 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803e00:	55                   	push   %ebp
  803e01:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  803e03:	8b 45 08             	mov    0x8(%ebp),%eax
  803e06:	89 c2                	mov    %eax,%edx
  803e08:	c1 ea 16             	shr    $0x16,%edx
  803e0b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  803e12:	f6 c2 01             	test   $0x1,%dl
  803e15:	74 20                	je     803e37 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  803e17:	c1 e8 0c             	shr    $0xc,%eax
  803e1a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  803e21:	a8 01                	test   $0x1,%al
  803e23:	74 12                	je     803e37 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803e25:	c1 e8 0c             	shr    $0xc,%eax
  803e28:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  803e2d:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  803e32:	0f b7 c0             	movzwl %ax,%eax
  803e35:	eb 05                	jmp    803e3c <pageref+0x3c>
  803e37:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803e3c:	5d                   	pop    %ebp
  803e3d:	c3                   	ret    
	...

00803e40 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  803e40:	55                   	push   %ebp
  803e41:	89 e5                	mov    %esp,%ebp
  803e43:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  803e46:	c7 44 24 04 d8 50 80 	movl   $0x8050d8,0x4(%esp)
  803e4d:	00 
  803e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  803e51:	89 04 24             	mov    %eax,(%esp)
  803e54:	e8 d1 ec ff ff       	call   802b2a <strcpy>
	return 0;
}
  803e59:	b8 00 00 00 00       	mov    $0x0,%eax
  803e5e:	c9                   	leave  
  803e5f:	c3                   	ret    

00803e60 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  803e60:	55                   	push   %ebp
  803e61:	89 e5                	mov    %esp,%ebp
  803e63:	53                   	push   %ebx
  803e64:	83 ec 14             	sub    $0x14,%esp
  803e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  803e6a:	89 1c 24             	mov    %ebx,(%esp)
  803e6d:	e8 8e ff ff ff       	call   803e00 <pageref>
  803e72:	89 c2                	mov    %eax,%edx
  803e74:	b8 00 00 00 00       	mov    $0x0,%eax
  803e79:	83 fa 01             	cmp    $0x1,%edx
  803e7c:	75 0b                	jne    803e89 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  803e7e:	8b 43 0c             	mov    0xc(%ebx),%eax
  803e81:	89 04 24             	mov    %eax,(%esp)
  803e84:	e8 b9 02 00 00       	call   804142 <nsipc_close>
	else
		return 0;
}
  803e89:	83 c4 14             	add    $0x14,%esp
  803e8c:	5b                   	pop    %ebx
  803e8d:	5d                   	pop    %ebp
  803e8e:	c3                   	ret    

00803e8f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  803e8f:	55                   	push   %ebp
  803e90:	89 e5                	mov    %esp,%ebp
  803e92:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  803e95:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803e9c:	00 
  803e9d:	8b 45 10             	mov    0x10(%ebp),%eax
  803ea0:	89 44 24 08          	mov    %eax,0x8(%esp)
  803ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
  803ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  803eab:	8b 45 08             	mov    0x8(%ebp),%eax
  803eae:	8b 40 0c             	mov    0xc(%eax),%eax
  803eb1:	89 04 24             	mov    %eax,(%esp)
  803eb4:	e8 c5 02 00 00       	call   80417e <nsipc_send>
}
  803eb9:	c9                   	leave  
  803eba:	c3                   	ret    

00803ebb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  803ebb:	55                   	push   %ebp
  803ebc:	89 e5                	mov    %esp,%ebp
  803ebe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  803ec1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  803ec8:	00 
  803ec9:	8b 45 10             	mov    0x10(%ebp),%eax
  803ecc:	89 44 24 08          	mov    %eax,0x8(%esp)
  803ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
  803ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  803ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  803eda:	8b 40 0c             	mov    0xc(%eax),%eax
  803edd:	89 04 24             	mov    %eax,(%esp)
  803ee0:	e8 0c 03 00 00       	call   8041f1 <nsipc_recv>
}
  803ee5:	c9                   	leave  
  803ee6:	c3                   	ret    

00803ee7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  803ee7:	55                   	push   %ebp
  803ee8:	89 e5                	mov    %esp,%ebp
  803eea:	56                   	push   %esi
  803eeb:	53                   	push   %ebx
  803eec:	83 ec 20             	sub    $0x20,%esp
  803eef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803ef1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803ef4:	89 04 24             	mov    %eax,(%esp)
  803ef7:	e8 3f f6 ff ff       	call   80353b <fd_alloc>
  803efc:	89 c3                	mov    %eax,%ebx
  803efe:	85 c0                	test   %eax,%eax
  803f00:	78 21                	js     803f23 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  803f02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803f09:	00 
  803f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803f18:	e8 70 f2 ff ff       	call   80318d <sys_page_alloc>
  803f1d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  803f1f:	85 c0                	test   %eax,%eax
  803f21:	79 0a                	jns    803f2d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  803f23:	89 34 24             	mov    %esi,(%esp)
  803f26:	e8 17 02 00 00       	call   804142 <nsipc_close>
		return r;
  803f2b:	eb 28                	jmp    803f55 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  803f2d:	8b 15 84 a0 80 00    	mov    0x80a084,%edx
  803f33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f36:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  803f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f3b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  803f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f45:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  803f48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803f4b:	89 04 24             	mov    %eax,(%esp)
  803f4e:	e8 bd f5 ff ff       	call   803510 <fd2num>
  803f53:	89 c3                	mov    %eax,%ebx
}
  803f55:	89 d8                	mov    %ebx,%eax
  803f57:	83 c4 20             	add    $0x20,%esp
  803f5a:	5b                   	pop    %ebx
  803f5b:	5e                   	pop    %esi
  803f5c:	5d                   	pop    %ebp
  803f5d:	c3                   	ret    

00803f5e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  803f5e:	55                   	push   %ebp
  803f5f:	89 e5                	mov    %esp,%ebp
  803f61:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  803f64:	8b 45 10             	mov    0x10(%ebp),%eax
  803f67:	89 44 24 08          	mov    %eax,0x8(%esp)
  803f6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  803f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803f72:	8b 45 08             	mov    0x8(%ebp),%eax
  803f75:	89 04 24             	mov    %eax,(%esp)
  803f78:	e8 79 01 00 00       	call   8040f6 <nsipc_socket>
  803f7d:	85 c0                	test   %eax,%eax
  803f7f:	78 05                	js     803f86 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  803f81:	e8 61 ff ff ff       	call   803ee7 <alloc_sockfd>
}
  803f86:	c9                   	leave  
  803f87:	c3                   	ret    

00803f88 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  803f88:	55                   	push   %ebp
  803f89:	89 e5                	mov    %esp,%ebp
  803f8b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  803f8e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  803f91:	89 54 24 04          	mov    %edx,0x4(%esp)
  803f95:	89 04 24             	mov    %eax,(%esp)
  803f98:	e8 10 f6 ff ff       	call   8035ad <fd_lookup>
  803f9d:	85 c0                	test   %eax,%eax
  803f9f:	78 15                	js     803fb6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  803fa1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803fa4:	8b 0a                	mov    (%edx),%ecx
  803fa6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  803fab:	3b 0d 84 a0 80 00    	cmp    0x80a084,%ecx
  803fb1:	75 03                	jne    803fb6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  803fb3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  803fb6:	c9                   	leave  
  803fb7:	c3                   	ret    

00803fb8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  803fb8:	55                   	push   %ebp
  803fb9:	89 e5                	mov    %esp,%ebp
  803fbb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  803fc1:	e8 c2 ff ff ff       	call   803f88 <fd2sockid>
  803fc6:	85 c0                	test   %eax,%eax
  803fc8:	78 0f                	js     803fd9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  803fca:	8b 55 0c             	mov    0xc(%ebp),%edx
  803fcd:	89 54 24 04          	mov    %edx,0x4(%esp)
  803fd1:	89 04 24             	mov    %eax,(%esp)
  803fd4:	e8 47 01 00 00       	call   804120 <nsipc_listen>
}
  803fd9:	c9                   	leave  
  803fda:	c3                   	ret    

00803fdb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  803fdb:	55                   	push   %ebp
  803fdc:	89 e5                	mov    %esp,%ebp
  803fde:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  803fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  803fe4:	e8 9f ff ff ff       	call   803f88 <fd2sockid>
  803fe9:	85 c0                	test   %eax,%eax
  803feb:	78 16                	js     804003 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  803fed:	8b 55 10             	mov    0x10(%ebp),%edx
  803ff0:	89 54 24 08          	mov    %edx,0x8(%esp)
  803ff4:	8b 55 0c             	mov    0xc(%ebp),%edx
  803ff7:	89 54 24 04          	mov    %edx,0x4(%esp)
  803ffb:	89 04 24             	mov    %eax,(%esp)
  803ffe:	e8 6e 02 00 00       	call   804271 <nsipc_connect>
}
  804003:	c9                   	leave  
  804004:	c3                   	ret    

00804005 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  804005:	55                   	push   %ebp
  804006:	89 e5                	mov    %esp,%ebp
  804008:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80400b:	8b 45 08             	mov    0x8(%ebp),%eax
  80400e:	e8 75 ff ff ff       	call   803f88 <fd2sockid>
  804013:	85 c0                	test   %eax,%eax
  804015:	78 0f                	js     804026 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  804017:	8b 55 0c             	mov    0xc(%ebp),%edx
  80401a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80401e:	89 04 24             	mov    %eax,(%esp)
  804021:	e8 36 01 00 00       	call   80415c <nsipc_shutdown>
}
  804026:	c9                   	leave  
  804027:	c3                   	ret    

00804028 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  804028:	55                   	push   %ebp
  804029:	89 e5                	mov    %esp,%ebp
  80402b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80402e:	8b 45 08             	mov    0x8(%ebp),%eax
  804031:	e8 52 ff ff ff       	call   803f88 <fd2sockid>
  804036:	85 c0                	test   %eax,%eax
  804038:	78 16                	js     804050 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80403a:	8b 55 10             	mov    0x10(%ebp),%edx
  80403d:	89 54 24 08          	mov    %edx,0x8(%esp)
  804041:	8b 55 0c             	mov    0xc(%ebp),%edx
  804044:	89 54 24 04          	mov    %edx,0x4(%esp)
  804048:	89 04 24             	mov    %eax,(%esp)
  80404b:	e8 60 02 00 00       	call   8042b0 <nsipc_bind>
}
  804050:	c9                   	leave  
  804051:	c3                   	ret    

00804052 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  804052:	55                   	push   %ebp
  804053:	89 e5                	mov    %esp,%ebp
  804055:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  804058:	8b 45 08             	mov    0x8(%ebp),%eax
  80405b:	e8 28 ff ff ff       	call   803f88 <fd2sockid>
  804060:	85 c0                	test   %eax,%eax
  804062:	78 1f                	js     804083 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  804064:	8b 55 10             	mov    0x10(%ebp),%edx
  804067:	89 54 24 08          	mov    %edx,0x8(%esp)
  80406b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80406e:	89 54 24 04          	mov    %edx,0x4(%esp)
  804072:	89 04 24             	mov    %eax,(%esp)
  804075:	e8 75 02 00 00       	call   8042ef <nsipc_accept>
  80407a:	85 c0                	test   %eax,%eax
  80407c:	78 05                	js     804083 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80407e:	e8 64 fe ff ff       	call   803ee7 <alloc_sockfd>
}
  804083:	c9                   	leave  
  804084:	c3                   	ret    
	...

00804090 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  804090:	55                   	push   %ebp
  804091:	89 e5                	mov    %esp,%ebp
  804093:	53                   	push   %ebx
  804094:	83 ec 14             	sub    $0x14,%esp
  804097:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  804099:	83 3d 0c b0 80 00 00 	cmpl   $0x0,0x80b00c
  8040a0:	75 11                	jne    8040b3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8040a2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8040a9:	e8 12 f3 ff ff       	call   8033c0 <ipc_find_env>
  8040ae:	a3 0c b0 80 00       	mov    %eax,0x80b00c
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8040b3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8040ba:	00 
  8040bb:	c7 44 24 08 00 e0 80 	movl   $0x80e000,0x8(%esp)
  8040c2:	00 
  8040c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8040c7:	a1 0c b0 80 00       	mov    0x80b00c,%eax
  8040cc:	89 04 24             	mov    %eax,(%esp)
  8040cf:	e8 35 f3 ff ff       	call   803409 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8040d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8040db:	00 
  8040dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8040e3:	00 
  8040e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8040eb:	e8 84 f3 ff ff       	call   803474 <ipc_recv>
}
  8040f0:	83 c4 14             	add    $0x14,%esp
  8040f3:	5b                   	pop    %ebx
  8040f4:	5d                   	pop    %ebp
  8040f5:	c3                   	ret    

008040f6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8040f6:	55                   	push   %ebp
  8040f7:	89 e5                	mov    %esp,%ebp
  8040f9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8040fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8040ff:	a3 00 e0 80 00       	mov    %eax,0x80e000
	nsipcbuf.socket.req_type = type;
  804104:	8b 45 0c             	mov    0xc(%ebp),%eax
  804107:	a3 04 e0 80 00       	mov    %eax,0x80e004
	nsipcbuf.socket.req_protocol = protocol;
  80410c:	8b 45 10             	mov    0x10(%ebp),%eax
  80410f:	a3 08 e0 80 00       	mov    %eax,0x80e008
	return nsipc(NSREQ_SOCKET);
  804114:	b8 09 00 00 00       	mov    $0x9,%eax
  804119:	e8 72 ff ff ff       	call   804090 <nsipc>
}
  80411e:	c9                   	leave  
  80411f:	c3                   	ret    

00804120 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  804120:	55                   	push   %ebp
  804121:	89 e5                	mov    %esp,%ebp
  804123:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  804126:	8b 45 08             	mov    0x8(%ebp),%eax
  804129:	a3 00 e0 80 00       	mov    %eax,0x80e000
	nsipcbuf.listen.req_backlog = backlog;
  80412e:	8b 45 0c             	mov    0xc(%ebp),%eax
  804131:	a3 04 e0 80 00       	mov    %eax,0x80e004
	return nsipc(NSREQ_LISTEN);
  804136:	b8 06 00 00 00       	mov    $0x6,%eax
  80413b:	e8 50 ff ff ff       	call   804090 <nsipc>
}
  804140:	c9                   	leave  
  804141:	c3                   	ret    

00804142 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  804142:	55                   	push   %ebp
  804143:	89 e5                	mov    %esp,%ebp
  804145:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  804148:	8b 45 08             	mov    0x8(%ebp),%eax
  80414b:	a3 00 e0 80 00       	mov    %eax,0x80e000
	return nsipc(NSREQ_CLOSE);
  804150:	b8 04 00 00 00       	mov    $0x4,%eax
  804155:	e8 36 ff ff ff       	call   804090 <nsipc>
}
  80415a:	c9                   	leave  
  80415b:	c3                   	ret    

0080415c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80415c:	55                   	push   %ebp
  80415d:	89 e5                	mov    %esp,%ebp
  80415f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  804162:	8b 45 08             	mov    0x8(%ebp),%eax
  804165:	a3 00 e0 80 00       	mov    %eax,0x80e000
	nsipcbuf.shutdown.req_how = how;
  80416a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80416d:	a3 04 e0 80 00       	mov    %eax,0x80e004
	return nsipc(NSREQ_SHUTDOWN);
  804172:	b8 03 00 00 00       	mov    $0x3,%eax
  804177:	e8 14 ff ff ff       	call   804090 <nsipc>
}
  80417c:	c9                   	leave  
  80417d:	c3                   	ret    

0080417e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80417e:	55                   	push   %ebp
  80417f:	89 e5                	mov    %esp,%ebp
  804181:	53                   	push   %ebx
  804182:	83 ec 14             	sub    $0x14,%esp
  804185:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  804188:	8b 45 08             	mov    0x8(%ebp),%eax
  80418b:	a3 00 e0 80 00       	mov    %eax,0x80e000
	assert(size < 1600);
  804190:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  804196:	7e 24                	jle    8041bc <nsipc_send+0x3e>
  804198:	c7 44 24 0c e4 50 80 	movl   $0x8050e4,0xc(%esp)
  80419f:	00 
  8041a0:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  8041a7:	00 
  8041a8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8041af:	00 
  8041b0:	c7 04 24 f0 50 80 00 	movl   $0x8050f0,(%esp)
  8041b7:	e8 74 e1 ff ff       	call   802330 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8041bc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8041c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8041c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8041c7:	c7 04 24 0c e0 80 00 	movl   $0x80e00c,(%esp)
  8041ce:	e8 42 eb ff ff       	call   802d15 <memmove>
	nsipcbuf.send.req_size = size;
  8041d3:	89 1d 04 e0 80 00    	mov    %ebx,0x80e004
	nsipcbuf.send.req_flags = flags;
  8041d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8041dc:	a3 08 e0 80 00       	mov    %eax,0x80e008
	return nsipc(NSREQ_SEND);
  8041e1:	b8 08 00 00 00       	mov    $0x8,%eax
  8041e6:	e8 a5 fe ff ff       	call   804090 <nsipc>
}
  8041eb:	83 c4 14             	add    $0x14,%esp
  8041ee:	5b                   	pop    %ebx
  8041ef:	5d                   	pop    %ebp
  8041f0:	c3                   	ret    

008041f1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8041f1:	55                   	push   %ebp
  8041f2:	89 e5                	mov    %esp,%ebp
  8041f4:	56                   	push   %esi
  8041f5:	53                   	push   %ebx
  8041f6:	83 ec 10             	sub    $0x10,%esp
  8041f9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8041fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8041ff:	a3 00 e0 80 00       	mov    %eax,0x80e000
	nsipcbuf.recv.req_len = len;
  804204:	89 35 04 e0 80 00    	mov    %esi,0x80e004
	nsipcbuf.recv.req_flags = flags;
  80420a:	8b 45 14             	mov    0x14(%ebp),%eax
  80420d:	a3 08 e0 80 00       	mov    %eax,0x80e008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  804212:	b8 07 00 00 00       	mov    $0x7,%eax
  804217:	e8 74 fe ff ff       	call   804090 <nsipc>
  80421c:	89 c3                	mov    %eax,%ebx
  80421e:	85 c0                	test   %eax,%eax
  804220:	78 46                	js     804268 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  804222:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  804227:	7f 04                	jg     80422d <nsipc_recv+0x3c>
  804229:	39 c6                	cmp    %eax,%esi
  80422b:	7d 24                	jge    804251 <nsipc_recv+0x60>
  80422d:	c7 44 24 0c fc 50 80 	movl   $0x8050fc,0xc(%esp)
  804234:	00 
  804235:	c7 44 24 08 cd 45 80 	movl   $0x8045cd,0x8(%esp)
  80423c:	00 
  80423d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  804244:	00 
  804245:	c7 04 24 f0 50 80 00 	movl   $0x8050f0,(%esp)
  80424c:	e8 df e0 ff ff       	call   802330 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  804251:	89 44 24 08          	mov    %eax,0x8(%esp)
  804255:	c7 44 24 04 00 e0 80 	movl   $0x80e000,0x4(%esp)
  80425c:	00 
  80425d:	8b 45 0c             	mov    0xc(%ebp),%eax
  804260:	89 04 24             	mov    %eax,(%esp)
  804263:	e8 ad ea ff ff       	call   802d15 <memmove>
	}

	return r;
}
  804268:	89 d8                	mov    %ebx,%eax
  80426a:	83 c4 10             	add    $0x10,%esp
  80426d:	5b                   	pop    %ebx
  80426e:	5e                   	pop    %esi
  80426f:	5d                   	pop    %ebp
  804270:	c3                   	ret    

00804271 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  804271:	55                   	push   %ebp
  804272:	89 e5                	mov    %esp,%ebp
  804274:	53                   	push   %ebx
  804275:	83 ec 14             	sub    $0x14,%esp
  804278:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80427b:	8b 45 08             	mov    0x8(%ebp),%eax
  80427e:	a3 00 e0 80 00       	mov    %eax,0x80e000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  804283:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  804287:	8b 45 0c             	mov    0xc(%ebp),%eax
  80428a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80428e:	c7 04 24 04 e0 80 00 	movl   $0x80e004,(%esp)
  804295:	e8 7b ea ff ff       	call   802d15 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80429a:	89 1d 14 e0 80 00    	mov    %ebx,0x80e014
	return nsipc(NSREQ_CONNECT);
  8042a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8042a5:	e8 e6 fd ff ff       	call   804090 <nsipc>
}
  8042aa:	83 c4 14             	add    $0x14,%esp
  8042ad:	5b                   	pop    %ebx
  8042ae:	5d                   	pop    %ebp
  8042af:	c3                   	ret    

008042b0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8042b0:	55                   	push   %ebp
  8042b1:	89 e5                	mov    %esp,%ebp
  8042b3:	53                   	push   %ebx
  8042b4:	83 ec 14             	sub    $0x14,%esp
  8042b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8042ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8042bd:	a3 00 e0 80 00       	mov    %eax,0x80e000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8042c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8042c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8042c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8042cd:	c7 04 24 04 e0 80 00 	movl   $0x80e004,(%esp)
  8042d4:	e8 3c ea ff ff       	call   802d15 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8042d9:	89 1d 14 e0 80 00    	mov    %ebx,0x80e014
	return nsipc(NSREQ_BIND);
  8042df:	b8 02 00 00 00       	mov    $0x2,%eax
  8042e4:	e8 a7 fd ff ff       	call   804090 <nsipc>
}
  8042e9:	83 c4 14             	add    $0x14,%esp
  8042ec:	5b                   	pop    %ebx
  8042ed:	5d                   	pop    %ebp
  8042ee:	c3                   	ret    

008042ef <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8042ef:	55                   	push   %ebp
  8042f0:	89 e5                	mov    %esp,%ebp
  8042f2:	83 ec 18             	sub    $0x18,%esp
  8042f5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8042f8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8042fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8042fe:	a3 00 e0 80 00       	mov    %eax,0x80e000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  804303:	b8 01 00 00 00       	mov    $0x1,%eax
  804308:	e8 83 fd ff ff       	call   804090 <nsipc>
  80430d:	89 c3                	mov    %eax,%ebx
  80430f:	85 c0                	test   %eax,%eax
  804311:	78 25                	js     804338 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  804313:	be 10 e0 80 00       	mov    $0x80e010,%esi
  804318:	8b 06                	mov    (%esi),%eax
  80431a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80431e:	c7 44 24 04 00 e0 80 	movl   $0x80e000,0x4(%esp)
  804325:	00 
  804326:	8b 45 0c             	mov    0xc(%ebp),%eax
  804329:	89 04 24             	mov    %eax,(%esp)
  80432c:	e8 e4 e9 ff ff       	call   802d15 <memmove>
		*addrlen = ret->ret_addrlen;
  804331:	8b 16                	mov    (%esi),%edx
  804333:	8b 45 10             	mov    0x10(%ebp),%eax
  804336:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  804338:	89 d8                	mov    %ebx,%eax
  80433a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80433d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  804340:	89 ec                	mov    %ebp,%esp
  804342:	5d                   	pop    %ebp
  804343:	c3                   	ret    
	...

00804350 <__udivdi3>:
  804350:	55                   	push   %ebp
  804351:	89 e5                	mov    %esp,%ebp
  804353:	57                   	push   %edi
  804354:	56                   	push   %esi
  804355:	83 ec 10             	sub    $0x10,%esp
  804358:	8b 45 14             	mov    0x14(%ebp),%eax
  80435b:	8b 55 08             	mov    0x8(%ebp),%edx
  80435e:	8b 75 10             	mov    0x10(%ebp),%esi
  804361:	8b 7d 0c             	mov    0xc(%ebp),%edi
  804364:	85 c0                	test   %eax,%eax
  804366:	89 55 f0             	mov    %edx,-0x10(%ebp)
  804369:	75 35                	jne    8043a0 <__udivdi3+0x50>
  80436b:	39 fe                	cmp    %edi,%esi
  80436d:	77 61                	ja     8043d0 <__udivdi3+0x80>
  80436f:	85 f6                	test   %esi,%esi
  804371:	75 0b                	jne    80437e <__udivdi3+0x2e>
  804373:	b8 01 00 00 00       	mov    $0x1,%eax
  804378:	31 d2                	xor    %edx,%edx
  80437a:	f7 f6                	div    %esi
  80437c:	89 c6                	mov    %eax,%esi
  80437e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  804381:	31 d2                	xor    %edx,%edx
  804383:	89 f8                	mov    %edi,%eax
  804385:	f7 f6                	div    %esi
  804387:	89 c7                	mov    %eax,%edi
  804389:	89 c8                	mov    %ecx,%eax
  80438b:	f7 f6                	div    %esi
  80438d:	89 c1                	mov    %eax,%ecx
  80438f:	89 fa                	mov    %edi,%edx
  804391:	89 c8                	mov    %ecx,%eax
  804393:	83 c4 10             	add    $0x10,%esp
  804396:	5e                   	pop    %esi
  804397:	5f                   	pop    %edi
  804398:	5d                   	pop    %ebp
  804399:	c3                   	ret    
  80439a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8043a0:	39 f8                	cmp    %edi,%eax
  8043a2:	77 1c                	ja     8043c0 <__udivdi3+0x70>
  8043a4:	0f bd d0             	bsr    %eax,%edx
  8043a7:	83 f2 1f             	xor    $0x1f,%edx
  8043aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8043ad:	75 39                	jne    8043e8 <__udivdi3+0x98>
  8043af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8043b2:	0f 86 a0 00 00 00    	jbe    804458 <__udivdi3+0x108>
  8043b8:	39 f8                	cmp    %edi,%eax
  8043ba:	0f 82 98 00 00 00    	jb     804458 <__udivdi3+0x108>
  8043c0:	31 ff                	xor    %edi,%edi
  8043c2:	31 c9                	xor    %ecx,%ecx
  8043c4:	89 c8                	mov    %ecx,%eax
  8043c6:	89 fa                	mov    %edi,%edx
  8043c8:	83 c4 10             	add    $0x10,%esp
  8043cb:	5e                   	pop    %esi
  8043cc:	5f                   	pop    %edi
  8043cd:	5d                   	pop    %ebp
  8043ce:	c3                   	ret    
  8043cf:	90                   	nop
  8043d0:	89 d1                	mov    %edx,%ecx
  8043d2:	89 fa                	mov    %edi,%edx
  8043d4:	89 c8                	mov    %ecx,%eax
  8043d6:	31 ff                	xor    %edi,%edi
  8043d8:	f7 f6                	div    %esi
  8043da:	89 c1                	mov    %eax,%ecx
  8043dc:	89 fa                	mov    %edi,%edx
  8043de:	89 c8                	mov    %ecx,%eax
  8043e0:	83 c4 10             	add    $0x10,%esp
  8043e3:	5e                   	pop    %esi
  8043e4:	5f                   	pop    %edi
  8043e5:	5d                   	pop    %ebp
  8043e6:	c3                   	ret    
  8043e7:	90                   	nop
  8043e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8043ec:	89 f2                	mov    %esi,%edx
  8043ee:	d3 e0                	shl    %cl,%eax
  8043f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8043f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8043f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8043fb:	89 c1                	mov    %eax,%ecx
  8043fd:	d3 ea                	shr    %cl,%edx
  8043ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  804403:	0b 55 ec             	or     -0x14(%ebp),%edx
  804406:	d3 e6                	shl    %cl,%esi
  804408:	89 c1                	mov    %eax,%ecx
  80440a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80440d:	89 fe                	mov    %edi,%esi
  80440f:	d3 ee                	shr    %cl,%esi
  804411:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  804415:	89 55 ec             	mov    %edx,-0x14(%ebp)
  804418:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80441b:	d3 e7                	shl    %cl,%edi
  80441d:	89 c1                	mov    %eax,%ecx
  80441f:	d3 ea                	shr    %cl,%edx
  804421:	09 d7                	or     %edx,%edi
  804423:	89 f2                	mov    %esi,%edx
  804425:	89 f8                	mov    %edi,%eax
  804427:	f7 75 ec             	divl   -0x14(%ebp)
  80442a:	89 d6                	mov    %edx,%esi
  80442c:	89 c7                	mov    %eax,%edi
  80442e:	f7 65 e8             	mull   -0x18(%ebp)
  804431:	39 d6                	cmp    %edx,%esi
  804433:	89 55 ec             	mov    %edx,-0x14(%ebp)
  804436:	72 30                	jb     804468 <__udivdi3+0x118>
  804438:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80443b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80443f:	d3 e2                	shl    %cl,%edx
  804441:	39 c2                	cmp    %eax,%edx
  804443:	73 05                	jae    80444a <__udivdi3+0xfa>
  804445:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  804448:	74 1e                	je     804468 <__udivdi3+0x118>
  80444a:	89 f9                	mov    %edi,%ecx
  80444c:	31 ff                	xor    %edi,%edi
  80444e:	e9 71 ff ff ff       	jmp    8043c4 <__udivdi3+0x74>
  804453:	90                   	nop
  804454:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  804458:	31 ff                	xor    %edi,%edi
  80445a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80445f:	e9 60 ff ff ff       	jmp    8043c4 <__udivdi3+0x74>
  804464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  804468:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80446b:	31 ff                	xor    %edi,%edi
  80446d:	89 c8                	mov    %ecx,%eax
  80446f:	89 fa                	mov    %edi,%edx
  804471:	83 c4 10             	add    $0x10,%esp
  804474:	5e                   	pop    %esi
  804475:	5f                   	pop    %edi
  804476:	5d                   	pop    %ebp
  804477:	c3                   	ret    
	...

00804480 <__umoddi3>:
  804480:	55                   	push   %ebp
  804481:	89 e5                	mov    %esp,%ebp
  804483:	57                   	push   %edi
  804484:	56                   	push   %esi
  804485:	83 ec 20             	sub    $0x20,%esp
  804488:	8b 55 14             	mov    0x14(%ebp),%edx
  80448b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80448e:	8b 7d 10             	mov    0x10(%ebp),%edi
  804491:	8b 75 0c             	mov    0xc(%ebp),%esi
  804494:	85 d2                	test   %edx,%edx
  804496:	89 c8                	mov    %ecx,%eax
  804498:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80449b:	75 13                	jne    8044b0 <__umoddi3+0x30>
  80449d:	39 f7                	cmp    %esi,%edi
  80449f:	76 3f                	jbe    8044e0 <__umoddi3+0x60>
  8044a1:	89 f2                	mov    %esi,%edx
  8044a3:	f7 f7                	div    %edi
  8044a5:	89 d0                	mov    %edx,%eax
  8044a7:	31 d2                	xor    %edx,%edx
  8044a9:	83 c4 20             	add    $0x20,%esp
  8044ac:	5e                   	pop    %esi
  8044ad:	5f                   	pop    %edi
  8044ae:	5d                   	pop    %ebp
  8044af:	c3                   	ret    
  8044b0:	39 f2                	cmp    %esi,%edx
  8044b2:	77 4c                	ja     804500 <__umoddi3+0x80>
  8044b4:	0f bd ca             	bsr    %edx,%ecx
  8044b7:	83 f1 1f             	xor    $0x1f,%ecx
  8044ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8044bd:	75 51                	jne    804510 <__umoddi3+0x90>
  8044bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8044c2:	0f 87 e0 00 00 00    	ja     8045a8 <__umoddi3+0x128>
  8044c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8044cb:	29 f8                	sub    %edi,%eax
  8044cd:	19 d6                	sbb    %edx,%esi
  8044cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8044d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8044d5:	89 f2                	mov    %esi,%edx
  8044d7:	83 c4 20             	add    $0x20,%esp
  8044da:	5e                   	pop    %esi
  8044db:	5f                   	pop    %edi
  8044dc:	5d                   	pop    %ebp
  8044dd:	c3                   	ret    
  8044de:	66 90                	xchg   %ax,%ax
  8044e0:	85 ff                	test   %edi,%edi
  8044e2:	75 0b                	jne    8044ef <__umoddi3+0x6f>
  8044e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8044e9:	31 d2                	xor    %edx,%edx
  8044eb:	f7 f7                	div    %edi
  8044ed:	89 c7                	mov    %eax,%edi
  8044ef:	89 f0                	mov    %esi,%eax
  8044f1:	31 d2                	xor    %edx,%edx
  8044f3:	f7 f7                	div    %edi
  8044f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8044f8:	f7 f7                	div    %edi
  8044fa:	eb a9                	jmp    8044a5 <__umoddi3+0x25>
  8044fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  804500:	89 c8                	mov    %ecx,%eax
  804502:	89 f2                	mov    %esi,%edx
  804504:	83 c4 20             	add    $0x20,%esp
  804507:	5e                   	pop    %esi
  804508:	5f                   	pop    %edi
  804509:	5d                   	pop    %ebp
  80450a:	c3                   	ret    
  80450b:	90                   	nop
  80450c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  804510:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  804514:	d3 e2                	shl    %cl,%edx
  804516:	89 55 f4             	mov    %edx,-0xc(%ebp)
  804519:	ba 20 00 00 00       	mov    $0x20,%edx
  80451e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  804521:	89 55 ec             	mov    %edx,-0x14(%ebp)
  804524:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  804528:	89 fa                	mov    %edi,%edx
  80452a:	d3 ea                	shr    %cl,%edx
  80452c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  804530:	0b 55 f4             	or     -0xc(%ebp),%edx
  804533:	d3 e7                	shl    %cl,%edi
  804535:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  804539:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80453c:	89 f2                	mov    %esi,%edx
  80453e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  804541:	89 c7                	mov    %eax,%edi
  804543:	d3 ea                	shr    %cl,%edx
  804545:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  804549:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80454c:	89 c2                	mov    %eax,%edx
  80454e:	d3 e6                	shl    %cl,%esi
  804550:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  804554:	d3 ea                	shr    %cl,%edx
  804556:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80455a:	09 d6                	or     %edx,%esi
  80455c:	89 f0                	mov    %esi,%eax
  80455e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  804561:	d3 e7                	shl    %cl,%edi
  804563:	89 f2                	mov    %esi,%edx
  804565:	f7 75 f4             	divl   -0xc(%ebp)
  804568:	89 d6                	mov    %edx,%esi
  80456a:	f7 65 e8             	mull   -0x18(%ebp)
  80456d:	39 d6                	cmp    %edx,%esi
  80456f:	72 2b                	jb     80459c <__umoddi3+0x11c>
  804571:	39 c7                	cmp    %eax,%edi
  804573:	72 23                	jb     804598 <__umoddi3+0x118>
  804575:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  804579:	29 c7                	sub    %eax,%edi
  80457b:	19 d6                	sbb    %edx,%esi
  80457d:	89 f0                	mov    %esi,%eax
  80457f:	89 f2                	mov    %esi,%edx
  804581:	d3 ef                	shr    %cl,%edi
  804583:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  804587:	d3 e0                	shl    %cl,%eax
  804589:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80458d:	09 f8                	or     %edi,%eax
  80458f:	d3 ea                	shr    %cl,%edx
  804591:	83 c4 20             	add    $0x20,%esp
  804594:	5e                   	pop    %esi
  804595:	5f                   	pop    %edi
  804596:	5d                   	pop    %ebp
  804597:	c3                   	ret    
  804598:	39 d6                	cmp    %edx,%esi
  80459a:	75 d9                	jne    804575 <__umoddi3+0xf5>
  80459c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80459f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8045a2:	eb d1                	jmp    804575 <__umoddi3+0xf5>
  8045a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8045a8:	39 f2                	cmp    %esi,%edx
  8045aa:	0f 82 18 ff ff ff    	jb     8044c8 <__umoddi3+0x48>
  8045b0:	e9 1d ff ff ff       	jmp    8044d2 <__umoddi3+0x52>
