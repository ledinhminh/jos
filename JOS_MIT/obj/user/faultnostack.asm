
obj/user/faultnostack.debug:     file format elf32-i386


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
  80002c:	e8 2b 00 00 00       	call   80005c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  80003a:	c7 44 24 04 cc 04 80 	movl   $0x8004cc,0x4(%esp)
  800041:	00 
  800042:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800049:	e8 d2 01 00 00       	call   800220 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004e:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800055:	00 00 00 
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    
	...

0080005c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005c:	55                   	push   %ebp
  80005d:	89 e5                	mov    %esp,%ebp
  80005f:	83 ec 18             	sub    $0x18,%esp
  800062:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800065:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800068:	8b 75 08             	mov    0x8(%ebp),%esi
  80006b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80006e:	e8 70 03 00 00       	call   8003e3 <sys_getenvid>
  800073:	25 ff 03 00 00       	and    $0x3ff,%eax
  800078:	c1 e0 07             	shl    $0x7,%eax
  80007b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800080:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800085:	85 f6                	test   %esi,%esi
  800087:	7e 07                	jle    800090 <libmain+0x34>
		binaryname = argv[0];
  800089:	8b 03                	mov    (%ebx),%eax
  80008b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800090:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800094:	89 34 24             	mov    %esi,(%esp)
  800097:	e8 98 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0b 00 00 00       	call   8000ac <exit>
}
  8000a1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a7:	89 ec                	mov    %ebp,%esp
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    
	...

008000ac <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b2:	e8 32 09 00 00       	call   8009e9 <close_all>
	sys_env_destroy(0);
  8000b7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000be:	e8 5b 03 00 00       	call   80041e <sys_env_destroy>
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 48             	sub    $0x48,%esp
  8000ce:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000d1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000d4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000d7:	89 c6                	mov    %eax,%esi
  8000d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000dc:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e7:	51                   	push   %ecx
  8000e8:	52                   	push   %edx
  8000e9:	53                   	push   %ebx
  8000ea:	54                   	push   %esp
  8000eb:	55                   	push   %ebp
  8000ec:	56                   	push   %esi
  8000ed:	57                   	push   %edi
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	8d 35 f8 00 80 00    	lea    0x8000f8,%esi
  8000f6:	0f 34                	sysenter 

008000f8 <.after_sysenter_label>:
  8000f8:	5f                   	pop    %edi
  8000f9:	5e                   	pop    %esi
  8000fa:	5d                   	pop    %ebp
  8000fb:	5c                   	pop    %esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5a                   	pop    %edx
  8000fe:	59                   	pop    %ecx
  8000ff:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800101:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800105:	74 28                	je     80012f <.after_sysenter_label+0x37>
  800107:	85 c0                	test   %eax,%eax
  800109:	7e 24                	jle    80012f <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80010f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800113:	c7 44 24 08 6a 23 80 	movl   $0x80236a,0x8(%esp)
  80011a:	00 
  80011b:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800122:	00 
  800123:	c7 04 24 87 23 80 00 	movl   $0x802387,(%esp)
  80012a:	e8 c5 11 00 00       	call   8012f4 <_panic>

	return ret;
}
  80012f:	89 d0                	mov    %edx,%eax
  800131:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800134:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800137:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80013a:	89 ec                	mov    %ebp,%esp
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800144:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80014b:	00 
  80014c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800153:	00 
  800154:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80015b:	00 
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80015f:	89 04 24             	mov    %eax,(%esp)
  800162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800165:	ba 00 00 00 00       	mov    $0x0,%edx
  80016a:	b8 10 00 00 00       	mov    $0x10,%eax
  80016f:	e8 54 ff ff ff       	call   8000c8 <syscall>
}
  800174:	c9                   	leave  
  800175:	c3                   	ret    

00800176 <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800176:	55                   	push   %ebp
  800177:	89 e5                	mov    %esp,%ebp
  800179:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  80017c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800183:	00 
  800184:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80018b:	00 
  80018c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800193:	00 
  800194:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80019b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8001a5:	b8 0f 00 00 00       	mov    $0xf,%eax
  8001aa:	e8 19 ff ff ff       	call   8000c8 <syscall>
}
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8001b7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001be:	00 
  8001bf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001c6:	00 
  8001c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ce:	00 
  8001cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001de:	b8 0e 00 00 00       	mov    $0xe,%eax
  8001e3:	e8 e0 fe ff ff       	call   8000c8 <syscall>
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8001f0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f7:	00 
  8001f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ff:	8b 45 10             	mov    0x10(%ebp),%eax
  800202:	89 44 24 04          	mov    %eax,0x4(%esp)
  800206:	8b 45 0c             	mov    0xc(%ebp),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020f:	ba 00 00 00 00       	mov    $0x0,%edx
  800214:	b8 0d 00 00 00       	mov    $0xd,%eax
  800219:	e8 aa fe ff ff       	call   8000c8 <syscall>
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800226:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022d:	00 
  80022e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800235:	00 
  800236:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80023d:	00 
  80023e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800241:	89 04 24             	mov    %eax,(%esp)
  800244:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800247:	ba 01 00 00 00       	mov    $0x1,%edx
  80024c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800251:	e8 72 fe ff ff       	call   8000c8 <syscall>
}
  800256:	c9                   	leave  
  800257:	c3                   	ret    

00800258 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80025e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800265:	00 
  800266:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80026d:	00 
  80026e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800275:	00 
  800276:	8b 45 0c             	mov    0xc(%ebp),%eax
  800279:	89 04 24             	mov    %eax,(%esp)
  80027c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027f:	ba 01 00 00 00       	mov    $0x1,%edx
  800284:	b8 0a 00 00 00       	mov    $0xa,%eax
  800289:	e8 3a fe ff ff       	call   8000c8 <syscall>
}
  80028e:	c9                   	leave  
  80028f:	c3                   	ret    

00800290 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800290:	55                   	push   %ebp
  800291:	89 e5                	mov    %esp,%ebp
  800293:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800296:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029d:	00 
  80029e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002a5:	00 
  8002a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002ad:	00 
  8002ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002b1:	89 04 24             	mov    %eax,(%esp)
  8002b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b7:	ba 01 00 00 00       	mov    $0x1,%edx
  8002bc:	b8 09 00 00 00       	mov    $0x9,%eax
  8002c1:	e8 02 fe ff ff       	call   8000c8 <syscall>
}
  8002c6:	c9                   	leave  
  8002c7:	c3                   	ret    

008002c8 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002ce:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002d5:	00 
  8002d6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002dd:	00 
  8002de:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8002e5:	00 
  8002e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	ba 01 00 00 00       	mov    $0x1,%edx
  8002f4:	b8 07 00 00 00       	mov    $0x7,%eax
  8002f9:	e8 ca fd ff ff       	call   8000c8 <syscall>
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800306:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030d:	00 
  80030e:	8b 45 18             	mov    0x18(%ebp),%eax
  800311:	0b 45 14             	or     0x14(%ebp),%eax
  800314:	89 44 24 08          	mov    %eax,0x8(%esp)
  800318:	8b 45 10             	mov    0x10(%ebp),%eax
  80031b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80031f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800322:	89 04 24             	mov    %eax,(%esp)
  800325:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800328:	ba 01 00 00 00       	mov    $0x1,%edx
  80032d:	b8 06 00 00 00       	mov    $0x6,%eax
  800332:	e8 91 fd ff ff       	call   8000c8 <syscall>
}
  800337:	c9                   	leave  
  800338:	c3                   	ret    

00800339 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800339:	55                   	push   %ebp
  80033a:	89 e5                	mov    %esp,%ebp
  80033c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80033f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800346:	00 
  800347:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80034e:	00 
  80034f:	8b 45 10             	mov    0x10(%ebp),%eax
  800352:	89 44 24 04          	mov    %eax,0x4(%esp)
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
  800359:	89 04 24             	mov    %eax,(%esp)
  80035c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035f:	ba 01 00 00 00       	mov    $0x1,%edx
  800364:	b8 05 00 00 00       	mov    $0x5,%eax
  800369:	e8 5a fd ff ff       	call   8000c8 <syscall>
}
  80036e:	c9                   	leave  
  80036f:	c3                   	ret    

00800370 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800376:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037d:	00 
  80037e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800385:	00 
  800386:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80038d:	00 
  80038e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800395:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039a:	ba 00 00 00 00       	mov    $0x0,%edx
  80039f:	b8 0c 00 00 00       	mov    $0xc,%eax
  8003a4:	e8 1f fd ff ff       	call   8000c8 <syscall>
}
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8003b1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003b8:	00 
  8003b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003c0:	00 
  8003c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003c8:	00 
  8003c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003cc:	89 04 24             	mov    %eax,(%esp)
  8003cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d7:	b8 04 00 00 00       	mov    $0x4,%eax
  8003dc:	e8 e7 fc ff ff       	call   8000c8 <syscall>
}
  8003e1:	c9                   	leave  
  8003e2:	c3                   	ret    

008003e3 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8003e9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003f0:	00 
  8003f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003f8:	00 
  8003f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800400:	00 
  800401:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800408:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	b8 02 00 00 00       	mov    $0x2,%eax
  800417:	e8 ac fc ff ff       	call   8000c8 <syscall>
}
  80041c:	c9                   	leave  
  80041d:	c3                   	ret    

0080041e <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800424:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80042b:	00 
  80042c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800433:	00 
  800434:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80043b:	00 
  80043c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800443:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800446:	ba 01 00 00 00       	mov    $0x1,%edx
  80044b:	b8 03 00 00 00       	mov    $0x3,%eax
  800450:	e8 73 fc ff ff       	call   8000c8 <syscall>
}
  800455:	c9                   	leave  
  800456:	c3                   	ret    

00800457 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800457:	55                   	push   %ebp
  800458:	89 e5                	mov    %esp,%ebp
  80045a:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80045d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800464:	00 
  800465:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80046c:	00 
  80046d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800474:	00 
  800475:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80047c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800481:	ba 00 00 00 00       	mov    $0x0,%edx
  800486:	b8 01 00 00 00       	mov    $0x1,%eax
  80048b:	e8 38 fc ff ff       	call   8000c8 <syscall>
}
  800490:	c9                   	leave  
  800491:	c3                   	ret    

00800492 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800498:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80049f:	00 
  8004a0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004a7:	00 
  8004a8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004af:	00 
  8004b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b3:	89 04 24             	mov    %eax,(%esp)
  8004b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	e8 00 fc ff ff       	call   8000c8 <syscall>
}
  8004c8:	c9                   	leave  
  8004c9:	c3                   	ret    
	...

008004cc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8004cc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8004cd:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8004d2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8004d4:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8004d7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8004db:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8004de:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8004e2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8004e6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8004e8:	83 c4 08             	add    $0x8,%esp
	popal
  8004eb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8004ec:	83 c4 04             	add    $0x4,%esp
	popfl
  8004ef:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8004f0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8004f1:	c3                   	ret    
	...

00800500 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	05 00 00 00 30       	add    $0x30000000,%eax
  80050b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80050e:	5d                   	pop    %ebp
  80050f:	c3                   	ret    

00800510 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800516:	8b 45 08             	mov    0x8(%ebp),%eax
  800519:	89 04 24             	mov    %eax,(%esp)
  80051c:	e8 df ff ff ff       	call   800500 <fd2num>
  800521:	05 20 00 0d 00       	add    $0xd0020,%eax
  800526:	c1 e0 0c             	shl    $0xc,%eax
}
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800534:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800539:	a8 01                	test   $0x1,%al
  80053b:	74 36                	je     800573 <fd_alloc+0x48>
  80053d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800542:	a8 01                	test   $0x1,%al
  800544:	74 2d                	je     800573 <fd_alloc+0x48>
  800546:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80054b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  800550:	be 00 00 40 ef       	mov    $0xef400000,%esi
  800555:	89 c3                	mov    %eax,%ebx
  800557:	89 c2                	mov    %eax,%edx
  800559:	c1 ea 16             	shr    $0x16,%edx
  80055c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80055f:	f6 c2 01             	test   $0x1,%dl
  800562:	74 14                	je     800578 <fd_alloc+0x4d>
  800564:	89 c2                	mov    %eax,%edx
  800566:	c1 ea 0c             	shr    $0xc,%edx
  800569:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80056c:	f6 c2 01             	test   $0x1,%dl
  80056f:	75 10                	jne    800581 <fd_alloc+0x56>
  800571:	eb 05                	jmp    800578 <fd_alloc+0x4d>
  800573:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  800578:	89 1f                	mov    %ebx,(%edi)
  80057a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80057f:	eb 17                	jmp    800598 <fd_alloc+0x6d>
  800581:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800586:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80058b:	75 c8                	jne    800555 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80058d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  800593:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  800598:	5b                   	pop    %ebx
  800599:	5e                   	pop    %esi
  80059a:	5f                   	pop    %edi
  80059b:	5d                   	pop    %ebp
  80059c:	c3                   	ret    

0080059d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80059d:	55                   	push   %ebp
  80059e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8005a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a3:	83 f8 1f             	cmp    $0x1f,%eax
  8005a6:	77 36                	ja     8005de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8005a8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8005ad:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8005b0:	89 c2                	mov    %eax,%edx
  8005b2:	c1 ea 16             	shr    $0x16,%edx
  8005b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8005bc:	f6 c2 01             	test   $0x1,%dl
  8005bf:	74 1d                	je     8005de <fd_lookup+0x41>
  8005c1:	89 c2                	mov    %eax,%edx
  8005c3:	c1 ea 0c             	shr    $0xc,%edx
  8005c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8005cd:	f6 c2 01             	test   $0x1,%dl
  8005d0:	74 0c                	je     8005de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8005d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005d5:	89 02                	mov    %eax,(%edx)
  8005d7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8005dc:	eb 05                	jmp    8005e3 <fd_lookup+0x46>
  8005de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8005e3:	5d                   	pop    %ebp
  8005e4:	c3                   	ret    

