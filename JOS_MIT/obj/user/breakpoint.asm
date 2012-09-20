
obj/user/breakpoint.debug:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800045:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800048:	8b 75 08             	mov    0x8(%ebp),%esi
  80004b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80004e:	e8 70 03 00 00       	call   8003c3 <sys_getenvid>
  800053:	25 ff 03 00 00       	and    $0x3ff,%eax
  800058:	c1 e0 07             	shl    $0x7,%eax
  80005b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800060:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800065:	85 f6                	test   %esi,%esi
  800067:	7e 07                	jle    800070 <libmain+0x34>
		binaryname = argv[0];
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800070:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800074:	89 34 24             	mov    %esi,(%esp)
  800077:	e8 b8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0b 00 00 00       	call   80008c <exit>
}
  800081:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800084:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800087:	89 ec                	mov    %ebp,%esp
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800092:	e8 02 09 00 00       	call   800999 <close_all>
	sys_env_destroy(0);
  800097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009e:	e8 5b 03 00 00       	call   8003fe <sys_env_destroy>
}
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    
  8000a5:	00 00                	add    %al,(%eax)
	...

008000a8 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 48             	sub    $0x48,%esp
  8000ae:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000bc:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c7:	51                   	push   %ecx
  8000c8:	52                   	push   %edx
  8000c9:	53                   	push   %ebx
  8000ca:	54                   	push   %esp
  8000cb:	55                   	push   %ebp
  8000cc:	56                   	push   %esi
  8000cd:	57                   	push   %edi
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	8d 35 d8 00 80 00    	lea    0x8000d8,%esi
  8000d6:	0f 34                	sysenter 

008000d8 <.after_sysenter_label>:
  8000d8:	5f                   	pop    %edi
  8000d9:	5e                   	pop    %esi
  8000da:	5d                   	pop    %ebp
  8000db:	5c                   	pop    %esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5a                   	pop    %edx
  8000de:	59                   	pop    %ecx
  8000df:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000e1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e5:	74 28                	je     80010f <.after_sysenter_label+0x37>
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	7e 24                	jle    80010f <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ef:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000f3:	c7 44 24 08 aa 22 80 	movl   $0x8022aa,0x8(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800102:	00 
  800103:	c7 04 24 c7 22 80 00 	movl   $0x8022c7,(%esp)
  80010a:	e8 95 11 00 00       	call   8012a4 <_panic>

	return ret;
}
  80010f:	89 d0                	mov    %edx,%eax
  800111:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800114:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800117:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80011a:	89 ec                	mov    %ebp,%esp
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    

0080011e <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800124:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012b:	00 
  80012c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800133:	00 
  800134:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80013b:	00 
  80013c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80013f:	89 04 24             	mov    %eax,(%esp)
  800142:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 10 00 00 00       	mov    $0x10,%eax
  80014f:	e8 54 ff ff ff       	call   8000a8 <syscall>
}
  800154:	c9                   	leave  
  800155:	c3                   	ret    

00800156 <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  80015c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800163:	00 
  800164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80016b:	00 
  80016c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800173:	00 
  800174:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0f 00 00 00       	mov    $0xf,%eax
  80018a:	e8 19 ff ff ff       	call   8000a8 <syscall>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800197:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80019e:	00 
  80019f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001a6:	00 
  8001a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ae:	00 
  8001af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001be:	b8 0e 00 00 00       	mov    $0xe,%eax
  8001c3:	e8 e0 fe ff ff       	call   8000a8 <syscall>
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8001d0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d7:	00 
  8001d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001df:	8b 45 10             	mov    0x10(%ebp),%eax
  8001e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001e9:	89 04 24             	mov    %eax,(%esp)
  8001ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8001f4:	b8 0d 00 00 00       	mov    $0xd,%eax
  8001f9:	e8 aa fe ff ff       	call   8000a8 <syscall>
}
  8001fe:	c9                   	leave  
  8001ff:	c3                   	ret    

00800200 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800206:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020d:	00 
  80020e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800215:	00 
  800216:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80021d:	00 
  80021e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800221:	89 04 24             	mov    %eax,(%esp)
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	ba 01 00 00 00       	mov    $0x1,%edx
  80022c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800231:	e8 72 fe ff ff       	call   8000a8 <syscall>
}
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80023e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800245:	00 
  800246:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80024d:	00 
  80024e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800255:	00 
  800256:	8b 45 0c             	mov    0xc(%ebp),%eax
  800259:	89 04 24             	mov    %eax,(%esp)
  80025c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025f:	ba 01 00 00 00       	mov    $0x1,%edx
  800264:	b8 0a 00 00 00       	mov    $0xa,%eax
  800269:	e8 3a fe ff ff       	call   8000a8 <syscall>
}
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800276:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027d:	00 
  80027e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800285:	00 
  800286:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80028d:	00 
  80028e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800291:	89 04 24             	mov    %eax,(%esp)
  800294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800297:	ba 01 00 00 00       	mov    $0x1,%edx
  80029c:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a1:	e8 02 fe ff ff       	call   8000a8 <syscall>
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002a8:	55                   	push   %ebp
  8002a9:	89 e5                	mov    %esp,%ebp
  8002ab:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002ae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b5:	00 
  8002b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002bd:	00 
  8002be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002c5:	00 
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002cf:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d4:	b8 07 00 00 00       	mov    $0x7,%eax
  8002d9:	e8 ca fd ff ff       	call   8000a8 <syscall>
}
  8002de:	c9                   	leave  
  8002df:	c3                   	ret    

008002e0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8002e6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ed:	00 
  8002ee:	8b 45 18             	mov    0x18(%ebp),%eax
  8002f1:	0b 45 14             	or     0x14(%ebp),%eax
  8002f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800308:	ba 01 00 00 00       	mov    $0x1,%edx
  80030d:	b8 06 00 00 00       	mov    $0x6,%eax
  800312:	e8 91 fd ff ff       	call   8000a8 <syscall>
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80031f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800326:	00 
  800327:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80032e:	00 
  80032f:	8b 45 10             	mov    0x10(%ebp),%eax
  800332:	89 44 24 04          	mov    %eax,0x4(%esp)
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
  800339:	89 04 24             	mov    %eax,(%esp)
  80033c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033f:	ba 01 00 00 00       	mov    $0x1,%edx
  800344:	b8 05 00 00 00       	mov    $0x5,%eax
  800349:	e8 5a fd ff ff       	call   8000a8 <syscall>
}
  80034e:	c9                   	leave  
  80034f:	c3                   	ret    

00800350 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800356:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80035d:	00 
  80035e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800365:	00 
  800366:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80036d:	00 
  80036e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800375:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
  80037f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800384:	e8 1f fd ff ff       	call   8000a8 <syscall>
}
  800389:	c9                   	leave  
  80038a:	c3                   	ret    

0080038b <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800391:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800398:	00 
  800399:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003a0:	00 
  8003a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003a8:	00 
  8003a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ac:	89 04 24             	mov    %eax,(%esp)
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	b8 04 00 00 00       	mov    $0x4,%eax
  8003bc:	e8 e7 fc ff ff       	call   8000a8 <syscall>
}
  8003c1:	c9                   	leave  
  8003c2:	c3                   	ret    

008003c3 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8003c9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003d0:	00 
  8003d1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	b8 02 00 00 00       	mov    $0x2,%eax
  8003f7:	e8 ac fc ff ff       	call   8000a8 <syscall>
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800404:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040b:	00 
  80040c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800413:	00 
  800414:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80041b:	00 
  80041c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800423:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800426:	ba 01 00 00 00       	mov    $0x1,%edx
  80042b:	b8 03 00 00 00       	mov    $0x3,%eax
  800430:	e8 73 fc ff ff       	call   8000a8 <syscall>
}
  800435:	c9                   	leave  
  800436:	c3                   	ret    

00800437 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80043d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800444:	00 
  800445:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80044c:	00 
  80044d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800454:	00 
  800455:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800461:	ba 00 00 00 00       	mov    $0x0,%edx
  800466:	b8 01 00 00 00       	mov    $0x1,%eax
  80046b:	e8 38 fc ff ff       	call   8000a8 <syscall>
}
  800470:	c9                   	leave  
  800471:	c3                   	ret    

00800472 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800478:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80047f:	00 
  800480:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800487:	00 
  800488:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80048f:	00 
  800490:	8b 45 0c             	mov    0xc(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a3:	e8 00 fc ff ff       	call   8000a8 <syscall>
}
  8004a8:	c9                   	leave  
  8004a9:	c3                   	ret    
  8004aa:	00 00                	add    %al,(%eax)
  8004ac:	00 00                	add    %al,(%eax)
	...

008004b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004bb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c9:	89 04 24             	mov    %eax,(%esp)
  8004cc:	e8 df ff ff ff       	call   8004b0 <fd2num>
  8004d1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8004d6:	c1 e0 0c             	shl    $0xc,%eax
}
  8004d9:	c9                   	leave  
  8004da:	c3                   	ret    

008004db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	57                   	push   %edi
  8004df:	56                   	push   %esi
  8004e0:	53                   	push   %ebx
  8004e1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8004e4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8004e9:	a8 01                	test   $0x1,%al
  8004eb:	74 36                	je     800523 <fd_alloc+0x48>
  8004ed:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8004f2:	a8 01                	test   $0x1,%al
  8004f4:	74 2d                	je     800523 <fd_alloc+0x48>
  8004f6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8004fb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800500:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800505:	89 c3                	mov    %eax,%ebx
  800507:	89 c2                	mov    %eax,%edx
  800509:	c1 ea 16             	shr    $0x16,%edx
  80050c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80050f:	f6 c2 01             	test   $0x1,%dl
  800512:	74 14                	je     800528 <fd_alloc+0x4d>
  800514:	89 c2                	mov    %eax,%edx
  800516:	c1 ea 0c             	shr    $0xc,%edx
  800519:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80051c:	f6 c2 01             	test   $0x1,%dl
  80051f:	75 10                	jne    800531 <fd_alloc+0x56>
  800521:	eb 05                	jmp    800528 <fd_alloc+0x4d>
  800523:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800528:	89 1f                	mov    %ebx,(%edi)
  80052a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80052f:	eb 17                	jmp    800548 <fd_alloc+0x6d>
  800531:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800536:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80053b:	75 c8                	jne    800505 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80053d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800543:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800548:	5b                   	pop    %ebx
  800549:	5e                   	pop    %esi
  80054a:	5f                   	pop    %edi
  80054b:	5d                   	pop    %ebp
  80054c:	c3                   	ret    

0080054d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80054d:	55                   	push   %ebp
  80054e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800550:	8b 45 08             	mov    0x8(%ebp),%eax
  800553:	83 f8 1f             	cmp    $0x1f,%eax
  800556:	77 36                	ja     80058e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800558:	05 00 00 0d 00       	add    $0xd0000,%eax
  80055d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800560:	89 c2                	mov    %eax,%edx
  800562:	c1 ea 16             	shr    $0x16,%edx
  800565:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80056c:	f6 c2 01             	test   $0x1,%dl
  80056f:	74 1d                	je     80058e <fd_lookup+0x41>
  800571:	89 c2                	mov    %eax,%edx
  800573:	c1 ea 0c             	shr    $0xc,%edx
  800576:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80057d:	f6 c2 01             	test   $0x1,%dl
  800580:	74 0c                	je     80058e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800582:	8b 55 0c             	mov    0xc(%ebp),%edx
  800585:	89 02                	mov    %eax,(%edx)
  800587:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80058c:	eb 05                	jmp    800593 <fd_lookup+0x46>
  80058e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800593:	5d                   	pop    %ebp
  800594:	c3                   	ret    

00800595 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800595:	55                   	push   %ebp
  800596:	89 e5                	mov    %esp,%ebp
  800598:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80059b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80059e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a5:	89 04 24             	mov    %eax,(%esp)
  8005a8:	e8 a0 ff ff ff       	call   80054d <fd_lookup>
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	78 0e                	js     8005bf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8005b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005b7:	89 50 04             	mov    %edx,0x4(%eax)
  8005ba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8005bf:	c9                   	leave  
  8005c0:	c3                   	ret    

008005c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005c1:	55                   	push   %ebp
  8005c2:	89 e5                	mov    %esp,%ebp
  8005c4:	56                   	push   %esi
  8005c5:	53                   	push   %ebx
  8005c6:	83 ec 10             	sub    $0x10,%esp
  8005c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8005cf:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8005d4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8005d9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8005df:	75 11                	jne    8005f2 <dev_lookup+0x31>
  8005e1:	eb 04                	jmp    8005e7 <dev_lookup+0x26>
  8005e3:	39 08                	cmp    %ecx,(%eax)
  8005e5:	75 10                	jne    8005f7 <dev_lookup+0x36>
			*dev = devtab[i];
  8005e7:	89 03                	mov    %eax,(%ebx)
  8005e9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8005ee:	66 90                	xchg   %ax,%ax
  8005f0:	eb 36                	jmp    800628 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005f2:	be 54 23 80 00       	mov    $0x802354,%esi
  8005f7:	83 c2 01             	add    $0x1,%edx
  8005fa:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	75 e2                	jne    8005e3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800601:	a1 08 40 80 00       	mov    0x804008,%eax
  800606:	8b 40 48             	mov    0x48(%eax),%eax
  800609:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800611:	c7 04 24 d8 22 80 00 	movl   $0x8022d8,(%esp)
  800618:	e8 40 0d 00 00       	call   80135d <cprintf>
	*dev = 0;
  80061d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800623:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5d                   	pop    %ebp
  80062e:	c3                   	ret    

