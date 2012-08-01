
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 30 80 00       	mov    0x803000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 3b 04 00 00       	call   80048a <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800066:	e8 70 03 00 00       	call   8003db <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 0a 09 00 00       	call   8009b9 <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 5b 03 00 00       	call   800416 <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 48             	sub    $0x48,%esp
  8000c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000cf:	89 c6                	mov    %eax,%esi
  8000d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000d4:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d6:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000df:	51                   	push   %ecx
  8000e0:	52                   	push   %edx
  8000e1:	53                   	push   %ebx
  8000e2:	54                   	push   %esp
  8000e3:	55                   	push   %ebp
  8000e4:	56                   	push   %esi
  8000e5:	57                   	push   %edi
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	8d 35 f0 00 80 00    	lea    0x8000f0,%esi
  8000ee:	0f 34                	sysenter 

008000f0 <.after_sysenter_label>:
  8000f0:	5f                   	pop    %edi
  8000f1:	5e                   	pop    %esi
  8000f2:	5d                   	pop    %ebp
  8000f3:	5c                   	pop    %esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5a                   	pop    %edx
  8000f6:	59                   	pop    %ecx
  8000f7:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000f9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000fd:	74 28                	je     800127 <.after_sysenter_label+0x37>
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7e 24                	jle    800127 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	89 44 24 10          	mov    %eax,0x10(%esp)
  800107:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80010b:	c7 44 24 08 b8 22 80 	movl   $0x8022b8,0x8(%esp)
  800112:	00 
  800113:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80011a:	00 
  80011b:	c7 04 24 d5 22 80 00 	movl   $0x8022d5,(%esp)
  800122:	e8 9d 11 00 00       	call   8012c4 <_panic>

	return ret;
}
  800127:	89 d0                	mov    %edx,%eax
  800129:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80012c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80012f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800132:	89 ec                	mov    %ebp,%esp
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  80013c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800143:	00 
  800144:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80014b:	00 
  80014c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800153:	00 
  800154:	8b 45 0c             	mov    0xc(%ebp),%eax
  800157:	89 04 24             	mov    %eax,(%esp)
  80015a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015d:	ba 00 00 00 00       	mov    $0x0,%edx
  800162:	b8 10 00 00 00       	mov    $0x10,%eax
  800167:	e8 54 ff ff ff       	call   8000c0 <syscall>
}
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    

0080016e <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80016e:	55                   	push   %ebp
  80016f:	89 e5                	mov    %esp,%ebp
  800171:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800174:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80017b:	00 
  80017c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800183:	00 
  800184:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80018b:	00 
  80018c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800193:	b9 00 00 00 00       	mov    $0x0,%ecx
  800198:	ba 00 00 00 00       	mov    $0x0,%edx
  80019d:	b8 0f 00 00 00       	mov    $0xf,%eax
  8001a2:	e8 19 ff ff ff       	call   8000c0 <syscall>
}
  8001a7:	c9                   	leave  
  8001a8:	c3                   	ret    

008001a9 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8001af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b6:	00 
  8001b7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001be:	00 
  8001bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001c6:	00 
  8001c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d6:	b8 0e 00 00 00       	mov    $0xe,%eax
  8001db:	e8 e0 fe ff ff       	call   8000c0 <syscall>
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001e2:	55                   	push   %ebp
  8001e3:	89 e5                	mov    %esp,%ebp
  8001e5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8001e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ef:	00 
  8001f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8001fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800201:	89 04 24             	mov    %eax,(%esp)
  800204:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800207:	ba 00 00 00 00       	mov    $0x0,%edx
  80020c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800211:	e8 aa fe ff ff       	call   8000c0 <syscall>
}
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80021e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800225:	00 
  800226:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80022d:	00 
  80022e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800235:	00 
  800236:	8b 45 0c             	mov    0xc(%ebp),%eax
  800239:	89 04 24             	mov    %eax,(%esp)
  80023c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023f:	ba 01 00 00 00       	mov    $0x1,%edx
  800244:	b8 0b 00 00 00       	mov    $0xb,%eax
  800249:	e8 72 fe ff ff       	call   8000c0 <syscall>
}
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800256:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025d:	00 
  80025e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800265:	00 
  800266:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80026d:	00 
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800271:	89 04 24             	mov    %eax,(%esp)
  800274:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800277:	ba 01 00 00 00       	mov    $0x1,%edx
  80027c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800281:	e8 3a fe ff ff       	call   8000c0 <syscall>
}
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80028e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800295:	00 
  800296:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80029d:	00 
  80029e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002a5:	00 
  8002a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a9:	89 04 24             	mov    %eax,(%esp)
  8002ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002af:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b9:	e8 02 fe ff ff       	call   8000c0 <syscall>
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002c6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cd:	00 
  8002ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002dd:	00 
  8002de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e1:	89 04 24             	mov    %eax,(%esp)
  8002e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e7:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ec:	b8 07 00 00 00       	mov    $0x7,%eax
  8002f1:	e8 ca fd ff ff       	call   8000c0 <syscall>
}
  8002f6:	c9                   	leave  
  8002f7:	c3                   	ret    

008002f8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8002fe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800305:	00 
  800306:	8b 45 18             	mov    0x18(%ebp),%eax
  800309:	0b 45 14             	or     0x14(%ebp),%eax
  80030c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800310:	8b 45 10             	mov    0x10(%ebp),%eax
  800313:	89 44 24 04          	mov    %eax,0x4(%esp)
  800317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800320:	ba 01 00 00 00       	mov    $0x1,%edx
  800325:	b8 06 00 00 00       	mov    $0x6,%eax
  80032a:	e8 91 fd ff ff       	call   8000c0 <syscall>
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800337:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033e:	00 
  80033f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800346:	00 
  800347:	8b 45 10             	mov    0x10(%ebp),%eax
  80034a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800351:	89 04 24             	mov    %eax,(%esp)
  800354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800357:	ba 01 00 00 00       	mov    $0x1,%edx
  80035c:	b8 05 00 00 00       	mov    $0x5,%eax
  800361:	e8 5a fd ff ff       	call   8000c0 <syscall>
}
  800366:	c9                   	leave  
  800367:	c3                   	ret    

00800368 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80036e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800375:	00 
  800376:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80037d:	00 
  80037e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800385:	00 
  800386:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80038d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800392:	ba 00 00 00 00       	mov    $0x0,%edx
  800397:	b8 0c 00 00 00       	mov    $0xc,%eax
  80039c:	e8 1f fd ff ff       	call   8000c0 <syscall>
}
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    

008003a3 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
  8003a6:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8003a9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003b0:	00 
  8003b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003b8:	00 
  8003b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003c0:	00 
  8003c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c4:	89 04 24             	mov    %eax,(%esp)
  8003c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cf:	b8 04 00 00 00       	mov    $0x4,%eax
  8003d4:	e8 e7 fc ff ff       	call   8000c0 <syscall>
}
  8003d9:	c9                   	leave  
  8003da:	c3                   	ret    

008003db <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8003e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e8:	00 
  8003e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003f0:	00 
  8003f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003f8:	00 
  8003f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800400:	b9 00 00 00 00       	mov    $0x0,%ecx
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
  80040a:	b8 02 00 00 00       	mov    $0x2,%eax
  80040f:	e8 ac fc ff ff       	call   8000c0 <syscall>
}
  800414:	c9                   	leave  
  800415:	c3                   	ret    

00800416 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
  800419:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80041c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800423:	00 
  800424:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80042b:	00 
  80042c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800433:	00 
  800434:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80043b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043e:	ba 01 00 00 00       	mov    $0x1,%edx
  800443:	b8 03 00 00 00       	mov    $0x3,%eax
  800448:	e8 73 fc ff ff       	call   8000c0 <syscall>
}
  80044d:	c9                   	leave  
  80044e:	c3                   	ret    

0080044f <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80044f:	55                   	push   %ebp
  800450:	89 e5                	mov    %esp,%ebp
  800452:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800455:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80045c:	00 
  80045d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800464:	00 
  800465:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80046c:	00 
  80046d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800474:	b9 00 00 00 00       	mov    $0x0,%ecx
  800479:	ba 00 00 00 00       	mov    $0x0,%edx
  80047e:	b8 01 00 00 00       	mov    $0x1,%eax
  800483:	e8 38 fc ff ff       	call   8000c0 <syscall>
}
  800488:	c9                   	leave  
  800489:	c3                   	ret    

0080048a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800497:	00 
  800498:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80049f:	00 
  8004a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004a7:	00 
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	89 04 24             	mov    %eax,(%esp)
  8004ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bb:	e8 00 fc ff ff       	call   8000c0 <syscall>
}
  8004c0:	c9                   	leave  
  8004c1:	c3                   	ret    
	...

008004d0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004db:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8004de:	5d                   	pop    %ebp
  8004df:	c3                   	ret    

008004e0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e9:	89 04 24             	mov    %eax,(%esp)
  8004ec:	e8 df ff ff ff       	call   8004d0 <fd2num>
  8004f1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8004f6:	c1 e0 0c             	shl    $0xc,%eax
}
  8004f9:	c9                   	leave  
  8004fa:	c3                   	ret    

008004fb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	57                   	push   %edi
  8004ff:	56                   	push   %esi
  800500:	53                   	push   %ebx
  800501:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800504:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800509:	a8 01                	test   $0x1,%al
  80050b:	74 36                	je     800543 <fd_alloc+0x48>
  80050d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800512:	a8 01                	test   $0x1,%al
  800514:	74 2d                	je     800543 <fd_alloc+0x48>
  800516:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80051b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800520:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800525:	89 c3                	mov    %eax,%ebx
  800527:	89 c2                	mov    %eax,%edx
  800529:	c1 ea 16             	shr    $0x16,%edx
  80052c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80052f:	f6 c2 01             	test   $0x1,%dl
  800532:	74 14                	je     800548 <fd_alloc+0x4d>
  800534:	89 c2                	mov    %eax,%edx
  800536:	c1 ea 0c             	shr    $0xc,%edx
  800539:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80053c:	f6 c2 01             	test   $0x1,%dl
  80053f:	75 10                	jne    800551 <fd_alloc+0x56>
  800541:	eb 05                	jmp    800548 <fd_alloc+0x4d>
  800543:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800548:	89 1f                	mov    %ebx,(%edi)
  80054a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80054f:	eb 17                	jmp    800568 <fd_alloc+0x6d>
  800551:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800556:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80055b:	75 c8                	jne    800525 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80055d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800563:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800568:	5b                   	pop    %ebx
  800569:	5e                   	pop    %esi
  80056a:	5f                   	pop    %edi
  80056b:	5d                   	pop    %ebp
  80056c:	c3                   	ret    

0080056d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800570:	8b 45 08             	mov    0x8(%ebp),%eax
  800573:	83 f8 1f             	cmp    $0x1f,%eax
  800576:	77 36                	ja     8005ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800578:	05 00 00 0d 00       	add    $0xd0000,%eax
  80057d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800580:	89 c2                	mov    %eax,%edx
  800582:	c1 ea 16             	shr    $0x16,%edx
  800585:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80058c:	f6 c2 01             	test   $0x1,%dl
  80058f:	74 1d                	je     8005ae <fd_lookup+0x41>
  800591:	89 c2                	mov    %eax,%edx
  800593:	c1 ea 0c             	shr    $0xc,%edx
  800596:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80059d:	f6 c2 01             	test   $0x1,%dl
  8005a0:	74 0c                	je     8005ae <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005a5:	89 02                	mov    %eax,(%edx)
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8005ac:	eb 05                	jmp    8005b3 <fd_lookup+0x46>
  8005ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005b3:	5d                   	pop    %ebp
  8005b4:	c3                   	ret    

008005b5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8005b5:	55                   	push   %ebp
  8005b6:	89 e5                	mov    %esp,%ebp
  8005b8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005bb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8005be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005c5:	89 04 24             	mov    %eax,(%esp)
  8005c8:	e8 a0 ff ff ff       	call   80056d <fd_lookup>
  8005cd:	85 c0                	test   %eax,%eax
  8005cf:	78 0e                	js     8005df <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8005d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d7:	89 50 04             	mov    %edx,0x4(%eax)
  8005da:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8005df:	c9                   	leave  
  8005e0:	c3                   	ret    

008005e1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	56                   	push   %esi
  8005e5:	53                   	push   %ebx
  8005e6:	83 ec 10             	sub    $0x10,%esp
  8005e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8005ef:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8005f4:	b8 08 30 80 00       	mov    $0x803008,%eax
  8005f9:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8005ff:	75 11                	jne    800612 <dev_lookup+0x31>
  800601:	eb 04                	jmp    800607 <dev_lookup+0x26>
  800603:	39 08                	cmp    %ecx,(%eax)
  800605:	75 10                	jne    800617 <dev_lookup+0x36>
			*dev = devtab[i];
  800607:	89 03                	mov    %eax,(%ebx)
  800609:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80060e:	66 90                	xchg   %ax,%ax
  800610:	eb 36                	jmp    800648 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800612:	be 60 23 80 00       	mov    $0x802360,%esi
  800617:	83 c2 01             	add    $0x1,%edx
  80061a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80061d:	85 c0                	test   %eax,%eax
  80061f:	75 e2                	jne    800603 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800621:	a1 08 40 80 00       	mov    0x804008,%eax
  800626:	8b 40 48             	mov    0x48(%eax),%eax
  800629:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80062d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800631:	c7 04 24 e4 22 80 00 	movl   $0x8022e4,(%esp)
  800638:	e8 40 0d 00 00       	call   80137d <cprintf>
	*dev = 0;
  80063d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800643:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	5b                   	pop    %ebx
  80064c:	5e                   	pop    %esi
  80064d:	5d                   	pop    %ebp
  80064e:	c3                   	ret    

