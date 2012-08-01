
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
  800041:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  800048:	e8 9d 0f 00 00       	call   800fea <strcpy>
	fsipcbuf.open.req_omode = mode;
  80004d:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  800053:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80005a:	e8 81 17 00 00       	call   8017e0 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80005f:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800066:	00 
  800067:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  80006e:	00 
  80006f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800076:	00 
  800077:	89 04 24             	mov    %eax,(%esp)
  80007a:	e8 a5 17 00 00       	call   801824 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  80007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800086:	00 
  800087:	c7 44 24 04 00 c0 cc 	movl   $0xccccc000,0x4(%esp)
  80008e:	cc 
  80008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800096:	e8 f4 17 00 00       	call   80188f <ipc_recv>
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
  8000b2:	b8 e0 29 80 00       	mov    $0x8029e0,%eax
  8000b7:	e8 78 ff ff ff       	call   800034 <xopen>
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	79 25                	jns    8000e5 <umain+0x44>
  8000c0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000c3:	74 3c                	je     800101 <umain+0x60>
		panic("serve_open /not-found: %e", r);
  8000c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c9:	c7 44 24 08 eb 29 80 	movl   $0x8029eb,0x8(%esp)
  8000d0:	00 
  8000d1:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8000d8:	00 
  8000d9:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8000e0:	e8 07 07 00 00       	call   8007ec <_panic>
	else if (r >= 0)
		panic("serve_open /not-found succeeded!");
  8000e5:	c7 44 24 08 a0 2b 80 	movl   $0x802ba0,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8000fc:	e8 eb 06 00 00       	call   8007ec <_panic>
	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  800101:	ba 00 00 00 00       	mov    $0x0,%edx
  800106:	b8 15 2a 80 00       	mov    $0x802a15,%eax
  80010b:	e8 24 ff ff ff       	call   800034 <xopen>
  800110:	85 c0                	test   %eax,%eax
  800112:	79 20                	jns    800134 <umain+0x93>
		panic("serve_open /newmotd: %e", r);
  800114:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800118:	c7 44 24 08 1e 2a 80 	movl   $0x802a1e,0x8(%esp)
  80011f:	00 
  800120:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800127:	00 
  800128:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  80012f:	e8 b8 06 00 00       	call   8007ec <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  800134:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  80013b:	75 12                	jne    80014f <umain+0xae>
  80013d:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800144:	75 09                	jne    80014f <umain+0xae>
  800146:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80014d:	74 1c                	je     80016b <umain+0xca>
		panic("serve_open did not fill struct Fd correctly\n");
  80014f:	c7 44 24 08 c4 2b 80 	movl   $0x802bc4,0x8(%esp)
  800156:	00 
  800157:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  80015e:	00 
  80015f:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  800166:	e8 81 06 00 00       	call   8007ec <_panic>
	cprintf("serve_open is good\n");
  80016b:	c7 04 24 36 2a 80 00 	movl   $0x802a36,(%esp)
  800172:	e8 2e 07 00 00       	call   8008a5 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800177:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800181:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  800188:	ff 15 1c 40 80 00    	call   *0x80401c
  80018e:	85 c0                	test   %eax,%eax
  800190:	79 20                	jns    8001b2 <umain+0x111>
		panic("file_stat: %e", r);
  800192:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800196:	c7 44 24 08 4a 2a 80 	movl   $0x802a4a,0x8(%esp)
  80019d:	00 
  80019e:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  8001a5:	00 
  8001a6:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8001ad:	e8 3a 06 00 00       	call   8007ec <_panic>
	if (strlen(msg) != st.st_size)
  8001b2:	a1 00 40 80 00       	mov    0x804000,%eax
  8001b7:	89 04 24             	mov    %eax,(%esp)
  8001ba:	e8 e1 0d 00 00       	call   800fa0 <strlen>
  8001bf:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  8001c2:	74 34                	je     8001f8 <umain+0x157>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8001c4:	a1 00 40 80 00       	mov    0x804000,%eax
  8001c9:	89 04 24             	mov    %eax,(%esp)
  8001cc:	e8 cf 0d 00 00       	call   800fa0 <strlen>
  8001d1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	c7 44 24 08 f4 2b 80 	movl   $0x802bf4,0x8(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8001eb:	00 
  8001ec:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8001f3:	e8 f4 05 00 00       	call   8007ec <_panic>
	cprintf("file_stat is good\n");
  8001f8:	c7 04 24 58 2a 80 00 	movl   $0x802a58,(%esp)
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
  800235:	ff 15 10 40 80 00    	call   *0x804010
  80023b:	85 c0                	test   %eax,%eax
  80023d:	79 20                	jns    80025f <umain+0x1be>
		panic("file_read: %e", r);
  80023f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800243:	c7 44 24 08 6b 2a 80 	movl   $0x802a6b,0x8(%esp)
  80024a:	00 
  80024b:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
  800252:	00 
  800253:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  80025a:	e8 8d 05 00 00       	call   8007ec <_panic>
	if (strcmp(buf, msg) != 0)
  80025f:	a1 00 40 80 00       	mov    0x804000,%eax
  800264:	89 44 24 04          	mov    %eax,0x4(%esp)
  800268:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80026e:	89 04 24             	mov    %eax,(%esp)
  800271:	e8 2f 0e 00 00       	call   8010a5 <strcmp>
  800276:	85 c0                	test   %eax,%eax
  800278:	74 1c                	je     800296 <umain+0x1f5>
		panic("file_read returned wrong data");
  80027a:	c7 44 24 08 79 2a 80 	movl   $0x802a79,0x8(%esp)
  800281:	00 
  800282:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  800291:	e8 56 05 00 00       	call   8007ec <_panic>
	cprintf("file_read is good\n");
  800296:	c7 04 24 97 2a 80 00 	movl   $0x802a97,(%esp)
  80029d:	e8 03 06 00 00       	call   8008a5 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8002a2:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8002a9:	ff 15 18 40 80 00    	call   *0x804018
  8002af:	85 c0                	test   %eax,%eax
  8002b1:	79 20                	jns    8002d3 <umain+0x232>
		panic("file_close: %e", r);
  8002b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b7:	c7 44 24 08 aa 2a 80 	movl   $0x802aaa,0x8(%esp)
  8002be:	00 
  8002bf:	c7 44 24 04 36 00 00 	movl   $0x36,0x4(%esp)
  8002c6:	00 
  8002c7:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8002ce:	e8 19 05 00 00       	call   8007ec <_panic>
	cprintf("file_close is good\n");
  8002d3:	c7 04 24 b9 2a 80 00 	movl   $0x802ab9,(%esp)
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
  80030a:	e8 cd 12 00 00       	call   8015dc <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80030f:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  800316:	00 
  800317:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 15 10 40 80 00    	call   *0x804010
  80032d:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800330:	74 20                	je     800352 <umain+0x2b1>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  800332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800336:	c7 44 24 08 1c 2c 80 	movl   $0x802c1c,0x8(%esp)
  80033d:	00 
  80033e:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  800345:	00 
  800346:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  80034d:	e8 9a 04 00 00       	call   8007ec <_panic>
	cprintf("stale fileid is good\n");
  800352:	c7 04 24 cd 2a 80 00 	movl   $0x802acd,(%esp)
  800359:	e8 47 05 00 00       	call   8008a5 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  80035e:	ba 02 01 00 00       	mov    $0x102,%edx
  800363:	b8 e3 2a 80 00       	mov    $0x802ae3,%eax
  800368:	e8 c7 fc ff ff       	call   800034 <xopen>
  80036d:	85 c0                	test   %eax,%eax
  80036f:	79 20                	jns    800391 <umain+0x2f0>
		panic("serve_open /new-file: %e", r);
  800371:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800375:	c7 44 24 08 ed 2a 80 	movl   $0x802aed,0x8(%esp)
  80037c:	00 
  80037d:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  800384:	00 
  800385:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  80038c:	e8 5b 04 00 00       	call   8007ec <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800391:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  800397:	a1 00 40 80 00       	mov    0x804000,%eax
  80039c:	89 04 24             	mov    %eax,(%esp)
  80039f:	e8 fc 0b 00 00       	call   800fa0 <strlen>
  8003a4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a8:	a1 00 40 80 00       	mov    0x804000,%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8003b8:	ff d3                	call   *%ebx
  8003ba:	89 c3                	mov    %eax,%ebx
  8003bc:	a1 00 40 80 00       	mov    0x804000,%eax
  8003c1:	89 04 24             	mov    %eax,(%esp)
  8003c4:	e8 d7 0b 00 00       	call   800fa0 <strlen>
  8003c9:	39 c3                	cmp    %eax,%ebx
  8003cb:	74 20                	je     8003ed <umain+0x34c>
		panic("file_write: %e", r);
  8003cd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8003d1:	c7 44 24 08 06 2b 80 	movl   $0x802b06,0x8(%esp)
  8003d8:	00 
  8003d9:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
  8003e0:	00 
  8003e1:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8003e8:	e8 ff 03 00 00       	call   8007ec <_panic>
	cprintf("file_write is good\n");
  8003ed:	c7 04 24 15 2b 80 00 	movl   $0x802b15,(%esp)
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
  800434:	ff 15 10 40 80 00    	call   *0x804010
  80043a:	89 c3                	mov    %eax,%ebx
  80043c:	85 c0                	test   %eax,%eax
  80043e:	79 20                	jns    800460 <umain+0x3bf>
		panic("file_read after file_write: %e", r);
  800440:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800444:	c7 44 24 08 54 2c 80 	movl   $0x802c54,0x8(%esp)
  80044b:	00 
  80044c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  800453:	00 
  800454:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  80045b:	e8 8c 03 00 00       	call   8007ec <_panic>
	if (r != strlen(msg))
  800460:	a1 00 40 80 00       	mov    0x804000,%eax
  800465:	89 04 24             	mov    %eax,(%esp)
  800468:	e8 33 0b 00 00       	call   800fa0 <strlen>
  80046d:	39 c3                	cmp    %eax,%ebx
  80046f:	74 20                	je     800491 <umain+0x3f0>
		panic("file_read after file_write returned wrong length: %d", r);
  800471:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800475:	c7 44 24 08 74 2c 80 	movl   $0x802c74,0x8(%esp)
  80047c:	00 
  80047d:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  800484:	00 
  800485:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  80048c:	e8 5b 03 00 00       	call   8007ec <_panic>
	if (strcmp(buf, msg) != 0)
  800491:	a1 00 40 80 00       	mov    0x804000,%eax
  800496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80049a:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	e8 fd 0b 00 00       	call   8010a5 <strcmp>
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	74 1c                	je     8004c8 <umain+0x427>
		panic("file_read after file_write returned wrong data");
  8004ac:	c7 44 24 08 ac 2c 80 	movl   $0x802cac,0x8(%esp)
  8004b3:	00 
  8004b4:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  8004bb:	00 
  8004bc:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8004c3:	e8 24 03 00 00       	call   8007ec <_panic>
	cprintf("file_read after file_write is good\n");
  8004c8:	c7 04 24 dc 2c 80 00 	movl   $0x802cdc,(%esp)
  8004cf:	e8 d1 03 00 00       	call   8008a5 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  8004d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8004db:	00 
  8004dc:	c7 04 24 e0 29 80 00 	movl   $0x8029e0,(%esp)
  8004e3:	e8 6c 1c 00 00       	call   802154 <open>
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	79 25                	jns    800511 <umain+0x470>
  8004ec:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8004ef:	74 3c                	je     80052d <umain+0x48c>
		panic("open /not-found: %e", r);
  8004f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f5:	c7 44 24 08 f1 29 80 	movl   $0x8029f1,0x8(%esp)
  8004fc:	00 
  8004fd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  800504:	00 
  800505:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  80050c:	e8 db 02 00 00       	call   8007ec <_panic>
	else if (r >= 0)
		panic("open /not-found succeeded!");
  800511:	c7 44 24 08 29 2b 80 	movl   $0x802b29,0x8(%esp)
  800518:	00 
  800519:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800520:	00 
  800521:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  800528:	e8 bf 02 00 00       	call   8007ec <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80052d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800534:	00 
  800535:	c7 04 24 15 2a 80 00 	movl   $0x802a15,(%esp)
  80053c:	e8 13 1c 00 00       	call   802154 <open>
  800541:	85 c0                	test   %eax,%eax
  800543:	79 20                	jns    800565 <umain+0x4c4>
		panic("open /newmotd: %e", r);
  800545:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800549:	c7 44 24 08 24 2a 80 	movl   $0x802a24,0x8(%esp)
  800550:	00 
  800551:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  800558:	00 
  800559:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
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
  80057e:	c7 44 24 08 00 2d 80 	movl   $0x802d00,0x8(%esp)
  800585:	00 
  800586:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  80058d:	00 
  80058e:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  800595:	e8 52 02 00 00       	call   8007ec <_panic>
	cprintf("open is good\n");
  80059a:	c7 04 24 3c 2a 80 00 	movl   $0x802a3c,(%esp)
  8005a1:	e8 ff 02 00 00       	call   8008a5 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8005a6:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  8005ad:	00 
  8005ae:	c7 04 24 44 2b 80 00 	movl   $0x802b44,(%esp)
  8005b5:	e8 9a 1b 00 00       	call   802154 <open>
  8005ba:	89 85 44 fd ff ff    	mov    %eax,-0x2bc(%ebp)
  8005c0:	85 c0                	test   %eax,%eax
  8005c2:	79 20                	jns    8005e4 <umain+0x543>
		panic("creat /big: %e", f);
  8005c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8005c8:	c7 44 24 08 49 2b 80 	movl   $0x802b49,0x8(%esp)
  8005cf:	00 
  8005d0:	c7 44 24 04 65 00 00 	movl   $0x65,0x4(%esp)
  8005d7:	00 
  8005d8:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
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
  800626:	e8 6f 15 00 00       	call   801b9a <write>
  80062b:	85 c0                	test   %eax,%eax
  80062d:	79 24                	jns    800653 <umain+0x5b2>
			panic("write /big@%d: %e", i, r);
  80062f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800633:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800637:	c7 44 24 08 58 2b 80 	movl   $0x802b58,0x8(%esp)
  80063e:	00 
  80063f:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
  800646:	00 
  800647:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
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
  80066a:	e8 1d 17 00 00       	call   801d8c <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80066f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800676:	00 
  800677:	c7 04 24 44 2b 80 00 	movl   $0x802b44,(%esp)
  80067e:	e8 d1 1a 00 00       	call   802154 <open>
  800683:	89 c6                	mov    %eax,%esi
  800685:	85 c0                	test   %eax,%eax
  800687:	79 20                	jns    8006a9 <umain+0x608>
		panic("open /big: %e", f);
  800689:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068d:	c7 44 24 08 6a 2b 80 	movl   $0x802b6a,0x8(%esp)
  800694:	00 
  800695:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
  80069c:	00 
  80069d:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
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
  8006c5:	e8 e7 15 00 00       	call   801cb1 <readn>
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	79 24                	jns    8006f2 <umain+0x651>
			panic("read /big@%d: %e", i, r);
  8006ce:	89 44 24 10          	mov    %eax,0x10(%esp)
  8006d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8006d6:	c7 44 24 08 78 2b 80 	movl   $0x802b78,0x8(%esp)
  8006dd:	00 
  8006de:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  8006e5:	00 
  8006e6:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  8006ed:	e8 fa 00 00 00       	call   8007ec <_panic>
		if (r != sizeof(buf))
  8006f2:	3d 00 02 00 00       	cmp    $0x200,%eax
  8006f7:	74 2c                	je     800725 <umain+0x684>
			panic("read /big from %d returned %d < %d bytes",
  8006f9:	c7 44 24 14 00 02 00 	movl   $0x200,0x14(%esp)
  800700:	00 
  800701:	89 44 24 10          	mov    %eax,0x10(%esp)
  800705:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800709:	c7 44 24 08 28 2d 80 	movl   $0x802d28,0x8(%esp)
  800710:	00 
  800711:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  800718:	00 
  800719:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
  800720:	e8 c7 00 00 00       	call   8007ec <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800725:	8b 07                	mov    (%edi),%eax
  800727:	39 d8                	cmp    %ebx,%eax
  800729:	74 24                	je     80074f <umain+0x6ae>
			panic("read /big from %d returned bad data %d",
  80072b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80072f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800733:	c7 44 24 08 54 2d 80 	movl   $0x802d54,0x8(%esp)
  80073a:	00 
  80073b:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  800742:	00 
  800743:	c7 04 24 05 2a 80 00 	movl   $0x802a05,(%esp)
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
  800764:	e8 23 16 00 00       	call   801d8c <close>
	cprintf("large file is good\n");
  800769:	c7 04 24 89 2b 80 00 	movl   $0x802b89,(%esp)
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
  800792:	e8 60 0f 00 00       	call   8016f7 <sys_getenvid>
  800797:	25 ff 03 00 00       	and    $0x3ff,%eax
  80079c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80079f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8007a4:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8007a9:	85 f6                	test   %esi,%esi
  8007ab:	7e 07                	jle    8007b4 <libmain+0x34>
		binaryname = argv[0];
  8007ad:	8b 03                	mov    (%ebx),%eax
  8007af:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8007d6:	e8 2e 16 00 00       	call   801e09 <close_all>
	sys_env_destroy(0);
  8007db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8007e2:	e8 4b 0f 00 00       	call   801732 <sys_env_destroy>
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
  8007f7:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8007fd:	e8 f5 0e 00 00       	call   8016f7 <sys_getenvid>
  800802:	8b 55 0c             	mov    0xc(%ebp),%edx
  800805:	89 54 24 10          	mov    %edx,0x10(%esp)
  800809:	8b 55 08             	mov    0x8(%ebp),%edx
  80080c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800810:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800814:	89 44 24 04          	mov    %eax,0x4(%esp)
  800818:	c7 04 24 ac 2d 80 00 	movl   $0x802dac,(%esp)
  80081f:	e8 81 00 00 00       	call   8008a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800824:	89 74 24 04          	mov    %esi,0x4(%esp)
  800828:	8b 45 10             	mov    0x10(%ebp),%eax
  80082b:	89 04 24             	mov    %eax,(%esp)
  80082e:	e8 11 00 00 00       	call   800844 <vcprintf>
	cprintf("\n");
  800833:	c7 04 24 a8 2a 80 00 	movl   $0x802aa8,(%esp)
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
  800898:	e8 09 0f 00 00       	call   8017a6 <sys_cputs>

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
  8008ec:	e8 b5 0e 00 00       	call   8017a6 <sys_cputs>
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
  80098d:	e8 ce 1d 00 00       	call   802760 <__udivdi3>
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
  8009e8:	e8 a3 1e 00 00       	call   802890 <__umoddi3>
  8009ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f1:	0f be 80 cf 2d 80 00 	movsbl 0x802dcf(%eax),%eax
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
  800ad5:	ff 24 95 a0 2f 80 00 	jmp    *0x802fa0(,%edx,4)
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
  800ba8:	8b 14 85 00 31 80 00 	mov    0x803100(,%eax,4),%edx
  800baf:	85 d2                	test   %edx,%edx
  800bb1:	75 20                	jne    800bd3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800bb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb7:	c7 44 24 08 e0 2d 80 	movl   $0x802de0,0x8(%esp)
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
  800bd7:	c7 44 24 08 5b 32 80 	movl   $0x80325b,0x8(%esp)
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
  800c11:	b8 e9 2d 80 00       	mov    $0x802de9,%eax
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
  800e55:	c7 44 24 0c 04 2f 80 	movl   $0x802f04,0xc(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 08 5b 32 80 	movl   $0x80325b,0x8(%esp)
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
  800e83:	c7 44 24 0c 3c 2f 80 	movl   $0x802f3c,0xc(%esp)
  800e8a:	00 
  800e8b:	c7 44 24 08 5b 32 80 	movl   $0x80325b,0x8(%esp)
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
  801427:	c7 44 24 08 40 31 80 	movl   $0x803140,0x8(%esp)
  80142e:	00 
  80142f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801436:	00 
  801437:	c7 04 24 5d 31 80 00 	movl   $0x80315d,(%esp)
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

00801452 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  801458:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80145f:	00 
  801460:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801467:	00 
  801468:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80146f:	00 
  801470:	8b 45 0c             	mov    0xc(%ebp),%eax
  801473:	89 04 24             	mov    %eax,(%esp)
  801476:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	b8 10 00 00 00       	mov    $0x10,%eax
  801483:	e8 54 ff ff ff       	call   8013dc <syscall>
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  801490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801497:	00 
  801498:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80149f:	00 
  8014a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014a7:	00 
  8014a8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8014be:	e8 19 ff ff ff       	call   8013dc <syscall>
}
  8014c3:	c9                   	leave  
  8014c4:	c3                   	ret    

008014c5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8014c5:	55                   	push   %ebp
  8014c6:	89 e5                	mov    %esp,%ebp
  8014c8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8014cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014d2:	00 
  8014d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014da:	00 
  8014db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014e2:	00 
  8014e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014ed:	ba 01 00 00 00       	mov    $0x1,%edx
  8014f2:	b8 0e 00 00 00       	mov    $0xe,%eax
  8014f7:	e8 e0 fe ff ff       	call   8013dc <syscall>
}
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801504:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80150b:	00 
  80150c:	8b 45 14             	mov    0x14(%ebp),%eax
  80150f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801513:	8b 45 10             	mov    0x10(%ebp),%eax
  801516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80151a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151d:	89 04 24             	mov    %eax,(%esp)
  801520:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801523:	ba 00 00 00 00       	mov    $0x0,%edx
  801528:	b8 0d 00 00 00       	mov    $0xd,%eax
  80152d:	e8 aa fe ff ff       	call   8013dc <syscall>
}
  801532:	c9                   	leave  
  801533:	c3                   	ret    

00801534 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801534:	55                   	push   %ebp
  801535:	89 e5                	mov    %esp,%ebp
  801537:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80153a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801541:	00 
  801542:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801549:	00 
  80154a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801551:	00 
  801552:	8b 45 0c             	mov    0xc(%ebp),%eax
  801555:	89 04 24             	mov    %eax,(%esp)
  801558:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155b:	ba 01 00 00 00       	mov    $0x1,%edx
  801560:	b8 0b 00 00 00       	mov    $0xb,%eax
  801565:	e8 72 fe ff ff       	call   8013dc <syscall>
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801572:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801579:	00 
  80157a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801581:	00 
  801582:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801589:	00 
  80158a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80158d:	89 04 24             	mov    %eax,(%esp)
  801590:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801593:	ba 01 00 00 00       	mov    $0x1,%edx
  801598:	b8 0a 00 00 00       	mov    $0xa,%eax
  80159d:	e8 3a fe ff ff       	call   8013dc <syscall>
}
  8015a2:	c9                   	leave  
  8015a3:	c3                   	ret    

