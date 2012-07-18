
obj/user/testfile.debug:     file format elf32-i386


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
  80002c:	e8 4f 07 00 00       	call   800780 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
  80003b:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800041:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  800048:	e8 9d 0f 00 00       	call   800fea <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80005a:	e8 11 17 00 00       	call   801770 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 35 17 00 00       	call   8017b4 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 88 17 00 00       	call   801823 <ipc_recv>
}
  80009b:	83 c4 14             	add    $0x14,%esp
  80009e:	5b                   	pop    %ebx
  80009f:	5d                   	pop    %ebp
  8000a0:	c3                   	ret    

008000a1 <umain>:

void
umain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	57                   	push   %edi
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	81 ec dc 02 00 00    	sub    $0x2dc,%esp
	struct Fd *fd;
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];
	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8000ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b2:	b8 20 24 80 00       	mov    $0x802420,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 2b 24 80 	movl   $0x80242b,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8000e0:	e8 07 07 00 00       	call   8007ec <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 e0 25 80 	movl   $0x8025e0,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8000fc:	e8 eb 06 00 00       	call   8007ec <_panic>
	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 55 24 80 00       	mov    $0x802455,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 5e 24 80 	movl   $0x80245e,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80012f:	e8 b8 06 00 00       	call   8007ec <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 04 26 80 	movl   $0x802604,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  800166:	e8 81 06 00 00       	call   8007ec <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 76 24 80 00 	movl   $0x802476,(%esp)
  800172:	e8 2e 07 00 00       	call   8008a5 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 30 80 00    	call   *0x80301c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 8a 24 80 	movl   $0x80248a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8001ad:	e8 3a 06 00 00       	call   8007ec <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 30 80 00       	mov    0x803000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 e1 0d 00 00       	call   800fa0 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 30 80 00       	mov    0x803000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 cf 0d 00 00       	call   800fa0 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 34 26 80 	movl   $0x802634,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8001f3:	e8 f4 05 00 00       	call   8007ec <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 98 24 80 00 	movl   $0x802498,(%esp)
  8001ff:	e8 a1 06 00 00       	call   8008a5 <cprintf>

	memset(buf, 0, sizeof buf);
  800204:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80020b:	00 
  80020c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800213:	00 
  800214:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  80021a:	89 1c 24             	mov    %ebx,(%esp)
  80021d:	e8 54 0f 00 00       	call   801176 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800222:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800229:	00 
  80022a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80022e:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800235:	ff 15 10 30 80 00    	call   *0x803010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 ab 24 80 	movl   $0x8024ab,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80025a:	e8 8d 05 00 00       	call   8007ec <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 30 80 00       	mov    0x803000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 2f 0e 00 00       	call   8010a5 <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 b9 24 80 	movl   $0x8024b9,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  800291:	e8 56 05 00 00       	call   8007ec <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 d7 24 80 00 	movl   $0x8024d7,(%esp)
  80029d:	e8 03 06 00 00       	call   8008a5 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 30 80 00    	call   *0x803018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 ea 24 80 	movl   $0x8024ea,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8002ce:	e8 19 05 00 00       	call   8007ec <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 f9 24 80 00 	movl   $0x8024f9,(%esp)
  8002da:	e8 c6 05 00 00       	call   8008a5 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8002df:	b8 00 c0 cc cc       	mov    $0xccccc000,%eax
  8002e4:	8b 10                	mov    (%eax),%edx
  8002e6:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8002e9:	8b 50 04             	mov    0x4(%eax),%edx
  8002ec:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8002ef:	8b 50 08             	mov    0x8(%eax),%edx
  8002f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8002f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8002fb:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  800302:	cc 
  800303:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80030a:	e8 5a 12 00 00       	call   801569 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80030f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800316:	00 
  800317:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 15 10 30 80 00    	call   *0x803010
  80032d:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800330:	74 20                	je     800352 <umain+0x2b1>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800336:	c7 44 24 08 5c 26 80 	movl   $0x80265c,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80034d:	e8 9a 04 00 00       	call   8007ec <_panic>
	cprintf("stale fileid is good\n");
  800352:	c7 04 24 0d 25 80 00 	movl   $0x80250d,(%esp)
  800359:	e8 47 05 00 00       	call   8008a5 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  80035e:	ba 02 01 00 00       	mov    $0x102,%edx
  800363:	b8 23 25 80 00       	mov    $0x802523,%eax
  800368:	e8 c7 fc ff ff       	call   800034 <xopen>
  80036d:	85 c0                	test   %eax,%eax
  80036f:	79 20                	jns    800391 <umain+0x2f0>
		panic("serve_open /new-file: %e", r);
  800371:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800375:	c7 44 24 08 2d 25 80 	movl   $0x80252d,0x8(%esp)
  80037c:	00 
  80037d:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  800384:	00 
  800385:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80038c:	e8 5b 04 00 00       	call   8007ec <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800391:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  800397:	a1 00 30 80 00       	mov    0x803000,%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 fc 0b 00 00       	call   800fa0 <strlen>
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	a1 00 30 80 00       	mov    0x803000,%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003b8:	ff d3                	call   *%ebx
  8003ba:	89 c3                	mov    %eax,%ebx
  8003bc:	a1 00 30 80 00       	mov    0x803000,%eax
  8003c1:	89 04 24             	mov    %eax,(%esp)
  8003c4:	e8 d7 0b 00 00       	call   800fa0 <strlen>
  8003c9:	39 c3                	cmp    %eax,%ebx
  8003cb:	74 20                	je     8003ed <umain+0x34c>
		panic("file_write: %e", r);
  8003cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d1:	c7 44 24 08 46 25 80 	movl   $0x802546,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8003e8:	e8 ff 03 00 00       	call   8007ec <_panic>
	cprintf("file_write is good\n");
  8003ed:	c7 04 24 55 25 80 00 	movl   $0x802555,(%esp)
  8003f4:	e8 ac 04 00 00       	call   8008a5 <cprintf>

	FVA->fd_offset = 0;
  8003f9:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800400:	00 00 00 
	memset(buf, 0, sizeof buf);
  800403:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  80040a:	00 
  80040b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800412:	00 
  800413:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800419:	89 1c 24             	mov    %ebx,(%esp)
  80041c:	e8 55 0d 00 00       	call   801176 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  800421:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800428:	00 
  800429:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80042d:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800434:	ff 15 10 30 80 00    	call   *0x803010
  80043a:	89 c3                	mov    %eax,%ebx
  80043c:	85 c0                	test   %eax,%eax
  80043e:	79 20                	jns    800460 <umain+0x3bf>
		panic("file_read after file_write: %e", r);
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	c7 44 24 08 94 26 80 	movl   $0x802694,0x8(%esp)
  80044b:	00 
  80044c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  800453:	00 
  800454:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80045b:	e8 8c 03 00 00       	call   8007ec <_panic>
	if (r != strlen(msg))
  800460:	a1 00 30 80 00       	mov    0x803000,%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	e8 33 0b 00 00       	call   800fa0 <strlen>
  80046d:	39 c3                	cmp    %eax,%ebx
  80046f:	74 20                	je     800491 <umain+0x3f0>
		panic("file_read after file_write returned wrong length: %d", r);
  800471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800475:	c7 44 24 08 b4 26 80 	movl   $0x8026b4,0x8(%esp)
  80047c:	00 
  80047d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800484:	00 
  800485:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80048c:	e8 5b 03 00 00       	call   8007ec <_panic>
	if (strcmp(buf, msg) != 0)
  800491:	a1 00 30 80 00       	mov    0x803000,%eax
  800496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 fd 0b 00 00       	call   8010a5 <strcmp>
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	74 1c                	je     8004c8 <umain+0x427>
		panic("file_read after file_write returned wrong data");
  8004ac:	c7 44 24 08 ec 26 80 	movl   $0x8026ec,0x8(%esp)
  8004b3:	00 
  8004b4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8004bb:	00 
  8004bc:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8004c3:	e8 24 03 00 00       	call   8007ec <_panic>
	cprintf("file_read after file_write is good\n");
  8004c8:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  8004cf:	e8 d1 03 00 00       	call   8008a5 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004db:	00 
  8004dc:	c7 04 24 20 24 80 00 	movl   $0x802420,(%esp)
  8004e3:	e8 0c 1c 00 00       	call   8020f4 <open>
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	79 25                	jns    800511 <umain+0x470>
  8004ec:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004ef:	74 3c                	je     80052d <umain+0x48c>
		panic("open /not-found: %e", r);
  8004f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f5:	c7 44 24 08 31 24 80 	movl   $0x802431,0x8(%esp)
  8004fc:	00 
  8004fd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800504:	00 
  800505:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80050c:	e8 db 02 00 00       	call   8007ec <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800511:	c7 44 24 08 69 25 80 	movl   $0x802569,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  800528:	e8 bf 02 00 00       	call   8007ec <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80052d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800534:	00 
  800535:	c7 04 24 55 24 80 00 	movl   $0x802455,(%esp)
  80053c:	e8 b3 1b 00 00       	call   8020f4 <open>
  800541:	85 c0                	test   %eax,%eax
  800543:	79 20                	jns    800565 <umain+0x4c4>
		panic("open /newmotd: %e", r);
  800545:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800549:	c7 44 24 08 64 24 80 	movl   $0x802464,0x8(%esp)
  800550:	00 
  800551:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800558:	00 
  800559:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  800560:	e8 87 02 00 00       	call   8007ec <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800565:	05 00 00 0d 00       	add    $0xd0000,%eax
  80056a:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80056d:	83 38 66             	cmpl   $0x66,(%eax)
  800570:	75 0c                	jne    80057e <umain+0x4dd>
  800572:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
  800576:	75 06                	jne    80057e <umain+0x4dd>
  800578:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
  80057c:	74 1c                	je     80059a <umain+0x4f9>
		panic("open did not fill struct Fd correctly\n");
  80057e:	c7 44 24 08 40 27 80 	movl   $0x802740,0x8(%esp)
  800585:	00 
  800586:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  80058d:	00 
  80058e:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  800595:	e8 52 02 00 00       	call   8007ec <_panic>
	cprintf("open is good\n");
  80059a:	c7 04 24 7c 24 80 00 	movl   $0x80247c,(%esp)
  8005a1:	e8 ff 02 00 00       	call   8008a5 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8005a6:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005ad:	00 
  8005ae:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  8005b5:	e8 3a 1b 00 00       	call   8020f4 <open>
  8005ba:	89 85 44 fd ff ff    	mov    %eax,-0x2bc(%ebp)
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	79 20                	jns    8005e4 <umain+0x543>
		panic("creat /big: %e", f);
  8005c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c8:	c7 44 24 08 89 25 80 	movl   $0x802589,0x8(%esp)
  8005cf:	00 
  8005d0:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  8005d7:	00 
  8005d8:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8005df:	e8 08 02 00 00       	call   8007ec <_panic>
	memset(buf, 0, sizeof(buf));
  8005e4:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8005eb:	00 
  8005ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8005f3:	00 
  8005f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	e8 74 0b 00 00       	call   801176 <memset>
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800607:	8d b5 4c fd ff ff    	lea    -0x2b4(%ebp),%esi
  80060d:	89 f7                	mov    %esi,%edi
  80060f:	89 1e                	mov    %ebx,(%esi)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800611:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800618:	00 
  800619:	89 74 24 04          	mov    %esi,0x4(%esp)
  80061d:	8b 85 44 fd ff ff    	mov    -0x2bc(%ebp),%eax
  800623:	89 04 24             	mov    %eax,(%esp)
  800626:	e8 0f 15 00 00       	call   801b3a <write>
  80062b:	85 c0                	test   %eax,%eax
  80062d:	79 24                	jns    800653 <umain+0x5b2>
			panic("write /big@%d: %e", i, r);
  80062f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800633:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800637:	c7 44 24 08 98 25 80 	movl   $0x802598,0x8(%esp)
  80063e:	00 
  80063f:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
  800646:	00 
  800647:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80064e:	e8 99 01 00 00       	call   8007ec <_panic>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
	return ipc_recv(NULL, FVA, NULL);
}