008005e5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8005e5:	55                   	push   %ebp
  8005e6:	89 e5                	mov    %esp,%ebp
  8005e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8005eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8005ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f5:	89 04 24             	mov    %eax,(%esp)
  8005f8:	e8 a0 ff ff ff       	call   80059d <fd_lookup>
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	78 0e                	js     80060f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800601:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800604:	8b 55 0c             	mov    0xc(%ebp),%edx
  800607:	89 50 04             	mov    %edx,0x4(%eax)
  80060a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80060f:	c9                   	leave  
  800610:	c3                   	ret    

00800611 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800611:	55                   	push   %ebp
  800612:	89 e5                	mov    %esp,%ebp
  800614:	56                   	push   %esi
  800615:	53                   	push   %ebx
  800616:	83 ec 10             	sub    $0x10,%esp
  800619:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80061c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80061f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800624:	b8 04 30 80 00       	mov    $0x803004,%eax
  800629:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80062f:	75 11                	jne    800642 <dev_lookup+0x31>
  800631:	eb 04                	jmp    800637 <dev_lookup+0x26>
  800633:	39 08                	cmp    %ecx,(%eax)
  800635:	75 10                	jne    800647 <dev_lookup+0x36>
			*dev = devtab[i];
  800637:	89 03                	mov    %eax,(%ebx)
  800639:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80063e:	66 90                	xchg   %ax,%ax
  800640:	eb 36                	jmp    800678 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800642:	be 14 24 80 00       	mov    $0x802414,%esi
  800647:	83 c2 01             	add    $0x1,%edx
  80064a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80064d:	85 c0                	test   %eax,%eax
  80064f:	75 e2                	jne    800633 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800651:	a1 08 40 80 00       	mov    0x804008,%eax
  800656:	8b 40 48             	mov    0x48(%eax),%eax
  800659:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80065d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800661:	c7 04 24 98 23 80 00 	movl   $0x802398,(%esp)
  800668:	e8 40 0d 00 00       	call   8013ad <cprintf>
	*dev = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  800678:	83 c4 10             	add    $0x10,%esp
  80067b:	5b                   	pop    %ebx
  80067c:	5e                   	pop    %esi
  80067d:	5d                   	pop    %ebp
  80067e:	c3                   	ret    

0080067f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	53                   	push   %ebx
  800683:	83 ec 24             	sub    $0x24,%esp
  800686:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800689:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80068c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800690:	8b 45 08             	mov    0x8(%ebp),%eax
  800693:	89 04 24             	mov    %eax,(%esp)
  800696:	e8 02 ff ff ff       	call   80059d <fd_lookup>
  80069b:	85 c0                	test   %eax,%eax
  80069d:	78 53                	js     8006f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	e8 5e ff ff ff       	call   800611 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	78 3b                	js     8006f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8006b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8006bf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8006c3:	74 2d                	je     8006f2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8006c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8006c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8006cf:	00 00 00 
	stat->st_isdir = 0;
  8006d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8006d9:	00 00 00 
	stat->st_dev = dev;
  8006dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8006e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006ec:	89 14 24             	mov    %edx,(%esp)
  8006ef:	ff 50 14             	call   *0x14(%eax)
}
  8006f2:	83 c4 24             	add    $0x24,%esp
  8006f5:	5b                   	pop    %ebx
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	53                   	push   %ebx
  8006fc:	83 ec 24             	sub    $0x24,%esp
  8006ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800702:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800705:	89 44 24 04          	mov    %eax,0x4(%esp)
  800709:	89 1c 24             	mov    %ebx,(%esp)
  80070c:	e8 8c fe ff ff       	call   80059d <fd_lookup>
  800711:	85 c0                	test   %eax,%eax
  800713:	78 5f                	js     800774 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800715:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800718:	89 44 24 04          	mov    %eax,0x4(%esp)
  80071c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071f:	8b 00                	mov    (%eax),%eax
  800721:	89 04 24             	mov    %eax,(%esp)
  800724:	e8 e8 fe ff ff       	call   800611 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800729:	85 c0                	test   %eax,%eax
  80072b:	78 47                	js     800774 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80072d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800730:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800734:	75 23                	jne    800759 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800736:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80073b:	8b 40 48             	mov    0x48(%eax),%eax
  80073e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800742:	89 44 24 04          	mov    %eax,0x4(%esp)
  800746:	c7 04 24 b8 23 80 00 	movl   $0x8023b8,(%esp)
  80074d:	e8 5b 0c 00 00       	call   8013ad <cprintf>
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800757:	eb 1b                	jmp    800774 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  800759:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80075c:	8b 48 18             	mov    0x18(%eax),%ecx
  80075f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800764:	85 c9                	test   %ecx,%ecx
  800766:	74 0c                	je     800774 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800768:	8b 45 0c             	mov    0xc(%ebp),%eax
  80076b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80076f:	89 14 24             	mov    %edx,(%esp)
  800772:	ff d1                	call   *%ecx
}
  800774:	83 c4 24             	add    $0x24,%esp
  800777:	5b                   	pop    %ebx
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	83 ec 24             	sub    $0x24,%esp
  800781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800784:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078b:	89 1c 24             	mov    %ebx,(%esp)
  80078e:	e8 0a fe ff ff       	call   80059d <fd_lookup>
  800793:	85 c0                	test   %eax,%eax
  800795:	78 66                	js     8007fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800797:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 66 fe ff ff       	call   800611 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 4e                	js     8007fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8007b2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8007b6:	75 23                	jne    8007db <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8007bd:	8b 40 48             	mov    0x48(%eax),%eax
  8007c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c8:	c7 04 24 d9 23 80 00 	movl   $0x8023d9,(%esp)
  8007cf:	e8 d9 0b 00 00       	call   8013ad <cprintf>
  8007d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8007d9:	eb 22                	jmp    8007fd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007de:	8b 48 0c             	mov    0xc(%eax),%ecx
  8007e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007e6:	85 c9                	test   %ecx,%ecx
  8007e8:	74 13                	je     8007fd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f8:	89 14 24             	mov    %edx,(%esp)
  8007fb:	ff d1                	call   *%ecx
}
  8007fd:	83 c4 24             	add    $0x24,%esp
  800800:	5b                   	pop    %ebx
  800801:	5d                   	pop    %ebp
  800802:	c3                   	ret    

00800803 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	53                   	push   %ebx
  800807:	83 ec 24             	sub    $0x24,%esp
  80080a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800810:	89 44 24 04          	mov    %eax,0x4(%esp)
  800814:	89 1c 24             	mov    %ebx,(%esp)
  800817:	e8 81 fd ff ff       	call   80059d <fd_lookup>
  80081c:	85 c0                	test   %eax,%eax
  80081e:	78 6b                	js     80088b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800820:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800823:	89 44 24 04          	mov    %eax,0x4(%esp)
  800827:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082a:	8b 00                	mov    (%eax),%eax
  80082c:	89 04 24             	mov    %eax,(%esp)
  80082f:	e8 dd fd ff ff       	call   800611 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800834:	85 c0                	test   %eax,%eax
  800836:	78 53                	js     80088b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800838:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80083b:	8b 42 08             	mov    0x8(%edx),%eax
  80083e:	83 e0 03             	and    $0x3,%eax
  800841:	83 f8 01             	cmp    $0x1,%eax
  800844:	75 23                	jne    800869 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800846:	a1 08 40 80 00       	mov    0x804008,%eax
  80084b:	8b 40 48             	mov    0x48(%eax),%eax
  80084e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800852:	89 44 24 04          	mov    %eax,0x4(%esp)
  800856:	c7 04 24 f6 23 80 00 	movl   $0x8023f6,(%esp)
  80085d:	e8 4b 0b 00 00       	call   8013ad <cprintf>
  800862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800867:	eb 22                	jmp    80088b <read+0x88>
	}
	if (!dev->dev_read)
  800869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086c:	8b 48 08             	mov    0x8(%eax),%ecx
  80086f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800874:	85 c9                	test   %ecx,%ecx
  800876:	74 13                	je     80088b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800878:	8b 45 10             	mov    0x10(%ebp),%eax
  80087b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800882:	89 44 24 04          	mov    %eax,0x4(%esp)
  800886:	89 14 24             	mov    %edx,(%esp)
  800889:	ff d1                	call   *%ecx
}
  80088b:	83 c4 24             	add    $0x24,%esp
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	57                   	push   %edi
  800895:	56                   	push   %esi
  800896:	53                   	push   %ebx
  800897:	83 ec 1c             	sub    $0x1c,%esp
  80089a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80089d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8008af:	85 f6                	test   %esi,%esi
  8008b1:	74 29                	je     8008dc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8008b3:	89 f0                	mov    %esi,%eax
  8008b5:	29 d0                	sub    %edx,%eax
  8008b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008bb:	03 55 0c             	add    0xc(%ebp),%edx
  8008be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c2:	89 3c 24             	mov    %edi,(%esp)
  8008c5:	e8 39 ff ff ff       	call   800803 <read>
		if (m < 0)
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	78 0e                	js     8008dc <readn+0x4b>
			return m;
		if (m == 0)
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	74 08                	je     8008da <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8008d2:	01 c3                	add    %eax,%ebx
  8008d4:	89 da                	mov    %ebx,%edx
  8008d6:	39 f3                	cmp    %esi,%ebx
  8008d8:	72 d9                	jb     8008b3 <readn+0x22>
  8008da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8008dc:	83 c4 1c             	add    $0x1c,%esp
  8008df:	5b                   	pop    %ebx
  8008e0:	5e                   	pop    %esi
  8008e1:	5f                   	pop    %edi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 28             	sub    $0x28,%esp
  8008ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8008ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8008f0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008f3:	89 34 24             	mov    %esi,(%esp)
  8008f6:	e8 05 fc ff ff       	call   800500 <fd2num>
  8008fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8008fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800902:	89 04 24             	mov    %eax,(%esp)
  800905:	e8 93 fc ff ff       	call   80059d <fd_lookup>
  80090a:	89 c3                	mov    %eax,%ebx
  80090c:	85 c0                	test   %eax,%eax
  80090e:	78 05                	js     800915 <fd_close+0x31>
  800910:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800913:	74 0e                	je     800923 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800915:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	0f 44 d8             	cmove  %eax,%ebx
  800921:	eb 3d                	jmp    800960 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800923:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	8b 06                	mov    (%esi),%eax
  80092c:	89 04 24             	mov    %eax,(%esp)
  80092f:	e8 dd fc ff ff       	call   800611 <dev_lookup>
  800934:	89 c3                	mov    %eax,%ebx
  800936:	85 c0                	test   %eax,%eax
  800938:	78 16                	js     800950 <fd_close+0x6c>
		if (dev->dev_close)
  80093a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80093d:	8b 40 10             	mov    0x10(%eax),%eax
  800940:	bb 00 00 00 00       	mov    $0x0,%ebx
  800945:	85 c0                	test   %eax,%eax
  800947:	74 07                	je     800950 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800949:	89 34 24             	mov    %esi,(%esp)
  80094c:	ff d0                	call   *%eax
  80094e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800950:	89 74 24 04          	mov    %esi,0x4(%esp)
  800954:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80095b:	e8 68 f9 ff ff       	call   8002c8 <sys_page_unmap>
	return r;
}
  800960:	89 d8                	mov    %ebx,%eax
  800962:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800965:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800968:	89 ec                	mov    %ebp,%esp
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800972:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800975:	89 44 24 04          	mov    %eax,0x4(%esp)
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	89 04 24             	mov    %eax,(%esp)
  80097f:	e8 19 fc ff ff       	call   80059d <fd_lookup>
  800984:	85 c0                	test   %eax,%eax
  800986:	78 13                	js     80099b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800988:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80098f:	00 
  800990:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800993:	89 04 24             	mov    %eax,(%esp)
  800996:	e8 49 ff ff ff       	call   8008e4 <fd_close>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 18             	sub    $0x18,%esp
  8009a3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8009a6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8009a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009b0:	00 
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	89 04 24             	mov    %eax,(%esp)
  8009b7:	e8 78 03 00 00       	call   800d34 <open>
  8009bc:	89 c3                	mov    %eax,%ebx
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 1b                	js     8009dd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8009c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c9:	89 1c 24             	mov    %ebx,(%esp)
  8009cc:	e8 ae fc ff ff       	call   80067f <fstat>
  8009d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8009d3:	89 1c 24             	mov    %ebx,(%esp)
  8009d6:	e8 91 ff ff ff       	call   80096c <close>
  8009db:	89 f3                	mov    %esi,%ebx
	return r;
}
  8009dd:	89 d8                	mov    %ebx,%eax
  8009df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8009e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8009e5:	89 ec                	mov    %ebp,%esp
  8009e7:	5d                   	pop    %ebp
  8009e8:	c3                   	ret    

