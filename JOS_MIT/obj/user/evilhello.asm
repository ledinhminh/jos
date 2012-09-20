
obj/user/evilhello.debug:     file format elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
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
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  80003a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 0c 00 10 f0 	movl   $0xf010000c,(%esp)
  800049:	e8 38 04 00 00       	call   800486 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800062:	e8 70 03 00 00       	call   8003d7 <sys_getenvid>
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	c1 e0 07             	shl    $0x7,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 f6                	test   %esi,%esi
  80007b:	7e 07                	jle    800084 <libmain+0x34>
		binaryname = argv[0];
  80007d:	8b 03                	mov    (%ebx),%eax
  80007f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800084:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800088:	89 34 24             	mov    %esi,(%esp)
  80008b:	e8 a4 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800090:	e8 0b 00 00 00       	call   8000a0 <exit>
}
  800095:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800098:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009b:	89 ec                	mov    %ebp,%esp
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a6:	e8 fe 08 00 00       	call   8009a9 <close_all>
	sys_env_destroy(0);
  8000ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b2:	e8 5b 03 00 00       	call   800412 <sys_env_destroy>
}
  8000b7:	c9                   	leave  
  8000b8:	c3                   	ret    
  8000b9:	00 00                	add    %al,(%eax)
	...

008000bc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 48             	sub    $0x48,%esp
  8000c2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000cb:	89 c6                	mov    %eax,%esi
  8000cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000d0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000d2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000db:	51                   	push   %ecx
  8000dc:	52                   	push   %edx
  8000dd:	53                   	push   %ebx
  8000de:	54                   	push   %esp
  8000df:	55                   	push   %ebp
  8000e0:	56                   	push   %esi
  8000e1:	57                   	push   %edi
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	8d 35 ec 00 80 00    	lea    0x8000ec,%esi
  8000ea:	0f 34                	sysenter 

008000ec <.after_sysenter_label>:
  8000ec:	5f                   	pop    %edi
  8000ed:	5e                   	pop    %esi
  8000ee:	5d                   	pop    %ebp
  8000ef:	5c                   	pop    %esp
  8000f0:	5b                   	pop    %ebx
  8000f1:	5a                   	pop    %edx
  8000f2:	59                   	pop    %ecx
  8000f3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000f5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000f9:	74 28                	je     800123 <.after_sysenter_label+0x37>
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 24                	jle    800123 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800103:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800107:	c7 44 24 08 aa 22 80 	movl   $0x8022aa,0x8(%esp)
  80010e:	00 
  80010f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800116:	00 
  800117:	c7 04 24 c7 22 80 00 	movl   $0x8022c7,(%esp)
  80011e:	e8 91 11 00 00       	call   8012b4 <_panic>

	return ret;
}
  800123:	89 d0                	mov    %edx,%eax
  800125:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800128:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80012b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80012e:	89 ec                	mov    %ebp,%esp
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800138:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80013f:	00 
  800140:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800147:	00 
  800148:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80014f:	00 
  800150:	8b 45 0c             	mov    0xc(%ebp),%eax
  800153:	89 04 24             	mov    %eax,(%esp)
  800156:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	b8 10 00 00 00       	mov    $0x10,%eax
  800163:	e8 54 ff ff ff       	call   8000bc <syscall>
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800170:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800177:	00 
  800178:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80017f:	00 
  800180:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800187:	00 
  800188:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800194:	ba 00 00 00 00       	mov    $0x0,%edx
  800199:	b8 0f 00 00 00       	mov    $0xf,%eax
  80019e:	e8 19 ff ff ff       	call   8000bc <syscall>
}
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8001ab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b2:	00 
  8001b3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001ba:	00 
  8001bb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001c2:	00 
  8001c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cd:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8001d7:	e8 e0 fe ff ff       	call   8000bc <syscall>
}
  8001dc:	c9                   	leave  
  8001dd:	c3                   	ret    

008001de <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8001e4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001eb:	00 
  8001ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fd:	89 04 24             	mov    %eax,(%esp)
  800200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800203:	ba 00 00 00 00       	mov    $0x0,%edx
  800208:	b8 0d 00 00 00       	mov    $0xd,%eax
  80020d:	e8 aa fe ff ff       	call   8000bc <syscall>
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80021a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800221:	00 
  800222:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800229:	00 
  80022a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800231:	00 
  800232:	8b 45 0c             	mov    0xc(%ebp),%eax
  800235:	89 04 24             	mov    %eax,(%esp)
  800238:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023b:	ba 01 00 00 00       	mov    $0x1,%edx
  800240:	b8 0b 00 00 00       	mov    $0xb,%eax
  800245:	e8 72 fe ff ff       	call   8000bc <syscall>
}
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800252:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800259:	00 
  80025a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800261:	00 
  800262:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800269:	00 
  80026a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026d:	89 04 24             	mov    %eax,(%esp)
  800270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800273:	ba 01 00 00 00       	mov    $0x1,%edx
  800278:	b8 0a 00 00 00       	mov    $0xa,%eax
  80027d:	e8 3a fe ff ff       	call   8000bc <syscall>
}
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80028a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800291:	00 
  800292:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800299:	00 
  80029a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002a1:	00 
  8002a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a5:	89 04 24             	mov    %eax,(%esp)
  8002a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b0:	b8 09 00 00 00       	mov    $0x9,%eax
  8002b5:	e8 02 fe ff ff       	call   8000bc <syscall>
}
  8002ba:	c9                   	leave  
  8002bb:	c3                   	ret    

008002bc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002c2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c9:	00 
  8002ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002d1:	00 
  8002d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002d9:	00 
  8002da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002dd:	89 04 24             	mov    %eax,(%esp)
  8002e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e3:	ba 01 00 00 00       	mov    $0x1,%edx
  8002e8:	b8 07 00 00 00       	mov    $0x7,%eax
  8002ed:	e8 ca fd ff ff       	call   8000bc <syscall>
}
  8002f2:	c9                   	leave  
  8002f3:	c3                   	ret    

008002f4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8002fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800301:	00 
  800302:	8b 45 18             	mov    0x18(%ebp),%eax
  800305:	0b 45 14             	or     0x14(%ebp),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	8b 45 10             	mov    0x10(%ebp),%eax
  80030f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800313:	8b 45 0c             	mov    0xc(%ebp),%eax
  800316:	89 04 24             	mov    %eax,(%esp)
  800319:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80031c:	ba 01 00 00 00       	mov    $0x1,%edx
  800321:	b8 06 00 00 00       	mov    $0x6,%eax
  800326:	e8 91 fd ff ff       	call   8000bc <syscall>
}
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800333:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033a:	00 
  80033b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800342:	00 
  800343:	8b 45 10             	mov    0x10(%ebp),%eax
  800346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80034a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80034d:	89 04 24             	mov    %eax,(%esp)
  800350:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800353:	ba 01 00 00 00       	mov    $0x1,%edx
  800358:	b8 05 00 00 00       	mov    $0x5,%eax
  80035d:	e8 5a fd ff ff       	call   8000bc <syscall>
}
  800362:	c9                   	leave  
  800363:	c3                   	ret    

00800364 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80036a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800371:	00 
  800372:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800379:	00 
  80037a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800381:	00 
  800382:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800389:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038e:	ba 00 00 00 00       	mov    $0x0,%edx
  800393:	b8 0c 00 00 00       	mov    $0xc,%eax
  800398:	e8 1f fd ff ff       	call   8000bc <syscall>
}
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8003a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ac:	00 
  8003ad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003b4:	00 
  8003b5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003bc:	00 
  8003bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cb:	b8 04 00 00 00       	mov    $0x4,%eax
  8003d0:	e8 e7 fc ff ff       	call   8000bc <syscall>
}
  8003d5:	c9                   	leave  
  8003d6:	c3                   	ret    

008003d7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8003dd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e4:	00 
  8003e5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003ec:	00 
  8003ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003f4:	00 
  8003f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800401:	ba 00 00 00 00       	mov    $0x0,%edx
  800406:	b8 02 00 00 00       	mov    $0x2,%eax
  80040b:	e8 ac fc ff ff       	call   8000bc <syscall>
}
  800410:	c9                   	leave  
  800411:	c3                   	ret    

00800412 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800418:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80041f:	00 
  800420:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800427:	00 
  800428:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80042f:	00 
  800430:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800437:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043a:	ba 01 00 00 00       	mov    $0x1,%edx
  80043f:	b8 03 00 00 00       	mov    $0x3,%eax
  800444:	e8 73 fc ff ff       	call   8000bc <syscall>
}
  800449:	c9                   	leave  
  80044a:	c3                   	ret    

0080044b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80044b:	55                   	push   %ebp
  80044c:	89 e5                	mov    %esp,%ebp
  80044e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800451:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800458:	00 
  800459:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800460:	00 
  800461:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800468:	00 
  800469:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800470:	b9 00 00 00 00       	mov    $0x0,%ecx
  800475:	ba 00 00 00 00       	mov    $0x0,%edx
  80047a:	b8 01 00 00 00       	mov    $0x1,%eax
  80047f:	e8 38 fc ff ff       	call   8000bc <syscall>
}
  800484:	c9                   	leave  
  800485:	c3                   	ret    

00800486 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800486:	55                   	push   %ebp
  800487:	89 e5                	mov    %esp,%ebp
  800489:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80048c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800493:	00 
  800494:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80049b:	00 
  80049c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004a3:	00 
  8004a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	e8 00 fc ff ff       	call   8000bc <syscall>
}
  8004bc:	c9                   	leave  
  8004bd:	c3                   	ret    
	...

008004c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8004cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	89 04 24             	mov    %eax,(%esp)
  8004dc:	e8 df ff ff ff       	call   8004c0 <fd2num>
  8004e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8004e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	57                   	push   %edi
  8004ef:	56                   	push   %esi
  8004f0:	53                   	push   %ebx
  8004f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8004f4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8004f9:	a8 01                	test   $0x1,%al
  8004fb:	74 36                	je     800533 <fd_alloc+0x48>
  8004fd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800502:	a8 01                	test   $0x1,%al
  800504:	74 2d                	je     800533 <fd_alloc+0x48>
  800506:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80050b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800510:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800515:	89 c3                	mov    %eax,%ebx
  800517:	89 c2                	mov    %eax,%edx
  800519:	c1 ea 16             	shr    $0x16,%edx
  80051c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80051f:	f6 c2 01             	test   $0x1,%dl
  800522:	74 14                	je     800538 <fd_alloc+0x4d>
  800524:	89 c2                	mov    %eax,%edx
  800526:	c1 ea 0c             	shr    $0xc,%edx
  800529:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80052c:	f6 c2 01             	test   $0x1,%dl
  80052f:	75 10                	jne    800541 <fd_alloc+0x56>
  800531:	eb 05                	jmp    800538 <fd_alloc+0x4d>
  800533:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800538:	89 1f                	mov    %ebx,(%edi)
  80053a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80053f:	eb 17                	jmp    800558 <fd_alloc+0x6d>
  800541:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800546:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80054b:	75 c8                	jne    800515 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80054d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800553:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800558:	5b                   	pop    %ebx
  800559:	5e                   	pop    %esi
  80055a:	5f                   	pop    %edi
  80055b:	5d                   	pop    %ebp
  80055c:	c3                   	ret    

0080055d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800560:	8b 45 08             	mov    0x8(%ebp),%eax
  800563:	83 f8 1f             	cmp    $0x1f,%eax
  800566:	77 36                	ja     80059e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800568:	05 00 00 0d 00       	add    $0xd0000,%eax
  80056d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800570:	89 c2                	mov    %eax,%edx
  800572:	c1 ea 16             	shr    $0x16,%edx
  800575:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80057c:	f6 c2 01             	test   $0x1,%dl
  80057f:	74 1d                	je     80059e <fd_lookup+0x41>
  800581:	89 c2                	mov    %eax,%edx
  800583:	c1 ea 0c             	shr    $0xc,%edx
  800586:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80058d:	f6 c2 01             	test   $0x1,%dl
  800590:	74 0c                	je     80059e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800592:	8b 55 0c             	mov    0xc(%ebp),%edx
  800595:	89 02                	mov    %eax,(%edx)
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80059c:	eb 05                	jmp    8005a3 <fd_lookup+0x46>
  80059e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005a3:	5d                   	pop    %ebp
  8005a4:	c3                   	ret    

