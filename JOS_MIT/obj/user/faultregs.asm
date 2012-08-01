
obj/user/faultregs.debug:     file format elf32-i386


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
  80002c:	e8 73 05 00 00       	call   8005a4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800054:	89 54 24 08          	mov    %edx,0x8(%esp)
  800058:	c7 44 24 04 d1 28 80 	movl   $0x8028d1,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 a0 28 80 00 	movl   $0x8028a0,(%esp)
  800067:	e8 5d 06 00 00       	call   8006c9 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	89 44 24 08          	mov    %eax,0x8(%esp)
  800078:	c7 44 24 04 b0 28 80 	movl   $0x8028b0,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  800087:	e8 3d 06 00 00       	call   8006c9 <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  800099:	e8 2b 06 00 00       	call   8006c9 <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  8000ac:	e8 18 06 00 00       	call   8006c9 <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 d2 28 80 	movl   $0x8028d2,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  8000d3:	e8 f1 05 00 00       	call   8006c9 <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  8000e7:	e8 dd 05 00 00       	call   8006c9 <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  8000f5:	e8 cf 05 00 00       	call   8006c9 <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 d6 28 80 	movl   $0x8028d6,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  80011c:	e8 a8 05 00 00       	call   8006c9 <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  800130:	e8 94 05 00 00       	call   8006c9 <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  80013e:	e8 86 05 00 00       	call   8006c9 <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 da 28 80 	movl   $0x8028da,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  800165:	e8 5f 05 00 00       	call   8006c9 <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  800179:	e8 4b 05 00 00       	call   8006c9 <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  800187:	e8 3d 05 00 00       	call   8006c9 <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 de 28 80 	movl   $0x8028de,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  8001ae:	e8 16 05 00 00       	call   8006c9 <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  8001c2:	e8 02 05 00 00       	call   8006c9 <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  8001d0:	e8 f4 04 00 00       	call   8006c9 <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 e2 28 80 	movl   $0x8028e2,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  8001f7:	e8 cd 04 00 00       	call   8006c9 <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  80020b:	e8 b9 04 00 00       	call   8006c9 <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  800219:	e8 ab 04 00 00       	call   8006c9 <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 e6 28 80 	movl   $0x8028e6,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  800240:	e8 84 04 00 00       	call   8006c9 <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  800254:	e8 70 04 00 00       	call   8006c9 <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  800262:	e8 62 04 00 00       	call   8006c9 <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 ea 28 80 	movl   $0x8028ea,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  800289:	e8 3b 04 00 00       	call   8006c9 <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  80029d:	e8 27 04 00 00       	call   8006c9 <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  8002ab:	e8 19 04 00 00       	call   8006c9 <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 ee 28 80 	movl   $0x8028ee,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  8002d2:	e8 f2 03 00 00       	call   8006c9 <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  8002e6:	e8 de 03 00 00       	call   8006c9 <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  8002f4:	e8 d0 03 00 00       	call   8006c9 <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 f5 28 80 	movl   $0x8028f5,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 b4 28 80 00 	movl   $0x8028b4,(%esp)
  80031b:	e8 a9 03 00 00       	call   8006c9 <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  80032f:	e8 95 03 00 00       	call   8006c9 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 f9 28 80 00 	movl   $0x8028f9,(%esp)
  800342:	e8 82 03 00 00       	call   8006c9 <cprintf>
	if (!mismatch)
  800347:	85 ff                	test   %edi,%edi
  800349:	74 23                	je     80036e <check_regs+0x32e>
  80034b:	eb 2f                	jmp    80037c <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  80034d:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  800354:	e8 70 03 00 00       	call   8006c9 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 f9 28 80 00 	movl   $0x8028f9,(%esp)
  800367:	e8 5d 03 00 00       	call   8006c9 <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 c4 28 80 00 	movl   $0x8028c4,(%esp)
  800375:	e8 4f 03 00 00       	call   8006c9 <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 c8 28 80 00 	movl   $0x8028c8,(%esp)
  800383:	e8 41 03 00 00       	call   8006c9 <cprintf>
}
  800388:	83 c4 1c             	add    $0x1c,%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <umain>:
		panic("sys_page_alloc: %e", r);
}

void
umain(int argc, char **argv)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800396:	c7 04 24 a1 04 80 00 	movl   $0x8004a1,(%esp)
  80039d:	e8 5e 12 00 00       	call   801600 <set_pgfault_handler>

	__asm __volatile(
  8003a2:	50                   	push   %eax
  8003a3:	9c                   	pushf  
  8003a4:	58                   	pop    %eax
  8003a5:	0d d5 08 00 00       	or     $0x8d5,%eax
  8003aa:	50                   	push   %eax
  8003ab:	9d                   	popf   
  8003ac:	a3 24 40 80 00       	mov    %eax,0x804024
  8003b1:	8d 05 ec 03 80 00    	lea    0x8003ec,%eax
  8003b7:	a3 20 40 80 00       	mov    %eax,0x804020
  8003bc:	58                   	pop    %eax
  8003bd:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8003c3:	89 35 04 40 80 00    	mov    %esi,0x804004
  8003c9:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8003cf:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8003d5:	89 15 14 40 80 00    	mov    %edx,0x804014
  8003db:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  8003e1:	a3 1c 40 80 00       	mov    %eax,0x80401c
  8003e6:	89 25 28 40 80 00    	mov    %esp,0x804028
  8003ec:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003f3:	00 00 00 
  8003f6:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8003fc:	89 35 84 40 80 00    	mov    %esi,0x804084
  800402:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  800408:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  80040e:	89 15 94 40 80 00    	mov    %edx,0x804094
  800414:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  80041a:	a3 9c 40 80 00       	mov    %eax,0x80409c
  80041f:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  800425:	8b 3d 00 40 80 00    	mov    0x804000,%edi
  80042b:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800431:	8b 2d 08 40 80 00    	mov    0x804008,%ebp
  800437:	8b 1d 10 40 80 00    	mov    0x804010,%ebx
  80043d:	8b 15 14 40 80 00    	mov    0x804014,%edx
  800443:	8b 0d 18 40 80 00    	mov    0x804018,%ecx
  800449:	a1 1c 40 80 00       	mov    0x80401c,%eax
  80044e:	8b 25 28 40 80 00    	mov    0x804028,%esp
  800454:	50                   	push   %eax
  800455:	9c                   	pushf  
  800456:	58                   	pop    %eax
  800457:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80045c:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80045d:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800464:	74 0c                	je     800472 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800466:	c7 04 24 60 29 80 00 	movl   $0x802960,(%esp)
  80046d:	e8 57 02 00 00       	call   8006c9 <cprintf>
	after.eip = before.eip;
  800472:	a1 20 40 80 00       	mov    0x804020,%eax
  800477:	a3 a0 40 80 00       	mov    %eax,0x8040a0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 0e 29 80 	movl   $0x80290e,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 1f 29 80 00 	movl   $0x80291f,(%esp)
  80048b:	b9 80 40 80 00       	mov    $0x804080,%ecx
  800490:	ba 07 29 80 00       	mov    $0x802907,%edx
  800495:	b8 00 40 80 00       	mov    $0x804000,%eax
  80049a:	e8 a1 fb ff ff       	call   800040 <check_regs>
}
  80049f:	c9                   	leave  
  8004a0:	c3                   	ret    

008004a1 <pgfault>:
		cprintf("MISMATCH\n");
}

static void
pgfault(struct UTrapframe *utf)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
  8004a4:	83 ec 28             	sub    $0x28,%esp
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8004b2:	74 27                	je     8004db <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004b4:	8b 40 28             	mov    0x28(%eax),%eax
  8004b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bf:	c7 44 24 08 80 29 80 	movl   $0x802980,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 25 29 80 00 	movl   $0x802925,(%esp)
  8004d6:	e8 35 01 00 00       	call   800610 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004db:	8b 50 08             	mov    0x8(%eax),%edx
  8004de:	89 15 40 40 80 00    	mov    %edx,0x804040
  8004e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8004e7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8004ed:	8b 50 10             	mov    0x10(%eax),%edx
  8004f0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8004f6:	8b 50 14             	mov    0x14(%eax),%edx
  8004f9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8004ff:	8b 50 18             	mov    0x18(%eax),%edx
  800502:	89 15 50 40 80 00    	mov    %edx,0x804050
  800508:	8b 50 1c             	mov    0x1c(%eax),%edx
  80050b:	89 15 54 40 80 00    	mov    %edx,0x804054
  800511:	8b 50 20             	mov    0x20(%eax),%edx
  800514:	89 15 58 40 80 00    	mov    %edx,0x804058
  80051a:	8b 50 24             	mov    0x24(%eax),%edx
  80051d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800523:	8b 50 28             	mov    0x28(%eax),%edx
  800526:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80052c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80052f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800535:	8b 40 30             	mov    0x30(%eax),%eax
  800538:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80053d:	c7 44 24 04 36 29 80 	movl   $0x802936,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 44 29 80 00 	movl   $0x802944,(%esp)
  80054c:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800551:	ba 07 29 80 00       	mov    $0x802907,%edx
  800556:	b8 00 40 80 00       	mov    $0x804000,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 f1 0e 00 00       	call   80146d <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 4b 29 80 	movl   $0x80294b,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 25 29 80 00 	movl   $0x802925,(%esp)
  80059b:	e8 70 00 00 00       	call   800610 <_panic>
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    
	...

008005a4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	83 ec 18             	sub    $0x18,%esp
  8005aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8005b6:	e8 5c 0f 00 00       	call   801517 <sys_getenvid>
  8005bb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005c3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005c8:	a3 b4 40 80 00       	mov    %eax,0x8040b4

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005cd:	85 f6                	test   %esi,%esi
  8005cf:	7e 07                	jle    8005d8 <libmain+0x34>
		binaryname = argv[0];
  8005d1:	8b 03                	mov    (%ebx),%eax
  8005d3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005d8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005dc:	89 34 24             	mov    %esi,(%esp)
  8005df:	e8 ac fd ff ff       	call   800390 <umain>

	// exit gracefully
	exit();
  8005e4:	e8 0b 00 00 00       	call   8005f4 <exit>
}
  8005e9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005ec:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005ef:	89 ec                	mov    %ebp,%esp
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
	...

008005f4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005f4:	55                   	push   %ebp
  8005f5:	89 e5                	mov    %esp,%ebp
  8005f7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8005fa:	e8 8a 15 00 00       	call   801b89 <close_all>
	sys_env_destroy(0);
  8005ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800606:	e8 47 0f 00 00       	call   801552 <sys_env_destroy>
}
  80060b:	c9                   	leave  
  80060c:	c3                   	ret    
  80060d:	00 00                	add    %al,(%eax)
	...

00800610 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800610:	55                   	push   %ebp
  800611:	89 e5                	mov    %esp,%ebp
  800613:	56                   	push   %esi
  800614:	53                   	push   %ebx
  800615:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800618:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80061b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800621:	e8 f1 0e 00 00       	call   801517 <sys_getenvid>
  800626:	8b 55 0c             	mov    0xc(%ebp),%edx
  800629:	89 54 24 10          	mov    %edx,0x10(%esp)
  80062d:	8b 55 08             	mov    0x8(%ebp),%edx
  800630:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800634:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800638:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063c:	c7 04 24 bc 29 80 00 	movl   $0x8029bc,(%esp)
  800643:	e8 81 00 00 00       	call   8006c9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800648:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064c:	8b 45 10             	mov    0x10(%ebp),%eax
  80064f:	89 04 24             	mov    %eax,(%esp)
  800652:	e8 11 00 00 00       	call   800668 <vcprintf>
	cprintf("\n");
  800657:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  80065e:	e8 66 00 00 00       	call   8006c9 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800663:	cc                   	int3   
  800664:	eb fd                	jmp    800663 <_panic+0x53>
	...

00800668 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800668:	55                   	push   %ebp
  800669:	89 e5                	mov    %esp,%ebp
  80066b:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800671:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800678:	00 00 00 
	b.cnt = 0;
  80067b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800682:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800685:	8b 45 0c             	mov    0xc(%ebp),%eax
  800688:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800693:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800699:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069d:	c7 04 24 e3 06 80 00 	movl   $0x8006e3,(%esp)
  8006a4:	e8 d4 01 00 00       	call   80087d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b9:	89 04 24             	mov    %eax,(%esp)
  8006bc:	e8 05 0f 00 00       	call   8015c6 <sys_cputs>

	return b.cnt;
}
  8006c1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c7:	c9                   	leave  
  8006c8:	c3                   	ret    

008006c9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c9:	55                   	push   %ebp
  8006ca:	89 e5                	mov    %esp,%ebp
  8006cc:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006cf:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d9:	89 04 24             	mov    %eax,(%esp)
  8006dc:	e8 87 ff ff ff       	call   800668 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	53                   	push   %ebx
  8006e7:	83 ec 14             	sub    $0x14,%esp
  8006ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006ed:	8b 03                	mov    (%ebx),%eax
  8006ef:	8b 55 08             	mov    0x8(%ebp),%edx
  8006f2:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006f6:	83 c0 01             	add    $0x1,%eax
  8006f9:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006fb:	3d ff 00 00 00       	cmp    $0xff,%eax
  800700:	75 19                	jne    80071b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800702:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800709:	00 
  80070a:	8d 43 08             	lea    0x8(%ebx),%eax
  80070d:	89 04 24             	mov    %eax,(%esp)
  800710:	e8 b1 0e 00 00       	call   8015c6 <sys_cputs>
		b->idx = 0;
  800715:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80071b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80071f:	83 c4 14             	add    $0x14,%esp
  800722:	5b                   	pop    %ebx
  800723:	5d                   	pop    %ebp
  800724:	c3                   	ret    
	...