008009e9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	53                   	push   %ebx
  8009ed:	83 ec 14             	sub    $0x14,%esp
  8009f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8009f5:	89 1c 24             	mov    %ebx,(%esp)
  8009f8:	e8 6f ff ff ff       	call   80096c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8009fd:	83 c3 01             	add    $0x1,%ebx
  800a00:	83 fb 20             	cmp    $0x20,%ebx
  800a03:	75 f0                	jne    8009f5 <close_all+0xc>
		close(i);
}
  800a05:	83 c4 14             	add    $0x14,%esp
  800a08:	5b                   	pop    %ebx
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	83 ec 58             	sub    $0x58,%esp
  800a11:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800a14:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800a17:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800a1a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800a1d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800a20:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	89 04 24             	mov    %eax,(%esp)
  800a2a:	e8 6e fb ff ff       	call   80059d <fd_lookup>
  800a2f:	89 c3                	mov    %eax,%ebx
  800a31:	85 c0                	test   %eax,%eax
  800a33:	0f 88 e0 00 00 00    	js     800b19 <dup+0x10e>
		return r;
	close(newfdnum);
  800a39:	89 3c 24             	mov    %edi,(%esp)
  800a3c:	e8 2b ff ff ff       	call   80096c <close>

	newfd = INDEX2FD(newfdnum);
  800a41:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800a47:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  800a4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a4d:	89 04 24             	mov    %eax,(%esp)
  800a50:	e8 bb fa ff ff       	call   800510 <fd2data>
  800a55:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800a57:	89 34 24             	mov    %esi,(%esp)
  800a5a:	e8 b1 fa ff ff       	call   800510 <fd2data>
  800a5f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  800a62:	89 da                	mov    %ebx,%edx
  800a64:	89 d8                	mov    %ebx,%eax
  800a66:	c1 e8 16             	shr    $0x16,%eax
  800a69:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800a70:	a8 01                	test   $0x1,%al
  800a72:	74 43                	je     800ab7 <dup+0xac>
  800a74:	c1 ea 0c             	shr    $0xc,%edx
  800a77:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a7e:	a8 01                	test   $0x1,%al
  800a80:	74 35                	je     800ab7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800a82:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  800a89:	25 07 0e 00 00       	and    $0xe07,%eax
  800a8e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a92:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a99:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800aa0:	00 
  800aa1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800aac:	e8 4f f8 ff ff       	call   800300 <sys_page_map>
  800ab1:	89 c3                	mov    %eax,%ebx
  800ab3:	85 c0                	test   %eax,%eax
  800ab5:	78 3f                	js     800af6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ab7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800aba:	89 c2                	mov    %eax,%edx
  800abc:	c1 ea 0c             	shr    $0xc,%edx
  800abf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ac6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800acc:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ad0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ad4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800adb:	00 
  800adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ae7:	e8 14 f8 ff ff       	call   800300 <sys_page_map>
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	85 c0                	test   %eax,%eax
  800af0:	78 04                	js     800af6 <dup+0xeb>
  800af2:	89 fb                	mov    %edi,%ebx
  800af4:	eb 23                	jmp    800b19 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800af6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800afa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b01:	e8 c2 f7 ff ff       	call   8002c8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800b06:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b14:	e8 af f7 ff ff       	call   8002c8 <sys_page_unmap>
	return r;
}
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800b1e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800b21:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800b24:	89 ec                	mov    %ebp,%esp
  800b26:	5d                   	pop    %ebp
  800b27:	c3                   	ret    

00800b28 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800b28:	55                   	push   %ebp
  800b29:	89 e5                	mov    %esp,%ebp
  800b2b:	83 ec 18             	sub    $0x18,%esp
  800b2e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800b31:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800b34:	89 c3                	mov    %eax,%ebx
  800b36:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800b38:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800b3f:	75 11                	jne    800b52 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800b41:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b48:	e8 03 14 00 00       	call   801f50 <ipc_find_env>
  800b4d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800b52:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800b59:	00 
  800b5a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800b61:	00 
  800b62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800b66:	a1 00 40 80 00       	mov    0x804000,%eax
  800b6b:	89 04 24             	mov    %eax,(%esp)
  800b6e:	e8 26 14 00 00       	call   801f99 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800b73:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800b7a:	00 
  800b7b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b86:	e8 79 14 00 00       	call   802004 <ipc_recv>
}
  800b8b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800b8e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800b91:	89 ec                	mov    %ebp,%esp
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800b9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9e:	8b 40 0c             	mov    0xc(%eax),%eax
  800ba1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb8:	e8 6b ff ff ff       	call   800b28 <fsipc>
}
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	8b 40 0c             	mov    0xc(%eax),%eax
  800bcb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd5:	b8 06 00 00 00       	mov    $0x6,%eax
  800bda:	e8 49 ff ff ff       	call   800b28 <fsipc>
}
  800bdf:	c9                   	leave  
  800be0:	c3                   	ret    

00800be1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 08 00 00 00       	mov    $0x8,%eax
  800bf1:	e8 32 ff ff ff       	call   800b28 <fsipc>
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 14             	sub    $0x14,%esp
  800bff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	8b 40 0c             	mov    0xc(%eax),%eax
  800c08:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 05 00 00 00       	mov    $0x5,%eax
  800c17:	e8 0c ff ff ff       	call   800b28 <fsipc>
  800c1c:	85 c0                	test   %eax,%eax
  800c1e:	78 2b                	js     800c4b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800c20:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c27:	00 
  800c28:	89 1c 24             	mov    %ebx,(%esp)
  800c2b:	e8 ba 0e 00 00       	call   801aea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800c30:	a1 80 50 80 00       	mov    0x805080,%eax
  800c35:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800c3b:	a1 84 50 80 00       	mov    0x805084,%eax
  800c40:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800c4b:	83 c4 14             	add    $0x14,%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 18             	sub    $0x18,%esp
  800c57:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 52 0c             	mov    0xc(%edx),%edx
  800c60:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800c66:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800c6b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800c70:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800c75:	0f 47 c2             	cmova  %edx,%eax
  800c78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c83:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800c8a:	e8 46 10 00 00       	call   801cd5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800c8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c94:	b8 04 00 00 00       	mov    $0x4,%eax
  800c99:	e8 8a fe ff ff       	call   800b28 <fsipc>
}
  800c9e:	c9                   	leave  
  800c9f:	c3                   	ret    

00800ca0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	53                   	push   %ebx
  800ca4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  800caa:	8b 40 0c             	mov    0xc(%eax),%eax
  800cad:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800cb2:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800cba:	ba 00 00 00 00       	mov    $0x0,%edx
  800cbf:	b8 03 00 00 00       	mov    $0x3,%eax
  800cc4:	e8 5f fe ff ff       	call   800b28 <fsipc>
  800cc9:	89 c3                	mov    %eax,%ebx
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	78 17                	js     800ce6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ccf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cd3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800cda:	00 
  800cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cde:	89 04 24             	mov    %eax,(%esp)
  800ce1:	e8 ef 0f 00 00       	call   801cd5 <memmove>
  return r;	
}
  800ce6:	89 d8                	mov    %ebx,%eax
  800ce8:	83 c4 14             	add    $0x14,%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5d                   	pop    %ebp
  800ced:	c3                   	ret    

00800cee <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	53                   	push   %ebx
  800cf2:	83 ec 14             	sub    $0x14,%esp
  800cf5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800cf8:	89 1c 24             	mov    %ebx,(%esp)
  800cfb:	e8 a0 0d 00 00       	call   801aa0 <strlen>
  800d00:	89 c2                	mov    %eax,%edx
  800d02:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800d07:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800d0d:	7f 1f                	jg     800d2e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800d0f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800d13:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d1a:	e8 cb 0d 00 00       	call   801aea <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800d1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d24:	b8 07 00 00 00       	mov    $0x7,%eax
  800d29:	e8 fa fd ff ff       	call   800b28 <fsipc>
}
  800d2e:	83 c4 14             	add    $0x14,%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 28             	sub    $0x28,%esp
  800d3a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800d3d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800d40:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d46:	89 04 24             	mov    %eax,(%esp)
  800d49:	e8 dd f7 ff ff       	call   80052b <fd_alloc>
  800d4e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800d50:	85 c0                	test   %eax,%eax
  800d52:	0f 88 89 00 00 00    	js     800de1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d58:	89 34 24             	mov    %esi,(%esp)
  800d5b:	e8 40 0d 00 00       	call   801aa0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800d60:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800d65:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800d6a:	7f 75                	jg     800de1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800d6c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d70:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800d77:	e8 6e 0d 00 00       	call   801aea <strcpy>
  fsipcbuf.open.req_omode = mode;
  800d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800d84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800d87:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8c:	e8 97 fd ff ff       	call   800b28 <fsipc>
  800d91:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800d93:	85 c0                	test   %eax,%eax
  800d95:	78 0f                	js     800da6 <open+0x72>
  return fd2num(fd);
  800d97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d9a:	89 04 24             	mov    %eax,(%esp)
  800d9d:	e8 5e f7 ff ff       	call   800500 <fd2num>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	eb 3b                	jmp    800de1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800da6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dad:	00 
  800dae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800db1:	89 04 24             	mov    %eax,(%esp)
  800db4:	e8 2b fb ff ff       	call   8008e4 <fd_close>
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	74 24                	je     800de1 <open+0xad>
  800dbd:	c7 44 24 0c 20 24 80 	movl   $0x802420,0xc(%esp)
  800dc4:	00 
  800dc5:	c7 44 24 08 35 24 80 	movl   $0x802435,0x8(%esp)
  800dcc:	00 
  800dcd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800dd4:	00 
  800dd5:	c7 04 24 4a 24 80 00 	movl   $0x80244a,(%esp)
  800ddc:	e8 13 05 00 00       	call   8012f4 <_panic>
  return r;
}
  800de1:	89 d8                	mov    %ebx,%eax
  800de3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800de6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800de9:	89 ec                	mov    %ebp,%esp
  800deb:	5d                   	pop    %ebp
  800dec:	c3                   	ret    
  800ded:	00 00                	add    %al,(%eax)
	...

00800df0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  800df6:	c7 44 24 04 55 24 80 	movl   $0x802455,0x4(%esp)
  800dfd:	00 
  800dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e01:	89 04 24             	mov    %eax,(%esp)
  800e04:	e8 e1 0c 00 00       	call   801aea <strcpy>
	return 0;
}
  800e09:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    

00800e10 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	53                   	push   %ebx
  800e14:	83 ec 14             	sub    $0x14,%esp
  800e17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800e1a:	89 1c 24             	mov    %ebx,(%esp)
  800e1d:	e8 72 12 00 00       	call   802094 <pageref>
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	b8 00 00 00 00       	mov    $0x0,%eax
  800e29:	83 fa 01             	cmp    $0x1,%edx
  800e2c:	75 0b                	jne    800e39 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  800e2e:	8b 43 0c             	mov    0xc(%ebx),%eax
  800e31:	89 04 24             	mov    %eax,(%esp)
  800e34:	e8 b9 02 00 00       	call   8010f2 <nsipc_close>
	else
		return 0;
}
  800e39:	83 c4 14             	add    $0x14,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800e45:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e4c:	00 
  800e4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	8b 40 0c             	mov    0xc(%eax),%eax
  800e61:	89 04 24             	mov    %eax,(%esp)
  800e64:	e8 c5 02 00 00       	call   80112e <nsipc_send>
}
  800e69:	c9                   	leave  
  800e6a:	c3                   	ret    

00800e6b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800e71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e78:	00 
  800e79:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	8b 40 0c             	mov    0xc(%eax),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	e8 0c 03 00 00       	call   8011a1 <nsipc_recv>
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 20             	sub    $0x20,%esp
  800e9f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ea1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea4:	89 04 24             	mov    %eax,(%esp)
  800ea7:	e8 7f f6 ff ff       	call   80052b <fd_alloc>
  800eac:	89 c3                	mov    %eax,%ebx
  800eae:	85 c0                	test   %eax,%eax
  800eb0:	78 21                	js     800ed3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800eb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  800eb9:	00 
  800eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec8:	e8 6c f4 ff ff       	call   800339 <sys_page_alloc>
  800ecd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800ecf:	85 c0                	test   %eax,%eax
  800ed1:	79 0a                	jns    800edd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  800ed3:	89 34 24             	mov    %esi,(%esp)
  800ed6:	e8 17 02 00 00       	call   8010f2 <nsipc_close>
		return r;
  800edb:	eb 28                	jmp    800f05 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800edd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ee3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ee8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eeb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ef5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800efb:	89 04 24             	mov    %eax,(%esp)
  800efe:	e8 fd f5 ff ff       	call   800500 <fd2num>
  800f03:	89 c3                	mov    %eax,%ebx
}
  800f05:	89 d8                	mov    %ebx,%eax
  800f07:	83 c4 20             	add    $0x20,%esp
  800f0a:	5b                   	pop    %ebx
  800f0b:	5e                   	pop    %esi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800f14:	8b 45 10             	mov    0x10(%ebp),%eax
  800f17:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f22:	8b 45 08             	mov    0x8(%ebp),%eax
  800f25:	89 04 24             	mov    %eax,(%esp)
  800f28:	e8 79 01 00 00       	call   8010a6 <nsipc_socket>
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 05                	js     800f36 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  800f31:	e8 61 ff ff ff       	call   800e97 <alloc_sockfd>
}
  800f36:	c9                   	leave  
  800f37:	c3                   	ret    

00800f38 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800f38:	55                   	push   %ebp
  800f39:	89 e5                	mov    %esp,%ebp
  800f3b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800f3e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f41:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f45:	89 04 24             	mov    %eax,(%esp)
  800f48:	e8 50 f6 ff ff       	call   80059d <fd_lookup>
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 15                	js     800f66 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800f51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f54:	8b 0a                	mov    (%edx),%ecx
  800f56:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800f5b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  800f61:	75 03                	jne    800f66 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800f63:	8b 42 0c             	mov    0xc(%edx),%eax
}
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f71:	e8 c2 ff ff ff       	call   800f38 <fd2sockid>
  800f76:	85 c0                	test   %eax,%eax
  800f78:	78 0f                	js     800f89 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f81:	89 04 24             	mov    %eax,(%esp)
  800f84:	e8 47 01 00 00       	call   8010d0 <nsipc_listen>
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	e8 9f ff ff ff       	call   800f38 <fd2sockid>
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 16                	js     800fb3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  800f9d:	8b 55 10             	mov    0x10(%ebp),%edx
  800fa0:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fa4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fa7:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fab:	89 04 24             	mov    %eax,(%esp)
  800fae:	e8 6e 02 00 00       	call   801221 <nsipc_connect>
}
  800fb3:	c9                   	leave  
  800fb4:	c3                   	ret    

