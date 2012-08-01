
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
  80004f:	c7 05 00 40 80 00 c0 	movl   $0x8029c0,0x804000
  800056:	29 80 00 

	output_envid = fork();
  800059:	e8 b4 12 00 00       	call   801312 <fork>
  80005e:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800063:	85 c0                	test   %eax,%eax
  800065:	79 1c                	jns    800083 <umain+0x43>
		panic("error forking");
  800067:	c7 44 24 08 cb 29 80 	movl   $0x8029cb,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  800076:	00 
  800077:	c7 04 24 d9 29 80 00 	movl   $0x8029d9,(%esp)
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
  8000bd:	c7 44 24 08 ea 29 80 	movl   $0x8029ea,0x8(%esp)
  8000c4:	00 
  8000c5:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8000cc:	00 
  8000cd:	c7 04 24 d9 29 80 00 	movl   $0x8029d9,(%esp)
  8000d4:	e8 2b 02 00 00       	call   800304 <_panic>
		pkt->jp_len = snprintf(pkt->jp_data,
  8000d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000dd:	c7 44 24 08 fd 29 80 	movl   $0x8029fd,0x8(%esp)
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
  800102:	c7 04 24 09 2a 80 00 	movl   $0x802a09,(%esp)
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
  80012e:	e8 51 16 00 00       	call   801784 <ipc_send>
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
  800186:	c7 05 00 40 80 00 21 	movl   $0x802a21,0x804000
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
  8001b6:	c7 44 24 08 2a 2a 80 	movl   $0x802a2a,0x8(%esp)
  8001bd:	00 
  8001be:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8001c5:	00 
  8001c6:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  8001cd:	e8 32 01 00 00       	call   800304 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8001d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001d9:	00 
  8001da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001e1:	00 
  8001e2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8001e9:	00 
  8001ea:	89 34 24             	mov    %esi,(%esp)
  8001ed:	e8 92 15 00 00       	call   801784 <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8001f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800201:	00 
  800202:	89 3c 24             	mov    %edi,(%esp)
  800205:	e8 e5 15 00 00       	call   8017ef <ipc_recv>
  80020a:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  80020c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80020f:	39 c6                	cmp    %eax,%esi
  800211:	74 12                	je     800225 <timer+0xb5>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800213:	89 44 24 04          	mov    %eax,0x4(%esp)
  800217:	c7 04 24 48 2a 80 00 	movl   $0x802a48,(%esp)
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
  80023b:	c7 05 00 40 80 00 83 	movl   $0x802a83,0x804000
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
  800253:	c7 05 00 40 80 00 8c 	movl   $0x802a8c,0x804000
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
  8002b4:	6b c0 7c             	imul   $0x7c,%eax,%eax
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
  8002ee:	e8 76 1a 00 00       	call   801d69 <close_all>
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
  800330:	c7 04 24 a0 2a 80 00 	movl   $0x802aa0,(%esp)
  800337:	e8 81 00 00 00       	call   8003bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800340:	8b 45 10             	mov    0x10(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	e8 11 00 00 00       	call   80035c <vcprintf>
	cprintf("\n");
  80034b:	c7 04 24 1f 2a 80 00 	movl   $0x802a1f,(%esp)
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
  80049d:	e8 ae 22 00 00       	call   802750 <__udivdi3>
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
  8004f8:	e8 83 23 00 00       	call   802880 <__umoddi3>
  8004fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800501:	0f be 80 c3 2a 80 00 	movsbl 0x802ac3(%eax),%eax
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
  8005e5:	ff 24 95 a0 2c 80 00 	jmp    *0x802ca0(,%edx,4)
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
  8006b8:	8b 14 85 00 2e 80 00 	mov    0x802e00(,%eax,4),%edx
  8006bf:	85 d2                	test   %edx,%edx
  8006c1:	75 20                	jne    8006e3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8006c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8006c7:	c7 44 24 08 d4 2a 80 	movl   $0x802ad4,0x8(%esp)
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
  8006e7:	c7 44 24 08 97 31 80 	movl   $0x803197,0x8(%esp)
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
  800721:	b8 dd 2a 80 00       	mov    $0x802add,%eax
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
  800965:	c7 44 24 0c f8 2b 80 	movl   $0x802bf8,0xc(%esp)
  80096c:	00 
  80096d:	c7 44 24 08 97 31 80 	movl   $0x803197,0x8(%esp)
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
  800993:	c7 44 24 0c 30 2c 80 	movl   $0x802c30,0xc(%esp)
  80099a:	00 
  80099b:	c7 44 24 08 97 31 80 	movl   $0x803197,0x8(%esp)
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
  800f37:	c7 44 24 08 40 2e 80 	movl   $0x802e40,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 5d 2e 80 00 	movl   $0x802e5d,(%esp)
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
  8012f6:	c7 44 24 08 6b 2e 80 	movl   $0x802e6b,0x8(%esp)
  8012fd:	00 
  8012fe:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801305:	00 
  801306:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  801322:	e8 4d 13 00 00       	call   802674 <set_pgfault_handler>
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
  801353:	c7 44 24 04 81 2e 80 	movl   $0x802e81,0x4(%esp)
  80135a:	00 
  80135b:	c7 04 24 c8 2e 80 00 	movl   $0x802ec8,(%esp)
  801362:	e8 56 f0 ff ff       	call   8003bd <cprintf>
	if (envidnum < 0)
  801367:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80136b:	79 23                	jns    801390 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80136d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801370:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801374:	c7 44 24 08 8c 2e 80 	movl   $0x802e8c,0x8(%esp)
  80137b:	00 
  80137c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801383:	00 
  801384:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  8013af:	6b c0 7c             	imul   $0x7c,%eax,%eax
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
  801443:	c7 44 24 08 f0 2e 80 	movl   $0x802ef0,0x8(%esp)
  80144a:	00 
  80144b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801452:	00 
  801453:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  801491:	c7 44 24 08 1c 2f 80 	movl   $0x802f1c,0x8(%esp)
  801498:	00 
  801499:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8014a0:	00 
  8014a1:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  8014a8:	e8 57 ee ff ff       	call   800304 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  8014ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8014b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014bb:	c7 04 24 9c 2e 80 00 	movl   $0x802e9c,(%esp)
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
  8014f8:	c7 44 24 08 48 2f 80 	movl   $0x802f48,0x8(%esp)
  8014ff:	00 
  801500:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801507:	00 
  801508:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  801549:	c7 44 24 08 74 2f 80 	movl   $0x802f74,0x8(%esp)
  801550:	00 
  801551:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801558:	00 
  801559:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  801560:	e8 9f ed ff ff       	call   800304 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801565:	c7 44 24 04 e4 26 80 	movl   $0x8026e4,0x4(%esp)
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
  801593:	c7 44 24 08 98 2f 80 	movl   $0x802f98,0x8(%esp)
  80159a:	00 
  80159b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8015a2:	00 
  8015a3:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
  8015aa:	e8 55 ed ff ff       	call   800304 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  8015af:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  8015b6:	00 
  8015b7:	c7 44 24 04 81 2e 80 	movl   $0x802e81,0x4(%esp)
  8015be:	00 
  8015bf:	c7 04 24 ae 2e 80 00 	movl   $0x802eae,(%esp)
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
  8015f9:	c7 44 24 08 c0 2f 80 	movl   $0x802fc0,0x8(%esp)
  801600:	00 
  801601:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801608:	00 
  801609:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  801636:	c7 44 24 08 fc 2f 80 	movl   $0x802ffc,0x8(%esp)
  80163d:	00 
  80163e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801645:	00 
  801646:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  801676:	c7 44 24 08 38 30 80 	movl   $0x803038,0x8(%esp)
  80167d:	00 
  80167e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801685:	00 
  801686:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  8016e0:	c7 44 24 08 60 30 80 	movl   $0x803060,0x8(%esp)
  8016e7:	00 
  8016e8:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8016ef:	00 
  8016f0:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  801718:	c7 44 24 08 84 30 80 	movl   $0x803084,0x8(%esp)
  80171f:	00 
  801720:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801727:	00 
  801728:	c7 04 24 81 2e 80 00 	movl   $0x802e81,(%esp)
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
  801757:	eb 0f                	jmp    801768 <ipc_find_env+0x28>
  801759:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80175c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801762:	8b 12                	mov    (%edx),%edx
  801764:	39 ca                	cmp    %ecx,%edx
  801766:	75 0c                	jne    801774 <ipc_find_env+0x34>
			return envs[i].env_id;
  801768:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80176b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801770:	8b 00                	mov    (%eax),%eax
  801772:	eb 0e                	jmp    801782 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801774:	83 c0 01             	add    $0x1,%eax
  801777:	3d 00 04 00 00       	cmp    $0x400,%eax
  80177c:	75 db                	jne    801759 <ipc_find_env+0x19>
  80177e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	57                   	push   %edi
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
  80178a:	83 ec 1c             	sub    $0x1c,%esp
  80178d:	8b 75 08             	mov    0x8(%ebp),%esi
  801790:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801793:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801796:	85 db                	test   %ebx,%ebx
  801798:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80179d:	0f 44 d8             	cmove  %eax,%ebx
  8017a0:	eb 25                	jmp    8017c7 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8017a2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017a5:	74 20                	je     8017c7 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8017a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ab:	c7 44 24 08 a8 30 80 	movl   $0x8030a8,0x8(%esp)
  8017b2:	00 
  8017b3:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8017ba:	00 
  8017bb:	c7 04 24 c6 30 80 00 	movl   $0x8030c6,(%esp)
  8017c2:	e8 3d eb ff ff       	call   800304 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8017c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8017d6:	89 34 24             	mov    %esi,(%esp)
  8017d9:	e8 30 f8 ff ff       	call   80100e <sys_ipc_try_send>
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	75 c0                	jne    8017a2 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8017e2:	e8 ad f9 ff ff       	call   801194 <sys_yield>
}
  8017e7:	83 c4 1c             	add    $0x1c,%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5e                   	pop    %esi
  8017ec:	5f                   	pop    %edi
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    

008017ef <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 28             	sub    $0x28,%esp
  8017f5:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8017f8:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8017fb:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8017fe:	8b 75 08             	mov    0x8(%ebp),%esi
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801807:	85 c0                	test   %eax,%eax
  801809:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80180e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801811:	89 04 24             	mov    %eax,(%esp)
  801814:	e8 bc f7 ff ff       	call   800fd5 <sys_ipc_recv>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	85 c0                	test   %eax,%eax
  80181d:	79 2a                	jns    801849 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80181f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801823:	89 44 24 04          	mov    %eax,0x4(%esp)
  801827:	c7 04 24 d0 30 80 00 	movl   $0x8030d0,(%esp)
  80182e:	e8 8a eb ff ff       	call   8003bd <cprintf>
		if(from_env_store != NULL)
  801833:	85 f6                	test   %esi,%esi
  801835:	74 06                	je     80183d <ipc_recv+0x4e>
			*from_env_store = 0;
  801837:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80183d:	85 ff                	test   %edi,%edi
  80183f:	74 2c                	je     80186d <ipc_recv+0x7e>
			*perm_store = 0;
  801841:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801847:	eb 24                	jmp    80186d <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801849:	85 f6                	test   %esi,%esi
  80184b:	74 0a                	je     801857 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  80184d:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801852:	8b 40 74             	mov    0x74(%eax),%eax
  801855:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801857:	85 ff                	test   %edi,%edi
  801859:	74 0a                	je     801865 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  80185b:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801860:	8b 40 78             	mov    0x78(%eax),%eax
  801863:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801865:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80186a:	8b 58 70             	mov    0x70(%eax),%ebx
}
  80186d:	89 d8                	mov    %ebx,%eax
  80186f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801872:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801875:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801878:	89 ec                	mov    %ebp,%esp
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    
  80187c:	00 00                	add    %al,(%eax)
	...

