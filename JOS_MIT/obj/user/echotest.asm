
obj/user/echotest.debug:     file format elf32-i386


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
  80002c:	e8 bb 01 00 00       	call   8001ec <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:

const char *msg = "Hello world!\n";

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 80 27 80 00 	movl   $0x802780,(%esp)
  800045:	e8 6f 02 00 00       	call   8002b9 <cprintf>
	exit();
  80004a:	e8 ed 01 00 00       	call   80023c <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <umain>:

void umain(int argc, char **argv)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 5c             	sub    $0x5c,%esp
	struct sockaddr_in echoserver;
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	cprintf("Connecting to:\n");
  80005a:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  800061:	e8 53 02 00 00       	call   8002b9 <cprintf>
	cprintf("\tip address %s = %x\n", IPADDR, inet_addr(IPADDR));
  800066:	c7 04 24 94 27 80 00 	movl   $0x802794,(%esp)
  80006d:	e8 4e 24 00 00       	call   8024c0 <inet_addr>
  800072:	89 44 24 08          	mov    %eax,0x8(%esp)
  800076:	c7 44 24 04 94 27 80 	movl   $0x802794,0x4(%esp)
  80007d:	00 
  80007e:	c7 04 24 9e 27 80 00 	movl   $0x80279e,(%esp)
  800085:	e8 2f 02 00 00       	call   8002b9 <cprintf>

	// Create the TCP socket
	if ((sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  80008a:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800091:	00 
  800092:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800099:	00 
  80009a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8000a1:	e8 58 1b 00 00       	call   801bfe <socket>
  8000a6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  8000a9:	85 c0                	test   %eax,%eax
  8000ab:	79 0a                	jns    8000b7 <umain+0x66>
		die("Failed to create socket");
  8000ad:	b8 b3 27 80 00       	mov    $0x8027b3,%eax
  8000b2:	e8 7d ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  8000b7:	c7 04 24 cb 27 80 00 	movl   $0x8027cb,(%esp)
  8000be:	e8 f6 01 00 00       	call   8002b9 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  8000c3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8000d6:	89 1c 24             	mov    %ebx,(%esp)
  8000d9:	e8 a8 0a 00 00       	call   800b86 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  8000de:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = inet_addr(IPADDR);   // IP address
  8000e2:	c7 04 24 94 27 80 00 	movl   $0x802794,(%esp)
  8000e9:	e8 d2 23 00 00       	call   8024c0 <inet_addr>
  8000ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  8000f1:	c7 04 24 10 27 00 00 	movl   $0x2710,(%esp)
  8000f8:	e8 a6 21 00 00       	call   8022a3 <htons>
  8000fd:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to connect to server\n");
  800101:	c7 04 24 da 27 80 00 	movl   $0x8027da,(%esp)
  800108:	e8 ac 01 00 00       	call   8002b9 <cprintf>

	// Establish connection
	if (connect(sock, (struct sockaddr *) &echoserver, sizeof(echoserver)) < 0)
  80010d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800114:	00 
  800115:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800119:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 57 1b 00 00       	call   801c7b <connect>
  800124:	85 c0                	test   %eax,%eax
  800126:	79 0a                	jns    800132 <umain+0xe1>
		die("Failed to connect with server");
  800128:	b8 f7 27 80 00       	mov    $0x8027f7,%eax
  80012d:	e8 02 ff ff ff       	call   800034 <die>

	cprintf("connected to server\n");
  800132:	c7 04 24 15 28 80 00 	movl   $0x802815,(%esp)
  800139:	e8 7b 01 00 00       	call   8002b9 <cprintf>

	// Send the word to the server
	echolen = strlen(msg);
  80013e:	a1 00 30 80 00       	mov    0x803000,%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 65 08 00 00       	call   8009b0 <strlen>
  80014b:	89 45 b0             	mov    %eax,-0x50(%ebp)
	if (write(sock, msg, echolen) != echolen)
  80014e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800152:	a1 00 30 80 00       	mov    0x803000,%eax
  800157:	89 44 24 04          	mov    %eax,0x4(%esp)
  80015b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80015e:	89 04 24             	mov    %eax,(%esp)
  800161:	e8 04 13 00 00       	call   80146a <write>
  800166:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  800169:	74 0a                	je     800175 <umain+0x124>
		die("Mismatch in number of sent bytes");
  80016b:	b8 44 28 80 00       	mov    $0x802844,%eax
  800170:	e8 bf fe ff ff       	call   800034 <die>

	// Receive the word back from the server
	cprintf("Received: \n");
  800175:	c7 04 24 2a 28 80 00 	movl   $0x80282a,(%esp)
  80017c:	e8 38 01 00 00       	call   8002b9 <cprintf>
	while (received < echolen) {
  800181:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  800185:	74 43                	je     8001ca <umain+0x179>
  800187:	bf 00 00 00 00       	mov    $0x0,%edi
		int bytes = 0;
		if ((bytes = read(sock, buffer, BUFFSIZE-1)) < 1) {
  80018c:	8d 75 b8             	lea    -0x48(%ebp),%esi
  80018f:	c7 44 24 08 1f 00 00 	movl   $0x1f,0x8(%esp)
  800196:	00 
  800197:	89 74 24 04          	mov    %esi,0x4(%esp)
  80019b:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  80019e:	89 04 24             	mov    %eax,(%esp)
  8001a1:	e8 4d 13 00 00       	call   8014f3 <read>
  8001a6:	89 c3                	mov    %eax,%ebx
  8001a8:	85 c0                	test   %eax,%eax
  8001aa:	7f 0a                	jg     8001b6 <umain+0x165>
			die("Failed to receive bytes from server");
  8001ac:	b8 68 28 80 00       	mov    $0x802868,%eax
  8001b1:	e8 7e fe ff ff       	call   800034 <die>
		}
		received += bytes;
  8001b6:	01 df                	add    %ebx,%edi
		buffer[bytes] = '\0';        // Assure null terminated string
  8001b8:	c6 44 1d b8 00       	movb   $0x0,-0x48(%ebp,%ebx,1)
		cprintf(buffer);
  8001bd:	89 34 24             	mov    %esi,(%esp)
  8001c0:	e8 f4 00 00 00       	call   8002b9 <cprintf>
	if (write(sock, msg, echolen) != echolen)
		die("Mismatch in number of sent bytes");

	// Receive the word back from the server
	cprintf("Received: \n");
	while (received < echolen) {
  8001c5:	39 7d b0             	cmp    %edi,-0x50(%ebp)
  8001c8:	77 c5                	ja     80018f <umain+0x13e>
		}
		received += bytes;
		buffer[bytes] = '\0';        // Assure null terminated string
		cprintf(buffer);
	}
	cprintf("\n");
  8001ca:	c7 04 24 34 28 80 00 	movl   $0x802834,(%esp)
  8001d1:	e8 e3 00 00 00       	call   8002b9 <cprintf>

	close(sock);
  8001d6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 7b 14 00 00       	call   80165c <close>
}
  8001e1:	83 c4 5c             	add    $0x5c,%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5e                   	pop    %esi
  8001e6:	5f                   	pop    %edi
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
  8001e9:	00 00                	add    %al,(%eax)
	...

008001ec <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	83 ec 18             	sub    $0x18,%esp
  8001f2:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8001f5:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8001f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8001fe:	e8 04 0f 00 00       	call   801107 <sys_getenvid>
  800203:	25 ff 03 00 00       	and    $0x3ff,%eax
  800208:	c1 e0 07             	shl    $0x7,%eax
  80020b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800210:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800215:	85 f6                	test   %esi,%esi
  800217:	7e 07                	jle    800220 <libmain+0x34>
		binaryname = argv[0];
  800219:	8b 03                	mov    (%ebx),%eax
  80021b:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800220:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800224:	89 34 24             	mov    %esi,(%esp)
  800227:	e8 25 fe ff ff       	call   800051 <umain>

	// exit gracefully
	exit();
  80022c:	e8 0b 00 00 00       	call   80023c <exit>
}
  800231:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800234:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800237:	89 ec                	mov    %ebp,%esp
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    
	...

0080023c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800242:	e8 92 14 00 00       	call   8016d9 <close_all>
	sys_env_destroy(0);
  800247:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80024e:	e8 ef 0e 00 00       	call   801142 <sys_env_destroy>
}
  800253:	c9                   	leave  
  800254:	c3                   	ret    
  800255:	00 00                	add    %al,(%eax)
	...

00800258 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800258:	55                   	push   %ebp
  800259:	89 e5                	mov    %esp,%ebp
  80025b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800261:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800268:	00 00 00 
	b.cnt = 0;
  80026b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800272:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800275:	8b 45 0c             	mov    0xc(%ebp),%eax
  800278:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80027c:	8b 45 08             	mov    0x8(%ebp),%eax
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80028d:	c7 04 24 d3 02 80 00 	movl   $0x8002d3,(%esp)
  800294:	e8 d4 01 00 00       	call   80046d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800299:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80029f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a9:	89 04 24             	mov    %eax,(%esp)
  8002ac:	e8 05 0f 00 00       	call   8011b6 <sys_cputs>

	return b.cnt;
}
  8002b1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b9:	55                   	push   %ebp
  8002ba:	89 e5                	mov    %esp,%ebp
  8002bc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002bf:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	e8 87 ff ff ff       	call   800258 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 14             	sub    $0x14,%esp
  8002da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002dd:	8b 03                	mov    (%ebx),%eax
  8002df:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8002e6:	83 c0 01             	add    $0x1,%eax
  8002e9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f0:	75 19                	jne    80030b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002f2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002f9:	00 
  8002fa:	8d 43 08             	lea    0x8(%ebx),%eax
  8002fd:	89 04 24             	mov    %eax,(%esp)
  800300:	e8 b1 0e 00 00       	call   8011b6 <sys_cputs>
		b->idx = 0;
  800305:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80030b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80030f:	83 c4 14             	add    $0x14,%esp
  800312:	5b                   	pop    %ebx
  800313:	5d                   	pop    %ebp
  800314:	c3                   	ret    
	...

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 4c             	sub    $0x4c,%esp
  800329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032c:	89 d6                	mov    %edx,%esi
  80032e:	8b 45 08             	mov    0x8(%ebp),%eax
  800331:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800334:	8b 55 0c             	mov    0xc(%ebp),%edx
  800337:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80033a:	8b 45 10             	mov    0x10(%ebp),%eax
  80033d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800340:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800343:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800346:	b9 00 00 00 00       	mov    $0x0,%ecx
  80034b:	39 d1                	cmp    %edx,%ecx
  80034d:	72 15                	jb     800364 <printnum+0x44>
  80034f:	77 07                	ja     800358 <printnum+0x38>
  800351:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800354:	39 d0                	cmp    %edx,%eax
  800356:	76 0c                	jbe    800364 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800358:	83 eb 01             	sub    $0x1,%ebx
  80035b:	85 db                	test   %ebx,%ebx
  80035d:	8d 76 00             	lea    0x0(%esi),%esi
  800360:	7f 61                	jg     8003c3 <printnum+0xa3>
  800362:	eb 70                	jmp    8003d4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800364:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800368:	83 eb 01             	sub    $0x1,%ebx
  80036b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80036f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800373:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800377:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80037b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80037e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800381:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800384:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800388:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80038f:	00 
  800390:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800393:	89 04 24             	mov    %eax,(%esp)
  800396:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800399:	89 54 24 04          	mov    %edx,0x4(%esp)
  80039d:	e8 5e 21 00 00       	call   802500 <__udivdi3>
  8003a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8003a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003b0:	89 04 24             	mov    %eax,(%esp)
  8003b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003b7:	89 f2                	mov    %esi,%edx
  8003b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003bc:	e8 5f ff ff ff       	call   800320 <printnum>
  8003c1:	eb 11                	jmp    8003d4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c7:	89 3c 24             	mov    %edi,(%esp)
  8003ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003cd:	83 eb 01             	sub    $0x1,%ebx
  8003d0:	85 db                	test   %ebx,%ebx
  8003d2:	7f ef                	jg     8003c3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003ea:	00 
  8003eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8003ee:	89 14 24             	mov    %edx,(%esp)
  8003f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003f8:	e8 33 22 00 00       	call   802630 <__umoddi3>
  8003fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800401:	0f be 80 96 28 80 00 	movsbl 0x802896(%eax),%eax
  800408:	89 04 24             	mov    %eax,(%esp)
  80040b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80040e:	83 c4 4c             	add    $0x4c,%esp
  800411:	5b                   	pop    %ebx
  800412:	5e                   	pop    %esi
  800413:	5f                   	pop    %edi
  800414:	5d                   	pop    %ebp
  800415:	c3                   	ret    

00800416 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800416:	55                   	push   %ebp
  800417:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800419:	83 fa 01             	cmp    $0x1,%edx
  80041c:	7e 0e                	jle    80042c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80041e:	8b 10                	mov    (%eax),%edx
  800420:	8d 4a 08             	lea    0x8(%edx),%ecx
  800423:	89 08                	mov    %ecx,(%eax)
  800425:	8b 02                	mov    (%edx),%eax
  800427:	8b 52 04             	mov    0x4(%edx),%edx
  80042a:	eb 22                	jmp    80044e <getuint+0x38>
	else if (lflag)
  80042c:	85 d2                	test   %edx,%edx
  80042e:	74 10                	je     800440 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800430:	8b 10                	mov    (%eax),%edx
  800432:	8d 4a 04             	lea    0x4(%edx),%ecx
  800435:	89 08                	mov    %ecx,(%eax)
  800437:	8b 02                	mov    (%edx),%eax
  800439:	ba 00 00 00 00       	mov    $0x0,%edx
  80043e:	eb 0e                	jmp    80044e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800440:	8b 10                	mov    (%eax),%edx
  800442:	8d 4a 04             	lea    0x4(%edx),%ecx
  800445:	89 08                	mov    %ecx,(%eax)
  800447:	8b 02                	mov    (%edx),%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80044e:	5d                   	pop    %ebp
  80044f:	c3                   	ret    

00800450 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800450:	55                   	push   %ebp
  800451:	89 e5                	mov    %esp,%ebp
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800456:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80045a:	8b 10                	mov    (%eax),%edx
  80045c:	3b 50 04             	cmp    0x4(%eax),%edx
  80045f:	73 0a                	jae    80046b <sprintputch+0x1b>
		*b->buf++ = ch;
  800461:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800464:	88 0a                	mov    %cl,(%edx)
  800466:	83 c2 01             	add    $0x1,%edx
  800469:	89 10                	mov    %edx,(%eax)
}
  80046b:	5d                   	pop    %ebp
  80046c:	c3                   	ret    

