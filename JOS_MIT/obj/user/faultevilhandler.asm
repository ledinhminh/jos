
obj/user/faultevilhandler.debug:     file format elf32-i386


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
  800051:	e8 8c 02 00 00       	call   8002e2 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800056:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005d:	f0 
  80005e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800065:	e8 5f 01 00 00       	call   8001c9 <sys_env_set_pgfault_upcall>
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
  80008a:	e8 fd 02 00 00       	call   80038c <sys_getenvid>
  80008f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800094:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009c:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000ce:	e8 96 08 00 00       	call   800969 <close_all>
	sys_env_destroy(0);
  8000d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000da:	e8 e8 02 00 00       	call   8003c7 <sys_env_destroy>
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
  80012f:	c7 44 24 08 2a 1d 80 	movl   $0x801d2a,0x8(%esp)
  800136:	00 
  800137:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  80013e:	00 
  80013f:	c7 04 24 47 1d 80 00 	movl   $0x801d47,(%esp)
  800146:	e8 25 0c 00 00       	call   800d70 <_panic>

	return ret;
}
  80014b:	89 d0                	mov    %edx,%eax
  80014d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800150:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800153:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800156:	89 ec                	mov    %ebp,%esp
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800160:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800167:	00 
  800168:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80016f:	00 
  800170:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800177:	00 
  800178:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80017f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800182:	ba 01 00 00 00       	mov    $0x1,%edx
  800187:	b8 0e 00 00 00       	mov    $0xe,%eax
  80018c:	e8 53 ff ff ff       	call   8000e4 <syscall>
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800199:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001a0:	00 
  8001a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b2:	89 04 24             	mov    %eax,(%esp)
  8001b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bd:	b8 0d 00 00 00       	mov    $0xd,%eax
  8001c2:	e8 1d ff ff ff       	call   8000e4 <syscall>
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8001cf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d6:	00 
  8001d7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001de:	00 
  8001df:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001e6:	00 
  8001e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ea:	89 04 24             	mov    %eax,(%esp)
  8001ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f0:	ba 01 00 00 00       	mov    $0x1,%edx
  8001f5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001fa:	e8 e5 fe ff ff       	call   8000e4 <syscall>
}
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800207:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020e:	00 
  80020f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800216:	00 
  800217:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80021e:	00 
  80021f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800222:	89 04 24             	mov    %eax,(%esp)
  800225:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800228:	ba 01 00 00 00       	mov    $0x1,%edx
  80022d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800232:	e8 ad fe ff ff       	call   8000e4 <syscall>
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80023f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800246:	00 
  800247:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80024e:	00 
  80024f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800256:	00 
  800257:	8b 45 0c             	mov    0xc(%ebp),%eax
  80025a:	89 04 24             	mov    %eax,(%esp)
  80025d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800260:	ba 01 00 00 00       	mov    $0x1,%edx
  800265:	b8 09 00 00 00       	mov    $0x9,%eax
  80026a:	e8 75 fe ff ff       	call   8000e4 <syscall>
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  80029d:	b8 07 00 00 00       	mov    $0x7,%eax
  8002a2:	e8 3d fe ff ff       	call   8000e4 <syscall>
}
  8002a7:	c9                   	leave  
  8002a8:	c3                   	ret    

008002a9 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8002af:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b6:	00 
  8002b7:	8b 45 18             	mov    0x18(%ebp),%eax
  8002ba:	0b 45 14             	or     0x14(%ebp),%eax
  8002bd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002cb:	89 04 24             	mov    %eax,(%esp)
  8002ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d1:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d6:	b8 06 00 00 00       	mov    $0x6,%eax
  8002db:	e8 04 fe ff ff       	call   8000e4 <syscall>
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8002e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ef:	00 
  8002f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002f7:	00 
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800302:	89 04 24             	mov    %eax,(%esp)
  800305:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800308:	ba 01 00 00 00       	mov    $0x1,%edx
  80030d:	b8 05 00 00 00       	mov    $0x5,%eax
  800312:	e8 cd fd ff ff       	call   8000e4 <syscall>
}
  800317:	c9                   	leave  
  800318:	c3                   	ret    

00800319 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800319:	55                   	push   %ebp
  80031a:	89 e5                	mov    %esp,%ebp
  80031c:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80031f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800326:	00 
  800327:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80032e:	00 
  80032f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800336:	00 
  800337:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80033e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800343:	ba 00 00 00 00       	mov    $0x0,%edx
  800348:	b8 0c 00 00 00       	mov    $0xc,%eax
  80034d:	e8 92 fd ff ff       	call   8000e4 <syscall>
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  80035a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800361:	00 
  800362:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800369:	00 
  80036a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800371:	00 
  800372:	8b 45 0c             	mov    0xc(%ebp),%eax
  800375:	89 04 24             	mov    %eax,(%esp)
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	b8 04 00 00 00       	mov    $0x4,%eax
  800385:	e8 5a fd ff ff       	call   8000e4 <syscall>
}
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800392:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800399:	00 
  80039a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003a1:	00 
  8003a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003a9:	00 
  8003aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8003c0:	e8 1f fd ff ff       	call   8000e4 <syscall>
}
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8003cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003d4:	00 
  8003d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003dc:	00 
  8003dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e4:	00 
  8003e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003ef:	ba 01 00 00 00       	mov    $0x1,%edx
  8003f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8003f9:	e8 e6 fc ff ff       	call   8000e4 <syscall>
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800406:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040d:	00 
  80040e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800415:	00 
  800416:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80041d:	00 
  80041e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
  80042a:	ba 00 00 00 00       	mov    $0x0,%edx
  80042f:	b8 01 00 00 00       	mov    $0x1,%eax
  800434:	e8 ab fc ff ff       	call   8000e4 <syscall>
}
  800439:	c9                   	leave  
  80043a:	c3                   	ret    

0080043b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800441:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800448:	00 
  800449:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800450:	00 
  800451:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800458:	00 
  800459:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045c:	89 04 24             	mov    %eax,(%esp)
  80045f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800462:	ba 00 00 00 00       	mov    $0x0,%edx
  800467:	b8 00 00 00 00       	mov    $0x0,%eax
  80046c:	e8 73 fc ff ff       	call   8000e4 <syscall>
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    
	...

00800480 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	8b 45 08             	mov    0x8(%ebp),%eax
  800486:	05 00 00 00 30       	add    $0x30000000,%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800496:	8b 45 08             	mov    0x8(%ebp),%eax
  800499:	89 04 24             	mov    %eax,(%esp)
  80049c:	e8 df ff ff ff       	call   800480 <fd2num>
  8004a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8004a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8004a9:	c9                   	leave  
  8004aa:	c3                   	ret    

008004ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	57                   	push   %edi
  8004af:	56                   	push   %esi
  8004b0:	53                   	push   %ebx
  8004b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8004b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8004b9:	a8 01                	test   $0x1,%al
  8004bb:	74 36                	je     8004f3 <fd_alloc+0x48>
  8004bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8004c2:	a8 01                	test   $0x1,%al
  8004c4:	74 2d                	je     8004f3 <fd_alloc+0x48>
  8004c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8004cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8004d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8004d5:	89 c3                	mov    %eax,%ebx
  8004d7:	89 c2                	mov    %eax,%edx
  8004d9:	c1 ea 16             	shr    $0x16,%edx
  8004dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8004df:	f6 c2 01             	test   $0x1,%dl
  8004e2:	74 14                	je     8004f8 <fd_alloc+0x4d>
  8004e4:	89 c2                	mov    %eax,%edx
  8004e6:	c1 ea 0c             	shr    $0xc,%edx
  8004e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8004ec:	f6 c2 01             	test   $0x1,%dl
  8004ef:	75 10                	jne    800501 <fd_alloc+0x56>
  8004f1:	eb 05                	jmp    8004f8 <fd_alloc+0x4d>
  8004f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8004f8:	89 1f                	mov    %ebx,(%edi)
  8004fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8004ff:	eb 17                	jmp    800518 <fd_alloc+0x6d>
  800501:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800506:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80050b:	75 c8                	jne    8004d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80050d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800513:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800518:	5b                   	pop    %ebx
  800519:	5e                   	pop    %esi
  80051a:	5f                   	pop    %edi
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800520:	8b 45 08             	mov    0x8(%ebp),%eax
  800523:	83 f8 1f             	cmp    $0x1f,%eax
  800526:	77 36                	ja     80055e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800528:	05 00 00 0d 00       	add    $0xd0000,%eax
  80052d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800530:	89 c2                	mov    %eax,%edx
  800532:	c1 ea 16             	shr    $0x16,%edx
  800535:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80053c:	f6 c2 01             	test   $0x1,%dl
  80053f:	74 1d                	je     80055e <fd_lookup+0x41>
  800541:	89 c2                	mov    %eax,%edx
  800543:	c1 ea 0c             	shr    $0xc,%edx
  800546:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80054d:	f6 c2 01             	test   $0x1,%dl
  800550:	74 0c                	je     80055e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800552:	8b 55 0c             	mov    0xc(%ebp),%edx
  800555:	89 02                	mov    %eax,(%edx)
  800557:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80055c:	eb 05                	jmp    800563 <fd_lookup+0x46>
  80055e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800563:	5d                   	pop    %ebp
  800564:	c3                   	ret    

00800565 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80056b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80056e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800572:	8b 45 08             	mov    0x8(%ebp),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	e8 a0 ff ff ff       	call   80051d <fd_lookup>
  80057d:	85 c0                	test   %eax,%eax
  80057f:	78 0e                	js     80058f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800581:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800584:	8b 55 0c             	mov    0xc(%ebp),%edx
  800587:	89 50 04             	mov    %edx,0x4(%eax)
  80058a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	83 ec 10             	sub    $0x10,%esp
  800599:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80059c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80059f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8005a4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8005a9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8005af:	75 11                	jne    8005c2 <dev_lookup+0x31>
  8005b1:	eb 04                	jmp    8005b7 <dev_lookup+0x26>
  8005b3:	39 08                	cmp    %ecx,(%eax)
  8005b5:	75 10                	jne    8005c7 <dev_lookup+0x36>
			*dev = devtab[i];
  8005b7:	89 03                	mov    %eax,(%ebx)
  8005b9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8005be:	66 90                	xchg   %ax,%ax
  8005c0:	eb 36                	jmp    8005f8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8005c2:	be d4 1d 80 00       	mov    $0x801dd4,%esi
  8005c7:	83 c2 01             	add    $0x1,%edx
  8005ca:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8005cd:	85 c0                	test   %eax,%eax
  8005cf:	75 e2                	jne    8005b3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8005d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8005d6:	8b 40 48             	mov    0x48(%eax),%eax
  8005d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e1:	c7 04 24 58 1d 80 00 	movl   $0x801d58,(%esp)
  8005e8:	e8 3c 08 00 00       	call   800e29 <cprintf>
	*dev = 0;
  8005ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	5b                   	pop    %ebx
  8005fc:	5e                   	pop    %esi
  8005fd:	5d                   	pop    %ebp
  8005fe:	c3                   	ret    

