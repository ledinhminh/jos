
obj/user/idle.debug:     file format elf32-i386


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
  80002c:	e8 1b 00 00 00       	call   80004c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  80003a:	c7 05 00 30 80 00 00 	movl   $0x801d00,0x803000
  800041:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800044:	e8 a4 02 00 00       	call   8002ed <sys_yield>
  800049:	eb f9                	jmp    800044 <umain+0x10>
	...

0080004c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004c:	55                   	push   %ebp
  80004d:	89 e5                	mov    %esp,%ebp
  80004f:	83 ec 18             	sub    $0x18,%esp
  800052:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800055:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800058:	8b 75 08             	mov    0x8(%ebp),%esi
  80005b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80005e:	e8 fd 02 00 00       	call   800360 <sys_getenvid>
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 f6                	test   %esi,%esi
  800077:	7e 07                	jle    800080 <libmain+0x34>
		binaryname = argv[0];
  800079:	8b 03                	mov    (%ebx),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800080:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800084:	89 34 24             	mov    %esi,(%esp)
  800087:	e8 a8 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80008c:	e8 0b 00 00 00       	call   80009c <exit>
}
  800091:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800094:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800097:	89 ec                	mov    %ebp,%esp
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
	...

0080009c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009c:	55                   	push   %ebp
  80009d:	89 e5                	mov    %esp,%ebp
  80009f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000a2:	e8 92 08 00 00       	call   800939 <close_all>
	sys_env_destroy(0);
  8000a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ae:	e8 e8 02 00 00       	call   80039b <sys_env_destroy>
}
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    
  8000b5:	00 00                	add    %al,(%eax)
	...

008000b8 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 48             	sub    $0x48,%esp
  8000be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8000c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8000c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8000c7:	89 c6                	mov    %eax,%esi
  8000c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000cc:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8000ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d7:	51                   	push   %ecx
  8000d8:	52                   	push   %edx
  8000d9:	53                   	push   %ebx
  8000da:	54                   	push   %esp
  8000db:	55                   	push   %ebp
  8000dc:	56                   	push   %esi
  8000dd:	57                   	push   %edi
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	8d 35 e8 00 80 00    	lea    0x8000e8,%esi
  8000e6:	0f 34                	sysenter 

008000e8 <.after_sysenter_label>:
  8000e8:	5f                   	pop    %edi
  8000e9:	5e                   	pop    %esi
  8000ea:	5d                   	pop    %ebp
  8000eb:	5c                   	pop    %esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5a                   	pop    %edx
  8000ee:	59                   	pop    %ecx
  8000ef:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  8000f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000f5:	74 28                	je     80011f <.after_sysenter_label+0x37>
  8000f7:	85 c0                	test   %eax,%eax
  8000f9:	7e 24                	jle    80011f <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800103:	c7 44 24 08 0f 1d 80 	movl   $0x801d0f,0x8(%esp)
  80010a:	00 
  80010b:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800112:	00 
  800113:	c7 04 24 2c 1d 80 00 	movl   $0x801d2c,(%esp)
  80011a:	e8 21 0c 00 00       	call   800d40 <_panic>

	return ret;
}
  80011f:	89 d0                	mov    %edx,%eax
  800121:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800124:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800127:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80012a:	89 ec                	mov    %ebp,%esp
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800134:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80013b:	00 
  80013c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800143:	00 
  800144:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80014b:	00 
  80014c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800156:	ba 01 00 00 00       	mov    $0x1,%edx
  80015b:	b8 0e 00 00 00       	mov    $0xe,%eax
  800160:	e8 53 ff ff ff       	call   8000b8 <syscall>
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  80016d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800174:	00 
  800175:	8b 45 14             	mov    0x14(%ebp),%eax
  800178:	89 44 24 08          	mov    %eax,0x8(%esp)
  80017c:	8b 45 10             	mov    0x10(%ebp),%eax
  80017f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800183:	8b 45 0c             	mov    0xc(%ebp),%eax
  800186:	89 04 24             	mov    %eax,(%esp)
  800189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018c:	ba 00 00 00 00       	mov    $0x0,%edx
  800191:	b8 0d 00 00 00       	mov    $0xd,%eax
  800196:	e8 1d ff ff ff       	call   8000b8 <syscall>
}
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8001a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001aa:	00 
  8001ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001b2:	00 
  8001b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ba:	00 
  8001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001be:	89 04 24             	mov    %eax,(%esp)
  8001c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001c4:	ba 01 00 00 00       	mov    $0x1,%edx
  8001c9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001ce:	e8 e5 fe ff ff       	call   8000b8 <syscall>
}
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8001db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001e2:	00 
  8001e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001ea:	00 
  8001eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001f2:	00 
  8001f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f6:	89 04 24             	mov    %eax,(%esp)
  8001f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fc:	ba 01 00 00 00       	mov    $0x1,%edx
  800201:	b8 0a 00 00 00       	mov    $0xa,%eax
  800206:	e8 ad fe ff ff       	call   8000b8 <syscall>
}
  80020b:	c9                   	leave  
  80020c:	c3                   	ret    

0080020d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80020d:	55                   	push   %ebp
  80020e:	89 e5                	mov    %esp,%ebp
  800210:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800213:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80021a:	00 
  80021b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800222:	00 
  800223:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80022a:	00 
  80022b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022e:	89 04 24             	mov    %eax,(%esp)
  800231:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800234:	ba 01 00 00 00       	mov    $0x1,%edx
  800239:	b8 09 00 00 00       	mov    $0x9,%eax
  80023e:	e8 75 fe ff ff       	call   8000b8 <syscall>
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80024b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800252:	00 
  800253:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80025a:	00 
  80025b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800262:	00 
  800263:	8b 45 0c             	mov    0xc(%ebp),%eax
  800266:	89 04 24             	mov    %eax,(%esp)
  800269:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80026c:	ba 01 00 00 00       	mov    $0x1,%edx
  800271:	b8 07 00 00 00       	mov    $0x7,%eax
  800276:	e8 3d fe ff ff       	call   8000b8 <syscall>
}
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800283:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028a:	00 
  80028b:	8b 45 18             	mov    0x18(%ebp),%eax
  80028e:	0b 45 14             	or     0x14(%ebp),%eax
  800291:	89 44 24 08          	mov    %eax,0x8(%esp)
  800295:	8b 45 10             	mov    0x10(%ebp),%eax
  800298:	89 44 24 04          	mov    %eax,0x4(%esp)
  80029c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a5:	ba 01 00 00 00       	mov    $0x1,%edx
  8002aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8002af:	e8 04 fe ff ff       	call   8000b8 <syscall>
}
  8002b4:	c9                   	leave  
  8002b5:	c3                   	ret    

008002b6 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
  8002b9:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8002bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c3:	00 
  8002c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8002cb:	00 
  8002cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002d6:	89 04 24             	mov    %eax,(%esp)
  8002d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002dc:	ba 01 00 00 00       	mov    $0x1,%edx
  8002e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8002e6:	e8 cd fd ff ff       	call   8000b8 <syscall>
}
  8002eb:	c9                   	leave  
  8002ec:	c3                   	ret    

008002ed <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8002f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fa:	00 
  8002fb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800302:	00 
  800303:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80030a:	00 
  80030b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800312:	b9 00 00 00 00       	mov    $0x0,%ecx
  800317:	ba 00 00 00 00       	mov    $0x0,%edx
  80031c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800321:	e8 92 fd ff ff       	call   8000b8 <syscall>
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  80032e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800335:	00 
  800336:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800345:	00 
  800346:	8b 45 0c             	mov    0xc(%ebp),%eax
  800349:	89 04 24             	mov    %eax,(%esp)
  80034c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034f:	ba 00 00 00 00       	mov    $0x0,%edx
  800354:	b8 04 00 00 00       	mov    $0x4,%eax
  800359:	e8 5a fd ff ff       	call   8000b8 <syscall>
}
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    

00800360 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800366:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036d:	00 
  80036e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800375:	00 
  800376:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80037d:	00 
  80037e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800385:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038a:	ba 00 00 00 00       	mov    $0x0,%edx
  80038f:	b8 02 00 00 00       	mov    $0x2,%eax
  800394:	e8 1f fd ff ff       	call   8000b8 <syscall>
}
  800399:	c9                   	leave  
  80039a:	c3                   	ret    

0080039b <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8003a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003b0:	00 
  8003b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003b8:	00 
  8003b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c3:	ba 01 00 00 00       	mov    $0x1,%edx
  8003c8:	b8 03 00 00 00       	mov    $0x3,%eax
  8003cd:	e8 e6 fc ff ff       	call   8000b8 <syscall>
}
  8003d2:	c9                   	leave  
  8003d3:	c3                   	ret    

008003d4 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
  8003d7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8003da:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003e1:	00 
  8003e2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8003e9:	00 
  8003ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003f1:	00 
  8003f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800403:	b8 01 00 00 00       	mov    $0x1,%eax
  800408:	e8 ab fc ff ff       	call   8000b8 <syscall>
}
  80040d:	c9                   	leave  
  80040e:	c3                   	ret    

0080040f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800415:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80041c:	00 
  80041d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800424:	00 
  800425:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80042c:	00 
  80042d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800430:	89 04 24             	mov    %eax,(%esp)
  800433:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800436:	ba 00 00 00 00       	mov    $0x0,%edx
  80043b:	b8 00 00 00 00       	mov    $0x0,%eax
  800440:	e8 73 fc ff ff       	call   8000b8 <syscall>
}
  800445:	c9                   	leave  
  800446:	c3                   	ret    
	...

00800450 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	8b 45 08             	mov    0x8(%ebp),%eax
  800456:	05 00 00 00 30       	add    $0x30000000,%eax
  80045b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80045e:	5d                   	pop    %ebp
  80045f:	c3                   	ret    

00800460 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800460:	55                   	push   %ebp
  800461:	89 e5                	mov    %esp,%ebp
  800463:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800466:	8b 45 08             	mov    0x8(%ebp),%eax
  800469:	89 04 24             	mov    %eax,(%esp)
  80046c:	e8 df ff ff ff       	call   800450 <fd2num>
  800471:	05 20 00 0d 00       	add    $0xd0020,%eax
  800476:	c1 e0 0c             	shl    $0xc,%eax
}
  800479:	c9                   	leave  
  80047a:	c3                   	ret    

0080047b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
  80047e:	57                   	push   %edi
  80047f:	56                   	push   %esi
  800480:	53                   	push   %ebx
  800481:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  800484:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  800489:	a8 01                	test   $0x1,%al
  80048b:	74 36                	je     8004c3 <fd_alloc+0x48>
  80048d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  800492:	a8 01                	test   $0x1,%al
  800494:	74 2d                	je     8004c3 <fd_alloc+0x48>
  800496:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80049b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8004a0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8004a5:	89 c3                	mov    %eax,%ebx
  8004a7:	89 c2                	mov    %eax,%edx
  8004a9:	c1 ea 16             	shr    $0x16,%edx
  8004ac:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8004af:	f6 c2 01             	test   $0x1,%dl
  8004b2:	74 14                	je     8004c8 <fd_alloc+0x4d>
  8004b4:	89 c2                	mov    %eax,%edx
  8004b6:	c1 ea 0c             	shr    $0xc,%edx
  8004b9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8004bc:	f6 c2 01             	test   $0x1,%dl
  8004bf:	75 10                	jne    8004d1 <fd_alloc+0x56>
  8004c1:	eb 05                	jmp    8004c8 <fd_alloc+0x4d>
  8004c3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8004c8:	89 1f                	mov    %ebx,(%edi)
  8004ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8004cf:	eb 17                	jmp    8004e8 <fd_alloc+0x6d>
  8004d1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8004d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8004db:	75 c8                	jne    8004a5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8004dd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8004e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8004e8:	5b                   	pop    %ebx
  8004e9:	5e                   	pop    %esi
  8004ea:	5f                   	pop    %edi
  8004eb:	5d                   	pop    %ebp
  8004ec:	c3                   	ret    

