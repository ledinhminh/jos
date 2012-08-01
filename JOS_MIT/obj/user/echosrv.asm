
obj/user/echosrv.debug:     file format elf32-i386


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
  80002c:	e8 db 01 00 00       	call   80020c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <die>:
#define BUFFSIZE 32
#define MAXPENDING 5    // Max connection requests

static void
die(char *m)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  80003a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80003e:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  800045:	e8 8f 02 00 00       	call   8002d9 <cprintf>
	exit();
  80004a:	e8 0d 02 00 00       	call   80025c <exit>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    

00800051 <handle_client>:

void
handle_client(int sock)
{
  800051:	55                   	push   %ebp
  800052:	89 e5                	mov    %esp,%ebp
  800054:	57                   	push   %edi
  800055:	56                   	push   %esi
  800056:	53                   	push   %ebx
  800057:	83 ec 3c             	sub    $0x3c,%esp
  80005a:	8b 7d 08             	mov    0x8(%ebp),%edi
	char buffer[BUFFSIZE];
	int received = -1;
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80005d:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  800064:	00 
  800065:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	89 3c 24             	mov    %edi,(%esp)
  80006f:	e8 9f 14 00 00       	call   801513 <read>
  800074:	89 c3                	mov    %eax,%ebx
  800076:	85 c0                	test   %eax,%eax
  800078:	79 0a                	jns    800084 <handle_client+0x33>
		die("Failed to receive initial bytes from client");
  80007a:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
  80007f:	e8 b0 ff ff ff       	call   800034 <die>

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  800084:	85 db                	test   %ebx,%ebx
  800086:	7e 49                	jle    8000d1 <handle_client+0x80>
		// Send back received data
		if (write(sock, buffer, received) != received)
  800088:	8d 75 c8             	lea    -0x38(%ebp),%esi
  80008b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80008f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800093:	89 3c 24             	mov    %edi,(%esp)
  800096:	e8 ef 13 00 00       	call   80148a <write>
  80009b:	39 d8                	cmp    %ebx,%eax
  80009d:	74 0a                	je     8000a9 <handle_client+0x58>
			die("Failed to send bytes to client");
  80009f:	b8 00 28 80 00       	mov    $0x802800,%eax
  8000a4:	e8 8b ff ff ff       	call   800034 <die>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  8000a9:	c7 44 24 08 20 00 00 	movl   $0x20,0x8(%esp)
  8000b0:	00 
  8000b1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b5:	89 3c 24             	mov    %edi,(%esp)
  8000b8:	e8 56 14 00 00       	call   801513 <read>
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	85 c0                	test   %eax,%eax
  8000c1:	79 0a                	jns    8000cd <handle_client+0x7c>
			die("Failed to receive additional bytes from client");
  8000c3:	b8 20 28 80 00       	mov    $0x802820,%eax
  8000c8:	e8 67 ff ff ff       	call   800034 <die>
	// Receive message
	if ((received = read(sock, buffer, BUFFSIZE)) < 0)
		die("Failed to receive initial bytes from client");

	// Send bytes and check for more incoming data in loop
	while (received > 0) {
  8000cd:	85 db                	test   %ebx,%ebx
  8000cf:	7f ba                	jg     80008b <handle_client+0x3a>

		// Check for more data
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
			die("Failed to receive additional bytes from client");
	}
	close(sock);
  8000d1:	89 3c 24             	mov    %edi,(%esp)
  8000d4:	e8 a3 15 00 00       	call   80167c <close>
}
  8000d9:	83 c4 3c             	add    $0x3c,%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <umain>:

void
umain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 4c             	sub    $0x4c,%esp
	char buffer[BUFFSIZE];
	unsigned int echolen;
	int received = 0;

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  8000ea:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8000f1:	00 
  8000f2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8000f9:	00 
  8000fa:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800101:	e8 18 1b 00 00       	call   801c1e <socket>
  800106:	89 c6                	mov    %eax,%esi
  800108:	85 c0                	test   %eax,%eax
  80010a:	79 0a                	jns    800116 <umain+0x35>
		die("Failed to create socket");
  80010c:	b8 80 27 80 00       	mov    $0x802780,%eax
  800111:	e8 1e ff ff ff       	call   800034 <die>

	cprintf("opened socket\n");
  800116:	c7 04 24 98 27 80 00 	movl   $0x802798,(%esp)
  80011d:	e8 b7 01 00 00       	call   8002d9 <cprintf>

	// Construct the server sockaddr_in structure
	memset(&echoserver, 0, sizeof(echoserver));       // Clear struct
  800122:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800129:	00 
  80012a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800131:	00 
  800132:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800135:	89 1c 24             	mov    %ebx,(%esp)
  800138:	e8 69 0a 00 00       	call   800ba6 <memset>
	echoserver.sin_family = AF_INET;                  // Internet/IP
  80013d:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	echoserver.sin_addr.s_addr = htonl(INADDR_ANY);   // IP address
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 87 21 00 00       	call   8022d4 <htonl>
  80014d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	echoserver.sin_port = htons(PORT);		  // server port
  800150:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800157:	e8 57 21 00 00       	call   8022b3 <htons>
  80015c:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	cprintf("trying to bind\n");
  800160:	c7 04 24 a7 27 80 00 	movl   $0x8027a7,(%esp)
  800167:	e8 6d 01 00 00       	call   8002d9 <cprintf>

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &echoserver,
  80016c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800173:	00 
  800174:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800178:	89 34 24             	mov    %esi,(%esp)
  80017b:	e8 68 1b 00 00       	call   801ce8 <bind>
  800180:	85 c0                	test   %eax,%eax
  800182:	79 0a                	jns    80018e <umain+0xad>
		 sizeof(echoserver)) < 0) {
		die("Failed to bind the server socket");
  800184:	b8 50 28 80 00       	mov    $0x802850,%eax
  800189:	e8 a6 fe ff ff       	call   800034 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  80018e:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  800195:	00 
  800196:	89 34 24             	mov    %esi,(%esp)
  800199:	e8 da 1a 00 00       	call   801c78 <listen>
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 0a                	jns    8001ac <umain+0xcb>
		die("Failed to listen on server socket");
  8001a2:	b8 74 28 80 00       	mov    $0x802874,%eax
  8001a7:	e8 88 fe ff ff       	call   800034 <die>

	cprintf("bound\n");
  8001ac:	c7 04 24 b7 27 80 00 	movl   $0x8027b7,(%esp)
  8001b3:	e8 21 01 00 00       	call   8002d9 <cprintf>
	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001b8:	8d 7d c4             	lea    -0x3c(%ebp),%edi

	cprintf("bound\n");

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
  8001bb:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock =
		     accept(serversock, (struct sockaddr *) &echoclient,
  8001c2:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8001c6:	8d 45 c8             	lea    -0x38(%ebp),%eax
  8001c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001cd:	89 34 24             	mov    %esi,(%esp)
  8001d0:	e8 3d 1b 00 00       	call   801d12 <accept>
  8001d5:	89 c3                	mov    %eax,%ebx

	// Run until canceled
	while (1) {
		unsigned int clientlen = sizeof(echoclient);
		// Wait for client connection
		if ((clientsock =
  8001d7:	85 c0                	test   %eax,%eax
  8001d9:	79 0a                	jns    8001e5 <umain+0x104>
		     accept(serversock, (struct sockaddr *) &echoclient,
			    &clientlen)) < 0) {
			die("Failed to accept client connection");
  8001db:	b8 98 28 80 00       	mov    $0x802898,%eax
  8001e0:	e8 4f fe ff ff       	call   800034 <die>
		}
		cprintf("Client connected: %s\n", inet_ntoa(echoclient.sin_addr));
  8001e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001e8:	89 04 24             	mov    %eax,(%esp)
  8001eb:	e8 f0 1f 00 00       	call   8021e0 <inet_ntoa>
  8001f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001f4:	c7 04 24 be 27 80 00 	movl   $0x8027be,(%esp)
  8001fb:	e8 d9 00 00 00       	call   8002d9 <cprintf>
		handle_client(clientsock);
  800200:	89 1c 24             	mov    %ebx,(%esp)
  800203:	e8 49 fe ff ff       	call   800051 <handle_client>
	}
  800208:	eb b1                	jmp    8001bb <umain+0xda>
	...

0080020c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	83 ec 18             	sub    $0x18,%esp
  800212:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800215:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800218:	8b 75 08             	mov    0x8(%ebp),%esi
  80021b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80021e:	e8 04 0f 00 00       	call   801127 <sys_getenvid>
  800223:	25 ff 03 00 00       	and    $0x3ff,%eax
  800228:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80022b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800230:	a3 18 40 80 00       	mov    %eax,0x804018

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800235:	85 f6                	test   %esi,%esi
  800237:	7e 07                	jle    800240 <libmain+0x34>
		binaryname = argv[0];
  800239:	8b 03                	mov    (%ebx),%eax
  80023b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800240:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800244:	89 34 24             	mov    %esi,(%esp)
  800247:	e8 95 fe ff ff       	call   8000e1 <umain>

	// exit gracefully
	exit();
  80024c:	e8 0b 00 00 00       	call   80025c <exit>
}
  800251:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800254:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800257:	89 ec                	mov    %ebp,%esp
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    
	...

0080025c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800262:	e8 92 14 00 00       	call   8016f9 <close_all>
	sys_env_destroy(0);
  800267:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80026e:	e8 ef 0e 00 00       	call   801162 <sys_env_destroy>
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    
  800275:	00 00                	add    %al,(%eax)
	...

00800278 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800281:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800288:	00 00 00 
	b.cnt = 0;
  80028b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800292:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800295:	8b 45 0c             	mov    0xc(%ebp),%eax
  800298:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029c:	8b 45 08             	mov    0x8(%ebp),%eax
  80029f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	c7 04 24 f3 02 80 00 	movl   $0x8002f3,(%esp)
  8002b4:	e8 d4 01 00 00       	call   80048d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002b9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	e8 05 0f 00 00       	call   8011d6 <sys_cputs>

	return b.cnt;
}
  8002d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    

008002d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8002df:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8002e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e9:	89 04 24             	mov    %eax,(%esp)
  8002ec:	e8 87 ff ff ff       	call   800278 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002f1:	c9                   	leave  
  8002f2:	c3                   	ret    

008002f3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 14             	sub    $0x14,%esp
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fd:	8b 03                	mov    (%ebx),%eax
  8002ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800302:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800306:	83 c0 01             	add    $0x1,%eax
  800309:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80030b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800310:	75 19                	jne    80032b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800312:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800319:	00 
  80031a:	8d 43 08             	lea    0x8(%ebx),%eax
  80031d:	89 04 24             	mov    %eax,(%esp)
  800320:	e8 b1 0e 00 00       	call   8011d6 <sys_cputs>
		b->idx = 0;
  800325:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80032b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80032f:	83 c4 14             	add    $0x14,%esp
  800332:	5b                   	pop    %ebx
  800333:	5d                   	pop    %ebp
  800334:	c3                   	ret    
	...

00800340 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	57                   	push   %edi
  800344:	56                   	push   %esi
  800345:	53                   	push   %ebx
  800346:	83 ec 4c             	sub    $0x4c,%esp
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	89 d6                	mov    %edx,%esi
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800354:	8b 55 0c             	mov    0xc(%ebp),%edx
  800357:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80035a:	8b 45 10             	mov    0x10(%ebp),%eax
  80035d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800360:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800363:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800366:	b9 00 00 00 00       	mov    $0x0,%ecx
  80036b:	39 d1                	cmp    %edx,%ecx
  80036d:	72 15                	jb     800384 <printnum+0x44>
  80036f:	77 07                	ja     800378 <printnum+0x38>
  800371:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800374:	39 d0                	cmp    %edx,%eax
  800376:	76 0c                	jbe    800384 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800378:	83 eb 01             	sub    $0x1,%ebx
  80037b:	85 db                	test   %ebx,%ebx
  80037d:	8d 76 00             	lea    0x0(%esi),%esi
  800380:	7f 61                	jg     8003e3 <printnum+0xa3>
  800382:	eb 70                	jmp    8003f4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800384:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800388:	83 eb 01             	sub    $0x1,%ebx
  80038b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800397:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80039b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80039e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8003a1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8003a4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003af:	00 
  8003b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003bd:	e8 4e 21 00 00       	call   802510 <__udivdi3>
  8003c2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003c5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8003c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8003cc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d0:	89 04 24             	mov    %eax,(%esp)
  8003d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8003d7:	89 f2                	mov    %esi,%edx
  8003d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8003dc:	e8 5f ff ff ff       	call   800340 <printnum>
  8003e1:	eb 11                	jmp    8003f4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003e7:	89 3c 24             	mov    %edi,(%esp)
  8003ea:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003ed:	83 eb 01             	sub    $0x1,%ebx
  8003f0:	85 db                	test   %ebx,%ebx
  8003f2:	7f ef                	jg     8003e3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800403:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040a:	00 
  80040b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80040e:	89 14 24             	mov    %edx,(%esp)
  800411:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800414:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800418:	e8 23 22 00 00       	call   802640 <__umoddi3>
  80041d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800421:	0f be 80 c5 28 80 00 	movsbl 0x8028c5(%eax),%eax
  800428:	89 04 24             	mov    %eax,(%esp)
  80042b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80042e:	83 c4 4c             	add    $0x4c,%esp
  800431:	5b                   	pop    %ebx
  800432:	5e                   	pop    %esi
  800433:	5f                   	pop    %edi
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800439:	83 fa 01             	cmp    $0x1,%edx
  80043c:	7e 0e                	jle    80044c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	8d 4a 08             	lea    0x8(%edx),%ecx
  800443:	89 08                	mov    %ecx,(%eax)
  800445:	8b 02                	mov    (%edx),%eax
  800447:	8b 52 04             	mov    0x4(%edx),%edx
  80044a:	eb 22                	jmp    80046e <getuint+0x38>
	else if (lflag)
  80044c:	85 d2                	test   %edx,%edx
  80044e:	74 10                	je     800460 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800450:	8b 10                	mov    (%eax),%edx
  800452:	8d 4a 04             	lea    0x4(%edx),%ecx
  800455:	89 08                	mov    %ecx,(%eax)
  800457:	8b 02                	mov    (%edx),%eax
  800459:	ba 00 00 00 00       	mov    $0x0,%edx
  80045e:	eb 0e                	jmp    80046e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800460:	8b 10                	mov    (%eax),%edx
  800462:	8d 4a 04             	lea    0x4(%edx),%ecx
  800465:	89 08                	mov    %ecx,(%eax)
  800467:	8b 02                	mov    (%edx),%eax
  800469:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80046e:	5d                   	pop    %ebp
  80046f:	c3                   	ret    

