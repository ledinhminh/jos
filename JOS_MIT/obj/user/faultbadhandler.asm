
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  80002c:	e8 47 00 00 00       	call   800078 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800041:	00 
  800042:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800049:	ee 
  80004a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800051:	e8 ff 02 00 00       	call   800355 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800056:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80005d:	de 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 d2 01 00 00       	call   80023c <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80006a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800071:	00 00 00 
}
  800074:	c9                   	leave  
  800075:	c3                   	ret    
	...

00800078 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
  80007e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800081:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800084:	8b 75 08             	mov    0x8(%ebp),%esi
  800087:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80008a:	e8 70 03 00 00       	call   8003ff <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	c1 e0 07             	shl    $0x7,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a1:	85 f6                	test   %esi,%esi
  8000a3:	7e 07                	jle    8000ac <libmain+0x34>
		binaryname = argv[0];
  8000a5:	8b 03                	mov    (%ebx),%eax
  8000a7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ac:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b0:	89 34 24             	mov    %esi,(%esp)
  8000b3:	e8 7c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000b8:	e8 0b 00 00 00       	call   8000c8 <exit>
}
  8000bd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000c3:	89 ec                	mov    %ebp,%esp
  8000c5:	5d                   	pop    %ebp
  8000c6:	c3                   	ret    
	...

008000c8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ce:	e8 06 09 00 00       	call   8009d9 <close_all>
	sys_env_destroy(0);
  8000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000da:	e8 5b 03 00 00       	call   80043a <sys_env_destroy>
}
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
  8000e1:	00 00                	add    %al,(%eax)
	...

008000e4 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 48             	sub    $0x48,%esp
  8000ea:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000ed:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000f0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000f3:	89 c6                	mov    %eax,%esi
  8000f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000f8:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800100:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800103:	51                   	push   %ecx
  800104:	52                   	push   %edx
  800105:	53                   	push   %ebx
  800106:	54                   	push   %esp
  800107:	55                   	push   %ebp
  800108:	56                   	push   %esi
  800109:	57                   	push   %edi
  80010a:	89 e5                	mov    %esp,%ebp
  80010c:	8d 35 14 01 80 00    	lea    0x800114,%esi
  800112:	0f 34                	sysenter 

00800114 <.after_sysenter_label>:
  800114:	5f                   	pop    %edi
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	5c                   	pop    %esp
  800118:	5b                   	pop    %ebx
  800119:	5a                   	pop    %edx
  80011a:	59                   	pop    %ecx
  80011b:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  80011d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800121:	74 28                	je     80014b <.after_sysenter_label+0x37>
  800123:	85 c0                	test   %eax,%eax
  800125:	7e 24                	jle    80014b <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800127:	89 44 24 10          	mov    %eax,0x10(%esp)
  80012b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80012f:	c7 44 24 08 ea 22 80 	movl   $0x8022ea,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 07 23 80 00 	movl   $0x802307,(%esp)
  800146:	e8 99 11 00 00       	call   8012e4 <_panic>

	return ret;
}
  80014b:	89 d0                	mov    %edx,%eax
  80014d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800150:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800153:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800156:	89 ec                	mov    %ebp,%esp
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800160:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800167:	00 
  800168:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80016f:	00 
  800170:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800177:	00 
  800178:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800181:	ba 00 00 00 00       	mov    $0x0,%edx
  800186:	b8 10 00 00 00       	mov    $0x10,%eax
  80018b:	e8 54 ff ff ff       	call   8000e4 <syscall>
}
  800190:	c9                   	leave  
  800191:	c3                   	ret    

00800192 <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800198:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80019f:	00 
  8001a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001af:	00 
  8001b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c1:	b8 0f 00 00 00       	mov    $0xf,%eax
  8001c6:	e8 19 ff ff ff       	call   8000e4 <syscall>
}
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8001cd:	55                   	push   %ebp
  8001ce:	89 e5                	mov    %esp,%ebp
  8001d0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8001d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001da:	00 
  8001db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e2:	00 
  8001e3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ea:	00 
  8001eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f5:	ba 01 00 00 00       	mov    $0x1,%edx
  8001fa:	b8 0e 00 00 00       	mov    $0xe,%eax
  8001ff:	e8 e0 fe ff ff       	call   8000e4 <syscall>
}
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80020c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800213:	00 
  800214:	8b 45 14             	mov    0x14(%ebp),%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	8b 45 10             	mov    0x10(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	8b 45 0c             	mov    0xc(%ebp),%eax
  800225:	89 04 24             	mov    %eax,(%esp)
  800228:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022b:	ba 00 00 00 00       	mov    $0x0,%edx
  800230:	b8 0d 00 00 00       	mov    $0xd,%eax
  800235:	e8 aa fe ff ff       	call   8000e4 <syscall>
}
  80023a:	c9                   	leave  
  80023b:	c3                   	ret    

0080023c <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800242:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800249:	00 
  80024a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800251:	00 
  800252:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800259:	00 
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800263:	ba 01 00 00 00       	mov    $0x1,%edx
  800268:	b8 0b 00 00 00       	mov    $0xb,%eax
  80026d:	e8 72 fe ff ff       	call   8000e4 <syscall>
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80027a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800281:	00 
  800282:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800289:	00 
  80028a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800291:	00 
  800292:	8b 45 0c             	mov    0xc(%ebp),%eax
  800295:	89 04 24             	mov    %eax,(%esp)
  800298:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029b:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a5:	e8 3a fe ff ff       	call   8000e4 <syscall>
}
  8002aa:	c9                   	leave  
  8002ab:	c3                   	ret    

008002ac <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8002b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b9:	00 
  8002ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002c1:	00 
  8002c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002c9:	00 
  8002ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cd:	89 04 24             	mov    %eax,(%esp)
  8002d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d3:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d8:	b8 09 00 00 00       	mov    $0x9,%eax
  8002dd:	e8 02 fe ff ff       	call   8000e4 <syscall>
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800310:	b8 07 00 00 00       	mov    $0x7,%eax
  800315:	e8 ca fd ff ff       	call   8000e4 <syscall>
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800322:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800329:	00 
  80032a:	8b 45 18             	mov    0x18(%ebp),%eax
  80032d:	0b 45 14             	or     0x14(%ebp),%eax
  800330:	89 44 24 08          	mov    %eax,0x8(%esp)
  800334:	8b 45 10             	mov    0x10(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033e:	89 04 24             	mov    %eax,(%esp)
  800341:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800344:	ba 01 00 00 00       	mov    $0x1,%edx
  800349:	b8 06 00 00 00       	mov    $0x6,%eax
  80034e:	e8 91 fd ff ff       	call   8000e4 <syscall>
}
  800353:	c9                   	leave  
  800354:	c3                   	ret    

00800355 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80035b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800362:	00 
  800363:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80036a:	00 
  80036b:	8b 45 10             	mov    0x10(%ebp),%eax
  80036e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	ba 01 00 00 00       	mov    $0x1,%edx
  800380:	b8 05 00 00 00       	mov    $0x5,%eax
  800385:	e8 5a fd ff ff       	call   8000e4 <syscall>
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800392:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800399:	00 
  80039a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003a9:	00 
  8003aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003c0:	e8 1f fd ff ff       	call   8000e4 <syscall>
}
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8003cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e4:	00 
  8003e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e8:	89 04 24             	mov    %eax,(%esp)
  8003eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8003f8:	e8 e7 fc ff ff       	call   8000e4 <syscall>
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800405:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040c:	00 
  80040d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800414:	00 
  800415:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80041c:	00 
  80041d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800424:	b9 00 00 00 00       	mov    $0x0,%ecx
  800429:	ba 00 00 00 00       	mov    $0x0,%edx
  80042e:	b8 02 00 00 00       	mov    $0x2,%eax
  800433:	e8 ac fc ff ff       	call   8000e4 <syscall>
}
  800438:	c9                   	leave  
  800439:	c3                   	ret    

0080043a <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800440:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800447:	00 
  800448:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80044f:	00 
  800450:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800457:	00 
  800458:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80045f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800462:	ba 01 00 00 00       	mov    $0x1,%edx
  800467:	b8 03 00 00 00       	mov    $0x3,%eax
  80046c:	e8 73 fc ff ff       	call   8000e4 <syscall>
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800479:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800480:	00 
  800481:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800488:	00 
  800489:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800490:	00 
  800491:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800498:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8004a7:	e8 38 fc ff ff       	call   8000e4 <syscall>
}
  8004ac:	c9                   	leave  
  8004ad:	c3                   	ret    

008004ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8004b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004bb:	00 
  8004bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004c3:	00 
  8004c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004cb:	00 
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cf:	89 04 24             	mov    %eax,(%esp)
  8004d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	e8 00 fc ff ff       	call   8000e4 <syscall>
}
  8004e4:	c9                   	leave  
  8004e5:	c3                   	ret    
	...

008004f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004fb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800506:	8b 45 08             	mov    0x8(%ebp),%eax
  800509:	89 04 24             	mov    %eax,(%esp)
  80050c:	e8 df ff ff ff       	call   8004f0 <fd2num>
  800511:	05 20 00 0d 00       	add    $0xd0020,%eax
  800516:	c1 e0 0c             	shl    $0xc,%eax
}
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80051b:	55                   	push   %ebp
  80051c:	89 e5                	mov    %esp,%ebp
  80051e:	57                   	push   %edi
  80051f:	56                   	push   %esi
  800520:	53                   	push   %ebx
  800521:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800524:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800529:	a8 01                	test   $0x1,%al
  80052b:	74 36                	je     800563 <fd_alloc+0x48>
  80052d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800532:	a8 01                	test   $0x1,%al
  800534:	74 2d                	je     800563 <fd_alloc+0x48>
  800536:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80053b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800540:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800545:	89 c3                	mov    %eax,%ebx
  800547:	89 c2                	mov    %eax,%edx
  800549:	c1 ea 16             	shr    $0x16,%edx
  80054c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80054f:	f6 c2 01             	test   $0x1,%dl
  800552:	74 14                	je     800568 <fd_alloc+0x4d>
  800554:	89 c2                	mov    %eax,%edx
  800556:	c1 ea 0c             	shr    $0xc,%edx
  800559:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80055c:	f6 c2 01             	test   $0x1,%dl
  80055f:	75 10                	jne    800571 <fd_alloc+0x56>
  800561:	eb 05                	jmp    800568 <fd_alloc+0x4d>
  800563:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800568:	89 1f                	mov    %ebx,(%edi)
  80056a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80056f:	eb 17                	jmp    800588 <fd_alloc+0x6d>
  800571:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800576:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80057b:	75 c8                	jne    800545 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80057d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800583:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800588:	5b                   	pop    %ebx
  800589:	5e                   	pop    %esi
  80058a:	5f                   	pop    %edi
  80058b:	5d                   	pop    %ebp
  80058c:	c3                   	ret    

0080058d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800590:	8b 45 08             	mov    0x8(%ebp),%eax
  800593:	83 f8 1f             	cmp    $0x1f,%eax
  800596:	77 36                	ja     8005ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800598:	05 00 00 0d 00       	add    $0xd0000,%eax
  80059d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8005a0:	89 c2                	mov    %eax,%edx
  8005a2:	c1 ea 16             	shr    $0x16,%edx
  8005a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005ac:	f6 c2 01             	test   $0x1,%dl
  8005af:	74 1d                	je     8005ce <fd_lookup+0x41>
  8005b1:	89 c2                	mov    %eax,%edx
  8005b3:	c1 ea 0c             	shr    $0xc,%edx
  8005b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005bd:	f6 c2 01             	test   $0x1,%dl
  8005c0:	74 0c                	je     8005ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c5:	89 02                	mov    %eax,(%edx)
  8005c7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8005cc:	eb 05                	jmp    8005d3 <fd_lookup+0x46>
  8005ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    

008005d5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8005d5:	55                   	push   %ebp
  8005d6:	89 e5                	mov    %esp,%ebp
  8005d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8005de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e5:	89 04 24             	mov    %eax,(%esp)
  8005e8:	e8 a0 ff ff ff       	call   80058d <fd_lookup>
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	78 0e                	js     8005ff <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8005f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005f7:	89 50 04             	mov    %edx,0x4(%eax)
  8005fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8005ff:	c9                   	leave  
  800600:	c3                   	ret    

