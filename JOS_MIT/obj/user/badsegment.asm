
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800049:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800052:	e8 fd 02 00 00       	call   800354 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 f6                	test   %esi,%esi
  80006b:	7e 07                	jle    800074 <libmain+0x34>
		binaryname = argv[0];
  80006d:	8b 03                	mov    (%ebx),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800078:	89 34 24             	mov    %esi,(%esp)
  80007b:	e8 b4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800080:	e8 0b 00 00 00       	call   800090 <exit>
}
  800085:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800088:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008b:	89 ec                	mov    %ebp,%esp
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800096:	e8 8e 08 00 00       	call   800929 <close_all>
	sys_env_destroy(0);
  80009b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a2:	e8 e8 02 00 00       	call   80038f <sys_env_destroy>
}
  8000a7:	c9                   	leave  
  8000a8:	c3                   	ret    
  8000a9:	00 00                	add    %al,(%eax)
	...

008000ac <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 48             	sub    $0x48,%esp
  8000b2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000b5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000b8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000c0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cb:	51                   	push   %ecx
  8000cc:	52                   	push   %edx
  8000cd:	53                   	push   %ebx
  8000ce:	54                   	push   %esp
  8000cf:	55                   	push   %ebp
  8000d0:	56                   	push   %esi
  8000d1:	57                   	push   %edi
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	8d 35 dc 00 80 00    	lea    0x8000dc,%esi
  8000da:	0f 34                	sysenter 

008000dc <.after_sysenter_label>:
  8000dc:	5f                   	pop    %edi
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	5c                   	pop    %esp
  8000e0:	5b                   	pop    %ebx
  8000e1:	5a                   	pop    %edx
  8000e2:	59                   	pop    %ecx
  8000e3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e9:	74 28                	je     800113 <.after_sysenter_label+0x37>
  8000eb:	85 c0                	test   %eax,%eax
  8000ed:	7e 24                	jle    800113 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000f7:	c7 44 24 08 ea 1c 80 	movl   $0x801cea,0x8(%esp)
  8000fe:	00 
  8000ff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800106:	00 
  800107:	c7 04 24 07 1d 80 00 	movl   $0x801d07,(%esp)
  80010e:	e8 1d 0c 00 00       	call   800d30 <_panic>

	return ret;
}
  800113:	89 d0                	mov    %edx,%eax
  800115:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800118:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80011b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80011e:	89 ec                	mov    %ebp,%esp
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800128:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80012f:	00 
  800130:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800137:	00 
  800138:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80013f:	00 
  800140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800147:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80014a:	ba 01 00 00 00       	mov    $0x1,%edx
  80014f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800154:	e8 53 ff ff ff       	call   8000ac <syscall>
}
  800159:	c9                   	leave  
  80015a:	c3                   	ret    

0080015b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800161:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800168:	00 
  800169:	8b 45 14             	mov    0x14(%ebp),%eax
  80016c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800170:	8b 45 10             	mov    0x10(%ebp),%eax
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	8b 45 0c             	mov    0xc(%ebp),%eax
  80017a:	89 04 24             	mov    %eax,(%esp)
  80017d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800180:	ba 00 00 00 00       	mov    $0x0,%edx
  800185:	b8 0d 00 00 00       	mov    $0xd,%eax
  80018a:	e8 1d ff ff ff       	call   8000ac <syscall>
}
  80018f:	c9                   	leave  
  800190:	c3                   	ret    

00800191 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800197:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80019e:	00 
  80019f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001a6:	00 
  8001a7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ae:	00 
  8001af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001b2:	89 04 24             	mov    %eax,(%esp)
  8001b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b8:	ba 01 00 00 00       	mov    $0x1,%edx
  8001bd:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c2:	e8 e5 fe ff ff       	call   8000ac <syscall>
}
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    

008001c9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001c9:	55                   	push   %ebp
  8001ca:	89 e5                	mov    %esp,%ebp
  8001cc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  8001f5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8001fa:	e8 ad fe ff ff       	call   8000ac <syscall>
}
  8001ff:	c9                   	leave  
  800200:	c3                   	ret    

00800201 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
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
  80022d:	b8 09 00 00 00       	mov    $0x9,%eax
  800232:	e8 75 fe ff ff       	call   8000ac <syscall>
}
  800237:	c9                   	leave  
  800238:	c3                   	ret    

00800239 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
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
  800265:	b8 07 00 00 00       	mov    $0x7,%eax
  80026a:	e8 3d fe ff ff       	call   8000ac <syscall>
}
  80026f:	c9                   	leave  
  800270:	c3                   	ret    

00800271 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800277:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80027e:	00 
  80027f:	8b 45 18             	mov    0x18(%ebp),%eax
  800282:	0b 45 14             	or     0x14(%ebp),%eax
  800285:	89 44 24 08          	mov    %eax,0x8(%esp)
  800289:	8b 45 10             	mov    0x10(%ebp),%eax
  80028c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800290:	8b 45 0c             	mov    0xc(%ebp),%eax
  800293:	89 04 24             	mov    %eax,(%esp)
  800296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800299:	ba 01 00 00 00       	mov    $0x1,%edx
  80029e:	b8 06 00 00 00       	mov    $0x6,%eax
  8002a3:	e8 04 fe ff ff       	call   8000ac <syscall>
}
  8002a8:	c9                   	leave  
  8002a9:	c3                   	ret    

008002aa <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002aa:	55                   	push   %ebp
  8002ab:	89 e5                	mov    %esp,%ebp
  8002ad:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8002b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b7:	00 
  8002b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002bf:	00 
  8002c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d0:	ba 01 00 00 00       	mov    $0x1,%edx
  8002d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8002da:	e8 cd fd ff ff       	call   8000ac <syscall>
}
  8002df:	c9                   	leave  
  8002e0:	c3                   	ret    

008002e1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8002e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ee:	00 
  8002ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002f6:	00 
  8002f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002fe:	00 
  8002ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800306:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030b:	ba 00 00 00 00       	mov    $0x0,%edx
  800310:	b8 0c 00 00 00       	mov    $0xc,%eax
  800315:	e8 92 fd ff ff       	call   8000ac <syscall>
}
  80031a:	c9                   	leave  
  80031b:	c3                   	ret    

0080031c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80031c:	55                   	push   %ebp
  80031d:	89 e5                	mov    %esp,%ebp
  80031f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800322:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800329:	00 
  80032a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800331:	00 
  800332:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800339:	00 
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80033d:	89 04 24             	mov    %eax,(%esp)
  800340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800343:	ba 00 00 00 00       	mov    $0x0,%edx
  800348:	b8 04 00 00 00       	mov    $0x4,%eax
  80034d:	e8 5a fd ff ff       	call   8000ac <syscall>
}
  800352:	c9                   	leave  
  800353:	c3                   	ret    

00800354 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80035a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800361:	00 
  800362:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800369:	00 
  80036a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800371:	00 
  800372:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	ba 00 00 00 00       	mov    $0x0,%edx
  800383:	b8 02 00 00 00       	mov    $0x2,%eax
  800388:	e8 1f fd ff ff       	call   8000ac <syscall>
}
  80038d:	c9                   	leave  
  80038e:	c3                   	ret    

0080038f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800395:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039c:	00 
  80039d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003a4:	00 
  8003a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003ac:	00 
  8003ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b7:	ba 01 00 00 00       	mov    $0x1,%edx
  8003bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8003c1:	e8 e6 fc ff ff       	call   8000ac <syscall>
}
  8003c6:	c9                   	leave  
  8003c7:	c3                   	ret    

008003c8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
  8003cb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8003ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003d5:	00 
  8003d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003dd:	00 
  8003de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e5:	00 
  8003e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8003fc:	e8 ab fc ff ff       	call   8000ac <syscall>
}
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800409:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800410:	00 
  800411:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800418:	00 
  800419:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800420:	00 
  800421:	8b 45 0c             	mov    0xc(%ebp),%eax
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042a:	ba 00 00 00 00       	mov    $0x0,%edx
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	e8 73 fc ff ff       	call   8000ac <syscall>
}
  800439:	c9                   	leave  
  80043a:	c3                   	ret    
  80043b:	00 00                	add    %al,(%eax)
  80043d:	00 00                	add    %al,(%eax)
	...

00800440 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800440:	55                   	push   %ebp
  800441:	89 e5                	mov    %esp,%ebp
  800443:	8b 45 08             	mov    0x8(%ebp),%eax
  800446:	05 00 00 00 30       	add    $0x30000000,%eax
  80044b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800456:	8b 45 08             	mov    0x8(%ebp),%eax
  800459:	89 04 24             	mov    %eax,(%esp)
  80045c:	e8 df ff ff ff       	call   800440 <fd2num>
  800461:	05 20 00 0d 00       	add    $0xd0020,%eax
  800466:	c1 e0 0c             	shl    $0xc,%eax
}
  800469:	c9                   	leave  
  80046a:	c3                   	ret    

0080046b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	57                   	push   %edi
  80046f:	56                   	push   %esi
  800470:	53                   	push   %ebx
  800471:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800474:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800479:	a8 01                	test   $0x1,%al
  80047b:	74 36                	je     8004b3 <fd_alloc+0x48>
  80047d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800482:	a8 01                	test   $0x1,%al
  800484:	74 2d                	je     8004b3 <fd_alloc+0x48>
  800486:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80048b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800490:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800495:	89 c3                	mov    %eax,%ebx
  800497:	89 c2                	mov    %eax,%edx
  800499:	c1 ea 16             	shr    $0x16,%edx
  80049c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80049f:	f6 c2 01             	test   $0x1,%dl
  8004a2:	74 14                	je     8004b8 <fd_alloc+0x4d>
  8004a4:	89 c2                	mov    %eax,%edx
  8004a6:	c1 ea 0c             	shr    $0xc,%edx
  8004a9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8004ac:	f6 c2 01             	test   $0x1,%dl
  8004af:	75 10                	jne    8004c1 <fd_alloc+0x56>
  8004b1:	eb 05                	jmp    8004b8 <fd_alloc+0x4d>
  8004b3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8004b8:	89 1f                	mov    %ebx,(%edi)
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8004bf:	eb 17                	jmp    8004d8 <fd_alloc+0x6d>
  8004c1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004c6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004cb:	75 c8                	jne    800495 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004cd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8004d3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8004d8:	5b                   	pop    %ebx
  8004d9:	5e                   	pop    %esi
  8004da:	5f                   	pop    %edi
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e3:	83 f8 1f             	cmp    $0x1f,%eax
  8004e6:	77 36                	ja     80051e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004e8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8004ed:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8004f0:	89 c2                	mov    %eax,%edx
  8004f2:	c1 ea 16             	shr    $0x16,%edx
  8004f5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8004fc:	f6 c2 01             	test   $0x1,%dl
  8004ff:	74 1d                	je     80051e <fd_lookup+0x41>
  800501:	89 c2                	mov    %eax,%edx
  800503:	c1 ea 0c             	shr    $0xc,%edx
  800506:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80050d:	f6 c2 01             	test   $0x1,%dl
  800510:	74 0c                	je     80051e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800512:	8b 55 0c             	mov    0xc(%ebp),%edx
  800515:	89 02                	mov    %eax,(%edx)
  800517:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80051c:	eb 05                	jmp    800523 <fd_lookup+0x46>
  80051e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80052e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800532:	8b 45 08             	mov    0x8(%ebp),%eax
  800535:	89 04 24             	mov    %eax,(%esp)
  800538:	e8 a0 ff ff ff       	call   8004dd <fd_lookup>
  80053d:	85 c0                	test   %eax,%eax
  80053f:	78 0e                	js     80054f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800541:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800544:	8b 55 0c             	mov    0xc(%ebp),%edx
  800547:	89 50 04             	mov    %edx,0x4(%eax)
  80054a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    