008005ff <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8005ff:	55                   	push   %ebp
  800600:	89 e5                	mov    %esp,%ebp
  800602:	53                   	push   %ebx
  800603:	83 ec 24             	sub    $0x24,%esp
  800606:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800609:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80060c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800610:	8b 45 08             	mov    0x8(%ebp),%eax
  800613:	89 04 24             	mov    %eax,(%esp)
  800616:	e8 02 ff ff ff       	call   80051d <fd_lookup>
  80061b:	85 c0                	test   %eax,%eax
  80061d:	78 53                	js     800672 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80061f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800622:	89 44 24 04          	mov    %eax,0x4(%esp)
  800626:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800629:	8b 00                	mov    (%eax),%eax
  80062b:	89 04 24             	mov    %eax,(%esp)
  80062e:	e8 5e ff ff ff       	call   800591 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800633:	85 c0                	test   %eax,%eax
  800635:	78 3b                	js     800672 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800637:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80063c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80063f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800643:	74 2d                	je     800672 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800645:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800648:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80064f:	00 00 00 
	stat->st_isdir = 0;
  800652:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800659:	00 00 00 
	stat->st_dev = dev;
  80065c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80065f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800665:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800669:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066c:	89 14 24             	mov    %edx,(%esp)
  80066f:	ff 50 14             	call   *0x14(%eax)
}
  800672:	83 c4 24             	add    $0x24,%esp
  800675:	5b                   	pop    %ebx
  800676:	5d                   	pop    %ebp
  800677:	c3                   	ret    

00800678 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	53                   	push   %ebx
  80067c:	83 ec 24             	sub    $0x24,%esp
  80067f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800682:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800685:	89 44 24 04          	mov    %eax,0x4(%esp)
  800689:	89 1c 24             	mov    %ebx,(%esp)
  80068c:	e8 8c fe ff ff       	call   80051d <fd_lookup>
  800691:	85 c0                	test   %eax,%eax
  800693:	78 5f                	js     8006f4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800698:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069f:	8b 00                	mov    (%eax),%eax
  8006a1:	89 04 24             	mov    %eax,(%esp)
  8006a4:	e8 e8 fe ff ff       	call   800591 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	78 47                	js     8006f4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006b0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8006b4:	75 23                	jne    8006d9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8006b6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8006bb:	8b 40 48             	mov    0x48(%eax),%eax
  8006be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c6:	c7 04 24 78 1d 80 00 	movl   $0x801d78,(%esp)
  8006cd:	e8 57 07 00 00       	call   800e29 <cprintf>
  8006d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8006d7:	eb 1b                	jmp    8006f4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dc:	8b 48 18             	mov    0x18(%eax),%ecx
  8006df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	74 0c                	je     8006f4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ef:	89 14 24             	mov    %edx,(%esp)
  8006f2:	ff d1                	call   *%ecx
}
  8006f4:	83 c4 24             	add    $0x24,%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5d                   	pop    %ebp
  8006f9:	c3                   	ret    

008006fa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fa:	55                   	push   %ebp
  8006fb:	89 e5                	mov    %esp,%ebp
  8006fd:	53                   	push   %ebx
  8006fe:	83 ec 24             	sub    $0x24,%esp
  800701:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800704:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800707:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070b:	89 1c 24             	mov    %ebx,(%esp)
  80070e:	e8 0a fe ff ff       	call   80051d <fd_lookup>
  800713:	85 c0                	test   %eax,%eax
  800715:	78 66                	js     80077d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800717:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80071a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800721:	8b 00                	mov    (%eax),%eax
  800723:	89 04 24             	mov    %eax,(%esp)
  800726:	e8 66 fe ff ff       	call   800591 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072b:	85 c0                	test   %eax,%eax
  80072d:	78 4e                	js     80077d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800732:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800736:	75 23                	jne    80075b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800738:	a1 04 40 80 00       	mov    0x804004,%eax
  80073d:	8b 40 48             	mov    0x48(%eax),%eax
  800740:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800744:	89 44 24 04          	mov    %eax,0x4(%esp)
  800748:	c7 04 24 99 1d 80 00 	movl   $0x801d99,(%esp)
  80074f:	e8 d5 06 00 00       	call   800e29 <cprintf>
  800754:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800759:	eb 22                	jmp    80077d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075e:	8b 48 0c             	mov    0xc(%eax),%ecx
  800761:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800766:	85 c9                	test   %ecx,%ecx
  800768:	74 13                	je     80077d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	8b 45 10             	mov    0x10(%ebp),%eax
  80076d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800771:	8b 45 0c             	mov    0xc(%ebp),%eax
  800774:	89 44 24 04          	mov    %eax,0x4(%esp)
  800778:	89 14 24             	mov    %edx,(%esp)
  80077b:	ff d1                	call   *%ecx
}
  80077d:	83 c4 24             	add    $0x24,%esp
  800780:	5b                   	pop    %ebx
  800781:	5d                   	pop    %ebp
  800782:	c3                   	ret    

00800783 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800783:	55                   	push   %ebp
  800784:	89 e5                	mov    %esp,%ebp
  800786:	53                   	push   %ebx
  800787:	83 ec 24             	sub    $0x24,%esp
  80078a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800790:	89 44 24 04          	mov    %eax,0x4(%esp)
  800794:	89 1c 24             	mov    %ebx,(%esp)
  800797:	e8 81 fd ff ff       	call   80051d <fd_lookup>
  80079c:	85 c0                	test   %eax,%eax
  80079e:	78 6b                	js     80080b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	89 04 24             	mov    %eax,(%esp)
  8007af:	e8 dd fd ff ff       	call   800591 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	78 53                	js     80080b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8007bb:	8b 42 08             	mov    0x8(%edx),%eax
  8007be:	83 e0 03             	and    $0x3,%eax
  8007c1:	83 f8 01             	cmp    $0x1,%eax
  8007c4:	75 23                	jne    8007e9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c6:	a1 04 40 80 00       	mov    0x804004,%eax
  8007cb:	8b 40 48             	mov    0x48(%eax),%eax
  8007ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d6:	c7 04 24 b6 1d 80 00 	movl   $0x801db6,(%esp)
  8007dd:	e8 47 06 00 00       	call   800e29 <cprintf>
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8007e7:	eb 22                	jmp    80080b <read+0x88>
	}
	if (!dev->dev_read)
  8007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ec:	8b 48 08             	mov    0x8(%eax),%ecx
  8007ef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007f4:	85 c9                	test   %ecx,%ecx
  8007f6:	74 13                	je     80080b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800802:	89 44 24 04          	mov    %eax,0x4(%esp)
  800806:	89 14 24             	mov    %edx,(%esp)
  800809:	ff d1                	call   *%ecx
}
  80080b:	83 c4 24             	add    $0x24,%esp
  80080e:	5b                   	pop    %ebx
  80080f:	5d                   	pop    %ebp
  800810:	c3                   	ret    

00800811 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	57                   	push   %edi
  800815:	56                   	push   %esi
  800816:	53                   	push   %ebx
  800817:	83 ec 1c             	sub    $0x1c,%esp
  80081a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80081d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800820:	ba 00 00 00 00       	mov    $0x0,%edx
  800825:	bb 00 00 00 00       	mov    $0x0,%ebx
  80082a:	b8 00 00 00 00       	mov    $0x0,%eax
  80082f:	85 f6                	test   %esi,%esi
  800831:	74 29                	je     80085c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800833:	89 f0                	mov    %esi,%eax
  800835:	29 d0                	sub    %edx,%eax
  800837:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083b:	03 55 0c             	add    0xc(%ebp),%edx
  80083e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800842:	89 3c 24             	mov    %edi,(%esp)
  800845:	e8 39 ff ff ff       	call   800783 <read>
		if (m < 0)
  80084a:	85 c0                	test   %eax,%eax
  80084c:	78 0e                	js     80085c <readn+0x4b>
			return m;
		if (m == 0)
  80084e:	85 c0                	test   %eax,%eax
  800850:	74 08                	je     80085a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800852:	01 c3                	add    %eax,%ebx
  800854:	89 da                	mov    %ebx,%edx
  800856:	39 f3                	cmp    %esi,%ebx
  800858:	72 d9                	jb     800833 <readn+0x22>
  80085a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80085c:	83 c4 1c             	add    $0x1c,%esp
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5f                   	pop    %edi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	83 ec 28             	sub    $0x28,%esp
  80086a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80086d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800870:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800873:	89 34 24             	mov    %esi,(%esp)
  800876:	e8 05 fc ff ff       	call   800480 <fd2num>
  80087b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80087e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800882:	89 04 24             	mov    %eax,(%esp)
  800885:	e8 93 fc ff ff       	call   80051d <fd_lookup>
  80088a:	89 c3                	mov    %eax,%ebx
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 05                	js     800895 <fd_close+0x31>
  800890:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800893:	74 0e                	je     8008a3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800895:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
  80089e:	0f 44 d8             	cmove  %eax,%ebx
  8008a1:	eb 3d                	jmp    8008e0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008aa:	8b 06                	mov    (%esi),%eax
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	e8 dd fc ff ff       	call   800591 <dev_lookup>
  8008b4:	89 c3                	mov    %eax,%ebx
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 16                	js     8008d0 <fd_close+0x6c>
		if (dev->dev_close)
  8008ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008bd:	8b 40 10             	mov    0x10(%eax),%eax
  8008c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	74 07                	je     8008d0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8008c9:	89 34 24             	mov    %esi,(%esp)
  8008cc:	ff d0                	call   *%eax
  8008ce:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008db:	e8 91 f9 ff ff       	call   800271 <sys_page_unmap>
	return r;
}
  8008e0:	89 d8                	mov    %ebx,%eax
  8008e2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8008e5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8008e8:	89 ec                	mov    %ebp,%esp
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    