00800601 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800601:	55                   	push   %ebp
  800602:	89 e5                	mov    %esp,%ebp
  800604:	56                   	push   %esi
  800605:	53                   	push   %ebx
  800606:	83 ec 10             	sub    $0x10,%esp
  800609:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80060c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80060f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800614:	b8 04 30 80 00       	mov    $0x803004,%eax
  800619:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80061f:	75 11                	jne    800632 <dev_lookup+0x31>
  800621:	eb 04                	jmp    800627 <dev_lookup+0x26>
  800623:	39 08                	cmp    %ecx,(%eax)
  800625:	75 10                	jne    800637 <dev_lookup+0x36>
			*dev = devtab[i];
  800627:	89 03                	mov    %eax,(%ebx)
  800629:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80062e:	66 90                	xchg   %ax,%ax
  800630:	eb 36                	jmp    800668 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800632:	be 94 23 80 00       	mov    $0x802394,%esi
  800637:	83 c2 01             	add    $0x1,%edx
  80063a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80063d:	85 c0                	test   %eax,%eax
  80063f:	75 e2                	jne    800623 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800641:	a1 08 40 80 00       	mov    0x804008,%eax
  800646:	8b 40 48             	mov    0x48(%eax),%eax
  800649:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80064d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800651:	c7 04 24 18 23 80 00 	movl   $0x802318,(%esp)
  800658:	e8 40 0d 00 00       	call   80139d <cprintf>
	*dev = 0;
  80065d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800663:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800668:	83 c4 10             	add    $0x10,%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	53                   	push   %ebx
  800673:	83 ec 24             	sub    $0x24,%esp
  800676:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800679:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	89 04 24             	mov    %eax,(%esp)
  800686:	e8 02 ff ff ff       	call   80058d <fd_lookup>
  80068b:	85 c0                	test   %eax,%eax
  80068d:	78 53                	js     8006e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800692:	89 44 24 04          	mov    %eax,0x4(%esp)
  800696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	89 04 24             	mov    %eax,(%esp)
  80069e:	e8 5e ff ff ff       	call   800601 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	78 3b                	js     8006e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8006a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006af:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8006b3:	74 2d                	je     8006e2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8006b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8006b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8006bf:	00 00 00 
	stat->st_isdir = 0;
  8006c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8006c9:	00 00 00 
	stat->st_dev = dev;
  8006cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8006d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006dc:	89 14 24             	mov    %edx,(%esp)
  8006df:	ff 50 14             	call   *0x14(%eax)
}
  8006e2:	83 c4 24             	add    $0x24,%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5d                   	pop    %ebp
  8006e7:	c3                   	ret    

008006e8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8006e8:	55                   	push   %ebp
  8006e9:	89 e5                	mov    %esp,%ebp
  8006eb:	53                   	push   %ebx
  8006ec:	83 ec 24             	sub    $0x24,%esp
  8006ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f9:	89 1c 24             	mov    %ebx,(%esp)
  8006fc:	e8 8c fe ff ff       	call   80058d <fd_lookup>
  800701:	85 c0                	test   %eax,%eax
  800703:	78 5f                	js     800764 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800705:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800708:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 04 24             	mov    %eax,(%esp)
  800714:	e8 e8 fe ff ff       	call   800601 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800719:	85 c0                	test   %eax,%eax
  80071b:	78 47                	js     800764 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80071d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800720:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800724:	75 23                	jne    800749 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800726:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80072b:	8b 40 48             	mov    0x48(%eax),%eax
  80072e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800732:	89 44 24 04          	mov    %eax,0x4(%esp)
  800736:	c7 04 24 38 23 80 00 	movl   $0x802338,(%esp)
  80073d:	e8 5b 0c 00 00       	call   80139d <cprintf>
  800742:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800747:	eb 1b                	jmp    800764 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800749:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074c:	8b 48 18             	mov    0x18(%eax),%ecx
  80074f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800754:	85 c9                	test   %ecx,%ecx
  800756:	74 0c                	je     800764 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800758:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075f:	89 14 24             	mov    %edx,(%esp)
  800762:	ff d1                	call   *%ecx
}
  800764:	83 c4 24             	add    $0x24,%esp
  800767:	5b                   	pop    %ebx
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	53                   	push   %ebx
  80076e:	83 ec 24             	sub    $0x24,%esp
  800771:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800777:	89 44 24 04          	mov    %eax,0x4(%esp)
  80077b:	89 1c 24             	mov    %ebx,(%esp)
  80077e:	e8 0a fe ff ff       	call   80058d <fd_lookup>
  800783:	85 c0                	test   %eax,%eax
  800785:	78 66                	js     8007ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800787:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800791:	8b 00                	mov    (%eax),%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	e8 66 fe ff ff       	call   800601 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079b:	85 c0                	test   %eax,%eax
  80079d:	78 4e                	js     8007ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80079f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8007a2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8007a6:	75 23                	jne    8007cb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007a8:	a1 08 40 80 00       	mov    0x804008,%eax
  8007ad:	8b 40 48             	mov    0x48(%eax),%eax
  8007b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	c7 04 24 59 23 80 00 	movl   $0x802359,(%esp)
  8007bf:	e8 d9 0b 00 00       	call   80139d <cprintf>
  8007c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8007c9:	eb 22                	jmp    8007ed <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ce:	8b 48 0c             	mov    0xc(%eax),%ecx
  8007d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007d6:	85 c9                	test   %ecx,%ecx
  8007d8:	74 13                	je     8007ed <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007da:	8b 45 10             	mov    0x10(%ebp),%eax
  8007dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e8:	89 14 24             	mov    %edx,(%esp)
  8007eb:	ff d1                	call   *%ecx
}
  8007ed:	83 c4 24             	add    $0x24,%esp
  8007f0:	5b                   	pop    %ebx
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	83 ec 24             	sub    $0x24,%esp
  8007fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800800:	89 44 24 04          	mov    %eax,0x4(%esp)
  800804:	89 1c 24             	mov    %ebx,(%esp)
  800807:	e8 81 fd ff ff       	call   80058d <fd_lookup>
  80080c:	85 c0                	test   %eax,%eax
  80080e:	78 6b                	js     80087b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	89 44 24 04          	mov    %eax,0x4(%esp)
  800817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081a:	8b 00                	mov    (%eax),%eax
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	e8 dd fd ff ff       	call   800601 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800824:	85 c0                	test   %eax,%eax
  800826:	78 53                	js     80087b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800828:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80082b:	8b 42 08             	mov    0x8(%edx),%eax
  80082e:	83 e0 03             	and    $0x3,%eax
  800831:	83 f8 01             	cmp    $0x1,%eax
  800834:	75 23                	jne    800859 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800836:	a1 08 40 80 00       	mov    0x804008,%eax
  80083b:	8b 40 48             	mov    0x48(%eax),%eax
  80083e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800842:	89 44 24 04          	mov    %eax,0x4(%esp)
  800846:	c7 04 24 76 23 80 00 	movl   $0x802376,(%esp)
  80084d:	e8 4b 0b 00 00       	call   80139d <cprintf>
  800852:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800857:	eb 22                	jmp    80087b <read+0x88>
	}
	if (!dev->dev_read)
  800859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085c:	8b 48 08             	mov    0x8(%eax),%ecx
  80085f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800864:	85 c9                	test   %ecx,%ecx
  800866:	74 13                	je     80087b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800868:	8b 45 10             	mov    0x10(%ebp),%eax
  80086b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800872:	89 44 24 04          	mov    %eax,0x4(%esp)
  800876:	89 14 24             	mov    %edx,(%esp)
  800879:	ff d1                	call   *%ecx
}
  80087b:	83 c4 24             	add    $0x24,%esp
  80087e:	5b                   	pop    %ebx
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	57                   	push   %edi
  800885:	56                   	push   %esi
  800886:	53                   	push   %ebx
  800887:	83 ec 1c             	sub    $0x1c,%esp
  80088a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80088d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800890:	ba 00 00 00 00       	mov    $0x0,%edx
  800895:	bb 00 00 00 00       	mov    $0x0,%ebx
  80089a:	b8 00 00 00 00       	mov    $0x0,%eax
  80089f:	85 f6                	test   %esi,%esi
  8008a1:	74 29                	je     8008cc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8008a3:	89 f0                	mov    %esi,%eax
  8008a5:	29 d0                	sub    %edx,%eax
  8008a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ab:	03 55 0c             	add    0xc(%ebp),%edx
  8008ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b2:	89 3c 24             	mov    %edi,(%esp)
  8008b5:	e8 39 ff ff ff       	call   8007f3 <read>
		if (m < 0)
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	78 0e                	js     8008cc <readn+0x4b>
			return m;
		if (m == 0)
  8008be:	85 c0                	test   %eax,%eax
  8008c0:	74 08                	je     8008ca <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008c2:	01 c3                	add    %eax,%ebx
  8008c4:	89 da                	mov    %ebx,%edx
  8008c6:	39 f3                	cmp    %esi,%ebx
  8008c8:	72 d9                	jb     8008a3 <readn+0x22>
  8008ca:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8008cc:	83 c4 1c             	add    $0x1c,%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 28             	sub    $0x28,%esp
  8008da:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8008dd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8008e0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008e3:	89 34 24             	mov    %esi,(%esp)
  8008e6:	e8 05 fc ff ff       	call   8004f0 <fd2num>
  8008eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	e8 93 fc ff ff       	call   80058d <fd_lookup>
  8008fa:	89 c3                	mov    %eax,%ebx
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	78 05                	js     800905 <fd_close+0x31>
  800900:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800903:	74 0e                	je     800913 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800905:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800909:	b8 00 00 00 00       	mov    $0x0,%eax
  80090e:	0f 44 d8             	cmove  %eax,%ebx
  800911:	eb 3d                	jmp    800950 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800913:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800916:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091a:	8b 06                	mov    (%esi),%eax
  80091c:	89 04 24             	mov    %eax,(%esp)
  80091f:	e8 dd fc ff ff       	call   800601 <dev_lookup>
  800924:	89 c3                	mov    %eax,%ebx
  800926:	85 c0                	test   %eax,%eax
  800928:	78 16                	js     800940 <fd_close+0x6c>
		if (dev->dev_close)
  80092a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80092d:	8b 40 10             	mov    0x10(%eax),%eax
  800930:	bb 00 00 00 00       	mov    $0x0,%ebx
  800935:	85 c0                	test   %eax,%eax
  800937:	74 07                	je     800940 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800939:	89 34 24             	mov    %esi,(%esp)
  80093c:	ff d0                	call   *%eax
  80093e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800940:	89 74 24 04          	mov    %esi,0x4(%esp)
  800944:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80094b:	e8 94 f9 ff ff       	call   8002e4 <sys_page_unmap>
	return r;
}
  800950:	89 d8                	mov    %ebx,%eax
  800952:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800955:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800958:	89 ec                	mov    %ebp,%esp
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800962:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	89 04 24             	mov    %eax,(%esp)
  80096f:	e8 19 fc ff ff       	call   80058d <fd_lookup>
  800974:	85 c0                	test   %eax,%eax
  800976:	78 13                	js     80098b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800978:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80097f:	00 
  800980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800983:	89 04 24             	mov    %eax,(%esp)
  800986:	e8 49 ff ff ff       	call   8008d4 <fd_close>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	83 ec 18             	sub    $0x18,%esp
  800993:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800996:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800999:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009a0:	00 
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a4:	89 04 24             	mov    %eax,(%esp)
  8009a7:	e8 78 03 00 00       	call   800d24 <open>
  8009ac:	89 c3                	mov    %eax,%ebx
  8009ae:	85 c0                	test   %eax,%eax
  8009b0:	78 1b                	js     8009cd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009b9:	89 1c 24             	mov    %ebx,(%esp)
  8009bc:	e8 ae fc ff ff       	call   80066f <fstat>
  8009c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8009c3:	89 1c 24             	mov    %ebx,(%esp)
  8009c6:	e8 91 ff ff ff       	call   80095c <close>
  8009cb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8009cd:	89 d8                	mov    %ebx,%eax
  8009cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8009d2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8009d5:	89 ec                	mov    %ebp,%esp
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	83 ec 14             	sub    $0x14,%esp
  8009e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8009e5:	89 1c 24             	mov    %ebx,(%esp)
  8009e8:	e8 6f ff ff ff       	call   80095c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009ed:	83 c3 01             	add    $0x1,%ebx
  8009f0:	83 fb 20             	cmp    $0x20,%ebx
  8009f3:	75 f0                	jne    8009e5 <close_all+0xc>
		close(i);
}
  8009f5:	83 c4 14             	add    $0x14,%esp
  8009f8:	5b                   	pop    %ebx
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 58             	sub    $0x58,%esp
  800a01:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a04:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a07:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a0a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a0d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 6e fb ff ff       	call   80058d <fd_lookup>
  800a1f:	89 c3                	mov    %eax,%ebx
  800a21:	85 c0                	test   %eax,%eax
  800a23:	0f 88 e0 00 00 00    	js     800b09 <dup+0x10e>
		return r;
	close(newfdnum);
  800a29:	89 3c 24             	mov    %edi,(%esp)
  800a2c:	e8 2b ff ff ff       	call   80095c <close>

	newfd = INDEX2FD(newfdnum);
  800a31:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a37:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a3a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a3d:	89 04 24             	mov    %eax,(%esp)
  800a40:	e8 bb fa ff ff       	call   800500 <fd2data>
  800a45:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a47:	89 34 24             	mov    %esi,(%esp)
  800a4a:	e8 b1 fa ff ff       	call   800500 <fd2data>
  800a4f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800a52:	89 da                	mov    %ebx,%edx
  800a54:	89 d8                	mov    %ebx,%eax
  800a56:	c1 e8 16             	shr    $0x16,%eax
  800a59:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a60:	a8 01                	test   $0x1,%al
  800a62:	74 43                	je     800aa7 <dup+0xac>
  800a64:	c1 ea 0c             	shr    $0xc,%edx
  800a67:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a6e:	a8 01                	test   $0x1,%al
  800a70:	74 35                	je     800aa7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a72:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a79:	25 07 0e 00 00       	and    $0xe07,%eax
  800a7e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a82:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a85:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a89:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a90:	00 
  800a91:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a9c:	e8 7b f8 ff ff       	call   80031c <sys_page_map>
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 3f                	js     800ae6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800aa7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aaa:	89 c2                	mov    %eax,%edx
  800aac:	c1 ea 0c             	shr    $0xc,%edx
  800aaf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ab6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800abc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ac0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ac4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800acb:	00 
  800acc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad7:	e8 40 f8 ff ff       	call   80031c <sys_page_map>
  800adc:	89 c3                	mov    %eax,%ebx
  800ade:	85 c0                	test   %eax,%eax
  800ae0:	78 04                	js     800ae6 <dup+0xeb>
  800ae2:	89 fb                	mov    %edi,%ebx
  800ae4:	eb 23                	jmp    800b09 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ae6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800af1:	e8 ee f7 ff ff       	call   8002e4 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800af6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800af9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800afd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b04:	e8 db f7 ff ff       	call   8002e4 <sys_page_unmap>
	return r;
}
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b0e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b11:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b14:	89 ec                	mov    %ebp,%esp
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 18             	sub    $0x18,%esp
  800b1e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b21:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b24:	89 c3                	mov    %eax,%ebx
  800b26:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b28:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b2f:	75 11                	jne    800b42 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b31:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b38:	e8 93 13 00 00       	call   801ed0 <ipc_find_env>
  800b3d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b42:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b49:	00 
  800b4a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b51:	00 
  800b52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b56:	a1 00 40 80 00       	mov    0x804000,%eax
  800b5b:	89 04 24             	mov    %eax,(%esp)
  800b5e:	e8 b6 13 00 00       	call   801f19 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b6a:	00 
  800b6b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b6f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b76:	e8 09 14 00 00       	call   801f84 <ipc_recv>
}
  800b7b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b7e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b81:	89 ec                	mov    %ebp,%esp
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8e:	8b 40 0c             	mov    0xc(%eax),%eax
  800b91:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b99:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba8:	e8 6b ff ff ff       	call   800b18 <fsipc>
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	8b 40 0c             	mov    0xc(%eax),%eax
  800bbb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bca:	e8 49 ff ff ff       	call   800b18 <fsipc>
}
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    