00800730 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	57                   	push   %edi
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	83 ec 4c             	sub    $0x4c,%esp
  800739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073c:	89 d6                	mov    %edx,%esi
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
  800747:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800750:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800753:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	39 d1                	cmp    %edx,%ecx
  80075d:	72 15                	jb     800774 <printnum+0x44>
  80075f:	77 07                	ja     800768 <printnum+0x38>
  800761:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800764:	39 d0                	cmp    %edx,%eax
  800766:	76 0c                	jbe    800774 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800768:	83 eb 01             	sub    $0x1,%ebx
  80076b:	85 db                	test   %ebx,%ebx
  80076d:	8d 76 00             	lea    0x0(%esi),%esi
  800770:	7f 61                	jg     8007d3 <printnum+0xa3>
  800772:	eb 70                	jmp    8007e4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800774:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800778:	83 eb 01             	sub    $0x1,%ebx
  80077b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800787:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80078b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80078e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800791:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800794:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800798:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80079f:	00 
  8007a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ad:	e8 6e 1e 00 00       	call   802620 <__udivdi3>
  8007b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007cc:	e8 5f ff ff ff       	call   800730 <printnum>
  8007d1:	eb 11                	jmp    8007e4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d7:	89 3c 24             	mov    %edi,(%esp)
  8007da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007dd:	83 eb 01             	sub    $0x1,%ebx
  8007e0:	85 db                	test   %ebx,%ebx
  8007e2:	7f ef                	jg     8007d3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007fa:	00 
  8007fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fe:	89 14 24             	mov    %edx,(%esp)
  800801:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800804:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800808:	e8 43 1f 00 00       	call   802750 <__umoddi3>
  80080d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800811:	0f be 80 df 29 80 00 	movsbl 0x8029df(%eax),%eax
  800818:	89 04 24             	mov    %eax,(%esp)
  80081b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80081e:	83 c4 4c             	add    $0x4c,%esp
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5f                   	pop    %edi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800829:	83 fa 01             	cmp    $0x1,%edx
  80082c:	7e 0e                	jle    80083c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	8d 4a 08             	lea    0x8(%edx),%ecx
  800833:	89 08                	mov    %ecx,(%eax)
  800835:	8b 02                	mov    (%edx),%eax
  800837:	8b 52 04             	mov    0x4(%edx),%edx
  80083a:	eb 22                	jmp    80085e <getuint+0x38>
	else if (lflag)
  80083c:	85 d2                	test   %edx,%edx
  80083e:	74 10                	je     800850 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800840:	8b 10                	mov    (%eax),%edx
  800842:	8d 4a 04             	lea    0x4(%edx),%ecx
  800845:	89 08                	mov    %ecx,(%eax)
  800847:	8b 02                	mov    (%edx),%eax
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
  80084e:	eb 0e                	jmp    80085e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800850:	8b 10                	mov    (%eax),%edx
  800852:	8d 4a 04             	lea    0x4(%edx),%ecx
  800855:	89 08                	mov    %ecx,(%eax)
  800857:	8b 02                	mov    (%edx),%eax
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800866:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80086a:	8b 10                	mov    (%eax),%edx
  80086c:	3b 50 04             	cmp    0x4(%eax),%edx
  80086f:	73 0a                	jae    80087b <sprintputch+0x1b>
		*b->buf++ = ch;
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	88 0a                	mov    %cl,(%edx)
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	89 10                	mov    %edx,(%eax)
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	83 ec 5c             	sub    $0x5c,%esp
  800886:	8b 7d 08             	mov    0x8(%ebp),%edi
  800889:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80088f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800896:	eb 11                	jmp    8008a9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800898:	85 c0                	test   %eax,%eax
  80089a:	0f 84 68 04 00 00    	je     800d08 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8008a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a9:	0f b6 03             	movzbl (%ebx),%eax
  8008ac:	83 c3 01             	add    $0x1,%ebx
  8008af:	83 f8 25             	cmp    $0x25,%eax
  8008b2:	75 e4                	jne    800898 <vprintfmt+0x1b>
  8008b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008bb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  8008c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c7:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  8008cb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008d2:	eb 06                	jmp    8008da <vprintfmt+0x5d>
  8008d4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8008d8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008da:	0f b6 13             	movzbl (%ebx),%edx
  8008dd:	0f b6 c2             	movzbl %dl,%eax
  8008e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008e3:	8d 43 01             	lea    0x1(%ebx),%eax
  8008e6:	83 ea 23             	sub    $0x23,%edx
  8008e9:	80 fa 55             	cmp    $0x55,%dl
  8008ec:	0f 87 f9 03 00 00    	ja     800ceb <vprintfmt+0x46e>
  8008f2:	0f b6 d2             	movzbl %dl,%edx
  8008f5:	ff 24 95 c0 2b 80 00 	jmp    *0x802bc0(,%edx,4)
  8008fc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800900:	eb d6                	jmp    8008d8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800902:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800905:	83 ea 30             	sub    $0x30,%edx
  800908:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80090b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80090e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800911:	83 fb 09             	cmp    $0x9,%ebx
  800914:	77 54                	ja     80096a <vprintfmt+0xed>
  800916:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800919:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80091c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80091f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800922:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800926:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800929:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80092c:	83 fb 09             	cmp    $0x9,%ebx
  80092f:	76 eb                	jbe    80091c <vprintfmt+0x9f>
  800931:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800934:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800937:	eb 31                	jmp    80096a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800939:	8b 55 14             	mov    0x14(%ebp),%edx
  80093c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80093f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800942:	8b 12                	mov    (%edx),%edx
  800944:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800947:	eb 21                	jmp    80096a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800949:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800956:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800959:	e9 7a ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>
  80095e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800965:	e9 6e ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80096a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80096e:	0f 89 64 ff ff ff    	jns    8008d8 <vprintfmt+0x5b>
  800974:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800977:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80097a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80097d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800980:	e9 53 ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800985:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800988:	e9 4b ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>
  80098d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800990:	8b 45 14             	mov    0x14(%ebp),%eax
  800993:	8d 50 04             	lea    0x4(%eax),%edx
  800996:	89 55 14             	mov    %edx,0x14(%ebp)
  800999:	89 74 24 04          	mov    %esi,0x4(%esp)
  80099d:	8b 00                	mov    (%eax),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	ff d7                	call   *%edi
  8009a4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8009a7:	e9 fd fe ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  8009ac:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 c2                	mov    %eax,%edx
  8009bc:	c1 fa 1f             	sar    $0x1f,%edx
  8009bf:	31 d0                	xor    %edx,%eax
  8009c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c3:	83 f8 0f             	cmp    $0xf,%eax
  8009c6:	7f 0b                	jg     8009d3 <vprintfmt+0x156>
  8009c8:	8b 14 85 20 2d 80 00 	mov    0x802d20(,%eax,4),%edx
  8009cf:	85 d2                	test   %edx,%edx
  8009d1:	75 20                	jne    8009f3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8009d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d7:	c7 44 24 08 f0 29 80 	movl   $0x8029f0,0x8(%esp)
  8009de:	00 
  8009df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e3:	89 3c 24             	mov    %edi,(%esp)
  8009e6:	e8 a5 03 00 00       	call   800d90 <printfmt>
  8009eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ee:	e9 b6 fe ff ff       	jmp    8008a9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009f7:	c7 44 24 08 67 2e 80 	movl   $0x802e67,0x8(%esp)
  8009fe:	00 
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	89 3c 24             	mov    %edi,(%esp)
  800a06:	e8 85 03 00 00       	call   800d90 <printfmt>
  800a0b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800a0e:	e9 96 fe ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800a13:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800a16:	89 c3                	mov    %eax,%ebx
  800a18:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a1b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  800a1e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a21:	8b 45 14             	mov    0x14(%ebp),%eax
  800a24:	8d 50 04             	lea    0x4(%eax),%edx
  800a27:	89 55 14             	mov    %edx,0x14(%ebp)
  800a2a:	8b 00                	mov    (%eax),%eax
  800a2c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	b8 f9 29 80 00       	mov    $0x8029f9,%eax
  800a36:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  800a3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a3d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800a41:	7e 06                	jle    800a49 <vprintfmt+0x1cc>
  800a43:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800a47:	75 13                	jne    800a5c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a49:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a4c:	0f be 02             	movsbl (%edx),%eax
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	0f 85 a2 00 00 00    	jne    800af9 <vprintfmt+0x27c>
  800a57:	e9 8f 00 00 00       	jmp    800aeb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a5c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a60:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800a63:	89 0c 24             	mov    %ecx,(%esp)
  800a66:	e8 70 03 00 00       	call   800ddb <strnlen>
  800a6b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a6e:	29 c2                	sub    %eax,%edx
  800a70:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800a73:	85 d2                	test   %edx,%edx
  800a75:	7e d2                	jle    800a49 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800a77:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800a7b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800a7e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800a81:	89 d3                	mov    %edx,%ebx
  800a83:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a87:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a8a:	89 04 24             	mov    %eax,(%esp)
  800a8d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a8f:	83 eb 01             	sub    $0x1,%ebx
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	7f ed                	jg     800a83 <vprintfmt+0x206>
  800a96:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800a99:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800aa0:	eb a7                	jmp    800a49 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aa2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800aa6:	74 1b                	je     800ac3 <vprintfmt+0x246>
  800aa8:	8d 50 e0             	lea    -0x20(%eax),%edx
  800aab:	83 fa 5e             	cmp    $0x5e,%edx
  800aae:	76 13                	jbe    800ac3 <vprintfmt+0x246>
					putch('?', putdat);
  800ab0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ab3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ab7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800abe:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800ac1:	eb 0d                	jmp    800ad0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800ac3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800ac6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800aca:	89 04 24             	mov    %eax,(%esp)
  800acd:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ad0:	83 ef 01             	sub    $0x1,%edi
  800ad3:	0f be 03             	movsbl (%ebx),%eax
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	74 05                	je     800adf <vprintfmt+0x262>
  800ada:	83 c3 01             	add    $0x1,%ebx
  800add:	eb 31                	jmp    800b10 <vprintfmt+0x293>
  800adf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800ae2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ae5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800ae8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800aeb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800aef:	7f 36                	jg     800b27 <vprintfmt+0x2aa>
  800af1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800af4:	e9 b0 fd ff ff       	jmp    8008a9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800af9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800afc:	83 c2 01             	add    $0x1,%edx
  800aff:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800b02:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800b05:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800b08:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800b0b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800b0e:	89 d3                	mov    %edx,%ebx
  800b10:	85 f6                	test   %esi,%esi
  800b12:	78 8e                	js     800aa2 <vprintfmt+0x225>
  800b14:	83 ee 01             	sub    $0x1,%esi
  800b17:	79 89                	jns    800aa2 <vprintfmt+0x225>
  800b19:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800b1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b1f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800b22:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800b25:	eb c4                	jmp    800aeb <vprintfmt+0x26e>
  800b27:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  800b2a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b2d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b31:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b38:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b3a:	83 eb 01             	sub    $0x1,%ebx
  800b3d:	85 db                	test   %ebx,%ebx
  800b3f:	7f ec                	jg     800b2d <vprintfmt+0x2b0>
  800b41:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800b44:	e9 60 fd ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800b49:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b4c:	83 f9 01             	cmp    $0x1,%ecx
  800b4f:	7e 16                	jle    800b67 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800b51:	8b 45 14             	mov    0x14(%ebp),%eax
  800b54:	8d 50 08             	lea    0x8(%eax),%edx
  800b57:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5a:	8b 10                	mov    (%eax),%edx
  800b5c:	8b 48 04             	mov    0x4(%eax),%ecx
  800b5f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800b62:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b65:	eb 32                	jmp    800b99 <vprintfmt+0x31c>
	else if (lflag)
  800b67:	85 c9                	test   %ecx,%ecx
  800b69:	74 18                	je     800b83 <vprintfmt+0x306>
		return va_arg(*ap, long);
  800b6b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b6e:	8d 50 04             	lea    0x4(%eax),%edx
  800b71:	89 55 14             	mov    %edx,0x14(%ebp)
  800b74:	8b 00                	mov    (%eax),%eax
  800b76:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b79:	89 c1                	mov    %eax,%ecx
  800b7b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b7e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b81:	eb 16                	jmp    800b99 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800b83:	8b 45 14             	mov    0x14(%ebp),%eax
  800b86:	8d 50 04             	lea    0x4(%eax),%edx
  800b89:	89 55 14             	mov    %edx,0x14(%ebp)
  800b8c:	8b 00                	mov    (%eax),%eax
  800b8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b91:	89 c2                	mov    %eax,%edx
  800b93:	c1 fa 1f             	sar    $0x1f,%edx
  800b96:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b99:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b9c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b9f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800ba4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ba8:	0f 89 8a 00 00 00    	jns    800c38 <vprintfmt+0x3bb>
				putch('-', putdat);
  800bae:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bb2:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800bb9:	ff d7                	call   *%edi
				num = -(long long) num;
  800bbb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800bbe:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800bc1:	f7 d8                	neg    %eax
  800bc3:	83 d2 00             	adc    $0x0,%edx
  800bc6:	f7 da                	neg    %edx
  800bc8:	eb 6e                	jmp    800c38 <vprintfmt+0x3bb>
  800bca:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bcd:	89 ca                	mov    %ecx,%edx
  800bcf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd2:	e8 4f fc ff ff       	call   800826 <getuint>
  800bd7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  800bdc:	eb 5a                	jmp    800c38 <vprintfmt+0x3bb>
  800bde:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800be1:	89 ca                	mov    %ecx,%edx
  800be3:	8d 45 14             	lea    0x14(%ebp),%eax
  800be6:	e8 3b fc ff ff       	call   800826 <getuint>
  800beb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800bf0:	eb 46                	jmp    800c38 <vprintfmt+0x3bb>
  800bf2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800bf5:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c00:	ff d7                	call   *%edi
			putch('x', putdat);
  800c02:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c06:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c0d:	ff d7                	call   *%edi
			num = (unsigned long long)
  800c0f:	8b 45 14             	mov    0x14(%ebp),%eax
  800c12:	8d 50 04             	lea    0x4(%eax),%edx
  800c15:	89 55 14             	mov    %edx,0x14(%ebp)
  800c18:	8b 00                	mov    (%eax),%eax
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c24:	eb 12                	jmp    800c38 <vprintfmt+0x3bb>
  800c26:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c29:	89 ca                	mov    %ecx,%edx
  800c2b:	8d 45 14             	lea    0x14(%ebp),%eax
  800c2e:	e8 f3 fb ff ff       	call   800826 <getuint>
  800c33:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c38:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  800c3c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800c40:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800c43:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c47:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c4b:	89 04 24             	mov    %eax,(%esp)
  800c4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c52:	89 f2                	mov    %esi,%edx
  800c54:	89 f8                	mov    %edi,%eax
  800c56:	e8 d5 fa ff ff       	call   800730 <printnum>
  800c5b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800c5e:	e9 46 fc ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800c63:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800c66:	8b 45 14             	mov    0x14(%ebp),%eax
  800c69:	8d 50 04             	lea    0x4(%eax),%edx
  800c6c:	89 55 14             	mov    %edx,0x14(%ebp)
  800c6f:	8b 00                	mov    (%eax),%eax
  800c71:	85 c0                	test   %eax,%eax
  800c73:	75 24                	jne    800c99 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800c75:	c7 44 24 0c 14 2b 80 	movl   $0x802b14,0xc(%esp)
  800c7c:	00 
  800c7d:	c7 44 24 08 67 2e 80 	movl   $0x802e67,0x8(%esp)
  800c84:	00 
  800c85:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c89:	89 3c 24             	mov    %edi,(%esp)
  800c8c:	e8 ff 00 00 00       	call   800d90 <printfmt>
  800c91:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800c94:	e9 10 fc ff ff       	jmp    8008a9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800c99:	83 3e 7f             	cmpl   $0x7f,(%esi)
  800c9c:	7e 29                	jle    800cc7 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  800c9e:	0f b6 16             	movzbl (%esi),%edx
  800ca1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800ca3:	c7 44 24 0c 4c 2b 80 	movl   $0x802b4c,0xc(%esp)
  800caa:	00 
  800cab:	c7 44 24 08 67 2e 80 	movl   $0x802e67,0x8(%esp)
  800cb2:	00 
  800cb3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb7:	89 3c 24             	mov    %edi,(%esp)
  800cba:	e8 d1 00 00 00       	call   800d90 <printfmt>
  800cbf:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800cc2:	e9 e2 fb ff ff       	jmp    8008a9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800cc7:	0f b6 16             	movzbl (%esi),%edx
  800cca:	88 10                	mov    %dl,(%eax)
  800ccc:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  800ccf:	e9 d5 fb ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800cd4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800cd7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800cda:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cde:	89 14 24             	mov    %edx,(%esp)
  800ce1:	ff d7                	call   *%edi
  800ce3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800ce6:	e9 be fb ff ff       	jmp    8008a9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ceb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cef:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800cf6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800cf8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800cfb:	80 38 25             	cmpb   $0x25,(%eax)
  800cfe:	0f 84 a5 fb ff ff    	je     8008a9 <vprintfmt+0x2c>
  800d04:	89 c3                	mov    %eax,%ebx
  800d06:	eb f0                	jmp    800cf8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800d08:	83 c4 5c             	add    $0x5c,%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    