008005a5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8005a5:	55                   	push   %ebp
  8005a6:	89 e5                	mov    %esp,%ebp
  8005a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8005ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005b5:	89 04 24             	mov    %eax,(%esp)
  8005b8:	e8 a0 ff ff ff       	call   80055d <fd_lookup>
  8005bd:	85 c0                	test   %eax,%eax
  8005bf:	78 0e                	js     8005cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8005c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8005c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005c7:	89 50 04             	mov    %edx,0x4(%eax)
  8005ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8005cf:	c9                   	leave  
  8005d0:	c3                   	ret    

008005d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	56                   	push   %esi
  8005d5:	53                   	push   %ebx
  8005d6:	83 ec 10             	sub    $0x10,%esp
  8005d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8005dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8005df:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8005e4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8005e9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8005ef:	75 11                	jne    800602 <dev_lookup+0x31>
  8005f1:	eb 04                	jmp    8005f7 <dev_lookup+0x26>
  8005f3:	39 08                	cmp    %ecx,(%eax)
  8005f5:	75 10                	jne    800607 <dev_lookup+0x36>
			*dev = devtab[i];
  8005f7:	89 03                	mov    %eax,(%ebx)
  8005f9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8005fe:	66 90                	xchg   %ax,%ax
  800600:	eb 36                	jmp    800638 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800602:	be 54 23 80 00       	mov    $0x802354,%esi
  800607:	83 c2 01             	add    $0x1,%edx
  80060a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80060d:	85 c0                	test   %eax,%eax
  80060f:	75 e2                	jne    8005f3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800611:	a1 08 40 80 00       	mov    0x804008,%eax
  800616:	8b 40 48             	mov    0x48(%eax),%eax
  800619:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80061d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800621:	c7 04 24 d8 22 80 00 	movl   $0x8022d8,(%esp)
  800628:	e8 40 0d 00 00       	call   80136d <cprintf>
	*dev = 0;
  80062d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800633:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	5b                   	pop    %ebx
  80063c:	5e                   	pop    %esi
  80063d:	5d                   	pop    %ebp
  80063e:	c3                   	ret    

0080063f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	53                   	push   %ebx
  800643:	83 ec 24             	sub    $0x24,%esp
  800646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80064c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800650:	8b 45 08             	mov    0x8(%ebp),%eax
  800653:	89 04 24             	mov    %eax,(%esp)
  800656:	e8 02 ff ff ff       	call   80055d <fd_lookup>
  80065b:	85 c0                	test   %eax,%eax
  80065d:	78 53                	js     8006b2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80065f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800662:	89 44 24 04          	mov    %eax,0x4(%esp)
  800666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 04 24             	mov    %eax,(%esp)
  80066e:	e8 5e ff ff ff       	call   8005d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800673:	85 c0                	test   %eax,%eax
  800675:	78 3b                	js     8006b2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800677:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80067c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80067f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800683:	74 2d                	je     8006b2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800685:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800688:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80068f:	00 00 00 
	stat->st_isdir = 0;
  800692:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800699:	00 00 00 
	stat->st_dev = dev;
  80069c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8006a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006ac:	89 14 24             	mov    %edx,(%esp)
  8006af:	ff 50 14             	call   *0x14(%eax)
}
  8006b2:	83 c4 24             	add    $0x24,%esp
  8006b5:	5b                   	pop    %ebx
  8006b6:	5d                   	pop    %ebp
  8006b7:	c3                   	ret    

008006b8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	53                   	push   %ebx
  8006bc:	83 ec 24             	sub    $0x24,%esp
  8006bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c9:	89 1c 24             	mov    %ebx,(%esp)
  8006cc:	e8 8c fe ff ff       	call   80055d <fd_lookup>
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	78 5f                	js     800734 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	89 04 24             	mov    %eax,(%esp)
  8006e4:	e8 e8 fe ff ff       	call   8005d1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 47                	js     800734 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006f0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8006f4:	75 23                	jne    800719 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8006f6:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8006fb:	8b 40 48             	mov    0x48(%eax),%eax
  8006fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800702:	89 44 24 04          	mov    %eax,0x4(%esp)
  800706:	c7 04 24 f8 22 80 00 	movl   $0x8022f8,(%esp)
  80070d:	e8 5b 0c 00 00       	call   80136d <cprintf>
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800717:	eb 1b                	jmp    800734 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80071c:	8b 48 18             	mov    0x18(%eax),%ecx
  80071f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800724:	85 c9                	test   %ecx,%ecx
  800726:	74 0c                	je     800734 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800728:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80072f:	89 14 24             	mov    %edx,(%esp)
  800732:	ff d1                	call   *%ecx
}
  800734:	83 c4 24             	add    $0x24,%esp
  800737:	5b                   	pop    %ebx
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	53                   	push   %ebx
  80073e:	83 ec 24             	sub    $0x24,%esp
  800741:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800744:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074b:	89 1c 24             	mov    %ebx,(%esp)
  80074e:	e8 0a fe ff ff       	call   80055d <fd_lookup>
  800753:	85 c0                	test   %eax,%eax
  800755:	78 66                	js     8007bd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800761:	8b 00                	mov    (%eax),%eax
  800763:	89 04 24             	mov    %eax,(%esp)
  800766:	e8 66 fe ff ff       	call   8005d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80076b:	85 c0                	test   %eax,%eax
  80076d:	78 4e                	js     8007bd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80076f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800772:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800776:	75 23                	jne    80079b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800778:	a1 08 40 80 00       	mov    0x804008,%eax
  80077d:	8b 40 48             	mov    0x48(%eax),%eax
  800780:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800784:	89 44 24 04          	mov    %eax,0x4(%esp)
  800788:	c7 04 24 19 23 80 00 	movl   $0x802319,(%esp)
  80078f:	e8 d9 0b 00 00       	call   80136d <cprintf>
  800794:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800799:	eb 22                	jmp    8007bd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079e:	8b 48 0c             	mov    0xc(%eax),%ecx
  8007a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007a6:	85 c9                	test   %ecx,%ecx
  8007a8:	74 13                	je     8007bd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b8:	89 14 24             	mov    %edx,(%esp)
  8007bb:	ff d1                	call   *%ecx
}
  8007bd:	83 c4 24             	add    $0x24,%esp
  8007c0:	5b                   	pop    %ebx
  8007c1:	5d                   	pop    %ebp
  8007c2:	c3                   	ret    

008007c3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8007c3:	55                   	push   %ebp
  8007c4:	89 e5                	mov    %esp,%ebp
  8007c6:	53                   	push   %ebx
  8007c7:	83 ec 24             	sub    $0x24,%esp
  8007ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d4:	89 1c 24             	mov    %ebx,(%esp)
  8007d7:	e8 81 fd ff ff       	call   80055d <fd_lookup>
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 6b                	js     80084b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	8b 00                	mov    (%eax),%eax
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	e8 dd fd ff ff       	call   8005d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007f4:	85 c0                	test   %eax,%eax
  8007f6:	78 53                	js     80084b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8007f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8007fb:	8b 42 08             	mov    0x8(%edx),%eax
  8007fe:	83 e0 03             	and    $0x3,%eax
  800801:	83 f8 01             	cmp    $0x1,%eax
  800804:	75 23                	jne    800829 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800806:	a1 08 40 80 00       	mov    0x804008,%eax
  80080b:	8b 40 48             	mov    0x48(%eax),%eax
  80080e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800812:	89 44 24 04          	mov    %eax,0x4(%esp)
  800816:	c7 04 24 36 23 80 00 	movl   $0x802336,(%esp)
  80081d:	e8 4b 0b 00 00       	call   80136d <cprintf>
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800827:	eb 22                	jmp    80084b <read+0x88>
	}
	if (!dev->dev_read)
  800829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80082c:	8b 48 08             	mov    0x8(%eax),%ecx
  80082f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800834:	85 c9                	test   %ecx,%ecx
  800836:	74 13                	je     80084b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800838:	8b 45 10             	mov    0x10(%ebp),%eax
  80083b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800842:	89 44 24 04          	mov    %eax,0x4(%esp)
  800846:	89 14 24             	mov    %edx,(%esp)
  800849:	ff d1                	call   *%ecx
}
  80084b:	83 c4 24             	add    $0x24,%esp
  80084e:	5b                   	pop    %ebx
  80084f:	5d                   	pop    %ebp
  800850:	c3                   	ret    