00800470 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800476:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80047a:	8b 10                	mov    (%eax),%edx
  80047c:	3b 50 04             	cmp    0x4(%eax),%edx
  80047f:	73 0a                	jae    80048b <sprintputch+0x1b>
		*b->buf++ = ch;
  800481:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800484:	88 0a                	mov    %cl,(%edx)
  800486:	83 c2 01             	add    $0x1,%edx
  800489:	89 10                	mov    %edx,(%eax)
}
  80048b:	5d                   	pop    %ebp
  80048c:	c3                   	ret    

0080048d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	57                   	push   %edi
  800491:	56                   	push   %esi
  800492:	53                   	push   %ebx
  800493:	83 ec 5c             	sub    $0x5c,%esp
  800496:	8b 7d 08             	mov    0x8(%ebp),%edi
  800499:	8b 75 0c             	mov    0xc(%ebp),%esi
  80049c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80049f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8004a6:	eb 11                	jmp    8004b9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	0f 84 68 04 00 00    	je     800918 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8004b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b4:	89 04 24             	mov    %eax,(%esp)
  8004b7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004b9:	0f b6 03             	movzbl (%ebx),%eax
  8004bc:	83 c3 01             	add    $0x1,%ebx
  8004bf:	83 f8 25             	cmp    $0x25,%eax
  8004c2:	75 e4                	jne    8004a8 <vprintfmt+0x1b>
  8004c4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8004cb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8004d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004d7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8004db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004e2:	eb 06                	jmp    8004ea <vprintfmt+0x5d>
  8004e4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8004e8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ea:	0f b6 13             	movzbl (%ebx),%edx
  8004ed:	0f b6 c2             	movzbl %dl,%eax
  8004f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004f3:	8d 43 01             	lea    0x1(%ebx),%eax
  8004f6:	83 ea 23             	sub    $0x23,%edx
  8004f9:	80 fa 55             	cmp    $0x55,%dl
  8004fc:	0f 87 f9 03 00 00    	ja     8008fb <vprintfmt+0x46e>
  800502:	0f b6 d2             	movzbl %dl,%edx
  800505:	ff 24 95 a0 2a 80 00 	jmp    *0x802aa0(,%edx,4)
  80050c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800510:	eb d6                	jmp    8004e8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800512:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800515:	83 ea 30             	sub    $0x30,%edx
  800518:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80051b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80051e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800521:	83 fb 09             	cmp    $0x9,%ebx
  800524:	77 54                	ja     80057a <vprintfmt+0xed>
  800526:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800529:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80052c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80052f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800532:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800536:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800539:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80053c:	83 fb 09             	cmp    $0x9,%ebx
  80053f:	76 eb                	jbe    80052c <vprintfmt+0x9f>
  800541:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800544:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800547:	eb 31                	jmp    80057a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800549:	8b 55 14             	mov    0x14(%ebp),%edx
  80054c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80054f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800552:	8b 12                	mov    (%edx),%edx
  800554:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800557:	eb 21                	jmp    80057a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800559:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055d:	ba 00 00 00 00       	mov    $0x0,%edx
  800562:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800566:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800569:	e9 7a ff ff ff       	jmp    8004e8 <vprintfmt+0x5b>
  80056e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800575:	e9 6e ff ff ff       	jmp    8004e8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80057a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057e:	0f 89 64 ff ff ff    	jns    8004e8 <vprintfmt+0x5b>
  800584:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800587:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80058a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80058d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800590:	e9 53 ff ff ff       	jmp    8004e8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800595:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800598:	e9 4b ff ff ff       	jmp    8004e8 <vprintfmt+0x5b>
  80059d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a3:	8d 50 04             	lea    0x4(%eax),%edx
  8005a6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ad:	8b 00                	mov    (%eax),%eax
  8005af:	89 04 24             	mov    %eax,(%esp)
  8005b2:	ff d7                	call   *%edi
  8005b4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8005b7:	e9 fd fe ff ff       	jmp    8004b9 <vprintfmt+0x2c>
  8005bc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 50 04             	lea    0x4(%eax),%edx
  8005c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c8:	8b 00                	mov    (%eax),%eax
  8005ca:	89 c2                	mov    %eax,%edx
  8005cc:	c1 fa 1f             	sar    $0x1f,%edx
  8005cf:	31 d0                	xor    %edx,%eax
  8005d1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005d3:	83 f8 0f             	cmp    $0xf,%eax
  8005d6:	7f 0b                	jg     8005e3 <vprintfmt+0x156>
  8005d8:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	75 20                	jne    800603 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8005e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005e7:	c7 44 24 08 d6 28 80 	movl   $0x8028d6,0x8(%esp)
  8005ee:	00 
  8005ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f3:	89 3c 24             	mov    %edi,(%esp)
  8005f6:	e8 a5 03 00 00       	call   8009a0 <printfmt>
  8005fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fe:	e9 b6 fe ff ff       	jmp    8004b9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800603:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800607:	c7 44 24 08 1b 2d 80 	movl   $0x802d1b,0x8(%esp)
  80060e:	00 
  80060f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800613:	89 3c 24             	mov    %edi,(%esp)
  800616:	e8 85 03 00 00       	call   8009a0 <printfmt>
  80061b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80061e:	e9 96 fe ff ff       	jmp    8004b9 <vprintfmt+0x2c>
  800623:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800626:	89 c3                	mov    %eax,%ebx
  800628:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80062e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 50 04             	lea    0x4(%eax),%edx
  800637:	89 55 14             	mov    %edx,0x14(%ebp)
  80063a:	8b 00                	mov    (%eax),%eax
  80063c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80063f:	85 c0                	test   %eax,%eax
  800641:	b8 df 28 80 00       	mov    $0x8028df,%eax
  800646:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80064a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80064d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800651:	7e 06                	jle    800659 <vprintfmt+0x1cc>
  800653:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800657:	75 13                	jne    80066c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800659:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80065c:	0f be 02             	movsbl (%edx),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	0f 85 a2 00 00 00    	jne    800709 <vprintfmt+0x27c>
  800667:	e9 8f 00 00 00       	jmp    8006fb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80066c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800670:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800673:	89 0c 24             	mov    %ecx,(%esp)
  800676:	e8 70 03 00 00       	call   8009eb <strnlen>
  80067b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80067e:	29 c2                	sub    %eax,%edx
  800680:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800683:	85 d2                	test   %edx,%edx
  800685:	7e d2                	jle    800659 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800687:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80068b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80068e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800691:	89 d3                	mov    %edx,%ebx
  800693:	89 74 24 04          	mov    %esi,0x4(%esp)
  800697:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80069a:	89 04 24             	mov    %eax,(%esp)
  80069d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	83 eb 01             	sub    $0x1,%ebx
  8006a2:	85 db                	test   %ebx,%ebx
  8006a4:	7f ed                	jg     800693 <vprintfmt+0x206>
  8006a6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8006a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8006b0:	eb a7                	jmp    800659 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006b2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b6:	74 1b                	je     8006d3 <vprintfmt+0x246>
  8006b8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8006bb:	83 fa 5e             	cmp    $0x5e,%edx
  8006be:	76 13                	jbe    8006d3 <vprintfmt+0x246>
					putch('?', putdat);
  8006c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8006ce:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006d1:	eb 0d                	jmp    8006e0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8006d3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006da:	89 04 24             	mov    %eax,(%esp)
  8006dd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e0:	83 ef 01             	sub    $0x1,%edi
  8006e3:	0f be 03             	movsbl (%ebx),%eax
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	74 05                	je     8006ef <vprintfmt+0x262>
  8006ea:	83 c3 01             	add    $0x1,%ebx
  8006ed:	eb 31                	jmp    800720 <vprintfmt+0x293>
  8006ef:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006f5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006f8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ff:	7f 36                	jg     800737 <vprintfmt+0x2aa>
  800701:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800704:	e9 b0 fd ff ff       	jmp    8004b9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800709:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80070c:	83 c2 01             	add    $0x1,%edx
  80070f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800712:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800715:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800718:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80071b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80071e:	89 d3                	mov    %edx,%ebx
  800720:	85 f6                	test   %esi,%esi
  800722:	78 8e                	js     8006b2 <vprintfmt+0x225>
  800724:	83 ee 01             	sub    $0x1,%esi
  800727:	79 89                	jns    8006b2 <vprintfmt+0x225>
  800729:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80072c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800732:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800735:	eb c4                	jmp    8006fb <vprintfmt+0x26e>
  800737:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80073a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800741:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800748:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074a:	83 eb 01             	sub    $0x1,%ebx
  80074d:	85 db                	test   %ebx,%ebx
  80074f:	7f ec                	jg     80073d <vprintfmt+0x2b0>
  800751:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800754:	e9 60 fd ff ff       	jmp    8004b9 <vprintfmt+0x2c>
  800759:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80075c:	83 f9 01             	cmp    $0x1,%ecx
  80075f:	7e 16                	jle    800777 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800761:	8b 45 14             	mov    0x14(%ebp),%eax
  800764:	8d 50 08             	lea    0x8(%eax),%edx
  800767:	89 55 14             	mov    %edx,0x14(%ebp)
  80076a:	8b 10                	mov    (%eax),%edx
  80076c:	8b 48 04             	mov    0x4(%eax),%ecx
  80076f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800772:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800775:	eb 32                	jmp    8007a9 <vprintfmt+0x31c>
	else if (lflag)
  800777:	85 c9                	test   %ecx,%ecx
  800779:	74 18                	je     800793 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 50 04             	lea    0x4(%eax),%edx
  800781:	89 55 14             	mov    %edx,0x14(%ebp)
  800784:	8b 00                	mov    (%eax),%eax
  800786:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800789:	89 c1                	mov    %eax,%ecx
  80078b:	c1 f9 1f             	sar    $0x1f,%ecx
  80078e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800791:	eb 16                	jmp    8007a9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 50 04             	lea    0x4(%eax),%edx
  800799:	89 55 14             	mov    %edx,0x14(%ebp)
  80079c:	8b 00                	mov    (%eax),%eax
  80079e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a1:	89 c2                	mov    %eax,%edx
  8007a3:	c1 fa 1f             	sar    $0x1f,%edx
  8007a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007a9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007af:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8007b4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007b8:	0f 89 8a 00 00 00    	jns    800848 <vprintfmt+0x3bb>
				putch('-', putdat);
  8007be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007c9:	ff d7                	call   *%edi
				num = -(long long) num;
  8007cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007ce:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007d1:	f7 d8                	neg    %eax
  8007d3:	83 d2 00             	adc    $0x0,%edx
  8007d6:	f7 da                	neg    %edx
  8007d8:	eb 6e                	jmp    800848 <vprintfmt+0x3bb>
  8007da:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007dd:	89 ca                	mov    %ecx,%edx
  8007df:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e2:	e8 4f fc ff ff       	call   800436 <getuint>
  8007e7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8007ec:	eb 5a                	jmp    800848 <vprintfmt+0x3bb>
  8007ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8007f1:	89 ca                	mov    %ecx,%edx
  8007f3:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f6:	e8 3b fc ff ff       	call   800436 <getuint>
  8007fb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800800:	eb 46                	jmp    800848 <vprintfmt+0x3bb>
  800802:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800805:	89 74 24 04          	mov    %esi,0x4(%esp)
  800809:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800810:	ff d7                	call   *%edi
			putch('x', putdat);
  800812:	89 74 24 04          	mov    %esi,0x4(%esp)
  800816:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80081d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80081f:	8b 45 14             	mov    0x14(%ebp),%eax
  800822:	8d 50 04             	lea    0x4(%eax),%edx
  800825:	89 55 14             	mov    %edx,0x14(%ebp)
  800828:	8b 00                	mov    (%eax),%eax
  80082a:	ba 00 00 00 00       	mov    $0x0,%edx
  80082f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800834:	eb 12                	jmp    800848 <vprintfmt+0x3bb>
  800836:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800839:	89 ca                	mov    %ecx,%edx
  80083b:	8d 45 14             	lea    0x14(%ebp),%eax
  80083e:	e8 f3 fb ff ff       	call   800436 <getuint>
  800843:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800848:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80084c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800850:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800853:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800857:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80085b:	89 04 24             	mov    %eax,(%esp)
  80085e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800862:	89 f2                	mov    %esi,%edx
  800864:	89 f8                	mov    %edi,%eax
  800866:	e8 d5 fa ff ff       	call   800340 <printnum>
  80086b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80086e:	e9 46 fc ff ff       	jmp    8004b9 <vprintfmt+0x2c>
  800873:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)
  80087f:	8b 00                	mov    (%eax),%eax
  800881:	85 c0                	test   %eax,%eax
  800883:	75 24                	jne    8008a9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800885:	c7 44 24 0c f8 29 80 	movl   $0x8029f8,0xc(%esp)
  80088c:	00 
  80088d:	c7 44 24 08 1b 2d 80 	movl   $0x802d1b,0x8(%esp)
  800894:	00 
  800895:	89 74 24 04          	mov    %esi,0x4(%esp)
  800899:	89 3c 24             	mov    %edi,(%esp)
  80089c:	e8 ff 00 00 00       	call   8009a0 <printfmt>
  8008a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8008a4:	e9 10 fc ff ff       	jmp    8004b9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8008a9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8008ac:	7e 29                	jle    8008d7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8008ae:	0f b6 16             	movzbl (%esi),%edx
  8008b1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8008b3:	c7 44 24 0c 30 2a 80 	movl   $0x802a30,0xc(%esp)
  8008ba:	00 
  8008bb:	c7 44 24 08 1b 2d 80 	movl   $0x802d1b,0x8(%esp)
  8008c2:	00 
  8008c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c7:	89 3c 24             	mov    %edi,(%esp)
  8008ca:	e8 d1 00 00 00       	call   8009a0 <printfmt>
  8008cf:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8008d2:	e9 e2 fb ff ff       	jmp    8004b9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  8008d7:	0f b6 16             	movzbl (%esi),%edx
  8008da:	88 10                	mov    %dl,(%eax)
  8008dc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  8008df:	e9 d5 fb ff ff       	jmp    8004b9 <vprintfmt+0x2c>
  8008e4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ee:	89 14 24             	mov    %edx,(%esp)
  8008f1:	ff d7                	call   *%edi
  8008f3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8008f6:	e9 be fb ff ff       	jmp    8004b9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008fb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008ff:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800906:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800908:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80090b:	80 38 25             	cmpb   $0x25,(%eax)
  80090e:	0f 84 a5 fb ff ff    	je     8004b9 <vprintfmt+0x2c>
  800914:	89 c3                	mov    %eax,%ebx
  800916:	eb f0                	jmp    800908 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800918:	83 c4 5c             	add    $0x5c,%esp
  80091b:	5b                   	pop    %ebx
  80091c:	5e                   	pop    %esi
  80091d:	5f                   	pop    %edi
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	83 ec 28             	sub    $0x28,%esp
  800926:	8b 45 08             	mov    0x8(%ebp),%eax
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80092c:	85 c0                	test   %eax,%eax
  80092e:	74 04                	je     800934 <vsnprintf+0x14>
  800930:	85 d2                	test   %edx,%edx
  800932:	7f 07                	jg     80093b <vsnprintf+0x1b>
  800934:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800939:	eb 3b                	jmp    800976 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80093b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80093e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800942:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800945:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80094c:	8b 45 14             	mov    0x14(%ebp),%eax
  80094f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800953:	8b 45 10             	mov    0x10(%ebp),%eax
  800956:	89 44 24 08          	mov    %eax,0x8(%esp)
  80095a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80095d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800961:	c7 04 24 70 04 80 00 	movl   $0x800470,(%esp)
  800968:	e8 20 fb ff ff       	call   80048d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80096d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800970:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800973:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80097e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800981:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800985:	8b 45 10             	mov    0x10(%ebp),%eax
  800988:	89 44 24 08          	mov    %eax,0x8(%esp)
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	e8 82 ff ff ff       	call   800920 <vsnprintf>
	va_end(ap);

	return rc;
}
  80099e:	c9                   	leave  
  80099f:	c3                   	ret    