0080064f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80064f:	55                   	push   %ebp
  800650:	89 e5                	mov    %esp,%ebp
  800652:	53                   	push   %ebx
  800653:	83 ec 24             	sub    $0x24,%esp
  800656:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800659:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800660:	8b 45 08             	mov    0x8(%ebp),%eax
  800663:	89 04 24             	mov    %eax,(%esp)
  800666:	e8 02 ff ff ff       	call   80056d <fd_lookup>
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 53                	js     8006c2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800672:	89 44 24 04          	mov    %eax,0x4(%esp)
  800676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	89 04 24             	mov    %eax,(%esp)
  80067e:	e8 5e ff ff ff       	call   8005e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800683:	85 c0                	test   %eax,%eax
  800685:	78 3b                	js     8006c2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800687:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80068c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80068f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800693:	74 2d                	je     8006c2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800695:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800698:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80069f:	00 00 00 
	stat->st_isdir = 0;
  8006a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8006a9:	00 00 00 
	stat->st_dev = dev;
  8006ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8006b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006bc:	89 14 24             	mov    %edx,(%esp)
  8006bf:	ff 50 14             	call   *0x14(%eax)
}
  8006c2:	83 c4 24             	add    $0x24,%esp
  8006c5:	5b                   	pop    %ebx
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	53                   	push   %ebx
  8006cc:	83 ec 24             	sub    $0x24,%esp
  8006cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d9:	89 1c 24             	mov    %ebx,(%esp)
  8006dc:	e8 8c fe ff ff       	call   80056d <fd_lookup>
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 5f                	js     800744 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ef:	8b 00                	mov    (%eax),%eax
  8006f1:	89 04 24             	mov    %eax,(%esp)
  8006f4:	e8 e8 fe ff ff       	call   8005e1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	78 47                	js     800744 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800700:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800704:	75 23                	jne    800729 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800706:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80070b:	8b 40 48             	mov    0x48(%eax),%eax
  80070e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800712:	89 44 24 04          	mov    %eax,0x4(%esp)
  800716:	c7 04 24 04 23 80 00 	movl   $0x802304,(%esp)
  80071d:	e8 5b 0c 00 00       	call   80137d <cprintf>
  800722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800727:	eb 1b                	jmp    800744 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072c:	8b 48 18             	mov    0x18(%eax),%ecx
  80072f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800734:	85 c9                	test   %ecx,%ecx
  800736:	74 0c                	je     800744 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800738:	8b 45 0c             	mov    0xc(%ebp),%eax
  80073b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80073f:	89 14 24             	mov    %edx,(%esp)
  800742:	ff d1                	call   *%ecx
}
  800744:	83 c4 24             	add    $0x24,%esp
  800747:	5b                   	pop    %ebx
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	53                   	push   %ebx
  80074e:	83 ec 24             	sub    $0x24,%esp
  800751:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800754:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800757:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075b:	89 1c 24             	mov    %ebx,(%esp)
  80075e:	e8 0a fe ff ff       	call   80056d <fd_lookup>
  800763:	85 c0                	test   %eax,%eax
  800765:	78 66                	js     8007cd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800767:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 04 24             	mov    %eax,(%esp)
  800776:	e8 66 fe ff ff       	call   8005e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80077b:	85 c0                	test   %eax,%eax
  80077d:	78 4e                	js     8007cd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800782:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800786:	75 23                	jne    8007ab <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800788:	a1 08 40 80 00       	mov    0x804008,%eax
  80078d:	8b 40 48             	mov    0x48(%eax),%eax
  800790:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	c7 04 24 25 23 80 00 	movl   $0x802325,(%esp)
  80079f:	e8 d9 0b 00 00       	call   80137d <cprintf>
  8007a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8007a9:	eb 22                	jmp    8007cd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ae:	8b 48 0c             	mov    0xc(%eax),%ecx
  8007b1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007b6:	85 c9                	test   %ecx,%ecx
  8007b8:	74 13                	je     8007cd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c8:	89 14 24             	mov    %edx,(%esp)
  8007cb:	ff d1                	call   *%ecx
}
  8007cd:	83 c4 24             	add    $0x24,%esp
  8007d0:	5b                   	pop    %ebx
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	53                   	push   %ebx
  8007d7:	83 ec 24             	sub    $0x24,%esp
  8007da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e4:	89 1c 24             	mov    %ebx,(%esp)
  8007e7:	e8 81 fd ff ff       	call   80056d <fd_lookup>
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	78 6b                	js     80085b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	8b 00                	mov    (%eax),%eax
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	e8 dd fd ff ff       	call   8005e1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800804:	85 c0                	test   %eax,%eax
  800806:	78 53                	js     80085b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800808:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80080b:	8b 42 08             	mov    0x8(%edx),%eax
  80080e:	83 e0 03             	and    $0x3,%eax
  800811:	83 f8 01             	cmp    $0x1,%eax
  800814:	75 23                	jne    800839 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800816:	a1 08 40 80 00       	mov    0x804008,%eax
  80081b:	8b 40 48             	mov    0x48(%eax),%eax
  80081e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800822:	89 44 24 04          	mov    %eax,0x4(%esp)
  800826:	c7 04 24 42 23 80 00 	movl   $0x802342,(%esp)
  80082d:	e8 4b 0b 00 00       	call   80137d <cprintf>
  800832:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800837:	eb 22                	jmp    80085b <read+0x88>
	}
	if (!dev->dev_read)
  800839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083c:	8b 48 08             	mov    0x8(%eax),%ecx
  80083f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800844:	85 c9                	test   %ecx,%ecx
  800846:	74 13                	je     80085b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800848:	8b 45 10             	mov    0x10(%ebp),%eax
  80084b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800852:	89 44 24 04          	mov    %eax,0x4(%esp)
  800856:	89 14 24             	mov    %edx,(%esp)
  800859:	ff d1                	call   *%ecx
}
  80085b:	83 c4 24             	add    $0x24,%esp
  80085e:	5b                   	pop    %ebx
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	57                   	push   %edi
  800865:	56                   	push   %esi
  800866:	53                   	push   %ebx
  800867:	83 ec 1c             	sub    $0x1c,%esp
  80086a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80086d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800870:	ba 00 00 00 00       	mov    $0x0,%edx
  800875:	bb 00 00 00 00       	mov    $0x0,%ebx
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	85 f6                	test   %esi,%esi
  800881:	74 29                	je     8008ac <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800883:	89 f0                	mov    %esi,%eax
  800885:	29 d0                	sub    %edx,%eax
  800887:	89 44 24 08          	mov    %eax,0x8(%esp)
  80088b:	03 55 0c             	add    0xc(%ebp),%edx
  80088e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800892:	89 3c 24             	mov    %edi,(%esp)
  800895:	e8 39 ff ff ff       	call   8007d3 <read>
		if (m < 0)
  80089a:	85 c0                	test   %eax,%eax
  80089c:	78 0e                	js     8008ac <readn+0x4b>
			return m;
		if (m == 0)
  80089e:	85 c0                	test   %eax,%eax
  8008a0:	74 08                	je     8008aa <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008a2:	01 c3                	add    %eax,%ebx
  8008a4:	89 da                	mov    %ebx,%edx
  8008a6:	39 f3                	cmp    %esi,%ebx
  8008a8:	72 d9                	jb     800883 <readn+0x22>
  8008aa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8008ac:	83 c4 1c             	add    $0x1c,%esp
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5f                   	pop    %edi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	83 ec 28             	sub    $0x28,%esp
  8008ba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8008bd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8008c0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008c3:	89 34 24             	mov    %esi,(%esp)
  8008c6:	e8 05 fc ff ff       	call   8004d0 <fd2num>
  8008cb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d2:	89 04 24             	mov    %eax,(%esp)
  8008d5:	e8 93 fc ff ff       	call   80056d <fd_lookup>
  8008da:	89 c3                	mov    %eax,%ebx
  8008dc:	85 c0                	test   %eax,%eax
  8008de:	78 05                	js     8008e5 <fd_close+0x31>
  8008e0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008e3:	74 0e                	je     8008f3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8008e5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ee:	0f 44 d8             	cmove  %eax,%ebx
  8008f1:	eb 3d                	jmp    800930 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fa:	8b 06                	mov    (%esi),%eax
  8008fc:	89 04 24             	mov    %eax,(%esp)
  8008ff:	e8 dd fc ff ff       	call   8005e1 <dev_lookup>
  800904:	89 c3                	mov    %eax,%ebx
  800906:	85 c0                	test   %eax,%eax
  800908:	78 16                	js     800920 <fd_close+0x6c>
		if (dev->dev_close)
  80090a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80090d:	8b 40 10             	mov    0x10(%eax),%eax
  800910:	bb 00 00 00 00       	mov    $0x0,%ebx
  800915:	85 c0                	test   %eax,%eax
  800917:	74 07                	je     800920 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800919:	89 34 24             	mov    %esi,(%esp)
  80091c:	ff d0                	call   *%eax
  80091e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800920:	89 74 24 04          	mov    %esi,0x4(%esp)
  800924:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80092b:	e8 90 f9 ff ff       	call   8002c0 <sys_page_unmap>
	return r;
}
  800930:	89 d8                	mov    %ebx,%eax
  800932:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800935:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800938:	89 ec                	mov    %ebp,%esp
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800942:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	8b 45 08             	mov    0x8(%ebp),%eax
  80094c:	89 04 24             	mov    %eax,(%esp)
  80094f:	e8 19 fc ff ff       	call   80056d <fd_lookup>
  800954:	85 c0                	test   %eax,%eax
  800956:	78 13                	js     80096b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800958:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80095f:	00 
  800960:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800963:	89 04 24             	mov    %eax,(%esp)
  800966:	e8 49 ff ff ff       	call   8008b4 <fd_close>
}
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 18             	sub    $0x18,%esp
  800973:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800976:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800979:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800980:	00 
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	89 04 24             	mov    %eax,(%esp)
  800987:	e8 78 03 00 00       	call   800d04 <open>
  80098c:	89 c3                	mov    %eax,%ebx
  80098e:	85 c0                	test   %eax,%eax
  800990:	78 1b                	js     8009ad <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800992:	8b 45 0c             	mov    0xc(%ebp),%eax
  800995:	89 44 24 04          	mov    %eax,0x4(%esp)
  800999:	89 1c 24             	mov    %ebx,(%esp)
  80099c:	e8 ae fc ff ff       	call   80064f <fstat>
  8009a1:	89 c6                	mov    %eax,%esi
	close(fd);
  8009a3:	89 1c 24             	mov    %ebx,(%esp)
  8009a6:	e8 91 ff ff ff       	call   80093c <close>
  8009ab:	89 f3                	mov    %esi,%ebx
	return r;
}
  8009ad:	89 d8                	mov    %ebx,%eax
  8009af:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8009b2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8009b5:	89 ec                	mov    %ebp,%esp
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	83 ec 14             	sub    $0x14,%esp
  8009c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8009c5:	89 1c 24             	mov    %ebx,(%esp)
  8009c8:	e8 6f ff ff ff       	call   80093c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009cd:	83 c3 01             	add    $0x1,%ebx
  8009d0:	83 fb 20             	cmp    $0x20,%ebx
  8009d3:	75 f0                	jne    8009c5 <close_all+0xc>
		close(i);
}
  8009d5:	83 c4 14             	add    $0x14,%esp
  8009d8:	5b                   	pop    %ebx
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 58             	sub    $0x58,%esp
  8009e1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009e4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009e7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	89 04 24             	mov    %eax,(%esp)
  8009fa:	e8 6e fb ff ff       	call   80056d <fd_lookup>
  8009ff:	89 c3                	mov    %eax,%ebx
  800a01:	85 c0                	test   %eax,%eax
  800a03:	0f 88 e0 00 00 00    	js     800ae9 <dup+0x10e>
		return r;
	close(newfdnum);
  800a09:	89 3c 24             	mov    %edi,(%esp)
  800a0c:	e8 2b ff ff ff       	call   80093c <close>

	newfd = INDEX2FD(newfdnum);
  800a11:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a17:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a1d:	89 04 24             	mov    %eax,(%esp)
  800a20:	e8 bb fa ff ff       	call   8004e0 <fd2data>
  800a25:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a27:	89 34 24             	mov    %esi,(%esp)
  800a2a:	e8 b1 fa ff ff       	call   8004e0 <fd2data>
  800a2f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800a32:	89 da                	mov    %ebx,%edx
  800a34:	89 d8                	mov    %ebx,%eax
  800a36:	c1 e8 16             	shr    $0x16,%eax
  800a39:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a40:	a8 01                	test   $0x1,%al
  800a42:	74 43                	je     800a87 <dup+0xac>
  800a44:	c1 ea 0c             	shr    $0xc,%edx
  800a47:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a4e:	a8 01                	test   $0x1,%al
  800a50:	74 35                	je     800a87 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a52:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a59:	25 07 0e 00 00       	and    $0xe07,%eax
  800a5e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a70:	00 
  800a71:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a75:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a7c:	e8 77 f8 ff ff       	call   8002f8 <sys_page_map>
  800a81:	89 c3                	mov    %eax,%ebx
  800a83:	85 c0                	test   %eax,%eax
  800a85:	78 3f                	js     800ac6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a8a:	89 c2                	mov    %eax,%edx
  800a8c:	c1 ea 0c             	shr    $0xc,%edx
  800a8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a96:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a9c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800aa0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800aa4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800aab:	00 
  800aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ab7:	e8 3c f8 ff ff       	call   8002f8 <sys_page_map>
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 04                	js     800ac6 <dup+0xeb>
  800ac2:	89 fb                	mov    %edi,%ebx
  800ac4:	eb 23                	jmp    800ae9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ac6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aca:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad1:	e8 ea f7 ff ff       	call   8002c0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ad6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ad9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800add:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ae4:	e8 d7 f7 ff ff       	call   8002c0 <sys_page_unmap>
	return r;
}
  800ae9:	89 d8                	mov    %ebx,%eax
  800aeb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800aee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800af1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800af4:	89 ec                	mov    %ebp,%esp
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    

