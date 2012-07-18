
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 43 02 00 00       	call   800274 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	if((int32_t)addr == USTACKTOP-PGSIZE)
  800042:	81 fb 00 d0 bf ee    	cmp    $0xeebfd000,%ebx
  800048:	75 0c                	jne    800056 <duppage+0x22>
		cprintf("deal STACK \n");
  80004a:	c7 04 24 20 1f 80 00 	movl   $0x801f20,(%esp)
  800051:	e8 43 03 00 00       	call   800399 <cprintf>
	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800056:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80005d:	00 
  80005e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 60 10 00 00       	call   8010ca <sys_page_alloc>
  80006a:	85 c0                	test   %eax,%eax
  80006c:	79 20                	jns    80008e <duppage+0x5a>
		panic("sys_page_alloc: %e", r);
  80006e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800072:	c7 44 24 08 2d 1f 80 	movl   $0x801f2d,0x8(%esp)
  800079:	00 
  80007a:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800081:	00 
  800082:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  800089:	e8 52 02 00 00       	call   8002e0 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80008e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800095:	00 
  800096:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  80009d:	00 
  80009e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000a5:	00 
  8000a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000aa:	89 34 24             	mov    %esi,(%esp)
  8000ad:	e8 df 0f 00 00       	call   801091 <sys_page_map>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 20                	jns    8000d6 <duppage+0xa2>
		panic("sys_page_map: %e", r);
  8000b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ba:	c7 44 24 08 50 1f 80 	movl   $0x801f50,0x8(%esp)
  8000c1:	00 
  8000c2:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000c9:	00 
  8000ca:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  8000d1:	e8 0a 02 00 00       	call   8002e0 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000d6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000dd:	00 
  8000de:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e2:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000e9:	e8 d7 0b 00 00       	call   800cc5 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000ee:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000f5:	00 
  8000f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fd:	e8 57 0f 00 00       	call   801059 <sys_page_unmap>
  800102:	85 c0                	test   %eax,%eax
  800104:	79 20                	jns    800126 <duppage+0xf2>
		panic("sys_page_unmap: %e", r);
  800106:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80010a:	c7 44 24 08 61 1f 80 	movl   $0x801f61,0x8(%esp)
  800111:	00 
  800112:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800119:	00 
  80011a:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  800121:	e8 ba 01 00 00       	call   8002e0 <_panic>
}
  800126:	83 c4 20             	add    $0x20,%esp
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <dumbfork>:

envid_t
dumbfork(void)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	53                   	push   %ebx
  800131:	83 ec 24             	sub    $0x24,%esp
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  800134:	bb 08 00 00 00       	mov    $0x8,%ebx
  800139:	89 d8                	mov    %ebx,%eax
  80013b:	51                   	push   %ecx
  80013c:	52                   	push   %edx
  80013d:	53                   	push   %ebx
  80013e:	55                   	push   %ebp
  80013f:	56                   	push   %esi
  800140:	57                   	push   %edi
  800141:	89 e5                	mov    %esp,%ebp
  800143:	8d 35 4b 01 80 00    	lea    0x80014b,%esi
  800149:	0f 34                	sysenter 

0080014b <.after_sysenter_label>:
  80014b:	5f                   	pop    %edi
  80014c:	5e                   	pop    %esi
  80014d:	5d                   	pop    %ebp
  80014e:	5b                   	pop    %ebx
  80014f:	5a                   	pop    %edx
  800150:	59                   	pop    %ecx
  800151:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  800153:	85 c0                	test   %eax,%eax
  800155:	79 20                	jns    800177 <.after_sysenter_label+0x2c>
		panic("sys_exofork: %e", envid);
  800157:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80015b:	c7 44 24 08 74 1f 80 	movl   $0x801f74,0x8(%esp)
  800162:	00 
  800163:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  80016a:	00 
  80016b:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  800172:	e8 69 01 00 00       	call   8002e0 <_panic>
	if (envid == 0) {
  800177:	85 c0                	test   %eax,%eax
  800179:	75 19                	jne    800194 <.after_sysenter_label+0x49>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  80017b:	e8 f4 0f 00 00       	call   801174 <sys_getenvid>
  800180:	25 ff 03 00 00       	and    $0x3ff,%eax
  800185:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80018d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800192:	eb 7e                	jmp    800212 <.after_sysenter_label+0xc7>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800194:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80019b:	b8 00 60 80 00       	mov    $0x806000,%eax
  8001a0:	3d 00 00 80 00       	cmp    $0x800000,%eax
  8001a5:	76 23                	jbe    8001ca <.after_sysenter_label+0x7f>
  8001a7:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  8001ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b0:	89 1c 24             	mov    %ebx,(%esp)
  8001b3:	e8 7c fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  8001b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001bb:	05 00 10 00 00       	add    $0x1000,%eax
  8001c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8001c3:	3d 00 60 80 00       	cmp    $0x806000,%eax
  8001c8:	72 e2                	jb     8001ac <.after_sysenter_label+0x61>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001cd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d6:	89 1c 24             	mov    %ebx,(%esp)
  8001d9:	e8 56 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001de:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001e5:	00 
  8001e6:	89 1c 24             	mov    %ebx,(%esp)
  8001e9:	e8 33 0e 00 00       	call   801021 <sys_env_set_status>
  8001ee:	85 c0                	test   %eax,%eax
  8001f0:	79 20                	jns    800212 <.after_sysenter_label+0xc7>
		panic("sys_env_set_status: %e", r);
  8001f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f6:	c7 44 24 08 84 1f 80 	movl   $0x801f84,0x8(%esp)
  8001fd:	00 
  8001fe:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  800205:	00 
  800206:	c7 04 24 40 1f 80 00 	movl   $0x801f40,(%esp)
  80020d:	e8 ce 00 00 00       	call   8002e0 <_panic>

	return envid;
}
  800212:	89 d8                	mov    %ebx,%eax
  800214:	83 c4 24             	add    $0x24,%esp
  800217:	5b                   	pop    %ebx
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    

0080021a <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	57                   	push   %edi
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;
	// fork a child process
	who = dumbfork();
  800223:	e8 05 ff ff ff       	call   80012d <dumbfork>
  800228:	89 c6                	mov    %eax,%esi
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80022f:	bf a1 1f 80 00       	mov    $0x801fa1,%edi
	int i;
	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800234:	eb 26                	jmp    80025c <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800236:	85 f6                	test   %esi,%esi
  800238:	b8 9b 1f 80 00       	mov    $0x801f9b,%eax
  80023d:	0f 45 c7             	cmovne %edi,%eax
  800240:	89 44 24 08          	mov    %eax,0x8(%esp)
  800244:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800248:	c7 04 24 a8 1f 80 00 	movl   $0x801fa8,(%esp)
  80024f:	e8 45 01 00 00       	call   800399 <cprintf>
		sys_yield();
  800254:	e8 a8 0e 00 00       	call   801101 <sys_yield>
	int i;
	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800259:	83 c3 01             	add    $0x1,%ebx
  80025c:	83 fe 01             	cmp    $0x1,%esi
  80025f:	19 c0                	sbb    %eax,%eax
  800261:	83 e0 0a             	and    $0xa,%eax
  800264:	83 c0 0a             	add    $0xa,%eax
  800267:	39 c3                	cmp    %eax,%ebx
  800269:	7c cb                	jl     800236 <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80026b:	83 c4 1c             	add    $0x1c,%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
	...

00800274 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 18             	sub    $0x18,%esp
  80027a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80027d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800280:	8b 75 08             	mov    0x8(%ebp),%esi
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800286:	e8 e9 0e 00 00       	call   801174 <sys_getenvid>
  80028b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800290:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800293:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800298:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80029d:	85 f6                	test   %esi,%esi
  80029f:	7e 07                	jle    8002a8 <libmain+0x34>
		binaryname = argv[0];
  8002a1:	8b 03                	mov    (%ebx),%eax
  8002a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002ac:	89 34 24             	mov    %esi,(%esp)
  8002af:	e8 66 ff ff ff       	call   80021a <umain>

	// exit gracefully
	exit();
  8002b4:	e8 0b 00 00 00       	call   8002c4 <exit>
}
  8002b9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002bc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002bf:	89 ec                	mov    %ebp,%esp
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    
	...

008002c4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002ca:	e8 7a 14 00 00       	call   801749 <close_all>
	sys_env_destroy(0);
  8002cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002d6:	e8 d4 0e 00 00       	call   8011af <sys_env_destroy>
}
  8002db:	c9                   	leave  
  8002dc:	c3                   	ret    
  8002dd:	00 00                	add    %al,(%eax)
	...

008002e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
  8002e5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002e8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002eb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002f1:	e8 7e 0e 00 00       	call   801174 <sys_getenvid>
  8002f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800304:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800308:	89 44 24 04          	mov    %eax,0x4(%esp)
  80030c:	c7 04 24 c4 1f 80 00 	movl   $0x801fc4,(%esp)
  800313:	e8 81 00 00 00       	call   800399 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800318:	89 74 24 04          	mov    %esi,0x4(%esp)
  80031c:	8b 45 10             	mov    0x10(%ebp),%eax
  80031f:	89 04 24             	mov    %eax,(%esp)
  800322:	e8 11 00 00 00       	call   800338 <vcprintf>
	cprintf("\n");
  800327:	c7 04 24 2b 1f 80 00 	movl   $0x801f2b,(%esp)
  80032e:	e8 66 00 00 00       	call   800399 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800333:	cc                   	int3   
  800334:	eb fd                	jmp    800333 <_panic+0x53>
	...

00800338 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800341:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800348:	00 00 00 
	b.cnt = 0;
  80034b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800352:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800355:	8b 45 0c             	mov    0xc(%ebp),%eax
  800358:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80035c:	8b 45 08             	mov    0x8(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800369:	89 44 24 04          	mov    %eax,0x4(%esp)
  80036d:	c7 04 24 b3 03 80 00 	movl   $0x8003b3,(%esp)
  800374:	e8 d4 01 00 00       	call   80054d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800379:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80037f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800383:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800389:	89 04 24             	mov    %eax,(%esp)
  80038c:	e8 92 0e 00 00       	call   801223 <sys_cputs>

	return b.cnt;
}
  800391:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80039f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8003a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	89 04 24             	mov    %eax,(%esp)
  8003ac:	e8 87 ff ff ff       	call   800338 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b1:	c9                   	leave  
  8003b2:	c3                   	ret    

008003b3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	53                   	push   %ebx
  8003b7:	83 ec 14             	sub    $0x14,%esp
  8003ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003bd:	8b 03                	mov    (%ebx),%eax
  8003bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003c6:	83 c0 01             	add    $0x1,%eax
  8003c9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003cb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003d0:	75 19                	jne    8003eb <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003d2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003d9:	00 
  8003da:	8d 43 08             	lea    0x8(%ebx),%eax
  8003dd:	89 04 24             	mov    %eax,(%esp)
  8003e0:	e8 3e 0e 00 00       	call   801223 <sys_cputs>
		b->idx = 0;
  8003e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003eb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ef:	83 c4 14             	add    $0x14,%esp
  8003f2:	5b                   	pop    %ebx
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    
	...

