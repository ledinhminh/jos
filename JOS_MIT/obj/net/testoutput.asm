
obj/net/testoutput:     file format elf32-i386


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
  80002c:	e8 67 02 00 00       	call   800298 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
static struct jif_pkt *pkt = (struct jif_pkt*)REQVA;


void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	envid_t ns_envid = sys_getenvid();
  800048:	e8 ba 11 00 00       	call   801207 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
	int i, r;

	binaryname = "testoutput";
  80004f:	c7 05 00 40 80 00 e0 	movl   $0x8029e0,0x804000
  800056:	29 80 00 

	output_envid = fork();
  800059:	e8 b4 12 00 00       	call   801312 <fork>
  80005e:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800063:	85 c0                	test   %eax,%eax
  800065:	79 1c                	jns    800083 <umain+0x43>
		panic("error forking");
  800067:	c7 44 24 08 eb 29 80 	movl   $0x8029eb,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 f9 29 80 00 	movl   $0x8029f9,(%esp)
  80007e:	e8 81 02 00 00       	call   800304 <_panic>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
  800083:	bb 00 00 00 00       	mov    $0x0,%ebx
	binaryname = "testoutput";

	output_envid = fork();
	if (output_envid < 0)
		panic("error forking");
	else if (output_envid == 0) {
  800088:	85 c0                	test   %eax,%eax
  80008a:	75 0d                	jne    800099 <umain+0x59>
		output(ns_envid);
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 b4 01 00 00       	call   800248 <output>
		return;
  800094:	e9 c9 00 00 00       	jmp    800162 <umain+0x122>
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
		if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800099:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8000a0:	00 
  8000a1:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  8000a8:	0f 
  8000a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b0:	e8 a8 10 00 00       	call   80115d <sys_page_alloc>
  8000b5:	85 c0                	test   %eax,%eax
  8000b7:	79 20                	jns    8000d9 <umain+0x99>
			panic("sys_page_alloc: %e", r);
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	c7 44 24 08 0a 2a 80 	movl   $0x802a0a,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 f9 29 80 00 	movl   $0x8029f9,(%esp)
  8000d4:	e8 2b 02 00 00       	call   800304 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000dd:	c7 44 24 08 1d 2a 80 	movl   $0x802a1d,0x8(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 04 fc 0f 00 	movl   $0xffc,0x4(%esp)
  8000ec:	00 
  8000ed:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  8000f4:	e8 5f 09 00 00       	call   800a58 <snprintf>
  8000f9:	a3 00 b0 fe 0f       	mov    %eax,0xffeb000
				       PGSIZE - sizeof(pkt->jp_len),
				       "Packet %02d", i);
		cprintf("Transmitting packet %d\n", i);
  8000fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800102:	c7 04 24 29 2a 80 00 	movl   $0x802a29,(%esp)
  800109:	e8 af 02 00 00       	call   8003bd <cprintf>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  80010e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800115:	00 
  800116:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  80011d:	0f 
  80011e:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  800125:	00 
  800126:	a1 00 50 80 00       	mov    0x805000,%eax
  80012b:	89 04 24             	mov    %eax,(%esp)
  80012e:	e8 56 16 00 00       	call   801789 <ipc_send>
		sys_page_unmap(0, pkt);
  800133:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  80013a:	0f 
  80013b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800142:	e8 a5 0f 00 00       	call   8010ec <sys_page_unmap>
	else if (output_envid == 0) {
		output(ns_envid);
		return;
	}

	for (i = 0; i < TESTOUTPUT_COUNT; i++) {
  800147:	83 c3 01             	add    $0x1,%ebx
  80014a:	83 fb 0a             	cmp    $0xa,%ebx
  80014d:	0f 85 46 ff ff ff    	jne    800099 <umain+0x59>
  800153:	b3 00                	mov    $0x0,%bl
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
		sys_yield();
  800155:	e8 3a 10 00 00       	call   801194 <sys_yield>
		ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
		sys_page_unmap(0, pkt);
	}

	// Spin for a while, just in case IPC's or packets need to be flushed
	for (i = 0; i < TESTOUTPUT_COUNT*2; i++)
  80015a:	83 c3 01             	add    $0x1,%ebx
  80015d:	83 fb 14             	cmp    $0x14,%ebx
  800160:	75 f3                	jne    800155 <umain+0x115>
		sys_yield();
}
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5d                   	pop    %ebp
  800168:	c3                   	ret    
  800169:	00 00                	add    %al,(%eax)
  80016b:	00 00                	add    %al,(%eax)
  80016d:	00 00                	add    %al,(%eax)
	...

00800170 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 2c             	sub    $0x2c,%esp
  800179:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  80017c:	e8 19 0e 00 00       	call   800f9a <sys_time_msec>
  800181:	89 c3                	mov    %eax,%ebx
  800183:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800186:	c7 05 00 40 80 00 41 	movl   $0x802a41,0x804000
  80018d:	2a 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800190:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800193:	eb 05                	jmp    80019a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800195:	e8 fa 0f 00 00       	call   801194 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80019a:	e8 fb 0d 00 00       	call   800f9a <sys_time_msec>
  80019f:	39 c3                	cmp    %eax,%ebx
  8001a1:	76 07                	jbe    8001aa <timer+0x3a>
  8001a3:	85 c0                	test   %eax,%eax
  8001a5:	79 ee                	jns    800195 <timer+0x25>
  8001a7:	90                   	nop
  8001a8:	eb 08                	jmp    8001b2 <timer+0x42>
			sys_yield();
		}
		if (r < 0)
  8001aa:	85 c0                	test   %eax,%eax
  8001ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8001b0:	79 20                	jns    8001d2 <timer+0x62>
			panic("sys_time_msec: %e", r);
  8001b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001b6:	c7 44 24 08 4a 2a 80 	movl   $0x802a4a,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 5c 2a 80 00 	movl   $0x802a5c,(%esp)
  8001cd:	e8 32 01 00 00       	call   800304 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d9:	00 
  8001da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e1:	00 
  8001e2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001e9:	00 
  8001ea:	89 34 24             	mov    %esi,(%esp)
  8001ed:	e8 97 15 00 00       	call   801789 <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800201:	00 
  800202:	89 3c 24             	mov    %edi,(%esp)
  800205:	e8 ea 15 00 00       	call   8017f4 <ipc_recv>
  80020a:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  80020c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020f:	39 c6                	cmp    %eax,%esi
  800211:	74 12                	je     800225 <timer+0xb5>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	c7 04 24 68 2a 80 00 	movl   $0x802a68,(%esp)
  80021e:	e8 9a 01 00 00       	call   8003bd <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  800223:	eb cd                	jmp    8001f2 <timer+0x82>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800225:	e8 70 0d 00 00       	call   800f9a <sys_time_msec>
  80022a:	01 c3                	add    %eax,%ebx
  80022c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800230:	e9 65 ff ff ff       	jmp    80019a <timer+0x2a>
  800235:	00 00                	add    %al,(%eax)
	...

00800238 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  80023b:	c7 05 00 40 80 00 a3 	movl   $0x802aa3,0x804000
  800242:	2a 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    
	...

