
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
  8000a4:	e8 c6 03 00 00       	call   80046f <sys_map_kernel_page>
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
  800132:	e8 70 03 00 00       	call   8004a7 <sys_getenvid>
  800137:	25 ff 03 00 00       	and    $0x3ff,%eax
  80013c:	c1 e0 07             	shl    $0x7,%eax
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
  800176:	e8 fe 08 00 00       	call   800a79 <close_all>
	sys_env_destroy(0);
  80017b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800182:	e8 5b 03 00 00       	call   8004e2 <sys_env_destroy>
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
  8001d7:	c7 44 24 08 8a 23 80 	movl   $0x80238a,0x8(%esp)
  8001de:	00 
  8001df:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001e6:	00 
  8001e7:	c7 04 24 a7 23 80 00 	movl   $0x8023a7,(%esp)
  8001ee:	e8 91 11 00 00       	call   801384 <_panic>

	return ret;
}
  8001f3:	89 d0                	mov    %edx,%eax
  8001f5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001f8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001fb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001fe:	89 ec                	mov    %ebp,%esp
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020f:	00 
  800210:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800217:	00 
  800218:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80021f:	00 
  800220:	8b 45 0c             	mov    0xc(%ebp),%eax
  800223:	89 04 24             	mov    %eax,(%esp)
  800226:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800229:	ba 00 00 00 00       	mov    $0x0,%edx
  80022e:	b8 10 00 00 00       	mov    $0x10,%eax
  800233:	e8 54 ff ff ff       	call   80018c <syscall>
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800240:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800247:	00 
  800248:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80024f:	00 
  800250:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800257:	00 
  800258:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80025f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800264:	ba 00 00 00 00       	mov    $0x0,%edx
  800269:	b8 0f 00 00 00       	mov    $0xf,%eax
  80026e:	e8 19 ff ff ff       	call   80018c <syscall>
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80027b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800282:	00 
  800283:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80028a:	00 
  80028b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800292:	00 
  800293:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80029a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029d:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8002a7:	e8 e0 fe ff ff       	call   80018c <syscall>
}
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002bb:	00 
  8002bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002dd:	e8 aa fe ff ff       	call   80018c <syscall>
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8002ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800301:	00 
  800302:	8b 45 0c             	mov    0xc(%ebp),%eax
  800305:	89 04 24             	mov    %eax,(%esp)
  800308:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80030b:	ba 01 00 00 00       	mov    $0x1,%edx
  800310:	b8 0b 00 00 00       	mov    $0xb,%eax
  800315:	e8 72 fe ff ff       	call   80018c <syscall>
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800322:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800329:	00 
  80032a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800331:	00 
  800332:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800339:	00 
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800343:	ba 01 00 00 00       	mov    $0x1,%edx
  800348:	b8 0a 00 00 00       	mov    $0xa,%eax
  80034d:	e8 3a fe ff ff       	call   80018c <syscall>
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80035a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800361:	00 
  800362:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800369:	00 
  80036a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800371:	00 
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	ba 01 00 00 00       	mov    $0x1,%edx
  800380:	b8 09 00 00 00       	mov    $0x9,%eax
  800385:	e8 02 fe ff ff       	call   80018c <syscall>
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800392:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800399:	00 
  80039a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003a9:	00 
  8003aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ad:	89 04 24             	mov    %eax,(%esp)
  8003b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b3:	ba 01 00 00 00       	mov    $0x1,%edx
  8003b8:	b8 07 00 00 00       	mov    $0x7,%eax
  8003bd:	e8 ca fd ff ff       	call   80018c <syscall>
}
  8003c2:	c9                   	leave  
  8003c3:	c3                   	ret    

008003c4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8003ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003d1:	00 
  8003d2:	8b 45 18             	mov    0x18(%ebp),%eax
  8003d5:	0b 45 14             	or     0x14(%ebp),%eax
  8003d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8003df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e6:	89 04 24             	mov    %eax,(%esp)
  8003e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ec:	ba 01 00 00 00       	mov    $0x1,%edx
  8003f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8003f6:	e8 91 fd ff ff       	call   80018c <syscall>
}
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800403:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040a:	00 
  80040b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800412:	00 
  800413:	8b 45 10             	mov    0x10(%ebp),%eax
  800416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80041a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041d:	89 04 24             	mov    %eax,(%esp)
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	ba 01 00 00 00       	mov    $0x1,%edx
  800428:	b8 05 00 00 00       	mov    $0x5,%eax
  80042d:	e8 5a fd ff ff       	call   80018c <syscall>
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80043a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800441:	00 
  800442:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800459:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045e:	ba 00 00 00 00       	mov    $0x0,%edx
  800463:	b8 0c 00 00 00       	mov    $0xc,%eax
  800468:	e8 1f fd ff ff       	call   80018c <syscall>
}
  80046d:	c9                   	leave  
  80046e:	c3                   	ret    

0080046f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800475:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80047c:	00 
  80047d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800484:	00 
  800485:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80048c:	00 
  80048d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800490:	89 04 24             	mov    %eax,(%esp)
  800493:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800496:	ba 00 00 00 00       	mov    $0x0,%edx
  80049b:	b8 04 00 00 00       	mov    $0x4,%eax
  8004a0:	e8 e7 fc ff ff       	call   80018c <syscall>
}
  8004a5:	c9                   	leave  
  8004a6:	c3                   	ret    

008004a7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8004a7:	55                   	push   %ebp
  8004a8:	89 e5                	mov    %esp,%ebp
  8004aa:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8004ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004b4:	00 
  8004b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004bc:	00 
  8004bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004c4:	00 
  8004c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8004cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	b8 02 00 00 00       	mov    $0x2,%eax
  8004db:	e8 ac fc ff ff       	call   80018c <syscall>
}
  8004e0:	c9                   	leave  
  8004e1:	c3                   	ret    

008004e2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8004e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ef:	00 
  8004f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004f7:	00 
  8004f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004ff:	00 
  800500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800507:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80050a:	ba 01 00 00 00       	mov    $0x1,%edx
  80050f:	b8 03 00 00 00       	mov    $0x3,%eax
  800514:	e8 73 fc ff ff       	call   80018c <syscall>
}
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800521:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800528:	00 
  800529:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800530:	00 
  800531:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800538:	00 
  800539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800540:	b9 00 00 00 00       	mov    $0x0,%ecx
  800545:	ba 00 00 00 00       	mov    $0x0,%edx
  80054a:	b8 01 00 00 00       	mov    $0x1,%eax
  80054f:	e8 38 fc ff ff       	call   80018c <syscall>
}
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80055c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800563:	00 
  800564:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80056b:	00 
  80056c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800573:	00 
  800574:	8b 45 0c             	mov    0xc(%ebp),%eax
  800577:	89 04 24             	mov    %eax,(%esp)
  80057a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80057d:	ba 00 00 00 00       	mov    $0x0,%edx
  800582:	b8 00 00 00 00       	mov    $0x0,%eax
  800587:	e8 00 fc ff ff       	call   80018c <syscall>
}
  80058c:	c9                   	leave  
  80058d:	c3                   	ret    
	...

00800590 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	8b 45 08             	mov    0x8(%ebp),%eax
  800596:	05 00 00 00 30       	add    $0x30000000,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80059e:	5d                   	pop    %ebp
  80059f:	c3                   	ret    

008005a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8005a0:	55                   	push   %ebp
  8005a1:	89 e5                	mov    %esp,%ebp
  8005a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8005a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	e8 df ff ff ff       	call   800590 <fd2num>
  8005b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8005b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8005b9:	c9                   	leave  
  8005ba:	c3                   	ret    

008005bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8005bb:	55                   	push   %ebp
  8005bc:	89 e5                	mov    %esp,%ebp
  8005be:	57                   	push   %edi
  8005bf:	56                   	push   %esi
  8005c0:	53                   	push   %ebx
  8005c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8005c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8005c9:	a8 01                	test   $0x1,%al
  8005cb:	74 36                	je     800603 <fd_alloc+0x48>
  8005cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8005d2:	a8 01                	test   $0x1,%al
  8005d4:	74 2d                	je     800603 <fd_alloc+0x48>
  8005d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8005db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8005e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8005e5:	89 c3                	mov    %eax,%ebx
  8005e7:	89 c2                	mov    %eax,%edx
  8005e9:	c1 ea 16             	shr    $0x16,%edx
  8005ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8005ef:	f6 c2 01             	test   $0x1,%dl
  8005f2:	74 14                	je     800608 <fd_alloc+0x4d>
  8005f4:	89 c2                	mov    %eax,%edx
  8005f6:	c1 ea 0c             	shr    $0xc,%edx
  8005f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8005fc:	f6 c2 01             	test   $0x1,%dl
  8005ff:	75 10                	jne    800611 <fd_alloc+0x56>
  800601:	eb 05                	jmp    800608 <fd_alloc+0x4d>
  800603:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800608:	89 1f                	mov    %ebx,(%edi)
  80060a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80060f:	eb 17                	jmp    800628 <fd_alloc+0x6d>
  800611:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800616:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80061b:	75 c8                	jne    8005e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80061d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800623:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800628:	5b                   	pop    %ebx
  800629:	5e                   	pop    %esi
  80062a:	5f                   	pop    %edi
  80062b:	5d                   	pop    %ebp
  80062c:	c3                   	ret    

0080062d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800630:	8b 45 08             	mov    0x8(%ebp),%eax
  800633:	83 f8 1f             	cmp    $0x1f,%eax
  800636:	77 36                	ja     80066e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800638:	05 00 00 0d 00       	add    $0xd0000,%eax
  80063d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800640:	89 c2                	mov    %eax,%edx
  800642:	c1 ea 16             	shr    $0x16,%edx
  800645:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80064c:	f6 c2 01             	test   $0x1,%dl
  80064f:	74 1d                	je     80066e <fd_lookup+0x41>
  800651:	89 c2                	mov    %eax,%edx
  800653:	c1 ea 0c             	shr    $0xc,%edx
  800656:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80065d:	f6 c2 01             	test   $0x1,%dl
  800660:	74 0c                	je     80066e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800662:	8b 55 0c             	mov    0xc(%ebp),%edx
  800665:	89 02                	mov    %eax,(%edx)
  800667:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80066c:	eb 05                	jmp    800673 <fd_lookup+0x46>
  80066e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800673:	5d                   	pop    %ebp
  800674:	c3                   	ret    

00800675 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800675:	55                   	push   %ebp
  800676:	89 e5                	mov    %esp,%ebp
  800678:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80067b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80067e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800682:	8b 45 08             	mov    0x8(%ebp),%eax
  800685:	89 04 24             	mov    %eax,(%esp)
  800688:	e8 a0 ff ff ff       	call   80062d <fd_lookup>
  80068d:	85 c0                	test   %eax,%eax
  80068f:	78 0e                	js     80069f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800691:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800694:	8b 55 0c             	mov    0xc(%ebp),%edx
  800697:	89 50 04             	mov    %edx,0x4(%eax)
  80069a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80069f:	c9                   	leave  
  8006a0:	c3                   	ret    

