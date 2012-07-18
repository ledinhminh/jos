
obj/user/evilhello2.debug:     file format elf32-i386


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
  80002c:	e8 ef 00 00 00       	call   800120 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <evil>:
#include <inc/x86.h>

char tmp[2*PGSIZE];
// Call this function with ring0 privilege
void evil()
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	// Kernel memory access
	*(char*)0xf010000a = 0;
  800037:	c6 05 0a 00 10 f0 00 	movb   $0x0,0xf010000a
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  80003e:	ba f8 03 00 00       	mov    $0x3f8,%edx
  800043:	b8 49 00 00 00       	mov    $0x49,%eax
  800048:	ee                   	out    %al,(%dx)
  800049:	b8 4e 00 00 00       	mov    $0x4e,%eax
  80004e:	ee                   	out    %al,(%dx)
  80004f:	b8 20 00 00 00       	mov    $0x20,%eax
  800054:	ee                   	out    %al,(%dx)
  800055:	b8 52 00 00 00       	mov    $0x52,%eax
  80005a:	ee                   	out    %al,(%dx)
  80005b:	b8 49 00 00 00       	mov    $0x49,%eax
  800060:	ee                   	out    %al,(%dx)
  800061:	b8 4e 00 00 00       	mov    $0x4e,%eax
  800066:	ee                   	out    %al,(%dx)
  800067:	b8 47 00 00 00       	mov    $0x47,%eax
  80006c:	ee                   	out    %al,(%dx)
  80006d:	b8 30 00 00 00       	mov    $0x30,%eax
  800072:	ee                   	out    %al,(%dx)
  800073:	b8 21 00 00 00       	mov    $0x21,%eax
  800078:	ee                   	out    %al,(%dx)
  800079:	ee                   	out    %al,(%dx)
  80007a:	ee                   	out    %al,(%dx)
  80007b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800080:	ee                   	out    %al,(%dx)
	outb(0x3f8, '0');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '!');
	outb(0x3f8, '\n');
}
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <ring0_call>:
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
}

// Invoke a given function pointer with ring0 privilege, then return to ring3
void ring0_call(void (*fun_ptr)(void)) {
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 38             	sub    $0x38,%esp
  800089:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80008c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80008f:	89 7d fc             	mov    %edi,-0x4(%ebp)
}

static void
sgdt(struct Pseudodesc* gdtd)
{
	__asm __volatile("sgdt %0" :  "=m" (*gdtd));
  800092:	0f 01 45 e2          	sgdtl  -0x1e(%ebp)
    // Lab3 : Your Code Here
    //1
    struct Pseudodesc lgdtcopy;
    sgdt(&lgdtcopy);
    //2
    sys_map_kernel_page((void*)(lgdtcopy.pd_base),(void*)&tmp[PGSIZE]);
  800096:	c7 44 24 04 20 50 80 	movl   $0x805020,0x4(%esp)
  80009d:	00 
  80009e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000a1:	89 04 24             	mov    %eax,(%esp)
  8000a4:	e8 53 03 00 00       	call   8003fc <sys_map_kernel_page>
    //3
    struct Gatedesc* gatedesc = &(((struct Gatedesc*)(
									(lgdtcopy.pd_base - ROUNDDOWN(lgdtcopy.pd_base,PGSIZE)) + ROUNDDOWN((&tmp[PGSIZE]),PGSIZE)
									))
									[3]
								);
  8000a9:	ba 20 50 80 00       	mov    $0x805020,%edx
  8000ae:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  8000b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000b7:	25 ff 0f 00 00       	and    $0xfff,%eax
  8000bc:	8d 5c 02 18          	lea    0x18(%edx,%eax,1),%ebx
        // call the evil function in ring0

	ring0_call(&evil);
	// call the evil function in ring3
	evil();
}
  8000c0:	8b 33                	mov    (%ebx),%esi
  8000c2:	8b 7b 04             	mov    0x4(%ebx),%edi
									(lgdtcopy.pd_base - ROUNDDOWN(lgdtcopy.pd_base,PGSIZE)) + ROUNDDOWN((&tmp[PGSIZE]),PGSIZE)
									))
									[3]
								);
    struct Gatedesc  savegate = *gatedesc;
    SETCALLGATE(*gatedesc,GD_KT,0x8000e5,3);
  8000c5:	66 c7 03 e5 00       	movw   $0xe5,(%ebx)
  8000ca:	66 c7 43 02 08 00    	movw   $0x8,0x2(%ebx)
  8000d0:	c6 43 04 00          	movb   $0x0,0x4(%ebx)
  8000d4:	0f b6 43 05          	movzbl 0x5(%ebx),%eax
  8000d8:	83 e0 e0             	and    $0xffffffe0,%eax
  8000db:	83 c8 0c             	or     $0xc,%eax
  8000de:	83 c8 e0             	or     $0xffffffe0,%eax
  8000e1:	88 43 05             	mov    %al,0x5(%ebx)
  8000e4:	66 c7 43 06 80 00    	movw   $0x80,0x6(%ebx)
    //4
    __asm __volatile("lcall $0x1b,$0\n");
  8000ea:	9a 00 00 00 00 1b 00 	lcall  $0x1b,$0x0
    //5
    fun_ptr();
  8000f1:	ff 55 08             	call   *0x8(%ebp)
    //6
    *gatedesc = savegate;
  8000f4:	89 33                	mov    %esi,(%ebx)
  8000f6:	89 7b 04             	mov    %edi,0x4(%ebx)
    //7
    __asm __volatile("lret \n");
  8000f9:	cb                   	lret   
    return;
    
}
  8000fa:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8000fd:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800100:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800103:	89 ec                	mov    %ebp,%esp
  800105:	5d                   	pop    %ebp
  800106:	c3                   	ret    

00800107 <umain>:

void
umain(int argc, char **argv)
{
  800107:	55                   	push   %ebp
  800108:	89 e5                	mov    %esp,%ebp
  80010a:	83 ec 18             	sub    $0x18,%esp
        // call the evil function in ring0

	ring0_call(&evil);
  80010d:	c7 04 24 34 00 80 00 	movl   $0x800034,(%esp)
  800114:	e8 6a ff ff ff       	call   800083 <ring0_call>
	// call the evil function in ring3
	evil();
  800119:	e8 16 ff ff ff       	call   800034 <evil>
}
  80011e:	c9                   	leave  
  80011f:	c3                   	ret    

00800120 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	83 ec 18             	sub    $0x18,%esp
  800126:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800129:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80012c:	8b 75 08             	mov    0x8(%ebp),%esi
  80012f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800132:	e8 fd 02 00 00       	call   800434 <sys_getenvid>
  800137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80013f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800144:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800149:	85 f6                	test   %esi,%esi
  80014b:	7e 07                	jle    800154 <libmain+0x34>
		binaryname = argv[0];
  80014d:	8b 03                	mov    (%ebx),%eax
  80014f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800154:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800158:	89 34 24             	mov    %esi,(%esp)
  80015b:	e8 a7 ff ff ff       	call   800107 <umain>

	// exit gracefully
	exit();
  800160:	e8 0b 00 00 00       	call   800170 <exit>
}
  800165:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800168:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80016b:	89 ec                	mov    %ebp,%esp
  80016d:	5d                   	pop    %ebp
  80016e:	c3                   	ret    
	...

00800170 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800176:	e8 8e 08 00 00       	call   800a09 <close_all>
	sys_env_destroy(0);
  80017b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800182:	e8 e8 02 00 00       	call   80046f <sys_env_destroy>
}
  800187:	c9                   	leave  
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
	...

0080018c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 48             	sub    $0x48,%esp
  800192:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800195:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800198:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80019b:	89 c6                	mov    %eax,%esi
  80019d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8001a0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8001a2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ab:	51                   	push   %ecx
  8001ac:	52                   	push   %edx
  8001ad:	53                   	push   %ebx
  8001ae:	54                   	push   %esp
  8001af:	55                   	push   %ebp
  8001b0:	56                   	push   %esi
  8001b1:	57                   	push   %edi
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	8d 35 bc 01 80 00    	lea    0x8001bc,%esi
  8001ba:	0f 34                	sysenter 

008001bc <.after_sysenter_label>:
  8001bc:	5f                   	pop    %edi
  8001bd:	5e                   	pop    %esi
  8001be:	5d                   	pop    %ebp
  8001bf:	5c                   	pop    %esp
  8001c0:	5b                   	pop    %ebx
  8001c1:	5a                   	pop    %edx
  8001c2:	59                   	pop    %ecx
  8001c3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8001c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8001c9:	74 28                	je     8001f3 <.after_sysenter_label+0x37>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	7e 24                	jle    8001f3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8001d7:	c7 44 24 08 ca 1d 80 	movl   $0x801dca,0x8(%esp)
  8001de:	00 
  8001df:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001e6:	00 
  8001e7:	c7 04 24 e7 1d 80 00 	movl   $0x801de7,(%esp)
  8001ee:	e8 1d 0c 00 00       	call   800e10 <_panic>

	return ret;
}
  8001f3:	89 d0                	mov    %edx,%eax
  8001f5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001f8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001fb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001fe:	89 ec                	mov    %ebp,%esp
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020f:	00 
  800210:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80021f:	00 
  800220:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	ba 01 00 00 00       	mov    $0x1,%edx
  80022f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800234:	e8 53 ff ff ff       	call   80018c <syscall>
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800241:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800248:	00 
  800249:	8b 45 14             	mov    0x14(%ebp),%eax
  80024c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800250:	8b 45 10             	mov    0x10(%ebp),%eax
  800253:	89 44 24 04          	mov    %eax,0x4(%esp)
  800257:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800260:	ba 00 00 00 00       	mov    $0x0,%edx
  800265:	b8 0d 00 00 00       	mov    $0xd,%eax
  80026a:	e8 1d ff ff ff       	call   80018c <syscall>
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800277:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027e:	00 
  80027f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800286:	00 
  800287:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80028e:	00 
  80028f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800292:	89 04 24             	mov    %eax,(%esp)
  800295:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800298:	ba 01 00 00 00       	mov    $0x1,%edx
  80029d:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a2:	e8 e5 fe ff ff       	call   80018c <syscall>
}
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8002af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b6:	00 
  8002b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002c6:	00 
  8002c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d0:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002da:	e8 ad fe ff ff       	call   80018c <syscall>
}
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8002e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ee:	00 
  8002ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002f6:	00 
  8002f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002fe:	00 
  8002ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800308:	ba 01 00 00 00       	mov    $0x1,%edx
  80030d:	b8 09 00 00 00       	mov    $0x9,%eax
  800312:	e8 75 fe ff ff       	call   80018c <syscall>
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80031f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800326:	00 
  800327:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80032e:	00 
  80032f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800336:	00 
  800337:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033a:	89 04 24             	mov    %eax,(%esp)
  80033d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800340:	ba 01 00 00 00       	mov    $0x1,%edx
  800345:	b8 07 00 00 00       	mov    $0x7,%eax
  80034a:	e8 3d fe ff ff       	call   80018c <syscall>
}
  80034f:	c9                   	leave  
  800350:	c3                   	ret    

00800351 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800351:	55                   	push   %ebp
  800352:	89 e5                	mov    %esp,%ebp
  800354:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800357:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035e:	00 
  80035f:	8b 45 18             	mov    0x18(%ebp),%eax
  800362:	0b 45 14             	or     0x14(%ebp),%eax
  800365:	89 44 24 08          	mov    %eax,0x8(%esp)
  800369:	8b 45 10             	mov    0x10(%ebp),%eax
  80036c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800370:	8b 45 0c             	mov    0xc(%ebp),%eax
  800373:	89 04 24             	mov    %eax,(%esp)
  800376:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800379:	ba 01 00 00 00       	mov    $0x1,%edx
  80037e:	b8 06 00 00 00       	mov    $0x6,%eax
  800383:	e8 04 fe ff ff       	call   80018c <syscall>
}
  800388:	c9                   	leave  
  800389:	c3                   	ret    

0080038a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800390:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800397:	00 
  800398:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80039f:	00 
  8003a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003aa:	89 04 24             	mov    %eax,(%esp)
  8003ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b0:	ba 01 00 00 00       	mov    $0x1,%edx
  8003b5:	b8 05 00 00 00       	mov    $0x5,%eax
  8003ba:	e8 cd fd ff ff       	call   80018c <syscall>
}
  8003bf:	c9                   	leave  
  8003c0:	c3                   	ret    

