
obj/net/testinput:     file format elf32-i386


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
  80002c:	e8 67 05 00 00       	call   800598 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	81 ec ac 00 00 00    	sub    $0xac,%esp
	envid_t ns_envid = sys_getenvid();
  80004c:	e8 b6 14 00 00       	call   801507 <sys_getenvid>
  800051:	89 c3                	mov    %eax,%ebx
	int i, r, first = 1;

	binaryname = "testinput";
  800053:	c7 05 00 40 80 00 00 	movl   $0x803000,0x804000
  80005a:	30 80 00 

	output_envid = fork();
  80005d:	e8 b0 15 00 00       	call   801612 <fork>
  800062:	a3 00 50 80 00       	mov    %eax,0x805000
	if (output_envid < 0)
  800067:	85 c0                	test   %eax,%eax
  800069:	79 1c                	jns    800087 <umain+0x47>
		panic("error forking");
  80006b:	c7 44 24 08 0a 30 80 	movl   $0x80300a,0x8(%esp)
  800072:	00 
  800073:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  80007a:	00 
  80007b:	c7 04 24 18 30 80 00 	movl   $0x803018,(%esp)
  800082:	e8 7d 05 00 00       	call   800604 <_panic>
	else if (output_envid == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 0d                	jne    800098 <umain+0x58>
		output(ns_envid);
  80008b:	89 1c 24             	mov    %ebx,(%esp)
  80008e:	e8 b5 04 00 00       	call   800548 <output>
		return;
  800093:	e9 c7 03 00 00       	jmp    80045f <umain+0x41f>
	}

	input_envid = fork();
  800098:	e8 75 15 00 00       	call   801612 <fork>
  80009d:	a3 04 50 80 00       	mov    %eax,0x805004
	if (input_envid < 0)
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	79 1c                	jns    8000c2 <umain+0x82>
		panic("error forking");
  8000a6:	c7 44 24 08 0a 30 80 	movl   $0x80300a,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 18 30 80 00 	movl   $0x803018,(%esp)
  8000bd:	e8 42 05 00 00       	call   800604 <_panic>
	else if (input_envid == 0) {
  8000c2:	85 c0                	test   %eax,%eax
  8000c4:	75 0f                	jne    8000d5 <umain+0x95>
		input(ns_envid);
  8000c6:	89 1c 24             	mov    %ebx,(%esp)
  8000c9:	e8 6a 04 00 00       	call   800538 <input>
  8000ce:	66 90                	xchg   %ax,%ax
  8000d0:	e9 8a 03 00 00       	jmp    80045f <umain+0x41f>
		return;
	}

	cprintf("Sending ARP announcement...\n");
  8000d5:	c7 04 24 28 30 80 00 	movl   $0x803028,(%esp)
  8000dc:	e8 dc 05 00 00       	call   8006bd <cprintf>
	// with ARP requests.  Ideally, we would use gratuitous ARP
	// for this, but QEMU's ARP implementation is dumb and only
	// listens for very specific ARP requests, such as requests
	// for the gateway IP.

	uint8_t mac[6] = {0x52, 0x54, 0x00, 0x12, 0x34, 0x56};
  8000e1:	c6 45 90 52          	movb   $0x52,-0x70(%ebp)
  8000e5:	c6 45 91 54          	movb   $0x54,-0x6f(%ebp)
  8000e9:	c6 45 92 00          	movb   $0x0,-0x6e(%ebp)
  8000ed:	c6 45 93 12          	movb   $0x12,-0x6d(%ebp)
  8000f1:	c6 45 94 34          	movb   $0x34,-0x6c(%ebp)
  8000f5:	c6 45 95 56          	movb   $0x56,-0x6b(%ebp)
	uint32_t myip = inet_addr(IP);
  8000f9:	c7 04 24 45 30 80 00 	movl   $0x803045,(%esp)
  800100:	e8 4b 2c 00 00       	call   802d50 <inet_addr>
  800105:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t gwip = inet_addr(DEFAULT);
  800108:	c7 04 24 4f 30 80 00 	movl   $0x80304f,(%esp)
  80010f:	e8 3c 2c 00 00       	call   802d50 <inet_addr>
  800114:	89 45 e0             	mov    %eax,-0x20(%ebp)
	int r;

	if ((r = sys_page_alloc(0, pkt, PTE_P|PTE_U|PTE_W)) < 0)
  800117:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80011e:	00 
  80011f:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800126:	0f 
  800127:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012e:	e8 2a 13 00 00       	call   80145d <sys_page_alloc>
  800133:	85 c0                	test   %eax,%eax
  800135:	79 20                	jns    800157 <umain+0x117>
		panic("sys_page_map: %e", r);
  800137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80013b:	c7 44 24 08 58 30 80 	movl   $0x803058,0x8(%esp)
  800142:	00 
  800143:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80014a:	00 
  80014b:	c7 04 24 18 30 80 00 	movl   $0x803018,(%esp)
  800152:	e8 ad 04 00 00       	call   800604 <_panic>

	struct etharp_hdr *arp = (struct etharp_hdr*)pkt->jp_data;
  800157:	bb 04 b0 fe 0f       	mov    $0xffeb004,%ebx
	pkt->jp_len = sizeof(*arp);
  80015c:	c7 05 00 b0 fe 0f 2a 	movl   $0x2a,0xffeb000
  800163:	00 00 00 

	memset(arp->ethhdr.dest.addr, 0xff, ETHARP_HWADDR_LEN);
  800166:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  80016d:	00 
  80016e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800175:	00 
  800176:	c7 04 24 04 b0 fe 0f 	movl   $0xffeb004,(%esp)
  80017d:	e8 04 0e 00 00       	call   800f86 <memset>
	memcpy(arp->ethhdr.src.addr,  mac,  ETHARP_HWADDR_LEN);
  800182:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800189:	00 
  80018a:	8d 75 90             	lea    -0x70(%ebp),%esi
  80018d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800191:	c7 04 24 0a b0 fe 0f 	movl   $0xffeb00a,(%esp)
  800198:	e8 c4 0e 00 00       	call   801061 <memcpy>
	arp->ethhdr.type = htons(ETHTYPE_ARP);
  80019d:	c7 04 24 06 08 00 00 	movl   $0x806,(%esp)
  8001a4:	e8 8a 29 00 00       	call   802b33 <htons>
  8001a9:	66 89 43 0c          	mov    %ax,0xc(%ebx)
	arp->hwtype = htons(1); // Ethernet
  8001ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001b4:	e8 7a 29 00 00       	call   802b33 <htons>
  8001b9:	66 89 43 0e          	mov    %ax,0xe(%ebx)
	arp->proto = htons(ETHTYPE_IP);
  8001bd:	c7 04 24 00 08 00 00 	movl   $0x800,(%esp)
  8001c4:	e8 6a 29 00 00       	call   802b33 <htons>
  8001c9:	66 89 43 10          	mov    %ax,0x10(%ebx)
	arp->_hwlen_protolen = htons((ETHARP_HWADDR_LEN << 8) | 4);
  8001cd:	c7 04 24 04 06 00 00 	movl   $0x604,(%esp)
  8001d4:	e8 5a 29 00 00       	call   802b33 <htons>
  8001d9:	66 89 43 12          	mov    %ax,0x12(%ebx)
	arp->opcode = htons(ARP_REQUEST);
  8001dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001e4:	e8 4a 29 00 00       	call   802b33 <htons>
  8001e9:	66 89 43 14          	mov    %ax,0x14(%ebx)
	memcpy(arp->shwaddr.addr,  mac,   ETHARP_HWADDR_LEN);
  8001ed:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  8001f4:	00 
  8001f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f9:	c7 04 24 1a b0 fe 0f 	movl   $0xffeb01a,(%esp)
  800200:	e8 5c 0e 00 00       	call   801061 <memcpy>
	memcpy(arp->sipaddr.addrw, &myip, 4);
  800205:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  80020c:	00 
  80020d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800210:	89 44 24 04          	mov    %eax,0x4(%esp)
  800214:	c7 04 24 20 b0 fe 0f 	movl   $0xffeb020,(%esp)
  80021b:	e8 41 0e 00 00       	call   801061 <memcpy>
	memset(arp->dhwaddr.addr,  0x00,  ETHARP_HWADDR_LEN);
  800220:	c7 44 24 08 06 00 00 	movl   $0x6,0x8(%esp)
  800227:	00 
  800228:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80022f:	00 
  800230:	c7 04 24 24 b0 fe 0f 	movl   $0xffeb024,(%esp)
  800237:	e8 4a 0d 00 00       	call   800f86 <memset>
	memcpy(arp->dipaddr.addrw, &gwip, 4);
  80023c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
  800243:	00 
  800244:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800247:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024b:	c7 04 24 2a b0 fe 0f 	movl   $0xffeb02a,(%esp)
  800252:	e8 0a 0e 00 00       	call   801061 <memcpy>

	ipc_send(output_envid, NSREQ_OUTPUT, pkt, PTE_P|PTE_W|PTE_U);
  800257:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80025e:	00 
  80025f:	c7 44 24 08 00 b0 fe 	movl   $0xffeb000,0x8(%esp)
  800266:	0f 
  800267:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
  80026e:	00 
  80026f:	a1 00 50 80 00       	mov    0x805000,%eax
  800274:	89 04 24             	mov    %eax,(%esp)
  800277:	e8 0d 18 00 00       	call   801a89 <ipc_send>
	sys_page_unmap(0, pkt);
  80027c:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  800283:	0f 
  800284:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80028b:	e8 5c 11 00 00       	call   8013ec <sys_page_unmap>
  800290:	c7 85 78 ff ff ff 01 	movl   $0x1,-0x88(%ebp)
  800297:	00 00 00 

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  80029a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80029d:	89 85 74 ff ff ff    	mov    %eax,-0x8c(%ebp)
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
  8002a3:	89 b5 70 ff ff ff    	mov    %esi,-0x90(%ebp)
  8002a9:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  8002af:	29 f0                	sub    %esi,%eax
  8002b1:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)

	while (1) {
		envid_t whom;
		int perm;

		int32_t req = ipc_recv((int32_t *)&whom, pkt, &perm);
  8002b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	c7 44 24 04 00 b0 fe 	movl   $0xffeb000,0x4(%esp)
  8002c5:	0f 
  8002c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8002c9:	89 04 24             	mov    %eax,(%esp)
  8002cc:	e8 23 18 00 00       	call   801af4 <ipc_recv>
		if (req < 0)
  8002d1:	85 c0                	test   %eax,%eax
  8002d3:	79 20                	jns    8002f5 <umain+0x2b5>
			panic("ipc_recv: %e", req);
  8002d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002d9:	c7 44 24 08 69 30 80 	movl   $0x803069,0x8(%esp)
  8002e0:	00 
  8002e1:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8002e8:	00 
  8002e9:	c7 04 24 18 30 80 00 	movl   $0x803018,(%esp)
  8002f0:	e8 0f 03 00 00       	call   800604 <_panic>
		if (whom != input_envid)
  8002f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002f8:	3b 15 04 50 80 00    	cmp    0x805004,%edx
  8002fe:	74 20                	je     800320 <umain+0x2e0>
			panic("IPC from unexpected environment %08x", whom);
  800300:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800304:	c7 44 24 08 c0 30 80 	movl   $0x8030c0,0x8(%esp)
  80030b:	00 
  80030c:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 18 30 80 00 	movl   $0x803018,(%esp)
  80031b:	e8 e4 02 00 00       	call   800604 <_panic>
		if (req != NSREQ_INPUT)
  800320:	83 f8 0a             	cmp    $0xa,%eax
  800323:	74 20                	je     800345 <umain+0x305>
			panic("Unexpected IPC %d", req);
  800325:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800329:	c7 44 24 08 76 30 80 	movl   $0x803076,0x8(%esp)
  800330:	00 
  800331:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  800338:	00 
  800339:	c7 04 24 18 30 80 00 	movl   $0x803018,(%esp)
  800340:	e8 bf 02 00 00       	call   800604 <_panic>

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
  800345:	a1 00 b0 fe 0f       	mov    0xffeb000,%eax
  80034a:	89 45 84             	mov    %eax,-0x7c(%ebp)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80034d:	85 c0                	test   %eax,%eax
  80034f:	0f 8e d6 00 00 00    	jle    80042b <umain+0x3eb>
  800355:	be 00 00 00 00       	mov    $0x0,%esi
  80035a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (i % 16 == 0)
			out = buf + snprintf(buf, end - buf,
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
		if (i % 16 == 15 || i == len - 1)
  80035f:	83 e8 01             	sub    $0x1,%eax
  800362:	89 45 80             	mov    %eax,-0x80(%ebp)
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  800365:	89 df                	mov    %ebx,%edi
		if (i % 16 == 0)
  800367:	f6 c3 0f             	test   $0xf,%bl
  80036a:	75 2e                	jne    80039a <umain+0x35a>
			out = buf + snprintf(buf, end - buf,
  80036c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800370:	c7 44 24 0c 88 30 80 	movl   $0x803088,0xc(%esp)
  800377:	00 
  800378:	c7 44 24 08 90 30 80 	movl   $0x803090,0x8(%esp)
  80037f:	00 
  800380:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  800386:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038a:	8d 45 90             	lea    -0x70(%ebp),%eax
  80038d:	89 04 24             	mov    %eax,(%esp)
  800390:	e8 c3 09 00 00       	call   800d58 <snprintf>
  800395:	8d 75 90             	lea    -0x70(%ebp),%esi
  800398:	01 c6                	add    %eax,%esi
					     "%s%04x   ", prefix, i);
		out += snprintf(out, end - out, "%02x", ((uint8_t*)data)[i]);
  80039a:	0f b6 87 04 b0 fe 0f 	movzbl 0xffeb004(%edi),%eax
  8003a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a5:	c7 44 24 08 9a 30 80 	movl   $0x80309a,0x8(%esp)
  8003ac:	00 
  8003ad:	8b 85 74 ff ff ff    	mov    -0x8c(%ebp),%eax
  8003b3:	29 f0                	sub    %esi,%eax
  8003b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b9:	89 34 24             	mov    %esi,(%esp)
  8003bc:	e8 97 09 00 00       	call   800d58 <snprintf>
  8003c1:	01 c6                	add    %eax,%esi
		if (i % 16 == 15 || i == len - 1)
  8003c3:	89 d8                	mov    %ebx,%eax
  8003c5:	c1 f8 1f             	sar    $0x1f,%eax
  8003c8:	c1 e8 1c             	shr    $0x1c,%eax
  8003cb:	8d 3c 03             	lea    (%ebx,%eax,1),%edi
  8003ce:	83 e7 0f             	and    $0xf,%edi
  8003d1:	29 c7                	sub    %eax,%edi
  8003d3:	83 ff 0f             	cmp    $0xf,%edi
  8003d6:	74 05                	je     8003dd <umain+0x39d>
  8003d8:	3b 5d 80             	cmp    -0x80(%ebp),%ebx
  8003db:	75 1f                	jne    8003fc <umain+0x3bc>
			cprintf("%.*s\n", out - buf, buf);
  8003dd:	8d 45 90             	lea    -0x70(%ebp),%eax
  8003e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e4:	89 f0                	mov    %esi,%eax
  8003e6:	2b 85 70 ff ff ff    	sub    -0x90(%ebp),%eax
  8003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003f0:	c7 04 24 9f 30 80 00 	movl   $0x80309f,(%esp)
  8003f7:	e8 c1 02 00 00       	call   8006bd <cprintf>
		if (i % 2 == 1)
  8003fc:	89 d8                	mov    %ebx,%eax
  8003fe:	c1 e8 1f             	shr    $0x1f,%eax
  800401:	8d 14 03             	lea    (%ebx,%eax,1),%edx
  800404:	83 e2 01             	and    $0x1,%edx
  800407:	29 c2                	sub    %eax,%edx
  800409:	83 fa 01             	cmp    $0x1,%edx
  80040c:	75 06                	jne    800414 <umain+0x3d4>
			*(out++) = ' ';
  80040e:	c6 06 20             	movb   $0x20,(%esi)
  800411:	83 c6 01             	add    $0x1,%esi
		if (i % 16 == 7)
  800414:	83 ff 07             	cmp    $0x7,%edi
  800417:	75 06                	jne    80041f <umain+0x3df>
			*(out++) = ' ';
  800419:	c6 06 20             	movb   $0x20,(%esi)
  80041c:	83 c6 01             	add    $0x1,%esi
{
	int i;
	char buf[80];
	char *end = buf + sizeof(buf);
	char *out = NULL;
	for (i = 0; i < len; i++) {
  80041f:	83 c3 01             	add    $0x1,%ebx
  800422:	39 5d 84             	cmp    %ebx,-0x7c(%ebp)
  800425:	0f 8f 3a ff ff ff    	jg     800365 <umain+0x325>
			panic("IPC from unexpected environment %08x", whom);
		if (req != NSREQ_INPUT)
			panic("Unexpected IPC %d", req);

		hexdump("input: ", pkt->jp_data, pkt->jp_len);
		cprintf("\n");
  80042b:	c7 04 24 bb 30 80 00 	movl   $0x8030bb,(%esp)
  800432:	e8 86 02 00 00       	call   8006bd <cprintf>

		// Only indicate that we're waiting for packets once
		// we've received the ARP reply
		if (first)
  800437:	83 bd 78 ff ff ff 00 	cmpl   $0x0,-0x88(%ebp)
  80043e:	0f 84 73 fe ff ff    	je     8002b7 <umain+0x277>
			cprintf("Waiting for packets...\n");
  800444:	c7 04 24 a5 30 80 00 	movl   $0x8030a5,(%esp)
  80044b:	e8 6d 02 00 00       	call   8006bd <cprintf>
  800450:	c7 85 78 ff ff ff 00 	movl   $0x0,-0x88(%ebp)
  800457:	00 00 00 
  80045a:	e9 58 fe ff ff       	jmp    8002b7 <umain+0x277>
		first = 0;
	}
}
  80045f:	81 c4 ac 00 00 00    	add    $0xac,%esp
  800465:	5b                   	pop    %ebx
  800466:	5e                   	pop    %esi
  800467:	5f                   	pop    %edi
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    
  80046a:	00 00                	add    %al,(%eax)
  80046c:	00 00                	add    %al,(%eax)
	...

00800470 <timer>:
#include "ns.h"

void
timer(envid_t ns_envid, uint32_t initial_to) {
  800470:	55                   	push   %ebp
  800471:	89 e5                	mov    %esp,%ebp
  800473:	57                   	push   %edi
  800474:	56                   	push   %esi
  800475:	53                   	push   %ebx
  800476:	83 ec 2c             	sub    $0x2c,%esp
  800479:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	uint32_t stop = sys_time_msec() + initial_to;
  80047c:	e8 19 0e 00 00       	call   80129a <sys_time_msec>
  800481:	89 c3                	mov    %eax,%ebx
  800483:	03 5d 0c             	add    0xc(%ebp),%ebx

	binaryname = "ns_timer";
  800486:	c7 05 00 40 80 00 e5 	movl   $0x8030e5,0x804000
  80048d:	30 80 00 

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  800490:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800493:	eb 05                	jmp    80049a <timer+0x2a>

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
			sys_yield();
  800495:	e8 fa 0f 00 00       	call   801494 <sys_yield>
	uint32_t stop = sys_time_msec() + initial_to;

	binaryname = "ns_timer";

	while (1) {
		while((r = sys_time_msec()) < stop && r >= 0) {
  80049a:	e8 fb 0d 00 00       	call   80129a <sys_time_msec>
  80049f:	39 c3                	cmp    %eax,%ebx
  8004a1:	76 07                	jbe    8004aa <timer+0x3a>
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	79 ee                	jns    800495 <timer+0x25>
  8004a7:	90                   	nop
  8004a8:	eb 08                	jmp    8004b2 <timer+0x42>
			sys_yield();
		}
		if (r < 0)
  8004aa:	85 c0                	test   %eax,%eax
  8004ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8004b0:	79 20                	jns    8004d2 <timer+0x62>
			panic("sys_time_msec: %e", r);
  8004b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b6:	c7 44 24 08 ee 30 80 	movl   $0x8030ee,0x8(%esp)
  8004bd:	00 
  8004be:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8004c5:	00 
  8004c6:	c7 04 24 00 31 80 00 	movl   $0x803100,(%esp)
  8004cd:	e8 32 01 00 00       	call   800604 <_panic>

		ipc_send(ns_envid, NSREQ_TIMER, 0, 0);
  8004d2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8004d9:	00 
  8004da:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004e1:	00 
  8004e2:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
  8004e9:	00 
  8004ea:	89 34 24             	mov    %esi,(%esp)
  8004ed:	e8 97 15 00 00       	call   801a89 <ipc_send>

		while (1) {
			uint32_t to, whom;
			to = ipc_recv((int32_t *) &whom, 0, 0);
  8004f2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8004f9:	00 
  8004fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800501:	00 
  800502:	89 3c 24             	mov    %edi,(%esp)
  800505:	e8 ea 15 00 00       	call   801af4 <ipc_recv>
  80050a:	89 c3                	mov    %eax,%ebx

			if (whom != ns_envid) {
  80050c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80050f:	39 c6                	cmp    %eax,%esi
  800511:	74 12                	je     800525 <timer+0xb5>
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
  800513:	89 44 24 04          	mov    %eax,0x4(%esp)
  800517:	c7 04 24 0c 31 80 00 	movl   $0x80310c,(%esp)
  80051e:	e8 9a 01 00 00       	call   8006bd <cprintf>
				continue;
			}

			stop = sys_time_msec() + to;
			break;
		}
  800523:	eb cd                	jmp    8004f2 <timer+0x82>
			if (whom != ns_envid) {
				cprintf("NS TIMER: timer thread got IPC message from env %x not NS\n", whom);
				continue;
			}

			stop = sys_time_msec() + to;
  800525:	e8 70 0d 00 00       	call   80129a <sys_time_msec>
  80052a:	01 c3                	add    %eax,%ebx
  80052c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800530:	e9 65 ff ff ff       	jmp    80049a <timer+0x2a>
  800535:	00 00                	add    %al,(%eax)
	...

00800538 <input>:

extern union Nsipc nsipcbuf;

void
input(envid_t ns_envid)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
	binaryname = "ns_input";
  80053b:	c7 05 00 40 80 00 47 	movl   $0x803147,0x804000
  800542:	31 80 00 
	// 	- read a packet from the device driver
	//	- send it to the network server
	// Hint: When you IPC a page to the network server, it will be
	// reading from it for a while, so don't immediately receive
	// another packet in to the same physical page.
}
  800545:	5d                   	pop    %ebp
  800546:	c3                   	ret    
	...

00800548 <output>:

extern union Nsipc nsipcbuf;

void
output(envid_t ns_envid)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 10             	sub    $0x10,%esp
  800550:	8b 75 08             	mov    0x8(%ebp),%esi
	binaryname = "ns_output";
  800553:	c7 05 00 40 80 00 50 	movl   $0x803150,0x804000
  80055a:	31 80 00 
	// 	- read a packet from the network server
	//	- send the packet to the device driver
    int r;

    while (1) {
        r = sys_ipc_recv(&nsipcbuf);
  80055d:	bb 00 70 80 00       	mov    $0x807000,%ebx
  800562:	89 1c 24             	mov    %ebx,(%esp)
  800565:	e8 6b 0d 00 00       	call   8012d5 <sys_ipc_recv>
        if ((thisenv->env_ipc_from != ns_envid) ||
  80056a:	a1 20 50 80 00       	mov    0x805020,%eax
  80056f:	8b 50 74             	mov    0x74(%eax),%edx
  800572:	39 f2                	cmp    %esi,%edx
  800574:	75 ec                	jne    800562 <output+0x1a>
            (thisenv->env_ipc_value != NSREQ_OUTPUT)) {
  800576:	8b 40 70             	mov    0x70(%eax),%eax
	//	- send the packet to the device driver
    int r;

    while (1) {
        r = sys_ipc_recv(&nsipcbuf);
        if ((thisenv->env_ipc_from != ns_envid) ||
  800579:	83 f8 0b             	cmp    $0xb,%eax
  80057c:	75 e4                	jne    800562 <output+0x1a>
            (thisenv->env_ipc_value != NSREQ_OUTPUT)) {
            continue;
        }

        while ((r = sys_net_try_send(nsipcbuf.pkt.jp_data,
  80057e:	8b 03                	mov    (%ebx),%eax
  800580:	89 44 24 04          	mov    %eax,0x4(%esp)
  800584:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  80058b:	e8 d2 0c 00 00       	call   801262 <sys_net_try_send>
  800590:	85 c0                	test   %eax,%eax
  800592:	78 ea                	js     80057e <output+0x36>
  800594:	eb cc                	jmp    800562 <output+0x1a>
	...

00800598 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800598:	55                   	push   %ebp
  800599:	89 e5                	mov    %esp,%ebp
  80059b:	83 ec 18             	sub    $0x18,%esp
  80059e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8005aa:	e8 58 0f 00 00       	call   801507 <sys_getenvid>
  8005af:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005b4:	c1 e0 07             	shl    $0x7,%eax
  8005b7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005bc:	a3 20 50 80 00       	mov    %eax,0x805020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005c1:	85 f6                	test   %esi,%esi
  8005c3:	7e 07                	jle    8005cc <libmain+0x34>
		binaryname = argv[0];
  8005c5:	8b 03                	mov    (%ebx),%eax
  8005c7:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	89 34 24             	mov    %esi,(%esp)
  8005d3:	e8 68 fa ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8005d8:	e8 0b 00 00 00       	call   8005e8 <exit>
}
  8005dd:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005e0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005e3:	89 ec                	mov    %ebp,%esp
  8005e5:	5d                   	pop    %ebp
  8005e6:	c3                   	ret    
	...

008005e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005e8:	55                   	push   %ebp
  8005e9:	89 e5                	mov    %esp,%ebp
  8005eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005ee:	e8 86 1a 00 00       	call   802079 <close_all>
	sys_env_destroy(0);
  8005f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8005fa:	e8 43 0f 00 00       	call   801542 <sys_env_destroy>
}
  8005ff:	c9                   	leave  
  800600:	c3                   	ret    
  800601:	00 00                	add    %al,(%eax)
	...

00800604 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800604:	55                   	push   %ebp
  800605:	89 e5                	mov    %esp,%ebp
  800607:	56                   	push   %esi
  800608:	53                   	push   %ebx
  800609:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80060c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80060f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  800615:	e8 ed 0e 00 00       	call   801507 <sys_getenvid>
  80061a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80061d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800621:	8b 55 08             	mov    0x8(%ebp),%edx
  800624:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800628:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80062c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800630:	c7 04 24 64 31 80 00 	movl   $0x803164,(%esp)
  800637:	e8 81 00 00 00       	call   8006bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80063c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800640:	8b 45 10             	mov    0x10(%ebp),%eax
  800643:	89 04 24             	mov    %eax,(%esp)
  800646:	e8 11 00 00 00       	call   80065c <vcprintf>
	cprintf("\n");
  80064b:	c7 04 24 bb 30 80 00 	movl   $0x8030bb,(%esp)
  800652:	e8 66 00 00 00       	call   8006bd <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800657:	cc                   	int3   
  800658:	eb fd                	jmp    800657 <_panic+0x53>
	...

0080065c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80065c:	55                   	push   %ebp
  80065d:	89 e5                	mov    %esp,%ebp
  80065f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800665:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80066c:	00 00 00 
	b.cnt = 0;
  80066f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800676:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800679:	8b 45 0c             	mov    0xc(%ebp),%eax
  80067c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800680:	8b 45 08             	mov    0x8(%ebp),%eax
  800683:	89 44 24 08          	mov    %eax,0x8(%esp)
  800687:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80068d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800691:	c7 04 24 d7 06 80 00 	movl   $0x8006d7,(%esp)
  800698:	e8 d0 01 00 00       	call   80086d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80069d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006a7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006ad:	89 04 24             	mov    %eax,(%esp)
  8006b0:	e8 01 0f 00 00       	call   8015b6 <sys_cputs>

	return b.cnt;
}
  8006b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006c3:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	89 04 24             	mov    %eax,(%esp)
  8006d0:	e8 87 ff ff ff       	call   80065c <vcprintf>
	va_end(ap);

	return cnt;
}
  8006d5:	c9                   	leave  
  8006d6:	c3                   	ret    

008006d7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	53                   	push   %ebx
  8006db:	83 ec 14             	sub    $0x14,%esp
  8006de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006e1:	8b 03                	mov    (%ebx),%eax
  8006e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006ea:	83 c0 01             	add    $0x1,%eax
  8006ed:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006ef:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006f4:	75 19                	jne    80070f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8006f6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8006fd:	00 
  8006fe:	8d 43 08             	lea    0x8(%ebx),%eax
  800701:	89 04 24             	mov    %eax,(%esp)
  800704:	e8 ad 0e 00 00       	call   8015b6 <sys_cputs>
		b->idx = 0;
  800709:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80070f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800713:	83 c4 14             	add    $0x14,%esp
  800716:	5b                   	pop    %ebx
  800717:	5d                   	pop    %ebp
  800718:	c3                   	ret    
  800719:	00 00                	add    %al,(%eax)
  80071b:	00 00                	add    %al,(%eax)
  80071d:	00 00                	add    %al,(%eax)
	...

00800720 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800720:	55                   	push   %ebp
  800721:	89 e5                	mov    %esp,%ebp
  800723:	57                   	push   %edi
  800724:	56                   	push   %esi
  800725:	53                   	push   %ebx
  800726:	83 ec 4c             	sub    $0x4c,%esp
  800729:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072c:	89 d6                	mov    %edx,%esi
  80072e:	8b 45 08             	mov    0x8(%ebp),%eax
  800731:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800734:	8b 55 0c             	mov    0xc(%ebp),%edx
  800737:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800740:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800743:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800746:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074b:	39 d1                	cmp    %edx,%ecx
  80074d:	72 15                	jb     800764 <printnum+0x44>
  80074f:	77 07                	ja     800758 <printnum+0x38>
  800751:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800754:	39 d0                	cmp    %edx,%eax
  800756:	76 0c                	jbe    800764 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800758:	83 eb 01             	sub    $0x1,%ebx
  80075b:	85 db                	test   %ebx,%ebx
  80075d:	8d 76 00             	lea    0x0(%esi),%esi
  800760:	7f 61                	jg     8007c3 <printnum+0xa3>
  800762:	eb 70                	jmp    8007d4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800764:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800768:	83 eb 01             	sub    $0x1,%ebx
  80076b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80076f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800773:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800777:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80077b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80077e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800781:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800784:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800788:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80078f:	00 
  800790:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800793:	89 04 24             	mov    %eax,(%esp)
  800796:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800799:	89 54 24 04          	mov    %edx,0x4(%esp)
  80079d:	e8 ee 25 00 00       	call   802d90 <__udivdi3>
  8007a2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007a5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007ac:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007b0:	89 04 24             	mov    %eax,(%esp)
  8007b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007b7:	89 f2                	mov    %esi,%edx
  8007b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007bc:	e8 5f ff ff ff       	call   800720 <printnum>
  8007c1:	eb 11                	jmp    8007d4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c7:	89 3c 24             	mov    %edi,(%esp)
  8007ca:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007cd:	83 eb 01             	sub    $0x1,%ebx
  8007d0:	85 db                	test   %ebx,%ebx
  8007d2:	7f ef                	jg     8007c3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007ea:	00 
  8007eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ee:	89 14 24             	mov    %edx,(%esp)
  8007f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8007f4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8007f8:	e8 c3 26 00 00       	call   802ec0 <__umoddi3>
  8007fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800801:	0f be 80 87 31 80 00 	movsbl 0x803187(%eax),%eax
  800808:	89 04 24             	mov    %eax,(%esp)
  80080b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80080e:	83 c4 4c             	add    $0x4c,%esp
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5f                   	pop    %edi
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    

00800816 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800819:	83 fa 01             	cmp    $0x1,%edx
  80081c:	7e 0e                	jle    80082c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80081e:	8b 10                	mov    (%eax),%edx
  800820:	8d 4a 08             	lea    0x8(%edx),%ecx
  800823:	89 08                	mov    %ecx,(%eax)
  800825:	8b 02                	mov    (%edx),%eax
  800827:	8b 52 04             	mov    0x4(%edx),%edx
  80082a:	eb 22                	jmp    80084e <getuint+0x38>
	else if (lflag)
  80082c:	85 d2                	test   %edx,%edx
  80082e:	74 10                	je     800840 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800830:	8b 10                	mov    (%eax),%edx
  800832:	8d 4a 04             	lea    0x4(%edx),%ecx
  800835:	89 08                	mov    %ecx,(%eax)
  800837:	8b 02                	mov    (%edx),%eax
  800839:	ba 00 00 00 00       	mov    $0x0,%edx
  80083e:	eb 0e                	jmp    80084e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800840:	8b 10                	mov    (%eax),%edx
  800842:	8d 4a 04             	lea    0x4(%edx),%ecx
  800845:	89 08                	mov    %ecx,(%eax)
  800847:	8b 02                	mov    (%edx),%eax
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800856:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80085a:	8b 10                	mov    (%eax),%edx
  80085c:	3b 50 04             	cmp    0x4(%eax),%edx
  80085f:	73 0a                	jae    80086b <sprintputch+0x1b>
		*b->buf++ = ch;
  800861:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800864:	88 0a                	mov    %cl,(%edx)
  800866:	83 c2 01             	add    $0x1,%edx
  800869:	89 10                	mov    %edx,(%eax)
}
  80086b:	5d                   	pop    %ebp
  80086c:	c3                   	ret    

0080086d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	57                   	push   %edi
  800871:	56                   	push   %esi
  800872:	53                   	push   %ebx
  800873:	83 ec 5c             	sub    $0x5c,%esp
  800876:	8b 7d 08             	mov    0x8(%ebp),%edi
  800879:	8b 75 0c             	mov    0xc(%ebp),%esi
  80087c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80087f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800886:	eb 11                	jmp    800899 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800888:	85 c0                	test   %eax,%eax
  80088a:	0f 84 68 04 00 00    	je     800cf8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800890:	89 74 24 04          	mov    %esi,0x4(%esp)
  800894:	89 04 24             	mov    %eax,(%esp)
  800897:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800899:	0f b6 03             	movzbl (%ebx),%eax
  80089c:	83 c3 01             	add    $0x1,%ebx
  80089f:	83 f8 25             	cmp    $0x25,%eax
  8008a2:	75 e4                	jne    800888 <vprintfmt+0x1b>
  8008a4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008ab:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8008bb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008c2:	eb 06                	jmp    8008ca <vprintfmt+0x5d>
  8008c4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8008c8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ca:	0f b6 13             	movzbl (%ebx),%edx
  8008cd:	0f b6 c2             	movzbl %dl,%eax
  8008d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008d3:	8d 43 01             	lea    0x1(%ebx),%eax
  8008d6:	83 ea 23             	sub    $0x23,%edx
  8008d9:	80 fa 55             	cmp    $0x55,%dl
  8008dc:	0f 87 f9 03 00 00    	ja     800cdb <vprintfmt+0x46e>
  8008e2:	0f b6 d2             	movzbl %dl,%edx
  8008e5:	ff 24 95 60 33 80 00 	jmp    *0x803360(,%edx,4)
  8008ec:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8008f0:	eb d6                	jmp    8008c8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008f5:	83 ea 30             	sub    $0x30,%edx
  8008f8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8008fb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8008fe:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800901:	83 fb 09             	cmp    $0x9,%ebx
  800904:	77 54                	ja     80095a <vprintfmt+0xed>
  800906:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800909:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80090c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80090f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800912:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800916:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800919:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80091c:	83 fb 09             	cmp    $0x9,%ebx
  80091f:	76 eb                	jbe    80090c <vprintfmt+0x9f>
  800921:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800924:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800927:	eb 31                	jmp    80095a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800929:	8b 55 14             	mov    0x14(%ebp),%edx
  80092c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80092f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800932:	8b 12                	mov    (%edx),%edx
  800934:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800937:	eb 21                	jmp    80095a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800939:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80093d:	ba 00 00 00 00       	mov    $0x0,%edx
  800942:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800946:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800949:	e9 7a ff ff ff       	jmp    8008c8 <vprintfmt+0x5b>
  80094e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800955:	e9 6e ff ff ff       	jmp    8008c8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80095a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80095e:	0f 89 64 ff ff ff    	jns    8008c8 <vprintfmt+0x5b>
  800964:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800967:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80096a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80096d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800970:	e9 53 ff ff ff       	jmp    8008c8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800975:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800978:	e9 4b ff ff ff       	jmp    8008c8 <vprintfmt+0x5b>
  80097d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800980:	8b 45 14             	mov    0x14(%ebp),%eax
  800983:	8d 50 04             	lea    0x4(%eax),%edx
  800986:	89 55 14             	mov    %edx,0x14(%ebp)
  800989:	89 74 24 04          	mov    %esi,0x4(%esp)
  80098d:	8b 00                	mov    (%eax),%eax
  80098f:	89 04 24             	mov    %eax,(%esp)
  800992:	ff d7                	call   *%edi
  800994:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800997:	e9 fd fe ff ff       	jmp    800899 <vprintfmt+0x2c>
  80099c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80099f:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a2:	8d 50 04             	lea    0x4(%eax),%edx
  8009a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a8:	8b 00                	mov    (%eax),%eax
  8009aa:	89 c2                	mov    %eax,%edx
  8009ac:	c1 fa 1f             	sar    $0x1f,%edx
  8009af:	31 d0                	xor    %edx,%eax
  8009b1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009b3:	83 f8 0f             	cmp    $0xf,%eax
  8009b6:	7f 0b                	jg     8009c3 <vprintfmt+0x156>
  8009b8:	8b 14 85 c0 34 80 00 	mov    0x8034c0(,%eax,4),%edx
  8009bf:	85 d2                	test   %edx,%edx
  8009c1:	75 20                	jne    8009e3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8009c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c7:	c7 44 24 08 98 31 80 	movl   $0x803198,0x8(%esp)
  8009ce:	00 
  8009cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d3:	89 3c 24             	mov    %edi,(%esp)
  8009d6:	e8 a5 03 00 00       	call   800d80 <printfmt>
  8009db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009de:	e9 b6 fe ff ff       	jmp    800899 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009e7:	c7 44 24 08 57 38 80 	movl   $0x803857,0x8(%esp)
  8009ee:	00 
  8009ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f3:	89 3c 24             	mov    %edi,(%esp)
  8009f6:	e8 85 03 00 00       	call   800d80 <printfmt>
  8009fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8009fe:	e9 96 fe ff ff       	jmp    800899 <vprintfmt+0x2c>
  800a03:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a06:	89 c3                	mov    %eax,%ebx
  800a08:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a0e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a11:	8b 45 14             	mov    0x14(%ebp),%eax
  800a14:	8d 50 04             	lea    0x4(%eax),%edx
  800a17:	89 55 14             	mov    %edx,0x14(%ebp)
  800a1a:	8b 00                	mov    (%eax),%eax
  800a1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	b8 a1 31 80 00       	mov    $0x8031a1,%eax
  800a26:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  800a2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a2d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800a31:	7e 06                	jle    800a39 <vprintfmt+0x1cc>
  800a33:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800a37:	75 13                	jne    800a4c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a39:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a3c:	0f be 02             	movsbl (%edx),%eax
  800a3f:	85 c0                	test   %eax,%eax
  800a41:	0f 85 a2 00 00 00    	jne    800ae9 <vprintfmt+0x27c>
  800a47:	e9 8f 00 00 00       	jmp    800adb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a4c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a50:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800a53:	89 0c 24             	mov    %ecx,(%esp)
  800a56:	e8 70 03 00 00       	call   800dcb <strnlen>
  800a5b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a5e:	29 c2                	sub    %eax,%edx
  800a60:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800a63:	85 d2                	test   %edx,%edx
  800a65:	7e d2                	jle    800a39 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800a67:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800a6b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800a6e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800a71:	89 d3                	mov    %edx,%ebx
  800a73:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a77:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a7a:	89 04 24             	mov    %eax,(%esp)
  800a7d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a7f:	83 eb 01             	sub    $0x1,%ebx
  800a82:	85 db                	test   %ebx,%ebx
  800a84:	7f ed                	jg     800a73 <vprintfmt+0x206>
  800a86:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800a89:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800a90:	eb a7                	jmp    800a39 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a92:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a96:	74 1b                	je     800ab3 <vprintfmt+0x246>
  800a98:	8d 50 e0             	lea    -0x20(%eax),%edx
  800a9b:	83 fa 5e             	cmp    $0x5e,%edx
  800a9e:	76 13                	jbe    800ab3 <vprintfmt+0x246>
					putch('?', putdat);
  800aa0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800aa3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800aa7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800aae:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ab1:	eb 0d                	jmp    800ac0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800ab3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ab6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800aba:	89 04 24             	mov    %eax,(%esp)
  800abd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ac0:	83 ef 01             	sub    $0x1,%edi
  800ac3:	0f be 03             	movsbl (%ebx),%eax
  800ac6:	85 c0                	test   %eax,%eax
  800ac8:	74 05                	je     800acf <vprintfmt+0x262>
  800aca:	83 c3 01             	add    $0x1,%ebx
  800acd:	eb 31                	jmp    800b00 <vprintfmt+0x293>
  800acf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800ad2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ad5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ad8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800adb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800adf:	7f 36                	jg     800b17 <vprintfmt+0x2aa>
  800ae1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800ae4:	e9 b0 fd ff ff       	jmp    800899 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ae9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aec:	83 c2 01             	add    $0x1,%edx
  800aef:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800af2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800af5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800af8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800afb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800afe:	89 d3                	mov    %edx,%ebx
  800b00:	85 f6                	test   %esi,%esi
  800b02:	78 8e                	js     800a92 <vprintfmt+0x225>
  800b04:	83 ee 01             	sub    $0x1,%esi
  800b07:	79 89                	jns    800a92 <vprintfmt+0x225>
  800b09:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b0f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b12:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800b15:	eb c4                	jmp    800adb <vprintfmt+0x26e>
  800b17:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800b1a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b21:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b28:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b2a:	83 eb 01             	sub    $0x1,%ebx
  800b2d:	85 db                	test   %ebx,%ebx
  800b2f:	7f ec                	jg     800b1d <vprintfmt+0x2b0>
  800b31:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800b34:	e9 60 fd ff ff       	jmp    800899 <vprintfmt+0x2c>
  800b39:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b3c:	83 f9 01             	cmp    $0x1,%ecx
  800b3f:	7e 16                	jle    800b57 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800b41:	8b 45 14             	mov    0x14(%ebp),%eax
  800b44:	8d 50 08             	lea    0x8(%eax),%edx
  800b47:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4a:	8b 10                	mov    (%eax),%edx
  800b4c:	8b 48 04             	mov    0x4(%eax),%ecx
  800b4f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800b52:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b55:	eb 32                	jmp    800b89 <vprintfmt+0x31c>
	else if (lflag)
  800b57:	85 c9                	test   %ecx,%ecx
  800b59:	74 18                	je     800b73 <vprintfmt+0x306>
		return va_arg(*ap, long);
  800b5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5e:	8d 50 04             	lea    0x4(%eax),%edx
  800b61:	89 55 14             	mov    %edx,0x14(%ebp)
  800b64:	8b 00                	mov    (%eax),%eax
  800b66:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b69:	89 c1                	mov    %eax,%ecx
  800b6b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b6e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b71:	eb 16                	jmp    800b89 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800b73:	8b 45 14             	mov    0x14(%ebp),%eax
  800b76:	8d 50 04             	lea    0x4(%eax),%edx
  800b79:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7c:	8b 00                	mov    (%eax),%eax
  800b7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b81:	89 c2                	mov    %eax,%edx
  800b83:	c1 fa 1f             	sar    $0x1f,%edx
  800b86:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b89:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800b94:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b98:	0f 89 8a 00 00 00    	jns    800c28 <vprintfmt+0x3bb>
				putch('-', putdat);
  800b9e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800ba9:	ff d7                	call   *%edi
				num = -(long long) num;
  800bab:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bae:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bb1:	f7 d8                	neg    %eax
  800bb3:	83 d2 00             	adc    $0x0,%edx
  800bb6:	f7 da                	neg    %edx
  800bb8:	eb 6e                	jmp    800c28 <vprintfmt+0x3bb>
  800bba:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bbd:	89 ca                	mov    %ecx,%edx
  800bbf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc2:	e8 4f fc ff ff       	call   800816 <getuint>
  800bc7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800bcc:	eb 5a                	jmp    800c28 <vprintfmt+0x3bb>
  800bce:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800bd1:	89 ca                	mov    %ecx,%edx
  800bd3:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd6:	e8 3b fc ff ff       	call   800816 <getuint>
  800bdb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800be0:	eb 46                	jmp    800c28 <vprintfmt+0x3bb>
  800be2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800be5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800bf0:	ff d7                	call   *%edi
			putch('x', putdat);
  800bf2:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800bfd:	ff d7                	call   *%edi
			num = (unsigned long long)
  800bff:	8b 45 14             	mov    0x14(%ebp),%eax
  800c02:	8d 50 04             	lea    0x4(%eax),%edx
  800c05:	89 55 14             	mov    %edx,0x14(%ebp)
  800c08:	8b 00                	mov    (%eax),%eax
  800c0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c0f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c14:	eb 12                	jmp    800c28 <vprintfmt+0x3bb>
  800c16:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c19:	89 ca                	mov    %ecx,%edx
  800c1b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c1e:	e8 f3 fb ff ff       	call   800816 <getuint>
  800c23:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c28:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800c2c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800c30:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800c33:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c37:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c3b:	89 04 24             	mov    %eax,(%esp)
  800c3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c42:	89 f2                	mov    %esi,%edx
  800c44:	89 f8                	mov    %edi,%eax
  800c46:	e8 d5 fa ff ff       	call   800720 <printnum>
  800c4b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800c4e:	e9 46 fc ff ff       	jmp    800899 <vprintfmt+0x2c>
  800c53:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800c56:	8b 45 14             	mov    0x14(%ebp),%eax
  800c59:	8d 50 04             	lea    0x4(%eax),%edx
  800c5c:	89 55 14             	mov    %edx,0x14(%ebp)
  800c5f:	8b 00                	mov    (%eax),%eax
  800c61:	85 c0                	test   %eax,%eax
  800c63:	75 24                	jne    800c89 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800c65:	c7 44 24 0c bc 32 80 	movl   $0x8032bc,0xc(%esp)
  800c6c:	00 
  800c6d:	c7 44 24 08 57 38 80 	movl   $0x803857,0x8(%esp)
  800c74:	00 
  800c75:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c79:	89 3c 24             	mov    %edi,(%esp)
  800c7c:	e8 ff 00 00 00       	call   800d80 <printfmt>
  800c81:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800c84:	e9 10 fc ff ff       	jmp    800899 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800c89:	83 3e 7f             	cmpl   $0x7f,(%esi)
  800c8c:	7e 29                	jle    800cb7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  800c8e:	0f b6 16             	movzbl (%esi),%edx
  800c91:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800c93:	c7 44 24 0c f4 32 80 	movl   $0x8032f4,0xc(%esp)
  800c9a:	00 
  800c9b:	c7 44 24 08 57 38 80 	movl   $0x803857,0x8(%esp)
  800ca2:	00 
  800ca3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ca7:	89 3c 24             	mov    %edi,(%esp)
  800caa:	e8 d1 00 00 00       	call   800d80 <printfmt>
  800caf:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800cb2:	e9 e2 fb ff ff       	jmp    800899 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800cb7:	0f b6 16             	movzbl (%esi),%edx
  800cba:	88 10                	mov    %dl,(%eax)
  800cbc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  800cbf:	e9 d5 fb ff ff       	jmp    800899 <vprintfmt+0x2c>
  800cc4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800cc7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cce:	89 14 24             	mov    %edx,(%esp)
  800cd1:	ff d7                	call   *%edi
  800cd3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800cd6:	e9 be fb ff ff       	jmp    800899 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800cdb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cdf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ce6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ce8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ceb:	80 38 25             	cmpb   $0x25,(%eax)
  800cee:	0f 84 a5 fb ff ff    	je     800899 <vprintfmt+0x2c>
  800cf4:	89 c3                	mov    %eax,%ebx
  800cf6:	eb f0                	jmp    800ce8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800cf8:	83 c4 5c             	add    $0x5c,%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d00:	55                   	push   %ebp
  800d01:	89 e5                	mov    %esp,%ebp
  800d03:	83 ec 28             	sub    $0x28,%esp
  800d06:	8b 45 08             	mov    0x8(%ebp),%eax
  800d09:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	74 04                	je     800d14 <vsnprintf+0x14>
  800d10:	85 d2                	test   %edx,%edx
  800d12:	7f 07                	jg     800d1b <vsnprintf+0x1b>
  800d14:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d19:	eb 3b                	jmp    800d56 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d1b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d1e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d25:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d2c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d33:	8b 45 10             	mov    0x10(%ebp),%eax
  800d36:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d41:	c7 04 24 50 08 80 00 	movl   $0x800850,(%esp)
  800d48:	e8 20 fb ff ff       	call   80086d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d50:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d56:	c9                   	leave  
  800d57:	c3                   	ret    

00800d58 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800d5e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800d61:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d65:	8b 45 10             	mov    0x10(%ebp),%eax
  800d68:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	89 04 24             	mov    %eax,(%esp)
  800d79:	e8 82 ff ff ff       	call   800d00 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800d86:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800d89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d90:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	89 04 24             	mov    %eax,(%esp)
  800da1:	e8 c7 fa ff ff       	call   80086d <vprintfmt>
	va_end(ap);
}
  800da6:	c9                   	leave  
  800da7:	c3                   	ret    
	...

00800db0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800db0:	55                   	push   %ebp
  800db1:	89 e5                	mov    %esp,%ebp
  800db3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800db6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dbb:	80 3a 00             	cmpb   $0x0,(%edx)
  800dbe:	74 09                	je     800dc9 <strlen+0x19>
		n++;
  800dc0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dc7:	75 f7                	jne    800dc0 <strlen+0x10>
		n++;
	return n;
}
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	53                   	push   %ebx
  800dcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800dd5:	85 c9                	test   %ecx,%ecx
  800dd7:	74 19                	je     800df2 <strnlen+0x27>
  800dd9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800ddc:	74 14                	je     800df2 <strnlen+0x27>
  800dde:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800de3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800de6:	39 c8                	cmp    %ecx,%eax
  800de8:	74 0d                	je     800df7 <strnlen+0x2c>
  800dea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800dee:	75 f3                	jne    800de3 <strnlen+0x18>
  800df0:	eb 05                	jmp    800df7 <strnlen+0x2c>
  800df2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800df7:	5b                   	pop    %ebx
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	53                   	push   %ebx
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e10:	83 c2 01             	add    $0x1,%edx
  800e13:	84 c9                	test   %cl,%cl
  800e15:	75 f2                	jne    800e09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e17:	5b                   	pop    %ebx
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    

00800e1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	53                   	push   %ebx
  800e1e:	83 ec 08             	sub    $0x8,%esp
  800e21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e24:	89 1c 24             	mov    %ebx,(%esp)
  800e27:	e8 84 ff ff ff       	call   800db0 <strlen>
	strcpy(dst + len, src);
  800e2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800e36:	89 04 24             	mov    %eax,(%esp)
  800e39:	e8 bc ff ff ff       	call   800dfa <strcpy>
	return dst;
}
  800e3e:	89 d8                	mov    %ebx,%eax
  800e40:	83 c4 08             	add    $0x8,%esp
  800e43:	5b                   	pop    %ebx
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e54:	85 f6                	test   %esi,%esi
  800e56:	74 18                	je     800e70 <strncpy+0x2a>
  800e58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e5d:	0f b6 1a             	movzbl (%edx),%ebx
  800e60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e63:	80 3a 01             	cmpb   $0x1,(%edx)
  800e66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e69:	83 c1 01             	add    $0x1,%ecx
  800e6c:	39 ce                	cmp    %ecx,%esi
  800e6e:	77 ed                	ja     800e5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	56                   	push   %esi
  800e78:	53                   	push   %ebx
  800e79:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e82:	89 f0                	mov    %esi,%eax
  800e84:	85 c9                	test   %ecx,%ecx
  800e86:	74 27                	je     800eaf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800e88:	83 e9 01             	sub    $0x1,%ecx
  800e8b:	74 1d                	je     800eaa <strlcpy+0x36>
  800e8d:	0f b6 1a             	movzbl (%edx),%ebx
  800e90:	84 db                	test   %bl,%bl
  800e92:	74 16                	je     800eaa <strlcpy+0x36>
			*dst++ = *src++;
  800e94:	88 18                	mov    %bl,(%eax)
  800e96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e99:	83 e9 01             	sub    $0x1,%ecx
  800e9c:	74 0e                	je     800eac <strlcpy+0x38>
			*dst++ = *src++;
  800e9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ea1:	0f b6 1a             	movzbl (%edx),%ebx
  800ea4:	84 db                	test   %bl,%bl
  800ea6:	75 ec                	jne    800e94 <strlcpy+0x20>
  800ea8:	eb 02                	jmp    800eac <strlcpy+0x38>
  800eaa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800eac:	c6 00 00             	movb   $0x0,(%eax)
  800eaf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ebe:	0f b6 01             	movzbl (%ecx),%eax
  800ec1:	84 c0                	test   %al,%al
  800ec3:	74 15                	je     800eda <strcmp+0x25>
  800ec5:	3a 02                	cmp    (%edx),%al
  800ec7:	75 11                	jne    800eda <strcmp+0x25>
		p++, q++;
  800ec9:	83 c1 01             	add    $0x1,%ecx
  800ecc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ecf:	0f b6 01             	movzbl (%ecx),%eax
  800ed2:	84 c0                	test   %al,%al
  800ed4:	74 04                	je     800eda <strcmp+0x25>
  800ed6:	3a 02                	cmp    (%edx),%al
  800ed8:	74 ef                	je     800ec9 <strcmp+0x14>
  800eda:	0f b6 c0             	movzbl %al,%eax
  800edd:	0f b6 12             	movzbl (%edx),%edx
  800ee0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ee2:	5d                   	pop    %ebp
  800ee3:	c3                   	ret    

00800ee4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	53                   	push   %ebx
  800ee8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	74 23                	je     800f18 <strncmp+0x34>
  800ef5:	0f b6 1a             	movzbl (%edx),%ebx
  800ef8:	84 db                	test   %bl,%bl
  800efa:	74 25                	je     800f21 <strncmp+0x3d>
  800efc:	3a 19                	cmp    (%ecx),%bl
  800efe:	75 21                	jne    800f21 <strncmp+0x3d>
  800f00:	83 e8 01             	sub    $0x1,%eax
  800f03:	74 13                	je     800f18 <strncmp+0x34>
		n--, p++, q++;
  800f05:	83 c2 01             	add    $0x1,%edx
  800f08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f0b:	0f b6 1a             	movzbl (%edx),%ebx
  800f0e:	84 db                	test   %bl,%bl
  800f10:	74 0f                	je     800f21 <strncmp+0x3d>
  800f12:	3a 19                	cmp    (%ecx),%bl
  800f14:	74 ea                	je     800f00 <strncmp+0x1c>
  800f16:	eb 09                	jmp    800f21 <strncmp+0x3d>
  800f18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f1d:	5b                   	pop    %ebx
  800f1e:	5d                   	pop    %ebp
  800f1f:	90                   	nop
  800f20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f21:	0f b6 02             	movzbl (%edx),%eax
  800f24:	0f b6 11             	movzbl (%ecx),%edx
  800f27:	29 d0                	sub    %edx,%eax
  800f29:	eb f2                	jmp    800f1d <strncmp+0x39>

00800f2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f35:	0f b6 10             	movzbl (%eax),%edx
  800f38:	84 d2                	test   %dl,%dl
  800f3a:	74 18                	je     800f54 <strchr+0x29>
		if (*s == c)
  800f3c:	38 ca                	cmp    %cl,%dl
  800f3e:	75 0a                	jne    800f4a <strchr+0x1f>
  800f40:	eb 17                	jmp    800f59 <strchr+0x2e>
  800f42:	38 ca                	cmp    %cl,%dl
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	74 0f                	je     800f59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f4a:	83 c0 01             	add    $0x1,%eax
  800f4d:	0f b6 10             	movzbl (%eax),%edx
  800f50:	84 d2                	test   %dl,%dl
  800f52:	75 ee                	jne    800f42 <strchr+0x17>
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f65:	0f b6 10             	movzbl (%eax),%edx
  800f68:	84 d2                	test   %dl,%dl
  800f6a:	74 18                	je     800f84 <strfind+0x29>
		if (*s == c)
  800f6c:	38 ca                	cmp    %cl,%dl
  800f6e:	75 0a                	jne    800f7a <strfind+0x1f>
  800f70:	eb 12                	jmp    800f84 <strfind+0x29>
  800f72:	38 ca                	cmp    %cl,%dl
  800f74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f78:	74 0a                	je     800f84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f7a:	83 c0 01             	add    $0x1,%eax
  800f7d:	0f b6 10             	movzbl (%eax),%edx
  800f80:	84 d2                	test   %dl,%dl
  800f82:	75 ee                	jne    800f72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    

00800f86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 0c             	sub    $0xc,%esp
  800f8c:	89 1c 24             	mov    %ebx,(%esp)
  800f8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fa0:	85 c9                	test   %ecx,%ecx
  800fa2:	74 30                	je     800fd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fa4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800faa:	75 25                	jne    800fd1 <memset+0x4b>
  800fac:	f6 c1 03             	test   $0x3,%cl
  800faf:	75 20                	jne    800fd1 <memset+0x4b>
		c &= 0xFF;
  800fb1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fb4:	89 d3                	mov    %edx,%ebx
  800fb6:	c1 e3 08             	shl    $0x8,%ebx
  800fb9:	89 d6                	mov    %edx,%esi
  800fbb:	c1 e6 18             	shl    $0x18,%esi
  800fbe:	89 d0                	mov    %edx,%eax
  800fc0:	c1 e0 10             	shl    $0x10,%eax
  800fc3:	09 f0                	or     %esi,%eax
  800fc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800fc7:	09 d8                	or     %ebx,%eax
  800fc9:	c1 e9 02             	shr    $0x2,%ecx
  800fcc:	fc                   	cld    
  800fcd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fcf:	eb 03                	jmp    800fd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fd1:	fc                   	cld    
  800fd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fd4:	89 f8                	mov    %edi,%eax
  800fd6:	8b 1c 24             	mov    (%esp),%ebx
  800fd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fdd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fe1:	89 ec                	mov    %ebp,%esp
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	89 34 24             	mov    %esi,(%esp)
  800fee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ff2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ff8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800ffb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ffd:	39 c6                	cmp    %eax,%esi
  800fff:	73 35                	jae    801036 <memmove+0x51>
  801001:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801004:	39 d0                	cmp    %edx,%eax
  801006:	73 2e                	jae    801036 <memmove+0x51>
		s += n;
		d += n;
  801008:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80100a:	f6 c2 03             	test   $0x3,%dl
  80100d:	75 1b                	jne    80102a <memmove+0x45>
  80100f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801015:	75 13                	jne    80102a <memmove+0x45>
  801017:	f6 c1 03             	test   $0x3,%cl
  80101a:	75 0e                	jne    80102a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80101c:	83 ef 04             	sub    $0x4,%edi
  80101f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801022:	c1 e9 02             	shr    $0x2,%ecx
  801025:	fd                   	std    
  801026:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801028:	eb 09                	jmp    801033 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80102a:	83 ef 01             	sub    $0x1,%edi
  80102d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801030:	fd                   	std    
  801031:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801033:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801034:	eb 20                	jmp    801056 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801036:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80103c:	75 15                	jne    801053 <memmove+0x6e>
  80103e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801044:	75 0d                	jne    801053 <memmove+0x6e>
  801046:	f6 c1 03             	test   $0x3,%cl
  801049:	75 08                	jne    801053 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80104b:	c1 e9 02             	shr    $0x2,%ecx
  80104e:	fc                   	cld    
  80104f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801051:	eb 03                	jmp    801056 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801053:	fc                   	cld    
  801054:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801056:	8b 34 24             	mov    (%esp),%esi
  801059:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80105d:	89 ec                	mov    %ebp,%esp
  80105f:	5d                   	pop    %ebp
  801060:	c3                   	ret    

00801061 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801061:	55                   	push   %ebp
  801062:	89 e5                	mov    %esp,%ebp
  801064:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801067:	8b 45 10             	mov    0x10(%ebp),%eax
  80106a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80106e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801071:	89 44 24 04          	mov    %eax,0x4(%esp)
  801075:	8b 45 08             	mov    0x8(%ebp),%eax
  801078:	89 04 24             	mov    %eax,(%esp)
  80107b:	e8 65 ff ff ff       	call   800fe5 <memmove>
}
  801080:	c9                   	leave  
  801081:	c3                   	ret    