00800af8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 18             	sub    $0x18,%esp
  800afe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b01:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b08:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b0f:	75 11                	jne    800b22 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b11:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b18:	e8 93 13 00 00       	call   801eb0 <ipc_find_env>
  800b1d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b22:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b29:	00 
  800b2a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b31:	00 
  800b32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b36:	a1 00 40 80 00       	mov    0x804000,%eax
  800b3b:	89 04 24             	mov    %eax,(%esp)
  800b3e:	e8 b1 13 00 00       	call   801ef4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b4a:	00 
  800b4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b4f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b56:	e8 04 14 00 00       	call   801f5f <ipc_recv>
}
  800b5b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b5e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b61:	89 ec                	mov    %ebp,%esp
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	8b 40 0c             	mov    0xc(%eax),%eax
  800b71:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b76:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b79:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b83:	b8 02 00 00 00       	mov    $0x2,%eax
  800b88:	e8 6b ff ff ff       	call   800af8 <fsipc>
}
  800b8d:	c9                   	leave  
  800b8e:	c3                   	ret    

00800b8f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b95:	8b 45 08             	mov    0x8(%ebp),%eax
  800b98:	8b 40 0c             	mov    0xc(%eax),%eax
  800b9b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 06 00 00 00       	mov    $0x6,%eax
  800baa:	e8 49 ff ff ff       	call   800af8 <fsipc>
}
  800baf:	c9                   	leave  
  800bb0:	c3                   	ret    

00800bb1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bb7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbc:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc1:	e8 32 ff ff ff       	call   800af8 <fsipc>
}
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 14             	sub    $0x14,%esp
  800bcf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 40 0c             	mov    0xc(%eax),%eax
  800bd8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 05 00 00 00       	mov    $0x5,%eax
  800be7:	e8 0c ff ff ff       	call   800af8 <fsipc>
  800bec:	85 c0                	test   %eax,%eax
  800bee:	78 2b                	js     800c1b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800bf0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800bf7:	00 
  800bf8:	89 1c 24             	mov    %ebx,(%esp)
  800bfb:	e8 ba 0e 00 00       	call   801aba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c00:	a1 80 50 80 00       	mov    0x805080,%eax
  800c05:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c0b:	a1 84 50 80 00       	mov    0x805084,%eax
  800c10:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800c16:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800c1b:	83 c4 14             	add    $0x14,%esp
  800c1e:	5b                   	pop    %ebx
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 18             	sub    $0x18,%esp
  800c27:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800c2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2d:	8b 52 0c             	mov    0xc(%edx),%edx
  800c30:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800c36:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800c3b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800c40:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800c45:	0f 47 c2             	cmova  %edx,%eax
  800c48:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c53:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800c5a:	e8 46 10 00 00       	call   801ca5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 04 00 00 00       	mov    $0x4,%eax
  800c69:	e8 8a fe ff ff       	call   800af8 <fsipc>
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	53                   	push   %ebx
  800c74:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c77:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7a:	8b 40 0c             	mov    0xc(%eax),%eax
  800c7d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800c82:	8b 45 10             	mov    0x10(%ebp),%eax
  800c85:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c8a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c94:	e8 5f fe ff ff       	call   800af8 <fsipc>
  800c99:	89 c3                	mov    %eax,%ebx
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	78 17                	js     800cb6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ca3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800caa:	00 
  800cab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cae:	89 04 24             	mov    %eax,(%esp)
  800cb1:	e8 ef 0f 00 00       	call   801ca5 <memmove>
  return r;	
}
  800cb6:	89 d8                	mov    %ebx,%eax
  800cb8:	83 c4 14             	add    $0x14,%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 14             	sub    $0x14,%esp
  800cc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cc8:	89 1c 24             	mov    %ebx,(%esp)
  800ccb:	e8 a0 0d 00 00       	call   801a70 <strlen>
  800cd0:	89 c2                	mov    %eax,%edx
  800cd2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800cd7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800cdd:	7f 1f                	jg     800cfe <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800cdf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ce3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cea:	e8 cb 0d 00 00       	call   801aba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800cef:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf4:	b8 07 00 00 00       	mov    $0x7,%eax
  800cf9:	e8 fa fd ff ff       	call   800af8 <fsipc>
}
  800cfe:	83 c4 14             	add    $0x14,%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	83 ec 28             	sub    $0x28,%esp
  800d0a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d0d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d10:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800d13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d16:	89 04 24             	mov    %eax,(%esp)
  800d19:	e8 dd f7 ff ff       	call   8004fb <fd_alloc>
  800d1e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800d20:	85 c0                	test   %eax,%eax
  800d22:	0f 88 89 00 00 00    	js     800db1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d28:	89 34 24             	mov    %esi,(%esp)
  800d2b:	e8 40 0d 00 00       	call   801a70 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800d30:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800d3a:	7f 75                	jg     800db1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800d3c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d40:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d47:	e8 6e 0d 00 00       	call   801aba <strcpy>
  fsipcbuf.open.req_omode = mode;
  800d4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d4f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800d54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d57:	b8 01 00 00 00       	mov    $0x1,%eax
  800d5c:	e8 97 fd ff ff       	call   800af8 <fsipc>
  800d61:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800d63:	85 c0                	test   %eax,%eax
  800d65:	78 0f                	js     800d76 <open+0x72>
  return fd2num(fd);
  800d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d6a:	89 04 24             	mov    %eax,(%esp)
  800d6d:	e8 5e f7 ff ff       	call   8004d0 <fd2num>
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	eb 3b                	jmp    800db1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800d76:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d7d:	00 
  800d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d81:	89 04 24             	mov    %eax,(%esp)
  800d84:	e8 2b fb ff ff       	call   8008b4 <fd_close>
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	74 24                	je     800db1 <open+0xad>
  800d8d:	c7 44 24 0c 6c 23 80 	movl   $0x80236c,0xc(%esp)
  800d94:	00 
  800d95:	c7 44 24 08 81 23 80 	movl   $0x802381,0x8(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800da4:	00 
  800da5:	c7 04 24 96 23 80 00 	movl   $0x802396,(%esp)
  800dac:	e8 13 05 00 00       	call   8012c4 <_panic>
  return r;
}
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800db6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800db9:	89 ec                	mov    %ebp,%esp
  800dbb:	5d                   	pop    %ebp
  800dbc:	c3                   	ret    
  800dbd:	00 00                	add    %al,(%eax)
	...

00800dc0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800dc6:	c7 44 24 04 a1 23 80 	movl   $0x8023a1,0x4(%esp)
  800dcd:	00 
  800dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd1:	89 04 24             	mov    %eax,(%esp)
  800dd4:	e8 e1 0c 00 00       	call   801aba <strcpy>
	return 0;
}
  800dd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	53                   	push   %ebx
  800de4:	83 ec 14             	sub    $0x14,%esp
  800de7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800dea:	89 1c 24             	mov    %ebx,(%esp)
  800ded:	e8 fa 11 00 00       	call   801fec <pageref>
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	b8 00 00 00 00       	mov    $0x0,%eax
  800df9:	83 fa 01             	cmp    $0x1,%edx
  800dfc:	75 0b                	jne    800e09 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800dfe:	8b 43 0c             	mov    0xc(%ebx),%eax
  800e01:	89 04 24             	mov    %eax,(%esp)
  800e04:	e8 b9 02 00 00       	call   8010c2 <nsipc_close>
	else
		return 0;
}
  800e09:	83 c4 14             	add    $0x14,%esp
  800e0c:	5b                   	pop    %ebx
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800e15:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e1c:	00 
  800e1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e20:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800e31:	89 04 24             	mov    %eax,(%esp)
  800e34:	e8 c5 02 00 00       	call   8010fe <nsipc_send>
}
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800e41:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e48:	00 
  800e49:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e5d:	89 04 24             	mov    %eax,(%esp)
  800e60:	e8 0c 03 00 00       	call   801171 <nsipc_recv>
}
  800e65:	c9                   	leave  
  800e66:	c3                   	ret    

00800e67 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 20             	sub    $0x20,%esp
  800e6f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e71:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e74:	89 04 24             	mov    %eax,(%esp)
  800e77:	e8 7f f6 ff ff       	call   8004fb <fd_alloc>
  800e7c:	89 c3                	mov    %eax,%ebx
  800e7e:	85 c0                	test   %eax,%eax
  800e80:	78 21                	js     800ea3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800e82:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e89:	00 
  800e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e91:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e98:	e8 94 f4 ff ff       	call   800331 <sys_page_alloc>
  800e9d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	79 0a                	jns    800ead <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  800ea3:	89 34 24             	mov    %esi,(%esp)
  800ea6:	e8 17 02 00 00       	call   8010c2 <nsipc_close>
		return r;
  800eab:	eb 28                	jmp    800ed5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ead:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ec8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecb:	89 04 24             	mov    %eax,(%esp)
  800ece:	e8 fd f5 ff ff       	call   8004d0 <fd2num>
  800ed3:	89 c3                	mov    %eax,%ebx
}
  800ed5:	89 d8                	mov    %ebx,%eax
  800ed7:	83 c4 20             	add    $0x20,%esp
  800eda:	5b                   	pop    %ebx
  800edb:	5e                   	pop    %esi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ee4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eee:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef5:	89 04 24             	mov    %eax,(%esp)
  800ef8:	e8 79 01 00 00       	call   801076 <nsipc_socket>
  800efd:	85 c0                	test   %eax,%eax
  800eff:	78 05                	js     800f06 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f01:	e8 61 ff ff ff       	call   800e67 <alloc_sockfd>
}
  800f06:	c9                   	leave  
  800f07:	c3                   	ret    

00800f08 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f08:	55                   	push   %ebp
  800f09:	89 e5                	mov    %esp,%ebp
  800f0b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f0e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f11:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f15:	89 04 24             	mov    %eax,(%esp)
  800f18:	e8 50 f6 ff ff       	call   80056d <fd_lookup>
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	78 15                	js     800f36 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f21:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f24:	8b 0a                	mov    (%edx),%ecx
  800f26:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f2b:	3b 0d 24 30 80 00    	cmp    0x803024,%ecx
  800f31:	75 03                	jne    800f36 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f33:	8b 42 0c             	mov    0xc(%edx),%eax
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	e8 c2 ff ff ff       	call   800f08 <fd2sockid>
  800f46:	85 c0                	test   %eax,%eax
  800f48:	78 0f                	js     800f59 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f4d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f51:	89 04 24             	mov    %eax,(%esp)
  800f54:	e8 47 01 00 00       	call   8010a0 <nsipc_listen>
}
  800f59:	c9                   	leave  
  800f5a:	c3                   	ret    

00800f5b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f61:	8b 45 08             	mov    0x8(%ebp),%eax
  800f64:	e8 9f ff ff ff       	call   800f08 <fd2sockid>
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	78 16                	js     800f83 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800f6d:	8b 55 10             	mov    0x10(%ebp),%edx
  800f70:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f77:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f7b:	89 04 24             	mov    %eax,(%esp)
  800f7e:	e8 6e 02 00 00       	call   8011f1 <nsipc_connect>
}
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	e8 75 ff ff ff       	call   800f08 <fd2sockid>
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 0f                	js     800fa6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800f97:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f9a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f9e:	89 04 24             	mov    %eax,(%esp)
  800fa1:	e8 36 01 00 00       	call   8010dc <nsipc_shutdown>
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb1:	e8 52 ff ff ff       	call   800f08 <fd2sockid>
  800fb6:	85 c0                	test   %eax,%eax
  800fb8:	78 16                	js     800fd0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800fba:	8b 55 10             	mov    0x10(%ebp),%edx
  800fbd:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fc8:	89 04 24             	mov    %eax,(%esp)
  800fcb:	e8 60 02 00 00       	call   801230 <nsipc_bind>
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdb:	e8 28 ff ff ff       	call   800f08 <fd2sockid>
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 1f                	js     801003 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800fe4:	8b 55 10             	mov    0x10(%ebp),%edx
  800fe7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800feb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fee:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ff2:	89 04 24             	mov    %eax,(%esp)
  800ff5:	e8 75 02 00 00       	call   80126f <nsipc_accept>
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	78 05                	js     801003 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800ffe:	e8 64 fe ff ff       	call   800e67 <alloc_sockfd>
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    
	...