0080046d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	57                   	push   %edi
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 5c             	sub    $0x5c,%esp
  800476:	8b 7d 08             	mov    0x8(%ebp),%edi
  800479:	8b 75 0c             	mov    0xc(%ebp),%esi
  80047c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80047f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800486:	eb 11                	jmp    800499 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800488:	85 c0                	test   %eax,%eax
  80048a:	0f 84 68 04 00 00    	je     8008f8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800490:	89 74 24 04          	mov    %esi,0x4(%esp)
  800494:	89 04 24             	mov    %eax,(%esp)
  800497:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800499:	0f b6 03             	movzbl (%ebx),%eax
  80049c:	83 c3 01             	add    $0x1,%ebx
  80049f:	83 f8 25             	cmp    $0x25,%eax
  8004a2:	75 e4                	jne    800488 <vprintfmt+0x1b>
  8004a4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004ab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004b7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8004bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004c2:	eb 06                	jmp    8004ca <vprintfmt+0x5d>
  8004c4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8004c8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ca:	0f b6 13             	movzbl (%ebx),%edx
  8004cd:	0f b6 c2             	movzbl %dl,%eax
  8004d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004d3:	8d 43 01             	lea    0x1(%ebx),%eax
  8004d6:	83 ea 23             	sub    $0x23,%edx
  8004d9:	80 fa 55             	cmp    $0x55,%dl
  8004dc:	0f 87 f9 03 00 00    	ja     8008db <vprintfmt+0x46e>
  8004e2:	0f b6 d2             	movzbl %dl,%edx
  8004e5:	ff 24 95 80 2a 80 00 	jmp    *0x802a80(,%edx,4)
  8004ec:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8004f0:	eb d6                	jmp    8004c8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004f5:	83 ea 30             	sub    $0x30,%edx
  8004f8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8004fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004fe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800501:	83 fb 09             	cmp    $0x9,%ebx
  800504:	77 54                	ja     80055a <vprintfmt+0xed>
  800506:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800509:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80050f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800512:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800516:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800519:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80051c:	83 fb 09             	cmp    $0x9,%ebx
  80051f:	76 eb                	jbe    80050c <vprintfmt+0x9f>
  800521:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800524:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800527:	eb 31                	jmp    80055a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800529:	8b 55 14             	mov    0x14(%ebp),%edx
  80052c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80052f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800532:	8b 12                	mov    (%edx),%edx
  800534:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800537:	eb 21                	jmp    80055a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800539:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053d:	ba 00 00 00 00       	mov    $0x0,%edx
  800542:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800546:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800549:	e9 7a ff ff ff       	jmp    8004c8 <vprintfmt+0x5b>
  80054e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800555:	e9 6e ff ff ff       	jmp    8004c8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80055a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055e:	0f 89 64 ff ff ff    	jns    8004c8 <vprintfmt+0x5b>
  800564:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800567:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80056a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80056d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800570:	e9 53 ff ff ff       	jmp    8004c8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800575:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800578:	e9 4b ff ff ff       	jmp    8004c8 <vprintfmt+0x5b>
  80057d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 50 04             	lea    0x4(%eax),%edx
  800586:	89 55 14             	mov    %edx,0x14(%ebp)
  800589:	89 74 24 04          	mov    %esi,0x4(%esp)
  80058d:	8b 00                	mov    (%eax),%eax
  80058f:	89 04 24             	mov    %eax,(%esp)
  800592:	ff d7                	call   *%edi
  800594:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800597:	e9 fd fe ff ff       	jmp    800499 <vprintfmt+0x2c>
  80059c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8d 50 04             	lea    0x4(%eax),%edx
  8005a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a8:	8b 00                	mov    (%eax),%eax
  8005aa:	89 c2                	mov    %eax,%edx
  8005ac:	c1 fa 1f             	sar    $0x1f,%edx
  8005af:	31 d0                	xor    %edx,%eax
  8005b1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005b3:	83 f8 0f             	cmp    $0xf,%eax
  8005b6:	7f 0b                	jg     8005c3 <vprintfmt+0x156>
  8005b8:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  8005bf:	85 d2                	test   %edx,%edx
  8005c1:	75 20                	jne    8005e3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8005c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c7:	c7 44 24 08 a7 28 80 	movl   $0x8028a7,0x8(%esp)
  8005ce:	00 
  8005cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d3:	89 3c 24             	mov    %edi,(%esp)
  8005d6:	e8 a5 03 00 00       	call   800980 <printfmt>
  8005db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005de:	e9 b6 fe ff ff       	jmp    800499 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8005e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e7:	c7 44 24 08 fb 2c 80 	movl   $0x802cfb,0x8(%esp)
  8005ee:	00 
  8005ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f3:	89 3c 24             	mov    %edi,(%esp)
  8005f6:	e8 85 03 00 00       	call   800980 <printfmt>
  8005fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005fe:	e9 96 fe ff ff       	jmp    800499 <vprintfmt+0x2c>
  800603:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800606:	89 c3                	mov    %eax,%ebx
  800608:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80060b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80060e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 04             	lea    0x4(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 00                	mov    (%eax),%eax
  80061c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80061f:	85 c0                	test   %eax,%eax
  800621:	b8 b0 28 80 00       	mov    $0x8028b0,%eax
  800626:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80062a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80062d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800631:	7e 06                	jle    800639 <vprintfmt+0x1cc>
  800633:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800637:	75 13                	jne    80064c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800639:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063c:	0f be 02             	movsbl (%edx),%eax
  80063f:	85 c0                	test   %eax,%eax
  800641:	0f 85 a2 00 00 00    	jne    8006e9 <vprintfmt+0x27c>
  800647:	e9 8f 00 00 00       	jmp    8006db <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80064c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800650:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800653:	89 0c 24             	mov    %ecx,(%esp)
  800656:	e8 70 03 00 00       	call   8009cb <strnlen>
  80065b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80065e:	29 c2                	sub    %eax,%edx
  800660:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800663:	85 d2                	test   %edx,%edx
  800665:	7e d2                	jle    800639 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800667:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80066b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80066e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800671:	89 d3                	mov    %edx,%ebx
  800673:	89 74 24 04          	mov    %esi,0x4(%esp)
  800677:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80067a:	89 04 24             	mov    %eax,(%esp)
  80067d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80067f:	83 eb 01             	sub    $0x1,%ebx
  800682:	85 db                	test   %ebx,%ebx
  800684:	7f ed                	jg     800673 <vprintfmt+0x206>
  800686:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800689:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800690:	eb a7                	jmp    800639 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800692:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800696:	74 1b                	je     8006b3 <vprintfmt+0x246>
  800698:	8d 50 e0             	lea    -0x20(%eax),%edx
  80069b:	83 fa 5e             	cmp    $0x5e,%edx
  80069e:	76 13                	jbe    8006b3 <vprintfmt+0x246>
					putch('?', putdat);
  8006a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006ae:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006b1:	eb 0d                	jmp    8006c0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ba:	89 04 24             	mov    %eax,(%esp)
  8006bd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c0:	83 ef 01             	sub    $0x1,%edi
  8006c3:	0f be 03             	movsbl (%ebx),%eax
  8006c6:	85 c0                	test   %eax,%eax
  8006c8:	74 05                	je     8006cf <vprintfmt+0x262>
  8006ca:	83 c3 01             	add    $0x1,%ebx
  8006cd:	eb 31                	jmp    800700 <vprintfmt+0x293>
  8006cf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006d8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006db:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006df:	7f 36                	jg     800717 <vprintfmt+0x2aa>
  8006e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006e4:	e9 b0 fd ff ff       	jmp    800499 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006ec:	83 c2 01             	add    $0x1,%edx
  8006ef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8006f2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8006f8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006fb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006fe:	89 d3                	mov    %edx,%ebx
  800700:	85 f6                	test   %esi,%esi
  800702:	78 8e                	js     800692 <vprintfmt+0x225>
  800704:	83 ee 01             	sub    $0x1,%esi
  800707:	79 89                	jns    800692 <vprintfmt+0x225>
  800709:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80070f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800712:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800715:	eb c4                	jmp    8006db <vprintfmt+0x26e>
  800717:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80071a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80071d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800721:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800728:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80072a:	83 eb 01             	sub    $0x1,%ebx
  80072d:	85 db                	test   %ebx,%ebx
  80072f:	7f ec                	jg     80071d <vprintfmt+0x2b0>
  800731:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800734:	e9 60 fd ff ff       	jmp    800499 <vprintfmt+0x2c>
  800739:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80073c:	83 f9 01             	cmp    $0x1,%ecx
  80073f:	7e 16                	jle    800757 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8d 50 08             	lea    0x8(%eax),%edx
  800747:	89 55 14             	mov    %edx,0x14(%ebp)
  80074a:	8b 10                	mov    (%eax),%edx
  80074c:	8b 48 04             	mov    0x4(%eax),%ecx
  80074f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800752:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800755:	eb 32                	jmp    800789 <vprintfmt+0x31c>
	else if (lflag)
  800757:	85 c9                	test   %ecx,%ecx
  800759:	74 18                	je     800773 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8d 50 04             	lea    0x4(%eax),%edx
  800761:	89 55 14             	mov    %edx,0x14(%ebp)
  800764:	8b 00                	mov    (%eax),%eax
  800766:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800769:	89 c1                	mov    %eax,%ecx
  80076b:	c1 f9 1f             	sar    $0x1f,%ecx
  80076e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800771:	eb 16                	jmp    800789 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800773:	8b 45 14             	mov    0x14(%ebp),%eax
  800776:	8d 50 04             	lea    0x4(%eax),%edx
  800779:	89 55 14             	mov    %edx,0x14(%ebp)
  80077c:	8b 00                	mov    (%eax),%eax
  80077e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800781:	89 c2                	mov    %eax,%edx
  800783:	c1 fa 1f             	sar    $0x1f,%edx
  800786:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800789:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80078c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80078f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800794:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800798:	0f 89 8a 00 00 00    	jns    800828 <vprintfmt+0x3bb>
				putch('-', putdat);
  80079e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007a9:	ff d7                	call   *%edi
				num = -(long long) num;
  8007ab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ae:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007b1:	f7 d8                	neg    %eax
  8007b3:	83 d2 00             	adc    $0x0,%edx
  8007b6:	f7 da                	neg    %edx
  8007b8:	eb 6e                	jmp    800828 <vprintfmt+0x3bb>
  8007ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007bd:	89 ca                	mov    %ecx,%edx
  8007bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c2:	e8 4f fc ff ff       	call   800416 <getuint>
  8007c7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8007cc:	eb 5a                	jmp    800828 <vprintfmt+0x3bb>
  8007ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007d1:	89 ca                	mov    %ecx,%edx
  8007d3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d6:	e8 3b fc ff ff       	call   800416 <getuint>
  8007db:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8007e0:	eb 46                	jmp    800828 <vprintfmt+0x3bb>
  8007e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8007e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007f0:	ff d7                	call   *%edi
			putch('x', putdat);
  8007f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007f6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007fd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 04             	lea    0x4(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	ba 00 00 00 00       	mov    $0x0,%edx
  80080f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800814:	eb 12                	jmp    800828 <vprintfmt+0x3bb>
  800816:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800819:	89 ca                	mov    %ecx,%edx
  80081b:	8d 45 14             	lea    0x14(%ebp),%eax
  80081e:	e8 f3 fb ff ff       	call   800416 <getuint>
  800823:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800828:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80082c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800830:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800833:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800837:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800842:	89 f2                	mov    %esi,%edx
  800844:	89 f8                	mov    %edi,%eax
  800846:	e8 d5 fa ff ff       	call   800320 <printnum>
  80084b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80084e:	e9 46 fc ff ff       	jmp    800499 <vprintfmt+0x2c>
  800853:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800856:	8b 45 14             	mov    0x14(%ebp),%eax
  800859:	8d 50 04             	lea    0x4(%eax),%edx
  80085c:	89 55 14             	mov    %edx,0x14(%ebp)
  80085f:	8b 00                	mov    (%eax),%eax
  800861:	85 c0                	test   %eax,%eax
  800863:	75 24                	jne    800889 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800865:	c7 44 24 0c cc 29 80 	movl   $0x8029cc,0xc(%esp)
  80086c:	00 
  80086d:	c7 44 24 08 fb 2c 80 	movl   $0x802cfb,0x8(%esp)
  800874:	00 
  800875:	89 74 24 04          	mov    %esi,0x4(%esp)
  800879:	89 3c 24             	mov    %edi,(%esp)
  80087c:	e8 ff 00 00 00       	call   800980 <printfmt>
  800881:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800884:	e9 10 fc ff ff       	jmp    800499 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800889:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80088c:	7e 29                	jle    8008b7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80088e:	0f b6 16             	movzbl (%esi),%edx
  800891:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800893:	c7 44 24 0c 04 2a 80 	movl   $0x802a04,0xc(%esp)
  80089a:	00 
  80089b:	c7 44 24 08 fb 2c 80 	movl   $0x802cfb,0x8(%esp)
  8008a2:	00 
  8008a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a7:	89 3c 24             	mov    %edi,(%esp)
  8008aa:	e8 d1 00 00 00       	call   800980 <printfmt>
  8008af:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8008b2:	e9 e2 fb ff ff       	jmp    800499 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8008b7:	0f b6 16             	movzbl (%esi),%edx
  8008ba:	88 10                	mov    %dl,(%eax)
  8008bc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8008bf:	e9 d5 fb ff ff       	jmp    800499 <vprintfmt+0x2c>
  8008c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ca:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ce:	89 14 24             	mov    %edx,(%esp)
  8008d1:	ff d7                	call   *%edi
  8008d3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8008d6:	e9 be fb ff ff       	jmp    800499 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008df:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008e6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8008eb:	80 38 25             	cmpb   $0x25,(%eax)
  8008ee:	0f 84 a5 fb ff ff    	je     800499 <vprintfmt+0x2c>
  8008f4:	89 c3                	mov    %eax,%ebx
  8008f6:	eb f0                	jmp    8008e8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8008f8:	83 c4 5c             	add    $0x5c,%esp
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5f                   	pop    %edi
  8008fe:	5d                   	pop    %ebp
  8008ff:	c3                   	ret    

00800900 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	83 ec 28             	sub    $0x28,%esp
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80090c:	85 c0                	test   %eax,%eax
  80090e:	74 04                	je     800914 <vsnprintf+0x14>
  800910:	85 d2                	test   %edx,%edx
  800912:	7f 07                	jg     80091b <vsnprintf+0x1b>
  800914:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800919:	eb 3b                	jmp    800956 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800922:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092c:	8b 45 14             	mov    0x14(%ebp),%eax
  80092f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800933:	8b 45 10             	mov    0x10(%ebp),%eax
  800936:	89 44 24 08          	mov    %eax,0x8(%esp)
  80093a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800941:	c7 04 24 50 04 80 00 	movl   $0x800450,(%esp)
  800948:	e8 20 fb ff ff       	call   80046d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800950:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800953:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800956:	c9                   	leave  
  800957:	c3                   	ret    

00800958 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80095e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800961:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800965:	8b 45 10             	mov    0x10(%ebp),%eax
  800968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800973:	8b 45 08             	mov    0x8(%ebp),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 82 ff ff ff       	call   800900 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800986:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800989:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80098d:	8b 45 10             	mov    0x10(%ebp),%eax
  800990:	89 44 24 08          	mov    %eax,0x8(%esp)
  800994:	8b 45 0c             	mov    0xc(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 c7 fa ff ff       	call   80046d <vprintfmt>
	va_end(ap);
}
  8009a6:	c9                   	leave  
  8009a7:	c3                   	ret    
	...

008009b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bb:	80 3a 00             	cmpb   $0x0,(%edx)
  8009be:	74 09                	je     8009c9 <strlen+0x19>
		n++;
  8009c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c7:	75 f7                	jne    8009c0 <strlen+0x10>
		n++;
	return n;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d5:	85 c9                	test   %ecx,%ecx
  8009d7:	74 19                	je     8009f2 <strnlen+0x27>
  8009d9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009dc:	74 14                	je     8009f2 <strnlen+0x27>
  8009de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8009e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e6:	39 c8                	cmp    %ecx,%eax
  8009e8:	74 0d                	je     8009f7 <strnlen+0x2c>
  8009ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8009ee:	75 f3                	jne    8009e3 <strnlen+0x18>
  8009f0:	eb 05                	jmp    8009f7 <strnlen+0x2c>
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a10:	83 c2 01             	add    $0x1,%edx
  800a13:	84 c9                	test   %cl,%cl
  800a15:	75 f2                	jne    800a09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	83 ec 08             	sub    $0x8,%esp
  800a21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a24:	89 1c 24             	mov    %ebx,(%esp)
  800a27:	e8 84 ff ff ff       	call   8009b0 <strlen>
	strcpy(dst + len, src);
  800a2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a36:	89 04 24             	mov    %eax,(%esp)
  800a39:	e8 bc ff ff ff       	call   8009fa <strcpy>
	return dst;
}
  800a3e:	89 d8                	mov    %ebx,%eax
  800a40:	83 c4 08             	add    $0x8,%esp
  800a43:	5b                   	pop    %ebx
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	56                   	push   %esi
  800a4a:	53                   	push   %ebx
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a54:	85 f6                	test   %esi,%esi
  800a56:	74 18                	je     800a70 <strncpy+0x2a>
  800a58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a5d:	0f b6 1a             	movzbl (%edx),%ebx
  800a60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a63:	80 3a 01             	cmpb   $0x1,(%edx)
  800a66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	39 ce                	cmp    %ecx,%esi
  800a6e:	77 ed                	ja     800a5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    

00800a74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a74:	55                   	push   %ebp
  800a75:	89 e5                	mov    %esp,%ebp
  800a77:	56                   	push   %esi
  800a78:	53                   	push   %ebx
  800a79:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a82:	89 f0                	mov    %esi,%eax
  800a84:	85 c9                	test   %ecx,%ecx
  800a86:	74 27                	je     800aaf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800a88:	83 e9 01             	sub    $0x1,%ecx
  800a8b:	74 1d                	je     800aaa <strlcpy+0x36>
  800a8d:	0f b6 1a             	movzbl (%edx),%ebx
  800a90:	84 db                	test   %bl,%bl
  800a92:	74 16                	je     800aaa <strlcpy+0x36>
			*dst++ = *src++;
  800a94:	88 18                	mov    %bl,(%eax)
  800a96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a99:	83 e9 01             	sub    $0x1,%ecx
  800a9c:	74 0e                	je     800aac <strlcpy+0x38>
			*dst++ = *src++;
  800a9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800aa1:	0f b6 1a             	movzbl (%edx),%ebx
  800aa4:	84 db                	test   %bl,%bl
  800aa6:	75 ec                	jne    800a94 <strlcpy+0x20>
  800aa8:	eb 02                	jmp    800aac <strlcpy+0x38>
  800aaa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aac:	c6 00 00             	movb   $0x0,(%eax)
  800aaf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800abe:	0f b6 01             	movzbl (%ecx),%eax
  800ac1:	84 c0                	test   %al,%al
  800ac3:	74 15                	je     800ada <strcmp+0x25>
  800ac5:	3a 02                	cmp    (%edx),%al
  800ac7:	75 11                	jne    800ada <strcmp+0x25>
		p++, q++;
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800acf:	0f b6 01             	movzbl (%ecx),%eax
  800ad2:	84 c0                	test   %al,%al
  800ad4:	74 04                	je     800ada <strcmp+0x25>
  800ad6:	3a 02                	cmp    (%edx),%al
  800ad8:	74 ef                	je     800ac9 <strcmp+0x14>
  800ada:	0f b6 c0             	movzbl %al,%eax
  800add:	0f b6 12             	movzbl (%edx),%edx
  800ae0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	8b 55 08             	mov    0x8(%ebp),%edx
  800aeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800af1:	85 c0                	test   %eax,%eax
  800af3:	74 23                	je     800b18 <strncmp+0x34>
  800af5:	0f b6 1a             	movzbl (%edx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	74 25                	je     800b21 <strncmp+0x3d>
  800afc:	3a 19                	cmp    (%ecx),%bl
  800afe:	75 21                	jne    800b21 <strncmp+0x3d>
  800b00:	83 e8 01             	sub    $0x1,%eax
  800b03:	74 13                	je     800b18 <strncmp+0x34>
		n--, p++, q++;
  800b05:	83 c2 01             	add    $0x1,%edx
  800b08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b0b:	0f b6 1a             	movzbl (%edx),%ebx
  800b0e:	84 db                	test   %bl,%bl
  800b10:	74 0f                	je     800b21 <strncmp+0x3d>
  800b12:	3a 19                	cmp    (%ecx),%bl
  800b14:	74 ea                	je     800b00 <strncmp+0x1c>
  800b16:	eb 09                	jmp    800b21 <strncmp+0x3d>
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b1d:	5b                   	pop    %ebx
  800b1e:	5d                   	pop    %ebp
  800b1f:	90                   	nop
  800b20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b21:	0f b6 02             	movzbl (%edx),%eax
  800b24:	0f b6 11             	movzbl (%ecx),%edx
  800b27:	29 d0                	sub    %edx,%eax
  800b29:	eb f2                	jmp    800b1d <strncmp+0x39>

00800b2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b35:	0f b6 10             	movzbl (%eax),%edx
  800b38:	84 d2                	test   %dl,%dl
  800b3a:	74 18                	je     800b54 <strchr+0x29>
		if (*s == c)
  800b3c:	38 ca                	cmp    %cl,%dl
  800b3e:	75 0a                	jne    800b4a <strchr+0x1f>
  800b40:	eb 17                	jmp    800b59 <strchr+0x2e>
  800b42:	38 ca                	cmp    %cl,%dl
  800b44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b48:	74 0f                	je     800b59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b4a:	83 c0 01             	add    $0x1,%eax
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	84 d2                	test   %dl,%dl
  800b52:	75 ee                	jne    800b42 <strchr+0x17>
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b65:	0f b6 10             	movzbl (%eax),%edx
  800b68:	84 d2                	test   %dl,%dl
  800b6a:	74 18                	je     800b84 <strfind+0x29>
		if (*s == c)
  800b6c:	38 ca                	cmp    %cl,%dl
  800b6e:	75 0a                	jne    800b7a <strfind+0x1f>
  800b70:	eb 12                	jmp    800b84 <strfind+0x29>
  800b72:	38 ca                	cmp    %cl,%dl
  800b74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b78:	74 0a                	je     800b84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b7a:	83 c0 01             	add    $0x1,%eax
  800b7d:	0f b6 10             	movzbl (%eax),%edx
  800b80:	84 d2                	test   %dl,%dl
  800b82:	75 ee                	jne    800b72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	89 1c 24             	mov    %ebx,(%esp)
  800b8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800b97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba0:	85 c9                	test   %ecx,%ecx
  800ba2:	74 30                	je     800bd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ba4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800baa:	75 25                	jne    800bd1 <memset+0x4b>
  800bac:	f6 c1 03             	test   $0x3,%cl
  800baf:	75 20                	jne    800bd1 <memset+0x4b>
		c &= 0xFF;
  800bb1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb4:	89 d3                	mov    %edx,%ebx
  800bb6:	c1 e3 08             	shl    $0x8,%ebx
  800bb9:	89 d6                	mov    %edx,%esi
  800bbb:	c1 e6 18             	shl    $0x18,%esi
  800bbe:	89 d0                	mov    %edx,%eax
  800bc0:	c1 e0 10             	shl    $0x10,%eax
  800bc3:	09 f0                	or     %esi,%eax
  800bc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800bc7:	09 d8                	or     %ebx,%eax
  800bc9:	c1 e9 02             	shr    $0x2,%ecx
  800bcc:	fc                   	cld    
  800bcd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bcf:	eb 03                	jmp    800bd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd1:	fc                   	cld    
  800bd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bd4:	89 f8                	mov    %edi,%eax
  800bd6:	8b 1c 24             	mov    (%esp),%ebx
  800bd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bdd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800be1:	89 ec                	mov    %ebp,%esp
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	83 ec 08             	sub    $0x8,%esp
  800beb:	89 34 24             	mov    %esi,(%esp)
  800bee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800bf8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800bfb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800bfd:	39 c6                	cmp    %eax,%esi
  800bff:	73 35                	jae    800c36 <memmove+0x51>
  800c01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 2e                	jae    800c36 <memmove+0x51>
		s += n;
		d += n;
  800c08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0a:	f6 c2 03             	test   $0x3,%dl
  800c0d:	75 1b                	jne    800c2a <memmove+0x45>
  800c0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c15:	75 13                	jne    800c2a <memmove+0x45>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0e                	jne    800c2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c1c:	83 ef 04             	sub    $0x4,%edi
  800c1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c22:	c1 e9 02             	shr    $0x2,%ecx
  800c25:	fd                   	std    
  800c26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c28:	eb 09                	jmp    800c33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c2a:	83 ef 01             	sub    $0x1,%edi
  800c2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c34:	eb 20                	jmp    800c56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c3c:	75 15                	jne    800c53 <memmove+0x6e>
  800c3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c44:	75 0d                	jne    800c53 <memmove+0x6e>
  800c46:	f6 c1 03             	test   $0x3,%cl
  800c49:	75 08                	jne    800c53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c4b:	c1 e9 02             	shr    $0x2,%ecx
  800c4e:	fc                   	cld    
  800c4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c51:	eb 03                	jmp    800c56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c53:	fc                   	cld    
  800c54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c56:	8b 34 24             	mov    (%esp),%esi
  800c59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c5d:	89 ec                	mov    %ebp,%esp
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c67:	8b 45 10             	mov    0x10(%ebp),%eax
  800c6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	89 04 24             	mov    %eax,(%esp)
  800c7b:	e8 65 ff ff ff       	call   800be5 <memmove>
}
  800c80:	c9                   	leave  
  800c81:	c3                   	ret    

00800c82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c91:	85 c9                	test   %ecx,%ecx
  800c93:	74 36                	je     800ccb <memcmp+0x49>
		if (*s1 != *s2)
  800c95:	0f b6 06             	movzbl (%esi),%eax
  800c98:	0f b6 1f             	movzbl (%edi),%ebx
  800c9b:	38 d8                	cmp    %bl,%al
  800c9d:	74 20                	je     800cbf <memcmp+0x3d>
  800c9f:	eb 14                	jmp    800cb5 <memcmp+0x33>
  800ca1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ca6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800cab:	83 c2 01             	add    $0x1,%edx
  800cae:	83 e9 01             	sub    $0x1,%ecx
  800cb1:	38 d8                	cmp    %bl,%al
  800cb3:	74 12                	je     800cc7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cb5:	0f b6 c0             	movzbl %al,%eax
  800cb8:	0f b6 db             	movzbl %bl,%ebx
  800cbb:	29 d8                	sub    %ebx,%eax
  800cbd:	eb 11                	jmp    800cd0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cbf:	83 e9 01             	sub    $0x1,%ecx
  800cc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc7:	85 c9                	test   %ecx,%ecx
  800cc9:	75 d6                	jne    800ca1 <memcmp+0x1f>
  800ccb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cdb:	89 c2                	mov    %eax,%edx
  800cdd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ce0:	39 d0                	cmp    %edx,%eax
  800ce2:	73 15                	jae    800cf9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ce4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ce8:	38 08                	cmp    %cl,(%eax)
  800cea:	75 06                	jne    800cf2 <memfind+0x1d>
  800cec:	eb 0b                	jmp    800cf9 <memfind+0x24>
  800cee:	38 08                	cmp    %cl,(%eax)
  800cf0:	74 07                	je     800cf9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cf2:	83 c0 01             	add    $0x1,%eax
  800cf5:	39 c2                	cmp    %eax,%edx
  800cf7:	77 f5                	ja     800cee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 04             	sub    $0x4,%esp
  800d04:	8b 55 08             	mov    0x8(%ebp),%edx
  800d07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d0a:	0f b6 02             	movzbl (%edx),%eax
  800d0d:	3c 20                	cmp    $0x20,%al
  800d0f:	74 04                	je     800d15 <strtol+0x1a>
  800d11:	3c 09                	cmp    $0x9,%al
  800d13:	75 0e                	jne    800d23 <strtol+0x28>
		s++;
  800d15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d18:	0f b6 02             	movzbl (%edx),%eax
  800d1b:	3c 20                	cmp    $0x20,%al
  800d1d:	74 f6                	je     800d15 <strtol+0x1a>
  800d1f:	3c 09                	cmp    $0x9,%al
  800d21:	74 f2                	je     800d15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d23:	3c 2b                	cmp    $0x2b,%al
  800d25:	75 0c                	jne    800d33 <strtol+0x38>
		s++;
  800d27:	83 c2 01             	add    $0x1,%edx
  800d2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d31:	eb 15                	jmp    800d48 <strtol+0x4d>
	else if (*s == '-')
  800d33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d3a:	3c 2d                	cmp    $0x2d,%al
  800d3c:	75 0a                	jne    800d48 <strtol+0x4d>
		s++, neg = 1;
  800d3e:	83 c2 01             	add    $0x1,%edx
  800d41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d48:	85 db                	test   %ebx,%ebx
  800d4a:	0f 94 c0             	sete   %al
  800d4d:	74 05                	je     800d54 <strtol+0x59>
  800d4f:	83 fb 10             	cmp    $0x10,%ebx
  800d52:	75 18                	jne    800d6c <strtol+0x71>
  800d54:	80 3a 30             	cmpb   $0x30,(%edx)
  800d57:	75 13                	jne    800d6c <strtol+0x71>
  800d59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d5d:	8d 76 00             	lea    0x0(%esi),%esi
  800d60:	75 0a                	jne    800d6c <strtol+0x71>
		s += 2, base = 16;
  800d62:	83 c2 02             	add    $0x2,%edx
  800d65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d6a:	eb 15                	jmp    800d81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d6c:	84 c0                	test   %al,%al
  800d6e:	66 90                	xchg   %ax,%ax
  800d70:	74 0f                	je     800d81 <strtol+0x86>
  800d72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d77:	80 3a 30             	cmpb   $0x30,(%edx)
  800d7a:	75 05                	jne    800d81 <strtol+0x86>
		s++, base = 8;
  800d7c:	83 c2 01             	add    $0x1,%edx
  800d7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d81:	b8 00 00 00 00       	mov    $0x0,%eax
  800d86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d88:	0f b6 0a             	movzbl (%edx),%ecx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800d90:	80 fb 09             	cmp    $0x9,%bl
  800d93:	77 08                	ja     800d9d <strtol+0xa2>
			dig = *s - '0';
  800d95:	0f be c9             	movsbl %cl,%ecx
  800d98:	83 e9 30             	sub    $0x30,%ecx
  800d9b:	eb 1e                	jmp    800dbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800d9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800da0:	80 fb 19             	cmp    $0x19,%bl
  800da3:	77 08                	ja     800dad <strtol+0xb2>
			dig = *s - 'a' + 10;
  800da5:	0f be c9             	movsbl %cl,%ecx
  800da8:	83 e9 57             	sub    $0x57,%ecx
  800dab:	eb 0e                	jmp    800dbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800dad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800db0:	80 fb 19             	cmp    $0x19,%bl
  800db3:	77 15                	ja     800dca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800db5:	0f be c9             	movsbl %cl,%ecx
  800db8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800dbb:	39 f1                	cmp    %esi,%ecx
  800dbd:	7d 0b                	jge    800dca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800dbf:	83 c2 01             	add    $0x1,%edx
  800dc2:	0f af c6             	imul   %esi,%eax
  800dc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800dc8:	eb be                	jmp    800d88 <strtol+0x8d>
  800dca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800dcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800dd0:	74 05                	je     800dd7 <strtol+0xdc>
		*endptr = (char *) s;
  800dd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800dd7:	89 ca                	mov    %ecx,%edx
  800dd9:	f7 da                	neg    %edx
  800ddb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ddf:	0f 45 c2             	cmovne %edx,%eax
}
  800de2:	83 c4 04             	add    $0x4,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
	...