00800bd1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bd7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800be1:	e8 32 ff ff ff       	call   800b18 <fsipc>
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	53                   	push   %ebx
  800bec:	83 ec 14             	sub    $0x14,%esp
  800bef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf5:	8b 40 0c             	mov    0xc(%eax),%eax
  800bf8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800c02:	b8 05 00 00 00       	mov    $0x5,%eax
  800c07:	e8 0c ff ff ff       	call   800b18 <fsipc>
  800c0c:	85 c0                	test   %eax,%eax
  800c0e:	78 2b                	js     800c3b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c10:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c17:	00 
  800c18:	89 1c 24             	mov    %ebx,(%esp)
  800c1b:	e8 ba 0e 00 00       	call   801ada <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c20:	a1 80 50 80 00       	mov    0x805080,%eax
  800c25:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c2b:	a1 84 50 80 00       	mov    0x805084,%eax
  800c30:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800c36:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800c3b:	83 c4 14             	add    $0x14,%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	83 ec 18             	sub    $0x18,%esp
  800c47:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	8b 52 0c             	mov    0xc(%edx),%edx
  800c50:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800c56:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800c5b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800c60:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800c65:	0f 47 c2             	cmova  %edx,%eax
  800c68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c73:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800c7a:	e8 46 10 00 00       	call   801cc5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800c7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c84:	b8 04 00 00 00       	mov    $0x4,%eax
  800c89:	e8 8a fe ff ff       	call   800b18 <fsipc>
}
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	53                   	push   %ebx
  800c94:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c97:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9a:	8b 40 0c             	mov    0xc(%eax),%eax
  800c9d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800ca2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cb4:	e8 5f fe ff ff       	call   800b18 <fsipc>
  800cb9:	89 c3                	mov    %eax,%ebx
  800cbb:	85 c0                	test   %eax,%eax
  800cbd:	78 17                	js     800cd6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800cbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cc3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800cca:	00 
  800ccb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cce:	89 04 24             	mov    %eax,(%esp)
  800cd1:	e8 ef 0f 00 00       	call   801cc5 <memmove>
  return r;	
}
  800cd6:	89 d8                	mov    %ebx,%eax
  800cd8:	83 c4 14             	add    $0x14,%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 14             	sub    $0x14,%esp
  800ce5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800ce8:	89 1c 24             	mov    %ebx,(%esp)
  800ceb:	e8 a0 0d 00 00       	call   801a90 <strlen>
  800cf0:	89 c2                	mov    %eax,%edx
  800cf2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800cf7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800cfd:	7f 1f                	jg     800d1e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800cff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d03:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d0a:	e8 cb 0d 00 00       	call   801ada <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800d0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d14:	b8 07 00 00 00       	mov    $0x7,%eax
  800d19:	e8 fa fd ff ff       	call   800b18 <fsipc>
}
  800d1e:	83 c4 14             	add    $0x14,%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 28             	sub    $0x28,%esp
  800d2a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d2d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d30:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800d33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d36:	89 04 24             	mov    %eax,(%esp)
  800d39:	e8 dd f7 ff ff       	call   80051b <fd_alloc>
  800d3e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800d40:	85 c0                	test   %eax,%eax
  800d42:	0f 88 89 00 00 00    	js     800dd1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d48:	89 34 24             	mov    %esi,(%esp)
  800d4b:	e8 40 0d 00 00       	call   801a90 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800d50:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d55:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800d5a:	7f 75                	jg     800dd1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800d5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d60:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d67:	e8 6e 0d 00 00       	call   801ada <strcpy>
  fsipcbuf.open.req_omode = mode;
  800d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d77:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7c:	e8 97 fd ff ff       	call   800b18 <fsipc>
  800d81:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800d83:	85 c0                	test   %eax,%eax
  800d85:	78 0f                	js     800d96 <open+0x72>
  return fd2num(fd);
  800d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d8a:	89 04 24             	mov    %eax,(%esp)
  800d8d:	e8 5e f7 ff ff       	call   8004f0 <fd2num>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	eb 3b                	jmp    800dd1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800d96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d9d:	00 
  800d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800da1:	89 04 24             	mov    %eax,(%esp)
  800da4:	e8 2b fb ff ff       	call   8008d4 <fd_close>
  800da9:	85 c0                	test   %eax,%eax
  800dab:	74 24                	je     800dd1 <open+0xad>
  800dad:	c7 44 24 0c a0 23 80 	movl   $0x8023a0,0xc(%esp)
  800db4:	00 
  800db5:	c7 44 24 08 b5 23 80 	movl   $0x8023b5,0x8(%esp)
  800dbc:	00 
  800dbd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800dc4:	00 
  800dc5:	c7 04 24 ca 23 80 00 	movl   $0x8023ca,(%esp)
  800dcc:	e8 13 05 00 00       	call   8012e4 <_panic>
  return r;
}
  800dd1:	89 d8                	mov    %ebx,%eax
  800dd3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800dd6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800dd9:	89 ec                	mov    %ebp,%esp
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    
  800ddd:	00 00                	add    %al,(%eax)
	...

00800de0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800de6:	c7 44 24 04 d5 23 80 	movl   $0x8023d5,0x4(%esp)
  800ded:	00 
  800dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 e1 0c 00 00       	call   801ada <strcpy>
	return 0;
}
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	53                   	push   %ebx
  800e04:	83 ec 14             	sub    $0x14,%esp
  800e07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800e0a:	89 1c 24             	mov    %ebx,(%esp)
  800e0d:	e8 02 12 00 00       	call   802014 <pageref>
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	b8 00 00 00 00       	mov    $0x0,%eax
  800e19:	83 fa 01             	cmp    $0x1,%edx
  800e1c:	75 0b                	jne    800e29 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800e1e:	8b 43 0c             	mov    0xc(%ebx),%eax
  800e21:	89 04 24             	mov    %eax,(%esp)
  800e24:	e8 b9 02 00 00       	call   8010e2 <nsipc_close>
	else
		return 0;
}
  800e29:	83 c4 14             	add    $0x14,%esp
  800e2c:	5b                   	pop    %ebx
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800e35:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e3c:	00 
  800e3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e40:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e44:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e47:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	8b 40 0c             	mov    0xc(%eax),%eax
  800e51:	89 04 24             	mov    %eax,(%esp)
  800e54:	e8 c5 02 00 00       	call   80111e <nsipc_send>
}
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800e61:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e68:	00 
  800e69:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e7d:	89 04 24             	mov    %eax,(%esp)
  800e80:	e8 0c 03 00 00       	call   801191 <nsipc_recv>
}
  800e85:	c9                   	leave  
  800e86:	c3                   	ret    

00800e87 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800e87:	55                   	push   %ebp
  800e88:	89 e5                	mov    %esp,%ebp
  800e8a:	56                   	push   %esi
  800e8b:	53                   	push   %ebx
  800e8c:	83 ec 20             	sub    $0x20,%esp
  800e8f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e94:	89 04 24             	mov    %eax,(%esp)
  800e97:	e8 7f f6 ff ff       	call   80051b <fd_alloc>
  800e9c:	89 c3                	mov    %eax,%ebx
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	78 21                	js     800ec3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800ea2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800ea9:	00 
  800eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ead:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb8:	e8 98 f4 ff ff       	call   800355 <sys_page_alloc>
  800ebd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 0a                	jns    800ecd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  800ec3:	89 34 24             	mov    %esi,(%esp)
  800ec6:	e8 17 02 00 00       	call   8010e2 <nsipc_close>
		return r;
  800ecb:	eb 28                	jmp    800ef5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ecd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800edb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ee2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eeb:	89 04 24             	mov    %eax,(%esp)
  800eee:	e8 fd f5 ff ff       	call   8004f0 <fd2num>
  800ef3:	89 c3                	mov    %eax,%ebx
}
  800ef5:	89 d8                	mov    %ebx,%eax
  800ef7:	83 c4 20             	add    $0x20,%esp
  800efa:	5b                   	pop    %ebx
  800efb:	5e                   	pop    %esi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f04:	8b 45 10             	mov    0x10(%ebp),%eax
  800f07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f12:	8b 45 08             	mov    0x8(%ebp),%eax
  800f15:	89 04 24             	mov    %eax,(%esp)
  800f18:	e8 79 01 00 00       	call   801096 <nsipc_socket>
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	78 05                	js     800f26 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f21:	e8 61 ff ff ff       	call   800e87 <alloc_sockfd>
}
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f31:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f35:	89 04 24             	mov    %eax,(%esp)
  800f38:	e8 50 f6 ff ff       	call   80058d <fd_lookup>
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 15                	js     800f56 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f44:	8b 0a                	mov    (%edx),%ecx
  800f46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f4b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  800f51:	75 03                	jne    800f56 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f53:	8b 42 0c             	mov    0xc(%edx),%eax
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f61:	e8 c2 ff ff ff       	call   800f28 <fd2sockid>
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 0f                	js     800f79 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f71:	89 04 24             	mov    %eax,(%esp)
  800f74:	e8 47 01 00 00       	call   8010c0 <nsipc_listen>
}
  800f79:	c9                   	leave  
  800f7a:	c3                   	ret    

00800f7b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f81:	8b 45 08             	mov    0x8(%ebp),%eax
  800f84:	e8 9f ff ff ff       	call   800f28 <fd2sockid>
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	78 16                	js     800fa3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800f8d:	8b 55 10             	mov    0x10(%ebp),%edx
  800f90:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f97:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f9b:	89 04 24             	mov    %eax,(%esp)
  800f9e:	e8 6e 02 00 00       	call   801211 <nsipc_connect>
}
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fab:	8b 45 08             	mov    0x8(%ebp),%eax
  800fae:	e8 75 ff ff ff       	call   800f28 <fd2sockid>
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	78 0f                	js     800fc6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fba:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fbe:	89 04 24             	mov    %eax,(%esp)
  800fc1:	e8 36 01 00 00       	call   8010fc <nsipc_shutdown>
}
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    

00800fc8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fc8:	55                   	push   %ebp
  800fc9:	89 e5                	mov    %esp,%ebp
  800fcb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fce:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd1:	e8 52 ff ff ff       	call   800f28 <fd2sockid>
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 16                	js     800ff0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800fda:	8b 55 10             	mov    0x10(%ebp),%edx
  800fdd:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fe1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fe4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe8:	89 04 24             	mov    %eax,(%esp)
  800feb:	e8 60 02 00 00       	call   801250 <nsipc_bind>
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ff2:	55                   	push   %ebp
  800ff3:	89 e5                	mov    %esp,%ebp
  800ff5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ff8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffb:	e8 28 ff ff ff       	call   800f28 <fd2sockid>
  801000:	85 c0                	test   %eax,%eax
  801002:	78 1f                	js     801023 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801004:	8b 55 10             	mov    0x10(%ebp),%edx
  801007:	89 54 24 08          	mov    %edx,0x8(%esp)
  80100b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80100e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801012:	89 04 24             	mov    %eax,(%esp)
  801015:	e8 75 02 00 00       	call   80128f <nsipc_accept>
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 05                	js     801023 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80101e:	e8 64 fe ff ff       	call   800e87 <alloc_sockfd>
}
  801023:	c9                   	leave  
  801024:	c3                   	ret    
	...

