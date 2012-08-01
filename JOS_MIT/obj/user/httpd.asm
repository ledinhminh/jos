
obj/user/httpd.debug:     file format elf32-i386


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
  80002c:	e8 1f 03 00 00       	call   800350 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <die>:
	{404, "Not Found"},
};

static void
die(char *m)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	cprintf("%s\n", m);
  800046:	89 44 24 04          	mov    %eax,0x4(%esp)
  80004a:	c7 04 24 80 2b 80 00 	movl   $0x802b80,(%esp)
  800051:	e8 1f 04 00 00       	call   800475 <cprintf>
	exit();
  800056:	e8 45 03 00 00       	call   8003a0 <exit>
}
  80005b:	c9                   	leave  
  80005c:	c3                   	ret    

0080005d <handle_client>:
	return r;
}

static void
handle_client(int sock)
{
  80005d:	55                   	push   %ebp
  80005e:	89 e5                	mov    %esp,%ebp
  800060:	57                   	push   %edi
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	81 ec 3c 04 00 00    	sub    $0x43c,%esp
  800069:	89 c3                	mov    %eax,%ebx
	struct http_request *req = &con_d;

	while (1)
	{
		// Receive message
		if ((received = read(sock, buffer, BUFFSIZE)) < 0)
  80006b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800072:	00 
  800073:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  800079:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007d:	89 1c 24             	mov    %ebx,(%esp)
  800080:	e8 2e 16 00 00       	call   8016b3 <read>
  800085:	85 c0                	test   %eax,%eax
  800087:	79 1c                	jns    8000a5 <handle_client+0x48>
			panic("failed to read");
  800089:	c7 44 24 08 84 2b 80 	movl   $0x802b84,0x8(%esp)
  800090:	00 
  800091:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  800098:	00 
  800099:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  8000a0:	e8 17 03 00 00       	call   8003bc <_panic>

		memset(req, 0, sizeof(req));
  8000a5:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  8000ac:	00 
  8000ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b4:	00 
  8000b5:	8d 45 dc             	lea    -0x24(%ebp),%eax
  8000b8:	89 04 24             	mov    %eax,(%esp)
  8000bb:	e8 86 0c 00 00       	call   800d46 <memset>

		req->sock = sock;
  8000c0:	89 5d dc             	mov    %ebx,-0x24(%ebp)
	int url_len, version_len;

	if (!req)
		return -1;

	if (strncmp(request, "GET ", 4) != 0)
  8000c3:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 a0 2b 80 	movl   $0x802ba0,0x4(%esp)
  8000d2:	00 
  8000d3:	8d 85 dc fd ff ff    	lea    -0x224(%ebp),%eax
  8000d9:	89 04 24             	mov    %eax,(%esp)
  8000dc:	e8 c3 0b 00 00       	call   800ca4 <strncmp>
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	0f 85 bf 00 00 00    	jne    8001a8 <handle_client+0x14b>
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  8000e9:	0f b6 85 e0 fd ff ff 	movzbl -0x220(%ebp),%eax
  8000f0:	84 c0                	test   %al,%al
  8000f2:	74 0a                	je     8000fe <handle_client+0xa1>
  8000f4:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  8000fa:	3c 20                	cmp    $0x20,%al
  8000fc:	75 08                	jne    800106 <handle_client+0xa9>
  8000fe:	8d 9d e0 fd ff ff    	lea    -0x220(%ebp),%ebx
  800104:	eb 0e                	jmp    800114 <handle_client+0xb7>
		request++;
  800106:	83 c3 01             	add    $0x1,%ebx
	// skip GET
	request += 4;

	// get the url
	url = request;
	while (*request && *request != ' ')
  800109:	0f b6 03             	movzbl (%ebx),%eax
  80010c:	84 c0                	test   %al,%al
  80010e:	74 04                	je     800114 <handle_client+0xb7>
  800110:	3c 20                	cmp    $0x20,%al
  800112:	75 f2                	jne    800106 <handle_client+0xa9>
		request++;
	url_len = request - url;
  800114:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
  80011a:	89 de                	mov    %ebx,%esi
  80011c:	29 fe                	sub    %edi,%esi

	req->url = malloc(url_len + 1);
  80011e:	8d 46 01             	lea    0x1(%esi),%eax
  800121:	89 04 24             	mov    %eax,(%esp)
  800124:	e8 5a 21 00 00       	call   802283 <malloc>
  800129:	89 45 e0             	mov    %eax,-0x20(%ebp)
	memmove(req->url, url, url_len);
  80012c:	89 74 24 08          	mov    %esi,0x8(%esp)
  800130:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800134:	89 04 24             	mov    %eax,(%esp)
  800137:	e8 69 0c 00 00       	call   800da5 <memmove>
	req->url[url_len] = '\0';
  80013c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80013f:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)

	// skip space
	request++;
  800143:	83 c3 01             	add    $0x1,%ebx

	version = request;
	while (*request && *request != '\n')
  800146:	0f b6 03             	movzbl (%ebx),%eax
  800149:	84 c0                	test   %al,%al
  80014b:	74 06                	je     800153 <handle_client+0xf6>
  80014d:	89 de                	mov    %ebx,%esi
  80014f:	3c 0a                	cmp    $0xa,%al
  800151:	75 04                	jne    800157 <handle_client+0xfa>
  800153:	89 de                	mov    %ebx,%esi
  800155:	eb 0e                	jmp    800165 <handle_client+0x108>
		request++;
  800157:	83 c6 01             	add    $0x1,%esi

	// skip space
	request++;

	version = request;
	while (*request && *request != '\n')
  80015a:	0f b6 06             	movzbl (%esi),%eax
  80015d:	84 c0                	test   %al,%al
  80015f:	74 04                	je     800165 <handle_client+0x108>
  800161:	3c 0a                	cmp    $0xa,%al
  800163:	75 f2                	jne    800157 <handle_client+0xfa>
		request++;
	version_len = request - version;
  800165:	29 de                	sub    %ebx,%esi

	req->version = malloc(version_len + 1);
  800167:	8d 46 01             	lea    0x1(%esi),%eax
  80016a:	89 04 24             	mov    %eax,(%esp)
  80016d:	e8 11 21 00 00       	call   802283 <malloc>
  800172:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	memmove(req->version, version, version_len);
  800175:	89 74 24 08          	mov    %esi,0x8(%esp)
  800179:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80017d:	89 04 24             	mov    %eax,(%esp)
  800180:	e8 20 0c 00 00       	call   800da5 <memmove>
	req->version[version_len] = '\0';
  800185:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800188:	c6 04 30 00          	movb   $0x0,(%eax,%esi,1)
	// if the file does not exist, send a 404 error using send_error
	// if the file is a directory, send a 404 error using send_error
	// set file_size to the size of the file

	// LAB 6: Your code here.
	panic("send_file not implemented");
  80018c:	c7 44 24 08 a5 2b 80 	movl   $0x802ba5,0x8(%esp)
  800193:	00 
  800194:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  80019b:	00 
  80019c:	c7 04 24 93 2b 80 00 	movl   $0x802b93,(%esp)
  8001a3:	e8 14 02 00 00       	call   8003bc <_panic>
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  8001a8:	8b 15 10 40 80 00    	mov    0x804010,%edx
  8001ae:	85 d2                	test   %edx,%edx
  8001b0:	74 73                	je     800225 <handle_client+0x1c8>
  8001b2:	b8 10 40 80 00       	mov    $0x804010,%eax
  8001b7:	83 3d 14 40 80 00 00 	cmpl   $0x0,0x804014
  8001be:	74 21                	je     8001e1 <handle_client+0x184>
		if (e->code == code)
  8001c0:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  8001c6:	75 0a                	jne    8001d2 <handle_client+0x175>
  8001c8:	eb 17                	jmp    8001e1 <handle_client+0x184>
  8001ca:	81 fa 90 01 00 00    	cmp    $0x190,%edx
  8001d0:	74 0f                	je     8001e1 <handle_client+0x184>
			break;
		e++;
  8001d2:	83 c0 08             	add    $0x8,%eax
{
	char buf[512];
	int r;

	struct error_messages *e = errors;
	while (e->code != 0 && e->msg != 0) {
  8001d5:	8b 10                	mov    (%eax),%edx
  8001d7:	85 d2                	test   %edx,%edx
  8001d9:	74 4a                	je     800225 <handle_client+0x1c8>
  8001db:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  8001df:	75 e9                	jne    8001ca <handle_client+0x16d>
	}

	if (e->code == 0)
		return -1;

	r = snprintf(buf, 512, "HTTP/" HTTP_VERSION" %d %s\r\n"
  8001e1:	8b 40 04             	mov    0x4(%eax),%eax
  8001e4:	89 44 24 18          	mov    %eax,0x18(%esp)
  8001e8:	89 54 24 14          	mov    %edx,0x14(%esp)
  8001ec:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001f4:	c7 44 24 08 f4 2b 80 	movl   $0x802bf4,0x8(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  800203:	00 
  800204:	8d b5 dc fb ff ff    	lea    -0x424(%ebp),%esi
  80020a:	89 34 24             	mov    %esi,(%esp)
  80020d:	e8 06 09 00 00       	call   800b18 <snprintf>
			       "Content-type: text/html\r\n"
			       "\r\n"
			       "<html><body><p>%d - %s</p></body></html>\r\n",
			       e->code, e->msg, e->code, e->msg);

	if (write(req->sock, buf, r) != r)
  800212:	89 44 24 08          	mov    %eax,0x8(%esp)
  800216:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80021d:	89 04 24             	mov    %eax,(%esp)
  800220:	e8 05 14 00 00       	call   80162a <write>
}

static void
req_free(struct http_request *req)
{
	free(req->url);
  800225:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 80 1f 00 00       	call   8021b0 <free>
	free(req->version);
  800230:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	e8 75 1f 00 00       	call   8021b0 <free>

		// no keep alive
		break;
	}

	close(sock);
  80023b:	89 1c 24             	mov    %ebx,(%esp)
  80023e:	e8 d9 15 00 00       	call   80181c <close>
}
  800243:	81 c4 3c 04 00 00    	add    $0x43c,%esp
  800249:	5b                   	pop    %ebx
  80024a:	5e                   	pop    %esi
  80024b:	5f                   	pop    %edi
  80024c:	5d                   	pop    %ebp
  80024d:	c3                   	ret    

0080024e <umain>:

void
umain(int argc, char **argv)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 4c             	sub    $0x4c,%esp
	int serversock, clientsock;
	struct sockaddr_in server, client;

	binaryname = "jhttpd";
  800257:	c7 05 20 40 80 00 bf 	movl   $0x802bbf,0x804020
  80025e:	2b 80 00 

	// Create the TCP socket
	if ((serversock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0)
  800261:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800268:	00 
  800269:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800270:	00 
  800271:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800278:	e8 41 1b 00 00       	call   801dbe <socket>
  80027d:	89 c6                	mov    %eax,%esi
  80027f:	85 c0                	test   %eax,%eax
  800281:	79 0a                	jns    80028d <umain+0x3f>
		die("Failed to create socket");
  800283:	b8 c6 2b 80 00       	mov    $0x802bc6,%eax
  800288:	e8 b3 fd ff ff       	call   800040 <die>

	// Construct the server sockaddr_in structure
	memset(&server, 0, sizeof(server));		// Clear struct
  80028d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  800294:	00 
  800295:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80029c:	00 
  80029d:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  8002a0:	89 1c 24             	mov    %ebx,(%esp)
  8002a3:	e8 9e 0a 00 00       	call   800d46 <memset>
	server.sin_family = AF_INET;			// Internet/IP
  8002a8:	c6 45 d9 02          	movb   $0x2,-0x27(%ebp)
	server.sin_addr.s_addr = htonl(INADDR_ANY);	// IP address
  8002ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b3:	e8 1c 24 00 00       	call   8026d4 <htonl>
  8002b8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	server.sin_port = htons(PORT);			// server port
  8002bb:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  8002c2:	e8 ec 23 00 00       	call   8026b3 <htons>
  8002c7:	66 89 45 da          	mov    %ax,-0x26(%ebp)

	// Bind the server socket
	if (bind(serversock, (struct sockaddr *) &server,
  8002cb:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
  8002d2:	00 
  8002d3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8002d7:	89 34 24             	mov    %esi,(%esp)
  8002da:	e8 a9 1b 00 00       	call   801e88 <bind>
  8002df:	85 c0                	test   %eax,%eax
  8002e1:	79 0a                	jns    8002ed <umain+0x9f>
		 sizeof(server)) < 0)
	{
		die("Failed to bind the server socket");
  8002e3:	b8 70 2c 80 00       	mov    $0x802c70,%eax
  8002e8:	e8 53 fd ff ff       	call   800040 <die>
	}

	// Listen on the server socket
	if (listen(serversock, MAXPENDING) < 0)
  8002ed:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  8002f4:	00 
  8002f5:	89 34 24             	mov    %esi,(%esp)
  8002f8:	e8 1b 1b 00 00       	call   801e18 <listen>
  8002fd:	85 c0                	test   %eax,%eax
  8002ff:	79 0a                	jns    80030b <umain+0xbd>
		die("Failed to listen on server socket");
  800301:	b8 94 2c 80 00       	mov    $0x802c94,%eax
  800306:	e8 35 fd ff ff       	call   800040 <die>

	cprintf("Waiting for http connections...\n");
  80030b:	c7 04 24 b8 2c 80 00 	movl   $0x802cb8,(%esp)
  800312:	e8 5e 01 00 00       	call   800475 <cprintf>

	while (1) {
		unsigned int clientlen = sizeof(client);
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800317:	8d 7d c4             	lea    -0x3c(%ebp),%edi
		die("Failed to listen on server socket");

	cprintf("Waiting for http connections...\n");

	while (1) {
		unsigned int clientlen = sizeof(client);
  80031a:	c7 45 c4 10 00 00 00 	movl   $0x10,-0x3c(%ebp)
		// Wait for client connection
		if ((clientsock = accept(serversock,
  800321:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800325:	8d 45 c8             	lea    -0x38(%ebp),%eax
  800328:	89 44 24 04          	mov    %eax,0x4(%esp)
  80032c:	89 34 24             	mov    %esi,(%esp)
  80032f:	e8 7e 1b 00 00       	call   801eb2 <accept>
  800334:	89 c3                	mov    %eax,%ebx
  800336:	85 c0                	test   %eax,%eax
  800338:	79 0a                	jns    800344 <umain+0xf6>
					 (struct sockaddr *) &client,
					 &clientlen)) < 0)
		{
			die("Failed to accept client connection");
  80033a:	b8 dc 2c 80 00       	mov    $0x802cdc,%eax
  80033f:	e8 fc fc ff ff       	call   800040 <die>
		}
		handle_client(clientsock);
  800344:	89 d8                	mov    %ebx,%eax
  800346:	e8 12 fd ff ff       	call   80005d <handle_client>
	}
  80034b:	eb cd                	jmp    80031a <umain+0xcc>
  80034d:	00 00                	add    %al,(%eax)
	...

00800350 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 18             	sub    $0x18,%esp
  800356:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800359:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80035c:	8b 75 08             	mov    0x8(%ebp),%esi
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800362:	e8 60 0f 00 00       	call   8012c7 <sys_getenvid>
  800367:	25 ff 03 00 00       	and    $0x3ff,%eax
  80036c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80036f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800374:	a3 1c 50 80 00       	mov    %eax,0x80501c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800379:	85 f6                	test   %esi,%esi
  80037b:	7e 07                	jle    800384 <libmain+0x34>
		binaryname = argv[0];
  80037d:	8b 03                	mov    (%ebx),%eax
  80037f:	a3 20 40 80 00       	mov    %eax,0x804020

	// call user main routine
	umain(argc, argv);
  800384:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800388:	89 34 24             	mov    %esi,(%esp)
  80038b:	e8 be fe ff ff       	call   80024e <umain>

	// exit gracefully
	exit();
  800390:	e8 0b 00 00 00       	call   8003a0 <exit>
}
  800395:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800398:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80039b:	89 ec                	mov    %ebp,%esp
  80039d:	5d                   	pop    %ebp
  80039e:	c3                   	ret    
	...

008003a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8003a6:	e8 ee 14 00 00       	call   801899 <close_all>
	sys_env_destroy(0);
  8003ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8003b2:	e8 4b 0f 00 00       	call   801302 <sys_env_destroy>
}
  8003b7:	c9                   	leave  
  8003b8:	c3                   	ret    
  8003b9:	00 00                	add    %al,(%eax)
	...

008003bc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	56                   	push   %esi
  8003c0:	53                   	push   %ebx
  8003c1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8003c4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003c7:	8b 1d 20 40 80 00    	mov    0x804020,%ebx
  8003cd:	e8 f5 0e 00 00       	call   8012c7 <sys_getenvid>
  8003d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8003e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003e8:	c7 04 24 30 2d 80 00 	movl   $0x802d30,(%esp)
  8003ef:	e8 81 00 00 00       	call   800475 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8003fb:	89 04 24             	mov    %eax,(%esp)
  8003fe:	e8 11 00 00 00       	call   800414 <vcprintf>
	cprintf("\n");
  800403:	c7 04 24 84 31 80 00 	movl   $0x803184,(%esp)
  80040a:	e8 66 00 00 00       	call   800475 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80040f:	cc                   	int3   
  800410:	eb fd                	jmp    80040f <_panic+0x53>
	...

00800414 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800414:	55                   	push   %ebp
  800415:	89 e5                	mov    %esp,%ebp
  800417:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80041d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800424:	00 00 00 
	b.cnt = 0;
  800427:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80042e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800431:	8b 45 0c             	mov    0xc(%ebp),%eax
  800434:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800438:	8b 45 08             	mov    0x8(%ebp),%eax
  80043b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800445:	89 44 24 04          	mov    %eax,0x4(%esp)
  800449:	c7 04 24 8f 04 80 00 	movl   $0x80048f,(%esp)
  800450:	e8 d8 01 00 00       	call   80062d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800455:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80045b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	e8 09 0f 00 00       	call   801376 <sys_cputs>

	return b.cnt;
}
  80046d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800473:	c9                   	leave  
  800474:	c3                   	ret    

00800475 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800475:	55                   	push   %ebp
  800476:	89 e5                	mov    %esp,%ebp
  800478:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80047b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80047e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800482:	8b 45 08             	mov    0x8(%ebp),%eax
  800485:	89 04 24             	mov    %eax,(%esp)
  800488:	e8 87 ff ff ff       	call   800414 <vcprintf>
	va_end(ap);

	return cnt;
}
  80048d:	c9                   	leave  
  80048e:	c3                   	ret    

0080048f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
  800492:	53                   	push   %ebx
  800493:	83 ec 14             	sub    $0x14,%esp
  800496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800499:	8b 03                	mov    (%ebx),%eax
  80049b:	8b 55 08             	mov    0x8(%ebp),%edx
  80049e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8004a2:	83 c0 01             	add    $0x1,%eax
  8004a5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8004a7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ac:	75 19                	jne    8004c7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8004ae:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8004b5:	00 
  8004b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8004b9:	89 04 24             	mov    %eax,(%esp)
  8004bc:	e8 b5 0e 00 00       	call   801376 <sys_cputs>
		b->idx = 0;
  8004c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8004c7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8004cb:	83 c4 14             	add    $0x14,%esp
  8004ce:	5b                   	pop    %ebx
  8004cf:	5d                   	pop    %ebp
  8004d0:	c3                   	ret    
	...