008004ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8004f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f3:	83 f8 1f             	cmp    $0x1f,%eax
  8004f6:	77 36                	ja     80052e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8004f8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8004fd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  800500:	89 c2                	mov    %eax,%edx
  800502:	c1 ea 16             	shr    $0x16,%edx
  800505:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80050c:	f6 c2 01             	test   $0x1,%dl
  80050f:	74 1d                	je     80052e <fd_lookup+0x41>
  800511:	89 c2                	mov    %eax,%edx
  800513:	c1 ea 0c             	shr    $0xc,%edx
  800516:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80051d:	f6 c2 01             	test   $0x1,%dl
  800520:	74 0c                	je     80052e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  800522:	8b 55 0c             	mov    0xc(%ebp),%edx
  800525:	89 02                	mov    %eax,(%edx)
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80052c:	eb 05                	jmp    800533 <fd_lookup+0x46>
  80052e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800533:	5d                   	pop    %ebp
  800534:	c3                   	ret    

00800535 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  800535:	55                   	push   %ebp
  800536:	89 e5                	mov    %esp,%ebp
  800538:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80053e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800542:	8b 45 08             	mov    0x8(%ebp),%eax
  800545:	89 04 24             	mov    %eax,(%esp)
  800548:	e8 a0 ff ff ff       	call   8004ed <fd_lookup>
  80054d:	85 c0                	test   %eax,%eax
  80054f:	78 0e                	js     80055f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  800551:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800554:	8b 55 0c             	mov    0xc(%ebp),%edx
  800557:	89 50 04             	mov    %edx,0x4(%eax)
  80055a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80055f:	c9                   	leave  
  800560:	c3                   	ret    

00800561 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800561:	55                   	push   %ebp
  800562:	89 e5                	mov    %esp,%ebp
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 10             	sub    $0x10,%esp
  800569:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80056c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80056f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  800574:	b8 04 30 80 00       	mov    $0x803004,%eax
  800579:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80057f:	75 11                	jne    800592 <dev_lookup+0x31>
  800581:	eb 04                	jmp    800587 <dev_lookup+0x26>
  800583:	39 08                	cmp    %ecx,(%eax)
  800585:	75 10                	jne    800597 <dev_lookup+0x36>
			*dev = devtab[i];
  800587:	89 03                	mov    %eax,(%ebx)
  800589:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80058e:	66 90                	xchg   %ax,%ax
  800590:	eb 36                	jmp    8005c8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800592:	be b8 1d 80 00       	mov    $0x801db8,%esi
  800597:	83 c2 01             	add    $0x1,%edx
  80059a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80059d:	85 c0                	test   %eax,%eax
  80059f:	75 e2                	jne    800583 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8005a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8005a6:	8b 40 48             	mov    0x48(%eax),%eax
  8005a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005b1:	c7 04 24 3c 1d 80 00 	movl   $0x801d3c,(%esp)
  8005b8:	e8 3c 08 00 00       	call   800df9 <cprintf>
	*dev = 0;
  8005bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	5b                   	pop    %ebx
  8005cc:	5e                   	pop    %esi
  8005cd:	5d                   	pop    %ebp
  8005ce:	c3                   	ret    

008005cf <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8005cf:	55                   	push   %ebp
  8005d0:	89 e5                	mov    %esp,%ebp
  8005d2:	53                   	push   %ebx
  8005d3:	83 ec 24             	sub    $0x24,%esp
  8005d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8005d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8005dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	e8 02 ff ff ff       	call   8004ed <fd_lookup>
  8005eb:	85 c0                	test   %eax,%eax
  8005ed:	78 53                	js     800642 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8005ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8005f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	89 04 24             	mov    %eax,(%esp)
  8005fe:	e8 5e ff ff ff       	call   800561 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800603:	85 c0                	test   %eax,%eax
  800605:	78 3b                	js     800642 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  800607:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80060c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  800613:	74 2d                	je     800642 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800615:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800618:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80061f:	00 00 00 
	stat->st_isdir = 0;
  800622:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800629:	00 00 00 
	stat->st_dev = dev;
  80062c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80062f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800635:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800639:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80063c:	89 14 24             	mov    %edx,(%esp)
  80063f:	ff 50 14             	call   *0x14(%eax)
}
  800642:	83 c4 24             	add    $0x24,%esp
  800645:	5b                   	pop    %ebx
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    

00800648 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	53                   	push   %ebx
  80064c:	83 ec 24             	sub    $0x24,%esp
  80064f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800652:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800655:	89 44 24 04          	mov    %eax,0x4(%esp)
  800659:	89 1c 24             	mov    %ebx,(%esp)
  80065c:	e8 8c fe ff ff       	call   8004ed <fd_lookup>
  800661:	85 c0                	test   %eax,%eax
  800663:	78 5f                	js     8006c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800668:	89 44 24 04          	mov    %eax,0x4(%esp)
  80066c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066f:	8b 00                	mov    (%eax),%eax
  800671:	89 04 24             	mov    %eax,(%esp)
  800674:	e8 e8 fe ff ff       	call   800561 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800679:	85 c0                	test   %eax,%eax
  80067b:	78 47                	js     8006c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80067d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800680:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800684:	75 23                	jne    8006a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800686:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80068b:	8b 40 48             	mov    0x48(%eax),%eax
  80068e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800692:	89 44 24 04          	mov    %eax,0x4(%esp)
  800696:	c7 04 24 5c 1d 80 00 	movl   $0x801d5c,(%esp)
  80069d:	e8 57 07 00 00       	call   800df9 <cprintf>
  8006a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8006a7:	eb 1b                	jmp    8006c4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8006a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ac:	8b 48 18             	mov    0x18(%eax),%ecx
  8006af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b4:	85 c9                	test   %ecx,%ecx
  8006b6:	74 0c                	je     8006c4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8006b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006bf:	89 14 24             	mov    %edx,(%esp)
  8006c2:	ff d1                	call   *%ecx
}
  8006c4:	83 c4 24             	add    $0x24,%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5d                   	pop    %ebp
  8006c9:	c3                   	ret    

008006ca <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 24             	sub    $0x24,%esp
  8006d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006db:	89 1c 24             	mov    %ebx,(%esp)
  8006de:	e8 0a fe ff ff       	call   8004ed <fd_lookup>
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 66                	js     80074d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006f1:	8b 00                	mov    (%eax),%eax
  8006f3:	89 04 24             	mov    %eax,(%esp)
  8006f6:	e8 66 fe ff ff       	call   800561 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	78 4e                	js     80074d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8006ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800702:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  800706:	75 23                	jne    80072b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800708:	a1 04 40 80 00       	mov    0x804004,%eax
  80070d:	8b 40 48             	mov    0x48(%eax),%eax
  800710:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800714:	89 44 24 04          	mov    %eax,0x4(%esp)
  800718:	c7 04 24 7d 1d 80 00 	movl   $0x801d7d,(%esp)
  80071f:	e8 d5 06 00 00       	call   800df9 <cprintf>
  800724:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  800729:	eb 22                	jmp    80074d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072e:	8b 48 0c             	mov    0xc(%eax),%ecx
  800731:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800736:	85 c9                	test   %ecx,%ecx
  800738:	74 13                	je     80074d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800741:	8b 45 0c             	mov    0xc(%ebp),%eax
  800744:	89 44 24 04          	mov    %eax,0x4(%esp)
  800748:	89 14 24             	mov    %edx,(%esp)
  80074b:	ff d1                	call   *%ecx
}
  80074d:	83 c4 24             	add    $0x24,%esp
  800750:	5b                   	pop    %ebx
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800753:	55                   	push   %ebp
  800754:	89 e5                	mov    %esp,%ebp
  800756:	53                   	push   %ebx
  800757:	83 ec 24             	sub    $0x24,%esp
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800760:	89 44 24 04          	mov    %eax,0x4(%esp)
  800764:	89 1c 24             	mov    %ebx,(%esp)
  800767:	e8 81 fd ff ff       	call   8004ed <fd_lookup>
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 6b                	js     8007db <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800770:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800773:	89 44 24 04          	mov    %eax,0x4(%esp)
  800777:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077a:	8b 00                	mov    (%eax),%eax
  80077c:	89 04 24             	mov    %eax,(%esp)
  80077f:	e8 dd fd ff ff       	call   800561 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800784:	85 c0                	test   %eax,%eax
  800786:	78 53                	js     8007db <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800788:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80078b:	8b 42 08             	mov    0x8(%edx),%eax
  80078e:	83 e0 03             	and    $0x3,%eax
  800791:	83 f8 01             	cmp    $0x1,%eax
  800794:	75 23                	jne    8007b9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800796:	a1 04 40 80 00       	mov    0x804004,%eax
  80079b:	8b 40 48             	mov    0x48(%eax),%eax
  80079e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8007a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a6:	c7 04 24 9a 1d 80 00 	movl   $0x801d9a,(%esp)
  8007ad:	e8 47 06 00 00       	call   800df9 <cprintf>
  8007b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8007b7:	eb 22                	jmp    8007db <read+0x88>
	}
	if (!dev->dev_read)
  8007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bc:	8b 48 08             	mov    0x8(%eax),%ecx
  8007bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007c4:	85 c9                	test   %ecx,%ecx
  8007c6:	74 13                	je     8007db <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8007c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8007cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d6:	89 14 24             	mov    %edx,(%esp)
  8007d9:	ff d1                	call   *%ecx
}
  8007db:	83 c4 24             	add    $0x24,%esp
  8007de:	5b                   	pop    %ebx
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8007e1:	55                   	push   %ebp
  8007e2:	89 e5                	mov    %esp,%ebp
  8007e4:	57                   	push   %edi
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	83 ec 1c             	sub    $0x1c,%esp
  8007ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8007ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8007f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ff:	85 f6                	test   %esi,%esi
  800801:	74 29                	je     80082c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800803:	89 f0                	mov    %esi,%eax
  800805:	29 d0                	sub    %edx,%eax
  800807:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080b:	03 55 0c             	add    0xc(%ebp),%edx
  80080e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800812:	89 3c 24             	mov    %edi,(%esp)
  800815:	e8 39 ff ff ff       	call   800753 <read>
		if (m < 0)
  80081a:	85 c0                	test   %eax,%eax
  80081c:	78 0e                	js     80082c <readn+0x4b>
			return m;
		if (m == 0)
  80081e:	85 c0                	test   %eax,%eax
  800820:	74 08                	je     80082a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800822:	01 c3                	add    %eax,%ebx
  800824:	89 da                	mov    %ebx,%edx
  800826:	39 f3                	cmp    %esi,%ebx
  800828:	72 d9                	jb     800803 <readn+0x22>
  80082a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80082c:	83 c4 1c             	add    $0x1c,%esp
  80082f:	5b                   	pop    %ebx
  800830:	5e                   	pop    %esi
  800831:	5f                   	pop    %edi
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	83 ec 28             	sub    $0x28,%esp
  80083a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80083d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800840:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800843:	89 34 24             	mov    %esi,(%esp)
  800846:	e8 05 fc ff ff       	call   800450 <fd2num>
  80084b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80084e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800852:	89 04 24             	mov    %eax,(%esp)
  800855:	e8 93 fc ff ff       	call   8004ed <fd_lookup>
  80085a:	89 c3                	mov    %eax,%ebx
  80085c:	85 c0                	test   %eax,%eax
  80085e:	78 05                	js     800865 <fd_close+0x31>
  800860:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800863:	74 0e                	je     800873 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  800865:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800869:	b8 00 00 00 00       	mov    $0x0,%eax
  80086e:	0f 44 d8             	cmove  %eax,%ebx
  800871:	eb 3d                	jmp    8008b0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800876:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087a:	8b 06                	mov    (%esi),%eax
  80087c:	89 04 24             	mov    %eax,(%esp)
  80087f:	e8 dd fc ff ff       	call   800561 <dev_lookup>
  800884:	89 c3                	mov    %eax,%ebx
  800886:	85 c0                	test   %eax,%eax
  800888:	78 16                	js     8008a0 <fd_close+0x6c>
		if (dev->dev_close)
  80088a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088d:	8b 40 10             	mov    0x10(%eax),%eax
  800890:	bb 00 00 00 00       	mov    $0x0,%ebx
  800895:	85 c0                	test   %eax,%eax
  800897:	74 07                	je     8008a0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  800899:	89 34 24             	mov    %esi,(%esp)
  80089c:	ff d0                	call   *%eax
  80089e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8008a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8008ab:	e8 95 f9 ff ff       	call   800245 <sys_page_unmap>
	return r;
}
  8008b0:	89 d8                	mov    %ebx,%eax
  8008b2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8008b5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8008b8:	89 ec                	mov    %ebp,%esp
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8008c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	e8 19 fc ff ff       	call   8004ed <fd_lookup>
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 13                	js     8008eb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8008d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8008df:	00 
  8008e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e3:	89 04 24             	mov    %eax,(%esp)
  8008e6:	e8 49 ff ff ff       	call   800834 <fd_close>
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	83 ec 18             	sub    $0x18,%esp
  8008f3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8008f6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800900:	00 
  800901:	8b 45 08             	mov    0x8(%ebp),%eax
  800904:	89 04 24             	mov    %eax,(%esp)
  800907:	e8 78 03 00 00       	call   800c84 <open>
  80090c:	89 c3                	mov    %eax,%ebx
  80090e:	85 c0                	test   %eax,%eax
  800910:	78 1b                	js     80092d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  800912:	8b 45 0c             	mov    0xc(%ebp),%eax
  800915:	89 44 24 04          	mov    %eax,0x4(%esp)
  800919:	89 1c 24             	mov    %ebx,(%esp)
  80091c:	e8 ae fc ff ff       	call   8005cf <fstat>
  800921:	89 c6                	mov    %eax,%esi
	close(fd);
  800923:	89 1c 24             	mov    %ebx,(%esp)
  800926:	e8 91 ff ff ff       	call   8008bc <close>
  80092b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80092d:	89 d8                	mov    %ebx,%eax
  80092f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800932:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800935:	89 ec                	mov    %ebp,%esp
  800937:	5d                   	pop    %ebp
  800938:	c3                   	ret    