00801880 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	8b 45 08             	mov    0x8(%ebp),%eax
  801886:	05 00 00 00 30       	add    $0x30000000,%eax
  80188b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801896:	8b 45 08             	mov    0x8(%ebp),%eax
  801899:	89 04 24             	mov    %eax,(%esp)
  80189c:	e8 df ff ff ff       	call   801880 <fd2num>
  8018a1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8018a6:	c1 e0 0c             	shl    $0xc,%eax
}
  8018a9:	c9                   	leave  
  8018aa:	c3                   	ret    

008018ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	57                   	push   %edi
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8018b4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8018b9:	a8 01                	test   $0x1,%al
  8018bb:	74 36                	je     8018f3 <fd_alloc+0x48>
  8018bd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8018c2:	a8 01                	test   $0x1,%al
  8018c4:	74 2d                	je     8018f3 <fd_alloc+0x48>
  8018c6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8018cb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8018d0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8018d5:	89 c3                	mov    %eax,%ebx
  8018d7:	89 c2                	mov    %eax,%edx
  8018d9:	c1 ea 16             	shr    $0x16,%edx
  8018dc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8018df:	f6 c2 01             	test   $0x1,%dl
  8018e2:	74 14                	je     8018f8 <fd_alloc+0x4d>
  8018e4:	89 c2                	mov    %eax,%edx
  8018e6:	c1 ea 0c             	shr    $0xc,%edx
  8018e9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8018ec:	f6 c2 01             	test   $0x1,%dl
  8018ef:	75 10                	jne    801901 <fd_alloc+0x56>
  8018f1:	eb 05                	jmp    8018f8 <fd_alloc+0x4d>
  8018f3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8018f8:	89 1f                	mov    %ebx,(%edi)
  8018fa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8018ff:	eb 17                	jmp    801918 <fd_alloc+0x6d>
  801901:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801906:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80190b:	75 c8                	jne    8018d5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80190d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801913:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5f                   	pop    %edi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	83 f8 1f             	cmp    $0x1f,%eax
  801926:	77 36                	ja     80195e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801928:	05 00 00 0d 00       	add    $0xd0000,%eax
  80192d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801930:	89 c2                	mov    %eax,%edx
  801932:	c1 ea 16             	shr    $0x16,%edx
  801935:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80193c:	f6 c2 01             	test   $0x1,%dl
  80193f:	74 1d                	je     80195e <fd_lookup+0x41>
  801941:	89 c2                	mov    %eax,%edx
  801943:	c1 ea 0c             	shr    $0xc,%edx
  801946:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80194d:	f6 c2 01             	test   $0x1,%dl
  801950:	74 0c                	je     80195e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801952:	8b 55 0c             	mov    0xc(%ebp),%edx
  801955:	89 02                	mov    %eax,(%edx)
  801957:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80195c:	eb 05                	jmp    801963 <fd_lookup+0x46>
  80195e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    

00801965 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80196b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80196e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	89 04 24             	mov    %eax,(%esp)
  801978:	e8 a0 ff ff ff       	call   80191d <fd_lookup>
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 0e                	js     80198f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801981:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801984:	8b 55 0c             	mov    0xc(%ebp),%edx
  801987:	89 50 04             	mov    %edx,0x4(%eax)
  80198a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	56                   	push   %esi
  801995:	53                   	push   %ebx
  801996:	83 ec 10             	sub    $0x10,%esp
  801999:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80199c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8019a4:	b8 04 40 80 00       	mov    $0x804004,%eax
  8019a9:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  8019af:	75 11                	jne    8019c2 <dev_lookup+0x31>
  8019b1:	eb 04                	jmp    8019b7 <dev_lookup+0x26>
  8019b3:	39 08                	cmp    %ecx,(%eax)
  8019b5:	75 10                	jne    8019c7 <dev_lookup+0x36>
			*dev = devtab[i];
  8019b7:	89 03                	mov    %eax,(%ebx)
  8019b9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8019be:	66 90                	xchg   %ax,%ax
  8019c0:	eb 36                	jmp    8019f8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8019c2:	be 64 31 80 00       	mov    $0x803164,%esi
  8019c7:	83 c2 01             	add    $0x1,%edx
  8019ca:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8019cd:	85 c0                	test   %eax,%eax
  8019cf:	75 e2                	jne    8019b3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8019d1:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8019d6:	8b 40 48             	mov    0x48(%eax),%eax
  8019d9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8019dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e1:	c7 04 24 e4 30 80 00 	movl   $0x8030e4,(%esp)
  8019e8:	e8 d0 e9 ff ff       	call   8003bd <cprintf>
	*dev = 0;
  8019ed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5e                   	pop    %esi
  8019fd:	5d                   	pop    %ebp
  8019fe:	c3                   	ret    

008019ff <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8019ff:	55                   	push   %ebp
  801a00:	89 e5                	mov    %esp,%ebp
  801a02:	53                   	push   %ebx
  801a03:	83 ec 24             	sub    $0x24,%esp
  801a06:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a09:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a10:	8b 45 08             	mov    0x8(%ebp),%eax
  801a13:	89 04 24             	mov    %eax,(%esp)
  801a16:	e8 02 ff ff ff       	call   80191d <fd_lookup>
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	78 53                	js     801a72 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a29:	8b 00                	mov    (%eax),%eax
  801a2b:	89 04 24             	mov    %eax,(%esp)
  801a2e:	e8 5e ff ff ff       	call   801991 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a33:	85 c0                	test   %eax,%eax
  801a35:	78 3b                	js     801a72 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801a37:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801a43:	74 2d                	je     801a72 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a45:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a48:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a4f:	00 00 00 
	stat->st_isdir = 0;
  801a52:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a59:	00 00 00 
	stat->st_dev = dev;
  801a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a65:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a69:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a6c:	89 14 24             	mov    %edx,(%esp)
  801a6f:	ff 50 14             	call   *0x14(%eax)
}
  801a72:	83 c4 24             	add    $0x24,%esp
  801a75:	5b                   	pop    %ebx
  801a76:	5d                   	pop    %ebp
  801a77:	c3                   	ret    