008008ec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	89 04 24             	mov    %eax,(%esp)
  8008ff:	e8 19 fc ff ff       	call   80051d <fd_lookup>
  800904:	85 c0                	test   %eax,%eax
  800906:	78 13                	js     80091b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800908:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80090f:	00 
  800910:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800913:	89 04 24             	mov    %eax,(%esp)
  800916:	e8 49 ff ff ff       	call   800864 <fd_close>
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 18             	sub    $0x18,%esp
  800923:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800926:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800929:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800930:	00 
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	89 04 24             	mov    %eax,(%esp)
  800937:	e8 78 03 00 00       	call   800cb4 <open>
  80093c:	89 c3                	mov    %eax,%ebx
  80093e:	85 c0                	test   %eax,%eax
  800940:	78 1b                	js     80095d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800942:	8b 45 0c             	mov    0xc(%ebp),%eax
  800945:	89 44 24 04          	mov    %eax,0x4(%esp)
  800949:	89 1c 24             	mov    %ebx,(%esp)
  80094c:	e8 ae fc ff ff       	call   8005ff <fstat>
  800951:	89 c6                	mov    %eax,%esi
	close(fd);
  800953:	89 1c 24             	mov    %ebx,(%esp)
  800956:	e8 91 ff ff ff       	call   8008ec <close>
  80095b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80095d:	89 d8                	mov    %ebx,%eax
  80095f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800962:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800965:	89 ec                	mov    %ebp,%esp
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	53                   	push   %ebx
  80096d:	83 ec 14             	sub    $0x14,%esp
  800970:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800975:	89 1c 24             	mov    %ebx,(%esp)
  800978:	e8 6f ff ff ff       	call   8008ec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80097d:	83 c3 01             	add    $0x1,%ebx
  800980:	83 fb 20             	cmp    $0x20,%ebx
  800983:	75 f0                	jne    800975 <close_all+0xc>
		close(i);
}
  800985:	83 c4 14             	add    $0x14,%esp
  800988:	5b                   	pop    %ebx
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	83 ec 58             	sub    $0x58,%esp
  800991:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800994:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800997:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80099a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80099d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	89 04 24             	mov    %eax,(%esp)
  8009aa:	e8 6e fb ff ff       	call   80051d <fd_lookup>
  8009af:	89 c3                	mov    %eax,%ebx
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	0f 88 e0 00 00 00    	js     800a99 <dup+0x10e>
		return r;
	close(newfdnum);
  8009b9:	89 3c 24             	mov    %edi,(%esp)
  8009bc:	e8 2b ff ff ff       	call   8008ec <close>

	newfd = INDEX2FD(newfdnum);
  8009c1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8009c7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8009ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009cd:	89 04 24             	mov    %eax,(%esp)
  8009d0:	e8 bb fa ff ff       	call   800490 <fd2data>
  8009d5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009d7:	89 34 24             	mov    %esi,(%esp)
  8009da:	e8 b1 fa ff ff       	call   800490 <fd2data>
  8009df:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8009e2:	89 da                	mov    %ebx,%edx
  8009e4:	89 d8                	mov    %ebx,%eax
  8009e6:	c1 e8 16             	shr    $0x16,%eax
  8009e9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009f0:	a8 01                	test   $0x1,%al
  8009f2:	74 43                	je     800a37 <dup+0xac>
  8009f4:	c1 ea 0c             	shr    $0xc,%edx
  8009f7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8009fe:	a8 01                	test   $0x1,%al
  800a00:	74 35                	je     800a37 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a02:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a09:	25 07 0e 00 00       	and    $0xe07,%eax
  800a0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a19:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a20:	00 
  800a21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a2c:	e8 78 f8 ff ff       	call   8002a9 <sys_page_map>
  800a31:	89 c3                	mov    %eax,%ebx
  800a33:	85 c0                	test   %eax,%eax
  800a35:	78 3f                	js     800a76 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	c1 ea 0c             	shr    $0xc,%edx
  800a3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a46:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a4c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a50:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a5b:	00 
  800a5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a67:	e8 3d f8 ff ff       	call   8002a9 <sys_page_map>
  800a6c:	89 c3                	mov    %eax,%ebx
  800a6e:	85 c0                	test   %eax,%eax
  800a70:	78 04                	js     800a76 <dup+0xeb>
  800a72:	89 fb                	mov    %edi,%ebx
  800a74:	eb 23                	jmp    800a99 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a76:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a81:	e8 eb f7 ff ff       	call   800271 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a89:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a94:	e8 d8 f7 ff ff       	call   800271 <sys_page_unmap>
	return r;
}
  800a99:	89 d8                	mov    %ebx,%eax
  800a9b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a9e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800aa1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800aa4:	89 ec                	mov    %ebp,%esp
  800aa6:	5d                   	pop    %ebp
  800aa7:	c3                   	ret    

00800aa8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800aa8:	55                   	push   %ebp
  800aa9:	89 e5                	mov    %esp,%ebp
  800aab:	83 ec 18             	sub    $0x18,%esp
  800aae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800ab1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800ab4:	89 c3                	mov    %eax,%ebx
  800ab6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800ab8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800abf:	75 11                	jne    800ad2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800ac1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800ac8:	e8 93 0e 00 00       	call   801960 <ipc_find_env>
  800acd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800ad2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800ad9:	00 
  800ada:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ae1:	00 
  800ae2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae6:	a1 00 40 80 00       	mov    0x804000,%eax
  800aeb:	89 04 24             	mov    %eax,(%esp)
  800aee:	e8 b1 0e 00 00       	call   8019a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800af3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800afa:	00 
  800afb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b06:	e8 08 0f 00 00       	call   801a13 <ipc_recv>
}
  800b0b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b0e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b11:	89 ec                	mov    %ebp,%esp
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 40 0c             	mov    0xc(%eax),%eax
  800b21:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b26:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b29:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b33:	b8 02 00 00 00       	mov    $0x2,%eax
  800b38:	e8 6b ff ff ff       	call   800aa8 <fsipc>
}
  800b3d:	c9                   	leave  
  800b3e:	c3                   	ret    

00800b3f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	8b 40 0c             	mov    0xc(%eax),%eax
  800b4b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b50:	ba 00 00 00 00       	mov    $0x0,%edx
  800b55:	b8 06 00 00 00       	mov    $0x6,%eax
  800b5a:	e8 49 ff ff ff       	call   800aa8 <fsipc>
}
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b71:	e8 32 ff ff ff       	call   800aa8 <fsipc>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 14             	sub    $0x14,%esp
  800b7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 40 0c             	mov    0xc(%eax),%eax
  800b88:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 05 00 00 00       	mov    $0x5,%eax
  800b97:	e8 0c ff ff ff       	call   800aa8 <fsipc>
  800b9c:	85 c0                	test   %eax,%eax
  800b9e:	78 2b                	js     800bcb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800ba0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800ba7:	00 
  800ba8:	89 1c 24             	mov    %ebx,(%esp)
  800bab:	e8 ba 09 00 00       	call   80156a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800bb0:	a1 80 50 80 00       	mov    0x805080,%eax
  800bb5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bbb:	a1 84 50 80 00       	mov    0x805084,%eax
  800bc0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800bcb:	83 c4 14             	add    $0x14,%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	83 ec 18             	sub    $0x18,%esp
  800bd7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 52 0c             	mov    0xc(%edx),%edx
  800be0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800be6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800beb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800bf0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800bf5:	0f 47 c2             	cmova  %edx,%eax
  800bf8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c03:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800c0a:	e8 46 0b 00 00       	call   801755 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800c0f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c14:	b8 04 00 00 00       	mov    $0x4,%eax
  800c19:	e8 8a fe ff ff       	call   800aa8 <fsipc>
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	53                   	push   %ebx
  800c24:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	8b 40 0c             	mov    0xc(%eax),%eax
  800c2d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800c32:	8b 45 10             	mov    0x10(%ebp),%eax
  800c35:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c44:	e8 5f fe ff ff       	call   800aa8 <fsipc>
  800c49:	89 c3                	mov    %eax,%ebx
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	78 17                	js     800c66 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c53:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c5a:	00 
  800c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c5e:	89 04 24             	mov    %eax,(%esp)
  800c61:	e8 ef 0a 00 00       	call   801755 <memmove>
  return r;	
}
  800c66:	89 d8                	mov    %ebx,%eax
  800c68:	83 c4 14             	add    $0x14,%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	53                   	push   %ebx
  800c72:	83 ec 14             	sub    $0x14,%esp
  800c75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800c78:	89 1c 24             	mov    %ebx,(%esp)
  800c7b:	e8 a0 08 00 00       	call   801520 <strlen>
  800c80:	89 c2                	mov    %eax,%edx
  800c82:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800c87:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800c8d:	7f 1f                	jg     800cae <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800c8f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c93:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c9a:	e8 cb 08 00 00       	call   80156a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca4:	b8 07 00 00 00       	mov    $0x7,%eax
  800ca9:	e8 fa fd ff ff       	call   800aa8 <fsipc>
}
  800cae:	83 c4 14             	add    $0x14,%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 28             	sub    $0x28,%esp
  800cba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cbd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800cc0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800cc3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cc6:	89 04 24             	mov    %eax,(%esp)
  800cc9:	e8 dd f7 ff ff       	call   8004ab <fd_alloc>
  800cce:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800cd0:	85 c0                	test   %eax,%eax
  800cd2:	0f 88 89 00 00 00    	js     800d61 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800cd8:	89 34 24             	mov    %esi,(%esp)
  800cdb:	e8 40 08 00 00       	call   801520 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800ce0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800ce5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cea:	7f 75                	jg     800d61 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800cec:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cf0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cf7:	e8 6e 08 00 00       	call   80156a <strcpy>
  fsipcbuf.open.req_omode = mode;
  800cfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cff:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800d04:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d07:	b8 01 00 00 00       	mov    $0x1,%eax
  800d0c:	e8 97 fd ff ff       	call   800aa8 <fsipc>
  800d11:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800d13:	85 c0                	test   %eax,%eax
  800d15:	78 0f                	js     800d26 <open+0x72>
  return fd2num(fd);
  800d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d1a:	89 04 24             	mov    %eax,(%esp)
  800d1d:	e8 5e f7 ff ff       	call   800480 <fd2num>
  800d22:	89 c3                	mov    %eax,%ebx
  800d24:	eb 3b                	jmp    800d61 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800d26:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d2d:	00 
  800d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d31:	89 04 24             	mov    %eax,(%esp)
  800d34:	e8 2b fb ff ff       	call   800864 <fd_close>
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	74 24                	je     800d61 <open+0xad>
  800d3d:	c7 44 24 0c dc 1d 80 	movl   $0x801ddc,0xc(%esp)
  800d44:	00 
  800d45:	c7 44 24 08 f1 1d 80 	movl   $0x801df1,0x8(%esp)
  800d4c:	00 
  800d4d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800d54:	00 
  800d55:	c7 04 24 06 1e 80 00 	movl   $0x801e06,(%esp)
  800d5c:	e8 0f 00 00 00       	call   800d70 <_panic>
  return r;
}
  800d61:	89 d8                	mov    %ebx,%eax
  800d63:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d66:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d69:	89 ec                	mov    %ebp,%esp
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    
  800d6d:	00 00                	add    %al,(%eax)
	...

00800d70 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	56                   	push   %esi
  800d74:	53                   	push   %ebx
  800d75:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800d78:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d7b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800d81:	e8 06 f6 ff ff       	call   80038c <sys_getenvid>
  800d86:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d89:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d90:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d94:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d98:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9c:	c7 04 24 14 1e 80 00 	movl   $0x801e14,(%esp)
  800da3:	e8 81 00 00 00       	call   800e29 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dac:	8b 45 10             	mov    0x10(%ebp),%eax
  800daf:	89 04 24             	mov    %eax,(%esp)
  800db2:	e8 11 00 00 00       	call   800dc8 <vcprintf>
	cprintf("\n");
  800db7:	c7 04 24 d0 1d 80 00 	movl   $0x801dd0,(%esp)
  800dbe:	e8 66 00 00 00       	call   800e29 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dc3:	cc                   	int3   
  800dc4:	eb fd                	jmp    800dc3 <_panic+0x53>
	...

00800dc8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800dd1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800dd8:	00 00 00 
	b.cnt = 0;
  800ddb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800de2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800de5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800df9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dfd:	c7 04 24 43 0e 80 00 	movl   $0x800e43,(%esp)
  800e04:	e8 d4 01 00 00       	call   800fdd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800e09:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800e0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e13:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800e19:	89 04 24             	mov    %eax,(%esp)
  800e1c:	e8 1a f6 ff ff       	call   80043b <sys_cputs>

	return b.cnt;
}
  800e21:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    