00800939 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  800939:	55                   	push   %ebp
  80093a:	89 e5                	mov    %esp,%ebp
  80093c:	53                   	push   %ebx
  80093d:	83 ec 14             	sub    $0x14,%esp
  800940:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  800945:	89 1c 24             	mov    %ebx,(%esp)
  800948:	e8 6f ff ff ff       	call   8008bc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80094d:	83 c3 01             	add    $0x1,%ebx
  800950:	83 fb 20             	cmp    $0x20,%ebx
  800953:	75 f0                	jne    800945 <close_all+0xc>
		close(i);
}
  800955:	83 c4 14             	add    $0x14,%esp
  800958:	5b                   	pop    %ebx
  800959:	5d                   	pop    %ebp
  80095a:	c3                   	ret    

0080095b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 58             	sub    $0x58,%esp
  800961:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800964:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800967:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80096a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80096d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800970:	89 44 24 04          	mov    %eax,0x4(%esp)
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	89 04 24             	mov    %eax,(%esp)
  80097a:	e8 6e fb ff ff       	call   8004ed <fd_lookup>
  80097f:	89 c3                	mov    %eax,%ebx
  800981:	85 c0                	test   %eax,%eax
  800983:	0f 88 e0 00 00 00    	js     800a69 <dup+0x10e>
		return r;
	close(newfdnum);
  800989:	89 3c 24             	mov    %edi,(%esp)
  80098c:	e8 2b ff ff ff       	call   8008bc <close>

	newfd = INDEX2FD(newfdnum);
  800991:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  800997:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80099a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80099d:	89 04 24             	mov    %eax,(%esp)
  8009a0:	e8 bb fa ff ff       	call   800460 <fd2data>
  8009a5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8009a7:	89 34 24             	mov    %esi,(%esp)
  8009aa:	e8 b1 fa ff ff       	call   800460 <fd2data>
  8009af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8009b2:	89 da                	mov    %ebx,%edx
  8009b4:	89 d8                	mov    %ebx,%eax
  8009b6:	c1 e8 16             	shr    $0x16,%eax
  8009b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009c0:	a8 01                	test   $0x1,%al
  8009c2:	74 43                	je     800a07 <dup+0xac>
  8009c4:	c1 ea 0c             	shr    $0xc,%edx
  8009c7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8009ce:	a8 01                	test   $0x1,%al
  8009d0:	74 35                	je     800a07 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009d2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8009d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8009de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8009e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8009f0:	00 
  8009f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8009f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009fc:	e8 7c f8 ff ff       	call   80027d <sys_page_map>
  800a01:	89 c3                	mov    %eax,%ebx
  800a03:	85 c0                	test   %eax,%eax
  800a05:	78 3f                	js     800a46 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a0a:	89 c2                	mov    %eax,%edx
  800a0c:	c1 ea 0c             	shr    $0xc,%edx
  800a0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800a16:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800a1c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a20:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800a24:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800a2b:	00 
  800a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a37:	e8 41 f8 ff ff       	call   80027d <sys_page_map>
  800a3c:	89 c3                	mov    %eax,%ebx
  800a3e:	85 c0                	test   %eax,%eax
  800a40:	78 04                	js     800a46 <dup+0xeb>
  800a42:	89 fb                	mov    %edi,%ebx
  800a44:	eb 23                	jmp    800a69 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a51:	e8 ef f7 ff ff       	call   800245 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a56:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a64:	e8 dc f7 ff ff       	call   800245 <sys_page_unmap>
	return r;
}
  800a69:	89 d8                	mov    %ebx,%eax
  800a6b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800a6e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800a71:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800a74:	89 ec                	mov    %ebp,%esp
  800a76:	5d                   	pop    %ebp
  800a77:	c3                   	ret    

00800a78 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	83 ec 18             	sub    $0x18,%esp
  800a7e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800a81:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800a84:	89 c3                	mov    %eax,%ebx
  800a86:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  800a88:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800a8f:	75 11                	jne    800aa2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800a91:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800a98:	e8 93 0e 00 00       	call   801930 <ipc_find_env>
  800a9d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800aa2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800aa9:	00 
  800aaa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  800ab1:	00 
  800ab2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab6:	a1 00 40 80 00       	mov    0x804000,%eax
  800abb:	89 04 24             	mov    %eax,(%esp)
  800abe:	e8 b1 0e 00 00       	call   801974 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800ac3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800aca:	00 
  800acb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800acf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ad6:	e8 08 0f 00 00       	call   8019e3 <ipc_recv>
}
  800adb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800ade:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800ae1:	89 ec                	mov    %ebp,%esp
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 40 0c             	mov    0xc(%eax),%eax
  800af1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800af6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800afe:	ba 00 00 00 00       	mov    $0x0,%edx
  800b03:	b8 02 00 00 00       	mov    $0x2,%eax
  800b08:	e8 6b ff ff ff       	call   800a78 <fsipc>
}
  800b0d:	c9                   	leave  
  800b0e:	c3                   	ret    

00800b0f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	8b 40 0c             	mov    0xc(%eax),%eax
  800b1b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 06 00 00 00       	mov    $0x6,%eax
  800b2a:	e8 49 ff ff ff       	call   800a78 <fsipc>
}
  800b2f:	c9                   	leave  
  800b30:	c3                   	ret    

00800b31 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b37:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b41:	e8 32 ff ff ff       	call   800a78 <fsipc>
}
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	53                   	push   %ebx
  800b4c:	83 ec 14             	sub    $0x14,%esp
  800b4f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 40 0c             	mov    0xc(%eax),%eax
  800b58:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 05 00 00 00       	mov    $0x5,%eax
  800b67:	e8 0c ff ff ff       	call   800a78 <fsipc>
  800b6c:	85 c0                	test   %eax,%eax
  800b6e:	78 2b                	js     800b9b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800b70:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800b77:	00 
  800b78:	89 1c 24             	mov    %ebx,(%esp)
  800b7b:	e8 ba 09 00 00       	call   80153a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800b80:	a1 80 50 80 00       	mov    0x805080,%eax
  800b85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800b8b:	a1 84 50 80 00       	mov    0x805084,%eax
  800b90:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  800b9b:	83 c4 14             	add    $0x14,%esp
  800b9e:	5b                   	pop    %ebx
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 18             	sub    $0x18,%esp
  800ba7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  800baa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bad:	8b 52 0c             	mov    0xc(%edx),%edx
  800bb0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  800bb6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  800bbb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800bc0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800bc5:	0f 47 c2             	cmova  %edx,%eax
  800bc8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bcc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  800bda:	e8 46 0b 00 00       	call   801725 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 04 00 00 00       	mov    $0x4,%eax
  800be9:	e8 8a fe ff ff       	call   800a78 <fsipc>
}
  800bee:	c9                   	leave  
  800bef:	c3                   	ret    

00800bf0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  800bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfa:	8b 40 0c             	mov    0xc(%eax),%eax
  800bfd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  800c02:	8b 45 10             	mov    0x10(%ebp),%eax
  800c05:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	b8 03 00 00 00       	mov    $0x3,%eax
  800c14:	e8 5f fe ff ff       	call   800a78 <fsipc>
  800c19:	89 c3                	mov    %eax,%ebx
  800c1b:	85 c0                	test   %eax,%eax
  800c1d:	78 17                	js     800c36 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800c1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c23:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  800c2a:	00 
  800c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2e:	89 04 24             	mov    %eax,(%esp)
  800c31:	e8 ef 0a 00 00       	call   801725 <memmove>
  return r;	
}
  800c36:	89 d8                	mov    %ebx,%eax
  800c38:	83 c4 14             	add    $0x14,%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	53                   	push   %ebx
  800c42:	83 ec 14             	sub    $0x14,%esp
  800c45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  800c48:	89 1c 24             	mov    %ebx,(%esp)
  800c4b:	e8 a0 08 00 00       	call   8014f0 <strlen>
  800c50:	89 c2                	mov    %eax,%edx
  800c52:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800c57:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  800c5d:	7f 1f                	jg     800c7e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  800c5f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c63:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800c6a:	e8 cb 08 00 00       	call   80153a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  800c6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c74:	b8 07 00 00 00       	mov    $0x7,%eax
  800c79:	e8 fa fd ff ff       	call   800a78 <fsipc>
}
  800c7e:	83 c4 14             	add    $0x14,%esp
  800c81:	5b                   	pop    %ebx
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 28             	sub    $0x28,%esp
  800c8a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800c8d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800c90:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  800c93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c96:	89 04 24             	mov    %eax,(%esp)
  800c99:	e8 dd f7 ff ff       	call   80047b <fd_alloc>
  800c9e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  800ca0:	85 c0                	test   %eax,%eax
  800ca2:	0f 88 89 00 00 00    	js     800d31 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800ca8:	89 34 24             	mov    %esi,(%esp)
  800cab:	e8 40 08 00 00       	call   8014f0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  800cb0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  800cb5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800cba:	7f 75                	jg     800d31 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  800cbc:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cc0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800cc7:	e8 6e 08 00 00       	call   80153a <strcpy>
  fsipcbuf.open.req_omode = mode;
  800ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  800cd4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800cd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cdc:	e8 97 fd ff ff       	call   800a78 <fsipc>
  800ce1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	78 0f                	js     800cf6 <open+0x72>
  return fd2num(fd);
  800ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cea:	89 04 24             	mov    %eax,(%esp)
  800ced:	e8 5e f7 ff ff       	call   800450 <fd2num>
  800cf2:	89 c3                	mov    %eax,%ebx
  800cf4:	eb 3b                	jmp    800d31 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  800cf6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cfd:	00 
  800cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d01:	89 04 24             	mov    %eax,(%esp)
  800d04:	e8 2b fb ff ff       	call   800834 <fd_close>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	74 24                	je     800d31 <open+0xad>
  800d0d:	c7 44 24 0c c0 1d 80 	movl   $0x801dc0,0xc(%esp)
  800d14:	00 
  800d15:	c7 44 24 08 d5 1d 80 	movl   $0x801dd5,0x8(%esp)
  800d1c:	00 
  800d1d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800d24:	00 
  800d25:	c7 04 24 ea 1d 80 00 	movl   $0x801dea,(%esp)
  800d2c:	e8 0f 00 00 00       	call   800d40 <_panic>
  return r;
}
  800d31:	89 d8                	mov    %ebx,%eax
  800d33:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800d36:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800d39:	89 ec                	mov    %ebp,%esp
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    
  800d3d:	00 00                	add    %al,(%eax)
	...