00801010 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	53                   	push   %ebx
  801014:	83 ec 14             	sub    $0x14,%esp
  801017:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801019:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801020:	75 11                	jne    801033 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801022:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801029:	e8 82 0e 00 00       	call   801eb0 <ipc_find_env>
  80102e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801033:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80103a:	00 
  80103b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801042:	00 
  801043:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801047:	a1 04 40 80 00       	mov    0x804004,%eax
  80104c:	89 04 24             	mov    %eax,(%esp)
  80104f:	e8 a0 0e 00 00       	call   801ef4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801054:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80105b:	00 
  80105c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801063:	00 
  801064:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80106b:	e8 ef 0e 00 00       	call   801f5f <ipc_recv>
}
  801070:	83 c4 14             	add    $0x14,%esp
  801073:	5b                   	pop    %ebx
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    

00801076 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80107c:	8b 45 08             	mov    0x8(%ebp),%eax
  80107f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801084:	8b 45 0c             	mov    0xc(%ebp),%eax
  801087:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80108c:	8b 45 10             	mov    0x10(%ebp),%eax
  80108f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801094:	b8 09 00 00 00       	mov    $0x9,%eax
  801099:	e8 72 ff ff ff       	call   801010 <nsipc>
}
  80109e:	c9                   	leave  
  80109f:	c3                   	ret    

008010a0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010b6:	b8 06 00 00 00       	mov    $0x6,%eax
  8010bb:	e8 50 ff ff ff       	call   801010 <nsipc>
}
  8010c0:	c9                   	leave  
  8010c1:	c3                   	ret    

008010c2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010cb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8010d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010d5:	e8 36 ff ff ff       	call   801010 <nsipc>
}
  8010da:	c9                   	leave  
  8010db:	c3                   	ret    

008010dc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8010ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ed:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8010f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8010f7:	e8 14 ff ff ff       	call   801010 <nsipc>
}
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    

008010fe <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	53                   	push   %ebx
  801102:	83 ec 14             	sub    $0x14,%esp
  801105:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801108:	8b 45 08             	mov    0x8(%ebp),%eax
  80110b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801110:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801116:	7e 24                	jle    80113c <nsipc_send+0x3e>
  801118:	c7 44 24 0c ad 23 80 	movl   $0x8023ad,0xc(%esp)
  80111f:	00 
  801120:	c7 44 24 08 81 23 80 	movl   $0x802381,0x8(%esp)
  801127:	00 
  801128:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80112f:	00 
  801130:	c7 04 24 b9 23 80 00 	movl   $0x8023b9,(%esp)
  801137:	e8 88 01 00 00       	call   8012c4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80113c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801140:	8b 45 0c             	mov    0xc(%ebp),%eax
  801143:	89 44 24 04          	mov    %eax,0x4(%esp)
  801147:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80114e:	e8 52 0b 00 00       	call   801ca5 <memmove>
	nsipcbuf.send.req_size = size;
  801153:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801159:	8b 45 14             	mov    0x14(%ebp),%eax
  80115c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801161:	b8 08 00 00 00       	mov    $0x8,%eax
  801166:	e8 a5 fe ff ff       	call   801010 <nsipc>
}
  80116b:	83 c4 14             	add    $0x14,%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5d                   	pop    %ebp
  801170:	c3                   	ret    

00801171 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 10             	sub    $0x10,%esp
  801179:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80117c:	8b 45 08             	mov    0x8(%ebp),%eax
  80117f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801184:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80118a:	8b 45 14             	mov    0x14(%ebp),%eax
  80118d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801192:	b8 07 00 00 00       	mov    $0x7,%eax
  801197:	e8 74 fe ff ff       	call   801010 <nsipc>
  80119c:	89 c3                	mov    %eax,%ebx
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 46                	js     8011e8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8011a2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8011a7:	7f 04                	jg     8011ad <nsipc_recv+0x3c>
  8011a9:	39 c6                	cmp    %eax,%esi
  8011ab:	7d 24                	jge    8011d1 <nsipc_recv+0x60>
  8011ad:	c7 44 24 0c c5 23 80 	movl   $0x8023c5,0xc(%esp)
  8011b4:	00 
  8011b5:	c7 44 24 08 81 23 80 	movl   $0x802381,0x8(%esp)
  8011bc:	00 
  8011bd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8011c4:	00 
  8011c5:	c7 04 24 b9 23 80 00 	movl   $0x8023b9,(%esp)
  8011cc:	e8 f3 00 00 00       	call   8012c4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8011d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011d5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8011dc:	00 
  8011dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e0:	89 04 24             	mov    %eax,(%esp)
  8011e3:	e8 bd 0a 00 00       	call   801ca5 <memmove>
	}

	return r;
}
  8011e8:	89 d8                	mov    %ebx,%eax
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 14             	sub    $0x14,%esp
  8011f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fe:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801203:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80120a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801215:	e8 8b 0a 00 00       	call   801ca5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80121a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801220:	b8 05 00 00 00       	mov    $0x5,%eax
  801225:	e8 e6 fd ff ff       	call   801010 <nsipc>
}
  80122a:	83 c4 14             	add    $0x14,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	53                   	push   %ebx
  801234:	83 ec 14             	sub    $0x14,%esp
  801237:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801242:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801246:	8b 45 0c             	mov    0xc(%ebp),%eax
  801249:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801254:	e8 4c 0a 00 00       	call   801ca5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801259:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80125f:	b8 02 00 00 00       	mov    $0x2,%eax
  801264:	e8 a7 fd ff ff       	call   801010 <nsipc>
}
  801269:	83 c4 14             	add    $0x14,%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    

0080126f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	83 ec 18             	sub    $0x18,%esp
  801275:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801278:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80127b:	8b 45 08             	mov    0x8(%ebp),%eax
  80127e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801283:	b8 01 00 00 00       	mov    $0x1,%eax
  801288:	e8 83 fd ff ff       	call   801010 <nsipc>
  80128d:	89 c3                	mov    %eax,%ebx
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 25                	js     8012b8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801293:	be 10 60 80 00       	mov    $0x806010,%esi
  801298:	8b 06                	mov    (%esi),%eax
  80129a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80129e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8012a5:	00 
  8012a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012a9:	89 04 24             	mov    %eax,(%esp)
  8012ac:	e8 f4 09 00 00       	call   801ca5 <memmove>
		*addrlen = ret->ret_addrlen;
  8012b1:	8b 16                	mov    (%esi),%edx
  8012b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8012b6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8012b8:	89 d8                	mov    %ebx,%eax
  8012ba:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012bd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8012c0:	89 ec                	mov    %ebp,%esp
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    

008012c4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8012cc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012cf:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8012d5:	e8 01 f1 ff ff       	call   8003db <sys_getenvid>
  8012da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012dd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f0:	c7 04 24 dc 23 80 00 	movl   $0x8023dc,(%esp)
  8012f7:	e8 81 00 00 00       	call   80137d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  801300:	8b 45 10             	mov    0x10(%ebp),%eax
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 11 00 00 00       	call   80131c <vcprintf>
	cprintf("\n");
  80130b:	c7 04 24 ac 22 80 00 	movl   $0x8022ac,(%esp)
  801312:	e8 66 00 00 00       	call   80137d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801317:	cc                   	int3   
  801318:	eb fd                	jmp    801317 <_panic+0x53>
	...

0080131c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80131c:	55                   	push   %ebp
  80131d:	89 e5                	mov    %esp,%ebp
  80131f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801325:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80132c:	00 00 00 
	b.cnt = 0;
  80132f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801336:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801339:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801340:	8b 45 08             	mov    0x8(%ebp),%eax
  801343:	89 44 24 08          	mov    %eax,0x8(%esp)
  801347:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	c7 04 24 97 13 80 00 	movl   $0x801397,(%esp)
  801358:	e8 d0 01 00 00       	call   80152d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80135d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801363:	89 44 24 04          	mov    %eax,0x4(%esp)
  801367:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80136d:	89 04 24             	mov    %eax,(%esp)
  801370:	e8 15 f1 ff ff       	call   80048a <sys_cputs>

	return b.cnt;
}
  801375:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80137b:	c9                   	leave  
  80137c:	c3                   	ret    

0080137d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801383:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 87 ff ff ff       	call   80131c <vcprintf>
	va_end(ap);

	return cnt;
}
  801395:	c9                   	leave  
  801396:	c3                   	ret    

00801397 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801397:	55                   	push   %ebp
  801398:	89 e5                	mov    %esp,%ebp
  80139a:	53                   	push   %ebx
  80139b:	83 ec 14             	sub    $0x14,%esp
  80139e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013a1:	8b 03                	mov    (%ebx),%eax
  8013a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013a6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8013aa:	83 c0 01             	add    $0x1,%eax
  8013ad:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8013af:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013b4:	75 19                	jne    8013cf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8013b6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8013bd:	00 
  8013be:	8d 43 08             	lea    0x8(%ebx),%eax
  8013c1:	89 04 24             	mov    %eax,(%esp)
  8013c4:	e8 c1 f0 ff ff       	call   80048a <sys_cputs>
		b->idx = 0;
  8013c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8013cf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013d3:	83 c4 14             	add    $0x14,%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    
  8013d9:	00 00                	add    %al,(%eax)
  8013db:	00 00                	add    %al,(%eax)
  8013dd:	00 00                	add    %al,(%eax)
	...

008013e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	57                   	push   %edi
  8013e4:	56                   	push   %esi
  8013e5:	53                   	push   %ebx
  8013e6:	83 ec 4c             	sub    $0x4c,%esp
  8013e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013ec:	89 d6                	mov    %edx,%esi
  8013ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8013fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801400:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801403:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80140b:	39 d1                	cmp    %edx,%ecx
  80140d:	72 15                	jb     801424 <printnum+0x44>
  80140f:	77 07                	ja     801418 <printnum+0x38>
  801411:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801414:	39 d0                	cmp    %edx,%eax
  801416:	76 0c                	jbe    801424 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801418:	83 eb 01             	sub    $0x1,%ebx
  80141b:	85 db                	test   %ebx,%ebx
  80141d:	8d 76 00             	lea    0x0(%esi),%esi
  801420:	7f 61                	jg     801483 <printnum+0xa3>
  801422:	eb 70                	jmp    801494 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801424:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801428:	83 eb 01             	sub    $0x1,%ebx
  80142b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80142f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801433:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801437:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80143b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80143e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801441:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801444:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801448:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80144f:	00 
  801450:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801453:	89 04 24             	mov    %eax,(%esp)
  801456:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801459:	89 54 24 04          	mov    %edx,0x4(%esp)
  80145d:	e8 ce 0b 00 00       	call   802030 <__udivdi3>
  801462:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801465:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801468:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80146c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801470:	89 04 24             	mov    %eax,(%esp)
  801473:	89 54 24 04          	mov    %edx,0x4(%esp)
  801477:	89 f2                	mov    %esi,%edx
  801479:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80147c:	e8 5f ff ff ff       	call   8013e0 <printnum>
  801481:	eb 11                	jmp    801494 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801483:	89 74 24 04          	mov    %esi,0x4(%esp)
  801487:	89 3c 24             	mov    %edi,(%esp)
  80148a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80148d:	83 eb 01             	sub    $0x1,%ebx
  801490:	85 db                	test   %ebx,%ebx
  801492:	7f ef                	jg     801483 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801494:	89 74 24 04          	mov    %esi,0x4(%esp)
  801498:	8b 74 24 04          	mov    0x4(%esp),%esi
  80149c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80149f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014aa:	00 
  8014ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ae:	89 14 24             	mov    %edx,(%esp)
  8014b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014b8:	e8 a3 0c 00 00       	call   802160 <__umoddi3>
  8014bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c1:	0f be 80 ff 23 80 00 	movsbl 0x8023ff(%eax),%eax
  8014c8:	89 04 24             	mov    %eax,(%esp)
  8014cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014ce:	83 c4 4c             	add    $0x4c,%esp
  8014d1:	5b                   	pop    %ebx
  8014d2:	5e                   	pop    %esi
  8014d3:	5f                   	pop    %edi
  8014d4:	5d                   	pop    %ebp
  8014d5:	c3                   	ret    