0080062f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80062f:	55                   	push   %ebp
  800630:	89 e5                	mov    %esp,%ebp
  800632:	53                   	push   %ebx
  800633:	83 ec 24             	sub    $0x24,%esp
  800636:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800639:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800640:	8b 45 08             	mov    0x8(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 02 ff ff ff       	call   80054d <fd_lookup>
  80064b:	85 c0                	test   %eax,%eax
  80064d:	78 53                	js     8006a2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800652:	89 44 24 04          	mov    %eax,0x4(%esp)
  800656:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	89 04 24             	mov    %eax,(%esp)
  80065e:	e8 5e ff ff ff       	call   8005c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800663:	85 c0                	test   %eax,%eax
  800665:	78 3b                	js     8006a2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800667:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80066c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80066f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800673:	74 2d                	je     8006a2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800675:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800678:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80067f:	00 00 00 
	stat->st_isdir = 0;
  800682:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800689:	00 00 00 
	stat->st_dev = dev;
  80068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800695:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800699:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069c:	89 14 24             	mov    %edx,(%esp)
  80069f:	ff 50 14             	call   *0x14(%eax)
}
  8006a2:	83 c4 24             	add    $0x24,%esp
  8006a5:	5b                   	pop    %ebx
  8006a6:	5d                   	pop    %ebp
  8006a7:	c3                   	ret    

008006a8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8006a8:	55                   	push   %ebp
  8006a9:	89 e5                	mov    %esp,%ebp
  8006ab:	53                   	push   %ebx
  8006ac:	83 ec 24             	sub    $0x24,%esp
  8006af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b9:	89 1c 24             	mov    %ebx,(%esp)
  8006bc:	e8 8c fe ff ff       	call   80054d <fd_lookup>
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	78 5f                	js     800724 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	89 04 24             	mov    %eax,(%esp)
  8006d4:	e8 e8 fe ff ff       	call   8005c1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	78 47                	js     800724 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006e0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8006e4:	75 23                	jne    800709 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8006e6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8006eb:	8b 40 48             	mov    0x48(%eax),%eax
  8006ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	c7 04 24 f8 22 80 00 	movl   $0x8022f8,(%esp)
  8006fd:	e8 5b 0c 00 00       	call   80135d <cprintf>
  800702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800707:	eb 1b                	jmp    800724 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800709:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070c:	8b 48 18             	mov    0x18(%eax),%ecx
  80070f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800714:	85 c9                	test   %ecx,%ecx
  800716:	74 0c                	je     800724 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800718:	8b 45 0c             	mov    0xc(%ebp),%eax
  80071b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071f:	89 14 24             	mov    %edx,(%esp)
  800722:	ff d1                	call   *%ecx
}
  800724:	83 c4 24             	add    $0x24,%esp
  800727:	5b                   	pop    %ebx
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    

0080072a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80072a:	55                   	push   %ebp
  80072b:	89 e5                	mov    %esp,%ebp
  80072d:	53                   	push   %ebx
  80072e:	83 ec 24             	sub    $0x24,%esp
  800731:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800734:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800737:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073b:	89 1c 24             	mov    %ebx,(%esp)
  80073e:	e8 0a fe ff ff       	call   80054d <fd_lookup>
  800743:	85 c0                	test   %eax,%eax
  800745:	78 66                	js     8007ad <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800747:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800751:	8b 00                	mov    (%eax),%eax
  800753:	89 04 24             	mov    %eax,(%esp)
  800756:	e8 66 fe ff ff       	call   8005c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075b:	85 c0                	test   %eax,%eax
  80075d:	78 4e                	js     8007ad <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800762:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800766:	75 23                	jne    80078b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800768:	a1 08 40 80 00       	mov    0x804008,%eax
  80076d:	8b 40 48             	mov    0x48(%eax),%eax
  800770:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	c7 04 24 19 23 80 00 	movl   $0x802319,(%esp)
  80077f:	e8 d9 0b 00 00       	call   80135d <cprintf>
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800789:	eb 22                	jmp    8007ad <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078e:	8b 48 0c             	mov    0xc(%eax),%ecx
  800791:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800796:	85 c9                	test   %ecx,%ecx
  800798:	74 13                	je     8007ad <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80079a:	8b 45 10             	mov    0x10(%ebp),%eax
  80079d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a8:	89 14 24             	mov    %edx,(%esp)
  8007ab:	ff d1                	call   *%ecx
}
  8007ad:	83 c4 24             	add    $0x24,%esp
  8007b0:	5b                   	pop    %ebx
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    

008007b3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	83 ec 24             	sub    $0x24,%esp
  8007ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	89 1c 24             	mov    %ebx,(%esp)
  8007c7:	e8 81 fd ff ff       	call   80054d <fd_lookup>
  8007cc:	85 c0                	test   %eax,%eax
  8007ce:	78 6b                	js     80083b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007da:	8b 00                	mov    (%eax),%eax
  8007dc:	89 04 24             	mov    %eax,(%esp)
  8007df:	e8 dd fd ff ff       	call   8005c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e4:	85 c0                	test   %eax,%eax
  8007e6:	78 53                	js     80083b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8007eb:	8b 42 08             	mov    0x8(%edx),%eax
  8007ee:	83 e0 03             	and    $0x3,%eax
  8007f1:	83 f8 01             	cmp    $0x1,%eax
  8007f4:	75 23                	jne    800819 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8007fb:	8b 40 48             	mov    0x48(%eax),%eax
  8007fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800802:	89 44 24 04          	mov    %eax,0x4(%esp)
  800806:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  80080d:	e8 4b 0b 00 00       	call   80135d <cprintf>
  800812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800817:	eb 22                	jmp    80083b <read+0x88>
	}
	if (!dev->dev_read)
  800819:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80081c:	8b 48 08             	mov    0x8(%eax),%ecx
  80081f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800824:	85 c9                	test   %ecx,%ecx
  800826:	74 13                	je     80083b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800828:	8b 45 10             	mov    0x10(%ebp),%eax
  80082b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800832:	89 44 24 04          	mov    %eax,0x4(%esp)
  800836:	89 14 24             	mov    %edx,(%esp)
  800839:	ff d1                	call   *%ecx
}
  80083b:	83 c4 24             	add    $0x24,%esp
  80083e:	5b                   	pop    %ebx
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	57                   	push   %edi
  800845:	56                   	push   %esi
  800846:	53                   	push   %ebx
  800847:	83 ec 1c             	sub    $0x1c,%esp
  80084a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80084d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800850:	ba 00 00 00 00       	mov    $0x0,%edx
  800855:	bb 00 00 00 00       	mov    $0x0,%ebx
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
  80085f:	85 f6                	test   %esi,%esi
  800861:	74 29                	je     80088c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800863:	89 f0                	mov    %esi,%eax
  800865:	29 d0                	sub    %edx,%eax
  800867:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086b:	03 55 0c             	add    0xc(%ebp),%edx
  80086e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800872:	89 3c 24             	mov    %edi,(%esp)
  800875:	e8 39 ff ff ff       	call   8007b3 <read>
		if (m < 0)
  80087a:	85 c0                	test   %eax,%eax
  80087c:	78 0e                	js     80088c <readn+0x4b>
			return m;
		if (m == 0)
  80087e:	85 c0                	test   %eax,%eax
  800880:	74 08                	je     80088a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800882:	01 c3                	add    %eax,%ebx
  800884:	89 da                	mov    %ebx,%edx
  800886:	39 f3                	cmp    %esi,%ebx
  800888:	72 d9                	jb     800863 <readn+0x22>
  80088a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80088c:	83 c4 1c             	add    $0x1c,%esp
  80088f:	5b                   	pop    %ebx
  800890:	5e                   	pop    %esi
  800891:	5f                   	pop    %edi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	83 ec 28             	sub    $0x28,%esp
  80089a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80089d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8008a0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008a3:	89 34 24             	mov    %esi,(%esp)
  8008a6:	e8 05 fc ff ff       	call   8004b0 <fd2num>
  8008ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b2:	89 04 24             	mov    %eax,(%esp)
  8008b5:	e8 93 fc ff ff       	call   80054d <fd_lookup>
  8008ba:	89 c3                	mov    %eax,%ebx
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	78 05                	js     8008c5 <fd_close+0x31>
  8008c0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008c3:	74 0e                	je     8008d3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8008c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ce:	0f 44 d8             	cmove  %eax,%ebx
  8008d1:	eb 3d                	jmp    800910 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	8b 06                	mov    (%esi),%eax
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	e8 dd fc ff ff       	call   8005c1 <dev_lookup>
  8008e4:	89 c3                	mov    %eax,%ebx
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	78 16                	js     800900 <fd_close+0x6c>
		if (dev->dev_close)
  8008ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ed:	8b 40 10             	mov    0x10(%eax),%eax
  8008f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	74 07                	je     800900 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8008f9:	89 34 24             	mov    %esi,(%esp)
  8008fc:	ff d0                	call   *%eax
  8008fe:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800900:	89 74 24 04          	mov    %esi,0x4(%esp)
  800904:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80090b:	e8 98 f9 ff ff       	call   8002a8 <sys_page_unmap>
	return r;
}
  800910:	89 d8                	mov    %ebx,%eax
  800912:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800915:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800918:	89 ec                	mov    %ebp,%esp
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800922:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800925:	89 44 24 04          	mov    %eax,0x4(%esp)
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	89 04 24             	mov    %eax,(%esp)
  80092f:	e8 19 fc ff ff       	call   80054d <fd_lookup>
  800934:	85 c0                	test   %eax,%eax
  800936:	78 13                	js     80094b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800938:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80093f:	00 
  800940:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800943:	89 04 24             	mov    %eax,(%esp)
  800946:	e8 49 ff ff ff       	call   800894 <fd_close>
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80094d:	55                   	push   %ebp
  80094e:	89 e5                	mov    %esp,%ebp
  800950:	83 ec 18             	sub    $0x18,%esp
  800953:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800956:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800959:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800960:	00 
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	89 04 24             	mov    %eax,(%esp)
  800967:	e8 78 03 00 00       	call   800ce4 <open>
  80096c:	89 c3                	mov    %eax,%ebx
  80096e:	85 c0                	test   %eax,%eax
  800970:	78 1b                	js     80098d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800972:	8b 45 0c             	mov    0xc(%ebp),%eax
  800975:	89 44 24 04          	mov    %eax,0x4(%esp)
  800979:	89 1c 24             	mov    %ebx,(%esp)
  80097c:	e8 ae fc ff ff       	call   80062f <fstat>
  800981:	89 c6                	mov    %eax,%esi
	close(fd);
  800983:	89 1c 24             	mov    %ebx,(%esp)
  800986:	e8 91 ff ff ff       	call   80091c <close>
  80098b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80098d:	89 d8                	mov    %ebx,%eax
  80098f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800992:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800995:	89 ec                	mov    %ebp,%esp
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	53                   	push   %ebx
  80099d:	83 ec 14             	sub    $0x14,%esp
  8009a0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8009a5:	89 1c 24             	mov    %ebx,(%esp)
  8009a8:	e8 6f ff ff ff       	call   80091c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009ad:	83 c3 01             	add    $0x1,%ebx
  8009b0:	83 fb 20             	cmp    $0x20,%ebx
  8009b3:	75 f0                	jne    8009a5 <close_all+0xc>
		close(i);
}
  8009b5:	83 c4 14             	add    $0x14,%esp
  8009b8:	5b                   	pop    %ebx
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 58             	sub    $0x58,%esp
  8009c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	89 04 24             	mov    %eax,(%esp)
  8009da:	e8 6e fb ff ff       	call   80054d <fd_lookup>
  8009df:	89 c3                	mov    %eax,%ebx
  8009e1:	85 c0                	test   %eax,%eax
  8009e3:	0f 88 e0 00 00 00    	js     800ac9 <dup+0x10e>
		return r;
	close(newfdnum);
  8009e9:	89 3c 24             	mov    %edi,(%esp)
  8009ec:	e8 2b ff ff ff       	call   80091c <close>

	newfd = INDEX2FD(newfdnum);
  8009f1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8009f7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8009fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009fd:	89 04 24             	mov    %eax,(%esp)
  800a00:	e8 bb fa ff ff       	call   8004c0 <fd2data>
  800a05:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a07:	89 34 24             	mov    %esi,(%esp)
  800a0a:	e8 b1 fa ff ff       	call   8004c0 <fd2data>
  800a0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800a12:	89 da                	mov    %ebx,%edx
  800a14:	89 d8                	mov    %ebx,%eax
  800a16:	c1 e8 16             	shr    $0x16,%eax
  800a19:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a20:	a8 01                	test   $0x1,%al
  800a22:	74 43                	je     800a67 <dup+0xac>
  800a24:	c1 ea 0c             	shr    $0xc,%edx
  800a27:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a2e:	a8 01                	test   $0x1,%al
  800a30:	74 35                	je     800a67 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a32:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a39:	25 07 0e 00 00       	and    $0xe07,%eax
  800a3e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a42:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a45:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a49:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a50:	00 
  800a51:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a5c:	e8 7f f8 ff ff       	call   8002e0 <sys_page_map>
  800a61:	89 c3                	mov    %eax,%ebx
  800a63:	85 c0                	test   %eax,%eax
  800a65:	78 3f                	js     800aa6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a6a:	89 c2                	mov    %eax,%edx
  800a6c:	c1 ea 0c             	shr    $0xc,%edx
  800a6f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a76:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a7c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a80:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a84:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a8b:	00 
  800a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a90:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a97:	e8 44 f8 ff ff       	call   8002e0 <sys_page_map>
  800a9c:	89 c3                	mov    %eax,%ebx
  800a9e:	85 c0                	test   %eax,%eax
  800aa0:	78 04                	js     800aa6 <dup+0xeb>
  800aa2:	89 fb                	mov    %edi,%ebx
  800aa4:	eb 23                	jmp    800ac9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800aa6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aaa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ab1:	e8 f2 f7 ff ff       	call   8002a8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ab6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800abd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ac4:	e8 df f7 ff ff       	call   8002a8 <sys_page_unmap>
	return r;
}
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ace:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ad1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ad4:	89 ec                	mov    %ebp,%esp
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 18             	sub    $0x18,%esp
  800ade:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ae1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ae4:	89 c3                	mov    %eax,%ebx
  800ae6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800ae8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800aef:	75 11                	jne    800b02 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800af1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800af8:	e8 93 13 00 00       	call   801e90 <ipc_find_env>
  800afd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b02:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b09:	00 
  800b0a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b11:	00 
  800b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b16:	a1 00 40 80 00       	mov    0x804000,%eax
  800b1b:	89 04 24             	mov    %eax,(%esp)
  800b1e:	e8 b6 13 00 00       	call   801ed9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b2a:	00 
  800b2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b36:	e8 09 14 00 00       	call   801f44 <ipc_recv>
}
  800b3b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b3e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b41:	89 ec                	mov    %ebp,%esp
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 40 0c             	mov    0xc(%eax),%eax
  800b51:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b59:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b63:	b8 02 00 00 00       	mov    $0x2,%eax
  800b68:	e8 6b ff ff ff       	call   800ad8 <fsipc>
}
  800b6d:	c9                   	leave  
  800b6e:	c3                   	ret    