00800400 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 4c             	sub    $0x4c,%esp
  800409:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040c:	89 d6                	mov    %edx,%esi
  80040e:	8b 45 08             	mov    0x8(%ebp),%eax
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	8b 55 0c             	mov    0xc(%ebp),%edx
  800417:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80041a:	8b 45 10             	mov    0x10(%ebp),%eax
  80041d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800420:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800423:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800426:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042b:	39 d1                	cmp    %edx,%ecx
  80042d:	72 15                	jb     800444 <printnum+0x44>
  80042f:	77 07                	ja     800438 <printnum+0x38>
  800431:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800434:	39 d0                	cmp    %edx,%eax
  800436:	76 0c                	jbe    800444 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800438:	83 eb 01             	sub    $0x1,%ebx
  80043b:	85 db                	test   %ebx,%ebx
  80043d:	8d 76 00             	lea    0x0(%esi),%esi
  800440:	7f 61                	jg     8004a3 <printnum+0xa3>
  800442:	eb 70                	jmp    8004b4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800444:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800448:	83 eb 01             	sub    $0x1,%ebx
  80044b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80044f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800453:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800457:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80045b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80045e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800461:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800464:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800468:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80046f:	00 
  800470:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800473:	89 04 24             	mov    %eax,(%esp)
  800476:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800479:	89 54 24 04          	mov    %edx,0x4(%esp)
  80047d:	e8 1e 18 00 00       	call   801ca0 <__udivdi3>
  800482:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800485:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80048c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	89 54 24 04          	mov    %edx,0x4(%esp)
  800497:	89 f2                	mov    %esi,%edx
  800499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049c:	e8 5f ff ff ff       	call   800400 <printnum>
  8004a1:	eb 11                	jmp    8004b4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a7:	89 3c 24             	mov    %edi,(%esp)
  8004aa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7f ef                	jg     8004a3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8004bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ca:	00 
  8004cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ce:	89 14 24             	mov    %edx,(%esp)
  8004d1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d8:	e8 f3 18 00 00       	call   801dd0 <__umoddi3>
  8004dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e1:	0f be 80 e7 1f 80 00 	movsbl 0x801fe7(%eax),%eax
  8004e8:	89 04 24             	mov    %eax,(%esp)
  8004eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004ee:	83 c4 4c             	add    $0x4c,%esp
  8004f1:	5b                   	pop    %ebx
  8004f2:	5e                   	pop    %esi
  8004f3:	5f                   	pop    %edi
  8004f4:	5d                   	pop    %ebp
  8004f5:	c3                   	ret    

008004f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004f9:	83 fa 01             	cmp    $0x1,%edx
  8004fc:	7e 0e                	jle    80050c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	8d 4a 08             	lea    0x8(%edx),%ecx
  800503:	89 08                	mov    %ecx,(%eax)
  800505:	8b 02                	mov    (%edx),%eax
  800507:	8b 52 04             	mov    0x4(%edx),%edx
  80050a:	eb 22                	jmp    80052e <getuint+0x38>
	else if (lflag)
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 10                	je     800520 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800510:	8b 10                	mov    (%eax),%edx
  800512:	8d 4a 04             	lea    0x4(%edx),%ecx
  800515:	89 08                	mov    %ecx,(%eax)
  800517:	8b 02                	mov    (%edx),%eax
  800519:	ba 00 00 00 00       	mov    $0x0,%edx
  80051e:	eb 0e                	jmp    80052e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800520:	8b 10                	mov    (%eax),%edx
  800522:	8d 4a 04             	lea    0x4(%edx),%ecx
  800525:	89 08                	mov    %ecx,(%eax)
  800527:	8b 02                	mov    (%edx),%eax
  800529:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800536:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80053a:	8b 10                	mov    (%eax),%edx
  80053c:	3b 50 04             	cmp    0x4(%eax),%edx
  80053f:	73 0a                	jae    80054b <sprintputch+0x1b>
		*b->buf++ = ch;
  800541:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800544:	88 0a                	mov    %cl,(%edx)
  800546:	83 c2 01             	add    $0x1,%edx
  800549:	89 10                	mov    %edx,(%eax)
}
  80054b:	5d                   	pop    %ebp
  80054c:	c3                   	ret    

0080054d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
  800550:	57                   	push   %edi
  800551:	56                   	push   %esi
  800552:	53                   	push   %ebx
  800553:	83 ec 5c             	sub    $0x5c,%esp
  800556:	8b 7d 08             	mov    0x8(%ebp),%edi
  800559:	8b 75 0c             	mov    0xc(%ebp),%esi
  80055c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80055f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800566:	eb 11                	jmp    800579 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800568:	85 c0                	test   %eax,%eax
  80056a:	0f 84 68 04 00 00    	je     8009d8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800570:	89 74 24 04          	mov    %esi,0x4(%esp)
  800574:	89 04 24             	mov    %eax,(%esp)
  800577:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800579:	0f b6 03             	movzbl (%ebx),%eax
  80057c:	83 c3 01             	add    $0x1,%ebx
  80057f:	83 f8 25             	cmp    $0x25,%eax
  800582:	75 e4                	jne    800568 <vprintfmt+0x1b>
  800584:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80058b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800592:	b9 00 00 00 00       	mov    $0x0,%ecx
  800597:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80059b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005a2:	eb 06                	jmp    8005aa <vprintfmt+0x5d>
  8005a4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8005a8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005aa:	0f b6 13             	movzbl (%ebx),%edx
  8005ad:	0f b6 c2             	movzbl %dl,%eax
  8005b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005b3:	8d 43 01             	lea    0x1(%ebx),%eax
  8005b6:	83 ea 23             	sub    $0x23,%edx
  8005b9:	80 fa 55             	cmp    $0x55,%dl
  8005bc:	0f 87 f9 03 00 00    	ja     8009bb <vprintfmt+0x46e>
  8005c2:	0f b6 d2             	movzbl %dl,%edx
  8005c5:	ff 24 95 c0 21 80 00 	jmp    *0x8021c0(,%edx,4)
  8005cc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8005d0:	eb d6                	jmp    8005a8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d5:	83 ea 30             	sub    $0x30,%edx
  8005d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8005db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005de:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005e1:	83 fb 09             	cmp    $0x9,%ebx
  8005e4:	77 54                	ja     80063a <vprintfmt+0xed>
  8005e6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005e9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ec:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005ef:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005f2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8005f6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005f9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005fc:	83 fb 09             	cmp    $0x9,%ebx
  8005ff:	76 eb                	jbe    8005ec <vprintfmt+0x9f>
  800601:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800604:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800607:	eb 31                	jmp    80063a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800609:	8b 55 14             	mov    0x14(%ebp),%edx
  80060c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80060f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800612:	8b 12                	mov    (%edx),%edx
  800614:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800617:	eb 21                	jmp    80063a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800619:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061d:	ba 00 00 00 00       	mov    $0x0,%edx
  800622:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800626:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800629:	e9 7a ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>
  80062e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800635:	e9 6e ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80063a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80063e:	0f 89 64 ff ff ff    	jns    8005a8 <vprintfmt+0x5b>
  800644:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800647:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80064a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80064d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800650:	e9 53 ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800655:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800658:	e9 4b ff ff ff       	jmp    8005a8 <vprintfmt+0x5b>
  80065d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 50 04             	lea    0x4(%eax),%edx
  800666:	89 55 14             	mov    %edx,0x14(%ebp)
  800669:	89 74 24 04          	mov    %esi,0x4(%esp)
  80066d:	8b 00                	mov    (%eax),%eax
  80066f:	89 04 24             	mov    %eax,(%esp)
  800672:	ff d7                	call   *%edi
  800674:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800677:	e9 fd fe ff ff       	jmp    800579 <vprintfmt+0x2c>
  80067c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	89 c2                	mov    %eax,%edx
  80068c:	c1 fa 1f             	sar    $0x1f,%edx
  80068f:	31 d0                	xor    %edx,%eax
  800691:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800693:	83 f8 0f             	cmp    $0xf,%eax
  800696:	7f 0b                	jg     8006a3 <vprintfmt+0x156>
  800698:	8b 14 85 20 23 80 00 	mov    0x802320(,%eax,4),%edx
  80069f:	85 d2                	test   %edx,%edx
  8006a1:	75 20                	jne    8006c3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8006a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006a7:	c7 44 24 08 f8 1f 80 	movl   $0x801ff8,0x8(%esp)
  8006ae:	00 
  8006af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b3:	89 3c 24             	mov    %edi,(%esp)
  8006b6:	e8 a5 03 00 00       	call   800a60 <printfmt>
  8006bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006be:	e9 b6 fe ff ff       	jmp    800579 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8006c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c7:	c7 44 24 08 3b 24 80 	movl   $0x80243b,0x8(%esp)
  8006ce:	00 
  8006cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d3:	89 3c 24             	mov    %edi,(%esp)
  8006d6:	e8 85 03 00 00       	call   800a60 <printfmt>
  8006db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006de:	e9 96 fe ff ff       	jmp    800579 <vprintfmt+0x2c>
  8006e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006e6:	89 c3                	mov    %eax,%ebx
  8006e8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8006ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8d 50 04             	lea    0x4(%eax),%edx
  8006f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fa:	8b 00                	mov    (%eax),%eax
  8006fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ff:	85 c0                	test   %eax,%eax
  800701:	b8 01 20 80 00       	mov    $0x802001,%eax
  800706:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80070a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80070d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800711:	7e 06                	jle    800719 <vprintfmt+0x1cc>
  800713:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800717:	75 13                	jne    80072c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800719:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80071c:	0f be 02             	movsbl (%edx),%eax
  80071f:	85 c0                	test   %eax,%eax
  800721:	0f 85 a2 00 00 00    	jne    8007c9 <vprintfmt+0x27c>
  800727:	e9 8f 00 00 00       	jmp    8007bb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800730:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800733:	89 0c 24             	mov    %ecx,(%esp)
  800736:	e8 70 03 00 00       	call   800aab <strnlen>
  80073b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80073e:	29 c2                	sub    %eax,%edx
  800740:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800743:	85 d2                	test   %edx,%edx
  800745:	7e d2                	jle    800719 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800747:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80074b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80074e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800751:	89 d3                	mov    %edx,%ebx
  800753:	89 74 24 04          	mov    %esi,0x4(%esp)
  800757:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80075a:	89 04 24             	mov    %eax,(%esp)
  80075d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80075f:	83 eb 01             	sub    $0x1,%ebx
  800762:	85 db                	test   %ebx,%ebx
  800764:	7f ed                	jg     800753 <vprintfmt+0x206>
  800766:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800769:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800770:	eb a7                	jmp    800719 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800772:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800776:	74 1b                	je     800793 <vprintfmt+0x246>
  800778:	8d 50 e0             	lea    -0x20(%eax),%edx
  80077b:	83 fa 5e             	cmp    $0x5e,%edx
  80077e:	76 13                	jbe    800793 <vprintfmt+0x246>
					putch('?', putdat);
  800780:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800783:	89 54 24 04          	mov    %edx,0x4(%esp)
  800787:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80078e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800791:	eb 0d                	jmp    8007a0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800793:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800796:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80079a:	89 04 24             	mov    %eax,(%esp)
  80079d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007a0:	83 ef 01             	sub    $0x1,%edi
  8007a3:	0f be 03             	movsbl (%ebx),%eax
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	74 05                	je     8007af <vprintfmt+0x262>
  8007aa:	83 c3 01             	add    $0x1,%ebx
  8007ad:	eb 31                	jmp    8007e0 <vprintfmt+0x293>
  8007af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007b8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007bf:	7f 36                	jg     8007f7 <vprintfmt+0x2aa>
  8007c1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007c4:	e9 b0 fd ff ff       	jmp    800579 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007cc:	83 c2 01             	add    $0x1,%edx
  8007cf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007d5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007d8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007db:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007de:	89 d3                	mov    %edx,%ebx
  8007e0:	85 f6                	test   %esi,%esi
  8007e2:	78 8e                	js     800772 <vprintfmt+0x225>
  8007e4:	83 ee 01             	sub    $0x1,%esi
  8007e7:	79 89                	jns    800772 <vprintfmt+0x225>
  8007e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007f2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8007f5:	eb c4                	jmp    8007bb <vprintfmt+0x26e>
  8007f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8007fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800801:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800808:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80080a:	83 eb 01             	sub    $0x1,%ebx
  80080d:	85 db                	test   %ebx,%ebx
  80080f:	7f ec                	jg     8007fd <vprintfmt+0x2b0>
  800811:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800814:	e9 60 fd ff ff       	jmp    800579 <vprintfmt+0x2c>
  800819:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80081c:	83 f9 01             	cmp    $0x1,%ecx
  80081f:	7e 16                	jle    800837 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8d 50 08             	lea    0x8(%eax),%edx
  800827:	89 55 14             	mov    %edx,0x14(%ebp)
  80082a:	8b 10                	mov    (%eax),%edx
  80082c:	8b 48 04             	mov    0x4(%eax),%ecx
  80082f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800832:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800835:	eb 32                	jmp    800869 <vprintfmt+0x31c>
	else if (lflag)
  800837:	85 c9                	test   %ecx,%ecx
  800839:	74 18                	je     800853 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80083b:	8b 45 14             	mov    0x14(%ebp),%eax
  80083e:	8d 50 04             	lea    0x4(%eax),%edx
  800841:	89 55 14             	mov    %edx,0x14(%ebp)
  800844:	8b 00                	mov    (%eax),%eax
  800846:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800849:	89 c1                	mov    %eax,%ecx
  80084b:	c1 f9 1f             	sar    $0x1f,%ecx
  80084e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800851:	eb 16                	jmp    800869 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8d 50 04             	lea    0x4(%eax),%edx
  800859:	89 55 14             	mov    %edx,0x14(%ebp)
  80085c:	8b 00                	mov    (%eax),%eax
  80085e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800861:	89 c2                	mov    %eax,%edx
  800863:	c1 fa 1f             	sar    $0x1f,%edx
  800866:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800869:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80086c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80086f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800874:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800878:	0f 89 8a 00 00 00    	jns    800908 <vprintfmt+0x3bb>
				putch('-', putdat);
  80087e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800882:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800889:	ff d7                	call   *%edi
				num = -(long long) num;
  80088b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80088e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800891:	f7 d8                	neg    %eax
  800893:	83 d2 00             	adc    $0x0,%edx
  800896:	f7 da                	neg    %edx
  800898:	eb 6e                	jmp    800908 <vprintfmt+0x3bb>
  80089a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80089d:	89 ca                	mov    %ecx,%edx
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
  8008a2:	e8 4f fc ff ff       	call   8004f6 <getuint>
  8008a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8008ac:	eb 5a                	jmp    800908 <vprintfmt+0x3bb>
  8008ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8008b1:	89 ca                	mov    %ecx,%edx
  8008b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008b6:	e8 3b fc ff ff       	call   8004f6 <getuint>
  8008bb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8008c0:	eb 46                	jmp    800908 <vprintfmt+0x3bb>
  8008c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8008c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008d0:	ff d7                	call   *%edi
			putch('x', putdat);
  8008d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008dd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8008df:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e2:	8d 50 04             	lea    0x4(%eax),%edx
  8008e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8008e8:	8b 00                	mov    (%eax),%eax
  8008ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ef:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008f4:	eb 12                	jmp    800908 <vprintfmt+0x3bb>
  8008f6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008f9:	89 ca                	mov    %ecx,%edx
  8008fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8008fe:	e8 f3 fb ff ff       	call   8004f6 <getuint>
  800903:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800908:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80090c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800910:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800913:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800917:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80091b:	89 04 24             	mov    %eax,(%esp)
  80091e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800922:	89 f2                	mov    %esi,%edx
  800924:	89 f8                	mov    %edi,%eax
  800926:	e8 d5 fa ff ff       	call   800400 <printnum>
  80092b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80092e:	e9 46 fc ff ff       	jmp    800579 <vprintfmt+0x2c>
  800933:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800936:	8b 45 14             	mov    0x14(%ebp),%eax
  800939:	8d 50 04             	lea    0x4(%eax),%edx
  80093c:	89 55 14             	mov    %edx,0x14(%ebp)
  80093f:	8b 00                	mov    (%eax),%eax
  800941:	85 c0                	test   %eax,%eax
  800943:	75 24                	jne    800969 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800945:	c7 44 24 0c 1c 21 80 	movl   $0x80211c,0xc(%esp)
  80094c:	00 
  80094d:	c7 44 24 08 3b 24 80 	movl   $0x80243b,0x8(%esp)
  800954:	00 
  800955:	89 74 24 04          	mov    %esi,0x4(%esp)
  800959:	89 3c 24             	mov    %edi,(%esp)
  80095c:	e8 ff 00 00 00       	call   800a60 <printfmt>
  800961:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800964:	e9 10 fc ff ff       	jmp    800579 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800969:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80096c:	7e 29                	jle    800997 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80096e:	0f b6 16             	movzbl (%esi),%edx
  800971:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800973:	c7 44 24 0c 54 21 80 	movl   $0x802154,0xc(%esp)
  80097a:	00 
  80097b:	c7 44 24 08 3b 24 80 	movl   $0x80243b,0x8(%esp)
  800982:	00 
  800983:	89 74 24 04          	mov    %esi,0x4(%esp)
  800987:	89 3c 24             	mov    %edi,(%esp)
  80098a:	e8 d1 00 00 00       	call   800a60 <printfmt>
  80098f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800992:	e9 e2 fb ff ff       	jmp    800579 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800997:	0f b6 16             	movzbl (%esi),%edx
  80099a:	88 10                	mov    %dl,(%eax)
  80099c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80099f:	e9 d5 fb ff ff       	jmp    800579 <vprintfmt+0x2c>
  8009a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ae:	89 14 24             	mov    %edx,(%esp)
  8009b1:	ff d7                	call   *%edi
  8009b3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8009b6:	e9 be fb ff ff       	jmp    800579 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009c6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8009cb:	80 38 25             	cmpb   $0x25,(%eax)
  8009ce:	0f 84 a5 fb ff ff    	je     800579 <vprintfmt+0x2c>
  8009d4:	89 c3                	mov    %eax,%ebx
  8009d6:	eb f0                	jmp    8009c8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8009d8:	83 c4 5c             	add    $0x5c,%esp
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5f                   	pop    %edi
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	83 ec 28             	sub    $0x28,%esp
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8009ec:	85 c0                	test   %eax,%eax
  8009ee:	74 04                	je     8009f4 <vsnprintf+0x14>
  8009f0:	85 d2                	test   %edx,%edx
  8009f2:	7f 07                	jg     8009fb <vsnprintf+0x1b>
  8009f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009f9:	eb 3b                	jmp    800a36 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009fe:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a13:	8b 45 10             	mov    0x10(%ebp),%eax
  800a16:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a21:	c7 04 24 30 05 80 00 	movl   $0x800530,(%esp)
  800a28:	e8 20 fb ff ff       	call   80054d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a30:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a3e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a45:	8b 45 10             	mov    0x10(%ebp),%eax
  800a48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a53:	8b 45 08             	mov    0x8(%ebp),%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 82 ff ff ff       	call   8009e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a5e:	c9                   	leave  
  800a5f:	c3                   	ret    