00801082 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	57                   	push   %edi
  801086:	56                   	push   %esi
  801087:	53                   	push   %ebx
  801088:	8b 75 08             	mov    0x8(%ebp),%esi
  80108b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80108e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801091:	85 c9                	test   %ecx,%ecx
  801093:	74 36                	je     8010cb <memcmp+0x49>
		if (*s1 != *s2)
  801095:	0f b6 06             	movzbl (%esi),%eax
  801098:	0f b6 1f             	movzbl (%edi),%ebx
  80109b:	38 d8                	cmp    %bl,%al
  80109d:	74 20                	je     8010bf <memcmp+0x3d>
  80109f:	eb 14                	jmp    8010b5 <memcmp+0x33>
  8010a1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8010a6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8010ab:	83 c2 01             	add    $0x1,%edx
  8010ae:	83 e9 01             	sub    $0x1,%ecx
  8010b1:	38 d8                	cmp    %bl,%al
  8010b3:	74 12                	je     8010c7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8010b5:	0f b6 c0             	movzbl %al,%eax
  8010b8:	0f b6 db             	movzbl %bl,%ebx
  8010bb:	29 d8                	sub    %ebx,%eax
  8010bd:	eb 11                	jmp    8010d0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010bf:	83 e9 01             	sub    $0x1,%ecx
  8010c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c7:	85 c9                	test   %ecx,%ecx
  8010c9:	75 d6                	jne    8010a1 <memcmp+0x1f>
  8010cb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010e0:	39 d0                	cmp    %edx,%eax
  8010e2:	73 15                	jae    8010f9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010e8:	38 08                	cmp    %cl,(%eax)
  8010ea:	75 06                	jne    8010f2 <memfind+0x1d>
  8010ec:	eb 0b                	jmp    8010f9 <memfind+0x24>
  8010ee:	38 08                	cmp    %cl,(%eax)
  8010f0:	74 07                	je     8010f9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010f2:	83 c0 01             	add    $0x1,%eax
  8010f5:	39 c2                	cmp    %eax,%edx
  8010f7:	77 f5                	ja     8010ee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	57                   	push   %edi
  8010ff:	56                   	push   %esi
  801100:	53                   	push   %ebx
  801101:	83 ec 04             	sub    $0x4,%esp
  801104:	8b 55 08             	mov    0x8(%ebp),%edx
  801107:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80110a:	0f b6 02             	movzbl (%edx),%eax
  80110d:	3c 20                	cmp    $0x20,%al
  80110f:	74 04                	je     801115 <strtol+0x1a>
  801111:	3c 09                	cmp    $0x9,%al
  801113:	75 0e                	jne    801123 <strtol+0x28>
		s++;
  801115:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801118:	0f b6 02             	movzbl (%edx),%eax
  80111b:	3c 20                	cmp    $0x20,%al
  80111d:	74 f6                	je     801115 <strtol+0x1a>
  80111f:	3c 09                	cmp    $0x9,%al
  801121:	74 f2                	je     801115 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801123:	3c 2b                	cmp    $0x2b,%al
  801125:	75 0c                	jne    801133 <strtol+0x38>
		s++;
  801127:	83 c2 01             	add    $0x1,%edx
  80112a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801131:	eb 15                	jmp    801148 <strtol+0x4d>
	else if (*s == '-')
  801133:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80113a:	3c 2d                	cmp    $0x2d,%al
  80113c:	75 0a                	jne    801148 <strtol+0x4d>
		s++, neg = 1;
  80113e:	83 c2 01             	add    $0x1,%edx
  801141:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801148:	85 db                	test   %ebx,%ebx
  80114a:	0f 94 c0             	sete   %al
  80114d:	74 05                	je     801154 <strtol+0x59>
  80114f:	83 fb 10             	cmp    $0x10,%ebx
  801152:	75 18                	jne    80116c <strtol+0x71>
  801154:	80 3a 30             	cmpb   $0x30,(%edx)
  801157:	75 13                	jne    80116c <strtol+0x71>
  801159:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
  801160:	75 0a                	jne    80116c <strtol+0x71>
		s += 2, base = 16;
  801162:	83 c2 02             	add    $0x2,%edx
  801165:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80116a:	eb 15                	jmp    801181 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80116c:	84 c0                	test   %al,%al
  80116e:	66 90                	xchg   %ax,%ax
  801170:	74 0f                	je     801181 <strtol+0x86>
  801172:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801177:	80 3a 30             	cmpb   $0x30,(%edx)
  80117a:	75 05                	jne    801181 <strtol+0x86>
		s++, base = 8;
  80117c:	83 c2 01             	add    $0x1,%edx
  80117f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801181:	b8 00 00 00 00       	mov    $0x0,%eax
  801186:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801188:	0f b6 0a             	movzbl (%edx),%ecx
  80118b:	89 cf                	mov    %ecx,%edi
  80118d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801190:	80 fb 09             	cmp    $0x9,%bl
  801193:	77 08                	ja     80119d <strtol+0xa2>
			dig = *s - '0';
  801195:	0f be c9             	movsbl %cl,%ecx
  801198:	83 e9 30             	sub    $0x30,%ecx
  80119b:	eb 1e                	jmp    8011bb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80119d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8011a0:	80 fb 19             	cmp    $0x19,%bl
  8011a3:	77 08                	ja     8011ad <strtol+0xb2>
			dig = *s - 'a' + 10;
  8011a5:	0f be c9             	movsbl %cl,%ecx
  8011a8:	83 e9 57             	sub    $0x57,%ecx
  8011ab:	eb 0e                	jmp    8011bb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8011ad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8011b0:	80 fb 19             	cmp    $0x19,%bl
  8011b3:	77 15                	ja     8011ca <strtol+0xcf>
			dig = *s - 'A' + 10;
  8011b5:	0f be c9             	movsbl %cl,%ecx
  8011b8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8011bb:	39 f1                	cmp    %esi,%ecx
  8011bd:	7d 0b                	jge    8011ca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8011bf:	83 c2 01             	add    $0x1,%edx
  8011c2:	0f af c6             	imul   %esi,%eax
  8011c5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8011c8:	eb be                	jmp    801188 <strtol+0x8d>
  8011ca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8011cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011d0:	74 05                	je     8011d7 <strtol+0xdc>
		*endptr = (char *) s;
  8011d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011d5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8011d7:	89 ca                	mov    %ecx,%edx
  8011d9:	f7 da                	neg    %edx
  8011db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011df:	0f 45 c2             	cmovne %edx,%eax
}
  8011e2:	83 c4 04             	add    $0x4,%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    
	...