008006a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8006a1:	55                   	push   %ebp
  8006a2:	89 e5                	mov    %esp,%ebp
  8006a4:	56                   	push   %esi
  8006a5:	53                   	push   %ebx
  8006a6:	83 ec 10             	sub    $0x10,%esp
  8006a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8006af:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8006b4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8006b9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8006bf:	75 11                	jne    8006d2 <dev_lookup+0x31>
  8006c1:	eb 04                	jmp    8006c7 <dev_lookup+0x26>
  8006c3:	39 08                	cmp    %ecx,(%eax)
  8006c5:	75 10                	jne    8006d7 <dev_lookup+0x36>
			*dev = devtab[i];
  8006c7:	89 03                	mov    %eax,(%ebx)
  8006c9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8006ce:	66 90                	xchg   %ax,%ax
  8006d0:	eb 36                	jmp    800708 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8006d2:	be 34 24 80 00       	mov    $0x802434,%esi
  8006d7:	83 c2 01             	add    $0x1,%edx
  8006da:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	75 e2                	jne    8006c3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8006e1:	a1 20 60 80 00       	mov    0x806020,%eax
  8006e6:	8b 40 48             	mov    0x48(%eax),%eax
  8006e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8006ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f1:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  8006f8:	e8 40 0d 00 00       	call   80143d <cprintf>
	*dev = 0;
  8006fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800703:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	5b                   	pop    %ebx
  80070c:	5e                   	pop    %esi
  80070d:	5d                   	pop    %ebp
  80070e:	c3                   	ret    

0080070f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	53                   	push   %ebx
  800713:	83 ec 24             	sub    $0x24,%esp
  800716:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800719:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800720:	8b 45 08             	mov    0x8(%ebp),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 02 ff ff ff       	call   80062d <fd_lookup>
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 53                	js     800782 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	8b 00                	mov    (%eax),%eax
  80073b:	89 04 24             	mov    %eax,(%esp)
  80073e:	e8 5e ff ff ff       	call   8006a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800743:	85 c0                	test   %eax,%eax
  800745:	78 3b                	js     800782 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800747:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80074c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800753:	74 2d                	je     800782 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800755:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800758:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80075f:	00 00 00 
	stat->st_isdir = 0;
  800762:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800769:	00 00 00 
	stat->st_dev = dev;
  80076c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800775:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800779:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80077c:	89 14 24             	mov    %edx,(%esp)
  80077f:	ff 50 14             	call   *0x14(%eax)
}
  800782:	83 c4 24             	add    $0x24,%esp
  800785:	5b                   	pop    %ebx
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
  80078b:	53                   	push   %ebx
  80078c:	83 ec 24             	sub    $0x24,%esp
  80078f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800792:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800795:	89 44 24 04          	mov    %eax,0x4(%esp)
  800799:	89 1c 24             	mov    %ebx,(%esp)
  80079c:	e8 8c fe ff ff       	call   80062d <fd_lookup>
  8007a1:	85 c0                	test   %eax,%eax
  8007a3:	78 5f                	js     800804 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007af:	8b 00                	mov    (%eax),%eax
  8007b1:	89 04 24             	mov    %eax,(%esp)
  8007b4:	e8 e8 fe ff ff       	call   8006a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b9:	85 c0                	test   %eax,%eax
  8007bb:	78 47                	js     800804 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8007c0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8007c4:	75 23                	jne    8007e9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007c6:	a1 20 60 80 00       	mov    0x806020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007cb:	8b 40 48             	mov    0x48(%eax),%eax
  8007ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d6:	c7 04 24 d8 23 80 00 	movl   $0x8023d8,(%esp)
  8007dd:	e8 5b 0c 00 00       	call   80143d <cprintf>
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8007e7:	eb 1b                	jmp    800804 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ec:	8b 48 18             	mov    0x18(%eax),%ecx
  8007ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	74 0c                	je     800804 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ff:	89 14 24             	mov    %edx,(%esp)
  800802:	ff d1                	call   *%ecx
}
  800804:	83 c4 24             	add    $0x24,%esp
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	83 ec 24             	sub    $0x24,%esp
  800811:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800814:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	89 1c 24             	mov    %ebx,(%esp)
  80081e:	e8 0a fe ff ff       	call   80062d <fd_lookup>
  800823:	85 c0                	test   %eax,%eax
  800825:	78 66                	js     80088d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800827:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80082a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800831:	8b 00                	mov    (%eax),%eax
  800833:	89 04 24             	mov    %eax,(%esp)
  800836:	e8 66 fe ff ff       	call   8006a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083b:	85 c0                	test   %eax,%eax
  80083d:	78 4e                	js     80088d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800842:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800846:	75 23                	jne    80086b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800848:	a1 20 60 80 00       	mov    0x806020,%eax
  80084d:	8b 40 48             	mov    0x48(%eax),%eax
  800850:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800854:	89 44 24 04          	mov    %eax,0x4(%esp)
  800858:	c7 04 24 f9 23 80 00 	movl   $0x8023f9,(%esp)
  80085f:	e8 d9 0b 00 00       	call   80143d <cprintf>
  800864:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800869:	eb 22                	jmp    80088d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80086b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086e:	8b 48 0c             	mov    0xc(%eax),%ecx
  800871:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800876:	85 c9                	test   %ecx,%ecx
  800878:	74 13                	je     80088d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80087a:	8b 45 10             	mov    0x10(%ebp),%eax
  80087d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800881:	8b 45 0c             	mov    0xc(%ebp),%eax
  800884:	89 44 24 04          	mov    %eax,0x4(%esp)
  800888:	89 14 24             	mov    %edx,(%esp)
  80088b:	ff d1                	call   *%ecx
}
  80088d:	83 c4 24             	add    $0x24,%esp
  800890:	5b                   	pop    %ebx
  800891:	5d                   	pop    %ebp
  800892:	c3                   	ret    

00800893 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	53                   	push   %ebx
  800897:	83 ec 24             	sub    $0x24,%esp
  80089a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a4:	89 1c 24             	mov    %ebx,(%esp)
  8008a7:	e8 81 fd ff ff       	call   80062d <fd_lookup>
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 6b                	js     80091b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ba:	8b 00                	mov    (%eax),%eax
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	e8 dd fd ff ff       	call   8006a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	78 53                	js     80091b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8008c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8008cb:	8b 42 08             	mov    0x8(%edx),%eax
  8008ce:	83 e0 03             	and    $0x3,%eax
  8008d1:	83 f8 01             	cmp    $0x1,%eax
  8008d4:	75 23                	jne    8008f9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8008d6:	a1 20 60 80 00       	mov    0x806020,%eax
  8008db:	8b 40 48             	mov    0x48(%eax),%eax
  8008de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8008e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e6:	c7 04 24 16 24 80 00 	movl   $0x802416,(%esp)
  8008ed:	e8 4b 0b 00 00       	call   80143d <cprintf>
  8008f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8008f7:	eb 22                	jmp    80091b <read+0x88>
	}
	if (!dev->dev_read)
  8008f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fc:	8b 48 08             	mov    0x8(%eax),%ecx
  8008ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 13                	je     80091b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800908:	8b 45 10             	mov    0x10(%ebp),%eax
  80090b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800912:	89 44 24 04          	mov    %eax,0x4(%esp)
  800916:	89 14 24             	mov    %edx,(%esp)
  800919:	ff d1                	call   *%ecx
}
  80091b:	83 c4 24             	add    $0x24,%esp
  80091e:	5b                   	pop    %ebx
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	57                   	push   %edi
  800925:	56                   	push   %esi
  800926:	53                   	push   %ebx
  800927:	83 ec 1c             	sub    $0x1c,%esp
  80092a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800930:	ba 00 00 00 00       	mov    $0x0,%edx
  800935:	bb 00 00 00 00       	mov    $0x0,%ebx
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
  80093f:	85 f6                	test   %esi,%esi
  800941:	74 29                	je     80096c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800943:	89 f0                	mov    %esi,%eax
  800945:	29 d0                	sub    %edx,%eax
  800947:	89 44 24 08          	mov    %eax,0x8(%esp)
  80094b:	03 55 0c             	add    0xc(%ebp),%edx
  80094e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800952:	89 3c 24             	mov    %edi,(%esp)
  800955:	e8 39 ff ff ff       	call   800893 <read>
		if (m < 0)
  80095a:	85 c0                	test   %eax,%eax
  80095c:	78 0e                	js     80096c <readn+0x4b>
			return m;
		if (m == 0)
  80095e:	85 c0                	test   %eax,%eax
  800960:	74 08                	je     80096a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800962:	01 c3                	add    %eax,%ebx
  800964:	89 da                	mov    %ebx,%edx
  800966:	39 f3                	cmp    %esi,%ebx
  800968:	72 d9                	jb     800943 <readn+0x22>
  80096a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80096c:	83 c4 1c             	add    $0x1c,%esp
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5f                   	pop    %edi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	83 ec 28             	sub    $0x28,%esp
  80097a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80097d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800980:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800983:	89 34 24             	mov    %esi,(%esp)
  800986:	e8 05 fc ff ff       	call   800590 <fd2num>
  80098b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80098e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800992:	89 04 24             	mov    %eax,(%esp)
  800995:	e8 93 fc ff ff       	call   80062d <fd_lookup>
  80099a:	89 c3                	mov    %eax,%ebx
  80099c:	85 c0                	test   %eax,%eax
  80099e:	78 05                	js     8009a5 <fd_close+0x31>
  8009a0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8009a3:	74 0e                	je     8009b3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8009a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8009a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ae:	0f 44 d8             	cmove  %eax,%ebx
  8009b1:	eb 3d                	jmp    8009f0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8009b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8009b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ba:	8b 06                	mov    (%esi),%eax
  8009bc:	89 04 24             	mov    %eax,(%esp)
  8009bf:	e8 dd fc ff ff       	call   8006a1 <dev_lookup>
  8009c4:	89 c3                	mov    %eax,%ebx
  8009c6:	85 c0                	test   %eax,%eax
  8009c8:	78 16                	js     8009e0 <fd_close+0x6c>
		if (dev->dev_close)
  8009ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009cd:	8b 40 10             	mov    0x10(%eax),%eax
  8009d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8009d5:	85 c0                	test   %eax,%eax
  8009d7:	74 07                	je     8009e0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8009d9:	89 34 24             	mov    %esi,(%esp)
  8009dc:	ff d0                	call   *%eax
  8009de:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8009e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009eb:	e8 9c f9 ff ff       	call   80038c <sys_page_unmap>
	return r;
}
  8009f0:	89 d8                	mov    %ebx,%eax
  8009f2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8009f5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8009f8:	89 ec                	mov    %ebp,%esp
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800a02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a05:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a09:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0c:	89 04 24             	mov    %eax,(%esp)
  800a0f:	e8 19 fc ff ff       	call   80062d <fd_lookup>
  800a14:	85 c0                	test   %eax,%eax
  800a16:	78 13                	js     800a2b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800a18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800a1f:	00 
  800a20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a23:	89 04 24             	mov    %eax,(%esp)
  800a26:	e8 49 ff ff ff       	call   800974 <fd_close>
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 18             	sub    $0x18,%esp
  800a33:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800a36:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800a39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800a40:	00 
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	89 04 24             	mov    %eax,(%esp)
  800a47:	e8 78 03 00 00       	call   800dc4 <open>
  800a4c:	89 c3                	mov    %eax,%ebx
  800a4e:	85 c0                	test   %eax,%eax
  800a50:	78 1b                	js     800a6d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a59:	89 1c 24             	mov    %ebx,(%esp)
  800a5c:	e8 ae fc ff ff       	call   80070f <fstat>
  800a61:	89 c6                	mov    %eax,%esi
	close(fd);
  800a63:	89 1c 24             	mov    %ebx,(%esp)
  800a66:	e8 91 ff ff ff       	call   8009fc <close>
  800a6b:	89 f3                	mov    %esi,%ebx
	return r;
}
  800a6d:	89 d8                	mov    %ebx,%eax
  800a6f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800a72:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800a75:	89 ec                	mov    %ebp,%esp
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	83 ec 14             	sub    $0x14,%esp
  800a80:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800a85:	89 1c 24             	mov    %ebx,(%esp)
  800a88:	e8 6f ff ff ff       	call   8009fc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800a8d:	83 c3 01             	add    $0x1,%ebx
  800a90:	83 fb 20             	cmp    $0x20,%ebx
  800a93:	75 f0                	jne    800a85 <close_all+0xc>
		close(i);
}
  800a95:	83 c4 14             	add    $0x14,%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	83 ec 58             	sub    $0x58,%esp
  800aa1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800aa4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800aa7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800aaa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800aad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	89 04 24             	mov    %eax,(%esp)
  800aba:	e8 6e fb ff ff       	call   80062d <fd_lookup>
  800abf:	89 c3                	mov    %eax,%ebx
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	0f 88 e0 00 00 00    	js     800ba9 <dup+0x10e>
		return r;
	close(newfdnum);
  800ac9:	89 3c 24             	mov    %edi,(%esp)
  800acc:	e8 2b ff ff ff       	call   8009fc <close>

	newfd = INDEX2FD(newfdnum);
  800ad1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800ad7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800ada:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800add:	89 04 24             	mov    %eax,(%esp)
  800ae0:	e8 bb fa ff ff       	call   8005a0 <fd2data>
  800ae5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800ae7:	89 34 24             	mov    %esi,(%esp)
  800aea:	e8 b1 fa ff ff       	call   8005a0 <fd2data>
  800aef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800af2:	89 da                	mov    %ebx,%edx
  800af4:	89 d8                	mov    %ebx,%eax
  800af6:	c1 e8 16             	shr    $0x16,%eax
  800af9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800b00:	a8 01                	test   $0x1,%al
  800b02:	74 43                	je     800b47 <dup+0xac>
  800b04:	c1 ea 0c             	shr    $0xc,%edx
  800b07:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800b0e:	a8 01                	test   $0x1,%al
  800b10:	74 35                	je     800b47 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800b12:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800b19:	25 07 0e 00 00       	and    $0xe07,%eax
  800b1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b29:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b30:	00 
  800b31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b3c:	e8 83 f8 ff ff       	call   8003c4 <sys_page_map>
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	85 c0                	test   %eax,%eax
  800b45:	78 3f                	js     800b86 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800b47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	c1 ea 0c             	shr    $0xc,%edx
  800b4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800b56:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800b5c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800b60:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800b64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b6b:	00 
  800b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b77:	e8 48 f8 ff ff       	call   8003c4 <sys_page_map>
  800b7c:	89 c3                	mov    %eax,%ebx
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	78 04                	js     800b86 <dup+0xeb>
  800b82:	89 fb                	mov    %edi,%ebx
  800b84:	eb 23                	jmp    800ba9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800b86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b91:	e8 f6 f7 ff ff       	call   80038c <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ba4:	e8 e3 f7 ff ff       	call   80038c <sys_page_unmap>
	return r;
}
  800ba9:	89 d8                	mov    %ebx,%eax
  800bab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800bae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800bb1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800bb4:	89 ec                	mov    %ebp,%esp
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 18             	sub    $0x18,%esp
  800bbe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800bc1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800bc4:	89 c3                	mov    %eax,%ebx
  800bc6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800bc8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800bcf:	75 11                	jne    800be2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800bd1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800bd8:	e8 93 13 00 00       	call   801f70 <ipc_find_env>
  800bdd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800be2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800be9:	00 
  800bea:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  800bf1:	00 
  800bf2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800bf6:	a1 00 40 80 00       	mov    0x804000,%eax
  800bfb:	89 04 24             	mov    %eax,(%esp)
  800bfe:	e8 b6 13 00 00       	call   801fb9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800c03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800c0a:	00 
  800c0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c16:	e8 09 14 00 00       	call   802024 <ipc_recv>
}
  800c1b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800c1e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800c21:	89 ec                	mov    %ebp,%esp
  800c23:	5d                   	pop    %ebp
  800c24:	c3                   	ret    