00800851 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	57                   	push   %edi
  800855:	56                   	push   %esi
  800856:	53                   	push   %ebx
  800857:	83 ec 1c             	sub    $0x1c,%esp
  80085a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80085d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800860:	ba 00 00 00 00       	mov    $0x0,%edx
  800865:	bb 00 00 00 00       	mov    $0x0,%ebx
  80086a:	b8 00 00 00 00       	mov    $0x0,%eax
  80086f:	85 f6                	test   %esi,%esi
  800871:	74 29                	je     80089c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800873:	89 f0                	mov    %esi,%eax
  800875:	29 d0                	sub    %edx,%eax
  800877:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087b:	03 55 0c             	add    0xc(%ebp),%edx
  80087e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800882:	89 3c 24             	mov    %edi,(%esp)
  800885:	e8 39 ff ff ff       	call   8007c3 <read>
		if (m < 0)
  80088a:	85 c0                	test   %eax,%eax
  80088c:	78 0e                	js     80089c <readn+0x4b>
			return m;
		if (m == 0)
  80088e:	85 c0                	test   %eax,%eax
  800890:	74 08                	je     80089a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800892:	01 c3                	add    %eax,%ebx
  800894:	89 da                	mov    %ebx,%edx
  800896:	39 f3                	cmp    %esi,%ebx
  800898:	72 d9                	jb     800873 <readn+0x22>
  80089a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80089c:	83 c4 1c             	add    $0x1c,%esp
  80089f:	5b                   	pop    %ebx
  8008a0:	5e                   	pop    %esi
  8008a1:	5f                   	pop    %edi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	83 ec 28             	sub    $0x28,%esp
  8008aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8008ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8008b0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008b3:	89 34 24             	mov    %esi,(%esp)
  8008b6:	e8 05 fc ff ff       	call   8004c0 <fd2num>
  8008bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	89 04 24             	mov    %eax,(%esp)
  8008c5:	e8 93 fc ff ff       	call   80055d <fd_lookup>
  8008ca:	89 c3                	mov    %eax,%ebx
  8008cc:	85 c0                	test   %eax,%eax
  8008ce:	78 05                	js     8008d5 <fd_close+0x31>
  8008d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008d3:	74 0e                	je     8008e3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8008d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8008d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8008de:	0f 44 d8             	cmove  %eax,%ebx
  8008e1:	eb 3d                	jmp    800920 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ea:	8b 06                	mov    (%esi),%eax
  8008ec:	89 04 24             	mov    %eax,(%esp)
  8008ef:	e8 dd fc ff ff       	call   8005d1 <dev_lookup>
  8008f4:	89 c3                	mov    %eax,%ebx
  8008f6:	85 c0                	test   %eax,%eax
  8008f8:	78 16                	js     800910 <fd_close+0x6c>
		if (dev->dev_close)
  8008fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008fd:	8b 40 10             	mov    0x10(%eax),%eax
  800900:	bb 00 00 00 00       	mov    $0x0,%ebx
  800905:	85 c0                	test   %eax,%eax
  800907:	74 07                	je     800910 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800909:	89 34 24             	mov    %esi,(%esp)
  80090c:	ff d0                	call   *%eax
  80090e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800910:	89 74 24 04          	mov    %esi,0x4(%esp)
  800914:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80091b:	e8 9c f9 ff ff       	call   8002bc <sys_page_unmap>
	return r;
}
  800920:	89 d8                	mov    %ebx,%eax
  800922:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800925:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800928:	89 ec                	mov    %ebp,%esp
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800932:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800935:	89 44 24 04          	mov    %eax,0x4(%esp)
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	89 04 24             	mov    %eax,(%esp)
  80093f:	e8 19 fc ff ff       	call   80055d <fd_lookup>
  800944:	85 c0                	test   %eax,%eax
  800946:	78 13                	js     80095b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800948:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80094f:	00 
  800950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800953:	89 04 24             	mov    %eax,(%esp)
  800956:	e8 49 ff ff ff       	call   8008a4 <fd_close>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 18             	sub    $0x18,%esp
  800963:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800966:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800969:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800970:	00 
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	89 04 24             	mov    %eax,(%esp)
  800977:	e8 78 03 00 00       	call   800cf4 <open>
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	85 c0                	test   %eax,%eax
  800980:	78 1b                	js     80099d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800982:	8b 45 0c             	mov    0xc(%ebp),%eax
  800985:	89 44 24 04          	mov    %eax,0x4(%esp)
  800989:	89 1c 24             	mov    %ebx,(%esp)
  80098c:	e8 ae fc ff ff       	call   80063f <fstat>
  800991:	89 c6                	mov    %eax,%esi
	close(fd);
  800993:	89 1c 24             	mov    %ebx,(%esp)
  800996:	e8 91 ff ff ff       	call   80092c <close>
  80099b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80099d:	89 d8                	mov    %ebx,%eax
  80099f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8009a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8009a5:	89 ec                	mov    %ebp,%esp
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	53                   	push   %ebx
  8009ad:	83 ec 14             	sub    $0x14,%esp
  8009b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8009b5:	89 1c 24             	mov    %ebx,(%esp)
  8009b8:	e8 6f ff ff ff       	call   80092c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009bd:	83 c3 01             	add    $0x1,%ebx
  8009c0:	83 fb 20             	cmp    $0x20,%ebx
  8009c3:	75 f0                	jne    8009b5 <close_all+0xc>
		close(i);
}
  8009c5:	83 c4 14             	add    $0x14,%esp
  8009c8:	5b                   	pop    %ebx
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 58             	sub    $0x58,%esp
  8009d1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8009d4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8009d7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8009da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8009dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e7:	89 04 24             	mov    %eax,(%esp)
  8009ea:	e8 6e fb ff ff       	call   80055d <fd_lookup>
  8009ef:	89 c3                	mov    %eax,%ebx
  8009f1:	85 c0                	test   %eax,%eax
  8009f3:	0f 88 e0 00 00 00    	js     800ad9 <dup+0x10e>
		return r;
	close(newfdnum);
  8009f9:	89 3c 24             	mov    %edi,(%esp)
  8009fc:	e8 2b ff ff ff       	call   80092c <close>

	newfd = INDEX2FD(newfdnum);
  800a01:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a07:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a0d:	89 04 24             	mov    %eax,(%esp)
  800a10:	e8 bb fa ff ff       	call   8004d0 <fd2data>
  800a15:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a17:	89 34 24             	mov    %esi,(%esp)
  800a1a:	e8 b1 fa ff ff       	call   8004d0 <fd2data>
  800a1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800a22:	89 da                	mov    %ebx,%edx
  800a24:	89 d8                	mov    %ebx,%eax
  800a26:	c1 e8 16             	shr    $0x16,%eax
  800a29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a30:	a8 01                	test   $0x1,%al
  800a32:	74 43                	je     800a77 <dup+0xac>
  800a34:	c1 ea 0c             	shr    $0xc,%edx
  800a37:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a3e:	a8 01                	test   $0x1,%al
  800a40:	74 35                	je     800a77 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a42:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a49:	25 07 0e 00 00       	and    $0xe07,%eax
  800a4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a60:	00 
  800a61:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800a65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a6c:	e8 83 f8 ff ff       	call   8002f4 <sys_page_map>
  800a71:	89 c3                	mov    %eax,%ebx
  800a73:	85 c0                	test   %eax,%eax
  800a75:	78 3f                	js     800ab6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a7a:	89 c2                	mov    %eax,%edx
  800a7c:	c1 ea 0c             	shr    $0xc,%edx
  800a7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a86:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a8c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a90:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a9b:	00 
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aa7:	e8 48 f8 ff ff       	call   8002f4 <sys_page_map>
  800aac:	89 c3                	mov    %eax,%ebx
  800aae:	85 c0                	test   %eax,%eax
  800ab0:	78 04                	js     800ab6 <dup+0xeb>
  800ab2:	89 fb                	mov    %edi,%ebx
  800ab4:	eb 23                	jmp    800ad9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ab6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ac1:	e8 f6 f7 ff ff       	call   8002bc <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ac6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800acd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad4:	e8 e3 f7 ff ff       	call   8002bc <sys_page_unmap>
	return r;
}
  800ad9:	89 d8                	mov    %ebx,%eax
  800adb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ade:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ae1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ae4:	89 ec                	mov    %ebp,%esp
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	83 ec 18             	sub    $0x18,%esp
  800aee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800af1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800af4:	89 c3                	mov    %eax,%ebx
  800af6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800af8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800aff:	75 11                	jne    800b12 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b01:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b08:	e8 93 13 00 00       	call   801ea0 <ipc_find_env>
  800b0d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b12:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b19:	00 
  800b1a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b21:	00 
  800b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b26:	a1 00 40 80 00       	mov    0x804000,%eax
  800b2b:	89 04 24             	mov    %eax,(%esp)
  800b2e:	e8 b6 13 00 00       	call   801ee9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b3a:	00 
  800b3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b46:	e8 09 14 00 00       	call   801f54 <ipc_recv>
}
  800b4b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b4e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b51:	89 ec                	mov    %ebp,%esp
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	8b 40 0c             	mov    0xc(%eax),%eax
  800b61:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b69:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b73:	b8 02 00 00 00       	mov    $0x2,%eax
  800b78:	e8 6b ff ff ff       	call   800ae8 <fsipc>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	8b 40 0c             	mov    0xc(%eax),%eax
  800b8b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 06 00 00 00       	mov    $0x6,%eax
  800b9a:	e8 49 ff ff ff       	call   800ae8 <fsipc>
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb1:	e8 32 ff ff ff       	call   800ae8 <fsipc>
}
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 14             	sub    $0x14,%esp
  800bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc5:	8b 40 0c             	mov    0xc(%eax),%eax
  800bc8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  800bd7:	e8 0c ff ff ff       	call   800ae8 <fsipc>
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	78 2b                	js     800c0b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800be0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800be7:	00 
  800be8:	89 1c 24             	mov    %ebx,(%esp)
  800beb:	e8 ba 0e 00 00       	call   801aaa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800bf0:	a1 80 50 80 00       	mov    0x805080,%eax
  800bf5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800bfb:	a1 84 50 80 00       	mov    0x805084,%eax
  800c00:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800c06:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800c0b:	83 c4 14             	add    $0x14,%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	83 ec 18             	sub    $0x18,%esp
  800c17:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	8b 52 0c             	mov    0xc(%edx),%edx
  800c20:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800c26:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800c2b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800c30:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800c35:	0f 47 c2             	cmova  %edx,%eax
  800c38:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c43:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800c4a:	e8 46 10 00 00       	call   801c95 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800c4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c54:	b8 04 00 00 00       	mov    $0x4,%eax
  800c59:	e8 8a fe ff ff       	call   800ae8 <fsipc>
}
  800c5e:	c9                   	leave  
  800c5f:	c3                   	ret    

00800c60 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	53                   	push   %ebx
  800c64:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800c67:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6a:	8b 40 0c             	mov    0xc(%eax),%eax
  800c6d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800c72:	8b 45 10             	mov    0x10(%ebp),%eax
  800c75:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c84:	e8 5f fe ff ff       	call   800ae8 <fsipc>
  800c89:	89 c3                	mov    %eax,%ebx
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	78 17                	js     800ca6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c93:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c9a:	00 
  800c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9e:	89 04 24             	mov    %eax,(%esp)
  800ca1:	e8 ef 0f 00 00       	call   801c95 <memmove>
  return r;	
}
  800ca6:	89 d8                	mov    %ebx,%eax
  800ca8:	83 c4 14             	add    $0x14,%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5d                   	pop    %ebp
  800cad:	c3                   	ret    

00800cae <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 14             	sub    $0x14,%esp
  800cb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cb8:	89 1c 24             	mov    %ebx,(%esp)
  800cbb:	e8 a0 0d 00 00       	call   801a60 <strlen>
  800cc0:	89 c2                	mov    %eax,%edx
  800cc2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800cc7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800ccd:	7f 1f                	jg     800cee <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800ccf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800cd3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cda:	e8 cb 0d 00 00       	call   801aaa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 07 00 00 00       	mov    $0x7,%eax
  800ce9:	e8 fa fd ff ff       	call   800ae8 <fsipc>
}
  800cee:	83 c4 14             	add    $0x14,%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 28             	sub    $0x28,%esp
  800cfa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800cfd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d00:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800d03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d06:	89 04 24             	mov    %eax,(%esp)
  800d09:	e8 dd f7 ff ff       	call   8004eb <fd_alloc>
  800d0e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800d10:	85 c0                	test   %eax,%eax
  800d12:	0f 88 89 00 00 00    	js     800da1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d18:	89 34 24             	mov    %esi,(%esp)
  800d1b:	e8 40 0d 00 00       	call   801a60 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800d20:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d25:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800d2a:	7f 75                	jg     800da1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800d2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d30:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d37:	e8 6e 0d 00 00       	call   801aaa <strcpy>
  fsipcbuf.open.req_omode = mode;
  800d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800d44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d47:	b8 01 00 00 00       	mov    $0x1,%eax
  800d4c:	e8 97 fd ff ff       	call   800ae8 <fsipc>
  800d51:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800d53:	85 c0                	test   %eax,%eax
  800d55:	78 0f                	js     800d66 <open+0x72>
  return fd2num(fd);
  800d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d5a:	89 04 24             	mov    %eax,(%esp)
  800d5d:	e8 5e f7 ff ff       	call   8004c0 <fd2num>
  800d62:	89 c3                	mov    %eax,%ebx
  800d64:	eb 3b                	jmp    800da1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800d66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d6d:	00 
  800d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d71:	89 04 24             	mov    %eax,(%esp)
  800d74:	e8 2b fb ff ff       	call   8008a4 <fd_close>
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	74 24                	je     800da1 <open+0xad>
  800d7d:	c7 44 24 0c 60 23 80 	movl   $0x802360,0xc(%esp)
  800d84:	00 
  800d85:	c7 44 24 08 75 23 80 	movl   $0x802375,0x8(%esp)
  800d8c:	00 
  800d8d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800d94:	00 
  800d95:	c7 04 24 8a 23 80 00 	movl   $0x80238a,(%esp)
  800d9c:	e8 13 05 00 00       	call   8012b4 <_panic>
  return r;
}
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800da6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800da9:	89 ec                	mov    %ebp,%esp
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    
  800dad:	00 00                	add    %al,(%eax)
	...

00800db0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800db6:	c7 44 24 04 95 23 80 	movl   $0x802395,0x4(%esp)
  800dbd:	00 
  800dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc1:	89 04 24             	mov    %eax,(%esp)
  800dc4:	e8 e1 0c 00 00       	call   801aaa <strcpy>
	return 0;
}
  800dc9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	53                   	push   %ebx
  800dd4:	83 ec 14             	sub    $0x14,%esp
  800dd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800dda:	89 1c 24             	mov    %ebx,(%esp)
  800ddd:	e8 02 12 00 00       	call   801fe4 <pageref>
  800de2:	89 c2                	mov    %eax,%edx
  800de4:	b8 00 00 00 00       	mov    $0x0,%eax
  800de9:	83 fa 01             	cmp    $0x1,%edx
  800dec:	75 0b                	jne    800df9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800dee:	8b 43 0c             	mov    0xc(%ebx),%eax
  800df1:	89 04 24             	mov    %eax,(%esp)
  800df4:	e8 b9 02 00 00       	call   8010b2 <nsipc_close>
	else
		return 0;
}
  800df9:	83 c4 14             	add    $0x14,%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800e05:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e0c:	00 
  800e0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e10:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	8b 40 0c             	mov    0xc(%eax),%eax
  800e21:	89 04 24             	mov    %eax,(%esp)
  800e24:	e8 c5 02 00 00       	call   8010ee <nsipc_send>
}
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    

