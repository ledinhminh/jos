
obj/boot/boot.out:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.set CR0_PE_ON,      0x1         # protected mode enable flag

.globl start
start:
  .code16                     # Assemble for 16-bit mode
  cli                         # Disable interrupts
    7c00:	fa                   	cli    
  cld                         # String operations increment
    7c01:	fc                   	cld    

  # Set up the important data segment registers (DS, ES, SS).
  xorw    %ax,%ax             # Segment number zero
    7c02:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c04:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c06:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c08:	8e d0                	mov    %eax,%ss

00007c0a <seta20.1>:
  # Enable A20:
  #   For backwards compatibility with the earliest PCs, physical
  #   address line 20 is tied low, so that addresses higher than
  #   1MB wrap around to zero by default.  This code undoes this.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c0a:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0c:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0e:	75 fa                	jne    7c0a <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c10:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c12:	e6 64                	out    %al,$0x64

00007c14 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c14:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c16:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c18:	75 fa                	jne    7c14 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c1a:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1c:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode, using a bootstrap GDT
  # and segment translation that makes virtual addresses 
  # identical to their physical addresses, so that the 
  # effective memory map does not change during the switch.
  lgdt    gdtdesc
    7c1e:	0f 01 16             	lgdtl  (%esi)
    7c21:	64                   	fs
    7c22:	7c 0f                	jl     7c33 <protcseg+0x1>
  movl    %cr0, %eax
    7c24:	20 c0                	and    %al,%al
  orl     $CR0_PE_ON, %eax
    7c26:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c2a:	0f 22 c0             	mov    %eax,%cr0
  
  # Jump to next instruction, but in 32-bit code segment.
  # Switches processor into 32-bit mode.
  ljmp    $PROT_MODE_CSEG, $protcseg
    7c2d:	ea 32 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c32

00007c32 <protcseg>:

  .code32                     # Assemble for 32-bit mode
protcseg:
  # Set up the protected-mode data segment registers
  movw    $PROT_MODE_DSEG, %ax    # Our data segment selector
    7c32:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c36:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c38:	8e c0                	mov    %eax,%es
  movw    %ax, %fs                # -> FS
    7c3a:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c3c:	8e e8                	mov    %eax,%gs
  movw    %ax, %ss                # -> SS: Stack Segment
    7c3e:	8e d0                	mov    %eax,%ss
  
  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c40:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call bootmain
    7c45:	e8 d2 00 00 00       	call   7d1c <bootmain>

00007c4a <spin>:

  # If bootmain returns (it shouldn't), loop.
spin:
  jmp spin
    7c4a:	eb fe                	jmp    7c4a <spin>

00007c4c <gdt>:
	...
    7c54:	ff                   	(bad)  
    7c55:	ff 00                	incl   (%eax)
    7c57:	00 00                	add    %al,(%eax)
    7c59:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c60:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c64 <gdtdesc>:
    7c64:	17                   	pop    %ss
    7c65:	00 4c 7c 00          	add    %cl,0x0(%esp,%edi,2)
    7c69:	00 90 90 55 ba f7    	add    %dl,-0x845aa70(%eax)

00007c6c <waitdisk>:
	}
}

void
waitdisk(void)
{
    7c6c:	55                   	push   %ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7c6d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c72:	89 e5                	mov    %esp,%ebp
    7c74:	ec                   	in     (%dx),%al
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c75:	25 c0 00 00 00       	and    $0xc0,%eax
    7c7a:	83 f8 40             	cmp    $0x40,%eax
    7c7d:	75 f5                	jne    7c74 <waitdisk+0x8>
		/* do nothing */;
}
    7c7f:	5d                   	pop    %ebp
    7c80:	c3                   	ret    

00007c81 <readsect>:

void
readsect(void *dst, uint32_t offset)
{
    7c81:	55                   	push   %ebp
    7c82:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c87:	89 e5                	mov    %esp,%ebp
    7c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    7c8c:	57                   	push   %edi
    7c8d:	ec                   	in     (%dx),%al

void
waitdisk(void)
{
	// wait for disk reaady
	while ((inb(0x1F7) & 0xC0) != 0x40)
    7c8e:	25 c0 00 00 00       	and    $0xc0,%eax
    7c93:	83 f8 40             	cmp    $0x40,%eax
    7c96:	75 f5                	jne    7c8d <readsect+0xc>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
    7c98:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7c9d:	b0 01                	mov    $0x1,%al
    7c9f:	ee                   	out    %al,(%dx)
    7ca0:	b2 f3                	mov    $0xf3,%dl
    7ca2:	88 c8                	mov    %cl,%al
    7ca4:	ee                   	out    %al,(%dx)
    7ca5:	89 c8                	mov    %ecx,%eax
    7ca7:	b2 f4                	mov    $0xf4,%dl
    7ca9:	c1 e8 08             	shr    $0x8,%eax
    7cac:	ee                   	out    %al,(%dx)
    7cad:	89 c8                	mov    %ecx,%eax
    7caf:	b2 f5                	mov    $0xf5,%dl
    7cb1:	c1 e8 10             	shr    $0x10,%eax
    7cb4:	ee                   	out    %al,(%dx)
    7cb5:	c1 e9 18             	shr    $0x18,%ecx
    7cb8:	b2 f6                	mov    $0xf6,%dl
    7cba:	88 c8                	mov    %cl,%al
    7cbc:	83 c8 e0             	or     $0xffffffe0,%eax
    7cbf:	ee                   	out    %al,(%dx)
    7cc0:	b0 20                	mov    $0x20,%al
    7cc2:	b2 f7                	mov    $0xf7,%dl
    7cc4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
    7cc5:	ec                   	in     (%dx),%al
    7cc6:	25 c0 00 00 00       	and    $0xc0,%eax
    7ccb:	83 f8 40             	cmp    $0x40,%eax
    7cce:	75 f5                	jne    7cc5 <readsect+0x44>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
    7cd0:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cd3:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cd8:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cdd:	fc                   	cld    
    7cde:	f2 6d                	repnz insl (%dx),%es:(%edi)
	// wait for disk to be ready
	waitdisk();

	// read a sector
	insl(0x1F0, dst, SECTSIZE/4);
}
    7ce0:	5f                   	pop    %edi
    7ce1:	5d                   	pop    %ebp
    7ce2:	c3                   	ret    

00007ce3 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7ce3:	55                   	push   %ebp
    7ce4:	89 e5                	mov    %esp,%ebp
    7ce6:	57                   	push   %edi
	uint32_t end_pa;

	end_pa = pa + count;
    7ce7:	8b 7d 0c             	mov    0xc(%ebp),%edi

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
    7cea:	56                   	push   %esi
    7ceb:	8b 75 10             	mov    0x10(%ebp),%esi
    7cee:	53                   	push   %ebx
    7cef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	
	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cf2:	c1 ee 09             	shr    $0x9,%esi
void
readseg(uint32_t pa, uint32_t count, uint32_t offset)
{
	uint32_t end_pa;

	end_pa = pa + count;
    7cf5:	01 df                	add    %ebx,%edi
	
	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);

	// translate from bytes to sectors, and kernel starts at sector 1
	offset = (offset / SECTSIZE) + 1;
    7cf7:	46                   	inc    %esi
	uint32_t end_pa;

	end_pa = pa + count;
	
	// round down to sector boundary
	pa &= ~(SECTSIZE - 1);
    7cf8:	81 e3 00 fe ff ff    	and    $0xfffffe00,%ebx
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
    7cfe:	eb 10                	jmp    7d10 <readseg+0x2d>
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7d00:	56                   	push   %esi
		pa += SECTSIZE;
		offset++;
    7d01:	46                   	inc    %esi
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7d02:	53                   	push   %ebx
		pa += SECTSIZE;
    7d03:	81 c3 00 02 00 00    	add    $0x200,%ebx
	while (pa < end_pa) {
		// Since we haven't enabled paging yet and we're using
		// an identity segment mapping (see boot.S), we can
		// use physical addresses directly.  This won't be the
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
    7d09:	e8 73 ff ff ff       	call   7c81 <readsect>
		pa += SECTSIZE;
		offset++;
    7d0e:	58                   	pop    %eax
    7d0f:	5a                   	pop    %edx
	offset = (offset / SECTSIZE) + 1;

	// If this is too slow, we could read lots of sectors at a time.
	// We'd write more to memory than asked, but it doesn't matter --
	// we load in increasing order.
	while (pa < end_pa) {
    7d10:	39 fb                	cmp    %edi,%ebx
    7d12:	72 ec                	jb     7d00 <readseg+0x1d>
		// case once JOS enables the MMU.
		readsect((uint8_t*) pa, offset);
		pa += SECTSIZE;
		offset++;
	}
}
    7d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
    7d17:	5b                   	pop    %ebx
    7d18:	5e                   	pop    %esi
    7d19:	5f                   	pop    %edi
    7d1a:	5d                   	pop    %ebp
    7d1b:	c3                   	ret    

00007d1c <bootmain>:
void readsect(void*, uint32_t);
void readseg(uint32_t, uint32_t, uint32_t);

void
bootmain(void)
{
    7d1c:	55                   	push   %ebp
    7d1d:	89 e5                	mov    %esp,%ebp
    7d1f:	56                   	push   %esi
    7d20:	53                   	push   %ebx
	struct Proghdr *ph, *eph;

	// read 1st page off disk
	readseg((uint32_t) ELFHDR, SECTSIZE*8, 0);
    7d21:	6a 00                	push   $0x0
    7d23:	68 00 10 00 00       	push   $0x1000
    7d28:	68 00 00 01 00       	push   $0x10000
    7d2d:	e8 b1 ff ff ff       	call   7ce3 <readseg>

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
    7d32:	83 c4 0c             	add    $0xc,%esp
    7d35:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d3c:	45 4c 46 
    7d3f:	75 39                	jne    7d7a <bootmain+0x5e>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d41:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d47:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
    7d4e:	81 c3 00 00 01 00    	add    $0x10000,%ebx
	eph = ph + ELFHDR->e_phnum;
    7d54:	c1 e0 05             	shl    $0x5,%eax
    7d57:	8d 34 03             	lea    (%ebx,%eax,1),%esi
	for (; ph < eph; ph++)
    7d5a:	eb 14                	jmp    7d70 <bootmain+0x54>
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d5c:	ff 73 04             	pushl  0x4(%ebx)
    7d5f:	ff 73 14             	pushl  0x14(%ebx)
    7d62:	ff 73 0c             	pushl  0xc(%ebx)
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d65:	83 c3 20             	add    $0x20,%ebx
		// p_pa is the load address of this segment (as well
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
    7d68:	e8 76 ff ff ff       	call   7ce3 <readseg>
		goto bad;

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	for (; ph < eph; ph++)
    7d6d:	83 c4 0c             	add    $0xc,%esp
    7d70:	39 f3                	cmp    %esi,%ebx
    7d72:	72 e8                	jb     7d5c <bootmain+0x40>
		// as the physical address)
		readseg(ph->p_pa, ph->p_memsz, ph->p_offset);

	// call the entry point from the ELF header
	// note: does not return!
	((void (*)(void)) (ELFHDR->e_entry))();
    7d74:	ff 15 18 00 01 00    	call   *0x10018
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
    7d7a:	ba 00 8a 00 00       	mov    $0x8a00,%edx
    7d7f:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
    7d84:	66 ef                	out    %ax,(%dx)
    7d86:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    7d8b:	66 ef                	out    %ax,(%dx)
    7d8d:	eb fe                	jmp    7d8d <bootmain+0x71>