00800dec <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 48             	sub    $0x48,%esp
  800df2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800df5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800df8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800dfb:	89 c6                	mov    %eax,%esi
  800dfd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e00:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e02:	8b 7d 10             	mov    0x10(%ebp),%edi
  800e05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0b:	51                   	push   %ecx
  800e0c:	52                   	push   %edx
  800e0d:	53                   	push   %ebx
  800e0e:	54                   	push   %esp
  800e0f:	55                   	push   %ebp
  800e10:	56                   	push   %esi
  800e11:	57                   	push   %edi
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	8d 35 1c 0e 80 00    	lea    0x800e1c,%esi
  800e1a:	0f 34                	sysenter 

00800e1c <.after_sysenter_label>:
  800e1c:	5f                   	pop    %edi
  800e1d:	5e                   	pop    %esi
  800e1e:	5d                   	pop    %ebp
  800e1f:	5c                   	pop    %esp
  800e20:	5b                   	pop    %ebx
  800e21:	5a                   	pop    %edx
  800e22:	59                   	pop    %ecx
  800e23:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e25:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e29:	74 28                	je     800e53 <.after_sysenter_label+0x37>
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7e 24                	jle    800e53 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e33:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e37:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800e46:	00 
  800e47:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  800e4e:	e8 91 11 00 00       	call   801fe4 <_panic>

	return ret;
}
  800e53:	89 d0                	mov    %edx,%eax
  800e55:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e58:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e5b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5e:	89 ec                	mov    %ebp,%esp
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800e68:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e6f:	00 
  800e70:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e77:	00 
  800e78:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e7f:	00 
  800e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e83:	89 04 24             	mov    %eax,(%esp)
  800e86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e89:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e93:	e8 54 ff ff ff       	call   800dec <syscall>
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800ea0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eaf:	00 
  800eb0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb7:	00 
  800eb8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ebf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ece:	e8 19 ff ff ff       	call   800dec <syscall>
}
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800edb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee2:	00 
  800ee3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eea:	00 
  800eeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef2:	00 
  800ef3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800efa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800efd:	ba 01 00 00 00       	mov    $0x1,%edx
  800f02:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f07:	e8 e0 fe ff ff       	call   800dec <syscall>
}
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    