008015a4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8015aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015b1:	00 
  8015b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015b9:	00 
  8015ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015c1:	00 
  8015c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015c5:	89 04 24             	mov    %eax,(%esp)
  8015c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015cb:	ba 01 00 00 00       	mov    $0x1,%edx
  8015d0:	b8 09 00 00 00       	mov    $0x9,%eax
  8015d5:	e8 02 fe ff ff       	call   8013dc <syscall>
}
  8015da:	c9                   	leave  
  8015db:	c3                   	ret    

008015dc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8015dc:	55                   	push   %ebp
  8015dd:	89 e5                	mov    %esp,%ebp
  8015df:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8015e2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015e9:	00 
  8015ea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f1:	00 
  8015f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015f9:	00 
  8015fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015fd:	89 04 24             	mov    %eax,(%esp)
  801600:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801603:	ba 01 00 00 00       	mov    $0x1,%edx
  801608:	b8 07 00 00 00       	mov    $0x7,%eax
  80160d:	e8 ca fd ff ff       	call   8013dc <syscall>
}
  801612:	c9                   	leave  
  801613:	c3                   	ret    

00801614 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  80161a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801621:	00 
  801622:	8b 45 18             	mov    0x18(%ebp),%eax
  801625:	0b 45 14             	or     0x14(%ebp),%eax
  801628:	89 44 24 08          	mov    %eax,0x8(%esp)
  80162c:	8b 45 10             	mov    0x10(%ebp),%eax
  80162f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801633:	8b 45 0c             	mov    0xc(%ebp),%eax
  801636:	89 04 24             	mov    %eax,(%esp)
  801639:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80163c:	ba 01 00 00 00       	mov    $0x1,%edx
  801641:	b8 06 00 00 00       	mov    $0x6,%eax
  801646:	e8 91 fd ff ff       	call   8013dc <syscall>
}
  80164b:	c9                   	leave  
  80164c:	c3                   	ret    