008004e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004e0:	55                   	push   %ebp
  8004e1:	89 e5                	mov    %esp,%ebp
  8004e3:	57                   	push   %edi
  8004e4:	56                   	push   %esi
  8004e5:	53                   	push   %ebx
  8004e6:	83 ec 4c             	sub    $0x4c,%esp
  8004e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ec:	89 d6                	mov    %edx,%esi
  8004ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800500:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800503:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800506:	b9 00 00 00 00       	mov    $0x0,%ecx
  80050b:	39 d1                	cmp    %edx,%ecx
  80050d:	72 15                	jb     800524 <printnum+0x44>
  80050f:	77 07                	ja     800518 <printnum+0x38>
  800511:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800514:	39 d0                	cmp    %edx,%eax
  800516:	76 0c                	jbe    800524 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800518:	83 eb 01             	sub    $0x1,%ebx
  80051b:	85 db                	test   %ebx,%ebx
  80051d:	8d 76 00             	lea    0x0(%esi),%esi
  800520:	7f 61                	jg     800583 <printnum+0xa3>
  800522:	eb 70                	jmp    800594 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800524:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800528:	83 eb 01             	sub    $0x1,%ebx
  80052b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80052f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800533:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800537:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80053b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80053e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800541:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800544:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800548:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80054f:	00 
  800550:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800559:	89 54 24 04          	mov    %edx,0x4(%esp)
  80055d:	e8 ae 23 00 00       	call   802910 <__udivdi3>
  800562:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800565:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800568:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80056c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800570:	89 04 24             	mov    %eax,(%esp)
  800573:	89 54 24 04          	mov    %edx,0x4(%esp)
  800577:	89 f2                	mov    %esi,%edx
  800579:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057c:	e8 5f ff ff ff       	call   8004e0 <printnum>
  800581:	eb 11                	jmp    800594 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800583:	89 74 24 04          	mov    %esi,0x4(%esp)
  800587:	89 3c 24             	mov    %edi,(%esp)
  80058a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80058d:	83 eb 01             	sub    $0x1,%ebx
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f ef                	jg     800583 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800594:	89 74 24 04          	mov    %esi,0x4(%esp)
  800598:	8b 74 24 04          	mov    0x4(%esp),%esi
  80059c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80059f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005aa:	00 
  8005ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ae:	89 14 24             	mov    %edx,(%esp)
  8005b1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b8:	e8 83 24 00 00       	call   802a40 <__umoddi3>
  8005bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c1:	0f be 80 53 2d 80 00 	movsbl 0x802d53(%eax),%eax
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8005ce:	83 c4 4c             	add    $0x4c,%esp
  8005d1:	5b                   	pop    %ebx
  8005d2:	5e                   	pop    %esi
  8005d3:	5f                   	pop    %edi
  8005d4:	5d                   	pop    %ebp
  8005d5:	c3                   	ret    

008005d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8005d6:	55                   	push   %ebp
  8005d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8005d9:	83 fa 01             	cmp    $0x1,%edx
  8005dc:	7e 0e                	jle    8005ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8005de:	8b 10                	mov    (%eax),%edx
  8005e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005e3:	89 08                	mov    %ecx,(%eax)
  8005e5:	8b 02                	mov    (%edx),%eax
  8005e7:	8b 52 04             	mov    0x4(%edx),%edx
  8005ea:	eb 22                	jmp    80060e <getuint+0x38>
	else if (lflag)
  8005ec:	85 d2                	test   %edx,%edx
  8005ee:	74 10                	je     800600 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005f5:	89 08                	mov    %ecx,(%eax)
  8005f7:	8b 02                	mov    (%edx),%eax
  8005f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005fe:	eb 0e                	jmp    80060e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800600:	8b 10                	mov    (%eax),%edx
  800602:	8d 4a 04             	lea    0x4(%edx),%ecx
  800605:	89 08                	mov    %ecx,(%eax)
  800607:	8b 02                	mov    (%edx),%eax
  800609:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80060e:	5d                   	pop    %ebp
  80060f:	c3                   	ret    

00800610 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800616:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	3b 50 04             	cmp    0x4(%eax),%edx
  80061f:	73 0a                	jae    80062b <sprintputch+0x1b>
		*b->buf++ = ch;
  800621:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800624:	88 0a                	mov    %cl,(%edx)
  800626:	83 c2 01             	add    $0x1,%edx
  800629:	89 10                	mov    %edx,(%eax)
}
  80062b:	5d                   	pop    %ebp
  80062c:	c3                   	ret    

0080062d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80062d:	55                   	push   %ebp
  80062e:	89 e5                	mov    %esp,%ebp
  800630:	57                   	push   %edi
  800631:	56                   	push   %esi
  800632:	53                   	push   %ebx
  800633:	83 ec 5c             	sub    $0x5c,%esp
  800636:	8b 7d 08             	mov    0x8(%ebp),%edi
  800639:	8b 75 0c             	mov    0xc(%ebp),%esi
  80063c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80063f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800646:	eb 11                	jmp    800659 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800648:	85 c0                	test   %eax,%eax
  80064a:	0f 84 68 04 00 00    	je     800ab8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800650:	89 74 24 04          	mov    %esi,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800659:	0f b6 03             	movzbl (%ebx),%eax
  80065c:	83 c3 01             	add    $0x1,%ebx
  80065f:	83 f8 25             	cmp    $0x25,%eax
  800662:	75 e4                	jne    800648 <vprintfmt+0x1b>
  800664:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80066b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800672:	b9 00 00 00 00       	mov    $0x0,%ecx
  800677:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80067b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800682:	eb 06                	jmp    80068a <vprintfmt+0x5d>
  800684:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800688:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068a:	0f b6 13             	movzbl (%ebx),%edx
  80068d:	0f b6 c2             	movzbl %dl,%eax
  800690:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800693:	8d 43 01             	lea    0x1(%ebx),%eax
  800696:	83 ea 23             	sub    $0x23,%edx
  800699:	80 fa 55             	cmp    $0x55,%dl
  80069c:	0f 87 f9 03 00 00    	ja     800a9b <vprintfmt+0x46e>
  8006a2:	0f b6 d2             	movzbl %dl,%edx
  8006a5:	ff 24 95 40 2f 80 00 	jmp    *0x802f40(,%edx,4)
  8006ac:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8006b0:	eb d6                	jmp    800688 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8006b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b5:	83 ea 30             	sub    $0x30,%edx
  8006b8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8006bb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8006be:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8006c1:	83 fb 09             	cmp    $0x9,%ebx
  8006c4:	77 54                	ja     80071a <vprintfmt+0xed>
  8006c6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006cc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8006cf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8006d2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8006d6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8006d9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8006dc:	83 fb 09             	cmp    $0x9,%ebx
  8006df:	76 eb                	jbe    8006cc <vprintfmt+0x9f>
  8006e1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006e7:	eb 31                	jmp    80071a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006e9:	8b 55 14             	mov    0x14(%ebp),%edx
  8006ec:	8d 5a 04             	lea    0x4(%edx),%ebx
  8006ef:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8006f2:	8b 12                	mov    (%edx),%edx
  8006f4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8006f7:	eb 21                	jmp    80071a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8006f9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800702:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800706:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800709:	e9 7a ff ff ff       	jmp    800688 <vprintfmt+0x5b>
  80070e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800715:	e9 6e ff ff ff       	jmp    800688 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80071a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071e:	0f 89 64 ff ff ff    	jns    800688 <vprintfmt+0x5b>
  800724:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800727:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80072a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80072d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800730:	e9 53 ff ff ff       	jmp    800688 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800735:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800738:	e9 4b ff ff ff       	jmp    800688 <vprintfmt+0x5b>
  80073d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 50 04             	lea    0x4(%eax),%edx
  800746:	89 55 14             	mov    %edx,0x14(%ebp)
  800749:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074d:	8b 00                	mov    (%eax),%eax
  80074f:	89 04 24             	mov    %eax,(%esp)
  800752:	ff d7                	call   *%edi
  800754:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800757:	e9 fd fe ff ff       	jmp    800659 <vprintfmt+0x2c>
  80075c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	89 c2                	mov    %eax,%edx
  80076c:	c1 fa 1f             	sar    $0x1f,%edx
  80076f:	31 d0                	xor    %edx,%eax
  800771:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800773:	83 f8 0f             	cmp    $0xf,%eax
  800776:	7f 0b                	jg     800783 <vprintfmt+0x156>
  800778:	8b 14 85 a0 30 80 00 	mov    0x8030a0(,%eax,4),%edx
  80077f:	85 d2                	test   %edx,%edx
  800781:	75 20                	jne    8007a3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800783:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800787:	c7 44 24 08 64 2d 80 	movl   $0x802d64,0x8(%esp)
  80078e:	00 
  80078f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800793:	89 3c 24             	mov    %edi,(%esp)
  800796:	e8 a5 03 00 00       	call   800b40 <printfmt>
  80079b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80079e:	e9 b6 fe ff ff       	jmp    800659 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8007a3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a7:	c7 44 24 08 bb 31 80 	movl   $0x8031bb,0x8(%esp)
  8007ae:	00 
  8007af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b3:	89 3c 24             	mov    %edi,(%esp)
  8007b6:	e8 85 03 00 00       	call   800b40 <printfmt>
  8007bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007be:	e9 96 fe ff ff       	jmp    800659 <vprintfmt+0x2c>
  8007c3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007c6:	89 c3                	mov    %eax,%ebx
  8007c8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8007ce:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 50 04             	lea    0x4(%eax),%edx
  8007d7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007da:	8b 00                	mov    (%eax),%eax
  8007dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	b8 6d 2d 80 00       	mov    $0x802d6d,%eax
  8007e6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8007ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8007ed:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8007f1:	7e 06                	jle    8007f9 <vprintfmt+0x1cc>
  8007f3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8007f7:	75 13                	jne    80080c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007f9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007fc:	0f be 02             	movsbl (%edx),%eax
  8007ff:	85 c0                	test   %eax,%eax
  800801:	0f 85 a2 00 00 00    	jne    8008a9 <vprintfmt+0x27c>
  800807:	e9 8f 00 00 00       	jmp    80089b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80080c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800810:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800813:	89 0c 24             	mov    %ecx,(%esp)
  800816:	e8 70 03 00 00       	call   800b8b <strnlen>
  80081b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80081e:	29 c2                	sub    %eax,%edx
  800820:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800823:	85 d2                	test   %edx,%edx
  800825:	7e d2                	jle    8007f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800827:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80082b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80082e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800831:	89 d3                	mov    %edx,%ebx
  800833:	89 74 24 04          	mov    %esi,0x4(%esp)
  800837:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80083a:	89 04 24             	mov    %eax,(%esp)
  80083d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80083f:	83 eb 01             	sub    $0x1,%ebx
  800842:	85 db                	test   %ebx,%ebx
  800844:	7f ed                	jg     800833 <vprintfmt+0x206>
  800846:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800849:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800850:	eb a7                	jmp    8007f9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800852:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800856:	74 1b                	je     800873 <vprintfmt+0x246>
  800858:	8d 50 e0             	lea    -0x20(%eax),%edx
  80085b:	83 fa 5e             	cmp    $0x5e,%edx
  80085e:	76 13                	jbe    800873 <vprintfmt+0x246>
					putch('?', putdat);
  800860:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800863:	89 54 24 04          	mov    %edx,0x4(%esp)
  800867:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80086e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800871:	eb 0d                	jmp    800880 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800873:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800876:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80087a:	89 04 24             	mov    %eax,(%esp)
  80087d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800880:	83 ef 01             	sub    $0x1,%edi
  800883:	0f be 03             	movsbl (%ebx),%eax
  800886:	85 c0                	test   %eax,%eax
  800888:	74 05                	je     80088f <vprintfmt+0x262>
  80088a:	83 c3 01             	add    $0x1,%ebx
  80088d:	eb 31                	jmp    8008c0 <vprintfmt+0x293>
  80088f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800892:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800895:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800898:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80089b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80089f:	7f 36                	jg     8008d7 <vprintfmt+0x2aa>
  8008a1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8008a4:	e9 b0 fd ff ff       	jmp    800659 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008ac:	83 c2 01             	add    $0x1,%edx
  8008af:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8008b2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8008b5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8008b8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8008bb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8008be:	89 d3                	mov    %edx,%ebx
  8008c0:	85 f6                	test   %esi,%esi
  8008c2:	78 8e                	js     800852 <vprintfmt+0x225>
  8008c4:	83 ee 01             	sub    $0x1,%esi
  8008c7:	79 89                	jns    800852 <vprintfmt+0x225>
  8008c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8008cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008cf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8008d2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8008d5:	eb c4                	jmp    80089b <vprintfmt+0x26e>
  8008d7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8008da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8008dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8008e8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8008ea:	83 eb 01             	sub    $0x1,%ebx
  8008ed:	85 db                	test   %ebx,%ebx
  8008ef:	7f ec                	jg     8008dd <vprintfmt+0x2b0>
  8008f1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8008f4:	e9 60 fd ff ff       	jmp    800659 <vprintfmt+0x2c>
  8008f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008fc:	83 f9 01             	cmp    $0x1,%ecx
  8008ff:	7e 16                	jle    800917 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800901:	8b 45 14             	mov    0x14(%ebp),%eax
  800904:	8d 50 08             	lea    0x8(%eax),%edx
  800907:	89 55 14             	mov    %edx,0x14(%ebp)
  80090a:	8b 10                	mov    (%eax),%edx
  80090c:	8b 48 04             	mov    0x4(%eax),%ecx
  80090f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800912:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800915:	eb 32                	jmp    800949 <vprintfmt+0x31c>
	else if (lflag)
  800917:	85 c9                	test   %ecx,%ecx
  800919:	74 18                	je     800933 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80091b:	8b 45 14             	mov    0x14(%ebp),%eax
  80091e:	8d 50 04             	lea    0x4(%eax),%edx
  800921:	89 55 14             	mov    %edx,0x14(%ebp)
  800924:	8b 00                	mov    (%eax),%eax
  800926:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800929:	89 c1                	mov    %eax,%ecx
  80092b:	c1 f9 1f             	sar    $0x1f,%ecx
  80092e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800931:	eb 16                	jmp    800949 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800933:	8b 45 14             	mov    0x14(%ebp),%eax
  800936:	8d 50 04             	lea    0x4(%eax),%edx
  800939:	89 55 14             	mov    %edx,0x14(%ebp)
  80093c:	8b 00                	mov    (%eax),%eax
  80093e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800941:	89 c2                	mov    %eax,%edx
  800943:	c1 fa 1f             	sar    $0x1f,%edx
  800946:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800949:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80094c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80094f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800954:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800958:	0f 89 8a 00 00 00    	jns    8009e8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80095e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800962:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800969:	ff d7                	call   *%edi
				num = -(long long) num;
  80096b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80096e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800971:	f7 d8                	neg    %eax
  800973:	83 d2 00             	adc    $0x0,%edx
  800976:	f7 da                	neg    %edx
  800978:	eb 6e                	jmp    8009e8 <vprintfmt+0x3bb>
  80097a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80097d:	89 ca                	mov    %ecx,%edx
  80097f:	8d 45 14             	lea    0x14(%ebp),%eax
  800982:	e8 4f fc ff ff       	call   8005d6 <getuint>
  800987:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80098c:	eb 5a                	jmp    8009e8 <vprintfmt+0x3bb>
  80098e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800991:	89 ca                	mov    %ecx,%edx
  800993:	8d 45 14             	lea    0x14(%ebp),%eax
  800996:	e8 3b fc ff ff       	call   8005d6 <getuint>
  80099b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8009a0:	eb 46                	jmp    8009e8 <vprintfmt+0x3bb>
  8009a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8009a5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8009b0:	ff d7                	call   *%edi
			putch('x', putdat);
  8009b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8009bd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8009bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c2:	8d 50 04             	lea    0x4(%eax),%edx
  8009c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c8:	8b 00                	mov    (%eax),%eax
  8009ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8009d4:	eb 12                	jmp    8009e8 <vprintfmt+0x3bb>
  8009d6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8009d9:	89 ca                	mov    %ecx,%edx
  8009db:	8d 45 14             	lea    0x14(%ebp),%eax
  8009de:	e8 f3 fb ff ff       	call   8005d6 <getuint>
  8009e3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8009e8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8009ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8009f0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8009f3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8009f7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8009fb:	89 04 24             	mov    %eax,(%esp)
  8009fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a02:	89 f2                	mov    %esi,%edx
  800a04:	89 f8                	mov    %edi,%eax
  800a06:	e8 d5 fa ff ff       	call   8004e0 <printnum>
  800a0b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a0e:	e9 46 fc ff ff       	jmp    800659 <vprintfmt+0x2c>
  800a13:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800a16:	8b 45 14             	mov    0x14(%ebp),%eax
  800a19:	8d 50 04             	lea    0x4(%eax),%edx
  800a1c:	89 55 14             	mov    %edx,0x14(%ebp)
  800a1f:	8b 00                	mov    (%eax),%eax
  800a21:	85 c0                	test   %eax,%eax
  800a23:	75 24                	jne    800a49 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800a25:	c7 44 24 0c 88 2e 80 	movl   $0x802e88,0xc(%esp)
  800a2c:	00 
  800a2d:	c7 44 24 08 bb 31 80 	movl   $0x8031bb,0x8(%esp)
  800a34:	00 
  800a35:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a39:	89 3c 24             	mov    %edi,(%esp)
  800a3c:	e8 ff 00 00 00       	call   800b40 <printfmt>
  800a41:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a44:	e9 10 fc ff ff       	jmp    800659 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800a49:	83 3e 7f             	cmpl   $0x7f,(%esi)
  800a4c:	7e 29                	jle    800a77 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  800a4e:	0f b6 16             	movzbl (%esi),%edx
  800a51:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800a53:	c7 44 24 0c c0 2e 80 	movl   $0x802ec0,0xc(%esp)
  800a5a:	00 
  800a5b:	c7 44 24 08 bb 31 80 	movl   $0x8031bb,0x8(%esp)
  800a62:	00 
  800a63:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a67:	89 3c 24             	mov    %edi,(%esp)
  800a6a:	e8 d1 00 00 00       	call   800b40 <printfmt>
  800a6f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a72:	e9 e2 fb ff ff       	jmp    800659 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800a77:	0f b6 16             	movzbl (%esi),%edx
  800a7a:	88 10                	mov    %dl,(%eax)
  800a7c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  800a7f:	e9 d5 fb ff ff       	jmp    800659 <vprintfmt+0x2c>
  800a84:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a87:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800a8a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a8e:	89 14 24             	mov    %edx,(%esp)
  800a91:	ff d7                	call   *%edi
  800a93:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800a96:	e9 be fb ff ff       	jmp    800659 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800a9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a9f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800aa6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800aa8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800aab:	80 38 25             	cmpb   $0x25,(%eax)
  800aae:	0f 84 a5 fb ff ff    	je     800659 <vprintfmt+0x2c>
  800ab4:	89 c3                	mov    %eax,%ebx
  800ab6:	eb f0                	jmp    800aa8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800ab8:	83 c4 5c             	add    $0x5c,%esp
  800abb:	5b                   	pop    %ebx
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	83 ec 28             	sub    $0x28,%esp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800acc:	85 c0                	test   %eax,%eax
  800ace:	74 04                	je     800ad4 <vsnprintf+0x14>
  800ad0:	85 d2                	test   %edx,%edx
  800ad2:	7f 07                	jg     800adb <vsnprintf+0x1b>
  800ad4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ad9:	eb 3b                	jmp    800b16 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800adb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ade:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ae2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ae5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800aec:	8b 45 14             	mov    0x14(%ebp),%eax
  800aef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800af3:	8b 45 10             	mov    0x10(%ebp),%eax
  800af6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800afa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800afd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b01:	c7 04 24 10 06 80 00 	movl   $0x800610,(%esp)
  800b08:	e8 20 fb ff ff       	call   80062d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b10:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b16:	c9                   	leave  
  800b17:	c3                   	ret    