008003c1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8003c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ce:	00 
  8003cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003d6:	00 
  8003d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003de:	00 
  8003df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003f5:	e8 92 fd ff ff       	call   80018c <syscall>
}
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800402:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800409:	00 
  80040a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800411:	00 
  800412:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800419:	00 
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 04 24             	mov    %eax,(%esp)
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	ba 00 00 00 00       	mov    $0x0,%edx
  800428:	b8 04 00 00 00       	mov    $0x4,%eax
  80042d:	e8 5a fd ff ff       	call   80018c <syscall>
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80043a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800441:	00 
  800442:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
  800463:	b8 02 00 00 00       	mov    $0x2,%eax
  800468:	e8 1f fd ff ff       	call   80018c <syscall>
}
  80046d:	c9                   	leave  
  80046e:	c3                   	ret    

0080046f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800475:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80047c:	00 
  80047d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800484:	00 
  800485:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80048c:	00 
  80048d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800494:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800497:	ba 01 00 00 00       	mov    $0x1,%edx
  80049c:	b8 03 00 00 00       	mov    $0x3,%eax
  8004a1:	e8 e6 fc ff ff       	call   80018c <syscall>
}
  8004a6:	c9                   	leave  
  8004a7:	c3                   	ret    

008004a8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8004a8:	55                   	push   %ebp
  8004a9:	89 e5                	mov    %esp,%ebp
  8004ab:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8004ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b5:	00 
  8004b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004bd:	00 
  8004be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004c5:	00 
  8004c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8004dc:	e8 ab fc ff ff       	call   80018c <syscall>
}
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    

008004e3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8004e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004f0:	00 
  8004f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004f8:	00 
  8004f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800500:	00 
  800501:	8b 45 0c             	mov    0xc(%ebp),%eax
  800504:	89 04 24             	mov    %eax,(%esp)
  800507:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80050a:	ba 00 00 00 00       	mov    $0x0,%edx
  80050f:	b8 00 00 00 00       	mov    $0x0,%eax
  800514:	e8 73 fc ff ff       	call   80018c <syscall>
}
  800519:	c9                   	leave  
  80051a:	c3                   	ret    
  80051b:	00 00                	add    %al,(%eax)
  80051d:	00 00                	add    %al,(%eax)
	...

00800520 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	8b 45 08             	mov    0x8(%ebp),%eax
  800526:	05 00 00 00 30       	add    $0x30000000,%eax
  80052b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800536:	8b 45 08             	mov    0x8(%ebp),%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	e8 df ff ff ff       	call   800520 <fd2num>
  800541:	05 20 00 0d 00       	add    $0xd0020,%eax
  800546:	c1 e0 0c             	shl    $0xc,%eax
}
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800554:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800559:	a8 01                	test   $0x1,%al
  80055b:	74 36                	je     800593 <fd_alloc+0x48>
  80055d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800562:	a8 01                	test   $0x1,%al
  800564:	74 2d                	je     800593 <fd_alloc+0x48>
  800566:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80056b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800570:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800575:	89 c3                	mov    %eax,%ebx
  800577:	89 c2                	mov    %eax,%edx
  800579:	c1 ea 16             	shr    $0x16,%edx
  80057c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80057f:	f6 c2 01             	test   $0x1,%dl
  800582:	74 14                	je     800598 <fd_alloc+0x4d>
  800584:	89 c2                	mov    %eax,%edx
  800586:	c1 ea 0c             	shr    $0xc,%edx
  800589:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80058c:	f6 c2 01             	test   $0x1,%dl
  80058f:	75 10                	jne    8005a1 <fd_alloc+0x56>
  800591:	eb 05                	jmp    800598 <fd_alloc+0x4d>
  800593:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800598:	89 1f                	mov    %ebx,(%edi)
  80059a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80059f:	eb 17                	jmp    8005b8 <fd_alloc+0x6d>
  8005a1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8005a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8005ab:	75 c8                	jne    800575 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8005ad:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8005b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8005b8:	5b                   	pop    %ebx
  8005b9:	5e                   	pop    %esi
  8005ba:	5f                   	pop    %edi
  8005bb:	5d                   	pop    %ebp
  8005bc:	c3                   	ret    

008005bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8005bd:	55                   	push   %ebp
  8005be:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c3:	83 f8 1f             	cmp    $0x1f,%eax
  8005c6:	77 36                	ja     8005fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005c8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8005cd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8005d0:	89 c2                	mov    %eax,%edx
  8005d2:	c1 ea 16             	shr    $0x16,%edx
  8005d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005dc:	f6 c2 01             	test   $0x1,%dl
  8005df:	74 1d                	je     8005fe <fd_lookup+0x41>
  8005e1:	89 c2                	mov    %eax,%edx
  8005e3:	c1 ea 0c             	shr    $0xc,%edx
  8005e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005ed:	f6 c2 01             	test   $0x1,%dl
  8005f0:	74 0c                	je     8005fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f5:	89 02                	mov    %eax,(%edx)
  8005f7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8005fc:	eb 05                	jmp    800603 <fd_lookup+0x46>
  8005fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800603:	5d                   	pop    %ebp
  800604:	c3                   	ret    

00800605 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800605:	55                   	push   %ebp
  800606:	89 e5                	mov    %esp,%ebp
  800608:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80060b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80060e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800612:	8b 45 08             	mov    0x8(%ebp),%eax
  800615:	89 04 24             	mov    %eax,(%esp)
  800618:	e8 a0 ff ff ff       	call   8005bd <fd_lookup>
  80061d:	85 c0                	test   %eax,%eax
  80061f:	78 0e                	js     80062f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800621:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800624:	8b 55 0c             	mov    0xc(%ebp),%edx
  800627:	89 50 04             	mov    %edx,0x4(%eax)
  80062a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80062f:	c9                   	leave  
  800630:	c3                   	ret    

00800631 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800631:	55                   	push   %ebp
  800632:	89 e5                	mov    %esp,%ebp
  800634:	56                   	push   %esi
  800635:	53                   	push   %ebx
  800636:	83 ec 10             	sub    $0x10,%esp
  800639:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80063c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80063f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800644:	b8 04 30 80 00       	mov    $0x803004,%eax
  800649:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80064f:	75 11                	jne    800662 <dev_lookup+0x31>
  800651:	eb 04                	jmp    800657 <dev_lookup+0x26>
  800653:	39 08                	cmp    %ecx,(%eax)
  800655:	75 10                	jne    800667 <dev_lookup+0x36>
			*dev = devtab[i];
  800657:	89 03                	mov    %eax,(%ebx)
  800659:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80065e:	66 90                	xchg   %ax,%ax
  800660:	eb 36                	jmp    800698 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800662:	be 74 1e 80 00       	mov    $0x801e74,%esi
  800667:	83 c2 01             	add    $0x1,%edx
  80066a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80066d:	85 c0                	test   %eax,%eax
  80066f:	75 e2                	jne    800653 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800671:	a1 20 60 80 00       	mov    0x806020,%eax
  800676:	8b 40 48             	mov    0x48(%eax),%eax
  800679:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80067d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800681:	c7 04 24 f8 1d 80 00 	movl   $0x801df8,(%esp)
  800688:	e8 3c 08 00 00       	call   800ec9 <cprintf>
	*dev = 0;
  80068d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800693:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	5b                   	pop    %ebx
  80069c:	5e                   	pop    %esi
  80069d:	5d                   	pop    %ebp
  80069e:	c3                   	ret    

0080069f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80069f:	55                   	push   %ebp
  8006a0:	89 e5                	mov    %esp,%ebp
  8006a2:	53                   	push   %ebx
  8006a3:	83 ec 24             	sub    $0x24,%esp
  8006a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b3:	89 04 24             	mov    %eax,(%esp)
  8006b6:	e8 02 ff ff ff       	call   8005bd <fd_lookup>
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	78 53                	js     800712 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c9:	8b 00                	mov    (%eax),%eax
  8006cb:	89 04 24             	mov    %eax,(%esp)
  8006ce:	e8 5e ff ff ff       	call   800631 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	78 3b                	js     800712 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8006d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006df:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8006e3:	74 2d                	je     800712 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8006e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8006e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8006ef:	00 00 00 
	stat->st_isdir = 0;
  8006f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8006f9:	00 00 00 
	stat->st_dev = dev;
  8006fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800705:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800709:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80070c:	89 14 24             	mov    %edx,(%esp)
  80070f:	ff 50 14             	call   *0x14(%eax)
}
  800712:	83 c4 24             	add    $0x24,%esp
  800715:	5b                   	pop    %ebx
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	53                   	push   %ebx
  80071c:	83 ec 24             	sub    $0x24,%esp
  80071f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800722:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800725:	89 44 24 04          	mov    %eax,0x4(%esp)
  800729:	89 1c 24             	mov    %ebx,(%esp)
  80072c:	e8 8c fe ff ff       	call   8005bd <fd_lookup>
  800731:	85 c0                	test   %eax,%eax
  800733:	78 5f                	js     800794 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800735:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800738:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	89 04 24             	mov    %eax,(%esp)
  800744:	e8 e8 fe ff ff       	call   800631 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800749:	85 c0                	test   %eax,%eax
  80074b:	78 47                	js     800794 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80074d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800750:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800754:	75 23                	jne    800779 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800756:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80075b:	8b 40 48             	mov    0x48(%eax),%eax
  80075e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800762:	89 44 24 04          	mov    %eax,0x4(%esp)
  800766:	c7 04 24 18 1e 80 00 	movl   $0x801e18,(%esp)
  80076d:	e8 57 07 00 00       	call   800ec9 <cprintf>
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800777:	eb 1b                	jmp    800794 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800779:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077c:	8b 48 18             	mov    0x18(%eax),%ecx
  80077f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800784:	85 c9                	test   %ecx,%ecx
  800786:	74 0c                	je     800794 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	89 14 24             	mov    %edx,(%esp)
  800792:	ff d1                	call   *%ecx
}
  800794:	83 c4 24             	add    $0x24,%esp
  800797:	5b                   	pop    %ebx
  800798:	5d                   	pop    %ebp
  800799:	c3                   	ret    