0080164d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80164d:	55                   	push   %ebp
  80164e:	89 e5                	mov    %esp,%ebp
  801650:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801653:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80165a:	00 
  80165b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801662:	00 
  801663:	8b 45 10             	mov    0x10(%ebp),%eax
  801666:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166d:	89 04 24             	mov    %eax,(%esp)
  801670:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801673:	ba 01 00 00 00       	mov    $0x1,%edx
  801678:	b8 05 00 00 00       	mov    $0x5,%eax
  80167d:	e8 5a fd ff ff       	call   8013dc <syscall>
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80168a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801691:	00 
  801692:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801699:	00 
  80169a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016a1:	00 
  8016a2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8016b8:	e8 1f fd ff ff       	call   8013dc <syscall>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8016c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8016cc:	00 
  8016cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016d4:	00 
  8016d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016dc:	00 
  8016dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e0:	89 04 24             	mov    %eax,(%esp)
  8016e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016eb:	b8 04 00 00 00       	mov    $0x4,%eax
  8016f0:	e8 e7 fc ff ff       	call   8013dc <syscall>
}
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8016fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801704:	00 
  801705:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170c:	00 
  80170d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801714:	00 
  801715:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80171c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
  801726:	b8 02 00 00 00       	mov    $0x2,%eax
  80172b:	e8 ac fc ff ff       	call   8013dc <syscall>
}
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801738:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80173f:	00 
  801740:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801747:	00 
  801748:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80174f:	00 
  801750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175a:	ba 01 00 00 00       	mov    $0x1,%edx
  80175f:	b8 03 00 00 00       	mov    $0x3,%eax
  801764:	e8 73 fc ff ff       	call   8013dc <syscall>
}
  801769:	c9                   	leave  
  80176a:	c3                   	ret    

0080176b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801771:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801778:	00 
  801779:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801780:	00 
  801781:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801788:	00 
  801789:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801790:	b9 00 00 00 00       	mov    $0x0,%ecx
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	b8 01 00 00 00       	mov    $0x1,%eax
  80179f:	e8 38 fc ff ff       	call   8013dc <syscall>
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8017ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8017b3:	00 
  8017b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017bb:	00 
  8017bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017c3:	00 
  8017c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c7:	89 04 24             	mov    %eax,(%esp)
  8017ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d7:	e8 00 fc ff ff       	call   8013dc <syscall>
}
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    
	...