00800d10 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 28             	sub    $0x28,%esp
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	74 04                	je     800d24 <vsnprintf+0x14>
  800d20:	85 d2                	test   %edx,%edx
  800d22:	7f 07                	jg     800d2b <vsnprintf+0x1b>
  800d24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d29:	eb 3b                	jmp    800d66 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800d2e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800d32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800d35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800d3c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d43:	8b 45 10             	mov    0x10(%ebp),%eax
  800d46:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d4a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d51:	c7 04 24 60 08 80 00 	movl   $0x800860,(%esp)
  800d58:	e8 20 fb ff ff       	call   80087d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d5d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d60:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800d6e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800d71:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d75:	8b 45 10             	mov    0x10(%ebp),%eax
  800d78:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	89 04 24             	mov    %eax,(%esp)
  800d89:	e8 82 ff ff ff       	call   800d10 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800d96:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800d99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d9d:	8b 45 10             	mov    0x10(%ebp),%eax
  800da0:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da7:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	89 04 24             	mov    %eax,(%esp)
  800db1:	e8 c7 fa ff ff       	call   80087d <vprintfmt>
	va_end(ap);
}
  800db6:	c9                   	leave  
  800db7:	c3                   	ret    
	...

00800dc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800dcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800dce:	74 09                	je     800dd9 <strlen+0x19>
		n++;
  800dd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800dd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800dd7:	75 f7                	jne    800dd0 <strlen+0x10>
		n++;
	return n;
}
  800dd9:	5d                   	pop    %ebp
  800dda:	c3                   	ret    

00800ddb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800de5:	85 c9                	test   %ecx,%ecx
  800de7:	74 19                	je     800e02 <strnlen+0x27>
  800de9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800dec:	74 14                	je     800e02 <strnlen+0x27>
  800dee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800df3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800df6:	39 c8                	cmp    %ecx,%eax
  800df8:	74 0d                	je     800e07 <strnlen+0x2c>
  800dfa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800dfe:	75 f3                	jne    800df3 <strnlen+0x18>
  800e00:	eb 05                	jmp    800e07 <strnlen+0x2c>
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800e07:	5b                   	pop    %ebx
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    

00800e0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800e0a:	55                   	push   %ebp
  800e0b:	89 e5                	mov    %esp,%ebp
  800e0d:	53                   	push   %ebx
  800e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800e19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800e1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	84 c9                	test   %cl,%cl
  800e25:	75 f2                	jne    800e19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800e27:	5b                   	pop    %ebx
  800e28:	5d                   	pop    %ebp
  800e29:	c3                   	ret    

00800e2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	53                   	push   %ebx
  800e2e:	83 ec 08             	sub    $0x8,%esp
  800e31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800e34:	89 1c 24             	mov    %ebx,(%esp)
  800e37:	e8 84 ff ff ff       	call   800dc0 <strlen>
	strcpy(dst + len, src);
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800e43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800e46:	89 04 24             	mov    %eax,(%esp)
  800e49:	e8 bc ff ff ff       	call   800e0a <strcpy>
	return dst;
}
  800e4e:	89 d8                	mov    %ebx,%eax
  800e50:	83 c4 08             	add    $0x8,%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e64:	85 f6                	test   %esi,%esi
  800e66:	74 18                	je     800e80 <strncpy+0x2a>
  800e68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e6d:	0f b6 1a             	movzbl (%edx),%ebx
  800e70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e73:	80 3a 01             	cmpb   $0x1,(%edx)
  800e76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e79:	83 c1 01             	add    $0x1,%ecx
  800e7c:	39 ce                	cmp    %ecx,%esi
  800e7e:	77 ed                	ja     800e6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	56                   	push   %esi
  800e88:	53                   	push   %ebx
  800e89:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e92:	89 f0                	mov    %esi,%eax
  800e94:	85 c9                	test   %ecx,%ecx
  800e96:	74 27                	je     800ebf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800e98:	83 e9 01             	sub    $0x1,%ecx
  800e9b:	74 1d                	je     800eba <strlcpy+0x36>
  800e9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ea0:	84 db                	test   %bl,%bl
  800ea2:	74 16                	je     800eba <strlcpy+0x36>
			*dst++ = *src++;
  800ea4:	88 18                	mov    %bl,(%eax)
  800ea6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ea9:	83 e9 01             	sub    $0x1,%ecx
  800eac:	74 0e                	je     800ebc <strlcpy+0x38>
			*dst++ = *src++;
  800eae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800eb1:	0f b6 1a             	movzbl (%edx),%ebx
  800eb4:	84 db                	test   %bl,%bl
  800eb6:	75 ec                	jne    800ea4 <strlcpy+0x20>
  800eb8:	eb 02                	jmp    800ebc <strlcpy+0x38>
  800eba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ebc:	c6 00 00             	movb   $0x0,(%eax)
  800ebf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ece:	0f b6 01             	movzbl (%ecx),%eax
  800ed1:	84 c0                	test   %al,%al
  800ed3:	74 15                	je     800eea <strcmp+0x25>
  800ed5:	3a 02                	cmp    (%edx),%al
  800ed7:	75 11                	jne    800eea <strcmp+0x25>
		p++, q++;
  800ed9:	83 c1 01             	add    $0x1,%ecx
  800edc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800edf:	0f b6 01             	movzbl (%ecx),%eax
  800ee2:	84 c0                	test   %al,%al
  800ee4:	74 04                	je     800eea <strcmp+0x25>
  800ee6:	3a 02                	cmp    (%edx),%al
  800ee8:	74 ef                	je     800ed9 <strcmp+0x14>
  800eea:	0f b6 c0             	movzbl %al,%eax
  800eed:	0f b6 12             	movzbl (%edx),%edx
  800ef0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	53                   	push   %ebx
  800ef8:	8b 55 08             	mov    0x8(%ebp),%edx
  800efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800f01:	85 c0                	test   %eax,%eax
  800f03:	74 23                	je     800f28 <strncmp+0x34>
  800f05:	0f b6 1a             	movzbl (%edx),%ebx
  800f08:	84 db                	test   %bl,%bl
  800f0a:	74 25                	je     800f31 <strncmp+0x3d>
  800f0c:	3a 19                	cmp    (%ecx),%bl
  800f0e:	75 21                	jne    800f31 <strncmp+0x3d>
  800f10:	83 e8 01             	sub    $0x1,%eax
  800f13:	74 13                	je     800f28 <strncmp+0x34>
		n--, p++, q++;
  800f15:	83 c2 01             	add    $0x1,%edx
  800f18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800f1b:	0f b6 1a             	movzbl (%edx),%ebx
  800f1e:	84 db                	test   %bl,%bl
  800f20:	74 0f                	je     800f31 <strncmp+0x3d>
  800f22:	3a 19                	cmp    (%ecx),%bl
  800f24:	74 ea                	je     800f10 <strncmp+0x1c>
  800f26:	eb 09                	jmp    800f31 <strncmp+0x3d>
  800f28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800f2d:	5b                   	pop    %ebx
  800f2e:	5d                   	pop    %ebp
  800f2f:	90                   	nop
  800f30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800f31:	0f b6 02             	movzbl (%edx),%eax
  800f34:	0f b6 11             	movzbl (%ecx),%edx
  800f37:	29 d0                	sub    %edx,%eax
  800f39:	eb f2                	jmp    800f2d <strncmp+0x39>

00800f3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f45:	0f b6 10             	movzbl (%eax),%edx
  800f48:	84 d2                	test   %dl,%dl
  800f4a:	74 18                	je     800f64 <strchr+0x29>
		if (*s == c)
  800f4c:	38 ca                	cmp    %cl,%dl
  800f4e:	75 0a                	jne    800f5a <strchr+0x1f>
  800f50:	eb 17                	jmp    800f69 <strchr+0x2e>
  800f52:	38 ca                	cmp    %cl,%dl
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	74 0f                	je     800f69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f5a:	83 c0 01             	add    $0x1,%eax
  800f5d:	0f b6 10             	movzbl (%eax),%edx
  800f60:	84 d2                	test   %dl,%dl
  800f62:	75 ee                	jne    800f52 <strchr+0x17>
  800f64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f69:	5d                   	pop    %ebp
  800f6a:	c3                   	ret    

00800f6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f75:	0f b6 10             	movzbl (%eax),%edx
  800f78:	84 d2                	test   %dl,%dl
  800f7a:	74 18                	je     800f94 <strfind+0x29>
		if (*s == c)
  800f7c:	38 ca                	cmp    %cl,%dl
  800f7e:	75 0a                	jne    800f8a <strfind+0x1f>
  800f80:	eb 12                	jmp    800f94 <strfind+0x29>
  800f82:	38 ca                	cmp    %cl,%dl
  800f84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f88:	74 0a                	je     800f94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f8a:	83 c0 01             	add    $0x1,%eax
  800f8d:	0f b6 10             	movzbl (%eax),%edx
  800f90:	84 d2                	test   %dl,%dl
  800f92:	75 ee                	jne    800f82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	83 ec 0c             	sub    $0xc,%esp
  800f9c:	89 1c 24             	mov    %ebx,(%esp)
  800f9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fa7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800faa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800fb0:	85 c9                	test   %ecx,%ecx
  800fb2:	74 30                	je     800fe4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fb4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fba:	75 25                	jne    800fe1 <memset+0x4b>
  800fbc:	f6 c1 03             	test   $0x3,%cl
  800fbf:	75 20                	jne    800fe1 <memset+0x4b>
		c &= 0xFF;
  800fc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800fc4:	89 d3                	mov    %edx,%ebx
  800fc6:	c1 e3 08             	shl    $0x8,%ebx
  800fc9:	89 d6                	mov    %edx,%esi
  800fcb:	c1 e6 18             	shl    $0x18,%esi
  800fce:	89 d0                	mov    %edx,%eax
  800fd0:	c1 e0 10             	shl    $0x10,%eax
  800fd3:	09 f0                	or     %esi,%eax
  800fd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800fd7:	09 d8                	or     %ebx,%eax
  800fd9:	c1 e9 02             	shr    $0x2,%ecx
  800fdc:	fc                   	cld    
  800fdd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800fdf:	eb 03                	jmp    800fe4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800fe1:	fc                   	cld    
  800fe2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800fe4:	89 f8                	mov    %edi,%eax
  800fe6:	8b 1c 24             	mov    (%esp),%ebx
  800fe9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ff1:	89 ec                	mov    %ebp,%esp
  800ff3:	5d                   	pop    %ebp
  800ff4:	c3                   	ret    

00800ff5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 08             	sub    $0x8,%esp
  800ffb:	89 34 24             	mov    %esi,(%esp)
  800ffe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  801008:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  80100b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  80100d:	39 c6                	cmp    %eax,%esi
  80100f:	73 35                	jae    801046 <memmove+0x51>
  801011:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801014:	39 d0                	cmp    %edx,%eax
  801016:	73 2e                	jae    801046 <memmove+0x51>
		s += n;
		d += n;
  801018:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80101a:	f6 c2 03             	test   $0x3,%dl
  80101d:	75 1b                	jne    80103a <memmove+0x45>
  80101f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801025:	75 13                	jne    80103a <memmove+0x45>
  801027:	f6 c1 03             	test   $0x3,%cl
  80102a:	75 0e                	jne    80103a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  80102c:	83 ef 04             	sub    $0x4,%edi
  80102f:	8d 72 fc             	lea    -0x4(%edx),%esi
  801032:	c1 e9 02             	shr    $0x2,%ecx
  801035:	fd                   	std    
  801036:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801038:	eb 09                	jmp    801043 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80103a:	83 ef 01             	sub    $0x1,%edi
  80103d:	8d 72 ff             	lea    -0x1(%edx),%esi
  801040:	fd                   	std    
  801041:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801043:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801044:	eb 20                	jmp    801066 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801046:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80104c:	75 15                	jne    801063 <memmove+0x6e>
  80104e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801054:	75 0d                	jne    801063 <memmove+0x6e>
  801056:	f6 c1 03             	test   $0x3,%cl
  801059:	75 08                	jne    801063 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80105b:	c1 e9 02             	shr    $0x2,%ecx
  80105e:	fc                   	cld    
  80105f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801061:	eb 03                	jmp    801066 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801063:	fc                   	cld    
  801064:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801066:	8b 34 24             	mov    (%esp),%esi
  801069:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80106d:	89 ec                	mov    %ebp,%esp
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801077:	8b 45 10             	mov    0x10(%ebp),%eax
  80107a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80107e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801081:	89 44 24 04          	mov    %eax,0x4(%esp)
  801085:	8b 45 08             	mov    0x8(%ebp),%eax
  801088:	89 04 24             	mov    %eax,(%esp)
  80108b:	e8 65 ff ff ff       	call   800ff5 <memmove>
}
  801090:	c9                   	leave  
  801091:	c3                   	ret    