00801030 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	53                   	push   %ebx
  801034:	83 ec 14             	sub    $0x14,%esp
  801037:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801039:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801040:	75 11                	jne    801053 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801042:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801049:	e8 82 0e 00 00       	call   801ed0 <ipc_find_env>
  80104e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801053:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80105a:	00 
  80105b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801062:	00 
  801063:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801067:	a1 04 40 80 00       	mov    0x804004,%eax
  80106c:	89 04 24             	mov    %eax,(%esp)
  80106f:	e8 a5 0e 00 00       	call   801f19 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801074:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107b:	00 
  80107c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801083:	00 
  801084:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108b:	e8 f4 0e 00 00       	call   801f84 <ipc_recv>
}
  801090:	83 c4 14             	add    $0x14,%esp
  801093:	5b                   	pop    %ebx
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80109c:	8b 45 08             	mov    0x8(%ebp),%eax
  80109f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8010a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8010af:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b9:	e8 72 ff ff ff       	call   801030 <nsipc>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8010db:	e8 50 ff ff ff       	call   801030 <nsipc>
}
  8010e0:	c9                   	leave  
  8010e1:	c3                   	ret    

008010e2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010eb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8010f0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010f5:	e8 36 ff ff ff       	call   801030 <nsipc>
}
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801102:	8b 45 08             	mov    0x8(%ebp),%eax
  801105:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80110a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801112:	b8 03 00 00 00       	mov    $0x3,%eax
  801117:	e8 14 ff ff ff       	call   801030 <nsipc>
}
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	53                   	push   %ebx
  801122:	83 ec 14             	sub    $0x14,%esp
  801125:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801128:	8b 45 08             	mov    0x8(%ebp),%eax
  80112b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801130:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801136:	7e 24                	jle    80115c <nsipc_send+0x3e>
  801138:	c7 44 24 0c e1 23 80 	movl   $0x8023e1,0xc(%esp)
  80113f:	00 
  801140:	c7 44 24 08 b5 23 80 	movl   $0x8023b5,0x8(%esp)
  801147:	00 
  801148:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80114f:	00 
  801150:	c7 04 24 ed 23 80 00 	movl   $0x8023ed,(%esp)
  801157:	e8 88 01 00 00       	call   8012e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80115c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801160:	8b 45 0c             	mov    0xc(%ebp),%eax
  801163:	89 44 24 04          	mov    %eax,0x4(%esp)
  801167:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80116e:	e8 52 0b 00 00       	call   801cc5 <memmove>
	nsipcbuf.send.req_size = size;
  801173:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801179:	8b 45 14             	mov    0x14(%ebp),%eax
  80117c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801181:	b8 08 00 00 00       	mov    $0x8,%eax
  801186:	e8 a5 fe ff ff       	call   801030 <nsipc>
}
  80118b:	83 c4 14             	add    $0x14,%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5d                   	pop    %ebp
  801190:	c3                   	ret    

00801191 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801191:	55                   	push   %ebp
  801192:	89 e5                	mov    %esp,%ebp
  801194:	56                   	push   %esi
  801195:	53                   	push   %ebx
  801196:	83 ec 10             	sub    $0x10,%esp
  801199:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80119c:	8b 45 08             	mov    0x8(%ebp),%eax
  80119f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8011a4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8011aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8011ad:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8011b2:	b8 07 00 00 00       	mov    $0x7,%eax
  8011b7:	e8 74 fe ff ff       	call   801030 <nsipc>
  8011bc:	89 c3                	mov    %eax,%ebx
  8011be:	85 c0                	test   %eax,%eax
  8011c0:	78 46                	js     801208 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8011c2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8011c7:	7f 04                	jg     8011cd <nsipc_recv+0x3c>
  8011c9:	39 c6                	cmp    %eax,%esi
  8011cb:	7d 24                	jge    8011f1 <nsipc_recv+0x60>
  8011cd:	c7 44 24 0c f9 23 80 	movl   $0x8023f9,0xc(%esp)
  8011d4:	00 
  8011d5:	c7 44 24 08 b5 23 80 	movl   $0x8023b5,0x8(%esp)
  8011dc:	00 
  8011dd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8011e4:	00 
  8011e5:	c7 04 24 ed 23 80 00 	movl   $0x8023ed,(%esp)
  8011ec:	e8 f3 00 00 00       	call   8012e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8011f1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8011fc:	00 
  8011fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801200:	89 04 24             	mov    %eax,(%esp)
  801203:	e8 bd 0a 00 00       	call   801cc5 <memmove>
	}

	return r;
}
  801208:	89 d8                	mov    %ebx,%eax
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	5b                   	pop    %ebx
  80120e:	5e                   	pop    %esi
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	53                   	push   %ebx
  801215:	83 ec 14             	sub    $0x14,%esp
  801218:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80121b:	8b 45 08             	mov    0x8(%ebp),%eax
  80121e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801223:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801227:	8b 45 0c             	mov    0xc(%ebp),%eax
  80122a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801235:	e8 8b 0a 00 00       	call   801cc5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80123a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801240:	b8 05 00 00 00       	mov    $0x5,%eax
  801245:	e8 e6 fd ff ff       	call   801030 <nsipc>
}
  80124a:	83 c4 14             	add    $0x14,%esp
  80124d:	5b                   	pop    %ebx
  80124e:	5d                   	pop    %ebp
  80124f:	c3                   	ret    

00801250 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	53                   	push   %ebx
  801254:	83 ec 14             	sub    $0x14,%esp
  801257:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
  80125d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801262:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801266:	8b 45 0c             	mov    0xc(%ebp),%eax
  801269:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801274:	e8 4c 0a 00 00       	call   801cc5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801279:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80127f:	b8 02 00 00 00       	mov    $0x2,%eax
  801284:	e8 a7 fd ff ff       	call   801030 <nsipc>
}
  801289:	83 c4 14             	add    $0x14,%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    

0080128f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
  801295:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801298:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80129b:	8b 45 08             	mov    0x8(%ebp),%eax
  80129e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8012a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a8:	e8 83 fd ff ff       	call   801030 <nsipc>
  8012ad:	89 c3                	mov    %eax,%ebx
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 25                	js     8012d8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8012b3:	be 10 60 80 00       	mov    $0x806010,%esi
  8012b8:	8b 06                	mov    (%esi),%eax
  8012ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012be:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8012c5:	00 
  8012c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012c9:	89 04 24             	mov    %eax,(%esp)
  8012cc:	e8 f4 09 00 00       	call   801cc5 <memmove>
		*addrlen = ret->ret_addrlen;
  8012d1:	8b 16                	mov    (%esi),%edx
  8012d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8012d6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8012d8:	89 d8                	mov    %ebx,%eax
  8012da:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012dd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8012e0:	89 ec                	mov    %ebp,%esp
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	56                   	push   %esi
  8012e8:	53                   	push   %ebx
  8012e9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8012ec:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012ef:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8012f5:	e8 05 f1 ff ff       	call   8003ff <sys_getenvid>
  8012fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fd:	89 54 24 10          	mov    %edx,0x10(%esp)
  801301:	8b 55 08             	mov    0x8(%ebp),%edx
  801304:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801308:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80130c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801310:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801317:	e8 81 00 00 00       	call   80139d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80131c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801320:	8b 45 10             	mov    0x10(%ebp),%eax
  801323:	89 04 24             	mov    %eax,(%esp)
  801326:	e8 11 00 00 00       	call   80133c <vcprintf>
	cprintf("\n");
  80132b:	c7 04 24 90 23 80 00 	movl   $0x802390,(%esp)
  801332:	e8 66 00 00 00       	call   80139d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801337:	cc                   	int3   
  801338:	eb fd                	jmp    801337 <_panic+0x53>
	...

0080133c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801345:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80134c:	00 00 00 
	b.cnt = 0;
  80134f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801356:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80135c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801360:	8b 45 08             	mov    0x8(%ebp),%eax
  801363:	89 44 24 08          	mov    %eax,0x8(%esp)
  801367:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	c7 04 24 b7 13 80 00 	movl   $0x8013b7,(%esp)
  801378:	e8 d0 01 00 00       	call   80154d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80137d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801383:	89 44 24 04          	mov    %eax,0x4(%esp)
  801387:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80138d:	89 04 24             	mov    %eax,(%esp)
  801390:	e8 19 f1 ff ff       	call   8004ae <sys_cputs>

	return b.cnt;
}
  801395:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8013a3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8013a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	e8 87 ff ff ff       	call   80133c <vcprintf>
	va_end(ap);

	return cnt;
}
  8013b5:	c9                   	leave  
  8013b6:	c3                   	ret    

008013b7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013b7:	55                   	push   %ebp
  8013b8:	89 e5                	mov    %esp,%ebp
  8013ba:	53                   	push   %ebx
  8013bb:	83 ec 14             	sub    $0x14,%esp
  8013be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013c1:	8b 03                	mov    (%ebx),%eax
  8013c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013c6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8013ca:	83 c0 01             	add    $0x1,%eax
  8013cd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8013cf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013d4:	75 19                	jne    8013ef <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8013d6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8013dd:	00 
  8013de:	8d 43 08             	lea    0x8(%ebx),%eax
  8013e1:	89 04 24             	mov    %eax,(%esp)
  8013e4:	e8 c5 f0 ff ff       	call   8004ae <sys_cputs>
		b->idx = 0;
  8013e9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8013ef:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013f3:	83 c4 14             	add    $0x14,%esp
  8013f6:	5b                   	pop    %ebx
  8013f7:	5d                   	pop    %ebp
  8013f8:	c3                   	ret    
  8013f9:	00 00                	add    %al,(%eax)
  8013fb:	00 00                	add    %al,(%eax)
  8013fd:	00 00                	add    %al,(%eax)
	...

00801400 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	57                   	push   %edi
  801404:	56                   	push   %esi
  801405:	53                   	push   %ebx
  801406:	83 ec 4c             	sub    $0x4c,%esp
  801409:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80140c:	89 d6                	mov    %edx,%esi
  80140e:	8b 45 08             	mov    0x8(%ebp),%eax
  801411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801414:	8b 55 0c             	mov    0xc(%ebp),%edx
  801417:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80141a:	8b 45 10             	mov    0x10(%ebp),%eax
  80141d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801420:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801423:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801426:	b9 00 00 00 00       	mov    $0x0,%ecx
  80142b:	39 d1                	cmp    %edx,%ecx
  80142d:	72 15                	jb     801444 <printnum+0x44>
  80142f:	77 07                	ja     801438 <printnum+0x38>
  801431:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801434:	39 d0                	cmp    %edx,%eax
  801436:	76 0c                	jbe    801444 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801438:	83 eb 01             	sub    $0x1,%ebx
  80143b:	85 db                	test   %ebx,%ebx
  80143d:	8d 76 00             	lea    0x0(%esi),%esi
  801440:	7f 61                	jg     8014a3 <printnum+0xa3>
  801442:	eb 70                	jmp    8014b4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801444:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801448:	83 eb 01             	sub    $0x1,%ebx
  80144b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80144f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801453:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801457:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80145b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80145e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801461:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801464:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801468:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80146f:	00 
  801470:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801473:	89 04 24             	mov    %eax,(%esp)
  801476:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801479:	89 54 24 04          	mov    %edx,0x4(%esp)
  80147d:	e8 de 0b 00 00       	call   802060 <__udivdi3>
  801482:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801485:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801488:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80148c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801490:	89 04 24             	mov    %eax,(%esp)
  801493:	89 54 24 04          	mov    %edx,0x4(%esp)
  801497:	89 f2                	mov    %esi,%edx
  801499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80149c:	e8 5f ff ff ff       	call   801400 <printnum>
  8014a1:	eb 11                	jmp    8014b4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a7:	89 3c 24             	mov    %edi,(%esp)
  8014aa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014ad:	83 eb 01             	sub    $0x1,%ebx
  8014b0:	85 db                	test   %ebx,%ebx
  8014b2:	7f ef                	jg     8014a3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014ca:	00 
  8014cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ce:	89 14 24             	mov    %edx,(%esp)
  8014d1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014d8:	e8 b3 0c 00 00       	call   802190 <__umoddi3>
  8014dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014e1:	0f be 80 33 24 80 00 	movsbl 0x802433(%eax),%eax
  8014e8:	89 04 24             	mov    %eax,(%esp)
  8014eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014ee:	83 c4 4c             	add    $0x4c,%esp
  8014f1:	5b                   	pop    %ebx
  8014f2:	5e                   	pop    %esi
  8014f3:	5f                   	pop    %edi
  8014f4:	5d                   	pop    %ebp
  8014f5:	c3                   	ret    