void
umain(int argc, char **argv)
  800653:	81 c3 00 02 00 00    	add    $0x200,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  800659:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  80065f:	75 ac                	jne    80060d <umain+0x56c>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800661:	8b 85 44 fd ff ff    	mov    -0x2bc(%ebp),%eax
  800667:	89 04 24             	mov    %eax,(%esp)
  80066a:	e8 bd 16 00 00       	call   801d2c <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80066f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800676:	00 
  800677:	c7 04 24 84 25 80 00 	movl   $0x802584,(%esp)
  80067e:	e8 71 1a 00 00       	call   8020f4 <open>
  800683:	89 c6                	mov    %eax,%esi
  800685:	85 c0                	test   %eax,%eax
  800687:	79 20                	jns    8006a9 <umain+0x608>
		panic("open /big: %e", f);
  800689:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068d:	c7 44 24 08 aa 25 80 	movl   $0x8025aa,0x8(%esp)
  800694:	00 
  800695:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80069c:	00 
  80069d:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8006a4:	e8 43 01 00 00       	call   8007ec <_panic>
  8006a9:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  8006ae:	89 1f                	mov    %ebx,(%edi)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  8006b0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8006b7:	00 
  8006b8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8006be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006c2:	89 34 24             	mov    %esi,(%esp)
  8006c5:	e8 87 15 00 00       	call   801c51 <readn>
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	79 24                	jns    8006f2 <umain+0x651>
			panic("read /big@%d: %e", i, r);
  8006ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d6:	c7 44 24 08 b8 25 80 	movl   $0x8025b8,0x8(%esp)
  8006dd:	00 
  8006de:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  8006e5:	00 
  8006e6:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  8006ed:	e8 fa 00 00 00       	call   8007ec <_panic>
		if (r != sizeof(buf))
  8006f2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006f7:	74 2c                	je     800725 <umain+0x684>
			panic("read /big from %d returned %d < %d bytes",
  8006f9:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  800700:	00 
  800701:	89 44 24 10          	mov    %eax,0x10(%esp)
  800705:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800709:	c7 44 24 08 68 27 80 	movl   $0x802768,0x8(%esp)
  800710:	00 
  800711:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  800718:	00 
  800719:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  800720:	e8 c7 00 00 00       	call   8007ec <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800725:	8b 07                	mov    (%edi),%eax
  800727:	39 d8                	cmp    %ebx,%eax
  800729:	74 24                	je     80074f <umain+0x6ae>
			panic("read /big from %d returned bad data %d",
  80072b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80072f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800733:	c7 44 24 08 94 27 80 	movl   $0x802794,0x8(%esp)
  80073a:	00 
  80073b:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  800742:	00 
  800743:	c7 04 24 45 24 80 00 	movl   $0x802445,(%esp)
  80074a:	e8 9d 00 00 00       	call   8007ec <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80074f:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  800755:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  80075b:	0f 8e 4d ff ff ff    	jle    8006ae <umain+0x60d>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800761:	89 34 24             	mov    %esi,(%esp)
  800764:	e8 c3 15 00 00       	call   801d2c <close>
	cprintf("large file is good\n");
  800769:	c7 04 24 c9 25 80 00 	movl   $0x8025c9,(%esp)
  800770:	e8 30 01 00 00       	call   8008a5 <cprintf>
}
  800775:	81 c4 dc 02 00 00    	add    $0x2dc,%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 18             	sub    $0x18,%esp
  800786:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800789:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800792:	e8 ed 0e 00 00       	call   801684 <sys_getenvid>
  800797:	25 ff 03 00 00       	and    $0x3ff,%eax
  80079c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80079f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007a4:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007a9:	85 f6                	test   %esi,%esi
  8007ab:	7e 07                	jle    8007b4 <libmain+0x34>
		binaryname = argv[0];
  8007ad:	8b 03                	mov    (%ebx),%eax
  8007af:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8007b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b8:	89 34 24             	mov    %esi,(%esp)
  8007bb:	e8 e1 f8 ff ff       	call   8000a1 <umain>

	// exit gracefully
	exit();
  8007c0:	e8 0b 00 00 00       	call   8007d0 <exit>
}
  8007c5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8007c8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8007cb:	89 ec                	mov    %ebp,%esp
  8007cd:	5d                   	pop    %ebp
  8007ce:	c3                   	ret    
	...

008007d0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8007d6:	e8 ce 15 00 00       	call   801da9 <close_all>
	sys_env_destroy(0);
  8007db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007e2:	e8 d8 0e 00 00       	call   8016bf <sys_env_destroy>
}
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    
  8007e9:	00 00                	add    %al,(%eax)
	...

008007ec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	56                   	push   %esi
  8007f0:	53                   	push   %ebx
  8007f1:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8007f4:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8007f7:	8b 1d 04 30 80 00    	mov    0x803004,%ebx
  8007fd:	e8 82 0e 00 00       	call   801684 <sys_getenvid>
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	89 54 24 10          	mov    %edx,0x10(%esp)
  800809:	8b 55 08             	mov    0x8(%ebp),%edx
  80080c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800810:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	c7 04 24 ec 27 80 00 	movl   $0x8027ec,(%esp)
  80081f:	e8 81 00 00 00       	call   8008a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800824:	89 74 24 04          	mov    %esi,0x4(%esp)
  800828:	8b 45 10             	mov    0x10(%ebp),%eax
  80082b:	89 04 24             	mov    %eax,(%esp)
  80082e:	e8 11 00 00 00       	call   800844 <vcprintf>
	cprintf("\n");
  800833:	c7 04 24 e8 24 80 00 	movl   $0x8024e8,(%esp)
  80083a:	e8 66 00 00 00       	call   8008a5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80083f:	cc                   	int3   
  800840:	eb fd                	jmp    80083f <_panic+0x53>
	...

00800844 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80084d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800854:	00 00 00 
	b.cnt = 0;
  800857:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80085e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800861:	8b 45 0c             	mov    0xc(%ebp),%eax
  800864:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800868:	8b 45 08             	mov    0x8(%ebp),%eax
  80086b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800875:	89 44 24 04          	mov    %eax,0x4(%esp)
  800879:	c7 04 24 bf 08 80 00 	movl   $0x8008bf,(%esp)
  800880:	e8 d8 01 00 00       	call   800a5d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800885:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80088b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80088f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800895:	89 04 24             	mov    %eax,(%esp)
  800898:	e8 96 0e 00 00       	call   801733 <sys_cputs>

	return b.cnt;
}
  80089d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8008ab:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8008ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b5:	89 04 24             	mov    %eax,(%esp)
  8008b8:	e8 87 ff ff ff       	call   800844 <vcprintf>
	va_end(ap);

	return cnt;
}
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    

008008bf <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	83 ec 14             	sub    $0x14,%esp
  8008c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8008c9:	8b 03                	mov    (%ebx),%eax
  8008cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ce:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8008d7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8008dc:	75 19                	jne    8008f7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8008de:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8008e5:	00 
  8008e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8008e9:	89 04 24             	mov    %eax,(%esp)
  8008ec:	e8 42 0e 00 00       	call   801733 <sys_cputs>
		b->idx = 0;
  8008f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8008f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8008fb:	83 c4 14             	add    $0x14,%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    
	...