00801092 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	57                   	push   %edi
  801096:	56                   	push   %esi
  801097:	53                   	push   %ebx
  801098:	8b 75 08             	mov    0x8(%ebp),%esi
  80109b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80109e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010a1:	85 c9                	test   %ecx,%ecx
  8010a3:	74 36                	je     8010db <memcmp+0x49>
		if (*s1 != *s2)
  8010a5:	0f b6 06             	movzbl (%esi),%eax
  8010a8:	0f b6 1f             	movzbl (%edi),%ebx
  8010ab:	38 d8                	cmp    %bl,%al
  8010ad:	74 20                	je     8010cf <memcmp+0x3d>
  8010af:	eb 14                	jmp    8010c5 <memcmp+0x33>
  8010b1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  8010b6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  8010bb:	83 c2 01             	add    $0x1,%edx
  8010be:	83 e9 01             	sub    $0x1,%ecx
  8010c1:	38 d8                	cmp    %bl,%al
  8010c3:	74 12                	je     8010d7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  8010c5:	0f b6 c0             	movzbl %al,%eax
  8010c8:	0f b6 db             	movzbl %bl,%ebx
  8010cb:	29 d8                	sub    %ebx,%eax
  8010cd:	eb 11                	jmp    8010e0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8010cf:	83 e9 01             	sub    $0x1,%ecx
  8010d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d7:	85 c9                	test   %ecx,%ecx
  8010d9:	75 d6                	jne    8010b1 <memcmp+0x1f>
  8010db:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8010eb:	89 c2                	mov    %eax,%edx
  8010ed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010f0:	39 d0                	cmp    %edx,%eax
  8010f2:	73 15                	jae    801109 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010f8:	38 08                	cmp    %cl,(%eax)
  8010fa:	75 06                	jne    801102 <memfind+0x1d>
  8010fc:	eb 0b                	jmp    801109 <memfind+0x24>
  8010fe:	38 08                	cmp    %cl,(%eax)
  801100:	74 07                	je     801109 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801102:	83 c0 01             	add    $0x1,%eax
  801105:	39 c2                	cmp    %eax,%edx
  801107:	77 f5                	ja     8010fe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
  801111:	83 ec 04             	sub    $0x4,%esp
  801114:	8b 55 08             	mov    0x8(%ebp),%edx
  801117:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80111a:	0f b6 02             	movzbl (%edx),%eax
  80111d:	3c 20                	cmp    $0x20,%al
  80111f:	74 04                	je     801125 <strtol+0x1a>
  801121:	3c 09                	cmp    $0x9,%al
  801123:	75 0e                	jne    801133 <strtol+0x28>
		s++;
  801125:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801128:	0f b6 02             	movzbl (%edx),%eax
  80112b:	3c 20                	cmp    $0x20,%al
  80112d:	74 f6                	je     801125 <strtol+0x1a>
  80112f:	3c 09                	cmp    $0x9,%al
  801131:	74 f2                	je     801125 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  801133:	3c 2b                	cmp    $0x2b,%al
  801135:	75 0c                	jne    801143 <strtol+0x38>
		s++;
  801137:	83 c2 01             	add    $0x1,%edx
  80113a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  801141:	eb 15                	jmp    801158 <strtol+0x4d>
	else if (*s == '-')
  801143:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  80114a:	3c 2d                	cmp    $0x2d,%al
  80114c:	75 0a                	jne    801158 <strtol+0x4d>
		s++, neg = 1;
  80114e:	83 c2 01             	add    $0x1,%edx
  801151:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801158:	85 db                	test   %ebx,%ebx
  80115a:	0f 94 c0             	sete   %al
  80115d:	74 05                	je     801164 <strtol+0x59>
  80115f:	83 fb 10             	cmp    $0x10,%ebx
  801162:	75 18                	jne    80117c <strtol+0x71>
  801164:	80 3a 30             	cmpb   $0x30,(%edx)
  801167:	75 13                	jne    80117c <strtol+0x71>
  801169:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80116d:	8d 76 00             	lea    0x0(%esi),%esi
  801170:	75 0a                	jne    80117c <strtol+0x71>
		s += 2, base = 16;
  801172:	83 c2 02             	add    $0x2,%edx
  801175:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80117a:	eb 15                	jmp    801191 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80117c:	84 c0                	test   %al,%al
  80117e:	66 90                	xchg   %ax,%ax
  801180:	74 0f                	je     801191 <strtol+0x86>
  801182:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801187:	80 3a 30             	cmpb   $0x30,(%edx)
  80118a:	75 05                	jne    801191 <strtol+0x86>
		s++, base = 8;
  80118c:	83 c2 01             	add    $0x1,%edx
  80118f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801191:	b8 00 00 00 00       	mov    $0x0,%eax
  801196:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801198:	0f b6 0a             	movzbl (%edx),%ecx
  80119b:	89 cf                	mov    %ecx,%edi
  80119d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  8011a0:	80 fb 09             	cmp    $0x9,%bl
  8011a3:	77 08                	ja     8011ad <strtol+0xa2>
			dig = *s - '0';
  8011a5:	0f be c9             	movsbl %cl,%ecx
  8011a8:	83 e9 30             	sub    $0x30,%ecx
  8011ab:	eb 1e                	jmp    8011cb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  8011ad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  8011b0:	80 fb 19             	cmp    $0x19,%bl
  8011b3:	77 08                	ja     8011bd <strtol+0xb2>
			dig = *s - 'a' + 10;
  8011b5:	0f be c9             	movsbl %cl,%ecx
  8011b8:	83 e9 57             	sub    $0x57,%ecx
  8011bb:	eb 0e                	jmp    8011cb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  8011bd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  8011c0:	80 fb 19             	cmp    $0x19,%bl
  8011c3:	77 15                	ja     8011da <strtol+0xcf>
			dig = *s - 'A' + 10;
  8011c5:	0f be c9             	movsbl %cl,%ecx
  8011c8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  8011cb:	39 f1                	cmp    %esi,%ecx
  8011cd:	7d 0b                	jge    8011da <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  8011cf:	83 c2 01             	add    $0x1,%edx
  8011d2:	0f af c6             	imul   %esi,%eax
  8011d5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  8011d8:	eb be                	jmp    801198 <strtol+0x8d>
  8011da:	89 c1                	mov    %eax,%ecx

	if (endptr)
  8011dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011e0:	74 05                	je     8011e7 <strtol+0xdc>
		*endptr = (char *) s;
  8011e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011e5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  8011e7:	89 ca                	mov    %ecx,%edx
  8011e9:	f7 da                	neg    %edx
  8011eb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  8011ef:	0f 45 c2             	cmovne %edx,%eax
}
  8011f2:	83 c4 04             	add    $0x4,%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    
	...

008011fc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8011fc:	55                   	push   %ebp
  8011fd:	89 e5                	mov    %esp,%ebp
  8011ff:	83 ec 48             	sub    $0x48,%esp
  801202:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801205:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801208:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80120b:	89 c6                	mov    %eax,%esi
  80120d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801210:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  801212:	8b 7d 10             	mov    0x10(%ebp),%edi
  801215:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801218:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80121b:	51                   	push   %ecx
  80121c:	52                   	push   %edx
  80121d:	53                   	push   %ebx
  80121e:	54                   	push   %esp
  80121f:	55                   	push   %ebp
  801220:	56                   	push   %esi
  801221:	57                   	push   %edi
  801222:	89 e5                	mov    %esp,%ebp
  801224:	8d 35 2c 12 80 00    	lea    0x80122c,%esi
  80122a:	0f 34                	sysenter 

0080122c <.after_sysenter_label>:
  80122c:	5f                   	pop    %edi
  80122d:	5e                   	pop    %esi
  80122e:	5d                   	pop    %ebp
  80122f:	5c                   	pop    %esp
  801230:	5b                   	pop    %ebx
  801231:	5a                   	pop    %edx
  801232:	59                   	pop    %ecx
  801233:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  801235:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801239:	74 28                	je     801263 <.after_sysenter_label+0x37>
  80123b:	85 c0                	test   %eax,%eax
  80123d:	7e 24                	jle    801263 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  80123f:	89 44 24 10          	mov    %eax,0x10(%esp)
  801243:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801247:	c7 44 24 08 60 2d 80 	movl   $0x802d60,0x8(%esp)
  80124e:	00 
  80124f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  801256:	00 
  801257:	c7 04 24 7d 2d 80 00 	movl   $0x802d7d,(%esp)
  80125e:	e8 ad f3 ff ff       	call   800610 <_panic>

	return ret;
}
  801263:	89 d0                	mov    %edx,%eax
  801265:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801268:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80126b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80126e:	89 ec                	mov    %ebp,%esp
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  801278:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80127f:	00 
  801280:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801287:	00 
  801288:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80128f:	00 
  801290:	8b 45 0c             	mov    0xc(%ebp),%eax
  801293:	89 04 24             	mov    %eax,(%esp)
  801296:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801299:	ba 00 00 00 00       	mov    $0x0,%edx
  80129e:	b8 10 00 00 00       	mov    $0x10,%eax
  8012a3:	e8 54 ff ff ff       	call   8011fc <syscall>
}
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    

008012aa <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  8012b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012b7:	00 
  8012b8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012bf:	00 
  8012c0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8012c7:	00 
  8012c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	b8 0f 00 00 00       	mov    $0xf,%eax
  8012de:	e8 19 ff ff ff       	call   8011fc <syscall>
}
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  8012e5:	55                   	push   %ebp
  8012e6:	89 e5                	mov    %esp,%ebp
  8012e8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8012eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8012f2:	00 
  8012f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012fa:	00 
  8012fb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801302:	00 
  801303:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80130a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130d:	ba 01 00 00 00       	mov    $0x1,%edx
  801312:	b8 0e 00 00 00       	mov    $0xe,%eax
  801317:	e8 e0 fe ff ff       	call   8011fc <syscall>
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801324:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80132b:	00 
  80132c:	8b 45 14             	mov    0x14(%ebp),%eax
  80132f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801333:	8b 45 10             	mov    0x10(%ebp),%eax
  801336:	89 44 24 04          	mov    %eax,0x4(%esp)
  80133a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133d:	89 04 24             	mov    %eax,(%esp)
  801340:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801343:	ba 00 00 00 00       	mov    $0x0,%edx
  801348:	b8 0d 00 00 00       	mov    $0xd,%eax
  80134d:	e8 aa fe ff ff       	call   8011fc <syscall>
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80135a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801361:	00 
  801362:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801369:	00 
  80136a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801371:	00 
  801372:	8b 45 0c             	mov    0xc(%ebp),%eax
  801375:	89 04 24             	mov    %eax,(%esp)
  801378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80137b:	ba 01 00 00 00       	mov    $0x1,%edx
  801380:	b8 0b 00 00 00       	mov    $0xb,%eax
  801385:	e8 72 fe ff ff       	call   8011fc <syscall>
}
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801392:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801399:	00 
  80139a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013a1:	00 
  8013a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013a9:	00 
  8013aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ad:	89 04 24             	mov    %eax,(%esp)
  8013b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013b3:	ba 01 00 00 00       	mov    $0x1,%edx
  8013b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8013bd:	e8 3a fe ff ff       	call   8011fc <syscall>
}
  8013c2:	c9                   	leave  
  8013c3:	c3                   	ret    

008013c4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8013ca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8013d1:	00 
  8013d2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8013d9:	00 
  8013da:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013e1:	00 
  8013e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e5:	89 04 24             	mov    %eax,(%esp)
  8013e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013eb:	ba 01 00 00 00       	mov    $0x1,%edx
  8013f0:	b8 09 00 00 00       	mov    $0x9,%eax
  8013f5:	e8 02 fe ff ff       	call   8011fc <syscall>
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    

008013fc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  8013fc:	55                   	push   %ebp
  8013fd:	89 e5                	mov    %esp,%ebp
  8013ff:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801402:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801409:	00 
  80140a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801411:	00 
  801412:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801419:	00 
  80141a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80141d:	89 04 24             	mov    %eax,(%esp)
  801420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801423:	ba 01 00 00 00       	mov    $0x1,%edx
  801428:	b8 07 00 00 00       	mov    $0x7,%eax
  80142d:	e8 ca fd ff ff       	call   8011fc <syscall>
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    

00801434 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  80143a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801441:	00 
  801442:	8b 45 18             	mov    0x18(%ebp),%eax
  801445:	0b 45 14             	or     0x14(%ebp),%eax
  801448:	89 44 24 08          	mov    %eax,0x8(%esp)
  80144c:	8b 45 10             	mov    0x10(%ebp),%eax
  80144f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801453:	8b 45 0c             	mov    0xc(%ebp),%eax
  801456:	89 04 24             	mov    %eax,(%esp)
  801459:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80145c:	ba 01 00 00 00       	mov    $0x1,%edx
  801461:	b8 06 00 00 00       	mov    $0x6,%eax
  801466:	e8 91 fd ff ff       	call   8011fc <syscall>
}
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801473:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80147a:	00 
  80147b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801482:	00 
  801483:	8b 45 10             	mov    0x10(%ebp),%eax
  801486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148d:	89 04 24             	mov    %eax,(%esp)
  801490:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801493:	ba 01 00 00 00       	mov    $0x1,%edx
  801498:	b8 05 00 00 00       	mov    $0x5,%eax
  80149d:	e8 5a fd ff ff       	call   8011fc <syscall>
}
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8014aa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014b1:	00 
  8014b2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014b9:	00 
  8014ba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014c1:	00 
  8014c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8014d8:	e8 1f fd ff ff       	call   8011fc <syscall>
}
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  8014e5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8014ec:	00 
  8014ed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8014f4:	00 
  8014f5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014fc:	00 
  8014fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801500:	89 04 24             	mov    %eax,(%esp)
  801503:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801506:	ba 00 00 00 00       	mov    $0x0,%edx
  80150b:	b8 04 00 00 00       	mov    $0x4,%eax
  801510:	e8 e7 fc ff ff       	call   8011fc <syscall>
}
  801515:	c9                   	leave  
  801516:	c3                   	ret    

00801517 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801517:	55                   	push   %ebp
  801518:	89 e5                	mov    %esp,%ebp
  80151a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80151d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801524:	00 
  801525:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80152c:	00 
  80152d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801534:	00 
  801535:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80153c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 02 00 00 00       	mov    $0x2,%eax
  80154b:	e8 ac fc ff ff       	call   8011fc <syscall>
}
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801558:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80155f:	00 
  801560:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801567:	00 
  801568:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80156f:	00 
  801570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801577:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80157a:	ba 01 00 00 00       	mov    $0x1,%edx
  80157f:	b8 03 00 00 00       	mov    $0x3,%eax
  801584:	e8 73 fc ff ff       	call   8011fc <syscall>
}
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801591:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801598:	00 
  801599:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a0:	00 
  8015a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015a8:	00 
  8015a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bf:	e8 38 fc ff ff       	call   8011fc <syscall>
}
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    

008015c6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8015c6:	55                   	push   %ebp
  8015c7:	89 e5                	mov    %esp,%ebp
  8015c9:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8015cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8015d3:	00 
  8015d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015db:	00 
  8015dc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015e3:	00 
  8015e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015e7:	89 04 24             	mov    %eax,(%esp)
  8015ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8015f7:	e8 00 fc ff ff       	call   8011fc <syscall>
}
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    
	...