00800a60 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a66:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a6d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	89 04 24             	mov    %eax,(%esp)
  800a81:	e8 c7 fa ff ff       	call   80054d <vprintfmt>
	va_end(ap);
}
  800a86:	c9                   	leave  
  800a87:	c3                   	ret    
	...

00800a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a96:	b8 00 00 00 00       	mov    $0x0,%eax
  800a9b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a9e:	74 09                	je     800aa9 <strlen+0x19>
		n++;
  800aa0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800aa3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800aa7:	75 f7                	jne    800aa0 <strlen+0x10>
		n++;
	return n;
}
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	53                   	push   %ebx
  800aaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ab5:	85 c9                	test   %ecx,%ecx
  800ab7:	74 19                	je     800ad2 <strnlen+0x27>
  800ab9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800abc:	74 14                	je     800ad2 <strnlen+0x27>
  800abe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ac3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ac6:	39 c8                	cmp    %ecx,%eax
  800ac8:	74 0d                	je     800ad7 <strnlen+0x2c>
  800aca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800ace:	75 f3                	jne    800ac3 <strnlen+0x18>
  800ad0:	eb 05                	jmp    800ad7 <strnlen+0x2c>
  800ad2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ae9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800aed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800af0:	83 c2 01             	add    $0x1,%edx
  800af3:	84 c9                	test   %cl,%cl
  800af5:	75 f2                	jne    800ae9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800af7:	5b                   	pop    %ebx
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strcat>:

char *
strcat(char *dst, const char *src)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	83 ec 08             	sub    $0x8,%esp
  800b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b04:	89 1c 24             	mov    %ebx,(%esp)
  800b07:	e8 84 ff ff ff       	call   800a90 <strlen>
	strcpy(dst + len, src);
  800b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b13:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b16:	89 04 24             	mov    %eax,(%esp)
  800b19:	e8 bc ff ff ff       	call   800ada <strcpy>
	return dst;
}
  800b1e:	89 d8                	mov    %ebx,%eax
  800b20:	83 c4 08             	add    $0x8,%esp
  800b23:	5b                   	pop    %ebx
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b34:	85 f6                	test   %esi,%esi
  800b36:	74 18                	je     800b50 <strncpy+0x2a>
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b3d:	0f b6 1a             	movzbl (%edx),%ebx
  800b40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b43:	80 3a 01             	cmpb   $0x1,(%edx)
  800b46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b49:	83 c1 01             	add    $0x1,%ecx
  800b4c:	39 ce                	cmp    %ecx,%esi
  800b4e:	77 ed                	ja     800b3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b62:	89 f0                	mov    %esi,%eax
  800b64:	85 c9                	test   %ecx,%ecx
  800b66:	74 27                	je     800b8f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b68:	83 e9 01             	sub    $0x1,%ecx
  800b6b:	74 1d                	je     800b8a <strlcpy+0x36>
  800b6d:	0f b6 1a             	movzbl (%edx),%ebx
  800b70:	84 db                	test   %bl,%bl
  800b72:	74 16                	je     800b8a <strlcpy+0x36>
			*dst++ = *src++;
  800b74:	88 18                	mov    %bl,(%eax)
  800b76:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b79:	83 e9 01             	sub    $0x1,%ecx
  800b7c:	74 0e                	je     800b8c <strlcpy+0x38>
			*dst++ = *src++;
  800b7e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b81:	0f b6 1a             	movzbl (%edx),%ebx
  800b84:	84 db                	test   %bl,%bl
  800b86:	75 ec                	jne    800b74 <strlcpy+0x20>
  800b88:	eb 02                	jmp    800b8c <strlcpy+0x38>
  800b8a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b8c:	c6 00 00             	movb   $0x0,(%eax)
  800b8f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b9e:	0f b6 01             	movzbl (%ecx),%eax
  800ba1:	84 c0                	test   %al,%al
  800ba3:	74 15                	je     800bba <strcmp+0x25>
  800ba5:	3a 02                	cmp    (%edx),%al
  800ba7:	75 11                	jne    800bba <strcmp+0x25>
		p++, q++;
  800ba9:	83 c1 01             	add    $0x1,%ecx
  800bac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800baf:	0f b6 01             	movzbl (%ecx),%eax
  800bb2:	84 c0                	test   %al,%al
  800bb4:	74 04                	je     800bba <strcmp+0x25>
  800bb6:	3a 02                	cmp    (%edx),%al
  800bb8:	74 ef                	je     800ba9 <strcmp+0x14>
  800bba:	0f b6 c0             	movzbl %al,%eax
  800bbd:	0f b6 12             	movzbl (%edx),%edx
  800bc0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	74 23                	je     800bf8 <strncmp+0x34>
  800bd5:	0f b6 1a             	movzbl (%edx),%ebx
  800bd8:	84 db                	test   %bl,%bl
  800bda:	74 25                	je     800c01 <strncmp+0x3d>
  800bdc:	3a 19                	cmp    (%ecx),%bl
  800bde:	75 21                	jne    800c01 <strncmp+0x3d>
  800be0:	83 e8 01             	sub    $0x1,%eax
  800be3:	74 13                	je     800bf8 <strncmp+0x34>
		n--, p++, q++;
  800be5:	83 c2 01             	add    $0x1,%edx
  800be8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800beb:	0f b6 1a             	movzbl (%edx),%ebx
  800bee:	84 db                	test   %bl,%bl
  800bf0:	74 0f                	je     800c01 <strncmp+0x3d>
  800bf2:	3a 19                	cmp    (%ecx),%bl
  800bf4:	74 ea                	je     800be0 <strncmp+0x1c>
  800bf6:	eb 09                	jmp    800c01 <strncmp+0x3d>
  800bf8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800bfd:	5b                   	pop    %ebx
  800bfe:	5d                   	pop    %ebp
  800bff:	90                   	nop
  800c00:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c01:	0f b6 02             	movzbl (%edx),%eax
  800c04:	0f b6 11             	movzbl (%ecx),%edx
  800c07:	29 d0                	sub    %edx,%eax
  800c09:	eb f2                	jmp    800bfd <strncmp+0x39>