00800e2b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800e2b:	55                   	push   %ebp
  800e2c:	89 e5                	mov    %esp,%ebp
  800e2e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800e31:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e38:	00 
  800e39:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e43:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e4d:	89 04 24             	mov    %eax,(%esp)
  800e50:	e8 0c 03 00 00       	call   801161 <nsipc_recv>
}
  800e55:	c9                   	leave  
  800e56:	c3                   	ret    

00800e57 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800e57:	55                   	push   %ebp
  800e58:	89 e5                	mov    %esp,%ebp
  800e5a:	56                   	push   %esi
  800e5b:	53                   	push   %ebx
  800e5c:	83 ec 20             	sub    $0x20,%esp
  800e5f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e64:	89 04 24             	mov    %eax,(%esp)
  800e67:	e8 7f f6 ff ff       	call   8004eb <fd_alloc>
  800e6c:	89 c3                	mov    %eax,%ebx
  800e6e:	85 c0                	test   %eax,%eax
  800e70:	78 21                	js     800e93 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800e72:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800e79:	00 
  800e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e81:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e88:	e8 a0 f4 ff ff       	call   80032d <sys_page_alloc>
  800e8d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	79 0a                	jns    800e9d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  800e93:	89 34 24             	mov    %esi,(%esp)
  800e96:	e8 17 02 00 00       	call   8010b2 <nsipc_close>
		return r;
  800e9b:	eb 28                	jmp    800ec5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800e9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebb:	89 04 24             	mov    %eax,(%esp)
  800ebe:	e8 fd f5 ff ff       	call   8004c0 <fd2num>
  800ec3:	89 c3                	mov    %eax,%ebx
}
  800ec5:	89 d8                	mov    %ebx,%eax
  800ec7:	83 c4 20             	add    $0x20,%esp
  800eca:	5b                   	pop    %ebx
  800ecb:	5e                   	pop    %esi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
  800ed1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800ed4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800edb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ede:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	89 04 24             	mov    %eax,(%esp)
  800ee8:	e8 79 01 00 00       	call   801066 <nsipc_socket>
  800eed:	85 c0                	test   %eax,%eax
  800eef:	78 05                	js     800ef6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800ef1:	e8 61 ff ff ff       	call   800e57 <alloc_sockfd>
}
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800efe:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f01:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f05:	89 04 24             	mov    %eax,(%esp)
  800f08:	e8 50 f6 ff ff       	call   80055d <fd_lookup>
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 15                	js     800f26 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f14:	8b 0a                	mov    (%edx),%ecx
  800f16:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f1b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  800f21:	75 03                	jne    800f26 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f23:	8b 42 0c             	mov    0xc(%edx),%eax
}
  800f26:	c9                   	leave  
  800f27:	c3                   	ret    

00800f28 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	e8 c2 ff ff ff       	call   800ef8 <fd2sockid>
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 0f                	js     800f49 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f3d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f41:	89 04 24             	mov    %eax,(%esp)
  800f44:	e8 47 01 00 00       	call   801090 <nsipc_listen>
}
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    

00800f4b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f51:	8b 45 08             	mov    0x8(%ebp),%eax
  800f54:	e8 9f ff ff ff       	call   800ef8 <fd2sockid>
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 16                	js     800f73 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800f5d:	8b 55 10             	mov    0x10(%ebp),%edx
  800f60:	89 54 24 08          	mov    %edx,0x8(%esp)
  800f64:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f67:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f6b:	89 04 24             	mov    %eax,(%esp)
  800f6e:	e8 6e 02 00 00       	call   8011e1 <nsipc_connect>
}
  800f73:	c9                   	leave  
  800f74:	c3                   	ret    

00800f75 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7e:	e8 75 ff ff ff       	call   800ef8 <fd2sockid>
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 0f                	js     800f96 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800f87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8a:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f8e:	89 04 24             	mov    %eax,(%esp)
  800f91:	e8 36 01 00 00       	call   8010cc <nsipc_shutdown>
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    

00800f98 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa1:	e8 52 ff ff ff       	call   800ef8 <fd2sockid>
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 16                	js     800fc0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800faa:	8b 55 10             	mov    0x10(%ebp),%edx
  800fad:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fb8:	89 04 24             	mov    %eax,(%esp)
  800fbb:	e8 60 02 00 00       	call   801220 <nsipc_bind>
}
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcb:	e8 28 ff ff ff       	call   800ef8 <fd2sockid>
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 1f                	js     800ff3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800fd4:	8b 55 10             	mov    0x10(%ebp),%edx
  800fd7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fdb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fde:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fe2:	89 04 24             	mov    %eax,(%esp)
  800fe5:	e8 75 02 00 00       	call   80125f <nsipc_accept>
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 05                	js     800ff3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  800fee:	e8 64 fe ff ff       	call   800e57 <alloc_sockfd>
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    
	...

00801000 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	53                   	push   %ebx
  801004:	83 ec 14             	sub    $0x14,%esp
  801007:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801009:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801010:	75 11                	jne    801023 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801012:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801019:	e8 82 0e 00 00       	call   801ea0 <ipc_find_env>
  80101e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801023:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80102a:	00 
  80102b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801032:	00 
  801033:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801037:	a1 04 40 80 00       	mov    0x804004,%eax
  80103c:	89 04 24             	mov    %eax,(%esp)
  80103f:	e8 a5 0e 00 00       	call   801ee9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801044:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104b:	00 
  80104c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801053:	00 
  801054:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80105b:	e8 f4 0e 00 00       	call   801f54 <ipc_recv>
}
  801060:	83 c4 14             	add    $0x14,%esp
  801063:	5b                   	pop    %ebx
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80106c:	8b 45 08             	mov    0x8(%ebp),%eax
  80106f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801074:	8b 45 0c             	mov    0xc(%ebp),%eax
  801077:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80107c:	8b 45 10             	mov    0x10(%ebp),%eax
  80107f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801084:	b8 09 00 00 00       	mov    $0x9,%eax
  801089:	e8 72 ff ff ff       	call   801000 <nsipc>
}
  80108e:	c9                   	leave  
  80108f:	c3                   	ret    

00801090 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801096:	8b 45 08             	mov    0x8(%ebp),%eax
  801099:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80109e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010a6:	b8 06 00 00 00       	mov    $0x6,%eax
  8010ab:	e8 50 ff ff ff       	call   801000 <nsipc>
}
  8010b0:	c9                   	leave  
  8010b1:	c3                   	ret    

008010b2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8010c0:	b8 04 00 00 00       	mov    $0x4,%eax
  8010c5:	e8 36 ff ff ff       	call   801000 <nsipc>
}
  8010ca:	c9                   	leave  
  8010cb:	c3                   	ret    

008010cc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8010cc:	55                   	push   %ebp
  8010cd:	89 e5                	mov    %esp,%ebp
  8010cf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8010da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010dd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8010e2:	b8 03 00 00 00       	mov    $0x3,%eax
  8010e7:	e8 14 ff ff ff       	call   801000 <nsipc>
}
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 14             	sub    $0x14,%esp
  8010f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801100:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801106:	7e 24                	jle    80112c <nsipc_send+0x3e>
  801108:	c7 44 24 0c a1 23 80 	movl   $0x8023a1,0xc(%esp)
  80110f:	00 
  801110:	c7 44 24 08 75 23 80 	movl   $0x802375,0x8(%esp)
  801117:	00 
  801118:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80111f:	00 
  801120:	c7 04 24 ad 23 80 00 	movl   $0x8023ad,(%esp)
  801127:	e8 88 01 00 00       	call   8012b4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80112c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801130:	8b 45 0c             	mov    0xc(%ebp),%eax
  801133:	89 44 24 04          	mov    %eax,0x4(%esp)
  801137:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80113e:	e8 52 0b 00 00       	call   801c95 <memmove>
	nsipcbuf.send.req_size = size;
  801143:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801149:	8b 45 14             	mov    0x14(%ebp),%eax
  80114c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801151:	b8 08 00 00 00       	mov    $0x8,%eax
  801156:	e8 a5 fe ff ff       	call   801000 <nsipc>
}
  80115b:	83 c4 14             	add    $0x14,%esp
  80115e:	5b                   	pop    %ebx
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 10             	sub    $0x10,%esp
  801169:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80116c:	8b 45 08             	mov    0x8(%ebp),%eax
  80116f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801174:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80117a:	8b 45 14             	mov    0x14(%ebp),%eax
  80117d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801182:	b8 07 00 00 00       	mov    $0x7,%eax
  801187:	e8 74 fe ff ff       	call   801000 <nsipc>
  80118c:	89 c3                	mov    %eax,%ebx
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 46                	js     8011d8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801192:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801197:	7f 04                	jg     80119d <nsipc_recv+0x3c>
  801199:	39 c6                	cmp    %eax,%esi
  80119b:	7d 24                	jge    8011c1 <nsipc_recv+0x60>
  80119d:	c7 44 24 0c b9 23 80 	movl   $0x8023b9,0xc(%esp)
  8011a4:	00 
  8011a5:	c7 44 24 08 75 23 80 	movl   $0x802375,0x8(%esp)
  8011ac:	00 
  8011ad:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8011b4:	00 
  8011b5:	c7 04 24 ad 23 80 00 	movl   $0x8023ad,(%esp)
  8011bc:	e8 f3 00 00 00       	call   8012b4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8011c1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011c5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8011cc:	00 
  8011cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d0:	89 04 24             	mov    %eax,(%esp)
  8011d3:	e8 bd 0a 00 00       	call   801c95 <memmove>
	}

	return r;
}
  8011d8:	89 d8                	mov    %ebx,%eax
  8011da:	83 c4 10             	add    $0x10,%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 14             	sub    $0x14,%esp
  8011e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ee:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8011f3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8011f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fe:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801205:	e8 8b 0a 00 00       	call   801c95 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80120a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801210:	b8 05 00 00 00       	mov    $0x5,%eax
  801215:	e8 e6 fd ff ff       	call   801000 <nsipc>
}
  80121a:	83 c4 14             	add    $0x14,%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	53                   	push   %ebx
  801224:	83 ec 14             	sub    $0x14,%esp
  801227:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801232:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801236:	8b 45 0c             	mov    0xc(%ebp),%eax
  801239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801244:	e8 4c 0a 00 00       	call   801c95 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801249:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80124f:	b8 02 00 00 00       	mov    $0x2,%eax
  801254:	e8 a7 fd ff ff       	call   801000 <nsipc>
}
  801259:	83 c4 14             	add    $0x14,%esp
  80125c:	5b                   	pop    %ebx
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	83 ec 18             	sub    $0x18,%esp
  801265:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801268:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80126b:	8b 45 08             	mov    0x8(%ebp),%eax
  80126e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801273:	b8 01 00 00 00       	mov    $0x1,%eax
  801278:	e8 83 fd ff ff       	call   801000 <nsipc>
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 25                	js     8012a8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801283:	be 10 60 80 00       	mov    $0x806010,%esi
  801288:	8b 06                	mov    (%esi),%eax
  80128a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80128e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801295:	00 
  801296:	8b 45 0c             	mov    0xc(%ebp),%eax
  801299:	89 04 24             	mov    %eax,(%esp)
  80129c:	e8 f4 09 00 00       	call   801c95 <memmove>
		*addrlen = ret->ret_addrlen;
  8012a1:	8b 16                	mov    (%esi),%edx
  8012a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8012a6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8012a8:	89 d8                	mov    %ebx,%eax
  8012aa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ad:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8012b0:	89 ec                	mov    %ebp,%esp
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8012bc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012bf:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8012c5:	e8 0d f1 ff ff       	call   8003d7 <sys_getenvid>
  8012ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012cd:	89 54 24 10          	mov    %edx,0x10(%esp)
  8012d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012d8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e0:	c7 04 24 d0 23 80 00 	movl   $0x8023d0,(%esp)
  8012e7:	e8 81 00 00 00       	call   80136d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8012ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8012f3:	89 04 24             	mov    %eax,(%esp)
  8012f6:	e8 11 00 00 00       	call   80130c <vcprintf>
	cprintf("\n");
  8012fb:	c7 04 24 50 23 80 00 	movl   $0x802350,(%esp)
  801302:	e8 66 00 00 00       	call   80136d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801307:	cc                   	int3   
  801308:	eb fd                	jmp    801307 <_panic+0x53>
	...