00800910 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	83 ec 4c             	sub    $0x4c,%esp
  800919:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091c:	89 d6                	mov    %edx,%esi
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800924:	8b 55 0c             	mov    0xc(%ebp),%edx
  800927:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80092a:	8b 45 10             	mov    0x10(%ebp),%eax
  80092d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800930:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800933:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800936:	b9 00 00 00 00       	mov    $0x0,%ecx
  80093b:	39 d1                	cmp    %edx,%ecx
  80093d:	72 15                	jb     800954 <printnum+0x44>
  80093f:	77 07                	ja     800948 <printnum+0x38>
  800941:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800944:	39 d0                	cmp    %edx,%eax
  800946:	76 0c                	jbe    800954 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800948:	83 eb 01             	sub    $0x1,%ebx
  80094b:	85 db                	test   %ebx,%ebx
  80094d:	8d 76 00             	lea    0x0(%esi),%esi
  800950:	7f 61                	jg     8009b3 <printnum+0xa3>
  800952:	eb 70                	jmp    8009c4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800954:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800958:	83 eb 01             	sub    $0x1,%ebx
  80095b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80095f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800963:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800967:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80096b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80096e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800971:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800974:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800978:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80097f:	00 
  800980:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800983:	89 04 24             	mov    %eax,(%esp)
  800986:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800989:	89 54 24 04          	mov    %edx,0x4(%esp)
  80098d:	e8 1e 18 00 00       	call   8021b0 <__udivdi3>
  800992:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800995:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800998:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80099c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8009a0:	89 04 24             	mov    %eax,(%esp)
  8009a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009a7:	89 f2                	mov    %esi,%edx
  8009a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8009ac:	e8 5f ff ff ff       	call   800910 <printnum>
  8009b1:	eb 11                	jmp    8009c4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8009b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b7:	89 3c 24             	mov    %edi,(%esp)
  8009ba:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8009bd:	83 eb 01             	sub    $0x1,%ebx
  8009c0:	85 db                	test   %ebx,%ebx
  8009c2:	7f ef                	jg     8009b3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8009c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009c8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009cc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8009da:	00 
  8009db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009de:	89 14 24             	mov    %edx,(%esp)
  8009e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009e4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8009e8:	e8 f3 18 00 00       	call   8022e0 <__umoddi3>
  8009ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f1:	0f be 80 0f 28 80 00 	movsbl 0x80280f(%eax),%eax
  8009f8:	89 04 24             	mov    %eax,(%esp)
  8009fb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8009fe:	83 c4 4c             	add    $0x4c,%esp
  800a01:	5b                   	pop    %ebx
  800a02:	5e                   	pop    %esi
  800a03:	5f                   	pop    %edi
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800a09:	83 fa 01             	cmp    $0x1,%edx
  800a0c:	7e 0e                	jle    800a1c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800a0e:	8b 10                	mov    (%eax),%edx
  800a10:	8d 4a 08             	lea    0x8(%edx),%ecx
  800a13:	89 08                	mov    %ecx,(%eax)
  800a15:	8b 02                	mov    (%edx),%eax
  800a17:	8b 52 04             	mov    0x4(%edx),%edx
  800a1a:	eb 22                	jmp    800a3e <getuint+0x38>
	else if (lflag)
  800a1c:	85 d2                	test   %edx,%edx
  800a1e:	74 10                	je     800a30 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800a20:	8b 10                	mov    (%eax),%edx
  800a22:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a25:	89 08                	mov    %ecx,(%eax)
  800a27:	8b 02                	mov    (%edx),%eax
  800a29:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2e:	eb 0e                	jmp    800a3e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800a30:	8b 10                	mov    (%eax),%edx
  800a32:	8d 4a 04             	lea    0x4(%edx),%ecx
  800a35:	89 08                	mov    %ecx,(%eax)
  800a37:	8b 02                	mov    (%edx),%eax
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800a46:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800a4a:	8b 10                	mov    (%eax),%edx
  800a4c:	3b 50 04             	cmp    0x4(%eax),%edx
  800a4f:	73 0a                	jae    800a5b <sprintputch+0x1b>
		*b->buf++ = ch;
  800a51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a54:	88 0a                	mov    %cl,(%edx)
  800a56:	83 c2 01             	add    $0x1,%edx
  800a59:	89 10                	mov    %edx,(%eax)
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	83 ec 5c             	sub    $0x5c,%esp
  800a66:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a69:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  800a6f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800a76:	eb 11                	jmp    800a89 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	0f 84 68 04 00 00    	je     800ee8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800a80:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a84:	89 04 24             	mov    %eax,(%esp)
  800a87:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a89:	0f b6 03             	movzbl (%ebx),%eax
  800a8c:	83 c3 01             	add    $0x1,%ebx
  800a8f:	83 f8 25             	cmp    $0x25,%eax
  800a92:	75 e4                	jne    800a78 <vprintfmt+0x1b>
  800a94:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  800a9b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800aa7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  800aab:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800ab2:	eb 06                	jmp    800aba <vprintfmt+0x5d>
  800ab4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800ab8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aba:	0f b6 13             	movzbl (%ebx),%edx
  800abd:	0f b6 c2             	movzbl %dl,%eax
  800ac0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ac3:	8d 43 01             	lea    0x1(%ebx),%eax
  800ac6:	83 ea 23             	sub    $0x23,%edx
  800ac9:	80 fa 55             	cmp    $0x55,%dl
  800acc:	0f 87 f9 03 00 00    	ja     800ecb <vprintfmt+0x46e>
  800ad2:	0f b6 d2             	movzbl %dl,%edx
  800ad5:	ff 24 95 e0 29 80 00 	jmp    *0x8029e0(,%edx,4)
  800adc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800ae0:	eb d6                	jmp    800ab8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800ae2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ae5:	83 ea 30             	sub    $0x30,%edx
  800ae8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  800aeb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800aee:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800af1:	83 fb 09             	cmp    $0x9,%ebx
  800af4:	77 54                	ja     800b4a <vprintfmt+0xed>
  800af6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800af9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800afc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  800aff:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800b02:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800b06:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800b09:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800b0c:	83 fb 09             	cmp    $0x9,%ebx
  800b0f:	76 eb                	jbe    800afc <vprintfmt+0x9f>
  800b11:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800b14:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b17:	eb 31                	jmp    800b4a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800b19:	8b 55 14             	mov    0x14(%ebp),%edx
  800b1c:	8d 5a 04             	lea    0x4(%edx),%ebx
  800b1f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800b22:	8b 12                	mov    (%edx),%edx
  800b24:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800b27:	eb 21                	jmp    800b4a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800b29:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800b36:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b39:	e9 7a ff ff ff       	jmp    800ab8 <vprintfmt+0x5b>
  800b3e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800b45:	e9 6e ff ff ff       	jmp    800ab8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  800b4a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b4e:	0f 89 64 ff ff ff    	jns    800ab8 <vprintfmt+0x5b>
  800b54:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800b57:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800b5a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  800b5d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800b60:	e9 53 ff ff ff       	jmp    800ab8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800b65:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800b68:	e9 4b ff ff ff       	jmp    800ab8 <vprintfmt+0x5b>
  800b6d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800b70:	8b 45 14             	mov    0x14(%ebp),%eax
  800b73:	8d 50 04             	lea    0x4(%eax),%edx
  800b76:	89 55 14             	mov    %edx,0x14(%ebp)
  800b79:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b7d:	8b 00                	mov    (%eax),%eax
  800b7f:	89 04 24             	mov    %eax,(%esp)
  800b82:	ff d7                	call   *%edi
  800b84:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800b87:	e9 fd fe ff ff       	jmp    800a89 <vprintfmt+0x2c>
  800b8c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  800b8f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b92:	8d 50 04             	lea    0x4(%eax),%edx
  800b95:	89 55 14             	mov    %edx,0x14(%ebp)
  800b98:	8b 00                	mov    (%eax),%eax
  800b9a:	89 c2                	mov    %eax,%edx
  800b9c:	c1 fa 1f             	sar    $0x1f,%edx
  800b9f:	31 d0                	xor    %edx,%eax
  800ba1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800ba3:	83 f8 0f             	cmp    $0xf,%eax
  800ba6:	7f 0b                	jg     800bb3 <vprintfmt+0x156>
  800ba8:	8b 14 85 40 2b 80 00 	mov    0x802b40(,%eax,4),%edx
  800baf:	85 d2                	test   %edx,%edx
  800bb1:	75 20                	jne    800bd3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800bb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb7:	c7 44 24 08 20 28 80 	movl   $0x802820,0x8(%esp)
  800bbe:	00 
  800bbf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bc3:	89 3c 24             	mov    %edi,(%esp)
  800bc6:	e8 a5 03 00 00       	call   800f70 <printfmt>
  800bcb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800bce:	e9 b6 fe ff ff       	jmp    800a89 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800bd3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800bd7:	c7 44 24 08 97 2c 80 	movl   $0x802c97,0x8(%esp)
  800bde:	00 
  800bdf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be3:	89 3c 24             	mov    %edi,(%esp)
  800be6:	e8 85 03 00 00       	call   800f70 <printfmt>
  800beb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800bee:	e9 96 fe ff ff       	jmp    800a89 <vprintfmt+0x2c>
  800bf3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800bf6:	89 c3                	mov    %eax,%ebx
  800bf8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800bfb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800bfe:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800c01:	8b 45 14             	mov    0x14(%ebp),%eax
  800c04:	8d 50 04             	lea    0x4(%eax),%edx
  800c07:	89 55 14             	mov    %edx,0x14(%ebp)
  800c0a:	8b 00                	mov    (%eax),%eax
  800c0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0f:	85 c0                	test   %eax,%eax
  800c11:	b8 29 28 80 00       	mov    $0x802829,%eax
  800c16:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  800c1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800c1d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800c21:	7e 06                	jle    800c29 <vprintfmt+0x1cc>
  800c23:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800c27:	75 13                	jne    800c3c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800c29:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c2c:	0f be 02             	movsbl (%edx),%eax
  800c2f:	85 c0                	test   %eax,%eax
  800c31:	0f 85 a2 00 00 00    	jne    800cd9 <vprintfmt+0x27c>
  800c37:	e9 8f 00 00 00       	jmp    800ccb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c3c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800c40:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800c43:	89 0c 24             	mov    %ecx,(%esp)
  800c46:	e8 70 03 00 00       	call   800fbb <strnlen>
  800c4b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800c4e:	29 c2                	sub    %eax,%edx
  800c50:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800c53:	85 d2                	test   %edx,%edx
  800c55:	7e d2                	jle    800c29 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800c57:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800c5b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800c5e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800c61:	89 d3                	mov    %edx,%ebx
  800c63:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c67:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800c6a:	89 04 24             	mov    %eax,(%esp)
  800c6d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800c6f:	83 eb 01             	sub    $0x1,%ebx
  800c72:	85 db                	test   %ebx,%ebx
  800c74:	7f ed                	jg     800c63 <vprintfmt+0x206>
  800c76:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800c79:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800c80:	eb a7                	jmp    800c29 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800c82:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800c86:	74 1b                	je     800ca3 <vprintfmt+0x246>
  800c88:	8d 50 e0             	lea    -0x20(%eax),%edx
  800c8b:	83 fa 5e             	cmp    $0x5e,%edx
  800c8e:	76 13                	jbe    800ca3 <vprintfmt+0x246>
					putch('?', putdat);
  800c90:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800c93:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c97:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800c9e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ca1:	eb 0d                	jmp    800cb0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800ca3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ca6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800caa:	89 04 24             	mov    %eax,(%esp)
  800cad:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cb0:	83 ef 01             	sub    $0x1,%edi
  800cb3:	0f be 03             	movsbl (%ebx),%eax
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	74 05                	je     800cbf <vprintfmt+0x262>
  800cba:	83 c3 01             	add    $0x1,%ebx
  800cbd:	eb 31                	jmp    800cf0 <vprintfmt+0x293>
  800cbf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800cc2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cc5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800cc8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ccb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800ccf:	7f 36                	jg     800d07 <vprintfmt+0x2aa>
  800cd1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800cd4:	e9 b0 fd ff ff       	jmp    800a89 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800cd9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cdc:	83 c2 01             	add    $0x1,%edx
  800cdf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800ce2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800ce5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800ce8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800ceb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800cee:	89 d3                	mov    %edx,%ebx
  800cf0:	85 f6                	test   %esi,%esi
  800cf2:	78 8e                	js     800c82 <vprintfmt+0x225>
  800cf4:	83 ee 01             	sub    $0x1,%esi
  800cf7:	79 89                	jns    800c82 <vprintfmt+0x225>
  800cf9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800cfc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cff:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800d02:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800d05:	eb c4                	jmp    800ccb <vprintfmt+0x26e>
  800d07:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800d0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800d0d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d11:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800d18:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800d1a:	83 eb 01             	sub    $0x1,%ebx
  800d1d:	85 db                	test   %ebx,%ebx
  800d1f:	7f ec                	jg     800d0d <vprintfmt+0x2b0>
  800d21:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800d24:	e9 60 fd ff ff       	jmp    800a89 <vprintfmt+0x2c>
  800d29:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800d2c:	83 f9 01             	cmp    $0x1,%ecx
  800d2f:	7e 16                	jle    800d47 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800d31:	8b 45 14             	mov    0x14(%ebp),%eax
  800d34:	8d 50 08             	lea    0x8(%eax),%edx
  800d37:	89 55 14             	mov    %edx,0x14(%ebp)
  800d3a:	8b 10                	mov    (%eax),%edx
  800d3c:	8b 48 04             	mov    0x4(%eax),%ecx
  800d3f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800d42:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d45:	eb 32                	jmp    800d79 <vprintfmt+0x31c>
	else if (lflag)
  800d47:	85 c9                	test   %ecx,%ecx
  800d49:	74 18                	je     800d63 <vprintfmt+0x306>
		return va_arg(*ap, long);
  800d4b:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4e:	8d 50 04             	lea    0x4(%eax),%edx
  800d51:	89 55 14             	mov    %edx,0x14(%ebp)
  800d54:	8b 00                	mov    (%eax),%eax
  800d56:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d59:	89 c1                	mov    %eax,%ecx
  800d5b:	c1 f9 1f             	sar    $0x1f,%ecx
  800d5e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800d61:	eb 16                	jmp    800d79 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800d63:	8b 45 14             	mov    0x14(%ebp),%eax
  800d66:	8d 50 04             	lea    0x4(%eax),%edx
  800d69:	89 55 14             	mov    %edx,0x14(%ebp)
  800d6c:	8b 00                	mov    (%eax),%eax
  800d6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	c1 fa 1f             	sar    $0x1f,%edx
  800d76:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800d79:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800d7f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800d84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800d88:	0f 89 8a 00 00 00    	jns    800e18 <vprintfmt+0x3bb>
				putch('-', putdat);
  800d8e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d92:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800d99:	ff d7                	call   *%edi
				num = -(long long) num;
  800d9b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d9e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800da1:	f7 d8                	neg    %eax
  800da3:	83 d2 00             	adc    $0x0,%edx
  800da6:	f7 da                	neg    %edx
  800da8:	eb 6e                	jmp    800e18 <vprintfmt+0x3bb>
  800daa:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800dad:	89 ca                	mov    %ecx,%edx
  800daf:	8d 45 14             	lea    0x14(%ebp),%eax
  800db2:	e8 4f fc ff ff       	call   800a06 <getuint>
  800db7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800dbc:	eb 5a                	jmp    800e18 <vprintfmt+0x3bb>
  800dbe:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800dc1:	89 ca                	mov    %ecx,%edx
  800dc3:	8d 45 14             	lea    0x14(%ebp),%eax
  800dc6:	e8 3b fc ff ff       	call   800a06 <getuint>
  800dcb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800dd0:	eb 46                	jmp    800e18 <vprintfmt+0x3bb>
  800dd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800dd5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dd9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800de0:	ff d7                	call   *%edi
			putch('x', putdat);
  800de2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800de6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800ded:	ff d7                	call   *%edi
			num = (unsigned long long)
  800def:	8b 45 14             	mov    0x14(%ebp),%eax
  800df2:	8d 50 04             	lea    0x4(%eax),%edx
  800df5:	89 55 14             	mov    %edx,0x14(%ebp)
  800df8:	8b 00                	mov    (%eax),%eax
  800dfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800dff:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800e04:	eb 12                	jmp    800e18 <vprintfmt+0x3bb>
  800e06:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800e09:	89 ca                	mov    %ecx,%edx
  800e0b:	8d 45 14             	lea    0x14(%ebp),%eax
  800e0e:	e8 f3 fb ff ff       	call   800a06 <getuint>
  800e13:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800e18:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800e1c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800e20:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e23:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e27:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e2b:	89 04 24             	mov    %eax,(%esp)
  800e2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e32:	89 f2                	mov    %esi,%edx
  800e34:	89 f8                	mov    %edi,%eax
  800e36:	e8 d5 fa ff ff       	call   800910 <printnum>
  800e3b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800e3e:	e9 46 fc ff ff       	jmp    800a89 <vprintfmt+0x2c>
  800e43:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800e46:	8b 45 14             	mov    0x14(%ebp),%eax
  800e49:	8d 50 04             	lea    0x4(%eax),%edx
  800e4c:	89 55 14             	mov    %edx,0x14(%ebp)
  800e4f:	8b 00                	mov    (%eax),%eax
  800e51:	85 c0                	test   %eax,%eax
  800e53:	75 24                	jne    800e79 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800e55:	c7 44 24 0c 44 29 80 	movl   $0x802944,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 97 2c 80 	movl   $0x802c97,0x8(%esp)
  800e64:	00 
  800e65:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e69:	89 3c 24             	mov    %edi,(%esp)
  800e6c:	e8 ff 00 00 00       	call   800f70 <printfmt>
  800e71:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800e74:	e9 10 fc ff ff       	jmp    800a89 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800e79:	83 3e 7f             	cmpl   $0x7f,(%esi)
  800e7c:	7e 29                	jle    800ea7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  800e7e:	0f b6 16             	movzbl (%esi),%edx
  800e81:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800e83:	c7 44 24 0c 7c 29 80 	movl   $0x80297c,0xc(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 08 97 2c 80 	movl   $0x802c97,0x8(%esp)
  800e92:	00 
  800e93:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e97:	89 3c 24             	mov    %edi,(%esp)
  800e9a:	e8 d1 00 00 00       	call   800f70 <printfmt>
  800e9f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800ea2:	e9 e2 fb ff ff       	jmp    800a89 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800ea7:	0f b6 16             	movzbl (%esi),%edx
  800eaa:	88 10                	mov    %dl,(%eax)
  800eac:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  800eaf:	e9 d5 fb ff ff       	jmp    800a89 <vprintfmt+0x2c>
  800eb4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800eb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800eba:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ebe:	89 14 24             	mov    %edx,(%esp)
  800ec1:	ff d7                	call   *%edi
  800ec3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800ec6:	e9 be fb ff ff       	jmp    800a89 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ecb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ecf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ed6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ed8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800edb:	80 38 25             	cmpb   $0x25,(%eax)
  800ede:	0f 84 a5 fb ff ff    	je     800a89 <vprintfmt+0x2c>
  800ee4:	89 c3                	mov    %eax,%ebx
  800ee6:	eb f0                	jmp    800ed8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800ee8:	83 c4 5c             	add    $0x5c,%esp
  800eeb:	5b                   	pop    %ebx
  800eec:	5e                   	pop    %esi
  800eed:	5f                   	pop    %edi
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 28             	sub    $0x28,%esp
  800ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800efc:	85 c0                	test   %eax,%eax
  800efe:	74 04                	je     800f04 <vsnprintf+0x14>
  800f00:	85 d2                	test   %edx,%edx
  800f02:	7f 07                	jg     800f0b <vsnprintf+0x1b>
  800f04:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f09:	eb 3b                	jmp    800f46 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800f0b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800f0e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800f12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800f15:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f23:	8b 45 10             	mov    0x10(%ebp),%eax
  800f26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f2a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f31:	c7 04 24 40 0a 80 00 	movl   $0x800a40,(%esp)
  800f38:	e8 20 fb ff ff       	call   800a5d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800f3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f40:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800f46:	c9                   	leave  
  800f47:	c3                   	ret    

00800f48 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800f4e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800f51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f55:	8b 45 10             	mov    0x10(%ebp),%eax
  800f58:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f63:	8b 45 08             	mov    0x8(%ebp),%eax
  800f66:	89 04 24             	mov    %eax,(%esp)
  800f69:	e8 82 ff ff ff       	call   800ef0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800f76:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800f79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	89 04 24             	mov    %eax,(%esp)
  800f91:	e8 c7 fa ff ff       	call   800a5d <vprintfmt>
	va_end(ap);
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    
	...

00800fa0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fab:	80 3a 00             	cmpb   $0x0,(%edx)
  800fae:	74 09                	je     800fb9 <strlen+0x19>
		n++;
  800fb0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800fb3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800fb7:	75 f7                	jne    800fb0 <strlen+0x10>
		n++;
	return n;
}
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	53                   	push   %ebx
  800fbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800fc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fc5:	85 c9                	test   %ecx,%ecx
  800fc7:	74 19                	je     800fe2 <strnlen+0x27>
  800fc9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800fcc:	74 14                	je     800fe2 <strnlen+0x27>
  800fce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800fd3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800fd6:	39 c8                	cmp    %ecx,%eax
  800fd8:	74 0d                	je     800fe7 <strnlen+0x2c>
  800fda:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800fde:	75 f3                	jne    800fd3 <strnlen+0x18>
  800fe0:	eb 05                	jmp    800fe7 <strnlen+0x2c>
  800fe2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800fe7:	5b                   	pop    %ebx
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    