00801a78 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	53                   	push   %ebx
  801a7c:	83 ec 24             	sub    $0x24,%esp
  801a7f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a89:	89 1c 24             	mov    %ebx,(%esp)
  801a8c:	e8 8c fe ff ff       	call   80191d <fd_lookup>
  801a91:	85 c0                	test   %eax,%eax
  801a93:	78 5f                	js     801af4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a9f:	8b 00                	mov    (%eax),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 e8 fe ff ff       	call   801991 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 47                	js     801af4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ab0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801ab4:	75 23                	jne    801ad9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801ab6:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801abb:	8b 40 48             	mov    0x48(%eax),%eax
  801abe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	c7 04 24 04 31 80 00 	movl   $0x803104,(%esp)
  801acd:	e8 eb e8 ff ff       	call   8003bd <cprintf>
  801ad2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801ad7:	eb 1b                	jmp    801af4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	8b 48 18             	mov    0x18(%eax),%ecx
  801adf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ae4:	85 c9                	test   %ecx,%ecx
  801ae6:	74 0c                	je     801af4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aef:	89 14 24             	mov    %edx,(%esp)
  801af2:	ff d1                	call   *%ecx
}
  801af4:	83 c4 24             	add    $0x24,%esp
  801af7:	5b                   	pop    %ebx
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	53                   	push   %ebx
  801afe:	83 ec 24             	sub    $0x24,%esp
  801b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b04:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0b:	89 1c 24             	mov    %ebx,(%esp)
  801b0e:	e8 0a fe ff ff       	call   80191d <fd_lookup>
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 66                	js     801b7d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b21:	8b 00                	mov    (%eax),%eax
  801b23:	89 04 24             	mov    %eax,(%esp)
  801b26:	e8 66 fe ff ff       	call   801991 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	78 4e                	js     801b7d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b2f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b32:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b36:	75 23                	jne    801b5b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b38:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801b3d:	8b 40 48             	mov    0x48(%eax),%eax
  801b40:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b44:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b48:	c7 04 24 28 31 80 00 	movl   $0x803128,(%esp)
  801b4f:	e8 69 e8 ff ff       	call   8003bd <cprintf>
  801b54:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801b59:	eb 22                	jmp    801b7d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801b61:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b66:	85 c9                	test   %ecx,%ecx
  801b68:	74 13                	je     801b7d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b74:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b78:	89 14 24             	mov    %edx,(%esp)
  801b7b:	ff d1                	call   *%ecx
}
  801b7d:	83 c4 24             	add    $0x24,%esp
  801b80:	5b                   	pop    %ebx
  801b81:	5d                   	pop    %ebp
  801b82:	c3                   	ret    

00801b83 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	53                   	push   %ebx
  801b87:	83 ec 24             	sub    $0x24,%esp
  801b8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b90:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b94:	89 1c 24             	mov    %ebx,(%esp)
  801b97:	e8 81 fd ff ff       	call   80191d <fd_lookup>
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	78 6b                	js     801c0b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ba0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801baa:	8b 00                	mov    (%eax),%eax
  801bac:	89 04 24             	mov    %eax,(%esp)
  801baf:	e8 dd fd ff ff       	call   801991 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bb4:	85 c0                	test   %eax,%eax
  801bb6:	78 53                	js     801c0b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801bb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bbb:	8b 42 08             	mov    0x8(%edx),%eax
  801bbe:	83 e0 03             	and    $0x3,%eax
  801bc1:	83 f8 01             	cmp    $0x1,%eax
  801bc4:	75 23                	jne    801be9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801bc6:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801bcb:	8b 40 48             	mov    0x48(%eax),%eax
  801bce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd6:	c7 04 24 45 31 80 00 	movl   $0x803145,(%esp)
  801bdd:	e8 db e7 ff ff       	call   8003bd <cprintf>
  801be2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801be7:	eb 22                	jmp    801c0b <read+0x88>
	}
	if (!dev->dev_read)
  801be9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bec:	8b 48 08             	mov    0x8(%eax),%ecx
  801bef:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bf4:	85 c9                	test   %ecx,%ecx
  801bf6:	74 13                	je     801c0b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801bf8:	8b 45 10             	mov    0x10(%ebp),%eax
  801bfb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c06:	89 14 24             	mov    %edx,(%esp)
  801c09:	ff d1                	call   *%ecx
}
  801c0b:	83 c4 24             	add    $0x24,%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	57                   	push   %edi
  801c15:	56                   	push   %esi
  801c16:	53                   	push   %ebx
  801c17:	83 ec 1c             	sub    $0x1c,%esp
  801c1a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c20:	ba 00 00 00 00       	mov    $0x0,%edx
  801c25:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2f:	85 f6                	test   %esi,%esi
  801c31:	74 29                	je     801c5c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c33:	89 f0                	mov    %esi,%eax
  801c35:	29 d0                	sub    %edx,%eax
  801c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3b:	03 55 0c             	add    0xc(%ebp),%edx
  801c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c42:	89 3c 24             	mov    %edi,(%esp)
  801c45:	e8 39 ff ff ff       	call   801b83 <read>
		if (m < 0)
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 0e                	js     801c5c <readn+0x4b>
			return m;
		if (m == 0)
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	74 08                	je     801c5a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c52:	01 c3                	add    %eax,%ebx
  801c54:	89 da                	mov    %ebx,%edx
  801c56:	39 f3                	cmp    %esi,%ebx
  801c58:	72 d9                	jb     801c33 <readn+0x22>
  801c5a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 28             	sub    $0x28,%esp
  801c6a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801c6d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801c70:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801c73:	89 34 24             	mov    %esi,(%esp)
  801c76:	e8 05 fc ff ff       	call   801880 <fd2num>
  801c7b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c82:	89 04 24             	mov    %eax,(%esp)
  801c85:	e8 93 fc ff ff       	call   80191d <fd_lookup>
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	78 05                	js     801c95 <fd_close+0x31>
  801c90:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801c93:	74 0e                	je     801ca3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801c95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801c99:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9e:	0f 44 d8             	cmove  %eax,%ebx
  801ca1:	eb 3d                	jmp    801ce0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ca3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801caa:	8b 06                	mov    (%esi),%eax
  801cac:	89 04 24             	mov    %eax,(%esp)
  801caf:	e8 dd fc ff ff       	call   801991 <dev_lookup>
  801cb4:	89 c3                	mov    %eax,%ebx
  801cb6:	85 c0                	test   %eax,%eax
  801cb8:	78 16                	js     801cd0 <fd_close+0x6c>
		if (dev->dev_close)
  801cba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbd:	8b 40 10             	mov    0x10(%eax),%eax
  801cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cc5:	85 c0                	test   %eax,%eax
  801cc7:	74 07                	je     801cd0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801cc9:	89 34 24             	mov    %esi,(%esp)
  801ccc:	ff d0                	call   *%eax
  801cce:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801cd0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cd4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cdb:	e8 0c f4 ff ff       	call   8010ec <sys_page_unmap>
	return r;
}
  801ce0:	89 d8                	mov    %ebx,%eax
  801ce2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ce5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ce8:	89 ec                	mov    %ebp,%esp
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfc:	89 04 24             	mov    %eax,(%esp)
  801cff:	e8 19 fc ff ff       	call   80191d <fd_lookup>
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 13                	js     801d1b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801d08:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d0f:	00 
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	89 04 24             	mov    %eax,(%esp)
  801d16:	e8 49 ff ff ff       	call   801c64 <fd_close>
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 18             	sub    $0x18,%esp
  801d23:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d26:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d29:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d30:	00 
  801d31:	8b 45 08             	mov    0x8(%ebp),%eax
  801d34:	89 04 24             	mov    %eax,(%esp)
  801d37:	e8 78 03 00 00       	call   8020b4 <open>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 1b                	js     801d5d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d42:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d45:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d49:	89 1c 24             	mov    %ebx,(%esp)
  801d4c:	e8 ae fc ff ff       	call   8019ff <fstat>
  801d51:	89 c6                	mov    %eax,%esi
	close(fd);
  801d53:	89 1c 24             	mov    %ebx,(%esp)
  801d56:	e8 91 ff ff ff       	call   801cec <close>
  801d5b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801d5d:	89 d8                	mov    %ebx,%eax
  801d5f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d62:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d65:	89 ec                	mov    %ebp,%esp
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    

00801d69 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	53                   	push   %ebx
  801d6d:	83 ec 14             	sub    $0x14,%esp
  801d70:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801d75:	89 1c 24             	mov    %ebx,(%esp)
  801d78:	e8 6f ff ff ff       	call   801cec <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d7d:	83 c3 01             	add    $0x1,%ebx
  801d80:	83 fb 20             	cmp    $0x20,%ebx
  801d83:	75 f0                	jne    801d75 <close_all+0xc>
		close(i);
}
  801d85:	83 c4 14             	add    $0x14,%esp
  801d88:	5b                   	pop    %ebx
  801d89:	5d                   	pop    %ebp
  801d8a:	c3                   	ret    