0080130c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801315:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80131c:	00 00 00 
	b.cnt = 0;
  80131f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801326:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801329:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801330:	8b 45 08             	mov    0x8(%ebp),%eax
  801333:	89 44 24 08          	mov    %eax,0x8(%esp)
  801337:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	c7 04 24 87 13 80 00 	movl   $0x801387,(%esp)
  801348:	e8 d0 01 00 00       	call   80151d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80134d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801353:	89 44 24 04          	mov    %eax,0x4(%esp)
  801357:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80135d:	89 04 24             	mov    %eax,(%esp)
  801360:	e8 21 f1 ff ff       	call   800486 <sys_cputs>

	return b.cnt;
}
  801365:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  801373:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  801376:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137a:	8b 45 08             	mov    0x8(%ebp),%eax
  80137d:	89 04 24             	mov    %eax,(%esp)
  801380:	e8 87 ff ff ff       	call   80130c <vcprintf>
	va_end(ap);

	return cnt;
}
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	53                   	push   %ebx
  80138b:	83 ec 14             	sub    $0x14,%esp
  80138e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801391:	8b 03                	mov    (%ebx),%eax
  801393:	8b 55 08             	mov    0x8(%ebp),%edx
  801396:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80139a:	83 c0 01             	add    $0x1,%eax
  80139d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80139f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013a4:	75 19                	jne    8013bf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8013a6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8013ad:	00 
  8013ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8013b1:	89 04 24             	mov    %eax,(%esp)
  8013b4:	e8 cd f0 ff ff       	call   800486 <sys_cputs>
		b->idx = 0;
  8013b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8013bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8013c3:	83 c4 14             	add    $0x14,%esp
  8013c6:	5b                   	pop    %ebx
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    
  8013c9:	00 00                	add    %al,(%eax)
  8013cb:	00 00                	add    %al,(%eax)
  8013cd:	00 00                	add    %al,(%eax)
	...

008013d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 4c             	sub    $0x4c,%esp
  8013d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8013dc:	89 d6                	mov    %edx,%esi
  8013de:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8013e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8013f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8013f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8013f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8013fb:	39 d1                	cmp    %edx,%ecx
  8013fd:	72 15                	jb     801414 <printnum+0x44>
  8013ff:	77 07                	ja     801408 <printnum+0x38>
  801401:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801404:	39 d0                	cmp    %edx,%eax
  801406:	76 0c                	jbe    801414 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801408:	83 eb 01             	sub    $0x1,%ebx
  80140b:	85 db                	test   %ebx,%ebx
  80140d:	8d 76 00             	lea    0x0(%esi),%esi
  801410:	7f 61                	jg     801473 <printnum+0xa3>
  801412:	eb 70                	jmp    801484 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801414:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801418:	83 eb 01             	sub    $0x1,%ebx
  80141b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80141f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801423:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801427:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80142b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80142e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801431:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801434:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801438:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80143f:	00 
  801440:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801443:	89 04 24             	mov    %eax,(%esp)
  801446:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801449:	89 54 24 04          	mov    %edx,0x4(%esp)
  80144d:	e8 de 0b 00 00       	call   802030 <__udivdi3>
  801452:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801455:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80145c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801460:	89 04 24             	mov    %eax,(%esp)
  801463:	89 54 24 04          	mov    %edx,0x4(%esp)
  801467:	89 f2                	mov    %esi,%edx
  801469:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80146c:	e8 5f ff ff ff       	call   8013d0 <printnum>
  801471:	eb 11                	jmp    801484 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801473:	89 74 24 04          	mov    %esi,0x4(%esp)
  801477:	89 3c 24             	mov    %edi,(%esp)
  80147a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80147d:	83 eb 01             	sub    $0x1,%ebx
  801480:	85 db                	test   %ebx,%ebx
  801482:	7f ef                	jg     801473 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801484:	89 74 24 04          	mov    %esi,0x4(%esp)
  801488:	8b 74 24 04          	mov    0x4(%esp),%esi
  80148c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80148f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801493:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80149a:	00 
  80149b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80149e:	89 14 24             	mov    %edx,(%esp)
  8014a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014a8:	e8 b3 0c 00 00       	call   802160 <__umoddi3>
  8014ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b1:	0f be 80 f3 23 80 00 	movsbl 0x8023f3(%eax),%eax
  8014b8:	89 04 24             	mov    %eax,(%esp)
  8014bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014be:	83 c4 4c             	add    $0x4c,%esp
  8014c1:	5b                   	pop    %ebx
  8014c2:	5e                   	pop    %esi
  8014c3:	5f                   	pop    %edi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    

008014c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8014c9:	83 fa 01             	cmp    $0x1,%edx
  8014cc:	7e 0e                	jle    8014dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8014ce:	8b 10                	mov    (%eax),%edx
  8014d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8014d3:	89 08                	mov    %ecx,(%eax)
  8014d5:	8b 02                	mov    (%edx),%eax
  8014d7:	8b 52 04             	mov    0x4(%edx),%edx
  8014da:	eb 22                	jmp    8014fe <getuint+0x38>
	else if (lflag)
  8014dc:	85 d2                	test   %edx,%edx
  8014de:	74 10                	je     8014f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8014e0:	8b 10                	mov    (%eax),%edx
  8014e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014e5:	89 08                	mov    %ecx,(%eax)
  8014e7:	8b 02                	mov    (%edx),%eax
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ee:	eb 0e                	jmp    8014fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8014f0:	8b 10                	mov    (%eax),%edx
  8014f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8014f5:	89 08                	mov    %ecx,(%eax)
  8014f7:	8b 02                	mov    (%edx),%eax
  8014f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8014fe:	5d                   	pop    %ebp
  8014ff:	c3                   	ret    