00800c25 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800c31:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  800c36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c39:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 02 00 00 00       	mov    $0x2,%eax
  800c48:	e8 6b ff ff ff       	call   800bb8 <fsipc>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	8b 40 0c             	mov    0xc(%eax),%eax
  800c5b:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6a:	e8 49 ff ff ff       	call   800bb8 <fsipc>
}
  800c6f:	c9                   	leave  
  800c70:	c3                   	ret    

00800c71 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800c77:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c81:	e8 32 ff ff ff       	call   800bb8 <fsipc>
}
  800c86:	c9                   	leave  
  800c87:	c3                   	ret    

00800c88 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 14             	sub    $0x14,%esp
  800c8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800c92:	8b 45 08             	mov    0x8(%ebp),%eax
  800c95:	8b 40 0c             	mov    0xc(%eax),%eax
  800c98:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800c9d:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca7:	e8 0c ff ff ff       	call   800bb8 <fsipc>
  800cac:	85 c0                	test   %eax,%eax
  800cae:	78 2b                	js     800cdb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800cb0:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800cb7:	00 
  800cb8:	89 1c 24             	mov    %ebx,(%esp)
  800cbb:	e8 ba 0e 00 00       	call   801b7a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800cc0:	a1 80 70 80 00       	mov    0x807080,%eax
  800cc5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800ccb:	a1 84 70 80 00       	mov    0x807084,%eax
  800cd0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800cdb:	83 c4 14             	add    $0x14,%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 18             	sub    $0x18,%esp
  800ce7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 52 0c             	mov    0xc(%edx),%edx
  800cf0:	89 15 00 70 80 00    	mov    %edx,0x807000
  fsipcbuf.write.req_n = n;
  800cf6:	a3 04 70 80 00       	mov    %eax,0x807004
  memmove(fsipcbuf.write.req_buf, buf,
  800cfb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800d00:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800d05:	0f 47 c2             	cmova  %edx,%eax
  800d08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d13:	c7 04 24 08 70 80 00 	movl   $0x807008,(%esp)
  800d1a:	e8 46 10 00 00       	call   801d65 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d24:	b8 04 00 00 00       	mov    $0x4,%eax
  800d29:	e8 8a fe ff ff       	call   800bb8 <fsipc>
}
  800d2e:	c9                   	leave  
  800d2f:	c3                   	ret    

00800d30 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	53                   	push   %ebx
  800d34:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800d37:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3a:	8b 40 0c             	mov    0xc(%eax),%eax
  800d3d:	a3 00 70 80 00       	mov    %eax,0x807000
  fsipcbuf.read.req_n = n;
  800d42:	8b 45 10             	mov    0x10(%ebp),%eax
  800d45:	a3 04 70 80 00       	mov    %eax,0x807004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800d4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d4f:	b8 03 00 00 00       	mov    $0x3,%eax
  800d54:	e8 5f fe ff ff       	call   800bb8 <fsipc>
  800d59:	89 c3                	mov    %eax,%ebx
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	78 17                	js     800d76 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800d5f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d63:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  800d6a:	00 
  800d6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6e:	89 04 24             	mov    %eax,(%esp)
  800d71:	e8 ef 0f 00 00       	call   801d65 <memmove>
  return r;	
}
  800d76:	89 d8                	mov    %ebx,%eax
  800d78:	83 c4 14             	add    $0x14,%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	53                   	push   %ebx
  800d82:	83 ec 14             	sub    $0x14,%esp
  800d85:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800d88:	89 1c 24             	mov    %ebx,(%esp)
  800d8b:	e8 a0 0d 00 00       	call   801b30 <strlen>
  800d90:	89 c2                	mov    %eax,%edx
  800d92:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d97:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800d9d:	7f 1f                	jg     800dbe <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800d9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800da3:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  800daa:	e8 cb 0d 00 00       	call   801b7a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	b8 07 00 00 00       	mov    $0x7,%eax
  800db9:	e8 fa fd ff ff       	call   800bb8 <fsipc>
}
  800dbe:	83 c4 14             	add    $0x14,%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 28             	sub    $0x28,%esp
  800dca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800dcd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800dd0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800dd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dd6:	89 04 24             	mov    %eax,(%esp)
  800dd9:	e8 dd f7 ff ff       	call   8005bb <fd_alloc>
  800dde:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800de0:	85 c0                	test   %eax,%eax
  800de2:	0f 88 89 00 00 00    	js     800e71 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800de8:	89 34 24             	mov    %esi,(%esp)
  800deb:	e8 40 0d 00 00       	call   801b30 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800df0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800df5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800dfa:	7f 75                	jg     800e71 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800dfc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e00:	c7 04 24 00 70 80 00 	movl   $0x807000,(%esp)
  800e07:	e8 6e 0d 00 00       	call   801b7a <strcpy>
  fsipcbuf.open.req_omode = mode;
  800e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0f:	a3 00 74 80 00       	mov    %eax,0x807400
  r = fsipc(FSREQ_OPEN, fd);
  800e14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e17:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1c:	e8 97 fd ff ff       	call   800bb8 <fsipc>
  800e21:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800e23:	85 c0                	test   %eax,%eax
  800e25:	78 0f                	js     800e36 <open+0x72>
  return fd2num(fd);
  800e27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e2a:	89 04 24             	mov    %eax,(%esp)
  800e2d:	e8 5e f7 ff ff       	call   800590 <fd2num>
  800e32:	89 c3                	mov    %eax,%ebx
  800e34:	eb 3b                	jmp    800e71 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800e36:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e3d:	00 
  800e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e41:	89 04 24             	mov    %eax,(%esp)
  800e44:	e8 2b fb ff ff       	call   800974 <fd_close>
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	74 24                	je     800e71 <open+0xad>
  800e4d:	c7 44 24 0c 40 24 80 	movl   $0x802440,0xc(%esp)
  800e54:	00 
  800e55:	c7 44 24 08 55 24 80 	movl   $0x802455,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 6a 24 80 00 	movl   $0x80246a,(%esp)
  800e6c:	e8 13 05 00 00       	call   801384 <_panic>
  return r;
}
  800e71:	89 d8                	mov    %ebx,%eax
  800e73:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800e76:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800e79:	89 ec                	mov    %ebp,%esp
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    
  800e7d:	00 00                	add    %al,(%eax)
	...

00800e80 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800e86:	c7 44 24 04 75 24 80 	movl   $0x802475,0x4(%esp)
  800e8d:	00 
  800e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e91:	89 04 24             	mov    %eax,(%esp)
  800e94:	e8 e1 0c 00 00       	call   801b7a <strcpy>
	return 0;
}
  800e99:	b8 00 00 00 00       	mov    $0x0,%eax
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	53                   	push   %ebx
  800ea4:	83 ec 14             	sub    $0x14,%esp
  800ea7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800eaa:	89 1c 24             	mov    %ebx,(%esp)
  800ead:	e8 02 12 00 00       	call   8020b4 <pageref>
  800eb2:	89 c2                	mov    %eax,%edx
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	83 fa 01             	cmp    $0x1,%edx
  800ebc:	75 0b                	jne    800ec9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800ebe:	8b 43 0c             	mov    0xc(%ebx),%eax
  800ec1:	89 04 24             	mov    %eax,(%esp)
  800ec4:	e8 b9 02 00 00       	call   801182 <nsipc_close>
	else
		return 0;
}
  800ec9:	83 c4 14             	add    $0x14,%esp
  800ecc:	5b                   	pop    %ebx
  800ecd:	5d                   	pop    %ebp
  800ece:	c3                   	ret    