008009a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009a6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8009b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	89 04 24             	mov    %eax,(%esp)
  8009c1:	e8 c7 fa ff ff       	call   80048d <vprintfmt>
	va_end(ap);
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    
	...

008009d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	80 3a 00             	cmpb   $0x0,(%edx)
  8009de:	74 09                	je     8009e9 <strlen+0x19>
		n++;
  8009e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e7:	75 f7                	jne    8009e0 <strlen+0x10>
		n++;
	return n;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	53                   	push   %ebx
  8009ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f5:	85 c9                	test   %ecx,%ecx
  8009f7:	74 19                	je     800a12 <strnlen+0x27>
  8009f9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8009fc:	74 14                	je     800a12 <strnlen+0x27>
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a03:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a06:	39 c8                	cmp    %ecx,%eax
  800a08:	74 0d                	je     800a17 <strnlen+0x2c>
  800a0a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a0e:	75 f3                	jne    800a03 <strnlen+0x18>
  800a10:	eb 05                	jmp    800a17 <strnlen+0x2c>
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a17:	5b                   	pop    %ebx
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	53                   	push   %ebx
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a24:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a2d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a30:	83 c2 01             	add    $0x1,%edx
  800a33:	84 c9                	test   %cl,%cl
  800a35:	75 f2                	jne    800a29 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a37:	5b                   	pop    %ebx
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	53                   	push   %ebx
  800a3e:	83 ec 08             	sub    $0x8,%esp
  800a41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a44:	89 1c 24             	mov    %ebx,(%esp)
  800a47:	e8 84 ff ff ff       	call   8009d0 <strlen>
	strcpy(dst + len, src);
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a53:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a56:	89 04 24             	mov    %eax,(%esp)
  800a59:	e8 bc ff ff ff       	call   800a1a <strcpy>
	return dst;
}
  800a5e:	89 d8                	mov    %ebx,%eax
  800a60:	83 c4 08             	add    $0x8,%esp
  800a63:	5b                   	pop    %ebx
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a74:	85 f6                	test   %esi,%esi
  800a76:	74 18                	je     800a90 <strncpy+0x2a>
  800a78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800a7d:	0f b6 1a             	movzbl (%edx),%ebx
  800a80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a83:	80 3a 01             	cmpb   $0x1,(%edx)
  800a86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	83 c1 01             	add    $0x1,%ecx
  800a8c:	39 ce                	cmp    %ecx,%esi
  800a8e:	77 ed                	ja     800a7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5e                   	pop    %esi
  800a92:	5d                   	pop    %ebp
  800a93:	c3                   	ret    

00800a94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aa2:	89 f0                	mov    %esi,%eax
  800aa4:	85 c9                	test   %ecx,%ecx
  800aa6:	74 27                	je     800acf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800aa8:	83 e9 01             	sub    $0x1,%ecx
  800aab:	74 1d                	je     800aca <strlcpy+0x36>
  800aad:	0f b6 1a             	movzbl (%edx),%ebx
  800ab0:	84 db                	test   %bl,%bl
  800ab2:	74 16                	je     800aca <strlcpy+0x36>
			*dst++ = *src++;
  800ab4:	88 18                	mov    %bl,(%eax)
  800ab6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ab9:	83 e9 01             	sub    $0x1,%ecx
  800abc:	74 0e                	je     800acc <strlcpy+0x38>
			*dst++ = *src++;
  800abe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ac1:	0f b6 1a             	movzbl (%edx),%ebx
  800ac4:	84 db                	test   %bl,%bl
  800ac6:	75 ec                	jne    800ab4 <strlcpy+0x20>
  800ac8:	eb 02                	jmp    800acc <strlcpy+0x38>
  800aca:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800acc:	c6 00 00             	movb   $0x0,(%eax)
  800acf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ad1:	5b                   	pop    %ebx
  800ad2:	5e                   	pop    %esi
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800adb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ade:	0f b6 01             	movzbl (%ecx),%eax
  800ae1:	84 c0                	test   %al,%al
  800ae3:	74 15                	je     800afa <strcmp+0x25>
  800ae5:	3a 02                	cmp    (%edx),%al
  800ae7:	75 11                	jne    800afa <strcmp+0x25>
		p++, q++;
  800ae9:	83 c1 01             	add    $0x1,%ecx
  800aec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aef:	0f b6 01             	movzbl (%ecx),%eax
  800af2:	84 c0                	test   %al,%al
  800af4:	74 04                	je     800afa <strcmp+0x25>
  800af6:	3a 02                	cmp    (%edx),%al
  800af8:	74 ef                	je     800ae9 <strcmp+0x14>
  800afa:	0f b6 c0             	movzbl %al,%eax
  800afd:	0f b6 12             	movzbl (%edx),%edx
  800b00:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	53                   	push   %ebx
  800b08:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b11:	85 c0                	test   %eax,%eax
  800b13:	74 23                	je     800b38 <strncmp+0x34>
  800b15:	0f b6 1a             	movzbl (%edx),%ebx
  800b18:	84 db                	test   %bl,%bl
  800b1a:	74 25                	je     800b41 <strncmp+0x3d>
  800b1c:	3a 19                	cmp    (%ecx),%bl
  800b1e:	75 21                	jne    800b41 <strncmp+0x3d>
  800b20:	83 e8 01             	sub    $0x1,%eax
  800b23:	74 13                	je     800b38 <strncmp+0x34>
		n--, p++, q++;
  800b25:	83 c2 01             	add    $0x1,%edx
  800b28:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b2b:	0f b6 1a             	movzbl (%edx),%ebx
  800b2e:	84 db                	test   %bl,%bl
  800b30:	74 0f                	je     800b41 <strncmp+0x3d>
  800b32:	3a 19                	cmp    (%ecx),%bl
  800b34:	74 ea                	je     800b20 <strncmp+0x1c>
  800b36:	eb 09                	jmp    800b41 <strncmp+0x3d>
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b3d:	5b                   	pop    %ebx
  800b3e:	5d                   	pop    %ebp
  800b3f:	90                   	nop
  800b40:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b41:	0f b6 02             	movzbl (%edx),%eax
  800b44:	0f b6 11             	movzbl (%ecx),%edx
  800b47:	29 d0                	sub    %edx,%eax
  800b49:	eb f2                	jmp    800b3d <strncmp+0x39>

00800b4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b55:	0f b6 10             	movzbl (%eax),%edx
  800b58:	84 d2                	test   %dl,%dl
  800b5a:	74 18                	je     800b74 <strchr+0x29>
		if (*s == c)
  800b5c:	38 ca                	cmp    %cl,%dl
  800b5e:	75 0a                	jne    800b6a <strchr+0x1f>
  800b60:	eb 17                	jmp    800b79 <strchr+0x2e>
  800b62:	38 ca                	cmp    %cl,%dl
  800b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b68:	74 0f                	je     800b79 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b6a:	83 c0 01             	add    $0x1,%eax
  800b6d:	0f b6 10             	movzbl (%eax),%edx
  800b70:	84 d2                	test   %dl,%dl
  800b72:	75 ee                	jne    800b62 <strchr+0x17>
  800b74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b85:	0f b6 10             	movzbl (%eax),%edx
  800b88:	84 d2                	test   %dl,%dl
  800b8a:	74 18                	je     800ba4 <strfind+0x29>
		if (*s == c)
  800b8c:	38 ca                	cmp    %cl,%dl
  800b8e:	75 0a                	jne    800b9a <strfind+0x1f>
  800b90:	eb 12                	jmp    800ba4 <strfind+0x29>
  800b92:	38 ca                	cmp    %cl,%dl
  800b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800b98:	74 0a                	je     800ba4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800b9a:	83 c0 01             	add    $0x1,%eax
  800b9d:	0f b6 10             	movzbl (%eax),%edx
  800ba0:	84 d2                	test   %dl,%dl
  800ba2:	75 ee                	jne    800b92 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	83 ec 0c             	sub    $0xc,%esp
  800bac:	89 1c 24             	mov    %ebx,(%esp)
  800baf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bb7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800bc0:	85 c9                	test   %ecx,%ecx
  800bc2:	74 30                	je     800bf4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bca:	75 25                	jne    800bf1 <memset+0x4b>
  800bcc:	f6 c1 03             	test   $0x3,%cl
  800bcf:	75 20                	jne    800bf1 <memset+0x4b>
		c &= 0xFF;
  800bd1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	c1 e3 08             	shl    $0x8,%ebx
  800bd9:	89 d6                	mov    %edx,%esi
  800bdb:	c1 e6 18             	shl    $0x18,%esi
  800bde:	89 d0                	mov    %edx,%eax
  800be0:	c1 e0 10             	shl    $0x10,%eax
  800be3:	09 f0                	or     %esi,%eax
  800be5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800be7:	09 d8                	or     %ebx,%eax
  800be9:	c1 e9 02             	shr    $0x2,%ecx
  800bec:	fc                   	cld    
  800bed:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bef:	eb 03                	jmp    800bf4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bf1:	fc                   	cld    
  800bf2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bf4:	89 f8                	mov    %edi,%eax
  800bf6:	8b 1c 24             	mov    (%esp),%ebx
  800bf9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800bfd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c01:	89 ec                	mov    %ebp,%esp
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
  800c0b:	89 34 24             	mov    %esi,(%esp)
  800c0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c12:	8b 45 08             	mov    0x8(%ebp),%eax
  800c15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800c18:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c1b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c1d:	39 c6                	cmp    %eax,%esi
  800c1f:	73 35                	jae    800c56 <memmove+0x51>
  800c21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c24:	39 d0                	cmp    %edx,%eax
  800c26:	73 2e                	jae    800c56 <memmove+0x51>
		s += n;
		d += n;
  800c28:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2a:	f6 c2 03             	test   $0x3,%dl
  800c2d:	75 1b                	jne    800c4a <memmove+0x45>
  800c2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c35:	75 13                	jne    800c4a <memmove+0x45>
  800c37:	f6 c1 03             	test   $0x3,%cl
  800c3a:	75 0e                	jne    800c4a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c3c:	83 ef 04             	sub    $0x4,%edi
  800c3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c42:	c1 e9 02             	shr    $0x2,%ecx
  800c45:	fd                   	std    
  800c46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c48:	eb 09                	jmp    800c53 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c4a:	83 ef 01             	sub    $0x1,%edi
  800c4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c50:	fd                   	std    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c53:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c54:	eb 20                	jmp    800c76 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c5c:	75 15                	jne    800c73 <memmove+0x6e>
  800c5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c64:	75 0d                	jne    800c73 <memmove+0x6e>
  800c66:	f6 c1 03             	test   $0x3,%cl
  800c69:	75 08                	jne    800c73 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800c6b:	c1 e9 02             	shr    $0x2,%ecx
  800c6e:	fc                   	cld    
  800c6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c71:	eb 03                	jmp    800c76 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c73:	fc                   	cld    
  800c74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c76:	8b 34 24             	mov    (%esp),%esi
  800c79:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c7d:	89 ec                	mov    %ebp,%esp
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    