00800d40 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	56                   	push   %esi
  800d44:	53                   	push   %ebx
  800d45:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800d48:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d4b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800d51:	e8 0a f6 ff ff       	call   800360 <sys_getenvid>
  800d56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d59:	89 54 24 10          	mov    %edx,0x10(%esp)
  800d5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d60:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800d64:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d6c:	c7 04 24 f8 1d 80 00 	movl   $0x801df8,(%esp)
  800d73:	e8 81 00 00 00       	call   800df9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d78:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d7f:	89 04 24             	mov    %eax,(%esp)
  800d82:	e8 11 00 00 00       	call   800d98 <vcprintf>
	cprintf("\n");
  800d87:	c7 04 24 b4 1d 80 00 	movl   $0x801db4,(%esp)
  800d8e:	e8 66 00 00 00       	call   800df9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d93:	cc                   	int3   
  800d94:	eb fd                	jmp    800d93 <_panic+0x53>
	...

00800d98 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800da1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800da8:	00 00 00 
	b.cnt = 0;
  800dab:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800db2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800db5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcd:	c7 04 24 13 0e 80 00 	movl   $0x800e13,(%esp)
  800dd4:	e8 d4 01 00 00       	call   800fad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800dd9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800de9:	89 04 24             	mov    %eax,(%esp)
  800dec:	e8 1e f6 ff ff       	call   80040f <sys_cputs>

	return b.cnt;
}
  800df1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800dff:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800e02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e06:	8b 45 08             	mov    0x8(%ebp),%eax
  800e09:	89 04 24             	mov    %eax,(%esp)
  800e0c:	e8 87 ff ff ff       	call   800d98 <vcprintf>
	va_end(ap);

	return cnt;
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	53                   	push   %ebx
  800e17:	83 ec 14             	sub    $0x14,%esp
  800e1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800e1d:	8b 03                	mov    (%ebx),%eax
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800e26:	83 c0 01             	add    $0x1,%eax
  800e29:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800e2b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800e30:	75 19                	jne    800e4b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800e32:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800e39:	00 
  800e3a:	8d 43 08             	lea    0x8(%ebx),%eax
  800e3d:	89 04 24             	mov    %eax,(%esp)
  800e40:	e8 ca f5 ff ff       	call   80040f <sys_cputs>
		b->idx = 0;
  800e45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800e4b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800e4f:	83 c4 14             	add    $0x14,%esp
  800e52:	5b                   	pop    %ebx
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
	...

00800e60 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	57                   	push   %edi
  800e64:	56                   	push   %esi
  800e65:	53                   	push   %ebx
  800e66:	83 ec 4c             	sub    $0x4c,%esp
  800e69:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800e6c:	89 d6                	mov    %edx,%esi
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e74:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e77:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e7a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800e80:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800e83:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800e86:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e8b:	39 d1                	cmp    %edx,%ecx
  800e8d:	72 15                	jb     800ea4 <printnum+0x44>
  800e8f:	77 07                	ja     800e98 <printnum+0x38>
  800e91:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800e94:	39 d0                	cmp    %edx,%eax
  800e96:	76 0c                	jbe    800ea4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800e98:	83 eb 01             	sub    $0x1,%ebx
  800e9b:	85 db                	test   %ebx,%ebx
  800e9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ea0:	7f 61                	jg     800f03 <printnum+0xa3>
  800ea2:	eb 70                	jmp    800f14 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800ea4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800ea8:	83 eb 01             	sub    $0x1,%ebx
  800eab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eb3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800eb7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  800ebb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800ebe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800ec1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800ec4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ec8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ecf:	00 
  800ed0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ed3:	89 04 24             	mov    %eax,(%esp)
  800ed6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ed9:	89 54 24 04          	mov    %edx,0x4(%esp)
  800edd:	e8 9e 0b 00 00       	call   801a80 <__udivdi3>
  800ee2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800ee5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800ee8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ef0:	89 04 24             	mov    %eax,(%esp)
  800ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef7:	89 f2                	mov    %esi,%edx
  800ef9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800efc:	e8 5f ff ff ff       	call   800e60 <printnum>
  800f01:	eb 11                	jmp    800f14 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800f03:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f07:	89 3c 24             	mov    %edi,(%esp)
  800f0a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800f0d:	83 eb 01             	sub    $0x1,%ebx
  800f10:	85 db                	test   %ebx,%ebx
  800f12:	7f ef                	jg     800f03 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800f14:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f18:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800f1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f23:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f2a:	00 
  800f2b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f2e:	89 14 24             	mov    %edx,(%esp)
  800f31:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800f34:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f38:	e8 73 0c 00 00       	call   801bb0 <__umoddi3>
  800f3d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f41:	0f be 80 1b 1e 80 00 	movsbl 0x801e1b(%eax),%eax
  800f48:	89 04 24             	mov    %eax,(%esp)
  800f4b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800f4e:	83 c4 4c             	add    $0x4c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    