00800b18 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b1e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b25:	8b 45 10             	mov    0x10(%ebp),%eax
  800b28:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	89 04 24             	mov    %eax,(%esp)
  800b39:	e8 82 ff ff ff       	call   800ac0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800b3e:	c9                   	leave  
  800b3f:	c3                   	ret    

00800b40 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b46:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800b50:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	89 04 24             	mov    %eax,(%esp)
  800b61:	e8 c7 fa ff ff       	call   80062d <vprintfmt>
	va_end(ap);
}
  800b66:	c9                   	leave  
  800b67:	c3                   	ret    
	...

00800b70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b76:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800b7e:	74 09                	je     800b89 <strlen+0x19>
		n++;
  800b80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800b83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b87:	75 f7                	jne    800b80 <strlen+0x10>
		n++;
	return n;
}
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	53                   	push   %ebx
  800b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800b92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b95:	85 c9                	test   %ecx,%ecx
  800b97:	74 19                	je     800bb2 <strnlen+0x27>
  800b99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800b9c:	74 14                	je     800bb2 <strnlen+0x27>
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800ba3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ba6:	39 c8                	cmp    %ecx,%eax
  800ba8:	74 0d                	je     800bb7 <strnlen+0x2c>
  800baa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bae:	75 f3                	jne    800ba3 <strnlen+0x18>
  800bb0:	eb 05                	jmp    800bb7 <strnlen+0x2c>
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bcd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800bd0:	83 c2 01             	add    $0x1,%edx
  800bd3:	84 c9                	test   %cl,%cl
  800bd5:	75 f2                	jne    800bc9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <strcat>:

char *
strcat(char *dst, const char *src)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 08             	sub    $0x8,%esp
  800be1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800be4:	89 1c 24             	mov    %ebx,(%esp)
  800be7:	e8 84 ff ff ff       	call   800b70 <strlen>
	strcpy(dst + len, src);
  800bec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bef:	89 54 24 04          	mov    %edx,0x4(%esp)
  800bf3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800bf6:	89 04 24             	mov    %eax,(%esp)
  800bf9:	e8 bc ff ff ff       	call   800bba <strcpy>
	return dst;
}
  800bfe:	89 d8                	mov    %ebx,%eax
  800c00:	83 c4 08             	add    $0x8,%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	56                   	push   %esi
  800c0a:	53                   	push   %ebx
  800c0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c14:	85 f6                	test   %esi,%esi
  800c16:	74 18                	je     800c30 <strncpy+0x2a>
  800c18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c1d:	0f b6 1a             	movzbl (%edx),%ebx
  800c20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c23:	80 3a 01             	cmpb   $0x1,(%edx)
  800c26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c29:	83 c1 01             	add    $0x1,%ecx
  800c2c:	39 ce                	cmp    %ecx,%esi
  800c2e:	77 ed                	ja     800c1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	8b 75 08             	mov    0x8(%ebp),%esi
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c42:	89 f0                	mov    %esi,%eax
  800c44:	85 c9                	test   %ecx,%ecx
  800c46:	74 27                	je     800c6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c48:	83 e9 01             	sub    $0x1,%ecx
  800c4b:	74 1d                	je     800c6a <strlcpy+0x36>
  800c4d:	0f b6 1a             	movzbl (%edx),%ebx
  800c50:	84 db                	test   %bl,%bl
  800c52:	74 16                	je     800c6a <strlcpy+0x36>
			*dst++ = *src++;
  800c54:	88 18                	mov    %bl,(%eax)
  800c56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c59:	83 e9 01             	sub    $0x1,%ecx
  800c5c:	74 0e                	je     800c6c <strlcpy+0x38>
			*dst++ = *src++;
  800c5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c61:	0f b6 1a             	movzbl (%edx),%ebx
  800c64:	84 db                	test   %bl,%bl
  800c66:	75 ec                	jne    800c54 <strlcpy+0x20>
  800c68:	eb 02                	jmp    800c6c <strlcpy+0x38>
  800c6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c6c:	c6 00 00             	movb   $0x0,(%eax)
  800c6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5d                   	pop    %ebp
  800c74:	c3                   	ret    

00800c75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c7e:	0f b6 01             	movzbl (%ecx),%eax
  800c81:	84 c0                	test   %al,%al
  800c83:	74 15                	je     800c9a <strcmp+0x25>
  800c85:	3a 02                	cmp    (%edx),%al
  800c87:	75 11                	jne    800c9a <strcmp+0x25>
		p++, q++;
  800c89:	83 c1 01             	add    $0x1,%ecx
  800c8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800c8f:	0f b6 01             	movzbl (%ecx),%eax
  800c92:	84 c0                	test   %al,%al
  800c94:	74 04                	je     800c9a <strcmp+0x25>
  800c96:	3a 02                	cmp    (%edx),%al
  800c98:	74 ef                	je     800c89 <strcmp+0x14>
  800c9a:	0f b6 c0             	movzbl %al,%eax
  800c9d:	0f b6 12             	movzbl (%edx),%edx
  800ca0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	53                   	push   %ebx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800cb1:	85 c0                	test   %eax,%eax
  800cb3:	74 23                	je     800cd8 <strncmp+0x34>
  800cb5:	0f b6 1a             	movzbl (%edx),%ebx
  800cb8:	84 db                	test   %bl,%bl
  800cba:	74 25                	je     800ce1 <strncmp+0x3d>
  800cbc:	3a 19                	cmp    (%ecx),%bl
  800cbe:	75 21                	jne    800ce1 <strncmp+0x3d>
  800cc0:	83 e8 01             	sub    $0x1,%eax
  800cc3:	74 13                	je     800cd8 <strncmp+0x34>
		n--, p++, q++;
  800cc5:	83 c2 01             	add    $0x1,%edx
  800cc8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ccb:	0f b6 1a             	movzbl (%edx),%ebx
  800cce:	84 db                	test   %bl,%bl
  800cd0:	74 0f                	je     800ce1 <strncmp+0x3d>
  800cd2:	3a 19                	cmp    (%ecx),%bl
  800cd4:	74 ea                	je     800cc0 <strncmp+0x1c>
  800cd6:	eb 09                	jmp    800ce1 <strncmp+0x3d>
  800cd8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5d                   	pop    %ebp
  800cdf:	90                   	nop
  800ce0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ce1:	0f b6 02             	movzbl (%edx),%eax
  800ce4:	0f b6 11             	movzbl (%ecx),%edx
  800ce7:	29 d0                	sub    %edx,%eax
  800ce9:	eb f2                	jmp    800cdd <strncmp+0x39>

00800ceb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ceb:	55                   	push   %ebp
  800cec:	89 e5                	mov    %esp,%ebp
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cf5:	0f b6 10             	movzbl (%eax),%edx
  800cf8:	84 d2                	test   %dl,%dl
  800cfa:	74 18                	je     800d14 <strchr+0x29>
		if (*s == c)
  800cfc:	38 ca                	cmp    %cl,%dl
  800cfe:	75 0a                	jne    800d0a <strchr+0x1f>
  800d00:	eb 17                	jmp    800d19 <strchr+0x2e>
  800d02:	38 ca                	cmp    %cl,%dl
  800d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d08:	74 0f                	je     800d19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d0a:	83 c0 01             	add    $0x1,%eax
  800d0d:	0f b6 10             	movzbl (%eax),%edx
  800d10:	84 d2                	test   %dl,%dl
  800d12:	75 ee                	jne    800d02 <strchr+0x17>
  800d14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	74 18                	je     800d44 <strfind+0x29>
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	75 0a                	jne    800d3a <strfind+0x1f>
  800d30:	eb 12                	jmp    800d44 <strfind+0x29>
  800d32:	38 ca                	cmp    %cl,%dl
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	74 0a                	je     800d44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	0f b6 10             	movzbl (%eax),%edx
  800d40:	84 d2                	test   %dl,%dl
  800d42:	75 ee                	jne    800d32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	89 1c 24             	mov    %ebx,(%esp)
  800d4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d60:	85 c9                	test   %ecx,%ecx
  800d62:	74 30                	je     800d94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d6a:	75 25                	jne    800d91 <memset+0x4b>
  800d6c:	f6 c1 03             	test   $0x3,%cl
  800d6f:	75 20                	jne    800d91 <memset+0x4b>
		c &= 0xFF;
  800d71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d74:	89 d3                	mov    %edx,%ebx
  800d76:	c1 e3 08             	shl    $0x8,%ebx
  800d79:	89 d6                	mov    %edx,%esi
  800d7b:	c1 e6 18             	shl    $0x18,%esi
  800d7e:	89 d0                	mov    %edx,%eax
  800d80:	c1 e0 10             	shl    $0x10,%eax
  800d83:	09 f0                	or     %esi,%eax
  800d85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800d87:	09 d8                	or     %ebx,%eax
  800d89:	c1 e9 02             	shr    $0x2,%ecx
  800d8c:	fc                   	cld    
  800d8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d8f:	eb 03                	jmp    800d94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d91:	fc                   	cld    
  800d92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800d94:	89 f8                	mov    %edi,%eax
  800d96:	8b 1c 24             	mov    (%esp),%ebx
  800d99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da1:	89 ec                	mov    %ebp,%esp
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	89 34 24             	mov    %esi,(%esp)
  800dae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800db8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dbd:	39 c6                	cmp    %eax,%esi
  800dbf:	73 35                	jae    800df6 <memmove+0x51>
  800dc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800dc4:	39 d0                	cmp    %edx,%eax
  800dc6:	73 2e                	jae    800df6 <memmove+0x51>
		s += n;
		d += n;
  800dc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dca:	f6 c2 03             	test   $0x3,%dl
  800dcd:	75 1b                	jne    800dea <memmove+0x45>
  800dcf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dd5:	75 13                	jne    800dea <memmove+0x45>
  800dd7:	f6 c1 03             	test   $0x3,%cl
  800dda:	75 0e                	jne    800dea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800ddc:	83 ef 04             	sub    $0x4,%edi
  800ddf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800de2:	c1 e9 02             	shr    $0x2,%ecx
  800de5:	fd                   	std    
  800de6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800de8:	eb 09                	jmp    800df3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800dea:	83 ef 01             	sub    $0x1,%edi
  800ded:	8d 72 ff             	lea    -0x1(%edx),%esi
  800df0:	fd                   	std    
  800df1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800df3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800df4:	eb 20                	jmp    800e16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800df6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800dfc:	75 15                	jne    800e13 <memmove+0x6e>
  800dfe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e04:	75 0d                	jne    800e13 <memmove+0x6e>
  800e06:	f6 c1 03             	test   $0x3,%cl
  800e09:	75 08                	jne    800e13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e0b:	c1 e9 02             	shr    $0x2,%ecx
  800e0e:	fc                   	cld    
  800e0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e11:	eb 03                	jmp    800e16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e13:	fc                   	cld    
  800e14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e16:	8b 34 24             	mov    (%esp),%esi
  800e19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e1d:	89 ec                	mov    %ebp,%esp
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e27:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e35:	8b 45 08             	mov    0x8(%ebp),%eax
  800e38:	89 04 24             	mov    %eax,(%esp)
  800e3b:	e8 65 ff ff ff       	call   800da5 <memmove>
}
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	8b 75 08             	mov    0x8(%ebp),%esi
  800e4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e51:	85 c9                	test   %ecx,%ecx
  800e53:	74 36                	je     800e8b <memcmp+0x49>
		if (*s1 != *s2)
  800e55:	0f b6 06             	movzbl (%esi),%eax
  800e58:	0f b6 1f             	movzbl (%edi),%ebx
  800e5b:	38 d8                	cmp    %bl,%al
  800e5d:	74 20                	je     800e7f <memcmp+0x3d>
  800e5f:	eb 14                	jmp    800e75 <memcmp+0x33>
  800e61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e6b:	83 c2 01             	add    $0x1,%edx
  800e6e:	83 e9 01             	sub    $0x1,%ecx
  800e71:	38 d8                	cmp    %bl,%al
  800e73:	74 12                	je     800e87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800e75:	0f b6 c0             	movzbl %al,%eax
  800e78:	0f b6 db             	movzbl %bl,%ebx
  800e7b:	29 d8                	sub    %ebx,%eax
  800e7d:	eb 11                	jmp    800e90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e7f:	83 e9 01             	sub    $0x1,%ecx
  800e82:	ba 00 00 00 00       	mov    $0x0,%edx
  800e87:	85 c9                	test   %ecx,%ecx
  800e89:	75 d6                	jne    800e61 <memcmp+0x1f>
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800e9b:	89 c2                	mov    %eax,%edx
  800e9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea0:	39 d0                	cmp    %edx,%eax
  800ea2:	73 15                	jae    800eb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ea8:	38 08                	cmp    %cl,(%eax)
  800eaa:	75 06                	jne    800eb2 <memfind+0x1d>
  800eac:	eb 0b                	jmp    800eb9 <memfind+0x24>
  800eae:	38 08                	cmp    %cl,(%eax)
  800eb0:	74 07                	je     800eb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800eb2:	83 c0 01             	add    $0x1,%eax
  800eb5:	39 c2                	cmp    %eax,%edx
  800eb7:	77 f5                	ja     800eae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    

00800ebb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	57                   	push   %edi
  800ebf:	56                   	push   %esi
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 04             	sub    $0x4,%esp
  800ec4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800eca:	0f b6 02             	movzbl (%edx),%eax
  800ecd:	3c 20                	cmp    $0x20,%al
  800ecf:	74 04                	je     800ed5 <strtol+0x1a>
  800ed1:	3c 09                	cmp    $0x9,%al
  800ed3:	75 0e                	jne    800ee3 <strtol+0x28>
		s++;
  800ed5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ed8:	0f b6 02             	movzbl (%edx),%eax
  800edb:	3c 20                	cmp    $0x20,%al
  800edd:	74 f6                	je     800ed5 <strtol+0x1a>
  800edf:	3c 09                	cmp    $0x9,%al
  800ee1:	74 f2                	je     800ed5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ee3:	3c 2b                	cmp    $0x2b,%al
  800ee5:	75 0c                	jne    800ef3 <strtol+0x38>
		s++;
  800ee7:	83 c2 01             	add    $0x1,%edx
  800eea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ef1:	eb 15                	jmp    800f08 <strtol+0x4d>
	else if (*s == '-')
  800ef3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800efa:	3c 2d                	cmp    $0x2d,%al
  800efc:	75 0a                	jne    800f08 <strtol+0x4d>
		s++, neg = 1;
  800efe:	83 c2 01             	add    $0x1,%edx
  800f01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f08:	85 db                	test   %ebx,%ebx
  800f0a:	0f 94 c0             	sete   %al
  800f0d:	74 05                	je     800f14 <strtol+0x59>
  800f0f:	83 fb 10             	cmp    $0x10,%ebx
  800f12:	75 18                	jne    800f2c <strtol+0x71>
  800f14:	80 3a 30             	cmpb   $0x30,(%edx)
  800f17:	75 13                	jne    800f2c <strtol+0x71>
  800f19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f1d:	8d 76 00             	lea    0x0(%esi),%esi
  800f20:	75 0a                	jne    800f2c <strtol+0x71>
		s += 2, base = 16;
  800f22:	83 c2 02             	add    $0x2,%edx
  800f25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f2a:	eb 15                	jmp    800f41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f2c:	84 c0                	test   %al,%al
  800f2e:	66 90                	xchg   %ax,%ax
  800f30:	74 0f                	je     800f41 <strtol+0x86>
  800f32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f37:	80 3a 30             	cmpb   $0x30,(%edx)
  800f3a:	75 05                	jne    800f41 <strtol+0x86>
		s++, base = 8;
  800f3c:	83 c2 01             	add    $0x1,%edx
  800f3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
  800f46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f48:	0f b6 0a             	movzbl (%edx),%ecx
  800f4b:	89 cf                	mov    %ecx,%edi
  800f4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f50:	80 fb 09             	cmp    $0x9,%bl
  800f53:	77 08                	ja     800f5d <strtol+0xa2>
			dig = *s - '0';
  800f55:	0f be c9             	movsbl %cl,%ecx
  800f58:	83 e9 30             	sub    $0x30,%ecx
  800f5b:	eb 1e                	jmp    800f7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f60:	80 fb 19             	cmp    $0x19,%bl
  800f63:	77 08                	ja     800f6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f65:	0f be c9             	movsbl %cl,%ecx
  800f68:	83 e9 57             	sub    $0x57,%ecx
  800f6b:	eb 0e                	jmp    800f7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800f70:	80 fb 19             	cmp    $0x19,%bl
  800f73:	77 15                	ja     800f8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800f75:	0f be c9             	movsbl %cl,%ecx
  800f78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800f7b:	39 f1                	cmp    %esi,%ecx
  800f7d:	7d 0b                	jge    800f8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800f7f:	83 c2 01             	add    $0x1,%edx
  800f82:	0f af c6             	imul   %esi,%eax
  800f85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800f88:	eb be                	jmp    800f48 <strtol+0x8d>
  800f8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800f8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f90:	74 05                	je     800f97 <strtol+0xdc>
		*endptr = (char *) s;
  800f92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800f95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800f97:	89 ca                	mov    %ecx,%edx
  800f99:	f7 da                	neg    %edx
  800f9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800f9f:	0f 45 c2             	cmovne %edx,%eax
}
  800fa2:	83 c4 04             	add    $0x4,%esp
  800fa5:	5b                   	pop    %ebx
  800fa6:	5e                   	pop    %esi
  800fa7:	5f                   	pop    %edi
  800fa8:	5d                   	pop    %ebp
  800fa9:	c3                   	ret    
	...

00800fac <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 48             	sub    $0x48,%esp
  800fb2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fb5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800fbb:	89 c6                	mov    %eax,%esi
  800fbd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800fc0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800fc2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800fc5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fcb:	51                   	push   %ecx
  800fcc:	52                   	push   %edx
  800fcd:	53                   	push   %ebx
  800fce:	54                   	push   %esp
  800fcf:	55                   	push   %ebp
  800fd0:	56                   	push   %esi
  800fd1:	57                   	push   %edi
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	8d 35 dc 0f 80 00    	lea    0x800fdc,%esi
  800fda:	0f 34                	sysenter 