008011ec <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	83 ec 48             	sub    $0x48,%esp
  8011f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8011f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8011f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8011fb:	89 c6                	mov    %eax,%esi
  8011fd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801200:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801202:	8b 7d 10             	mov    0x10(%ebp),%edi
  801205:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801208:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120b:	51                   	push   %ecx
  80120c:	52                   	push   %edx
  80120d:	53                   	push   %ebx
  80120e:	54                   	push   %esp
  80120f:	55                   	push   %ebp
  801210:	56                   	push   %esi
  801211:	57                   	push   %edi
  801212:	89 e5                	mov    %esp,%ebp
  801214:	8d 35 1c 12 80 00    	lea    0x80121c,%esi
  80121a:	0f 34                	sysenter 

0080121c <.after_sysenter_label>:
  80121c:	5f                   	pop    %edi
  80121d:	5e                   	pop    %esi
  80121e:	5d                   	pop    %ebp
  80121f:	5c                   	pop    %esp
  801220:	5b                   	pop    %ebx
  801221:	5a                   	pop    %edx
  801222:	59                   	pop    %ecx
  801223:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801225:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801229:	74 28                	je     801253 <.after_sysenter_label+0x37>
  80122b:	85 c0                	test   %eax,%eax
  80122d:	7e 24                	jle    801253 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801233:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801237:	c7 44 24 08 00 35 80 	movl   $0x803500,0x8(%esp)
  80123e:	00 
  80123f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801246:	00 
  801247:	c7 04 24 1d 35 80 00 	movl   $0x80351d,(%esp)
  80124e:	e8 b1 f3 ff ff       	call   800604 <_panic>

	return ret;
}
  801253:	89 d0                	mov    %edx,%eax
  801255:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801258:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80125b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80125e:	89 ec                	mov    %ebp,%esp
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  801268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80126f:	00 
  801270:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801277:	00 
  801278:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80127f:	00 
  801280:	8b 45 0c             	mov    0xc(%ebp),%eax
  801283:	89 04 24             	mov    %eax,(%esp)
  801286:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801289:	ba 00 00 00 00       	mov    $0x0,%edx
  80128e:	b8 10 00 00 00       	mov    $0x10,%eax
  801293:	e8 54 ff ff ff       	call   8011ec <syscall>
}
  801298:	c9                   	leave  
  801299:	c3                   	ret    