00800c81 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c87:	8b 45 10             	mov    0x10(%ebp),%eax
  800c8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c95:	8b 45 08             	mov    0x8(%ebp),%eax
  800c98:	89 04 24             	mov    %eax,(%esp)
  800c9b:	e8 65 ff ff ff       	call   800c05 <memmove>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	8b 75 08             	mov    0x8(%ebp),%esi
  800cab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cb1:	85 c9                	test   %ecx,%ecx
  800cb3:	74 36                	je     800ceb <memcmp+0x49>
		if (*s1 != *s2)
  800cb5:	0f b6 06             	movzbl (%esi),%eax
  800cb8:	0f b6 1f             	movzbl (%edi),%ebx
  800cbb:	38 d8                	cmp    %bl,%al
  800cbd:	74 20                	je     800cdf <memcmp+0x3d>
  800cbf:	eb 14                	jmp    800cd5 <memcmp+0x33>
  800cc1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800cc6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ccb:	83 c2 01             	add    $0x1,%edx
  800cce:	83 e9 01             	sub    $0x1,%ecx
  800cd1:	38 d8                	cmp    %bl,%al
  800cd3:	74 12                	je     800ce7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800cd5:	0f b6 c0             	movzbl %al,%eax
  800cd8:	0f b6 db             	movzbl %bl,%ebx
  800cdb:	29 d8                	sub    %ebx,%eax
  800cdd:	eb 11                	jmp    800cf0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cdf:	83 e9 01             	sub    $0x1,%ecx
  800ce2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce7:	85 c9                	test   %ecx,%ecx
  800ce9:	75 d6                	jne    800cc1 <memcmp+0x1f>
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800cfb:	89 c2                	mov    %eax,%edx
  800cfd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d00:	39 d0                	cmp    %edx,%eax
  800d02:	73 15                	jae    800d19 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d08:	38 08                	cmp    %cl,(%eax)
  800d0a:	75 06                	jne    800d12 <memfind+0x1d>
  800d0c:	eb 0b                	jmp    800d19 <memfind+0x24>
  800d0e:	38 08                	cmp    %cl,(%eax)
  800d10:	74 07                	je     800d19 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d12:	83 c0 01             	add    $0x1,%eax
  800d15:	39 c2                	cmp    %eax,%edx
  800d17:	77 f5                	ja     800d0e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 04             	sub    $0x4,%esp
  800d24:	8b 55 08             	mov    0x8(%ebp),%edx
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d2a:	0f b6 02             	movzbl (%edx),%eax
  800d2d:	3c 20                	cmp    $0x20,%al
  800d2f:	74 04                	je     800d35 <strtol+0x1a>
  800d31:	3c 09                	cmp    $0x9,%al
  800d33:	75 0e                	jne    800d43 <strtol+0x28>
		s++;
  800d35:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d38:	0f b6 02             	movzbl (%edx),%eax
  800d3b:	3c 20                	cmp    $0x20,%al
  800d3d:	74 f6                	je     800d35 <strtol+0x1a>
  800d3f:	3c 09                	cmp    $0x9,%al
  800d41:	74 f2                	je     800d35 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d43:	3c 2b                	cmp    $0x2b,%al
  800d45:	75 0c                	jne    800d53 <strtol+0x38>
		s++;
  800d47:	83 c2 01             	add    $0x1,%edx
  800d4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d51:	eb 15                	jmp    800d68 <strtol+0x4d>
	else if (*s == '-')
  800d53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d5a:	3c 2d                	cmp    $0x2d,%al
  800d5c:	75 0a                	jne    800d68 <strtol+0x4d>
		s++, neg = 1;
  800d5e:	83 c2 01             	add    $0x1,%edx
  800d61:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d68:	85 db                	test   %ebx,%ebx
  800d6a:	0f 94 c0             	sete   %al
  800d6d:	74 05                	je     800d74 <strtol+0x59>
  800d6f:	83 fb 10             	cmp    $0x10,%ebx
  800d72:	75 18                	jne    800d8c <strtol+0x71>
  800d74:	80 3a 30             	cmpb   $0x30,(%edx)
  800d77:	75 13                	jne    800d8c <strtol+0x71>
  800d79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800d7d:	8d 76 00             	lea    0x0(%esi),%esi
  800d80:	75 0a                	jne    800d8c <strtol+0x71>
		s += 2, base = 16;
  800d82:	83 c2 02             	add    $0x2,%edx
  800d85:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d8a:	eb 15                	jmp    800da1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d8c:	84 c0                	test   %al,%al
  800d8e:	66 90                	xchg   %ax,%ax
  800d90:	74 0f                	je     800da1 <strtol+0x86>
  800d92:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800d97:	80 3a 30             	cmpb   $0x30,(%edx)
  800d9a:	75 05                	jne    800da1 <strtol+0x86>
		s++, base = 8;
  800d9c:	83 c2 01             	add    $0x1,%edx
  800d9f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
  800da6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800da8:	0f b6 0a             	movzbl (%edx),%ecx
  800dab:	89 cf                	mov    %ecx,%edi
  800dad:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800db0:	80 fb 09             	cmp    $0x9,%bl
  800db3:	77 08                	ja     800dbd <strtol+0xa2>
			dig = *s - '0';
  800db5:	0f be c9             	movsbl %cl,%ecx
  800db8:	83 e9 30             	sub    $0x30,%ecx
  800dbb:	eb 1e                	jmp    800ddb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dbd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800dc0:	80 fb 19             	cmp    $0x19,%bl
  800dc3:	77 08                	ja     800dcd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800dc5:	0f be c9             	movsbl %cl,%ecx
  800dc8:	83 e9 57             	sub    $0x57,%ecx
  800dcb:	eb 0e                	jmp    800ddb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800dcd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800dd0:	80 fb 19             	cmp    $0x19,%bl
  800dd3:	77 15                	ja     800dea <strtol+0xcf>
			dig = *s - 'A' + 10;
  800dd5:	0f be c9             	movsbl %cl,%ecx
  800dd8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ddb:	39 f1                	cmp    %esi,%ecx
  800ddd:	7d 0b                	jge    800dea <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ddf:	83 c2 01             	add    $0x1,%edx
  800de2:	0f af c6             	imul   %esi,%eax
  800de5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800de8:	eb be                	jmp    800da8 <strtol+0x8d>
  800dea:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800dec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800df0:	74 05                	je     800df7 <strtol+0xdc>
		*endptr = (char *) s;
  800df2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800df5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800df7:	89 ca                	mov    %ecx,%edx
  800df9:	f7 da                	neg    %edx
  800dfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800dff:	0f 45 c2             	cmovne %edx,%eax
}
  800e02:	83 c4 04             	add    $0x4,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
	...

00800e0c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	83 ec 48             	sub    $0x48,%esp
  800e12:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e15:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e18:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800e1b:	89 c6                	mov    %eax,%esi
  800e1d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e20:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800e22:	8b 7d 10             	mov    0x10(%ebp),%edi
  800e25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2b:	51                   	push   %ecx
  800e2c:	52                   	push   %edx
  800e2d:	53                   	push   %ebx
  800e2e:	54                   	push   %esp
  800e2f:	55                   	push   %ebp
  800e30:	56                   	push   %esi
  800e31:	57                   	push   %edi
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8d 35 3c 0e 80 00    	lea    0x800e3c,%esi
  800e3a:	0f 34                	sysenter 

00800e3c <.after_sysenter_label>:
  800e3c:	5f                   	pop    %edi
  800e3d:	5e                   	pop    %esi
  800e3e:	5d                   	pop    %ebp
  800e3f:	5c                   	pop    %esp
  800e40:	5b                   	pop    %ebx
  800e41:	5a                   	pop    %edx
  800e42:	59                   	pop    %ecx
  800e43:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800e45:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e49:	74 28                	je     800e73 <.after_sysenter_label+0x37>
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	7e 24                	jle    800e73 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e53:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800e57:	c7 44 24 08 40 2c 80 	movl   $0x802c40,0x8(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800e66:	00 
  800e67:	c7 04 24 5d 2c 80 00 	movl   $0x802c5d,(%esp)
  800e6e:	e8 91 11 00 00       	call   802004 <_panic>

	return ret;
}
  800e73:	89 d0                	mov    %edx,%eax
  800e75:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e78:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7e:	89 ec                	mov    %ebp,%esp
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    

00800e82 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800e88:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e8f:	00 
  800e90:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e97:	00 
  800e98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e9f:	00 
  800ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea3:	89 04 24             	mov    %eax,(%esp)
  800ea6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea9:	ba 00 00 00 00       	mov    $0x0,%edx
  800eae:	b8 10 00 00 00       	mov    $0x10,%eax
  800eb3:	e8 54 ff ff ff       	call   800e0c <syscall>
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800ec0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ecf:	00 
  800ed0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ed7:	00 
  800ed8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800edf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800eee:	e8 19 ff ff ff       	call   800e0c <syscall>
}
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800efb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f02:	00 
  800f03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f12:	00 
  800f13:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1d:	ba 01 00 00 00       	mov    $0x1,%edx
  800f22:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f27:	e8 e0 fe ff ff       	call   800e0c <syscall>
}
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    

00800f2e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f34:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3b:	00 
  800f3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f3f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f43:	8b 45 10             	mov    0x10(%ebp),%eax
  800f46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f53:	ba 00 00 00 00       	mov    $0x0,%edx
  800f58:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f5d:	e8 aa fe ff ff       	call   800e0c <syscall>
}
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f71:	00 
  800f72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f79:	00 
  800f7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f81:	00 
  800f82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f85:	89 04 24             	mov    %eax,(%esp)
  800f88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f8b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f90:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f95:	e8 72 fe ff ff       	call   800e0c <syscall>
}
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    

00800f9c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800fa2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fa9:	00 
  800faa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb1:	00 
  800fb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fb9:	00 
  800fba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fbd:	89 04 24             	mov    %eax,(%esp)
  800fc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fc8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fcd:	e8 3a fe ff ff       	call   800e0c <syscall>
}
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800fda:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe1:	00 
  800fe2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fe9:	00 
  800fea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff1:	00 
  800ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff5:	89 04 24             	mov    %eax,(%esp)
  800ff8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ffb:	ba 01 00 00 00       	mov    $0x1,%edx
  801000:	b8 09 00 00 00       	mov    $0x9,%eax
  801005:	e8 02 fe ff ff       	call   800e0c <syscall>
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801012:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801019:	00 
  80101a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801021:	00 
  801022:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801029:	00 
  80102a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80102d:	89 04 24             	mov    %eax,(%esp)
  801030:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801033:	ba 01 00 00 00       	mov    $0x1,%edx
  801038:	b8 07 00 00 00       	mov    $0x7,%eax
  80103d:	e8 ca fd ff ff       	call   800e0c <syscall>
}
  801042:	c9                   	leave  
  801043:	c3                   	ret    

00801044 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  80104a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801051:	00 
  801052:	8b 45 18             	mov    0x18(%ebp),%eax
  801055:	0b 45 14             	or     0x14(%ebp),%eax
  801058:	89 44 24 08          	mov    %eax,0x8(%esp)
  80105c:	8b 45 10             	mov    0x10(%ebp),%eax
  80105f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801063:	8b 45 0c             	mov    0xc(%ebp),%eax
  801066:	89 04 24             	mov    %eax,(%esp)
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106c:	ba 01 00 00 00       	mov    $0x1,%edx
  801071:	b8 06 00 00 00       	mov    $0x6,%eax
  801076:	e8 91 fd ff ff       	call   800e0c <syscall>
}
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801083:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80108a:	00 
  80108b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801092:	00 
  801093:	8b 45 10             	mov    0x10(%ebp),%eax
  801096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80109a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80109d:	89 04 24             	mov    %eax,(%esp)
  8010a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a3:	ba 01 00 00 00       	mov    $0x1,%edx
  8010a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8010ad:	e8 5a fd ff ff       	call   800e0c <syscall>
}
  8010b2:	c9                   	leave  
  8010b3:	c3                   	ret    

008010b4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8010ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010c1:	00 
  8010c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010c9:	00 
  8010ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010d1:	00 
  8010d2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010de:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8010e8:	e8 1f fd ff ff       	call   800e0c <syscall>
}
  8010ed:	c9                   	leave  
  8010ee:	c3                   	ret    

008010ef <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8010f5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010fc:	00 
  8010fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801104:	00 
  801105:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80110c:	00 
  80110d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801110:	89 04 24             	mov    %eax,(%esp)
  801113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801116:	ba 00 00 00 00       	mov    $0x0,%edx
  80111b:	b8 04 00 00 00       	mov    $0x4,%eax
  801120:	e8 e7 fc ff ff       	call   800e0c <syscall>
}
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801127:	55                   	push   %ebp
  801128:	89 e5                	mov    %esp,%ebp
  80112a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80112d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801134:	00 
  801135:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80113c:	00 
  80113d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801144:	00 
  801145:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80114c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801151:	ba 00 00 00 00       	mov    $0x0,%edx
  801156:	b8 02 00 00 00       	mov    $0x2,%eax
  80115b:	e8 ac fc ff ff       	call   800e0c <syscall>
}
  801160:	c9                   	leave  
  801161:	c3                   	ret    

00801162 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801168:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80116f:	00 
  801170:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801177:	00 
  801178:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80117f:	00 
  801180:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801187:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118a:	ba 01 00 00 00       	mov    $0x1,%edx
  80118f:	b8 03 00 00 00       	mov    $0x3,%eax
  801194:	e8 73 fc ff ff       	call   800e0c <syscall>
}
  801199:	c9                   	leave  
  80119a:	c3                   	ret    

0080119b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8011a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011a8:	00 
  8011a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011b0:	00 
  8011b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011b8:	00 
  8011b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ca:	b8 01 00 00 00       	mov    $0x1,%eax
  8011cf:	e8 38 fc ff ff       	call   800e0c <syscall>
}
  8011d4:	c9                   	leave  
  8011d5:	c3                   	ret    

008011d6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8011dc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011e3:	00 
  8011e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011eb:	00 
  8011ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011f3:	00 
  8011f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f7:	89 04 24             	mov    %eax,(%esp)
  8011fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801202:	b8 00 00 00 00       	mov    $0x0,%eax
  801207:	e8 00 fc ff ff       	call   800e0c <syscall>
}
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    
	...