00800e29 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800e2f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800e32:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
  800e39:	89 04 24             	mov    %eax,(%esp)
  800e3c:	e8 87 ff ff ff       	call   800dc8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	53                   	push   %ebx
  800e47:	83 ec 14             	sub    $0x14,%esp
  800e4a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800e4d:	8b 03                	mov    (%ebx),%eax
  800e4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e52:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800e56:	83 c0 01             	add    $0x1,%eax
  800e59:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800e5b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800e60:	75 19                	jne    800e7b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800e62:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800e69:	00 
  800e6a:	8d 43 08             	lea    0x8(%ebx),%eax
  800e6d:	89 04 24             	mov    %eax,(%esp)
  800e70:	e8 c6 f5 ff ff       	call   80043b <sys_cputs>
		b->idx = 0;
  800e75:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800e7b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800e7f:	83 c4 14             	add    $0x14,%esp
  800e82:	5b                   	pop    %ebx
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    
	...

00800e90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	83 ec 4c             	sub    $0x4c,%esp
  800e99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e9c:	89 d6                	mov    %edx,%esi
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800eaa:	8b 45 10             	mov    0x10(%ebp),%eax
  800ead:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800eb0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800eb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800eb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebb:	39 d1                	cmp    %edx,%ecx
  800ebd:	72 15                	jb     800ed4 <printnum+0x44>
  800ebf:	77 07                	ja     800ec8 <printnum+0x38>
  800ec1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ec4:	39 d0                	cmp    %edx,%eax
  800ec6:	76 0c                	jbe    800ed4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800ec8:	83 eb 01             	sub    $0x1,%ebx
  800ecb:	85 db                	test   %ebx,%ebx
  800ecd:	8d 76 00             	lea    0x0(%esi),%esi
  800ed0:	7f 61                	jg     800f33 <printnum+0xa3>
  800ed2:	eb 70                	jmp    800f44 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800ed4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800ed8:	83 eb 01             	sub    $0x1,%ebx
  800edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800edf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ee3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ee7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  800eeb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800eee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800ef1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ef4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ef8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eff:	00 
  800f00:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f03:	89 04 24             	mov    %eax,(%esp)
  800f06:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f09:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f0d:	e8 9e 0b 00 00       	call   801ab0 <__udivdi3>
  800f12:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800f15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800f18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f1c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f20:	89 04 24             	mov    %eax,(%esp)
  800f23:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f27:	89 f2                	mov    %esi,%edx
  800f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f2c:	e8 5f ff ff ff       	call   800e90 <printnum>
  800f31:	eb 11                	jmp    800f44 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800f33:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f37:	89 3c 24             	mov    %edi,(%esp)
  800f3a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800f3d:	83 eb 01             	sub    $0x1,%ebx
  800f40:	85 db                	test   %ebx,%ebx
  800f42:	7f ef                	jg     800f33 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f44:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f48:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f4f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f53:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f5a:	00 
  800f5b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f5e:	89 14 24             	mov    %edx,(%esp)
  800f61:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f68:	e8 73 0c 00 00       	call   801be0 <__umoddi3>
  800f6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f71:	0f be 80 37 1e 80 00 	movsbl 0x801e37(%eax),%eax
  800f78:	89 04 24             	mov    %eax,(%esp)
  800f7b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800f7e:	83 c4 4c             	add    $0x4c,%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f89:	83 fa 01             	cmp    $0x1,%edx
  800f8c:	7e 0e                	jle    800f9c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f8e:	8b 10                	mov    (%eax),%edx
  800f90:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f93:	89 08                	mov    %ecx,(%eax)
  800f95:	8b 02                	mov    (%edx),%eax
  800f97:	8b 52 04             	mov    0x4(%edx),%edx
  800f9a:	eb 22                	jmp    800fbe <getuint+0x38>
	else if (lflag)
  800f9c:	85 d2                	test   %edx,%edx
  800f9e:	74 10                	je     800fb0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800fa0:	8b 10                	mov    (%eax),%edx
  800fa2:	8d 4a 04             	lea    0x4(%edx),%ecx
  800fa5:	89 08                	mov    %ecx,(%eax)
  800fa7:	8b 02                	mov    (%edx),%eax
  800fa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fae:	eb 0e                	jmp    800fbe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800fb0:	8b 10                	mov    (%eax),%edx
  800fb2:	8d 4a 04             	lea    0x4(%edx),%ecx
  800fb5:	89 08                	mov    %ecx,(%eax)
  800fb7:	8b 02                	mov    (%edx),%eax
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800fc6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800fca:	8b 10                	mov    (%eax),%edx
  800fcc:	3b 50 04             	cmp    0x4(%eax),%edx
  800fcf:	73 0a                	jae    800fdb <sprintputch+0x1b>
		*b->buf++ = ch;
  800fd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd4:	88 0a                	mov    %cl,(%edx)
  800fd6:	83 c2 01             	add    $0x1,%edx
  800fd9:	89 10                	mov    %edx,(%eax)
}
  800fdb:	5d                   	pop    %ebp
  800fdc:	c3                   	ret    