00800fea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800fea:	55                   	push   %ebp
  800feb:	89 e5                	mov    %esp,%ebp
  800fed:	53                   	push   %ebx
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ff4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800ff9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800ffd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801000:	83 c2 01             	add    $0x1,%edx
  801003:	84 c9                	test   %cl,%cl
  801005:	75 f2                	jne    800ff9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801007:	5b                   	pop    %ebx
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    

0080100a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80100a:	55                   	push   %ebp
  80100b:	89 e5                	mov    %esp,%ebp
  80100d:	53                   	push   %ebx
  80100e:	83 ec 08             	sub    $0x8,%esp
  801011:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801014:	89 1c 24             	mov    %ebx,(%esp)
  801017:	e8 84 ff ff ff       	call   800fa0 <strlen>
	strcpy(dst + len, src);
  80101c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80101f:	89 54 24 04          	mov    %edx,0x4(%esp)
  801023:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  801026:	89 04 24             	mov    %eax,(%esp)
  801029:	e8 bc ff ff ff       	call   800fea <strcpy>
	return dst;
}
  80102e:	89 d8                	mov    %ebx,%eax
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	5b                   	pop    %ebx
  801034:	5d                   	pop    %ebp
  801035:	c3                   	ret    

00801036 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	8b 45 08             	mov    0x8(%ebp),%eax
  80103e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801041:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801044:	85 f6                	test   %esi,%esi
  801046:	74 18                	je     801060 <strncpy+0x2a>
  801048:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80104d:	0f b6 1a             	movzbl (%edx),%ebx
  801050:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801053:	80 3a 01             	cmpb   $0x1,(%edx)
  801056:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801059:	83 c1 01             	add    $0x1,%ecx
  80105c:	39 ce                	cmp    %ecx,%esi
  80105e:	77 ed                	ja     80104d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801060:	5b                   	pop    %ebx
  801061:	5e                   	pop    %esi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	56                   	push   %esi
  801068:	53                   	push   %ebx
  801069:	8b 75 08             	mov    0x8(%ebp),%esi
  80106c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80106f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801072:	89 f0                	mov    %esi,%eax
  801074:	85 c9                	test   %ecx,%ecx
  801076:	74 27                	je     80109f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  801078:	83 e9 01             	sub    $0x1,%ecx
  80107b:	74 1d                	je     80109a <strlcpy+0x36>
  80107d:	0f b6 1a             	movzbl (%edx),%ebx
  801080:	84 db                	test   %bl,%bl
  801082:	74 16                	je     80109a <strlcpy+0x36>
			*dst++ = *src++;
  801084:	88 18                	mov    %bl,(%eax)
  801086:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801089:	83 e9 01             	sub    $0x1,%ecx
  80108c:	74 0e                	je     80109c <strlcpy+0x38>
			*dst++ = *src++;
  80108e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801091:	0f b6 1a             	movzbl (%edx),%ebx
  801094:	84 db                	test   %bl,%bl
  801096:	75 ec                	jne    801084 <strlcpy+0x20>
  801098:	eb 02                	jmp    80109c <strlcpy+0x38>
  80109a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80109c:	c6 00 00             	movb   $0x0,(%eax)
  80109f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8010a1:	5b                   	pop    %ebx
  8010a2:	5e                   	pop    %esi
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8010ae:	0f b6 01             	movzbl (%ecx),%eax
  8010b1:	84 c0                	test   %al,%al
  8010b3:	74 15                	je     8010ca <strcmp+0x25>
  8010b5:	3a 02                	cmp    (%edx),%al
  8010b7:	75 11                	jne    8010ca <strcmp+0x25>
		p++, q++;
  8010b9:	83 c1 01             	add    $0x1,%ecx
  8010bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8010bf:	0f b6 01             	movzbl (%ecx),%eax
  8010c2:	84 c0                	test   %al,%al
  8010c4:	74 04                	je     8010ca <strcmp+0x25>
  8010c6:	3a 02                	cmp    (%edx),%al
  8010c8:	74 ef                	je     8010b9 <strcmp+0x14>
  8010ca:	0f b6 c0             	movzbl %al,%eax
  8010cd:	0f b6 12             	movzbl (%edx),%edx
  8010d0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8010d2:	5d                   	pop    %ebp
  8010d3:	c3                   	ret    

008010d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8010d4:	55                   	push   %ebp
  8010d5:	89 e5                	mov    %esp,%ebp
  8010d7:	53                   	push   %ebx
  8010d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8010db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010de:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	74 23                	je     801108 <strncmp+0x34>
  8010e5:	0f b6 1a             	movzbl (%edx),%ebx
  8010e8:	84 db                	test   %bl,%bl
  8010ea:	74 25                	je     801111 <strncmp+0x3d>
  8010ec:	3a 19                	cmp    (%ecx),%bl
  8010ee:	75 21                	jne    801111 <strncmp+0x3d>
  8010f0:	83 e8 01             	sub    $0x1,%eax
  8010f3:	74 13                	je     801108 <strncmp+0x34>
		n--, p++, q++;
  8010f5:	83 c2 01             	add    $0x1,%edx
  8010f8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8010fb:	0f b6 1a             	movzbl (%edx),%ebx
  8010fe:	84 db                	test   %bl,%bl
  801100:	74 0f                	je     801111 <strncmp+0x3d>
  801102:	3a 19                	cmp    (%ecx),%bl
  801104:	74 ea                	je     8010f0 <strncmp+0x1c>
  801106:	eb 09                	jmp    801111 <strncmp+0x3d>
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80110d:	5b                   	pop    %ebx
  80110e:	5d                   	pop    %ebp
  80110f:	90                   	nop
  801110:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801111:	0f b6 02             	movzbl (%edx),%eax
  801114:	0f b6 11             	movzbl (%ecx),%edx
  801117:	29 d0                	sub    %edx,%eax
  801119:	eb f2                	jmp    80110d <strncmp+0x39>

0080111b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	8b 45 08             	mov    0x8(%ebp),%eax
  801121:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801125:	0f b6 10             	movzbl (%eax),%edx
  801128:	84 d2                	test   %dl,%dl
  80112a:	74 18                	je     801144 <strchr+0x29>
		if (*s == c)
  80112c:	38 ca                	cmp    %cl,%dl
  80112e:	75 0a                	jne    80113a <strchr+0x1f>
  801130:	eb 17                	jmp    801149 <strchr+0x2e>
  801132:	38 ca                	cmp    %cl,%dl
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	74 0f                	je     801149 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80113a:	83 c0 01             	add    $0x1,%eax
  80113d:	0f b6 10             	movzbl (%eax),%edx
  801140:	84 d2                	test   %dl,%dl
  801142:	75 ee                	jne    801132 <strchr+0x17>
  801144:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  801149:	5d                   	pop    %ebp
  80114a:	c3                   	ret    

0080114b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	8b 45 08             	mov    0x8(%ebp),%eax
  801151:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801155:	0f b6 10             	movzbl (%eax),%edx
  801158:	84 d2                	test   %dl,%dl
  80115a:	74 18                	je     801174 <strfind+0x29>
		if (*s == c)
  80115c:	38 ca                	cmp    %cl,%dl
  80115e:	75 0a                	jne    80116a <strfind+0x1f>
  801160:	eb 12                	jmp    801174 <strfind+0x29>
  801162:	38 ca                	cmp    %cl,%dl
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	74 0a                	je     801174 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80116a:	83 c0 01             	add    $0x1,%eax
  80116d:	0f b6 10             	movzbl (%eax),%edx
  801170:	84 d2                	test   %dl,%dl
  801172:	75 ee                	jne    801162 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  801174:	5d                   	pop    %ebp
  801175:	c3                   	ret    

00801176 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	89 1c 24             	mov    %ebx,(%esp)
  80117f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801183:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801187:	8b 7d 08             	mov    0x8(%ebp),%edi
  80118a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801190:	85 c9                	test   %ecx,%ecx
  801192:	74 30                	je     8011c4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801194:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80119a:	75 25                	jne    8011c1 <memset+0x4b>
  80119c:	f6 c1 03             	test   $0x3,%cl
  80119f:	75 20                	jne    8011c1 <memset+0x4b>
		c &= 0xFF;
  8011a1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011a4:	89 d3                	mov    %edx,%ebx
  8011a6:	c1 e3 08             	shl    $0x8,%ebx
  8011a9:	89 d6                	mov    %edx,%esi
  8011ab:	c1 e6 18             	shl    $0x18,%esi
  8011ae:	89 d0                	mov    %edx,%eax
  8011b0:	c1 e0 10             	shl    $0x10,%eax
  8011b3:	09 f0                	or     %esi,%eax
  8011b5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8011b7:	09 d8                	or     %ebx,%eax
  8011b9:	c1 e9 02             	shr    $0x2,%ecx
  8011bc:	fc                   	cld    
  8011bd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011bf:	eb 03                	jmp    8011c4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011c1:	fc                   	cld    
  8011c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011c4:	89 f8                	mov    %edi,%eax
  8011c6:	8b 1c 24             	mov    (%esp),%ebx
  8011c9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011cd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011d1:	89 ec                	mov    %ebp,%esp
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	89 34 24             	mov    %esi,(%esp)
  8011de:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  8011e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  8011eb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  8011ed:	39 c6                	cmp    %eax,%esi
  8011ef:	73 35                	jae    801226 <memmove+0x51>
  8011f1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8011f4:	39 d0                	cmp    %edx,%eax
  8011f6:	73 2e                	jae    801226 <memmove+0x51>
		s += n;
		d += n;
  8011f8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8011fa:	f6 c2 03             	test   $0x3,%dl
  8011fd:	75 1b                	jne    80121a <memmove+0x45>
  8011ff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801205:	75 13                	jne    80121a <memmove+0x45>
  801207:	f6 c1 03             	test   $0x3,%cl
  80120a:	75 0e                	jne    80121a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80120c:	83 ef 04             	sub    $0x4,%edi
  80120f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801212:	c1 e9 02             	shr    $0x2,%ecx
  801215:	fd                   	std    
  801216:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801218:	eb 09                	jmp    801223 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80121a:	83 ef 01             	sub    $0x1,%edi
  80121d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801220:	fd                   	std    
  801221:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801223:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801224:	eb 20                	jmp    801246 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801226:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80122c:	75 15                	jne    801243 <memmove+0x6e>
  80122e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801234:	75 0d                	jne    801243 <memmove+0x6e>
  801236:	f6 c1 03             	test   $0x3,%cl
  801239:	75 08                	jne    801243 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80123b:	c1 e9 02             	shr    $0x2,%ecx
  80123e:	fc                   	cld    
  80123f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801241:	eb 03                	jmp    801246 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801243:	fc                   	cld    
  801244:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801246:	8b 34 24             	mov    (%esp),%esi
  801249:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80124d:	89 ec                	mov    %ebp,%esp
  80124f:	5d                   	pop    %ebp
  801250:	c3                   	ret    

00801251 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801257:	8b 45 10             	mov    0x10(%ebp),%eax
  80125a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80125e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801261:	89 44 24 04          	mov    %eax,0x4(%esp)
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	89 04 24             	mov    %eax,(%esp)
  80126b:	e8 65 ff ff ff       	call   8011d5 <memmove>
}
  801270:	c9                   	leave  
  801271:	c3                   	ret    

00801272 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	57                   	push   %edi
  801276:	56                   	push   %esi
  801277:	53                   	push   %ebx
  801278:	8b 75 08             	mov    0x8(%ebp),%esi
  80127b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80127e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801281:	85 c9                	test   %ecx,%ecx
  801283:	74 36                	je     8012bb <memcmp+0x49>
		if (*s1 != *s2)
  801285:	0f b6 06             	movzbl (%esi),%eax
  801288:	0f b6 1f             	movzbl (%edi),%ebx
  80128b:	38 d8                	cmp    %bl,%al
  80128d:	74 20                	je     8012af <memcmp+0x3d>
  80128f:	eb 14                	jmp    8012a5 <memcmp+0x33>
  801291:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801296:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80129b:	83 c2 01             	add    $0x1,%edx
  80129e:	83 e9 01             	sub    $0x1,%ecx
  8012a1:	38 d8                	cmp    %bl,%al
  8012a3:	74 12                	je     8012b7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8012a5:	0f b6 c0             	movzbl %al,%eax
  8012a8:	0f b6 db             	movzbl %bl,%ebx
  8012ab:	29 d8                	sub    %ebx,%eax
  8012ad:	eb 11                	jmp    8012c0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012af:	83 e9 01             	sub    $0x1,%ecx
  8012b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b7:	85 c9                	test   %ecx,%ecx
  8012b9:	75 d6                	jne    801291 <memcmp+0x1f>
  8012bb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8012cb:	89 c2                	mov    %eax,%edx
  8012cd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012d0:	39 d0                	cmp    %edx,%eax
  8012d2:	73 15                	jae    8012e9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8012d8:	38 08                	cmp    %cl,(%eax)
  8012da:	75 06                	jne    8012e2 <memfind+0x1d>
  8012dc:	eb 0b                	jmp    8012e9 <memfind+0x24>
  8012de:	38 08                	cmp    %cl,(%eax)
  8012e0:	74 07                	je     8012e9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012e2:	83 c0 01             	add    $0x1,%eax
  8012e5:	39 c2                	cmp    %eax,%edx
  8012e7:	77 f5                	ja     8012de <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012e9:	5d                   	pop    %ebp
  8012ea:	c3                   	ret    