008014f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014f9:	83 fa 01             	cmp    $0x1,%edx
  8014fc:	7e 0e                	jle    80150c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014fe:	8b 10                	mov    (%eax),%edx
  801500:	8d 4a 08             	lea    0x8(%edx),%ecx
  801503:	89 08                	mov    %ecx,(%eax)
  801505:	8b 02                	mov    (%edx),%eax
  801507:	8b 52 04             	mov    0x4(%edx),%edx
  80150a:	eb 22                	jmp    80152e <getuint+0x38>
	else if (lflag)
  80150c:	85 d2                	test   %edx,%edx
  80150e:	74 10                	je     801520 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801510:	8b 10                	mov    (%eax),%edx
  801512:	8d 4a 04             	lea    0x4(%edx),%ecx
  801515:	89 08                	mov    %ecx,(%eax)
  801517:	8b 02                	mov    (%edx),%eax
  801519:	ba 00 00 00 00       	mov    $0x0,%edx
  80151e:	eb 0e                	jmp    80152e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801520:	8b 10                	mov    (%eax),%edx
  801522:	8d 4a 04             	lea    0x4(%edx),%ecx
  801525:	89 08                	mov    %ecx,(%eax)
  801527:	8b 02                	mov    (%edx),%eax
  801529:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80152e:	5d                   	pop    %ebp
  80152f:	c3                   	ret    

00801530 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801536:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80153a:	8b 10                	mov    (%eax),%edx
  80153c:	3b 50 04             	cmp    0x4(%eax),%edx
  80153f:	73 0a                	jae    80154b <sprintputch+0x1b>
		*b->buf++ = ch;
  801541:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801544:	88 0a                	mov    %cl,(%edx)
  801546:	83 c2 01             	add    $0x1,%edx
  801549:	89 10                	mov    %edx,(%eax)
}
  80154b:	5d                   	pop    %ebp
  80154c:	c3                   	ret    

0080154d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	57                   	push   %edi
  801551:	56                   	push   %esi
  801552:	53                   	push   %ebx
  801553:	83 ec 5c             	sub    $0x5c,%esp
  801556:	8b 7d 08             	mov    0x8(%ebp),%edi
  801559:	8b 75 0c             	mov    0xc(%ebp),%esi
  80155c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80155f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801566:	eb 11                	jmp    801579 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801568:	85 c0                	test   %eax,%eax
  80156a:	0f 84 68 04 00 00    	je     8019d8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  801570:	89 74 24 04          	mov    %esi,0x4(%esp)
  801574:	89 04 24             	mov    %eax,(%esp)
  801577:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801579:	0f b6 03             	movzbl (%ebx),%eax
  80157c:	83 c3 01             	add    $0x1,%ebx
  80157f:	83 f8 25             	cmp    $0x25,%eax
  801582:	75 e4                	jne    801568 <vprintfmt+0x1b>
  801584:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80158b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801592:	b9 00 00 00 00       	mov    $0x0,%ecx
  801597:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80159b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015a2:	eb 06                	jmp    8015aa <vprintfmt+0x5d>
  8015a4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8015a8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015aa:	0f b6 13             	movzbl (%ebx),%edx
  8015ad:	0f b6 c2             	movzbl %dl,%eax
  8015b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015b3:	8d 43 01             	lea    0x1(%ebx),%eax
  8015b6:	83 ea 23             	sub    $0x23,%edx
  8015b9:	80 fa 55             	cmp    $0x55,%dl
  8015bc:	0f 87 f9 03 00 00    	ja     8019bb <vprintfmt+0x46e>
  8015c2:	0f b6 d2             	movzbl %dl,%edx
  8015c5:	ff 24 95 20 26 80 00 	jmp    *0x802620(,%edx,4)
  8015cc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8015d0:	eb d6                	jmp    8015a8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015d5:	83 ea 30             	sub    $0x30,%edx
  8015d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8015db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015de:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015e1:	83 fb 09             	cmp    $0x9,%ebx
  8015e4:	77 54                	ja     80163a <vprintfmt+0xed>
  8015e6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8015e9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015ec:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8015ef:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8015f2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8015f6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015f9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015fc:	83 fb 09             	cmp    $0x9,%ebx
  8015ff:	76 eb                	jbe    8015ec <vprintfmt+0x9f>
  801601:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801604:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801607:	eb 31                	jmp    80163a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801609:	8b 55 14             	mov    0x14(%ebp),%edx
  80160c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80160f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801612:	8b 12                	mov    (%edx),%edx
  801614:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  801617:	eb 21                	jmp    80163a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  801619:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80161d:	ba 00 00 00 00       	mov    $0x0,%edx
  801622:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  801626:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801629:	e9 7a ff ff ff       	jmp    8015a8 <vprintfmt+0x5b>
  80162e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801635:	e9 6e ff ff ff       	jmp    8015a8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80163a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80163e:	0f 89 64 ff ff ff    	jns    8015a8 <vprintfmt+0x5b>
  801644:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801647:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80164a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80164d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801650:	e9 53 ff ff ff       	jmp    8015a8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801655:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  801658:	e9 4b ff ff ff       	jmp    8015a8 <vprintfmt+0x5b>
  80165d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801660:	8b 45 14             	mov    0x14(%ebp),%eax
  801663:	8d 50 04             	lea    0x4(%eax),%edx
  801666:	89 55 14             	mov    %edx,0x14(%ebp)
  801669:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166d:	8b 00                	mov    (%eax),%eax
  80166f:	89 04 24             	mov    %eax,(%esp)
  801672:	ff d7                	call   *%edi
  801674:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801677:	e9 fd fe ff ff       	jmp    801579 <vprintfmt+0x2c>
  80167c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80167f:	8b 45 14             	mov    0x14(%ebp),%eax
  801682:	8d 50 04             	lea    0x4(%eax),%edx
  801685:	89 55 14             	mov    %edx,0x14(%ebp)
  801688:	8b 00                	mov    (%eax),%eax
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	c1 fa 1f             	sar    $0x1f,%edx
  80168f:	31 d0                	xor    %edx,%eax
  801691:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801693:	83 f8 0f             	cmp    $0xf,%eax
  801696:	7f 0b                	jg     8016a3 <vprintfmt+0x156>
  801698:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  80169f:	85 d2                	test   %edx,%edx
  8016a1:	75 20                	jne    8016c3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8016a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016a7:	c7 44 24 08 44 24 80 	movl   $0x802444,0x8(%esp)
  8016ae:	00 
  8016af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016b3:	89 3c 24             	mov    %edi,(%esp)
  8016b6:	e8 a5 03 00 00       	call   801a60 <printfmt>
  8016bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016be:	e9 b6 fe ff ff       	jmp    801579 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8016c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016c7:	c7 44 24 08 c7 23 80 	movl   $0x8023c7,0x8(%esp)
  8016ce:	00 
  8016cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016d3:	89 3c 24             	mov    %edi,(%esp)
  8016d6:	e8 85 03 00 00       	call   801a60 <printfmt>
  8016db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016de:	e9 96 fe ff ff       	jmp    801579 <vprintfmt+0x2c>
  8016e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016e6:	89 c3                	mov    %eax,%ebx
  8016e8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8016eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8016f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016f4:	8d 50 04             	lea    0x4(%eax),%edx
  8016f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8016fa:	8b 00                	mov    (%eax),%eax
  8016fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016ff:	85 c0                	test   %eax,%eax
  801701:	b8 4d 24 80 00       	mov    $0x80244d,%eax
  801706:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80170a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80170d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801711:	7e 06                	jle    801719 <vprintfmt+0x1cc>
  801713:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  801717:	75 13                	jne    80172c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801719:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80171c:	0f be 02             	movsbl (%edx),%eax
  80171f:	85 c0                	test   %eax,%eax
  801721:	0f 85 a2 00 00 00    	jne    8017c9 <vprintfmt+0x27c>
  801727:	e9 8f 00 00 00       	jmp    8017bb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80172c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801730:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801733:	89 0c 24             	mov    %ecx,(%esp)
  801736:	e8 70 03 00 00       	call   801aab <strnlen>
  80173b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80173e:	29 c2                	sub    %eax,%edx
  801740:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801743:	85 d2                	test   %edx,%edx
  801745:	7e d2                	jle    801719 <vprintfmt+0x1cc>
					putch(padc, putdat);
  801747:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80174b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80174e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  801751:	89 d3                	mov    %edx,%ebx
  801753:	89 74 24 04          	mov    %esi,0x4(%esp)
  801757:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80175a:	89 04 24             	mov    %eax,(%esp)
  80175d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80175f:	83 eb 01             	sub    $0x1,%ebx
  801762:	85 db                	test   %ebx,%ebx
  801764:	7f ed                	jg     801753 <vprintfmt+0x206>
  801766:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801769:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801770:	eb a7                	jmp    801719 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801772:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801776:	74 1b                	je     801793 <vprintfmt+0x246>
  801778:	8d 50 e0             	lea    -0x20(%eax),%edx
  80177b:	83 fa 5e             	cmp    $0x5e,%edx
  80177e:	76 13                	jbe    801793 <vprintfmt+0x246>
					putch('?', putdat);
  801780:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801783:	89 54 24 04          	mov    %edx,0x4(%esp)
  801787:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80178e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801791:	eb 0d                	jmp    8017a0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801793:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801796:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80179a:	89 04 24             	mov    %eax,(%esp)
  80179d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017a0:	83 ef 01             	sub    $0x1,%edi
  8017a3:	0f be 03             	movsbl (%ebx),%eax
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	74 05                	je     8017af <vprintfmt+0x262>
  8017aa:	83 c3 01             	add    $0x1,%ebx
  8017ad:	eb 31                	jmp    8017e0 <vprintfmt+0x293>
  8017af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017b8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8017bf:	7f 36                	jg     8017f7 <vprintfmt+0x2aa>
  8017c1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8017c4:	e9 b0 fd ff ff       	jmp    801579 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017cc:	83 c2 01             	add    $0x1,%edx
  8017cf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8017d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017d5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8017d8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8017db:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8017de:	89 d3                	mov    %edx,%ebx
  8017e0:	85 f6                	test   %esi,%esi
  8017e2:	78 8e                	js     801772 <vprintfmt+0x225>
  8017e4:	83 ee 01             	sub    $0x1,%esi
  8017e7:	79 89                	jns    801772 <vprintfmt+0x225>
  8017e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017f2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8017f5:	eb c4                	jmp    8017bb <vprintfmt+0x26e>
  8017f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8017fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  801801:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801808:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80180a:	83 eb 01             	sub    $0x1,%ebx
  80180d:	85 db                	test   %ebx,%ebx
  80180f:	7f ec                	jg     8017fd <vprintfmt+0x2b0>
  801811:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801814:	e9 60 fd ff ff       	jmp    801579 <vprintfmt+0x2c>
  801819:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80181c:	83 f9 01             	cmp    $0x1,%ecx
  80181f:	7e 16                	jle    801837 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  801821:	8b 45 14             	mov    0x14(%ebp),%eax
  801824:	8d 50 08             	lea    0x8(%eax),%edx
  801827:	89 55 14             	mov    %edx,0x14(%ebp)
  80182a:	8b 10                	mov    (%eax),%edx
  80182c:	8b 48 04             	mov    0x4(%eax),%ecx
  80182f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801832:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801835:	eb 32                	jmp    801869 <vprintfmt+0x31c>
	else if (lflag)
  801837:	85 c9                	test   %ecx,%ecx
  801839:	74 18                	je     801853 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80183b:	8b 45 14             	mov    0x14(%ebp),%eax
  80183e:	8d 50 04             	lea    0x4(%eax),%edx
  801841:	89 55 14             	mov    %edx,0x14(%ebp)
  801844:	8b 00                	mov    (%eax),%eax
  801846:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801849:	89 c1                	mov    %eax,%ecx
  80184b:	c1 f9 1f             	sar    $0x1f,%ecx
  80184e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801851:	eb 16                	jmp    801869 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  801853:	8b 45 14             	mov    0x14(%ebp),%eax
  801856:	8d 50 04             	lea    0x4(%eax),%edx
  801859:	89 55 14             	mov    %edx,0x14(%ebp)
  80185c:	8b 00                	mov    (%eax),%eax
  80185e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801861:	89 c2                	mov    %eax,%edx
  801863:	c1 fa 1f             	sar    $0x1f,%edx
  801866:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801869:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80186c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80186f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  801874:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801878:	0f 89 8a 00 00 00    	jns    801908 <vprintfmt+0x3bb>
				putch('-', putdat);
  80187e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801882:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801889:	ff d7                	call   *%edi
				num = -(long long) num;
  80188b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80188e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801891:	f7 d8                	neg    %eax
  801893:	83 d2 00             	adc    $0x0,%edx
  801896:	f7 da                	neg    %edx
  801898:	eb 6e                	jmp    801908 <vprintfmt+0x3bb>
  80189a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80189d:	89 ca                	mov    %ecx,%edx
  80189f:	8d 45 14             	lea    0x14(%ebp),%eax
  8018a2:	e8 4f fc ff ff       	call   8014f6 <getuint>
  8018a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8018ac:	eb 5a                	jmp    801908 <vprintfmt+0x3bb>
  8018ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8018b1:	89 ca                	mov    %ecx,%edx
  8018b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b6:	e8 3b fc ff ff       	call   8014f6 <getuint>
  8018bb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8018c0:	eb 46                	jmp    801908 <vprintfmt+0x3bb>
  8018c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8018c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018c9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8018d0:	ff d7                	call   *%edi
			putch('x', putdat);
  8018d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8018dd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8018df:	8b 45 14             	mov    0x14(%ebp),%eax
  8018e2:	8d 50 04             	lea    0x4(%eax),%edx
  8018e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018e8:	8b 00                	mov    (%eax),%eax
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018f4:	eb 12                	jmp    801908 <vprintfmt+0x3bb>
  8018f6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018f9:	89 ca                	mov    %ecx,%edx
  8018fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8018fe:	e8 f3 fb ff ff       	call   8014f6 <getuint>
  801903:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801908:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80190c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801910:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801913:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801917:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80191b:	89 04 24             	mov    %eax,(%esp)
  80191e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801922:	89 f2                	mov    %esi,%edx
  801924:	89 f8                	mov    %edi,%eax
  801926:	e8 d5 fa ff ff       	call   801400 <printnum>
  80192b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80192e:	e9 46 fc ff ff       	jmp    801579 <vprintfmt+0x2c>
  801933:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  801936:	8b 45 14             	mov    0x14(%ebp),%eax
  801939:	8d 50 04             	lea    0x4(%eax),%edx
  80193c:	89 55 14             	mov    %edx,0x14(%ebp)
  80193f:	8b 00                	mov    (%eax),%eax
  801941:	85 c0                	test   %eax,%eax
  801943:	75 24                	jne    801969 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  801945:	c7 44 24 0c 68 25 80 	movl   $0x802568,0xc(%esp)
  80194c:	00 
  80194d:	c7 44 24 08 c7 23 80 	movl   $0x8023c7,0x8(%esp)
  801954:	00 
  801955:	89 74 24 04          	mov    %esi,0x4(%esp)
  801959:	89 3c 24             	mov    %edi,(%esp)
  80195c:	e8 ff 00 00 00       	call   801a60 <printfmt>
  801961:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801964:	e9 10 fc ff ff       	jmp    801579 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  801969:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80196c:	7e 29                	jle    801997 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80196e:	0f b6 16             	movzbl (%esi),%edx
  801971:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  801973:	c7 44 24 0c a0 25 80 	movl   $0x8025a0,0xc(%esp)
  80197a:	00 
  80197b:	c7 44 24 08 c7 23 80 	movl   $0x8023c7,0x8(%esp)
  801982:	00 
  801983:	89 74 24 04          	mov    %esi,0x4(%esp)
  801987:	89 3c 24             	mov    %edi,(%esp)
  80198a:	e8 d1 00 00 00       	call   801a60 <printfmt>
  80198f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801992:	e9 e2 fb ff ff       	jmp    801579 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  801997:	0f b6 16             	movzbl (%esi),%edx
  80199a:	88 10                	mov    %dl,(%eax)
  80199c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80199f:	e9 d5 fb ff ff       	jmp    801579 <vprintfmt+0x2c>
  8019a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8019a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ae:	89 14 24             	mov    %edx,(%esp)
  8019b1:	ff d7                	call   *%edi
  8019b3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8019b6:	e9 be fb ff ff       	jmp    801579 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8019c6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8019cb:	80 38 25             	cmpb   $0x25,(%eax)
  8019ce:	0f 84 a5 fb ff ff    	je     801579 <vprintfmt+0x2c>
  8019d4:	89 c3                	mov    %eax,%ebx
  8019d6:	eb f0                	jmp    8019c8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8019d8:	83 c4 5c             	add    $0x5c,%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5e                   	pop    %esi
  8019dd:	5f                   	pop    %edi
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	83 ec 28             	sub    $0x28,%esp
  8019e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8019ec:	85 c0                	test   %eax,%eax
  8019ee:	74 04                	je     8019f4 <vsnprintf+0x14>
  8019f0:	85 d2                	test   %edx,%edx
  8019f2:	7f 07                	jg     8019fb <vsnprintf+0x1b>
  8019f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019f9:	eb 3b                	jmp    801a36 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019fe:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a05:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a13:	8b 45 10             	mov    0x10(%ebp),%eax
  801a16:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 30 15 80 00 	movl   $0x801530,(%esp)
  801a28:	e8 20 fb ff ff       	call   80154d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a30:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801a36:	c9                   	leave  
  801a37:	c3                   	ret    