00801210 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	05 00 00 00 30       	add    $0x30000000,%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	89 04 24             	mov    %eax,(%esp)
  80122c:	e8 df ff ff ff       	call   801210 <fd2num>
  801231:	05 20 00 0d 00       	add    $0xd0020,%eax
  801236:	c1 e0 0c             	shl    $0xc,%eax
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	57                   	push   %edi
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801244:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801249:	a8 01                	test   $0x1,%al
  80124b:	74 36                	je     801283 <fd_alloc+0x48>
  80124d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801252:	a8 01                	test   $0x1,%al
  801254:	74 2d                	je     801283 <fd_alloc+0x48>
  801256:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80125b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801260:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801265:	89 c3                	mov    %eax,%ebx
  801267:	89 c2                	mov    %eax,%edx
  801269:	c1 ea 16             	shr    $0x16,%edx
  80126c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 14                	je     801288 <fd_alloc+0x4d>
  801274:	89 c2                	mov    %eax,%edx
  801276:	c1 ea 0c             	shr    $0xc,%edx
  801279:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80127c:	f6 c2 01             	test   $0x1,%dl
  80127f:	75 10                	jne    801291 <fd_alloc+0x56>
  801281:	eb 05                	jmp    801288 <fd_alloc+0x4d>
  801283:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801288:	89 1f                	mov    %ebx,(%edi)
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80128f:	eb 17                	jmp    8012a8 <fd_alloc+0x6d>
  801291:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801296:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129b:	75 c8                	jne    801265 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80129d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8012a3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012a8:	5b                   	pop    %ebx
  8012a9:	5e                   	pop    %esi
  8012aa:	5f                   	pop    %edi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	83 f8 1f             	cmp    $0x1f,%eax
  8012b6:	77 36                	ja     8012ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012bd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	c1 ea 16             	shr    $0x16,%edx
  8012c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012cc:	f6 c2 01             	test   $0x1,%dl
  8012cf:	74 1d                	je     8012ee <fd_lookup+0x41>
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	c1 ea 0c             	shr    $0xc,%edx
  8012d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012dd:	f6 c2 01             	test   $0x1,%dl
  8012e0:	74 0c                	je     8012ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e5:	89 02                	mov    %eax,(%edx)
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8012ec:	eb 05                	jmp    8012f3 <fd_lookup+0x46>
  8012ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	89 04 24             	mov    %eax,(%esp)
  801308:	e8 a0 ff ff ff       	call   8012ad <fd_lookup>
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 0e                	js     80131f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801311:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	89 50 04             	mov    %edx,0x4(%eax)
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	56                   	push   %esi
  801325:	53                   	push   %ebx
  801326:	83 ec 10             	sub    $0x10,%esp
  801329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80132f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801334:	b8 04 30 80 00       	mov    $0x803004,%eax
  801339:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80133f:	75 11                	jne    801352 <dev_lookup+0x31>
  801341:	eb 04                	jmp    801347 <dev_lookup+0x26>
  801343:	39 08                	cmp    %ecx,(%eax)
  801345:	75 10                	jne    801357 <dev_lookup+0x36>
			*dev = devtab[i];
  801347:	89 03                	mov    %eax,(%ebx)
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80134e:	66 90                	xchg   %ax,%ax
  801350:	eb 36                	jmp    801388 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801352:	be e8 2c 80 00       	mov    $0x802ce8,%esi
  801357:	83 c2 01             	add    $0x1,%edx
  80135a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80135d:	85 c0                	test   %eax,%eax
  80135f:	75 e2                	jne    801343 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801361:	a1 18 40 80 00       	mov    0x804018,%eax
  801366:	8b 40 48             	mov    0x48(%eax),%eax
  801369:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	c7 04 24 6c 2c 80 00 	movl   $0x802c6c,(%esp)
  801378:	e8 5c ef ff ff       	call   8002d9 <cprintf>
	*dev = 0;
  80137d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801383:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	53                   	push   %ebx
  801393:	83 ec 24             	sub    $0x24,%esp
  801396:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801399:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	89 04 24             	mov    %eax,(%esp)
  8013a6:	e8 02 ff ff ff       	call   8012ad <fd_lookup>
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 53                	js     801402 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b9:	8b 00                	mov    (%eax),%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 5e ff ff ff       	call   801321 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 3b                	js     801402 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013cf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013d3:	74 2d                	je     801402 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013df:	00 00 00 
	stat->st_isdir = 0;
  8013e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e9:	00 00 00 
	stat->st_dev = dev;
  8013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fc:	89 14 24             	mov    %edx,(%esp)
  8013ff:	ff 50 14             	call   *0x14(%eax)
}
  801402:	83 c4 24             	add    $0x24,%esp
  801405:	5b                   	pop    %ebx
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	53                   	push   %ebx
  80140c:	83 ec 24             	sub    $0x24,%esp
  80140f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801412:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801415:	89 44 24 04          	mov    %eax,0x4(%esp)
  801419:	89 1c 24             	mov    %ebx,(%esp)
  80141c:	e8 8c fe ff ff       	call   8012ad <fd_lookup>
  801421:	85 c0                	test   %eax,%eax
  801423:	78 5f                	js     801484 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801425:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142f:	8b 00                	mov    (%eax),%eax
  801431:	89 04 24             	mov    %eax,(%esp)
  801434:	e8 e8 fe ff ff       	call   801321 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 47                	js     801484 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801440:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801444:	75 23                	jne    801469 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801446:	a1 18 40 80 00       	mov    0x804018,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80144b:	8b 40 48             	mov    0x48(%eax),%eax
  80144e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801452:	89 44 24 04          	mov    %eax,0x4(%esp)
  801456:	c7 04 24 8c 2c 80 00 	movl   $0x802c8c,(%esp)
  80145d:	e8 77 ee ff ff       	call   8002d9 <cprintf>
  801462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801467:	eb 1b                	jmp    801484 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146c:	8b 48 18             	mov    0x18(%eax),%ecx
  80146f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801474:	85 c9                	test   %ecx,%ecx
  801476:	74 0c                	je     801484 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147f:	89 14 24             	mov    %edx,(%esp)
  801482:	ff d1                	call   *%ecx
}
  801484:	83 c4 24             	add    $0x24,%esp
  801487:	5b                   	pop    %ebx
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 24             	sub    $0x24,%esp
  801491:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801494:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	89 1c 24             	mov    %ebx,(%esp)
  80149e:	e8 0a fe ff ff       	call   8012ad <fd_lookup>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 66                	js     80150d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b1:	8b 00                	mov    (%eax),%eax
  8014b3:	89 04 24             	mov    %eax,(%esp)
  8014b6:	e8 66 fe ff ff       	call   801321 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 4e                	js     80150d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014c6:	75 23                	jne    8014eb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c8:	a1 18 40 80 00       	mov    0x804018,%eax
  8014cd:	8b 40 48             	mov    0x48(%eax),%eax
  8014d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	c7 04 24 ad 2c 80 00 	movl   $0x802cad,(%esp)
  8014df:	e8 f5 ed ff ff       	call   8002d9 <cprintf>
  8014e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014e9:	eb 22                	jmp    80150d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ee:	8b 48 0c             	mov    0xc(%eax),%ecx
  8014f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014f6:	85 c9                	test   %ecx,%ecx
  8014f8:	74 13                	je     80150d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8014fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	89 14 24             	mov    %edx,(%esp)
  80150b:	ff d1                	call   *%ecx
}
  80150d:	83 c4 24             	add    $0x24,%esp
  801510:	5b                   	pop    %ebx
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 24             	sub    $0x24,%esp
  80151a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801520:	89 44 24 04          	mov    %eax,0x4(%esp)
  801524:	89 1c 24             	mov    %ebx,(%esp)
  801527:	e8 81 fd ff ff       	call   8012ad <fd_lookup>
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 6b                	js     80159b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801533:	89 44 24 04          	mov    %eax,0x4(%esp)
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	8b 00                	mov    (%eax),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 dd fd ff ff       	call   801321 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801544:	85 c0                	test   %eax,%eax
  801546:	78 53                	js     80159b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801548:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80154b:	8b 42 08             	mov    0x8(%edx),%eax
  80154e:	83 e0 03             	and    $0x3,%eax
  801551:	83 f8 01             	cmp    $0x1,%eax
  801554:	75 23                	jne    801579 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801556:	a1 18 40 80 00       	mov    0x804018,%eax
  80155b:	8b 40 48             	mov    0x48(%eax),%eax
  80155e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801562:	89 44 24 04          	mov    %eax,0x4(%esp)
  801566:	c7 04 24 ca 2c 80 00 	movl   $0x802cca,(%esp)
  80156d:	e8 67 ed ff ff       	call   8002d9 <cprintf>
  801572:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801577:	eb 22                	jmp    80159b <read+0x88>
	}
	if (!dev->dev_read)
  801579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157c:	8b 48 08             	mov    0x8(%eax),%ecx
  80157f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801584:	85 c9                	test   %ecx,%ecx
  801586:	74 13                	je     80159b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801588:	8b 45 10             	mov    0x10(%ebp),%eax
  80158b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80158f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801592:	89 44 24 04          	mov    %eax,0x4(%esp)
  801596:	89 14 24             	mov    %edx,(%esp)
  801599:	ff d1                	call   *%ecx
}
  80159b:	83 c4 24             	add    $0x24,%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	57                   	push   %edi
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 1c             	sub    $0x1c,%esp
  8015aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bf:	85 f6                	test   %esi,%esi
  8015c1:	74 29                	je     8015ec <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c3:	89 f0                	mov    %esi,%eax
  8015c5:	29 d0                	sub    %edx,%eax
  8015c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015cb:	03 55 0c             	add    0xc(%ebp),%edx
  8015ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015d2:	89 3c 24             	mov    %edi,(%esp)
  8015d5:	e8 39 ff ff ff       	call   801513 <read>
		if (m < 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 0e                	js     8015ec <readn+0x4b>
			return m;
		if (m == 0)
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 08                	je     8015ea <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e2:	01 c3                	add    %eax,%ebx
  8015e4:	89 da                	mov    %ebx,%edx
  8015e6:	39 f3                	cmp    %esi,%ebx
  8015e8:	72 d9                	jb     8015c3 <readn+0x22>
  8015ea:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ec:	83 c4 1c             	add    $0x1c,%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 28             	sub    $0x28,%esp
  8015fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801600:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801603:	89 34 24             	mov    %esi,(%esp)
  801606:	e8 05 fc ff ff       	call   801210 <fd2num>
  80160b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80160e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801612:	89 04 24             	mov    %eax,(%esp)
  801615:	e8 93 fc ff ff       	call   8012ad <fd_lookup>
  80161a:	89 c3                	mov    %eax,%ebx
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 05                	js     801625 <fd_close+0x31>
  801620:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801623:	74 0e                	je     801633 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801625:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801629:	b8 00 00 00 00       	mov    $0x0,%eax
  80162e:	0f 44 d8             	cmove  %eax,%ebx
  801631:	eb 3d                	jmp    801670 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	8b 06                	mov    (%esi),%eax
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 dd fc ff ff       	call   801321 <dev_lookup>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	85 c0                	test   %eax,%eax
  801648:	78 16                	js     801660 <fd_close+0x6c>
		if (dev->dev_close)
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	8b 40 10             	mov    0x10(%eax),%eax
  801650:	bb 00 00 00 00       	mov    $0x0,%ebx
  801655:	85 c0                	test   %eax,%eax
  801657:	74 07                	je     801660 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801659:	89 34 24             	mov    %esi,(%esp)
  80165c:	ff d0                	call   *%eax
  80165e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801660:	89 74 24 04          	mov    %esi,0x4(%esp)
  801664:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166b:	e8 9c f9 ff ff       	call   80100c <sys_page_unmap>
	return r;
}
  801670:	89 d8                	mov    %ebx,%eax
  801672:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801675:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801678:	89 ec                	mov    %ebp,%esp
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801685:	89 44 24 04          	mov    %eax,0x4(%esp)
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 19 fc ff ff       	call   8012ad <fd_lookup>
  801694:	85 c0                	test   %eax,%eax
  801696:	78 13                	js     8016ab <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801698:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80169f:	00 
  8016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 49 ff ff ff       	call   8015f4 <fd_close>
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 18             	sub    $0x18,%esp
  8016b3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016b6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016c0:	00 
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 78 03 00 00       	call   801a44 <open>
  8016cc:	89 c3                	mov    %eax,%ebx
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 1b                	js     8016ed <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	89 1c 24             	mov    %ebx,(%esp)
  8016dc:	e8 ae fc ff ff       	call   80138f <fstat>
  8016e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e3:	89 1c 24             	mov    %ebx,(%esp)
  8016e6:	e8 91 ff ff ff       	call   80167c <close>
  8016eb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8016ed:	89 d8                	mov    %ebx,%eax
  8016ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016f5:	89 ec                	mov    %ebp,%esp
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 14             	sub    $0x14,%esp
  801700:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801705:	89 1c 24             	mov    %ebx,(%esp)
  801708:	e8 6f ff ff ff       	call   80167c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80170d:	83 c3 01             	add    $0x1,%ebx
  801710:	83 fb 20             	cmp    $0x20,%ebx
  801713:	75 f0                	jne    801705 <close_all+0xc>
		close(i);
}
  801715:	83 c4 14             	add    $0x14,%esp
  801718:	5b                   	pop    %ebx
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 58             	sub    $0x58,%esp
  801721:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801724:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801727:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80172a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80172d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801730:	89 44 24 04          	mov    %eax,0x4(%esp)
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	e8 6e fb ff ff       	call   8012ad <fd_lookup>
  80173f:	89 c3                	mov    %eax,%ebx
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 e0 00 00 00    	js     801829 <dup+0x10e>
		return r;
	close(newfdnum);
  801749:	89 3c 24             	mov    %edi,(%esp)
  80174c:	e8 2b ff ff ff       	call   80167c <close>

	newfd = INDEX2FD(newfdnum);
  801751:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801757:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80175a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175d:	89 04 24             	mov    %eax,(%esp)
  801760:	e8 bb fa ff ff       	call   801220 <fd2data>
  801765:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801767:	89 34 24             	mov    %esi,(%esp)
  80176a:	e8 b1 fa ff ff       	call   801220 <fd2data>
  80176f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801772:	89 da                	mov    %ebx,%edx
  801774:	89 d8                	mov    %ebx,%eax
  801776:	c1 e8 16             	shr    $0x16,%eax
  801779:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801780:	a8 01                	test   $0x1,%al
  801782:	74 43                	je     8017c7 <dup+0xac>
  801784:	c1 ea 0c             	shr    $0xc,%edx
  801787:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80178e:	a8 01                	test   $0x1,%al
  801790:	74 35                	je     8017c7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801792:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801799:	25 07 0e 00 00       	and    $0xe07,%eax
  80179e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b0:	00 
  8017b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 83 f8 ff ff       	call   801044 <sys_page_map>
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 3f                	js     801806 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	c1 ea 0c             	shr    $0xc,%edx
  8017cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017d6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017eb:	00 
  8017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f7:	e8 48 f8 ff ff       	call   801044 <sys_page_map>
  8017fc:	89 c3                	mov    %eax,%ebx
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 04                	js     801806 <dup+0xeb>
  801802:	89 fb                	mov    %edi,%ebx
  801804:	eb 23                	jmp    801829 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80180a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801811:	e8 f6 f7 ff ff       	call   80100c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801816:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801824:	e8 e3 f7 ff ff       	call   80100c <sys_page_unmap>
	return r;
}
  801829:	89 d8                	mov    %ebx,%eax
  80182b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80182e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801831:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801834:	89 ec                	mov    %ebp,%esp
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 18             	sub    $0x18,%esp
  80183e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801841:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801844:	89 c3                	mov    %eax,%ebx
  801846:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801848:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80184f:	75 11                	jne    801862 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801851:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801858:	e8 03 08 00 00       	call   802060 <ipc_find_env>
  80185d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801862:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801869:	00 
  80186a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801871:	00 
  801872:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801876:	a1 00 40 80 00       	mov    0x804000,%eax
  80187b:	89 04 24             	mov    %eax,(%esp)
  80187e:	e8 21 08 00 00       	call   8020a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801883:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80188a:	00 
  80188b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80188f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801896:	e8 74 08 00 00       	call   80210f <ipc_recv>
}
  80189b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80189e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018a1:	89 ec                	mov    %ebp,%esp
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c8:	e8 6b ff ff ff       	call   801838 <fsipc>
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018db:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ea:	e8 49 ff ff ff       	call   801838 <fsipc>
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801901:	e8 32 ff ff ff       	call   801838 <fsipc>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	53                   	push   %ebx
  80190c:	83 ec 14             	sub    $0x14,%esp
  80190f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	8b 40 0c             	mov    0xc(%eax),%eax
  801918:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80191d:	ba 00 00 00 00       	mov    $0x0,%edx
  801922:	b8 05 00 00 00       	mov    $0x5,%eax
  801927:	e8 0c ff ff ff       	call   801838 <fsipc>
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 2b                	js     80195b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801930:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801937:	00 
  801938:	89 1c 24             	mov    %ebx,(%esp)
  80193b:	e8 da f0 ff ff       	call   800a1a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801940:	a1 80 50 80 00       	mov    0x805080,%eax
  801945:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80194b:	a1 84 50 80 00       	mov    0x805084,%eax
  801950:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801956:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80195b:	83 c4 14             	add    $0x14,%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 18             	sub    $0x18,%esp
  801967:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80196a:	8b 55 08             	mov    0x8(%ebp),%edx
  80196d:	8b 52 0c             	mov    0xc(%edx),%edx
  801970:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801976:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80197b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801980:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801985:	0f 47 c2             	cmova  %edx,%eax
  801988:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801993:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80199a:	e8 66 f2 ff ff       	call   800c05 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a9:	e8 8a fe ff ff       	call   801838 <fsipc>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8019c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d4:	e8 5f fe ff ff       	call   801838 <fsipc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 17                	js     8019f6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019ea:	00 
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 0f f2 ff ff       	call   800c05 <memmove>
  return r;	
}
  8019f6:	89 d8                	mov    %ebx,%eax
  8019f8:	83 c4 14             	add    $0x14,%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	53                   	push   %ebx
  801a02:	83 ec 14             	sub    $0x14,%esp
  801a05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a08:	89 1c 24             	mov    %ebx,(%esp)
  801a0b:	e8 c0 ef ff ff       	call   8009d0 <strlen>
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801a17:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801a1d:	7f 1f                	jg     801a3e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a23:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a2a:	e8 eb ef ff ff       	call   800a1a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a34:	b8 07 00 00 00       	mov    $0x7,%eax
  801a39:	e8 fa fd ff ff       	call   801838 <fsipc>
}
  801a3e:	83 c4 14             	add    $0x14,%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 28             	sub    $0x28,%esp
  801a4a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a4d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a50:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801a53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 dd f7 ff ff       	call   80123b <fd_alloc>
  801a5e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a60:	85 c0                	test   %eax,%eax
  801a62:	0f 88 89 00 00 00    	js     801af1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a68:	89 34 24             	mov    %esi,(%esp)
  801a6b:	e8 60 ef ff ff       	call   8009d0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a70:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a75:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a7a:	7f 75                	jg     801af1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a80:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a87:	e8 8e ef ff ff       	call   800a1a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801a94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a97:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9c:	e8 97 fd ff ff       	call   801838 <fsipc>
  801aa1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	78 0f                	js     801ab6 <open+0x72>
  return fd2num(fd);
  801aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 5e f7 ff ff       	call   801210 <fd2num>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	eb 3b                	jmp    801af1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801ab6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801abd:	00 
  801abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac1:	89 04 24             	mov    %eax,(%esp)
  801ac4:	e8 2b fb ff ff       	call   8015f4 <fd_close>
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	74 24                	je     801af1 <open+0xad>
  801acd:	c7 44 24 0c f4 2c 80 	movl   $0x802cf4,0xc(%esp)
  801ad4:	00 
  801ad5:	c7 44 24 08 09 2d 80 	movl   $0x802d09,0x8(%esp)
  801adc:	00 
  801add:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801ae4:	00 
  801ae5:	c7 04 24 1e 2d 80 00 	movl   $0x802d1e,(%esp)
  801aec:	e8 13 05 00 00       	call   802004 <_panic>
  return r;
}
  801af1:	89 d8                	mov    %ebx,%eax
  801af3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801af6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801af9:	89 ec                	mov    %ebp,%esp
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    
  801afd:	00 00                	add    %al,(%eax)
	...