00800fdc <.after_sysenter_label>:
  800fdc:	5f                   	pop    %edi
  800fdd:	5e                   	pop    %esi
  800fde:	5d                   	pop    %ebp
  800fdf:	5c                   	pop    %esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5a                   	pop    %edx
  800fe2:	59                   	pop    %ecx
  800fe3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800fe5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800fe9:	74 28                	je     801013 <.after_sysenter_label+0x37>
  800feb:	85 c0                	test   %eax,%eax
  800fed:	7e 24                	jle    801013 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fef:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ff3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ff7:	c7 44 24 08 e0 30 80 	movl   $0x8030e0,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 fd 30 80 00 	movl   $0x8030fd,(%esp)
  80100e:	e8 a9 f3 ff ff       	call   8003bc <_panic>

	return ret;
}
  801013:	89 d0                	mov    %edx,%eax
  801015:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801018:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80101b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80101e:	89 ec                	mov    %ebp,%esp
  801020:	5d                   	pop    %ebp
  801021:	c3                   	ret    

00801022 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  801028:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80102f:	00 
  801030:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801037:	00 
  801038:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103f:	00 
  801040:	8b 45 0c             	mov    0xc(%ebp),%eax
  801043:	89 04 24             	mov    %eax,(%esp)
  801046:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801049:	ba 00 00 00 00       	mov    $0x0,%edx
  80104e:	b8 10 00 00 00       	mov    $0x10,%eax
  801053:	e8 54 ff ff ff       	call   800fac <syscall>
}
  801058:	c9                   	leave  
  801059:	c3                   	ret    

0080105a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  801060:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801067:	00 
  801068:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106f:	00 
  801070:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801077:	00 
  801078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801084:	ba 00 00 00 00       	mov    $0x0,%edx
  801089:	b8 0f 00 00 00       	mov    $0xf,%eax
  80108e:	e8 19 ff ff ff       	call   800fac <syscall>
}
  801093:	c9                   	leave  
  801094:	c3                   	ret    

00801095 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80109b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a2:	00 
  8010a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010aa:	00 
  8010ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b2:	00 
  8010b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bd:	ba 01 00 00 00       	mov    $0x1,%edx
  8010c2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8010c7:	e8 e0 fe ff ff       	call   800fac <syscall>
}
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    

008010ce <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010db:	00 
  8010dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8010df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010ed:	89 04 24             	mov    %eax,(%esp)
  8010f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f8:	b8 0d 00 00 00       	mov    $0xd,%eax
  8010fd:	e8 aa fe ff ff       	call   800fac <syscall>
}
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80110a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801111:	00 
  801112:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801119:	00 
  80111a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801121:	00 
  801122:	8b 45 0c             	mov    0xc(%ebp),%eax
  801125:	89 04 24             	mov    %eax,(%esp)
  801128:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112b:	ba 01 00 00 00       	mov    $0x1,%edx
  801130:	b8 0b 00 00 00       	mov    $0xb,%eax
  801135:	e8 72 fe ff ff       	call   800fac <syscall>
}
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    

0080113c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801142:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801149:	00 
  80114a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801151:	00 
  801152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801159:	00 
  80115a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115d:	89 04 24             	mov    %eax,(%esp)
  801160:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801163:	ba 01 00 00 00       	mov    $0x1,%edx
  801168:	b8 0a 00 00 00       	mov    $0xa,%eax
  80116d:	e8 3a fe ff ff       	call   800fac <syscall>
}
  801172:	c9                   	leave  
  801173:	c3                   	ret    

00801174 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801174:	55                   	push   %ebp
  801175:	89 e5                	mov    %esp,%ebp
  801177:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80117a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801181:	00 
  801182:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801189:	00 
  80118a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801191:	00 
  801192:	8b 45 0c             	mov    0xc(%ebp),%eax
  801195:	89 04 24             	mov    %eax,(%esp)
  801198:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119b:	ba 01 00 00 00       	mov    $0x1,%edx
  8011a0:	b8 09 00 00 00       	mov    $0x9,%eax
  8011a5:	e8 02 fe ff ff       	call   800fac <syscall>
}
  8011aa:	c9                   	leave  
  8011ab:	c3                   	ret    

008011ac <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8011b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011b9:	00 
  8011ba:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011c1:	00 
  8011c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8011c9:	00 
  8011ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011cd:	89 04 24             	mov    %eax,(%esp)
  8011d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d3:	ba 01 00 00 00       	mov    $0x1,%edx
  8011d8:	b8 07 00 00 00       	mov    $0x7,%eax
  8011dd:	e8 ca fd ff ff       	call   800fac <syscall>
}
  8011e2:	c9                   	leave  
  8011e3:	c3                   	ret    

008011e4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
  8011e7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8011ea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8011f1:	00 
  8011f2:	8b 45 18             	mov    0x18(%ebp),%eax
  8011f5:	0b 45 14             	or     0x14(%ebp),%eax
  8011f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801203:	8b 45 0c             	mov    0xc(%ebp),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120c:	ba 01 00 00 00       	mov    $0x1,%edx
  801211:	b8 06 00 00 00       	mov    $0x6,%eax
  801216:	e8 91 fd ff ff       	call   800fac <syscall>
}
  80121b:	c9                   	leave  
  80121c:	c3                   	ret    

0080121d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80121d:	55                   	push   %ebp
  80121e:	89 e5                	mov    %esp,%ebp
  801220:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801223:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80122a:	00 
  80122b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801232:	00 
  801233:	8b 45 10             	mov    0x10(%ebp),%eax
  801236:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80123d:	89 04 24             	mov    %eax,(%esp)
  801240:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801243:	ba 01 00 00 00       	mov    $0x1,%edx
  801248:	b8 05 00 00 00       	mov    $0x5,%eax
  80124d:	e8 5a fd ff ff       	call   800fac <syscall>
}
  801252:	c9                   	leave  
  801253:	c3                   	ret    

00801254 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80125a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801261:	00 
  801262:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801269:	00 
  80126a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801271:	00 
  801272:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801279:	b9 00 00 00 00       	mov    $0x0,%ecx
  80127e:	ba 00 00 00 00       	mov    $0x0,%edx
  801283:	b8 0c 00 00 00       	mov    $0xc,%eax
  801288:	e8 1f fd ff ff       	call   800fac <syscall>
}
  80128d:	c9                   	leave  
  80128e:	c3                   	ret    

0080128f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80128f:	55                   	push   %ebp
  801290:	89 e5                	mov    %esp,%ebp
  801292:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801295:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80129c:	00 
  80129d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012a4:	00 
  8012a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012ac:	00 
  8012ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b0:	89 04 24             	mov    %eax,(%esp)
  8012b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8012bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8012c0:	e8 e7 fc ff ff       	call   800fac <syscall>
}
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    

008012c7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8012c7:	55                   	push   %ebp
  8012c8:	89 e5                	mov    %esp,%ebp
  8012ca:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8012cd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012d4:	00 
  8012d5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012dc:	00 
  8012dd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012e4:	00 
  8012e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f6:	b8 02 00 00 00       	mov    $0x2,%eax
  8012fb:	e8 ac fc ff ff       	call   800fac <syscall>
}
  801300:	c9                   	leave  
  801301:	c3                   	ret    

00801302 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801302:	55                   	push   %ebp
  801303:	89 e5                	mov    %esp,%ebp
  801305:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801308:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80130f:	00 
  801310:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801317:	00 
  801318:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80131f:	00 
  801320:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801327:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132a:	ba 01 00 00 00       	mov    $0x1,%edx
  80132f:	b8 03 00 00 00       	mov    $0x3,%eax
  801334:	e8 73 fc ff ff       	call   800fac <syscall>
}
  801339:	c9                   	leave  
  80133a:	c3                   	ret    

0080133b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80133b:	55                   	push   %ebp
  80133c:	89 e5                	mov    %esp,%ebp
  80133e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801341:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801348:	00 
  801349:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801350:	00 
  801351:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801358:	00 
  801359:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801360:	b9 00 00 00 00       	mov    $0x0,%ecx
  801365:	ba 00 00 00 00       	mov    $0x0,%edx
  80136a:	b8 01 00 00 00       	mov    $0x1,%eax
  80136f:	e8 38 fc ff ff       	call   800fac <syscall>
}
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80137c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801383:	00 
  801384:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80138b:	00 
  80138c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801393:	00 
  801394:	8b 45 0c             	mov    0xc(%ebp),%eax
  801397:	89 04 24             	mov    %eax,(%esp)
  80139a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80139d:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a7:	e8 00 fc ff ff       	call   800fac <syscall>
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    
	...

008013b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8013bb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8013c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c9:	89 04 24             	mov    %eax,(%esp)
  8013cc:	e8 df ff ff ff       	call   8013b0 <fd2num>
  8013d1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8013d6:	c1 e0 0c             	shl    $0xc,%eax
}
  8013d9:	c9                   	leave  
  8013da:	c3                   	ret    

008013db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	57                   	push   %edi
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8013e4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8013e9:	a8 01                	test   $0x1,%al
  8013eb:	74 36                	je     801423 <fd_alloc+0x48>
  8013ed:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8013f2:	a8 01                	test   $0x1,%al
  8013f4:	74 2d                	je     801423 <fd_alloc+0x48>
  8013f6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8013fb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801400:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801405:	89 c3                	mov    %eax,%ebx
  801407:	89 c2                	mov    %eax,%edx
  801409:	c1 ea 16             	shr    $0x16,%edx
  80140c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80140f:	f6 c2 01             	test   $0x1,%dl
  801412:	74 14                	je     801428 <fd_alloc+0x4d>
  801414:	89 c2                	mov    %eax,%edx
  801416:	c1 ea 0c             	shr    $0xc,%edx
  801419:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80141c:	f6 c2 01             	test   $0x1,%dl
  80141f:	75 10                	jne    801431 <fd_alloc+0x56>
  801421:	eb 05                	jmp    801428 <fd_alloc+0x4d>
  801423:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801428:	89 1f                	mov    %ebx,(%edi)
  80142a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80142f:	eb 17                	jmp    801448 <fd_alloc+0x6d>
  801431:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801436:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80143b:	75 c8                	jne    801405 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80143d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801443:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801448:	5b                   	pop    %ebx
  801449:	5e                   	pop    %esi
  80144a:	5f                   	pop    %edi
  80144b:	5d                   	pop    %ebp
  80144c:	c3                   	ret    

0080144d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801450:	8b 45 08             	mov    0x8(%ebp),%eax
  801453:	83 f8 1f             	cmp    $0x1f,%eax
  801456:	77 36                	ja     80148e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801458:	05 00 00 0d 00       	add    $0xd0000,%eax
  80145d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801460:	89 c2                	mov    %eax,%edx
  801462:	c1 ea 16             	shr    $0x16,%edx
  801465:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80146c:	f6 c2 01             	test   $0x1,%dl
  80146f:	74 1d                	je     80148e <fd_lookup+0x41>
  801471:	89 c2                	mov    %eax,%edx
  801473:	c1 ea 0c             	shr    $0xc,%edx
  801476:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80147d:	f6 c2 01             	test   $0x1,%dl
  801480:	74 0c                	je     80148e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801482:	8b 55 0c             	mov    0xc(%ebp),%edx
  801485:	89 02                	mov    %eax,(%edx)
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80148c:	eb 05                	jmp    801493 <fd_lookup+0x46>
  80148e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801493:	5d                   	pop    %ebp
  801494:	c3                   	ret    

00801495 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801495:	55                   	push   %ebp
  801496:	89 e5                	mov    %esp,%ebp
  801498:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80149b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80149e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	89 04 24             	mov    %eax,(%esp)
  8014a8:	e8 a0 ff ff ff       	call   80144d <fd_lookup>
  8014ad:	85 c0                	test   %eax,%eax
  8014af:	78 0e                	js     8014bf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8014b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014b7:	89 50 04             	mov    %edx,0x4(%eax)
  8014ba:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	56                   	push   %esi
  8014c5:	53                   	push   %ebx
  8014c6:	83 ec 10             	sub    $0x10,%esp
  8014c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8014cf:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8014d4:	b8 24 40 80 00       	mov    $0x804024,%eax
  8014d9:	39 0d 24 40 80 00    	cmp    %ecx,0x804024
  8014df:	75 11                	jne    8014f2 <dev_lookup+0x31>
  8014e1:	eb 04                	jmp    8014e7 <dev_lookup+0x26>
  8014e3:	39 08                	cmp    %ecx,(%eax)
  8014e5:	75 10                	jne    8014f7 <dev_lookup+0x36>
			*dev = devtab[i];
  8014e7:	89 03                	mov    %eax,(%ebx)
  8014e9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8014ee:	66 90                	xchg   %ax,%ax
  8014f0:	eb 36                	jmp    801528 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014f2:	be 88 31 80 00       	mov    $0x803188,%esi
  8014f7:	83 c2 01             	add    $0x1,%edx
  8014fa:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	75 e2                	jne    8014e3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801501:	a1 1c 50 80 00       	mov    0x80501c,%eax
  801506:	8b 40 48             	mov    0x48(%eax),%eax
  801509:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80150d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801511:	c7 04 24 0c 31 80 00 	movl   $0x80310c,(%esp)
  801518:	e8 58 ef ff ff       	call   800475 <cprintf>
	*dev = 0;
  80151d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801523:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    

0080152f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	53                   	push   %ebx
  801533:	83 ec 24             	sub    $0x24,%esp
  801536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801539:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801540:	8b 45 08             	mov    0x8(%ebp),%eax
  801543:	89 04 24             	mov    %eax,(%esp)
  801546:	e8 02 ff ff ff       	call   80144d <fd_lookup>
  80154b:	85 c0                	test   %eax,%eax
  80154d:	78 53                	js     8015a2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80154f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801552:	89 44 24 04          	mov    %eax,0x4(%esp)
  801556:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801559:	8b 00                	mov    (%eax),%eax
  80155b:	89 04 24             	mov    %eax,(%esp)
  80155e:	e8 5e ff ff ff       	call   8014c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801563:	85 c0                	test   %eax,%eax
  801565:	78 3b                	js     8015a2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801567:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80156c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80156f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801573:	74 2d                	je     8015a2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801575:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801578:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80157f:	00 00 00 
	stat->st_isdir = 0;
  801582:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801589:	00 00 00 
	stat->st_dev = dev;
  80158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801595:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801599:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80159c:	89 14 24             	mov    %edx,(%esp)
  80159f:	ff 50 14             	call   *0x14(%eax)
}
  8015a2:	83 c4 24             	add    $0x24,%esp
  8015a5:	5b                   	pop    %ebx
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    

008015a8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 24             	sub    $0x24,%esp
  8015af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b9:	89 1c 24             	mov    %ebx,(%esp)
  8015bc:	e8 8c fe ff ff       	call   80144d <fd_lookup>
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	78 5f                	js     801624 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	8b 00                	mov    (%eax),%eax
  8015d1:	89 04 24             	mov    %eax,(%esp)
  8015d4:	e8 e8 fe ff ff       	call   8014c1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	78 47                	js     801624 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015dd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015e0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8015e4:	75 23                	jne    801609 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015e6:	a1 1c 50 80 00       	mov    0x80501c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015eb:	8b 40 48             	mov    0x48(%eax),%eax
  8015ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f6:	c7 04 24 2c 31 80 00 	movl   $0x80312c,(%esp)
  8015fd:	e8 73 ee ff ff       	call   800475 <cprintf>
  801602:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801607:	eb 1b                	jmp    801624 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801609:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80160c:	8b 48 18             	mov    0x18(%eax),%ecx
  80160f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801614:	85 c9                	test   %ecx,%ecx
  801616:	74 0c                	je     801624 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801618:	8b 45 0c             	mov    0xc(%ebp),%eax
  80161b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80161f:	89 14 24             	mov    %edx,(%esp)
  801622:	ff d1                	call   *%ecx
}
  801624:	83 c4 24             	add    $0x24,%esp
  801627:	5b                   	pop    %ebx
  801628:	5d                   	pop    %ebp
  801629:	c3                   	ret    

0080162a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	53                   	push   %ebx
  80162e:	83 ec 24             	sub    $0x24,%esp
  801631:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801634:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163b:	89 1c 24             	mov    %ebx,(%esp)
  80163e:	e8 0a fe ff ff       	call   80144d <fd_lookup>
  801643:	85 c0                	test   %eax,%eax
  801645:	78 66                	js     8016ad <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801651:	8b 00                	mov    (%eax),%eax
  801653:	89 04 24             	mov    %eax,(%esp)
  801656:	e8 66 fe ff ff       	call   8014c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 4e                	js     8016ad <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801662:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801666:	75 23                	jne    80168b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801668:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80166d:	8b 40 48             	mov    0x48(%eax),%eax
  801670:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801674:	89 44 24 04          	mov    %eax,0x4(%esp)
  801678:	c7 04 24 4d 31 80 00 	movl   $0x80314d,(%esp)
  80167f:	e8 f1 ed ff ff       	call   800475 <cprintf>
  801684:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801689:	eb 22                	jmp    8016ad <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801691:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801696:	85 c9                	test   %ecx,%ecx
  801698:	74 13                	je     8016ad <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80169a:	8b 45 10             	mov    0x10(%ebp),%eax
  80169d:	89 44 24 08          	mov    %eax,0x8(%esp)
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a8:	89 14 24             	mov    %edx,(%esp)
  8016ab:	ff d1                	call   *%ecx
}
  8016ad:	83 c4 24             	add    $0x24,%esp
  8016b0:	5b                   	pop    %ebx
  8016b1:	5d                   	pop    %ebp
  8016b2:	c3                   	ret    