008014d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014d9:	83 fa 01             	cmp    $0x1,%edx
  8014dc:	7e 0e                	jle    8014ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014de:	8b 10                	mov    (%eax),%edx
  8014e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014e3:	89 08                	mov    %ecx,(%eax)
  8014e5:	8b 02                	mov    (%edx),%eax
  8014e7:	8b 52 04             	mov    0x4(%edx),%edx
  8014ea:	eb 22                	jmp    80150e <getuint+0x38>
	else if (lflag)
  8014ec:	85 d2                	test   %edx,%edx
  8014ee:	74 10                	je     801500 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014f0:	8b 10                	mov    (%eax),%edx
  8014f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014f5:	89 08                	mov    %ecx,(%eax)
  8014f7:	8b 02                	mov    (%edx),%eax
  8014f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fe:	eb 0e                	jmp    80150e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801500:	8b 10                	mov    (%eax),%edx
  801502:	8d 4a 04             	lea    0x4(%edx),%ecx
  801505:	89 08                	mov    %ecx,(%eax)
  801507:	8b 02                	mov    (%edx),%eax
  801509:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80150e:	5d                   	pop    %ebp
  80150f:	c3                   	ret    

00801510 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801516:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80151a:	8b 10                	mov    (%eax),%edx
  80151c:	3b 50 04             	cmp    0x4(%eax),%edx
  80151f:	73 0a                	jae    80152b <sprintputch+0x1b>
		*b->buf++ = ch;
  801521:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801524:	88 0a                	mov    %cl,(%edx)
  801526:	83 c2 01             	add    $0x1,%edx
  801529:	89 10                	mov    %edx,(%eax)
}
  80152b:	5d                   	pop    %ebp
  80152c:	c3                   	ret    

0080152d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	57                   	push   %edi
  801531:	56                   	push   %esi
  801532:	53                   	push   %ebx
  801533:	83 ec 5c             	sub    $0x5c,%esp
  801536:	8b 7d 08             	mov    0x8(%ebp),%edi
  801539:	8b 75 0c             	mov    0xc(%ebp),%esi
  80153c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80153f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801546:	eb 11                	jmp    801559 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801548:	85 c0                	test   %eax,%eax
  80154a:	0f 84 68 04 00 00    	je     8019b8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  801550:	89 74 24 04          	mov    %esi,0x4(%esp)
  801554:	89 04 24             	mov    %eax,(%esp)
  801557:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801559:	0f b6 03             	movzbl (%ebx),%eax
  80155c:	83 c3 01             	add    $0x1,%ebx
  80155f:	83 f8 25             	cmp    $0x25,%eax
  801562:	75 e4                	jne    801548 <vprintfmt+0x1b>
  801564:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80156b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801572:	b9 00 00 00 00       	mov    $0x0,%ecx
  801577:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80157b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801582:	eb 06                	jmp    80158a <vprintfmt+0x5d>
  801584:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  801588:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80158a:	0f b6 13             	movzbl (%ebx),%edx
  80158d:	0f b6 c2             	movzbl %dl,%eax
  801590:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801593:	8d 43 01             	lea    0x1(%ebx),%eax
  801596:	83 ea 23             	sub    $0x23,%edx
  801599:	80 fa 55             	cmp    $0x55,%dl
  80159c:	0f 87 f9 03 00 00    	ja     80199b <vprintfmt+0x46e>
  8015a2:	0f b6 d2             	movzbl %dl,%edx
  8015a5:	ff 24 95 e0 25 80 00 	jmp    *0x8025e0(,%edx,4)
  8015ac:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8015b0:	eb d6                	jmp    801588 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015b5:	83 ea 30             	sub    $0x30,%edx
  8015b8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8015bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015be:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015c1:	83 fb 09             	cmp    $0x9,%ebx
  8015c4:	77 54                	ja     80161a <vprintfmt+0xed>
  8015c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8015c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015cc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8015cf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8015d2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8015d6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015dc:	83 fb 09             	cmp    $0x9,%ebx
  8015df:	76 eb                	jbe    8015cc <vprintfmt+0x9f>
  8015e1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8015e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8015e7:	eb 31                	jmp    80161a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015e9:	8b 55 14             	mov    0x14(%ebp),%edx
  8015ec:	8d 5a 04             	lea    0x4(%edx),%ebx
  8015ef:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8015f2:	8b 12                	mov    (%edx),%edx
  8015f4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8015f7:	eb 21                	jmp    80161a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8015f9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801602:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  801606:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801609:	e9 7a ff ff ff       	jmp    801588 <vprintfmt+0x5b>
  80160e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801615:	e9 6e ff ff ff       	jmp    801588 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80161a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80161e:	0f 89 64 ff ff ff    	jns    801588 <vprintfmt+0x5b>
  801624:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801627:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80162a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80162d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801630:	e9 53 ff ff ff       	jmp    801588 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801635:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  801638:	e9 4b ff ff ff       	jmp    801588 <vprintfmt+0x5b>
  80163d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801640:	8b 45 14             	mov    0x14(%ebp),%eax
  801643:	8d 50 04             	lea    0x4(%eax),%edx
  801646:	89 55 14             	mov    %edx,0x14(%ebp)
  801649:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164d:	8b 00                	mov    (%eax),%eax
  80164f:	89 04 24             	mov    %eax,(%esp)
  801652:	ff d7                	call   *%edi
  801654:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801657:	e9 fd fe ff ff       	jmp    801559 <vprintfmt+0x2c>
  80165c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80165f:	8b 45 14             	mov    0x14(%ebp),%eax
  801662:	8d 50 04             	lea    0x4(%eax),%edx
  801665:	89 55 14             	mov    %edx,0x14(%ebp)
  801668:	8b 00                	mov    (%eax),%eax
  80166a:	89 c2                	mov    %eax,%edx
  80166c:	c1 fa 1f             	sar    $0x1f,%edx
  80166f:	31 d0                	xor    %edx,%eax
  801671:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801673:	83 f8 0f             	cmp    $0xf,%eax
  801676:	7f 0b                	jg     801683 <vprintfmt+0x156>
  801678:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80167f:	85 d2                	test   %edx,%edx
  801681:	75 20                	jne    8016a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  801683:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801687:	c7 44 24 08 10 24 80 	movl   $0x802410,0x8(%esp)
  80168e:	00 
  80168f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801693:	89 3c 24             	mov    %edi,(%esp)
  801696:	e8 a5 03 00 00       	call   801a40 <printfmt>
  80169b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80169e:	e9 b6 fe ff ff       	jmp    801559 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8016a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016a7:	c7 44 24 08 93 23 80 	movl   $0x802393,0x8(%esp)
  8016ae:	00 
  8016af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b3:	89 3c 24             	mov    %edi,(%esp)
  8016b6:	e8 85 03 00 00       	call   801a40 <printfmt>
  8016bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016be:	e9 96 fe ff ff       	jmp    801559 <vprintfmt+0x2c>
  8016c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016c6:	89 c3                	mov    %eax,%ebx
  8016c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8016cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8016d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016d4:	8d 50 04             	lea    0x4(%eax),%edx
  8016d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8016da:	8b 00                	mov    (%eax),%eax
  8016dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016df:	85 c0                	test   %eax,%eax
  8016e1:	b8 19 24 80 00       	mov    $0x802419,%eax
  8016e6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8016ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8016ed:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8016f1:	7e 06                	jle    8016f9 <vprintfmt+0x1cc>
  8016f3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8016f7:	75 13                	jne    80170c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8016f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016fc:	0f be 02             	movsbl (%edx),%eax
  8016ff:	85 c0                	test   %eax,%eax
  801701:	0f 85 a2 00 00 00    	jne    8017a9 <vprintfmt+0x27c>
  801707:	e9 8f 00 00 00       	jmp    80179b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80170c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801710:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801713:	89 0c 24             	mov    %ecx,(%esp)
  801716:	e8 70 03 00 00       	call   801a8b <strnlen>
  80171b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80171e:	29 c2                	sub    %eax,%edx
  801720:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801723:	85 d2                	test   %edx,%edx
  801725:	7e d2                	jle    8016f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  801727:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80172b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80172e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  801731:	89 d3                	mov    %edx,%ebx
  801733:	89 74 24 04          	mov    %esi,0x4(%esp)
  801737:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80173a:	89 04 24             	mov    %eax,(%esp)
  80173d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80173f:	83 eb 01             	sub    $0x1,%ebx
  801742:	85 db                	test   %ebx,%ebx
  801744:	7f ed                	jg     801733 <vprintfmt+0x206>
  801746:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801749:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801750:	eb a7                	jmp    8016f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801752:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801756:	74 1b                	je     801773 <vprintfmt+0x246>
  801758:	8d 50 e0             	lea    -0x20(%eax),%edx
  80175b:	83 fa 5e             	cmp    $0x5e,%edx
  80175e:	76 13                	jbe    801773 <vprintfmt+0x246>
					putch('?', putdat);
  801760:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801763:	89 54 24 04          	mov    %edx,0x4(%esp)
  801767:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80176e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801771:	eb 0d                	jmp    801780 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801773:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801776:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80177a:	89 04 24             	mov    %eax,(%esp)
  80177d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801780:	83 ef 01             	sub    $0x1,%edi
  801783:	0f be 03             	movsbl (%ebx),%eax
  801786:	85 c0                	test   %eax,%eax
  801788:	74 05                	je     80178f <vprintfmt+0x262>
  80178a:	83 c3 01             	add    $0x1,%ebx
  80178d:	eb 31                	jmp    8017c0 <vprintfmt+0x293>
  80178f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801792:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801795:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801798:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80179b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80179f:	7f 36                	jg     8017d7 <vprintfmt+0x2aa>
  8017a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8017a4:	e9 b0 fd ff ff       	jmp    801559 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017ac:	83 c2 01             	add    $0x1,%edx
  8017af:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8017b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8017b8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8017bb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8017be:	89 d3                	mov    %edx,%ebx
  8017c0:	85 f6                	test   %esi,%esi
  8017c2:	78 8e                	js     801752 <vprintfmt+0x225>
  8017c4:	83 ee 01             	sub    $0x1,%esi
  8017c7:	79 89                	jns    801752 <vprintfmt+0x225>
  8017c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017d2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8017d5:	eb c4                	jmp    80179b <vprintfmt+0x26e>
  8017d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8017da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017e1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8017e8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017ea:	83 eb 01             	sub    $0x1,%ebx
  8017ed:	85 db                	test   %ebx,%ebx
  8017ef:	7f ec                	jg     8017dd <vprintfmt+0x2b0>
  8017f1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8017f4:	e9 60 fd ff ff       	jmp    801559 <vprintfmt+0x2c>
  8017f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8017fc:	83 f9 01             	cmp    $0x1,%ecx
  8017ff:	7e 16                	jle    801817 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  801801:	8b 45 14             	mov    0x14(%ebp),%eax
  801804:	8d 50 08             	lea    0x8(%eax),%edx
  801807:	89 55 14             	mov    %edx,0x14(%ebp)
  80180a:	8b 10                	mov    (%eax),%edx
  80180c:	8b 48 04             	mov    0x4(%eax),%ecx
  80180f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801812:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801815:	eb 32                	jmp    801849 <vprintfmt+0x31c>
	else if (lflag)
  801817:	85 c9                	test   %ecx,%ecx
  801819:	74 18                	je     801833 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80181b:	8b 45 14             	mov    0x14(%ebp),%eax
  80181e:	8d 50 04             	lea    0x4(%eax),%edx
  801821:	89 55 14             	mov    %edx,0x14(%ebp)
  801824:	8b 00                	mov    (%eax),%eax
  801826:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801829:	89 c1                	mov    %eax,%ecx
  80182b:	c1 f9 1f             	sar    $0x1f,%ecx
  80182e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801831:	eb 16                	jmp    801849 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  801833:	8b 45 14             	mov    0x14(%ebp),%eax
  801836:	8d 50 04             	lea    0x4(%eax),%edx
  801839:	89 55 14             	mov    %edx,0x14(%ebp)
  80183c:	8b 00                	mov    (%eax),%eax
  80183e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801841:	89 c2                	mov    %eax,%edx
  801843:	c1 fa 1f             	sar    $0x1f,%edx
  801846:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801849:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80184c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80184f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  801854:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801858:	0f 89 8a 00 00 00    	jns    8018e8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80185e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801862:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801869:	ff d7                	call   *%edi
				num = -(long long) num;
  80186b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80186e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801871:	f7 d8                	neg    %eax
  801873:	83 d2 00             	adc    $0x0,%edx
  801876:	f7 da                	neg    %edx
  801878:	eb 6e                	jmp    8018e8 <vprintfmt+0x3bb>
  80187a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80187d:	89 ca                	mov    %ecx,%edx
  80187f:	8d 45 14             	lea    0x14(%ebp),%eax
  801882:	e8 4f fc ff ff       	call   8014d6 <getuint>
  801887:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80188c:	eb 5a                	jmp    8018e8 <vprintfmt+0x3bb>
  80188e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801891:	89 ca                	mov    %ecx,%edx
  801893:	8d 45 14             	lea    0x14(%ebp),%eax
  801896:	e8 3b fc ff ff       	call   8014d6 <getuint>
  80189b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8018a0:	eb 46                	jmp    8018e8 <vprintfmt+0x3bb>
  8018a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8018a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8018b0:	ff d7                	call   *%edi
			putch('x', putdat);
  8018b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018b6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8018bd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8018bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c2:	8d 50 04             	lea    0x4(%eax),%edx
  8018c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c8:	8b 00                	mov    (%eax),%eax
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018d4:	eb 12                	jmp    8018e8 <vprintfmt+0x3bb>
  8018d6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018d9:	89 ca                	mov    %ecx,%edx
  8018db:	8d 45 14             	lea    0x14(%ebp),%eax
  8018de:	e8 f3 fb ff ff       	call   8014d6 <getuint>
  8018e3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018e8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8018ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8018f3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8018f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018fb:	89 04 24             	mov    %eax,(%esp)
  8018fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801902:	89 f2                	mov    %esi,%edx
  801904:	89 f8                	mov    %edi,%eax
  801906:	e8 d5 fa ff ff       	call   8013e0 <printnum>
  80190b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80190e:	e9 46 fc ff ff       	jmp    801559 <vprintfmt+0x2c>
  801913:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  801916:	8b 45 14             	mov    0x14(%ebp),%eax
  801919:	8d 50 04             	lea    0x4(%eax),%edx
  80191c:	89 55 14             	mov    %edx,0x14(%ebp)
  80191f:	8b 00                	mov    (%eax),%eax
  801921:	85 c0                	test   %eax,%eax
  801923:	75 24                	jne    801949 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  801925:	c7 44 24 0c 34 25 80 	movl   $0x802534,0xc(%esp)
  80192c:	00 
  80192d:	c7 44 24 08 93 23 80 	movl   $0x802393,0x8(%esp)
  801934:	00 
  801935:	89 74 24 04          	mov    %esi,0x4(%esp)
  801939:	89 3c 24             	mov    %edi,(%esp)
  80193c:	e8 ff 00 00 00       	call   801a40 <printfmt>
  801941:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801944:	e9 10 fc ff ff       	jmp    801559 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  801949:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80194c:	7e 29                	jle    801977 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80194e:	0f b6 16             	movzbl (%esi),%edx
  801951:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  801953:	c7 44 24 0c 6c 25 80 	movl   $0x80256c,0xc(%esp)
  80195a:	00 
  80195b:	c7 44 24 08 93 23 80 	movl   $0x802393,0x8(%esp)
  801962:	00 
  801963:	89 74 24 04          	mov    %esi,0x4(%esp)
  801967:	89 3c 24             	mov    %edi,(%esp)
  80196a:	e8 d1 00 00 00       	call   801a40 <printfmt>
  80196f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801972:	e9 e2 fb ff ff       	jmp    801559 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  801977:	0f b6 16             	movzbl (%esi),%edx
  80197a:	88 10                	mov    %dl,(%eax)
  80197c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80197f:	e9 d5 fb ff ff       	jmp    801559 <vprintfmt+0x2c>
  801984:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801987:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80198a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198e:	89 14 24             	mov    %edx,(%esp)
  801991:	ff d7                	call   *%edi
  801993:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801996:	e9 be fb ff ff       	jmp    801559 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80199b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80199f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8019a6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8019ab:	80 38 25             	cmpb   $0x25,(%eax)
  8019ae:	0f 84 a5 fb ff ff    	je     801559 <vprintfmt+0x2c>
  8019b4:	89 c3                	mov    %eax,%ebx
  8019b6:	eb f0                	jmp    8019a8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8019b8:	83 c4 5c             	add    $0x5c,%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5f                   	pop    %edi
  8019be:	5d                   	pop    %ebp
  8019bf:	c3                   	ret    