00800551 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	56                   	push   %esi
  800555:	53                   	push   %ebx
  800556:	83 ec 10             	sub    $0x10,%esp
  800559:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80055c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80055f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800564:	b8 04 30 80 00       	mov    $0x803004,%eax
  800569:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80056f:	75 11                	jne    800582 <dev_lookup+0x31>
  800571:	eb 04                	jmp    800577 <dev_lookup+0x26>
  800573:	39 08                	cmp    %ecx,(%eax)
  800575:	75 10                	jne    800587 <dev_lookup+0x36>
			*dev = devtab[i];
  800577:	89 03                	mov    %eax,(%ebx)
  800579:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80057e:	66 90                	xchg   %ax,%ax
  800580:	eb 36                	jmp    8005b8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800582:	be 94 1d 80 00       	mov    $0x801d94,%esi
  800587:	83 c2 01             	add    $0x1,%edx
  80058a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80058d:	85 c0                	test   %eax,%eax
  80058f:	75 e2                	jne    800573 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800591:	a1 04 40 80 00       	mov    0x804004,%eax
  800596:	8b 40 48             	mov    0x48(%eax),%eax
  800599:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80059d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005a1:	c7 04 24 18 1d 80 00 	movl   $0x801d18,(%esp)
  8005a8:	e8 3c 08 00 00       	call   800de9 <cprintf>
	*dev = 0;
  8005ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	5b                   	pop    %ebx
  8005bc:	5e                   	pop    %esi
  8005bd:	5d                   	pop    %ebp
  8005be:	c3                   	ret    

008005bf <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8005bf:	55                   	push   %ebp
  8005c0:	89 e5                	mov    %esp,%ebp
  8005c2:	53                   	push   %ebx
  8005c3:	83 ec 24             	sub    $0x24,%esp
  8005c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8005c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d3:	89 04 24             	mov    %eax,(%esp)
  8005d6:	e8 02 ff ff ff       	call   8004dd <fd_lookup>
  8005db:	85 c0                	test   %eax,%eax
  8005dd:	78 53                	js     800632 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8005df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 5e ff ff ff       	call   800551 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8005f3:	85 c0                	test   %eax,%eax
  8005f5:	78 3b                	js     800632 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8005f7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8005fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ff:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800603:	74 2d                	je     800632 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800605:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800608:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80060f:	00 00 00 
	stat->st_isdir = 0;
  800612:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800619:	00 00 00 
	stat->st_dev = dev;
  80061c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80061f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800625:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800629:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80062c:	89 14 24             	mov    %edx,(%esp)
  80062f:	ff 50 14             	call   *0x14(%eax)
}
  800632:	83 c4 24             	add    $0x24,%esp
  800635:	5b                   	pop    %ebx
  800636:	5d                   	pop    %ebp
  800637:	c3                   	ret    

00800638 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	53                   	push   %ebx
  80063c:	83 ec 24             	sub    $0x24,%esp
  80063f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800642:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800645:	89 44 24 04          	mov    %eax,0x4(%esp)
  800649:	89 1c 24             	mov    %ebx,(%esp)
  80064c:	e8 8c fe ff ff       	call   8004dd <fd_lookup>
  800651:	85 c0                	test   %eax,%eax
  800653:	78 5f                	js     8006b4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800655:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800658:	89 44 24 04          	mov    %eax,0x4(%esp)
  80065c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 04 24             	mov    %eax,(%esp)
  800664:	e8 e8 fe ff ff       	call   800551 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800669:	85 c0                	test   %eax,%eax
  80066b:	78 47                	js     8006b4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80066d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800670:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800674:	75 23                	jne    800699 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800682:	89 44 24 04          	mov    %eax,0x4(%esp)
  800686:	c7 04 24 38 1d 80 00 	movl   $0x801d38,(%esp)
  80068d:	e8 57 07 00 00       	call   800de9 <cprintf>
  800692:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800697:	eb 1b                	jmp    8006b4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069c:	8b 48 18             	mov    0x18(%eax),%ecx
  80069f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	74 0c                	je     8006b4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8006a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006af:	89 14 24             	mov    %edx,(%esp)
  8006b2:	ff d1                	call   *%ecx
}
  8006b4:	83 c4 24             	add    $0x24,%esp
  8006b7:	5b                   	pop    %ebx
  8006b8:	5d                   	pop    %ebp
  8006b9:	c3                   	ret    

008006ba <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ba:	55                   	push   %ebp
  8006bb:	89 e5                	mov    %esp,%ebp
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 24             	sub    $0x24,%esp
  8006c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006cb:	89 1c 24             	mov    %ebx,(%esp)
  8006ce:	e8 0a fe ff ff       	call   8004dd <fd_lookup>
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	78 66                	js     80073d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006e1:	8b 00                	mov    (%eax),%eax
  8006e3:	89 04 24             	mov    %eax,(%esp)
  8006e6:	e8 66 fe ff ff       	call   800551 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	78 4e                	js     80073d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006f2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8006f6:	75 23                	jne    80071b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8006f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8006fd:	8b 40 48             	mov    0x48(%eax),%eax
  800700:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800704:	89 44 24 04          	mov    %eax,0x4(%esp)
  800708:	c7 04 24 59 1d 80 00 	movl   $0x801d59,(%esp)
  80070f:	e8 d5 06 00 00       	call   800de9 <cprintf>
  800714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800719:	eb 22                	jmp    80073d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80071b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071e:	8b 48 0c             	mov    0xc(%eax),%ecx
  800721:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800726:	85 c9                	test   %ecx,%ecx
  800728:	74 13                	je     80073d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80072a:	8b 45 10             	mov    0x10(%ebp),%eax
  80072d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800731:	8b 45 0c             	mov    0xc(%ebp),%eax
  800734:	89 44 24 04          	mov    %eax,0x4(%esp)
  800738:	89 14 24             	mov    %edx,(%esp)
  80073b:	ff d1                	call   *%ecx
}
  80073d:	83 c4 24             	add    $0x24,%esp
  800740:	5b                   	pop    %ebx
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	83 ec 24             	sub    $0x24,%esp
  80074a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80074d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800750:	89 44 24 04          	mov    %eax,0x4(%esp)
  800754:	89 1c 24             	mov    %ebx,(%esp)
  800757:	e8 81 fd ff ff       	call   8004dd <fd_lookup>
  80075c:	85 c0                	test   %eax,%eax
  80075e:	78 6b                	js     8007cb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800760:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800763:	89 44 24 04          	mov    %eax,0x4(%esp)
  800767:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076a:	8b 00                	mov    (%eax),%eax
  80076c:	89 04 24             	mov    %eax,(%esp)
  80076f:	e8 dd fd ff ff       	call   800551 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800774:	85 c0                	test   %eax,%eax
  800776:	78 53                	js     8007cb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800778:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80077b:	8b 42 08             	mov    0x8(%edx),%eax
  80077e:	83 e0 03             	and    $0x3,%eax
  800781:	83 f8 01             	cmp    $0x1,%eax
  800784:	75 23                	jne    8007a9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800786:	a1 04 40 80 00       	mov    0x804004,%eax
  80078b:	8b 40 48             	mov    0x48(%eax),%eax
  80078e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800792:	89 44 24 04          	mov    %eax,0x4(%esp)
  800796:	c7 04 24 76 1d 80 00 	movl   $0x801d76,(%esp)
  80079d:	e8 47 06 00 00       	call   800de9 <cprintf>
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8007a7:	eb 22                	jmp    8007cb <read+0x88>
	}
	if (!dev->dev_read)
  8007a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ac:	8b 48 08             	mov    0x8(%eax),%ecx
  8007af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007b4:	85 c9                	test   %ecx,%ecx
  8007b6:	74 13                	je     8007cb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c6:	89 14 24             	mov    %edx,(%esp)
  8007c9:	ff d1                	call   *%ecx
}
  8007cb:	83 c4 24             	add    $0x24,%esp
  8007ce:	5b                   	pop    %ebx
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	57                   	push   %edi
  8007d5:	56                   	push   %esi
  8007d6:	53                   	push   %ebx
  8007d7:	83 ec 1c             	sub    $0x1c,%esp
  8007da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007dd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	85 f6                	test   %esi,%esi
  8007f1:	74 29                	je     80081c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8007f3:	89 f0                	mov    %esi,%eax
  8007f5:	29 d0                	sub    %edx,%eax
  8007f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007fb:	03 55 0c             	add    0xc(%ebp),%edx
  8007fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800802:	89 3c 24             	mov    %edi,(%esp)
  800805:	e8 39 ff ff ff       	call   800743 <read>
		if (m < 0)
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 0e                	js     80081c <readn+0x4b>
			return m;
		if (m == 0)
  80080e:	85 c0                	test   %eax,%eax
  800810:	74 08                	je     80081a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800812:	01 c3                	add    %eax,%ebx
  800814:	89 da                	mov    %ebx,%edx
  800816:	39 f3                	cmp    %esi,%ebx
  800818:	72 d9                	jb     8007f3 <readn+0x22>
  80081a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80081c:	83 c4 1c             	add    $0x1c,%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	83 ec 28             	sub    $0x28,%esp
  80082a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80082d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800830:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800833:	89 34 24             	mov    %esi,(%esp)
  800836:	e8 05 fc ff ff       	call   800440 <fd2num>
  80083b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80083e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800842:	89 04 24             	mov    %eax,(%esp)
  800845:	e8 93 fc ff ff       	call   8004dd <fd_lookup>
  80084a:	89 c3                	mov    %eax,%ebx
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 05                	js     800855 <fd_close+0x31>
  800850:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800853:	74 0e                	je     800863 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800855:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800859:	b8 00 00 00 00       	mov    $0x0,%eax
  80085e:	0f 44 d8             	cmove  %eax,%ebx
  800861:	eb 3d                	jmp    8008a0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800866:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086a:	8b 06                	mov    (%esi),%eax
  80086c:	89 04 24             	mov    %eax,(%esp)
  80086f:	e8 dd fc ff ff       	call   800551 <dev_lookup>
  800874:	89 c3                	mov    %eax,%ebx
  800876:	85 c0                	test   %eax,%eax
  800878:	78 16                	js     800890 <fd_close+0x6c>
		if (dev->dev_close)
  80087a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80087d:	8b 40 10             	mov    0x10(%eax),%eax
  800880:	bb 00 00 00 00       	mov    $0x0,%ebx
  800885:	85 c0                	test   %eax,%eax
  800887:	74 07                	je     800890 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800889:	89 34 24             	mov    %esi,(%esp)
  80088c:	ff d0                	call   *%eax
  80088e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800890:	89 74 24 04          	mov    %esi,0x4(%esp)
  800894:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80089b:	e8 99 f9 ff ff       	call   800239 <sys_page_unmap>
	return r;
}
  8008a0:	89 d8                	mov    %ebx,%eax
  8008a2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8008a5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8008a8:	89 ec                	mov    %ebp,%esp
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	89 04 24             	mov    %eax,(%esp)
  8008bf:	e8 19 fc ff ff       	call   8004dd <fd_lookup>
  8008c4:	85 c0                	test   %eax,%eax
  8008c6:	78 13                	js     8008db <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8008c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8008cf:	00 
  8008d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d3:	89 04 24             	mov    %eax,(%esp)
  8008d6:	e8 49 ff ff ff       	call   800824 <fd_close>
}
  8008db:	c9                   	leave  
  8008dc:	c3                   	ret    