008016b3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	53                   	push   %ebx
  8016b7:	83 ec 24             	sub    $0x24,%esp
  8016ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c4:	89 1c 24             	mov    %ebx,(%esp)
  8016c7:	e8 81 fd ff ff       	call   80144d <fd_lookup>
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 6b                	js     80173b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016da:	8b 00                	mov    (%eax),%eax
  8016dc:	89 04 24             	mov    %eax,(%esp)
  8016df:	e8 dd fd ff ff       	call   8014c1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e4:	85 c0                	test   %eax,%eax
  8016e6:	78 53                	js     80173b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016eb:	8b 42 08             	mov    0x8(%edx),%eax
  8016ee:	83 e0 03             	and    $0x3,%eax
  8016f1:	83 f8 01             	cmp    $0x1,%eax
  8016f4:	75 23                	jne    801719 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f6:	a1 1c 50 80 00       	mov    0x80501c,%eax
  8016fb:	8b 40 48             	mov    0x48(%eax),%eax
  8016fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	c7 04 24 6a 31 80 00 	movl   $0x80316a,(%esp)
  80170d:	e8 63 ed ff ff       	call   800475 <cprintf>
  801712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801717:	eb 22                	jmp    80173b <read+0x88>
	}
	if (!dev->dev_read)
  801719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171c:	8b 48 08             	mov    0x8(%eax),%ecx
  80171f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801724:	85 c9                	test   %ecx,%ecx
  801726:	74 13                	je     80173b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801728:	8b 45 10             	mov    0x10(%ebp),%eax
  80172b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80172f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801732:	89 44 24 04          	mov    %eax,0x4(%esp)
  801736:	89 14 24             	mov    %edx,(%esp)
  801739:	ff d1                	call   *%ecx
}
  80173b:	83 c4 24             	add    $0x24,%esp
  80173e:	5b                   	pop    %ebx
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	57                   	push   %edi
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	83 ec 1c             	sub    $0x1c,%esp
  80174a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80174d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801750:	ba 00 00 00 00       	mov    $0x0,%edx
  801755:	bb 00 00 00 00       	mov    $0x0,%ebx
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
  80175f:	85 f6                	test   %esi,%esi
  801761:	74 29                	je     80178c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801763:	89 f0                	mov    %esi,%eax
  801765:	29 d0                	sub    %edx,%eax
  801767:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176b:	03 55 0c             	add    0xc(%ebp),%edx
  80176e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801772:	89 3c 24             	mov    %edi,(%esp)
  801775:	e8 39 ff ff ff       	call   8016b3 <read>
		if (m < 0)
  80177a:	85 c0                	test   %eax,%eax
  80177c:	78 0e                	js     80178c <readn+0x4b>
			return m;
		if (m == 0)
  80177e:	85 c0                	test   %eax,%eax
  801780:	74 08                	je     80178a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801782:	01 c3                	add    %eax,%ebx
  801784:	89 da                	mov    %ebx,%edx
  801786:	39 f3                	cmp    %esi,%ebx
  801788:	72 d9                	jb     801763 <readn+0x22>
  80178a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80178c:	83 c4 1c             	add    $0x1c,%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5f                   	pop    %edi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	83 ec 28             	sub    $0x28,%esp
  80179a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80179d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8017a0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017a3:	89 34 24             	mov    %esi,(%esp)
  8017a6:	e8 05 fc ff ff       	call   8013b0 <fd2num>
  8017ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8017b2:	89 04 24             	mov    %eax,(%esp)
  8017b5:	e8 93 fc ff ff       	call   80144d <fd_lookup>
  8017ba:	89 c3                	mov    %eax,%ebx
  8017bc:	85 c0                	test   %eax,%eax
  8017be:	78 05                	js     8017c5 <fd_close+0x31>
  8017c0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8017c3:	74 0e                	je     8017d3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8017c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8017c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ce:	0f 44 d8             	cmove  %eax,%ebx
  8017d1:	eb 3d                	jmp    801810 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017da:	8b 06                	mov    (%esi),%eax
  8017dc:	89 04 24             	mov    %eax,(%esp)
  8017df:	e8 dd fc ff ff       	call   8014c1 <dev_lookup>
  8017e4:	89 c3                	mov    %eax,%ebx
  8017e6:	85 c0                	test   %eax,%eax
  8017e8:	78 16                	js     801800 <fd_close+0x6c>
		if (dev->dev_close)
  8017ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ed:	8b 40 10             	mov    0x10(%eax),%eax
  8017f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f5:	85 c0                	test   %eax,%eax
  8017f7:	74 07                	je     801800 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8017f9:	89 34 24             	mov    %esi,(%esp)
  8017fc:	ff d0                	call   *%eax
  8017fe:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801800:	89 74 24 04          	mov    %esi,0x4(%esp)
  801804:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80180b:	e8 9c f9 ff ff       	call   8011ac <sys_page_unmap>
	return r;
}
  801810:	89 d8                	mov    %ebx,%eax
  801812:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801815:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801818:	89 ec                	mov    %ebp,%esp
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	89 44 24 04          	mov    %eax,0x4(%esp)
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	89 04 24             	mov    %eax,(%esp)
  80182f:	e8 19 fc ff ff       	call   80144d <fd_lookup>
  801834:	85 c0                	test   %eax,%eax
  801836:	78 13                	js     80184b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801838:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80183f:	00 
  801840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801843:	89 04 24             	mov    %eax,(%esp)
  801846:	e8 49 ff ff ff       	call   801794 <fd_close>
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	83 ec 18             	sub    $0x18,%esp
  801853:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801856:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801859:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801860:	00 
  801861:	8b 45 08             	mov    0x8(%ebp),%eax
  801864:	89 04 24             	mov    %eax,(%esp)
  801867:	e8 78 03 00 00       	call   801be4 <open>
  80186c:	89 c3                	mov    %eax,%ebx
  80186e:	85 c0                	test   %eax,%eax
  801870:	78 1b                	js     80188d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801872:	8b 45 0c             	mov    0xc(%ebp),%eax
  801875:	89 44 24 04          	mov    %eax,0x4(%esp)
  801879:	89 1c 24             	mov    %ebx,(%esp)
  80187c:	e8 ae fc ff ff       	call   80152f <fstat>
  801881:	89 c6                	mov    %eax,%esi
	close(fd);
  801883:	89 1c 24             	mov    %ebx,(%esp)
  801886:	e8 91 ff ff ff       	call   80181c <close>
  80188b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80188d:	89 d8                	mov    %ebx,%eax
  80188f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801892:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801895:	89 ec                	mov    %ebp,%esp
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	53                   	push   %ebx
  80189d:	83 ec 14             	sub    $0x14,%esp
  8018a0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8018a5:	89 1c 24             	mov    %ebx,(%esp)
  8018a8:	e8 6f ff ff ff       	call   80181c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8018ad:	83 c3 01             	add    $0x1,%ebx
  8018b0:	83 fb 20             	cmp    $0x20,%ebx
  8018b3:	75 f0                	jne    8018a5 <close_all+0xc>
		close(i);
}
  8018b5:	83 c4 14             	add    $0x14,%esp
  8018b8:	5b                   	pop    %ebx
  8018b9:	5d                   	pop    %ebp
  8018ba:	c3                   	ret    

008018bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 58             	sub    $0x58,%esp
  8018c1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8018c4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8018c7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8018ca:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018cd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	89 04 24             	mov    %eax,(%esp)
  8018da:	e8 6e fb ff ff       	call   80144d <fd_lookup>
  8018df:	89 c3                	mov    %eax,%ebx
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	0f 88 e0 00 00 00    	js     8019c9 <dup+0x10e>
		return r;
	close(newfdnum);
  8018e9:	89 3c 24             	mov    %edi,(%esp)
  8018ec:	e8 2b ff ff ff       	call   80181c <close>

	newfd = INDEX2FD(newfdnum);
  8018f1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8018f7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8018fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018fd:	89 04 24             	mov    %eax,(%esp)
  801900:	e8 bb fa ff ff       	call   8013c0 <fd2data>
  801905:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801907:	89 34 24             	mov    %esi,(%esp)
  80190a:	e8 b1 fa ff ff       	call   8013c0 <fd2data>
  80190f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801912:	89 da                	mov    %ebx,%edx
  801914:	89 d8                	mov    %ebx,%eax
  801916:	c1 e8 16             	shr    $0x16,%eax
  801919:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801920:	a8 01                	test   $0x1,%al
  801922:	74 43                	je     801967 <dup+0xac>
  801924:	c1 ea 0c             	shr    $0xc,%edx
  801927:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80192e:	a8 01                	test   $0x1,%al
  801930:	74 35                	je     801967 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801932:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801939:	25 07 0e 00 00       	and    $0xe07,%eax
  80193e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801942:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801945:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801949:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801950:	00 
  801951:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801955:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80195c:	e8 83 f8 ff ff       	call   8011e4 <sys_page_map>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	85 c0                	test   %eax,%eax
  801965:	78 3f                	js     8019a6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801967:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80196a:	89 c2                	mov    %eax,%edx
  80196c:	c1 ea 0c             	shr    $0xc,%edx
  80196f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801976:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80197c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801980:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801984:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80198b:	00 
  80198c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801990:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801997:	e8 48 f8 ff ff       	call   8011e4 <sys_page_map>
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 04                	js     8019a6 <dup+0xeb>
  8019a2:	89 fb                	mov    %edi,%ebx
  8019a4:	eb 23                	jmp    8019c9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8019a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019b1:	e8 f6 f7 ff ff       	call   8011ac <sys_page_unmap>
	sys_page_unmap(0, nva);
  8019b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8019b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019c4:	e8 e3 f7 ff ff       	call   8011ac <sys_page_unmap>
	return r;
}
  8019c9:	89 d8                	mov    %ebx,%eax
  8019cb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8019ce:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8019d1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8019d4:	89 ec                	mov    %ebp,%esp
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	83 ec 18             	sub    $0x18,%esp
  8019de:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019e1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8019e4:	89 c3                	mov    %eax,%ebx
  8019e6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8019e8:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8019ef:	75 11                	jne    801a02 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019f1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8019f8:	e8 63 0a 00 00       	call   802460 <ipc_find_env>
  8019fd:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a02:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a09:	00 
  801a0a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801a11:	00 
  801a12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a16:	a1 00 50 80 00       	mov    0x805000,%eax
  801a1b:	89 04 24             	mov    %eax,(%esp)
  801a1e:	e8 81 0a 00 00       	call   8024a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a23:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a2a:	00 
  801a2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a2f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a36:	e8 d4 0a 00 00       	call   80250f <ipc_recv>
}
  801a3b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a3e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a41:	89 ec                	mov    %ebp,%esp
  801a43:	5d                   	pop    %ebp
  801a44:	c3                   	ret    

00801a45 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a51:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a59:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a5e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a63:	b8 02 00 00 00       	mov    $0x2,%eax
  801a68:	e8 6b ff ff ff       	call   8019d8 <fsipc>
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a75:	8b 45 08             	mov    0x8(%ebp),%eax
  801a78:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801a80:	ba 00 00 00 00       	mov    $0x0,%edx
  801a85:	b8 06 00 00 00       	mov    $0x6,%eax
  801a8a:	e8 49 ff ff ff       	call   8019d8 <fsipc>
}
  801a8f:	c9                   	leave  
  801a90:	c3                   	ret    

00801a91 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a97:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9c:	b8 08 00 00 00       	mov    $0x8,%eax
  801aa1:	e8 32 ff ff ff       	call   8019d8 <fsipc>
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	53                   	push   %ebx
  801aac:	83 ec 14             	sub    $0x14,%esp
  801aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab5:	8b 40 0c             	mov    0xc(%eax),%eax
  801ab8:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801abd:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac2:	b8 05 00 00 00       	mov    $0x5,%eax
  801ac7:	e8 0c ff ff ff       	call   8019d8 <fsipc>
  801acc:	85 c0                	test   %eax,%eax
  801ace:	78 2b                	js     801afb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801ad0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ad7:	00 
  801ad8:	89 1c 24             	mov    %ebx,(%esp)
  801adb:	e8 da f0 ff ff       	call   800bba <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ae0:	a1 80 60 80 00       	mov    0x806080,%eax
  801ae5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801aeb:	a1 84 60 80 00       	mov    0x806084,%eax
  801af0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801afb:	83 c4 14             	add    $0x14,%esp
  801afe:	5b                   	pop    %ebx
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	83 ec 18             	sub    $0x18,%esp
  801b07:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  801b0d:	8b 52 0c             	mov    0xc(%edx),%edx
  801b10:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801b16:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801b1b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b20:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b25:	0f 47 c2             	cmova  %edx,%eax
  801b28:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b33:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801b3a:	e8 66 f2 ff ff       	call   800da5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801b44:	b8 04 00 00 00       	mov    $0x4,%eax
  801b49:	e8 8a fe ff ff       	call   8019d8 <fsipc>
}
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	53                   	push   %ebx
  801b54:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801b62:	8b 45 10             	mov    0x10(%ebp),%eax
  801b65:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b6a:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b74:	e8 5f fe ff ff       	call   8019d8 <fsipc>
  801b79:	89 c3                	mov    %eax,%ebx
  801b7b:	85 c0                	test   %eax,%eax
  801b7d:	78 17                	js     801b96 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b83:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801b8a:	00 
  801b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8e:	89 04 24             	mov    %eax,(%esp)
  801b91:	e8 0f f2 ff ff       	call   800da5 <memmove>
  return r;	
}
  801b96:	89 d8                	mov    %ebx,%eax
  801b98:	83 c4 14             	add    $0x14,%esp
  801b9b:	5b                   	pop    %ebx
  801b9c:	5d                   	pop    %ebp
  801b9d:	c3                   	ret    

00801b9e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	53                   	push   %ebx
  801ba2:	83 ec 14             	sub    $0x14,%esp
  801ba5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801ba8:	89 1c 24             	mov    %ebx,(%esp)
  801bab:	e8 c0 ef ff ff       	call   800b70 <strlen>
  801bb0:	89 c2                	mov    %eax,%edx
  801bb2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801bb7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801bbd:	7f 1f                	jg     801bde <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801bbf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801bca:	e8 eb ef ff ff       	call   800bba <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd4:	b8 07 00 00 00       	mov    $0x7,%eax
  801bd9:	e8 fa fd ff ff       	call   8019d8 <fsipc>
}
  801bde:	83 c4 14             	add    $0x14,%esp
  801be1:	5b                   	pop    %ebx
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    

00801be4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 28             	sub    $0x28,%esp
  801bea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801bed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801bf0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801bf3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf6:	89 04 24             	mov    %eax,(%esp)
  801bf9:	e8 dd f7 ff ff       	call   8013db <fd_alloc>
  801bfe:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801c00:	85 c0                	test   %eax,%eax
  801c02:	0f 88 89 00 00 00    	js     801c91 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801c08:	89 34 24             	mov    %esi,(%esp)
  801c0b:	e8 60 ef ff ff       	call   800b70 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801c10:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801c15:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c1a:	7f 75                	jg     801c91 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801c1c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c20:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801c27:	e8 8e ef ff ff       	call   800bba <strcpy>
  fsipcbuf.open.req_omode = mode;
  801c2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801c34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c37:	b8 01 00 00 00       	mov    $0x1,%eax
  801c3c:	e8 97 fd ff ff       	call   8019d8 <fsipc>
  801c41:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801c43:	85 c0                	test   %eax,%eax
  801c45:	78 0f                	js     801c56 <open+0x72>
  return fd2num(fd);
  801c47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4a:	89 04 24             	mov    %eax,(%esp)
  801c4d:	e8 5e f7 ff ff       	call   8013b0 <fd2num>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	eb 3b                	jmp    801c91 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801c56:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c5d:	00 
  801c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c61:	89 04 24             	mov    %eax,(%esp)
  801c64:	e8 2b fb ff ff       	call   801794 <fd_close>
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	74 24                	je     801c91 <open+0xad>
  801c6d:	c7 44 24 0c 94 31 80 	movl   $0x803194,0xc(%esp)
  801c74:	00 
  801c75:	c7 44 24 08 a9 31 80 	movl   $0x8031a9,0x8(%esp)
  801c7c:	00 
  801c7d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801c84:	00 
  801c85:	c7 04 24 be 31 80 00 	movl   $0x8031be,(%esp)
  801c8c:	e8 2b e7 ff ff       	call   8003bc <_panic>
  return r;
}
  801c91:	89 d8                	mov    %ebx,%eax
  801c93:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801c96:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801c99:	89 ec                	mov    %ebp,%esp
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    
  801c9d:	00 00                	add    %al,(%eax)
	...

00801ca0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801ca6:	c7 44 24 04 c9 31 80 	movl   $0x8031c9,0x4(%esp)
  801cad:	00 
  801cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb1:	89 04 24             	mov    %eax,(%esp)
  801cb4:	e8 01 ef ff ff       	call   800bba <strcpy>
	return 0;
}
  801cb9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbe:	c9                   	leave  
  801cbf:	c3                   	ret    

00801cc0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cc0:	55                   	push   %ebp
  801cc1:	89 e5                	mov    %esp,%ebp
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 14             	sub    $0x14,%esp
  801cc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cca:	89 1c 24             	mov    %ebx,(%esp)
  801ccd:	e8 ca 08 00 00       	call   80259c <pageref>
  801cd2:	89 c2                	mov    %eax,%edx
  801cd4:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd9:	83 fa 01             	cmp    $0x1,%edx
  801cdc:	75 0b                	jne    801ce9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801cde:	8b 43 0c             	mov    0xc(%ebx),%eax
  801ce1:	89 04 24             	mov    %eax,(%esp)
  801ce4:	e8 b9 02 00 00       	call   801fa2 <nsipc_close>
	else
		return 0;
}
  801ce9:	83 c4 14             	add    $0x14,%esp
  801cec:	5b                   	pop    %ebx
  801ced:	5d                   	pop    %ebp
  801cee:	c3                   	ret    

00801cef <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801cf5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801cfc:	00 
  801cfd:	8b 45 10             	mov    0x10(%ebp),%eax
  801d00:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d07:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d11:	89 04 24             	mov    %eax,(%esp)
  801d14:	e8 c5 02 00 00       	call   801fde <nsipc_send>
}
  801d19:	c9                   	leave  
  801d1a:	c3                   	ret    

00801d1b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801d28:	00 
  801d29:	8b 45 10             	mov    0x10(%ebp),%eax
  801d2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d33:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d37:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3a:	8b 40 0c             	mov    0xc(%eax),%eax
  801d3d:	89 04 24             	mov    %eax,(%esp)
  801d40:	e8 0c 03 00 00       	call   802051 <nsipc_recv>
}
  801d45:	c9                   	leave  
  801d46:	c3                   	ret    

00801d47 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801d47:	55                   	push   %ebp
  801d48:	89 e5                	mov    %esp,%ebp
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
  801d4c:	83 ec 20             	sub    $0x20,%esp
  801d4f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d54:	89 04 24             	mov    %eax,(%esp)
  801d57:	e8 7f f6 ff ff       	call   8013db <fd_alloc>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	78 21                	js     801d83 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d62:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d69:	00 
  801d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d71:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d78:	e8 a0 f4 ff ff       	call   80121d <sys_page_alloc>
  801d7d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	79 0a                	jns    801d8d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801d83:	89 34 24             	mov    %esi,(%esp)
  801d86:	e8 17 02 00 00       	call   801fa2 <nsipc_close>
		return r;
  801d8b:	eb 28                	jmp    801db5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d8d:	8b 15 40 40 80 00    	mov    0x804040,%edx
  801d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d96:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dab:	89 04 24             	mov    %eax,(%esp)
  801dae:	e8 fd f5 ff ff       	call   8013b0 <fd2num>
  801db3:	89 c3                	mov    %eax,%ebx
}
  801db5:	89 d8                	mov    %ebx,%eax
  801db7:	83 c4 20             	add    $0x20,%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
  801dc1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801dc4:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dce:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd5:	89 04 24             	mov    %eax,(%esp)
  801dd8:	e8 79 01 00 00       	call   801f56 <nsipc_socket>
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 05                	js     801de6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801de1:	e8 61 ff ff ff       	call   801d47 <alloc_sockfd>
}
  801de6:	c9                   	leave  
  801de7:	c3                   	ret    