00800c0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c15:	0f b6 10             	movzbl (%eax),%edx
  800c18:	84 d2                	test   %dl,%dl
  800c1a:	74 18                	je     800c34 <strchr+0x29>
		if (*s == c)
  800c1c:	38 ca                	cmp    %cl,%dl
  800c1e:	75 0a                	jne    800c2a <strchr+0x1f>
  800c20:	eb 17                	jmp    800c39 <strchr+0x2e>
  800c22:	38 ca                	cmp    %cl,%dl
  800c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c28:	74 0f                	je     800c39 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c2a:	83 c0 01             	add    $0x1,%eax
  800c2d:	0f b6 10             	movzbl (%eax),%edx
  800c30:	84 d2                	test   %dl,%dl
  800c32:	75 ee                	jne    800c22 <strchr+0x17>
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c45:	0f b6 10             	movzbl (%eax),%edx
  800c48:	84 d2                	test   %dl,%dl
  800c4a:	74 18                	je     800c64 <strfind+0x29>
		if (*s == c)
  800c4c:	38 ca                	cmp    %cl,%dl
  800c4e:	75 0a                	jne    800c5a <strfind+0x1f>
  800c50:	eb 12                	jmp    800c64 <strfind+0x29>
  800c52:	38 ca                	cmp    %cl,%dl
  800c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c58:	74 0a                	je     800c64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c5a:	83 c0 01             	add    $0x1,%eax
  800c5d:	0f b6 10             	movzbl (%eax),%edx
  800c60:	84 d2                	test   %dl,%dl
  800c62:	75 ee                	jne    800c52 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	83 ec 0c             	sub    $0xc,%esp
  800c6c:	89 1c 24             	mov    %ebx,(%esp)
  800c6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c80:	85 c9                	test   %ecx,%ecx
  800c82:	74 30                	je     800cb4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c8a:	75 25                	jne    800cb1 <memset+0x4b>
  800c8c:	f6 c1 03             	test   $0x3,%cl
  800c8f:	75 20                	jne    800cb1 <memset+0x4b>
		c &= 0xFF;
  800c91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c94:	89 d3                	mov    %edx,%ebx
  800c96:	c1 e3 08             	shl    $0x8,%ebx
  800c99:	89 d6                	mov    %edx,%esi
  800c9b:	c1 e6 18             	shl    $0x18,%esi
  800c9e:	89 d0                	mov    %edx,%eax
  800ca0:	c1 e0 10             	shl    $0x10,%eax
  800ca3:	09 f0                	or     %esi,%eax
  800ca5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ca7:	09 d8                	or     %ebx,%eax
  800ca9:	c1 e9 02             	shr    $0x2,%ecx
  800cac:	fc                   	cld    
  800cad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800caf:	eb 03                	jmp    800cb4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cb1:	fc                   	cld    
  800cb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cb4:	89 f8                	mov    %edi,%eax
  800cb6:	8b 1c 24             	mov    (%esp),%ebx
  800cb9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cbd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cc1:	89 ec                	mov    %ebp,%esp
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	83 ec 08             	sub    $0x8,%esp
  800ccb:	89 34 24             	mov    %esi,(%esp)
  800cce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cd8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cdb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cdd:	39 c6                	cmp    %eax,%esi
  800cdf:	73 35                	jae    800d16 <memmove+0x51>
  800ce1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ce4:	39 d0                	cmp    %edx,%eax
  800ce6:	73 2e                	jae    800d16 <memmove+0x51>
		s += n;
		d += n;
  800ce8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cea:	f6 c2 03             	test   $0x3,%dl
  800ced:	75 1b                	jne    800d0a <memmove+0x45>
  800cef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800cf5:	75 13                	jne    800d0a <memmove+0x45>
  800cf7:	f6 c1 03             	test   $0x3,%cl
  800cfa:	75 0e                	jne    800d0a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800cfc:	83 ef 04             	sub    $0x4,%edi
  800cff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d02:	c1 e9 02             	shr    $0x2,%ecx
  800d05:	fd                   	std    
  800d06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d08:	eb 09                	jmp    800d13 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d0a:	83 ef 01             	sub    $0x1,%edi
  800d0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d10:	fd                   	std    
  800d11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d13:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d14:	eb 20                	jmp    800d36 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d1c:	75 15                	jne    800d33 <memmove+0x6e>
  800d1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d24:	75 0d                	jne    800d33 <memmove+0x6e>
  800d26:	f6 c1 03             	test   $0x3,%cl
  800d29:	75 08                	jne    800d33 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d2b:	c1 e9 02             	shr    $0x2,%ecx
  800d2e:	fc                   	cld    
  800d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d31:	eb 03                	jmp    800d36 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d33:	fc                   	cld    
  800d34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d36:	8b 34 24             	mov    (%esp),%esi
  800d39:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d3d:	89 ec                	mov    %ebp,%esp
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d47:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d55:	8b 45 08             	mov    0x8(%ebp),%eax
  800d58:	89 04 24             	mov    %eax,(%esp)
  800d5b:	e8 65 ff ff ff       	call   800cc5 <memmove>
}
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	57                   	push   %edi
  800d66:	56                   	push   %esi
  800d67:	53                   	push   %ebx
  800d68:	8b 75 08             	mov    0x8(%ebp),%esi
  800d6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d71:	85 c9                	test   %ecx,%ecx
  800d73:	74 36                	je     800dab <memcmp+0x49>
		if (*s1 != *s2)
  800d75:	0f b6 06             	movzbl (%esi),%eax
  800d78:	0f b6 1f             	movzbl (%edi),%ebx
  800d7b:	38 d8                	cmp    %bl,%al
  800d7d:	74 20                	je     800d9f <memcmp+0x3d>
  800d7f:	eb 14                	jmp    800d95 <memcmp+0x33>
  800d81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d8b:	83 c2 01             	add    $0x1,%edx
  800d8e:	83 e9 01             	sub    $0x1,%ecx
  800d91:	38 d8                	cmp    %bl,%al
  800d93:	74 12                	je     800da7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d95:	0f b6 c0             	movzbl %al,%eax
  800d98:	0f b6 db             	movzbl %bl,%ebx
  800d9b:	29 d8                	sub    %ebx,%eax
  800d9d:	eb 11                	jmp    800db0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d9f:	83 e9 01             	sub    $0x1,%ecx
  800da2:	ba 00 00 00 00       	mov    $0x0,%edx
  800da7:	85 c9                	test   %ecx,%ecx
  800da9:	75 d6                	jne    800d81 <memcmp+0x1f>
  800dab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800db0:	5b                   	pop    %ebx
  800db1:	5e                   	pop    %esi
  800db2:	5f                   	pop    %edi
  800db3:	5d                   	pop    %ebp
  800db4:	c3                   	ret    

00800db5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800dbb:	89 c2                	mov    %eax,%edx
  800dbd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800dc0:	39 d0                	cmp    %edx,%eax
  800dc2:	73 15                	jae    800dd9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dc4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800dc8:	38 08                	cmp    %cl,(%eax)
  800dca:	75 06                	jne    800dd2 <memfind+0x1d>
  800dcc:	eb 0b                	jmp    800dd9 <memfind+0x24>
  800dce:	38 08                	cmp    %cl,(%eax)
  800dd0:	74 07                	je     800dd9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800dd2:	83 c0 01             	add    $0x1,%eax
  800dd5:	39 c2                	cmp    %eax,%edx
  800dd7:	77 f5                	ja     800dce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	57                   	push   %edi
  800ddf:	56                   	push   %esi
  800de0:	53                   	push   %ebx
  800de1:	83 ec 04             	sub    $0x4,%esp
  800de4:	8b 55 08             	mov    0x8(%ebp),%edx
  800de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800dea:	0f b6 02             	movzbl (%edx),%eax
  800ded:	3c 20                	cmp    $0x20,%al
  800def:	74 04                	je     800df5 <strtol+0x1a>
  800df1:	3c 09                	cmp    $0x9,%al
  800df3:	75 0e                	jne    800e03 <strtol+0x28>
		s++;
  800df5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800df8:	0f b6 02             	movzbl (%edx),%eax
  800dfb:	3c 20                	cmp    $0x20,%al
  800dfd:	74 f6                	je     800df5 <strtol+0x1a>
  800dff:	3c 09                	cmp    $0x9,%al
  800e01:	74 f2                	je     800df5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e03:	3c 2b                	cmp    $0x2b,%al
  800e05:	75 0c                	jne    800e13 <strtol+0x38>
		s++;
  800e07:	83 c2 01             	add    $0x1,%edx
  800e0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e11:	eb 15                	jmp    800e28 <strtol+0x4d>
	else if (*s == '-')
  800e13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e1a:	3c 2d                	cmp    $0x2d,%al
  800e1c:	75 0a                	jne    800e28 <strtol+0x4d>
		s++, neg = 1;
  800e1e:	83 c2 01             	add    $0x1,%edx
  800e21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e28:	85 db                	test   %ebx,%ebx
  800e2a:	0f 94 c0             	sete   %al
  800e2d:	74 05                	je     800e34 <strtol+0x59>
  800e2f:	83 fb 10             	cmp    $0x10,%ebx
  800e32:	75 18                	jne    800e4c <strtol+0x71>
  800e34:	80 3a 30             	cmpb   $0x30,(%edx)
  800e37:	75 13                	jne    800e4c <strtol+0x71>
  800e39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e3d:	8d 76 00             	lea    0x0(%esi),%esi
  800e40:	75 0a                	jne    800e4c <strtol+0x71>
		s += 2, base = 16;
  800e42:	83 c2 02             	add    $0x2,%edx
  800e45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e4a:	eb 15                	jmp    800e61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e4c:	84 c0                	test   %al,%al
  800e4e:	66 90                	xchg   %ax,%ax
  800e50:	74 0f                	je     800e61 <strtol+0x86>
  800e52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e57:	80 3a 30             	cmpb   $0x30,(%edx)
  800e5a:	75 05                	jne    800e61 <strtol+0x86>
		s++, base = 8;
  800e5c:	83 c2 01             	add    $0x1,%edx
  800e5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e61:	b8 00 00 00 00       	mov    $0x0,%eax
  800e66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e68:	0f b6 0a             	movzbl (%edx),%ecx
  800e6b:	89 cf                	mov    %ecx,%edi
  800e6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e70:	80 fb 09             	cmp    $0x9,%bl
  800e73:	77 08                	ja     800e7d <strtol+0xa2>
			dig = *s - '0';
  800e75:	0f be c9             	movsbl %cl,%ecx
  800e78:	83 e9 30             	sub    $0x30,%ecx
  800e7b:	eb 1e                	jmp    800e9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e80:	80 fb 19             	cmp    $0x19,%bl
  800e83:	77 08                	ja     800e8d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e85:	0f be c9             	movsbl %cl,%ecx
  800e88:	83 e9 57             	sub    $0x57,%ecx
  800e8b:	eb 0e                	jmp    800e9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e90:	80 fb 19             	cmp    $0x19,%bl
  800e93:	77 15                	ja     800eaa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e95:	0f be c9             	movsbl %cl,%ecx
  800e98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e9b:	39 f1                	cmp    %esi,%ecx
  800e9d:	7d 0b                	jge    800eaa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e9f:	83 c2 01             	add    $0x1,%edx
  800ea2:	0f af c6             	imul   %esi,%eax
  800ea5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ea8:	eb be                	jmp    800e68 <strtol+0x8d>
  800eaa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800eac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800eb0:	74 05                	je     800eb7 <strtol+0xdc>
		*endptr = (char *) s;
  800eb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800eb5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800eb7:	89 ca                	mov    %ecx,%edx
  800eb9:	f7 da                	neg    %edx
  800ebb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ebf:	0f 45 c2             	cmovne %edx,%eax
}
  800ec2:	83 c4 04             	add    $0x4,%esp
  800ec5:	5b                   	pop    %ebx
  800ec6:	5e                   	pop    %esi
  800ec7:	5f                   	pop    %edi
  800ec8:	5d                   	pop    %ebp
  800ec9:	c3                   	ret    
	...