00801d8b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801d8b:	55                   	push   %ebp
  801d8c:	89 e5                	mov    %esp,%ebp
  801d8e:	83 ec 58             	sub    $0x58,%esp
  801d91:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801d94:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801d97:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801d9a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801d9d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801da0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da4:	8b 45 08             	mov    0x8(%ebp),%eax
  801da7:	89 04 24             	mov    %eax,(%esp)
  801daa:	e8 6e fb ff ff       	call   80191d <fd_lookup>
  801daf:	89 c3                	mov    %eax,%ebx
  801db1:	85 c0                	test   %eax,%eax
  801db3:	0f 88 e0 00 00 00    	js     801e99 <dup+0x10e>
		return r;
	close(newfdnum);
  801db9:	89 3c 24             	mov    %edi,(%esp)
  801dbc:	e8 2b ff ff ff       	call   801cec <close>

	newfd = INDEX2FD(newfdnum);
  801dc1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801dc7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801dca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dcd:	89 04 24             	mov    %eax,(%esp)
  801dd0:	e8 bb fa ff ff       	call   801890 <fd2data>
  801dd5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801dd7:	89 34 24             	mov    %esi,(%esp)
  801dda:	e8 b1 fa ff ff       	call   801890 <fd2data>
  801ddf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801de2:	89 da                	mov    %ebx,%edx
  801de4:	89 d8                	mov    %ebx,%eax
  801de6:	c1 e8 16             	shr    $0x16,%eax
  801de9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801df0:	a8 01                	test   $0x1,%al
  801df2:	74 43                	je     801e37 <dup+0xac>
  801df4:	c1 ea 0c             	shr    $0xc,%edx
  801df7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801dfe:	a8 01                	test   $0x1,%al
  801e00:	74 35                	je     801e37 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e02:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e09:	25 07 0e 00 00       	and    $0xe07,%eax
  801e0e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e15:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e19:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e20:	00 
  801e21:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e25:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2c:	e8 f3 f2 ff ff       	call   801124 <sys_page_map>
  801e31:	89 c3                	mov    %eax,%ebx
  801e33:	85 c0                	test   %eax,%eax
  801e35:	78 3f                	js     801e76 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e37:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e3a:	89 c2                	mov    %eax,%edx
  801e3c:	c1 ea 0c             	shr    $0xc,%edx
  801e3f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e46:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801e4c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e50:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e54:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e5b:	00 
  801e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e60:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e67:	e8 b8 f2 ff ff       	call   801124 <sys_page_map>
  801e6c:	89 c3                	mov    %eax,%ebx
  801e6e:	85 c0                	test   %eax,%eax
  801e70:	78 04                	js     801e76 <dup+0xeb>
  801e72:	89 fb                	mov    %edi,%ebx
  801e74:	eb 23                	jmp    801e99 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e76:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e7a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e81:	e8 66 f2 ff ff       	call   8010ec <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e94:	e8 53 f2 ff ff       	call   8010ec <sys_page_unmap>
	return r;
}
  801e99:	89 d8                	mov    %ebx,%eax
  801e9b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801e9e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ea1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ea4:	89 ec                	mov    %ebp,%esp
  801ea6:	5d                   	pop    %ebp
  801ea7:	c3                   	ret    

00801ea8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 18             	sub    $0x18,%esp
  801eae:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801eb1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801eb8:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801ebf:	75 11                	jne    801ed2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ec1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ec8:	e8 73 f8 ff ff       	call   801740 <ipc_find_env>
  801ecd:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801ed2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801ed9:	00 
  801eda:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ee1:	00 
  801ee2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ee6:	a1 04 50 80 00       	mov    0x805004,%eax
  801eeb:	89 04 24             	mov    %eax,(%esp)
  801eee:	e8 91 f8 ff ff       	call   801784 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801ef3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801efa:	00 
  801efb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f06:	e8 e4 f8 ff ff       	call   8017ef <ipc_recv>
}
  801f0b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f0e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f11:	89 ec                	mov    %ebp,%esp
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    

00801f15 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f15:	55                   	push   %ebp
  801f16:	89 e5                	mov    %esp,%ebp
  801f18:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f21:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801f26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f29:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f33:	b8 02 00 00 00       	mov    $0x2,%eax
  801f38:	e8 6b ff ff ff       	call   801ea8 <fsipc>
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f45:	8b 45 08             	mov    0x8(%ebp),%eax
  801f48:	8b 40 0c             	mov    0xc(%eax),%eax
  801f4b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801f50:	ba 00 00 00 00       	mov    $0x0,%edx
  801f55:	b8 06 00 00 00       	mov    $0x6,%eax
  801f5a:	e8 49 ff ff ff       	call   801ea8 <fsipc>
}
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801f67:	ba 00 00 00 00       	mov    $0x0,%edx
  801f6c:	b8 08 00 00 00       	mov    $0x8,%eax
  801f71:	e8 32 ff ff ff       	call   801ea8 <fsipc>
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	53                   	push   %ebx
  801f7c:	83 ec 14             	sub    $0x14,%esp
  801f7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801f82:	8b 45 08             	mov    0x8(%ebp),%eax
  801f85:	8b 40 0c             	mov    0xc(%eax),%eax
  801f88:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801f8d:	ba 00 00 00 00       	mov    $0x0,%edx
  801f92:	b8 05 00 00 00       	mov    $0x5,%eax
  801f97:	e8 0c ff ff ff       	call   801ea8 <fsipc>
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	78 2b                	js     801fcb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fa0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fa7:	00 
  801fa8:	89 1c 24             	mov    %ebx,(%esp)
  801fab:	e8 4a eb ff ff       	call   800afa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801fb0:	a1 80 60 80 00       	mov    0x806080,%eax
  801fb5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801fbb:	a1 84 60 80 00       	mov    0x806084,%eax
  801fc0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801fc6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801fcb:	83 c4 14             	add    $0x14,%esp
  801fce:	5b                   	pop    %ebx
  801fcf:	5d                   	pop    %ebp
  801fd0:	c3                   	ret    

00801fd1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801fd1:	55                   	push   %ebp
  801fd2:	89 e5                	mov    %esp,%ebp
  801fd4:	83 ec 18             	sub    $0x18,%esp
  801fd7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801fda:	8b 55 08             	mov    0x8(%ebp),%edx
  801fdd:	8b 52 0c             	mov    0xc(%edx),%edx
  801fe0:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801fe6:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801feb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801ff0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801ff5:	0f 47 c2             	cmova  %edx,%eax
  801ff8:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fff:	89 44 24 04          	mov    %eax,0x4(%esp)
  802003:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80200a:	e8 d6 ec ff ff       	call   800ce5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80200f:	ba 00 00 00 00       	mov    $0x0,%edx
  802014:	b8 04 00 00 00       	mov    $0x4,%eax
  802019:	e8 8a fe ff ff       	call   801ea8 <fsipc>
}
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	53                   	push   %ebx
  802024:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	8b 40 0c             	mov    0xc(%eax),%eax
  80202d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  802032:	8b 45 10             	mov    0x10(%ebp),%eax
  802035:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80203a:	ba 00 00 00 00       	mov    $0x0,%edx
  80203f:	b8 03 00 00 00       	mov    $0x3,%eax
  802044:	e8 5f fe ff ff       	call   801ea8 <fsipc>
  802049:	89 c3                	mov    %eax,%ebx
  80204b:	85 c0                	test   %eax,%eax
  80204d:	78 17                	js     802066 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80204f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802053:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80205a:	00 
  80205b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80205e:	89 04 24             	mov    %eax,(%esp)
  802061:	e8 7f ec ff ff       	call   800ce5 <memmove>
  return r;	
}
  802066:	89 d8                	mov    %ebx,%eax
  802068:	83 c4 14             	add    $0x14,%esp
  80206b:	5b                   	pop    %ebx
  80206c:	5d                   	pop    %ebp
  80206d:	c3                   	ret    

0080206e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80206e:	55                   	push   %ebp
  80206f:	89 e5                	mov    %esp,%ebp
  802071:	53                   	push   %ebx
  802072:	83 ec 14             	sub    $0x14,%esp
  802075:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  802078:	89 1c 24             	mov    %ebx,(%esp)
  80207b:	e8 30 ea ff ff       	call   800ab0 <strlen>
  802080:	89 c2                	mov    %eax,%edx
  802082:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  802087:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80208d:	7f 1f                	jg     8020ae <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80208f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802093:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80209a:	e8 5b ea ff ff       	call   800afa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80209f:	ba 00 00 00 00       	mov    $0x0,%edx
  8020a4:	b8 07 00 00 00       	mov    $0x7,%eax
  8020a9:	e8 fa fd ff ff       	call   801ea8 <fsipc>
}
  8020ae:	83 c4 14             	add    $0x14,%esp
  8020b1:	5b                   	pop    %ebx
  8020b2:	5d                   	pop    %ebp
  8020b3:	c3                   	ret    