0080129a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  80129a:	55                   	push   %ebp
  80129b:	89 e5                	mov    %esp,%ebp
  80129d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  8012a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012a7:	00 
  8012a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012af:	00 
  8012b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012b7:	00 
  8012b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012c9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8012ce:	e8 19 ff ff ff       	call   8011ec <syscall>
}
  8012d3:	c9                   	leave  
  8012d4:	c3                   	ret    

008012d5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8012db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012e2:	00 
  8012e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012ea:	00 
  8012eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012f2:	00 
  8012f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fd:	ba 01 00 00 00       	mov    $0x1,%edx
  801302:	b8 0e 00 00 00       	mov    $0xe,%eax
  801307:	e8 e0 fe ff ff       	call   8011ec <syscall>
}
  80130c:	c9                   	leave  
  80130d:	c3                   	ret    

0080130e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80130e:	55                   	push   %ebp
  80130f:	89 e5                	mov    %esp,%ebp
  801311:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801314:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80131b:	00 
  80131c:	8b 45 14             	mov    0x14(%ebp),%eax
  80131f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801323:	8b 45 10             	mov    0x10(%ebp),%eax
  801326:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132d:	89 04 24             	mov    %eax,(%esp)
  801330:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801333:	ba 00 00 00 00       	mov    $0x0,%edx
  801338:	b8 0d 00 00 00       	mov    $0xd,%eax
  80133d:	e8 aa fe ff ff       	call   8011ec <syscall>
}
  801342:	c9                   	leave  
  801343:	c3                   	ret    

00801344 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80134a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801351:	00 
  801352:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801359:	00 
  80135a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801361:	00 
  801362:	8b 45 0c             	mov    0xc(%ebp),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80136b:	ba 01 00 00 00       	mov    $0x1,%edx
  801370:	b8 0b 00 00 00       	mov    $0xb,%eax
  801375:	e8 72 fe ff ff       	call   8011ec <syscall>
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801382:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801389:	00 
  80138a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801391:	00 
  801392:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801399:	00 
  80139a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139d:	89 04 24             	mov    %eax,(%esp)
  8013a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013a3:	ba 01 00 00 00       	mov    $0x1,%edx
  8013a8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8013ad:	e8 3a fe ff ff       	call   8011ec <syscall>
}
  8013b2:	c9                   	leave  
  8013b3:	c3                   	ret    

008013b4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8013ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013c1:	00 
  8013c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013c9:	00 
  8013ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013d1:	00 
  8013d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d5:	89 04 24             	mov    %eax,(%esp)
  8013d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013db:	ba 01 00 00 00       	mov    $0x1,%edx
  8013e0:	b8 09 00 00 00       	mov    $0x9,%eax
  8013e5:	e8 02 fe ff ff       	call   8011ec <syscall>
}
  8013ea:	c9                   	leave  
  8013eb:	c3                   	ret    

008013ec <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8013f2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013f9:	00 
  8013fa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801401:	00 
  801402:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801409:	00 
  80140a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140d:	89 04 24             	mov    %eax,(%esp)
  801410:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801413:	ba 01 00 00 00       	mov    $0x1,%edx
  801418:	b8 07 00 00 00       	mov    $0x7,%eax
  80141d:	e8 ca fd ff ff       	call   8011ec <syscall>
}
  801422:	c9                   	leave  
  801423:	c3                   	ret    

00801424 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801424:	55                   	push   %ebp
  801425:	89 e5                	mov    %esp,%ebp
  801427:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  80142a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801431:	00 
  801432:	8b 45 18             	mov    0x18(%ebp),%eax
  801435:	0b 45 14             	or     0x14(%ebp),%eax
  801438:	89 44 24 08          	mov    %eax,0x8(%esp)
  80143c:	8b 45 10             	mov    0x10(%ebp),%eax
  80143f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801443:	8b 45 0c             	mov    0xc(%ebp),%eax
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80144c:	ba 01 00 00 00       	mov    $0x1,%edx
  801451:	b8 06 00 00 00       	mov    $0x6,%eax
  801456:	e8 91 fd ff ff       	call   8011ec <syscall>
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801463:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80146a:	00 
  80146b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801472:	00 
  801473:	8b 45 10             	mov    0x10(%ebp),%eax
  801476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147d:	89 04 24             	mov    %eax,(%esp)
  801480:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801483:	ba 01 00 00 00       	mov    $0x1,%edx
  801488:	b8 05 00 00 00       	mov    $0x5,%eax
  80148d:	e8 5a fd ff ff       	call   8011ec <syscall>
}
  801492:	c9                   	leave  
  801493:	c3                   	ret    

00801494 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  801494:	55                   	push   %ebp
  801495:	89 e5                	mov    %esp,%ebp
  801497:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80149a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014a1:	00 
  8014a2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014a9:	00 
  8014aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014b1:	00 
  8014b2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014be:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014c8:	e8 1f fd ff ff       	call   8011ec <syscall>
}
  8014cd:	c9                   	leave  
  8014ce:	c3                   	ret    

008014cf <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8014cf:	55                   	push   %ebp
  8014d0:	89 e5                	mov    %esp,%ebp
  8014d2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8014d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014dc:	00 
  8014dd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014e4:	00 
  8014e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014ec:	00 
  8014ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f0:	89 04 24             	mov    %eax,(%esp)
  8014f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014fb:	b8 04 00 00 00       	mov    $0x4,%eax
  801500:	e8 e7 fc ff ff       	call   8011ec <syscall>
}
  801505:	c9                   	leave  
  801506:	c3                   	ret    

00801507 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80150d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801514:	00 
  801515:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80151c:	00 
  80151d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801524:	00 
  801525:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80152c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801531:	ba 00 00 00 00       	mov    $0x0,%edx
  801536:	b8 02 00 00 00       	mov    $0x2,%eax
  80153b:	e8 ac fc ff ff       	call   8011ec <syscall>
}
  801540:	c9                   	leave  
  801541:	c3                   	ret    

00801542 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801548:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80154f:	00 
  801550:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801557:	00 
  801558:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80155f:	00 
  801560:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801567:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156a:	ba 01 00 00 00       	mov    $0x1,%edx
  80156f:	b8 03 00 00 00       	mov    $0x3,%eax
  801574:	e8 73 fc ff ff       	call   8011ec <syscall>
}
  801579:	c9                   	leave  
  80157a:	c3                   	ret    

0080157b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801581:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801588:	00 
  801589:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801590:	00 
  801591:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801598:	00 
  801599:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8015af:	e8 38 fc ff ff       	call   8011ec <syscall>
}
  8015b4:	c9                   	leave  
  8015b5:	c3                   	ret    

008015b6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015b6:	55                   	push   %ebp
  8015b7:	89 e5                	mov    %esp,%ebp
  8015b9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8015bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015c3:	00 
  8015c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015cb:	00 
  8015cc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015d3:	00 
  8015d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d7:	89 04 24             	mov    %eax,(%esp)
  8015da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015e7:	e8 00 fc ff ff       	call   8011ec <syscall>
}
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    
	...

008015f0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8015f6:	c7 44 24 08 2b 35 80 	movl   $0x80352b,0x8(%esp)
  8015fd:	00 
  8015fe:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801605:	00 
  801606:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  80160d:	e8 f2 ef ff ff       	call   800604 <_panic>

00801612 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	57                   	push   %edi
  801616:	56                   	push   %esi
  801617:	53                   	push   %ebx
  801618:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  80161b:	c7 04 24 d6 18 80 00 	movl   $0x8018d6,(%esp)
  801622:	e8 5d 13 00 00       	call   802984 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801627:	ba 08 00 00 00       	mov    $0x8,%edx
  80162c:	89 d0                	mov    %edx,%eax
  80162e:	51                   	push   %ecx
  80162f:	52                   	push   %edx
  801630:	53                   	push   %ebx
  801631:	55                   	push   %ebp
  801632:	56                   	push   %esi
  801633:	57                   	push   %edi
  801634:	89 e5                	mov    %esp,%ebp
  801636:	8d 35 3e 16 80 00    	lea    0x80163e,%esi
  80163c:	0f 34                	sysenter 

0080163e <.after_sysenter_label>:
  80163e:	5f                   	pop    %edi
  80163f:	5e                   	pop    %esi
  801640:	5d                   	pop    %ebp
  801641:	5b                   	pop    %ebx
  801642:	5a                   	pop    %edx
  801643:	59                   	pop    %ecx
  801644:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801647:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80164b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  801652:	00 
  801653:	c7 44 24 04 41 35 80 	movl   $0x803541,0x4(%esp)
  80165a:	00 
  80165b:	c7 04 24 88 35 80 00 	movl   $0x803588,(%esp)
  801662:	e8 56 f0 ff ff       	call   8006bd <cprintf>
	if (envidnum < 0)
  801667:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80166b:	79 23                	jns    801690 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80166d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801670:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801674:	c7 44 24 08 4c 35 80 	movl   $0x80354c,0x8(%esp)
  80167b:	00 
  80167c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801683:	00 
  801684:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  80168b:	e8 74 ef ff ff       	call   800604 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801690:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801695:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80169a:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80169f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8016a3:	75 1c                	jne    8016c1 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  8016a5:	e8 5d fe ff ff       	call   801507 <sys_getenvid>
  8016aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8016af:	c1 e0 07             	shl    $0x7,%eax
  8016b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8016b7:	a3 20 50 80 00       	mov    %eax,0x805020
		return 0;
  8016bc:	e9 0a 02 00 00       	jmp    8018cb <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8016c1:	89 d8                	mov    %ebx,%eax
  8016c3:	c1 e8 16             	shr    $0x16,%eax
  8016c6:	8b 04 86             	mov    (%esi,%eax,4),%eax
  8016c9:	a8 01                	test   $0x1,%al
  8016cb:	0f 84 43 01 00 00    	je     801814 <.after_sysenter_label+0x1d6>
  8016d1:	89 d8                	mov    %ebx,%eax
  8016d3:	c1 e8 0c             	shr    $0xc,%eax
  8016d6:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8016d9:	f6 c2 01             	test   $0x1,%dl
  8016dc:	0f 84 32 01 00 00    	je     801814 <.after_sysenter_label+0x1d6>
  8016e2:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8016e5:	f6 c2 04             	test   $0x4,%dl
  8016e8:	0f 84 26 01 00 00    	je     801814 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  8016ee:	c1 e0 0c             	shl    $0xc,%eax
  8016f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  8016f4:	c1 e8 0c             	shr    $0xc,%eax
  8016f7:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  8016fa:	89 c2                	mov    %eax,%edx
  8016fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  801702:	a9 02 08 00 00       	test   $0x802,%eax
  801707:	0f 84 a0 00 00 00    	je     8017ad <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  80170d:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  801710:	80 ce 08             	or     $0x8,%dh
  801713:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801716:	89 54 24 10          	mov    %edx,0x10(%esp)
  80171a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80171d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801721:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801724:	89 44 24 08          	mov    %eax,0x8(%esp)
  801728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80172b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801736:	e8 e9 fc ff ff       	call   801424 <sys_page_map>
  80173b:	85 c0                	test   %eax,%eax
  80173d:	79 20                	jns    80175f <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80173f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801743:	c7 44 24 08 b0 35 80 	movl   $0x8035b0,0x8(%esp)
  80174a:	00 
  80174b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801752:	00 
  801753:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  80175a:	e8 a5 ee ff ff       	call   800604 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80175f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801762:	89 44 24 10          	mov    %eax,0x10(%esp)
  801766:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801769:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80176d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801774:	00 
  801775:	89 44 24 04          	mov    %eax,0x4(%esp)
  801779:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801780:	e8 9f fc ff ff       	call   801424 <sys_page_map>
  801785:	85 c0                	test   %eax,%eax
  801787:	0f 89 87 00 00 00    	jns    801814 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  80178d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801791:	c7 44 24 08 dc 35 80 	movl   $0x8035dc,0x8(%esp)
  801798:	00 
  801799:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8017a0:	00 
  8017a1:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  8017a8:	e8 57 ee ff ff       	call   800604 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  8017ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017bb:	c7 04 24 5c 35 80 00 	movl   $0x80355c,(%esp)
  8017c2:	e8 f6 ee ff ff       	call   8006bd <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  8017c7:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  8017ce:	00 
  8017cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017eb:	e8 34 fc ff ff       	call   801424 <sys_page_map>
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	79 20                	jns    801814 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  8017f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f8:	c7 44 24 08 08 36 80 	movl   $0x803608,0x8(%esp)
  8017ff:	00 
  801800:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801807:	00 
  801808:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  80180f:	e8 f0 ed ff ff       	call   800604 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801814:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80181a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801820:	0f 85 9b fe ff ff    	jne    8016c1 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801826:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80182d:	00 
  80182e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801835:	ee 
  801836:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801839:	89 04 24             	mov    %eax,(%esp)
  80183c:	e8 1c fc ff ff       	call   80145d <sys_page_alloc>
  801841:	85 c0                	test   %eax,%eax
  801843:	79 20                	jns    801865 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801845:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801849:	c7 44 24 08 34 36 80 	movl   $0x803634,0x8(%esp)
  801850:	00 
  801851:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801858:	00 
  801859:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  801860:	e8 9f ed ff ff       	call   800604 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801865:	c7 44 24 04 f4 29 80 	movl   $0x8029f4,0x4(%esp)
  80186c:	00 
  80186d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801870:	89 04 24             	mov    %eax,(%esp)
  801873:	e8 cc fa ff ff       	call   801344 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801878:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80187f:	00 
  801880:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801883:	89 04 24             	mov    %eax,(%esp)
  801886:	e8 29 fb ff ff       	call   8013b4 <sys_env_set_status>
  80188b:	85 c0                	test   %eax,%eax
  80188d:	79 20                	jns    8018af <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80188f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801893:	c7 44 24 08 58 36 80 	movl   $0x803658,0x8(%esp)
  80189a:	00 
  80189b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8018a2:	00 
  8018a3:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  8018aa:	e8 55 ed ff ff       	call   800604 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  8018af:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  8018b6:	00 
  8018b7:	c7 44 24 04 41 35 80 	movl   $0x803541,0x4(%esp)
  8018be:	00 
  8018bf:	c7 04 24 6e 35 80 00 	movl   $0x80356e,(%esp)
  8018c6:	e8 f2 ed ff ff       	call   8006bd <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  8018cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8018ce:	83 c4 3c             	add    $0x3c,%esp
  8018d1:	5b                   	pop    %ebx
  8018d2:	5e                   	pop    %esi
  8018d3:	5f                   	pop    %edi
  8018d4:	5d                   	pop    %ebp
  8018d5:	c3                   	ret    

008018d6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 24             	sub    $0x24,%esp
  8018dd:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8018e0:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8018e2:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  8018e5:	f6 c2 02             	test   $0x2,%dl
  8018e8:	75 2b                	jne    801915 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  8018ea:	8b 40 28             	mov    0x28(%eax),%eax
  8018ed:	89 44 24 14          	mov    %eax,0x14(%esp)
  8018f1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8018f5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018f9:	c7 44 24 08 80 36 80 	movl   $0x803680,0x8(%esp)
  801900:	00 
  801901:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801908:	00 
  801909:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  801910:	e8 ef ec ff ff       	call   800604 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801915:	89 d8                	mov    %ebx,%eax
  801917:	c1 e8 16             	shr    $0x16,%eax
  80191a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801921:	a8 01                	test   $0x1,%al
  801923:	74 11                	je     801936 <pgfault+0x60>
  801925:	89 d8                	mov    %ebx,%eax
  801927:	c1 e8 0c             	shr    $0xc,%eax
  80192a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801931:	f6 c4 08             	test   $0x8,%ah
  801934:	75 1c                	jne    801952 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  801936:	c7 44 24 08 bc 36 80 	movl   $0x8036bc,0x8(%esp)
  80193d:	00 
  80193e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801945:	00 
  801946:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  80194d:	e8 b2 ec ff ff       	call   800604 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801952:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801959:	00 
  80195a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801961:	00 
  801962:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801969:	e8 ef fa ff ff       	call   80145d <sys_page_alloc>
  80196e:	85 c0                	test   %eax,%eax
  801970:	79 20                	jns    801992 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  801972:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801976:	c7 44 24 08 f8 36 80 	movl   $0x8036f8,0x8(%esp)
  80197d:	00 
  80197e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801985:	00 
  801986:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  80198d:	e8 72 ec ff ff       	call   800604 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801992:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  801998:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80199f:	00 
  8019a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019a4:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  8019ab:	e8 35 f6 ff ff       	call   800fe5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  8019b0:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8019b7:	00 
  8019b8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8019bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8019c3:	00 
  8019c4:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8019cb:	00 
  8019cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019d3:	e8 4c fa ff ff       	call   801424 <sys_page_map>
  8019d8:	85 c0                	test   %eax,%eax
  8019da:	79 20                	jns    8019fc <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  8019dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e0:	c7 44 24 08 20 37 80 	movl   $0x803720,0x8(%esp)
  8019e7:	00 
  8019e8:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8019ef:	00 
  8019f0:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  8019f7:	e8 08 ec ff ff       	call   800604 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  8019fc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801a03:	00 
  801a04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a0b:	e8 dc f9 ff ff       	call   8013ec <sys_page_unmap>
  801a10:	85 c0                	test   %eax,%eax
  801a12:	79 20                	jns    801a34 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  801a14:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a18:	c7 44 24 08 44 37 80 	movl   $0x803744,0x8(%esp)
  801a1f:	00 
  801a20:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801a27:	00 
  801a28:	c7 04 24 41 35 80 00 	movl   $0x803541,(%esp)
  801a2f:	e8 d0 eb ff ff       	call   800604 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801a34:	83 c4 24             	add    $0x24,%esp
  801a37:	5b                   	pop    %ebx
  801a38:	5d                   	pop    %ebp
  801a39:	c3                   	ret    
  801a3a:	00 00                	add    %al,(%eax)
  801a3c:	00 00                	add    %al,(%eax)
	...