008008dd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	83 ec 18             	sub    $0x18,%esp
  8008e3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8008e6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8008f0:	00 
  8008f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f4:	89 04 24             	mov    %eax,(%esp)
  8008f7:	e8 78 03 00 00       	call   800c74 <open>
  8008fc:	89 c3                	mov    %eax,%ebx
  8008fe:	85 c0                	test   %eax,%eax
  800900:	78 1b                	js     80091d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800902:	8b 45 0c             	mov    0xc(%ebp),%eax
  800905:	89 44 24 04          	mov    %eax,0x4(%esp)
  800909:	89 1c 24             	mov    %ebx,(%esp)
  80090c:	e8 ae fc ff ff       	call   8005bf <fstat>
  800911:	89 c6                	mov    %eax,%esi
	close(fd);
  800913:	89 1c 24             	mov    %ebx,(%esp)
  800916:	e8 91 ff ff ff       	call   8008ac <close>
  80091b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80091d:	89 d8                	mov    %ebx,%eax
  80091f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800922:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800925:	89 ec                	mov    %ebp,%esp
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	53                   	push   %ebx
  80092d:	83 ec 14             	sub    $0x14,%esp
  800930:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800935:	89 1c 24             	mov    %ebx,(%esp)
  800938:	e8 6f ff ff ff       	call   8008ac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80093d:	83 c3 01             	add    $0x1,%ebx
  800940:	83 fb 20             	cmp    $0x20,%ebx
  800943:	75 f0                	jne    800935 <close_all+0xc>
		close(i);
}
  800945:	83 c4 14             	add    $0x14,%esp
  800948:	5b                   	pop    %ebx
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	83 ec 58             	sub    $0x58,%esp
  800951:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800954:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800957:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80095a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80095d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800960:	89 44 24 04          	mov    %eax,0x4(%esp)
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	89 04 24             	mov    %eax,(%esp)
  80096a:	e8 6e fb ff ff       	call   8004dd <fd_lookup>
  80096f:	89 c3                	mov    %eax,%ebx
  800971:	85 c0                	test   %eax,%eax
  800973:	0f 88 e0 00 00 00    	js     800a59 <dup+0x10e>
		return r;
	close(newfdnum);
  800979:	89 3c 24             	mov    %edi,(%esp)
  80097c:	e8 2b ff ff ff       	call   8008ac <close>

	newfd = INDEX2FD(newfdnum);
  800981:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800987:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80098a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80098d:	89 04 24             	mov    %eax,(%esp)
  800990:	e8 bb fa ff ff       	call   800450 <fd2data>
  800995:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800997:	89 34 24             	mov    %esi,(%esp)
  80099a:	e8 b1 fa ff ff       	call   800450 <fd2data>
  80099f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8009a2:	89 da                	mov    %ebx,%edx
  8009a4:	89 d8                	mov    %ebx,%eax
  8009a6:	c1 e8 16             	shr    $0x16,%eax
  8009a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009b0:	a8 01                	test   $0x1,%al
  8009b2:	74 43                	je     8009f7 <dup+0xac>
  8009b4:	c1 ea 0c             	shr    $0xc,%edx
  8009b7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8009be:	a8 01                	test   $0x1,%al
  8009c0:	74 35                	je     8009f7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009c2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8009c9:	25 07 0e 00 00       	and    $0xe07,%eax
  8009ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009d2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8009e0:	00 
  8009e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009ec:	e8 80 f8 ff ff       	call   800271 <sys_page_map>
  8009f1:	89 c3                	mov    %eax,%ebx
  8009f3:	85 c0                	test   %eax,%eax
  8009f5:	78 3f                	js     800a36 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8009f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	c1 ea 0c             	shr    $0xc,%edx
  8009ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a06:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a0c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a10:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a14:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a1b:	00 
  800a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a27:	e8 45 f8 ff ff       	call   800271 <sys_page_map>
  800a2c:	89 c3                	mov    %eax,%ebx
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 04                	js     800a36 <dup+0xeb>
  800a32:	89 fb                	mov    %edi,%ebx
  800a34:	eb 23                	jmp    800a59 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a36:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a41:	e8 f3 f7 ff ff       	call   800239 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a46:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a54:	e8 e0 f7 ff ff       	call   800239 <sys_page_unmap>
	return r;
}
  800a59:	89 d8                	mov    %ebx,%eax
  800a5b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a5e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a61:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a64:	89 ec                	mov    %ebp,%esp
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	83 ec 18             	sub    $0x18,%esp
  800a6e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800a71:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800a74:	89 c3                	mov    %eax,%ebx
  800a76:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a78:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a7f:	75 11                	jne    800a92 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a81:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a88:	e8 93 0e 00 00       	call   801920 <ipc_find_env>
  800a8d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800a92:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800a99:	00 
  800a9a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800aa1:	00 
  800aa2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa6:	a1 00 40 80 00       	mov    0x804000,%eax
  800aab:	89 04 24             	mov    %eax,(%esp)
  800aae:	e8 b1 0e 00 00       	call   801964 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ab3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800aba:	00 
  800abb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800abf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ac6:	e8 08 0f 00 00       	call   8019d3 <ipc_recv>
}
  800acb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ace:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ad1:	89 ec                	mov    %ebp,%esp
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 40 0c             	mov    0xc(%eax),%eax
  800ae1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ae6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800aee:	ba 00 00 00 00       	mov    $0x0,%edx
  800af3:	b8 02 00 00 00       	mov    $0x2,%eax
  800af8:	e8 6b ff ff ff       	call   800a68 <fsipc>
}
  800afd:	c9                   	leave  
  800afe:	c3                   	ret    

00800aff <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b05:	8b 45 08             	mov    0x8(%ebp),%eax
  800b08:	8b 40 0c             	mov    0xc(%eax),%eax
  800b0b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 06 00 00 00       	mov    $0x6,%eax
  800b1a:	e8 49 ff ff ff       	call   800a68 <fsipc>
}
  800b1f:	c9                   	leave  
  800b20:	c3                   	ret    

00800b21 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b27:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b31:	e8 32 ff ff ff       	call   800a68 <fsipc>
}
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	53                   	push   %ebx
  800b3c:	83 ec 14             	sub    $0x14,%esp
  800b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b42:	8b 45 08             	mov    0x8(%ebp),%eax
  800b45:	8b 40 0c             	mov    0xc(%eax),%eax
  800b48:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 05 00 00 00       	mov    $0x5,%eax
  800b57:	e8 0c ff ff ff       	call   800a68 <fsipc>
  800b5c:	85 c0                	test   %eax,%eax
  800b5e:	78 2b                	js     800b8b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b60:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b67:	00 
  800b68:	89 1c 24             	mov    %ebx,(%esp)
  800b6b:	e8 ba 09 00 00       	call   80152a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b70:	a1 80 50 80 00       	mov    0x805080,%eax
  800b75:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b7b:	a1 84 50 80 00       	mov    0x805084,%eax
  800b80:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800b86:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800b8b:	83 c4 14             	add    $0x14,%esp
  800b8e:	5b                   	pop    %ebx
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 18             	sub    $0x18,%esp
  800b97:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800b9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9d:	8b 52 0c             	mov    0xc(%edx),%edx
  800ba0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800ba6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800bab:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800bb0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800bb5:	0f 47 c2             	cmova  %edx,%eax
  800bb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bc3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800bca:	e8 46 0b 00 00       	call   801715 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd4:	b8 04 00 00 00       	mov    $0x4,%eax
  800bd9:	e8 8a fe ff ff       	call   800a68 <fsipc>
}
  800bde:	c9                   	leave  
  800bdf:	c3                   	ret    

00800be0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	53                   	push   %ebx
  800be4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	8b 40 0c             	mov    0xc(%eax),%eax
  800bed:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800bf2:	8b 45 10             	mov    0x10(%ebp),%eax
  800bf5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 03 00 00 00       	mov    $0x3,%eax
  800c04:	e8 5f fe ff ff       	call   800a68 <fsipc>
  800c09:	89 c3                	mov    %eax,%ebx
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	78 17                	js     800c26 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c13:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c1a:	00 
  800c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c1e:	89 04 24             	mov    %eax,(%esp)
  800c21:	e8 ef 0a 00 00       	call   801715 <memmove>
  return r;	
}
  800c26:	89 d8                	mov    %ebx,%eax
  800c28:	83 c4 14             	add    $0x14,%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	53                   	push   %ebx
  800c32:	83 ec 14             	sub    $0x14,%esp
  800c35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800c38:	89 1c 24             	mov    %ebx,(%esp)
  800c3b:	e8 a0 08 00 00       	call   8014e0 <strlen>
  800c40:	89 c2                	mov    %eax,%edx
  800c42:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800c47:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800c4d:	7f 1f                	jg     800c6e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800c4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c53:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c5a:	e8 cb 08 00 00       	call   80152a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 07 00 00 00       	mov    $0x7,%eax
  800c69:	e8 fa fd ff ff       	call   800a68 <fsipc>
}
  800c6e:	83 c4 14             	add    $0x14,%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	83 ec 28             	sub    $0x28,%esp
  800c7a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800c7d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800c80:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800c83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c86:	89 04 24             	mov    %eax,(%esp)
  800c89:	e8 dd f7 ff ff       	call   80046b <fd_alloc>
  800c8e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800c90:	85 c0                	test   %eax,%eax
  800c92:	0f 88 89 00 00 00    	js     800d21 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800c98:	89 34 24             	mov    %esi,(%esp)
  800c9b:	e8 40 08 00 00       	call   8014e0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800ca0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800ca5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800caa:	7f 75                	jg     800d21 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800cac:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cb7:	e8 6e 08 00 00       	call   80152a <strcpy>
  fsipcbuf.open.req_omode = mode;
  800cbc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cbf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800cc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cc7:	b8 01 00 00 00       	mov    $0x1,%eax
  800ccc:	e8 97 fd ff ff       	call   800a68 <fsipc>
  800cd1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800cd3:	85 c0                	test   %eax,%eax
  800cd5:	78 0f                	js     800ce6 <open+0x72>
  return fd2num(fd);
  800cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cda:	89 04 24             	mov    %eax,(%esp)
  800cdd:	e8 5e f7 ff ff       	call   800440 <fd2num>
  800ce2:	89 c3                	mov    %eax,%ebx
  800ce4:	eb 3b                	jmp    800d21 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800ce6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ced:	00 
  800cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cf1:	89 04 24             	mov    %eax,(%esp)
  800cf4:	e8 2b fb ff ff       	call   800824 <fd_close>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	74 24                	je     800d21 <open+0xad>
  800cfd:	c7 44 24 0c 9c 1d 80 	movl   $0x801d9c,0xc(%esp)
  800d04:	00 
  800d05:	c7 44 24 08 b1 1d 80 	movl   $0x801db1,0x8(%esp)
  800d0c:	00 
  800d0d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800d14:	00 
  800d15:	c7 04 24 c6 1d 80 00 	movl   $0x801dc6,(%esp)
  800d1c:	e8 0f 00 00 00       	call   800d30 <_panic>
  return r;
}
  800d21:	89 d8                	mov    %ebx,%eax
  800d23:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d26:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d29:	89 ec                	mov    %ebp,%esp
  800d2b:	5d                   	pop    %ebp
  800d2c:	c3                   	ret    
  800d2d:	00 00                	add    %al,(%eax)
	...