008020b4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8020b4:	55                   	push   %ebp
  8020b5:	89 e5                	mov    %esp,%ebp
  8020b7:	83 ec 28             	sub    $0x28,%esp
  8020ba:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8020bd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8020c0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8020c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c6:	89 04 24             	mov    %eax,(%esp)
  8020c9:	e8 dd f7 ff ff       	call   8018ab <fd_alloc>
  8020ce:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	0f 88 89 00 00 00    	js     802161 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8020d8:	89 34 24             	mov    %esi,(%esp)
  8020db:	e8 d0 e9 ff ff       	call   800ab0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8020e0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8020e5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8020ea:	7f 75                	jg     802161 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8020ec:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020f0:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8020f7:	e8 fe e9 ff ff       	call   800afa <strcpy>
  fsipcbuf.open.req_omode = mode;
  8020fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ff:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  802104:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802107:	b8 01 00 00 00       	mov    $0x1,%eax
  80210c:	e8 97 fd ff ff       	call   801ea8 <fsipc>
  802111:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  802113:	85 c0                	test   %eax,%eax
  802115:	78 0f                	js     802126 <open+0x72>
  return fd2num(fd);
  802117:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80211a:	89 04 24             	mov    %eax,(%esp)
  80211d:	e8 5e f7 ff ff       	call   801880 <fd2num>
  802122:	89 c3                	mov    %eax,%ebx
  802124:	eb 3b                	jmp    802161 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  802126:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80212d:	00 
  80212e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802131:	89 04 24             	mov    %eax,(%esp)
  802134:	e8 2b fb ff ff       	call   801c64 <fd_close>
  802139:	85 c0                	test   %eax,%eax
  80213b:	74 24                	je     802161 <open+0xad>
  80213d:	c7 44 24 0c 70 31 80 	movl   $0x803170,0xc(%esp)
  802144:	00 
  802145:	c7 44 24 08 85 31 80 	movl   $0x803185,0x8(%esp)
  80214c:	00 
  80214d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  802154:	00 
  802155:	c7 04 24 9a 31 80 00 	movl   $0x80319a,(%esp)
  80215c:	e8 a3 e1 ff ff       	call   800304 <_panic>
  return r;
}
  802161:	89 d8                	mov    %ebx,%eax
  802163:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802166:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802169:	89 ec                	mov    %ebp,%esp
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
  80216d:	00 00                	add    %al,(%eax)
	...

00802170 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802176:	c7 44 24 04 a5 31 80 	movl   $0x8031a5,0x4(%esp)
  80217d:	00 
  80217e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802181:	89 04 24             	mov    %eax,(%esp)
  802184:	e8 71 e9 ff ff       	call   800afa <strcpy>
	return 0;
}
  802189:	b8 00 00 00 00       	mov    $0x0,%eax
  80218e:	c9                   	leave  
  80218f:	c3                   	ret    

00802190 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802190:	55                   	push   %ebp
  802191:	89 e5                	mov    %esp,%ebp
  802193:	53                   	push   %ebx
  802194:	83 ec 14             	sub    $0x14,%esp
  802197:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80219a:	89 1c 24             	mov    %ebx,(%esp)
  80219d:	e8 6a 05 00 00       	call   80270c <pageref>
  8021a2:	89 c2                	mov    %eax,%edx
  8021a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8021a9:	83 fa 01             	cmp    $0x1,%edx
  8021ac:	75 0b                	jne    8021b9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8021ae:	8b 43 0c             	mov    0xc(%ebx),%eax
  8021b1:	89 04 24             	mov    %eax,(%esp)
  8021b4:	e8 b9 02 00 00       	call   802472 <nsipc_close>
	else
		return 0;
}
  8021b9:	83 c4 14             	add    $0x14,%esp
  8021bc:	5b                   	pop    %ebx
  8021bd:	5d                   	pop    %ebp
  8021be:	c3                   	ret    

008021bf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8021bf:	55                   	push   %ebp
  8021c0:	89 e5                	mov    %esp,%ebp
  8021c2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8021c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8021cc:	00 
  8021cd:	8b 45 10             	mov    0x10(%ebp),%eax
  8021d0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021db:	8b 45 08             	mov    0x8(%ebp),%eax
  8021de:	8b 40 0c             	mov    0xc(%eax),%eax
  8021e1:	89 04 24             	mov    %eax,(%esp)
  8021e4:	e8 c5 02 00 00       	call   8024ae <nsipc_send>
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    

008021eb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8021f1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8021f8:	00 
  8021f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8021fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  802200:	8b 45 0c             	mov    0xc(%ebp),%eax
  802203:	89 44 24 04          	mov    %eax,0x4(%esp)
  802207:	8b 45 08             	mov    0x8(%ebp),%eax
  80220a:	8b 40 0c             	mov    0xc(%eax),%eax
  80220d:	89 04 24             	mov    %eax,(%esp)
  802210:	e8 0c 03 00 00       	call   802521 <nsipc_recv>
}
  802215:	c9                   	leave  
  802216:	c3                   	ret    

00802217 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802217:	55                   	push   %ebp
  802218:	89 e5                	mov    %esp,%ebp
  80221a:	56                   	push   %esi
  80221b:	53                   	push   %ebx
  80221c:	83 ec 20             	sub    $0x20,%esp
  80221f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802221:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802224:	89 04 24             	mov    %eax,(%esp)
  802227:	e8 7f f6 ff ff       	call   8018ab <fd_alloc>
  80222c:	89 c3                	mov    %eax,%ebx
  80222e:	85 c0                	test   %eax,%eax
  802230:	78 21                	js     802253 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802232:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802239:	00 
  80223a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802241:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802248:	e8 10 ef ff ff       	call   80115d <sys_page_alloc>
  80224d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80224f:	85 c0                	test   %eax,%eax
  802251:	79 0a                	jns    80225d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802253:	89 34 24             	mov    %esi,(%esp)
  802256:	e8 17 02 00 00       	call   802472 <nsipc_close>
		return r;
  80225b:	eb 28                	jmp    802285 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80225d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802266:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802268:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802272:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802275:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802278:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80227b:	89 04 24             	mov    %eax,(%esp)
  80227e:	e8 fd f5 ff ff       	call   801880 <fd2num>
  802283:	89 c3                	mov    %eax,%ebx
}
  802285:	89 d8                	mov    %ebx,%eax
  802287:	83 c4 20             	add    $0x20,%esp
  80228a:	5b                   	pop    %ebx
  80228b:	5e                   	pop    %esi
  80228c:	5d                   	pop    %ebp
  80228d:	c3                   	ret    

0080228e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80228e:	55                   	push   %ebp
  80228f:	89 e5                	mov    %esp,%ebp
  802291:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802294:	8b 45 10             	mov    0x10(%ebp),%eax
  802297:	89 44 24 08          	mov    %eax,0x8(%esp)
  80229b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80229e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a5:	89 04 24             	mov    %eax,(%esp)
  8022a8:	e8 79 01 00 00       	call   802426 <nsipc_socket>
  8022ad:	85 c0                	test   %eax,%eax
  8022af:	78 05                	js     8022b6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8022b1:	e8 61 ff ff ff       	call   802217 <alloc_sockfd>
}
  8022b6:	c9                   	leave  
  8022b7:	c3                   	ret    

008022b8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8022b8:	55                   	push   %ebp
  8022b9:	89 e5                	mov    %esp,%ebp
  8022bb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8022be:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8022c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022c5:	89 04 24             	mov    %eax,(%esp)
  8022c8:	e8 50 f6 ff ff       	call   80191d <fd_lookup>
  8022cd:	85 c0                	test   %eax,%eax
  8022cf:	78 15                	js     8022e6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8022d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8022d4:	8b 0a                	mov    (%edx),%ecx
  8022d6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8022db:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8022e1:	75 03                	jne    8022e6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8022e3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8022e6:	c9                   	leave  
  8022e7:	c3                   	ret    

008022e8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8022e8:	55                   	push   %ebp
  8022e9:	89 e5                	mov    %esp,%ebp
  8022eb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8022ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f1:	e8 c2 ff ff ff       	call   8022b8 <fd2sockid>
  8022f6:	85 c0                	test   %eax,%eax
  8022f8:	78 0f                	js     802309 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  8022fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022fd:	89 54 24 04          	mov    %edx,0x4(%esp)
  802301:	89 04 24             	mov    %eax,(%esp)
  802304:	e8 47 01 00 00       	call   802450 <nsipc_listen>
}
  802309:	c9                   	leave  
  80230a:	c3                   	ret    