00800b6f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b75:	8b 45 08             	mov    0x8(%ebp),%eax
  800b78:	8b 40 0c             	mov    0xc(%eax),%eax
  800b7b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 06 00 00 00       	mov    $0x6,%eax
  800b8a:	e8 49 ff ff ff       	call   800ad8 <fsipc>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b97:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9c:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba1:	e8 32 ff ff ff       	call   800ad8 <fsipc>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	53                   	push   %ebx
  800bac:	83 ec 14             	sub    $0x14,%esp
  800baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb5:	8b 40 0c             	mov    0xc(%eax),%eax
  800bb8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc7:	e8 0c ff ff ff       	call   800ad8 <fsipc>
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	78 2b                	js     800bfb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800bd0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bd7:	00 
  800bd8:	89 1c 24             	mov    %ebx,(%esp)
  800bdb:	e8 ba 0e 00 00       	call   801a9a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800be0:	a1 80 50 80 00       	mov    0x805080,%eax
  800be5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800beb:	a1 84 50 80 00       	mov    0x805084,%eax
  800bf0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800bfb:	83 c4 14             	add    $0x14,%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5d                   	pop    %ebp
  800c00:	c3                   	ret    

00800c01 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
  800c04:	83 ec 18             	sub    $0x18,%esp
  800c07:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	8b 52 0c             	mov    0xc(%edx),%edx
  800c10:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800c16:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800c1b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800c20:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800c25:	0f 47 c2             	cmova  %edx,%eax
  800c28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c33:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800c3a:	e8 46 10 00 00       	call   801c85 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800c3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c44:	b8 04 00 00 00       	mov    $0x4,%eax
  800c49:	e8 8a fe ff ff       	call   800ad8 <fsipc>
}
  800c4e:	c9                   	leave  
  800c4f:	c3                   	ret    

00800c50 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c50:	55                   	push   %ebp
  800c51:	89 e5                	mov    %esp,%ebp
  800c53:	53                   	push   %ebx
  800c54:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c57:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5a:	8b 40 0c             	mov    0xc(%eax),%eax
  800c5d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800c62:	8b 45 10             	mov    0x10(%ebp),%eax
  800c65:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c74:	e8 5f fe ff ff       	call   800ad8 <fsipc>
  800c79:	89 c3                	mov    %eax,%ebx
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	78 17                	js     800c96 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c83:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c8a:	00 
  800c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8e:	89 04 24             	mov    %eax,(%esp)
  800c91:	e8 ef 0f 00 00       	call   801c85 <memmove>
  return r;	
}
  800c96:	89 d8                	mov    %ebx,%eax
  800c98:	83 c4 14             	add    $0x14,%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 14             	sub    $0x14,%esp
  800ca5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800ca8:	89 1c 24             	mov    %ebx,(%esp)
  800cab:	e8 a0 0d 00 00       	call   801a50 <strlen>
  800cb0:	89 c2                	mov    %eax,%edx
  800cb2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800cb7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800cbd:	7f 1f                	jg     800cde <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800cbf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cc3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cca:	e8 cb 0d 00 00       	call   801a9a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800ccf:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd4:	b8 07 00 00 00       	mov    $0x7,%eax
  800cd9:	e8 fa fd ff ff       	call   800ad8 <fsipc>
}
  800cde:	83 c4 14             	add    $0x14,%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	83 ec 28             	sub    $0x28,%esp
  800cea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ced:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800cf0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800cf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cf6:	89 04 24             	mov    %eax,(%esp)
  800cf9:	e8 dd f7 ff ff       	call   8004db <fd_alloc>
  800cfe:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800d00:	85 c0                	test   %eax,%eax
  800d02:	0f 88 89 00 00 00    	js     800d91 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d08:	89 34 24             	mov    %esi,(%esp)
  800d0b:	e8 40 0d 00 00       	call   801a50 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800d10:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800d1a:	7f 75                	jg     800d91 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800d1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d20:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d27:	e8 6e 0d 00 00       	call   801a9a <strcpy>
  fsipcbuf.open.req_omode = mode;
  800d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800d34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d37:	b8 01 00 00 00       	mov    $0x1,%eax
  800d3c:	e8 97 fd ff ff       	call   800ad8 <fsipc>
  800d41:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800d43:	85 c0                	test   %eax,%eax
  800d45:	78 0f                	js     800d56 <open+0x72>
  return fd2num(fd);
  800d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d4a:	89 04 24             	mov    %eax,(%esp)
  800d4d:	e8 5e f7 ff ff       	call   8004b0 <fd2num>
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	eb 3b                	jmp    800d91 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800d56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d5d:	00 
  800d5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d61:	89 04 24             	mov    %eax,(%esp)
  800d64:	e8 2b fb ff ff       	call   800894 <fd_close>
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	74 24                	je     800d91 <open+0xad>
  800d6d:	c7 44 24 0c 60 23 80 	movl   $0x802360,0xc(%esp)
  800d74:	00 
  800d75:	c7 44 24 08 75 23 80 	movl   $0x802375,0x8(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800d84:	00 
  800d85:	c7 04 24 8a 23 80 00 	movl   $0x80238a,(%esp)
  800d8c:	e8 13 05 00 00       	call   8012a4 <_panic>
  return r;
}
  800d91:	89 d8                	mov    %ebx,%eax
  800d93:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d96:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d99:	89 ec                	mov    %ebp,%esp
  800d9b:	5d                   	pop    %ebp
  800d9c:	c3                   	ret    
  800d9d:	00 00                	add    %al,(%eax)
	...

00800da0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800da6:	c7 44 24 04 95 23 80 	movl   $0x802395,0x4(%esp)
  800dad:	00 
  800dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db1:	89 04 24             	mov    %eax,(%esp)
  800db4:	e8 e1 0c 00 00       	call   801a9a <strcpy>
	return 0;
}
  800db9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbe:	c9                   	leave  
  800dbf:	c3                   	ret    

00800dc0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	53                   	push   %ebx
  800dc4:	83 ec 14             	sub    $0x14,%esp
  800dc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800dca:	89 1c 24             	mov    %ebx,(%esp)
  800dcd:	e8 02 12 00 00       	call   801fd4 <pageref>
  800dd2:	89 c2                	mov    %eax,%edx
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd9:	83 fa 01             	cmp    $0x1,%edx
  800ddc:	75 0b                	jne    800de9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800dde:	8b 43 0c             	mov    0xc(%ebx),%eax
  800de1:	89 04 24             	mov    %eax,(%esp)
  800de4:	e8 b9 02 00 00       	call   8010a2 <nsipc_close>
	else
		return 0;
}
  800de9:	83 c4 14             	add    $0x14,%esp
  800dec:	5b                   	pop    %ebx
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800df5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dfc:	00 
  800dfd:	8b 45 10             	mov    0x10(%ebp),%eax
  800e00:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e07:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	8b 40 0c             	mov    0xc(%eax),%eax
  800e11:	89 04 24             	mov    %eax,(%esp)
  800e14:	e8 c5 02 00 00       	call   8010de <nsipc_send>
}
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800e1b:	55                   	push   %ebp
  800e1c:	89 e5                	mov    %esp,%ebp
  800e1e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800e21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e28:	00 
  800e29:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e3d:	89 04 24             	mov    %eax,(%esp)
  800e40:	e8 0c 03 00 00       	call   801151 <nsipc_recv>
}
  800e45:	c9                   	leave  
  800e46:	c3                   	ret    

00800e47 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	56                   	push   %esi
  800e4b:	53                   	push   %ebx
  800e4c:	83 ec 20             	sub    $0x20,%esp
  800e4f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e54:	89 04 24             	mov    %eax,(%esp)
  800e57:	e8 7f f6 ff ff       	call   8004db <fd_alloc>
  800e5c:	89 c3                	mov    %eax,%ebx
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	78 21                	js     800e83 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800e62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e69:	00 
  800e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e78:	e8 9c f4 ff ff       	call   800319 <sys_page_alloc>
  800e7d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e7f:	85 c0                	test   %eax,%eax
  800e81:	79 0a                	jns    800e8d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  800e83:	89 34 24             	mov    %esi,(%esp)
  800e86:	e8 17 02 00 00       	call   8010a2 <nsipc_close>
		return r;
  800e8b:	eb 28                	jmp    800eb5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800e8d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e96:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e9b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eab:	89 04 24             	mov    %eax,(%esp)
  800eae:	e8 fd f5 ff ff       	call   8004b0 <fd2num>
  800eb3:	89 c3                	mov    %eax,%ebx
}
  800eb5:	89 d8                	mov    %ebx,%eax
  800eb7:	83 c4 20             	add    $0x20,%esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ec4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ecb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed5:	89 04 24             	mov    %eax,(%esp)
  800ed8:	e8 79 01 00 00       	call   801056 <nsipc_socket>
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 05                	js     800ee6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800ee1:	e8 61 ff ff ff       	call   800e47 <alloc_sockfd>
}
  800ee6:	c9                   	leave  
  800ee7:	c3                   	ret    