00800d30 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800d38:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d3b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800d41:	e8 0e f6 ff ff       	call   800354 <sys_getenvid>
  800d46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d49:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d50:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d54:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d58:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d5c:	c7 04 24 d4 1d 80 00 	movl   $0x801dd4,(%esp)
  800d63:	e8 81 00 00 00       	call   800de9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d68:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6f:	89 04 24             	mov    %eax,(%esp)
  800d72:	e8 11 00 00 00       	call   800d88 <vcprintf>
	cprintf("\n");
  800d77:	c7 04 24 90 1d 80 00 	movl   $0x801d90,(%esp)
  800d7e:	e8 66 00 00 00       	call   800de9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d83:	cc                   	int3   
  800d84:	eb fd                	jmp    800d83 <_panic+0x53>
	...

00800d88 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800d91:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800d98:	00 00 00 
	b.cnt = 0;
  800d9b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800da2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800da5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dac:	8b 45 08             	mov    0x8(%ebp),%eax
  800daf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800db3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800db9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dbd:	c7 04 24 03 0e 80 00 	movl   $0x800e03,(%esp)
  800dc4:	e8 d4 01 00 00       	call   800f9d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800dc9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dd3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800dd9:	89 04 24             	mov    %eax,(%esp)
  800ddc:	e8 22 f6 ff ff       	call   800403 <sys_cputs>

	return b.cnt;
}
  800de1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    

00800de9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800def:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800df2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800df6:	8b 45 08             	mov    0x8(%ebp),%eax
  800df9:	89 04 24             	mov    %eax,(%esp)
  800dfc:	e8 87 ff ff ff       	call   800d88 <vcprintf>
	va_end(ap);

	return cnt;
}
  800e01:	c9                   	leave  
  800e02:	c3                   	ret    

00800e03 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	53                   	push   %ebx
  800e07:	83 ec 14             	sub    $0x14,%esp
  800e0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800e0d:	8b 03                	mov    (%ebx),%eax
  800e0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e12:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800e16:	83 c0 01             	add    $0x1,%eax
  800e19:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800e1b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800e20:	75 19                	jne    800e3b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800e22:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800e29:	00 
  800e2a:	8d 43 08             	lea    0x8(%ebx),%eax
  800e2d:	89 04 24             	mov    %eax,(%esp)
  800e30:	e8 ce f5 ff ff       	call   800403 <sys_cputs>
		b->idx = 0;
  800e35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800e3b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800e3f:	83 c4 14             	add    $0x14,%esp
  800e42:	5b                   	pop    %ebx
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
	...