00800f0e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f14:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f1b:	00 
  800f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f23:	8b 45 10             	mov    0x10(%ebp),%eax
  800f26:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	89 04 24             	mov    %eax,(%esp)
  800f30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f33:	ba 00 00 00 00       	mov    $0x0,%edx
  800f38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3d:	e8 aa fe ff ff       	call   800dec <syscall>
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f61:	00 
  800f62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f65:	89 04 24             	mov    %eax,(%esp)
  800f68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f70:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f75:	e8 72 fe ff ff       	call   800dec <syscall>
}
  800f7a:	c9                   	leave  
  800f7b:	c3                   	ret    

00800f7c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800f82:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f89:	00 
  800f8a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f91:	00 
  800f92:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f99:	00 
  800f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9d:	89 04 24             	mov    %eax,(%esp)
  800fa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fa8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fad:	e8 3a fe ff ff       	call   800dec <syscall>
}
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    

00800fb4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800fba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc1:	00 
  800fc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc9:	00 
  800fca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd1:	00 
  800fd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd5:	89 04 24             	mov    %eax,(%esp)
  800fd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fdb:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe0:	b8 09 00 00 00       	mov    $0x9,%eax
  800fe5:	e8 02 fe ff ff       	call   800dec <syscall>
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ff2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff9:	00 
  800ffa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801001:	00 
  801002:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801009:	00 
  80100a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100d:	89 04 24             	mov    %eax,(%esp)
  801010:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801013:	ba 01 00 00 00       	mov    $0x1,%edx
  801018:	b8 07 00 00 00       	mov    $0x7,%eax
  80101d:	e8 ca fd ff ff       	call   800dec <syscall>
}
  801022:	c9                   	leave  
  801023:	c3                   	ret    

00801024 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  80102a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801031:	00 
  801032:	8b 45 18             	mov    0x18(%ebp),%eax
  801035:	0b 45 14             	or     0x14(%ebp),%eax
  801038:	89 44 24 08          	mov    %eax,0x8(%esp)
  80103c:	8b 45 10             	mov    0x10(%ebp),%eax
  80103f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801043:	8b 45 0c             	mov    0xc(%ebp),%eax
  801046:	89 04 24             	mov    %eax,(%esp)
  801049:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104c:	ba 01 00 00 00       	mov    $0x1,%edx
  801051:	b8 06 00 00 00       	mov    $0x6,%eax
  801056:	e8 91 fd ff ff       	call   800dec <syscall>
}
  80105b:	c9                   	leave  
  80105c:	c3                   	ret    

0080105d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801063:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80106a:	00 
  80106b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801072:	00 
  801073:	8b 45 10             	mov    0x10(%ebp),%eax
  801076:	89 44 24 04          	mov    %eax,0x4(%esp)
  80107a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80107d:	89 04 24             	mov    %eax,(%esp)
  801080:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801083:	ba 01 00 00 00       	mov    $0x1,%edx
  801088:	b8 05 00 00 00       	mov    $0x5,%eax
  80108d:	e8 5a fd ff ff       	call   800dec <syscall>
}
  801092:	c9                   	leave  
  801093:	c3                   	ret    

00801094 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80109a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a1:	00 
  8010a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010a9:	00 
  8010aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b1:	00 
  8010b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010be:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010c8:	e8 1f fd ff ff       	call   800dec <syscall>
}
  8010cd:	c9                   	leave  
  8010ce:	c3                   	ret    

008010cf <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8010d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010e4:	00 
  8010e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010ec:	00 
  8010ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010f0:	89 04 24             	mov    %eax,(%esp)
  8010f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801100:	e8 e7 fc ff ff       	call   800dec <syscall>
}
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80110d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801114:	00 
  801115:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80111c:	00 
  80111d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801124:	00 
  801125:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801131:	ba 00 00 00 00       	mov    $0x0,%edx
  801136:	b8 02 00 00 00       	mov    $0x2,%eax
  80113b:	e8 ac fc ff ff       	call   800dec <syscall>
}
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801148:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80114f:	00 
  801150:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801157:	00 
  801158:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80115f:	00 
  801160:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116a:	ba 01 00 00 00       	mov    $0x1,%edx
  80116f:	b8 03 00 00 00       	mov    $0x3,%eax
  801174:	e8 73 fc ff ff       	call   800dec <syscall>
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801181:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801188:	00 
  801189:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8011af:	e8 38 fc ff ff       	call   800dec <syscall>
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8011bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011c3:	00 
  8011c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011cb:	00 
  8011cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011d3:	00 
  8011d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d7:	89 04 24             	mov    %eax,(%esp)
  8011da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e7:	e8 00 fc ff ff       	call   800dec <syscall>
}
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    
	...

008011f0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801206:	8b 45 08             	mov    0x8(%ebp),%eax
  801209:	89 04 24             	mov    %eax,(%esp)
  80120c:	e8 df ff ff ff       	call   8011f0 <fd2num>
  801211:	05 20 00 0d 00       	add    $0xd0020,%eax
  801216:	c1 e0 0c             	shl    $0xc,%eax
}
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801224:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801229:	a8 01                	test   $0x1,%al
  80122b:	74 36                	je     801263 <fd_alloc+0x48>
  80122d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801232:	a8 01                	test   $0x1,%al
  801234:	74 2d                	je     801263 <fd_alloc+0x48>
  801236:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80123b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801240:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801245:	89 c3                	mov    %eax,%ebx
  801247:	89 c2                	mov    %eax,%edx
  801249:	c1 ea 16             	shr    $0x16,%edx
  80124c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80124f:	f6 c2 01             	test   $0x1,%dl
  801252:	74 14                	je     801268 <fd_alloc+0x4d>
  801254:	89 c2                	mov    %eax,%edx
  801256:	c1 ea 0c             	shr    $0xc,%edx
  801259:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80125c:	f6 c2 01             	test   $0x1,%dl
  80125f:	75 10                	jne    801271 <fd_alloc+0x56>
  801261:	eb 05                	jmp    801268 <fd_alloc+0x4d>
  801263:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801268:	89 1f                	mov    %ebx,(%edi)
  80126a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80126f:	eb 17                	jmp    801288 <fd_alloc+0x6d>
  801271:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801276:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80127b:	75 c8                	jne    801245 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80127d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801283:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801290:	8b 45 08             	mov    0x8(%ebp),%eax
  801293:	83 f8 1f             	cmp    $0x1f,%eax
  801296:	77 36                	ja     8012ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801298:	05 00 00 0d 00       	add    $0xd0000,%eax
  80129d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8012a0:	89 c2                	mov    %eax,%edx
  8012a2:	c1 ea 16             	shr    $0x16,%edx
  8012a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ac:	f6 c2 01             	test   $0x1,%dl
  8012af:	74 1d                	je     8012ce <fd_lookup+0x41>
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	c1 ea 0c             	shr    $0xc,%edx
  8012b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bd:	f6 c2 01             	test   $0x1,%dl
  8012c0:	74 0c                	je     8012ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c5:	89 02                	mov    %eax,(%edx)
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8012cc:	eb 05                	jmp    8012d3 <fd_lookup+0x46>
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e5:	89 04 24             	mov    %eax,(%esp)
  8012e8:	e8 a0 ff ff ff       	call   80128d <fd_lookup>
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 0e                	js     8012ff <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f7:	89 50 04             	mov    %edx,0x4(%eax)
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8012ff:	c9                   	leave  
  801300:	c3                   	ret    

00801301 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	56                   	push   %esi
  801305:	53                   	push   %ebx
  801306:	83 ec 10             	sub    $0x10,%esp
  801309:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80130f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801314:	b8 08 30 80 00       	mov    $0x803008,%eax
  801319:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  80131f:	75 11                	jne    801332 <dev_lookup+0x31>
  801321:	eb 04                	jmp    801327 <dev_lookup+0x26>
  801323:	39 08                	cmp    %ecx,(%eax)
  801325:	75 10                	jne    801337 <dev_lookup+0x36>
			*dev = devtab[i];
  801327:	89 03                	mov    %eax,(%ebx)
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80132e:	66 90                	xchg   %ax,%ax
  801330:	eb 36                	jmp    801368 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801332:	be c8 2c 80 00       	mov    $0x802cc8,%esi
  801337:	83 c2 01             	add    $0x1,%edx
  80133a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80133d:	85 c0                	test   %eax,%eax
  80133f:	75 e2                	jne    801323 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801341:	a1 18 40 80 00       	mov    0x804018,%eax
  801346:	8b 40 48             	mov    0x48(%eax),%eax
  801349:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80134d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801351:	c7 04 24 4c 2c 80 00 	movl   $0x802c4c,(%esp)
  801358:	e8 5c ef ff ff       	call   8002b9 <cprintf>
	*dev = 0;
  80135d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801363:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801368:	83 c4 10             	add    $0x10,%esp
  80136b:	5b                   	pop    %ebx
  80136c:	5e                   	pop    %esi
  80136d:	5d                   	pop    %ebp
  80136e:	c3                   	ret    

0080136f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	53                   	push   %ebx
  801373:	83 ec 24             	sub    $0x24,%esp
  801376:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801379:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801380:	8b 45 08             	mov    0x8(%ebp),%eax
  801383:	89 04 24             	mov    %eax,(%esp)
  801386:	e8 02 ff ff ff       	call   80128d <fd_lookup>
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 53                	js     8013e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801392:	89 44 24 04          	mov    %eax,0x4(%esp)
  801396:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801399:	8b 00                	mov    (%eax),%eax
  80139b:	89 04 24             	mov    %eax,(%esp)
  80139e:	e8 5e ff ff ff       	call   801301 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 3b                	js     8013e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013af:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013b3:	74 2d                	je     8013e2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013bf:	00 00 00 
	stat->st_isdir = 0;
  8013c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013c9:	00 00 00 
	stat->st_dev = dev;
  8013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013dc:	89 14 24             	mov    %edx,(%esp)
  8013df:	ff 50 14             	call   *0x14(%eax)
}
  8013e2:	83 c4 24             	add    $0x24,%esp
  8013e5:	5b                   	pop    %ebx
  8013e6:	5d                   	pop    %ebp
  8013e7:	c3                   	ret    

008013e8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	53                   	push   %ebx
  8013ec:	83 ec 24             	sub    $0x24,%esp
  8013ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f9:	89 1c 24             	mov    %ebx,(%esp)
  8013fc:	e8 8c fe ff ff       	call   80128d <fd_lookup>
  801401:	85 c0                	test   %eax,%eax
  801403:	78 5f                	js     801464 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801405:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801408:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140f:	8b 00                	mov    (%eax),%eax
  801411:	89 04 24             	mov    %eax,(%esp)
  801414:	e8 e8 fe ff ff       	call   801301 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 47                	js     801464 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80141d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801420:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801424:	75 23                	jne    801449 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801426:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80142b:	8b 40 48             	mov    0x48(%eax),%eax
  80142e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801432:	89 44 24 04          	mov    %eax,0x4(%esp)
  801436:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
  80143d:	e8 77 ee ff ff       	call   8002b9 <cprintf>
  801442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801447:	eb 1b                	jmp    801464 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801449:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144c:	8b 48 18             	mov    0x18(%eax),%ecx
  80144f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801454:	85 c9                	test   %ecx,%ecx
  801456:	74 0c                	je     801464 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801458:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145f:	89 14 24             	mov    %edx,(%esp)
  801462:	ff d1                	call   *%ecx
}
  801464:	83 c4 24             	add    $0x24,%esp
  801467:	5b                   	pop    %ebx
  801468:	5d                   	pop    %ebp
  801469:	c3                   	ret    

0080146a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80146a:	55                   	push   %ebp
  80146b:	89 e5                	mov    %esp,%ebp
  80146d:	53                   	push   %ebx
  80146e:	83 ec 24             	sub    $0x24,%esp
  801471:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801474:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801477:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147b:	89 1c 24             	mov    %ebx,(%esp)
  80147e:	e8 0a fe ff ff       	call   80128d <fd_lookup>
  801483:	85 c0                	test   %eax,%eax
  801485:	78 66                	js     8014ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801487:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801491:	8b 00                	mov    (%eax),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 66 fe ff ff       	call   801301 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 4e                	js     8014ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80149f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014a2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014a6:	75 23                	jne    8014cb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014a8:	a1 18 40 80 00       	mov    0x804018,%eax
  8014ad:	8b 40 48             	mov    0x48(%eax),%eax
  8014b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b8:	c7 04 24 8d 2c 80 00 	movl   $0x802c8d,(%esp)
  8014bf:	e8 f5 ed ff ff       	call   8002b9 <cprintf>
  8014c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014c9:	eb 22                	jmp    8014ed <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ce:	8b 48 0c             	mov    0xc(%eax),%ecx
  8014d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014d6:	85 c9                	test   %ecx,%ecx
  8014d8:	74 13                	je     8014ed <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014da:	8b 45 10             	mov    0x10(%ebp),%eax
  8014dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	89 14 24             	mov    %edx,(%esp)
  8014eb:	ff d1                	call   *%ecx
}
  8014ed:	83 c4 24             	add    $0x24,%esp
  8014f0:	5b                   	pop    %ebx
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    