00800fb5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  800fb5:	55                   	push   %ebp
  800fb6:	89 e5                	mov    %esp,%ebp
  800fb8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbe:	e8 75 ff ff ff       	call   800f38 <fd2sockid>
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 0f                	js     800fd6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800fc7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fca:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fce:	89 04 24             	mov    %eax,(%esp)
  800fd1:	e8 36 01 00 00       	call   80110c <nsipc_shutdown>
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800fde:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe1:	e8 52 ff ff ff       	call   800f38 <fd2sockid>
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 16                	js     801000 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  800fea:	8b 55 10             	mov    0x10(%ebp),%edx
  800fed:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ff1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ff4:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ff8:	89 04 24             	mov    %eax,(%esp)
  800ffb:	e8 60 02 00 00       	call   801260 <nsipc_bind>
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801008:	8b 45 08             	mov    0x8(%ebp),%eax
  80100b:	e8 28 ff ff ff       	call   800f38 <fd2sockid>
  801010:	85 c0                	test   %eax,%eax
  801012:	78 1f                	js     801033 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801014:	8b 55 10             	mov    0x10(%ebp),%edx
  801017:	89 54 24 08          	mov    %edx,0x8(%esp)
  80101b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801022:	89 04 24             	mov    %eax,(%esp)
  801025:	e8 75 02 00 00       	call   80129f <nsipc_accept>
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 05                	js     801033 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80102e:	e8 64 fe ff ff       	call   800e97 <alloc_sockfd>
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    
	...

00801040 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	53                   	push   %ebx
  801044:	83 ec 14             	sub    $0x14,%esp
  801047:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801049:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801050:	75 11                	jne    801063 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801052:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801059:	e8 f2 0e 00 00       	call   801f50 <ipc_find_env>
  80105e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801063:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80106a:	00 
  80106b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801072:	00 
  801073:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801077:	a1 04 40 80 00       	mov    0x804004,%eax
  80107c:	89 04 24             	mov    %eax,(%esp)
  80107f:	e8 15 0f 00 00       	call   801f99 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801084:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80108b:	00 
  80108c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801093:	00 
  801094:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109b:	e8 64 0f 00 00       	call   802004 <ipc_recv>
}
  8010a0:	83 c4 14             	add    $0x14,%esp
  8010a3:	5b                   	pop    %ebx
  8010a4:	5d                   	pop    %ebp
  8010a5:	c3                   	ret    

008010a6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8010b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8010bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8010bf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8010c4:	b8 09 00 00 00       	mov    $0x9,%eax
  8010c9:	e8 72 ff ff ff       	call   801040 <nsipc>
}
  8010ce:	c9                   	leave  
  8010cf:	c3                   	ret    

008010d0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8010de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8010e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8010eb:	e8 50 ff ff ff       	call   801040 <nsipc>
}
  8010f0:	c9                   	leave  
  8010f1:	c3                   	ret    

008010f2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
  8010f5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801100:	b8 04 00 00 00       	mov    $0x4,%eax
  801105:	e8 36 ff ff ff       	call   801040 <nsipc>
}
  80110a:	c9                   	leave  
  80110b:	c3                   	ret    

0080110c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80110c:	55                   	push   %ebp
  80110d:	89 e5                	mov    %esp,%ebp
  80110f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801112:	8b 45 08             	mov    0x8(%ebp),%eax
  801115:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80111a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80111d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801122:	b8 03 00 00 00       	mov    $0x3,%eax
  801127:	e8 14 ff ff ff       	call   801040 <nsipc>
}
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    

0080112e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	53                   	push   %ebx
  801132:	83 ec 14             	sub    $0x14,%esp
  801135:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801140:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801146:	7e 24                	jle    80116c <nsipc_send+0x3e>
  801148:	c7 44 24 0c 61 24 80 	movl   $0x802461,0xc(%esp)
  80114f:	00 
  801150:	c7 44 24 08 35 24 80 	movl   $0x802435,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 6d 24 80 00 	movl   $0x80246d,(%esp)
  801167:	e8 88 01 00 00       	call   8012f4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80116c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801170:	8b 45 0c             	mov    0xc(%ebp),%eax
  801173:	89 44 24 04          	mov    %eax,0x4(%esp)
  801177:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80117e:	e8 52 0b 00 00       	call   801cd5 <memmove>
	nsipcbuf.send.req_size = size;
  801183:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801189:	8b 45 14             	mov    0x14(%ebp),%eax
  80118c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801191:	b8 08 00 00 00       	mov    $0x8,%eax
  801196:	e8 a5 fe ff ff       	call   801040 <nsipc>
}
  80119b:	83 c4 14             	add    $0x14,%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	56                   	push   %esi
  8011a5:	53                   	push   %ebx
  8011a6:	83 ec 10             	sub    $0x10,%esp
  8011a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8011ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8011af:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8011b4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8011ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8011bd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8011c2:	b8 07 00 00 00       	mov    $0x7,%eax
  8011c7:	e8 74 fe ff ff       	call   801040 <nsipc>
  8011cc:	89 c3                	mov    %eax,%ebx
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	78 46                	js     801218 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8011d2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8011d7:	7f 04                	jg     8011dd <nsipc_recv+0x3c>
  8011d9:	39 c6                	cmp    %eax,%esi
  8011db:	7d 24                	jge    801201 <nsipc_recv+0x60>
  8011dd:	c7 44 24 0c 79 24 80 	movl   $0x802479,0xc(%esp)
  8011e4:	00 
  8011e5:	c7 44 24 08 35 24 80 	movl   $0x802435,0x8(%esp)
  8011ec:	00 
  8011ed:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8011f4:	00 
  8011f5:	c7 04 24 6d 24 80 00 	movl   $0x80246d,(%esp)
  8011fc:	e8 f3 00 00 00       	call   8012f4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801201:	89 44 24 08          	mov    %eax,0x8(%esp)
  801205:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80120c:	00 
  80120d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801210:	89 04 24             	mov    %eax,(%esp)
  801213:	e8 bd 0a 00 00       	call   801cd5 <memmove>
	}

	return r;
}
  801218:	89 d8                	mov    %ebx,%eax
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	53                   	push   %ebx
  801225:	83 ec 14             	sub    $0x14,%esp
  801228:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80122b:	8b 45 08             	mov    0x8(%ebp),%eax
  80122e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801233:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801237:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801245:	e8 8b 0a 00 00       	call   801cd5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80124a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801250:	b8 05 00 00 00       	mov    $0x5,%eax
  801255:	e8 e6 fd ff ff       	call   801040 <nsipc>
}
  80125a:	83 c4 14             	add    $0x14,%esp
  80125d:	5b                   	pop    %ebx
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	53                   	push   %ebx
  801264:	83 ec 14             	sub    $0x14,%esp
  801267:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80126a:	8b 45 08             	mov    0x8(%ebp),%eax
  80126d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801272:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801276:	8b 45 0c             	mov    0xc(%ebp),%eax
  801279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801284:	e8 4c 0a 00 00       	call   801cd5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801289:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80128f:	b8 02 00 00 00       	mov    $0x2,%eax
  801294:	e8 a7 fd ff ff       	call   801040 <nsipc>
}
  801299:	83 c4 14             	add    $0x14,%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 18             	sub    $0x18,%esp
  8012a5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8012a8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8012ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ae:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8012b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8012b8:	e8 83 fd ff ff       	call   801040 <nsipc>
  8012bd:	89 c3                	mov    %eax,%ebx
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 25                	js     8012e8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8012c3:	be 10 60 80 00       	mov    $0x806010,%esi
  8012c8:	8b 06                	mov    (%esi),%eax
  8012ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ce:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8012d5:	00 
  8012d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d9:	89 04 24             	mov    %eax,(%esp)
  8012dc:	e8 f4 09 00 00       	call   801cd5 <memmove>
		*addrlen = ret->ret_addrlen;
  8012e1:	8b 16                	mov    (%esi),%edx
  8012e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8012e6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8012e8:	89 d8                	mov    %ebx,%eax
  8012ea:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8012ed:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8012f0:	89 ec                	mov    %ebp,%esp
  8012f2:	5d                   	pop    %ebp
  8012f3:	c3                   	ret    

008012f4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	56                   	push   %esi
  8012f8:	53                   	push   %ebx
  8012f9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8012fc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8012ff:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801305:	e8 d9 f0 ff ff       	call   8003e3 <sys_getenvid>
  80130a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801311:	8b 55 08             	mov    0x8(%ebp),%edx
  801314:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801318:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801320:	c7 04 24 90 24 80 00 	movl   $0x802490,(%esp)
  801327:	e8 81 00 00 00       	call   8013ad <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80132c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801330:	8b 45 10             	mov    0x10(%ebp),%eax
  801333:	89 04 24             	mov    %eax,(%esp)
  801336:	e8 11 00 00 00       	call   80134c <vcprintf>
	cprintf("\n");
  80133b:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  801342:	e8 66 00 00 00       	call   8013ad <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801347:	cc                   	int3   
  801348:	eb fd                	jmp    801347 <_panic+0x53>
	...

0080134c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801355:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80135c:	00 00 00 
	b.cnt = 0;
  80135f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801366:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801369:	8b 45 0c             	mov    0xc(%ebp),%eax
  80136c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801370:	8b 45 08             	mov    0x8(%ebp),%eax
  801373:	89 44 24 08          	mov    %eax,0x8(%esp)
  801377:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80137d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801381:	c7 04 24 c7 13 80 00 	movl   $0x8013c7,(%esp)
  801388:	e8 d0 01 00 00       	call   80155d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80138d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801393:	89 44 24 04          	mov    %eax,0x4(%esp)
  801397:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	e8 ed f0 ff ff       	call   800492 <sys_cputs>

	return b.cnt;
}
  8013a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8013ab:	c9                   	leave  
  8013ac:	c3                   	ret    

008013ad <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8013b3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8013b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bd:	89 04 24             	mov    %eax,(%esp)
  8013c0:	e8 87 ff ff ff       	call   80134c <vcprintf>
	va_end(ap);

	return cnt;
}
  8013c5:	c9                   	leave  
  8013c6:	c3                   	ret    

008013c7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8013c7:	55                   	push   %ebp
  8013c8:	89 e5                	mov    %esp,%ebp
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 14             	sub    $0x14,%esp
  8013ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8013d1:	8b 03                	mov    (%ebx),%eax
  8013d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8013d6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8013da:	83 c0 01             	add    $0x1,%eax
  8013dd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8013df:	3d ff 00 00 00       	cmp    $0xff,%eax
  8013e4:	75 19                	jne    8013ff <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8013e6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8013ed:	00 
  8013ee:	8d 43 08             	lea    0x8(%ebx),%eax
  8013f1:	89 04 24             	mov    %eax,(%esp)
  8013f4:	e8 99 f0 ff ff       	call   800492 <sys_cputs>
		b->idx = 0;
  8013f9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8013ff:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801403:	83 c4 14             	add    $0x14,%esp
  801406:	5b                   	pop    %ebx
  801407:	5d                   	pop    %ebp
  801408:	c3                   	ret    
  801409:	00 00                	add    %al,(%eax)
  80140b:	00 00                	add    %al,(%eax)
  80140d:	00 00                	add    %al,(%eax)
	...