00800e50 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	57                   	push   %edi
  800e54:	56                   	push   %esi
  800e55:	53                   	push   %ebx
  800e56:	83 ec 4c             	sub    $0x4c,%esp
  800e59:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e5c:	89 d6                	mov    %edx,%esi
  800e5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e61:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e67:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e6a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800e70:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e73:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7b:	39 d1                	cmp    %edx,%ecx
  800e7d:	72 15                	jb     800e94 <printnum+0x44>
  800e7f:	77 07                	ja     800e88 <printnum+0x38>
  800e81:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800e84:	39 d0                	cmp    %edx,%eax
  800e86:	76 0c                	jbe    800e94 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e88:	83 eb 01             	sub    $0x1,%ebx
  800e8b:	85 db                	test   %ebx,%ebx
  800e8d:	8d 76 00             	lea    0x0(%esi),%esi
  800e90:	7f 61                	jg     800ef3 <printnum+0xa3>
  800e92:	eb 70                	jmp    800f04 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800e94:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800e98:	83 eb 01             	sub    $0x1,%ebx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ea3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ea7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  800eab:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800eae:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800eb1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800eb4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800eb8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ebf:	00 
  800ec0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ec3:	89 04 24             	mov    %eax,(%esp)
  800ec6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ec9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ecd:	e8 9e 0b 00 00       	call   801a70 <__udivdi3>
  800ed2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ed5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ed8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800edc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ee0:	89 04 24             	mov    %eax,(%esp)
  800ee3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ee7:	89 f2                	mov    %esi,%edx
  800ee9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800eec:	e8 5f ff ff ff       	call   800e50 <printnum>
  800ef1:	eb 11                	jmp    800f04 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800ef3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef7:	89 3c 24             	mov    %edi,(%esp)
  800efa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800efd:	83 eb 01             	sub    $0x1,%ebx
  800f00:	85 db                	test   %ebx,%ebx
  800f02:	7f ef                	jg     800ef3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f08:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f0f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f13:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1a:	00 
  800f1b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f1e:	89 14 24             	mov    %edx,(%esp)
  800f21:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f24:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f28:	e8 73 0c 00 00       	call   801ba0 <__umoddi3>
  800f2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f31:	0f be 80 f7 1d 80 00 	movsbl 0x801df7(%eax),%eax
  800f38:	89 04 24             	mov    %eax,(%esp)
  800f3b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800f3e:	83 c4 4c             	add    $0x4c,%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f49:	83 fa 01             	cmp    $0x1,%edx
  800f4c:	7e 0e                	jle    800f5c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f4e:	8b 10                	mov    (%eax),%edx
  800f50:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f53:	89 08                	mov    %ecx,(%eax)
  800f55:	8b 02                	mov    (%edx),%eax
  800f57:	8b 52 04             	mov    0x4(%edx),%edx
  800f5a:	eb 22                	jmp    800f7e <getuint+0x38>
	else if (lflag)
  800f5c:	85 d2                	test   %edx,%edx
  800f5e:	74 10                	je     800f70 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f60:	8b 10                	mov    (%eax),%edx
  800f62:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f65:	89 08                	mov    %ecx,(%eax)
  800f67:	8b 02                	mov    (%edx),%eax
  800f69:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6e:	eb 0e                	jmp    800f7e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f70:	8b 10                	mov    (%eax),%edx
  800f72:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f75:	89 08                	mov    %ecx,(%eax)
  800f77:	8b 02                	mov    (%edx),%eax
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800f86:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800f8a:	8b 10                	mov    (%eax),%edx
  800f8c:	3b 50 04             	cmp    0x4(%eax),%edx
  800f8f:	73 0a                	jae    800f9b <sprintputch+0x1b>
		*b->buf++ = ch;
  800f91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f94:	88 0a                	mov    %cl,(%edx)
  800f96:	83 c2 01             	add    $0x1,%edx
  800f99:	89 10                	mov    %edx,(%eax)
}
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
  800fa3:	83 ec 5c             	sub    $0x5c,%esp
  800fa6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fa9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fac:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800faf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800fb6:	eb 11                	jmp    800fc9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	0f 84 68 04 00 00    	je     801428 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800fc0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc4:	89 04 24             	mov    %eax,(%esp)
  800fc7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800fc9:	0f b6 03             	movzbl (%ebx),%eax
  800fcc:	83 c3 01             	add    $0x1,%ebx
  800fcf:	83 f8 25             	cmp    $0x25,%eax
  800fd2:	75 e4                	jne    800fb8 <vprintfmt+0x1b>
  800fd4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800fdb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800feb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800ff2:	eb 06                	jmp    800ffa <vprintfmt+0x5d>
  800ff4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800ff8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ffa:	0f b6 13             	movzbl (%ebx),%edx
  800ffd:	0f b6 c2             	movzbl %dl,%eax
  801000:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801003:	8d 43 01             	lea    0x1(%ebx),%eax
  801006:	83 ea 23             	sub    $0x23,%edx
  801009:	80 fa 55             	cmp    $0x55,%dl
  80100c:	0f 87 f9 03 00 00    	ja     80140b <vprintfmt+0x46e>
  801012:	0f b6 d2             	movzbl %dl,%edx
  801015:	ff 24 95 e0 1f 80 00 	jmp    *0x801fe0(,%edx,4)
  80101c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  801020:	eb d6                	jmp    800ff8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801022:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801025:	83 ea 30             	sub    $0x30,%edx
  801028:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80102b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80102e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801031:	83 fb 09             	cmp    $0x9,%ebx
  801034:	77 54                	ja     80108a <vprintfmt+0xed>
  801036:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801039:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80103c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80103f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801042:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  801046:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801049:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80104c:	83 fb 09             	cmp    $0x9,%ebx
  80104f:	76 eb                	jbe    80103c <vprintfmt+0x9f>
  801051:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801054:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801057:	eb 31                	jmp    80108a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801059:	8b 55 14             	mov    0x14(%ebp),%edx
  80105c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80105f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801062:	8b 12                	mov    (%edx),%edx
  801064:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  801067:	eb 21                	jmp    80108a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  801069:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80106d:	ba 00 00 00 00       	mov    $0x0,%edx
  801072:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  801076:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801079:	e9 7a ff ff ff       	jmp    800ff8 <vprintfmt+0x5b>
  80107e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801085:	e9 6e ff ff ff       	jmp    800ff8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80108a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80108e:	0f 89 64 ff ff ff    	jns    800ff8 <vprintfmt+0x5b>
  801094:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801097:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80109a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80109d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8010a0:	e9 53 ff ff ff       	jmp    800ff8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010a5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8010a8:	e9 4b ff ff ff       	jmp    800ff8 <vprintfmt+0x5b>
  8010ad:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8010b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8010b3:	8d 50 04             	lea    0x4(%eax),%edx
  8010b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8010b9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010bd:	8b 00                	mov    (%eax),%eax
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	ff d7                	call   *%edi
  8010c4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8010c7:	e9 fd fe ff ff       	jmp    800fc9 <vprintfmt+0x2c>
  8010cc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8010cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8010d2:	8d 50 04             	lea    0x4(%eax),%edx
  8010d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8010d8:	8b 00                	mov    (%eax),%eax
  8010da:	89 c2                	mov    %eax,%edx
  8010dc:	c1 fa 1f             	sar    $0x1f,%edx
  8010df:	31 d0                	xor    %edx,%eax
  8010e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8010e3:	83 f8 0f             	cmp    $0xf,%eax
  8010e6:	7f 0b                	jg     8010f3 <vprintfmt+0x156>
  8010e8:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8010ef:	85 d2                	test   %edx,%edx
  8010f1:	75 20                	jne    801113 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8010f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010f7:	c7 44 24 08 08 1e 80 	movl   $0x801e08,0x8(%esp)
  8010fe:	00 
  8010ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  801103:	89 3c 24             	mov    %edi,(%esp)
  801106:	e8 a5 03 00 00       	call   8014b0 <printfmt>
  80110b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80110e:	e9 b6 fe ff ff       	jmp    800fc9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801113:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801117:	c7 44 24 08 c3 1d 80 	movl   $0x801dc3,0x8(%esp)
  80111e:	00 
  80111f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801123:	89 3c 24             	mov    %edi,(%esp)
  801126:	e8 85 03 00 00       	call   8014b0 <printfmt>
  80112b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80112e:	e9 96 fe ff ff       	jmp    800fc9 <vprintfmt+0x2c>
  801133:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801136:	89 c3                	mov    %eax,%ebx
  801138:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80113b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80113e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801141:	8b 45 14             	mov    0x14(%ebp),%eax
  801144:	8d 50 04             	lea    0x4(%eax),%edx
  801147:	89 55 14             	mov    %edx,0x14(%ebp)
  80114a:	8b 00                	mov    (%eax),%eax
  80114c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80114f:	85 c0                	test   %eax,%eax
  801151:	b8 11 1e 80 00       	mov    $0x801e11,%eax
  801156:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80115a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80115d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801161:	7e 06                	jle    801169 <vprintfmt+0x1cc>
  801163:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  801167:	75 13                	jne    80117c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801169:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80116c:	0f be 02             	movsbl (%edx),%eax
  80116f:	85 c0                	test   %eax,%eax
  801171:	0f 85 a2 00 00 00    	jne    801219 <vprintfmt+0x27c>
  801177:	e9 8f 00 00 00       	jmp    80120b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80117c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801180:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801183:	89 0c 24             	mov    %ecx,(%esp)
  801186:	e8 70 03 00 00       	call   8014fb <strnlen>
  80118b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80118e:	29 c2                	sub    %eax,%edx
  801190:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801193:	85 d2                	test   %edx,%edx
  801195:	7e d2                	jle    801169 <vprintfmt+0x1cc>
					putch(padc, putdat);
  801197:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80119b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80119e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8011a1:	89 d3                	mov    %edx,%ebx
  8011a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011af:	83 eb 01             	sub    $0x1,%ebx
  8011b2:	85 db                	test   %ebx,%ebx
  8011b4:	7f ed                	jg     8011a3 <vprintfmt+0x206>
  8011b6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8011b9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8011c0:	eb a7                	jmp    801169 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011c2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8011c6:	74 1b                	je     8011e3 <vprintfmt+0x246>
  8011c8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8011cb:	83 fa 5e             	cmp    $0x5e,%edx
  8011ce:	76 13                	jbe    8011e3 <vprintfmt+0x246>
					putch('?', putdat);
  8011d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011d7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8011de:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011e1:	eb 0d                	jmp    8011f0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8011e3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8011e6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011ea:	89 04 24             	mov    %eax,(%esp)
  8011ed:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8011f0:	83 ef 01             	sub    $0x1,%edi
  8011f3:	0f be 03             	movsbl (%ebx),%eax
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	74 05                	je     8011ff <vprintfmt+0x262>
  8011fa:	83 c3 01             	add    $0x1,%ebx
  8011fd:	eb 31                	jmp    801230 <vprintfmt+0x293>
  8011ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801202:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801205:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801208:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80120b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80120f:	7f 36                	jg     801247 <vprintfmt+0x2aa>
  801211:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801214:	e9 b0 fd ff ff       	jmp    800fc9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801219:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80121c:	83 c2 01             	add    $0x1,%edx
  80121f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801222:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801225:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801228:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80122b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80122e:	89 d3                	mov    %edx,%ebx
  801230:	85 f6                	test   %esi,%esi
  801232:	78 8e                	js     8011c2 <vprintfmt+0x225>
  801234:	83 ee 01             	sub    $0x1,%esi
  801237:	79 89                	jns    8011c2 <vprintfmt+0x225>
  801239:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80123c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80123f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801242:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  801245:	eb c4                	jmp    80120b <vprintfmt+0x26e>
  801247:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80124a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80124d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801251:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801258:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80125a:	83 eb 01             	sub    $0x1,%ebx
  80125d:	85 db                	test   %ebx,%ebx
  80125f:	7f ec                	jg     80124d <vprintfmt+0x2b0>
  801261:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801264:	e9 60 fd ff ff       	jmp    800fc9 <vprintfmt+0x2c>
  801269:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80126c:	83 f9 01             	cmp    $0x1,%ecx
  80126f:	7e 16                	jle    801287 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  801271:	8b 45 14             	mov    0x14(%ebp),%eax
  801274:	8d 50 08             	lea    0x8(%eax),%edx
  801277:	89 55 14             	mov    %edx,0x14(%ebp)
  80127a:	8b 10                	mov    (%eax),%edx
  80127c:	8b 48 04             	mov    0x4(%eax),%ecx
  80127f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801282:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801285:	eb 32                	jmp    8012b9 <vprintfmt+0x31c>
	else if (lflag)
  801287:	85 c9                	test   %ecx,%ecx
  801289:	74 18                	je     8012a3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80128b:	8b 45 14             	mov    0x14(%ebp),%eax
  80128e:	8d 50 04             	lea    0x4(%eax),%edx
  801291:	89 55 14             	mov    %edx,0x14(%ebp)
  801294:	8b 00                	mov    (%eax),%eax
  801296:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801299:	89 c1                	mov    %eax,%ecx
  80129b:	c1 f9 1f             	sar    $0x1f,%ecx
  80129e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012a1:	eb 16                	jmp    8012b9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8012a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a6:	8d 50 04             	lea    0x4(%eax),%edx
  8012a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8012ac:	8b 00                	mov    (%eax),%eax
  8012ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 fa 1f             	sar    $0x1f,%edx
  8012b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012bc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8012bf:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8012c4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8012c8:	0f 89 8a 00 00 00    	jns    801358 <vprintfmt+0x3bb>
				putch('-', putdat);
  8012ce:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012d2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012d9:	ff d7                	call   *%edi
				num = -(long long) num;
  8012db:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012de:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8012e1:	f7 d8                	neg    %eax
  8012e3:	83 d2 00             	adc    $0x0,%edx
  8012e6:	f7 da                	neg    %edx
  8012e8:	eb 6e                	jmp    801358 <vprintfmt+0x3bb>
  8012ea:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8012ed:	89 ca                	mov    %ecx,%edx
  8012ef:	8d 45 14             	lea    0x14(%ebp),%eax
  8012f2:	e8 4f fc ff ff       	call   800f46 <getuint>
  8012f7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8012fc:	eb 5a                	jmp    801358 <vprintfmt+0x3bb>
  8012fe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801301:	89 ca                	mov    %ecx,%edx
  801303:	8d 45 14             	lea    0x14(%ebp),%eax
  801306:	e8 3b fc ff ff       	call   800f46 <getuint>
  80130b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  801310:	eb 46                	jmp    801358 <vprintfmt+0x3bb>
  801312:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  801315:	89 74 24 04          	mov    %esi,0x4(%esp)
  801319:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801320:	ff d7                	call   *%edi
			putch('x', putdat);
  801322:	89 74 24 04          	mov    %esi,0x4(%esp)
  801326:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80132d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	8d 50 04             	lea    0x4(%eax),%edx
  801335:	89 55 14             	mov    %edx,0x14(%ebp)
  801338:	8b 00                	mov    (%eax),%eax
  80133a:	ba 00 00 00 00       	mov    $0x0,%edx
  80133f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801344:	eb 12                	jmp    801358 <vprintfmt+0x3bb>
  801346:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801349:	89 ca                	mov    %ecx,%edx
  80134b:	8d 45 14             	lea    0x14(%ebp),%eax
  80134e:	e8 f3 fb ff ff       	call   800f46 <getuint>
  801353:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801358:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80135c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801360:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801363:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801367:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80136b:	89 04 24             	mov    %eax,(%esp)
  80136e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801372:	89 f2                	mov    %esi,%edx
  801374:	89 f8                	mov    %edi,%eax
  801376:	e8 d5 fa ff ff       	call   800e50 <printnum>
  80137b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80137e:	e9 46 fc ff ff       	jmp    800fc9 <vprintfmt+0x2c>
  801383:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  801386:	8b 45 14             	mov    0x14(%ebp),%eax
  801389:	8d 50 04             	lea    0x4(%eax),%edx
  80138c:	89 55 14             	mov    %edx,0x14(%ebp)
  80138f:	8b 00                	mov    (%eax),%eax
  801391:	85 c0                	test   %eax,%eax
  801393:	75 24                	jne    8013b9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  801395:	c7 44 24 0c 2c 1f 80 	movl   $0x801f2c,0xc(%esp)
  80139c:	00 
  80139d:	c7 44 24 08 c3 1d 80 	movl   $0x801dc3,0x8(%esp)
  8013a4:	00 
  8013a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013a9:	89 3c 24             	mov    %edi,(%esp)
  8013ac:	e8 ff 00 00 00       	call   8014b0 <printfmt>
  8013b1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8013b4:	e9 10 fc ff ff       	jmp    800fc9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8013b9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8013bc:	7e 29                	jle    8013e7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8013be:	0f b6 16             	movzbl (%esi),%edx
  8013c1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8013c3:	c7 44 24 0c 64 1f 80 	movl   $0x801f64,0xc(%esp)
  8013ca:	00 
  8013cb:	c7 44 24 08 c3 1d 80 	movl   $0x801dc3,0x8(%esp)
  8013d2:	00 
  8013d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013d7:	89 3c 24             	mov    %edi,(%esp)
  8013da:	e8 d1 00 00 00       	call   8014b0 <printfmt>
  8013df:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8013e2:	e9 e2 fb ff ff       	jmp    800fc9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8013e7:	0f b6 16             	movzbl (%esi),%edx
  8013ea:	88 10                	mov    %dl,(%eax)
  8013ec:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8013ef:	e9 d5 fb ff ff       	jmp    800fc9 <vprintfmt+0x2c>
  8013f4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8013f7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8013fa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013fe:	89 14 24             	mov    %edx,(%esp)
  801401:	ff d7                	call   *%edi
  801403:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801406:	e9 be fb ff ff       	jmp    800fc9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80140b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801416:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801418:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80141b:	80 38 25             	cmpb   $0x25,(%eax)
  80141e:	0f 84 a5 fb ff ff    	je     800fc9 <vprintfmt+0x2c>
  801424:	89 c3                	mov    %eax,%ebx
  801426:	eb f0                	jmp    801418 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  801428:	83 c4 5c             	add    $0x5c,%esp
  80142b:	5b                   	pop    %ebx
  80142c:	5e                   	pop    %esi
  80142d:	5f                   	pop    %edi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    

00801430 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 28             	sub    $0x28,%esp
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80143c:	85 c0                	test   %eax,%eax
  80143e:	74 04                	je     801444 <vsnprintf+0x14>
  801440:	85 d2                	test   %edx,%edx
  801442:	7f 07                	jg     80144b <vsnprintf+0x1b>
  801444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801449:	eb 3b                	jmp    801486 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80144b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80144e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801452:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801455:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80145c:	8b 45 14             	mov    0x14(%ebp),%eax
  80145f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801463:	8b 45 10             	mov    0x10(%ebp),%eax
  801466:	89 44 24 08          	mov    %eax,0x8(%esp)
  80146a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80146d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801471:	c7 04 24 80 0f 80 00 	movl   $0x800f80,(%esp)
  801478:	e8 20 fb ff ff       	call   800f9d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80147d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801480:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801483:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80148e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801491:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801495:	8b 45 10             	mov    0x10(%ebp),%eax
  801498:	89 44 24 08          	mov    %eax,0x8(%esp)
  80149c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a6:	89 04 24             	mov    %eax,(%esp)
  8014a9:	e8 82 ff ff ff       	call   801430 <vsnprintf>
	va_end(ap);

	return rc;
}
  8014ae:	c9                   	leave  
  8014af:	c3                   	ret    