00801de8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801de8:	55                   	push   %ebp
  801de9:	89 e5                	mov    %esp,%ebp
  801deb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801dee:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801df1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801df5:	89 04 24             	mov    %eax,(%esp)
  801df8:	e8 50 f6 ff ff       	call   80144d <fd_lookup>
  801dfd:	85 c0                	test   %eax,%eax
  801dff:	78 15                	js     801e16 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e04:	8b 0a                	mov    (%edx),%ecx
  801e06:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e0b:	3b 0d 40 40 80 00    	cmp    0x804040,%ecx
  801e11:	75 03                	jne    801e16 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801e13:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e21:	e8 c2 ff ff ff       	call   801de8 <fd2sockid>
  801e26:	85 c0                	test   %eax,%eax
  801e28:	78 0f                	js     801e39 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e31:	89 04 24             	mov    %eax,(%esp)
  801e34:	e8 47 01 00 00       	call   801f80 <nsipc_listen>
}
  801e39:	c9                   	leave  
  801e3a:	c3                   	ret    

00801e3b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e41:	8b 45 08             	mov    0x8(%ebp),%eax
  801e44:	e8 9f ff ff ff       	call   801de8 <fd2sockid>
  801e49:	85 c0                	test   %eax,%eax
  801e4b:	78 16                	js     801e63 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801e4d:	8b 55 10             	mov    0x10(%ebp),%edx
  801e50:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e54:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e57:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e5b:	89 04 24             	mov    %eax,(%esp)
  801e5e:	e8 6e 02 00 00       	call   8020d1 <nsipc_connect>
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	e8 75 ff ff ff       	call   801de8 <fd2sockid>
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 0f                	js     801e86 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e7e:	89 04 24             	mov    %eax,(%esp)
  801e81:	e8 36 01 00 00       	call   801fbc <nsipc_shutdown>
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e91:	e8 52 ff ff ff       	call   801de8 <fd2sockid>
  801e96:	85 c0                	test   %eax,%eax
  801e98:	78 16                	js     801eb0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801e9a:	8b 55 10             	mov    0x10(%ebp),%edx
  801e9d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ea1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea4:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ea8:	89 04 24             	mov    %eax,(%esp)
  801eab:	e8 60 02 00 00       	call   802110 <nsipc_bind>
}
  801eb0:	c9                   	leave  
  801eb1:	c3                   	ret    

00801eb2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801eb2:	55                   	push   %ebp
  801eb3:	89 e5                	mov    %esp,%ebp
  801eb5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebb:	e8 28 ff ff ff       	call   801de8 <fd2sockid>
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	78 1f                	js     801ee3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ec4:	8b 55 10             	mov    0x10(%ebp),%edx
  801ec7:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ece:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ed2:	89 04 24             	mov    %eax,(%esp)
  801ed5:	e8 75 02 00 00       	call   80214f <nsipc_accept>
  801eda:	85 c0                	test   %eax,%eax
  801edc:	78 05                	js     801ee3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801ede:	e8 64 fe ff ff       	call   801d47 <alloc_sockfd>
}
  801ee3:	c9                   	leave  
  801ee4:	c3                   	ret    
	...

00801ef0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	53                   	push   %ebx
  801ef4:	83 ec 14             	sub    $0x14,%esp
  801ef7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ef9:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801f00:	75 11                	jne    801f13 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801f02:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801f09:	e8 52 05 00 00       	call   802460 <ipc_find_env>
  801f0e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801f13:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f1a:	00 
  801f1b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  801f22:	00 
  801f23:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f27:	a1 04 50 80 00       	mov    0x805004,%eax
  801f2c:	89 04 24             	mov    %eax,(%esp)
  801f2f:	e8 70 05 00 00       	call   8024a4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801f34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f3b:	00 
  801f3c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f43:	00 
  801f44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f4b:	e8 bf 05 00 00       	call   80250f <ipc_recv>
}
  801f50:	83 c4 14             	add    $0x14,%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5d                   	pop    %ebp
  801f55:	c3                   	ret    

00801f56 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801f56:	55                   	push   %ebp
  801f57:	89 e5                	mov    %esp,%ebp
  801f59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f67:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801f6c:	8b 45 10             	mov    0x10(%ebp),%eax
  801f6f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801f74:	b8 09 00 00 00       	mov    $0x9,%eax
  801f79:	e8 72 ff ff ff       	call   801ef0 <nsipc>
}
  801f7e:	c9                   	leave  
  801f7f:	c3                   	ret    

00801f80 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f86:	8b 45 08             	mov    0x8(%ebp),%eax
  801f89:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801f8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f91:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801f96:	b8 06 00 00 00       	mov    $0x6,%eax
  801f9b:	e8 50 ff ff ff       	call   801ef0 <nsipc>
}
  801fa0:	c9                   	leave  
  801fa1:	c3                   	ret    

00801fa2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801fab:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801fb0:	b8 04 00 00 00       	mov    $0x4,%eax
  801fb5:	e8 36 ff ff ff       	call   801ef0 <nsipc>
}
  801fba:	c9                   	leave  
  801fbb:	c3                   	ret    

00801fbc <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801fbc:	55                   	push   %ebp
  801fbd:	89 e5                	mov    %esp,%ebp
  801fbf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801fca:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fcd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801fd2:	b8 03 00 00 00       	mov    $0x3,%eax
  801fd7:	e8 14 ff ff ff       	call   801ef0 <nsipc>
}
  801fdc:	c9                   	leave  
  801fdd:	c3                   	ret    

00801fde <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 14             	sub    $0x14,%esp
  801fe5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  801feb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801ff0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ff6:	7e 24                	jle    80201c <nsipc_send+0x3e>
  801ff8:	c7 44 24 0c d5 31 80 	movl   $0x8031d5,0xc(%esp)
  801fff:	00 
  802000:	c7 44 24 08 a9 31 80 	movl   $0x8031a9,0x8(%esp)
  802007:	00 
  802008:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80200f:	00 
  802010:	c7 04 24 e1 31 80 00 	movl   $0x8031e1,(%esp)
  802017:	e8 a0 e3 ff ff       	call   8003bc <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80201c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802020:	8b 45 0c             	mov    0xc(%ebp),%eax
  802023:	89 44 24 04          	mov    %eax,0x4(%esp)
  802027:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80202e:	e8 72 ed ff ff       	call   800da5 <memmove>
	nsipcbuf.send.req_size = size;
  802033:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802039:	8b 45 14             	mov    0x14(%ebp),%eax
  80203c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802041:	b8 08 00 00 00       	mov    $0x8,%eax
  802046:	e8 a5 fe ff ff       	call   801ef0 <nsipc>
}
  80204b:	83 c4 14             	add    $0x14,%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    

00802051 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802051:	55                   	push   %ebp
  802052:	89 e5                	mov    %esp,%ebp
  802054:	56                   	push   %esi
  802055:	53                   	push   %ebx
  802056:	83 ec 10             	sub    $0x10,%esp
  802059:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80205c:	8b 45 08             	mov    0x8(%ebp),%eax
  80205f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802064:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80206a:	8b 45 14             	mov    0x14(%ebp),%eax
  80206d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802072:	b8 07 00 00 00       	mov    $0x7,%eax
  802077:	e8 74 fe ff ff       	call   801ef0 <nsipc>
  80207c:	89 c3                	mov    %eax,%ebx
  80207e:	85 c0                	test   %eax,%eax
  802080:	78 46                	js     8020c8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802082:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802087:	7f 04                	jg     80208d <nsipc_recv+0x3c>
  802089:	39 c6                	cmp    %eax,%esi
  80208b:	7d 24                	jge    8020b1 <nsipc_recv+0x60>
  80208d:	c7 44 24 0c ed 31 80 	movl   $0x8031ed,0xc(%esp)
  802094:	00 
  802095:	c7 44 24 08 a9 31 80 	movl   $0x8031a9,0x8(%esp)
  80209c:	00 
  80209d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8020a4:	00 
  8020a5:	c7 04 24 e1 31 80 00 	movl   $0x8031e1,(%esp)
  8020ac:	e8 0b e3 ff ff       	call   8003bc <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8020b1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020b5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8020bc:	00 
  8020bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c0:	89 04 24             	mov    %eax,(%esp)
  8020c3:	e8 dd ec ff ff       	call   800da5 <memmove>
	}

	return r;
}
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5d                   	pop    %ebp
  8020d0:	c3                   	ret    

008020d1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8020d1:	55                   	push   %ebp
  8020d2:	89 e5                	mov    %esp,%ebp
  8020d4:	53                   	push   %ebx
  8020d5:	83 ec 14             	sub    $0x14,%esp
  8020d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8020db:	8b 45 08             	mov    0x8(%ebp),%eax
  8020de:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8020e3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020ee:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8020f5:	e8 ab ec ff ff       	call   800da5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8020fa:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802100:	b8 05 00 00 00       	mov    $0x5,%eax
  802105:	e8 e6 fd ff ff       	call   801ef0 <nsipc>
}
  80210a:	83 c4 14             	add    $0x14,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5d                   	pop    %ebp
  80210f:	c3                   	ret    

00802110 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	53                   	push   %ebx
  802114:	83 ec 14             	sub    $0x14,%esp
  802117:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80211a:	8b 45 08             	mov    0x8(%ebp),%eax
  80211d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802122:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802126:	8b 45 0c             	mov    0xc(%ebp),%eax
  802129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80212d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802134:	e8 6c ec ff ff       	call   800da5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802139:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80213f:	b8 02 00 00 00       	mov    $0x2,%eax
  802144:	e8 a7 fd ff ff       	call   801ef0 <nsipc>
}
  802149:	83 c4 14             	add    $0x14,%esp
  80214c:	5b                   	pop    %ebx
  80214d:	5d                   	pop    %ebp
  80214e:	c3                   	ret    

0080214f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	83 ec 18             	sub    $0x18,%esp
  802155:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802158:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80215b:	8b 45 08             	mov    0x8(%ebp),%eax
  80215e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802163:	b8 01 00 00 00       	mov    $0x1,%eax
  802168:	e8 83 fd ff ff       	call   801ef0 <nsipc>
  80216d:	89 c3                	mov    %eax,%ebx
  80216f:	85 c0                	test   %eax,%eax
  802171:	78 25                	js     802198 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802173:	be 10 70 80 00       	mov    $0x807010,%esi
  802178:	8b 06                	mov    (%esi),%eax
  80217a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80217e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802185:	00 
  802186:	8b 45 0c             	mov    0xc(%ebp),%eax
  802189:	89 04 24             	mov    %eax,(%esp)
  80218c:	e8 14 ec ff ff       	call   800da5 <memmove>
		*addrlen = ret->ret_addrlen;
  802191:	8b 16                	mov    (%esi),%edx
  802193:	8b 45 10             	mov    0x10(%ebp),%eax
  802196:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802198:	89 d8                	mov    %ebx,%eax
  80219a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80219d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021a0:	89 ec                	mov    %ebp,%esp
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
	...

008021b0 <free>:
	return v;
}

void
free(void *v)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	56                   	push   %esi
  8021b4:	53                   	push   %ebx
  8021b5:	83 ec 10             	sub    $0x10,%esp
  8021b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint8_t *c;
	uint32_t *ref;

	if (v == 0)
  8021bb:	85 db                	test   %ebx,%ebx
  8021bd:	0f 84 b9 00 00 00    	je     80227c <free+0xcc>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);
  8021c3:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  8021c9:	76 08                	jbe    8021d3 <free+0x23>
  8021cb:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  8021d1:	76 24                	jbe    8021f7 <free+0x47>
  8021d3:	c7 44 24 0c 04 32 80 	movl   $0x803204,0xc(%esp)
  8021da:	00 
  8021db:	c7 44 24 08 a9 31 80 	movl   $0x8031a9,0x8(%esp)
  8021e2:	00 
  8021e3:	c7 44 24 04 7a 00 00 	movl   $0x7a,0x4(%esp)
  8021ea:	00 
  8021eb:	c7 04 24 34 32 80 00 	movl   $0x803234,(%esp)
  8021f2:	e8 c5 e1 ff ff       	call   8003bc <_panic>

	c = ROUNDDOWN(v, PGSIZE);
  8021f7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx

	while (vpt[PGNUM(c)] & PTE_CONTINUED) {
  8021fd:	be 00 00 40 ef       	mov    $0xef400000,%esi
  802202:	eb 4a                	jmp    80224e <free+0x9e>
		sys_page_unmap(0, c);
  802204:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802208:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80220f:	e8 98 ef ff ff       	call   8011ac <sys_page_unmap>
		c += PGSIZE;
  802214:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		assert(mbegin <= c && c < mend);
  80221a:	81 fb ff ff ff 07    	cmp    $0x7ffffff,%ebx
  802220:	76 08                	jbe    80222a <free+0x7a>
  802222:	81 fb ff ff ff 0f    	cmp    $0xfffffff,%ebx
  802228:	76 24                	jbe    80224e <free+0x9e>
  80222a:	c7 44 24 0c 41 32 80 	movl   $0x803241,0xc(%esp)
  802231:	00 
  802232:	c7 44 24 08 a9 31 80 	movl   $0x8031a9,0x8(%esp)
  802239:	00 
  80223a:	c7 44 24 04 81 00 00 	movl   $0x81,0x4(%esp)
  802241:	00 
  802242:	c7 04 24 34 32 80 00 	movl   $0x803234,(%esp)
  802249:	e8 6e e1 ff ff       	call   8003bc <_panic>
		return;
	assert(mbegin <= (uint8_t*) v && (uint8_t*) v < mend);

	c = ROUNDDOWN(v, PGSIZE);

	while (vpt[PGNUM(c)] & PTE_CONTINUED) {
  80224e:	89 d8                	mov    %ebx,%eax
  802250:	c1 e8 0c             	shr    $0xc,%eax
  802253:	8b 04 86             	mov    (%esi,%eax,4),%eax
  802256:	f6 c4 04             	test   $0x4,%ah
  802259:	75 a9                	jne    802204 <free+0x54>

	/*
	 * c is just a piece of this page, so dec the ref count
	 * and maybe free the page.
	 */
	ref = (uint32_t*) (c + PGSIZE - 4);
  80225b:	8d 93 fc 0f 00 00    	lea    0xffc(%ebx),%edx
	if (--(*ref) == 0)
  802261:	8b 02                	mov    (%edx),%eax
  802263:	83 e8 01             	sub    $0x1,%eax
  802266:	89 02                	mov    %eax,(%edx)
  802268:	85 c0                	test   %eax,%eax
  80226a:	75 10                	jne    80227c <free+0xcc>
		sys_page_unmap(0, c);
  80226c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802270:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802277:	e8 30 ef ff ff       	call   8011ac <sys_page_unmap>
}
  80227c:	83 c4 10             	add    $0x10,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <malloc>:
	return 1;
}

void*
malloc(size_t n)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	57                   	push   %edi
  802287:	56                   	push   %esi
  802288:	53                   	push   %ebx
  802289:	83 ec 3c             	sub    $0x3c,%esp
	int i, cont;
	int nwrap;
	uint32_t *ref;
	void *v;

	if (mptr == 0)
  80228c:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  802293:	75 0a                	jne    80229f <malloc+0x1c>
		mptr = mbegin;
  802295:	c7 05 08 50 80 00 00 	movl   $0x8000000,0x805008
  80229c:	00 00 08 

	n = ROUNDUP(n, 4);
  80229f:	8b 45 08             	mov    0x8(%ebp),%eax
  8022a2:	83 c0 03             	add    $0x3,%eax
  8022a5:	83 e0 fc             	and    $0xfffffffc,%eax
  8022a8:	89 45 d8             	mov    %eax,-0x28(%ebp)

	if (n >= MAXMALLOC)
  8022ab:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
  8022b0:	0f 87 97 01 00 00    	ja     80244d <malloc+0x1ca>
		return 0;

	if ((uintptr_t) mptr % PGSIZE){
  8022b6:	a1 08 50 80 00       	mov    0x805008,%eax
  8022bb:	89 c2                	mov    %eax,%edx
  8022bd:	a9 ff 0f 00 00       	test   $0xfff,%eax
  8022c2:	74 4d                	je     802311 <malloc+0x8e>
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
  8022c4:	89 c3                	mov    %eax,%ebx
  8022c6:	c1 eb 0c             	shr    $0xc,%ebx
  8022c9:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8022cc:	8d 4c 30 03          	lea    0x3(%eax,%esi,1),%ecx
  8022d0:	c1 e9 0c             	shr    $0xc,%ecx
  8022d3:	39 cb                	cmp    %ecx,%ebx
  8022d5:	75 1e                	jne    8022f5 <malloc+0x72>
		/*
		 * we're in the middle of a partially
		 * allocated page - can we add this chunk?
		 * the +4 below is for the ref count.
		 */
		ref = (uint32_t*) (ROUNDUP(mptr, PGSIZE) - 4);
  8022d7:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  8022dd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		if ((uintptr_t) mptr / PGSIZE == (uintptr_t) (mptr + n - 1 + 4) / PGSIZE) {
			(*ref)++;
  8022e3:	83 42 fc 01          	addl   $0x1,-0x4(%edx)
			v = mptr;
			mptr += n;
  8022e7:	8d 14 30             	lea    (%eax,%esi,1),%edx
  8022ea:	89 15 08 50 80 00    	mov    %edx,0x805008
			return v;
  8022f0:	e9 5d 01 00 00       	jmp    802452 <malloc+0x1cf>
		}
		/*
		 * stop working on this page and move on.
		 */
		free(mptr);	/* drop reference to this page */
  8022f5:	89 04 24             	mov    %eax,(%esp)
  8022f8:	e8 b3 fe ff ff       	call   8021b0 <free>
		mptr = ROUNDDOWN(mptr + PGSIZE, PGSIZE);
  8022fd:	a1 08 50 80 00       	mov    0x805008,%eax
  802302:	05 00 10 00 00       	add    $0x1000,%eax
  802307:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80230c:	a3 08 50 80 00       	mov    %eax,0x805008
  802311:	8b 3d 08 50 80 00    	mov    0x805008,%edi
  802317:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
			return 0;
	return 1;
}

void*
malloc(size_t n)
  80231e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  802321:	83 c0 04             	add    $0x4,%eax
  802324:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
		    || ((vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P)))
  802327:	bb 00 d0 7b ef       	mov    $0xef7bd000,%ebx
  80232c:	be 00 00 40 ef       	mov    $0xef400000,%esi
			return 0;
	return 1;
}