00800ee8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800eee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800ef1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef5:	89 04 24             	mov    %eax,(%esp)
  800ef8:	e8 50 f6 ff ff       	call   80054d <fd_lookup>
  800efd:	85 c0                	test   %eax,%eax
  800eff:	78 15                	js     800f16 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f04:	8b 0a                	mov    (%edx),%ecx
  800f06:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f0b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  800f11:	75 03                	jne    800f16 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f13:	8b 42 0c             	mov    0xc(%edx),%eax
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	e8 c2 ff ff ff       	call   800ee8 <fd2sockid>
  800f26:	85 c0                	test   %eax,%eax
  800f28:	78 0f                	js     800f39 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f31:	89 04 24             	mov    %eax,(%esp)
  800f34:	e8 47 01 00 00       	call   801080 <nsipc_listen>
}
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f41:	8b 45 08             	mov    0x8(%ebp),%eax
  800f44:	e8 9f ff ff ff       	call   800ee8 <fd2sockid>
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	78 16                	js     800f63 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800f4d:	8b 55 10             	mov    0x10(%ebp),%edx
  800f50:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f57:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f5b:	89 04 24             	mov    %eax,(%esp)
  800f5e:	e8 6e 02 00 00       	call   8011d1 <nsipc_connect>
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	e8 75 ff ff ff       	call   800ee8 <fd2sockid>
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 0f                	js     800f86 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800f77:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f7e:	89 04 24             	mov    %eax,(%esp)
  800f81:	e8 36 01 00 00       	call   8010bc <nsipc_shutdown>
}
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	e8 52 ff ff ff       	call   800ee8 <fd2sockid>
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 16                	js     800fb0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800f9a:	8b 55 10             	mov    0x10(%ebp),%edx
  800f9d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fa1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa8:	89 04 24             	mov    %eax,(%esp)
  800fab:	e8 60 02 00 00       	call   801210 <nsipc_bind>
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbb:	e8 28 ff ff ff       	call   800ee8 <fd2sockid>
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 1f                	js     800fe3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800fc4:	8b 55 10             	mov    0x10(%ebp),%edx
  800fc7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fcb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fce:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd2:	89 04 24             	mov    %eax,(%esp)
  800fd5:	e8 75 02 00 00       	call   80124f <nsipc_accept>
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 05                	js     800fe3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800fde:	e8 64 fe ff ff       	call   800e47 <alloc_sockfd>
}
  800fe3:	c9                   	leave  
  800fe4:	c3                   	ret    
	...

00800ff0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 14             	sub    $0x14,%esp
  800ff7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800ff9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801000:	75 11                	jne    801013 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801002:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801009:	e8 82 0e 00 00       	call   801e90 <ipc_find_env>
  80100e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801013:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80101a:	00 
  80101b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801022:	00 
  801023:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801027:	a1 04 40 80 00       	mov    0x804004,%eax
  80102c:	89 04 24             	mov    %eax,(%esp)
  80102f:	e8 a5 0e 00 00       	call   801ed9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801034:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801043:	00 
  801044:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80104b:	e8 f4 0e 00 00       	call   801f44 <ipc_recv>
}
  801050:	83 c4 14             	add    $0x14,%esp
  801053:	5b                   	pop    %ebx
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801064:	8b 45 0c             	mov    0xc(%ebp),%eax
  801067:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80106c:	8b 45 10             	mov    0x10(%ebp),%eax
  80106f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801074:	b8 09 00 00 00       	mov    $0x9,%eax
  801079:	e8 72 ff ff ff       	call   800ff0 <nsipc>
}
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80108e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801091:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801096:	b8 06 00 00 00       	mov    $0x6,%eax
  80109b:	e8 50 ff ff ff       	call   800ff0 <nsipc>
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ab:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8010b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010b5:	e8 36 ff ff ff       	call   800ff0 <nsipc>
}
  8010ba:	c9                   	leave  
  8010bb:	c3                   	ret    

008010bc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8010c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8010ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010cd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8010d2:	b8 03 00 00 00       	mov    $0x3,%eax
  8010d7:	e8 14 ff ff ff       	call   800ff0 <nsipc>
}
  8010dc:	c9                   	leave  
  8010dd:	c3                   	ret    

008010de <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 14             	sub    $0x14,%esp
  8010e5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010eb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8010f0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8010f6:	7e 24                	jle    80111c <nsipc_send+0x3e>
  8010f8:	c7 44 24 0c a1 23 80 	movl   $0x8023a1,0xc(%esp)
  8010ff:	00 
  801100:	c7 44 24 08 75 23 80 	movl   $0x802375,0x8(%esp)
  801107:	00 
  801108:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80110f:	00 
  801110:	c7 04 24 ad 23 80 00 	movl   $0x8023ad,(%esp)
  801117:	e8 88 01 00 00       	call   8012a4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80111c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801120:	8b 45 0c             	mov    0xc(%ebp),%eax
  801123:	89 44 24 04          	mov    %eax,0x4(%esp)
  801127:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80112e:	e8 52 0b 00 00       	call   801c85 <memmove>
	nsipcbuf.send.req_size = size;
  801133:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801139:	8b 45 14             	mov    0x14(%ebp),%eax
  80113c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801141:	b8 08 00 00 00       	mov    $0x8,%eax
  801146:	e8 a5 fe ff ff       	call   800ff0 <nsipc>
}
  80114b:	83 c4 14             	add    $0x14,%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 10             	sub    $0x10,%esp
  801159:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80115c:	8b 45 08             	mov    0x8(%ebp),%eax
  80115f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801164:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80116a:	8b 45 14             	mov    0x14(%ebp),%eax
  80116d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801172:	b8 07 00 00 00       	mov    $0x7,%eax
  801177:	e8 74 fe ff ff       	call   800ff0 <nsipc>
  80117c:	89 c3                	mov    %eax,%ebx
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 46                	js     8011c8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801182:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801187:	7f 04                	jg     80118d <nsipc_recv+0x3c>
  801189:	39 c6                	cmp    %eax,%esi
  80118b:	7d 24                	jge    8011b1 <nsipc_recv+0x60>
  80118d:	c7 44 24 0c b9 23 80 	movl   $0x8023b9,0xc(%esp)
  801194:	00 
  801195:	c7 44 24 08 75 23 80 	movl   $0x802375,0x8(%esp)
  80119c:	00 
  80119d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8011a4:	00 
  8011a5:	c7 04 24 ad 23 80 00 	movl   $0x8023ad,(%esp)
  8011ac:	e8 f3 00 00 00       	call   8012a4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8011b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8011bc:	00 
  8011bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011c0:	89 04 24             	mov    %eax,(%esp)
  8011c3:	e8 bd 0a 00 00       	call   801c85 <memmove>
	}

	return r;
}
  8011c8:	89 d8                	mov    %ebx,%eax
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	5b                   	pop    %ebx
  8011ce:	5e                   	pop    %esi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    

008011d1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	53                   	push   %ebx
  8011d5:	83 ec 14             	sub    $0x14,%esp
  8011d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011db:	8b 45 08             	mov    0x8(%ebp),%eax
  8011de:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8011e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ee:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8011f5:	e8 8b 0a 00 00       	call   801c85 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8011fa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801200:	b8 05 00 00 00       	mov    $0x5,%eax
  801205:	e8 e6 fd ff ff       	call   800ff0 <nsipc>
}
  80120a:	83 c4 14             	add    $0x14,%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    

00801210 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	53                   	push   %ebx
  801214:	83 ec 14             	sub    $0x14,%esp
  801217:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80121a:	8b 45 08             	mov    0x8(%ebp),%eax
  80121d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801222:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801226:	8b 45 0c             	mov    0xc(%ebp),%eax
  801229:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801234:	e8 4c 0a 00 00       	call   801c85 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801239:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80123f:	b8 02 00 00 00       	mov    $0x2,%eax
  801244:	e8 a7 fd ff ff       	call   800ff0 <nsipc>
}
  801249:	83 c4 14             	add    $0x14,%esp
  80124c:	5b                   	pop    %ebx
  80124d:	5d                   	pop    %ebp
  80124e:	c3                   	ret    

0080124f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	83 ec 18             	sub    $0x18,%esp
  801255:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801258:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80125b:	8b 45 08             	mov    0x8(%ebp),%eax
  80125e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801263:	b8 01 00 00 00       	mov    $0x1,%eax
  801268:	e8 83 fd ff ff       	call   800ff0 <nsipc>
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 25                	js     801298 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801273:	be 10 60 80 00       	mov    $0x806010,%esi
  801278:	8b 06                	mov    (%esi),%eax
  80127a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80127e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801285:	00 
  801286:	8b 45 0c             	mov    0xc(%ebp),%eax
  801289:	89 04 24             	mov    %eax,(%esp)
  80128c:	e8 f4 09 00 00       	call   801c85 <memmove>
		*addrlen = ret->ret_addrlen;
  801291:	8b 16                	mov    (%esi),%edx
  801293:	8b 45 10             	mov    0x10(%ebp),%eax
  801296:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801298:	89 d8                	mov    %ebx,%eax
  80129a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80129d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8012a0:	89 ec                	mov    %ebp,%esp
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	56                   	push   %esi
  8012a8:	53                   	push   %ebx
  8012a9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8012ac:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012af:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8012b5:	e8 09 f1 ff ff       	call   8003c3 <sys_getenvid>
  8012ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012c8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d0:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  8012d7:	e8 81 00 00 00       	call   80135d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e3:	89 04 24             	mov    %eax,(%esp)
  8012e6:	e8 11 00 00 00       	call   8012fc <vcprintf>
	cprintf("\n");
  8012eb:	c7 04 24 50 23 80 00 	movl   $0x802350,(%esp)
  8012f2:	e8 66 00 00 00       	call   80135d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8012f7:	cc                   	int3   
  8012f8:	eb fd                	jmp    8012f7 <_panic+0x53>
	...

008012fc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801305:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80130c:	00 00 00 
	b.cnt = 0;
  80130f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801316:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801319:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801320:	8b 45 08             	mov    0x8(%ebp),%eax
  801323:	89 44 24 08          	mov    %eax,0x8(%esp)
  801327:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80132d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801331:	c7 04 24 77 13 80 00 	movl   $0x801377,(%esp)
  801338:	e8 d0 01 00 00       	call   80150d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80133d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801343:	89 44 24 04          	mov    %eax,0x4(%esp)
  801347:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80134d:	89 04 24             	mov    %eax,(%esp)
  801350:	e8 1d f1 ff ff       	call   800472 <sys_cputs>

	return b.cnt;
}
  801355:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801363:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801366:	89 44 24 04          	mov    %eax,0x4(%esp)
  80136a:	8b 45 08             	mov    0x8(%ebp),%eax
  80136d:	89 04 24             	mov    %eax,(%esp)
  801370:	e8 87 ff ff ff       	call   8012fc <vcprintf>
	va_end(ap);

	return cnt;
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 14             	sub    $0x14,%esp
  80137e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801381:	8b 03                	mov    (%ebx),%eax
  801383:	8b 55 08             	mov    0x8(%ebp),%edx
  801386:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80138a:	83 c0 01             	add    $0x1,%eax
  80138d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80138f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801394:	75 19                	jne    8013af <putch+0x38>
		sys_cputs(b->buf, b->idx);
  801396:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80139d:	00 
  80139e:	8d 43 08             	lea    0x8(%ebx),%eax
  8013a1:	89 04 24             	mov    %eax,(%esp)
  8013a4:	e8 c9 f0 ff ff       	call   800472 <sys_cputs>
		b->idx = 0;
  8013a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8013af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013b3:	83 c4 14             	add    $0x14,%esp
  8013b6:	5b                   	pop    %ebx
  8013b7:	5d                   	pop    %ebp
  8013b8:	c3                   	ret    
  8013b9:	00 00                	add    %al,(%eax)
  8013bb:	00 00                	add    %al,(%eax)
  8013bd:	00 00                	add    %al,(%eax)
	...

008013c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	57                   	push   %edi
  8013c4:	56                   	push   %esi
  8013c5:	53                   	push   %ebx
  8013c6:	83 ec 4c             	sub    $0x4c,%esp
  8013c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013cc:	89 d6                	mov    %edx,%esi
  8013ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013da:	8b 45 10             	mov    0x10(%ebp),%eax
  8013dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8013e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8013e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013eb:	39 d1                	cmp    %edx,%ecx
  8013ed:	72 15                	jb     801404 <printnum+0x44>
  8013ef:	77 07                	ja     8013f8 <printnum+0x38>
  8013f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8013f4:	39 d0                	cmp    %edx,%eax
  8013f6:	76 0c                	jbe    801404 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8013f8:	83 eb 01             	sub    $0x1,%ebx
  8013fb:	85 db                	test   %ebx,%ebx
  8013fd:	8d 76 00             	lea    0x0(%esi),%esi
  801400:	7f 61                	jg     801463 <printnum+0xa3>
  801402:	eb 70                	jmp    801474 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801404:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801408:	83 eb 01             	sub    $0x1,%ebx
  80140b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80140f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801413:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801417:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80141b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80141e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801421:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801424:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801428:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80142f:	00 
  801430:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801433:	89 04 24             	mov    %eax,(%esp)
  801436:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801439:	89 54 24 04          	mov    %edx,0x4(%esp)
  80143d:	e8 de 0b 00 00       	call   802020 <__udivdi3>
  801442:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801445:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801448:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80144c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801450:	89 04 24             	mov    %eax,(%esp)
  801453:	89 54 24 04          	mov    %edx,0x4(%esp)
  801457:	89 f2                	mov    %esi,%edx
  801459:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80145c:	e8 5f ff ff ff       	call   8013c0 <printnum>
  801461:	eb 11                	jmp    801474 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801463:	89 74 24 04          	mov    %esi,0x4(%esp)
  801467:	89 3c 24             	mov    %edi,(%esp)
  80146a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80146d:	83 eb 01             	sub    $0x1,%ebx
  801470:	85 db                	test   %ebx,%ebx
  801472:	7f ef                	jg     801463 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801474:	89 74 24 04          	mov    %esi,0x4(%esp)
  801478:	8b 74 24 04          	mov    0x4(%esp),%esi
  80147c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80147f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801483:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80148a:	00 
  80148b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80148e:	89 14 24             	mov    %edx,(%esp)
  801491:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801494:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801498:	e8 b3 0c 00 00       	call   802150 <__umoddi3>
  80149d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a1:	0f be 80 f3 23 80 00 	movsbl 0x8023f3(%eax),%eax
  8014a8:	89 04 24             	mov    %eax,(%esp)
  8014ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014ae:	83 c4 4c             	add    $0x4c,%esp
  8014b1:	5b                   	pop    %ebx
  8014b2:	5e                   	pop    %esi
  8014b3:	5f                   	pop    %edi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014b9:	83 fa 01             	cmp    $0x1,%edx
  8014bc:	7e 0e                	jle    8014cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014be:	8b 10                	mov    (%eax),%edx
  8014c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014c3:	89 08                	mov    %ecx,(%eax)
  8014c5:	8b 02                	mov    (%edx),%eax
  8014c7:	8b 52 04             	mov    0x4(%edx),%edx
  8014ca:	eb 22                	jmp    8014ee <getuint+0x38>
	else if (lflag)
  8014cc:	85 d2                	test   %edx,%edx
  8014ce:	74 10                	je     8014e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014d0:	8b 10                	mov    (%eax),%edx
  8014d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014d5:	89 08                	mov    %ecx,(%eax)
  8014d7:	8b 02                	mov    (%edx),%eax
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	eb 0e                	jmp    8014ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8014e0:	8b 10                	mov    (%eax),%edx
  8014e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014e5:	89 08                	mov    %ecx,(%eax)
  8014e7:	8b 02                	mov    (%edx),%eax
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014ee:	5d                   	pop    %ebp
  8014ef:	c3                   	ret    