00801500 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801500:	55                   	push   %ebp
  801501:	89 e5                	mov    %esp,%ebp
  801503:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801506:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80150a:	8b 10                	mov    (%eax),%edx
  80150c:	3b 50 04             	cmp    0x4(%eax),%edx
  80150f:	73 0a                	jae    80151b <sprintputch+0x1b>
		*b->buf++ = ch;
  801511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801514:	88 0a                	mov    %cl,(%edx)
  801516:	83 c2 01             	add    $0x1,%edx
  801519:	89 10                	mov    %edx,(%eax)
}
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 5c             	sub    $0x5c,%esp
  801526:	8b 7d 08             	mov    0x8(%ebp),%edi
  801529:	8b 75 0c             	mov    0xc(%ebp),%esi
  80152c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80152f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801536:	eb 11                	jmp    801549 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801538:	85 c0                	test   %eax,%eax
  80153a:	0f 84 68 04 00 00    	je     8019a8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  801540:	89 74 24 04          	mov    %esi,0x4(%esp)
  801544:	89 04 24             	mov    %eax,(%esp)
  801547:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801549:	0f b6 03             	movzbl (%ebx),%eax
  80154c:	83 c3 01             	add    $0x1,%ebx
  80154f:	83 f8 25             	cmp    $0x25,%eax
  801552:	75 e4                	jne    801538 <vprintfmt+0x1b>
  801554:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80155b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  801562:	b9 00 00 00 00       	mov    $0x0,%ecx
  801567:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80156b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801572:	eb 06                	jmp    80157a <vprintfmt+0x5d>
  801574:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  801578:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80157a:	0f b6 13             	movzbl (%ebx),%edx
  80157d:	0f b6 c2             	movzbl %dl,%eax
  801580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801583:	8d 43 01             	lea    0x1(%ebx),%eax
  801586:	83 ea 23             	sub    $0x23,%edx
  801589:	80 fa 55             	cmp    $0x55,%dl
  80158c:	0f 87 f9 03 00 00    	ja     80198b <vprintfmt+0x46e>
  801592:	0f b6 d2             	movzbl %dl,%edx
  801595:	ff 24 95 e0 25 80 00 	jmp    *0x8025e0(,%edx,4)
  80159c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8015a0:	eb d6                	jmp    801578 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015a5:	83 ea 30             	sub    $0x30,%edx
  8015a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8015ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015b1:	83 fb 09             	cmp    $0x9,%ebx
  8015b4:	77 54                	ja     80160a <vprintfmt+0xed>
  8015b6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8015b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8015bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8015c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8015c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015cc:	83 fb 09             	cmp    $0x9,%ebx
  8015cf:	76 eb                	jbe    8015bc <vprintfmt+0x9f>
  8015d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8015d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8015d7:	eb 31                	jmp    80160a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8015d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8015dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8015df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8015e2:	8b 12                	mov    (%edx),%edx
  8015e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8015e7:	eb 21                	jmp    80160a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8015e9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8015ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8015f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8015f9:	e9 7a ff ff ff       	jmp    801578 <vprintfmt+0x5b>
  8015fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801605:	e9 6e ff ff ff       	jmp    801578 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80160a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80160e:	0f 89 64 ff ff ff    	jns    801578 <vprintfmt+0x5b>
  801614:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801617:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80161a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80161d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801620:	e9 53 ff ff ff       	jmp    801578 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801625:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  801628:	e9 4b ff ff ff       	jmp    801578 <vprintfmt+0x5b>
  80162d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801630:	8b 45 14             	mov    0x14(%ebp),%eax
  801633:	8d 50 04             	lea    0x4(%eax),%edx
  801636:	89 55 14             	mov    %edx,0x14(%ebp)
  801639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80163d:	8b 00                	mov    (%eax),%eax
  80163f:	89 04 24             	mov    %eax,(%esp)
  801642:	ff d7                	call   *%edi
  801644:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801647:	e9 fd fe ff ff       	jmp    801549 <vprintfmt+0x2c>
  80164c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80164f:	8b 45 14             	mov    0x14(%ebp),%eax
  801652:	8d 50 04             	lea    0x4(%eax),%edx
  801655:	89 55 14             	mov    %edx,0x14(%ebp)
  801658:	8b 00                	mov    (%eax),%eax
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	c1 fa 1f             	sar    $0x1f,%edx
  80165f:	31 d0                	xor    %edx,%eax
  801661:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801663:	83 f8 0f             	cmp    $0xf,%eax
  801666:	7f 0b                	jg     801673 <vprintfmt+0x156>
  801668:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  80166f:	85 d2                	test   %edx,%edx
  801671:	75 20                	jne    801693 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  801673:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801677:	c7 44 24 08 04 24 80 	movl   $0x802404,0x8(%esp)
  80167e:	00 
  80167f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801683:	89 3c 24             	mov    %edi,(%esp)
  801686:	e8 a5 03 00 00       	call   801a30 <printfmt>
  80168b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80168e:	e9 b6 fe ff ff       	jmp    801549 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801697:	c7 44 24 08 87 23 80 	movl   $0x802387,0x8(%esp)
  80169e:	00 
  80169f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016a3:	89 3c 24             	mov    %edi,(%esp)
  8016a6:	e8 85 03 00 00       	call   801a30 <printfmt>
  8016ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016ae:	e9 96 fe ff ff       	jmp    801549 <vprintfmt+0x2c>
  8016b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016b6:	89 c3                	mov    %eax,%ebx
  8016b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8016bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8016c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8016c4:	8d 50 04             	lea    0x4(%eax),%edx
  8016c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8016ca:	8b 00                	mov    (%eax),%eax
  8016cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	b8 0d 24 80 00       	mov    $0x80240d,%eax
  8016d6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8016da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8016dd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8016e1:	7e 06                	jle    8016e9 <vprintfmt+0x1cc>
  8016e3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8016e7:	75 13                	jne    8016fc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8016e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016ec:	0f be 02             	movsbl (%edx),%eax
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	0f 85 a2 00 00 00    	jne    801799 <vprintfmt+0x27c>
  8016f7:	e9 8f 00 00 00       	jmp    80178b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8016fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801700:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801703:	89 0c 24             	mov    %ecx,(%esp)
  801706:	e8 70 03 00 00       	call   801a7b <strnlen>
  80170b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80170e:	29 c2                	sub    %eax,%edx
  801710:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801713:	85 d2                	test   %edx,%edx
  801715:	7e d2                	jle    8016e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  801717:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80171b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80171e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  801721:	89 d3                	mov    %edx,%ebx
  801723:	89 74 24 04          	mov    %esi,0x4(%esp)
  801727:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80172a:	89 04 24             	mov    %eax,(%esp)
  80172d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80172f:	83 eb 01             	sub    $0x1,%ebx
  801732:	85 db                	test   %ebx,%ebx
  801734:	7f ed                	jg     801723 <vprintfmt+0x206>
  801736:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801739:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801740:	eb a7                	jmp    8016e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801742:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801746:	74 1b                	je     801763 <vprintfmt+0x246>
  801748:	8d 50 e0             	lea    -0x20(%eax),%edx
  80174b:	83 fa 5e             	cmp    $0x5e,%edx
  80174e:	76 13                	jbe    801763 <vprintfmt+0x246>
					putch('?', putdat);
  801750:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801753:	89 54 24 04          	mov    %edx,0x4(%esp)
  801757:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80175e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801761:	eb 0d                	jmp    801770 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  801763:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801766:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80176a:	89 04 24             	mov    %eax,(%esp)
  80176d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801770:	83 ef 01             	sub    $0x1,%edi
  801773:	0f be 03             	movsbl (%ebx),%eax
  801776:	85 c0                	test   %eax,%eax
  801778:	74 05                	je     80177f <vprintfmt+0x262>
  80177a:	83 c3 01             	add    $0x1,%ebx
  80177d:	eb 31                	jmp    8017b0 <vprintfmt+0x293>
  80177f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801785:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801788:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80178b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80178f:	7f 36                	jg     8017c7 <vprintfmt+0x2aa>
  801791:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801794:	e9 b0 fd ff ff       	jmp    801549 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801799:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80179c:	83 c2 01             	add    $0x1,%edx
  80179f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8017a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017a5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8017a8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8017ab:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8017ae:	89 d3                	mov    %edx,%ebx
  8017b0:	85 f6                	test   %esi,%esi
  8017b2:	78 8e                	js     801742 <vprintfmt+0x225>
  8017b4:	83 ee 01             	sub    $0x1,%esi
  8017b7:	79 89                	jns    801742 <vprintfmt+0x225>
  8017b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017c2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8017c5:	eb c4                	jmp    80178b <vprintfmt+0x26e>
  8017c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8017ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8017cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8017d8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017da:	83 eb 01             	sub    $0x1,%ebx
  8017dd:	85 db                	test   %ebx,%ebx
  8017df:	7f ec                	jg     8017cd <vprintfmt+0x2b0>
  8017e1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8017e4:	e9 60 fd ff ff       	jmp    801549 <vprintfmt+0x2c>
  8017e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8017ec:	83 f9 01             	cmp    $0x1,%ecx
  8017ef:	7e 16                	jle    801807 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8017f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f4:	8d 50 08             	lea    0x8(%eax),%edx
  8017f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8017fa:	8b 10                	mov    (%eax),%edx
  8017fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8017ff:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801802:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801805:	eb 32                	jmp    801839 <vprintfmt+0x31c>
	else if (lflag)
  801807:	85 c9                	test   %ecx,%ecx
  801809:	74 18                	je     801823 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80180b:	8b 45 14             	mov    0x14(%ebp),%eax
  80180e:	8d 50 04             	lea    0x4(%eax),%edx
  801811:	89 55 14             	mov    %edx,0x14(%ebp)
  801814:	8b 00                	mov    (%eax),%eax
  801816:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801819:	89 c1                	mov    %eax,%ecx
  80181b:	c1 f9 1f             	sar    $0x1f,%ecx
  80181e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801821:	eb 16                	jmp    801839 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  801823:	8b 45 14             	mov    0x14(%ebp),%eax
  801826:	8d 50 04             	lea    0x4(%eax),%edx
  801829:	89 55 14             	mov    %edx,0x14(%ebp)
  80182c:	8b 00                	mov    (%eax),%eax
  80182e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801831:	89 c2                	mov    %eax,%edx
  801833:	c1 fa 1f             	sar    $0x1f,%edx
  801836:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801839:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80183c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80183f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  801844:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801848:	0f 89 8a 00 00 00    	jns    8018d8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80184e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801852:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801859:	ff d7                	call   *%edi
				num = -(long long) num;
  80185b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80185e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801861:	f7 d8                	neg    %eax
  801863:	83 d2 00             	adc    $0x0,%edx
  801866:	f7 da                	neg    %edx
  801868:	eb 6e                	jmp    8018d8 <vprintfmt+0x3bb>
  80186a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80186d:	89 ca                	mov    %ecx,%edx
  80186f:	8d 45 14             	lea    0x14(%ebp),%eax
  801872:	e8 4f fc ff ff       	call   8014c6 <getuint>
  801877:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80187c:	eb 5a                	jmp    8018d8 <vprintfmt+0x3bb>
  80187e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801881:	89 ca                	mov    %ecx,%edx
  801883:	8d 45 14             	lea    0x14(%ebp),%eax
  801886:	e8 3b fc ff ff       	call   8014c6 <getuint>
  80188b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  801890:	eb 46                	jmp    8018d8 <vprintfmt+0x3bb>
  801892:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  801895:	89 74 24 04          	mov    %esi,0x4(%esp)
  801899:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8018a0:	ff d7                	call   *%edi
			putch('x', putdat);
  8018a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8018ad:	ff d7                	call   *%edi
			num = (unsigned long long)
  8018af:	8b 45 14             	mov    0x14(%ebp),%eax
  8018b2:	8d 50 04             	lea    0x4(%eax),%edx
  8018b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018b8:	8b 00                	mov    (%eax),%eax
  8018ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8018c4:	eb 12                	jmp    8018d8 <vprintfmt+0x3bb>
  8018c6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8018c9:	89 ca                	mov    %ecx,%edx
  8018cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8018ce:	e8 f3 fb ff ff       	call   8014c6 <getuint>
  8018d3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8018d8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8018dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8018e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8018e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8018e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018eb:	89 04 24             	mov    %eax,(%esp)
  8018ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018f2:	89 f2                	mov    %esi,%edx
  8018f4:	89 f8                	mov    %edi,%eax
  8018f6:	e8 d5 fa ff ff       	call   8013d0 <printnum>
  8018fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8018fe:	e9 46 fc ff ff       	jmp    801549 <vprintfmt+0x2c>
  801903:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  801906:	8b 45 14             	mov    0x14(%ebp),%eax
  801909:	8d 50 04             	lea    0x4(%eax),%edx
  80190c:	89 55 14             	mov    %edx,0x14(%ebp)
  80190f:	8b 00                	mov    (%eax),%eax
  801911:	85 c0                	test   %eax,%eax
  801913:	75 24                	jne    801939 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  801915:	c7 44 24 0c 28 25 80 	movl   $0x802528,0xc(%esp)
  80191c:	00 
  80191d:	c7 44 24 08 87 23 80 	movl   $0x802387,0x8(%esp)
  801924:	00 
  801925:	89 74 24 04          	mov    %esi,0x4(%esp)
  801929:	89 3c 24             	mov    %edi,(%esp)
  80192c:	e8 ff 00 00 00       	call   801a30 <printfmt>
  801931:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801934:	e9 10 fc ff ff       	jmp    801549 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  801939:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80193c:	7e 29                	jle    801967 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80193e:	0f b6 16             	movzbl (%esi),%edx
  801941:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  801943:	c7 44 24 0c 60 25 80 	movl   $0x802560,0xc(%esp)
  80194a:	00 
  80194b:	c7 44 24 08 87 23 80 	movl   $0x802387,0x8(%esp)
  801952:	00 
  801953:	89 74 24 04          	mov    %esi,0x4(%esp)
  801957:	89 3c 24             	mov    %edi,(%esp)
  80195a:	e8 d1 00 00 00       	call   801a30 <printfmt>
  80195f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801962:	e9 e2 fb ff ff       	jmp    801549 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  801967:	0f b6 16             	movzbl (%esi),%edx
  80196a:	88 10                	mov    %dl,(%eax)
  80196c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80196f:	e9 d5 fb ff ff       	jmp    801549 <vprintfmt+0x2c>
  801974:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801977:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80197a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80197e:	89 14 24             	mov    %edx,(%esp)
  801981:	ff d7                	call   *%edi
  801983:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801986:	e9 be fb ff ff       	jmp    801549 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80198b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80198f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801996:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801998:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80199b:	80 38 25             	cmpb   $0x25,(%eax)
  80199e:	0f 84 a5 fb ff ff    	je     801549 <vprintfmt+0x2c>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	eb f0                	jmp    801998 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8019a8:	83 c4 5c             	add    $0x5c,%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5f                   	pop    %edi
  8019ae:	5d                   	pop    %ebp
  8019af:	c3                   	ret    

008019b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	83 ec 28             	sub    $0x28,%esp
  8019b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	74 04                	je     8019c4 <vsnprintf+0x14>
  8019c0:	85 d2                	test   %edx,%edx
  8019c2:	7f 07                	jg     8019cb <vsnprintf+0x1b>
  8019c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019c9:	eb 3b                	jmp    801a06 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8019cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8019ce:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8019d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8019d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8019dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8019df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8019ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f1:	c7 04 24 00 15 80 00 	movl   $0x801500,(%esp)
  8019f8:	e8 20 fb ff ff       	call   80151d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8019fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801a06:	c9                   	leave  
  801a07:	c3                   	ret    

00801a08 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801a0e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801a11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a15:	8b 45 10             	mov    0x10(%ebp),%eax
  801a18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a23:	8b 45 08             	mov    0x8(%ebp),%eax
  801a26:	89 04 24             	mov    %eax,(%esp)
  801a29:	e8 82 ff ff ff       	call   8019b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801a36:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801a39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	89 04 24             	mov    %eax,(%esp)
  801a51:	e8 c7 fa ff ff       	call   80151d <vprintfmt>
	va_end(ap);
}
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    
	...

00801a60 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801a66:	b8 00 00 00 00       	mov    $0x0,%eax
  801a6b:	80 3a 00             	cmpb   $0x0,(%edx)
  801a6e:	74 09                	je     801a79 <strlen+0x19>
		n++;
  801a70:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801a73:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801a77:	75 f7                	jne    801a70 <strlen+0x10>
		n++;
	return n;
}
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	53                   	push   %ebx
  801a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a85:	85 c9                	test   %ecx,%ecx
  801a87:	74 19                	je     801aa2 <strnlen+0x27>
  801a89:	80 3b 00             	cmpb   $0x0,(%ebx)
  801a8c:	74 14                	je     801aa2 <strnlen+0x27>
  801a8e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801a93:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801a96:	39 c8                	cmp    %ecx,%eax
  801a98:	74 0d                	je     801aa7 <strnlen+0x2c>
  801a9a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801a9e:	75 f3                	jne    801a93 <strnlen+0x18>
  801aa0:	eb 05                	jmp    801aa7 <strnlen+0x2c>
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801aa7:	5b                   	pop    %ebx
  801aa8:	5d                   	pop    %ebp
  801aa9:	c3                   	ret    