008019c0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 28             	sub    $0x28,%esp
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	74 04                	je     8019d4 <vsnprintf+0x14>
  8019d0:	85 d2                	test   %edx,%edx
  8019d2:	7f 07                	jg     8019db <vsnprintf+0x1b>
  8019d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019d9:	eb 3b                	jmp    801a16 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019de:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8019e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8019e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019fa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a01:	c7 04 24 10 15 80 00 	movl   $0x801510,(%esp)
  801a08:	e8 20 fb ff ff       	call   80152d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a10:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801a1e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801a21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a25:	8b 45 10             	mov    0x10(%ebp),%eax
  801a28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a33:	8b 45 08             	mov    0x8(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 82 ff ff ff       	call   8019c0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801a46:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801a49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a4d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a50:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a57:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	89 04 24             	mov    %eax,(%esp)
  801a61:	e8 c7 fa ff ff       	call   80152d <vprintfmt>
	va_end(ap);
}
  801a66:	c9                   	leave  
  801a67:	c3                   	ret    
	...

00801a70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a76:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7b:	80 3a 00             	cmpb   $0x0,(%edx)
  801a7e:	74 09                	je     801a89 <strlen+0x19>
		n++;
  801a80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a87:	75 f7                	jne    801a80 <strlen+0x10>
		n++;
	return n;
}
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a8b:	55                   	push   %ebp
  801a8c:	89 e5                	mov    %esp,%ebp
  801a8e:	53                   	push   %ebx
  801a8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a95:	85 c9                	test   %ecx,%ecx
  801a97:	74 19                	je     801ab2 <strnlen+0x27>
  801a99:	80 3b 00             	cmpb   $0x0,(%ebx)
  801a9c:	74 14                	je     801ab2 <strnlen+0x27>
  801a9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801aa3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801aa6:	39 c8                	cmp    %ecx,%eax
  801aa8:	74 0d                	je     801ab7 <strnlen+0x2c>
  801aaa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801aae:	75 f3                	jne    801aa3 <strnlen+0x18>
  801ab0:	eb 05                	jmp    801ab7 <strnlen+0x2c>
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801ab7:	5b                   	pop    %ebx
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	53                   	push   %ebx
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ac9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801acd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801ad0:	83 c2 01             	add    $0x1,%edx
  801ad3:	84 c9                	test   %cl,%cl
  801ad5:	75 f2                	jne    801ac9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801ad7:	5b                   	pop    %ebx
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	83 ec 08             	sub    $0x8,%esp
  801ae1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ae4:	89 1c 24             	mov    %ebx,(%esp)
  801ae7:	e8 84 ff ff ff       	call   801a70 <strlen>
	strcpy(dst + len, src);
  801aec:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aef:	89 54 24 04          	mov    %edx,0x4(%esp)
  801af3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801af6:	89 04 24             	mov    %eax,(%esp)
  801af9:	e8 bc ff ff ff       	call   801aba <strcpy>
	return dst;
}
  801afe:	89 d8                	mov    %ebx,%eax
  801b00:	83 c4 08             	add    $0x8,%esp
  801b03:	5b                   	pop    %ebx
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b14:	85 f6                	test   %esi,%esi
  801b16:	74 18                	je     801b30 <strncpy+0x2a>
  801b18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b1d:	0f b6 1a             	movzbl (%edx),%ebx
  801b20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b23:	80 3a 01             	cmpb   $0x1,(%edx)
  801b26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b29:	83 c1 01             	add    $0x1,%ecx
  801b2c:	39 ce                	cmp    %ecx,%esi
  801b2e:	77 ed                	ja     801b1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	56                   	push   %esi
  801b38:	53                   	push   %ebx
  801b39:	8b 75 08             	mov    0x8(%ebp),%esi
  801b3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b42:	89 f0                	mov    %esi,%eax
  801b44:	85 c9                	test   %ecx,%ecx
  801b46:	74 27                	je     801b6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801b48:	83 e9 01             	sub    $0x1,%ecx
  801b4b:	74 1d                	je     801b6a <strlcpy+0x36>
  801b4d:	0f b6 1a             	movzbl (%edx),%ebx
  801b50:	84 db                	test   %bl,%bl
  801b52:	74 16                	je     801b6a <strlcpy+0x36>
			*dst++ = *src++;
  801b54:	88 18                	mov    %bl,(%eax)
  801b56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b59:	83 e9 01             	sub    $0x1,%ecx
  801b5c:	74 0e                	je     801b6c <strlcpy+0x38>
			*dst++ = *src++;
  801b5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b61:	0f b6 1a             	movzbl (%edx),%ebx
  801b64:	84 db                	test   %bl,%bl
  801b66:	75 ec                	jne    801b54 <strlcpy+0x20>
  801b68:	eb 02                	jmp    801b6c <strlcpy+0x38>
  801b6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801b6c:	c6 00 00             	movb   $0x0,(%eax)
  801b6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801b71:	5b                   	pop    %ebx
  801b72:	5e                   	pop    %esi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    

00801b75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b7e:	0f b6 01             	movzbl (%ecx),%eax
  801b81:	84 c0                	test   %al,%al
  801b83:	74 15                	je     801b9a <strcmp+0x25>
  801b85:	3a 02                	cmp    (%edx),%al
  801b87:	75 11                	jne    801b9a <strcmp+0x25>
		p++, q++;
  801b89:	83 c1 01             	add    $0x1,%ecx
  801b8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b8f:	0f b6 01             	movzbl (%ecx),%eax
  801b92:	84 c0                	test   %al,%al
  801b94:	74 04                	je     801b9a <strcmp+0x25>
  801b96:	3a 02                	cmp    (%edx),%al
  801b98:	74 ef                	je     801b89 <strcmp+0x14>
  801b9a:	0f b6 c0             	movzbl %al,%eax
  801b9d:	0f b6 12             	movzbl (%edx),%edx
  801ba0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ba2:	5d                   	pop    %ebp
  801ba3:	c3                   	ret    

00801ba4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801ba4:	55                   	push   %ebp
  801ba5:	89 e5                	mov    %esp,%ebp
  801ba7:	53                   	push   %ebx
  801ba8:	8b 55 08             	mov    0x8(%ebp),%edx
  801bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	74 23                	je     801bd8 <strncmp+0x34>
  801bb5:	0f b6 1a             	movzbl (%edx),%ebx
  801bb8:	84 db                	test   %bl,%bl
  801bba:	74 25                	je     801be1 <strncmp+0x3d>
  801bbc:	3a 19                	cmp    (%ecx),%bl
  801bbe:	75 21                	jne    801be1 <strncmp+0x3d>
  801bc0:	83 e8 01             	sub    $0x1,%eax
  801bc3:	74 13                	je     801bd8 <strncmp+0x34>
		n--, p++, q++;
  801bc5:	83 c2 01             	add    $0x1,%edx
  801bc8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bcb:	0f b6 1a             	movzbl (%edx),%ebx
  801bce:	84 db                	test   %bl,%bl
  801bd0:	74 0f                	je     801be1 <strncmp+0x3d>
  801bd2:	3a 19                	cmp    (%ecx),%bl
  801bd4:	74 ea                	je     801bc0 <strncmp+0x1c>
  801bd6:	eb 09                	jmp    801be1 <strncmp+0x3d>
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801bdd:	5b                   	pop    %ebx
  801bde:	5d                   	pop    %ebp
  801bdf:	90                   	nop
  801be0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801be1:	0f b6 02             	movzbl (%edx),%eax
  801be4:	0f b6 11             	movzbl (%ecx),%edx
  801be7:	29 d0                	sub    %edx,%eax
  801be9:	eb f2                	jmp    801bdd <strncmp+0x39>

00801beb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801bf5:	0f b6 10             	movzbl (%eax),%edx
  801bf8:	84 d2                	test   %dl,%dl
  801bfa:	74 18                	je     801c14 <strchr+0x29>
		if (*s == c)
  801bfc:	38 ca                	cmp    %cl,%dl
  801bfe:	75 0a                	jne    801c0a <strchr+0x1f>
  801c00:	eb 17                	jmp    801c19 <strchr+0x2e>
  801c02:	38 ca                	cmp    %cl,%dl
  801c04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c08:	74 0f                	je     801c19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c0a:	83 c0 01             	add    $0x1,%eax
  801c0d:	0f b6 10             	movzbl (%eax),%edx
  801c10:	84 d2                	test   %dl,%dl
  801c12:	75 ee                	jne    801c02 <strchr+0x17>
  801c14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c25:	0f b6 10             	movzbl (%eax),%edx
  801c28:	84 d2                	test   %dl,%dl
  801c2a:	74 18                	je     801c44 <strfind+0x29>
		if (*s == c)
  801c2c:	38 ca                	cmp    %cl,%dl
  801c2e:	75 0a                	jne    801c3a <strfind+0x1f>
  801c30:	eb 12                	jmp    801c44 <strfind+0x29>
  801c32:	38 ca                	cmp    %cl,%dl
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	74 0a                	je     801c44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801c3a:	83 c0 01             	add    $0x1,%eax
  801c3d:	0f b6 10             	movzbl (%eax),%edx
  801c40:	84 d2                	test   %dl,%dl
  801c42:	75 ee                	jne    801c32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	83 ec 0c             	sub    $0xc,%esp
  801c4c:	89 1c 24             	mov    %ebx,(%esp)
  801c4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801c57:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c60:	85 c9                	test   %ecx,%ecx
  801c62:	74 30                	je     801c94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c6a:	75 25                	jne    801c91 <memset+0x4b>
  801c6c:	f6 c1 03             	test   $0x3,%cl
  801c6f:	75 20                	jne    801c91 <memset+0x4b>
		c &= 0xFF;
  801c71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c74:	89 d3                	mov    %edx,%ebx
  801c76:	c1 e3 08             	shl    $0x8,%ebx
  801c79:	89 d6                	mov    %edx,%esi
  801c7b:	c1 e6 18             	shl    $0x18,%esi
  801c7e:	89 d0                	mov    %edx,%eax
  801c80:	c1 e0 10             	shl    $0x10,%eax
  801c83:	09 f0                	or     %esi,%eax
  801c85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801c87:	09 d8                	or     %ebx,%eax
  801c89:	c1 e9 02             	shr    $0x2,%ecx
  801c8c:	fc                   	cld    
  801c8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c8f:	eb 03                	jmp    801c94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c91:	fc                   	cld    
  801c92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c94:	89 f8                	mov    %edi,%eax
  801c96:	8b 1c 24             	mov    (%esp),%ebx
  801c99:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801ca1:	89 ec                	mov    %ebp,%esp
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    