00801600 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801606:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  80160d:	75 54                	jne    801663 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80160f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801616:	00 
  801617:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80161e:	ee 
  80161f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801626:	e8 42 fe ff ff       	call   80146d <sys_page_alloc>
  80162b:	85 c0                	test   %eax,%eax
  80162d:	79 20                	jns    80164f <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80162f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801633:	c7 44 24 08 8b 2d 80 	movl   $0x802d8b,0x8(%esp)
  80163a:	00 
  80163b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801642:	00 
  801643:	c7 04 24 a3 2d 80 00 	movl   $0x802da3,(%esp)
  80164a:	e8 c1 ef ff ff       	call   800610 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80164f:	c7 44 24 04 70 16 80 	movl   $0x801670,0x4(%esp)
  801656:	00 
  801657:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80165e:	e8 f1 fc ff ff       	call   801354 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801663:	8b 45 08             	mov    0x8(%ebp),%eax
  801666:	a3 b8 40 80 00       	mov    %eax,0x8040b8
}
  80166b:	c9                   	leave  
  80166c:	c3                   	ret    
  80166d:	00 00                	add    %al,(%eax)
	...

00801670 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801670:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801671:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  801676:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801678:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  80167b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80167f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801682:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  801686:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80168a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  80168c:	83 c4 08             	add    $0x8,%esp
	popal
  80168f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  801690:	83 c4 04             	add    $0x4,%esp
	popfl
  801693:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801694:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801695:	c3                   	ret    
	...

008016a0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016ab:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b9:	89 04 24             	mov    %eax,(%esp)
  8016bc:	e8 df ff ff ff       	call   8016a0 <fd2num>
  8016c1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8016c6:	c1 e0 0c             	shl    $0xc,%eax
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	57                   	push   %edi
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8016d4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8016d9:	a8 01                	test   $0x1,%al
  8016db:	74 36                	je     801713 <fd_alloc+0x48>
  8016dd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8016e2:	a8 01                	test   $0x1,%al
  8016e4:	74 2d                	je     801713 <fd_alloc+0x48>
  8016e6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8016eb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8016f0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	89 c2                	mov    %eax,%edx
  8016f9:	c1 ea 16             	shr    $0x16,%edx
  8016fc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8016ff:	f6 c2 01             	test   $0x1,%dl
  801702:	74 14                	je     801718 <fd_alloc+0x4d>
  801704:	89 c2                	mov    %eax,%edx
  801706:	c1 ea 0c             	shr    $0xc,%edx
  801709:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80170c:	f6 c2 01             	test   $0x1,%dl
  80170f:	75 10                	jne    801721 <fd_alloc+0x56>
  801711:	eb 05                	jmp    801718 <fd_alloc+0x4d>
  801713:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801718:	89 1f                	mov    %ebx,(%edi)
  80171a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80171f:	eb 17                	jmp    801738 <fd_alloc+0x6d>
  801721:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801726:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80172b:	75 c8                	jne    8016f5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80172d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801733:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801738:	5b                   	pop    %ebx
  801739:	5e                   	pop    %esi
  80173a:	5f                   	pop    %edi
  80173b:	5d                   	pop    %ebp
  80173c:	c3                   	ret    

0080173d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80173d:	55                   	push   %ebp
  80173e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801740:	8b 45 08             	mov    0x8(%ebp),%eax
  801743:	83 f8 1f             	cmp    $0x1f,%eax
  801746:	77 36                	ja     80177e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801748:	05 00 00 0d 00       	add    $0xd0000,%eax
  80174d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801750:	89 c2                	mov    %eax,%edx
  801752:	c1 ea 16             	shr    $0x16,%edx
  801755:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80175c:	f6 c2 01             	test   $0x1,%dl
  80175f:	74 1d                	je     80177e <fd_lookup+0x41>
  801761:	89 c2                	mov    %eax,%edx
  801763:	c1 ea 0c             	shr    $0xc,%edx
  801766:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80176d:	f6 c2 01             	test   $0x1,%dl
  801770:	74 0c                	je     80177e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801772:	8b 55 0c             	mov    0xc(%ebp),%edx
  801775:	89 02                	mov    %eax,(%edx)
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80177c:	eb 05                	jmp    801783 <fd_lookup+0x46>
  80177e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80178b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80178e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801792:	8b 45 08             	mov    0x8(%ebp),%eax
  801795:	89 04 24             	mov    %eax,(%esp)
  801798:	e8 a0 ff ff ff       	call   80173d <fd_lookup>
  80179d:	85 c0                	test   %eax,%eax
  80179f:	78 0e                	js     8017af <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a7:	89 50 04             	mov    %edx,0x4(%eax)
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	56                   	push   %esi
  8017b5:	53                   	push   %ebx
  8017b6:	83 ec 10             	sub    $0x10,%esp
  8017b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8017c4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8017c9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8017cf:	75 11                	jne    8017e2 <dev_lookup+0x31>
  8017d1:	eb 04                	jmp    8017d7 <dev_lookup+0x26>
  8017d3:	39 08                	cmp    %ecx,(%eax)
  8017d5:	75 10                	jne    8017e7 <dev_lookup+0x36>
			*dev = devtab[i];
  8017d7:	89 03                	mov    %eax,(%ebx)
  8017d9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8017de:	66 90                	xchg   %ax,%ax
  8017e0:	eb 36                	jmp    801818 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8017e2:	be 34 2e 80 00       	mov    $0x802e34,%esi
  8017e7:	83 c2 01             	add    $0x1,%edx
  8017ea:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	75 e2                	jne    8017d3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8017f1:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8017f6:	8b 40 48             	mov    0x48(%eax),%eax
  8017f9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801801:	c7 04 24 b4 2d 80 00 	movl   $0x802db4,(%esp)
  801808:	e8 bc ee ff ff       	call   8006c9 <cprintf>
	*dev = 0;
  80180d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801813:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5e                   	pop    %esi
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	53                   	push   %ebx
  801823:	83 ec 24             	sub    $0x24,%esp
  801826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801829:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	89 04 24             	mov    %eax,(%esp)
  801836:	e8 02 ff ff ff       	call   80173d <fd_lookup>
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 53                	js     801892 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80183f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801849:	8b 00                	mov    (%eax),%eax
  80184b:	89 04 24             	mov    %eax,(%esp)
  80184e:	e8 5e ff ff ff       	call   8017b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801853:	85 c0                	test   %eax,%eax
  801855:	78 3b                	js     801892 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801857:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80185c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801863:	74 2d                	je     801892 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801865:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801868:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80186f:	00 00 00 
	stat->st_isdir = 0;
  801872:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801879:	00 00 00 
	stat->st_dev = dev;
  80187c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801885:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801889:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80188c:	89 14 24             	mov    %edx,(%esp)
  80188f:	ff 50 14             	call   *0x14(%eax)
}
  801892:	83 c4 24             	add    $0x24,%esp
  801895:	5b                   	pop    %ebx
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 24             	sub    $0x24,%esp
  80189f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018a9:	89 1c 24             	mov    %ebx,(%esp)
  8018ac:	e8 8c fe ff ff       	call   80173d <fd_lookup>
  8018b1:	85 c0                	test   %eax,%eax
  8018b3:	78 5f                	js     801914 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bf:	8b 00                	mov    (%eax),%eax
  8018c1:	89 04 24             	mov    %eax,(%esp)
  8018c4:	e8 e8 fe ff ff       	call   8017b1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	78 47                	js     801914 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018d0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8018d4:	75 23                	jne    8018f9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8018d6:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018db:	8b 40 48             	mov    0x48(%eax),%eax
  8018de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e6:	c7 04 24 d4 2d 80 00 	movl   $0x802dd4,(%esp)
  8018ed:	e8 d7 ed ff ff       	call   8006c9 <cprintf>
  8018f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018f7:	eb 1b                	jmp    801914 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8018f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fc:	8b 48 18             	mov    0x18(%eax),%ecx
  8018ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801904:	85 c9                	test   %ecx,%ecx
  801906:	74 0c                	je     801914 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801908:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190f:	89 14 24             	mov    %edx,(%esp)
  801912:	ff d1                	call   *%ecx
}
  801914:	83 c4 24             	add    $0x24,%esp
  801917:	5b                   	pop    %ebx
  801918:	5d                   	pop    %ebp
  801919:	c3                   	ret    

0080191a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	53                   	push   %ebx
  80191e:	83 ec 24             	sub    $0x24,%esp
  801921:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801924:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801927:	89 44 24 04          	mov    %eax,0x4(%esp)
  80192b:	89 1c 24             	mov    %ebx,(%esp)
  80192e:	e8 0a fe ff ff       	call   80173d <fd_lookup>
  801933:	85 c0                	test   %eax,%eax
  801935:	78 66                	js     80199d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801937:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801941:	8b 00                	mov    (%eax),%eax
  801943:	89 04 24             	mov    %eax,(%esp)
  801946:	e8 66 fe ff ff       	call   8017b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 4e                	js     80199d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80194f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801952:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801956:	75 23                	jne    80197b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801958:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80195d:	8b 40 48             	mov    0x48(%eax),%eax
  801960:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801964:	89 44 24 04          	mov    %eax,0x4(%esp)
  801968:	c7 04 24 f8 2d 80 00 	movl   $0x802df8,(%esp)
  80196f:	e8 55 ed ff ff       	call   8006c9 <cprintf>
  801974:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801979:	eb 22                	jmp    80199d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80197e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801981:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801986:	85 c9                	test   %ecx,%ecx
  801988:	74 13                	je     80199d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80198a:	8b 45 10             	mov    0x10(%ebp),%eax
  80198d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801991:	8b 45 0c             	mov    0xc(%ebp),%eax
  801994:	89 44 24 04          	mov    %eax,0x4(%esp)
  801998:	89 14 24             	mov    %edx,(%esp)
  80199b:	ff d1                	call   *%ecx
}
  80199d:	83 c4 24             	add    $0x24,%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	53                   	push   %ebx
  8019a7:	83 ec 24             	sub    $0x24,%esp
  8019aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019b4:	89 1c 24             	mov    %ebx,(%esp)
  8019b7:	e8 81 fd ff ff       	call   80173d <fd_lookup>
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 6b                	js     801a2b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ca:	8b 00                	mov    (%eax),%eax
  8019cc:	89 04 24             	mov    %eax,(%esp)
  8019cf:	e8 dd fd ff ff       	call   8017b1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 53                	js     801a2b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019db:	8b 42 08             	mov    0x8(%edx),%eax
  8019de:	83 e0 03             	and    $0x3,%eax
  8019e1:	83 f8 01             	cmp    $0x1,%eax
  8019e4:	75 23                	jne    801a09 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019e6:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8019eb:	8b 40 48             	mov    0x48(%eax),%eax
  8019ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f6:	c7 04 24 15 2e 80 00 	movl   $0x802e15,(%esp)
  8019fd:	e8 c7 ec ff ff       	call   8006c9 <cprintf>
  801a02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a07:	eb 22                	jmp    801a2b <read+0x88>
	}
	if (!dev->dev_read)
  801a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0c:	8b 48 08             	mov    0x8(%eax),%ecx
  801a0f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a14:	85 c9                	test   %ecx,%ecx
  801a16:	74 13                	je     801a2b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a18:	8b 45 10             	mov    0x10(%ebp),%eax
  801a1b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a22:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a26:	89 14 24             	mov    %edx,(%esp)
  801a29:	ff d1                	call   *%ecx
}
  801a2b:	83 c4 24             	add    $0x24,%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	57                   	push   %edi
  801a35:	56                   	push   %esi
  801a36:	53                   	push   %ebx
  801a37:	83 ec 1c             	sub    $0x1c,%esp
  801a3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a3d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a40:	ba 00 00 00 00       	mov    $0x0,%edx
  801a45:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4f:	85 f6                	test   %esi,%esi
  801a51:	74 29                	je     801a7c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a53:	89 f0                	mov    %esi,%eax
  801a55:	29 d0                	sub    %edx,%eax
  801a57:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5b:	03 55 0c             	add    0xc(%ebp),%edx
  801a5e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a62:	89 3c 24             	mov    %edi,(%esp)
  801a65:	e8 39 ff ff ff       	call   8019a3 <read>
		if (m < 0)
  801a6a:	85 c0                	test   %eax,%eax
  801a6c:	78 0e                	js     801a7c <readn+0x4b>
			return m;
		if (m == 0)
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	74 08                	je     801a7a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a72:	01 c3                	add    %eax,%ebx
  801a74:	89 da                	mov    %ebx,%edx
  801a76:	39 f3                	cmp    %esi,%ebx
  801a78:	72 d9                	jb     801a53 <readn+0x22>
  801a7a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801a7c:	83 c4 1c             	add    $0x1c,%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5f                   	pop    %edi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 28             	sub    $0x28,%esp
  801a8a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a8d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a90:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801a93:	89 34 24             	mov    %esi,(%esp)
  801a96:	e8 05 fc ff ff       	call   8016a0 <fd2num>
  801a9b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aa2:	89 04 24             	mov    %eax,(%esp)
  801aa5:	e8 93 fc ff ff       	call   80173d <fd_lookup>
  801aaa:	89 c3                	mov    %eax,%ebx
  801aac:	85 c0                	test   %eax,%eax
  801aae:	78 05                	js     801ab5 <fd_close+0x31>
  801ab0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801ab3:	74 0e                	je     801ac3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  801abe:	0f 44 d8             	cmove  %eax,%ebx
  801ac1:	eb 3d                	jmp    801b00 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801ac3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aca:	8b 06                	mov    (%esi),%eax
  801acc:	89 04 24             	mov    %eax,(%esp)
  801acf:	e8 dd fc ff ff       	call   8017b1 <dev_lookup>
  801ad4:	89 c3                	mov    %eax,%ebx
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 16                	js     801af0 <fd_close+0x6c>
		if (dev->dev_close)
  801ada:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801add:	8b 40 10             	mov    0x10(%eax),%eax
  801ae0:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	74 07                	je     801af0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801ae9:	89 34 24             	mov    %esi,(%esp)
  801aec:	ff d0                	call   *%eax
  801aee:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801af0:	89 74 24 04          	mov    %esi,0x4(%esp)
  801af4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801afb:	e8 fc f8 ff ff       	call   8013fc <sys_page_unmap>
	return r;
}
  801b00:	89 d8                	mov    %ebx,%eax
  801b02:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b05:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b08:	89 ec                	mov    %ebp,%esp
  801b0a:	5d                   	pop    %ebp
  801b0b:	c3                   	ret    

00801b0c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	89 04 24             	mov    %eax,(%esp)
  801b1f:	e8 19 fc ff ff       	call   80173d <fd_lookup>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 13                	js     801b3b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b28:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b2f:	00 
  801b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 49 ff ff ff       	call   801a84 <fd_close>
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    