00800fdd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	57                   	push   %edi
  800fe1:	56                   	push   %esi
  800fe2:	53                   	push   %ebx
  800fe3:	83 ec 5c             	sub    $0x5c,%esp
  800fe6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fe9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800fef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800ff6:	eb 11                	jmp    801009 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	0f 84 68 04 00 00    	je     801468 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  801000:	89 74 24 04          	mov    %esi,0x4(%esp)
  801004:	89 04 24             	mov    %eax,(%esp)
  801007:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801009:	0f b6 03             	movzbl (%ebx),%eax
  80100c:	83 c3 01             	add    $0x1,%ebx
  80100f:	83 f8 25             	cmp    $0x25,%eax
  801012:	75 e4                	jne    800ff8 <vprintfmt+0x1b>
  801014:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80101b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801022:	b9 00 00 00 00       	mov    $0x0,%ecx
  801027:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80102b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801032:	eb 06                	jmp    80103a <vprintfmt+0x5d>
  801034:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  801038:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80103a:	0f b6 13             	movzbl (%ebx),%edx
  80103d:	0f b6 c2             	movzbl %dl,%eax
  801040:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801043:	8d 43 01             	lea    0x1(%ebx),%eax
  801046:	83 ea 23             	sub    $0x23,%edx
  801049:	80 fa 55             	cmp    $0x55,%dl
  80104c:	0f 87 f9 03 00 00    	ja     80144b <vprintfmt+0x46e>
  801052:	0f b6 d2             	movzbl %dl,%edx
  801055:	ff 24 95 20 20 80 00 	jmp    *0x802020(,%edx,4)
  80105c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  801060:	eb d6                	jmp    801038 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801062:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801065:	83 ea 30             	sub    $0x30,%edx
  801068:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80106b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80106e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801071:	83 fb 09             	cmp    $0x9,%ebx
  801074:	77 54                	ja     8010ca <vprintfmt+0xed>
  801076:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801079:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80107c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80107f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801082:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  801086:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801089:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80108c:	83 fb 09             	cmp    $0x9,%ebx
  80108f:	76 eb                	jbe    80107c <vprintfmt+0x9f>
  801091:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801094:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801097:	eb 31                	jmp    8010ca <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801099:	8b 55 14             	mov    0x14(%ebp),%edx
  80109c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80109f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8010a2:	8b 12                	mov    (%edx),%edx
  8010a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8010a7:	eb 21                	jmp    8010ca <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8010a9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8010ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8010b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8010b9:	e9 7a ff ff ff       	jmp    801038 <vprintfmt+0x5b>
  8010be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8010c5:	e9 6e ff ff ff       	jmp    801038 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8010ca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8010ce:	0f 89 64 ff ff ff    	jns    801038 <vprintfmt+0x5b>
  8010d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8010d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8010da:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8010dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8010e0:	e9 53 ff ff ff       	jmp    801038 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010e5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8010e8:	e9 4b ff ff ff       	jmp    801038 <vprintfmt+0x5b>
  8010ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8010f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8010f3:	8d 50 04             	lea    0x4(%eax),%edx
  8010f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8010f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010fd:	8b 00                	mov    (%eax),%eax
  8010ff:	89 04 24             	mov    %eax,(%esp)
  801102:	ff d7                	call   *%edi
  801104:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801107:	e9 fd fe ff ff       	jmp    801009 <vprintfmt+0x2c>
  80110c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80110f:	8b 45 14             	mov    0x14(%ebp),%eax
  801112:	8d 50 04             	lea    0x4(%eax),%edx
  801115:	89 55 14             	mov    %edx,0x14(%ebp)
  801118:	8b 00                	mov    (%eax),%eax
  80111a:	89 c2                	mov    %eax,%edx
  80111c:	c1 fa 1f             	sar    $0x1f,%edx
  80111f:	31 d0                	xor    %edx,%eax
  801121:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801123:	83 f8 0f             	cmp    $0xf,%eax
  801126:	7f 0b                	jg     801133 <vprintfmt+0x156>
  801128:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  80112f:	85 d2                	test   %edx,%edx
  801131:	75 20                	jne    801153 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  801133:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801137:	c7 44 24 08 48 1e 80 	movl   $0x801e48,0x8(%esp)
  80113e:	00 
  80113f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801143:	89 3c 24             	mov    %edi,(%esp)
  801146:	e8 a5 03 00 00       	call   8014f0 <printfmt>
  80114b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80114e:	e9 b6 fe ff ff       	jmp    801009 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801153:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801157:	c7 44 24 08 03 1e 80 	movl   $0x801e03,0x8(%esp)
  80115e:	00 
  80115f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801163:	89 3c 24             	mov    %edi,(%esp)
  801166:	e8 85 03 00 00       	call   8014f0 <printfmt>
  80116b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80116e:	e9 96 fe ff ff       	jmp    801009 <vprintfmt+0x2c>
  801173:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801176:	89 c3                	mov    %eax,%ebx
  801178:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80117b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80117e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801181:	8b 45 14             	mov    0x14(%ebp),%eax
  801184:	8d 50 04             	lea    0x4(%eax),%edx
  801187:	89 55 14             	mov    %edx,0x14(%ebp)
  80118a:	8b 00                	mov    (%eax),%eax
  80118c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80118f:	85 c0                	test   %eax,%eax
  801191:	b8 51 1e 80 00       	mov    $0x801e51,%eax
  801196:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80119a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80119d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8011a1:	7e 06                	jle    8011a9 <vprintfmt+0x1cc>
  8011a3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8011a7:	75 13                	jne    8011bc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8011a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8011ac:	0f be 02             	movsbl (%edx),%eax
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	0f 85 a2 00 00 00    	jne    801259 <vprintfmt+0x27c>
  8011b7:	e9 8f 00 00 00       	jmp    80124b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8011c3:	89 0c 24             	mov    %ecx,(%esp)
  8011c6:	e8 70 03 00 00       	call   80153b <strnlen>
  8011cb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8011ce:	29 c2                	sub    %eax,%edx
  8011d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8011d3:	85 d2                	test   %edx,%edx
  8011d5:	7e d2                	jle    8011a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8011d7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8011db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011de:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8011e1:	89 d3                	mov    %edx,%ebx
  8011e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011ea:	89 04 24             	mov    %eax,(%esp)
  8011ed:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011ef:	83 eb 01             	sub    $0x1,%ebx
  8011f2:	85 db                	test   %ebx,%ebx
  8011f4:	7f ed                	jg     8011e3 <vprintfmt+0x206>
  8011f6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8011f9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801200:	eb a7                	jmp    8011a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801202:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801206:	74 1b                	je     801223 <vprintfmt+0x246>
  801208:	8d 50 e0             	lea    -0x20(%eax),%edx
  80120b:	83 fa 5e             	cmp    $0x5e,%edx
  80120e:	76 13                	jbe    801223 <vprintfmt+0x246>
					putch('?', putdat);
  801210:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801213:	89 54 24 04          	mov    %edx,0x4(%esp)
  801217:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80121e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801221:	eb 0d                	jmp    801230 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801223:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801226:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80122a:	89 04 24             	mov    %eax,(%esp)
  80122d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801230:	83 ef 01             	sub    $0x1,%edi
  801233:	0f be 03             	movsbl (%ebx),%eax
  801236:	85 c0                	test   %eax,%eax
  801238:	74 05                	je     80123f <vprintfmt+0x262>
  80123a:	83 c3 01             	add    $0x1,%ebx
  80123d:	eb 31                	jmp    801270 <vprintfmt+0x293>
  80123f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801242:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801245:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801248:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80124b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80124f:	7f 36                	jg     801287 <vprintfmt+0x2aa>
  801251:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801254:	e9 b0 fd ff ff       	jmp    801009 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801259:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80125c:	83 c2 01             	add    $0x1,%edx
  80125f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801262:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801265:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801268:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80126b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80126e:	89 d3                	mov    %edx,%ebx
  801270:	85 f6                	test   %esi,%esi
  801272:	78 8e                	js     801202 <vprintfmt+0x225>
  801274:	83 ee 01             	sub    $0x1,%esi
  801277:	79 89                	jns    801202 <vprintfmt+0x225>
  801279:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80127c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80127f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801282:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  801285:	eb c4                	jmp    80124b <vprintfmt+0x26e>
  801287:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80128a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80128d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801291:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801298:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80129a:	83 eb 01             	sub    $0x1,%ebx
  80129d:	85 db                	test   %ebx,%ebx
  80129f:	7f ec                	jg     80128d <vprintfmt+0x2b0>
  8012a1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8012a4:	e9 60 fd ff ff       	jmp    801009 <vprintfmt+0x2c>
  8012a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8012ac:	83 f9 01             	cmp    $0x1,%ecx
  8012af:	7e 16                	jle    8012c7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8012b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b4:	8d 50 08             	lea    0x8(%eax),%edx
  8012b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ba:	8b 10                	mov    (%eax),%edx
  8012bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8012bf:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8012c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012c5:	eb 32                	jmp    8012f9 <vprintfmt+0x31c>
	else if (lflag)
  8012c7:	85 c9                	test   %ecx,%ecx
  8012c9:	74 18                	je     8012e3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8012cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ce:	8d 50 04             	lea    0x4(%eax),%edx
  8012d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8012d4:	8b 00                	mov    (%eax),%eax
  8012d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012d9:	89 c1                	mov    %eax,%ecx
  8012db:	c1 f9 1f             	sar    $0x1f,%ecx
  8012de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012e1:	eb 16                	jmp    8012f9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8012e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e6:	8d 50 04             	lea    0x4(%eax),%edx
  8012e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ec:	8b 00                	mov    (%eax),%eax
  8012ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012f1:	89 c2                	mov    %eax,%edx
  8012f3:	c1 fa 1f             	sar    $0x1f,%edx
  8012f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8012ff:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  801304:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801308:	0f 89 8a 00 00 00    	jns    801398 <vprintfmt+0x3bb>
				putch('-', putdat);
  80130e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801312:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801319:	ff d7                	call   *%edi
				num = -(long long) num;
  80131b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80131e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801321:	f7 d8                	neg    %eax
  801323:	83 d2 00             	adc    $0x0,%edx
  801326:	f7 da                	neg    %edx
  801328:	eb 6e                	jmp    801398 <vprintfmt+0x3bb>
  80132a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80132d:	89 ca                	mov    %ecx,%edx
  80132f:	8d 45 14             	lea    0x14(%ebp),%eax
  801332:	e8 4f fc ff ff       	call   800f86 <getuint>
  801337:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80133c:	eb 5a                	jmp    801398 <vprintfmt+0x3bb>
  80133e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801341:	89 ca                	mov    %ecx,%edx
  801343:	8d 45 14             	lea    0x14(%ebp),%eax
  801346:	e8 3b fc ff ff       	call   800f86 <getuint>
  80134b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  801350:	eb 46                	jmp    801398 <vprintfmt+0x3bb>
  801352:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  801355:	89 74 24 04          	mov    %esi,0x4(%esp)
  801359:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801360:	ff d7                	call   *%edi
			putch('x', putdat);
  801362:	89 74 24 04          	mov    %esi,0x4(%esp)
  801366:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80136d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80136f:	8b 45 14             	mov    0x14(%ebp),%eax
  801372:	8d 50 04             	lea    0x4(%eax),%edx
  801375:	89 55 14             	mov    %edx,0x14(%ebp)
  801378:	8b 00                	mov    (%eax),%eax
  80137a:	ba 00 00 00 00       	mov    $0x0,%edx
  80137f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801384:	eb 12                	jmp    801398 <vprintfmt+0x3bb>
  801386:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801389:	89 ca                	mov    %ecx,%edx
  80138b:	8d 45 14             	lea    0x14(%ebp),%eax
  80138e:	e8 f3 fb ff ff       	call   800f86 <getuint>
  801393:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801398:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80139c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8013a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8013a3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8013a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013ab:	89 04 24             	mov    %eax,(%esp)
  8013ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013b2:	89 f2                	mov    %esi,%edx
  8013b4:	89 f8                	mov    %edi,%eax
  8013b6:	e8 d5 fa ff ff       	call   800e90 <printnum>
  8013bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8013be:	e9 46 fc ff ff       	jmp    801009 <vprintfmt+0x2c>
  8013c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8013c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c9:	8d 50 04             	lea    0x4(%eax),%edx
  8013cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8013cf:	8b 00                	mov    (%eax),%eax
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	75 24                	jne    8013f9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8013d5:	c7 44 24 0c 6c 1f 80 	movl   $0x801f6c,0xc(%esp)
  8013dc:	00 
  8013dd:	c7 44 24 08 03 1e 80 	movl   $0x801e03,0x8(%esp)
  8013e4:	00 
  8013e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e9:	89 3c 24             	mov    %edi,(%esp)
  8013ec:	e8 ff 00 00 00       	call   8014f0 <printfmt>
  8013f1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8013f4:	e9 10 fc ff ff       	jmp    801009 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8013f9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8013fc:	7e 29                	jle    801427 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8013fe:	0f b6 16             	movzbl (%esi),%edx
  801401:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  801403:	c7 44 24 0c a4 1f 80 	movl   $0x801fa4,0xc(%esp)
  80140a:	00 
  80140b:	c7 44 24 08 03 1e 80 	movl   $0x801e03,0x8(%esp)
  801412:	00 
  801413:	89 74 24 04          	mov    %esi,0x4(%esp)
  801417:	89 3c 24             	mov    %edi,(%esp)
  80141a:	e8 d1 00 00 00       	call   8014f0 <printfmt>
  80141f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801422:	e9 e2 fb ff ff       	jmp    801009 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  801427:	0f b6 16             	movzbl (%esi),%edx
  80142a:	88 10                	mov    %dl,(%eax)
  80142c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80142f:	e9 d5 fb ff ff       	jmp    801009 <vprintfmt+0x2c>
  801434:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801437:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80143a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80143e:	89 14 24             	mov    %edx,(%esp)
  801441:	ff d7                	call   *%edi
  801443:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801446:	e9 be fb ff ff       	jmp    801009 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80144b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80144f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801456:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801458:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80145b:	80 38 25             	cmpb   $0x25,(%eax)
  80145e:	0f 84 a5 fb ff ff    	je     801009 <vprintfmt+0x2c>
  801464:	89 c3                	mov    %eax,%ebx
  801466:	eb f0                	jmp    801458 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  801468:	83 c4 5c             	add    $0x5c,%esp
  80146b:	5b                   	pop    %ebx
  80146c:	5e                   	pop    %esi
  80146d:	5f                   	pop    %edi
  80146e:	5d                   	pop    %ebp
  80146f:	c3                   	ret    

00801470 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801470:	55                   	push   %ebp
  801471:	89 e5                	mov    %esp,%ebp
  801473:	83 ec 28             	sub    $0x28,%esp
  801476:	8b 45 08             	mov    0x8(%ebp),%eax
  801479:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80147c:	85 c0                	test   %eax,%eax
  80147e:	74 04                	je     801484 <vsnprintf+0x14>
  801480:	85 d2                	test   %edx,%edx
  801482:	7f 07                	jg     80148b <vsnprintf+0x1b>
  801484:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801489:	eb 3b                	jmp    8014c6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80148b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80148e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801492:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801495:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80149c:	8b 45 14             	mov    0x14(%ebp),%eax
  80149f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8014a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8014ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b1:	c7 04 24 c0 0f 80 00 	movl   $0x800fc0,(%esp)
  8014b8:	e8 20 fb ff ff       	call   800fdd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8014bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8014c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8014c8:	55                   	push   %ebp
  8014c9:	89 e5                	mov    %esp,%ebp
  8014cb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8014ce:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8014d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e6:	89 04 24             	mov    %eax,(%esp)
  8014e9:	e8 82 ff ff ff       	call   801470 <vsnprintf>
	va_end(ap);

	return rc;
}
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8014f6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8014f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801500:	89 44 24 08          	mov    %eax,0x8(%esp)
  801504:	8b 45 0c             	mov    0xc(%ebp),%eax
  801507:	89 44 24 04          	mov    %eax,0x4(%esp)
  80150b:	8b 45 08             	mov    0x8(%ebp),%eax
  80150e:	89 04 24             	mov    %eax,(%esp)
  801511:	e8 c7 fa ff ff       	call   800fdd <vprintfmt>
	va_end(ap);
}
  801516:	c9                   	leave  
  801517:	c3                   	ret    
	...

00801520 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	80 3a 00             	cmpb   $0x0,(%edx)
  80152e:	74 09                	je     801539 <strlen+0x19>
		n++;
  801530:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801533:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801537:	75 f7                	jne    801530 <strlen+0x10>
		n++;
	return n;
}
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	53                   	push   %ebx
  80153f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801542:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801545:	85 c9                	test   %ecx,%ecx
  801547:	74 19                	je     801562 <strnlen+0x27>
  801549:	80 3b 00             	cmpb   $0x0,(%ebx)
  80154c:	74 14                	je     801562 <strnlen+0x27>
  80154e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801553:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801556:	39 c8                	cmp    %ecx,%eax
  801558:	74 0d                	je     801567 <strnlen+0x2c>
  80155a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80155e:	75 f3                	jne    801553 <strnlen+0x18>
  801560:	eb 05                	jmp    801567 <strnlen+0x2c>
  801562:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801567:	5b                   	pop    %ebx
  801568:	5d                   	pop    %ebp
  801569:	c3                   	ret    