00801a38 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801a3e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801a41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a45:	8b 45 10             	mov    0x10(%ebp),%eax
  801a48:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a4f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a53:	8b 45 08             	mov    0x8(%ebp),%eax
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 82 ff ff ff       	call   8019e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a5e:	c9                   	leave  
  801a5f:	c3                   	ret    

00801a60 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801a66:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801a69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7e:	89 04 24             	mov    %eax,(%esp)
  801a81:	e8 c7 fa ff ff       	call   80154d <vprintfmt>
	va_end(ap);
}
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    
	...

00801a90 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a96:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9b:	80 3a 00             	cmpb   $0x0,(%edx)
  801a9e:	74 09                	je     801aa9 <strlen+0x19>
		n++;
  801aa0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801aa3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801aa7:	75 f7                	jne    801aa0 <strlen+0x10>
		n++;
	return n;
}
  801aa9:	5d                   	pop    %ebp
  801aaa:	c3                   	ret    

00801aab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	53                   	push   %ebx
  801aaf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ab2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ab5:	85 c9                	test   %ecx,%ecx
  801ab7:	74 19                	je     801ad2 <strnlen+0x27>
  801ab9:	80 3b 00             	cmpb   $0x0,(%ebx)
  801abc:	74 14                	je     801ad2 <strnlen+0x27>
  801abe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801ac3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ac6:	39 c8                	cmp    %ecx,%eax
  801ac8:	74 0d                	je     801ad7 <strnlen+0x2c>
  801aca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801ace:	75 f3                	jne    801ac3 <strnlen+0x18>
  801ad0:	eb 05                	jmp    801ad7 <strnlen+0x2c>
  801ad2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801ad7:	5b                   	pop    %ebx
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    

00801ada <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ae4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ae9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801aed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801af0:	83 c2 01             	add    $0x1,%edx
  801af3:	84 c9                	test   %cl,%cl
  801af5:	75 f2                	jne    801ae9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801af7:	5b                   	pop    %ebx
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <strcat>:

char *
strcat(char *dst, const char *src)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b04:	89 1c 24             	mov    %ebx,(%esp)
  801b07:	e8 84 ff ff ff       	call   801a90 <strlen>
	strcpy(dst + len, src);
  801b0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b0f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b13:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801b16:	89 04 24             	mov    %eax,(%esp)
  801b19:	e8 bc ff ff ff       	call   801ada <strcpy>
	return dst;
}
  801b1e:	89 d8                	mov    %ebx,%eax
  801b20:	83 c4 08             	add    $0x8,%esp
  801b23:	5b                   	pop    %ebx
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b31:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b34:	85 f6                	test   %esi,%esi
  801b36:	74 18                	je     801b50 <strncpy+0x2a>
  801b38:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b3d:	0f b6 1a             	movzbl (%edx),%ebx
  801b40:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b43:	80 3a 01             	cmpb   $0x1,(%edx)
  801b46:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b49:	83 c1 01             	add    $0x1,%ecx
  801b4c:	39 ce                	cmp    %ecx,%esi
  801b4e:	77 ed                	ja     801b3d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5d                   	pop    %ebp
  801b53:	c3                   	ret    

00801b54 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	56                   	push   %esi
  801b58:	53                   	push   %ebx
  801b59:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b62:	89 f0                	mov    %esi,%eax
  801b64:	85 c9                	test   %ecx,%ecx
  801b66:	74 27                	je     801b8f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801b68:	83 e9 01             	sub    $0x1,%ecx
  801b6b:	74 1d                	je     801b8a <strlcpy+0x36>
  801b6d:	0f b6 1a             	movzbl (%edx),%ebx
  801b70:	84 db                	test   %bl,%bl
  801b72:	74 16                	je     801b8a <strlcpy+0x36>
			*dst++ = *src++;
  801b74:	88 18                	mov    %bl,(%eax)
  801b76:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b79:	83 e9 01             	sub    $0x1,%ecx
  801b7c:	74 0e                	je     801b8c <strlcpy+0x38>
			*dst++ = *src++;
  801b7e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b81:	0f b6 1a             	movzbl (%edx),%ebx
  801b84:	84 db                	test   %bl,%bl
  801b86:	75 ec                	jne    801b74 <strlcpy+0x20>
  801b88:	eb 02                	jmp    801b8c <strlcpy+0x38>
  801b8a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801b8c:	c6 00 00             	movb   $0x0,(%eax)
  801b8f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801b91:	5b                   	pop    %ebx
  801b92:	5e                   	pop    %esi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b9e:	0f b6 01             	movzbl (%ecx),%eax
  801ba1:	84 c0                	test   %al,%al
  801ba3:	74 15                	je     801bba <strcmp+0x25>
  801ba5:	3a 02                	cmp    (%edx),%al
  801ba7:	75 11                	jne    801bba <strcmp+0x25>
		p++, q++;
  801ba9:	83 c1 01             	add    $0x1,%ecx
  801bac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801baf:	0f b6 01             	movzbl (%ecx),%eax
  801bb2:	84 c0                	test   %al,%al
  801bb4:	74 04                	je     801bba <strcmp+0x25>
  801bb6:	3a 02                	cmp    (%edx),%al
  801bb8:	74 ef                	je     801ba9 <strcmp+0x14>
  801bba:	0f b6 c0             	movzbl %al,%eax
  801bbd:	0f b6 12             	movzbl (%edx),%edx
  801bc0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	53                   	push   %ebx
  801bc8:	8b 55 08             	mov    0x8(%ebp),%edx
  801bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	74 23                	je     801bf8 <strncmp+0x34>
  801bd5:	0f b6 1a             	movzbl (%edx),%ebx
  801bd8:	84 db                	test   %bl,%bl
  801bda:	74 25                	je     801c01 <strncmp+0x3d>
  801bdc:	3a 19                	cmp    (%ecx),%bl
  801bde:	75 21                	jne    801c01 <strncmp+0x3d>
  801be0:	83 e8 01             	sub    $0x1,%eax
  801be3:	74 13                	je     801bf8 <strncmp+0x34>
		n--, p++, q++;
  801be5:	83 c2 01             	add    $0x1,%edx
  801be8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801beb:	0f b6 1a             	movzbl (%edx),%ebx
  801bee:	84 db                	test   %bl,%bl
  801bf0:	74 0f                	je     801c01 <strncmp+0x3d>
  801bf2:	3a 19                	cmp    (%ecx),%bl
  801bf4:	74 ea                	je     801be0 <strncmp+0x1c>
  801bf6:	eb 09                	jmp    801c01 <strncmp+0x3d>
  801bf8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801bfd:	5b                   	pop    %ebx
  801bfe:	5d                   	pop    %ebp
  801bff:	90                   	nop
  801c00:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c01:	0f b6 02             	movzbl (%edx),%eax
  801c04:	0f b6 11             	movzbl (%ecx),%edx
  801c07:	29 d0                	sub    %edx,%eax
  801c09:	eb f2                	jmp    801bfd <strncmp+0x39>

00801c0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c15:	0f b6 10             	movzbl (%eax),%edx
  801c18:	84 d2                	test   %dl,%dl
  801c1a:	74 18                	je     801c34 <strchr+0x29>
		if (*s == c)
  801c1c:	38 ca                	cmp    %cl,%dl
  801c1e:	75 0a                	jne    801c2a <strchr+0x1f>
  801c20:	eb 17                	jmp    801c39 <strchr+0x2e>
  801c22:	38 ca                	cmp    %cl,%dl
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	74 0f                	je     801c39 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	0f b6 10             	movzbl (%eax),%edx
  801c30:	84 d2                	test   %dl,%dl
  801c32:	75 ee                	jne    801c22 <strchr+0x17>
  801c34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    