008014b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8014b0:	55                   	push   %ebp
  8014b1:	89 e5                	mov    %esp,%ebp
  8014b3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8014b6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8014b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8014c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ce:	89 04 24             	mov    %eax,(%esp)
  8014d1:	e8 c7 fa ff ff       	call   800f9d <vprintfmt>
	va_end(ap);
}
  8014d6:	c9                   	leave  
  8014d7:	c3                   	ret    
	...

008014e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8014e0:	55                   	push   %ebp
  8014e1:	89 e5                	mov    %esp,%ebp
  8014e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8014ee:	74 09                	je     8014f9 <strlen+0x19>
		n++;
  8014f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8014f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8014f7:	75 f7                	jne    8014f0 <strlen+0x10>
		n++;
	return n;
}
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	53                   	push   %ebx
  8014ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801502:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801505:	85 c9                	test   %ecx,%ecx
  801507:	74 19                	je     801522 <strnlen+0x27>
  801509:	80 3b 00             	cmpb   $0x0,(%ebx)
  80150c:	74 14                	je     801522 <strnlen+0x27>
  80150e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801513:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801516:	39 c8                	cmp    %ecx,%eax
  801518:	74 0d                	je     801527 <strnlen+0x2c>
  80151a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80151e:	75 f3                	jne    801513 <strnlen+0x18>
  801520:	eb 05                	jmp    801527 <strnlen+0x2c>
  801522:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801527:	5b                   	pop    %ebx
  801528:	5d                   	pop    %ebp
  801529:	c3                   	ret    

0080152a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	8b 45 08             	mov    0x8(%ebp),%eax
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801534:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801539:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80153d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801540:	83 c2 01             	add    $0x1,%edx
  801543:	84 c9                	test   %cl,%cl
  801545:	75 f2                	jne    801539 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801547:	5b                   	pop    %ebx
  801548:	5d                   	pop    %ebp
  801549:	c3                   	ret    

0080154a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	53                   	push   %ebx
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801554:	89 1c 24             	mov    %ebx,(%esp)
  801557:	e8 84 ff ff ff       	call   8014e0 <strlen>
	strcpy(dst + len, src);
  80155c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801563:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801566:	89 04 24             	mov    %eax,(%esp)
  801569:	e8 bc ff ff ff       	call   80152a <strcpy>
	return dst;
}
  80156e:	89 d8                	mov    %ebx,%eax
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	5b                   	pop    %ebx
  801574:	5d                   	pop    %ebp
  801575:	c3                   	ret    

00801576 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801576:	55                   	push   %ebp
  801577:	89 e5                	mov    %esp,%ebp
  801579:	56                   	push   %esi
  80157a:	53                   	push   %ebx
  80157b:	8b 45 08             	mov    0x8(%ebp),%eax
  80157e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801581:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801584:	85 f6                	test   %esi,%esi
  801586:	74 18                	je     8015a0 <strncpy+0x2a>
  801588:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80158d:	0f b6 1a             	movzbl (%edx),%ebx
  801590:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801593:	80 3a 01             	cmpb   $0x1,(%edx)
  801596:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801599:	83 c1 01             	add    $0x1,%ecx
  80159c:	39 ce                	cmp    %ecx,%esi
  80159e:	77 ed                	ja     80158d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8015b2:	89 f0                	mov    %esi,%eax
  8015b4:	85 c9                	test   %ecx,%ecx
  8015b6:	74 27                	je     8015df <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8015b8:	83 e9 01             	sub    $0x1,%ecx
  8015bb:	74 1d                	je     8015da <strlcpy+0x36>
  8015bd:	0f b6 1a             	movzbl (%edx),%ebx
  8015c0:	84 db                	test   %bl,%bl
  8015c2:	74 16                	je     8015da <strlcpy+0x36>
			*dst++ = *src++;
  8015c4:	88 18                	mov    %bl,(%eax)
  8015c6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8015c9:	83 e9 01             	sub    $0x1,%ecx
  8015cc:	74 0e                	je     8015dc <strlcpy+0x38>
			*dst++ = *src++;
  8015ce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8015d1:	0f b6 1a             	movzbl (%edx),%ebx
  8015d4:	84 db                	test   %bl,%bl
  8015d6:	75 ec                	jne    8015c4 <strlcpy+0x20>
  8015d8:	eb 02                	jmp    8015dc <strlcpy+0x38>
  8015da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8015dc:	c6 00 00             	movb   $0x0,(%eax)
  8015df:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8015ee:	0f b6 01             	movzbl (%ecx),%eax
  8015f1:	84 c0                	test   %al,%al
  8015f3:	74 15                	je     80160a <strcmp+0x25>
  8015f5:	3a 02                	cmp    (%edx),%al
  8015f7:	75 11                	jne    80160a <strcmp+0x25>
		p++, q++;
  8015f9:	83 c1 01             	add    $0x1,%ecx
  8015fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8015ff:	0f b6 01             	movzbl (%ecx),%eax
  801602:	84 c0                	test   %al,%al
  801604:	74 04                	je     80160a <strcmp+0x25>
  801606:	3a 02                	cmp    (%edx),%al
  801608:	74 ef                	je     8015f9 <strcmp+0x14>
  80160a:	0f b6 c0             	movzbl %al,%eax
  80160d:	0f b6 12             	movzbl (%edx),%edx
  801610:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	8b 55 08             	mov    0x8(%ebp),%edx
  80161b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80161e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801621:	85 c0                	test   %eax,%eax
  801623:	74 23                	je     801648 <strncmp+0x34>
  801625:	0f b6 1a             	movzbl (%edx),%ebx
  801628:	84 db                	test   %bl,%bl
  80162a:	74 25                	je     801651 <strncmp+0x3d>
  80162c:	3a 19                	cmp    (%ecx),%bl
  80162e:	75 21                	jne    801651 <strncmp+0x3d>
  801630:	83 e8 01             	sub    $0x1,%eax
  801633:	74 13                	je     801648 <strncmp+0x34>
		n--, p++, q++;
  801635:	83 c2 01             	add    $0x1,%edx
  801638:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80163b:	0f b6 1a             	movzbl (%edx),%ebx
  80163e:	84 db                	test   %bl,%bl
  801640:	74 0f                	je     801651 <strncmp+0x3d>
  801642:	3a 19                	cmp    (%ecx),%bl
  801644:	74 ea                	je     801630 <strncmp+0x1c>
  801646:	eb 09                	jmp    801651 <strncmp+0x3d>
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80164d:	5b                   	pop    %ebx
  80164e:	5d                   	pop    %ebp
  80164f:	90                   	nop
  801650:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801651:	0f b6 02             	movzbl (%edx),%eax
  801654:	0f b6 11             	movzbl (%ecx),%edx
  801657:	29 d0                	sub    %edx,%eax
  801659:	eb f2                	jmp    80164d <strncmp+0x39>

0080165b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80165b:	55                   	push   %ebp
  80165c:	89 e5                	mov    %esp,%ebp
  80165e:	8b 45 08             	mov    0x8(%ebp),%eax
  801661:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801665:	0f b6 10             	movzbl (%eax),%edx
  801668:	84 d2                	test   %dl,%dl
  80166a:	74 18                	je     801684 <strchr+0x29>
		if (*s == c)
  80166c:	38 ca                	cmp    %cl,%dl
  80166e:	75 0a                	jne    80167a <strchr+0x1f>
  801670:	eb 17                	jmp    801689 <strchr+0x2e>
  801672:	38 ca                	cmp    %cl,%dl
  801674:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801678:	74 0f                	je     801689 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80167a:	83 c0 01             	add    $0x1,%eax
  80167d:	0f b6 10             	movzbl (%eax),%edx
  801680:	84 d2                	test   %dl,%dl
  801682:	75 ee                	jne    801672 <strchr+0x17>
  801684:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	8b 45 08             	mov    0x8(%ebp),%eax
  801691:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801695:	0f b6 10             	movzbl (%eax),%edx
  801698:	84 d2                	test   %dl,%dl
  80169a:	74 18                	je     8016b4 <strfind+0x29>
		if (*s == c)
  80169c:	38 ca                	cmp    %cl,%dl
  80169e:	75 0a                	jne    8016aa <strfind+0x1f>
  8016a0:	eb 12                	jmp    8016b4 <strfind+0x29>
  8016a2:	38 ca                	cmp    %cl,%dl
  8016a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016a8:	74 0a                	je     8016b4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8016aa:	83 c0 01             	add    $0x1,%eax
  8016ad:	0f b6 10             	movzbl (%eax),%edx
  8016b0:	84 d2                	test   %dl,%dl
  8016b2:	75 ee                	jne    8016a2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8016b4:	5d                   	pop    %ebp
  8016b5:	c3                   	ret    

008016b6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	83 ec 0c             	sub    $0xc,%esp
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8016c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8016d0:	85 c9                	test   %ecx,%ecx
  8016d2:	74 30                	je     801704 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8016d4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016da:	75 25                	jne    801701 <memset+0x4b>
  8016dc:	f6 c1 03             	test   $0x3,%cl
  8016df:	75 20                	jne    801701 <memset+0x4b>
		c &= 0xFF;
  8016e1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8016e4:	89 d3                	mov    %edx,%ebx
  8016e6:	c1 e3 08             	shl    $0x8,%ebx
  8016e9:	89 d6                	mov    %edx,%esi
  8016eb:	c1 e6 18             	shl    $0x18,%esi
  8016ee:	89 d0                	mov    %edx,%eax
  8016f0:	c1 e0 10             	shl    $0x10,%eax
  8016f3:	09 f0                	or     %esi,%eax
  8016f5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8016f7:	09 d8                	or     %ebx,%eax
  8016f9:	c1 e9 02             	shr    $0x2,%ecx
  8016fc:	fc                   	cld    
  8016fd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8016ff:	eb 03                	jmp    801704 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801701:	fc                   	cld    
  801702:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801704:	89 f8                	mov    %edi,%eax
  801706:	8b 1c 24             	mov    (%esp),%ebx
  801709:	8b 74 24 04          	mov    0x4(%esp),%esi
  80170d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801711:	89 ec                	mov    %ebp,%esp
  801713:	5d                   	pop    %ebp
  801714:	c3                   	ret    