008014f3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f3:	55                   	push   %ebp
  8014f4:	89 e5                	mov    %esp,%ebp
  8014f6:	53                   	push   %ebx
  8014f7:	83 ec 24             	sub    $0x24,%esp
  8014fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801500:	89 44 24 04          	mov    %eax,0x4(%esp)
  801504:	89 1c 24             	mov    %ebx,(%esp)
  801507:	e8 81 fd ff ff       	call   80128d <fd_lookup>
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 6b                	js     80157b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801510:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801513:	89 44 24 04          	mov    %eax,0x4(%esp)
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	8b 00                	mov    (%eax),%eax
  80151c:	89 04 24             	mov    %eax,(%esp)
  80151f:	e8 dd fd ff ff       	call   801301 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801524:	85 c0                	test   %eax,%eax
  801526:	78 53                	js     80157b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801528:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80152b:	8b 42 08             	mov    0x8(%edx),%eax
  80152e:	83 e0 03             	and    $0x3,%eax
  801531:	83 f8 01             	cmp    $0x1,%eax
  801534:	75 23                	jne    801559 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801536:	a1 18 40 80 00       	mov    0x804018,%eax
  80153b:	8b 40 48             	mov    0x48(%eax),%eax
  80153e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801542:	89 44 24 04          	mov    %eax,0x4(%esp)
  801546:	c7 04 24 aa 2c 80 00 	movl   $0x802caa,(%esp)
  80154d:	e8 67 ed ff ff       	call   8002b9 <cprintf>
  801552:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801557:	eb 22                	jmp    80157b <read+0x88>
	}
	if (!dev->dev_read)
  801559:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80155c:	8b 48 08             	mov    0x8(%eax),%ecx
  80155f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801564:	85 c9                	test   %ecx,%ecx
  801566:	74 13                	je     80157b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801568:	8b 45 10             	mov    0x10(%ebp),%eax
  80156b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80156f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	89 14 24             	mov    %edx,(%esp)
  801579:	ff d1                	call   *%ecx
}
  80157b:	83 c4 24             	add    $0x24,%esp
  80157e:	5b                   	pop    %ebx
  80157f:	5d                   	pop    %ebp
  801580:	c3                   	ret    

00801581 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801581:	55                   	push   %ebp
  801582:	89 e5                	mov    %esp,%ebp
  801584:	57                   	push   %edi
  801585:	56                   	push   %esi
  801586:	53                   	push   %ebx
  801587:	83 ec 1c             	sub    $0x1c,%esp
  80158a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801590:	ba 00 00 00 00       	mov    $0x0,%edx
  801595:	bb 00 00 00 00       	mov    $0x0,%ebx
  80159a:	b8 00 00 00 00       	mov    $0x0,%eax
  80159f:	85 f6                	test   %esi,%esi
  8015a1:	74 29                	je     8015cc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015a3:	89 f0                	mov    %esi,%eax
  8015a5:	29 d0                	sub    %edx,%eax
  8015a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015ab:	03 55 0c             	add    0xc(%ebp),%edx
  8015ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015b2:	89 3c 24             	mov    %edi,(%esp)
  8015b5:	e8 39 ff ff ff       	call   8014f3 <read>
		if (m < 0)
  8015ba:	85 c0                	test   %eax,%eax
  8015bc:	78 0e                	js     8015cc <readn+0x4b>
			return m;
		if (m == 0)
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	74 08                	je     8015ca <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c2:	01 c3                	add    %eax,%ebx
  8015c4:	89 da                	mov    %ebx,%edx
  8015c6:	39 f3                	cmp    %esi,%ebx
  8015c8:	72 d9                	jb     8015a3 <readn+0x22>
  8015ca:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015cc:	83 c4 1c             	add    $0x1c,%esp
  8015cf:	5b                   	pop    %ebx
  8015d0:	5e                   	pop    %esi
  8015d1:	5f                   	pop    %edi
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 28             	sub    $0x28,%esp
  8015da:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015dd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8015e0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e3:	89 34 24             	mov    %esi,(%esp)
  8015e6:	e8 05 fc ff ff       	call   8011f0 <fd2num>
  8015eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8015ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015f2:	89 04 24             	mov    %eax,(%esp)
  8015f5:	e8 93 fc ff ff       	call   80128d <fd_lookup>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 05                	js     801605 <fd_close+0x31>
  801600:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801603:	74 0e                	je     801613 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801605:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801609:	b8 00 00 00 00       	mov    $0x0,%eax
  80160e:	0f 44 d8             	cmove  %eax,%ebx
  801611:	eb 3d                	jmp    801650 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801613:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801616:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161a:	8b 06                	mov    (%esi),%eax
  80161c:	89 04 24             	mov    %eax,(%esp)
  80161f:	e8 dd fc ff ff       	call   801301 <dev_lookup>
  801624:	89 c3                	mov    %eax,%ebx
  801626:	85 c0                	test   %eax,%eax
  801628:	78 16                	js     801640 <fd_close+0x6c>
		if (dev->dev_close)
  80162a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162d:	8b 40 10             	mov    0x10(%eax),%eax
  801630:	bb 00 00 00 00       	mov    $0x0,%ebx
  801635:	85 c0                	test   %eax,%eax
  801637:	74 07                	je     801640 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801639:	89 34 24             	mov    %esi,(%esp)
  80163c:	ff d0                	call   *%eax
  80163e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801640:	89 74 24 04          	mov    %esi,0x4(%esp)
  801644:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80164b:	e8 9c f9 ff ff       	call   800fec <sys_page_unmap>
	return r;
}
  801650:	89 d8                	mov    %ebx,%eax
  801652:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801655:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801658:	89 ec                	mov    %ebp,%esp
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801662:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801665:	89 44 24 04          	mov    %eax,0x4(%esp)
  801669:	8b 45 08             	mov    0x8(%ebp),%eax
  80166c:	89 04 24             	mov    %eax,(%esp)
  80166f:	e8 19 fc ff ff       	call   80128d <fd_lookup>
  801674:	85 c0                	test   %eax,%eax
  801676:	78 13                	js     80168b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801678:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80167f:	00 
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	89 04 24             	mov    %eax,(%esp)
  801686:	e8 49 ff ff ff       	call   8015d4 <fd_close>
}
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 18             	sub    $0x18,%esp
  801693:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801696:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801699:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016a0:	00 
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	89 04 24             	mov    %eax,(%esp)
  8016a7:	e8 78 03 00 00       	call   801a24 <open>
  8016ac:	89 c3                	mov    %eax,%ebx
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 1b                	js     8016cd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b9:	89 1c 24             	mov    %ebx,(%esp)
  8016bc:	e8 ae fc ff ff       	call   80136f <fstat>
  8016c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016c3:	89 1c 24             	mov    %ebx,(%esp)
  8016c6:	e8 91 ff ff ff       	call   80165c <close>
  8016cb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8016cd:	89 d8                	mov    %ebx,%eax
  8016cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016d2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016d5:	89 ec                	mov    %ebp,%esp
  8016d7:	5d                   	pop    %ebp
  8016d8:	c3                   	ret    

008016d9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	53                   	push   %ebx
  8016dd:	83 ec 14             	sub    $0x14,%esp
  8016e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8016e5:	89 1c 24             	mov    %ebx,(%esp)
  8016e8:	e8 6f ff ff ff       	call   80165c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8016ed:	83 c3 01             	add    $0x1,%ebx
  8016f0:	83 fb 20             	cmp    $0x20,%ebx
  8016f3:	75 f0                	jne    8016e5 <close_all+0xc>
		close(i);
}
  8016f5:	83 c4 14             	add    $0x14,%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 58             	sub    $0x58,%esp
  801701:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801704:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801707:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80170a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80170d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801710:	89 44 24 04          	mov    %eax,0x4(%esp)
  801714:	8b 45 08             	mov    0x8(%ebp),%eax
  801717:	89 04 24             	mov    %eax,(%esp)
  80171a:	e8 6e fb ff ff       	call   80128d <fd_lookup>
  80171f:	89 c3                	mov    %eax,%ebx
  801721:	85 c0                	test   %eax,%eax
  801723:	0f 88 e0 00 00 00    	js     801809 <dup+0x10e>
		return r;
	close(newfdnum);
  801729:	89 3c 24             	mov    %edi,(%esp)
  80172c:	e8 2b ff ff ff       	call   80165c <close>

	newfd = INDEX2FD(newfdnum);
  801731:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801737:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80173a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173d:	89 04 24             	mov    %eax,(%esp)
  801740:	e8 bb fa ff ff       	call   801200 <fd2data>
  801745:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801747:	89 34 24             	mov    %esi,(%esp)
  80174a:	e8 b1 fa ff ff       	call   801200 <fd2data>
  80174f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801752:	89 da                	mov    %ebx,%edx
  801754:	89 d8                	mov    %ebx,%eax
  801756:	c1 e8 16             	shr    $0x16,%eax
  801759:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801760:	a8 01                	test   $0x1,%al
  801762:	74 43                	je     8017a7 <dup+0xac>
  801764:	c1 ea 0c             	shr    $0xc,%edx
  801767:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80176e:	a8 01                	test   $0x1,%al
  801770:	74 35                	je     8017a7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801772:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801779:	25 07 0e 00 00       	and    $0xe07,%eax
  80177e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801782:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801785:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801789:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801790:	00 
  801791:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801795:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80179c:	e8 83 f8 ff ff       	call   801024 <sys_page_map>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 3f                	js     8017e6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017aa:	89 c2                	mov    %eax,%edx
  8017ac:	c1 ea 0c             	shr    $0xc,%edx
  8017af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017b6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017cb:	00 
  8017cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017d7:	e8 48 f8 ff ff       	call   801024 <sys_page_map>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	85 c0                	test   %eax,%eax
  8017e0:	78 04                	js     8017e6 <dup+0xeb>
  8017e2:	89 fb                	mov    %edi,%ebx
  8017e4:	eb 23                	jmp    801809 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8017e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f1:	e8 f6 f7 ff ff       	call   800fec <sys_page_unmap>
	sys_page_unmap(0, nva);
  8017f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801804:	e8 e3 f7 ff ff       	call   800fec <sys_page_unmap>
	return r;
}
  801809:	89 d8                	mov    %ebx,%eax
  80180b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80180e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801811:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801814:	89 ec                	mov    %ebp,%esp
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 18             	sub    $0x18,%esp
  80181e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801821:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801824:	89 c3                	mov    %eax,%ebx
  801826:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801828:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80182f:	75 11                	jne    801842 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801831:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801838:	e8 03 08 00 00       	call   802040 <ipc_find_env>
  80183d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801842:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801849:	00 
  80184a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801851:	00 
  801852:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801856:	a1 00 40 80 00       	mov    0x804000,%eax
  80185b:	89 04 24             	mov    %eax,(%esp)
  80185e:	e8 26 08 00 00       	call   802089 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801863:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80186a:	00 
  80186b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80186f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801876:	e8 79 08 00 00       	call   8020f4 <ipc_recv>
}
  80187b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80187e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801881:	89 ec                	mov    %ebp,%esp
  801883:	5d                   	pop    %ebp
  801884:	c3                   	ret    

00801885 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	8b 40 0c             	mov    0xc(%eax),%eax
  801891:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801896:	8b 45 0c             	mov    0xc(%ebp),%eax
  801899:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80189e:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018a8:	e8 6b ff ff ff       	call   801818 <fsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ca:	e8 49 ff ff ff       	call   801818 <fsipc>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8018d1:	55                   	push   %ebp
  8018d2:	89 e5                	mov    %esp,%ebp
  8018d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8018e1:	e8 32 ff ff ff       	call   801818 <fsipc>
}
  8018e6:	c9                   	leave  
  8018e7:	c3                   	ret    

008018e8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	53                   	push   %ebx
  8018ec:	83 ec 14             	sub    $0x14,%esp
  8018ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 05 00 00 00       	mov    $0x5,%eax
  801907:	e8 0c ff ff ff       	call   801818 <fsipc>
  80190c:	85 c0                	test   %eax,%eax
  80190e:	78 2b                	js     80193b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801910:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801917:	00 
  801918:	89 1c 24             	mov    %ebx,(%esp)
  80191b:	e8 da f0 ff ff       	call   8009fa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801920:	a1 80 50 80 00       	mov    0x805080,%eax
  801925:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80192b:	a1 84 50 80 00       	mov    0x805084,%eax
  801930:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80193b:	83 c4 14             	add    $0x14,%esp
  80193e:	5b                   	pop    %ebx
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	83 ec 18             	sub    $0x18,%esp
  801947:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80194a:	8b 55 08             	mov    0x8(%ebp),%edx
  80194d:	8b 52 0c             	mov    0xc(%edx),%edx
  801950:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801956:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80195b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801960:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801965:	0f 47 c2             	cmova  %edx,%eax
  801968:	89 44 24 08          	mov    %eax,0x8(%esp)
  80196c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80196f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801973:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80197a:	e8 66 f2 ff ff       	call   800be5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80197f:	ba 00 00 00 00       	mov    $0x0,%edx
  801984:	b8 04 00 00 00       	mov    $0x4,%eax
  801989:	e8 8a fe ff ff       	call   801818 <fsipc>
}
  80198e:	c9                   	leave  
  80198f:	c3                   	ret    

00801990 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	53                   	push   %ebx
  801994:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801997:	8b 45 08             	mov    0x8(%ebp),%eax
  80199a:	8b 40 0c             	mov    0xc(%eax),%eax
  80199d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8019a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8019af:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b4:	e8 5f fe ff ff       	call   801818 <fsipc>
  8019b9:	89 c3                	mov    %eax,%ebx
  8019bb:	85 c0                	test   %eax,%eax
  8019bd:	78 17                	js     8019d6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019ca:	00 
  8019cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ce:	89 04 24             	mov    %eax,(%esp)
  8019d1:	e8 0f f2 ff ff       	call   800be5 <memmove>
  return r;	
}
  8019d6:	89 d8                	mov    %ebx,%eax
  8019d8:	83 c4 14             	add    $0x14,%esp
  8019db:	5b                   	pop    %ebx
  8019dc:	5d                   	pop    %ebp
  8019dd:	c3                   	ret    

008019de <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8019de:	55                   	push   %ebp
  8019df:	89 e5                	mov    %esp,%ebp
  8019e1:	53                   	push   %ebx
  8019e2:	83 ec 14             	sub    $0x14,%esp
  8019e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8019e8:	89 1c 24             	mov    %ebx,(%esp)
  8019eb:	e8 c0 ef ff ff       	call   8009b0 <strlen>
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8019f7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8019fd:	7f 1f                	jg     801a1e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8019ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a03:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a0a:	e8 eb ef ff ff       	call   8009fa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a0f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a14:	b8 07 00 00 00       	mov    $0x7,%eax
  801a19:	e8 fa fd ff ff       	call   801818 <fsipc>
}
  801a1e:	83 c4 14             	add    $0x14,%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5d                   	pop    %ebp
  801a23:	c3                   	ret    