00800248 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 10             	sub    $0x10,%esp
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
	binaryname = "ns_output";
  800253:	c7 05 00 40 80 00 ac 	movl   $0x802aac,0x804000
  80025a:	2a 80 00 
	// 	- read a packet from the network server
	//	- send the packet to the device driver
    int r;

    while (1) {
        r = sys_ipc_recv(&nsipcbuf);
  80025d:	bb 00 70 80 00       	mov    $0x807000,%ebx
  800262:	89 1c 24             	mov    %ebx,(%esp)
  800265:	e8 6b 0d 00 00       	call   800fd5 <sys_ipc_recv>
        if ((thisenv->env_ipc_from != ns_envid) ||
  80026a:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80026f:	8b 50 74             	mov    0x74(%eax),%edx
  800272:	39 f2                	cmp    %esi,%edx
  800274:	75 ec                	jne    800262 <output+0x1a>
            (thisenv->env_ipc_value != NSREQ_OUTPUT)) {
  800276:	8b 40 70             	mov    0x70(%eax),%eax
	//	- send the packet to the device driver
    int r;

    while (1) {
        r = sys_ipc_recv(&nsipcbuf);
        if ((thisenv->env_ipc_from != ns_envid) ||
  800279:	83 f8 0b             	cmp    $0xb,%eax
  80027c:	75 e4                	jne    800262 <output+0x1a>
            (thisenv->env_ipc_value != NSREQ_OUTPUT)) {
            continue;
        }

        while ((r = sys_net_try_send(nsipcbuf.pkt.jp_data,
  80027e:	8b 03                	mov    (%ebx),%eax
  800280:	89 44 24 04          	mov    %eax,0x4(%esp)
  800284:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80028b:	e8 d2 0c 00 00       	call   800f62 <sys_net_try_send>
  800290:	85 c0                	test   %eax,%eax
  800292:	78 ea                	js     80027e <output+0x36>
  800294:	eb cc                	jmp    800262 <output+0x1a>
	...

00800298 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	83 ec 18             	sub    $0x18,%esp
  80029e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8002a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8002a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8002aa:	e8 58 0f 00 00       	call   801207 <sys_getenvid>
  8002af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002b4:	c1 e0 07             	shl    $0x7,%eax
  8002b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002bc:	a3 0c 50 80 00       	mov    %eax,0x80500c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002c1:	85 f6                	test   %esi,%esi
  8002c3:	7e 07                	jle    8002cc <libmain+0x34>
		binaryname = argv[0];
  8002c5:	8b 03                	mov    (%ebx),%eax
  8002c7:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8002cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d0:	89 34 24             	mov    %esi,(%esp)
  8002d3:	e8 68 fd ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8002d8:	e8 0b 00 00 00       	call   8002e8 <exit>
}
  8002dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8002e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8002e3:	89 ec                	mov    %ebp,%esp
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    
	...

008002e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002ee:	e8 86 1a 00 00       	call   801d79 <close_all>
	sys_env_destroy(0);
  8002f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002fa:	e8 43 0f 00 00       	call   801242 <sys_env_destroy>
}
  8002ff:	c9                   	leave  
  800300:	c3                   	ret    
  800301:	00 00                	add    %al,(%eax)
	...

00800304 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	56                   	push   %esi
  800308:	53                   	push   %ebx
  800309:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80030c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80030f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800315:	e8 ed 0e 00 00       	call   801207 <sys_getenvid>
  80031a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800328:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80032c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800330:	c7 04 24 c0 2a 80 00 	movl   $0x802ac0,(%esp)
  800337:	e8 81 00 00 00       	call   8003bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800340:	8b 45 10             	mov    0x10(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	e8 11 00 00 00       	call   80035c <vcprintf>
	cprintf("\n");
  80034b:	c7 04 24 3f 2a 80 00 	movl   $0x802a3f,(%esp)
  800352:	e8 66 00 00 00       	call   8003bd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800357:	cc                   	int3   
  800358:	eb fd                	jmp    800357 <_panic+0x53>
	...

0080035c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80035c:	55                   	push   %ebp
  80035d:	89 e5                	mov    %esp,%ebp
  80035f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800365:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80036c:	00 00 00 
	b.cnt = 0;
  80036f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800376:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800379:	8b 45 0c             	mov    0xc(%ebp),%eax
  80037c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800380:	8b 45 08             	mov    0x8(%ebp),%eax
  800383:	89 44 24 08          	mov    %eax,0x8(%esp)
  800387:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80038d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800391:	c7 04 24 d7 03 80 00 	movl   $0x8003d7,(%esp)
  800398:	e8 d0 01 00 00       	call   80056d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80039d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8003a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ad:	89 04 24             	mov    %eax,(%esp)
  8003b0:	e8 01 0f 00 00       	call   8012b6 <sys_cputs>

	return b.cnt;
}
  8003b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8003c3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8003c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	89 04 24             	mov    %eax,(%esp)
  8003d0:	e8 87 ff ff ff       	call   80035c <vcprintf>
	va_end(ap);

	return cnt;
}
  8003d5:	c9                   	leave  
  8003d6:	c3                   	ret    

008003d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	53                   	push   %ebx
  8003db:	83 ec 14             	sub    $0x14,%esp
  8003de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003e1:	8b 03                	mov    (%ebx),%eax
  8003e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8003ea:	83 c0 01             	add    $0x1,%eax
  8003ed:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003f4:	75 19                	jne    80040f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003f6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003fd:	00 
  8003fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800401:	89 04 24             	mov    %eax,(%esp)
  800404:	e8 ad 0e 00 00       	call   8012b6 <sys_cputs>
		b->idx = 0;
  800409:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80040f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800413:	83 c4 14             	add    $0x14,%esp
  800416:	5b                   	pop    %ebx
  800417:	5d                   	pop    %ebp
  800418:	c3                   	ret    
  800419:	00 00                	add    %al,(%eax)
  80041b:	00 00                	add    %al,(%eax)
  80041d:	00 00                	add    %al,(%eax)
	...

00800420 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	57                   	push   %edi
  800424:	56                   	push   %esi
  800425:	53                   	push   %ebx
  800426:	83 ec 4c             	sub    $0x4c,%esp
  800429:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042c:	89 d6                	mov    %edx,%esi
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800434:	8b 55 0c             	mov    0xc(%ebp),%edx
  800437:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043a:	8b 45 10             	mov    0x10(%ebp),%eax
  80043d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800440:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800443:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800446:	b9 00 00 00 00       	mov    $0x0,%ecx
  80044b:	39 d1                	cmp    %edx,%ecx
  80044d:	72 15                	jb     800464 <printnum+0x44>
  80044f:	77 07                	ja     800458 <printnum+0x38>
  800451:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800454:	39 d0                	cmp    %edx,%eax
  800456:	76 0c                	jbe    800464 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800458:	83 eb 01             	sub    $0x1,%ebx
  80045b:	85 db                	test   %ebx,%ebx
  80045d:	8d 76 00             	lea    0x0(%esi),%esi
  800460:	7f 61                	jg     8004c3 <printnum+0xa3>
  800462:	eb 70                	jmp    8004d4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800464:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800468:	83 eb 01             	sub    $0x1,%ebx
  80046b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80046f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800473:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800477:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80047b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80047e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800481:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800484:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800488:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80048f:	00 
  800490:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800499:	89 54 24 04          	mov    %edx,0x4(%esp)
  80049d:	e8 be 22 00 00       	call   802760 <__udivdi3>
  8004a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8004a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8004a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8004ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004b0:	89 04 24             	mov    %eax,(%esp)
  8004b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8004b7:	89 f2                	mov    %esi,%edx
  8004b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004bc:	e8 5f ff ff ff       	call   800420 <printnum>
  8004c1:	eb 11                	jmp    8004d4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c7:	89 3c 24             	mov    %edi,(%esp)
  8004ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8004cd:	83 eb 01             	sub    $0x1,%ebx
  8004d0:	85 db                	test   %ebx,%ebx
  8004d2:	7f ef                	jg     8004c3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8004dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004ea:	00 
  8004eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ee:	89 14 24             	mov    %edx,(%esp)
  8004f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f8:	e8 93 23 00 00       	call   802890 <__umoddi3>
  8004fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800501:	0f be 80 e3 2a 80 00 	movsbl 0x802ae3(%eax),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80050e:	83 c4 4c             	add    $0x4c,%esp
  800511:	5b                   	pop    %ebx
  800512:	5e                   	pop    %esi
  800513:	5f                   	pop    %edi
  800514:	5d                   	pop    %ebp
  800515:	c3                   	ret    

00800516 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800519:	83 fa 01             	cmp    $0x1,%edx
  80051c:	7e 0e                	jle    80052c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80051e:	8b 10                	mov    (%eax),%edx
  800520:	8d 4a 08             	lea    0x8(%edx),%ecx
  800523:	89 08                	mov    %ecx,(%eax)
  800525:	8b 02                	mov    (%edx),%eax
  800527:	8b 52 04             	mov    0x4(%edx),%edx
  80052a:	eb 22                	jmp    80054e <getuint+0x38>
	else if (lflag)
  80052c:	85 d2                	test   %edx,%edx
  80052e:	74 10                	je     800540 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800530:	8b 10                	mov    (%eax),%edx
  800532:	8d 4a 04             	lea    0x4(%edx),%ecx
  800535:	89 08                	mov    %ecx,(%eax)
  800537:	8b 02                	mov    (%edx),%eax
  800539:	ba 00 00 00 00       	mov    $0x0,%edx
  80053e:	eb 0e                	jmp    80054e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800540:	8b 10                	mov    (%eax),%edx
  800542:	8d 4a 04             	lea    0x4(%edx),%ecx
  800545:	89 08                	mov    %ecx,(%eax)
  800547:	8b 02                	mov    (%edx),%eax
  800549:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80054e:	5d                   	pop    %ebp
  80054f:	c3                   	ret    

00800550 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800556:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	3b 50 04             	cmp    0x4(%eax),%edx
  80055f:	73 0a                	jae    80056b <sprintputch+0x1b>
		*b->buf++ = ch;
  800561:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800564:	88 0a                	mov    %cl,(%edx)
  800566:	83 c2 01             	add    $0x1,%edx
  800569:	89 10                	mov    %edx,(%eax)
}
  80056b:	5d                   	pop    %ebp
  80056c:	c3                   	ret    

0080056d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80056d:	55                   	push   %ebp
  80056e:	89 e5                	mov    %esp,%ebp
  800570:	57                   	push   %edi
  800571:	56                   	push   %esi
  800572:	53                   	push   %ebx
  800573:	83 ec 5c             	sub    $0x5c,%esp
  800576:	8b 7d 08             	mov    0x8(%ebp),%edi
  800579:	8b 75 0c             	mov    0xc(%ebp),%esi
  80057c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80057f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800586:	eb 11                	jmp    800599 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800588:	85 c0                	test   %eax,%eax
  80058a:	0f 84 68 04 00 00    	je     8009f8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800590:	89 74 24 04          	mov    %esi,0x4(%esp)
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800599:	0f b6 03             	movzbl (%ebx),%eax
  80059c:	83 c3 01             	add    $0x1,%ebx
  80059f:	83 f8 25             	cmp    $0x25,%eax
  8005a2:	75 e4                	jne    800588 <vprintfmt+0x1b>
  8005a4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8005ab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8005b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8005bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005c2:	eb 06                	jmp    8005ca <vprintfmt+0x5d>
  8005c4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8005c8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	0f b6 13             	movzbl (%ebx),%edx
  8005cd:	0f b6 c2             	movzbl %dl,%eax
  8005d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005d3:	8d 43 01             	lea    0x1(%ebx),%eax
  8005d6:	83 ea 23             	sub    $0x23,%edx
  8005d9:	80 fa 55             	cmp    $0x55,%dl
  8005dc:	0f 87 f9 03 00 00    	ja     8009db <vprintfmt+0x46e>
  8005e2:	0f b6 d2             	movzbl %dl,%edx
  8005e5:	ff 24 95 c0 2c 80 00 	jmp    *0x802cc0(,%edx,4)
  8005ec:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8005f0:	eb d6                	jmp    8005c8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f5:	83 ea 30             	sub    $0x30,%edx
  8005f8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8005fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005fe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800601:	83 fb 09             	cmp    $0x9,%ebx
  800604:	77 54                	ja     80065a <vprintfmt+0xed>
  800606:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800609:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80060c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80060f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800612:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800616:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800619:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80061c:	83 fb 09             	cmp    $0x9,%ebx
  80061f:	76 eb                	jbe    80060c <vprintfmt+0x9f>
  800621:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800624:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800627:	eb 31                	jmp    80065a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800629:	8b 55 14             	mov    0x14(%ebp),%edx
  80062c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80062f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800632:	8b 12                	mov    (%edx),%edx
  800634:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800637:	eb 21                	jmp    80065a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800639:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80063d:	ba 00 00 00 00       	mov    $0x0,%edx
  800642:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800646:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800649:	e9 7a ff ff ff       	jmp    8005c8 <vprintfmt+0x5b>
  80064e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800655:	e9 6e ff ff ff       	jmp    8005c8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80065a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80065e:	0f 89 64 ff ff ff    	jns    8005c8 <vprintfmt+0x5b>
  800664:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800667:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80066a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80066d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800670:	e9 53 ff ff ff       	jmp    8005c8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800675:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800678:	e9 4b ff ff ff       	jmp    8005c8 <vprintfmt+0x5b>
  80067d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800680:	8b 45 14             	mov    0x14(%ebp),%eax
  800683:	8d 50 04             	lea    0x4(%eax),%edx
  800686:	89 55 14             	mov    %edx,0x14(%ebp)
  800689:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068d:	8b 00                	mov    (%eax),%eax
  80068f:	89 04 24             	mov    %eax,(%esp)
  800692:	ff d7                	call   *%edi
  800694:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800697:	e9 fd fe ff ff       	jmp    800599 <vprintfmt+0x2c>
  80069c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	c1 fa 1f             	sar    $0x1f,%edx
  8006af:	31 d0                	xor    %edx,%eax
  8006b1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006b3:	83 f8 0f             	cmp    $0xf,%eax
  8006b6:	7f 0b                	jg     8006c3 <vprintfmt+0x156>
  8006b8:	8b 14 85 20 2e 80 00 	mov    0x802e20(,%eax,4),%edx
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	75 20                	jne    8006e3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8006c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c7:	c7 44 24 08 f4 2a 80 	movl   $0x802af4,0x8(%esp)
  8006ce:	00 
  8006cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d3:	89 3c 24             	mov    %edi,(%esp)
  8006d6:	e8 a5 03 00 00       	call   800a80 <printfmt>
  8006db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006de:	e9 b6 fe ff ff       	jmp    800599 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8006e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e7:	c7 44 24 08 b7 31 80 	movl   $0x8031b7,0x8(%esp)
  8006ee:	00 
  8006ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f3:	89 3c 24             	mov    %edi,(%esp)
  8006f6:	e8 85 03 00 00       	call   800a80 <printfmt>
  8006fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006fe:	e9 96 fe ff ff       	jmp    800599 <vprintfmt+0x2c>
  800703:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800706:	89 c3                	mov    %eax,%ebx
  800708:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80070e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8d 50 04             	lea    0x4(%eax),%edx
  800717:	89 55 14             	mov    %edx,0x14(%ebp)
  80071a:	8b 00                	mov    (%eax),%eax
  80071c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80071f:	85 c0                	test   %eax,%eax
  800721:	b8 fd 2a 80 00       	mov    $0x802afd,%eax
  800726:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80072a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80072d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800731:	7e 06                	jle    800739 <vprintfmt+0x1cc>
  800733:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800737:	75 13                	jne    80074c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800739:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80073c:	0f be 02             	movsbl (%edx),%eax
  80073f:	85 c0                	test   %eax,%eax
  800741:	0f 85 a2 00 00 00    	jne    8007e9 <vprintfmt+0x27c>
  800747:	e9 8f 00 00 00       	jmp    8007db <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80074c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800750:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800753:	89 0c 24             	mov    %ecx,(%esp)
  800756:	e8 70 03 00 00       	call   800acb <strnlen>
  80075b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80075e:	29 c2                	sub    %eax,%edx
  800760:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800763:	85 d2                	test   %edx,%edx
  800765:	7e d2                	jle    800739 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800767:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80076b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80076e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800771:	89 d3                	mov    %edx,%ebx
  800773:	89 74 24 04          	mov    %esi,0x4(%esp)
  800777:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80077a:	89 04 24             	mov    %eax,(%esp)
  80077d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80077f:	83 eb 01             	sub    $0x1,%ebx
  800782:	85 db                	test   %ebx,%ebx
  800784:	7f ed                	jg     800773 <vprintfmt+0x206>
  800786:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800789:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800790:	eb a7                	jmp    800739 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800792:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800796:	74 1b                	je     8007b3 <vprintfmt+0x246>
  800798:	8d 50 e0             	lea    -0x20(%eax),%edx
  80079b:	83 fa 5e             	cmp    $0x5e,%edx
  80079e:	76 13                	jbe    8007b3 <vprintfmt+0x246>
					putch('?', putdat);
  8007a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8007ae:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007b1:	eb 0d                	jmp    8007c0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8007b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007ba:	89 04 24             	mov    %eax,(%esp)
  8007bd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007c0:	83 ef 01             	sub    $0x1,%edi
  8007c3:	0f be 03             	movsbl (%ebx),%eax
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	74 05                	je     8007cf <vprintfmt+0x262>
  8007ca:	83 c3 01             	add    $0x1,%ebx
  8007cd:	eb 31                	jmp    800800 <vprintfmt+0x293>
  8007cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007d8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007df:	7f 36                	jg     800817 <vprintfmt+0x2aa>
  8007e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007e4:	e9 b0 fd ff ff       	jmp    800599 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007ec:	83 c2 01             	add    $0x1,%edx
  8007ef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8007f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007f5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8007f8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007fb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007fe:	89 d3                	mov    %edx,%ebx
  800800:	85 f6                	test   %esi,%esi
  800802:	78 8e                	js     800792 <vprintfmt+0x225>
  800804:	83 ee 01             	sub    $0x1,%esi
  800807:	79 89                	jns    800792 <vprintfmt+0x225>
  800809:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80080c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80080f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800812:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800815:	eb c4                	jmp    8007db <vprintfmt+0x26e>
  800817:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80081a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80081d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800821:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800828:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80082a:	83 eb 01             	sub    $0x1,%ebx
  80082d:	85 db                	test   %ebx,%ebx
  80082f:	7f ec                	jg     80081d <vprintfmt+0x2b0>
  800831:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800834:	e9 60 fd ff ff       	jmp    800599 <vprintfmt+0x2c>
  800839:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083c:	83 f9 01             	cmp    $0x1,%ecx
  80083f:	7e 16                	jle    800857 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8d 50 08             	lea    0x8(%eax),%edx
  800847:	89 55 14             	mov    %edx,0x14(%ebp)
  80084a:	8b 10                	mov    (%eax),%edx
  80084c:	8b 48 04             	mov    0x4(%eax),%ecx
  80084f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800852:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800855:	eb 32                	jmp    800889 <vprintfmt+0x31c>
	else if (lflag)
  800857:	85 c9                	test   %ecx,%ecx
  800859:	74 18                	je     800873 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 50 04             	lea    0x4(%eax),%edx
  800861:	89 55 14             	mov    %edx,0x14(%ebp)
  800864:	8b 00                	mov    (%eax),%eax
  800866:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800869:	89 c1                	mov    %eax,%ecx
  80086b:	c1 f9 1f             	sar    $0x1f,%ecx
  80086e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800871:	eb 16                	jmp    800889 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8d 50 04             	lea    0x4(%eax),%edx
  800879:	89 55 14             	mov    %edx,0x14(%ebp)
  80087c:	8b 00                	mov    (%eax),%eax
  80087e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800881:	89 c2                	mov    %eax,%edx
  800883:	c1 fa 1f             	sar    $0x1f,%edx
  800886:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800889:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80088c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80088f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800894:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800898:	0f 89 8a 00 00 00    	jns    800928 <vprintfmt+0x3bb>
				putch('-', putdat);
  80089e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8008a9:	ff d7                	call   *%edi
				num = -(long long) num;
  8008ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008b1:	f7 d8                	neg    %eax
  8008b3:	83 d2 00             	adc    $0x0,%edx
  8008b6:	f7 da                	neg    %edx
  8008b8:	eb 6e                	jmp    800928 <vprintfmt+0x3bb>
  8008ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008bd:	89 ca                	mov    %ecx,%edx
  8008bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8008c2:	e8 4f fc ff ff       	call   800516 <getuint>
  8008c7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8008cc:	eb 5a                	jmp    800928 <vprintfmt+0x3bb>
  8008ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8008d1:	89 ca                	mov    %ecx,%edx
  8008d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8008d6:	e8 3b fc ff ff       	call   800516 <getuint>
  8008db:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8008e0:	eb 46                	jmp    800928 <vprintfmt+0x3bb>
  8008e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8008e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008f0:	ff d7                	call   *%edi
			putch('x', putdat);
  8008f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008f6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008fd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8008ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800902:	8d 50 04             	lea    0x4(%eax),%edx
  800905:	89 55 14             	mov    %edx,0x14(%ebp)
  800908:	8b 00                	mov    (%eax),%eax
  80090a:	ba 00 00 00 00       	mov    $0x0,%edx
  80090f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800914:	eb 12                	jmp    800928 <vprintfmt+0x3bb>
  800916:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800919:	89 ca                	mov    %ecx,%edx
  80091b:	8d 45 14             	lea    0x14(%ebp),%eax
  80091e:	e8 f3 fb ff ff       	call   800516 <getuint>
  800923:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800928:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80092c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800930:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800933:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800937:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80093b:	89 04 24             	mov    %eax,(%esp)
  80093e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800942:	89 f2                	mov    %esi,%edx
  800944:	89 f8                	mov    %edi,%eax
  800946:	e8 d5 fa ff ff       	call   800420 <printnum>
  80094b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80094e:	e9 46 fc ff ff       	jmp    800599 <vprintfmt+0x2c>
  800953:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800956:	8b 45 14             	mov    0x14(%ebp),%eax
  800959:	8d 50 04             	lea    0x4(%eax),%edx
  80095c:	89 55 14             	mov    %edx,0x14(%ebp)
  80095f:	8b 00                	mov    (%eax),%eax
  800961:	85 c0                	test   %eax,%eax
  800963:	75 24                	jne    800989 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800965:	c7 44 24 0c 18 2c 80 	movl   $0x802c18,0xc(%esp)
  80096c:	00 
  80096d:	c7 44 24 08 b7 31 80 	movl   $0x8031b7,0x8(%esp)
  800974:	00 
  800975:	89 74 24 04          	mov    %esi,0x4(%esp)
  800979:	89 3c 24             	mov    %edi,(%esp)
  80097c:	e8 ff 00 00 00       	call   800a80 <printfmt>
  800981:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800984:	e9 10 fc ff ff       	jmp    800599 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800989:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80098c:	7e 29                	jle    8009b7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80098e:	0f b6 16             	movzbl (%esi),%edx
  800991:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800993:	c7 44 24 0c 50 2c 80 	movl   $0x802c50,0xc(%esp)
  80099a:	00 
  80099b:	c7 44 24 08 b7 31 80 	movl   $0x8031b7,0x8(%esp)
  8009a2:	00 
  8009a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a7:	89 3c 24             	mov    %edi,(%esp)
  8009aa:	e8 d1 00 00 00       	call   800a80 <printfmt>
  8009af:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8009b2:	e9 e2 fb ff ff       	jmp    800599 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8009b7:	0f b6 16             	movzbl (%esi),%edx
  8009ba:	88 10                	mov    %dl,(%eax)
  8009bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8009bf:	e9 d5 fb ff ff       	jmp    800599 <vprintfmt+0x2c>
  8009c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8009ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009ce:	89 14 24             	mov    %edx,(%esp)
  8009d1:	ff d7                	call   *%edi
  8009d3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8009d6:	e9 be fb ff ff       	jmp    800599 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8009db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8009e6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8009eb:	80 38 25             	cmpb   $0x25,(%eax)
  8009ee:	0f 84 a5 fb ff ff    	je     800599 <vprintfmt+0x2c>
  8009f4:	89 c3                	mov    %eax,%ebx
  8009f6:	eb f0                	jmp    8009e8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8009f8:	83 c4 5c             	add    $0x5c,%esp
  8009fb:	5b                   	pop    %ebx
  8009fc:	5e                   	pop    %esi
  8009fd:	5f                   	pop    %edi
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 28             	sub    $0x28,%esp
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800a0c:	85 c0                	test   %eax,%eax
  800a0e:	74 04                	je     800a14 <vsnprintf+0x14>
  800a10:	85 d2                	test   %edx,%edx
  800a12:	7f 07                	jg     800a1b <vsnprintf+0x1b>
  800a14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a19:	eb 3b                	jmp    800a56 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800a1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800a1e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800a2c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a33:	8b 45 10             	mov    0x10(%ebp),%eax
  800a36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a41:	c7 04 24 50 05 80 00 	movl   $0x800550,(%esp)
  800a48:	e8 20 fb ff ff       	call   80056d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a50:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800a56:	c9                   	leave  
  800a57:	c3                   	ret    

00800a58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800a5e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800a61:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a65:	8b 45 10             	mov    0x10(%ebp),%eax
  800a68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	89 04 24             	mov    %eax,(%esp)
  800a79:	e8 82 ff ff ff       	call   800a00 <vsnprintf>
	va_end(ap);

	return rc;
}
  800a7e:	c9                   	leave  
  800a7f:	c3                   	ret    

00800a80 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800a86:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800a89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800a8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800a90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	89 04 24             	mov    %eax,(%esp)
  800aa1:	e8 c7 fa ff ff       	call   80056d <vprintfmt>
	va_end(ap);
}
  800aa6:	c9                   	leave  
  800aa7:	c3                   	ret    
	...