0080230b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80230b:	55                   	push   %ebp
  80230c:	89 e5                	mov    %esp,%ebp
  80230e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802311:	8b 45 08             	mov    0x8(%ebp),%eax
  802314:	e8 9f ff ff ff       	call   8022b8 <fd2sockid>
  802319:	85 c0                	test   %eax,%eax
  80231b:	78 16                	js     802333 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80231d:	8b 55 10             	mov    0x10(%ebp),%edx
  802320:	89 54 24 08          	mov    %edx,0x8(%esp)
  802324:	8b 55 0c             	mov    0xc(%ebp),%edx
  802327:	89 54 24 04          	mov    %edx,0x4(%esp)
  80232b:	89 04 24             	mov    %eax,(%esp)
  80232e:	e8 6e 02 00 00       	call   8025a1 <nsipc_connect>
}
  802333:	c9                   	leave  
  802334:	c3                   	ret    

00802335 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802335:	55                   	push   %ebp
  802336:	89 e5                	mov    %esp,%ebp
  802338:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80233b:	8b 45 08             	mov    0x8(%ebp),%eax
  80233e:	e8 75 ff ff ff       	call   8022b8 <fd2sockid>
  802343:	85 c0                	test   %eax,%eax
  802345:	78 0f                	js     802356 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802347:	8b 55 0c             	mov    0xc(%ebp),%edx
  80234a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80234e:	89 04 24             	mov    %eax,(%esp)
  802351:	e8 36 01 00 00       	call   80248c <nsipc_shutdown>
}
  802356:	c9                   	leave  
  802357:	c3                   	ret    

00802358 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80235e:	8b 45 08             	mov    0x8(%ebp),%eax
  802361:	e8 52 ff ff ff       	call   8022b8 <fd2sockid>
  802366:	85 c0                	test   %eax,%eax
  802368:	78 16                	js     802380 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80236a:	8b 55 10             	mov    0x10(%ebp),%edx
  80236d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802371:	8b 55 0c             	mov    0xc(%ebp),%edx
  802374:	89 54 24 04          	mov    %edx,0x4(%esp)
  802378:	89 04 24             	mov    %eax,(%esp)
  80237b:	e8 60 02 00 00       	call   8025e0 <nsipc_bind>
}
  802380:	c9                   	leave  
  802381:	c3                   	ret    

00802382 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802382:	55                   	push   %ebp
  802383:	89 e5                	mov    %esp,%ebp
  802385:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802388:	8b 45 08             	mov    0x8(%ebp),%eax
  80238b:	e8 28 ff ff ff       	call   8022b8 <fd2sockid>
  802390:	85 c0                	test   %eax,%eax
  802392:	78 1f                	js     8023b3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802394:	8b 55 10             	mov    0x10(%ebp),%edx
  802397:	89 54 24 08          	mov    %edx,0x8(%esp)
  80239b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80239e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a2:	89 04 24             	mov    %eax,(%esp)
  8023a5:	e8 75 02 00 00       	call   80261f <nsipc_accept>
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	78 05                	js     8023b3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8023ae:	e8 64 fe ff ff       	call   802217 <alloc_sockfd>
}
  8023b3:	c9                   	leave  
  8023b4:	c3                   	ret    
	...

008023c0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8023c0:	55                   	push   %ebp
  8023c1:	89 e5                	mov    %esp,%ebp
  8023c3:	53                   	push   %ebx
  8023c4:	83 ec 14             	sub    $0x14,%esp
  8023c7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8023c9:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  8023d0:	75 11                	jne    8023e3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8023d2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8023d9:	e8 62 f3 ff ff       	call   801740 <ipc_find_env>
  8023de:	a3 08 50 80 00       	mov    %eax,0x805008
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8023e3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8023ea:	00 
  8023eb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  8023f2:	00 
  8023f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023f7:	a1 08 50 80 00       	mov    0x805008,%eax
  8023fc:	89 04 24             	mov    %eax,(%esp)
  8023ff:	e8 80 f3 ff ff       	call   801784 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802404:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80240b:	00 
  80240c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802413:	00 
  802414:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80241b:	e8 cf f3 ff ff       	call   8017ef <ipc_recv>
}
  802420:	83 c4 14             	add    $0x14,%esp
  802423:	5b                   	pop    %ebx
  802424:	5d                   	pop    %ebp
  802425:	c3                   	ret    

00802426 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80242c:	8b 45 08             	mov    0x8(%ebp),%eax
  80242f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802434:	8b 45 0c             	mov    0xc(%ebp),%eax
  802437:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80243c:	8b 45 10             	mov    0x10(%ebp),%eax
  80243f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802444:	b8 09 00 00 00       	mov    $0x9,%eax
  802449:	e8 72 ff ff ff       	call   8023c0 <nsipc>
}
  80244e:	c9                   	leave  
  80244f:	c3                   	ret    

00802450 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802450:	55                   	push   %ebp
  802451:	89 e5                	mov    %esp,%ebp
  802453:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802456:	8b 45 08             	mov    0x8(%ebp),%eax
  802459:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80245e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802461:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802466:	b8 06 00 00 00       	mov    $0x6,%eax
  80246b:	e8 50 ff ff ff       	call   8023c0 <nsipc>
}
  802470:	c9                   	leave  
  802471:	c3                   	ret    

00802472 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802472:	55                   	push   %ebp
  802473:	89 e5                	mov    %esp,%ebp
  802475:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802478:	8b 45 08             	mov    0x8(%ebp),%eax
  80247b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802480:	b8 04 00 00 00       	mov    $0x4,%eax
  802485:	e8 36 ff ff ff       	call   8023c0 <nsipc>
}
  80248a:	c9                   	leave  
  80248b:	c3                   	ret    

0080248c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80248c:	55                   	push   %ebp
  80248d:	89 e5                	mov    %esp,%ebp
  80248f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802492:	8b 45 08             	mov    0x8(%ebp),%eax
  802495:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80249a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80249d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8024a2:	b8 03 00 00 00       	mov    $0x3,%eax
  8024a7:	e8 14 ff ff ff       	call   8023c0 <nsipc>
}
  8024ac:	c9                   	leave  
  8024ad:	c3                   	ret    

008024ae <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8024ae:	55                   	push   %ebp
  8024af:	89 e5                	mov    %esp,%ebp
  8024b1:	53                   	push   %ebx
  8024b2:	83 ec 14             	sub    $0x14,%esp
  8024b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8024b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8024bb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8024c0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8024c6:	7e 24                	jle    8024ec <nsipc_send+0x3e>
  8024c8:	c7 44 24 0c b1 31 80 	movl   $0x8031b1,0xc(%esp)
  8024cf:	00 
  8024d0:	c7 44 24 08 85 31 80 	movl   $0x803185,0x8(%esp)
  8024d7:	00 
  8024d8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8024df:	00 
  8024e0:	c7 04 24 bd 31 80 00 	movl   $0x8031bd,(%esp)
  8024e7:	e8 18 de ff ff       	call   800304 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8024ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024f7:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  8024fe:	e8 e2 e7 ff ff       	call   800ce5 <memmove>
	nsipcbuf.send.req_size = size;
  802503:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802509:	8b 45 14             	mov    0x14(%ebp),%eax
  80250c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802511:	b8 08 00 00 00       	mov    $0x8,%eax
  802516:	e8 a5 fe ff ff       	call   8023c0 <nsipc>
}
  80251b:	83 c4 14             	add    $0x14,%esp
  80251e:	5b                   	pop    %ebx
  80251f:	5d                   	pop    %ebp
  802520:	c3                   	ret    

00802521 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802521:	55                   	push   %ebp
  802522:	89 e5                	mov    %esp,%ebp
  802524:	56                   	push   %esi
  802525:	53                   	push   %ebx
  802526:	83 ec 10             	sub    $0x10,%esp
  802529:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80252c:	8b 45 08             	mov    0x8(%ebp),%eax
  80252f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802534:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80253a:	8b 45 14             	mov    0x14(%ebp),%eax
  80253d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802542:	b8 07 00 00 00       	mov    $0x7,%eax
  802547:	e8 74 fe ff ff       	call   8023c0 <nsipc>
  80254c:	89 c3                	mov    %eax,%ebx
  80254e:	85 c0                	test   %eax,%eax
  802550:	78 46                	js     802598 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802552:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802557:	7f 04                	jg     80255d <nsipc_recv+0x3c>
  802559:	39 c6                	cmp    %eax,%esi
  80255b:	7d 24                	jge    802581 <nsipc_recv+0x60>
  80255d:	c7 44 24 0c c9 31 80 	movl   $0x8031c9,0xc(%esp)
  802564:	00 
  802565:	c7 44 24 08 85 31 80 	movl   $0x803185,0x8(%esp)
  80256c:	00 
  80256d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802574:	00 
  802575:	c7 04 24 bd 31 80 00 	movl   $0x8031bd,(%esp)
  80257c:	e8 83 dd ff ff       	call   800304 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802581:	89 44 24 08          	mov    %eax,0x8(%esp)
  802585:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80258c:	00 
  80258d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802590:	89 04 24             	mov    %eax,(%esp)
  802593:	e8 4d e7 ff ff       	call   800ce5 <memmove>
	}

	return r;
}
  802598:	89 d8                	mov    %ebx,%eax
  80259a:	83 c4 10             	add    $0x10,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5d                   	pop    %ebp
  8025a0:	c3                   	ret    