00801410 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801410:	55                   	push   %ebp
  801411:	89 e5                	mov    %esp,%ebp
  801413:	57                   	push   %edi
  801414:	56                   	push   %esi
  801415:	53                   	push   %ebx
  801416:	83 ec 4c             	sub    $0x4c,%esp
  801419:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80141c:	89 d6                	mov    %edx,%esi
  80141e:	8b 45 08             	mov    0x8(%ebp),%eax
  801421:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801424:	8b 55 0c             	mov    0xc(%ebp),%edx
  801427:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80142a:	8b 45 10             	mov    0x10(%ebp),%eax
  80142d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801430:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801433:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801436:	b9 00 00 00 00       	mov    $0x0,%ecx
  80143b:	39 d1                	cmp    %edx,%ecx
  80143d:	72 15                	jb     801454 <printnum+0x44>
  80143f:	77 07                	ja     801448 <printnum+0x38>
  801441:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801444:	39 d0                	cmp    %edx,%eax
  801446:	76 0c                	jbe    801454 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801448:	83 eb 01             	sub    $0x1,%ebx
  80144b:	85 db                	test   %ebx,%ebx
  80144d:	8d 76 00             	lea    0x0(%esi),%esi
  801450:	7f 61                	jg     8014b3 <printnum+0xa3>
  801452:	eb 70                	jmp    8014c4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801454:	89 7c 24 10          	mov    %edi,0x10(%esp)
  801458:	83 eb 01             	sub    $0x1,%ebx
  80145b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80145f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801463:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801467:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80146b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80146e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  801471:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  801474:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801478:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80147f:	00 
  801480:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801489:	89 54 24 04          	mov    %edx,0x4(%esp)
  80148d:	e8 4e 0c 00 00       	call   8020e0 <__udivdi3>
  801492:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801495:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  801498:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80149c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8014a0:	89 04 24             	mov    %eax,(%esp)
  8014a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014a7:	89 f2                	mov    %esi,%edx
  8014a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014ac:	e8 5f ff ff ff       	call   801410 <printnum>
  8014b1:	eb 11                	jmp    8014c4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8014b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b7:	89 3c 24             	mov    %edi,(%esp)
  8014ba:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8014bd:	83 eb 01             	sub    $0x1,%ebx
  8014c0:	85 db                	test   %ebx,%ebx
  8014c2:	7f ef                	jg     8014b3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8014c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8014cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014da:	00 
  8014db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014de:	89 14 24             	mov    %edx,(%esp)
  8014e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8014e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014e8:	e8 23 0d 00 00       	call   802210 <__umoddi3>
  8014ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014f1:	0f be 80 b3 24 80 00 	movsbl 0x8024b3(%eax),%eax
  8014f8:	89 04 24             	mov    %eax,(%esp)
  8014fb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8014fe:	83 c4 4c             	add    $0x4c,%esp
  801501:	5b                   	pop    %ebx
  801502:	5e                   	pop    %esi
  801503:	5f                   	pop    %edi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801509:	83 fa 01             	cmp    $0x1,%edx
  80150c:	7e 0e                	jle    80151c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80150e:	8b 10                	mov    (%eax),%edx
  801510:	8d 4a 08             	lea    0x8(%edx),%ecx
  801513:	89 08                	mov    %ecx,(%eax)
  801515:	8b 02                	mov    (%edx),%eax
  801517:	8b 52 04             	mov    0x4(%edx),%edx
  80151a:	eb 22                	jmp    80153e <getuint+0x38>
	else if (lflag)
  80151c:	85 d2                	test   %edx,%edx
  80151e:	74 10                	je     801530 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801520:	8b 10                	mov    (%eax),%edx
  801522:	8d 4a 04             	lea    0x4(%edx),%ecx
  801525:	89 08                	mov    %ecx,(%eax)
  801527:	8b 02                	mov    (%edx),%eax
  801529:	ba 00 00 00 00       	mov    $0x0,%edx
  80152e:	eb 0e                	jmp    80153e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801530:	8b 10                	mov    (%eax),%edx
  801532:	8d 4a 04             	lea    0x4(%edx),%ecx
  801535:	89 08                	mov    %ecx,(%eax)
  801537:	8b 02                	mov    (%edx),%eax
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801546:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80154a:	8b 10                	mov    (%eax),%edx
  80154c:	3b 50 04             	cmp    0x4(%eax),%edx
  80154f:	73 0a                	jae    80155b <sprintputch+0x1b>
		*b->buf++ = ch;
  801551:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801554:	88 0a                	mov    %cl,(%edx)
  801556:	83 c2 01             	add    $0x1,%edx
  801559:	89 10                	mov    %edx,(%eax)
}
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	57                   	push   %edi
  801561:	56                   	push   %esi
  801562:	53                   	push   %ebx
  801563:	83 ec 5c             	sub    $0x5c,%esp
  801566:	8b 7d 08             	mov    0x8(%ebp),%edi
  801569:	8b 75 0c             	mov    0xc(%ebp),%esi
  80156c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80156f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801576:	eb 11                	jmp    801589 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801578:	85 c0                	test   %eax,%eax
  80157a:	0f 84 68 04 00 00    	je     8019e8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  801580:	89 74 24 04          	mov    %esi,0x4(%esp)
  801584:	89 04 24             	mov    %eax,(%esp)
  801587:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801589:	0f b6 03             	movzbl (%ebx),%eax
  80158c:	83 c3 01             	add    $0x1,%ebx
  80158f:	83 f8 25             	cmp    $0x25,%eax
  801592:	75 e4                	jne    801578 <vprintfmt+0x1b>
  801594:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80159b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8015a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8015ab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8015b2:	eb 06                	jmp    8015ba <vprintfmt+0x5d>
  8015b4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8015b8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ba:	0f b6 13             	movzbl (%ebx),%edx
  8015bd:	0f b6 c2             	movzbl %dl,%eax
  8015c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015c3:	8d 43 01             	lea    0x1(%ebx),%eax
  8015c6:	83 ea 23             	sub    $0x23,%edx
  8015c9:	80 fa 55             	cmp    $0x55,%dl
  8015cc:	0f 87 f9 03 00 00    	ja     8019cb <vprintfmt+0x46e>
  8015d2:	0f b6 d2             	movzbl %dl,%edx
  8015d5:	ff 24 95 a0 26 80 00 	jmp    *0x8026a0(,%edx,4)
  8015dc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8015e0:	eb d6                	jmp    8015b8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8015e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015e5:	83 ea 30             	sub    $0x30,%edx
  8015e8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8015eb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8015ee:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8015f1:	83 fb 09             	cmp    $0x9,%ebx
  8015f4:	77 54                	ja     80164a <vprintfmt+0xed>
  8015f6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8015f9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8015fc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8015ff:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801602:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  801606:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801609:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80160c:	83 fb 09             	cmp    $0x9,%ebx
  80160f:	76 eb                	jbe    8015fc <vprintfmt+0x9f>
  801611:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801614:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801617:	eb 31                	jmp    80164a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801619:	8b 55 14             	mov    0x14(%ebp),%edx
  80161c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80161f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801622:	8b 12                	mov    (%edx),%edx
  801624:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  801627:	eb 21                	jmp    80164a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  801629:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  801636:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801639:	e9 7a ff ff ff       	jmp    8015b8 <vprintfmt+0x5b>
  80163e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801645:	e9 6e ff ff ff       	jmp    8015b8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80164a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80164e:	0f 89 64 ff ff ff    	jns    8015b8 <vprintfmt+0x5b>
  801654:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801657:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80165a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80165d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801660:	e9 53 ff ff ff       	jmp    8015b8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801665:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  801668:	e9 4b ff ff ff       	jmp    8015b8 <vprintfmt+0x5b>
  80166d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801670:	8b 45 14             	mov    0x14(%ebp),%eax
  801673:	8d 50 04             	lea    0x4(%eax),%edx
  801676:	89 55 14             	mov    %edx,0x14(%ebp)
  801679:	89 74 24 04          	mov    %esi,0x4(%esp)
  80167d:	8b 00                	mov    (%eax),%eax
  80167f:	89 04 24             	mov    %eax,(%esp)
  801682:	ff d7                	call   *%edi
  801684:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801687:	e9 fd fe ff ff       	jmp    801589 <vprintfmt+0x2c>
  80168c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80168f:	8b 45 14             	mov    0x14(%ebp),%eax
  801692:	8d 50 04             	lea    0x4(%eax),%edx
  801695:	89 55 14             	mov    %edx,0x14(%ebp)
  801698:	8b 00                	mov    (%eax),%eax
  80169a:	89 c2                	mov    %eax,%edx
  80169c:	c1 fa 1f             	sar    $0x1f,%edx
  80169f:	31 d0                	xor    %edx,%eax
  8016a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016a3:	83 f8 0f             	cmp    $0xf,%eax
  8016a6:	7f 0b                	jg     8016b3 <vprintfmt+0x156>
  8016a8:	8b 14 85 00 28 80 00 	mov    0x802800(,%eax,4),%edx
  8016af:	85 d2                	test   %edx,%edx
  8016b1:	75 20                	jne    8016d3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8016b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016b7:	c7 44 24 08 c4 24 80 	movl   $0x8024c4,0x8(%esp)
  8016be:	00 
  8016bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016c3:	89 3c 24             	mov    %edi,(%esp)
  8016c6:	e8 a5 03 00 00       	call   801a70 <printfmt>
  8016cb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8016ce:	e9 b6 fe ff ff       	jmp    801589 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8016d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016d7:	c7 44 24 08 47 24 80 	movl   $0x802447,0x8(%esp)
  8016de:	00 
  8016df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016e3:	89 3c 24             	mov    %edi,(%esp)
  8016e6:	e8 85 03 00 00       	call   801a70 <printfmt>
  8016eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8016ee:	e9 96 fe ff ff       	jmp    801589 <vprintfmt+0x2c>
  8016f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8016fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016fe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801701:	8b 45 14             	mov    0x14(%ebp),%eax
  801704:	8d 50 04             	lea    0x4(%eax),%edx
  801707:	89 55 14             	mov    %edx,0x14(%ebp)
  80170a:	8b 00                	mov    (%eax),%eax
  80170c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170f:	85 c0                	test   %eax,%eax
  801711:	b8 cd 24 80 00       	mov    $0x8024cd,%eax
  801716:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80171a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80171d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801721:	7e 06                	jle    801729 <vprintfmt+0x1cc>
  801723:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  801727:	75 13                	jne    80173c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801729:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80172c:	0f be 02             	movsbl (%edx),%eax
  80172f:	85 c0                	test   %eax,%eax
  801731:	0f 85 a2 00 00 00    	jne    8017d9 <vprintfmt+0x27c>
  801737:	e9 8f 00 00 00       	jmp    8017cb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80173c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801740:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801743:	89 0c 24             	mov    %ecx,(%esp)
  801746:	e8 70 03 00 00       	call   801abb <strnlen>
  80174b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80174e:	29 c2                	sub    %eax,%edx
  801750:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801753:	85 d2                	test   %edx,%edx
  801755:	7e d2                	jle    801729 <vprintfmt+0x1cc>
					putch(padc, putdat);
  801757:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80175b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80175e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  801761:	89 d3                	mov    %edx,%ebx
  801763:	89 74 24 04          	mov    %esi,0x4(%esp)
  801767:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80176a:	89 04 24             	mov    %eax,(%esp)
  80176d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80176f:	83 eb 01             	sub    $0x1,%ebx
  801772:	85 db                	test   %ebx,%ebx
  801774:	7f ed                	jg     801763 <vprintfmt+0x206>
  801776:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  801779:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  801780:	eb a7                	jmp    801729 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801782:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801786:	74 1b                	je     8017a3 <vprintfmt+0x246>
  801788:	8d 50 e0             	lea    -0x20(%eax),%edx
  80178b:	83 fa 5e             	cmp    $0x5e,%edx
  80178e:	76 13                	jbe    8017a3 <vprintfmt+0x246>
					putch('?', putdat);
  801790:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801793:	89 54 24 04          	mov    %edx,0x4(%esp)
  801797:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80179e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8017a1:	eb 0d                	jmp    8017b0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8017a3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8017a6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017aa:	89 04 24             	mov    %eax,(%esp)
  8017ad:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017b0:	83 ef 01             	sub    $0x1,%edi
  8017b3:	0f be 03             	movsbl (%ebx),%eax
  8017b6:	85 c0                	test   %eax,%eax
  8017b8:	74 05                	je     8017bf <vprintfmt+0x262>
  8017ba:	83 c3 01             	add    $0x1,%ebx
  8017bd:	eb 31                	jmp    8017f0 <vprintfmt+0x293>
  8017bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017c5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8017c8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8017cb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8017cf:	7f 36                	jg     801807 <vprintfmt+0x2aa>
  8017d1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8017d4:	e9 b0 fd ff ff       	jmp    801589 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8017d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8017dc:	83 c2 01             	add    $0x1,%edx
  8017df:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8017e2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8017e5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8017e8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8017eb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8017ee:	89 d3                	mov    %edx,%ebx
  8017f0:	85 f6                	test   %esi,%esi
  8017f2:	78 8e                	js     801782 <vprintfmt+0x225>
  8017f4:	83 ee 01             	sub    $0x1,%esi
  8017f7:	79 89                	jns    801782 <vprintfmt+0x225>
  8017f9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8017fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801802:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  801805:	eb c4                	jmp    8017cb <vprintfmt+0x26e>
  801807:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80180a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80180d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801811:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801818:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80181a:	83 eb 01             	sub    $0x1,%ebx
  80181d:	85 db                	test   %ebx,%ebx
  80181f:	7f ec                	jg     80180d <vprintfmt+0x2b0>
  801821:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801824:	e9 60 fd ff ff       	jmp    801589 <vprintfmt+0x2c>
  801829:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80182c:	83 f9 01             	cmp    $0x1,%ecx
  80182f:	7e 16                	jle    801847 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  801831:	8b 45 14             	mov    0x14(%ebp),%eax
  801834:	8d 50 08             	lea    0x8(%eax),%edx
  801837:	89 55 14             	mov    %edx,0x14(%ebp)
  80183a:	8b 10                	mov    (%eax),%edx
  80183c:	8b 48 04             	mov    0x4(%eax),%ecx
  80183f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801842:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801845:	eb 32                	jmp    801879 <vprintfmt+0x31c>
	else if (lflag)
  801847:	85 c9                	test   %ecx,%ecx
  801849:	74 18                	je     801863 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80184b:	8b 45 14             	mov    0x14(%ebp),%eax
  80184e:	8d 50 04             	lea    0x4(%eax),%edx
  801851:	89 55 14             	mov    %edx,0x14(%ebp)
  801854:	8b 00                	mov    (%eax),%eax
  801856:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801859:	89 c1                	mov    %eax,%ecx
  80185b:	c1 f9 1f             	sar    $0x1f,%ecx
  80185e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801861:	eb 16                	jmp    801879 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  801863:	8b 45 14             	mov    0x14(%ebp),%eax
  801866:	8d 50 04             	lea    0x4(%eax),%edx
  801869:	89 55 14             	mov    %edx,0x14(%ebp)
  80186c:	8b 00                	mov    (%eax),%eax
  80186e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801871:	89 c2                	mov    %eax,%edx
  801873:	c1 fa 1f             	sar    $0x1f,%edx
  801876:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801879:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80187c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80187f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  801884:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801888:	0f 89 8a 00 00 00    	jns    801918 <vprintfmt+0x3bb>
				putch('-', putdat);
  80188e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801892:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801899:	ff d7                	call   *%edi
				num = -(long long) num;
  80189b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80189e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8018a1:	f7 d8                	neg    %eax
  8018a3:	83 d2 00             	adc    $0x0,%edx
  8018a6:	f7 da                	neg    %edx
  8018a8:	eb 6e                	jmp    801918 <vprintfmt+0x3bb>
  8018aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8018ad:	89 ca                	mov    %ecx,%edx
  8018af:	8d 45 14             	lea    0x14(%ebp),%eax
  8018b2:	e8 4f fc ff ff       	call   801506 <getuint>
  8018b7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8018bc:	eb 5a                	jmp    801918 <vprintfmt+0x3bb>
  8018be:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8018c1:	89 ca                	mov    %ecx,%edx
  8018c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8018c6:	e8 3b fc ff ff       	call   801506 <getuint>
  8018cb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8018d0:	eb 46                	jmp    801918 <vprintfmt+0x3bb>
  8018d2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8018d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8018e0:	ff d7                	call   *%edi
			putch('x', putdat);
  8018e2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8018ed:	ff d7                	call   *%edi
			num = (unsigned long long)
  8018ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f2:	8d 50 04             	lea    0x4(%eax),%edx
  8018f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8018f8:	8b 00                	mov    (%eax),%eax
  8018fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ff:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801904:	eb 12                	jmp    801918 <vprintfmt+0x3bb>
  801906:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801909:	89 ca                	mov    %ecx,%edx
  80190b:	8d 45 14             	lea    0x14(%ebp),%eax
  80190e:	e8 f3 fb ff ff       	call   801506 <getuint>
  801913:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801918:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80191c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801920:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801923:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801927:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192b:	89 04 24             	mov    %eax,(%esp)
  80192e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801932:	89 f2                	mov    %esi,%edx
  801934:	89 f8                	mov    %edi,%eax
  801936:	e8 d5 fa ff ff       	call   801410 <printnum>
  80193b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80193e:	e9 46 fc ff ff       	jmp    801589 <vprintfmt+0x2c>
  801943:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  801946:	8b 45 14             	mov    0x14(%ebp),%eax
  801949:	8d 50 04             	lea    0x4(%eax),%edx
  80194c:	89 55 14             	mov    %edx,0x14(%ebp)
  80194f:	8b 00                	mov    (%eax),%eax
  801951:	85 c0                	test   %eax,%eax
  801953:	75 24                	jne    801979 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  801955:	c7 44 24 0c e8 25 80 	movl   $0x8025e8,0xc(%esp)
  80195c:	00 
  80195d:	c7 44 24 08 47 24 80 	movl   $0x802447,0x8(%esp)
  801964:	00 
  801965:	89 74 24 04          	mov    %esi,0x4(%esp)
  801969:	89 3c 24             	mov    %edi,(%esp)
  80196c:	e8 ff 00 00 00       	call   801a70 <printfmt>
  801971:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801974:	e9 10 fc ff ff       	jmp    801589 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  801979:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80197c:	7e 29                	jle    8019a7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80197e:	0f b6 16             	movzbl (%esi),%edx
  801981:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  801983:	c7 44 24 0c 20 26 80 	movl   $0x802620,0xc(%esp)
  80198a:	00 
  80198b:	c7 44 24 08 47 24 80 	movl   $0x802447,0x8(%esp)
  801992:	00 
  801993:	89 74 24 04          	mov    %esi,0x4(%esp)
  801997:	89 3c 24             	mov    %edi,(%esp)
  80199a:	e8 d1 00 00 00       	call   801a70 <printfmt>
  80199f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8019a2:	e9 e2 fb ff ff       	jmp    801589 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8019a7:	0f b6 16             	movzbl (%esi),%edx
  8019aa:	88 10                	mov    %dl,(%eax)
  8019ac:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8019af:	e9 d5 fb ff ff       	jmp    801589 <vprintfmt+0x2c>
  8019b4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8019b7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019be:	89 14 24             	mov    %edx,(%esp)
  8019c1:	ff d7                	call   *%edi
  8019c3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8019c6:	e9 be fb ff ff       	jmp    801589 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8019cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019cf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8019d6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8019d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8019db:	80 38 25             	cmpb   $0x25,(%eax)
  8019de:	0f 84 a5 fb ff ff    	je     801589 <vprintfmt+0x2c>
  8019e4:	89 c3                	mov    %eax,%ebx
  8019e6:	eb f0                	jmp    8019d8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8019e8:	83 c4 5c             	add    $0x5c,%esp
  8019eb:	5b                   	pop    %ebx
  8019ec:	5e                   	pop    %esi
  8019ed:	5f                   	pop    %edi
  8019ee:	5d                   	pop    %ebp
  8019ef:	c3                   	ret    