0080079a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	53                   	push   %ebx
  80079e:	83 ec 24             	sub    $0x24,%esp
  8007a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ab:	89 1c 24             	mov    %ebx,(%esp)
  8007ae:	e8 0a fe ff ff       	call   8005bd <fd_lookup>
  8007b3:	85 c0                	test   %eax,%eax
  8007b5:	78 66                	js     80081d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c1:	8b 00                	mov    (%eax),%eax
  8007c3:	89 04 24             	mov    %eax,(%esp)
  8007c6:	e8 66 fe ff ff       	call   800631 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 4e                	js     80081d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8007d2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8007d6:	75 23                	jne    8007fb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007d8:	a1 20 60 80 00       	mov    0x806020,%eax
  8007dd:	8b 40 48             	mov    0x48(%eax),%eax
  8007e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	c7 04 24 39 1e 80 00 	movl   $0x801e39,(%esp)
  8007ef:	e8 d5 06 00 00       	call   800ec9 <cprintf>
  8007f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8007f9:	eb 22                	jmp    80081d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fe:	8b 48 0c             	mov    0xc(%eax),%ecx
  800801:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800806:	85 c9                	test   %ecx,%ecx
  800808:	74 13                	je     80081d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80080a:	8b 45 10             	mov    0x10(%ebp),%eax
  80080d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800811:	8b 45 0c             	mov    0xc(%ebp),%eax
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	89 14 24             	mov    %edx,(%esp)
  80081b:	ff d1                	call   *%ecx
}
  80081d:	83 c4 24             	add    $0x24,%esp
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	53                   	push   %ebx
  800827:	83 ec 24             	sub    $0x24,%esp
  80082a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800830:	89 44 24 04          	mov    %eax,0x4(%esp)
  800834:	89 1c 24             	mov    %ebx,(%esp)
  800837:	e8 81 fd ff ff       	call   8005bd <fd_lookup>
  80083c:	85 c0                	test   %eax,%eax
  80083e:	78 6b                	js     8008ab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800840:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800843:	89 44 24 04          	mov    %eax,0x4(%esp)
  800847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084a:	8b 00                	mov    (%eax),%eax
  80084c:	89 04 24             	mov    %eax,(%esp)
  80084f:	e8 dd fd ff ff       	call   800631 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800854:	85 c0                	test   %eax,%eax
  800856:	78 53                	js     8008ab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800858:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80085b:	8b 42 08             	mov    0x8(%edx),%eax
  80085e:	83 e0 03             	and    $0x3,%eax
  800861:	83 f8 01             	cmp    $0x1,%eax
  800864:	75 23                	jne    800889 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800866:	a1 20 60 80 00       	mov    0x806020,%eax
  80086b:	8b 40 48             	mov    0x48(%eax),%eax
  80086e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800872:	89 44 24 04          	mov    %eax,0x4(%esp)
  800876:	c7 04 24 56 1e 80 00 	movl   $0x801e56,(%esp)
  80087d:	e8 47 06 00 00       	call   800ec9 <cprintf>
  800882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800887:	eb 22                	jmp    8008ab <read+0x88>
	}
	if (!dev->dev_read)
  800889:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80088c:	8b 48 08             	mov    0x8(%eax),%ecx
  80088f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 13                	je     8008ab <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800898:	8b 45 10             	mov    0x10(%ebp),%eax
  80089b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a6:	89 14 24             	mov    %edx,(%esp)
  8008a9:	ff d1                	call   *%ecx
}
  8008ab:	83 c4 24             	add    $0x24,%esp
  8008ae:	5b                   	pop    %ebx
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	57                   	push   %edi
  8008b5:	56                   	push   %esi
  8008b6:	53                   	push   %ebx
  8008b7:	83 ec 1c             	sub    $0x1c,%esp
  8008ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cf:	85 f6                	test   %esi,%esi
  8008d1:	74 29                	je     8008fc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8008d3:	89 f0                	mov    %esi,%eax
  8008d5:	29 d0                	sub    %edx,%eax
  8008d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008db:	03 55 0c             	add    0xc(%ebp),%edx
  8008de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e2:	89 3c 24             	mov    %edi,(%esp)
  8008e5:	e8 39 ff ff ff       	call   800823 <read>
		if (m < 0)
  8008ea:	85 c0                	test   %eax,%eax
  8008ec:	78 0e                	js     8008fc <readn+0x4b>
			return m;
		if (m == 0)
  8008ee:	85 c0                	test   %eax,%eax
  8008f0:	74 08                	je     8008fa <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008f2:	01 c3                	add    %eax,%ebx
  8008f4:	89 da                	mov    %ebx,%edx
  8008f6:	39 f3                	cmp    %esi,%ebx
  8008f8:	72 d9                	jb     8008d3 <readn+0x22>
  8008fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8008fc:	83 c4 1c             	add    $0x1c,%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5f                   	pop    %edi
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	83 ec 28             	sub    $0x28,%esp
  80090a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80090d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800910:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800913:	89 34 24             	mov    %esi,(%esp)
  800916:	e8 05 fc ff ff       	call   800520 <fd2num>
  80091b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80091e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800922:	89 04 24             	mov    %eax,(%esp)
  800925:	e8 93 fc ff ff       	call   8005bd <fd_lookup>
  80092a:	89 c3                	mov    %eax,%ebx
  80092c:	85 c0                	test   %eax,%eax
  80092e:	78 05                	js     800935 <fd_close+0x31>
  800930:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800933:	74 0e                	je     800943 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800935:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800939:	b8 00 00 00 00       	mov    $0x0,%eax
  80093e:	0f 44 d8             	cmove  %eax,%ebx
  800941:	eb 3d                	jmp    800980 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800943:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800946:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094a:	8b 06                	mov    (%esi),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 dd fc ff ff       	call   800631 <dev_lookup>
  800954:	89 c3                	mov    %eax,%ebx
  800956:	85 c0                	test   %eax,%eax
  800958:	78 16                	js     800970 <fd_close+0x6c>
		if (dev->dev_close)
  80095a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095d:	8b 40 10             	mov    0x10(%eax),%eax
  800960:	bb 00 00 00 00       	mov    $0x0,%ebx
  800965:	85 c0                	test   %eax,%eax
  800967:	74 07                	je     800970 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800969:	89 34 24             	mov    %esi,(%esp)
  80096c:	ff d0                	call   *%eax
  80096e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800970:	89 74 24 04          	mov    %esi,0x4(%esp)
  800974:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80097b:	e8 99 f9 ff ff       	call   800319 <sys_page_unmap>
	return r;
}
  800980:	89 d8                	mov    %ebx,%eax
  800982:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800985:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800988:	89 ec                	mov    %ebp,%esp
  80098a:	5d                   	pop    %ebp
  80098b:	c3                   	ret    

0080098c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800992:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800995:	89 44 24 04          	mov    %eax,0x4(%esp)
  800999:	8b 45 08             	mov    0x8(%ebp),%eax
  80099c:	89 04 24             	mov    %eax,(%esp)
  80099f:	e8 19 fc ff ff       	call   8005bd <fd_lookup>
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	78 13                	js     8009bb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8009a8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8009af:	00 
  8009b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 49 ff ff ff       	call   800904 <fd_close>
}
  8009bb:	c9                   	leave  
  8009bc:	c3                   	ret    

008009bd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	83 ec 18             	sub    $0x18,%esp
  8009c3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8009c6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009d0:	00 
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	89 04 24             	mov    %eax,(%esp)
  8009d7:	e8 78 03 00 00       	call   800d54 <open>
  8009dc:	89 c3                	mov    %eax,%ebx
  8009de:	85 c0                	test   %eax,%eax
  8009e0:	78 1b                	js     8009fd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8009e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e9:	89 1c 24             	mov    %ebx,(%esp)
  8009ec:	e8 ae fc ff ff       	call   80069f <fstat>
  8009f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8009f3:	89 1c 24             	mov    %ebx,(%esp)
  8009f6:	e8 91 ff ff ff       	call   80098c <close>
  8009fb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8009fd:	89 d8                	mov    %ebx,%eax
  8009ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800a02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800a05:	89 ec                	mov    %ebp,%esp
  800a07:	5d                   	pop    %ebp
  800a08:	c3                   	ret    

00800a09 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800a09:	55                   	push   %ebp
  800a0a:	89 e5                	mov    %esp,%ebp
  800a0c:	53                   	push   %ebx
  800a0d:	83 ec 14             	sub    $0x14,%esp
  800a10:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800a15:	89 1c 24             	mov    %ebx,(%esp)
  800a18:	e8 6f ff ff ff       	call   80098c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800a1d:	83 c3 01             	add    $0x1,%ebx
  800a20:	83 fb 20             	cmp    $0x20,%ebx
  800a23:	75 f0                	jne    800a15 <close_all+0xc>
		close(i);
}
  800a25:	83 c4 14             	add    $0x14,%esp
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	83 ec 58             	sub    $0x58,%esp
  800a31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a37:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a40:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	89 04 24             	mov    %eax,(%esp)
  800a4a:	e8 6e fb ff ff       	call   8005bd <fd_lookup>
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	85 c0                	test   %eax,%eax
  800a53:	0f 88 e0 00 00 00    	js     800b39 <dup+0x10e>
		return r;
	close(newfdnum);
  800a59:	89 3c 24             	mov    %edi,(%esp)
  800a5c:	e8 2b ff ff ff       	call   80098c <close>

	newfd = INDEX2FD(newfdnum);
  800a61:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a67:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a6d:	89 04 24             	mov    %eax,(%esp)
  800a70:	e8 bb fa ff ff       	call   800530 <fd2data>
  800a75:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a77:	89 34 24             	mov    %esi,(%esp)
  800a7a:	e8 b1 fa ff ff       	call   800530 <fd2data>
  800a7f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800a82:	89 da                	mov    %ebx,%edx
  800a84:	89 d8                	mov    %ebx,%eax
  800a86:	c1 e8 16             	shr    $0x16,%eax
  800a89:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a90:	a8 01                	test   $0x1,%al
  800a92:	74 43                	je     800ad7 <dup+0xac>
  800a94:	c1 ea 0c             	shr    $0xc,%edx
  800a97:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a9e:	a8 01                	test   $0x1,%al
  800aa0:	74 35                	je     800ad7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800aa2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800aa9:	25 07 0e 00 00       	and    $0xe07,%eax
  800aae:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ab2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ab5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ab9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ac0:	00 
  800ac1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800acc:	e8 80 f8 ff ff       	call   800351 <sys_page_map>
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 3f                	js     800b16 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ad7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ada:	89 c2                	mov    %eax,%edx
  800adc:	c1 ea 0c             	shr    $0xc,%edx
  800adf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ae6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800aec:	89 54 24 10          	mov    %edx,0x10(%esp)
  800af0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800af4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800afb:	00 
  800afc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b07:	e8 45 f8 ff ff       	call   800351 <sys_page_map>
  800b0c:	89 c3                	mov    %eax,%ebx
  800b0e:	85 c0                	test   %eax,%eax
  800b10:	78 04                	js     800b16 <dup+0xeb>
  800b12:	89 fb                	mov    %edi,%ebx
  800b14:	eb 23                	jmp    800b39 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b21:	e8 f3 f7 ff ff       	call   800319 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b29:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b34:	e8 e0 f7 ff ff       	call   800319 <sys_page_unmap>
	return r;
}
  800b39:	89 d8                	mov    %ebx,%eax
  800b3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b44:	89 ec                	mov    %ebp,%esp
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 18             	sub    $0x18,%esp
  800b4e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b51:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b54:	89 c3                	mov    %eax,%ebx
  800b56:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b58:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b5f:	75 11                	jne    800b72 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b61:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b68:	e8 93 0e 00 00       	call   801a00 <ipc_find_env>
  800b6d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b72:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b79:	00 
  800b7a:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  800b81:	00 
  800b82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b86:	a1 00 40 80 00       	mov    0x804000,%eax
  800b8b:	89 04 24             	mov    %eax,(%esp)
  800b8e:	e8 b1 0e 00 00       	call   801a44 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b9a:	00 
  800b9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ba6:	e8 08 0f 00 00       	call   801ab3 <ipc_recv>
}
  800bab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800bae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800bb1:	89 ec                	mov    %ebp,%esp
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 40 0c             	mov    0xc(%eax),%eax
  800bc1:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  800bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bc9:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd8:	e8 6b ff ff ff       	call   800b48 <fsipc>
}
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800be5:	8b 45 08             	mov    0x8(%ebp),%eax
  800be8:	8b 40 0c             	mov    0xc(%eax),%eax
  800beb:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bfa:	e8 49 ff ff ff       	call   800b48 <fsipc>
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c07:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c11:	e8 32 ff ff ff       	call   800b48 <fsipc>
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	53                   	push   %ebx
  800c1c:	83 ec 14             	sub    $0x14,%esp
  800c1f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800c22:	8b 45 08             	mov    0x8(%ebp),%eax
  800c25:	8b 40 0c             	mov    0xc(%eax),%eax
  800c28:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800c2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c32:	b8 05 00 00 00       	mov    $0x5,%eax
  800c37:	e8 0c ff ff ff       	call   800b48 <fsipc>
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	78 2b                	js     800c6b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c40:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800c47:	00 
  800c48:	89 1c 24             	mov    %ebx,(%esp)
  800c4b:	e8 ba 09 00 00       	call   80160a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c50:	a1 80 70 80 00       	mov    0x807080,%eax
  800c55:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c5b:	a1 84 70 80 00       	mov    0x807084,%eax
  800c60:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800c66:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800c6b:	83 c4 14             	add    $0x14,%esp
  800c6e:	5b                   	pop    %ebx
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 18             	sub    $0x18,%esp
  800c77:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 52 0c             	mov    0xc(%edx),%edx
  800c80:	89 15 00 70 80 00    	mov    %edx,0x807000
  fsipcbuf.write.req_n = n;
  800c86:	a3 04 70 80 00       	mov    %eax,0x807004
  memmove(fsipcbuf.write.req_buf, buf,
  800c8b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800c90:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800c95:	0f 47 c2             	cmova  %edx,%eax
  800c98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca3:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  800caa:	e8 46 0b 00 00       	call   8017f5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800caf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb4:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb9:	e8 8a fe ff ff       	call   800b48 <fsipc>
}
  800cbe:	c9                   	leave  
  800cbf:	c3                   	ret    