0080156a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	8b 45 08             	mov    0x8(%ebp),%eax
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801574:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801579:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80157d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801580:	83 c2 01             	add    $0x1,%edx
  801583:	84 c9                	test   %cl,%cl
  801585:	75 f2                	jne    801579 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801587:	5b                   	pop    %ebx
  801588:	5d                   	pop    %ebp
  801589:	c3                   	ret    

0080158a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	53                   	push   %ebx
  80158e:	83 ec 08             	sub    $0x8,%esp
  801591:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801594:	89 1c 24             	mov    %ebx,(%esp)
  801597:	e8 84 ff ff ff       	call   801520 <strlen>
	strcpy(dst + len, src);
  80159c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80159f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8015a6:	89 04 24             	mov    %eax,(%esp)
  8015a9:	e8 bc ff ff ff       	call   80156a <strcpy>
	return dst;
}
  8015ae:	89 d8                	mov    %ebx,%eax
  8015b0:	83 c4 08             	add    $0x8,%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5d                   	pop    %ebp
  8015b5:	c3                   	ret    

008015b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8015c4:	85 f6                	test   %esi,%esi
  8015c6:	74 18                	je     8015e0 <strncpy+0x2a>
  8015c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8015cd:	0f b6 1a             	movzbl (%edx),%ebx
  8015d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8015d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8015d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8015d9:	83 c1 01             	add    $0x1,%ecx
  8015dc:	39 ce                	cmp    %ecx,%esi
  8015de:	77 ed                	ja     8015cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8015e0:	5b                   	pop    %ebx
  8015e1:	5e                   	pop    %esi
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	56                   	push   %esi
  8015e8:	53                   	push   %ebx
  8015e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8015f2:	89 f0                	mov    %esi,%eax
  8015f4:	85 c9                	test   %ecx,%ecx
  8015f6:	74 27                	je     80161f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8015f8:	83 e9 01             	sub    $0x1,%ecx
  8015fb:	74 1d                	je     80161a <strlcpy+0x36>
  8015fd:	0f b6 1a             	movzbl (%edx),%ebx
  801600:	84 db                	test   %bl,%bl
  801602:	74 16                	je     80161a <strlcpy+0x36>
			*dst++ = *src++;
  801604:	88 18                	mov    %bl,(%eax)
  801606:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801609:	83 e9 01             	sub    $0x1,%ecx
  80160c:	74 0e                	je     80161c <strlcpy+0x38>
			*dst++ = *src++;
  80160e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801611:	0f b6 1a             	movzbl (%edx),%ebx
  801614:	84 db                	test   %bl,%bl
  801616:	75 ec                	jne    801604 <strlcpy+0x20>
  801618:	eb 02                	jmp    80161c <strlcpy+0x38>
  80161a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80161c:	c6 00 00             	movb   $0x0,(%eax)
  80161f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801621:	5b                   	pop    %ebx
  801622:	5e                   	pop    %esi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80162e:	0f b6 01             	movzbl (%ecx),%eax
  801631:	84 c0                	test   %al,%al
  801633:	74 15                	je     80164a <strcmp+0x25>
  801635:	3a 02                	cmp    (%edx),%al
  801637:	75 11                	jne    80164a <strcmp+0x25>
		p++, q++;
  801639:	83 c1 01             	add    $0x1,%ecx
  80163c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80163f:	0f b6 01             	movzbl (%ecx),%eax
  801642:	84 c0                	test   %al,%al
  801644:	74 04                	je     80164a <strcmp+0x25>
  801646:	3a 02                	cmp    (%edx),%al
  801648:	74 ef                	je     801639 <strcmp+0x14>
  80164a:	0f b6 c0             	movzbl %al,%eax
  80164d:	0f b6 12             	movzbl (%edx),%edx
  801650:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801652:	5d                   	pop    %ebp
  801653:	c3                   	ret    

00801654 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	8b 55 08             	mov    0x8(%ebp),%edx
  80165b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80165e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801661:	85 c0                	test   %eax,%eax
  801663:	74 23                	je     801688 <strncmp+0x34>
  801665:	0f b6 1a             	movzbl (%edx),%ebx
  801668:	84 db                	test   %bl,%bl
  80166a:	74 25                	je     801691 <strncmp+0x3d>
  80166c:	3a 19                	cmp    (%ecx),%bl
  80166e:	75 21                	jne    801691 <strncmp+0x3d>
  801670:	83 e8 01             	sub    $0x1,%eax
  801673:	74 13                	je     801688 <strncmp+0x34>
		n--, p++, q++;
  801675:	83 c2 01             	add    $0x1,%edx
  801678:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80167b:	0f b6 1a             	movzbl (%edx),%ebx
  80167e:	84 db                	test   %bl,%bl
  801680:	74 0f                	je     801691 <strncmp+0x3d>
  801682:	3a 19                	cmp    (%ecx),%bl
  801684:	74 ea                	je     801670 <strncmp+0x1c>
  801686:	eb 09                	jmp    801691 <strncmp+0x3d>
  801688:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80168d:	5b                   	pop    %ebx
  80168e:	5d                   	pop    %ebp
  80168f:	90                   	nop
  801690:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801691:	0f b6 02             	movzbl (%edx),%eax
  801694:	0f b6 11             	movzbl (%ecx),%edx
  801697:	29 d0                	sub    %edx,%eax
  801699:	eb f2                	jmp    80168d <strncmp+0x39>

0080169b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8016a5:	0f b6 10             	movzbl (%eax),%edx
  8016a8:	84 d2                	test   %dl,%dl
  8016aa:	74 18                	je     8016c4 <strchr+0x29>
		if (*s == c)
  8016ac:	38 ca                	cmp    %cl,%dl
  8016ae:	75 0a                	jne    8016ba <strchr+0x1f>
  8016b0:	eb 17                	jmp    8016c9 <strchr+0x2e>
  8016b2:	38 ca                	cmp    %cl,%dl
  8016b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016b8:	74 0f                	je     8016c9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8016ba:	83 c0 01             	add    $0x1,%eax
  8016bd:	0f b6 10             	movzbl (%eax),%edx
  8016c0:	84 d2                	test   %dl,%dl
  8016c2:	75 ee                	jne    8016b2 <strchr+0x17>
  8016c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    

008016cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8016d5:	0f b6 10             	movzbl (%eax),%edx
  8016d8:	84 d2                	test   %dl,%dl
  8016da:	74 18                	je     8016f4 <strfind+0x29>
		if (*s == c)
  8016dc:	38 ca                	cmp    %cl,%dl
  8016de:	75 0a                	jne    8016ea <strfind+0x1f>
  8016e0:	eb 12                	jmp    8016f4 <strfind+0x29>
  8016e2:	38 ca                	cmp    %cl,%dl
  8016e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016e8:	74 0a                	je     8016f4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8016ea:	83 c0 01             	add    $0x1,%eax
  8016ed:	0f b6 10             	movzbl (%eax),%edx
  8016f0:	84 d2                	test   %dl,%dl
  8016f2:	75 ee                	jne    8016e2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	83 ec 0c             	sub    $0xc,%esp
  8016fc:	89 1c 24             	mov    %ebx,(%esp)
  8016ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801703:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801707:	8b 7d 08             	mov    0x8(%ebp),%edi
  80170a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801710:	85 c9                	test   %ecx,%ecx
  801712:	74 30                	je     801744 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801714:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80171a:	75 25                	jne    801741 <memset+0x4b>
  80171c:	f6 c1 03             	test   $0x3,%cl
  80171f:	75 20                	jne    801741 <memset+0x4b>
		c &= 0xFF;
  801721:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801724:	89 d3                	mov    %edx,%ebx
  801726:	c1 e3 08             	shl    $0x8,%ebx
  801729:	89 d6                	mov    %edx,%esi
  80172b:	c1 e6 18             	shl    $0x18,%esi
  80172e:	89 d0                	mov    %edx,%eax
  801730:	c1 e0 10             	shl    $0x10,%eax
  801733:	09 f0                	or     %esi,%eax
  801735:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801737:	09 d8                	or     %ebx,%eax
  801739:	c1 e9 02             	shr    $0x2,%ecx
  80173c:	fc                   	cld    
  80173d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80173f:	eb 03                	jmp    801744 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801741:	fc                   	cld    
  801742:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801744:	89 f8                	mov    %edi,%eax
  801746:	8b 1c 24             	mov    (%esp),%ebx
  801749:	8b 74 24 04          	mov    0x4(%esp),%esi
  80174d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801751:	89 ec                	mov    %ebp,%esp
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	89 34 24             	mov    %esi,(%esp)
  80175e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801768:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80176b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80176d:	39 c6                	cmp    %eax,%esi
  80176f:	73 35                	jae    8017a6 <memmove+0x51>
  801771:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801774:	39 d0                	cmp    %edx,%eax
  801776:	73 2e                	jae    8017a6 <memmove+0x51>
		s += n;
		d += n;
  801778:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80177a:	f6 c2 03             	test   $0x3,%dl
  80177d:	75 1b                	jne    80179a <memmove+0x45>
  80177f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801785:	75 13                	jne    80179a <memmove+0x45>
  801787:	f6 c1 03             	test   $0x3,%cl
  80178a:	75 0e                	jne    80179a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80178c:	83 ef 04             	sub    $0x4,%edi
  80178f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801792:	c1 e9 02             	shr    $0x2,%ecx
  801795:	fd                   	std    
  801796:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801798:	eb 09                	jmp    8017a3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80179a:	83 ef 01             	sub    $0x1,%edi
  80179d:	8d 72 ff             	lea    -0x1(%edx),%esi
  8017a0:	fd                   	std    
  8017a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8017a3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8017a4:	eb 20                	jmp    8017c6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8017a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8017ac:	75 15                	jne    8017c3 <memmove+0x6e>
  8017ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8017b4:	75 0d                	jne    8017c3 <memmove+0x6e>
  8017b6:	f6 c1 03             	test   $0x3,%cl
  8017b9:	75 08                	jne    8017c3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  8017bb:	c1 e9 02             	shr    $0x2,%ecx
  8017be:	fc                   	cld    
  8017bf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8017c1:	eb 03                	jmp    8017c6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8017c3:	fc                   	cld    
  8017c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8017c6:	8b 34 24             	mov    (%esp),%esi
  8017c9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8017cd:	89 ec                	mov    %ebp,%esp
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8017d7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	89 04 24             	mov    %eax,(%esp)
  8017eb:	e8 65 ff ff ff       	call   801755 <memmove>
}
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	57                   	push   %edi
  8017f6:	56                   	push   %esi
  8017f7:	53                   	push   %ebx
  8017f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017fb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801801:	85 c9                	test   %ecx,%ecx
  801803:	74 36                	je     80183b <memcmp+0x49>
		if (*s1 != *s2)
  801805:	0f b6 06             	movzbl (%esi),%eax
  801808:	0f b6 1f             	movzbl (%edi),%ebx
  80180b:	38 d8                	cmp    %bl,%al
  80180d:	74 20                	je     80182f <memcmp+0x3d>
  80180f:	eb 14                	jmp    801825 <memcmp+0x33>
  801811:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801816:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80181b:	83 c2 01             	add    $0x1,%edx
  80181e:	83 e9 01             	sub    $0x1,%ecx
  801821:	38 d8                	cmp    %bl,%al
  801823:	74 12                	je     801837 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801825:	0f b6 c0             	movzbl %al,%eax
  801828:	0f b6 db             	movzbl %bl,%ebx
  80182b:	29 d8                	sub    %ebx,%eax
  80182d:	eb 11                	jmp    801840 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80182f:	83 e9 01             	sub    $0x1,%ecx
  801832:	ba 00 00 00 00       	mov    $0x0,%edx
  801837:	85 c9                	test   %ecx,%ecx
  801839:	75 d6                	jne    801811 <memcmp+0x1f>
  80183b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801840:	5b                   	pop    %ebx
  801841:	5e                   	pop    %esi
  801842:	5f                   	pop    %edi
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80184b:	89 c2                	mov    %eax,%edx
  80184d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801850:	39 d0                	cmp    %edx,%eax
  801852:	73 15                	jae    801869 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801854:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801858:	38 08                	cmp    %cl,(%eax)
  80185a:	75 06                	jne    801862 <memfind+0x1d>
  80185c:	eb 0b                	jmp    801869 <memfind+0x24>
  80185e:	38 08                	cmp    %cl,(%eax)
  801860:	74 07                	je     801869 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801862:	83 c0 01             	add    $0x1,%eax
  801865:	39 c2                	cmp    %eax,%edx
  801867:	77 f5                	ja     80185e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801869:	5d                   	pop    %ebp
  80186a:	c3                   	ret    