00801a24 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 28             	sub    $0x28,%esp
  801a2a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a2d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a30:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801a33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a36:	89 04 24             	mov    %eax,(%esp)
  801a39:	e8 dd f7 ff ff       	call   80121b <fd_alloc>
  801a3e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a40:	85 c0                	test   %eax,%eax
  801a42:	0f 88 89 00 00 00    	js     801ad1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a48:	89 34 24             	mov    %esi,(%esp)
  801a4b:	e8 60 ef ff ff       	call   8009b0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a50:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a55:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a5a:	7f 75                	jg     801ad1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a60:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a67:	e8 8e ef ff ff       	call   8009fa <strcpy>
  fsipcbuf.open.req_omode = mode;
  801a6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801a74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a77:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7c:	e8 97 fd ff ff       	call   801818 <fsipc>
  801a81:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801a83:	85 c0                	test   %eax,%eax
  801a85:	78 0f                	js     801a96 <open+0x72>
  return fd2num(fd);
  801a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8a:	89 04 24             	mov    %eax,(%esp)
  801a8d:	e8 5e f7 ff ff       	call   8011f0 <fd2num>
  801a92:	89 c3                	mov    %eax,%ebx
  801a94:	eb 3b                	jmp    801ad1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801a96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a9d:	00 
  801a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa1:	89 04 24             	mov    %eax,(%esp)
  801aa4:	e8 2b fb ff ff       	call   8015d4 <fd_close>
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	74 24                	je     801ad1 <open+0xad>
  801aad:	c7 44 24 0c d4 2c 80 	movl   $0x802cd4,0xc(%esp)
  801ab4:	00 
  801ab5:	c7 44 24 08 e9 2c 80 	movl   $0x802ce9,0x8(%esp)
  801abc:	00 
  801abd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801ac4:	00 
  801ac5:	c7 04 24 fe 2c 80 00 	movl   $0x802cfe,(%esp)
  801acc:	e8 13 05 00 00       	call   801fe4 <_panic>
  return r;
}
  801ad1:	89 d8                	mov    %ebx,%eax
  801ad3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ad6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ad9:	89 ec                	mov    %ebp,%esp
  801adb:	5d                   	pop    %ebp
  801adc:	c3                   	ret    
  801add:	00 00                	add    %al,(%eax)
	...

00801ae0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ae6:	c7 44 24 04 09 2d 80 	movl   $0x802d09,0x4(%esp)
  801aed:	00 
  801aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 01 ef ff ff       	call   8009fa <strcpy>
	return 0;
}
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
  801afe:	c9                   	leave  
  801aff:	c3                   	ret    

00801b00 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	53                   	push   %ebx
  801b04:	83 ec 14             	sub    $0x14,%esp
  801b07:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b0a:	89 1c 24             	mov    %ebx,(%esp)
  801b0d:	e8 72 06 00 00       	call   802184 <pageref>
  801b12:	89 c2                	mov    %eax,%edx
  801b14:	b8 00 00 00 00       	mov    $0x0,%eax
  801b19:	83 fa 01             	cmp    $0x1,%edx
  801b1c:	75 0b                	jne    801b29 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801b1e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 b9 02 00 00       	call   801de2 <nsipc_close>
	else
		return 0;
}
  801b29:	83 c4 14             	add    $0x14,%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5d                   	pop    %ebp
  801b2e:	c3                   	ret    

00801b2f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b35:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b3c:	00 
  801b3d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b40:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b44:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 c5 02 00 00       	call   801e1e <nsipc_send>
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b61:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b68:	00 
  801b69:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b77:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b7d:	89 04 24             	mov    %eax,(%esp)
  801b80:	e8 0c 03 00 00       	call   801e91 <nsipc_recv>
}
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	56                   	push   %esi
  801b8b:	53                   	push   %ebx
  801b8c:	83 ec 20             	sub    $0x20,%esp
  801b8f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b94:	89 04 24             	mov    %eax,(%esp)
  801b97:	e8 7f f6 ff ff       	call   80121b <fd_alloc>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	78 21                	js     801bc3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ba2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ba9:	00 
  801baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bad:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bb8:	e8 a0 f4 ff ff       	call   80105d <sys_page_alloc>
  801bbd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	79 0a                	jns    801bcd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801bc3:	89 34 24             	mov    %esi,(%esp)
  801bc6:	e8 17 02 00 00       	call   801de2 <nsipc_close>
		return r;
  801bcb:	eb 28                	jmp    801bf5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bcd:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801bd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801be2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801beb:	89 04 24             	mov    %eax,(%esp)
  801bee:	e8 fd f5 ff ff       	call   8011f0 <fd2num>
  801bf3:	89 c3                	mov    %eax,%ebx
}
  801bf5:	89 d8                	mov    %ebx,%eax
  801bf7:	83 c4 20             	add    $0x20,%esp
  801bfa:	5b                   	pop    %ebx
  801bfb:	5e                   	pop    %esi
  801bfc:	5d                   	pop    %ebp
  801bfd:	c3                   	ret    

00801bfe <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c04:	8b 45 10             	mov    0x10(%ebp),%eax
  801c07:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	89 04 24             	mov    %eax,(%esp)
  801c18:	e8 79 01 00 00       	call   801d96 <nsipc_socket>
  801c1d:	85 c0                	test   %eax,%eax
  801c1f:	78 05                	js     801c26 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c21:	e8 61 ff ff ff       	call   801b87 <alloc_sockfd>
}
  801c26:	c9                   	leave  
  801c27:	c3                   	ret    

00801c28 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 50 f6 ff ff       	call   80128d <fd_lookup>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 15                	js     801c56 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c44:	8b 0a                	mov    (%edx),%ecx
  801c46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c4b:	3b 0d 24 30 80 00    	cmp    0x803024,%ecx
  801c51:	75 03                	jne    801c56 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c53:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c61:	e8 c2 ff ff ff       	call   801c28 <fd2sockid>
  801c66:	85 c0                	test   %eax,%eax
  801c68:	78 0f                	js     801c79 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c71:	89 04 24             	mov    %eax,(%esp)
  801c74:	e8 47 01 00 00       	call   801dc0 <nsipc_listen>
}
  801c79:	c9                   	leave  
  801c7a:	c3                   	ret    

00801c7b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c81:	8b 45 08             	mov    0x8(%ebp),%eax
  801c84:	e8 9f ff ff ff       	call   801c28 <fd2sockid>
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 16                	js     801ca3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801c8d:	8b 55 10             	mov    0x10(%ebp),%edx
  801c90:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c97:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c9b:	89 04 24             	mov    %eax,(%esp)
  801c9e:	e8 6e 02 00 00       	call   801f11 <nsipc_connect>
}
  801ca3:	c9                   	leave  
  801ca4:	c3                   	ret    

00801ca5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801ca5:	55                   	push   %ebp
  801ca6:	89 e5                	mov    %esp,%ebp
  801ca8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cab:	8b 45 08             	mov    0x8(%ebp),%eax
  801cae:	e8 75 ff ff ff       	call   801c28 <fd2sockid>
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	78 0f                	js     801cc6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cba:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cbe:	89 04 24             	mov    %eax,(%esp)
  801cc1:	e8 36 01 00 00       	call   801dfc <nsipc_shutdown>
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	e8 52 ff ff ff       	call   801c28 <fd2sockid>
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 16                	js     801cf0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cda:	8b 55 10             	mov    0x10(%ebp),%edx
  801cdd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ce4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce8:	89 04 24             	mov    %eax,(%esp)
  801ceb:	e8 60 02 00 00       	call   801f50 <nsipc_bind>
}
  801cf0:	c9                   	leave  
  801cf1:	c3                   	ret    

00801cf2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfb:	e8 28 ff ff ff       	call   801c28 <fd2sockid>
  801d00:	85 c0                	test   %eax,%eax
  801d02:	78 1f                	js     801d23 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d04:	8b 55 10             	mov    0x10(%ebp),%edx
  801d07:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d12:	89 04 24             	mov    %eax,(%esp)
  801d15:	e8 75 02 00 00       	call   801f8f <nsipc_accept>
  801d1a:	85 c0                	test   %eax,%eax
  801d1c:	78 05                	js     801d23 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d1e:	e8 64 fe ff ff       	call   801b87 <alloc_sockfd>
}
  801d23:	c9                   	leave  
  801d24:	c3                   	ret    
	...

00801d30 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d30:	55                   	push   %ebp
  801d31:	89 e5                	mov    %esp,%ebp
  801d33:	53                   	push   %ebx
  801d34:	83 ec 14             	sub    $0x14,%esp
  801d37:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d39:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d40:	75 11                	jne    801d53 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d42:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801d49:	e8 f2 02 00 00       	call   802040 <ipc_find_env>
  801d4e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d53:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d5a:	00 
  801d5b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d62:	00 
  801d63:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d67:	a1 04 40 80 00       	mov    0x804004,%eax
  801d6c:	89 04 24             	mov    %eax,(%esp)
  801d6f:	e8 15 03 00 00       	call   802089 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d7b:	00 
  801d7c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d83:	00 
  801d84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d8b:	e8 64 03 00 00       	call   8020f4 <ipc_recv>
}
  801d90:	83 c4 14             	add    $0x14,%esp
  801d93:	5b                   	pop    %ebx
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dac:	8b 45 10             	mov    0x10(%ebp),%eax
  801daf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801db4:	b8 09 00 00 00       	mov    $0x9,%eax
  801db9:	e8 72 ff ff ff       	call   801d30 <nsipc>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dce:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  801ddb:	e8 50 ff ff ff       	call   801d30 <nsipc>
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801de8:	8b 45 08             	mov    0x8(%ebp),%eax
  801deb:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801df0:	b8 04 00 00 00       	mov    $0x4,%eax
  801df5:	e8 36 ff ff ff       	call   801d30 <nsipc>
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e02:	8b 45 08             	mov    0x8(%ebp),%eax
  801e05:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e0d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e12:	b8 03 00 00 00       	mov    $0x3,%eax
  801e17:	e8 14 ff ff ff       	call   801d30 <nsipc>
}
  801e1c:	c9                   	leave  
  801e1d:	c3                   	ret    

00801e1e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	53                   	push   %ebx
  801e22:	83 ec 14             	sub    $0x14,%esp
  801e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e28:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e30:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e36:	7e 24                	jle    801e5c <nsipc_send+0x3e>
  801e38:	c7 44 24 0c 15 2d 80 	movl   $0x802d15,0xc(%esp)
  801e3f:	00 
  801e40:	c7 44 24 08 e9 2c 80 	movl   $0x802ce9,0x8(%esp)
  801e47:	00 
  801e48:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801e4f:	00 
  801e50:	c7 04 24 21 2d 80 00 	movl   $0x802d21,(%esp)
  801e57:	e8 88 01 00 00       	call   801fe4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e5c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e67:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e6e:	e8 72 ed ff ff       	call   800be5 <memmove>
	nsipcbuf.send.req_size = size;
  801e73:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e79:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801e81:	b8 08 00 00 00       	mov    $0x8,%eax
  801e86:	e8 a5 fe ff ff       	call   801d30 <nsipc>
}
  801e8b:	83 c4 14             	add    $0x14,%esp
  801e8e:	5b                   	pop    %ebx
  801e8f:	5d                   	pop    %ebp
  801e90:	c3                   	ret    

00801e91 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e91:	55                   	push   %ebp
  801e92:	89 e5                	mov    %esp,%ebp
  801e94:	56                   	push   %esi
  801e95:	53                   	push   %ebx
  801e96:	83 ec 10             	sub    $0x10,%esp
  801e99:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ea4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eaa:	8b 45 14             	mov    0x14(%ebp),%eax
  801ead:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801eb2:	b8 07 00 00 00       	mov    $0x7,%eax
  801eb7:	e8 74 fe ff ff       	call   801d30 <nsipc>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 46                	js     801f08 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ec2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ec7:	7f 04                	jg     801ecd <nsipc_recv+0x3c>
  801ec9:	39 c6                	cmp    %eax,%esi
  801ecb:	7d 24                	jge    801ef1 <nsipc_recv+0x60>
  801ecd:	c7 44 24 0c 2d 2d 80 	movl   $0x802d2d,0xc(%esp)
  801ed4:	00 
  801ed5:	c7 44 24 08 e9 2c 80 	movl   $0x802ce9,0x8(%esp)
  801edc:	00 
  801edd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801ee4:	00 
  801ee5:	c7 04 24 21 2d 80 00 	movl   $0x802d21,(%esp)
  801eec:	e8 f3 00 00 00       	call   801fe4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ef1:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ef5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801efc:	00 
  801efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f00:	89 04 24             	mov    %eax,(%esp)
  801f03:	e8 dd ec ff ff       	call   800be5 <memmove>
	}

	return r;
}
  801f08:	89 d8                	mov    %ebx,%eax
  801f0a:	83 c4 10             	add    $0x10,%esp
  801f0d:	5b                   	pop    %ebx
  801f0e:	5e                   	pop    %esi
  801f0f:	5d                   	pop    %ebp
  801f10:	c3                   	ret    

00801f11 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	53                   	push   %ebx
  801f15:	83 ec 14             	sub    $0x14,%esp
  801f18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f1e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f23:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f35:	e8 ab ec ff ff       	call   800be5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f3a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f40:	b8 05 00 00 00       	mov    $0x5,%eax
  801f45:	e8 e6 fd ff ff       	call   801d30 <nsipc>
}
  801f4a:	83 c4 14             	add    $0x14,%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    

00801f50 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f50:	55                   	push   %ebp
  801f51:	89 e5                	mov    %esp,%ebp
  801f53:	53                   	push   %ebx
  801f54:	83 ec 14             	sub    $0x14,%esp
  801f57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f62:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f74:	e8 6c ec ff ff       	call   800be5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f79:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f7f:	b8 02 00 00 00       	mov    $0x2,%eax
  801f84:	e8 a7 fd ff ff       	call   801d30 <nsipc>
}
  801f89:	83 c4 14             	add    $0x14,%esp
  801f8c:	5b                   	pop    %ebx
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	83 ec 18             	sub    $0x18,%esp
  801f95:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f98:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801f9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f9e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fa3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa8:	e8 83 fd ff ff       	call   801d30 <nsipc>
  801fad:	89 c3                	mov    %eax,%ebx
  801faf:	85 c0                	test   %eax,%eax
  801fb1:	78 25                	js     801fd8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fb3:	be 10 60 80 00       	mov    $0x806010,%esi
  801fb8:	8b 06                	mov    (%esi),%eax
  801fba:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fbe:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fc5:	00 
  801fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc9:	89 04 24             	mov    %eax,(%esp)
  801fcc:	e8 14 ec ff ff       	call   800be5 <memmove>
		*addrlen = ret->ret_addrlen;
  801fd1:	8b 16                	mov    (%esi),%edx
  801fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fd6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fdd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fe0:	89 ec                	mov    %ebp,%esp
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    

00801fe4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	56                   	push   %esi
  801fe8:	53                   	push   %ebx
  801fe9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801fec:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801fef:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  801ff5:	e8 0d f1 ff ff       	call   801107 <sys_getenvid>
  801ffa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ffd:	89 54 24 10          	mov    %edx,0x10(%esp)
  802001:	8b 55 08             	mov    0x8(%ebp),%edx
  802004:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802008:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802010:	c7 04 24 44 2d 80 00 	movl   $0x802d44,(%esp)
  802017:	e8 9d e2 ff ff       	call   8002b9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80201c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802020:	8b 45 10             	mov    0x10(%ebp),%eax
  802023:	89 04 24             	mov    %eax,(%esp)
  802026:	e8 2d e2 ff ff       	call   800258 <vcprintf>
	cprintf("\n");
  80202b:	c7 04 24 34 28 80 00 	movl   $0x802834,(%esp)
  802032:	e8 82 e2 ff ff       	call   8002b9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802037:	cc                   	int3   
  802038:	eb fd                	jmp    802037 <_panic+0x53>
  80203a:	00 00                	add    %al,(%eax)
  80203c:	00 00                	add    %al,(%eax)
	...