00800f56 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800f56:	55                   	push   %ebp
  800f57:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800f59:	83 fa 01             	cmp    $0x1,%edx
  800f5c:	7e 0e                	jle    800f6c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800f5e:	8b 10                	mov    (%eax),%edx
  800f60:	8d 4a 08             	lea    0x8(%edx),%ecx
  800f63:	89 08                	mov    %ecx,(%eax)
  800f65:	8b 02                	mov    (%edx),%eax
  800f67:	8b 52 04             	mov    0x4(%edx),%edx
  800f6a:	eb 22                	jmp    800f8e <getuint+0x38>
	else if (lflag)
  800f6c:	85 d2                	test   %edx,%edx
  800f6e:	74 10                	je     800f80 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800f70:	8b 10                	mov    (%eax),%edx
  800f72:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f75:	89 08                	mov    %ecx,(%eax)
  800f77:	8b 02                	mov    (%edx),%eax
  800f79:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7e:	eb 0e                	jmp    800f8e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800f80:	8b 10                	mov    (%eax),%edx
  800f82:	8d 4a 04             	lea    0x4(%edx),%ecx
  800f85:	89 08                	mov    %ecx,(%eax)
  800f87:	8b 02                	mov    (%edx),%eax
  800f89:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800f96:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800f9a:	8b 10                	mov    (%eax),%edx
  800f9c:	3b 50 04             	cmp    0x4(%eax),%edx
  800f9f:	73 0a                	jae    800fab <sprintputch+0x1b>
		*b->buf++ = ch;
  800fa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa4:	88 0a                	mov    %cl,(%edx)
  800fa6:	83 c2 01             	add    $0x1,%edx
  800fa9:	89 10                	mov    %edx,(%eax)
}
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	57                   	push   %edi
  800fb1:	56                   	push   %esi
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 5c             	sub    $0x5c,%esp
  800fb6:	8b 7d 08             	mov    0x8(%ebp),%edi
  800fb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  800fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800fbf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800fc6:	eb 11                	jmp    800fd9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	0f 84 68 04 00 00    	je     801438 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800fd0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fd4:	89 04 24             	mov    %eax,(%esp)
  800fd7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800fd9:	0f b6 03             	movzbl (%ebx),%eax
  800fdc:	83 c3 01             	add    $0x1,%ebx
  800fdf:	83 f8 25             	cmp    $0x25,%eax
  800fe2:	75 e4                	jne    800fc8 <vprintfmt+0x1b>
  800fe4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800feb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800ff2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800ffb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801002:	eb 06                	jmp    80100a <vprintfmt+0x5d>
  801004:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  801008:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80100a:	0f b6 13             	movzbl (%ebx),%edx
  80100d:	0f b6 c2             	movzbl %dl,%eax
  801010:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801013:	8d 43 01             	lea    0x1(%ebx),%eax
  801016:	83 ea 23             	sub    $0x23,%edx
  801019:	80 fa 55             	cmp    $0x55,%dl
  80101c:	0f 87 f9 03 00 00    	ja     80141b <vprintfmt+0x46e>
  801022:	0f b6 d2             	movzbl %dl,%edx
  801025:	ff 24 95 00 20 80 00 	jmp    *0x802000(,%edx,4)
  80102c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  801030:	eb d6                	jmp    801008 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801032:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801035:	83 ea 30             	sub    $0x30,%edx
  801038:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80103b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80103e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  801041:	83 fb 09             	cmp    $0x9,%ebx
  801044:	77 54                	ja     80109a <vprintfmt+0xed>
  801046:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801049:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80104c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80104f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  801052:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  801056:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  801059:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80105c:	83 fb 09             	cmp    $0x9,%ebx
  80105f:	76 eb                	jbe    80104c <vprintfmt+0x9f>
  801061:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801064:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801067:	eb 31                	jmp    80109a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801069:	8b 55 14             	mov    0x14(%ebp),%edx
  80106c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80106f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  801072:	8b 12                	mov    (%edx),%edx
  801074:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  801077:	eb 21                	jmp    80109a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  801079:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80107d:	ba 00 00 00 00       	mov    $0x0,%edx
  801082:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  801086:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  801089:	e9 7a ff ff ff       	jmp    801008 <vprintfmt+0x5b>
  80108e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  801095:	e9 6e ff ff ff       	jmp    801008 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80109a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80109e:	0f 89 64 ff ff ff    	jns    801008 <vprintfmt+0x5b>
  8010a4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8010a7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8010aa:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8010ad:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8010b0:	e9 53 ff ff ff       	jmp    801008 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8010b5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8010b8:	e9 4b ff ff ff       	jmp    801008 <vprintfmt+0x5b>
  8010bd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8010c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8010c3:	8d 50 04             	lea    0x4(%eax),%edx
  8010c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8010c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8010cd:	8b 00                	mov    (%eax),%eax
  8010cf:	89 04 24             	mov    %eax,(%esp)
  8010d2:	ff d7                	call   *%edi
  8010d4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8010d7:	e9 fd fe ff ff       	jmp    800fd9 <vprintfmt+0x2c>
  8010dc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8010df:	8b 45 14             	mov    0x14(%ebp),%eax
  8010e2:	8d 50 04             	lea    0x4(%eax),%edx
  8010e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8010e8:	8b 00                	mov    (%eax),%eax
  8010ea:	89 c2                	mov    %eax,%edx
  8010ec:	c1 fa 1f             	sar    $0x1f,%edx
  8010ef:	31 d0                	xor    %edx,%eax
  8010f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8010f3:	83 f8 0f             	cmp    $0xf,%eax
  8010f6:	7f 0b                	jg     801103 <vprintfmt+0x156>
  8010f8:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  8010ff:	85 d2                	test   %edx,%edx
  801101:	75 20                	jne    801123 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  801103:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801107:	c7 44 24 08 2c 1e 80 	movl   $0x801e2c,0x8(%esp)
  80110e:	00 
  80110f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801113:	89 3c 24             	mov    %edi,(%esp)
  801116:	e8 a5 03 00 00       	call   8014c0 <printfmt>
  80111b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80111e:	e9 b6 fe ff ff       	jmp    800fd9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  801123:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801127:	c7 44 24 08 e7 1d 80 	movl   $0x801de7,0x8(%esp)
  80112e:	00 
  80112f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801133:	89 3c 24             	mov    %edi,(%esp)
  801136:	e8 85 03 00 00       	call   8014c0 <printfmt>
  80113b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80113e:	e9 96 fe ff ff       	jmp    800fd9 <vprintfmt+0x2c>
  801143:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801146:	89 c3                	mov    %eax,%ebx
  801148:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80114b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80114e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801151:	8b 45 14             	mov    0x14(%ebp),%eax
  801154:	8d 50 04             	lea    0x4(%eax),%edx
  801157:	89 55 14             	mov    %edx,0x14(%ebp)
  80115a:	8b 00                	mov    (%eax),%eax
  80115c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80115f:	85 c0                	test   %eax,%eax
  801161:	b8 35 1e 80 00       	mov    $0x801e35,%eax
  801166:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80116a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80116d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  801171:	7e 06                	jle    801179 <vprintfmt+0x1cc>
  801173:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  801177:	75 13                	jne    80118c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801179:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80117c:	0f be 02             	movsbl (%edx),%eax
  80117f:	85 c0                	test   %eax,%eax
  801181:	0f 85 a2 00 00 00    	jne    801229 <vprintfmt+0x27c>
  801187:	e9 8f 00 00 00       	jmp    80121b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80118c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801190:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801193:	89 0c 24             	mov    %ecx,(%esp)
  801196:	e8 70 03 00 00       	call   80150b <strnlen>
  80119b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80119e:	29 c2                	sub    %eax,%edx
  8011a0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8011a3:	85 d2                	test   %edx,%edx
  8011a5:	7e d2                	jle    801179 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8011a7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8011ab:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8011ae:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8011b1:	89 d3                	mov    %edx,%ebx
  8011b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011ba:	89 04 24             	mov    %eax,(%esp)
  8011bd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8011bf:	83 eb 01             	sub    $0x1,%ebx
  8011c2:	85 db                	test   %ebx,%ebx
  8011c4:	7f ed                	jg     8011b3 <vprintfmt+0x206>
  8011c6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8011c9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8011d0:	eb a7                	jmp    801179 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011d2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8011d6:	74 1b                	je     8011f3 <vprintfmt+0x246>
  8011d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8011db:	83 fa 5e             	cmp    $0x5e,%edx
  8011de:	76 13                	jbe    8011f3 <vprintfmt+0x246>
					putch('?', putdat);
  8011e0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8011e7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8011ee:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8011f1:	eb 0d                	jmp    801200 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8011f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8011f6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011fa:	89 04 24             	mov    %eax,(%esp)
  8011fd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801200:	83 ef 01             	sub    $0x1,%edi
  801203:	0f be 03             	movsbl (%ebx),%eax
  801206:	85 c0                	test   %eax,%eax
  801208:	74 05                	je     80120f <vprintfmt+0x262>
  80120a:	83 c3 01             	add    $0x1,%ebx
  80120d:	eb 31                	jmp    801240 <vprintfmt+0x293>
  80120f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801212:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801215:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801218:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80121b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80121f:	7f 36                	jg     801257 <vprintfmt+0x2aa>
  801221:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801224:	e9 b0 fd ff ff       	jmp    800fd9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801229:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80122c:	83 c2 01             	add    $0x1,%edx
  80122f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801232:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801235:	89 75 e0             	mov    %esi,-0x20(%ebp)
  801238:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80123b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80123e:	89 d3                	mov    %edx,%ebx
  801240:	85 f6                	test   %esi,%esi
  801242:	78 8e                	js     8011d2 <vprintfmt+0x225>
  801244:	83 ee 01             	sub    $0x1,%esi
  801247:	79 89                	jns    8011d2 <vprintfmt+0x225>
  801249:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80124c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80124f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801252:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  801255:	eb c4                	jmp    80121b <vprintfmt+0x26e>
  801257:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80125a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80125d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801261:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801268:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80126a:	83 eb 01             	sub    $0x1,%ebx
  80126d:	85 db                	test   %ebx,%ebx
  80126f:	7f ec                	jg     80125d <vprintfmt+0x2b0>
  801271:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  801274:	e9 60 fd ff ff       	jmp    800fd9 <vprintfmt+0x2c>
  801279:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80127c:	83 f9 01             	cmp    $0x1,%ecx
  80127f:	7e 16                	jle    801297 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  801281:	8b 45 14             	mov    0x14(%ebp),%eax
  801284:	8d 50 08             	lea    0x8(%eax),%edx
  801287:	89 55 14             	mov    %edx,0x14(%ebp)
  80128a:	8b 10                	mov    (%eax),%edx
  80128c:	8b 48 04             	mov    0x4(%eax),%ecx
  80128f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  801292:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801295:	eb 32                	jmp    8012c9 <vprintfmt+0x31c>
	else if (lflag)
  801297:	85 c9                	test   %ecx,%ecx
  801299:	74 18                	je     8012b3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80129b:	8b 45 14             	mov    0x14(%ebp),%eax
  80129e:	8d 50 04             	lea    0x4(%eax),%edx
  8012a1:	89 55 14             	mov    %edx,0x14(%ebp)
  8012a4:	8b 00                	mov    (%eax),%eax
  8012a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012a9:	89 c1                	mov    %eax,%ecx
  8012ab:	c1 f9 1f             	sar    $0x1f,%ecx
  8012ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8012b1:	eb 16                	jmp    8012c9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8012b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b6:	8d 50 04             	lea    0x4(%eax),%edx
  8012b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8012bc:	8b 00                	mov    (%eax),%eax
  8012be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012c1:	89 c2                	mov    %eax,%edx
  8012c3:	c1 fa 1f             	sar    $0x1f,%edx
  8012c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8012c9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8012cf:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8012d4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8012d8:	0f 89 8a 00 00 00    	jns    801368 <vprintfmt+0x3bb>
				putch('-', putdat);
  8012de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012e2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8012e9:	ff d7                	call   *%edi
				num = -(long long) num;
  8012eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8012f1:	f7 d8                	neg    %eax
  8012f3:	83 d2 00             	adc    $0x0,%edx
  8012f6:	f7 da                	neg    %edx
  8012f8:	eb 6e                	jmp    801368 <vprintfmt+0x3bb>
  8012fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8012fd:	89 ca                	mov    %ecx,%edx
  8012ff:	8d 45 14             	lea    0x14(%ebp),%eax
  801302:	e8 4f fc ff ff       	call   800f56 <getuint>
  801307:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80130c:	eb 5a                	jmp    801368 <vprintfmt+0x3bb>
  80130e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  801311:	89 ca                	mov    %ecx,%edx
  801313:	8d 45 14             	lea    0x14(%ebp),%eax
  801316:	e8 3b fc ff ff       	call   800f56 <getuint>
  80131b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  801320:	eb 46                	jmp    801368 <vprintfmt+0x3bb>
  801322:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  801325:	89 74 24 04          	mov    %esi,0x4(%esp)
  801329:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801330:	ff d7                	call   *%edi
			putch('x', putdat);
  801332:	89 74 24 04          	mov    %esi,0x4(%esp)
  801336:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80133d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80133f:	8b 45 14             	mov    0x14(%ebp),%eax
  801342:	8d 50 04             	lea    0x4(%eax),%edx
  801345:	89 55 14             	mov    %edx,0x14(%ebp)
  801348:	8b 00                	mov    (%eax),%eax
  80134a:	ba 00 00 00 00       	mov    $0x0,%edx
  80134f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801354:	eb 12                	jmp    801368 <vprintfmt+0x3bb>
  801356:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801359:	89 ca                	mov    %ecx,%edx
  80135b:	8d 45 14             	lea    0x14(%ebp),%eax
  80135e:	e8 f3 fb ff ff       	call   800f56 <getuint>
  801363:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  801368:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80136c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801370:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  801373:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801377:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80137b:	89 04 24             	mov    %eax,(%esp)
  80137e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801382:	89 f2                	mov    %esi,%edx
  801384:	89 f8                	mov    %edi,%eax
  801386:	e8 d5 fa ff ff       	call   800e60 <printnum>
  80138b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80138e:	e9 46 fc ff ff       	jmp    800fd9 <vprintfmt+0x2c>
  801393:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  801396:	8b 45 14             	mov    0x14(%ebp),%eax
  801399:	8d 50 04             	lea    0x4(%eax),%edx
  80139c:	89 55 14             	mov    %edx,0x14(%ebp)
  80139f:	8b 00                	mov    (%eax),%eax
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	75 24                	jne    8013c9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8013a5:	c7 44 24 0c 50 1f 80 	movl   $0x801f50,0xc(%esp)
  8013ac:	00 
  8013ad:	c7 44 24 08 e7 1d 80 	movl   $0x801de7,0x8(%esp)
  8013b4:	00 
  8013b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013b9:	89 3c 24             	mov    %edi,(%esp)
  8013bc:	e8 ff 00 00 00       	call   8014c0 <printfmt>
  8013c1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8013c4:	e9 10 fc ff ff       	jmp    800fd9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8013c9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8013cc:	7e 29                	jle    8013f7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8013ce:	0f b6 16             	movzbl (%esi),%edx
  8013d1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8013d3:	c7 44 24 0c 88 1f 80 	movl   $0x801f88,0xc(%esp)
  8013da:	00 
  8013db:	c7 44 24 08 e7 1d 80 	movl   $0x801de7,0x8(%esp)
  8013e2:	00 
  8013e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8013e7:	89 3c 24             	mov    %edi,(%esp)
  8013ea:	e8 d1 00 00 00       	call   8014c0 <printfmt>
  8013ef:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8013f2:	e9 e2 fb ff ff       	jmp    800fd9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8013f7:	0f b6 16             	movzbl (%esi),%edx
  8013fa:	88 10                	mov    %dl,(%eax)
  8013fc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8013ff:	e9 d5 fb ff ff       	jmp    800fd9 <vprintfmt+0x2c>
  801404:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801407:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80140a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80140e:	89 14 24             	mov    %edx,(%esp)
  801411:	ff d7                	call   *%edi
  801413:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  801416:	e9 be fb ff ff       	jmp    800fd9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80141b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80141f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801426:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801428:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80142b:	80 38 25             	cmpb   $0x25,(%eax)
  80142e:	0f 84 a5 fb ff ff    	je     800fd9 <vprintfmt+0x2c>
  801434:	89 c3                	mov    %eax,%ebx
  801436:	eb f0                	jmp    801428 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  801438:	83 c4 5c             	add    $0x5c,%esp
  80143b:	5b                   	pop    %ebx
  80143c:	5e                   	pop    %esi
  80143d:	5f                   	pop    %edi
  80143e:	5d                   	pop    %ebp
  80143f:	c3                   	ret    