00801b3d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	83 ec 18             	sub    $0x18,%esp
  801b43:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b46:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b49:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b50:	00 
  801b51:	8b 45 08             	mov    0x8(%ebp),%eax
  801b54:	89 04 24             	mov    %eax,(%esp)
  801b57:	e8 78 03 00 00       	call   801ed4 <open>
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	78 1b                	js     801b7d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b65:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b69:	89 1c 24             	mov    %ebx,(%esp)
  801b6c:	e8 ae fc ff ff       	call   80181f <fstat>
  801b71:	89 c6                	mov    %eax,%esi
	close(fd);
  801b73:	89 1c 24             	mov    %ebx,(%esp)
  801b76:	e8 91 ff ff ff       	call   801b0c <close>
  801b7b:	89 f3                	mov    %esi,%ebx
	return r;
}
  801b7d:	89 d8                	mov    %ebx,%eax
  801b7f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b82:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b85:	89 ec                	mov    %ebp,%esp
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 14             	sub    $0x14,%esp
  801b90:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801b95:	89 1c 24             	mov    %ebx,(%esp)
  801b98:	e8 6f ff ff ff       	call   801b0c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801b9d:	83 c3 01             	add    $0x1,%ebx
  801ba0:	83 fb 20             	cmp    $0x20,%ebx
  801ba3:	75 f0                	jne    801b95 <close_all+0xc>
		close(i);
}
  801ba5:	83 c4 14             	add    $0x14,%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 58             	sub    $0x58,%esp
  801bb1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bb4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bb7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801bba:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bbd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	89 04 24             	mov    %eax,(%esp)
  801bca:	e8 6e fb ff ff       	call   80173d <fd_lookup>
  801bcf:	89 c3                	mov    %eax,%ebx
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 e0 00 00 00    	js     801cb9 <dup+0x10e>
		return r;
	close(newfdnum);
  801bd9:	89 3c 24             	mov    %edi,(%esp)
  801bdc:	e8 2b ff ff ff       	call   801b0c <close>

	newfd = INDEX2FD(newfdnum);
  801be1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801be7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801bea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801bed:	89 04 24             	mov    %eax,(%esp)
  801bf0:	e8 bb fa ff ff       	call   8016b0 <fd2data>
  801bf5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801bf7:	89 34 24             	mov    %esi,(%esp)
  801bfa:	e8 b1 fa ff ff       	call   8016b0 <fd2data>
  801bff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801c02:	89 da                	mov    %ebx,%edx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	c1 e8 16             	shr    $0x16,%eax
  801c09:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c10:	a8 01                	test   $0x1,%al
  801c12:	74 43                	je     801c57 <dup+0xac>
  801c14:	c1 ea 0c             	shr    $0xc,%edx
  801c17:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c1e:	a8 01                	test   $0x1,%al
  801c20:	74 35                	je     801c57 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c22:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c29:	25 07 0e 00 00       	and    $0xe07,%eax
  801c2e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c35:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c40:	00 
  801c41:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c45:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c4c:	e8 e3 f7 ff ff       	call   801434 <sys_page_map>
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 3f                	js     801c96 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c5a:	89 c2                	mov    %eax,%edx
  801c5c:	c1 ea 0c             	shr    $0xc,%edx
  801c5f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c66:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801c6c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801c70:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801c74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c7b:	00 
  801c7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c87:	e8 a8 f7 ff ff       	call   801434 <sys_page_map>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 04                	js     801c96 <dup+0xeb>
  801c92:	89 fb                	mov    %edi,%ebx
  801c94:	eb 23                	jmp    801cb9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801c96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ca1:	e8 56 f7 ff ff       	call   8013fc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ca6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb4:	e8 43 f7 ff ff       	call   8013fc <sys_page_unmap>
	return r;
}
  801cb9:	89 d8                	mov    %ebx,%eax
  801cbb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cbe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801cc1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801cc4:	89 ec                	mov    %ebp,%esp
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    

00801cc8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 18             	sub    $0x18,%esp
  801cce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cd1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801cd4:	89 c3                	mov    %eax,%ebx
  801cd6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801cd8:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  801cdf:	75 11                	jne    801cf2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801ce1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801ce8:	e8 b3 07 00 00       	call   8024a0 <ipc_find_env>
  801ced:	a3 ac 40 80 00       	mov    %eax,0x8040ac
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801cf2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801cf9:	00 
  801cfa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801d01:	00 
  801d02:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d06:	a1 ac 40 80 00       	mov    0x8040ac,%eax
  801d0b:	89 04 24             	mov    %eax,(%esp)
  801d0e:	e8 d1 07 00 00       	call   8024e4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d13:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d1a:	00 
  801d1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d26:	e8 24 08 00 00       	call   80254f <ipc_recv>
}
  801d2b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d2e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d31:	89 ec                	mov    %ebp,%esp
  801d33:	5d                   	pop    %ebp
  801d34:	c3                   	ret    

00801d35 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d3e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d49:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d53:	b8 02 00 00 00       	mov    $0x2,%eax
  801d58:	e8 6b ff ff ff       	call   801cc8 <fsipc>
}
  801d5d:	c9                   	leave  
  801d5e:	c3                   	ret    

00801d5f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801d65:	8b 45 08             	mov    0x8(%ebp),%eax
  801d68:	8b 40 0c             	mov    0xc(%eax),%eax
  801d6b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801d70:	ba 00 00 00 00       	mov    $0x0,%edx
  801d75:	b8 06 00 00 00       	mov    $0x6,%eax
  801d7a:	e8 49 ff ff ff       	call   801cc8 <fsipc>
}
  801d7f:	c9                   	leave  
  801d80:	c3                   	ret    

00801d81 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801d87:	ba 00 00 00 00       	mov    $0x0,%edx
  801d8c:	b8 08 00 00 00       	mov    $0x8,%eax
  801d91:	e8 32 ff ff ff       	call   801cc8 <fsipc>
}
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	53                   	push   %ebx
  801d9c:	83 ec 14             	sub    $0x14,%esp
  801d9f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	8b 40 0c             	mov    0xc(%eax),%eax
  801da8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801dad:	ba 00 00 00 00       	mov    $0x0,%edx
  801db2:	b8 05 00 00 00       	mov    $0x5,%eax
  801db7:	e8 0c ff ff ff       	call   801cc8 <fsipc>
  801dbc:	85 c0                	test   %eax,%eax
  801dbe:	78 2b                	js     801deb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801dc0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801dc7:	00 
  801dc8:	89 1c 24             	mov    %ebx,(%esp)
  801dcb:	e8 3a f0 ff ff       	call   800e0a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801dd0:	a1 80 50 80 00       	mov    0x805080,%eax
  801dd5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ddb:	a1 84 50 80 00       	mov    0x805084,%eax
  801de0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801de6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801deb:	83 c4 14             	add    $0x14,%esp
  801dee:	5b                   	pop    %ebx
  801def:	5d                   	pop    %ebp
  801df0:	c3                   	ret    

00801df1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801df1:	55                   	push   %ebp
  801df2:	89 e5                	mov    %esp,%ebp
  801df4:	83 ec 18             	sub    $0x18,%esp
  801df7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  801dfd:	8b 52 0c             	mov    0xc(%edx),%edx
  801e00:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801e06:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801e0b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e10:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e15:	0f 47 c2             	cmova  %edx,%eax
  801e18:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e23:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801e2a:	e8 c6 f1 ff ff       	call   800ff5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e34:	b8 04 00 00 00       	mov    $0x4,%eax
  801e39:	e8 8a fe ff ff       	call   801cc8 <fsipc>
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	53                   	push   %ebx
  801e44:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e4d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801e52:	8b 45 10             	mov    0x10(%ebp),%eax
  801e55:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e5f:	b8 03 00 00 00       	mov    $0x3,%eax
  801e64:	e8 5f fe ff ff       	call   801cc8 <fsipc>
  801e69:	89 c3                	mov    %eax,%ebx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	78 17                	js     801e86 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801e6f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e73:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801e7a:	00 
  801e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e7e:	89 04 24             	mov    %eax,(%esp)
  801e81:	e8 6f f1 ff ff       	call   800ff5 <memmove>
  return r;	
}
  801e86:	89 d8                	mov    %ebx,%eax
  801e88:	83 c4 14             	add    $0x14,%esp
  801e8b:	5b                   	pop    %ebx
  801e8c:	5d                   	pop    %ebp
  801e8d:	c3                   	ret    

00801e8e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	53                   	push   %ebx
  801e92:	83 ec 14             	sub    $0x14,%esp
  801e95:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801e98:	89 1c 24             	mov    %ebx,(%esp)
  801e9b:	e8 20 ef ff ff       	call   800dc0 <strlen>
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801ea7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ead:	7f 1f                	jg     801ece <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801eaf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801eb3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801eba:	e8 4b ef ff ff       	call   800e0a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801ebf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ec4:	b8 07 00 00 00       	mov    $0x7,%eax
  801ec9:	e8 fa fd ff ff       	call   801cc8 <fsipc>
}
  801ece:	83 c4 14             	add    $0x14,%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 28             	sub    $0x28,%esp
  801eda:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801edd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ee0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801ee3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ee6:	89 04 24             	mov    %eax,(%esp)
  801ee9:	e8 dd f7 ff ff       	call   8016cb <fd_alloc>
  801eee:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801ef0:	85 c0                	test   %eax,%eax
  801ef2:	0f 88 89 00 00 00    	js     801f81 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801ef8:	89 34 24             	mov    %esi,(%esp)
  801efb:	e8 c0 ee ff ff       	call   800dc0 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801f00:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801f05:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f0a:	7f 75                	jg     801f81 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801f0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f10:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801f17:	e8 ee ee ff ff       	call   800e0a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801f1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801f24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f27:	b8 01 00 00 00       	mov    $0x1,%eax
  801f2c:	e8 97 fd ff ff       	call   801cc8 <fsipc>
  801f31:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 0f                	js     801f46 <open+0x72>
  return fd2num(fd);
  801f37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3a:	89 04 24             	mov    %eax,(%esp)
  801f3d:	e8 5e f7 ff ff       	call   8016a0 <fd2num>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	eb 3b                	jmp    801f81 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801f46:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f4d:	00 
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	89 04 24             	mov    %eax,(%esp)
  801f54:	e8 2b fb ff ff       	call   801a84 <fd_close>
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	74 24                	je     801f81 <open+0xad>
  801f5d:	c7 44 24 0c 40 2e 80 	movl   $0x802e40,0xc(%esp)
  801f64:	00 
  801f65:	c7 44 24 08 55 2e 80 	movl   $0x802e55,0x8(%esp)
  801f6c:	00 
  801f6d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801f74:	00 
  801f75:	c7 04 24 6a 2e 80 00 	movl   $0x802e6a,(%esp)
  801f7c:	e8 8f e6 ff ff       	call   800610 <_panic>
  return r;
}
  801f81:	89 d8                	mov    %ebx,%eax
  801f83:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f86:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f89:	89 ec                	mov    %ebp,%esp
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    
  801f8d:	00 00                	add    %al,(%eax)
	...

00801f90 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801f96:	c7 44 24 04 75 2e 80 	movl   $0x802e75,0x4(%esp)
  801f9d:	00 
  801f9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa1:	89 04 24             	mov    %eax,(%esp)
  801fa4:	e8 61 ee ff ff       	call   800e0a <strcpy>
	return 0;
}
  801fa9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fae:	c9                   	leave  
  801faf:	c3                   	ret    

00801fb0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 14             	sub    $0x14,%esp
  801fb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801fba:	89 1c 24             	mov    %ebx,(%esp)
  801fbd:	e8 1a 06 00 00       	call   8025dc <pageref>
  801fc2:	89 c2                	mov    %eax,%edx
  801fc4:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc9:	83 fa 01             	cmp    $0x1,%edx
  801fcc:	75 0b                	jne    801fd9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801fce:	8b 43 0c             	mov    0xc(%ebx),%eax
  801fd1:	89 04 24             	mov    %eax,(%esp)
  801fd4:	e8 b9 02 00 00       	call   802292 <nsipc_close>
	else
		return 0;
}
  801fd9:	83 c4 14             	add    $0x14,%esp
  801fdc:	5b                   	pop    %ebx
  801fdd:	5d                   	pop    %ebp
  801fde:	c3                   	ret    

00801fdf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801fdf:	55                   	push   %ebp
  801fe0:	89 e5                	mov    %esp,%ebp
  801fe2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801fe5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801fec:	00 
  801fed:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff0:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffe:	8b 40 0c             	mov    0xc(%eax),%eax
  802001:	89 04 24             	mov    %eax,(%esp)
  802004:	e8 c5 02 00 00       	call   8022ce <nsipc_send>
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    

0080200b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802011:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802018:	00 
  802019:	8b 45 10             	mov    0x10(%ebp),%eax
  80201c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802020:	8b 45 0c             	mov    0xc(%ebp),%eax
  802023:	89 44 24 04          	mov    %eax,0x4(%esp)
  802027:	8b 45 08             	mov    0x8(%ebp),%eax
  80202a:	8b 40 0c             	mov    0xc(%eax),%eax
  80202d:	89 04 24             	mov    %eax,(%esp)
  802030:	e8 0c 03 00 00       	call   802341 <nsipc_recv>
}
  802035:	c9                   	leave  
  802036:	c3                   	ret    

00802037 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802037:	55                   	push   %ebp
  802038:	89 e5                	mov    %esp,%ebp
  80203a:	56                   	push   %esi
  80203b:	53                   	push   %ebx
  80203c:	83 ec 20             	sub    $0x20,%esp
  80203f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802041:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802044:	89 04 24             	mov    %eax,(%esp)
  802047:	e8 7f f6 ff ff       	call   8016cb <fd_alloc>
  80204c:	89 c3                	mov    %eax,%ebx
  80204e:	85 c0                	test   %eax,%eax
  802050:	78 21                	js     802073 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802052:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802059:	00 
  80205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80205d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802061:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802068:	e8 00 f4 ff ff       	call   80146d <sys_page_alloc>
  80206d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  80206f:	85 c0                	test   %eax,%eax
  802071:	79 0a                	jns    80207d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  802073:	89 34 24             	mov    %esi,(%esp)
  802076:	e8 17 02 00 00       	call   802292 <nsipc_close>
		return r;
  80207b:	eb 28                	jmp    8020a5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80207d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  802083:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802086:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  802088:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80208b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  802092:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802095:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  802098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209b:	89 04 24             	mov    %eax,(%esp)
  80209e:	e8 fd f5 ff ff       	call   8016a0 <fd2num>
  8020a3:	89 c3                	mov    %eax,%ebx
}
  8020a5:	89 d8                	mov    %ebx,%eax
  8020a7:	83 c4 20             	add    $0x20,%esp
  8020aa:	5b                   	pop    %ebx
  8020ab:	5e                   	pop    %esi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020b4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020be:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c5:	89 04 24             	mov    %eax,(%esp)
  8020c8:	e8 79 01 00 00       	call   802246 <nsipc_socket>
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	78 05                	js     8020d6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  8020d1:	e8 61 ff ff ff       	call   802037 <alloc_sockfd>
}
  8020d6:	c9                   	leave  
  8020d7:	c3                   	ret    