00801a40 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a46:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801a4c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a51:	39 ca                	cmp    %ecx,%edx
  801a53:	75 04                	jne    801a59 <ipc_find_env+0x19>
  801a55:	b0 00                	mov    $0x0,%al
  801a57:	eb 11                	jmp    801a6a <ipc_find_env+0x2a>
  801a59:	89 c2                	mov    %eax,%edx
  801a5b:	c1 e2 07             	shl    $0x7,%edx
  801a5e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801a64:	8b 12                	mov    (%edx),%edx
  801a66:	39 ca                	cmp    %ecx,%edx
  801a68:	75 0f                	jne    801a79 <ipc_find_env+0x39>
			return envs[i].env_id;
  801a6a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801a6e:	c1 e0 06             	shl    $0x6,%eax
  801a71:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801a77:	eb 0e                	jmp    801a87 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a79:	83 c0 01             	add    $0x1,%eax
  801a7c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a81:	75 d6                	jne    801a59 <ipc_find_env+0x19>
  801a83:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801a87:	5d                   	pop    %ebp
  801a88:	c3                   	ret    

00801a89 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	57                   	push   %edi
  801a8d:	56                   	push   %esi
  801a8e:	53                   	push   %ebx
  801a8f:	83 ec 1c             	sub    $0x1c,%esp
  801a92:	8b 75 08             	mov    0x8(%ebp),%esi
  801a95:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a9b:	85 db                	test   %ebx,%ebx
  801a9d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801aa2:	0f 44 d8             	cmove  %eax,%ebx
  801aa5:	eb 25                	jmp    801acc <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801aa7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aaa:	74 20                	je     801acc <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801aac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ab0:	c7 44 24 08 68 37 80 	movl   $0x803768,0x8(%esp)
  801ab7:	00 
  801ab8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801abf:	00 
  801ac0:	c7 04 24 86 37 80 00 	movl   $0x803786,(%esp)
  801ac7:	e8 38 eb ff ff       	call   800604 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801acc:	8b 45 14             	mov    0x14(%ebp),%eax
  801acf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ad3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ad7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801adb:	89 34 24             	mov    %esi,(%esp)
  801ade:	e8 2b f8 ff ff       	call   80130e <sys_ipc_try_send>
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	75 c0                	jne    801aa7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801ae7:	e8 a8 f9 ff ff       	call   801494 <sys_yield>
}
  801aec:	83 c4 1c             	add    $0x1c,%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5f                   	pop    %edi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	83 ec 28             	sub    $0x28,%esp
  801afa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801afd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801b00:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801b03:	8b 75 08             	mov    0x8(%ebp),%esi
  801b06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b09:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b13:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801b16:	89 04 24             	mov    %eax,(%esp)
  801b19:	e8 b7 f7 ff ff       	call   8012d5 <sys_ipc_recv>
  801b1e:	89 c3                	mov    %eax,%ebx
  801b20:	85 c0                	test   %eax,%eax
  801b22:	79 2a                	jns    801b4e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801b24:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b28:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b2c:	c7 04 24 90 37 80 00 	movl   $0x803790,(%esp)
  801b33:	e8 85 eb ff ff       	call   8006bd <cprintf>
		if(from_env_store != NULL)
  801b38:	85 f6                	test   %esi,%esi
  801b3a:	74 06                	je     801b42 <ipc_recv+0x4e>
			*from_env_store = 0;
  801b3c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b42:	85 ff                	test   %edi,%edi
  801b44:	74 2c                	je     801b72 <ipc_recv+0x7e>
			*perm_store = 0;
  801b46:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b4c:	eb 24                	jmp    801b72 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801b4e:	85 f6                	test   %esi,%esi
  801b50:	74 0a                	je     801b5c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801b52:	a1 20 50 80 00       	mov    0x805020,%eax
  801b57:	8b 40 74             	mov    0x74(%eax),%eax
  801b5a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b5c:	85 ff                	test   %edi,%edi
  801b5e:	74 0a                	je     801b6a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801b60:	a1 20 50 80 00       	mov    0x805020,%eax
  801b65:	8b 40 78             	mov    0x78(%eax),%eax
  801b68:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b6a:	a1 20 50 80 00       	mov    0x805020,%eax
  801b6f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801b72:	89 d8                	mov    %ebx,%eax
  801b74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b77:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b7d:	89 ec                	mov    %ebp,%esp
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    
	...

00801b90 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	8b 45 08             	mov    0x8(%ebp),%eax
  801b96:	05 00 00 00 30       	add    $0x30000000,%eax
  801b9b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801ba6:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba9:	89 04 24             	mov    %eax,(%esp)
  801bac:	e8 df ff ff ff       	call   801b90 <fd2num>
  801bb1:	05 20 00 0d 00       	add    $0xd0020,%eax
  801bb6:	c1 e0 0c             	shl    $0xc,%eax
}
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	57                   	push   %edi
  801bbf:	56                   	push   %esi
  801bc0:	53                   	push   %ebx
  801bc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801bc4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801bc9:	a8 01                	test   $0x1,%al
  801bcb:	74 36                	je     801c03 <fd_alloc+0x48>
  801bcd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801bd2:	a8 01                	test   $0x1,%al
  801bd4:	74 2d                	je     801c03 <fd_alloc+0x48>
  801bd6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  801bdb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801be0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801be5:	89 c3                	mov    %eax,%ebx
  801be7:	89 c2                	mov    %eax,%edx
  801be9:	c1 ea 16             	shr    $0x16,%edx
  801bec:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  801bef:	f6 c2 01             	test   $0x1,%dl
  801bf2:	74 14                	je     801c08 <fd_alloc+0x4d>
  801bf4:	89 c2                	mov    %eax,%edx
  801bf6:	c1 ea 0c             	shr    $0xc,%edx
  801bf9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  801bfc:	f6 c2 01             	test   $0x1,%dl
  801bff:	75 10                	jne    801c11 <fd_alloc+0x56>
  801c01:	eb 05                	jmp    801c08 <fd_alloc+0x4d>
  801c03:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801c08:	89 1f                	mov    %ebx,(%edi)
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801c0f:	eb 17                	jmp    801c28 <fd_alloc+0x6d>
  801c11:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c16:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c1b:	75 c8                	jne    801be5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c1d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801c23:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5f                   	pop    %edi
  801c2b:	5d                   	pop    %ebp
  801c2c:	c3                   	ret    

00801c2d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c2d:	55                   	push   %ebp
  801c2e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	83 f8 1f             	cmp    $0x1f,%eax
  801c36:	77 36                	ja     801c6e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c38:	05 00 00 0d 00       	add    $0xd0000,%eax
  801c3d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801c40:	89 c2                	mov    %eax,%edx
  801c42:	c1 ea 16             	shr    $0x16,%edx
  801c45:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c4c:	f6 c2 01             	test   $0x1,%dl
  801c4f:	74 1d                	je     801c6e <fd_lookup+0x41>
  801c51:	89 c2                	mov    %eax,%edx
  801c53:	c1 ea 0c             	shr    $0xc,%edx
  801c56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c5d:	f6 c2 01             	test   $0x1,%dl
  801c60:	74 0c                	je     801c6e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c62:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c65:	89 02                	mov    %eax,(%edx)
  801c67:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  801c6c:	eb 05                	jmp    801c73 <fd_lookup+0x46>
  801c6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	89 04 24             	mov    %eax,(%esp)
  801c88:	e8 a0 ff ff ff       	call   801c2d <fd_lookup>
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	78 0e                	js     801c9f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801c91:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801c94:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c97:	89 50 04             	mov    %edx,0x4(%eax)
  801c9a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c9f:	c9                   	leave  
  801ca0:	c3                   	ret    

00801ca1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801ca1:	55                   	push   %ebp
  801ca2:	89 e5                	mov    %esp,%ebp
  801ca4:	56                   	push   %esi
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 10             	sub    $0x10,%esp
  801ca9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  801caf:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801cb4:	b8 04 40 80 00       	mov    $0x804004,%eax
  801cb9:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  801cbf:	75 11                	jne    801cd2 <dev_lookup+0x31>
  801cc1:	eb 04                	jmp    801cc7 <dev_lookup+0x26>
  801cc3:	39 08                	cmp    %ecx,(%eax)
  801cc5:	75 10                	jne    801cd7 <dev_lookup+0x36>
			*dev = devtab[i];
  801cc7:	89 03                	mov    %eax,(%ebx)
  801cc9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  801cce:	66 90                	xchg   %ax,%ax
  801cd0:	eb 36                	jmp    801d08 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801cd2:	be 24 38 80 00       	mov    $0x803824,%esi
  801cd7:	83 c2 01             	add    $0x1,%edx
  801cda:	8b 04 96             	mov    (%esi,%edx,4),%eax
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	75 e2                	jne    801cc3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801ce1:	a1 20 50 80 00       	mov    0x805020,%eax
  801ce6:	8b 40 48             	mov    0x48(%eax),%eax
  801ce9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ced:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cf1:	c7 04 24 a4 37 80 00 	movl   $0x8037a4,(%esp)
  801cf8:	e8 c0 e9 ff ff       	call   8006bd <cprintf>
	*dev = 0;
  801cfd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801d03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	5b                   	pop    %ebx
  801d0c:	5e                   	pop    %esi
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    

00801d0f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	53                   	push   %ebx
  801d13:	83 ec 24             	sub    $0x24,%esp
  801d16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d19:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d20:	8b 45 08             	mov    0x8(%ebp),%eax
  801d23:	89 04 24             	mov    %eax,(%esp)
  801d26:	e8 02 ff ff ff       	call   801c2d <fd_lookup>
  801d2b:	85 c0                	test   %eax,%eax
  801d2d:	78 53                	js     801d82 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801d2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d39:	8b 00                	mov    (%eax),%eax
  801d3b:	89 04 24             	mov    %eax,(%esp)
  801d3e:	e8 5e ff ff ff       	call   801ca1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 3b                	js     801d82 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801d47:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801d4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d4f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801d53:	74 2d                	je     801d82 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801d55:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801d58:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801d5f:	00 00 00 
	stat->st_isdir = 0;
  801d62:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d69:	00 00 00 
	stat->st_dev = dev;
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801d75:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d79:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d7c:	89 14 24             	mov    %edx,(%esp)
  801d7f:	ff 50 14             	call   *0x14(%eax)
}
  801d82:	83 c4 24             	add    $0x24,%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5d                   	pop    %ebp
  801d87:	c3                   	ret    

00801d88 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	53                   	push   %ebx
  801d8c:	83 ec 24             	sub    $0x24,%esp
  801d8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801d92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d99:	89 1c 24             	mov    %ebx,(%esp)
  801d9c:	e8 8c fe ff ff       	call   801c2d <fd_lookup>
  801da1:	85 c0                	test   %eax,%eax
  801da3:	78 5f                	js     801e04 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801da5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801daf:	8b 00                	mov    (%eax),%eax
  801db1:	89 04 24             	mov    %eax,(%esp)
  801db4:	e8 e8 fe ff ff       	call   801ca1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801db9:	85 c0                	test   %eax,%eax
  801dbb:	78 47                	js     801e04 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801dbd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dc0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801dc4:	75 23                	jne    801de9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801dc6:	a1 20 50 80 00       	mov    0x805020,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801dcb:	8b 40 48             	mov    0x48(%eax),%eax
  801dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dd6:	c7 04 24 c4 37 80 00 	movl   $0x8037c4,(%esp)
  801ddd:	e8 db e8 ff ff       	call   8006bd <cprintf>
  801de2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801de7:	eb 1b                	jmp    801e04 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dec:	8b 48 18             	mov    0x18(%eax),%ecx
  801def:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801df4:	85 c9                	test   %ecx,%ecx
  801df6:	74 0c                	je     801e04 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dff:	89 14 24             	mov    %edx,(%esp)
  801e02:	ff d1                	call   *%ecx
}
  801e04:	83 c4 24             	add    $0x24,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5d                   	pop    %ebp
  801e09:	c3                   	ret    

00801e0a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	53                   	push   %ebx
  801e0e:	83 ec 24             	sub    $0x24,%esp
  801e11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e14:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e1b:	89 1c 24             	mov    %ebx,(%esp)
  801e1e:	e8 0a fe ff ff       	call   801c2d <fd_lookup>
  801e23:	85 c0                	test   %eax,%eax
  801e25:	78 66                	js     801e8d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e31:	8b 00                	mov    (%eax),%eax
  801e33:	89 04 24             	mov    %eax,(%esp)
  801e36:	e8 66 fe ff ff       	call   801ca1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 4e                	js     801e8d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801e3f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e42:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801e46:	75 23                	jne    801e6b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801e48:	a1 20 50 80 00       	mov    0x805020,%eax
  801e4d:	8b 40 48             	mov    0x48(%eax),%eax
  801e50:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e54:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e58:	c7 04 24 e8 37 80 00 	movl   $0x8037e8,(%esp)
  801e5f:	e8 59 e8 ff ff       	call   8006bd <cprintf>
  801e64:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801e69:	eb 22                	jmp    801e8d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801e71:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801e76:	85 c9                	test   %ecx,%ecx
  801e78:	74 13                	je     801e8d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801e7a:	8b 45 10             	mov    0x10(%ebp),%eax
  801e7d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e81:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e84:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e88:	89 14 24             	mov    %edx,(%esp)
  801e8b:	ff d1                	call   *%ecx
}
  801e8d:	83 c4 24             	add    $0x24,%esp
  801e90:	5b                   	pop    %ebx
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    

00801e93 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	53                   	push   %ebx
  801e97:	83 ec 24             	sub    $0x24,%esp
  801e9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801e9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ea4:	89 1c 24             	mov    %ebx,(%esp)
  801ea7:	e8 81 fd ff ff       	call   801c2d <fd_lookup>
  801eac:	85 c0                	test   %eax,%eax
  801eae:	78 6b                	js     801f1b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eba:	8b 00                	mov    (%eax),%eax
  801ebc:	89 04 24             	mov    %eax,(%esp)
  801ebf:	e8 dd fd ff ff       	call   801ca1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 53                	js     801f1b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ec8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ecb:	8b 42 08             	mov    0x8(%edx),%eax
  801ece:	83 e0 03             	and    $0x3,%eax
  801ed1:	83 f8 01             	cmp    $0x1,%eax
  801ed4:	75 23                	jne    801ef9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801ed6:	a1 20 50 80 00       	mov    0x805020,%eax
  801edb:	8b 40 48             	mov    0x48(%eax),%eax
  801ede:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ee2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ee6:	c7 04 24 05 38 80 00 	movl   $0x803805,(%esp)
  801eed:	e8 cb e7 ff ff       	call   8006bd <cprintf>
  801ef2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801ef7:	eb 22                	jmp    801f1b <read+0x88>
	}
	if (!dev->dev_read)
  801ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efc:	8b 48 08             	mov    0x8(%eax),%ecx
  801eff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f04:	85 c9                	test   %ecx,%ecx
  801f06:	74 13                	je     801f1b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f08:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f12:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f16:	89 14 24             	mov    %edx,(%esp)
  801f19:	ff d1                	call   *%ecx
}
  801f1b:	83 c4 24             	add    $0x24,%esp
  801f1e:	5b                   	pop    %ebx
  801f1f:	5d                   	pop    %ebp
  801f20:	c3                   	ret    

00801f21 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	57                   	push   %edi
  801f25:	56                   	push   %esi
  801f26:	53                   	push   %ebx
  801f27:	83 ec 1c             	sub    $0x1c,%esp
  801f2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f30:	ba 00 00 00 00       	mov    $0x0,%edx
  801f35:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f3f:	85 f6                	test   %esi,%esi
  801f41:	74 29                	je     801f6c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f43:	89 f0                	mov    %esi,%eax
  801f45:	29 d0                	sub    %edx,%eax
  801f47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f4b:	03 55 0c             	add    0xc(%ebp),%edx
  801f4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f52:	89 3c 24             	mov    %edi,(%esp)
  801f55:	e8 39 ff ff ff       	call   801e93 <read>
		if (m < 0)
  801f5a:	85 c0                	test   %eax,%eax
  801f5c:	78 0e                	js     801f6c <readn+0x4b>
			return m;
		if (m == 0)
  801f5e:	85 c0                	test   %eax,%eax
  801f60:	74 08                	je     801f6a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f62:	01 c3                	add    %eax,%ebx
  801f64:	89 da                	mov    %ebx,%edx
  801f66:	39 f3                	cmp    %esi,%ebx
  801f68:	72 d9                	jb     801f43 <readn+0x22>
  801f6a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801f6c:	83 c4 1c             	add    $0x1c,%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 28             	sub    $0x28,%esp
  801f7a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f7d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f80:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f83:	89 34 24             	mov    %esi,(%esp)
  801f86:	e8 05 fc ff ff       	call   801b90 <fd2num>
  801f8b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f92:	89 04 24             	mov    %eax,(%esp)
  801f95:	e8 93 fc ff ff       	call   801c2d <fd_lookup>
  801f9a:	89 c3                	mov    %eax,%ebx
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	78 05                	js     801fa5 <fd_close+0x31>
  801fa0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801fa3:	74 0e                	je     801fb3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801fa5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fae:	0f 44 d8             	cmove  %eax,%ebx
  801fb1:	eb 3d                	jmp    801ff0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801fb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801fb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fba:	8b 06                	mov    (%esi),%eax
  801fbc:	89 04 24             	mov    %eax,(%esp)
  801fbf:	e8 dd fc ff ff       	call   801ca1 <dev_lookup>
  801fc4:	89 c3                	mov    %eax,%ebx
  801fc6:	85 c0                	test   %eax,%eax
  801fc8:	78 16                	js     801fe0 <fd_close+0x6c>
		if (dev->dev_close)
  801fca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fcd:	8b 40 10             	mov    0x10(%eax),%eax
  801fd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	74 07                	je     801fe0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801fd9:	89 34 24             	mov    %esi,(%esp)
  801fdc:	ff d0                	call   *%eax
  801fde:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801fe0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fe4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801feb:	e8 fc f3 ff ff       	call   8013ec <sys_page_unmap>
	return r;
}
  801ff0:	89 d8                	mov    %ebx,%eax
  801ff2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ff5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ff8:	89 ec                	mov    %ebp,%esp
  801ffa:	5d                   	pop    %ebp
  801ffb:	c3                   	ret    

00801ffc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801ffc:	55                   	push   %ebp
  801ffd:	89 e5                	mov    %esp,%ebp
  801fff:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802002:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802005:	89 44 24 04          	mov    %eax,0x4(%esp)
  802009:	8b 45 08             	mov    0x8(%ebp),%eax
  80200c:	89 04 24             	mov    %eax,(%esp)
  80200f:	e8 19 fc ff ff       	call   801c2d <fd_lookup>
  802014:	85 c0                	test   %eax,%eax
  802016:	78 13                	js     80202b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802018:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80201f:	00 
  802020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802023:	89 04 24             	mov    %eax,(%esp)
  802026:	e8 49 ff ff ff       	call   801f74 <fd_close>
}
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    

0080202d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80202d:	55                   	push   %ebp
  80202e:	89 e5                	mov    %esp,%ebp
  802030:	83 ec 18             	sub    $0x18,%esp
  802033:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802036:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802039:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802040:	00 
  802041:	8b 45 08             	mov    0x8(%ebp),%eax
  802044:	89 04 24             	mov    %eax,(%esp)
  802047:	e8 78 03 00 00       	call   8023c4 <open>
  80204c:	89 c3                	mov    %eax,%ebx
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 1b                	js     80206d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  802052:	8b 45 0c             	mov    0xc(%ebp),%eax
  802055:	89 44 24 04          	mov    %eax,0x4(%esp)
  802059:	89 1c 24             	mov    %ebx,(%esp)
  80205c:	e8 ae fc ff ff       	call   801d0f <fstat>
  802061:	89 c6                	mov    %eax,%esi
	close(fd);
  802063:	89 1c 24             	mov    %ebx,(%esp)
  802066:	e8 91 ff ff ff       	call   801ffc <close>
  80206b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80206d:	89 d8                	mov    %ebx,%eax
  80206f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802072:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802075:	89 ec                	mov    %ebp,%esp
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    

00802079 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	53                   	push   %ebx
  80207d:	83 ec 14             	sub    $0x14,%esp
  802080:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  802085:	89 1c 24             	mov    %ebx,(%esp)
  802088:	e8 6f ff ff ff       	call   801ffc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80208d:	83 c3 01             	add    $0x1,%ebx
  802090:	83 fb 20             	cmp    $0x20,%ebx
  802093:	75 f0                	jne    802085 <close_all+0xc>
		close(i);
}
  802095:	83 c4 14             	add    $0x14,%esp
  802098:	5b                   	pop    %ebx
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    