008017e0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8017e6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8017ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f1:	39 ca                	cmp    %ecx,%edx
  8017f3:	75 04                	jne    8017f9 <ipc_find_env+0x19>
  8017f5:	b0 00                	mov    $0x0,%al
  8017f7:	eb 0f                	jmp    801808 <ipc_find_env+0x28>
  8017f9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8017fc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801802:	8b 12                	mov    (%edx),%edx
  801804:	39 ca                	cmp    %ecx,%edx
  801806:	75 0c                	jne    801814 <ipc_find_env+0x34>
			return envs[i].env_id;
  801808:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80180b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801810:	8b 00                	mov    (%eax),%eax
  801812:	eb 0e                	jmp    801822 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801814:	83 c0 01             	add    $0x1,%eax
  801817:	3d 00 04 00 00       	cmp    $0x400,%eax
  80181c:	75 db                	jne    8017f9 <ipc_find_env+0x19>
  80181e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	83 ec 1c             	sub    $0x1c,%esp
  80182d:	8b 75 08             	mov    0x8(%ebp),%esi
  801830:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801833:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801836:	85 db                	test   %ebx,%ebx
  801838:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80183d:	0f 44 d8             	cmove  %eax,%ebx
  801840:	eb 25                	jmp    801867 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801842:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801845:	74 20                	je     801867 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801847:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80184b:	c7 44 24 08 6b 31 80 	movl   $0x80316b,0x8(%esp)
  801852:	00 
  801853:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80185a:	00 
  80185b:	c7 04 24 89 31 80 00 	movl   $0x803189,(%esp)
  801862:	e8 85 ef ff ff       	call   8007ec <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801867:	8b 45 14             	mov    0x14(%ebp),%eax
  80186a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80186e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801872:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801876:	89 34 24             	mov    %esi,(%esp)
  801879:	e8 80 fc ff ff       	call   8014fe <sys_ipc_try_send>
  80187e:	85 c0                	test   %eax,%eax
  801880:	75 c0                	jne    801842 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801882:	e8 fd fd ff ff       	call   801684 <sys_yield>
}
  801887:	83 c4 1c             	add    $0x1c,%esp
  80188a:	5b                   	pop    %ebx
  80188b:	5e                   	pop    %esi
  80188c:	5f                   	pop    %edi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	83 ec 28             	sub    $0x28,%esp
  801895:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801898:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80189b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80189e:	8b 75 08             	mov    0x8(%ebp),%esi
  8018a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a4:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8018ae:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8018b1:	89 04 24             	mov    %eax,(%esp)
  8018b4:	e8 0c fc ff ff       	call   8014c5 <sys_ipc_recv>
  8018b9:	89 c3                	mov    %eax,%ebx
  8018bb:	85 c0                	test   %eax,%eax
  8018bd:	79 2a                	jns    8018e9 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8018bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c7:	c7 04 24 93 31 80 00 	movl   $0x803193,(%esp)
  8018ce:	e8 d2 ef ff ff       	call   8008a5 <cprintf>
		if(from_env_store != NULL)
  8018d3:	85 f6                	test   %esi,%esi
  8018d5:	74 06                	je     8018dd <ipc_recv+0x4e>
			*from_env_store = 0;
  8018d7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8018dd:	85 ff                	test   %edi,%edi
  8018df:	74 2c                	je     80190d <ipc_recv+0x7e>
			*perm_store = 0;
  8018e1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8018e7:	eb 24                	jmp    80190d <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8018e9:	85 f6                	test   %esi,%esi
  8018eb:	74 0a                	je     8018f7 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8018ed:	a1 08 50 80 00       	mov    0x805008,%eax
  8018f2:	8b 40 74             	mov    0x74(%eax),%eax
  8018f5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8018f7:	85 ff                	test   %edi,%edi
  8018f9:	74 0a                	je     801905 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8018fb:	a1 08 50 80 00       	mov    0x805008,%eax
  801900:	8b 40 78             	mov    0x78(%eax),%eax
  801903:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801905:	a1 08 50 80 00       	mov    0x805008,%eax
  80190a:	8b 58 70             	mov    0x70(%eax),%ebx
}
  80190d:	89 d8                	mov    %ebx,%eax
  80190f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801912:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801915:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801918:	89 ec                	mov    %ebp,%esp
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    
  80191c:	00 00                	add    %al,(%eax)
	...

00801920 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	8b 45 08             	mov    0x8(%ebp),%eax
  801926:	05 00 00 00 30       	add    $0x30000000,%eax
  80192b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801936:	8b 45 08             	mov    0x8(%ebp),%eax
  801939:	89 04 24             	mov    %eax,(%esp)
  80193c:	e8 df ff ff ff       	call   801920 <fd2num>
  801941:	05 20 00 0d 00       	add    $0xd0020,%eax
  801946:	c1 e0 0c             	shl    $0xc,%eax
}
  801949:	c9                   	leave  
  80194a:	c3                   	ret    

0080194b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80194b:	55                   	push   %ebp
  80194c:	89 e5                	mov    %esp,%ebp
  80194e:	57                   	push   %edi
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801954:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801959:	a8 01                	test   $0x1,%al
  80195b:	74 36                	je     801993 <fd_alloc+0x48>
  80195d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801962:	a8 01                	test   $0x1,%al
  801964:	74 2d                	je     801993 <fd_alloc+0x48>
  801966:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80196b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801970:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801975:	89 c3                	mov    %eax,%ebx
  801977:	89 c2                	mov    %eax,%edx
  801979:	c1 ea 16             	shr    $0x16,%edx
  80197c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80197f:	f6 c2 01             	test   $0x1,%dl
  801982:	74 14                	je     801998 <fd_alloc+0x4d>
  801984:	89 c2                	mov    %eax,%edx
  801986:	c1 ea 0c             	shr    $0xc,%edx
  801989:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80198c:	f6 c2 01             	test   $0x1,%dl
  80198f:	75 10                	jne    8019a1 <fd_alloc+0x56>
  801991:	eb 05                	jmp    801998 <fd_alloc+0x4d>
  801993:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801998:	89 1f                	mov    %ebx,(%edi)
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80199f:	eb 17                	jmp    8019b8 <fd_alloc+0x6d>
  8019a1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8019a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8019ab:	75 c8                	jne    801975 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8019ad:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8019b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8019b8:	5b                   	pop    %ebx
  8019b9:	5e                   	pop    %esi
  8019ba:	5f                   	pop    %edi
  8019bb:	5d                   	pop    %ebp
  8019bc:	c3                   	ret    

008019bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8019c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c3:	83 f8 1f             	cmp    $0x1f,%eax
  8019c6:	77 36                	ja     8019fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8019c8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8019cd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8019d0:	89 c2                	mov    %eax,%edx
  8019d2:	c1 ea 16             	shr    $0x16,%edx
  8019d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8019dc:	f6 c2 01             	test   $0x1,%dl
  8019df:	74 1d                	je     8019fe <fd_lookup+0x41>
  8019e1:	89 c2                	mov    %eax,%edx
  8019e3:	c1 ea 0c             	shr    $0xc,%edx
  8019e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8019ed:	f6 c2 01             	test   $0x1,%dl
  8019f0:	74 0c                	je     8019fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8019f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f5:	89 02                	mov    %eax,(%edx)
  8019f7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8019fc:	eb 05                	jmp    801a03 <fd_lookup+0x46>
  8019fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801a05:	55                   	push   %ebp
  801a06:	89 e5                	mov    %esp,%ebp
  801a08:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a0b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	89 04 24             	mov    %eax,(%esp)
  801a18:	e8 a0 ff ff ff       	call   8019bd <fd_lookup>
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 0e                	js     801a2f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801a21:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801a24:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a27:	89 50 04             	mov    %edx,0x4(%eax)
  801a2a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    

00801a31 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 10             	sub    $0x10,%esp
  801a39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801a3f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801a44:	b8 08 40 80 00       	mov    $0x804008,%eax
  801a49:	39 0d 08 40 80 00    	cmp    %ecx,0x804008
  801a4f:	75 11                	jne    801a62 <dev_lookup+0x31>
  801a51:	eb 04                	jmp    801a57 <dev_lookup+0x26>
  801a53:	39 08                	cmp    %ecx,(%eax)
  801a55:	75 10                	jne    801a67 <dev_lookup+0x36>
			*dev = devtab[i];
  801a57:	89 03                	mov    %eax,(%ebx)
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801a5e:	66 90                	xchg   %ax,%ax
  801a60:	eb 36                	jmp    801a98 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801a62:	be 28 32 80 00       	mov    $0x803228,%esi
  801a67:	83 c2 01             	add    $0x1,%edx
  801a6a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801a6d:	85 c0                	test   %eax,%eax
  801a6f:	75 e2                	jne    801a53 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801a71:	a1 08 50 80 00       	mov    0x805008,%eax
  801a76:	8b 40 48             	mov    0x48(%eax),%eax
  801a79:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801a7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a81:	c7 04 24 a8 31 80 00 	movl   $0x8031a8,(%esp)
  801a88:	e8 18 ee ff ff       	call   8008a5 <cprintf>
	*dev = 0;
  801a8d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801a98:	83 c4 10             	add    $0x10,%esp
  801a9b:	5b                   	pop    %ebx
  801a9c:	5e                   	pop    %esi
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    