00800ecc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 48             	sub    $0x48,%esp
  800ed2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ed5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ed8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800edb:	89 c6                	mov    %eax,%esi
  800edd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ee0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ee2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ee5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eeb:	51                   	push   %ecx
  800eec:	52                   	push   %edx
  800eed:	53                   	push   %ebx
  800eee:	54                   	push   %esp
  800eef:	55                   	push   %ebp
  800ef0:	56                   	push   %esi
  800ef1:	57                   	push   %edi
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	8d 35 fc 0e 80 00    	lea    0x800efc,%esi
  800efa:	0f 34                	sysenter 

00800efc <.after_sysenter_label>:
  800efc:	5f                   	pop    %edi
  800efd:	5e                   	pop    %esi
  800efe:	5d                   	pop    %ebp
  800eff:	5c                   	pop    %esp
  800f00:	5b                   	pop    %ebx
  800f01:	5a                   	pop    %edx
  800f02:	59                   	pop    %ecx
  800f03:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f05:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f09:	74 28                	je     800f33 <.after_sysenter_label+0x37>
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	7e 24                	jle    800f33 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f13:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f17:	c7 44 24 08 60 23 80 	movl   $0x802360,0x8(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800f26:	00 
  800f27:	c7 04 24 7d 23 80 00 	movl   $0x80237d,(%esp)
  800f2e:	e8 ad f3 ff ff       	call   8002e0 <_panic>

	return ret;
}
  800f33:	89 d0                	mov    %edx,%eax
  800f35:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f38:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f3b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f3e:	89 ec                	mov    %ebp,%esp
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    

00800f42 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4f:	00 
  800f50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f57:	00 
  800f58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5f:	00 
  800f60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800f6f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f74:	e8 53 ff ff ff       	call   800ecc <syscall>
}
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f88:	00 
  800f89:	8b 45 14             	mov    0x14(%ebp),%eax
  800f8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f90:	8b 45 10             	mov    0x10(%ebp),%eax
  800f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9a:	89 04 24             	mov    %eax,(%esp)
  800f9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800faa:	e8 1d ff ff ff       	call   800ecc <syscall>
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800fb7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fbe:	00 
  800fbf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc6:	00 
  800fc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fce:	00 
  800fcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd2:	89 04 24             	mov    %eax,(%esp)
  800fd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800fdd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fe2:	e8 e5 fe ff ff       	call   800ecc <syscall>
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800fef:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff6:	00 
  800ff7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801006:	00 
  801007:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100a:	89 04 24             	mov    %eax,(%esp)
  80100d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801010:	ba 01 00 00 00       	mov    $0x1,%edx
  801015:	b8 0a 00 00 00       	mov    $0xa,%eax
  80101a:	e8 ad fe ff ff       	call   800ecc <syscall>
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801027:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80102e:	00 
  80102f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801036:	00 
  801037:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103e:	00 
  80103f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801042:	89 04 24             	mov    %eax,(%esp)
  801045:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801048:	ba 01 00 00 00       	mov    $0x1,%edx
  80104d:	b8 09 00 00 00       	mov    $0x9,%eax
  801052:	e8 75 fe ff ff       	call   800ecc <syscall>
}
  801057:	c9                   	leave  
  801058:	c3                   	ret    

00801059 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80105f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801066:	00 
  801067:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106e:	00 
  80106f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801076:	00 
  801077:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107a:	89 04 24             	mov    %eax,(%esp)
  80107d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801080:	ba 01 00 00 00       	mov    $0x1,%edx
  801085:	b8 07 00 00 00       	mov    $0x7,%eax
  80108a:	e8 3d fe ff ff       	call   800ecc <syscall>
}
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  801097:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80109e:	00 
  80109f:	8b 45 18             	mov    0x18(%ebp),%eax
  8010a2:	0b 45 14             	or     0x14(%ebp),%eax
  8010a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010a9:	8b 45 10             	mov    0x10(%ebp),%eax
  8010ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b3:	89 04 24             	mov    %eax,(%esp)
  8010b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b9:	ba 01 00 00 00       	mov    $0x1,%edx
  8010be:	b8 06 00 00 00       	mov    $0x6,%eax
  8010c3:	e8 04 fe ff ff       	call   800ecc <syscall>
}
  8010c8:	c9                   	leave  
  8010c9:	c3                   	ret    

008010ca <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8010d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010df:	00 
  8010e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ea:	89 04 24             	mov    %eax,(%esp)
  8010ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f0:	ba 01 00 00 00       	mov    $0x1,%edx
  8010f5:	b8 05 00 00 00       	mov    $0x5,%eax
  8010fa:	e8 cd fd ff ff       	call   800ecc <syscall>
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801107:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80110e:	00 
  80110f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801116:	00 
  801117:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80111e:	00 
  80111f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801126:	b9 00 00 00 00       	mov    $0x0,%ecx
  80112b:	ba 00 00 00 00       	mov    $0x0,%edx
  801130:	b8 0c 00 00 00       	mov    $0xc,%eax
  801135:	e8 92 fd ff ff       	call   800ecc <syscall>
}
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    

0080113c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801142:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801149:	00 
  80114a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801151:	00 
  801152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801159:	00 
  80115a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801163:	ba 00 00 00 00       	mov    $0x0,%edx
  801168:	b8 04 00 00 00       	mov    $0x4,%eax
  80116d:	e8 5a fd ff ff       	call   800ecc <syscall>
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80117a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801181:	00 
  801182:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801189:	00 
  80118a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801191:	00 
  801192:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801199:	b9 00 00 00 00       	mov    $0x0,%ecx
  80119e:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8011a8:	e8 1f fd ff ff       	call   800ecc <syscall>
}
  8011ad:	c9                   	leave  
  8011ae:	c3                   	ret    

008011af <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8011b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c4:	00 
  8011c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011cc:	00 
  8011cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d7:	ba 01 00 00 00       	mov    $0x1,%edx
  8011dc:	b8 03 00 00 00       	mov    $0x3,%eax
  8011e1:	e8 e6 fc ff ff       	call   800ecc <syscall>
}
  8011e6:	c9                   	leave  
  8011e7:	c3                   	ret    

008011e8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8011ee:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011f5:	00 
  8011f6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011fd:	00 
  8011fe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801205:	00 
  801206:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80120d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	b8 01 00 00 00       	mov    $0x1,%eax
  80121c:	e8 ab fc ff ff       	call   800ecc <syscall>
}
  801221:	c9                   	leave  
  801222:	c3                   	ret    

00801223 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801229:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801230:	00 
  801231:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801238:	00 
  801239:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801240:	00 
  801241:	8b 45 0c             	mov    0xc(%ebp),%eax
  801244:	89 04 24             	mov    %eax,(%esp)
  801247:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124a:	ba 00 00 00 00       	mov    $0x0,%edx
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
  801254:	e8 73 fc ff ff       	call   800ecc <syscall>
}
  801259:	c9                   	leave  
  80125a:	c3                   	ret    
  80125b:	00 00                	add    %al,(%eax)
  80125d:	00 00                	add    %al,(%eax)
	...

00801260 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 45 08             	mov    0x8(%ebp),%eax
  801266:	05 00 00 00 30       	add    $0x30000000,%eax
  80126b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    

00801270 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801276:	8b 45 08             	mov    0x8(%ebp),%eax
  801279:	89 04 24             	mov    %eax,(%esp)
  80127c:	e8 df ff ff ff       	call   801260 <fd2num>
  801281:	05 20 00 0d 00       	add    $0xd0020,%eax
  801286:	c1 e0 0c             	shl    $0xc,%eax
}
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	57                   	push   %edi
  80128f:	56                   	push   %esi
  801290:	53                   	push   %ebx
  801291:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801294:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801299:	a8 01                	test   $0x1,%al
  80129b:	74 36                	je     8012d3 <fd_alloc+0x48>
  80129d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8012a2:	a8 01                	test   $0x1,%al
  8012a4:	74 2d                	je     8012d3 <fd_alloc+0x48>
  8012a6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8012ab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8012b0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8012b5:	89 c3                	mov    %eax,%ebx
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	c1 ea 16             	shr    $0x16,%edx
  8012bc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8012bf:	f6 c2 01             	test   $0x1,%dl
  8012c2:	74 14                	je     8012d8 <fd_alloc+0x4d>
  8012c4:	89 c2                	mov    %eax,%edx
  8012c6:	c1 ea 0c             	shr    $0xc,%edx
  8012c9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8012cc:	f6 c2 01             	test   $0x1,%dl
  8012cf:	75 10                	jne    8012e1 <fd_alloc+0x56>
  8012d1:	eb 05                	jmp    8012d8 <fd_alloc+0x4d>
  8012d3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8012d8:	89 1f                	mov    %ebx,(%edi)
  8012da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8012df:	eb 17                	jmp    8012f8 <fd_alloc+0x6d>
  8012e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012eb:	75 c8                	jne    8012b5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8012f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5f                   	pop    %edi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
  801303:	83 f8 1f             	cmp    $0x1f,%eax
  801306:	77 36                	ja     80133e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801308:	05 00 00 0d 00       	add    $0xd0000,%eax
  80130d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801310:	89 c2                	mov    %eax,%edx
  801312:	c1 ea 16             	shr    $0x16,%edx
  801315:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80131c:	f6 c2 01             	test   $0x1,%dl
  80131f:	74 1d                	je     80133e <fd_lookup+0x41>
  801321:	89 c2                	mov    %eax,%edx
  801323:	c1 ea 0c             	shr    $0xc,%edx
  801326:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132d:	f6 c2 01             	test   $0x1,%dl
  801330:	74 0c                	je     80133e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801332:	8b 55 0c             	mov    0xc(%ebp),%edx
  801335:	89 02                	mov    %eax,(%edx)
  801337:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80133c:	eb 05                	jmp    801343 <fd_lookup+0x46>
  80133e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80134e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 a0 ff ff ff       	call   8012fd <fd_lookup>
  80135d:	85 c0                	test   %eax,%eax
  80135f:	78 0e                	js     80136f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801361:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801364:	8b 55 0c             	mov    0xc(%ebp),%edx
  801367:	89 50 04             	mov    %edx,0x4(%eax)
  80136a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80136f:	c9                   	leave  
  801370:	c3                   	ret    

00801371 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	56                   	push   %esi
  801375:	53                   	push   %ebx
  801376:	83 ec 10             	sub    $0x10,%esp
  801379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80137f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801384:	b8 04 30 80 00       	mov    $0x803004,%eax
  801389:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80138f:	75 11                	jne    8013a2 <dev_lookup+0x31>
  801391:	eb 04                	jmp    801397 <dev_lookup+0x26>
  801393:	39 08                	cmp    %ecx,(%eax)
  801395:	75 10                	jne    8013a7 <dev_lookup+0x36>
			*dev = devtab[i];
  801397:	89 03                	mov    %eax,(%ebx)
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80139e:	66 90                	xchg   %ax,%ax
  8013a0:	eb 36                	jmp    8013d8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013a2:	be 0c 24 80 00       	mov    $0x80240c,%esi
  8013a7:	83 c2 01             	add    $0x1,%edx
  8013aa:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8013ad:	85 c0                	test   %eax,%eax
  8013af:	75 e2                	jne    801393 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013b1:	a1 04 40 80 00       	mov    0x804004,%eax
  8013b6:	8b 40 48             	mov    0x48(%eax),%eax
  8013b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c1:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  8013c8:	e8 cc ef ff ff       	call   800399 <cprintf>
	*dev = 0;
  8013cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	5b                   	pop    %ebx
  8013dc:	5e                   	pop    %esi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    