008014f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8014f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8014fa:	8b 10                	mov    (%eax),%edx
  8014fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8014ff:	73 0a                	jae    80150b <sprintputch+0x1b>
		*b->buf++ = ch;
  801501:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801504:	88 0a                	mov    %cl,(%edx)
  801506:	83 c2 01             	add    $0x1,%edx
  801509:	89 10                	mov    %edx,(%eax)
}
  80150b:	5d                   	pop    %ebp
  80150c:	c3                   	ret    

0080150d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	57                   	push   %edi
  801511:	56                   	push   %esi
  801512:	53                   	push   %ebx
  801513:	83 ec 5c             	sub    $0x5c,%esp
  801516:	8b 7d 08             	mov    0x8(%ebp),%edi
  801519:	8b 75 0c             	mov    0xc(%ebp),%esi
  80151c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80151f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801526:	eb 11                	jmp    801539 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801528:	85 c0                	test   %eax,%eax
  80152a:	0f 84 68 04 00 00    	je     801998 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  801530:	89 74 24 04          	mov    %esi,0x4(%esp)
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801539:	0f b6 03             	movzbl (%ebx),%eax
  80153c:	83 c3 01             	add    $0x1,%ebx
  80153f:	83 f8 25             	cmp    $0x25,%eax
  801542:	75 e4                	jne    801528 <vprintfmt+0x1b>
  801544:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80154b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801552:	b9 00 00 00 00       	mov    $0x0,%ecx
  801557:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80155b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801562:	eb 06                	jmp    80156a <vprintfmt+0x5d>
  801564:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  801568:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80156a:	0f b6 13             	movzbl (%ebx),%edx
  80156d:	0f b6 c2             	movzbl %dl,%eax
  801570:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801573:	8d 43 01             	lea    0x1(%ebx),%eax
  801576:	83 ea 23             	sub    $0x23,%edx
  801579:	80 fa 55             	cmp    $0x55,%dl
  80157c:	0f 87 f9 03 00 00    	ja     80197b <vprintfmt+0x46e>
  801582:	0f b6 d2             	movzbl %dl,%edx
  801585:	ff 24 95 e0 25 80 00 	jmp    *0x8025e0(,%edx,4)
  80158c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  801590:	eb d6                	jmp    801568 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801592:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801595:	83 ea 30             	sub    $0x30,%edx
  801598:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80159b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80159e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015a1:	83 fb 09             	cmp    $0x9,%ebx
  8015a4:	77 54                	ja     8015fa <vprintfmt+0xed>
  8015a6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8015a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015ac:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8015af:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8015b2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8015b6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015bc:	83 fb 09             	cmp    $0x9,%ebx
  8015bf:	76 eb                	jbe    8015ac <vprintfmt+0x9f>
  8015c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8015c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8015c7:	eb 31                	jmp    8015fa <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8015cc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8015cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8015d2:	8b 12                	mov    (%edx),%edx
  8015d4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8015d7:	eb 21                	jmp    8015fa <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8015d9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8015e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8015e9:	e9 7a ff ff ff       	jmp    801568 <vprintfmt+0x5b>
  8015ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8015f5:	e9 6e ff ff ff       	jmp    801568 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8015fa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015fe:	0f 89 64 ff ff ff    	jns    801568 <vprintfmt+0x5b>
  801604:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801607:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80160a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80160d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801610:	e9 53 ff ff ff       	jmp    801568 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801615:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  801618:	e9 4b ff ff ff       	jmp    801568 <vprintfmt+0x5b>
  80161d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801620:	8b 45 14             	mov    0x14(%ebp),%eax
  801623:	8d 50 04             	lea    0x4(%eax),%edx
  801626:	89 55 14             	mov    %edx,0x14(%ebp)
  801629:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162d:	8b 00                	mov    (%eax),%eax
  80162f:	89 04 24             	mov    %eax,(%esp)
  801632:	ff d7                	call   *%edi
  801634:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801637:	e9 fd fe ff ff       	jmp    801539 <vprintfmt+0x2c>
  80163c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80163f:	8b 45 14             	mov    0x14(%ebp),%eax
  801642:	8d 50 04             	lea    0x4(%eax),%edx
  801645:	89 55 14             	mov    %edx,0x14(%ebp)
  801648:	8b 00                	mov    (%eax),%eax
  80164a:	89 c2                	mov    %eax,%edx
  80164c:	c1 fa 1f             	sar    $0x1f,%edx
  80164f:	31 d0                	xor    %edx,%eax
  801651:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801653:	83 f8 0f             	cmp    $0xf,%eax
  801656:	7f 0b                	jg     801663 <vprintfmt+0x156>
  801658:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80165f:	85 d2                	test   %edx,%edx
  801661:	75 20                	jne    801683 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  801663:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801667:	c7 44 24 08 04 24 80 	movl   $0x802404,0x8(%esp)
  80166e:	00 
  80166f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801673:	89 3c 24             	mov    %edi,(%esp)
  801676:	e8 a5 03 00 00       	call   801a20 <printfmt>
  80167b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80167e:	e9 b6 fe ff ff       	jmp    801539 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801683:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801687:	c7 44 24 08 87 23 80 	movl   $0x802387,0x8(%esp)
  80168e:	00 
  80168f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801693:	89 3c 24             	mov    %edi,(%esp)
  801696:	e8 85 03 00 00       	call   801a20 <printfmt>
  80169b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80169e:	e9 96 fe ff ff       	jmp    801539 <vprintfmt+0x2c>
  8016a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016a6:	89 c3                	mov    %eax,%ebx
  8016a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8016ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8016b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016b4:	8d 50 04             	lea    0x4(%eax),%edx
  8016b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ba:	8b 00                	mov    (%eax),%eax
  8016bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	b8 0d 24 80 00       	mov    $0x80240d,%eax
  8016c6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8016ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8016cd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8016d1:	7e 06                	jle    8016d9 <vprintfmt+0x1cc>
  8016d3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8016d7:	75 13                	jne    8016ec <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8016d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016dc:	0f be 02             	movsbl (%edx),%eax
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	0f 85 a2 00 00 00    	jne    801789 <vprintfmt+0x27c>
  8016e7:	e9 8f 00 00 00       	jmp    80177b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8016ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8016f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8016f3:	89 0c 24             	mov    %ecx,(%esp)
  8016f6:	e8 70 03 00 00       	call   801a6b <strnlen>
  8016fb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8016fe:	29 c2                	sub    %eax,%edx
  801700:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801703:	85 d2                	test   %edx,%edx
  801705:	7e d2                	jle    8016d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  801707:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80170b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80170e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  801711:	89 d3                	mov    %edx,%ebx
  801713:	89 74 24 04          	mov    %esi,0x4(%esp)
  801717:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80171a:	89 04 24             	mov    %eax,(%esp)
  80171d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80171f:	83 eb 01             	sub    $0x1,%ebx
  801722:	85 db                	test   %ebx,%ebx
  801724:	7f ed                	jg     801713 <vprintfmt+0x206>
  801726:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801729:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801730:	eb a7                	jmp    8016d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801732:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801736:	74 1b                	je     801753 <vprintfmt+0x246>
  801738:	8d 50 e0             	lea    -0x20(%eax),%edx
  80173b:	83 fa 5e             	cmp    $0x5e,%edx
  80173e:	76 13                	jbe    801753 <vprintfmt+0x246>
					putch('?', putdat);
  801740:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801743:	89 54 24 04          	mov    %edx,0x4(%esp)
  801747:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80174e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801751:	eb 0d                	jmp    801760 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801753:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801756:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80175a:	89 04 24             	mov    %eax,(%esp)
  80175d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801760:	83 ef 01             	sub    $0x1,%edi
  801763:	0f be 03             	movsbl (%ebx),%eax
  801766:	85 c0                	test   %eax,%eax
  801768:	74 05                	je     80176f <vprintfmt+0x262>
  80176a:	83 c3 01             	add    $0x1,%ebx
  80176d:	eb 31                	jmp    8017a0 <vprintfmt+0x293>
  80176f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801772:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801775:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801778:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80177b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80177f:	7f 36                	jg     8017b7 <vprintfmt+0x2aa>
  801781:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801784:	e9 b0 fd ff ff       	jmp    801539 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801789:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80178c:	83 c2 01             	add    $0x1,%edx
  80178f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801792:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801795:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801798:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80179b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80179e:	89 d3                	mov    %edx,%ebx
  8017a0:	85 f6                	test   %esi,%esi
  8017a2:	78 8e                	js     801732 <vprintfmt+0x225>
  8017a4:	83 ee 01             	sub    $0x1,%esi
  8017a7:	79 89                	jns    801732 <vprintfmt+0x225>
  8017a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017b2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8017b5:	eb c4                	jmp    80177b <vprintfmt+0x26e>
  8017b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8017ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017c1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8017c8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017ca:	83 eb 01             	sub    $0x1,%ebx
  8017cd:	85 db                	test   %ebx,%ebx
  8017cf:	7f ec                	jg     8017bd <vprintfmt+0x2b0>
  8017d1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8017d4:	e9 60 fd ff ff       	jmp    801539 <vprintfmt+0x2c>
  8017d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8017dc:	83 f9 01             	cmp    $0x1,%ecx
  8017df:	7e 16                	jle    8017f7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8017e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e4:	8d 50 08             	lea    0x8(%eax),%edx
  8017e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ea:	8b 10                	mov    (%eax),%edx
  8017ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8017ef:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8017f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8017f5:	eb 32                	jmp    801829 <vprintfmt+0x31c>
	else if (lflag)
  8017f7:	85 c9                	test   %ecx,%ecx
  8017f9:	74 18                	je     801813 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8017fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fe:	8d 50 04             	lea    0x4(%eax),%edx
  801801:	89 55 14             	mov    %edx,0x14(%ebp)
  801804:	8b 00                	mov    (%eax),%eax
  801806:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801809:	89 c1                	mov    %eax,%ecx
  80180b:	c1 f9 1f             	sar    $0x1f,%ecx
  80180e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801811:	eb 16                	jmp    801829 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  801813:	8b 45 14             	mov    0x14(%ebp),%eax
  801816:	8d 50 04             	lea    0x4(%eax),%edx
  801819:	89 55 14             	mov    %edx,0x14(%ebp)
  80181c:	8b 00                	mov    (%eax),%eax
  80181e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801821:	89 c2                	mov    %eax,%edx
  801823:	c1 fa 1f             	sar    $0x1f,%edx
  801826:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801829:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80182c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80182f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  801834:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801838:	0f 89 8a 00 00 00    	jns    8018c8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80183e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801842:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801849:	ff d7                	call   *%edi
				num = -(long long) num;
  80184b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80184e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801851:	f7 d8                	neg    %eax
  801853:	83 d2 00             	adc    $0x0,%edx
  801856:	f7 da                	neg    %edx
  801858:	eb 6e                	jmp    8018c8 <vprintfmt+0x3bb>
  80185a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80185d:	89 ca                	mov    %ecx,%edx
  80185f:	8d 45 14             	lea    0x14(%ebp),%eax
  801862:	e8 4f fc ff ff       	call   8014b6 <getuint>
  801867:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80186c:	eb 5a                	jmp    8018c8 <vprintfmt+0x3bb>
  80186e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801871:	89 ca                	mov    %ecx,%edx
  801873:	8d 45 14             	lea    0x14(%ebp),%eax
  801876:	e8 3b fc ff ff       	call   8014b6 <getuint>
  80187b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  801880:	eb 46                	jmp    8018c8 <vprintfmt+0x3bb>
  801882:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  801885:	89 74 24 04          	mov    %esi,0x4(%esp)
  801889:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801890:	ff d7                	call   *%edi
			putch('x', putdat);
  801892:	89 74 24 04          	mov    %esi,0x4(%esp)
  801896:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80189d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80189f:	8b 45 14             	mov    0x14(%ebp),%eax
  8018a2:	8d 50 04             	lea    0x4(%eax),%edx
  8018a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018a8:	8b 00                	mov    (%eax),%eax
  8018aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018af:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018b4:	eb 12                	jmp    8018c8 <vprintfmt+0x3bb>
  8018b6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018b9:	89 ca                	mov    %ecx,%edx
  8018bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8018be:	e8 f3 fb ff ff       	call   8014b6 <getuint>
  8018c3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018c8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8018cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8018d3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8018d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018db:	89 04 24             	mov    %eax,(%esp)
  8018de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018e2:	89 f2                	mov    %esi,%edx
  8018e4:	89 f8                	mov    %edi,%eax
  8018e6:	e8 d5 fa ff ff       	call   8013c0 <printnum>
  8018eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8018ee:	e9 46 fc ff ff       	jmp    801539 <vprintfmt+0x2c>
  8018f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8018f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f9:	8d 50 04             	lea    0x4(%eax),%edx
  8018fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8018ff:	8b 00                	mov    (%eax),%eax
  801901:	85 c0                	test   %eax,%eax
  801903:	75 24                	jne    801929 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  801905:	c7 44 24 0c 28 25 80 	movl   $0x802528,0xc(%esp)
  80190c:	00 
  80190d:	c7 44 24 08 87 23 80 	movl   $0x802387,0x8(%esp)
  801914:	00 
  801915:	89 74 24 04          	mov    %esi,0x4(%esp)
  801919:	89 3c 24             	mov    %edi,(%esp)
  80191c:	e8 ff 00 00 00       	call   801a20 <printfmt>
  801921:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801924:	e9 10 fc ff ff       	jmp    801539 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  801929:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80192c:	7e 29                	jle    801957 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80192e:	0f b6 16             	movzbl (%esi),%edx
  801931:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  801933:	c7 44 24 0c 60 25 80 	movl   $0x802560,0xc(%esp)
  80193a:	00 
  80193b:	c7 44 24 08 87 23 80 	movl   $0x802387,0x8(%esp)
  801942:	00 
  801943:	89 74 24 04          	mov    %esi,0x4(%esp)
  801947:	89 3c 24             	mov    %edi,(%esp)
  80194a:	e8 d1 00 00 00       	call   801a20 <printfmt>
  80194f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801952:	e9 e2 fb ff ff       	jmp    801539 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  801957:	0f b6 16             	movzbl (%esi),%edx
  80195a:	88 10                	mov    %dl,(%eax)
  80195c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80195f:	e9 d5 fb ff ff       	jmp    801539 <vprintfmt+0x2c>
  801964:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801967:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80196a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80196e:	89 14 24             	mov    %edx,(%esp)
  801971:	ff d7                	call   *%edi
  801973:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801976:	e9 be fb ff ff       	jmp    801539 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80197b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80197f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801986:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801988:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80198b:	80 38 25             	cmpb   $0x25,(%eax)
  80198e:	0f 84 a5 fb ff ff    	je     801539 <vprintfmt+0x2c>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	eb f0                	jmp    801988 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  801998:	83 c4 5c             	add    $0x5c,%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5f                   	pop    %edi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 28             	sub    $0x28,%esp
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8019ac:	85 c0                	test   %eax,%eax
  8019ae:	74 04                	je     8019b4 <vsnprintf+0x14>
  8019b0:	85 d2                	test   %edx,%edx
  8019b2:	7f 07                	jg     8019bb <vsnprintf+0x1b>
  8019b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019b9:	eb 3b                	jmp    8019f6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019be:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8019c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8019c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e1:	c7 04 24 f0 14 80 00 	movl   $0x8014f0,(%esp)
  8019e8:	e8 20 fb ff ff       	call   80150d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8019f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8019fe:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801a01:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a05:	8b 45 10             	mov    0x10(%ebp),%eax
  801a08:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a13:	8b 45 08             	mov    0x8(%ebp),%eax
  801a16:	89 04 24             	mov    %eax,(%esp)
  801a19:	e8 82 ff ff ff       	call   8019a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801a26:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801a29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a30:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3e:	89 04 24             	mov    %eax,(%esp)
  801a41:	e8 c7 fa ff ff       	call   80150d <vprintfmt>
	va_end(ap);
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    
	...