00801b00 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b06:	c7 44 24 04 29 2d 80 	movl   $0x802d29,0x4(%esp)
  801b0d:	00 
  801b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b11:	89 04 24             	mov    %eax,(%esp)
  801b14:	e8 01 ef ff ff       	call   800a1a <strcpy>
	return 0;
}
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	53                   	push   %ebx
  801b24:	83 ec 14             	sub    $0x14,%esp
  801b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b2a:	89 1c 24             	mov    %ebx,(%esp)
  801b2d:	e8 6a 06 00 00       	call   80219c <pageref>
  801b32:	89 c2                	mov    %eax,%edx
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
  801b39:	83 fa 01             	cmp    $0x1,%edx
  801b3c:	75 0b                	jne    801b49 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801b3e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 b9 02 00 00       	call   801e02 <nsipc_close>
	else
		return 0;
}
  801b49:	83 c4 14             	add    $0x14,%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b5c:	00 
  801b5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b71:	89 04 24             	mov    %eax,(%esp)
  801b74:	e8 c5 02 00 00       	call   801e3e <nsipc_send>
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b88:	00 
  801b89:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9d:	89 04 24             	mov    %eax,(%esp)
  801ba0:	e8 0c 03 00 00       	call   801eb1 <nsipc_recv>
}
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	56                   	push   %esi
  801bab:	53                   	push   %ebx
  801bac:	83 ec 20             	sub    $0x20,%esp
  801baf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 7f f6 ff ff       	call   80123b <fd_alloc>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 21                	js     801be3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bc2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bc9:	00 
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd8:	e8 a0 f4 ff ff       	call   80107d <sys_page_alloc>
  801bdd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	79 0a                	jns    801bed <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801be3:	89 34 24             	mov    %esi,(%esp)
  801be6:	e8 17 02 00 00       	call   801e02 <nsipc_close>
		return r;
  801beb:	eb 28                	jmp    801c15 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0b:	89 04 24             	mov    %eax,(%esp)
  801c0e:	e8 fd f5 ff ff       	call   801210 <fd2num>
  801c13:	89 c3                	mov    %eax,%ebx
}
  801c15:	89 d8                	mov    %ebx,%eax
  801c17:	83 c4 20             	add    $0x20,%esp
  801c1a:	5b                   	pop    %ebx
  801c1b:	5e                   	pop    %esi
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c24:	8b 45 10             	mov    0x10(%ebp),%eax
  801c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 79 01 00 00       	call   801db6 <nsipc_socket>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 05                	js     801c46 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c41:	e8 61 ff ff ff       	call   801ba7 <alloc_sockfd>
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c4e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 50 f6 ff ff       	call   8012ad <fd_lookup>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 15                	js     801c76 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c64:	8b 0a                	mov    (%edx),%ecx
  801c66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c6b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801c71:	75 03                	jne    801c76 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c73:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	e8 c2 ff ff ff       	call   801c48 <fd2sockid>
  801c86:	85 c0                	test   %eax,%eax
  801c88:	78 0f                	js     801c99 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c91:	89 04 24             	mov    %eax,(%esp)
  801c94:	e8 47 01 00 00       	call   801de0 <nsipc_listen>
}
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	e8 9f ff ff ff       	call   801c48 <fd2sockid>
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	78 16                	js     801cc3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801cad:	8b 55 10             	mov    0x10(%ebp),%edx
  801cb0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cbb:	89 04 24             	mov    %eax,(%esp)
  801cbe:	e8 6e 02 00 00       	call   801f31 <nsipc_connect>
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	e8 75 ff ff ff       	call   801c48 <fd2sockid>
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 0f                	js     801ce6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cda:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 36 01 00 00       	call   801e1c <nsipc_shutdown>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	e8 52 ff ff ff       	call   801c48 <fd2sockid>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 16                	js     801d10 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cfa:	8b 55 10             	mov    0x10(%ebp),%edx
  801cfd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d01:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d04:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d08:	89 04 24             	mov    %eax,(%esp)
  801d0b:	e8 60 02 00 00       	call   801f70 <nsipc_bind>
}
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	e8 28 ff ff ff       	call   801c48 <fd2sockid>
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 1f                	js     801d43 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d24:	8b 55 10             	mov    0x10(%ebp),%edx
  801d27:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d32:	89 04 24             	mov    %eax,(%esp)
  801d35:	e8 75 02 00 00       	call   801faf <nsipc_accept>
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 05                	js     801d43 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d3e:	e8 64 fe ff ff       	call   801ba7 <alloc_sockfd>
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    
	...

00801d50 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	53                   	push   %ebx
  801d54:	83 ec 14             	sub    $0x14,%esp
  801d57:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d59:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d60:	75 11                	jne    801d73 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d62:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801d69:	e8 f2 02 00 00       	call   802060 <ipc_find_env>
  801d6e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d73:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d7a:	00 
  801d7b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d82:	00 
  801d83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d87:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 10 03 00 00       	call   8020a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d9b:	00 
  801d9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801da3:	00 
  801da4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dab:	e8 5f 03 00 00       	call   80210f <ipc_recv>
}
  801db0:	83 c4 14             	add    $0x14,%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dcc:	8b 45 10             	mov    0x10(%ebp),%eax
  801dcf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dd4:	b8 09 00 00 00       	mov    $0x9,%eax
  801dd9:	e8 72 ff ff ff       	call   801d50 <nsipc>
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801df6:	b8 06 00 00 00       	mov    $0x6,%eax
  801dfb:	e8 50 ff ff ff       	call   801d50 <nsipc>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e10:	b8 04 00 00 00       	mov    $0x4,%eax
  801e15:	e8 36 ff ff ff       	call   801d50 <nsipc>
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e32:	b8 03 00 00 00       	mov    $0x3,%eax
  801e37:	e8 14 ff ff ff       	call   801d50 <nsipc>
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 14             	sub    $0x14,%esp
  801e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e48:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e50:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e56:	7e 24                	jle    801e7c <nsipc_send+0x3e>
  801e58:	c7 44 24 0c 35 2d 80 	movl   $0x802d35,0xc(%esp)
  801e5f:	00 
  801e60:	c7 44 24 08 09 2d 80 	movl   $0x802d09,0x8(%esp)
  801e67:	00 
  801e68:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801e6f:	00 
  801e70:	c7 04 24 41 2d 80 00 	movl   $0x802d41,(%esp)
  801e77:	e8 88 01 00 00       	call   802004 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e7c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e87:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e8e:	e8 72 ed ff ff       	call   800c05 <memmove>
	nsipcbuf.send.req_size = size;
  801e93:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e99:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ea1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea6:	e8 a5 fe ff ff       	call   801d50 <nsipc>
}
  801eab:	83 c4 14             	add    $0x14,%esp
  801eae:	5b                   	pop    %ebx
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	83 ec 10             	sub    $0x10,%esp
  801eb9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ec4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eca:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ed2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ed7:	e8 74 fe ff ff       	call   801d50 <nsipc>
  801edc:	89 c3                	mov    %eax,%ebx
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	78 46                	js     801f28 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ee2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ee7:	7f 04                	jg     801eed <nsipc_recv+0x3c>
  801ee9:	39 c6                	cmp    %eax,%esi
  801eeb:	7d 24                	jge    801f11 <nsipc_recv+0x60>
  801eed:	c7 44 24 0c 4d 2d 80 	movl   $0x802d4d,0xc(%esp)
  801ef4:	00 
  801ef5:	c7 44 24 08 09 2d 80 	movl   $0x802d09,0x8(%esp)
  801efc:	00 
  801efd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801f04:	00 
  801f05:	c7 04 24 41 2d 80 00 	movl   $0x802d41,(%esp)
  801f0c:	e8 f3 00 00 00       	call   802004 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f15:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f1c:	00 
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	89 04 24             	mov    %eax,(%esp)
  801f23:	e8 dd ec ff ff       	call   800c05 <memmove>
	}

	return r;
}
  801f28:	89 d8                	mov    %ebx,%eax
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	53                   	push   %ebx
  801f35:	83 ec 14             	sub    $0x14,%esp
  801f38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f43:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f55:	e8 ab ec ff ff       	call   800c05 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f5a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f60:	b8 05 00 00 00       	mov    $0x5,%eax
  801f65:	e8 e6 fd ff ff       	call   801d50 <nsipc>
}
  801f6a:	83 c4 14             	add    $0x14,%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	53                   	push   %ebx
  801f74:	83 ec 14             	sub    $0x14,%esp
  801f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f94:	e8 6c ec ff ff       	call   800c05 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f99:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f9f:	b8 02 00 00 00       	mov    $0x2,%eax
  801fa4:	e8 a7 fd ff ff       	call   801d50 <nsipc>
}
  801fa9:	83 c4 14             	add    $0x14,%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	83 ec 18             	sub    $0x18,%esp
  801fb5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fb8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fc3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc8:	e8 83 fd ff ff       	call   801d50 <nsipc>
  801fcd:	89 c3                	mov    %eax,%ebx
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	78 25                	js     801ff8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fd3:	be 10 60 80 00       	mov    $0x806010,%esi
  801fd8:	8b 06                	mov    (%esi),%eax
  801fda:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fde:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fe5:	00 
  801fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe9:	89 04 24             	mov    %eax,(%esp)
  801fec:	e8 14 ec ff ff       	call   800c05 <memmove>
		*addrlen = ret->ret_addrlen;
  801ff1:	8b 16                	mov    (%esi),%edx
  801ff3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801ff8:	89 d8                	mov    %ebx,%eax
  801ffa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ffd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802000:	89 ec                	mov    %ebp,%esp
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	56                   	push   %esi
  802008:	53                   	push   %ebx
  802009:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80200c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80200f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802015:	e8 0d f1 ff ff       	call   801127 <sys_getenvid>
  80201a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80201d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802021:	8b 55 08             	mov    0x8(%ebp),%edx
  802024:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802028:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802030:	c7 04 24 64 2d 80 00 	movl   $0x802d64,(%esp)
  802037:	e8 9d e2 ff ff       	call   8002d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80203c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802040:	8b 45 10             	mov    0x10(%ebp),%eax
  802043:	89 04 24             	mov    %eax,(%esp)
  802046:	e8 2d e2 ff ff       	call   800278 <vcprintf>
	cprintf("\n");
  80204b:	c7 04 24 b5 27 80 00 	movl   $0x8027b5,(%esp)
  802052:	e8 82 e2 ff ff       	call   8002d9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802057:	cc                   	int3   
  802058:	eb fd                	jmp    802057 <_panic+0x53>
  80205a:	00 00                	add    %al,(%eax)
  80205c:	00 00                	add    %al,(%eax)
	...

00802060 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802066:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80206c:	b8 01 00 00 00       	mov    $0x1,%eax
  802071:	39 ca                	cmp    %ecx,%edx
  802073:	75 04                	jne    802079 <ipc_find_env+0x19>
  802075:	b0 00                	mov    $0x0,%al
  802077:	eb 0f                	jmp    802088 <ipc_find_env+0x28>
  802079:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80207c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802082:	8b 12                	mov    (%edx),%edx
  802084:	39 ca                	cmp    %ecx,%edx
  802086:	75 0c                	jne    802094 <ipc_find_env+0x34>
			return envs[i].env_id;
  802088:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80208b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  802090:	8b 00                	mov    (%eax),%eax
  802092:	eb 0e                	jmp    8020a2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802094:	83 c0 01             	add    $0x1,%eax
  802097:	3d 00 04 00 00       	cmp    $0x400,%eax
  80209c:	75 db                	jne    802079 <ipc_find_env+0x19>
  80209e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	57                   	push   %edi
  8020a8:	56                   	push   %esi
  8020a9:	53                   	push   %ebx
  8020aa:	83 ec 1c             	sub    $0x1c,%esp
  8020ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8020b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8020b6:	85 db                	test   %ebx,%ebx
  8020b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020bd:	0f 44 d8             	cmove  %eax,%ebx
  8020c0:	eb 25                	jmp    8020e7 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8020c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020c5:	74 20                	je     8020e7 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8020c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cb:	c7 44 24 08 88 2d 80 	movl   $0x802d88,0x8(%esp)
  8020d2:	00 
  8020d3:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8020da:	00 
  8020db:	c7 04 24 a6 2d 80 00 	movl   $0x802da6,(%esp)
  8020e2:	e8 1d ff ff ff       	call   802004 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8020e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8020f6:	89 34 24             	mov    %esi,(%esp)
  8020f9:	e8 30 ee ff ff       	call   800f2e <sys_ipc_try_send>
  8020fe:	85 c0                	test   %eax,%eax
  802100:	75 c0                	jne    8020c2 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802102:	e8 ad ef ff ff       	call   8010b4 <sys_yield>
}
  802107:	83 c4 1c             	add    $0x1c,%esp
  80210a:	5b                   	pop    %ebx
  80210b:	5e                   	pop    %esi
  80210c:	5f                   	pop    %edi
  80210d:	5d                   	pop    %ebp
  80210e:	c3                   	ret    