00801a9f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	53                   	push   %ebx
  801aa3:	83 ec 24             	sub    $0x24,%esp
  801aa6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801aa9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab3:	89 04 24             	mov    %eax,(%esp)
  801ab6:	e8 02 ff ff ff       	call   8019bd <fd_lookup>
  801abb:	85 c0                	test   %eax,%eax
  801abd:	78 53                	js     801b12 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801abf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ac6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac9:	8b 00                	mov    (%eax),%eax
  801acb:	89 04 24             	mov    %eax,(%esp)
  801ace:	e8 5e ff ff ff       	call   801a31 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ad3:	85 c0                	test   %eax,%eax
  801ad5:	78 3b                	js     801b12 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801ad7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801adc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801adf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801ae3:	74 2d                	je     801b12 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801ae5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801ae8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801aef:	00 00 00 
	stat->st_isdir = 0;
  801af2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801af9:	00 00 00 
	stat->st_dev = dev;
  801afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801b05:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b09:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b0c:	89 14 24             	mov    %edx,(%esp)
  801b0f:	ff 50 14             	call   *0x14(%eax)
}
  801b12:	83 c4 24             	add    $0x24,%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	53                   	push   %ebx
  801b1c:	83 ec 24             	sub    $0x24,%esp
  801b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b22:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b29:	89 1c 24             	mov    %ebx,(%esp)
  801b2c:	e8 8c fe ff ff       	call   8019bd <fd_lookup>
  801b31:	85 c0                	test   %eax,%eax
  801b33:	78 5f                	js     801b94 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b38:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b3c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3f:	8b 00                	mov    (%eax),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 e8 fe ff ff       	call   801a31 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 47                	js     801b94 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b4d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b50:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801b54:	75 23                	jne    801b79 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801b56:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b5b:	8b 40 48             	mov    0x48(%eax),%eax
  801b5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b66:	c7 04 24 c8 31 80 00 	movl   $0x8031c8,(%esp)
  801b6d:	e8 33 ed ff ff       	call   8008a5 <cprintf>
  801b72:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801b77:	eb 1b                	jmp    801b94 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801b79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7c:	8b 48 18             	mov    0x18(%eax),%ecx
  801b7f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b84:	85 c9                	test   %ecx,%ecx
  801b86:	74 0c                	je     801b94 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8f:	89 14 24             	mov    %edx,(%esp)
  801b92:	ff d1                	call   *%ecx
}
  801b94:	83 c4 24             	add    $0x24,%esp
  801b97:	5b                   	pop    %ebx
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 24             	sub    $0x24,%esp
  801ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ba4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bab:	89 1c 24             	mov    %ebx,(%esp)
  801bae:	e8 0a fe ff ff       	call   8019bd <fd_lookup>
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 66                	js     801c1d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc1:	8b 00                	mov    (%eax),%eax
  801bc3:	89 04 24             	mov    %eax,(%esp)
  801bc6:	e8 66 fe ff ff       	call   801a31 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801bcb:	85 c0                	test   %eax,%eax
  801bcd:	78 4e                	js     801c1d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801bcf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bd2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801bd6:	75 23                	jne    801bfb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801bd8:	a1 08 50 80 00       	mov    0x805008,%eax
  801bdd:	8b 40 48             	mov    0x48(%eax),%eax
  801be0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be8:	c7 04 24 ec 31 80 00 	movl   $0x8031ec,(%esp)
  801bef:	e8 b1 ec ff ff       	call   8008a5 <cprintf>
  801bf4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801bf9:	eb 22                	jmp    801c1d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801bfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfe:	8b 48 0c             	mov    0xc(%eax),%ecx
  801c01:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c06:	85 c9                	test   %ecx,%ecx
  801c08:	74 13                	je     801c1d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801c0a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c14:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c18:	89 14 24             	mov    %edx,(%esp)
  801c1b:	ff d1                	call   *%ecx
}
  801c1d:	83 c4 24             	add    $0x24,%esp
  801c20:	5b                   	pop    %ebx
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 24             	sub    $0x24,%esp
  801c2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c2d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c34:	89 1c 24             	mov    %ebx,(%esp)
  801c37:	e8 81 fd ff ff       	call   8019bd <fd_lookup>
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	78 6b                	js     801cab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801c40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c43:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c47:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c4a:	8b 00                	mov    (%eax),%eax
  801c4c:	89 04 24             	mov    %eax,(%esp)
  801c4f:	e8 dd fd ff ff       	call   801a31 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801c54:	85 c0                	test   %eax,%eax
  801c56:	78 53                	js     801cab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801c58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c5b:	8b 42 08             	mov    0x8(%edx),%eax
  801c5e:	83 e0 03             	and    $0x3,%eax
  801c61:	83 f8 01             	cmp    $0x1,%eax
  801c64:	75 23                	jne    801c89 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801c66:	a1 08 50 80 00       	mov    0x805008,%eax
  801c6b:	8b 40 48             	mov    0x48(%eax),%eax
  801c6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c72:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c76:	c7 04 24 09 32 80 00 	movl   $0x803209,(%esp)
  801c7d:	e8 23 ec ff ff       	call   8008a5 <cprintf>
  801c82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801c87:	eb 22                	jmp    801cab <read+0x88>
	}
	if (!dev->dev_read)
  801c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8c:	8b 48 08             	mov    0x8(%eax),%ecx
  801c8f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c94:	85 c9                	test   %ecx,%ecx
  801c96:	74 13                	je     801cab <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801c98:	8b 45 10             	mov    0x10(%ebp),%eax
  801c9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ca2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ca6:	89 14 24             	mov    %edx,(%esp)
  801ca9:	ff d1                	call   *%ecx
}
  801cab:	83 c4 24             	add    $0x24,%esp
  801cae:	5b                   	pop    %ebx
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    

00801cb1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801cb1:	55                   	push   %ebp
  801cb2:	89 e5                	mov    %esp,%ebp
  801cb4:	57                   	push   %edi
  801cb5:	56                   	push   %esi
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 1c             	sub    $0x1c,%esp
  801cba:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cbd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  801cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccf:	85 f6                	test   %esi,%esi
  801cd1:	74 29                	je     801cfc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801cd3:	89 f0                	mov    %esi,%eax
  801cd5:	29 d0                	sub    %edx,%eax
  801cd7:	89 44 24 08          	mov    %eax,0x8(%esp)
  801cdb:	03 55 0c             	add    0xc(%ebp),%edx
  801cde:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ce2:	89 3c 24             	mov    %edi,(%esp)
  801ce5:	e8 39 ff ff ff       	call   801c23 <read>
		if (m < 0)
  801cea:	85 c0                	test   %eax,%eax
  801cec:	78 0e                	js     801cfc <readn+0x4b>
			return m;
		if (m == 0)
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	74 08                	je     801cfa <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801cf2:	01 c3                	add    %eax,%ebx
  801cf4:	89 da                	mov    %ebx,%edx
  801cf6:	39 f3                	cmp    %esi,%ebx
  801cf8:	72 d9                	jb     801cd3 <readn+0x22>
  801cfa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801cfc:	83 c4 1c             	add    $0x1c,%esp
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	83 ec 28             	sub    $0x28,%esp
  801d0a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d0d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d10:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801d13:	89 34 24             	mov    %esi,(%esp)
  801d16:	e8 05 fc ff ff       	call   801920 <fd2num>
  801d1b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d1e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d22:	89 04 24             	mov    %eax,(%esp)
  801d25:	e8 93 fc ff ff       	call   8019bd <fd_lookup>
  801d2a:	89 c3                	mov    %eax,%ebx
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 05                	js     801d35 <fd_close+0x31>
  801d30:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d33:	74 0e                	je     801d43 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801d35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3e:	0f 44 d8             	cmove  %eax,%ebx
  801d41:	eb 3d                	jmp    801d80 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d43:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d46:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d4a:	8b 06                	mov    (%esi),%eax
  801d4c:	89 04 24             	mov    %eax,(%esp)
  801d4f:	e8 dd fc ff ff       	call   801a31 <dev_lookup>
  801d54:	89 c3                	mov    %eax,%ebx
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 16                	js     801d70 <fd_close+0x6c>
		if (dev->dev_close)
  801d5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5d:	8b 40 10             	mov    0x10(%eax),%eax
  801d60:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d65:	85 c0                	test   %eax,%eax
  801d67:	74 07                	je     801d70 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801d69:	89 34 24             	mov    %esi,(%esp)
  801d6c:	ff d0                	call   *%eax
  801d6e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d70:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d74:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d7b:	e8 5c f8 ff ff       	call   8015dc <sys_page_unmap>
	return r;
}
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d85:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d88:	89 ec                	mov    %ebp,%esp
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    

00801d8c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d8c:	55                   	push   %ebp
  801d8d:	89 e5                	mov    %esp,%ebp
  801d8f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d92:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 19 fc ff ff       	call   8019bd <fd_lookup>
  801da4:	85 c0                	test   %eax,%eax
  801da6:	78 13                	js     801dbb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801da8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801daf:	00 
  801db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db3:	89 04 24             	mov    %eax,(%esp)
  801db6:	e8 49 ff ff ff       	call   801d04 <fd_close>
}
  801dbb:	c9                   	leave  
  801dbc:	c3                   	ret    