void*
malloc(size_t n)
  802331:	8b 45 dc             	mov    -0x24(%ebp),%eax
  802334:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  802337:	8d 0c 07             	lea    (%edi,%eax,1),%ecx
  80233a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  80233d:	39 cf                	cmp    %ecx,%edi
  80233f:	0f 83 d7 00 00 00    	jae    80241c <malloc+0x199>
		if (va >= (uintptr_t) mend
  802345:	89 f8                	mov    %edi,%eax
  802347:	81 ff ff ff ff 0f    	cmp    $0xfffffff,%edi
  80234d:	76 09                	jbe    802358 <malloc+0xd5>
  80234f:	eb 38                	jmp    802389 <malloc+0x106>
  802351:	3d ff ff ff 0f       	cmp    $0xfffffff,%eax
  802356:	77 31                	ja     802389 <malloc+0x106>
		    || ((vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P)))
  802358:	89 c2                	mov    %eax,%edx
  80235a:	c1 ea 16             	shr    $0x16,%edx
  80235d:	8b 14 93             	mov    (%ebx,%edx,4),%edx
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
  802360:	f6 c2 01             	test   $0x1,%dl
  802363:	74 0d                	je     802372 <malloc+0xef>
		    || ((vpd[PDX(va)] & PTE_P) && (vpt[PGNUM(va)] & PTE_P)))
  802365:	89 c2                	mov    %eax,%edx
  802367:	c1 ea 0c             	shr    $0xc,%edx
  80236a:	8b 14 96             	mov    (%esi,%edx,4),%edx
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
		if (va >= (uintptr_t) mend
  80236d:	f6 c2 01             	test   $0x1,%dl
  802370:	75 17                	jne    802389 <malloc+0x106>
static int
isfree(void *v, size_t n)
{
	uintptr_t va, end_va = (uintptr_t) v + n;

	for (va = (uintptr_t) v; va < end_va; va += PGSIZE)
  802372:	05 00 10 00 00       	add    $0x1000,%eax
  802377:	39 c8                	cmp    %ecx,%eax
  802379:	72 d6                	jb     802351 <malloc+0xce>
  80237b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80237e:	89 35 08 50 80 00    	mov    %esi,0x805008
  802384:	e9 9b 00 00 00       	jmp    802424 <malloc+0x1a1>
  802389:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80238f:	81 c1 00 10 00 00    	add    $0x1000,%ecx
	nwrap = 0;
	while (1) {
		if (isfree(mptr, n + 4))
			break;
		mptr += PGSIZE;
		if (mptr == mend) {
  802395:	81 ff 00 00 00 10    	cmp    $0x10000000,%edi
  80239b:	75 9d                	jne    80233a <malloc+0xb7>
			mptr = mbegin;
			if (++nwrap == 2)
  80239d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  8023a1:	83 7d e0 02          	cmpl   $0x2,-0x20(%ebp)
  8023a5:	74 07                	je     8023ae <malloc+0x12b>
  8023a7:	bf 00 00 00 08       	mov    $0x8000000,%edi
  8023ac:	eb 83                	jmp    802331 <malloc+0xae>
  8023ae:	c7 05 08 50 80 00 00 	movl   $0x8000000,0x805008
  8023b5:	00 00 08 
  8023b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8023bd:	e9 90 00 00 00       	jmp    802452 <malloc+0x1cf>

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
  8023c2:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
  8023c8:	39 fe                	cmp    %edi,%esi
  8023ca:	19 c0                	sbb    %eax,%eax
  8023cc:	25 00 04 00 00       	and    $0x400,%eax
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
  8023d1:	83 c8 07             	or     $0x7,%eax
  8023d4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023d8:	03 15 08 50 80 00    	add    0x805008,%edx
  8023de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023e9:	e8 2f ee ff ff       	call   80121d <sys_page_alloc>
  8023ee:	85 c0                	test   %eax,%eax
  8023f0:	78 04                	js     8023f6 <malloc+0x173>
  8023f2:	89 f3                	mov    %esi,%ebx
  8023f4:	eb 36                	jmp    80242c <malloc+0x1a9>
			for (; i >= 0; i -= PGSIZE)
  8023f6:	85 db                	test   %ebx,%ebx
  8023f8:	78 53                	js     80244d <malloc+0x1ca>
				sys_page_unmap(0, mptr + i);
  8023fa:	89 d8                	mov    %ebx,%eax
  8023fc:	03 05 08 50 80 00    	add    0x805008,%eax
  802402:	89 44 24 04          	mov    %eax,0x4(%esp)
  802406:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80240d:	e8 9a ed ff ff       	call   8011ac <sys_page_unmap>
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
		cont = (i + PGSIZE < n + 4) ? PTE_CONTINUED : 0;
		if (sys_page_alloc(0, mptr + i, PTE_P|PTE_U|PTE_W|cont) < 0){
			for (; i >= 0; i -= PGSIZE)
  802412:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  802418:	79 e0                	jns    8023fa <malloc+0x177>
  80241a:	eb 31                	jmp    80244d <malloc+0x1ca>
  80241c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80241f:	a3 08 50 80 00       	mov    %eax,0x805008
  802424:	bb 00 00 00 00       	mov    $0x0,%ebx
  802429:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80242c:	89 da                	mov    %ebx,%edx
	}

	/*
	 * allocate at mptr - the +4 makes sure we allocate a ref count.
	 */
	for (i = 0; i < n + 4; i += PGSIZE){
  80242e:	39 fb                	cmp    %edi,%ebx
  802430:	72 90                	jb     8023c2 <malloc+0x13f>
				sys_page_unmap(0, mptr + i);
			return 0;	/* out of physical memory */
		}
	}

	ref = (uint32_t*) (mptr + i - 4);
  802432:	a1 08 50 80 00       	mov    0x805008,%eax
	*ref = 2;	/* reference for mptr, reference for returned block */
  802437:	c7 44 18 fc 02 00 00 	movl   $0x2,-0x4(%eax,%ebx,1)
  80243e:	00 
	v = mptr;
	mptr += n;
  80243f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802442:	8d 14 10             	lea    (%eax,%edx,1),%edx
  802445:	89 15 08 50 80 00    	mov    %edx,0x805008
	return v;
  80244b:	eb 05                	jmp    802452 <malloc+0x1cf>
  80244d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802452:	83 c4 3c             	add    $0x3c,%esp
  802455:	5b                   	pop    %ebx
  802456:	5e                   	pop    %esi
  802457:	5f                   	pop    %edi
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    
  80245a:	00 00                	add    %al,(%eax)
  80245c:	00 00                	add    %al,(%eax)
	...

00802460 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802466:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80246c:	b8 01 00 00 00       	mov    $0x1,%eax
  802471:	39 ca                	cmp    %ecx,%edx
  802473:	75 04                	jne    802479 <ipc_find_env+0x19>
  802475:	b0 00                	mov    $0x0,%al
  802477:	eb 0f                	jmp    802488 <ipc_find_env+0x28>
  802479:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80247c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802482:	8b 12                	mov    (%edx),%edx
  802484:	39 ca                	cmp    %ecx,%edx
  802486:	75 0c                	jne    802494 <ipc_find_env+0x34>
			return envs[i].env_id;
  802488:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80248b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  802490:	8b 00                	mov    (%eax),%eax
  802492:	eb 0e                	jmp    8024a2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802494:	83 c0 01             	add    $0x1,%eax
  802497:	3d 00 04 00 00       	cmp    $0x400,%eax
  80249c:	75 db                	jne    802479 <ipc_find_env+0x19>
  80249e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8024a2:	5d                   	pop    %ebp
  8024a3:	c3                   	ret    

008024a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024a4:	55                   	push   %ebp
  8024a5:	89 e5                	mov    %esp,%ebp
  8024a7:	57                   	push   %edi
  8024a8:	56                   	push   %esi
  8024a9:	53                   	push   %ebx
  8024aa:	83 ec 1c             	sub    $0x1c,%esp
  8024ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8024b6:	85 db                	test   %ebx,%ebx
  8024b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024bd:	0f 44 d8             	cmove  %eax,%ebx
  8024c0:	eb 25                	jmp    8024e7 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  8024c2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024c5:	74 20                	je     8024e7 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  8024c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024cb:	c7 44 24 08 59 32 80 	movl   $0x803259,0x8(%esp)
  8024d2:	00 
  8024d3:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8024da:	00 
  8024db:	c7 04 24 77 32 80 00 	movl   $0x803277,(%esp)
  8024e2:	e8 d5 de ff ff       	call   8003bc <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8024e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8024ea:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8024f6:	89 34 24             	mov    %esi,(%esp)
  8024f9:	e8 d0 eb ff ff       	call   8010ce <sys_ipc_try_send>
  8024fe:	85 c0                	test   %eax,%eax
  802500:	75 c0                	jne    8024c2 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802502:	e8 4d ed ff ff       	call   801254 <sys_yield>
}
  802507:	83 c4 1c             	add    $0x1c,%esp
  80250a:	5b                   	pop    %ebx
  80250b:	5e                   	pop    %esi
  80250c:	5f                   	pop    %edi
  80250d:	5d                   	pop    %ebp
  80250e:	c3                   	ret    

0080250f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80250f:	55                   	push   %ebp
  802510:	89 e5                	mov    %esp,%ebp
  802512:	83 ec 28             	sub    $0x28,%esp
  802515:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802518:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80251b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80251e:	8b 75 08             	mov    0x8(%ebp),%esi
  802521:	8b 45 0c             	mov    0xc(%ebp),%eax
  802524:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802527:	85 c0                	test   %eax,%eax
  802529:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80252e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802531:	89 04 24             	mov    %eax,(%esp)
  802534:	e8 5c eb ff ff       	call   801095 <sys_ipc_recv>
  802539:	89 c3                	mov    %eax,%ebx
  80253b:	85 c0                	test   %eax,%eax
  80253d:	79 2a                	jns    802569 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80253f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802543:	89 44 24 04          	mov    %eax,0x4(%esp)
  802547:	c7 04 24 81 32 80 00 	movl   $0x803281,(%esp)
  80254e:	e8 22 df ff ff       	call   800475 <cprintf>
		if(from_env_store != NULL)
  802553:	85 f6                	test   %esi,%esi
  802555:	74 06                	je     80255d <ipc_recv+0x4e>
			*from_env_store = 0;
  802557:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80255d:	85 ff                	test   %edi,%edi
  80255f:	74 2c                	je     80258d <ipc_recv+0x7e>
			*perm_store = 0;
  802561:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  802567:	eb 24                	jmp    80258d <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  802569:	85 f6                	test   %esi,%esi
  80256b:	74 0a                	je     802577 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  80256d:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802572:	8b 40 74             	mov    0x74(%eax),%eax
  802575:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  802577:	85 ff                	test   %edi,%edi
  802579:	74 0a                	je     802585 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  80257b:	a1 1c 50 80 00       	mov    0x80501c,%eax
  802580:	8b 40 78             	mov    0x78(%eax),%eax
  802583:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  802585:	a1 1c 50 80 00       	mov    0x80501c,%eax
  80258a:	8b 58 70             	mov    0x70(%eax),%ebx
}
  80258d:	89 d8                	mov    %ebx,%eax
  80258f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802592:	8b 75 f8             	mov    -0x8(%ebp),%esi
  802595:	8b 7d fc             	mov    -0x4(%ebp),%edi
  802598:	89 ec                	mov    %ebp,%esp
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    

0080259c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80259c:	55                   	push   %ebp
  80259d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80259f:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a2:	89 c2                	mov    %eax,%edx
  8025a4:	c1 ea 16             	shr    $0x16,%edx
  8025a7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025ae:	f6 c2 01             	test   $0x1,%dl
  8025b1:	74 20                	je     8025d3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025b3:	c1 e8 0c             	shr    $0xc,%eax
  8025b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025bd:	a8 01                	test   $0x1,%al
  8025bf:	74 12                	je     8025d3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025c1:	c1 e8 0c             	shr    $0xc,%eax
  8025c4:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025c9:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025ce:	0f b7 c0             	movzwl %ax,%eax
  8025d1:	eb 05                	jmp    8025d8 <pageref+0x3c>
  8025d3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    
  8025da:	00 00                	add    %al,(%eax)
  8025dc:	00 00                	add    %al,(%eax)
	...

008025e0 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  8025e0:	55                   	push   %ebp
  8025e1:	89 e5                	mov    %esp,%ebp
  8025e3:	57                   	push   %edi
  8025e4:	56                   	push   %esi
  8025e5:	53                   	push   %ebx
  8025e6:	83 ec 20             	sub    $0x20,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  8025e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  8025ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8025f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  8025f5:	8d 55 f3             	lea    -0xd(%ebp),%edx
  8025f8:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8025fb:	bb 0c 50 80 00       	mov    $0x80500c,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802600:	b9 cd ff ff ff       	mov    $0xffffffcd,%ecx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802605:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802608:	0f b6 37             	movzbl (%edi),%esi
  80260b:	ba 00 00 00 00       	mov    $0x0,%edx
  802610:	89 d0                	mov    %edx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	89 de                	mov    %ebx,%esi
  802616:	89 c3                	mov    %eax,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802618:	89 d0                	mov    %edx,%eax
  80261a:	f6 e1                	mul    %cl
  80261c:	66 c1 e8 08          	shr    $0x8,%ax
  802620:	c0 e8 03             	shr    $0x3,%al
  802623:	89 c7                	mov    %eax,%edi
  802625:	8d 04 80             	lea    (%eax,%eax,4),%eax
  802628:	01 c0                	add    %eax,%eax
  80262a:	28 c2                	sub    %al,%dl
  80262c:	89 d0                	mov    %edx,%eax
      *ap /= (u8_t)10;
  80262e:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  802630:	0f b6 fb             	movzbl %bl,%edi
  802633:	83 c0 30             	add    $0x30,%eax
  802636:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  80263a:	8d 43 01             	lea    0x1(%ebx),%eax
    } while(*ap);
  80263d:	84 d2                	test   %dl,%dl
  80263f:	74 04                	je     802645 <inet_ntoa+0x65>
  802641:	89 c3                	mov    %eax,%ebx
  802643:	eb d3                	jmp    802618 <inet_ntoa+0x38>
  802645:	88 45 d7             	mov    %al,-0x29(%ebp)
  802648:	89 df                	mov    %ebx,%edi
  80264a:	89 f3                	mov    %esi,%ebx
  80264c:	89 d6                	mov    %edx,%esi
  80264e:	89 fa                	mov    %edi,%edx
  802650:	88 55 dc             	mov    %dl,-0x24(%ebp)
  802653:	89 f0                	mov    %esi,%eax
  802655:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802658:	88 07                	mov    %al,(%edi)
    while(i--)
  80265a:	80 7d d7 00          	cmpb   $0x0,-0x29(%ebp)
  80265e:	74 2a                	je     80268a <inet_ntoa+0xaa>
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802660:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  802664:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802667:	8d 7c 03 01          	lea    0x1(%ebx,%eax,1),%edi
  80266b:	89 d8                	mov    %ebx,%eax
  80266d:	89 de                	mov    %ebx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  80266f:	0f b6 da             	movzbl %dl,%ebx
  802672:	0f b6 5c 1d ed       	movzbl -0x13(%ebp,%ebx,1),%ebx
  802677:	88 18                	mov    %bl,(%eax)
  802679:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  80267c:	83 ea 01             	sub    $0x1,%edx
  80267f:	39 f8                	cmp    %edi,%eax
  802681:	75 ec                	jne    80266f <inet_ntoa+0x8f>
  802683:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802686:	8d 5c 16 01          	lea    0x1(%esi,%edx,1),%ebx
      *rp++ = inv[i];
    *rp++ = '.';
  80268a:	c6 03 2e             	movb   $0x2e,(%ebx)
  80268d:	8d 43 01             	lea    0x1(%ebx),%eax
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802690:	8b 7d d8             	mov    -0x28(%ebp),%edi
  802693:	39 7d e0             	cmp    %edi,-0x20(%ebp)
  802696:	74 0b                	je     8026a3 <inet_ntoa+0xc3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802698:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  80269c:	89 c3                	mov    %eax,%ebx
  80269e:	e9 62 ff ff ff       	jmp    802605 <inet_ntoa+0x25>
  }
  *--rp = 0;
  8026a3:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  8026a6:	b8 0c 50 80 00       	mov    $0x80500c,%eax
  8026ab:	83 c4 20             	add    $0x20,%esp
  8026ae:	5b                   	pop    %ebx
  8026af:	5e                   	pop    %esi
  8026b0:	5f                   	pop    %edi
  8026b1:	5d                   	pop    %ebp
  8026b2:	c3                   	ret    

008026b3 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  8026b3:	55                   	push   %ebp
  8026b4:	89 e5                	mov    %esp,%ebp
  8026b6:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8026ba:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  8026be:	5d                   	pop    %ebp
  8026bf:	c3                   	ret    

008026c0 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
  8026c3:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  8026c6:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  8026ca:	89 04 24             	mov    %eax,(%esp)
  8026cd:	e8 e1 ff ff ff       	call   8026b3 <htons>
}
  8026d2:	c9                   	leave  
  8026d3:	c3                   	ret    

008026d4 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  8026d4:	55                   	push   %ebp
  8026d5:	89 e5                	mov    %esp,%ebp
  8026d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8026da:	89 d1                	mov    %edx,%ecx
  8026dc:	c1 e9 18             	shr    $0x18,%ecx
  8026df:	89 d0                	mov    %edx,%eax
  8026e1:	c1 e0 18             	shl    $0x18,%eax
  8026e4:	09 c8                	or     %ecx,%eax
  8026e6:	89 d1                	mov    %edx,%ecx
  8026e8:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  8026ee:	c1 e1 08             	shl    $0x8,%ecx
  8026f1:	09 c8                	or     %ecx,%eax
  8026f3:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  8026f9:	c1 ea 08             	shr    $0x8,%edx
  8026fc:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  8026fe:	5d                   	pop    %ebp
  8026ff:	c3                   	ret    