00800ab0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ab6:	b8 00 00 00 00       	mov    $0x0,%eax
  800abb:	80 3a 00             	cmpb   $0x0,(%edx)
  800abe:	74 09                	je     800ac9 <strlen+0x19>
		n++;
  800ac0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800ac3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800ac7:	75 f7                	jne    800ac0 <strlen+0x10>
		n++;
	return n;
}
  800ac9:	5d                   	pop    %ebp
  800aca:	c3                   	ret    

00800acb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	53                   	push   %ebx
  800acf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800ad2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ad5:	85 c9                	test   %ecx,%ecx
  800ad7:	74 19                	je     800af2 <strnlen+0x27>
  800ad9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800adc:	74 14                	je     800af2 <strnlen+0x27>
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ae3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ae6:	39 c8                	cmp    %ecx,%eax
  800ae8:	74 0d                	je     800af7 <strnlen+0x2c>
  800aea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800aee:	75 f3                	jne    800ae3 <strnlen+0x18>
  800af0:	eb 05                	jmp    800af7 <strnlen+0x2c>
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800af7:	5b                   	pop    %ebx
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800b0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800b10:	83 c2 01             	add    $0x1,%edx
  800b13:	84 c9                	test   %cl,%cl
  800b15:	75 f2                	jne    800b09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800b17:	5b                   	pop    %ebx
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 08             	sub    $0x8,%esp
  800b21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800b24:	89 1c 24             	mov    %ebx,(%esp)
  800b27:	e8 84 ff ff ff       	call   800ab0 <strlen>
	strcpy(dst + len, src);
  800b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800b33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 bc ff ff ff       	call   800afa <strcpy>
	return dst;
}
  800b3e:	89 d8                	mov    %ebx,%eax
  800b40:	83 c4 08             	add    $0x8,%esp
  800b43:	5b                   	pop    %ebx
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	56                   	push   %esi
  800b4a:	53                   	push   %ebx
  800b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b54:	85 f6                	test   %esi,%esi
  800b56:	74 18                	je     800b70 <strncpy+0x2a>
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800b5d:	0f b6 1a             	movzbl (%edx),%ebx
  800b60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800b63:	80 3a 01             	cmpb   $0x1,(%edx)
  800b66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800b69:	83 c1 01             	add    $0x1,%ecx
  800b6c:	39 ce                	cmp    %ecx,%esi
  800b6e:	77 ed                	ja     800b5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b82:	89 f0                	mov    %esi,%eax
  800b84:	85 c9                	test   %ecx,%ecx
  800b86:	74 27                	je     800baf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800b88:	83 e9 01             	sub    $0x1,%ecx
  800b8b:	74 1d                	je     800baa <strlcpy+0x36>
  800b8d:	0f b6 1a             	movzbl (%edx),%ebx
  800b90:	84 db                	test   %bl,%bl
  800b92:	74 16                	je     800baa <strlcpy+0x36>
			*dst++ = *src++;
  800b94:	88 18                	mov    %bl,(%eax)
  800b96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b99:	83 e9 01             	sub    $0x1,%ecx
  800b9c:	74 0e                	je     800bac <strlcpy+0x38>
			*dst++ = *src++;
  800b9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ba1:	0f b6 1a             	movzbl (%edx),%ebx
  800ba4:	84 db                	test   %bl,%bl
  800ba6:	75 ec                	jne    800b94 <strlcpy+0x20>
  800ba8:	eb 02                	jmp    800bac <strlcpy+0x38>
  800baa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800bac:	c6 00 00             	movb   $0x0,(%eax)
  800baf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800bb1:	5b                   	pop    %ebx
  800bb2:	5e                   	pop    %esi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800bbe:	0f b6 01             	movzbl (%ecx),%eax
  800bc1:	84 c0                	test   %al,%al
  800bc3:	74 15                	je     800bda <strcmp+0x25>
  800bc5:	3a 02                	cmp    (%edx),%al
  800bc7:	75 11                	jne    800bda <strcmp+0x25>
		p++, q++;
  800bc9:	83 c1 01             	add    $0x1,%ecx
  800bcc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800bcf:	0f b6 01             	movzbl (%ecx),%eax
  800bd2:	84 c0                	test   %al,%al
  800bd4:	74 04                	je     800bda <strcmp+0x25>
  800bd6:	3a 02                	cmp    (%edx),%al
  800bd8:	74 ef                	je     800bc9 <strcmp+0x14>
  800bda:	0f b6 c0             	movzbl %al,%eax
  800bdd:	0f b6 12             	movzbl (%edx),%edx
  800be0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800be2:	5d                   	pop    %ebp
  800be3:	c3                   	ret    

00800be4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800be4:	55                   	push   %ebp
  800be5:	89 e5                	mov    %esp,%ebp
  800be7:	53                   	push   %ebx
  800be8:	8b 55 08             	mov    0x8(%ebp),%edx
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	74 23                	je     800c18 <strncmp+0x34>
  800bf5:	0f b6 1a             	movzbl (%edx),%ebx
  800bf8:	84 db                	test   %bl,%bl
  800bfa:	74 25                	je     800c21 <strncmp+0x3d>
  800bfc:	3a 19                	cmp    (%ecx),%bl
  800bfe:	75 21                	jne    800c21 <strncmp+0x3d>
  800c00:	83 e8 01             	sub    $0x1,%eax
  800c03:	74 13                	je     800c18 <strncmp+0x34>
		n--, p++, q++;
  800c05:	83 c2 01             	add    $0x1,%edx
  800c08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800c0b:	0f b6 1a             	movzbl (%edx),%ebx
  800c0e:	84 db                	test   %bl,%bl
  800c10:	74 0f                	je     800c21 <strncmp+0x3d>
  800c12:	3a 19                	cmp    (%ecx),%bl
  800c14:	74 ea                	je     800c00 <strncmp+0x1c>
  800c16:	eb 09                	jmp    800c21 <strncmp+0x3d>
  800c18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800c1d:	5b                   	pop    %ebx
  800c1e:	5d                   	pop    %ebp
  800c1f:	90                   	nop
  800c20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c21:	0f b6 02             	movzbl (%edx),%eax
  800c24:	0f b6 11             	movzbl (%ecx),%edx
  800c27:	29 d0                	sub    %edx,%eax
  800c29:	eb f2                	jmp    800c1d <strncmp+0x39>

00800c2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c35:	0f b6 10             	movzbl (%eax),%edx
  800c38:	84 d2                	test   %dl,%dl
  800c3a:	74 18                	je     800c54 <strchr+0x29>
		if (*s == c)
  800c3c:	38 ca                	cmp    %cl,%dl
  800c3e:	75 0a                	jne    800c4a <strchr+0x1f>
  800c40:	eb 17                	jmp    800c59 <strchr+0x2e>
  800c42:	38 ca                	cmp    %cl,%dl
  800c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c48:	74 0f                	je     800c59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800c4a:	83 c0 01             	add    $0x1,%eax
  800c4d:	0f b6 10             	movzbl (%eax),%edx
  800c50:	84 d2                	test   %dl,%dl
  800c52:	75 ee                	jne    800c42 <strchr+0x17>
  800c54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800c65:	0f b6 10             	movzbl (%eax),%edx
  800c68:	84 d2                	test   %dl,%dl
  800c6a:	74 18                	je     800c84 <strfind+0x29>
		if (*s == c)
  800c6c:	38 ca                	cmp    %cl,%dl
  800c6e:	75 0a                	jne    800c7a <strfind+0x1f>
  800c70:	eb 12                	jmp    800c84 <strfind+0x29>
  800c72:	38 ca                	cmp    %cl,%dl
  800c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800c78:	74 0a                	je     800c84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800c7a:	83 c0 01             	add    $0x1,%eax
  800c7d:	0f b6 10             	movzbl (%eax),%edx
  800c80:	84 d2                	test   %dl,%dl
  800c82:	75 ee                	jne    800c72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	89 1c 24             	mov    %ebx,(%esp)
  800c8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800c97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ca0:	85 c9                	test   %ecx,%ecx
  800ca2:	74 30                	je     800cd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ca4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800caa:	75 25                	jne    800cd1 <memset+0x4b>
  800cac:	f6 c1 03             	test   $0x3,%cl
  800caf:	75 20                	jne    800cd1 <memset+0x4b>
		c &= 0xFF;
  800cb1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cb4:	89 d3                	mov    %edx,%ebx
  800cb6:	c1 e3 08             	shl    $0x8,%ebx
  800cb9:	89 d6                	mov    %edx,%esi
  800cbb:	c1 e6 18             	shl    $0x18,%esi
  800cbe:	89 d0                	mov    %edx,%eax
  800cc0:	c1 e0 10             	shl    $0x10,%eax
  800cc3:	09 f0                	or     %esi,%eax
  800cc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800cc7:	09 d8                	or     %ebx,%eax
  800cc9:	c1 e9 02             	shr    $0x2,%ecx
  800ccc:	fc                   	cld    
  800ccd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ccf:	eb 03                	jmp    800cd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800cd1:	fc                   	cld    
  800cd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800cd4:	89 f8                	mov    %edi,%eax
  800cd6:	8b 1c 24             	mov    (%esp),%ebx
  800cd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cdd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ce1:	89 ec                	mov    %ebp,%esp
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
  800ceb:	89 34 24             	mov    %esi,(%esp)
  800cee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800cf8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800cfb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800cfd:	39 c6                	cmp    %eax,%esi
  800cff:	73 35                	jae    800d36 <memmove+0x51>
  800d01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d04:	39 d0                	cmp    %edx,%eax
  800d06:	73 2e                	jae    800d36 <memmove+0x51>
		s += n;
		d += n;
  800d08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d0a:	f6 c2 03             	test   $0x3,%dl
  800d0d:	75 1b                	jne    800d2a <memmove+0x45>
  800d0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d15:	75 13                	jne    800d2a <memmove+0x45>
  800d17:	f6 c1 03             	test   $0x3,%cl
  800d1a:	75 0e                	jne    800d2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800d1c:	83 ef 04             	sub    $0x4,%edi
  800d1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d22:	c1 e9 02             	shr    $0x2,%ecx
  800d25:	fd                   	std    
  800d26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d28:	eb 09                	jmp    800d33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800d2a:	83 ef 01             	sub    $0x1,%edi
  800d2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800d30:	fd                   	std    
  800d31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d34:	eb 20                	jmp    800d56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d3c:	75 15                	jne    800d53 <memmove+0x6e>
  800d3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d44:	75 0d                	jne    800d53 <memmove+0x6e>
  800d46:	f6 c1 03             	test   $0x3,%cl
  800d49:	75 08                	jne    800d53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800d4b:	c1 e9 02             	shr    $0x2,%ecx
  800d4e:	fc                   	cld    
  800d4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d51:	eb 03                	jmp    800d56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800d53:	fc                   	cld    
  800d54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d56:	8b 34 24             	mov    (%esp),%esi
  800d59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800d5d:	89 ec                	mov    %ebp,%esp
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d67:	8b 45 10             	mov    0x10(%ebp),%eax
  800d6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d75:	8b 45 08             	mov    0x8(%ebp),%eax
  800d78:	89 04 24             	mov    %eax,(%esp)
  800d7b:	e8 65 ff ff ff       	call   800ce5 <memmove>
}
  800d80:	c9                   	leave  
  800d81:	c3                   	ret    

00800d82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
  800d88:	8b 75 08             	mov    0x8(%ebp),%esi
  800d8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d91:	85 c9                	test   %ecx,%ecx
  800d93:	74 36                	je     800dcb <memcmp+0x49>
		if (*s1 != *s2)
  800d95:	0f b6 06             	movzbl (%esi),%eax
  800d98:	0f b6 1f             	movzbl (%edi),%ebx
  800d9b:	38 d8                	cmp    %bl,%al
  800d9d:	74 20                	je     800dbf <memcmp+0x3d>
  800d9f:	eb 14                	jmp    800db5 <memcmp+0x33>
  800da1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800da6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800dab:	83 c2 01             	add    $0x1,%edx
  800dae:	83 e9 01             	sub    $0x1,%ecx
  800db1:	38 d8                	cmp    %bl,%al
  800db3:	74 12                	je     800dc7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800db5:	0f b6 c0             	movzbl %al,%eax
  800db8:	0f b6 db             	movzbl %bl,%ebx
  800dbb:	29 d8                	sub    %ebx,%eax
  800dbd:	eb 11                	jmp    800dd0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbf:	83 e9 01             	sub    $0x1,%ecx
  800dc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800dc7:	85 c9                	test   %ecx,%ecx
  800dc9:	75 d6                	jne    800da1 <memcmp+0x1f>
  800dcb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ddb:	89 c2                	mov    %eax,%edx
  800ddd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800de0:	39 d0                	cmp    %edx,%eax
  800de2:	73 15                	jae    800df9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800de4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800de8:	38 08                	cmp    %cl,(%eax)
  800dea:	75 06                	jne    800df2 <memfind+0x1d>
  800dec:	eb 0b                	jmp    800df9 <memfind+0x24>
  800dee:	38 08                	cmp    %cl,(%eax)
  800df0:	74 07                	je     800df9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800df2:	83 c0 01             	add    $0x1,%eax
  800df5:	39 c2                	cmp    %eax,%edx
  800df7:	77 f5                	ja     800dee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	57                   	push   %edi
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	8b 55 08             	mov    0x8(%ebp),%edx
  800e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e0a:	0f b6 02             	movzbl (%edx),%eax
  800e0d:	3c 20                	cmp    $0x20,%al
  800e0f:	74 04                	je     800e15 <strtol+0x1a>
  800e11:	3c 09                	cmp    $0x9,%al
  800e13:	75 0e                	jne    800e23 <strtol+0x28>
		s++;
  800e15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e18:	0f b6 02             	movzbl (%edx),%eax
  800e1b:	3c 20                	cmp    $0x20,%al
  800e1d:	74 f6                	je     800e15 <strtol+0x1a>
  800e1f:	3c 09                	cmp    $0x9,%al
  800e21:	74 f2                	je     800e15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800e23:	3c 2b                	cmp    $0x2b,%al
  800e25:	75 0c                	jne    800e33 <strtol+0x38>
		s++;
  800e27:	83 c2 01             	add    $0x1,%edx
  800e2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e31:	eb 15                	jmp    800e48 <strtol+0x4d>
	else if (*s == '-')
  800e33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800e3a:	3c 2d                	cmp    $0x2d,%al
  800e3c:	75 0a                	jne    800e48 <strtol+0x4d>
		s++, neg = 1;
  800e3e:	83 c2 01             	add    $0x1,%edx
  800e41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e48:	85 db                	test   %ebx,%ebx
  800e4a:	0f 94 c0             	sete   %al
  800e4d:	74 05                	je     800e54 <strtol+0x59>
  800e4f:	83 fb 10             	cmp    $0x10,%ebx
  800e52:	75 18                	jne    800e6c <strtol+0x71>
  800e54:	80 3a 30             	cmpb   $0x30,(%edx)
  800e57:	75 13                	jne    800e6c <strtol+0x71>
  800e59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800e5d:	8d 76 00             	lea    0x0(%esi),%esi
  800e60:	75 0a                	jne    800e6c <strtol+0x71>
		s += 2, base = 16;
  800e62:	83 c2 02             	add    $0x2,%edx
  800e65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e6a:	eb 15                	jmp    800e81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e6c:	84 c0                	test   %al,%al
  800e6e:	66 90                	xchg   %ax,%ax
  800e70:	74 0f                	je     800e81 <strtol+0x86>
  800e72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800e77:	80 3a 30             	cmpb   $0x30,(%edx)
  800e7a:	75 05                	jne    800e81 <strtol+0x86>
		s++, base = 8;
  800e7c:	83 c2 01             	add    $0x1,%edx
  800e7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800e88:	0f b6 0a             	movzbl (%edx),%ecx
  800e8b:	89 cf                	mov    %ecx,%edi
  800e8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800e90:	80 fb 09             	cmp    $0x9,%bl
  800e93:	77 08                	ja     800e9d <strtol+0xa2>
			dig = *s - '0';
  800e95:	0f be c9             	movsbl %cl,%ecx
  800e98:	83 e9 30             	sub    $0x30,%ecx
  800e9b:	eb 1e                	jmp    800ebb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800e9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ea0:	80 fb 19             	cmp    $0x19,%bl
  800ea3:	77 08                	ja     800ead <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ea5:	0f be c9             	movsbl %cl,%ecx
  800ea8:	83 e9 57             	sub    $0x57,%ecx
  800eab:	eb 0e                	jmp    800ebb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ead:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800eb0:	80 fb 19             	cmp    $0x19,%bl
  800eb3:	77 15                	ja     800eca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800eb5:	0f be c9             	movsbl %cl,%ecx
  800eb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ebb:	39 f1                	cmp    %esi,%ecx
  800ebd:	7d 0b                	jge    800eca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ebf:	83 c2 01             	add    $0x1,%edx
  800ec2:	0f af c6             	imul   %esi,%eax
  800ec5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ec8:	eb be                	jmp    800e88 <strtol+0x8d>
  800eca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 05                	je     800ed7 <strtol+0xdc>
		*endptr = (char *) s;
  800ed2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ed5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ed7:	89 ca                	mov    %ecx,%edx
  800ed9:	f7 da                	neg    %edx
  800edb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800edf:	0f 45 c2             	cmovne %edx,%eax
}
  800ee2:	83 c4 04             	add    $0x4,%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    
	...