008013df <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8013df:	55                   	push   %ebp
  8013e0:	89 e5                	mov    %esp,%ebp
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 24             	sub    $0x24,%esp
  8013e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f3:	89 04 24             	mov    %eax,(%esp)
  8013f6:	e8 02 ff ff ff       	call   8012fd <fd_lookup>
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 53                	js     801452 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801402:	89 44 24 04          	mov    %eax,0x4(%esp)
  801406:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801409:	8b 00                	mov    (%eax),%eax
  80140b:	89 04 24             	mov    %eax,(%esp)
  80140e:	e8 5e ff ff ff       	call   801371 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801413:	85 c0                	test   %eax,%eax
  801415:	78 3b                	js     801452 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801417:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80141c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80141f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801423:	74 2d                	je     801452 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801425:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801428:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80142f:	00 00 00 
	stat->st_isdir = 0;
  801432:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801439:	00 00 00 
	stat->st_dev = dev;
  80143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801445:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801449:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80144c:	89 14 24             	mov    %edx,(%esp)
  80144f:	ff 50 14             	call   *0x14(%eax)
}
  801452:	83 c4 24             	add    $0x24,%esp
  801455:	5b                   	pop    %ebx
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	53                   	push   %ebx
  80145c:	83 ec 24             	sub    $0x24,%esp
  80145f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801462:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801465:	89 44 24 04          	mov    %eax,0x4(%esp)
  801469:	89 1c 24             	mov    %ebx,(%esp)
  80146c:	e8 8c fe ff ff       	call   8012fd <fd_lookup>
  801471:	85 c0                	test   %eax,%eax
  801473:	78 5f                	js     8014d4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801475:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801478:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80147f:	8b 00                	mov    (%eax),%eax
  801481:	89 04 24             	mov    %eax,(%esp)
  801484:	e8 e8 fe ff ff       	call   801371 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 47                	js     8014d4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80148d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801490:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801494:	75 23                	jne    8014b9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801496:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80149b:	8b 40 48             	mov    0x48(%eax),%eax
  80149e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a6:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  8014ad:	e8 e7 ee ff ff       	call   800399 <cprintf>
  8014b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b7:	eb 1b                	jmp    8014d4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8014b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bc:	8b 48 18             	mov    0x18(%eax),%ecx
  8014bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c4:	85 c9                	test   %ecx,%ecx
  8014c6:	74 0c                	je     8014d4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cf:	89 14 24             	mov    %edx,(%esp)
  8014d2:	ff d1                	call   *%ecx
}
  8014d4:	83 c4 24             	add    $0x24,%esp
  8014d7:	5b                   	pop    %ebx
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	53                   	push   %ebx
  8014de:	83 ec 24             	sub    $0x24,%esp
  8014e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014eb:	89 1c 24             	mov    %ebx,(%esp)
  8014ee:	e8 0a fe ff ff       	call   8012fd <fd_lookup>
  8014f3:	85 c0                	test   %eax,%eax
  8014f5:	78 66                	js     80155d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801501:	8b 00                	mov    (%eax),%eax
  801503:	89 04 24             	mov    %eax,(%esp)
  801506:	e8 66 fe ff ff       	call   801371 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 4e                	js     80155d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801512:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801516:	75 23                	jne    80153b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801518:	a1 04 40 80 00       	mov    0x804004,%eax
  80151d:	8b 40 48             	mov    0x48(%eax),%eax
  801520:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801524:	89 44 24 04          	mov    %eax,0x4(%esp)
  801528:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  80152f:	e8 65 ee ff ff       	call   800399 <cprintf>
  801534:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801539:	eb 22                	jmp    80155d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80153b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801541:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801546:	85 c9                	test   %ecx,%ecx
  801548:	74 13                	je     80155d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80154a:	8b 45 10             	mov    0x10(%ebp),%eax
  80154d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801551:	8b 45 0c             	mov    0xc(%ebp),%eax
  801554:	89 44 24 04          	mov    %eax,0x4(%esp)
  801558:	89 14 24             	mov    %edx,(%esp)
  80155b:	ff d1                	call   *%ecx
}
  80155d:	83 c4 24             	add    $0x24,%esp
  801560:	5b                   	pop    %ebx
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    

00801563 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	53                   	push   %ebx
  801567:	83 ec 24             	sub    $0x24,%esp
  80156a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80156d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801570:	89 44 24 04          	mov    %eax,0x4(%esp)
  801574:	89 1c 24             	mov    %ebx,(%esp)
  801577:	e8 81 fd ff ff       	call   8012fd <fd_lookup>
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 6b                	js     8015eb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	89 44 24 04          	mov    %eax,0x4(%esp)
  801587:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158a:	8b 00                	mov    (%eax),%eax
  80158c:	89 04 24             	mov    %eax,(%esp)
  80158f:	e8 dd fd ff ff       	call   801371 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801594:	85 c0                	test   %eax,%eax
  801596:	78 53                	js     8015eb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801598:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80159b:	8b 42 08             	mov    0x8(%edx),%eax
  80159e:	83 e0 03             	and    $0x3,%eax
  8015a1:	83 f8 01             	cmp    $0x1,%eax
  8015a4:	75 23                	jne    8015c9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ab:	8b 40 48             	mov    0x48(%eax),%eax
  8015ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b6:	c7 04 24 ed 23 80 00 	movl   $0x8023ed,(%esp)
  8015bd:	e8 d7 ed ff ff       	call   800399 <cprintf>
  8015c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8015c7:	eb 22                	jmp    8015eb <read+0x88>
	}
	if (!dev->dev_read)
  8015c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015cc:	8b 48 08             	mov    0x8(%eax),%ecx
  8015cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d4:	85 c9                	test   %ecx,%ecx
  8015d6:	74 13                	je     8015eb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8015db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e6:	89 14 24             	mov    %edx,(%esp)
  8015e9:	ff d1                	call   *%ecx
}
  8015eb:	83 c4 24             	add    $0x24,%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    

008015f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	57                   	push   %edi
  8015f5:	56                   	push   %esi
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 1c             	sub    $0x1c,%esp
  8015fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801600:	ba 00 00 00 00       	mov    $0x0,%edx
  801605:	bb 00 00 00 00       	mov    $0x0,%ebx
  80160a:	b8 00 00 00 00       	mov    $0x0,%eax
  80160f:	85 f6                	test   %esi,%esi
  801611:	74 29                	je     80163c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801613:	89 f0                	mov    %esi,%eax
  801615:	29 d0                	sub    %edx,%eax
  801617:	89 44 24 08          	mov    %eax,0x8(%esp)
  80161b:	03 55 0c             	add    0xc(%ebp),%edx
  80161e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801622:	89 3c 24             	mov    %edi,(%esp)
  801625:	e8 39 ff ff ff       	call   801563 <read>
		if (m < 0)
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 0e                	js     80163c <readn+0x4b>
			return m;
		if (m == 0)
  80162e:	85 c0                	test   %eax,%eax
  801630:	74 08                	je     80163a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801632:	01 c3                	add    %eax,%ebx
  801634:	89 da                	mov    %ebx,%edx
  801636:	39 f3                	cmp    %esi,%ebx
  801638:	72 d9                	jb     801613 <readn+0x22>
  80163a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80163c:	83 c4 1c             	add    $0x1c,%esp
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5f                   	pop    %edi
  801642:	5d                   	pop    %ebp
  801643:	c3                   	ret    

00801644 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 28             	sub    $0x28,%esp
  80164a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80164d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801650:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801653:	89 34 24             	mov    %esi,(%esp)
  801656:	e8 05 fc ff ff       	call   801260 <fd2num>
  80165b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80165e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801662:	89 04 24             	mov    %eax,(%esp)
  801665:	e8 93 fc ff ff       	call   8012fd <fd_lookup>
  80166a:	89 c3                	mov    %eax,%ebx
  80166c:	85 c0                	test   %eax,%eax
  80166e:	78 05                	js     801675 <fd_close+0x31>
  801670:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801673:	74 0e                	je     801683 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801675:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
  80167e:	0f 44 d8             	cmove  %eax,%ebx
  801681:	eb 3d                	jmp    8016c0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801683:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801686:	89 44 24 04          	mov    %eax,0x4(%esp)
  80168a:	8b 06                	mov    (%esi),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 dd fc ff ff       	call   801371 <dev_lookup>
  801694:	89 c3                	mov    %eax,%ebx
  801696:	85 c0                	test   %eax,%eax
  801698:	78 16                	js     8016b0 <fd_close+0x6c>
		if (dev->dev_close)
  80169a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169d:	8b 40 10             	mov    0x10(%eax),%eax
  8016a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016a5:	85 c0                	test   %eax,%eax
  8016a7:	74 07                	je     8016b0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8016a9:	89 34 24             	mov    %esi,(%esp)
  8016ac:	ff d0                	call   *%eax
  8016ae:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8016b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016bb:	e8 99 f9 ff ff       	call   801059 <sys_page_unmap>
	return r;
}
  8016c0:	89 d8                	mov    %ebx,%eax
  8016c2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016c5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016c8:	89 ec                	mov    %ebp,%esp
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dc:	89 04 24             	mov    %eax,(%esp)
  8016df:	e8 19 fc ff ff       	call   8012fd <fd_lookup>
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 13                	js     8016fb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016ef:	00 
  8016f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f3:	89 04 24             	mov    %eax,(%esp)
  8016f6:	e8 49 ff ff ff       	call   801644 <fd_close>
}
  8016fb:	c9                   	leave  
  8016fc:	c3                   	ret    

008016fd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	83 ec 18             	sub    $0x18,%esp
  801703:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801706:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801709:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801710:	00 
  801711:	8b 45 08             	mov    0x8(%ebp),%eax
  801714:	89 04 24             	mov    %eax,(%esp)
  801717:	e8 78 03 00 00       	call   801a94 <open>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 1b                	js     80173d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801722:	8b 45 0c             	mov    0xc(%ebp),%eax
  801725:	89 44 24 04          	mov    %eax,0x4(%esp)
  801729:	89 1c 24             	mov    %ebx,(%esp)
  80172c:	e8 ae fc ff ff       	call   8013df <fstat>
  801731:	89 c6                	mov    %eax,%esi
	close(fd);
  801733:	89 1c 24             	mov    %ebx,(%esp)
  801736:	e8 91 ff ff ff       	call   8016cc <close>
  80173b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80173d:	89 d8                	mov    %ebx,%eax
  80173f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801742:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801745:	89 ec                	mov    %ebp,%esp
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	53                   	push   %ebx
  80174d:	83 ec 14             	sub    $0x14,%esp
  801750:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801755:	89 1c 24             	mov    %ebx,(%esp)
  801758:	e8 6f ff ff ff       	call   8016cc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80175d:	83 c3 01             	add    $0x1,%ebx
  801760:	83 fb 20             	cmp    $0x20,%ebx
  801763:	75 f0                	jne    801755 <close_all+0xc>
		close(i);
}
  801765:	83 c4 14             	add    $0x14,%esp
  801768:	5b                   	pop    %ebx
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 58             	sub    $0x58,%esp
  801771:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801774:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801777:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80177a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80177d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801780:	89 44 24 04          	mov    %eax,0x4(%esp)
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	89 04 24             	mov    %eax,(%esp)
  80178a:	e8 6e fb ff ff       	call   8012fd <fd_lookup>
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	85 c0                	test   %eax,%eax
  801793:	0f 88 e0 00 00 00    	js     801879 <dup+0x10e>
		return r;
	close(newfdnum);
  801799:	89 3c 24             	mov    %edi,(%esp)
  80179c:	e8 2b ff ff ff       	call   8016cc <close>

	newfd = INDEX2FD(newfdnum);
  8017a1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8017a7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8017aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ad:	89 04 24             	mov    %eax,(%esp)
  8017b0:	e8 bb fa ff ff       	call   801270 <fd2data>
  8017b5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8017b7:	89 34 24             	mov    %esi,(%esp)
  8017ba:	e8 b1 fa ff ff       	call   801270 <fd2data>
  8017bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8017c2:	89 da                	mov    %ebx,%edx
  8017c4:	89 d8                	mov    %ebx,%eax
  8017c6:	c1 e8 16             	shr    $0x16,%eax
  8017c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8017d0:	a8 01                	test   $0x1,%al
  8017d2:	74 43                	je     801817 <dup+0xac>
  8017d4:	c1 ea 0c             	shr    $0xc,%edx
  8017d7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017de:	a8 01                	test   $0x1,%al
  8017e0:	74 35                	je     801817 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017e2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8017ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801800:	00 
  801801:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801805:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180c:	e8 80 f8 ff ff       	call   801091 <sys_page_map>
  801811:	89 c3                	mov    %eax,%ebx
  801813:	85 c0                	test   %eax,%eax
  801815:	78 3f                	js     801856 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801817:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80181a:	89 c2                	mov    %eax,%edx
  80181c:	c1 ea 0c             	shr    $0xc,%edx
  80181f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801826:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80182c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801830:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801834:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80183b:	00 
  80183c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801840:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801847:	e8 45 f8 ff ff       	call   801091 <sys_page_map>
  80184c:	89 c3                	mov    %eax,%ebx
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 04                	js     801856 <dup+0xeb>
  801852:	89 fb                	mov    %edi,%ebx
  801854:	eb 23                	jmp    801879 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801856:	89 74 24 04          	mov    %esi,0x4(%esp)
  80185a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801861:	e8 f3 f7 ff ff       	call   801059 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801866:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801869:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801874:	e8 e0 f7 ff ff       	call   801059 <sys_page_unmap>
	return r;
}
  801879:	89 d8                	mov    %ebx,%eax
  80187b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80187e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801881:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801884:	89 ec                	mov    %ebp,%esp
  801886:	5d                   	pop    %ebp
  801887:	c3                   	ret    