008012eb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	57                   	push   %edi
  8012ef:	56                   	push   %esi
  8012f0:	53                   	push   %ebx
  8012f1:	83 ec 04             	sub    $0x4,%esp
  8012f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8012f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012fa:	0f b6 02             	movzbl (%edx),%eax
  8012fd:	3c 20                	cmp    $0x20,%al
  8012ff:	74 04                	je     801305 <strtol+0x1a>
  801301:	3c 09                	cmp    $0x9,%al
  801303:	75 0e                	jne    801313 <strtol+0x28>
		s++;
  801305:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801308:	0f b6 02             	movzbl (%edx),%eax
  80130b:	3c 20                	cmp    $0x20,%al
  80130d:	74 f6                	je     801305 <strtol+0x1a>
  80130f:	3c 09                	cmp    $0x9,%al
  801311:	74 f2                	je     801305 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801313:	3c 2b                	cmp    $0x2b,%al
  801315:	75 0c                	jne    801323 <strtol+0x38>
		s++;
  801317:	83 c2 01             	add    $0x1,%edx
  80131a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801321:	eb 15                	jmp    801338 <strtol+0x4d>
	else if (*s == '-')
  801323:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80132a:	3c 2d                	cmp    $0x2d,%al
  80132c:	75 0a                	jne    801338 <strtol+0x4d>
		s++, neg = 1;
  80132e:	83 c2 01             	add    $0x1,%edx
  801331:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801338:	85 db                	test   %ebx,%ebx
  80133a:	0f 94 c0             	sete   %al
  80133d:	74 05                	je     801344 <strtol+0x59>
  80133f:	83 fb 10             	cmp    $0x10,%ebx
  801342:	75 18                	jne    80135c <strtol+0x71>
  801344:	80 3a 30             	cmpb   $0x30,(%edx)
  801347:	75 13                	jne    80135c <strtol+0x71>
  801349:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80134d:	8d 76 00             	lea    0x0(%esi),%esi
  801350:	75 0a                	jne    80135c <strtol+0x71>
		s += 2, base = 16;
  801352:	83 c2 02             	add    $0x2,%edx
  801355:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80135a:	eb 15                	jmp    801371 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80135c:	84 c0                	test   %al,%al
  80135e:	66 90                	xchg   %ax,%ax
  801360:	74 0f                	je     801371 <strtol+0x86>
  801362:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801367:	80 3a 30             	cmpb   $0x30,(%edx)
  80136a:	75 05                	jne    801371 <strtol+0x86>
		s++, base = 8;
  80136c:	83 c2 01             	add    $0x1,%edx
  80136f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801371:	b8 00 00 00 00       	mov    $0x0,%eax
  801376:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801378:	0f b6 0a             	movzbl (%edx),%ecx
  80137b:	89 cf                	mov    %ecx,%edi
  80137d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801380:	80 fb 09             	cmp    $0x9,%bl
  801383:	77 08                	ja     80138d <strtol+0xa2>
			dig = *s - '0';
  801385:	0f be c9             	movsbl %cl,%ecx
  801388:	83 e9 30             	sub    $0x30,%ecx
  80138b:	eb 1e                	jmp    8013ab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80138d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801390:	80 fb 19             	cmp    $0x19,%bl
  801393:	77 08                	ja     80139d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801395:	0f be c9             	movsbl %cl,%ecx
  801398:	83 e9 57             	sub    $0x57,%ecx
  80139b:	eb 0e                	jmp    8013ab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80139d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8013a0:	80 fb 19             	cmp    $0x19,%bl
  8013a3:	77 15                	ja     8013ba <strtol+0xcf>
			dig = *s - 'A' + 10;
  8013a5:	0f be c9             	movsbl %cl,%ecx
  8013a8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8013ab:	39 f1                	cmp    %esi,%ecx
  8013ad:	7d 0b                	jge    8013ba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8013af:	83 c2 01             	add    $0x1,%edx
  8013b2:	0f af c6             	imul   %esi,%eax
  8013b5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8013b8:	eb be                	jmp    801378 <strtol+0x8d>
  8013ba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8013bc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013c0:	74 05                	je     8013c7 <strtol+0xdc>
		*endptr = (char *) s;
  8013c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013c5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8013c7:	89 ca                	mov    %ecx,%edx
  8013c9:	f7 da                	neg    %edx
  8013cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8013cf:	0f 45 c2             	cmovne %edx,%eax
}
  8013d2:	83 c4 04             	add    $0x4,%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    
	...

008013dc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 48             	sub    $0x48,%esp
  8013e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8013eb:	89 c6                	mov    %eax,%esi
  8013ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8013f0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  8013f2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8013f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8013f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013fb:	51                   	push   %ecx
  8013fc:	52                   	push   %edx
  8013fd:	53                   	push   %ebx
  8013fe:	54                   	push   %esp
  8013ff:	55                   	push   %ebp
  801400:	56                   	push   %esi
  801401:	57                   	push   %edi
  801402:	89 e5                	mov    %esp,%ebp
  801404:	8d 35 0c 14 80 00    	lea    0x80140c,%esi
  80140a:	0f 34                	sysenter 

0080140c <.after_sysenter_label>:
  80140c:	5f                   	pop    %edi
  80140d:	5e                   	pop    %esi
  80140e:	5d                   	pop    %ebp
  80140f:	5c                   	pop    %esp
  801410:	5b                   	pop    %ebx
  801411:	5a                   	pop    %edx
  801412:	59                   	pop    %ecx
  801413:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801415:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801419:	74 28                	je     801443 <.after_sysenter_label+0x37>
  80141b:	85 c0                	test   %eax,%eax
  80141d:	7e 24                	jle    801443 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  80141f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801423:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801427:	c7 44 24 08 80 2b 80 	movl   $0x802b80,0x8(%esp)
  80142e:	00 
  80142f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801436:	00 
  801437:	c7 04 24 9d 2b 80 00 	movl   $0x802b9d,(%esp)
  80143e:	e8 a9 f3 ff ff       	call   8007ec <_panic>

	return ret;
}
  801443:	89 d0                	mov    %edx,%eax
  801445:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801448:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80144b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80144e:	89 ec                	mov    %ebp,%esp
  801450:	5d                   	pop    %ebp
  801451:	c3                   	ret    

00801452 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801458:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80145f:	00 
  801460:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801467:	00 
  801468:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80146f:	00 
  801470:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801477:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147a:	ba 01 00 00 00       	mov    $0x1,%edx
  80147f:	b8 0e 00 00 00       	mov    $0xe,%eax
  801484:	e8 53 ff ff ff       	call   8013dc <syscall>
}
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801491:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801498:	00 
  801499:	8b 45 14             	mov    0x14(%ebp),%eax
  80149c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8014a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014aa:	89 04 24             	mov    %eax,(%esp)
  8014ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b5:	b8 0d 00 00 00       	mov    $0xd,%eax
  8014ba:	e8 1d ff ff ff       	call   8013dc <syscall>
}
  8014bf:	c9                   	leave  
  8014c0:	c3                   	ret    

008014c1 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8014c7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014ce:	00 
  8014cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014d6:	00 
  8014d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014de:	00 
  8014df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e2:	89 04 24             	mov    %eax,(%esp)
  8014e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e8:	ba 01 00 00 00       	mov    $0x1,%edx
  8014ed:	b8 0b 00 00 00       	mov    $0xb,%eax
  8014f2:	e8 e5 fe ff ff       	call   8013dc <syscall>
}
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8014ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801506:	00 
  801507:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80150e:	00 
  80150f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801516:	00 
  801517:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151a:	89 04 24             	mov    %eax,(%esp)
  80151d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801520:	ba 01 00 00 00       	mov    $0x1,%edx
  801525:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152a:	e8 ad fe ff ff       	call   8013dc <syscall>
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801537:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80153e:	00 
  80153f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801546:	00 
  801547:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80154e:	00 
  80154f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801552:	89 04 24             	mov    %eax,(%esp)
  801555:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801558:	ba 01 00 00 00       	mov    $0x1,%edx
  80155d:	b8 09 00 00 00       	mov    $0x9,%eax
  801562:	e8 75 fe ff ff       	call   8013dc <syscall>
}
  801567:	c9                   	leave  
  801568:	c3                   	ret    

00801569 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801569:	55                   	push   %ebp
  80156a:	89 e5                	mov    %esp,%ebp
  80156c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80156f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801576:	00 
  801577:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80157e:	00 
  80157f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801586:	00 
  801587:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158a:	89 04 24             	mov    %eax,(%esp)
  80158d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801590:	ba 01 00 00 00       	mov    $0x1,%edx
  801595:	b8 07 00 00 00       	mov    $0x7,%eax
  80159a:	e8 3d fe ff ff       	call   8013dc <syscall>
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  8015a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015ae:	00 
  8015af:	8b 45 18             	mov    0x18(%ebp),%eax
  8015b2:	0b 45 14             	or     0x14(%ebp),%eax
  8015b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8015bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c3:	89 04 24             	mov    %eax,(%esp)
  8015c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015c9:	ba 01 00 00 00       	mov    $0x1,%edx
  8015ce:	b8 06 00 00 00       	mov    $0x6,%eax
  8015d3:	e8 04 fe ff ff       	call   8013dc <syscall>
}
  8015d8:	c9                   	leave  
  8015d9:	c3                   	ret    

008015da <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8015da:	55                   	push   %ebp
  8015db:	89 e5                	mov    %esp,%ebp
  8015dd:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8015e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015e7:	00 
  8015e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015ef:	00 
  8015f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fa:	89 04 24             	mov    %eax,(%esp)
  8015fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801600:	ba 01 00 00 00       	mov    $0x1,%edx
  801605:	b8 05 00 00 00       	mov    $0x5,%eax
  80160a:	e8 cd fd ff ff       	call   8013dc <syscall>
}
  80160f:	c9                   	leave  
  801610:	c3                   	ret    

00801611 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  801617:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80161e:	00 
  80161f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801626:	00 
  801627:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80162e:	00 
  80162f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80163b:	ba 00 00 00 00       	mov    $0x0,%edx
  801640:	b8 0c 00 00 00       	mov    $0xc,%eax
  801645:	e8 92 fd ff ff       	call   8013dc <syscall>
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801652:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801659:	00 
  80165a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801661:	00 
  801662:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801669:	00 
  80166a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801673:	ba 00 00 00 00       	mov    $0x0,%edx
  801678:	b8 04 00 00 00       	mov    $0x4,%eax
  80167d:	e8 5a fd ff ff       	call   8013dc <syscall>
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80168a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801691:	00 
  801692:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801699:	00 
  80169a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016a1:	00 
  8016a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b8:	e8 1f fd ff ff       	call   8013dc <syscall>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8016c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016cc:	00 
  8016cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016d4:	00 
  8016d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016dc:	00 
  8016dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e7:	ba 01 00 00 00       	mov    $0x1,%edx
  8016ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8016f1:	e8 e6 fc ff ff       	call   8013dc <syscall>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8016fe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801705:	00 
  801706:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170d:	00 
  80170e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801715:	00 
  801716:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801722:	ba 00 00 00 00       	mov    $0x0,%edx
  801727:	b8 01 00 00 00       	mov    $0x1,%eax
  80172c:	e8 ab fc ff ff       	call   8013dc <syscall>
}
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801739:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801740:	00 
  801741:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801748:	00 
  801749:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801750:	00 
  801751:	8b 45 0c             	mov    0xc(%ebp),%eax
  801754:	89 04 24             	mov    %eax,(%esp)
  801757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175a:	ba 00 00 00 00       	mov    $0x0,%edx
  80175f:	b8 00 00 00 00       	mov    $0x0,%eax
  801764:	e8 73 fc ff ff       	call   8013dc <syscall>
}
  801769:	c9                   	leave  
  80176a:	c3                   	ret    
  80176b:	00 00                	add    %al,(%eax)
  80176d:	00 00                	add    %al,(%eax)
	...