00800eec <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	83 ec 48             	sub    $0x48,%esp
  800ef2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ef8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800efb:	89 c6                	mov    %eax,%esi
  800efd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800f00:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800f02:	8b 7d 10             	mov    0x10(%ebp),%edi
  800f05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f0b:	51                   	push   %ecx
  800f0c:	52                   	push   %edx
  800f0d:	53                   	push   %ebx
  800f0e:	54                   	push   %esp
  800f0f:	55                   	push   %ebp
  800f10:	56                   	push   %esi
  800f11:	57                   	push   %edi
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	8d 35 1c 0f 80 00    	lea    0x800f1c,%esi
  800f1a:	0f 34                	sysenter 

00800f1c <.after_sysenter_label>:
  800f1c:	5f                   	pop    %edi
  800f1d:	5e                   	pop    %esi
  800f1e:	5d                   	pop    %ebp
  800f1f:	5c                   	pop    %esp
  800f20:	5b                   	pop    %ebx
  800f21:	5a                   	pop    %edx
  800f22:	59                   	pop    %ecx
  800f23:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800f25:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f29:	74 28                	je     800f53 <.after_sysenter_label+0x37>
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	7e 24                	jle    800f53 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f33:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800f37:	c7 44 24 08 60 2e 80 	movl   $0x802e60,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 7d 2e 80 00 	movl   $0x802e7d,(%esp)
  800f4e:	e8 b1 f3 ff ff       	call   800304 <_panic>

	return ret;
}
  800f53:	89 d0                	mov    %edx,%eax
  800f55:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f58:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f5b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5e:	89 ec                	mov    %ebp,%esp
  800f60:	5d                   	pop    %ebp
  800f61:	c3                   	ret    

00800f62 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800f68:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f6f:	00 
  800f70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f77:	00 
  800f78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f7f:	00 
  800f80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f83:	89 04 24             	mov    %eax,(%esp)
  800f86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f89:	ba 00 00 00 00       	mov    $0x0,%edx
  800f8e:	b8 10 00 00 00       	mov    $0x10,%eax
  800f93:	e8 54 ff ff ff       	call   800eec <syscall>
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800fa0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fa7:	00 
  800fa8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800faf:	00 
  800fb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fb7:	00 
  800fb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fbf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800fce:	e8 19 ff ff ff       	call   800eec <syscall>
}
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800fdb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe2:	00 
  800fe3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fea:	00 
  800feb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff2:	00 
  800ff3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ffa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ffd:	ba 01 00 00 00       	mov    $0x1,%edx
  801002:	b8 0e 00 00 00       	mov    $0xe,%eax
  801007:	e8 e0 fe ff ff       	call   800eec <syscall>
}
  80100c:	c9                   	leave  
  80100d:	c3                   	ret    

0080100e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801014:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80101b:	00 
  80101c:	8b 45 14             	mov    0x14(%ebp),%eax
  80101f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801023:	8b 45 10             	mov    0x10(%ebp),%eax
  801026:	89 44 24 04          	mov    %eax,0x4(%esp)
  80102a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801033:	ba 00 00 00 00       	mov    $0x0,%edx
  801038:	b8 0d 00 00 00       	mov    $0xd,%eax
  80103d:	e8 aa fe ff ff       	call   800eec <syscall>
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80104a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801051:	00 
  801052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801059:	00 
  80105a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801061:	00 
  801062:	8b 45 0c             	mov    0xc(%ebp),%eax
  801065:	89 04 24             	mov    %eax,(%esp)
  801068:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106b:	ba 01 00 00 00       	mov    $0x1,%edx
  801070:	b8 0b 00 00 00       	mov    $0xb,%eax
  801075:	e8 72 fe ff ff       	call   800eec <syscall>
}
  80107a:	c9                   	leave  
  80107b:	c3                   	ret    

0080107c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80107c:	55                   	push   %ebp
  80107d:	89 e5                	mov    %esp,%ebp
  80107f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801082:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801089:	00 
  80108a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801091:	00 
  801092:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801099:	00 
  80109a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109d:	89 04 24             	mov    %eax,(%esp)
  8010a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a3:	ba 01 00 00 00       	mov    $0x1,%edx
  8010a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010ad:	e8 3a fe ff ff       	call   800eec <syscall>
}
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8010ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010c1:	00 
  8010c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c9:	00 
  8010ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010d1:	00 
  8010d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010db:	ba 01 00 00 00       	mov    $0x1,%edx
  8010e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8010e5:	e8 02 fe ff ff       	call   800eec <syscall>
}
  8010ea:	c9                   	leave  
  8010eb:	c3                   	ret    

008010ec <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8010f2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010f9:	00 
  8010fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801101:	00 
  801102:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801109:	00 
  80110a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110d:	89 04 24             	mov    %eax,(%esp)
  801110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801113:	ba 01 00 00 00       	mov    $0x1,%edx
  801118:	b8 07 00 00 00       	mov    $0x7,%eax
  80111d:	e8 ca fd ff ff       	call   800eec <syscall>
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  80112a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801131:	00 
  801132:	8b 45 18             	mov    0x18(%ebp),%eax
  801135:	0b 45 14             	or     0x14(%ebp),%eax
  801138:	89 44 24 08          	mov    %eax,0x8(%esp)
  80113c:	8b 45 10             	mov    0x10(%ebp),%eax
  80113f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801143:	8b 45 0c             	mov    0xc(%ebp),%eax
  801146:	89 04 24             	mov    %eax,(%esp)
  801149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114c:	ba 01 00 00 00       	mov    $0x1,%edx
  801151:	b8 06 00 00 00       	mov    $0x6,%eax
  801156:	e8 91 fd ff ff       	call   800eec <syscall>
}
  80115b:	c9                   	leave  
  80115c:	c3                   	ret    

0080115d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801163:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80116a:	00 
  80116b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801172:	00 
  801173:	8b 45 10             	mov    0x10(%ebp),%eax
  801176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80117a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117d:	89 04 24             	mov    %eax,(%esp)
  801180:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801183:	ba 01 00 00 00       	mov    $0x1,%edx
  801188:	b8 05 00 00 00       	mov    $0x5,%eax
  80118d:	e8 5a fd ff ff       	call   800eec <syscall>
}
  801192:	c9                   	leave  
  801193:	c3                   	ret    

00801194 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80119a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011a1:	00 
  8011a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011a9:	00 
  8011aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011b1:	00 
  8011b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011be:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011c8:	e8 1f fd ff ff       	call   800eec <syscall>
}
  8011cd:	c9                   	leave  
  8011ce:	c3                   	ret    

008011cf <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8011d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011dc:	00 
  8011dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011e4:	00 
  8011e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011ec:	00 
  8011ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f0:	89 04 24             	mov    %eax,(%esp)
  8011f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801200:	e8 e7 fc ff ff       	call   800eec <syscall>
}
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80120d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801214:	00 
  801215:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80121c:	00 
  80121d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801224:	00 
  801225:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80122c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801231:	ba 00 00 00 00       	mov    $0x0,%edx
  801236:	b8 02 00 00 00       	mov    $0x2,%eax
  80123b:	e8 ac fc ff ff       	call   800eec <syscall>
}
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801248:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80124f:	00 
  801250:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801257:	00 
  801258:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80125f:	00 
  801260:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801267:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126a:	ba 01 00 00 00       	mov    $0x1,%edx
  80126f:	b8 03 00 00 00       	mov    $0x3,%eax
  801274:	e8 73 fc ff ff       	call   800eec <syscall>
}
  801279:	c9                   	leave  
  80127a:	c3                   	ret    

0080127b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801281:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801288:	00 
  801289:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801290:	00 
  801291:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801298:	00 
  801299:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012af:	e8 38 fc ff ff       	call   800eec <syscall>
}
  8012b4:	c9                   	leave  
  8012b5:	c3                   	ret    

008012b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8012b6:	55                   	push   %ebp
  8012b7:	89 e5                	mov    %esp,%ebp
  8012b9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8012bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012c3:	00 
  8012c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012cb:	00 
  8012cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012d3:	00 
  8012d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d7:	89 04 24             	mov    %eax,(%esp)
  8012da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e7:	e8 00 fc ff ff       	call   800eec <syscall>
}
  8012ec:	c9                   	leave  
  8012ed:	c3                   	ret    
	...

008012f0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012f6:	c7 44 24 08 8b 2e 80 	movl   $0x802e8b,0x8(%esp)
  8012fd:	00 
  8012fe:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801305:	00 
  801306:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80130d:	e8 f2 ef ff ff       	call   800304 <_panic>

00801312 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	57                   	push   %edi
  801316:	56                   	push   %esi
  801317:	53                   	push   %ebx
  801318:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  80131b:	c7 04 24 d6 15 80 00 	movl   $0x8015d6,(%esp)
  801322:	e8 5d 13 00 00       	call   802684 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801327:	ba 08 00 00 00       	mov    $0x8,%edx
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	51                   	push   %ecx
  80132f:	52                   	push   %edx
  801330:	53                   	push   %ebx
  801331:	55                   	push   %ebp
  801332:	56                   	push   %esi
  801333:	57                   	push   %edi
  801334:	89 e5                	mov    %esp,%ebp
  801336:	8d 35 3e 13 80 00    	lea    0x80133e,%esi
  80133c:	0f 34                	sysenter 

0080133e <.after_sysenter_label>:
  80133e:	5f                   	pop    %edi
  80133f:	5e                   	pop    %esi
  801340:	5d                   	pop    %ebp
  801341:	5b                   	pop    %ebx
  801342:	5a                   	pop    %edx
  801343:	59                   	pop    %ecx
  801344:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801347:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80134b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  801352:	00 
  801353:	c7 44 24 04 a1 2e 80 	movl   $0x802ea1,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 e8 2e 80 00 	movl   $0x802ee8,(%esp)
  801362:	e8 56 f0 ff ff       	call   8003bd <cprintf>
	if (envidnum < 0)
  801367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136b:	79 23                	jns    801390 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80136d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801370:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801374:	c7 44 24 08 ac 2e 80 	movl   $0x802eac,0x8(%esp)
  80137b:	00 
  80137c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801383:	00 
  801384:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80138b:	e8 74 ef ff ff       	call   800304 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801390:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801395:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80139a:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80139f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a3:	75 1c                	jne    8013c1 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  8013a5:	e8 5d fe ff ff       	call   801207 <sys_getenvid>
  8013aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8013af:	c1 e0 07             	shl    $0x7,%eax
  8013b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8013b7:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  8013bc:	e9 0a 02 00 00       	jmp    8015cb <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8013c1:	89 d8                	mov    %ebx,%eax
  8013c3:	c1 e8 16             	shr    $0x16,%eax
  8013c6:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8013c9:	a8 01                	test   $0x1,%al
  8013cb:	0f 84 43 01 00 00    	je     801514 <.after_sysenter_label+0x1d6>
  8013d1:	89 d8                	mov    %ebx,%eax
  8013d3:	c1 e8 0c             	shr    $0xc,%eax
  8013d6:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8013d9:	f6 c2 01             	test   $0x1,%dl
  8013dc:	0f 84 32 01 00 00    	je     801514 <.after_sysenter_label+0x1d6>
  8013e2:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8013e5:	f6 c2 04             	test   $0x4,%dl
  8013e8:	0f 84 26 01 00 00    	je     801514 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  8013ee:	c1 e0 0c             	shl    $0xc,%eax
  8013f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  8013f4:	c1 e8 0c             	shr    $0xc,%eax
  8013f7:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  801402:	a9 02 08 00 00       	test   $0x802,%eax
  801407:	0f 84 a0 00 00 00    	je     8014ad <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  80140d:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  801410:	80 ce 08             	or     $0x8,%dh
  801413:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801416:	89 54 24 10          	mov    %edx,0x10(%esp)
  80141a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80141d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801421:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801424:	89 44 24 08          	mov    %eax,0x8(%esp)
  801428:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80142b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801436:	e8 e9 fc ff ff       	call   801124 <sys_page_map>
  80143b:	85 c0                	test   %eax,%eax
  80143d:	79 20                	jns    80145f <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80143f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801443:	c7 44 24 08 10 2f 80 	movl   $0x802f10,0x8(%esp)
  80144a:	00 
  80144b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801452:	00 
  801453:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80145a:	e8 a5 ee ff ff       	call   800304 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80145f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801462:	89 44 24 10          	mov    %eax,0x10(%esp)
  801466:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801474:	00 
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801480:	e8 9f fc ff ff       	call   801124 <sys_page_map>
  801485:	85 c0                	test   %eax,%eax
  801487:	0f 89 87 00 00 00    	jns    801514 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  80148d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801491:	c7 44 24 08 3c 2f 80 	movl   $0x802f3c,0x8(%esp)
  801498:	00 
  801499:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8014a0:	00 
  8014a1:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8014a8:	e8 57 ee ff ff       	call   800304 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  8014ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	c7 04 24 bc 2e 80 00 	movl   $0x802ebc,(%esp)
  8014c2:	e8 f6 ee ff ff       	call   8003bd <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  8014c7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8014ce:	00 
  8014cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014eb:	e8 34 fc ff ff       	call   801124 <sys_page_map>
  8014f0:	85 c0                	test   %eax,%eax
  8014f2:	79 20                	jns    801514 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  8014f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014f8:	c7 44 24 08 68 2f 80 	movl   $0x802f68,0x8(%esp)
  8014ff:	00 
  801500:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801507:	00 
  801508:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80150f:	e8 f0 ed ff ff       	call   800304 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801514:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80151a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801520:	0f 85 9b fe ff ff    	jne    8013c1 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801526:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80152d:	00 
  80152e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801535:	ee 
  801536:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801539:	89 04 24             	mov    %eax,(%esp)
  80153c:	e8 1c fc ff ff       	call   80115d <sys_page_alloc>
  801541:	85 c0                	test   %eax,%eax
  801543:	79 20                	jns    801565 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801545:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801549:	c7 44 24 08 94 2f 80 	movl   $0x802f94,0x8(%esp)
  801550:	00 
  801551:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801558:	00 
  801559:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  801560:	e8 9f ed ff ff       	call   800304 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801565:	c7 44 24 04 f4 26 80 	movl   $0x8026f4,0x4(%esp)
  80156c:	00 
  80156d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801570:	89 04 24             	mov    %eax,(%esp)
  801573:	e8 cc fa ff ff       	call   801044 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801578:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80157f:	00 
  801580:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801583:	89 04 24             	mov    %eax,(%esp)
  801586:	e8 29 fb ff ff       	call   8010b4 <sys_env_set_status>
  80158b:	85 c0                	test   %eax,%eax
  80158d:	79 20                	jns    8015af <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80158f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801593:	c7 44 24 08 b8 2f 80 	movl   $0x802fb8,0x8(%esp)
  80159a:	00 
  80159b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8015a2:	00 
  8015a3:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8015aa:	e8 55 ed ff ff       	call   800304 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  8015af:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  8015b6:	00 
  8015b7:	c7 44 24 04 a1 2e 80 	movl   $0x802ea1,0x4(%esp)
  8015be:	00 
  8015bf:	c7 04 24 ce 2e 80 00 	movl   $0x802ece,(%esp)
  8015c6:	e8 f2 ed ff ff       	call   8003bd <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  8015cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015ce:	83 c4 3c             	add    $0x3c,%esp
  8015d1:	5b                   	pop    %ebx
  8015d2:	5e                   	pop    %esi
  8015d3:	5f                   	pop    %edi
  8015d4:	5d                   	pop    %ebp
  8015d5:	c3                   	ret    