0080209b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	83 ec 58             	sub    $0x58,%esp
  8020a1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8020a4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8020a7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8020aa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8020ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8020b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020b7:	89 04 24             	mov    %eax,(%esp)
  8020ba:	e8 6e fb ff ff       	call   801c2d <fd_lookup>
  8020bf:	89 c3                	mov    %eax,%ebx
  8020c1:	85 c0                	test   %eax,%eax
  8020c3:	0f 88 e0 00 00 00    	js     8021a9 <dup+0x10e>
		return r;
	close(newfdnum);
  8020c9:	89 3c 24             	mov    %edi,(%esp)
  8020cc:	e8 2b ff ff ff       	call   801ffc <close>

	newfd = INDEX2FD(newfdnum);
  8020d1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8020d7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8020da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020dd:	89 04 24             	mov    %eax,(%esp)
  8020e0:	e8 bb fa ff ff       	call   801ba0 <fd2data>
  8020e5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8020e7:	89 34 24             	mov    %esi,(%esp)
  8020ea:	e8 b1 fa ff ff       	call   801ba0 <fd2data>
  8020ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8020f2:	89 da                	mov    %ebx,%edx
  8020f4:	89 d8                	mov    %ebx,%eax
  8020f6:	c1 e8 16             	shr    $0x16,%eax
  8020f9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802100:	a8 01                	test   $0x1,%al
  802102:	74 43                	je     802147 <dup+0xac>
  802104:	c1 ea 0c             	shr    $0xc,%edx
  802107:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80210e:	a8 01                	test   $0x1,%al
  802110:	74 35                	je     802147 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802112:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  802119:	25 07 0e 00 00       	and    $0xe07,%eax
  80211e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802122:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802125:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802129:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802130:	00 
  802131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213c:	e8 e3 f2 ff ff       	call   801424 <sys_page_map>
  802141:	89 c3                	mov    %eax,%ebx
  802143:	85 c0                	test   %eax,%eax
  802145:	78 3f                	js     802186 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802147:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80214a:	89 c2                	mov    %eax,%edx
  80214c:	c1 ea 0c             	shr    $0xc,%edx
  80214f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802156:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80215c:	89 54 24 10          	mov    %edx,0x10(%esp)
  802160:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80216b:	00 
  80216c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802170:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802177:	e8 a8 f2 ff ff       	call   801424 <sys_page_map>
  80217c:	89 c3                	mov    %eax,%ebx
  80217e:	85 c0                	test   %eax,%eax
  802180:	78 04                	js     802186 <dup+0xeb>
  802182:	89 fb                	mov    %edi,%ebx
  802184:	eb 23                	jmp    8021a9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802191:	e8 56 f2 ff ff       	call   8013ec <sys_page_unmap>
	sys_page_unmap(0, nva);
  802196:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802199:	89 44 24 04          	mov    %eax,0x4(%esp)
  80219d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8021a4:	e8 43 f2 ff ff       	call   8013ec <sys_page_unmap>
	return r;
}
  8021a9:	89 d8                	mov    %ebx,%eax
  8021ab:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8021ae:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8021b1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8021b4:	89 ec                	mov    %ebp,%esp
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    

008021b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	83 ec 18             	sub    $0x18,%esp
  8021be:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8021c1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8021c4:	89 c3                	mov    %eax,%ebx
  8021c6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8021c8:	83 3d 08 50 80 00 00 	cmpl   $0x0,0x805008
  8021cf:	75 11                	jne    8021e2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8021d1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8021d8:	e8 63 f8 ff ff       	call   801a40 <ipc_find_env>
  8021dd:	a3 08 50 80 00       	mov    %eax,0x805008
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8021e2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8021e9:	00 
  8021ea:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  8021f1:	00 
  8021f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021f6:	a1 08 50 80 00       	mov    0x805008,%eax
  8021fb:	89 04 24             	mov    %eax,(%esp)
  8021fe:	e8 86 f8 ff ff       	call   801a89 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802203:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80220a:	00 
  80220b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80220f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802216:	e8 d9 f8 ff ff       	call   801af4 <ipc_recv>
}
  80221b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80221e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802221:	89 ec                	mov    %ebp,%esp
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80222b:	8b 45 08             	mov    0x8(%ebp),%eax
  80222e:	8b 40 0c             	mov    0xc(%eax),%eax
  802231:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802236:	8b 45 0c             	mov    0xc(%ebp),%eax
  802239:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80223e:	ba 00 00 00 00       	mov    $0x0,%edx
  802243:	b8 02 00 00 00       	mov    $0x2,%eax
  802248:	e8 6b ff ff ff       	call   8021b8 <fsipc>
}
  80224d:	c9                   	leave  
  80224e:	c3                   	ret    

0080224f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80224f:	55                   	push   %ebp
  802250:	89 e5                	mov    %esp,%ebp
  802252:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802255:	8b 45 08             	mov    0x8(%ebp),%eax
  802258:	8b 40 0c             	mov    0xc(%eax),%eax
  80225b:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802260:	ba 00 00 00 00       	mov    $0x0,%edx
  802265:	b8 06 00 00 00       	mov    $0x6,%eax
  80226a:	e8 49 ff ff ff       	call   8021b8 <fsipc>
}
  80226f:	c9                   	leave  
  802270:	c3                   	ret    

00802271 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  802271:	55                   	push   %ebp
  802272:	89 e5                	mov    %esp,%ebp
  802274:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802277:	ba 00 00 00 00       	mov    $0x0,%edx
  80227c:	b8 08 00 00 00       	mov    $0x8,%eax
  802281:	e8 32 ff ff ff       	call   8021b8 <fsipc>
}
  802286:	c9                   	leave  
  802287:	c3                   	ret    

00802288 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802288:	55                   	push   %ebp
  802289:	89 e5                	mov    %esp,%ebp
  80228b:	53                   	push   %ebx
  80228c:	83 ec 14             	sub    $0x14,%esp
  80228f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802292:	8b 45 08             	mov    0x8(%ebp),%eax
  802295:	8b 40 0c             	mov    0xc(%eax),%eax
  802298:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80229d:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8022a7:	e8 0c ff ff ff       	call   8021b8 <fsipc>
  8022ac:	85 c0                	test   %eax,%eax
  8022ae:	78 2b                	js     8022db <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8022b0:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8022b7:	00 
  8022b8:	89 1c 24             	mov    %ebx,(%esp)
  8022bb:	e8 3a eb ff ff       	call   800dfa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8022c0:	a1 80 60 80 00       	mov    0x806080,%eax
  8022c5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8022cb:	a1 84 60 80 00       	mov    0x806084,%eax
  8022d0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8022d6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8022db:	83 c4 14             	add    $0x14,%esp
  8022de:	5b                   	pop    %ebx
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    

008022e1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8022e1:	55                   	push   %ebp
  8022e2:	89 e5                	mov    %esp,%ebp
  8022e4:	83 ec 18             	sub    $0x18,%esp
  8022e7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8022ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8022ed:	8b 52 0c             	mov    0xc(%edx),%edx
  8022f0:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  8022f6:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  8022fb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802300:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802305:	0f 47 c2             	cmova  %edx,%eax
  802308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80230c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80230f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802313:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  80231a:	e8 c6 ec ff ff       	call   800fe5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80231f:	ba 00 00 00 00       	mov    $0x0,%edx
  802324:	b8 04 00 00 00       	mov    $0x4,%eax
  802329:	e8 8a fe ff ff       	call   8021b8 <fsipc>
}
  80232e:	c9                   	leave  
  80232f:	c3                   	ret    

00802330 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	53                   	push   %ebx
  802334:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  802337:	8b 45 08             	mov    0x8(%ebp),%eax
  80233a:	8b 40 0c             	mov    0xc(%eax),%eax
  80233d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  802342:	8b 45 10             	mov    0x10(%ebp),%eax
  802345:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80234a:	ba 00 00 00 00       	mov    $0x0,%edx
  80234f:	b8 03 00 00 00       	mov    $0x3,%eax
  802354:	e8 5f fe ff ff       	call   8021b8 <fsipc>
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	85 c0                	test   %eax,%eax
  80235d:	78 17                	js     802376 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80235f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802363:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  80236a:	00 
  80236b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80236e:	89 04 24             	mov    %eax,(%esp)
  802371:	e8 6f ec ff ff       	call   800fe5 <memmove>
  return r;	
}
  802376:	89 d8                	mov    %ebx,%eax
  802378:	83 c4 14             	add    $0x14,%esp
  80237b:	5b                   	pop    %ebx
  80237c:	5d                   	pop    %ebp
  80237d:	c3                   	ret    

0080237e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80237e:	55                   	push   %ebp
  80237f:	89 e5                	mov    %esp,%ebp
  802381:	53                   	push   %ebx
  802382:	83 ec 14             	sub    $0x14,%esp
  802385:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  802388:	89 1c 24             	mov    %ebx,(%esp)
  80238b:	e8 20 ea ff ff       	call   800db0 <strlen>
  802390:	89 c2                	mov    %eax,%edx
  802392:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  802397:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80239d:	7f 1f                	jg     8023be <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80239f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8023a3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  8023aa:	e8 4b ea ff ff       	call   800dfa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8023af:	ba 00 00 00 00       	mov    $0x0,%edx
  8023b4:	b8 07 00 00 00       	mov    $0x7,%eax
  8023b9:	e8 fa fd ff ff       	call   8021b8 <fsipc>
}
  8023be:	83 c4 14             	add    $0x14,%esp
  8023c1:	5b                   	pop    %ebx
  8023c2:	5d                   	pop    %ebp
  8023c3:	c3                   	ret    

008023c4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8023c4:	55                   	push   %ebp
  8023c5:	89 e5                	mov    %esp,%ebp
  8023c7:	83 ec 28             	sub    $0x28,%esp
  8023ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8023cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8023d0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8023d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d6:	89 04 24             	mov    %eax,(%esp)
  8023d9:	e8 dd f7 ff ff       	call   801bbb <fd_alloc>
  8023de:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8023e0:	85 c0                	test   %eax,%eax
  8023e2:	0f 88 89 00 00 00    	js     802471 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8023e8:	89 34 24             	mov    %esi,(%esp)
  8023eb:	e8 c0 e9 ff ff       	call   800db0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8023f0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8023f5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8023fa:	7f 75                	jg     802471 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8023fc:	89 74 24 04          	mov    %esi,0x4(%esp)
  802400:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  802407:	e8 ee e9 ff ff       	call   800dfa <strcpy>
  fsipcbuf.open.req_omode = mode;
  80240c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80240f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  802414:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802417:	b8 01 00 00 00       	mov    $0x1,%eax
  80241c:	e8 97 fd ff ff       	call   8021b8 <fsipc>
  802421:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  802423:	85 c0                	test   %eax,%eax
  802425:	78 0f                	js     802436 <open+0x72>
  return fd2num(fd);
  802427:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80242a:	89 04 24             	mov    %eax,(%esp)
  80242d:	e8 5e f7 ff ff       	call   801b90 <fd2num>
  802432:	89 c3                	mov    %eax,%ebx
  802434:	eb 3b                	jmp    802471 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  802436:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80243d:	00 
  80243e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802441:	89 04 24             	mov    %eax,(%esp)
  802444:	e8 2b fb ff ff       	call   801f74 <fd_close>
  802449:	85 c0                	test   %eax,%eax
  80244b:	74 24                	je     802471 <open+0xad>
  80244d:	c7 44 24 0c 30 38 80 	movl   $0x803830,0xc(%esp)
  802454:	00 
  802455:	c7 44 24 08 45 38 80 	movl   $0x803845,0x8(%esp)
  80245c:	00 
  80245d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  802464:	00 
  802465:	c7 04 24 5a 38 80 00 	movl   $0x80385a,(%esp)
  80246c:	e8 93 e1 ff ff       	call   800604 <_panic>
  return r;
}
  802471:	89 d8                	mov    %ebx,%eax
  802473:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  802476:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802479:	89 ec                	mov    %ebp,%esp
  80247b:	5d                   	pop    %ebp
  80247c:	c3                   	ret    
  80247d:	00 00                	add    %al,(%eax)
	...

00802480 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  802486:	c7 44 24 04 65 38 80 	movl   $0x803865,0x4(%esp)
  80248d:	00 
  80248e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802491:	89 04 24             	mov    %eax,(%esp)
  802494:	e8 61 e9 ff ff       	call   800dfa <strcpy>
	return 0;
}
  802499:	b8 00 00 00 00       	mov    $0x0,%eax
  80249e:	c9                   	leave  
  80249f:	c3                   	ret    

008024a0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 14             	sub    $0x14,%esp
  8024a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8024aa:	89 1c 24             	mov    %ebx,(%esp)
  8024ad:	e8 6a 05 00 00       	call   802a1c <pageref>
  8024b2:	89 c2                	mov    %eax,%edx
  8024b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b9:	83 fa 01             	cmp    $0x1,%edx
  8024bc:	75 0b                	jne    8024c9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  8024be:	8b 43 0c             	mov    0xc(%ebx),%eax
  8024c1:	89 04 24             	mov    %eax,(%esp)
  8024c4:	e8 b9 02 00 00       	call   802782 <nsipc_close>
	else
		return 0;
}
  8024c9:	83 c4 14             	add    $0x14,%esp
  8024cc:	5b                   	pop    %ebx
  8024cd:	5d                   	pop    %ebp
  8024ce:	c3                   	ret    

008024cf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8024cf:	55                   	push   %ebp
  8024d0:	89 e5                	mov    %esp,%ebp
  8024d2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8024d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8024dc:	00 
  8024dd:	8b 45 10             	mov    0x10(%ebp),%eax
  8024e0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8024f1:	89 04 24             	mov    %eax,(%esp)
  8024f4:	e8 c5 02 00 00       	call   8027be <nsipc_send>
}
  8024f9:	c9                   	leave  
  8024fa:	c3                   	ret    

008024fb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8024fb:	55                   	push   %ebp
  8024fc:	89 e5                	mov    %esp,%ebp
  8024fe:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802501:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802508:	00 
  802509:	8b 45 10             	mov    0x10(%ebp),%eax
  80250c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802510:	8b 45 0c             	mov    0xc(%ebp),%eax
  802513:	89 44 24 04          	mov    %eax,0x4(%esp)
  802517:	8b 45 08             	mov    0x8(%ebp),%eax
  80251a:	8b 40 0c             	mov    0xc(%eax),%eax
  80251d:	89 04 24             	mov    %eax,(%esp)
  802520:	e8 0c 03 00 00       	call   802831 <nsipc_recv>
}
  802525:	c9                   	leave  
  802526:	c3                   	ret    

00802527 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802527:	55                   	push   %ebp
  802528:	89 e5                	mov    %esp,%ebp
  80252a:	56                   	push   %esi
  80252b:	53                   	push   %ebx
  80252c:	83 ec 20             	sub    $0x20,%esp
  80252f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802531:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802534:	89 04 24             	mov    %eax,(%esp)
  802537:	e8 7f f6 ff ff       	call   801bbb <fd_alloc>
  80253c:	89 c3                	mov    %eax,%ebx
  80253e:	85 c0                	test   %eax,%eax
  802540:	78 21                	js     802563 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802542:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802549:	00 
  80254a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80254d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802551:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802558:	e8 00 ef ff ff       	call   80145d <sys_page_alloc>
  80255d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80255f:	85 c0                	test   %eax,%eax
  802561:	79 0a                	jns    80256d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802563:	89 34 24             	mov    %esi,(%esp)
  802566:	e8 17 02 00 00       	call   802782 <nsipc_close>
		return r;
  80256b:	eb 28                	jmp    802595 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80256d:	8b 15 20 40 80 00    	mov    0x804020,%edx
  802573:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802576:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80257b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802582:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802585:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802588:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80258b:	89 04 24             	mov    %eax,(%esp)
  80258e:	e8 fd f5 ff ff       	call   801b90 <fd2num>
  802593:	89 c3                	mov    %eax,%ebx
}
  802595:	89 d8                	mov    %ebx,%eax
  802597:	83 c4 20             	add    $0x20,%esp
  80259a:	5b                   	pop    %ebx
  80259b:	5e                   	pop    %esi
  80259c:	5d                   	pop    %ebp
  80259d:	c3                   	ret    

0080259e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80259e:	55                   	push   %ebp
  80259f:	89 e5                	mov    %esp,%ebp
  8025a1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8025a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8025a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  8025ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8025b5:	89 04 24             	mov    %eax,(%esp)
  8025b8:	e8 79 01 00 00       	call   802736 <nsipc_socket>
  8025bd:	85 c0                	test   %eax,%eax
  8025bf:	78 05                	js     8025c6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8025c1:	e8 61 ff ff ff       	call   802527 <alloc_sockfd>
}
  8025c6:	c9                   	leave  
  8025c7:	c3                   	ret    

008025c8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8025c8:	55                   	push   %ebp
  8025c9:	89 e5                	mov    %esp,%ebp
  8025cb:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8025ce:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8025d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025d5:	89 04 24             	mov    %eax,(%esp)
  8025d8:	e8 50 f6 ff ff       	call   801c2d <fd_lookup>
  8025dd:	85 c0                	test   %eax,%eax
  8025df:	78 15                	js     8025f6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8025e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8025e4:	8b 0a                	mov    (%edx),%ecx
  8025e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8025eb:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  8025f1:	75 03                	jne    8025f6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8025f3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  8025f6:	c9                   	leave  
  8025f7:	c3                   	ret    

008025f8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  8025f8:	55                   	push   %ebp
  8025f9:	89 e5                	mov    %esp,%ebp
  8025fb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8025fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802601:	e8 c2 ff ff ff       	call   8025c8 <fd2sockid>
  802606:	85 c0                	test   %eax,%eax
  802608:	78 0f                	js     802619 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80260a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80260d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802611:	89 04 24             	mov    %eax,(%esp)
  802614:	e8 47 01 00 00       	call   802760 <nsipc_listen>
}
  802619:	c9                   	leave  
  80261a:	c3                   	ret    

0080261b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80261b:	55                   	push   %ebp
  80261c:	89 e5                	mov    %esp,%ebp
  80261e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802621:	8b 45 08             	mov    0x8(%ebp),%eax
  802624:	e8 9f ff ff ff       	call   8025c8 <fd2sockid>
  802629:	85 c0                	test   %eax,%eax
  80262b:	78 16                	js     802643 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80262d:	8b 55 10             	mov    0x10(%ebp),%edx
  802630:	89 54 24 08          	mov    %edx,0x8(%esp)
  802634:	8b 55 0c             	mov    0xc(%ebp),%edx
  802637:	89 54 24 04          	mov    %edx,0x4(%esp)
  80263b:	89 04 24             	mov    %eax,(%esp)
  80263e:	e8 6e 02 00 00       	call   8028b1 <nsipc_connect>
}
  802643:	c9                   	leave  
  802644:	c3                   	ret    

00802645 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802645:	55                   	push   %ebp
  802646:	89 e5                	mov    %esp,%ebp
  802648:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80264b:	8b 45 08             	mov    0x8(%ebp),%eax
  80264e:	e8 75 ff ff ff       	call   8025c8 <fd2sockid>
  802653:	85 c0                	test   %eax,%eax
  802655:	78 0f                	js     802666 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802657:	8b 55 0c             	mov    0xc(%ebp),%edx
  80265a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80265e:	89 04 24             	mov    %eax,(%esp)
  802661:	e8 36 01 00 00       	call   80279c <nsipc_shutdown>
}
  802666:	c9                   	leave  
  802667:	c3                   	ret    

00802668 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802668:	55                   	push   %ebp
  802669:	89 e5                	mov    %esp,%ebp
  80266b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80266e:	8b 45 08             	mov    0x8(%ebp),%eax
  802671:	e8 52 ff ff ff       	call   8025c8 <fd2sockid>
  802676:	85 c0                	test   %eax,%eax
  802678:	78 16                	js     802690 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80267a:	8b 55 10             	mov    0x10(%ebp),%edx
  80267d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802681:	8b 55 0c             	mov    0xc(%ebp),%edx
  802684:	89 54 24 04          	mov    %edx,0x4(%esp)
  802688:	89 04 24             	mov    %eax,(%esp)
  80268b:	e8 60 02 00 00       	call   8028f0 <nsipc_bind>
}
  802690:	c9                   	leave  
  802691:	c3                   	ret    

00802692 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802692:	55                   	push   %ebp
  802693:	89 e5                	mov    %esp,%ebp
  802695:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802698:	8b 45 08             	mov    0x8(%ebp),%eax
  80269b:	e8 28 ff ff ff       	call   8025c8 <fd2sockid>
  8026a0:	85 c0                	test   %eax,%eax
  8026a2:	78 1f                	js     8026c3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8026a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8026a7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8026ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8026ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026b2:	89 04 24             	mov    %eax,(%esp)
  8026b5:	e8 75 02 00 00       	call   80292f <nsipc_accept>
  8026ba:	85 c0                	test   %eax,%eax
  8026bc:	78 05                	js     8026c3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8026be:	e8 64 fe ff ff       	call   802527 <alloc_sockfd>
}
  8026c3:	c9                   	leave  
  8026c4:	c3                   	ret    
	...

008026d0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8026d0:	55                   	push   %ebp
  8026d1:	89 e5                	mov    %esp,%ebp
  8026d3:	53                   	push   %ebx
  8026d4:	83 ec 14             	sub    $0x14,%esp
  8026d7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8026d9:	83 3d 0c 50 80 00 00 	cmpl   $0x0,0x80500c
  8026e0:	75 11                	jne    8026f3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8026e2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8026e9:	e8 52 f3 ff ff       	call   801a40 <ipc_find_env>
  8026ee:	a3 0c 50 80 00       	mov    %eax,0x80500c
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8026f3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8026fa:	00 
  8026fb:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802702:	00 
  802703:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802707:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80270c:	89 04 24             	mov    %eax,(%esp)
  80270f:	e8 75 f3 ff ff       	call   801a89 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802714:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80271b:	00 
  80271c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802723:	00 
  802724:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80272b:	e8 c4 f3 ff ff       	call   801af4 <ipc_recv>
}
  802730:	83 c4 14             	add    $0x14,%esp
  802733:	5b                   	pop    %ebx
  802734:	5d                   	pop    %ebp
  802735:	c3                   	ret    

00802736 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802736:	55                   	push   %ebp
  802737:	89 e5                	mov    %esp,%ebp
  802739:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80273c:	8b 45 08             	mov    0x8(%ebp),%eax
  80273f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802744:	8b 45 0c             	mov    0xc(%ebp),%eax
  802747:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80274c:	8b 45 10             	mov    0x10(%ebp),%eax
  80274f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  802754:	b8 09 00 00 00       	mov    $0x9,%eax
  802759:	e8 72 ff ff ff       	call   8026d0 <nsipc>
}
  80275e:	c9                   	leave  
  80275f:	c3                   	ret    

00802760 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802760:	55                   	push   %ebp
  802761:	89 e5                	mov    %esp,%ebp
  802763:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802766:	8b 45 08             	mov    0x8(%ebp),%eax
  802769:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  80276e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802771:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802776:	b8 06 00 00 00       	mov    $0x6,%eax
  80277b:	e8 50 ff ff ff       	call   8026d0 <nsipc>
}
  802780:	c9                   	leave  
  802781:	c3                   	ret    

00802782 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802782:	55                   	push   %ebp
  802783:	89 e5                	mov    %esp,%ebp
  802785:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802788:	8b 45 08             	mov    0x8(%ebp),%eax
  80278b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802790:	b8 04 00 00 00       	mov    $0x4,%eax
  802795:	e8 36 ff ff ff       	call   8026d0 <nsipc>
}
  80279a:	c9                   	leave  
  80279b:	c3                   	ret    