008025a1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8025a1:	55                   	push   %ebp
  8025a2:	89 e5                	mov    %esp,%ebp
  8025a4:	53                   	push   %ebx
  8025a5:	83 ec 14             	sub    $0x14,%esp
  8025a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8025ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ae:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8025b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025be:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8025c5:	e8 1b e7 ff ff       	call   800ce5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8025ca:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8025d0:	b8 05 00 00 00       	mov    $0x5,%eax
  8025d5:	e8 e6 fd ff ff       	call   8023c0 <nsipc>
}
  8025da:	83 c4 14             	add    $0x14,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5d                   	pop    %ebp
  8025df:	c3                   	ret    

008025e0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8025e0:	55                   	push   %ebp
  8025e1:	89 e5                	mov    %esp,%ebp
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 14             	sub    $0x14,%esp
  8025e7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8025ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ed:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8025f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8025f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025fd:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802604:	e8 dc e6 ff ff       	call   800ce5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802609:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80260f:	b8 02 00 00 00       	mov    $0x2,%eax
  802614:	e8 a7 fd ff ff       	call   8023c0 <nsipc>
}
  802619:	83 c4 14             	add    $0x14,%esp
  80261c:	5b                   	pop    %ebx
  80261d:	5d                   	pop    %ebp
  80261e:	c3                   	ret    

0080261f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80261f:	55                   	push   %ebp
  802620:	89 e5                	mov    %esp,%ebp
  802622:	83 ec 18             	sub    $0x18,%esp
  802625:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802628:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80262b:	8b 45 08             	mov    0x8(%ebp),%eax
  80262e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802633:	b8 01 00 00 00       	mov    $0x1,%eax
  802638:	e8 83 fd ff ff       	call   8023c0 <nsipc>
  80263d:	89 c3                	mov    %eax,%ebx
  80263f:	85 c0                	test   %eax,%eax
  802641:	78 25                	js     802668 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802643:	be 10 70 80 00       	mov    $0x807010,%esi
  802648:	8b 06                	mov    (%esi),%eax
  80264a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80264e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802655:	00 
  802656:	8b 45 0c             	mov    0xc(%ebp),%eax
  802659:	89 04 24             	mov    %eax,(%esp)
  80265c:	e8 84 e6 ff ff       	call   800ce5 <memmove>
		*addrlen = ret->ret_addrlen;
  802661:	8b 16                	mov    (%esi),%edx
  802663:	8b 45 10             	mov    0x10(%ebp),%eax
  802666:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80266d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802670:	89 ec                	mov    %ebp,%esp
  802672:	5d                   	pop    %ebp
  802673:	c3                   	ret    

00802674 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802674:	55                   	push   %ebp
  802675:	89 e5                	mov    %esp,%ebp
  802677:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80267a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802681:	75 54                	jne    8026d7 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  802683:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80268a:	00 
  80268b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802692:	ee 
  802693:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80269a:	e8 be ea ff ff       	call   80115d <sys_page_alloc>
  80269f:	85 c0                	test   %eax,%eax
  8026a1:	79 20                	jns    8026c3 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8026a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026a7:	c7 44 24 08 de 31 80 	movl   $0x8031de,0x8(%esp)
  8026ae:	00 
  8026af:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8026b6:	00 
  8026b7:	c7 04 24 f6 31 80 00 	movl   $0x8031f6,(%esp)
  8026be:	e8 41 dc ff ff       	call   800304 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8026c3:	c7 44 24 04 e4 26 80 	movl   $0x8026e4,0x4(%esp)
  8026ca:	00 
  8026cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8026d2:	e8 6d e9 ff ff       	call   801044 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8026d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8026da:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8026df:	c9                   	leave  
  8026e0:	c3                   	ret    
  8026e1:	00 00                	add    %al,(%eax)
	...

008026e4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026e4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026e5:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8026ea:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026ec:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8026ef:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8026f3:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8026f6:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8026fa:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8026fe:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802700:	83 c4 08             	add    $0x8,%esp
	popal
  802703:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  802704:	83 c4 04             	add    $0x4,%esp
	popfl
  802707:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802708:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802709:	c3                   	ret    
	...

0080270c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80270c:	55                   	push   %ebp
  80270d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80270f:	8b 45 08             	mov    0x8(%ebp),%eax
  802712:	89 c2                	mov    %eax,%edx
  802714:	c1 ea 16             	shr    $0x16,%edx
  802717:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80271e:	f6 c2 01             	test   $0x1,%dl
  802721:	74 20                	je     802743 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802723:	c1 e8 0c             	shr    $0xc,%eax
  802726:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80272d:	a8 01                	test   $0x1,%al
  80272f:	74 12                	je     802743 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802731:	c1 e8 0c             	shr    $0xc,%eax
  802734:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802739:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80273e:	0f b7 c0             	movzwl %ax,%eax
  802741:	eb 05                	jmp    802748 <pageref+0x3c>
  802743:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802748:	5d                   	pop    %ebp
  802749:	c3                   	ret    
  80274a:	00 00                	add    %al,(%eax)
  80274c:	00 00                	add    %al,(%eax)
	...

00802750 <__udivdi3>:
  802750:	55                   	push   %ebp
  802751:	89 e5                	mov    %esp,%ebp
  802753:	57                   	push   %edi
  802754:	56                   	push   %esi
  802755:	83 ec 10             	sub    $0x10,%esp
  802758:	8b 45 14             	mov    0x14(%ebp),%eax
  80275b:	8b 55 08             	mov    0x8(%ebp),%edx
  80275e:	8b 75 10             	mov    0x10(%ebp),%esi
  802761:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802764:	85 c0                	test   %eax,%eax
  802766:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802769:	75 35                	jne    8027a0 <__udivdi3+0x50>
  80276b:	39 fe                	cmp    %edi,%esi
  80276d:	77 61                	ja     8027d0 <__udivdi3+0x80>
  80276f:	85 f6                	test   %esi,%esi
  802771:	75 0b                	jne    80277e <__udivdi3+0x2e>
  802773:	b8 01 00 00 00       	mov    $0x1,%eax
  802778:	31 d2                	xor    %edx,%edx
  80277a:	f7 f6                	div    %esi
  80277c:	89 c6                	mov    %eax,%esi
  80277e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802781:	31 d2                	xor    %edx,%edx
  802783:	89 f8                	mov    %edi,%eax
  802785:	f7 f6                	div    %esi
  802787:	89 c7                	mov    %eax,%edi
  802789:	89 c8                	mov    %ecx,%eax
  80278b:	f7 f6                	div    %esi
  80278d:	89 c1                	mov    %eax,%ecx
  80278f:	89 fa                	mov    %edi,%edx
  802791:	89 c8                	mov    %ecx,%eax
  802793:	83 c4 10             	add    $0x10,%esp
  802796:	5e                   	pop    %esi
  802797:	5f                   	pop    %edi
  802798:	5d                   	pop    %ebp
  802799:	c3                   	ret    
  80279a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027a0:	39 f8                	cmp    %edi,%eax
  8027a2:	77 1c                	ja     8027c0 <__udivdi3+0x70>
  8027a4:	0f bd d0             	bsr    %eax,%edx
  8027a7:	83 f2 1f             	xor    $0x1f,%edx
  8027aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027ad:	75 39                	jne    8027e8 <__udivdi3+0x98>
  8027af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8027b2:	0f 86 a0 00 00 00    	jbe    802858 <__udivdi3+0x108>
  8027b8:	39 f8                	cmp    %edi,%eax
  8027ba:	0f 82 98 00 00 00    	jb     802858 <__udivdi3+0x108>
  8027c0:	31 ff                	xor    %edi,%edi
  8027c2:	31 c9                	xor    %ecx,%ecx
  8027c4:	89 c8                	mov    %ecx,%eax
  8027c6:	89 fa                	mov    %edi,%edx
  8027c8:	83 c4 10             	add    $0x10,%esp
  8027cb:	5e                   	pop    %esi
  8027cc:	5f                   	pop    %edi
  8027cd:	5d                   	pop    %ebp
  8027ce:	c3                   	ret    
  8027cf:	90                   	nop
  8027d0:	89 d1                	mov    %edx,%ecx
  8027d2:	89 fa                	mov    %edi,%edx
  8027d4:	89 c8                	mov    %ecx,%eax
  8027d6:	31 ff                	xor    %edi,%edi
  8027d8:	f7 f6                	div    %esi
  8027da:	89 c1                	mov    %eax,%ecx
  8027dc:	89 fa                	mov    %edi,%edx
  8027de:	89 c8                	mov    %ecx,%eax
  8027e0:	83 c4 10             	add    $0x10,%esp
  8027e3:	5e                   	pop    %esi
  8027e4:	5f                   	pop    %edi
  8027e5:	5d                   	pop    %ebp
  8027e6:	c3                   	ret    
  8027e7:	90                   	nop
  8027e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8027ec:	89 f2                	mov    %esi,%edx
  8027ee:	d3 e0                	shl    %cl,%eax
  8027f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8027f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8027f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8027fb:	89 c1                	mov    %eax,%ecx
  8027fd:	d3 ea                	shr    %cl,%edx
  8027ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802803:	0b 55 ec             	or     -0x14(%ebp),%edx
  802806:	d3 e6                	shl    %cl,%esi
  802808:	89 c1                	mov    %eax,%ecx
  80280a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80280d:	89 fe                	mov    %edi,%esi
  80280f:	d3 ee                	shr    %cl,%esi
  802811:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802815:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802818:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80281b:	d3 e7                	shl    %cl,%edi
  80281d:	89 c1                	mov    %eax,%ecx
  80281f:	d3 ea                	shr    %cl,%edx
  802821:	09 d7                	or     %edx,%edi
  802823:	89 f2                	mov    %esi,%edx
  802825:	89 f8                	mov    %edi,%eax
  802827:	f7 75 ec             	divl   -0x14(%ebp)
  80282a:	89 d6                	mov    %edx,%esi
  80282c:	89 c7                	mov    %eax,%edi
  80282e:	f7 65 e8             	mull   -0x18(%ebp)
  802831:	39 d6                	cmp    %edx,%esi
  802833:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802836:	72 30                	jb     802868 <__udivdi3+0x118>
  802838:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80283b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80283f:	d3 e2                	shl    %cl,%edx
  802841:	39 c2                	cmp    %eax,%edx
  802843:	73 05                	jae    80284a <__udivdi3+0xfa>
  802845:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802848:	74 1e                	je     802868 <__udivdi3+0x118>
  80284a:	89 f9                	mov    %edi,%ecx
  80284c:	31 ff                	xor    %edi,%edi
  80284e:	e9 71 ff ff ff       	jmp    8027c4 <__udivdi3+0x74>
  802853:	90                   	nop
  802854:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802858:	31 ff                	xor    %edi,%edi
  80285a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80285f:	e9 60 ff ff ff       	jmp    8027c4 <__udivdi3+0x74>
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80286b:	31 ff                	xor    %edi,%edi
  80286d:	89 c8                	mov    %ecx,%eax
  80286f:	89 fa                	mov    %edi,%edx
  802871:	83 c4 10             	add    $0x10,%esp
  802874:	5e                   	pop    %esi
  802875:	5f                   	pop    %edi
  802876:	5d                   	pop    %ebp
  802877:	c3                   	ret    
	...