00801440 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801440:	55                   	push   %ebp
  801441:	89 e5                	mov    %esp,%ebp
  801443:	83 ec 28             	sub    $0x28,%esp
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80144c:	85 c0                	test   %eax,%eax
  80144e:	74 04                	je     801454 <vsnprintf+0x14>
  801450:	85 d2                	test   %edx,%edx
  801452:	7f 07                	jg     80145b <vsnprintf+0x1b>
  801454:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801459:	eb 3b                	jmp    801496 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80145b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80145e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  801462:	89 45 f0             	mov    %eax,-0x10(%ebp)
  801465:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80146c:	8b 45 14             	mov    0x14(%ebp),%eax
  80146f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801473:	8b 45 10             	mov    0x10(%ebp),%eax
  801476:	89 44 24 08          	mov    %eax,0x8(%esp)
  80147a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80147d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801481:	c7 04 24 90 0f 80 00 	movl   $0x800f90,(%esp)
  801488:	e8 20 fb ff ff       	call   800fad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80148d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801490:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801493:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  801496:	c9                   	leave  
  801497:	c3                   	ret    

00801498 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80149e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8014a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8014a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b6:	89 04 24             	mov    %eax,(%esp)
  8014b9:	e8 82 ff ff ff       	call   801440 <vsnprintf>
	va_end(ap);

	return rc;
}
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8014c6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8014c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	89 04 24             	mov    %eax,(%esp)
  8014e1:	e8 c7 fa ff ff       	call   800fad <vprintfmt>
	va_end(ap);
}
  8014e6:	c9                   	leave  
  8014e7:	c3                   	ret    
	...

008014f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8014f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8014fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8014fe:	74 09                	je     801509 <strlen+0x19>
		n++;
  801500:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801503:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801507:	75 f7                	jne    801500 <strlen+0x10>
		n++;
	return n;
}
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	53                   	push   %ebx
  80150f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801512:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801515:	85 c9                	test   %ecx,%ecx
  801517:	74 19                	je     801532 <strnlen+0x27>
  801519:	80 3b 00             	cmpb   $0x0,(%ebx)
  80151c:	74 14                	je     801532 <strnlen+0x27>
  80151e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  801523:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801526:	39 c8                	cmp    %ecx,%eax
  801528:	74 0d                	je     801537 <strnlen+0x2c>
  80152a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80152e:	75 f3                	jne    801523 <strnlen+0x18>
  801530:	eb 05                	jmp    801537 <strnlen+0x2c>
  801532:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  801537:	5b                   	pop    %ebx
  801538:	5d                   	pop    %ebp
  801539:	c3                   	ret    

0080153a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80153a:	55                   	push   %ebp
  80153b:	89 e5                	mov    %esp,%ebp
  80153d:	53                   	push   %ebx
  80153e:	8b 45 08             	mov    0x8(%ebp),%eax
  801541:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801544:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801549:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80154d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801550:	83 c2 01             	add    $0x1,%edx
  801553:	84 c9                	test   %cl,%cl
  801555:	75 f2                	jne    801549 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801557:	5b                   	pop    %ebx
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    

0080155a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	53                   	push   %ebx
  80155e:	83 ec 08             	sub    $0x8,%esp
  801561:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801564:	89 1c 24             	mov    %ebx,(%esp)
  801567:	e8 84 ff ff ff       	call   8014f0 <strlen>
	strcpy(dst + len, src);
  80156c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801573:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801576:	89 04 24             	mov    %eax,(%esp)
  801579:	e8 bc ff ff ff       	call   80153a <strcpy>
	return dst;
}
  80157e:	89 d8                	mov    %ebx,%eax
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	5b                   	pop    %ebx
  801584:	5d                   	pop    %ebp
  801585:	c3                   	ret    

00801586 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801586:	55                   	push   %ebp
  801587:	89 e5                	mov    %esp,%ebp
  801589:	56                   	push   %esi
  80158a:	53                   	push   %ebx
  80158b:	8b 45 08             	mov    0x8(%ebp),%eax
  80158e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801591:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801594:	85 f6                	test   %esi,%esi
  801596:	74 18                	je     8015b0 <strncpy+0x2a>
  801598:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80159d:	0f b6 1a             	movzbl (%edx),%ebx
  8015a0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8015a3:	80 3a 01             	cmpb   $0x1,(%edx)
  8015a6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8015a9:	83 c1 01             	add    $0x1,%ecx
  8015ac:	39 ce                	cmp    %ecx,%esi
  8015ae:	77 ed                	ja     80159d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	56                   	push   %esi
  8015b8:	53                   	push   %ebx
  8015b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8015bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8015c2:	89 f0                	mov    %esi,%eax
  8015c4:	85 c9                	test   %ecx,%ecx
  8015c6:	74 27                	je     8015ef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8015c8:	83 e9 01             	sub    $0x1,%ecx
  8015cb:	74 1d                	je     8015ea <strlcpy+0x36>
  8015cd:	0f b6 1a             	movzbl (%edx),%ebx
  8015d0:	84 db                	test   %bl,%bl
  8015d2:	74 16                	je     8015ea <strlcpy+0x36>
			*dst++ = *src++;
  8015d4:	88 18                	mov    %bl,(%eax)
  8015d6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8015d9:	83 e9 01             	sub    $0x1,%ecx
  8015dc:	74 0e                	je     8015ec <strlcpy+0x38>
			*dst++ = *src++;
  8015de:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8015e1:	0f b6 1a             	movzbl (%edx),%ebx
  8015e4:	84 db                	test   %bl,%bl
  8015e6:	75 ec                	jne    8015d4 <strlcpy+0x20>
  8015e8:	eb 02                	jmp    8015ec <strlcpy+0x38>
  8015ea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8015ec:	c6 00 00             	movb   $0x0,(%eax)
  8015ef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8015fe:	0f b6 01             	movzbl (%ecx),%eax
  801601:	84 c0                	test   %al,%al
  801603:	74 15                	je     80161a <strcmp+0x25>
  801605:	3a 02                	cmp    (%edx),%al
  801607:	75 11                	jne    80161a <strcmp+0x25>
		p++, q++;
  801609:	83 c1 01             	add    $0x1,%ecx
  80160c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80160f:	0f b6 01             	movzbl (%ecx),%eax
  801612:	84 c0                	test   %al,%al
  801614:	74 04                	je     80161a <strcmp+0x25>
  801616:	3a 02                	cmp    (%edx),%al
  801618:	74 ef                	je     801609 <strcmp+0x14>
  80161a:	0f b6 c0             	movzbl %al,%eax
  80161d:	0f b6 12             	movzbl (%edx),%edx
  801620:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801622:	5d                   	pop    %ebp
  801623:	c3                   	ret    

00801624 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801624:	55                   	push   %ebp
  801625:	89 e5                	mov    %esp,%ebp
  801627:	53                   	push   %ebx
  801628:	8b 55 08             	mov    0x8(%ebp),%edx
  80162b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80162e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  801631:	85 c0                	test   %eax,%eax
  801633:	74 23                	je     801658 <strncmp+0x34>
  801635:	0f b6 1a             	movzbl (%edx),%ebx
  801638:	84 db                	test   %bl,%bl
  80163a:	74 25                	je     801661 <strncmp+0x3d>
  80163c:	3a 19                	cmp    (%ecx),%bl
  80163e:	75 21                	jne    801661 <strncmp+0x3d>
  801640:	83 e8 01             	sub    $0x1,%eax
  801643:	74 13                	je     801658 <strncmp+0x34>
		n--, p++, q++;
  801645:	83 c2 01             	add    $0x1,%edx
  801648:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80164b:	0f b6 1a             	movzbl (%edx),%ebx
  80164e:	84 db                	test   %bl,%bl
  801650:	74 0f                	je     801661 <strncmp+0x3d>
  801652:	3a 19                	cmp    (%ecx),%bl
  801654:	74 ea                	je     801640 <strncmp+0x1c>
  801656:	eb 09                	jmp    801661 <strncmp+0x3d>
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80165d:	5b                   	pop    %ebx
  80165e:	5d                   	pop    %ebp
  80165f:	90                   	nop
  801660:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801661:	0f b6 02             	movzbl (%edx),%eax
  801664:	0f b6 11             	movzbl (%ecx),%edx
  801667:	29 d0                	sub    %edx,%eax
  801669:	eb f2                	jmp    80165d <strncmp+0x39>

0080166b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	8b 45 08             	mov    0x8(%ebp),%eax
  801671:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801675:	0f b6 10             	movzbl (%eax),%edx
  801678:	84 d2                	test   %dl,%dl
  80167a:	74 18                	je     801694 <strchr+0x29>
		if (*s == c)
  80167c:	38 ca                	cmp    %cl,%dl
  80167e:	75 0a                	jne    80168a <strchr+0x1f>
  801680:	eb 17                	jmp    801699 <strchr+0x2e>
  801682:	38 ca                	cmp    %cl,%dl
  801684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801688:	74 0f                	je     801699 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80168a:	83 c0 01             	add    $0x1,%eax
  80168d:	0f b6 10             	movzbl (%eax),%edx
  801690:	84 d2                	test   %dl,%dl
  801692:	75 ee                	jne    801682 <strchr+0x17>
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8016a5:	0f b6 10             	movzbl (%eax),%edx
  8016a8:	84 d2                	test   %dl,%dl
  8016aa:	74 18                	je     8016c4 <strfind+0x29>
		if (*s == c)
  8016ac:	38 ca                	cmp    %cl,%dl
  8016ae:	75 0a                	jne    8016ba <strfind+0x1f>
  8016b0:	eb 12                	jmp    8016c4 <strfind+0x29>
  8016b2:	38 ca                	cmp    %cl,%dl
  8016b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8016b8:	74 0a                	je     8016c4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8016ba:	83 c0 01             	add    $0x1,%eax
  8016bd:	0f b6 10             	movzbl (%eax),%edx
  8016c0:	84 d2                	test   %dl,%dl
  8016c2:	75 ee                	jne    8016b2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8016c4:	5d                   	pop    %ebp
  8016c5:	c3                   	ret    

008016c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8016c6:	55                   	push   %ebp
  8016c7:	89 e5                	mov    %esp,%ebp
  8016c9:	83 ec 0c             	sub    $0xc,%esp
  8016cc:	89 1c 24             	mov    %ebx,(%esp)
  8016cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8016d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8016e0:	85 c9                	test   %ecx,%ecx
  8016e2:	74 30                	je     801714 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8016e4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8016ea:	75 25                	jne    801711 <memset+0x4b>
  8016ec:	f6 c1 03             	test   $0x3,%cl
  8016ef:	75 20                	jne    801711 <memset+0x4b>
		c &= 0xFF;
  8016f1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8016f4:	89 d3                	mov    %edx,%ebx
  8016f6:	c1 e3 08             	shl    $0x8,%ebx
  8016f9:	89 d6                	mov    %edx,%esi
  8016fb:	c1 e6 18             	shl    $0x18,%esi
  8016fe:	89 d0                	mov    %edx,%eax
  801700:	c1 e0 10             	shl    $0x10,%eax
  801703:	09 f0                	or     %esi,%eax
  801705:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  801707:	09 d8                	or     %ebx,%eax
  801709:	c1 e9 02             	shr    $0x2,%ecx
  80170c:	fc                   	cld    
  80170d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80170f:	eb 03                	jmp    801714 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801711:	fc                   	cld    
  801712:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801714:	89 f8                	mov    %edi,%eax
  801716:	8b 1c 24             	mov    (%esp),%ebx
  801719:	8b 74 24 04          	mov    0x4(%esp),%esi
  80171d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801721:	89 ec                	mov    %ebp,%esp
  801723:	5d                   	pop    %ebp
  801724:	c3                   	ret    