00801c3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c45:	0f b6 10             	movzbl (%eax),%edx
  801c48:	84 d2                	test   %dl,%dl
  801c4a:	74 18                	je     801c64 <strfind+0x29>
		if (*s == c)
  801c4c:	38 ca                	cmp    %cl,%dl
  801c4e:	75 0a                	jne    801c5a <strfind+0x1f>
  801c50:	eb 12                	jmp    801c64 <strfind+0x29>
  801c52:	38 ca                	cmp    %cl,%dl
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	74 0a                	je     801c64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801c5a:	83 c0 01             	add    $0x1,%eax
  801c5d:	0f b6 10             	movzbl (%eax),%edx
  801c60:	84 d2                	test   %dl,%dl
  801c62:	75 ee                	jne    801c52 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	83 ec 0c             	sub    $0xc,%esp
  801c6c:	89 1c 24             	mov    %ebx,(%esp)
  801c6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801c77:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c80:	85 c9                	test   %ecx,%ecx
  801c82:	74 30                	je     801cb4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c8a:	75 25                	jne    801cb1 <memset+0x4b>
  801c8c:	f6 c1 03             	test   $0x3,%cl
  801c8f:	75 20                	jne    801cb1 <memset+0x4b>
		c &= 0xFF;
  801c91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c94:	89 d3                	mov    %edx,%ebx
  801c96:	c1 e3 08             	shl    $0x8,%ebx
  801c99:	89 d6                	mov    %edx,%esi
  801c9b:	c1 e6 18             	shl    $0x18,%esi
  801c9e:	89 d0                	mov    %edx,%eax
  801ca0:	c1 e0 10             	shl    $0x10,%eax
  801ca3:	09 f0                	or     %esi,%eax
  801ca5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801ca7:	09 d8                	or     %ebx,%eax
  801ca9:	c1 e9 02             	shr    $0x2,%ecx
  801cac:	fc                   	cld    
  801cad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801caf:	eb 03                	jmp    801cb4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cb1:	fc                   	cld    
  801cb2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cb4:	89 f8                	mov    %edi,%eax
  801cb6:	8b 1c 24             	mov    (%esp),%ebx
  801cb9:	8b 74 24 04          	mov    0x4(%esp),%esi
  801cbd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801cc1:	89 ec                	mov    %ebp,%esp
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 08             	sub    $0x8,%esp
  801ccb:	89 34 24             	mov    %esi,(%esp)
  801cce:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801cd8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801cdb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801cdd:	39 c6                	cmp    %eax,%esi
  801cdf:	73 35                	jae    801d16 <memmove+0x51>
  801ce1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801ce4:	39 d0                	cmp    %edx,%eax
  801ce6:	73 2e                	jae    801d16 <memmove+0x51>
		s += n;
		d += n;
  801ce8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cea:	f6 c2 03             	test   $0x3,%dl
  801ced:	75 1b                	jne    801d0a <memmove+0x45>
  801cef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cf5:	75 13                	jne    801d0a <memmove+0x45>
  801cf7:	f6 c1 03             	test   $0x3,%cl
  801cfa:	75 0e                	jne    801d0a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801cfc:	83 ef 04             	sub    $0x4,%edi
  801cff:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d02:	c1 e9 02             	shr    $0x2,%ecx
  801d05:	fd                   	std    
  801d06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d08:	eb 09                	jmp    801d13 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d0a:	83 ef 01             	sub    $0x1,%edi
  801d0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d10:	fd                   	std    
  801d11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d13:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d14:	eb 20                	jmp    801d36 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d1c:	75 15                	jne    801d33 <memmove+0x6e>
  801d1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d24:	75 0d                	jne    801d33 <memmove+0x6e>
  801d26:	f6 c1 03             	test   $0x3,%cl
  801d29:	75 08                	jne    801d33 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801d2b:	c1 e9 02             	shr    $0x2,%ecx
  801d2e:	fc                   	cld    
  801d2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d31:	eb 03                	jmp    801d36 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d33:	fc                   	cld    
  801d34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d36:	8b 34 24             	mov    (%esp),%esi
  801d39:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d3d:	89 ec                	mov    %ebp,%esp
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d47:	8b 45 10             	mov    0x10(%ebp),%eax
  801d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d55:	8b 45 08             	mov    0x8(%ebp),%eax
  801d58:	89 04 24             	mov    %eax,(%esp)
  801d5b:	e8 65 ff ff ff       	call   801cc5 <memmove>
}
  801d60:	c9                   	leave  
  801d61:	c3                   	ret    

00801d62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	57                   	push   %edi
  801d66:	56                   	push   %esi
  801d67:	53                   	push   %ebx
  801d68:	8b 75 08             	mov    0x8(%ebp),%esi
  801d6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d71:	85 c9                	test   %ecx,%ecx
  801d73:	74 36                	je     801dab <memcmp+0x49>
		if (*s1 != *s2)
  801d75:	0f b6 06             	movzbl (%esi),%eax
  801d78:	0f b6 1f             	movzbl (%edi),%ebx
  801d7b:	38 d8                	cmp    %bl,%al
  801d7d:	74 20                	je     801d9f <memcmp+0x3d>
  801d7f:	eb 14                	jmp    801d95 <memcmp+0x33>
  801d81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801d86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801d8b:	83 c2 01             	add    $0x1,%edx
  801d8e:	83 e9 01             	sub    $0x1,%ecx
  801d91:	38 d8                	cmp    %bl,%al
  801d93:	74 12                	je     801da7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801d95:	0f b6 c0             	movzbl %al,%eax
  801d98:	0f b6 db             	movzbl %bl,%ebx
  801d9b:	29 d8                	sub    %ebx,%eax
  801d9d:	eb 11                	jmp    801db0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d9f:	83 e9 01             	sub    $0x1,%ecx
  801da2:	ba 00 00 00 00       	mov    $0x0,%edx
  801da7:	85 c9                	test   %ecx,%ecx
  801da9:	75 d6                	jne    801d81 <memcmp+0x1f>
  801dab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dbb:	89 c2                	mov    %eax,%edx
  801dbd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dc0:	39 d0                	cmp    %edx,%eax
  801dc2:	73 15                	jae    801dd9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801dc8:	38 08                	cmp    %cl,(%eax)
  801dca:	75 06                	jne    801dd2 <memfind+0x1d>
  801dcc:	eb 0b                	jmp    801dd9 <memfind+0x24>
  801dce:	38 08                	cmp    %cl,(%eax)
  801dd0:	74 07                	je     801dd9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801dd2:	83 c0 01             	add    $0x1,%eax
  801dd5:	39 c2                	cmp    %eax,%edx
  801dd7:	77 f5                	ja     801dce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801dd9:	5d                   	pop    %ebp
  801dda:	c3                   	ret    

00801ddb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ddb:	55                   	push   %ebp
  801ddc:	89 e5                	mov    %esp,%ebp
  801dde:	57                   	push   %edi
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
  801de1:	83 ec 04             	sub    $0x4,%esp
  801de4:	8b 55 08             	mov    0x8(%ebp),%edx
  801de7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dea:	0f b6 02             	movzbl (%edx),%eax
  801ded:	3c 20                	cmp    $0x20,%al
  801def:	74 04                	je     801df5 <strtol+0x1a>
  801df1:	3c 09                	cmp    $0x9,%al
  801df3:	75 0e                	jne    801e03 <strtol+0x28>
		s++;
  801df5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801df8:	0f b6 02             	movzbl (%edx),%eax
  801dfb:	3c 20                	cmp    $0x20,%al
  801dfd:	74 f6                	je     801df5 <strtol+0x1a>
  801dff:	3c 09                	cmp    $0x9,%al
  801e01:	74 f2                	je     801df5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e03:	3c 2b                	cmp    $0x2b,%al
  801e05:	75 0c                	jne    801e13 <strtol+0x38>
		s++;
  801e07:	83 c2 01             	add    $0x1,%edx
  801e0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801e11:	eb 15                	jmp    801e28 <strtol+0x4d>
	else if (*s == '-')
  801e13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801e1a:	3c 2d                	cmp    $0x2d,%al
  801e1c:	75 0a                	jne    801e28 <strtol+0x4d>
		s++, neg = 1;
  801e1e:	83 c2 01             	add    $0x1,%edx
  801e21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e28:	85 db                	test   %ebx,%ebx
  801e2a:	0f 94 c0             	sete   %al
  801e2d:	74 05                	je     801e34 <strtol+0x59>
  801e2f:	83 fb 10             	cmp    $0x10,%ebx
  801e32:	75 18                	jne    801e4c <strtol+0x71>
  801e34:	80 3a 30             	cmpb   $0x30,(%edx)
  801e37:	75 13                	jne    801e4c <strtol+0x71>
  801e39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	75 0a                	jne    801e4c <strtol+0x71>
		s += 2, base = 16;
  801e42:	83 c2 02             	add    $0x2,%edx
  801e45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e4a:	eb 15                	jmp    801e61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e4c:	84 c0                	test   %al,%al
  801e4e:	66 90                	xchg   %ax,%ax
  801e50:	74 0f                	je     801e61 <strtol+0x86>
  801e52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801e57:	80 3a 30             	cmpb   $0x30,(%edx)
  801e5a:	75 05                	jne    801e61 <strtol+0x86>
		s++, base = 8;
  801e5c:	83 c2 01             	add    $0x1,%edx
  801e5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
  801e66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e68:	0f b6 0a             	movzbl (%edx),%ecx
  801e6b:	89 cf                	mov    %ecx,%edi
  801e6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801e70:	80 fb 09             	cmp    $0x9,%bl
  801e73:	77 08                	ja     801e7d <strtol+0xa2>
			dig = *s - '0';
  801e75:	0f be c9             	movsbl %cl,%ecx
  801e78:	83 e9 30             	sub    $0x30,%ecx
  801e7b:	eb 1e                	jmp    801e9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801e7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801e80:	80 fb 19             	cmp    $0x19,%bl
  801e83:	77 08                	ja     801e8d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801e85:	0f be c9             	movsbl %cl,%ecx
  801e88:	83 e9 57             	sub    $0x57,%ecx
  801e8b:	eb 0e                	jmp    801e9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801e8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801e90:	80 fb 19             	cmp    $0x19,%bl
  801e93:	77 15                	ja     801eaa <strtol+0xcf>
			dig = *s - 'A' + 10;
  801e95:	0f be c9             	movsbl %cl,%ecx
  801e98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801e9b:	39 f1                	cmp    %esi,%ecx
  801e9d:	7d 0b                	jge    801eaa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801e9f:	83 c2 01             	add    $0x1,%edx
  801ea2:	0f af c6             	imul   %esi,%eax
  801ea5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801ea8:	eb be                	jmp    801e68 <strtol+0x8d>
  801eaa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801eac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eb0:	74 05                	je     801eb7 <strtol+0xdc>
		*endptr = (char *) s;
  801eb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801eb5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801eb7:	89 ca                	mov    %ecx,%edx
  801eb9:	f7 da                	neg    %edx
  801ebb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801ebf:	0f 45 c2             	cmovne %edx,%eax
}
  801ec2:	83 c4 04             	add    $0x4,%esp
  801ec5:	5b                   	pop    %ebx
  801ec6:	5e                   	pop    %esi
  801ec7:	5f                   	pop    %edi
  801ec8:	5d                   	pop    %ebp
  801ec9:	c3                   	ret    
  801eca:	00 00                	add    %al,(%eax)
  801ecc:	00 00                	add    %al,(%eax)
	...

00801ed0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ed6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801edc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee1:	39 ca                	cmp    %ecx,%edx
  801ee3:	75 04                	jne    801ee9 <ipc_find_env+0x19>
  801ee5:	b0 00                	mov    $0x0,%al
  801ee7:	eb 11                	jmp    801efa <ipc_find_env+0x2a>
  801ee9:	89 c2                	mov    %eax,%edx
  801eeb:	c1 e2 07             	shl    $0x7,%edx
  801eee:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801ef4:	8b 12                	mov    (%edx),%edx
  801ef6:	39 ca                	cmp    %ecx,%edx
  801ef8:	75 0f                	jne    801f09 <ipc_find_env+0x39>
			return envs[i].env_id;
  801efa:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801efe:	c1 e0 06             	shl    $0x6,%eax
  801f01:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801f07:	eb 0e                	jmp    801f17 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f09:	83 c0 01             	add    $0x1,%eax
  801f0c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f11:	75 d6                	jne    801ee9 <ipc_find_env+0x19>
  801f13:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	57                   	push   %edi
  801f1d:	56                   	push   %esi
  801f1e:	53                   	push   %ebx
  801f1f:	83 ec 1c             	sub    $0x1c,%esp
  801f22:	8b 75 08             	mov    0x8(%ebp),%esi
  801f25:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f2b:	85 db                	test   %ebx,%ebx
  801f2d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f32:	0f 44 d8             	cmove  %eax,%ebx
  801f35:	eb 25                	jmp    801f5c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801f37:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f3a:	74 20                	je     801f5c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801f3c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f40:	c7 44 24 08 c0 27 80 	movl   $0x8027c0,0x8(%esp)
  801f47:	00 
  801f48:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f4f:	00 
  801f50:	c7 04 24 de 27 80 00 	movl   $0x8027de,(%esp)
  801f57:	e8 88 f3 ff ff       	call   8012e4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f5c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f63:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f67:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f6b:	89 34 24             	mov    %esi,(%esp)
  801f6e:	e8 93 e2 ff ff       	call   800206 <sys_ipc_try_send>
  801f73:	85 c0                	test   %eax,%eax
  801f75:	75 c0                	jne    801f37 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f77:	e8 10 e4 ff ff       	call   80038c <sys_yield>
}
  801f7c:	83 c4 1c             	add    $0x1c,%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 28             	sub    $0x28,%esp
  801f8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f90:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f93:	8b 75 08             	mov    0x8(%ebp),%esi
  801f96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f99:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fa3:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801fa6:	89 04 24             	mov    %eax,(%esp)
  801fa9:	e8 1f e2 ff ff       	call   8001cd <sys_ipc_recv>
  801fae:	89 c3                	mov    %eax,%ebx
  801fb0:	85 c0                	test   %eax,%eax
  801fb2:	79 2a                	jns    801fde <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801fb4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fbc:	c7 04 24 e8 27 80 00 	movl   $0x8027e8,(%esp)
  801fc3:	e8 d5 f3 ff ff       	call   80139d <cprintf>
		if(from_env_store != NULL)
  801fc8:	85 f6                	test   %esi,%esi
  801fca:	74 06                	je     801fd2 <ipc_recv+0x4e>
			*from_env_store = 0;
  801fcc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fd2:	85 ff                	test   %edi,%edi
  801fd4:	74 2c                	je     802002 <ipc_recv+0x7e>
			*perm_store = 0;
  801fd6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fdc:	eb 24                	jmp    802002 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801fde:	85 f6                	test   %esi,%esi
  801fe0:	74 0a                	je     801fec <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801fe2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe7:	8b 40 74             	mov    0x74(%eax),%eax
  801fea:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fec:	85 ff                	test   %edi,%edi
  801fee:	74 0a                	je     801ffa <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801ff0:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff5:	8b 40 78             	mov    0x78(%eax),%eax
  801ff8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801ffa:	a1 08 40 80 00       	mov    0x804008,%eax
  801fff:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802002:	89 d8                	mov    %ebx,%eax
  802004:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802007:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80200a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80200d:	89 ec                	mov    %ebp,%esp
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    
  802011:	00 00                	add    %al,(%eax)
	...