00800ecf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800ed5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800edc:	00 
  800edd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800eee:	8b 40 0c             	mov    0xc(%eax),%eax
  800ef1:	89 04 24             	mov    %eax,(%esp)
  800ef4:	e8 c5 02 00 00       	call   8011be <nsipc_send>
}
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800f01:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f08:	00 
  800f09:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f17:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1a:	8b 40 0c             	mov    0xc(%eax),%eax
  800f1d:	89 04 24             	mov    %eax,(%esp)
  800f20:	e8 0c 03 00 00       	call   801231 <nsipc_recv>
}
  800f25:	c9                   	leave  
  800f26:	c3                   	ret    

00800f27 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	56                   	push   %esi
  800f2b:	53                   	push   %ebx
  800f2c:	83 ec 20             	sub    $0x20,%esp
  800f2f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f34:	89 04 24             	mov    %eax,(%esp)
  800f37:	e8 7f f6 ff ff       	call   8005bb <fd_alloc>
  800f3c:	89 c3                	mov    %eax,%ebx
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	78 21                	js     800f63 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800f42:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800f49:	00 
  800f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f58:	e8 a0 f4 ff ff       	call   8003fd <sys_page_alloc>
  800f5d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 0a                	jns    800f6d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  800f63:	89 34 24             	mov    %esi,(%esp)
  800f66:	e8 17 02 00 00       	call   801182 <nsipc_close>
		return r;
  800f6b:	eb 28                	jmp    800f95 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800f6d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f76:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f7b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800f82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f85:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800f88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8b:	89 04 24             	mov    %eax,(%esp)
  800f8e:	e8 fd f5 ff ff       	call   800590 <fd2num>
  800f93:	89 c3                	mov    %eax,%ebx
}
  800f95:	89 d8                	mov    %ebx,%eax
  800f97:	83 c4 20             	add    $0x20,%esp
  800f9a:	5b                   	pop    %ebx
  800f9b:	5e                   	pop    %esi
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800fa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	89 04 24             	mov    %eax,(%esp)
  800fb8:	e8 79 01 00 00       	call   801136 <nsipc_socket>
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 05                	js     800fc6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800fc1:	e8 61 ff ff ff       	call   800f27 <alloc_sockfd>
}
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800fce:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	e8 50 f6 ff ff       	call   80062d <fd_lookup>
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 15                	js     800ff6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800fe1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fe4:	8b 0a                	mov    (%edx),%ecx
  800fe6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800feb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  800ff1:	75 03                	jne    800ff6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800ff3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  801001:	e8 c2 ff ff ff       	call   800fc8 <fd2sockid>
  801006:	85 c0                	test   %eax,%eax
  801008:	78 0f                	js     801019 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80100a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801011:	89 04 24             	mov    %eax,(%esp)
  801014:	e8 47 01 00 00       	call   801160 <nsipc_listen>
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801021:	8b 45 08             	mov    0x8(%ebp),%eax
  801024:	e8 9f ff ff ff       	call   800fc8 <fd2sockid>
  801029:	85 c0                	test   %eax,%eax
  80102b:	78 16                	js     801043 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80102d:	8b 55 10             	mov    0x10(%ebp),%edx
  801030:	89 54 24 08          	mov    %edx,0x8(%esp)
  801034:	8b 55 0c             	mov    0xc(%ebp),%edx
  801037:	89 54 24 04          	mov    %edx,0x4(%esp)
  80103b:	89 04 24             	mov    %eax,(%esp)
  80103e:	e8 6e 02 00 00       	call   8012b1 <nsipc_connect>
}
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80104b:	8b 45 08             	mov    0x8(%ebp),%eax
  80104e:	e8 75 ff ff ff       	call   800fc8 <fd2sockid>
  801053:	85 c0                	test   %eax,%eax
  801055:	78 0f                	js     801066 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801057:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80105e:	89 04 24             	mov    %eax,(%esp)
  801061:	e8 36 01 00 00       	call   80119c <nsipc_shutdown>
}
  801066:	c9                   	leave  
  801067:	c3                   	ret    

00801068 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801068:	55                   	push   %ebp
  801069:	89 e5                	mov    %esp,%ebp
  80106b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80106e:	8b 45 08             	mov    0x8(%ebp),%eax
  801071:	e8 52 ff ff ff       	call   800fc8 <fd2sockid>
  801076:	85 c0                	test   %eax,%eax
  801078:	78 16                	js     801090 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80107a:	8b 55 10             	mov    0x10(%ebp),%edx
  80107d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801081:	8b 55 0c             	mov    0xc(%ebp),%edx
  801084:	89 54 24 04          	mov    %edx,0x4(%esp)
  801088:	89 04 24             	mov    %eax,(%esp)
  80108b:	e8 60 02 00 00       	call   8012f0 <nsipc_bind>
}
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	e8 28 ff ff ff       	call   800fc8 <fd2sockid>
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 1f                	js     8010c3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8010a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8010a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8010ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010b2:	89 04 24             	mov    %eax,(%esp)
  8010b5:	e8 75 02 00 00       	call   80132f <nsipc_accept>
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 05                	js     8010c3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8010be:	e8 64 fe ff ff       	call   800f27 <alloc_sockfd>
}
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    
	...

008010d0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	53                   	push   %ebx
  8010d4:	83 ec 14             	sub    $0x14,%esp
  8010d7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8010d9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8010e0:	75 11                	jne    8010f3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8010e2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8010e9:	e8 82 0e 00 00       	call   801f70 <ipc_find_env>
  8010ee:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8010f3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8010fa:	00 
  8010fb:	c7 44 24 08 00 80 80 	movl   $0x808000,0x8(%esp)
  801102:	00 
  801103:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801107:	a1 04 40 80 00       	mov    0x804004,%eax
  80110c:	89 04 24             	mov    %eax,(%esp)
  80110f:	e8 a5 0e 00 00       	call   801fb9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801114:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80111b:	00 
  80111c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801123:	00 
  801124:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112b:	e8 f4 0e 00 00       	call   802024 <ipc_recv>
}
  801130:	83 c4 14             	add    $0x14,%esp
  801133:	5b                   	pop    %ebx
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    

00801136 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80113c:	8b 45 08             	mov    0x8(%ebp),%eax
  80113f:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.socket.req_type = type;
  801144:	8b 45 0c             	mov    0xc(%ebp),%eax
  801147:	a3 04 80 80 00       	mov    %eax,0x808004
	nsipcbuf.socket.req_protocol = protocol;
  80114c:	8b 45 10             	mov    0x10(%ebp),%eax
  80114f:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SOCKET);
  801154:	b8 09 00 00 00       	mov    $0x9,%eax
  801159:	e8 72 ff ff ff       	call   8010d0 <nsipc>
}
  80115e:	c9                   	leave  
  80115f:	c3                   	ret    

00801160 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801166:	8b 45 08             	mov    0x8(%ebp),%eax
  801169:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.listen.req_backlog = backlog;
  80116e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801171:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_LISTEN);
  801176:	b8 06 00 00 00       	mov    $0x6,%eax
  80117b:	e8 50 ff ff ff       	call   8010d0 <nsipc>
}
  801180:	c9                   	leave  
  801181:	c3                   	ret    

00801182 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801188:	8b 45 08             	mov    0x8(%ebp),%eax
  80118b:	a3 00 80 80 00       	mov    %eax,0x808000
	return nsipc(NSREQ_CLOSE);
  801190:	b8 04 00 00 00       	mov    $0x4,%eax
  801195:	e8 36 ff ff ff       	call   8010d0 <nsipc>
}
  80119a:	c9                   	leave  
  80119b:	c3                   	ret    

0080119c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80119c:	55                   	push   %ebp
  80119d:	89 e5                	mov    %esp,%ebp
  80119f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a5:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.shutdown.req_how = how;
  8011aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ad:	a3 04 80 80 00       	mov    %eax,0x808004
	return nsipc(NSREQ_SHUTDOWN);
  8011b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8011b7:	e8 14 ff ff ff       	call   8010d0 <nsipc>
}
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	53                   	push   %ebx
  8011c2:	83 ec 14             	sub    $0x14,%esp
  8011c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8011c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8011cb:	a3 00 80 80 00       	mov    %eax,0x808000
	assert(size < 1600);
  8011d0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8011d6:	7e 24                	jle    8011fc <nsipc_send+0x3e>
  8011d8:	c7 44 24 0c 81 24 80 	movl   $0x802481,0xc(%esp)
  8011df:	00 
  8011e0:	c7 44 24 08 55 24 80 	movl   $0x802455,0x8(%esp)
  8011e7:	00 
  8011e8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8011ef:	00 
  8011f0:	c7 04 24 8d 24 80 00 	movl   $0x80248d,(%esp)
  8011f7:	e8 88 01 00 00       	call   801384 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8011fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801200:	8b 45 0c             	mov    0xc(%ebp),%eax
  801203:	89 44 24 04          	mov    %eax,0x4(%esp)
  801207:	c7 04 24 0c 80 80 00 	movl   $0x80800c,(%esp)
  80120e:	e8 52 0b 00 00       	call   801d65 <memmove>
	nsipcbuf.send.req_size = size;
  801213:	89 1d 04 80 80 00    	mov    %ebx,0x808004
	nsipcbuf.send.req_flags = flags;
  801219:	8b 45 14             	mov    0x14(%ebp),%eax
  80121c:	a3 08 80 80 00       	mov    %eax,0x808008
	return nsipc(NSREQ_SEND);
  801221:	b8 08 00 00 00       	mov    $0x8,%eax
  801226:	e8 a5 fe ff ff       	call   8010d0 <nsipc>
}
  80122b:	83 c4 14             	add    $0x14,%esp
  80122e:	5b                   	pop    %ebx
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 10             	sub    $0x10,%esp
  801239:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	a3 00 80 80 00       	mov    %eax,0x808000
	nsipcbuf.recv.req_len = len;
  801244:	89 35 04 80 80 00    	mov    %esi,0x808004
	nsipcbuf.recv.req_flags = flags;
  80124a:	8b 45 14             	mov    0x14(%ebp),%eax
  80124d:	a3 08 80 80 00       	mov    %eax,0x808008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801252:	b8 07 00 00 00       	mov    $0x7,%eax
  801257:	e8 74 fe ff ff       	call   8010d0 <nsipc>
  80125c:	89 c3                	mov    %eax,%ebx
  80125e:	85 c0                	test   %eax,%eax
  801260:	78 46                	js     8012a8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801262:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801267:	7f 04                	jg     80126d <nsipc_recv+0x3c>
  801269:	39 c6                	cmp    %eax,%esi
  80126b:	7d 24                	jge    801291 <nsipc_recv+0x60>
  80126d:	c7 44 24 0c 99 24 80 	movl   $0x802499,0xc(%esp)
  801274:	00 
  801275:	c7 44 24 08 55 24 80 	movl   $0x802455,0x8(%esp)
  80127c:	00 
  80127d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801284:	00 
  801285:	c7 04 24 8d 24 80 00 	movl   $0x80248d,(%esp)
  80128c:	e8 f3 00 00 00       	call   801384 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801291:	89 44 24 08          	mov    %eax,0x8(%esp)
  801295:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  80129c:	00 
  80129d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a0:	89 04 24             	mov    %eax,(%esp)
  8012a3:	e8 bd 0a 00 00       	call   801d65 <memmove>
	}

	return r;
}
  8012a8:	89 d8                	mov    %ebx,%eax
  8012aa:	83 c4 10             	add    $0x10,%esp
  8012ad:	5b                   	pop    %ebx
  8012ae:	5e                   	pop    %esi
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 14             	sub    $0x14,%esp
  8012b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8012bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8012be:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8012c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ce:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  8012d5:	e8 8b 0a 00 00       	call   801d65 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8012da:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_CONNECT);
  8012e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8012e5:	e8 e6 fd ff ff       	call   8010d0 <nsipc>
}
  8012ea:	83 c4 14             	add    $0x14,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 14             	sub    $0x14,%esp
  8012f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8012fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8012fd:	a3 00 80 80 00       	mov    %eax,0x808000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801302:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801306:	8b 45 0c             	mov    0xc(%ebp),%eax
  801309:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130d:	c7 04 24 04 80 80 00 	movl   $0x808004,(%esp)
  801314:	e8 4c 0a 00 00       	call   801d65 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801319:	89 1d 14 80 80 00    	mov    %ebx,0x808014
	return nsipc(NSREQ_BIND);
  80131f:	b8 02 00 00 00       	mov    $0x2,%eax
  801324:	e8 a7 fd ff ff       	call   8010d0 <nsipc>
}
  801329:	83 c4 14             	add    $0x14,%esp
  80132c:	5b                   	pop    %ebx
  80132d:	5d                   	pop    %ebp
  80132e:	c3                   	ret    