008015d6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 24             	sub    $0x24,%esp
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8015e0:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8015e2:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  8015e5:	f6 c2 02             	test   $0x2,%dl
  8015e8:	75 2b                	jne    801615 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  8015ea:	8b 40 28             	mov    0x28(%eax),%eax
  8015ed:	89 44 24 14          	mov    %eax,0x14(%esp)
  8015f1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8015f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015f9:	c7 44 24 08 e0 2f 80 	movl   $0x802fe0,0x8(%esp)
  801600:	00 
  801601:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801608:	00 
  801609:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  801610:	e8 ef ec ff ff       	call   800304 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801615:	89 d8                	mov    %ebx,%eax
  801617:	c1 e8 16             	shr    $0x16,%eax
  80161a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801621:	a8 01                	test   $0x1,%al
  801623:	74 11                	je     801636 <pgfault+0x60>
  801625:	89 d8                	mov    %ebx,%eax
  801627:	c1 e8 0c             	shr    $0xc,%eax
  80162a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801631:	f6 c4 08             	test   $0x8,%ah
  801634:	75 1c                	jne    801652 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  801636:	c7 44 24 08 1c 30 80 	movl   $0x80301c,0x8(%esp)
  80163d:	00 
  80163e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801645:	00 
  801646:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80164d:	e8 b2 ec ff ff       	call   800304 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801652:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801659:	00 
  80165a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801661:	00 
  801662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801669:	e8 ef fa ff ff       	call   80115d <sys_page_alloc>
  80166e:	85 c0                	test   %eax,%eax
  801670:	79 20                	jns    801692 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  801672:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801676:	c7 44 24 08 58 30 80 	movl   $0x803058,0x8(%esp)
  80167d:	00 
  80167e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801685:	00 
  801686:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80168d:	e8 72 ec ff ff       	call   800304 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801692:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  801698:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80169f:	00 
  8016a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8016ab:	e8 35 f6 ff ff       	call   800ce5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  8016b0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8016b7:	00 
  8016b8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8016bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016c3:	00 
  8016c4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8016cb:	00 
  8016cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d3:	e8 4c fa ff ff       	call   801124 <sys_page_map>
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	79 20                	jns    8016fc <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  8016dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016e0:	c7 44 24 08 80 30 80 	movl   $0x803080,0x8(%esp)
  8016e7:	00 
  8016e8:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8016ef:	00 
  8016f0:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  8016f7:	e8 08 ec ff ff       	call   800304 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  8016fc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801703:	00 
  801704:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80170b:	e8 dc f9 ff ff       	call   8010ec <sys_page_unmap>
  801710:	85 c0                	test   %eax,%eax
  801712:	79 20                	jns    801734 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  801714:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801718:	c7 44 24 08 a4 30 80 	movl   $0x8030a4,0x8(%esp)
  80171f:	00 
  801720:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801727:	00 
  801728:	c7 04 24 a1 2e 80 00 	movl   $0x802ea1,(%esp)
  80172f:	e8 d0 eb ff ff       	call   800304 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801734:	83 c4 24             	add    $0x24,%esp
  801737:	5b                   	pop    %ebx
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    
  80173a:	00 00                	add    %al,(%eax)
  80173c:	00 00                	add    %al,(%eax)
	...

00801740 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801746:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80174c:	b8 01 00 00 00       	mov    $0x1,%eax
  801751:	39 ca                	cmp    %ecx,%edx
  801753:	75 04                	jne    801759 <ipc_find_env+0x19>
  801755:	b0 00                	mov    $0x0,%al
  801757:	eb 11                	jmp    80176a <ipc_find_env+0x2a>
  801759:	89 c2                	mov    %eax,%edx
  80175b:	c1 e2 07             	shl    $0x7,%edx
  80175e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801764:	8b 12                	mov    (%edx),%edx
  801766:	39 ca                	cmp    %ecx,%edx
  801768:	75 0f                	jne    801779 <ipc_find_env+0x39>
			return envs[i].env_id;
  80176a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  80176e:	c1 e0 06             	shl    $0x6,%eax
  801771:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801777:	eb 0e                	jmp    801787 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801779:	83 c0 01             	add    $0x1,%eax
  80177c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801781:	75 d6                	jne    801759 <ipc_find_env+0x19>
  801783:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	57                   	push   %edi
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
  80178f:	83 ec 1c             	sub    $0x1c,%esp
  801792:	8b 75 08             	mov    0x8(%ebp),%esi
  801795:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801798:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80179b:	85 db                	test   %ebx,%ebx
  80179d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8017a2:	0f 44 d8             	cmove  %eax,%ebx
  8017a5:	eb 25                	jmp    8017cc <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8017a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017aa:	74 20                	je     8017cc <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8017ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b0:	c7 44 24 08 c8 30 80 	movl   $0x8030c8,0x8(%esp)
  8017b7:	00 
  8017b8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8017bf:	00 
  8017c0:	c7 04 24 e6 30 80 00 	movl   $0x8030e6,(%esp)
  8017c7:	e8 38 eb ff ff       	call   800304 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8017cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8017cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017db:	89 34 24             	mov    %esi,(%esp)
  8017de:	e8 2b f8 ff ff       	call   80100e <sys_ipc_try_send>
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	75 c0                	jne    8017a7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8017e7:	e8 a8 f9 ff ff       	call   801194 <sys_yield>
}
  8017ec:	83 c4 1c             	add    $0x1c,%esp
  8017ef:	5b                   	pop    %ebx
  8017f0:	5e                   	pop    %esi
  8017f1:	5f                   	pop    %edi
  8017f2:	5d                   	pop    %ebp
  8017f3:	c3                   	ret    

008017f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 28             	sub    $0x28,%esp
  8017fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801800:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801803:	8b 75 08             	mov    0x8(%ebp),%esi
  801806:	8b 45 0c             	mov    0xc(%ebp),%eax
  801809:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80180c:	85 c0                	test   %eax,%eax
  80180e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801813:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801816:	89 04 24             	mov    %eax,(%esp)
  801819:	e8 b7 f7 ff ff       	call   800fd5 <sys_ipc_recv>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	85 c0                	test   %eax,%eax
  801822:	79 2a                	jns    80184e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801824:	89 44 24 08          	mov    %eax,0x8(%esp)
  801828:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182c:	c7 04 24 f0 30 80 00 	movl   $0x8030f0,(%esp)
  801833:	e8 85 eb ff ff       	call   8003bd <cprintf>
		if(from_env_store != NULL)
  801838:	85 f6                	test   %esi,%esi
  80183a:	74 06                	je     801842 <ipc_recv+0x4e>
			*from_env_store = 0;
  80183c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801842:	85 ff                	test   %edi,%edi
  801844:	74 2c                	je     801872 <ipc_recv+0x7e>
			*perm_store = 0;
  801846:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80184c:	eb 24                	jmp    801872 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80184e:	85 f6                	test   %esi,%esi
  801850:	74 0a                	je     80185c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801852:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801857:	8b 40 74             	mov    0x74(%eax),%eax
  80185a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80185c:	85 ff                	test   %edi,%edi
  80185e:	74 0a                	je     80186a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801860:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801865:	8b 40 78             	mov    0x78(%eax),%eax
  801868:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80186a:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80186f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801872:	89 d8                	mov    %ebx,%eax
  801874:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801877:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80187a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80187d:	89 ec                	mov    %ebp,%esp
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    
	...

00801890 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	8b 45 08             	mov    0x8(%ebp),%eax
  801896:	05 00 00 00 30       	add    $0x30000000,%eax
  80189b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8018a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a9:	89 04 24             	mov    %eax,(%esp)
  8018ac:	e8 df ff ff ff       	call   801890 <fd2num>
  8018b1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8018b6:	c1 e0 0c             	shl    $0xc,%eax
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	57                   	push   %edi
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8018c4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8018c9:	a8 01                	test   $0x1,%al
  8018cb:	74 36                	je     801903 <fd_alloc+0x48>
  8018cd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8018d2:	a8 01                	test   $0x1,%al
  8018d4:	74 2d                	je     801903 <fd_alloc+0x48>
  8018d6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8018db:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8018e0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	89 c2                	mov    %eax,%edx
  8018e9:	c1 ea 16             	shr    $0x16,%edx
  8018ec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8018ef:	f6 c2 01             	test   $0x1,%dl
  8018f2:	74 14                	je     801908 <fd_alloc+0x4d>
  8018f4:	89 c2                	mov    %eax,%edx
  8018f6:	c1 ea 0c             	shr    $0xc,%edx
  8018f9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8018fc:	f6 c2 01             	test   $0x1,%dl
  8018ff:	75 10                	jne    801911 <fd_alloc+0x56>
  801901:	eb 05                	jmp    801908 <fd_alloc+0x4d>
  801903:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801908:	89 1f                	mov    %ebx,(%edi)
  80190a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80190f:	eb 17                	jmp    801928 <fd_alloc+0x6d>
  801911:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801916:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80191b:	75 c8                	jne    8018e5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80191d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801923:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	5f                   	pop    %edi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    

0080192d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80192d:	55                   	push   %ebp
  80192e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	83 f8 1f             	cmp    $0x1f,%eax
  801936:	77 36                	ja     80196e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801938:	05 00 00 0d 00       	add    $0xd0000,%eax
  80193d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801940:	89 c2                	mov    %eax,%edx
  801942:	c1 ea 16             	shr    $0x16,%edx
  801945:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80194c:	f6 c2 01             	test   $0x1,%dl
  80194f:	74 1d                	je     80196e <fd_lookup+0x41>
  801951:	89 c2                	mov    %eax,%edx
  801953:	c1 ea 0c             	shr    $0xc,%edx
  801956:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80195d:	f6 c2 01             	test   $0x1,%dl
  801960:	74 0c                	je     80196e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801962:	8b 55 0c             	mov    0xc(%ebp),%edx
  801965:	89 02                	mov    %eax,(%edx)
  801967:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80196c:	eb 05                	jmp    801973 <fd_lookup+0x46>
  80196e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801973:	5d                   	pop    %ebp
  801974:	c3                   	ret    

00801975 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80197b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80197e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
  801985:	89 04 24             	mov    %eax,(%esp)
  801988:	e8 a0 ff ff ff       	call   80192d <fd_lookup>
  80198d:	85 c0                	test   %eax,%eax
  80198f:	78 0e                	js     80199f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801991:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801994:	8b 55 0c             	mov    0xc(%ebp),%edx
  801997:	89 50 04             	mov    %edx,0x4(%eax)
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80199f:	c9                   	leave  
  8019a0:	c3                   	ret    

008019a1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 10             	sub    $0x10,%esp
  8019a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8019af:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8019b4:	b8 04 40 80 00       	mov    $0x804004,%eax
  8019b9:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  8019bf:	75 11                	jne    8019d2 <dev_lookup+0x31>
  8019c1:	eb 04                	jmp    8019c7 <dev_lookup+0x26>
  8019c3:	39 08                	cmp    %ecx,(%eax)
  8019c5:	75 10                	jne    8019d7 <dev_lookup+0x36>
			*dev = devtab[i];
  8019c7:	89 03                	mov    %eax,(%ebx)
  8019c9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8019ce:	66 90                	xchg   %ax,%ax
  8019d0:	eb 36                	jmp    801a08 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8019d2:	be 84 31 80 00       	mov    $0x803184,%esi
  8019d7:	83 c2 01             	add    $0x1,%edx
  8019da:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	75 e2                	jne    8019c3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019e1:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8019e6:	8b 40 48             	mov    0x48(%eax),%eax
  8019e9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f1:	c7 04 24 04 31 80 00 	movl   $0x803104,(%esp)
  8019f8:	e8 c0 e9 ff ff       	call   8003bd <cprintf>
	*dev = 0;
  8019fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801a08:	83 c4 10             	add    $0x10,%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	53                   	push   %ebx
  801a13:	83 ec 24             	sub    $0x24,%esp
  801a16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a20:	8b 45 08             	mov    0x8(%ebp),%eax
  801a23:	89 04 24             	mov    %eax,(%esp)
  801a26:	e8 02 ff ff ff       	call   80192d <fd_lookup>
  801a2b:	85 c0                	test   %eax,%eax
  801a2d:	78 53                	js     801a82 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a39:	8b 00                	mov    (%eax),%eax
  801a3b:	89 04 24             	mov    %eax,(%esp)
  801a3e:	e8 5e ff ff ff       	call   8019a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a43:	85 c0                	test   %eax,%eax
  801a45:	78 3b                	js     801a82 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801a47:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a4f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801a53:	74 2d                	je     801a82 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a55:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a58:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a5f:	00 00 00 
	stat->st_isdir = 0;
  801a62:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a69:	00 00 00 
	stat->st_dev = dev;
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a79:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a7c:	89 14 24             	mov    %edx,(%esp)
  801a7f:	ff 50 14             	call   *0x14(%eax)
}
  801a82:	83 c4 24             	add    $0x24,%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	53                   	push   %ebx
  801a8c:	83 ec 24             	sub    $0x24,%esp
  801a8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a99:	89 1c 24             	mov    %ebx,(%esp)
  801a9c:	e8 8c fe ff ff       	call   80192d <fd_lookup>
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	78 5f                	js     801b04 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801aa5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aaf:	8b 00                	mov    (%eax),%eax
  801ab1:	89 04 24             	mov    %eax,(%esp)
  801ab4:	e8 e8 fe ff ff       	call   8019a1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	78 47                	js     801b04 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801abd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ac0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801ac4:	75 23                	jne    801ae9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ac6:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801acb:	8b 40 48             	mov    0x48(%eax),%eax
  801ace:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ad2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ad6:	c7 04 24 24 31 80 00 	movl   $0x803124,(%esp)
  801add:	e8 db e8 ff ff       	call   8003bd <cprintf>
  801ae2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801ae7:	eb 1b                	jmp    801b04 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aec:	8b 48 18             	mov    0x18(%eax),%ecx
  801aef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801af4:	85 c9                	test   %ecx,%ecx
  801af6:	74 0c                	je     801b04 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801afb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aff:	89 14 24             	mov    %edx,(%esp)
  801b02:	ff d1                	call   *%ecx
}
  801b04:	83 c4 24             	add    $0x24,%esp
  801b07:	5b                   	pop    %ebx
  801b08:	5d                   	pop    %ebp
  801b09:	c3                   	ret    