0080210f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	83 ec 28             	sub    $0x28,%esp
  802115:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802118:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80211b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80211e:	8b 75 08             	mov    0x8(%ebp),%esi
  802121:	8b 45 0c             	mov    0xc(%ebp),%eax
  802124:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802127:	85 c0                	test   %eax,%eax
  802129:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80212e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802131:	89 04 24             	mov    %eax,(%esp)
  802134:	e8 bc ed ff ff       	call   800ef5 <sys_ipc_recv>
  802139:	89 c3                	mov    %eax,%ebx
  80213b:	85 c0                	test   %eax,%eax
  80213d:	79 2a                	jns    802169 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80213f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802143:	89 44 24 04          	mov    %eax,0x4(%esp)
  802147:	c7 04 24 b0 2d 80 00 	movl   $0x802db0,(%esp)
  80214e:	e8 86 e1 ff ff       	call   8002d9 <cprintf>
		if(from_env_store != NULL)
  802153:	85 f6                	test   %esi,%esi
  802155:	74 06                	je     80215d <ipc_recv+0x4e>
			*from_env_store = 0;
  802157:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80215d:	85 ff                	test   %edi,%edi
  80215f:	74 2c                	je     80218d <ipc_recv+0x7e>
			*perm_store = 0;
  802161:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802167:	eb 24                	jmp    80218d <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  802169:	85 f6                	test   %esi,%esi
  80216b:	74 0a                	je     802177 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  80216d:	a1 18 40 80 00       	mov    0x804018,%eax
  802172:	8b 40 74             	mov    0x74(%eax),%eax
  802175:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802177:	85 ff                	test   %edi,%edi
  802179:	74 0a                	je     802185 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  80217b:	a1 18 40 80 00       	mov    0x804018,%eax
  802180:	8b 40 78             	mov    0x78(%eax),%eax
  802183:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802185:	a1 18 40 80 00       	mov    0x804018,%eax
  80218a:	8b 58 70             	mov    0x70(%eax),%ebx
}
  80218d:	89 d8                	mov    %ebx,%eax
  80218f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802192:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802195:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802198:	89 ec                	mov    %ebp,%esp
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    

0080219c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80219f:	8b 45 08             	mov    0x8(%ebp),%eax
  8021a2:	89 c2                	mov    %eax,%edx
  8021a4:	c1 ea 16             	shr    $0x16,%edx
  8021a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8021ae:	f6 c2 01             	test   $0x1,%dl
  8021b1:	74 20                	je     8021d3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8021b3:	c1 e8 0c             	shr    $0xc,%eax
  8021b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021bd:	a8 01                	test   $0x1,%al
  8021bf:	74 12                	je     8021d3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021c1:	c1 e8 0c             	shr    $0xc,%eax
  8021c4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8021c9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8021ce:	0f b7 c0             	movzwl %ax,%eax
  8021d1:	eb 05                	jmp    8021d8 <pageref+0x3c>
  8021d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    
  8021da:	00 00                	add    %al,(%eax)
  8021dc:	00 00                	add    %al,(%eax)
	...

008021e0 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	57                   	push   %edi
  8021e4:	56                   	push   %esi
  8021e5:	53                   	push   %ebx
  8021e6:	83 ec 20             	sub    $0x20,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8021e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8021ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8021f5:	8d 55 f3             	lea    -0xd(%ebp),%edx
  8021f8:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8021fb:	bb 08 40 80 00       	mov    $0x804008,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802200:	b9 cd ff ff ff       	mov    $0xffffffcd,%ecx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802205:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802208:	0f b6 37             	movzbl (%edi),%esi
  80220b:	ba 00 00 00 00       	mov    $0x0,%edx
  802210:	89 d0                	mov    %edx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	89 de                	mov    %ebx,%esi
  802216:	89 c3                	mov    %eax,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802218:	89 d0                	mov    %edx,%eax
  80221a:	f6 e1                	mul    %cl
  80221c:	66 c1 e8 08          	shr    $0x8,%ax
  802220:	c0 e8 03             	shr    $0x3,%al
  802223:	89 c7                	mov    %eax,%edi
  802225:	8d 04 80             	lea    (%eax,%eax,4),%eax
  802228:	01 c0                	add    %eax,%eax
  80222a:	28 c2                	sub    %al,%dl
  80222c:	89 d0                	mov    %edx,%eax
      *ap /= (u8_t)10;
  80222e:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  802230:	0f b6 fb             	movzbl %bl,%edi
  802233:	83 c0 30             	add    $0x30,%eax
  802236:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  80223a:	8d 43 01             	lea    0x1(%ebx),%eax
    } while(*ap);
  80223d:	84 d2                	test   %dl,%dl
  80223f:	74 04                	je     802245 <inet_ntoa+0x65>
  802241:	89 c3                	mov    %eax,%ebx
  802243:	eb d3                	jmp    802218 <inet_ntoa+0x38>
  802245:	88 45 d7             	mov    %al,-0x29(%ebp)
  802248:	89 df                	mov    %ebx,%edi
  80224a:	89 f3                	mov    %esi,%ebx
  80224c:	89 d6                	mov    %edx,%esi
  80224e:	89 fa                	mov    %edi,%edx
  802250:	88 55 dc             	mov    %dl,-0x24(%ebp)
  802253:	89 f0                	mov    %esi,%eax
  802255:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802258:	88 07                	mov    %al,(%edi)
    while(i--)
  80225a:	80 7d d7 00          	cmpb   $0x0,-0x29(%ebp)
  80225e:	74 2a                	je     80228a <inet_ntoa+0xaa>
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802260:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  802264:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802267:	8d 7c 03 01          	lea    0x1(%ebx,%eax,1),%edi
  80226b:	89 d8                	mov    %ebx,%eax
  80226d:	89 de                	mov    %ebx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  80226f:	0f b6 da             	movzbl %dl,%ebx
  802272:	0f b6 5c 1d ed       	movzbl -0x13(%ebp,%ebx,1),%ebx
  802277:	88 18                	mov    %bl,(%eax)
  802279:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80227c:	83 ea 01             	sub    $0x1,%edx
  80227f:	39 f8                	cmp    %edi,%eax
  802281:	75 ec                	jne    80226f <inet_ntoa+0x8f>
  802283:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802286:	8d 5c 16 01          	lea    0x1(%esi,%edx,1),%ebx
      *rp++ = inv[i];
    *rp++ = '.';
  80228a:	c6 03 2e             	movb   $0x2e,(%ebx)
  80228d:	8d 43 01             	lea    0x1(%ebx),%eax
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802290:	8b 7d d8             	mov    -0x28(%ebp),%edi
  802293:	39 7d e0             	cmp    %edi,-0x20(%ebp)
  802296:	74 0b                	je     8022a3 <inet_ntoa+0xc3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802298:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80229c:	89 c3                	mov    %eax,%ebx
  80229e:	e9 62 ff ff ff       	jmp    802205 <inet_ntoa+0x25>
  }
  *--rp = 0;
  8022a3:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  8022a6:	b8 08 40 80 00       	mov    $0x804008,%eax
  8022ab:	83 c4 20             	add    $0x20,%esp
  8022ae:	5b                   	pop    %ebx
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    

008022b3 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8022ba:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  8022be:	5d                   	pop    %ebp
  8022bf:	c3                   	ret    

008022c0 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8022c0:	55                   	push   %ebp
  8022c1:	89 e5                	mov    %esp,%ebp
  8022c3:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  8022c6:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8022ca:	89 04 24             	mov    %eax,(%esp)
  8022cd:	e8 e1 ff ff ff       	call   8022b3 <htons>
}
  8022d2:	c9                   	leave  
  8022d3:	c3                   	ret    

008022d4 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8022da:	89 d1                	mov    %edx,%ecx
  8022dc:	c1 e9 18             	shr    $0x18,%ecx
  8022df:	89 d0                	mov    %edx,%eax
  8022e1:	c1 e0 18             	shl    $0x18,%eax
  8022e4:	09 c8                	or     %ecx,%eax
  8022e6:	89 d1                	mov    %edx,%ecx
  8022e8:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8022ee:	c1 e1 08             	shl    $0x8,%ecx
  8022f1:	09 c8                	or     %ecx,%eax
  8022f3:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8022f9:	c1 ea 08             	shr    $0x8,%edx
  8022fc:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8022fe:	5d                   	pop    %ebp
  8022ff:	c3                   	ret    

00802300 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802300:	55                   	push   %ebp
  802301:	89 e5                	mov    %esp,%ebp
  802303:	57                   	push   %edi
  802304:	56                   	push   %esi
  802305:	53                   	push   %ebx
  802306:	83 ec 28             	sub    $0x28,%esp
  802309:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  80230c:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80230f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802312:	80 f9 09             	cmp    $0x9,%cl
  802315:	0f 87 a8 01 00 00    	ja     8024c3 <inet_aton+0x1c3>
  80231b:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80231e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802321:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  802324:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  802327:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  80232e:	83 fa 30             	cmp    $0x30,%edx
  802331:	75 24                	jne    802357 <inet_aton+0x57>
      c = *++cp;
  802333:	83 c0 01             	add    $0x1,%eax
  802336:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  802339:	83 fa 78             	cmp    $0x78,%edx
  80233c:	74 0c                	je     80234a <inet_aton+0x4a>
  80233e:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  802345:	83 fa 58             	cmp    $0x58,%edx
  802348:	75 0d                	jne    802357 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  80234a:	83 c0 01             	add    $0x1,%eax
  80234d:	0f be 10             	movsbl (%eax),%edx
  802350:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  802357:	83 c0 01             	add    $0x1,%eax
  80235a:	be 00 00 00 00       	mov    $0x0,%esi
  80235f:	eb 03                	jmp    802364 <inet_aton+0x64>
  802361:	83 c0 01             	add    $0x1,%eax
  802364:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  802367:	89 d1                	mov    %edx,%ecx
  802369:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80236c:	80 fb 09             	cmp    $0x9,%bl
  80236f:	77 0d                	ja     80237e <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  802371:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  802375:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  802379:	0f be 10             	movsbl (%eax),%edx
  80237c:	eb e3                	jmp    802361 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  80237e:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  802382:	75 2b                	jne    8023af <inet_aton+0xaf>
  802384:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802387:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  80238a:	80 fb 05             	cmp    $0x5,%bl
  80238d:	76 08                	jbe    802397 <inet_aton+0x97>
  80238f:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802392:	80 fb 05             	cmp    $0x5,%bl
  802395:	77 18                	ja     8023af <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802397:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80239b:	19 c9                	sbb    %ecx,%ecx
  80239d:	83 e1 20             	and    $0x20,%ecx
  8023a0:	c1 e6 04             	shl    $0x4,%esi
  8023a3:	29 ca                	sub    %ecx,%edx
  8023a5:	8d 52 c9             	lea    -0x37(%edx),%edx
  8023a8:	09 d6                	or     %edx,%esi
        c = *++cp;
  8023aa:	0f be 10             	movsbl (%eax),%edx
  8023ad:	eb b2                	jmp    802361 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  8023af:	83 fa 2e             	cmp    $0x2e,%edx
  8023b2:	75 29                	jne    8023dd <inet_aton+0xdd>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8023b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8023b7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8023ba:	0f 86 03 01 00 00    	jbe    8024c3 <inet_aton+0x1c3>
        return (0);
      *pp++ = val;
  8023c0:	89 32                	mov    %esi,(%edx)
      c = *++cp;
  8023c2:	8d 47 01             	lea    0x1(%edi),%eax
  8023c5:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8023c8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8023cb:	80 f9 09             	cmp    $0x9,%cl
  8023ce:	0f 87 ef 00 00 00    	ja     8024c3 <inet_aton+0x1c3>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  8023d4:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  8023d8:	e9 4a ff ff ff       	jmp    802327 <inet_aton+0x27>
  8023dd:	89 f3                	mov    %esi,%ebx
  8023df:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8023e1:	85 d2                	test   %edx,%edx
  8023e3:	74 36                	je     80241b <inet_aton+0x11b>
  8023e5:	80 f9 1f             	cmp    $0x1f,%cl
  8023e8:	0f 86 d5 00 00 00    	jbe    8024c3 <inet_aton+0x1c3>
  8023ee:	84 d2                	test   %dl,%dl
  8023f0:	0f 88 cd 00 00 00    	js     8024c3 <inet_aton+0x1c3>
  8023f6:	83 fa 20             	cmp    $0x20,%edx
  8023f9:	74 20                	je     80241b <inet_aton+0x11b>
  8023fb:	83 fa 0c             	cmp    $0xc,%edx
  8023fe:	66 90                	xchg   %ax,%ax
  802400:	74 19                	je     80241b <inet_aton+0x11b>
  802402:	83 fa 0a             	cmp    $0xa,%edx
  802405:	74 14                	je     80241b <inet_aton+0x11b>
  802407:	83 fa 0d             	cmp    $0xd,%edx
  80240a:	74 0f                	je     80241b <inet_aton+0x11b>
  80240c:	83 fa 09             	cmp    $0x9,%edx
  80240f:	90                   	nop
  802410:	74 09                	je     80241b <inet_aton+0x11b>
  802412:	83 fa 0b             	cmp    $0xb,%edx
  802415:	0f 85 a8 00 00 00    	jne    8024c3 <inet_aton+0x1c3>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  80241b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80241e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802421:	29 d1                	sub    %edx,%ecx
  802423:	89 ca                	mov    %ecx,%edx
  802425:	c1 fa 02             	sar    $0x2,%edx
  802428:	83 c2 01             	add    $0x1,%edx
  80242b:	83 fa 02             	cmp    $0x2,%edx
  80242e:	74 2a                	je     80245a <inet_aton+0x15a>
  802430:	83 fa 02             	cmp    $0x2,%edx
  802433:	7f 0d                	jg     802442 <inet_aton+0x142>
  802435:	85 d2                	test   %edx,%edx
  802437:	0f 84 86 00 00 00    	je     8024c3 <inet_aton+0x1c3>
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	eb 62                	jmp    8024a4 <inet_aton+0x1a4>
  802442:	83 fa 03             	cmp    $0x3,%edx
  802445:	8d 76 00             	lea    0x0(%esi),%esi
  802448:	74 22                	je     80246c <inet_aton+0x16c>
  80244a:	83 fa 04             	cmp    $0x4,%edx
  80244d:	8d 76 00             	lea    0x0(%esi),%esi
  802450:	75 52                	jne    8024a4 <inet_aton+0x1a4>
  802452:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802458:	eb 2b                	jmp    802485 <inet_aton+0x185>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80245a:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  80245f:	90                   	nop
  802460:	77 61                	ja     8024c3 <inet_aton+0x1c3>
      return (0);
    val |= parts[0] << 24;
  802462:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802465:	c1 e3 18             	shl    $0x18,%ebx
  802468:	09 c3                	or     %eax,%ebx
    break;
  80246a:	eb 38                	jmp    8024a4 <inet_aton+0x1a4>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80246c:	3d ff ff 00 00       	cmp    $0xffff,%eax
  802471:	77 50                	ja     8024c3 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  802473:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  802476:	c1 e3 10             	shl    $0x10,%ebx
  802479:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80247c:	c1 e2 18             	shl    $0x18,%edx
  80247f:	09 d3                	or     %edx,%ebx
  802481:	09 c3                	or     %eax,%ebx
    break;
  802483:	eb 1f                	jmp    8024a4 <inet_aton+0x1a4>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  802485:	3d ff 00 00 00       	cmp    $0xff,%eax
  80248a:	77 37                	ja     8024c3 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80248c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80248f:	c1 e3 10             	shl    $0x10,%ebx
  802492:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802495:	c1 e2 18             	shl    $0x18,%edx
  802498:	09 d3                	or     %edx,%ebx
  80249a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80249d:	c1 e2 08             	shl    $0x8,%edx
  8024a0:	09 d3                	or     %edx,%ebx
  8024a2:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  8024a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8024ad:	74 19                	je     8024c8 <inet_aton+0x1c8>
    addr->s_addr = htonl(val);
  8024af:	89 1c 24             	mov    %ebx,(%esp)
  8024b2:	e8 1d fe ff ff       	call   8022d4 <htonl>
  8024b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8024ba:	89 03                	mov    %eax,(%ebx)
  8024bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c1:	eb 05                	jmp    8024c8 <inet_aton+0x1c8>
  8024c3:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  8024c8:	83 c4 28             	add    $0x28,%esp
  8024cb:	5b                   	pop    %ebx
  8024cc:	5e                   	pop    %esi
  8024cd:	5f                   	pop    %edi
  8024ce:	5d                   	pop    %ebp
  8024cf:	c3                   	ret    