008019f0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	83 ec 28             	sub    $0x28,%esp
  8019f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	74 04                	je     801a04 <vsnprintf+0x14>
  801a00:	85 d2                	test   %edx,%edx
  801a02:	7f 07                	jg     801a0b <vsnprintf+0x1b>
  801a04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a09:	eb 3b                	jmp    801a46 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a0e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801a15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a23:	8b 45 10             	mov    0x10(%ebp),%eax
  801a26:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a2a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a31:	c7 04 24 40 15 80 00 	movl   $0x801540,(%esp)
  801a38:	e8 20 fb ff ff       	call   80155d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a40:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801a46:	c9                   	leave  
  801a47:	c3                   	ret    

00801a48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  801a4e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  801a51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a55:	8b 45 10             	mov    0x10(%ebp),%eax
  801a58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a63:	8b 45 08             	mov    0x8(%ebp),%eax
  801a66:	89 04 24             	mov    %eax,(%esp)
  801a69:	e8 82 ff ff ff       	call   8019f0 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a6e:	c9                   	leave  
  801a6f:	c3                   	ret    

00801a70 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  801a76:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  801a79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	89 04 24             	mov    %eax,(%esp)
  801a91:	e8 c7 fa ff ff       	call   80155d <vprintfmt>
	va_end(ap);
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    
	...

00801aa0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801aa6:	b8 00 00 00 00       	mov    $0x0,%eax
  801aab:	80 3a 00             	cmpb   $0x0,(%edx)
  801aae:	74 09                	je     801ab9 <strlen+0x19>
		n++;
  801ab0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801ab3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ab7:	75 f7                	jne    801ab0 <strlen+0x10>
		n++;
	return n;
}
  801ab9:	5d                   	pop    %ebp
  801aba:	c3                   	ret    

00801abb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801ac2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ac5:	85 c9                	test   %ecx,%ecx
  801ac7:	74 19                	je     801ae2 <strnlen+0x27>
  801ac9:	80 3b 00             	cmpb   $0x0,(%ebx)
  801acc:	74 14                	je     801ae2 <strnlen+0x27>
  801ace:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801ad3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ad6:	39 c8                	cmp    %ecx,%eax
  801ad8:	74 0d                	je     801ae7 <strnlen+0x2c>
  801ada:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  801ade:	75 f3                	jne    801ad3 <strnlen+0x18>
  801ae0:	eb 05                	jmp    801ae7 <strnlen+0x2c>
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801ae7:	5b                   	pop    %ebx
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    

00801aea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801aea:	55                   	push   %ebp
  801aeb:	89 e5                	mov    %esp,%ebp
  801aed:	53                   	push   %ebx
  801aee:	8b 45 08             	mov    0x8(%ebp),%eax
  801af1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801af4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801af9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  801afd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801b00:	83 c2 01             	add    $0x1,%edx
  801b03:	84 c9                	test   %cl,%cl
  801b05:	75 f2                	jne    801af9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b07:	5b                   	pop    %ebx
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 08             	sub    $0x8,%esp
  801b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b14:	89 1c 24             	mov    %ebx,(%esp)
  801b17:	e8 84 ff ff ff       	call   801aa0 <strlen>
	strcpy(dst + len, src);
  801b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b23:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801b26:	89 04 24             	mov    %eax,(%esp)
  801b29:	e8 bc ff ff ff       	call   801aea <strcpy>
	return dst;
}
  801b2e:	89 d8                	mov    %ebx,%eax
  801b30:	83 c4 08             	add    $0x8,%esp
  801b33:	5b                   	pop    %ebx
  801b34:	5d                   	pop    %ebp
  801b35:	c3                   	ret    

00801b36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801b36:	55                   	push   %ebp
  801b37:	89 e5                	mov    %esp,%ebp
  801b39:	56                   	push   %esi
  801b3a:	53                   	push   %ebx
  801b3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b44:	85 f6                	test   %esi,%esi
  801b46:	74 18                	je     801b60 <strncpy+0x2a>
  801b48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  801b4d:	0f b6 1a             	movzbl (%edx),%ebx
  801b50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801b53:	80 3a 01             	cmpb   $0x1,(%edx)
  801b56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801b59:	83 c1 01             	add    $0x1,%ecx
  801b5c:	39 ce                	cmp    %ecx,%esi
  801b5e:	77 ed                	ja     801b4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5d                   	pop    %ebp
  801b63:	c3                   	ret    

00801b64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
  801b69:	8b 75 08             	mov    0x8(%ebp),%esi
  801b6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801b72:	89 f0                	mov    %esi,%eax
  801b74:	85 c9                	test   %ecx,%ecx
  801b76:	74 27                	je     801b9f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801b78:	83 e9 01             	sub    $0x1,%ecx
  801b7b:	74 1d                	je     801b9a <strlcpy+0x36>
  801b7d:	0f b6 1a             	movzbl (%edx),%ebx
  801b80:	84 db                	test   %bl,%bl
  801b82:	74 16                	je     801b9a <strlcpy+0x36>
			*dst++ = *src++;
  801b84:	88 18                	mov    %bl,(%eax)
  801b86:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b89:	83 e9 01             	sub    $0x1,%ecx
  801b8c:	74 0e                	je     801b9c <strlcpy+0x38>
			*dst++ = *src++;
  801b8e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801b91:	0f b6 1a             	movzbl (%edx),%ebx
  801b94:	84 db                	test   %bl,%bl
  801b96:	75 ec                	jne    801b84 <strlcpy+0x20>
  801b98:	eb 02                	jmp    801b9c <strlcpy+0x38>
  801b9a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  801b9c:	c6 00 00             	movb   $0x0,(%eax)
  801b9f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  801ba1:	5b                   	pop    %ebx
  801ba2:	5e                   	pop    %esi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801bae:	0f b6 01             	movzbl (%ecx),%eax
  801bb1:	84 c0                	test   %al,%al
  801bb3:	74 15                	je     801bca <strcmp+0x25>
  801bb5:	3a 02                	cmp    (%edx),%al
  801bb7:	75 11                	jne    801bca <strcmp+0x25>
		p++, q++;
  801bb9:	83 c1 01             	add    $0x1,%ecx
  801bbc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801bbf:	0f b6 01             	movzbl (%ecx),%eax
  801bc2:	84 c0                	test   %al,%al
  801bc4:	74 04                	je     801bca <strcmp+0x25>
  801bc6:	3a 02                	cmp    (%edx),%al
  801bc8:	74 ef                	je     801bb9 <strcmp+0x14>
  801bca:	0f b6 c0             	movzbl %al,%eax
  801bcd:	0f b6 12             	movzbl (%edx),%edx
  801bd0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	53                   	push   %ebx
  801bd8:	8b 55 08             	mov    0x8(%ebp),%edx
  801bdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bde:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801be1:	85 c0                	test   %eax,%eax
  801be3:	74 23                	je     801c08 <strncmp+0x34>
  801be5:	0f b6 1a             	movzbl (%edx),%ebx
  801be8:	84 db                	test   %bl,%bl
  801bea:	74 25                	je     801c11 <strncmp+0x3d>
  801bec:	3a 19                	cmp    (%ecx),%bl
  801bee:	75 21                	jne    801c11 <strncmp+0x3d>
  801bf0:	83 e8 01             	sub    $0x1,%eax
  801bf3:	74 13                	je     801c08 <strncmp+0x34>
		n--, p++, q++;
  801bf5:	83 c2 01             	add    $0x1,%edx
  801bf8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801bfb:	0f b6 1a             	movzbl (%edx),%ebx
  801bfe:	84 db                	test   %bl,%bl
  801c00:	74 0f                	je     801c11 <strncmp+0x3d>
  801c02:	3a 19                	cmp    (%ecx),%bl
  801c04:	74 ea                	je     801bf0 <strncmp+0x1c>
  801c06:	eb 09                	jmp    801c11 <strncmp+0x3d>
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801c0d:	5b                   	pop    %ebx
  801c0e:	5d                   	pop    %ebp
  801c0f:	90                   	nop
  801c10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c11:	0f b6 02             	movzbl (%edx),%eax
  801c14:	0f b6 11             	movzbl (%ecx),%edx
  801c17:	29 d0                	sub    %edx,%eax
  801c19:	eb f2                	jmp    801c0d <strncmp+0x39>

00801c1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c1b:	55                   	push   %ebp
  801c1c:	89 e5                	mov    %esp,%ebp
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c25:	0f b6 10             	movzbl (%eax),%edx
  801c28:	84 d2                	test   %dl,%dl
  801c2a:	74 18                	je     801c44 <strchr+0x29>
		if (*s == c)
  801c2c:	38 ca                	cmp    %cl,%dl
  801c2e:	75 0a                	jne    801c3a <strchr+0x1f>
  801c30:	eb 17                	jmp    801c49 <strchr+0x2e>
  801c32:	38 ca                	cmp    %cl,%dl
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	74 0f                	je     801c49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801c3a:	83 c0 01             	add    $0x1,%eax
  801c3d:	0f b6 10             	movzbl (%eax),%edx
  801c40:	84 d2                	test   %dl,%dl
  801c42:	75 ee                	jne    801c32 <strchr+0x17>
  801c44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c55:	0f b6 10             	movzbl (%eax),%edx
  801c58:	84 d2                	test   %dl,%dl
  801c5a:	74 18                	je     801c74 <strfind+0x29>
		if (*s == c)
  801c5c:	38 ca                	cmp    %cl,%dl
  801c5e:	75 0a                	jne    801c6a <strfind+0x1f>
  801c60:	eb 12                	jmp    801c74 <strfind+0x29>
  801c62:	38 ca                	cmp    %cl,%dl
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	74 0a                	je     801c74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801c6a:	83 c0 01             	add    $0x1,%eax
  801c6d:	0f b6 10             	movzbl (%eax),%edx
  801c70:	84 d2                	test   %dl,%dl
  801c72:	75 ee                	jne    801c62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801c74:	5d                   	pop    %ebp
  801c75:	c3                   	ret    