00801715 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	83 ec 08             	sub    $0x8,%esp
  80171b:	89 34 24             	mov    %esi,(%esp)
  80171e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801728:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80172b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80172d:	39 c6                	cmp    %eax,%esi
  80172f:	73 35                	jae    801766 <memmove+0x51>
  801731:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801734:	39 d0                	cmp    %edx,%eax
  801736:	73 2e                	jae    801766 <memmove+0x51>
		s += n;
		d += n;
  801738:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80173a:	f6 c2 03             	test   $0x3,%dl
  80173d:	75 1b                	jne    80175a <memmove+0x45>
  80173f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801745:	75 13                	jne    80175a <memmove+0x45>
  801747:	f6 c1 03             	test   $0x3,%cl
  80174a:	75 0e                	jne    80175a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80174c:	83 ef 04             	sub    $0x4,%edi
  80174f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801752:	c1 e9 02             	shr    $0x2,%ecx
  801755:	fd                   	std    
  801756:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801758:	eb 09                	jmp    801763 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80175a:	83 ef 01             	sub    $0x1,%edi
  80175d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801760:	fd                   	std    
  801761:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801763:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801764:	eb 20                	jmp    801786 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801766:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80176c:	75 15                	jne    801783 <memmove+0x6e>
  80176e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801774:	75 0d                	jne    801783 <memmove+0x6e>
  801776:	f6 c1 03             	test   $0x3,%cl
  801779:	75 08                	jne    801783 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80177b:	c1 e9 02             	shr    $0x2,%ecx
  80177e:	fc                   	cld    
  80177f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801781:	eb 03                	jmp    801786 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801783:	fc                   	cld    
  801784:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801786:	8b 34 24             	mov    (%esp),%esi
  801789:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80178d:	89 ec                	mov    %ebp,%esp
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801797:	8b 45 10             	mov    0x10(%ebp),%eax
  80179a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80179e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a8:	89 04 24             	mov    %eax,(%esp)
  8017ab:	e8 65 ff ff ff       	call   801715 <memmove>
}
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	57                   	push   %edi
  8017b6:	56                   	push   %esi
  8017b7:	53                   	push   %ebx
  8017b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017bb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017be:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017c1:	85 c9                	test   %ecx,%ecx
  8017c3:	74 36                	je     8017fb <memcmp+0x49>
		if (*s1 != *s2)
  8017c5:	0f b6 06             	movzbl (%esi),%eax
  8017c8:	0f b6 1f             	movzbl (%edi),%ebx
  8017cb:	38 d8                	cmp    %bl,%al
  8017cd:	74 20                	je     8017ef <memcmp+0x3d>
  8017cf:	eb 14                	jmp    8017e5 <memcmp+0x33>
  8017d1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8017d6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8017db:	83 c2 01             	add    $0x1,%edx
  8017de:	83 e9 01             	sub    $0x1,%ecx
  8017e1:	38 d8                	cmp    %bl,%al
  8017e3:	74 12                	je     8017f7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8017e5:	0f b6 c0             	movzbl %al,%eax
  8017e8:	0f b6 db             	movzbl %bl,%ebx
  8017eb:	29 d8                	sub    %ebx,%eax
  8017ed:	eb 11                	jmp    801800 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017ef:	83 e9 01             	sub    $0x1,%ecx
  8017f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f7:	85 c9                	test   %ecx,%ecx
  8017f9:	75 d6                	jne    8017d1 <memcmp+0x1f>
  8017fb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801800:	5b                   	pop    %ebx
  801801:	5e                   	pop    %esi
  801802:	5f                   	pop    %edi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80180b:	89 c2                	mov    %eax,%edx
  80180d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801810:	39 d0                	cmp    %edx,%eax
  801812:	73 15                	jae    801829 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801814:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801818:	38 08                	cmp    %cl,(%eax)
  80181a:	75 06                	jne    801822 <memfind+0x1d>
  80181c:	eb 0b                	jmp    801829 <memfind+0x24>
  80181e:	38 08                	cmp    %cl,(%eax)
  801820:	74 07                	je     801829 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801822:	83 c0 01             	add    $0x1,%eax
  801825:	39 c2                	cmp    %eax,%edx
  801827:	77 f5                	ja     80181e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	57                   	push   %edi
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	83 ec 04             	sub    $0x4,%esp
  801834:	8b 55 08             	mov    0x8(%ebp),%edx
  801837:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80183a:	0f b6 02             	movzbl (%edx),%eax
  80183d:	3c 20                	cmp    $0x20,%al
  80183f:	74 04                	je     801845 <strtol+0x1a>
  801841:	3c 09                	cmp    $0x9,%al
  801843:	75 0e                	jne    801853 <strtol+0x28>
		s++;
  801845:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801848:	0f b6 02             	movzbl (%edx),%eax
  80184b:	3c 20                	cmp    $0x20,%al
  80184d:	74 f6                	je     801845 <strtol+0x1a>
  80184f:	3c 09                	cmp    $0x9,%al
  801851:	74 f2                	je     801845 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801853:	3c 2b                	cmp    $0x2b,%al
  801855:	75 0c                	jne    801863 <strtol+0x38>
		s++;
  801857:	83 c2 01             	add    $0x1,%edx
  80185a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801861:	eb 15                	jmp    801878 <strtol+0x4d>
	else if (*s == '-')
  801863:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80186a:	3c 2d                	cmp    $0x2d,%al
  80186c:	75 0a                	jne    801878 <strtol+0x4d>
		s++, neg = 1;
  80186e:	83 c2 01             	add    $0x1,%edx
  801871:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801878:	85 db                	test   %ebx,%ebx
  80187a:	0f 94 c0             	sete   %al
  80187d:	74 05                	je     801884 <strtol+0x59>
  80187f:	83 fb 10             	cmp    $0x10,%ebx
  801882:	75 18                	jne    80189c <strtol+0x71>
  801884:	80 3a 30             	cmpb   $0x30,(%edx)
  801887:	75 13                	jne    80189c <strtol+0x71>
  801889:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80188d:	8d 76 00             	lea    0x0(%esi),%esi
  801890:	75 0a                	jne    80189c <strtol+0x71>
		s += 2, base = 16;
  801892:	83 c2 02             	add    $0x2,%edx
  801895:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80189a:	eb 15                	jmp    8018b1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80189c:	84 c0                	test   %al,%al
  80189e:	66 90                	xchg   %ax,%ax
  8018a0:	74 0f                	je     8018b1 <strtol+0x86>
  8018a2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8018a7:	80 3a 30             	cmpb   $0x30,(%edx)
  8018aa:	75 05                	jne    8018b1 <strtol+0x86>
		s++, base = 8;
  8018ac:	83 c2 01             	add    $0x1,%edx
  8018af:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8018b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8018b8:	0f b6 0a             	movzbl (%edx),%ecx
  8018bb:	89 cf                	mov    %ecx,%edi
  8018bd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8018c0:	80 fb 09             	cmp    $0x9,%bl
  8018c3:	77 08                	ja     8018cd <strtol+0xa2>
			dig = *s - '0';
  8018c5:	0f be c9             	movsbl %cl,%ecx
  8018c8:	83 e9 30             	sub    $0x30,%ecx
  8018cb:	eb 1e                	jmp    8018eb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8018cd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8018d0:	80 fb 19             	cmp    $0x19,%bl
  8018d3:	77 08                	ja     8018dd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8018d5:	0f be c9             	movsbl %cl,%ecx
  8018d8:	83 e9 57             	sub    $0x57,%ecx
  8018db:	eb 0e                	jmp    8018eb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8018dd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8018e0:	80 fb 19             	cmp    $0x19,%bl
  8018e3:	77 15                	ja     8018fa <strtol+0xcf>
			dig = *s - 'A' + 10;
  8018e5:	0f be c9             	movsbl %cl,%ecx
  8018e8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8018eb:	39 f1                	cmp    %esi,%ecx
  8018ed:	7d 0b                	jge    8018fa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8018ef:	83 c2 01             	add    $0x1,%edx
  8018f2:	0f af c6             	imul   %esi,%eax
  8018f5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8018f8:	eb be                	jmp    8018b8 <strtol+0x8d>
  8018fa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8018fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801900:	74 05                	je     801907 <strtol+0xdc>
		*endptr = (char *) s;
  801902:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801905:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801907:	89 ca                	mov    %ecx,%edx
  801909:	f7 da                	neg    %edx
  80190b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80190f:	0f 45 c2             	cmovne %edx,%eax
}
  801912:	83 c4 04             	add    $0x4,%esp
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5f                   	pop    %edi
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    
  80191a:	00 00                	add    %al,(%eax)
  80191c:	00 00                	add    %al,(%eax)
	...

00801920 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801926:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80192c:	b8 01 00 00 00       	mov    $0x1,%eax
  801931:	39 ca                	cmp    %ecx,%edx
  801933:	75 04                	jne    801939 <ipc_find_env+0x19>
  801935:	b0 00                	mov    $0x0,%al
  801937:	eb 0f                	jmp    801948 <ipc_find_env+0x28>
  801939:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80193c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801942:	8b 12                	mov    (%edx),%edx
  801944:	39 ca                	cmp    %ecx,%edx
  801946:	75 0c                	jne    801954 <ipc_find_env+0x34>
			return envs[i].env_id;
  801948:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80194b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801950:	8b 00                	mov    (%eax),%eax
  801952:	eb 0e                	jmp    801962 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801954:	83 c0 01             	add    $0x1,%eax
  801957:	3d 00 04 00 00       	cmp    $0x400,%eax
  80195c:	75 db                	jne    801939 <ipc_find_env+0x19>
  80195e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	57                   	push   %edi
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
  80196a:	83 ec 1c             	sub    $0x1c,%esp
  80196d:	8b 75 08             	mov    0x8(%ebp),%esi
  801970:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801973:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801976:	85 db                	test   %ebx,%ebx
  801978:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80197d:	0f 44 d8             	cmove  %eax,%ebx
  801980:	eb 29                	jmp    8019ab <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801982:	85 c0                	test   %eax,%eax
  801984:	79 25                	jns    8019ab <ipc_send+0x47>
  801986:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801989:	74 20                	je     8019ab <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  80198b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80198f:	c7 44 24 08 80 21 80 	movl   $0x802180,0x8(%esp)
  801996:	00 
  801997:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80199e:	00 
  80199f:	c7 04 24 9e 21 80 00 	movl   $0x80219e,(%esp)
  8019a6:	e8 85 f3 ff ff       	call   800d30 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8019ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019b6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019ba:	89 34 24             	mov    %esi,(%esp)
  8019bd:	e8 99 e7 ff ff       	call   80015b <sys_ipc_try_send>
  8019c2:	85 c0                	test   %eax,%eax
  8019c4:	75 bc                	jne    801982 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8019c6:	e8 16 e9 ff ff       	call   8002e1 <sys_yield>
}
  8019cb:	83 c4 1c             	add    $0x1c,%esp
  8019ce:	5b                   	pop    %ebx
  8019cf:	5e                   	pop    %esi
  8019d0:	5f                   	pop    %edi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    

008019d3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	83 ec 28             	sub    $0x28,%esp
  8019d9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019dc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019df:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019f2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8019f5:	89 04 24             	mov    %eax,(%esp)
  8019f8:	e8 25 e7 ff ff       	call   800122 <sys_ipc_recv>
  8019fd:	89 c3                	mov    %eax,%ebx
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	79 2a                	jns    801a2d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801a03:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a0b:	c7 04 24 a8 21 80 00 	movl   $0x8021a8,(%esp)
  801a12:	e8 d2 f3 ff ff       	call   800de9 <cprintf>
		if(from_env_store != NULL)
  801a17:	85 f6                	test   %esi,%esi
  801a19:	74 06                	je     801a21 <ipc_recv+0x4e>
			*from_env_store = 0;
  801a1b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801a21:	85 ff                	test   %edi,%edi
  801a23:	74 2d                	je     801a52 <ipc_recv+0x7f>
			*perm_store = 0;
  801a25:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a2b:	eb 25                	jmp    801a52 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801a2d:	85 f6                	test   %esi,%esi
  801a2f:	90                   	nop
  801a30:	74 0a                	je     801a3c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801a32:	a1 04 40 80 00       	mov    0x804004,%eax
  801a37:	8b 40 74             	mov    0x74(%eax),%eax
  801a3a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801a3c:	85 ff                	test   %edi,%edi
  801a3e:	74 0a                	je     801a4a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801a40:	a1 04 40 80 00       	mov    0x804004,%eax
  801a45:	8b 40 78             	mov    0x78(%eax),%eax
  801a48:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801a52:	89 d8                	mov    %ebx,%eax
  801a54:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a57:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a5a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a5d:	89 ec                	mov    %ebp,%esp
  801a5f:	5d                   	pop    %ebp
  801a60:	c3                   	ret    
	...