0080132f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80132f:	55                   	push   %ebp
  801330:	89 e5                	mov    %esp,%ebp
  801332:	83 ec 18             	sub    $0x18,%esp
  801335:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801338:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80133b:	8b 45 08             	mov    0x8(%ebp),%eax
  80133e:	a3 00 80 80 00       	mov    %eax,0x808000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801343:	b8 01 00 00 00       	mov    $0x1,%eax
  801348:	e8 83 fd ff ff       	call   8010d0 <nsipc>
  80134d:	89 c3                	mov    %eax,%ebx
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 25                	js     801378 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801353:	be 10 80 80 00       	mov    $0x808010,%esi
  801358:	8b 06                	mov    (%esi),%eax
  80135a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135e:	c7 44 24 04 00 80 80 	movl   $0x808000,0x4(%esp)
  801365:	00 
  801366:	8b 45 0c             	mov    0xc(%ebp),%eax
  801369:	89 04 24             	mov    %eax,(%esp)
  80136c:	e8 f4 09 00 00       	call   801d65 <memmove>
		*addrlen = ret->ret_addrlen;
  801371:	8b 16                	mov    (%esi),%edx
  801373:	8b 45 10             	mov    0x10(%ebp),%eax
  801376:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801378:	89 d8                	mov    %ebx,%eax
  80137a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80137d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801380:	89 ec                	mov    %ebp,%esp
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	56                   	push   %esi
  801388:	53                   	push   %ebx
  801389:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80138c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80138f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801395:	e8 0d f1 ff ff       	call   8004a7 <sys_getenvid>
  80139a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80139d:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013a8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b0:	c7 04 24 b0 24 80 00 	movl   $0x8024b0,(%esp)
  8013b7:	e8 81 00 00 00       	call   80143d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8013bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8013c3:	89 04 24             	mov    %eax,(%esp)
  8013c6:	e8 11 00 00 00       	call   8013dc <vcprintf>
	cprintf("\n");
  8013cb:	c7 04 24 30 24 80 00 	movl   $0x802430,(%esp)
  8013d2:	e8 66 00 00 00       	call   80143d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8013d7:	cc                   	int3   
  8013d8:	eb fd                	jmp    8013d7 <_panic+0x53>
	...

008013dc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8013e5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8013ec:	00 00 00 
	b.cnt = 0;
  8013ef:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8013f6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801400:	8b 45 08             	mov    0x8(%ebp),%eax
  801403:	89 44 24 08          	mov    %eax,0x8(%esp)
  801407:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	c7 04 24 57 14 80 00 	movl   $0x801457,(%esp)
  801418:	e8 d0 01 00 00       	call   8015ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80141d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801423:	89 44 24 04          	mov    %eax,0x4(%esp)
  801427:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80142d:	89 04 24             	mov    %eax,(%esp)
  801430:	e8 21 f1 ff ff       	call   800556 <sys_cputs>

	return b.cnt;
}
  801435:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801443:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801446:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144a:	8b 45 08             	mov    0x8(%ebp),%eax
  80144d:	89 04 24             	mov    %eax,(%esp)
  801450:	e8 87 ff ff ff       	call   8013dc <vcprintf>
	va_end(ap);

	return cnt;
}
  801455:	c9                   	leave  
  801456:	c3                   	ret    

00801457 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	53                   	push   %ebx
  80145b:	83 ec 14             	sub    $0x14,%esp
  80145e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801461:	8b 03                	mov    (%ebx),%eax
  801463:	8b 55 08             	mov    0x8(%ebp),%edx
  801466:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80146a:	83 c0 01             	add    $0x1,%eax
  80146d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80146f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801474:	75 19                	jne    80148f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801476:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80147d:	00 
  80147e:	8d 43 08             	lea    0x8(%ebx),%eax
  801481:	89 04 24             	mov    %eax,(%esp)
  801484:	e8 cd f0 ff ff       	call   800556 <sys_cputs>
		b->idx = 0;
  801489:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80148f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801493:	83 c4 14             	add    $0x14,%esp
  801496:	5b                   	pop    %ebx
  801497:	5d                   	pop    %ebp
  801498:	c3                   	ret    
  801499:	00 00                	add    %al,(%eax)
  80149b:	00 00                	add    %al,(%eax)
  80149d:	00 00                	add    %al,(%eax)
	...

008014a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	57                   	push   %edi
  8014a4:	56                   	push   %esi
  8014a5:	53                   	push   %ebx
  8014a6:	83 ec 4c             	sub    $0x4c,%esp
  8014a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8014ac:	89 d6                	mov    %edx,%esi
  8014ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8014ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8014bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8014c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8014c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8014c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014cb:	39 d1                	cmp    %edx,%ecx
  8014cd:	72 15                	jb     8014e4 <printnum+0x44>
  8014cf:	77 07                	ja     8014d8 <printnum+0x38>
  8014d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014d4:	39 d0                	cmp    %edx,%eax
  8014d6:	76 0c                	jbe    8014e4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014d8:	83 eb 01             	sub    $0x1,%ebx
  8014db:	85 db                	test   %ebx,%ebx
  8014dd:	8d 76 00             	lea    0x0(%esi),%esi
  8014e0:	7f 61                	jg     801543 <printnum+0xa3>
  8014e2:	eb 70                	jmp    801554 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8014e4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8014e8:	83 eb 01             	sub    $0x1,%ebx
  8014eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014f3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8014f7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8014fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8014fe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801501:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801504:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801508:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80150f:	00 
  801510:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801513:	89 04 24             	mov    %eax,(%esp)
  801516:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801519:	89 54 24 04          	mov    %edx,0x4(%esp)
  80151d:	e8 de 0b 00 00       	call   802100 <__udivdi3>
  801522:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801525:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801528:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80152c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801530:	89 04 24             	mov    %eax,(%esp)
  801533:	89 54 24 04          	mov    %edx,0x4(%esp)
  801537:	89 f2                	mov    %esi,%edx
  801539:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80153c:	e8 5f ff ff ff       	call   8014a0 <printnum>
  801541:	eb 11                	jmp    801554 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801543:	89 74 24 04          	mov    %esi,0x4(%esp)
  801547:	89 3c 24             	mov    %edi,(%esp)
  80154a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80154d:	83 eb 01             	sub    $0x1,%ebx
  801550:	85 db                	test   %ebx,%ebx
  801552:	7f ef                	jg     801543 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801554:	89 74 24 04          	mov    %esi,0x4(%esp)
  801558:	8b 74 24 04          	mov    0x4(%esp),%esi
  80155c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80155f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801563:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80156a:	00 
  80156b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80156e:	89 14 24             	mov    %edx,(%esp)
  801571:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801574:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801578:	e8 b3 0c 00 00       	call   802230 <__umoddi3>
  80157d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801581:	0f be 80 d3 24 80 00 	movsbl 0x8024d3(%eax),%eax
  801588:	89 04 24             	mov    %eax,(%esp)
  80158b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80158e:	83 c4 4c             	add    $0x4c,%esp
  801591:	5b                   	pop    %ebx
  801592:	5e                   	pop    %esi
  801593:	5f                   	pop    %edi
  801594:	5d                   	pop    %ebp
  801595:	c3                   	ret    

00801596 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801596:	55                   	push   %ebp
  801597:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801599:	83 fa 01             	cmp    $0x1,%edx
  80159c:	7e 0e                	jle    8015ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80159e:	8b 10                	mov    (%eax),%edx
  8015a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8015a3:	89 08                	mov    %ecx,(%eax)
  8015a5:	8b 02                	mov    (%edx),%eax
  8015a7:	8b 52 04             	mov    0x4(%edx),%edx
  8015aa:	eb 22                	jmp    8015ce <getuint+0x38>
	else if (lflag)
  8015ac:	85 d2                	test   %edx,%edx
  8015ae:	74 10                	je     8015c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8015b0:	8b 10                	mov    (%eax),%edx
  8015b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015b5:	89 08                	mov    %ecx,(%eax)
  8015b7:	8b 02                	mov    (%edx),%eax
  8015b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015be:	eb 0e                	jmp    8015ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8015c0:	8b 10                	mov    (%eax),%edx
  8015c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8015c5:	89 08                	mov    %ecx,(%eax)
  8015c7:	8b 02                	mov    (%edx),%eax
  8015c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8015ce:	5d                   	pop    %ebp
  8015cf:	c3                   	ret    

008015d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8015d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8015da:	8b 10                	mov    (%eax),%edx
  8015dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8015df:	73 0a                	jae    8015eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8015e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015e4:	88 0a                	mov    %cl,(%edx)
  8015e6:	83 c2 01             	add    $0x1,%edx
  8015e9:	89 10                	mov    %edx,(%eax)
}
  8015eb:	5d                   	pop    %ebp
  8015ec:	c3                   	ret    