008024d0 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8024d0:	55                   	push   %ebp
  8024d1:	89 e5                	mov    %esp,%ebp
  8024d3:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8024d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8024d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e0:	89 04 24             	mov    %eax,(%esp)
  8024e3:	e8 18 fe ff ff       	call   802300 <inet_aton>
  8024e8:	85 c0                	test   %eax,%eax
  8024ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024ef:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  8024f3:	c9                   	leave  
  8024f4:	c3                   	ret    

008024f5 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8024f5:	55                   	push   %ebp
  8024f6:	89 e5                	mov    %esp,%ebp
  8024f8:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  8024fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024fe:	89 04 24             	mov    %eax,(%esp)
  802501:	e8 ce fd ff ff       	call   8022d4 <htonl>
}
  802506:	c9                   	leave  
  802507:	c3                   	ret    
	...

00802510 <__udivdi3>:
  802510:	55                   	push   %ebp
  802511:	89 e5                	mov    %esp,%ebp
  802513:	57                   	push   %edi
  802514:	56                   	push   %esi
  802515:	83 ec 10             	sub    $0x10,%esp
  802518:	8b 45 14             	mov    0x14(%ebp),%eax
  80251b:	8b 55 08             	mov    0x8(%ebp),%edx
  80251e:	8b 75 10             	mov    0x10(%ebp),%esi
  802521:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802524:	85 c0                	test   %eax,%eax
  802526:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802529:	75 35                	jne    802560 <__udivdi3+0x50>
  80252b:	39 fe                	cmp    %edi,%esi
  80252d:	77 61                	ja     802590 <__udivdi3+0x80>
  80252f:	85 f6                	test   %esi,%esi
  802531:	75 0b                	jne    80253e <__udivdi3+0x2e>
  802533:	b8 01 00 00 00       	mov    $0x1,%eax
  802538:	31 d2                	xor    %edx,%edx
  80253a:	f7 f6                	div    %esi
  80253c:	89 c6                	mov    %eax,%esi
  80253e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802541:	31 d2                	xor    %edx,%edx
  802543:	89 f8                	mov    %edi,%eax
  802545:	f7 f6                	div    %esi
  802547:	89 c7                	mov    %eax,%edi
  802549:	89 c8                	mov    %ecx,%eax
  80254b:	f7 f6                	div    %esi
  80254d:	89 c1                	mov    %eax,%ecx
  80254f:	89 fa                	mov    %edi,%edx
  802551:	89 c8                	mov    %ecx,%eax
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	5e                   	pop    %esi
  802557:	5f                   	pop    %edi
  802558:	5d                   	pop    %ebp
  802559:	c3                   	ret    
  80255a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802560:	39 f8                	cmp    %edi,%eax
  802562:	77 1c                	ja     802580 <__udivdi3+0x70>
  802564:	0f bd d0             	bsr    %eax,%edx
  802567:	83 f2 1f             	xor    $0x1f,%edx
  80256a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80256d:	75 39                	jne    8025a8 <__udivdi3+0x98>
  80256f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802572:	0f 86 a0 00 00 00    	jbe    802618 <__udivdi3+0x108>
  802578:	39 f8                	cmp    %edi,%eax
  80257a:	0f 82 98 00 00 00    	jb     802618 <__udivdi3+0x108>
  802580:	31 ff                	xor    %edi,%edi
  802582:	31 c9                	xor    %ecx,%ecx
  802584:	89 c8                	mov    %ecx,%eax
  802586:	89 fa                	mov    %edi,%edx
  802588:	83 c4 10             	add    $0x10,%esp
  80258b:	5e                   	pop    %esi
  80258c:	5f                   	pop    %edi
  80258d:	5d                   	pop    %ebp
  80258e:	c3                   	ret    
  80258f:	90                   	nop
  802590:	89 d1                	mov    %edx,%ecx
  802592:	89 fa                	mov    %edi,%edx
  802594:	89 c8                	mov    %ecx,%eax
  802596:	31 ff                	xor    %edi,%edi
  802598:	f7 f6                	div    %esi
  80259a:	89 c1                	mov    %eax,%ecx
  80259c:	89 fa                	mov    %edi,%edx
  80259e:	89 c8                	mov    %ecx,%eax
  8025a0:	83 c4 10             	add    $0x10,%esp
  8025a3:	5e                   	pop    %esi
  8025a4:	5f                   	pop    %edi
  8025a5:	5d                   	pop    %ebp
  8025a6:	c3                   	ret    
  8025a7:	90                   	nop
  8025a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025ac:	89 f2                	mov    %esi,%edx
  8025ae:	d3 e0                	shl    %cl,%eax
  8025b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8025b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8025b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8025bb:	89 c1                	mov    %eax,%ecx
  8025bd:	d3 ea                	shr    %cl,%edx
  8025bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8025c6:	d3 e6                	shl    %cl,%esi
  8025c8:	89 c1                	mov    %eax,%ecx
  8025ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8025cd:	89 fe                	mov    %edi,%esi
  8025cf:	d3 ee                	shr    %cl,%esi
  8025d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025db:	d3 e7                	shl    %cl,%edi
  8025dd:	89 c1                	mov    %eax,%ecx
  8025df:	d3 ea                	shr    %cl,%edx
  8025e1:	09 d7                	or     %edx,%edi
  8025e3:	89 f2                	mov    %esi,%edx
  8025e5:	89 f8                	mov    %edi,%eax
  8025e7:	f7 75 ec             	divl   -0x14(%ebp)
  8025ea:	89 d6                	mov    %edx,%esi
  8025ec:	89 c7                	mov    %eax,%edi
  8025ee:	f7 65 e8             	mull   -0x18(%ebp)
  8025f1:	39 d6                	cmp    %edx,%esi
  8025f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8025f6:	72 30                	jb     802628 <__udivdi3+0x118>
  8025f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8025fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8025ff:	d3 e2                	shl    %cl,%edx
  802601:	39 c2                	cmp    %eax,%edx
  802603:	73 05                	jae    80260a <__udivdi3+0xfa>
  802605:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802608:	74 1e                	je     802628 <__udivdi3+0x118>
  80260a:	89 f9                	mov    %edi,%ecx
  80260c:	31 ff                	xor    %edi,%edi
  80260e:	e9 71 ff ff ff       	jmp    802584 <__udivdi3+0x74>
  802613:	90                   	nop
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	31 ff                	xor    %edi,%edi
  80261a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80261f:	e9 60 ff ff ff       	jmp    802584 <__udivdi3+0x74>
  802624:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802628:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80262b:	31 ff                	xor    %edi,%edi
  80262d:	89 c8                	mov    %ecx,%eax
  80262f:	89 fa                	mov    %edi,%edx
  802631:	83 c4 10             	add    $0x10,%esp
  802634:	5e                   	pop    %esi
  802635:	5f                   	pop    %edi
  802636:	5d                   	pop    %ebp
  802637:	c3                   	ret    
	...

00802640 <__umoddi3>:
  802640:	55                   	push   %ebp
  802641:	89 e5                	mov    %esp,%ebp
  802643:	57                   	push   %edi
  802644:	56                   	push   %esi
  802645:	83 ec 20             	sub    $0x20,%esp
  802648:	8b 55 14             	mov    0x14(%ebp),%edx
  80264b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80264e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802651:	8b 75 0c             	mov    0xc(%ebp),%esi
  802654:	85 d2                	test   %edx,%edx
  802656:	89 c8                	mov    %ecx,%eax
  802658:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80265b:	75 13                	jne    802670 <__umoddi3+0x30>
  80265d:	39 f7                	cmp    %esi,%edi
  80265f:	76 3f                	jbe    8026a0 <__umoddi3+0x60>
  802661:	89 f2                	mov    %esi,%edx
  802663:	f7 f7                	div    %edi
  802665:	89 d0                	mov    %edx,%eax
  802667:	31 d2                	xor    %edx,%edx
  802669:	83 c4 20             	add    $0x20,%esp
  80266c:	5e                   	pop    %esi
  80266d:	5f                   	pop    %edi
  80266e:	5d                   	pop    %ebp
  80266f:	c3                   	ret    
  802670:	39 f2                	cmp    %esi,%edx
  802672:	77 4c                	ja     8026c0 <__umoddi3+0x80>
  802674:	0f bd ca             	bsr    %edx,%ecx
  802677:	83 f1 1f             	xor    $0x1f,%ecx
  80267a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80267d:	75 51                	jne    8026d0 <__umoddi3+0x90>
  80267f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802682:	0f 87 e0 00 00 00    	ja     802768 <__umoddi3+0x128>
  802688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80268b:	29 f8                	sub    %edi,%eax
  80268d:	19 d6                	sbb    %edx,%esi
  80268f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802695:	89 f2                	mov    %esi,%edx
  802697:	83 c4 20             	add    $0x20,%esp
  80269a:	5e                   	pop    %esi
  80269b:	5f                   	pop    %edi
  80269c:	5d                   	pop    %ebp
  80269d:	c3                   	ret    
  80269e:	66 90                	xchg   %ax,%ax
  8026a0:	85 ff                	test   %edi,%edi
  8026a2:	75 0b                	jne    8026af <__umoddi3+0x6f>
  8026a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8026a9:	31 d2                	xor    %edx,%edx
  8026ab:	f7 f7                	div    %edi
  8026ad:	89 c7                	mov    %eax,%edi
  8026af:	89 f0                	mov    %esi,%eax
  8026b1:	31 d2                	xor    %edx,%edx
  8026b3:	f7 f7                	div    %edi
  8026b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8026b8:	f7 f7                	div    %edi
  8026ba:	eb a9                	jmp    802665 <__umoddi3+0x25>
  8026bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026c0:	89 c8                	mov    %ecx,%eax
  8026c2:	89 f2                	mov    %esi,%edx
  8026c4:	83 c4 20             	add    $0x20,%esp
  8026c7:	5e                   	pop    %esi
  8026c8:	5f                   	pop    %edi
  8026c9:	5d                   	pop    %ebp
  8026ca:	c3                   	ret    
  8026cb:	90                   	nop
  8026cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026d4:	d3 e2                	shl    %cl,%edx
  8026d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8026de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8026e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026e8:	89 fa                	mov    %edi,%edx
  8026ea:	d3 ea                	shr    %cl,%edx
  8026ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8026f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8026f3:	d3 e7                	shl    %cl,%edi
  8026f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8026f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8026fc:	89 f2                	mov    %esi,%edx
  8026fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802701:	89 c7                	mov    %eax,%edi
  802703:	d3 ea                	shr    %cl,%edx
  802705:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802709:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80270c:	89 c2                	mov    %eax,%edx
  80270e:	d3 e6                	shl    %cl,%esi
  802710:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802714:	d3 ea                	shr    %cl,%edx
  802716:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80271a:	09 d6                	or     %edx,%esi
  80271c:	89 f0                	mov    %esi,%eax
  80271e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802721:	d3 e7                	shl    %cl,%edi
  802723:	89 f2                	mov    %esi,%edx
  802725:	f7 75 f4             	divl   -0xc(%ebp)
  802728:	89 d6                	mov    %edx,%esi
  80272a:	f7 65 e8             	mull   -0x18(%ebp)
  80272d:	39 d6                	cmp    %edx,%esi
  80272f:	72 2b                	jb     80275c <__umoddi3+0x11c>
  802731:	39 c7                	cmp    %eax,%edi
  802733:	72 23                	jb     802758 <__umoddi3+0x118>
  802735:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802739:	29 c7                	sub    %eax,%edi
  80273b:	19 d6                	sbb    %edx,%esi
  80273d:	89 f0                	mov    %esi,%eax
  80273f:	89 f2                	mov    %esi,%edx
  802741:	d3 ef                	shr    %cl,%edi
  802743:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802747:	d3 e0                	shl    %cl,%eax
  802749:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80274d:	09 f8                	or     %edi,%eax
  80274f:	d3 ea                	shr    %cl,%edx
  802751:	83 c4 20             	add    $0x20,%esp
  802754:	5e                   	pop    %esi
  802755:	5f                   	pop    %edi
  802756:	5d                   	pop    %ebp
  802757:	c3                   	ret    
  802758:	39 d6                	cmp    %edx,%esi
  80275a:	75 d9                	jne    802735 <__umoddi3+0xf5>
  80275c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80275f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802762:	eb d1                	jmp    802735 <__umoddi3+0xf5>
  802764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802768:	39 f2                	cmp    %esi,%edx
  80276a:	0f 82 18 ff ff ff    	jb     802688 <__umoddi3+0x48>
  802770:	e9 1d ff ff ff       	jmp    802692 <__umoddi3+0x52>