00802700 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802700:	55                   	push   %ebp
  802701:	89 e5                	mov    %esp,%ebp
  802703:	57                   	push   %edi
  802704:	56                   	push   %esi
  802705:	53                   	push   %ebx
  802706:	83 ec 28             	sub    $0x28,%esp
  802709:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  80270c:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  80270f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802712:	80 f9 09             	cmp    $0x9,%cl
  802715:	0f 87 a8 01 00 00    	ja     8028c3 <inet_aton+0x1c3>
  80271b:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  80271e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802721:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  802724:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  802727:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  80272e:	83 fa 30             	cmp    $0x30,%edx
  802731:	75 24                	jne    802757 <inet_aton+0x57>
      c = *++cp;
  802733:	83 c0 01             	add    $0x1,%eax
  802736:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  802739:	83 fa 78             	cmp    $0x78,%edx
  80273c:	74 0c                	je     80274a <inet_aton+0x4a>
  80273e:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  802745:	83 fa 58             	cmp    $0x58,%edx
  802748:	75 0d                	jne    802757 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  80274a:	83 c0 01             	add    $0x1,%eax
  80274d:	0f be 10             	movsbl (%eax),%edx
  802750:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  802757:	83 c0 01             	add    $0x1,%eax
  80275a:	be 00 00 00 00       	mov    $0x0,%esi
  80275f:	eb 03                	jmp    802764 <inet_aton+0x64>
  802761:	83 c0 01             	add    $0x1,%eax
  802764:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  802767:	89 d1                	mov    %edx,%ecx
  802769:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  80276c:	80 fb 09             	cmp    $0x9,%bl
  80276f:	77 0d                	ja     80277e <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  802771:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  802775:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  802779:	0f be 10             	movsbl (%eax),%edx
  80277c:	eb e3                	jmp    802761 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  80277e:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  802782:	75 2b                	jne    8027af <inet_aton+0xaf>
  802784:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802787:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  80278a:	80 fb 05             	cmp    $0x5,%bl
  80278d:	76 08                	jbe    802797 <inet_aton+0x97>
  80278f:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802792:	80 fb 05             	cmp    $0x5,%bl
  802795:	77 18                	ja     8027af <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802797:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  80279b:	19 c9                	sbb    %ecx,%ecx
  80279d:	83 e1 20             	and    $0x20,%ecx
  8027a0:	c1 e6 04             	shl    $0x4,%esi
  8027a3:	29 ca                	sub    %ecx,%edx
  8027a5:	8d 52 c9             	lea    -0x37(%edx),%edx
  8027a8:	09 d6                	or     %edx,%esi
        c = *++cp;
  8027aa:	0f be 10             	movsbl (%eax),%edx
  8027ad:	eb b2                	jmp    802761 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  8027af:	83 fa 2e             	cmp    $0x2e,%edx
  8027b2:	75 29                	jne    8027dd <inet_aton+0xdd>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  8027b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8027b7:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  8027ba:	0f 86 03 01 00 00    	jbe    8028c3 <inet_aton+0x1c3>
        return (0);
      *pp++ = val;
  8027c0:	89 32                	mov    %esi,(%edx)
      c = *++cp;
  8027c2:	8d 47 01             	lea    0x1(%edi),%eax
  8027c5:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  8027c8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8027cb:	80 f9 09             	cmp    $0x9,%cl
  8027ce:	0f 87 ef 00 00 00    	ja     8028c3 <inet_aton+0x1c3>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  8027d4:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  8027d8:	e9 4a ff ff ff       	jmp    802727 <inet_aton+0x27>
  8027dd:	89 f3                	mov    %esi,%ebx
  8027df:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  8027e1:	85 d2                	test   %edx,%edx
  8027e3:	74 36                	je     80281b <inet_aton+0x11b>
  8027e5:	80 f9 1f             	cmp    $0x1f,%cl
  8027e8:	0f 86 d5 00 00 00    	jbe    8028c3 <inet_aton+0x1c3>
  8027ee:	84 d2                	test   %dl,%dl
  8027f0:	0f 88 cd 00 00 00    	js     8028c3 <inet_aton+0x1c3>
  8027f6:	83 fa 20             	cmp    $0x20,%edx
  8027f9:	74 20                	je     80281b <inet_aton+0x11b>
  8027fb:	83 fa 0c             	cmp    $0xc,%edx
  8027fe:	66 90                	xchg   %ax,%ax
  802800:	74 19                	je     80281b <inet_aton+0x11b>
  802802:	83 fa 0a             	cmp    $0xa,%edx
  802805:	74 14                	je     80281b <inet_aton+0x11b>
  802807:	83 fa 0d             	cmp    $0xd,%edx
  80280a:	74 0f                	je     80281b <inet_aton+0x11b>
  80280c:	83 fa 09             	cmp    $0x9,%edx
  80280f:	90                   	nop
  802810:	74 09                	je     80281b <inet_aton+0x11b>
  802812:	83 fa 0b             	cmp    $0xb,%edx
  802815:	0f 85 a8 00 00 00    	jne    8028c3 <inet_aton+0x1c3>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  80281b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80281e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802821:	29 d1                	sub    %edx,%ecx
  802823:	89 ca                	mov    %ecx,%edx
  802825:	c1 fa 02             	sar    $0x2,%edx
  802828:	83 c2 01             	add    $0x1,%edx
  80282b:	83 fa 02             	cmp    $0x2,%edx
  80282e:	74 2a                	je     80285a <inet_aton+0x15a>
  802830:	83 fa 02             	cmp    $0x2,%edx
  802833:	7f 0d                	jg     802842 <inet_aton+0x142>
  802835:	85 d2                	test   %edx,%edx
  802837:	0f 84 86 00 00 00    	je     8028c3 <inet_aton+0x1c3>
  80283d:	8d 76 00             	lea    0x0(%esi),%esi
  802840:	eb 62                	jmp    8028a4 <inet_aton+0x1a4>
  802842:	83 fa 03             	cmp    $0x3,%edx
  802845:	8d 76 00             	lea    0x0(%esi),%esi
  802848:	74 22                	je     80286c <inet_aton+0x16c>
  80284a:	83 fa 04             	cmp    $0x4,%edx
  80284d:	8d 76 00             	lea    0x0(%esi),%esi
  802850:	75 52                	jne    8028a4 <inet_aton+0x1a4>
  802852:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802858:	eb 2b                	jmp    802885 <inet_aton+0x185>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  80285a:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  80285f:	90                   	nop
  802860:	77 61                	ja     8028c3 <inet_aton+0x1c3>
      return (0);
    val |= parts[0] << 24;
  802862:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802865:	c1 e3 18             	shl    $0x18,%ebx
  802868:	09 c3                	or     %eax,%ebx
    break;
  80286a:	eb 38                	jmp    8028a4 <inet_aton+0x1a4>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  80286c:	3d ff ff 00 00       	cmp    $0xffff,%eax
  802871:	77 50                	ja     8028c3 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  802873:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  802876:	c1 e3 10             	shl    $0x10,%ebx
  802879:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80287c:	c1 e2 18             	shl    $0x18,%edx
  80287f:	09 d3                	or     %edx,%ebx
  802881:	09 c3                	or     %eax,%ebx
    break;
  802883:	eb 1f                	jmp    8028a4 <inet_aton+0x1a4>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  802885:	3d ff 00 00 00       	cmp    $0xff,%eax
  80288a:	77 37                	ja     8028c3 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  80288c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  80288f:	c1 e3 10             	shl    $0x10,%ebx
  802892:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802895:	c1 e2 18             	shl    $0x18,%edx
  802898:	09 d3                	or     %edx,%ebx
  80289a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  80289d:	c1 e2 08             	shl    $0x8,%edx
  8028a0:	09 d3                	or     %edx,%ebx
  8028a2:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  8028a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8028a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8028ad:	74 19                	je     8028c8 <inet_aton+0x1c8>
    addr->s_addr = htonl(val);
  8028af:	89 1c 24             	mov    %ebx,(%esp)
  8028b2:	e8 1d fe ff ff       	call   8026d4 <htonl>
  8028b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8028ba:	89 03                	mov    %eax,(%ebx)
  8028bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8028c1:	eb 05                	jmp    8028c8 <inet_aton+0x1c8>
  8028c3:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  8028c8:	83 c4 28             	add    $0x28,%esp
  8028cb:	5b                   	pop    %ebx
  8028cc:	5e                   	pop    %esi
  8028cd:	5f                   	pop    %edi
  8028ce:	5d                   	pop    %ebp
  8028cf:	c3                   	ret    

008028d0 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  8028d0:	55                   	push   %ebp
  8028d1:	89 e5                	mov    %esp,%ebp
  8028d3:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  8028d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8028d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8028e0:	89 04 24             	mov    %eax,(%esp)
  8028e3:	e8 18 fe ff ff       	call   802700 <inet_aton>
  8028e8:	85 c0                	test   %eax,%eax
  8028ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8028ef:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  8028f3:	c9                   	leave  
  8028f4:	c3                   	ret    

008028f5 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  8028f5:	55                   	push   %ebp
  8028f6:	89 e5                	mov    %esp,%ebp
  8028f8:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  8028fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8028fe:	89 04 24             	mov    %eax,(%esp)
  802901:	e8 ce fd ff ff       	call   8026d4 <htonl>
}
  802906:	c9                   	leave  
  802907:	c3                   	ret    
	...

00802910 <__udivdi3>:
  802910:	55                   	push   %ebp
  802911:	89 e5                	mov    %esp,%ebp
  802913:	57                   	push   %edi
  802914:	56                   	push   %esi
  802915:	83 ec 10             	sub    $0x10,%esp
  802918:	8b 45 14             	mov    0x14(%ebp),%eax
  80291b:	8b 55 08             	mov    0x8(%ebp),%edx
  80291e:	8b 75 10             	mov    0x10(%ebp),%esi
  802921:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802924:	85 c0                	test   %eax,%eax
  802926:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802929:	75 35                	jne    802960 <__udivdi3+0x50>
  80292b:	39 fe                	cmp    %edi,%esi
  80292d:	77 61                	ja     802990 <__udivdi3+0x80>
  80292f:	85 f6                	test   %esi,%esi
  802931:	75 0b                	jne    80293e <__udivdi3+0x2e>
  802933:	b8 01 00 00 00       	mov    $0x1,%eax
  802938:	31 d2                	xor    %edx,%edx
  80293a:	f7 f6                	div    %esi
  80293c:	89 c6                	mov    %eax,%esi
  80293e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802941:	31 d2                	xor    %edx,%edx
  802943:	89 f8                	mov    %edi,%eax
  802945:	f7 f6                	div    %esi
  802947:	89 c7                	mov    %eax,%edi
  802949:	89 c8                	mov    %ecx,%eax
  80294b:	f7 f6                	div    %esi
  80294d:	89 c1                	mov    %eax,%ecx
  80294f:	89 fa                	mov    %edi,%edx
  802951:	89 c8                	mov    %ecx,%eax
  802953:	83 c4 10             	add    $0x10,%esp
  802956:	5e                   	pop    %esi
  802957:	5f                   	pop    %edi
  802958:	5d                   	pop    %ebp
  802959:	c3                   	ret    
  80295a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802960:	39 f8                	cmp    %edi,%eax
  802962:	77 1c                	ja     802980 <__udivdi3+0x70>
  802964:	0f bd d0             	bsr    %eax,%edx
  802967:	83 f2 1f             	xor    $0x1f,%edx
  80296a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80296d:	75 39                	jne    8029a8 <__udivdi3+0x98>
  80296f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802972:	0f 86 a0 00 00 00    	jbe    802a18 <__udivdi3+0x108>
  802978:	39 f8                	cmp    %edi,%eax
  80297a:	0f 82 98 00 00 00    	jb     802a18 <__udivdi3+0x108>
  802980:	31 ff                	xor    %edi,%edi
  802982:	31 c9                	xor    %ecx,%ecx
  802984:	89 c8                	mov    %ecx,%eax
  802986:	89 fa                	mov    %edi,%edx
  802988:	83 c4 10             	add    $0x10,%esp
  80298b:	5e                   	pop    %esi
  80298c:	5f                   	pop    %edi
  80298d:	5d                   	pop    %ebp
  80298e:	c3                   	ret    
  80298f:	90                   	nop
  802990:	89 d1                	mov    %edx,%ecx
  802992:	89 fa                	mov    %edi,%edx
  802994:	89 c8                	mov    %ecx,%eax
  802996:	31 ff                	xor    %edi,%edi
  802998:	f7 f6                	div    %esi
  80299a:	89 c1                	mov    %eax,%ecx
  80299c:	89 fa                	mov    %edi,%edx
  80299e:	89 c8                	mov    %ecx,%eax
  8029a0:	83 c4 10             	add    $0x10,%esp
  8029a3:	5e                   	pop    %esi
  8029a4:	5f                   	pop    %edi
  8029a5:	5d                   	pop    %ebp
  8029a6:	c3                   	ret    
  8029a7:	90                   	nop
  8029a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8029ac:	89 f2                	mov    %esi,%edx
  8029ae:	d3 e0                	shl    %cl,%eax
  8029b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8029b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8029b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8029bb:	89 c1                	mov    %eax,%ecx
  8029bd:	d3 ea                	shr    %cl,%edx
  8029bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8029c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8029c6:	d3 e6                	shl    %cl,%esi
  8029c8:	89 c1                	mov    %eax,%ecx
  8029ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8029cd:	89 fe                	mov    %edi,%esi
  8029cf:	d3 ee                	shr    %cl,%esi
  8029d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8029d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8029d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8029db:	d3 e7                	shl    %cl,%edi
  8029dd:	89 c1                	mov    %eax,%ecx
  8029df:	d3 ea                	shr    %cl,%edx
  8029e1:	09 d7                	or     %edx,%edi
  8029e3:	89 f2                	mov    %esi,%edx
  8029e5:	89 f8                	mov    %edi,%eax
  8029e7:	f7 75 ec             	divl   -0x14(%ebp)
  8029ea:	89 d6                	mov    %edx,%esi
  8029ec:	89 c7                	mov    %eax,%edi
  8029ee:	f7 65 e8             	mull   -0x18(%ebp)
  8029f1:	39 d6                	cmp    %edx,%esi
  8029f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8029f6:	72 30                	jb     802a28 <__udivdi3+0x118>
  8029f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8029fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8029ff:	d3 e2                	shl    %cl,%edx
  802a01:	39 c2                	cmp    %eax,%edx
  802a03:	73 05                	jae    802a0a <__udivdi3+0xfa>
  802a05:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802a08:	74 1e                	je     802a28 <__udivdi3+0x118>
  802a0a:	89 f9                	mov    %edi,%ecx
  802a0c:	31 ff                	xor    %edi,%edi
  802a0e:	e9 71 ff ff ff       	jmp    802984 <__udivdi3+0x74>
  802a13:	90                   	nop
  802a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a18:	31 ff                	xor    %edi,%edi
  802a1a:	b9 01 00 00 00       	mov    $0x1,%ecx
  802a1f:	e9 60 ff ff ff       	jmp    802984 <__udivdi3+0x74>
  802a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802a28:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802a2b:	31 ff                	xor    %edi,%edi
  802a2d:	89 c8                	mov    %ecx,%eax
  802a2f:	89 fa                	mov    %edi,%edx
  802a31:	83 c4 10             	add    $0x10,%esp
  802a34:	5e                   	pop    %esi
  802a35:	5f                   	pop    %edi
  802a36:	5d                   	pop    %ebp
  802a37:	c3                   	ret    
	...

00802a40 <__umoddi3>:
  802a40:	55                   	push   %ebp
  802a41:	89 e5                	mov    %esp,%ebp
  802a43:	57                   	push   %edi
  802a44:	56                   	push   %esi
  802a45:	83 ec 20             	sub    $0x20,%esp
  802a48:	8b 55 14             	mov    0x14(%ebp),%edx
  802a4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802a4e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802a51:	8b 75 0c             	mov    0xc(%ebp),%esi
  802a54:	85 d2                	test   %edx,%edx
  802a56:	89 c8                	mov    %ecx,%eax
  802a58:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802a5b:	75 13                	jne    802a70 <__umoddi3+0x30>
  802a5d:	39 f7                	cmp    %esi,%edi
  802a5f:	76 3f                	jbe    802aa0 <__umoddi3+0x60>
  802a61:	89 f2                	mov    %esi,%edx
  802a63:	f7 f7                	div    %edi
  802a65:	89 d0                	mov    %edx,%eax
  802a67:	31 d2                	xor    %edx,%edx
  802a69:	83 c4 20             	add    $0x20,%esp
  802a6c:	5e                   	pop    %esi
  802a6d:	5f                   	pop    %edi
  802a6e:	5d                   	pop    %ebp
  802a6f:	c3                   	ret    
  802a70:	39 f2                	cmp    %esi,%edx
  802a72:	77 4c                	ja     802ac0 <__umoddi3+0x80>
  802a74:	0f bd ca             	bsr    %edx,%ecx
  802a77:	83 f1 1f             	xor    $0x1f,%ecx
  802a7a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802a7d:	75 51                	jne    802ad0 <__umoddi3+0x90>
  802a7f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802a82:	0f 87 e0 00 00 00    	ja     802b68 <__umoddi3+0x128>
  802a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a8b:	29 f8                	sub    %edi,%eax
  802a8d:	19 d6                	sbb    %edx,%esi
  802a8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a95:	89 f2                	mov    %esi,%edx
  802a97:	83 c4 20             	add    $0x20,%esp
  802a9a:	5e                   	pop    %esi
  802a9b:	5f                   	pop    %edi
  802a9c:	5d                   	pop    %ebp
  802a9d:	c3                   	ret    
  802a9e:	66 90                	xchg   %ax,%ax
  802aa0:	85 ff                	test   %edi,%edi
  802aa2:	75 0b                	jne    802aaf <__umoddi3+0x6f>
  802aa4:	b8 01 00 00 00       	mov    $0x1,%eax
  802aa9:	31 d2                	xor    %edx,%edx
  802aab:	f7 f7                	div    %edi
  802aad:	89 c7                	mov    %eax,%edi
  802aaf:	89 f0                	mov    %esi,%eax
  802ab1:	31 d2                	xor    %edx,%edx
  802ab3:	f7 f7                	div    %edi
  802ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ab8:	f7 f7                	div    %edi
  802aba:	eb a9                	jmp    802a65 <__umoddi3+0x25>
  802abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ac0:	89 c8                	mov    %ecx,%eax
  802ac2:	89 f2                	mov    %esi,%edx
  802ac4:	83 c4 20             	add    $0x20,%esp
  802ac7:	5e                   	pop    %esi
  802ac8:	5f                   	pop    %edi
  802ac9:	5d                   	pop    %ebp
  802aca:	c3                   	ret    
  802acb:	90                   	nop
  802acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ad0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802ad4:	d3 e2                	shl    %cl,%edx
  802ad6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802ad9:	ba 20 00 00 00       	mov    $0x20,%edx
  802ade:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802ae1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802ae4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802ae8:	89 fa                	mov    %edi,%edx
  802aea:	d3 ea                	shr    %cl,%edx
  802aec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802af0:	0b 55 f4             	or     -0xc(%ebp),%edx
  802af3:	d3 e7                	shl    %cl,%edi
  802af5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802af9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802afc:	89 f2                	mov    %esi,%edx
  802afe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802b01:	89 c7                	mov    %eax,%edi
  802b03:	d3 ea                	shr    %cl,%edx
  802b05:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b09:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802b0c:	89 c2                	mov    %eax,%edx
  802b0e:	d3 e6                	shl    %cl,%esi
  802b10:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b14:	d3 ea                	shr    %cl,%edx
  802b16:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b1a:	09 d6                	or     %edx,%esi
  802b1c:	89 f0                	mov    %esi,%eax
  802b1e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802b21:	d3 e7                	shl    %cl,%edi
  802b23:	89 f2                	mov    %esi,%edx
  802b25:	f7 75 f4             	divl   -0xc(%ebp)
  802b28:	89 d6                	mov    %edx,%esi
  802b2a:	f7 65 e8             	mull   -0x18(%ebp)
  802b2d:	39 d6                	cmp    %edx,%esi
  802b2f:	72 2b                	jb     802b5c <__umoddi3+0x11c>
  802b31:	39 c7                	cmp    %eax,%edi
  802b33:	72 23                	jb     802b58 <__umoddi3+0x118>
  802b35:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b39:	29 c7                	sub    %eax,%edi
  802b3b:	19 d6                	sbb    %edx,%esi
  802b3d:	89 f0                	mov    %esi,%eax
  802b3f:	89 f2                	mov    %esi,%edx
  802b41:	d3 ef                	shr    %cl,%edi
  802b43:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802b47:	d3 e0                	shl    %cl,%eax
  802b49:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802b4d:	09 f8                	or     %edi,%eax
  802b4f:	d3 ea                	shr    %cl,%edx
  802b51:	83 c4 20             	add    $0x20,%esp
  802b54:	5e                   	pop    %esi
  802b55:	5f                   	pop    %edi
  802b56:	5d                   	pop    %ebp
  802b57:	c3                   	ret    
  802b58:	39 d6                	cmp    %edx,%esi
  802b5a:	75 d9                	jne    802b35 <__umoddi3+0xf5>
  802b5c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802b5f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802b62:	eb d1                	jmp    802b35 <__umoddi3+0xf5>
  802b64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802b68:	39 f2                	cmp    %esi,%edx
  802b6a:	0f 82 18 ff ff ff    	jb     802a88 <__umoddi3+0x48>
  802b70:	e9 1d ff ff ff       	jmp    802a92 <__umoddi3+0x52>