00800cc0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cca:	8b 40 0c             	mov    0xc(%eax),%eax
  800ccd:	a3 00 70 80 00       	mov    %eax,0x807000
  fsipcbuf.read.req_n = n;
  800cd2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd5:	a3 04 70 80 00       	mov    %eax,0x807004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800cda:	ba 00 00 00 00       	mov    $0x0,%edx
  800cdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800ce4:	e8 5f fe ff ff       	call   800b48 <fsipc>
  800ce9:	89 c3                	mov    %eax,%ebx
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	78 17                	js     800d06 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800cef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf3:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800cfa:	00 
  800cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cfe:	89 04 24             	mov    %eax,(%esp)
  800d01:	e8 ef 0a 00 00       	call   8017f5 <memmove>
  return r;	
}
  800d06:	89 d8                	mov    %ebx,%eax
  800d08:	83 c4 14             	add    $0x14,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	53                   	push   %ebx
  800d12:	83 ec 14             	sub    $0x14,%esp
  800d15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800d18:	89 1c 24             	mov    %ebx,(%esp)
  800d1b:	e8 a0 08 00 00       	call   8015c0 <strlen>
  800d20:	89 c2                	mov    %eax,%edx
  800d22:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d27:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800d2d:	7f 1f                	jg     800d4e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800d2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d33:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  800d3a:	e8 cb 08 00 00       	call   80160a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d44:	b8 07 00 00 00       	mov    $0x7,%eax
  800d49:	e8 fa fd ff ff       	call   800b48 <fsipc>
}
  800d4e:	83 c4 14             	add    $0x14,%esp
  800d51:	5b                   	pop    %ebx
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 28             	sub    $0x28,%esp
  800d5a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d5d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d60:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800d63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d66:	89 04 24             	mov    %eax,(%esp)
  800d69:	e8 dd f7 ff ff       	call   80054b <fd_alloc>
  800d6e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800d70:	85 c0                	test   %eax,%eax
  800d72:	0f 88 89 00 00 00    	js     800e01 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d78:	89 34 24             	mov    %esi,(%esp)
  800d7b:	e8 40 08 00 00       	call   8015c0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800d80:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d85:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800d8a:	7f 75                	jg     800e01 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800d8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d90:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  800d97:	e8 6e 08 00 00       	call   80160a <strcpy>
  fsipcbuf.open.req_omode = mode;
  800d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9f:	a3 00 74 80 00       	mov    %eax,0x807400
  r = fsipc(FSREQ_OPEN, fd);
  800da4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800da7:	b8 01 00 00 00       	mov    $0x1,%eax
  800dac:	e8 97 fd ff ff       	call   800b48 <fsipc>
  800db1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800db3:	85 c0                	test   %eax,%eax
  800db5:	78 0f                	js     800dc6 <open+0x72>
  return fd2num(fd);
  800db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dba:	89 04 24             	mov    %eax,(%esp)
  800dbd:	e8 5e f7 ff ff       	call   800520 <fd2num>
  800dc2:	89 c3                	mov    %eax,%ebx
  800dc4:	eb 3b                	jmp    800e01 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800dc6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dcd:	00 
  800dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dd1:	89 04 24             	mov    %eax,(%esp)
  800dd4:	e8 2b fb ff ff       	call   800904 <fd_close>
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	74 24                	je     800e01 <open+0xad>
  800ddd:	c7 44 24 0c 7c 1e 80 	movl   $0x801e7c,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 91 1e 80 	movl   $0x801e91,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 a6 1e 80 00 	movl   $0x801ea6,(%esp)
  800dfc:	e8 0f 00 00 00       	call   800e10 <_panic>
  return r;
}
  800e01:	89 d8                	mov    %ebx,%eax
  800e03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800e09:	89 ec                	mov    %ebp,%esp
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    
  800e0d:	00 00                	add    %al,(%eax)
	...

00800e10 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800e18:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800e1b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800e21:	e8 0e f6 ff ff       	call   800434 <sys_getenvid>
  800e26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e29:	89 54 24 10          	mov    %edx,0x10(%esp)
  800e2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e30:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800e34:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e38:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e3c:	c7 04 24 b4 1e 80 00 	movl   $0x801eb4,(%esp)
  800e43:	e8 81 00 00 00       	call   800ec9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800e48:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4f:	89 04 24             	mov    %eax,(%esp)
  800e52:	e8 11 00 00 00       	call   800e68 <vcprintf>
	cprintf("\n");
  800e57:	c7 04 24 70 1e 80 00 	movl   $0x801e70,(%esp)
  800e5e:	e8 66 00 00 00       	call   800ec9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e63:	cc                   	int3   
  800e64:	eb fd                	jmp    800e63 <_panic+0x53>
	...

00800e68 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800e71:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800e78:	00 00 00 
	b.cnt = 0;
  800e7b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800e82:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800e85:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e93:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e9d:	c7 04 24 e3 0e 80 00 	movl   $0x800ee3,(%esp)
  800ea4:	e8 d4 01 00 00       	call   80107d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ea9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800eb9:	89 04 24             	mov    %eax,(%esp)
  800ebc:	e8 22 f6 ff ff       	call   8004e3 <sys_cputs>

	return b.cnt;
}
  800ec1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800ec7:	c9                   	leave  
  800ec8:	c3                   	ret    

00800ec9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800ec9:	55                   	push   %ebp
  800eca:	89 e5                	mov    %esp,%ebp
  800ecc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800ecf:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800ed2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	89 04 24             	mov    %eax,(%esp)
  800edc:	e8 87 ff ff ff       	call   800e68 <vcprintf>
	va_end(ap);

	return cnt;
}
  800ee1:	c9                   	leave  
  800ee2:	c3                   	ret    

00800ee3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	53                   	push   %ebx
  800ee7:	83 ec 14             	sub    $0x14,%esp
  800eea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800eed:	8b 03                	mov    (%ebx),%eax
  800eef:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800ef6:	83 c0 01             	add    $0x1,%eax
  800ef9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800efb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800f00:	75 19                	jne    800f1b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800f02:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800f09:	00 
  800f0a:	8d 43 08             	lea    0x8(%ebx),%eax
  800f0d:	89 04 24             	mov    %eax,(%esp)
  800f10:	e8 ce f5 ff ff       	call   8004e3 <sys_cputs>
		b->idx = 0;
  800f15:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800f1b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800f1f:	83 c4 14             	add    $0x14,%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5d                   	pop    %ebp
  800f24:	c3                   	ret    
	...

00800f30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 4c             	sub    $0x4c,%esp
  800f39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800f3c:	89 d6                	mov    %edx,%esi
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f44:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f47:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800f50:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800f53:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800f56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5b:	39 d1                	cmp    %edx,%ecx
  800f5d:	72 15                	jb     800f74 <printnum+0x44>
  800f5f:	77 07                	ja     800f68 <printnum+0x38>
  800f61:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f64:	39 d0                	cmp    %edx,%eax
  800f66:	76 0c                	jbe    800f74 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800f68:	83 eb 01             	sub    $0x1,%ebx
  800f6b:	85 db                	test   %ebx,%ebx
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	7f 61                	jg     800fd3 <printnum+0xa3>
  800f72:	eb 70                	jmp    800fe4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800f74:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800f78:	83 eb 01             	sub    $0x1,%ebx
  800f7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f83:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f87:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  800f8b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800f8e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800f91:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800f94:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f9f:	00 
  800fa0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fa3:	89 04 24             	mov    %eax,(%esp)
  800fa6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800fa9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fad:	e8 9e 0b 00 00       	call   801b50 <__udivdi3>
  800fb2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800fb5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800fb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fbc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fc0:	89 04 24             	mov    %eax,(%esp)
  800fc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc7:	89 f2                	mov    %esi,%edx
  800fc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fcc:	e8 5f ff ff ff       	call   800f30 <printnum>
  800fd1:	eb 11                	jmp    800fe4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800fd3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd7:	89 3c 24             	mov    %edi,(%esp)
  800fda:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800fdd:	83 eb 01             	sub    $0x1,%ebx
  800fe0:	85 db                	test   %ebx,%ebx
  800fe2:	7f ef                	jg     800fd3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800fe4:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fe8:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800fef:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ff3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ffa:	00 
  800ffb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ffe:	89 14 24             	mov    %edx,(%esp)
  801001:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801004:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801008:	e8 73 0c 00 00       	call   801c80 <__umoddi3>
  80100d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801011:	0f be 80 d7 1e 80 00 	movsbl 0x801ed7(%eax),%eax
  801018:	89 04 24             	mov    %eax,(%esp)
  80101b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80101e:	83 c4 4c             	add    $0x4c,%esp
  801021:	5b                   	pop    %ebx
  801022:	5e                   	pop    %esi
  801023:	5f                   	pop    %edi
  801024:	5d                   	pop    %ebp
  801025:	c3                   	ret    