0080186b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	57                   	push   %edi
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	83 ec 04             	sub    $0x4,%esp
  801874:	8b 55 08             	mov    0x8(%ebp),%edx
  801877:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80187a:	0f b6 02             	movzbl (%edx),%eax
  80187d:	3c 20                	cmp    $0x20,%al
  80187f:	74 04                	je     801885 <strtol+0x1a>
  801881:	3c 09                	cmp    $0x9,%al
  801883:	75 0e                	jne    801893 <strtol+0x28>
		s++;
  801885:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801888:	0f b6 02             	movzbl (%edx),%eax
  80188b:	3c 20                	cmp    $0x20,%al
  80188d:	74 f6                	je     801885 <strtol+0x1a>
  80188f:	3c 09                	cmp    $0x9,%al
  801891:	74 f2                	je     801885 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801893:	3c 2b                	cmp    $0x2b,%al
  801895:	75 0c                	jne    8018a3 <strtol+0x38>
		s++;
  801897:	83 c2 01             	add    $0x1,%edx
  80189a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8018a1:	eb 15                	jmp    8018b8 <strtol+0x4d>
	else if (*s == '-')
  8018a3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8018aa:	3c 2d                	cmp    $0x2d,%al
  8018ac:	75 0a                	jne    8018b8 <strtol+0x4d>
		s++, neg = 1;
  8018ae:	83 c2 01             	add    $0x1,%edx
  8018b1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8018b8:	85 db                	test   %ebx,%ebx
  8018ba:	0f 94 c0             	sete   %al
  8018bd:	74 05                	je     8018c4 <strtol+0x59>
  8018bf:	83 fb 10             	cmp    $0x10,%ebx
  8018c2:	75 18                	jne    8018dc <strtol+0x71>
  8018c4:	80 3a 30             	cmpb   $0x30,(%edx)
  8018c7:	75 13                	jne    8018dc <strtol+0x71>
  8018c9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8018cd:	8d 76 00             	lea    0x0(%esi),%esi
  8018d0:	75 0a                	jne    8018dc <strtol+0x71>
		s += 2, base = 16;
  8018d2:	83 c2 02             	add    $0x2,%edx
  8018d5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8018da:	eb 15                	jmp    8018f1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8018dc:	84 c0                	test   %al,%al
  8018de:	66 90                	xchg   %ax,%ax
  8018e0:	74 0f                	je     8018f1 <strtol+0x86>
  8018e2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8018e7:	80 3a 30             	cmpb   $0x30,(%edx)
  8018ea:	75 05                	jne    8018f1 <strtol+0x86>
		s++, base = 8;
  8018ec:	83 c2 01             	add    $0x1,%edx
  8018ef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8018f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8018f8:	0f b6 0a             	movzbl (%edx),%ecx
  8018fb:	89 cf                	mov    %ecx,%edi
  8018fd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801900:	80 fb 09             	cmp    $0x9,%bl
  801903:	77 08                	ja     80190d <strtol+0xa2>
			dig = *s - '0';
  801905:	0f be c9             	movsbl %cl,%ecx
  801908:	83 e9 30             	sub    $0x30,%ecx
  80190b:	eb 1e                	jmp    80192b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80190d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801910:	80 fb 19             	cmp    $0x19,%bl
  801913:	77 08                	ja     80191d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801915:	0f be c9             	movsbl %cl,%ecx
  801918:	83 e9 57             	sub    $0x57,%ecx
  80191b:	eb 0e                	jmp    80192b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80191d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801920:	80 fb 19             	cmp    $0x19,%bl
  801923:	77 15                	ja     80193a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801925:	0f be c9             	movsbl %cl,%ecx
  801928:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80192b:	39 f1                	cmp    %esi,%ecx
  80192d:	7d 0b                	jge    80193a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80192f:	83 c2 01             	add    $0x1,%edx
  801932:	0f af c6             	imul   %esi,%eax
  801935:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801938:	eb be                	jmp    8018f8 <strtol+0x8d>
  80193a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80193c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801940:	74 05                	je     801947 <strtol+0xdc>
		*endptr = (char *) s;
  801942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801945:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801947:	89 ca                	mov    %ecx,%edx
  801949:	f7 da                	neg    %edx
  80194b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80194f:	0f 45 c2             	cmovne %edx,%eax
}
  801952:	83 c4 04             	add    $0x4,%esp
  801955:	5b                   	pop    %ebx
  801956:	5e                   	pop    %esi
  801957:	5f                   	pop    %edi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    
  80195a:	00 00                	add    %al,(%eax)
  80195c:	00 00                	add    %al,(%eax)
	...

00801960 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801966:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80196c:	b8 01 00 00 00       	mov    $0x1,%eax
  801971:	39 ca                	cmp    %ecx,%edx
  801973:	75 04                	jne    801979 <ipc_find_env+0x19>
  801975:	b0 00                	mov    $0x0,%al
  801977:	eb 0f                	jmp    801988 <ipc_find_env+0x28>
  801979:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80197c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801982:	8b 12                	mov    (%edx),%edx
  801984:	39 ca                	cmp    %ecx,%edx
  801986:	75 0c                	jne    801994 <ipc_find_env+0x34>
			return envs[i].env_id;
  801988:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80198b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801990:	8b 00                	mov    (%eax),%eax
  801992:	eb 0e                	jmp    8019a2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801994:	83 c0 01             	add    $0x1,%eax
  801997:	3d 00 04 00 00       	cmp    $0x400,%eax
  80199c:	75 db                	jne    801979 <ipc_find_env+0x19>
  80199e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8019a2:	5d                   	pop    %ebp
  8019a3:	c3                   	ret    

008019a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8019a4:	55                   	push   %ebp
  8019a5:	89 e5                	mov    %esp,%ebp
  8019a7:	57                   	push   %edi
  8019a8:	56                   	push   %esi
  8019a9:	53                   	push   %ebx
  8019aa:	83 ec 1c             	sub    $0x1c,%esp
  8019ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8019b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8019b6:	85 db                	test   %ebx,%ebx
  8019b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8019bd:	0f 44 d8             	cmove  %eax,%ebx
  8019c0:	eb 29                	jmp    8019eb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	79 25                	jns    8019eb <ipc_send+0x47>
  8019c6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019c9:	74 20                	je     8019eb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  8019cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019cf:	c7 44 24 08 c0 21 80 	movl   $0x8021c0,0x8(%esp)
  8019d6:	00 
  8019d7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8019de:	00 
  8019df:	c7 04 24 de 21 80 00 	movl   $0x8021de,(%esp)
  8019e6:	e8 85 f3 ff ff       	call   800d70 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8019eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019fa:	89 34 24             	mov    %esi,(%esp)
  8019fd:	e8 91 e7 ff ff       	call   800193 <sys_ipc_try_send>
  801a02:	85 c0                	test   %eax,%eax
  801a04:	75 bc                	jne    8019c2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801a06:	e8 0e e9 ff ff       	call   800319 <sys_yield>
}
  801a0b:	83 c4 1c             	add    $0x1c,%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5f                   	pop    %edi
  801a11:	5d                   	pop    %ebp
  801a12:	c3                   	ret    

00801a13 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 28             	sub    $0x28,%esp
  801a19:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a1c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a1f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a22:	8b 75 08             	mov    0x8(%ebp),%esi
  801a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a28:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a32:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801a35:	89 04 24             	mov    %eax,(%esp)
  801a38:	e8 1d e7 ff ff       	call   80015a <sys_ipc_recv>
  801a3d:	89 c3                	mov    %eax,%ebx
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	79 2a                	jns    801a6d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801a43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	c7 04 24 e8 21 80 00 	movl   $0x8021e8,(%esp)
  801a52:	e8 d2 f3 ff ff       	call   800e29 <cprintf>
		if(from_env_store != NULL)
  801a57:	85 f6                	test   %esi,%esi
  801a59:	74 06                	je     801a61 <ipc_recv+0x4e>
			*from_env_store = 0;
  801a5b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801a61:	85 ff                	test   %edi,%edi
  801a63:	74 2d                	je     801a92 <ipc_recv+0x7f>
			*perm_store = 0;
  801a65:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a6b:	eb 25                	jmp    801a92 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801a6d:	85 f6                	test   %esi,%esi
  801a6f:	90                   	nop
  801a70:	74 0a                	je     801a7c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801a72:	a1 04 40 80 00       	mov    0x804004,%eax
  801a77:	8b 40 74             	mov    0x74(%eax),%eax
  801a7a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801a7c:	85 ff                	test   %edi,%edi
  801a7e:	74 0a                	je     801a8a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801a80:	a1 04 40 80 00       	mov    0x804004,%eax
  801a85:	8b 40 78             	mov    0x78(%eax),%eax
  801a88:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a8a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a8f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801a92:	89 d8                	mov    %ebx,%eax
  801a94:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a97:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a9a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a9d:	89 ec                	mov    %ebp,%esp
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    
	...