00801dbd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	83 ec 18             	sub    $0x18,%esp
  801dc3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801dc6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801dc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dd0:	00 
  801dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd4:	89 04 24             	mov    %eax,(%esp)
  801dd7:	e8 78 03 00 00       	call   802154 <open>
  801ddc:	89 c3                	mov    %eax,%ebx
  801dde:	85 c0                	test   %eax,%eax
  801de0:	78 1b                	js     801dfd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801de2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801de9:	89 1c 24             	mov    %ebx,(%esp)
  801dec:	e8 ae fc ff ff       	call   801a9f <fstat>
  801df1:	89 c6                	mov    %eax,%esi
	close(fd);
  801df3:	89 1c 24             	mov    %ebx,(%esp)
  801df6:	e8 91 ff ff ff       	call   801d8c <close>
  801dfb:	89 f3                	mov    %esi,%ebx
	return r;
}
  801dfd:	89 d8                	mov    %ebx,%eax
  801dff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e02:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e05:	89 ec                	mov    %ebp,%esp
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 14             	sub    $0x14,%esp
  801e10:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801e15:	89 1c 24             	mov    %ebx,(%esp)
  801e18:	e8 6f ff ff ff       	call   801d8c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801e1d:	83 c3 01             	add    $0x1,%ebx
  801e20:	83 fb 20             	cmp    $0x20,%ebx
  801e23:	75 f0                	jne    801e15 <close_all+0xc>
		close(i);
}
  801e25:	83 c4 14             	add    $0x14,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 58             	sub    $0x58,%esp
  801e31:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801e34:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801e37:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801e3a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801e3d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e40:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e44:	8b 45 08             	mov    0x8(%ebp),%eax
  801e47:	89 04 24             	mov    %eax,(%esp)
  801e4a:	e8 6e fb ff ff       	call   8019bd <fd_lookup>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	85 c0                	test   %eax,%eax
  801e53:	0f 88 e0 00 00 00    	js     801f39 <dup+0x10e>
		return r;
	close(newfdnum);
  801e59:	89 3c 24             	mov    %edi,(%esp)
  801e5c:	e8 2b ff ff ff       	call   801d8c <close>

	newfd = INDEX2FD(newfdnum);
  801e61:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801e67:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801e6a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e6d:	89 04 24             	mov    %eax,(%esp)
  801e70:	e8 bb fa ff ff       	call   801930 <fd2data>
  801e75:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801e77:	89 34 24             	mov    %esi,(%esp)
  801e7a:	e8 b1 fa ff ff       	call   801930 <fd2data>
  801e7f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801e82:	89 da                	mov    %ebx,%edx
  801e84:	89 d8                	mov    %ebx,%eax
  801e86:	c1 e8 16             	shr    $0x16,%eax
  801e89:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e90:	a8 01                	test   $0x1,%al
  801e92:	74 43                	je     801ed7 <dup+0xac>
  801e94:	c1 ea 0c             	shr    $0xc,%edx
  801e97:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801e9e:	a8 01                	test   $0x1,%al
  801ea0:	74 35                	je     801ed7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801ea2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801ea9:	25 07 0e 00 00       	and    $0xe07,%eax
  801eae:	89 44 24 10          	mov    %eax,0x10(%esp)
  801eb2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801eb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ec0:	00 
  801ec1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ec5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ecc:	e8 43 f7 ff ff       	call   801614 <sys_page_map>
  801ed1:	89 c3                	mov    %eax,%ebx
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 3f                	js     801f16 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ed7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801eda:	89 c2                	mov    %eax,%edx
  801edc:	c1 ea 0c             	shr    $0xc,%edx
  801edf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ee6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801eec:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ef0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ef4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801efb:	00 
  801efc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f07:	e8 08 f7 ff ff       	call   801614 <sys_page_map>
  801f0c:	89 c3                	mov    %eax,%ebx
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	78 04                	js     801f16 <dup+0xeb>
  801f12:	89 fb                	mov    %edi,%ebx
  801f14:	eb 23                	jmp    801f39 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f1a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f21:	e8 b6 f6 ff ff       	call   8015dc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801f26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801f29:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f2d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f34:	e8 a3 f6 ff ff       	call   8015dc <sys_page_unmap>
	return r;
}
  801f39:	89 d8                	mov    %ebx,%eax
  801f3b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801f3e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801f41:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801f44:	89 ec                	mov    %ebp,%esp
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    

00801f48 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	83 ec 18             	sub    $0x18,%esp
  801f4e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f51:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f54:	89 c3                	mov    %eax,%ebx
  801f56:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801f58:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801f5f:	75 11                	jne    801f72 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801f61:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801f68:	e8 73 f8 ff ff       	call   8017e0 <ipc_find_env>
  801f6d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801f72:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801f79:	00 
  801f7a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801f81:	00 
  801f82:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f86:	a1 00 50 80 00       	mov    0x805000,%eax
  801f8b:	89 04 24             	mov    %eax,(%esp)
  801f8e:	e8 91 f8 ff ff       	call   801824 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801f93:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f9a:	00 
  801f9b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa6:	e8 e4 f8 ff ff       	call   80188f <ipc_recv>
}
  801fab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fb1:	89 ec                	mov    %ebp,%esp
  801fb3:	5d                   	pop    %ebp
  801fb4:	c3                   	ret    

00801fb5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	8b 40 0c             	mov    0xc(%eax),%eax
  801fc1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc9:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801fce:	ba 00 00 00 00       	mov    $0x0,%edx
  801fd3:	b8 02 00 00 00       	mov    $0x2,%eax
  801fd8:	e8 6b ff ff ff       	call   801f48 <fsipc>
}
  801fdd:	c9                   	leave  
  801fde:	c3                   	ret    

00801fdf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe8:	8b 40 0c             	mov    0xc(%eax),%eax
  801feb:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ff0:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff5:	b8 06 00 00 00       	mov    $0x6,%eax
  801ffa:	e8 49 ff ff ff       	call   801f48 <fsipc>
}
  801fff:	c9                   	leave  
  802000:	c3                   	ret    

00802001 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802007:	ba 00 00 00 00       	mov    $0x0,%edx
  80200c:	b8 08 00 00 00       	mov    $0x8,%eax
  802011:	e8 32 ff ff ff       	call   801f48 <fsipc>
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802018:	55                   	push   %ebp
  802019:	89 e5                	mov    %esp,%ebp
  80201b:	53                   	push   %ebx
  80201c:	83 ec 14             	sub    $0x14,%esp
  80201f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802022:	8b 45 08             	mov    0x8(%ebp),%eax
  802025:	8b 40 0c             	mov    0xc(%eax),%eax
  802028:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80202d:	ba 00 00 00 00       	mov    $0x0,%edx
  802032:	b8 05 00 00 00       	mov    $0x5,%eax
  802037:	e8 0c ff ff ff       	call   801f48 <fsipc>
  80203c:	85 c0                	test   %eax,%eax
  80203e:	78 2b                	js     80206b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802040:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802047:	00 
  802048:	89 1c 24             	mov    %ebx,(%esp)
  80204b:	e8 9a ef ff ff       	call   800fea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802050:	a1 80 60 80 00       	mov    0x806080,%eax
  802055:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80205b:	a1 84 60 80 00       	mov    0x806084,%eax
  802060:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  802066:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80206b:	83 c4 14             	add    $0x14,%esp
  80206e:	5b                   	pop    %ebx
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    

00802071 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	83 ec 18             	sub    $0x18,%esp
  802077:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80207a:	8b 55 08             	mov    0x8(%ebp),%edx
  80207d:	8b 52 0c             	mov    0xc(%edx),%edx
  802080:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  802086:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  80208b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802090:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802095:	0f 47 c2             	cmova  %edx,%eax
  802098:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80209f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a3:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  8020aa:	e8 26 f1 ff ff       	call   8011d5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8020af:	ba 00 00 00 00       	mov    $0x0,%edx
  8020b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8020b9:	e8 8a fe ff ff       	call   801f48 <fsipc>
}
  8020be:	c9                   	leave  
  8020bf:	c3                   	ret    

008020c0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8020c0:	55                   	push   %ebp
  8020c1:	89 e5                	mov    %esp,%ebp
  8020c3:	53                   	push   %ebx
  8020c4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8020cd:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  8020d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020d5:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8020da:	ba 00 00 00 00       	mov    $0x0,%edx
  8020df:	b8 03 00 00 00       	mov    $0x3,%eax
  8020e4:	e8 5f fe ff ff       	call   801f48 <fsipc>
  8020e9:	89 c3                	mov    %eax,%ebx
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	78 17                	js     802106 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8020ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020f3:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8020fa:	00 
  8020fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fe:	89 04 24             	mov    %eax,(%esp)
  802101:	e8 cf f0 ff ff       	call   8011d5 <memmove>
  return r;	
}
  802106:	89 d8                	mov    %ebx,%eax
  802108:	83 c4 14             	add    $0x14,%esp
  80210b:	5b                   	pop    %ebx
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    

0080210e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	53                   	push   %ebx
  802112:	83 ec 14             	sub    $0x14,%esp
  802115:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  802118:	89 1c 24             	mov    %ebx,(%esp)
  80211b:	e8 80 ee ff ff       	call   800fa0 <strlen>
  802120:	89 c2                	mov    %eax,%edx
  802122:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  802127:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80212d:	7f 1f                	jg     80214e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80212f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802133:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  80213a:	e8 ab ee ff ff       	call   800fea <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80213f:	ba 00 00 00 00       	mov    $0x0,%edx
  802144:	b8 07 00 00 00       	mov    $0x7,%eax
  802149:	e8 fa fd ff ff       	call   801f48 <fsipc>
}
  80214e:	83 c4 14             	add    $0x14,%esp
  802151:	5b                   	pop    %ebx
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    

00802154 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802154:	55                   	push   %ebp
  802155:	89 e5                	mov    %esp,%ebp
  802157:	83 ec 28             	sub    $0x28,%esp
  80215a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80215d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  802160:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  802163:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802166:	89 04 24             	mov    %eax,(%esp)
  802169:	e8 dd f7 ff ff       	call   80194b <fd_alloc>
  80216e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  802170:	85 c0                	test   %eax,%eax
  802172:	0f 88 89 00 00 00    	js     802201 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  802178:	89 34 24             	mov    %esi,(%esp)
  80217b:	e8 20 ee ff ff       	call   800fa0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  802180:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  802185:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80218a:	7f 75                	jg     802201 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80218c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802190:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802197:	e8 4e ee ff ff       	call   800fea <strcpy>
  fsipcbuf.open.req_omode = mode;
  80219c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80219f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  8021a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ac:	e8 97 fd ff ff       	call   801f48 <fsipc>
  8021b1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8021b3:	85 c0                	test   %eax,%eax
  8021b5:	78 0f                	js     8021c6 <open+0x72>
  return fd2num(fd);
  8021b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ba:	89 04 24             	mov    %eax,(%esp)
  8021bd:	e8 5e f7 ff ff       	call   801920 <fd2num>
  8021c2:	89 c3                	mov    %eax,%ebx
  8021c4:	eb 3b                	jmp    802201 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8021c6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8021cd:	00 
  8021ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d1:	89 04 24             	mov    %eax,(%esp)
  8021d4:	e8 2b fb ff ff       	call   801d04 <fd_close>
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	74 24                	je     802201 <open+0xad>
  8021dd:	c7 44 24 0c 34 32 80 	movl   $0x803234,0xc(%esp)
  8021e4:	00 
  8021e5:	c7 44 24 08 49 32 80 	movl   $0x803249,0x8(%esp)
  8021ec:	00 
  8021ed:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8021f4:	00 
  8021f5:	c7 04 24 5e 32 80 00 	movl   $0x80325e,(%esp)
  8021fc:	e8 eb e5 ff ff       	call   8007ec <_panic>
  return r;
}
  802201:	89 d8                	mov    %ebx,%eax
  802203:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802206:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802209:	89 ec                	mov    %ebp,%esp
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    
  80220d:	00 00                	add    %al,(%eax)
	...