00801888 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801888:	55                   	push   %ebp
  801889:	89 e5                	mov    %esp,%ebp
  80188b:	83 ec 18             	sub    $0x18,%esp
  80188e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801891:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801894:	89 c3                	mov    %eax,%ebx
  801896:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801898:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80189f:	75 11                	jne    8018b2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8018a8:	e8 a3 02 00 00       	call   801b50 <ipc_find_env>
  8018ad:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8018b9:	00 
  8018ba:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8018c1:	00 
  8018c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8018cb:	89 04 24             	mov    %eax,(%esp)
  8018ce:	e8 c1 02 00 00       	call   801b94 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8018da:	00 
  8018db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e6:	e8 18 03 00 00       	call   801c03 <ipc_recv>
}
  8018eb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018ee:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018f1:	89 ec                	mov    %ebp,%esp
  8018f3:	5d                   	pop    %ebp
  8018f4:	c3                   	ret    

008018f5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801901:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801906:	8b 45 0c             	mov    0xc(%ebp),%eax
  801909:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80190e:	ba 00 00 00 00       	mov    $0x0,%edx
  801913:	b8 02 00 00 00       	mov    $0x2,%eax
  801918:	e8 6b ff ff ff       	call   801888 <fsipc>
}
  80191d:	c9                   	leave  
  80191e:	c3                   	ret    

0080191f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 40 0c             	mov    0xc(%eax),%eax
  80192b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801930:	ba 00 00 00 00       	mov    $0x0,%edx
  801935:	b8 06 00 00 00       	mov    $0x6,%eax
  80193a:	e8 49 ff ff ff       	call   801888 <fsipc>
}
  80193f:	c9                   	leave  
  801940:	c3                   	ret    

00801941 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801947:	ba 00 00 00 00       	mov    $0x0,%edx
  80194c:	b8 08 00 00 00       	mov    $0x8,%eax
  801951:	e8 32 ff ff ff       	call   801888 <fsipc>
}
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	53                   	push   %ebx
  80195c:	83 ec 14             	sub    $0x14,%esp
  80195f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	8b 40 0c             	mov    0xc(%eax),%eax
  801968:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80196d:	ba 00 00 00 00       	mov    $0x0,%edx
  801972:	b8 05 00 00 00       	mov    $0x5,%eax
  801977:	e8 0c ff ff ff       	call   801888 <fsipc>
  80197c:	85 c0                	test   %eax,%eax
  80197e:	78 2b                	js     8019ab <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801980:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801987:	00 
  801988:	89 1c 24             	mov    %ebx,(%esp)
  80198b:	e8 4a f1 ff ff       	call   800ada <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801990:	a1 80 50 80 00       	mov    0x805080,%eax
  801995:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80199b:	a1 84 50 80 00       	mov    0x805084,%eax
  8019a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8019a6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8019ab:	83 c4 14             	add    $0x14,%esp
  8019ae:	5b                   	pop    %ebx
  8019af:	5d                   	pop    %ebp
  8019b0:	c3                   	ret    

008019b1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8019b1:	55                   	push   %ebp
  8019b2:	89 e5                	mov    %esp,%ebp
  8019b4:	83 ec 18             	sub    $0x18,%esp
  8019b7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8019ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8019bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8019c0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  8019c6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  8019cb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8019d0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019d5:	0f 47 c2             	cmova  %edx,%eax
  8019d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019ea:	e8 d6 f2 ff ff       	call   800cc5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8019ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019f9:	e8 8a fe ff ff       	call   801888 <fsipc>
}
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	53                   	push   %ebx
  801a04:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a07:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a0d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801a12:	8b 45 10             	mov    0x10(%ebp),%eax
  801a15:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1f:	b8 03 00 00 00       	mov    $0x3,%eax
  801a24:	e8 5f fe ff ff       	call   801888 <fsipc>
  801a29:	89 c3                	mov    %eax,%ebx
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	78 17                	js     801a46 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a2f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a33:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801a3a:	00 
  801a3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3e:	89 04 24             	mov    %eax,(%esp)
  801a41:	e8 7f f2 ff ff       	call   800cc5 <memmove>
  return r;	
}
  801a46:	89 d8                	mov    %ebx,%eax
  801a48:	83 c4 14             	add    $0x14,%esp
  801a4b:	5b                   	pop    %ebx
  801a4c:	5d                   	pop    %ebp
  801a4d:	c3                   	ret    

00801a4e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a4e:	55                   	push   %ebp
  801a4f:	89 e5                	mov    %esp,%ebp
  801a51:	53                   	push   %ebx
  801a52:	83 ec 14             	sub    $0x14,%esp
  801a55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a58:	89 1c 24             	mov    %ebx,(%esp)
  801a5b:	e8 30 f0 ff ff       	call   800a90 <strlen>
  801a60:	89 c2                	mov    %eax,%edx
  801a62:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801a67:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801a6d:	7f 1f                	jg     801a8e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a6f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a73:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a7a:	e8 5b f0 ff ff       	call   800ada <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a7f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a84:	b8 07 00 00 00       	mov    $0x7,%eax
  801a89:	e8 fa fd ff ff       	call   801888 <fsipc>
}
  801a8e:	83 c4 14             	add    $0x14,%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	83 ec 28             	sub    $0x28,%esp
  801a9a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a9d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801aa0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa6:	89 04 24             	mov    %eax,(%esp)
  801aa9:	e8 dd f7 ff ff       	call   80128b <fd_alloc>
  801aae:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	0f 88 89 00 00 00    	js     801b41 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801ab8:	89 34 24             	mov    %esi,(%esp)
  801abb:	e8 d0 ef ff ff       	call   800a90 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801ac0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801ac5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801aca:	7f 75                	jg     801b41 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801acc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ad0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801ad7:	e8 fe ef ff ff       	call   800ada <strcpy>
  fsipcbuf.open.req_omode = mode;
  801adc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801adf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801ae4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ae7:	b8 01 00 00 00       	mov    $0x1,%eax
  801aec:	e8 97 fd ff ff       	call   801888 <fsipc>
  801af1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 0f                	js     801b06 <open+0x72>
  return fd2num(fd);
  801af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afa:	89 04 24             	mov    %eax,(%esp)
  801afd:	e8 5e f7 ff ff       	call   801260 <fd2num>
  801b02:	89 c3                	mov    %eax,%ebx
  801b04:	eb 3b                	jmp    801b41 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801b06:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b0d:	00 
  801b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b11:	89 04 24             	mov    %eax,(%esp)
  801b14:	e8 2b fb ff ff       	call   801644 <fd_close>
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	74 24                	je     801b41 <open+0xad>
  801b1d:	c7 44 24 0c 14 24 80 	movl   $0x802414,0xc(%esp)
  801b24:	00 
  801b25:	c7 44 24 08 29 24 80 	movl   $0x802429,0x8(%esp)
  801b2c:	00 
  801b2d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801b34:	00 
  801b35:	c7 04 24 3e 24 80 00 	movl   $0x80243e,(%esp)
  801b3c:	e8 9f e7 ff ff       	call   8002e0 <_panic>
  return r;
}
  801b41:	89 d8                	mov    %ebx,%eax
  801b43:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b46:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b49:	89 ec                	mov    %ebp,%esp
  801b4b:	5d                   	pop    %ebp
  801b4c:	c3                   	ret    
  801b4d:	00 00                	add    %al,(%eax)
	...

00801b50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801b56:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801b5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801b61:	39 ca                	cmp    %ecx,%edx
  801b63:	75 04                	jne    801b69 <ipc_find_env+0x19>
  801b65:	b0 00                	mov    $0x0,%al
  801b67:	eb 0f                	jmp    801b78 <ipc_find_env+0x28>
  801b69:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b6c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801b72:	8b 12                	mov    (%edx),%edx
  801b74:	39 ca                	cmp    %ecx,%edx
  801b76:	75 0c                	jne    801b84 <ipc_find_env+0x34>
			return envs[i].env_id;
  801b78:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b7b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801b80:	8b 00                	mov    (%eax),%eax
  801b82:	eb 0e                	jmp    801b92 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b84:	83 c0 01             	add    $0x1,%eax
  801b87:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b8c:	75 db                	jne    801b69 <ipc_find_env+0x19>
  801b8e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	57                   	push   %edi
  801b98:	56                   	push   %esi
  801b99:	53                   	push   %ebx
  801b9a:	83 ec 1c             	sub    $0x1c,%esp
  801b9d:	8b 75 08             	mov    0x8(%ebp),%esi
  801ba0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ba3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801ba6:	85 db                	test   %ebx,%ebx
  801ba8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bad:	0f 44 d8             	cmove  %eax,%ebx
  801bb0:	eb 29                	jmp    801bdb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	79 25                	jns    801bdb <ipc_send+0x47>
  801bb6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bb9:	74 20                	je     801bdb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbf:	c7 44 24 08 49 24 80 	movl   $0x802449,0x8(%esp)
  801bc6:	00 
  801bc7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801bce:	00 
  801bcf:	c7 04 24 67 24 80 00 	movl   $0x802467,(%esp)
  801bd6:	e8 05 e7 ff ff       	call   8002e0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801bdb:	8b 45 14             	mov    0x14(%ebp),%eax
  801bde:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801be2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801be6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bea:	89 34 24             	mov    %esi,(%esp)
  801bed:	e8 89 f3 ff ff       	call   800f7b <sys_ipc_try_send>
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	75 bc                	jne    801bb2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801bf6:	e8 06 f5 ff ff       	call   801101 <sys_yield>
}
  801bfb:	83 c4 1c             	add    $0x1c,%esp
  801bfe:	5b                   	pop    %ebx
  801bff:	5e                   	pop    %esi
  801c00:	5f                   	pop    %edi
  801c01:	5d                   	pop    %ebp
  801c02:	c3                   	ret    

00801c03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	83 ec 28             	sub    $0x28,%esp
  801c09:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801c0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801c0f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801c12:	8b 75 08             	mov    0x8(%ebp),%esi
  801c15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c18:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c22:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801c25:	89 04 24             	mov    %eax,(%esp)
  801c28:	e8 15 f3 ff ff       	call   800f42 <sys_ipc_recv>
  801c2d:	89 c3                	mov    %eax,%ebx
  801c2f:	85 c0                	test   %eax,%eax
  801c31:	79 2a                	jns    801c5d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801c33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c3b:	c7 04 24 71 24 80 00 	movl   $0x802471,(%esp)
  801c42:	e8 52 e7 ff ff       	call   800399 <cprintf>
		if(from_env_store != NULL)
  801c47:	85 f6                	test   %esi,%esi
  801c49:	74 06                	je     801c51 <ipc_recv+0x4e>
			*from_env_store = 0;
  801c4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801c51:	85 ff                	test   %edi,%edi
  801c53:	74 2d                	je     801c82 <ipc_recv+0x7f>
			*perm_store = 0;
  801c55:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801c5b:	eb 25                	jmp    801c82 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801c5d:	85 f6                	test   %esi,%esi
  801c5f:	90                   	nop
  801c60:	74 0a                	je     801c6c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801c62:	a1 04 40 80 00       	mov    0x804004,%eax
  801c67:	8b 40 74             	mov    0x74(%eax),%eax
  801c6a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801c6c:	85 ff                	test   %edi,%edi
  801c6e:	74 0a                	je     801c7a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801c70:	a1 04 40 80 00       	mov    0x804004,%eax
  801c75:	8b 40 78             	mov    0x78(%eax),%eax
  801c78:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801c7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c7f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801c82:	89 d8                	mov    %ebx,%eax
  801c84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801c87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801c8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801c8d:	89 ec                	mov    %ebp,%esp
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    
	...