00801026 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801029:	83 fa 01             	cmp    $0x1,%edx
  80102c:	7e 0e                	jle    80103c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80102e:	8b 10                	mov    (%eax),%edx
  801030:	8d 4a 08             	lea    0x8(%edx),%ecx
  801033:	89 08                	mov    %ecx,(%eax)
  801035:	8b 02                	mov    (%edx),%eax
  801037:	8b 52 04             	mov    0x4(%edx),%edx
  80103a:	eb 22                	jmp    80105e <getuint+0x38>
	else if (lflag)
  80103c:	85 d2                	test   %edx,%edx
  80103e:	74 10                	je     801050 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801040:	8b 10                	mov    (%eax),%edx
  801042:	8d 4a 04             	lea    0x4(%edx),%ecx
  801045:	89 08                	mov    %ecx,(%eax)
  801047:	8b 02                	mov    (%edx),%eax
  801049:	ba 00 00 00 00       	mov    $0x0,%edx
  80104e:	eb 0e                	jmp    80105e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801050:	8b 10                	mov    (%eax),%edx
  801052:	8d 4a 04             	lea    0x4(%edx),%ecx
  801055:	89 08                	mov    %ecx,(%eax)
  801057:	8b 02                	mov    (%edx),%eax
  801059:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801066:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80106a:	8b 10                	mov    (%eax),%edx
  80106c:	3b 50 04             	cmp    0x4(%eax),%edx
  80106f:	73 0a                	jae    80107b <sprintputch+0x1b>
		*b->buf++ = ch;
  801071:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801074:	88 0a                	mov    %cl,(%edx)
  801076:	83 c2 01             	add    $0x1,%edx
  801079:	89 10                	mov    %edx,(%eax)
}
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 5c             	sub    $0x5c,%esp
  801086:	8b 7d 08             	mov    0x8(%ebp),%edi
  801089:	8b 75 0c             	mov    0xc(%ebp),%esi
  80108c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80108f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801096:	eb 11                	jmp    8010a9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801098:	85 c0                	test   %eax,%eax
  80109a:	0f 84 68 04 00 00    	je     801508 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8010a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010a4:	89 04 24             	mov    %eax,(%esp)
  8010a7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8010a9:	0f b6 03             	movzbl (%ebx),%eax
  8010ac:	83 c3 01             	add    $0x1,%ebx
  8010af:	83 f8 25             	cmp    $0x25,%eax
  8010b2:	75 e4                	jne    801098 <vprintfmt+0x1b>
  8010b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8010bb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8010c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010c7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8010cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8010d2:	eb 06                	jmp    8010da <vprintfmt+0x5d>
  8010d4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8010d8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8010da:	0f b6 13             	movzbl (%ebx),%edx
  8010dd:	0f b6 c2             	movzbl %dl,%eax
  8010e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010e3:	8d 43 01             	lea    0x1(%ebx),%eax
  8010e6:	83 ea 23             	sub    $0x23,%edx
  8010e9:	80 fa 55             	cmp    $0x55,%dl
  8010ec:	0f 87 f9 03 00 00    	ja     8014eb <vprintfmt+0x46e>
  8010f2:	0f b6 d2             	movzbl %dl,%edx
  8010f5:	ff 24 95 c0 20 80 00 	jmp    *0x8020c0(,%edx,4)
  8010fc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  801100:	eb d6                	jmp    8010d8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801102:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801105:	83 ea 30             	sub    $0x30,%edx
  801108:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80110b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80110e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801111:	83 fb 09             	cmp    $0x9,%ebx
  801114:	77 54                	ja     80116a <vprintfmt+0xed>
  801116:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801119:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80111c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80111f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801122:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  801126:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801129:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80112c:	83 fb 09             	cmp    $0x9,%ebx
  80112f:	76 eb                	jbe    80111c <vprintfmt+0x9f>
  801131:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801134:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801137:	eb 31                	jmp    80116a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801139:	8b 55 14             	mov    0x14(%ebp),%edx
  80113c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80113f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801142:	8b 12                	mov    (%edx),%edx
  801144:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  801147:	eb 21                	jmp    80116a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  801149:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80114d:	ba 00 00 00 00       	mov    $0x0,%edx
  801152:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  801156:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801159:	e9 7a ff ff ff       	jmp    8010d8 <vprintfmt+0x5b>
  80115e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801165:	e9 6e ff ff ff       	jmp    8010d8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80116a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80116e:	0f 89 64 ff ff ff    	jns    8010d8 <vprintfmt+0x5b>
  801174:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801177:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80117a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80117d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801180:	e9 53 ff ff ff       	jmp    8010d8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801185:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  801188:	e9 4b ff ff ff       	jmp    8010d8 <vprintfmt+0x5b>
  80118d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801190:	8b 45 14             	mov    0x14(%ebp),%eax
  801193:	8d 50 04             	lea    0x4(%eax),%edx
  801196:	89 55 14             	mov    %edx,0x14(%ebp)
  801199:	89 74 24 04          	mov    %esi,0x4(%esp)
  80119d:	8b 00                	mov    (%eax),%eax
  80119f:	89 04 24             	mov    %eax,(%esp)
  8011a2:	ff d7                	call   *%edi
  8011a4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8011a7:	e9 fd fe ff ff       	jmp    8010a9 <vprintfmt+0x2c>
  8011ac:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8011af:	8b 45 14             	mov    0x14(%ebp),%eax
  8011b2:	8d 50 04             	lea    0x4(%eax),%edx
  8011b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8011b8:	8b 00                	mov    (%eax),%eax
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	c1 fa 1f             	sar    $0x1f,%edx
  8011bf:	31 d0                	xor    %edx,%eax
  8011c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8011c3:	83 f8 0f             	cmp    $0xf,%eax
  8011c6:	7f 0b                	jg     8011d3 <vprintfmt+0x156>
  8011c8:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  8011cf:	85 d2                	test   %edx,%edx
  8011d1:	75 20                	jne    8011f3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8011d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d7:	c7 44 24 08 e8 1e 80 	movl   $0x801ee8,0x8(%esp)
  8011de:	00 
  8011df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e3:	89 3c 24             	mov    %edi,(%esp)
  8011e6:	e8 a5 03 00 00       	call   801590 <printfmt>
  8011eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8011ee:	e9 b6 fe ff ff       	jmp    8010a9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8011f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8011f7:	c7 44 24 08 a3 1e 80 	movl   $0x801ea3,0x8(%esp)
  8011fe:	00 
  8011ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801203:	89 3c 24             	mov    %edi,(%esp)
  801206:	e8 85 03 00 00       	call   801590 <printfmt>
  80120b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80120e:	e9 96 fe ff ff       	jmp    8010a9 <vprintfmt+0x2c>
  801213:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801216:	89 c3                	mov    %eax,%ebx
  801218:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80121b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80121e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801221:	8b 45 14             	mov    0x14(%ebp),%eax
  801224:	8d 50 04             	lea    0x4(%eax),%edx
  801227:	89 55 14             	mov    %edx,0x14(%ebp)
  80122a:	8b 00                	mov    (%eax),%eax
  80122c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80122f:	85 c0                	test   %eax,%eax
  801231:	b8 f1 1e 80 00       	mov    $0x801ef1,%eax
  801236:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80123a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80123d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801241:	7e 06                	jle    801249 <vprintfmt+0x1cc>
  801243:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  801247:	75 13                	jne    80125c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801249:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80124c:	0f be 02             	movsbl (%edx),%eax
  80124f:	85 c0                	test   %eax,%eax
  801251:	0f 85 a2 00 00 00    	jne    8012f9 <vprintfmt+0x27c>
  801257:	e9 8f 00 00 00       	jmp    8012eb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80125c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801260:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801263:	89 0c 24             	mov    %ecx,(%esp)
  801266:	e8 70 03 00 00       	call   8015db <strnlen>
  80126b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80126e:	29 c2                	sub    %eax,%edx
  801270:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801273:	85 d2                	test   %edx,%edx
  801275:	7e d2                	jle    801249 <vprintfmt+0x1cc>
					putch(padc, putdat);
  801277:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80127b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80127e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  801281:	89 d3                	mov    %edx,%ebx
  801283:	89 74 24 04          	mov    %esi,0x4(%esp)
  801287:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80128a:	89 04 24             	mov    %eax,(%esp)
  80128d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80128f:	83 eb 01             	sub    $0x1,%ebx
  801292:	85 db                	test   %ebx,%ebx
  801294:	7f ed                	jg     801283 <vprintfmt+0x206>
  801296:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801299:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8012a0:	eb a7                	jmp    801249 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8012a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8012a6:	74 1b                	je     8012c3 <vprintfmt+0x246>
  8012a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8012ab:	83 fa 5e             	cmp    $0x5e,%edx
  8012ae:	76 13                	jbe    8012c3 <vprintfmt+0x246>
					putch('?', putdat);
  8012b0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8012b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8012b7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8012be:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8012c1:	eb 0d                	jmp    8012d0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8012c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8012c6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012ca:	89 04 24             	mov    %eax,(%esp)
  8012cd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8012d0:	83 ef 01             	sub    $0x1,%edi
  8012d3:	0f be 03             	movsbl (%ebx),%eax
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	74 05                	je     8012df <vprintfmt+0x262>
  8012da:	83 c3 01             	add    $0x1,%ebx
  8012dd:	eb 31                	jmp    801310 <vprintfmt+0x293>
  8012df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8012e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8012e8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8012eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8012ef:	7f 36                	jg     801327 <vprintfmt+0x2aa>
  8012f1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8012f4:	e9 b0 fd ff ff       	jmp    8010a9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8012f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012fc:	83 c2 01             	add    $0x1,%edx
  8012ff:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801302:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801305:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801308:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80130b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80130e:	89 d3                	mov    %edx,%ebx
  801310:	85 f6                	test   %esi,%esi
  801312:	78 8e                	js     8012a2 <vprintfmt+0x225>
  801314:	83 ee 01             	sub    $0x1,%esi
  801317:	79 89                	jns    8012a2 <vprintfmt+0x225>
  801319:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801322:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  801325:	eb c4                	jmp    8012eb <vprintfmt+0x26e>
  801327:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80132a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80132d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801331:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801338:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80133a:	83 eb 01             	sub    $0x1,%ebx
  80133d:	85 db                	test   %ebx,%ebx
  80133f:	7f ec                	jg     80132d <vprintfmt+0x2b0>
  801341:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801344:	e9 60 fd ff ff       	jmp    8010a9 <vprintfmt+0x2c>
  801349:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80134c:	83 f9 01             	cmp    $0x1,%ecx
  80134f:	7e 16                	jle    801367 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  801351:	8b 45 14             	mov    0x14(%ebp),%eax
  801354:	8d 50 08             	lea    0x8(%eax),%edx
  801357:	89 55 14             	mov    %edx,0x14(%ebp)
  80135a:	8b 10                	mov    (%eax),%edx
  80135c:	8b 48 04             	mov    0x4(%eax),%ecx
  80135f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801362:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801365:	eb 32                	jmp    801399 <vprintfmt+0x31c>
	else if (lflag)
  801367:	85 c9                	test   %ecx,%ecx
  801369:	74 18                	je     801383 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80136b:	8b 45 14             	mov    0x14(%ebp),%eax
  80136e:	8d 50 04             	lea    0x4(%eax),%edx
  801371:	89 55 14             	mov    %edx,0x14(%ebp)
  801374:	8b 00                	mov    (%eax),%eax
  801376:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801379:	89 c1                	mov    %eax,%ecx
  80137b:	c1 f9 1f             	sar    $0x1f,%ecx
  80137e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801381:	eb 16                	jmp    801399 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  801383:	8b 45 14             	mov    0x14(%ebp),%eax
  801386:	8d 50 04             	lea    0x4(%eax),%edx
  801389:	89 55 14             	mov    %edx,0x14(%ebp)
  80138c:	8b 00                	mov    (%eax),%eax
  80138e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801391:	89 c2                	mov    %eax,%edx
  801393:	c1 fa 1f             	sar    $0x1f,%edx
  801396:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801399:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80139c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80139f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8013a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8013a8:	0f 89 8a 00 00 00    	jns    801438 <vprintfmt+0x3bb>
				putch('-', putdat);
  8013ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8013b9:	ff d7                	call   *%edi
				num = -(long long) num;
  8013bb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8013be:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8013c1:	f7 d8                	neg    %eax
  8013c3:	83 d2 00             	adc    $0x0,%edx
  8013c6:	f7 da                	neg    %edx
  8013c8:	eb 6e                	jmp    801438 <vprintfmt+0x3bb>
  8013ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8013cd:	89 ca                	mov    %ecx,%edx
  8013cf:	8d 45 14             	lea    0x14(%ebp),%eax
  8013d2:	e8 4f fc ff ff       	call   801026 <getuint>
  8013d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8013dc:	eb 5a                	jmp    801438 <vprintfmt+0x3bb>
  8013de:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8013e1:	89 ca                	mov    %ecx,%edx
  8013e3:	8d 45 14             	lea    0x14(%ebp),%eax
  8013e6:	e8 3b fc ff ff       	call   801026 <getuint>
  8013eb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8013f0:	eb 46                	jmp    801438 <vprintfmt+0x3bb>
  8013f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8013f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013f9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801400:	ff d7                	call   *%edi
			putch('x', putdat);
  801402:	89 74 24 04          	mov    %esi,0x4(%esp)
  801406:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80140d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80140f:	8b 45 14             	mov    0x14(%ebp),%eax
  801412:	8d 50 04             	lea    0x4(%eax),%edx
  801415:	89 55 14             	mov    %edx,0x14(%ebp)
  801418:	8b 00                	mov    (%eax),%eax
  80141a:	ba 00 00 00 00       	mov    $0x0,%edx
  80141f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801424:	eb 12                	jmp    801438 <vprintfmt+0x3bb>
  801426:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801429:	89 ca                	mov    %ecx,%edx
  80142b:	8d 45 14             	lea    0x14(%ebp),%eax
  80142e:	e8 f3 fb ff ff       	call   801026 <getuint>
  801433:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801438:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80143c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801440:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801443:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801447:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80144b:	89 04 24             	mov    %eax,(%esp)
  80144e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801452:	89 f2                	mov    %esi,%edx
  801454:	89 f8                	mov    %edi,%eax
  801456:	e8 d5 fa ff ff       	call   800f30 <printnum>
  80145b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80145e:	e9 46 fc ff ff       	jmp    8010a9 <vprintfmt+0x2c>
  801463:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  801466:	8b 45 14             	mov    0x14(%ebp),%eax
  801469:	8d 50 04             	lea    0x4(%eax),%edx
  80146c:	89 55 14             	mov    %edx,0x14(%ebp)
  80146f:	8b 00                	mov    (%eax),%eax
  801471:	85 c0                	test   %eax,%eax
  801473:	75 24                	jne    801499 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  801475:	c7 44 24 0c 0c 20 80 	movl   $0x80200c,0xc(%esp)
  80147c:	00 
  80147d:	c7 44 24 08 a3 1e 80 	movl   $0x801ea3,0x8(%esp)
  801484:	00 
  801485:	89 74 24 04          	mov    %esi,0x4(%esp)
  801489:	89 3c 24             	mov    %edi,(%esp)
  80148c:	e8 ff 00 00 00       	call   801590 <printfmt>
  801491:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801494:	e9 10 fc ff ff       	jmp    8010a9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  801499:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80149c:	7e 29                	jle    8014c7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80149e:	0f b6 16             	movzbl (%esi),%edx
  8014a1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8014a3:	c7 44 24 0c 44 20 80 	movl   $0x802044,0xc(%esp)
  8014aa:	00 
  8014ab:	c7 44 24 08 a3 1e 80 	movl   $0x801ea3,0x8(%esp)
  8014b2:	00 
  8014b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b7:	89 3c 24             	mov    %edi,(%esp)
  8014ba:	e8 d1 00 00 00       	call   801590 <printfmt>
  8014bf:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8014c2:	e9 e2 fb ff ff       	jmp    8010a9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8014c7:	0f b6 16             	movzbl (%esi),%edx
  8014ca:	88 10                	mov    %dl,(%eax)
  8014cc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8014cf:	e9 d5 fb ff ff       	jmp    8010a9 <vprintfmt+0x2c>
  8014d4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8014d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8014da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014de:	89 14 24             	mov    %edx,(%esp)
  8014e1:	ff d7                	call   *%edi
  8014e3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8014e6:	e9 be fb ff ff       	jmp    8010a9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8014eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014ef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8014f6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8014f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8014fb:	80 38 25             	cmpb   $0x25,(%eax)
  8014fe:	0f 84 a5 fb ff ff    	je     8010a9 <vprintfmt+0x2c>
  801504:	89 c3                	mov    %eax,%ebx
  801506:	eb f0                	jmp    8014f8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  801508:	83 c4 5c             	add    $0x5c,%esp
  80150b:	5b                   	pop    %ebx
  80150c:	5e                   	pop    %esi
  80150d:	5f                   	pop    %edi
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    