00802210 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802210:	55                   	push   %ebp
  802211:	89 e5                	mov    %esp,%ebp
  802213:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802216:	c7 44 24 04 69 32 80 	movl   $0x803269,0x4(%esp)
  80221d:	00 
  80221e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802221:	89 04 24             	mov    %eax,(%esp)
  802224:	e8 c1 ed ff ff       	call   800fea <strcpy>
	return 0;
}
  802229:	b8 00 00 00 00       	mov    $0x0,%eax
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    

00802230 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  802230:	55                   	push   %ebp
  802231:	89 e5                	mov    %esp,%ebp
  802233:	53                   	push   %ebx
  802234:	83 ec 14             	sub    $0x14,%esp
  802237:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80223a:	89 1c 24             	mov    %ebx,(%esp)
  80223d:	e8 d2 04 00 00       	call   802714 <pageref>
  802242:	89 c2                	mov    %eax,%edx
  802244:	b8 00 00 00 00       	mov    $0x0,%eax
  802249:	83 fa 01             	cmp    $0x1,%edx
  80224c:	75 0b                	jne    802259 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80224e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802251:	89 04 24             	mov    %eax,(%esp)
  802254:	e8 b9 02 00 00       	call   802512 <nsipc_close>
	else
		return 0;
}
  802259:	83 c4 14             	add    $0x14,%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5d                   	pop    %ebp
  80225e:	c3                   	ret    

0080225f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80225f:	55                   	push   %ebp
  802260:	89 e5                	mov    %esp,%ebp
  802262:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802265:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80226c:	00 
  80226d:	8b 45 10             	mov    0x10(%ebp),%eax
  802270:	89 44 24 08          	mov    %eax,0x8(%esp)
  802274:	8b 45 0c             	mov    0xc(%ebp),%eax
  802277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80227b:	8b 45 08             	mov    0x8(%ebp),%eax
  80227e:	8b 40 0c             	mov    0xc(%eax),%eax
  802281:	89 04 24             	mov    %eax,(%esp)
  802284:	e8 c5 02 00 00       	call   80254e <nsipc_send>
}
  802289:	c9                   	leave  
  80228a:	c3                   	ret    

0080228b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80228b:	55                   	push   %ebp
  80228c:	89 e5                	mov    %esp,%ebp
  80228e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802291:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802298:	00 
  802299:	8b 45 10             	mov    0x10(%ebp),%eax
  80229c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8022aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ad:	89 04 24             	mov    %eax,(%esp)
  8022b0:	e8 0c 03 00 00       	call   8025c1 <nsipc_recv>
}
  8022b5:	c9                   	leave  
  8022b6:	c3                   	ret    

008022b7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8022b7:	55                   	push   %ebp
  8022b8:	89 e5                	mov    %esp,%ebp
  8022ba:	56                   	push   %esi
  8022bb:	53                   	push   %ebx
  8022bc:	83 ec 20             	sub    $0x20,%esp
  8022bf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c4:	89 04 24             	mov    %eax,(%esp)
  8022c7:	e8 7f f6 ff ff       	call   80194b <fd_alloc>
  8022cc:	89 c3                	mov    %eax,%ebx
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	78 21                	js     8022f3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8022d2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8022d9:	00 
  8022da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8022e8:	e8 60 f3 ff ff       	call   80164d <sys_page_alloc>
  8022ed:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8022ef:	85 c0                	test   %eax,%eax
  8022f1:	79 0a                	jns    8022fd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  8022f3:	89 34 24             	mov    %esi,(%esp)
  8022f6:	e8 17 02 00 00       	call   802512 <nsipc_close>
		return r;
  8022fb:	eb 28                	jmp    802325 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8022fd:	8b 15 24 40 80 00    	mov    0x804024,%edx
  802303:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802306:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802308:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802312:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802315:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80231b:	89 04 24             	mov    %eax,(%esp)
  80231e:	e8 fd f5 ff ff       	call   801920 <fd2num>
  802323:	89 c3                	mov    %eax,%ebx
}
  802325:	89 d8                	mov    %ebx,%eax
  802327:	83 c4 20             	add    $0x20,%esp
  80232a:	5b                   	pop    %ebx
  80232b:	5e                   	pop    %esi
  80232c:	5d                   	pop    %ebp
  80232d:	c3                   	ret    

0080232e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80232e:	55                   	push   %ebp
  80232f:	89 e5                	mov    %esp,%ebp
  802331:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  802334:	8b 45 10             	mov    0x10(%ebp),%eax
  802337:	89 44 24 08          	mov    %eax,0x8(%esp)
  80233b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80233e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802342:	8b 45 08             	mov    0x8(%ebp),%eax
  802345:	89 04 24             	mov    %eax,(%esp)
  802348:	e8 79 01 00 00       	call   8024c6 <nsipc_socket>
  80234d:	85 c0                	test   %eax,%eax
  80234f:	78 05                	js     802356 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802351:	e8 61 ff ff ff       	call   8022b7 <alloc_sockfd>
}
  802356:	c9                   	leave  
  802357:	c3                   	ret    

00802358 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802358:	55                   	push   %ebp
  802359:	89 e5                	mov    %esp,%ebp
  80235b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80235e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802361:	89 54 24 04          	mov    %edx,0x4(%esp)
  802365:	89 04 24             	mov    %eax,(%esp)
  802368:	e8 50 f6 ff ff       	call   8019bd <fd_lookup>
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 15                	js     802386 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802371:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802374:	8b 0a                	mov    (%edx),%ecx
  802376:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80237b:	3b 0d 24 40 80 00    	cmp    0x804024,%ecx
  802381:	75 03                	jne    802386 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802383:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802386:	c9                   	leave  
  802387:	c3                   	ret    

00802388 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802388:	55                   	push   %ebp
  802389:	89 e5                	mov    %esp,%ebp
  80238b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80238e:	8b 45 08             	mov    0x8(%ebp),%eax
  802391:	e8 c2 ff ff ff       	call   802358 <fd2sockid>
  802396:	85 c0                	test   %eax,%eax
  802398:	78 0f                	js     8023a9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80239a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80239d:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023a1:	89 04 24             	mov    %eax,(%esp)
  8023a4:	e8 47 01 00 00       	call   8024f0 <nsipc_listen>
}
  8023a9:	c9                   	leave  
  8023aa:	c3                   	ret    

008023ab <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b4:	e8 9f ff ff ff       	call   802358 <fd2sockid>
  8023b9:	85 c0                	test   %eax,%eax
  8023bb:	78 16                	js     8023d3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  8023bd:	8b 55 10             	mov    0x10(%ebp),%edx
  8023c0:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023c7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023cb:	89 04 24             	mov    %eax,(%esp)
  8023ce:	e8 6e 02 00 00       	call   802641 <nsipc_connect>
}
  8023d3:	c9                   	leave  
  8023d4:	c3                   	ret    

008023d5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023db:	8b 45 08             	mov    0x8(%ebp),%eax
  8023de:	e8 75 ff ff ff       	call   802358 <fd2sockid>
  8023e3:	85 c0                	test   %eax,%eax
  8023e5:	78 0f                	js     8023f6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8023e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023ea:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023ee:	89 04 24             	mov    %eax,(%esp)
  8023f1:	e8 36 01 00 00       	call   80252c <nsipc_shutdown>
}
  8023f6:	c9                   	leave  
  8023f7:	c3                   	ret    

008023f8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8023f8:	55                   	push   %ebp
  8023f9:	89 e5                	mov    %esp,%ebp
  8023fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8023fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802401:	e8 52 ff ff ff       	call   802358 <fd2sockid>
  802406:	85 c0                	test   %eax,%eax
  802408:	78 16                	js     802420 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80240a:	8b 55 10             	mov    0x10(%ebp),%edx
  80240d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802411:	8b 55 0c             	mov    0xc(%ebp),%edx
  802414:	89 54 24 04          	mov    %edx,0x4(%esp)
  802418:	89 04 24             	mov    %eax,(%esp)
  80241b:	e8 60 02 00 00       	call   802680 <nsipc_bind>
}
  802420:	c9                   	leave  
  802421:	c3                   	ret    

00802422 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802422:	55                   	push   %ebp
  802423:	89 e5                	mov    %esp,%ebp
  802425:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802428:	8b 45 08             	mov    0x8(%ebp),%eax
  80242b:	e8 28 ff ff ff       	call   802358 <fd2sockid>
  802430:	85 c0                	test   %eax,%eax
  802432:	78 1f                	js     802453 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802434:	8b 55 10             	mov    0x10(%ebp),%edx
  802437:	89 54 24 08          	mov    %edx,0x8(%esp)
  80243b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80243e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802442:	89 04 24             	mov    %eax,(%esp)
  802445:	e8 75 02 00 00       	call   8026bf <nsipc_accept>
  80244a:	85 c0                	test   %eax,%eax
  80244c:	78 05                	js     802453 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80244e:	e8 64 fe ff ff       	call   8022b7 <alloc_sockfd>
}
  802453:	c9                   	leave  
  802454:	c3                   	ret    
	...