0080279c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80279c:	55                   	push   %ebp
  80279d:	89 e5                	mov    %esp,%ebp
  80279f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8027a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8027a5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8027aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8027ad:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  8027b2:	b8 03 00 00 00       	mov    $0x3,%eax
  8027b7:	e8 14 ff ff ff       	call   8026d0 <nsipc>
}
  8027bc:	c9                   	leave  
  8027bd:	c3                   	ret    

008027be <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8027be:	55                   	push   %ebp
  8027bf:	89 e5                	mov    %esp,%ebp
  8027c1:	53                   	push   %ebx
  8027c2:	83 ec 14             	sub    $0x14,%esp
  8027c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8027c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8027cb:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  8027d0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8027d6:	7e 24                	jle    8027fc <nsipc_send+0x3e>
  8027d8:	c7 44 24 0c 71 38 80 	movl   $0x803871,0xc(%esp)
  8027df:	00 
  8027e0:	c7 44 24 08 45 38 80 	movl   $0x803845,0x8(%esp)
  8027e7:	00 
  8027e8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8027ef:	00 
  8027f0:	c7 04 24 7d 38 80 00 	movl   $0x80387d,(%esp)
  8027f7:	e8 08 de ff ff       	call   800604 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8027fc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802800:	8b 45 0c             	mov    0xc(%ebp),%eax
  802803:	89 44 24 04          	mov    %eax,0x4(%esp)
  802807:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80280e:	e8 d2 e7 ff ff       	call   800fe5 <memmove>
	nsipcbuf.send.req_size = size;
  802813:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802819:	8b 45 14             	mov    0x14(%ebp),%eax
  80281c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802821:	b8 08 00 00 00       	mov    $0x8,%eax
  802826:	e8 a5 fe ff ff       	call   8026d0 <nsipc>
}
  80282b:	83 c4 14             	add    $0x14,%esp
  80282e:	5b                   	pop    %ebx
  80282f:	5d                   	pop    %ebp
  802830:	c3                   	ret    

00802831 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802831:	55                   	push   %ebp
  802832:	89 e5                	mov    %esp,%ebp
  802834:	56                   	push   %esi
  802835:	53                   	push   %ebx
  802836:	83 ec 10             	sub    $0x10,%esp
  802839:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80283c:	8b 45 08             	mov    0x8(%ebp),%eax
  80283f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802844:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80284a:	8b 45 14             	mov    0x14(%ebp),%eax
  80284d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802852:	b8 07 00 00 00       	mov    $0x7,%eax
  802857:	e8 74 fe ff ff       	call   8026d0 <nsipc>
  80285c:	89 c3                	mov    %eax,%ebx
  80285e:	85 c0                	test   %eax,%eax
  802860:	78 46                	js     8028a8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802862:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802867:	7f 04                	jg     80286d <nsipc_recv+0x3c>
  802869:	39 c6                	cmp    %eax,%esi
  80286b:	7d 24                	jge    802891 <nsipc_recv+0x60>
  80286d:	c7 44 24 0c 89 38 80 	movl   $0x803889,0xc(%esp)
  802874:	00 
  802875:	c7 44 24 08 45 38 80 	movl   $0x803845,0x8(%esp)
  80287c:	00 
  80287d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802884:	00 
  802885:	c7 04 24 7d 38 80 00 	movl   $0x80387d,(%esp)
  80288c:	e8 73 dd ff ff       	call   800604 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802891:	89 44 24 08          	mov    %eax,0x8(%esp)
  802895:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80289c:	00 
  80289d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028a0:	89 04 24             	mov    %eax,(%esp)
  8028a3:	e8 3d e7 ff ff       	call   800fe5 <memmove>
	}

	return r;
}
  8028a8:	89 d8                	mov    %ebx,%eax
  8028aa:	83 c4 10             	add    $0x10,%esp
  8028ad:	5b                   	pop    %ebx
  8028ae:	5e                   	pop    %esi
  8028af:	5d                   	pop    %ebp
  8028b0:	c3                   	ret    

008028b1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8028b1:	55                   	push   %ebp
  8028b2:	89 e5                	mov    %esp,%ebp
  8028b4:	53                   	push   %ebx
  8028b5:	83 ec 14             	sub    $0x14,%esp
  8028b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8028bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8028be:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8028c3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028ce:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  8028d5:	e8 0b e7 ff ff       	call   800fe5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8028da:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  8028e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8028e5:	e8 e6 fd ff ff       	call   8026d0 <nsipc>
}
  8028ea:	83 c4 14             	add    $0x14,%esp
  8028ed:	5b                   	pop    %ebx
  8028ee:	5d                   	pop    %ebp
  8028ef:	c3                   	ret    

008028f0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8028f0:	55                   	push   %ebp
  8028f1:	89 e5                	mov    %esp,%ebp
  8028f3:	53                   	push   %ebx
  8028f4:	83 ec 14             	sub    $0x14,%esp
  8028f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8028fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8028fd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802902:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802906:	8b 45 0c             	mov    0xc(%ebp),%eax
  802909:	89 44 24 04          	mov    %eax,0x4(%esp)
  80290d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802914:	e8 cc e6 ff ff       	call   800fe5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802919:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80291f:	b8 02 00 00 00       	mov    $0x2,%eax
  802924:	e8 a7 fd ff ff       	call   8026d0 <nsipc>
}
  802929:	83 c4 14             	add    $0x14,%esp
  80292c:	5b                   	pop    %ebx
  80292d:	5d                   	pop    %ebp
  80292e:	c3                   	ret    

0080292f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80292f:	55                   	push   %ebp
  802930:	89 e5                	mov    %esp,%ebp
  802932:	83 ec 18             	sub    $0x18,%esp
  802935:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802938:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80293b:	8b 45 08             	mov    0x8(%ebp),%eax
  80293e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802943:	b8 01 00 00 00       	mov    $0x1,%eax
  802948:	e8 83 fd ff ff       	call   8026d0 <nsipc>
  80294d:	89 c3                	mov    %eax,%ebx
  80294f:	85 c0                	test   %eax,%eax
  802951:	78 25                	js     802978 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802953:	be 10 70 80 00       	mov    $0x807010,%esi
  802958:	8b 06                	mov    (%esi),%eax
  80295a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80295e:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  802965:	00 
  802966:	8b 45 0c             	mov    0xc(%ebp),%eax
  802969:	89 04 24             	mov    %eax,(%esp)
  80296c:	e8 74 e6 ff ff       	call   800fe5 <memmove>
		*addrlen = ret->ret_addrlen;
  802971:	8b 16                	mov    (%esi),%edx
  802973:	8b 45 10             	mov    0x10(%ebp),%eax
  802976:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802978:	89 d8                	mov    %ebx,%eax
  80297a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80297d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802980:	89 ec                	mov    %ebp,%esp
  802982:	5d                   	pop    %ebp
  802983:	c3                   	ret    

00802984 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802984:	55                   	push   %ebp
  802985:	89 e5                	mov    %esp,%ebp
  802987:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80298a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802991:	75 54                	jne    8029e7 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  802993:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80299a:	00 
  80299b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8029a2:	ee 
  8029a3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029aa:	e8 ae ea ff ff       	call   80145d <sys_page_alloc>
  8029af:	85 c0                	test   %eax,%eax
  8029b1:	79 20                	jns    8029d3 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8029b3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029b7:	c7 44 24 08 9e 38 80 	movl   $0x80389e,0x8(%esp)
  8029be:	00 
  8029bf:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8029c6:	00 
  8029c7:	c7 04 24 b6 38 80 00 	movl   $0x8038b6,(%esp)
  8029ce:	e8 31 dc ff ff       	call   800604 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8029d3:	c7 44 24 04 f4 29 80 	movl   $0x8029f4,0x4(%esp)
  8029da:	00 
  8029db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8029e2:	e8 5d e9 ff ff       	call   801344 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8029e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8029ea:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8029ef:	c9                   	leave  
  8029f0:	c3                   	ret    
  8029f1:	00 00                	add    %al,(%eax)
	...

008029f4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8029f4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8029f5:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8029fa:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8029fc:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8029ff:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  802a03:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  802a06:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  802a0a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  802a0e:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  802a10:	83 c4 08             	add    $0x8,%esp
	popal
  802a13:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  802a14:	83 c4 04             	add    $0x4,%esp
	popfl
  802a17:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  802a18:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802a19:	c3                   	ret    
	...

00802a1c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a1c:	55                   	push   %ebp
  802a1d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  802a22:	89 c2                	mov    %eax,%edx
  802a24:	c1 ea 16             	shr    $0x16,%edx
  802a27:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802a2e:	f6 c2 01             	test   $0x1,%dl
  802a31:	74 20                	je     802a53 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802a33:	c1 e8 0c             	shr    $0xc,%eax
  802a36:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802a3d:	a8 01                	test   $0x1,%al
  802a3f:	74 12                	je     802a53 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a41:	c1 e8 0c             	shr    $0xc,%eax
  802a44:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802a49:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802a4e:	0f b7 c0             	movzwl %ax,%eax
  802a51:	eb 05                	jmp    802a58 <pageref+0x3c>
  802a53:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802a58:	5d                   	pop    %ebp
  802a59:	c3                   	ret    
  802a5a:	00 00                	add    %al,(%eax)
  802a5c:	00 00                	add    %al,(%eax)
	...

00802a60 <inet_ntoa>:
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
{
  802a60:	55                   	push   %ebp
  802a61:	89 e5                	mov    %esp,%ebp
  802a63:	57                   	push   %edi
  802a64:	56                   	push   %esi
  802a65:	53                   	push   %ebx
  802a66:	83 ec 20             	sub    $0x20,%esp
  static char str[16];
  u32_t s_addr = addr.s_addr;
  802a69:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  u8_t rem;
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  802a6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a72:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802a75:	8d 55 f3             	lea    -0xd(%ebp),%edx
  802a78:	89 55 d8             	mov    %edx,-0x28(%ebp)
  802a7b:	bb 10 50 80 00       	mov    $0x805010,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802a80:	b9 cd ff ff ff       	mov    $0xffffffcd,%ecx
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802a85:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802a88:	0f b6 37             	movzbl (%edi),%esi
  802a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  802a90:	89 d0                	mov    %edx,%eax
  802a92:	89 f2                	mov    %esi,%edx
  802a94:	89 de                	mov    %ebx,%esi
  802a96:	89 c3                	mov    %eax,%ebx
  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
    i = 0;
    do {
      rem = *ap % (u8_t)10;
  802a98:	89 d0                	mov    %edx,%eax
  802a9a:	f6 e1                	mul    %cl
  802a9c:	66 c1 e8 08          	shr    $0x8,%ax
  802aa0:	c0 e8 03             	shr    $0x3,%al
  802aa3:	89 c7                	mov    %eax,%edi
  802aa5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  802aa8:	01 c0                	add    %eax,%eax
  802aaa:	28 c2                	sub    %al,%dl
  802aac:	89 d0                	mov    %edx,%eax
      *ap /= (u8_t)10;
  802aae:	89 fa                	mov    %edi,%edx
      inv[i++] = '0' + rem;
  802ab0:	0f b6 fb             	movzbl %bl,%edi
  802ab3:	83 c0 30             	add    $0x30,%eax
  802ab6:	88 44 3d ed          	mov    %al,-0x13(%ebp,%edi,1)
  802aba:	8d 43 01             	lea    0x1(%ebx),%eax
    } while(*ap);
  802abd:	84 d2                	test   %dl,%dl
  802abf:	74 04                	je     802ac5 <inet_ntoa+0x65>
  802ac1:	89 c3                	mov    %eax,%ebx
  802ac3:	eb d3                	jmp    802a98 <inet_ntoa+0x38>
  802ac5:	88 45 d7             	mov    %al,-0x29(%ebp)
  802ac8:	89 df                	mov    %ebx,%edi
  802aca:	89 f3                	mov    %esi,%ebx
  802acc:	89 d6                	mov    %edx,%esi
  802ace:	89 fa                	mov    %edi,%edx
  802ad0:	88 55 dc             	mov    %dl,-0x24(%ebp)
  802ad3:	89 f0                	mov    %esi,%eax
  802ad5:	8b 7d e0             	mov    -0x20(%ebp),%edi
  802ad8:	88 07                	mov    %al,(%edi)
    while(i--)
  802ada:	80 7d d7 00          	cmpb   $0x0,-0x29(%ebp)
  802ade:	74 2a                	je     802b0a <inet_ntoa+0xaa>
 * @param addr ip address in network order to convert
 * @return pointer to a global static (!) buffer that holds the ASCII
 *         represenation of addr
 */
char *
inet_ntoa(struct in_addr addr)
  802ae0:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  802ae4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  802ae7:	8d 7c 03 01          	lea    0x1(%ebx,%eax,1),%edi
  802aeb:	89 d8                	mov    %ebx,%eax
  802aed:	89 de                	mov    %ebx,%esi
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
  802aef:	0f b6 da             	movzbl %dl,%ebx
  802af2:	0f b6 5c 1d ed       	movzbl -0x13(%ebp,%ebx,1),%ebx
  802af7:	88 18                	mov    %bl,(%eax)
  802af9:	83 c0 01             	add    $0x1,%eax
    do {
      rem = *ap % (u8_t)10;
      *ap /= (u8_t)10;
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
  802afc:	83 ea 01             	sub    $0x1,%edx
  802aff:	39 f8                	cmp    %edi,%eax
  802b01:	75 ec                	jne    802aef <inet_ntoa+0x8f>
  802b03:	8b 55 dc             	mov    -0x24(%ebp),%edx
  802b06:	8d 5c 16 01          	lea    0x1(%esi,%edx,1),%ebx
      *rp++ = inv[i];
    *rp++ = '.';
  802b0a:	c6 03 2e             	movb   $0x2e,(%ebx)
  802b0d:	8d 43 01             	lea    0x1(%ebx),%eax
  u8_t n;
  u8_t i;

  rp = str;
  ap = (u8_t *)&s_addr;
  for(n = 0; n < 4; n++) {
  802b10:	8b 7d d8             	mov    -0x28(%ebp),%edi
  802b13:	39 7d e0             	cmp    %edi,-0x20(%ebp)
  802b16:	74 0b                	je     802b23 <inet_ntoa+0xc3>
      inv[i++] = '0' + rem;
    } while(*ap);
    while(i--)
      *rp++ = inv[i];
    *rp++ = '.';
    ap++;
  802b18:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
  802b1c:	89 c3                	mov    %eax,%ebx
  802b1e:	e9 62 ff ff ff       	jmp    802a85 <inet_ntoa+0x25>
  }
  *--rp = 0;
  802b23:	c6 03 00             	movb   $0x0,(%ebx)
  return str;
}
  802b26:	b8 10 50 80 00       	mov    $0x805010,%eax
  802b2b:	83 c4 20             	add    $0x20,%esp
  802b2e:	5b                   	pop    %ebx
  802b2f:	5e                   	pop    %esi
  802b30:	5f                   	pop    %edi
  802b31:	5d                   	pop    %ebp
  802b32:	c3                   	ret    

00802b33 <htons>:
 * @param n u16_t in host byte order
 * @return n in network byte order
 */
u16_t
htons(u16_t n)
{
  802b33:	55                   	push   %ebp
  802b34:	89 e5                	mov    %esp,%ebp
  802b36:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802b3a:	66 c1 c0 08          	rol    $0x8,%ax
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}
  802b3e:	5d                   	pop    %ebp
  802b3f:	c3                   	ret    

00802b40 <ntohs>:
 * @param n u16_t in network byte order
 * @return n in host byte order
 */
u16_t
ntohs(u16_t n)
{
  802b40:	55                   	push   %ebp
  802b41:	89 e5                	mov    %esp,%ebp
  802b43:	83 ec 04             	sub    $0x4,%esp
  return htons(n);
  802b46:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
  802b4a:	89 04 24             	mov    %eax,(%esp)
  802b4d:	e8 e1 ff ff ff       	call   802b33 <htons>
}
  802b52:	c9                   	leave  
  802b53:	c3                   	ret    

00802b54 <htonl>:
 * @param n u32_t in host byte order
 * @return n in network byte order
 */
u32_t
htonl(u32_t n)
{
  802b54:	55                   	push   %ebp
  802b55:	89 e5                	mov    %esp,%ebp
  802b57:	8b 55 08             	mov    0x8(%ebp),%edx
  802b5a:	89 d1                	mov    %edx,%ecx
  802b5c:	c1 e9 18             	shr    $0x18,%ecx
  802b5f:	89 d0                	mov    %edx,%eax
  802b61:	c1 e0 18             	shl    $0x18,%eax
  802b64:	09 c8                	or     %ecx,%eax
  802b66:	89 d1                	mov    %edx,%ecx
  802b68:	81 e1 00 ff 00 00    	and    $0xff00,%ecx
  802b6e:	c1 e1 08             	shl    $0x8,%ecx
  802b71:	09 c8                	or     %ecx,%eax
  802b73:	81 e2 00 00 ff 00    	and    $0xff0000,%edx
  802b79:	c1 ea 08             	shr    $0x8,%edx
  802b7c:	09 d0                	or     %edx,%eax
  return ((n & 0xff) << 24) |
    ((n & 0xff00) << 8) |
    ((n & 0xff0000UL) >> 8) |
    ((n & 0xff000000UL) >> 24);
}
  802b7e:	5d                   	pop    %ebp
  802b7f:	c3                   	ret    

00802b80 <inet_aton>:
 * @param addr pointer to which to save the ip address in network order
 * @return 1 if cp could be converted to addr, 0 on failure
 */