00801ca5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 08             	sub    $0x8,%esp
  801cab:	89 34 24             	mov    %esi,(%esp)
  801cae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801cb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801cbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801cbd:	39 c6                	cmp    %eax,%esi
  801cbf:	73 35                	jae    801cf6 <memmove+0x51>
  801cc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cc4:	39 d0                	cmp    %edx,%eax
  801cc6:	73 2e                	jae    801cf6 <memmove+0x51>
		s += n;
		d += n;
  801cc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cca:	f6 c2 03             	test   $0x3,%dl
  801ccd:	75 1b                	jne    801cea <memmove+0x45>
  801ccf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cd5:	75 13                	jne    801cea <memmove+0x45>
  801cd7:	f6 c1 03             	test   $0x3,%cl
  801cda:	75 0e                	jne    801cea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801cdc:	83 ef 04             	sub    $0x4,%edi
  801cdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  801ce2:	c1 e9 02             	shr    $0x2,%ecx
  801ce5:	fd                   	std    
  801ce6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ce8:	eb 09                	jmp    801cf3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801cea:	83 ef 01             	sub    $0x1,%edi
  801ced:	8d 72 ff             	lea    -0x1(%edx),%esi
  801cf0:	fd                   	std    
  801cf1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801cf3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801cf4:	eb 20                	jmp    801d16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cf6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cfc:	75 15                	jne    801d13 <memmove+0x6e>
  801cfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d04:	75 0d                	jne    801d13 <memmove+0x6e>
  801d06:	f6 c1 03             	test   $0x3,%cl
  801d09:	75 08                	jne    801d13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801d0b:	c1 e9 02             	shr    $0x2,%ecx
  801d0e:	fc                   	cld    
  801d0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d11:	eb 03                	jmp    801d16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d13:	fc                   	cld    
  801d14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d16:	8b 34 24             	mov    (%esp),%esi
  801d19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d1d:	89 ec                	mov    %ebp,%esp
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d27:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d35:	8b 45 08             	mov    0x8(%ebp),%eax
  801d38:	89 04 24             	mov    %eax,(%esp)
  801d3b:	e8 65 ff ff ff       	call   801ca5 <memmove>
}
  801d40:	c9                   	leave  
  801d41:	c3                   	ret    

00801d42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d42:	55                   	push   %ebp
  801d43:	89 e5                	mov    %esp,%ebp
  801d45:	57                   	push   %edi
  801d46:	56                   	push   %esi
  801d47:	53                   	push   %ebx
  801d48:	8b 75 08             	mov    0x8(%ebp),%esi
  801d4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d51:	85 c9                	test   %ecx,%ecx
  801d53:	74 36                	je     801d8b <memcmp+0x49>
		if (*s1 != *s2)
  801d55:	0f b6 06             	movzbl (%esi),%eax
  801d58:	0f b6 1f             	movzbl (%edi),%ebx
  801d5b:	38 d8                	cmp    %bl,%al
  801d5d:	74 20                	je     801d7f <memcmp+0x3d>
  801d5f:	eb 14                	jmp    801d75 <memcmp+0x33>
  801d61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801d66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801d6b:	83 c2 01             	add    $0x1,%edx
  801d6e:	83 e9 01             	sub    $0x1,%ecx
  801d71:	38 d8                	cmp    %bl,%al
  801d73:	74 12                	je     801d87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801d75:	0f b6 c0             	movzbl %al,%eax
  801d78:	0f b6 db             	movzbl %bl,%ebx
  801d7b:	29 d8                	sub    %ebx,%eax
  801d7d:	eb 11                	jmp    801d90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d7f:	83 e9 01             	sub    $0x1,%ecx
  801d82:	ba 00 00 00 00       	mov    $0x0,%edx
  801d87:	85 c9                	test   %ecx,%ecx
  801d89:	75 d6                	jne    801d61 <memcmp+0x1f>
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801d90:	5b                   	pop    %ebx
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    

00801d95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d95:	55                   	push   %ebp
  801d96:	89 e5                	mov    %esp,%ebp
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d9b:	89 c2                	mov    %eax,%edx
  801d9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801da0:	39 d0                	cmp    %edx,%eax
  801da2:	73 15                	jae    801db9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801da4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801da8:	38 08                	cmp    %cl,(%eax)
  801daa:	75 06                	jne    801db2 <memfind+0x1d>
  801dac:	eb 0b                	jmp    801db9 <memfind+0x24>
  801dae:	38 08                	cmp    %cl,(%eax)
  801db0:	74 07                	je     801db9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801db2:	83 c0 01             	add    $0x1,%eax
  801db5:	39 c2                	cmp    %eax,%edx
  801db7:	77 f5                	ja     801dae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	57                   	push   %edi
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	83 ec 04             	sub    $0x4,%esp
  801dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  801dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dca:	0f b6 02             	movzbl (%edx),%eax
  801dcd:	3c 20                	cmp    $0x20,%al
  801dcf:	74 04                	je     801dd5 <strtol+0x1a>
  801dd1:	3c 09                	cmp    $0x9,%al
  801dd3:	75 0e                	jne    801de3 <strtol+0x28>
		s++;
  801dd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd8:	0f b6 02             	movzbl (%edx),%eax
  801ddb:	3c 20                	cmp    $0x20,%al
  801ddd:	74 f6                	je     801dd5 <strtol+0x1a>
  801ddf:	3c 09                	cmp    $0x9,%al
  801de1:	74 f2                	je     801dd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801de3:	3c 2b                	cmp    $0x2b,%al
  801de5:	75 0c                	jne    801df3 <strtol+0x38>
		s++;
  801de7:	83 c2 01             	add    $0x1,%edx
  801dea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801df1:	eb 15                	jmp    801e08 <strtol+0x4d>
	else if (*s == '-')
  801df3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801dfa:	3c 2d                	cmp    $0x2d,%al
  801dfc:	75 0a                	jne    801e08 <strtol+0x4d>
		s++, neg = 1;
  801dfe:	83 c2 01             	add    $0x1,%edx
  801e01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e08:	85 db                	test   %ebx,%ebx
  801e0a:	0f 94 c0             	sete   %al
  801e0d:	74 05                	je     801e14 <strtol+0x59>
  801e0f:	83 fb 10             	cmp    $0x10,%ebx
  801e12:	75 18                	jne    801e2c <strtol+0x71>
  801e14:	80 3a 30             	cmpb   $0x30,(%edx)
  801e17:	75 13                	jne    801e2c <strtol+0x71>
  801e19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	75 0a                	jne    801e2c <strtol+0x71>
		s += 2, base = 16;
  801e22:	83 c2 02             	add    $0x2,%edx
  801e25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e2a:	eb 15                	jmp    801e41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e2c:	84 c0                	test   %al,%al
  801e2e:	66 90                	xchg   %ax,%ax
  801e30:	74 0f                	je     801e41 <strtol+0x86>
  801e32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801e37:	80 3a 30             	cmpb   $0x30,(%edx)
  801e3a:	75 05                	jne    801e41 <strtol+0x86>
		s++, base = 8;
  801e3c:	83 c2 01             	add    $0x1,%edx
  801e3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e41:	b8 00 00 00 00       	mov    $0x0,%eax
  801e46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e48:	0f b6 0a             	movzbl (%edx),%ecx
  801e4b:	89 cf                	mov    %ecx,%edi
  801e4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801e50:	80 fb 09             	cmp    $0x9,%bl
  801e53:	77 08                	ja     801e5d <strtol+0xa2>
			dig = *s - '0';
  801e55:	0f be c9             	movsbl %cl,%ecx
  801e58:	83 e9 30             	sub    $0x30,%ecx
  801e5b:	eb 1e                	jmp    801e7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801e5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801e60:	80 fb 19             	cmp    $0x19,%bl
  801e63:	77 08                	ja     801e6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801e65:	0f be c9             	movsbl %cl,%ecx
  801e68:	83 e9 57             	sub    $0x57,%ecx
  801e6b:	eb 0e                	jmp    801e7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801e6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801e70:	80 fb 19             	cmp    $0x19,%bl
  801e73:	77 15                	ja     801e8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801e75:	0f be c9             	movsbl %cl,%ecx
  801e78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801e7b:	39 f1                	cmp    %esi,%ecx
  801e7d:	7d 0b                	jge    801e8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801e7f:	83 c2 01             	add    $0x1,%edx
  801e82:	0f af c6             	imul   %esi,%eax
  801e85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801e88:	eb be                	jmp    801e48 <strtol+0x8d>
  801e8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801e8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e90:	74 05                	je     801e97 <strtol+0xdc>
		*endptr = (char *) s;
  801e92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801e97:	89 ca                	mov    %ecx,%edx
  801e99:	f7 da                	neg    %edx
  801e9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801e9f:	0f 45 c2             	cmovne %edx,%eax
}
  801ea2:	83 c4 04             	add    $0x4,%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5f                   	pop    %edi
  801ea8:	5d                   	pop    %ebp
  801ea9:	c3                   	ret    
  801eaa:	00 00                	add    %al,(%eax)
  801eac:	00 00                	add    %al,(%eax)
	...

00801eb0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801eb6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec1:	39 ca                	cmp    %ecx,%edx
  801ec3:	75 04                	jne    801ec9 <ipc_find_env+0x19>
  801ec5:	b0 00                	mov    $0x0,%al
  801ec7:	eb 0f                	jmp    801ed8 <ipc_find_env+0x28>
  801ec9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ecc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801ed2:	8b 12                	mov    (%edx),%edx
  801ed4:	39 ca                	cmp    %ecx,%edx
  801ed6:	75 0c                	jne    801ee4 <ipc_find_env+0x34>
			return envs[i].env_id;
  801ed8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801edb:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801ee0:	8b 00                	mov    (%eax),%eax
  801ee2:	eb 0e                	jmp    801ef2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee4:	83 c0 01             	add    $0x1,%eax
  801ee7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eec:	75 db                	jne    801ec9 <ipc_find_env+0x19>
  801eee:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801ef2:	5d                   	pop    %ebp
  801ef3:	c3                   	ret    

00801ef4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	57                   	push   %edi
  801ef8:	56                   	push   %esi
  801ef9:	53                   	push   %ebx
  801efa:	83 ec 1c             	sub    $0x1c,%esp
  801efd:	8b 75 08             	mov    0x8(%ebp),%esi
  801f00:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f06:	85 db                	test   %ebx,%ebx
  801f08:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f0d:	0f 44 d8             	cmove  %eax,%ebx
  801f10:	eb 25                	jmp    801f37 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801f12:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f15:	74 20                	je     801f37 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801f17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f1b:	c7 44 24 08 80 27 80 	movl   $0x802780,0x8(%esp)
  801f22:	00 
  801f23:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f2a:	00 
  801f2b:	c7 04 24 9e 27 80 00 	movl   $0x80279e,(%esp)
  801f32:	e8 8d f3 ff ff       	call   8012c4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f37:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f3e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f42:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f46:	89 34 24             	mov    %esi,(%esp)
  801f49:	e8 94 e2 ff ff       	call   8001e2 <sys_ipc_try_send>
  801f4e:	85 c0                	test   %eax,%eax
  801f50:	75 c0                	jne    801f12 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f52:	e8 11 e4 ff ff       	call   800368 <sys_yield>
}
  801f57:	83 c4 1c             	add    $0x1c,%esp
  801f5a:	5b                   	pop    %ebx
  801f5b:	5e                   	pop    %esi
  801f5c:	5f                   	pop    %edi
  801f5d:	5d                   	pop    %ebp
  801f5e:	c3                   	ret    