00801a50 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a56:	b8 00 00 00 00       	mov    $0x0,%eax
  801a5b:	80 3a 00             	cmpb   $0x0,(%edx)
  801a5e:	74 09                	je     801a69 <strlen+0x19>
		n++;
  801a60:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a63:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a67:	75 f7                	jne    801a60 <strlen+0x10>
		n++;
	return n;
}
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	53                   	push   %ebx
  801a6f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a75:	85 c9                	test   %ecx,%ecx
  801a77:	74 19                	je     801a92 <strnlen+0x27>
  801a79:	80 3b 00             	cmpb   $0x0,(%ebx)
  801a7c:	74 14                	je     801a92 <strnlen+0x27>
  801a7e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801a83:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a86:	39 c8                	cmp    %ecx,%eax
  801a88:	74 0d                	je     801a97 <strnlen+0x2c>
  801a8a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801a8e:	75 f3                	jne    801a83 <strnlen+0x18>
  801a90:	eb 05                	jmp    801a97 <strnlen+0x2c>
  801a92:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801a97:	5b                   	pop    %ebx
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    

00801a9a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801aa4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801aa9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801aad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801ab0:	83 c2 01             	add    $0x1,%edx
  801ab3:	84 c9                	test   %cl,%cl
  801ab5:	75 f2                	jne    801aa9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801ab7:	5b                   	pop    %ebx
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <strcat>:

char *
strcat(char *dst, const char *src)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	53                   	push   %ebx
  801abe:	83 ec 08             	sub    $0x8,%esp
  801ac1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ac4:	89 1c 24             	mov    %ebx,(%esp)
  801ac7:	e8 84 ff ff ff       	call   801a50 <strlen>
	strcpy(dst + len, src);
  801acc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801acf:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ad3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801ad6:	89 04 24             	mov    %eax,(%esp)
  801ad9:	e8 bc ff ff ff       	call   801a9a <strcpy>
	return dst;
}
  801ade:	89 d8                	mov    %ebx,%eax
  801ae0:	83 c4 08             	add    $0x8,%esp
  801ae3:	5b                   	pop    %ebx
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    

00801ae6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	56                   	push   %esi
  801aea:	53                   	push   %ebx
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801af4:	85 f6                	test   %esi,%esi
  801af6:	74 18                	je     801b10 <strncpy+0x2a>
  801af8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801afd:	0f b6 1a             	movzbl (%edx),%ebx
  801b00:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b03:	80 3a 01             	cmpb   $0x1,(%edx)
  801b06:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b09:	83 c1 01             	add    $0x1,%ecx
  801b0c:	39 ce                	cmp    %ecx,%esi
  801b0e:	77 ed                	ja     801afd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b10:	5b                   	pop    %ebx
  801b11:	5e                   	pop    %esi
  801b12:	5d                   	pop    %ebp
  801b13:	c3                   	ret    

00801b14 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	56                   	push   %esi
  801b18:	53                   	push   %ebx
  801b19:	8b 75 08             	mov    0x8(%ebp),%esi
  801b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b22:	89 f0                	mov    %esi,%eax
  801b24:	85 c9                	test   %ecx,%ecx
  801b26:	74 27                	je     801b4f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801b28:	83 e9 01             	sub    $0x1,%ecx
  801b2b:	74 1d                	je     801b4a <strlcpy+0x36>
  801b2d:	0f b6 1a             	movzbl (%edx),%ebx
  801b30:	84 db                	test   %bl,%bl
  801b32:	74 16                	je     801b4a <strlcpy+0x36>
			*dst++ = *src++;
  801b34:	88 18                	mov    %bl,(%eax)
  801b36:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b39:	83 e9 01             	sub    $0x1,%ecx
  801b3c:	74 0e                	je     801b4c <strlcpy+0x38>
			*dst++ = *src++;
  801b3e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b41:	0f b6 1a             	movzbl (%edx),%ebx
  801b44:	84 db                	test   %bl,%bl
  801b46:	75 ec                	jne    801b34 <strlcpy+0x20>
  801b48:	eb 02                	jmp    801b4c <strlcpy+0x38>
  801b4a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801b4c:	c6 00 00             	movb   $0x0,(%eax)
  801b4f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b5e:	0f b6 01             	movzbl (%ecx),%eax
  801b61:	84 c0                	test   %al,%al
  801b63:	74 15                	je     801b7a <strcmp+0x25>
  801b65:	3a 02                	cmp    (%edx),%al
  801b67:	75 11                	jne    801b7a <strcmp+0x25>
		p++, q++;
  801b69:	83 c1 01             	add    $0x1,%ecx
  801b6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b6f:	0f b6 01             	movzbl (%ecx),%eax
  801b72:	84 c0                	test   %al,%al
  801b74:	74 04                	je     801b7a <strcmp+0x25>
  801b76:	3a 02                	cmp    (%edx),%al
  801b78:	74 ef                	je     801b69 <strcmp+0x14>
  801b7a:	0f b6 c0             	movzbl %al,%eax
  801b7d:	0f b6 12             	movzbl (%edx),%edx
  801b80:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    

00801b84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	53                   	push   %ebx
  801b88:	8b 55 08             	mov    0x8(%ebp),%edx
  801b8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b8e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801b91:	85 c0                	test   %eax,%eax
  801b93:	74 23                	je     801bb8 <strncmp+0x34>
  801b95:	0f b6 1a             	movzbl (%edx),%ebx
  801b98:	84 db                	test   %bl,%bl
  801b9a:	74 25                	je     801bc1 <strncmp+0x3d>
  801b9c:	3a 19                	cmp    (%ecx),%bl
  801b9e:	75 21                	jne    801bc1 <strncmp+0x3d>
  801ba0:	83 e8 01             	sub    $0x1,%eax
  801ba3:	74 13                	je     801bb8 <strncmp+0x34>
		n--, p++, q++;
  801ba5:	83 c2 01             	add    $0x1,%edx
  801ba8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bab:	0f b6 1a             	movzbl (%edx),%ebx
  801bae:	84 db                	test   %bl,%bl
  801bb0:	74 0f                	je     801bc1 <strncmp+0x3d>
  801bb2:	3a 19                	cmp    (%ecx),%bl
  801bb4:	74 ea                	je     801ba0 <strncmp+0x1c>
  801bb6:	eb 09                	jmp    801bc1 <strncmp+0x3d>
  801bb8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801bbd:	5b                   	pop    %ebx
  801bbe:	5d                   	pop    %ebp
  801bbf:	90                   	nop
  801bc0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801bc1:	0f b6 02             	movzbl (%edx),%eax
  801bc4:	0f b6 11             	movzbl (%ecx),%edx
  801bc7:	29 d0                	sub    %edx,%eax
  801bc9:	eb f2                	jmp    801bbd <strncmp+0x39>

00801bcb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801bd5:	0f b6 10             	movzbl (%eax),%edx
  801bd8:	84 d2                	test   %dl,%dl
  801bda:	74 18                	je     801bf4 <strchr+0x29>
		if (*s == c)
  801bdc:	38 ca                	cmp    %cl,%dl
  801bde:	75 0a                	jne    801bea <strchr+0x1f>
  801be0:	eb 17                	jmp    801bf9 <strchr+0x2e>
  801be2:	38 ca                	cmp    %cl,%dl
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	74 0f                	je     801bf9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801bea:	83 c0 01             	add    $0x1,%eax
  801bed:	0f b6 10             	movzbl (%eax),%edx
  801bf0:	84 d2                	test   %dl,%dl
  801bf2:	75 ee                	jne    801be2 <strchr+0x17>
  801bf4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c05:	0f b6 10             	movzbl (%eax),%edx
  801c08:	84 d2                	test   %dl,%dl
  801c0a:	74 18                	je     801c24 <strfind+0x29>
		if (*s == c)
  801c0c:	38 ca                	cmp    %cl,%dl
  801c0e:	75 0a                	jne    801c1a <strfind+0x1f>
  801c10:	eb 12                	jmp    801c24 <strfind+0x29>
  801c12:	38 ca                	cmp    %cl,%dl
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	74 0a                	je     801c24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801c1a:	83 c0 01             	add    $0x1,%eax
  801c1d:	0f b6 10             	movzbl (%eax),%edx
  801c20:	84 d2                	test   %dl,%dl
  801c22:	75 ee                	jne    801c12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801c24:	5d                   	pop    %ebp
  801c25:	c3                   	ret    