008015ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8015ed:	55                   	push   %ebp
  8015ee:	89 e5                	mov    %esp,%ebp
  8015f0:	57                   	push   %edi
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 5c             	sub    $0x5c,%esp
  8015f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8015ff:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801606:	eb 11                	jmp    801619 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801608:	85 c0                	test   %eax,%eax
  80160a:	0f 84 68 04 00 00    	je     801a78 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  801610:	89 74 24 04          	mov    %esi,0x4(%esp)
  801614:	89 04 24             	mov    %eax,(%esp)
  801617:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801619:	0f b6 03             	movzbl (%ebx),%eax
  80161c:	83 c3 01             	add    $0x1,%ebx
  80161f:	83 f8 25             	cmp    $0x25,%eax
  801622:	75 e4                	jne    801608 <vprintfmt+0x1b>
  801624:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80162b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801632:	b9 00 00 00 00       	mov    $0x0,%ecx
  801637:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80163b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801642:	eb 06                	jmp    80164a <vprintfmt+0x5d>
  801644:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  801648:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164a:	0f b6 13             	movzbl (%ebx),%edx
  80164d:	0f b6 c2             	movzbl %dl,%eax
  801650:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801653:	8d 43 01             	lea    0x1(%ebx),%eax
  801656:	83 ea 23             	sub    $0x23,%edx
  801659:	80 fa 55             	cmp    $0x55,%dl
  80165c:	0f 87 f9 03 00 00    	ja     801a5b <vprintfmt+0x46e>
  801662:	0f b6 d2             	movzbl %dl,%edx
  801665:	ff 24 95 c0 26 80 00 	jmp    *0x8026c0(,%edx,4)
  80166c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  801670:	eb d6                	jmp    801648 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801672:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801675:	83 ea 30             	sub    $0x30,%edx
  801678:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80167b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80167e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801681:	83 fb 09             	cmp    $0x9,%ebx
  801684:	77 54                	ja     8016da <vprintfmt+0xed>
  801686:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801689:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80168c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80168f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801692:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  801696:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801699:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80169c:	83 fb 09             	cmp    $0x9,%ebx
  80169f:	76 eb                	jbe    80168c <vprintfmt+0x9f>
  8016a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8016a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8016a7:	eb 31                	jmp    8016da <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8016a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8016ac:	8d 5a 04             	lea    0x4(%edx),%ebx
  8016af:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8016b2:	8b 12                	mov    (%edx),%edx
  8016b4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8016b7:	eb 21                	jmp    8016da <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8016b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8016bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8016c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8016c9:	e9 7a ff ff ff       	jmp    801648 <vprintfmt+0x5b>
  8016ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8016d5:	e9 6e ff ff ff       	jmp    801648 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8016da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8016de:	0f 89 64 ff ff ff    	jns    801648 <vprintfmt+0x5b>
  8016e4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8016e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8016ea:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8016ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8016f0:	e9 53 ff ff ff       	jmp    801648 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8016f5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8016f8:	e9 4b ff ff ff       	jmp    801648 <vprintfmt+0x5b>
  8016fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801700:	8b 45 14             	mov    0x14(%ebp),%eax
  801703:	8d 50 04             	lea    0x4(%eax),%edx
  801706:	89 55 14             	mov    %edx,0x14(%ebp)
  801709:	89 74 24 04          	mov    %esi,0x4(%esp)
  80170d:	8b 00                	mov    (%eax),%eax
  80170f:	89 04 24             	mov    %eax,(%esp)
  801712:	ff d7                	call   *%edi
  801714:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801717:	e9 fd fe ff ff       	jmp    801619 <vprintfmt+0x2c>
  80171c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80171f:	8b 45 14             	mov    0x14(%ebp),%eax
  801722:	8d 50 04             	lea    0x4(%eax),%edx
  801725:	89 55 14             	mov    %edx,0x14(%ebp)
  801728:	8b 00                	mov    (%eax),%eax
  80172a:	89 c2                	mov    %eax,%edx
  80172c:	c1 fa 1f             	sar    $0x1f,%edx
  80172f:	31 d0                	xor    %edx,%eax
  801731:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801733:	83 f8 0f             	cmp    $0xf,%eax
  801736:	7f 0b                	jg     801743 <vprintfmt+0x156>
  801738:	8b 14 85 20 28 80 00 	mov    0x802820(,%eax,4),%edx
  80173f:	85 d2                	test   %edx,%edx
  801741:	75 20                	jne    801763 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  801743:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801747:	c7 44 24 08 e4 24 80 	movl   $0x8024e4,0x8(%esp)
  80174e:	00 
  80174f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801753:	89 3c 24             	mov    %edi,(%esp)
  801756:	e8 a5 03 00 00       	call   801b00 <printfmt>
  80175b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80175e:	e9 b6 fe ff ff       	jmp    801619 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801763:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801767:	c7 44 24 08 67 24 80 	movl   $0x802467,0x8(%esp)
  80176e:	00 
  80176f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801773:	89 3c 24             	mov    %edi,(%esp)
  801776:	e8 85 03 00 00       	call   801b00 <printfmt>
  80177b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80177e:	e9 96 fe ff ff       	jmp    801619 <vprintfmt+0x2c>
  801783:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801786:	89 c3                	mov    %eax,%ebx
  801788:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80178b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80178e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801791:	8b 45 14             	mov    0x14(%ebp),%eax
  801794:	8d 50 04             	lea    0x4(%eax),%edx
  801797:	89 55 14             	mov    %edx,0x14(%ebp)
  80179a:	8b 00                	mov    (%eax),%eax
  80179c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80179f:	85 c0                	test   %eax,%eax
  8017a1:	b8 ed 24 80 00       	mov    $0x8024ed,%eax
  8017a6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8017aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8017ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8017b1:	7e 06                	jle    8017b9 <vprintfmt+0x1cc>
  8017b3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8017b7:	75 13                	jne    8017cc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017bc:	0f be 02             	movsbl (%edx),%eax
  8017bf:	85 c0                	test   %eax,%eax
  8017c1:	0f 85 a2 00 00 00    	jne    801869 <vprintfmt+0x27c>
  8017c7:	e9 8f 00 00 00       	jmp    80185b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017d3:	89 0c 24             	mov    %ecx,(%esp)
  8017d6:	e8 70 03 00 00       	call   801b4b <strnlen>
  8017db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8017de:	29 c2                	sub    %eax,%edx
  8017e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8017e3:	85 d2                	test   %edx,%edx
  8017e5:	7e d2                	jle    8017b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8017e7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8017eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8017ee:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8017f1:	89 d3                	mov    %edx,%ebx
  8017f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8017ff:	83 eb 01             	sub    $0x1,%ebx
  801802:	85 db                	test   %ebx,%ebx
  801804:	7f ed                	jg     8017f3 <vprintfmt+0x206>
  801806:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801809:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801810:	eb a7                	jmp    8017b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801812:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801816:	74 1b                	je     801833 <vprintfmt+0x246>
  801818:	8d 50 e0             	lea    -0x20(%eax),%edx
  80181b:	83 fa 5e             	cmp    $0x5e,%edx
  80181e:	76 13                	jbe    801833 <vprintfmt+0x246>
					putch('?', putdat);
  801820:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801823:	89 54 24 04          	mov    %edx,0x4(%esp)
  801827:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80182e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801831:	eb 0d                	jmp    801840 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801833:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801836:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80183a:	89 04 24             	mov    %eax,(%esp)
  80183d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801840:	83 ef 01             	sub    $0x1,%edi
  801843:	0f be 03             	movsbl (%ebx),%eax
  801846:	85 c0                	test   %eax,%eax
  801848:	74 05                	je     80184f <vprintfmt+0x262>
  80184a:	83 c3 01             	add    $0x1,%ebx
  80184d:	eb 31                	jmp    801880 <vprintfmt+0x293>
  80184f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801852:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801855:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801858:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80185b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80185f:	7f 36                	jg     801897 <vprintfmt+0x2aa>
  801861:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801864:	e9 b0 fd ff ff       	jmp    801619 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801869:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80186c:	83 c2 01             	add    $0x1,%edx
  80186f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801872:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801875:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801878:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80187b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80187e:	89 d3                	mov    %edx,%ebx
  801880:	85 f6                	test   %esi,%esi
  801882:	78 8e                	js     801812 <vprintfmt+0x225>
  801884:	83 ee 01             	sub    $0x1,%esi
  801887:	79 89                	jns    801812 <vprintfmt+0x225>
  801889:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80188c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80188f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801892:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  801895:	eb c4                	jmp    80185b <vprintfmt+0x26e>
  801897:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80189a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80189d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8018a8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018aa:	83 eb 01             	sub    $0x1,%ebx
  8018ad:	85 db                	test   %ebx,%ebx
  8018af:	7f ec                	jg     80189d <vprintfmt+0x2b0>
  8018b1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8018b4:	e9 60 fd ff ff       	jmp    801619 <vprintfmt+0x2c>
  8018b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8018bc:	83 f9 01             	cmp    $0x1,%ecx
  8018bf:	7e 16                	jle    8018d7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8018c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c4:	8d 50 08             	lea    0x8(%eax),%edx
  8018c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ca:	8b 10                	mov    (%eax),%edx
  8018cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8018cf:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8018d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018d5:	eb 32                	jmp    801909 <vprintfmt+0x31c>
	else if (lflag)
  8018d7:	85 c9                	test   %ecx,%ecx
  8018d9:	74 18                	je     8018f3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8018db:	8b 45 14             	mov    0x14(%ebp),%eax
  8018de:	8d 50 04             	lea    0x4(%eax),%edx
  8018e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e4:	8b 00                	mov    (%eax),%eax
  8018e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018e9:	89 c1                	mov    %eax,%ecx
  8018eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8018ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8018f1:	eb 16                	jmp    801909 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8018f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f6:	8d 50 04             	lea    0x4(%eax),%edx
  8018f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fc:	8b 00                	mov    (%eax),%eax
  8018fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801901:	89 c2                	mov    %eax,%edx
  801903:	c1 fa 1f             	sar    $0x1f,%edx
  801906:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801909:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80190c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80190f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  801914:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801918:	0f 89 8a 00 00 00    	jns    8019a8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80191e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801922:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801929:	ff d7                	call   *%edi
				num = -(long long) num;
  80192b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80192e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801931:	f7 d8                	neg    %eax
  801933:	83 d2 00             	adc    $0x0,%edx
  801936:	f7 da                	neg    %edx
  801938:	eb 6e                	jmp    8019a8 <vprintfmt+0x3bb>
  80193a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80193d:	89 ca                	mov    %ecx,%edx
  80193f:	8d 45 14             	lea    0x14(%ebp),%eax
  801942:	e8 4f fc ff ff       	call   801596 <getuint>
  801947:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80194c:	eb 5a                	jmp    8019a8 <vprintfmt+0x3bb>
  80194e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801951:	89 ca                	mov    %ecx,%edx
  801953:	8d 45 14             	lea    0x14(%ebp),%eax
  801956:	e8 3b fc ff ff       	call   801596 <getuint>
  80195b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  801960:	eb 46                	jmp    8019a8 <vprintfmt+0x3bb>
  801962:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  801965:	89 74 24 04          	mov    %esi,0x4(%esp)
  801969:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801970:	ff d7                	call   *%edi
			putch('x', putdat);
  801972:	89 74 24 04          	mov    %esi,0x4(%esp)
  801976:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80197d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80197f:	8b 45 14             	mov    0x14(%ebp),%eax
  801982:	8d 50 04             	lea    0x4(%eax),%edx
  801985:	89 55 14             	mov    %edx,0x14(%ebp)
  801988:	8b 00                	mov    (%eax),%eax
  80198a:	ba 00 00 00 00       	mov    $0x0,%edx
  80198f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801994:	eb 12                	jmp    8019a8 <vprintfmt+0x3bb>
  801996:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801999:	89 ca                	mov    %ecx,%edx
  80199b:	8d 45 14             	lea    0x14(%ebp),%eax
  80199e:	e8 f3 fb ff ff       	call   801596 <getuint>
  8019a3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019a8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8019ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8019b0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8019b3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8019b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019bb:	89 04 24             	mov    %eax,(%esp)
  8019be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8019c2:	89 f2                	mov    %esi,%edx
  8019c4:	89 f8                	mov    %edi,%eax
  8019c6:	e8 d5 fa ff ff       	call   8014a0 <printnum>
  8019cb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8019ce:	e9 46 fc ff ff       	jmp    801619 <vprintfmt+0x2c>
  8019d3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8019d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d9:	8d 50 04             	lea    0x4(%eax),%edx
  8019dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8019df:	8b 00                	mov    (%eax),%eax
  8019e1:	85 c0                	test   %eax,%eax
  8019e3:	75 24                	jne    801a09 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8019e5:	c7 44 24 0c 08 26 80 	movl   $0x802608,0xc(%esp)
  8019ec:	00 
  8019ed:	c7 44 24 08 67 24 80 	movl   $0x802467,0x8(%esp)
  8019f4:	00 
  8019f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019f9:	89 3c 24             	mov    %edi,(%esp)
  8019fc:	e8 ff 00 00 00       	call   801b00 <printfmt>
  801a01:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801a04:	e9 10 fc ff ff       	jmp    801619 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  801a09:	83 3e 7f             	cmpl   $0x7f,(%esi)
  801a0c:	7e 29                	jle    801a37 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  801a0e:	0f b6 16             	movzbl (%esi),%edx
  801a11:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  801a13:	c7 44 24 0c 40 26 80 	movl   $0x802640,0xc(%esp)
  801a1a:	00 
  801a1b:	c7 44 24 08 67 24 80 	movl   $0x802467,0x8(%esp)
  801a22:	00 
  801a23:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a27:	89 3c 24             	mov    %edi,(%esp)
  801a2a:	e8 d1 00 00 00       	call   801b00 <printfmt>
  801a2f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801a32:	e9 e2 fb ff ff       	jmp    801619 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  801a37:	0f b6 16             	movzbl (%esi),%edx
  801a3a:	88 10                	mov    %dl,(%eax)
  801a3c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  801a3f:	e9 d5 fb ff ff       	jmp    801619 <vprintfmt+0x2c>
  801a44:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801a47:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801a4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a4e:	89 14 24             	mov    %edx,(%esp)
  801a51:	ff d7                	call   *%edi
  801a53:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801a56:	e9 be fb ff ff       	jmp    801619 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a5b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a5f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801a66:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a68:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801a6b:	80 38 25             	cmpb   $0x25,(%eax)
  801a6e:	0f 84 a5 fb ff ff    	je     801619 <vprintfmt+0x2c>
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	eb f0                	jmp    801a68 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  801a78:	83 c4 5c             	add    $0x5c,%esp
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5f                   	pop    %edi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 28             	sub    $0x28,%esp
  801a86:	8b 45 08             	mov    0x8(%ebp),%eax
  801a89:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	74 04                	je     801a94 <vsnprintf+0x14>
  801a90:	85 d2                	test   %edx,%edx
  801a92:	7f 07                	jg     801a9b <vsnprintf+0x1b>
  801a94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a99:	eb 3b                	jmp    801ad6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a9b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a9e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801aa2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801aa5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aac:	8b 45 14             	mov    0x14(%ebp),%eax
  801aaf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab6:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac1:	c7 04 24 d0 15 80 00 	movl   $0x8015d0,(%esp)
  801ac8:	e8 20 fb ff ff       	call   8015ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801acd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ad0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801ade:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801ae1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ae5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aef:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af3:	8b 45 08             	mov    0x8(%ebp),%eax
  801af6:	89 04 24             	mov    %eax,(%esp)
  801af9:	e8 82 ff ff ff       	call   801a80 <vsnprintf>
	va_end(ap);

	return rc;
}
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801b06:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801b09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b0d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b10:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	e8 c7 fa ff ff       	call   8015ed <vprintfmt>
	va_end(ap);
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    
	...