00802880 <__umoddi3>:
  802880:	55                   	push   %ebp
  802881:	89 e5                	mov    %esp,%ebp
  802883:	57                   	push   %edi
  802884:	56                   	push   %esi
  802885:	83 ec 20             	sub    $0x20,%esp
  802888:	8b 55 14             	mov    0x14(%ebp),%edx
  80288b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80288e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802891:	8b 75 0c             	mov    0xc(%ebp),%esi
  802894:	85 d2                	test   %edx,%edx
  802896:	89 c8                	mov    %ecx,%eax
  802898:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80289b:	75 13                	jne    8028b0 <__umoddi3+0x30>
  80289d:	39 f7                	cmp    %esi,%edi
  80289f:	76 3f                	jbe    8028e0 <__umoddi3+0x60>
  8028a1:	89 f2                	mov    %esi,%edx
  8028a3:	f7 f7                	div    %edi
  8028a5:	89 d0                	mov    %edx,%eax
  8028a7:	31 d2                	xor    %edx,%edx
  8028a9:	83 c4 20             	add    $0x20,%esp
  8028ac:	5e                   	pop    %esi
  8028ad:	5f                   	pop    %edi
  8028ae:	5d                   	pop    %ebp
  8028af:	c3                   	ret    
  8028b0:	39 f2                	cmp    %esi,%edx
  8028b2:	77 4c                	ja     802900 <__umoddi3+0x80>
  8028b4:	0f bd ca             	bsr    %edx,%ecx
  8028b7:	83 f1 1f             	xor    $0x1f,%ecx
  8028ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8028bd:	75 51                	jne    802910 <__umoddi3+0x90>
  8028bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8028c2:	0f 87 e0 00 00 00    	ja     8029a8 <__umoddi3+0x128>
  8028c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028cb:	29 f8                	sub    %edi,%eax
  8028cd:	19 d6                	sbb    %edx,%esi
  8028cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8028d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028d5:	89 f2                	mov    %esi,%edx
  8028d7:	83 c4 20             	add    $0x20,%esp
  8028da:	5e                   	pop    %esi
  8028db:	5f                   	pop    %edi
  8028dc:	5d                   	pop    %ebp
  8028dd:	c3                   	ret    
  8028de:	66 90                	xchg   %ax,%ax
  8028e0:	85 ff                	test   %edi,%edi
  8028e2:	75 0b                	jne    8028ef <__umoddi3+0x6f>
  8028e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028e9:	31 d2                	xor    %edx,%edx
  8028eb:	f7 f7                	div    %edi
  8028ed:	89 c7                	mov    %eax,%edi
  8028ef:	89 f0                	mov    %esi,%eax
  8028f1:	31 d2                	xor    %edx,%edx
  8028f3:	f7 f7                	div    %edi
  8028f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8028f8:	f7 f7                	div    %edi
  8028fa:	eb a9                	jmp    8028a5 <__umoddi3+0x25>
  8028fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802900:	89 c8                	mov    %ecx,%eax
  802902:	89 f2                	mov    %esi,%edx
  802904:	83 c4 20             	add    $0x20,%esp
  802907:	5e                   	pop    %esi
  802908:	5f                   	pop    %edi
  802909:	5d                   	pop    %ebp
  80290a:	c3                   	ret    
  80290b:	90                   	nop
  80290c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802910:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802914:	d3 e2                	shl    %cl,%edx
  802916:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802919:	ba 20 00 00 00       	mov    $0x20,%edx
  80291e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802921:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802924:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802928:	89 fa                	mov    %edi,%edx
  80292a:	d3 ea                	shr    %cl,%edx
  80292c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802930:	0b 55 f4             	or     -0xc(%ebp),%edx
  802933:	d3 e7                	shl    %cl,%edi
  802935:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802939:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80293c:	89 f2                	mov    %esi,%edx
  80293e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802941:	89 c7                	mov    %eax,%edi
  802943:	d3 ea                	shr    %cl,%edx
  802945:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802949:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80294c:	89 c2                	mov    %eax,%edx
  80294e:	d3 e6                	shl    %cl,%esi
  802950:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802954:	d3 ea                	shr    %cl,%edx
  802956:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80295a:	09 d6                	or     %edx,%esi
  80295c:	89 f0                	mov    %esi,%eax
  80295e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802961:	d3 e7                	shl    %cl,%edi
  802963:	89 f2                	mov    %esi,%edx
  802965:	f7 75 f4             	divl   -0xc(%ebp)
  802968:	89 d6                	mov    %edx,%esi
  80296a:	f7 65 e8             	mull   -0x18(%ebp)
  80296d:	39 d6                	cmp    %edx,%esi
  80296f:	72 2b                	jb     80299c <__umoddi3+0x11c>
  802971:	39 c7                	cmp    %eax,%edi
  802973:	72 23                	jb     802998 <__umoddi3+0x118>
  802975:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802979:	29 c7                	sub    %eax,%edi
  80297b:	19 d6                	sbb    %edx,%esi
  80297d:	89 f0                	mov    %esi,%eax
  80297f:	89 f2                	mov    %esi,%edx
  802981:	d3 ef                	shr    %cl,%edi
  802983:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802987:	d3 e0                	shl    %cl,%eax
  802989:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80298d:	09 f8                	or     %edi,%eax
  80298f:	d3 ea                	shr    %cl,%edx
  802991:	83 c4 20             	add    $0x20,%esp
  802994:	5e                   	pop    %esi
  802995:	5f                   	pop    %edi
  802996:	5d                   	pop    %ebp
  802997:	c3                   	ret    
  802998:	39 d6                	cmp    %edx,%esi
  80299a:	75 d9                	jne    802975 <__umoddi3+0xf5>
  80299c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80299f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8029a2:	eb d1                	jmp    802975 <__umoddi3+0xf5>
  8029a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8029a8:	39 f2                	cmp    %esi,%edx
  8029aa:	0f 82 18 ff ff ff    	jb     8028c8 <__umoddi3+0x48>
  8029b0:	e9 1d ff ff ff       	jmp    8028d2 <__umoddi3+0x52>