00801770 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801776:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80177c:	b8 01 00 00 00       	mov    $0x1,%eax
  801781:	39 ca                	cmp    %ecx,%edx
  801783:	75 04                	jne    801789 <ipc_find_env+0x19>
  801785:	b0 00                	mov    $0x0,%al
  801787:	eb 0f                	jmp    801798 <ipc_find_env+0x28>
  801789:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80178c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801792:	8b 12                	mov    (%edx),%edx
  801794:	39 ca                	cmp    %ecx,%edx
  801796:	75 0c                	jne    8017a4 <ipc_find_env+0x34>
			return envs[i].env_id;
  801798:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80179b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8017a0:	8b 00                	mov    (%eax),%eax
  8017a2:	eb 0e                	jmp    8017b2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8017a4:	83 c0 01             	add    $0x1,%eax
  8017a7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8017ac:	75 db                	jne    801789 <ipc_find_env+0x19>
  8017ae:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	57                   	push   %edi
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 1c             	sub    $0x1c,%esp
  8017bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8017c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8017c6:	85 db                	test   %ebx,%ebx
  8017c8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8017cd:	0f 44 d8             	cmove  %eax,%ebx
  8017d0:	eb 29                	jmp    8017fb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  8017d2:	85 c0                	test   %eax,%eax
  8017d4:	79 25                	jns    8017fb <ipc_send+0x47>
  8017d6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8017d9:	74 20                	je     8017fb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  8017db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017df:	c7 44 24 08 ab 2b 80 	movl   $0x802bab,0x8(%esp)
  8017e6:	00 
  8017e7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8017ee:	00 
  8017ef:	c7 04 24 c9 2b 80 00 	movl   $0x802bc9,(%esp)
  8017f6:	e8 f1 ef ff ff       	call   8007ec <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8017fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801802:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801806:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80180a:	89 34 24             	mov    %esi,(%esp)
  80180d:	e8 79 fc ff ff       	call   80148b <sys_ipc_try_send>
  801812:	85 c0                	test   %eax,%eax
  801814:	75 bc                	jne    8017d2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801816:	e8 f6 fd ff ff       	call   801611 <sys_yield>
}
  80181b:	83 c4 1c             	add    $0x1c,%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	5f                   	pop    %edi
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 28             	sub    $0x28,%esp
  801829:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80182c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80182f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801832:	8b 75 08             	mov    0x8(%ebp),%esi
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80183b:	85 c0                	test   %eax,%eax
  80183d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801842:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801845:	89 04 24             	mov    %eax,(%esp)
  801848:	e8 05 fc ff ff       	call   801452 <sys_ipc_recv>
  80184d:	89 c3                	mov    %eax,%ebx
  80184f:	85 c0                	test   %eax,%eax
  801851:	79 2a                	jns    80187d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801853:	89 44 24 08          	mov    %eax,0x8(%esp)
  801857:	89 44 24 04          	mov    %eax,0x4(%esp)
  80185b:	c7 04 24 d3 2b 80 00 	movl   $0x802bd3,(%esp)
  801862:	e8 3e f0 ff ff       	call   8008a5 <cprintf>
		if(from_env_store != NULL)
  801867:	85 f6                	test   %esi,%esi
  801869:	74 06                	je     801871 <ipc_recv+0x4e>
			*from_env_store = 0;
  80186b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801871:	85 ff                	test   %edi,%edi
  801873:	74 2d                	je     8018a2 <ipc_recv+0x7f>
			*perm_store = 0;
  801875:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80187b:	eb 25                	jmp    8018a2 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  80187d:	85 f6                	test   %esi,%esi
  80187f:	90                   	nop
  801880:	74 0a                	je     80188c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801882:	a1 04 40 80 00       	mov    0x804004,%eax
  801887:	8b 40 74             	mov    0x74(%eax),%eax
  80188a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80188c:	85 ff                	test   %edi,%edi
  80188e:	74 0a                	je     80189a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801890:	a1 04 40 80 00       	mov    0x804004,%eax
  801895:	8b 40 78             	mov    0x78(%eax),%eax
  801898:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80189a:	a1 04 40 80 00       	mov    0x804004,%eax
  80189f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8018a2:	89 d8                	mov    %ebx,%eax
  8018a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8018a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8018aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8018ad:	89 ec                	mov    %ebp,%esp
  8018af:	5d                   	pop    %ebp
  8018b0:	c3                   	ret    
	...

008018c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8018cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	89 04 24             	mov    %eax,(%esp)
  8018dc:	e8 df ff ff ff       	call   8018c0 <fd2num>
  8018e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8018e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	57                   	push   %edi
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8018f4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8018f9:	a8 01                	test   $0x1,%al
  8018fb:	74 36                	je     801933 <fd_alloc+0x48>
  8018fd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801902:	a8 01                	test   $0x1,%al
  801904:	74 2d                	je     801933 <fd_alloc+0x48>
  801906:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80190b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801910:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801915:	89 c3                	mov    %eax,%ebx
  801917:	89 c2                	mov    %eax,%edx
  801919:	c1 ea 16             	shr    $0x16,%edx
  80191c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80191f:	f6 c2 01             	test   $0x1,%dl
  801922:	74 14                	je     801938 <fd_alloc+0x4d>
  801924:	89 c2                	mov    %eax,%edx
  801926:	c1 ea 0c             	shr    $0xc,%edx
  801929:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80192c:	f6 c2 01             	test   $0x1,%dl
  80192f:	75 10                	jne    801941 <fd_alloc+0x56>
  801931:	eb 05                	jmp    801938 <fd_alloc+0x4d>
  801933:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801938:	89 1f                	mov    %ebx,(%edi)
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80193f:	eb 17                	jmp    801958 <fd_alloc+0x6d>
  801941:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801946:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80194b:	75 c8                	jne    801915 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80194d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801953:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5f                   	pop    %edi
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    

0080195d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
  801963:	83 f8 1f             	cmp    $0x1f,%eax
  801966:	77 36                	ja     80199e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801968:	05 00 00 0d 00       	add    $0xd0000,%eax
  80196d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801970:	89 c2                	mov    %eax,%edx
  801972:	c1 ea 16             	shr    $0x16,%edx
  801975:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80197c:	f6 c2 01             	test   $0x1,%dl
  80197f:	74 1d                	je     80199e <fd_lookup+0x41>
  801981:	89 c2                	mov    %eax,%edx
  801983:	c1 ea 0c             	shr    $0xc,%edx
  801986:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80198d:	f6 c2 01             	test   $0x1,%dl
  801990:	74 0c                	je     80199e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801992:	8b 55 0c             	mov    0xc(%ebp),%edx
  801995:	89 02                	mov    %eax,(%edx)
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80199c:	eb 05                	jmp    8019a3 <fd_lookup+0x46>
  80199e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8019ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b5:	89 04 24             	mov    %eax,(%esp)
  8019b8:	e8 a0 ff ff ff       	call   80195d <fd_lookup>
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 0e                	js     8019cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8019c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8019c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c7:	89 50 04             	mov    %edx,0x4(%eax)
  8019ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8019cf:	c9                   	leave  
  8019d0:	c3                   	ret    

008019d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	83 ec 10             	sub    $0x10,%esp
  8019d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8019df:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8019e4:	b8 08 30 80 00       	mov    $0x803008,%eax
  8019e9:	39 0d 08 30 80 00    	cmp    %ecx,0x803008
  8019ef:	75 11                	jne    801a02 <dev_lookup+0x31>
  8019f1:	eb 04                	jmp    8019f7 <dev_lookup+0x26>
  8019f3:	39 08                	cmp    %ecx,(%eax)
  8019f5:	75 10                	jne    801a07 <dev_lookup+0x36>
			*dev = devtab[i];
  8019f7:	89 03                	mov    %eax,(%ebx)
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8019fe:	66 90                	xchg   %ax,%ax
  801a00:	eb 36                	jmp    801a38 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a02:	be 68 2c 80 00       	mov    $0x802c68,%esi
  801a07:	83 c2 01             	add    $0x1,%edx
  801a0a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801a0d:	85 c0                	test   %eax,%eax
  801a0f:	75 e2                	jne    8019f3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a11:	a1 04 40 80 00       	mov    0x804004,%eax
  801a16:	8b 40 48             	mov    0x48(%eax),%eax
  801a19:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 e8 2b 80 00 	movl   $0x802be8,(%esp)
  801a28:	e8 78 ee ff ff       	call   8008a5 <cprintf>
	*dev = 0;
  801a2d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	53                   	push   %ebx
  801a43:	83 ec 24             	sub    $0x24,%esp
  801a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a49:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a50:	8b 45 08             	mov    0x8(%ebp),%eax
  801a53:	89 04 24             	mov    %eax,(%esp)
  801a56:	e8 02 ff ff ff       	call   80195d <fd_lookup>
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 53                	js     801ab2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a69:	8b 00                	mov    (%eax),%eax
  801a6b:	89 04 24             	mov    %eax,(%esp)
  801a6e:	e8 5e ff ff ff       	call   8019d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 3b                	js     801ab2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801a77:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a7f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801a83:	74 2d                	je     801ab2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801a85:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801a88:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801a8f:	00 00 00 
	stat->st_isdir = 0;
  801a92:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a99:	00 00 00 
	stat->st_dev = dev;
  801a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801aa5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801aa9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aac:	89 14 24             	mov    %edx,(%esp)
  801aaf:	ff 50 14             	call   *0x14(%eax)
}
  801ab2:	83 c4 24             	add    $0x24,%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5d                   	pop    %ebp
  801ab7:	c3                   	ret    

00801ab8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	53                   	push   %ebx
  801abc:	83 ec 24             	sub    $0x24,%esp
  801abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ac2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac9:	89 1c 24             	mov    %ebx,(%esp)
  801acc:	e8 8c fe ff ff       	call   80195d <fd_lookup>
  801ad1:	85 c0                	test   %eax,%eax
  801ad3:	78 5f                	js     801b34 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801ad5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801adc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801adf:	8b 00                	mov    (%eax),%eax
  801ae1:	89 04 24             	mov    %eax,(%esp)
  801ae4:	e8 e8 fe ff ff       	call   8019d1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 47                	js     801b34 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801aed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801af0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801af4:	75 23                	jne    801b19 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801af6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801afb:	8b 40 48             	mov    0x48(%eax),%eax
  801afe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b06:	c7 04 24 08 2c 80 00 	movl   $0x802c08,(%esp)
  801b0d:	e8 93 ed ff ff       	call   8008a5 <cprintf>
  801b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b17:	eb 1b                	jmp    801b34 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1c:	8b 48 18             	mov    0x18(%eax),%ecx
  801b1f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b24:	85 c9                	test   %ecx,%ecx
  801b26:	74 0c                	je     801b34 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b28:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2f:	89 14 24             	mov    %edx,(%esp)
  801b32:	ff d1                	call   *%ecx
}
  801b34:	83 c4 24             	add    $0x24,%esp
  801b37:	5b                   	pop    %ebx
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    

00801b3a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	53                   	push   %ebx
  801b3e:	83 ec 24             	sub    $0x24,%esp
  801b41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b44:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b47:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b4b:	89 1c 24             	mov    %ebx,(%esp)
  801b4e:	e8 0a fe ff ff       	call   80195d <fd_lookup>
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 66                	js     801bbd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b61:	8b 00                	mov    (%eax),%eax
  801b63:	89 04 24             	mov    %eax,(%esp)
  801b66:	e8 66 fe ff ff       	call   8019d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b6b:	85 c0                	test   %eax,%eax
  801b6d:	78 4e                	js     801bbd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b6f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b72:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b76:	75 23                	jne    801b9b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801b78:	a1 04 40 80 00       	mov    0x804004,%eax
  801b7d:	8b 40 48             	mov    0x48(%eax),%eax
  801b80:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b88:	c7 04 24 2c 2c 80 00 	movl   $0x802c2c,(%esp)
  801b8f:	e8 11 ed ff ff       	call   8008a5 <cprintf>
  801b94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801b99:	eb 22                	jmp    801bbd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801ba1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ba6:	85 c9                	test   %ecx,%ecx
  801ba8:	74 13                	je     801bbd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801baa:	8b 45 10             	mov    0x10(%ebp),%eax
  801bad:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bb8:	89 14 24             	mov    %edx,(%esp)
  801bbb:	ff d1                	call   *%ecx
}
  801bbd:	83 c4 24             	add    $0x24,%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	53                   	push   %ebx
  801bc7:	83 ec 24             	sub    $0x24,%esp
  801bca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bcd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd4:	89 1c 24             	mov    %ebx,(%esp)
  801bd7:	e8 81 fd ff ff       	call   80195d <fd_lookup>
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	78 6b                	js     801c4b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801be0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bea:	8b 00                	mov    (%eax),%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 dd fd ff ff       	call   8019d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	78 53                	js     801c4b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801bf8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bfb:	8b 42 08             	mov    0x8(%edx),%eax
  801bfe:	83 e0 03             	and    $0x3,%eax
  801c01:	83 f8 01             	cmp    $0x1,%eax
  801c04:	75 23                	jne    801c29 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c06:	a1 04 40 80 00       	mov    0x804004,%eax
  801c0b:	8b 40 48             	mov    0x48(%eax),%eax
  801c0e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c16:	c7 04 24 49 2c 80 00 	movl   $0x802c49,(%esp)
  801c1d:	e8 83 ec ff ff       	call   8008a5 <cprintf>
  801c22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801c27:	eb 22                	jmp    801c4b <read+0x88>
	}
	if (!dev->dev_read)
  801c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c2c:	8b 48 08             	mov    0x8(%eax),%ecx
  801c2f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c34:	85 c9                	test   %ecx,%ecx
  801c36:	74 13                	je     801c4b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c38:	8b 45 10             	mov    0x10(%ebp),%eax
  801c3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c42:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c46:	89 14 24             	mov    %edx,(%esp)
  801c49:	ff d1                	call   *%ecx
}
  801c4b:	83 c4 24             	add    $0x24,%esp
  801c4e:	5b                   	pop    %ebx
  801c4f:	5d                   	pop    %ebp
  801c50:	c3                   	ret    

00801c51 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801c51:	55                   	push   %ebp
  801c52:	89 e5                	mov    %esp,%ebp
  801c54:	57                   	push   %edi
  801c55:	56                   	push   %esi
  801c56:	53                   	push   %ebx
  801c57:	83 ec 1c             	sub    $0x1c,%esp
  801c5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c5d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c60:	ba 00 00 00 00       	mov    $0x0,%edx
  801c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c6a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6f:	85 f6                	test   %esi,%esi
  801c71:	74 29                	je     801c9c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801c73:	89 f0                	mov    %esi,%eax
  801c75:	29 d0                	sub    %edx,%eax
  801c77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7b:	03 55 0c             	add    0xc(%ebp),%edx
  801c7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c82:	89 3c 24             	mov    %edi,(%esp)
  801c85:	e8 39 ff ff ff       	call   801bc3 <read>
		if (m < 0)
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 0e                	js     801c9c <readn+0x4b>
			return m;
		if (m == 0)
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	74 08                	je     801c9a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801c92:	01 c3                	add    %eax,%ebx
  801c94:	89 da                	mov    %ebx,%edx
  801c96:	39 f3                	cmp    %esi,%ebx
  801c98:	72 d9                	jb     801c73 <readn+0x22>
  801c9a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801c9c:	83 c4 1c             	add    $0x1c,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    