00801ca0 <__udivdi3>:
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	57                   	push   %edi
  801ca4:	56                   	push   %esi
  801ca5:	83 ec 10             	sub    $0x10,%esp
  801ca8:	8b 45 14             	mov    0x14(%ebp),%eax
  801cab:	8b 55 08             	mov    0x8(%ebp),%edx
  801cae:	8b 75 10             	mov    0x10(%ebp),%esi
  801cb1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801cb9:	75 35                	jne    801cf0 <__udivdi3+0x50>
  801cbb:	39 fe                	cmp    %edi,%esi
  801cbd:	77 61                	ja     801d20 <__udivdi3+0x80>
  801cbf:	85 f6                	test   %esi,%esi
  801cc1:	75 0b                	jne    801cce <__udivdi3+0x2e>
  801cc3:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	f7 f6                	div    %esi
  801ccc:	89 c6                	mov    %eax,%esi
  801cce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801cd1:	31 d2                	xor    %edx,%edx
  801cd3:	89 f8                	mov    %edi,%eax
  801cd5:	f7 f6                	div    %esi
  801cd7:	89 c7                	mov    %eax,%edi
  801cd9:	89 c8                	mov    %ecx,%eax
  801cdb:	f7 f6                	div    %esi
  801cdd:	89 c1                	mov    %eax,%ecx
  801cdf:	89 fa                	mov    %edi,%edx
  801ce1:	89 c8                	mov    %ecx,%eax
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	39 f8                	cmp    %edi,%eax
  801cf2:	77 1c                	ja     801d10 <__udivdi3+0x70>
  801cf4:	0f bd d0             	bsr    %eax,%edx
  801cf7:	83 f2 1f             	xor    $0x1f,%edx
  801cfa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801cfd:	75 39                	jne    801d38 <__udivdi3+0x98>
  801cff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801d02:	0f 86 a0 00 00 00    	jbe    801da8 <__udivdi3+0x108>
  801d08:	39 f8                	cmp    %edi,%eax
  801d0a:	0f 82 98 00 00 00    	jb     801da8 <__udivdi3+0x108>
  801d10:	31 ff                	xor    %edi,%edi
  801d12:	31 c9                	xor    %ecx,%ecx
  801d14:	89 c8                	mov    %ecx,%eax
  801d16:	89 fa                	mov    %edi,%edx
  801d18:	83 c4 10             	add    $0x10,%esp
  801d1b:	5e                   	pop    %esi
  801d1c:	5f                   	pop    %edi
  801d1d:	5d                   	pop    %ebp
  801d1e:	c3                   	ret    
  801d1f:	90                   	nop
  801d20:	89 d1                	mov    %edx,%ecx
  801d22:	89 fa                	mov    %edi,%edx
  801d24:	89 c8                	mov    %ecx,%eax
  801d26:	31 ff                	xor    %edi,%edi
  801d28:	f7 f6                	div    %esi
  801d2a:	89 c1                	mov    %eax,%ecx
  801d2c:	89 fa                	mov    %edi,%edx
  801d2e:	89 c8                	mov    %ecx,%eax
  801d30:	83 c4 10             	add    $0x10,%esp
  801d33:	5e                   	pop    %esi
  801d34:	5f                   	pop    %edi
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    
  801d37:	90                   	nop
  801d38:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d3c:	89 f2                	mov    %esi,%edx
  801d3e:	d3 e0                	shl    %cl,%eax
  801d40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801d43:	b8 20 00 00 00       	mov    $0x20,%eax
  801d48:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801d4b:	89 c1                	mov    %eax,%ecx
  801d4d:	d3 ea                	shr    %cl,%edx
  801d4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d53:	0b 55 ec             	or     -0x14(%ebp),%edx
  801d56:	d3 e6                	shl    %cl,%esi
  801d58:	89 c1                	mov    %eax,%ecx
  801d5a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801d5d:	89 fe                	mov    %edi,%esi
  801d5f:	d3 ee                	shr    %cl,%esi
  801d61:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d65:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d6b:	d3 e7                	shl    %cl,%edi
  801d6d:	89 c1                	mov    %eax,%ecx
  801d6f:	d3 ea                	shr    %cl,%edx
  801d71:	09 d7                	or     %edx,%edi
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	89 f8                	mov    %edi,%eax
  801d77:	f7 75 ec             	divl   -0x14(%ebp)
  801d7a:	89 d6                	mov    %edx,%esi
  801d7c:	89 c7                	mov    %eax,%edi
  801d7e:	f7 65 e8             	mull   -0x18(%ebp)
  801d81:	39 d6                	cmp    %edx,%esi
  801d83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d86:	72 30                	jb     801db8 <__udivdi3+0x118>
  801d88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d8b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	39 c2                	cmp    %eax,%edx
  801d93:	73 05                	jae    801d9a <__udivdi3+0xfa>
  801d95:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801d98:	74 1e                	je     801db8 <__udivdi3+0x118>
  801d9a:	89 f9                	mov    %edi,%ecx
  801d9c:	31 ff                	xor    %edi,%edi
  801d9e:	e9 71 ff ff ff       	jmp    801d14 <__udivdi3+0x74>
  801da3:	90                   	nop
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	31 ff                	xor    %edi,%edi
  801daa:	b9 01 00 00 00       	mov    $0x1,%ecx
  801daf:	e9 60 ff ff ff       	jmp    801d14 <__udivdi3+0x74>
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801dbb:	31 ff                	xor    %edi,%edi
  801dbd:	89 c8                	mov    %ecx,%eax
  801dbf:	89 fa                	mov    %edi,%edx
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	5e                   	pop    %esi
  801dc5:	5f                   	pop    %edi
  801dc6:	5d                   	pop    %ebp
  801dc7:	c3                   	ret    
	...

00801dd0 <__umoddi3>:
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	57                   	push   %edi
  801dd4:	56                   	push   %esi
  801dd5:	83 ec 20             	sub    $0x20,%esp
  801dd8:	8b 55 14             	mov    0x14(%ebp),%edx
  801ddb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dde:	8b 7d 10             	mov    0x10(%ebp),%edi
  801de1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801de4:	85 d2                	test   %edx,%edx
  801de6:	89 c8                	mov    %ecx,%eax
  801de8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801deb:	75 13                	jne    801e00 <__umoddi3+0x30>
  801ded:	39 f7                	cmp    %esi,%edi
  801def:	76 3f                	jbe    801e30 <__umoddi3+0x60>
  801df1:	89 f2                	mov    %esi,%edx
  801df3:	f7 f7                	div    %edi
  801df5:	89 d0                	mov    %edx,%eax
  801df7:	31 d2                	xor    %edx,%edx
  801df9:	83 c4 20             	add    $0x20,%esp
  801dfc:	5e                   	pop    %esi
  801dfd:	5f                   	pop    %edi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    
  801e00:	39 f2                	cmp    %esi,%edx
  801e02:	77 4c                	ja     801e50 <__umoddi3+0x80>
  801e04:	0f bd ca             	bsr    %edx,%ecx
  801e07:	83 f1 1f             	xor    $0x1f,%ecx
  801e0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801e0d:	75 51                	jne    801e60 <__umoddi3+0x90>
  801e0f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801e12:	0f 87 e0 00 00 00    	ja     801ef8 <__umoddi3+0x128>
  801e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e1b:	29 f8                	sub    %edi,%eax
  801e1d:	19 d6                	sbb    %edx,%esi
  801e1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801e22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e25:	89 f2                	mov    %esi,%edx
  801e27:	83 c4 20             	add    $0x20,%esp
  801e2a:	5e                   	pop    %esi
  801e2b:	5f                   	pop    %edi
  801e2c:	5d                   	pop    %ebp
  801e2d:	c3                   	ret    
  801e2e:	66 90                	xchg   %ax,%ax
  801e30:	85 ff                	test   %edi,%edi
  801e32:	75 0b                	jne    801e3f <__umoddi3+0x6f>
  801e34:	b8 01 00 00 00       	mov    $0x1,%eax
  801e39:	31 d2                	xor    %edx,%edx
  801e3b:	f7 f7                	div    %edi
  801e3d:	89 c7                	mov    %eax,%edi
  801e3f:	89 f0                	mov    %esi,%eax
  801e41:	31 d2                	xor    %edx,%edx
  801e43:	f7 f7                	div    %edi
  801e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e48:	f7 f7                	div    %edi
  801e4a:	eb a9                	jmp    801df5 <__umoddi3+0x25>
  801e4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e50:	89 c8                	mov    %ecx,%eax
  801e52:	89 f2                	mov    %esi,%edx
  801e54:	83 c4 20             	add    $0x20,%esp
  801e57:	5e                   	pop    %esi
  801e58:	5f                   	pop    %edi
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    
  801e5b:	90                   	nop
  801e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e64:	d3 e2                	shl    %cl,%edx
  801e66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801e69:	ba 20 00 00 00       	mov    $0x20,%edx
  801e6e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801e71:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801e74:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801e78:	89 fa                	mov    %edi,%edx
  801e7a:	d3 ea                	shr    %cl,%edx
  801e7c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e80:	0b 55 f4             	or     -0xc(%ebp),%edx
  801e83:	d3 e7                	shl    %cl,%edi
  801e85:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801e89:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801e8c:	89 f2                	mov    %esi,%edx
  801e8e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801e91:	89 c7                	mov    %eax,%edi
  801e93:	d3 ea                	shr    %cl,%edx
  801e95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801e99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801e9c:	89 c2                	mov    %eax,%edx
  801e9e:	d3 e6                	shl    %cl,%esi
  801ea0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ea4:	d3 ea                	shr    %cl,%edx
  801ea6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801eaa:	09 d6                	or     %edx,%esi
  801eac:	89 f0                	mov    %esi,%eax
  801eae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801eb1:	d3 e7                	shl    %cl,%edi
  801eb3:	89 f2                	mov    %esi,%edx
  801eb5:	f7 75 f4             	divl   -0xc(%ebp)
  801eb8:	89 d6                	mov    %edx,%esi
  801eba:	f7 65 e8             	mull   -0x18(%ebp)
  801ebd:	39 d6                	cmp    %edx,%esi
  801ebf:	72 2b                	jb     801eec <__umoddi3+0x11c>
  801ec1:	39 c7                	cmp    %eax,%edi
  801ec3:	72 23                	jb     801ee8 <__umoddi3+0x118>
  801ec5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ec9:	29 c7                	sub    %eax,%edi
  801ecb:	19 d6                	sbb    %edx,%esi
  801ecd:	89 f0                	mov    %esi,%eax
  801ecf:	89 f2                	mov    %esi,%edx
  801ed1:	d3 ef                	shr    %cl,%edi
  801ed3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ed7:	d3 e0                	shl    %cl,%eax
  801ed9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801edd:	09 f8                	or     %edi,%eax
  801edf:	d3 ea                	shr    %cl,%edx
  801ee1:	83 c4 20             	add    $0x20,%esp
  801ee4:	5e                   	pop    %esi
  801ee5:	5f                   	pop    %edi
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    
  801ee8:	39 d6                	cmp    %edx,%esi
  801eea:	75 d9                	jne    801ec5 <__umoddi3+0xf5>
  801eec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801eef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801ef2:	eb d1                	jmp    801ec5 <__umoddi3+0xf5>
  801ef4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ef8:	39 f2                	cmp    %esi,%edx
  801efa:	0f 82 18 ff ff ff    	jb     801e18 <__umoddi3+0x48>
  801f00:	e9 1d ff ff ff       	jmp    801e22 <__umoddi3+0x52>