008020d8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8020d8:	55                   	push   %ebp
  8020d9:	89 e5                	mov    %esp,%ebp
  8020db:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8020de:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8020e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e5:	89 04 24             	mov    %eax,(%esp)
  8020e8:	e8 50 f6 ff ff       	call   80173d <fd_lookup>
  8020ed:	85 c0                	test   %eax,%eax
  8020ef:	78 15                	js     802106 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8020f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020f4:	8b 0a                	mov    (%edx),%ecx
  8020f6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8020fb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  802101:	75 03                	jne    802106 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802103:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802106:	c9                   	leave  
  802107:	c3                   	ret    

00802108 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802108:	55                   	push   %ebp
  802109:	89 e5                	mov    %esp,%ebp
  80210b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80210e:	8b 45 08             	mov    0x8(%ebp),%eax
  802111:	e8 c2 ff ff ff       	call   8020d8 <fd2sockid>
  802116:	85 c0                	test   %eax,%eax
  802118:	78 0f                	js     802129 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80211a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80211d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802121:	89 04 24             	mov    %eax,(%esp)
  802124:	e8 47 01 00 00       	call   802270 <nsipc_listen>
}
  802129:	c9                   	leave  
  80212a:	c3                   	ret    

0080212b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80212b:	55                   	push   %ebp
  80212c:	89 e5                	mov    %esp,%ebp
  80212e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802131:	8b 45 08             	mov    0x8(%ebp),%eax
  802134:	e8 9f ff ff ff       	call   8020d8 <fd2sockid>
  802139:	85 c0                	test   %eax,%eax
  80213b:	78 16                	js     802153 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80213d:	8b 55 10             	mov    0x10(%ebp),%edx
  802140:	89 54 24 08          	mov    %edx,0x8(%esp)
  802144:	8b 55 0c             	mov    0xc(%ebp),%edx
  802147:	89 54 24 04          	mov    %edx,0x4(%esp)
  80214b:	89 04 24             	mov    %eax,(%esp)
  80214e:	e8 6e 02 00 00       	call   8023c1 <nsipc_connect>
}
  802153:	c9                   	leave  
  802154:	c3                   	ret    

00802155 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80215b:	8b 45 08             	mov    0x8(%ebp),%eax
  80215e:	e8 75 ff ff ff       	call   8020d8 <fd2sockid>
  802163:	85 c0                	test   %eax,%eax
  802165:	78 0f                	js     802176 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  802167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80216a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80216e:	89 04 24             	mov    %eax,(%esp)
  802171:	e8 36 01 00 00       	call   8022ac <nsipc_shutdown>
}
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80217e:	8b 45 08             	mov    0x8(%ebp),%eax
  802181:	e8 52 ff ff ff       	call   8020d8 <fd2sockid>
  802186:	85 c0                	test   %eax,%eax
  802188:	78 16                	js     8021a0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  80218a:	8b 55 10             	mov    0x10(%ebp),%edx
  80218d:	89 54 24 08          	mov    %edx,0x8(%esp)
  802191:	8b 55 0c             	mov    0xc(%ebp),%edx
  802194:	89 54 24 04          	mov    %edx,0x4(%esp)
  802198:	89 04 24             	mov    %eax,(%esp)
  80219b:	e8 60 02 00 00       	call   802400 <nsipc_bind>
}
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    

008021a2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ab:	e8 28 ff ff ff       	call   8020d8 <fd2sockid>
  8021b0:	85 c0                	test   %eax,%eax
  8021b2:	78 1f                	js     8021d3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8021b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8021b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c2:	89 04 24             	mov    %eax,(%esp)
  8021c5:	e8 75 02 00 00       	call   80243f <nsipc_accept>
  8021ca:	85 c0                	test   %eax,%eax
  8021cc:	78 05                	js     8021d3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  8021ce:	e8 64 fe ff ff       	call   802037 <alloc_sockfd>
}
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    
	...

008021e0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	53                   	push   %ebx
  8021e4:	83 ec 14             	sub    $0x14,%esp
  8021e7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8021e9:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  8021f0:	75 11                	jne    802203 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8021f2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8021f9:	e8 a2 02 00 00       	call   8024a0 <ipc_find_env>
  8021fe:	a3 b0 40 80 00       	mov    %eax,0x8040b0
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802203:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80220a:	00 
  80220b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  802212:	00 
  802213:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802217:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  80221c:	89 04 24             	mov    %eax,(%esp)
  80221f:	e8 c0 02 00 00       	call   8024e4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802224:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80222b:	00 
  80222c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802233:	00 
  802234:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80223b:	e8 0f 03 00 00       	call   80254f <ipc_recv>
}
  802240:	83 c4 14             	add    $0x14,%esp
  802243:	5b                   	pop    %ebx
  802244:	5d                   	pop    %ebp
  802245:	c3                   	ret    

00802246 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802246:	55                   	push   %ebp
  802247:	89 e5                	mov    %esp,%ebp
  802249:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80224c:	8b 45 08             	mov    0x8(%ebp),%eax
  80224f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  802254:	8b 45 0c             	mov    0xc(%ebp),%eax
  802257:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80225c:	8b 45 10             	mov    0x10(%ebp),%eax
  80225f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  802264:	b8 09 00 00 00       	mov    $0x9,%eax
  802269:	e8 72 ff ff ff       	call   8021e0 <nsipc>
}
  80226e:	c9                   	leave  
  80226f:	c3                   	ret    

00802270 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  802276:	8b 45 08             	mov    0x8(%ebp),%eax
  802279:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80227e:	8b 45 0c             	mov    0xc(%ebp),%eax
  802281:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  802286:	b8 06 00 00 00       	mov    $0x6,%eax
  80228b:	e8 50 ff ff ff       	call   8021e0 <nsipc>
}
  802290:	c9                   	leave  
  802291:	c3                   	ret    

00802292 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802292:	55                   	push   %ebp
  802293:	89 e5                	mov    %esp,%ebp
  802295:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802298:	8b 45 08             	mov    0x8(%ebp),%eax
  80229b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8022a0:	b8 04 00 00 00       	mov    $0x4,%eax
  8022a5:	e8 36 ff ff ff       	call   8021e0 <nsipc>
}
  8022aa:	c9                   	leave  
  8022ab:	c3                   	ret    

008022ac <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8022ac:	55                   	push   %ebp
  8022ad:	89 e5                	mov    %esp,%ebp
  8022af:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  8022ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022bd:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  8022c2:	b8 03 00 00 00       	mov    $0x3,%eax
  8022c7:	e8 14 ff ff ff       	call   8021e0 <nsipc>
}
  8022cc:	c9                   	leave  
  8022cd:	c3                   	ret    

008022ce <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	53                   	push   %ebx
  8022d2:	83 ec 14             	sub    $0x14,%esp
  8022d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  8022e0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  8022e6:	7e 24                	jle    80230c <nsipc_send+0x3e>
  8022e8:	c7 44 24 0c 81 2e 80 	movl   $0x802e81,0xc(%esp)
  8022ef:	00 
  8022f0:	c7 44 24 08 55 2e 80 	movl   $0x802e55,0x8(%esp)
  8022f7:	00 
  8022f8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8022ff:	00 
  802300:	c7 04 24 8d 2e 80 00 	movl   $0x802e8d,(%esp)
  802307:	e8 04 e3 ff ff       	call   800610 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80230c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802310:	8b 45 0c             	mov    0xc(%ebp),%eax
  802313:	89 44 24 04          	mov    %eax,0x4(%esp)
  802317:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  80231e:	e8 d2 ec ff ff       	call   800ff5 <memmove>
	nsipcbuf.send.req_size = size;
  802323:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  802329:	8b 45 14             	mov    0x14(%ebp),%eax
  80232c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  802331:	b8 08 00 00 00       	mov    $0x8,%eax
  802336:	e8 a5 fe ff ff       	call   8021e0 <nsipc>
}
  80233b:	83 c4 14             	add    $0x14,%esp
  80233e:	5b                   	pop    %ebx
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    

00802341 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802341:	55                   	push   %ebp
  802342:	89 e5                	mov    %esp,%ebp
  802344:	56                   	push   %esi
  802345:	53                   	push   %ebx
  802346:	83 ec 10             	sub    $0x10,%esp
  802349:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80234c:	8b 45 08             	mov    0x8(%ebp),%eax
  80234f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  802354:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80235a:	8b 45 14             	mov    0x14(%ebp),%eax
  80235d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  802362:	b8 07 00 00 00       	mov    $0x7,%eax
  802367:	e8 74 fe ff ff       	call   8021e0 <nsipc>
  80236c:	89 c3                	mov    %eax,%ebx
  80236e:	85 c0                	test   %eax,%eax
  802370:	78 46                	js     8023b8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  802372:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  802377:	7f 04                	jg     80237d <nsipc_recv+0x3c>
  802379:	39 c6                	cmp    %eax,%esi
  80237b:	7d 24                	jge    8023a1 <nsipc_recv+0x60>
  80237d:	c7 44 24 0c 99 2e 80 	movl   $0x802e99,0xc(%esp)
  802384:	00 
  802385:	c7 44 24 08 55 2e 80 	movl   $0x802e55,0x8(%esp)
  80238c:	00 
  80238d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802394:	00 
  802395:	c7 04 24 8d 2e 80 00 	movl   $0x802e8d,(%esp)
  80239c:	e8 6f e2 ff ff       	call   800610 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023a5:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  8023ac:	00 
  8023ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023b0:	89 04 24             	mov    %eax,(%esp)
  8023b3:	e8 3d ec ff ff       	call   800ff5 <memmove>
	}

	return r;
}
  8023b8:	89 d8                	mov    %ebx,%eax
  8023ba:	83 c4 10             	add    $0x10,%esp
  8023bd:	5b                   	pop    %ebx
  8023be:	5e                   	pop    %esi
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    

008023c1 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8023c1:	55                   	push   %ebp
  8023c2:	89 e5                	mov    %esp,%ebp
  8023c4:	53                   	push   %ebx
  8023c5:	83 ec 14             	sub    $0x14,%esp
  8023c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8023cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8023ce:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8023d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8023de:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  8023e5:	e8 0b ec ff ff       	call   800ff5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8023ea:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8023f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8023f5:	e8 e6 fd ff ff       	call   8021e0 <nsipc>
}
  8023fa:	83 c4 14             	add    $0x14,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5d                   	pop    %ebp
  8023ff:	c3                   	ret    

00802400 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	53                   	push   %ebx
  802404:	83 ec 14             	sub    $0x14,%esp
  802407:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80240a:	8b 45 08             	mov    0x8(%ebp),%eax
  80240d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802412:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802416:	8b 45 0c             	mov    0xc(%ebp),%eax
  802419:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  802424:	e8 cc eb ff ff       	call   800ff5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802429:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80242f:	b8 02 00 00 00       	mov    $0x2,%eax
  802434:	e8 a7 fd ff ff       	call   8021e0 <nsipc>
}
  802439:	83 c4 14             	add    $0x14,%esp
  80243c:	5b                   	pop    %ebx
  80243d:	5d                   	pop    %ebp
  80243e:	c3                   	ret    

0080243f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80243f:	55                   	push   %ebp
  802440:	89 e5                	mov    %esp,%ebp
  802442:	83 ec 18             	sub    $0x18,%esp
  802445:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802448:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80244b:	8b 45 08             	mov    0x8(%ebp),%eax
  80244e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802453:	b8 01 00 00 00       	mov    $0x1,%eax
  802458:	e8 83 fd ff ff       	call   8021e0 <nsipc>
  80245d:	89 c3                	mov    %eax,%ebx
  80245f:	85 c0                	test   %eax,%eax
  802461:	78 25                	js     802488 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  802463:	be 10 60 80 00       	mov    $0x806010,%esi
  802468:	8b 06                	mov    (%esi),%eax
  80246a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80246e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  802475:	00 
  802476:	8b 45 0c             	mov    0xc(%ebp),%eax
  802479:	89 04 24             	mov    %eax,(%esp)
  80247c:	e8 74 eb ff ff       	call   800ff5 <memmove>
		*addrlen = ret->ret_addrlen;
  802481:	8b 16                	mov    (%esi),%edx
  802483:	8b 45 10             	mov    0x10(%ebp),%eax
  802486:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802488:	89 d8                	mov    %ebx,%eax
  80248a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80248d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802490:	89 ec                	mov    %ebp,%esp
  802492:	5d                   	pop    %ebp
  802493:	c3                   	ret    
	...

008024a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8024a0:	55                   	push   %ebp
  8024a1:	89 e5                	mov    %esp,%ebp
  8024a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8024a6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8024ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8024b1:	39 ca                	cmp    %ecx,%edx
  8024b3:	75 04                	jne    8024b9 <ipc_find_env+0x19>
  8024b5:	b0 00                	mov    $0x0,%al
  8024b7:	eb 0f                	jmp    8024c8 <ipc_find_env+0x28>
  8024b9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8024bc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8024c2:	8b 12                	mov    (%edx),%edx
  8024c4:	39 ca                	cmp    %ecx,%edx
  8024c6:	75 0c                	jne    8024d4 <ipc_find_env+0x34>
			return envs[i].env_id;
  8024c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024cb:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8024d0:	8b 00                	mov    (%eax),%eax
  8024d2:	eb 0e                	jmp    8024e2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024d4:	83 c0 01             	add    $0x1,%eax
  8024d7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024dc:	75 db                	jne    8024b9 <ipc_find_env+0x19>
  8024de:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    

008024e4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024e4:	55                   	push   %ebp
  8024e5:	89 e5                	mov    %esp,%ebp
  8024e7:	57                   	push   %edi
  8024e8:	56                   	push   %esi
  8024e9:	53                   	push   %ebx
  8024ea:	83 ec 1c             	sub    $0x1c,%esp
  8024ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8024f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8024f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8024f6:	85 db                	test   %ebx,%ebx
  8024f8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8024fd:	0f 44 d8             	cmove  %eax,%ebx
  802500:	eb 25                	jmp    802527 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  802502:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802505:	74 20                	je     802527 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  802507:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80250b:	c7 44 24 08 ae 2e 80 	movl   $0x802eae,0x8(%esp)
  802512:	00 
  802513:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80251a:	00 
  80251b:	c7 04 24 cc 2e 80 00 	movl   $0x802ecc,(%esp)
  802522:	e8 e9 e0 ff ff       	call   800610 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  802527:	8b 45 14             	mov    0x14(%ebp),%eax
  80252a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80252e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802532:	89 7c 24 04          	mov    %edi,0x4(%esp)
  802536:	89 34 24             	mov    %esi,(%esp)
  802539:	e8 e0 ed ff ff       	call   80131e <sys_ipc_try_send>
  80253e:	85 c0                	test   %eax,%eax
  802540:	75 c0                	jne    802502 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802542:	e8 5d ef ff ff       	call   8014a4 <sys_yield>
}
  802547:	83 c4 1c             	add    $0x1c,%esp
  80254a:	5b                   	pop    %ebx
  80254b:	5e                   	pop    %esi
  80254c:	5f                   	pop    %edi
  80254d:	5d                   	pop    %ebp
  80254e:	c3                   	ret    