00801b30 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b36:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3b:	80 3a 00             	cmpb   $0x0,(%edx)
  801b3e:	74 09                	je     801b49 <strlen+0x19>
		n++;
  801b40:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b47:	75 f7                	jne    801b40 <strlen+0x10>
		n++;
	return n;
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	53                   	push   %ebx
  801b4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b55:	85 c9                	test   %ecx,%ecx
  801b57:	74 19                	je     801b72 <strnlen+0x27>
  801b59:	80 3b 00             	cmpb   $0x0,(%ebx)
  801b5c:	74 14                	je     801b72 <strnlen+0x27>
  801b5e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801b63:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b66:	39 c8                	cmp    %ecx,%eax
  801b68:	74 0d                	je     801b77 <strnlen+0x2c>
  801b6a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801b6e:	75 f3                	jne    801b63 <strnlen+0x18>
  801b70:	eb 05                	jmp    801b77 <strnlen+0x2c>
  801b72:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801b77:	5b                   	pop    %ebx
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    

00801b7a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	53                   	push   %ebx
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b84:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b89:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801b8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801b90:	83 c2 01             	add    $0x1,%edx
  801b93:	84 c9                	test   %cl,%cl
  801b95:	75 f2                	jne    801b89 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b97:	5b                   	pop    %ebx
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 08             	sub    $0x8,%esp
  801ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ba4:	89 1c 24             	mov    %ebx,(%esp)
  801ba7:	e8 84 ff ff ff       	call   801b30 <strlen>
	strcpy(dst + len, src);
  801bac:	8b 55 0c             	mov    0xc(%ebp),%edx
  801baf:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bb3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801bb6:	89 04 24             	mov    %eax,(%esp)
  801bb9:	e8 bc ff ff ff       	call   801b7a <strcpy>
	return dst;
}
  801bbe:	89 d8                	mov    %ebx,%eax
  801bc0:	83 c4 08             	add    $0x8,%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5d                   	pop    %ebp
  801bc5:	c3                   	ret    

00801bc6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bc6:	55                   	push   %ebp
  801bc7:	89 e5                	mov    %esp,%ebp
  801bc9:	56                   	push   %esi
  801bca:	53                   	push   %ebx
  801bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bce:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd4:	85 f6                	test   %esi,%esi
  801bd6:	74 18                	je     801bf0 <strncpy+0x2a>
  801bd8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801bdd:	0f b6 1a             	movzbl (%edx),%ebx
  801be0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be3:	80 3a 01             	cmpb   $0x1,(%edx)
  801be6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801be9:	83 c1 01             	add    $0x1,%ecx
  801bec:	39 ce                	cmp    %ecx,%esi
  801bee:	77 ed                	ja     801bdd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801bf0:	5b                   	pop    %ebx
  801bf1:	5e                   	pop    %esi
  801bf2:	5d                   	pop    %ebp
  801bf3:	c3                   	ret    

00801bf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c02:	89 f0                	mov    %esi,%eax
  801c04:	85 c9                	test   %ecx,%ecx
  801c06:	74 27                	je     801c2f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801c08:	83 e9 01             	sub    $0x1,%ecx
  801c0b:	74 1d                	je     801c2a <strlcpy+0x36>
  801c0d:	0f b6 1a             	movzbl (%edx),%ebx
  801c10:	84 db                	test   %bl,%bl
  801c12:	74 16                	je     801c2a <strlcpy+0x36>
			*dst++ = *src++;
  801c14:	88 18                	mov    %bl,(%eax)
  801c16:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c19:	83 e9 01             	sub    $0x1,%ecx
  801c1c:	74 0e                	je     801c2c <strlcpy+0x38>
			*dst++ = *src++;
  801c1e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c21:	0f b6 1a             	movzbl (%edx),%ebx
  801c24:	84 db                	test   %bl,%bl
  801c26:	75 ec                	jne    801c14 <strlcpy+0x20>
  801c28:	eb 02                	jmp    801c2c <strlcpy+0x38>
  801c2a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c2c:	c6 00 00             	movb   $0x0,(%eax)
  801c2f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c3e:	0f b6 01             	movzbl (%ecx),%eax
  801c41:	84 c0                	test   %al,%al
  801c43:	74 15                	je     801c5a <strcmp+0x25>
  801c45:	3a 02                	cmp    (%edx),%al
  801c47:	75 11                	jne    801c5a <strcmp+0x25>
		p++, q++;
  801c49:	83 c1 01             	add    $0x1,%ecx
  801c4c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c4f:	0f b6 01             	movzbl (%ecx),%eax
  801c52:	84 c0                	test   %al,%al
  801c54:	74 04                	je     801c5a <strcmp+0x25>
  801c56:	3a 02                	cmp    (%edx),%al
  801c58:	74 ef                	je     801c49 <strcmp+0x14>
  801c5a:	0f b6 c0             	movzbl %al,%eax
  801c5d:	0f b6 12             	movzbl (%edx),%edx
  801c60:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	53                   	push   %ebx
  801c68:	8b 55 08             	mov    0x8(%ebp),%edx
  801c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801c71:	85 c0                	test   %eax,%eax
  801c73:	74 23                	je     801c98 <strncmp+0x34>
  801c75:	0f b6 1a             	movzbl (%edx),%ebx
  801c78:	84 db                	test   %bl,%bl
  801c7a:	74 25                	je     801ca1 <strncmp+0x3d>
  801c7c:	3a 19                	cmp    (%ecx),%bl
  801c7e:	75 21                	jne    801ca1 <strncmp+0x3d>
  801c80:	83 e8 01             	sub    $0x1,%eax
  801c83:	74 13                	je     801c98 <strncmp+0x34>
		n--, p++, q++;
  801c85:	83 c2 01             	add    $0x1,%edx
  801c88:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c8b:	0f b6 1a             	movzbl (%edx),%ebx
  801c8e:	84 db                	test   %bl,%bl
  801c90:	74 0f                	je     801ca1 <strncmp+0x3d>
  801c92:	3a 19                	cmp    (%ecx),%bl
  801c94:	74 ea                	je     801c80 <strncmp+0x1c>
  801c96:	eb 09                	jmp    801ca1 <strncmp+0x3d>
  801c98:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c9d:	5b                   	pop    %ebx
  801c9e:	5d                   	pop    %ebp
  801c9f:	90                   	nop
  801ca0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ca1:	0f b6 02             	movzbl (%edx),%eax
  801ca4:	0f b6 11             	movzbl (%ecx),%edx
  801ca7:	29 d0                	sub    %edx,%eax
  801ca9:	eb f2                	jmp    801c9d <strncmp+0x39>

00801cab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb5:	0f b6 10             	movzbl (%eax),%edx
  801cb8:	84 d2                	test   %dl,%dl
  801cba:	74 18                	je     801cd4 <strchr+0x29>
		if (*s == c)
  801cbc:	38 ca                	cmp    %cl,%dl
  801cbe:	75 0a                	jne    801cca <strchr+0x1f>
  801cc0:	eb 17                	jmp    801cd9 <strchr+0x2e>
  801cc2:	38 ca                	cmp    %cl,%dl
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	74 0f                	je     801cd9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cca:	83 c0 01             	add    $0x1,%eax
  801ccd:	0f b6 10             	movzbl (%eax),%edx
  801cd0:	84 d2                	test   %dl,%dl
  801cd2:	75 ee                	jne    801cc2 <strchr+0x17>
  801cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ce5:	0f b6 10             	movzbl (%eax),%edx
  801ce8:	84 d2                	test   %dl,%dl
  801cea:	74 18                	je     801d04 <strfind+0x29>
		if (*s == c)
  801cec:	38 ca                	cmp    %cl,%dl
  801cee:	75 0a                	jne    801cfa <strfind+0x1f>
  801cf0:	eb 12                	jmp    801d04 <strfind+0x29>
  801cf2:	38 ca                	cmp    %cl,%dl
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	74 0a                	je     801d04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801cfa:	83 c0 01             	add    $0x1,%eax
  801cfd:	0f b6 10             	movzbl (%eax),%edx
  801d00:	84 d2                	test   %dl,%dl
  801d02:	75 ee                	jne    801cf2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	83 ec 0c             	sub    $0xc,%esp
  801d0c:	89 1c 24             	mov    %ebx,(%esp)
  801d0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801d17:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d20:	85 c9                	test   %ecx,%ecx
  801d22:	74 30                	je     801d54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d2a:	75 25                	jne    801d51 <memset+0x4b>
  801d2c:	f6 c1 03             	test   $0x3,%cl
  801d2f:	75 20                	jne    801d51 <memset+0x4b>
		c &= 0xFF;
  801d31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d34:	89 d3                	mov    %edx,%ebx
  801d36:	c1 e3 08             	shl    $0x8,%ebx
  801d39:	89 d6                	mov    %edx,%esi
  801d3b:	c1 e6 18             	shl    $0x18,%esi
  801d3e:	89 d0                	mov    %edx,%eax
  801d40:	c1 e0 10             	shl    $0x10,%eax
  801d43:	09 f0                	or     %esi,%eax
  801d45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801d47:	09 d8                	or     %ebx,%eax
  801d49:	c1 e9 02             	shr    $0x2,%ecx
  801d4c:	fc                   	cld    
  801d4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d4f:	eb 03                	jmp    801d54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d51:	fc                   	cld    
  801d52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d54:	89 f8                	mov    %edi,%eax
  801d56:	8b 1c 24             	mov    (%esp),%ebx
  801d59:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801d61:	89 ec                	mov    %ebp,%esp
  801d63:	5d                   	pop    %ebp
  801d64:	c3                   	ret    