00801b0a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	53                   	push   %ebx
  801b0e:	83 ec 24             	sub    $0x24,%esp
  801b11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1b:	89 1c 24             	mov    %ebx,(%esp)
  801b1e:	e8 0a fe ff ff       	call   80192d <fd_lookup>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 66                	js     801b8d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b31:	8b 00                	mov    (%eax),%eax
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 66 fe ff ff       	call   8019a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	78 4e                	js     801b8d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b42:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b46:	75 23                	jne    801b6b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b48:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801b4d:	8b 40 48             	mov    0x48(%eax),%eax
  801b50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b58:	c7 04 24 48 31 80 00 	movl   $0x803148,(%esp)
  801b5f:	e8 59 e8 ff ff       	call   8003bd <cprintf>
  801b64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801b69:	eb 22                	jmp    801b8d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801b71:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b76:	85 c9                	test   %ecx,%ecx
  801b78:	74 13                	je     801b8d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b7d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b88:	89 14 24             	mov    %edx,(%esp)
  801b8b:	ff d1                	call   *%ecx
}
  801b8d:	83 c4 24             	add    $0x24,%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	53                   	push   %ebx
  801b97:	83 ec 24             	sub    $0x24,%esp
  801b9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba4:	89 1c 24             	mov    %ebx,(%esp)
  801ba7:	e8 81 fd ff ff       	call   80192d <fd_lookup>
  801bac:	85 c0                	test   %eax,%eax
  801bae:	78 6b                	js     801c1b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bba:	8b 00                	mov    (%eax),%eax
  801bbc:	89 04 24             	mov    %eax,(%esp)
  801bbf:	e8 dd fd ff ff       	call   8019a1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bc4:	85 c0                	test   %eax,%eax
  801bc6:	78 53                	js     801c1b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801bc8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bcb:	8b 42 08             	mov    0x8(%edx),%eax
  801bce:	83 e0 03             	and    $0x3,%eax
  801bd1:	83 f8 01             	cmp    $0x1,%eax
  801bd4:	75 23                	jne    801bf9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801bd6:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801bdb:	8b 40 48             	mov    0x48(%eax),%eax
  801bde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be6:	c7 04 24 65 31 80 00 	movl   $0x803165,(%esp)
  801bed:	e8 cb e7 ff ff       	call   8003bd <cprintf>
  801bf2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801bf7:	eb 22                	jmp    801c1b <read+0x88>
	}
	if (!dev->dev_read)
  801bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfc:	8b 48 08             	mov    0x8(%eax),%ecx
  801bff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c04:	85 c9                	test   %ecx,%ecx
  801c06:	74 13                	je     801c1b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c08:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c16:	89 14 24             	mov    %edx,(%esp)
  801c19:	ff d1                	call   *%ecx
}
  801c1b:	83 c4 24             	add    $0x24,%esp
  801c1e:	5b                   	pop    %ebx
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	57                   	push   %edi
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	83 ec 1c             	sub    $0x1c,%esp
  801c2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c30:	ba 00 00 00 00       	mov    $0x0,%edx
  801c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3f:	85 f6                	test   %esi,%esi
  801c41:	74 29                	je     801c6c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c43:	89 f0                	mov    %esi,%eax
  801c45:	29 d0                	sub    %edx,%eax
  801c47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c4b:	03 55 0c             	add    0xc(%ebp),%edx
  801c4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c52:	89 3c 24             	mov    %edi,(%esp)
  801c55:	e8 39 ff ff ff       	call   801b93 <read>
		if (m < 0)
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	78 0e                	js     801c6c <readn+0x4b>
			return m;
		if (m == 0)
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	74 08                	je     801c6a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c62:	01 c3                	add    %eax,%ebx
  801c64:	89 da                	mov    %ebx,%edx
  801c66:	39 f3                	cmp    %esi,%ebx
  801c68:	72 d9                	jb     801c43 <readn+0x22>
  801c6a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801c6c:	83 c4 1c             	add    $0x1c,%esp
  801c6f:	5b                   	pop    %ebx
  801c70:	5e                   	pop    %esi
  801c71:	5f                   	pop    %edi
  801c72:	5d                   	pop    %ebp
  801c73:	c3                   	ret    

00801c74 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c74:	55                   	push   %ebp
  801c75:	89 e5                	mov    %esp,%ebp
  801c77:	83 ec 28             	sub    $0x28,%esp
  801c7a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c7d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c80:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c83:	89 34 24             	mov    %esi,(%esp)
  801c86:	e8 05 fc ff ff       	call   801890 <fd2num>
  801c8b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c92:	89 04 24             	mov    %eax,(%esp)
  801c95:	e8 93 fc ff ff       	call   80192d <fd_lookup>
  801c9a:	89 c3                	mov    %eax,%ebx
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 05                	js     801ca5 <fd_close+0x31>
  801ca0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ca3:	74 0e                	je     801cb3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801ca5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ca9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cae:	0f 44 d8             	cmove  %eax,%ebx
  801cb1:	eb 3d                	jmp    801cf0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801cb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cba:	8b 06                	mov    (%esi),%eax
  801cbc:	89 04 24             	mov    %eax,(%esp)
  801cbf:	e8 dd fc ff ff       	call   8019a1 <dev_lookup>
  801cc4:	89 c3                	mov    %eax,%ebx
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 16                	js     801ce0 <fd_close+0x6c>
		if (dev->dev_close)
  801cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ccd:	8b 40 10             	mov    0x10(%eax),%eax
  801cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd5:	85 c0                	test   %eax,%eax
  801cd7:	74 07                	je     801ce0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801cd9:	89 34 24             	mov    %esi,(%esp)
  801cdc:	ff d0                	call   *%eax
  801cde:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801ce0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ce4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ceb:	e8 fc f3 ff ff       	call   8010ec <sys_page_unmap>
	return r;
}
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801cf5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801cf8:	89 ec                	mov    %ebp,%esp
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d05:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	89 04 24             	mov    %eax,(%esp)
  801d0f:	e8 19 fc ff ff       	call   80192d <fd_lookup>
  801d14:	85 c0                	test   %eax,%eax
  801d16:	78 13                	js     801d2b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801d18:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d1f:	00 
  801d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d23:	89 04 24             	mov    %eax,(%esp)
  801d26:	e8 49 ff ff ff       	call   801c74 <fd_close>
}
  801d2b:	c9                   	leave  
  801d2c:	c3                   	ret    

00801d2d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801d2d:	55                   	push   %ebp
  801d2e:	89 e5                	mov    %esp,%ebp
  801d30:	83 ec 18             	sub    $0x18,%esp
  801d33:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d36:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d40:	00 
  801d41:	8b 45 08             	mov    0x8(%ebp),%eax
  801d44:	89 04 24             	mov    %eax,(%esp)
  801d47:	e8 78 03 00 00       	call   8020c4 <open>
  801d4c:	89 c3                	mov    %eax,%ebx
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	78 1b                	js     801d6d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d59:	89 1c 24             	mov    %ebx,(%esp)
  801d5c:	e8 ae fc ff ff       	call   801a0f <fstat>
  801d61:	89 c6                	mov    %eax,%esi
	close(fd);
  801d63:	89 1c 24             	mov    %ebx,(%esp)
  801d66:	e8 91 ff ff ff       	call   801cfc <close>
  801d6b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801d6d:	89 d8                	mov    %ebx,%eax
  801d6f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d72:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d75:	89 ec                	mov    %ebp,%esp
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    

00801d79 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	53                   	push   %ebx
  801d7d:	83 ec 14             	sub    $0x14,%esp
  801d80:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801d85:	89 1c 24             	mov    %ebx,(%esp)
  801d88:	e8 6f ff ff ff       	call   801cfc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d8d:	83 c3 01             	add    $0x1,%ebx
  801d90:	83 fb 20             	cmp    $0x20,%ebx
  801d93:	75 f0                	jne    801d85 <close_all+0xc>
		close(i);
}
  801d95:	83 c4 14             	add    $0x14,%esp
  801d98:	5b                   	pop    %ebx
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 58             	sub    $0x58,%esp
  801da1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801da4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801da7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801daa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801dad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801db0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801db4:	8b 45 08             	mov    0x8(%ebp),%eax
  801db7:	89 04 24             	mov    %eax,(%esp)
  801dba:	e8 6e fb ff ff       	call   80192d <fd_lookup>
  801dbf:	89 c3                	mov    %eax,%ebx
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	0f 88 e0 00 00 00    	js     801ea9 <dup+0x10e>
		return r;
	close(newfdnum);
  801dc9:	89 3c 24             	mov    %edi,(%esp)
  801dcc:	e8 2b ff ff ff       	call   801cfc <close>

	newfd = INDEX2FD(newfdnum);
  801dd1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801dd7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ddd:	89 04 24             	mov    %eax,(%esp)
  801de0:	e8 bb fa ff ff       	call   8018a0 <fd2data>
  801de5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801de7:	89 34 24             	mov    %esi,(%esp)
  801dea:	e8 b1 fa ff ff       	call   8018a0 <fd2data>
  801def:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801df2:	89 da                	mov    %ebx,%edx
  801df4:	89 d8                	mov    %ebx,%eax
  801df6:	c1 e8 16             	shr    $0x16,%eax
  801df9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e00:	a8 01                	test   $0x1,%al
  801e02:	74 43                	je     801e47 <dup+0xac>
  801e04:	c1 ea 0c             	shr    $0xc,%edx
  801e07:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e0e:	a8 01                	test   $0x1,%al
  801e10:	74 35                	je     801e47 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e12:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e19:	25 07 0e 00 00       	and    $0xe07,%eax
  801e1e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e22:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e25:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e29:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e30:	00 
  801e31:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e3c:	e8 e3 f2 ff ff       	call   801124 <sys_page_map>
  801e41:	89 c3                	mov    %eax,%ebx
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 3f                	js     801e86 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e4a:	89 c2                	mov    %eax,%edx
  801e4c:	c1 ea 0c             	shr    $0xc,%edx
  801e4f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e56:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801e5c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e60:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e64:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e6b:	00 
  801e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e77:	e8 a8 f2 ff ff       	call   801124 <sys_page_map>
  801e7c:	89 c3                	mov    %eax,%ebx
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	78 04                	js     801e86 <dup+0xeb>
  801e82:	89 fb                	mov    %edi,%ebx
  801e84:	eb 23                	jmp    801ea9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e8a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e91:	e8 56 f2 ff ff       	call   8010ec <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea4:	e8 43 f2 ff ff       	call   8010ec <sys_page_unmap>
	return r;
}
  801ea9:	89 d8                	mov    %ebx,%eax
  801eab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801eae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801eb1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801eb4:	89 ec                	mov    %ebp,%esp
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    

00801eb8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	83 ec 18             	sub    $0x18,%esp
  801ebe:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ec1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801ec8:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801ecf:	75 11                	jne    801ee2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ed1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ed8:	e8 63 f8 ff ff       	call   801740 <ipc_find_env>
  801edd:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ee2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ee9:	00 
  801eea:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ef1:	00 
  801ef2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ef6:	a1 04 50 80 00       	mov    0x805004,%eax
  801efb:	89 04 24             	mov    %eax,(%esp)
  801efe:	e8 86 f8 ff ff       	call   801789 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f0a:	00 
  801f0b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f16:	e8 d9 f8 ff ff       	call   8017f4 <ipc_recv>
}
  801f1b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f1e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f21:	89 ec                	mov    %ebp,%esp
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    

00801f25 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f25:	55                   	push   %ebp
  801f26:	89 e5                	mov    %esp,%ebp
  801f28:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f31:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801f36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f39:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f43:	b8 02 00 00 00       	mov    $0x2,%eax
  801f48:	e8 6b ff ff ff       	call   801eb8 <fsipc>
}
  801f4d:	c9                   	leave  
  801f4e:	c3                   	ret    

00801f4f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f55:	8b 45 08             	mov    0x8(%ebp),%eax
  801f58:	8b 40 0c             	mov    0xc(%eax),%eax
  801f5b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f60:	ba 00 00 00 00       	mov    $0x0,%edx
  801f65:	b8 06 00 00 00       	mov    $0x6,%eax
  801f6a:	e8 49 ff ff ff       	call   801eb8 <fsipc>
}
  801f6f:	c9                   	leave  
  801f70:	c3                   	ret    

00801f71 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f77:	ba 00 00 00 00       	mov    $0x0,%edx
  801f7c:	b8 08 00 00 00       	mov    $0x8,%eax
  801f81:	e8 32 ff ff ff       	call   801eb8 <fsipc>
}
  801f86:	c9                   	leave  
  801f87:	c3                   	ret    

00801f88 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	53                   	push   %ebx
  801f8c:	83 ec 14             	sub    $0x14,%esp
  801f8f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	8b 40 0c             	mov    0xc(%eax),%eax
  801f98:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f9d:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa2:	b8 05 00 00 00       	mov    $0x5,%eax
  801fa7:	e8 0c ff ff ff       	call   801eb8 <fsipc>
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 2b                	js     801fdb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fb0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fb7:	00 
  801fb8:	89 1c 24             	mov    %ebx,(%esp)
  801fbb:	e8 3a eb ff ff       	call   800afa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801fc0:	a1 80 60 80 00       	mov    0x806080,%eax
  801fc5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801fcb:	a1 84 60 80 00       	mov    0x806084,%eax
  801fd0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801fd6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801fdb:	83 c4 14             	add    $0x14,%esp
  801fde:	5b                   	pop    %ebx
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    

00801fe1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801fe1:	55                   	push   %ebp
  801fe2:	89 e5                	mov    %esp,%ebp
  801fe4:	83 ec 18             	sub    $0x18,%esp
  801fe7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801fea:	8b 55 08             	mov    0x8(%ebp),%edx
  801fed:	8b 52 0c             	mov    0xc(%edx),%edx
  801ff0:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801ff6:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801ffb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802000:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802005:	0f 47 c2             	cmova  %edx,%eax
  802008:	89 44 24 08          	mov    %eax,0x8(%esp)
  80200c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80200f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802013:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80201a:	e8 c6 ec ff ff       	call   800ce5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80201f:	ba 00 00 00 00       	mov    $0x0,%edx
  802024:	b8 04 00 00 00       	mov    $0x4,%eax
  802029:	e8 8a fe ff ff       	call   801eb8 <fsipc>
}
  80202e:	c9                   	leave  
  80202f:	c3                   	ret    

00802030 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	53                   	push   %ebx
  802034:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  802037:	8b 45 08             	mov    0x8(%ebp),%eax
  80203a:	8b 40 0c             	mov    0xc(%eax),%eax
  80203d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  802042:	8b 45 10             	mov    0x10(%ebp),%eax
  802045:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80204a:	ba 00 00 00 00       	mov    $0x0,%edx
  80204f:	b8 03 00 00 00       	mov    $0x3,%eax
  802054:	e8 5f fe ff ff       	call   801eb8 <fsipc>
  802059:	89 c3                	mov    %eax,%ebx
  80205b:	85 c0                	test   %eax,%eax
  80205d:	78 17                	js     802076 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80205f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802063:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80206a:	00 
  80206b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80206e:	89 04 24             	mov    %eax,(%esp)
  802071:	e8 6f ec ff ff       	call   800ce5 <memmove>
  return r;	
}
  802076:	89 d8                	mov    %ebx,%eax
  802078:	83 c4 14             	add    $0x14,%esp
  80207b:	5b                   	pop    %ebx
  80207c:	5d                   	pop    %ebp
  80207d:	c3                   	ret    

0080207e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80207e:	55                   	push   %ebp
  80207f:	89 e5                	mov    %esp,%ebp
  802081:	53                   	push   %ebx
  802082:	83 ec 14             	sub    $0x14,%esp
  802085:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  802088:	89 1c 24             	mov    %ebx,(%esp)
  80208b:	e8 20 ea ff ff       	call   800ab0 <strlen>
  802090:	89 c2                	mov    %eax,%edx
  802092:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  802097:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80209d:	7f 1f                	jg     8020be <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80209f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020a3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8020aa:	e8 4b ea ff ff       	call   800afa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8020af:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b4:	b8 07 00 00 00       	mov    $0x7,%eax
  8020b9:	e8 fa fd ff ff       	call   801eb8 <fsipc>
}
  8020be:	83 c4 14             	add    $0x14,%esp
  8020c1:	5b                   	pop    %ebx
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    