int
inet_aton(const char *cp, struct in_addr *addr)
{
  802b80:	55                   	push   %ebp
  802b81:	89 e5                	mov    %esp,%ebp
  802b83:	57                   	push   %edi
  802b84:	56                   	push   %esi
  802b85:	53                   	push   %ebx
  802b86:	83 ec 28             	sub    $0x28,%esp
  802b89:	8b 45 08             	mov    0x8(%ebp),%eax
  u32_t val;
  int base, n, c;
  u32_t parts[4];
  u32_t *pp = parts;

  c = *cp;
  802b8c:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802b8f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802b92:	80 f9 09             	cmp    $0x9,%cl
  802b95:	0f 87 a8 01 00 00    	ja     802d43 <inet_aton+0x1c3>
  802b9b:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  802b9e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802ba1:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  802ba4:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
     */
    if (!isdigit(c))
      return (0);
    val = 0;
    base = 10;
    if (c == '0') {
  802ba7:	c7 45 e0 0a 00 00 00 	movl   $0xa,-0x20(%ebp)
  802bae:	83 fa 30             	cmp    $0x30,%edx
  802bb1:	75 24                	jne    802bd7 <inet_aton+0x57>
      c = *++cp;
  802bb3:	83 c0 01             	add    $0x1,%eax
  802bb6:	0f be 10             	movsbl (%eax),%edx
      if (c == 'x' || c == 'X') {
  802bb9:	83 fa 78             	cmp    $0x78,%edx
  802bbc:	74 0c                	je     802bca <inet_aton+0x4a>
  802bbe:	c7 45 e0 08 00 00 00 	movl   $0x8,-0x20(%ebp)
  802bc5:	83 fa 58             	cmp    $0x58,%edx
  802bc8:	75 0d                	jne    802bd7 <inet_aton+0x57>
        base = 16;
        c = *++cp;
  802bca:	83 c0 01             	add    $0x1,%eax
  802bcd:	0f be 10             	movsbl (%eax),%edx
  802bd0:	c7 45 e0 10 00 00 00 	movl   $0x10,-0x20(%ebp)
  802bd7:	83 c0 01             	add    $0x1,%eax
  802bda:	be 00 00 00 00       	mov    $0x0,%esi
  802bdf:	eb 03                	jmp    802be4 <inet_aton+0x64>
  802be1:	83 c0 01             	add    $0x1,%eax
  802be4:	8d 78 ff             	lea    -0x1(%eax),%edi
      } else
        base = 8;
    }
    for (;;) {
      if (isdigit(c)) {
  802be7:	89 d1                	mov    %edx,%ecx
  802be9:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802bec:	80 fb 09             	cmp    $0x9,%bl
  802bef:	77 0d                	ja     802bfe <inet_aton+0x7e>
        val = (val * base) + (int)(c - '0');
  802bf1:	0f af 75 e0          	imul   -0x20(%ebp),%esi
  802bf5:	8d 74 32 d0          	lea    -0x30(%edx,%esi,1),%esi
        c = *++cp;
  802bf9:	0f be 10             	movsbl (%eax),%edx
  802bfc:	eb e3                	jmp    802be1 <inet_aton+0x61>
      } else if (base == 16 && isxdigit(c)) {
  802bfe:	83 7d e0 10          	cmpl   $0x10,-0x20(%ebp)
  802c02:	75 2b                	jne    802c2f <inet_aton+0xaf>
  802c04:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802c07:	88 5d d3             	mov    %bl,-0x2d(%ebp)
  802c0a:	80 fb 05             	cmp    $0x5,%bl
  802c0d:	76 08                	jbe    802c17 <inet_aton+0x97>
  802c0f:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802c12:	80 fb 05             	cmp    $0x5,%bl
  802c15:	77 18                	ja     802c2f <inet_aton+0xaf>
        val = (val << 4) | (int)(c + 10 - (islower(c) ? 'a' : 'A'));
  802c17:	80 7d d3 1a          	cmpb   $0x1a,-0x2d(%ebp)
  802c1b:	19 c9                	sbb    %ecx,%ecx
  802c1d:	83 e1 20             	and    $0x20,%ecx
  802c20:	c1 e6 04             	shl    $0x4,%esi
  802c23:	29 ca                	sub    %ecx,%edx
  802c25:	8d 52 c9             	lea    -0x37(%edx),%edx
  802c28:	09 d6                	or     %edx,%esi
        c = *++cp;
  802c2a:	0f be 10             	movsbl (%eax),%edx
  802c2d:	eb b2                	jmp    802be1 <inet_aton+0x61>
      } else
        break;
    }
    if (c == '.') {
  802c2f:	83 fa 2e             	cmp    $0x2e,%edx
  802c32:	75 29                	jne    802c5d <inet_aton+0xdd>
       * Internet format:
       *  a.b.c.d
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
  802c34:	8b 55 d8             	mov    -0x28(%ebp),%edx
  802c37:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
  802c3a:	0f 86 03 01 00 00    	jbe    802d43 <inet_aton+0x1c3>
        return (0);
      *pp++ = val;
  802c40:	89 32                	mov    %esi,(%edx)
      c = *++cp;
  802c42:	8d 47 01             	lea    0x1(%edi),%eax
  802c45:	0f be 10             	movsbl (%eax),%edx
    /*
     * Collect number up to ``.''.
     * Values are specified as for C:
     * 0x=hex, 0=octal, 1-9=decimal.
     */
    if (!isdigit(c))
  802c48:	8d 4a d0             	lea    -0x30(%edx),%ecx
  802c4b:	80 f9 09             	cmp    $0x9,%cl
  802c4e:	0f 87 ef 00 00 00    	ja     802d43 <inet_aton+0x1c3>
       *  a.b.c   (with c treated as 16 bits)
       *  a.b (with b treated as 24 bits)
       */
      if (pp >= parts + 3)
        return (0);
      *pp++ = val;
  802c54:	83 45 d8 04          	addl   $0x4,-0x28(%ebp)
  802c58:	e9 4a ff ff ff       	jmp    802ba7 <inet_aton+0x27>
  802c5d:	89 f3                	mov    %esi,%ebx
  802c5f:	89 f0                	mov    %esi,%eax
      break;
  }
  /*
   * Check for trailing characters.
   */
  if (c != '\0' && (!isprint(c) || !isspace(c)))
  802c61:	85 d2                	test   %edx,%edx
  802c63:	74 36                	je     802c9b <inet_aton+0x11b>
  802c65:	80 f9 1f             	cmp    $0x1f,%cl
  802c68:	0f 86 d5 00 00 00    	jbe    802d43 <inet_aton+0x1c3>
  802c6e:	84 d2                	test   %dl,%dl
  802c70:	0f 88 cd 00 00 00    	js     802d43 <inet_aton+0x1c3>
  802c76:	83 fa 20             	cmp    $0x20,%edx
  802c79:	74 20                	je     802c9b <inet_aton+0x11b>
  802c7b:	83 fa 0c             	cmp    $0xc,%edx
  802c7e:	66 90                	xchg   %ax,%ax
  802c80:	74 19                	je     802c9b <inet_aton+0x11b>
  802c82:	83 fa 0a             	cmp    $0xa,%edx
  802c85:	74 14                	je     802c9b <inet_aton+0x11b>
  802c87:	83 fa 0d             	cmp    $0xd,%edx
  802c8a:	74 0f                	je     802c9b <inet_aton+0x11b>
  802c8c:	83 fa 09             	cmp    $0x9,%edx
  802c8f:	90                   	nop
  802c90:	74 09                	je     802c9b <inet_aton+0x11b>
  802c92:	83 fa 0b             	cmp    $0xb,%edx
  802c95:	0f 85 a8 00 00 00    	jne    802d43 <inet_aton+0x1c3>
  /*
   * Concoct the address according to
   * the number of parts specified.
   */
  n = pp - parts + 1;
  switch (n) {
  802c9b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  802c9e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  802ca1:	29 d1                	sub    %edx,%ecx
  802ca3:	89 ca                	mov    %ecx,%edx
  802ca5:	c1 fa 02             	sar    $0x2,%edx
  802ca8:	83 c2 01             	add    $0x1,%edx
  802cab:	83 fa 02             	cmp    $0x2,%edx
  802cae:	74 2a                	je     802cda <inet_aton+0x15a>
  802cb0:	83 fa 02             	cmp    $0x2,%edx
  802cb3:	7f 0d                	jg     802cc2 <inet_aton+0x142>
  802cb5:	85 d2                	test   %edx,%edx
  802cb7:	0f 84 86 00 00 00    	je     802d43 <inet_aton+0x1c3>
  802cbd:	8d 76 00             	lea    0x0(%esi),%esi
  802cc0:	eb 62                	jmp    802d24 <inet_aton+0x1a4>
  802cc2:	83 fa 03             	cmp    $0x3,%edx
  802cc5:	8d 76 00             	lea    0x0(%esi),%esi
  802cc8:	74 22                	je     802cec <inet_aton+0x16c>
  802cca:	83 fa 04             	cmp    $0x4,%edx
  802ccd:	8d 76 00             	lea    0x0(%esi),%esi
  802cd0:	75 52                	jne    802d24 <inet_aton+0x1a4>
  802cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802cd8:	eb 2b                	jmp    802d05 <inet_aton+0x185>

  case 1:             /* a -- 32 bits */
    break;

  case 2:             /* a.b -- 8.24 bits */
    if (val > 0xffffffUL)
  802cda:	3d ff ff ff 00       	cmp    $0xffffff,%eax
  802cdf:	90                   	nop
  802ce0:	77 61                	ja     802d43 <inet_aton+0x1c3>
      return (0);
    val |= parts[0] << 24;
  802ce2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802ce5:	c1 e3 18             	shl    $0x18,%ebx
  802ce8:	09 c3                	or     %eax,%ebx
    break;
  802cea:	eb 38                	jmp    802d24 <inet_aton+0x1a4>

  case 3:             /* a.b.c -- 8.8.16 bits */
    if (val > 0xffff)
  802cec:	3d ff ff 00 00       	cmp    $0xffff,%eax
  802cf1:	77 50                	ja     802d43 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16);
  802cf3:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  802cf6:	c1 e3 10             	shl    $0x10,%ebx
  802cf9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802cfc:	c1 e2 18             	shl    $0x18,%edx
  802cff:	09 d3                	or     %edx,%ebx
  802d01:	09 c3                	or     %eax,%ebx
    break;
  802d03:	eb 1f                	jmp    802d24 <inet_aton+0x1a4>

  case 4:             /* a.b.c.d -- 8.8.8.8 bits */
    if (val > 0xff)
  802d05:	3d ff 00 00 00       	cmp    $0xff,%eax
  802d0a:	77 37                	ja     802d43 <inet_aton+0x1c3>
      return (0);
    val |= (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8);
  802d0c:	8b 5d e8             	mov    -0x18(%ebp),%ebx
  802d0f:	c1 e3 10             	shl    $0x10,%ebx
  802d12:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802d15:	c1 e2 18             	shl    $0x18,%edx
  802d18:	09 d3                	or     %edx,%ebx
  802d1a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  802d1d:	c1 e2 08             	shl    $0x8,%edx
  802d20:	09 d3                	or     %edx,%ebx
  802d22:	09 c3                	or     %eax,%ebx
    break;
  }
  if (addr)
  802d24:	b8 01 00 00 00       	mov    $0x1,%eax
  802d29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802d2d:	74 19                	je     802d48 <inet_aton+0x1c8>
    addr->s_addr = htonl(val);
  802d2f:	89 1c 24             	mov    %ebx,(%esp)
  802d32:	e8 1d fe ff ff       	call   802b54 <htonl>
  802d37:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802d3a:	89 03                	mov    %eax,(%ebx)
  802d3c:	b8 01 00 00 00       	mov    $0x1,%eax
  802d41:	eb 05                	jmp    802d48 <inet_aton+0x1c8>
  802d43:	b8 00 00 00 00       	mov    $0x0,%eax
  return (1);
}
  802d48:	83 c4 28             	add    $0x28,%esp
  802d4b:	5b                   	pop    %ebx
  802d4c:	5e                   	pop    %esi
  802d4d:	5f                   	pop    %edi
  802d4e:	5d                   	pop    %ebp
  802d4f:	c3                   	ret    

00802d50 <inet_addr>:
 * @param cp IP address in ascii represenation (e.g. "127.0.0.1")
 * @return ip address in network order
 */
u32_t
inet_addr(const char *cp)
{
  802d50:	55                   	push   %ebp
  802d51:	89 e5                	mov    %esp,%ebp
  802d53:	83 ec 18             	sub    $0x18,%esp
  struct in_addr val;

  if (inet_aton(cp, &val)) {
  802d56:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802d59:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  802d60:	89 04 24             	mov    %eax,(%esp)
  802d63:	e8 18 fe ff ff       	call   802b80 <inet_aton>
  802d68:	85 c0                	test   %eax,%eax
  802d6a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802d6f:	0f 45 45 fc          	cmovne -0x4(%ebp),%eax
    return (val.s_addr);
  }
  return (INADDR_NONE);
}
  802d73:	c9                   	leave  
  802d74:	c3                   	ret    

00802d75 <ntohl>:
 * @param n u32_t in network byte order
 * @return n in host byte order
 */
u32_t
ntohl(u32_t n)
{
  802d75:	55                   	push   %ebp
  802d76:	89 e5                	mov    %esp,%ebp
  802d78:	83 ec 04             	sub    $0x4,%esp
  return htonl(n);
  802d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  802d7e:	89 04 24             	mov    %eax,(%esp)
  802d81:	e8 ce fd ff ff       	call   802b54 <htonl>
}
  802d86:	c9                   	leave  
  802d87:	c3                   	ret    
	...

00802d90 <__udivdi3>:
  802d90:	55                   	push   %ebp
  802d91:	89 e5                	mov    %esp,%ebp
  802d93:	57                   	push   %edi
  802d94:	56                   	push   %esi
  802d95:	83 ec 10             	sub    $0x10,%esp
  802d98:	8b 45 14             	mov    0x14(%ebp),%eax
  802d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  802d9e:	8b 75 10             	mov    0x10(%ebp),%esi
  802da1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802da4:	85 c0                	test   %eax,%eax
  802da6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802da9:	75 35                	jne    802de0 <__udivdi3+0x50>
  802dab:	39 fe                	cmp    %edi,%esi
  802dad:	77 61                	ja     802e10 <__udivdi3+0x80>
  802daf:	85 f6                	test   %esi,%esi
  802db1:	75 0b                	jne    802dbe <__udivdi3+0x2e>
  802db3:	b8 01 00 00 00       	mov    $0x1,%eax
  802db8:	31 d2                	xor    %edx,%edx
  802dba:	f7 f6                	div    %esi
  802dbc:	89 c6                	mov    %eax,%esi
  802dbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802dc1:	31 d2                	xor    %edx,%edx
  802dc3:	89 f8                	mov    %edi,%eax
  802dc5:	f7 f6                	div    %esi
  802dc7:	89 c7                	mov    %eax,%edi
  802dc9:	89 c8                	mov    %ecx,%eax
  802dcb:	f7 f6                	div    %esi
  802dcd:	89 c1                	mov    %eax,%ecx
  802dcf:	89 fa                	mov    %edi,%edx
  802dd1:	89 c8                	mov    %ecx,%eax
  802dd3:	83 c4 10             	add    $0x10,%esp
  802dd6:	5e                   	pop    %esi
  802dd7:	5f                   	pop    %edi
  802dd8:	5d                   	pop    %ebp
  802dd9:	c3                   	ret    
  802dda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802de0:	39 f8                	cmp    %edi,%eax
  802de2:	77 1c                	ja     802e00 <__udivdi3+0x70>
  802de4:	0f bd d0             	bsr    %eax,%edx
  802de7:	83 f2 1f             	xor    $0x1f,%edx
  802dea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802ded:	75 39                	jne    802e28 <__udivdi3+0x98>
  802def:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802df2:	0f 86 a0 00 00 00    	jbe    802e98 <__udivdi3+0x108>
  802df8:	39 f8                	cmp    %edi,%eax
  802dfa:	0f 82 98 00 00 00    	jb     802e98 <__udivdi3+0x108>
  802e00:	31 ff                	xor    %edi,%edi
  802e02:	31 c9                	xor    %ecx,%ecx
  802e04:	89 c8                	mov    %ecx,%eax
  802e06:	89 fa                	mov    %edi,%edx
  802e08:	83 c4 10             	add    $0x10,%esp
  802e0b:	5e                   	pop    %esi
  802e0c:	5f                   	pop    %edi
  802e0d:	5d                   	pop    %ebp
  802e0e:	c3                   	ret    
  802e0f:	90                   	nop
  802e10:	89 d1                	mov    %edx,%ecx
  802e12:	89 fa                	mov    %edi,%edx
  802e14:	89 c8                	mov    %ecx,%eax
  802e16:	31 ff                	xor    %edi,%edi
  802e18:	f7 f6                	div    %esi
  802e1a:	89 c1                	mov    %eax,%ecx
  802e1c:	89 fa                	mov    %edi,%edx
  802e1e:	89 c8                	mov    %ecx,%eax
  802e20:	83 c4 10             	add    $0x10,%esp
  802e23:	5e                   	pop    %esi
  802e24:	5f                   	pop    %edi
  802e25:	5d                   	pop    %ebp
  802e26:	c3                   	ret    
  802e27:	90                   	nop
  802e28:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802e2c:	89 f2                	mov    %esi,%edx
  802e2e:	d3 e0                	shl    %cl,%eax
  802e30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802e33:	b8 20 00 00 00       	mov    $0x20,%eax
  802e38:	2b 45 f4             	sub    -0xc(%ebp),%eax
  802e3b:	89 c1                	mov    %eax,%ecx
  802e3d:	d3 ea                	shr    %cl,%edx
  802e3f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802e43:	0b 55 ec             	or     -0x14(%ebp),%edx
  802e46:	d3 e6                	shl    %cl,%esi
  802e48:	89 c1                	mov    %eax,%ecx
  802e4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  802e4d:	89 fe                	mov    %edi,%esi
  802e4f:	d3 ee                	shr    %cl,%esi
  802e51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802e55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802e58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802e5b:	d3 e7                	shl    %cl,%edi
  802e5d:	89 c1                	mov    %eax,%ecx
  802e5f:	d3 ea                	shr    %cl,%edx
  802e61:	09 d7                	or     %edx,%edi
  802e63:	89 f2                	mov    %esi,%edx
  802e65:	89 f8                	mov    %edi,%eax
  802e67:	f7 75 ec             	divl   -0x14(%ebp)
  802e6a:	89 d6                	mov    %edx,%esi
  802e6c:	89 c7                	mov    %eax,%edi
  802e6e:	f7 65 e8             	mull   -0x18(%ebp)
  802e71:	39 d6                	cmp    %edx,%esi
  802e73:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802e76:	72 30                	jb     802ea8 <__udivdi3+0x118>
  802e78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802e7b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802e7f:	d3 e2                	shl    %cl,%edx
  802e81:	39 c2                	cmp    %eax,%edx
  802e83:	73 05                	jae    802e8a <__udivdi3+0xfa>
  802e85:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802e88:	74 1e                	je     802ea8 <__udivdi3+0x118>
  802e8a:	89 f9                	mov    %edi,%ecx
  802e8c:	31 ff                	xor    %edi,%edi
  802e8e:	e9 71 ff ff ff       	jmp    802e04 <__udivdi3+0x74>
  802e93:	90                   	nop
  802e94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802e98:	31 ff                	xor    %edi,%edi
  802e9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  802e9f:	e9 60 ff ff ff       	jmp    802e04 <__udivdi3+0x74>
  802ea4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802ea8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  802eab:	31 ff                	xor    %edi,%edi
  802ead:	89 c8                	mov    %ecx,%eax
  802eaf:	89 fa                	mov    %edi,%edx
  802eb1:	83 c4 10             	add    $0x10,%esp
  802eb4:	5e                   	pop    %esi
  802eb5:	5f                   	pop    %edi
  802eb6:	5d                   	pop    %ebp
  802eb7:	c3                   	ret    
	...

00802ec0 <__umoddi3>:
  802ec0:	55                   	push   %ebp
  802ec1:	89 e5                	mov    %esp,%ebp
  802ec3:	57                   	push   %edi
  802ec4:	56                   	push   %esi
  802ec5:	83 ec 20             	sub    $0x20,%esp
  802ec8:	8b 55 14             	mov    0x14(%ebp),%edx
  802ecb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802ece:	8b 7d 10             	mov    0x10(%ebp),%edi
  802ed1:	8b 75 0c             	mov    0xc(%ebp),%esi
  802ed4:	85 d2                	test   %edx,%edx
  802ed6:	89 c8                	mov    %ecx,%eax
  802ed8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  802edb:	75 13                	jne    802ef0 <__umoddi3+0x30>
  802edd:	39 f7                	cmp    %esi,%edi
  802edf:	76 3f                	jbe    802f20 <__umoddi3+0x60>
  802ee1:	89 f2                	mov    %esi,%edx
  802ee3:	f7 f7                	div    %edi
  802ee5:	89 d0                	mov    %edx,%eax
  802ee7:	31 d2                	xor    %edx,%edx
  802ee9:	83 c4 20             	add    $0x20,%esp
  802eec:	5e                   	pop    %esi
  802eed:	5f                   	pop    %edi
  802eee:	5d                   	pop    %ebp
  802eef:	c3                   	ret    
  802ef0:	39 f2                	cmp    %esi,%edx
  802ef2:	77 4c                	ja     802f40 <__umoddi3+0x80>
  802ef4:	0f bd ca             	bsr    %edx,%ecx
  802ef7:	83 f1 1f             	xor    $0x1f,%ecx
  802efa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  802efd:	75 51                	jne    802f50 <__umoddi3+0x90>
  802eff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802f02:	0f 87 e0 00 00 00    	ja     802fe8 <__umoddi3+0x128>
  802f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f0b:	29 f8                	sub    %edi,%eax
  802f0d:	19 d6                	sbb    %edx,%esi
  802f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802f12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f15:	89 f2                	mov    %esi,%edx
  802f17:	83 c4 20             	add    $0x20,%esp
  802f1a:	5e                   	pop    %esi
  802f1b:	5f                   	pop    %edi
  802f1c:	5d                   	pop    %ebp
  802f1d:	c3                   	ret    
  802f1e:	66 90                	xchg   %ax,%ax
  802f20:	85 ff                	test   %edi,%edi
  802f22:	75 0b                	jne    802f2f <__umoddi3+0x6f>
  802f24:	b8 01 00 00 00       	mov    $0x1,%eax
  802f29:	31 d2                	xor    %edx,%edx
  802f2b:	f7 f7                	div    %edi
  802f2d:	89 c7                	mov    %eax,%edi
  802f2f:	89 f0                	mov    %esi,%eax
  802f31:	31 d2                	xor    %edx,%edx
  802f33:	f7 f7                	div    %edi
  802f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802f38:	f7 f7                	div    %edi
  802f3a:	eb a9                	jmp    802ee5 <__umoddi3+0x25>
  802f3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802f40:	89 c8                	mov    %ecx,%eax
  802f42:	89 f2                	mov    %esi,%edx
  802f44:	83 c4 20             	add    $0x20,%esp
  802f47:	5e                   	pop    %esi
  802f48:	5f                   	pop    %edi
  802f49:	5d                   	pop    %ebp
  802f4a:	c3                   	ret    
  802f4b:	90                   	nop
  802f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802f50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802f54:	d3 e2                	shl    %cl,%edx
  802f56:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802f59:	ba 20 00 00 00       	mov    $0x20,%edx
  802f5e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802f61:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802f64:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802f68:	89 fa                	mov    %edi,%edx
  802f6a:	d3 ea                	shr    %cl,%edx
  802f6c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802f70:	0b 55 f4             	or     -0xc(%ebp),%edx
  802f73:	d3 e7                	shl    %cl,%edi
  802f75:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802f79:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802f7c:	89 f2                	mov    %esi,%edx
  802f7e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802f81:	89 c7                	mov    %eax,%edi
  802f83:	d3 ea                	shr    %cl,%edx
  802f85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802f89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  802f8c:	89 c2                	mov    %eax,%edx
  802f8e:	d3 e6                	shl    %cl,%esi
  802f90:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802f94:	d3 ea                	shr    %cl,%edx
  802f96:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802f9a:	09 d6                	or     %edx,%esi
  802f9c:	89 f0                	mov    %esi,%eax
  802f9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802fa1:	d3 e7                	shl    %cl,%edi
  802fa3:	89 f2                	mov    %esi,%edx
  802fa5:	f7 75 f4             	divl   -0xc(%ebp)
  802fa8:	89 d6                	mov    %edx,%esi
  802faa:	f7 65 e8             	mull   -0x18(%ebp)
  802fad:	39 d6                	cmp    %edx,%esi
  802faf:	72 2b                	jb     802fdc <__umoddi3+0x11c>
  802fb1:	39 c7                	cmp    %eax,%edi
  802fb3:	72 23                	jb     802fd8 <__umoddi3+0x118>
  802fb5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802fb9:	29 c7                	sub    %eax,%edi
  802fbb:	19 d6                	sbb    %edx,%esi
  802fbd:	89 f0                	mov    %esi,%eax
  802fbf:	89 f2                	mov    %esi,%edx
  802fc1:	d3 ef                	shr    %cl,%edi
  802fc3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802fc7:	d3 e0                	shl    %cl,%eax
  802fc9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802fcd:	09 f8                	or     %edi,%eax
  802fcf:	d3 ea                	shr    %cl,%edx
  802fd1:	83 c4 20             	add    $0x20,%esp
  802fd4:	5e                   	pop    %esi
  802fd5:	5f                   	pop    %edi
  802fd6:	5d                   	pop    %ebp
  802fd7:	c3                   	ret    
  802fd8:	39 d6                	cmp    %edx,%esi
  802fda:	75 d9                	jne    802fb5 <__umoddi3+0xf5>
  802fdc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  802fdf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802fe2:	eb d1                	jmp    802fb5 <__umoddi3+0xf5>
  802fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802fe8:	39 f2                	cmp    %esi,%edx
  802fea:	0f 82 18 ff ff ff    	jb     802f08 <__umoddi3+0x48>
  802ff0:	e9 1d ff ff ff       	jmp    802f12 <__umoddi3+0x52>