00802014 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802017:	8b 45 08             	mov    0x8(%ebp),%eax
  80201a:	89 c2                	mov    %eax,%edx
  80201c:	c1 ea 16             	shr    $0x16,%edx
  80201f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802026:	f6 c2 01             	test   $0x1,%dl
  802029:	74 20                	je     80204b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80202b:	c1 e8 0c             	shr    $0xc,%eax
  80202e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802035:	a8 01                	test   $0x1,%al
  802037:	74 12                	je     80204b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802039:	c1 e8 0c             	shr    $0xc,%eax
  80203c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802041:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802046:	0f b7 c0             	movzwl %ax,%eax
  802049:	eb 05                	jmp    802050 <pageref+0x3c>
  80204b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
	...

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	57                   	push   %edi
  802064:	56                   	push   %esi
  802065:	83 ec 10             	sub    $0x10,%esp
  802068:	8b 45 14             	mov    0x14(%ebp),%eax
  80206b:	8b 55 08             	mov    0x8(%ebp),%edx
  80206e:	8b 75 10             	mov    0x10(%ebp),%esi
  802071:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802074:	85 c0                	test   %eax,%eax
  802076:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802079:	75 35                	jne    8020b0 <__udivdi3+0x50>
  80207b:	39 fe                	cmp    %edi,%esi
  80207d:	77 61                	ja     8020e0 <__udivdi3+0x80>
  80207f:	85 f6                	test   %esi,%esi
  802081:	75 0b                	jne    80208e <__udivdi3+0x2e>
  802083:	b8 01 00 00 00       	mov    $0x1,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	f7 f6                	div    %esi
  80208c:	89 c6                	mov    %eax,%esi
  80208e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802091:	31 d2                	xor    %edx,%edx
  802093:	89 f8                	mov    %edi,%eax
  802095:	f7 f6                	div    %esi
  802097:	89 c7                	mov    %eax,%edi
  802099:	89 c8                	mov    %ecx,%eax
  80209b:	f7 f6                	div    %esi
  80209d:	89 c1                	mov    %eax,%ecx
  80209f:	89 fa                	mov    %edi,%edx
  8020a1:	89 c8                	mov    %ecx,%eax
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	5e                   	pop    %esi
  8020a7:	5f                   	pop    %edi
  8020a8:	5d                   	pop    %ebp
  8020a9:	c3                   	ret    
  8020aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b0:	39 f8                	cmp    %edi,%eax
  8020b2:	77 1c                	ja     8020d0 <__udivdi3+0x70>
  8020b4:	0f bd d0             	bsr    %eax,%edx
  8020b7:	83 f2 1f             	xor    $0x1f,%edx
  8020ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020bd:	75 39                	jne    8020f8 <__udivdi3+0x98>
  8020bf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020c2:	0f 86 a0 00 00 00    	jbe    802168 <__udivdi3+0x108>
  8020c8:	39 f8                	cmp    %edi,%eax
  8020ca:	0f 82 98 00 00 00    	jb     802168 <__udivdi3+0x108>
  8020d0:	31 ff                	xor    %edi,%edi
  8020d2:	31 c9                	xor    %ecx,%ecx
  8020d4:	89 c8                	mov    %ecx,%eax
  8020d6:	89 fa                	mov    %edi,%edx
  8020d8:	83 c4 10             	add    $0x10,%esp
  8020db:	5e                   	pop    %esi
  8020dc:	5f                   	pop    %edi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    
  8020df:	90                   	nop
  8020e0:	89 d1                	mov    %edx,%ecx
  8020e2:	89 fa                	mov    %edi,%edx
  8020e4:	89 c8                	mov    %ecx,%eax
  8020e6:	31 ff                	xor    %edi,%edi
  8020e8:	f7 f6                	div    %esi
  8020ea:	89 c1                	mov    %eax,%ecx
  8020ec:	89 fa                	mov    %edi,%edx
  8020ee:	89 c8                	mov    %ecx,%eax
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	5e                   	pop    %esi
  8020f4:	5f                   	pop    %edi
  8020f5:	5d                   	pop    %ebp
  8020f6:	c3                   	ret    
  8020f7:	90                   	nop
  8020f8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020fc:	89 f2                	mov    %esi,%edx
  8020fe:	d3 e0                	shl    %cl,%eax
  802100:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802103:	b8 20 00 00 00       	mov    $0x20,%eax
  802108:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80210b:	89 c1                	mov    %eax,%ecx
  80210d:	d3 ea                	shr    %cl,%edx
  80210f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802113:	0b 55 ec             	or     -0x14(%ebp),%edx
  802116:	d3 e6                	shl    %cl,%esi
  802118:	89 c1                	mov    %eax,%ecx
  80211a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80211d:	89 fe                	mov    %edi,%esi
  80211f:	d3 ee                	shr    %cl,%esi
  802121:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802125:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80212b:	d3 e7                	shl    %cl,%edi
  80212d:	89 c1                	mov    %eax,%ecx
  80212f:	d3 ea                	shr    %cl,%edx
  802131:	09 d7                	or     %edx,%edi
  802133:	89 f2                	mov    %esi,%edx
  802135:	89 f8                	mov    %edi,%eax
  802137:	f7 75 ec             	divl   -0x14(%ebp)
  80213a:	89 d6                	mov    %edx,%esi
  80213c:	89 c7                	mov    %eax,%edi
  80213e:	f7 65 e8             	mull   -0x18(%ebp)
  802141:	39 d6                	cmp    %edx,%esi
  802143:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802146:	72 30                	jb     802178 <__udivdi3+0x118>
  802148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80214b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80214f:	d3 e2                	shl    %cl,%edx
  802151:	39 c2                	cmp    %eax,%edx
  802153:	73 05                	jae    80215a <__udivdi3+0xfa>
  802155:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802158:	74 1e                	je     802178 <__udivdi3+0x118>
  80215a:	89 f9                	mov    %edi,%ecx
  80215c:	31 ff                	xor    %edi,%edi
  80215e:	e9 71 ff ff ff       	jmp    8020d4 <__udivdi3+0x74>
  802163:	90                   	nop
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	31 ff                	xor    %edi,%edi
  80216a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80216f:	e9 60 ff ff ff       	jmp    8020d4 <__udivdi3+0x74>
  802174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802178:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80217b:	31 ff                	xor    %edi,%edi
  80217d:	89 c8                	mov    %ecx,%eax
  80217f:	89 fa                	mov    %edi,%edx
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	5e                   	pop    %esi
  802185:	5f                   	pop    %edi
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    
	...

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	57                   	push   %edi
  802194:	56                   	push   %esi
  802195:	83 ec 20             	sub    $0x20,%esp
  802198:	8b 55 14             	mov    0x14(%ebp),%edx
  80219b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80219e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a4:	85 d2                	test   %edx,%edx
  8021a6:	89 c8                	mov    %ecx,%eax
  8021a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021ab:	75 13                	jne    8021c0 <__umoddi3+0x30>
  8021ad:	39 f7                	cmp    %esi,%edi
  8021af:	76 3f                	jbe    8021f0 <__umoddi3+0x60>
  8021b1:	89 f2                	mov    %esi,%edx
  8021b3:	f7 f7                	div    %edi
  8021b5:	89 d0                	mov    %edx,%eax
  8021b7:	31 d2                	xor    %edx,%edx
  8021b9:	83 c4 20             	add    $0x20,%esp
  8021bc:	5e                   	pop    %esi
  8021bd:	5f                   	pop    %edi
  8021be:	5d                   	pop    %ebp
  8021bf:	c3                   	ret    
  8021c0:	39 f2                	cmp    %esi,%edx
  8021c2:	77 4c                	ja     802210 <__umoddi3+0x80>
  8021c4:	0f bd ca             	bsr    %edx,%ecx
  8021c7:	83 f1 1f             	xor    $0x1f,%ecx
  8021ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021cd:	75 51                	jne    802220 <__umoddi3+0x90>
  8021cf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021d2:	0f 87 e0 00 00 00    	ja     8022b8 <__umoddi3+0x128>
  8021d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021db:	29 f8                	sub    %edi,%eax
  8021dd:	19 d6                	sbb    %edx,%esi
  8021df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e5:	89 f2                	mov    %esi,%edx
  8021e7:	83 c4 20             	add    $0x20,%esp
  8021ea:	5e                   	pop    %esi
  8021eb:	5f                   	pop    %edi
  8021ec:	5d                   	pop    %ebp
  8021ed:	c3                   	ret    
  8021ee:	66 90                	xchg   %ax,%ax
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	75 0b                	jne    8021ff <__umoddi3+0x6f>
  8021f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f9:	31 d2                	xor    %edx,%edx
  8021fb:	f7 f7                	div    %edi
  8021fd:	89 c7                	mov    %eax,%edi
  8021ff:	89 f0                	mov    %esi,%eax
  802201:	31 d2                	xor    %edx,%edx
  802203:	f7 f7                	div    %edi
  802205:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802208:	f7 f7                	div    %edi
  80220a:	eb a9                	jmp    8021b5 <__umoddi3+0x25>
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 20             	add    $0x20,%esp
  802217:	5e                   	pop    %esi
  802218:	5f                   	pop    %edi
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    
  80221b:	90                   	nop
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802224:	d3 e2                	shl    %cl,%edx
  802226:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802229:	ba 20 00 00 00       	mov    $0x20,%edx
  80222e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802231:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802234:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802238:	89 fa                	mov    %edi,%edx
  80223a:	d3 ea                	shr    %cl,%edx
  80223c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802240:	0b 55 f4             	or     -0xc(%ebp),%edx
  802243:	d3 e7                	shl    %cl,%edi
  802245:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802249:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80224c:	89 f2                	mov    %esi,%edx
  80224e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802251:	89 c7                	mov    %eax,%edi
  802253:	d3 ea                	shr    %cl,%edx
  802255:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802259:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80225c:	89 c2                	mov    %eax,%edx
  80225e:	d3 e6                	shl    %cl,%esi
  802260:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802264:	d3 ea                	shr    %cl,%edx
  802266:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80226a:	09 d6                	or     %edx,%esi
  80226c:	89 f0                	mov    %esi,%eax
  80226e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802271:	d3 e7                	shl    %cl,%edi
  802273:	89 f2                	mov    %esi,%edx
  802275:	f7 75 f4             	divl   -0xc(%ebp)
  802278:	89 d6                	mov    %edx,%esi
  80227a:	f7 65 e8             	mull   -0x18(%ebp)
  80227d:	39 d6                	cmp    %edx,%esi
  80227f:	72 2b                	jb     8022ac <__umoddi3+0x11c>
  802281:	39 c7                	cmp    %eax,%edi
  802283:	72 23                	jb     8022a8 <__umoddi3+0x118>
  802285:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802289:	29 c7                	sub    %eax,%edi
  80228b:	19 d6                	sbb    %edx,%esi
  80228d:	89 f0                	mov    %esi,%eax
  80228f:	89 f2                	mov    %esi,%edx
  802291:	d3 ef                	shr    %cl,%edi
  802293:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802297:	d3 e0                	shl    %cl,%eax
  802299:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80229d:	09 f8                	or     %edi,%eax
  80229f:	d3 ea                	shr    %cl,%edx
  8022a1:	83 c4 20             	add    $0x20,%esp
  8022a4:	5e                   	pop    %esi
  8022a5:	5f                   	pop    %edi
  8022a6:	5d                   	pop    %ebp
  8022a7:	c3                   	ret    
  8022a8:	39 d6                	cmp    %edx,%esi
  8022aa:	75 d9                	jne    802285 <__umoddi3+0xf5>
  8022ac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022af:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022b2:	eb d1                	jmp    802285 <__umoddi3+0xf5>
  8022b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	39 f2                	cmp    %esi,%edx
  8022ba:	0f 82 18 ff ff ff    	jb     8021d8 <__umoddi3+0x48>
  8022c0:	e9 1d ff ff ff       	jmp    8021e2 <__umoddi3+0x52>