00801ca4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 28             	sub    $0x28,%esp
  801caa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cb0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cb3:	89 34 24             	mov    %esi,(%esp)
  801cb6:	e8 05 fc ff ff       	call   8018c0 <fd2num>
  801cbb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801cbe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cc2:	89 04 24             	mov    %eax,(%esp)
  801cc5:	e8 93 fc ff ff       	call   80195d <fd_lookup>
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	85 c0                	test   %eax,%eax
  801cce:	78 05                	js     801cd5 <fd_close+0x31>
  801cd0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801cd3:	74 0e                	je     801ce3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801cd5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  801cde:	0f 44 d8             	cmove  %eax,%ebx
  801ce1:	eb 3d                	jmp    801d20 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ce3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ce6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cea:	8b 06                	mov    (%esi),%eax
  801cec:	89 04 24             	mov    %eax,(%esp)
  801cef:	e8 dd fc ff ff       	call   8019d1 <dev_lookup>
  801cf4:	89 c3                	mov    %eax,%ebx
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 16                	js     801d10 <fd_close+0x6c>
		if (dev->dev_close)
  801cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfd:	8b 40 10             	mov    0x10(%eax),%eax
  801d00:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d05:	85 c0                	test   %eax,%eax
  801d07:	74 07                	je     801d10 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801d09:	89 34 24             	mov    %esi,(%esp)
  801d0c:	ff d0                	call   *%eax
  801d0e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d10:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d1b:	e8 49 f8 ff ff       	call   801569 <sys_page_unmap>
	return r;
}
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d25:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d28:	89 ec                	mov    %ebp,%esp
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d35:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d39:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3c:	89 04 24             	mov    %eax,(%esp)
  801d3f:	e8 19 fc ff ff       	call   80195d <fd_lookup>
  801d44:	85 c0                	test   %eax,%eax
  801d46:	78 13                	js     801d5b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801d48:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801d4f:	00 
  801d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d53:	89 04 24             	mov    %eax,(%esp)
  801d56:	e8 49 ff ff ff       	call   801ca4 <fd_close>
}
  801d5b:	c9                   	leave  
  801d5c:	c3                   	ret    

00801d5d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801d5d:	55                   	push   %ebp
  801d5e:	89 e5                	mov    %esp,%ebp
  801d60:	83 ec 18             	sub    $0x18,%esp
  801d63:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d66:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801d69:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d70:	00 
  801d71:	8b 45 08             	mov    0x8(%ebp),%eax
  801d74:	89 04 24             	mov    %eax,(%esp)
  801d77:	e8 78 03 00 00       	call   8020f4 <open>
  801d7c:	89 c3                	mov    %eax,%ebx
  801d7e:	85 c0                	test   %eax,%eax
  801d80:	78 1b                	js     801d9d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801d82:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d85:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d89:	89 1c 24             	mov    %ebx,(%esp)
  801d8c:	e8 ae fc ff ff       	call   801a3f <fstat>
  801d91:	89 c6                	mov    %eax,%esi
	close(fd);
  801d93:	89 1c 24             	mov    %ebx,(%esp)
  801d96:	e8 91 ff ff ff       	call   801d2c <close>
  801d9b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801d9d:	89 d8                	mov    %ebx,%eax
  801d9f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801da2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801da5:	89 ec                	mov    %ebp,%esp
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	53                   	push   %ebx
  801dad:	83 ec 14             	sub    $0x14,%esp
  801db0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801db5:	89 1c 24             	mov    %ebx,(%esp)
  801db8:	e8 6f ff ff ff       	call   801d2c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801dbd:	83 c3 01             	add    $0x1,%ebx
  801dc0:	83 fb 20             	cmp    $0x20,%ebx
  801dc3:	75 f0                	jne    801db5 <close_all+0xc>
		close(i);
}
  801dc5:	83 c4 14             	add    $0x14,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    

00801dcb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	83 ec 58             	sub    $0x58,%esp
  801dd1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801dd4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801dd7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801dda:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801ddd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801de0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de4:	8b 45 08             	mov    0x8(%ebp),%eax
  801de7:	89 04 24             	mov    %eax,(%esp)
  801dea:	e8 6e fb ff ff       	call   80195d <fd_lookup>
  801def:	89 c3                	mov    %eax,%ebx
  801df1:	85 c0                	test   %eax,%eax
  801df3:	0f 88 e0 00 00 00    	js     801ed9 <dup+0x10e>
		return r;
	close(newfdnum);
  801df9:	89 3c 24             	mov    %edi,(%esp)
  801dfc:	e8 2b ff ff ff       	call   801d2c <close>

	newfd = INDEX2FD(newfdnum);
  801e01:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801e07:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801e0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e0d:	89 04 24             	mov    %eax,(%esp)
  801e10:	e8 bb fa ff ff       	call   8018d0 <fd2data>
  801e15:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e17:	89 34 24             	mov    %esi,(%esp)
  801e1a:	e8 b1 fa ff ff       	call   8018d0 <fd2data>
  801e1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801e22:	89 da                	mov    %ebx,%edx
  801e24:	89 d8                	mov    %ebx,%eax
  801e26:	c1 e8 16             	shr    $0x16,%eax
  801e29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e30:	a8 01                	test   $0x1,%al
  801e32:	74 43                	je     801e77 <dup+0xac>
  801e34:	c1 ea 0c             	shr    $0xc,%edx
  801e37:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e3e:	a8 01                	test   $0x1,%al
  801e40:	74 35                	je     801e77 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e42:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e49:	25 07 0e 00 00       	and    $0xe07,%eax
  801e4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801e55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e60:	00 
  801e61:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801e65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e6c:	e8 30 f7 ff ff       	call   8015a1 <sys_page_map>
  801e71:	89 c3                	mov    %eax,%ebx
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 3f                	js     801eb6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e7a:	89 c2                	mov    %eax,%edx
  801e7c:	c1 ea 0c             	shr    $0xc,%edx
  801e7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e86:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801e8c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e90:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801e9b:	00 
  801e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea7:	e8 f5 f6 ff ff       	call   8015a1 <sys_page_map>
  801eac:	89 c3                	mov    %eax,%ebx
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 04                	js     801eb6 <dup+0xeb>
  801eb2:	89 fb                	mov    %edi,%ebx
  801eb4:	eb 23                	jmp    801ed9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801eb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec1:	e8 a3 f6 ff ff       	call   801569 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ec6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ec9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed4:	e8 90 f6 ff ff       	call   801569 <sys_page_unmap>
	return r;
}
  801ed9:	89 d8                	mov    %ebx,%eax
  801edb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ede:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ee1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ee4:	89 ec                	mov    %ebp,%esp
  801ee6:	5d                   	pop    %ebp
  801ee7:	c3                   	ret    

00801ee8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	83 ec 18             	sub    $0x18,%esp
  801eee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ef1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ef4:	89 c3                	mov    %eax,%ebx
  801ef6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801ef8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801eff:	75 11                	jne    801f12 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f01:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f08:	e8 63 f8 ff ff       	call   801770 <ipc_find_env>
  801f0d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f12:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f19:	00 
  801f1a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801f21:	00 
  801f22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f26:	a1 00 40 80 00       	mov    0x804000,%eax
  801f2b:	89 04 24             	mov    %eax,(%esp)
  801f2e:	e8 81 f8 ff ff       	call   8017b4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f3a:	00 
  801f3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f46:	e8 d8 f8 ff ff       	call   801823 <ipc_recv>
}
  801f4b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f4e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f51:	89 ec                	mov    %ebp,%esp
  801f53:	5d                   	pop    %ebp
  801f54:	c3                   	ret    

00801f55 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801f55:	55                   	push   %ebp
  801f56:	89 e5                	mov    %esp,%ebp
  801f58:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801f5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f5e:	8b 40 0c             	mov    0xc(%eax),%eax
  801f61:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801f66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f69:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801f6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801f73:	b8 02 00 00 00       	mov    $0x2,%eax
  801f78:	e8 6b ff ff ff       	call   801ee8 <fsipc>
}
  801f7d:	c9                   	leave  
  801f7e:	c3                   	ret    

00801f7f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801f85:	8b 45 08             	mov    0x8(%ebp),%eax
  801f88:	8b 40 0c             	mov    0xc(%eax),%eax
  801f8b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801f90:	ba 00 00 00 00       	mov    $0x0,%edx
  801f95:	b8 06 00 00 00       	mov    $0x6,%eax
  801f9a:	e8 49 ff ff ff       	call   801ee8 <fsipc>
}
  801f9f:	c9                   	leave  
  801fa0:	c3                   	ret    

00801fa1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801fa1:	55                   	push   %ebp
  801fa2:	89 e5                	mov    %esp,%ebp
  801fa4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801fa7:	ba 00 00 00 00       	mov    $0x0,%edx
  801fac:	b8 08 00 00 00       	mov    $0x8,%eax
  801fb1:	e8 32 ff ff ff       	call   801ee8 <fsipc>
}
  801fb6:	c9                   	leave  
  801fb7:	c3                   	ret    

00801fb8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	53                   	push   %ebx
  801fbc:	83 ec 14             	sub    $0x14,%esp
  801fbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc5:	8b 40 0c             	mov    0xc(%eax),%eax
  801fc8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801fcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd2:	b8 05 00 00 00       	mov    $0x5,%eax
  801fd7:	e8 0c ff ff ff       	call   801ee8 <fsipc>
  801fdc:	85 c0                	test   %eax,%eax
  801fde:	78 2b                	js     80200b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801fe0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801fe7:	00 
  801fe8:	89 1c 24             	mov    %ebx,(%esp)
  801feb:	e8 fa ef ff ff       	call   800fea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ff0:	a1 80 50 80 00       	mov    0x805080,%eax
  801ff5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ffb:	a1 84 50 80 00       	mov    0x805084,%eax
  802000:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  802006:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80200b:	83 c4 14             	add    $0x14,%esp
  80200e:	5b                   	pop    %ebx
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    

00802011 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802011:	55                   	push   %ebp
  802012:	89 e5                	mov    %esp,%ebp
  802014:	83 ec 18             	sub    $0x18,%esp
  802017:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80201a:	8b 55 08             	mov    0x8(%ebp),%edx
  80201d:	8b 52 0c             	mov    0xc(%edx),%edx
  802020:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  802026:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80202b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802030:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802035:	0f 47 c2             	cmova  %edx,%eax
  802038:	89 44 24 08          	mov    %eax,0x8(%esp)
  80203c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802043:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80204a:	e8 86 f1 ff ff       	call   8011d5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80204f:	ba 00 00 00 00       	mov    $0x0,%edx
  802054:	b8 04 00 00 00       	mov    $0x4,%eax
  802059:	e8 8a fe ff ff       	call   801ee8 <fsipc>
}
  80205e:	c9                   	leave  
  80205f:	c3                   	ret    

00802060 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802060:	55                   	push   %ebp
  802061:	89 e5                	mov    %esp,%ebp
  802063:	53                   	push   %ebx
  802064:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  802067:	8b 45 08             	mov    0x8(%ebp),%eax
  80206a:	8b 40 0c             	mov    0xc(%eax),%eax
  80206d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  802072:	8b 45 10             	mov    0x10(%ebp),%eax
  802075:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80207a:	ba 00 00 00 00       	mov    $0x0,%edx
  80207f:	b8 03 00 00 00       	mov    $0x3,%eax
  802084:	e8 5f fe ff ff       	call   801ee8 <fsipc>
  802089:	89 c3                	mov    %eax,%ebx
  80208b:	85 c0                	test   %eax,%eax
  80208d:	78 17                	js     8020a6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80208f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802093:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80209a:	00 
  80209b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209e:	89 04 24             	mov    %eax,(%esp)
  8020a1:	e8 2f f1 ff ff       	call   8011d5 <memmove>
  return r;	
}
  8020a6:	89 d8                	mov    %ebx,%eax
  8020a8:	83 c4 14             	add    $0x14,%esp
  8020ab:	5b                   	pop    %ebx
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	53                   	push   %ebx
  8020b2:	83 ec 14             	sub    $0x14,%esp
  8020b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8020b8:	89 1c 24             	mov    %ebx,(%esp)
  8020bb:	e8 e0 ee ff ff       	call   800fa0 <strlen>
  8020c0:	89 c2                	mov    %eax,%edx
  8020c2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8020c7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8020cd:	7f 1f                	jg     8020ee <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8020cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020d3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8020da:	e8 0b ef ff ff       	call   800fea <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8020df:	ba 00 00 00 00       	mov    $0x0,%edx
  8020e4:	b8 07 00 00 00       	mov    $0x7,%eax
  8020e9:	e8 fa fd ff ff       	call   801ee8 <fsipc>
}
  8020ee:	83 c4 14             	add    $0x14,%esp
  8020f1:	5b                   	pop    %ebx
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    