00802040 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802046:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80204c:	b8 01 00 00 00       	mov    $0x1,%eax
  802051:	39 ca                	cmp    %ecx,%edx
  802053:	75 04                	jne    802059 <ipc_find_env+0x19>
  802055:	b0 00                	mov    $0x0,%al
  802057:	eb 11                	jmp    80206a <ipc_find_env+0x2a>
  802059:	89 c2                	mov    %eax,%edx
  80205b:	c1 e2 07             	shl    $0x7,%edx
  80205e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802064:	8b 12                	mov    (%edx),%edx
  802066:	39 ca                	cmp    %ecx,%edx
  802068:	75 0f                	jne    802079 <ipc_find_env+0x39>
			return envs[i].env_id;
  80206a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  80206e:	c1 e0 06             	shl    $0x6,%eax
  802071:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  802077:	eb 0e                	jmp    802087 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802079:	83 c0 01             	add    $0x1,%eax
  80207c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802081:	75 d6                	jne    802059 <ipc_find_env+0x19>
  802083:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    

00802089 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	57                   	push   %edi
  80208d:	56                   	push   %esi
  80208e:	53                   	push   %ebx
  80208f:	83 ec 1c             	sub    $0x1c,%esp
  802092:	8b 75 08             	mov    0x8(%ebp),%esi
  802095:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802098:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80209b:	85 db                	test   %ebx,%ebx
  80209d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020a2:	0f 44 d8             	cmove  %eax,%ebx
  8020a5:	eb 25                	jmp    8020cc <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8020a7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020aa:	74 20                	je     8020cc <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8020ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020b0:	c7 44 24 08 68 2d 80 	movl   $0x802d68,0x8(%esp)
  8020b7:	00 
  8020b8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8020bf:	00 
  8020c0:	c7 04 24 86 2d 80 00 	movl   $0x802d86,(%esp)
  8020c7:	e8 18 ff ff ff       	call   801fe4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8020cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8020cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020db:	89 34 24             	mov    %esi,(%esp)
  8020de:	e8 2b ee ff ff       	call   800f0e <sys_ipc_try_send>
  8020e3:	85 c0                	test   %eax,%eax
  8020e5:	75 c0                	jne    8020a7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8020e7:	e8 a8 ef ff ff       	call   801094 <sys_yield>
}
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    

008020f4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 28             	sub    $0x28,%esp
  8020fa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020fd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802100:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802103:	8b 75 08             	mov    0x8(%ebp),%esi
  802106:	8b 45 0c             	mov    0xc(%ebp),%eax
  802109:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80210c:	85 c0                	test   %eax,%eax
  80210e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802113:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802116:	89 04 24             	mov    %eax,(%esp)
  802119:	e8 b7 ed ff ff       	call   800ed5 <sys_ipc_recv>
  80211e:	89 c3                	mov    %eax,%ebx
  802120:	85 c0                	test   %eax,%eax
  802122:	79 2a                	jns    80214e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802124:	89 44 24 08          	mov    %eax,0x8(%esp)
  802128:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212c:	c7 04 24 90 2d 80 00 	movl   $0x802d90,(%esp)
  802133:	e8 81 e1 ff ff       	call   8002b9 <cprintf>
		if(from_env_store != NULL)
  802138:	85 f6                	test   %esi,%esi
  80213a:	74 06                	je     802142 <ipc_recv+0x4e>
			*from_env_store = 0;
  80213c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802142:	85 ff                	test   %edi,%edi
  802144:	74 2c                	je     802172 <ipc_recv+0x7e>
			*perm_store = 0;
  802146:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80214c:	eb 24                	jmp    802172 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80214e:	85 f6                	test   %esi,%esi
  802150:	74 0a                	je     80215c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  802152:	a1 18 40 80 00       	mov    0x804018,%eax
  802157:	8b 40 74             	mov    0x74(%eax),%eax
  80215a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80215c:	85 ff                	test   %edi,%edi
  80215e:	74 0a                	je     80216a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802160:	a1 18 40 80 00       	mov    0x804018,%eax
  802165:	8b 40 78             	mov    0x78(%eax),%eax
  802168:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80216a:	a1 18 40 80 00       	mov    0x804018,%eax
  80216f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802172:	89 d8                	mov    %ebx,%eax
  802174:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802177:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80217a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80217d:	89 ec                	mov    %ebp,%esp
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    
  802181:	00 00                	add    %al,(%eax)
	...

00802184 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802184:	55                   	push   %ebp
  802185:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802187:	8b 45 08             	mov    0x8(%ebp),%eax
  80218a:	89 c2                	mov    %eax,%edx
  80218c:	c1 ea 16             	shr    $0x16,%edx
  80218f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802196:	f6 c2 01             	test   $0x1,%dl
  802199:	74 20                	je     8021bb <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80219b:	c1 e8 0c             	shr    $0xc,%eax
  80219e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021a5:	a8 01                	test   $0x1,%al
  8021a7:	74 12                	je     8021bb <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021a9:	c1 e8 0c             	shr    $0xc,%eax
  8021ac:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8021b1:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8021b6:	0f b7 c0             	movzwl %ax,%eax
  8021b9:	eb 05                	jmp    8021c0 <pageref+0x3c>
  8021bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
	...

008021d0 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	57                   	push   %edi
  8021d4:	56                   	push   %esi
  8021d5:	53                   	push   %ebx
  8021d6:	83 ec 20             	sub    $0x20,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8021d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8021df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8021e5:	8d 55 f3             	lea    -0xd(%ebp),%edx
  8021e8:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8021eb:	bb 08 40 80 00       	mov    $0x804008,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  8021f0:	b9 cd ff ff ff       	mov    $0xffffffcd,%ecx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8021f5:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8021f8:	0f b6 37             	movzbl (%edi),%esi
  8021fb:	ba 00 00 00 00       	mov    $0x0,%edx
  802200:	89 d0                	mov    %edx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	89 de                	mov    %ebx,%esi
  802206:	89 c3                	mov    %eax,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802208:	89 d0                	mov    %edx,%eax
  80220a:	f6 e1                	mul    %cl
  80220c:	66 c1 e8 08          	shr    $0x8,%ax
  802210:	c0 e8 03             	shr    $0x3,%al
  802213:	89 c7                	mov    %eax,%edi
  802215:	8d 04 80             	lea    (%eax,%eax,4),%eax
  802218:	01 c0                	add    %eax,%eax
  80221a:	28 c2                	sub    %al,%dl
  80221c:	89 d0                	mov    %edx,%eax
      *ap /= (u8_t)10;
  80221e:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  802220:	0f b6 fb             	movzbl %bl,%edi
  802223:	83 c0 30             	add    $0x30,%eax
  802226:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  80222a:	8d 43 01             	lea    0x1(%ebx),%eax
    } while(*ap);
  80222d:	84 d2                	test   %dl,%dl
  80222f:	74 04                	je     802235 <inet_ntoa+0x65>
  802231:	89 c3                	mov    %eax,%ebx
  802233:	eb d3                	jmp    802208 <inet_ntoa+0x38>
  802235:	88 45 d7             	mov    %al,-0x29(%ebp)
  802238:	89 df                	mov    %ebx,%edi
  80223a:	89 f3                	mov    %esi,%ebx
  80223c:	89 d6                	mov    %edx,%esi
  80223e:	89 fa                	mov    %edi,%edx
  802240:	88 55 dc             	mov    %dl,-0x24(%ebp)
  802243:	89 f0                	mov    %esi,%eax
  802245:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802248:	88 07                	mov    %al,(%edi)
    while(i--)
  80224a:	80 7d d7 00          	cmpb   $0x0,-0x29(%ebp)
  80224e:	74 2a                	je     80227a <inet_ntoa+0xaa>
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802250:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  802254:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802257:	8d 7c 03 01          	lea    0x1(%ebx,%eax,1),%edi
  80225b:	89 d8                	mov    %ebx,%eax
  80225d:	89 de                	mov    %ebx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  80225f:	0f b6 da             	movzbl %dl,%ebx
  802262:	0f b6 5c 1d ed       	movzbl -0x13(%ebp,%ebx,1),%ebx
  802267:	88 18                	mov    %bl,(%eax)
  802269:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80226c:	83 ea 01             	sub    $0x1,%edx
  80226f:	39 f8                	cmp    %edi,%eax
  802271:	75 ec                	jne    80225f <inet_ntoa+0x8f>
  802273:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802276:	8d 5c 16 01          	lea    0x1(%esi,%edx,1),%ebx
      *rp++ = inv[i];
    *rp++ = '.';
  80227a:	c6 03 2e             	movb   $0x2e,(%ebx)
  80227d:	8d 43 01             	lea    0x1(%ebx),%eax
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802280:	8b 7d d8             	mov    -0x28(%ebp),%edi
  802283:	39 7d e0             	cmp    %edi,-0x20(%ebp)
  802286:	74 0b                	je     802293 <inet_ntoa+0xc3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802288:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80228c:	89 c3                	mov    %eax,%ebx
  80228e:	e9 62 ff ff ff       	jmp    8021f5 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802293:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  802296:	b8 08 40 80 00       	mov    $0x804008,%eax
  80229b:	83 c4 20             	add    $0x20,%esp
  80229e:	5b                   	pop    %ebx
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    

008022a3 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8022a3:	55                   	push   %ebp
  8022a4:	89 e5                	mov    %esp,%ebp
  8022a6:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8022aa:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  8022ae:	5d                   	pop    %ebp
  8022af:	c3                   	ret    

008022b0 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  8022b6:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8022ba:	89 04 24             	mov    %eax,(%esp)
  8022bd:	e8 e1 ff ff ff       	call   8022a3 <htons>
}
  8022c2:	c9                   	leave  
  8022c3:	c3                   	ret    

008022c4 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8022c4:	55                   	push   %ebp
  8022c5:	89 e5                	mov    %esp,%ebp
  8022c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8022ca:	89 d1                	mov    %edx,%ecx
  8022cc:	c1 e9 18             	shr    $0x18,%ecx
  8022cf:	89 d0                	mov    %edx,%eax
  8022d1:	c1 e0 18             	shl    $0x18,%eax
  8022d4:	09 c8                	or     %ecx,%eax
  8022d6:	89 d1                	mov    %edx,%ecx
  8022d8:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8022de:	c1 e1 08             	shl    $0x8,%ecx
  8022e1:	09 c8                	or     %ecx,%eax
  8022e3:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8022e9:	c1 ea 08             	shr    $0x8,%edx
  8022ec:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8022ee:	5d                   	pop    %ebp
  8022ef:	c3                   	ret    

008022f0 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	57                   	push   %edi
  8022f4:	56                   	push   %esi
  8022f5:	53                   	push   %ebx
  8022f6:	83 ec 28             	sub    $0x28,%esp
  8022f9:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  8022fc:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8022ff:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802302:	80 f9 09             	cmp    $0x9,%cl
  802305:	0f 87 a8 01 00 00    	ja     8024b3 <inet_aton+0x1c3>
  80230b:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80230e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802311:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  802314:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  802317:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  80231e:	83 fa 30             	cmp    $0x30,%edx
  802321:	75 24                	jne    802347 <inet_aton+0x57>
      c = *++cp;
  802323:	83 c0 01             	add    $0x1,%eax
  802326:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  802329:	83 fa 78             	cmp    $0x78,%edx
  80232c:	74 0c                	je     80233a <inet_aton+0x4a>
  80232e:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  802335:	83 fa 58             	cmp    $0x58,%edx
  802338:	75 0d                	jne    802347 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  80233a:	83 c0 01             	add    $0x1,%eax
  80233d:	0f be 10             	movsbl (%eax),%edx
  802340:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  802347:	83 c0 01             	add    $0x1,%eax
  80234a:	be 00 00 00 00       	mov    $0x0,%esi
  80234f:	eb 03                	jmp    802354 <inet_aton+0x64>
  802351:	83 c0 01             	add    $0x1,%eax
  802354:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  802357:	89 d1                	mov    %edx,%ecx
  802359:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80235c:	80 fb 09             	cmp    $0x9,%bl
  80235f:	77 0d                	ja     80236e <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  802361:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  802365:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  802369:	0f be 10             	movsbl (%eax),%edx
  80236c:	eb e3                	jmp    802351 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  80236e:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  802372:	75 2b                	jne    80239f <inet_aton+0xaf>
  802374:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802377:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  80237a:	80 fb 05             	cmp    $0x5,%bl
  80237d:	76 08                	jbe    802387 <inet_aton+0x97>
  80237f:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802382:	80 fb 05             	cmp    $0x5,%bl
  802385:	77 18                	ja     80239f <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802387:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80238b:	19 c9                	sbb    %ecx,%ecx
  80238d:	83 e1 20             	and    $0x20,%ecx
  802390:	c1 e6 04             	shl    $0x4,%esi
  802393:	29 ca                	sub    %ecx,%edx
  802395:	8d 52 c9             	lea    -0x37(%edx),%edx
  802398:	09 d6                	or     %edx,%esi
        c = *++cp;
  80239a:	0f be 10             	movsbl (%eax),%edx
  80239d:	eb b2                	jmp    802351 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  80239f:	83 fa 2e             	cmp    $0x2e,%edx
  8023a2:	75 29                	jne    8023cd <inet_aton+0xdd>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8023a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8023a7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8023aa:	0f 86 03 01 00 00    	jbe    8024b3 <inet_aton+0x1c3>
        return (0);
      *pp++ = val;
  8023b0:	89 32                	mov    %esi,(%edx)
      c = *++cp;
  8023b2:	8d 47 01             	lea    0x1(%edi),%eax
  8023b5:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8023b8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8023bb:	80 f9 09             	cmp    $0x9,%cl
  8023be:	0f 87 ef 00 00 00    	ja     8024b3 <inet_aton+0x1c3>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  8023c4:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  8023c8:	e9 4a ff ff ff       	jmp    802317 <inet_aton+0x27>
  8023cd:	89 f3                	mov    %esi,%ebx
  8023cf:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8023d1:	85 d2                	test   %edx,%edx
  8023d3:	74 36                	je     80240b <inet_aton+0x11b>
  8023d5:	80 f9 1f             	cmp    $0x1f,%cl
  8023d8:	0f 86 d5 00 00 00    	jbe    8024b3 <inet_aton+0x1c3>
  8023de:	84 d2                	test   %dl,%dl
  8023e0:	0f 88 cd 00 00 00    	js     8024b3 <inet_aton+0x1c3>
  8023e6:	83 fa 20             	cmp    $0x20,%edx
  8023e9:	74 20                	je     80240b <inet_aton+0x11b>
  8023eb:	83 fa 0c             	cmp    $0xc,%edx
  8023ee:	66 90                	xchg   %ax,%ax
  8023f0:	74 19                	je     80240b <inet_aton+0x11b>
  8023f2:	83 fa 0a             	cmp    $0xa,%edx
  8023f5:	74 14                	je     80240b <inet_aton+0x11b>
  8023f7:	83 fa 0d             	cmp    $0xd,%edx
  8023fa:	74 0f                	je     80240b <inet_aton+0x11b>
  8023fc:	83 fa 09             	cmp    $0x9,%edx
  8023ff:	90                   	nop
  802400:	74 09                	je     80240b <inet_aton+0x11b>
  802402:	83 fa 0b             	cmp    $0xb,%edx
  802405:	0f 85 a8 00 00 00    	jne    8024b3 <inet_aton+0x1c3>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  80240b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80240e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802411:	29 d1                	sub    %edx,%ecx
  802413:	89 ca                	mov    %ecx,%edx
  802415:	c1 fa 02             	sar    $0x2,%edx
  802418:	83 c2 01             	add    $0x1,%edx
  80241b:	83 fa 02             	cmp    $0x2,%edx
  80241e:	74 2a                	je     80244a <inet_aton+0x15a>
  802420:	83 fa 02             	cmp    $0x2,%edx
  802423:	7f 0d                	jg     802432 <inet_aton+0x142>
  802425:	85 d2                	test   %edx,%edx
  802427:	0f 84 86 00 00 00    	je     8024b3 <inet_aton+0x1c3>
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	eb 62                	jmp    802494 <inet_aton+0x1a4>
  802432:	83 fa 03             	cmp    $0x3,%edx
  802435:	8d 76 00             	lea    0x0(%esi),%esi
  802438:	74 22                	je     80245c <inet_aton+0x16c>
  80243a:	83 fa 04             	cmp    $0x4,%edx
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	75 52                	jne    802494 <inet_aton+0x1a4>
  802442:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802448:	eb 2b                	jmp    802475 <inet_aton+0x185>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80244a:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  80244f:	90                   	nop
  802450:	77 61                	ja     8024b3 <inet_aton+0x1c3>
      return (0);
    val |= parts[0] << 24;
  802452:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802455:	c1 e3 18             	shl    $0x18,%ebx
  802458:	09 c3                	or     %eax,%ebx
    break;
  80245a:	eb 38                	jmp    802494 <inet_aton+0x1a4>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80245c:	3d ff ff 00 00       	cmp    $0xffff,%eax
  802461:	77 50                	ja     8024b3 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  802463:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  802466:	c1 e3 10             	shl    $0x10,%ebx
  802469:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80246c:	c1 e2 18             	shl    $0x18,%edx
  80246f:	09 d3                	or     %edx,%ebx
  802471:	09 c3                	or     %eax,%ebx
    break;
  802473:	eb 1f                	jmp    802494 <inet_aton+0x1a4>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  802475:	3d ff 00 00 00       	cmp    $0xff,%eax
  80247a:	77 37                	ja     8024b3 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80247c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80247f:	c1 e3 10             	shl    $0x10,%ebx
  802482:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802485:	c1 e2 18             	shl    $0x18,%edx
  802488:	09 d3                	or     %edx,%ebx
  80248a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80248d:	c1 e2 08             	shl    $0x8,%edx
  802490:	09 d3                	or     %edx,%ebx
  802492:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  802494:	b8 01 00 00 00       	mov    $0x1,%eax
  802499:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80249d:	74 19                	je     8024b8 <inet_aton+0x1c8>
    addr->s_addr = htonl(val);
  80249f:	89 1c 24             	mov    %ebx,(%esp)
  8024a2:	e8 1d fe ff ff       	call   8022c4 <htonl>
  8024a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8024aa:	89 03                	mov    %eax,(%ebx)
  8024ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b1:	eb 05                	jmp    8024b8 <inet_aton+0x1c8>
  8024b3:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  8024b8:	83 c4 28             	add    $0x28,%esp
  8024bb:	5b                   	pop    %ebx
  8024bc:	5e                   	pop    %esi
  8024bd:	5f                   	pop    %edi
  8024be:	5d                   	pop    %ebp
  8024bf:	c3                   	ret    