008020c4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
  8020c7:	83 ec 28             	sub    $0x28,%esp
  8020ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8020cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8020d0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8020d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d6:	89 04 24             	mov    %eax,(%esp)
  8020d9:	e8 dd f7 ff ff       	call   8018bb <fd_alloc>
  8020de:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	0f 88 89 00 00 00    	js     802171 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8020e8:	89 34 24             	mov    %esi,(%esp)
  8020eb:	e8 c0 e9 ff ff       	call   800ab0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8020f0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8020f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8020fa:	7f 75                	jg     802171 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8020fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  802100:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802107:	e8 ee e9 ff ff       	call   800afa <strcpy>
  fsipcbuf.open.req_omode = mode;
  80210c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80210f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  802114:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802117:	b8 01 00 00 00       	mov    $0x1,%eax
  80211c:	e8 97 fd ff ff       	call   801eb8 <fsipc>
  802121:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  802123:	85 c0                	test   %eax,%eax
  802125:	78 0f                	js     802136 <open+0x72>
  return fd2num(fd);
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	89 04 24             	mov    %eax,(%esp)
  80212d:	e8 5e f7 ff ff       	call   801890 <fd2num>
  802132:	89 c3                	mov    %eax,%ebx
  802134:	eb 3b                	jmp    802171 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  802136:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80213d:	00 
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	89 04 24             	mov    %eax,(%esp)
  802144:	e8 2b fb ff ff       	call   801c74 <fd_close>
  802149:	85 c0                	test   %eax,%eax
  80214b:	74 24                	je     802171 <open+0xad>
  80214d:	c7 44 24 0c 90 31 80 	movl   $0x803190,0xc(%esp)
  802154:	00 
  802155:	c7 44 24 08 a5 31 80 	movl   $0x8031a5,0x8(%esp)
  80215c:	00 
  80215d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  802164:	00 
  802165:	c7 04 24 ba 31 80 00 	movl   $0x8031ba,(%esp)
  80216c:	e8 93 e1 ff ff       	call   800304 <_panic>
  return r;
}
  802171:	89 d8                	mov    %ebx,%eax
  802173:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802176:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802179:	89 ec                	mov    %ebp,%esp
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
  80217d:	00 00                	add    %al,(%eax)
	...

00802180 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802186:	c7 44 24 04 c5 31 80 	movl   $0x8031c5,0x4(%esp)
  80218d:	00 
  80218e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802191:	89 04 24             	mov    %eax,(%esp)
  802194:	e8 61 e9 ff ff       	call   800afa <strcpy>
	return 0;
}
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	53                   	push   %ebx
  8021a4:	83 ec 14             	sub    $0x14,%esp
  8021a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8021aa:	89 1c 24             	mov    %ebx,(%esp)
  8021ad:	e8 6a 05 00 00       	call   80271c <pageref>
  8021b2:	89 c2                	mov    %eax,%edx
  8021b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b9:	83 fa 01             	cmp    $0x1,%edx
  8021bc:	75 0b                	jne    8021c9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8021be:	8b 43 0c             	mov    0xc(%ebx),%eax
  8021c1:	89 04 24             	mov    %eax,(%esp)
  8021c4:	e8 b9 02 00 00       	call   802482 <nsipc_close>
	else
		return 0;
}
  8021c9:	83 c4 14             	add    $0x14,%esp
  8021cc:	5b                   	pop    %ebx
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    

008021cf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8021d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8021dc:	00 
  8021dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8021e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8021f1:	89 04 24             	mov    %eax,(%esp)
  8021f4:	e8 c5 02 00 00       	call   8024be <nsipc_send>
}
  8021f9:	c9                   	leave  
  8021fa:	c3                   	ret    

008021fb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8021fb:	55                   	push   %ebp
  8021fc:	89 e5                	mov    %esp,%ebp
  8021fe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802201:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802208:	00 
  802209:	8b 45 10             	mov    0x10(%ebp),%eax
  80220c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802210:	8b 45 0c             	mov    0xc(%ebp),%eax
  802213:	89 44 24 04          	mov    %eax,0x4(%esp)
  802217:	8b 45 08             	mov    0x8(%ebp),%eax
  80221a:	8b 40 0c             	mov    0xc(%eax),%eax
  80221d:	89 04 24             	mov    %eax,(%esp)
  802220:	e8 0c 03 00 00       	call   802531 <nsipc_recv>
}
  802225:	c9                   	leave  
  802226:	c3                   	ret    

00802227 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802227:	55                   	push   %ebp
  802228:	89 e5                	mov    %esp,%ebp
  80222a:	56                   	push   %esi
  80222b:	53                   	push   %ebx
  80222c:	83 ec 20             	sub    $0x20,%esp
  80222f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802231:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802234:	89 04 24             	mov    %eax,(%esp)
  802237:	e8 7f f6 ff ff       	call   8018bb <fd_alloc>
  80223c:	89 c3                	mov    %eax,%ebx
  80223e:	85 c0                	test   %eax,%eax
  802240:	78 21                	js     802263 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802242:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802249:	00 
  80224a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80224d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802251:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802258:	e8 00 ef ff ff       	call   80115d <sys_page_alloc>
  80225d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80225f:	85 c0                	test   %eax,%eax
  802261:	79 0a                	jns    80226d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802263:	89 34 24             	mov    %esi,(%esp)
  802266:	e8 17 02 00 00       	call   802482 <nsipc_close>
		return r;
  80226b:	eb 28                	jmp    802295 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80226d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802273:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802276:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802285:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228b:	89 04 24             	mov    %eax,(%esp)
  80228e:	e8 fd f5 ff ff       	call   801890 <fd2num>
  802293:	89 c3                	mov    %eax,%ebx
}
  802295:	89 d8                	mov    %ebx,%eax
  802297:	83 c4 20             	add    $0x20,%esp
  80229a:	5b                   	pop    %ebx
  80229b:	5e                   	pop    %esi
  80229c:	5d                   	pop    %ebp
  80229d:	c3                   	ret    

0080229e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80229e:	55                   	push   %ebp
  80229f:	89 e5                	mov    %esp,%ebp
  8022a1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8022a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8022a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b5:	89 04 24             	mov    %eax,(%esp)
  8022b8:	e8 79 01 00 00       	call   802436 <nsipc_socket>
  8022bd:	85 c0                	test   %eax,%eax
  8022bf:	78 05                	js     8022c6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8022c1:	e8 61 ff ff ff       	call   802227 <alloc_sockfd>
}
  8022c6:	c9                   	leave  
  8022c7:	c3                   	ret    

008022c8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8022ce:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d5:	89 04 24             	mov    %eax,(%esp)
  8022d8:	e8 50 f6 ff ff       	call   80192d <fd_lookup>
  8022dd:	85 c0                	test   %eax,%eax
  8022df:	78 15                	js     8022f6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8022e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022e4:	8b 0a                	mov    (%edx),%ecx
  8022e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8022eb:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8022f1:	75 03                	jne    8022f6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8022f3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8022f6:	c9                   	leave  
  8022f7:	c3                   	ret    

008022f8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8022f8:	55                   	push   %ebp
  8022f9:	89 e5                	mov    %esp,%ebp
  8022fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802301:	e8 c2 ff ff ff       	call   8022c8 <fd2sockid>
  802306:	85 c0                	test   %eax,%eax
  802308:	78 0f                	js     802319 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80230a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80230d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802311:	89 04 24             	mov    %eax,(%esp)
  802314:	e8 47 01 00 00       	call   802460 <nsipc_listen>
}
  802319:	c9                   	leave  
  80231a:	c3                   	ret    

0080231b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802321:	8b 45 08             	mov    0x8(%ebp),%eax
  802324:	e8 9f ff ff ff       	call   8022c8 <fd2sockid>
  802329:	85 c0                	test   %eax,%eax
  80232b:	78 16                	js     802343 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80232d:	8b 55 10             	mov    0x10(%ebp),%edx
  802330:	89 54 24 08          	mov    %edx,0x8(%esp)
  802334:	8b 55 0c             	mov    0xc(%ebp),%edx
  802337:	89 54 24 04          	mov    %edx,0x4(%esp)
  80233b:	89 04 24             	mov    %eax,(%esp)
  80233e:	e8 6e 02 00 00       	call   8025b1 <nsipc_connect>
}
  802343:	c9                   	leave  
  802344:	c3                   	ret    

00802345 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802345:	55                   	push   %ebp
  802346:	89 e5                	mov    %esp,%ebp
  802348:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80234b:	8b 45 08             	mov    0x8(%ebp),%eax
  80234e:	e8 75 ff ff ff       	call   8022c8 <fd2sockid>
  802353:	85 c0                	test   %eax,%eax
  802355:	78 0f                	js     802366 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802357:	8b 55 0c             	mov    0xc(%ebp),%edx
  80235a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80235e:	89 04 24             	mov    %eax,(%esp)
  802361:	e8 36 01 00 00       	call   80249c <nsipc_shutdown>
}
  802366:	c9                   	leave  
  802367:	c3                   	ret    

00802368 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802368:	55                   	push   %ebp
  802369:	89 e5                	mov    %esp,%ebp
  80236b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80236e:	8b 45 08             	mov    0x8(%ebp),%eax
  802371:	e8 52 ff ff ff       	call   8022c8 <fd2sockid>
  802376:	85 c0                	test   %eax,%eax
  802378:	78 16                	js     802390 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80237a:	8b 55 10             	mov    0x10(%ebp),%edx
  80237d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802381:	8b 55 0c             	mov    0xc(%ebp),%edx
  802384:	89 54 24 04          	mov    %edx,0x4(%esp)
  802388:	89 04 24             	mov    %eax,(%esp)
  80238b:	e8 60 02 00 00       	call   8025f0 <nsipc_bind>
}
  802390:	c9                   	leave  
  802391:	c3                   	ret    

00802392 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802398:	8b 45 08             	mov    0x8(%ebp),%eax
  80239b:	e8 28 ff ff ff       	call   8022c8 <fd2sockid>
  8023a0:	85 c0                	test   %eax,%eax
  8023a2:	78 1f                	js     8023c3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8023a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8023a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023b2:	89 04 24             	mov    %eax,(%esp)
  8023b5:	e8 75 02 00 00       	call   80262f <nsipc_accept>
  8023ba:	85 c0                	test   %eax,%eax
  8023bc:	78 05                	js     8023c3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8023be:	e8 64 fe ff ff       	call   802227 <alloc_sockfd>
}
  8023c3:	c9                   	leave  
  8023c4:	c3                   	ret    
	...

008023d0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	53                   	push   %ebx
  8023d4:	83 ec 14             	sub    $0x14,%esp
  8023d7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8023d9:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  8023e0:	75 11                	jne    8023f3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8023e2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8023e9:	e8 52 f3 ff ff       	call   801740 <ipc_find_env>
  8023ee:	a3 08 50 80 00       	mov    %eax,0x805008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8023f3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8023fa:	00 
  8023fb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802402:	00 
  802403:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802407:	a1 08 50 80 00       	mov    0x805008,%eax
  80240c:	89 04 24             	mov    %eax,(%esp)
  80240f:	e8 75 f3 ff ff       	call   801789 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802414:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80241b:	00 
  80241c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802423:	00 
  802424:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80242b:	e8 c4 f3 ff ff       	call   8017f4 <ipc_recv>
}
  802430:	83 c4 14             	add    $0x14,%esp
  802433:	5b                   	pop    %ebx
  802434:	5d                   	pop    %ebp
  802435:	c3                   	ret    

00802436 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802436:	55                   	push   %ebp
  802437:	89 e5                	mov    %esp,%ebp
  802439:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80243c:	8b 45 08             	mov    0x8(%ebp),%eax
  80243f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802444:	8b 45 0c             	mov    0xc(%ebp),%eax
  802447:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80244c:	8b 45 10             	mov    0x10(%ebp),%eax
  80244f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802454:	b8 09 00 00 00       	mov    $0x9,%eax
  802459:	e8 72 ff ff ff       	call   8023d0 <nsipc>
}
  80245e:	c9                   	leave  
  80245f:	c3                   	ret    

00802460 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802466:	8b 45 08             	mov    0x8(%ebp),%eax
  802469:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80246e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802471:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802476:	b8 06 00 00 00       	mov    $0x6,%eax
  80247b:	e8 50 ff ff ff       	call   8023d0 <nsipc>
}
  802480:	c9                   	leave  
  802481:	c3                   	ret    

00802482 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802482:	55                   	push   %ebp
  802483:	89 e5                	mov    %esp,%ebp
  802485:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802488:	8b 45 08             	mov    0x8(%ebp),%eax
  80248b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802490:	b8 04 00 00 00       	mov    $0x4,%eax
  802495:	e8 36 ff ff ff       	call   8023d0 <nsipc>
}
  80249a:	c9                   	leave  
  80249b:	c3                   	ret    

0080249c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80249c:	55                   	push   %ebp
  80249d:	89 e5                	mov    %esp,%ebp
  80249f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8024a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8024a5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8024aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ad:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8024b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8024b7:	e8 14 ff ff ff       	call   8023d0 <nsipc>
}
  8024bc:	c9                   	leave  
  8024bd:	c3                   	ret    

008024be <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	53                   	push   %ebx
  8024c2:	83 ec 14             	sub    $0x14,%esp
  8024c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8024c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8024d0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8024d6:	7e 24                	jle    8024fc <nsipc_send+0x3e>
  8024d8:	c7 44 24 0c d1 31 80 	movl   $0x8031d1,0xc(%esp)
  8024df:	00 
  8024e0:	c7 44 24 08 a5 31 80 	movl   $0x8031a5,0x8(%esp)
  8024e7:	00 
  8024e8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8024ef:	00 
  8024f0:	c7 04 24 dd 31 80 00 	movl   $0x8031dd,(%esp)
  8024f7:	e8 08 de ff ff       	call   800304 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8024fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802500:	8b 45 0c             	mov    0xc(%ebp),%eax
  802503:	89 44 24 04          	mov    %eax,0x4(%esp)
  802507:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80250e:	e8 d2 e7 ff ff       	call   800ce5 <memmove>
	nsipcbuf.send.req_size = size;
  802513:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802519:	8b 45 14             	mov    0x14(%ebp),%eax
  80251c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802521:	b8 08 00 00 00       	mov    $0x8,%eax
  802526:	e8 a5 fe ff ff       	call   8023d0 <nsipc>
}
  80252b:	83 c4 14             	add    $0x14,%esp
  80252e:	5b                   	pop    %ebx
  80252f:	5d                   	pop    %ebp
  802530:	c3                   	ret    

00802531 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802531:	55                   	push   %ebp
  802532:	89 e5                	mov    %esp,%ebp
  802534:	56                   	push   %esi
  802535:	53                   	push   %ebx
  802536:	83 ec 10             	sub    $0x10,%esp
  802539:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80253c:	8b 45 08             	mov    0x8(%ebp),%eax
  80253f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802544:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80254a:	8b 45 14             	mov    0x14(%ebp),%eax
  80254d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802552:	b8 07 00 00 00       	mov    $0x7,%eax
  802557:	e8 74 fe ff ff       	call   8023d0 <nsipc>
  80255c:	89 c3                	mov    %eax,%ebx
  80255e:	85 c0                	test   %eax,%eax
  802560:	78 46                	js     8025a8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802562:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802567:	7f 04                	jg     80256d <nsipc_recv+0x3c>
  802569:	39 c6                	cmp    %eax,%esi
  80256b:	7d 24                	jge    802591 <nsipc_recv+0x60>
  80256d:	c7 44 24 0c e9 31 80 	movl   $0x8031e9,0xc(%esp)
  802574:	00 
  802575:	c7 44 24 08 a5 31 80 	movl   $0x8031a5,0x8(%esp)
  80257c:	00 
  80257d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802584:	00 
  802585:	c7 04 24 dd 31 80 00 	movl   $0x8031dd,(%esp)
  80258c:	e8 73 dd ff ff       	call   800304 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802591:	89 44 24 08          	mov    %eax,0x8(%esp)
  802595:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80259c:	00 
  80259d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025a0:	89 04 24             	mov    %eax,(%esp)
  8025a3:	e8 3d e7 ff ff       	call   800ce5 <memmove>
	}

	return r;
}
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	83 c4 10             	add    $0x10,%esp
  8025ad:	5b                   	pop    %ebx
  8025ae:	5e                   	pop    %esi
  8025af:	5d                   	pop    %ebp
  8025b0:	c3                   	ret    

008025b1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025b1:	55                   	push   %ebp
  8025b2:	89 e5                	mov    %esp,%ebp
  8025b4:	53                   	push   %ebx
  8025b5:	83 ec 14             	sub    $0x14,%esp
  8025b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8025bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8025be:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8025c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025ce:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8025d5:	e8 0b e7 ff ff       	call   800ce5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8025da:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8025e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8025e5:	e8 e6 fd ff ff       	call   8023d0 <nsipc>
}
  8025ea:	83 c4 14             	add    $0x14,%esp
  8025ed:	5b                   	pop    %ebx
  8025ee:	5d                   	pop    %ebp
  8025ef:	c3                   	ret    