00802460 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802460:	55                   	push   %ebp
  802461:	89 e5                	mov    %esp,%ebp
  802463:	53                   	push   %ebx
  802464:	83 ec 14             	sub    $0x14,%esp
  802467:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802469:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802470:	75 11                	jne    802483 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802472:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802479:	e8 62 f3 ff ff       	call   8017e0 <ipc_find_env>
  80247e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802483:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80248a:	00 
  80248b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802492:	00 
  802493:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802497:	a1 04 50 80 00       	mov    0x805004,%eax
  80249c:	89 04 24             	mov    %eax,(%esp)
  80249f:	e8 80 f3 ff ff       	call   801824 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8024a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8024ab:	00 
  8024ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8024b3:	00 
  8024b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8024bb:	e8 cf f3 ff ff       	call   80188f <ipc_recv>
}
  8024c0:	83 c4 14             	add    $0x14,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5d                   	pop    %ebp
  8024c5:	c3                   	ret    

008024c6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8024c6:	55                   	push   %ebp
  8024c7:	89 e5                	mov    %esp,%ebp
  8024c9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8024cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8024d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024d7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8024dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8024df:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8024e4:	b8 09 00 00 00       	mov    $0x9,%eax
  8024e9:	e8 72 ff ff ff       	call   802460 <nsipc>
}
  8024ee:	c9                   	leave  
  8024ef:	c3                   	ret    

008024f0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8024f0:	55                   	push   %ebp
  8024f1:	89 e5                	mov    %esp,%ebp
  8024f3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8024f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8024f9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8024fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  802501:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802506:	b8 06 00 00 00       	mov    $0x6,%eax
  80250b:	e8 50 ff ff ff       	call   802460 <nsipc>
}
  802510:	c9                   	leave  
  802511:	c3                   	ret    

00802512 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802512:	55                   	push   %ebp
  802513:	89 e5                	mov    %esp,%ebp
  802515:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802520:	b8 04 00 00 00       	mov    $0x4,%eax
  802525:	e8 36 ff ff ff       	call   802460 <nsipc>
}
  80252a:	c9                   	leave  
  80252b:	c3                   	ret    

0080252c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802532:	8b 45 08             	mov    0x8(%ebp),%eax
  802535:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80253a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80253d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802542:	b8 03 00 00 00       	mov    $0x3,%eax
  802547:	e8 14 ff ff ff       	call   802460 <nsipc>
}
  80254c:	c9                   	leave  
  80254d:	c3                   	ret    

0080254e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80254e:	55                   	push   %ebp
  80254f:	89 e5                	mov    %esp,%ebp
  802551:	53                   	push   %ebx
  802552:	83 ec 14             	sub    $0x14,%esp
  802555:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802558:	8b 45 08             	mov    0x8(%ebp),%eax
  80255b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802560:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802566:	7e 24                	jle    80258c <nsipc_send+0x3e>
  802568:	c7 44 24 0c 75 32 80 	movl   $0x803275,0xc(%esp)
  80256f:	00 
  802570:	c7 44 24 08 49 32 80 	movl   $0x803249,0x8(%esp)
  802577:	00 
  802578:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80257f:	00 
  802580:	c7 04 24 81 32 80 00 	movl   $0x803281,(%esp)
  802587:	e8 60 e2 ff ff       	call   8007ec <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80258c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802590:	8b 45 0c             	mov    0xc(%ebp),%eax
  802593:	89 44 24 04          	mov    %eax,0x4(%esp)
  802597:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80259e:	e8 32 ec ff ff       	call   8011d5 <memmove>
	nsipcbuf.send.req_size = size;
  8025a3:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8025a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8025ac:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8025b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8025b6:	e8 a5 fe ff ff       	call   802460 <nsipc>
}
  8025bb:	83 c4 14             	add    $0x14,%esp
  8025be:	5b                   	pop    %ebx
  8025bf:	5d                   	pop    %ebp
  8025c0:	c3                   	ret    

008025c1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8025c1:	55                   	push   %ebp
  8025c2:	89 e5                	mov    %esp,%ebp
  8025c4:	56                   	push   %esi
  8025c5:	53                   	push   %ebx
  8025c6:	83 ec 10             	sub    $0x10,%esp
  8025c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8025cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8025cf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8025d4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8025da:	8b 45 14             	mov    0x14(%ebp),%eax
  8025dd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8025e2:	b8 07 00 00 00       	mov    $0x7,%eax
  8025e7:	e8 74 fe ff ff       	call   802460 <nsipc>
  8025ec:	89 c3                	mov    %eax,%ebx
  8025ee:	85 c0                	test   %eax,%eax
  8025f0:	78 46                	js     802638 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8025f2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8025f7:	7f 04                	jg     8025fd <nsipc_recv+0x3c>
  8025f9:	39 c6                	cmp    %eax,%esi
  8025fb:	7d 24                	jge    802621 <nsipc_recv+0x60>
  8025fd:	c7 44 24 0c 8d 32 80 	movl   $0x80328d,0xc(%esp)
  802604:	00 
  802605:	c7 44 24 08 49 32 80 	movl   $0x803249,0x8(%esp)
  80260c:	00 
  80260d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802614:	00 
  802615:	c7 04 24 81 32 80 00 	movl   $0x803281,(%esp)
  80261c:	e8 cb e1 ff ff       	call   8007ec <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802621:	89 44 24 08          	mov    %eax,0x8(%esp)
  802625:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80262c:	00 
  80262d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802630:	89 04 24             	mov    %eax,(%esp)
  802633:	e8 9d eb ff ff       	call   8011d5 <memmove>
	}

	return r;
}
  802638:	89 d8                	mov    %ebx,%eax
  80263a:	83 c4 10             	add    $0x10,%esp
  80263d:	5b                   	pop    %ebx
  80263e:	5e                   	pop    %esi
  80263f:	5d                   	pop    %ebp
  802640:	c3                   	ret    

00802641 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802641:	55                   	push   %ebp
  802642:	89 e5                	mov    %esp,%ebp
  802644:	53                   	push   %ebx
  802645:	83 ec 14             	sub    $0x14,%esp
  802648:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80264b:	8b 45 08             	mov    0x8(%ebp),%eax
  80264e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802653:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802657:	8b 45 0c             	mov    0xc(%ebp),%eax
  80265a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80265e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802665:	e8 6b eb ff ff       	call   8011d5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80266a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802670:	b8 05 00 00 00       	mov    $0x5,%eax
  802675:	e8 e6 fd ff ff       	call   802460 <nsipc>
}
  80267a:	83 c4 14             	add    $0x14,%esp
  80267d:	5b                   	pop    %ebx
  80267e:	5d                   	pop    %ebp
  80267f:	c3                   	ret    

00802680 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802680:	55                   	push   %ebp
  802681:	89 e5                	mov    %esp,%ebp
  802683:	53                   	push   %ebx
  802684:	83 ec 14             	sub    $0x14,%esp
  802687:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80268a:	8b 45 08             	mov    0x8(%ebp),%eax
  80268d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802692:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802696:	8b 45 0c             	mov    0xc(%ebp),%eax
  802699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80269d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8026a4:	e8 2c eb ff ff       	call   8011d5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8026a9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8026af:	b8 02 00 00 00       	mov    $0x2,%eax
  8026b4:	e8 a7 fd ff ff       	call   802460 <nsipc>
}
  8026b9:	83 c4 14             	add    $0x14,%esp
  8026bc:	5b                   	pop    %ebx
  8026bd:	5d                   	pop    %ebp
  8026be:	c3                   	ret    

008026bf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8026bf:	55                   	push   %ebp
  8026c0:	89 e5                	mov    %esp,%ebp
  8026c2:	83 ec 18             	sub    $0x18,%esp
  8026c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8026c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8026cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8026ce:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8026d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8026d8:	e8 83 fd ff ff       	call   802460 <nsipc>
  8026dd:	89 c3                	mov    %eax,%ebx
  8026df:	85 c0                	test   %eax,%eax
  8026e1:	78 25                	js     802708 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8026e3:	be 10 70 80 00       	mov    $0x807010,%esi
  8026e8:	8b 06                	mov    (%esi),%eax
  8026ea:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026ee:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8026f5:	00 
  8026f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f9:	89 04 24             	mov    %eax,(%esp)
  8026fc:	e8 d4 ea ff ff       	call   8011d5 <memmove>
		*addrlen = ret->ret_addrlen;
  802701:	8b 16                	mov    (%esi),%edx
  802703:	8b 45 10             	mov    0x10(%ebp),%eax
  802706:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802708:	89 d8                	mov    %ebx,%eax
  80270a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80270d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802710:	89 ec                	mov    %ebp,%esp
  802712:	5d                   	pop    %ebp
  802713:	c3                   	ret    

00802714 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802714:	55                   	push   %ebp
  802715:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802717:	8b 45 08             	mov    0x8(%ebp),%eax
  80271a:	89 c2                	mov    %eax,%edx
  80271c:	c1 ea 16             	shr    $0x16,%edx
  80271f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802726:	f6 c2 01             	test   $0x1,%dl
  802729:	74 20                	je     80274b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80272b:	c1 e8 0c             	shr    $0xc,%eax
  80272e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802735:	a8 01                	test   $0x1,%al
  802737:	74 12                	je     80274b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802739:	c1 e8 0c             	shr    $0xc,%eax
  80273c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802741:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802746:	0f b7 c0             	movzwl %ax,%eax
  802749:	eb 05                	jmp    802750 <pageref+0x3c>
  80274b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802750:	5d                   	pop    %ebp
  802751:	c3                   	ret    
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