00801c26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c26:	55                   	push   %ebp
  801c27:	89 e5                	mov    %esp,%ebp
  801c29:	83 ec 0c             	sub    $0xc,%esp
  801c2c:	89 1c 24             	mov    %ebx,(%esp)
  801c2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801c37:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c40:	85 c9                	test   %ecx,%ecx
  801c42:	74 30                	je     801c74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c4a:	75 25                	jne    801c71 <memset+0x4b>
  801c4c:	f6 c1 03             	test   $0x3,%cl
  801c4f:	75 20                	jne    801c71 <memset+0x4b>
		c &= 0xFF;
  801c51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c54:	89 d3                	mov    %edx,%ebx
  801c56:	c1 e3 08             	shl    $0x8,%ebx
  801c59:	89 d6                	mov    %edx,%esi
  801c5b:	c1 e6 18             	shl    $0x18,%esi
  801c5e:	89 d0                	mov    %edx,%eax
  801c60:	c1 e0 10             	shl    $0x10,%eax
  801c63:	09 f0                	or     %esi,%eax
  801c65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801c67:	09 d8                	or     %ebx,%eax
  801c69:	c1 e9 02             	shr    $0x2,%ecx
  801c6c:	fc                   	cld    
  801c6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c6f:	eb 03                	jmp    801c74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c71:	fc                   	cld    
  801c72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c74:	89 f8                	mov    %edi,%eax
  801c76:	8b 1c 24             	mov    (%esp),%ebx
  801c79:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801c81:	89 ec                	mov    %ebp,%esp
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	83 ec 08             	sub    $0x8,%esp
  801c8b:	89 34 24             	mov    %esi,(%esp)
  801c8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c92:	8b 45 08             	mov    0x8(%ebp),%eax
  801c95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801c98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801c9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801c9d:	39 c6                	cmp    %eax,%esi
  801c9f:	73 35                	jae    801cd6 <memmove+0x51>
  801ca1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ca4:	39 d0                	cmp    %edx,%eax
  801ca6:	73 2e                	jae    801cd6 <memmove+0x51>
		s += n;
		d += n;
  801ca8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801caa:	f6 c2 03             	test   $0x3,%dl
  801cad:	75 1b                	jne    801cca <memmove+0x45>
  801caf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cb5:	75 13                	jne    801cca <memmove+0x45>
  801cb7:	f6 c1 03             	test   $0x3,%cl
  801cba:	75 0e                	jne    801cca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801cbc:	83 ef 04             	sub    $0x4,%edi
  801cbf:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cc2:	c1 e9 02             	shr    $0x2,%ecx
  801cc5:	fd                   	std    
  801cc6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cc8:	eb 09                	jmp    801cd3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801cca:	83 ef 01             	sub    $0x1,%edi
  801ccd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801cd0:	fd                   	std    
  801cd1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801cd3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cd4:	eb 20                	jmp    801cf6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cd6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cdc:	75 15                	jne    801cf3 <memmove+0x6e>
  801cde:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801ce4:	75 0d                	jne    801cf3 <memmove+0x6e>
  801ce6:	f6 c1 03             	test   $0x3,%cl
  801ce9:	75 08                	jne    801cf3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801ceb:	c1 e9 02             	shr    $0x2,%ecx
  801cee:	fc                   	cld    
  801cef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf1:	eb 03                	jmp    801cf6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801cf3:	fc                   	cld    
  801cf4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801cf6:	8b 34 24             	mov    (%esp),%esi
  801cf9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801cfd:	89 ec                	mov    %ebp,%esp
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d07:	8b 45 10             	mov    0x10(%ebp),%eax
  801d0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	89 04 24             	mov    %eax,(%esp)
  801d1b:	e8 65 ff ff ff       	call   801c85 <memmove>
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	57                   	push   %edi
  801d26:	56                   	push   %esi
  801d27:	53                   	push   %ebx
  801d28:	8b 75 08             	mov    0x8(%ebp),%esi
  801d2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d31:	85 c9                	test   %ecx,%ecx
  801d33:	74 36                	je     801d6b <memcmp+0x49>
		if (*s1 != *s2)
  801d35:	0f b6 06             	movzbl (%esi),%eax
  801d38:	0f b6 1f             	movzbl (%edi),%ebx
  801d3b:	38 d8                	cmp    %bl,%al
  801d3d:	74 20                	je     801d5f <memcmp+0x3d>
  801d3f:	eb 14                	jmp    801d55 <memcmp+0x33>
  801d41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801d46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801d4b:	83 c2 01             	add    $0x1,%edx
  801d4e:	83 e9 01             	sub    $0x1,%ecx
  801d51:	38 d8                	cmp    %bl,%al
  801d53:	74 12                	je     801d67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801d55:	0f b6 c0             	movzbl %al,%eax
  801d58:	0f b6 db             	movzbl %bl,%ebx
  801d5b:	29 d8                	sub    %ebx,%eax
  801d5d:	eb 11                	jmp    801d70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d5f:	83 e9 01             	sub    $0x1,%ecx
  801d62:	ba 00 00 00 00       	mov    $0x0,%edx
  801d67:	85 c9                	test   %ecx,%ecx
  801d69:	75 d6                	jne    801d41 <memcmp+0x1f>
  801d6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801d70:	5b                   	pop    %ebx
  801d71:	5e                   	pop    %esi
  801d72:	5f                   	pop    %edi
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d7b:	89 c2                	mov    %eax,%edx
  801d7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801d80:	39 d0                	cmp    %edx,%eax
  801d82:	73 15                	jae    801d99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801d88:	38 08                	cmp    %cl,(%eax)
  801d8a:	75 06                	jne    801d92 <memfind+0x1d>
  801d8c:	eb 0b                	jmp    801d99 <memfind+0x24>
  801d8e:	38 08                	cmp    %cl,(%eax)
  801d90:	74 07                	je     801d99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801d92:	83 c0 01             	add    $0x1,%eax
  801d95:	39 c2                	cmp    %eax,%edx
  801d97:	77 f5                	ja     801d8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	57                   	push   %edi
  801d9f:	56                   	push   %esi
  801da0:	53                   	push   %ebx
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	8b 55 08             	mov    0x8(%ebp),%edx
  801da7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801daa:	0f b6 02             	movzbl (%edx),%eax
  801dad:	3c 20                	cmp    $0x20,%al
  801daf:	74 04                	je     801db5 <strtol+0x1a>
  801db1:	3c 09                	cmp    $0x9,%al
  801db3:	75 0e                	jne    801dc3 <strtol+0x28>
		s++;
  801db5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801db8:	0f b6 02             	movzbl (%edx),%eax
  801dbb:	3c 20                	cmp    $0x20,%al
  801dbd:	74 f6                	je     801db5 <strtol+0x1a>
  801dbf:	3c 09                	cmp    $0x9,%al
  801dc1:	74 f2                	je     801db5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dc3:	3c 2b                	cmp    $0x2b,%al
  801dc5:	75 0c                	jne    801dd3 <strtol+0x38>
		s++;
  801dc7:	83 c2 01             	add    $0x1,%edx
  801dca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801dd1:	eb 15                	jmp    801de8 <strtol+0x4d>
	else if (*s == '-')
  801dd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801dda:	3c 2d                	cmp    $0x2d,%al
  801ddc:	75 0a                	jne    801de8 <strtol+0x4d>
		s++, neg = 1;
  801dde:	83 c2 01             	add    $0x1,%edx
  801de1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801de8:	85 db                	test   %ebx,%ebx
  801dea:	0f 94 c0             	sete   %al
  801ded:	74 05                	je     801df4 <strtol+0x59>
  801def:	83 fb 10             	cmp    $0x10,%ebx
  801df2:	75 18                	jne    801e0c <strtol+0x71>
  801df4:	80 3a 30             	cmpb   $0x30,(%edx)
  801df7:	75 13                	jne    801e0c <strtol+0x71>
  801df9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	75 0a                	jne    801e0c <strtol+0x71>
		s += 2, base = 16;
  801e02:	83 c2 02             	add    $0x2,%edx
  801e05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e0a:	eb 15                	jmp    801e21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e0c:	84 c0                	test   %al,%al
  801e0e:	66 90                	xchg   %ax,%ax
  801e10:	74 0f                	je     801e21 <strtol+0x86>
  801e12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801e17:	80 3a 30             	cmpb   $0x30,(%edx)
  801e1a:	75 05                	jne    801e21 <strtol+0x86>
		s++, base = 8;
  801e1c:	83 c2 01             	add    $0x1,%edx
  801e1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e21:	b8 00 00 00 00       	mov    $0x0,%eax
  801e26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e28:	0f b6 0a             	movzbl (%edx),%ecx
  801e2b:	89 cf                	mov    %ecx,%edi
  801e2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801e30:	80 fb 09             	cmp    $0x9,%bl
  801e33:	77 08                	ja     801e3d <strtol+0xa2>
			dig = *s - '0';
  801e35:	0f be c9             	movsbl %cl,%ecx
  801e38:	83 e9 30             	sub    $0x30,%ecx
  801e3b:	eb 1e                	jmp    801e5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801e3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801e40:	80 fb 19             	cmp    $0x19,%bl
  801e43:	77 08                	ja     801e4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801e45:	0f be c9             	movsbl %cl,%ecx
  801e48:	83 e9 57             	sub    $0x57,%ecx
  801e4b:	eb 0e                	jmp    801e5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801e4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801e50:	80 fb 19             	cmp    $0x19,%bl
  801e53:	77 15                	ja     801e6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801e55:	0f be c9             	movsbl %cl,%ecx
  801e58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801e5b:	39 f1                	cmp    %esi,%ecx
  801e5d:	7d 0b                	jge    801e6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801e5f:	83 c2 01             	add    $0x1,%edx
  801e62:	0f af c6             	imul   %esi,%eax
  801e65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801e68:	eb be                	jmp    801e28 <strtol+0x8d>
  801e6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801e6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e70:	74 05                	je     801e77 <strtol+0xdc>
		*endptr = (char *) s;
  801e72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801e77:	89 ca                	mov    %ecx,%edx
  801e79:	f7 da                	neg    %edx
  801e7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801e7f:	0f 45 c2             	cmovne %edx,%eax
}
  801e82:	83 c4 04             	add    $0x4,%esp
  801e85:	5b                   	pop    %ebx
  801e86:	5e                   	pop    %esi
  801e87:	5f                   	pop    %edi
  801e88:	5d                   	pop    %ebp
  801e89:	c3                   	ret    
  801e8a:	00 00                	add    %al,(%eax)
  801e8c:	00 00                	add    %al,(%eax)
	...

00801e90 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801e96:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801e9c:	b8 01 00 00 00       	mov    $0x1,%eax
  801ea1:	39 ca                	cmp    %ecx,%edx
  801ea3:	75 04                	jne    801ea9 <ipc_find_env+0x19>
  801ea5:	b0 00                	mov    $0x0,%al
  801ea7:	eb 11                	jmp    801eba <ipc_find_env+0x2a>
  801ea9:	89 c2                	mov    %eax,%edx
  801eab:	c1 e2 07             	shl    $0x7,%edx
  801eae:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801eb4:	8b 12                	mov    (%edx),%edx
  801eb6:	39 ca                	cmp    %ecx,%edx
  801eb8:	75 0f                	jne    801ec9 <ipc_find_env+0x39>
			return envs[i].env_id;
  801eba:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801ebe:	c1 e0 06             	shl    $0x6,%eax
  801ec1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801ec7:	eb 0e                	jmp    801ed7 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ec9:	83 c0 01             	add    $0x1,%eax
  801ecc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ed1:	75 d6                	jne    801ea9 <ipc_find_env+0x19>
  801ed3:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	57                   	push   %edi
  801edd:	56                   	push   %esi
  801ede:	53                   	push   %ebx
  801edf:	83 ec 1c             	sub    $0x1c,%esp
  801ee2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801eeb:	85 db                	test   %ebx,%ebx
  801eed:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801ef2:	0f 44 d8             	cmove  %eax,%ebx
  801ef5:	eb 25                	jmp    801f1c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801ef7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801efa:	74 20                	je     801f1c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801efc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f00:	c7 44 24 08 80 27 80 	movl   $0x802780,0x8(%esp)
  801f07:	00 
  801f08:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f0f:	00 
  801f10:	c7 04 24 9e 27 80 00 	movl   $0x80279e,(%esp)
  801f17:	e8 88 f3 ff ff       	call   8012a4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f27:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f2b:	89 34 24             	mov    %esi,(%esp)
  801f2e:	e8 97 e2 ff ff       	call   8001ca <sys_ipc_try_send>
  801f33:	85 c0                	test   %eax,%eax
  801f35:	75 c0                	jne    801ef7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f37:	e8 14 e4 ff ff       	call   800350 <sys_yield>
}
  801f3c:	83 c4 1c             	add    $0x1c,%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 28             	sub    $0x28,%esp
  801f4a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f4d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f50:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f53:	8b 75 08             	mov    0x8(%ebp),%esi
  801f56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f59:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f63:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801f66:	89 04 24             	mov    %eax,(%esp)
  801f69:	e8 23 e2 ff ff       	call   800191 <sys_ipc_recv>
  801f6e:	89 c3                	mov    %eax,%ebx
  801f70:	85 c0                	test   %eax,%eax
  801f72:	79 2a                	jns    801f9e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801f74:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f78:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7c:	c7 04 24 a8 27 80 00 	movl   $0x8027a8,(%esp)
  801f83:	e8 d5 f3 ff ff       	call   80135d <cprintf>
		if(from_env_store != NULL)
  801f88:	85 f6                	test   %esi,%esi
  801f8a:	74 06                	je     801f92 <ipc_recv+0x4e>
			*from_env_store = 0;
  801f8c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801f92:	85 ff                	test   %edi,%edi
  801f94:	74 2c                	je     801fc2 <ipc_recv+0x7e>
			*perm_store = 0;
  801f96:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801f9c:	eb 24                	jmp    801fc2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801f9e:	85 f6                	test   %esi,%esi
  801fa0:	74 0a                	je     801fac <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801fa2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa7:	8b 40 74             	mov    0x74(%eax),%eax
  801faa:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fac:	85 ff                	test   %edi,%edi
  801fae:	74 0a                	je     801fba <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801fb0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb5:	8b 40 78             	mov    0x78(%eax),%eax
  801fb8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fba:	a1 08 40 80 00       	mov    0x804008,%eax
  801fbf:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801fc2:	89 d8                	mov    %ebx,%eax
  801fc4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fc7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fca:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fcd:	89 ec                	mov    %ebp,%esp
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    
  801fd1:	00 00                	add    %al,(%eax)
	...