0080254f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	83 ec 28             	sub    $0x28,%esp
  802555:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  802558:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80255b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80255e:	8b 75 08             	mov    0x8(%ebp),%esi
  802561:	8b 45 0c             	mov    0xc(%ebp),%eax
  802564:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  802567:	85 c0                	test   %eax,%eax
  802569:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80256e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802571:	89 04 24             	mov    %eax,(%esp)
  802574:	e8 6c ed ff ff       	call   8012e5 <sys_ipc_recv>
  802579:	89 c3                	mov    %eax,%ebx
  80257b:	85 c0                	test   %eax,%eax
  80257d:	79 2a                	jns    8025a9 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80257f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802583:	89 44 24 04          	mov    %eax,0x4(%esp)
  802587:	c7 04 24 d6 2e 80 00 	movl   $0x802ed6,(%esp)
  80258e:	e8 36 e1 ff ff       	call   8006c9 <cprintf>
		if(from_env_store != NULL)
  802593:	85 f6                	test   %esi,%esi
  802595:	74 06                	je     80259d <ipc_recv+0x4e>
			*from_env_store = 0;
  802597:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80259d:	85 ff                	test   %edi,%edi
  80259f:	74 2c                	je     8025cd <ipc_recv+0x7e>
			*perm_store = 0;
  8025a1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8025a7:	eb 24                	jmp    8025cd <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8025a9:	85 f6                	test   %esi,%esi
  8025ab:	74 0a                	je     8025b7 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8025ad:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8025b2:	8b 40 74             	mov    0x74(%eax),%eax
  8025b5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8025b7:	85 ff                	test   %edi,%edi
  8025b9:	74 0a                	je     8025c5 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8025bb:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8025c0:	8b 40 78             	mov    0x78(%eax),%eax
  8025c3:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8025c5:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8025ca:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8025cd:	89 d8                	mov    %ebx,%eax
  8025cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8025d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8025d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8025d8:	89 ec                	mov    %ebp,%esp
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    

008025dc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025dc:	55                   	push   %ebp
  8025dd:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8025df:	8b 45 08             	mov    0x8(%ebp),%eax
  8025e2:	89 c2                	mov    %eax,%edx
  8025e4:	c1 ea 16             	shr    $0x16,%edx
  8025e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025ee:	f6 c2 01             	test   $0x1,%dl
  8025f1:	74 20                	je     802613 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025f3:	c1 e8 0c             	shr    $0xc,%eax
  8025f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025fd:	a8 01                	test   $0x1,%al
  8025ff:	74 12                	je     802613 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802601:	c1 e8 0c             	shr    $0xc,%eax
  802604:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802609:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80260e:	0f b7 c0             	movzwl %ax,%eax
  802611:	eb 05                	jmp    802618 <pageref+0x3c>
  802613:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802618:	5d                   	pop    %ebp
  802619:	c3                   	ret    
  80261a:	00 00                	add    %al,(%eax)
  80261c:	00 00                	add    %al,(%eax)
	...

00802620 <__udivdi3>:
  802620:	55                   	push   %ebp
  802621:	89 e5                	mov    %esp,%ebp
  802623:	57                   	push   %edi
  802624:	56                   	push   %esi
  802625:	83 ec 10             	sub    $0x10,%esp
  802628:	8b 45 14             	mov    0x14(%ebp),%eax
  80262b:	8b 55 08             	mov    0x8(%ebp),%edx
  80262e:	8b 75 10             	mov    0x10(%ebp),%esi
  802631:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802634:	85 c0                	test   %eax,%eax
  802636:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802639:	75 35                	jne    802670 <__udivdi3+0x50>
  80263b:	39 fe                	cmp    %edi,%esi
  80263d:	77 61                	ja     8026a0 <__udivdi3+0x80>
  80263f:	85 f6                	test   %esi,%esi
  802641:	75 0b                	jne    80264e <__udivdi3+0x2e>
  802643:	b8 01 00 00 00       	mov    $0x1,%eax
  802648:	31 d2                	xor    %edx,%edx
  80264a:	f7 f6                	div    %esi
  80264c:	89 c6                	mov    %eax,%esi
  80264e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802651:	31 d2                	xor    %edx,%edx
  802653:	89 f8                	mov    %edi,%eax
  802655:	f7 f6                	div    %esi
  802657:	89 c7                	mov    %eax,%edi
  802659:	89 c8                	mov    %ecx,%eax
  80265b:	f7 f6                	div    %esi
  80265d:	89 c1                	mov    %eax,%ecx
  80265f:	89 fa                	mov    %edi,%edx
  802661:	89 c8                	mov    %ecx,%eax
  802663:	83 c4 10             	add    $0x10,%esp
  802666:	5e                   	pop    %esi
  802667:	5f                   	pop    %edi
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    
  80266a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802670:	39 f8                	cmp    %edi,%eax
  802672:	77 1c                	ja     802690 <__udivdi3+0x70>
  802674:	0f bd d0             	bsr    %eax,%edx
  802677:	83 f2 1f             	xor    $0x1f,%edx
  80267a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80267d:	75 39                	jne    8026b8 <__udivdi3+0x98>
  80267f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802682:	0f 86 a0 00 00 00    	jbe    802728 <__udivdi3+0x108>
  802688:	39 f8                	cmp    %edi,%eax
  80268a:	0f 82 98 00 00 00    	jb     802728 <__udivdi3+0x108>
  802690:	31 ff                	xor    %edi,%edi
  802692:	31 c9                	xor    %ecx,%ecx
  802694:	89 c8                	mov    %ecx,%eax
  802696:	89 fa                	mov    %edi,%edx
  802698:	83 c4 10             	add    $0x10,%esp
  80269b:	5e                   	pop    %esi
  80269c:	5f                   	pop    %edi
  80269d:	5d                   	pop    %ebp
  80269e:	c3                   	ret    
  80269f:	90                   	nop
  8026a0:	89 d1                	mov    %edx,%ecx
  8026a2:	89 fa                	mov    %edi,%edx
  8026a4:	89 c8                	mov    %ecx,%eax
  8026a6:	31 ff                	xor    %edi,%edi
  8026a8:	f7 f6                	div    %esi
  8026aa:	89 c1                	mov    %eax,%ecx
  8026ac:	89 fa                	mov    %edi,%edx
  8026ae:	89 c8                	mov    %ecx,%eax
  8026b0:	83 c4 10             	add    $0x10,%esp
  8026b3:	5e                   	pop    %esi
  8026b4:	5f                   	pop    %edi
  8026b5:	5d                   	pop    %ebp
  8026b6:	c3                   	ret    
  8026b7:	90                   	nop
  8026b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026bc:	89 f2                	mov    %esi,%edx
  8026be:	d3 e0                	shl    %cl,%eax
  8026c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8026cb:	89 c1                	mov    %eax,%ecx
  8026cd:	d3 ea                	shr    %cl,%edx
  8026cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8026d6:	d3 e6                	shl    %cl,%esi
  8026d8:	89 c1                	mov    %eax,%ecx
  8026da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8026dd:	89 fe                	mov    %edi,%esi
  8026df:	d3 ee                	shr    %cl,%esi
  8026e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026eb:	d3 e7                	shl    %cl,%edi
  8026ed:	89 c1                	mov    %eax,%ecx
  8026ef:	d3 ea                	shr    %cl,%edx
  8026f1:	09 d7                	or     %edx,%edi
  8026f3:	89 f2                	mov    %esi,%edx
  8026f5:	89 f8                	mov    %edi,%eax
  8026f7:	f7 75 ec             	divl   -0x14(%ebp)
  8026fa:	89 d6                	mov    %edx,%esi
  8026fc:	89 c7                	mov    %eax,%edi
  8026fe:	f7 65 e8             	mull   -0x18(%ebp)
  802701:	39 d6                	cmp    %edx,%esi
  802703:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802706:	72 30                	jb     802738 <__udivdi3+0x118>
  802708:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80270b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80270f:	d3 e2                	shl    %cl,%edx
  802711:	39 c2                	cmp    %eax,%edx
  802713:	73 05                	jae    80271a <__udivdi3+0xfa>
  802715:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802718:	74 1e                	je     802738 <__udivdi3+0x118>
  80271a:	89 f9                	mov    %edi,%ecx
  80271c:	31 ff                	xor    %edi,%edi
  80271e:	e9 71 ff ff ff       	jmp    802694 <__udivdi3+0x74>
  802723:	90                   	nop
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	31 ff                	xor    %edi,%edi
  80272a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80272f:	e9 60 ff ff ff       	jmp    802694 <__udivdi3+0x74>
  802734:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802738:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80273b:	31 ff                	xor    %edi,%edi
  80273d:	89 c8                	mov    %ecx,%eax
  80273f:	89 fa                	mov    %edi,%edx
  802741:	83 c4 10             	add    $0x10,%esp
  802744:	5e                   	pop    %esi
  802745:	5f                   	pop    %edi
  802746:	5d                   	pop    %ebp
  802747:	c3                   	ret    
	...

00802750 <__umoddi3>:
  802750:	55                   	push   %ebp
  802751:	89 e5                	mov    %esp,%ebp
  802753:	57                   	push   %edi
  802754:	56                   	push   %esi
  802755:	83 ec 20             	sub    $0x20,%esp
  802758:	8b 55 14             	mov    0x14(%ebp),%edx
  80275b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80275e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802761:	8b 75 0c             	mov    0xc(%ebp),%esi
  802764:	85 d2                	test   %edx,%edx
  802766:	89 c8                	mov    %ecx,%eax
  802768:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80276b:	75 13                	jne    802780 <__umoddi3+0x30>
  80276d:	39 f7                	cmp    %esi,%edi
  80276f:	76 3f                	jbe    8027b0 <__umoddi3+0x60>
  802771:	89 f2                	mov    %esi,%edx
  802773:	f7 f7                	div    %edi
  802775:	89 d0                	mov    %edx,%eax
  802777:	31 d2                	xor    %edx,%edx
  802779:	83 c4 20             	add    $0x20,%esp
  80277c:	5e                   	pop    %esi
  80277d:	5f                   	pop    %edi
  80277e:	5d                   	pop    %ebp
  80277f:	c3                   	ret    
  802780:	39 f2                	cmp    %esi,%edx
  802782:	77 4c                	ja     8027d0 <__umoddi3+0x80>
  802784:	0f bd ca             	bsr    %edx,%ecx
  802787:	83 f1 1f             	xor    $0x1f,%ecx
  80278a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80278d:	75 51                	jne    8027e0 <__umoddi3+0x90>
  80278f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802792:	0f 87 e0 00 00 00    	ja     802878 <__umoddi3+0x128>
  802798:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80279b:	29 f8                	sub    %edi,%eax
  80279d:	19 d6                	sbb    %edx,%esi
  80279f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8027a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027a5:	89 f2                	mov    %esi,%edx
  8027a7:	83 c4 20             	add    $0x20,%esp
  8027aa:	5e                   	pop    %esi
  8027ab:	5f                   	pop    %edi
  8027ac:	5d                   	pop    %ebp
  8027ad:	c3                   	ret    
  8027ae:	66 90                	xchg   %ax,%ax
  8027b0:	85 ff                	test   %edi,%edi
  8027b2:	75 0b                	jne    8027bf <__umoddi3+0x6f>
  8027b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027b9:	31 d2                	xor    %edx,%edx
  8027bb:	f7 f7                	div    %edi
  8027bd:	89 c7                	mov    %eax,%edi
  8027bf:	89 f0                	mov    %esi,%eax
  8027c1:	31 d2                	xor    %edx,%edx
  8027c3:	f7 f7                	div    %edi
  8027c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027c8:	f7 f7                	div    %edi
  8027ca:	eb a9                	jmp    802775 <__umoddi3+0x25>
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	89 c8                	mov    %ecx,%eax
  8027d2:	89 f2                	mov    %esi,%edx
  8027d4:	83 c4 20             	add    $0x20,%esp
  8027d7:	5e                   	pop    %esi
  8027d8:	5f                   	pop    %edi
  8027d9:	5d                   	pop    %ebp
  8027da:	c3                   	ret    
  8027db:	90                   	nop
  8027dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027e4:	d3 e2                	shl    %cl,%edx
  8027e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027f8:	89 fa                	mov    %edi,%edx
  8027fa:	d3 ea                	shr    %cl,%edx
  8027fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802800:	0b 55 f4             	or     -0xc(%ebp),%edx
  802803:	d3 e7                	shl    %cl,%edi
  802805:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802809:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80280c:	89 f2                	mov    %esi,%edx
  80280e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802811:	89 c7                	mov    %eax,%edi
  802813:	d3 ea                	shr    %cl,%edx
  802815:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802819:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80281c:	89 c2                	mov    %eax,%edx
  80281e:	d3 e6                	shl    %cl,%esi
  802820:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802824:	d3 ea                	shr    %cl,%edx
  802826:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80282a:	09 d6                	or     %edx,%esi
  80282c:	89 f0                	mov    %esi,%eax
  80282e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802831:	d3 e7                	shl    %cl,%edi
  802833:	89 f2                	mov    %esi,%edx
  802835:	f7 75 f4             	divl   -0xc(%ebp)
  802838:	89 d6                	mov    %edx,%esi
  80283a:	f7 65 e8             	mull   -0x18(%ebp)
  80283d:	39 d6                	cmp    %edx,%esi
  80283f:	72 2b                	jb     80286c <__umoddi3+0x11c>
  802841:	39 c7                	cmp    %eax,%edi
  802843:	72 23                	jb     802868 <__umoddi3+0x118>
  802845:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802849:	29 c7                	sub    %eax,%edi
  80284b:	19 d6                	sbb    %edx,%esi
  80284d:	89 f0                	mov    %esi,%eax
  80284f:	89 f2                	mov    %esi,%edx
  802851:	d3 ef                	shr    %cl,%edi
  802853:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802857:	d3 e0                	shl    %cl,%eax
  802859:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80285d:	09 f8                	or     %edi,%eax
  80285f:	d3 ea                	shr    %cl,%edx
  802861:	83 c4 20             	add    $0x20,%esp
  802864:	5e                   	pop    %esi
  802865:	5f                   	pop    %edi
  802866:	5d                   	pop    %ebp
  802867:	c3                   	ret    
  802868:	39 d6                	cmp    %edx,%esi
  80286a:	75 d9                	jne    802845 <__umoddi3+0xf5>
  80286c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80286f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802872:	eb d1                	jmp    802845 <__umoddi3+0xf5>
  802874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802878:	39 f2                	cmp    %esi,%edx
  80287a:	0f 82 18 ff ff ff    	jb     802798 <__umoddi3+0x48>
  802880:	e9 1d ff ff ff       	jmp    8027a2 <__umoddi3+0x52>