00801a70 <__udivdi3>:
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	83 ec 10             	sub    $0x10,%esp
  801a78:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a7e:	8b 75 10             	mov    0x10(%ebp),%esi
  801a81:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a84:	85 c0                	test   %eax,%eax
  801a86:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801a89:	75 35                	jne    801ac0 <__udivdi3+0x50>
  801a8b:	39 fe                	cmp    %edi,%esi
  801a8d:	77 61                	ja     801af0 <__udivdi3+0x80>
  801a8f:	85 f6                	test   %esi,%esi
  801a91:	75 0b                	jne    801a9e <__udivdi3+0x2e>
  801a93:	b8 01 00 00 00       	mov    $0x1,%eax
  801a98:	31 d2                	xor    %edx,%edx
  801a9a:	f7 f6                	div    %esi
  801a9c:	89 c6                	mov    %eax,%esi
  801a9e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801aa1:	31 d2                	xor    %edx,%edx
  801aa3:	89 f8                	mov    %edi,%eax
  801aa5:	f7 f6                	div    %esi
  801aa7:	89 c7                	mov    %eax,%edi
  801aa9:	89 c8                	mov    %ecx,%eax
  801aab:	f7 f6                	div    %esi
  801aad:	89 c1                	mov    %eax,%ecx
  801aaf:	89 fa                	mov    %edi,%edx
  801ab1:	89 c8                	mov    %ecx,%eax
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    
  801aba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ac0:	39 f8                	cmp    %edi,%eax
  801ac2:	77 1c                	ja     801ae0 <__udivdi3+0x70>
  801ac4:	0f bd d0             	bsr    %eax,%edx
  801ac7:	83 f2 1f             	xor    $0x1f,%edx
  801aca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801acd:	75 39                	jne    801b08 <__udivdi3+0x98>
  801acf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ad2:	0f 86 a0 00 00 00    	jbe    801b78 <__udivdi3+0x108>
  801ad8:	39 f8                	cmp    %edi,%eax
  801ada:	0f 82 98 00 00 00    	jb     801b78 <__udivdi3+0x108>
  801ae0:	31 ff                	xor    %edi,%edi
  801ae2:	31 c9                	xor    %ecx,%ecx
  801ae4:	89 c8                	mov    %ecx,%eax
  801ae6:	89 fa                	mov    %edi,%edx
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	5e                   	pop    %esi
  801aec:	5f                   	pop    %edi
  801aed:	5d                   	pop    %ebp
  801aee:	c3                   	ret    
  801aef:	90                   	nop
  801af0:	89 d1                	mov    %edx,%ecx
  801af2:	89 fa                	mov    %edi,%edx
  801af4:	89 c8                	mov    %ecx,%eax
  801af6:	31 ff                	xor    %edi,%edi
  801af8:	f7 f6                	div    %esi
  801afa:	89 c1                	mov    %eax,%ecx
  801afc:	89 fa                	mov    %edi,%edx
  801afe:	89 c8                	mov    %ecx,%eax
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    
  801b07:	90                   	nop
  801b08:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b0c:	89 f2                	mov    %esi,%edx
  801b0e:	d3 e0                	shl    %cl,%eax
  801b10:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b13:	b8 20 00 00 00       	mov    $0x20,%eax
  801b18:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b1b:	89 c1                	mov    %eax,%ecx
  801b1d:	d3 ea                	shr    %cl,%edx
  801b1f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b23:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b26:	d3 e6                	shl    %cl,%esi
  801b28:	89 c1                	mov    %eax,%ecx
  801b2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b2d:	89 fe                	mov    %edi,%esi
  801b2f:	d3 ee                	shr    %cl,%esi
  801b31:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b35:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b3b:	d3 e7                	shl    %cl,%edi
  801b3d:	89 c1                	mov    %eax,%ecx
  801b3f:	d3 ea                	shr    %cl,%edx
  801b41:	09 d7                	or     %edx,%edi
  801b43:	89 f2                	mov    %esi,%edx
  801b45:	89 f8                	mov    %edi,%eax
  801b47:	f7 75 ec             	divl   -0x14(%ebp)
  801b4a:	89 d6                	mov    %edx,%esi
  801b4c:	89 c7                	mov    %eax,%edi
  801b4e:	f7 65 e8             	mull   -0x18(%ebp)
  801b51:	39 d6                	cmp    %edx,%esi
  801b53:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b56:	72 30                	jb     801b88 <__udivdi3+0x118>
  801b58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b5b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b5f:	d3 e2                	shl    %cl,%edx
  801b61:	39 c2                	cmp    %eax,%edx
  801b63:	73 05                	jae    801b6a <__udivdi3+0xfa>
  801b65:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b68:	74 1e                	je     801b88 <__udivdi3+0x118>
  801b6a:	89 f9                	mov    %edi,%ecx
  801b6c:	31 ff                	xor    %edi,%edi
  801b6e:	e9 71 ff ff ff       	jmp    801ae4 <__udivdi3+0x74>
  801b73:	90                   	nop
  801b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b78:	31 ff                	xor    %edi,%edi
  801b7a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801b7f:	e9 60 ff ff ff       	jmp    801ae4 <__udivdi3+0x74>
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801b8b:	31 ff                	xor    %edi,%edi
  801b8d:	89 c8                	mov    %ecx,%eax
  801b8f:	89 fa                	mov    %edi,%edx
  801b91:	83 c4 10             	add    $0x10,%esp
  801b94:	5e                   	pop    %esi
  801b95:	5f                   	pop    %edi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    
	...

00801ba0 <__umoddi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	57                   	push   %edi
  801ba4:	56                   	push   %esi
  801ba5:	83 ec 20             	sub    $0x20,%esp
  801ba8:	8b 55 14             	mov    0x14(%ebp),%edx
  801bab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bae:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bb1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bb4:	85 d2                	test   %edx,%edx
  801bb6:	89 c8                	mov    %ecx,%eax
  801bb8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bbb:	75 13                	jne    801bd0 <__umoddi3+0x30>
  801bbd:	39 f7                	cmp    %esi,%edi
  801bbf:	76 3f                	jbe    801c00 <__umoddi3+0x60>
  801bc1:	89 f2                	mov    %esi,%edx
  801bc3:	f7 f7                	div    %edi
  801bc5:	89 d0                	mov    %edx,%eax
  801bc7:	31 d2                	xor    %edx,%edx
  801bc9:	83 c4 20             	add    $0x20,%esp
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    
  801bd0:	39 f2                	cmp    %esi,%edx
  801bd2:	77 4c                	ja     801c20 <__umoddi3+0x80>
  801bd4:	0f bd ca             	bsr    %edx,%ecx
  801bd7:	83 f1 1f             	xor    $0x1f,%ecx
  801bda:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bdd:	75 51                	jne    801c30 <__umoddi3+0x90>
  801bdf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801be2:	0f 87 e0 00 00 00    	ja     801cc8 <__umoddi3+0x128>
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	29 f8                	sub    %edi,%eax
  801bed:	19 d6                	sbb    %edx,%esi
  801bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	89 f2                	mov    %esi,%edx
  801bf7:	83 c4 20             	add    $0x20,%esp
  801bfa:	5e                   	pop    %esi
  801bfb:	5f                   	pop    %edi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    
  801bfe:	66 90                	xchg   %ax,%ax
  801c00:	85 ff                	test   %edi,%edi
  801c02:	75 0b                	jne    801c0f <__umoddi3+0x6f>
  801c04:	b8 01 00 00 00       	mov    $0x1,%eax
  801c09:	31 d2                	xor    %edx,%edx
  801c0b:	f7 f7                	div    %edi
  801c0d:	89 c7                	mov    %eax,%edi
  801c0f:	89 f0                	mov    %esi,%eax
  801c11:	31 d2                	xor    %edx,%edx
  801c13:	f7 f7                	div    %edi
  801c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c18:	f7 f7                	div    %edi
  801c1a:	eb a9                	jmp    801bc5 <__umoddi3+0x25>
  801c1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c20:	89 c8                	mov    %ecx,%eax
  801c22:	89 f2                	mov    %esi,%edx
  801c24:	83 c4 20             	add    $0x20,%esp
  801c27:	5e                   	pop    %esi
  801c28:	5f                   	pop    %edi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    
  801c2b:	90                   	nop
  801c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c30:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c34:	d3 e2                	shl    %cl,%edx
  801c36:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c39:	ba 20 00 00 00       	mov    $0x20,%edx
  801c3e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c41:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c44:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c48:	89 fa                	mov    %edi,%edx
  801c4a:	d3 ea                	shr    %cl,%edx
  801c4c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c50:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c53:	d3 e7                	shl    %cl,%edi
  801c55:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c59:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c5c:	89 f2                	mov    %esi,%edx
  801c5e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c61:	89 c7                	mov    %eax,%edi
  801c63:	d3 ea                	shr    %cl,%edx
  801c65:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c69:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c6c:	89 c2                	mov    %eax,%edx
  801c6e:	d3 e6                	shl    %cl,%esi
  801c70:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c74:	d3 ea                	shr    %cl,%edx
  801c76:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c7a:	09 d6                	or     %edx,%esi
  801c7c:	89 f0                	mov    %esi,%eax
  801c7e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801c81:	d3 e7                	shl    %cl,%edi
  801c83:	89 f2                	mov    %esi,%edx
  801c85:	f7 75 f4             	divl   -0xc(%ebp)
  801c88:	89 d6                	mov    %edx,%esi
  801c8a:	f7 65 e8             	mull   -0x18(%ebp)
  801c8d:	39 d6                	cmp    %edx,%esi
  801c8f:	72 2b                	jb     801cbc <__umoddi3+0x11c>
  801c91:	39 c7                	cmp    %eax,%edi
  801c93:	72 23                	jb     801cb8 <__umoddi3+0x118>
  801c95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c99:	29 c7                	sub    %eax,%edi
  801c9b:	19 d6                	sbb    %edx,%esi
  801c9d:	89 f0                	mov    %esi,%eax
  801c9f:	89 f2                	mov    %esi,%edx
  801ca1:	d3 ef                	shr    %cl,%edi
  801ca3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ca7:	d3 e0                	shl    %cl,%eax
  801ca9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cad:	09 f8                	or     %edi,%eax
  801caf:	d3 ea                	shr    %cl,%edx
  801cb1:	83 c4 20             	add    $0x20,%esp
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	39 d6                	cmp    %edx,%esi
  801cba:	75 d9                	jne    801c95 <__umoddi3+0xf5>
  801cbc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801cbf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801cc2:	eb d1                	jmp    801c95 <__umoddi3+0xf5>
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	0f 82 18 ff ff ff    	jb     801be8 <__umoddi3+0x48>
  801cd0:	e9 1d ff ff ff       	jmp    801bf2 <__umoddi3+0x52>