00801aaa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801aaa:	55                   	push   %ebp
  801aab:	89 e5                	mov    %esp,%ebp
  801aad:	53                   	push   %ebx
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ab4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ab9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801abd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801ac0:	83 c2 01             	add    $0x1,%edx
  801ac3:	84 c9                	test   %cl,%cl
  801ac5:	75 f2                	jne    801ab9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801ac7:	5b                   	pop    %ebx
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    

00801aca <strcat>:

char *
strcat(char *dst, const char *src)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	53                   	push   %ebx
  801ace:	83 ec 08             	sub    $0x8,%esp
  801ad1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ad4:	89 1c 24             	mov    %ebx,(%esp)
  801ad7:	e8 84 ff ff ff       	call   801a60 <strlen>
	strcpy(dst + len, src);
  801adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801adf:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ae3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801ae6:	89 04 24             	mov    %eax,(%esp)
  801ae9:	e8 bc ff ff ff       	call   801aaa <strcpy>
	return dst;
}
  801aee:	89 d8                	mov    %ebx,%eax
  801af0:	83 c4 08             	add    $0x8,%esp
  801af3:	5b                   	pop    %ebx
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	8b 45 08             	mov    0x8(%ebp),%eax
  801afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b01:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b04:	85 f6                	test   %esi,%esi
  801b06:	74 18                	je     801b20 <strncpy+0x2a>
  801b08:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b0d:	0f b6 1a             	movzbl (%edx),%ebx
  801b10:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b13:	80 3a 01             	cmpb   $0x1,(%edx)
  801b16:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b19:	83 c1 01             	add    $0x1,%ecx
  801b1c:	39 ce                	cmp    %ecx,%esi
  801b1e:	77 ed                	ja     801b0d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b32:	89 f0                	mov    %esi,%eax
  801b34:	85 c9                	test   %ecx,%ecx
  801b36:	74 27                	je     801b5f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801b38:	83 e9 01             	sub    $0x1,%ecx
  801b3b:	74 1d                	je     801b5a <strlcpy+0x36>
  801b3d:	0f b6 1a             	movzbl (%edx),%ebx
  801b40:	84 db                	test   %bl,%bl
  801b42:	74 16                	je     801b5a <strlcpy+0x36>
			*dst++ = *src++;
  801b44:	88 18                	mov    %bl,(%eax)
  801b46:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b49:	83 e9 01             	sub    $0x1,%ecx
  801b4c:	74 0e                	je     801b5c <strlcpy+0x38>
			*dst++ = *src++;
  801b4e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b51:	0f b6 1a             	movzbl (%edx),%ebx
  801b54:	84 db                	test   %bl,%bl
  801b56:	75 ec                	jne    801b44 <strlcpy+0x20>
  801b58:	eb 02                	jmp    801b5c <strlcpy+0x38>
  801b5a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801b5c:	c6 00 00             	movb   $0x0,(%eax)
  801b5f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801b61:	5b                   	pop    %ebx
  801b62:	5e                   	pop    %esi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    

00801b65 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801b65:	55                   	push   %ebp
  801b66:	89 e5                	mov    %esp,%ebp
  801b68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801b6e:	0f b6 01             	movzbl (%ecx),%eax
  801b71:	84 c0                	test   %al,%al
  801b73:	74 15                	je     801b8a <strcmp+0x25>
  801b75:	3a 02                	cmp    (%edx),%al
  801b77:	75 11                	jne    801b8a <strcmp+0x25>
		p++, q++;
  801b79:	83 c1 01             	add    $0x1,%ecx
  801b7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801b7f:	0f b6 01             	movzbl (%ecx),%eax
  801b82:	84 c0                	test   %al,%al
  801b84:	74 04                	je     801b8a <strcmp+0x25>
  801b86:	3a 02                	cmp    (%edx),%al
  801b88:	74 ef                	je     801b79 <strcmp+0x14>
  801b8a:	0f b6 c0             	movzbl %al,%eax
  801b8d:	0f b6 12             	movzbl (%edx),%edx
  801b90:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801b92:	5d                   	pop    %ebp
  801b93:	c3                   	ret    

00801b94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801b94:	55                   	push   %ebp
  801b95:	89 e5                	mov    %esp,%ebp
  801b97:	53                   	push   %ebx
  801b98:	8b 55 08             	mov    0x8(%ebp),%edx
  801b9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801ba1:	85 c0                	test   %eax,%eax
  801ba3:	74 23                	je     801bc8 <strncmp+0x34>
  801ba5:	0f b6 1a             	movzbl (%edx),%ebx
  801ba8:	84 db                	test   %bl,%bl
  801baa:	74 25                	je     801bd1 <strncmp+0x3d>
  801bac:	3a 19                	cmp    (%ecx),%bl
  801bae:	75 21                	jne    801bd1 <strncmp+0x3d>
  801bb0:	83 e8 01             	sub    $0x1,%eax
  801bb3:	74 13                	je     801bc8 <strncmp+0x34>
		n--, p++, q++;
  801bb5:	83 c2 01             	add    $0x1,%edx
  801bb8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bbb:	0f b6 1a             	movzbl (%edx),%ebx
  801bbe:	84 db                	test   %bl,%bl
  801bc0:	74 0f                	je     801bd1 <strncmp+0x3d>
  801bc2:	3a 19                	cmp    (%ecx),%bl
  801bc4:	74 ea                	je     801bb0 <strncmp+0x1c>
  801bc6:	eb 09                	jmp    801bd1 <strncmp+0x3d>
  801bc8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801bcd:	5b                   	pop    %ebx
  801bce:	5d                   	pop    %ebp
  801bcf:	90                   	nop
  801bd0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801bd1:	0f b6 02             	movzbl (%edx),%eax
  801bd4:	0f b6 11             	movzbl (%ecx),%edx
  801bd7:	29 d0                	sub    %edx,%eax
  801bd9:	eb f2                	jmp    801bcd <strncmp+0x39>

00801bdb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	8b 45 08             	mov    0x8(%ebp),%eax
  801be1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801be5:	0f b6 10             	movzbl (%eax),%edx
  801be8:	84 d2                	test   %dl,%dl
  801bea:	74 18                	je     801c04 <strchr+0x29>
		if (*s == c)
  801bec:	38 ca                	cmp    %cl,%dl
  801bee:	75 0a                	jne    801bfa <strchr+0x1f>
  801bf0:	eb 17                	jmp    801c09 <strchr+0x2e>
  801bf2:	38 ca                	cmp    %cl,%dl
  801bf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bf8:	74 0f                	je     801c09 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801bfa:	83 c0 01             	add    $0x1,%eax
  801bfd:	0f b6 10             	movzbl (%eax),%edx
  801c00:	84 d2                	test   %dl,%dl
  801c02:	75 ee                	jne    801bf2 <strchr+0x17>
  801c04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801c09:	5d                   	pop    %ebp
  801c0a:	c3                   	ret    

00801c0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c0b:	55                   	push   %ebp
  801c0c:	89 e5                	mov    %esp,%ebp
  801c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c15:	0f b6 10             	movzbl (%eax),%edx
  801c18:	84 d2                	test   %dl,%dl
  801c1a:	74 18                	je     801c34 <strfind+0x29>
		if (*s == c)
  801c1c:	38 ca                	cmp    %cl,%dl
  801c1e:	75 0a                	jne    801c2a <strfind+0x1f>
  801c20:	eb 12                	jmp    801c34 <strfind+0x29>
  801c22:	38 ca                	cmp    %cl,%dl
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	74 0a                	je     801c34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801c2a:	83 c0 01             	add    $0x1,%eax
  801c2d:	0f b6 10             	movzbl (%eax),%edx
  801c30:	84 d2                	test   %dl,%dl
  801c32:	75 ee                	jne    801c22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    

00801c36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	83 ec 0c             	sub    $0xc,%esp
  801c3c:	89 1c 24             	mov    %ebx,(%esp)
  801c3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801c47:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c50:	85 c9                	test   %ecx,%ecx
  801c52:	74 30                	je     801c84 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c5a:	75 25                	jne    801c81 <memset+0x4b>
  801c5c:	f6 c1 03             	test   $0x3,%cl
  801c5f:	75 20                	jne    801c81 <memset+0x4b>
		c &= 0xFF;
  801c61:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801c64:	89 d3                	mov    %edx,%ebx
  801c66:	c1 e3 08             	shl    $0x8,%ebx
  801c69:	89 d6                	mov    %edx,%esi
  801c6b:	c1 e6 18             	shl    $0x18,%esi
  801c6e:	89 d0                	mov    %edx,%eax
  801c70:	c1 e0 10             	shl    $0x10,%eax
  801c73:	09 f0                	or     %esi,%eax
  801c75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801c77:	09 d8                	or     %ebx,%eax
  801c79:	c1 e9 02             	shr    $0x2,%ecx
  801c7c:	fc                   	cld    
  801c7d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c7f:	eb 03                	jmp    801c84 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801c81:	fc                   	cld    
  801c82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801c84:	89 f8                	mov    %edi,%eax
  801c86:	8b 1c 24             	mov    (%esp),%ebx
  801c89:	8b 74 24 04          	mov    0x4(%esp),%esi
  801c8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801c91:	89 ec                	mov    %ebp,%esp
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801c95:	55                   	push   %ebp
  801c96:	89 e5                	mov    %esp,%ebp
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	89 34 24             	mov    %esi,(%esp)
  801c9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801ca8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801cab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801cad:	39 c6                	cmp    %eax,%esi
  801caf:	73 35                	jae    801ce6 <memmove+0x51>
  801cb1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cb4:	39 d0                	cmp    %edx,%eax
  801cb6:	73 2e                	jae    801ce6 <memmove+0x51>
		s += n;
		d += n;
  801cb8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cba:	f6 c2 03             	test   $0x3,%dl
  801cbd:	75 1b                	jne    801cda <memmove+0x45>
  801cbf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cc5:	75 13                	jne    801cda <memmove+0x45>
  801cc7:	f6 c1 03             	test   $0x3,%cl
  801cca:	75 0e                	jne    801cda <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801ccc:	83 ef 04             	sub    $0x4,%edi
  801ccf:	8d 72 fc             	lea    -0x4(%edx),%esi
  801cd2:	c1 e9 02             	shr    $0x2,%ecx
  801cd5:	fd                   	std    
  801cd6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cd8:	eb 09                	jmp    801ce3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801cda:	83 ef 01             	sub    $0x1,%edi
  801cdd:	8d 72 ff             	lea    -0x1(%edx),%esi
  801ce0:	fd                   	std    
  801ce1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801ce3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801ce4:	eb 20                	jmp    801d06 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801ce6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801cec:	75 15                	jne    801d03 <memmove+0x6e>
  801cee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801cf4:	75 0d                	jne    801d03 <memmove+0x6e>
  801cf6:	f6 c1 03             	test   $0x3,%cl
  801cf9:	75 08                	jne    801d03 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801cfb:	c1 e9 02             	shr    $0x2,%ecx
  801cfe:	fc                   	cld    
  801cff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d01:	eb 03                	jmp    801d06 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d03:	fc                   	cld    
  801d04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d06:	8b 34 24             	mov    (%esp),%esi
  801d09:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d0d:	89 ec                	mov    %ebp,%esp
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d17:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d25:	8b 45 08             	mov    0x8(%ebp),%eax
  801d28:	89 04 24             	mov    %eax,(%esp)
  801d2b:	e8 65 ff ff ff       	call   801c95 <memmove>
}
  801d30:	c9                   	leave  
  801d31:	c3                   	ret    