00801510 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	83 ec 28             	sub    $0x28,%esp
  801516:	8b 45 08             	mov    0x8(%ebp),%eax
  801519:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80151c:	85 c0                	test   %eax,%eax
  80151e:	74 04                	je     801524 <vsnprintf+0x14>
  801520:	85 d2                	test   %edx,%edx
  801522:	7f 07                	jg     80152b <vsnprintf+0x1b>
  801524:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801529:	eb 3b                	jmp    801566 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80152b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80152e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801532:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801535:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80153c:	8b 45 14             	mov    0x14(%ebp),%eax
  80153f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801543:	8b 45 10             	mov    0x10(%ebp),%eax
  801546:	89 44 24 08          	mov    %eax,0x8(%esp)
  80154a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80154d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801551:	c7 04 24 60 10 80 00 	movl   $0x801060,(%esp)
  801558:	e8 20 fb ff ff       	call   80107d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80155d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801560:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801563:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801566:	c9                   	leave  
  801567:	c3                   	ret    

00801568 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801568:	55                   	push   %ebp
  801569:	89 e5                	mov    %esp,%ebp
  80156b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80156e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801571:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801575:	8b 45 10             	mov    0x10(%ebp),%eax
  801578:	89 44 24 08          	mov    %eax,0x8(%esp)
  80157c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801583:	8b 45 08             	mov    0x8(%ebp),%eax
  801586:	89 04 24             	mov    %eax,(%esp)
  801589:	e8 82 ff ff ff       	call   801510 <vsnprintf>
	va_end(ap);

	return rc;
}
  80158e:	c9                   	leave  
  80158f:	c3                   	ret    

00801590 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801590:	55                   	push   %ebp
  801591:	89 e5                	mov    %esp,%ebp
  801593:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801596:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801599:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80159d:	8b 45 10             	mov    0x10(%ebp),%eax
  8015a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ae:	89 04 24             	mov    %eax,(%esp)
  8015b1:	e8 c7 fa ff ff       	call   80107d <vprintfmt>
	va_end(ap);
}
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    
	...

008015c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8015c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8015ce:	74 09                	je     8015d9 <strlen+0x19>
		n++;
  8015d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8015d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8015d7:	75 f7                	jne    8015d0 <strlen+0x10>
		n++;
	return n;
}
  8015d9:	5d                   	pop    %ebp
  8015da:	c3                   	ret    

008015db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	53                   	push   %ebx
  8015df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8015e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8015e5:	85 c9                	test   %ecx,%ecx
  8015e7:	74 19                	je     801602 <strnlen+0x27>
  8015e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8015ec:	74 14                	je     801602 <strnlen+0x27>
  8015ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8015f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8015f6:	39 c8                	cmp    %ecx,%eax
  8015f8:	74 0d                	je     801607 <strnlen+0x2c>
  8015fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8015fe:	75 f3                	jne    8015f3 <strnlen+0x18>
  801600:	eb 05                	jmp    801607 <strnlen+0x2c>
  801602:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801607:	5b                   	pop    %ebx
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	53                   	push   %ebx
  80160e:	8b 45 08             	mov    0x8(%ebp),%eax
  801611:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801614:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801619:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80161d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801620:	83 c2 01             	add    $0x1,%edx
  801623:	84 c9                	test   %cl,%cl
  801625:	75 f2                	jne    801619 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801627:	5b                   	pop    %ebx
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	53                   	push   %ebx
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801634:	89 1c 24             	mov    %ebx,(%esp)
  801637:	e8 84 ff ff ff       	call   8015c0 <strlen>
	strcpy(dst + len, src);
  80163c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801643:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 bc ff ff ff       	call   80160a <strcpy>
	return dst;
}
  80164e:	89 d8                	mov    %ebx,%eax
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	5b                   	pop    %ebx
  801654:	5d                   	pop    %ebp
  801655:	c3                   	ret    

00801656 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
  80165b:	8b 45 08             	mov    0x8(%ebp),%eax
  80165e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801661:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801664:	85 f6                	test   %esi,%esi
  801666:	74 18                	je     801680 <strncpy+0x2a>
  801668:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80166d:	0f b6 1a             	movzbl (%edx),%ebx
  801670:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801673:	80 3a 01             	cmpb   $0x1,(%edx)
  801676:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801679:	83 c1 01             	add    $0x1,%ecx
  80167c:	39 ce                	cmp    %ecx,%esi
  80167e:	77 ed                	ja     80166d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801680:	5b                   	pop    %ebx
  801681:	5e                   	pop    %esi
  801682:	5d                   	pop    %ebp
  801683:	c3                   	ret    

00801684 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
  801689:	8b 75 08             	mov    0x8(%ebp),%esi
  80168c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80168f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801692:	89 f0                	mov    %esi,%eax
  801694:	85 c9                	test   %ecx,%ecx
  801696:	74 27                	je     8016bf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801698:	83 e9 01             	sub    $0x1,%ecx
  80169b:	74 1d                	je     8016ba <strlcpy+0x36>
  80169d:	0f b6 1a             	movzbl (%edx),%ebx
  8016a0:	84 db                	test   %bl,%bl
  8016a2:	74 16                	je     8016ba <strlcpy+0x36>
			*dst++ = *src++;
  8016a4:	88 18                	mov    %bl,(%eax)
  8016a6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016a9:	83 e9 01             	sub    $0x1,%ecx
  8016ac:	74 0e                	je     8016bc <strlcpy+0x38>
			*dst++ = *src++;
  8016ae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8016b1:	0f b6 1a             	movzbl (%edx),%ebx
  8016b4:	84 db                	test   %bl,%bl
  8016b6:	75 ec                	jne    8016a4 <strlcpy+0x20>
  8016b8:	eb 02                	jmp    8016bc <strlcpy+0x38>
  8016ba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8016bc:	c6 00 00             	movb   $0x0,(%eax)
  8016bf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8016ce:	0f b6 01             	movzbl (%ecx),%eax
  8016d1:	84 c0                	test   %al,%al
  8016d3:	74 15                	je     8016ea <strcmp+0x25>
  8016d5:	3a 02                	cmp    (%edx),%al
  8016d7:	75 11                	jne    8016ea <strcmp+0x25>
		p++, q++;
  8016d9:	83 c1 01             	add    $0x1,%ecx
  8016dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8016df:	0f b6 01             	movzbl (%ecx),%eax
  8016e2:	84 c0                	test   %al,%al
  8016e4:	74 04                	je     8016ea <strcmp+0x25>
  8016e6:	3a 02                	cmp    (%edx),%al
  8016e8:	74 ef                	je     8016d9 <strcmp+0x14>
  8016ea:	0f b6 c0             	movzbl %al,%eax
  8016ed:	0f b6 12             	movzbl (%edx),%edx
  8016f0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8016f2:	5d                   	pop    %ebp
  8016f3:	c3                   	ret    

008016f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	53                   	push   %ebx
  8016f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8016fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801701:	85 c0                	test   %eax,%eax
  801703:	74 23                	je     801728 <strncmp+0x34>
  801705:	0f b6 1a             	movzbl (%edx),%ebx
  801708:	84 db                	test   %bl,%bl
  80170a:	74 25                	je     801731 <strncmp+0x3d>
  80170c:	3a 19                	cmp    (%ecx),%bl
  80170e:	75 21                	jne    801731 <strncmp+0x3d>
  801710:	83 e8 01             	sub    $0x1,%eax
  801713:	74 13                	je     801728 <strncmp+0x34>
		n--, p++, q++;
  801715:	83 c2 01             	add    $0x1,%edx
  801718:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80171b:	0f b6 1a             	movzbl (%edx),%ebx
  80171e:	84 db                	test   %bl,%bl
  801720:	74 0f                	je     801731 <strncmp+0x3d>
  801722:	3a 19                	cmp    (%ecx),%bl
  801724:	74 ea                	je     801710 <strncmp+0x1c>
  801726:	eb 09                	jmp    801731 <strncmp+0x3d>
  801728:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80172d:	5b                   	pop    %ebx
  80172e:	5d                   	pop    %ebp
  80172f:	90                   	nop
  801730:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801731:	0f b6 02             	movzbl (%edx),%eax
  801734:	0f b6 11             	movzbl (%ecx),%edx
  801737:	29 d0                	sub    %edx,%eax
  801739:	eb f2                	jmp    80172d <strncmp+0x39>