00801725 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	89 34 24             	mov    %esi,(%esp)
  80172e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801738:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80173b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80173d:	39 c6                	cmp    %eax,%esi
  80173f:	73 35                	jae    801776 <memmove+0x51>
  801741:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801744:	39 d0                	cmp    %edx,%eax
  801746:	73 2e                	jae    801776 <memmove+0x51>
		s += n;
		d += n;
  801748:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80174a:	f6 c2 03             	test   $0x3,%dl
  80174d:	75 1b                	jne    80176a <memmove+0x45>
  80174f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801755:	75 13                	jne    80176a <memmove+0x45>
  801757:	f6 c1 03             	test   $0x3,%cl
  80175a:	75 0e                	jne    80176a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80175c:	83 ef 04             	sub    $0x4,%edi
  80175f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801762:	c1 e9 02             	shr    $0x2,%ecx
  801765:	fd                   	std    
  801766:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801768:	eb 09                	jmp    801773 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80176a:	83 ef 01             	sub    $0x1,%edi
  80176d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801770:	fd                   	std    
  801771:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801773:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801774:	eb 20                	jmp    801796 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801776:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80177c:	75 15                	jne    801793 <memmove+0x6e>
  80177e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801784:	75 0d                	jne    801793 <memmove+0x6e>
  801786:	f6 c1 03             	test   $0x3,%cl
  801789:	75 08                	jne    801793 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80178b:	c1 e9 02             	shr    $0x2,%ecx
  80178e:	fc                   	cld    
  80178f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801791:	eb 03                	jmp    801796 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801793:	fc                   	cld    
  801794:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801796:	8b 34 24             	mov    (%esp),%esi
  801799:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80179d:	89 ec                	mov    %ebp,%esp
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8017a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b8:	89 04 24             	mov    %eax,(%esp)
  8017bb:	e8 65 ff ff ff       	call   801725 <memmove>
}
  8017c0:	c9                   	leave  
  8017c1:	c3                   	ret    

008017c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	57                   	push   %edi
  8017c6:	56                   	push   %esi
  8017c7:	53                   	push   %ebx
  8017c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8017cb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017d1:	85 c9                	test   %ecx,%ecx
  8017d3:	74 36                	je     80180b <memcmp+0x49>
		if (*s1 != *s2)
  8017d5:	0f b6 06             	movzbl (%esi),%eax
  8017d8:	0f b6 1f             	movzbl (%edi),%ebx
  8017db:	38 d8                	cmp    %bl,%al
  8017dd:	74 20                	je     8017ff <memcmp+0x3d>
  8017df:	eb 14                	jmp    8017f5 <memcmp+0x33>
  8017e1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8017e6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8017eb:	83 c2 01             	add    $0x1,%edx
  8017ee:	83 e9 01             	sub    $0x1,%ecx
  8017f1:	38 d8                	cmp    %bl,%al
  8017f3:	74 12                	je     801807 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8017f5:	0f b6 c0             	movzbl %al,%eax
  8017f8:	0f b6 db             	movzbl %bl,%ebx
  8017fb:	29 d8                	sub    %ebx,%eax
  8017fd:	eb 11                	jmp    801810 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8017ff:	83 e9 01             	sub    $0x1,%ecx
  801802:	ba 00 00 00 00       	mov    $0x0,%edx
  801807:	85 c9                	test   %ecx,%ecx
  801809:	75 d6                	jne    8017e1 <memcmp+0x1f>
  80180b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801810:	5b                   	pop    %ebx
  801811:	5e                   	pop    %esi
  801812:	5f                   	pop    %edi
  801813:	5d                   	pop    %ebp
  801814:	c3                   	ret    

00801815 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801815:	55                   	push   %ebp
  801816:	89 e5                	mov    %esp,%ebp
  801818:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801820:	39 d0                	cmp    %edx,%eax
  801822:	73 15                	jae    801839 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  801824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  801828:	38 08                	cmp    %cl,(%eax)
  80182a:	75 06                	jne    801832 <memfind+0x1d>
  80182c:	eb 0b                	jmp    801839 <memfind+0x24>
  80182e:	38 08                	cmp    %cl,(%eax)
  801830:	74 07                	je     801839 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801832:	83 c0 01             	add    $0x1,%eax
  801835:	39 c2                	cmp    %eax,%edx
  801837:	77 f5                	ja     80182e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    

0080183b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80183b:	55                   	push   %ebp
  80183c:	89 e5                	mov    %esp,%ebp
  80183e:	57                   	push   %edi
  80183f:	56                   	push   %esi
  801840:	53                   	push   %ebx
  801841:	83 ec 04             	sub    $0x4,%esp
  801844:	8b 55 08             	mov    0x8(%ebp),%edx
  801847:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80184a:	0f b6 02             	movzbl (%edx),%eax
  80184d:	3c 20                	cmp    $0x20,%al
  80184f:	74 04                	je     801855 <strtol+0x1a>
  801851:	3c 09                	cmp    $0x9,%al
  801853:	75 0e                	jne    801863 <strtol+0x28>
		s++;
  801855:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801858:	0f b6 02             	movzbl (%edx),%eax
  80185b:	3c 20                	cmp    $0x20,%al
  80185d:	74 f6                	je     801855 <strtol+0x1a>
  80185f:	3c 09                	cmp    $0x9,%al
  801861:	74 f2                	je     801855 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801863:	3c 2b                	cmp    $0x2b,%al
  801865:	75 0c                	jne    801873 <strtol+0x38>
		s++;
  801867:	83 c2 01             	add    $0x1,%edx
  80186a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801871:	eb 15                	jmp    801888 <strtol+0x4d>
	else if (*s == '-')
  801873:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80187a:	3c 2d                	cmp    $0x2d,%al
  80187c:	75 0a                	jne    801888 <strtol+0x4d>
		s++, neg = 1;
  80187e:	83 c2 01             	add    $0x1,%edx
  801881:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801888:	85 db                	test   %ebx,%ebx
  80188a:	0f 94 c0             	sete   %al
  80188d:	74 05                	je     801894 <strtol+0x59>
  80188f:	83 fb 10             	cmp    $0x10,%ebx
  801892:	75 18                	jne    8018ac <strtol+0x71>
  801894:	80 3a 30             	cmpb   $0x30,(%edx)
  801897:	75 13                	jne    8018ac <strtol+0x71>
  801899:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80189d:	8d 76 00             	lea    0x0(%esi),%esi
  8018a0:	75 0a                	jne    8018ac <strtol+0x71>
		s += 2, base = 16;
  8018a2:	83 c2 02             	add    $0x2,%edx
  8018a5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8018aa:	eb 15                	jmp    8018c1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8018ac:	84 c0                	test   %al,%al
  8018ae:	66 90                	xchg   %ax,%ax
  8018b0:	74 0f                	je     8018c1 <strtol+0x86>
  8018b2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  8018b7:	80 3a 30             	cmpb   $0x30,(%edx)
  8018ba:	75 05                	jne    8018c1 <strtol+0x86>
		s++, base = 8;
  8018bc:	83 c2 01             	add    $0x1,%edx
  8018bf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8018c8:	0f b6 0a             	movzbl (%edx),%ecx
  8018cb:	89 cf                	mov    %ecx,%edi
  8018cd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8018d0:	80 fb 09             	cmp    $0x9,%bl
  8018d3:	77 08                	ja     8018dd <strtol+0xa2>
			dig = *s - '0';
  8018d5:	0f be c9             	movsbl %cl,%ecx
  8018d8:	83 e9 30             	sub    $0x30,%ecx
  8018db:	eb 1e                	jmp    8018fb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8018dd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8018e0:	80 fb 19             	cmp    $0x19,%bl
  8018e3:	77 08                	ja     8018ed <strtol+0xb2>
			dig = *s - 'a' + 10;
  8018e5:	0f be c9             	movsbl %cl,%ecx
  8018e8:	83 e9 57             	sub    $0x57,%ecx
  8018eb:	eb 0e                	jmp    8018fb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8018ed:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8018f0:	80 fb 19             	cmp    $0x19,%bl
  8018f3:	77 15                	ja     80190a <strtol+0xcf>
			dig = *s - 'A' + 10;
  8018f5:	0f be c9             	movsbl %cl,%ecx
  8018f8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8018fb:	39 f1                	cmp    %esi,%ecx
  8018fd:	7d 0b                	jge    80190a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8018ff:	83 c2 01             	add    $0x1,%edx
  801902:	0f af c6             	imul   %esi,%eax
  801905:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801908:	eb be                	jmp    8018c8 <strtol+0x8d>
  80190a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80190c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801910:	74 05                	je     801917 <strtol+0xdc>
		*endptr = (char *) s;
  801912:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801915:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801917:	89 ca                	mov    %ecx,%edx
  801919:	f7 da                	neg    %edx
  80191b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80191f:	0f 45 c2             	cmovne %edx,%eax
}
  801922:	83 c4 04             	add    $0x4,%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5f                   	pop    %edi
  801928:	5d                   	pop    %ebp
  801929:	c3                   	ret    
  80192a:	00 00                	add    %al,(%eax)
  80192c:	00 00                	add    %al,(%eax)
	...

00801930 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801936:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80193c:	b8 01 00 00 00       	mov    $0x1,%eax
  801941:	39 ca                	cmp    %ecx,%edx
  801943:	75 04                	jne    801949 <ipc_find_env+0x19>
  801945:	b0 00                	mov    $0x0,%al
  801947:	eb 0f                	jmp    801958 <ipc_find_env+0x28>
  801949:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80194c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801952:	8b 12                	mov    (%edx),%edx
  801954:	39 ca                	cmp    %ecx,%edx
  801956:	75 0c                	jne    801964 <ipc_find_env+0x34>
			return envs[i].env_id;
  801958:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80195b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801960:	8b 00                	mov    (%eax),%eax
  801962:	eb 0e                	jmp    801972 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801964:	83 c0 01             	add    $0x1,%eax
  801967:	3d 00 04 00 00       	cmp    $0x400,%eax
  80196c:	75 db                	jne    801949 <ipc_find_env+0x19>
  80196e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	57                   	push   %edi
  801978:	56                   	push   %esi
  801979:	53                   	push   %ebx
  80197a:	83 ec 1c             	sub    $0x1c,%esp
  80197d:	8b 75 08             	mov    0x8(%ebp),%esi
  801980:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801986:	85 db                	test   %ebx,%ebx
  801988:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80198d:	0f 44 d8             	cmove  %eax,%ebx
  801990:	eb 29                	jmp    8019bb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801992:	85 c0                	test   %eax,%eax
  801994:	79 25                	jns    8019bb <ipc_send+0x47>
  801996:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801999:	74 20                	je     8019bb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  80199b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80199f:	c7 44 24 08 a0 21 80 	movl   $0x8021a0,0x8(%esp)
  8019a6:	00 
  8019a7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8019ae:	00 
  8019af:	c7 04 24 be 21 80 00 	movl   $0x8021be,(%esp)
  8019b6:	e8 85 f3 ff ff       	call   800d40 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8019bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019ca:	89 34 24             	mov    %esi,(%esp)
  8019cd:	e8 95 e7 ff ff       	call   800167 <sys_ipc_try_send>
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	75 bc                	jne    801992 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8019d6:	e8 12 e9 ff ff       	call   8002ed <sys_yield>
}
  8019db:	83 c4 1c             	add    $0x1c,%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5f                   	pop    %edi
  8019e1:	5d                   	pop    %ebp
  8019e2:	c3                   	ret    