00801c76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 0c             	sub    $0xc,%esp
  801c7c:	89 1c 24             	mov    %ebx,(%esp)
  801c7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801c87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801c90:	85 c9                	test   %ecx,%ecx
  801c92:	74 30                	je     801cc4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801c94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801c9a:	75 25                	jne    801cc1 <memset+0x4b>
  801c9c:	f6 c1 03             	test   $0x3,%cl
  801c9f:	75 20                	jne    801cc1 <memset+0x4b>
		c &= 0xFF;
  801ca1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ca4:	89 d3                	mov    %edx,%ebx
  801ca6:	c1 e3 08             	shl    $0x8,%ebx
  801ca9:	89 d6                	mov    %edx,%esi
  801cab:	c1 e6 18             	shl    $0x18,%esi
  801cae:	89 d0                	mov    %edx,%eax
  801cb0:	c1 e0 10             	shl    $0x10,%eax
  801cb3:	09 f0                	or     %esi,%eax
  801cb5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801cb7:	09 d8                	or     %ebx,%eax
  801cb9:	c1 e9 02             	shr    $0x2,%ecx
  801cbc:	fc                   	cld    
  801cbd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cbf:	eb 03                	jmp    801cc4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cc1:	fc                   	cld    
  801cc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cc4:	89 f8                	mov    %edi,%eax
  801cc6:	8b 1c 24             	mov    (%esp),%ebx
  801cc9:	8b 74 24 04          	mov    0x4(%esp),%esi
  801ccd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801cd1:	89 ec                	mov    %ebp,%esp
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    

00801cd5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 08             	sub    $0x8,%esp
  801cdb:	89 34 24             	mov    %esi,(%esp)
  801cde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801ce8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  801ceb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  801ced:	39 c6                	cmp    %eax,%esi
  801cef:	73 35                	jae    801d26 <memmove+0x51>
  801cf1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801cf4:	39 d0                	cmp    %edx,%eax
  801cf6:	73 2e                	jae    801d26 <memmove+0x51>
		s += n;
		d += n;
  801cf8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801cfa:	f6 c2 03             	test   $0x3,%dl
  801cfd:	75 1b                	jne    801d1a <memmove+0x45>
  801cff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d05:	75 13                	jne    801d1a <memmove+0x45>
  801d07:	f6 c1 03             	test   $0x3,%cl
  801d0a:	75 0e                	jne    801d1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  801d0c:	83 ef 04             	sub    $0x4,%edi
  801d0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d12:	c1 e9 02             	shr    $0x2,%ecx
  801d15:	fd                   	std    
  801d16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d18:	eb 09                	jmp    801d23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d1a:	83 ef 01             	sub    $0x1,%edi
  801d1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d20:	fd                   	std    
  801d21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d23:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d24:	eb 20                	jmp    801d46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d2c:	75 15                	jne    801d43 <memmove+0x6e>
  801d2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d34:	75 0d                	jne    801d43 <memmove+0x6e>
  801d36:	f6 c1 03             	test   $0x3,%cl
  801d39:	75 08                	jne    801d43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  801d3b:	c1 e9 02             	shr    $0x2,%ecx
  801d3e:	fc                   	cld    
  801d3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d41:	eb 03                	jmp    801d46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801d43:	fc                   	cld    
  801d44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d46:	8b 34 24             	mov    (%esp),%esi
  801d49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801d4d:	89 ec                	mov    %ebp,%esp
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    

00801d51 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d57:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d61:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	89 04 24             	mov    %eax,(%esp)
  801d6b:	e8 65 ff ff ff       	call   801cd5 <memmove>
}
  801d70:	c9                   	leave  
  801d71:	c3                   	ret    

00801d72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d72:	55                   	push   %ebp
  801d73:	89 e5                	mov    %esp,%ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	8b 75 08             	mov    0x8(%ebp),%esi
  801d7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801d7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d81:	85 c9                	test   %ecx,%ecx
  801d83:	74 36                	je     801dbb <memcmp+0x49>
		if (*s1 != *s2)
  801d85:	0f b6 06             	movzbl (%esi),%eax
  801d88:	0f b6 1f             	movzbl (%edi),%ebx
  801d8b:	38 d8                	cmp    %bl,%al
  801d8d:	74 20                	je     801daf <memcmp+0x3d>
  801d8f:	eb 14                	jmp    801da5 <memcmp+0x33>
  801d91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801d96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  801d9b:	83 c2 01             	add    $0x1,%edx
  801d9e:	83 e9 01             	sub    $0x1,%ecx
  801da1:	38 d8                	cmp    %bl,%al
  801da3:	74 12                	je     801db7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801da5:	0f b6 c0             	movzbl %al,%eax
  801da8:	0f b6 db             	movzbl %bl,%ebx
  801dab:	29 d8                	sub    %ebx,%eax
  801dad:	eb 11                	jmp    801dc0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801daf:	83 e9 01             	sub    $0x1,%ecx
  801db2:	ba 00 00 00 00       	mov    $0x0,%edx
  801db7:	85 c9                	test   %ecx,%ecx
  801db9:	75 d6                	jne    801d91 <memcmp+0x1f>
  801dbb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801dc0:	5b                   	pop    %ebx
  801dc1:	5e                   	pop    %esi
  801dc2:	5f                   	pop    %edi
  801dc3:	5d                   	pop    %ebp
  801dc4:	c3                   	ret    

00801dc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801dcb:	89 c2                	mov    %eax,%edx
  801dcd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dd0:	39 d0                	cmp    %edx,%eax
  801dd2:	73 15                	jae    801de9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801dd8:	38 08                	cmp    %cl,(%eax)
  801dda:	75 06                	jne    801de2 <memfind+0x1d>
  801ddc:	eb 0b                	jmp    801de9 <memfind+0x24>
  801dde:	38 08                	cmp    %cl,(%eax)
  801de0:	74 07                	je     801de9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801de2:	83 c0 01             	add    $0x1,%eax
  801de5:	39 c2                	cmp    %eax,%edx
  801de7:	77 f5                	ja     801dde <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    

00801deb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	83 ec 04             	sub    $0x4,%esp
  801df4:	8b 55 08             	mov    0x8(%ebp),%edx
  801df7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dfa:	0f b6 02             	movzbl (%edx),%eax
  801dfd:	3c 20                	cmp    $0x20,%al
  801dff:	74 04                	je     801e05 <strtol+0x1a>
  801e01:	3c 09                	cmp    $0x9,%al
  801e03:	75 0e                	jne    801e13 <strtol+0x28>
		s++;
  801e05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e08:	0f b6 02             	movzbl (%edx),%eax
  801e0b:	3c 20                	cmp    $0x20,%al
  801e0d:	74 f6                	je     801e05 <strtol+0x1a>
  801e0f:	3c 09                	cmp    $0x9,%al
  801e11:	74 f2                	je     801e05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e13:	3c 2b                	cmp    $0x2b,%al
  801e15:	75 0c                	jne    801e23 <strtol+0x38>
		s++;
  801e17:	83 c2 01             	add    $0x1,%edx
  801e1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801e21:	eb 15                	jmp    801e38 <strtol+0x4d>
	else if (*s == '-')
  801e23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801e2a:	3c 2d                	cmp    $0x2d,%al
  801e2c:	75 0a                	jne    801e38 <strtol+0x4d>
		s++, neg = 1;
  801e2e:	83 c2 01             	add    $0x1,%edx
  801e31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e38:	85 db                	test   %ebx,%ebx
  801e3a:	0f 94 c0             	sete   %al
  801e3d:	74 05                	je     801e44 <strtol+0x59>
  801e3f:	83 fb 10             	cmp    $0x10,%ebx
  801e42:	75 18                	jne    801e5c <strtol+0x71>
  801e44:	80 3a 30             	cmpb   $0x30,(%edx)
  801e47:	75 13                	jne    801e5c <strtol+0x71>
  801e49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e4d:	8d 76 00             	lea    0x0(%esi),%esi
  801e50:	75 0a                	jne    801e5c <strtol+0x71>
		s += 2, base = 16;
  801e52:	83 c2 02             	add    $0x2,%edx
  801e55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e5a:	eb 15                	jmp    801e71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e5c:	84 c0                	test   %al,%al
  801e5e:	66 90                	xchg   %ax,%ax
  801e60:	74 0f                	je     801e71 <strtol+0x86>
  801e62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801e67:	80 3a 30             	cmpb   $0x30,(%edx)
  801e6a:	75 05                	jne    801e71 <strtol+0x86>
		s++, base = 8;
  801e6c:	83 c2 01             	add    $0x1,%edx
  801e6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
  801e76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e78:	0f b6 0a             	movzbl (%edx),%ecx
  801e7b:	89 cf                	mov    %ecx,%edi
  801e7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801e80:	80 fb 09             	cmp    $0x9,%bl
  801e83:	77 08                	ja     801e8d <strtol+0xa2>
			dig = *s - '0';
  801e85:	0f be c9             	movsbl %cl,%ecx
  801e88:	83 e9 30             	sub    $0x30,%ecx
  801e8b:	eb 1e                	jmp    801eab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  801e8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801e90:	80 fb 19             	cmp    $0x19,%bl
  801e93:	77 08                	ja     801e9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801e95:	0f be c9             	movsbl %cl,%ecx
  801e98:	83 e9 57             	sub    $0x57,%ecx
  801e9b:	eb 0e                	jmp    801eab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  801e9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801ea0:	80 fb 19             	cmp    $0x19,%bl
  801ea3:	77 15                	ja     801eba <strtol+0xcf>
			dig = *s - 'A' + 10;
  801ea5:	0f be c9             	movsbl %cl,%ecx
  801ea8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801eab:	39 f1                	cmp    %esi,%ecx
  801ead:	7d 0b                	jge    801eba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  801eaf:	83 c2 01             	add    $0x1,%edx
  801eb2:	0f af c6             	imul   %esi,%eax
  801eb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801eb8:	eb be                	jmp    801e78 <strtol+0x8d>
  801eba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  801ebc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ec0:	74 05                	je     801ec7 <strtol+0xdc>
		*endptr = (char *) s;
  801ec2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801ec5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801ec7:	89 ca                	mov    %ecx,%edx
  801ec9:	f7 da                	neg    %edx
  801ecb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  801ecf:	0f 45 c2             	cmovne %edx,%eax
}
  801ed2:	83 c4 04             	add    $0x4,%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5f                   	pop    %edi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    
	...

00801edc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801ee2:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801ee9:	75 54                	jne    801f3f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801eeb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801ef2:	00 
  801ef3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801efa:	ee 
  801efb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f02:	e8 32 e4 ff ff       	call   800339 <sys_page_alloc>
  801f07:	85 c0                	test   %eax,%eax
  801f09:	79 20                	jns    801f2b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  801f0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0f:	c7 44 24 08 40 28 80 	movl   $0x802840,0x8(%esp)
  801f16:	00 
  801f17:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801f1e:	00 
  801f1f:	c7 04 24 58 28 80 00 	movl   $0x802858,(%esp)
  801f26:	e8 c9 f3 ff ff       	call   8012f4 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  801f2b:	c7 44 24 04 cc 04 80 	movl   $0x8004cc,0x4(%esp)
  801f32:	00 
  801f33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f3a:	e8 e1 e2 ff ff       	call   800220 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f42:	a3 00 70 80 00       	mov    %eax,0x807000
}
  801f47:	c9                   	leave  
  801f48:	c3                   	ret    
  801f49:	00 00                	add    %al,(%eax)
  801f4b:	00 00                	add    %al,(%eax)
  801f4d:	00 00                	add    %al,(%eax)
	...

00801f50 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f56:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f61:	39 ca                	cmp    %ecx,%edx
  801f63:	75 04                	jne    801f69 <ipc_find_env+0x19>
  801f65:	b0 00                	mov    $0x0,%al
  801f67:	eb 11                	jmp    801f7a <ipc_find_env+0x2a>
  801f69:	89 c2                	mov    %eax,%edx
  801f6b:	c1 e2 07             	shl    $0x7,%edx
  801f6e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801f74:	8b 12                	mov    (%edx),%edx
  801f76:	39 ca                	cmp    %ecx,%edx
  801f78:	75 0f                	jne    801f89 <ipc_find_env+0x39>
			return envs[i].env_id;
  801f7a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801f7e:	c1 e0 06             	shl    $0x6,%eax
  801f81:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801f87:	eb 0e                	jmp    801f97 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f89:	83 c0 01             	add    $0x1,%eax
  801f8c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f91:	75 d6                	jne    801f69 <ipc_find_env+0x19>
  801f93:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f97:	5d                   	pop    %ebp
  801f98:	c3                   	ret    