00801fd4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  801fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fda:	89 c2                	mov    %eax,%edx
  801fdc:	c1 ea 16             	shr    $0x16,%edx
  801fdf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fe6:	f6 c2 01             	test   $0x1,%dl
  801fe9:	74 20                	je     80200b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  801feb:	c1 e8 0c             	shr    $0xc,%eax
  801fee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ff5:	a8 01                	test   $0x1,%al
  801ff7:	74 12                	je     80200b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff9:	c1 e8 0c             	shr    $0xc,%eax
  801ffc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802001:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802006:	0f b7 c0             	movzwl %ax,%eax
  802009:	eb 05                	jmp    802010 <pageref+0x3c>
  80200b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
	...

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	83 ec 10             	sub    $0x10,%esp
  802028:	8b 45 14             	mov    0x14(%ebp),%eax
  80202b:	8b 55 08             	mov    0x8(%ebp),%edx
  80202e:	8b 75 10             	mov    0x10(%ebp),%esi
  802031:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802034:	85 c0                	test   %eax,%eax
  802036:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802039:	75 35                	jne    802070 <__udivdi3+0x50>
  80203b:	39 fe                	cmp    %edi,%esi
  80203d:	77 61                	ja     8020a0 <__udivdi3+0x80>
  80203f:	85 f6                	test   %esi,%esi
  802041:	75 0b                	jne    80204e <__udivdi3+0x2e>
  802043:	b8 01 00 00 00       	mov    $0x1,%eax
  802048:	31 d2                	xor    %edx,%edx
  80204a:	f7 f6                	div    %esi
  80204c:	89 c6                	mov    %eax,%esi
  80204e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802051:	31 d2                	xor    %edx,%edx
  802053:	89 f8                	mov    %edi,%eax
  802055:	f7 f6                	div    %esi
  802057:	89 c7                	mov    %eax,%edi
  802059:	89 c8                	mov    %ecx,%eax
  80205b:	f7 f6                	div    %esi
  80205d:	89 c1                	mov    %eax,%ecx
  80205f:	89 fa                	mov    %edi,%edx
  802061:	89 c8                	mov    %ecx,%eax
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
  80206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802070:	39 f8                	cmp    %edi,%eax
  802072:	77 1c                	ja     802090 <__udivdi3+0x70>
  802074:	0f bd d0             	bsr    %eax,%edx
  802077:	83 f2 1f             	xor    $0x1f,%edx
  80207a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80207d:	75 39                	jne    8020b8 <__udivdi3+0x98>
  80207f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802082:	0f 86 a0 00 00 00    	jbe    802128 <__udivdi3+0x108>
  802088:	39 f8                	cmp    %edi,%eax
  80208a:	0f 82 98 00 00 00    	jb     802128 <__udivdi3+0x108>
  802090:	31 ff                	xor    %edi,%edi
  802092:	31 c9                	xor    %ecx,%ecx
  802094:	89 c8                	mov    %ecx,%eax
  802096:	89 fa                	mov    %edi,%edx
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	5e                   	pop    %esi
  80209c:	5f                   	pop    %edi
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    
  80209f:	90                   	nop
  8020a0:	89 d1                	mov    %edx,%ecx
  8020a2:	89 fa                	mov    %edi,%edx
  8020a4:	89 c8                	mov    %ecx,%eax
  8020a6:	31 ff                	xor    %edi,%edi
  8020a8:	f7 f6                	div    %esi
  8020aa:	89 c1                	mov    %eax,%ecx
  8020ac:	89 fa                	mov    %edi,%edx
  8020ae:	89 c8                	mov    %ecx,%eax
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	5e                   	pop    %esi
  8020b4:	5f                   	pop    %edi
  8020b5:	5d                   	pop    %ebp
  8020b6:	c3                   	ret    
  8020b7:	90                   	nop
  8020b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020bc:	89 f2                	mov    %esi,%edx
  8020be:	d3 e0                	shl    %cl,%eax
  8020c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8020cb:	89 c1                	mov    %eax,%ecx
  8020cd:	d3 ea                	shr    %cl,%edx
  8020cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8020d6:	d3 e6                	shl    %cl,%esi
  8020d8:	89 c1                	mov    %eax,%ecx
  8020da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8020dd:	89 fe                	mov    %edi,%esi
  8020df:	d3 ee                	shr    %cl,%esi
  8020e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020eb:	d3 e7                	shl    %cl,%edi
  8020ed:	89 c1                	mov    %eax,%ecx
  8020ef:	d3 ea                	shr    %cl,%edx
  8020f1:	09 d7                	or     %edx,%edi
  8020f3:	89 f2                	mov    %esi,%edx
  8020f5:	89 f8                	mov    %edi,%eax
  8020f7:	f7 75 ec             	divl   -0x14(%ebp)
  8020fa:	89 d6                	mov    %edx,%esi
  8020fc:	89 c7                	mov    %eax,%edi
  8020fe:	f7 65 e8             	mull   -0x18(%ebp)
  802101:	39 d6                	cmp    %edx,%esi
  802103:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802106:	72 30                	jb     802138 <__udivdi3+0x118>
  802108:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80210b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80210f:	d3 e2                	shl    %cl,%edx
  802111:	39 c2                	cmp    %eax,%edx
  802113:	73 05                	jae    80211a <__udivdi3+0xfa>
  802115:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802118:	74 1e                	je     802138 <__udivdi3+0x118>
  80211a:	89 f9                	mov    %edi,%ecx
  80211c:	31 ff                	xor    %edi,%edi
  80211e:	e9 71 ff ff ff       	jmp    802094 <__udivdi3+0x74>
  802123:	90                   	nop
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80212f:	e9 60 ff ff ff       	jmp    802094 <__udivdi3+0x74>
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80213b:	31 ff                	xor    %edi,%edi
  80213d:	89 c8                	mov    %ecx,%eax
  80213f:	89 fa                	mov    %edi,%edx
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
	...

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	57                   	push   %edi
  802154:	56                   	push   %esi
  802155:	83 ec 20             	sub    $0x20,%esp
  802158:	8b 55 14             	mov    0x14(%ebp),%edx
  80215b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80215e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802161:	8b 75 0c             	mov    0xc(%ebp),%esi
  802164:	85 d2                	test   %edx,%edx
  802166:	89 c8                	mov    %ecx,%eax
  802168:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80216b:	75 13                	jne    802180 <__umoddi3+0x30>
  80216d:	39 f7                	cmp    %esi,%edi
  80216f:	76 3f                	jbe    8021b0 <__umoddi3+0x60>
  802171:	89 f2                	mov    %esi,%edx
  802173:	f7 f7                	div    %edi
  802175:	89 d0                	mov    %edx,%eax
  802177:	31 d2                	xor    %edx,%edx
  802179:	83 c4 20             	add    $0x20,%esp
  80217c:	5e                   	pop    %esi
  80217d:	5f                   	pop    %edi
  80217e:	5d                   	pop    %ebp
  80217f:	c3                   	ret    
  802180:	39 f2                	cmp    %esi,%edx
  802182:	77 4c                	ja     8021d0 <__umoddi3+0x80>
  802184:	0f bd ca             	bsr    %edx,%ecx
  802187:	83 f1 1f             	xor    $0x1f,%ecx
  80218a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80218d:	75 51                	jne    8021e0 <__umoddi3+0x90>
  80218f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802192:	0f 87 e0 00 00 00    	ja     802278 <__umoddi3+0x128>
  802198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219b:	29 f8                	sub    %edi,%eax
  80219d:	19 d6                	sbb    %edx,%esi
  80219f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	89 f2                	mov    %esi,%edx
  8021a7:	83 c4 20             	add    $0x20,%esp
  8021aa:	5e                   	pop    %esi
  8021ab:	5f                   	pop    %edi
  8021ac:	5d                   	pop    %ebp
  8021ad:	c3                   	ret    
  8021ae:	66 90                	xchg   %ax,%ax
  8021b0:	85 ff                	test   %edi,%edi
  8021b2:	75 0b                	jne    8021bf <__umoddi3+0x6f>
  8021b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b9:	31 d2                	xor    %edx,%edx
  8021bb:	f7 f7                	div    %edi
  8021bd:	89 c7                	mov    %eax,%edi
  8021bf:	89 f0                	mov    %esi,%eax
  8021c1:	31 d2                	xor    %edx,%edx
  8021c3:	f7 f7                	div    %edi
  8021c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c8:	f7 f7                	div    %edi
  8021ca:	eb a9                	jmp    802175 <__umoddi3+0x25>
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	83 c4 20             	add    $0x20,%esp
  8021d7:	5e                   	pop    %esi
  8021d8:	5f                   	pop    %edi
  8021d9:	5d                   	pop    %ebp
  8021da:	c3                   	ret    
  8021db:	90                   	nop
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021e4:	d3 e2                	shl    %cl,%edx
  8021e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8021ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8021f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	d3 ea                	shr    %cl,%edx
  8021fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802200:	0b 55 f4             	or     -0xc(%ebp),%edx
  802203:	d3 e7                	shl    %cl,%edi
  802205:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802209:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80220c:	89 f2                	mov    %esi,%edx
  80220e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802211:	89 c7                	mov    %eax,%edi
  802213:	d3 ea                	shr    %cl,%edx
  802215:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802219:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80221c:	89 c2                	mov    %eax,%edx
  80221e:	d3 e6                	shl    %cl,%esi
  802220:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802224:	d3 ea                	shr    %cl,%edx
  802226:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80222a:	09 d6                	or     %edx,%esi
  80222c:	89 f0                	mov    %esi,%eax
  80222e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802231:	d3 e7                	shl    %cl,%edi
  802233:	89 f2                	mov    %esi,%edx
  802235:	f7 75 f4             	divl   -0xc(%ebp)
  802238:	89 d6                	mov    %edx,%esi
  80223a:	f7 65 e8             	mull   -0x18(%ebp)
  80223d:	39 d6                	cmp    %edx,%esi
  80223f:	72 2b                	jb     80226c <__umoddi3+0x11c>
  802241:	39 c7                	cmp    %eax,%edi
  802243:	72 23                	jb     802268 <__umoddi3+0x118>
  802245:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802249:	29 c7                	sub    %eax,%edi
  80224b:	19 d6                	sbb    %edx,%esi
  80224d:	89 f0                	mov    %esi,%eax
  80224f:	89 f2                	mov    %esi,%edx
  802251:	d3 ef                	shr    %cl,%edi
  802253:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802257:	d3 e0                	shl    %cl,%eax
  802259:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80225d:	09 f8                	or     %edi,%eax
  80225f:	d3 ea                	shr    %cl,%edx
  802261:	83 c4 20             	add    $0x20,%esp
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	39 d6                	cmp    %edx,%esi
  80226a:	75 d9                	jne    802245 <__umoddi3+0xf5>
  80226c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80226f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802272:	eb d1                	jmp    802245 <__umoddi3+0xf5>
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 f2                	cmp    %esi,%edx
  80227a:	0f 82 18 ff ff ff    	jb     802198 <__umoddi3+0x48>
  802280:	e9 1d ff ff ff       	jmp    8021a2 <__umoddi3+0x52>