00801d32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	57                   	push   %edi
  801d36:	56                   	push   %esi
  801d37:	53                   	push   %ebx
  801d38:	8b 75 08             	mov    0x8(%ebp),%esi
  801d3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d41:	85 c9                	test   %ecx,%ecx
  801d43:	74 36                	je     801d7b <memcmp+0x49>
		if (*s1 != *s2)
  801d45:	0f b6 06             	movzbl (%esi),%eax
  801d48:	0f b6 1f             	movzbl (%edi),%ebx
  801d4b:	38 d8                	cmp    %bl,%al
  801d4d:	74 20                	je     801d6f <memcmp+0x3d>
  801d4f:	eb 14                	jmp    801d65 <memcmp+0x33>
  801d51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801d56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801d5b:	83 c2 01             	add    $0x1,%edx
  801d5e:	83 e9 01             	sub    $0x1,%ecx
  801d61:	38 d8                	cmp    %bl,%al
  801d63:	74 12                	je     801d77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801d65:	0f b6 c0             	movzbl %al,%eax
  801d68:	0f b6 db             	movzbl %bl,%ebx
  801d6b:	29 d8                	sub    %ebx,%eax
  801d6d:	eb 11                	jmp    801d80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d6f:	83 e9 01             	sub    $0x1,%ecx
  801d72:	ba 00 00 00 00       	mov    $0x0,%edx
  801d77:	85 c9                	test   %ecx,%ecx
  801d79:	75 d6                	jne    801d51 <memcmp+0x1f>
  801d7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801d80:	5b                   	pop    %ebx
  801d81:	5e                   	pop    %esi
  801d82:	5f                   	pop    %edi
  801d83:	5d                   	pop    %ebp
  801d84:	c3                   	ret    

00801d85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801d85:	55                   	push   %ebp
  801d86:	89 e5                	mov    %esp,%ebp
  801d88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801d8b:	89 c2                	mov    %eax,%edx
  801d8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801d90:	39 d0                	cmp    %edx,%eax
  801d92:	73 15                	jae    801da9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801d94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801d98:	38 08                	cmp    %cl,(%eax)
  801d9a:	75 06                	jne    801da2 <memfind+0x1d>
  801d9c:	eb 0b                	jmp    801da9 <memfind+0x24>
  801d9e:	38 08                	cmp    %cl,(%eax)
  801da0:	74 07                	je     801da9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801da2:	83 c0 01             	add    $0x1,%eax
  801da5:	39 c2                	cmp    %eax,%edx
  801da7:	77 f5                	ja     801d9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	57                   	push   %edi
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 04             	sub    $0x4,%esp
  801db4:	8b 55 08             	mov    0x8(%ebp),%edx
  801db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dba:	0f b6 02             	movzbl (%edx),%eax
  801dbd:	3c 20                	cmp    $0x20,%al
  801dbf:	74 04                	je     801dc5 <strtol+0x1a>
  801dc1:	3c 09                	cmp    $0x9,%al
  801dc3:	75 0e                	jne    801dd3 <strtol+0x28>
		s++;
  801dc5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dc8:	0f b6 02             	movzbl (%edx),%eax
  801dcb:	3c 20                	cmp    $0x20,%al
  801dcd:	74 f6                	je     801dc5 <strtol+0x1a>
  801dcf:	3c 09                	cmp    $0x9,%al
  801dd1:	74 f2                	je     801dc5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801dd3:	3c 2b                	cmp    $0x2b,%al
  801dd5:	75 0c                	jne    801de3 <strtol+0x38>
		s++;
  801dd7:	83 c2 01             	add    $0x1,%edx
  801dda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801de1:	eb 15                	jmp    801df8 <strtol+0x4d>
	else if (*s == '-')
  801de3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801dea:	3c 2d                	cmp    $0x2d,%al
  801dec:	75 0a                	jne    801df8 <strtol+0x4d>
		s++, neg = 1;
  801dee:	83 c2 01             	add    $0x1,%edx
  801df1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df8:	85 db                	test   %ebx,%ebx
  801dfa:	0f 94 c0             	sete   %al
  801dfd:	74 05                	je     801e04 <strtol+0x59>
  801dff:	83 fb 10             	cmp    $0x10,%ebx
  801e02:	75 18                	jne    801e1c <strtol+0x71>
  801e04:	80 3a 30             	cmpb   $0x30,(%edx)
  801e07:	75 13                	jne    801e1c <strtol+0x71>
  801e09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	75 0a                	jne    801e1c <strtol+0x71>
		s += 2, base = 16;
  801e12:	83 c2 02             	add    $0x2,%edx
  801e15:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e1a:	eb 15                	jmp    801e31 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e1c:	84 c0                	test   %al,%al
  801e1e:	66 90                	xchg   %ax,%ax
  801e20:	74 0f                	je     801e31 <strtol+0x86>
  801e22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801e27:	80 3a 30             	cmpb   $0x30,(%edx)
  801e2a:	75 05                	jne    801e31 <strtol+0x86>
		s++, base = 8;
  801e2c:	83 c2 01             	add    $0x1,%edx
  801e2f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
  801e36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e38:	0f b6 0a             	movzbl (%edx),%ecx
  801e3b:	89 cf                	mov    %ecx,%edi
  801e3d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801e40:	80 fb 09             	cmp    $0x9,%bl
  801e43:	77 08                	ja     801e4d <strtol+0xa2>
			dig = *s - '0';
  801e45:	0f be c9             	movsbl %cl,%ecx
  801e48:	83 e9 30             	sub    $0x30,%ecx
  801e4b:	eb 1e                	jmp    801e6b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801e4d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801e50:	80 fb 19             	cmp    $0x19,%bl
  801e53:	77 08                	ja     801e5d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801e55:	0f be c9             	movsbl %cl,%ecx
  801e58:	83 e9 57             	sub    $0x57,%ecx
  801e5b:	eb 0e                	jmp    801e6b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801e5d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801e60:	80 fb 19             	cmp    $0x19,%bl
  801e63:	77 15                	ja     801e7a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801e65:	0f be c9             	movsbl %cl,%ecx
  801e68:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801e6b:	39 f1                	cmp    %esi,%ecx
  801e6d:	7d 0b                	jge    801e7a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801e6f:	83 c2 01             	add    $0x1,%edx
  801e72:	0f af c6             	imul   %esi,%eax
  801e75:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801e78:	eb be                	jmp    801e38 <strtol+0x8d>
  801e7a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801e7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e80:	74 05                	je     801e87 <strtol+0xdc>
		*endptr = (char *) s;
  801e82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e85:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801e87:	89 ca                	mov    %ecx,%edx
  801e89:	f7 da                	neg    %edx
  801e8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801e8f:	0f 45 c2             	cmovne %edx,%eax
}
  801e92:	83 c4 04             	add    $0x4,%esp
  801e95:	5b                   	pop    %ebx
  801e96:	5e                   	pop    %esi
  801e97:	5f                   	pop    %edi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    
  801e9a:	00 00                	add    %al,(%eax)
  801e9c:	00 00                	add    %al,(%eax)
	...

00801ea0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ea6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801eac:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb1:	39 ca                	cmp    %ecx,%edx
  801eb3:	75 04                	jne    801eb9 <ipc_find_env+0x19>
  801eb5:	b0 00                	mov    $0x0,%al
  801eb7:	eb 11                	jmp    801eca <ipc_find_env+0x2a>
  801eb9:	89 c2                	mov    %eax,%edx
  801ebb:	c1 e2 07             	shl    $0x7,%edx
  801ebe:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801ec4:	8b 12                	mov    (%edx),%edx
  801ec6:	39 ca                	cmp    %ecx,%edx
  801ec8:	75 0f                	jne    801ed9 <ipc_find_env+0x39>
			return envs[i].env_id;
  801eca:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801ece:	c1 e0 06             	shl    $0x6,%eax
  801ed1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801ed7:	eb 0e                	jmp    801ee7 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed9:	83 c0 01             	add    $0x1,%eax
  801edc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee1:	75 d6                	jne    801eb9 <ipc_find_env+0x19>
  801ee3:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    

00801ee9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee9:	55                   	push   %ebp
  801eea:	89 e5                	mov    %esp,%ebp
  801eec:	57                   	push   %edi
  801eed:	56                   	push   %esi
  801eee:	53                   	push   %ebx
  801eef:	83 ec 1c             	sub    $0x1c,%esp
  801ef2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f02:	0f 44 d8             	cmove  %eax,%ebx
  801f05:	eb 25                	jmp    801f2c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801f07:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0a:	74 20                	je     801f2c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801f0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f10:	c7 44 24 08 80 27 80 	movl   $0x802780,0x8(%esp)
  801f17:	00 
  801f18:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f1f:	00 
  801f20:	c7 04 24 9e 27 80 00 	movl   $0x80279e,(%esp)
  801f27:	e8 88 f3 ff ff       	call   8012b4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f33:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f37:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f3b:	89 34 24             	mov    %esi,(%esp)
  801f3e:	e8 9b e2 ff ff       	call   8001de <sys_ipc_try_send>
  801f43:	85 c0                	test   %eax,%eax
  801f45:	75 c0                	jne    801f07 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f47:	e8 18 e4 ff ff       	call   800364 <sys_yield>
}
  801f4c:	83 c4 1c             	add    $0x1c,%esp
  801f4f:	5b                   	pop    %ebx
  801f50:	5e                   	pop    %esi
  801f51:	5f                   	pop    %edi
  801f52:	5d                   	pop    %ebp
  801f53:	c3                   	ret    

00801f54 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 28             	sub    $0x28,%esp
  801f5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f60:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f63:	8b 75 08             	mov    0x8(%ebp),%esi
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f6c:	85 c0                	test   %eax,%eax
  801f6e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f73:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801f76:	89 04 24             	mov    %eax,(%esp)
  801f79:	e8 27 e2 ff ff       	call   8001a5 <sys_ipc_recv>
  801f7e:	89 c3                	mov    %eax,%ebx
  801f80:	85 c0                	test   %eax,%eax
  801f82:	79 2a                	jns    801fae <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801f84:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f88:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8c:	c7 04 24 a8 27 80 00 	movl   $0x8027a8,(%esp)
  801f93:	e8 d5 f3 ff ff       	call   80136d <cprintf>
		if(from_env_store != NULL)
  801f98:	85 f6                	test   %esi,%esi
  801f9a:	74 06                	je     801fa2 <ipc_recv+0x4e>
			*from_env_store = 0;
  801f9c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fa2:	85 ff                	test   %edi,%edi
  801fa4:	74 2c                	je     801fd2 <ipc_recv+0x7e>
			*perm_store = 0;
  801fa6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fac:	eb 24                	jmp    801fd2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801fae:	85 f6                	test   %esi,%esi
  801fb0:	74 0a                	je     801fbc <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801fb2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb7:	8b 40 74             	mov    0x74(%eax),%eax
  801fba:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fbc:	85 ff                	test   %edi,%edi
  801fbe:	74 0a                	je     801fca <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801fc0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fc5:	8b 40 78             	mov    0x78(%eax),%eax
  801fc8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fca:	a1 08 40 80 00       	mov    0x804008,%eax
  801fcf:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801fd2:	89 d8                	mov    %ebx,%eax
  801fd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fd7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fdd:	89 ec                	mov    %ebp,%esp
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    
  801fe1:	00 00                	add    %al,(%eax)
	...

00801fe4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  801fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  801fea:	89 c2                	mov    %eax,%edx
  801fec:	c1 ea 16             	shr    $0x16,%edx
  801fef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801ff6:	f6 c2 01             	test   $0x1,%dl
  801ff9:	74 20                	je     80201b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  801ffb:	c1 e8 0c             	shr    $0xc,%eax
  801ffe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802005:	a8 01                	test   $0x1,%al
  802007:	74 12                	je     80201b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802009:	c1 e8 0c             	shr    $0xc,%eax
  80200c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802011:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802016:	0f b7 c0             	movzwl %ax,%eax
  802019:	eb 05                	jmp    802020 <pageref+0x3c>
  80201b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802020:	5d                   	pop    %ebp
  802021:	c3                   	ret    
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