008019e3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 28             	sub    $0x28,%esp
  8019e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a02:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801a05:	89 04 24             	mov    %eax,(%esp)
  801a08:	e8 21 e7 ff ff       	call   80012e <sys_ipc_recv>
  801a0d:	89 c3                	mov    %eax,%ebx
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	79 2a                	jns    801a3d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801a13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1b:	c7 04 24 c8 21 80 00 	movl   $0x8021c8,(%esp)
  801a22:	e8 d2 f3 ff ff       	call   800df9 <cprintf>
		if(from_env_store != NULL)
  801a27:	85 f6                	test   %esi,%esi
  801a29:	74 06                	je     801a31 <ipc_recv+0x4e>
			*from_env_store = 0;
  801a2b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801a31:	85 ff                	test   %edi,%edi
  801a33:	74 2d                	je     801a62 <ipc_recv+0x7f>
			*perm_store = 0;
  801a35:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a3b:	eb 25                	jmp    801a62 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801a3d:	85 f6                	test   %esi,%esi
  801a3f:	90                   	nop
  801a40:	74 0a                	je     801a4c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 40 74             	mov    0x74(%eax),%eax
  801a4a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801a4c:	85 ff                	test   %edi,%edi
  801a4e:	74 0a                	je     801a5a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 40 78             	mov    0x78(%eax),%eax
  801a58:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a67:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a6a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a6d:	89 ec                	mov    %ebp,%esp
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    
	...

00801a80 <__udivdi3>:
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	83 ec 10             	sub    $0x10,%esp
  801a88:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a8e:	8b 75 10             	mov    0x10(%ebp),%esi
  801a91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a94:	85 c0                	test   %eax,%eax
  801a96:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801a99:	75 35                	jne    801ad0 <__udivdi3+0x50>
  801a9b:	39 fe                	cmp    %edi,%esi
  801a9d:	77 61                	ja     801b00 <__udivdi3+0x80>
  801a9f:	85 f6                	test   %esi,%esi
  801aa1:	75 0b                	jne    801aae <__udivdi3+0x2e>
  801aa3:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa8:	31 d2                	xor    %edx,%edx
  801aaa:	f7 f6                	div    %esi
  801aac:	89 c6                	mov    %eax,%esi
  801aae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ab1:	31 d2                	xor    %edx,%edx
  801ab3:	89 f8                	mov    %edi,%eax
  801ab5:	f7 f6                	div    %esi
  801ab7:	89 c7                	mov    %eax,%edi
  801ab9:	89 c8                	mov    %ecx,%eax
  801abb:	f7 f6                	div    %esi
  801abd:	89 c1                	mov    %eax,%ecx
  801abf:	89 fa                	mov    %edi,%edx
  801ac1:	89 c8                	mov    %ecx,%eax
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	5e                   	pop    %esi
  801ac7:	5f                   	pop    %edi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    
  801aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ad0:	39 f8                	cmp    %edi,%eax
  801ad2:	77 1c                	ja     801af0 <__udivdi3+0x70>
  801ad4:	0f bd d0             	bsr    %eax,%edx
  801ad7:	83 f2 1f             	xor    $0x1f,%edx
  801ada:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801add:	75 39                	jne    801b18 <__udivdi3+0x98>
  801adf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ae2:	0f 86 a0 00 00 00    	jbe    801b88 <__udivdi3+0x108>
  801ae8:	39 f8                	cmp    %edi,%eax
  801aea:	0f 82 98 00 00 00    	jb     801b88 <__udivdi3+0x108>
  801af0:	31 ff                	xor    %edi,%edi
  801af2:	31 c9                	xor    %ecx,%ecx
  801af4:	89 c8                	mov    %ecx,%eax
  801af6:	89 fa                	mov    %edi,%edx
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	5e                   	pop    %esi
  801afc:	5f                   	pop    %edi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    
  801aff:	90                   	nop
  801b00:	89 d1                	mov    %edx,%ecx
  801b02:	89 fa                	mov    %edi,%edx
  801b04:	89 c8                	mov    %ecx,%eax
  801b06:	31 ff                	xor    %edi,%edi
  801b08:	f7 f6                	div    %esi
  801b0a:	89 c1                	mov    %eax,%ecx
  801b0c:	89 fa                	mov    %edi,%edx
  801b0e:	89 c8                	mov    %ecx,%eax
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	5e                   	pop    %esi
  801b14:	5f                   	pop    %edi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    
  801b17:	90                   	nop
  801b18:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b1c:	89 f2                	mov    %esi,%edx
  801b1e:	d3 e0                	shl    %cl,%eax
  801b20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b23:	b8 20 00 00 00       	mov    $0x20,%eax
  801b28:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b2b:	89 c1                	mov    %eax,%ecx
  801b2d:	d3 ea                	shr    %cl,%edx
  801b2f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b33:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b36:	d3 e6                	shl    %cl,%esi
  801b38:	89 c1                	mov    %eax,%ecx
  801b3a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b3d:	89 fe                	mov    %edi,%esi
  801b3f:	d3 ee                	shr    %cl,%esi
  801b41:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b45:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b4b:	d3 e7                	shl    %cl,%edi
  801b4d:	89 c1                	mov    %eax,%ecx
  801b4f:	d3 ea                	shr    %cl,%edx
  801b51:	09 d7                	or     %edx,%edi
  801b53:	89 f2                	mov    %esi,%edx
  801b55:	89 f8                	mov    %edi,%eax
  801b57:	f7 75 ec             	divl   -0x14(%ebp)
  801b5a:	89 d6                	mov    %edx,%esi
  801b5c:	89 c7                	mov    %eax,%edi
  801b5e:	f7 65 e8             	mull   -0x18(%ebp)
  801b61:	39 d6                	cmp    %edx,%esi
  801b63:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b66:	72 30                	jb     801b98 <__udivdi3+0x118>
  801b68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b6b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b6f:	d3 e2                	shl    %cl,%edx
  801b71:	39 c2                	cmp    %eax,%edx
  801b73:	73 05                	jae    801b7a <__udivdi3+0xfa>
  801b75:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b78:	74 1e                	je     801b98 <__udivdi3+0x118>
  801b7a:	89 f9                	mov    %edi,%ecx
  801b7c:	31 ff                	xor    %edi,%edi
  801b7e:	e9 71 ff ff ff       	jmp    801af4 <__udivdi3+0x74>
  801b83:	90                   	nop
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	31 ff                	xor    %edi,%edi
  801b8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801b8f:	e9 60 ff ff ff       	jmp    801af4 <__udivdi3+0x74>
  801b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b98:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801b9b:	31 ff                	xor    %edi,%edi
  801b9d:	89 c8                	mov    %ecx,%eax
  801b9f:	89 fa                	mov    %edi,%edx
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
	...

00801bb0 <__umoddi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	83 ec 20             	sub    $0x20,%esp
  801bb8:	8b 55 14             	mov    0x14(%ebp),%edx
  801bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc4:	85 d2                	test   %edx,%edx
  801bc6:	89 c8                	mov    %ecx,%eax
  801bc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bcb:	75 13                	jne    801be0 <__umoddi3+0x30>
  801bcd:	39 f7                	cmp    %esi,%edi
  801bcf:	76 3f                	jbe    801c10 <__umoddi3+0x60>
  801bd1:	89 f2                	mov    %esi,%edx
  801bd3:	f7 f7                	div    %edi
  801bd5:	89 d0                	mov    %edx,%eax
  801bd7:	31 d2                	xor    %edx,%edx
  801bd9:	83 c4 20             	add    $0x20,%esp
  801bdc:	5e                   	pop    %esi
  801bdd:	5f                   	pop    %edi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    
  801be0:	39 f2                	cmp    %esi,%edx
  801be2:	77 4c                	ja     801c30 <__umoddi3+0x80>
  801be4:	0f bd ca             	bsr    %edx,%ecx
  801be7:	83 f1 1f             	xor    $0x1f,%ecx
  801bea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bed:	75 51                	jne    801c40 <__umoddi3+0x90>
  801bef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801bf2:	0f 87 e0 00 00 00    	ja     801cd8 <__umoddi3+0x128>
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	29 f8                	sub    %edi,%eax
  801bfd:	19 d6                	sbb    %edx,%esi
  801bff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 f2                	mov    %esi,%edx
  801c07:	83 c4 20             	add    $0x20,%esp
  801c0a:	5e                   	pop    %esi
  801c0b:	5f                   	pop    %edi
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    
  801c0e:	66 90                	xchg   %ax,%ax
  801c10:	85 ff                	test   %edi,%edi
  801c12:	75 0b                	jne    801c1f <__umoddi3+0x6f>
  801c14:	b8 01 00 00 00       	mov    $0x1,%eax
  801c19:	31 d2                	xor    %edx,%edx
  801c1b:	f7 f7                	div    %edi
  801c1d:	89 c7                	mov    %eax,%edi
  801c1f:	89 f0                	mov    %esi,%eax
  801c21:	31 d2                	xor    %edx,%edx
  801c23:	f7 f7                	div    %edi
  801c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c28:	f7 f7                	div    %edi
  801c2a:	eb a9                	jmp    801bd5 <__umoddi3+0x25>
  801c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 c8                	mov    %ecx,%eax
  801c32:	89 f2                	mov    %esi,%edx
  801c34:	83 c4 20             	add    $0x20,%esp
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    
  801c3b:	90                   	nop
  801c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c40:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c44:	d3 e2                	shl    %cl,%edx
  801c46:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c49:	ba 20 00 00 00       	mov    $0x20,%edx
  801c4e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c51:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c54:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	d3 ea                	shr    %cl,%edx
  801c5c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c60:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c63:	d3 e7                	shl    %cl,%edi
  801c65:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c69:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c6c:	89 f2                	mov    %esi,%edx
  801c6e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c71:	89 c7                	mov    %eax,%edi
  801c73:	d3 ea                	shr    %cl,%edx
  801c75:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c7c:	89 c2                	mov    %eax,%edx
  801c7e:	d3 e6                	shl    %cl,%esi
  801c80:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c84:	d3 ea                	shr    %cl,%edx
  801c86:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c8a:	09 d6                	or     %edx,%esi
  801c8c:	89 f0                	mov    %esi,%eax
  801c8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801c91:	d3 e7                	shl    %cl,%edi
  801c93:	89 f2                	mov    %esi,%edx
  801c95:	f7 75 f4             	divl   -0xc(%ebp)
  801c98:	89 d6                	mov    %edx,%esi
  801c9a:	f7 65 e8             	mull   -0x18(%ebp)
  801c9d:	39 d6                	cmp    %edx,%esi
  801c9f:	72 2b                	jb     801ccc <__umoddi3+0x11c>
  801ca1:	39 c7                	cmp    %eax,%edi
  801ca3:	72 23                	jb     801cc8 <__umoddi3+0x118>
  801ca5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ca9:	29 c7                	sub    %eax,%edi
  801cab:	19 d6                	sbb    %edx,%esi
  801cad:	89 f0                	mov    %esi,%eax
  801caf:	89 f2                	mov    %esi,%edx
  801cb1:	d3 ef                	shr    %cl,%edi
  801cb3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cb7:	d3 e0                	shl    %cl,%eax
  801cb9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cbd:	09 f8                	or     %edi,%eax
  801cbf:	d3 ea                	shr    %cl,%edx
  801cc1:	83 c4 20             	add    $0x20,%esp
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	39 d6                	cmp    %edx,%esi
  801cca:	75 d9                	jne    801ca5 <__umoddi3+0xf5>
  801ccc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801ccf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801cd2:	eb d1                	jmp    801ca5 <__umoddi3+0xf5>
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	0f 82 18 ff ff ff    	jb     801bf8 <__umoddi3+0x48>
  801ce0:	e9 1d ff ff ff       	jmp    801c02 <__umoddi3+0x52>