00801f99 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f99:	55                   	push   %ebp
  801f9a:	89 e5                	mov    %esp,%ebp
  801f9c:	57                   	push   %edi
  801f9d:	56                   	push   %esi
  801f9e:	53                   	push   %ebx
  801f9f:	83 ec 1c             	sub    $0x1c,%esp
  801fa2:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fa8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801fab:	85 db                	test   %ebx,%ebx
  801fad:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fb2:	0f 44 d8             	cmove  %eax,%ebx
  801fb5:	eb 25                	jmp    801fdc <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801fb7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fba:	74 20                	je     801fdc <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801fbc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fc0:	c7 44 24 08 66 28 80 	movl   $0x802866,0x8(%esp)
  801fc7:	00 
  801fc8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801fcf:	00 
  801fd0:	c7 04 24 84 28 80 00 	movl   $0x802884,(%esp)
  801fd7:	e8 18 f3 ff ff       	call   8012f4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801fdc:	8b 45 14             	mov    0x14(%ebp),%eax
  801fdf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fe3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fe7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801feb:	89 34 24             	mov    %esi,(%esp)
  801fee:	e8 f7 e1 ff ff       	call   8001ea <sys_ipc_try_send>
  801ff3:	85 c0                	test   %eax,%eax
  801ff5:	75 c0                	jne    801fb7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801ff7:	e8 74 e3 ff ff       	call   800370 <sys_yield>
}
  801ffc:	83 c4 1c             	add    $0x1c,%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	83 ec 28             	sub    $0x28,%esp
  80200a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80200d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802010:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802013:	8b 75 08             	mov    0x8(%ebp),%esi
  802016:	8b 45 0c             	mov    0xc(%ebp),%eax
  802019:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80201c:	85 c0                	test   %eax,%eax
  80201e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802023:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802026:	89 04 24             	mov    %eax,(%esp)
  802029:	e8 83 e1 ff ff       	call   8001b1 <sys_ipc_recv>
  80202e:	89 c3                	mov    %eax,%ebx
  802030:	85 c0                	test   %eax,%eax
  802032:	79 2a                	jns    80205e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802034:	89 44 24 08          	mov    %eax,0x8(%esp)
  802038:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203c:	c7 04 24 8e 28 80 00 	movl   $0x80288e,(%esp)
  802043:	e8 65 f3 ff ff       	call   8013ad <cprintf>
		if(from_env_store != NULL)
  802048:	85 f6                	test   %esi,%esi
  80204a:	74 06                	je     802052 <ipc_recv+0x4e>
			*from_env_store = 0;
  80204c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802052:	85 ff                	test   %edi,%edi
  802054:	74 2c                	je     802082 <ipc_recv+0x7e>
			*perm_store = 0;
  802056:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80205c:	eb 24                	jmp    802082 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80205e:	85 f6                	test   %esi,%esi
  802060:	74 0a                	je     80206c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  802062:	a1 08 40 80 00       	mov    0x804008,%eax
  802067:	8b 40 74             	mov    0x74(%eax),%eax
  80206a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80206c:	85 ff                	test   %edi,%edi
  80206e:	74 0a                	je     80207a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802070:	a1 08 40 80 00       	mov    0x804008,%eax
  802075:	8b 40 78             	mov    0x78(%eax),%eax
  802078:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80207a:	a1 08 40 80 00       	mov    0x804008,%eax
  80207f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802082:	89 d8                	mov    %ebx,%eax
  802084:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802087:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80208a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80208d:	89 ec                	mov    %ebp,%esp
  80208f:	5d                   	pop    %ebp
  802090:	c3                   	ret    
  802091:	00 00                	add    %al,(%eax)
	...

00802094 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802097:	8b 45 08             	mov    0x8(%ebp),%eax
  80209a:	89 c2                	mov    %eax,%edx
  80209c:	c1 ea 16             	shr    $0x16,%edx
  80209f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020a6:	f6 c2 01             	test   $0x1,%dl
  8020a9:	74 20                	je     8020cb <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8020ab:	c1 e8 0c             	shr    $0xc,%eax
  8020ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020b5:	a8 01                	test   $0x1,%al
  8020b7:	74 12                	je     8020cb <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020b9:	c1 e8 0c             	shr    $0xc,%eax
  8020bc:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8020c1:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8020c6:	0f b7 c0             	movzwl %ax,%eax
  8020c9:	eb 05                	jmp    8020d0 <pageref+0x3c>
  8020cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
	...

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	57                   	push   %edi
  8020e4:	56                   	push   %esi
  8020e5:	83 ec 10             	sub    $0x10,%esp
  8020e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8020ee:	8b 75 10             	mov    0x10(%ebp),%esi
  8020f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020f4:	85 c0                	test   %eax,%eax
  8020f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8020f9:	75 35                	jne    802130 <__udivdi3+0x50>
  8020fb:	39 fe                	cmp    %edi,%esi
  8020fd:	77 61                	ja     802160 <__udivdi3+0x80>
  8020ff:	85 f6                	test   %esi,%esi
  802101:	75 0b                	jne    80210e <__udivdi3+0x2e>
  802103:	b8 01 00 00 00       	mov    $0x1,%eax
  802108:	31 d2                	xor    %edx,%edx
  80210a:	f7 f6                	div    %esi
  80210c:	89 c6                	mov    %eax,%esi
  80210e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802111:	31 d2                	xor    %edx,%edx
  802113:	89 f8                	mov    %edi,%eax
  802115:	f7 f6                	div    %esi
  802117:	89 c7                	mov    %eax,%edi
  802119:	89 c8                	mov    %ecx,%eax
  80211b:	f7 f6                	div    %esi
  80211d:	89 c1                	mov    %eax,%ecx
  80211f:	89 fa                	mov    %edi,%edx
  802121:	89 c8                	mov    %ecx,%eax
  802123:	83 c4 10             	add    $0x10,%esp
  802126:	5e                   	pop    %esi
  802127:	5f                   	pop    %edi
  802128:	5d                   	pop    %ebp
  802129:	c3                   	ret    
  80212a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802130:	39 f8                	cmp    %edi,%eax
  802132:	77 1c                	ja     802150 <__udivdi3+0x70>
  802134:	0f bd d0             	bsr    %eax,%edx
  802137:	83 f2 1f             	xor    $0x1f,%edx
  80213a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80213d:	75 39                	jne    802178 <__udivdi3+0x98>
  80213f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802142:	0f 86 a0 00 00 00    	jbe    8021e8 <__udivdi3+0x108>
  802148:	39 f8                	cmp    %edi,%eax
  80214a:	0f 82 98 00 00 00    	jb     8021e8 <__udivdi3+0x108>
  802150:	31 ff                	xor    %edi,%edi
  802152:	31 c9                	xor    %ecx,%ecx
  802154:	89 c8                	mov    %ecx,%eax
  802156:	89 fa                	mov    %edi,%edx
  802158:	83 c4 10             	add    $0x10,%esp
  80215b:	5e                   	pop    %esi
  80215c:	5f                   	pop    %edi
  80215d:	5d                   	pop    %ebp
  80215e:	c3                   	ret    
  80215f:	90                   	nop
  802160:	89 d1                	mov    %edx,%ecx
  802162:	89 fa                	mov    %edi,%edx
  802164:	89 c8                	mov    %ecx,%eax
  802166:	31 ff                	xor    %edi,%edi
  802168:	f7 f6                	div    %esi
  80216a:	89 c1                	mov    %eax,%ecx
  80216c:	89 fa                	mov    %edi,%edx
  80216e:	89 c8                	mov    %ecx,%eax
  802170:	83 c4 10             	add    $0x10,%esp
  802173:	5e                   	pop    %esi
  802174:	5f                   	pop    %edi
  802175:	5d                   	pop    %ebp
  802176:	c3                   	ret    
  802177:	90                   	nop
  802178:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80217c:	89 f2                	mov    %esi,%edx
  80217e:	d3 e0                	shl    %cl,%eax
  802180:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802183:	b8 20 00 00 00       	mov    $0x20,%eax
  802188:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80218b:	89 c1                	mov    %eax,%ecx
  80218d:	d3 ea                	shr    %cl,%edx
  80218f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802193:	0b 55 ec             	or     -0x14(%ebp),%edx
  802196:	d3 e6                	shl    %cl,%esi
  802198:	89 c1                	mov    %eax,%ecx
  80219a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80219d:	89 fe                	mov    %edi,%esi
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021ab:	d3 e7                	shl    %cl,%edi
  8021ad:	89 c1                	mov    %eax,%ecx
  8021af:	d3 ea                	shr    %cl,%edx
  8021b1:	09 d7                	or     %edx,%edi
  8021b3:	89 f2                	mov    %esi,%edx
  8021b5:	89 f8                	mov    %edi,%eax
  8021b7:	f7 75 ec             	divl   -0x14(%ebp)
  8021ba:	89 d6                	mov    %edx,%esi
  8021bc:	89 c7                	mov    %eax,%edi
  8021be:	f7 65 e8             	mull   -0x18(%ebp)
  8021c1:	39 d6                	cmp    %edx,%esi
  8021c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021c6:	72 30                	jb     8021f8 <__udivdi3+0x118>
  8021c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021cf:	d3 e2                	shl    %cl,%edx
  8021d1:	39 c2                	cmp    %eax,%edx
  8021d3:	73 05                	jae    8021da <__udivdi3+0xfa>
  8021d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8021d8:	74 1e                	je     8021f8 <__udivdi3+0x118>
  8021da:	89 f9                	mov    %edi,%ecx
  8021dc:	31 ff                	xor    %edi,%edi
  8021de:	e9 71 ff ff ff       	jmp    802154 <__udivdi3+0x74>
  8021e3:	90                   	nop
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8021ef:	e9 60 ff ff ff       	jmp    802154 <__udivdi3+0x74>
  8021f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8021fb:	31 ff                	xor    %edi,%edi
  8021fd:	89 c8                	mov    %ecx,%eax
  8021ff:	89 fa                	mov    %edi,%edx
  802201:	83 c4 10             	add    $0x10,%esp
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
	...

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	57                   	push   %edi
  802214:	56                   	push   %esi
  802215:	83 ec 20             	sub    $0x20,%esp
  802218:	8b 55 14             	mov    0x14(%ebp),%edx
  80221b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80221e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802221:	8b 75 0c             	mov    0xc(%ebp),%esi
  802224:	85 d2                	test   %edx,%edx
  802226:	89 c8                	mov    %ecx,%eax
  802228:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80222b:	75 13                	jne    802240 <__umoddi3+0x30>
  80222d:	39 f7                	cmp    %esi,%edi
  80222f:	76 3f                	jbe    802270 <__umoddi3+0x60>
  802231:	89 f2                	mov    %esi,%edx
  802233:	f7 f7                	div    %edi
  802235:	89 d0                	mov    %edx,%eax
  802237:	31 d2                	xor    %edx,%edx
  802239:	83 c4 20             	add    $0x20,%esp
  80223c:	5e                   	pop    %esi
  80223d:	5f                   	pop    %edi
  80223e:	5d                   	pop    %ebp
  80223f:	c3                   	ret    
  802240:	39 f2                	cmp    %esi,%edx
  802242:	77 4c                	ja     802290 <__umoddi3+0x80>
  802244:	0f bd ca             	bsr    %edx,%ecx
  802247:	83 f1 1f             	xor    $0x1f,%ecx
  80224a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80224d:	75 51                	jne    8022a0 <__umoddi3+0x90>
  80224f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802252:	0f 87 e0 00 00 00    	ja     802338 <__umoddi3+0x128>
  802258:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80225b:	29 f8                	sub    %edi,%eax
  80225d:	19 d6                	sbb    %edx,%esi
  80225f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802262:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802265:	89 f2                	mov    %esi,%edx
  802267:	83 c4 20             	add    $0x20,%esp
  80226a:	5e                   	pop    %esi
  80226b:	5f                   	pop    %edi
  80226c:	5d                   	pop    %ebp
  80226d:	c3                   	ret    
  80226e:	66 90                	xchg   %ax,%ax
  802270:	85 ff                	test   %edi,%edi
  802272:	75 0b                	jne    80227f <__umoddi3+0x6f>
  802274:	b8 01 00 00 00       	mov    $0x1,%eax
  802279:	31 d2                	xor    %edx,%edx
  80227b:	f7 f7                	div    %edi
  80227d:	89 c7                	mov    %eax,%edi
  80227f:	89 f0                	mov    %esi,%eax
  802281:	31 d2                	xor    %edx,%edx
  802283:	f7 f7                	div    %edi
  802285:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802288:	f7 f7                	div    %edi
  80228a:	eb a9                	jmp    802235 <__umoddi3+0x25>
  80228c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 c8                	mov    %ecx,%eax
  802292:	89 f2                	mov    %esi,%edx
  802294:	83 c4 20             	add    $0x20,%esp
  802297:	5e                   	pop    %esi
  802298:	5f                   	pop    %edi
  802299:	5d                   	pop    %ebp
  80229a:	c3                   	ret    
  80229b:	90                   	nop
  80229c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022a4:	d3 e2                	shl    %cl,%edx
  8022a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8022ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8022b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8022b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022b8:	89 fa                	mov    %edi,%edx
  8022ba:	d3 ea                	shr    %cl,%edx
  8022bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8022c3:	d3 e7                	shl    %cl,%edi
  8022c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022cc:	89 f2                	mov    %esi,%edx
  8022ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8022d1:	89 c7                	mov    %eax,%edi
  8022d3:	d3 ea                	shr    %cl,%edx
  8022d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8022dc:	89 c2                	mov    %eax,%edx
  8022de:	d3 e6                	shl    %cl,%esi
  8022e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022e4:	d3 ea                	shr    %cl,%edx
  8022e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022ea:	09 d6                	or     %edx,%esi
  8022ec:	89 f0                	mov    %esi,%eax
  8022ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8022f1:	d3 e7                	shl    %cl,%edi
  8022f3:	89 f2                	mov    %esi,%edx
  8022f5:	f7 75 f4             	divl   -0xc(%ebp)
  8022f8:	89 d6                	mov    %edx,%esi
  8022fa:	f7 65 e8             	mull   -0x18(%ebp)
  8022fd:	39 d6                	cmp    %edx,%esi
  8022ff:	72 2b                	jb     80232c <__umoddi3+0x11c>
  802301:	39 c7                	cmp    %eax,%edi
  802303:	72 23                	jb     802328 <__umoddi3+0x118>
  802305:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802309:	29 c7                	sub    %eax,%edi
  80230b:	19 d6                	sbb    %edx,%esi
  80230d:	89 f0                	mov    %esi,%eax
  80230f:	89 f2                	mov    %esi,%edx
  802311:	d3 ef                	shr    %cl,%edi
  802313:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802317:	d3 e0                	shl    %cl,%eax
  802319:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80231d:	09 f8                	or     %edi,%eax
  80231f:	d3 ea                	shr    %cl,%edx
  802321:	83 c4 20             	add    $0x20,%esp
  802324:	5e                   	pop    %esi
  802325:	5f                   	pop    %edi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    
  802328:	39 d6                	cmp    %edx,%esi
  80232a:	75 d9                	jne    802305 <__umoddi3+0xf5>
  80232c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80232f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802332:	eb d1                	jmp    802305 <__umoddi3+0xf5>
  802334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802338:	39 f2                	cmp    %esi,%edx
  80233a:	0f 82 18 ff ff ff    	jb     802258 <__umoddi3+0x48>
  802340:	e9 1d ff ff ff       	jmp    802262 <__umoddi3+0x52>