00801f5f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f5f:	55                   	push   %ebp
  801f60:	89 e5                	mov    %esp,%ebp
  801f62:	83 ec 28             	sub    $0x28,%esp
  801f65:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f68:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f6b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801f71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f74:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f77:	85 c0                	test   %eax,%eax
  801f79:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f7e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801f81:	89 04 24             	mov    %eax,(%esp)
  801f84:	e8 20 e2 ff ff       	call   8001a9 <sys_ipc_recv>
  801f89:	89 c3                	mov    %eax,%ebx
  801f8b:	85 c0                	test   %eax,%eax
  801f8d:	79 2a                	jns    801fb9 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801f8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f97:	c7 04 24 a8 27 80 00 	movl   $0x8027a8,(%esp)
  801f9e:	e8 da f3 ff ff       	call   80137d <cprintf>
		if(from_env_store != NULL)
  801fa3:	85 f6                	test   %esi,%esi
  801fa5:	74 06                	je     801fad <ipc_recv+0x4e>
			*from_env_store = 0;
  801fa7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fad:	85 ff                	test   %edi,%edi
  801faf:	74 2c                	je     801fdd <ipc_recv+0x7e>
			*perm_store = 0;
  801fb1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fb7:	eb 24                	jmp    801fdd <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801fb9:	85 f6                	test   %esi,%esi
  801fbb:	74 0a                	je     801fc7 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801fbd:	a1 08 40 80 00       	mov    0x804008,%eax
  801fc2:	8b 40 74             	mov    0x74(%eax),%eax
  801fc5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fc7:	85 ff                	test   %edi,%edi
  801fc9:	74 0a                	je     801fd5 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801fcb:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd0:	8b 40 78             	mov    0x78(%eax),%eax
  801fd3:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fd5:	a1 08 40 80 00       	mov    0x804008,%eax
  801fda:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801fdd:	89 d8                	mov    %ebx,%eax
  801fdf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fe2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fe5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fe8:	89 ec                	mov    %ebp,%esp
  801fea:	5d                   	pop    %ebp
  801feb:	c3                   	ret    

00801fec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fec:	55                   	push   %ebp
  801fed:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  801fef:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff2:	89 c2                	mov    %eax,%edx
  801ff4:	c1 ea 16             	shr    $0x16,%edx
  801ff7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ffe:	f6 c2 01             	test   $0x1,%dl
  802001:	74 20                	je     802023 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802003:	c1 e8 0c             	shr    $0xc,%eax
  802006:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80200d:	a8 01                	test   $0x1,%al
  80200f:	74 12                	je     802023 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802011:	c1 e8 0c             	shr    $0xc,%eax
  802014:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802019:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80201e:	0f b7 c0             	movzwl %ax,%eax
  802021:	eb 05                	jmp    802028 <pageref+0x3c>
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802028:	5d                   	pop    %ebp
  802029:	c3                   	ret    
  80202a:	00 00                	add    %al,(%eax)
  80202c:	00 00                	add    %al,(%eax)
	...

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	57                   	push   %edi
  802034:	56                   	push   %esi
  802035:	83 ec 10             	sub    $0x10,%esp
  802038:	8b 45 14             	mov    0x14(%ebp),%eax
  80203b:	8b 55 08             	mov    0x8(%ebp),%edx
  80203e:	8b 75 10             	mov    0x10(%ebp),%esi
  802041:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802044:	85 c0                	test   %eax,%eax
  802046:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802049:	75 35                	jne    802080 <__udivdi3+0x50>
  80204b:	39 fe                	cmp    %edi,%esi
  80204d:	77 61                	ja     8020b0 <__udivdi3+0x80>
  80204f:	85 f6                	test   %esi,%esi
  802051:	75 0b                	jne    80205e <__udivdi3+0x2e>
  802053:	b8 01 00 00 00       	mov    $0x1,%eax
  802058:	31 d2                	xor    %edx,%edx
  80205a:	f7 f6                	div    %esi
  80205c:	89 c6                	mov    %eax,%esi
  80205e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802061:	31 d2                	xor    %edx,%edx
  802063:	89 f8                	mov    %edi,%eax
  802065:	f7 f6                	div    %esi
  802067:	89 c7                	mov    %eax,%edi
  802069:	89 c8                	mov    %ecx,%eax
  80206b:	f7 f6                	div    %esi
  80206d:	89 c1                	mov    %eax,%ecx
  80206f:	89 fa                	mov    %edi,%edx
  802071:	89 c8                	mov    %ecx,%eax
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	5e                   	pop    %esi
  802077:	5f                   	pop    %edi
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
  80207a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802080:	39 f8                	cmp    %edi,%eax
  802082:	77 1c                	ja     8020a0 <__udivdi3+0x70>
  802084:	0f bd d0             	bsr    %eax,%edx
  802087:	83 f2 1f             	xor    $0x1f,%edx
  80208a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80208d:	75 39                	jne    8020c8 <__udivdi3+0x98>
  80208f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802092:	0f 86 a0 00 00 00    	jbe    802138 <__udivdi3+0x108>
  802098:	39 f8                	cmp    %edi,%eax
  80209a:	0f 82 98 00 00 00    	jb     802138 <__udivdi3+0x108>
  8020a0:	31 ff                	xor    %edi,%edi
  8020a2:	31 c9                	xor    %ecx,%ecx
  8020a4:	89 c8                	mov    %ecx,%eax
  8020a6:	89 fa                	mov    %edi,%edx
  8020a8:	83 c4 10             	add    $0x10,%esp
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    
  8020af:	90                   	nop
  8020b0:	89 d1                	mov    %edx,%ecx
  8020b2:	89 fa                	mov    %edi,%edx
  8020b4:	89 c8                	mov    %ecx,%eax
  8020b6:	31 ff                	xor    %edi,%edi
  8020b8:	f7 f6                	div    %esi
  8020ba:	89 c1                	mov    %eax,%ecx
  8020bc:	89 fa                	mov    %edi,%edx
  8020be:	89 c8                	mov    %ecx,%eax
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	5e                   	pop    %esi
  8020c4:	5f                   	pop    %edi
  8020c5:	5d                   	pop    %ebp
  8020c6:	c3                   	ret    
  8020c7:	90                   	nop
  8020c8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020cc:	89 f2                	mov    %esi,%edx
  8020ce:	d3 e0                	shl    %cl,%eax
  8020d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8020db:	89 c1                	mov    %eax,%ecx
  8020dd:	d3 ea                	shr    %cl,%edx
  8020df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020e3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8020e6:	d3 e6                	shl    %cl,%esi
  8020e8:	89 c1                	mov    %eax,%ecx
  8020ea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8020ed:	89 fe                	mov    %edi,%esi
  8020ef:	d3 ee                	shr    %cl,%esi
  8020f1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020fb:	d3 e7                	shl    %cl,%edi
  8020fd:	89 c1                	mov    %eax,%ecx
  8020ff:	d3 ea                	shr    %cl,%edx
  802101:	09 d7                	or     %edx,%edi
  802103:	89 f2                	mov    %esi,%edx
  802105:	89 f8                	mov    %edi,%eax
  802107:	f7 75 ec             	divl   -0x14(%ebp)
  80210a:	89 d6                	mov    %edx,%esi
  80210c:	89 c7                	mov    %eax,%edi
  80210e:	f7 65 e8             	mull   -0x18(%ebp)
  802111:	39 d6                	cmp    %edx,%esi
  802113:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802116:	72 30                	jb     802148 <__udivdi3+0x118>
  802118:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80211b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	39 c2                	cmp    %eax,%edx
  802123:	73 05                	jae    80212a <__udivdi3+0xfa>
  802125:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802128:	74 1e                	je     802148 <__udivdi3+0x118>
  80212a:	89 f9                	mov    %edi,%ecx
  80212c:	31 ff                	xor    %edi,%edi
  80212e:	e9 71 ff ff ff       	jmp    8020a4 <__udivdi3+0x74>
  802133:	90                   	nop
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80213f:	e9 60 ff ff ff       	jmp    8020a4 <__udivdi3+0x74>
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80214b:	31 ff                	xor    %edi,%edi
  80214d:	89 c8                	mov    %ecx,%eax
  80214f:	89 fa                	mov    %edi,%edx
  802151:	83 c4 10             	add    $0x10,%esp
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
	...

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	89 e5                	mov    %esp,%ebp
  802163:	57                   	push   %edi
  802164:	56                   	push   %esi
  802165:	83 ec 20             	sub    $0x20,%esp
  802168:	8b 55 14             	mov    0x14(%ebp),%edx
  80216b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80216e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802171:	8b 75 0c             	mov    0xc(%ebp),%esi
  802174:	85 d2                	test   %edx,%edx
  802176:	89 c8                	mov    %ecx,%eax
  802178:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80217b:	75 13                	jne    802190 <__umoddi3+0x30>
  80217d:	39 f7                	cmp    %esi,%edi
  80217f:	76 3f                	jbe    8021c0 <__umoddi3+0x60>
  802181:	89 f2                	mov    %esi,%edx
  802183:	f7 f7                	div    %edi
  802185:	89 d0                	mov    %edx,%eax
  802187:	31 d2                	xor    %edx,%edx
  802189:	83 c4 20             	add    $0x20,%esp
  80218c:	5e                   	pop    %esi
  80218d:	5f                   	pop    %edi
  80218e:	5d                   	pop    %ebp
  80218f:	c3                   	ret    
  802190:	39 f2                	cmp    %esi,%edx
  802192:	77 4c                	ja     8021e0 <__umoddi3+0x80>
  802194:	0f bd ca             	bsr    %edx,%ecx
  802197:	83 f1 1f             	xor    $0x1f,%ecx
  80219a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80219d:	75 51                	jne    8021f0 <__umoddi3+0x90>
  80219f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021a2:	0f 87 e0 00 00 00    	ja     802288 <__umoddi3+0x128>
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	29 f8                	sub    %edi,%eax
  8021ad:	19 d6                	sbb    %edx,%esi
  8021af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b5:	89 f2                	mov    %esi,%edx
  8021b7:	83 c4 20             	add    $0x20,%esp
  8021ba:	5e                   	pop    %esi
  8021bb:	5f                   	pop    %edi
  8021bc:	5d                   	pop    %ebp
  8021bd:	c3                   	ret    
  8021be:	66 90                	xchg   %ax,%ax
  8021c0:	85 ff                	test   %edi,%edi
  8021c2:	75 0b                	jne    8021cf <__umoddi3+0x6f>
  8021c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021c9:	31 d2                	xor    %edx,%edx
  8021cb:	f7 f7                	div    %edi
  8021cd:	89 c7                	mov    %eax,%edi
  8021cf:	89 f0                	mov    %esi,%eax
  8021d1:	31 d2                	xor    %edx,%edx
  8021d3:	f7 f7                	div    %edi
  8021d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d8:	f7 f7                	div    %edi
  8021da:	eb a9                	jmp    802185 <__umoddi3+0x25>
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 c8                	mov    %ecx,%eax
  8021e2:	89 f2                	mov    %esi,%edx
  8021e4:	83 c4 20             	add    $0x20,%esp
  8021e7:	5e                   	pop    %esi
  8021e8:	5f                   	pop    %edi
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    
  8021eb:	90                   	nop
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021f4:	d3 e2                	shl    %cl,%edx
  8021f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8021fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802201:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802204:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802208:	89 fa                	mov    %edi,%edx
  80220a:	d3 ea                	shr    %cl,%edx
  80220c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802210:	0b 55 f4             	or     -0xc(%ebp),%edx
  802213:	d3 e7                	shl    %cl,%edi
  802215:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802219:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80221c:	89 f2                	mov    %esi,%edx
  80221e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802221:	89 c7                	mov    %eax,%edi
  802223:	d3 ea                	shr    %cl,%edx
  802225:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802229:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80222c:	89 c2                	mov    %eax,%edx
  80222e:	d3 e6                	shl    %cl,%esi
  802230:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802234:	d3 ea                	shr    %cl,%edx
  802236:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80223a:	09 d6                	or     %edx,%esi
  80223c:	89 f0                	mov    %esi,%eax
  80223e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802241:	d3 e7                	shl    %cl,%edi
  802243:	89 f2                	mov    %esi,%edx
  802245:	f7 75 f4             	divl   -0xc(%ebp)
  802248:	89 d6                	mov    %edx,%esi
  80224a:	f7 65 e8             	mull   -0x18(%ebp)
  80224d:	39 d6                	cmp    %edx,%esi
  80224f:	72 2b                	jb     80227c <__umoddi3+0x11c>
  802251:	39 c7                	cmp    %eax,%edi
  802253:	72 23                	jb     802278 <__umoddi3+0x118>
  802255:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802259:	29 c7                	sub    %eax,%edi
  80225b:	19 d6                	sbb    %edx,%esi
  80225d:	89 f0                	mov    %esi,%eax
  80225f:	89 f2                	mov    %esi,%edx
  802261:	d3 ef                	shr    %cl,%edi
  802263:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802267:	d3 e0                	shl    %cl,%eax
  802269:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80226d:	09 f8                	or     %edi,%eax
  80226f:	d3 ea                	shr    %cl,%edx
  802271:	83 c4 20             	add    $0x20,%esp
  802274:	5e                   	pop    %esi
  802275:	5f                   	pop    %edi
  802276:	5d                   	pop    %ebp
  802277:	c3                   	ret    
  802278:	39 d6                	cmp    %edx,%esi
  80227a:	75 d9                	jne    802255 <__umoddi3+0xf5>
  80227c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80227f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802282:	eb d1                	jmp    802255 <__umoddi3+0xf5>
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	0f 82 18 ff ff ff    	jb     8021a8 <__umoddi3+0x48>
  802290:	e9 1d ff ff ff       	jmp    8021b2 <__umoddi3+0x52>