0080173b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	8b 45 08             	mov    0x8(%ebp),%eax
  801741:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801745:	0f b6 10             	movzbl (%eax),%edx
  801748:	84 d2                	test   %dl,%dl
  80174a:	74 18                	je     801764 <strchr+0x29>
		if (*s == c)
  80174c:	38 ca                	cmp    %cl,%dl
  80174e:	75 0a                	jne    80175a <strchr+0x1f>
  801750:	eb 17                	jmp    801769 <strchr+0x2e>
  801752:	38 ca                	cmp    %cl,%dl
  801754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801758:	74 0f                	je     801769 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80175a:	83 c0 01             	add    $0x1,%eax
  80175d:	0f b6 10             	movzbl (%eax),%edx
  801760:	84 d2                	test   %dl,%dl
  801762:	75 ee                	jne    801752 <strchr+0x17>
  801764:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	8b 45 08             	mov    0x8(%ebp),%eax
  801771:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801775:	0f b6 10             	movzbl (%eax),%edx
  801778:	84 d2                	test   %dl,%dl
  80177a:	74 18                	je     801794 <strfind+0x29>
		if (*s == c)
  80177c:	38 ca                	cmp    %cl,%dl
  80177e:	75 0a                	jne    80178a <strfind+0x1f>
  801780:	eb 12                	jmp    801794 <strfind+0x29>
  801782:	38 ca                	cmp    %cl,%dl
  801784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801788:	74 0a                	je     801794 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80178a:	83 c0 01             	add    $0x1,%eax
  80178d:	0f b6 10             	movzbl (%eax),%edx
  801790:	84 d2                	test   %dl,%dl
  801792:	75 ee                	jne    801782 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	83 ec 0c             	sub    $0xc,%esp
  80179c:	89 1c 24             	mov    %ebx,(%esp)
  80179f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017a3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8017a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017b0:	85 c9                	test   %ecx,%ecx
  8017b2:	74 30                	je     8017e4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017ba:	75 25                	jne    8017e1 <memset+0x4b>
  8017bc:	f6 c1 03             	test   $0x3,%cl
  8017bf:	75 20                	jne    8017e1 <memset+0x4b>
		c &= 0xFF;
  8017c1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8017c4:	89 d3                	mov    %edx,%ebx
  8017c6:	c1 e3 08             	shl    $0x8,%ebx
  8017c9:	89 d6                	mov    %edx,%esi
  8017cb:	c1 e6 18             	shl    $0x18,%esi
  8017ce:	89 d0                	mov    %edx,%eax
  8017d0:	c1 e0 10             	shl    $0x10,%eax
  8017d3:	09 f0                	or     %esi,%eax
  8017d5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8017d7:	09 d8                	or     %ebx,%eax
  8017d9:	c1 e9 02             	shr    $0x2,%ecx
  8017dc:	fc                   	cld    
  8017dd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017df:	eb 03                	jmp    8017e4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8017e1:	fc                   	cld    
  8017e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8017e4:	89 f8                	mov    %edi,%eax
  8017e6:	8b 1c 24             	mov    (%esp),%ebx
  8017e9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8017ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8017f1:	89 ec                	mov    %ebp,%esp
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	83 ec 08             	sub    $0x8,%esp
  8017fb:	89 34 24             	mov    %esi,(%esp)
  8017fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801808:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80180b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80180d:	39 c6                	cmp    %eax,%esi
  80180f:	73 35                	jae    801846 <memmove+0x51>
  801811:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801814:	39 d0                	cmp    %edx,%eax
  801816:	73 2e                	jae    801846 <memmove+0x51>
		s += n;
		d += n;
  801818:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80181a:	f6 c2 03             	test   $0x3,%dl
  80181d:	75 1b                	jne    80183a <memmove+0x45>
  80181f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801825:	75 13                	jne    80183a <memmove+0x45>
  801827:	f6 c1 03             	test   $0x3,%cl
  80182a:	75 0e                	jne    80183a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80182c:	83 ef 04             	sub    $0x4,%edi
  80182f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801832:	c1 e9 02             	shr    $0x2,%ecx
  801835:	fd                   	std    
  801836:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801838:	eb 09                	jmp    801843 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80183a:	83 ef 01             	sub    $0x1,%edi
  80183d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801840:	fd                   	std    
  801841:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801843:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801844:	eb 20                	jmp    801866 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801846:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80184c:	75 15                	jne    801863 <memmove+0x6e>
  80184e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801854:	75 0d                	jne    801863 <memmove+0x6e>
  801856:	f6 c1 03             	test   $0x3,%cl
  801859:	75 08                	jne    801863 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80185b:	c1 e9 02             	shr    $0x2,%ecx
  80185e:	fc                   	cld    
  80185f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801861:	eb 03                	jmp    801866 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801863:	fc                   	cld    
  801864:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801866:	8b 34 24             	mov    (%esp),%esi
  801869:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80186d:	89 ec                	mov    %ebp,%esp
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801877:	8b 45 10             	mov    0x10(%ebp),%eax
  80187a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801881:	89 44 24 04          	mov    %eax,0x4(%esp)
  801885:	8b 45 08             	mov    0x8(%ebp),%eax
  801888:	89 04 24             	mov    %eax,(%esp)
  80188b:	e8 65 ff ff ff       	call   8017f5 <memmove>
}
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	57                   	push   %edi
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	8b 75 08             	mov    0x8(%ebp),%esi
  80189b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80189e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018a1:	85 c9                	test   %ecx,%ecx
  8018a3:	74 36                	je     8018db <memcmp+0x49>
		if (*s1 != *s2)
  8018a5:	0f b6 06             	movzbl (%esi),%eax
  8018a8:	0f b6 1f             	movzbl (%edi),%ebx
  8018ab:	38 d8                	cmp    %bl,%al
  8018ad:	74 20                	je     8018cf <memcmp+0x3d>
  8018af:	eb 14                	jmp    8018c5 <memcmp+0x33>
  8018b1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8018b6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8018bb:	83 c2 01             	add    $0x1,%edx
  8018be:	83 e9 01             	sub    $0x1,%ecx
  8018c1:	38 d8                	cmp    %bl,%al
  8018c3:	74 12                	je     8018d7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8018c5:	0f b6 c0             	movzbl %al,%eax
  8018c8:	0f b6 db             	movzbl %bl,%ebx
  8018cb:	29 d8                	sub    %ebx,%eax
  8018cd:	eb 11                	jmp    8018e0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cf:	83 e9 01             	sub    $0x1,%ecx
  8018d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d7:	85 c9                	test   %ecx,%ecx
  8018d9:	75 d6                	jne    8018b1 <memcmp+0x1f>
  8018db:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5f                   	pop    %edi
  8018e3:	5d                   	pop    %ebp
  8018e4:	c3                   	ret    

008018e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8018eb:	89 c2                	mov    %eax,%edx
  8018ed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018f0:	39 d0                	cmp    %edx,%eax
  8018f2:	73 15                	jae    801909 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8018f8:	38 08                	cmp    %cl,(%eax)
  8018fa:	75 06                	jne    801902 <memfind+0x1d>
  8018fc:	eb 0b                	jmp    801909 <memfind+0x24>
  8018fe:	38 08                	cmp    %cl,(%eax)
  801900:	74 07                	je     801909 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801902:	83 c0 01             	add    $0x1,%eax
  801905:	39 c2                	cmp    %eax,%edx
  801907:	77 f5                	ja     8018fe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	57                   	push   %edi
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	83 ec 04             	sub    $0x4,%esp
  801914:	8b 55 08             	mov    0x8(%ebp),%edx
  801917:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191a:	0f b6 02             	movzbl (%edx),%eax
  80191d:	3c 20                	cmp    $0x20,%al
  80191f:	74 04                	je     801925 <strtol+0x1a>
  801921:	3c 09                	cmp    $0x9,%al
  801923:	75 0e                	jne    801933 <strtol+0x28>
		s++;
  801925:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801928:	0f b6 02             	movzbl (%edx),%eax
  80192b:	3c 20                	cmp    $0x20,%al
  80192d:	74 f6                	je     801925 <strtol+0x1a>
  80192f:	3c 09                	cmp    $0x9,%al
  801931:	74 f2                	je     801925 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801933:	3c 2b                	cmp    $0x2b,%al
  801935:	75 0c                	jne    801943 <strtol+0x38>
		s++;
  801937:	83 c2 01             	add    $0x1,%edx
  80193a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801941:	eb 15                	jmp    801958 <strtol+0x4d>
	else if (*s == '-')
  801943:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80194a:	3c 2d                	cmp    $0x2d,%al
  80194c:	75 0a                	jne    801958 <strtol+0x4d>
		s++, neg = 1;
  80194e:	83 c2 01             	add    $0x1,%edx
  801951:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801958:	85 db                	test   %ebx,%ebx
  80195a:	0f 94 c0             	sete   %al
  80195d:	74 05                	je     801964 <strtol+0x59>
  80195f:	83 fb 10             	cmp    $0x10,%ebx
  801962:	75 18                	jne    80197c <strtol+0x71>
  801964:	80 3a 30             	cmpb   $0x30,(%edx)
  801967:	75 13                	jne    80197c <strtol+0x71>
  801969:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80196d:	8d 76 00             	lea    0x0(%esi),%esi
  801970:	75 0a                	jne    80197c <strtol+0x71>
		s += 2, base = 16;
  801972:	83 c2 02             	add    $0x2,%edx
  801975:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197a:	eb 15                	jmp    801991 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80197c:	84 c0                	test   %al,%al
  80197e:	66 90                	xchg   %ax,%ax
  801980:	74 0f                	je     801991 <strtol+0x86>
  801982:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801987:	80 3a 30             	cmpb   $0x30,(%edx)
  80198a:	75 05                	jne    801991 <strtol+0x86>
		s++, base = 8;
  80198c:	83 c2 01             	add    $0x1,%edx
  80198f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
  801996:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801998:	0f b6 0a             	movzbl (%edx),%ecx
  80199b:	89 cf                	mov    %ecx,%edi
  80199d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8019a0:	80 fb 09             	cmp    $0x9,%bl
  8019a3:	77 08                	ja     8019ad <strtol+0xa2>
			dig = *s - '0';
  8019a5:	0f be c9             	movsbl %cl,%ecx
  8019a8:	83 e9 30             	sub    $0x30,%ecx
  8019ab:	eb 1e                	jmp    8019cb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8019ad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8019b0:	80 fb 19             	cmp    $0x19,%bl
  8019b3:	77 08                	ja     8019bd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8019b5:	0f be c9             	movsbl %cl,%ecx
  8019b8:	83 e9 57             	sub    $0x57,%ecx
  8019bb:	eb 0e                	jmp    8019cb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8019bd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8019c0:	80 fb 19             	cmp    $0x19,%bl
  8019c3:	77 15                	ja     8019da <strtol+0xcf>
			dig = *s - 'A' + 10;
  8019c5:	0f be c9             	movsbl %cl,%ecx
  8019c8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8019cb:	39 f1                	cmp    %esi,%ecx
  8019cd:	7d 0b                	jge    8019da <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8019cf:	83 c2 01             	add    $0x1,%edx
  8019d2:	0f af c6             	imul   %esi,%eax
  8019d5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8019d8:	eb be                	jmp    801998 <strtol+0x8d>
  8019da:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8019dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e0:	74 05                	je     8019e7 <strtol+0xdc>
		*endptr = (char *) s;
  8019e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8019e7:	89 ca                	mov    %ecx,%edx
  8019e9:	f7 da                	neg    %edx
  8019eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8019ef:	0f 45 c2             	cmovne %edx,%eax
}
  8019f2:	83 c4 04             	add    $0x4,%esp
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    
  8019fa:	00 00                	add    %al,(%eax)
  8019fc:	00 00                	add    %al,(%eax)
	...

00801a00 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a06:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801a0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a11:	39 ca                	cmp    %ecx,%edx
  801a13:	75 04                	jne    801a19 <ipc_find_env+0x19>
  801a15:	b0 00                	mov    $0x0,%al
  801a17:	eb 0f                	jmp    801a28 <ipc_find_env+0x28>
  801a19:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a1c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801a22:	8b 12                	mov    (%edx),%edx
  801a24:	39 ca                	cmp    %ecx,%edx
  801a26:	75 0c                	jne    801a34 <ipc_find_env+0x34>
			return envs[i].env_id;
  801a28:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a2b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801a30:	8b 00                	mov    (%eax),%eax
  801a32:	eb 0e                	jmp    801a42 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a34:	83 c0 01             	add    $0x1,%eax
  801a37:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a3c:	75 db                	jne    801a19 <ipc_find_env+0x19>
  801a3e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 1c             	sub    $0x1c,%esp
  801a4d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a50:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a56:	85 db                	test   %ebx,%ebx
  801a58:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a5d:	0f 44 d8             	cmove  %eax,%ebx
  801a60:	eb 29                	jmp    801a8b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801a62:	85 c0                	test   %eax,%eax
  801a64:	79 25                	jns    801a8b <ipc_send+0x47>
  801a66:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a69:	74 20                	je     801a8b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801a6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a6f:	c7 44 24 08 60 22 80 	movl   $0x802260,0x8(%esp)
  801a76:	00 
  801a77:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801a7e:	00 
  801a7f:	c7 04 24 7e 22 80 00 	movl   $0x80227e,(%esp)
  801a86:	e8 85 f3 ff ff       	call   800e10 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801a8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a96:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a9a:	89 34 24             	mov    %esi,(%esp)
  801a9d:	e8 99 e7 ff ff       	call   80023b <sys_ipc_try_send>
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	75 bc                	jne    801a62 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801aa6:	e8 16 e9 ff ff       	call   8003c1 <sys_yield>
}
  801aab:	83 c4 1c             	add    $0x1c,%esp
  801aae:	5b                   	pop    %ebx
  801aaf:	5e                   	pop    %esi
  801ab0:	5f                   	pop    %edi
  801ab1:	5d                   	pop    %ebp
  801ab2:	c3                   	ret    