00801ab0 <__udivdi3>:
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	57                   	push   %edi
  801ab4:	56                   	push   %esi
  801ab5:	83 ec 10             	sub    $0x10,%esp
  801ab8:	8b 45 14             	mov    0x14(%ebp),%eax
  801abb:	8b 55 08             	mov    0x8(%ebp),%edx
  801abe:	8b 75 10             	mov    0x10(%ebp),%esi
  801ac1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ac4:	85 c0                	test   %eax,%eax
  801ac6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ac9:	75 35                	jne    801b00 <__udivdi3+0x50>
  801acb:	39 fe                	cmp    %edi,%esi
  801acd:	77 61                	ja     801b30 <__udivdi3+0x80>
  801acf:	85 f6                	test   %esi,%esi
  801ad1:	75 0b                	jne    801ade <__udivdi3+0x2e>
  801ad3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad8:	31 d2                	xor    %edx,%edx
  801ada:	f7 f6                	div    %esi
  801adc:	89 c6                	mov    %eax,%esi
  801ade:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ae1:	31 d2                	xor    %edx,%edx
  801ae3:	89 f8                	mov    %edi,%eax
  801ae5:	f7 f6                	div    %esi
  801ae7:	89 c7                	mov    %eax,%edi
  801ae9:	89 c8                	mov    %ecx,%eax
  801aeb:	f7 f6                	div    %esi
  801aed:	89 c1                	mov    %eax,%ecx
  801aef:	89 fa                	mov    %edi,%edx
  801af1:	89 c8                	mov    %ecx,%eax
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	5e                   	pop    %esi
  801af7:	5f                   	pop    %edi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    
  801afa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b00:	39 f8                	cmp    %edi,%eax
  801b02:	77 1c                	ja     801b20 <__udivdi3+0x70>
  801b04:	0f bd d0             	bsr    %eax,%edx
  801b07:	83 f2 1f             	xor    $0x1f,%edx
  801b0a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b0d:	75 39                	jne    801b48 <__udivdi3+0x98>
  801b0f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801b12:	0f 86 a0 00 00 00    	jbe    801bb8 <__udivdi3+0x108>
  801b18:	39 f8                	cmp    %edi,%eax
  801b1a:	0f 82 98 00 00 00    	jb     801bb8 <__udivdi3+0x108>
  801b20:	31 ff                	xor    %edi,%edi
  801b22:	31 c9                	xor    %ecx,%ecx
  801b24:	89 c8                	mov    %ecx,%eax
  801b26:	89 fa                	mov    %edi,%edx
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	5e                   	pop    %esi
  801b2c:	5f                   	pop    %edi
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    
  801b2f:	90                   	nop
  801b30:	89 d1                	mov    %edx,%ecx
  801b32:	89 fa                	mov    %edi,%edx
  801b34:	89 c8                	mov    %ecx,%eax
  801b36:	31 ff                	xor    %edi,%edi
  801b38:	f7 f6                	div    %esi
  801b3a:	89 c1                	mov    %eax,%ecx
  801b3c:	89 fa                	mov    %edi,%edx
  801b3e:	89 c8                	mov    %ecx,%eax
  801b40:	83 c4 10             	add    $0x10,%esp
  801b43:	5e                   	pop    %esi
  801b44:	5f                   	pop    %edi
  801b45:	5d                   	pop    %ebp
  801b46:	c3                   	ret    
  801b47:	90                   	nop
  801b48:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b4c:	89 f2                	mov    %esi,%edx
  801b4e:	d3 e0                	shl    %cl,%eax
  801b50:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b53:	b8 20 00 00 00       	mov    $0x20,%eax
  801b58:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b5b:	89 c1                	mov    %eax,%ecx
  801b5d:	d3 ea                	shr    %cl,%edx
  801b5f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b63:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b66:	d3 e6                	shl    %cl,%esi
  801b68:	89 c1                	mov    %eax,%ecx
  801b6a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b6d:	89 fe                	mov    %edi,%esi
  801b6f:	d3 ee                	shr    %cl,%esi
  801b71:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b75:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b7b:	d3 e7                	shl    %cl,%edi
  801b7d:	89 c1                	mov    %eax,%ecx
  801b7f:	d3 ea                	shr    %cl,%edx
  801b81:	09 d7                	or     %edx,%edi
  801b83:	89 f2                	mov    %esi,%edx
  801b85:	89 f8                	mov    %edi,%eax
  801b87:	f7 75 ec             	divl   -0x14(%ebp)
  801b8a:	89 d6                	mov    %edx,%esi
  801b8c:	89 c7                	mov    %eax,%edi
  801b8e:	f7 65 e8             	mull   -0x18(%ebp)
  801b91:	39 d6                	cmp    %edx,%esi
  801b93:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b96:	72 30                	jb     801bc8 <__udivdi3+0x118>
  801b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b9b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b9f:	d3 e2                	shl    %cl,%edx
  801ba1:	39 c2                	cmp    %eax,%edx
  801ba3:	73 05                	jae    801baa <__udivdi3+0xfa>
  801ba5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801ba8:	74 1e                	je     801bc8 <__udivdi3+0x118>
  801baa:	89 f9                	mov    %edi,%ecx
  801bac:	31 ff                	xor    %edi,%edi
  801bae:	e9 71 ff ff ff       	jmp    801b24 <__udivdi3+0x74>
  801bb3:	90                   	nop
  801bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	31 ff                	xor    %edi,%edi
  801bba:	b9 01 00 00 00       	mov    $0x1,%ecx
  801bbf:	e9 60 ff ff ff       	jmp    801b24 <__udivdi3+0x74>
  801bc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bc8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801bcb:	31 ff                	xor    %edi,%edi
  801bcd:	89 c8                	mov    %ecx,%eax
  801bcf:	89 fa                	mov    %edi,%edx
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	5e                   	pop    %esi
  801bd5:	5f                   	pop    %edi
  801bd6:	5d                   	pop    %ebp
  801bd7:	c3                   	ret    
	...

00801be0 <__umoddi3>:
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	57                   	push   %edi
  801be4:	56                   	push   %esi
  801be5:	83 ec 20             	sub    $0x20,%esp
  801be8:	8b 55 14             	mov    0x14(%ebp),%edx
  801beb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bee:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bf1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bf4:	85 d2                	test   %edx,%edx
  801bf6:	89 c8                	mov    %ecx,%eax
  801bf8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bfb:	75 13                	jne    801c10 <__umoddi3+0x30>
  801bfd:	39 f7                	cmp    %esi,%edi
  801bff:	76 3f                	jbe    801c40 <__umoddi3+0x60>
  801c01:	89 f2                	mov    %esi,%edx
  801c03:	f7 f7                	div    %edi
  801c05:	89 d0                	mov    %edx,%eax
  801c07:	31 d2                	xor    %edx,%edx
  801c09:	83 c4 20             	add    $0x20,%esp
  801c0c:	5e                   	pop    %esi
  801c0d:	5f                   	pop    %edi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    
  801c10:	39 f2                	cmp    %esi,%edx
  801c12:	77 4c                	ja     801c60 <__umoddi3+0x80>
  801c14:	0f bd ca             	bsr    %edx,%ecx
  801c17:	83 f1 1f             	xor    $0x1f,%ecx
  801c1a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c1d:	75 51                	jne    801c70 <__umoddi3+0x90>
  801c1f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801c22:	0f 87 e0 00 00 00    	ja     801d08 <__umoddi3+0x128>
  801c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2b:	29 f8                	sub    %edi,%eax
  801c2d:	19 d6                	sbb    %edx,%esi
  801c2f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c35:	89 f2                	mov    %esi,%edx
  801c37:	83 c4 20             	add    $0x20,%esp
  801c3a:	5e                   	pop    %esi
  801c3b:	5f                   	pop    %edi
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    
  801c3e:	66 90                	xchg   %ax,%ax
  801c40:	85 ff                	test   %edi,%edi
  801c42:	75 0b                	jne    801c4f <__umoddi3+0x6f>
  801c44:	b8 01 00 00 00       	mov    $0x1,%eax
  801c49:	31 d2                	xor    %edx,%edx
  801c4b:	f7 f7                	div    %edi
  801c4d:	89 c7                	mov    %eax,%edi
  801c4f:	89 f0                	mov    %esi,%eax
  801c51:	31 d2                	xor    %edx,%edx
  801c53:	f7 f7                	div    %edi
  801c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c58:	f7 f7                	div    %edi
  801c5a:	eb a9                	jmp    801c05 <__umoddi3+0x25>
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 c8                	mov    %ecx,%eax
  801c62:	89 f2                	mov    %esi,%edx
  801c64:	83 c4 20             	add    $0x20,%esp
  801c67:	5e                   	pop    %esi
  801c68:	5f                   	pop    %edi
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    
  801c6b:	90                   	nop
  801c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c74:	d3 e2                	shl    %cl,%edx
  801c76:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c79:	ba 20 00 00 00       	mov    $0x20,%edx
  801c7e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c81:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c84:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	d3 ea                	shr    %cl,%edx
  801c8c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c90:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c93:	d3 e7                	shl    %cl,%edi
  801c95:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c99:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c9c:	89 f2                	mov    %esi,%edx
  801c9e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801ca1:	89 c7                	mov    %eax,%edi
  801ca3:	d3 ea                	shr    %cl,%edx
  801ca5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ca9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801cac:	89 c2                	mov    %eax,%edx
  801cae:	d3 e6                	shl    %cl,%esi
  801cb0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cb4:	d3 ea                	shr    %cl,%edx
  801cb6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cba:	09 d6                	or     %edx,%esi
  801cbc:	89 f0                	mov    %esi,%eax
  801cbe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801cc1:	d3 e7                	shl    %cl,%edi
  801cc3:	89 f2                	mov    %esi,%edx
  801cc5:	f7 75 f4             	divl   -0xc(%ebp)
  801cc8:	89 d6                	mov    %edx,%esi
  801cca:	f7 65 e8             	mull   -0x18(%ebp)
  801ccd:	39 d6                	cmp    %edx,%esi
  801ccf:	72 2b                	jb     801cfc <__umoddi3+0x11c>
  801cd1:	39 c7                	cmp    %eax,%edi
  801cd3:	72 23                	jb     801cf8 <__umoddi3+0x118>
  801cd5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cd9:	29 c7                	sub    %eax,%edi
  801cdb:	19 d6                	sbb    %edx,%esi
  801cdd:	89 f0                	mov    %esi,%eax
  801cdf:	89 f2                	mov    %esi,%edx
  801ce1:	d3 ef                	shr    %cl,%edi
  801ce3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ce7:	d3 e0                	shl    %cl,%eax
  801ce9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ced:	09 f8                	or     %edi,%eax
  801cef:	d3 ea                	shr    %cl,%edx
  801cf1:	83 c4 20             	add    $0x20,%esp
  801cf4:	5e                   	pop    %esi
  801cf5:	5f                   	pop    %edi
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    
  801cf8:	39 d6                	cmp    %edx,%esi
  801cfa:	75 d9                	jne    801cd5 <__umoddi3+0xf5>
  801cfc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801cff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801d02:	eb d1                	jmp    801cd5 <__umoddi3+0xf5>
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	0f 82 18 ff ff ff    	jb     801c28 <__umoddi3+0x48>
  801d10:	e9 1d ff ff ff       	jmp    801c32 <__umoddi3+0x52>