008024c0 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8024c0:	55                   	push   %ebp
  8024c1:	89 e5                	mov    %esp,%ebp
  8024c3:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8024c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8024c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8024d0:	89 04 24             	mov    %eax,(%esp)
  8024d3:	e8 18 fe ff ff       	call   8022f0 <inet_aton>
  8024d8:	85 c0                	test   %eax,%eax
  8024da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024df:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  8024e3:	c9                   	leave  
  8024e4:	c3                   	ret    

008024e5 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8024e5:	55                   	push   %ebp
  8024e6:	89 e5                	mov    %esp,%ebp
  8024e8:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  8024eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ee:	89 04 24             	mov    %eax,(%esp)
  8024f1:	e8 ce fd ff ff       	call   8022c4 <htonl>
}
  8024f6:	c9                   	leave  
  8024f7:	c3                   	ret    
	...

00802500 <__udivdi3>:
  802500:	55                   	push   %ebp
  802501:	89 e5                	mov    %esp,%ebp
  802503:	57                   	push   %edi
  802504:	56                   	push   %esi
  802505:	83 ec 10             	sub    $0x10,%esp
  802508:	8b 45 14             	mov    0x14(%ebp),%eax
  80250b:	8b 55 08             	mov    0x8(%ebp),%edx
  80250e:	8b 75 10             	mov    0x10(%ebp),%esi
  802511:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802514:	85 c0                	test   %eax,%eax
  802516:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802519:	75 35                	jne    802550 <__udivdi3+0x50>
  80251b:	39 fe                	cmp    %edi,%esi
  80251d:	77 61                	ja     802580 <__udivdi3+0x80>
  80251f:	85 f6                	test   %esi,%esi
  802521:	75 0b                	jne    80252e <__udivdi3+0x2e>
  802523:	b8 01 00 00 00       	mov    $0x1,%eax
  802528:	31 d2                	xor    %edx,%edx
  80252a:	f7 f6                	div    %esi
  80252c:	89 c6                	mov    %eax,%esi
  80252e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802531:	31 d2                	xor    %edx,%edx
  802533:	89 f8                	mov    %edi,%eax
  802535:	f7 f6                	div    %esi
  802537:	89 c7                	mov    %eax,%edi
  802539:	89 c8                	mov    %ecx,%eax
  80253b:	f7 f6                	div    %esi
  80253d:	89 c1                	mov    %eax,%ecx
  80253f:	89 fa                	mov    %edi,%edx
  802541:	89 c8                	mov    %ecx,%eax
  802543:	83 c4 10             	add    $0x10,%esp
  802546:	5e                   	pop    %esi
  802547:	5f                   	pop    %edi
  802548:	5d                   	pop    %ebp
  802549:	c3                   	ret    
  80254a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802550:	39 f8                	cmp    %edi,%eax
  802552:	77 1c                	ja     802570 <__udivdi3+0x70>
  802554:	0f bd d0             	bsr    %eax,%edx
  802557:	83 f2 1f             	xor    $0x1f,%edx
  80255a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80255d:	75 39                	jne    802598 <__udivdi3+0x98>
  80255f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802562:	0f 86 a0 00 00 00    	jbe    802608 <__udivdi3+0x108>
  802568:	39 f8                	cmp    %edi,%eax
  80256a:	0f 82 98 00 00 00    	jb     802608 <__udivdi3+0x108>
  802570:	31 ff                	xor    %edi,%edi
  802572:	31 c9                	xor    %ecx,%ecx
  802574:	89 c8                	mov    %ecx,%eax
  802576:	89 fa                	mov    %edi,%edx
  802578:	83 c4 10             	add    $0x10,%esp
  80257b:	5e                   	pop    %esi
  80257c:	5f                   	pop    %edi
  80257d:	5d                   	pop    %ebp
  80257e:	c3                   	ret    
  80257f:	90                   	nop
  802580:	89 d1                	mov    %edx,%ecx
  802582:	89 fa                	mov    %edi,%edx
  802584:	89 c8                	mov    %ecx,%eax
  802586:	31 ff                	xor    %edi,%edi
  802588:	f7 f6                	div    %esi
  80258a:	89 c1                	mov    %eax,%ecx
  80258c:	89 fa                	mov    %edi,%edx
  80258e:	89 c8                	mov    %ecx,%eax
  802590:	83 c4 10             	add    $0x10,%esp
  802593:	5e                   	pop    %esi
  802594:	5f                   	pop    %edi
  802595:	5d                   	pop    %ebp
  802596:	c3                   	ret    
  802597:	90                   	nop
  802598:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80259c:	89 f2                	mov    %esi,%edx
  80259e:	d3 e0                	shl    %cl,%eax
  8025a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8025a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8025ab:	89 c1                	mov    %eax,%ecx
  8025ad:	d3 ea                	shr    %cl,%edx
  8025af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8025b6:	d3 e6                	shl    %cl,%esi
  8025b8:	89 c1                	mov    %eax,%ecx
  8025ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8025bd:	89 fe                	mov    %edi,%esi
  8025bf:	d3 ee                	shr    %cl,%esi
  8025c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025cb:	d3 e7                	shl    %cl,%edi
  8025cd:	89 c1                	mov    %eax,%ecx
  8025cf:	d3 ea                	shr    %cl,%edx
  8025d1:	09 d7                	or     %edx,%edi
  8025d3:	89 f2                	mov    %esi,%edx
  8025d5:	89 f8                	mov    %edi,%eax
  8025d7:	f7 75 ec             	divl   -0x14(%ebp)
  8025da:	89 d6                	mov    %edx,%esi
  8025dc:	89 c7                	mov    %eax,%edi
  8025de:	f7 65 e8             	mull   -0x18(%ebp)
  8025e1:	39 d6                	cmp    %edx,%esi
  8025e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025e6:	72 30                	jb     802618 <__udivdi3+0x118>
  8025e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025ef:	d3 e2                	shl    %cl,%edx
  8025f1:	39 c2                	cmp    %eax,%edx
  8025f3:	73 05                	jae    8025fa <__udivdi3+0xfa>
  8025f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8025f8:	74 1e                	je     802618 <__udivdi3+0x118>
  8025fa:	89 f9                	mov    %edi,%ecx
  8025fc:	31 ff                	xor    %edi,%edi
  8025fe:	e9 71 ff ff ff       	jmp    802574 <__udivdi3+0x74>
  802603:	90                   	nop
  802604:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802608:	31 ff                	xor    %edi,%edi
  80260a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80260f:	e9 60 ff ff ff       	jmp    802574 <__udivdi3+0x74>
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80261b:	31 ff                	xor    %edi,%edi
  80261d:	89 c8                	mov    %ecx,%eax
  80261f:	89 fa                	mov    %edi,%edx
  802621:	83 c4 10             	add    $0x10,%esp
  802624:	5e                   	pop    %esi
  802625:	5f                   	pop    %edi
  802626:	5d                   	pop    %ebp
  802627:	c3                   	ret    
	...

00802630 <__umoddi3>:
  802630:	55                   	push   %ebp
  802631:	89 e5                	mov    %esp,%ebp
  802633:	57                   	push   %edi
  802634:	56                   	push   %esi
  802635:	83 ec 20             	sub    $0x20,%esp
  802638:	8b 55 14             	mov    0x14(%ebp),%edx
  80263b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80263e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802641:	8b 75 0c             	mov    0xc(%ebp),%esi
  802644:	85 d2                	test   %edx,%edx
  802646:	89 c8                	mov    %ecx,%eax
  802648:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80264b:	75 13                	jne    802660 <__umoddi3+0x30>
  80264d:	39 f7                	cmp    %esi,%edi
  80264f:	76 3f                	jbe    802690 <__umoddi3+0x60>
  802651:	89 f2                	mov    %esi,%edx
  802653:	f7 f7                	div    %edi
  802655:	89 d0                	mov    %edx,%eax
  802657:	31 d2                	xor    %edx,%edx
  802659:	83 c4 20             	add    $0x20,%esp
  80265c:	5e                   	pop    %esi
  80265d:	5f                   	pop    %edi
  80265e:	5d                   	pop    %ebp
  80265f:	c3                   	ret    
  802660:	39 f2                	cmp    %esi,%edx
  802662:	77 4c                	ja     8026b0 <__umoddi3+0x80>
  802664:	0f bd ca             	bsr    %edx,%ecx
  802667:	83 f1 1f             	xor    $0x1f,%ecx
  80266a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80266d:	75 51                	jne    8026c0 <__umoddi3+0x90>
  80266f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802672:	0f 87 e0 00 00 00    	ja     802758 <__umoddi3+0x128>
  802678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80267b:	29 f8                	sub    %edi,%eax
  80267d:	19 d6                	sbb    %edx,%esi
  80267f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802682:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802685:	89 f2                	mov    %esi,%edx
  802687:	83 c4 20             	add    $0x20,%esp
  80268a:	5e                   	pop    %esi
  80268b:	5f                   	pop    %edi
  80268c:	5d                   	pop    %ebp
  80268d:	c3                   	ret    
  80268e:	66 90                	xchg   %ax,%ax
  802690:	85 ff                	test   %edi,%edi
  802692:	75 0b                	jne    80269f <__umoddi3+0x6f>
  802694:	b8 01 00 00 00       	mov    $0x1,%eax
  802699:	31 d2                	xor    %edx,%edx
  80269b:	f7 f7                	div    %edi
  80269d:	89 c7                	mov    %eax,%edi
  80269f:	89 f0                	mov    %esi,%eax
  8026a1:	31 d2                	xor    %edx,%edx
  8026a3:	f7 f7                	div    %edi
  8026a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026a8:	f7 f7                	div    %edi
  8026aa:	eb a9                	jmp    802655 <__umoddi3+0x25>
  8026ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	89 c8                	mov    %ecx,%eax
  8026b2:	89 f2                	mov    %esi,%edx
  8026b4:	83 c4 20             	add    $0x20,%esp
  8026b7:	5e                   	pop    %esi
  8026b8:	5f                   	pop    %edi
  8026b9:	5d                   	pop    %ebp
  8026ba:	c3                   	ret    
  8026bb:	90                   	nop
  8026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026c4:	d3 e2                	shl    %cl,%edx
  8026c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8026ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8026d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026d8:	89 fa                	mov    %edi,%edx
  8026da:	d3 ea                	shr    %cl,%edx
  8026dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026e3:	d3 e7                	shl    %cl,%edi
  8026e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026ec:	89 f2                	mov    %esi,%edx
  8026ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8026f1:	89 c7                	mov    %eax,%edi
  8026f3:	d3 ea                	shr    %cl,%edx
  8026f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8026fc:	89 c2                	mov    %eax,%edx
  8026fe:	d3 e6                	shl    %cl,%esi
  802700:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802704:	d3 ea                	shr    %cl,%edx
  802706:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80270a:	09 d6                	or     %edx,%esi
  80270c:	89 f0                	mov    %esi,%eax
  80270e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802711:	d3 e7                	shl    %cl,%edi
  802713:	89 f2                	mov    %esi,%edx
  802715:	f7 75 f4             	divl   -0xc(%ebp)
  802718:	89 d6                	mov    %edx,%esi
  80271a:	f7 65 e8             	mull   -0x18(%ebp)
  80271d:	39 d6                	cmp    %edx,%esi
  80271f:	72 2b                	jb     80274c <__umoddi3+0x11c>
  802721:	39 c7                	cmp    %eax,%edi
  802723:	72 23                	jb     802748 <__umoddi3+0x118>
  802725:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802729:	29 c7                	sub    %eax,%edi
  80272b:	19 d6                	sbb    %edx,%esi
  80272d:	89 f0                	mov    %esi,%eax
  80272f:	89 f2                	mov    %esi,%edx
  802731:	d3 ef                	shr    %cl,%edi
  802733:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802737:	d3 e0                	shl    %cl,%eax
  802739:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80273d:	09 f8                	or     %edi,%eax
  80273f:	d3 ea                	shr    %cl,%edx
  802741:	83 c4 20             	add    $0x20,%esp
  802744:	5e                   	pop    %esi
  802745:	5f                   	pop    %edi
  802746:	5d                   	pop    %ebp
  802747:	c3                   	ret    
  802748:	39 d6                	cmp    %edx,%esi
  80274a:	75 d9                	jne    802725 <__umoddi3+0xf5>
  80274c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80274f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802752:	eb d1                	jmp    802725 <__umoddi3+0xf5>
  802754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802758:	39 f2                	cmp    %esi,%edx
  80275a:	0f 82 18 ff ff ff    	jb     802678 <__umoddi3+0x48>
  802760:	e9 1d ff ff ff       	jmp    802682 <__umoddi3+0x52>