008020f4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	83 ec 28             	sub    $0x28,%esp
  8020fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8020fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802100:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  802103:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802106:	89 04 24             	mov    %eax,(%esp)
  802109:	e8 dd f7 ff ff       	call   8018eb <fd_alloc>
  80210e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  802110:	85 c0                	test   %eax,%eax
  802112:	0f 88 89 00 00 00    	js     8021a1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  802118:	89 34 24             	mov    %esi,(%esp)
  80211b:	e8 80 ee ff ff       	call   800fa0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  802120:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  802125:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80212a:	7f 75                	jg     8021a1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80212c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802130:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  802137:	e8 ae ee ff ff       	call   800fea <strcpy>
  fsipcbuf.open.req_omode = mode;
  80213c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80213f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  802144:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802147:	b8 01 00 00 00       	mov    $0x1,%eax
  80214c:	e8 97 fd ff ff       	call   801ee8 <fsipc>
  802151:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  802153:	85 c0                	test   %eax,%eax
  802155:	78 0f                	js     802166 <open+0x72>
  return fd2num(fd);
  802157:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80215a:	89 04 24             	mov    %eax,(%esp)
  80215d:	e8 5e f7 ff ff       	call   8018c0 <fd2num>
  802162:	89 c3                	mov    %eax,%ebx
  802164:	eb 3b                	jmp    8021a1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  802166:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80216d:	00 
  80216e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802171:	89 04 24             	mov    %eax,(%esp)
  802174:	e8 2b fb ff ff       	call   801ca4 <fd_close>
  802179:	85 c0                	test   %eax,%eax
  80217b:	74 24                	je     8021a1 <open+0xad>
  80217d:	c7 44 24 0c 70 2c 80 	movl   $0x802c70,0xc(%esp)
  802184:	00 
  802185:	c7 44 24 08 85 2c 80 	movl   $0x802c85,0x8(%esp)
  80218c:	00 
  80218d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  802194:	00 
  802195:	c7 04 24 9a 2c 80 00 	movl   $0x802c9a,(%esp)
  80219c:	e8 4b e6 ff ff       	call   8007ec <_panic>
  return r;
}
  8021a1:	89 d8                	mov    %ebx,%eax
  8021a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8021a6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8021a9:	89 ec                	mov    %ebp,%esp
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	00 00                	add    %al,(%eax)
	...

008021b0 <__udivdi3>:
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	57                   	push   %edi
  8021b4:	56                   	push   %esi
  8021b5:	83 ec 10             	sub    $0x10,%esp
  8021b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8021bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8021be:	8b 75 10             	mov    0x10(%ebp),%esi
  8021c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8021c9:	75 35                	jne    802200 <__udivdi3+0x50>
  8021cb:	39 fe                	cmp    %edi,%esi
  8021cd:	77 61                	ja     802230 <__udivdi3+0x80>
  8021cf:	85 f6                	test   %esi,%esi
  8021d1:	75 0b                	jne    8021de <__udivdi3+0x2e>
  8021d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d8:	31 d2                	xor    %edx,%edx
  8021da:	f7 f6                	div    %esi
  8021dc:	89 c6                	mov    %eax,%esi
  8021de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8021e1:	31 d2                	xor    %edx,%edx
  8021e3:	89 f8                	mov    %edi,%eax
  8021e5:	f7 f6                	div    %esi
  8021e7:	89 c7                	mov    %eax,%edi
  8021e9:	89 c8                	mov    %ecx,%eax
  8021eb:	f7 f6                	div    %esi
  8021ed:	89 c1                	mov    %eax,%ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	89 c8                	mov    %ecx,%eax
  8021f3:	83 c4 10             	add    $0x10,%esp
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    
  8021fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802200:	39 f8                	cmp    %edi,%eax
  802202:	77 1c                	ja     802220 <__udivdi3+0x70>
  802204:	0f bd d0             	bsr    %eax,%edx
  802207:	83 f2 1f             	xor    $0x1f,%edx
  80220a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80220d:	75 39                	jne    802248 <__udivdi3+0x98>
  80220f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802212:	0f 86 a0 00 00 00    	jbe    8022b8 <__udivdi3+0x108>
  802218:	39 f8                	cmp    %edi,%eax
  80221a:	0f 82 98 00 00 00    	jb     8022b8 <__udivdi3+0x108>
  802220:	31 ff                	xor    %edi,%edi
  802222:	31 c9                	xor    %ecx,%ecx
  802224:	89 c8                	mov    %ecx,%eax
  802226:	89 fa                	mov    %edi,%edx
  802228:	83 c4 10             	add    $0x10,%esp
  80222b:	5e                   	pop    %esi
  80222c:	5f                   	pop    %edi
  80222d:	5d                   	pop    %ebp
  80222e:	c3                   	ret    
  80222f:	90                   	nop
  802230:	89 d1                	mov    %edx,%ecx
  802232:	89 fa                	mov    %edi,%edx
  802234:	89 c8                	mov    %ecx,%eax
  802236:	31 ff                	xor    %edi,%edi
  802238:	f7 f6                	div    %esi
  80223a:	89 c1                	mov    %eax,%ecx
  80223c:	89 fa                	mov    %edi,%edx
  80223e:	89 c8                	mov    %ecx,%eax
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	5e                   	pop    %esi
  802244:	5f                   	pop    %edi
  802245:	5d                   	pop    %ebp
  802246:	c3                   	ret    
  802247:	90                   	nop
  802248:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80224c:	89 f2                	mov    %esi,%edx
  80224e:	d3 e0                	shl    %cl,%eax
  802250:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802253:	b8 20 00 00 00       	mov    $0x20,%eax
  802258:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80225b:	89 c1                	mov    %eax,%ecx
  80225d:	d3 ea                	shr    %cl,%edx
  80225f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802263:	0b 55 ec             	or     -0x14(%ebp),%edx
  802266:	d3 e6                	shl    %cl,%esi
  802268:	89 c1                	mov    %eax,%ecx
  80226a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80226d:	89 fe                	mov    %edi,%esi
  80226f:	d3 ee                	shr    %cl,%esi
  802271:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802275:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802278:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80227b:	d3 e7                	shl    %cl,%edi
  80227d:	89 c1                	mov    %eax,%ecx
  80227f:	d3 ea                	shr    %cl,%edx
  802281:	09 d7                	or     %edx,%edi
  802283:	89 f2                	mov    %esi,%edx
  802285:	89 f8                	mov    %edi,%eax
  802287:	f7 75 ec             	divl   -0x14(%ebp)
  80228a:	89 d6                	mov    %edx,%esi
  80228c:	89 c7                	mov    %eax,%edi
  80228e:	f7 65 e8             	mull   -0x18(%ebp)
  802291:	39 d6                	cmp    %edx,%esi
  802293:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802296:	72 30                	jb     8022c8 <__udivdi3+0x118>
  802298:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80229b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80229f:	d3 e2                	shl    %cl,%edx
  8022a1:	39 c2                	cmp    %eax,%edx
  8022a3:	73 05                	jae    8022aa <__udivdi3+0xfa>
  8022a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8022a8:	74 1e                	je     8022c8 <__udivdi3+0x118>
  8022aa:	89 f9                	mov    %edi,%ecx
  8022ac:	31 ff                	xor    %edi,%edi
  8022ae:	e9 71 ff ff ff       	jmp    802224 <__udivdi3+0x74>
  8022b3:	90                   	nop
  8022b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	31 ff                	xor    %edi,%edi
  8022ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8022bf:	e9 60 ff ff ff       	jmp    802224 <__udivdi3+0x74>
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8022cb:	31 ff                	xor    %edi,%edi
  8022cd:	89 c8                	mov    %ecx,%eax
  8022cf:	89 fa                	mov    %edi,%edx
  8022d1:	83 c4 10             	add    $0x10,%esp
  8022d4:	5e                   	pop    %esi
  8022d5:	5f                   	pop    %edi
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    
	...

008022e0 <__umoddi3>:
  8022e0:	55                   	push   %ebp
  8022e1:	89 e5                	mov    %esp,%ebp
  8022e3:	57                   	push   %edi
  8022e4:	56                   	push   %esi
  8022e5:	83 ec 20             	sub    $0x20,%esp
  8022e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8022eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8022f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022f4:	85 d2                	test   %edx,%edx
  8022f6:	89 c8                	mov    %ecx,%eax
  8022f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8022fb:	75 13                	jne    802310 <__umoddi3+0x30>
  8022fd:	39 f7                	cmp    %esi,%edi
  8022ff:	76 3f                	jbe    802340 <__umoddi3+0x60>
  802301:	89 f2                	mov    %esi,%edx
  802303:	f7 f7                	div    %edi
  802305:	89 d0                	mov    %edx,%eax
  802307:	31 d2                	xor    %edx,%edx
  802309:	83 c4 20             	add    $0x20,%esp
  80230c:	5e                   	pop    %esi
  80230d:	5f                   	pop    %edi
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    
  802310:	39 f2                	cmp    %esi,%edx
  802312:	77 4c                	ja     802360 <__umoddi3+0x80>
  802314:	0f bd ca             	bsr    %edx,%ecx
  802317:	83 f1 1f             	xor    $0x1f,%ecx
  80231a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80231d:	75 51                	jne    802370 <__umoddi3+0x90>
  80231f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802322:	0f 87 e0 00 00 00    	ja     802408 <__umoddi3+0x128>
  802328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80232b:	29 f8                	sub    %edi,%eax
  80232d:	19 d6                	sbb    %edx,%esi
  80232f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802335:	89 f2                	mov    %esi,%edx
  802337:	83 c4 20             	add    $0x20,%esp
  80233a:	5e                   	pop    %esi
  80233b:	5f                   	pop    %edi
  80233c:	5d                   	pop    %ebp
  80233d:	c3                   	ret    
  80233e:	66 90                	xchg   %ax,%ax
  802340:	85 ff                	test   %edi,%edi
  802342:	75 0b                	jne    80234f <__umoddi3+0x6f>
  802344:	b8 01 00 00 00       	mov    $0x1,%eax
  802349:	31 d2                	xor    %edx,%edx
  80234b:	f7 f7                	div    %edi
  80234d:	89 c7                	mov    %eax,%edi
  80234f:	89 f0                	mov    %esi,%eax
  802351:	31 d2                	xor    %edx,%edx
  802353:	f7 f7                	div    %edi
  802355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802358:	f7 f7                	div    %edi
  80235a:	eb a9                	jmp    802305 <__umoddi3+0x25>
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	89 c8                	mov    %ecx,%eax
  802362:	89 f2                	mov    %esi,%edx
  802364:	83 c4 20             	add    $0x20,%esp
  802367:	5e                   	pop    %esi
  802368:	5f                   	pop    %edi
  802369:	5d                   	pop    %ebp
  80236a:	c3                   	ret    
  80236b:	90                   	nop
  80236c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802370:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802374:	d3 e2                	shl    %cl,%edx
  802376:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802379:	ba 20 00 00 00       	mov    $0x20,%edx
  80237e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802381:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802384:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802388:	89 fa                	mov    %edi,%edx
  80238a:	d3 ea                	shr    %cl,%edx
  80238c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802390:	0b 55 f4             	or     -0xc(%ebp),%edx
  802393:	d3 e7                	shl    %cl,%edi
  802395:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802399:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80239c:	89 f2                	mov    %esi,%edx
  80239e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8023a1:	89 c7                	mov    %eax,%edi
  8023a3:	d3 ea                	shr    %cl,%edx
  8023a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8023ac:	89 c2                	mov    %eax,%edx
  8023ae:	d3 e6                	shl    %cl,%esi
  8023b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8023b4:	d3 ea                	shr    %cl,%edx
  8023b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023ba:	09 d6                	or     %edx,%esi
  8023bc:	89 f0                	mov    %esi,%eax
  8023be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8023c1:	d3 e7                	shl    %cl,%edi
  8023c3:	89 f2                	mov    %esi,%edx
  8023c5:	f7 75 f4             	divl   -0xc(%ebp)
  8023c8:	89 d6                	mov    %edx,%esi
  8023ca:	f7 65 e8             	mull   -0x18(%ebp)
  8023cd:	39 d6                	cmp    %edx,%esi
  8023cf:	72 2b                	jb     8023fc <__umoddi3+0x11c>
  8023d1:	39 c7                	cmp    %eax,%edi
  8023d3:	72 23                	jb     8023f8 <__umoddi3+0x118>
  8023d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023d9:	29 c7                	sub    %eax,%edi
  8023db:	19 d6                	sbb    %edx,%esi
  8023dd:	89 f0                	mov    %esi,%eax
  8023df:	89 f2                	mov    %esi,%edx
  8023e1:	d3 ef                	shr    %cl,%edi
  8023e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8023e7:	d3 e0                	shl    %cl,%eax
  8023e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8023ed:	09 f8                	or     %edi,%eax
  8023ef:	d3 ea                	shr    %cl,%edx
  8023f1:	83 c4 20             	add    $0x20,%esp
  8023f4:	5e                   	pop    %esi
  8023f5:	5f                   	pop    %edi
  8023f6:	5d                   	pop    %ebp
  8023f7:	c3                   	ret    
  8023f8:	39 d6                	cmp    %edx,%esi
  8023fa:	75 d9                	jne    8023d5 <__umoddi3+0xf5>
  8023fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8023ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802402:	eb d1                	jmp    8023d5 <__umoddi3+0xf5>
  802404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802408:	39 f2                	cmp    %esi,%edx
  80240a:	0f 82 18 ff ff ff    	jb     802328 <__umoddi3+0x48>
  802410:	e9 1d ff ff ff       	jmp    802332 <__umoddi3+0x52>