008025f0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8025f0:	55                   	push   %ebp
  8025f1:	89 e5                	mov    %esp,%ebp
  8025f3:	53                   	push   %ebx
  8025f4:	83 ec 14             	sub    $0x14,%esp
  8025f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8025fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8025fd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802602:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802606:	8b 45 0c             	mov    0xc(%ebp),%eax
  802609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80260d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802614:	e8 cc e6 ff ff       	call   800ce5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802619:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80261f:	b8 02 00 00 00       	mov    $0x2,%eax
  802624:	e8 a7 fd ff ff       	call   8023d0 <nsipc>
}
  802629:	83 c4 14             	add    $0x14,%esp
  80262c:	5b                   	pop    %ebx
  80262d:	5d                   	pop    %ebp
  80262e:	c3                   	ret    

0080262f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80262f:	55                   	push   %ebp
  802630:	89 e5                	mov    %esp,%ebp
  802632:	83 ec 18             	sub    $0x18,%esp
  802635:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802638:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80263b:	8b 45 08             	mov    0x8(%ebp),%eax
  80263e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802643:	b8 01 00 00 00       	mov    $0x1,%eax
  802648:	e8 83 fd ff ff       	call   8023d0 <nsipc>
  80264d:	89 c3                	mov    %eax,%ebx
  80264f:	85 c0                	test   %eax,%eax
  802651:	78 25                	js     802678 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802653:	be 10 70 80 00       	mov    $0x807010,%esi
  802658:	8b 06                	mov    (%esi),%eax
  80265a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80265e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802665:	00 
  802666:	8b 45 0c             	mov    0xc(%ebp),%eax
  802669:	89 04 24             	mov    %eax,(%esp)
  80266c:	e8 74 e6 ff ff       	call   800ce5 <memmove>
		*addrlen = ret->ret_addrlen;
  802671:	8b 16                	mov    (%esi),%edx
  802673:	8b 45 10             	mov    0x10(%ebp),%eax
  802676:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80267d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802680:	89 ec                	mov    %ebp,%esp
  802682:	5d                   	pop    %ebp
  802683:	c3                   	ret    

00802684 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802684:	55                   	push   %ebp
  802685:	89 e5                	mov    %esp,%ebp
  802687:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80268a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802691:	75 54                	jne    8026e7 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  802693:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80269a:	00 
  80269b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8026a2:	ee 
  8026a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026aa:	e8 ae ea ff ff       	call   80115d <sys_page_alloc>
  8026af:	85 c0                	test   %eax,%eax
  8026b1:	79 20                	jns    8026d3 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8026b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026b7:	c7 44 24 08 fe 31 80 	movl   $0x8031fe,0x8(%esp)
  8026be:	00 
  8026bf:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8026c6:	00 
  8026c7:	c7 04 24 16 32 80 00 	movl   $0x803216,(%esp)
  8026ce:	e8 31 dc ff ff       	call   800304 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8026d3:	c7 44 24 04 f4 26 80 	movl   $0x8026f4,0x4(%esp)
  8026da:	00 
  8026db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026e2:	e8 5d e9 ff ff       	call   801044 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ea:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8026ef:	c9                   	leave  
  8026f0:	c3                   	ret    
  8026f1:	00 00                	add    %al,(%eax)
	...

008026f4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026f4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026f5:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8026fa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026fc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8026ff:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802703:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802706:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  80270a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80270e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802710:	83 c4 08             	add    $0x8,%esp
	popal
  802713:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  802714:	83 c4 04             	add    $0x4,%esp
	popfl
  802717:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802718:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802719:	c3                   	ret    
	...

0080271c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80271c:	55                   	push   %ebp
  80271d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80271f:	8b 45 08             	mov    0x8(%ebp),%eax
  802722:	89 c2                	mov    %eax,%edx
  802724:	c1 ea 16             	shr    $0x16,%edx
  802727:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80272e:	f6 c2 01             	test   $0x1,%dl
  802731:	74 20                	je     802753 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802733:	c1 e8 0c             	shr    $0xc,%eax
  802736:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80273d:	a8 01                	test   $0x1,%al
  80273f:	74 12                	je     802753 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802741:	c1 e8 0c             	shr    $0xc,%eax
  802744:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802749:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80274e:	0f b7 c0             	movzwl %ax,%eax
  802751:	eb 05                	jmp    802758 <pageref+0x3c>
  802753:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802758:	5d                   	pop    %ebp
  802759:	c3                   	ret    
  80275a:	00 00                	add    %al,(%eax)
  80275c:	00 00                	add    %al,(%eax)
	...

00802760 <__udivdi3>:
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	57                   	push   %edi
  802764:	56                   	push   %esi
  802765:	83 ec 10             	sub    $0x10,%esp
  802768:	8b 45 14             	mov    0x14(%ebp),%eax
  80276b:	8b 55 08             	mov    0x8(%ebp),%edx
  80276e:	8b 75 10             	mov    0x10(%ebp),%esi
  802771:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802774:	85 c0                	test   %eax,%eax
  802776:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802779:	75 35                	jne    8027b0 <__udivdi3+0x50>
  80277b:	39 fe                	cmp    %edi,%esi
  80277d:	77 61                	ja     8027e0 <__udivdi3+0x80>
  80277f:	85 f6                	test   %esi,%esi
  802781:	75 0b                	jne    80278e <__udivdi3+0x2e>
  802783:	b8 01 00 00 00       	mov    $0x1,%eax
  802788:	31 d2                	xor    %edx,%edx
  80278a:	f7 f6                	div    %esi
  80278c:	89 c6                	mov    %eax,%esi
  80278e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802791:	31 d2                	xor    %edx,%edx
  802793:	89 f8                	mov    %edi,%eax
  802795:	f7 f6                	div    %esi
  802797:	89 c7                	mov    %eax,%edi
  802799:	89 c8                	mov    %ecx,%eax
  80279b:	f7 f6                	div    %esi
  80279d:	89 c1                	mov    %eax,%ecx
  80279f:	89 fa                	mov    %edi,%edx
  8027a1:	89 c8                	mov    %ecx,%eax
  8027a3:	83 c4 10             	add    $0x10,%esp
  8027a6:	5e                   	pop    %esi
  8027a7:	5f                   	pop    %edi
  8027a8:	5d                   	pop    %ebp
  8027a9:	c3                   	ret    
  8027aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027b0:	39 f8                	cmp    %edi,%eax
  8027b2:	77 1c                	ja     8027d0 <__udivdi3+0x70>
  8027b4:	0f bd d0             	bsr    %eax,%edx
  8027b7:	83 f2 1f             	xor    $0x1f,%edx
  8027ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027bd:	75 39                	jne    8027f8 <__udivdi3+0x98>
  8027bf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8027c2:	0f 86 a0 00 00 00    	jbe    802868 <__udivdi3+0x108>
  8027c8:	39 f8                	cmp    %edi,%eax
  8027ca:	0f 82 98 00 00 00    	jb     802868 <__udivdi3+0x108>
  8027d0:	31 ff                	xor    %edi,%edi
  8027d2:	31 c9                	xor    %ecx,%ecx
  8027d4:	89 c8                	mov    %ecx,%eax
  8027d6:	89 fa                	mov    %edi,%edx
  8027d8:	83 c4 10             	add    $0x10,%esp
  8027db:	5e                   	pop    %esi
  8027dc:	5f                   	pop    %edi
  8027dd:	5d                   	pop    %ebp
  8027de:	c3                   	ret    
  8027df:	90                   	nop
  8027e0:	89 d1                	mov    %edx,%ecx
  8027e2:	89 fa                	mov    %edi,%edx
  8027e4:	89 c8                	mov    %ecx,%eax
  8027e6:	31 ff                	xor    %edi,%edi
  8027e8:	f7 f6                	div    %esi
  8027ea:	89 c1                	mov    %eax,%ecx
  8027ec:	89 fa                	mov    %edi,%edx
  8027ee:	89 c8                	mov    %ecx,%eax
  8027f0:	83 c4 10             	add    $0x10,%esp
  8027f3:	5e                   	pop    %esi
  8027f4:	5f                   	pop    %edi
  8027f5:	5d                   	pop    %ebp
  8027f6:	c3                   	ret    
  8027f7:	90                   	nop
  8027f8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027fc:	89 f2                	mov    %esi,%edx
  8027fe:	d3 e0                	shl    %cl,%eax
  802800:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802803:	b8 20 00 00 00       	mov    $0x20,%eax
  802808:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80280b:	89 c1                	mov    %eax,%ecx
  80280d:	d3 ea                	shr    %cl,%edx
  80280f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802813:	0b 55 ec             	or     -0x14(%ebp),%edx
  802816:	d3 e6                	shl    %cl,%esi
  802818:	89 c1                	mov    %eax,%ecx
  80281a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80281d:	89 fe                	mov    %edi,%esi
  80281f:	d3 ee                	shr    %cl,%esi
  802821:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802825:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802828:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80282b:	d3 e7                	shl    %cl,%edi
  80282d:	89 c1                	mov    %eax,%ecx
  80282f:	d3 ea                	shr    %cl,%edx
  802831:	09 d7                	or     %edx,%edi
  802833:	89 f2                	mov    %esi,%edx
  802835:	89 f8                	mov    %edi,%eax
  802837:	f7 75 ec             	divl   -0x14(%ebp)
  80283a:	89 d6                	mov    %edx,%esi
  80283c:	89 c7                	mov    %eax,%edi
  80283e:	f7 65 e8             	mull   -0x18(%ebp)
  802841:	39 d6                	cmp    %edx,%esi
  802843:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802846:	72 30                	jb     802878 <__udivdi3+0x118>
  802848:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80284b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80284f:	d3 e2                	shl    %cl,%edx
  802851:	39 c2                	cmp    %eax,%edx
  802853:	73 05                	jae    80285a <__udivdi3+0xfa>
  802855:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802858:	74 1e                	je     802878 <__udivdi3+0x118>
  80285a:	89 f9                	mov    %edi,%ecx
  80285c:	31 ff                	xor    %edi,%edi
  80285e:	e9 71 ff ff ff       	jmp    8027d4 <__udivdi3+0x74>
  802863:	90                   	nop
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	31 ff                	xor    %edi,%edi
  80286a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80286f:	e9 60 ff ff ff       	jmp    8027d4 <__udivdi3+0x74>
  802874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802878:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80287b:	31 ff                	xor    %edi,%edi
  80287d:	89 c8                	mov    %ecx,%eax
  80287f:	89 fa                	mov    %edi,%edx
  802881:	83 c4 10             	add    $0x10,%esp
  802884:	5e                   	pop    %esi
  802885:	5f                   	pop    %edi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    
	...

00802890 <__umoddi3>:
  802890:	55                   	push   %ebp
  802891:	89 e5                	mov    %esp,%ebp
  802893:	57                   	push   %edi
  802894:	56                   	push   %esi
  802895:	83 ec 20             	sub    $0x20,%esp
  802898:	8b 55 14             	mov    0x14(%ebp),%edx
  80289b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80289e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8028a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8028a4:	85 d2                	test   %edx,%edx
  8028a6:	89 c8                	mov    %ecx,%eax
  8028a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8028ab:	75 13                	jne    8028c0 <__umoddi3+0x30>
  8028ad:	39 f7                	cmp    %esi,%edi
  8028af:	76 3f                	jbe    8028f0 <__umoddi3+0x60>
  8028b1:	89 f2                	mov    %esi,%edx
  8028b3:	f7 f7                	div    %edi
  8028b5:	89 d0                	mov    %edx,%eax
  8028b7:	31 d2                	xor    %edx,%edx
  8028b9:	83 c4 20             	add    $0x20,%esp
  8028bc:	5e                   	pop    %esi
  8028bd:	5f                   	pop    %edi
  8028be:	5d                   	pop    %ebp
  8028bf:	c3                   	ret    
  8028c0:	39 f2                	cmp    %esi,%edx
  8028c2:	77 4c                	ja     802910 <__umoddi3+0x80>
  8028c4:	0f bd ca             	bsr    %edx,%ecx
  8028c7:	83 f1 1f             	xor    $0x1f,%ecx
  8028ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8028cd:	75 51                	jne    802920 <__umoddi3+0x90>
  8028cf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8028d2:	0f 87 e0 00 00 00    	ja     8029b8 <__umoddi3+0x128>
  8028d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028db:	29 f8                	sub    %edi,%eax
  8028dd:	19 d6                	sbb    %edx,%esi
  8028df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8028e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028e5:	89 f2                	mov    %esi,%edx
  8028e7:	83 c4 20             	add    $0x20,%esp
  8028ea:	5e                   	pop    %esi
  8028eb:	5f                   	pop    %edi
  8028ec:	5d                   	pop    %ebp
  8028ed:	c3                   	ret    
  8028ee:	66 90                	xchg   %ax,%ax
  8028f0:	85 ff                	test   %edi,%edi
  8028f2:	75 0b                	jne    8028ff <__umoddi3+0x6f>
  8028f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028f9:	31 d2                	xor    %edx,%edx
  8028fb:	f7 f7                	div    %edi
  8028fd:	89 c7                	mov    %eax,%edi
  8028ff:	89 f0                	mov    %esi,%eax
  802901:	31 d2                	xor    %edx,%edx
  802903:	f7 f7                	div    %edi
  802905:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802908:	f7 f7                	div    %edi
  80290a:	eb a9                	jmp    8028b5 <__umoddi3+0x25>
  80290c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802910:	89 c8                	mov    %ecx,%eax
  802912:	89 f2                	mov    %esi,%edx
  802914:	83 c4 20             	add    $0x20,%esp
  802917:	5e                   	pop    %esi
  802918:	5f                   	pop    %edi
  802919:	5d                   	pop    %ebp
  80291a:	c3                   	ret    
  80291b:	90                   	nop
  80291c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802920:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802924:	d3 e2                	shl    %cl,%edx
  802926:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802929:	ba 20 00 00 00       	mov    $0x20,%edx
  80292e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802931:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802934:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802938:	89 fa                	mov    %edi,%edx
  80293a:	d3 ea                	shr    %cl,%edx
  80293c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802940:	0b 55 f4             	or     -0xc(%ebp),%edx
  802943:	d3 e7                	shl    %cl,%edi
  802945:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802949:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80294c:	89 f2                	mov    %esi,%edx
  80294e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802951:	89 c7                	mov    %eax,%edi
  802953:	d3 ea                	shr    %cl,%edx
  802955:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802959:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80295c:	89 c2                	mov    %eax,%edx
  80295e:	d3 e6                	shl    %cl,%esi
  802960:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802964:	d3 ea                	shr    %cl,%edx
  802966:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80296a:	09 d6                	or     %edx,%esi
  80296c:	89 f0                	mov    %esi,%eax
  80296e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802971:	d3 e7                	shl    %cl,%edi
  802973:	89 f2                	mov    %esi,%edx
  802975:	f7 75 f4             	divl   -0xc(%ebp)
  802978:	89 d6                	mov    %edx,%esi
  80297a:	f7 65 e8             	mull   -0x18(%ebp)
  80297d:	39 d6                	cmp    %edx,%esi
  80297f:	72 2b                	jb     8029ac <__umoddi3+0x11c>
  802981:	39 c7                	cmp    %eax,%edi
  802983:	72 23                	jb     8029a8 <__umoddi3+0x118>
  802985:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802989:	29 c7                	sub    %eax,%edi
  80298b:	19 d6                	sbb    %edx,%esi
  80298d:	89 f0                	mov    %esi,%eax
  80298f:	89 f2                	mov    %esi,%edx
  802991:	d3 ef                	shr    %cl,%edi
  802993:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802997:	d3 e0                	shl    %cl,%eax
  802999:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80299d:	09 f8                	or     %edi,%eax
  80299f:	d3 ea                	shr    %cl,%edx
  8029a1:	83 c4 20             	add    $0x20,%esp
  8029a4:	5e                   	pop    %esi
  8029a5:	5f                   	pop    %edi
  8029a6:	5d                   	pop    %ebp
  8029a7:	c3                   	ret    
  8029a8:	39 d6                	cmp    %edx,%esi
  8029aa:	75 d9                	jne    802985 <__umoddi3+0xf5>
  8029ac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8029af:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8029b2:	eb d1                	jmp    802985 <__umoddi3+0xf5>
  8029b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029b8:	39 f2                	cmp    %esi,%edx
  8029ba:	0f 82 18 ff ff ff    	jb     8028d8 <__umoddi3+0x48>
  8029c0:	e9 1d ff ff ff       	jmp    8028e2 <__umoddi3+0x52>