00801d65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 08             	sub    $0x8,%esp
  801d6b:	89 34 24             	mov    %esi,(%esp)
  801d6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801d72:	8b 45 08             	mov    0x8(%ebp),%eax
  801d75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801d78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801d7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801d7d:	39 c6                	cmp    %eax,%esi
  801d7f:	73 35                	jae    801db6 <memmove+0x51>
  801d81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d84:	39 d0                	cmp    %edx,%eax
  801d86:	73 2e                	jae    801db6 <memmove+0x51>
		s += n;
		d += n;
  801d88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d8a:	f6 c2 03             	test   $0x3,%dl
  801d8d:	75 1b                	jne    801daa <memmove+0x45>
  801d8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d95:	75 13                	jne    801daa <memmove+0x45>
  801d97:	f6 c1 03             	test   $0x3,%cl
  801d9a:	75 0e                	jne    801daa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801d9c:	83 ef 04             	sub    $0x4,%edi
  801d9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801da2:	c1 e9 02             	shr    $0x2,%ecx
  801da5:	fd                   	std    
  801da6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801da8:	eb 09                	jmp    801db3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801daa:	83 ef 01             	sub    $0x1,%edi
  801dad:	8d 72 ff             	lea    -0x1(%edx),%esi
  801db0:	fd                   	std    
  801db1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801db3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801db4:	eb 20                	jmp    801dd6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801db6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801dbc:	75 15                	jne    801dd3 <memmove+0x6e>
  801dbe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801dc4:	75 0d                	jne    801dd3 <memmove+0x6e>
  801dc6:	f6 c1 03             	test   $0x3,%cl
  801dc9:	75 08                	jne    801dd3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801dcb:	c1 e9 02             	shr    $0x2,%ecx
  801dce:	fc                   	cld    
  801dcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dd1:	eb 03                	jmp    801dd6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dd3:	fc                   	cld    
  801dd4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dd6:	8b 34 24             	mov    (%esp),%esi
  801dd9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801ddd:	89 ec                	mov    %ebp,%esp
  801ddf:	5d                   	pop    %ebp
  801de0:	c3                   	ret    

00801de1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801de1:	55                   	push   %ebp
  801de2:	89 e5                	mov    %esp,%ebp
  801de4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801de7:	8b 45 10             	mov    0x10(%ebp),%eax
  801dea:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801df5:	8b 45 08             	mov    0x8(%ebp),%eax
  801df8:	89 04 24             	mov    %eax,(%esp)
  801dfb:	e8 65 ff ff ff       	call   801d65 <memmove>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	57                   	push   %edi
  801e06:	56                   	push   %esi
  801e07:	53                   	push   %ebx
  801e08:	8b 75 08             	mov    0x8(%ebp),%esi
  801e0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801e0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e11:	85 c9                	test   %ecx,%ecx
  801e13:	74 36                	je     801e4b <memcmp+0x49>
		if (*s1 != *s2)
  801e15:	0f b6 06             	movzbl (%esi),%eax
  801e18:	0f b6 1f             	movzbl (%edi),%ebx
  801e1b:	38 d8                	cmp    %bl,%al
  801e1d:	74 20                	je     801e3f <memcmp+0x3d>
  801e1f:	eb 14                	jmp    801e35 <memcmp+0x33>
  801e21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801e26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801e2b:	83 c2 01             	add    $0x1,%edx
  801e2e:	83 e9 01             	sub    $0x1,%ecx
  801e31:	38 d8                	cmp    %bl,%al
  801e33:	74 12                	je     801e47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801e35:	0f b6 c0             	movzbl %al,%eax
  801e38:	0f b6 db             	movzbl %bl,%ebx
  801e3b:	29 d8                	sub    %ebx,%eax
  801e3d:	eb 11                	jmp    801e50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e3f:	83 e9 01             	sub    $0x1,%ecx
  801e42:	ba 00 00 00 00       	mov    $0x0,%edx
  801e47:	85 c9                	test   %ecx,%ecx
  801e49:	75 d6                	jne    801e21 <memcmp+0x1f>
  801e4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    

00801e55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e5b:	89 c2                	mov    %eax,%edx
  801e5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e60:	39 d0                	cmp    %edx,%eax
  801e62:	73 15                	jae    801e79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801e68:	38 08                	cmp    %cl,(%eax)
  801e6a:	75 06                	jne    801e72 <memfind+0x1d>
  801e6c:	eb 0b                	jmp    801e79 <memfind+0x24>
  801e6e:	38 08                	cmp    %cl,(%eax)
  801e70:	74 07                	je     801e79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e72:	83 c0 01             	add    $0x1,%eax
  801e75:	39 c2                	cmp    %eax,%edx
  801e77:	77 f5                	ja     801e6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e79:	5d                   	pop    %ebp
  801e7a:	c3                   	ret    

00801e7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	57                   	push   %edi
  801e7f:	56                   	push   %esi
  801e80:	53                   	push   %ebx
  801e81:	83 ec 04             	sub    $0x4,%esp
  801e84:	8b 55 08             	mov    0x8(%ebp),%edx
  801e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e8a:	0f b6 02             	movzbl (%edx),%eax
  801e8d:	3c 20                	cmp    $0x20,%al
  801e8f:	74 04                	je     801e95 <strtol+0x1a>
  801e91:	3c 09                	cmp    $0x9,%al
  801e93:	75 0e                	jne    801ea3 <strtol+0x28>
		s++;
  801e95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e98:	0f b6 02             	movzbl (%edx),%eax
  801e9b:	3c 20                	cmp    $0x20,%al
  801e9d:	74 f6                	je     801e95 <strtol+0x1a>
  801e9f:	3c 09                	cmp    $0x9,%al
  801ea1:	74 f2                	je     801e95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801ea3:	3c 2b                	cmp    $0x2b,%al
  801ea5:	75 0c                	jne    801eb3 <strtol+0x38>
		s++;
  801ea7:	83 c2 01             	add    $0x1,%edx
  801eaa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801eb1:	eb 15                	jmp    801ec8 <strtol+0x4d>
	else if (*s == '-')
  801eb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801eba:	3c 2d                	cmp    $0x2d,%al
  801ebc:	75 0a                	jne    801ec8 <strtol+0x4d>
		s++, neg = 1;
  801ebe:	83 c2 01             	add    $0x1,%edx
  801ec1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801ec8:	85 db                	test   %ebx,%ebx
  801eca:	0f 94 c0             	sete   %al
  801ecd:	74 05                	je     801ed4 <strtol+0x59>
  801ecf:	83 fb 10             	cmp    $0x10,%ebx
  801ed2:	75 18                	jne    801eec <strtol+0x71>
  801ed4:	80 3a 30             	cmpb   $0x30,(%edx)
  801ed7:	75 13                	jne    801eec <strtol+0x71>
  801ed9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801edd:	8d 76 00             	lea    0x0(%esi),%esi
  801ee0:	75 0a                	jne    801eec <strtol+0x71>
		s += 2, base = 16;
  801ee2:	83 c2 02             	add    $0x2,%edx
  801ee5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801eea:	eb 15                	jmp    801f01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eec:	84 c0                	test   %al,%al
  801eee:	66 90                	xchg   %ax,%ax
  801ef0:	74 0f                	je     801f01 <strtol+0x86>
  801ef2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801ef7:	80 3a 30             	cmpb   $0x30,(%edx)
  801efa:	75 05                	jne    801f01 <strtol+0x86>
		s++, base = 8;
  801efc:	83 c2 01             	add    $0x1,%edx
  801eff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f01:	b8 00 00 00 00       	mov    $0x0,%eax
  801f06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f08:	0f b6 0a             	movzbl (%edx),%ecx
  801f0b:	89 cf                	mov    %ecx,%edi
  801f0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801f10:	80 fb 09             	cmp    $0x9,%bl
  801f13:	77 08                	ja     801f1d <strtol+0xa2>
			dig = *s - '0';
  801f15:	0f be c9             	movsbl %cl,%ecx
  801f18:	83 e9 30             	sub    $0x30,%ecx
  801f1b:	eb 1e                	jmp    801f3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801f1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801f20:	80 fb 19             	cmp    $0x19,%bl
  801f23:	77 08                	ja     801f2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801f25:	0f be c9             	movsbl %cl,%ecx
  801f28:	83 e9 57             	sub    $0x57,%ecx
  801f2b:	eb 0e                	jmp    801f3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801f2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801f30:	80 fb 19             	cmp    $0x19,%bl
  801f33:	77 15                	ja     801f4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801f35:	0f be c9             	movsbl %cl,%ecx
  801f38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801f3b:	39 f1                	cmp    %esi,%ecx
  801f3d:	7d 0b                	jge    801f4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801f3f:	83 c2 01             	add    $0x1,%edx
  801f42:	0f af c6             	imul   %esi,%eax
  801f45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801f48:	eb be                	jmp    801f08 <strtol+0x8d>
  801f4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801f4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f50:	74 05                	je     801f57 <strtol+0xdc>
		*endptr = (char *) s;
  801f52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801f57:	89 ca                	mov    %ecx,%edx
  801f59:	f7 da                	neg    %edx
  801f5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801f5f:	0f 45 c2             	cmovne %edx,%eax
}
  801f62:	83 c4 04             	add    $0x4,%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5f                   	pop    %edi
  801f68:	5d                   	pop    %ebp
  801f69:	c3                   	ret    
  801f6a:	00 00                	add    %al,(%eax)
  801f6c:	00 00                	add    %al,(%eax)
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
  801fe0:	c7 44 24 08 60 28 80 	movl   $0x802860,0x8(%esp)
  801fe7:	00 
  801fe8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801fef:	00 
  801ff0:	c7 04 24 7e 28 80 00 	movl   $0x80287e,(%esp)
  801ff7:	e8 88 f3 ff ff       	call   801384 <_panic>
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
  80200e:	e8 9b e2 ff ff       	call   8002ae <sys_ipc_try_send>
  802013:	85 c0                	test   %eax,%eax
  802015:	75 c0                	jne    801fd7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802017:	e8 18 e4 ff ff       	call   800434 <sys_yield>
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
  802049:	e8 27 e2 ff ff       	call   800275 <sys_ipc_recv>
  80204e:	89 c3                	mov    %eax,%ebx
  802050:	85 c0                	test   %eax,%eax
  802052:	79 2a                	jns    80207e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802054:	89 44 24 08          	mov    %eax,0x8(%esp)
  802058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80205c:	c7 04 24 88 28 80 00 	movl   $0x802888,(%esp)
  802063:	e8 d5 f3 ff ff       	call   80143d <cprintf>
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
  802082:	a1 20 60 80 00       	mov    0x806020,%eax
  802087:	8b 40 74             	mov    0x74(%eax),%eax
  80208a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80208c:	85 ff                	test   %edi,%edi
  80208e:	74 0a                	je     80209a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802090:	a1 20 60 80 00       	mov    0x806020,%eax
  802095:	8b 40 78             	mov    0x78(%eax),%eax
  802098:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80209a:	a1 20 60 80 00       	mov    0x806020,%eax
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