00801ab3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ab3:	55                   	push   %ebp
  801ab4:	89 e5                	mov    %esp,%ebp
  801ab6:	83 ec 28             	sub    $0x28,%esp
  801ab9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801abc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801abf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ac2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ac5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ac8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801acb:	85 c0                	test   %eax,%eax
  801acd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ad2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801ad5:	89 04 24             	mov    %eax,(%esp)
  801ad8:	e8 25 e7 ff ff       	call   800202 <sys_ipc_recv>
  801add:	89 c3                	mov    %eax,%ebx
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	79 2a                	jns    801b0d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801ae3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aeb:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  801af2:	e8 d2 f3 ff ff       	call   800ec9 <cprintf>
		if(from_env_store != NULL)
  801af7:	85 f6                	test   %esi,%esi
  801af9:	74 06                	je     801b01 <ipc_recv+0x4e>
			*from_env_store = 0;
  801afb:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b01:	85 ff                	test   %edi,%edi
  801b03:	74 2d                	je     801b32 <ipc_recv+0x7f>
			*perm_store = 0;
  801b05:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b0b:	eb 25                	jmp    801b32 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801b0d:	85 f6                	test   %esi,%esi
  801b0f:	90                   	nop
  801b10:	74 0a                	je     801b1c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801b12:	a1 20 60 80 00       	mov    0x806020,%eax
  801b17:	8b 40 74             	mov    0x74(%eax),%eax
  801b1a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b1c:	85 ff                	test   %edi,%edi
  801b1e:	74 0a                	je     801b2a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801b20:	a1 20 60 80 00       	mov    0x806020,%eax
  801b25:	8b 40 78             	mov    0x78(%eax),%eax
  801b28:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b2a:	a1 20 60 80 00       	mov    0x806020,%eax
  801b2f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801b32:	89 d8                	mov    %ebx,%eax
  801b34:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b37:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b3a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b3d:	89 ec                	mov    %ebp,%esp
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    
	...

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	57                   	push   %edi
  801b54:	56                   	push   %esi
  801b55:	83 ec 10             	sub    $0x10,%esp
  801b58:	8b 45 14             	mov    0x14(%ebp),%eax
  801b5b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b5e:	8b 75 10             	mov    0x10(%ebp),%esi
  801b61:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b64:	85 c0                	test   %eax,%eax
  801b66:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801b69:	75 35                	jne    801ba0 <__udivdi3+0x50>
  801b6b:	39 fe                	cmp    %edi,%esi
  801b6d:	77 61                	ja     801bd0 <__udivdi3+0x80>
  801b6f:	85 f6                	test   %esi,%esi
  801b71:	75 0b                	jne    801b7e <__udivdi3+0x2e>
  801b73:	b8 01 00 00 00       	mov    $0x1,%eax
  801b78:	31 d2                	xor    %edx,%edx
  801b7a:	f7 f6                	div    %esi
  801b7c:	89 c6                	mov    %eax,%esi
  801b7e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801b81:	31 d2                	xor    %edx,%edx
  801b83:	89 f8                	mov    %edi,%eax
  801b85:	f7 f6                	div    %esi
  801b87:	89 c7                	mov    %eax,%edi
  801b89:	89 c8                	mov    %ecx,%eax
  801b8b:	f7 f6                	div    %esi
  801b8d:	89 c1                	mov    %eax,%ecx
  801b8f:	89 fa                	mov    %edi,%edx
  801b91:	89 c8                	mov    %ecx,%eax
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    
  801b9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ba0:	39 f8                	cmp    %edi,%eax
  801ba2:	77 1c                	ja     801bc0 <__udivdi3+0x70>
  801ba4:	0f bd d0             	bsr    %eax,%edx
  801ba7:	83 f2 1f             	xor    $0x1f,%edx
  801baa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801bad:	75 39                	jne    801be8 <__udivdi3+0x98>
  801baf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801bb2:	0f 86 a0 00 00 00    	jbe    801c58 <__udivdi3+0x108>
  801bb8:	39 f8                	cmp    %edi,%eax
  801bba:	0f 82 98 00 00 00    	jb     801c58 <__udivdi3+0x108>
  801bc0:	31 ff                	xor    %edi,%edi
  801bc2:	31 c9                	xor    %ecx,%ecx
  801bc4:	89 c8                	mov    %ecx,%eax
  801bc6:	89 fa                	mov    %edi,%edx
  801bc8:	83 c4 10             	add    $0x10,%esp
  801bcb:	5e                   	pop    %esi
  801bcc:	5f                   	pop    %edi
  801bcd:	5d                   	pop    %ebp
  801bce:	c3                   	ret    
  801bcf:	90                   	nop
  801bd0:	89 d1                	mov    %edx,%ecx
  801bd2:	89 fa                	mov    %edi,%edx
  801bd4:	89 c8                	mov    %ecx,%eax
  801bd6:	31 ff                	xor    %edi,%edi
  801bd8:	f7 f6                	div    %esi
  801bda:	89 c1                	mov    %eax,%ecx
  801bdc:	89 fa                	mov    %edi,%edx
  801bde:	89 c8                	mov    %ecx,%eax
  801be0:	83 c4 10             	add    $0x10,%esp
  801be3:	5e                   	pop    %esi
  801be4:	5f                   	pop    %edi
  801be5:	5d                   	pop    %ebp
  801be6:	c3                   	ret    
  801be7:	90                   	nop
  801be8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bec:	89 f2                	mov    %esi,%edx
  801bee:	d3 e0                	shl    %cl,%eax
  801bf0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bf3:	b8 20 00 00 00       	mov    $0x20,%eax
  801bf8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801bfb:	89 c1                	mov    %eax,%ecx
  801bfd:	d3 ea                	shr    %cl,%edx
  801bff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c03:	0b 55 ec             	or     -0x14(%ebp),%edx
  801c06:	d3 e6                	shl    %cl,%esi
  801c08:	89 c1                	mov    %eax,%ecx
  801c0a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801c0d:	89 fe                	mov    %edi,%esi
  801c0f:	d3 ee                	shr    %cl,%esi
  801c11:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c15:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c1b:	d3 e7                	shl    %cl,%edi
  801c1d:	89 c1                	mov    %eax,%ecx
  801c1f:	d3 ea                	shr    %cl,%edx
  801c21:	09 d7                	or     %edx,%edi
  801c23:	89 f2                	mov    %esi,%edx
  801c25:	89 f8                	mov    %edi,%eax
  801c27:	f7 75 ec             	divl   -0x14(%ebp)
  801c2a:	89 d6                	mov    %edx,%esi
  801c2c:	89 c7                	mov    %eax,%edi
  801c2e:	f7 65 e8             	mull   -0x18(%ebp)
  801c31:	39 d6                	cmp    %edx,%esi
  801c33:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c36:	72 30                	jb     801c68 <__udivdi3+0x118>
  801c38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c3b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c3f:	d3 e2                	shl    %cl,%edx
  801c41:	39 c2                	cmp    %eax,%edx
  801c43:	73 05                	jae    801c4a <__udivdi3+0xfa>
  801c45:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801c48:	74 1e                	je     801c68 <__udivdi3+0x118>
  801c4a:	89 f9                	mov    %edi,%ecx
  801c4c:	31 ff                	xor    %edi,%edi
  801c4e:	e9 71 ff ff ff       	jmp    801bc4 <__udivdi3+0x74>
  801c53:	90                   	nop
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	31 ff                	xor    %edi,%edi
  801c5a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801c5f:	e9 60 ff ff ff       	jmp    801bc4 <__udivdi3+0x74>
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801c6b:	31 ff                	xor    %edi,%edi
  801c6d:	89 c8                	mov    %ecx,%eax
  801c6f:	89 fa                	mov    %edi,%edx
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
	...

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	57                   	push   %edi
  801c84:	56                   	push   %esi
  801c85:	83 ec 20             	sub    $0x20,%esp
  801c88:	8b 55 14             	mov    0x14(%ebp),%edx
  801c8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c91:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c94:	85 d2                	test   %edx,%edx
  801c96:	89 c8                	mov    %ecx,%eax
  801c98:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c9b:	75 13                	jne    801cb0 <__umoddi3+0x30>
  801c9d:	39 f7                	cmp    %esi,%edi
  801c9f:	76 3f                	jbe    801ce0 <__umoddi3+0x60>
  801ca1:	89 f2                	mov    %esi,%edx
  801ca3:	f7 f7                	div    %edi
  801ca5:	89 d0                	mov    %edx,%eax
  801ca7:	31 d2                	xor    %edx,%edx
  801ca9:	83 c4 20             	add    $0x20,%esp
  801cac:	5e                   	pop    %esi
  801cad:	5f                   	pop    %edi
  801cae:	5d                   	pop    %ebp
  801caf:	c3                   	ret    
  801cb0:	39 f2                	cmp    %esi,%edx
  801cb2:	77 4c                	ja     801d00 <__umoddi3+0x80>
  801cb4:	0f bd ca             	bsr    %edx,%ecx
  801cb7:	83 f1 1f             	xor    $0x1f,%ecx
  801cba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801cbd:	75 51                	jne    801d10 <__umoddi3+0x90>
  801cbf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801cc2:	0f 87 e0 00 00 00    	ja     801da8 <__umoddi3+0x128>
  801cc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ccb:	29 f8                	sub    %edi,%eax
  801ccd:	19 d6                	sbb    %edx,%esi
  801ccf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd5:	89 f2                	mov    %esi,%edx
  801cd7:	83 c4 20             	add    $0x20,%esp
  801cda:	5e                   	pop    %esi
  801cdb:	5f                   	pop    %edi
  801cdc:	5d                   	pop    %ebp
  801cdd:	c3                   	ret    
  801cde:	66 90                	xchg   %ax,%ax
  801ce0:	85 ff                	test   %edi,%edi
  801ce2:	75 0b                	jne    801cef <__umoddi3+0x6f>
  801ce4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce9:	31 d2                	xor    %edx,%edx
  801ceb:	f7 f7                	div    %edi
  801ced:	89 c7                	mov    %eax,%edi
  801cef:	89 f0                	mov    %esi,%eax
  801cf1:	31 d2                	xor    %edx,%edx
  801cf3:	f7 f7                	div    %edi
  801cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf8:	f7 f7                	div    %edi
  801cfa:	eb a9                	jmp    801ca5 <__umoddi3+0x25>
  801cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	83 c4 20             	add    $0x20,%esp
  801d07:	5e                   	pop    %esi
  801d08:	5f                   	pop    %edi
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    
  801d0b:	90                   	nop
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d14:	d3 e2                	shl    %cl,%edx
  801d16:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d19:	ba 20 00 00 00       	mov    $0x20,%edx
  801d1e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801d21:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d24:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d28:	89 fa                	mov    %edi,%edx
  801d2a:	d3 ea                	shr    %cl,%edx
  801d2c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d30:	0b 55 f4             	or     -0xc(%ebp),%edx
  801d33:	d3 e7                	shl    %cl,%edi
  801d35:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d39:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d3c:	89 f2                	mov    %esi,%edx
  801d3e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801d41:	89 c7                	mov    %eax,%edi
  801d43:	d3 ea                	shr    %cl,%edx
  801d45:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d49:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801d4c:	89 c2                	mov    %eax,%edx
  801d4e:	d3 e6                	shl    %cl,%esi
  801d50:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d54:	d3 ea                	shr    %cl,%edx
  801d56:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d5a:	09 d6                	or     %edx,%esi
  801d5c:	89 f0                	mov    %esi,%eax
  801d5e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801d61:	d3 e7                	shl    %cl,%edi
  801d63:	89 f2                	mov    %esi,%edx
  801d65:	f7 75 f4             	divl   -0xc(%ebp)
  801d68:	89 d6                	mov    %edx,%esi
  801d6a:	f7 65 e8             	mull   -0x18(%ebp)
  801d6d:	39 d6                	cmp    %edx,%esi
  801d6f:	72 2b                	jb     801d9c <__umoddi3+0x11c>
  801d71:	39 c7                	cmp    %eax,%edi
  801d73:	72 23                	jb     801d98 <__umoddi3+0x118>
  801d75:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d79:	29 c7                	sub    %eax,%edi
  801d7b:	19 d6                	sbb    %edx,%esi
  801d7d:	89 f0                	mov    %esi,%eax
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	d3 ef                	shr    %cl,%edi
  801d83:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d87:	d3 e0                	shl    %cl,%eax
  801d89:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d8d:	09 f8                	or     %edi,%eax
  801d8f:	d3 ea                	shr    %cl,%edx
  801d91:	83 c4 20             	add    $0x20,%esp
  801d94:	5e                   	pop    %esi
  801d95:	5f                   	pop    %edi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    
  801d98:	39 d6                	cmp    %edx,%esi
  801d9a:	75 d9                	jne    801d75 <__umoddi3+0xf5>
  801d9c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801d9f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801da2:	eb d1                	jmp    801d75 <__umoddi3+0xf5>
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	39 f2                	cmp    %esi,%edx
  801daa:	0f 82 18 ff ff ff    	jb     801cc8 <__umoddi3+0x48>
  801db0:	e9 1d ff ff ff       	jmp    801cd2 <__umoddi3+0x52>
